--------------------------------------------------------
--  DDL for Package Body AHL_VWP_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_RULES_PVT" AS
/* $Header: AHLVRULB.pls 120.13.12010000.5 2010/02/01 05:15:31 skpathak ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_RULES_PVT
--
-- PURPOSE
--    This package body is a Private API for managing VWP Visit and Tasks
--    general utilities procedures in Complex Maintainance, Repair and Overhauling(CMRO).
--    It defines few global constants, various local functions and procedures
--    used by other Visit Work Package(VWP) APIs
--
-- PROCEDURES
--    Check_Serial_No_by_UConfig    -- Check_Item_name_Or_Id
--    Check_Serial_Name_Or_Id       -- Check_Lookup_name_Or_Id
--    Check_Org_Name_Or_Id          -- Check_Dept_Desc_Or_Id
--    Check_Visit_is_Simulated      -- Check_Unit_Name_Valid
--    Check_Stage_Number_Or_Id      -- Check_SR_request_number_Or_Id
--    Check_Visit_Task_Number_Or_Id -- Check_Project_Template_Or_Id
--    Check_Proj_Responsibility     -- Check_Cost_Parent_Loop
--    Check_Origin_Task_Loop        -- Check_Price_List_Name_Or_Id

--    Validate_bef_Times_Derive     -- Insert_Task
--    Create_Tasks_for_MR           -- Tech_Dependency

--    Get_Visit_Task_Id             -- Get_Visit_Task_Number
--    Get_Serial_Item_by_Unit       -- Get_Cost_Originating_Id
--    Get_Summary_Task_Time         --
--
--    Update_Cost_Origin_Task       -- Update_Visit_Task_Flag
--    Merge_for_Unique_Items        -- Merge_for_Unique_Items
--
-- NOTES
--
-- HISTORY
-- 03-MAR-2003  SHBHANDA  Created.
-- 06-AUG-2003  SHBHANDA  11.5.10 Changes.
-- 09-12-2003   RTADIKON  Merge_for_Unique_Items Coded for costing 11.5.10
--                        Along with the logging mechanism.
-- 05-NOV-2007  RNAHATA   Replaced all Ahl_Debug_Pub.debug with STATEMENT
--                        level logs and added more STATEMENT level logs at
--                        key decision points. Added PROCEDURE level logs
--                        when entering and exiting a procedure.
-----------------------------------------------------------------

-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
G_APP_NAME        CONSTANT VARCHAR2(3)  := 'AHL';
G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AHL_VWP_RULES_PVT';
G_OPER_ASSOC_TYPE CONSTANT VARCHAR2(30) := 'OPERATION';
G_RT_ASSOC_TYPE   CONSTANT VARCHAR2(30) := 'ROUTE';
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level   NUMBER   := fnd_log.g_current_runtime_level;
l_log_statement       NUMBER   := fnd_log.level_statement;
l_log_procedure       NUMBER   := fnd_log.level_procedure;
l_log_error           NUMBER   := fnd_log.level_error;
l_log_unexpected      NUMBER   := fnd_log.level_unexpected;
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
--  Serial record type for validating serial exists in unit-config tree of the visit
TYPE Serial_Rec_Type IS RECORD
   (INSTANCE_ID          NUMBER,
    SERIAL_NUMBER        VARCHAR2(30));

---------------------------------------------------------------------
-- Define Table Types for table structures of records needed by the APIs --
---------------------------------------------------------------------
--  Table type for storing 'Serial_Rec_Type' record datatype
TYPE Serial_Tbl_Type IS TABLE OF Serial_Rec_Type
   INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------
-- Define local procedures signature                              --
--------------------------------------------------------------------

--------------------------------------------------------------------
-- Define local functions signature                               --
--------------------------------------------------------------------

--------------------------------------------------------------------
-- Define local procedures body                                   --
--------------------------------------------------------------------
-----------------------------------------------------------------------
-- FUNCTION
--    instance_in_config_tree
--
-- PURPOSE
--    Check whether p_instance_id belongs to the instance of p_visit_id
--    Return 'Y' for the following cases:
--      1. p_visit_id doesn't have instance_id associated at all
--      2. The instance_id of p_visit_id = p_instance_id regardless whether
--         the instance of p_visit_id has components or not
--      3. p_instance_id is a component of the instance of p_visit_id regardless
--         whether it is a UC tree or IB tree
--    Return 'N' otherwise
-----------------------------------------------------------------------
FUNCTION instance_in_config_tree(p_visit_id NUMBER, p_instance_id NUMBER) RETURN VARCHAR2
IS
  l_instance_id        NUMBER;
  l_visit_instance_id  NUMBER;
  L_API_NAME    CONSTANT VARCHAR2(30)  := 'instance_in_config_tree';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  CURSOR get_visit_instance IS
    SELECT item_instance_id
      FROM ahl_visits_b
     WHERE visit_id = p_visit_id;
  CURSOR check_instance_in_tree(c_top_instance_id NUMBER, c_instance_id NUMBER) IS
    SELECT subject_id
      FROM csi_ii_relationships
     WHERE subject_id = c_instance_id
START WITH object_id = c_top_instance_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE)
CONNECT BY object_id = PRIOR subject_id
       AND relationship_type_code = 'COMPONENT-OF'
       AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
       AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL function. Visit Id = ' || p_visit_id ||
                    ', p_instance_id = ' || p_instance_id);
  END IF;
  OPEN get_visit_instance;
  FETCH get_visit_instance INTO l_visit_instance_id;
  -- Added additional or condition by senthil as the Visit Instance Id can be null.
  IF get_visit_instance%NOTFOUND OR l_visit_instance_id is NULL THEN
     CLOSE get_visit_instance;
     RETURN FND_API.G_RET_STS_SUCCESS;
  ELSE
     CLOSE get_visit_instance;
     IF l_visit_instance_id = p_instance_id THEN
        RETURN FND_API.G_RET_STS_SUCCESS;
     ELSE
        OPEN check_instance_in_tree(l_visit_instance_id, p_instance_id);
        FETCH check_instance_in_tree INTO l_instance_id;
        IF check_instance_in_tree%FOUND THEN
           CLOSE check_instance_in_tree;
           RETURN FND_API.G_RET_STS_SUCCESS;
        ELSE
           CLOSE check_instance_in_tree;
           RETURN FND_API.G_RET_STS_ERROR;
        END IF;
     END IF;
  END IF;
END;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Item_Name_OR_Id
--
-- PURPOSE
--    Converts Item Name and Inventory Org to Inventory Item Id
--------------------------------------------------------------------
PROCEDURE Check_Item_Name_Or_Id
    (p_item_id              IN NUMBER,
     p_org_id               IN NUMBER,
     p_item_name            IN VARCHAR2,

     x_item_id              OUT NOCOPY NUMBER,
     x_org_id               OUT NOCOPY NUMBER,
     x_item_name            OUT NOCOPY VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_error_msg_code       OUT NOCOPY VARCHAR2
     )
IS
  -- Define local variables
  L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Item_Name_Or_Id';
  L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Item Id = ' ||
                     p_item_id || ', Item Name = ' || p_item_name || ', Org Id = ' || p_org_id);
   END IF;

   IF p_org_id IS NOT NULL THEN
      IF p_item_name IS NOT NULL THEN
         -- SELECT concatenated_segments, inventory_item_id, inventory_org_id
         -- INTO x_item_name, x_item_id, x_org_id
         -- FROM AHL_MTL_ITEMS_OU_V
         -- WHERE concatenated_segments = p_item_name AND inventory_org_id = p_org_id;

         -- Fix for ADS bug# 4357001.
         -- AnRaj:Changes made for fixing bug#4919353, issue# 1
         /* SELECT concatenated_segments, inventory_item_id, organization_id
         INTO x_item_name, x_item_id, x_org_id
         FROM MTL_SYSTEM_ITEMS_KFV
         WHERE concatenated_segments = p_item_name AND organization_id = p_org_id
         AND organization_id IN (Select DISTINCT m.master_organization_id
                                 FROM org_organization_definitions org, mtl_parameters m
                                 WHERE org.organization_id = m.organization_id
                                 AND NVL(org.operating_unit, mo_global.get_current_org_id())
                                 = mo_global.get_current_org_id()
                                );*/

        SELECT concatenated_segments, inventory_item_id, organization_id
        INTO x_item_name, x_item_id, x_org_id
        FROM MTL_SYSTEM_ITEMS_KFV
        WHERE concatenated_segments = p_item_name
        AND organization_id = p_org_id
        AND organization_id IN
            (SELECT DISTINCT m.master_organization_id
             FROM INV_ORGANIZATION_INFO_V org,
                  mtl_parameters m
              WHERE org.organization_id = m.organization_id
              AND NVL(org.operating_unit,mo_global.get_current_org_id()) = mo_global.get_current_org_id()
            ) ;
      ELSIF p_item_id IS NOT NULL THEN
         -- SELECT concatenated_segments, inventory_item_id, inventory_org_id
         -- INTO x_item_name, x_item_id, x_org_id
         -- FROM AHL_MTL_ITEMS_OU_V
         -- WHERE inventory_item_id = p_item_id AND inventory_org_id = p_org_id;

         -- Fix for ADS bug# 4357001.
         /* SELECT concatenated_segments, inventory_item_id, organization_id
         INTO x_item_name, x_item_id, x_org_id
         FROM MTL_SYSTEM_ITEMS_KFV
         WHERE inventory_item_id = p_item_id AND organization_id = p_org_id
         AND organization_id IN (Select DISTINCT m.master_organization_id
                                 FROM org_organization_definitions org, mtl_parameters m
                                 WHERE org.organization_id = m.organization_id
                                 AND NVL(org.operating_unit, mo_global.get_current_org_id())
                                 = mo_global.get_current_org_id()
                                ); */
         -- AnRaj: Changes made for fixing bug#4919353
         SELECT concatenated_segments, inventory_item_id, organization_id
         INTO x_item_name, x_item_id, x_org_id
         FROM MTL_SYSTEM_ITEMS_KFV
         WHERE inventory_item_id = p_item_id AND organization_id = p_org_id
         AND organization_id IN (Select DISTINCT m.master_organization_id
                                 FROM inv_organization_info_v org,
                                      mtl_parameters m
                                 WHERE org.organization_id = m.organization_id
                                 AND NVL(org.operating_unit,mo_global.get_current_org_id())
                                 = mo_global.get_current_org_id()
                                ) ;
      END IF;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   ELSE
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     '. Item Id = ' || x_item_id || ', Item Name = ' || x_item_name ||
                     ', Org Id = ' || x_org_id);
   END IF;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_ITEM_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_ITEM_NOT_EXISTS';
       WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Check_Item_Name_Or_Id;

-- Post 11.5.10 Enhancements
-- Added Procedure for Checking Project Template Name of Id.
--------------------------------------------------------------------
-- PROCEDURE
--    Check_Project_Template_Or_Id
--
-- PURPOSE
--    Procedure to check project template name and retrieve project id
--------------------------------------------------------------------
PROCEDURE Check_Project_Template_Or_Id
(
 p_proj_temp_name     IN VARCHAR2,

 x_project_id         OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2,
 x_error_msg_code     OUT NOCOPY VARCHAR2
)
IS
  -- Define local variables
   L_API_NAME   CONSTANT VARCHAR2(30) := 'Check_Project_Template_Or_Id';
   L_DEBUG_KEY  CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  CURSOR c_proj_template(p_proj_temp_name IN VARCHAR2)
  IS
    -- AnRaj:Changes made for fixing bug#4919353, issue# 8
    SELECT  project_id
    FROM  PA_PROJECTS
    WHERE name = p_proj_temp_name
    AND TEMPLATE_FLAG = 'Y';

    /*
    -- Commented by rnahata on June 25, 2007 for Bug 6147752
    -- Check removed to avoid having to setup Project's
    -- Carrying-out Org as an Inventory Org
    AND carrying_out_organization_id IN
        ( SELECT  organization_id
          FROM  INV_ORGANIZATION_INFO_V
          WHERE NVL(operating_unit,mo_global.get_current_org_id()) =
              mo_global.get_current_org_id()
        );
    */
    /*
    SELECT project_id
    FROM PA_PROJECTS
    WHERE name = p_proj_temp_name
    AND TEMPLATE_FLAG = 'Y'
    AND  carrying_out_organization_id IN (SELECT organization_id
      FROM org_organization_definitions
      WHERE NVL(operating_unit, mo_global.get_current_org_id()) =
            mo_global.get_current_org_id());
    */

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Project Template Name = ' || p_proj_temp_name);
   END IF;

   IF p_proj_temp_name IS NOT NULL THEN
      OPEN c_proj_template(p_proj_temp_name);
      FETCH c_proj_template INTO x_project_id;
      IF c_proj_template%NOTFOUND
      THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      ELSE
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Project Id = ' || x_project_id);
         END IF;
         x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      END IF;
      CLOSE c_proj_template;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Project_Template_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Serial_Name_Or_Id
--
-- PURPOSE
--    Converts Serial Name to Instance Id
--------------------------------------------------------------------
PROCEDURE Check_Serial_Name_Or_Id
  (p_item_id          IN NUMBER,
   p_org_id           IN NUMBER,
   p_serial_id        IN NUMBER,
   p_serial_number    IN VARCHAR2,

   x_serial_id        OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_error_msg_code   OUT NOCOPY VARCHAR2
 )
