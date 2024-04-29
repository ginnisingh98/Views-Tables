--------------------------------------------------------
--  DDL for Package Body AHL_VWP_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_COST_PVT" AS
/* $Header: AHLVCSTB.pls 120.6 2007/11/13 00:24:03 rbhavsar ship $ */
-----------------------------------------------------------------------
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> Visit or MR or Tasks COSTING
--    which involves integration of Complex Maintainance, Repair
--    and Overhauling (CMRO) with COST MANAGEMENT related
--    procedures in Complex Maintainance, Repair and Overhauling(CMRO)
--
--
--      Calculate_Visit_Cost           --      Calculate_MR_Cost
--      Calculate_Task_Cost            --      Get_WO_Cost
--      Push_MR_Cost_Hierarchy         --      Rollup_MR_Cost_Hierarchy
--      Calculate_WO_Cost              --      Estimate_WO_Cost
--      Get_Profit_or_Loss             --      Insert_Cst_Wo_Hierarchy
--      Create_Wo_Cost_Structure       --      Create_Wo_Dependencies
--
--
-- NOTES
--
--
-- HISTORY
-- 28-AUG-2003    SHBHANDA      11.5.10. VWP-Costing Enhancements
-- 19-SEP-2003    SHBHANDA      Incorporated APIs
--                                 Insert_Cst_Wo_Hierarchy   -- Srini
--                                 Create_Wo_Cost_Structure  -- Srini
--                                 Create_Wo_Dependencies    -- ShivaK
--
-- 24-SEP-2003    SHBHANDA      Made call for CST_eamCost_PUB.Compute_Job_Estimate API
--                              in Rollup_MR_Cost_Hierarchy API
--
-- 08-OCT-2003    SHBHANDA      Made call for CST_eamCost_PUB.Delete_eamPerBal API
--                              prior to calling the Compute_Job_Estimate API
--                              in Rollup_MR_Cost_Hierarchy API
--
-- 14-OCT-2003    SHBHANDA      Incorporated Estimate_WO_Cost to be called from
--                              Estimate_Visit/MR/Task_Cost API.
--                              Also made changes to Calculated_WO_Cost
--                              in Rollup_MR_Cost_Hierarchy API
--
-- 07-NOV-2007    RBHAVSAR      Added PROCEDURE level logs when entering and exiting a procedure.
--                              Returned the status before returning from the procedure.
--                              Replaced all fnd_log.level_procedure with STATEMENT
--                              level logs and added more STATEMENT level logs at
--                              key decision points. Removed some tabs in the code.
-----------------------------------------------------------------


-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
-- Package/App Name
  G_PKG_NAME         CONSTANT  VARCHAR(30) := 'AHL_VWP_COST_PVT';
  G_APP_NAME         CONSTANT  VARCHAR2(3) := 'AHL';
  G_DEBUG 		               VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level   NUMBER   := fnd_log.g_current_runtime_level;
l_log_statement       NUMBER   := fnd_log.level_statement;
l_log_procedure       NUMBER   := fnd_log.level_procedure;
l_log_error           NUMBER   := fnd_log.level_error;
l_log_unexpected      NUMBER   := fnd_log.level_unexpected;
----------------------------------------------------------------------
-- START: Defining procedures BODY                                  --
----------------------------------------------------------------------


---------------------------------------------------------------------------------
-- Procedure to create Workorder Cost Structure from visit Cost Hierarchy      --
---------------------------------------------------------------------------------
PROCEDURE Create_Wo_Cost_Structure (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id               IN            NUMBER,
    x_cost_session_id        OUT    NOCOPY NUMBER,
    x_return_status          OUT    NOCOPY VARCHAR2,
    x_msg_count              OUT    NOCOPY NUMBER,
    x_msg_data               OUT    NOCOPY VARCHAR2)
  IS

  -- Get master workorder details
   CURSOR c_master_wo_cur (C_VISIT_ID IN NUMBER)
    IS
      SELECT workorder_id,wip_entity_id, visit_id
      FROM ahl_workorders
     WHERE visit_id = C_VISIT_ID AND VISIT_TASK_ID IS NULL
       AND master_workorder_flag = 'Y'
      AND STATUS_CODE NOT IN ('22','7');

  --Get child tasks details
  CURSOR c_child_tasks_cur (C_VISIT_ID IN NUMBER)
   IS
  SELECT visit_task_id,cost_parent_id,level,
         task_type_code,originating_task_id
    FROM ahl_visit_tasks_b
  WHERE visit_id = C_VISIT_ID
   AND NVL(status_code,'Y') <> 'DELETED'
   START WITH cost_parent_id IS NULL
   CONNECT BY PRIOR visit_task_id = cost_parent_id
   ORDER BY LEVEL;

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-Cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

 -- Get child workorder details
 CURSOR c_child_wo_cur (C_VISIT_TASK_ID IN NUMBER)
   IS
  SELECT workorder_id,wip_entity_id,visit_task_id
    FROM ahl_workorders
  WHERE visit_task_id = C_VISIT_TASK_ID
--    AND STATUS_CODE NOT IN ('22','7');
      AND STATUS_CODE <>'22'
      ORDER BY LAST_UPDATE_DATE DESC;

-- yazhou 27-Jun-2006 ends


   l_api_name	          CONSTANT VARCHAR2(30)	:= 'Create_Wo_Cost_Structure';
   L_DEBUG_KEY            CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data             VARCHAR2(2000);
   l_return_status        VARCHAR2(1);

   l_msg_count            NUMBER;
   l_child_entity         NUMBER;
   l_child_id             NUMBER;
   l_parent_entity        NUMBER;
   l_parent_id            NUMBER;
   l_session_id           NUMBER;
   l_application_id       NUMBER;

   l_master_wo_rec        c_master_wo_cur%ROWTYPE;
   l_child_tasks_rec      c_child_tasks_cur%ROWTYPE;
   l_child_wo_rec         c_child_wo_cur%ROWTYPE;
   l_cst_job_tbl          cst_job_tbl;
   i number := 0;

   BEGIN

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.  Visit id = ' || p_visit_id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Create_Wo_Cost_Structure;

      -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean( p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Get progarm application id
     l_application_id := FND_GLOBAL.prog_appl_id;

	 --  Get master workorder
     OPEN c_master_wo_cur(p_visit_id);
	 FETCH c_master_wo_cur INTO l_master_wo_rec;
	 IF c_master_wo_cur%FOUND THEN

	   l_cst_job_tbl(i).object_id := l_master_wo_rec.wip_entity_id;
	   l_cst_job_tbl(i).object_type := 2;
	   l_cst_job_tbl(i).parent_object_id := l_master_wo_rec.wip_entity_id;
	   l_cst_job_tbl(i).parent_object_type := 2;
	   l_cst_job_tbl(i).level_num := 0;
	   l_cst_job_tbl(i).program_application_id := l_application_id;

     END IF;
	   i := i + 1;
     CLOSE c_master_wo_cur;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Master Wo Object Id : ' || l_master_wo_rec.wip_entity_id ||
                        'Master Wo Parent Object Id : ' || l_master_wo_rec.wip_entity_id ||
                        'Application Id : ' || l_application_id);
     END IF;

	 -- Process child work orders
	 OPEN c_child_tasks_cur(p_visit_id);

	 LOOP
	  FETCH c_child_tasks_cur INTO l_child_tasks_rec;
          EXIT WHEN c_child_tasks_cur%NOTFOUND;
	  --Get associated wip entity id for the task
	  OPEN c_child_wo_cur(l_child_tasks_rec.visit_task_id);
	  FETCH c_child_wo_cur INTO l_child_wo_rec;
	  IF c_child_wo_cur%FOUND  THEN
	     l_child_entity := 2;
		 l_child_id     := l_child_wo_rec.wip_entity_id;

	  ELSE
	     l_child_entity := 1;
		 l_child_id     := l_child_tasks_rec.visit_task_id;

          END IF;
	  CLOSE c_child_wo_cur;

	  -- Find parent object id and parent type
      IF l_child_tasks_rec.cost_parent_id IS NOT NULL THEN
	  OPEN c_child_wo_cur(l_child_tasks_rec.cost_parent_id);
	  FETCH c_child_wo_cur INTO l_child_wo_rec;
	  IF c_child_wo_cur%FOUND  THEN
	     l_parent_entity := 2;
             l_parent_id     := l_child_wo_rec.wip_entity_id;

	  ELSE
	     l_parent_entity := 1;
             l_parent_id     := l_child_tasks_rec.visit_task_id;

          END IF;
	  CLOSE c_child_wo_cur;
      -- if Cost parent is null, get master workorder
      ELSE
	  l_parent_entity := 2;
	  l_parent_id     := l_master_wo_rec.wip_entity_id;
      END IF; --Cost parent is not null

	  -- Assign processed values
	   l_cst_job_tbl(i).object_id := l_child_id;
	   l_cst_job_tbl(i).object_type := l_child_entity;
	   l_cst_job_tbl(i).parent_object_id := l_parent_id;
	   l_cst_job_tbl(i).parent_object_type := l_parent_entity;
	   l_cst_job_tbl(i).level_num := l_child_tasks_rec.level;
	   l_cst_job_tbl(i).program_application_id := l_application_id;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Visit Task Id : ' || l_child_tasks_rec.visit_task_id ||
                           'Associated Child Object Id : ' || l_child_id ||
                           'Associated Child Object Type : ' || l_child_entity ||
                           'Level No : ' || l_child_tasks_rec.level ||
                           'Associated Parent Object Id : ' || l_parent_id ||
                           'Associated Parent Object Type : ' || l_parent_entity );
        END IF;

	i := i + 1;

      --
	  END LOOP;
	  CLOSE c_child_tasks_cur;

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Before Calling Insert Cst Wo Hierarchy ' ||l_cst_job_tbl.count);
       END IF;

    -- Call Insert procedure to load into interface table
      Insert_Cst_Wo_Hierarchy (
        p_cst_job_tbl        => l_cst_job_tbl,
        p_commit             => p_commit,
        x_session_id         => x_cost_session_id,
        x_return_status      => l_return_status);

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After Calling Insert cost workorder hierarchy, Return Status = ' || l_return_status ||
                        'Session id :' ||x_cost_session_id);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from Insert cost workorder hierarchy' || x_msg_count);
       END IF;

       RAISE Fnd_Api.g_exc_error;
     END IF;

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status);
     END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   ROLLBACK TO Create_Wo_Cost_Structure;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Create_Wo_Cost_Structure;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Create_Wo_Cost_Structure;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Create_Wo_Cost_Structure',
                               p_error_text     => SUBSTR(SQLERRM,1,500));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Create_Wo_Cost_Structure;


