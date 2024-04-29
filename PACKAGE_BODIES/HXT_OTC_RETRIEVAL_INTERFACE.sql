--------------------------------------------------------
--  DDL for Package Body HXT_OTC_RETRIEVAL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_OTC_RETRIEVAL_INTERFACE" AS
/* $Header: hxtotcri.pkb 120.11.12010000.9 2010/02/16 16:25:12 asrajago ship $ */
--
--
   g_debug                   BOOLEAN         := hr_utility.debug_enabled;
   g_package        CONSTANT VARCHAR2 (31)  := 'hxc_otc_retrieval_interface.';

   TYPE t_timcards_tab IS TABLE OF NUMBER
      INDEX BY VARCHAR2(255);

--
   g_status                  VARCHAR2 (30);
   g_exception_description   VARCHAR2 (2000);
   e_record_error            EXCEPTION;
   e_amount_hours            EXCEPTION;
   g_timecards               t_timcards_tab;
   g_bg_id                   NUMBER;
   l_no_more_timecards       BOOLEAN         := FALSE;

/*
|| Function to identify whether a Timecard, although approved, should get
|| retrieved today or not (we cannot accept timecards if they were already send
|| to payroll today as well because of current DT restrictions in OTLR)
*/
   FUNCTION is_retrievable (
      p_sum_id        IN   hxt_sum_hours_worked_f.ID%TYPE,
      p_date_worked   IN   hxt_sum_hours_worked_f.date_worked%TYPE,
      p_person_id     IN   hxt_timecards_f.for_person_id%TYPE
   )
      RETURN BOOLEAN
   AS
      l_proc              VARCHAR2 (72);
      l_is_retrievable    BOOLEAN                                 := TRUE;
      l_dt_update_mode    VARCHAR2 (256);
      l_error_message     VARCHAR2 (2000);
      l_return_code       NUMBER;
      l_time_summary_id   hxt_det_hours_worked_f.parent_id%TYPE;

      FUNCTION timecard_id (
         p_sum_id        IN   hxt_sum_hours_worked_f.ID%TYPE,
         p_date_worked   IN   hxt_sum_hours_worked_f.date_worked%TYPE,
         p_person_id     IN   hxt_timecards_f.for_person_id%TYPE
      )
         RETURN hxt_timecards_f.ID%TYPE
      AS
         l_proc          VARCHAR2 (72);

         CURSOR csr_timecard_id_from_sum (
            p_sum_id   hxt_sum_hours_worked_f.ID%TYPE
         )
         IS
            SELECT tim_id
              FROM hxt_sum_hours_worked_f
             WHERE ID = p_sum_id;

         CURSOR csr_timecard_id (
            p_date_worked   hxt_sum_hours_worked_f.date_worked%TYPE,
            p_person_id     hxt_timecards_f.for_person_id%TYPE
         )
         IS
            SELECT HTF.ID
              FROM hxt_timecards_f HTF, per_time_periods ptp
             WHERE HTF.for_person_id = p_person_id
               AND HTF.time_period_id = ptp.time_period_id
               AND TRUNC (p_date_worked) BETWEEN TRUNC (ptp.start_date)
                                             AND TRUNC (ptp.end_date);

         l_timecard_id   hxt_timecards_f.ID%TYPE;
      BEGIN
         IF g_debug
         THEN
            l_proc := g_package || 'timecard_id';
            hr_utility.set_location ('Entering: ' || l_proc, 10);
         END IF;

         IF (p_sum_id IS NOT NULL)
         THEN
            OPEN csr_timecard_id_from_sum (p_sum_id);

            FETCH csr_timecard_id_from_sum
             INTO l_timecard_id;

            CLOSE csr_timecard_id_from_sum;
         ELSE
            OPEN csr_timecard_id (p_date_worked, p_person_id);

            FETCH csr_timecard_id
             INTO l_timecard_id;

            CLOSE csr_timecard_id;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (   'Leaving: '
                                     || l_proc
                                     || ' returning timecard_id = '
                                     || l_timecard_id,
                                     100
                                    );
         END IF;

         RETURN l_timecard_id;
      END timecard_id;
/*
|| MAIN
*/
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := g_package || 'is_retrievable';
         hr_utility.set_location (   'Entering: '
                                  || l_proc
                                  || ' (p_sum_id IN = '
                                  || p_sum_id
                                  || ')',
                                  10
                                 );
      END IF;

      hxt_td_util.retro_restrict_edit
                                     (p_tim_id             => timecard_id
                                                                 (p_sum_id,
                                                                  p_date_worked,
                                                                  p_person_id
                                                                 ),
                                      p_session_date       => SYSDATE,
                                      o_dt_update_mod      => l_dt_update_mode,
                                      o_error_message      => l_error_message,
                                      o_return_code        => l_return_code
                                     );
      hr_utility.set_location ('l_dt_update_mode = ' || l_dt_update_mode, 11);
      hr_utility.set_location ('l_error_message = ' || l_error_message, 12);
      hr_utility.set_location ('l_return_code = ' || l_return_code, 13);

      IF (l_dt_update_mode IS NULL)
      THEN
         IF g_debug
         THEN
            hr_utility.set_location
                          (   '   This line is not retrievable (p_sum_id = '
                           || p_sum_id
                           || ')',
                           20
                          );
         END IF;

         l_is_retrievable := FALSE;
      ELSE
         l_is_retrievable := TRUE;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('Leaving: ' || l_proc, 100);
      END IF;

      RETURN l_is_retrievable;
   END is_retrievable;

--
--
-------------------------- get_employee_number -----------------------------
--
   FUNCTION get_employee_number (
      p_person_id        IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2
   IS
-- local vars
      l_employee_number   VARCHAR2 (30);
      l_full_name         VARCHAR2 (240);
   BEGIN
      g_debug := hr_utility.debug_enabled;

--
      IF g_debug
      THEN
         hr_utility.set_location
                          ('HXT_OTC_RETRIEVAL_INTERFACE.get_employee_number',
                           1
                          );
      END IF;

--
      BEGIN
         SELECT employee_number, full_name
           INTO l_employee_number, l_full_name
           FROM per_people_f
          WHERE person_id = p_person_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HXT_RET_NO_EMP_NUMBER');
            fnd_message.set_token ('PERSON_NAME', g_full_name);
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_record_error;
            --
            RETURN (NULL);
      END;

--
      IF g_debug
      THEN
         hr_utility.set_location
                              ('HXT_OTC_RETRIEVAL_INTERFACE.employee_number',
                               2
                              );
         hr_utility.TRACE ('Employee Number is ' || l_employee_number);
         hr_utility.TRACE ('Full Name is ' || l_full_name);
      END IF;

--
      RETURN (l_employee_number);
--
   END get_employee_number;

--
--------------------------- get_assignment_id ---------------------------
--
   PROCEDURE get_assignment_id (
      p_person_id        IN              NUMBER,
      p_payroll_id       OUT NOCOPY      NUMBER,
      p_bg_id            OUT NOCOPY      NUMBER,
      p_assignment_id    OUT NOCOPY      NUMBER,
      p_effective_date   IN              DATE
   )
   IS
   BEGIN
--
      BEGIN
         --
         SELECT paf.payroll_id, paf.business_group_id, paf.assignment_id
           INTO p_payroll_id, p_bg_id, p_assignment_id
           FROM per_all_assignments_f paf
          WHERE paf.person_id = p_person_id
            AND p_effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
            AND paf.assignment_type = 'E'
            AND paf.primary_flag = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HRPAY_RET_NO_ASSIGN');
            fnd_message.set_token ('PERSON_NAME', g_full_name);
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_record_error;
            RETURN;
      END;
--
   END get_assignment_id;

--
------------------------- find_existing_timecard ---------------------------
--
   PROCEDURE find_existing_timecard (
      p_payroll_id            IN              NUMBER,
      p_date_worked           IN              DATE,
      p_person_id             IN              NUMBER,
      p_old_ovn               IN              NUMBER DEFAULT NULL,
      p_bb_id                 IN              NUMBER DEFAULT NULL,
      p_time_summary_id       OUT NOCOPY      NUMBER,
      p_time_sum_start_date   OUT NOCOPY      DATE,
      p_time_sum_end_date     OUT NOCOPY      DATE,
      p_tim_id                OUT NOCOPY     NUMBER
   )
   IS
--
      l_time_period_id   NUMBER (15);
      l_start_date       DATE;
      l_end_date         DATE;
--
   BEGIN
--
      BEGIN
         --
         SELECT time_period_id, start_date, end_date
           INTO l_time_period_id, l_start_date, l_end_date
           FROM per_time_periods
          WHERE payroll_id = p_payroll_id
            AND TRUNC (p_date_worked) BETWEEN TRUNC (start_date)
                                          AND TRUNC (end_date);

         SELECT hshw.ID, hshw.effective_start_date, hshw.effective_end_date,
                hshw.tim_id
           INTO p_time_summary_id, p_time_sum_start_date, p_time_sum_end_date,
                p_tim_id
           FROM hxt_timecards_f HTF, hxt_sum_hours_worked hshw
          WHERE HTF.for_person_id = p_person_id
            AND HTF.payroll_id = p_payroll_id
            AND HTF.time_period_id = l_time_period_id
            AND HTF.effective_end_date = hr_general.end_of_time
            AND HTF.ID = hshw.tim_id
            AND hshw.time_building_block_id = p_bb_id
            -- AND hshw.time_building_block_ovn = p_old_ovn
            AND TRUNC (hshw.date_worked) = TRUNC (p_date_worked);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            p_time_summary_id := NULL;
            p_time_sum_start_date := NULL;
            p_time_sum_end_date := NULL;
         --
         -- g_status := 'ERRORS';
         -- fnd_message.set_name('HXC', 'HXC_HXT_RET_NO_TIMECARD');
         -- fnd_message.set_token('PERSON_NAME', g_full_name);
         -- g_exception_description := SUBSTR(fnd_message.get,1,2000);
         -- raise e_record_error;
         --
         WHEN TOO_MANY_ROWS
         THEN
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HXT_CANNOT_UPDATE');
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_record_error;
            RETURN;
      END;
--
   END find_existing_timecard;

-- In the case where an excpetion is thrown for a bb_id without processing
-- the attibutes, this funciton is used to maintain the p_last_att_index
-- index
   FUNCTION sync_attributes (
      p_att_table        IN   hxc_generic_retrieval_pkg.t_time_attribute,
      p_bb_id            IN   NUMBER,
      p_last_att_index   IN   BINARY_INTEGER
   )
      RETURN VARCHAR2
   IS
      l_att_index   BINARY_INTEGER;
   BEGIN
      IF (p_att_table.COUNT > 0)
      THEN
         l_att_index := NVL (p_last_att_index, p_att_table.FIRST);

         LOOP
            EXIT WHEN (   (NOT p_att_table.EXISTS (l_att_index))
                       OR (p_att_table (l_att_index).bb_id <> p_bb_id)
                      );
            l_att_index := p_att_table.NEXT (l_att_index);
         END LOOP;
      ELSE
         l_att_index := p_last_att_index;
      END IF;

      RETURN l_att_index;
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE ('exception is sync atts ' || SQLERRM);
         RAISE;
   END sync_attributes;

--
--------------------------- get_attributes -------------------------------
--
   PROCEDURE get_attributes (
      p_att_table        IN              hxc_generic_retrieval_pkg.t_time_attribute,
      p_bb_id            IN              NUMBER,
      p_field_name       OUT NOCOPY      t_field_name,
      p_value            OUT NOCOPY      t_value,
      p_context          OUT NOCOPY      t_field_name,
      p_category         OUT NOCOPY      t_field_name,
      p_last_att_index   IN OUT NOCOPY   BINARY_INTEGER,
      p_element_type_id  OUT NOCOPY      NUMBER
   )
   IS
      l_att_index       BINARY_INTEGER;
      l_bld_blk_id      hxc_time_building_blocks.time_building_block_id%TYPE;
      l_bb_id_changed   BOOLEAN                                      := FALSE;
   BEGIN
--
-- Get the attributes of the detail record - element name, input values
--
      IF g_debug
      THEN
         hr_utility.TRACE ('------ Start get_Attributes ------');
      END IF;

--
      IF p_att_table.COUNT <> 0
      THEN
         --
         IF g_debug
         THEN
            hr_utility.TRACE (' att table not empty');
         END IF;

         l_att_index := NVL (p_last_att_index, p_att_table.FIRST);

         IF g_debug
         THEN
            hr_utility.TRACE (' RM 2');
         END IF;

         l_bld_blk_id := p_att_table (l_att_index).bb_id;

         IF g_debug
         THEN
            hr_utility.TRACE (' RM 3');
         END IF;
      --
      ELSE
         --
         RETURN;
      --
      END IF;

--
      IF g_debug
      THEN
         hr_utility.TRACE ('------ Middle get_Attributes ------');
      END IF;

--
-- sanity check to make sure we are in sync
--
      IF (l_bld_blk_id <> p_bb_id)
      THEN
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', 'get_attribute');
         fnd_message.set_token ('STEP', 'bld blk mismatch');
         fnd_message.raise_error;
      END IF;

--
      IF p_att_table.COUNT <> 0
      THEN
         WHILE ((l_att_index IS NOT NULL) AND (NOT l_bb_id_changed))
         LOOP
            IF g_debug
            THEN
               hr_utility.TRACE ('------ In Attribute Loop ------');
            END IF;

            p_field_name (l_att_index) := p_att_table (l_att_index).field_name;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_field_name(l_att_index) is '
                                 || p_field_name (l_att_index)
                                );
            END IF;


            -- Copying the element id into a variable for later
            -- use.

            IF p_field_name(l_att_index) = 'DUMMY ELEMENT CONTEXT'
            THEN
               p_element_type_id := TO_NUMBER(REPLACE(p_att_table (l_att_index).VALUE,'ELEMENT - '));
            END IF;

            p_value (l_att_index) := p_att_table (l_att_index).VALUE;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_value(l_att_index) is '
                                 || p_value (l_att_index)
                                );
            END IF;

            p_context (l_att_index) := p_att_table (l_att_index).CONTEXT;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_context(l_att_index) is '
                                 || p_context (l_att_index)
                                );
            END IF;

            p_category (l_att_index) := p_att_table (l_att_index).CATEGORY;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_category(l_att_index) is '
                                 || p_category (l_att_index)
                                );
            END IF;

            l_att_index := p_att_table.NEXT (l_att_index);

            IF (l_att_index IS NOT NULL)
            THEN
               IF (l_bld_blk_id <> p_att_table (l_att_index).bb_id)
               THEN
                  l_bb_id_changed := TRUE;
                  p_last_att_index := l_att_index;
               END IF;
            END IF;
         END LOOP;
      END IF;
   END get_attributes;

--
--
-------------------------- get_element_name ------------------------------
--
   FUNCTION get_element_name (p_ele_type_id IN NUMBER, p_effective_date IN DATE)
      RETURN VARCHAR2
   IS
-- local vars
      l_element_name   VARCHAR2 (80);
   BEGIN
--
      IF g_debug
      THEN
         hr_utility.set_location ('get_element_name', 1);
      END IF;

