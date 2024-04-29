--------------------------------------------------------
--  DDL for Package JTF_TASK_ASSIGNMENT_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_ASSIGNMENT_AUDIT_PKG" AUTHID CURRENT_USER AS
  /* $Header: jtftkaus.pls 120.0.12010000.1 2009/04/13 08:27:50 anangupt noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_TASK_ASSIGNMENT_AUDIT_PKG';

 /*#
   * Procedure to accept call for creation of audit record for change in
   * task assignment. This procedure validates if the update is actual
   * update or a dummy update by comparing values passed with the values
   * stored for the given assignment.This procedure inturn calls
   * INSERT_ROW() procedure to create row in database.
   *
   * @param p_api_version   Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their
   * behalf. By default, the message list will not be initialized. See "Standard IN Parameters", Oracle Common Application Calendar API Reference
   * Guide.
   * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default,
   * the commit will not be performed.See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
   * @param p_object_version_number Object version number of the current record.
   * @param p_task_id  task ID
   * @param P_TASK_ASSIGNMENT_ID   Assignment id
   * @param p_new_resource_type_code  new resource type code
   * @param p_new_resource_id     new resource id
   * @param p_new_assignment_status  new assignment status
   * @param p_new_actual_effort     new actual effort
   * @param p_new_actual_effort_uom  new actual effort UOM
   * @param p_new_res_territory_id   new resoruce territory id
   * @param p_new_assignee_role      new assignee role
   * @param p_new_schedule_flag      new schedule flag
   * @param p_new_alarm_type         new alarm type
   * @param p_new_alarm_contact      new alarm contact
   * @param p_new_update_status_flag  new update status flag
   * @param p_new_show_on_cal_flag  new show on calendar flag
   * @param p_new_category_id       new category id
   * @param p_new_free_busy_type       new free busy type
   * @param p_new_booking_start_date   new booking start date
   * @param p_new_booking_end_date     new booking end date
   * @param p_new_actual_travel_distance new actual travel distance
   * @param p_new_actual_travel_duration new actual travel duration
   * @param p_new_actual_travel_dur_uom new actual travel duration UOM
   * @param p_new_sched_travel_distance new schedule travel distance
   * @param p_new_sched_travel_duration new schedule travel duration
   * @param p_new_sched_travel_dur_uom  new schedule travel duration UOM
   * @param p_new_actual_start_date    new actual start date
   * @param p_new_actual_end_date      new actual end date
   * @param x_return_status            Result of all the operations performed by the API. This will have one of the following values:
   * <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
   * <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
   * <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
   * @param x_msg_count  Number of messages returned in the API message list.
   * @param x_msg_data   Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
   */
    PROCEDURE CREATE_TASK_ASSIGNMENT_AUDIT (
      P_API_VERSION                 IN       NUMBER,
      P_INIT_MSG_LIST               IN       VARCHAR2 DEFAULT FND_API.G_FALSE,
      P_COMMIT                      IN       VARCHAR2 DEFAULT FND_API.G_FALSE,
      P_OBJECT_VERSION_NUMBER       IN       NUMBER,
      P_TASK_ID                     IN       NUMBER,
      P_TASK_ASSIGNMENT_ID          IN       NUMBER,
      P_NEW_RESOURCE_TYPE_CODE      IN       VARCHAR2 DEFAULT NULL,
      P_NEW_RESOURCE_ID             IN       NUMBER DEFAULT NULL,
      P_NEW_ASSIGNMENT_STATUS       IN       NUMBER DEFAULT NULL,
      P_NEW_ACTUAL_EFFORT           IN       NUMBER DEFAULT NULL,
      P_NEW_ACTUAL_EFFORT_UOM       IN       VARCHAR2 DEFAULT NULL,
      P_NEW_RES_TERRITORY_ID        IN       NUMBER DEFAULT NULL,
      P_NEW_ASSIGNEE_ROLE           IN       VARCHAR2 DEFAULT NULL,
      P_NEW_SCHEDULE_FLAG           IN       VARCHAR2 DEFAULT NULL,
      P_NEW_ALARM_TYPE              IN       VARCHAR2 DEFAULT NULL,
      P_NEW_ALARM_CONTACT           IN       VARCHAR2 DEFAULT NULL,
      P_NEW_UPDATE_STATUS_FLAG      IN       VARCHAR2 DEFAULT NULL,
      P_NEW_SHOW_ON_CAL_FLAG        IN       VARCHAR2 DEFAULT NULL,
      P_NEW_CATEGORY_ID             IN       NUMBER DEFAULT NULL,
      P_NEW_FREE_BUSY_TYPE          IN       VARCHAR2 DEFAULT NULL,
      P_NEW_BOOKING_START_DATE      IN       DATE DEFAULT NULL,
      P_NEW_BOOKING_END_DATE        IN       DATE DEFAULT NULL,
      P_NEW_ACTUAL_TRAVEL_DISTANCE  IN       NUMBER DEFAULT NULL,
      P_NEW_ACTUAL_TRAVEL_DURATION  IN       NUMBER DEFAULT NULL,
      P_NEW_ACTUAL_TRAVEL_DUR_UOM IN       VARCHAR2 DEFAULT NULL,
      P_NEW_SCHED_TRAVEL_DISTANCE   IN       NUMBER DEFAULT NULL,
      P_NEW_SCHED_TRAVEL_DURATION   IN       NUMBER DEFAULT NULL,
      P_NEW_SCHED_TRAVEL_DUR_UOM    IN       VARCHAR2 DEFAULT NULL,
      P_NEW_ACTUAL_START_DATE       IN       DATE DEFAULT NULL,
      P_NEW_ACTUAL_END_DATE         IN       DATE DEFAULT NULL,
      X_RETURN_STATUS               OUT NOCOPY     VARCHAR2,
      X_MSG_COUNT                   OUT NOCOPY     NUMBER,
      X_MSG_DATA                    OUT NOCOPY     VARCHAR2
      );

 /*#
   * This procedure accepts new and old values for a task assigment.
   * and creates a new row in JTF_TASK_ASSIGNMENTS_AUDIT_B table
   *
   * @param p_object_version_number Object version number of the current record.
   * @param p_task_id  task ID
   * @param P_TASK_ASSIGNMENT_ID   Assignment id
   * @param p_new_resource_type_code  new resource type code
   * @param p_new_resource_id     new resource id
   * @param p_new_assignment_status  new assignment status
   * @param p_new_actual_effort     new actual effort
   * @param p_new_actual_effort_uom  new actual effort UOM
   * @param p_new_res_territory_id   new resoruce territory id
   * @param p_new_assignee_role      new assignee role
   * @param p_schedule_flag_changed     schedule flag changed or not.Possible values are 'Y' or 'N'
   * @param p_new_alarm_type         new alarm type
   * @param p_new_alarm_contact      new alarm contact
   * @param p_update_status_flag_changed update status flag changed or not.Possible values are 'Y' or 'N'
   * @param p_show_on_cal_flag_changed Show on calendar flag changed or not.Possible values are 'Y' or 'N'
   * @param p_new_category_id       new category id
   * @param p_free_busy_type_changed       free busy type flag changed or not.Possible values are 'Y' or 'N'
   * @param p_new_booking_start_date   new booking start date
   * @param p_new_booking_end_date     new booking end date
   * @param p_new_actual_travel_distance new actual travel distance
   * @param p_new_actual_travel_duration new actual travel duration
   * @param p_new_actual_travel_dur_uom new actual travel duration UOM
   * @param p_new_sched_travel_distance new schedule travel distance
   * @param p_new_sched_travel_duration new schedule travel duration
   * @param p_new_sched_travel_dur_uom  new schedule travel duration UOM
   * @param p_new_actual_start_date    new actual start date
   * @param p_new_actual_end_date      new actual end date
   * @param p_old_resource_type_code  old resource type code
   * @param p_old_resource_id     old resource id
   * @param p_old_assignment_status  old assignment status
   * @param p_old_actual_effort     old actual effort
   * @param p_old_actual_effort_uom  old actual effort UOM
   * @param p_old_res_territory_id   old resoruce territory id
   * @param p_old_assignee_role      old assignee role
   * @param p_old_alarm_type         old alarm type
   * @param p_old_alarm_contact      old alarm contact
   * @param p_old_category_id       old category id
   * @param p_old_booking_start_date   old booking start date
   * @param p_old_booking_end_date     old booking end date
   * @param p_old_actual_travel_distance old actual travel distance
   * @param p_old_actual_travel_duration old actual travel duration
   * @param p_old_actual_travel_dur_uom old actual travel duration UOM
   * @param p_old_sched_travel_distance old schedule travel distance
   * @param p_old_sched_travel_duration old schedule travel duration
   * @param p_old_sched_travel_dur_uom  old schedule travel duration UOM
   * @param p_old_actual_start_date    old actual start date
   * @param p_old_actual_end_date      old actual end date
   * @param x_return_status            Result of all the operations performed by the API. This will have one of the following values:
   * <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
   * <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
   * <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
   * @param x_msg_count  Number of messages returned in the API message list.
   * @param x_msg_data   Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
   */

     PROCEDURE INSERT_ROW (
       X_ASSIGNMENT_AUDIT_ID IN NUMBER,
       X_ASSIGNMENT_ID IN NUMBER,
       X_TASK_ID IN NUMBER,
       X_CREATION_DATE in DATE,
       X_CREATED_BY in NUMBER,
       X_LAST_UPDATE_DATE in DATE,
       X_LAST_UPDATED_BY in NUMBER,
       X_LAST_UPDATE_LOGIN in NUMBER,
       X_OLD_RESOURCE_TYPE_CODE IN VARCHAR2,
       X_NEW_RESOURCE_TYPE_CODE IN VARCHAR2,
       X_OLD_RESOURCE_ID IN NUMBER,
       X_NEW_RESOURCE_ID IN NUMBER,
       X_OLD_ASSIGNMENT_STATUS_ID IN NUMBER,
       X_NEW_ASSIGNMENT_STATUS_ID IN NUMBER,
       X_OLD_ACTUAL_EFFORT IN NUMBER,
       X_NEW_ACTUAL_EFFORT IN NUMBER,
       X_OLD_ACTUAL_EFFORT_UOM IN VARCHAR2,
       X_NEW_ACTUAL_EFFORT_UOM IN VARCHAR2,
       X_OLD_RES_TERRITORY_ID IN NUMBER,
       X_NEW_RES_TERRITORY_ID IN NUMBER,
       X_OLD_ASSIGNEE_ROLE IN VARCHAR2,
       X_NEW_ASSIGNEE_ROLE IN VARCHAR2,
       X_OLD_ALARM_TYPE IN VARCHAR2,
       X_NEW_ALARM_TYPE IN VARCHAR2,
       X_OLD_ALARM_CONTACT IN VARCHAR2,
       X_NEW_ALARM_CONTACT IN VARCHAR2,
       X_OLD_CATEGORY_ID IN NUMBER,
       X_NEW_CATEGORY_ID IN NUMBER,
       X_OLD_BOOKING_START_DATE IN DATE,
       X_NEW_BOOKING_START_DATE IN DATE,
       X_OLD_BOOKING_END_DATE IN DATE,
       X_NEW_BOOKING_END_DATE IN DATE,
       X_OLD_ACTUAL_TRAVEL_DISTANCE IN NUMBER,
       X_NEW_ACTUAL_TRAVEL_DISTANCE IN NUMBER,
       X_OLD_ACTUAL_TRAVEL_DURATION IN NUMBER,
       X_NEW_ACTUAL_TRAVEL_DURATION IN NUMBER,
       X_OLD_ACTUAL_TRAVEL_DUR_UOM IN VARCHAR2,
       X_NEW_ACTUAL_TRAVEL_DUR_UOM IN VARCHAR2,
       X_OLD_SCHED_TRAVEL_DISTANCE IN NUMBER,
       X_NEW_SCHED_TRAVEL_DISTANCE IN NUMBER,
       X_OLD_SCHED_TRAVEL_DURATION IN NUMBER,
       X_NEW_SCHED_TRAVEL_DURATION IN NUMBER,
       X_OLD_SCHED_TRAVEL_DUR_UOM IN VARCHAR2,
       X_NEW_SCHED_TRAVEL_DUR_UOM IN VARCHAR2,
       X_OLD_ACTUAL_START_DATE IN DATE,
       X_NEW_ACTUAL_START_DATE IN DATE,
       X_OLD_ACTUAL_END_DATE IN DATE,
       X_NEW_ACTUAL_END_DATE IN DATE,
       X_FREE_BUSY_TYPE_CHANGED IN VARCHAR2,
       X_UPDATE_STATUS_FLAG_CHANGED IN VARCHAR2,
       X_SHOW_ON_CALENDAR_CHANGED IN VARCHAR2,
       X_SCHEDULED_FLAG_CHANGED IN VARCHAR2
       );

/*#
  * This procedure acceptsassignmetn id for a deleted task assignment
  * and removes all assignment audit records from JTF_TASK_ASSIGNMENTS_AUDIT_B
  * table corresponds to the given TASK_ASSIGNMENT_ID
  *
  * @param X_ASSIGNMENT_ID task Assignment ID of task assignment which is deleted.
  */

   PROCEDURE DELETE_ROW(X_ASSIGNMENT_ID NUMBER);

END jtf_task_assignment_audit_pkg;

/