---------------------------------------------------------------------------------
-- Procedure to create Workorder Scheduling dependencies                       --
---------------------------------------------------------------------------------
PROCEDURE Create_Wo_Dependencies
(
    p_api_version            IN         NUMBER,
    p_init_msg_list          IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN         NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id               IN         NUMBER,
    x_MR_session_id          OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
)
IS
   l_api_name                 VARCHAR2(30) := 'Create_Wo_Dependencies';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   l_return_status            VARCHAR2(1);

   l_msg_count                NUMBER;
   l_visit_wip_entity_id      NUMBER;
   l_application_id           NUMBER;
   i                          NUMBER := 0;

   l_cst_job_tbl              cst_job_tbl;


-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-Cancelled)

   -- Get the Visit Workorder
   CURSOR     c_get_visit_wo( c_visit_id NUMBER)
   IS
   SELECT     wip_entity_id
   FROM       AHL_WORKORDERS
   WHERE      visit_id = c_visit_id
   AND        visit_task_id IS NULL
   AND        STATUS_CODE NOT IN ('22','7')
   AND        master_workorder_flag = 'Y';


-- Since one task may map to multiple canceled workorders, query for the latest one

   -- Get the Child Workorders for the Visit
   CURSOR     c_get_child_workorders( c_wip_entity_id NUMBER)
   IS
   SELECT     parent_object_id,
                     child_object_id,
                     level
   FROM       WIP_SCHED_RELATIONSHIPS
   WHERE      parent_object_type_id = 1
   AND        child_object_type_id = 1
   AND        not exists (select 1 from ahl_workorders awo1
                                                where awo1.wip_entity_id = parent_object_id
                                                 and ( awo1.status_code ='22'
                                                 OR (awo1.status_code ='7'
                                               AND awo1.LAST_UPDATE_DATE <> (select MAX(LAST_UPDATE_DATE)
                                                                               from ahl_workorders awo2
                                                                              where visit_task_id = awo1.visit_task_id)))
                   )
   AND        not exists (select 1 from ahl_workorders awo1
                                                where awo1.wip_entity_id = child_object_id
                                                 and ( awo1.status_code ='22'
                                                 OR (awo1.status_code ='7'
                                               AND awo1.LAST_UPDATE_DATE <> (select MAX(LAST_UPDATE_DATE)
                                                                               from ahl_workorders awo2
                                                                              where visit_task_id = awo1.visit_task_id)))
                   )
   START WITH parent_object_id = c_wip_entity_id
              AND  relationship_type = 1
   CONNECT BY parent_object_id = PRIOR child_object_id
              AND  relationship_type = 1
   ORDER BY   level;

-- yazhou 27-Jun-2006 ends

BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' ||  p_visit_id);
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard Start of API savepoint
  SAVEPOINT create_wo_dependencies_PVT;

  l_application_id := FND_GLOBAL.prog_appl_id;

  OPEN   c_get_visit_wo( p_visit_id );
  FETCH  c_get_visit_wo
  INTO   l_visit_wip_entity_id;
  CLOSE  c_get_visit_wo;

  -- Populate the Visit Record
  l_cst_job_tbl(i).object_id := l_visit_wip_entity_id;
  l_cst_job_tbl(i).object_type := 2;
  l_cst_job_tbl(i).parent_object_id := l_visit_wip_entity_id;
  l_cst_job_tbl(i).parent_object_type := 2;
  l_cst_job_tbl(i).level_num := 0;
  l_cst_job_tbl(i).program_application_id := l_application_id;

  IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Level-Parent Object Id - Child Object Id' || l_cst_job_tbl(i).level_num ||
                     '----' || l_cst_job_tbl(i).parent_object_id || '-----' || l_cst_job_tbl(i).object_id);
  END IF;

  -- Populate the Child Workorders for the Visit
  FOR child_cur IN c_get_child_workorders( l_visit_wip_entity_id ) LOOP
     i := i + 1;
     l_cst_job_tbl(i).object_id := child_cur.child_object_id;
     l_cst_job_tbl(i).object_type := 2;
     l_cst_job_tbl(i).parent_object_id := child_cur.parent_object_id;
     l_cst_job_tbl(i).parent_object_type := 2;
     l_cst_job_tbl(i).level_num := child_cur.level;
     l_cst_job_tbl(i).program_application_id := l_application_id;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Level-Parent Object Id - Child Object Id' || l_cst_job_tbl(i).level_num || '----' ||  l_cst_job_tbl(i).parent_object_id || '-----' || l_cst_job_tbl(i).object_id);
     END IF;

  END LOOP;

  IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                    'Before Calling Insert_Cst_Wo_Hierarchy');
  END IF;

  Insert_Cst_Wo_Hierarchy
  (
    p_cst_job_tbl        => l_cst_job_tbl,
    p_commit             => FND_API.G_FALSE,
    x_session_id         => x_MR_session_id,
    x_return_status      => l_return_status
  );

  IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                    'After Calling Insert_Cst_Wo_Hierarchy, Return Status = ' || l_return_status);
  END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from Insert cost workorder hierarchy' || x_msg_count);
       END IF;

       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       RAISE Fnd_Api.g_exc_error;
     END IF;

  IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     ' x_session_id = ' || x_MR_session_id  );
  END IF;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_wo_dependencies_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_wo_dependencies_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get
    (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO create_wo_dependencies_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
      FND_MSG_PUB.add_exc_msg
      (
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240)
      );
    END IF;
     FND_MSG_PUB.count_and_get
     (
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data
     );

END Create_Wo_Dependencies;

---------------------------------------------------------------------------------
-- Procedure to insert Visits cost hierarchy structure and MR Hierarchy structure
--                      into Costing interface table CST_EAM_HIERARCHY_SNAPSHOT
---------------------------------------------------------------------------------
PROCEDURE Insert_Cst_Wo_Hierarchy (
    p_cst_job_tbl            IN           Cst_Job_Tbl,
    p_commit                 IN           VARCHAR2  := Fnd_Api.G_FALSE,
    x_session_id             OUT NOCOPY   NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2)
 IS

  l_api_name	      CONSTANT	VARCHAR2(30)	:= 'Insert_Cst_Wo_Hierarchy';
  L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);

  l_msg_count         NUMBER;
  l_group_id          NUMBER;

  l_cst_job_tbl     cst_job_tbl := p_cst_job_tbl;

 BEGIN

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.');
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Cost Session Id
	SELECT MTL_EAM_ASSET_ACTIVITIES_S.nextval INTO l_group_id
	FROM DUAL;

   	-- Validation for sequence
	IF l_group_id IS NULL THEN
          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_CST_EAM_SEQ_NOT_EXIST');
          FND_MSG_PUB.ADD;
          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'MTL_EAM_ASSET_ACTIVITIES_S Sequence not exists ');
          END IF;
          RAISE Fnd_Api.g_exc_error;
        END IF;

   -- loop through all the records
   IF l_cst_job_tbl.COUNT> 0 THEN
    FOR i IN l_cst_job_tbl.FIRST..l_cst_job_tbl.LAST
	LOOP

                  IF (l_log_statement >= l_log_current_level) THEN
                      fnd_log.string(l_log_statement,
                                     L_DEBUG_KEY,
                                     'Call INSERT CST_EAM_HIERARCHY_SNAPSHOT ');
                  END IF;
		  INSERT INTO CST_EAM_HIERARCHY_SNAPSHOT(
		   GROUP_ID,
		   OBJECT_ID,
		   OBJECT_TYPE,
		   PARENT_OBJECT_ID,
		   PARENT_OBJECT_TYPE ,
		   LEVEL_NUM,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   CREATION_DATE,
		   CREATED_BY,
		   REQUEST_ID,
		   PROGRAM_APPLICATION_ID,
		   LAST_UPDATE_LOGIN)
		   VALUES
		   (
		    l_group_id,
		    l_cst_job_tbl(i).object_id,
		    l_cst_job_tbl(i).object_type,
		    l_cst_job_tbl(i).parent_object_id,
		    l_cst_job_tbl(i).parent_object_type,
		    l_cst_job_tbl(i).level_num,
		    sysdate,
		    fnd_global.user_id,
		    sysdate,
		    fnd_global.user_id,
		    null,
		    l_cst_job_tbl(i).program_application_id,
		    fnd_global.login_id
		   );

	  END LOOP;
     END IF;

      -- Assign Cost Session Id
      x_session_id := l_group_id;

     -- x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. '  ||
                        'Value of Session ID : ' || x_session_id);
     END IF;


END Insert_Cst_Wo_Hierarchy;

--------------------------------------------------------------------------
-- Procedure to calculate visit's actual and estimated cost             --
--------------------------------------------------------------------------
PROCEDURE Calculate_Visit_Cost(
    p_visit_id	        IN              NUMBER,
    p_Session_id        IN              NUMBER,
    x_Actual_cost       OUT NOCOPY      NUMBER,
    x_Estimated_cost    OUT NOCOPY      NUMBER,
    x_return_status     OUT NOCOPY      VARCHAR2)