--
      BEGIN
         SELECT petl.element_name
           INTO l_element_name
           FROM pay_element_types_f pet, pay_element_types_f_tl petl
          WHERE pet.element_type_id = p_ele_type_id
            AND petl.element_type_id = pet.element_type_id
            AND USERENV ('LANG') = petl.LANGUAGE
            AND p_effective_date BETWEEN pet.effective_start_date
                                     AND pet.effective_end_date;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HRPAY_RET_NO_ELE_NAME');
            fnd_message.set_token ('ELE_TYPE_ID', p_ele_type_id);
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_record_error;
            RETURN (NULL);
      END;

--
      IF g_debug
      THEN
         hr_utility.set_location ('get_element_name', 2);
      END IF;

--
      RETURN (l_element_name);
--
   END get_element_name;

--------------------------- parse_attributes -------------------------------
--
   -- Bug 8888777
   -- Added new parameter, building block id
   PROCEDURE parse_attributes (
      p_category        IN OUT NOCOPY   t_field_name,
      p_field_name      IN OUT NOCOPY   t_field_name,
      p_value           IN OUT NOCOPY   t_value,
      p_context         IN OUT NOCOPY   t_field_name,
      p_date_worked     OUT NOCOPY      DATE,
      p_type            IN              VARCHAR2,
      p_measure         IN              NUMBER,
      p_start_time      IN              DATE,
      p_stop_time       IN              DATE,
      p_assignment_id   IN              NUMBER,
      p_hours           OUT NOCOPY      NUMBER,
      p_hours_type      OUT NOCOPY      VARCHAR2,
      p_segment         OUT NOCOPY      t_segment,
      p_project         OUT NOCOPY      VARCHAR2,
      p_task            OUT NOCOPY      VARCHAR2,
      p_state_name      OUT NOCOPY      VARCHAR2,
      p_county_name     OUT NOCOPY      VARCHAR2,
      p_city_name       OUT NOCOPY      VARCHAR2,
      p_zip_code        OUT NOCOPY      VARCHAR2,
      p_bb_id           IN              NUMBER  DEFAULT 0      -- Bug 8888777
   )
   IS
      l_seg               NUMBER (5);
      l_element_type_id   NUMBER;
      l_base_elt_id       NUMBER;
      l_earn_policy_id    NUMBER;
      l_retcode           NUMBER (9);
      c_proc              VARCHAR2 (100)
                            := 'HXT_OTC_RETRIEVAL_INTERFACE.parse_attributes';

      CURSOR c_get_base_hours_type (p_earning_policy_id NUMBER)
      IS
         SELECT egr.element_type_id
           FROM hxt_earning_rules egr, hxt_add_elem_info_f aei
          WHERE egr.egp_id = p_earning_policy_id
            AND aei.element_type_id = egr.element_type_id
            AND aei.earning_category = 'REG'
            AND egr.egr_type <> 'HOL';

      CURSOR c_get_project (p_project_id NUMBER)
      IS
         SELECT proj.project_number
           FROM hxt_all_projects_v proj
          WHERE proj.project_id = p_project_id;

      CURSOR c_get_task (p_task_id NUMBER)
      IS
         SELECT task.task_number
           FROM hxt_all_tasks_v task
          WHERE task.task_id = p_task_id;

      l_id_flex_num       NUMBER;
--
   BEGIN
      g_debug := hr_utility.debug_enabled;
      pay_paywsqee_pkg.populate_context_items (g_bg_id, l_id_flex_num);

--
-- Initialize 30 costing segments to NULL
--
      FOR seg IN 1 .. 30
      LOOP
         p_segment (seg) := NULL;
      END LOOP;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 10);
      END IF;

--
-- If the detail block is of type duration, then the number
-- of hours is in l_measure.
--
      IF p_type = 'MEASURE'
      THEN
         p_hours := p_measure;

         --
         IF g_debug
         THEN
            hr_utility.set_location (c_proc, 20);
         END IF;
      --
      END IF;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 30);
      END IF;

--
-- If the detail block is of type range, then the number
-- of hours is derived from the difference between
-- p_start_time and p_stop_time.
--
      IF p_type = 'RANGE'
      THEN
         p_hours := (p_stop_time - p_start_time) * 24;

         --
         IF g_debug
         THEN
            hr_utility.set_location (c_proc, 40);
         END IF;
      --
      END IF;

--
      IF g_debug
      THEN
         hr_utility.TRACE ('The Number of Hours is ' || TO_CHAR (p_hours));
         hr_utility.set_location (c_proc, 50);
      END IF;

--
-- Set up the date earned for the batch line.  The
-- date_earned for the time is the date of the start_time.
--
      p_date_worked := TRUNC (p_start_time);

--
      IF g_debug
      THEN
         hr_utility.TRACE (   'p_date_worked is '
                           || TO_CHAR (p_date_worked, 'DD-MON-YYYY')
                          );
         hr_utility.TRACE (   'p_start_time is '
                           || TO_CHAR (p_start_time, 'DD-MON-YYYY HH:MI:SS')
                          );
      END IF;

--
-- Map all other attributes if they exist
--
      IF p_category.COUNT <> 0
      THEN
--
         FOR l_att IN p_category.FIRST .. p_category.LAST
         LOOP
            --
            IF g_debug
            THEN
               hr_utility.TRACE ('------ In Parse attribute Loop ------');
               hr_utility.TRACE ('category is ' || p_category (l_att));
               hr_utility.TRACE ('context is ' || p_context (l_att));
               hr_utility.TRACE ('field_name is ' || p_field_name (l_att));
               hr_utility.TRACE ('value is ' || p_value (l_att));
               hr_utility.set_location (c_proc, 200);
            END IF;

            --
            IF UPPER (p_field_name (l_att)) = 'DUMMY ELEMENT CONTEXT'
            THEN
               l_element_type_id :=
                  TO_NUMBER (REPLACE (UPPER (p_value (l_att)), 'ELEMENT - '));

               IF l_element_type_id IS NOT NULL
               THEN
                  --
                  l_retcode :=
                     hxt_tim_col_util.get_earn_pol_id (p_assignment_id,
                                                       p_date_worked,
                                                       NULL,
                                                       l_earn_policy_id
                                                      );

                  --
                  OPEN c_get_base_hours_type (l_earn_policy_id);

                  FETCH c_get_base_hours_type
                   INTO l_base_elt_id;

                  CLOSE c_get_base_hours_type;

                  --
                  IF g_debug
                  THEN
                     hr_utility.TRACE
                                   ('---- Before setting the hours type ----');
                     hr_utility.TRACE (   'MH assignment id is '
                                       || p_assignment_id
                                      );
                     hr_utility.TRACE (   'MH earning policy id'
                                       || l_earn_policy_id
                                      );
                     hr_utility.TRACE (   'MH base element type id '
                                       || l_base_elt_id
                                      );
                     hr_utility.TRACE (   'MH l_element_type_id '
                                       || l_element_type_id
                                      );
                     hr_utility.TRACE ('MH p_hours_type ' || p_hours_type);
                  END IF;

                  --
                  IF l_element_type_id = l_base_elt_id
                  THEN
                     p_hours_type := NULL;
                  ELSE
                     p_hours_type :=
                          get_element_name (l_element_type_id, p_date_worked);
                  END IF;

                  --
                  IF g_debug
                  THEN
                     hr_utility.TRACE
                                    ('---- After setting the hours type ----');
                     hr_utility.TRACE ('MH p_hours_type ' || p_hours_type);
                  END IF;
               --
               END IF;
            --
            ELSIF UPPER (p_field_name (l_att)) LIKE 'COSTSEGMENT%'
            THEN
               l_seg :=
                  TO_NUMBER (REPLACE (UPPER (p_field_name (l_att)),
                                      'COSTSEGMENT'
                                     )
                            );

               IF l_seg <= 30
               THEN
                  --bug 2649003
                  --change the value of costing from flex_value_id to flex_value for independent value set
                  IF p_value (l_att) IS NOT NULL
                  THEN
                     p_value (l_att) :=
                        hxt_interface_utilities.costflex_value
                                           (p_id_flex_num        => l_id_flex_num,
                                            p_segment_name       =>    'SEGMENT'
                                                                    || l_seg,
                                            p_flex_value_id      => p_value
                                                                        (l_att)
                                           );
                  END IF;

                  -- bug 2649003 end
                  p_segment (l_seg) := p_value (l_att);
                  p_field_name (l_att) := NULL;
                  p_value (l_att) := NULL;
                  p_context (l_att) := NULL;
                  p_category (l_att) := NULL;
               END IF;
            ELSIF UPPER (p_field_name (l_att)) = 'PROJECT_ID'
            THEN
               --we need to get the Project number. p_value holds Project ID
               OPEN c_get_project (p_value (l_att));

               FETCH c_get_project
                INTO p_project;

               CLOSE c_get_project;
            ELSIF UPPER (p_field_name (l_att)) = 'TASK_ID'
            THEN
               OPEN c_get_task (p_value (l_att));

               FETCH c_get_task
                INTO p_task;

               CLOSE c_get_task;
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_STATE_NAME'
            THEN
               p_state_name := p_value (l_att);
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_COUNTY_NAME'
            THEN
               p_county_name := p_value (l_att);
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_CITY_NAME'
            THEN
               p_city_name := p_value (l_att);
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_ZIP_CODE'
            THEN
               p_zip_code := p_value (l_att);
            END IF;
         --
         END LOOP;
      END IF;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 90);
      END IF;
--
   END parse_attributes;

--
--
--------------------------- parse_attributes -------------------------------
--
   -- Bug 8888777
   -- Added new parameter, building block id

   PROCEDURE parse_attributes (
      p_category        IN OUT NOCOPY   t_field_name,
      p_field_name      IN OUT NOCOPY   t_field_name,
      p_value           IN OUT NOCOPY   t_value,
      p_context         IN OUT NOCOPY   t_field_name,
      p_date_worked     OUT NOCOPY      DATE,
      p_type            IN              VARCHAR2,
      p_measure         IN              NUMBER,
      p_start_time      IN              DATE,
      p_stop_time       IN              DATE,
      p_assignment_id   IN              NUMBER,
      p_hours           OUT NOCOPY      NUMBER,
      p_hours_type      OUT NOCOPY      VARCHAR2,
      p_segment         OUT NOCOPY      t_segment,
      --2223669
      p_amount          OUT NOCOPY      NUMBER,
      p_hourly_rate     OUT NOCOPY      NUMBER,
      p_rate_multiple   OUT NOCOPY      NUMBER,
      p_project         OUT NOCOPY      VARCHAR2,
      p_task            OUT NOCOPY      VARCHAR2,
      p_state_name      OUT NOCOPY      VARCHAR2,
      p_county_name     OUT NOCOPY      VARCHAR2,
      p_city_name       OUT NOCOPY      VARCHAR2,
      p_zip_code        OUT NOCOPY      VARCHAR2,
      p_bb_id           IN              NUMBER  DEFAULT 0    -- Bug 8888777

   )
   IS
      l_seg               NUMBER (5);
      l_element_type_id   NUMBER;
      l_base_elt_id       NUMBER;
      l_earn_policy_id    NUMBER;
      l_retcode           NUMBER (9);
      l_ipv_name          VARCHAR2 (80);
      l_trans_ipv_name    VARCHAR2 (30);
      c_proc              VARCHAR2 (100)
                            := 'HXT_OTC_RETRIEVAL_INTERFACE.parse_attributes';

      --2223669
      CURSOR c_input_value_name (
         p_ele_type_id   IN   NUMBER,
         p_ipv_segment   IN   VARCHAR2
      )
      IS
         SELECT end_user_column_name
           FROM fnd_descr_flex_column_usages c, hxc_mapping_components mpc
          WHERE c.application_id = 809
            AND c.descriptive_flexfield_name = 'OTC Information Types'
            AND c.descriptive_flex_context_code =
                                       'ELEMENT - ' || TO_CHAR (p_ele_type_id)
            AND c.application_column_name = mpc.SEGMENT
            AND UPPER (mpc.field_name) = p_ipv_segment;

      CURSOR c_get_base_hours_type (p_earning_policy_id NUMBER)
      IS
         SELECT egr.element_type_id
           FROM hxt_earning_rules egr, hxt_add_elem_info_f aei
          WHERE egr.egp_id = p_earning_policy_id
            AND aei.element_type_id = egr.element_type_id
            AND aei.earning_category = 'REG'
            AND egr.egr_type <> 'HOL';

      CURSOR c_get_project (p_project_id NUMBER)
      IS
         SELECT proj.project_number
           FROM hxt_all_projects_v proj
          WHERE proj.project_id = p_project_id;

      CURSOR c_get_task (p_task_id NUMBER)
      IS
         SELECT task.task_number
           FROM hxt_all_tasks_v task
          WHERE task.task_id = p_task_id;

      l_id_flex_num       NUMBER;
--
   BEGIN
      g_debug := hr_utility.debug_enabled;
      pay_paywsqee_pkg.populate_context_items (g_bg_id, l_id_flex_num);

--
-- Initialize 30 costing segments to NULL
--
      FOR seg IN 1 .. 30
      LOOP
         p_segment (seg) := NULL;
      END LOOP;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 10);
      END IF;

--
-- If the detail block is of type duration, then the number
-- of hours is in l_measure.
--
      IF p_type = 'MEASURE'
      THEN
         p_hours := p_measure;

         --
         IF g_debug
         THEN
            hr_utility.set_location (c_proc, 20);
         END IF;
      --
      END IF;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 30);
      END IF;

--
-- If the detail block is of type range, then the number
-- of hours is derived from the difference between
-- p_start_time and p_stop_time.
--
      IF p_type = 'RANGE'
      THEN
         p_hours := (p_stop_time - p_start_time) * 24;

         --
         IF g_debug
         THEN
            hr_utility.set_location (c_proc, 40);
         END IF;
      --
      END IF;

--
      IF g_debug
      THEN
         hr_utility.TRACE ('The Number of Hours is ' || TO_CHAR (p_hours));
         hr_utility.set_location (c_proc, 50);
      END IF;

--
-- Set up the date earned for the batch line.  The
-- date_earned for the time is the date of the start_time.
--
      p_date_worked := TRUNC (p_start_time);

--
      IF g_debug
      THEN
         hr_utility.TRACE (   'p_date_worked is '
                           || TO_CHAR (p_date_worked, 'DD-MON-YYYY')
                          );
         hr_utility.TRACE (   'p_start_time is '
                           || TO_CHAR (p_start_time, 'DD-MON-YYYY HH:MI:SS')
                          );
      END IF;

--
-- Map all other attributes if they exist
--
      IF p_category.COUNT <> 0
      THEN