IS
  -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Check_Serial_Name_Or_Id';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Org Id = ' || p_org_id ||
                     ', Item Id = ' || p_item_id ||
                     ', Serial Id = ' || p_serial_id ||
                     ', Serial Number' || p_serial_number);
   END IF;

   IF (p_serial_id IS NOT NULL AND p_item_id IS NOT NULL AND p_org_id IS NOT NULL) THEN
      SELECT Instance_Id INTO x_serial_id
      FROM CSI_ITEM_INSTANCES
      WHERE Instance_Id  = p_serial_id AND Inventory_Item_Id = p_item_id AND Inv_Master_Organization_Id = p_org_id
       AND ACTIVE_START_DATE <= sysdate AND (ACTIVE_END_DATE >= sysdate OR ACTIVE_END_DATE IS NULL);
   END IF;

   IF (p_serial_number IS NOT NULL AND p_item_id IS NOT NULL AND p_org_id IS NOT NULL) THEN
      SELECT Instance_Id INTO x_serial_id
      FROM CSI_ITEM_INSTANCES
      WHERE Serial_Number = p_serial_number AND Inventory_Item_Id = p_item_id AND Inv_Master_Organization_Id = p_org_id
       AND ACTIVE_START_DATE <= sysdate AND (ACTIVE_END_DATE >= sysdate OR ACTIVE_END_DATE IS NULL);
   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' ||
                     x_return_status || ', Serial Id = ' || x_serial_id);
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_SERIAL_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_SERIAL_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Serial_Name_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Dept_Desc_Or_Id
--
-- PURPOSE
--    Converts Deparment Name to Department Id.
--------------------------------------------------------------------
PROCEDURE Check_Dept_Desc_Or_Id
    (p_organization_id  IN NUMBER,
     p_department_id    IN NUMBER,
     p_dept_name        IN VARCHAR2,

     x_department_id    OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
   -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Check_Dept_Desc_Or_Id';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Org Id = ' || p_organization_id ||
                     ', Dept Id = ' || p_department_id || ', Dept Name = ' || p_dept_name);
   END IF;
   IF (p_department_id IS NOT NULL) THEN
      SELECT department_id INTO x_department_id
      FROM BOM_DEPARTMENTS
      WHERE organization_id = p_organization_id
       AND department_id   = p_department_id;
   END IF;

   IF (p_dept_name IS NOT NULL) THEN
      SELECT department_id INTO x_department_id
      FROM BOM_DEPARTMENTS
      WHERE organization_id =  p_organization_id
       AND description = p_dept_name;
   END IF;

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                    '. Department Id = ' || x_department_id);
  END IF;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_return_status:= Fnd_Api.G_RET_STS_ERROR;
            x_error_msg_code:= 'AHL_VWP_DEPT_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
            x_return_status:= Fnd_Api.G_RET_STS_ERROR;
            x_error_msg_code:= 'AHL_VWP_DEPT_NOT_EXISTS';
       WHEN OTHERS THEN
            x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Check_Dept_Desc_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Org_Name_Or_Id
--
-- PURPOSE
--    Converts Organization Name to Organization Id
--------------------------------------------------------------------
PROCEDURE Check_Org_Name_Or_Id
    (p_organization_id IN NUMBER,
     p_org_name        IN VARCHAR2,

     x_organization_id OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_error_msg_code  OUT NOCOPY VARCHAR2
     )
IS
   -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Check_Org_Name_Or_Id';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Organization Id = ' || p_organization_id ||
                      'Organization Name = ' || p_org_name);
    END IF;
    IF (p_organization_id IS NOT NULL) THEN
    -- AnRaj:Changes made for fixing bug#4919353, issue# 6
       SELECT hou.organization_id
       INTO x_organization_id
       FROM hr_organization_units hou, mtl_parameters MP
       WHERE hou.organization_id = mp.organization_id
        AND hou.organization_id = p_organization_id
        AND hou.organization_id IN
        (SELECT organization_id
         FROM INV_ORGANIZATION_INFO_V
         WHERE hou.organization_id = mp.organization_id
          AND NVL(operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id())
          AND MP.EAM_enabled_flag='Y';
    ELSE
      -- AnRaj:Changes made for fixing bug#4919353, issue# 5
       SELECT hou.organization_id
       INTO x_organization_id
       FROM hr_organization_units hou, mtl_parameters MP
       WHERE hou.organization_id = mp.organization_id
        AND hou.Name = p_org_name
        AND hou.organization_id IN
        (SELECT organization_id
         FROM INV_ORGANIZATION_INFO_V
         WHERE hou.organization_id = mp.organization_id
          AND NVL(operating_unit, mo_global.get_current_org_id()) =  mo_global.get_current_org_id())
          AND MP.EAM_enabled_flag='Y';
    END IF;
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                      'Organization Id = ' || x_organization_id);
    END IF;

EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_return_status:= Fnd_Api.G_RET_STS_ERROR;
            x_error_msg_code:= 'AHL_VWP_ORG_NOT_EXISTS';
       WHEN TOO_MANY_ROWS THEN
            x_return_status:= Fnd_Api.G_RET_STS_ERROR;
            x_error_msg_code:= 'AHL_VWP_ORG_NOT_EXISTS';
       WHEN OTHERS THEN
            x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
            RAISE;
END Check_Org_Name_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_SR_Request_Number_Or_Id
--
-- PURPOSE
--    Converts Service Request Number to Service Request Id
--------------------------------------------------------------------
PROCEDURE Check_SR_Request_Number_Or_Id
    (p_service_id       IN NUMBER,
     p_service_number   IN VARCHAR2,

     x_service_id       OUT NOCOPY NUMBER,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_error_msg_code   OUT NOCOPY VARCHAR2
     )
IS
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_SR_Request_Number_Or_Id';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. SR Number= ' ||
                     p_service_number || ', SR Id = ' || p_service_id);
   END IF;

   -- yazhou 19Oct2005 Starts
   -- Bug fix #4415024
   IF p_service_id IS NOT NULL THEN
      SELECT a.Incident_Id INTO x_service_id
      FROM CS_INCIDENTS_ALL_B a, CS_INCIDENT_TYPES_VL CIT
      WHERE a.incident_type_id = cit.incident_type_id
       AND cit.INCIDENT_SUBTYPE = 'INC'
       AND cit.CMRO_FLAG = 'Y'
       AND Incident_Id  = p_service_id;
   ELSIF p_service_number IS NOT NULL THEN
      SELECT a.Incident_Id INTO x_service_id
      FROM CS_INCIDENTS_ALL_B a, CS_INCIDENT_TYPES_VL CIT
      WHERE a.incident_type_id = cit.incident_type_id
       AND cit.INCIDENT_SUBTYPE = 'INC'
       AND cit.CMRO_FLAG = 'Y'
       AND Incident_Number  = p_service_number;
   -- yazhou 19Oct2005 ends
   ELSE
      x_return_status:= Fnd_Api.G_RET_STS_ERROR;
      x_error_msg_code:= 'AHL_VWP_SERVICE_REQ_NOT_EXISTS';
   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     'Service Id = ' || x_service_id);
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_SERVICE_REQ_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_SERVICE_REQ_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_SR_Request_Number_Or_Id;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Visit_is_Simulated
--
-- PURPOSE
--    Check if the Visit is Simulated or not
--------------------------------------------------------------------
PROCEDURE Check_Visit_is_Simulated
    (p_Visit_id             IN NUMBER,

     x_bln_flag             OUT NOCOPY VARCHAR2,
     x_return_status        OUT NOCOPY VARCHAR2,
     x_error_msg_code       OUT NOCOPY VARCHAR2
     )
IS
   -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Visit_is_Simulated';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   l_simulation_plan    NUMBER;
   l_simulation_plan_id NUMBER;
   l_dummy VARCHAR2(1);

   -- Define local cursors
   CURSOR c_visit(x_id IN NUMBER)IS
    SELECT SIMULATION_PLAN_ID FROM
    AHL_VISITS_VL WHERE VISIT_ID = x_id;
   /*
   CURSOR c_sim_visit(x_id IN NUMBER) IS
    SELECT 'x'
    FROM   ahl_simulation_plans_vl ASP
    WHERE primary_plan_flag = 'Y'
     AND EXISTS ( SELECT 1
                  FROM ahl_visits_b
                  WHERE visit_id = x_id
                   AND NVL(simulation_plan_id,-99) = ASP.simulation_plan_id);
   */
BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_Visit_id);
   END IF;
   IF (p_visit_id IS NOT NULL) THEN
       OPEN c_visit(p_visit_id);
       FETCH c_visit INTO l_simulation_plan;
       CLOSE c_visit;

       IF (l_simulation_plan IS NOT NULL) THEN

          IF (l_log_statement >= l_log_current_level)THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'Simulation Id Check' || l_simulation_plan);
          END IF;
          SELECT SIMULATION_PLAN_ID INTO l_simulation_plan_id
          FROM AHL_SIMULATION_PLANS_VL WHERE primary_plan_flag = 'Y';

          IF l_simulation_plan_id = l_simulation_plan THEN
             x_bln_flag := 'Y';
          ELSE
             x_bln_flag := 'N';
          END IF;
       END IF;
   END IF;

   /*
   OPEN c_sim_visit(p_visit_id);
   FETCH c_sim_visit INTO l_dummy;
   IF c_sim_visit%FOUND THEN
      x_bln_flag := 'Y';
   ELSE
      x_bln_flag := 'N';
   END IF;
   CLOSE c_sim_visit;
   */
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     'x_bln_flag = ' || x_bln_flag);
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_SIMULATION_PLAN_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_LTP_SIMULATION_PLAN_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Visit_is_Simulated;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Visit_Task_Number_Or_Id
--
-- PURPOSE
--    Converts Visit Task Number to Visit Task Id
--------------------------------------------------------------------
PROCEDURE Check_Visit_Task_Number_Or_Id
    (p_visit_task_id     IN NUMBER,
     p_visit_task_number IN NUMBER,
     p_visit_id          IN NUMBER,

     x_visit_task_id     OUT NOCOPY NUMBER,
     x_return_status     OUT NOCOPY VARCHAR2,
     x_error_msg_code    OUT NOCOPY VARCHAR2
     )
IS
   -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Check_Visit_Task_Number_Or_Id';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  --mpothuku added status_code <> 'DELETED' clause to fix #206 on 03/30/05
BEGIN
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Visit Task Id = ' || p_visit_task_id ||
                      ', Visit Task Number = ' || p_visit_task_number || ', Visit Id = ' || p_visit_id);
    END IF;
    IF (p_visit_task_id IS NOT NULL) THEN
       SELECT Visit_Task_Id INTO x_visit_task_id
       FROM AHL_VISIT_TASKS_B
       WHERE Visit_Task_Id  = p_visit_task_id AND Visit_Id = p_visit_id AND status_code <> 'DELETED';
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    ELSIF (p_visit_task_number IS NOT NULL) THEN
       SELECT Visit_Task_Id INTO x_visit_task_id
       FROM AHL_VISIT_TASKS_B
       WHERE Visit_Task_Number = p_visit_task_number AND Visit_Id = p_visit_id AND status_code <> 'DELETED';
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    ELSE
       x_return_status:= Fnd_Api.G_RET_STS_ERROR;
       Fnd_Message.set_name ('AHL', 'AHL_VWP_VISIT_TASKS_NOT_EXISTS');
       Fnd_Msg_Pub.ADD;
    END IF;

    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                      'Visit Task Id = ' || x_visit_task_id);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_VISIT_TASKS_NOT_EXISTS';
    WHEN TOO_MANY_ROWS THEN
         x_return_status:= Fnd_Api.G_RET_STS_ERROR;
         x_error_msg_code:= 'AHL_VWP_VISIT_TASKS_NOT_EXISTS';
    WHEN OTHERS THEN
         x_return_status:= Fnd_Api.G_RET_STS_UNEXP_ERROR;
RAISE;
END Check_Visit_Task_Number_OR_ID;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Lookup_Name_Or_Id
--
-- PURPOSE
--    To derive the any of the lookup codes to its lookup values
--------------------------------------------------------------------
PROCEDURE Check_Lookup_Name_Or_Id
 ( p_lookup_type   IN         FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code   IN         FND_LOOKUPS.lookup_code%TYPE,
   p_meaning       IN         FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag IN         VARCHAR2,

   x_lookup_code   OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2)
IS
   -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Check_Lookup_Name_Or_Id';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure. p_lookup_type = ' || p_lookup_type ||
                    ', p_lookup_code = ' || p_lookup_code ||
                    ', p_meaning = ' || p_meaning ||
                    ', p_check_id_flag = ' || p_check_id_flag);
  END IF;
  IF (p_lookup_code IS NOT NULL) THEN
     IF (p_check_id_flag = 'Y') THEN
        SELECT Lookup_Code INTO x_lookup_code
        FROM FND_LOOKUP_VALUES_VL
        WHERE Lookup_Type = p_lookup_type
         AND Lookup_Code = p_lookup_code
            AND enabled_flag = 'Y'   --sowsubra FP:Bug#5758829
         AND SYSDATE BETWEEN nvl(start_date_active,sysdate) --Sowmya Bug#5715342
         AND NVL(end_date_active,SYSDATE);
     ELSE
        x_lookup_code := p_lookup_code;
     END IF;
  ELSE
     SELECT Lookup_Code INTO x_lookup_code
     FROM FND_LOOKUP_VALUES_VL
     WHERE Lookup_Type = p_lookup_type
      AND Meaning = p_meaning
            AND enabled_flag = 'Y'   --sowsubra FP:Bug#5758829
            AND SYSDATE BETWEEN nvl(start_date_active,sysdate) --sowsubra FP:Bug#5758829
      AND NVL(end_date_active,SYSDATE);
  END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     '. x_lookup_code = ' || x_lookup_code);
   END IF;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Check_Lookup_Name_Or_Id;


--------------------------------------------------------------------
-- PROCEDURE
--    Check_Proj_Responsibility
--
-- PURPOSE
--    While integrating with projects,
--    VWP need to check for valid project resposibilities
--------------------------------------------------------------------
PROCEDURE Check_Proj_Responsibility
 ( x_check_project    OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2)