IS
   -- Define local Variables
   l_actual_cost        NUMBER := 0;
   l_estimated_cost     NUMBER := 0;
   l_wip_Id             NUMBER;
   l_count              NUMBER;
   l_OSP_cost           NUMBER;

   l_return_status      VARCHAR2(1);

   L_API_NAME  CONSTANT VARCHAR2(30) := 'Calculate_Visit_Cost';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define local cursors
   -- To find out WIP_Entity_Id for the visit
    CURSOR c_job(x_id IN NUMBER) IS
     SELECT AWO.WIP_ENTITY_ID
        FROM AHL_WORKORDERS AWO
        WHERE AWO.VISIT_ID = x_id
      AND VISIT_TASK_ID IS NULL
      AND AWO.STATUS_CODE NOT IN ('22','7')
      AND AWO.MASTER_WORKORDER_FLAG = 'Y';

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

   -- To find out to find out all task's Workorder_Id within visit except those,
   -- which have task_type_code = 'Summary' and MR_id is Null i.e manually created Summary task
    CURSOR c_WO_tasks (x_id IN NUMBER) IS
      SELECT AVTB.VISIT_TASK_ID, AWV.WORKORDER_ID
      FROM AHL_VISIT_TASKS_B AVTB, AHL_WORKORDERS AWV
        WHERE AVTB.VISIT_TASK_ID = AWV.VISIT_TASK_ID
        AND AVTB.VISIT_ID = x_id
        AND NVL(AVTB.status_code, 'Y') <> NVL ('DELETED', 'X')
--        AND AWV.STATUS_CODE NOT IN ('22','7')
        AND AWV.STATUS_CODE <> '22'
        AND not (AVTB.MR_ID is Null and AVTB.task_type_code='SUMMARY')
        ORDER BY AWV.LAST_UPDATE_DATE DESC;

-- yazhou 27-Jun-2006 ends

    c_WO_tasks_rec c_WO_tasks%ROWTYPE;


    -- To find out if jobs is an internal job or an OSP job
    CURSOR c_OSP_Job (x_id IN NUMBER) IS
      SELECT * FROM AHL_OSP_ORDER_LINES
        WHERE WORKORDER_ID = x_id;
    c_OSP_Job_rec c_OSP_Job%ROWTYPE;

BEGIN
   ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Visit ID : ' || p_visit_id || 'Session ID : ' || p_Session_id);
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Calculate_Visit_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------Start of API Body------------------------------------

     -- make sure that visit id is present in the input

     IF(p_visit_id IS NULL OR p_visit_id = FND_API.G_MISS_NUM) THEN

        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END IF;


     -- Cursor to find out Wip_Entity_Id for the visit
       OPEN c_job(p_visit_id);
       FETCH c_job INTO l_wip_Id;
       CLOSE c_job;

     -- Debug statements
      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before calling Get_WO_Cost API to find Cost' ||
                         'WIP ENTITY ID = ' || l_wip_Id );
      END IF;

     -- Call Get_WO_Cost to find Cost for the visit from Cost Mgnt Entity
        Get_WO_Cost (
             p_Session_Id      => p_Session_id,
             p_Id	       => l_wip_Id,
             p_program_id      => FND_GLOBAL.Prog_Appl_Id,
             x_Actual_cost     => l_Actual_cost,
             x_Estimated_cost  => l_Estimated_cost,
             x_return_status   => l_return_status);


    -- Debug statements
     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling Get_WO_Cost API to find Cost, Return Status = ' || l_return_status ||
                        'Actual Cost : ' || l_actual_cost ||
                        'Estimated Cost : ' || l_estimated_cost );
     END IF;

    -- Cursor to find all tasks under this current Visit
       OPEN c_WO_tasks(p_visit_id);
       LOOP
         FETCH c_WO_tasks INTO c_WO_tasks_rec;
         EXIT WHEN c_WO_tasks%NOTFOUND;

            -- Cursor to find if any OSP jobs present for the tasks in Visit
            OPEN c_OSP_Job(c_WO_tasks_rec.Workorder_Id);
            FETCH c_OSP_Job INTO c_OSP_Job_rec;

            IF c_OSP_Job%FOUND THEN
               -- Debug statements
               IF (l_log_statement >= l_log_current_level) THEN
                   fnd_log.string(l_log_statement,
                                  L_DEBUG_KEY,
                                  'Before calling Get_OSP_Cost API to find Cost for OSP Job' );
               END IF;

               AHL_OSP_COST_PVT.Get_OSP_Cost
               (
                     x_return_status   => l_return_status,
                     p_workorder_id    => c_WO_tasks_rec.Workorder_Id,
                     x_osp_cost        => l_osp_cost
               );


                l_actual_cost := l_actual_cost +  l_OSP_cost;
                l_estimated_cost := l_estimated_cost +  l_OSP_cost;

               -- Debug statements
                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'After calling Get_OSP_Cost API, Return Status = ' || l_return_status ||
                                   'Actual Cost : ' || l_actual_cost ||
                                   'Estimated Cost : ' || l_estimated_cost );
                END IF;

            END IF;
            CLOSE c_OSP_Job;

       END LOOP;
       CLOSE c_WO_tasks;


       x_Actual_cost     := l_actual_cost;
       x_Estimated_cost  := l_Estimated_cost;

    ------------------------End of API Body------------------------------------

    --x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string(l_log_procedure,
                       L_DEBUG_KEY ||'.end',
                       'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                       'Actual Cost : ' || l_actual_cost ||
                       'Estimated Cost : ' || l_estimated_cost );
    END IF;

    ------------------------Terminate API Body------------------------------------
END Calculate_Visit_Cost;


--------------------------------------------------------------------------
-- Procedure to calculate visit's MR actual and estimated cost          --
--------------------------------------------------------------------------
PROCEDURE Calculate_MR_Cost(
    p_visit_task_id         IN 	        NUMBER,
    p_Session_id            IN 	        NUMBER,
    x_Actual_cost           OUT NOCOPY  NUMBER,
    x_Estimated_cost        OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY  VARCHAR2 )
IS
    -- Define local Variables
   l_actual_cost        NUMBER := 0;
   l_estimated_cost     NUMBER := 0;

   l_wip_Id             NUMBER;
   l_count              NUMBER;
   l_OSP_cost           NUMBER;

   l_return_status      VARCHAR2(1);

   L_API_NAME  CONSTANT VARCHAR2(30) := 'Calculate_MR_Cost';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define local Cursors
   -- To find out viist's task details
    CURSOR c_task(x_id IN NUMBER)IS
     SELECT * FROM AHL_VISIT_TASKS_B
     WHERE VISIT_TASK_ID = x_id;
    c_task_rec c_task%ROWTYPE;

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

   -- To find out WIP_Entity_Id for the MR task
    CURSOR c_job(x_id IN NUMBER) IS
     SELECT AWO.WIP_ENTITY_ID
        FROM AHL_WORKORDERS AWO
        WHERE AWO.VISIT_TASK_ID = x_id
--      AND AWO.STATUS_CODE NOT IN ('22','7')
      AND AWO.STATUS_CODE <>'22'
      AND AWO.MASTER_WORKORDER_FLAG = 'Y'
     ORDER BY LAST_UPDATE_DATE DESC;

-- yazhou 27-Jun-2006 ends


   -- To find out all tasks under the given MR
    CURSOR c_MR_task(x_id IN NUMBER) IS
     SELECT visit_task_id
       FROM ahl_visit_tasks_b
       WHERE mr_id is not null
    START WITH visit_task_id = x_id
    CONNECT BY PRIOR visit_task_id = originating_task_id;
    c_MR_task_rec c_MR_task%ROWTYPE;

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

   -- To find out to find out task's Workorder_Id
    CURSOR c_WO_tasks (x_id IN NUMBER) IS
      SELECT AWV.WORKORDER_ID
      FROM AHL_WORKORDERS AWV
        WHERE AWV.VISIT_TASK_ID = x_id
--      AND AWO.STATUS_CODE NOT IN ('22','7')
      AND AWV.STATUS_CODE <>'22'
     ORDER BY LAST_UPDATE_DATE DESC;

-- yazhou 27-Jun-2006 ends

    c_WO_tasks_rec c_WO_tasks%ROWTYPE;


    -- To find out if jobs is an internal job or an OSP job
    CURSOR c_OSP_Job (x_id IN NUMBER) IS
      SELECT * FROM AHL_OSP_ORDER_LINES
        WHERE WORKORDER_ID = x_id;
    c_OSP_Job_rec c_OSP_Job%ROWTYPE;