--
         FOR l_att IN p_category.FIRST .. p_category.LAST
         LOOP
            --
            IF g_debug
            THEN
               hr_utility.TRACE ('------ In Parse attribute Loop ------');
               hr_utility.TRACE ('category is ' || p_category (l_att));
               hr_utility.TRACE ('context is ' || p_context (l_att));
               hr_utility.TRACE ('field_name is ' || p_field_name (l_att));
               hr_utility.TRACE ('value is ' || p_value (l_att));
               hr_utility.set_location (c_proc, 200);
            END IF;

            --
            IF UPPER (p_field_name (l_att)) = 'DUMMY ELEMENT CONTEXT'
            THEN
               l_element_type_id :=
                  TO_NUMBER (REPLACE (UPPER (p_value (l_att)), 'ELEMENT - '));

               IF l_element_type_id IS NOT NULL
               THEN
                  --
                  l_retcode :=
                     hxt_tim_col_util.get_earn_pol_id (p_assignment_id,
                                                       p_date_worked,
                                                       NULL,
                                                       l_earn_policy_id
                                                      );

                  --
                  OPEN c_get_base_hours_type (l_earn_policy_id);

                  FETCH c_get_base_hours_type
                   INTO l_base_elt_id;

                  CLOSE c_get_base_hours_type;

                  --
                  IF g_debug
                  THEN
                     hr_utility.TRACE
                                   ('---- Before setting the hours type ----');
                     hr_utility.TRACE (   'MH assignment id is '
                                       || p_assignment_id
                                      );
                     hr_utility.TRACE (   'MH earning policy id'
                                       || l_earn_policy_id
                                      );
                     hr_utility.TRACE (   'MH base element type id '
                                       || l_base_elt_id
                                      );
                     hr_utility.TRACE (   'MH l_element_type_id '
                                       || l_element_type_id
                                      );
                     hr_utility.TRACE ('MH p_hours_type ' || p_hours_type);
                  END IF;

                  --
                  IF l_element_type_id = l_base_elt_id
                  THEN
                     p_hours_type := NULL;
                  ELSE
                     p_hours_type :=
                          get_element_name (l_element_type_id, p_date_worked);
                  END IF;

                  --
                  IF g_debug
                  THEN
                     hr_utility.TRACE
                                    ('---- After setting the hours type ----');
                     hr_utility.TRACE ('MH p_hours_type ' || p_hours_type);
                  END IF;
               --
               END IF;
            --
            ELSIF UPPER (p_field_name (l_att)) LIKE 'COSTSEGMENT%'
            THEN
               l_seg :=
                  TO_NUMBER (REPLACE (UPPER (p_field_name (l_att)),
                                      'COSTSEGMENT'
                                     )
                            );

               IF l_seg <= 30
               THEN
                  --bug 2649003
                  --change the value of costing from flex_value_id to flex_value for independent value set
                  IF p_value (l_att) IS NOT NULL
                  THEN
                     p_value (l_att) :=
                        hxt_interface_utilities.costflex_value
                                           (p_id_flex_num        => l_id_flex_num,
                                            p_segment_name       =>    'SEGMENT'
                                                                    || l_seg,
                                            p_flex_value_id      => p_value
                                                                        (l_att)
                                           );
                  END IF;

                  -- bug 2649003 end
                  p_segment (l_seg) := p_value (l_att);
                  p_field_name (l_att) := NULL;
                  p_value (l_att) := NULL;
                  p_context (l_att) := NULL;
                  p_category (l_att) := NULL;
               END IF;
            -- 2223669
            ELSIF UPPER (p_field_name (l_att)) LIKE 'INPUTVALUE%'
            THEN
               OPEN c_input_value_name (l_element_type_id,
                                        p_field_name (l_att)
                                       );

               FETCH c_input_value_name
                INTO l_ipv_name;

               IF (c_input_value_name%FOUND)
               THEN
                  l_trans_ipv_name :=
                      hxt_batch_process.get_lookup_code (l_ipv_name, SYSDATE);

                  IF (l_trans_ipv_name = 'AMOUNT')
                  THEN
                     IF     (p_value (l_att) IS NOT NULL)
                        AND (NVL (p_hours, 0) <> 0)
                     THEN
                        RAISE e_amount_hours;
                     END IF;

                     -- Bug 7685797
                     -- Added FND Number conversions in case the process
                     -- is run from a resp with Number format 10.000,00
                     p_amount := FND_NUMBER.CANONICAL_TO_NUMBER(p_value (l_att));
                  ELSIF (l_trans_ipv_name = 'RATE_MULTIPLE')
                  THEN
                     p_rate_multiple := FND_NUMBER.CANONICAL_TO_NUMBER(p_value (l_att));
                  ELSIF (l_trans_ipv_name = 'HOURLY_RATE')
                  THEN
                     p_hourly_rate := FND_NUMBER.CANONICAL_TO_NUMBER(p_value (l_att));
                  ELSIF (l_trans_ipv_name = 'RATE')
                  THEN
                     p_hourly_rate := FND_NUMBER.CANONICAL_TO_NUMBER(p_value (l_att));
                  ELSE
                     -- Bug 8888777
                     -- Added the below code to copy any InputValue to
                     -- the global table for later retrieval.
                     -- Would do this only if the Input value is none of the above types.

                     IF g_debug
                     THEN
                        hr_utility.trace('Picking up some configured input value here ');
                        hr_utility.trace('Field name : '||p_field_name(l_att));
                        hr_utility.trace('Value : '||p_value(l_att));
                     END IF;

                     IF UPPER (p_field_name (l_att)) = 'INPUTVALUE1'
                     THEN
                        g_iv_table(p_bb_id).attribute1 := p_value(l_att);
                     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE2'
                     THEN
                        g_iv_table(p_bb_id).attribute2 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE3'
                     THEN
                        g_iv_table(p_bb_id).attribute3 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE4'
                     THEN
                        g_iv_table(p_bb_id).attribute4 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE5'
                     THEN
                        g_iv_table(p_bb_id).attribute5 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE6'
                     THEN
                        g_iv_table(p_bb_id).attribute6 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE7'
                     THEN
                        g_iv_table(p_bb_id).attribute7 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE8'
                     THEN
                        g_iv_table(p_bb_id).attribute8 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE9'
                     THEN
                        g_iv_table(p_bb_id).attribute9 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE10'
                     THEN
                        g_iv_table(p_bb_id).attribute10 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE11'
                     THEN
                        g_iv_table(p_bb_id).attribute11 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE12'
                     THEN
                        g_iv_table(p_bb_id).attribute12 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE13'
                     THEN
                        g_iv_table(p_bb_id).attribute13 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE14'
                     THEN
                        g_iv_table(p_bb_id).attribute14 := p_value(l_att);
		     ELSIF UPPER (p_field_name (l_att)) = 'INPUTVALUE15'
                     THEN
                        g_iv_table(p_bb_id).attribute15 := p_value(l_att);
                     END IF;

                  END IF;
               END IF;

               CLOSE c_input_value_name;
            ELSIF UPPER (p_field_name (l_att)) LIKE 'PROJECT_ID'
            THEN
               --we need to get the Project number. p_value holds Project ID
               OPEN c_get_project (p_value (l_att));

               FETCH c_get_project
                INTO p_project;

               CLOSE c_get_project;
            ELSIF UPPER (p_field_name (l_att)) LIKE 'TASK_ID'
            THEN
               OPEN c_get_task (p_value (l_att));

               FETCH c_get_task
                INTO p_task;

               CLOSE c_get_task;
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_STATE_NAME'
            THEN
               p_state_name := p_value (l_att);
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_COUNTY_NAME'
            THEN
               p_county_name := p_value (l_att);
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_CITY_NAME'
            THEN
               p_city_name := p_value (l_att);
            ELSIF UPPER (p_field_name (l_att)) LIKE 'NA_ZIP_CODE'
            THEN
               p_zip_code := p_value (l_att);
            END IF;
         --
         END LOOP;
      END IF;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 90);
      END IF;
--
   END parse_attributes;

--
------------------------- transfer_to_otm ----------------------------
--
   PROCEDURE transfer_to_otm (
      p_bg_id                        IN              NUMBER,
      p_incremental                  IN              VARCHAR2 DEFAULT 'Y',
      p_start_date                   IN              VARCHAR2,
      p_end_date                     IN              VARCHAR2,
      p_where_clause                 IN              VARCHAR2,
      p_transfer_to_bee              IN              VARCHAR2 DEFAULT 'N',
      p_retrieval_transaction_code   IN              VARCHAR2,
      p_batch_ref                    IN              VARCHAR2,
      p_no_otm                       IN OUT NOCOPY   VARCHAR2,
      p_unique_params                IN              VARCHAR2,
      p_since_date                   IN              VARCHAR2
   )
   IS
--
-- TYPE t_field_name IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
-- TYPE t_value IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
-- TYPE t_segment IS TABLE OF varchar2(60) INDEX BY BINARY_INTEGER;
--
--
      CURSOR get_batch_status (p_tim_id hxt_timecards.ID%TYPE)
      IS
         SELECT batch_status_cd
           FROM hxt_timecards_fmv
          WHERE ID = p_tim_id;

      l_batch_status_cd               hxt_timecards_fmv.batch_status_cd%TYPE;

      CURSOR get_debug
      IS
         SELECT 'X'
           FROM hxc_debug
          WHERE UPPER (process) = 'HXT_OTC_RETRIEVAL_INTERFACE'
            AND TRUNC (debug_date) <= SYSDATE;

      CURSOR csr_created_timecards (p_batch_ref VARCHAR2)
      IS
         SELECT   HTF.ID
             FROM hxt_timecards_f HTF, pay_batch_headers pbh
            WHERE pbh.batch_reference LIKE p_batch_ref || '%'
              AND HTF.batch_id = pbh.batch_id
         ORDER BY for_person_id, time_period_id;

--
-- global table counts
      g_cnt_t_bld_blks                NUMBER;
      g_cnt_t_attributes              NUMBER;
      g_cnt_t_detail_bld_blks         NUMBER;
      g_cnt_t_detail_attributes       NUMBER;
      g_cnt_t_day_bld_blks            NUMBER;
--
      g_cnt_t_old_detail_bld_blks     NUMBER;
      g_cnt_t_old_detail_attributes   NUMBER;
      g_cnt_t_old_day_bld_blks        NUMBER;
--
      g_cnt_t_tx_det_bb_id            NUMBER;
      g_cnt_t_tx_det_status           NUMBER;
      g_cnt_t_tx_det_exception        NUMBER;
-- t_tx_detail_bb_id t_time_building_block_id;
-- t_tx_detail_parent_id t_time_building_block_id;
-- t_tx_detail_bb_ovn t_time_building_block_ovn;
-- t_tx_detail_transaction_id t_transaction_id;
-- t_tx_detail_status t_status;
-- t_tx_detail_exception t_exception_description;
--
-- local tables
      l_field_name                    t_field_name;
      l_value                         t_value;
      l_context                       t_field_name;
      l_category                      t_field_name;
      l_segment                       t_segment;
--
      l_old_field_name                t_field_name;
      l_old_value                     t_value;
      l_old_context                   t_field_name;
      l_old_category                  t_field_name;
      l_old_segment                   t_segment;
-- local variables
      l_last_att_index                BINARY_INTEGER;
      l_old_last_att_index            BINARY_INTEGER;
      l_object_version_number         NUMBER (9);
      l_batch_id                      NUMBER (15);
      l_count_timecards               NUMBER (9);
      l_max_batches                   NUMBER
                                       := fnd_profile.VALUE ('HXT_BATCH_SIZE');
-- l_max_batches                NUMBER := fnd_profile.Value('OTC_BATCH_SIZE');
      l_batch_ref                     VARCHAR2 (30);
      l_batch_name                    VARCHAR2 (30);
      l_non_retro_batch_id            NUMBER (15);
      l_count_batch_lines             NUMBER (9);
      l_count_batch_head              NUMBER (9);
-- l_retro_batch_ref            VARCHAR2(30);
      l_retro_batch_name              VARCHAR2 (30);
      l_retro_batch_id                NUMBER (15);
      l_retro_count_batch_lines       NUMBER (9);
      l_retro_count_batch_head        NUMBER (9);
--
      l_batch_created                 VARCHAR2 (1)                      := 'N';
      l_retro_batch_created           VARCHAR2 (1)                      := 'N';
--
      l_batch_line_id                 NUMBER (15);
      l_retro_batch_request_id        NUMBER;
      l_batch_process_request_id      NUMBER;
--
      l_old_bb_index                  BINARY_INTEGER;
      l_bb_id                         NUMBER (15);
      l_ovn                           NUMBER (9);
      l_type                          VARCHAR2 (30);
      l_measure                       NUMBER;
      l_start_time                    DATE;
      l_stop_time                     DATE;
      l_parent_bb_id                  NUMBER (15);
      l_scope                         VARCHAR2 (30);
      l_resource_id                   NUMBER (15);
      l_resource_type                 VARCHAR2 (30);
      l_comment_text                  VARCHAR2 (2000);
--
      l_old_bb_id                     NUMBER (15);
      l_old_ovn                       NUMBER (9);
      l_old_type                      VARCHAR2 (30);
      l_old_measure                   NUMBER (15);
      l_old_start_time                DATE;
      l_old_stop_time                 DATE;
      l_old_parent_bb_id              NUMBER (15);
      l_old_scope                     VARCHAR2 (30);
      l_old_resource_id               NUMBER (15);
      l_old_resource_type             VARCHAR2 (30);
      l_old_comment_text              VARCHAR2 (2000);
--
      l_where_clause                  VARCHAR2 (32000)            DEFAULT NULL;
--
      l_person_id                     NUMBER (9);
      l_payroll_id                    NUMBER (9);
      l_gre_id                        NUMBER (9);
      l_bg_id                         NUMBER (9);
      l_org_id                        NUMBER (9);
      l_assignment_id                 NUMBER (9);
      l_assignment_number             VARCHAR2 (30);
      l_effective_date                DATE;
--
      l_employee_number               VARCHAR2 (30);
      l_approver_number               VARCHAR2 (30);
--
      l_errbuf                        VARCHAR2 (512)              DEFAULT NULL;
      l_retcode                       NUMBER (9);
--
      l_created_tim_sum_id            hxt_sum_hours_worked.ID%TYPE
                                                                  DEFAULT NULL;
      l_otm_error                     VARCHAR2 (2000)             DEFAULT NULL;
      l_oracle_error                  VARCHAR2 (2000)             DEFAULT NULL;
--
      l_time_summary_id               NUMBER;
      l_time_sum_start_date           DATE;
      l_time_sum_end_date             DATE;
--
      l_earn_policy                   VARCHAR2 (30);
      l_old_earn_policy               VARCHAR2 (30);
      l_task                          VARCHAR2 (30);
      l_old_task                      VARCHAR2 (30);
      l_task_id                       NUMBER (15);
      l_old_task_id                   NUMBER (15);
      l_hours_type                    VARCHAR2 (80);
      -- Bug 7835456
      -- Changed size to 80
      l_old_hours_type                VARCHAR2 (80);
      l_earn_reason_code              VARCHAR2 (30);
      l_old_earn_reason_code          VARCHAR2 (30);
      l_project                       VARCHAR2 (30);
      l_old_project                   VARCHAR2 (30);
      l_project_id                    NUMBER (15);
      l_old_project_id                NUMBER (15);
      l_location                      VARCHAR2 (30);
      l_old_location                  VARCHAR2 (30);
      l_location_id                   NUMBER (15);
      l_old_location_id               NUMBER (15);
      l_comment                       VARCHAR2 (30);
      l_old_comment                   VARCHAR2 (30);
      l_rate_multiple                 NUMBER;
      l_old_rate_multiple             NUMBER;
      l_hourly_rate                   NUMBER;
      l_old_hourly_rate               NUMBER;
      l_amount                        NUMBER;
      l_old_amount                    NUMBER;
      l_sep_check_flag                VARCHAR2 (30);
      l_old_sep_check_flag            VARCHAR2 (30);
      l_hours                         NUMBER;
      l_old_hours                     NUMBER;
      l_state_name                    hxt_sum_hours_worked_f.state_name%TYPE;
      l_old_state_name                hxt_sum_hours_worked_f.state_name%TYPE;
      l_county_name                   hxt_sum_hours_worked_f.county_name%TYPE;
      l_old_county_name               hxt_sum_hours_worked_f.county_name%TYPE;
      l_city_name                     hxt_sum_hours_worked_f.city_name%TYPE;
      l_old_city_name                 hxt_sum_hours_worked_f.city_name%TYPE;
      l_zip_code                      hxt_sum_hours_worked_f.zip_code%TYPE;
      l_old_zip_code                  hxt_sum_hours_worked_f.zip_code%TYPE;
