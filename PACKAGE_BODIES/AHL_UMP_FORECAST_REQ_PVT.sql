--------------------------------------------------------
--  DDL for Package Body AHL_UMP_FORECAST_REQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_FORECAST_REQ_PVT" AS
/* $Header: AHLVURQB.pls 120.1.12010000.3 2009/09/06 23:17:23 sracha ship $ */

-----------------------
-- Declare Constants --
-----------------------
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_UMP_FORECAST_REQ_PVT';
--G_APP_MODULE        CONSTANT VARCHAR2(30) := 'AHL';
G_APP_MODULE        CONSTANT VARCHAR2(30) := RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));

-- UMP Statuses
G_REQ_TYPE_FORECAST CONSTANT VARCHAR2(30) := 'FORECAST';

G_IS_PM_INSTALLED   CONSTANT VARCHAR2(1) := AHL_UTIL_PKG.IS_PM_INSTALLED;

-- FND Logging Constants
G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_DEBUG_UEXP        CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

------------------------------
-- Declare Global Variables --
------------------------------
G_previous_route_id    NUMBER;
G_previous_req_date    DATE;


------------------------
-- Define Table Types --
------------------------
-- number table.
TYPE nbr_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- varchar2 table.
TYPE vchar_tbl_type IS TABLE OF VARCHAR2(400) INDEX BY BINARY_INTEGER;

-- date table
TYPE date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

--------------------------------------
-- Declare Procedures and Functions --
--------------------------------------
-- To get the root item instance for the input item instance if exists.
FUNCTION Get_RootInstanceID(p_csi_item_instance_id IN NUMBER)
RETURN NUMBER;

-- Build the item instance tree containing root nodes and its components.
PROCEDURE Build_Config_Tree(p_csi_root_instance_id  IN         NUMBER,
                            p_master_config_id      IN         NUMBER,
                            x_config_node_tbl       OUT NOCOPY AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type);

-- process material requirement for a UE.
PROCEDURE Process_Material_Req (p_unit_effectivity_id  IN NUMBER,
                      p_csi_item_instance_id IN NUMBER,
                      p_due_date             IN DATE,
                      p_mr_route_id          IN NUMBER,
                      p_route_id             IN NUMBER,
                      p_r_start_date_active  IN DATE,
                      p_r_end_date_active    IN DATE);

-- log error messages into concurrent log.
PROCEDURE log_error_messages;
-------------------------------------
-- Define Procedures and Functions --
-------------------------------------
-- Start of Comments --
--  Procedure name    : Process_Mrl_Req_Forecast
--  Type              : Private
--  Function          : Private API to collect the material requirements for unit effectivities of a given set of item instances.
--                      Insert these material requirements into AHL_SCHEDULE_MATERIALS for ASCP/DP to pick up and plan the
--                      forecasted material requirements.
--                      If a unit effectivity does not have due date, the material forecast is not done.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Route_Mtl_Req Parameters:
--      P_applicable_instances_tbl      IN     AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type  Required
--                                             The table of records containing list of item instances for which the due
--                                             date calculation process is being performed.
--
--  Version :
--      Initial Version   1.0
--  Create By : Sunil Kumar
--  End of Comments.