IS
  -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Proj_Responsibility';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_msg_count          NUMBER;
   l_responsibility_id  NUMBER;
   l_return_status      VARCHAR2(1);
   l_msg_data           VARCHAR2(2000);
   G_EXC_ERROR          EXCEPTION;

   -- Define local cursors
   -- To find the responsibiltiy_id for Project Billing Superuser
   -- Not using project superuser resposibility as the menu associated is changed in 11.5.9
   CURSOR c_fnd_response IS
    SELECT RESPONSIBILITY_ID
    FROM FND_RESPONSIBILITY_VL
    WHERE RESPONSIBILITY_KEY LIKE 'PROJECT_BILLING_SUPER_USER';

   -- To find the responsibiltiy_id for Project Superuser
 /*
   CURSOR c_fnd_user_resp(x_resp_id IN NUMBER) IS
    SELECT RESPONSIBILITY_ID
    FROM FND_USER_RESP_GROUPS
    WHERE USER_ID = Fnd_Global.USER_ID AND RESPONSIBILITY_ID = x_resp_id;
*/
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure.');
   END IF;
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   -- Always return x_check_project = 'Y' as we no longer need to check for Project Billing
   -- Superuser Resp. Part of ADS bug fix 4357001.
   x_check_project := 'Y';

/* -- Commented out hardcoding of Responsibility. AMG's function security functions will be
   -- included into ahlmenu instead. Part of ADS bug fix 4357001.
   OPEN c_fnd_response;
   FETCH c_fnd_response INTO l_responsibility_id;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,L_DEBUG_KEY, 'Responsiblity_Id from c_fnd_response = ' || l_responsibility_id);
   END IF;

   IF c_fnd_response%NOTFOUND THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_NO_SUPERUSER');
         Fnd_Msg_Pub.ADD;
         CLOSE c_fnd_response;
         RAISE G_EXC_ERROR;
      END IF;
   END IF;
   CLOSE c_fnd_response;

   OPEN c_fnd_user_resp(l_responsibility_id);
   FETCH c_fnd_user_resp INTO l_responsibility_id;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,L_DEBUG_KEY, 'Responsiblity_Id from c_fnd_user_resp = ' || l_responsibility_id);
   END IF;

   IF c_fnd_user_resp%NOTFOUND THEN
      x_return_status := Fnd_Api.g_ret_sts_error;
      IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_NO_USER_GROUPS');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF;
   CLOSE c_fnd_user_resp;

   IF x_return_status =Fnd_Api.G_RET_STS_SUCCESS THEN

      IF l_responsibility_id = l_responsibility_id THEN
         x_check_project := 'Y';

         -- Project Billing Super user
         PA_INTERFACE_UTILS_PUB.Set_Global_Info
         ( p_api_version_number => 1.0,
           p_responsibility_id  => l_responsibility_id,
           p_user_id            => Fnd_Global.USER_ID,
           p_msg_count          => l_msg_count,
           p_msg_data           => l_msg_data,
*/

/* Fix for Bug 4086726 on Dec 23, 2004 by JR.
 * Commenting out the calling mode param.
 * Need to add if required, along with build dependency and a one-off
 * fix from PA.
             p_return_status => l_return_status ,
             p_calling_mode  => 'PUBLISH');
             p_return_status => l_return_status);
       IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE G_EXC_ERROR;
       END IF;

    ELSE
       x_check_project := 'N';
       x_return_status := Fnd_Api.g_ret_sts_error;

       IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name ('AHL', 'AHL_VWP_PROJ_NO_RESPONSIBILITY');
          Fnd_Msg_Pub.ADD;
       END IF;
    END IF;
  END IF;
*/

   -- jaramana July 25, 2005
   /* From Majid Ansari's email dated June 8, 2005:
    * Before calling any AMG api, its mandatory to call PA_INTERFACE_UTILS_PUB.Set_Global_Info.
    * This has been mentioned in the AMG doc. You cannot get rid of this call.
    * None of the APIs will be usable.
    */
   -- So, reintroduced the call to PA_INTERFACE_UTILS_PUB.Set_Global_Info.
   -- However, passing the current responsibilty id instead of the hardcoded
   -- Project Billing Superuser Responsibility as was done before the ADS Bug 4357001 Fix.
   PA_INTERFACE_UTILS_PUB.Set_Global_Info( p_api_version_number => 1.0,
                                           p_responsibility_id  => Fnd_Global.RESP_ID,
                                           p_resp_appl_id       => Fnd_Global.RESP_APPL_ID,
                                           p_user_id            => Fnd_Global.USER_ID,
                                           p_operating_unit_id  => mo_global.get_current_org_id, -- Yazhou added for MOAC changes on 05Oct2005
                                           p_msg_count          => l_msg_count,
                                           p_msg_data           => l_msg_data,
                                           p_return_status      => x_return_status);
   IF (fnd_log.level_event >= l_log_current_level) THEN
     fnd_log.string(fnd_log.level_event,
                    L_DEBUG_KEY,
                    'After calling PA_INTERFACE_UTILS_PUB.Set_Global_Info. Return Status = ' || x_return_status);
   END IF;
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Errors from PA_INTERFACE_UTILS_PUB.Set_Global_Info. Message count: ' ||
                        l_msg_count || ', message data: ' || l_msg_data);
      END IF;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   -- End Changes made by jaramana on July 25, 2005

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure. Return Status = ' ||
                    x_return_status || '. x_check_project = ' || x_check_project);
  END IF;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Check_Proj_Responsibility;

--------------------------------------------------------------------
-- PROCEDURE
--    Get_Serial_Item_by_Unit
--
-- PURPOSE
--    To retrieve Inventory Item Id, Item Org Id and Instance Id from Unit Name
--------------------------------------------------------------------
PROCEDURE Get_Serial_Item_by_Unit
 ( p_unit_name      IN         VARCHAR2,
   x_instance_id    OUT NOCOPY NUMBER,
   x_item_id        OUT NOCOPY NUMBER,
   x_item_org_id    OUT NOCOPY NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_error_msg_code OUT NOCOPY VARCHAR2)
IS
-- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30)  := 'Get_Serial_Item_by_Unit';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

-- Define local cursors
  CURSOR c_serial (p_unit_name IN VARCHAR2) IS
   SELECT csi_item_instance_id
   FROM ahl_unit_config_headers
   WHERE name = p_unit_name AND unit_config_status_code = 'COMPLETE'
    AND (active_end_date is null or active_end_date > sysdate);

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Unit Name = ' || p_unit_name);
   END IF;
   IF (p_unit_name IS NOT NULL) THEN
      OPEN c_serial(p_unit_name);
      FETCH c_serial INTO x_instance_id;
      CLOSE c_serial;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Instance Id = ' || x_instance_id);
      END IF;

      IF x_instance_id IS NOT NULL THEN
         SELECT Inventory_Item_Id, Inv_Master_Organization_Id
         INTO x_Item_Id, x_Item_Org_Id
         FROM CSI_ITEM_INSTANCES
         WHERE Instance_Id = x_instance_id;
      ELSE
         Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_NOT_EXISTS');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     '. Item Id = ' || x_item_id || ' Item Org Id' || x_item_org_id);
   END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
      WHEN TOO_MANY_ROWS THEN
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
      WHEN OTHERS THEN
           x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   RAISE;
END Get_Serial_Item_by_Unit;

--------------------------------------------------------------------
-- PROCEDURE
--    Insert_Tasks
--
-- PURPOSE
--    To call when inserting planned/unplanned tasks
--------------------------------------------------------------------
PROCEDURE Insert_Tasks (
   p_visit_id      IN    NUMBER,
   p_unit_id       IN    NUMBER,
   p_serial_id     IN    NUMBER,
   p_service_id    IN    NUMBER,
   p_dept_id       IN    NUMBER,
   p_item_id       IN    NUMBER,
   p_item_org_id   IN    NUMBER,
   p_mr_id         IN    NUMBER,
   p_mr_route_id   IN    NUMBER,
   p_parent_id     IN    NUMBER,
   p_flag          IN    VARCHAR2,
   p_stage_id      IN    NUMBER := NULL,
   -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
   -- Added past start and end dates
   p_past_task_start_date IN DATE := NULL,
   p_past_task_end_date IN DATE := NULL,
   p_quantity      IN    NUMBER := NULL, -- Added by rnahata for Issue 105
   -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
   p_task_start_date IN  DATE := NULL,
   x_task_id       OUT   NOCOPY NUMBER,
   x_return_status OUT   NOCOPY VARCHAR2,
   x_msg_count     OUT   NOCOPY NUMBER,
   x_msg_data      OUT   NOCOPY VARCHAR2
)
IS
   -- Define local variables
   L_API_NAME   CONSTANT VARCHAR2(30) := 'Insert_Tasks';
   L_DEBUG_KEY  CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Added by sjayacha for Servie Request Integration

   CURSOR c_mr_title(c_mr_id IN NUMBER) IS
    SELECT title, description /*Bug 5758813- Fetch the description of the MR*/
    FROM ahl_mr_headers_vl
    WHERE mr_header_id = c_mr_id;

   CURSOR c_unit_eff_title(c_unit_eff_id IN NUMBER) IS
    SELECT substrb(title,1,80), description /*Bug 5758813 - Fetch the description.*/
    FROM ahl_unit_effectivities_v
    WHERE unit_effectivity_id = c_unit_eff_id;

   /*Bug 5758813 - rnahata - Route title and route remarks should be passed
   to visit as visit task name and visit task description*/
   CURSOR c_route_title(c_mr_route_id IN NUMBER) IS
    SELECT substrb(ar.title,1,80), ar.remarks
    FROM ahl_routes_vl ar, ahl_mr_routes mrr
    WHERE mrr.mr_route_id = c_mr_route_id
     AND mrr.route_id = ar.route_id;

   -- Local variables defined for the procedure
   l_msg_data      VARCHAR2(2000);
   l_name          VARCHAR2(80);
   l_rowid         VARCHAR2(30);
   l_type          VARCHAR2(30);
   l_return_status VARCHAR2(1);
   l_template_flag VARCHAR2(1);

   l_msg_count     NUMBER;
   l_task_number   NUMBER;
   l_task_id       NUMBER;
   l_item_id       NUMBER;
   l_item_org_id   NUMBER;
   l_serial_id     NUMBER;
   l_mr_id         NUMBER;
   l_mr_route_id   NUMBER;
   l_description   ahl_routes_vl.remarks%TYPE; --Bug 5758813

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id ||
                     ', parent id = ' || p_parent_id || ', p_serial_id = ' || p_serial_id ||
                     ', p_item_id = ' || p_item_id || ', p_mr_id = ' || p_mr_id ||
                     ', p_mr_route_id = ' || p_mr_route_id);
   END IF;
   IF p_visit_id IS NOT NULL THEN
      IF p_unit_id IS NOT NULL THEN
         l_type := 'PLANNED';
      ELSE
         l_type := 'UNPLANNED';
         IF p_serial_id IS NULL THEN
            x_return_status := Fnd_Api.g_ret_sts_error;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Error in Insert_Tasks. Serial Id missing.');
            END IF;
            IF Fnd_Msg_Pub.check_msg_level (Fnd_Msg_Pub.g_msg_lvl_error) THEN
               Fnd_Message.SET_NAME('AHL','AHL_VWP_SERIAL_MISSING');
               Fnd_Msg_Pub.ADD;
            END IF;
         END IF;
      END IF; -- End of p_unit_id check

      IF p_flag = 'Y' THEN
         l_type := 'SUMMARY';
         IF p_mr_id IS NOT NULL THEN
            -- MR Summary Task
            /*Bug 5758813 - rnahata*/
            OPEN c_mr_title(p_mr_id);
            FETCH c_mr_title INTO l_name, l_description;
            CLOSE c_mr_title;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Summary Task. MR Title = ' || l_name || ', MR Description = ' || l_description);
            END IF;
         ELSIF p_unit_id IS NOT NULL THEN
            -- Added by sjayacha for Servie Request Integration
            /*Bug 5758813 - rnahata*/
            OPEN c_unit_eff_title(p_unit_id);
            FETCH c_unit_eff_title INTO l_name, l_description;
            CLOSE c_unit_eff_title;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Summary Task. Unit Eff Title = ' || l_name || ', Unit Eff Description = ' || l_description);
            END IF;
         END IF;
      ELSE
         -- Not a Summary Task
         IF p_mr_route_id IS NOT NULL THEN
            /*Bug 5758813 - rnahata*/
            OPEN c_route_title(p_mr_route_id);
            FETCH c_route_title INTO l_name, l_description;
            CLOSE c_route_title;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Task. Route Title = ' || l_name || ', Route Description = ' || l_description);
            END IF;
         ELSIF p_unit_id IS NOT NULL THEN
            -- Added by sjayacha for Service Request Integration
            /*Bug 5758813 - rnahata*/
            OPEN c_unit_eff_title(p_unit_id);
            FETCH c_unit_eff_title INTO l_name, l_description;
            CLOSE c_unit_eff_title;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Task. Unit Eff Title = ' || l_name || ', Unit Eff Description = ' || l_description);
            END IF;
         END IF;
      END IF;  -- Summary Task or Not

      -- Check for the Visit Task ID and Number.
      l_task_ID := Get_Visit_Task_Id();
      l_task_number := Get_Visit_Task_Number(p_visit_id);
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Task ID = ' || l_task_id || ', Task Number = ' || l_task_number);
      END IF;

      l_msg_count := Fnd_Msg_Pub.count_msg;
      IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
         x_msg_count := l_msg_count;
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling AHL_VISIT_TASKS_PKG.Insert_Row.');
      END IF;

      -- Insert a record in AHL_VISIT_TASKS base and translational tables
      Ahl_Visit_Tasks_Pkg.Insert_Row (
       X_ROWID                 => l_rowid,
       X_VISIT_TASK_ID         => l_task_ID ,
       X_VISIT_TASK_NUMBER     => l_task_number,
       X_OBJECT_VERSION_NUMBER => 1,
       X_VISIT_ID              => p_visit_id,
       X_PROJECT_TASK_ID       => NULL,
       X_COST_PARENT_ID        => p_parent_id,
       X_MR_ROUTE_ID           => p_mr_route_id,
       X_MR_ID                 => p_mr_id,
       X_DURATION              => NULL,
       X_UNIT_EFFECTIVITY_ID   => p_unit_id,
       X_START_FROM_HOUR       => NULL,
       X_INVENTORY_ITEM_ID     => p_item_id,
       X_ITEM_ORGANIZATION_ID  => p_item_org_id,
       X_INSTANCE_ID           => p_serial_id,
       X_PRIMARY_VISIT_TASK_ID => NULL,
       X_ORIGINATING_TASK_ID   => p_parent_id,
       X_SERVICE_REQUEST_ID    => p_service_id,
       X_TASK_TYPE_CODE        => l_type,
       X_DEPARTMENT_ID         => p_dept_id,
       X_SUMMARY_TASK_FLAG     => 'N',
       X_PRICE_LIST_ID         => NULL,
       X_STATUS_CODE           => 'PLANNING',
       X_ESTIMATED_PRICE       => NULL,
       X_ACTUAL_PRICE          => NULL,
       X_ACTUAL_COST           => NULL,
       X_STAGE_ID              => p_stage_id,
       -- Added cxcheng POST11510--------------
       X_START_DATE_TIME       => p_past_task_start_date,
       X_END_DATE_TIME         => p_past_task_end_date,
       X_PAST_TASK_START_DATE  => p_past_task_start_date,
       X_PAST_TASK_END_DATE    => p_past_task_end_date,
       X_ATTRIBUTE_CATEGORY    => NULL,
       X_ATTRIBUTE1            => NULL,
       X_ATTRIBUTE2            => NULL,
       X_ATTRIBUTE3            => NULL,
       X_ATTRIBUTE4            => NULL,
       X_ATTRIBUTE5            => NULL,
       X_ATTRIBUTE6            => NULL,
       X_ATTRIBUTE7            => NULL,
       X_ATTRIBUTE8            => NULL,
       X_ATTRIBUTE9            => NULL,
       X_ATTRIBUTE10           => NULL,
       X_ATTRIBUTE11           => NULL,
       X_ATTRIBUTE12           => NULL,
       X_ATTRIBUTE13           => NULL,
       X_ATTRIBUTE14           => NULL,
       X_ATTRIBUTE15           => NULL,
       X_VISIT_TASK_NAME       => l_name, --Bug 5758813
       X_DESCRIPTION           => l_description, --Bug 5758813
       -- Added by rnahata for Issue 105
       X_QUANTITY              => p_quantity,
       X_CREATION_DATE         => SYSDATE,
       X_CREATED_BY            => Fnd_Global.USER_ID,
       X_LAST_UPDATE_DATE      => SYSDATE,
       X_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
       X_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID);

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling AHL_VISIT_TASKS_PKG.Insert_Row.');
      END IF;

      x_task_id := l_task_id;

      -- Added cxcheng POST11510--------------
      --Now adjust the times derivation for task
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling AHL_VWP_TIMES_PVT.Adjust_Task_Times.');
      END IF;

      -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
      -- Included the new in param p_task_start_date
      -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Call Adjust_Task_Times only if past date is null
      IF p_past_task_start_date IS NULL THEN
        AHL_VWP_TIMES_PVT.Adjust_Task_Times
           (p_api_version      => 1.0,
            p_init_msg_list    => Fnd_Api.G_FALSE,
            p_commit           => Fnd_Api.G_FALSE,
            p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            p_task_id          => l_task_id,
            p_task_start_date  => p_task_start_date);
      END IF;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling AHL_VWP_TIMES_PVT.Adjust_Task_Times. Return Status = ' ||
                        l_return_status);
      END IF;

      l_msg_count := Fnd_Msg_Pub.count_msg;
      IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from AHL_VWP_TIMES_PVT.Adjust_Task_Times. Message count: ' ||
                           l_msg_count || ', message data: ' || l_msg_data);
         END IF;
         x_msg_count := l_msg_count;
         x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      x_return_status := Fnd_Api.g_ret_sts_success;
      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY || '.end',
                        'Return Status = ' || x_return_status || '. Task Id = ' || x_task_id);
      END IF;
   END IF; -- p_visit_id IS NOT NULL
