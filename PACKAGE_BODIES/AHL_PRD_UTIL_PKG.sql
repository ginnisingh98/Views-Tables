--------------------------------------------------------
--  DDL for Package Body AHL_PRD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_UTIL_PKG" AS
/* $Header: AHLUPRDB.pls 120.17.12010000.2 2009/03/13 06:54:39 jkjain ship $ */

-- Purpose: Briefly explain the functionality of the package body
-- Contains common utility procedures to be used by parts change and material transactions.
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
--Validates locator for a given organization. Also if subinventory is provided then chekcs if the loctaor belongs to the
-- subinventory.
  PROCEDURE validate_locators
     ( p_locator_id IN number,
       p_org_id IN number,
       p_subinventory_code in varchar2,
       X_Return_Status      Out NOCOPY Varchar2,
       X_Msg_Data           Out NOCOPY Varchar2
    )
    AS
 l_subinv_code varchar2(20):= null;
 CURSOR ahl_locator_csr(p_org_id number, p_locator_id number) is
  select subinventory_code
     from mtl_item_locations_kfv
     where organization_id = p_org_id
     and inventory_location_id = p_locator_id
     and nvl(disable_Date, sysdate) >= sysdate;

   BEGIN
    -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- test if subinventory si null;
if (p_subinventory_code is null ) then

  FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_PC_SUBINV_MANDATORY');

  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
end if;

 -- Commented the following validation as locator id need not exist in
 -- mtl_item_locations if it is setup as dynamic entry.

 --          OPEN ahl_locator_csr(p_Org_Id,p_locator_id);
 --          FETCH ahl_locator_csr INTO l_subinv_code;
 --          CLOSE ahl_locator_csr;


 /*        if (l_subinv_code is null) then
             x_return_status :=  FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('AHL','AHL_PRD_LOCATOR_INVALID');
             FND_MSG_PUB.ADD;

         END if;*/

         --Check if the locator is attached to the subinventory if subinventory is provided
  --       if (l_subinv_code is not null
  --       and l_subinv_code <> p_subinventory_code ) then
  --           x_return_status :=  FND_API.G_RET_STS_ERROR;
  --            FND_MESSAGE.Set_Name('AHL','AHL_PRD_LOCATOR_SUBINV_INVALID');
  --           FND_MSG_PUB.ADD;

  --       END if;
 EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--          x_return_status := FND_API.G_RET_STS_ERROR;
--          FND_MESSAGE.Set_Name('AHL','AHL_PRD_LOCATOR_INVALID');
--          FND_MSG_PUB.ADD;


         WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
--Validates a removal condition
 procedure validate_condition
    (
        p_condition_id  In number,
        x_return_status out NOCOPY varchar2,
        x_msg_data out NOCOPY varchar2

    )
    AS

    l_junk varchar2(1):= null;

    CURSOR ahl_condition_csr (p_condn_id number) IS
     select 'x'
            from mtl_material_statuses
            where status_id=p_condn_id
            and enabled_flag =1;
    BEGIN

     -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

           OPEN ahl_condition_csr(p_condition_id);
           FETCH ahl_condition_csr INTO l_junk;
           CLOSE ahl_condition_csr;

            if (l_junk is null) then
                x_return_status :=  FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_CONDN_MISSING');
                FND_MSG_PUB.ADD;
            END if;
    END;

--Validates a removal reason.
    procedure validate_reason
    (
        p_reason_id  In number,
        x_return_status out NOCOPY varchar2,
        x_msg_data out NOCOPY varchar2

    )

    AS
      CURSOR ahl_reason_csr (p_reason_id number) IS
      select 'x'
            from MTL_TRANSACTION_REASONS
            where reason_id=p_reason_id
            and nvl(disable_date, sysdate) >= sysdate;

    l_junk varchar2(1) := null;
    begin
            -- Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;

            OPEN ahl_reason_csr(p_reason_id);
           FETCH ahl_reason_csr INTO l_junk;
           CLOSE ahl_reason_csr;


            if (l_junk is null) then
                 x_return_status :=  FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_REASON');
                   FND_MESSAGE.Set_Token('REASON',p_reason_id);

                FND_MSG_PUB.ADD;
            END if;
    end;


/********************************************************
This procedure checks the condition of the item and validates
if the sub inventory is valid for this codnition.
*********************************************************/


PROCEDURE VALIDATE_MATERIAL_STATUS(p_Organization_Id 	IN   NUMBER,
		  						p_Subinventory_Code IN 	 VARCHAR2,-- not null
								p_Condition_id		IN 	 NUMBER,-- null/not null
								x_return_status 	OUT NOCOPY  VARCHAR2
								)
IS
l_status_id NUMBER;
--for inventory sttaus
CURSOR ahl_inv_status_csr(p_org_id number, p_subinv_code varchar2) is
	SELECT status_id
		FROM MTL_SECONDARY_INVENTORIES
		WHERE ORGANIZATION_ID = p_org_Id
		AND SECONDARY_INVENTORY_NAME = p_Subinv_Code;