PROCEDURE Process_Mrl_Req_Forecast
(
   p_api_version                IN            NUMBER,
   p_init_msg_list              IN            VARCHAR2  := FND_API.G_FALSE,
   p_commit                     IN            VARCHAR2  := FND_API.G_FALSE,
   p_validation_level           IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT  NOCOPY   VARCHAR2,
   x_msg_count                  OUT  NOCOPY   NUMBER,
   x_msg_data                   OUT  NOCOPY   VARCHAR2,
   P_applicable_instances_tbl   IN            AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type
) IS

   l_Route_Mtl_Req_Tbl          AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type;

   /* Delete orphan forecast record in AHL_SCHEDULE_MATERIALS table for
    * deleted unit effectivities
    * unit effectivities where due date is null after the re-calculation
   */
   /*CURSOR delete_schedule_mtl_csr IS
   SELECT scheduled_material_id FROM AHL_SCHEDULE_MATERIALS SM
   WHERE SM.material_request_type = G_REQ_TYPE_FORECAST
   AND SM.unit_effectivity_id IS NOT NULL
   AND NOT EXISTS(SELECT 'x' FROM AHL_UNIT_EFFECTIVITIES_APP_V UE WHERE UE.unit_effectivity_id = SM.unit_effectivity_id)
   UNION ALL
   SELECT scheduled_material_id FROM AHL_SCHEDULE_MATERIALS SM, AHL_UNIT_EFFECTIVITIES_APP_V UE
   WHERE (UE.status_code IS NULL OR UE.status_code = 'INIT-DUE')
   AND UE.due_date IS NULL
   AND SM.unit_effectivity_id IS NOT NULL
   AND SM.material_request_type = G_REQ_TYPE_FORECAST
   AND SM.unit_effectivity_id = UE.unit_effectivity_id;*/

   /* Finds out all
    * open(means with status null or init-due) unit effectivities applicable to item instances - with not null due date
    * mr routes for these unit effectitivities
   */
   CURSOR ue_mr_routes_csr (p_item_indtance_id IN NUMBER) IS
   SELECT UE.unit_effectivity_id, UE.due_date, MR.mr_route_id, R.route_id, R.start_date_active, R.end_date_active
   -- FROM AHL_UNIT_EFFECTIVITIES_APP_V UE, AHL_MR_ROUTES_V MR
   FROM AHL_UNIT_EFFECTIVITIES_B UE, AHL_ROUTES_B R, AHL_MR_ROUTES MR
   WHERE UE.mr_header_id = MR.mr_header_id
   AND R.route_id = MR.ROUTE_ID
   --AND MR.APPLICATION_USG_CODE = RTRIM(LTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')))
   AND UE.APPLICATION_USG_CODE = G_APP_MODULE
   AND (UE.status_code IS NULL OR UE.status_code = 'INIT-DUE')
   AND UE.due_date IS NOT NULL
   AND UE.csi_item_instance_id = p_item_indtance_id
   ORDER BY MR.route_id, UE.due_date;

   /*
    * Find out the schedule material records for expired routes
   */
   CURSOR del_exp_route_schedule_mtl_csr(p_unit_effectivity_id IN NUMBER, p_mr_route_id IN NUMBER) IS
   SELECT scheduled_material_id FROM AHL_SCHEDULE_MATERIALS SM
   WHERE SM.material_request_type = G_REQ_TYPE_FORECAST
   AND SM.mr_route_id = p_mr_route_id
   AND SM.unit_effectivity_id IS NOT NULL
   AND SM.unit_effectivity_id = p_unit_effectivity_id;

   /* Validates whether a forecast record with unique key combination exisits
    * in AHL_SCHEDULE_MATERIALS table
    * output record used for DML update operation
   */
   CURSOR schedule_mtl_exists_csr(p_unit_effectivity_id IN NUMBER, p_mr_route_id IN NUMBER, p_inventory_item_id IN NUMBER, p_rt_oper_material_id IN NUMBER) IS
   SELECT * FROM AHL_SCHEDULE_MATERIALS SM
   WHERE SM.material_request_type = G_REQ_TYPE_FORECAST
   AND NVL(SM.rt_oper_material_id,-1) = NVL(p_rt_oper_material_id,-1)
   AND SM.inventory_item_id = p_inventory_item_id
   AND SM.mr_route_id = p_mr_route_id
   AND SM.unit_effectivity_id = p_unit_effectivity_id
   FOR UPDATE OF REQUESTED_DATE NOWAIT;

   l_Schedule_Mtl_Req_rec       AHL_SCHEDULE_MATERIALS%ROWTYPE;

   l_requirement_date DATE;
   l_previous_route_id NUMBER;
   l_previous_req_date DATE;

   l_debug_module   varchar2(400) := 'AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast';

BEGIN
     IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
		fnd_log.string
		(
			G_DEBUG_PROC,
			'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast.begin',
			'At the start of PLSQL procedure'
		);
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Process_Mrl_Req_Forecast;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- perform orphan forcast delete. Which ones? refer to comments for cursor.
     -- delete operation transferred to due date calculation API
     /*FOR delete_mtl_forecast_rec IN delete_schedule_mtl_csr LOOP
         AHL_SCHEDULE_MATERIALS_PKG.delete_row(x_scheduled_material_id => delete_mtl_forecast_rec.scheduled_material_id);
     END LOOP;*/

     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		fnd_log.string
		(
			G_DEBUG_STMT,
			'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			'Have succesfully deleted the orphan forecasts'
		);
     END IF;

     --Collect the material requirements and forecast them
     IF(P_applicable_instances_tbl IS NOT NULL AND P_applicable_instances_tbl.COUNT > 0)THEN
       FOR i IN P_applicable_instances_tbl.FIRST..P_applicable_instances_tbl.LAST  LOOP
         IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		    fnd_log.string
		    (
			    G_DEBUG_STMT,
			    'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			    'Processing unit effectivities for csi_item_instance_id : ' || P_applicable_instances_tbl(i).csi_item_instance_id
		    );
         END IF;
         FOR ue_mr_routes_rec IN ue_mr_routes_csr (P_applicable_instances_tbl(i).csi_item_instance_id) LOOP
            IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
	       fnd_log.string
		        (
			        G_DEBUG_STMT ,
			        'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			        'AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req API :p_route_id :p_mr_route_id : p_item_instance_id : p_requirement_date'
                    || ue_mr_routes_rec.route_id || ':' || ue_mr_routes_rec.mr_route_id || ':' ||P_applicable_instances_tbl(i).csi_item_instance_id
                    || ':' ||ue_mr_routes_rec.due_date
		        );
               -- log into concurrent log file.
               fnd_file.put_line(fnd_file.log,l_debug_module || ':p_route_id :p_mr_route_id : p_item_instance_id : p_requirement_date' || ue_mr_routes_rec.route_id || ':' || ue_mr_routes_rec.mr_route_id
              || ':' ||P_applicable_instances_tbl(i).csi_item_instance_id || ':' ||ue_mr_routes_rec.due_date);
           END IF;

           IF NOT(TRUNC(NVL(ue_mr_routes_rec.start_date_active,SYSDATE)) <= TRUNC(SYSDATE)
                  AND TRUNC(NVL(ue_mr_routes_rec.end_date_active,SYSDATE+1))>TRUNC(SYSDATE))THEN
              -- route is expired so delete forecast
              IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		        fnd_log.string
		        (
			        G_DEBUG_STMT ,
			        'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			        'AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req API :p_route_id :p_mr_route_id : '
                    || ue_mr_routes_rec.route_id || ':' || ue_mr_routes_rec.mr_route_id
		        );
              END IF;
              FOR del_exp_route_rec IN del_exp_route_schedule_mtl_csr(ue_mr_routes_rec.unit_effectivity_id, ue_mr_routes_rec.mr_route_id) LOOP
                AHL_SCHEDULE_MATERIALS_PKG.delete_row(x_scheduled_material_id => del_exp_route_rec.scheduled_material_id);
              END LOOP;
           ELSE
             -- route is valid and proceed to forecast
             IF(TRUNC(ue_mr_routes_rec.due_date) < TRUNC(SYSDATE))THEN
                l_requirement_date := SYSDATE;
             ELSE
              l_requirement_date := ue_mr_routes_rec.due_date;
             END IF;

             IF( NVL(l_previous_route_id,-1) <> ue_mr_routes_rec.route_id OR
               TRUNC(NVL(l_previous_req_date,l_requirement_date - 1)) <> TRUNC(l_requirement_date))THEN

               AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req
               (
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_route_id              => ue_mr_routes_rec.route_id,
                p_mr_route_id           => ue_mr_routes_rec.mr_route_id,
                p_item_instance_id      => P_applicable_instances_tbl(i).csi_item_instance_id,
                p_requirement_date      => l_requirement_date,
                p_request_type          => G_REQ_TYPE_FORECAST,
                x_route_mtl_req_tbl     => l_Route_Mtl_Req_Tbl
               );
               l_previous_route_id := ue_mr_routes_rec.route_id;
               l_previous_req_date := l_requirement_date;

               IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
                 IF(fnd_log.level_error >= G_DEBUG_LEVEL)THEN
		           fnd_log.string
		           (
			          fnd_log.level_error,
			          'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			          'AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req Threw error'
		           );
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
              END IF;

              IF (l_Route_Mtl_Req_Tbl IS NOT NULL AND l_Route_Mtl_Req_Tbl.COUNT > 0)THEN
              IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		          fnd_log.string
		          (
			        G_DEBUG_STMT,
			        'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			        'After call AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req API : l_Route_Mtl_Req_Tbl.COUNT : ' || l_Route_Mtl_Req_Tbl.COUNT
		          );
              END IF;
              FOR j IN l_Route_Mtl_Req_Tbl.FIRST..l_Route_Mtl_Req_Tbl.LAST LOOP
                  OPEN schedule_mtl_exists_csr(ue_mr_routes_rec.unit_effectivity_id,
                           ue_mr_routes_rec.mr_route_id, l_Route_Mtl_Req_Tbl(j).inventory_item_id, l_Route_Mtl_Req_Tbl(j).rt_oper_material_id);
                  FETCH schedule_mtl_exists_csr INTO l_Schedule_Mtl_Req_rec;
                  IF(schedule_mtl_exists_csr%NOTFOUND)THEN
                    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		                fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'Inserting record in AHL_SCHEDULE_MATERIALS '
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'unit_effectivity_id :  ' || ue_mr_routes_rec.unit_effectivity_id
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'requested_date :  ' || ue_mr_routes_rec.due_date
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'mr_route_id : '|| ue_mr_routes_rec.mr_route_id
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'inventory_item_id :  ' || l_Route_Mtl_Req_Tbl(j).inventory_item_id
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'quantity :  ' || l_Route_Mtl_Req_Tbl(j).quantity
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'uom :  ' || l_Route_Mtl_Req_Tbl(j).uom_code
		                );
                    END IF;
                    AHL_SCHEDULE_MATERIALS_PKG.INSERT_ROW
                    (
                        X_SCHEDULED_MATERIAL_ID  => NULL,
                        X_OBJECT_VERSION_NUMBER  => 1,
                        X_LAST_UPDATE_DATE       => SYSDATE,
                        X_LAST_UPDATED_BY        => fnd_global.user_id,
                        X_CREATION_DATE          => SYSDATE,
                        X_CREATED_BY             => fnd_global.user_id,
                        X_LAST_UPDATE_LOGIN      => fnd_global.user_id,
                        X_INVENTORY_ITEM_ID      => l_Route_Mtl_Req_Tbl(j).inventory_item_id,
                        X_SCHEDULE_DESIGNATOR    => NULL,
                        X_VISIT_ID               => NULL,
                        X_VISIT_START_DATE       => NULL,
                        X_VISIT_TASK_ID          => NULL,
                        X_ORGANIZATION_ID        => NULL,
                        X_SCHEDULED_DATE         => NULL,
                        X_REQUEST_ID             => NULL,
                        -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                        X_REQUESTED_DATE         => trunc(ue_mr_routes_rec.due_date),
                        X_SCHEDULED_QUANTITY     => NULL,
                        X_PROCESS_STATUS         => NULL,
                        X_ERROR_MESSAGE          => NULL,
                        X_TRANSACTION_ID         => NULL,
                        X_UOM                    => l_Route_Mtl_Req_Tbl(j).uom_code,
                        X_RT_OPER_MATERIAL_ID    => l_Route_Mtl_Req_Tbl(j).rt_oper_material_id,
                        X_OPERATION_CODE         => NULL,
                        X_OPERATION_SEQUENCE     => NULL,
                        X_ITEM_GROUP_ID          => l_Route_Mtl_Req_Tbl(j).item_group_id,
                        X_REQUESTED_QUANTITY     => l_Route_Mtl_Req_Tbl(j).quantity,
                        X_PROGRAM_ID             => NULL,
                        X_PROGRAM_UPDATE_DATE    => NULL,
                        X_LAST_UPDATED_DATE      => NULL,
                        X_WORKORDER_OPERATION_ID => NULL,
                        X_POSITION_PATH_ID       => l_Route_Mtl_Req_Tbl(j).position_path_id,
                        X_RELATIONSHIP_ID        => l_Route_Mtl_Req_Tbl(j).relationship_id,
                        X_UNIT_EFFECTIVITY_ID    => ue_mr_routes_rec.unit_effectivity_id,
                        X_MR_ROUTE_ID            => ue_mr_routes_rec.mr_route_id,
                        X_MATERIAL_REQUEST_TYPE  => G_REQ_TYPE_FORECAST,
                        X_ATTRIBUTE_CATEGORY     => NULL,
                        X_ATTRIBUTE1             => NULL,
                        X_ATTRIBUTE2             => NULL,
                        X_ATTRIBUTE3             => NULL,
                        X_ATTRIBUTE4             => NULL,
                        X_ATTRIBUTE5             => NULL,
                        X_ATTRIBUTE6             => NULL,
                        X_ATTRIBUTE7             => NULL,
                        X_ATTRIBUTE8             => NULL,
                        X_ATTRIBUTE9             => NULL,
                        X_ATTRIBUTE10            => NULL,
                        X_ATTRIBUTE11            => NULL,
                        X_ATTRIBUTE12            => NULL,
                        X_ATTRIBUTE13            => NULL,
                        X_ATTRIBUTE14            => NULL,
                        X_ATTRIBUTE15            => NULL
                    );
                  ELSE
                    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		                fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'Updating record in AHL_SCHEDULE_MATERIALS '
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'unit_effectivity_id :  ' || ue_mr_routes_rec.unit_effectivity_id
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'requested_date :  ' || ue_mr_routes_rec.due_date
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'mr_route_id : '|| ue_mr_routes_rec.mr_route_id
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'inventory_item_id :  ' || l_Route_Mtl_Req_Tbl(j).inventory_item_id
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'quantity :  ' || l_Route_Mtl_Req_Tbl(j).quantity
		                );
                        fnd_log.string
		                (
			                G_DEBUG_STMT,
			                'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			                'uom :  ' || l_Route_Mtl_Req_Tbl(j).uom_code
		                );
                    END IF;
                    AHL_SCHEDULE_MATERIALS_PKG.UPDATE_ROW
                    (
                        X_SCHEDULED_MATERIAL_ID  => l_Schedule_Mtl_Req_rec.SCHEDULED_MATERIAL_ID,
                        X_OBJECT_VERSION_NUMBER  => l_Schedule_Mtl_Req_rec.OBJECT_VERSION_NUMBER,--Update Column
                        X_LAST_UPDATE_DATE       => SYSDATE,
                        X_LAST_UPDATED_BY        => fnd_global.user_id,
                        X_LAST_UPDATE_LOGIN      => fnd_global.user_id,
                        X_INVENTORY_ITEM_ID      => l_Schedule_Mtl_Req_rec.INVENTORY_ITEM_ID,
                        X_SCHEDULE_DESIGNATOR    => l_Schedule_Mtl_Req_rec.SCHEDULE_DESIGNATOR,
                        X_VISIT_ID               => l_Schedule_Mtl_Req_rec.VISIT_ID,
                        X_VISIT_START_DATE       => l_Schedule_Mtl_Req_rec.VISIT_START_DATE,
                        X_VISIT_TASK_ID          => l_Schedule_Mtl_Req_rec.VISIT_TASK_ID,
                        X_ORGANIZATION_ID        => l_Schedule_Mtl_Req_rec.ORGANIZATION_ID,
                        X_SCHEDULED_DATE         => l_Schedule_Mtl_Req_rec.SCHEDULED_DATE,
                        X_REQUEST_ID             => l_Schedule_Mtl_Req_rec.REQUEST_ID,
                        -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                        X_REQUESTED_DATE         => trunc(ue_mr_routes_rec.due_date),--Update Column
                        X_SCHEDULED_QUANTITY     => l_Schedule_Mtl_Req_rec.SCHEDULED_QUANTITY,
                        X_PROCESS_STATUS         => l_Schedule_Mtl_Req_rec.PROCESS_STATUS,
                        X_ERROR_MESSAGE          => l_Schedule_Mtl_Req_rec.ERROR_MESSAGE,
                        X_TRANSACTION_ID         => l_Schedule_Mtl_Req_rec.TRANSACTION_ID,
                        X_UOM                    => l_Route_Mtl_Req_Tbl(j).uom_code,--Update Column
                        X_RT_OPER_MATERIAL_ID    => l_Route_Mtl_Req_Tbl(j).rt_oper_material_id,--Update Column
                        X_OPERATION_CODE         => l_Schedule_Mtl_Req_rec.OPERATION_CODE,
                        X_OPERATION_SEQUENCE     => l_Schedule_Mtl_Req_rec.OPERATION_SEQUENCE,
                        X_ITEM_GROUP_ID          => l_Route_Mtl_Req_Tbl(j).item_group_id,--Update Column
                        X_REQUESTED_QUANTITY     => l_Route_Mtl_Req_Tbl(j).quantity,--Update Column
                        X_PROGRAM_ID             => l_Schedule_Mtl_Req_rec.PROGRAM_ID,
                        X_PROGRAM_UPDATE_DATE    => l_Schedule_Mtl_Req_rec.PROGRAM_UPDATE_DATE,
                        X_LAST_UPDATED_DATE      => l_Schedule_Mtl_Req_rec.LAST_UPDATED_DATE,
                        X_WORKORDER_OPERATION_ID => l_Schedule_Mtl_Req_rec.WORKORDER_OPERATION_ID,
                        X_POSITION_PATH_ID       => l_Route_Mtl_Req_Tbl(j).position_path_id,--Update Column
                        X_RELATIONSHIP_ID        => l_Route_Mtl_Req_Tbl(j).relationship_id,--Update Column
                        X_UNIT_EFFECTIVITY_ID    => l_Schedule_Mtl_Req_rec.UNIT_EFFECTIVITY_ID,
                        X_MR_ROUTE_ID            => l_Schedule_Mtl_Req_rec.MR_ROUTE_ID,
                        X_MATERIAL_REQUEST_TYPE  => l_Schedule_Mtl_Req_rec.MATERIAL_REQUEST_TYPE,
                        X_ATTRIBUTE_CATEGORY     => l_Schedule_Mtl_Req_rec.ATTRIBUTE_CATEGORY,
                        X_ATTRIBUTE1             => l_Schedule_Mtl_Req_rec.ATTRIBUTE1,
                        X_ATTRIBUTE2             => l_Schedule_Mtl_Req_rec.ATTRIBUTE2,
                        X_ATTRIBUTE3             => l_Schedule_Mtl_Req_rec.ATTRIBUTE3,
                        X_ATTRIBUTE4             => l_Schedule_Mtl_Req_rec.ATTRIBUTE4,
                        X_ATTRIBUTE5             => l_Schedule_Mtl_Req_rec.ATTRIBUTE5,
                        X_ATTRIBUTE6             => l_Schedule_Mtl_Req_rec.ATTRIBUTE6,
                        X_ATTRIBUTE7             => l_Schedule_Mtl_Req_rec.ATTRIBUTE7,
                        X_ATTRIBUTE8             => l_Schedule_Mtl_Req_rec.ATTRIBUTE8,
                        X_ATTRIBUTE9             => l_Schedule_Mtl_Req_rec.ATTRIBUTE9,
                        X_ATTRIBUTE10            => l_Schedule_Mtl_Req_rec.ATTRIBUTE10,
                        X_ATTRIBUTE11            => l_Schedule_Mtl_Req_rec.ATTRIBUTE11,
                        X_ATTRIBUTE12            => l_Schedule_Mtl_Req_rec.ATTRIBUTE12,
                        X_ATTRIBUTE13            => l_Schedule_Mtl_Req_rec.ATTRIBUTE13,
                        X_ATTRIBUTE14            => l_Schedule_Mtl_Req_rec.ATTRIBUTE14,
                        X_ATTRIBUTE15            => l_Schedule_Mtl_Req_rec.ATTRIBUTE15
                    );
                  END IF;
                  CLOSE schedule_mtl_exists_csr;
              END LOOP; -- Finished forecasting for single mr route in a unit effectivity
            END IF;-- if route material requirement has a list to be forecasted
          END IF;
         END LOOP;-- For all unit effectivities
       END LOOP;-- for all item instances
     END IF;-- if there is a list of item instances

     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
		fnd_log.string
		(
			G_DEBUG_STMT,
			'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast',
			'Have succesfully finished forecasting'
		);
     END IF;
     -- Check Error Message stack.
     x_msg_count := FND_MSG_PUB.count_msg;
     IF x_msg_count > 0 THEN
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
     END IF;

     IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
		fnd_log.string
		(
			G_DEBUG_PROC,
			'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Mrl_Req_Forecast.end',
			'At the end of PLSQL procedure'
		);
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Process_Mrl_Req_Forecast;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Process_Mrl_Req_Forecast;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Process_Mrl_Req_Forecast;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Mrl_Req_Forecast',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