END Insert_Tasks;

--------------------------------------------------------------------
-- Define local functions body                                   --
--------------------------------------------------------------------


--------------------------------------------------------------------
-- FUNCTION
--    Get_Cost_Originating_Id
--
-- PURPOSE
--    To seek Cost Parent Id and Originating Task Id for the
--    planned/unplanned task which has to be created.
--------------------------------------------------------------------
FUNCTION Get_Cost_Originating_Id (p_mr_main_id IN NUMBER, p_mr_header_id IN NUMBER)
RETURN NUMBER
IS
-- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Get_Cost_Originating_Id';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_flag1              VARCHAR2(1);
   x_parent_id          NUMBER;
   y                    NUMBER := 0;
   i                    NUMBER := 0;

-- Define local cursors
 -- To find all relationships between various MR_HEADER_IDs
 -- under main MR_HEADER_IDs which was retreived on basis of the Unit Effectivity
   CURSOR c_relationship(x_MR_id IN NUMBER) IS
    SELECT MR_HEADER_ID, RELATED_MR_HEADER_ID
      FROM AHL_MR_RELATIONSHIPS
       START WITH MR_HEADER_ID = (
           SELECT MR_HEADER_ID
           FROM AHL_MR_HEADERS_APP_V
           WHERE MR_HEADER_ID = x_MR_id)
       CONNECT BY PRIOR RELATED_MR_HEADER_ID = MR_HEADER_ID;
   relation_rec c_relationship%ROWTYPE;

-- Define local record type for storing MR_Id and Related MR_Header_Id
   TYPE Task_Rel_Type IS RECORD
   (MR_HEADER_ID                NUMBER,
    RELATED_MR_HEADER_ID        NUMBER);

-- Define local table type for storing MR_Id and Related MR_Header_Id
   TYPE relation_tbl IS TABLE OF Task_Rel_Type
   INDEX BY BINARY_INTEGER;

   relation_rec_tbl relation_tbl;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL function. MAIN HEADER = ' || p_MR_main_id ||
                     'CURRENT MR HEADER = ' || p_MR_HEADER_id);
   END IF;
   -- To store all related rows of relationship with main mr_header id in a form of a table datatype
   OPEN c_relationship (p_mr_main_id);
   LOOP
   FETCH c_relationship INTO relation_rec;
       EXIT WHEN c_relationship%NOTFOUND;
       relation_rec_tbl(i).MR_HEADER_ID:=relation_rec.MR_HEADER_ID;
       relation_rec_tbl(i).RELATED_MR_HEADER_ID:=relation_rec.RELATED_MR_HEADER_ID;
       i:=i+1;
   END LOOP;
   CLOSE c_relationship;

   -- Find out parent of MR_HEADER_ID as cost and parent ID
   IF relation_rec_tbl.COUNT > 0 THEN
      y := relation_rec_tbl.FIRST;
      LOOP
         IF relation_rec_tbl(y).RELATED_MR_HEADER_ID = p_MR_HEADER_id THEN
            IF relation_rec_tbl(y).RELATED_MR_HEADER_ID = p_mr_main_id THEN
               x_parent_id := NULL;
               l_flag1 := 'Y';
               EXIT WHEN l_flag1 = 'Y';
            ELSE
               x_parent_id := relation_rec_tbl(y).MR_HEADER_ID;
               l_flag1 := 'Y';
               EXIT WHEN l_flag1 = 'Y';
            END IF;
         END IF;
         EXIT WHEN y = relation_rec_tbl.LAST ;
         y :=relation_rec_tbl.NEXT(y);
      END LOOP;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL function. Parent_Id' || x_parent_id);
   END IF;
   RETURN x_parent_id;
END Get_Cost_Originating_Id;

--------------------------------------------------------------------
-- FUNCTION
--    Get_Visit_Task_Id
--
-- PURPOSE
--    To retrieve visit task id from the sequence
--------------------------------------------------------------------
FUNCTION  Get_Visit_Task_Id
RETURN NUMBER
IS
   -- Define local cursors
   CURSOR c_seq_t IS
    SELECT Ahl_Visit_Tasks_B_S.NEXTVAL
    FROM   dual;

   CURSOR c_id_exists_t (c_id IN NUMBER) IS
    SELECT 1
    FROM   Ahl_Visit_Tasks_VL
    WHERE  Visit_Task_id = c_id;

   -- Define local variables
   x_visit_task_id NUMBER;
   l_dummy         NUMBER;
   L_API_NAME   CONSTANT VARCHAR2(30) := 'Get_Visit_Task_Id';
   L_DEBUG_KEY  CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL function.');
   END IF;

   -- If the ID is not passed into the API, then grab a value from the sequence.
   OPEN c_seq_t;
   FETCH c_seq_t INTO x_visit_task_id;
   CLOSE c_seq_t;

   -- Check to be sure that the sequence does not exist.
   OPEN c_id_exists_t (x_visit_task_id);
   FETCH c_id_exists_t INTO l_dummy;
   IF c_id_exists_t%FOUND THEN
      x_visit_task_id := Get_Visit_Task_Id();
   END IF;
   CLOSE c_id_exists_t;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL function. Visit Task Id = ' || x_visit_task_id);
   END IF;
   RETURN x_visit_task_id;
END Get_Visit_Task_Id;

--------------------------------------------------------------------
-- FUNCTION
--    Get_Visit_Task_Number
--
-- PURPOSE
--    To retrieve visit task's task number with maximum plus one criteria
--------------------------------------------------------------------

FUNCTION Get_Visit_Task_Number(p_visit_id IN NUMBER)
RETURN NUMBER
IS
 -- To find out the maximum task number value in the visit
  CURSOR c_task_number IS
   SELECT MAX(visit_task_number)
   FROM Ahl_Visit_Tasks_B
   WHERE Visit_Id = p_visit_id;

  x_Visit_Task_Number NUMBER;
  L_API_NAME   CONSTANT VARCHAR2(30) := 'Get_Visit_Task_Number';
  L_DEBUG_KEY  CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL function. Visit Id = ' || p_visit_id);
   END IF;

   -- Check for Visit Number
   OPEN c_Task_Number;
   FETCH c_Task_Number INTO x_Visit_Task_Number;
   CLOSE c_Task_Number;
   IF x_Visit_Task_Number IS NOT NULL THEN
      x_Visit_Task_Number := x_Visit_Task_Number + 1;
   ELSE
      x_Visit_Task_Number := 1;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL function. Visit Task Number = ' || x_Visit_Task_Number);
   END IF;
   RETURN x_Visit_Task_Number;
END Get_Visit_Task_Number;

--------------------------------------------------------------------
-- PROCEDURE
--    Tech_Dependency
--
--
--------------------------------------------------------------------
PROCEDURE Tech_Dependency (
   p_visit_id       IN         NUMBER,
   p_task_type      IN         VARCHAR2,
   p_MR_Serial_Tbl  IN         MR_Serial_Tbl_Type,
   x_return_status  OUT NOCOPY VARCHAR2)
IS
  -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Tech_Dependency';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_task_rec           Task_Rec_Type;
   l_return_status      VARCHAR2(1);
   l_flag               VARCHAR2(1);
   l_tsk_flag           VARCHAR2(1);
   l_serial_id          NUMBER;
   l_count              NUMBER;
   l_task_link_id       NUMBER;
   l_child_task_id      NUMBER;
   l_parent_task_id     NUMBER;
   l_route_id           NUMBER;
   y                    NUMBER;

   --  Table type for storing Task Ids record type
   TYPE Task_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_parent_Task_Tbl    Task_Tbl_Type;
   l_child_Task_Tbl     Task_Tbl_Type;

-- Define local variables
   -- To find out the count for the relationship with MR Route Id
   CURSOR c_route_seq_ct (x_route_id IN NUMBER) IS
    SELECT COUNT(*) FROM AHL_MR_ROUTE_SEQUENCES_APP_V
    WHERE MR_ROUTE_ID = x_route_id;

   -- To find out the the relationship between MR Route Id and Related MR Route Id
   CURSOR c_route_seq (x_route_id IN NUMBER) IS
    SELECT MR_ROUTE_ID, RELATED_MR_ROUTE_ID FROM AHL_MR_ROUTE_SEQUENCES_APP_V
    WHERE MR_ROUTE_ID = x_route_id;
   c_route_seq_rec c_route_seq%ROWTYPE;

   -- To find out the tasks with tasktype code as planned for visits
   CURSOR c_route_task (x_route_id IN NUMBER, x_serial_id IN NUMBER,
                        x_id IN NUMBER, x_type IN VARCHAR2) IS
    SELECT VISIT_TASK_ID FROM AHL_VISIT_TASKS_VL
    WHERE MR_ROUTE_ID = x_route_id AND INSTANCE_ID = x_serial_id
    AND VISIT_ID = x_id AND TASK_TYPE_CODE = x_type
    AND  nvl(STATUS_CODE,'x') <> 'DELETED';

   -- To find MR_ROUTE_ID for the particular MR_HEADER_ID
   CURSOR c_MR_route (x_mr_id IN NUMBER) IS
      SELECT   T1.MR_ROUTE_ID
      FROM     AHL_MR_ROUTES_V T1,
               AHL_ROUTES_B T2
      WHERE    T1.MR_HEADER_ID = x_mr_id
       AND     T1.ROUTE_ID = T2.ROUTE_ID
       AND     T2.REVISION_STATUS_CODE = 'COMPLETE'
       -- Added as of Bug# 3562914
       -- By shbhanda 04/22/2004
       AND     T1.ROUTE_REVISION_NUMBER
       IN      (  SELECT MAX(T3.ROUTE_REVISION_NUMBER)
                  FROM   AHL_MR_ROUTES_V T3
                WHERE  T3.MR_HEADER_ID = x_mr_id
                  AND T3.ROUTE_NUMBER = T1.ROUTE_NUMBER
               GROUP BY T3.ROUTE_NUMBER
            );
