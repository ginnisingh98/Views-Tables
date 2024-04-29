--------------------------------------------------------
--  DDL for Package Body AHL_UMP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UMP_UTIL_PKG" AS
/* $Header: AHLUUMPB.pls 120.7.12010000.3 2010/04/05 21:51:23 sracha ship $ */


-----------------------------------------------------------
-- Function to get unit configuration name for a given   --
-- item instance.                                        --
-----------------------------------------------------------
FUNCTION get_unitName (p_csi_item_instance_id  IN  NUMBER)
RETURN VARCHAR2
IS

  -- Get unit name for component.
  CURSOR get_unit_name_csr (p_csi_item_instance_id IN NUMBER) IS
    SELECT name
    FROM ahl_unit_config_headers uc
    WHERE csi_item_instance_id in ( SELECT object_id
                                    FROM csi_ii_relationships
                                    START WITH subject_id = p_csi_item_instance_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                                    CONNECT BY PRIOR object_id = subject_id
                                      AND relationship_type_code = 'COMPONENT-OF'
                                      AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                      AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                                  )
         AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
         AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
         AND parent_uc_header_id IS NULL;

  -- For top node.
  CURSOR get_unit_name_csr1 (p_csi_item_instance_id IN NUMBER) IS
  SELECT name
    FROM ahl_unit_config_headers uc
    WHERE csi_item_instance_id = p_csi_item_instance_id
          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
          AND parent_uc_header_id IS NULL;

  l_name  ahl_unit_config_headers.name%TYPE;

begin

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

end get_unitName;

-------------------------------------------------------
-- Function to get the children count for a group MR --
-------------------------------------------------------
FUNCTION GetCount_childUE(p_ue_id IN NUMBER)
RETURN NUMBER
IS
--
 CURSOR get_count_child_csr(p_id IN NUMBER) IS
  SELECT count(related_ue_id)
  FROM ahl_ue_relationships
  WHERE relationship_code = 'PARENT'
    AND ue_id = p_id;
--
  l_count NUMBER;
--
BEGIN
  OPEN get_count_child_csr(p_ue_id);
  FETCH get_count_child_csr INTO l_count;
  CLOSE get_count_child_csr;

 return l_count;
END GetCount_childUE;


-----------------------------------------------------------
-- Procedure to get Visit details for a unit effectivity --
-----------------------------------------------------------
PROCEDURE get_Visit_Details ( p_unit_effectivity_id  IN         NUMBER,
                              x_visit_Start_date     OUT NOCOPY DATE,
                              x_visit_End_date       OUT NOCOPY DATE,
                              x_visit_Assign_code    OUT NOCOPY VARCHAR2)

IS

  --l_ump_visit_rec  AHL_VWP_VISITS_PVT.Srch_UMP_rec_type;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_visit_id       NUMBER;

  -- 11.5.10CU2: Ignore simulation visits.
  CURSOR ahl_visit_csr(p_ue_id IN NUMBER) IS
      SELECT vst.start_date_time, vst.visit_id
      FROM ahl_visit_tasks_b tsk, (select vst1.*
          from ahl_visits_b vst1, ahl_simulation_plans_b sim
          where vst1.simulation_plan_id = sim.simulation_plan_id
            and sim.primary_plan_flag = 'Y'
          UNION ALL
           select vst1.*
           from ahl_visits_b vst1
           where vst1.simulation_plan_id IS NULL) vst
      WHERE vst.visit_id = tsk.visit_id
        AND NVL(vst.status_code,'x') NOT IN ('DELETED','CANCELLED')
        AND NVL(tsk.status_code,'x') NOT IN ('DELETED','CANCELLED')
        AND tsk.unit_effectivity_id = p_ue_id;
begin

   x_visit_End_date    := null;
   x_visit_start_date  := null;
   x_visit_assign_code := null;

   -- Call VWP API.
/*   AHL_VWP_VISITS_PVT.UMP_Visit_Info( p_api_version         => 1.0,
                                      p_init_msg_list       => FND_API.G_FALSE,
                                      p_commit              => FND_API.G_FALSE,
                                      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                      p_unit_effectivity_id => p_unit_effectivity_id,
                                      x_return_status       => l_return_status,
                                      x_msg_count           => l_msg_count,
                                      x_msg_data            => l_msg_data,
                                      x_ump_visit_rec       => l_ump_visit_rec);


   IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
   END IF; */

   open ahl_visit_csr (p_unit_effectivity_id);
   FETCH ahl_visit_csr INTO x_visit_start_date, l_visit_id;

   /* Call vwp function to get visit end date */

   IF (ahl_visit_csr%FOUND) THEN
      x_visit_End_date := AHL_VWP_TIMES_PVT.get_visit_end_time(p_visit_id => l_visit_id,
                                                               p_use_actuals => FND_API.G_FALSE);
   END IF;

   close ahl_visit_csr;

   --x_visit_start_date   := l_ump_visit_rec.Visit_start_Date;
   --x_visit_End_date   := l_ump_visit_rec.Visit_End_Date;
   --x_visit_assign_code := l_ump_visit_rec.Assign_Status_Code;

end get_Visit_Details;

-------------------------------------------------------------------------------
-- Function to get the visit status - planning/released/closed/              --
-- This procedure will be called by Process_Unit and Terminate_MR_Instances. --
-------------------------------------------------------------------------------
FUNCTION get_Visit_Status ( p_unit_effectivity_id  IN  NUMBER)

RETURN VARCHAR2


IS

