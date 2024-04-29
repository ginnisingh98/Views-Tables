--------------------------------------------------------
--  DDL for Package Body MRP_LAUNCH_PLAN_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_LAUNCH_PLAN_PK" AS
 /* $Header: MRPPLAPB.pls 120.1 2006/06/22 13:24:12 rgurugub noship $ */

-- ************************* mrp_launch_plan ******************************* --

	PROCEDURE 		mrp_launch_plan (
                                errbuf  OUT NOCOPY VARCHAR2,
								retcode OUT NOCOPY NUMBER,
								arg_org_id IN NUMBER,
								arg_compile_desig IN VARCHAR2,
								arg_launch_snapshot IN NUMBER,
								arg_launch_planner IN NUMBER,
								arg_anchor_date IN VARCHAR2,
								arg_plan_horizon IN VARCHAR2 default NULL)
IS

	var_exploder_req_id		INTEGER;
	var_snapshot_req_id		INTEGER;
	var_planner_req_id		INTEGER;
	var_mps_relief_req_id	INTEGER;
	var_user_id             INTEGER;
	var_production1			INTEGER;
	var_production2			INTEGER;
	var_auto_release_id 	INTEGER;
	months					NUMBER;
        var_new_date            DATE;

        G_MRP_DEBUG   VARCHAR2(1); /*2663505*/