BEGIN
   ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Visit Task ID : ' || p_visit_task_id || 'Session ID : ' || p_Session_id);

     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Calculate_MR_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------Start of API Body------------------------------------
    -- Validate Visit Task and Session Exists
     IF p_visit_task_id IS NULL THEN
       Fnd_Message.Set_Name('AHL','AHL_CST_VISIT_TASK_ID_NULL');
       Fnd_Msg_Pub.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

       -- Cursor to find out MR_Id value for the Summary Task
       OPEN c_task(p_visit_task_id);
       FETCH c_task INTO c_task_rec;
       CLOSE c_task;

       IF c_task_rec.MR_Id IS NOT NULL THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'MR ID is not null : ' || c_task_rec.MR_Id );
          END IF;
          -- Cursor to find out WIP entity Id for the Current task
          OPEN c_job(p_visit_task_id);
          FETCH c_job INTO l_wip_Id;
          CLOSE c_job;

          -- Debug statements

          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'WIP ENTITY ID : ' || l_wip_Id ||
                            'Before calling Get_WO_Cost API to find Cost' );
          END IF;

          Get_WO_Cost (
             p_Session_Id      => p_Session_id,
             p_Id              => l_wip_Id,
             p_program_id      => FND_GLOBAL.Prog_Appl_Id,
             x_Actual_cost     => l_actual_cost,
             x_Estimated_cost  => l_estimated_cost,
             x_return_status   => l_return_status);

          -- Debug statements
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'After calling Get_WO_Cost API to find Cost' ||
                            'Actual Cost : ' || l_actual_cost ||
                            'Estimated Cost : ' || l_estimated_cost );
          END IF;

          -- Cursor to find all tasks with routes under this current MR
          OPEN c_MR_task(p_visit_task_id);
          LOOP
              FETCH c_MR_task INTO c_MR_task_rec;
              EXIT WHEN c_MR_task%NOTFOUND;

                -- Cursor to find if any jobs present for the tasks in Visit
                OPEN c_WO_tasks(c_MR_task_rec.visit_task_id);
                FETCH c_WO_tasks INTO c_WO_tasks_rec;
                CLOSE c_WO_tasks;

                -- Cursor to find if any OSP jobs present for the tasks in Visit
                OPEN c_OSP_Job(c_WO_tasks_rec.Workorder_Id);
                FETCH c_OSP_Job INTO c_OSP_Job_rec;

                IF c_OSP_Job%FOUND THEN

                 -- Debug statements
                   IF (l_log_statement >= l_log_current_level) THEN
                       fnd_log.string(l_log_statement,
                                      L_DEBUG_KEY,
                                      'Before calling Get_OSP_Cost API to find Cost for OSP Job' );
                   END IF;

                   AHL_OSP_COST_PVT.Get_OSP_Cost
                   (
                     x_return_status   => l_return_status,
                     p_workorder_id    => c_WO_tasks_rec.Workorder_Id,
                     x_osp_cost        => l_osp_cost
                   );

                    l_actual_cost := l_actual_cost +  nvl(l_OSP_cost,0);
                    l_estimated_cost := l_estimated_cost +  nvl(l_OSP_cost,0);

                -- Debug statements

                    IF (l_log_statement >= l_log_current_level) THEN
                        fnd_log.string(l_log_statement,
                                       L_DEBUG_KEY,
                                       'After calling Get_OSP_Cost API to find Cost for OSP Job, , Return Status = ' || l_return_status ||
                                       'Actual Cost : ' || l_actual_cost ||
                                       'Estimated Cost : ' || l_estimated_cost);
                    END IF;

                END IF;
                CLOSE c_OSP_Job;

          END LOOP;
          CLOSE c_MR_task;
       END IF; -- MR ID is not null


     x_actual_cost    := l_actual_cost;
     x_estimated_cost := l_estimated_cost;

    ------------------------End of API Body------------------------------------
     --x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                        'Actual Cost : ' || l_actual_cost ||
                        'Estimated Cost : ' || l_estimated_cost);
     END IF;

     ------------------------Terminate API Body------------------------------------
END Calculate_MR_Cost;

--------------------------------------------------------------------------
-- Procedure to calculate visit's Cost Structure Node actual and estimated cost        --
--------------------------------------------------------------------------
PROCEDURE Calculate_Node_Cost(
    p_visit_task_id         IN	            NUMBER,
    p_session_id            IN              NUMBER,
    x_Actual_cost           OUT     NOCOPY  NUMBER,
    x_Estimated_cost        OUT     NOCOPY  NUMBER,
    x_return_status         OUT     NOCOPY  VARCHAR2  )
IS
   l_actual_cost        NUMBER := 0;
   l_estimated_cost     NUMBER := 0;

   l_OSP_cost           NUMBER;
   l_return_status      VARCHAR2(1);

   L_API_NAME  CONSTANT VARCHAR2(30) := 'Calculate_Node_Cost';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define local cursors
   -- To find out viist's task details
    CURSOR c_task(x_id IN NUMBER)IS
     SELECT * FROM AHL_VISIT_TASKS_B
     WHERE VISIT_TASK_ID = x_id;
    c_task_rec c_task%ROWTYPE;

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

   -- To find out to find out task's Workorder_Id
    CURSOR c_WO_tasks (x_id IN NUMBER) IS
      SELECT AWV.WORKORDER_ID, AWV.wip_entity_id
      FROM AHL_WORKORDERS AWV
        WHERE AWV.VISIT_TASK_ID = x_id
--      AND AWV.STATUS_CODE NOT IN ('22','7')
      AND AWV.STATUS_CODE <>'22'
     ORDER BY LAST_UPDATE_DATE DESC;

-- yazhou 27-Jun-2006 ends

    c_WO_tasks_rec c_WO_tasks%ROWTYPE;

    -- To find out if jobs is an internal job or an OSP job
    CURSOR c_OSP_Job (x_id IN NUMBER) IS
      SELECT * FROM AHL_OSP_ORDER_LINES
        WHERE WORKORDER_ID = x_id;
    c_OSP_Job_rec c_OSP_Job%ROWTYPE;

   -- To find out all tasks using the given task as cost parent
    CURSOR c_Cost_Parent_task(x_id IN NUMBER) IS
     SELECT visit_task_id
       FROM ahl_visit_tasks_b
       START WITH visit_task_id = x_id
    CONNECT BY PRIOR visit_task_id = cost_parent_id;
    c_Cost_Parent_task_rec c_Cost_Parent_task%ROWTYPE;

BEGIN
   ------------------------Initialize Body------------------------------------
     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Value of Visit Task ID : ' || p_visit_task_id ||
                        'Cost Session ID : ' || p_Session_id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Calculate_Node_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------Start of API Body------------------------------------
        -- Validate Visit Task
     IF p_Visit_task_id IS NULL THEN
       Fnd_Message.Set_Name('AHL','AHL_CST_VISIT_TASK_ID_NULL');
       Fnd_Msg_Pub.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

       OPEN c_task(p_Visit_task_id);
       FETCH c_task INTO c_task_rec;
       CLOSE c_task;

-- for manually created summary task representing MRs

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'TASK TYPE CODE is = '  || c_task_rec.TASK_TYPE_CODE ||
                          'MR ID is = ' || c_task_rec.mr_id );
       END IF;

       IF c_task_rec.TASK_TYPE_CODE = 'SUMMARY' and c_task_rec.mr_id is null
       THEN

        -- Debug statements
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before calling Get_WO_Cost API to find Cost' );
          END IF;

          Get_WO_Cost (
             p_Session_Id      => p_Session_id,
             p_Id              => p_Visit_task_id,
             p_program_id      => FND_GLOBAL.Prog_Appl_Id,
             x_Actual_cost     => l_actual_cost,
             x_Estimated_cost  => l_estimated_cost,
             x_return_status   => l_return_status);

          -- Debug statements
             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'After calling Get_WO_Cost API to find Cost, , Return Status = ' || l_return_status);
             END IF;

      ELSE -- all other tasks

              OPEN c_WO_tasks(p_Visit_task_id);
              FETCH c_WO_tasks INTO c_WO_tasks_rec;
              CLOSE c_WO_tasks;

        -- Debug statements
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Before calling Get_WO_Cost API to find Cost' ||
                            'WIP ENTITY ID = ' || c_WO_tasks_rec.wip_entity_id ||
                            'Value of Work Order ID = ' || c_WO_tasks_rec.workorder_id );

          END IF;

          Get_WO_Cost (
             p_Session_Id      => p_Session_id,
             p_Id              => c_WO_tasks_rec.wip_entity_id,
             p_program_id      => FND_GLOBAL.Prog_Appl_Id,
             x_Actual_cost     => l_actual_cost,
             x_Estimated_cost  => l_estimated_cost,
             x_return_status   => l_return_status);

          -- Debug statements
                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'After calling Get_OSP_Cost API to find Cost for OSP Job, Return Status = ' || l_return_status ||
                                   'Value of p_Session_Id : ' || p_Session_Id ||
                                   'Actual Cost : ' || l_actual_cost ||
                                   'Estimated Cost : ' || l_estimated_cost );
                END IF;

       END IF; -- task type = summary and mr_id is null

          -- Cursor to find all tasks using the current task as cost parent
          OPEN c_Cost_Parent_task(p_visit_task_id);
          LOOP
              FETCH c_Cost_Parent_task INTO c_Cost_Parent_task_rec;
              EXIT WHEN c_Cost_Parent_task%NOTFOUND;

               -- Cursor to find if any jobs present for the tasks in Visit
              OPEN c_WO_tasks(c_Cost_Parent_task_rec.visit_task_id);
              FETCH c_WO_tasks INTO c_WO_tasks_rec;

              if c_WO_tasks%FOUND then

                -- Cursor to find if any OSP jobs present for the tasks in Visit
                OPEN c_OSP_Job(c_WO_tasks_rec.Workorder_Id);
                FETCH c_OSP_Job INTO c_OSP_Job_rec;

                IF c_OSP_Job%FOUND THEN

                 -- Debug statements
                   IF (l_log_statement >= l_log_current_level) THEN
                       fnd_log.string(l_log_statement,
                                      L_DEBUG_KEY,
                                      'Before calling Get_OSP_Cost API to find Cost for OSP Job' );
                   END IF;

                   AHL_OSP_COST_PVT.Get_OSP_Cost
                   (
                     x_return_status   => l_return_status,
                     p_workorder_id    => c_WO_tasks_rec.Workorder_Id,
                     x_osp_cost        => l_osp_cost
                   );

                    l_actual_cost := l_actual_cost +  nvl(l_OSP_cost,0);
                    l_estimated_cost := l_estimated_cost +  nvl(l_OSP_cost,0);

                    -- Debug statements
                    IF (l_log_statement >= l_log_current_level) THEN
                        fnd_log.string(l_log_statement,
                                       L_DEBUG_KEY,
                                       'After calling Get_OSP_Cost API to find Cost for OSP Job, Return Status = ' || l_return_status ||
                                       'Actual Cost : ' || l_actual_cost ||
                                       'Estimated Cost : ' || l_estimated_cost );
                    END IF;

                END IF;
                CLOSE c_OSP_Job;
             END IF;
             CLOSE c_WO_tasks;
          END LOOP;
          CLOSE c_Cost_Parent_task;


     x_actual_cost    := l_actual_cost;
     x_estimated_cost := l_estimated_cost;

    ------------------------End of API Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                        'Task Actual Cost : ' || x_actual_cost ||
                        'Task Estimated Cost : ' || x_estimated_cost );
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------Terminate API Body------------------------------------
END Calculate_Node_Cost;