--
      l_tc_rowid                      ROWID;
--
      l_process_name                  VARCHAR2 (80);
--
      l_element_name                  VARCHAR2 (80);
      l_element_type_id               NUMBER (9);
--
      l_date_worked                   DATE;
      l_old_date_worked               DATE;
      l_start_date                    DATE;
      l_end_date                      DATE;
--
      l_changed                       VARCHAR2 (1)                      := 'N';
      l_deleted                       VARCHAR2 (1)                      := 'N';
      l_no_times                      VARCHAR2 (1)                      := 'N';
      l_no_old_times                  VARCHAR2 (1)                      := 'N';
--
      l_old_att                       NUMBER;
      i                               VARCHAR2(255);
      loop_ok                         BOOLEAN                          := TRUE;
      l_debug                         VARCHAR2 (1);
      l_dt_update_mode                VARCHAR2 (255);
      l_return_code                   NUMBER;
--
-- l_seq    NUMBER;
--
      e_retrieval_error               EXCEPTION;
      e_not_retrievable               EXCEPTION;
--
      c_proc                          VARCHAR2 (100)
                              := 'HXT_OTC_RETRIEVAL_INTERFACE.transfer_to_otm';

      l_element_id                    NUMBER;
      l_tim_id                        NUMBER;

--
--
-------------------------- get_ele_type_id -------------------------------
--
      FUNCTION get_ele_type_id (
         p_element_name     IN   VARCHAR2,
         p_bg_id            IN   NUMBER,
         p_effective_date   IN   DATE
      )
         RETURN NUMBER
      IS
-- local vars
         l_ele_type_id   NUMBER (9);
      BEGIN
--
         IF g_debug
         THEN
            hr_utility.set_location
                              ('HXT_OTC_RETRIEVAL_INTERFACE.get_ele_type_id',
                               1
                              );
         END IF;

--
         BEGIN
            SELECT pet.element_type_id
              INTO l_ele_type_id
              FROM pay_element_types_f pet
             WHERE pet.element_name = p_element_name
               AND (   pet.business_group_id + 0 = p_bg_id
                    OR pet.business_group_id IS NULL
                   )
--and pet.legislation_code = 'US')
--or (pet.business_group_id is null
--and pet.legislation_code is null))
               AND p_effective_date BETWEEN pet.effective_start_date
                                        AND pet.effective_end_date;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --
               g_status := 'ERRORS';
               fnd_message.set_name ('HXC', 'HXC_HRPAY_RET_NO_ELE_TYPE_ID');
               fnd_message.set_token ('ELE_NAME', p_element_name);
               g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
               RAISE e_record_error;
               --
               RETURN (NULL);
         END;

--
         IF g_debug
         THEN
            hr_utility.set_location
                              ('HXT_OTC_RETRIEVAL_INTERFACE.get_ele_type_id',
                               2
                              );
         END IF;

--
         RETURN (l_ele_type_id);
--
      END get_ele_type_id;

--
----------------------------- record_time -----------------------------------
--
      PROCEDURE record_time (
         p_employee_number           IN   VARCHAR2,
         p_approver_number           IN   VARCHAR2,
         p_batch_ref                 IN   VARCHAR2,
         p_batch_name                IN   VARCHAR2,
         p_bg_id                     IN   NUMBER,
         p_start_time                IN   DATE,
         p_end_time                  IN   DATE,
         p_date_worked               IN   DATE,
         p_hours                     IN   NUMBER,
         p_earning_policy            IN   VARCHAR2,
         p_hours_type                IN   VARCHAR2,
         p_earn_reason_code          IN   VARCHAR2,
         p_project                   IN   VARCHAR2,
         p_task                      IN   VARCHAR2,
         p_location                  IN   VARCHAR2,
         p_comment                   IN   VARCHAR2,
         p_rate_multiple             IN   NUMBER,
         p_hourly_rate               IN   NUMBER,
         p_amount                    IN   NUMBER,
         p_sep_check_flag            IN   VARCHAR2,
         p_segment                   IN   t_segment,
         p_time_summary_id           IN   NUMBER DEFAULT NULL,
         p_time_sum_start_date       IN   DATE DEFAULT NULL,
         p_time_sum_end_date         IN   DATE DEFAULT NULL,
         p_time_building_block_id    IN   NUMBER,
         p_time_building_block_ovn   IN   NUMBER,
         p_delete                    IN   VARCHAR2,
         p_state_name                IN   VARCHAR2 DEFAULT NULL,
         p_county_name               IN   VARCHAR2 DEFAULT NULL,
         p_city_name                 IN   VARCHAR2 DEFAULT NULL,
         p_zip_code                  IN   VARCHAR2 DEFAULT NULL
      )
      IS
--
         CURSOR get_timecard_id (p_tim_sum_id NUMBER)
         IS
            SELECT hshw.tim_id, ht.time_period_id
              FROM hxt_sum_hours_worked hshw, hxt_timecards ht
             WHERE hshw.ID = p_tim_sum_id AND hshw.tim_id = ht.ID;

--
         l_created_tim_sum_id   hxt_sum_hours_worked.ID%TYPE   DEFAULT NULL;
         l_otm_error            VARCHAR2 (2000)                DEFAULT NULL;
         l_oracle_error         VARCHAR2 (2000)                DEFAULT NULL;
         l_time_period_id       NUMBER;
         l_timecard_id          NUMBER;
--
      BEGIN
         IF g_debug
         THEN
            hr_utility.TRACE ('---- Before Call to Record Time API ----');
            hr_utility.TRACE ('employee_number is ' || p_employee_number);
            hr_utility.TRACE ('approver_number is ' || p_approver_number);
            hr_utility.TRACE (   'date_worked is '
                              || TO_CHAR (p_date_worked, 'DD-MON-YYYY')
                             );
            hr_utility.TRACE (   'start_time is '
                              || TO_CHAR (p_start_time,
                                          'DD-MON-YYYY HH:MI:SS')
                             );
            hr_utility.TRACE (   'end_time is '
                              || TO_CHAR (p_end_time, 'DD-MON-YYYY HH:MI:SS')
                             );
            hr_utility.TRACE ('hours is  ' || TO_CHAR (p_hours));
            hr_utility.TRACE ('hours_type is ' || p_hours_type);
            hr_utility.TRACE ('earning_policy is ' || p_earning_policy);
            hr_utility.TRACE ('project is ' || p_project);
            hr_utility.TRACE ('task is ' || p_task);
            hr_utility.TRACE ('location is ' || p_location);
            hr_utility.TRACE ('rate_multiple is  '
                              || TO_CHAR (p_rate_multiple)
                             );
            hr_utility.TRACE ('hourly_rate is  ' || TO_CHAR (p_rate_multiple));
            hr_utility.TRACE ('amount is  ' || TO_CHAR (p_amount));
            hr_utility.TRACE (   'time_summary_id is  '
                              || TO_CHAR (p_time_summary_id)
                             );
            hr_utility.TRACE (   'time_sum_start_date is '
                              || TO_CHAR (p_time_sum_start_date,
                                          'DD-MON-YYYY')
                             );
            hr_utility.TRACE (   'time_sum_end_date is '
                              || TO_CHAR (p_time_sum_end_date, 'DD-MON-YYYY')
                             );
         END IF;

--
         hxt_time_collection.record_time
                      (timecard_source                => 'Time Store',
                       batch_ref                      => p_batch_ref,
                       batch_name                     => p_batch_name,
                       approver_number                => p_approver_number,
                       employee_number                => p_employee_number,
                       date_worked                    => p_date_worked,
                       start_time                     => p_start_time,
                       end_time                       => p_end_time,
                       hours                          => p_hours,
                       wage_code                      => NULL,
                       earning_policy                 => p_earning_policy,
                       hours_type                     => p_hours_type,
                       earn_reason_code               => p_earn_reason_code,
                       project                        => p_project,
                       task_number                    => p_task,
                       location_code                  => p_location,
                       COMMENT                        => p_comment,
                       rate_multiple                  => p_rate_multiple,
                       hourly_rate                    => p_hourly_rate,
                       amount                         => p_amount,
                       separate_check_flag            => p_sep_check_flag,
                       business_group_id              => p_bg_id
--              ,concat_cost_segments      =>
         ,
                       cost_segment1                  => p_segment (1),
                       cost_segment2                  => p_segment (2),
                       cost_segment3                  => p_segment (3),
                       cost_segment4                  => p_segment (4),
                       cost_segment5                  => p_segment (5),
                       cost_segment6                  => p_segment (6),
                       cost_segment7                  => p_segment (7),
                       cost_segment8                  => p_segment (8),
                       cost_segment9                  => p_segment (9),
                       cost_segment10                 => p_segment (10),
                       cost_segment11                 => p_segment (11),
                       cost_segment12                 => p_segment (12),
                       cost_segment13                 => p_segment (13),
                       cost_segment14                 => p_segment (14),
                       cost_segment15                 => p_segment (15),
                       cost_segment16                 => p_segment (16),
                       cost_segment17                 => p_segment (17),
                       cost_segment18                 => p_segment (18),
                       cost_segment19                 => p_segment (19),
                       cost_segment20                 => p_segment (20),
                       cost_segment21                 => p_segment (21),
                       cost_segment22                 => p_segment (22),
                       cost_segment23                 => p_segment (23),
                       cost_segment24                 => p_segment (24),
                       cost_segment25                 => p_segment (25),
                       cost_segment26                 => p_segment (26),
                       cost_segment27                 => p_segment (27),
                       cost_segment28                 => p_segment (28),
                       cost_segment29                 => p_segment (29),
                       cost_segment30                 => p_segment (30),
                       time_summary_id                => p_time_summary_id,
                       tim_sum_eff_start_date         => p_time_sum_start_date,
                       tim_sum_eff_end_date           => p_time_sum_end_date,
                       created_by                     => '-1',
                       last_updated_by                => '-1',
                       last_update_login              => '-1',
--              ,writesum_yn               =>
                       explode_yn                     => 'N',
                       delete_yn                      => p_delete,
                       dt_update_mode                 => 'CORRECTION',
                       created_tim_sum_id             => l_created_tim_sum_id,
                       otm_error                      => l_otm_error,
                       oracle_error                   => l_oracle_error,
                       p_time_building_block_id       => p_time_building_block_id,
                       p_time_building_block_ovn      => p_time_building_block_ovn,
                       p_validate                     => FALSE,
                       p_state_name                   => p_state_name,
                       p_county_name                  => p_county_name,
                       p_city_name                    => p_city_name,
                       p_zip_code                     => p_zip_code
                      );

--
         IF l_otm_error IS NOT NULL
         THEN
            --
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HXT_DEP_VAL_OTMERR');
            fnd_message.set_token ('ERROR', l_otm_error);
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_record_error;
         --
         END IF;

--
         IF l_oracle_error IS NOT NULL
         THEN
            --
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HXT_DEP_VAL_ORAERR');
            fnd_message.set_token ('ERROR', l_oracle_error);
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_record_error;
         --
         END IF;

--
         OPEN get_timecard_id (p_tim_sum_id => l_created_tim_sum_id);

         FETCH get_timecard_id
          INTO l_timecard_id, l_time_period_id;

         CLOSE get_timecard_id;

         -- Bug 8888777
         -- Added the following code to update
         -- picked up element input values into the summary table.
         IF  g_iv_table.EXISTS(p_time_building_block_id)
         THEN
            IF g_debug
            THEN
               hr_utility.trace('There exists some input values, need to update them');
               hr_utility.trace(' l_created_sum_id :'||l_created_tim_sum_id);
               hr_utility.trace(' bb_id :'||p_time_building_block_id);
               hr_utility.trace(' attribute1 : '||g_iv_table(p_time_building_block_id).attribute1 );
               hr_utility.trace(' attribute2 : '||g_iv_table(p_time_building_block_id).attribute2 );
               hr_utility.trace(' attribute3 : '||g_iv_table(p_time_building_block_id).attribute3 );
               hr_utility.trace(' attribute4 : '||g_iv_table(p_time_building_block_id).attribute4 );
               hr_utility.trace(' attribute5 : '||g_iv_table(p_time_building_block_id).attribute5 );
               hr_utility.trace(' attribute6 : '||g_iv_table(p_time_building_block_id).attribute6 );
               hr_utility.trace(' attribute7 : '||g_iv_table(p_time_building_block_id).attribute7 );
               hr_utility.trace(' attribute8 : '||g_iv_table(p_time_building_block_id).attribute8 );
               hr_utility.trace(' attribute9 : '||g_iv_table(p_time_building_block_id).attribute9 );
               hr_utility.trace(' attribute10 :'||g_iv_table(p_time_building_block_id).attribute10);
               hr_utility.trace(' attribute11 :'||g_iv_table(p_time_building_block_id).attribute11);
               hr_utility.trace(' attribute12 :'||g_iv_table(p_time_building_block_id).attribute12);
               hr_utility.trace(' attribute13 :'||g_iv_table(p_time_building_block_id).attribute13);
               hr_utility.trace(' attribute14 :'||g_iv_table(p_time_building_block_id).attribute14);
               hr_utility.trace(' attribute15 :'||g_iv_table(p_time_building_block_id).attribute15);
            END IF;

            UPDATE hxt_sum_hours_worked_f
               SET attribute1 = g_iv_table(p_time_building_block_id).attribute1,
                   attribute2 = g_iv_table(p_time_building_block_id).attribute2,
                   attribute3 = g_iv_table(p_time_building_block_id).attribute3,
                   attribute4 = g_iv_table(p_time_building_block_id).attribute4,
                   attribute5 = g_iv_table(p_time_building_block_id).attribute5,
                   attribute6 = g_iv_table(p_time_building_block_id).attribute6,
                   attribute7 = g_iv_table(p_time_building_block_id).attribute7,
                   attribute8 = g_iv_table(p_time_building_block_id).attribute8,
                   attribute9 = g_iv_table(p_time_building_block_id).attribute9,
                   attribute10 = g_iv_table(p_time_building_block_id).attribute10,
                   attribute11 = g_iv_table(p_time_building_block_id).attribute11,
                   attribute12 = g_iv_table(p_time_building_block_id).attribute12,
                   attribute13 = g_iv_table(p_time_building_block_id).attribute13,
                   attribute14 = g_iv_table(p_time_building_block_id).attribute14,
                   attribute15 = g_iv_table(p_time_building_block_id).attribute15
            WHERE id = l_created_tim_sum_id
              AND time_building_block_id = p_time_building_block_id
              AND time_building_block_ovn = p_time_building_block_ovn ; -- Bug 9159142
        END IF;


--
         IF g_debug
         THEN
            hr_utility.TRACE (   'TIM_SUM_ID IS : '
                              || TO_CHAR (l_created_tim_sum_id)
                             );
            hr_utility.TRACE ('l_timecard_id is : ' || TO_CHAR (l_timecard_id));
         END IF;