END Process_Mrl_Req_Forecast;

---
-- Called from concurrent program. This will create/update the material
-- forecast stream.
PROCEDURE Build_Mat_Forecast_Stream (
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_unit_config_hdr_id    IN          NUMBER,
    p_item_instance_id      IN          NUMBER)
IS

   -- To validate instance.
  CURSOR csi_item_instances_csr(p_csi_item_instance_id IN  NUMBER) IS
    SELECT instance_number, active_end_date
    FROM csi_item_instances
    WHERE instance_id = p_csi_item_instance_id;

  -- To validate unit.
  CURSOR ahl_unit_config_headers_csr (p_uc_header_id IN NUMBER) IS
    SELECT name, csi_item_instance_id, master_config_id, unit_config_status_code
    FROM  ahl_unit_config_headers
    WHERE unit_config_header_id = p_uc_header_id;

  -- To get unit config id.
  CURSOR ahl_unit_config_header_csr (p_item_instance_id IN NUMBER) IS
    SELECT name, master_config_id, unit_config_status_code
    FROM  ahl_unit_config_headers
    WHERE csi_item_instance_id = p_item_instance_id
      AND parent_uc_header_id IS NULL;

  -- get mr_route and route_id for a mr_header.
  CURSOR ahl_mr_route_csr(p_mr_header_id IN NUMBER) IS
    SELECT rt.mr_route_id, rt.route_id, R.start_date_active, R.end_date_active
    FROM AHL_MR_ROUTES rt, ahl_routes_b R
    WHERE rt.route_id = r.route_id
      AND rt.mr_header_id = p_mr_header_id;

  -- get mr headers
  CURSOR ahl_mr_header_csr(appln_usg_code IN VARCHAR2) IS
    SELECT mr_header_id
      FROM ahl_mr_headers_b mr
      WHERE application_usg_code = appln_usg_code
      AND mr_status_code = 'COMPLETE'
      AND EXISTS (SELECT 1
                  FROM ahl_unit_effectivities_b
                  WHERE mr_header_id = mr.mr_header_id
                    AND (status_code IS NULL OR status_code = 'INIT-DUE')
                 );

  -- get open UE IDs for the MR header.
  -- check if instance expired to fix bug# 8543402.
  CURSOR get_ue_csr (p_mr_header_id IN NUMBER) IS
    SELECT unit_effectivity_id, due_date, csi_item_instance_id
      FROM ahl_unit_effectivities_b UE, csi_item_instances II
     WHERE UE.mr_header_id = p_mr_header_id
       AND UE.csi_item_instance_id = II.instance_id
       AND nvl(ii.active_end_date, sysdate+1) > sysdate
       AND UE.due_date IS NOT NULL
       AND (UE.status_code IS NULL OR UE.status_code = 'INIT-DUE');
     --ORDER BY csi_item_instance_id, due_date;

  l_debug_module          VARCHAR2(400) := 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Build_Mat_Forecast_Stream';

  l_csi_item_instance_id  NUMBER;
  l_name                  ahl_unit_config_headers.name%TYPE;
  l_instance_number       csi_item_instances.instance_number%TYPE;
  l_active_end_date       DATE;

  l_config_node_tbl       AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type;
  l_master_config_id      NUMBER;
  l_config_status_code    fnd_lookup_values_vl.lookup_code%TYPE;

  l_msg_data              VARCHAR2(2000);
  l_msg_count             NUMBER;
  l_return_status         VARCHAR2(1);

  l_mr_route_id_tbl       nbr_tbl_type;
  l_route_id_tbl          nbr_tbl_type;
  l_mr_header_id_tbl      nbr_tbl_type;
  l_r_start_date_tbl      date_tbl_type;
  l_r_end_date_tbl        date_tbl_type;

  l_ue_id_tbl             nbr_tbl_type;
  l_ue_due_date_tbl       date_tbl_type;
  l_ue_ii_id_tbl          nbr_tbl_type;

  l_buffer_limit          NUMBER := 1000;

