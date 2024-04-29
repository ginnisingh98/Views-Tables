--------------------------------------------------------
--  DDL for Package JTA_SYNC_TASK_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_SYNC_TASK_COMMON" AUTHID CURRENT_USER AS
/* $Header: jtavstcs.pls 115.58 2002/12/13 22:25:44 cjang ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|          jtavstcs.pls                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|          This package is a common for sync task                       |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date          Developer        Change                                 |
| ------        ---------------  -------------------------------------- |
| 21-Feb-2002   cjang            Refactoring                            |
| 22-Feb-2002   cjang            Refactoring                            |
| 25-Feb-2002   cjang            Bug Fix to select assignments          |
|                                        for an assignee                |
|                                Removed p_alarm_uom on set_alarm_date()|
|                                Removed include_record()               |
| 27-Feb-2002   cjang            Added can_update_task, get_max_enddate |
|                                Added recurrences to the cursor c_task |
|                                Added a cursor c_repeating_task        |
|                                Added add_task_with_recurrence         |
|                                Modified adjust_timezone               |
| 28-Feb-2002   cjang            Integrate with invitee function        |
| 01-Mar-2002   cjang            Refactoring and Bug Fix                |
| 06-Mar-2002   cjang            Added get_all_nonrepeat_tasks          |
|                                      get_all_repeat_tasks             |
|                                      create_new_data                  |
|                                      update_existing_data             |
|                                      add_nonrepeat_task               |
|                                      add_repeat_task                  |
|                                      convert_task_to_gmt              |
|                                Modified parameters on add_task        |
| 11-Mar-2002   cjang            Added the followings                   |
|                                - delete_exclusion_task                |
|                                - delete_task_data                     |
|                                - reject_task_data                     |
|                                - changed_repeat_rule                  |
|                                - update_repeating_rule                |
| 11-Mar-2002   sanjeev          - Changing methos to include exclusion |
| 13-Mar-2002   cjang            Added insert_or_update_mapping         |
|                                Changed OUT to IN OUT on the parameter |
|                                    x_task_rec in delete_exclusion_task|
| 25-Mar-2002   sanjeev          Added procedure  transformStatus and   |
|                                function getChangedStatusId()          |
| 08-Apr-2002   arpatel          Merged convert_dates2 with convert_dates|
| 08-Apr-2002   ssallaka         merged do_mapping anf insert_mapping   |
| 19-Apr-2002   cjang            Removed p_get_data from add_task()     |
| 30-Apr-2002   cjang            Added a new parameter p_resource_type  |
|                                in get_assignment_id                   |
| 23-May-2002   cjang            Added validate_syncid()                |
|                                 to fix bug 2382927                    |
| 05-Aug-2002   cjang            Changed the default for the parameter  |
|                                 p_mapping_type to G_NEW in the proc   |
|                                 create_new_data().                    |
|                                  Fixed bug 2497963                    |
| 04-Oct-2002   cjang           Fixed bug 2469488, 2469487, 2469479     |
|                                 Added function already_selected       |
*=======================================================================*/
   G_TASK_TYPE_GENERAL  CONSTANT NUMBER := 15; -- Task Type Name = General
   G_NEW        CONSTANT VARCHAR2(10) := 'New';
   G_MODIFY     CONSTANT VARCHAR2(10) := 'Modify';
   G_DELETE     CONSTANT VARCHAR2(10) := 'Delete';
   G_GMT_TIMEZONE_ID    CONSTANT NUMBER := 0;
   G_SERVER_TIMEZONE_ID CONSTANT NUMBER := TO_NUMBER (fnd_profile.VALUE ('SERVER_TIMEZONE_ID'));
   G_SYNC_SUCCESS   CONSTANT NUMBER := 0;
   G_CLIENT_TIMEZONE_ID CONSTANT NUMBER := TO_NUMBER (fnd_profile.VALUE ('CLIENT_TIMEZONE_ID'));

   -- Define update_type
   G_UPDATE_ALL     CONSTANT VARCHAR2(10) := 'UPDATE_ALL';
   G_UPDATE_STATUS  CONSTANT VARCHAR2(13) := 'UPDATE_STATUS';
   G_DO_NOTHING     CONSTANT VARCHAR2(10) := 'DO_NOTHING';

   G_PREFIX_INVITEE CONSTANT VARCHAR2(8) := 'INVITE: ';
   G_APPOINTMENT CONSTANT VARCHAR2(12)  := 'APPOINTMENT';
   G_TASK   CONSTANT VARCHAR2(5) := 'TASK';
   G_REQ_APPOINTMENT CONSTANT VARCHAR2(12)  := 'APPOINTMENTS';
   G_REQ_TASK        CONSTANT VARCHAR2(12)  := 'TASKS';

   G_USER_STATUS_RULE         BOOLEAN;
   G_LOGIN_RESOURCE_ID        NUMBER;
   G_CARRIAGE_RETURN_XML      VARCHAR2(6) := '&#x0d;';
   G_CARRIAGE_RETURN_ORACLE   VARCHAR2(1) := '