BEGIN
      G_MRP_DEBUG := FND_PROFILE.VALUE('MRP_DEBUG') ; /*2663505*/

	/*----------------------------------------+
	| Update mrp_plans with plan horizon date |
	+----------------------------------------*/

        IF G_MRP_DEBUG = 'Y' THEN /*2663505*/

	MRP_UTIL.Mrp_Debug('******About to Launch Plan******');
        END IF ; /*2663505*/

	IF arg_plan_horizon IS  NULL THEN
		months := fnd_profile.value('MRP_CUTOFF_DATE_OFFSET');

        var_new_date := MRP_CALENDAR.NEXT_WORK_DAY(arg_org_id,1,
                TO_DATE(TO_CHAR(add_months(sysdate, NVL(months, 12)),
                        'YYYY/MM/DD HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS')) ;
		UPDATE mrp_plans
		SET   	curr_cutoff_date = var_new_date,
		plan_completion_date = NULL,
		data_completion_date = NULL
		WHERE   organization_id = arg_org_id
		AND    compile_designator = arg_compile_desig;
		COMMIT;
	ELSE

        var_new_date := MRP_CALENDAR.NEXT_WORK_DAY(arg_org_id,1,TO_DATE(arg_plan_horizon, 'YYYY/MM/DD HH24:MI:SS')) ;
		UPDATE mrp_plans
		SET    curr_cutoff_date = var_new_date,
		plan_completion_date = NULL,
		data_completion_date = NULL
		WHERE  organization_id = arg_org_id
		AND    compile_designator = arg_compile_desig;
		COMMIT;
	END IF;
	/*---------------------------------------+
	| Update mrp_parameters with anchor date |
	+---------------------------------------*/
	UPDATE mrp_parameters
	SET    repetitive_anchor_date = TO_DATE(arg_anchor_date, 'YYYY/MM/DD HH24:MI:SS')
	WHERE  organization_id IN (select planned_organization
								from mrp_plan_organizations_v
								where organization_id = arg_org_id
								and compile_designator = arg_compile_desig);

	COMMIT;

	/*-------------+
	| Get user id  |
	+--------------*/

	var_user_id := fnd_profile.value('USER_ID');
	/*-----------------------------------------------+
	| Insert subinventories into mrp_sub_inventories |
	| that are defined after options are defined     |
	+-----------------------------------------------*/
   BEGIN
	   INSERT INTO MRP_SUB_INVENTORIES
				(SUB_INVENTORY_CODE,
				 ORGANIZATION_ID,
				 COMPILE_DESIGNATOR,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_LOGIN,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 NETTING_TYPE)
		   SELECT  msi.secondary_inventory_name,
			mpo.planned_organization,
			arg_compile_desig,
			SYSDATE,
			1,
			-1,
			SYSDATE,
			1,
			msi.availability_type
		   FROM    MTL_SECONDARY_INVENTORIES msi,
				   mrp_plan_organizations_v mpo
			 WHERE   NOT EXISTS
				(SELECT NULL
				 FROM MRP_SUB_INVENTORIES SUB
				 WHERE SUB.ORGANIZATION_ID = mpo.planned_organization
				 AND SUB.COMPILE_DESIGNATOR = mpo.compile_designator
				 AND SUB.sub_inventory_code = msi.SECONDARY_INVENTORY_NAME)
				 AND NVL(MSI.DISABLE_DATE, SYSDATE + 1) > TRUNC(SYSDATE)
		AND msi.ORGANIZATION_ID = mpo.planned_organization
		and mpo.organization_id = arg_org_id
		and mpo.compile_designator = arg_compile_desig;

		COMMIT;
	EXCEPTION when no_data_found then
		null;
	END;


	IF (arg_launch_snapshot = SYS_YES) THEN
		var_mps_relief_req_id := NULL;
		var_mps_relief_req_id := FND_REQUEST.SUBMIT_REQUEST (
												'MRP',
												'MRCMPW',
												NULL,
												NULL,
												FALSE,
												TO_CHAR(4));
	    COMMIT;

       IF G_MRP_DEBUG = 'Y' THEN /*2663505*/

       MRP_UTIL.Mrp_Debug('Launched MPS Relief Worker:'||
				  to_char(var_mps_relief_req_id));
       END IF ; /*2663505*/

			var_snapshot_req_id := NULL;
			var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
													'MRP', -- application
													'MRCNSP', -- program
													NULL,  -- description
													NULL, -- start time
													FALSE, -- sub_request
													TO_CHAR(arg_org_id),
													arg_compile_desig);
	    COMMIT;

        IF G_MRP_DEBUG = 'Y' THEN /*2663505*/
        MRP_UTIL.Mrp_Debug('Launched Snapshot:'||
					  to_char(var_snapshot_req_id));
        END IF ; /*2663505*/

	END IF; /* if arg_launch_snapshot = SYS_YES */

	IF ((arg_launch_planner = SYS_YES) AND
			(arg_launch_snapshot = SYS_NO)) THEN
		var_planner_req_id := NULL;
		var_planner_req_id := FND_REQUEST.SUBMIT_REQUEST(
												'MRP', -- application
												'MRCNEW', -- program
												NULL, -- description
												NULL, -- start time
												FALSE, -- sub_request
												TO_CHAR(arg_org_id),
												arg_compile_desig,
												0);
	COMMIT;

    IF G_MRP_DEBUG = 'Y' THEN /*2663505*/
    MRP_UTIL.Mrp_Debug('Launched Planner:'||
					  to_char(var_planner_req_id));
    END IF ; /*2663505*/
	END IF;

	begin
	SELECT NVL(production, SYS_NO)
	INTO   var_production1
	FROM   mrp_designators
	WHERE  organization_id = arg_org_id
	AND    compile_designator = arg_compile_desig;
	exception when no_data_found then
	null;
	end;

	begin
	SELECT NVL(production, SYS_NO)
	INTO   var_production2
	FROM   mrp_schedule_designators
	WHERE  organization_id = arg_org_id
	AND    schedule_designator = arg_compile_desig;
	exception when no_data_found then
	null;
	end;
    IF G_MRP_DEBUG = 'Y' THEN /*2663505*/
    MRP_UTIL.Mrp_Debug('Exiting with Success');
    END IF ; /*2663505*/
	retcode := 0;
	errbuf := NULL;
	return;
EXCEPTION
   WHEN OTHERS THEN
	   retcode := 2;
	   errbuf := 'Error in launching plan:' || to_char(sqlcode);
END mrp_launch_plan;

--*************************** get_crp_status ******************************--

FUNCTION get_crp_status (app_id IN NUMBER,
                                            dep_app_id IN NUMBER)
                                            RETURN VARCHAR2  IS
status VARCHAR2(1);
ret_val boolean;
industry VARCHAR2(1);
BEGIN
	ret_val:= FND_INSTALLATION.get(app_id, dep_app_id, status, industry);
	RETURN (status);
END;


END; -- package

/
