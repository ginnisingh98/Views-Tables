--------------------------------------------------------
--  DDL for Package Body AHL_LTP_MATRL_AVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_MATRL_AVAL_PUB" AS
/* $Header: AHLPMTAB.pls 120.0.12010000.2 2009/04/02 10:35:01 skpathak ship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_MATRL_AVAL_PUB';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
-- PACKAGE
--    AHL_LTP_MATRL_AVAL_PUB
--
-- PURPOSE
--     This Package is a Public API for verifying material availabilty for  an item
--     Calling ATP
--
-- NOTES
--
--
-- HISTORY
-- 23-Apr-2002    ssurapan      Created.

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Check_Material_Aval
--  Type        : Public
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Check_Material_Aval Parameters :
--        p_x_material_avl_tbl      IN  OUT NOCOPY Material_Availability_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Check_Material_Aval (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_material_avl_tbl      IN  OUT NOCOPY Material_Availability_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
 l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_MATERIAL_AVAL';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_commit      VARCHAR2(10)  := FND_API.g_false;
 l_material_avl_tbl   Material_Availability_Tbl := p_x_material_avl_tbl;
BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_REQST_MATRL_PUB.Check_Material_Aval',
			'At the start of PLSQL procedure'
		);
     END IF;
-- dbms_output.put_line( 'start public API:');

  --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT check_material_aval;
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
    IF l_material_avl_tbl.COUNT > 0 THEN
      --
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
    		(
	  		fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Check Material Aval Number of Records : ' || l_material_avl_tbl.COUNT
		    );
		   fnd_log.string
    		(
	  		fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Check Material Aval Schedule material Id : ' || l_material_avl_tbl(1).schedule_material_id
		    );

        END IF;

        AHL_LTP_MATRL_AVAL_PVT.Check_Material_Aval
                    (p_api_version          => p_api_version,
                     p_init_msg_list        => p_init_msg_list,
                     p_commit               => l_commit,
                     p_validation_level     => p_validation_level,
                     p_module_type          => p_module_type,
                     p_x_material_avl_tbl   => l_material_avl_tbl,
                     x_return_status        => l_return_status,
                     x_msg_count            => l_msg_count,
                     x_msg_data             => l_msg_data);
      END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string
		 (
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp matrl aval pvt.Check Material Aval, Return Status : '|| l_return_status
		);
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;
      --Assign derived values
      IF l_material_avl_tbl.COUNT > 0 THEN
      FOR i IN l_material_avl_tbl.FIRST..l_material_avl_tbl.LAST
      LOOP
         p_x_material_avl_tbl(i).visit_task_id       := l_material_avl_tbl(i).visit_task_id;
         p_x_material_avl_tbl(i).task_name           := l_material_avl_tbl(i).task_name;
         p_x_material_avl_tbl(i).inventory_item_id   := l_material_avl_tbl(i).inventory_item_id;
         p_x_material_avl_tbl(i).item                := l_material_avl_tbl(i).item;
         p_x_material_avl_tbl(i).req_arrival_date    := l_material_avl_tbl(i).req_arrival_date;
         p_x_material_avl_tbl(i).uom                 := l_material_avl_tbl(i).uom;
         p_x_material_avl_tbl(i).quantity            := l_material_avl_tbl(i).quantity;
         p_x_material_avl_tbl(i).quantity_available  := l_material_avl_tbl(i).quantity_available;
         p_x_material_avl_tbl(i).schedule_material_id := l_material_avl_tbl(i).schedule_material_id;
         p_x_material_avl_tbl(i).error_code           := l_material_avl_tbl(i).error_code;
         p_x_material_avl_tbl(i).error_message        := 'For Item'||l_material_avl_tbl(i).item||','||l_material_avl_tbl(i).error_message;
         --SKPATHAK :: Bug 8392521 :: 02-APR-2009
         --Make the schedule date returned by the private API, available to the out param of the public API
         p_x_material_avl_tbl(i).scheduled_date       := l_material_avl_tbl(i).scheduled_date;


    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Material_Aval',
			' Derieved Value, Visit Task Id: ' || p_x_material_avl_tbl(i).visit_task_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Material_Aval',
			' Derieved Value, Inventory Item Id: ' || p_x_material_avl_tbl(i).inventory_item_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Material_Aval',
			' Derieved Value, Quantity: ' || p_x_material_avl_tbl(i).quantity
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Material_Aval',
			' Derieved Value, Quantity Available: ' || p_x_material_avl_tbl(i).quantity_available
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Material_Aval',
			' Derieved Value, Error Message: ' || p_x_material_avl_tbl(i).error_message
		);

	  END IF;
      END LOOP;
      END IF;
   ------------------------End of Body---------------------------------------
   --Standard check to count messages
   IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
     END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check Material Aval.end',
			'At the end of PLSQL procedure'
		);
     END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_material_aval;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO check_material_aval;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

WHEN OTHERS THEN
    ROLLBACK TO check_material_aval;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PUB',
                            p_procedure_name  =>  'CHECK_MATERIAL_AVAL',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END Check_Material_Aval;

-- Start of Comments --
--  Procedure name    : Get_Visit_Task_Materials
--  Type        : Public
--  Function    : This procedure derives material information associated to scheduled
--                visit, which are defined at Route Operation level
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Get_Visit_Task_Materials :
--           p_visit_id                 IN   NUMBER,Required
--
PROCEDURE Get_Visit_Task_Materials (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN    NUMBER,
   x_task_req_matrl_tbl      OUT  NOCOPY Task_Req_Matrl_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2)
IS
  --Standard local variables
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Visit_Task_Materials';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  --
  l_task_req_matrl_tbl    Task_Req_Matrl_Tbl;
  --
BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Get_Visit_Task_Materials.begin',
			'At the start of PLSQL procedure'
		);
     END IF;
    -- Standard Start of API savepoint
    SAVEPOINT get_visit_task_materials;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Visit Task Materials for Visit Id : ' || p_visit_id
		);

     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl ltp matrl aval pvt.Get Visit Task Materials'
   		  );

     END IF;

     IF p_visit_id IS NOT NULL AND p_visit_id <> FND_API.G_MISS_NUM
     THEN

      AHL_LTP_MATRL_AVAL_PVT.Get_Visit_Task_Materials
                 (p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  p_validation_level    => p_validation_level,
                  p_visit_id            => p_visit_id,
                  x_task_req_matrl_tbl  => l_task_req_matrl_tbl,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data);

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp matrl aval pvt.Get Visit Task Materials, Return Status : '|| l_return_status
		);
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

    IF l_task_req_matrl_tbl.COUNT > 0 THEN
      FOR i IN l_task_req_matrl_tbl.FIRST..l_task_req_matrl_tbl.LAST
      LOOP
          x_task_req_matrl_tbl(i).schedule_material_id  := l_task_req_matrl_tbl(i).schedule_material_id;
          x_task_req_matrl_tbl(i).object_version_number  := l_task_req_matrl_tbl(i).object_version_number;
          x_task_req_matrl_tbl(i).visit_task_id      := l_task_req_matrl_tbl(i).visit_task_id;
          x_task_req_matrl_tbl(i).task_name          := l_task_req_matrl_tbl(i).task_name;
			 -- anraj : added columns TASK_STATUS_CODE and TASK_STATUS_MEANING , for Material Availabilty UI
          x_task_req_matrl_tbl(i).task_status_code   := l_task_req_matrl_tbl(i).task_status_code;
			 x_task_req_matrl_tbl(i).task_status_meaning:= l_task_req_matrl_tbl(i).task_status_meaning;
			 x_task_req_matrl_tbl(i).inventory_item_id  := l_task_req_matrl_tbl(i).inventory_item_id;
          x_task_req_matrl_tbl(i).item               := l_task_req_matrl_tbl(i).item;
          x_task_req_matrl_tbl(i).req_arrival_date   := l_task_req_matrl_tbl(i).req_arrival_date;
          x_task_req_matrl_tbl(i).uom_code           := l_task_req_matrl_tbl(i).uom_code;
          x_task_req_matrl_tbl(i).quantity           := l_task_req_matrl_tbl(i).quantity;
          x_task_req_matrl_tbl(i).scheduled_date     := l_task_req_matrl_tbl(i).scheduled_date;
          x_task_req_matrl_tbl(i).planned_order      := l_task_req_matrl_tbl(i).planned_order;
        --
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Schedule Material Id : '||x_task_req_matrl_tbl(i).schedule_material_id
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Object Version Number : '||x_task_req_matrl_tbl(i).object_version_number
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Visit Task Id : '||x_task_req_matrl_tbl(i).visit_task_id
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Visit Task Name : '||x_task_req_matrl_tbl(i).task_name
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Inventory Item Id : '||x_task_req_matrl_tbl(i).inventory_item_id
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Item Description : '||x_task_req_matrl_tbl(i).item
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Requested Date : '||x_task_req_matrl_tbl(i).req_arrival_date
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'UOM : '||x_task_req_matrl_tbl(i).uom_code
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Requested Quantity : '||x_task_req_matrl_tbl(i).quantity
         );
         fnd_log.string
	     (
		     fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		     'Planned Order Id : '||x_task_req_matrl_tbl(i).planned_order
         );

     END IF;

     END LOOP;
     END IF;
   END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

    --Standard check for commit
    IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
       COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Get_Visit_Task_Materials.end',
			'At the end of PLSQL procedure'
		);
     END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO get_visit_task_materials;
        X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                   p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO get_visit_task_materials;
       X_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => X_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO get_visit_task_materials;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PUB',
                              p_procedure_name  =>  'GET_VISIT_TASK_MATERIALS',
                              p_error_text      => SUBSTR(SQLERRM,1,240));
      END IF;
      FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                 p_count => x_msg_count,
                                 p_data  => X_msg_data);
 END Get_Visit_Task_Materials;

-- Start of Comments --
--  Procedure name    : Check_Materials_For_All
--  Type        : Public
--  Function    : This procedure calls ATP to check inventory item is available
--                for Routine jobs associated to a visit
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Check_Materials_For_All Parameters :
--        p_visit_id              IN   NUMBER, Required
--         List of item attributes associated to visit task
--
PROCEDURE Check_Materials_For_All (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN   NUMBER,
   x_task_matrl_aval_tbl     OUT  NOCOPY Material_Availability_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2

)IS

	-- anraj added for checking whether atleast one task is in status planning
	CURSOR c_any_task_in_planning (c_visit_id IN NUMBER)
	IS
		SELECT 1
		FROM AHL_VISIT_TASKS_B
		WHERE visit_id = c_visit_id
		AND status_code = 'PLANNING';

	l_dummy number;

 l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_MATERIALS_FOR_ALL';
 l_api_version     CONSTANT NUMBER       := 1.0;
 l_msg_count                NUMBER;
 l_return_status            VARCHAR2(1);
 l_mat_return_status        VARCHAR2(1);
 l_msg_data                 VARCHAR2(2000);
 l_task_req_matrl_tbl    Task_Req_Matrl_Tbl;
 l_material_avl_tbl     Material_Availability_Tbl;
--
J  NUMBER;
BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_REQST_MATRL_PUB.Check_Materials_For_All',
			'At the start of PLSQL procedure'
		);
     END IF;

  --------------------Initialize ----------------------------------
   -- Standard Start of API savepoint
   SAVEPOINT check_materials_for_all;
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
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	   fnd_log.string
   		(
  		fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
		'Request for Check Material For Visit Id : ' || p_visit_id
	    );

   END IF;

   IF p_visit_id IS NOT NULL AND p_visit_id <> FND_API.G_MISS_NUM
   THEN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl ltp matrl aval pvt.Get Visit Task Materials'
   		  );

     END IF;

	--anraj, validation to check whether atleast one task is in planning
	OPEN c_any_task_in_planning(p_visit_id);
	FETCH c_any_task_in_planning INTO l_dummy;
	IF c_any_task_in_planning%NOTFOUND THEN
		Fnd_Message.SET_NAME('AHL','AHL_LTP_CHK_AVL_ALL_NONE_PLAN');
		Fnd_Msg_Pub.ADD;
		CLOSE c_any_task_in_planning;
		RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   CLOSE c_any_task_in_planning;


    AHL_LTP_MATRL_AVAL_PVT.Get_Visit_Task_Materials
                ( p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  p_validation_level    => p_validation_level,
                  p_visit_id            => p_visit_id,
                  x_task_req_matrl_tbl  => l_task_req_matrl_tbl,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data);
      --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string
		 (
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp Matrl Aval pvt.Get Visit Task Materials, Return Status : '|| l_return_status
		);
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' After Calling Get Visit Task Materials, Number of Records: ' || l_task_req_matrl_tbl.COUNT
		);
    END IF;

     IF l_task_req_matrl_tbl.COUNT > 0 THEN
        j := 1;
        FOR i IN l_task_req_matrl_tbl.FIRST..l_task_req_matrl_tbl.LAST
           LOOP
              l_material_avl_tbl(j).inventory_item_id := l_task_req_matrl_tbl(i).inventory_item_id;
              l_material_avl_tbl(j).item := l_task_req_matrl_tbl(i).item;
              l_material_avl_tbl(j).visit_task_id := l_task_req_matrl_tbl(i).visit_task_id;
				  -- anraj : this line of code was missing and coz of this "For Task" was null after "Check Avail For All"
				  l_material_avl_tbl(j).task_name := l_task_req_matrl_tbl(i).task_name;
				  -- anraj : added the following two lines for task_status_code and task_status_meaning
				  l_material_avl_tbl(j).task_status_code := l_task_req_matrl_tbl(i).task_status_code;
				  l_material_avl_tbl(j).task_status_meaning := l_task_req_matrl_tbl(i).task_status_meaning;

              l_material_avl_tbl(j).req_arrival_date := l_task_req_matrl_tbl(i).req_arrival_date;
              l_material_avl_tbl(j).uom := l_task_req_matrl_tbl(i).uom_code;
              l_material_avl_tbl(j).quantity := l_task_req_matrl_tbl(i).quantity;
              l_material_avl_tbl(j).visit_id := p_visit_id;
              l_material_avl_tbl(j).schedule_material_id := l_task_req_matrl_tbl(i).schedule_material_id;
               j := j + 1;
               --
        END LOOP;
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' Before Calling Ahl ltp Matrl aval pvt Check Material Aval, Number of Records: ' || l_material_avl_tbl.COUNT
		);
    END IF;
       --Call check material
       AHL_LTP_MATRL_AVAL_PVT.Check_Material_Aval
                    (
                     p_api_version          => p_api_version,
                     p_init_msg_list        => p_init_msg_list,
                     p_commit               => p_commit,
                     p_validation_level     => p_validation_level,
                     p_module_type          => p_module_type,
                     p_x_material_avl_tbl   => l_material_avl_tbl,
                     x_return_status        => l_return_status,
                     x_msg_count            => l_msg_count,
                     x_msg_data             => l_msg_data );
      END IF;
      --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string
		 (
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp Matrl Aval pvt.Check Material Aval, Return Status : '|| l_return_status
		);
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' Before Assigning , Number of Records: ' || l_material_avl_tbl.COUNT
		);
    END IF;

     IF l_material_avl_tbl.COUNT > 0 THEN
      FOR i IN l_material_avl_tbl.FIRST..l_material_avl_tbl.LAST
      LOOP
          x_task_matrl_aval_tbl(i).visit_task_id       := l_material_avl_tbl(i).visit_task_id;
          x_task_matrl_aval_tbl(i).task_name           := l_material_avl_tbl(i).task_name;
			 -- added these two lines of code for the material availability UI
			 x_task_matrl_aval_tbl(i).task_status_code    := l_material_avl_tbl(i).task_status_code;
			 x_task_matrl_aval_tbl(i).task_status_meaning    := l_material_avl_tbl(i).task_status_meaning;

          x_task_matrl_aval_tbl(i).inventory_item_id   := l_material_avl_tbl(i).inventory_item_id;
          x_task_matrl_aval_tbl(i).item                := l_material_avl_tbl(i).item;
          x_task_matrl_aval_tbl(i).req_arrival_date    := l_material_avl_tbl(i).req_arrival_date;
          x_task_matrl_aval_tbl(i).uom                 := l_material_avl_tbl(i).uom;
          x_task_matrl_aval_tbl(i).quantity            := l_material_avl_tbl(i).quantity;
          x_task_matrl_aval_tbl(i).quantity_available  := l_material_avl_tbl(i).quantity_available;
          x_task_matrl_aval_tbl(i).schedule_material_id:= l_material_avl_tbl(i).schedule_material_id;
          x_task_matrl_aval_tbl(i).error_code          := l_material_avl_tbl(i).error_code;
          x_task_matrl_aval_tbl(i).error_message       := l_material_avl_tbl(i).item||' '||l_material_avl_tbl(i).error_message;
          --SKPATHAK :: Bug 8392521 :: 02-APR-2009
          --Make the schedule date returned by the private API, available to the out param of the public API
          x_task_matrl_aval_tbl(i).scheduled_date      := l_material_avl_tbl(i).scheduled_date;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' Derieved Value, Visit Task Id: ' || x_task_matrl_aval_tbl(i).visit_task_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' Derieved Value, Inventory Item Id: ' || x_task_matrl_aval_tbl(i).inventory_item_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' Derieved Value, Quantity: ' || x_task_matrl_aval_tbl(i).quantity
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			' Derieved Value, Quantity Available: ' || x_task_matrl_aval_tbl(i).quantity_available
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check_Materials_For_All',
			'at last x_task_matrl_aval_tbl(i).scheduled_date ' || x_task_matrl_aval_tbl(i).scheduled_date
		);

      END IF;

      END LOOP;
    END IF;
  END IF;

   ------------------------End of Body---------------------------------------
     --Standard check to count messages
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Check Materials For All.end',
			'At the end of PLSQL procedure'
		);
     END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO check_materials_for_all;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO check_materials_for_all;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

WHEN OTHERS THEN
    ROLLBACK TO check_materials_for_all;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PUB',
                            p_procedure_name  =>  'CHECK_MATERIALS_FOR_ALL',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END Check_Materials_For_All;
--
-- Start of Comments --
--  Procedure name    : Schedule_Planned_Mtrls
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Schedule_Planned_Matrls Parameters :
--        p_x_planned_matrls_tbl      IN  OUT NOCOPY Planned_Matrls_Tbl,Required
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_Planned_Matrls (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_x_planned_matrl_tbl     IN  OUT NOCOPY Planned_Matrl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2)

  IS
   --Standard local variables
   l_api_name        CONSTANT VARCHAR2(30) := 'Schedule_Planned_Matrls';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_msg_count                NUMBER;
   l_return_status            VARCHAR2(1);
   l_mat_return_status        VARCHAR2(1);
   l_msg_data                 VARCHAR2(2000);
   l_commit         VARCHAR2(10)  := FND_API.g_false;
   --
   l_planned_matrl_tbl     Planned_Matrl_Tbl := p_x_planned_matrl_tbl;

 BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule_Planned_Matrls.begin',
			'At the start of PLSQL procedure'
		);
     END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Schedule_Planned_Matrls;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Schedule Planned Materials for Number of Records : ' || P_x_Planned_Matrl_Tbl.COUNT
		);

     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl ltp matrl aval pvt.Schedule Planned Matrls'
   		  );

     END IF;

	-- Private Api to Process
    AHL_LTP_MATRL_AVAL_PVT.Schedule_Planned_Matrls
           (p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            p_commit              => l_commit,
            p_validation_level    => p_validation_level,
            p_x_planned_matrl_tbl => l_Planned_Matrl_Tbl,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp matrl aval pvt.Schedule Planned Matrls, Return Status : '|| l_return_status
		);
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;
    IF l_planned_matrl_tbl.COUNT > 0 THEN
	 FOR i IN l_planned_matrl_tbl.FIRST..l_planned_matrl_tbl.LAST
	 LOOP
       --Assign
	   p_x_planned_matrl_tbl(i).schedule_material_id := l_planned_matrl_tbl(i).schedule_material_id;
	   p_x_planned_matrl_tbl(i).quantity_available   := l_planned_matrl_tbl(i).quantity_available;
	   p_x_planned_matrl_tbl(i).object_version_number := l_planned_matrl_tbl(i).object_version_number;
       p_x_planned_matrl_tbl(i).inventory_item_id     := l_planned_matrl_tbl(i).inventory_item_id;
       p_x_planned_matrl_tbl(i).item_description      := l_planned_matrl_tbl(i).item_description;
       p_x_planned_matrl_tbl(i).visit_id              := l_planned_matrl_tbl(i).visit_id;
       p_x_planned_matrl_tbl(i).visit_task_id         := l_planned_matrl_tbl(i).visit_task_id;
       p_x_planned_matrl_tbl(i).task_name             := l_planned_matrl_tbl(i).task_name;
       --SKPATHAK :: Bug 8392521 :: 02-APR-2009
       --Make the schedule date returned by the private API, available to the out param of the public API
       p_x_planned_matrl_tbl(i).scheduled_date        := l_planned_matrl_tbl(i).scheduled_date;
       p_x_planned_matrl_tbl(i).requested_date        := l_planned_matrl_tbl(i).requested_date;
       p_x_planned_matrl_tbl(i).required_quantity     := l_planned_matrl_tbl(i).required_quantity;
--       p_x_planned_matrl_tbl(i).scheduled_quantity    := l_planned_matrl_tbl(i).scheduled_quantity;
       p_x_planned_matrl_tbl(i).primary_uom           := l_planned_matrl_tbl(i).primary_uom;
       p_x_planned_matrl_tbl(i).error_code            := l_planned_matrl_tbl(i).error_code;
       p_x_planned_matrl_tbl(i).error_message         := l_planned_matrl_tbl(i).error_message;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule Planned Matrls',
			' Derieved Value, Schedule Material Id: ' || p_x_planned_matrl_tbl(i).schedule_material_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule Planned Matrls',
			' Derieved Value, Available Quantity: ' || p_x_planned_matrl_tbl(i).quantity_available
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule Planned Matrls',
			'p_x_planned_matrl_tbl(i).scheduled_date: ' || p_x_planned_matrl_tbl(i).scheduled_date
		);

     END IF;

	 END LOOP;
    END IF;
    --Standard check for commit
    IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
       COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule_Planned_Matrls.end',
			'At the end of PLSQL procedure'
		);
     END IF;

 EXCEPTION

	 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO Schedule_Planned_Matrls;
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
	                               p_count => x_msg_count,
	                               p_data  => x_msg_data);

	WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO Schedule_Planned_Matrls;
	    X_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
	                               p_count => x_msg_count,
	                               p_data  => X_msg_data);

	WHEN OTHERS THEN
	    ROLLBACK TO Schedule_Planned_Matrls;
	    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PUB',
	                            p_procedure_name  =>  'SCHEDULE_PLANNED_MATRLS',
	                            p_error_text      => SUBSTR(SQLERRM,1,240));
	    END IF;
	    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
	                               p_count => x_msg_count,
	                               p_data  => X_msg_data);

  END Schedule_Planned_Matrls;

-- Start of Comments --
--  Procedure name    : Schedule_All_Materials
--  Type        : Public
--  Function    : This procedure calls ATP to schedule planned materials
--                for Routine jobs derived requested quantity and task start date
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Schedule_All_Materials Parameters :
--          p_visit_id               IN       NUMBER       Required,
--         List of item attributes associated to visit task
--
PROCEDURE Schedule_All_Materials (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2  := FND_API.g_false,
   p_validation_level        IN      NUMBER    := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2  := 'JSP',
   p_visit_id                IN      NUMBER,
   x_planned_matrl_tbl           OUT NOCOPY Planned_Matrl_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2)

  IS

		-- anraj added for checking whether atleast one task is in status planning
	CURSOR c_any_task_in_planning (c_visit_id IN NUMBER)
	IS
		SELECT 1
		FROM AHL_VISIT_TASKS_B
		WHERE visit_id = c_visit_id
		AND status_code = 'PLANNING';
	l_dummy number;
   --Standard local variables
   l_api_name        CONSTANT VARCHAR2(30) := 'Schedule_All_Materials';
   l_api_version     CONSTANT NUMBER       := 1.0;
   l_msg_count                NUMBER;
   l_return_status            VARCHAR2(1);
   l_msg_data                 VARCHAR2(2000);
   l_commit         VARCHAR2(10)  := FND_API.g_false;
   l_planned_matrl_tbl     Planned_Matrl_Tbl;

  BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule_All_Materials.begin',
			'At the start of PLSQL procedure'
		);
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Schedule_All_Materials;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                        p_api_version,
                                        l_api_name,G_PKG_NAME)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Schedule All Materials for Visit Id : ' || P_visit_id
		);

     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string
		  (
		   fnd_log.level_procedure,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
    	        'Before calling ahl ltp matrl aval pvt.Schedule All Materials'
   		  );

     END IF;

	--anraj, validation to check whether atleast one task is in planning
	OPEN c_any_task_in_planning(p_visit_id);
	FETCH c_any_task_in_planning INTO l_dummy;
	IF c_any_task_in_planning%NOTFOUND THEN
		Fnd_Message.SET_NAME('AHL','AHL_LTP_SCHEDULE_ALL_NONE_PLAN');
		Fnd_Msg_Pub.ADD;
		CLOSE c_any_task_in_planning;
		RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   CLOSE c_any_task_in_planning;



     -- Private Api to Process
     AHL_LTP_MATRL_AVAL_PVT.Schedule_All_Materials
              (p_api_version         => p_api_version,
               p_init_msg_list       => p_init_msg_list,
               p_commit              => l_commit,
               p_validation_level    => p_validation_level,
               p_visit_id            => p_visit_id,
               x_planned_matrl_tbl   => l_Planned_Matrl_Tbl,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data);

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string
		(
		  fnd_log.level_procedure,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||': End API',
	        'After calling ahl ltp matrl aval pvt.Schedule All Materials, Return Status : '|| l_return_status
		);
    END IF;

    -- Check Error Message stack.
     IF (l_return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
       END IF;

    IF l_Planned_Matrl_Tbl.COUNT > 0 THEN
	 FOR i IN l_Planned_Matrl_Tbl.FIRST..l_Planned_Matrl_Tbl.LAST
	 LOOP
       --Assign
	   X_Planned_Matrl_Tbl(i).schedule_material_id := l_Planned_Matrl_Tbl(i).schedule_material_id;
	   X_Planned_Matrl_Tbl(i).quantity_available   := l_Planned_Matrl_Tbl(i).quantity_available;
	   X_Planned_Matrl_Tbl(i).object_version_number := l_Planned_Matrl_Tbl(i).object_version_number;
       X_Planned_Matrl_Tbl(i).inventory_item_id     := l_Planned_Matrl_Tbl(i).inventory_item_id;
       X_Planned_Matrl_Tbl(i).item_description      := l_Planned_Matrl_Tbl(i).item_description;
       X_Planned_Matrl_Tbl(i).visit_id              := l_Planned_Matrl_Tbl(i).visit_id;
       X_Planned_Matrl_Tbl(i).visit_task_id         := l_Planned_Matrl_Tbl(i).visit_task_id;
       X_Planned_Matrl_Tbl(i).task_name             := l_Planned_Matrl_Tbl(i).task_name;
		 -- anraj added fot the Material Availability UI
		 X_Planned_Matrl_Tbl(i).task_status_code      := l_Planned_Matrl_Tbl(i).task_status_code;
       X_Planned_Matrl_Tbl(i).task_status_meaning   := l_Planned_Matrl_Tbl(i).task_status_meaning;

       --SKPATHAK :: Bug 8392521 :: 02-APR-2009
       --Make the schedule date returned by the private API, available to the out param of the public API
       X_Planned_Matrl_Tbl(i).scheduled_date        := l_Planned_Matrl_Tbl(i).scheduled_date;
       X_Planned_Matrl_Tbl(i).requested_date        := l_Planned_Matrl_Tbl(i).requested_date;
       X_Planned_Matrl_Tbl(i).required_quantity     := l_Planned_Matrl_Tbl(i).required_quantity;
--       X_Planned_Matrl_Tbl(i).scheduled_quantity    := l_Planned_Matrl_Tbl(i).scheduled_quantity;
       X_Planned_Matrl_Tbl(i).primary_uom           := l_Planned_Matrl_Tbl(i).primary_uom;
       X_Planned_Matrl_Tbl(i).error_code            := l_Planned_Matrl_Tbl(i).error_code;
       X_Planned_Matrl_Tbl(i).error_message         := l_Planned_Matrl_Tbl(i).error_message;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule Planned Matrls',
			' Derieved Value, Schedule Material Id: ' || X_Planned_Matrl_Tbl(i).schedule_material_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule Planned Matrls',
			' Derieved Value, Available Quantity: ' || X_Planned_Matrl_Tbl(i).quantity_available
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule Planned Matrls',
			'X_Planned_Matrl_Tbl(i).scheduled_date: ' ||X_Planned_Matrl_Tbl(i).scheduled_date
		);

     END IF;

	 END LOOP;
    END IF;

    --Standard check for commit
    IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
       COMMIT;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_MATRL_AVAL_PUB.Schedule_All_Materials.end',
			'At the end of PLSQL procedure'
		);
     END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Schedule_All_Materials;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Schedule_All_Materials;
         X_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                    p_count => x_msg_count,
                                    p_data  => X_msg_data);

    WHEN OTHERS THEN
         ROLLBACK TO Schedule_All_Materials;
         X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
          fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_MATRL_AVAL_PUB',
                                  p_procedure_name  =>  'SCHEDULE_ALL_MATERIALS',
                                  p_error_text      => SUBSTR(SQLERRM,1,240));
         END IF;
         FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                    p_count => x_msg_count,
                                    p_data  => X_msg_data);

  END Schedule_All_Materials;

--
END AHL_LTP_MATRL_AVAL_PUB;

/