BEGIN



	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

         OPEN ahl_inv_status_csr(p_Organization_Id,p_Subinventory_Code);
           FETCH ahl_inv_status_csr INTO l_status_id;
           CLOSE ahl_inv_status_csr;

		if l_status_id is null THEN
			FND_MESSAGE.Set_Name('AHL','AHL_PRD_INVALID_SUBINVENTORY');
            FND_MESSAGE.set_token('INV', p_Subinventory_Code);
			FND_MSG_PUB.ADD;
           x_return_status :=  FND_API.G_RET_STS_ERROR;

        End if;
        --dbms_output.put_line('ahl_prd_util_pkg - Condition id'|| p_condition_id);
          -- dbms_output.put_line('ahl_prd_util_pkg - status id'|| l_status_id);
              --dbms_output.put_line('ahl_prd_util_pkg - org id'|| p_organization_id);
        if (p_condition_id is not null
        and
           (    (FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_SERVICABLE')is not null and
                  p_condition_id = FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_SERVICABLE'))
                OR
                    ( FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_UNSERVICABLE') is not null and
                        p_condition_id=FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_UNSERVICABLE'))
                OR
                    (FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_MRB')is not null and
                     p_condition_id = FND_PROFILE.VALUE('AHL_MTL_MAT_STATUS_MRB'))
            )
          AND
            p_condition_id <> l_status_id ) then


					FND_MESSAGE.Set_Name('AHL','AHL_PRD_CONDN_SUBINV_MISMATCH');
					FND_MSG_PUB.ADD;
                    x_return_status :=  FND_API.G_RET_STS_ERROR;

	END IF;

END ;--VALIDATE_MATERIAL_STATUS;

------------------------------------------------------------------------------------------------
-- Function to test if the Unit in context is locked or not. The input to the API can be one of
-- workorder_id, mr_id, visit_id or item_instance_id.
------------------------------------------------------------------------------------------------
FUNCTION Is_Unit_Locked(
	P_workorder_id		IN 	NUMBER,
	P_ue_id			IN 	NUMBER,
	P_visit_id		IN 	NUMBER,
	P_item_instance_id	IN 	NUMBER
)
RETURN VARCHAR2
IS
/*
 * Cursor to get workorder_ids of a given visit.
 */
CURSOR c_get_visit_workorders(p_visit_id IN NUMBER)
IS
SELECT
	workorder_id
FROM
	ahl_workorders
WHERE
	visit_id = p_visit_id AND
	status_code not in (22, 7, 17) AND
	master_workorder_flag <> 'Y';
/*
 * Cursor for getting item details from a workorder.
 * Detailed are retrieved by joining workorder and visit tables.
 * If the visit header has item instance info then use that else
 * get the info from visit task tables.
 */
CURSOR c_get_wo_item_details(p_workorder_id IN NUMBER)
IS
SELECT
	vst.item_instance_id,
	vtk.instance_id
FROM
	ahl_visit_tasks_b vtk,
	ahl_visits_b vst,
	ahl_workorders wo
WHERE
	wo.workorder_id = p_workorder_id AND
	vtk.visit_task_id = wo.visit_task_id AND
	vtk.visit_id = vst.visit_id;

/*
 * Cursor for getting csi_item_instance_id given mr_id.
 */
CURSOR  c_get_ue_instance_id(p_ue_id IN NUMBER)
IS
SELECT
	csi_item_instance_id
FROM
	AHL_UNIT_EFFECTIVITIES_B
WHERE
	unit_effectivity_id = p_ue_id;

-- declare all local variables here
l_item_instance_id NUMBER;
l_instance_id NUMBER;

BEGIN
	-- Check if item_instance_id is input to the API.
	IF p_item_instance_id IS NOT NULL
	THEN
		RETURN AHL_UTIL_UC_PKG.Is_Unit_Quarantined(
							p_unit_header_id	=>	null,
							p_instance_id		=> p_item_instance_id
							);
	-- If visit_id is input
	ELSIF p_visit_id IS NOT NULL
	THEN
		-- get all visit workorders
		FOR vst_wos IN c_get_visit_workorders(p_visit_id)
		LOOP
			-- for each workorder get item instance info.
			OPEN c_get_wo_item_details(vst_wos.workorder_id);
			FETCH c_get_wo_item_details INTO l_item_instance_id, l_instance_id;
			CLOSE c_get_wo_item_details;

			-- If visit header has item instance info.
			IF l_instance_id IS NOT NULL
			THEN
				IF AHL_UTIL_UC_PKG.Is_Unit_Quarantined(
							p_unit_header_id	=>	null,
							p_instance_id		=> l_instance_id
							) = FND_API.G_TRUE
				THEN
					RETURN FND_API.G_TRUE;
				END IF;

			ELSE
				-- If visit task has item instance info.
				RETURN AHL_UTIL_UC_PKG.Is_Unit_Quarantined(
							p_unit_header_id	=>	null,
							p_instance_id		=>	l_item_instance_id
						);
			END IF;
		END LOOP;

		RETURN FND_API.G_FALSE;
	-- if mr header id is input to the API.
	ELSIF p_ue_id IS NOT NULL
	THEN
		OPEN c_get_ue_instance_id(p_ue_id);
		FETCH c_get_ue_instance_id INTO l_instance_id;
		CLOSE c_get_ue_instance_id;
		RETURN AHL_UTIL_UC_PKG.Is_Unit_Quarantined(
						p_unit_header_id	=>	null,
						p_instance_id		=>	l_instance_id
						);
	-- If workorder id is input to the API.
	ELSIF p_workorder_id IS NOT NULL
	THEN
		OPEN c_get_wo_item_details(p_workorder_id);
		FETCH c_get_wo_item_details INTO l_item_instance_id, l_instance_id;
		CLOSE c_get_wo_item_details;
		RETURN AHL_UTIL_UC_PKG.Is_Unit_Quarantined(
				p_unit_header_id	=>	null,
				p_instance_id		=>	nvl(l_instance_id, l_item_instance_id) );
	END IF;

	-- Control will reach here if all inputs to the API are null. return false then.
	RETURN FND_API.G_FALSE;

END Is_Unit_Locked;

------------------------------------------------------------------------------------------------
-- Function to test if the workorder can be updated.
-- Determined based on following factors
-- 1. If the unit is quarantined then it cannot be updated.
-- 2. If the workorder status is any of 22, 12 and 7 then it cannot be updated.
------------------------------------------------------------------------------------------------
FUNCTION Is_Wo_Updatable(
	P_workorder_id		IN 	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2
IS
/*
 * Cursor for selecting workorder status validity.
 */
CURSOR c_validate_wo_status(p_workorder_id IN NUMBER) IS
SELECT
	'X'
FROM
	ahl_workorders
WHERE
	workorder_id = p_workorder_id AND
	status_code in (7, 12, 22);

-- declare local variables here
l_exists VARCHAR2(1);

BEGIN
	-- If workorder_id is null then immediately return false.
	IF p_workorder_id IS NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- Check if the unit is locked... If so then return false to indicate
	-- the workorder can't be updated.
	IF p_check_unit = FND_API.G_TRUE THEN
	IF Is_Unit_Locked(
			p_workorder_id		=> 	p_workorder_id,
			P_ue_id			=>	null,
			P_visit_id		=>	null,
			P_item_instance_id	=>	null
		 ) = FND_API.G_TRUE
	THEN
		RETURN FND_API.G_FALSE;
	END IF;
	END IF;

	-- If the unit is not locked and the workorder is in any of
	-- 7, 12 or 22 then return false.
	OPEN c_validate_wo_status(p_workorder_id);
	FETCH c_validate_wo_status INTO l_exists;
	CLOSE c_validate_wo_status;

	IF l_exists IS NOT NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- If this point is reached then neither the unit is locked nor the workorder is
	-- in invalid status. Return true here.
	RETURN FND_API.G_TRUE;

END Is_Wo_Updatable;

------------------------------------------------------------------------------------------------
-- Function to test if the workorder operation can be updated.
-- Determined based on following factors
-- 1. If the unit associated with the workorder to which the operation belongs is quarantined
--    then it cannot be updated.
-- 2. If the workorder status is any of 22, 12 and 7 then it cannot be updated.
-- 3. If the operation status is 'COMPLETE' then it cannot be updated
------------------------------------------------------------------------------------------------
FUNCTION Is_Op_Updatable(
	p_workorder_id		IN	NUMBER,
	p_operation_seq_num	IN	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2
IS

/*
 * Cursor for selecting workorder status validity.
 */
CURSOR c_validate_wo_status(p_workorder_id IN NUMBER)
IS
SELECT
	'X'
FROM
	ahl_workorders
WHERE
	workorder_id = p_workorder_id AND
	status_code in (4, 5, 7, 12, 22);
/*
 * Cursor for checking workorder operation status validity
 */
CURSOR c_validate_op_status(p_workorder_id IN NUMBER, p_op_seq_no IN NUMBER)
IS
SELECT
	'X'
FROM
	ahl_workorder_operations
WHERE
	workorder_id = p_workorder_id AND
	operation_sequence_num = p_op_seq_no AND
	status_code = 1;

-- declare local variables here
l_exists VARCHAR2(1);

BEGIN
	-- If either of workorder_id or operation sequence number is null then
	-- return false as it is incorrect input to this API.
	IF p_workorder_id IS NULL OR p_operation_seq_num IS NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- If the unit associated with this workorder is locked then
	-- operation should not be updatable.
	IF p_check_unit = FND_API.G_TRUE THEN
	IF Is_Unit_Locked(
			p_workorder_id		=> 	p_workorder_id,
			P_ue_id			=>	null,
			P_visit_id		=>	null,
			P_item_instance_id	=>	null
		 ) = FND_API.G_TRUE
	THEN
		RETURN FND_API.G_FALSE;
	END IF;
	END IF;

	-- If the workorder status is any of 7, 12 or 22 then return false.
	OPEN c_validate_wo_status(p_workorder_id);
	FETCH c_validate_wo_status INTO l_exists;
	CLOSE c_validate_wo_status;
	IF l_exists IS NOT NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- If the operation status is 'Complete' then return false
	-- to indicate the operation is not updatable.
	OPEN c_validate_op_status(p_workorder_id, p_operation_seq_num);
	FETCH c_validate_op_status INTO l_exists;
	IF l_exists IS NOT NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- Control reaching here indicates above three checks are not valid for
	-- the input hence return true to indicate the operation is updatable.
	RETURN FND_API.G_TRUE;

END Is_Op_Updatable;

------------------------------------------------------------------------------------------------
-- Function to determine if a MR requires Quality collection to be done.
-- (Whether QA Collection is required)
-- The function returns QA Plan id or null if one is not associated with the MR.
------------------------------------------------------------------------------------------------
FUNCTION Is_Mr_Qa_Enabled(
	p_ue_id			IN	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN NUMBER
IS

/*
 * Cursor to retrieve mr_header_id and qa_collection_id from ue_effectivities table.
 */
CURSOR  c_get_mr_details(p_ue_id IN NUMBER)
IS
SELECT
	mr_header_id,
	qa_collection_id
FROM
	AHL_UNIT_EFFECTIVITIES_B
WHERE
	unit_effectivity_id = p_ue_id;

/*
 * Cursor to retrieve plan id given qa collection id.
 */
CURSOR c_get_plan_from_col(p_qa_collection_id IN NUMBER)
IS
SELECT
	DISTINCT plan_id
FROM
	QA_RESULTS
WHERE
	collection_id = p_qa_collection_id;

/*
 * Cursor to retrieve mr_qa_inspection_type given mr_header_id
 */
CURSOR c_get_mr_insp_type(p_mr_header_id IN  NUMBER)
IS
SELECT
	qa_inspection_type
FROM
	AHL_MR_HEADERS_B
WHERE
	mr_header_id = p_mr_header_id;

/*
 * Cursor for getting qa plan id from MR qa_inspection_type and ue_id.
 */
CURSOR c_get_plan_from_insp_type(p_qa_insp_type IN VARCHAR2, p_ue_id IN NUMBER)
IS
SELECT
  QP.PLAN_ID
FROM
  QA_PLANS_VAL_V QP,
  QA_PLAN_TRANSACTIONS QPT,
  QA_PLAN_COLLECTION_TRIGGERS QPCT
WHERE
  QP.PLAN_ID = QPT.PLAN_ID AND
  QPT.PLAN_TRANSACTION_ID = QPCT.PLAN_TRANSACTION_ID AND
  QP.ORGANIZATION_ID =   (SELECT
  				ORGANIZATION_ID
  			  FROM
  			  	AHL_VISITS_B VST,
  			  	AHL_VISIT_TASKS_B TSK
  			  WHERE VST.VISIT_ID = TSK.VISIT_ID AND
				TSK.UNIT_EFFECTIVITY_ID = p_ue_id AND
			  ROWNUM < 2) AND
  QPT.TRANSACTION_NUMBER IN (9999,2001)	AND
  QPCT.COLLECTION_TRIGGER_ID = 87 AND
  QPCT.LOW_VALUE = p_qa_insp_type
GROUP BY
	QP.PLAN_ID,
	QPT.TRANSACTION_NUMBER
HAVING
	TRANSACTION_NUMBER = MAX(TRANSACTION_NUMBER);

--declare all local variables here
l_mr_id NUMBER;
l_qa_collection_id NUMBER;
l_plan_id NUMBER;
l_qa_insp_type VARCHAR2(150);

BEGIN
	-- If ue id which is only input to this API is null then return null.
	IF p_ue_id IS NULL
	THEN
		RETURN NULL;
	END IF;

	-- retrieve mr_header_id and qa_collection_id for the given ue.
	OPEN c_get_mr_details(p_ue_id);
	FETCH c_get_mr_details INTO l_mr_id, l_qa_collection_id;
	CLOSE c_get_mr_details;

	-- If mr_header_id is null dont proceed further and return null.
	IF l_mr_id IS NULL
	THEN
		RETURN NULL;
	END IF;

	-- If the unit associated with this workorder is locked then
	-- operation should not be updatable.
	IF p_check_unit = FND_API.G_TRUE THEN
	IF Is_Unit_Locked(
			p_workorder_id		=> 	null,
			P_ue_id			=>	l_mr_id,
			P_visit_id		=>	null,
			P_item_instance_id	=>	null
		 ) = FND_API.G_TRUE
	THEN
		RETURN NULL;
	END IF;
	END IF;

	-- retrieve plan_id for information gathered above.
	IF l_qa_collection_id IS NOT NULL
	THEN
		-- Get qa_plan_id from qa_collection_id
		OPEN c_get_plan_from_col(l_qa_collection_id);
		FETCH c_get_plan_from_col INTO l_plan_id;
		CLOSE c_get_plan_from_col;
	ELSE
		-- Get qa_inspection_type from mr header.
		OPEN c_get_mr_insp_type(l_mr_id);
		FETCH c_get_mr_insp_type INTO l_qa_insp_type;
		CLOSE c_get_mr_insp_type;

		-- retrieve qa_plan_id from qa_inspection_type and ue_id.
		IF l_qa_insp_type IS NOT NULL
		THEN
			OPEN c_get_plan_from_insp_type(l_qa_insp_type, p_ue_id);
			FETCH c_get_plan_from_insp_type INTO l_plan_id;
			CLOSE c_get_plan_from_insp_type;
		END IF;
	END IF;

	-- return plan_id collected. could be null also if no plan is associated.
	RETURN l_plan_id;

END Is_Mr_Qa_Enabled;


------------------------------------------------------------------------------------------------
-- Function to determine if parts changes are allowed for a workorder
-- 1. If the unit is quarantined then part changes are not allowed.
-- 2. If the workorder status is anything other than Released (3) or On Parts Hold (19) then part changes
--    are not allowed.
------------------------------------------------------------------------------------------------
FUNCTION Is_PartChange_Enabled(
	P_workorder_id		IN	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2
IS
/*
 * Cursor for getting the status of the workorder id passed as input to this API.
 * workorder status mapping
 * ------------------------
 * 3 Released
 * 19 on parts hold
 */
CURSOR c_get_workorder_details(p_workorder_id IN NUMBER)
IS
SELECT AWOS.STATUS_CODE,
       NVL(VTS.INSTANCE_ID, VST.ITEM_INSTANCE_ID)
FROM
	AHL_WORKORDERS AWOS,
	AHL_VISITS_B VST,
	AHL_VISIT_TASKS_B VTS
WHERE
        AWOS.VISIT_TASK_ID = VTS.VISIT_TASK_ID   AND
        VST.VISIT_ID = VTS.VISIT_ID  AND
	WORKORDER_ID = p_workorder_id;

-- declare local variables here
l_status_code      VARCHAR2(30);
l_item_instance_id NUMBER;

l_unit_config_name ahl_unit_config_headers.name%TYPE;
l_unit_config_id   NUMBER;
l_return_status    VARCHAR2(1);
BEGIN
	-- If sole input to this API p_workorder_id is null then return false
	IF p_workorder_id IS NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- If the Unit is locked then part changes cannot be done hence return false
	IF p_check_unit = FND_API.G_TRUE THEN
	IF Is_Unit_Locked(
			  p_workorder_id => p_workorder_id,
			  P_ue_id		=>	null,
			  P_visit_id		=>	null,
			  P_item_instance_id	=>	null
			 ) = FND_API.G_TRUE THEN
		RETURN FND_API.G_FALSE;
	END IF;
	END IF;

	-- If workorder is in an invalid status where part changes cannot be done then
	-- return false;
	OPEN c_get_workorder_details(p_workorder_id);
	FETCH c_get_workorder_details INTO l_status_code, l_item_instance_id;
	CLOSE c_get_workorder_details;

	IF l_status_code NOT IN ('3', '19') THEN
		RETURN FND_API.G_FALSE;
	END IF;

        AHL_PRD_PARTS_CHANGE_PVT.get_unit_config_information(
                                    p_item_instance_id => l_item_instance_id,
                                    p_workorder_id => null,
                                    x_unit_config_id   => l_unit_config_id,
                                    x_unit_config_name => l_unit_config_name,
                                    x_return_status    => l_return_status);
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN FND_API.G_FALSE;
       END IF;

        -- All above conditions are false hence part changes can be done. return true.
	RETURN FND_API.G_TRUE;

END Is_PartChange_Enabled;


------------------------------------------------------------------------------------------------
-- Function to check if resource assignment should be allowed. The logic is based on following
-- factors :
-- 1. The unit is quarantined.
-- 2. A user is currently logged into the resource assignment.
-- 3. Resource transactions have been posted corresponding to this resource assignment.
------------------------------------------------------------------------------------------------
FUNCTION IsDelAsg_Enabled(
		P_assignment_id		IN	NUMBER,
		P_workorder_id		IN	NUMBER,
	        p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2
IS

/*
 * Cursor for getting resource assignment details given assingment id.
 */
CURSOR c_get_ass_details(p_assignment_id IN NUMBER)
IS
SELECT
	WREQ.operation_sequence,
	WREQ.resource_sequence
FROM
	AHL_WORK_ASSIGNMENTS WASS,
	AHL_PP_REQUIREMENT_V WREQ
WHERE
	WASS.assignment_id = p_assignment_id AND
	WREQ.resource_id = WASS.operation_resource_id AND
	login_date IS NOT NULL;

-- declare local variables here
--l_login_date DATE;
l_op_seq_num NUMBER;
l_res_seq_num NUMBER;

BEGIN

	-- If sole input to this API p_workorder_id is null then return false
	IF P_assignment_id IS NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;
	-- If the Unit is locked then Assignment cant be deleted return false.
	IF p_check_unit = FND_API.G_TRUE THEN
	IF Is_Unit_Locked(
			  p_workorder_id 	=> p_workorder_id,
			  P_ue_id		=>	null,
			  P_visit_id		=>	null,
			  P_item_instance_id	=>	null
			 ) = FND_API.G_TRUE
	THEN
		Fnd_Message.Set_Name('AHL', 'AHL_PP_DEL_RESASG_UNTLCKD');
		Fnd_Msg_Pub.ADD;
		RETURN FND_API.G_FALSE;
	END IF;
	END IF;

	OPEN c_get_ass_details(p_assignment_id);
	FETCH c_get_ass_details INTO l_op_seq_num, l_res_seq_num;

	IF c_get_ass_details%FOUND
	THEN
		FND_MESSAGE.Set_Name('AHL', 'AHL_PP_DELASG_LOGDIN');
		FND_MESSAGE.set_token( 'OP_SEQ' , l_op_seq_num);
		FND_MESSAGE.set_token( 'RES_SEQ' , l_res_seq_num);
		Fnd_Msg_Pub.ADD;

		CLOSE c_get_ass_details;
		RETURN FND_API.G_FALSE;
	END IF;
	CLOSE c_get_ass_details;


	/*IF l_login_date IS NOT NULL
	THEN
		-- the user is currently logged in corresponding to this resource assignment
		-- the resource assignment cannot be deleted
		RETURN FND_API.G_FALSE;
	END IF;
	*/

	RETURN FND_API.G_TRUE;

END IsDelAsg_Enabled;

FUNCTION Is_Wo_Completable(
	P_workorder_id		IN 	NUMBER
)
RETURN VARCHAR2
IS
/*
 * Cursor for selecting workorder status validity.
 */
CURSOR c_validate_wo_status(p_workorder_id IN NUMBER) IS
SELECT
	'X'
FROM
	ahl_workorders
WHERE
	workorder_id = p_workorder_id AND
	status_code in (1,4,5,7, 12,21, 22);

/*
 * Cursor for selecting operation status validity.
 */
CURSOR c_validate_op_status(p_workorder_id IN NUMBER) IS
SELECT
	'X'
FROM
	ahl_workorder_operations
WHERE
	workorder_id = p_workorder_id AND
	status_code in (0,2);

-- declare local variables here
l_exists VARCHAR2(1);

BEGIN
	-- If workorder_id is null then immediately return false.
	IF p_workorder_id IS NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	OPEN c_validate_wo_status(p_workorder_id);
	FETCH c_validate_wo_status INTO l_exists;
	CLOSE c_validate_wo_status;

	IF l_exists IS NOT NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	OPEN c_validate_op_status(p_workorder_id);
	FETCH c_validate_op_status INTO l_exists;
	CLOSE c_validate_op_status;

	IF l_exists IS NOT NULL
	THEN
		RETURN FND_API.G_FALSE;
	END IF;

	-- If this point is reached then neither the unit is locked nor the workorder is
	-- in invalid status. Return true here.
	RETURN FND_API.G_TRUE;

END Is_Wo_Completable;

------------------------------------------------------------------------------------------------
-- Function to test if resource transactions are allowed for a workorder
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_ResTxn_Allowed
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
-- Is_Unit_Locked IN parameters:
--      P_workorder_id		NUMBER		Required
--
-- Is_Unit_Locked IN OUT parameters:
--      None
--
-- Is_Unit_Locked OUT parameters:
--      None.
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_ResTxn_Allowed(
	P_workorder_id		IN 	NUMBER,
	p_check_unit            IN      VARCHAR2 DEFAULT FND_API.G_TRUE
)
RETURN VARCHAR2
IS
-- cursor to retrieve the workorder status
CURSOR get_wo_status (c_wo_id NUMBER)
IS
SELECT STATUS_CODE
FROM AHL_WORKORDERS
WHERE WORKORDER_ID = c_wo_id;

l_return_value VARCHAR2(1);
l_wo_status    VARCHAR2(30);
BEGIN

l_return_value := FND_API.G_FALSE;
IF p_check_unit = FND_API.G_TRUE THEN
l_return_value := is_unit_locked(p_workorder_id => p_workorder_id,
                                 p_ue_id => NULL,
				p_item_instance_id => NULL,
				p_visit_id => NULL
				);
-- If the unit is locked, then resource transactions are not allowed
IF l_return_value = FND_API.G_TRUE THEN
  RETURN FND_API.G_FALSE;
END IF;
END IF;

OPEN get_wo_status(p_workorder_id);
FETCH get_wo_status INTO l_wo_status;
CLOSE get_wo_status;

-- If the workorder is in status On Hold, Closed, Complete No Charge, Unreleased, Cancelled
-- then resource transactions are not allowed
IF l_wo_status IS NULL OR l_wo_status IN ('6','12','5','1', '7', '13') THEN
  RETURN FND_API.G_FALSE;
END IF;

RETURN FND_API.G_TRUE;

END Is_ResTxn_Allowed;

------------------------------------------------------------------------------------------------
-- Function to test if user has privileges to cancel a workorder that is not un-released
-- or if user has privileges to cancel any work order.
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Function name               : Is_Wo_Cancel_Allowed
-- Type                        : Private
-- Pre-reqs                    :
-- Parameters                  :
-- Return		       : FND_API.G_TRUE or FND_API.G_FALSE.
--
-- Standard IN  Parameters :
--	None
--
-- Standard OUT Parameters :
--	None
--
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

FUNCTION Is_Wo_Cancel_Allowed(
	P_workorder_id		IN 	  NUMBER := NULL
) RETURN VARCHAR2
IS
-- cursor to retrieve whether workorder is released
CURSOR is_workorders_released(c_wo_id NUMBER)
IS
SELECT 'x'
FROM AHL_WORKORDERS WO,wip_discrete_jobs WIP
WHERE WO.wip_entity_id = WIP.wip_entity_id
AND WIP.date_released IS NOT NULL AND
WO.WORKORDER_ID = c_wo_id;

l_junk VARCHAR2(1);

BEGIN

IF NOT(FND_FUNCTION.TEST('AHL_PRD_DISALLOW_CANCEL_JOBS',null)) THEN

   -- if no workorder ID is passed, then check for only AHL_PRD_DISALLOW_CANCEL_JOBS
   -- function access.
   IF (p_workorder_id IS NULL) THEN
    return FND_API.G_TRUE;
   ELSE
      OPEN is_workorders_released(p_workorder_id);
      FETCH is_workorders_released INTO l_junk;
      IF(is_workorders_released%NOTFOUND)THEN
        CLOSE is_workorders_released;
        return FND_API.G_TRUE;
      END IF;
      CLOSE is_workorders_released;

      IF(FND_FUNCTION.TEST('AHL_PRD_CANCEL_REL_JOBS',null))THEN
        return FND_API.G_TRUE;
      END IF;
   END IF;

END IF;

RETURN FND_API.G_FALSE;

END Is_Wo_Cancel_Allowed;

-- Start of Comments --
--  Function name : Get_Op_TotalHours_Assigned
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function returns the total hours assigned to an operation.
--                  If the user role is technician or line maintenance technician, then the
--                  total hours are calculated for that particular employee resource,
--                  otherwise the total hours are calculated for all the person type
--                  resources in the operation. If the employee id is not passed to the
--                  function then the calculations are done for the user who is currently
--                  logged into the application.
--

FUNCTION Get_Op_TotalHours_Assigned (p_employee_id       IN NUMBER := NULL,
                                     p_workorder_id      IN NUMBER,
                                     p_operation_seq_num IN NUMBER,
                                     p_fnd_function_name IN VARCHAR2)
RETURN NUMBER

IS

  -- query to retrieve total hrs assigned to an employee for an operation.
  CURSOR c_get_total_hours_emp(p_employee_id IN NUMBER,
                               p_workorder_id IN NUMBER,
                               p_operation_seq_num IN NUMBER) IS
    SELECT SUM((AWAS.assign_end_date - AWAS.assign_start_date) * 24)
    FROM AHL_WORKORDER_OPERATIONS WO, AHL_OPERATION_RESOURCES AOR,
         AHL_WORK_ASSIGNMENTS AWAS, BOM_RESOURCES BOM
    WHERE WO.workorder_operation_id = AOR.workorder_operation_id
      AND AOR.operation_resource_id = AWAS.operation_resource_id
      AND BOM.resource_id = AOR.resource_id
      AND BOM.resource_type = 2  -- Person
      AND WO.workorder_id = p_workorder_id
      AND WO.operation_sequence_num = p_operation_seq_num
      AND AWAS.employee_id = p_employee_id;

  -- query to retrieve total hrs required for all employees for an operation.
  CURSOR c_get_total_hours_op(p_workorder_id IN NUMBER,
                              p_operation_seq_num IN NUMBER) IS
    SELECT SUM(NVL(AOR.duration, 0))
    FROM AHL_OPERATION_RESOURCES AOR,
         BOM_RESOURCES BOMR,
         AHL_WORKORDER_OPERATIONS AWOP
    WHERE AOR.RESOURCE_ID = BOMR.RESOURCE_ID
      AND BOMR.resource_type = 2  -- Person
      AND AOR.WORKORDER_OPERATION_ID = AWOP.WORKORDER_OPERATION_ID
      AND AWOP.workorder_id = p_workorder_id
      AND AWOP.operation_sequence_num = p_operation_seq_num;

  l_employee_id  NUMBER;
  l_total_hours  NUMBER;

BEGIN

  l_total_hours := 0;
  IF (p_fnd_function_name = G_TECH_MYWO) THEN  -- Technician.
    -- Get logged in user's emp ID if input employee ID is null.
    IF (p_employee_id IS NULL) THEN
       l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID;
    ELSE
       l_employee_id := p_employee_id;
    END IF;

    -- get total hrs.
    OPEN c_get_total_hours_emp(l_employee_id, p_workorder_id, p_operation_seq_num);
    FETCH c_get_total_hours_emp INTO l_total_hours;
    CLOSE c_get_total_hours_emp;
  ELSE    -- Data Clerk, Transit role.
    OPEN c_get_total_hours_op(p_workorder_id, p_operation_seq_num);
    FETCH c_get_total_hours_op INTO l_total_hours;
    CLOSE c_get_total_hours_op;
  END IF;

  RETURN round(l_total_hours,3);

END Get_Op_TotalHours_Assigned;
-----------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Res_TotalHours_Assigned
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_id       -- Mandatory resource ID.
--                  p_resource_seq_num   -- Mandatory resource ID.
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function returns the total hours assigned for a specific resource
--                  within an operation. If the employee id passed to the function is null,
--                  then the calculations are done for the user who is currently logged
--                  into the application.

FUNCTION Get_Res_TotalHours_Assigned (p_employee_id       IN NUMBER := NULL,
                                      p_workorder_id      IN NUMBER,
                                      p_operation_seq_num IN NUMBER,
                                      p_resource_id       IN NUMBER,
								      p_resource_seq_num IN NUMBER,
                                      p_fnd_function_name IN VARCHAR2)
RETURN NUMBER
IS
  -- query to retrieve total hrs assigned to an employee for an operation-resource.
  CURSOR c_get_total_hours_emp(p_employee_id IN NUMBER,
                               p_workorder_id IN NUMBER,
                               p_operation_seq_num IN NUMBER,
                               p_resource_id       IN NUMBER,
							   p_resource_seq_num IN NUMBER ) IS
    SELECT SUM((AWAS.assign_end_date - AWAS.assign_start_date) * 24)
    FROM AHL_WORKORDER_OPERATIONS WO, AHL_OPERATION_RESOURCES AOR,
         AHL_WORK_ASSIGNMENTS AWAS, BOM_RESOURCES BOM
    WHERE WO.workorder_operation_id = AOR.workorder_operation_id
      AND AOR.operation_resource_id = AWAS.operation_resource_id
      AND BOM.resource_id = AOR.resource_id
      AND BOM.resource_type = 2  -- Person
      AND WO.workorder_id = p_workorder_id
      AND WO.operation_sequence_num = p_operation_seq_num
      AND AOR.resource_id = p_resource_id
      AND AWAS.employee_id = p_employee_id
      AND AOR.RESOURCE_SEQUENCE_NUM = p_resource_seq_num;
  -- query to retrieve total hrs assigned to all employees for an operation-resource.
  CURSOR c_get_total_hours_op(p_workorder_id IN NUMBER,
                              p_operation_seq_num IN NUMBER,
                              p_resource_id       IN NUMBER,
							  p_resource_seq_num IN NUMBER ) IS
    SELECT SUM((AWAS.assign_end_date - AWAS.assign_start_date) * 24)
    FROM AHL_WORKORDER_OPERATIONS WO, AHL_OPERATION_RESOURCES AOR,
         AHL_WORK_ASSIGNMENTS AWAS, BOM_RESOURCES BOM
    WHERE WO.workorder_operation_id = AOR.workorder_operation_id
      AND AOR.operation_resource_id = AWAS.operation_resource_id
      AND BOM.resource_id = AOR.resource_id
      AND BOM.resource_type = 2  -- Person
      AND WO.workorder_id = p_workorder_id
      AND WO.operation_sequence_num = p_operation_seq_num
      AND AOR.resource_id = p_resource_id
      AND AOR.RESOURCE_SEQUENCE_NUM = p_resource_seq_num;
  l_total_hours  NUMBER;
  l_employee_id  NUMBER;

BEGIN

  l_total_hours := 0;
  IF (p_fnd_function_name = G_TECH_MYWO) THEN  -- Technician.
      -- Get logged in user's emp ID if input employee ID is null.
      IF (p_employee_id IS NULL) THEN
         l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID;
      ELSE
         l_employee_id := p_employee_id;
    END IF;

    -- get total hrs.
    OPEN c_get_total_hours_emp(l_employee_id, p_workorder_id, p_operation_seq_num,
                               p_resource_id,p_resource_seq_num);
    FETCH c_get_total_hours_emp INTO l_total_hours;
    CLOSE c_get_total_hours_emp;
  ELSE
    -- Data Clerk, Transit.
    OPEN c_get_total_hours_op(p_workorder_id, p_operation_seq_num, p_resource_id,p_resource_seq_num);
    FETCH c_get_total_hours_op INTO l_total_hours;
    CLOSE c_get_total_hours_op;
  END IF;

  RETURN round(l_total_hours,3);

END Get_Res_TotalHours_Assigned;
-----------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Op_Transacted_Hours
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--  Description   : This function returns the number of hours transacted by an employee
--                  accross all resources within an operation. If the employee id passed to the
--                  function is null then the calculations are based on the user currently logged
--                  into the application.

FUNCTION Get_Op_Transacted_Hours (p_employee_id       IN NUMBER := NULL,
                                  p_wip_entity_id     IN NUMBER,
                                  p_operation_seq_num IN NUMBER,
                                  p_fnd_function_name IN VARCHAR2)
RETURN NUMBER
IS
  -- query to retrieve total hrs transacted by an employee.
  CURSOR c_get_res_txns_emp(p_wip_entity_id     IN NUMBER,
                            p_operation_seq_num IN NUMBER,
                            p_employee_id       IN NUMBER ) IS
    SELECT   NVL( SUM( transaction_quantity ), 0 )
      FROM    WIP_TRANSACTIONS WT, BOM_RESOURCES BRS
      WHERE   WT.resource_id = BRS.resource_id
        AND   BRS.resource_type = 2  -- person.
        AND   wt.wip_entity_id = p_wip_entity_id
        AND   wt.operation_seq_num = p_operation_seq_num
        AND   wt.employee_id = p_employee_id;

  -- query to get pending resource txns for an employee.
  CURSOR c_get_pend_res_txns_emp(p_wip_entity_id NUMBER,
                                 p_operation_seq_num NUMBER,
                                 p_employee_id NUMBER ) IS
    SELECT NVL( SUM( transaction_quantity ), 0 )
    FROM   WIP_COST_TXN_INTERFACE wcti, bom_resources br, wip_operation_resources wor
    WHERE  wcti.wip_entity_id = wor.wip_entity_id
      AND  wcti.operation_seq_num = wor.operation_seq_num
      AND  wcti.resource_seq_num = wor.resource_seq_num
      AND  wcti.organization_id = wor.organization_id
      AND  wor.resource_id = br.resource_id
      AND  br.resource_type = 2
      AND  wcti.wip_entity_id = p_wip_entity_id
      AND  wcti.operation_seq_num = p_operation_seq_num
      AND  wcti.employee_id = p_employee_id
      AND  wcti.process_status <> 3; -- skip errored txns.

  -- query to retrieve total hrs transacted by all employees.
  CURSOR c_get_res_txns_op(p_wip_entity_id     IN NUMBER,
                           p_operation_seq_num IN NUMBER) IS
    SELECT   NVL( SUM( transaction_quantity ), 0 )
      FROM   WIP_TRANSACTIONS WT, BOM_RESOURCES BRS
      WHERE  WT.resource_id = BRS.resource_id
        AND  BRS.resource_type = 2  -- person.
        AND  WT.wip_entity_id = p_wip_entity_id
        AND  WT.operation_seq_num = p_operation_seq_num;

  -- query to get pending resource txns for all employees.
  CURSOR c_get_pend_res_txns_op(p_wip_entity_id NUMBER,
                                p_operation_seq_num NUMBER) IS
		-- Here we cannot join with wcti.resource_id column
		-- since this col can be null.
    SELECT NVL( SUM( transaction_quantity ), 0 )
    FROM   WIP_COST_TXN_INTERFACE wcti, bom_resources br, wip_operation_resources wor
    WHERE  wcti.wip_entity_id = wor.wip_entity_id
      AND  wcti.operation_seq_num = wor.operation_seq_num
      AND  wcti.resource_seq_num = wor.resource_seq_num
      AND  wcti.organization_id = wor.organization_id
      AND  wor.resource_id = br.resource_id
      AND  br.resource_type = 2
      AND  wcti.wip_entity_id = p_wip_entity_id
      AND  wcti.operation_seq_num = p_operation_seq_num
      AND  wcti.process_status <> 3; -- skip errored txns.

  l_total_hrs  NUMBER;
  l_pending_hrs  NUMBER;
  l_employee_id  NUMBER;

BEGIN

  l_total_hrs := 0;
  l_pending_hrs := 0;
    IF (p_fnd_function_name = G_TECH_MYWO OR p_fnd_function_name = G_LINE_TECH) THEN

    -- Get logged in user's emp ID if input employee ID is null.
    IF (p_employee_id IS NULL) THEN
       l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID;
    ELSE
       l_employee_id := p_employee_id;
    END IF;
    -- get emp txns for an wo-oper.
    OPEN c_get_res_txns_emp(p_wip_entity_id, p_operation_seq_num, l_employee_id);
    FETCH c_get_res_txns_emp INTO l_total_hrs;
    CLOSE c_get_res_txns_emp;
    -- get pending txns.
    OPEN c_get_pend_res_txns_emp(p_wip_entity_id, p_operation_seq_num, l_employee_id);
    FETCH c_get_pend_res_txns_emp INTO l_pending_hrs;
    CLOSE c_get_pend_res_txns_emp;
    l_total_hrs := l_total_hrs + l_pending_hrs;

  ELSE -- Data Clerk

    -- get operation txns.
      OPEN c_get_res_txns_op(p_wip_entity_id, p_operation_seq_num);
      FETCH c_get_res_txns_op INTO l_total_hrs;
      CLOSE c_get_res_txns_op;

      -- get pending txns.
      OPEN c_get_pend_res_txns_op(p_wip_entity_id, p_operation_seq_num);
      FETCH c_get_pend_res_txns_op INTO  l_pending_hrs;
      CLOSE c_get_pend_res_txns_op;

    l_total_hrs := l_total_hrs + l_pending_hrs;
  END IF;  -- p_fnd_function_name.

  RETURN round(l_total_hrs,3);

END Get_Op_Transacted_Hours;
-----------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Res_Transacted_Hours
--
--  Parameters  :
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_wip_entity_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_resource_seq_num  -- Mandatory Resource ID.
--                  p_fnd_function_name  -- Mandatory fnd_function to identify user role.
--
--  Description   : This function returns the number of hours transacted by an employee
--                  for a particular resource requirement within an operation if the user is
--                  has a role of a technician or line maintenance technician. It returns the
--                  number of hours transacted by all employees for a resource requirement
--                  within an operation if the user is a data clerk.
--

FUNCTION Get_Res_Transacted_Hours (p_employee_id      IN NUMBER := NULL,
                                   p_wip_entity_id     IN NUMBER,
                                   p_operation_seq_num IN NUMBER,
                                   p_resource_seq_num  IN NUMBER,
                                   p_fnd_function_name IN VARCHAR2)
RETURN NUMBER
IS
  -- query to retrieve total hrs transacted by an employee.
  CURSOR c_get_res_txns_emp(p_wip_entity_id     IN NUMBER,
                            p_operation_seq_num IN NUMBER,
                            p_resource_seq_num  IN NUMBER,
                            p_employee_id       IN NUMBER ) IS
    SELECT   NVL( SUM( transaction_quantity ), 0 )
      FROM    WIP_TRANSACTIONS WT, BOM_RESOURCES BRS
      WHERE   WT.resource_id = BRS.resource_id
        AND   BRS.resource_type = 2  -- person.
        AND   WT.transaction_type = 1 -- resource txn.
        AND   wt.wip_entity_id = p_wip_entity_id
        AND   wt.operation_seq_num = p_operation_seq_num
        AND   wt.resource_seq_num = p_resource_seq_num
        AND   wt.employee_id = p_employee_id;

  -- query to get pending resource txns for an employee.
  CURSOR c_get_pend_res_txns_emp(p_wip_entity_id NUMBER,
                                 p_operation_seq_num NUMBER,
                                 p_resource_seq_num  IN NUMBER,
                                 p_employee_id NUMBER ) IS
    SELECT NVL( SUM( transaction_quantity ), 0 )
    FROM   WIP_COST_TXN_INTERFACE wcti, bom_resources br,
           wip_operation_resources wor
    WHERE  wcti.wip_entity_id = wor.wip_entity_id
      AND  wcti.operation_seq_num = wor.operation_seq_num
      AND  wcti.resource_seq_num = wor.resource_seq_num
      AND  wcti.organization_id = wor.organization_id
      AND  wor.resource_id = br.resource_id
      AND  br.resource_type = 2  -- person
      AND  wcti.transaction_type = 1  -- resource txn.
      AND  wcti.wip_entity_id = p_wip_entity_id
      AND  wcti.operation_seq_num = p_operation_seq_num
      AND  wcti.resource_seq_num = p_resource_seq_num
      AND  wcti.employee_id = p_employee_id
      AND  wcti.process_status <> 3; -- skip errored txns.

  -- query to retrieve total hrs transacted by all employees.
  CURSOR c_get_res_txns_res(p_wip_entity_id     IN NUMBER,
                            p_operation_seq_num IN NUMBER,
                            p_resource_seq_num  IN NUMBER) IS
    SELECT   NVL( SUM( transaction_quantity ), 0 )
      FROM    WIP_TRANSACTIONS WT, BOM_RESOURCES BRS
      WHERE   WT.resource_id = BRS.resource_id
        AND   BRS.resource_type = 2  -- person.
        AND   WT.transaction_type = 1 -- resource txn.
        AND   wt.wip_entity_id = p_wip_entity_id
        AND   wt.operation_seq_num = p_operation_seq_num
        AND   wt.resource_seq_num = p_resource_seq_num;

  -- query to get pending resource txns for all employees.
  -- Here we cannot join with wcti.resource_id column
  -- since this col maybe null
  CURSOR c_get_pend_res_txns_res(p_wip_entity_id IN NUMBER,
                                 p_operation_seq_num IN NUMBER,
                                 p_resource_seq_num  IN NUMBER) IS
    SELECT NVL( SUM( transaction_quantity ), 0 )
    FROM   WIP_COST_TXN_INTERFACE wcti, bom_resources br,
           wip_operation_resources wor
    WHERE  wcti.wip_entity_id = wor.wip_entity_id
      AND  wcti.operation_seq_num = wor.operation_seq_num
      AND  wcti.resource_seq_num = wor.resource_seq_num
      AND  wcti.organization_id = wor.organization_id
      AND  wor.resource_id = br.resource_id
      AND  br.resource_type = 2  -- person
      AND  wcti.transaction_type = 1  -- resource txn.
      AND  wcti.wip_entity_id = p_wip_entity_id
      AND  wcti.operation_seq_num = p_operation_seq_num
      AND  wcti.resource_seq_num = p_resource_seq_num
      AND  wcti.process_status <> 3; -- skip errored txns.

  l_total_hrs    NUMBER;
  l_pending_hrs  NUMBER;
  l_employee_id  NUMBER;
  l_fnd_function_name VARCHAR2(80);

BEGIN

  l_total_hrs := 0;
  l_pending_hrs := 0;

  -- Though p_fnd_function_name is mandatory it cannot be passed from the OA Tech Search UI
  -- due to the limitation with OA inner table. Hence putting the code here.
  l_fnd_function_name := p_fnd_function_name;
  IF (l_fnd_function_name IS NULL) THEN
  	l_fnd_function_name := AHL_PRD_WO_LOGIN_PVT.Get_User_Role;
  END IF;

  -- Technician or Transit Technician
  IF (l_fnd_function_name = G_TECH_MYWO OR l_fnd_function_name = G_LINE_TECH) THEN

    -- Get logged in user's emp ID if input employee ID is null.
    IF (p_employee_id IS NULL) THEN
       l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID;
    ELSE
       l_employee_id := p_employee_id;
    END IF;

    -- get emp txns for an wo-oper.
    OPEN c_get_res_txns_emp(p_wip_entity_id, p_operation_seq_num, p_resource_seq_num,l_employee_id);
    FETCH c_get_res_txns_emp INTO l_total_hrs;
    CLOSE c_get_res_txns_emp;

    -- get pending txns.
    OPEN c_get_pend_res_txns_emp(p_wip_entity_id, p_operation_seq_num, p_resource_seq_num,l_employee_id);
    FETCH c_get_pend_res_txns_emp INTO l_pending_hrs;
    CLOSE c_get_pend_res_txns_emp;

    l_total_hrs := l_total_hrs + l_pending_hrs;

  ELSE -- Data Clerk
      -- get operation txns.
      OPEN c_get_res_txns_res(p_wip_entity_id, p_operation_seq_num, p_resource_seq_num);
      FETCH c_get_res_txns_res INTO l_total_hrs;
      CLOSE c_get_res_txns_res;

      -- get pending txns.
      OPEN c_get_pend_res_txns_res(p_wip_entity_id, p_operation_seq_num, p_resource_seq_num);
      FETCH c_get_pend_res_txns_res INTO  l_pending_hrs;
      CLOSE c_get_pend_res_txns_res;

    l_total_hrs := l_total_hrs + l_pending_hrs;
  END IF;  -- p_fnd_function_name.

  RETURN round(l_total_hrs,3);

END Get_Res_Transacted_Hours;
-----------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Op_Assigned_Start_Date
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function will be used to retrieve the Assigned Start Date for an
--                  operation as displayed on the Operations subtab of the Update Workorders
--                  page. The logic for retrieving the correct date is as follows:
--                      1. If the user is a technician, then assigned start time is the
--                         assign_start_date for the employee if he is assigned to only
--                         one resource within the operation.
--                         If the employee is assigned to more than one resource within
--                         the operation, then the assigned start date is the earliest
--                         of all the assignment dates for the employee.
---2.	If the user is a data clerk or a line maintenance technician, then the assigned
---        start date is the scheduled start date for the operation.

--

FUNCTION Get_Op_Assigned_Start_Date(p_employee_id       IN NUMBER := NULL,
                                    p_workorder_id      IN NUMBER,
                                    p_operation_seq_num IN NUMBER,
                                    p_fnd_function_name IN VARCHAR2)
RETURN DATE

IS

  -- query to retrieve min of assigned to an employee for an operation.
  CURSOR c_get_assigned_start_emp(p_employee_id IN NUMBER,
                                  p_workorder_id IN NUMBER,
                                  p_operation_seq_num IN NUMBER) IS
    SELECT MIN(AWAS.ASSIGN_START_DATE)
    FROM WIP_Operation_Resources WOR, AHL_OPERATION_RESOURCES AOR,
         AHL_WORK_ASSIGNMENTS AWAS, AHL_WORKORDERS AW
    WHERE WOR.resource_id = AOR.resource_id
      AND WOR.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
      AND AOR.operation_resource_id = AWAS.operation_resource_id
      AND WOR.wip_entity_id = AW.wip_entity_id
      AND AWAS.employee_id = p_employee_id
      AND AW.workorder_id = p_workorder_id
      AND WOR.operation_seq_num = p_operation_seq_num;

  -- query to retrieve min of assigned to all employees for an operation.
  CURSOR c_get_op_sched_start(p_workorder_id IN NUMBER,
                              p_operation_seq_num IN NUMBER) IS
    SELECT SCHEDULED_START_DATE
    FROM AHL_WORKORDER_OPERATIONS_V  AO
    WHERE AO.workorder_id = p_workorder_id
      AND AO.operation_sequence_num = p_operation_seq_num;

  l_employee_id  NUMBER;
  l_assigned_start  DATE;

BEGIN

  IF (p_fnd_function_name = G_TECH_MYWO) THEN  -- Technician.
    -- Get logged in user's emp ID if input employee ID is null.
    IF (p_employee_id IS NULL) THEN
       l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID;
    ELSE
       l_employee_id := p_employee_id;
    END IF;

    -- get assigned start.
    OPEN c_get_assigned_start_emp(l_employee_id, p_workorder_id, p_operation_seq_num);
    FETCH c_get_assigned_start_emp INTO l_assigned_start;
    CLOSE c_get_assigned_start_emp;
  ELSE    -- Data Clerk, Transit role.
    OPEN c_get_op_sched_start(p_workorder_id, p_operation_seq_num);
    FETCH c_get_op_sched_start INTO l_assigned_start;
    CLOSE c_get_op_sched_start;
  END IF;

  RETURN l_assigned_start;

END Get_Op_Assigned_Start_Date;
-----------------------------------------------------------------------------------------

-- Start of Comments --
--  Function name : Get_Op_Assigned_End_Date
--
--  Parameters  :
--
--                  p_employee_id    --  Optional Input Employee Id.
--                  p_workorder_id   --  Mandatory Workorder ID.
--                  p_operation_seq_num -- Mandatory Operation Seq Number
--                  p_fnd_function_name   -- Mandatory fnd_function to identify User role.
--
--
--  Description   : This function will be used to retrieve the Assigned End Date for an
--                  operation as displayed on the Operations subtab of the Update Workorders
--                  page. The logic for retrieving the correct date is as follows:
--                      1. If the user is a technician, then assigned end time is the
--                         assign_end_date for the employee if he is assigned to only
--                         one resource within the operation.
--                         If the employee is assigned to more than one resource within
--                         the operation, then the assigned end date is the latest
--                         of all the assignment dates for the employee.
---                     2. If the user is a data clerk or a line maintenance technician, then
--                         the assigned end date is the scheduled start date for the operation.
--

FUNCTION Get_Op_Assigned_End_Date(p_employee_id       IN NUMBER := NULL,
                                  p_workorder_id      IN NUMBER,
                                  p_operation_seq_num IN NUMBER,
                                  p_fnd_function_name IN VARCHAR2)
RETURN DATE

IS

  -- query to retrieve min of assigned to an employee for an operation.
  CURSOR c_get_assigned_end_emp(p_employee_id IN NUMBER,
                                p_workorder_id IN NUMBER,
                                p_operation_seq_num IN NUMBER) IS
    SELECT MAX(AWAS.ASSIGN_END_DATE)
    FROM WIP_Operation_Resources WOR, AHL_OPERATION_RESOURCES AOR,
         AHL_WORK_ASSIGNMENTS AWAS, AHL_WORKORDERS AW
    WHERE WOR.resource_id = AOR.resource_id
      AND WOR.RESOURCE_SEQ_NUM = AOR.RESOURCE_SEQUENCE_NUM
      AND AOR.operation_resource_id = AWAS.operation_resource_id
      AND WOR.wip_entity_id = AW.wip_entity_id
      AND AWAS.employee_id = p_employee_id
      AND AW.workorder_id = p_workorder_id
      AND WOR.operation_seq_num = p_operation_seq_num;

  -- query to retrieve min of assigned to all employees for an operation.
  CURSOR c_get_op_sched_end(p_workorder_id IN NUMBER,
                            p_operation_seq_num IN NUMBER) IS
    SELECT SCHEDULED_END_DATE
    FROM AHL_WORKORDER_OPERATIONS_V  AO
    WHERE AO.workorder_id = p_workorder_id
      AND AO.operation_sequence_num = p_operation_seq_num;

  l_employee_id  NUMBER;
  l_assigned_end  DATE;

BEGIN

  IF (p_fnd_function_name = G_TECH_MYWO) THEN  -- Technician.
    -- Get logged in user's emp ID if input employee ID is null.
    IF (p_employee_id IS NULL) THEN
       l_employee_id := AHL_PRD_WO_LOGIN_PVT.Get_Employee_ID;
    ELSE
       l_employee_id := p_employee_id;
    END IF;

    -- get assigned start.
    OPEN c_get_assigned_end_emp(l_employee_id, p_workorder_id, p_operation_seq_num);
    FETCH c_get_assigned_end_emp INTO l_assigned_end;
    CLOSE c_get_assigned_end_emp;
  ELSE    -- Data Clerk, Transit role.
    OPEN c_get_op_sched_end(p_workorder_id, p_operation_seq_num);
    FETCH c_get_op_sched_end INTO l_assigned_end;
    CLOSE c_get_op_sched_end;
  END IF;

  RETURN l_assigned_end;

END Get_Op_Assigned_End_Date;

 -- Start of Comments --
 -- Function name : Hr_To_Duration
 -- Created by JKJ on 9th Jan 2009 for Bug No. 7658562. Fp bug 8241923
 -- Parameters  :
 -- p_hr   -- Input : Total Hours in Decimal Format.
 -- Description  :
 -- This function returns a String in Hours:Minutes:Seconds format when given hours as input in decimal format.
 --
 FUNCTION Hr_To_Duration(
 p_hr  IN        NUMBER
 )
 RETURN VARCHAR2 IS

 l_hr   NUMBER;
 l_min  NUMBER;
 l_sec  NUMBER;
 l_temp NUMBER;

 BEGIN
 -- If input Hours is null , Then make it 0.
 l_temp := NVL(p_hr,0);
 --  Taking the Integer part of the Hours(in Decimal Format), without rounding off
 l_hr := Floor(l_temp);
 --  Multiplying Decimal Part of Hours by 60 to get the Minute
 l_temp := ((l_temp-l_hr)*60);
 --  Taking the Integer part of the Minutes(in Decimal Format), without rounding off
 l_min := Floor(l_temp);
 --  Multiplying Decimal Part of Minutes by 60 to get the Seconds
 l_temp := ((l_temp-l_min)*60);
 --  Taking the Integer part of the Seconds(in Decimal Format), with rounding off to Integer
 l_sec := Round(l_temp,0);

 RETURN (l_hr||':'||l_min||':'||l_sec);

 END Hr_To_Duration;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

END AHL_PRD_UTIL_PKG; -- Package Body AHL_PRD_UTIL_PKG

/
