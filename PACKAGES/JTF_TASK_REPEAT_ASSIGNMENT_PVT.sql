--------------------------------------------------------
--  DDL for Package JTF_TASK_REPEAT_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_REPEAT_ASSIGNMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkcs.pls 120.1.12000000.2 2007/07/19 08:35:45 lokumar ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|   jtftkcs.pls                                                         |
|                                                                       |
| DESCRIPTION                                                           |
|   This package is used to process the repsone of assignee's response  |
|    in repeating appointment.                                          |
|   The assignee can accept or reject either a specific appointment or  |
|        all the appointments among repeating appointments.             |
|                                                                       |
| NOTES                                                                 |
|   Action     assignment_status_id                                     |
|   ========== ======================                                   |
|   REJECT ALL          4                                               |
|   ACCEPT ALL          3                                               |
|                                                                       |
|   The possible value for add_option:                                  |
|       T: Add a new invitee to all the future appointments             |
|       A: Add a new invitee to all appointments                        |
|       F: Add a new invitee to the current selected appointment only   |
|       N: Skip the new functionality                                   |
|                                                                       |
|   The possible value for delete_option:                               |
|       T: Delete a new invitee from all the future appointments        |
|       A: Delete a new invitee from all appointments                   |
|       F: Delete a new invitee from the current selected appointment   |
|       N: Skip the new functionality                                   |
|                                                                       |
| Date          Developer    Change                                     |
|------         -----------  ---------------------------------------    |
| 28-Mar-2002   cjang        Created                                    |
| 29-Mar-2002   cjang        Added response_invitation_rec              |
|                                  add_assignee_rec                     |
|                                  delete_assignee_rec                  |
|                                  add_assignee_rec                     |
|                                  add_assignee_rec                     |
|                                  add_assignee                         |
|                                  delete_assignee                      |
|                            Modified response_invitation               |
| 10-Apr-2002   cjang        A user is NOT allowed to accept one of     |
|                              occurrences.                             |
|                            He/She can either accept all or reject all.|
|                            The "update_all" and "calendar_start_date" |
|                              in response_invitation_rec is removed.   |
*=======================================================================*/

    TYPE response_invitation_rec IS RECORD
    (
        task_assignment_id     NUMBER,
        assignment_status_id   NUMBER,
        task_id                NUMBER,
        recurrence_rule_id     NUMBER,
        enable_workflow        VARCHAR2(1),
        abort_workflow         VARCHAR2(1)
    );

    TYPE add_assignee_rec IS RECORD
    (
        recurrence_rule_id    NUMBER,
        task_id               NUMBER,
        calendar_start_date   DATE,
        resource_type_code    jtf_task_all_assignments.resource_type_code%TYPE,
	free_busy_type        jtf_task_all_assignments.free_busy_type%TYPE,
        resource_id           NUMBER,
        assignment_status_id  NUMBER,
        add_option            VARCHAR2(1),
        enable_workflow       VARCHAR2(1),
        abort_workflow        VARCHAR2(1)
    );

    TYPE delete_assignee_rec IS RECORD
    (
        recurrence_rule_id    NUMBER,
        task_id               NUMBER,
        calendar_start_date   DATE,
        resource_id           NUMBER,
        delete_option         VARCHAR2(1),
        enable_workflow       VARCHAR2(1),
        abort_workflow        VARCHAR2(1)
    );

    PROCEDURE response_invitation(
        p_api_version             IN     NUMBER,
        p_init_msg_list           IN     VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN     VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN OUT NOCOPY NUMBER,
        p_response_invitation_rec IN     response_invitation_rec,
        x_return_status           OUT NOCOPY    VARCHAR2,
        x_msg_count               OUT NOCOPY    NUMBER,
        x_msg_data                OUT NOCOPY    VARCHAR2
    );

    PROCEDURE add_assignee(
        p_api_version         IN  NUMBER,
        p_init_msg_list       IN  VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit              IN  VARCHAR2 DEFAULT fnd_api.g_false,
        p_add_assignee_rec    IN  add_assignee_rec,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
        x_task_assignment_id  OUT NOCOPY NUMBER
    );

    PROCEDURE delete_assignee(
        p_api_version         IN  NUMBER,
        p_init_msg_list       IN  VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit              IN  VARCHAR2 DEFAULT fnd_api.g_false,
        p_delete_assignee_rec IN  delete_assignee_rec,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2
    );
END jtf_task_repeat_assignment_pvt;

 

/
