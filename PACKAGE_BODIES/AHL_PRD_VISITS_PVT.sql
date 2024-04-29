--------------------------------------------------------
--  DDL for Package Body AHL_PRD_VISITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_VISITS_PVT" AS
 /* $Header: AHLVPSVB.pls 120.0.12010000.2 2010/01/08 11:20:35 snarkhed ship $*/
-----------------------------------------------------------------------
-- PACKAGE
--    AHL_PRD_VISITS_PVT
--
-- PURPOSE
--    This package body is a Private API for managing PRD Visit procedures
--    in Complex Maintainance, Repair and Overhauling(CMRO).
--    It defines global constants, various local functions and procedures.
--
-- PROCEDURES
--       Get_Visit_Details
--       Get_Unit_Name
--
-- NOTES
--
--
-- HISTORY
-- 30-APR-2004    RROY      Created.
-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AHL_PRD_VISIT_PVT';
G_DEBUG 		        VARCHAR2(1)  := AHL_DEBUG_PUB.is_log_enabled;

--  To find out Due_by_Date for the visit update screen.
PROCEDURE Get_Due_by_Date(
   p_visit_id         IN    NUMBER,
   x_Due_by_Date      OUT   NOCOPY DATE
);


-------------------------------------------------------------------
-- PROCEDURE
--    Get_Due_by_Date
--
-- PURPOSE
--    To find out least due by date among all tasks of a visit
--------------------------------------------------------------------



PROCEDURE Get_Due_by_Date(
   p_visit_id         IN    NUMBER,
   x_due_by_date      OUT  NOCOPY  DATE)
IS
   -- Define local variables
   l_count1 NUMBER;
   l_count2 NUMBER;
   l_date  DATE;

   -- Define local Cursors
   -- To find whether a visit exists
   CURSOR c_visit (x_id IN NUMBER) IS
      SELECT COUNT(*)
      FROM Ahl_Visit_Tasks_B
      WHERE VISIT_ID = x_id
      AND NVL(STATUS_CODE,'X') <> 'DELETED';

   -- To find the total number of tasks for a visit
   CURSOR c_visit_task (x_id IN NUMBER) IS
      SELECT COUNT(*)
      FROM Ahl_Visit_Tasks_B
      WHERE VISIT_ID = x_id
      AND UNIT_EFFECTIVITY_ID IS NOT NULL
      AND NVL(STATUS_CODE,'X') <> 'DELETED';

  -- To find due date for a visit related with tasks
   CURSOR c_due_date (x_id IN NUMBER) IS
     SELECT MIN(T1.due_date)
     FROM ahl_unit_effectivities_vl T1, ahl_visit_tasks_b T2
     WHERE T1.unit_effectivity_id = T2.unit_effectivity_id
     AND T1.due_date IS NOT NULL AND T2.visit_id = x_id;

BEGIN

      OPEN c_visit(p_visit_id);
      FETCH c_visit INTO l_count1;
      IF c_visit%FOUND THEN         --Tasks found for visit
            CLOSE c_visit;

            OPEN c_visit_task(p_visit_id);
            FETCH c_visit_task INTO l_count2;
            IF c_visit_task%FOUND THEN  --Tasks found for visit checking for unit_effectivity_id
                CLOSE c_visit_task;
                OPEN c_due_date(p_visit_id);
                FETCH c_due_date INTO x_due_by_date;
                  IF c_due_date%FOUND THEN     --Tasks found for visit
                        CLOSE c_due_date;
                  END IF;
            ELSE
                CLOSE c_visit_task;
            END IF;

      ELSE
           CLOSE c_visit;
      END IF;
      RETURN;
END Get_Due_by_Date;

-----------------------------------------------------------------------
-- PROCEDURE
--  get_unitName
--
-- PURPOSE
--  Function to get unit configuration name for a given item instance.
-----------------------------------------------------------------------
FUNCTION Get_UnitName (p_csi_item_instance_id  IN  NUMBER)
RETURN VARCHAR2
IS
  -- Define local Cursors
  -- Get unit name for component.
  CURSOR get_unit_name_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT name
    FROM ahl_unit_config_headers uc
    WHERE csi_item_instance_id in ( SELECT object_id
                                    FROM csi_ii_relationships
                                    START WITH object_id = p_csi_item_instance_id
                                    AND relationship_type_code = 'COMPONENT-OF'
                                    CONNECT BY PRIOR subject_id = object_id
                                    AND relationship_type_code = 'COMPONENT-OF'
                                  )
          and unit_config_status_code = 'COMPLETE'
          and (active_end_date is null or active_end_date > sysdate);

  -- For top node.
  CURSOR get_unit_name_csr1 (p_csi_item_instance_id IN NUMBER) IS
  SELECT name
    FROM ahl_unit_config_headers uc
    WHERE csi_item_instance_id = p_csi_item_instance_id
    and unit_config_status_code = 'COMPLETE' and (active_end_date is null or active_end_date > sysdate);

  l_name  ahl_unit_config_headers.name%TYPE;

