--------------------------------------------------------
--  DDL for Package JTF_TASK_REPEAT_APPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_REPEAT_APPT_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkos.pls 120.2 2005/08/04 13:32:16 sbarat ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|   jtfvtkos.pls                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|   This is used to process the change of repeating appointments        |
| NOTES                                                                 |
|                                                                       |
| Date          Developer        Change                                 |
|------         ---------------  ---------------------------------------|
| 26-Mar-2002   cjang            Created                                |
| 28-Mar-2002   cjang            Modified the code for p_change_mode    |
|                                Added is_this_first_task(),            |
|                                      get_new_first_taskid(),          |
|                                      exist_syncid()                   |
| 01-Apr-2002   cjang            Moved is_this_first_task(),            |
|                                      get_new_first_taskid(),          |
|                                      exist_syncid()                   |
|                                  to jtf_task_utl                      |
|                                Changed G_ONE from 'O' to 'F'          |
| 03-Aug-2005   Swapan Barat     Added location_id field in             |
|                                updated_field_rec for Enh# 3691788     |
*=======================================================================*/
    G_FUTURE CONSTANT VARCHAR2(1) := 'T';
    G_ALL    CONSTANT VARCHAR2(1) := 'A';
    G_ONE    CONSTANT VARCHAR2(1) := 'F';
    G_SKIP   CONSTANT VARCHAR2(1) := 'N';

    TYPE updated_field_rec IS RECORD
    (
        task_id                 NUMBER   DEFAULT fnd_api.g_miss_num,
        task_name               jtf_tasks_tl.task_name%TYPE DEFAULT fnd_api.g_miss_char,
        task_type_id            NUMBER   DEFAULT fnd_api.g_miss_num,
        description             jtf_tasks_tl.description%TYPE DEFAULT fnd_api.g_miss_char,
        task_status_id          NUMBER   DEFAULT fnd_api.g_miss_num,
        task_priority_id        NUMBER   DEFAULT fnd_api.g_miss_num,
        owner_type_code         jtf_tasks_b.owner_type_code%TYPE DEFAULT fnd_api.g_miss_char,
        owner_id                NUMBER   DEFAULT fnd_api.g_miss_num,
        owner_territory_id      NUMBER   DEFAULT fnd_api.g_miss_num,
        assigned_by_id          NUMBER   DEFAULT fnd_api.g_miss_num,
        customer_id             NUMBER   DEFAULT fnd_api.g_miss_num,
        cust_account_id         NUMBER   DEFAULT fnd_api.g_miss_num,
        address_id              NUMBER   DEFAULT fnd_api.g_miss_num,   ---- hz_party_sites
        planned_start_date      DATE     DEFAULT fnd_api.g_miss_date,
        planned_end_date        DATE     DEFAULT fnd_api.g_miss_date,
        scheduled_start_date    DATE     DEFAULT fnd_api.g_miss_date,
        scheduled_end_date      DATE     DEFAULT fnd_api.g_miss_date,
        actual_start_date       DATE     DEFAULT fnd_api.g_miss_date,
        actual_end_date         DATE     DEFAULT fnd_api.g_miss_date,
        timezone_id             NUMBER   DEFAULT fnd_api.g_miss_num,
        source_object_type_code jtf_tasks_b.source_object_type_code%TYPE DEFAULT fnd_api.g_miss_char,
        source_object_id        NUMBER   DEFAULT fnd_api.g_miss_num,
        source_object_name      jtf_tasks_b.source_object_name%TYPE DEFAULT fnd_api.g_miss_char,
        duration                NUMBER   DEFAULT fnd_api.g_miss_num,
        duration_uom            jtf_tasks_b.duration_uom%TYPE DEFAULT fnd_api.g_miss_char,
        planned_effort          NUMBER   DEFAULT fnd_api.g_miss_num,
        planned_effort_uom      jtf_tasks_b.planned_effort_uom%TYPE DEFAULT fnd_api.g_miss_char,
        actual_effort           NUMBER   DEFAULT fnd_api.g_miss_num,
        actual_effort_uom       jtf_tasks_b.actual_effort_uom%TYPE DEFAULT fnd_api.g_miss_char,
        percentage_complete     NUMBER   DEFAULT fnd_api.g_miss_num,
        reason_code             jtf_tasks_b.reason_code%TYPE DEFAULT fnd_api.g_miss_char,
        private_flag            jtf_tasks_b.private_flag%TYPE DEFAULT fnd_api.g_miss_char,
        publish_flag            jtf_tasks_b.publish_flag%TYPE DEFAULT fnd_api.g_miss_char,
        restrict_closure_flag   jtf_tasks_b.restrict_closure_flag%TYPE DEFAULT fnd_api.g_miss_char,
        multi_booked_flag       jtf_tasks_b.multi_booked_flag%TYPE DEFAULT fnd_api.g_miss_char,
        milestone_flag          jtf_tasks_b.milestone_flag%TYPE DEFAULT fnd_api.g_miss_char,
        holiday_flag            jtf_tasks_b.holiday_flag%TYPE DEFAULT fnd_api.g_miss_char,
        billable_flag           jtf_tasks_b.billable_flag%TYPE DEFAULT fnd_api.g_miss_char,
        bound_mode_code         jtf_tasks_b.bound_mode_code%TYPE DEFAULT fnd_api.g_miss_char,
        soft_bound_flag         jtf_tasks_b.soft_bound_flag%TYPE DEFAULT fnd_api.g_miss_char,
        workflow_process_id     NUMBER   DEFAULT fnd_api.g_miss_num,
        notification_flag       jtf_tasks_b.notification_flag%TYPE DEFAULT fnd_api.g_miss_char,
        notification_period     jtf_tasks_b.notification_period%TYPE   DEFAULT fnd_api.g_miss_num,
        notification_period_uom jtf_tasks_b.notification_period_uom%TYPE DEFAULT fnd_api.g_miss_char,
        parent_task_id          NUMBER   DEFAULT fnd_api.g_miss_num,
        alarm_start             NUMBER   DEFAULT fnd_api.g_miss_num,
        alarm_start_uom         jtf_tasks_b.alarm_start_uom%TYPE DEFAULT fnd_api.g_miss_char,
        alarm_on                jtf_tasks_b.alarm_on%TYPE        DEFAULT fnd_api.g_miss_char,
        alarm_count             NUMBER   DEFAULT fnd_api.g_miss_num,
        alarm_fired_count       NUMBER   DEFAULT fnd_api.g_miss_num,
        alarm_interval          NUMBER   DEFAULT fnd_api.g_miss_num,
        alarm_interval_uom      jtf_tasks_b.alarm_interval_uom%TYPE DEFAULT fnd_api.g_miss_char,
        palm_flag               jtf_tasks_b.palm_flag%TYPE          DEFAULT fnd_api.g_miss_char,
        wince_flag              jtf_tasks_b.wince_flag%TYPE         DEFAULT fnd_api.g_miss_char,
        laptop_flag             jtf_tasks_b.laptop_flag%TYPE        DEFAULT fnd_api.g_miss_char,
        device1_flag            jtf_tasks_b.device1_flag%TYPE       DEFAULT fnd_api.g_miss_char,
        device2_flag            jtf_tasks_b.device2_flag%TYPE       DEFAULT fnd_api.g_miss_char,
        device3_flag            jtf_tasks_b.device3_flag%TYPE       DEFAULT fnd_api.g_miss_char,
        costs                   NUMBER   DEFAULT fnd_api.g_miss_num,
        currency_code           jtf_tasks_b.currency_code%TYPE DEFAULT fnd_api.g_miss_char,
        escalation_level        jtf_tasks_b.escalation_level%TYPE DEFAULT fnd_api.g_miss_char,
        attribute1              jtf_tasks_b.attribute1%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute2              jtf_tasks_b.attribute2%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute3              jtf_tasks_b.attribute3%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute4              jtf_tasks_b.attribute4%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute5              jtf_tasks_b.attribute5%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute6              jtf_tasks_b.attribute6%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute7              jtf_tasks_b.attribute7%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute8              jtf_tasks_b.attribute8%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute9              jtf_tasks_b.attribute9%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute10             jtf_tasks_b.attribute10%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute11             jtf_tasks_b.attribute11%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute12             jtf_tasks_b.attribute12%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute13             jtf_tasks_b.attribute13%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute14             jtf_tasks_b.attribute14%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute15             jtf_tasks_b.attribute15%TYPE DEFAULT jtf_task_utl.g_miss_char,
        attribute_category      jtf_tasks_b.attribute_category%TYPE DEFAULT jtf_task_utl.g_miss_char,
        date_selected           jtf_tasks_b.date_selected%TYPE DEFAULT jtf_task_utl.g_miss_char,
        category_id             NUMBER   DEFAULT jtf_task_utl.g_miss_number,
        show_on_calendar        jtf_task_all_assignments.show_on_calendar%TYPE DEFAULT jtf_task_utl.g_miss_char,
        owner_status_id         NUMBER   DEFAULT jtf_task_utl.g_miss_number,
        enable_workflow         VARCHAR2(1) DEFAULT fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
        abort_workflow          VARCHAR2(1) DEFAULT fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
        change_mode             VARCHAR2(1) DEFAULT 'N',
        recurrence_rule_id      NUMBER   DEFAULT NULL,
        old_calendar_start_date DATE     DEFAULT NULL,
        new_calendar_start_date DATE     DEFAULT NULL,
        new_calendar_end_date   DATE     DEFAULT NULL,
	  free_busy_type	        jtf_task_all_assignments.free_busy_type%TYPE DEFAULT jtf_task_utl.g_miss_char, -- Bug No 4231616
        location_id		  NUMBER   DEFAULT NULL
    );

    PROCEDURE update_repeat_appointment(
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN OUT NOCOPY   NUMBER,
        p_updated_field_rec       IN       updated_field_rec,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    );


END JTF_TASK_REPEAT_APPT_PVT;

 

/