--------------------------------------------------------------------------
-- Procedure to calculate visit's task actual and estimated cost        --
--------------------------------------------------------------------------
PROCEDURE Calculate_Task_Cost(
    p_visit_task_id         IN	            NUMBER,
    p_session_id            IN              NUMBER,
    x_Actual_cost           OUT     NOCOPY  NUMBER,
    x_Estimated_cost        OUT     NOCOPY  NUMBER,
    x_return_status         OUT     NOCOPY  VARCHAR2  )
IS
   l_actual_cost        NUMBER := 0;
   l_estimated_cost     NUMBER := 0;

   l_wip_Id             NUMBER;
   l_WO_Id              NUMBER;

   l_OSP_cost           NUMBER;
   l_return_status      VARCHAR2(1);

   L_API_NAME  CONSTANT VARCHAR2(30) := 'Calculate_Task_Cost';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define local cursors
   -- To find out viist's task details
    CURSOR c_task(x_id IN NUMBER)IS
     SELECT * FROM AHL_VISIT_TASKS_B
     WHERE VISIT_TASK_ID = x_id;
    c_task_rec c_task%ROWTYPE;

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

   -- To find out WIP_Entity_Id for the task
    CURSOR c_job(x_id IN NUMBER) IS
     SELECT AWO.WIP_ENTITY_ID, AWO.WORKORDER_ID
        FROM AHL_WORKORDERS AWO
        WHERE AWO.VISIT_TASK_ID = x_id
--      AND AWO.STATUS_CODE NOT IN ('22','7')
      AND AWO.STATUS_CODE <>'22'
      AND AWO.MASTER_WORKORDER_FLAG = 'N'
      ORDER BY LAST_UPDATE_DATE DESC;
-- yazhou 27-Jun-2006 ends

    -- To find out if jobs is an internal job or an OSP job
    CURSOR c_OSP_Job (x_id IN NUMBER) IS
      SELECT * FROM AHL_OSP_ORDER_LINES
        WHERE WORKORDER_ID = x_id;
    c_OSP_Job_rec c_OSP_Job%ROWTYPE;

BEGIN
   ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Value of Visit Task ID : ' || p_visit_task_id ||
                        'Session ID : ' || p_Session_id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Calculate_Task_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------Start of API Body------------------------------------

        -- Validate Visit Task
     IF p_Visit_task_id IS NULL THEN
       Fnd_Message.Set_Name('AHL','AHL_CST_VISIT_TASK_ID_NULL');
       Fnd_Msg_Pub.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

       OPEN c_task(p_Visit_task_id);
       FETCH c_task INTO c_task_rec;
       CLOSE c_task;

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'TASK TYPE CODE = '  || c_task_rec.TASK_TYPE_CODE ||
                          'MR ID = ' || c_task_rec.mr_id );
       END IF;

-- for summary task representing MRs

       IF c_task_rec.TASK_TYPE_CODE = 'SUMMARY' and c_task_rec.mr_id is not null THEN

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Before Calling Calculate_MR_Cost : MR-summary tasks' );
          END IF;

          Calculate_MR_Cost
           (p_Visit_task_id      => p_Visit_task_id,
            p_Session_id         => p_Session_id,
            x_Actual_cost        => l_actual_cost,
            x_Estimated_cost     => l_estimated_cost,
            x_return_status      => l_return_status
           );

           IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'After calling Calculate_MR_Cost, Return Status = ' || l_return_status ||
                              'Actual Cost : ' || l_actual_cost ||
                              'Estimated Cost : ' || l_estimated_cost );
           END IF;
       ELSIF c_task_rec.TASK_TYPE_CODE <> 'SUMMARY'
       THEN
-- for planned/unplanned/unassociate tasks

          OPEN c_job(p_Visit_task_id);
          FETCH c_job INTO l_wip_Id, l_WO_Id;
          CLOSE c_job;

        -- Debug statements
          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Before calling Get_WO_Cost API to find Cost : Non-summary tasks ' ||
                             'WIP ENTITY ID : ' || l_wip_Id ||
                             'Value of Work Order ID : ' || l_WO_Id );
          END IF;

          Get_WO_Cost (
             p_Session_Id      => p_Session_id,
             p_Id              => l_wip_Id,
             p_program_id      => FND_GLOBAL.Prog_Appl_Id,
             x_Actual_cost     => l_actual_cost,
             x_Estimated_cost  => l_estimated_cost,
             x_return_status   => l_return_status);

          -- Debug statements
                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'After calling Get_OSP_Cost API to find Cost for OSP Job, Return Status = ' || l_return_status ||
                                   'Actual Cost : ' || l_actual_cost ||
                                   'Estimated Cost : ' || l_estimated_cost );
                END IF;

                OPEN c_OSP_Job(l_WO_Id);
                FETCH c_OSP_Job INTO c_OSP_Job_rec;

                IF c_OSP_Job%FOUND THEN

                  IF (l_log_statement >= l_log_current_level) THEN
                      fnd_log.string(l_log_statement,
                                     L_DEBUG_KEY,
                                     'Before calling AHL_OSP_COST_PVT.Get_OSP_Cost' );
                  END IF;
                  AHL_OSP_COST_PVT.Get_OSP_Cost
                   (
                     x_return_status   => l_return_status,
                     p_workorder_id    => l_WO_Id,
                     x_osp_cost        => l_osp_cost
                   );

                  l_actual_cost := l_actual_cost +  nvl(l_OSP_cost,0);
                  l_estimated_cost := l_estimated_cost +  nvl(l_OSP_cost,0);

                  IF (l_log_statement >= l_log_current_level) THEN
                      fnd_log.string(l_log_statement,
                                     L_DEBUG_KEY,
                                     'After calling AHL_OSP_COST_PVT.Get_OSP_Cost, Return Status = ' || l_return_status ||
                                     'l_actual_cost = ' || l_actual_cost ||
                                     'l_estimated_cost = ' || l_estimated_cost);
                  END IF;
                END IF;
                CLOSE c_OSP_Job;

        END IF;


     x_actual_cost    := l_actual_cost;
     x_estimated_cost := l_estimated_cost;

     ------------------------End of API Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                        'Task Actual Cost : ' || x_actual_cost ||
                        'Task Estimated Cost : ' || x_estimated_cost );
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------Terminate API Body------------------------------------
END Calculate_Task_Cost;


--------------------------------------------------------------------------
-- Procedure to disitnguish between various conditions mainly Visit status,
-- Session and Job existence for further calculation of actual and estimated cost
-- Called from get_visit_cost_details/get_task_cost_details/get_MR_cost_details
--------------------------------------------------------------------------
PROCEDURE Calculate_WO_Cost(
    p_api_version            IN            NUMBER    := 1.0,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_x_cost_price_rec       IN OUT        NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_price_rec_type,
    x_return_status          OUT           NOCOPY	VARCHAR2)
IS
   -- Define Local Variables
    l_count            NUMBER;

    l_visit_id         NUMBER;
    l_mr_Session_id    NUMBER := NULL;
    l_cost_session_id  NUMBER := NULL;

    l_return_status    VARCHAR2(1);
    l_cost_rollup_flag VARCHAR2(1):='N';
    l_cost_price_rec   AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type := p_x_cost_price_rec;

    L_API_NAME  CONSTANT VARCHAR2(30) := 'Calculate_WO_Cost';
    L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define Local Cursors
   -- To find all visit related details
    CURSOR c_visit_details (x_id IN NUMBER) IS
      SELECT * FROM AHL_VISITS_VL
        WHERE VISIT_ID = x_id;
    visit_rec  c_visit_details%ROWTYPE;

   -- To find visit id for a given task
    CURSOR c_task (x_T_id IN NUMBER) IS
      SELECT visit_id FROM AHL_VISIT_TASKS_VL
      WHERE VISIT_TASK_ID = x_T_id;

  -- To find if job exists for the visit at shop floor
  -- in 'Draft' status
    CURSOR c_job_visit(x_id IN NUMBER) IS
      SELECT WORKORDER_ID FROM AHL_WORKORDERS
        WHERE VISIT_ID = x_id
      AND VISIT_TASK_ID IS NULL
      AND STATUS_CODE NOT IN ('22','7')
      AND MASTER_WORKORDER_FLAG = 'Y';

