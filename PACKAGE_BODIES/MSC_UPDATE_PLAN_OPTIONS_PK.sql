--------------------------------------------------------
--  DDL for Package Body MSC_UPDATE_PLAN_OPTIONS_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_UPDATE_PLAN_OPTIONS_PK" AS
/* $Header: MSCPUPLB.pls 120.1 2005/07/06 13:25:39 pabram noship $ */

/******************msc_update_options****************************************/
	PROCEDURE 		msc_update_options (
								arg_plan_id IN NUMBER,
								arg_user_id IN NUMBER)
IS


BEGIN


    	UPDATE  msc_plans
		SET
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
		WHERE   plan_id = arg_plan_id;

		COMMIT;


END	msc_update_options;

/********************msc_set_completion_time**********************************/
PROCEDURE msc_set_completion_time (
                        arg_plan_id IN NUMBER,
						arg_user_id IN NUMBER) IS
BEGIN

    UPDATE 	msc_plans
    SET     data_completion_date = SYSDATE,
            last_update_date = SYSDATE,
            last_updated_by = arg_user_id
    WHERE   plan_id = arg_plan_id;


    COMMIT;

END msc_set_completion_time;

END msc_update_plan_options_pk;

/