';
   G_USER_DEFAULT_REPEAT_COUNT CONSTANT NUMBER := TO_NUMBER (fnd_profile.VALUE ('JTF_TASK_DEFAULT_REPEAT_COUNT'));

   -- The record type to store a group id and resource_type "RS_GROUP"
   TYPE resource_list_rec IS RECORD (
      resource_id      NUMBER,
      resource_type    VARCHAR2(100)
   );

   -- The PLSQL table to store a list of group ids and resource_types
   TYPE resource_list_tbl IS TABLE OF resource_list_rec
      INDEX BY BINARY_INTEGER;

   PROCEDURE get_resource_details (
      x_resource_id   OUT NOCOPY NUMBER,
      x_resource_type OUT NOCOPY VARCHAR2
   );

   FUNCTION get_client_priority(p_importance_level IN NUMBER)
      RETURN NUMBER;

   -------------------------------
   -- Public cursor
   -------------------------------

   -- This returns a PLSQL table that stores a list of group ids and resource types
   FUNCTION get_group_calendar (p_resource_id IN NUMBER) RETURN resource_list_tbl;

   PROCEDURE get_group_resource (
      p_request_type  IN VARCHAR2,
      p_resource_id   IN NUMBER,
      p_resource_type IN VARCHAR2,
      x_resources     OUT NOCOPY resource_list_tbl
   );

   PROCEDURE get_alarm_mins (
      p_task_rec    IN jta_sync_task.task_rec,
      x_alarm_mins OUT NOCOPY NUMBER
   );

   -- Used in creating a new task
   FUNCTION convert_gmt_to_client (p_date IN DATE) RETURN DATE;
   -- Used in updating a task
   FUNCTION convert_gmt_to_task (p_date    IN DATE,
                 p_task_id IN NUMBER) RETURN DATE;
   -- Used in getting a list of tasks
   FUNCTION convert_task_to_gmt (p_date IN DATE,
                 p_timezone_id IN NUMBER) RETURN DATE;
   -- Used to establish a new syncanchor
   FUNCTION convert_server_to_gmt (p_date IN DATE) RETURN DATE;

   -- Used to convert syncanchor from GMT to Server timezone
   FUNCTION convert_gmt_to_server (p_date IN DATE) RETURN DATE;

   -- Used in creating a task
   PROCEDURE convert_dates (
      p_task_rec       IN       jta_sync_task.task_rec,
      p_operation      IN       VARCHAR2, --CREATE OR UPDATE
      x_planned_start      OUT NOCOPY      DATE,
      x_planned_end    OUT NOCOPY      DATE,
      x_scheduled_start    OUT NOCOPY      DATE,
      x_scheduled_end      OUT NOCOPY      DATE,
      x_actual_start       OUT NOCOPY      DATE,
      x_actual_end     OUT NOCOPY      DATE,
      x_date_selected      OUT NOCOPY      VARCHAR2,
      x_show_on_calendar   OUT NOCOPY      VARCHAR2
   );

   -- Used in getting a list of tasks
   PROCEDURE adjust_timezone(
      p_timezone_id      IN NUMBER,
      p_syncanchor       IN DATE,
      p_planned_start_date   IN DATE,
      p_planned_end_date     IN DATE,
      p_scheduled_start_date IN DATE,
      p_scheduled_end_date   IN DATE,
      p_actual_start_date    IN DATE,
      p_actual_end_date      IN DATE,
      p_item_display_type    IN NUMBER,
      x_task_rec     IN OUT NOCOPY jta_sync_task.task_rec);

   FUNCTION get_max_enddate(p_recurrence_rule_id IN NUMBER)
   RETURN DATE;

     PROCEDURE make_prefix(
      p_assignment_status_id    IN       NUMBER,
      p_source_object_type_code IN       VARCHAR2,
      p_resource_type           IN       VARCHAR2,
      p_resource_id             IN       NUMBER,
      p_group_id                IN       NUMBER,
      x_subject                 IN OUT NOCOPY   VARCHAR2
   );

   PROCEDURE check_delete_data(
       p_task_id      IN NUMBER,
       p_resource_id  IN NUMBER,
       p_objectcode   IN VARCHAR2,
       x_status_id   OUT NOCOPY NUMBER,
       x_delete_flag OUT NOCOPY VARCHAR2
   );

   FUNCTION get_assignment_id (p_task_id       IN NUMBER,
                               p_resource_id   IN NUMBER,
                               p_resource_type IN VARCHAR2 DEFAULT 'RS_EMPLOYEE'
   )
   RETURN NUMBER;

   FUNCTION get_assignment_status_id (p_task_id IN NUMBER,
                      p_resource_id IN NUMBER
   )
   RETURN NUMBER;

   PROCEDURE get_assignment_info(p_task_id      IN  NUMBER
                ,p_resource_id      IN  NUMBER
                ,x_assignee_role    OUT NOCOPY VARCHAR2
                ,x_assignment_status_id OUT NOCOPY NUMBER);

   PROCEDURE get_owner_info(p_task_id         IN  NUMBER,
                x_task_name       OUT NOCOPY VARCHAR2,
                x_owner_id        OUT NOCOPY NUMBER,
                x_owner_type_code OUT NOCOPY VARCHAR2);

   FUNCTION get_access(p_group_id    IN VARCHAR2
              ,p_resource_id IN NUMBER
   )
   RETURN VARCHAR2;

   FUNCTION get_source_object_type(p_task_id IN NUMBER)
   RETURN VARCHAR2;

   FUNCTION get_update_type (
     p_task_id     IN NUMBER,
     p_resource_id IN NUMBER,
     p_subject     IN VARCHAR2
)
   RETURN VARCHAR2;

   FUNCTION get_recurrence_rule_id(p_task_id IN NUMBER)
   RETURN NUMBER;

   PROCEDURE convert_recur_date_to_client(p_base_start_time IN DATE,
                      p_base_end_time   IN DATE,
                      p_start_date      IN DATE,
                      p_end_date        IN DATE,
                      p_occurs_which    IN NUMBER,
                      p_uom         IN VARCHAR2,
                      x_date_of_month  OUT NOCOPY NUMBER,
                      x_start_date     IN OUT NOCOPY DATE,
                      x_end_date       IN OUT NOCOPY DATE);

   PROCEDURE get_all_nonrepeat_tasks(
         p_request_type       IN VARCHAR2,
         p_syncanchor         IN DATE,
         p_recordindex        IN NUMBER,
         p_resource_id        IN NUMBER,
         p_resource_type      IN VARCHAR2,
         p_source_object_type IN VARCHAR2,
         p_get_data       IN BOOLEAN,
         x_totalnew       IN OUT NOCOPY NUMBER,
         x_totalmodified      IN OUT NOCOPY NUMBER,
         x_data           IN OUT NOCOPY jta_sync_task.task_tbl
         --p_new_syncanchor     in date
   );
   PROCEDURE get_all_deleted_tasks(
         p_request_type       IN VARCHAR2,
         p_syncanchor         IN DATE,
         p_recordindex        IN NUMBER,
         p_resource_id        IN NUMBER,
         p_resource_type      IN VARCHAR2,
         p_source_object_type IN VARCHAR2,
         p_get_data       IN BOOLEAN,
         x_totaldeleted       IN OUT NOCOPY NUMBER,
         x_data           IN OUT NOCOPY jta_sync_task.task_tbl
         --p_new_syncanchor     in date
   );
   PROCEDURE get_all_repeat_tasks(
         p_request_type       IN VARCHAR2,
         p_syncanchor         IN DATE,
         p_recordindex        IN NUMBER,
         p_resource_id        IN NUMBER,
         p_resource_type      IN VARCHAR2,
         p_source_object_type IN VARCHAR2,
         p_get_data       IN BOOLEAN,
         x_totalnew       IN OUT NOCOPY NUMBER,
         x_totalmodified      IN OUT NOCOPY NUMBER,
        -- x_totaldeleted   IN OUT NOCOPY NUMBER,
         x_data           IN OUT NOCOPY jta_sync_task.task_tbl,
         x_exclusion_data     IN OUT NOCOPY Jta_Sync_Task.exclusion_tbl
         --p_new_syncanchor     in date
   );

   PROCEDURE create_new_data(p_task_rec      IN OUT NOCOPY jta_sync_task.task_rec
                ,p_mapping_type  IN VARCHAR2 DEFAULT G_NEW -- Fixed bug 2497963 for 9i issue
                ,p_exclusion_tbl IN jta_sync_task.exclusion_tbl
                ,p_resource_id   IN NUMBER
                ,p_resource_type IN VARCHAR2
   );

   PROCEDURE update_existing_data(p_task_rec IN OUT NOCOPY jta_sync_task.task_rec
                  ,p_exclusion_tbl IN jta_sync_task.exclusion_tbl
                  ,p_resource_id   IN NUMBER
                  ,p_resource_type IN VARCHAR2);

   PROCEDURE delete_exclusion_task(
       p_repeating_task_id   IN     NUMBER
       ,x_task_rec       IN OUT NOCOPY jta_sync_task.task_rec
       );

   PROCEDURE delete_task_data(
       p_task_rec IN OUT NOCOPY jta_sync_task.task_rec
      ,p_delete_map_flag IN BOOLEAN DEFAULT TRUE
   );

   PROCEDURE reject_task_data(
       p_task_rec IN OUT NOCOPY jta_sync_task.task_rec
   );

   FUNCTION changed_repeat_rule(p_task_rec IN jta_sync_task.task_rec)
   RETURN BOOLEAN;

   -- function to check if a repeating task is on exclusion list
   FUNCTION check_for_exclusion(p_sync_id         IN NUMBER,
                p_exclusion_tbl       IN jta_sync_task.exclusion_tbl,
                p_calendar_start_date IN DATE,
                p_client_time_zone_id NUMBER)
   RETURN BOOLEAN;

   FUNCTION get_excluding_taskid (p_sync_id        IN NUMBER,
                  p_recurrence_rule_id IN NUMBER,
                  p_exclusion_rec      IN jta_sync_task.exclusion_rec)
   RETURN NUMBER;

   PROCEDURE transformStatus(p_task_status_id IN out NOCOPY  NUMBER,
                 p_task_sync_id   IN NUMBER,
                             x_operation      IN OUT NOCOPY VARCHAR2
                );

   FUNCTION getChangedStatusId(p_task_status_id      IN NUMBER,
                p_source_object_type_code IN VARCHAR2
                   )
   RETURN NUMBER;

   FUNCTION checkUserStatusRule RETURN BOOLEAN;

      FUNCTION is_this_new_task (
      p_sync_id IN NUMBER
      )
      RETURN BOOLEAN;

     FUNCTION get_task_id (
      p_sync_id IN NUMBER
      )
      RETURN NUMBER;

   FUNCTION get_ovn (p_task_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION get_ovn (p_task_assignment_id IN NUMBER)
      RETURN NUMBER;

     PROCEDURE do_mapping (
      p_task_id         IN     NUMBER,
      p_operation       IN     VARCHAR2,
      x_task_sync_id    IN OUT NOCOPY NUMBER
   );

   FUNCTION already_selected(p_task_id     IN NUMBER DEFAULT NULL
                            ,p_sync_id     IN NUMBER DEFAULT NULL
                            ,p_task_tbl    IN jta_sync_task.task_tbl)
   RETURN BOOLEAN;

   -- this procedure is made public only for testing ...should not be used otherwise
   PROCEDURE add_task (
      p_request_type           IN   VARCHAR2,
      p_resource_id        IN   NUMBER,
      p_resource_type          IN   VARCHAR2,
      p_recordindex        IN   NUMBER,
      p_operation          IN   VARCHAR2,
      p_task_sync_id           IN   NUMBER,
      p_task_id            IN   NUMBER,
      p_task_name          IN   VARCHAR2,
      p_owner_type_code        IN   VARCHAR2,
      p_description        IN   VARCHAR2,
      p_task_status_id         IN   NUMBER,
      p_task_priority_id       IN   NUMBER,
      p_private_flag           IN   VARCHAR2,
      p_date_selected          IN   VARCHAR2,
      p_timezone_id        IN   NUMBER,
      p_syncanchor         IN   DATE,
      p_planned_start_date     IN   DATE,
      p_planned_end_date       IN   DATE,
      p_scheduled_start_date   IN   DATE,
      p_scheduled_end_date     IN   DATE,
      p_actual_start_date      IN   DATE,
      p_actual_end_date        IN   DATE,
      p_calendar_start_date    IN   DATE,
      p_calendar_end_date      IN   DATE,
      p_alarm_on           IN   VARCHAR2,
      p_alarm_start        IN   NUMBER,
      p_recurrence_rule_id     IN   NUMBER,
      p_occurs_uom         IN   VARCHAR2,
      p_occurs_every           IN   NUMBER,
      p_occurs_number          IN   NUMBER,
      p_start_date_active      IN   DATE,
      p_end_date_active        IN   DATE,
      p_sunday             IN   VARCHAR2,
      p_monday             IN   VARCHAR2,
      p_tuesday            IN   VARCHAR2,
      p_wednesday          IN   VARCHAR2,
      p_thursday           IN   VARCHAR2,
      p_friday             IN   VARCHAR2,
      p_saturday           IN   VARCHAR2,
      p_date_of_month          IN   VARCHAR2,
      p_occurs_which           IN   VARCHAR2,
      x_task_rec           IN OUT NOCOPY   jta_sync_task.task_rec
   );

   FUNCTION set_alarm_date (
      p_task_id            IN   NUMBER,
      p_request_type           IN   VARCHAR2,
      p_scheduled_start_date   IN   DATE,
      p_planned_start_date     IN   DATE,
      p_actual_start_date      IN   DATE,
      p_alarm_flag         IN   VARCHAR2,
      p_alarm_start        IN   NUMBER
      )
   RETURN DATE ;

    -- Added to fix bug 2382927
    FUNCTION validate_syncid(p_syncid IN NUMBER)
    RETURN BOOLEAN;

END jta_sync_task_common;   -- Package spec

 

/