--
         IF (NOT g_timecards.EXISTS (l_timecard_id))
         THEN
            g_timecards (l_timecard_id) := l_timecard_id;
         END IF;
--
--
      END record_time;

--
-------------------------- transfer_to_bee -----------------------------
--
      PROCEDURE transfer_to_bee (
         p_bg_id         IN   NUMBER,
         p_batch_id      IN   NUMBER,
         p_date_earned   IN   DATE,
         p_batch_ref     IN   VARCHAR2
      )
      IS
         l_errbuf    VARCHAR2 (512) DEFAULT NULL;
         l_retcode   NUMBER (9);
--
      BEGIN
         hxt_batch_process.main_process (errbuf                => l_errbuf,
                                         retcode               => l_retcode,
                                         p_payroll_id          => NULL
                                                                      -- NOT USED
         ,
                                         p_date_earned         => p_date_earned
--        ,p_time_period_id       => l_time_period_id -- DEFAULT NULL
         ,
                                         p_from_batch_num      => p_batch_id,
                                         p_to_batch_num        => p_batch_id,
                                         p_ref_num             => p_batch_ref,
                                         p_process_mode        => 'V'
                                                                     -- Validate
         ,
                                         p_bus_group_id        => p_bg_id
                                        );

--
         IF l_retcode <> 0
         THEN
            NULL;
         END IF;

--
         IF g_debug
         THEN
            hr_utility.set_location (c_proc, 7);
         END IF;

--
         hxt_batch_process.main_process (errbuf                => l_errbuf,
                                         retcode               => l_retcode,
                                         p_payroll_id          => NULL
                                                                      -- NOT USED
         ,
                                         p_date_earned         => p_date_earned
--        ,p_time_period_id       => l_time_period_id -- DEFAULT NULL
         ,
                                         p_from_batch_num      => p_batch_id
                                                                            -- DEFAULT NULL
         ,
                                         p_to_batch_num        => p_batch_id
                                                                            -- DEFAULT NULL
         ,
                                         p_ref_num             => p_batch_ref,
                                         p_process_mode        => 'T'
                                                                     -- Transfer
         ,
                                         p_bus_group_id        => p_bg_id
                                        );

--
         IF l_retcode <> 0
         THEN
            NULL;
         END IF;
--
      END transfer_to_bee;

--
------------------------ transfer_to_bee_retro ---------------------------
--
      PROCEDURE transfer_to_bee_retro (
         p_bg_id            IN   NUMBER,
         p_retro_batch_id   IN   NUMBER,
         p_date_earned      IN   DATE,
         p_batch_ref        IN   VARCHAR2
      )
      IS
         l_errbuf    VARCHAR2 (512) DEFAULT NULL;
         l_retcode   NUMBER (9);
--
      BEGIN
         hxt_retro_process.main_retro (errbuf                => l_errbuf,
                                       retcode               => l_retcode,
                                       p_payroll_id          => NULL
                                                                    -- NOT USED
         ,
                                       p_date_earned         => p_date_earned,
                                       p_retro_batch_id      => p_retro_batch_id,
                                       p_ref_num             => p_batch_ref,
                                       p_process_mode        => 'V',
                                       p_bus_group_id        => p_bg_id
                                      );
--
         hxt_retro_process.main_retro (errbuf                => l_errbuf,
                                       retcode               => l_retcode,
                                       p_payroll_id          => NULL
                                                                    -- NOT USED
         ,
                                       p_date_earned         => p_date_earned,
                                       p_retro_batch_id      => p_retro_batch_id,
                                       p_ref_num             => p_batch_ref,
                                       p_process_mode        => 'T',
                                       p_bus_group_id        => p_bg_id
                                      );
      END transfer_to_bee_retro;

--
--------------------------- create_batch ---------------------------------
--
      PROCEDURE create_batch (
         p_batch_name     IN              VARCHAR2,
         p_batch_ref      IN              VARCHAR2,
         p_batch_source   IN              VARCHAR2,
         p_batch_id       OUT NOCOPY      NUMBER,
         p_bg_id          IN              NUMBER,
         p_session_date   IN              DATE
      )
      IS
         l_object_version_number   NUMBER (9);
      BEGIN
         pay_batch_element_entry_api.create_batch_header
                          (p_validate                      => FALSE,
                           p_session_date                  => p_session_date,
                           p_batch_name                    => p_batch_name,
                           p_batch_status                  => 'U'
                                                                 -- DEFAULT 'U'
         ,
                           p_business_group_id             => p_bg_id,
                           p_action_if_exists              => 'R'
                                                                 -- DEFAULT 'R'
         ,
                           p_batch_reference               => p_batch_ref,
                           p_batch_source                  => p_batch_source,
                           p_comments                      => NULL
                                                                  -- DEFAULT NULL
         ,
                           p_date_effective_changes        => 'C'
                                                                 -- DEFAULT 'C'
         ,
                           p_purge_after_transfer          => 'N'
                                                                 -- DEFAULT 'N'
         ,
                           p_reject_if_future_changes      => 'Y'
                                                                 -- DEFAULT 'Y'
         ,
                           p_batch_id                      => p_batch_id,
                           p_object_version_number         => l_object_version_number
                          );
      EXCEPTION
         WHEN OTHERS
         THEN
            g_status := 'ERRORS';
            fnd_message.set_name ('HXC', 'HXC_HRPAY_RET_BATCH_HDR_API');
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
            RAISE e_retrieval_error;
      END create_batch;

--
--------------------------- get_assignment_info ---------------------------
--
      PROCEDURE get_assignment_info (
         p_person_id        IN              NUMBER,
         p_payroll_id       OUT NOCOPY      NUMBER,
         p_bg_id            OUT NOCOPY      NUMBER,
         p_assignment_id    OUT NOCOPY      NUMBER,
         p_effective_date   IN              DATE
      )
      IS
      BEGIN
--
         BEGIN
            --
            SELECT paf.payroll_id, paf.business_group_id, paf.assignment_id
              INTO p_payroll_id, p_bg_id, p_assignment_id
              FROM per_all_assignments_f paf
             WHERE paf.person_id = p_person_id
               AND p_effective_date BETWEEN paf.effective_start_date
                                        AND paf.effective_end_date
               AND paf.assignment_type = 'E'
               AND paf.primary_flag = 'Y';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               g_status := 'ERRORS';
               fnd_message.set_name ('HXC', 'HXC_HRPAY_RET_NO_ASSIGN');
               fnd_message.set_token ('PERSON_NAME', g_full_name);
               g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
               RAISE e_record_error;
               RETURN;
         END;
--
      END get_assignment_info;

--
--------------------------- get_batch_info -------------------------------
--
      FUNCTION get_batch_info (
         p_batch_ref      IN              VARCHAR2,
         p_count_header   IN OUT NOCOPY   NUMBER,
         p_count_lines    IN OUT NOCOPY   NUMBER,
         p_retro          IN              VARCHAR2,
         p_created        OUT NOCOPY      VARCHAR2
      )
         RETURN VARCHAR2
      IS
-- local vars
-- l_batch_ref        VARCHAR2(30);
         l_batch_name       VARCHAR2 (30);
         l_retro_batch_id   NUMBER (15);
         l_batch_lines      NUMBER;
      BEGIN
--
         IF g_debug
         THEN
            hr_utility.set_location
                               ('HXT_OTC_RETRIEVAL_INTERFACE.get_batch_info',
                                1
                               );
         END IF;

--
         IF p_retro = 'N'
         THEN
            BEGIN
               SELECT MAX (pbh.batch_name)
                 INTO l_batch_name
                 FROM pay_batch_headers pbh
                WHERE pbh.batch_reference LIKE p_batch_ref || '%'
                  AND pbh.batch_reference NOT LIKE '%RETRO%'
                  AND pbh.batch_status NOT IN ('T', 'TW');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_batch_name := NULL;
            END;
         ELSE
            BEGIN
               SELECT MAX (pbh.batch_name)
                 INTO l_batch_name
                 FROM pay_batch_headers pbh
                WHERE pbh.batch_reference LIKE p_batch_ref || '%'
                  AND pbh.batch_status NOT IN ('T', 'TW');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_batch_name := NULL;
            END;
         END IF;

--
         IF g_debug
         THEN
            hr_utility.set_location
                               ('HXT_OTC_RETRIEVAL_INTERFACE.get_batch_info',
                                2
                               );
         END IF;

--
         IF l_batch_name IS NOT NULL
         THEN
            SELECT COUNT (pbl.batch_line_id)
              INTO l_batch_lines
              FROM pay_batch_lines pbl, pay_batch_headers pbh
             WHERE pbh.batch_name = l_batch_name
               AND pbl.batch_id = pbh.batch_id;

            --
            IF g_debug
            THEN
               hr_utility.set_location
                               ('HXT_OTC_RETRIEVAL_INTERFACE.get_batch_info',
                                3
                               );
            END IF;

            --
            IF l_max_batches > l_batch_lines
            THEN
               p_count_lines := l_batch_lines;
               p_count_header :=
                  TO_NUMBER (REPLACE (l_batch_name,
                                      REPLACE (p_batch_ref, ' ', '_') || '_'
                                     )
                            );
               p_created := 'Y';
            ELSE
               p_count_lines := 0;
               p_count_header :=
                    TO_NUMBER (REPLACE (l_batch_name,
                                        REPLACE (p_batch_ref, ' ', '_') || '_'
                                       )
                              )
                  + 1;
               l_batch_name :=
                     REPLACE (p_batch_ref, ' ', '_')
                  || '_'
                  || TO_CHAR (p_count_header);
               p_created := 'N';
            END IF;

            --
            IF g_debug
            THEN
               hr_utility.set_location
                               ('HXT_OTC_RETRIEVAL_INTERFACE.get_batch_info',
                                4
                               );
            END IF;
         --
         ELSE
            l_batch_name :=
                  REPLACE (p_batch_ref, ' ', '_')
               || '_'
               || TO_CHAR (p_count_header + 1);
            p_created := 'N';
         END IF;

--
         IF g_debug
         THEN
            hr_utility.set_location
                               ('HXT_OTC_RETRIEVAL_INTERFACE.get_batch_info',
                                5
                               );
         END IF;

--
         RETURN (l_batch_name);
--
      END get_batch_info;

--
------------------------------- set_transaction --------------------------
--
      PROCEDURE set_transaction (
         p_bb_id      IN   NUMBER,
         p_bb_index   IN   BINARY_INTEGER,
         p_status     IN   VARCHAR2,
         p_excep      IN   VARCHAR2
      )
      IS
      BEGIN
--
         IF g_debug
         THEN
            hr_utility.TRACE ('----- In procedure set_transaction -----');
            hr_utility.TRACE ('Setting status for bb_id ' || TO_CHAR (p_bb_id)
                             );
            hr_utility.TRACE ('Status is ' || p_status);
            hr_utility.TRACE ('Exception is ' || p_excep);
         END IF;

         IF (hxc_generic_retrieval_pkg.t_tx_detail_bb_id (p_bb_index) <>
                                                                       p_bb_id
            )
         THEN
            fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
            fnd_message.set_token ('PROCEDURE', 'set_transaction');
            fnd_message.set_token ('STEP', 'status bb id mismatch');
            fnd_message.raise_error;
         END IF;

         hxc_generic_retrieval_pkg.t_tx_detail_status (p_bb_index) := p_status;
         hxc_generic_retrieval_pkg.t_tx_detail_exception (p_bb_index) :=
                                                                       p_excep;

         IF g_debug
         THEN
            hr_utility.TRACE ('----- Done setting status -----');
         END IF;
      END set_transaction;
--
-------------------------- transfer_to_otm Main --------------------
--
-- Main Procedure
   BEGIN
      g_debug := hr_utility.debug_enabled;

--
--
--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 1);
      END IF;

--
      g_timecards.DELETE;
      p_no_otm := 'N';
      g_bg_id := p_bg_id;

--
      IF g_debug
      THEN
         hr_utility.TRACE ('****** Parameters are: ******');
         hr_utility.TRACE ('p_bg_id is: ' || TO_CHAR (p_bg_id));
         hr_utility.TRACE ('p_incremental is: ' || p_incremental);
         hr_utility.TRACE ('p_start_date is: ' || p_start_date);
         hr_utility.TRACE ('p_end_date is: ' || p_end_date);
         hr_utility.TRACE (   'p_retrieval_transaction_code is: '
                           || p_retrieval_transaction_code
                          );
         hr_utility.TRACE ('p_batch_ref is: ' || p_batch_ref);
         hr_utility.TRACE ('p_transfer_to_bee is: ' || p_transfer_to_bee);
      END IF;

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 10);
      END IF;

--
-- Set session date
      pay_db_pay_setup.set_session_date (SYSDATE);
      l_start_date := fnd_date.canonical_to_date (p_start_date);
      l_end_date := fnd_date.canonical_to_date (p_end_date);
--
-- Change it now that OTM is not a time recipient.
--
      l_process_name := 'Apply Schedule Rules';

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 20);
      END IF;

--
-- Initialize batch counters
--
      l_count_batch_lines := 0;
      l_count_batch_head := 0;
      l_count_timecards := 0;
/*
l_batch_name := get_batch_info(p_batch_ref,
                               l_count_batch_head,
                               l_count_batch_lines,
                               'N',
                l_batch_created);
*/
      l_batch_ref := p_batch_ref || ' X';
      l_batch_name := REPLACE (l_batch_ref, ' ', '_') || '_';

--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 30);
         hr_utility.set_location (c_proc, 40);
      END IF;

--
/*
l_retro_count_batch_lines := 0;
l_retro_count_batch_head := 0;
l_retro_batch_name := get_batch_info(p_batch_ref || ' RETRO',
                              l_retro_count_batch_head,
                              l_retro_count_batch_lines,
                              'Y',
               l_retro_batch_created);
*/
--
      IF g_debug
      THEN
         hr_utility.set_location (c_proc, 50);
         hr_utility.set_location (c_proc, 60);
      END IF;

--
--
      l_where_clause := p_where_clause;

--
      IF g_debug
      THEN
         hr_utility.TRACE ('l_where_clause is: ' || l_where_clause);
         hr_utility.set_location (c_proc, 70);
      END IF;

--
---------------------------- Call Generic Retrieval -----------------------
--
      IF g_debug
      THEN
         hr_utility.TRACE ('--- Calling Generic Retrieval ---');
      END IF;

--
      WHILE (NOT l_no_more_timecards)
      LOOP
         g_timecards.DELETE;
         l_last_att_index := NULL;
         l_old_last_att_index := NULL;
         l_old_bb_index := NULL;                   -- GPM v115.45 WWB 3245991
         hxc_generic_retrieval_pkg.execute_retrieval_process
                         (p_process               => l_process_name,
                          p_transaction_code      => p_retrieval_transaction_code,
                          p_start_date            => l_start_date,
                          p_end_date              => l_end_date,
                          p_incremental           => p_incremental,
                          p_rerun_flag            => 'N',
                          p_where_clause          => l_where_clause,
                          p_scope                 => 'DAY',
                          p_clusive               => 'IN',
                          p_unique_params         => p_unique_params,
                          p_since_date            => p_since_date
                         );

