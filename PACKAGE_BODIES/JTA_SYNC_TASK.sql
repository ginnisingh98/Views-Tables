--------------------------------------------------------
--  DDL for Package Body JTA_SYNC_TASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_SYNC_TASK" AS
/* $Header: jtavstsb.pls 115.75 2002/12/12 19:08:05 cjang ship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavstsb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is for Task Business Logic.                          |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 20-Jan-2002   mmarovic/arpatel Created.                               |
 | 21-Jan-2002   rdespoto         modified.                              |
 | 25-Jan-2002   arpatel          cleaned up for jtadev5 compilation     |
 | 28-Jan-2002   arpatel/chanik   Added get_list_appt(),                 |
 |                                      get_list_task(),                 |
 |                                      get_count_appt(),                |
 |                                      get_count_task()                 |
 | 29-Jan-2002   arpatel/chanik   Added a cursor to find date_selected   |
 | 30-Jan-2002   arpatel/chanik   Added p_event in get_list_xxxx()       |
 | 01-Feb-2002   arpatel/chanik   Removed object_type_code clause from   |
 |                                 get_list_appt cursor                  |
 | 04-Feb-2002   akaran/sachoudh  Added function get_event_type()        |
 | 05-Feb-2002   arpatel          Added nvl for flags                    |
 | 12-Feb-2002   cjang            Added group calendar functionality     |
 | 20-Feb-2002   cjang            The followings are not synced          |
 |                                1) Change from Task to Appt            |
 |                                2) Change from Appt to Task            |
 |                                Removed event_type and object          |
 |                                           from cursor c_task          |
 | 22-Feb-2002   cjang            Refactoring                            |
 | 27-Feb-2002   cjang            Added a function to check the update   |
 |                                          privilege                    |
 | 27-Feb-2002   arpatel          Changed update_data to handle updates  |
 |                                of descriptions for repeating apmts    |
 | 27-Feb-2002   cjang            Added separate loop for repeating task |
 | 28-Feb-2002   cjang            Integrate with invitee function        |
 | 01-Mar-2002   cjang            Refactoring and Bug Fix                |
 | 06-Mar-2002   cjang            Modularize UPDATE_DATA()               |
 |                                           GET_ALL_DATA()              |
 | 11-Mar-2002   cjang            Modified delete_data                   |
 | 11-Mar-2002   sanjeev          Changed methods for exclusions         |
 | 24-Apr-2002   cjang      When jta_sync_task_common.get_all_nonrepeat_tasks
 |                           is called, pass p_record_index with NVL(x_data.count,0)
 | 26-Apr-2002   cjang            Commented out debug statements         |
 | 30-Apr-2002   cjang            Added if condition to check if subject |
 |                                    is null.                           |
 |                                   We're not accepting NULL task name  |
 | 23-May-2002   cjang            Modified delete_data()                 |
 |                                    to fix bug 2382927                 |
 | 28-May-2002   cjang            Modified create_ids()                  |
 |                                Fix Bug# 2387015                       |
 |                                to avoid using contacts sequence number|
 | 04-Jun-2002   cjang            Modified delete_data()                 |
 |                                    to fix bug 2382927                 |
 |                                For the invalid syncid, new sync anchor|
 |                                must be assigned                       |
 +======================================================================*/

     -------------------------------
     -- Private Method
     -------------------------------
     PROCEDURE get_all_data (
        p_request_type   IN VARCHAR2,
        p_syncanchor     IN DATE,
        p_get_data       IN BOOLEAN,
        x_totalnew      OUT NOCOPY NUMBER,
        x_totalmodified OUT NOCOPY NUMBER,
        x_totaldeleted  OUT NOCOPY NUMBER,
        x_data          OUT NOCOPY jta_sync_task.task_tbl,
        x_exclusion_data  OUT NOCOPY Jta_Sync_Task.exclusion_tbl
     )
     IS
        -- Added a group calendar feature
        -- Used to store the list of group resource ids for the current resource
        l_resources  jta_sync_task_common.resource_list_tbl;
        i            NUMBER := 0;
        l_operation  VARCHAR2(240);
        l_syncanchor DATE ;
        l_source_object_type VARCHAR2(60) := RTRIM(p_request_type,'S');
        l_task_rec jta_sync_task.task_rec;
        l_resource_id   NUMBER;
        l_resource_type VARCHAR2(30);
        l_new_syncanchor  date ;

     BEGIN
        x_totalnew := 0;
        x_totalmodified := 0;
        x_totaldeleted := 0;

        jta_sync_task_common.get_resource_details (g_login_resource_id, l_resource_type);

        l_syncanchor := jta_sync_task_common.convert_gmt_to_server (p_syncanchor);
        --JTA_SYNC_DEBUG_PKG.DEBUG('l_syncanchor = '||to_char(l_syncanchor,'DD-MON-YYYY HH24:MI:SS'));

        -----------------------------------------------------
        -- Get group ids including current resource id
        -----------------------------------------------------
        jta_sync_task_common.get_group_resource (
           p_request_type  => p_request_type,
           p_resource_id   => g_login_resource_id,
           p_resource_type => l_resource_type,
           x_resources     => l_resources
        );

        -----------------------------------------------------
        -- Loop with current resource id and group ids
        -----------------------------------------------------
        --l_new_syncanchor := sysdate;

        FOR j IN l_resources.FIRST .. l_resources.LAST
        LOOP
           -------------------------------------------------
           -- Process non repeat tasks
           -------------------------------------------------
           jta_sync_task_common.get_all_nonrepeat_tasks(
                 p_request_type       => p_request_type,
                 p_syncanchor         => l_syncanchor,
                 p_recordindex        => NVL(x_data.count,0),
                 p_resource_id        => l_resources(j).resource_id,
                 p_resource_type      => l_resources(j).resource_type,
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
              jta_sync_task_common.get_all_repeat_tasks(
                    p_request_type       => p_request_type,
                    p_syncanchor         => l_syncanchor,
                    p_recordindex        => nvl(x_data.count,0) + 1,
                    p_resource_id        => l_resources(j).resource_id,
                    p_resource_type      => l_resources(j).resource_type,
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
           jta_sync_task_common.get_all_deleted_tasks(
               p_request_type       => p_request_type,
               p_syncanchor         => l_syncanchor,
               p_recordindex        => nvl(x_data.count,0) + 1,
               p_resource_id        => l_resources(j).resource_id,
               p_resource_type      => l_resources(j).resource_type,
               p_source_object_type => l_source_object_type,
               p_get_data           => p_get_data,
               --p_new_syncanchor     => l_new_syncanchor,
               x_totaldeleted       => x_totaldeleted,
               x_data               => x_data
           );
        END LOOP;

     END get_all_data;

     -------------------------------
     -- Public Method
     -------------------------------
     PROCEDURE get_count (
        p_request_type   IN VARCHAR2,
        p_syncanchor     IN DATE,
        x_total         OUT NOCOPY NUMBER,
        x_totalnew      OUT NOCOPY NUMBER,
        x_totalmodified OUT NOCOPY NUMBER,
        x_totaldeleted  OUT NOCOPY NUMBER
     )
     IS
        l_syncanchor    DATE;
        l_data          jta_sync_task.task_tbl;
        l_exclusion_data jta_sync_task.exclusion_tbl;
     BEGIN
        x_total         := 0;
        x_totalnew      := 0;
        x_totalmodified := 0;
        x_totaldeleted  := 0;

        -- Call the private api to get the data.
        get_all_data (
           p_request_type  => p_request_type,
           p_syncanchor    => p_syncanchor,
           p_get_data      => FALSE,
           x_totalnew      => x_totalnew,
           x_totalmodified => x_totalmodified,
           x_totaldeleted  => x_totaldeleted,
           x_data          => l_data,
           x_exclusion_data => l_exclusion_data
        );
        x_total := x_totalnew + x_totalmodified + x_totaldeleted;

     END get_count;

     PROCEDURE get_list (
        p_request_type     IN VARCHAR2,
        p_syncanchor       IN DATE,
        x_data            OUT NOCOPY jta_sync_task.task_tbl,
        x_exclusion_data  OUT NOCOPY Jta_Sync_Task.exclusion_tbl
     )
     IS
        l_totalnew      NUMBER;
        l_totalmodified NUMBER;
        l_totaldeleted  NUMBER;
        l_data          jta_sync_task.task_tbl;
        l_resource_id   NUMBER;
        l_resource_type VARCHAR2(30);
     BEGIN
        get_all_data (
           p_request_type  => p_request_type,
           p_syncanchor    => p_syncanchor,
           p_get_data      => TRUE,
           x_totalnew      => l_totalnew,
           x_totalmodified => l_totalmodified,
           x_totaldeleted  => l_totaldeleted,
           x_data          => l_data,
           x_exclusion_data => x_exclusion_data
           );
           x_data := l_data;
     END get_list;

     PROCEDURE create_ids (
        p_num_req IN NUMBER,
        x_results IN OUT NOCOPY jta_sync_task.task_tbl
     )
     IS
     BEGIN
        FOR i IN 1 .. NVL (p_num_req, 0)
        LOOP
           -- Fix Bug# 2387015 to avoid using contacts sequence number
           SELECT jta_sync_task_mapping_s.nextval
             INTO x_results (i).syncid
             FROM DUAL;
           x_results (i).resultid := jta_sync_task_common.g_sync_success;   --success, no message will be displayed to user
        END LOOP;
     END create_ids;

     PROCEDURE update_data (p_tasks      IN OUT NOCOPY jta_sync_task.task_tbl
                           ,p_exclusions IN     jta_sync_task.exclusion_tbl)
     IS
         l_resource_id        NUMBER;
         l_resource_type      VARCHAR2(100);
         l_is_this_new_task    BOOLEAN;
     BEGIN
         jta_sync_task_common.get_resource_details (l_resource_id, l_resource_type);

         g_login_resource_id := l_resource_id;

         FOR i IN 1 .. NVL (p_tasks.LAST, 0)
         LOOP
            l_is_this_new_task := jta_sync_task_common.is_this_new_task(p_tasks(i).syncid);

            IF p_tasks(i).subject IS NOT NULL AND
               ( (    l_is_this_new_task AND p_tasks(i).subject <> FND_API.G_MISS_CHAR) OR
                 (NOT l_is_this_new_task)
               )
            THEN
                IF p_tasks(i).category <> FND_API.G_MISS_CHAR OR
                   p_tasks(i).category IS NOT NULL
                THEN
                   jta_sync_task_category.create_category(p_category_name  => p_tasks(i).category,
                                                          p_resource_id    => l_resource_id );
                END IF;

                IF l_is_this_new_task
                THEN  -- This is a new task
                    jta_sync_task_common.create_new_data( p_task_rec      => p_tasks(i)
                                                        , p_exclusion_tbl => p_exclusions
                                                        , p_resource_id   => l_resource_id
                                                        , p_resource_type => l_resource_type);
                ELSE -- This is an existing task
                    jta_sync_task_common.update_existing_data( p_task_rec      => p_tasks(i)
                                                             , p_exclusion_tbl => p_exclusions
                                                             , p_resource_id   => l_resource_id
                                                             , p_resource_type => l_resource_type);
                END IF;
            ELSE
                 jta_sync_common.put_messages_to_result (
                    p_tasks(i),
                    p_status => 2,
                    p_user_message => 'JTA_SYNC_NULL_TASKNAME'
                 );
            END IF;

            p_tasks(i).recordIndex  := i ;
         END LOOP; -- for loop of p_tasks
     END update_data;

     PROCEDURE delete_data (
        p_tasks        IN OUT NOCOPY jta_sync_task.task_tbl
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
        jta_sync_task_common.get_resource_details (l_resource_id, l_resource_type);
        g_login_resource_id := l_resource_id;

        FOR i IN 1 .. NVL (p_tasks.LAST, 0)
        LOOP
            IF jta_sync_task_common.validate_syncid(p_syncid => p_tasks(i).syncid) -- Fix Bug 2382927
            THEN
               fnd_msg_pub.initialize;

               l_sync_id := p_tasks (i).syncid;
               l_task_id := jta_sync_task_common.get_task_id (p_sync_id => l_sync_id);
               l_source_object_type_code := jta_sync_task_common.get_source_object_type(p_task_id => l_task_id);

               jta_sync_task_common.check_delete_data(
                      p_task_id     => l_task_id,
                      p_resource_id => l_resource_id,
                      p_objectcode  => l_source_object_type_code,
                      x_status_id   => l_status_id,
                      x_delete_flag => l_delete_flag);

               IF l_delete_flag = 'D'
               THEN

                   jta_sync_task_common.delete_task_data(p_task_rec => p_tasks(i));

               ELSIF l_delete_flag = 'U'

               THEN
                   jta_sync_task_common.reject_task_data(p_task_rec => p_tasks(i));

               ELSE -- l_delete_flag = 'X'

                   p_tasks (i).syncanchor := jta_sync_task_common.convert_server_to_gmt (SYSDATE);
                   jta_sync_common.put_messages_to_result (p_tasks (i),
                                                           p_status => jta_sync_task_common.g_sync_success,
                                                           p_user_message => 'JTA_SYNC_SUCCESS');

               END IF; -- l_delete_flag
            --------------------------------------------------------------
            -- Fix Bug 2382927 :
            -- When Intellisync sends a sync id which has not been synced,
            --   the record is ignored and returned as success.
            --------------------------------------------------------------
            ELSE -- Cannot found sync id in mapping table
                p_tasks (i).syncanchor := jta_sync_task_common.convert_server_to_gmt (SYSDATE); -- Newly added on 04-Jun-2002 to fix bug 2382927
                jta_sync_common.put_messages_to_result (
                   p_tasks(i),
                   p_status => jta_sync_task_common.g_sync_success,
                   p_user_message => 'JTA_SYNC_SUCCESS'
                );
            END IF; -- jta_sync_task_common.validate_syncid(p_syncid => p_tasks(i).syncid)
        END LOOP; -- FOR i IN 1 .. NVL (p_tasks.LAST, 0)

   END delete_data;

END jta_sync_task;

/
