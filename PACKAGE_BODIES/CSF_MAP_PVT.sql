--------------------------------------------------------
--  DDL for Package Body CSF_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_MAP_PVT" AS
/* $Header: CSFVMAPB.pls 120.0 2005/09/15 21:36:44 sseshaiy noship $ */
   FUNCTION set_escalation_flag (p_task_id NUMBER)
      RETURN VARCHAR2
   IS
      l_return_value       VARCHAR2 (1);
      l_object_type_code   VARCHAR2 (30);
      l_object_id          NUMBER;

      CURSOR c_esc
      IS
         SELECT NULL
           FROM jtf_tasks_b t, jtf_task_references_vl r, jtf_ec_statuses_vl s
          WHERE t.task_id = r.task_id
            AND t.task_type_id = 22
            AND t.task_status_id = s.task_status_id
            AND (s.closed_flag = 'N' OR s.closed_flag IS NULL)
            AND (s.completed_flag = 'N' OR s.completed_flag IS NULL)
            AND (s.cancelled_flag = 'N' OR s.cancelled_flag IS NULL)
            AND r.reference_code = 'ESC'
            AND r.object_type_code = l_object_type_code
            AND r.object_id = l_object_id;

      CURSOR c_tsk
      IS
         SELECT t.source_object_type_code,
                t.source_object_id
           FROM jtf_tasks_b t, jtf_task_statuses_vl s
          WHERE t.task_id = p_task_id
            AND t.task_status_id = s.task_status_id
            AND (s.closed_flag = 'N' OR s.closed_flag IS NULL)
            AND (s.completed_flag = 'N' OR s.completed_flag IS NULL)
            AND (s.cancelled_flag = 'N' OR s.cancelled_flag IS NULL);

      r_esc                c_esc%ROWTYPE;
      r_tsk                c_tsk%ROWTYPE;
   BEGIN
      -- Check if Task is escalated. Ignore completed/cancelled status
      -- of Task.
      l_return_value := 'N';
      l_object_type_code := 'TASK';
      l_object_id := p_task_id;

      OPEN c_esc;

      FETCH c_esc
       INTO r_esc;

      IF c_esc%FOUND
      THEN
         l_return_value := 'Y';
      END IF;

      CLOSE c_esc;

      -- If Task is not escalated then check if Service Request is
      -- escalated. Only Tasks which are not completed/cancelled can be
      -- escalated if the Service Request is escalated
      IF l_return_value = 'N'
      THEN
         OPEN c_tsk;

         FETCH c_tsk
          INTO r_tsk;

         IF c_tsk%FOUND
         THEN
            l_object_type_code := r_tsk.source_object_type_code;
            l_object_id := r_tsk.source_object_id;

            OPEN c_esc;

            FETCH c_esc
             INTO r_esc;

            IF c_esc%FOUND
            THEN
               l_return_value := 'Y';
            END IF;

            CLOSE c_esc;
         END IF;

         CLOSE c_tsk;
      END IF;

      RETURN l_return_value;
   END set_escalation_flag;

   -- get attributes of the task assignment prior to the current
   -- task assignment, dependant on the type of the current task, that is
   -- for an arrival virtual task all tasks in the shift, for a departure
   -- nothing (because this is the first 'task' in the shift), and for a
   -- real task all tasks before the current task including the departure
   PROCEDURE get_prior_task_assignment (
      p_res_id            IN              NUMBER,
      p_res_type          IN              VARCHAR2,
      p_shift_start       IN              DATE,
      p_shift_end         IN              DATE,
      p_sched_start       IN              DATE,
      p_ta_id             IN              NUMBER,
      p_task_type_id      IN              NUMBER,
      x_prior_ta_id       OUT NOCOPY      NUMBER,
      x_prior_sched_end   OUT NOCOPY      DATE,
      x_prior_found       OUT NOCOPY      BOOLEAN
   )
   IS
      -- get tasks for this resource in this shift which are before current
      -- task or is the departure virtual task
      CURSOR c_prior (
         p_res_id        NUMBER,
         p_res_type      VARCHAR2,
         p_shift_start   DATE,
         p_shift_end     DATE,
         p_sched_start   DATE,
         p_ta_id         NUMBER
      )
      IS
         SELECT   task_assignment_id,
                  scheduled_end_date
             FROM jtf_tasks_b jtb,
                  jtf_task_assignments jta,
                  cac_sr_object_capacity cso
            WHERE jta.resource_id = p_res_id
              AND jta.resource_type_code = p_res_type
              AND jta.object_capacity_id = cso.object_capacity_id
              AND jta.task_id = jtb.task_id
              AND cso.start_date_time = p_shift_start
              AND cso.end_date_time = p_shift_end
              AND (   jtb.task_type_id = 20                    -- departure task
                   OR (    jtb.task_type_id NOT IN (20, 21)        -- real tasks
                       AND (   jtb.scheduled_start_date < p_sched_start
                            OR (    jtb.scheduled_start_date = p_sched_start
                                AND jta.task_assignment_id < p_ta_id
                               )
                           )
                      )
                  )
         ORDER BY DECODE (jtb.task_type_id, 20, 1, 0)     -- departure task last
                                                     ,
                  jtb.scheduled_start_date DESC,
                  jta.task_assignment_id DESC;

      -- get all tasks for this resource in this shift but without arrival
      CURSOR c_prior_all (
         p_res_id        NUMBER,
         p_res_type      VARCHAR2,
         p_shift_start   DATE,
         p_shift_end     DATE
      )
      IS
         SELECT   jta.task_assignment_id,
                  jtb.scheduled_end_date
             FROM jtf_tasks_b jtb,
                  jtf_task_assignments jta,
                  cac_sr_object_capacity cso
            WHERE jta.resource_id = p_res_id
              AND jta.resource_type_code = p_res_type
              AND jta.object_capacity_id = cso.object_capacity_id
              AND jta.task_id = jtb.task_id
              AND cso.start_date_time = p_shift_start
              AND cso.end_date_time = p_shift_end
              AND jtb.task_type_id <> 21                     -- not arrival task
         ORDER BY DECODE (jtb.task_type_id, 20, 1, 0)     -- departure task last
                                                     ,
                  jtb.scheduled_start_date DESC,
                  jta.task_assignment_id DESC;
   BEGIN
      x_prior_ta_id := NULL;
      x_prior_sched_end := NULL;
      x_prior_found := FALSE;

      -- real task
      IF p_task_type_id NOT IN (20, 21)
      THEN
         OPEN c_prior (p_res_id,
                       p_res_type,
                       p_shift_start,
                       p_shift_end,
                       p_sched_start,
                       p_ta_id
                      );

         FETCH c_prior
          INTO x_prior_ta_id,
               x_prior_sched_end;

         IF c_prior%FOUND
         THEN
            x_prior_found := TRUE;
         END IF;

         CLOSE c_prior;
      -- virtual arrival task
      ELSIF p_task_type_id = 21
      THEN
         OPEN c_prior_all (p_res_id, p_res_type, p_shift_start, p_shift_end);

         FETCH c_prior_all
          INTO x_prior_ta_id,
               x_prior_sched_end;

         IF c_prior_all%FOUND
         THEN
            x_prior_found := TRUE;
         END IF;

         CLOSE c_prior_all;
      END IF;
   END get_prior_task_assignment;

   FUNCTION predict_time_difference (p_task_assignment_id NUMBER)
      RETURN NUMBER
   IS
      l_diff              NUMBER        := 0;
      l_sched_start       DATE          := NULL;
      l_sched_end         DATE          := NULL;
      l_actua_start       DATE          := NULL;
      l_actua_end         DATE          := NULL;
      l_sched_travel      NUMBER        := 0;
      l_res_id            NUMBER        := NULL;
      l_res_type          VARCHAR2 (30) := NULL;
      l_shift_start       DATE          := NULL;
      l_shift_end         DATE          := NULL;
      l_prior_ta_id       NUMBER        := NULL;
      l_prior_sched_end   DATE          := NULL;
      l_min_start         DATE          := NULL;
      l_free              NUMBER        := 0;
      l_bmode             VARCHAR2 (30) := NULL;
      l_plan_start        DATE          := NULL;
      l_plan_end          DATE          := NULL;
      l_task_type_id      NUMBER        := NULL;
      l_prior_found       BOOLEAN       := FALSE;

      CURSOR c_this (p_ta_id NUMBER)
      IS
         SELECT jtb.scheduled_start_date,
                jtb.scheduled_end_date,
                jtb.actual_start_date,
                jtb.actual_end_date,
                jta.sched_travel_duration,
                jta.resource_id,
                jta.resource_type_code,
                cso.start_date_time,
                cso.end_date_time,
                jtb.bound_mode_code,
                jtb.planned_start_date,
                jtb.planned_end_date,
                jtb.task_type_id
           FROM jtf_tasks_b jtb,
                jtf_task_assignments jta,
                cac_sr_object_capacity cso
          WHERE jta.object_capacity_id = cso.object_capacity_id
            AND jta.task_id = jtb.task_id
            AND jta.task_assignment_id = p_ta_id;
   BEGIN
      OPEN c_this (p_task_assignment_id);

      FETCH c_this
       INTO l_sched_start,
            l_sched_end,
            l_actua_start,
            l_actua_end,
            l_sched_travel,
            l_res_id,
            l_res_type,
            l_shift_start,
            l_shift_end,
            l_bmode,
            l_plan_start,
            l_plan_end,
            l_task_type_id;

      IF c_this%FOUND
      THEN
         -- validate shift
         IF    l_shift_start IS NULL
            OR l_shift_end IS NULL
            OR l_shift_end < l_shift_start
         THEN
            -- exit
            RETURN 0;
         END IF;

         -- compute difference
         IF l_actua_end IS NOT NULL
         THEN
            l_diff := l_actua_end - l_sched_end;
         ELSIF l_actua_start IS NOT NULL
         THEN
            l_diff := l_actua_start - l_sched_start;

            IF SYSDATE > l_sched_end + l_diff
            THEN
               l_diff := SYSDATE - l_sched_end;
            END IF;
         -- no actual dates are found, get the previous task in this trip to find
         -- an actual date
         ELSE
            get_prior_task_assignment (l_res_id,
                                       l_res_type,
                                       l_shift_start,
                                       l_shift_end,
                                       l_sched_start,
                                       p_task_assignment_id,
                                       l_task_type_id,
                                       l_prior_ta_id,
                                       l_prior_sched_end,
                                       l_prior_found
                                      );

            IF l_prior_found
            THEN
               -- this is a recursive function!
               l_diff := predict_time_difference (l_prior_ta_id);
            -- no previous task found, this is the first task of the trip, take
            -- system date into account
            ELSE
               IF SYSDATE > l_sched_start
               THEN
                  l_diff := SYSDATE - l_sched_start;
               END IF;
            END IF;

            -- validate travel time attributes
            IF l_sched_travel IS NULL OR l_sched_travel < 0
            THEN
               l_sched_travel := 0;
            END IF;

            -- compute minimal time resource has to leave in order to arrive
            -- in time to start task (unit of measurement is minute)
            l_min_start := l_sched_start - (l_sched_travel / 1440);
            -- correct difference by amount of not scheduled, free time
            l_free := l_min_start - NVL (l_prior_sched_end, l_shift_start);
            l_diff := l_diff - l_free;

            -- correct for time bounds
            IF     l_bmode = 'BTS'
               AND l_plan_end >= l_plan_start
               -- makes no sense for virtual tasks departure and arrival
               AND l_task_type_id NOT IN (20, 21)
            THEN
               IF (l_sched_start + l_diff) < l_plan_start
               THEN
                  l_diff := l_plan_start - l_sched_start;
               END IF;
            END IF;
         END IF;
      END IF;

      CLOSE c_this;

      RETURN l_diff;
   END predict_time_difference;

   FUNCTION get_progress_status (
      p_resource_id          NUMBER,
      p_resource_type_code   VARCHAR2,
      p_date                 DATE
   )
      RETURN NUMBER
   IS
      -- get all escalated tasks in current trip
      CURSOR c_escalated_tasks (
         p_res_id     NUMBER,
         p_res_type   VARCHAR2,
         p_date       DATE
      )
      IS
         SELECT task_id
           FROM jtf_task_assignments jta
          WHERE jta.resource_id = p_res_id
            AND jta.resource_type_code = p_res_type
            AND TRUNC (p_date) BETWEEN TRUNC (jta.booking_start_date)
                                   AND TRUNC (jta.booking_end_date);

      CURSOR c_task_details (p_res_id NUMBER, p_res_type VARCHAR2, p_date DATE)
      IS
         SELECT                                                       --task_id,