BEGIN
 ---------------------------Start of Body-------------------------------------
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id ||
                     ', Task Type = ' || p_task_type || ', MR count = ' || p_MR_Serial_tbl.count);
   END IF;

   IF p_MR_Serial_tbl.count > 0 THEN
      y := p_MR_Serial_tbl.FIRST;
      LOOP
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'MR ID = ' || p_MR_Serial_tbl(y).MR_ID);
         END IF;

         -- Cursor to find all MR routes under the current MR
         OPEN c_MR_route (p_MR_Serial_tbl(y).MR_ID);
         LOOP
         FETCH c_MR_route INTO l_route_id;
         EXIT WHEN c_MR_route%NOTFOUND;

         -- Cursor to find the count of number of MR routes
         -- which have parent-child relationship with the current MR Route
         OPEN c_route_seq_ct (l_route_id);
         FETCH c_route_seq_ct INTO l_count;
         CLOSE c_route_seq_ct;

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Route sequence count = ' || l_count);
         END IF;

         IF l_count > 0 THEN

            -- To know parent-child MR Routes in AHL_MR_ROUTE_SEQUENCES
            OPEN c_route_seq (l_route_id);
            LOOP
            FETCH c_route_seq INTO c_route_seq_rec;
            EXIT WHEN c_route_seq%NOTFOUND;
            l_parent_task_id := 0;
            l_child_task_id  := 0;

            IF p_task_type = 'UNPLANNED' THEN  -- For Unplanned task: Serial Id remains same for all Routes within a MR
               l_serial_id   :=  p_MR_Serial_tbl(y).SERIAL_ID ;

               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Task type code = ' || p_task_type || ', MR ROUTE = ' || c_route_seq_rec.MR_ROUTE_ID);
               END IF;

               OPEN c_route_task (c_route_seq_rec.MR_ROUTE_ID, l_serial_id, p_visit_id, p_task_type);
               FETCH c_route_task INTO l_parent_task_id;
               CLOSE c_route_task;

               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Parent Id = ' || l_parent_task_id || ', RELATED MR ROUTE = ' || c_route_seq_rec.RELATED_MR_ROUTE_ID);
               END IF;

               OPEN c_route_task (c_route_seq_rec.RELATED_MR_ROUTE_ID, l_serial_id, p_visit_id, p_task_type);
               FETCH c_route_task INTO l_child_task_id;
               CLOSE c_route_task;

               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Child Id = ' || l_child_task_id);
               END IF;

               IF l_parent_task_id <> 0 AND l_child_task_id <> 0 THEN
                  IF (l_log_statement >= l_log_current_level) THEN
                     fnd_log.string(l_log_statement,
                                    L_DEBUG_KEY,
                                    'Parent Id = ' || l_parent_task_id || ', Child Id = ' || l_child_task_id);
                  END IF;
                  l_tsk_flag := 'Y';
               ELSE
                  l_tsk_flag := 'N';
               END IF;

            ELSE -- Else of p_task_type = 'UNPLANNED' check
            -- For Planned task Serial Id are different for each MR Route within a MR,
            -- because of Unit effectivites relations

               l_serial_id   :=  p_MR_Serial_tbl(y).SERIAL_ID ;

               OPEN c_route_task (c_route_seq_rec.MR_ROUTE_ID, l_serial_id, p_visit_id, p_task_type);
               FETCH c_route_task INTO l_parent_task_id;
               CLOSE c_route_task;

               OPEN c_route_task (c_route_seq_rec.RELATED_MR_ROUTE_ID, l_serial_id, p_visit_id, p_task_type);
               FETCH c_route_task INTO l_child_task_id;
               CLOSE c_route_task;

               IF l_parent_task_id <> 0 AND l_child_task_id <> 0 THEN
                  l_tsk_flag := 'Y';
               ELSE
                  l_tsk_flag := 'N';
               END IF;

            END IF; -- End of check p_task_type = 'UNPLANNED' check

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Value of L_TSK_FLAG after task type check' || l_tsk_flag);
            END IF;

            IF l_tsk_flag = 'Y' THEN
               SELECT ahl_task_links_s.nextval INTO l_task_link_id FROM DUAL;

               IF l_task_rec.attribute_category = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute_category := NULL;
               END IF;
               --
               IF l_task_rec.attribute1 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute1 := NULL;
               END IF;
               --
               IF  l_task_rec.attribute2 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute2 := NULL;
               END IF;
               --
               IF l_task_rec.attribute3 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute3 := NULL;
               END IF;
               --
               IF l_task_rec.attribute4 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute4 := NULL;
               END IF;
               --
               IF l_task_rec.attribute5 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute5 := NULL;
               END IF;
               --
               IF l_task_rec.attribute6 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute6 := NULL;
               END IF;
               --
               IF l_task_rec.attribute7 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute7 := NULL;
               END IF;
               --
               IF l_task_rec.attribute8 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute8 := NULL;
               END IF;
               --
               IF l_task_rec.attribute9 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute9 := NULL;
               END IF;
               --
               IF l_task_rec.attribute10 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute10 := NULL;
               END IF;
               --
               IF  l_task_rec.attribute11 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute11 := NULL;
               END IF;
               --
               IF  l_task_rec.attribute12 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute12 := NULL;
               END IF;
               --
               IF  l_task_rec.attribute13 = Fnd_Api.G_MISS_CHAR THEN
                 l_task_rec.attribute13 := NULL;
               END IF;
               --
               IF  l_task_rec.attribute14 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute14 := NULL;
               END IF;
               --
               IF  l_task_rec.attribute15 = Fnd_Api.G_MISS_CHAR THEN
                  l_task_rec.attribute15 := NULL;
               END IF;

               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'Before inserting record into AHL_TASK_LINKS');
               END IF;

               INSERT INTO AHL_TASK_LINKS
               (
                TASK_LINK_ID,OBJECT_VERSION_NUMBER, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, VISIT_TASK_ID, PARENT_TASK_ID,
                ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
                ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
                ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
               )
               VALUES
               (
                l_TASK_LINK_ID, 1,sysdate, fnd_global.user_id, sysdate,
                fnd_global.user_id, fnd_global.user_id, l_child_task_id, l_parent_task_id,
                l_task_rec.ATTRIBUTE_CATEGORY, l_task_rec.ATTRIBUTE1, l_task_rec.ATTRIBUTE2,
                l_task_rec.ATTRIBUTE3, l_task_rec.ATTRIBUTE4, l_task_rec.ATTRIBUTE5,
                l_task_rec.ATTRIBUTE6, l_task_rec.ATTRIBUTE7, l_task_rec.ATTRIBUTE8,
                l_task_rec.ATTRIBUTE9, l_task_rec.ATTRIBUTE10,l_task_rec.ATTRIBUTE11,
                l_task_rec.ATTRIBUTE12, l_task_rec.ATTRIBUTE13, l_task_rec.ATTRIBUTE14,
                l_task_rec.ATTRIBUTE15
               );

               IF (l_log_statement >= l_log_current_level) THEN
                  fnd_log.string(l_log_statement,
                                 L_DEBUG_KEY,
                                 'After inserting record into AHL_TASK_LINKS');
               END IF;
            END IF; --  -- End of check l_tsk_flag = 'Y'
         END LOOP;
         CLOSE c_route_seq;
      END IF; -- End of check l_count > 0

   END LOOP;
   CLOSE c_MR_route;

   EXIT WHEN y = p_MR_Serial_tbl.LAST ;
   y := p_MR_Serial_tbl.NEXT(y);
END LOOP;
END IF; -- End of check p_MR_Id_tbl.count > 0
   x_return_status := Fnd_Api.g_ret_sts_success;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
END Tech_Dependency;

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Tasks_for_MR
--
-- PURPOSE
--    To create tasks for MR
--------------------------------------------------------------------
PROCEDURE Create_Tasks_for_MR
 (  p_visit_id       IN            NUMBER,
    p_unit_id        IN            NUMBER,
    p_item_id        IN            NUMBER,
    p_org_id         IN            NUMBER,
    p_serial_id      IN            NUMBER,
    p_mr_id          IN            NUMBER,
    p_department_id  IN            NUMBER,
    p_service_req_id IN            NUMBER,
    -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Added past task start and end dates
    p_past_task_start_date  IN DATE := NULL,
    p_past_task_end_date    IN DATE := NULL,
    -- Added by rnahata for Issue 105
    p_quantity       IN            NUMBER,
    -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
    p_task_start_date IN    DATE := NULL,
    p_x_parent_MR_Id IN OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2)
IS
   -- Define local variables
   L_API_NAME   CONSTANT VARCHAR2(30) := 'Create_Tasks_for_MR';
   L_DEBUG_KEY  CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   -- Define Cursors
   -- To find MR_ROUTE_ID for the particular MR_HEADER_ID
   CURSOR c_MR_route(x_mr_id IN NUMBER) IS
   -- AnRaj: Changes made for fixing bug#4919353, issue# 10
    SELECT T1.MR_ROUTE_ID,
    -- Added for 11.5.10 Changes done by Senthil.
           T1.STAGE
    FROM AHL_MR_ROUTES_V T1, AHL_ROUTES_B T2
    WHERE T1.MR_HEADER_ID = x_mr_id
     AND T1.ROUTE_ID = T2.ROUTE_ID
     AND T2.REVISION_STATUS_CODE = 'COMPLETE'
     -- Added as of Bug# 3562914
     -- By shbhanda 04/22/2004
     AND T1.ROUTE_REVISION_NUMBER
         IN (SELECT MAX(T3.ROUTE_REVISION_NUMBER)
             FROM AHL_MR_ROUTES_V T3
             WHERE T3.MR_HEADER_ID = x_mr_id
              AND T3.ROUTE_NUMBER = T1.ROUTE_NUMBER
             GROUP BY T3.ROUTE_NUMBER
            );

   -- To find any visit task exists for the retrieve Serial Number, Unit Effectivity ID and MR Route ID and other info
   CURSOR c_task (x_mroute_id IN NUMBER, x_serial_id IN NUMBER, x_unit_id IN NUMBER) IS
    SELECT Visit_Id, Visit_Task_id
    FROM AHL_VISIT_TASKS_B
    WHERE MR_Route_Id = x_mroute_id
     AND Instance_Id = x_serial_id
     AND Unit_Effectivity_Id = x_unit_id
     AND (STATUS_CODE IS NULL OR STATUS_CODE <> 'DELETED');
    c_task_rec c_task%ROWTYPE;

   -- To find on the basis of input unit effectivity the related information
   CURSOR c_info(x_mr_header_id IN NUMBER, x_unit_id IN NUMBER, x_serial_id IN NUMBER) IS
    SELECT CSI.INV_MASTER_ORGANIZATION_ID, CSI.INVENTORY_ITEM_ID
    FROM AHL_UNIT_EFFECTIVITIES_VL AUEB, CSI_ITEM_INSTANCES CSI
    WHERE AUEB.CSI_ITEM_INSTANCE_ID = CSI.INSTANCE_ID
     AND AUEB.CSI_ITEM_INSTANCE_ID = x_serial_id
     AND (AUEB.STATUS_CODE IS NULL OR AUEB.STATUS_CODE = 'INIT-DUE')
     AND AUEB.UNIT_EFFECTIVITY_ID = x_unit_id
     AND AUEB.MR_HEADER_ID = x_mr_header_id;

   -- To find any visit task exists for the retrieve Serial Number, Unit Effectivity ID and MR Route ID and other info
   CURSOR c_task_chk (x_id IN NUMBER, x_mr_id IN NUMBER, x_serial_id in NUMBER) IS
    SELECT AMHV.Title
    FROM AHL_VISIT_TASKS_B AVTB, AHL_MR_HEADERS_APP_V AMHV
    WHERE AVTB.MR_ID = AMHV.MR_HEADER_ID
     AND AVTB.MR_Id =  x_mr_id
     AND AVTB.Instance_Id = x_serial_id
     AND AVTB.VISIT_ID = x_id
     AND (AVTB.STATUS_CODE IS NULL OR AVTB.STATUS_CODE <> 'DELETED');
     c_task_chk_rec c_task_chk%ROWTYPE;

   CURSOR c_stage(p_stage_number IN NUMBER, p_visit_id IN NUMBER) IS
    SELECT stage_id,
           stage_name
    FROM ahl_vwp_stages_vl
    WHERE stage_num = p_stage_number
     AND visit_id = p_visit_id;

   CURSOR c_mr_title(p_mr_id IN NUMBER) IS
    SELECT TITLE
    FROM ahl_mr_headers_b
    WHERE mr_header_id = p_mr_id;

   CURSOR c_task_det(p_visit_task_id NUMBER) IS
    SELECT visit_task_id,
           start_date_time,
           end_date_time
    FROM   ahl_visit_tasks_b
    WHERE  visit_task_id = p_visit_task_id;

