--------------------------------------------------------
--  DDL for Package Body AHL_LTP_RESRC_LEVL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_RESRC_LEVL_PUB" AS
/* $Header: AHLPRLGB.pls 115.14 2003/09/09 06:05:19 rroy noship $ */
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_RESRC_LEVL_PUB';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-----------------------------------------------------------
-- PACKAGE
--    AHL_LTP_RESRC_LEVL_PUB
--
-- PURPOSE
--
-- NOTES
--
--
-- HISTORY
-- 23-May-2002    ssurapan      Created.

--------------------------------------------------------------------
-- PROCEDURE
--   Derive_Resource_Capacity
--
-- PURPOSE
--    Derive Required Resources Capacity
--
-- PARAMETERS
--    p_req_resources_rec       : Record Representing Required Resources
--    x_aval_resources_tbl     : Table Representing Available Resources Table
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Derive_Resource_Capacity (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_req_resources           IN  Req_Resources_Rec,
   x_aval_resources_tbl          OUT NOCOPY Aval_Resources_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
 IS
 --
 l_api_name        CONSTANT VARCHAR2(30) := 'DERIVE_RESOURCE_CAPACITY';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_aval_resources_tbl       AHL_LTP_RESRC_LEVL_PUB.Aval_Resources_Tbl;
 l_period_Rsrc_Req_Tbl      AHL_LTP_RESRC_LEVL_PVT.Period_Rsrc_Req_Tbl_Type;
 l_department_id            NUMBER := null;
BEGIN

  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT derive_resource_capacity;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_resrc_levl_pub. derive resource capacity','+RESLG+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------
/*
    IF (p_x_req_resources.org_name IS NOT NULL AND
        p_x_req_resources.org_name <> FND_API.G_MISS_CHAR) THEN
       --
       IF (p_x_req_resources.dept_name IS NOT NULL AND
           p_x_req_resources.dept_name <> FND_API.G_MISS_CHAR) THEN
       --
       SELECT department_id INTO l_department_id
         FROM BOM_DEPARTMENTS A, HR_ALL_ORGANIZATION_UNITS B
       WHERE A.ORGANIZATION_ID = B.ORGANIZATION_ID
        AND  B.NAME = p_x_req_resources.org_name
        AND  A.description = p_x_req_resources.dept_name;
       --
        IF l_department_id IS NULL THEN
         Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INVALID');
         Fnd_Msg_Pub.ADD;
         RAISE  Fnd_Api.G_EXC_ERROR;
        END IF;
       ELSE
         Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_NULL');
         Fnd_Msg_Pub.ADD;
         RAISE  Fnd_Api.G_EXC_ERROR;
       END IF;
      --
  */
      AHL_LTP_RESRC_LEVL_PVT.Get_Rsrc_Req_By_Period
                   (
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    p_commit         => p_commit,
                    p_validation_level  => p_validation_level,
                    p_default           => null,
                    p_module_type       => p_module_type,
                    p_dept_id           => p_req_resources.dept_id,
                    p_dept_name         => p_req_resources.dept_name,
                    p_org_name          => p_req_resources.org_name,
                    p_plan_id           => p_req_resources.plan_id,
                    p_start_time        => p_req_resources.start_date,
                    p_end_time          => p_req_resources.end_date,
                    p_uom_code          => p_req_resources.uom_code,
                    p_required_capacity => p_req_resources.required_capacity,
                    x_per_rsrc_tbl      => l_period_Rsrc_Req_Tbl,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data);

--     END IF;
     --
          IF l_return_status = 'S' THEN
            IF  l_period_Rsrc_Req_Tbl.COUNT > 0 THEN
               FOR i IN l_period_Rsrc_Req_Tbl.FIRST..l_period_Rsrc_Req_Tbl.LAST
                 LOOP
                 x_aval_resources_tbl(i).period_string           := l_period_Rsrc_Req_Tbl(i).period_string;
                 x_aval_resources_tbl(i).required_capacity       := l_period_Rsrc_Req_Tbl(i).capacity_units;
                 x_aval_resources_tbl(i).dept_name               := l_period_Rsrc_Req_Tbl(i).dept_description;
                 x_aval_resources_tbl(i).period_start            := l_period_Rsrc_Req_Tbl(i).period_start;
                 x_aval_resources_tbl(i).period_end              := l_period_Rsrc_Req_Tbl(i).period_end;
                 x_aval_resources_tbl(i).resource_type_meaning   := l_period_Rsrc_Req_Tbl(i).resource_type_meaning;
                 x_aval_resources_tbl(i).resource_name           := l_period_Rsrc_Req_Tbl(i).resource_name;
                 x_aval_resources_tbl(i).resource_id             := l_period_Rsrc_Req_Tbl(i).resource_id;
   IF G_DEBUG='Y' THEN
   --
   AHL_DEBUG_PUB.debug( 'END PUB SDATE:'||x_aval_resources_tbl(i).period_start);
   AHL_DEBUG_PUB.debug( 'END PUB EDATE:'||x_aval_resources_tbl(i).period_end);
   AHL_DEBUG_PUB.debug( 'END PUB period string:'||x_aval_resources_tbl(i).period_string);
   AHL_DEBUG_PUB.debug( 'END PUB RID:'||x_aval_resources_tbl(i).resource_id);
   --
   END IF;
                 END LOOP;
             END IF;
          END IF;

   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Derive Resource Capacity','+RSRLG+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO derive_resource_capacity;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_resrc_levl_pub. Derive Resource Capacity','+RSRLG+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO derive_resource_capacity;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_resrc_levl_pub. Derive Resource Capacity','+RSRLG+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO derive_resource_capacity;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_RESRC_LEVL_PUB',
                            p_procedure_name  =>  'DERIVE_RESOURCE_CAPACITY',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_resrc_levl_pub. Derive Resource Capacity','+RSRLG+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

END Derive_Resource_Capacity;

--------------------------------------------------------------------
-- PROCEDURE
--   Derive_Resource_Consum
--
-- PURPOSE
--    Derive Resource Consum
--
-- PARAMETERS
--    p_req_resources         : Record Representing Resource Consumption For
--    x_resource_con_tbl      : Table Representing Resource Consumption Table
--
-- NOTES
--------------------------------------------------------------------
PROCEDURE Derive_Resource_Consum (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_req_resources           IN  Req_Resources_Rec,
   x_resource_con_tbl            OUT NOCOPY Resource_Con_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'DERIVE_RESOURCE_CONSUM';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_task_req_tbl             AHL_LTP_RESRC_LEVL_PVT.Task_Requirement_Tbl_Type;
 l_resource_con_tbl         AHL_LTP_RESRC_LEVL_PUB.Resource_Con_Tbl;
 l_department_id            NUMBER;
 BEGIN

  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT derive_resource_consum;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_resrc_levl_pub. derive resource consum','+RESLG+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --------------------Start of API Body-----------------------------------

    IF (p_req_resources.org_name IS NOT NULL AND
        p_req_resources.org_name <> FND_API.G_MISS_CHAR) THEN
       --
       IF (p_req_resources.dept_name IS NOT NULL AND
           p_req_resources.dept_name <> FND_API.G_MISS_CHAR) THEN
       --
       SELECT department_id INTO l_department_id
         FROM BOM_DEPARTMENTS A, HR_ALL_ORGANIZATION_UNITS B
       WHERE A.ORGANIZATION_ID = B.ORGANIZATION_ID
        AND  B.NAME = p_req_resources.org_name
        AND  A.description = p_req_resources.dept_name;
       --
        IF l_department_id IS NULL THEN
         Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INVALID');
         Fnd_Msg_Pub.ADD;
         RAISE  Fnd_Api.G_EXC_ERROR;
        END IF;
       ELSE
         Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_ID_NOT_EXIST');
         Fnd_Msg_Pub.ADD;
         RAISE  Fnd_Api.G_EXC_ERROR;
       END IF;
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'before public CallRID:'||p_req_resources.resource_id);
   AHL_DEBUG_PUB.debug( 'before public CallRTY:'||p_req_resources.resource_type_meaning);
   AHL_DEBUG_PUB.debug( 'before public CallDID:'||p_req_resources.dept_id);
   AHL_DEBUG_PUB.debug( 'before public CallDNAME:'||p_req_resources.dept_name);
   AHL_DEBUG_PUB.debug( 'before public CallDSTART:'||p_req_resources.display_start_date);
   AHL_DEBUG_PUB.debug( 'before public CallDENDD:'||p_req_resources.display_end_date);
   AHL_DEBUG_PUB.debug( 'before public CallSTART:'||p_req_resources.start_date);
   AHL_DEBUG_PUB.debug( 'before public CallENDD:'||p_req_resources.end_date);
   END IF;
      AHL_LTP_RESRC_LEVL_PVT.Get_Task_Requirements
                   (
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    p_commit         => p_commit,
                    p_validation_level  => p_validation_level,
                    p_default           => null,
                    p_module_type       => p_module_type,
                    p_dept_id           => l_department_id, --p_req_resources.dept_id,
                    p_dept_name         => p_req_resources.dept_name,
                    p_org_name          => p_req_resources.org_name,
                    p_plan_id           => p_req_resources.plan_id,
                    p_start_time        => trunc(p_req_resources.start_date),
                    p_end_time          => trunc(p_req_resources.end_date),
                    p_dstart_time       => trunc(p_req_resources.display_start_date),
                    p_dend_time         => trunc(p_req_resources.display_end_date),
				    p_resource_id       => p_req_resources.resource_id,
                    p_aso_bom_rsrc_type => p_req_resources.resource_type_meaning,
                    x_task_req_tbl      => l_task_req_tbl,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data);
    END IF;

          IF l_return_status = 'S' THEN
            IF  l_task_req_tbl.COUNT > 0 THEN
               FOR i IN l_task_req_tbl.FIRST..l_task_req_tbl.LAST
                 LOOP
                 x_resource_con_tbl(i).visit_id        := l_task_req_tbl(i).visit_id;
                 x_resource_con_tbl(i).task_id         := l_task_req_tbl(i).task_id;
                 x_resource_con_tbl(i).visit_name      := l_task_req_tbl(i).visit_name;
                 x_resource_con_tbl(i).visit_task_name := l_task_req_tbl(i).visit_task_name;
                 x_resource_con_tbl(i).task_type_code  := l_task_req_tbl(i).task_type_code;
                 x_resource_con_tbl(i).dept_name       := l_task_req_tbl(i).dept_name;
                 x_resource_con_tbl(i).quantity        := l_task_req_tbl(i).required_units;
                 x_resource_con_tbl(i).available_units := l_task_req_tbl(i).available_units;
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'End of public VID:'||x_resource_con_tbl(i).visit_id);
   AHL_DEBUG_PUB.debug( 'End of public TID:'||x_resource_con_tbl(i).task_id);
   AHL_DEBUG_PUB.debug( 'End of public VTNA:'||x_resource_con_tbl(i).visit_task_name);
   AHL_DEBUG_PUB.debug( 'End of public VNAM:'||x_resource_con_tbl(i).visit_name);
   AHL_DEBUG_PUB.debug( 'End of public RQTY:'||x_resource_con_tbl(i).required_units);
   AHL_DEBUG_PUB.debug( 'End of public AQTY:'||x_resource_con_tbl(i).available_units);
   END IF;

                 END LOOP;
             END IF;
          END IF;


   ------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of public api Derive Resource Consum','+RSRLG+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO derive_resource_consum;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_resrc_levl_pub. Derive Resource Consum','+RSRLG+');
        -- Check if API is called in debug mode. If yes, disable debug.
         AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO derive_resource_consum;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_resrc_levl_pub. Derive Resource Consum','+RSRLG+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN OTHERS THEN
    ROLLBACK TO derive_resource_consum;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_RESRC_LEVL_PUB',
                            p_procedure_name  =>  'DERIVE_RESOURCE_CAPACITY',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_resrc_levl_pub. Derive Resource Consum','+RSRLG+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

END Derive_Resource_Consum;
--
END AHL_LTP_RESRC_LEVL_PUB;

/
