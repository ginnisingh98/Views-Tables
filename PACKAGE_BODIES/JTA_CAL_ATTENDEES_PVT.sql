--------------------------------------------------------
--  DDL for Package Body JTA_CAL_ATTENDEES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_CAL_ATTENDEES_PVT" AS
/* $Header: jtavcatb.pls 120.2 2005/10/05 09:29:45 cijang ship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavcatb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is for Calendar Assignment.                          |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 12-Apr-2002   arpatel          Created.                               |
 | 23-May-2001   rdespoto         default sendEmail preference to YES    |
 | 09-DEC-2003   cjang            Added p_free_busy_type on create/update|
 +======================================================================*/

   PROCEDURE create_cal_assignment (
      p_task_id                      IN       NUMBER,
      p_resources                    IN       Resource_tbl,
      p_add_option                   IN       VARCHAR2,
      p_invitor_res_id               IN       NUMBER,
      x_return_status                OUT   NOCOPY   VARCHAR2,
      x_task_assignment_ids          OUT   NOCOPY   Task_Assign_tbl
   ) IS
     l_return_status       VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(1000);
     l_issue_invitation    VARCHAR2(30);
     l_Preferences         JTF_CAL_PVT.Preference;
     l_WeekTimePrefTbl     JTF_CAL_PVT.WeekTimePrefTblType;
   BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     fnd_msg_pub.initialize;

     for i in p_resources.first .. p_resources.last
     loop
         --Rada, add this initialize to avoid NOCOPY no data found issue
          x_task_assignment_ids(i).task_assignment_id := NULL;
          --call to task assignments api
          JTF_TASK_ASSIGNMENTS_PVT.create_task_assignment (
          p_api_version                  =>       1.0,
          p_init_msg_list                =>       'F', --needed??
          p_task_id                      =>       p_task_id,
          p_resource_type_code           =>       p_resources(i).resource_type,
          p_resource_id                  =>       p_resources(i).resource_id,
          p_assignment_status_id         =>       18,
          p_assignee_role                =>       'ASSIGNEE',
          p_show_on_calendar             =>       'Y',
          p_enable_workflow              =>       'N',
          p_abort_workflow               =>       'N',
          p_add_option                   =>       p_add_option,
          p_free_busy_type               =>       'TENTATIVE',
          x_return_status                =>       l_return_status,
          x_msg_count                    =>       l_msg_count,
          x_msg_data                     =>       l_msg_data,
          x_task_assignment_id           =>       x_task_assignment_ids(i).task_assignment_id
          ) ;

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
             x_return_status := l_return_status;
             fnd_message.set_name ('JTA', 'JTA_CAL_CREATE_TASK_ASSIGN_ERROR');
             fnd_message.set_token ('Task Assignment failed for:',
                                     JTF_CAL_UTILITY_PVT.GetResourceName(p_resources(i).resource_id, p_resources(i).resource_type));
             fnd_msg_pub.add;
          END IF;

      end loop;

          JTF_CAL_UTILITY_PVT.GetPreferences
            ( p_ResourceID          =>     p_invitor_res_id
            , p_ResourceType        =>     'RS_EMPLOYEE'
            , x_Preferences         =>     l_Preferences
            , x_WeekTimePrefTbl     =>     l_WeekTimePrefTbl
            );

       --call workflow with task_id
          IF NVL(l_Preferences.SendEmail, 'YES') = 'YES' THEN
            JTF_CAL_WF_PVT.StartInvite
              ( p_api_version   =>     1.0
              , p_commit        =>     'F'  --FALSE?
              , x_return_status =>     l_return_status
              , x_msg_count     =>     l_msg_count
              , x_msg_data      =>     l_msg_data
              , p_INVITOR       =>     p_invitor_res_id  -- Resource ID of Invitor
              , p_TaskID        =>     p_task_id   -- Task ID of the appointment
              );

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                 x_return_status := l_return_status;
                 fnd_message.set_name ('JTA', 'JTA_CAL_START_INVITE_ERROR');
                 fnd_message.set_token ('Workflow startInvite failed for :',
                                        JTF_CAL_UTILITY_PVT.GetResourceName(p_invitor_res_id, 'RS_EMPLOYEE'));
                 fnd_msg_pub.add;
              END IF;

          END IF;

   END;

    PROCEDURE  delete_cal_assignment
    (p_object_version_number        IN       NUMBER,
     p_task_assignments             IN       Task_Assign_tbl,
     p_delete_option                IN       VARCHAR2,
     p_no_of_attendies              IN       NUMBER,
     x_return_status                OUT    NOCOPY  VARCHAR2
     )
      IS
      l_return_status       VARCHAR2(1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(1000);
     BEGIN
         x_return_status := fnd_api.g_ret_sts_success;
         fnd_msg_pub.initialize;
         for i in p_task_assignments.first .. p_task_assignments.last
         loop

           IF p_task_assignments(i).task_assignment_id IS NOT NULL THEN
             JTF_TASK_ASSIGNMENTS_PVT.Delete_Task_Assignment
            ( p_api_version                 =>       1.0,
              p_object_version_number       =>       p_object_version_number,
              p_task_assignment_id          =>       p_task_assignments(i).task_assignment_id,
              p_enable_workflow             =>       'N',
              p_abort_workflow              =>       'N',
              p_delete_option               =>       p_delete_option,
              x_return_status               =>       l_return_status,
              x_msg_count                   =>       l_msg_count,
              x_msg_data                    =>       l_msg_data );
            END IF;

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                 x_return_status := l_return_status;
                 fnd_message.set_name ('JTA', 'JTA_CAL_DELETE_TASK_ASSIGN_ERROR');
                 fnd_message.set_token ('Delete Task Assignment failed for task_assignment_id:',
                                         p_task_assignments(i).task_assignment_id);
                 fnd_msg_pub.add;
              END IF;

         end loop;
     END;

   PROCEDURE update_cal_assignment (
      p_object_version_number        IN  OUT NOCOPY  NUMBER,
      p_task_assignment_id           IN       NUMBER,
      p_resource_id                  IN       NUMBER,
      p_resource_type                IN       VARCHAR2,
      p_assignment_status_id         IN       NUMBER,
      x_return_status                OUT  NOCOPY    VARCHAR2
   ) IS
     l_return_status         VARCHAR2(1);
     l_msg_count             NUMBER;
     l_msg_data              VARCHAR2(1000);
     l_free_busy_type        VARCHAR2(4);
   BEGIN
         x_return_status := fnd_api.g_ret_sts_success;
         fnd_msg_pub.initialize;

         IF p_assignment_status_id = 3 THEN
            -- If accepted
         	l_free_busy_type := 'BUSY';
         ELSIF p_assignment_status_id = 4 THEN
            -- If rejected
         	l_free_busy_type := 'FREE';
         END IF;

         JTF_TASK_ASSIGNMENTS_PVT.update_task_assignment (
            p_api_version                  =>       1.0,
            p_object_version_number        =>       p_object_version_number,
            p_init_msg_list                =>       'T', --?
            p_task_assignment_id           =>       p_task_assignment_id,
            p_resource_type_code           =>       p_resource_type,
            p_resource_id                  =>       p_resource_id,
            p_schedule_flag                =>       fnd_api.g_miss_char, --Y Or N??
            p_actual_start_date            =>       null, --?
            p_actual_end_date              =>       null, --?
            p_assignment_status_id         =>       p_assignment_status_id,
            p_show_on_calendar             =>       'Y',
            p_enable_workflow              =>       'N',
            p_abort_workflow               =>       'N',
            p_free_busy_type               =>       l_free_busy_type,
            x_return_status                =>       l_return_status,
            x_msg_count                    =>       l_msg_count,
            x_msg_data                     =>       l_msg_data
         ) ;

         IF l_return_status = fnd_api.g_ret_sts_success THEN
            jtf_cal_wf_pvt.processinvitation(p_api_version => 1.0
            ,p_init_msg_list => 'T'
            ,p_commit        => 'F'
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_task_assignment_id => p_task_assignment_id
            ,p_resource_type     => p_resource_type
            ,p_resource_id => p_resource_id
            ,p_assignment_status_id => p_assignment_status_id);
         END IF;
         x_return_status := l_return_status;
   END;

End  ;

/