l_task_det c_task_det%rowtype;

 -- Table type for storing MR Route Id
   TYPE MR_Route_Tbl_Type IS TABLE OF INTEGER
   INDEX BY BINARY_INTEGER;

 -- Table type for storing MR Route Id
 -- 11.5.10 Changes done by Senthil.
   TYPE Stage_num_Tbl_Type IS TABLE OF INTEGER
   INDEX BY BINARY_INTEGER;

   MR_Route_Tbl         MR_Route_Tbl_Type;
   l_Stage_num_Tbl      Stage_num_Tbl_Type;
   l_return_status      VARCHAR2(1);
   l_msg_data           VARCHAR2(2000);
   l_planned_order_flag VARCHAR2(1);
   l_msg_count          NUMBER;
   l_visit_id           NUMBER;
   l_Unit_Id            NUMBER;
   l_MR_Id              NUMBER;
   l_serial_id          NUMBER;
   l_service_req_id     NUMBER;
   l_department_id      NUMBER;
   l_parent_MR_Id       NUMBER;
   l_org_id             NUMBER;
   l_item_id            NUMBER;
   l_mr_route_id        NUMBER;
   l_task_id            NUMBER;
   l_parent_task_id     NUMBER;
   i                    NUMBER;
   l_stage_number       NUMBER;
   l_stage_name         VARCHAR2(80);
   l_stage_id           NUMBER;
   l_mr_title           VARCHAR2(80);

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. p_visit_id' || p_visit_id ||
                      ', p_unit_id' || p_unit_id || ', p_item_id' || p_item_id ||
                      ', p_mr_id' || p_mr_id || ', p_service_req_id' || p_service_req_id ||
                      ', p_quantity' || p_quantity);
   END IF;
   l_visit_id      :=  p_visit_id;
   l_Unit_Id       :=  p_Unit_Id ;
   l_MR_Id         :=  p_MR_Id   ;
   l_serial_id     :=  p_serial_id ;
   l_service_req_id:=  p_service_req_id;
   l_department_id :=  p_department_id;
   l_parent_MR_Id  :=  p_x_parent_MR_Id;

   IF l_Unit_Id IS NOT NULL then
      -- Cursor to find MR Id, Uniteffectivty and Serial with in task entity.
      -- Check if the results falls in the same visit as the input visit
      OPEN c_task(l_MR_id, l_serial_id, l_unit_Id);
      FETCH c_task INTO c_task_rec;

      IF c_task%FOUND THEN
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Inner c_task found. Unit Effectivity is found');
         END IF;
         CLOSE c_task;
         OPEN c_mr_title(l_MR_id);
         FETCH c_mr_title into l_mr_title;
         CLOSE c_mr_title;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_VISIT_TASK_FOUND');
         FND_MESSAGE.SET_TOKEN('MR',l_mr_title);
         Fnd_Msg_Pub.ADD;

      ELSE -- else of c_task cursor found or not
         --Dup-MR ER#6338208 - sowsubra - start
         --commented to allow duplicate MR's in a visit
         /*
         -- Cursor to find MR and Serial with in all tasks of a visit.
         OPEN c_task_chk(l_visit_id, l_MR_Id, l_serial_id);
         FETCH c_task_chk INTO c_task_chk_rec;
         IF c_task_chk%FOUND THEN
            IF (l_log_statement >= l_log_current_level)THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              ' Inner c_task2 found');
            END IF;
            Fnd_Message.SET_NAME('AHL','AHL_VWP_MR_FOUND');
            Fnd_Message.SET_TOKEN('MR_TITLE',c_task_chk_rec.title);
            Fnd_Msg_Pub.ADD;
         ELSE
         */
         --Dup-MR ER#6338208 - sowsubra - end

         -- To retrieve Item Id and Organization Id with the input Unit Effectivity and MR Id
         OPEN c_info (l_MR_Id, l_Unit_Id, l_serial_id);
         FETCH c_info INTO l_org_id, l_item_id;
         CLOSE c_info;

         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'c_info cursor - Organization = '||l_org_id ||
                           'and Item = ' || l_item_id);
         END IF;
        --Dup-MR ER#6338208 - sowsubra - commented out
         --  END IF;
         --  CLOSE c_task_chk;
      END IF;
      CLOSE c_task;
   ELSE
      -- Cursor to find MR and Serial with in all tasks of a visit.
        --Dup-MR ER#6338208 - sowsubra - start
        --commented to allow duplicate MR's in a visit
      /*
      OPEN c_task_chk(l_visit_id, l_MR_Id, l_serial_id);
      FETCH c_task_chk INTO c_task_chk_rec;
      IF c_task_chk%FOUND THEN
         IF (l_log_statement >= l_log_current_level)THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           ' Inner c_task2 found');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_MR_FOUND');
         Fnd_Message.SET_TOKEN('MR_TITLE',c_task_chk_rec.title);
         Fnd_Msg_Pub.ADD;
      END IF;
      CLOSE c_task_chk;
      */
          --Dup-MR ER#6338208 - sowsubra - end

      l_item_id  := p_item_id;
      l_org_id   := p_org_id;
   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'Before calling INSERT_TASKS for Summary Task. Task Id = ' || l_task_id);
   END IF;

   INSERT_TASKS
         (p_visit_id        => l_visit_id,
          p_unit_id         => l_unit_id,
          p_serial_id       => l_serial_id,
          p_service_id      => l_service_req_id,
          p_dept_id         => l_department_id,
          p_item_id         => l_item_id,
          p_item_org_id     => l_org_id,
          p_mr_id           => l_MR_id,
          p_mr_route_id     => NULL,
          p_parent_id       => l_parent_MR_Id,
          p_flag            => 'Y',
          P_STAGE_ID        => NULL,
          -- Added by rnahata for Issue 105 - pass the quantity for summary task
          p_quantity        => p_quantity,
	  -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
          p_task_start_date => p_task_start_date,
          x_task_id         => l_task_id,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data);

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string(l_log_statement,
                     L_DEBUG_KEY,
                     'After calling INSERT_TASKS for Summary Task. Task Id = ' || l_task_id ||
                     '. Return Status = ' || l_return_status);
   END IF;

   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Errors from INSERT_TASKS. Message count: ' ||
                        l_msg_count || ', message data: ' || l_msg_data);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   p_x_parent_MR_Id := l_task_id;  -- To get MR as parent for child summary tasks
   l_parent_Task_Id := l_task_id;  -- To get MR as parent for child planned/unplanned tasks

   /*
     y := 0;
     -- To retrieve all MR Route Id's for MR Header Id

     OPEN c_MR_route (l_MR_Id);
     FETCH c_MR_route INTO l_mr_route_id,l_stage_number;
     WHILE c_MR_route%FOUND LOOP
        MR_Route_Tbl(y) := l_mr_route_id;
        y := y + 1;
     FETCH c_MR_route INTO l_mr_route_id;
     END LOOP;
     CLOSE c_MR_route;
   */

   -- To retrieve all MR Route Id's for MR Header Id
   --  11.5.10 Changes by Senthil.
   -- AnRaj: Changes made for fixing bug#4919353, issue# 11
   SELECT T1.MR_ROUTE_ID, T1.STAGE
   BULK COLLECT INTO MR_Route_Tbl,l_Stage_num_Tbl
   FROM AHL_MR_ROUTES_V T1, AHL_ROUTES_B T2
   WHERE T1.MR_HEADER_ID = l_MR_Id
    AND T1.ROUTE_ID = T2.ROUTE_ID
    AND T2.revision_status_code = 'COMPLETE'
    AND T1.ROUTE_REVISION_NUMBER IN
        (SELECT MAX(T3.ROUTE_REVISION_NUMBER)
         FROM   AHL_MR_ROUTES_V T3
         WHERE  T3.MR_HEADER_ID = l_MR_Id
          AND T3.ROUTE_NUMBER = T1.ROUTE_NUMBER
         GROUP BY T3.ROUTE_NUMBER
        );

   -- To Create Planned Tasks
   i := 0 ;
   IF MR_Route_Tbl.COUNT > 0 THEN
      i := MR_Route_Tbl.FIRST;
      LOOP
         IF l_Stage_num_Tbl(i) IS NOT NULL THEN
            OPEN c_stage(l_Stage_num_Tbl(i),l_visit_id);
            FETCH c_stage INTO l_stage_id, l_stage_name ;
            IF c_stage%NOTFOUND THEN
               Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_NO_EXIST');
               Fnd_Msg_Pub.ADD;
               CLOSE c_stage;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE c_stage;
         END IF;
---  End of 11.5.10 Changes by Senthil.

         l_mr_route_id := MR_Route_Tbl(i);

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'l_mr_route_id = ' || l_mr_route_id);
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Before calling INSERT_TASKS for Simple Task');
         END IF;

         INSERT_TASKS
            (p_visit_id        => l_visit_id,
             p_unit_id         => l_unit_id,
             p_serial_id       => l_serial_id,
             p_service_id      => l_service_req_id,
             p_dept_id         => l_department_id,
             p_item_id         => l_item_id,
             p_item_org_id     => l_org_id,
             p_mr_id           => l_MR_Id,
             p_MR_Route_id     => l_MR_route_id,
             p_parent_id       => l_parent_task_id,
             p_flag            => 'N',
             P_STAGE_ID        => l_stage_id,
             -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: Pass past dates too
             p_past_task_start_date => p_past_task_start_date,
             p_past_task_end_date => p_past_task_end_date,
             -- Added by rnahata for Issue 105 - pass the quantity for the simple tasks
             p_quantity        => p_quantity,
             -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
             p_task_start_date => p_task_start_date,
             x_task_id         => l_task_id,
             x_return_status   => l_return_status,
             x_msg_count       => l_msg_count,
             x_msg_data        => l_msg_data);

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'After calling INSERT_TASKS for Simple Task. Task Id = ' || l_task_id ||
                           '. Visit ID = ' || l_visit_id);
         END IF;

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Errors from INSERT_TASKS. Message count: ' ||
                              l_msg_count || ', message data: ' || l_msg_data);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- To call LTP Process Materials API for APS Integration by Shbhanda 04-Dec-03
         OPEN c_task_det(l_task_id);
         FETCH c_task_det INTO l_task_det;
         CLOSE c_task_det;

         IF l_task_det.start_date_time IS NOT NULL THEN

            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'PLANNED TASK - Before calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
            END IF;
            AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials (
                p_api_version          => 1.0,
                p_init_msg_list        => FND_API.g_false,
                p_commit               => FND_API.g_false,
                p_validation_level     => FND_API.g_valid_level_full,
                p_visit_id             => l_Visit_Id,
                p_visit_task_id        => l_Task_Id,
                p_org_id               => NULL,
                p_start_date           => NULL,
                p_operation_flag       => 'C',
                x_planned_order_flag   => l_planned_order_flag ,
                x_return_status        => x_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data );
            IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string(l_log_statement,
                               L_DEBUG_KEY,
                               'PLANNED TASK - After calling AHL_LTP_REQST_MATRL_PVT.Process_Planned_Materials');
            END IF;
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 OR l_return_status <> Fnd_Api.g_ret_sts_success THEN
                X_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; --check for Visit Task Start Date

         EXIT WHEN i = MR_Route_Tbl.LAST ;
         i := MR_Route_Tbl.NEXT(i);
      END LOOP;
   END IF;

   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status ||
                     ', p_x_parent_MR_Id = ' || p_x_parent_MR_Id);
   END IF;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
   WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        RAISE;
END Create_Tasks_for_MR;


--------------------------------------------------------------------
-- PROCEDURE
--    Check_Cost_Parent_Loop
--
-- PURPOSE
--    To check if the cost parent task not forming loop among other tasks
--------------------------------------------------------------------
PROCEDURE Check_Cost_Parent_Loop
    (p_visit_id       IN  NUMBER,
     p_visit_task_id  IN  NUMBER,
     p_cost_parent_id IN  NUMBER
    )
IS
   -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30)  := 'Check_Cost_Parent_Loop';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  -- Define local cursors
  -- For all children of cost_parent_id
  CURSOR c_child (c_cost_id IN NUMBER, c_id IN NUMBER) IS
   SELECT VISIT_TASK_ID FROM AHL_VISIT_TASKS_B
   WHERE VISIT_ID = c_id
   START WITH COST_PARENT_ID = c_cost_id
   CONNECT BY PRIOR VISIT_TASK_ID = COST_PARENT_ID;
   c_child_rec c_child%ROWTYPE;

BEGIN
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure. Visit Id = ' || p_visit_id ||
                    'Visit Task Id = ' || p_visit_task_id || 'Cost Parent Id = ' || p_cost_parent_id);
  END IF;
  -- Check for cost parent task id not forming loop
  IF (p_cost_parent_id IS NOT NULL AND
      p_cost_parent_id <> Fnd_Api.G_MISS_NUM ) THEN

      IF p_cost_parent_id = p_visit_task_id THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'p_cost_parent_id = p_visit_task_id');
         END IF;
         Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_COST_LOOP');
         Fnd_Msg_Pub.ADD;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      OPEN c_child (p_visit_task_id, p_visit_id);
      LOOP
         FETCH c_child INTO c_child_rec;

         IF p_cost_parent_id = c_child_rec.VISIT_TASK_ID THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'TASK LOOP');
            END IF;
            Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_COST_LOOP');
            Fnd_Msg_Pub.ADD;
            CLOSE c_child;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         EXIT WHEN c_child%NOTFOUND;
      END LOOP;
      CLOSE c_child;
   END IF;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure.');
   END IF;

END Check_Cost_Parent_Loop;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Origin_Task_Loop
--
-- PURPOSE
--    To check if the originating task not forming loop among other tasks
--------------------------------------------------------------------
PROCEDURE Check_Origin_Task_Loop
  (p_visit_id            IN  NUMBER,
   p_visit_task_id       IN  NUMBER,
   p_originating_task_id IN NUMBER
   )
IS
 -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Origin_Task_Loop';
   L_DEBUG_KEY CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

 -- Define local cursors
 -- For all children of originating_task_id
    CURSOR c_child (x_org_id IN NUMBER, x_id IN NUMBER) IS
     SELECT VISIT_TASK_ID FROM AHL_VISIT_TASKS_B
     WHERE VISIT_ID = x_id
      AND NVL(STATUS_CODE,'X') <> 'DELETED'
     START WITH ORIGINATING_TASK_ID = x_org_id
     CONNECT BY PRIOR VISIT_TASK_ID = ORIGINATING_TASK_ID;
    c_child_rec c_child%ROWTYPE;

BEGIN
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Visit Id = ' || p_visit_id || '. Visit Task Id = ' ||
                      p_visit_task_id || '. Originating Task Id' || p_originating_task_id);
    END IF;
    -- Check for originating task id not forming loop
    IF (p_originating_task_id IS NOT NULL AND
        p_originating_task_id <> Fnd_Api.G_MISS_NUM ) THEN

       IF p_originating_task_id = p_visit_task_id THEN
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'TASK LOOP1');
          END IF;
          Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_ORIGIN_LOOP');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       OPEN c_child (p_visit_task_id, p_visit_id);
       LOOP
       FETCH c_child INTO c_child_rec;

       IF p_originating_task_id = c_child_rec.VISIT_TASK_ID THEN
          IF (l_log_statement >= l_log_current_level) THEN
             fnd_log.string(l_log_statement,
                            L_DEBUG_KEY,
                            'TASK LOOP2');
          END IF;

          Fnd_Message.SET_NAME('AHL','AHL_VWP_NO_ORIGIN_LOOP');
          Fnd_Msg_Pub.ADD;
          CLOSE c_child;
          RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

       EXIT WHEN c_child%NOTFOUND;
       END LOOP;
       CLOSE c_child;
    END IF;
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL procedure.');
    END IF;