BEGIN
 ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Value of Visit ID : ' || l_cost_price_rec.visit_id ||
                        'Value of Cost Session ID : ' || l_cost_price_rec.cost_session_Id ||
                        'Value of MR Session ID : ' || l_cost_price_rec.MR_Session_Id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Calculate_WO_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_Visit_Id        := l_cost_price_rec.visit_Id;
     l_MR_Session_Id   := l_cost_price_rec.MR_Session_Id;
     l_Cost_Session_Id := l_cost_price_rec.Cost_Session_Id;


    IF l_visit_id IS NULL OR l_visit_id = FND_API.G_MISS_NUM THEN

       -- Whether call for Calculate_WO_Cost is from Visit OR Task
         IF l_cost_price_rec.visit_task_id IS NOT NULL AND l_cost_price_rec.visit_task_id <> FND_API.G_MISS_NUM THEN

             -- Cursor for task related information in search task view
              OPEN c_task(l_cost_price_rec.visit_task_id);
              FETCH c_task INTO l_visit_id;
              CLOSE c_task;

         END IF;

      -- Validate Visit exists
       IF l_visit_id IS NULL OR l_visit_id = FND_API.G_MISS_NUM THEN

          FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INPUT_MISS');

          FND_MSG_PUB.ADD;

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'Visit id is mandatory but found null in input ' );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

     END IF;

         -- Check if workorder already exists for the visit

         OPEN c_job_visit(l_visit_id);
         FETCH c_job_visit INTO l_cost_price_rec.workorder_id;
         CLOSE c_job_visit;

         IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'work order ID is : '||l_cost_price_rec.workorder_id );
         END IF;

         -- Cursor to fetch all visit details
         OPEN c_visit_details(l_visit_id);
         FETCH c_visit_details INTO visit_rec;
         CLOSE c_visit_details;


     --  If any task changed flag is  'Y' then
     -- return with l_cost_price_rec.Is_Cst_Struc_updated set to 'Y'

    IF visit_rec.any_task_chg_flag = 'Y' THEN
            l_cost_price_rec.Is_Cst_Struc_updated :=  'Y';
    ELSE
            l_cost_price_rec.Is_Cst_Struc_updated :=  'N';


         -- If any task changed flag is 'N' then
         -- Check visit status
         -- When Visit is in 'PLANNING' status

         IF visit_rec.status_code = 'PLANNING' THEN

                 -- workorder created already
                 IF l_cost_price_rec.workorder_id is not null and
                      l_cost_price_rec.workorder_id <> FND_API.G_MISS_NUM THEN

                    l_cost_rollup_flag := 'Y';

                 END IF; -- Check for l_count

        ELSE -- Else for visit status
             -- When Visit is in 'RELEASED' status

             l_cost_rollup_flag := 'Y';

        END IF; -- Check for visit status

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'l_cost_rollup_flag =  ' || l_cost_rollup_flag );
        END IF;

        IF l_cost_rollup_flag ='Y' AND l_cost_price_rec.workorder_id is not null THEN

                     -- Check if MR Session and Cost Session ID
                     -- are present in Released status for Visit
                     IF l_MR_Session_Id IS NOT NULL AND l_cost_session_Id IS NOT NULL THEN

                         IF (l_log_statement >= l_log_current_level) THEN
                             fnd_log.string(l_log_statement,
                                            L_DEBUG_KEY,
                                            'Before calling Rollup_MR_Cost_Hierarchy API: ' );
                         END IF;

                        -- Call for Rollup_MR_Cost_Hierarchy API
                         Rollup_MR_Cost_Hierarchy
                         (
                            p_api_version            => p_api_version,
                            p_init_msg_list          => p_init_msg_list,
                            p_commit                 => p_commit,
                            p_visit_id               => l_visit_id,
                            p_MR_session_Id          => l_MR_session_Id,
                            p_Cost_Session_Id        => l_Cost_Session_Id,
                            x_return_status          => l_return_status
                          );

                         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                               RAISE Fnd_Api.G_EXC_ERROR;
                         END IF;

                         IF (l_log_statement >= l_log_current_level) THEN
                             fnd_log.string(l_log_statement,
                                             L_DEBUG_KEY,
                                             'After calling Rollup_MR_Cost_Hierarchy API, Return Status = ' || l_return_status ||
                                             'Visit Id : ' || l_visit_id );
                         END IF;

                    ELSE
                        -- Else for MR Session and Cost Session ID
                        -- are not present in Released Status for Visit

                        IF (l_log_statement >= l_log_current_level) THEN
                            fnd_log.string(l_log_statement,
                                           L_DEBUG_KEY,
                                           'Before calling Push_MR_Cost_Hierarchy API: ' );
                        END IF;

                     -- Call for Push_MR_Cost_Hierarchy API
                      Push_MR_Cost_Hierarchy
                       (
                            p_api_version            => p_api_version,
                            p_init_msg_list          => p_init_msg_list,
                            p_commit                 => p_commit,
                            p_validation_level       => p_validation_level,
                            p_visit_id               => l_visit_id,
                            x_MR_session_Id          => l_MR_session_Id,
                            x_Cost_Session_Id        => l_Cost_Session_Id,
                            x_return_status          => l_return_status
                        );

                        IF (l_log_statement >= l_log_current_level) THEN
                            fnd_log.string(l_log_statement,
                                           L_DEBUG_KEY,
                                           'After calling Push_MR_Cost_Hierarchy API, Return Status = ' || l_return_status ||
                                           'Visit Id : ' || l_visit_id  );
                        END IF;

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                               RAISE Fnd_Api.G_EXC_ERROR;
                        END IF;

                        IF (l_log_statement >= l_log_current_level) THEN
                            fnd_log.string(l_log_statement,
                                           L_DEBUG_KEY,
                                          'Before calling Rollup_MR_Cost_Hierarchy API: ' );
                        END IF;

                        -- Call for Rollup_MR_Cost_Hierarchy API
                          Rollup_MR_Cost_Hierarchy
                            (
                            p_api_version            => p_api_version,
                            p_init_msg_list          => p_init_msg_list,
                            p_commit                 => p_commit,
                            p_visit_id               => l_visit_id,
                            p_MR_session_Id          => l_MR_session_Id,
                            p_Cost_Session_Id        => l_Cost_Session_Id,
                            x_return_status          => l_return_status
                           );

                          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                               RAISE Fnd_Api.G_EXC_ERROR;
                          END IF;

                          IF (l_log_statement >= l_log_current_level) THEN
                              fnd_log.string(l_log_statement,
                                             L_DEBUG_KEY,
                                             'After calling Rollup_MR_Cost_Hierarchy API, Return Status = ' || l_return_status ||
                                             'Visit Id : '  || l_visit_id);
                          END IF;

                     END IF; -- Check for Session Ids

         END IF; -- l_cost_rollup_flag

    END IF;   -- visit_rec.any_task_chg_flag = 'Y'

     p_x_cost_price_rec.MR_Session_Id      :=  l_MR_Session_Id;
     p_x_cost_price_rec.Cost_Session_Id    :=  l_Cost_Session_Id;
     p_x_cost_price_rec.Is_Cst_Struc_updated := l_cost_price_rec.Is_Cst_Struc_updated;
     p_x_cost_price_rec.workorder_id := l_cost_price_rec.workorder_id;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    ------------------------End of API Body------------------------------------

   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                      'MR Session ID: ' || p_x_cost_price_rec.MR_Session_Id ||
                      'Cost Session ID: ' || p_x_cost_price_rec.Cost_Session_Id ||
                      'Is_Cst_Struc_updated flag: ' || p_x_cost_price_rec.Is_Cst_Struc_updated ||
                      'Work order ID: ' || p_x_cost_price_rec.workorder_id );
   END IF;

    ------------------------Terminate API Body------------------------------------
END Calculate_WO_Cost;



--------------------------------------------------------------------------
-- Procedure to disitnguish between various conditions mainly Visit status,
-- Session and Job existence for further calculation of actual and estimated cost
-- Called from estimate_visit_cost/estimate_MR_cost/estimate_task_cost
--------------------------------------------------------------------------
PROCEDURE Estimate_WO_Cost(
    p_api_version            IN            NUMBER    := 1.0,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_x_cost_price_rec       IN OUT        NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_price_rec_type,
    x_return_status          OUT           NOCOPY       VARCHAR2)
IS
   -- Define Local Variables

    l_visit_id         NUMBER;
    l_mr_Session_id    NUMBER := NULL;
    l_cost_session_id  NUMBER := NULL;

    l_return_status    VARCHAR2(1);

    l_cost_price_rec   AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type := p_x_cost_price_rec;

    L_API_NAME  CONSTANT VARCHAR2(30) := 'Estimate_WO_Cost';
    L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define Local Cursors
   -- To find task related information when its for a visit
    CURSOR c_task (x_T_id IN NUMBER) IS
      SELECT * FROM AHL_VISIT_TASKS_VL
      WHERE VISIT_TASK_ID = x_T_id;
    task_rec c_task%ROWTYPE;

BEGIN
 ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Value of Visit ID : ' || l_cost_price_rec.visit_id  ||
                        'Value of Cost Session ID : ' || l_cost_price_rec.cost_session_Id ||
                        'Value of MR Session ID : ' || l_cost_price_rec.MR_Session_Id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Estimate_WO_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_Visit_Id        := l_cost_price_rec.visit_Id;
     l_MR_Session_Id   := l_cost_price_rec.MR_Session_Id;
     l_Cost_Session_Id := l_cost_price_rec.Cost_Session_Id;

        -- Whether call for Calculate_WO_Cost is from Visit OR Task
         IF l_cost_price_rec.visit_task_id IS NOT NULL AND l_cost_price_rec.visit_task_id <> FND_API.G_MISS_NUM THEN

             -- Cursor for task related information in search task view
              OPEN c_task(l_cost_price_rec.visit_task_id);
              FETCH c_task INTO task_rec;
              CLOSE c_task;

             l_visit_id := task_rec.visit_id;
         END IF;

-- yazhou 25-Jul-2005 starts
-- push the cost structure ever time estimate cost button is clicked

   --push the cost structure if session id not present

--   IF l_MR_Session_Id IS NULL OR l_cost_session_Id IS NULL THEN