BEGIN

  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string ( G_DEBUG_PROC, l_debug_module, 'Start Build_Mat_Forecast_Stream');
     fnd_log.string ( G_DEBUG_PROC, l_debug_module,
                      'Input Parameter: p_unit_config_hdr_id:' || p_unit_config_hdr_id);
     fnd_log.string ( G_DEBUG_PROC, l_debug_module,
                      'Input Parameter: p_item_instance_id:' || p_item_instance_id);
  END IF;

   -- initialize return status.
   retcode := 0;

   IF (G_IS_PM_INSTALLED <> 'N') THEN
     -- only valid for application usg code - AHL
     RETURN;
   END IF;

   IF (p_unit_config_hdr_id IS NOT NULL OR p_item_instance_id IS NOT NULL) THEN
      IF (p_item_instance_id IS NOT NULL) THEN
         -- validate item instance.
         OPEN csi_item_instances_csr (p_item_instance_id);
         FETCH csi_item_instances_csr INTO l_instance_number, l_active_end_date;
         IF (csi_item_instances_csr%NOTFOUND) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INSTID_NOTFOUND');
            FND_MESSAGE.Set_Token('INST_ID', p_item_instance_id);
            FND_MSG_PUB.ADD;
            CLOSE csi_item_instances_csr;
            --dbms_output.put_line('Instance not found');
            errbuf := FND_MSG_PUB.GET;
            retcode := 2;
         ELSIF (trunc(l_active_end_date) < trunc(sysdate)) THEN
           FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_INST_EXPIRED');
           FND_MESSAGE.Set_Token('NUMBER', l_instance_number);
           FND_MSG_PUB.ADD;
           --dbms_output.put_line('Instance has expired');
           errbuf := FND_MSG_PUB.GET;
           retcode := 2;
         ELSE
           l_csi_item_instance_id := p_item_instance_id;

           -- If item instance is not top node, find the root item instance.
           l_csi_item_instance_id := Get_RootInstanceID(l_csi_item_instance_id);

           -- get master Config ID if root instance is a UC.
           OPEN ahl_unit_config_header_csr(l_csi_item_instance_id);
           FETCH ahl_unit_config_header_csr INTO l_name, l_master_config_id, l_config_status_code;
           IF (ahl_unit_config_header_csr%FOUND) THEN
              IF (l_config_status_code = 'DRAFT') THEN
                 FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_STATUS_INVALID');
                 FND_MESSAGE.Set_Token('NAME',l_name);
                 FND_MSG_PUB.ADD;
                 errbuf := FND_MSG_PUB.GET;
                 retcode := 2;
              END IF;
           ELSE
              l_master_config_id := NULL;
           END IF; -- ahl_unit_config_header_csr%FOUND
           CLOSE ahl_unit_config_header_csr;

         END IF; -- csi_item_instances_csr%NOTFOUND
         CLOSE csi_item_instances_csr;

      END IF; -- p_item_instance_id

      IF (p_unit_config_hdr_id IS NOT NULL) THEN
          -- Validate unit config id.
          OPEN ahl_unit_config_headers_csr (p_unit_config_hdr_id);
          FETCH ahl_unit_config_headers_csr INTO l_name, l_csi_item_instance_id, l_master_config_id,
                                                 l_config_status_code ;
          IF (ahl_unit_config_headers_csr%NOTFOUND) THEN
              FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_UNIT_NOTFOUND');
              FND_MESSAGE.Set_Token('UNIT_ID',p_unit_config_hdr_id);
              FND_MSG_PUB.ADD;
              errbuf := FND_MSG_PUB.GET;
              retcode := 2;
              --dbms_output.put_line('Unit not found');
          ELSE
            IF (l_config_status_code = 'DRAFT') THEN
               FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_STATUS_INVALID');
               FND_MESSAGE.Set_Token('NAME',l_name);
               FND_MSG_PUB.ADD;
               CLOSE ahl_unit_config_headers_csr;

               errbuf := FND_MSG_PUB.GET;
               retcode := 2;
            END IF;
          END IF;
      END IF; -- p_unit_config_hdr_id

      -- Check error code.
      IF (retcode = 2) THEN
        RETURN;
      END IF;

      IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
        fnd_log.string ( G_DEBUG_PROC, l_debug_module, 'Master Config ID:' || l_master_config_id);
        fnd_log.string ( G_DEBUG_PROC, l_debug_module, 'Root Instance ID:' || l_csi_item_instance_id);
      END IF;

      -- Build the Configuration tree structure.(G_config_node_tbl).
      Build_Config_Tree(l_csi_item_instance_id, l_master_config_id, l_config_node_tbl);

      SAVEPOINT Build_Mrl_Forecast_Stream_s;

      --call for material requirement forecast
      AHL_UMP_FORECAST_REQ_PVT.process_mrl_req_forecast
      (
       p_api_version                => 1.0,
       p_init_msg_list              => FND_API.G_TRUE,
       p_commit                     => FND_API.G_FALSE,
       p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
       x_return_status              => l_return_status,
       x_msg_count                  => l_msg_count,
       x_msg_data                   => l_msg_data,
       p_applicable_instances_tbl   => l_config_node_tbl
      );

      l_msg_count := FND_MSG_PUB.Count_Msg;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        retcode := 2;  -- error based only on return status
      ELSIF (l_msg_count > 0 AND l_return_status = FND_API.G_RET_STS_SUCCESS)
      THEN
         retcode := 1;  -- warning based on return status + msg count
      END IF;

      -- success.
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT WORK;
      END IF;

   END IF; -- p_unit_config_hdr_id IS NOT NULL OR p_item_instance_id IS NOT NULL

   IF (p_unit_config_hdr_id IS NULL AND p_item_instance_id IS NULL) THEN
      -- process all UEs.
      OPEN ahl_mr_header_csr(G_APP_MODULE);
      LOOP
        FETCH ahl_mr_header_csr BULK COLLECT INTO l_mr_header_id_tbl LIMIT l_buffer_limit;
        EXIT WHEN (l_mr_header_id_tbl.count = 0);

        FOR j IN l_mr_header_id_tbl.FIRST..l_mr_header_id_tbl.LAST LOOP

          -- set savepoint for MR and commit after processing MR.
          SAVEPOINT Build_Mrl_Forecast_Stream_s;

          IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
            fnd_log.string ( G_DEBUG_STMT, l_debug_module, 'MR Header ID:' || l_mr_header_id_tbl(j));
          END IF;

          OPEN ahl_mr_route_csr(l_mr_header_id_tbl(j));
          FETCH ahl_mr_route_csr BULK COLLECT INTO l_mr_route_id_tbl, l_route_id_tbl,
                                                   l_r_start_date_tbl, l_r_end_date_tbl;
          CLOSE ahl_mr_route_csr;

          -- get UE IDs and due dates for the MR.
          OPEN get_ue_csr(l_mr_header_id_tbl(j));
          LOOP
            FETCH get_ue_csr BULK COLLECT INTO l_ue_id_tbl, l_ue_due_date_tbl, l_ue_ii_id_tbl LIMIT l_buffer_limit;
            EXIT WHEN (l_ue_id_tbl.COUNT = 0);
            FOR i IN l_ue_id_tbl.FIRST..l_ue_id_tbl.LAST LOOP
               IF (l_mr_route_id_tbl.COUNT > 0) THEN
                  FOR k IN l_mr_route_id_tbl.FIRST..l_mr_route_id_tbl.LAST LOOP
                     -- validate and update/insert into schedule materials for
                     -- every combination of UE and mr_route_id.
                     AHL_UMP_FORECAST_REQ_PVT.Process_Material_Req
                              (p_unit_effectivity_id  => l_ue_id_tbl(i),
                               p_csi_item_instance_id => l_ue_ii_id_tbl(i),
                               p_due_date             => l_ue_due_date_tbl(i),
                               p_mr_route_id          => l_mr_route_id_tbl(k),
                               p_route_id             => l_route_id_tbl(k),
                               p_r_start_date_active  => l_r_start_date_tbl(k),
                               p_r_end_date_active    => l_r_end_date_tbl(k)
                              );
                  END LOOP; -- l_mr_route_id_tbl.FIRST
               END IF; -- l_mr_route_id_tbl.COUNT
            END LOOP; -- l_ue_id_tbl.FIRST
          END LOOP;
          CLOSE  get_ue_csr;

          COMMIT WORK;  -- commit after processing MR.

        END LOOP; -- l_mr_header_id_tbl.FIRST
      END LOOP;  -- ahl_mr_header_csr
      CLOSE ahl_mr_header_csr;

   END IF; -- p_unit_config_hdr_id IS NULL AND p_item_instance_id IS NULL


   IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
     fnd_log.string ( G_DEBUG_PROC, l_debug_module, 'Out Parameter: retcode:' || retcode);
     fnd_log.string ( G_DEBUG_PROC, l_debug_module, 'Out Parameter: errbuf:' || errbuf);
     fnd_log.string ( G_DEBUG_PROC, l_debug_module, 'End Build_Mat_Forecast_Stream');
   END IF;


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Build_Mrl_Forecast_Stream_s;
   retcode := 2;
   log_error_messages;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Build_Mrl_Forecast_Stream_s;
   retcode := 2;
   log_error_messages;


 WHEN OTHERS THEN
    ROLLBACK TO Build_Mrl_Forecast_Stream_s;
   retcode := 2;
   log_error_messages;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Build_Mrl_Forecast_Stream',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;