END Check_Origin_Task_Loop;

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Visit_Task_Flag
--
-- PURPOSE
--    To update visit entity any_task_chg_flag attribute whenever there
--    are changes in visit task - either addition or deletion or change
--    in cost parent of any task
--------------------------------------------------------------------
PROCEDURE Update_Visit_Task_Flag
    (p_visit_id       IN  NUMBER,
     p_flag           IN  VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2
    )
IS
 -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Visit_Task_Flag';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id ||
                     'p_flag' || p_flag);
   END IF;
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF p_visit_id  IS NOT NULL THEN
      UPDATE AHL_VISITS_B
      SET OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
      --TCHIMIRA::BUG 9222622 ::15-DEC-2009::UPDATE WHO COLUMNS
          LAST_UPDATE_DATE      = SYSDATE,
          LAST_UPDATED_BY       = Fnd_Global.USER_ID,
          LAST_UPDATE_LOGIN     = Fnd_Global.LOGIN_ID,
          ANY_TASK_CHG_FLAG = p_flag
      WHERE VISIT_ID = p_visit_id;
   END IF;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
END Update_Visit_Task_Flag;

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Price_List_Name_Or_Id
--
-- PURPOSE
--    To find out price list id for price list name for a visit or tasks
--------------------------------------------------------------------
PROCEDURE Check_Price_List_Name_Or_Id(
     p_visit_id        IN         NUMBER,
     p_price_list_name IN         VARCHAR2,
     x_price_list_id   OUT NOCOPY NUMBER,
     x_return_status   OUT NOCOPY VARCHAR2
     ) IS
 -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Price_List_Name_Or_Id';
   L_DEBUG_KEY CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   CURSOR visit_info_csr(p_visit_id IN NUMBER)IS
   SELECT service_request_id FROM ahl_visits_b
   WHERE visit_id = p_visit_id;

   l_service_request_id NUMBER;

   CURSOR customer_id_csr(p_service_request_id IN NUMBER)IS
   SELECT customer_id FROM CS_INCIDENTS_ALL_B
   WHERE incident_id = p_service_request_id;

   l_customer_id NUMBER;

   /*CURSOR price_list_id_csr(p_price_list_name IN VARCHAR2,p_customer_id IN NUMBER)IS
   SELECT qlhv.list_header_id
   FROM qp_list_headers_vl qlhv, FINANCIALS_SYSTEM_PARAMETERS FSP, qp_qualifiers qpq, GL_SETS_OF_BOOKS GSB
   WHERE FSP.set_of_books_id = GSB.set_of_books_id
   AND qlhv.list_type_code = 'PRL'
   AND qlhv.currency_code = gsb.currency_code
   AND UPPER(qlhv.name) like UPPER(p_price_list_name)
   AND qpq.QUALIFIER_ATTR_VALUE = p_customer_id
   AND qpq.list_header_id=qlhv.list_header_id
   AND  qpq.qualifier_context = 'CUSTOMER'
   AND  qpq.qualifier_attribute = 'QUALIFIER_ATTRIBUTE16'
   UNION
   SELECT qlhv.list_header_id
   FROM qp_list_headers_vl qlhv,oe_agreements oa, qp_qualifiers qpq, FINANCIALS_SYSTEM_PARAMETERS FSP, GL_SETS_OF_BOOKS GSB
   WHERE FSP.set_of_books_id = GSB.set_of_books_id
   AND ((oa.price_list_id = qlhv.list_header_id AND qlhv.list_type_code
   IN('PRL', 'AGR')) OR qlhv.list_type_code = 'PRL')
   AND qlhv.currency_code = gsb.currency_code
   AND UPPER(qlhv.name) like UPPER(p_price_list_name)
   AND qpq.QUALIFIER_ATTR_VALUE = p_customer_id
   AND qpq.list_header_id=qlhv.list_header_id
   AND  qpq.qualifier_context = 'CUSTOMER'
   AND  qpq.qualifier_attribute = 'QUALIFIER_ATTRIBUTE16';*/

   CURSOR price_list_id_csr(p_price_list_name IN VARCHAR2,p_customer_id IN NUMBER)IS
   SELECT qlhv.list_header_id
   from qp_list_headers_vl qlhv, qp_qualifiers qpq
   where qlhv.list_type_code = 'PRL'
   and upper(qlhv.name) like upper(p_price_list_name)
   and qpq.QUALIFIER_ATTR_VALUE = p_customer_id
   and qpq.list_header_id=qlhv.list_header_id
   and  qpq.qualifier_context = 'CUSTOMER'
   and  qpq.qualifier_attribute = 'QUALIFIER_ATTRIBUTE16';

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' ||
                     p_visit_id || 'Price List Name = ' || p_price_list_name);
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN visit_info_csr(p_visit_id);
   FETCH visit_info_csr INTO l_service_request_id;
   IF (visit_info_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT');
      FND_MSG_PUB.ADD;
      IF (l_log_unexpected >= l_log_current_level)THEN
         fnd_log.string(l_log_unexpected,
                        L_DEBUG_KEY,
                        'Visit id not found in AHL_VISITS_B table');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ELSIF(l_service_request_id IS NULL)THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_VISIT_UPDT_NOS');
      FND_MSG_PUB.ADD;
      IF (fnd_log.level_error >= l_log_current_level)THEN
         fnd_log.string(fnd_log.level_error,
                        L_DEBUG_KEY,
                        'price list can not be associated because service request id is not associated to visit');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   CLOSE visit_info_csr;

   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RETURN;
   END IF;

   OPEN customer_id_csr(l_service_request_id);
   FETCH customer_id_csr INTO l_customer_id;
   IF(customer_id_csr%NOTFOUND)THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_SR_ID');
      FND_MSG_PUB.ADD;
      IF (l_log_unexpected >= l_log_current_level)THEN
         fnd_log.string(l_log_unexpected,
                        L_DEBUG_KEY,
                        'Associated Service Request ' || l_service_request_id ||
                        ' is invalid as record not found.');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ELSIF(l_customer_id IS NULL)THEN
      FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_INV_SRVREQ_NOCUST');
      FND_MSG_PUB.ADD;
      IF (fnd_log.level_error >= l_log_current_level)THEN
         fnd_log.string(fnd_log.level_error,
                        L_DEBUG_KEY,
                        'Customer id for corresponding service request ' || l_service_request_id || ' is null.');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   CLOSE customer_id_csr;

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RETURN;
   END IF;

   -- find out the price list id
   OPEN price_list_id_csr(p_price_list_name,l_customer_id);
   FETCH price_list_id_csr INTO x_price_list_id;
   IF(price_list_id_csr%NOTFOUND)THEN
     FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_PLIST_NFOUND');
     FND_MESSAGE.Set_Token('PRICE_LIST',p_price_list_name);
     FND_MSG_PUB.ADD;
     IF (fnd_log.level_error >= l_log_current_level)THEN
        fnd_log.string(fnd_log.level_error,
                       L_DEBUG_KEY,
                       'Valid price list not found with price list name ' || p_price_list_name);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   CLOSE price_list_id_csr;

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RETURN;
   END IF;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. x_price_list_id = ' || x_price_list_id);
   END IF;

END Check_Price_List_Name_Or_Id;
--------------------------------------------------------------------
-- PROCEDURE
--    Update_Cost_Origin_Task
--
-- PURPOSE
--    To update all tasks which have the deleting task as cost or originating task
--------------------------------------------------------------------
PROCEDURE Update_Cost_Origin_Task
    (p_visit_task_id  IN  NUMBER,
     x_return_status  OUT NOCOPY VARCHAR2
    )
IS
   -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Update_Cost_Origin_Task';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_task_id            NUMBER;

   -- To find any task which have originating id as deleted task id
   CURSOR c_origin (x_task_id IN NUMBER) IS
    SELECT Visit_Task_Id, Object_Version_Number
    FROM  Ahl_Visit_Tasks_VL
    WHERE ORIGINATING_TASK_ID = x_task_id;
   c_origin_rec      c_origin%ROWTYPE;

   -- To find any task which have parent id as deleted task id
   CURSOR c_parent (x_task_id IN NUMBER) IS
    SELECT Visit_Task_Id, Object_Version_Number
    FROM  Ahl_Visit_Tasks_VL
    WHERE COST_PARENT_ID = x_task_id;
   c_parent_rec      c_parent%ROWTYPE;

   -- Post 11.5.10
   --RR
   -- For updating the Cost Parent Task
   CURSOR c_parent_id(x_task_id IN NUMBER) IS
    SELECT cost_parent_id
    FROM AHL_VISIT_TASKS_VL
    WHERE visit_task_id = x_task_id;
   l_parent_id NUMBER;
   -- Post 11.5.10
   --RR
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Task Id = ' || p_visit_task_id);
   END IF;
   l_task_id := p_visit_task_id;

   -- Post 11.5.10
   -- RR
   OPEN c_parent_id(l_task_id);
   FETCH c_parent_id INTO l_parent_id;
   CLOSE c_parent_id;

   -- To find if a task deleted is the "originating task" for another task,
   -- then association/s must be removed before the task can be deleted.
   OPEN c_origin (l_task_id);
   LOOP
       FETCH c_origin INTO c_origin_rec;
       EXIT WHEN c_origin%NOTFOUND;
       IF c_origin_rec.visit_task_id IS NOT NULL THEN
           IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'update origin');
           END IF;
           UPDATE AHL_VISIT_TASKS_B SET ORIGINATING_TASK_ID = NULL,
           OBJECT_VERSION_NUMBER = c_origin_rec.object_version_number + 1
           WHERE VISIT_TASK_ID = c_origin_rec.visit_task_id;
       END IF;
   END LOOP;
   CLOSE c_origin;

   -- To find if a task deleted is the "cost parent task" for another task,
   -- then association/s must be removed before the task can be deleted.
   -- Post 11.5.10
   -- RR
   OPEN c_parent (l_task_id);
   LOOP
       FETCH c_parent INTO c_parent_rec;
       EXIT WHEN c_parent%NOTFOUND;
       IF c_parent_rec.visit_task_id IS NOT NULL THEN
          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string(l_log_statement,
                             L_DEBUG_KEY,
                             'update parent');
          END IF;
          UPDATE AHL_VISIT_TASKS_B SET COST_PARENT_ID = l_parent_id,
          OBJECT_VERSION_NUMBER = c_parent_rec.object_version_number + 1
          WHERE VISIT_TASK_ID = c_parent_rec.visit_task_id;
       END IF;
   END LOOP;
   CLOSE c_parent;
   -- RR
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
END Update_Cost_Origin_Task;

--------------------------------------------------------------------
-- PROCEDURE
--    Merge_for_Unique_Items
--
-- PURPOSE
--    To merge two item tables and remove the redundant items
--    in table for which no price is defined
--------------------------------------------------------------------
PROCEDURE Merge_for_Unique_Items
    (p_item_tbl1  IN  Item_Tbl_Type,
     p_item_tbl2  IN  Item_Tbl_Type,
     x_item_tbl   OUT NOCOPY Item_Tbl_Type
     )
IS
 -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Merge_for_Unique_Items';
   L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_index              NUMBER:=0;
   l_item_present       boolean:=false;
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. p_item_tbl1.count = ' || p_item_tbl1.count ||
                     '. p_item_tbl2.count = ' || p_item_tbl2.count);
   END IF;

   IF p_item_tbl1.count > 0 THEN
      x_item_tbl := p_item_tbl1;
      l_index:=x_item_tbl.count;
   ELSE
      x_item_tbl := p_item_tbl2;
      RETURN;
   END IF;

   IF p_item_tbl2.count > 0 THEN
      FOR i IN p_item_tbl2.first ..p_item_tbl2.last
      LOOP
         l_item_present:=false;
         IF x_item_tbl.count > 0 THEN
            FOR k IN  x_item_tbl.first .. x_item_tbl.last
            LOOP
               IF x_item_tbl(k).item_id=p_item_tbl2(i).item_id
               AND  x_item_tbl(k).uom_code=p_item_tbl2(i).uom_code
               AND  x_item_tbl(k).effective_date=p_item_tbl2(i).effective_date
               THEN
                  IF x_item_tbl(k).duration is not NULL AND x_item_tbl(k).duration <> FND_API.G_MISS_NUM
                      AND p_item_tbl2(i).duration is not NULL AND p_item_tbl2(i).duration <> FND_API.G_MISS_NUM THEN
                      x_item_tbl(k).duration := nvl(x_item_tbl(k).duration,0)+nvl(p_item_tbl2(i).duration,0);
                      l_item_present:=true;
                  ELSIF (x_item_tbl(k).duration is NULL OR x_item_tbl(k).duration = FND_API.G_MISS_NUM )
                         AND (p_item_tbl2(i).duration is NULL OR p_item_tbl2(i).duration = FND_API.G_MISS_NUM) THEN
                         x_item_tbl(k).quantity := nvl(x_item_tbl(k).quantity,0)+nvl(p_item_tbl2(i).quantity,0);
                         l_item_present:=true;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         IF l_item_present=FALSE THEN
            l_index:=l_index+1;
            x_item_tbl(l_index) := p_item_tbl2(i);
         END IF;
      END LOOP;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. x_item_tbl.COUNT = ' || x_item_tbl.COUNT);
   END IF;

END Merge_for_Unique_Items;