--
         OPEN get_debug;

         FETCH get_debug
          INTO l_debug;

         IF get_debug%FOUND
         THEN
            hr_utility.trace_on (NULL, 'RET_OTM');
         END IF;

         CLOSE get_debug;

--
         IF g_debug
         THEN
            hr_utility.TRACE ('--- Returned from Generic Retrieval ---');
            hr_utility.set_location (c_proc, 80);
         END IF;

--
----------------------------- Transfer to BEE -----------------------------
--
-- g_cnt_t_bld_blks       := hxc_generic_retrieval_pkg.t_bld_blks.COUNT;
         g_cnt_t_attributes := hxc_generic_retrieval_pkg.t_attributes.COUNT;
         g_cnt_t_detail_bld_blks :=
                             hxc_generic_retrieval_pkg.t_detail_bld_blks.COUNT;
         g_cnt_t_detail_attributes :=
                           hxc_generic_retrieval_pkg.t_detail_attributes.COUNT;
         g_cnt_t_day_bld_blks :=
                                hxc_generic_retrieval_pkg.t_day_bld_blks.COUNT;
--
         g_cnt_t_old_day_bld_blks :=
                            hxc_generic_retrieval_pkg.t_old_day_bld_blks.COUNT;
         g_cnt_t_old_detail_bld_blks :=
                         hxc_generic_retrieval_pkg.t_old_detail_bld_blks.COUNT;
         g_cnt_t_old_detail_attributes :=
                       hxc_generic_retrieval_pkg.t_old_detail_attributes.COUNT;
--
         g_cnt_t_tx_det_bb_id :=
                             hxc_generic_retrieval_pkg.t_tx_detail_bb_id.COUNT;
         g_cnt_t_tx_det_status :=
                            hxc_generic_retrieval_pkg.t_tx_detail_status.COUNT;
         g_cnt_t_tx_det_exception :=
                         hxc_generic_retrieval_pkg.t_tx_detail_exception.COUNT;

--
-- FOR l_cnt in 1 .. g_cnt_t_detail_bld_blks LOOP
         IF hxc_generic_retrieval_pkg.t_detail_bld_blks.COUNT <> 0
         THEN