END Build_Mat_Forecast_Stream;

-----------------------------------------------------------------------
-- To get the root item instance for the input item instance if exists.

FUNCTION Get_RootInstanceID(p_csi_item_instance_id IN NUMBER)
RETURN NUMBER
IS

  CURSOR csi_root_instance_csr (p_instance_id IN NUMBER) IS
    SELECT root.object_id
    FROM csi_ii_relationships root
    WHERE NOT EXISTS (SELECT 'x'
                      FROM csi_ii_relationships
                      WHERE subject_id = root.object_id
                        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      )
    START WITH root.subject_id = p_instance_id
               AND root.relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(root.active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(root.active_end_date, sysdate+1))
    CONNECT BY PRIOR root.object_id = root.subject_id
                     AND root.relationship_type_code = 'COMPONENT-OF'
                     AND trunc(nvl(root.active_start_date,sysdate)) <= trunc(sysdate)
                     AND trunc(sysdate) < trunc(nvl(root.active_end_date, sysdate+1));

  l_csi_instance_id  NUMBER;

BEGIN

  -- get root instance given an item instance_id.
  OPEN csi_root_instance_csr (p_csi_item_instance_id);
  FETCH csi_root_instance_csr INTO l_csi_instance_id;
  IF (csi_root_instance_csr%NOTFOUND) THEN
     -- input id is root instance.
     l_csi_instance_id := p_csi_item_instance_id;
  END IF;
  CLOSE csi_root_instance_csr;
  --dbms_output.put_line ('root instance' || l_csi_instance_id);

  RETURN  l_csi_instance_id;

