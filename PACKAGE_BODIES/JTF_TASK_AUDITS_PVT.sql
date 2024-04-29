--------------------------------------------------------
--  DDL for Package Body JTF_TASK_AUDITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_AUDITS_PVT" AS
/* $Header: jtftktub.pls 120.3.12010000.4 2010/03/31 12:12:57 anangupt ship $ */
   PROCEDURE process_task_audits (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number       IN       NUMBER ,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      p_old_billable_flag           IN       VARCHAR2 DEFAULT NULL,
      p_old_device1_flag            IN       VARCHAR2 DEFAULT NULL,
      p_old_device2_flag            IN       VARCHAR2 DEFAULT NULL,
      p_old_device3_flag            IN       VARCHAR2 DEFAULT NULL,
      p_old_esc_flag                IN       VARCHAR2 DEFAULT NULL,
      p_old_holiday_flag            IN       VARCHAR2 DEFAULT NULL,
      p_old_laptop_flag             IN       VARCHAR2 DEFAULT NULL,
      p_old_milestone_flag          IN       VARCHAR2 DEFAULT NULL,
      p_old_multi_booked_flag       IN       VARCHAR2 DEFAULT NULL,
      p_old_not_flag                IN       VARCHAR2 DEFAULT NULL,
      p_old_palm_flag               IN       VARCHAR2 DEFAULT NULL,
      p_old_private_flag            IN       VARCHAR2 DEFAULT NULL,
      p_old_publish_flag            IN       VARCHAR2 DEFAULT NULL,
      p_old_restrict_closure_flag   IN       VARCHAR2 DEFAULT NULL,
      p_old_wince_flag              IN       VARCHAR2 DEFAULT NULL,
      p_old_soft_bound_flag         IN       VARCHAR2 DEFAULT NULL,
      p_new_billable_flag           IN       VARCHAR2 DEFAULT NULL,
      p_new_device1_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_device2_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_device3_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_esc_flag                IN       VARCHAR2 DEFAULT NULL,
      p_new_holiday_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_laptop_flag             IN       VARCHAR2 DEFAULT NULL,
      p_new_milestone_flag          IN       VARCHAR2 DEFAULT NULL,
      p_new_multi_booked_flag       IN       VARCHAR2 DEFAULT NULL,
      p_new_not_flag                IN       VARCHAR2 DEFAULT NULL,
      p_new_palm_flag               IN       VARCHAR2 DEFAULT NULL,
      p_new_private_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_publish_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_restrict_closure_flag   IN       VARCHAR2 DEFAULT NULL,
      p_new_wince_flag              IN       VARCHAR2 DEFAULT NULL,
      p_new_soft_bound_flag         IN       VARCHAR2 DEFAULT NULL,
      p_new_actual_effort           IN       NUMBER DEFAULT NULL,
      p_new_actual_effort_uom       IN       VARCHAR2 DEFAULT NULL,
      p_new_actual_end_date         IN       DATE DEFAULT NULL,
      p_new_actual_start_date       IN       DATE DEFAULT NULL,
      p_new_address_id              IN       NUMBER DEFAULT NULL,
      p_new_assigned_by_id          IN       NUMBER DEFAULT NULL,
      p_new_bound_mode_code         IN       VARCHAR2 DEFAULT NULL,
      p_new_costs                   IN       NUMBER DEFAULT NULL,
      p_new_currency_code           IN       VARCHAR2 DEFAULT NULL,
      p_new_customer_id             IN       NUMBER DEFAULT NULL,
      p_new_cust_account_id         IN       NUMBER DEFAULT NULL,
      p_new_duration                IN       NUMBER DEFAULT NULL,
      p_new_duration_uom            IN       VARCHAR2 DEFAULT NULL,
      p_new_esc_owner_id            IN       NUMBER DEFAULT NULL,
      p_new_esc_terr_id             IN       NUMBER DEFAULT NULL,
      p_new_not_period              IN       NUMBER DEFAULT NULL,
      p_new_not_period_uom          IN       VARCHAR2 DEFAULT NULL,
      p_new_org_id                  IN       NUMBER DEFAULT NULL,
      p_new_owner_id                IN       NUMBER DEFAULT NULL,
      p_new_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
      p_new_parent_task_id          IN       NUMBER DEFAULT NULL,
      p_new_per_complete            IN       NUMBER DEFAULT NULL,
      p_new_planned_effort          IN       NUMBER DEFAULT NULL,
      p_new_planned_effort_uom      IN       VARCHAR2 DEFAULT NULL,
      p_new_planned_end_date        IN       DATE DEFAULT NULL,
      p_new_planned_start_date      IN       DATE DEFAULT NULL,
      p_new_reason_code             IN       VARCHAR2 DEFAULT NULL,
      p_new_recurrence_rule_id      IN       NUMBER DEFAULT NULL,
      p_new_sched_end_date          IN       DATE DEFAULT NULL,
      p_new_sched_start_date        IN       DATE DEFAULT NULL,
      p_new_src_obj_id              IN       NUMBER DEFAULT NULL,
      p_new_src_obj_name            IN       VARCHAR2 DEFAULT NULL,
      p_new_src_obj_type_code       IN       VARCHAR2 DEFAULT NULL,
      p_new_task_priority_id        IN       NUMBER DEFAULT NULL,
      p_new_task_status_id          IN       NUMBER DEFAULT NULL,
      p_new_task_type_id            IN       NUMBER DEFAULT NULL,
      p_new_timezone_id             IN       NUMBER DEFAULT NULL,
      p_new_workflow_process_id     IN       NUMBER DEFAULT NULL,
      p_not_chan_flag               IN       VARCHAR2 DEFAULT NULL,
      p_old_actual_effort           IN       NUMBER DEFAULT NULL,
      p_old_actual_effort_uom       IN       VARCHAR2 DEFAULT NULL,
      p_old_actual_end_date         IN       DATE DEFAULT NULL,
      p_old_actual_start_date       IN       DATE DEFAULT NULL,
      p_old_address_id              IN       NUMBER DEFAULT NULL,
      p_old_assigned_by_id          IN       NUMBER DEFAULT NULL,
      p_old_bound_mode_code         IN       VARCHAR2 DEFAULT NULL,
      p_old_costs                   IN       NUMBER DEFAULT NULL,
      p_old_currency_code           IN       VARCHAR2 DEFAULT NULL,
      p_old_customer_id             IN       NUMBER DEFAULT NULL,
      p_old_cust_account_id         IN       NUMBER DEFAULT NULL,
      p_old_duration                IN       NUMBER DEFAULT NULL,
      p_old_duration_uom            IN       VARCHAR2 DEFAULT NULL,
      p_old_esc_owner_id            IN       NUMBER DEFAULT NULL,
      p_old_esc_terr_id             IN       NUMBER DEFAULT NULL,
      p_old_not_period              IN       NUMBER DEFAULT NULL,
      p_old_not_period_uom          IN       VARCHAR2 DEFAULT NULL,
      p_old_org_id                  IN       NUMBER DEFAULT NULL,
      p_old_owner_id                IN       NUMBER DEFAULT NULL,
      p_old_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
      p_old_parent_task_id          IN       NUMBER DEFAULT NULL,
      p_old_per_complete            IN       NUMBER DEFAULT NULL,
      p_old_planned_effort          IN       NUMBER DEFAULT NULL,
      p_old_planned_effort_uom      IN       VARCHAR2 DEFAULT NULL,
      p_old_planned_end_date        IN       DATE DEFAULT NULL,
      p_old_planned_start_date      IN       DATE DEFAULT NULL,
      p_old_reason_code             IN       VARCHAR2 DEFAULT NULL,
      p_old_recurrence_rule_id      IN       NUMBER DEFAULT NULL,
      p_old_sched_end_date          IN       DATE DEFAULT NULL,
      p_old_sched_start_date        IN       DATE DEFAULT NULL,
      p_old_src_obj_id              IN       NUMBER DEFAULT NULL,
      p_old_src_obj_name            IN       VARCHAR2 DEFAULT NULL,
      p_old_src_obj_type_code       IN       VARCHAR2 DEFAULT NULL,
      p_old_task_priority_id        IN       NUMBER DEFAULT NULL,
      p_old_task_status_id          IN       NUMBER DEFAULT NULL,
      p_old_task_type_id            IN       NUMBER DEFAULT NULL,
      p_old_timezone_id             IN       NUMBER DEFAULT NULL,
      p_old_workflow_process_id     IN       NUMBER DEFAULT NULL,
      p_task_id                     IN       NUMBER,
      p_new_description             IN       VARCHAR2 DEFAULT NULL,
      p_new_task_name               IN       VARCHAR2 DEFAULT NULL,
      p_old_description             IN       VARCHAR2 DEFAULT NULL,
      p_old_task_name               IN       VARCHAR2 DEFAULT NULL,
      p_old_escalation_level        IN       VARCHAR2 DEFAULT NULL,
      p_new_escalation_level        IN       VARCHAR2 DEFAULT NULL,
      p_old_owner_territory_id      IN       NUMBER DEFAULT NULL,
      p_new_owner_territory_id      IN       NUMBER DEFAULT NULL,
      P_OLD_DATE_SELECTED           IN       VARCHAR2 DEFAULT NULL ,
      P_NEW_DATE_SELECTED           IN       VARCHAR2 DEFAULT NULL ,
      p_old_location_id             IN       NUMBER DEFAULT NULL,
      p_new_location_id             IN       NUMBER DEFAULT NULL,
      x_task_audit_id               OUT NOCOPY NUMBER
   )
   IS
      l_api_name              CONSTANT VARCHAR2(30)   := 'JTF_TASK_AUDITS_PVT';
      l_api_version           CONSTANT NUMBER         := 1.0;
      l_rowid                          ROWID;
      l_init_msg_list                  VARCHAR2(10)   := fnd_api.g_false;
      l_commit                         VARCHAR2(10)   := fnd_api.g_false;
      l_last_update_date               DATE;
      l_last_updated_by                NUMBER;
      l_creation_date                  DATE           := SYSDATE;
      l_task_audit_id                  NUMBER;
      l_task_id                        NUMBER         := p_task_id;
      l_new_actual_effort              NUMBER         := p_new_actual_effort;
      l_new_actual_effort_uom          VARCHAR2(3)    := p_new_actual_effort_uom;
      l_new_actual_end_date            DATE           := p_new_actual_end_date;
      l_new_actual_start_date          DATE           := p_new_actual_start_date;
      l_new_address_id                 NUMBER         := p_new_address_id;
      l_new_assigned_by_id             NUMBER         := p_new_assigned_by_id;
      l_new_bound_mode_code            VARCHAR2(30)   := p_new_bound_mode_code;
      l_new_costs                      NUMBER         := p_new_costs;
      l_new_currency_code              VARCHAR2(15)   := p_new_currency_code;
      l_new_customer_id                NUMBER         := p_new_customer_id;
      l_new_cust_account_id            NUMBER         := p_new_cust_account_id;
      l_new_duration                   NUMBER         := p_new_duration;
      l_new_duration_uom               VARCHAR2(3)    := p_new_duration_uom;
      l_new_esc_owner_id               NUMBER         := p_new_esc_owner_id;
      l_new_esc_terr_id                NUMBER         := p_new_esc_terr_id;
      l_new_not_period                 NUMBER         := p_new_not_period;
      l_new_not_period_uom             VARCHAR2(3)    := p_new_not_period_uom;
      l_new_org_id                     NUMBER         := p_new_org_id;
      l_new_owner_id                   NUMBER         := p_new_owner_id;
      l_new_owner_type_code            VARCHAR2(30)   := p_new_owner_type_code;
      l_new_parent_task_id             NUMBER         := p_new_parent_task_id;
      l_new_per_complete               NUMBER         := p_new_per_complete;
      l_new_planned_effort             NUMBER         := p_new_planned_effort;
      l_new_planned_effort_uom         VARCHAR2(3)    := p_new_planned_effort_uom;
      l_new_planned_end_date           DATE           := p_new_planned_end_date;
      l_new_planned_start_date         DATE           := p_new_planned_start_date;
      l_new_reason_code                VARCHAR2(30)   := p_new_reason_code;
      l_new_recurrence_rule_id         NUMBER         := p_new_recurrence_rule_id;
      l_new_sched_end_date             DATE           := p_new_sched_end_date;
      l_new_sched_start_date           DATE           := p_new_sched_start_date;
      l_new_src_obj_id                 NUMBER         := p_new_src_obj_id;
      l_new_src_obj_name               VARCHAR2(80)   := p_new_src_obj_name;
      l_new_src_obj_type_code          VARCHAR2(30)   := p_new_src_obj_type_code;
      l_new_task_priority_id           NUMBER         := p_new_task_priority_id;
      l_new_task_status_id             NUMBER         := p_new_task_status_id;
      l_new_task_type_id               NUMBER         := p_new_task_type_id;
      l_new_timezone_id                NUMBER         := p_new_timezone_id;
      l_new_workflow_process_id        NUMBER         := p_new_workflow_process_id;
      l_new_description                VARCHAR2(4000) := p_new_description;
      l_old_description                VARCHAR2(4000) := p_old_description;
      l_old_billable_flag              VARCHAR2(1)    := p_old_billable_flag;
      l_old_device1_flag               VARCHAR2(1)    := p_old_device1_flag;
      l_old_device2_flag               VARCHAR2(1)    := p_old_device2_flag;
      l_old_device3_flag               VARCHAR2(1)    := p_old_device3_flag;
      l_old_esc_flag                   VARCHAR2(1)    := p_old_esc_flag;
      l_old_holiday_flag               VARCHAR2(1)    := p_old_holiday_flag;
      l_old_laptop_flag                VARCHAR2(1)    := p_old_laptop_flag;
      l_old_milestone_flag             VARCHAR2(1)    := p_old_milestone_flag;
      l_old_multi_booked_flag          VARCHAR2(1)    := p_old_multi_booked_flag;
      l_old_not_flag                   VARCHAR2(1)    := p_old_not_flag;
      l_old_palm_flag                  VARCHAR2(1)    := p_old_palm_flag;
      l_old_private_flag               VARCHAR2(1)    := p_old_private_flag;
      l_old_publish_flag               VARCHAR2(1)    := p_old_publish_flag;
      l_old_restrict_closure_flag      VARCHAR2(1)    := p_old_restrict_closure_flag;
      l_old_wince_flag                 VARCHAR2(1)    := p_old_wince_flag;
      l_old_soft_bound_flag            VARCHAR2(1)    := p_old_soft_bound_flag;
      l_old_actual_effort              NUMBER         := p_old_actual_effort;
      l_old_actual_effort_uom          VARCHAR2(3)    := p_old_actual_effort_uom;
      l_old_actual_end_date            DATE           := p_old_actual_end_date;
      l_old_actual_start_date          DATE           := p_old_actual_start_date;
      l_old_address_id                 NUMBER         := p_old_address_id;
      l_old_assigned_by_id             NUMBER         := p_old_assigned_by_id;
      l_old_bound_mode_code            VARCHAR2(30)   := p_old_bound_mode_code;
      l_old_costs                      NUMBER         := p_old_costs;
      l_old_currency_code              VARCHAR2(15)   := p_old_currency_code;
      l_old_customer_id                NUMBER         := p_old_customer_id;
      l_old_cust_account_id            NUMBER         := p_old_cust_account_id;
      l_old_duration                   NUMBER         := p_old_duration;
      l_old_duration_uom               VARCHAR2(3)    := p_old_duration_uom;
      l_old_esc_owner_id               NUMBER         := p_old_esc_owner_id;
      l_old_esc_terr_id                NUMBER         := p_old_esc_terr_id;
      l_old_not_period                 NUMBER         := p_old_not_period;
      l_old_not_period_uom             VARCHAR2(3)    := p_old_not_period_uom;
      l_old_org_id                     NUMBER         := p_old_org_id;
      l_old_owner_id                   NUMBER         := p_old_owner_id;
      l_old_owner_type_code            VARCHAR2(30)   := p_old_owner_type_code;
      l_old_parent_task_id             NUMBER         := p_old_parent_task_id;
      l_old_per_complete               NUMBER         := p_old_per_complete;
      l_old_planned_effort             NUMBER         := p_old_planned_effort;
      l_old_planned_effort_uom         VARCHAR2(3)    := p_old_planned_effort_uom;
      l_old_planned_end_date           DATE           := p_old_planned_end_date;
      l_old_planned_start_date         DATE           := p_old_planned_start_date;
      l_old_reason_code                VARCHAR2(30)   := p_old_reason_code;
      l_old_recurrence_rule_id         NUMBER         := p_old_recurrence_rule_id;
      l_old_sched_end_date             DATE           := p_old_sched_end_date;
      l_old_sched_start_date           DATE           := p_old_sched_start_date;
      l_old_src_obj_id                 NUMBER         := p_old_src_obj_id;
      l_old_src_obj_name               VARCHAR2(80)   := p_old_src_obj_name;
      l_old_src_obj_type_code          VARCHAR2(30)   := p_old_src_obj_type_code;
      l_old_task_priority_id           NUMBER         := p_old_task_priority_id;
      l_old_task_status_id             NUMBER         := p_old_task_status_id;
      l_old_task_type_id               NUMBER         := p_old_task_type_id;
      l_old_timezone_id                NUMBER         := p_old_timezone_id;
      l_old_workflow_process_id        NUMBER         := p_old_workflow_process_id;
      l_new_task_name                  VARCHAR2(80)   := p_new_task_name;
      l_old_task_name                  VARCHAR2(80)   := p_old_task_name;
      l_new_billable_flag              VARCHAR2(1)    := p_new_billable_flag;
      l_new_device1_flag               VARCHAR2(1)    := p_new_device1_flag;
      l_new_device2_flag               VARCHAR2(1)    := p_new_device2_flag;
      l_new_device3_flag               VARCHAR2(1)    := p_new_device3_flag;
      l_new_esc_flag                   VARCHAR2(1)    := p_new_esc_flag;
      l_new_holiday_flag               VARCHAR2(1)    := p_new_holiday_flag;
      l_new_laptop_flag                VARCHAR2(1)    := p_new_laptop_flag;
      l_new_milestone_flag             VARCHAR2(1)    := p_new_milestone_flag;
      l_new_multi_booked_flag          VARCHAR2(1)    := p_new_multi_booked_flag;
      l_new_not_flag                   VARCHAR2(1)    := p_new_not_flag;
      l_new_palm_flag                  VARCHAR2(1)    := p_new_palm_flag;
      l_new_private_flag               VARCHAR2(1)    := p_new_private_flag;
      l_new_publish_flag               VARCHAR2(1)    := p_new_publish_flag;
      l_new_restrict_closure_flag      VARCHAR2(1)    := p_new_restrict_closure_flag;
      l_new_wince_flag                 VARCHAR2(1)    := p_new_wince_flag;
      l_new_soft_bound_flag            VARCHAR2(1)    := p_new_soft_bound_flag;
      l_object_version_number          NUMBER         := p_object_version_number;
      --l_owner_territory_id                  NUMBER            := P_OWNER_TERRITORY_ID;
      l_address_chan_flag              CHAR(1)        := 'N';
      l_status_chan_flag               CHAR(1)        := 'N';
      l_bound_chan_flag                CHAR(1)        := 'N';
      l_costs_chan_flag                CHAR(1)        := 'N';
      l_currency_code_chan_flag        CHAR(1)        := 'N';
      l_customer_id_chan_flag          CHAR(1)        := 'N';
      l_cust_account_chan_flag         CHAR(1)        := 'N';
      l_duration_chan_flag             CHAR(1)        := 'N';
      l_duration_uom_chan_flag         CHAR(1)        := 'N';
      l_workflow_chan_flag             CHAR(1)        := 'N';
      l_not_chan_flag                  CHAR(1)        := 'N';
      l_palm_chan_flag                 CHAR(1)        := 'N';
      l_private_chan_flag              CHAR(1)        := 'N';
      l_publish_chan_flag              CHAR(1)        := 'N';
      l_restrict_closure_chan_flag     CHAR(1)        := 'N';
      l_wince_chan_flag                CHAR(1)        := 'N';
      l_soft_bound_chan_flag           CHAR(1)        := 'N';
      l_billable_chan_flag             CHAR(1)        := 'N';
      l_device1_chan_flag              CHAR(1)        := 'N';
      l_device2_chan_flag              CHAR(1)        := 'N';
      l_device3_chan_flag              CHAR(1)        := 'N';
      l_esc_chan_flag                  CHAR(1)        := 'N';
      l_holiday_chan_flag              CHAR(1)        := 'N';
      l_laptop_chan_flag               CHAR(1)        := 'N';
      l_milestone_chan_flag            CHAR(1)        := 'N';
      l_multi_booked_chan_flag         CHAR(1)        := 'N';
      l_esc_owner_id_chan_flag         CHAR(1)        := 'N';
      l_esc_terr_id_chan_flag          CHAR(1)        := 'N';
      l_not_period_chan_flag           CHAR(1)        := 'N';
      l_not_period_uom_chan_flag       CHAR(1)        := 'N';
      l_owner_id_chan_flag             CHAR(1)        := 'N';
      l_owner_type_code_chan_flag      CHAR(1)        := 'N';
      l_parent_task_id_chan_flag       CHAR(1)        := 'N';
      l_per_complete_chan_flag         CHAR(1)        := 'N';
      l_planned_effort_chan_flag       CHAR(1)        := 'N';
      l_planned_effort_uom_chan_flag   CHAR(1)        := 'N';
      l_planned_end_date_chan_flag     CHAR(1)        := 'N';
      l_planned_start_date_chan_flag   CHAR(1)        := 'N';
      l_reason_code_chan_flag          CHAR(1)        := 'N';
      l_recurrence_rule_id_chan_flag   CHAR(1)        := 'N';
      l_sched_end_date_chan_flag       CHAR(1)        := 'N';
      l_sched_start_date_chan_flag     CHAR(1)        := 'N';
      l_src_obj_id_chan_flag           CHAR(1)        := 'N';
      l_src_obj_name_chan_flag         CHAR(1)        := 'N';
      l_src_obj_type_code_chan_flag    CHAR(1)        := 'N';
      l_task_priority_id_chan_flag     CHAR(1)        := 'N';
      l_task_status_id_chan_flag       CHAR(1)        := 'N';
      l_task_type_id_chan_flag         CHAR(1)        := 'N';
      l_timezone_id_chan_flag          CHAR(1)        := 'N';
      l_task_name_chan_flag            CHAR(1)        := 'N';
      l_owner_territory_id_chan_flag   CHAR(1)        := 'N';
      l_escalation_level_chan_flag     CHAR(1)        := 'N';
      l_description_chan_flag          CHAR(1)        := 'N';
      l_date_selected_chan_flag        CHAR(1)        := 'N';
      l_location_id_chan_flag          CHAR(1)        := 'N';
      l_old_owner_territory_id         NUMBER         := p_old_owner_territory_id;
      l_new_owner_territory_id         NUMBER         := p_new_owner_territory_id;
      l_new_escalation_level           VARCHAR2(5)    := p_new_escalation_level;
      l_old_escalation_level           VARCHAR2(5)    := p_old_escalation_level;
      l_OLD_DATE_SELECTED              VARCHAR2(1)    := p_OLD_DATE_SELECTED;
      l_NEW_DATE_SELECTED              VARCHAR2(1)    := p_NEW_DATE_SELECTED;
      l_old_location_id                NUMBER         := p_old_location_id;
      l_new_location_id                NUMBER         := p_new_location_id;

      x                                CHAR;
      l_creation_date                  DATE;
      l_created_by                     NUMBER(15);
      l_last_update_date               DATE;
      x_commit                         VARCHAR2(1);
      l_last_updated_by                NUMBER(15);
      l_last_update_login              NUMBER(15);

      CURSOR ta_cur1 (l_rowid IN ROWID)
      IS
         SELECT 1
           FROM jtf_task_audits_b
          WHERE ROWID = l_rowid;

      CURSOR c_audit
      IS
         SELECT jtf_task_audits_s.nextval
           FROM dual;
   BEGIN
      -- ---------------------------------------
      -- Standard API stuff
      -- ---------------------------------------

      -- Establish savepoint
      SAVEPOINT process_task_audit_pvt;

      -- Check version number
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if requested
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize return status to SUCCESS
      x_return_status := fnd_api.g_ret_sts_success;

      --dbms_output.put_line(' start of process task  ');

       -- ----------------------------------------------
      -- Check if the audited fields have been changed
      -- ----------------------------------------------
      IF     (NOT (   p_new_address_id IS NULL
                  AND p_old_address_id IS NULL))
         AND (  p_new_address_id IS NULL
             OR p_old_address_id IS NULL
             OR p_new_address_id <> p_old_address_id)
      THEN
         l_address_chan_flag := 'Y';
         l_new_address_id := p_new_address_id;
         l_old_address_id := p_old_address_id;
      END IF;

      IF     (NOT (   p_new_assigned_by_id IS NULL
                  AND p_old_assigned_by_id IS NULL))
         AND (  p_new_assigned_by_id IS NULL
             OR p_old_assigned_by_id IS NULL
             OR p_new_assigned_by_id <> p_old_assigned_by_id)
      THEN
         l_status_chan_flag := 'Y';
         l_new_assigned_by_id := p_new_assigned_by_id;
         l_old_assigned_by_id := p_old_assigned_by_id;
      END IF;

      IF     (NOT (   p_new_bound_mode_code IS NULL
                  AND p_old_bound_mode_code IS NULL))
         AND (  p_new_bound_mode_code IS NULL
             OR p_old_bound_mode_code IS NULL
             OR p_new_bound_mode_code <> p_old_bound_mode_code)
      THEN
         l_bound_chan_flag := 'Y';
         l_new_bound_mode_code := p_new_bound_mode_code;
         l_old_bound_mode_code := p_old_bound_mode_code;
      END IF;

      IF     (NOT (   p_new_costs IS NULL
                  AND p_old_costs IS NULL))
         AND (  p_new_costs IS NULL
             OR p_old_costs IS NULL
             OR p_new_costs <> p_old_costs)
      THEN
         l_costs_chan_flag := 'Y';
         l_new_costs := p_new_costs;
         l_old_costs := p_old_costs;
      END IF;

      IF     (NOT (   p_new_currency_code IS NULL
                  AND p_old_currency_code IS NULL))
         AND (  p_new_currency_code IS NULL
             OR p_old_currency_code IS NULL
             OR p_new_currency_code <> p_old_currency_code)
      THEN
         l_currency_code_chan_flag := 'Y';
         l_new_currency_code := p_new_currency_code;
         l_old_currency_code := p_old_currency_code;
      END IF;

      IF     (NOT (   p_new_customer_id IS NULL
                  AND p_old_customer_id IS NULL))
         AND (  p_new_customer_id IS NULL
             OR p_old_customer_id IS NULL
             OR p_new_customer_id <> p_old_customer_id)
      THEN
         l_customer_id_chan_flag := 'Y';
         l_new_customer_id := p_new_customer_id;
         l_old_customer_id := p_old_customer_id;
      END IF;

      IF     (NOT (   p_new_cust_account_id IS NULL
                  AND p_old_cust_account_id IS NULL))
         AND (  p_new_cust_account_id IS NULL
             OR p_old_cust_account_id IS NULL
             OR p_new_cust_account_id <> p_old_cust_account_id)
      THEN
         l_cust_account_chan_flag := 'Y';
         l_new_cust_account_id := p_new_cust_account_id;
         l_old_cust_account_id := p_old_cust_account_id;
      END IF;

      IF     (NOT (   p_new_duration IS NULL
                  AND p_old_duration IS NULL))
         AND (  p_new_duration IS NULL
             OR p_old_duration IS NULL
             OR p_new_duration <> p_old_duration)
      THEN
         l_duration_chan_flag := 'Y';
         l_new_duration := p_new_duration;
         l_old_duration := p_old_duration;
      END IF;

      IF     (NOT (   p_new_duration_uom IS NULL
                  AND p_old_duration_uom IS NULL))
         AND (  p_new_duration_uom IS NULL
             OR p_old_duration_uom IS NULL
             OR p_new_duration_uom <> p_old_duration_uom)
      THEN
         l_duration_uom_chan_flag := 'Y';
         l_new_duration_uom := p_new_duration_uom;
         l_old_duration_uom := p_old_duration_uom;
      END IF;

      IF     (NOT (   p_new_not_period IS NULL
                  AND p_old_not_period IS NULL))
         AND (  p_new_not_period IS NULL
             OR p_old_not_period IS NULL
             OR p_new_not_period <> p_old_not_period)
      THEN
         l_not_period_chan_flag := 'Y';
         l_new_not_period := p_new_not_period;
         l_old_not_period := p_old_not_period;
      END IF;

      IF     (NOT (   p_new_not_period_uom IS NULL
                  AND p_old_not_period_uom IS NULL))
         AND (  p_new_not_period_uom IS NULL
             OR p_old_not_period_uom IS NULL
             OR p_new_not_period_uom <> p_old_not_period_uom)
      THEN
         l_not_period_uom_chan_flag := 'Y';
         l_new_not_period_uom := p_new_not_period_uom;
         l_old_not_period_uom := p_old_not_period_uom;
      END IF;

      IF     (NOT (   p_new_owner_id IS NULL
                  AND p_old_owner_id IS NULL))
         AND (  p_new_owner_id IS NULL
             OR p_old_owner_id IS NULL
             OR p_new_owner_id <> p_old_owner_id)
      THEN
         l_owner_id_chan_flag := 'Y';
         l_new_owner_id := p_new_owner_id;
         l_old_owner_id := p_old_owner_id;
      END IF;

      IF     (NOT (   p_new_owner_type_code IS NULL
                  AND p_old_owner_type_code IS NULL))
         AND (  p_new_owner_type_code IS NULL
             OR p_old_owner_type_code IS NULL
             OR p_new_owner_type_code <> p_old_owner_type_code)
      THEN
         l_owner_type_code_chan_flag := 'Y';
         l_new_owner_type_code := p_new_owner_type_code;
         l_old_owner_type_code := p_old_owner_type_code;
      END IF;

      IF     (NOT (   p_new_parent_task_id IS NULL
                  AND p_old_parent_task_id IS NULL))
         AND (  p_new_parent_task_id IS NULL
             OR p_old_parent_task_id IS NULL
             OR p_new_parent_task_id <> p_old_parent_task_id)
      THEN
         l_parent_task_id_chan_flag := 'Y';
         l_new_parent_task_id := p_new_parent_task_id;
         l_old_parent_task_id := p_old_parent_task_id;
      END IF;

      IF     (NOT (   p_new_task_name IS NULL
                  AND p_old_task_name IS NULL))
         AND (  p_new_task_name IS NULL
             OR p_old_task_name IS NULL
             OR p_new_task_name <> p_old_task_name)
      THEN
         l_task_name_chan_flag := 'Y';
         l_new_task_name := p_new_task_name;
         l_old_task_name := p_old_task_name;
      END IF;

      IF     (NOT (   p_new_per_complete IS NULL
                  AND p_old_per_complete IS NULL))
         AND (  p_new_per_complete IS NULL
             OR p_old_per_complete IS NULL
             OR p_new_per_complete <> p_old_per_complete)
      THEN
         l_per_complete_chan_flag := 'Y';
         l_new_per_complete := p_new_per_complete;
         l_old_per_complete := p_old_per_complete;
      END IF;

      IF     (NOT (   p_new_planned_effort IS NULL
                  AND p_old_planned_effort IS NULL))
         AND (  p_new_planned_effort IS NULL
             OR p_old_planned_effort IS NULL
             OR p_new_planned_effort <> p_old_planned_effort)
      THEN
         l_planned_effort_chan_flag := 'Y';
         l_new_planned_effort := p_new_planned_effort;
         l_old_planned_effort := p_old_planned_effort;
      END IF;

      IF     (NOT (   p_new_planned_effort_uom IS NULL
                  AND p_old_planned_effort_uom IS NULL))
         AND (  p_new_planned_effort_uom IS NULL
             OR p_old_planned_effort_uom IS NULL
             OR p_new_planned_effort_uom <> p_old_planned_effort_uom)
      THEN
         l_planned_effort_uom_chan_flag := 'Y';
         l_new_planned_effort_uom := p_new_planned_effort_uom;
         l_old_planned_effort_uom := p_old_planned_effort_uom;
      END IF;

      IF     (NOT (   p_new_planned_end_date IS NULL
                  AND p_old_planned_end_date IS NULL))
         AND (  p_new_planned_end_date IS NULL
             OR p_old_planned_end_date IS NULL
             OR p_new_planned_end_date <> p_old_planned_end_date)
      THEN
         l_planned_end_date_chan_flag := 'Y';
         l_new_planned_end_date := p_new_planned_end_date;
         l_old_planned_end_date := p_old_planned_end_date;
      END IF;

      IF     (NOT (   p_new_planned_start_date IS NULL
                  AND p_old_planned_start_date IS NULL))
         AND (  p_new_planned_start_date IS NULL
             OR p_old_planned_start_date IS NULL
             OR p_new_planned_start_date <> p_old_planned_start_date)
      THEN
         l_planned_start_date_chan_flag := 'Y';
         l_new_planned_start_date := p_new_planned_start_date;
         l_old_planned_start_date := p_old_planned_start_date;
      END IF;

      IF     (NOT (   p_new_reason_code IS NULL
                  AND p_old_reason_code IS NULL))
         AND (  p_new_reason_code IS NULL
             OR p_old_reason_code IS NULL
             OR p_new_reason_code <> p_old_reason_code)
      THEN
         l_reason_code_chan_flag := 'Y';
         l_new_reason_code := p_new_reason_code;
         l_old_reason_code := p_old_reason_code;
      END IF;

      IF     (NOT (   p_new_recurrence_rule_id IS NULL
                  AND p_old_recurrence_rule_id IS NULL))
         AND (  p_new_recurrence_rule_id IS NULL
             OR p_old_recurrence_rule_id IS NULL
             OR p_new_recurrence_rule_id <> p_old_recurrence_rule_id)
      THEN
         l_recurrence_rule_id_chan_flag := 'Y';
         l_new_recurrence_rule_id := p_new_recurrence_rule_id;
         l_old_recurrence_rule_id := p_old_recurrence_rule_id;
      END IF;

      IF     (NOT (   p_new_sched_end_date IS NULL
                  AND p_old_sched_end_date IS NULL))
         AND (  p_new_sched_end_date IS NULL
             OR p_old_sched_end_date IS NULL
             OR p_new_sched_end_date <> p_old_sched_end_date)
      THEN
         l_sched_end_date_chan_flag := 'Y';
         l_new_sched_end_date := p_new_sched_end_date;
         l_old_sched_end_date := p_old_sched_end_date;
      END IF;

      IF     (NOT (   p_new_sched_start_date IS NULL
                  AND p_old_sched_start_date IS NULL))
         AND (  p_new_sched_start_date IS NULL
             OR p_old_sched_start_date IS NULL
             OR p_new_sched_start_date <> p_old_sched_start_date)
      THEN
         l_sched_start_date_chan_flag := 'Y';
         l_new_sched_start_date := p_new_sched_start_date;
         l_old_sched_start_date := p_old_sched_start_date;
      END IF;

      IF     (NOT (   p_new_src_obj_id IS NULL
                  AND p_old_src_obj_id IS NULL))
         AND (  p_new_src_obj_id IS NULL
             OR p_old_src_obj_id IS NULL
             OR p_new_src_obj_id <> p_old_src_obj_id)
      THEN
         l_src_obj_id_chan_flag := 'Y';
         l_new_src_obj_id := p_new_src_obj_id;
         l_old_src_obj_id := p_old_src_obj_id;
      END IF;

      IF     (NOT (   p_new_src_obj_name IS NULL
                  AND p_old_src_obj_name IS NULL))
         AND (  p_new_src_obj_name IS NULL
             OR p_old_src_obj_name IS NULL
             OR p_new_src_obj_name <> p_old_src_obj_name)
      THEN
         l_src_obj_name_chan_flag := 'Y';
         l_new_src_obj_name := p_new_src_obj_name;
         l_old_src_obj_name := p_old_src_obj_name;
      END IF;

      IF     (NOT (   p_new_src_obj_type_code IS NULL
                  AND p_old_src_obj_type_code IS NULL))
         AND (  p_new_src_obj_type_code IS NULL
             OR p_old_src_obj_type_code IS NULL
             OR p_new_src_obj_type_code <> p_old_src_obj_type_code)
      THEN
         l_src_obj_type_code_chan_flag := 'Y';
         l_new_src_obj_type_code := p_new_src_obj_type_code;
         l_old_src_obj_type_code := p_old_src_obj_type_code;
      END IF;

      IF     (NOT (   p_new_task_priority_id IS NULL
                  AND p_old_task_priority_id IS NULL))
         AND (  p_new_task_priority_id IS NULL
             OR p_old_task_priority_id IS NULL
             OR p_new_task_priority_id <> p_old_task_priority_id)
      THEN
         l_task_priority_id_chan_flag := 'Y';
         l_new_task_priority_id := p_new_task_priority_id;
         l_old_task_priority_id := p_old_task_priority_id;
      END IF;

      IF     (NOT (   p_new_task_status_id IS NULL
                  AND p_old_task_status_id IS NULL))
         AND (  p_new_task_status_id IS NULL
             OR p_old_task_status_id IS NULL
             OR p_new_task_status_id <> p_old_task_status_id)
      THEN
         l_task_status_id_chan_flag := 'Y';
         l_new_task_status_id := p_new_task_status_id;
         l_old_task_status_id := p_old_task_status_id;
      END IF;

      IF     (NOT (   p_new_task_type_id IS NULL
                  AND p_old_task_type_id IS NULL))
         AND (  p_new_task_type_id IS NULL
             OR p_old_task_type_id IS NULL
             OR p_new_task_type_id <> p_old_task_type_id)
      THEN
         l_task_type_id_chan_flag := 'Y';
         l_new_task_type_id := p_new_task_type_id;
         l_old_task_type_id := p_old_task_type_id;
      END IF;

      IF     (NOT (   p_new_timezone_id IS NULL
                  AND p_old_timezone_id IS NULL))
         AND (  p_new_timezone_id IS NULL
             OR p_old_timezone_id IS NULL
             OR p_new_timezone_id <> p_old_timezone_id)
      THEN
         l_timezone_id_chan_flag := 'Y';
         l_new_timezone_id := p_new_timezone_id;
         l_old_timezone_id := p_old_timezone_id;
      END IF;

      IF     (NOT (   p_new_workflow_process_id IS NULL
                  AND p_old_workflow_process_id IS NULL))
         AND (  p_new_workflow_process_id IS NULL
             OR p_old_workflow_process_id IS NULL
             OR p_new_workflow_process_id <> p_old_workflow_process_id)
      THEN
         l_workflow_chan_flag := 'Y';
         l_new_workflow_process_id := p_new_workflow_process_id;
         l_old_workflow_process_id := p_old_workflow_process_id;
      END IF;

      IF     (NOT (   p_new_owner_territory_id IS NULL
                  AND p_old_owner_territory_id IS NULL))
         AND (  p_new_owner_territory_id IS NULL
             OR p_old_owner_territory_id IS NULL
             OR p_new_owner_territory_id <> p_old_owner_territory_id)
      THEN
         l_owner_territory_id_chan_flag := 'Y';
         l_new_owner_territory_id := p_new_owner_territory_id;
         l_old_owner_territory_id := p_old_owner_territory_id;
      END IF;

      IF     (NOT (   p_new_escalation_level IS NULL
                  AND p_old_escalation_level IS NULL))
         AND (  p_new_escalation_level IS NULL
             OR p_old_escalation_level IS NULL
             OR p_new_escalation_level <> p_old_escalation_level)
      THEN
         l_escalation_level_chan_flag := 'Y';
         l_new_escalation_level := p_new_escalation_level;
         l_old_escalation_level := p_old_escalation_level;
      END IF;

      IF     (NOT (   p_new_description IS NULL
                  AND p_old_description IS NULL))
         AND (  p_new_description IS NULL
             OR p_old_description IS NULL
             OR p_new_description <> p_old_description)
      THEN
         l_description_chan_flag := 'Y';
         l_new_description := p_new_description;
         l_old_description := p_old_description;
      END IF;

      IF     (NOT (   p_new_date_selected IS NULL
                  AND p_old_date_selected IS NULL))
         AND (  p_new_date_selected IS NULL
             OR p_old_date_selected IS NULL
             OR p_new_date_selected <> p_old_date_selected)
      THEN
         l_date_selected_chan_flag := 'Y';
         l_new_date_selected := p_new_date_selected;
         l_old_date_selected := p_old_date_selected;
      END IF;

      IF     (NOT (   p_new_location_id IS NULL
                  AND p_old_location_id IS NULL))
         AND (  p_new_location_id IS NULL
             OR p_old_location_id IS NULL
             OR p_new_location_id <> p_old_location_id)
      THEN
         l_location_id_chan_flag := 'Y';
         l_new_location_id := p_new_location_id;
         l_old_location_id := p_old_location_id;
      END IF;

      -- ---------------------------------------
      -- Call to Flags
      -- ---------------------------------------
      IF     (NOT (   p_new_billable_flag IS NULL
                  AND p_old_billable_flag IS NULL))
         AND (  p_new_billable_flag IS NULL
             OR p_old_billable_flag IS NULL
             OR p_new_billable_flag <> p_old_billable_flag)
      THEN
         l_billable_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_device1_flag IS NULL
                  AND p_old_device1_flag IS NULL))
         AND (  p_new_device1_flag IS NULL
             OR p_old_device1_flag IS NULL
             OR p_new_device1_flag <> p_old_device1_flag)
      THEN
         l_device1_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_device2_flag IS NULL
                  AND p_old_device2_flag IS NULL))
         AND (  p_new_device2_flag IS NULL
             OR p_old_device2_flag IS NULL
             OR p_new_device2_flag <> p_old_device2_flag)
      THEN
         l_device2_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_device3_flag IS NULL
                  AND p_old_device3_flag IS NULL))
         AND (  p_new_device3_flag IS NULL
             OR p_old_device3_flag IS NULL
             OR p_new_device3_flag <> p_old_device3_flag)
      THEN
         l_device3_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_esc_flag IS NULL
                  AND p_old_esc_flag IS NULL))
         AND (  p_new_esc_flag IS NULL
             OR p_old_esc_flag IS NULL
             OR p_new_esc_flag <> p_old_esc_flag)
      THEN
         l_esc_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_holiday_flag IS NULL
                  AND p_old_holiday_flag IS NULL))
         AND (  p_new_holiday_flag IS NULL
             OR p_old_holiday_flag IS NULL
             OR p_new_holiday_flag <> p_old_holiday_flag)
      THEN
         l_holiday_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_laptop_flag IS NULL
                  AND p_old_laptop_flag IS NULL))
         AND (  p_new_laptop_flag IS NULL
             OR p_old_laptop_flag IS NULL
             OR p_new_laptop_flag <> p_old_laptop_flag)
      THEN
         l_laptop_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_milestone_flag IS NULL
                  AND p_old_milestone_flag IS NULL))
         AND (  p_new_milestone_flag IS NULL
             OR p_old_milestone_flag IS NULL
             OR p_new_milestone_flag <> p_old_milestone_flag)
      THEN
         l_milestone_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_multi_booked_flag IS NULL
                  AND p_old_multi_booked_flag IS NULL))
         AND (  p_new_multi_booked_flag IS NULL
             OR p_old_multi_booked_flag IS NULL
             OR p_new_multi_booked_flag <> p_old_multi_booked_flag)
      THEN
         l_multi_booked_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_palm_flag IS NULL
                  AND p_old_palm_flag IS NULL))
         AND (  p_new_palm_flag IS NULL
             OR p_old_palm_flag IS NULL
             OR p_new_palm_flag <> p_old_palm_flag)
      THEN
         l_palm_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_private_flag IS NULL
                  AND p_old_private_flag IS NULL))
         AND (  p_new_private_flag IS NULL
             OR p_old_private_flag IS NULL
             OR p_new_private_flag <> p_old_private_flag)
      THEN
         l_private_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_publish_flag IS NULL
                  AND p_old_publish_flag IS NULL))
         AND (  p_new_publish_flag IS NULL
             OR p_old_publish_flag IS NULL
             OR p_new_publish_flag <> p_old_publish_flag)
      THEN
         l_publish_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_restrict_closure_flag IS NULL
                  AND p_old_restrict_closure_flag IS NULL))
         AND (  p_new_restrict_closure_flag IS NULL
             OR p_old_restrict_closure_flag IS NULL
             OR p_new_restrict_closure_flag <> p_old_restrict_closure_flag)
      THEN
         l_restrict_closure_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_multi_booked_flag IS NULL
                  AND p_old_multi_booked_flag IS NULL))
         AND (  p_new_multi_booked_flag IS NULL
             OR p_old_multi_booked_flag IS NULL
             OR p_new_multi_booked_flag <> p_old_multi_booked_flag)
      THEN
         l_multi_booked_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_wince_flag IS NULL
                  AND p_old_wince_flag IS NULL))
         AND (  p_new_wince_flag IS NULL
             OR p_old_wince_flag IS NULL
             OR p_new_wince_flag <> p_old_wince_flag)
      THEN
         l_wince_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_soft_bound_flag IS NULL
                  AND p_old_soft_bound_flag IS NULL))
         AND (  p_new_soft_bound_flag IS NULL
             OR p_old_soft_bound_flag IS NULL
             OR p_new_soft_bound_flag <> p_old_soft_bound_flag)
      THEN
         l_soft_bound_chan_flag := 'Y';
      END IF;

      IF     (NOT (   p_new_not_flag IS NULL
                  AND p_old_not_flag IS NULL))
         AND (  p_new_not_flag IS NULL
             OR p_old_not_flag IS NULL
             OR p_new_not_flag <> p_old_not_flag)
      THEN
         l_not_chan_flag := 'Y';
      END IF;

      --dbms_output.put_line(' after flags changed  ');


      -- ---------------------------------------
      -- Call to Table Handler
      -- ---------------------------------------
      IF    l_address_chan_flag = 'Y'
         OR l_status_chan_flag = 'Y'
         OR l_bound_chan_flag = 'Y'
         OR l_costs_chan_flag = 'Y'
         OR l_currency_code_chan_flag = 'Y'
         OR l_customer_id_chan_flag = 'Y'
         OR l_cust_account_chan_flag = 'Y'
         OR l_duration_chan_flag = 'Y'
         OR l_duration_uom_chan_flag = 'Y'
         OR l_workflow_chan_flag = 'Y'
         OR l_billable_chan_flag = 'Y'
         OR l_device1_chan_flag = 'Y'
         OR l_not_period_chan_flag = 'Y'
         OR l_not_period_uom_chan_flag = 'Y'
         OR l_owner_id_chan_flag = 'Y'
         OR l_owner_type_code_chan_flag = 'Y'
         OR l_parent_task_id_chan_flag = 'Y'
         OR l_per_complete_chan_flag = 'Y'
         OR l_planned_effort_chan_flag = 'Y'
         OR l_planned_effort_uom_chan_flag = 'Y'
         OR l_planned_end_date_chan_flag = 'Y'
         OR l_planned_start_date_chan_flag = 'Y'
         OR l_reason_code_chan_flag = 'Y'
         OR l_recurrence_rule_id_chan_flag = 'Y'
         OR l_sched_end_date_chan_flag = 'Y'
         OR l_sched_start_date_chan_flag = 'Y'
         OR l_src_obj_id_chan_flag = 'Y'
         OR l_src_obj_name_chan_flag = 'Y'
         OR l_src_obj_type_code_chan_flag = 'Y'
         OR l_task_priority_id_chan_flag = 'Y'
         OR l_task_status_id_chan_flag = 'Y'
         OR l_task_type_id_chan_flag = 'Y'
         OR l_timezone_id_chan_flag = 'Y'
         OR l_not_chan_flag = 'Y'
         OR l_palm_chan_flag = 'Y'
         OR l_private_chan_flag = 'Y'
         OR l_publish_chan_flag = 'Y'
         OR l_restrict_closure_chan_flag = 'Y'
         OR l_wince_chan_flag = 'Y'
         OR l_soft_bound_chan_flag = 'Y'
         OR l_billable_chan_flag = 'Y'
         OR l_device1_chan_flag = 'Y'
         OR l_device2_chan_flag = 'Y'
         OR l_device3_chan_flag = 'Y'
         OR l_esc_chan_flag = 'Y'
         OR l_holiday_chan_flag = 'Y'
         OR l_laptop_chan_flag = 'Y'
         OR l_milestone_chan_flag = 'Y'
         OR l_multi_booked_chan_flag = 'Y'
         OR l_task_name_chan_flag = 'Y'
         OR l_owner_territory_id_chan_flag = 'Y'
         OR l_escalation_level_chan_flag = 'Y'
         OR l_description_chan_flag = 'Y'
         OR l_date_selected_chan_flag = 'Y'
      THEN


         OPEN c_audit;

         FETCH c_audit INTO l_task_audit_id;

         CLOSE c_audit;

         jtf_task_audits_pvt.insert_row (
            x_rowid => l_rowid,
            x_task_audit_id => l_task_audit_id,
            x_new_notification_period => l_new_not_period,
            x_old_notification_period_uom => l_old_not_period,
            x_new_notification_period_uom => l_new_not_period_uom,
            x_old_parent_task_id => l_old_parent_task_id,
            x_new_parent_task_id => l_new_parent_task_id,
            x_old_recurrence_rule_id => l_old_recurrence_rule_id,
            x_new_recurrence_rule_id => l_new_recurrence_rule_id,
            x_palm_changed_flag => l_palm_chan_flag,
            x_wince_changed_flag => l_wince_chan_flag,
            x_laptop_changed_flag => l_laptop_chan_flag,
            x_device1_changed_flag => l_device1_chan_flag,
            x_device2_changed_flag => l_device2_chan_flag,
            x_device3_changed_flag => l_device3_chan_flag,
            x_old_currency_code => l_old_currency_code,
            x_new_currency_code => l_new_currency_code,
            x_old_costs => l_old_costs,
            x_new_costs => l_new_costs,
            x_task_id => l_task_id,
            x_old_task_type_id => l_old_task_type_id,
            x_new_task_type_id => l_new_task_type_id,
            x_old_task_status_id => l_old_task_status_id,
            x_new_task_status_id => l_new_task_status_id,
            x_old_task_priority_id => l_old_task_priority_id,
            x_new_task_priority_id => l_new_task_priority_id,
            x_old_owner_id => l_old_owner_id,
            x_new_owner_id => l_new_owner_id,
            x_old_owner_type_code => l_old_owner_type_code,
            x_new_owner_type_code => l_new_owner_type_code,
            x_old_assigned_by_id => l_old_assigned_by_id,
            x_new_assigned_by_id => l_new_assigned_by_id,
            x_old_cust_account_id => l_old_cust_account_id,
            x_new_cust_account_id => l_new_cust_account_id,
            x_old_customer_id => l_old_customer_id,
            x_new_customer_id => l_new_customer_id,
            x_old_address_id => l_old_address_id,
            x_new_address_id => l_new_address_id,
            x_old_planned_start_date => l_old_planned_start_date,
            x_new_planned_start_date => l_new_planned_start_date,
            x_old_planned_end_date => l_old_planned_end_date,
            x_new_planned_end_date => l_new_planned_end_date,
            x_old_scheduled_start_date => l_old_sched_start_date,
            x_new_scheduled_start_date => l_new_sched_start_date,
            x_old_scheduled_end_date => l_old_sched_end_date,
            x_new_scheduled_end_date => l_new_sched_end_date,
            x_old_actual_start_date => l_old_actual_start_date,
            x_new_actual_start_date => l_new_actual_start_date,
            x_old_actual_end_date => l_old_actual_end_date,
            x_new_actual_end_date => l_new_actual_end_date,
            x_old_source_object_type_code => l_old_src_obj_type_code,
            x_new_source_object_type_code => l_new_src_obj_type_code,
            x_old_timezone_id => l_old_timezone_id,
            x_new_timezone_id => l_new_timezone_id,
            x_old_source_object_id => l_old_src_obj_id,
            x_new_source_object_id => l_new_src_obj_id,
            x_old_source_object_name => l_old_src_obj_name,
            x_new_source_object_name => l_new_src_obj_name,
            x_old_duration => l_old_duration,
            x_new_duration => l_new_duration,
            x_old_duration_uom => l_old_duration_uom,
            x_new_duration_uom => l_new_duration_uom,
            x_old_planned_effort => l_old_planned_effort,
            x_new_planned_effort => l_new_planned_effort,
            x_old_planned_effort_uom => l_old_planned_effort_uom,
            x_new_planned_effort_uom => l_new_planned_effort_uom,
            x_old_actual_effort => l_old_actual_effort,
            x_new_actual_effort => l_new_actual_effort,
            x_old_actual_effort_uom => l_old_actual_effort_uom,
            x_new_actual_effort_uom => l_new_actual_effort_uom,
            x_old_percentage_complete => l_old_per_complete,
            x_new_percentage_complete => l_new_per_complete,
            x_old_reason_code => l_old_reason_code,
            x_new_reason_code => l_new_reason_code,
            x_private_changed_flag => l_private_chan_flag,
            x_publish_changed_flag => l_publish_chan_flag,
            x_restrict_closure_change_flag => l_restrict_closure_chan_flag,
            x_multi_booked_changed_flag => l_multi_booked_chan_flag,
            x_milestone_changed_flag => l_milestone_chan_flag,
            x_holiday_changed_flag => l_holiday_chan_flag,
            x_billable_changed_flag => l_billable_chan_flag,
            x_old_bound_mode_code => l_old_bound_mode_code,
            x_new_bound_mode_code => l_new_bound_mode_code,
            x_soft_bound_changed_flag => l_soft_bound_chan_flag,
            x_old_workflow_process_id => l_old_workflow_process_id,
            x_new_workflow_process_id => l_new_workflow_process_id,
            x_notification_changed_flag => l_not_chan_flag,
            x_old_notification_period => l_old_not_period,
            x_old_task_name => l_old_task_name,
            x_new_task_name => l_new_task_name,
            x_old_description => l_old_description,
            x_new_description => l_new_description,
            x_creation_date => SYSDATE,
            x_created_by => jtf_task_utl.created_by,
            x_last_update_date => SYSDATE,
            x_last_updated_by => jtf_task_utl.updated_by,
            x_last_update_login => jtf_task_utl.login_id,
            x_object_version_number => p_object_version_number ,
            x_old_owner_territory_id => l_old_owner_territory_id,
            x_new_owner_territory_id => l_new_owner_territory_id,
            x_new_escalation_level => l_new_escalation_level,
            x_old_escalation_level => l_old_escalation_level,
            x_new_date_selected => l_new_date_selected,
            x_old_date_selected => l_old_date_selected,
            x_new_location_id => l_new_location_id,
            x_old_location_id => l_old_location_id
         );

         OPEN ta_cur1 (l_rowid);
         FETCH ta_cur1 INTO x;

         IF ta_cur1%NOTFOUND
         THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         ELSE
            NULL;
         END IF;

         x_task_audit_id := l_task_audit_id ;

      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;


      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO process_task_audit_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO process_task_audit_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO process_task_audit_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

   PROCEDURE create_task_audits (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number       IN       NUMBER,
      p_task_id                     IN       NUMBER,
      p_new_billable_flag           IN       VARCHAR2 DEFAULT NULL,
      p_new_device1_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_device2_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_device3_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_esc_flag                IN       VARCHAR2 DEFAULT NULL,
      p_new_holiday_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_laptop_flag             IN       VARCHAR2 DEFAULT NULL,
      p_new_milestone_flag          IN       VARCHAR2 DEFAULT NULL,
      p_new_multi_booked_flag       IN       VARCHAR2 DEFAULT NULL,
      p_new_not_flag                IN       VARCHAR2 DEFAULT NULL,
      p_new_palm_flag               IN       VARCHAR2 DEFAULT NULL,
      p_new_private_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_publish_flag            IN       VARCHAR2 DEFAULT NULL,
      p_new_restrict_closure_flag   IN       VARCHAR2 DEFAULT NULL,
      p_new_wince_flag              IN       VARCHAR2 DEFAULT NULL,
      p_new_soft_bound_flag         IN       VARCHAR2 DEFAULT NULL,
      p_new_actual_effort           IN       NUMBER DEFAULT NULL,
      p_new_actual_effort_uom       IN       VARCHAR2 DEFAULT NULL,
      p_new_actual_end_date         IN       DATE DEFAULT NULL,
      p_new_actual_start_date       IN       DATE DEFAULT NULL,
      p_new_address_id              IN       NUMBER DEFAULT NULL,
      p_new_assigned_by_id          IN       NUMBER DEFAULT NULL,
      p_new_bound_mode_code         IN       VARCHAR2 DEFAULT NULL,
      p_new_costs                   IN       NUMBER DEFAULT NULL,
      p_new_currency_code           IN       VARCHAR2 DEFAULT NULL,
      p_new_customer_id             IN       NUMBER DEFAULT NULL,
      p_new_cust_account_id         IN       NUMBER DEFAULT NULL,
      p_new_duration                IN       NUMBER DEFAULT NULL,
      p_new_duration_uom            IN       VARCHAR2 DEFAULT NULL,
      p_new_esc_owner_id            IN       NUMBER DEFAULT NULL,
      p_new_esc_terr_id             IN       NUMBER DEFAULT NULL,
      p_new_not_period              IN       NUMBER DEFAULT NULL,
      p_new_not_period_uom          IN       VARCHAR2 DEFAULT NULL,
      p_new_org_id                  IN       NUMBER DEFAULT NULL,
      p_new_owner_id                IN       NUMBER DEFAULT NULL,
      p_new_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
      p_new_parent_task_id          IN       NUMBER DEFAULT NULL,
      p_new_per_complete            IN       NUMBER DEFAULT NULL,
      p_new_planned_effort          IN       NUMBER DEFAULT NULL,
      p_new_planned_effort_uom      IN       VARCHAR2 DEFAULT NULL,
      p_new_planned_end_date        IN       DATE DEFAULT NULL,
      p_new_planned_start_date      IN       DATE DEFAULT NULL,
      p_new_reason_code             IN       VARCHAR2 DEFAULT NULL,
      p_new_recurrence_rule_id      IN       NUMBER DEFAULT NULL,
      p_new_sched_end_date          IN       DATE DEFAULT NULL,
      p_new_sched_start_date        IN       DATE DEFAULT NULL,
      p_new_src_obj_id              IN       NUMBER DEFAULT NULL,
      p_new_src_obj_name            IN       VARCHAR2 DEFAULT NULL,
      p_new_src_obj_type_code       IN       VARCHAR2 DEFAULT NULL,
      p_new_task_priority_id        IN       NUMBER DEFAULT NULL,
      p_new_task_status_id          IN       NUMBER DEFAULT NULL,
      p_new_task_type_id            IN       NUMBER DEFAULT NULL,
      p_new_timezone_id             IN       NUMBER DEFAULT NULL,
      p_new_workflow_process_id     IN       NUMBER DEFAULT NULL,
      p_not_chan_flag               IN       VARCHAR2 DEFAULT NULL,
      p_new_description             IN       VARCHAR2 DEFAULT NULL,
      p_new_task_name               IN       VARCHAR2 DEFAULT NULL,
      p_new_escalation_level        IN       VARCHAR2 DEFAULT NULL,
      p_new_owner_territory_id      IN       NUMBER DEFAULT NULL,
      p_new_date_selected           IN       VARCHAR2 DEFAULT NULL,
      p_new_location_id             IN       NUMBER   DEFAULT NULL,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_task_audit_id               OUT NOCOPY     NUMBER
   )
   IS
      l_api_name           CONSTANT VARCHAR2(30)    := 'JTF_TASK_AUDITS_PVT';
      l_api_version        CONSTANT NUMBER          := 1.0;
      l_rowid                       ROWID;
      l_init_msg_list               VARCHAR2(10)    := fnd_api.g_false;
      l_commit                      VARCHAR2(10)    := fnd_api.g_false;
      l_last_update_date            DATE            := SYSDATE;
      l_last_updated_by             NUMBER          := -1;
      l_creation_date               DATE            := SYSDATE;
      l_task_audit_id               NUMBER;
      l_new_actual_effort           NUMBER          := p_new_actual_effort;
      l_new_actual_effort_uom       VARCHAR2(3)     := p_new_actual_effort_uom;
      l_new_actual_end_date         DATE            := p_new_actual_end_date;
      l_new_actual_start_date       DATE            := p_new_actual_start_date;
      l_new_address_id              NUMBER          := p_new_address_id;
      l_new_assigned_by_id          NUMBER          := p_new_assigned_by_id;
      l_new_bound_mode_code         VARCHAR2(30)    := p_new_bound_mode_code;
      l_new_costs                   NUMBER          := p_new_costs;
      l_new_currency_code           VARCHAR2(15)    := p_new_currency_code;
      l_new_customer_id             NUMBER          := p_new_customer_id;
      l_new_cust_account_id         NUMBER          := p_new_cust_account_id;
      l_new_duration                NUMBER          := p_new_duration;
      l_new_duration_uom            VARCHAR2(3)     := p_new_duration_uom;
      l_new_esc_owner_id            NUMBER          := p_new_esc_owner_id;
      l_new_esc_terr_id             NUMBER          := p_new_esc_terr_id;
      l_new_not_period              NUMBER          := p_new_not_period;
      l_new_not_period_uom          VARCHAR2(3)     := p_new_not_period_uom;
      l_new_org_id                  NUMBER          := p_new_org_id;
      l_new_owner_id                NUMBER          := p_new_owner_id;
      l_new_owner_type_code         VARCHAR2(30)    := p_new_owner_type_code;
      l_new_parent_task_id          NUMBER          := p_new_parent_task_id;
      l_new_per_complete            NUMBER          := p_new_per_complete;
      l_new_planned_effort          NUMBER          := p_new_planned_effort;
      l_new_planned_effort_uom      VARCHAR2(3)     := p_new_planned_effort_uom;
      l_new_planned_end_date        DATE            := p_new_planned_end_date;
      l_new_planned_start_date      DATE            := p_new_planned_start_date;
      l_new_reason_code             VARCHAR2(30)    := p_new_reason_code;
      l_new_recurrence_rule_id      NUMBER          := p_new_recurrence_rule_id;
      l_new_sched_end_date          DATE            := p_new_sched_end_date;
      l_new_sched_start_date        DATE            := p_new_sched_start_date;
      l_new_src_obj_id              NUMBER          := p_new_src_obj_id;
      l_new_src_obj_name            VARCHAR2(80)    := p_new_src_obj_name;
      l_new_src_obj_type_code       VARCHAR2(30)    := p_new_src_obj_type_code;
      l_new_task_priority_id        NUMBER          := p_new_task_priority_id;
      l_new_task_status_id          NUMBER          := p_new_task_status_id;
      l_new_task_type_id            NUMBER          := p_new_task_type_id;
      l_new_timezone_id             NUMBER          := p_new_timezone_id;
      l_new_workflow_process_id     NUMBER          := p_new_workflow_process_id;
      l_new_description             VARCHAR2(4000)  := p_new_description;
      l_new_task_name               VARCHAR2(80)    := p_new_task_name;
      l_new_billable_flag           VARCHAR2(1)     := p_new_billable_flag;
      l_new_device1_flag            VARCHAR2(1)     := p_new_device1_flag;
      l_new_device2_flag            VARCHAR2(1)     := p_new_device2_flag;
      l_new_device3_flag            VARCHAR2(1)     := p_new_device3_flag;
      l_new_esc_flag                VARCHAR2(1)     := p_new_esc_flag;
      l_new_holiday_flag            VARCHAR2(1)     := p_new_holiday_flag;
      l_new_laptop_flag             VARCHAR2(1)     := p_new_laptop_flag;
      l_new_milestone_flag          VARCHAR2(1)     := p_new_milestone_flag;
      l_new_multi_booked_flag       VARCHAR2(1)     := p_new_multi_booked_flag;
      l_new_not_flag                VARCHAR2(1)     := p_new_not_flag;
      l_new_palm_flag               VARCHAR2(1)     := p_new_palm_flag;
      l_new_private_flag            VARCHAR2(1)     := p_new_private_flag;
      l_new_publish_flag            VARCHAR2(1)     := p_new_publish_flag;
      l_new_restrict_closure_flag   VARCHAR2(1)     := p_new_restrict_closure_flag;
      l_new_wince_flag              VARCHAR2(1)     := p_new_wince_flag;
      l_new_soft_bound_flag         VARCHAR2(1)     := p_new_soft_bound_flag;
      l_object_version_number       NUMBER          := p_object_version_number;
      l_new_owner_territory_id      NUMBER          := p_new_owner_territory_id;
      l_new_escalation_level        VARCHAR2(30)    := p_new_escalation_level;
      l_new_date_selected           VARCHAR2(1)     := p_new_date_selected;
      l_new_location_id             NUMBER          := p_new_location_id;
      l_old_description             VARCHAR2(4000);
      l_old_billable_flag           VARCHAR2(1);
      l_old_device1_flag            VARCHAR2(1);
      l_old_device2_flag            VARCHAR2(1);
      l_old_device3_flag            VARCHAR2(1);
      l_old_esc_flag                VARCHAR2(1);
      l_old_holiday_flag            VARCHAR2(1);
      l_old_laptop_flag             VARCHAR2(1);
      l_old_milestone_flag          VARCHAR2(1);
      l_old_multi_booked_flag       VARCHAR2(1);
      l_old_not_flag                VARCHAR2(1);
      l_old_palm_flag               VARCHAR2(1);
      l_old_private_flag            VARCHAR2(1);
      l_old_publish_flag            VARCHAR2(1);
      l_old_restrict_closure_flag   VARCHAR2(1);
      l_old_wince_flag              VARCHAR2(1);
      l_old_soft_bound_flag         VARCHAR2(1);
      l_old_actual_effort           NUMBER;
      l_old_actual_effort_uom       VARCHAR2(3);
      l_old_actual_end_date         DATE;
      l_old_actual_start_date       DATE;
      l_old_address_id              NUMBER;
      l_old_assigned_by_id          NUMBER;
      l_old_bound_mode_code         VARCHAR2(30);
      l_old_costs                   NUMBER;
      l_old_currency_code           VARCHAR2(15);
      l_old_customer_id             NUMBER;
      l_old_cust_account_id         NUMBER;
      l_old_duration                NUMBER;
      l_old_duration_uom            VARCHAR2(3);
      l_old_esc_owner_id            NUMBER;
      l_old_esc_terr_id             NUMBER;
      l_old_not_period              NUMBER;
      l_old_not_period_uom          VARCHAR2(3);
      l_old_org_id                  NUMBER;
      l_old_owner_id                NUMBER;
      l_old_owner_type_code         VARCHAR2(30);
      l_old_parent_task_id          NUMBER;
      l_old_per_complete            NUMBER;
      l_old_planned_effort          NUMBER;
      l_old_planned_effort_uom      VARCHAR2(3);
      l_old_planned_end_date        DATE;
      l_old_planned_start_date      DATE;
      l_old_reason_code             VARCHAR2(30);
      l_old_recurrence_rule_id      NUMBER;
      l_old_sched_end_date          DATE;
      l_old_sched_start_date        DATE;
      l_old_src_obj_id              NUMBER;
      l_old_src_obj_name            VARCHAR2(80);
      l_old_src_obj_type_code       VARCHAR2(30);
      l_old_task_priority_id        NUMBER;
      l_old_task_status_id          NUMBER;
      l_old_task_type_id            NUMBER;
      l_old_timezone_id             NUMBER;
      l_old_workflow_process_id     NUMBER;
      l_old_task_name               VARCHAR2(80);
      l_old_owner_territory_id      NUMBER;
      l_old_escalation_level        VARCHAR2(5);
      l_old_date_selected           VARCHAR2(1);
      l_old_location_id             NUMBER;
      x                             CHAR;
      l_creation_date               DATE;
      l_created_by                  NUMBER(15);
      l_last_update_date            DATE;
      x_commit                      VARCHAR2(1);
      l_last_updated_by             NUMBER(15);
      l_last_update_login           NUMBER(15);
      l_not_chan_flag               CHAR(1)         := 'N';

      CURSOR ta_cur1 (l_rowid IN ROWID)
      IS
         SELECT 1
           FROM jtf_task_audits_b
          WHERE ROWID = l_rowid;

      CURSOR tsk_aud (p_task_id IN NUMBER)
      IS
         SELECT attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute_category,
                task_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                task_number,
                task_type_id,
                task_status_id,
                task_priority_id,
                owner_id,
                owner_type_code,
                assigned_by_id,
                cust_account_id,
                customer_id,
                address_id,
                planned_start_date,
                palm_flag,
                wince_flag,
                laptop_flag,
                device1_flag,
                device2_flag,
                device3_flag,
                costs,
                currency_code,
                attribute1,
                attribute2,
                attribute3,
                notification_period,
                notification_period_uom,
                parent_task_id,
                recurrence_rule_id,
                alarm_start,
                alarm_start_uom,
                alarm_on,
                alarm_count,
                alarm_fired_count,
                alarm_interval,
                alarm_interval_uom,
                deleted_flag,
                actual_start_date,
                actual_end_date,
                source_object_type_code,
                timezone_id,
                source_object_id,
                source_object_name,
                duration,
                duration_uom,
                planned_effort,
                planned_effort_uom,
                actual_effort,
                actual_effort_uom,
                percentage_complete,
                reason_code,
                private_flag,
                publish_flag,
                restrict_closure_flag,
                multi_booked_flag,
                milestone_flag,
                holiday_flag,
                billable_flag,
                bound_mode_code,
                soft_bound_flag,
                workflow_process_id,
                notification_flag,
                planned_end_date,
                scheduled_start_date,
                scheduled_end_date,
                task_name,
                description,
                object_version_number,
                owner_territory_id,
                escalation_level,
                date_selected,
		    location_id
           FROM jtf_tasks_vl
          WHERE task_id = p_task_id;

      CURSOR c_audit
      IS
         SELECT jtf_task_audits_s.nextval
           FROM dual;

      aud_rec                       tsk_aud%ROWTYPE;
   BEGIN
      SAVEPOINT process_task_audit_pvt;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      OPEN tsk_aud (p_task_id);

      --dbms_output.put_line(' opening cursor....');

      FETCH tsk_aud INTO aud_rec;
      IF tsk_aud%notfound THEN
        l_old_description := NULL;
        l_old_billable_flag := NULL;
        l_old_device1_flag := NULL;
        l_old_device2_flag := NULL;
        l_old_device3_flag := NULL;
        l_old_esc_flag := NULL;
        l_old_holiday_flag := NULL;
        l_old_laptop_flag := NULL;
        l_old_milestone_flag := NULL;
        l_old_multi_booked_flag := NULL;
        l_old_not_flag := NULL;
        l_old_palm_flag := NULL;
        l_old_private_flag := NULL;
        l_old_publish_flag := NULL;
        l_old_restrict_closure_flag := NULL;
        l_old_wince_flag := NULL;
        l_old_soft_bound_flag := NULL;
        l_old_actual_effort := NULL;
        l_old_actual_effort_uom := NULL;
        l_old_actual_end_date := NULL;
        l_old_actual_start_date := NULL;
        l_old_address_id := NULL;
        l_old_assigned_by_id := NULL;
        l_old_bound_mode_code := NULL;
        l_old_costs := NULL;
        l_old_currency_code := NULL;
        l_old_customer_id := NULL;
        l_old_cust_account_id := NULL;
        l_old_duration := NULL;
        l_old_duration_uom := NULL;
        l_old_esc_owner_id := NULL;
        l_old_esc_owner_id := NULL;
        l_old_esc_terr_id := NULL;
        l_old_not_period := NULL;
        l_old_not_period_uom := NULL;
        l_old_owner_id := NULL;
        l_old_owner_type_code := NULL;
        l_old_parent_task_id := NULL;
        l_old_per_complete := NULL;
        l_old_planned_effort := NULL;
        l_old_planned_effort_uom := NULL;
        l_old_planned_end_date := NULL;
        l_old_planned_start_date := NULL;
        l_old_reason_code := NULL;
        l_old_recurrence_rule_id := NULL;
        l_old_sched_end_date := NULL;
        l_old_sched_start_date := NULL;
        l_old_src_obj_id := NULL;
        l_old_src_obj_name := NULL;
        l_old_src_obj_type_code := NULL;
        l_old_task_priority_id := NULL;
        l_old_task_status_id := NULL;
        l_old_task_type_id := NULL;
        l_old_timezone_id := NULL;
        l_old_workflow_process_id := NULL;
        l_old_task_name := NULL;
        l_old_owner_territory_id := NULL;
        l_old_escalation_level := NULL;
        l_old_date_selected := NULL;
        l_old_location_id := NULL;
      ELSE
        l_old_description := aud_rec.description;
        l_old_billable_flag := aud_rec.billable_flag;
        l_old_device1_flag := aud_rec.device1_flag;
        l_old_device2_flag := aud_rec.device2_flag;
        l_old_device3_flag := aud_rec.device3_flag;
        l_old_esc_flag := NULL;
        l_old_holiday_flag := aud_rec.holiday_flag;
        l_old_laptop_flag := aud_rec.laptop_flag;
        l_old_milestone_flag := aud_rec.milestone_flag;
        l_old_multi_booked_flag := aud_rec.multi_booked_flag;
        l_old_not_flag := aud_rec.notification_flag;
        l_old_palm_flag := aud_rec.palm_flag;
        l_old_private_flag := aud_rec.private_flag;
        l_old_publish_flag := aud_rec.publish_flag;
        l_old_restrict_closure_flag := aud_rec.restrict_closure_flag;
        l_old_wince_flag := aud_rec.wince_flag;
        l_old_soft_bound_flag := aud_rec.soft_bound_flag;
        l_old_actual_effort := aud_rec.actual_effort;
        l_old_actual_effort_uom := aud_rec.actual_effort_uom;
        l_old_actual_end_date := aud_rec.actual_end_date;
        l_old_actual_start_date := aud_rec.actual_start_date;
        l_old_address_id := aud_rec.address_id;
        l_old_assigned_by_id := aud_rec.assigned_by_id;
        l_old_bound_mode_code := aud_rec.bound_mode_code;
        l_old_costs := aud_rec.costs;
        l_old_currency_code := aud_rec.currency_code;
        l_old_customer_id := aud_rec.customer_id;
        l_old_cust_account_id := aud_rec.cust_account_id;
        l_old_duration := aud_rec.duration;
        l_old_duration_uom := aud_rec.duration_uom;
        l_old_esc_owner_id := aud_rec.owner_id;
        l_old_esc_owner_id := NULL;
        l_old_esc_terr_id := aud_rec.owner_territory_id;
        l_old_not_period := aud_rec.notification_period;
        l_old_not_period_uom := aud_rec.notification_period_uom;
        l_old_owner_id := aud_rec.owner_id;
        l_old_owner_type_code := aud_rec.owner_type_code;
        l_old_parent_task_id := aud_rec.parent_task_id;
        l_old_per_complete := aud_rec.percentage_complete;
        l_old_planned_effort := aud_rec.planned_effort;
        l_old_planned_effort_uom := aud_rec.planned_effort_uom;
        l_old_planned_end_date := aud_rec.planned_end_date;
        l_old_planned_start_date := aud_rec.planned_start_date;
        l_old_reason_code := aud_rec.reason_code;
        l_old_recurrence_rule_id := aud_rec.recurrence_rule_id;
        l_old_sched_end_date := aud_rec.scheduled_end_date;
        l_old_sched_start_date := aud_rec.scheduled_start_date;
        l_old_src_obj_id := aud_rec.source_object_id;
        l_old_src_obj_name := aud_rec.source_object_name;
        l_old_src_obj_type_code := aud_rec.source_object_type_code;
        l_old_task_priority_id := aud_rec.task_priority_id;
        l_old_task_status_id := aud_rec.task_status_id;
        l_old_task_type_id := aud_rec.task_type_id;
        l_old_timezone_id := aud_rec.timezone_id;
        l_old_workflow_process_id := aud_rec.workflow_process_id;
        l_old_task_name := aud_rec.task_name;
        l_old_owner_territory_id := aud_rec.owner_territory_id;
        l_old_escalation_level := aud_rec.escalation_level;
        l_old_date_selected := aud_rec.date_selected;
        l_old_location_id := aud_rec.location_id;
      END IF;
      CLOSE tsk_aud;

      --dbms_output.put_line(' calling process tasks...... ');
      jtf_task_audits_pvt.process_task_audits (
         p_api_version => 1.0,
         p_init_msg_list => fnd_api.g_false,
         p_commit => fnd_api.g_false,
         p_object_version_number => p_object_version_number ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         p_old_billable_flag => l_old_billable_flag,
         p_old_device1_flag => l_old_device1_flag,
         p_old_device2_flag => l_old_device2_flag,
         p_old_device3_flag => l_old_device3_flag,
         p_old_esc_flag => l_old_esc_flag,
         p_old_holiday_flag => l_old_holiday_flag,
         p_old_laptop_flag => l_old_laptop_flag,
         p_old_milestone_flag => l_old_milestone_flag,
         p_old_multi_booked_flag => l_old_multi_booked_flag,
         p_old_not_flag => l_old_not_flag,
         p_old_palm_flag => l_old_palm_flag,
         p_old_private_flag => l_old_private_flag,
         p_old_publish_flag => l_old_publish_flag,
         p_old_restrict_closure_flag => l_old_restrict_closure_flag,
         p_old_wince_flag => l_old_wince_flag,
         p_old_soft_bound_flag => l_old_soft_bound_flag,
         p_new_billable_flag => l_new_billable_flag,
         p_new_device1_flag => l_new_device1_flag,
         p_new_device2_flag => l_new_device2_flag,
         p_new_device3_flag => l_new_device3_flag,
         p_new_esc_flag => l_new_esc_flag,
         p_new_holiday_flag => l_new_holiday_flag,
         p_new_laptop_flag => l_new_laptop_flag,
         p_new_milestone_flag => l_new_milestone_flag,
         p_new_multi_booked_flag => l_new_multi_booked_flag,
         p_new_not_flag => l_new_not_flag,
         p_new_palm_flag => l_new_palm_flag,
         p_new_private_flag => l_new_private_flag,
         p_new_publish_flag => l_new_publish_flag,
         p_new_restrict_closure_flag => l_new_restrict_closure_flag,
         p_new_wince_flag => l_new_wince_flag,
         p_new_soft_bound_flag => l_new_soft_bound_flag,
         p_new_actual_effort => l_new_actual_effort,
         p_new_actual_effort_uom => l_new_actual_effort_uom,
         p_new_actual_end_date => l_new_actual_end_date,
         p_new_actual_start_date => l_new_actual_start_date,
         p_new_address_id => l_new_address_id,
         p_new_assigned_by_id => l_new_assigned_by_id,
         p_new_bound_mode_code => l_new_bound_mode_code,
         p_new_costs => l_new_costs,
         p_new_currency_code => l_new_currency_code,
         p_new_customer_id => l_new_customer_id,
         p_new_cust_account_id => l_new_cust_account_id,
         p_new_duration => l_new_duration,
         p_new_duration_uom => l_new_duration_uom,
         p_new_esc_owner_id => l_new_esc_owner_id,
         p_new_esc_terr_id => l_new_esc_terr_id,
         p_new_not_period => l_new_not_period,
         p_new_not_period_uom => l_new_not_period_uom,
         p_new_org_id => l_new_org_id,
         p_new_owner_id => l_new_owner_id,
         p_new_owner_type_code => l_new_owner_type_code,
         p_new_parent_task_id => l_new_parent_task_id,
         p_new_per_complete => l_new_per_complete,
         p_new_planned_effort => l_new_planned_effort,
         p_new_planned_effort_uom => l_new_planned_effort_uom,
         p_new_planned_end_date => l_new_planned_end_date,
         p_new_planned_start_date => l_new_planned_start_date,
         p_new_reason_code => l_new_reason_code,
         p_new_recurrence_rule_id => l_new_recurrence_rule_id,
         p_new_sched_end_date => l_new_sched_end_date,
         p_new_sched_start_date => l_new_sched_start_date,
         p_new_src_obj_id => l_new_src_obj_id,
         p_new_src_obj_name => l_new_src_obj_name,
         p_new_src_obj_type_code => l_new_src_obj_type_code,
         p_new_task_priority_id => l_new_task_priority_id,
         p_new_task_status_id => l_new_task_status_id,
         p_new_task_type_id => l_new_task_type_id,
         p_new_timezone_id => l_new_timezone_id,
         p_new_workflow_process_id => l_new_workflow_process_id,
         p_not_chan_flag => l_not_chan_flag,
         p_old_actual_effort => l_old_actual_effort,
         p_old_actual_effort_uom => l_old_actual_effort_uom,
         p_old_actual_end_date => l_old_actual_end_date,
         p_old_actual_start_date => l_old_actual_start_date,
         p_old_address_id => l_old_address_id,
         p_old_assigned_by_id => l_old_assigned_by_id,
         p_old_bound_mode_code => l_old_bound_mode_code,
         p_old_costs => l_old_costs,
         p_old_currency_code => l_old_currency_code,
         p_old_customer_id => l_old_customer_id,
         p_old_cust_account_id => l_old_cust_account_id,
         p_old_duration => l_old_duration,
         p_old_duration_uom => l_old_duration_uom,
         p_old_esc_owner_id => NULL,
         p_old_esc_terr_id => l_old_esc_terr_id,
         p_old_not_period => l_old_not_period,
         p_old_not_period_uom => l_old_not_period_uom,
         p_old_org_id => NULL,
         p_old_owner_id => l_old_owner_id,
         p_old_owner_type_code => l_old_owner_type_code,
         p_old_parent_task_id => l_old_parent_task_id,
         p_old_per_complete => l_old_per_complete,
         p_old_planned_effort => l_old_planned_effort,
         p_old_planned_effort_uom => l_old_planned_effort_uom,
         p_old_planned_end_date => l_old_planned_end_date,
         p_old_planned_start_date => l_old_planned_start_date,
         p_old_reason_code => l_old_reason_code,
         p_old_recurrence_rule_id => l_old_recurrence_rule_id,
         p_old_sched_end_date => l_old_sched_end_date,
         p_old_sched_start_date => l_old_sched_start_date,
         p_old_src_obj_id => l_old_src_obj_id,
         p_old_src_obj_name => l_old_src_obj_name,
         p_old_src_obj_type_code => l_old_src_obj_type_code,
         p_old_task_priority_id => l_old_task_priority_id,
         p_old_task_status_id => l_old_task_status_id,
         p_old_task_type_id => l_old_task_type_id,
         p_old_timezone_id => l_old_timezone_id,
         p_old_workflow_process_id => l_old_workflow_process_id,
         p_task_id => p_task_id,
         p_new_description => l_new_description,
         p_new_task_name => l_new_task_name,
         p_old_description => l_old_description,
         p_old_task_name => l_old_task_name,
         p_old_escalation_level => l_old_escalation_level,
         p_new_escalation_level => l_new_escalation_level,
         p_old_owner_territory_id => l_old_owner_territory_id,
         p_new_owner_territory_id => l_new_owner_territory_id,
         p_old_date_selected => l_old_date_selected,
         p_new_date_selected => l_new_date_selected,
         p_old_location_id => l_old_location_id,
         p_new_location_id => l_new_location_id,
         x_task_audit_id => x_task_audit_id
      );

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO process_task_audit_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO process_task_audit_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS
      THEN
         ROLLBACK TO process_task_audit_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TASK_AUDIT_ID in NUMBER,
  X_NEW_NOTIFICATION_PERIOD in NUMBER,
  X_OLD_NOTIFICATION_PERIOD_UOM in VARCHAR2,
  X_NEW_NOTIFICATION_PERIOD_UOM in VARCHAR2,
  X_OLD_PARENT_TASK_ID in NUMBER,
  X_NEW_PARENT_TASK_ID in NUMBER,
  X_OLD_RECURRENCE_RULE_ID in NUMBER,
  X_NEW_RECURRENCE_RULE_ID in NUMBER,
  X_PALM_CHANGED_FLAG in VARCHAR2,
  X_WINCE_CHANGED_FLAG in VARCHAR2,
  X_LAPTOP_CHANGED_FLAG in VARCHAR2,
  X_DEVICE1_CHANGED_FLAG in VARCHAR2,
  X_DEVICE2_CHANGED_FLAG in VARCHAR2,
  X_DEVICE3_CHANGED_FLAG in VARCHAR2,
  X_OLD_CURRENCY_CODE in VARCHAR2,
  X_NEW_CURRENCY_CODE in VARCHAR2,
  X_OLD_COSTS in NUMBER,
  X_NEW_COSTS in NUMBER,
  X_TASK_ID in NUMBER,
  X_OLD_TASK_TYPE_ID in NUMBER,
  X_NEW_TASK_TYPE_ID in NUMBER,
  X_OLD_TASK_STATUS_ID in NUMBER,
  X_NEW_TASK_STATUS_ID in NUMBER,
  X_OLD_TASK_PRIORITY_ID in NUMBER,
  X_NEW_TASK_PRIORITY_ID in NUMBER,
  X_OLD_OWNER_ID in NUMBER,
  X_NEW_OWNER_ID in NUMBER,
  X_OLD_OWNER_TYPE_CODE in VARCHAR2,
  X_NEW_OWNER_TYPE_CODE in VARCHAR2,
  X_OLD_ASSIGNED_BY_ID in NUMBER,
  X_NEW_ASSIGNED_BY_ID in NUMBER,
  X_OLD_CUST_ACCOUNT_ID in NUMBER,
  X_NEW_CUST_ACCOUNT_ID in NUMBER,
  X_OLD_CUSTOMER_ID in NUMBER,
  X_NEW_CUSTOMER_ID in NUMBER,
  X_OLD_ADDRESS_ID in NUMBER,
  X_NEW_ADDRESS_ID in NUMBER,
  X_OLD_PLANNED_START_DATE in DATE,
  X_NEW_PLANNED_START_DATE in DATE,
  X_OLD_PLANNED_END_DATE in DATE,
  X_NEW_PLANNED_END_DATE in DATE,
  X_OLD_SCHEDULED_START_DATE in DATE,
  X_NEW_SCHEDULED_START_DATE in DATE,
  X_OLD_SCHEDULED_END_DATE in DATE,
  X_NEW_SCHEDULED_END_DATE in DATE,
  X_OLD_ACTUAL_START_DATE in DATE,
  X_NEW_ACTUAL_START_DATE in DATE,
  X_OLD_ACTUAL_END_DATE in DATE,
  X_NEW_ACTUAL_END_DATE in DATE,
  X_OLD_SOURCE_OBJECT_TYPE_CODE in VARCHAR2,
  X_NEW_SOURCE_OBJECT_TYPE_CODE in VARCHAR2,
  X_OLD_TIMEZONE_ID in NUMBER,
  X_NEW_TIMEZONE_ID in NUMBER,
  X_OLD_SOURCE_OBJECT_ID in NUMBER,
  X_NEW_SOURCE_OBJECT_ID in NUMBER,
  X_OLD_SOURCE_OBJECT_NAME in VARCHAR2,
  X_NEW_SOURCE_OBJECT_NAME in VARCHAR2,
  X_OLD_DURATION in NUMBER,
  X_NEW_DURATION in NUMBER,
  X_OLD_DURATION_UOM in VARCHAR2,
  X_NEW_DURATION_UOM in VARCHAR2,
  X_OLD_PLANNED_EFFORT in NUMBER,
  X_NEW_PLANNED_EFFORT in NUMBER,
  X_OLD_PLANNED_EFFORT_UOM in VARCHAR2,
  X_NEW_PLANNED_EFFORT_UOM in VARCHAR2,
  X_OLD_ACTUAL_EFFORT in NUMBER,
  X_NEW_ACTUAL_EFFORT in NUMBER,
  X_OLD_ACTUAL_EFFORT_UOM in VARCHAR2,
  X_NEW_ACTUAL_EFFORT_UOM in VARCHAR2,
  X_OLD_PERCENTAGE_COMPLETE in NUMBER,
  X_NEW_PERCENTAGE_COMPLETE in NUMBER,
  X_OLD_REASON_CODE in VARCHAR2,
  X_NEW_REASON_CODE in VARCHAR2,
  X_PRIVATE_CHANGED_FLAG in VARCHAR2,
  X_PUBLISH_CHANGED_FLAG in VARCHAR2,
  X_RESTRICT_CLOSURE_CHANGE_FLAG in VARCHAR2,
  X_MULTI_BOOKED_CHANGED_FLAG in VARCHAR2,
  X_MILESTONE_CHANGED_FLAG in VARCHAR2,
  X_HOLIDAY_CHANGED_FLAG in VARCHAR2,
  X_BILLABLE_CHANGED_FLAG in VARCHAR2,
  X_OLD_BOUND_MODE_CODE in VARCHAR2,
  X_NEW_BOUND_MODE_CODE in VARCHAR2,
  X_SOFT_BOUND_CHANGED_FLAG in VARCHAR2,
  X_OLD_WORKFLOW_PROCESS_ID in NUMBER,
  X_NEW_WORKFLOW_PROCESS_ID in NUMBER,
  X_NOTIFICATION_CHANGED_FLAG in VARCHAR2,
  X_OLD_NOTIFICATION_PERIOD in NUMBER,
  X_OLD_TASK_NAME in VARCHAR2,
  X_NEW_TASK_NAME in VARCHAR2,
  X_OLD_DESCRIPTION in VARCHAR2,
  X_NEW_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OWNER_TERRITORY_ID in NUMBER,
  X_NEW_OWNER_TERRITORY_ID in NUMBER,
  X_NEW_ESCALATION_LEVEL in VARCHAR2,
  X_OLD_ESCALATION_LEVEL in VARCHAR2,
  X_OLD_DATE_SELECTED in VARCHAR2,
  X_NEW_DATE_SELECTED in VARCHAR2,
  X_OLD_LOCATION_ID in NUMBER,
  X_NEW_LOCATION_ID in NUMBER
) is
  cursor C is select ROWID from JTF_TASK_AUDITS_B
    where TASK_AUDIT_ID = X_TASK_AUDIT_ID
    ;
    l_enable_audit    varchar2(5);