--
            FOR l_cnt IN
               hxc_generic_retrieval_pkg.t_detail_bld_blks.FIRST .. hxc_generic_retrieval_pkg.t_detail_bld_blks.LAST
            LOOP
               BEGIN
                  l_bb_id :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).bb_id;
                  l_ovn :=
                      hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).ovn;
                  l_type :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).TYPE;
                  l_measure :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).measure;
                  l_start_time :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).start_time;
                  l_stop_time :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).stop_time;
                  l_parent_bb_id :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).parent_bb_id;
                  l_scope :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).SCOPE;
                  l_resource_id :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).resource_id;
                  l_resource_type :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).resource_type;
                  l_comment_text :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).comment_text;
                  l_changed :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).changed;
                  l_deleted :=
                     hxc_generic_retrieval_pkg.t_detail_bld_blks (l_cnt).deleted;
                  l_no_times := 'N';


                  -- Bug 8888777
                  -- Clear any left over data.
                  g_iv_table.DELETE(l_bb_id);

                  --
                  IF g_debug
                  THEN
                     hr_utility.set_location (c_proc, 90);
                     --
                     hr_utility.TRACE ('--------------------------------');
                     hr_utility.TRACE ('In Building Block Loop');
                     hr_utility.TRACE ('l_type is ' || l_type);
                     hr_utility.TRACE ('l_measure is ' || l_measure);
                     hr_utility.TRACE (   'l_start_time is '
                                       || TO_CHAR (l_start_time,
                                                   'DD-MON-YYYY HH:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'l_stop_time is '
                                       || TO_CHAR (l_stop_time,
                                                   'DD-MON-YYYY HH:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE ('l_scope is ' || l_scope);
                     hr_utility.TRACE (   'l_resource_id is '
                                       || TO_CHAR (l_resource_id)
                                      );
                     hr_utility.TRACE ('l_resource_type is '
                                       || l_resource_type
                                      );
                     hr_utility.TRACE ('l_changed is ' || l_changed);
                     hr_utility.TRACE ('l_deleted is ' || l_deleted);
                     hr_utility.trace ('OTL: l_old_bb_index is '||l_old_bb_index);
                     hr_utility.TRACE ('--------------------------------');
                  END IF;

                  IF l_scope = 'DETAIL'
                  THEN
                     -- Get the start time from the parent block if it is a measure
                     -- building block, which is a day block
                     IF l_type = 'MEASURE'
                     THEN
                        l_no_times := 'Y';
                     END IF;

                     IF l_type = 'MEASURE' AND l_start_time IS NULL
                     THEN
                        FOR l_bb_cnt IN
                           hxc_generic_retrieval_pkg.t_day_bld_blks.FIRST .. hxc_generic_retrieval_pkg.t_day_bld_blks.LAST
                        LOOP
                           --
                           IF     (l_parent_bb_id =
                                      hxc_generic_retrieval_pkg.t_day_bld_blks
                                                                     (l_bb_cnt).bb_id
                                  )
                              AND (hxc_generic_retrieval_pkg.t_day_bld_blks
                                                                     (l_bb_cnt).SCOPE =
                                                                         'DAY'
                                  )
                           THEN
                              --
                              l_start_time :=
                                 hxc_generic_retrieval_pkg.t_day_bld_blks
                                                                    (l_bb_cnt).start_time;
                              l_stop_time :=
                                 hxc_generic_retrieval_pkg.t_day_bld_blks
                                                                    (l_bb_cnt).stop_time;
                              l_no_times := 'Y';

                              --
                              IF g_debug
                              THEN
                                 hr_utility.TRACE
                                             (   'l_start_time is '
                                              || TO_CHAR
                                                       (l_start_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                             );
                                 hr_utility.TRACE
                                              (   'l_stop_time is '
                                               || TO_CHAR
                                                       (l_stop_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                              );
                              END IF;

                              --
                              EXIT;
                           END IF;
                        END LOOP;
                     END IF;

                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 100);
                     END IF;

                     --
                     IF l_resource_type = 'PERSON'
                     THEN
                        l_person_id := l_resource_id;

                        --
                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_person_id is '
                                             || TO_CHAR (l_person_id)
                                            );
                        END IF;
                     --
                     ELSIF l_resource_type = 'ASSIGNMENT'
                     THEN
                        --
                        l_assignment_id := l_resource_id;

                        --
                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_assignment_id is '
                                             || TO_CHAR (l_assignment_id)
                                            );
                        END IF;
                     --
                     END IF;

                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 110);
                     END IF;

                     --
                     l_effective_date := TRUNC (l_start_time);

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'l_effective_date is :'
                                          || TO_CHAR (l_effective_date,
                                                      'DD-MON-YYYY'
                                                     )
                                         );
                     END IF;

                     --
                     BEGIN
                        SELECT full_name
                          INTO g_full_name
                          FROM per_all_people_f
                         WHERE person_id = l_person_id
                           AND l_effective_date BETWEEN effective_start_date
                                                    AND effective_end_date;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           hr_utility.set_message
                                             (800,
                                              'HR_52365_PTU_NO_PERSON_EXISTS'
                                             );
                           l_last_att_index :=
                              sync_attributes
                                 (p_att_table           => hxc_generic_retrieval_pkg.t_detail_attributes,
                                  p_bb_id               => l_bb_id,
                                  p_last_att_index      => l_last_att_index
                                 );
                           l_old_last_att_index :=
                              sync_attributes
                                 (p_att_table           => hxc_generic_retrieval_pkg.t_old_detail_attributes,
                                  p_bb_id               => l_bb_id,
                                  p_last_att_index      => l_old_last_att_index
                                 );
                           hr_utility.raise_error;
                     END;

                     --
                     -- Get the attributes of the detail record.
                     --
                     -- Reset all tables
                     --
                     l_field_name.DELETE;
                     l_value.DELETE;
                     l_context.DELETE;
                     l_category.DELETE;
                     --
                     get_attributes
                               (hxc_generic_retrieval_pkg.t_detail_attributes,
                                l_bb_id,
                                l_field_name,
                                l_value,
                                l_context,
                                l_category,
                                l_last_att_index,
                                l_element_id
                               );

                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 120);
                     END IF;

                     --
                     -- If there is a mapping set up for the assignment_id, get the assignment
                     -- id from the attribute, else get it from the person id.
                     -- Also, get the element_name.
                     --
                     IF l_field_name.COUNT <> 0
                     THEN
                        FOR attr_cnt IN
                           l_field_name.FIRST .. l_field_name.LAST
                        LOOP
                           --
                           IF UPPER (l_field_name (attr_cnt)) =
                                                            'P_ASSIGNMENT_ID'
                           THEN
                              l_assignment_id :=
                                               TO_NUMBER (l_value (attr_cnt));
                           ELSIF UPPER (l_field_name (attr_cnt)) =
                                                         'P_ASSIGNMENT_NUMBER'
                           THEN
                              l_assignment_number := l_value (attr_cnt);
                           END IF;
                        --
                        END LOOP;
                     END IF;

                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 130);
                     END IF;

                     --
                     -- Get payroll id
                     --
                     get_assignment_info (l_person_id,
                                          l_payroll_id,
                                          l_bg_id,
                                          l_assignment_id,
                                          l_effective_date
                                         );

                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 140);
                        hr_utility.TRACE
                                 ('--- After Call to get_assignment_info ---');
                        hr_utility.TRACE (   'Person IDs are '
                                          || TO_CHAR (l_person_id)
                                         );
                        hr_utility.TRACE (   'Payroll IDs are '
                                          || TO_CHAR (l_payroll_id)
                                         );
                        hr_utility.TRACE (   'bg IDs are '
                                          || TO_CHAR (l_bg_id)
                                          || ' AND '
                                          || TO_CHAR (p_bg_id)
                                         );
                     END IF;

                     --
                     IF l_person_id IS NOT NULL AND l_bg_id = p_bg_id
                     THEN
                        --
                        IF g_debug
                        THEN
                           hr_utility.set_location (c_proc, 150);
                           hr_utility.TRACE ('Inside IF');
                        END IF;

                             --
                             -- Get the attributes of the detail record
                        --
                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                      (   'g_cnt_t_detail_bld_blks count is '
                                       || TO_CHAR (g_cnt_t_detail_bld_blks)
                                      );
                        END IF;

                        --
                        IF l_changed = 'Y' AND p_incremental = 'Y'
                        THEN
                           --
                                -- Get the old data
                           --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 160);
                              hr_utility.TRACE
                                 (   'Get old building block info for bb id: '
                                  || TO_CHAR (l_bb_id)
                                 );
                           END IF;

                           l_old_bb_index :=
                              NVL
                                 (l_old_bb_index,
                                  hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
                                 );

                           --
                           IF g_debug
                           THEN
                              hr_utility.TRACE ('Before IF');
                              hr_utility.TRACE
                                 (   'g_cnt_t_old_detail_bld_blks count is '
                                  || TO_CHAR
                                        (hxc_generic_retrieval_pkg.t_old_detail_bld_blks.COUNT
                                        )
                                 );
                              hr_utility.TRACE (   'l_old_bb_index IS : '
                                                || TO_CHAR (l_old_bb_index)
                                               );
                              hr_utility.TRACE (   'l_cnt IS : '
                                                || TO_CHAR (l_cnt)
                                               );
                           END IF;

                           --

                           -- Bug 6621627
                           -- No functional change here, just moved the IF condition
                           -- outside the loop. Was looping and the condition being checked
                           -- each time. Need to loop only if you have trace enabled.

                           IF g_debug
                           THEN
                           FOR i IN
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST .. hxc_generic_retrieval_pkg.t_old_detail_bld_blks.LAST
                           LOOP
                                 hr_utility.TRACE
                                    (   'BB ID IS : '
                                     || TO_CHAR
                                           (hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                                           (i).bb_id
                                           )
                                    );
                                 hr_utility.TRACE ('i is : ' || TO_CHAR (i));
                           END LOOP;
                           END IF;



                                --
                           -- IF hxc_generic_retrieval_pkg.t_old_detail_bld_blks(l_cnt).bb_id <> l_bb_id
                           IF hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).bb_id <>
                                                                       l_bb_id
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.TRACE
                                                 ('in old bb id exception!!!');
                              END IF;

                              fnd_message.set_name
                                                 ('PAY',
                                                  'HR_6153_ALL_PROCEDURE_FAIL'
                                                 );
                              fnd_message.set_token ('PROCEDURE',
                                                     'transfer to otm'
                                                    );
                              fnd_message.set_token ('STEP',
                                                     'bld blk mismatch'
                                                    );
                              fnd_message.raise_error;
                           END IF;

                           --
                           IF g_debug
                           THEN
                              hr_utility.TRACE ('After IF');
                           END IF;

                           --
                           l_old_ovn :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).ovn;
                           l_old_type :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).TYPE;
                           l_old_measure :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).measure;
                           l_old_start_time :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).start_time;
                           l_old_stop_time :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).stop_time;
                           l_old_parent_bb_id :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).parent_bb_id;
                           l_old_scope :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).SCOPE;
                           l_old_resource_id :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).resource_id;
                           l_old_resource_type :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).resource_type;
                           l_old_comment_text :=
                              hxc_generic_retrieval_pkg.t_old_detail_bld_blks
                                                               (l_old_bb_index).comment_text;
                           l_no_old_times := 'N';

                           -- Bug 9308216
                           -- Commenting this out, and doing it at the end of the loop.
                           --l_old_bb_index := l_old_bb_index + 1;
                           IF g_debug
                           THEN
                              hr_utility.trace('OTL: Old bb index was incremented here -- moved below');
                              hr_utility.trace('OTL: Old bb index still is '||l_old_bb_index);
                           END IF;

                           IF l_old_type = 'MEASURE'
                           THEN
                              l_no_old_times := 'Y';
                           END IF;

                           --
                           IF     l_old_type = 'MEASURE'
                              AND l_old_start_time IS NULL
                           THEN
                              FOR l_old_bb_cnt IN
                                 hxc_generic_retrieval_pkg.t_old_day_bld_blks.FIRST .. hxc_generic_retrieval_pkg.t_old_day_bld_blks.LAST
                              LOOP
                                 --
                                 IF g_debug
                                 THEN
                                    hr_utility.set_location (c_proc, 170);
                                    hr_utility.TRACE
                                              ('Get old start and stop times');
                                 END IF;

                                 --
                                 IF     (l_old_parent_bb_id =
                                            hxc_generic_retrieval_pkg.t_old_day_bld_blks
                                                                 (l_old_bb_cnt).bb_id
                                        )
                                    AND hxc_generic_retrieval_pkg.t_old_day_bld_blks
                                                                 (l_old_bb_cnt).SCOPE =
                                                                         'DAY'
                                 THEN
                                    --
                                    l_old_start_time :=
                                       hxc_generic_retrieval_pkg.t_old_day_bld_blks
                                                                (l_old_bb_cnt).start_time;
                                    l_old_stop_time :=
                                       hxc_generic_retrieval_pkg.t_old_day_bld_blks
                                                                (l_old_bb_cnt).stop_time;
                                    l_no_old_times := 'Y';

                                    --
                                    IF g_debug
                                    THEN
                                       hr_utility.TRACE
                                             (   'l_old_start_time is '
                                              || TO_CHAR
                                                       (l_old_start_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                             );
                                       hr_utility.TRACE
                                              (   'l_old_stop_time is '
                                               || TO_CHAR
                                                       (l_old_stop_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                              );
                                    END IF;

                                    --
                                    EXIT;
                                 END IF;
                              END LOOP;
                           END IF;

                           --
                           -- Reset all old tables
                           --
                           l_old_field_name.DELETE;
                           l_old_value.DELETE;
                           l_old_context.DELETE;
                           l_old_category.DELETE;

                           --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 180);
                           END IF;

                           --
                           -- Get the attributes of the old detail record.
                           --
                           IF g_debug
                           THEN
                              hr_utility.TRACE
                                         (   'Get old attributes for bb id: '
                                          || TO_CHAR (l_bb_id)
                                         );
                           END IF;

                           --
                           get_attributes
                              (hxc_generic_retrieval_pkg.t_old_detail_attributes,
                               l_bb_id,
                               l_old_field_name,
                               l_old_value,
                               l_old_context,
                               l_old_category,
                               l_old_last_att_index,
                               l_element_id
                              );

                           --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 190);
                           END IF;
                        --
                        END IF;       -- l_changed is Y and p_incremental is Y

                        --
                        -- Parse attribute Information.
                        --
                        -- Bug 8888777
                        -- Added a new paramter, building_block_id.
                        parse_attributes (p_category           => l_category,
                                          p_field_name         => l_field_name,
                                          p_value              => l_value,
                                          p_context            => l_context,
                                          p_date_worked        => l_date_worked,
                                          p_type               => l_type,
                                          p_measure            => l_measure,
                                          p_start_time         => l_start_time,
                                          p_stop_time          => l_stop_time,
                                          p_assignment_id      => l_assignment_id,
                                          p_hours              => l_hours,
                                          p_hours_type         => l_hours_type,
                                          p_segment            => l_segment,
                                          p_amount             => l_amount,
                                          p_hourly_rate        => l_hourly_rate,
                                          p_rate_multiple      => l_rate_multiple,
                                          p_project            => l_project,
                                          p_task               => l_task,
                                          p_state_name         => l_state_name,
                                          p_county_name        => l_county_name,
                                          p_city_name          => l_city_name,
                                          p_zip_code           => l_zip_code,
                                          p_bb_id              => l_bb_id     -- Bug 8888777
                                         );

                        --
                        IF g_debug
                        THEN
                           hr_utility.set_location (c_proc, 210);
                           hr_utility.set_location (c_proc, 220);
                           hr_utility.set_location (c_proc, 230);
                        END IF;

                        --
                        IF l_changed = 'Y' AND p_incremental = 'Y'
                        THEN
                           --
                           -- Parse the old attributes
                                     --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 240);
                              hr_utility.TRACE ('Parse old attributes.');
                           END IF;

                           --
                           parse_attributes
                                      (p_category           => l_old_category,
                                       p_field_name         => l_old_field_name,
                                       p_value              => l_old_value,
                                       p_context            => l_old_context,
                                       p_date_worked        => l_old_date_worked,
                                       p_type               => l_old_type,
                                       p_measure            => l_old_measure,
                                       p_start_time         => l_old_start_time,
                                       p_stop_time          => l_old_stop_time,
                                       p_assignment_id      => l_assignment_id,
                                       p_hours              => l_old_hours,
                                       p_hours_type         => l_old_hours_type,
                                       p_segment            => l_old_segment,
                                       p_amount             => l_old_amount,
                                       p_hourly_rate        => l_old_hourly_rate,
                                       p_rate_multiple      => l_old_rate_multiple,
                                       p_project            => l_old_project,
                                       p_task               => l_old_task,
                                       p_state_name         => l_old_state_name,
                                       p_county_name        => l_old_county_name,
                                       p_city_name          => l_old_city_name,
                                       p_zip_code           => l_old_zip_code
                                      );

                           --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 270);
                           END IF;
                        --
                        END IF;

                        --
                        -------------------- Create Batch Header --------------------
                        --
                        IF g_debug
                        THEN
                           hr_utility.set_location (c_proc, 280);
                        END IF;

                                      --
                            /*
                            --
                          IF l_count_timecards > l_max_batches THEN
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 290);
                          end if;
                          --
                           -- Reset counter
                           l_count_timecards := 0;

                           -- Increment batch header reference
                           l_count_batch_head := l_count_batch_head + 1;
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 300);
                          end if;
                          --
                          --
                          ------------------- Transfer To BEE -----------------------
                          --
                        if g_debug then
                           hr_utility.set_location(c_proc, 5);
                        end if;
                        --
                          -- Only transfer if the user has asked for it.
                        --
                        IF p_transfer_to_bee = 'Y' THEN
                              --
                              if g_debug then
                                 hr_utility.set_location(c_proc, 6);
                              end if;
                              --
                        transfer_to_bee(p_bg_id          => p_bg_id,
                                   p_batch_id       => l_non_retro_batch_id,
                                   p_date_earned    => l_date_worked,
                                   p_batch_ref      => l_batch_ref);

                          END IF;
                          -- Set up new batch name
                          l_batch_name := replace(l_batch_ref, ' ', '_') ||
                           to_char(l_count_batch_head);
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 310);
                          end if;
                          --
                            END IF;
                          --
                          IF l_retro_count_batch_lines > l_max_batches THEN
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 320);
                          end if;
                          --
                           -- Reset retro counter
                           l_retro_count_batch_lines := 0;
                        --
                           -- Increment retro batch header reference
                           l_retro_count_batch_head := l_retro_count_batch_head + 1;
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 330);
                          end if;
                          --
                          ------------------- Transfer To BEE -----------------------
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 5);
                          end if;
                          --
                          -- Only transfer if the user has asked for it.
                          --
                          IF p_transfer_to_bee = 'Y' THEN
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 6);
                          end if;
                          --
                          transfer_to_bee_retro(p_bg_id      => p_bg_id,
                                p_retro_batch_id   => l_retro_batch_id,
                                p_date_earned      => l_date_worked,
                                p_batch_ref        => l_batch_ref);
                          END IF;
                          --
                          -- Set up new batch name
                          l_retro_batch_name := replace(l_batch_ref, ' ', '_') ||
                            '_RETRO_' ||
                            to_char(l_retro_count_batch_head);
                          --
                          if g_debug then
                             hr_utility.set_location(c_proc, 340);
                          end if;
                          --
                            END IF;
                            */
                        IF g_debug
                        THEN
                           hr_utility.set_location (c_proc, 350);
                        END IF;

                        --
                        --------------------- Create Timecard ---------------------
                        --
                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                          ('---- Before Create Timecard ----');
                        END IF;

                        IF (NOT is_retrievable
                                              (p_sum_id           => l_time_summary_id,
                                               p_date_worked      => l_date_worked,
                                               p_person_id        => l_person_id
                                              )
                           )
                        THEN
                           RAISE e_not_retrievable;
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_employee_number is '
                                             || l_employee_number
                                            );
                        END IF;

                        --
                                  -- Null out start and stop times is flag is set.
                                  --
                        IF l_no_times = 'Y'
                        THEN
                           l_start_time := NULL;
                           l_stop_time := NULL;
                        END IF;

                        --
                        IF l_no_old_times = 'Y'
                        THEN
                           l_old_start_time := NULL;
                           l_old_stop_time := NULL;
                        END IF;

                                  --
                        -- Make a retro entry in OTM
                        --
                        l_time_summary_id := NULL;
                        l_time_sum_start_date := NULL;
                        l_time_sum_end_date := NULL;

                        --
                        IF l_changed = 'Y'
                        THEN
                           --
                           IF g_debug
                           THEN
                              hr_utility.TRACE
                                     ('---- Making retro timecard entry ----');
                              hr_utility.TRACE (   'l_retro_batch_id is '
                                                || TO_CHAR (l_retro_batch_id)
                                               );
                           END IF;

                           --
                           find_existing_timecard
                              (p_payroll_id               => l_payroll_id,
                               p_date_worked              => l_old_date_worked,
                               p_person_id                => l_person_id,
                               p_old_ovn                  => l_old_ovn,
                               p_bb_id                    => l_bb_id,
                               p_time_summary_id          => l_time_summary_id,
                               p_time_sum_start_date      => l_time_sum_start_date,
                               p_time_sum_end_date        => l_time_sum_end_date,
                               p_tim_id                   => l_tim_id
                              );

                           --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 352);
                           END IF;
                        END IF;       -- l_changed is Y and p_incremental is Y

                        --
                        -- Only create a new timecard if there is one to
                        -- create.  That is, if the change is that of a delete,
                        -- then just need to back out the old entry that was
                        -- created and NOT create a new entry.
                        -- If it is not a delete, then create a new entry for the
                        -- current data.
                        --
                        IF l_deleted = 'Y' AND l_changed = 'Y'
                        THEN

                           -- g_timecards decides if the timecard needs to
                           -- be re-exploded.  In case the timecard is not
                           -- added already to g_timecards, check if it needs
                           -- an explosion.  If yes, add it to g_timecards.
                           IF NOT( g_timecards.EXISTS(l_tim_id))
                             -- Bug 9308216
                             -- Added to avoid ORA 6502
                             AND l_tim_id IS NOT NULL
                           THEN
                              IF(chk_need_re_explosion( l_assignment_id,
                                                        l_date_worked,
                                                        l_element_id ))
                              THEN
                                  IF g_debug
                                  THEN
                                     hr_utility.trace('This timecard needs re-explosion');
                                  END IF;
                                  l_retcode := hxt_tim_col_util.get_session_date(
                                        hxt_time_collection.g_sess_date);
                                  g_timecards(l_tim_id) := l_tim_id;
                              END IF;
                            END IF;

                           --
                           -- Delete old summary and detail rows.
                           --
                           DELETE FROM hxt_det_hours_worked_f
                                 WHERE parent_id = l_time_summary_id;

                           --
                           -- Delete the summary row itself.
                           --
                           DELETE FROM hxt_sum_hours_worked_f
                                 WHERE ID = l_time_summary_id;
                        --
                        END IF;

                        --
                        IF l_deleted = 'N'
                        THEN
                           --
                           IF g_debug
                           THEN
                              hr_utility.TRACE
                                           ('---- Creating new timecard ----');
                              hr_utility.TRACE (   'l_date_worked is '
                                                || TO_CHAR (l_date_worked,
                                                            'DD-MON-YYYY'
                                                           )
                                               );
                              hr_utility.set_location (c_proc, 353);
                           END IF;

                           --
                                     -- Pass in Person ID for employee number - issue
                                     -- with going from employee number to person ID
                                     -- in OTM API.  Hence bypass it and just pass in person ID.
                                     --
                                     -- IF l_changed = 'N' THEN
                                        --
                                        -- l_count_timecards := l_count_timecards + 1;
                                        --
                                     -- END IF;
                                     --
                           record_time
                              (p_employee_number              => TO_CHAR
                                                                    (l_person_id
                                                                    ),
                               p_approver_number              => l_approver_number,
                               p_batch_ref                    => l_batch_ref,
                               p_batch_name                   => l_batch_name,
                               p_bg_id                        => p_bg_id,
                               p_start_time                   => l_start_time,
                               p_end_time                     => l_stop_time,
                               p_date_worked                  => l_date_worked,
                               p_hours                        => l_hours,
                               p_earning_policy               => l_earn_policy,
                               p_hours_type                   => l_hours_type,
                               p_earn_reason_code             => l_earn_reason_code,
                               p_project                      => l_project,
                               p_task                         => l_task,
                               p_location                     => l_location,
                               p_comment                      => l_comment_text,
                               p_rate_multiple                => l_rate_multiple,
                               p_hourly_rate                  => l_hourly_rate,
                               p_amount                       => l_amount,
                               p_sep_check_flag               => l_sep_check_flag,
                               p_segment                      => l_segment,
                               p_time_summary_id              => l_time_summary_id,
                               p_time_sum_start_date          => l_time_sum_start_date,
                               p_time_sum_end_date            => l_time_sum_end_date,
                               p_time_building_block_id       => l_bb_id,
                               p_time_building_block_ovn      => l_ovn,
                               p_delete                       => 'N',
                               p_state_name                   => l_state_name,
                               p_county_name                  => l_county_name,
                               p_city_name                    => l_city_name,
                               p_zip_code                     => l_zip_code
                              );

                           --
                           IF g_debug
                           THEN
                              hr_utility.set_location (c_proc, 360);
                           END IF;
                        --
                        END IF;

                        --
                             -------- Update Transaction in OTC for building block --------
                             --
                                -- Update with success or failure for each timecard.
                        -- Currently, only update the detail block since that
                        -- is the only block that is being used.  Should the parent
                        -- blocks inherit the status of the detail block?
                                --
                        -- TRANSACTION_STATUS: S (Success), E (Errors), W (Warnings)
                        --
                        g_status := 'SUCCESS';
                        fnd_message.set_name ('HXC',
                                              'HXC_HXT_RET_REC_SUCCESS');
                        g_exception_description :=
                                             SUBSTR (fnd_message.get, 1, 2000);
                        --
                        set_transaction (p_bb_id         => l_bb_id,
                                         p_bb_index      => l_cnt,
                                         p_status        => g_status,
                                         p_excep         => g_exception_description
                                        );

                        --
                        IF g_debug
                        THEN
                           hr_utility.set_location (c_proc, 370);
                        END IF;

                             --
                             --------------------- Write Error Report --------------------
                             --
                             -- Error checking
                             -- If status in BEE <> Unprocessed, then check to see if
                        -- validate or transfer resulted in error status
                        --
                        IF g_debug
                        THEN
                           hr_utility.set_location (c_proc, 380);
                           hr_utility.set_location (c_proc, 390);
                           hr_utility.set_location (c_proc, 400);
                        END IF;
                     --
                     END IF;                           -- parameter validation

                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 410);
                     END IF;
                  --
                  END IF;                                  -- scope = 'DETAIL'

                  -- Bug 9308216
                  -- Added incrementing Old bb id here so that all processing is complete
                  -- before this.
                  IF g_debug
                  THEN
                     hr_utility.trace('OTL: Adding bb index here now '||l_old_bb_index);
                  END IF;
                  IF l_changed = 'Y' AND p_incremental = 'Y'
                  THEN
                     l_old_bb_index := NVL(l_old_bb_index,
                    	                hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
                     	            );

		     IF (l_old_bb_index <= g_cnt_t_old_detail_bld_blks)
                     THEN
                        l_old_bb_index := l_old_bb_index + 1;
                        hr_utility.trace('End of loop: l_old_bb_index is changed '||l_old_bb_index);
                     END IF;
                  END IF;


               --
               EXCEPTION
                  WHEN e_record_error
                  THEN
                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 411);
                     END IF;

                     --
                     set_transaction (p_bb_id         => l_bb_id,
                                      p_bb_index      => l_cnt,
                                      p_status        => g_status,
                                      p_excep         => g_exception_description
                                     );
                     --
                     l_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_last_att_index
                           );
                     l_old_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_old_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_old_last_att_index
                           );

                     -- Bug 6621627
                     -- Added the below adjustment for old building blocks also to
                     -- avoid propagation of the 6153 error.
                     -- 6153 error happens from get_attributes when the attribute of
                     -- a particular building block is missing. The exception that
                     -- was getting raised, adjusts the attribute and old attribute
                     -- index, but not the old bb index. Added this code here to
                     -- adjust that also.  Adjust the index only if we are processing a
                     -- changed record, which has a corresponding old bb id too.
                     -- The NVL condition put to take care if the first building block
                     -- itself is missing attributes.  In this case, l_old_bb_index
                     -- would be NULL. The same adjustment done to all the exceptions
                     -- being raised here.

                     -- Bug 9308216
                     IF g_debug
                     THEN
                        hr_utility.trace('OTL: l_old_bb_index is '||l_old_bb_index);
                     END IF;

                     IF l_changed = 'Y' AND p_incremental = 'Y'
                     THEN
                        l_old_bb_index := NVL(l_old_bb_index,
                     	                hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
                     	            );

			IF (l_old_bb_index <= g_cnt_t_old_detail_bld_blks)
                     	THEN
                     	   l_old_bb_index := l_old_bb_index + 1;
                     	   hr_utility.trace('e_record_error:l_old_bb_index is changed '||l_old_bb_index);
                     	END IF;
                     END IF;

                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 412);
                     END IF;
                  --
                  WHEN e_amount_hours
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 666);
                     END IF;

                     fnd_message.set_name ('HXT', 'HXT_39443_HRS_AMT_EDIT');
                     g_status := 'ERRORS';
                     g_exception_description :=
                                             SUBSTR (fnd_message.get, 1, 2000);

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'g_exception_description is : '
                                          || g_exception_description
                                         );
                     END IF;

                     set_transaction (p_bb_id         => l_bb_id,
                                      p_bb_index      => l_cnt,
                                      p_status        => g_status,
                                      p_excep         => g_exception_description
                                     );
                     l_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_last_att_index
                           );
                     l_old_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_old_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_old_last_att_index
                           );


                     -- Bug 6621627

                     -- Bug 9308216
                     IF g_debug
                     THEN
                        hr_utility.trace('OTL: l_old_bb_index is '||l_old_bb_index);
                     END IF;

                     IF l_changed = 'Y' AND p_incremental = 'Y'
                     THEN
                        l_old_bb_index := NVL(l_old_bb_index,
                     	                hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
                     	            );

			IF (l_old_bb_index <= g_cnt_t_old_detail_bld_blks)
                     	THEN
                     	   l_old_bb_index := l_old_bb_index + 1;
                     	   hr_utility.trace('e_amount_hours:l_old_bb_index is changed '||l_old_bb_index);
                     	END IF;
                     END IF;


                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 666.5);
                     END IF;

                     fnd_message.raise_error;
                     RETURN;
                  WHEN e_not_retrievable
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 700);
                     END IF;

                     fnd_message.set_name ('HXT',
                                           'HXT_TC_CANNOT_BE_CHANGED_TODAY'
                                          );
                     g_status := 'ERRORS';
                     g_exception_description :=
                                             SUBSTR (fnd_message.get, 1, 2000);

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'g_exception_description is : '
                                          || g_exception_description
                                         );
                     END IF;

                     set_transaction (p_bb_id         => l_bb_id,
                                      p_bb_index      => l_cnt,
                                      p_status        => g_status,
                                      p_excep         => g_exception_description
                                     );
                     l_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_last_att_index
                           );
                     l_old_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_old_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_old_last_att_index
                           );

                     -- Bug 6621627

                     -- Bug 9308216
                     IF g_debug
                     THEN
                        hr_utility.trace('OTL: l_old_bb_index is '||l_old_bb_index);
                     END IF;

                     IF l_changed = 'Y' AND p_incremental = 'Y'
                     THEN
                        l_old_bb_index := NVL(l_old_bb_index,
                     	                hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
                     	            );

			IF (l_old_bb_index <= g_cnt_t_old_detail_bld_blks)
                     	THEN
                     	   l_old_bb_index := l_old_bb_index + 1;
                     	   hr_utility.trace('e_not_retrievable:l_old_bb_index is changed '||l_old_bb_index);
                     	END IF;
                     END IF;


                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 710);
                     END IF;
                  WHEN OTHERS
                  THEN
                     --
                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 413);
                     END IF;

                     --
                     g_status := 'ERRORS';
                     g_exception_description :=
                        SUBSTR (   'The error is : '
                                || TO_CHAR (SQLCODE)
                                || ' '
                                || SQLERRM,
                                1,
                                2000
                               );
                     hr_utility.trace('G_exception description is '||g_exception_description);
                     --
                     set_transaction (p_bb_id         => l_bb_id,
                                      p_bb_index      => l_cnt,
                                      p_status        => g_status,
                                      p_excep         => g_exception_description
                                     );
                     --
                     l_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_last_att_index
                           );
                     l_old_last_att_index :=
                        sync_attributes
                           (p_att_table           => hxc_generic_retrieval_pkg.t_old_detail_attributes,
                            p_bb_id               => l_bb_id,
                            p_last_att_index      => l_old_last_att_index
                           );

                     -- Bug 6621627

                     -- Bug 9308216
                     IF g_debug
                     THEN
                        hr_utility.trace('OTL: l_old_bb_index is '||l_old_bb_index);
                     END IF;

                     IF l_changed = 'Y' AND p_incremental = 'Y'
                     THEN
                        l_old_bb_index := NVL(l_old_bb_index,
                     	                hxc_generic_retrieval_pkg.t_old_detail_bld_blks.FIRST
                     	            );

			IF (l_old_bb_index <= g_cnt_t_old_detail_bld_blks)
                     	THEN
                     	   l_old_bb_index := l_old_bb_index + 1;
                     	   hr_utility.trace('OTHERS:l_old_bb_index is changed '||l_old_bb_index);
                     	END IF;
                     END IF;


                     IF g_debug
                     THEN
                        hr_utility.set_location (c_proc, 414);
                     END IF;
               --
               END;

               --
               IF g_debug
               THEN
                  hr_utility.set_location (c_proc, 420);
               END IF;
            --
            END LOOP;

