--------------------------------------------------------
--  DDL for Package Body AHL_LTP_ASCP_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_ASCP_ORDERS_PVT" AS
/* $Header: AHLSCMRB.pls 115.3 2004/01/29 00:05:59 ssurapan noship $*/
--
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_ASCP_ORDERS_PVT';
-- Start of Comments --
--  Procedure name    : Update_Sheduling_Results
--  Type        : Public
--  Function    : This procedure Updates Scheduled Materials table with scheduled date
--                from APS
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Update_Scheduling_Results :
--
--
--
PROCEDURE Update_Scheduling_Results (
   p_api_version             IN    NUMBER    := 1.0,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_sched_Orders_Tbl        IN    Sched_Orders_Tbl,
   x_return_status              OUT NOCOPY VARCHAR2)
   IS

   CURSOR Check_Sched_Mat_Cur(c_sch_mat_id    IN NUMBER)
       IS
	 SELECT 1 FROM ahl_schedule_materials
	  WHERE scheduled_material_id = c_sch_mat_id;

  --Standard local variables
  l_api_name        CONSTANT VARCHAR2(30) := 'Update_Scheduling_Results';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_return_status          VARCHAR2(1);
  l_msg_data               VARCHAR2(2000);
  l_msg_count              NUMBER;
  l_dummy                  NUMBER;
   BEGIN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_ASCP_ORDERS_PVT.Update_Scheduling_Results.begin',
			'At the start of PLSQL procedure'
		);
    END IF;
    -- Standard Start of API savepoint
    SAVEPOINT Update_Scheduling_Results;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
     END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to check for call compatibility.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
			'Request for Update Scheduled Sales Orders Number of Records : ' || p_sched_Orders_tbl.COUNT
		);

     END IF;


	  IF p_sched_Orders_tbl.COUNT > 0 THEN
	     FOR i IN p_sched_Orders_tbl.FIRST..p_sched_Orders_tbl.LAST
		 LOOP
		     -- Check for record exists in schedule materials
			  IF p_sched_Orders_tbl(i).order_line_id IS NOT NULL THEN
			    OPEN Check_Sched_Mat_Cur(p_sched_Orders_tbl(i).order_line_id);
				FETCH Check_Sched_Mat_Cur INTO l_dummy;
				IF Check_Sched_Mat_Cur%FOUND THEN
		            UPDATE AHL_SCHEDULE_MATERIALS
					   SET scheduled_date = p_sched_Orders_tbl(i).schedule_ship_date,
					       scheduled_quantity = p_sched_Orders_tbl(i).Quantity_By_Due_Date,
					       object_version_number = object_version_number + 1
   			         WHERE scheduled_material_id = p_sched_Orders_tbl(i).order_line_id;
                 END IF;
				 CLOSE Check_Sched_Mat_Cur;
		         END IF;
		 END LOOP;
	  END IF;

      --Standard check to count messages
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Standard check of p_commit
     IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_LTP_ASCP_ORDERS_PVT.Update_Scheduling_Results.end',
			'At the end of PLSQL procedure'
		);
     END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_Scheduling_Results;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Update_Scheduling_Results;
       X_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO Update_Scheduling_Results;
       X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_ASCP_ORDERS_PVT',
                               p_procedure_name  =>  'UPDATE_SCHEDULING_RESULTS',
                               p_error_text      => SUBSTR(SQLERRM,1,240));
       END IF;
       FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);


   END Update_Scheduling_Results;


END AHL_LTP_ASCP_ORDERS_PVT;

/