END Get_RootInstanceID;

-------------------------------------------------------------
-- Build the item instance tree containing root nodes and its components.
PROCEDURE Build_Config_Tree(p_csi_root_instance_id IN         NUMBER,
                            p_master_config_id     IN         NUMBER,
                            x_config_node_tbl      OUT NOCOPY AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type)

IS

  CURSOR csi_config_tree_csr ( p_csi_root_instance_id IN NUMBER) IS
    SELECT subject_id , object_id, position_reference
    FROM csi_ii_relationships
    START WITH object_id = p_csi_root_instance_id
               AND relationship_type_code = 'COMPONENT-OF'
               AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
               AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    CONNECT BY PRIOR subject_id = object_id
                     AND relationship_type_code = 'COMPONENT-OF'
                     AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                     AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
    ORDER BY level;

  i  NUMBER;
  l_config_node_tbl   AHL_UMP_PROCESSUNIT_PVT.config_node_tbl_type := x_config_node_tbl;

  -- added for perf fix for bug# 6893404.
  l_buffer_limit      number := 1000;

  l_subj_id_tbl       nbr_tbl_type;
  l_obj_id_tbl        nbr_tbl_type;
  l_posn_ref_tbl      vchar_tbl_type;

BEGIN

  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
     fnd_log.string ( G_DEBUG_PROC, 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Build_Config_Tree',
                      'Start Build_Config_Tree');
  END IF;

   -- For top node.
  l_config_node_tbl(1).csi_item_instance_id := p_csi_root_instance_id;

  -- For position reference.
  IF (p_master_config_id IS NOT NULL) THEN
    l_config_node_tbl(1).position_reference := to_char(p_master_config_id);
  END IF;

  i := 1;

  -- add child nodes.
  -- added for perf fix for bug# 6893404.
  OPEN csi_config_tree_csr(p_csi_root_instance_id);
  LOOP
    FETCH csi_config_tree_csr BULK COLLECT INTO l_subj_id_tbl, l_obj_id_tbl, l_posn_ref_tbl
                              LIMIT l_buffer_limit;

    EXIT WHEN (l_subj_id_tbl.count = 0);

    FOR j IN l_subj_id_tbl.FIRST..l_subj_id_tbl.LAST LOOP

      -- Loop through to get all components of the configuration.
      i := i + 1;

      l_config_node_tbl(i).csi_item_instance_id := l_subj_id_tbl(j);
      l_config_node_tbl(i).object_id            := l_obj_id_tbl(j);
      l_config_node_tbl(i).position_reference   := l_posn_ref_tbl(j);

    END LOOP; -- l_subj_id_tbl.FIRST

    -- reset tables and get the next batch of nodes.
    l_subj_id_tbl.DELETE;
    l_obj_id_tbl.DELETE;
    l_posn_ref_tbl.DELETE;

  END LOOP; -- FETCH csi_config_tree_csr
  CLOSE csi_config_tree_csr;

  X_CONFIG_NODE_TBL := l_config_node_tbl;

  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
      fnd_log.string (G_DEBUG_PROC, 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Build_Config_Tree',
                      'Count on config' || x_config_node_tbl.COUNT);

      fnd_log.string (G_DEBUG_PROC, 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Build_Config_Tree',
                      'End Build_Config_Tree');
  END IF;

END Build_Config_Tree;
---
PROCEDURE Process_Material_Req (p_unit_effectivity_id  IN NUMBER,
                      p_csi_item_instance_id IN NUMBER,
                      p_due_date             IN DATE,
                      p_mr_route_id          IN NUMBER,
                      p_route_id             IN NUMBER,
                      p_r_start_date_active  IN DATE,
                      p_r_end_date_active    IN DATE)
IS

   -- Find out the schedule material records for expired routes
   CURSOR del_exp_route_schedule_mtl_csr(p_unit_effectivity_id IN NUMBER, p_mr_route_id IN NUMBER) IS
   SELECT scheduled_material_id FROM AHL_SCHEDULE_MATERIALS SM
   WHERE SM.material_request_type = G_REQ_TYPE_FORECAST
   AND SM.mr_route_id = p_mr_route_id
   AND SM.unit_effectivity_id IS NOT NULL
   AND SM.unit_effectivity_id = p_unit_effectivity_id;

   -- Validates whether a forecast record with unique key combination exisits
   -- in AHL_SCHEDULE_MATERIALS table
   -- output record used for DML update operation
   CURSOR schedule_mtl_exists_csr(p_unit_effectivity_id IN NUMBER,
                                  p_mr_route_id IN NUMBER,
                                  p_inventory_item_id IN NUMBER,
                                  p_rt_oper_material_id IN NUMBER) IS
   SELECT * FROM AHL_SCHEDULE_MATERIALS SM
   WHERE SM.material_request_type = G_REQ_TYPE_FORECAST
   AND NVL(SM.rt_oper_material_id,-1) = NVL(p_rt_oper_material_id,-1)
   AND SM.inventory_item_id = p_inventory_item_id
   AND SM.mr_route_id = p_mr_route_id
   AND SM.unit_effectivity_id = p_unit_effectivity_id
   FOR UPDATE OF REQUESTED_DATE NOWAIT;

   l_debug_module               VARCHAR2(1000) := 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.Process_Material_Req';
   l_Schedule_Mtl_Req_rec       AHL_SCHEDULE_MATERIALS%ROWTYPE;
   l_requirement_date           DATE;
   l_Route_Mtl_Req_Tbl          AHL_LTP_MTL_REQ_PVT.Route_Mtl_Req_Tbl_Type;

   l_msg_data                   VARCHAR2(2000);
   l_msg_count                  NUMBER;
   l_return_status              VARCHAR2(1);

BEGIN

  IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
    fnd_log.string (G_DEBUG_STMT , l_debug_module,
                    'p_route_id:p_mr_route_id:p_item_instance_id:p_requirement_date:' || p_route_id || ':' || p_mr_route_id || ':' ||p_csi_item_instance_id || ':' || p_due_date);

    -- log into concurrent log file.
    fnd_file.put_line(fnd_file.log,l_debug_module || ':p_route_id :p_mr_route_id : p_item_instance_id : p_requirement_date' || p_route_id || ':' || p_mr_route_id || ':' ||p_csi_item_instance_id || ':' || p_due_date);

  END IF;



  IF NOT(TRUNC(NVL(p_r_start_date_active,SYSDATE)) <= TRUNC(SYSDATE)
     AND TRUNC(NVL(p_r_end_date_active,SYSDATE+1))>TRUNC(SYSDATE)) THEN
     -- route is expired so delete forecast
     IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
       fnd_log.string (G_DEBUG_STMT ,l_debug_module,
                      'p_route_id :p_mr_route_id : ' || p_route_id || ':' || p_mr_route_id);
     END IF;

     FOR del_exp_route_rec IN del_exp_route_schedule_mtl_csr(p_unit_effectivity_id,p_mr_route_id) LOOP
        AHL_SCHEDULE_MATERIALS_PKG.delete_row(x_scheduled_material_id => del_exp_route_rec.scheduled_material_id);
     END LOOP;

  ELSE
     -- route is valid and proceed to forecast
     IF(TRUNC(p_due_date) < TRUNC(SYSDATE)) THEN
        l_requirement_date := SYSDATE;
     ELSE
        l_requirement_date := p_due_date;
     END IF;