--
            IF g_debug
            THEN
               hr_utility.set_location (c_proc, 430);
            END IF;

--
--------------- Update Transaction in OTC for whole process ---------------
--
            hxc_generic_retrieval_utils.set_parent_statuses;
--
            g_status := 'SUCCESS';
            fnd_message.set_name ('HXC', 'HXC_HXT_RET_PROC_SUCCESS');
            g_exception_description := SUBSTR (fnd_message.get, 1, 2000);
--
            hxc_generic_retrieval_pkg.update_transaction_status
                          (p_process                    => l_process_name,
                           p_status                     => g_status,
                           p_exception_description      => g_exception_description,
                           p_rollback                   => FALSE
                          );

            IF g_debug
            THEN
               hr_utility.set_location (c_proc, 440);
            END IF;
         ELSE
            -- end of loop
            l_no_more_timecards := TRUE;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE ('g_timecards.count = ' || g_timecards.COUNT);
            hr_utility.TRACE ('p_batch_ref = ' || p_batch_ref);
         END IF;

         -- reset timecard list
         i := g_timecards.FIRST;

         <<re_explode_timecard>>
         LOOP
            EXIT re_explode_timecard WHEN NOT g_timecards.EXISTS (i);
            hxt_td_util.retro_restrict_edit
                                        (p_tim_id             => g_timecards
                                                                           (i),
                                         p_session_date       => SYSDATE,
                                         o_dt_update_mod      => l_dt_update_mode,
                                         o_error_message      => l_otm_error,
                                         o_return_code        => l_return_code
                                        );

            IF g_debug
            THEN
               hr_utility.TRACE ('l_dt_update_mode = ' || l_dt_update_mode);
            END IF;

            hxt_time_collection.re_explode_timecard
                                          (timecard_id             => g_timecards
                                                                           (i),
                                           tim_eff_start_date      => NULL,
                                           -- Not Being Used
                                           tim_eff_end_date        => NULL,
                                           -- Not Being Used
                                           dt_update_mode          => l_dt_update_mode,
                                           -- 'CORRECTION',
                                           otm_error               => l_otm_error,
                                           oracle_error            => l_oracle_error
                                          );

            IF l_otm_error IS NOT NULL
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (c_proc, 2000);
                  hr_utility.TRACE ('l_otm_error :' || l_otm_error);
               END IF;
            -- raise e_error;
            END IF;

            IF l_oracle_error IS NOT NULL
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (c_proc, 2050);
                  hr_utility.TRACE ('l_oracle_error :' || l_oracle_error);
               END IF;
            -- raise e_error;
            END IF;

            i := g_timecards.NEXT (i);
         END LOOP re_explode_timecard;

         -- commit records after re-explosion and processing of this chunk
         COMMIT;
      END LOOP;                           -- WHILE ( NOT l_no_more_timecards )
------------------ Conclude transfer_to_otm Main -----------------
--
   EXCEPTION
      WHEN e_retrieval_error
      THEN
         --
         hxc_generic_retrieval_utils.set_parent_statuses;
         --
         hxc_generic_retrieval_pkg.update_transaction_status
                         (p_process                    => l_process_name,
                          p_status                     => g_status,
                          p_exception_description      => g_exception_description,
                          p_rollback                   => FALSE
                         );
         --
         RETURN;
      --
      --
      WHEN OTHERS
      THEN
         g_status := 'ERRORS';
         g_exception_description :=
            SUBSTR ('The error is : ' || TO_CHAR (SQLCODE) || ' ' || SQLERRM,
                    1,
                    2000
                   );

         --
         IF g_debug
         THEN
            hr_utility.TRACE ('g_exception_description is : ' || SQLERRM);
         END IF;

         --
         IF SQLERRM NOT LIKE '%HXC%'
         THEN
            --
            hxc_generic_retrieval_utils.set_parent_statuses;
            --
            hxc_generic_retrieval_pkg.update_transaction_status
                         (p_process                    => l_process_name,
                          p_status                     => g_status,
                          p_exception_description      => g_exception_description,
                          p_rollback                   => FALSE
                         );
            --
            fnd_message.raise_error;
         --
         END IF;

         --
         IF (    (SQLERRM LIKE '%HXC%')
             AND (fnd_profile.VALUE ('HXC_RETRIEVAL_OPTIONS') = 'BOTH')
            )
         THEN
            hxc_generic_retrieval_utils.set_parent_statuses;
            hxc_generic_retrieval_pkg.update_transaction_status
                         (p_process                    => l_process_name,
                          p_status                     => 'ERRORS',
                          p_exception_description      => g_exception_description,
                          p_rollback                   => FALSE
                         );

            IF (SQLERRM LIKE '%HXC_0017_GNRET_PROCESS_RUNNING%')
            THEN
               fnd_message.raise_error;
            ELSE
               p_no_otm := 'Y';
            END IF;
         ELSIF (fnd_profile.VALUE ('HXC_RETRIEVAL_OPTIONS') = 'OTLR')
         THEN
            hxc_generic_retrieval_utils.set_parent_statuses;
            --
            hxc_generic_retrieval_pkg.update_transaction_status
                         (p_process                    => l_process_name,
                          p_status                     => 'ERRORS',
                          p_exception_description      => g_exception_description,
                          p_rollback                   => FALSE
                         );
            --
            fnd_message.raise_error;
         END IF;

         --
         RETURN;

      --
--
         IF g_debug
         THEN
            hr_utility.set_location (c_proc, 450);
         END IF;
--

   --
   END transfer_to_otm;


   FUNCTION chk_need_re_explosion (
      p_assignment_id                IN              NUMBER,
      p_date_worked                  IN              DATE,
      p_element_type_id              IN              NUMBER )
    RETURN BOOLEAN
    IS

      CURSOR get_earn_pol( p_asg_id   IN NUMBER)
          IS SELECT /*+ INDEX(asg HXT_ADD_ASSIGN_INFO_ON1)*/
                    earning_policy,
                    effective_start_date,
                    effective_end_date
               FROM hxt_add_assign_info_f asg
              WHERE assignment_id = p_asg_id
              ORDER BY effective_start_date ;

      CURSOR get_earn_group_elements ( p_ep_id   IN NUMBER)
          IS SELECT /*+ LEADING(ep)
		        INDEX(ep HXT_EARNING_POLICIES_PK)
		        INDEX(eg HXT_EARN_GROUPS_EGT_FK) */
                    element_type_id
               FROM hxt_earning_policies ep,
                    hxt_earn_groups     eg
              WHERE ep.id = p_ep_id
                AND eg.egt_id = ep.egt_id
               ORDER BY element_type_id ;

      l_ep_id     NUMBER;
      l_ep_list   earn_pol_tab;
      l_element_list element_tab;


    BEGIN
        IF g_debug
        THEN
           hr_utility.trace('Deleted entry, check if re-explosion needed ');
        END IF;

        -- Check if the earning policy list is created already for this
        -- assignment.  If not, create it.
        IF NOT(g_earn_pol_list.exists((to_char(p_assignment_id))))
        THEN
           IF g_debug
           THEN
              hr_utility.trace('Checking policy for '||p_assignment_id);
           END IF;
           OPEN get_earn_pol(p_assignment_id);
           FETCH get_earn_pol BULK COLLECT INTO l_ep_list ;
           CLOSE get_earn_pol;

           g_earn_pol_list(to_char(p_assignment_id)).ep_list := l_ep_list;
        END IF;

        -- Loop thru the earning policy list and find out the one which
        -- suits this date_worked.
        FOR i IN g_earn_pol_list(to_char(p_assignment_id)).ep_list.FIRST..
                 g_earn_pol_list(to_char(p_assignment_id)).ep_list.LAST
        LOOP
           IF p_date_worked BETWEEN g_earn_pol_list(to_char(p_assignment_id)).ep_list(i).start_date
                                AND g_earn_pol_list(to_char(p_assignment_id)).ep_list(i).end_date
           THEN
              l_ep_id := g_earn_pol_list(to_char(p_assignment_id)).ep_list(i).earn_pol_id;
              EXIT;
           END IF;
        END LOOP;


        IF g_debug
        THEN
           hr_utility.trace('Earning policy is '||l_ep_id);
        END IF;

        -- Check if this earning policy already has
        -- elements in earning group populated.
        -- If not, fetch and populate it.
        IF NOT (g_earn_group_list.exists(to_char(l_ep_id)))
        THEN
           hr_utility.trace(' Checking earning group elements for '||l_ep_id);
           OPEN get_earn_group_elements(l_ep_id);
           FETCH get_earn_group_elements BULK COLLECT INTO l_element_list;
           CLOSE get_earn_group_elements;

           g_earn_group_list(l_ep_id).element_list := l_element_list;

        END IF;

        -- Find out if this element is in the EG.  If yes,
        -- we need to re-explode, send TRUE.  Else do nothing,
        -- and return FALSE.

        FOR i IN g_earn_group_list(l_ep_id).element_list.first..
                    g_earn_group_list(l_ep_id).element_list.last
        LOOP
           IF p_element_type_id < g_earn_group_list(l_ep_id).element_list(i)
           THEN
              EXIT;
           ELSIF p_element_type_id = g_earn_group_list(l_ep_id).element_list(i)
           THEN
              IF g_debug
              THEN
                 hr_utility.trace(' Element '||p_element_type_id||' in Earning group ');
              END IF;
              RETURN TRUE;
           END IF;
        END LOOP;

       RETURN FALSE;

     END chk_need_re_explosion ;

--
------------------------------------------------------------------------
END hxt_otc_retrieval_interface;

/