BEGIN
  --Check for top node.
  OPEN get_unit_name_csr1(p_csi_item_instance_id);
  FETCH get_unit_name_csr1 INTO l_name;
  IF (get_unit_name_csr1%NOTFOUND) THEN

     -- Check for component.
     OPEN get_unit_name_csr(p_csi_item_instance_id);
     FETCH get_unit_name_csr INTO l_name;
     IF (get_unit_name_csr%NOTFOUND) THEN
        l_name := null;
     END IF;
     CLOSE get_unit_name_csr;

  END IF;
  CLOSE get_unit_name_csr1;
  RETURN l_name;
END get_unitName;


--------------------------------------------------------------------
-- PROCEDURE
--    Get_Visit_Details
--
-- PURPOSE
--    Get a particular Visit Records with all details
--------------------------------------------------------------------
PROCEDURE Get_Visit_Details (
   p_api_version             IN   NUMBER,
   p_init_msg_list           IN   VARCHAR2  := Fnd_Api.g_false,
   p_commit                  IN   VARCHAR2  := Fnd_Api.g_false,
   p_validation_level        IN   NUMBER    := Fnd_Api.g_valid_level_full,
   p_module_type             IN   VARCHAR2  := 'JSP',
   p_visit_id                IN   NUMBER,

   x_Visit_rec               OUT  NOCOPY Visit_Rec_Type,
   x_return_status           OUT  NOCOPY VARCHAR2,
   x_msg_count               OUT  NOCOPY NUMBER,
   x_msg_data                OUT  NOCOPY VARCHAR2
)
IS
  -- Define local Variables
   L_API_VERSION          CONSTANT NUMBER := 1.0;
   L_API_NAME             CONSTANT VARCHAR2(30) := 'Get_Visit_Details';
   L_FULL_NAME            CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || L_API_NAME;

   l_msg_data             VARCHAR2(2000);
   l_project_flag         VARCHAR2(80);
   l_simulation_plan_name VARCHAR2(80);
   l_unit_name            VARCHAR2(80);
   l_hour                 VARCHAR2(30);
   l_hour_close           VARCHAR2(30);
   l_default              VARCHAR2(30);
   l_proj_temp_name       VARCHAR2(30);
   l_return_status        VARCHAR2(1);
   l_valid_flag           VARCHAR2(1);

   l_visit_id             NUMBER:= p_visit_id;
   l_count                NUMBER;
   l_duration             NUMBER;
   l_visit_end_hour       NUMBER;
   l_proj_temp_id         NUMBER;
   l_workorder_id         NUMBER;
   i                      NUMBER;
   x                      NUMBER;

   l_due_date             DATE;
   x_due_by_date          DATE;
   l_workorder_name 	  VARCHAR2(80); -- Added in 11.5.10

 -- Define local record datatypes
   l_visit_rec          Visit_Rec_Type;

   -- Define local cursors
   -- To find out required search visit details
    CURSOR c_visit (x_id IN NUMBER) IS
      SELECT * FROM AHL_PRD_VISITS_V
      WHERE VISIT_ID = x_id;
    c_visit_rec c_visit%ROWTYPE;

  -- To find out all visit/template details
    CURSOR c_visit_details (x_id IN NUMBER) IS
      SELECT * FROM AHL_VISITS_VL
      WHERE VISIT_ID = x_id;
    visit_rec  c_visit_details%ROWTYPE;

  -- Cursor to find master workorder name for the given visit
    CURSOR c_workorder_csr (x_id IN NUMBER) IS
      SELECT WORKORDER_NAME, WORKORDER_ID FROM AHL_WORKORDERS
      WHERE MASTER_WORKORDER_FLAG = 'Y' AND VISIT_ID = x_id;

 -- CURSOR added to get the Project Template Name
 -- Post 11.5.10
 CURSOR c_proj_template(p_proj_temp_id IN NUMBER)
  IS
    SELECT name
    FROM PA_PROJECTS
    WHERE project_id = p_proj_temp_id;
 BEGIN
   -------------------------------- Initialize -----------------------
   -- Standard start of API savepoint
   SAVEPOINT Get_Visit_Details;

   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.enable_debug;
   END IF;

   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.Debug( 'Get Visit Details' ||': Start');
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_boolean(p_init_msg_list)
   THEN
     Fnd_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;
   ------------------------------Start of API Body------------------------------------

   ----------------------------------------- Cursor ----------------------------------
   OPEN c_visit_details(p_visit_id);
       FETCH c_visit_details INTO visit_rec;
   CLOSE c_visit_details;

   OPEN c_Visit(p_visit_id);
       FETCH c_visit INTO c_visit_rec;
   CLOSE c_Visit;

  ------------------------------------------ Start -----------------------------------
     -- Debug info.
    IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.Debug( 'Visit Id= ' || p_visit_id);
    END IF;

   -- get workorder name and Id added in 11.5.10
   OPEN c_workorder_csr(p_visit_id);
   FETCH c_workorder_csr INTO l_workorder_name, l_workorder_id;

   IF c_workorder_csr%FOUND THEN
     l_visit_rec.job_number := l_workorder_name;
     --l_visit_rec.workorder_id := l_workorder_id;
   END IF;
   CLOSE c_workorder_csr;

    -- To find meaning for fnd_lookups code
    IF (visit_rec.project_flag IS NOT NULL) THEN
          SELECT meaning
              INTO l_project_flag
            FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_code = visit_rec.project_flag
          AND LOOKUP_TYPE = 'AHL_YES_NO_TYPE';
    END IF;

   ----------------------------------- FOR VISITS --------------------------------------
    --IF UPPER(c_visit_rec.template_flag) = 'N' THEN
      -- To find Unit Name on basis of Instance Id
        IF visit_rec.item_instance_id IS NOT NULL THEN
               AHL_DEBUG_PUB.Debug(L_FULL_NAME || 'UNIT NAME - item instance' || visit_rec.item_instance_id);
           -- Call Get_UnitName to get unit name for a particular instance_id
	   --  Fix for Bug #9260723
	   --  Now getting Unit Name from AHL_UTILITY_PVT.Get_Unit_Name instead of local function
	   --  Get_UnitName.
               l_unit_name := AHL_UTILITY_PVT.Get_Unit_Name(visit_rec.item_instance_id);
               AHL_DEBUG_PUB.Debug(L_FULL_NAME || 'UNIT NAME - l_unit_name' || l_unit_name);

           -- Compare unit name entered from unit name derived
               IF l_unit_name IS NOT NULL THEN
                  l_unit_name := l_unit_name;
               ELSE
                  l_unit_name := Null;
               END IF;
        END IF;

       -- To find simulation plan name for the simulation id from LTP view
        /*IF (visit_rec.simulation_plan_id IS NOT NULL) THEN
             SELECT SIMULATION_PLAN_NAME
              INTO l_simulation_plan_name
            FROM AHL_SIMULATION_PLANS_VL
          WHERE SIMULATION_PLAN_ID = visit_rec.simulation_plan_id;
        ELSE
              l_simulation_plan_name := NULL;
        END IF;*/

	-- Post 11.5.10
	-- Added l_min and l_min_close
	-- Reema Start
        -- To check if visit starttime is not null then store time in HH4 format
        IF (c_visit_rec.START_DATE_TIME IS NOT NULL AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN
            l_hour := TO_NUMBER(TO_CHAR(c_visit_rec.START_DATE_TIME , 'HH24'));
        ELSE
            l_hour := NULL;
            c_visit_rec.START_DATE_TIME := NULL;
        END IF;

        -- To check if visit closetime is not null then store time in HH4 format
        IF (visit_rec.CLOSE_DATE_TIME IS NOT NULL AND visit_rec.CLOSE_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN
            l_hour_close := TO_NUMBER(TO_CHAR(visit_rec.CLOSE_DATE_TIME , 'HH24'));
        ELSE
            l_hour_close := NULL;
            visit_rec.CLOSE_DATE_TIME := Null;
        END IF;

        -- Call local procedure to retrieve Due by Date of the visit
    	Get_Due_by_Date(p_visit_id => l_visit_id, x_due_by_date  => l_due_date);


       IF (c_visit_rec.START_DATE_TIME IS NOT NULL
       AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE) THEN



       --END IF;

       -- Post 11.5.10
       -- get the project template name from cursor
       IF visit_rec.project_template_id IS NOT NULL THEN
       OPEN c_proj_template(visit_rec.project_template_id);
       FETCH c_proj_template INTO l_visit_rec.proj_template_name;
       IF c_proj_template%NOTFOUND THEN
         IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          	Fnd_Message.SET_NAME('AHL','AHL_VWP_INVALID_PROTEM');
		Fnd_Msg_Pub.ADD;
		RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
       END IF;
       CLOSE c_proj_template;
       END IF;

    -- Assigning all visits field to visit record attributes meant for display
	l_visit_rec.visit_id		      :=  c_visit_rec.visit_id ;
	l_visit_rec.visit_name		      :=  c_visit_rec.visit_name ;
	l_visit_rec.visit_number	      :=  c_visit_rec.visit_number ;

    l_visit_rec.status_code           :=  c_visit_rec.status_code;
    l_visit_rec.status_name           :=  c_visit_rec.status;

    l_visit_rec.visit_type_code	      :=  c_visit_rec.visit_type_code ;
	l_visit_rec.visit_type_name       :=  c_visit_rec.VISIT_TYPE ;

    l_visit_rec.object_version_number :=  c_visit_rec.object_version_number ;

    l_visit_rec.inventory_item_id     :=  c_visit_rec.inventory_item_id ;
	l_visit_rec.item_organization_id  :=  c_visit_rec.item_organization_id ;
	l_visit_rec.item_name             :=  c_visit_rec.ITEM_DESCRIPTION ;

    l_visit_rec.unit_name             :=  l_unit_name ;
    l_visit_rec.item_instance_id      :=  c_visit_rec.item_instance_id ;
	l_visit_rec.serial_number         :=  c_visit_rec.serial_number ;

   -- l_visit_rec.service_request_id    :=  c_visit_rec.service_request_id;
   -- l_visit_rec.service_request_number:=  c_visit_rec.incident_number;

   -- l_visit_rec.space_category_code   :=  c_visit_rec.space_category_code;
   -- l_visit_rec.space_category_name   :=  c_visit_rec.space_category_mean;

	l_visit_rec.organization_id       :=  c_visit_rec.organization_id ;
	l_visit_rec.org_name              :=  c_visit_rec.ORGANIZATION_NAME ;

	l_visit_rec.department_id         :=  c_visit_rec.department_id  ;
	l_visit_rec.dept_name             :=  c_visit_rec.DEPARTMENT_NAME ;


    l_visit_rec.start_date            :=  c_visit_rec.START_DATE_TIME;
    l_visit_rec.start_hour            :=  l_hour;

    l_visit_rec.PLAN_END_DATE         :=  visit_rec.CLOSE_DATE_TIME;
    l_visit_rec.PLAN_END_HOUR         :=  l_hour_close;

	l_visit_rec.project_flag	      :=  l_project_flag;
	l_visit_rec.project_flag_code     :=  visit_rec.project_flag;

  	l_visit_rec.end_date  := AHL_VWP_TIMES_PVT.get_visit_end_time(c_visit_rec.visit_id);
	l_visit_rec.due_by_date	          :=  l_due_date ;
	l_visit_rec.duration	          :=  NULL ;

--	l_visit_rec.simulation_plan_id    :=  visit_rec.simulation_plan_id  ;
--	l_visit_rec.simulation_plan_name  :=  l_simulation_plan_name ;

--	l_visit_rec.template_flag         :=  c_visit_rec.template_flag ;
	l_visit_rec.description           :=  visit_rec.description ;
        l_visit_rec.last_update_date      :=  visit_rec.last_update_date;

  	l_visit_rec.project_id            :=  visit_rec.project_id;
	l_visit_rec.project_number        :=  visit_rec.visit_number;
	l_visit_rec.outside_party_flag	  :=  visit_rec.outside_party_flag;

	-- Post 11.5.10
	-- Reema Start
	l_visit_rec.priority_code         := visit_rec.priority_code;
	l_visit_rec.proj_template_id      := visit_rec.project_template_id;
--	l_visit_rec.priority_value        := c_visit_rec.priority_mean;
	-- Reema End
    x_visit_rec := l_visit_rec;
END IF;

IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.Debug( l_full_name ||': End of Get Visit Details**********************');
END IF;

------------------------End of API Body------------------------------------
    -- Standard call to get message count and if count is 1, get message info
    Fnd_Msg_Pub.Count_And_Get
        ( p_count => x_msg_count,
        p_data  => x_msg_data,
        p_encoded => Fnd_Api.g_false);

    -- Check if API is called in debug mode. If yes, enable debug.
    IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.enable_debug;
    END IF;

    -- Debug info.
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.Debug( 'AHL_VWP_VISITS_PVT - End');
    END IF;

   -- Check if API is called in debug mode. If yes, disable debug.
    IF G_DEBUG='Y' THEN
    Ahl_Debug_Pub.disable_debug;
	END IF;
    RETURN;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   ROLLBACK TO Get_Visit_Details;
   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => Fnd_Api.g_false);


 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   ROLLBACK TO Get_Visit_Details;
   Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO Get_Visit_Details;
    Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => 'Get_Visit_Details',
                             p_error_text     => SQLERRM);

    Fnd_Msg_Pub.count_and_get( p_count   => x_msg_count,
                               p_data    => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
END Get_Visit_Details;



----------------------------------------------------------------------
-- END: Defining procedures BODY, which are called from UI screen --
----------------------------------------------------------------------

END AHL_PRD_VISITS_PVT;

/