--l_ump_visit_rec  AHL_VWP_VISITS_PVT.Srch_UMP_rec_type;
  l_visit_status_code  AHL_VISITS_B.STATUS_CODE%TYPE;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  -- 11.5.10CU2: Ignore simulation visits.
  CURSOR ahl_visit_csr(p_ue_id IN NUMBER) IS

      SELECT decode(vst.status_code,'CLOSED', vst.status_code, tsk.status_code)
      FROM ahl_visit_tasks_b tsk, (select vst1.*
          from ahl_visits_b vst1, ahl_simulation_plans_b sim
          where vst1.simulation_plan_id = sim.simulation_plan_id
            and sim.primary_plan_flag = 'Y'
          UNION ALL
           select vst1.*
           from ahl_visits_b vst1
           where vst1.simulation_plan_id IS NULL) vst
      WHERE vst.visit_id = tsk.visit_id
        AND NVL(vst.status_code,'x') NOT IN ('DELETED','CANCELLED')
        AND NVL(tsk.status_code,'x') NOT IN ('DELETED','CANCELLED')
        AND tsk.unit_effectivity_id = p_ue_id;
/*
      FROM ahl_visit_tasks_b tsk, ahl_visits_b vst
      WHERE vst.visit_id = tsk.visit_id
        AND NVL(vst.status_code,'x') NOT IN ('DELETED','CANCELLED')
        AND NVL(tsk.status_code,'x') NOT IN ('DELETED','CANCELLED')
        AND tsk.unit_effectivity_id = p_ue_id;
*/

begin
/*
   -- Call VWP API.
   AHL_VWP_VISITS_PVT.UMP_Visit_Info( p_api_version         => 1.0,
                                      p_init_msg_list       => FND_API.G_FALSE,
                                      p_commit              => FND_API.G_FALSE,
                                      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                      p_unit_effectivity_id => p_unit_effectivity_id,
                                      x_return_status       => l_return_status,
                                      x_msg_count           => l_msg_count,
                                      x_msg_data            => l_msg_data,
                                      x_ump_visit_rec       => l_ump_visit_rec);

   IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
   END IF;

*/

   open ahl_visit_csr (p_unit_effectivity_id);
   FETCH ahl_visit_csr INTO l_visit_status_code;
   close ahl_visit_csr;

   --  return visit status.
   --RETURN l_ump_visit_rec.Visit_Status_Code;
   RETURN l_visit_status_code;


end get_Visit_Status;

-------------------------------------------------------------------------
-- Procedure to get the last accomplishment of an MR for any given item
-- instance. --
-------------------------------------------------------------------------
PROCEDURE get_last_accomplishment (p_csi_item_instance_id IN         NUMBER,
                                   p_mr_header_id         IN         NUMBER,
                                   x_accomplishment_date  OUT NOCOPY DATE,
                                   x_unit_effectivity_id  OUT NOCOPY NUMBER,
                                   x_deferral_flag        OUT NOCOPY BOOLEAN,
                                   x_status_code          OUT NOCOPY VARCHAR2,
                                   x_return_val           OUT NOCOPY BOOLEAN)
IS

 -- cursor to get mr title, version and copy accomplishment.
 CURSOR ahl_mr_headers_csr (p_mr_header_id IN NUMBER) IS
   SELECT title mr_title, version_number, copy_accomplishment_flag
   FROM ahl_mr_headers_b
   WHERE mr_header_id = p_mr_header_id;

 -- cursor to get mr title, version and copy accomplishment.
 CURSOR ahl_mr_title_csr (p_mr_title IN VARCHAR2,
                          p_version_number IN NUMBER) IS
   SELECT version_number, copy_accomplishment_flag, mr_header_id
   FROM ahl_mr_headers_b
   WHERE title = p_mr_title AND
         version_number = p_version_number;

 -- cursor to get accomplishments for current version.
 CURSOR ahl_unit_effectivities_csr (p_csi_item_instance_id IN NUMBER,
                                    p_mr_header_id         IN NUMBER) IS
   SELECT ue.accomplished_date, ue.unit_effectivity_id, ue.status_code,
          decode(ue.status_code, 'TERMINATED', ter.affect_due_calc_flag, def.affect_due_calc_flag),
          decode(ue.status_code, 'TERMINATED', ter.deferral_effective_on, def.deferral_effective_on)
   FROM ahl_unit_effectivities_b ue, ahl_unit_deferrals_b def, ahl_unit_deferrals_b ter
   WHERE ue.defer_from_ue_id = def.unit_effectivity_id (+)
      AND ue.unit_effectivity_id = ter.unit_effectivity_id(+)
      AND ue.status_code IN ('ACCOMPLISHED','INIT-ACCOMPLISHED','TERMINATED')
      AND def.unit_deferral_type(+) = 'DEFERRAL'
      AND ter.unit_deferral_type(+) = 'DEFERRAL'
      AND ue.csi_item_instance_id = p_csi_item_instance_id
      AND ue.mr_header_id = p_mr_header_id
   --ORDER BY accomplished_date DESC;
   ORDER BY decode (ue.status_code, 'TERMINATED', ter.deferral_effective_on, ue.accomplished_date) DESC;

  l_accomplish_found  BOOLEAN := FALSE;
  l_mr_header_id      NUMBER  := p_mr_header_id;
  l_unit_effectivity_id NUMBER;
  l_accomplishment_date DATE;
  l_copy_accomplishment_flag  ahl_mr_headers_v.copy_accomplishment_flag%TYPE;
  l_mr_title            ahl_mr_headers_v.title%TYPE;
  l_version_number      NUMBER;
  l_status_code       ahl_unit_effectivities_vl.status_code%TYPE;

  -- Added for deferral functionality.
  l_affect_due_calc_flag   VARCHAr2(1);
  l_deferral_effective_on  DATE;