-------------------------------------------------------------------
-- PROCEDURE
--    Check_Item_in_Price_List
--
-- PURPOSE
--    To Check if item of MR is defined in price list.
--------------------------------------------------------------------
/* commented as this is not being used anywhere
PROCEDURE Check_Item_in_Price_List
    (p_price_list  IN   NUMBER,
     p_item_id       IN   NUMBER,
     x_item_chk_flag OUT  NOCOPY NUMBER
     )
IS
 -- Define local variables
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Check_Item_in_Price_List';
   L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
   l_item_chk_flag        VARCHAR2(1) ;
   I                      NUMBER;

     CURSOR c_task(p_visit_id NUMBER, p_tsk_id NUMBER) IS
     SELECT visit_task_id, originating_task_id
     FROM AHL_VISIT_TASKS_B
     WHERE VISIT_ID = p_visit_id
      AND VISIT_TASK_ID = p_tsk_id
      AND (STATUS_CODE IS NULL OR STATUS_CODE <> 'DELETED');
     c_task_rec c_task%ROWTYPE;

BEGIN

   OPEN c_task(p_price_list, p_item_id);
   LOOP
      FETCH c_task INTO c_task_rec;
      EXIT WHEN c_task%NOTFOUND;

      IF c_task_rec.originating_task_id IS NOT NULL THEN
         l_item_chk_flag := 'Y';
         Check_Item_in_Price_List
         ( p_price_list   => p_price_list,
           p_item_id      => c_task_rec.originating_task_id,
           x_item_chk_flag  => l_item_chk_flag);

         IF (l_log_procedure >= l_log_current_level)THEN
            fnd_log.string(l_log_procedure,
                           L_DEBUG_KEY||'.end',
                           'Check for RECURSIVE task id = ' || p_item_id);
         END IF;
      ELSE
         l_item_chk_flag := 'N';
         IF (l_log_procedure >= l_log_current_level)THEN
            fnd_log.string(l_log_procedure,
                           L_DEBUG_KEY||'.end',
                           'Check for NON RECURSIVE task id = ' || p_item_id);
         END IF;
      END IF;
      I:=I+1;
   END LOOP;
   CLOSE c_task;

END Check_Item_in_Price_List;
*/

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Currency_for_Costing
--
-- PURPOSE
--    To used to retrieve currency code and pass as input parameter to Pricing API
--------------------------------------------------------------------
PROCEDURE Check_Currency_for_Costing
    (p_visit_id   IN  NUMBER,
     x_currency_code OUT NOCOPY VARCHAR2
     )
IS
   -- Define local variables
   L_API_NAME  CONSTANT VARCHAR2(30) := 'Check_Currency_for_Costing';
   L_DEBUG_KEY CONSTANT VARCHAR2(100):= 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

   CURSOR organization_csr(p_visit_id IN NUMBER)IS
    SELECT VST.organization_id FROM AHL_VISITS_B VST
    WHERE VST.visit_id = p_visit_id;

   l_org_id NUMBER;

   -- AnRaj:Changes made for fixing bug#4919353, issue# 7
   CURSOR currency_code_csr(p_org_id IN NUMBER) IS
    SELECT currency_code
    FROM cst_acct_info_v COD, GL_SETS_OF_BOOKS GSOB
    WHERE COD.Organization_Id = p_org_id
     AND LEDGER_ID = GSOB.SET_OF_BOOKS_ID
     AND NVL(operating_unit, mo_global.get_current_org_id())= mo_global.get_current_org_id();

   /*SELECT currency_code
   -- into x_currency_code
   FROM   CST_ORGANIZATION_DEFINITIONS COD --,AHL_VISITS_B VST
   WHERE --VST.visit_id = p_visit_id AND
   --COD.Organization_Id = VST.organization_id
   COD.Organization_Id = p_org_id
   AND NVL(operating_unit, mo_global.get_current_org_id())
       = mo_global.get_current_org_id();*/

BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;
   -- FETCH organization id
   OPEN organization_csr(p_visit_id);
   FETCH organization_csr INTO l_org_id;
   CLOSE organization_csr;

   IF (l_org_id IS NOT NULL)THEN
      OPEN currency_code_csr(l_org_id);
      FETCH currency_code_csr INTO x_currency_code;
      IF (currency_code_csr%NOTFOUND)THEN
         FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_VWP_CST_NO_CURRENCY');
         FND_MSG_PUB.ADD;
         IF (fnd_log.level_error >= l_log_current_level)THEN
            fnd_log.string(fnd_log.level_error,
                           L_DEBUG_KEY,
                           'No curency is defined for the organization of the visit. l_org_id = ' || l_org_id);
         END IF;
      END IF;
      CLOSE currency_code_csr;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Currency Code = ' || x_currency_code);
   END IF;
END Check_Currency_for_Costing;
-------------------------------------------------------------------------------
-- PROCEDURE
--    Check_Job_Status
--
-- PURPOSE
--    To find out valid job status on shop floor for a Visit/MR/Task
-------------------------------------------------------------------------------
PROCEDURE Check_Job_Status
    (p_id             IN         NUMBER,
     p_is_task_flag   IN         VARCHAR2,
     x_status_code    OUT NOCOPY NUMBER,
     x_status_meaning OUT NOCOPY VARCHAR2
     )
IS
  -- Define local variables
  L_API_NAME  CONSTANT VARCHAR2(30)  := 'Check_Job_Status';
  L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;

  -- To find if job exists for the visit at shop floor not in Cancelled-7 Or Deleted-22
  CURSOR c_job(x_id IN NUMBER) IS
   SELECT AWO.STATUS_CODE, FLV.MEANING
   FROM AHL_WORKORDERS AWO, FND_LOOKUP_VALUES_VL FLV
   WHERE AWO.VISIT_ID = x_id
    AND AWO.STATUS_CODE <> 7 AND AWO.STATUS_CODE <> 22
    AND FLV.LOOKUP_TYPE(+) = 'AHL_JOB_STATUS'
    AND AWO.STATUS_CODE = FLV.LOOKUP_CODE(+)
    AND AWO.MASTER_WORKORDER_FLAG = 'Y'
    AND AWO.VISIT_TASK_ID IS NULL;

  -- To find if job exists for the Task/MR at shop floor not in Cancelled-7 Or Deleted-22
  CURSOR c_job_tsk(x_id IN NUMBER)IS
   SELECT AWO.STATUS_CODE, FLV.MEANING
   FROM AHL_WORKORDERS AWO, FND_LOOKUP_VALUES_VL FLV
   WHERE AWO.VISIT_TASK_ID = x_id
    AND AWO.STATUS_CODE <> 7 AND AWO.STATUS_CODE <> 22
    AND FLV.LOOKUP_TYPE(+) = 'AHL_JOB_STATUS'
    AND AWO.STATUS_CODE = FLV.LOOKUP_CODE(+);
BEGIN
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Visit OR Task Id = ' || p_id ||
                      'p_is_task_flag = '|| p_is_task_flag);
    END IF;

    IF p_is_task_flag = 'N' THEN -- For Visit
       OPEN c_job(p_id);
       FETCH c_job INTO x_status_code, x_status_meaning;
       CLOSE c_job;
    ELSE -- For MR/Task
       OPEN c_job_tsk(p_id);
       FETCH c_job_tsk INTO x_status_code, x_status_meaning;
       CLOSE c_job_tsk;
   END IF;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Status Code = '|| x_status_code ||
                     'Status Meaning = ' || x_status_meaning);
   END IF;

END Check_Job_Status;

-------------------------------------------------------------------------------
-- PROCEDURE
--    Check_Department_Shift
--
-- PURPOSE
--    To find out valid job status on shop floor for a Visit/MR/Task
-------------------------------------------------------------------------------
PROCEDURE Check_Department_Shift(
    p_dept_id        IN            NUMBER,
    x_return_status  OUT NOCOPY    VARCHAR2
)
is
L_DUMMY VARCHAR2(1);
L_API_NAME  CONSTANT VARCHAR2(30)  := 'Check_Department_Shift';
L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
--
CURSOR get_dept_csr (p_dept_id IN NUMBER) IS
 SELECT 'x'
 FROM AHL_DEPARTMENT_SHIFTS
 WHERE DEPARTMENT_ID = P_DEPT_ID;
--
BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Department Id = ' || p_dept_id);
   END IF;
   IF P_DEPT_ID IS NOT NULL AND P_DEPT_ID <> FND_API.G_MISS_NUM
   THEN
      OPEN get_dept_csr (p_dept_id);
      FETCH get_dept_csr INTO l_dummy;
      IF (get_dept_csr%NOTFOUND) THEN
          x_return_status:= Fnd_Api.G_RET_STS_ERROR;
      ELSE
          x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      END IF;
      CLOSE get_dept_csr;
   ELSE
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   END IF;
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. Return Status = ' || x_return_status);
   END IF;
END CHECK_DEPARTMENT_SHIFT;


-- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: START
-- Added this new procedure
--------------------------------------------------------------------
--  PROCEDURE         : Validate_Past_Task_Dates
--  Type              : Private
--  Purpose           : To validate the past task start and end dates against cost parent/task stages
--  Parameters  :
--
--  Validate_Past_Task_Dates IN Parameters :
--  p_task_rec       IN OUT NOCOPY Task_Rec_Type Required

--  Validate_Past_Task_Dates OUT Parameters :
--  x_return_status    OUT varchar2 Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
PROCEDURE Validate_Past_Task_Dates (
    p_task_rec       IN OUT NOCOPY Task_Rec_Type,
    x_return_status  OUT NOCOPY VARCHAR2
)
IS
L_DUMMY VARCHAR2(1);
L_API_NAME  CONSTANT VARCHAR2(30)  := 'Validate_Past_Task_Dates';
L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
l_cost_parent_id NUMBER;
l_stage_planned_start_time DATE;
l_cum_duration NUMBER;
l_visit_start_date DATE;
l_dept_id NUMBER;

--

-- To fetch the cost parent id corresponding to cost parent number
Cursor get_cost_parent_id (c_cost_parent_number NUMBER,
                           c_visit_id NUMBER)
  IS
  SELECT visit_task_id
  FROM ahl_visit_tasks_b
  WHERE visit_task_number = c_cost_parent_number
  AND visit_id = c_visit_id;


-- To fetch the start and end of the first non-summary parent (in the cost hierarchy) of the task
Cursor get_cost_parent_dates (c_id NUMBER)
  IS
  SELECT start_date_time, end_date_time
  FROM ahl_visit_tasks_b
  WHERE task_type_code<>'SUMMARY'
  START WITH visit_task_id = c_id
  CONNECT BY PRIOR   cost_parent_id = visit_task_id;
  cost_parent_dates_rec get_cost_parent_dates%ROWTYPE;

-- To fetch the start and end of the first non-summary child (in the cost hierarchy) of the task
Cursor get_cost_child_dates (c_id NUMBER)
  IS
  SELECT start_date_time, end_date_time
  FROM ahl_visit_tasks_b
  WHERE task_type_code<>'SUMMARY'
  AND visit_task_id <> c_id
  START WITH visit_task_id = c_id
  CONNECT BY PRIOR visit_task_id = cost_parent_id;
  cost_child_dates_rec get_cost_child_dates%ROWTYPE;

-- To find visit related information
CURSOR c_visit (c_visit_id IN NUMBER)
IS
      SELECT START_DATE_TIME , department_id FROM AHL_VISITS_B
      WHERE VISIT_ID = c_visit_id;

-- Cursor to find out the cumulative duration of all the stages before the stage of this task
CURSOR c_sum_stage_duration (c_stage_name VARCHAR2,
                             c_visit_id NUMBER)
IS
SELECT sum(duration)
FROM AHL_VWP_STAGES_VL
WHERE visit_id = c_visit_id
AND stage_num < (select stage_num
                    from AHL_VWP_STAGES_VL
                    WHERE stage_name = c_stage_name
                    AND visit_id = c_visit_id);
--

BEGIN
   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit task id = ' || p_task_rec.visit_task_id);
   END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get the cost parent id corresponding to the cost parent number
   -- Please note that this cost parent is the new updated cost parent
   -- and hence it is mandatory to pass this to the cursor get_cost_parent_dates
   OPEN get_cost_parent_id (p_task_rec.cost_parent_number, p_task_rec.visit_id);
   FETCH get_cost_parent_id INTO l_cost_parent_id;
   CLOSE get_cost_parent_id;

   -- Get the start and end of this task's first non-summary cost parent in the cost hierarchy
   OPEN get_cost_parent_dates (l_cost_parent_id);
   FETCH get_cost_parent_dates INTO cost_parent_dates_rec;
   CLOSE get_cost_parent_dates;

   -- Validate that this past task's dates are within the first cost parent's dates
   IF cost_parent_dates_rec.start_date_time IS NOT NULL THEN
     IF (cost_parent_dates_rec.start_date_time > p_task_rec.past_task_start_date
        OR cost_parent_dates_rec.end_date_time < p_task_rec.past_task_end_date) THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_PAST_DATE_INVLD');
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

   -- Get the start and end of this task's first non-summary cost child in the cost hierarchy
   OPEN get_cost_child_dates (p_task_rec.visit_task_id);
   FETCH get_cost_child_dates INTO cost_child_dates_rec;
   CLOSE get_cost_child_dates;

   -- Validate that the first cost child's dates are within this task's dates
   IF cost_child_dates_rec.start_date_time IS NOT NULL THEN
     IF (cost_child_dates_rec.start_date_time < p_task_rec.past_task_start_date
        OR cost_child_dates_rec.end_date_time > p_task_rec.past_task_end_date) THEN
          Fnd_Message.SET_NAME('AHL','AHL_VWP_TASK_PAST_DATE_INVLD');
          Fnd_Msg_Pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

   -- Cursor to find out the cumulative duration of all the stages before the stage of this task
   OPEN c_sum_stage_duration (p_task_rec.stage_name, p_task_rec.visit_id);
   FETCH c_sum_stage_duration INTO l_cum_duration;
   CLOSE c_sum_stage_duration;

   -- Cursor to find visit start time
   OPEN c_visit (p_task_rec.visit_id);
   FETCH c_visit INTO l_visit_start_date,l_dept_id;
   CLOSE c_visit;
   -- Find the planned start time of the stage in which this task falls
   l_stage_planned_start_time :=
   AHL_VWP_TIMES_PVT.compute_date(l_visit_start_date, l_dept_id, l_cum_duration);

   -- Validate that the any of the tasks does not start before the stage starts
   IF p_task_rec.past_task_start_date < l_stage_planned_start_time THEN
      Fnd_Message.SET_NAME('AHL','AHL_VWP_STAGE_TASK_DATE_INVLD');
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF (l_log_procedure >= l_log_current_level)THEN
        fnd_log.string ( l_log_procedure,L_DEBUG_KEY ||'.end','At the end of PLSQL procedure, x_return_status=' || x_return_status);
   END IF;

 END Validate_Past_Task_Dates;
 -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010 :: END


END AHL_VWP_RULES_PVT;

/