--             start_date_time shift_start,
                MAX (NVL (jta.actual_start_date,
                            jta.booking_start_date
                          + predict_time_difference (jta.task_assignment_id)
                         )
                    ) predicted_start_date,
                MAX (end_date_time) shift_end
           --           NVL (jta.actual_end_date, jtb.scheduled_end_date + predict_time_difference (jta.task_assignment_id)) predicted_end_date
         FROM   jtf_task_assignments jta, cac_sr_object_capacity cso
          WHERE jta.resource_id = p_res_id
            AND jta.resource_type_code = p_res_type
            AND TRUNC (p_date) BETWEEN TRUNC (jta.booking_start_date)
                                   AND TRUNC (jta.booking_end_date)
            AND cso.object_capacity_id = jta.object_capacity_id;

      l_chk            VARCHAR2 (1);
      l_max_pred_end   DATE         := NULL;
      l_shift_end      DATE         := NULL;
      l_dif            NUMBER       := NULL;
      l_uom   CONSTANT NUMBER       := 1440;
                                            /* unit of measurement is minutes */
      l_margin         NUMBER;
      l_task           NUMBER;
   BEGIN
      /* see if any task in current trip is escalated */
      OPEN c_escalated_tasks (p_resource_id, p_resource_type_code, p_date);

      LOOP
         FETCH c_escalated_tasks
          INTO l_task;

         IF c_escalated_tasks%NOTFOUND
         THEN
            EXIT;
         END IF;

         IF set_escalation_flag (l_task) = 'Y'
         THEN
            CLOSE c_escalated_tasks;

            RETURN 4;                                           /* escalated */
         END IF;
      END LOOP;

      CLOSE c_escalated_tasks;

      /* get highest predicted end date within trip */
      OPEN c_task_details (p_resource_id, p_resource_type_code, p_date);

      FETCH c_task_details
       INTO l_max_pred_end,
            l_shift_end;

      /* calculate difference with shift end */
      l_dif := (l_shift_end - l_max_pred_end) * l_uom;

      IF c_task_details%FOUND AND l_dif IS NOT NULL
      THEN
         /* get margin profile option */
         l_margin :=
                 TO_NUMBER (fnd_profile.VALUE ('CSF_RESOURCE_PROGRESS_STATUS'));

         IF l_margin IS NULL OR SQLCODE <> 0
         THEN
            l_margin := 60;                    /* default value (60 minutes) */
         END IF;

         CLOSE c_task_details;

         IF l_dif < (l_margin * -1)
         THEN
            RETURN 3;                                     /* behind schedule */
         ELSIF l_dif > l_margin
         THEN
            RETURN 1;                                   /* ahead of schedule */
         END IF;

         RETURN 2;                                             /* on schedule */
      END IF;

      CLOSE c_task_details;

      RETURN 0;                                                    /* unknown */
   END get_progress_status;
END csf_map_pvt;

/