--     IF (NVL(G_previous_route_id,-1) <> p_route_id OR
--        TRUNC(NVL(G_previous_req_date,l_requirement_date - 1)) <> TRUNC(l_requirement_date))THEN

         AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req
          (
           p_api_version           => 1.0,
           p_init_msg_list         => FND_API.G_FALSE,
           p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
           x_return_status         => l_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data,
           p_route_id              => p_route_id,
           p_mr_route_id           => p_mr_route_id,
           p_item_instance_id      => p_csi_item_instance_id,
           p_requirement_date      => l_requirement_date,
           p_request_type          => G_REQ_TYPE_FORECAST,
           x_route_mtl_req_tbl     => l_Route_Mtl_Req_Tbl
          );

         --G_previous_route_id := p_route_id;
         --G_previous_req_date := l_requirement_date;

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (fnd_log.level_error >= G_DEBUG_LEVEL) THEN
              fnd_log.string(fnd_log.level_error, l_debug_module,
                             'AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req Threw error');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

--     END IF; -- (NVL(G_previous_route_id,-1)

     IF (l_Route_Mtl_Req_Tbl IS NOT NULL AND l_Route_Mtl_Req_Tbl.COUNT > 0) THEN
        IF (G_DEBUG_STMT >= G_DEBUG_LEVEL) THEN
          fnd_log.string ( G_DEBUG_STMT,l_debug_module,
               'After call AHL_LTP_MTL_REQ_PVT.Get_Route_Mtl_Req API : l_Route_Mtl_Req_Tbl.COUNT : ' ||
                l_Route_Mtl_Req_Tbl.COUNT);
        END IF;

        FOR j IN l_Route_Mtl_Req_Tbl.FIRST..l_Route_Mtl_Req_Tbl.LAST LOOP
            OPEN schedule_mtl_exists_csr(p_unit_effectivity_id,
                                         p_mr_route_id,
                                         l_Route_Mtl_Req_Tbl(j).inventory_item_id,
                                         l_Route_Mtl_Req_Tbl(j).rt_oper_material_id);
            FETCH schedule_mtl_exists_csr INTO l_Schedule_Mtl_Req_rec;
            IF(schedule_mtl_exists_csr%NOTFOUND)THEN
                IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
                   fnd_log.string (G_DEBUG_STMT, l_debug_module,
	             'Inserting record in AHL_SCHEDULE_MATERIALS ');
                   fnd_log.string (G_DEBUG_STMT,l_debug_module,
	             'unit_effectivity_id :  ' || p_unit_effectivity_id);
                   fnd_log.string (G_DEBUG_STMT,l_debug_module,
	             'requested_date :  ' || p_due_date);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'mr_route_id : '|| p_mr_route_id);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'inventory_item_id :  ' || l_Route_Mtl_Req_Tbl(j).inventory_item_id);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'quantity :  ' || l_Route_Mtl_Req_Tbl(j).quantity);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'uom :  ' || l_Route_Mtl_Req_Tbl(j).uom_code);
                END IF;
                AHL_SCHEDULE_MATERIALS_PKG.INSERT_ROW
                (
                    X_SCHEDULED_MATERIAL_ID  => NULL,
                    X_OBJECT_VERSION_NUMBER  => 1,
                    X_LAST_UPDATE_DATE       => SYSDATE,
                    X_LAST_UPDATED_BY        => fnd_global.user_id,
                    X_CREATION_DATE          => SYSDATE,
                    X_CREATED_BY             => fnd_global.user_id,
                    X_LAST_UPDATE_LOGIN      => fnd_global.user_id,
                    X_INVENTORY_ITEM_ID      => l_Route_Mtl_Req_Tbl(j).inventory_item_id,
                    X_SCHEDULE_DESIGNATOR    => NULL,
                    X_VISIT_ID               => NULL,
                    X_VISIT_START_DATE       => NULL,
                    X_VISIT_TASK_ID          => NULL,
                    X_ORGANIZATION_ID        => NULL,
                    X_SCHEDULED_DATE         => NULL,
                    X_REQUEST_ID             => NULL,
                    -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                    X_REQUESTED_DATE         => trunc(p_due_date),
                    X_SCHEDULED_QUANTITY     => NULL,
                    X_PROCESS_STATUS         => NULL,
                    X_ERROR_MESSAGE          => NULL,
                    X_TRANSACTION_ID         => NULL,
                    X_UOM                    => l_Route_Mtl_Req_Tbl(j).uom_code,
                    X_RT_OPER_MATERIAL_ID    => l_Route_Mtl_Req_Tbl(j).rt_oper_material_id,
                    X_OPERATION_CODE         => NULL,
                    X_OPERATION_SEQUENCE     => NULL,
                    X_ITEM_GROUP_ID          => l_Route_Mtl_Req_Tbl(j).item_group_id,
                    X_REQUESTED_QUANTITY     => l_Route_Mtl_Req_Tbl(j).quantity,
                    X_PROGRAM_ID             => NULL,
                    X_PROGRAM_UPDATE_DATE    => NULL,
                    X_LAST_UPDATED_DATE      => NULL,
                    X_WORKORDER_OPERATION_ID => NULL,
                    X_POSITION_PATH_ID       => l_Route_Mtl_Req_Tbl(j).position_path_id,
                    X_RELATIONSHIP_ID        => l_Route_Mtl_Req_Tbl(j).relationship_id,
                    X_UNIT_EFFECTIVITY_ID    => p_unit_effectivity_id,
                    X_MR_ROUTE_ID            => p_mr_route_id,
                    X_MATERIAL_REQUEST_TYPE  => G_REQ_TYPE_FORECAST,
                    X_ATTRIBUTE_CATEGORY     => NULL,
                    X_ATTRIBUTE1             => NULL,
                    X_ATTRIBUTE2             => NULL,
                    X_ATTRIBUTE3             => NULL,
                    X_ATTRIBUTE4             => NULL,
                    X_ATTRIBUTE5             => NULL,
                    X_ATTRIBUTE6             => NULL,
                    X_ATTRIBUTE7             => NULL,
                    X_ATTRIBUTE8             => NULL,
                    X_ATTRIBUTE9             => NULL,
                    X_ATTRIBUTE10            => NULL,
                    X_ATTRIBUTE11            => NULL,
                    X_ATTRIBUTE12            => NULL,
                    X_ATTRIBUTE13            => NULL,
                    X_ATTRIBUTE14            => NULL,
                    X_ATTRIBUTE15            => NULL
                );
            ELSE -- schedule_mtl_exists
                IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
                   fnd_log.string ( G_DEBUG_STMT, l_debug_module,
                                   'Updating record in AHL_SCHEDULE_MATERIALS ');
                   fnd_log.string ( G_DEBUG_STMT, l_debug_module,
	               'unit_effectivity_id :  ' || p_unit_effectivity_id);
                   fnd_log.string ( G_DEBUG_STMT, l_debug_module,
	               'requested_date :  ' || p_due_date);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'mr_route_id : '|| p_mr_route_id);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'inventory_item_id :  ' || l_Route_Mtl_Req_Tbl(j).inventory_item_id);
                   fnd_log.string ( G_DEBUG_STMT,l_debug_module,
	              'quantity :  ' || l_Route_Mtl_Req_Tbl(j).quantity);
                   fnd_log.string ( G_DEBUG_STMT, l_debug_module,
	              'uom :  ' || l_Route_Mtl_Req_Tbl(j).uom_code);
                   fnd_log.string ( G_DEBUG_STMT, l_debug_module,
                                    'SCHEDULED_MATERIAL_ID:' || l_Schedule_Mtl_Req_rec.SCHEDULED_MATERIAL_ID);
                END IF;
                AHL_SCHEDULE_MATERIALS_PKG.UPDATE_ROW
                (
                    X_SCHEDULED_MATERIAL_ID  => l_Schedule_Mtl_Req_rec.SCHEDULED_MATERIAL_ID,
                    X_OBJECT_VERSION_NUMBER  => l_Schedule_Mtl_Req_rec.OBJECT_VERSION_NUMBER,--Update Column
                    X_LAST_UPDATE_DATE       => SYSDATE,
                    X_LAST_UPDATED_BY        => fnd_global.user_id,
                    X_LAST_UPDATE_LOGIN      => fnd_global.user_id,
                    X_INVENTORY_ITEM_ID      => l_Schedule_Mtl_Req_rec.INVENTORY_ITEM_ID,
                    X_SCHEDULE_DESIGNATOR    => l_Schedule_Mtl_Req_rec.SCHEDULE_DESIGNATOR,
                    X_VISIT_ID               => l_Schedule_Mtl_Req_rec.VISIT_ID,
                    X_VISIT_START_DATE       => l_Schedule_Mtl_Req_rec.VISIT_START_DATE,
                    X_VISIT_TASK_ID          => l_Schedule_Mtl_Req_rec.VISIT_TASK_ID,
                    X_ORGANIZATION_ID        => l_Schedule_Mtl_Req_rec.ORGANIZATION_ID,
                    X_SCHEDULED_DATE         => l_Schedule_Mtl_Req_rec.SCHEDULED_DATE,
                    X_REQUEST_ID             => l_Schedule_Mtl_Req_rec.REQUEST_ID,
                    -- AnRaj: truncating Requested Date for Material Requirement based on discussions with PM
                    X_REQUESTED_DATE         => trunc(p_due_date),--Update Column
                    X_SCHEDULED_QUANTITY     => l_Schedule_Mtl_Req_rec.SCHEDULED_QUANTITY,
                    X_PROCESS_STATUS         => l_Schedule_Mtl_Req_rec.PROCESS_STATUS,
                    X_ERROR_MESSAGE          => l_Schedule_Mtl_Req_rec.ERROR_MESSAGE,
                    X_TRANSACTION_ID         => l_Schedule_Mtl_Req_rec.TRANSACTION_ID,
                    X_UOM                    => l_Route_Mtl_Req_Tbl(j).uom_code,--Update Column
                    X_RT_OPER_MATERIAL_ID    => l_Route_Mtl_Req_Tbl(j).rt_oper_material_id,--Update Column
                    X_OPERATION_CODE         => l_Schedule_Mtl_Req_rec.OPERATION_CODE,
                    X_OPERATION_SEQUENCE     => l_Schedule_Mtl_Req_rec.OPERATION_SEQUENCE,
                    X_ITEM_GROUP_ID          => l_Route_Mtl_Req_Tbl(j).item_group_id,--Update Column
                    X_REQUESTED_QUANTITY     => l_Route_Mtl_Req_Tbl(j).quantity,--Update Column
                    X_PROGRAM_ID             => l_Schedule_Mtl_Req_rec.PROGRAM_ID,
                    X_PROGRAM_UPDATE_DATE    => l_Schedule_Mtl_Req_rec.PROGRAM_UPDATE_DATE,
                    X_LAST_UPDATED_DATE      => l_Schedule_Mtl_Req_rec.LAST_UPDATED_DATE,
                    X_WORKORDER_OPERATION_ID => l_Schedule_Mtl_Req_rec.WORKORDER_OPERATION_ID,
                    X_POSITION_PATH_ID       => l_Route_Mtl_Req_Tbl(j).position_path_id,--Update Column
                    X_RELATIONSHIP_ID        => l_Route_Mtl_Req_Tbl(j).relationship_id,--Update Column
                    X_UNIT_EFFECTIVITY_ID    => l_Schedule_Mtl_Req_rec.UNIT_EFFECTIVITY_ID,
                    X_MR_ROUTE_ID            => l_Schedule_Mtl_Req_rec.MR_ROUTE_ID,
                    X_MATERIAL_REQUEST_TYPE  => l_Schedule_Mtl_Req_rec.MATERIAL_REQUEST_TYPE,
                    X_ATTRIBUTE_CATEGORY     => l_Schedule_Mtl_Req_rec.ATTRIBUTE_CATEGORY,
                    X_ATTRIBUTE1             => l_Schedule_Mtl_Req_rec.ATTRIBUTE1,
                    X_ATTRIBUTE2             => l_Schedule_Mtl_Req_rec.ATTRIBUTE2,
                    X_ATTRIBUTE3             => l_Schedule_Mtl_Req_rec.ATTRIBUTE3,
                    X_ATTRIBUTE4             => l_Schedule_Mtl_Req_rec.ATTRIBUTE4,
                    X_ATTRIBUTE5             => l_Schedule_Mtl_Req_rec.ATTRIBUTE5,
                    X_ATTRIBUTE6             => l_Schedule_Mtl_Req_rec.ATTRIBUTE6,
                    X_ATTRIBUTE7             => l_Schedule_Mtl_Req_rec.ATTRIBUTE7,
                    X_ATTRIBUTE8             => l_Schedule_Mtl_Req_rec.ATTRIBUTE8,
                    X_ATTRIBUTE9             => l_Schedule_Mtl_Req_rec.ATTRIBUTE9,
                    X_ATTRIBUTE10            => l_Schedule_Mtl_Req_rec.ATTRIBUTE10,
                    X_ATTRIBUTE11            => l_Schedule_Mtl_Req_rec.ATTRIBUTE11,
                    X_ATTRIBUTE12            => l_Schedule_Mtl_Req_rec.ATTRIBUTE12,
                    X_ATTRIBUTE13            => l_Schedule_Mtl_Req_rec.ATTRIBUTE13,
                    X_ATTRIBUTE14            => l_Schedule_Mtl_Req_rec.ATTRIBUTE14,
                    X_ATTRIBUTE15            => l_Schedule_Mtl_Req_rec.ATTRIBUTE15
                );
            END IF; -- schedule_mtl_exists_csr%NOTFOUND
            CLOSE schedule_mtl_exists_csr;
        END LOOP; -- l_Route_Mtl_Req_Tbl(j)
     END IF; -- l_Route_Mtl_Req_Tbl.COUNT > 0
  END IF; -- NOT(TRUNC(NVL(p_r_start_date_active
END Process_Material_Req;

---------------------------------------------------------------------------
-- To log error messages into a log file if called from concurrent process.

PROCEDURE log_error_messages IS

  l_msg_count      NUMBER;
  l_msg_index_out  NUMBER;
  l_msg_data       VARCHAR2(2000);

BEGIN

  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
      fnd_log.string (G_DEBUG_PROC, 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.log_error_messages',
                      'Start log error messages');
  END IF;

  -- Standard call to get message count.
  l_msg_count := FND_MSG_PUB.Count_Msg;

  FOR i IN 1..l_msg_count LOOP
    FND_MSG_PUB.get (
      p_msg_index      => i,
      p_encoded        => FND_API.G_FALSE,
      p_data           => l_msg_data,
      p_msg_index_out  => l_msg_index_out );

    fnd_file.put_line(FND_FILE.LOG, 'Err message-'||l_msg_index_out||':' || l_msg_data);
    IF (G_DEBUG_STMT >= G_DEBUG_LEVEL)THEN
      fnd_log.string (G_DEBUG_STMT, 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.log_error_messages',
                      'Err message-'||l_msg_index_out||':' || substr(l_msg_data,1,240));
    END IF;

  END LOOP;

  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL)THEN
      fnd_log.string (G_DEBUG_PROC, 'ahl.plsql.AHL_UMP_FORECAST_REQ_PVT.log_error_messages',
                      'End log error messages');
  END IF;

END log_error_messages;

END AHL_UMP_FORECAST_REQ_PVT;

/