-- yazhou 25-Jul-2005 ends

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'Before calling Push_MR_Cost_Hierarchy API: ' );
             END IF;

             -- Call for Push_MR_Cost_Hierarchy API
              Push_MR_Cost_Hierarchy
               (
                    p_api_version            => p_api_version,
                    p_init_msg_list          => p_init_msg_list,
                    p_commit                 => p_commit,
                    p_validation_level       => p_validation_level,
                    p_visit_id               => l_visit_id,
                    x_MR_session_Id          => l_MR_session_Id,
                    x_Cost_Session_Id        => l_Cost_Session_Id,
                    x_return_status          => l_return_status
                );

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'After calling Push_MR_Cost_Hierarchy API, Return Status = ' || l_return_status );
             END IF;

             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN
                      RAISE Fnd_Api.G_EXC_ERROR;
             END IF;

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'Before calling Rollup_MR_Cost_Hierarchy API: ' );
             END IF;

-- yazhou 25-Jul-2005 starts


--   END IF; -- session id is null


-- yazhou 25-Jul-2005 ends

                 -- Call for Rollup_MR_Cost_Hierarchy API
                    Rollup_MR_Cost_Hierarchy
                    (
                        p_api_version            => p_api_version,
                        p_init_msg_list          => p_init_msg_list,
                        p_commit                 => p_commit,
                        p_visit_id               => l_visit_id,
                        p_MR_session_Id          => l_MR_session_Id,
                        p_Cost_Session_Id        => l_Cost_Session_Id,
                        x_return_status          => l_return_status
                    );

                 IF (l_log_statement >= l_log_current_level) THEN
                     fnd_log.string(l_log_statement,
                                    L_DEBUG_KEY,
                                    'After calling Rollup_MR_Cost_Hierarchy API, Return Status = ' || l_return_status);
                 END IF;

     -- Assign Is_Cst_Struc_updated to 'N'
     l_cost_price_rec.Is_Cst_Struc_updated :=  'N';

     -- Assign values to in-out rectype
     p_x_cost_price_rec.MR_Session_Id        :=  l_MR_Session_Id;
     p_x_cost_price_rec.Cost_Session_Id      :=  l_Cost_Session_Id;
     p_x_cost_price_rec.Is_Cst_Struc_updated :=  l_cost_price_rec.Is_Cst_Struc_updated;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    ------------------------End of API Body------------------------------------


     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                        'Value of Cost Session ID : ' || p_x_cost_price_rec.cost_session_Id ||
                        'Value of MR Session ID : ' || p_x_cost_price_rec.MR_Session_Id );
     END IF;


    ------------------------Terminate API Body------------------------------------
END Estimate_WO_Cost;



--------------------------------------------------------------------------
-- Procedure to find Visit/MR/Task actual and estimated costs in cost hierarchy table
--------------------------------------------------------------------------
PROCEDURE Get_WO_Cost(
    p_Session_Id        IN              NUMBER,
    p_Id                IN              NUMBER,
    p_program_id        IN              NUMBER,
    x_Actual_cost       OUT     NOCOPY	NUMBER,
    x_Estimated_cost    OUT     NOCOPY	NUMBER,
    x_return_status     OUT     NOCOPY	VARCHAR2  )
IS
    L_API_NAME  CONSTANT VARCHAR2(30) := 'Get_WO_Cost';
    L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

 -- Define Local Cursors
    CURSOR c_cost_csr(x_session_id IN NUMBER, x_id IN NUMBER, x_prg_id IN NUMBER) IS
     /*SELECT OBJECT_ID, SUM (ACTUAL_COST) ACTUAL_COST,
            SUM (ESTIMATED_COST) ESTIMATED_COST
      FROM AHL_VWP_ROLLUP_COSTS_V
     WHERE GROUP_ID = x_session_id
      AND OBJECT_ID = x_id
      AND PROGRAM_APPLICATION_ID = x_prg_id
     GROUP BY OBJECT_ID; */

     SELECT *
      FROM AHL_VWP_ROLLUP_COSTS_V
     WHERE GROUP_ID = x_session_id
      AND OBJECT_ID = x_id
      AND PROGRAM_APPLICATION_ID = x_prg_id;

     c_cost_csr_rec c_cost_csr%ROWTYPE;

BEGIN
 ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Value for Session ID : ' || p_Session_Id ||
                        'Value for Object ID : ' || p_id ||
                        'Value for Program Application ID : ' || p_program_id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Get_WO_Cost;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN c_cost_csr(p_session_id, p_id, p_program_id);
     FETCH c_cost_csr INTO c_cost_csr_rec;
     IF c_cost_csr%FOUND THEN
        x_actual_cost    := nvl(c_cost_csr_rec.actual_cost,0);
        x_estimated_cost := nvl(c_cost_csr_rec.estimated_cost,0);

     ELSE
        x_actual_cost    := 0;
        x_estimated_cost := 0;

     END IF;
     CLOSE c_cost_csr;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------End of API Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                        'Value for Actual Cost : ' || x_Actual_Cost ||
                        'Value for Estimated Cost : ' || x_Estimated_Cost );
     END IF;

     ------------------------Terminate API Body------------------------------------
END Get_WO_Cost;




--------------------------------------------------------------------------
-- Procedure to rollup costs of Visit/MR/Task from Costing table
-- 'CST_EAM_HIERARCHY_SNAPSHOT' and inserting in CST_EAM_ROLLUP_COSTS   --
--------------------------------------------------------------------------
PROCEDURE Rollup_MR_Cost_Hierarchy(
    p_api_version            IN              NUMBER    := 1.0,
    p_init_msg_list          IN              VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN              VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN              NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id               IN              NUMBER,
    p_MR_session_Id          IN              NUMBER,
    p_cost_session_id        IN              NUMBER,
    x_return_status          OUT     NOCOPY  VARCHAR2)
IS
  -- Define Local Variables
    l_cost_session_id   NUMBER;
    l_MR_session_id     NUMBER;
    l_msg_count         NUMBER;

    l_return_status     VARCHAR2(1);
    l_msg_data          VARCHAR2(2000);

-- yazhou 22Sept2005 starts
-- Bug fix#4617326
    l_entity_id_tab     CSTPECEP.wip_entity_id_type;
    l_index             NUMBER;

    L_API_NAME  CONSTANT VARCHAR2(30) := 'Rollup_MR_Cost_Hierarchy';
    L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

-- yazhou 22Sept2005 ends

  -- Define Local Cursors
  -- To find out all visit related details
    CURSOR c_visit_details (x_id IN NUMBER) IS
      SELECT * FROM AHL_VISITS_VL
      WHERE VISIT_ID = x_id;
    visit_rec  c_visit_details%ROWTYPE;

-- yazhou 22Sept2005 starts
-- yazhou 19Jun200 starts
-- Bug fix#5239507
-- Should not call Compute_Job_Estimate for closed workorders (status '12')

-- yazhou 27-Jun-2006 starts
-- fix for bug#5377347, to include cost of the canceled workorder (7-Cancelled)
-- Since one task may map to multiple canceled workorders, query for the latest one

  -- To find out all wip enities for the current visit
    CURSOR c_wip_jobs (x_id IN NUMBER) IS
      SELECT wip_entity_id
        FROM ahl_workorders
      WHERE visit_id = x_id AND STATUS_CODE NOT IN ('22','12');

-- yazhou 27-Jun-2006 ends

-- yazhou 19Jun200 ends

-- yazhou 22Sept2005 starts

    c_wip_jobs_rec c_wip_jobs%ROWTYPE;


BEGIN

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure.' ||
                        'Value of Cost Session ID : ' || p_cost_session_id ||
                        'Value of MR Session ID : ' || p_MR_session_id );
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Rollup_MR_Cost_Hierarchy;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     OPEN c_visit_details(p_visit_id);
     FETCH c_visit_details INTO visit_rec;
     CLOSE c_visit_details;

     -- Call for CST_EAMCOST_PUB.Delete_eamPerBal API
     -- To reset WIP_EAM_PERIOD_BALANCES for the work
     -- orders before calling the Work Order Cost Rollup API

-- yazhou 22Sept2005 starts
-- Bug fix#4617326

        l_index :=1;

        OPEN c_wip_jobs(p_visit_id);
        LOOP
        FETCH c_wip_jobs INTO c_wip_jobs_rec;
        EXIT WHEN c_wip_jobs%NOTFOUND;
          IF c_wip_jobs%FOUND THEN

             l_entity_id_tab(l_index) := c_wip_jobs_rec.wip_entity_id;
             l_index := l_index +1;
          END IF;

        END LOOP;
        CLOSE c_wip_jobs;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before Calling CST_EAMCOST_PUB.Delete_eamPerBal'  );
        END IF;

        CST_EAMCOST_PUB.Delete_eamPerBal (
                p_api_version       => 1.0,
                p_init_msg_list     => Fnd_Api.G_FALSE,
                p_commit            => Fnd_Api.G_FALSE,
                p_validation_level  => Fnd_Api.G_VALID_LEVEL_FULL,

                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data,

    	        p_entity_id_tab     => l_entity_id_tab,
    	        p_org_id            => visit_rec.organization_id,
                p_type              => 1);

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After Calling CST_EAMCOST_PUB.Delete_eamPerBal, Return Status = ' || l_return_status );
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'Errors from CST_EAMCOST_PUB.Delete_eamPerBal API -COST SESSION' || l_msg_count );
                END IF;

                RAISE Fnd_Api.g_exc_error;
        END IF;