begin

  l_enable_audit := Upper(nvl(fnd_profile.Value('JTF_TASK_ENABLE_AUDIT'),'Y'));
  IF(l_enable_audit = 'N') THEN
    RETURN;
  END IF;
  insert into JTF_TASK_AUDITS_B (
    NEW_NOTIFICATION_PERIOD,
    OLD_NOTIFICATION_PERIOD_UOM,
    NEW_NOTIFICATION_PERIOD_UOM,
    OLD_PARENT_TASK_ID,
    NEW_PARENT_TASK_ID,
    OLD_RECURRENCE_RULE_ID,
    NEW_RECURRENCE_RULE_ID,
    PALM_CHANGED_FLAG,
    WINCE_CHANGED_FLAG,
    LAPTOP_CHANGED_FLAG,
    DEVICE1_CHANGED_FLAG,
    DEVICE2_CHANGED_FLAG,
    DEVICE3_CHANGED_FLAG,
    OLD_CURRENCY_CODE,
    NEW_CURRENCY_CODE,
    OLD_COSTS,
    NEW_COSTS,
    TASK_AUDIT_ID,
    TASK_ID,
    OLD_TASK_TYPE_ID,
    NEW_TASK_TYPE_ID,
    OLD_TASK_STATUS_ID,
    NEW_TASK_STATUS_ID,
    OLD_TASK_PRIORITY_ID,
    NEW_TASK_PRIORITY_ID,
    OLD_OWNER_ID,
    NEW_OWNER_ID,
    OLD_OWNER_TYPE_CODE,
    NEW_OWNER_TYPE_CODE,
    OLD_ASSIGNED_BY_ID,
    NEW_ASSIGNED_BY_ID,
    OLD_CUST_ACCOUNT_ID,
    NEW_CUST_ACCOUNT_ID,
    OLD_CUSTOMER_ID,
    NEW_CUSTOMER_ID,
    OLD_ADDRESS_ID,
    NEW_ADDRESS_ID,
    OLD_PLANNED_START_DATE,
    NEW_PLANNED_START_DATE,
    OLD_PLANNED_END_DATE,
    NEW_PLANNED_END_DATE,
    OLD_SCHEDULED_START_DATE,
    NEW_SCHEDULED_START_DATE,
    OLD_SCHEDULED_END_DATE,
    NEW_SCHEDULED_END_DATE,
    OLD_ACTUAL_START_DATE,
    NEW_ACTUAL_START_DATE,
    OLD_ACTUAL_END_DATE,
    NEW_ACTUAL_END_DATE,
    OLD_SOURCE_OBJECT_TYPE_CODE,
    NEW_SOURCE_OBJECT_TYPE_CODE,
    OLD_TIMEZONE_ID,
    NEW_TIMEZONE_ID,
    OLD_SOURCE_OBJECT_ID,
    NEW_SOURCE_OBJECT_ID,
    OLD_SOURCE_OBJECT_NAME,
    NEW_SOURCE_OBJECT_NAME,
    OLD_DURATION,
    NEW_DURATION,
    OLD_DURATION_UOM,
    NEW_DURATION_UOM,
    OLD_PLANNED_EFFORT,
    NEW_PLANNED_EFFORT,
    OLD_PLANNED_EFFORT_UOM,
    NEW_PLANNED_EFFORT_UOM,
    OLD_ACTUAL_EFFORT,
    NEW_ACTUAL_EFFORT,
    OLD_ACTUAL_EFFORT_UOM,
    NEW_ACTUAL_EFFORT_UOM,
    OLD_PERCENTAGE_COMPLETE,
    NEW_PERCENTAGE_COMPLETE,
    OLD_REASON_CODE,
    NEW_REASON_CODE,
    PRIVATE_CHANGED_FLAG,
    PUBLISH_CHANGED_FLAG,
    RESTRICT_CLOSURE_CHANGE_FLAG,
    MULTI_BOOKED_CHANGED_FLAG,
    MILESTONE_CHANGED_FLAG,
    HOLIDAY_CHANGED_FLAG,
    BILLABLE_CHANGED_FLAG,
    OLD_BOUND_MODE_CODE,
    NEW_BOUND_MODE_CODE,
    SOFT_BOUND_CHANGED_FLAG,
    OLD_WORKFLOW_PROCESS_ID,
    NEW_WORKFLOW_PROCESS_ID,
    NOTIFICATION_CHANGED_FLAG,
    OLD_NOTIFICATION_PERIOD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    OLD_OWNER_TERRITORY_ID,
    NEW_OWNER_TERRITORY_ID,
    NEW_ESCALATION_LEVEL,
    OLD_ESCALATION_LEVEL,
    NEW_DATE_SELECTED,
    OLD_DATE_SELECTED
  ) values (
    X_NEW_NOTIFICATION_PERIOD,
    X_OLD_NOTIFICATION_PERIOD_UOM,
    X_NEW_NOTIFICATION_PERIOD_UOM,
    X_OLD_PARENT_TASK_ID,
    X_NEW_PARENT_TASK_ID,
    X_OLD_RECURRENCE_RULE_ID,
    X_NEW_RECURRENCE_RULE_ID,
    X_PALM_CHANGED_FLAG,
    X_WINCE_CHANGED_FLAG,
    X_LAPTOP_CHANGED_FLAG,
    X_DEVICE1_CHANGED_FLAG,
    X_DEVICE2_CHANGED_FLAG,
    X_DEVICE3_CHANGED_FLAG,
    X_OLD_CURRENCY_CODE,
    X_NEW_CURRENCY_CODE,
    X_OLD_COSTS,
    X_NEW_COSTS,
    X_TASK_AUDIT_ID,
    X_TASK_ID,
    X_OLD_TASK_TYPE_ID,
    X_NEW_TASK_TYPE_ID,
    X_OLD_TASK_STATUS_ID,
    X_NEW_TASK_STATUS_ID,
    X_OLD_TASK_PRIORITY_ID,
    X_NEW_TASK_PRIORITY_ID,
    X_OLD_OWNER_ID,
    X_NEW_OWNER_ID,
    X_OLD_OWNER_TYPE_CODE,
    X_NEW_OWNER_TYPE_CODE,
    X_OLD_ASSIGNED_BY_ID,
    X_NEW_ASSIGNED_BY_ID,
    X_OLD_CUST_ACCOUNT_ID,
    X_NEW_CUST_ACCOUNT_ID,
    X_OLD_CUSTOMER_ID,
    X_NEW_CUSTOMER_ID,
    X_OLD_ADDRESS_ID,
    X_NEW_ADDRESS_ID,
    X_OLD_PLANNED_START_DATE,
    X_NEW_PLANNED_START_DATE,
    X_OLD_PLANNED_END_DATE,
    X_NEW_PLANNED_END_DATE,
    X_OLD_SCHEDULED_START_DATE,
    X_NEW_SCHEDULED_START_DATE,
    X_OLD_SCHEDULED_END_DATE,
    X_NEW_SCHEDULED_END_DATE,
    X_OLD_ACTUAL_START_DATE,
    X_NEW_ACTUAL_START_DATE,
    X_OLD_ACTUAL_END_DATE,
    X_NEW_ACTUAL_END_DATE,
    X_OLD_SOURCE_OBJECT_TYPE_CODE,
    X_NEW_SOURCE_OBJECT_TYPE_CODE,
    X_OLD_TIMEZONE_ID,
    X_NEW_TIMEZONE_ID,
    X_OLD_SOURCE_OBJECT_ID,
    X_NEW_SOURCE_OBJECT_ID,
    X_OLD_SOURCE_OBJECT_NAME,
    X_NEW_SOURCE_OBJECT_NAME,
    X_OLD_DURATION,
    X_NEW_DURATION,
    X_OLD_DURATION_UOM,
    X_NEW_DURATION_UOM,
    X_OLD_PLANNED_EFFORT,
    X_NEW_PLANNED_EFFORT,
    X_OLD_PLANNED_EFFORT_UOM,
    X_NEW_PLANNED_EFFORT_UOM,
    X_OLD_ACTUAL_EFFORT,
    X_NEW_ACTUAL_EFFORT,
    X_OLD_ACTUAL_EFFORT_UOM,
    X_NEW_ACTUAL_EFFORT_UOM,
    X_OLD_PERCENTAGE_COMPLETE,
    X_NEW_PERCENTAGE_COMPLETE,
    X_OLD_REASON_CODE,
    X_NEW_REASON_CODE,
    X_PRIVATE_CHANGED_FLAG,
    X_PUBLISH_CHANGED_FLAG,
    X_RESTRICT_CLOSURE_CHANGE_FLAG,
    X_MULTI_BOOKED_CHANGED_FLAG,
    X_MILESTONE_CHANGED_FLAG,
    X_HOLIDAY_CHANGED_FLAG,
    X_BILLABLE_CHANGED_FLAG,
    X_OLD_BOUND_MODE_CODE,
    X_NEW_BOUND_MODE_CODE,
    X_SOFT_BOUND_CHANGED_FLAG,
    X_OLD_WORKFLOW_PROCESS_ID,
    X_NEW_WORKFLOW_PROCESS_ID,
    X_NOTIFICATION_CHANGED_FLAG,
    X_OLD_NOTIFICATION_PERIOD,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_OLD_OWNER_TERRITORY_ID,
    X_NEW_OWNER_TERRITORY_ID,
    X_NEW_ESCALATION_LEVEL,
    X_OLD_ESCALATION_LEVEL,
    X_NEW_DATE_SELECTED,
    X_OLD_DATE_SELECTED
  );

  insert into JTF_TASK_AUDITS_TL (
    TASK_AUDIT_ID,
    OLD_TASK_NAME,
    NEW_TASK_NAME,
    OLD_DESCRIPTION,
    NEW_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TASK_AUDIT_ID,
    X_OLD_TASK_NAME,
    X_NEW_TASK_NAME,
    X_OLD_DESCRIPTION,
    X_NEW_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_TASK_AUDITS_TL T
    where T.TASK_AUDIT_ID = X_TASK_AUDIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure ADD_LANGUAGE
is
begin

  /* Solving Perf. Bug 3723927 */
     /* The following delete and update statements are commented out */
     /* as a quick workaround to fix the time-consuming table handler issue */
     /*

  delete from JTF_TASK_AUDITS_TL T
  where not exists
    (select NULL
    from JTF_TASK_AUDITS_B B
    where B.TASK_AUDIT_ID = T.TASK_AUDIT_ID
    );

  update JTF_TASK_AUDITS_TL T set (
      OLD_TASK_NAME,
      NEW_TASK_NAME,
      OLD_DESCRIPTION,
      NEW_DESCRIPTION
    ) = (select
      B.OLD_TASK_NAME,
      B.NEW_TASK_NAME,
      B.OLD_DESCRIPTION,
      B.NEW_DESCRIPTION
    from JTF_TASK_AUDITS_TL B
    where B.TASK_AUDIT_ID = T.TASK_AUDIT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_AUDIT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_AUDIT_ID,
      SUBT.LANGUAGE
    from JTF_TASK_AUDITS_TL SUBB, JTF_TASK_AUDITS_TL SUBT
    where SUBB.TASK_AUDIT_ID = SUBT.TASK_AUDIT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OLD_TASK_NAME <> SUBT.OLD_TASK_NAME
      or (SUBB.OLD_TASK_NAME is null and SUBT.OLD_TASK_NAME is not null)
      or (SUBB.OLD_TASK_NAME is not null and SUBT.OLD_TASK_NAME is null)
      or SUBB.NEW_TASK_NAME <> SUBT.NEW_TASK_NAME
      or (SUBB.NEW_TASK_NAME is null and SUBT.NEW_TASK_NAME is not null)
      or (SUBB.NEW_TASK_NAME is not null and SUBT.NEW_TASK_NAME is null)
      or SUBB.OLD_DESCRIPTION <> SUBT.OLD_DESCRIPTION
      or (SUBB.OLD_DESCRIPTION is null and SUBT.OLD_DESCRIPTION is not null)
      or (SUBB.OLD_DESCRIPTION is not null and SUBT.OLD_DESCRIPTION is null)
      or SUBB.NEW_DESCRIPTION <> SUBT.NEW_DESCRIPTION
      or (SUBB.NEW_DESCRIPTION is null and SUBT.NEW_DESCRIPTION is not null)
      or (SUBB.NEW_DESCRIPTION is not null and SUBT.NEW_DESCRIPTION is null)
  ));  */

  -- Added hint 'parallel' by SBARAT on 19/01/2006 for perf bug# 4888496

  insert into JTF_TASK_AUDITS_TL (
    SECURITY_GROUP_ID,
    TASK_AUDIT_ID,
    OLD_TASK_NAME,
    NEW_TASK_NAME,
    OLD_DESCRIPTION,
    NEW_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ parallel(B) parallel(L) */
    B.SECURITY_GROUP_ID,
    B.TASK_AUDIT_ID,
    B.OLD_TASK_NAME,
    B.NEW_TASK_NAME,
    B.OLD_DESCRIPTION,
    B.NEW_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_TASK_AUDITS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select /*+ parallel(T) */  NULL
    from JTF_TASK_AUDITS_TL T
    where T.TASK_AUDIT_ID = B.TASK_AUDIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure translate_row(
   x_task_audit_id in number,
   x_old_task_name   in varchar2,
   x_new_task_name   in varchar2,
   x_old_description in varchar2,
   x_new_description in varchar2,
   x_owner           in varchar2
    )
as
begin
  update jtf_task_audits_tl set
    old_task_name = nvl(x_old_task_name,old_task_name),
    new_task_name = nvl(x_new_task_name,new_task_name),
    old_description = nvl(x_old_description,old_description),
    new_description = nvl(x_new_description,new_description),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATEd_by = decode(x_owner,'SEED',1,0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where task_audit_id = X_task_audit_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end ;

END jtf_task_audits_pvt;

/
