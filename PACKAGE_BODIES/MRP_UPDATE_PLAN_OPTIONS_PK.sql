--------------------------------------------------------
--  DDL for Package Body MRP_UPDATE_PLAN_OPTIONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_UPDATE_PLAN_OPTIONS_PK" AS
/* $Header: MRPPUPLB.pls 115.0 99/07/16 12:35:24 porting ship $ */

/******************mrp_update_options****************************************/
	PROCEDURE 		mrp_update_options (
								arg_org_id IN NUMBER,
								arg_user_id IN NUMBER,
								arg_compile_desig IN VARCHAR2)
IS

	var_org_selection		INTEGER;

BEGIN

	SELECT 	NVL(organization_selection, SINGLE_ORG)
	INTO	var_org_selection
	FROM	mrp_plans
	WHERE	organization_id = arg_org_id
	AND		compile_designator = arg_compile_desig;

	IF var_org_selection =  SINGLE_ORG THEN

    	UPDATE  mrp_plans
		SET     explosion_start_date = SYSDATE,
				explosion_completion_date = SYSDATE,
				data_start_date = SYSDATE,
				data_completion_date = NULL,
				last_update_date = SYSDATE,
				last_updated_by = arg_user_id,
				schedule_designator = curr_schedule_designator,
				schedule_type = curr_schedule_type,
				operation_schedule_type = curr_operation_schedule_type,
				plan_type = curr_plan_type,
				cutoff_date = curr_cutoff_date,
				part_include_type = curr_part_include_type,
				planning_time_fence_flag =
						curr_planning_time_fence_flag,
				demand_time_fence_flag = curr_demand_time_fence_flag,
				consider_reservations = curr_consider_reservations,
				plan_safety_stock = curr_plan_safety_stock,
				consider_wip = curr_consider_wip,
				consider_po = curr_consider_po,
				snapshot_lock = curr_snapshot_lock,
				overwrite_option = curr_overwrite_option,
				append_planned_orders = curr_append_planned_orders,
				full_pegging = curr_full_pegging,
				reservation_level = curr_reservation_level,
				hard_pegging_level = curr_hard_pegging_level
		WHERE   organization_id = arg_org_id
		  AND   compile_designator = arg_compile_desig;

		COMMIT;

	ELSE

		UPDATE  mrp_plans
		SET		explosion_start_date = SYSDATE,
                explosion_completion_date = SYSDATE,
                data_start_date = SYSDATE,
                data_completion_date = NULL,
                last_update_date = SYSDATE,
                last_updated_by = arg_user_id,
				operation_schedule_type = curr_operation_schedule_type,
                plan_type = curr_plan_type,
                cutoff_date = curr_cutoff_date,
                part_include_type = curr_part_include_type,
                planning_time_fence_flag =
                        curr_planning_time_fence_flag,
                demand_time_fence_flag = curr_demand_time_fence_flag,
                snapshot_lock = curr_snapshot_lock,
                overwrite_option = curr_overwrite_option,
                append_planned_orders = curr_append_planned_orders,
				assignment_set_id = curr_assignment_set_id,
				full_pegging = curr_full_pegging,
				reservation_level = curr_reservation_level,
				hard_pegging_level = curr_hard_pegging_level
		WHERE	organization_id = arg_org_id
		AND		compile_designator = arg_compile_desig;

		COMMIT;

		INSERT
				INTO mrp_plan_organizations
					(organization_id,
					 compile_designator,
					 planned_organization,
					 plan_level,
					 last_updated_by,
					 last_update_date,
					 created_by,
					 creation_date,
					 last_update_login,
					 net_wip,
					 net_reservations,
					 net_purchasing,
			 		 plan_safety_stock)
		SELECT		organization_id,
					compile_designator,
					planned_organization,
					LAST_LAST_SUBMITTED,
					arg_user_id,
					SYSDATE,
					arg_user_id,
					SYSDATE,
					-1,
					net_wip,
					net_reservations,
					net_purchasing,
					plan_safety_stock
		FROM		mrp_plan_organizations orgs
		WHERE   	orgs.organization_id = arg_org_id
		AND			orgs.compile_designator = arg_compile_desig
		AND			orgs.plan_level = LAST_SUBMITTED
		AND			NOT EXISTS
					(SELECT	null
					 from	mrp_plan_organizations orgs1
					 where	orgs1.organization_id = orgs.organization_id
					 and	orgs1.compile_designator = orgs.compile_designator
					 and	orgs1.plan_level = LAST_LAST_SUBMITTED
					 and	orgs1.planned_organization =
								orgs.planned_organization);
		COMMIT;

		DELETE FROM mrp_plan_organizations
		WHERE	organization_id = arg_org_id
		AND		compile_designator = arg_compile_desig
		AND		plan_level =  LAST_SUBMITTED;

		COMMIT;

        DELETE FROM mrp_plan_schedules
        WHERE   organization_id = arg_org_id
        AND     compile_designator = arg_compile_desig
        AND     plan_level =  LAST_SUBMITTED;

        COMMIT;

		INSERT
				INTO mrp_plan_organizations
					(organization_id,
					 compile_designator,
					 planned_organization,
					 plan_level,
					 last_updated_by,
					 last_update_date,
					 created_by,
					 creation_date,
					 last_update_login,
					 net_wip,
					 net_reservations,
					 net_purchasing,
			 		 plan_safety_stock)
		SELECT		organization_id,
					compile_designator,
					planned_organization,
					LAST_SUBMITTED,
					arg_user_id,
					SYSDATE,
					arg_user_id,
					SYSDATE,
					-1,
					net_wip,
					net_reservations,
					net_purchasing,
					plan_safety_stock
		FROM		mrp_plan_organizations
		WHERE   	organization_id = arg_org_id
		AND			compile_designator = arg_compile_desig
		AND			plan_level = CURRENT_LEVEL;

		COMMIT;

		INSERT
				INTO mrp_plan_schedules
					(organization_id,
					 compile_designator,
					 input_type,
					 input_name,
					 input_organization_id,
					 plan_level,
					 last_updated_by,
					 last_update_date,
					 created_by,
					 creation_date,
					 last_update_login)
		SELECT		organization_id,
					compile_designator,
					input_type,
					input_name,
					input_organization_id,
					LAST_SUBMITTED,
					arg_user_id,
					SYSDATE,
					arg_user_id,
					SYSDATE,
					-1
		FROM		mrp_plan_schedules
		WHERE		organization_id = arg_org_id
		AND			compile_designator = arg_compile_desig
		AND			plan_level = CURRENT_LEVEL;

		COMMIT;
	END IF;

END	mrp_update_options;

/********************mrp_set_completion_time**********************************/
PROCEDURE mrp_set_completion_time (
                        arg_org_id IN NUMBER,
                        arg_user_id IN NUMBER,
                        arg_compile_desig IN VARCHAR2) IS
		var_org_selection       INTEGER;
BEGIN

    UPDATE 	mrp_plans
    SET     data_completion_date = SYSDATE,
            update_bom = SYS_NO,
            last_update_date = SYSDATE,
            last_updated_by = arg_user_id
    WHERE   organization_id = arg_org_id
    AND   	compile_designator = arg_compile_desig;

	SELECT 	NVL(organization_selection, SINGLE_ORG)
	INTO	var_org_selection
	FROM	mrp_plans
	WHERE	organization_id = arg_org_id
	AND		compile_designator = arg_compile_desig;

	if var_org_selection <> SINGLE_ORG
	THEN
		DELETE	from mrp_plan_organizations
		WHERE	organization_id = arg_org_id
		AND		compile_designator = arg_compile_desig
		AND		plan_level = LAST_LAST_SUBMITTED;
	end if;

    COMMIT;

END mrp_set_completion_time;

END mrp_update_plan_options_pk;

/