-- yazhou 22Sept2005 ends

     -- Call for CST_EAMCOST_PUB.Compute_Job_Estimate API
     -- To generate the estimates for the work orders before
     -- calling the Work Order Cost Rollup API

        OPEN c_wip_jobs(p_visit_id);
        LOOP
        FETCH c_wip_jobs INTO c_wip_jobs_rec;
        EXIT WHEN c_wip_jobs%NOTFOUND;
          IF c_wip_jobs%FOUND THEN

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string(l_log_statement,
                                L_DEBUG_KEY,
                                'Before calling CST_EAMCOST_PUB.Compute_Job_Estimate' );
             END IF;

             CST_EAMCOST_PUB.Compute_Job_Estimate (
                p_api_version       => 1.0,
                p_init_msg_list     => Fnd_Api.G_FALSE,
                p_commit            => Fnd_Api.G_FALSE,
                p_validation_level  => Fnd_Api.G_VALID_LEVEL_FULL,
                p_debug             => 'N',
                p_wip_entity_id     => c_wip_jobs_rec.wip_entity_id,
                p_user_id           => fnd_global.user_id,
                p_request_id        => NULL,
                p_prog_id           => NULL,
                p_prog_app_id       => fnd_global.PROG_APPL_ID,
                p_login_id          => fnd_global.login_id,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

                IF (l_log_statement >= l_log_current_level) THEN
                    fnd_log.string(l_log_statement,
                                   L_DEBUG_KEY,
                                   'After calling CST_EAMCOST_PUB.Compute_Job_Estimate, Return Status = ' || l_return_status);
                END IF;

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                     IF (l_log_statement >= l_log_current_level) THEN
                         fnd_log.string(l_log_statement,
                                        L_DEBUG_KEY,
                                        'Errors from CST_EAMCOST_PUB.Delete_eamPerBal API -COST SESSION' || l_msg_count );
                     END IF;

                     CLOSE c_wip_jobs;
                     RAISE Fnd_Api.g_exc_error;
               END IF;

          END IF;

        END LOOP;
        CLOSE c_wip_jobs;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before Calling CST_EAMCOST_PUB.Rollup_WorkOrderCost-COST SESSION' );
     END IF;


     -- Call for CST_EAMCOST_PUB.Rollup_WorkOrderCost API
     -- FOR VISIT COST STRUCTURE
     -- To calculate the cumulative costs of each hierarchy node
     -- and populate the CST_EAM_ROLLUP_COSTS with that information.

     CST_EAMCOST_PUB.Rollup_WorkOrderCost
     (
        p_api_version            => 1.0,
        p_init_msg_list          => Fnd_Api.G_FALSE,
        p_commit                 => Fnd_Api.G_FALSE,
        p_group_id               => p_cost_session_id,
        p_organization_id        => visit_rec.organization_id,
        p_user_id                => Fnd_Global.USER_ID,
        p_prog_appl_id           => Fnd_Global.PROG_APPL_ID,
        x_return_status          => l_return_status

     );

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After Calling CST_EAMCOST_PUB.Rollup_WorkOrderCost-COST SESSION, Return Status = ' || l_return_status );
     END IF;


     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from CST_EAMCOST_PUB.Rollup_WorkOrderCosts API -COST SESSION' || l_msg_count );
       END IF;

       RAISE Fnd_Api.g_exc_error;
     ELSE
       FND_MSG_PUB.Initialize;
     END IF;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before Calling CST_EAMCOST_PUB.Rollup_WorkOrderCost-MR SESSION' );
     END IF;

     -- Call for CST_EAMCOST_PUB.Rollup_WorkOrderCost API
     -- FOR WORKORDER SCHEDULLING DEPENDENCIES
     -- To calculate the cumulative costs of each hierarchy node
     -- and populate the CST_EAM_ROLLUP_COSTS with that information.


     CST_EAMCOST_PUB.Rollup_WorkOrderCost
     (
        p_api_version            => 1.0,
        p_init_msg_list          => Fnd_Api.G_FALSE,
        p_commit                 => Fnd_Api.G_FALSE,
        p_group_id               => p_MR_session_id,
        p_organization_id        => visit_rec.organization_id,
        p_user_id                => Fnd_Global.USER_ID,
        p_prog_appl_id           => Fnd_Global.PROG_APPL_ID,
        x_return_status          => l_return_status

     );

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After Calling CST_EAMCOST_PUB.Rollup_WorkOrderCost-MR SESSION, Return Status = ' || l_return_status);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from CST_EAMCOST_PUB.Rollup_WorkOrderCosts API -MR SESSION' || l_msg_count);
       END IF;

       RAISE Fnd_Api.g_exc_error;
     ELSE
       FND_MSG_PUB.Initialize;
     END IF;

     ------------------------End of API Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status);
     END IF;

     --x_return_status := FND_API.G_RET_STS_SUCCESS;

     ------------------------Terminate API Body------------------------------------
END Rollup_MR_Cost_Hierarchy;


--------------------------------------------------------------------------
-- Procedure to push Visit/MR/Task Schedulling dependencies and
-- Cost Hierarchy structure by inserting in Costing tables              --
--------------------------------------------------------------------------
PROCEDURE Push_MR_Cost_Hierarchy(
    p_api_version            IN                 NUMBER    := 1.0,
    p_init_msg_list          IN                 VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN                 VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN                 NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id	             IN                 NUMBER,
    x_cost_session_id	     OUT         NOCOPY     NUMBER,
    x_MR_session_id          OUT         NOCOPY	    NUMBER,
    x_return_status          OUT         NOCOPY	    VARCHAR2 )
IS
--  Define Local Variables
    l_cost_session_id   NUMBER;
    l_MR_session_id     NUMBER;
    l_msg_count         NUMBER;

    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(1);

    L_API_NAME  CONSTANT VARCHAR2(30) := 'Push_MR_Cost_Hierarchy';
    L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
 ------------------------Initialize Body------------------------------------

     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.begin',
                        'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
     END IF;

     -- Standard start of API savepoint
     SAVEPOINT Push_MR_Cost_Hierarchy;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before Calling Create_WO_Cost_Structure: Value of Visit ID : ' || p_visit_id );
     END IF;

     -- Calling Create_WO_Cost_Structure API
     Create_WO_Cost_Structure
        (
            p_api_version            => 1.0,
            p_init_msg_list          => Fnd_Api.G_FALSE,
            p_commit                 => Fnd_Api.G_FALSE,
            p_validation_level       => Fnd_Api.G_VALID_LEVEL_FULL,
            p_visit_id               => p_visit_id,
            x_cost_session_id        => l_cost_session_id,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data
       );

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After Calling AHL_VWP_CST_WO_PVT.Create_WO_Cost_Structure, Return Status = ' || l_return_status);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from Create_WO_Cost_Structure API' || l_msg_count) ;
       END IF;

       RAISE Fnd_Api.g_exc_error;
     END IF;

      IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string(l_log_statement,
                         L_DEBUG_KEY,
                         'Before Calling AHL_VWP_CST_WO_PVT.Create_WO_Dependencies' );
      END IF;

      Create_WO_Dependencies
      (
        p_api_version            => 1.0,
        p_init_msg_list          => Fnd_Api.G_FALSE,
        p_commit                 => Fnd_Api.G_FALSE,
        p_validation_level       => Fnd_Api.G_VALID_LEVEL_FULL,
        p_visit_id               => p_visit_id,
        x_MR_session_id          => l_MR_session_id,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data
      );

     IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After Calling AHL_VWP_CST_WO_PVT.Create_WO_Dependencies, Return Status = '  || l_return_status);
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string(l_log_statement,
                          L_DEBUG_KEY,
                          'Errors from Create_WO_Dependencies API' || l_msg_count );
       END IF;

       RAISE Fnd_Api.g_exc_error;
     END IF;

     x_MR_session_id   := l_MR_session_id;
     x_cost_session_id := l_cost_session_id;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    ------------------------End of API Body------------------------------------
     IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL procedure. Return Status = ' || l_return_status ||
                        'x_MR_session_id  = ' || x_MR_session_id ||
                        'x_cost_session_id = '  || x_cost_session_id );
     END IF;

     ------------------------Terminate API Body------------------------------------
END Push_MR_Cost_Hierarchy;


---------------------------------------------------------------------------------
-- Procedure to calculate and get Visit/MR/Task actual and estimated profit/loss--
----------------------------------------------------------------------------------
PROCEDURE Get_Profit_or_Loss(
    p_actual_price      IN              NUMBER,
    p_estimated_price   IN              NUMBER,
    p_actual_cost       IN              NUMBER,
    p_estimated_cost    IN              NUMBER,
    x_actual_profit     OUT     NOCOPY  NUMBER,
    x_estimated_profit  OUT     NOCOPY  NUMBER,
    x_return_status     OUT     NOCOPY	VARCHAR2)
IS
    L_API_NAME  CONSTANT VARCHAR2(30) := 'Get_Profit_or_Loss';
    L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
 ------------------------Initialize Body------------------------------------

    IF (l_log_procedure >= l_log_current_level) THEN
        fnd_log.string(l_log_procedure,
                       L_DEBUG_KEY ||'.begin',
                       'At the start of PL SQL procedure.' ||
                       'Actual Price : ' || p_actual_price || '***' || 'Actual Cost : ' || p_actual_cost ||
                       'Estimated Price : ' || p_estimated_price || '***' || 'Actual Price : ' || p_actual_price );
    END IF;

     -- Standard start of API savepoint
    SAVEPOINT Get_Profit_or_Loss;

     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_actual_price IS NOT NULL AND p_actual_cost IS NOT NULL THEN
           x_actual_profit := p_actual_price - p_actual_cost;
    ELSE
           x_actual_profit := NULL;
    END IF;

    IF p_estimated_price IS NOT NULL AND p_estimated_cost IS NOT NULL THEN
           x_estimated_profit := p_estimated_price - p_estimated_cost;
    ELSE
           x_estimated_profit := NULL;
    END IF;

    ------------------------End of API Body------------------------------------
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                      'Actual Profit : ' || x_actual_profit ||
                      'Estimated Profit : ' || x_estimated_profit );
   END IF;

    --x_return_status := FND_API.G_RET_STS_SUCCESS;

    ------------------------Terminate API Body------------------------------------
END Get_Profit_or_Loss;

----------------------------------------------------------------------
-- END: Defining procedures BODY                                    --
----------------------------------------------------------------------

END AHL_VWP_COST_PVT;

/