BEGIN
  -- Set return status.
  x_return_val := TRUE;

  -- Set deferral flag.
  x_deferral_flag := FALSE;

  -- GET MR details.
  OPEN ahl_mr_headers_csr (p_mr_header_id);
  FETCH ahl_mr_headers_csr INTO l_mr_title,
                                l_version_number,
                                l_copy_accomplishment_flag;
  IF (ahl_mr_headers_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_NOTFOUND');
    FND_MESSAGE.Set_Token('MR_ID',p_mr_header_id);
    FND_MSG_PUB.ADD;
    x_return_val := FALSE;
    x_accomplishment_date := null;
    x_unit_effectivity_id := null;
    x_status_code := null;
    CLOSE ahl_mr_headers_csr;
    RETURN;
  END IF;
  CLOSE ahl_mr_headers_csr;

 -- pick the most recent accomplishment from previous version.
 l_accomplish_found := FALSE;
 WHILE NOT(l_accomplish_found) LOOP
   -- Get last accomplishment.
   OPEN ahl_unit_effectivities_csr(p_csi_item_instance_id,
                                   l_mr_header_id);
   FETCH ahl_unit_effectivities_csr INTO l_accomplishment_date,
                                         l_unit_effectivity_id,
                                         l_status_code,
                                         l_affect_due_calc_flag,
                                         l_deferral_effective_on;

   IF (ahl_unit_effectivities_csr%FOUND) THEN
      --dbms_output.put_line ('ue id' || l_unit_effectivity_id);
      -- Added for deferral enhancements.
      -- Use deferral_effective_on date instead of accomplishment date.
      IF (l_affect_due_calc_flag = 'N') THEN
         l_accomplishment_date := l_deferral_effective_on;
         x_deferral_flag := TRUE;
      END IF;
      x_accomplishment_date := l_accomplishment_date;
      x_unit_effectivity_id := l_unit_effectivity_id;
      x_status_code := l_status_code;
      l_accomplish_found := TRUE;
      CLOSE ahl_unit_effectivities_csr;
   ELSE
      -- find accomplishments from last mr revision based on copy accomplishment flag.
      IF (l_copy_accomplishment_flag = 'N') THEN
         --dbms_output.put_line ('copy_accomplishment_flag' || l_copy_accomplishment_flag );
         x_accomplishment_date := null;
         x_unit_effectivity_id := null;
         x_status_code := null;
         l_accomplish_found := TRUE;
      ELSE
         -- check if any more versions available.
         IF (l_version_number = 1) THEN
             --dbms_output.put_line ('version_number = 1' );
             x_accomplishment_date := null;
             x_unit_effectivity_id := null;
             x_status_code := null;
             l_accomplish_found := TRUE;
         ELSE
            -- check if the earlier version exists.
            IF (ahl_unit_effectivities_csr%ISOPEN) THEN
              CLOSE ahl_unit_effectivities_csr;
            END IF;
            --dbms_output.put_line ('next version');
            OPEN ahl_mr_title_csr(l_mr_title,
                                  l_version_number-1);
            FETCH ahl_mr_title_csr INTO l_version_number,
                                        l_copy_accomplishment_flag,
                                        l_mr_header_id;
            IF (ahl_mr_title_csr%NOTFOUND) THEN
              FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_TITLE_INVALID');
              FND_MESSAGE.Set_Token('TITLE',l_mr_title);
              FND_MESSAGE.Set_Token('VERSION',l_version_number);
              FND_MSG_PUB.ADD;
              x_return_val := FALSE;
              x_accomplishment_date := null;
              x_unit_effectivity_id := null;
              x_status_code := null;
              CLOSE ahl_mr_title_csr;
              RETURN;
            END IF;
            CLOSE ahl_mr_title_csr;
         END IF; /* version number */
      END IF; /* l_copy accomplishment flag */
    END IF; /* unit effectivities not found */
   --dbms_output.put_line ('loop again');
 END LOOP;  /* while */

 IF (ahl_unit_effectivities_csr%ISOPEN) THEN
    CLOSE ahl_unit_effectivities_csr;
 END IF;

END get_last_accomplishment;

-----------------------------------------------------------------------------
--
-- Is_UE_In_Execution
--   Checks if the unit effectivity (item instance and MR) is currently
--      in execution by calling the get_Visit_Status procedure given above.
--   Returns TRUE even if any of the descendents (group MR) is in execution.
--   Used by Capture_MR_Updates before terminating an UE
--
-- Input (Mandatory)
--  p_ue_id:       NUMBER Unit Effectivity Id
--
-----------------------------------------------------------------------------
FUNCTION Is_UE_In_Execution
(
  p_ue_id   NUMBER) return boolean IS

BEGIN

  IF ( nvl(get_visit_status(p_ue_id),'X') NOT IN ('RELEASED', 'CLOSED') ) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;


END Is_UE_In_Execution;


---------------------------------------------------------------------
-- Procedure to get Service Request details for a unit effectivity --
-- Used in Preventive Maintenance mode only                        --
---------------------------------------------------------------------
PROCEDURE get_ServiceRequest_Details (p_unit_effectivity_id IN         NUMBER,
                                      x_incident_id         OUT NOCOPY NUMBER,
                                      x_incident_number     OUT NOCOPY VARCHAR2,
                                      x_scheduled_date      OUT NOCOPY DATE)
IS

  CURSOR get_SR_details_csr (p_unit_effectivity_id IN NUMBER,
                             p_cs_link_id          IN NUMBER) IS
    SELECT inc.incident_number, inc.incident_id
    FROM cs_incident_links link, cs_incidents_all_vl inc
    WHERE link.subject_id = inc.incident_id
       AND subject_type = 'SR'
       AND link_type_id = p_cs_link_id
       AND object_type = 'AHL_UMP_EFF'
       AND object_id = p_unit_effectivity_id;

  c_cs_link_id  CONSTANT NUMBER := 6;
  -- This link-id is seeded in cs_link_types_b and
  -- points to link type code = 'Reference'.

BEGIN

  -- Initialize.
  x_scheduled_date := null;

  -- Get Service request details.
  OPEN get_SR_details_csr(p_unit_effectivity_id, c_cs_link_id);
  FETCH get_SR_details_csr INTO x_incident_number, x_incident_id;
  CLOSE get_SR_details_csr;

END get_ServiceRequest_Details;

-----------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Populate_Appl_MRs
--  Type        : Private
--  Function    : Calls FMP and populates the AHL_APPLICABLE_MRS table.
--  Pre-reqs    :
--  Parameters  :
--
--  Populate_Appl_MRs Parameters:
--       p_csi_ii_id       IN  csi item instance id  Required
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.


PROCEDURE Populate_Appl_MRs (
    p_csi_ii_id           IN            NUMBER,
    p_include_doNotImplmt IN            VARCHAR2 := 'Y',
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2)
IS
 l_api_version     CONSTANT NUMBER := 1.0;
 l_appl_mrs_tbl    AHL_FMP_PVT.applicable_mr_tbl_type;

BEGIN

  -- Initialize temporary table.
  DELETE FROM AHL_APPLICABLE_MRS;

  -- call api to fetch all applicable mrs for ASO installation.
  AHL_FMP_PVT.get_applicable_mrs(
                   p_api_version            => l_api_version,
		   p_init_msg_list          => FND_API.G_FALSE,
		   p_commit                 => FND_API.G_FALSE,
		   p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status          => x_return_status,
                   x_msg_count              => x_msg_count,
                   x_msg_data               => x_msg_data,
		   p_item_instance_id       => p_csi_ii_id,
		   p_components_flag        => 'Y',
                   p_include_doNotImplmt    => p_include_doNotImplmt,
		   x_applicable_mr_tbl      => l_appl_mrs_tbl);


  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Populate temporary table ahl_applicable_mrs.
  IF (l_appl_mrs_tbl.COUNT > 0) THEN
     FOR i IN l_appl_mrs_tbl.FIRST..l_appl_mrs_tbl.LAST LOOP
--       dbms_output.put_line( l_appl_mrs_tbl(i).item_instance_id||'  '||
--       l_appl_mrs_tbl(i).mr_header_id);
           INSERT INTO AHL_APPLICABLE_MRS (
       	  CSI_ITEM_INSTANCE_ID,
 	        MR_HEADER_ID,
       	  MR_EFFECTIVITY_ID,
 	        REPETITIVE_FLAG   ,
      	  SHOW_REPETITIVE_CODE,
 	        COPY_ACCOMPLISHMENT_CODE,
 	        PRECEDING_MR_HEADER_ID,
  	        IMPLEMENT_STATUS_CODE,
 	        DESCENDENT_COUNT
           ) values
      	  ( l_appl_mrs_tbl(i).item_instance_id,
	          l_appl_mrs_tbl(i).mr_header_id,
	          l_appl_mrs_tbl(i).mr_effectivity_id,
	          l_appl_mrs_tbl(i).repetitive_flag,
	          l_appl_mrs_tbl(i).show_repetitive_code,
	          l_appl_mrs_tbl(i).copy_accomplishment_flag,
	          l_appl_mrs_tbl(i).preceding_mr_header_id,
 	          l_appl_mrs_tbl(i).implement_status_code,
	          l_appl_mrs_tbl(i).descendent_count
	      );
     END LOOP;
  END IF;

END Populate_Appl_MRs;

--------------------------------------------------------------------
PROCEDURE Process_Group_MRs
IS
--
 CURSOR ahl_applicable_mrs_csr IS
   SELECT  distinct mr_header_id, csi_item_instance_id, descendent_count
    FROM    ahl_applicable_mrs
    WHERE  descendent_count > 0;

--
 l_mr_header_id           NUMBER;
 l_csi_ii_id   		  NUMBER;
 l_desc_count             NUMBER;
--
BEGIN

 -- Initialize temporary table.
 DELETE FROM AHL_APPLICABLE_MR_RELNS;

 OPEN ahl_applicable_mrs_csr;
 LOOP
   FETCH ahl_applicable_mrs_csr INTO l_mr_header_id,
				     l_csi_ii_id, l_desc_count;
   EXIT WHEN ahl_applicable_mrs_csr%NOTFOUND;
   IF (l_desc_count > 0) THEN
         process_group_mr_instance(
	       		p_top_mr_id => l_mr_header_id,
			p_top_item_instance_id => l_csi_ii_id);
   END IF;
 END LOOP;
 CLOSE ahl_applicable_mrs_csr;

END Process_Group_MRs;

-----------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Process_group_mr_instance
--  Type        : Private
--  Function    : Generate relationships for one mr+item instance combination.
--  Pre-reqs    :
--  Parameters  :
--
--  Populate_Appl_MRs Parameters:
--       p_top_item_instance_id      IN   csi item instance id Required
--       p_top_mr_id		     IN  top mr id             Required
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.


PROCEDURE Process_Group_MR_Instance (
    p_top_mr_id                IN            NUMBER,
    p_top_item_instance_id     IN            NUMBER,
    p_init_temp_table          IN            VARCHAR2 DEFAULT 'N')
IS
--
 -- cursor that selects all distinct, valid mr relationships
 CURSOR ahl_fmp_relationships_csr(p_mr_id IN NUMBER) IS

   /*
   SELECT  distinct r.mr_header_id, r.related_mr_header_id,
		r.relationship_code
    FROM    ahl_mr_relationships r
    WHERE  EXISTS (SELECT 'x'
               FROM AHL_MR_HEADERS_B b1, AHL_MR_HEADERS_B b2
               WHERE b1.mr_header_id = r.mr_header_id
                 AND b2.mr_header_id = r.related_mr_header_id
                 AND b1.mr_status_code = 'COMPLETE'
	         AND b2.mr_status_code = 'COMPLETE'
                 AND NVL(b1.effective_from, SYSDATE) <= SYSDATE
	         AND NVL(b2.effective_from, SYSDATE) <= SYSDATE
                 AND NVL(b1.effective_to, SYSDATE+1) >= SYSDATE
	         AND NVL(b2.effective_to, SYSDATE+1) >= SYSDATE)
    START WITH r.mr_header_id = p_mr_id
    CONNECT BY r.mr_header_id = PRIOR r.related_mr_header_id
	  AND r.relationship_code = 'PARENT';
    */

    SELECT  distinct r.mr_header_id, r.related_mr_header_id,
                     r.relationship_code
    FROM    ahl_mr_relationships r
    START WITH r.mr_header_id = p_mr_id
       AND r.relationship_code = 'PARENT'
       AND exists (select 'x' from ahl_mr_headers_b mr1
                   where mr1.mr_header_id = r.related_mr_header_id
                   and mr1.version_number = (select max(mr2.version_number)
                                               from ahl_mr_headers_b mr2
                                              where mr2.title = mr1.title
                                                and mr2.mr_status_code = 'COMPLETE'
                                                and SYSDATE between trunc(mr2.effective_from)
                                                and trunc(nvl(mr2.effective_to,SYSDATE+1))
                                            )
                   )
    CONNECT BY r.mr_header_id = PRIOR r.related_mr_header_id
       AND r.relationship_code = 'PARENT'
       AND exists (select 'x' from ahl_mr_headers_b mr1
                   where mr1.mr_header_id = r.related_mr_header_id
                     and mr1.version_number = (select max(mr2.version_number)
                                                 from ahl_mr_headers_b mr2
                                                where mr2.title = mr1.title
                                                  and mr2.mr_status_code = 'COMPLETE'
                                                  and SYSDATE between trunc(mr2.effective_from)
                                                  and trunc(nvl(mr2.effective_to,SYSDATE+1))
                                              )
                  );

--
 CURSOR ahl_appl_parent_mr_csr(p_mr_id IN NUMBER) IS

   SELECT   distinct csi_item_instance_id
    FROM    ahl_applicable_mrs
    WHERE   mr_header_id = p_mr_id;
--
 CURSOR ahl_appl_child_mrs_csr(p_mr_id IN NUMBER,
			       p_item_instance_id IN NUMBER) IS

   --Priyan Changed the SQl Query for performance tuning reasons
   --Refer to Bug # 4918807

   /*SELECT  distinct  csi_item_instance_id
    FROM    ahl_applicable_mrs
    WHERE   mr_header_id = p_mr_id
      AND (csi_item_instance_id = p_item_instance_id
        OR csi_item_instance_id IN (SELECT subject_id
			FROM csi_ii_relationships
			START WITH object_id = p_item_instance_id
			           AND relationship_type_code = 'COMPONENT-OF'
                                   AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                                   AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
			CONNECT BY PRIOR subject_id = object_id
			  AND relationship_type_code = 'COMPONENT-OF'
                          AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
           ); */

        /* Modified for performance in R12.0. replaced with WITH clause
	SELECT distinct  csi_item_instance_id
	FROM ahl_applicable_mrs amr,
		   (SELECT subject_id
                    FROM csi_ii_relationships
                    START WITH object_id = p_item_instance_id
			   AND relationship_type_code = 'COMPONENT-OF'
			   AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
			   AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                    CONNECT BY PRIOR subject_id = object_id
			   AND relationship_type_code = 'COMPONENT-OF'
			   AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
			   AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                    UNION ALL
                    SELECT p_item_instance_id
                    FROM DUAL) cs
	WHERE amr.mr_header_id = p_mr_id
	AND amr.csi_item_instance_id = cs.subject_id;
        */
        /* performance fix.
        WITH INST AS (SELECT subject_id csi_item_instance_id
                      FROM csi_ii_relationships
                      START WITH object_id = p_item_instance_id
                             AND relationship_type_code = 'COMPONENT-OF'
                             AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                             AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      CONNECT BY PRIOR subject_id = object_id
                             AND relationship_type_code = 'COMPONENT-OF'
                             AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                             AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
                      UNION ALL
                      SELECT p_item_instance_id csi_item_instance_id
                      FROM DUAL)
             SELECT csi_item_instance_id
               FROM INST
              WHERE EXISTS (SELECT 'x'
                            FROM ahl_applicable_mrs AMR
                            WHERE amr.mr_header_id = p_mr_id
                              AND amr.csi_item_instance_id = inst.csi_item_instance_id);
        */

        SELECT subject_id csi_item_instance_id
          FROM csi_ii_relationships
          WHERE EXISTS (SELECT 'x'
                         FROM ahl_applicable_mrs AMR
                         WHERE amr.mr_header_id = p_mr_id
                           AND amr.csi_item_instance_id = subject_id)
          START WITH object_id = p_item_instance_id
                 AND relationship_type_code = 'COMPONENT-OF'
                 AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                 AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
          CONNECT BY PRIOR subject_id = object_id
                 AND relationship_type_code = 'COMPONENT-OF'
                 AND trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
                 AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        UNION ALL
        SELECT p_item_instance_id csi_item_instance_id
          FROM DUAL
          WHERE EXISTS (SELECT 'x'
                         FROM ahl_applicable_mrs AMR
                         WHERE amr.mr_header_id = p_mr_id
                           AND amr.csi_item_instance_id = p_item_instance_id);
--
 CURSOR ahl_appl_mrs_csr(p_mr_id IN NUMBER,
			 p_item_instance_id IN NUMBER) IS
   SELECT  level depth_level, mr_header_id, csi_item_instance_id,
	 related_mr_header_id, related_csi_item_instance_id
    FROM    ahl_applicable_mr_relns
      --WHERE orig_mr_header_id = p_mr_id
      --AND orig_csi_item_instance_id = p_item_instance_id
    START WITH mr_header_id = p_mr_id
          AND  csi_item_instance_id = p_item_instance_id
          AND orig_mr_header_id = p_mr_id
          AND orig_csi_item_instance_id = p_item_instance_id
    CONNECT BY  mr_header_id =  PRIOR related_mr_header_id
	  AND csi_item_instance_id = PRIOR related_csi_item_instance_id
          AND orig_mr_header_id = p_mr_id
          AND orig_csi_item_instance_id = p_item_instance_id;

--
 CURSOR ahl_get_depth_level_csr(p_mr_id IN NUMBER,
			        p_item_instance_id IN NUMBER,
				p_related_mr_id IN NUMBER,
				p_related_item_instance_id IN NUMBER,
				p_orig_mr_id IN NUMBER,
				p_orig_item_instance_id IN NUMBER) IS
   SELECT  NVL(tree_depth_level, 0)
    FROM    ahl_applicable_mr_relns
    WHERE orig_mr_header_id = p_orig_mr_id
      AND orig_csi_item_instance_id = p_orig_item_instance_id
      AND mr_header_id = p_mr_id
      AND csi_item_instance_id = p_item_instance_id
      AND related_mr_header_id =  p_related_mr_id
      AND related_csi_item_instance_id = p_related_item_instance_id;
--
  CURSOR ahl_duplicate_relns_csr(p_mr_id IN NUMBER,
			     p_item_instance_id IN NUMBER) IS
  SELECT  related_mr_header_id, related_csi_item_instance_id
    FROM    ahl_applicable_mr_relns
    WHERE orig_mr_header_id = p_mr_id
      AND orig_csi_item_instance_id = p_item_instance_id
    GROUP BY related_mr_header_id, related_csi_item_instance_id
    HAVING COUNT(*)>1;
--
  CURSOR ahl_max_depth_reln_csr(p_mr_id IN NUMBER,
				p_item_instance_id IN NUMBER,
				p_orig_mr_id IN NUMBER,
				p_orig_item_instance_id IN NUMBER) IS
  SELECT mr_header_id, csi_item_instance_id
  FROM    ahl_applicable_mr_relns
  WHERE tree_depth_level = (SELECT max(tree_depth_level)
			from ahl_applicable_mr_relns
			where  orig_mr_header_id = p_orig_mr_id
      			AND orig_csi_item_instance_id = p_orig_item_instance_id
      			AND related_mr_header_id =  p_mr_id
      			AND related_csi_item_instance_id=p_item_instance_id)
    AND orig_mr_header_id = p_orig_mr_id
    AND orig_csi_item_instance_id = p_orig_item_instance_id
    AND related_mr_header_id =  p_mr_id
    AND related_csi_item_instance_id=p_item_instance_id;
--
 l_orig_ii_id             NUMBER;
 l_orig_mr_id             NUMBER;
 l_num_of_desc            NUMBER;
 l_mr_header_id           NUMBER;
 l_related_mr_header_id   NUMBER;
 l_relationship_code      VARCHAR2(30);
 l_csi_ii_id   		  NUMBER;
 l_related_csi_ii_id      NUMBER;
 l_depth_level            NUMBER;
 l_appl_mr_relns_rec  ahl_appl_mrs_csr%ROWTYPE;

--
BEGIN

 -- Initialize temporary table.
 IF (p_init_temp_table = 'Y') THEN
   DELETE FROM AHL_APPLICABLE_MR_RELNS;
 END IF;

 l_orig_ii_id := p_top_item_instance_id;
 l_orig_mr_id  := p_top_mr_id;


 --dbms_output.put_line(l_orig_mr_id||'::'||l_orig_ii_id);
 --Now fetch all relations into l_mr_relns_tbl
 --And populate the ahl_applicable_mr_relns table
 OPEN ahl_fmp_relationships_csr(l_orig_mr_id);
 LOOP
   FETCH ahl_fmp_relationships_csr INTO l_mr_header_id,
					l_related_mr_header_id,
					l_relationship_code;
   EXIT WHEN ahl_fmp_relationships_csr%NOTFOUND;



   --For each edge of mr_relationships graph
   --Loop through all the mr + ii combinations
   OPEN ahl_appl_parent_mr_csr(l_mr_header_id);
   LOOP
     FETCH ahl_appl_parent_mr_csr INTO l_csi_ii_id;
     EXIT WHEN ahl_appl_parent_mr_csr%NOTFOUND;

     --For each mr+ii combination
     OPEN ahl_appl_child_mrs_csr(l_related_mr_header_id, l_csi_ii_id);
     LOOP
        FETCH ahl_appl_child_mrs_csr INTO l_related_csi_ii_id;
	EXIT WHEN ahl_appl_child_mrs_csr%NOTFOUND;


	INSERT INTO AHL_APPLICABLE_MR_RELNS (
 	  MR_HEADER_ID,
 	  CSI_ITEM_INSTANCE_ID,
 	  RELATED_MR_HEADER_ID,
 	  RELATED_CSI_ITEM_INSTANCE_ID,
 	  ORIG_MR_HEADER_ID,
 	  ORIG_CSI_ITEM_INSTANCE_ID,
	  RELATIONSHIP_CODE
         ) values
	  ( l_mr_header_id,
	    l_csi_ii_id,
	    l_related_mr_header_id,
	    l_related_csi_ii_id,
	    l_orig_mr_id,
 	    l_orig_ii_id,
	    l_relationship_code
	  );
     END LOOP;
     Close ahl_appl_child_mrs_csr;

   END LOOP;
   Close ahl_appl_parent_mr_csr;

 END LOOP;
 CLOSE ahl_fmp_relationships_csr;

 --Done with creating all possible applicable edges.
 --Now fetch all relations reachable from the top node
 OPEN ahl_appl_mrs_csr(l_orig_mr_id, l_orig_ii_id);
 LOOP
   FETCH ahl_appl_mrs_csr INTO l_appl_mr_relns_rec;
   EXIT WHEN ahl_appl_mrs_csr%NOTFOUND;

   OPEN ahl_get_depth_level_csr(l_appl_mr_relns_rec.mr_header_id,
			  l_appl_mr_relns_rec.csi_item_instance_id,
	 		  l_appl_mr_relns_rec.related_mr_header_id,
			  l_appl_mr_relns_rec.related_csi_item_instance_id,
			  l_orig_mr_id,
			  l_orig_ii_id);
   FETCH  ahl_get_depth_level_csr INTO l_depth_level;

   IF (ahl_get_depth_level_csr%FOUND) THEN
     --If depth is greater in rec, update to new depth
     IF (l_depth_level < l_appl_mr_relns_rec.depth_level) THEN
        UPDATE ahl_applicable_mr_relns
          SET tree_depth_level = l_appl_mr_relns_rec.depth_level
        WHERE orig_mr_header_id = l_orig_mr_id
          AND orig_csi_item_instance_id = l_orig_ii_id
          AND mr_header_id = l_appl_mr_relns_rec.mr_header_id
          AND csi_item_instance_id = l_appl_mr_relns_rec.csi_item_instance_id
          AND related_mr_header_id = l_appl_mr_relns_rec.related_mr_header_id
          AND related_csi_item_instance_id = l_appl_mr_relns_rec.related_csi_item_instance_id;
     END IF;
   END IF; -- ahl_get_depth_level_csr%FOUND
   CLOSE ahl_get_depth_level_csr;
 END LOOP;
 CLOSE ahl_appl_mrs_csr;

 --Now delete all rows with null depth (unreachable)
 DELETE FROM ahl_applicable_mr_relns
  WHERE tree_depth_level IS NULL
    AND orig_mr_header_id = l_orig_mr_id
    AND orig_csi_item_instance_id = l_orig_ii_id;

 --Remove all duplicates and keep deepest paths
 OPEN ahl_duplicate_relns_csr(l_orig_mr_id, l_orig_ii_id);
 LOOP
   FETCH ahl_duplicate_relns_csr INTO l_related_mr_header_id, l_related_csi_ii_id;
   EXIT WHEN ahl_duplicate_relns_csr%NOTFOUND;

   OPEN ahl_max_depth_reln_csr(l_related_mr_header_id,
			  	l_related_csi_ii_id,
			  	l_orig_mr_id,
			  	l_orig_ii_id);
   FETCH  ahl_max_depth_reln_csr INTO l_mr_header_id, l_csi_ii_id;
   IF (ahl_max_depth_reln_csr%FOUND) THEN
     --Delete all rows != edge with maximum depth
     DELETE FROM ahl_applicable_mr_relns
     WHERE (mr_header_id <> l_mr_header_id
        OR csi_item_instance_id <> l_csi_ii_id)
       AND orig_mr_header_id = l_orig_mr_id
       AND orig_csi_item_instance_id = l_orig_ii_id
       AND related_mr_header_id = l_related_mr_header_id
       AND related_csi_item_instance_id = l_related_csi_ii_id;
   END IF; -- ahl_max_depth_reln_csr%FOUND
   CLOSE ahl_max_depth_reln_csr;
 END LOOP;
 CLOSE ahl_duplicate_relns_csr;

END Process_Group_MR_Instance;

-------------------------------------------------------------------------
-- Procedure to get the first accomplishment of an MR for any given item
-- instance. --
-------------------------------------------------------------------------
PROCEDURE get_first_accomplishment (p_csi_item_instance_id IN        NUMBER,
                                   p_mr_header_id          IN        NUMBER,
                                   x_accomplishment_date  OUT NOCOPY DATE,
                                   x_unit_effectivity_id  OUT NOCOPY NUMBER,
                                   x_deferral_flag        OUT NOCOPY BOOLEAN,
                                   x_status_code          OUT NOCOPY VARCHAR2,
                                   x_return_val           OUT NOCOPY BOOLEAN)
IS

 -- cursor to get mr title, version and copy accomplishment.
 CURSOR ahl_mr_headers_csr (p_mr_header_id IN NUMBER) IS
   SELECT title mr_title, version_number, copy_accomplishment_flag
   FROM ahl_mr_headers_b
   WHERE mr_header_id = p_mr_header_id;

 -- cursor to get mr title, version and copy accomplishment.
 CURSOR ahl_mr_title_csr (p_mr_title IN VARCHAR2,
                          p_version_number IN NUMBER) IS
   SELECT version_number, copy_accomplishment_flag, mr_header_id
   FROM ahl_mr_headers_b
   WHERE title = p_mr_title AND
         version_number = p_version_number;

 -- cursor to get accomplishments for current version.
 CURSOR ahl_unit_effectivities_csr (p_csi_item_instance_id IN NUMBER,
                                    p_mr_header_id         IN NUMBER) IS
   SELECT ue.accomplished_date, ue.unit_effectivity_id, ue.status_code,
          affect_due_calc_flag, deferral_effective_on
   FROM ahl_unit_effectivities_b ue, ahl_unit_deferrals_b def
   WHERE ue.defer_from_ue_id = def.unit_effectivity_id (+)
      AND ue.status_code IN ('ACCOMPLISHED','INIT-ACCOMPLISHED')
      AND ue.csi_item_instance_id = p_csi_item_instance_id
      AND ue.mr_header_id = p_mr_header_id
   ORDER BY accomplished_date ASC;

  l_accomplish_found  BOOLEAN := FALSE;
  l_mr_header_id      NUMBER  := p_mr_header_id;
  l_unit_effectivity_id NUMBER;
  l_accomplishment_date DATE;
  l_copy_accomplishment_flag  ahl_mr_headers_v.copy_accomplishment_flag%TYPE;
  l_mr_title            ahl_mr_headers_v.title%TYPE;
  l_version_number      NUMBER;
  l_status_code       ahl_unit_effectivities_vl.status_code%TYPE;

  -- Added for deferral functionality.
  l_affect_due_calc_flag   VARCHAr2(1);
  l_deferral_effective_on  DATE;

BEGIN

  -- Set return status.
  x_return_val := TRUE;

  -- Set deferral flag.
  x_deferral_flag := FALSE;

  l_accomplish_found := FALSE;

  -- GET MR details.
  OPEN ahl_mr_headers_csr (p_mr_header_id);
  FETCH ahl_mr_headers_csr INTO l_mr_title,
                                l_version_number,
                                l_copy_accomplishment_flag;
  IF (ahl_mr_headers_csr%NOTFOUND) THEN
    --dbms_output.put_line ('mr_heeader_id not found');
    FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_MR_NOTFOUND');
    FND_MESSAGE.Set_Token('MR_ID',p_mr_header_id);
    FND_MSG_PUB.ADD;
    x_return_val := FALSE;
    x_accomplishment_date := null;
    x_unit_effectivity_id := null;
    x_status_code := null;
    CLOSE ahl_mr_headers_csr;
    RETURN;
  END IF;

  CLOSE ahl_mr_headers_csr;

  -- default l_copy_accomplishment_flag to Y if NULL.
  IF (l_copy_accomplishment_flag IS NULL) THEN
    l_copy_accomplishment_flag := 'Y';
  END IF;

  -- Get first accomplishment for current mr revsision.
  OPEN ahl_unit_effectivities_csr(p_csi_item_instance_id,
                                  l_mr_header_id);
  FETCH ahl_unit_effectivities_csr INTO l_accomplishment_date,
                                        l_unit_effectivity_id,
                                        l_status_code,
                                        l_affect_due_calc_flag,
                                        l_deferral_effective_on;

  IF (ahl_unit_effectivities_csr%FOUND) THEN
      -- dbms_output.put_line ('ue id' || l_unit_effectivity_id);
      -- Added for deferral enhancements.
      -- Use deferral_effective_on date instead of accomplishment date.
      IF (l_affect_due_calc_flag = 'N') THEN
         x_accomplishment_date := l_deferral_effective_on;
         x_deferral_flag := TRUE;
      ELSE
        x_accomplishment_date := l_accomplishment_date;
      END IF;
      x_unit_effectivity_id := l_unit_effectivity_id;
      x_status_code := l_status_code;
      l_accomplish_found := TRUE;
  ELSE
      x_accomplishment_date := null;
      x_unit_effectivity_id := null;
      x_status_code := null;
  END IF; -- unit effectivities not found
  CLOSE ahl_unit_effectivities_csr;

  WHILE ((l_copy_accomplishment_flag = 'Y') AND (l_version_number > 1)) LOOP

    -- check if the earlier version exists.
    IF (ahl_unit_effectivities_csr%ISOPEN) THEN
       CLOSE ahl_unit_effectivities_csr;
    END IF;
    --dbms_output.put_line ('next version');

    OPEN ahl_mr_title_csr(l_mr_title,
                          l_version_number-1);
    FETCH ahl_mr_title_csr INTO l_version_number,
                                l_copy_accomplishment_flag,
                                l_mr_header_id;
    IF (ahl_mr_title_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UMP_PUE_TITLE_INVALID');
       FND_MESSAGE.Set_Token('TITLE',l_mr_title);
       FND_MESSAGE.Set_Token('VERSION',l_version_number);
       FND_MSG_PUB.ADD;
       x_return_val := FALSE;
       x_accomplishment_date := null;
       x_unit_effectivity_id := null;
       x_status_code := null;
       CLOSE ahl_mr_title_csr;
       RETURN;
    END IF;
    CLOSE ahl_mr_title_csr;

    -- Get first accomplishment for mr version.
    OPEN ahl_unit_effectivities_csr(p_csi_item_instance_id,
                                    l_mr_header_id);
    FETCH ahl_unit_effectivities_csr INTO l_accomplishment_date,
                                          l_unit_effectivity_id,
                                          l_status_code,
                                          l_affect_due_calc_flag,
                                          l_deferral_effective_on;

    IF (ahl_unit_effectivities_csr%FOUND) THEN
       -- dbms_output.put_line ('ue id' || l_unit_effectivity_id);
       -- Added for deferral enhancements.
       -- Use deferral_effective_on date instead of accomplishment date.
       IF (l_affect_due_calc_flag = 'N') THEN
          x_accomplishment_date := l_deferral_effective_on;
          x_deferral_flag := TRUE;
       ELSE
          x_deferral_flag := FALSE;
          x_accomplishment_date := l_accomplishment_date;
       END IF;
       x_unit_effectivity_id := l_unit_effectivity_id;
       x_status_code := l_status_code;
       l_accomplish_found := TRUE;

    END IF; -- unit effectivities not found
    CLOSE ahl_unit_effectivities_csr;

    -- dbms_output.put_line ('loop again');

 END LOOP;  /* while */

 IF (ahl_unit_effectivities_csr%ISOPEN) THEN
    CLOSE ahl_unit_effectivities_csr;
 END IF;

 -- dbms_output.put_line ('x_ue_id:' || x_unit_effectivity_id);
 -- dbms_output.put_line ('x_acc_dt:' || x_accomplishment_date);

END get_first_accomplishment;

-------------------------------------------------------------------------
END AHL_UMP_UTIL_PKG;

/
