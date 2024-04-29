--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_TASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_TASK" AS
/* $Header: cacvstsb.pls 120.8 2005/10/02 17:19:48 rhshriva noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cacvstsb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is for Task Business Logic.                          |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 04-Nov-2004   sachoudh         Created.                               |
 |                                                                       |
 +======================================================================*/

     -------------------------------
     -- Private Method
     -------------------------------


       PROCEDURE get_all_data (
        p_request_type   IN VARCHAR2,
        p_syncanchor     IN DATE,
        p_principal_id     IN NUMBER,
        p_get_data       IN BOOLEAN,
        p_sync_type      IN VARCHAR2,
        x_totalnew      OUT NOCOPY NUMBER,
        x_totalmodified OUT NOCOPY NUMBER,
        x_totaldeleted  OUT NOCOPY NUMBER,
        x_data          OUT NOCOPY cac_sync_task.task_tbl,
        x_exclusion_data  OUT NOCOPY cac_sync_task.exclusion_tbl,
        x_attendee_data     OUT NOCOPY Cac_Sync_Task.attendee_tbl
     )
     IS
        -- Added a group calendar feature
        -- Used to store the list of group resource ids for the current resource
        l_resources  cac_sync_task_common.resource_list_tbl;
        i            NUMBER := 0;
        l_operation  VARCHAR2(240);
        l_syncanchor DATE ;
        l_source_object_type VARCHAR2(60) := RTRIM(p_request_type,'S');
        l_task_rec cac_sync_task.task_rec;
        l_resource_id   NUMBER;
        l_resource_type VARCHAR2(30);
        l_new_syncanchor  date ;


      CURSOR c_assignment (b_task_id NUMBER)
      IS
      SELECT a.assignee_role, a.assignment_status_id,
                 a.resource_id, a.resource_type_code
      FROM   jtf_task_all_assignments a
      WHERE  a.task_id = b_task_id;

      cursor getEmployeeResourceInfo(b_resource_id NUMBER)
       is
        Select resource_id,
        source_phone, source_email, source_job_title,
        source_first_name, source_middle_name, source_last_name
      from
       JTF_RS_RESOURCE_EXTNS
      where
       resource_id =b_resource_id;

      cursor getGroupResourceInfo(b_resource_id NUMBER)
       is
       Select
       cp.party_id,
       pp.person_first_name,
       pp.person_middle_name,
       pp.person_last_name,
       cp.primary_phone_country_code,
       cp.primary_phone_area_code,
       cp.primary_phone_number,
       cp.primary_phone_extension,
       cp.email_address,
       ctct.job_title
      from
       HZ_PARTIES pp, HZ_PARTIES cp, HZ_RELATIONSHIPS rel, HZ_ORG_CONTACTS ctct
       where cp.party_id = rel.party_id
       and rel.relationship_id = ctct.party_relationship_id
       and rel.subject_id = pp.party_id
       and rel.directional_flag = 'F'
       and cp.party_id =b_resource_id;



       l_getEmployeeResourceInfo  getEmployeeResourceInfo%rowtype;
       l_getGroupResourceInfo     getGroupResourceInfo%rowtype;
       l_assignee_role             VARCHAR2(30);
       l_assignment_status_id      NUMBER;
       l_attendee_id               NUMBER;
       l_attendee_type_code        VARCHAR2(30);

       i_counter BINARY_INTEGER := 0 ;

       l_return_status    VARCHAR2(1);
       l_msg_count        NUMBER;
       l_msg_data         VARCHAR2(2000);

     BEGIN
        x_totalnew := 0;
        x_totalmodified := 0;
        x_totaldeleted := 0;

        cac_sync_task_common.get_resource_details (g_login_resource_id, l_resource_type);

        l_syncanchor := p_syncanchor;
        --JTA_SYNC_DEBUG_PKG.DEBUG('l_syncanchor = '||to_char(l_syncanchor,'DD-MON-YYYY HH24:MI:SS'));

        -----------------------------------------------------
        -- Get group ids including current resource id
        -----------------------------------------------------
        cac_sync_task_common.get_group_resource (
           p_request_type  => p_request_type,
           p_resource_id   => g_login_resource_id,
           p_resource_type => l_resource_type,
           x_resources     => l_resources
        );



        -----------------------------------------------------
        -- Loop with current resource id and group ids
        -----------------------------------------------------
        --l_new_syncanchor := sysdate;

       -- FOR j IN l_resources.FIRST .. l_resources.LAST
       -- LOOP
           -------------------------------------------------
           -- Process non repeat tasks
           -------------------------------------------------



           cac_sync_task_common.get_all_nonrepeat_tasks(
                 p_request_type       => p_request_type,
                 p_syncanchor         => l_syncanchor,
                 p_recordindex        => NVL(x_data.count,0),
                 p_resource_id        => g_login_resource_id,
                 p_principal_id       => p_principal_id,
                 p_resource_type      => l_resource_type,
                 p_source_object_type => l_source_object_type,
                 p_get_data           => p_get_data,
                 x_totalnew           => x_totalnew,
                 x_totalmodified      => x_totalmodified,
                 --x_totaldeleted       => x_totaldeleted,
                 --p_new_syncanchor => l_new_syncanchor,
                 x_data               => x_data
           );


           -------------------------------------------------
           -- Process repeating tasks
           -------------------------------------------------
           IF  l_source_object_type = 'APPOINTMENT'
           THEN
              cac_sync_task_common.get_all_repeat_tasks(
                    p_request_type       => p_request_type,
                    p_syncanchor         => l_syncanchor,
                    p_recordindex        => nvl(x_data.count,0) + 1,
                    p_resource_id        => g_login_resource_id,
                    p_principal_id       => p_principal_id,
                    p_resource_type      => l_resource_type,
                    p_source_object_type => l_source_object_type,
                    p_get_data           => p_get_data,
                    x_totalnew           => x_totalnew,
                    x_totalmodified      => x_totalmodified,
                    --x_totaldeleted       => x_totaldeleted,
                    --p_new_syncanchor => l_new_syncanchor,
                    x_data               => x_data,
                    x_exclusion_data     => x_exclusion_data
               );

           END IF;

           ----------------------------------
           -- processing all deleted records
           ----------------------------------

	   if  (trim(p_sync_type) <>'SS') then

           cac_sync_task_common.get_all_deleted_tasks(
               p_request_type       => p_request_type,
               p_syncanchor         => l_syncanchor,
               p_recordindex        => nvl(x_data.count,0) + 1,
               p_resource_id        => g_login_resource_id,
               p_principal_id       => p_principal_id,
               p_resource_type      => l_resource_type,
               p_source_object_type => l_source_object_type,
               p_get_data           => p_get_data,
               --p_new_syncanchor     => l_new_syncanchor,
               x_totaldeleted       => x_totaldeleted,
               x_data               => x_data
           );


          end if;

       -- END LOOP;


        FOR k IN 1 .. x_data.COUNT
        LOOP

          i_counter := i_counter + 1 ;

          FOR c_attendee IN c_assignment (x_data(k).task_id)
          LOOP
          x_attendee_data(i_counter).task_id         := x_data(k).task_id;
          x_attendee_data(i_counter).attendee_role   := c_attendee.assignee_role;
          x_attendee_data(i_counter).attendee_status := c_attendee.assignment_status_id;
          x_attendee_data(i_counter).resourceId      := c_attendee.resource_id;
          x_attendee_data(i_counter).resourceType    := c_attendee.resource_type_code;

          if (c_attendee.resource_type_code='RS_EMPLOYEE') then

           open getEmployeeResourceInfo(c_attendee.resource_id);
           fetch getEmployeeResourceInfo into l_getEmployeeResourceInfo;
           if (getEmployeeResourceInfo%FOUND) then

             x_attendee_data(i_counter).first_name:=l_getEmployeeResourceInfo.source_first_name;
             x_attendee_data(i_counter).middle_name:=l_getEmployeeResourceInfo.source_middle_name;
             x_attendee_data(i_counter).last_name:=l_getEmployeeResourceInfo.source_last_name;
             x_attendee_data(i_counter).primary_phone_country_code:=null;
             x_attendee_data(i_counter).primary_phone_area_code:=null;
             x_attendee_data(i_counter).primary_phone_number:=l_getEmployeeResourceInfo.source_phone;
             x_attendee_data(i_counter).primary_phone_extension:=null;
             x_attendee_data(i_counter).email_address:=l_getEmployeeResourceInfo.source_email;
             x_attendee_data(i_counter).job_title:=l_getEmployeeResourceInfo.source_job_title;

           end if;-- if (getEmployeeResourceInfo%FOUND) then

           if (getEmployeeResourceInfo%ISOPEN) then
            close getEmployeeResourceInfo;
           end if;

     else -- for   if (c_attendee.resource_type_code='RS_EMPLOYEE') then

           open getGroupResourceInfo(c_attendee.resource_id);
           fetch getGroupResourceInfo into l_getGroupResourceInfo;
           if (getGroupResourceInfo%FOUND) then

             x_attendee_data(i_counter).first_name:=l_getGroupResourceInfo.person_first_name;
             x_attendee_data(i_counter).middle_name:=l_getGroupResourceInfo.person_middle_name;
             x_attendee_data(i_counter).last_name:=l_getGroupResourceInfo.person_last_name;
             x_attendee_data(i_counter).primary_phone_country_code:=l_getGroupResourceInfo.primary_phone_country_code;
             x_attendee_data(i_counter).primary_phone_area_code:=l_getGroupResourceInfo.primary_phone_area_code;
             x_attendee_data(i_counter).primary_phone_number:=l_getGroupResourceInfo.primary_phone_number;
             x_attendee_data(i_counter).primary_phone_extension:=l_getGroupResourceInfo.primary_phone_extension;
             x_attendee_data(i_counter).email_address:=l_getGroupResourceInfo.email_address;
             x_attendee_data(i_counter).job_title:=l_getGroupResourceInfo.job_title;

           end if;-- if (getGroupResourceInfo%FOUND) then

           if (getGroupResourceInfo%ISOPEN) then
            close getGroupResourceInfo;
           end if;

         end if;-- if (c_attendee.resource_type_code='RS_GROUP') then

          i_counter := i_counter + 1 ;

          END LOOP;


        END LOOP;



--fetching through exclusion table


           FOR k IN 1 .. x_exclusion_data.COUNT
        LOOP

          i_counter := i_counter + 1 ;

          FOR c_attendee IN c_assignment (x_exclusion_data(k).task_id)
          LOOP
          x_attendee_data(i_counter).task_id         := x_exclusion_data(k).task_id;
          x_attendee_data(i_counter).attendee_role   := c_attendee.assignee_role;
          x_attendee_data(i_counter).attendee_status := c_attendee.assignment_status_id;
          x_attendee_data(i_counter).resourceId      := c_attendee.resource_id;
          x_attendee_data(i_counter).resourceType    := c_attendee.resource_type_code;

          if (c_attendee.resource_type_code='RS_EMPLOYEE') then

           open getEmployeeResourceInfo(c_attendee.resource_id);
           fetch getEmployeeResourceInfo into l_getEmployeeResourceInfo;
           if (getEmployeeResourceInfo%FOUND) then

             x_attendee_data(i_counter).first_name:=l_getEmployeeResourceInfo.source_first_name;
             x_attendee_data(i_counter).middle_name:=l_getEmployeeResourceInfo.source_middle_name;
             x_attendee_data(i_counter).last_name:=l_getEmployeeResourceInfo.source_last_name;
             x_attendee_data(i_counter).primary_phone_country_code:=null;
             x_attendee_data(i_counter).primary_phone_area_code:=null;
             x_attendee_data(i_counter).primary_phone_number:=l_getEmployeeResourceInfo.source_phone;
             x_attendee_data(i_counter).primary_phone_extension:=null;
             x_attendee_data(i_counter).email_address:=l_getEmployeeResourceInfo.source_email;
             x_attendee_data(i_counter).job_title:=l_getEmployeeResourceInfo.source_job_title;

           end if;-- if (getEmployeeResourceInfo%FOUND) then

           if (getEmployeeResourceInfo%ISOPEN) then
            close getEmployeeResourceInfo;
           end if;

     else -- for   if (c_attendee.resource_type_code='RS_EMPLOYEE') then

           open getGroupResourceInfo(c_attendee.resource_id);
           fetch getGroupResourceInfo into l_getGroupResourceInfo;
           if (getGroupResourceInfo%FOUND) then

             x_attendee_data(i_counter).first_name:=l_getGroupResourceInfo.person_first_name;
             x_attendee_data(i_counter).middle_name:=l_getGroupResourceInfo.person_middle_name;
             x_attendee_data(i_counter).last_name:=l_getGroupResourceInfo.person_last_name;
             x_attendee_data(i_counter).primary_phone_country_code:=l_getGroupResourceInfo.primary_phone_country_code;
             x_attendee_data(i_counter).primary_phone_area_code:=l_getGroupResourceInfo.primary_phone_area_code;
             x_attendee_data(i_counter).primary_phone_number:=l_getGroupResourceInfo.primary_phone_number;
             x_attendee_data(i_counter).primary_phone_extension:=l_getGroupResourceInfo.primary_phone_extension;
             x_attendee_data(i_counter).email_address:=l_getGroupResourceInfo.email_address;
             x_attendee_data(i_counter).job_title:=l_getGroupResourceInfo.job_title;

           end if;-- if (getGroupResourceInfo%FOUND) then

           if (getGroupResourceInfo%ISOPEN) then
            close getGroupResourceInfo;
           end if;

         end if;-- if (c_attendee.resource_type_code='RS_GROUP') then

          i_counter := i_counter + 1 ;

          END LOOP;


        END LOOP;


     END get_all_data;



     -------------------------------
     -- Public Method
     -------------------------------
     PROCEDURE get_count (
        p_request_type   IN VARCHAR2,
        p_syncanchor     IN DATE,
        p_principal_id   IN NUMBER,
        x_total         OUT NOCOPY NUMBER,
        x_totalnew      OUT NOCOPY NUMBER,
        x_totalmodified OUT NOCOPY NUMBER,
        x_totaldeleted  OUT NOCOPY NUMBER
     )
     IS
        l_syncanchor    DATE;
        l_data          cac_sync_task.task_tbl;
        l_exclusion_data cac_sync_task.exclusion_tbl;
        l_attendee_data  Cac_Sync_Task.attendee_tbl;
     BEGIN
        x_total         := 0;
        x_totalnew      := 0;
        x_totalmodified := 0;
        x_totaldeleted  := 0;

        -- Call the private api to get the data.
        get_all_data (
           p_request_type  => p_request_type,
           p_syncanchor    => p_syncanchor,
           p_principal_id  => p_principal_id,
           p_get_data      => FALSE,
           p_sync_type     => 'IS',  --it will not delete the booking data,only on get list we will delete booking data
           x_totalnew      => x_totalnew,
           x_totalmodified => x_totalmodified,
           x_totaldeleted  => x_totaldeleted,
           x_data          => l_data,
           x_exclusion_data => l_exclusion_data,
           x_attendee_data  => l_attendee_data
        );
        x_total := x_totalnew + x_totalmodified + x_totaldeleted;

     END get_count;

 --only on get_list will booking data be deleted.
 --On get_count the booking data will not be deleted.

     PROCEDURE get_list (
        p_request_type     IN VARCHAR2,
        p_syncanchor       IN DATE,
        p_principal_id     IN NUMBER,
        p_sync_type        IN VARCHAR2, --'SS' for slow sync, 'IS' for Incremental sync
        x_data            OUT NOCOPY cac_sync_task.task_tbl,
        x_exclusion_data  OUT NOCOPY cac_sync_task.exclusion_tbl,
        x_attendee_data     OUT NOCOPY Cac_Sync_Task.attendee_tbl

     )
     IS
        l_totalnew      NUMBER;
        l_totalmodified NUMBER;
        l_totaldeleted  NUMBER;
        l_data          cac_sync_task.task_tbl;
        l_resource_id   NUMBER;
        l_resource_type VARCHAR2(30);
     BEGIN
        get_all_data (
           p_request_type  => p_request_type,
           p_syncanchor    => p_syncanchor,
           p_principal_id  => p_principal_id,
           p_get_data      => TRUE,
           p_sync_type     => p_sync_type,
           x_totalnew      => l_totalnew,
           x_totalmodified => l_totalmodified,
           x_totaldeleted  => l_totaldeleted,
           x_data          => l_data,
           x_exclusion_data => x_exclusion_data,
           x_attendee_data  => x_attendee_data
           );
           x_data := l_data;
     END get_list;

     PROCEDURE create_ids (
        p_num_req IN NUMBER,
        x_results IN OUT NOCOPY cac_sync_task.task_tbl
     )
     IS
     BEGIN
        FOR i IN 1 .. NVL (p_num_req, 0)
        LOOP
           -- Fix Bug# 2387015 to avoid using contacts sequence number
           SELECT jta_sync_task_mapping_s.nextval
             INTO x_results (i).syncid
             FROM DUAL;
           x_results (i).resultid := cac_sync_task_common.g_sync_success;   --success, no message will be displayed to user
        END LOOP;
     END create_ids;

     PROCEDURE update_data (p_tasks      IN OUT NOCOPY cac_sync_task.task_tbl
                           ,p_exclusions IN OUT NOCOPY cac_sync_task.exclusion_tbl)
     IS
         l_resource_id        NUMBER;
         l_resource_type      VARCHAR2(100);
         l_is_this_new_task    BOOLEAN;
         l_old_sync_id            NUMBER;
         l_principal_id       NUMBER;
         l_new_task_id        NUMBER;
     BEGIN
         cac_sync_task_common.get_resource_details (l_resource_id, l_resource_type);

         g_login_resource_id := l_resource_id;


 for  i IN 1 .. NVL (p_tasks.LAST, 0)
         LOOP
 if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'sync id ' ||p_tasks(i).syncId||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'task id ' ||p_tasks(i).task_id||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'objectcode ' ||p_tasks(i).objectCode||' for task name '|| p_tasks(i).objectCode);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'subject ' ||p_tasks(i).subject||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'description ' ||p_tasks(i).description||' for task name '|| p_tasks(i).subject);

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'dateSelected ' ||p_tasks(i).dateSelected||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'plannedStartDate ' ||p_tasks(i).plannedStartDate||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'plannedEndDate ' ||p_tasks(i).plannedEndDate||' for task name '|| p_tasks(i).objectCode);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'scheduledStartDate ' ||p_tasks(i).scheduledStartDate||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'scheduledEndDate ' ||p_tasks(i).scheduledEndDate||' for task name '|| p_tasks(i).subject);

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'actualStartDate ' ||p_tasks(i).actualStartDate||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'actualendDate ' ||p_tasks(i).actualendDate||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'statusId ' ||p_tasks(i).statusId||' for task name '|| p_tasks(i).objectCode);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'priorityId ' ||p_tasks(i).priorityId||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'alarmFlag ' ||p_tasks(i).alarmFlag||' for task name '|| p_tasks(i).subject);

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'alarmDate ' ||p_tasks(i).alarmDate||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'privateFlag ' ||p_tasks(i).privateFlag||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'catgory ' ||p_tasks(i).category||' for task name '|| p_tasks(i).objectCode);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'resource Id ' ||p_tasks(i).resourceId||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'resourc type ' ||p_tasks(i).resourceType||' for task name '|| p_tasks(i).subject);

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'assignemtn id ' ||p_tasks(i).task_assignment_id||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'result id ' ||p_tasks(i).resultId||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'resultSystemMessage ' ||p_tasks(i).resultSystemMessage||' for task name '|| p_tasks(i).objectCode);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'unit_of_measure ' ||p_tasks(i).unit_of_measure||' for task name '|| p_tasks(i).subject);

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'occurs_which ' ||p_tasks(i).occurs_which||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'occurs every ' ||p_tasks(i).occurs_every ||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'date of month ' ||p_tasks(i).date_of_month||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'locations ' ||p_tasks(i).locations||' for task name '|| p_tasks(i).objectCode);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'principal id ' ||p_tasks(i).principal_id||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'free busy type ' ||p_tasks(i).free_busy_type||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'dial in ' ||p_tasks(i).dial_in||' for task name '|| p_tasks(i).subject);

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'sunday ' ||p_tasks(i).sunday ||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'monday ' ||p_tasks(i).monday||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'tuesday ' ||p_tasks(i).tuesday||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'wednesday ' ||p_tasks(i).wednesday||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'thursday ' ||p_tasks(i).thursday||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'friday ' ||p_tasks(i).friday||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_dataa', 'saturday ' ||p_tasks(i).saturday||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'date_of_month ' ||p_tasks(i).date_of_month||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'unit_of_measure ' ||p_tasks(i).unit_of_measure||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'start_date ' ||p_tasks(i).start_date||' for task name '|| p_tasks(i).subject);
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'end_date ' ||p_tasks(i).end_date||' for task name '|| p_tasks(i).subject);


  end if;
end loop;



         FOR i IN 1 .. NVL (p_tasks.LAST, 0)
         LOOP
            l_is_this_new_task := cac_sync_task_common.is_this_new_task(p_tasks(i).syncid);

            IF p_tasks(i).subject IS NOT NULL AND
               ( (    l_is_this_new_task AND p_tasks(i).subject <> FND_API.G_MISS_CHAR) OR
                 (NOT l_is_this_new_task)
               )
            THEN

                IF l_is_this_new_task
                THEN  -- This is a new task
                    cac_sync_task_common.create_new_data( p_task_rec      => p_tasks(i)
                                                        , p_exclusion_tbl => p_exclusions
                                                        , p_resource_id   => l_resource_id
                                                        , p_resource_type => l_resource_type);



                ELSE -- This is an existing task

                if (cac_sync_task_common.is_recur_rule_same(p_task_rec=>p_tasks(i)))  then

 if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'recurrence rule is same so calling update_existing_data');
 end if;

                    cac_sync_task_common.update_existing_data( p_task_rec      => p_tasks(i)
                                                             , p_exclusion_tbl => p_exclusions
                                                             , p_resource_id   => l_resource_id
                                                             , p_resource_type => l_resource_type);

                 else
--case when re-inclusion happens on the client. the server deleted all data and  re-creates them .




                 l_old_sync_id:=p_tasks(i).syncid;
                 l_principal_id:=p_tasks(i).principal_id;


 if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'calling delete_task and then create task inside update_data');
 end if;

                 cac_sync_task_common.delete_task_data (p_task_rec=>p_tasks(i));




                 cac_sync_task_common.create_new_data( p_task_rec      => p_tasks(i)
                                                        , p_exclusion_tbl => p_exclusions
                                                        , p_resource_id   => l_resource_id
                                                        , p_resource_type => l_resource_type);


                --update sync mapping table with old sync_id.
             l_new_task_id := cac_sync_task_common.get_task_id (p_sync_id => p_tasks(i).syncid);

            if (l_new_task_id is not null) then

 if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task.update_data', 'updating sync mapping after deletion and creation of data');
 end if;

              UPDATE jta_sync_task_mapping
               SET task_sync_id      = l_old_sync_id,
                   last_update_date  = sysdate,
                   last_updated_by   = fnd_global.user_id,
                   last_update_login = fnd_global.login_id

                  WHERE    task_id = l_new_task_id
                   and   principal_id = l_principal_id;

             else

                   cac_sync_common.put_messages_to_result (
                    p_tasks(i),
                    p_status => 2,
                    p_user_message => 'JTA_SYNC_NULL_TASKNAME'
                 );


             end if;-- for if (l_new_task_id is not null) then

            end if;--for    if (cac_sync_task_common.is_recur_rule_same(p_task_rec=>p_tasks(i))  then

        END IF;-- for  IF l_is_this_new_task
            ELSE
                 cac_sync_common.put_messages_to_result (
                    p_tasks(i),
                    p_status => 2,
                    p_user_message => 'JTA_SYNC_NULL_TASKNAME'
                 );
            END IF;

            p_tasks(i).recordIndex  := i ;
         END LOOP; -- for loop of p_tasks


    END update_data;

     PROCEDURE delete_data (
        p_tasks        IN OUT NOCOPY cac_sync_task.task_tbl
     )
     IS
        l_task_id NUMBER;
        l_delete_flag VARCHAR2(1);
        l_resource_id NUMBER;
        l_resource_type VARCHAR2(30);
        l_status_id NUMBER;
        l_sync_id      NUMBER;
        l_source_object_type_code VARCHAR2(60);
     BEGIN
        cac_sync_task_common.get_resource_details (l_resource_id, l_resource_type);
        g_login_resource_id := l_resource_id;



        commit;


        FOR i IN 1 .. NVL (p_tasks.LAST, 0)
        LOOP
            IF cac_sync_task_common.validate_syncid(p_syncid => p_tasks(i).syncid) -- Fix Bug 2382927
            THEN
               fnd_msg_pub.initialize;

               l_sync_id := p_tasks (i).syncid;
               l_task_id := cac_sync_task_common.get_task_id (p_sync_id => l_sync_id);
               l_source_object_type_code := cac_sync_task_common.get_source_object_type(p_task_id => l_task_id);



               cac_sync_task_common.check_delete_data(
                      p_task_id     => l_task_id,
                      p_resource_id => l_resource_id,
                      p_objectcode  => l_source_object_type_code,
                      x_status_id   => l_status_id,
                      x_delete_flag => l_delete_flag);

               IF l_delete_flag = 'D'
               THEN


                   cac_sync_task_common.delete_task_data(p_task_rec => p_tasks(i));

               ELSIF l_delete_flag = 'U'

               THEN

                   cac_sync_task_common.reject_task_data(p_task_rec => p_tasks(i));

               ELSE -- l_delete_flag = 'X'


                   p_tasks (i).syncanchor := cac_sync_task_common.convert_server_to_gmt (SYSDATE);
                   cac_sync_common.put_messages_to_result (p_tasks (i),
                                                           p_status => cac_sync_task_common.g_sync_success,
                                                           p_user_message => 'JTA_SYNC_SUCCESS');

               END IF; -- l_delete_flag
            --------------------------------------------------------------
            -- Fix Bug 2382927 :
            -- When Intellisync sends a sync id which has not been synced,
            --   the record is ignored and returned as success.
            --------------------------------------------------------------
            ELSE -- Cannot found sync id in mapping table

                p_tasks (i).syncanchor := cac_sync_task_common.convert_server_to_gmt (SYSDATE); -- Newly added on 04-Jun-2002 to fix bug 2382927
                cac_sync_common.put_messages_to_result (
                   p_tasks(i),
                   p_status => cac_sync_task_common.g_sync_success,
                   p_user_message => 'JTA_SYNC_SUCCESS'
                );
            END IF; -- cac_sync_task_common.validate_syncid(p_syncid => p_tasks(i).syncid)
        END LOOP; -- FOR i IN 1 .. NVL (p_tasks.LAST, 0)
        commit;

   END delete_data;



END Cac_Sync_Task;

/
