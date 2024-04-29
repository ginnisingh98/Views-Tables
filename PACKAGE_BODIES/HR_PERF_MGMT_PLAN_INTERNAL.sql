--------------------------------------------------------
--  DDL for Package Body HR_PERF_MGMT_PLAN_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERF_MGMT_PLAN_INTERNAL" AS
/* $Header: pepmpbsi.pkb 120.43.12010000.42 2010/04/08 06:36:30 schowdhu ship $ */
  -- Package Variables
  -- Package Variables
  --
   g_package                     VARCHAR2 (33)                     := 'hr_perf_mgmt_plan_internal.';
   g_debug                       BOOLEAN                                := hr_utility.debug_enabled;
   g_num_errors                  NUMBER                                      := 0;
   g_max_errors                  NUMBER;
   --
   -- Proprietory debugging. Allows for concurrent request output, etc.
   -- (see procedures "op").
   --
   g_dbg                         BOOLEAN                                     := g_debug;
   g_dbg_type                    NUMBER                                      := g_no_debug;
   g_log_level                   VARCHAR2 (1)                                := g_regular_log;
   --
   --
   -- Package (private) constants.
   --
   LOGGING              CONSTANT pay_action_parameters.parameter_name%TYPE   := 'LOGGING';
   max_errors           CONSTANT pay_action_parameters.parameter_name%TYPE  := 'MAX_ERRORS_ALLOWED';
   NEWLINE              CONSTANT VARCHAR2 (10)                               := fnd_global.NEWLINE;
   tab                  CONSTANT VARCHAR2 (30)                               := fnd_global.tab;
   --
   g_error_txt                   VARCHAR2 (32000);
   g_cp_error_txt                VARCHAR2 (32000);

   --

   --
   -- Private user-defined types.
   --

   -- Used for populating Plan Population
   TYPE g_qual_pop_r IS RECORD (
      assignment_id              per_all_assignments_f.assignment_id%TYPE,
      person_id                  per_all_assignments_f.person_id%TYPE,
      business_group_id          per_all_assignments_f.business_group_id%TYPE,
      supervisor_id              per_all_assignments_f.supervisor_id%TYPE,
      supervisor_assignment_id   per_all_assignments_f.supervisor_assignment_id%TYPE,
      organization_id            per_all_assignments_f.organization_id%TYPE,
      position_id                per_all_assignments_f.position_id%TYPE
   );

   TYPE g_qual_pop_t IS TABLE OF g_qual_pop_r
      INDEX BY BINARY_INTEGER;

   g_qual_pop_tbl                g_qual_pop_t;

   -- Used for populating existing scorecard population
   TYPE g_curr_sc_pop_r IS RECORD (
      assignment_id           per_personal_scorecards.assignment_id%TYPE,
      scorecard_id            per_personal_scorecards.scorecard_id%TYPE,
      object_version_number   per_personal_scorecards.object_version_number%TYPE,
      status_code             per_personal_scorecards.status_code%TYPE
   );

   TYPE g_curr_sc_pop_t IS TABLE OF g_curr_sc_pop_r
      INDEX BY BINARY_INTEGER;

   g_curr_sc_pop_tbl             g_curr_sc_pop_t;

   -- Used for populating qualifying objectives
   TYPE g_qual_obj_r IS RECORD (
      objective_id             per_objectives_library.objective_id%TYPE,
      objective_name           per_objectives_library.objective_name%TYPE,
      valid_from               per_objectives_library.valid_from%TYPE,
      valid_to                 per_objectives_library.valid_to%TYPE,
      target_date              per_objectives_library.target_date%TYPE,
      next_review_date         per_objectives_library.next_review_date%TYPE,
      group_code               per_objectives_library.group_code%TYPE,
      priority_code            per_objectives_library.priority_code%TYPE,
      appraise_flag            per_objectives_library.appraise_flag%TYPE,
      weighting_percent        per_objectives_library.weighting_percent%TYPE,
      target_value             per_objectives_library.target_value%TYPE,
      uom_code                 per_objectives_library.uom_code%TYPE,
      measurement_style_code   per_objectives_library.measurement_style_code%TYPE,
      measure_name             per_objectives_library.measure_name%TYPE,
      measure_type_code        per_objectives_library.measure_type_code%TYPE,
      measure_comments         per_objectives_library.measure_comments%TYPE,
      details                  per_objectives_library.details%TYPE,
      success_criteria         per_objectives_library.success_criteria%TYPE,
      comments                 per_objectives_library.comments%TYPE,
      elig_obj_id              ben_elig_obj_f.elig_obj_id%TYPE
   );

   TYPE g_qual_obj_t IS TABLE OF g_qual_obj_r
      INDEX BY BINARY_INTEGER;

   g_qual_obj_tbl                g_qual_obj_t;

   -- User for populating existing scorecard objectives
   TYPE g_curr_sc_obj_r IS RECORD (
      copied_from_library_id   per_objectives.copied_from_library_id%TYPE,
      objective_id             per_objectives.objective_id%TYPE,
      object_version_number    per_objectives.object_version_number%TYPE
   );

   TYPE g_curr_sc_obj_t IS TABLE OF g_curr_sc_obj_r
      INDEX BY BINARY_INTEGER;

   g_curr_sc_obj_tbl             g_curr_sc_obj_t;

   -- User for populating plan appraisal periods
   TYPE g_plan_aprsl_pds_r IS RECORD (
      appraisal_period_id      per_appraisal_periods.appraisal_period_id%TYPE,
      appraisal_template_id    per_appraisal_periods.appraisal_template_id%TYPE,
      start_date               per_appraisal_periods.start_date%TYPE,
      end_date                 per_appraisal_periods.end_date%TYPE,
      task_start_date          per_appraisal_periods.task_start_date%TYPE,
      task_end_date            per_appraisal_periods.task_end_date%TYPE,
      initiator_code           per_appraisal_periods.initiator_code%TYPE,
      appraisal_system_type    per_appraisal_periods.appraisal_system_type%TYPE,
      auto_conc_process        per_appraisal_periods.auto_conc_process%TYPE,
      days_before_task_st_dt   per_appraisal_periods.days_before_task_st_dt%TYPE,
      appraisal_assmt_status   per_appraisal_periods.appraisal_assmt_status%TYPE,
      appraisal_type           per_appraisal_periods.appraisal_type%TYPE
   );

   TYPE g_plan_aprsl_pds_t IS TABLE OF g_plan_aprsl_pds_r
      INDEX BY BINARY_INTEGER;

   g_plan_aprsl_pds_tbl          g_plan_aprsl_pds_t;

   --
   TYPE g_boolean_t IS TABLE OF BOOLEAN
      INDEX BY BINARY_INTEGER;

   g_plan_pop_known_t            g_boolean_t;
   g_fetched_plan_member_index   NUMBER;

   --
   TYPE scorecard_info IS RECORD (
      scorecard_id     per_personal_scorecards.scorecard_id%TYPE,
      assignment_id    per_personal_scorecards.assignment_id%TYPE,
      person_id        per_personal_scorecards.person_id%TYPE,
      scorecard_name   per_personal_scorecards.scorecard_name%TYPE
   );

   TYPE assignment_info IS RECORD (
      assignment_id          per_all_assignments_f.assignment_id%TYPE,
      business_group_id      per_all_assignments_f.business_group_id%TYPE,
      grade_id               per_all_assignments_f.grade_id%TYPE,
      position_id            per_all_assignments_f.position_id%TYPE,
      job_id                 per_all_assignments_f.job_id%TYPE,
      org_id                 per_all_assignments_f.organization_id%TYPE,
      supervisor_id          per_all_assignments_f.supervisor_id%TYPE,
      effective_state_date   per_all_assignments_f.effective_start_date%TYPE
   );

   TYPE appraisal_templ_info IS RECORD (
      appraisal_template_id     per_appraisal_templates.appraisal_template_id%TYPE,
      assessment_type_id        per_appraisal_templates.assessment_type_id%TYPE,
      objective_asmnt_type_id   per_appraisal_templates.objective_asmnt_type_id%TYPE,
      business_group_id         per_appraisal_templates.business_group_id%TYPE
   );

   TYPE assess_comps_info IS RECORD (
      competence_id                  per_competence_elements.competence_id%TYPE,
      competence_element_id          per_competence_elements.competence_element_id%TYPE,
      TYPE                           per_competence_elements.TYPE%TYPE,
      parent_competence_element_id   per_competence_elements.parent_competence_element_id%TYPE,
      NAME                           per_competences_vl.NAME%TYPE,
      RANK                           NUMBER
   );

   TYPE bus_rules_comps IS RECORD (
      NAME                        per_competences_vl.NAME%TYPE,
      competence_id               per_competences.competence_id%TYPE,
      competence_element_id       per_competence_elements.competence_element_id%TYPE,
      mandatory                   per_competence_elements.mandatory%TYPE,
      proficiency_level_id        per_competence_elements.proficiency_level_id%TYPE,
      high_proficiency_level_id   per_competence_elements.high_proficiency_level_id%TYPE,
      organization_id             per_competence_elements.organization_id%TYPE,
      job_id                      per_competence_elements.job_id%TYPE,
      position_id                 per_competence_elements.position_id%TYPE,
      valid_grade_id              per_competence_elements.valid_grade_id%TYPE,
      business_group_id           per_competence_elements.business_group_id%TYPE,
      enterprise_id               per_competence_elements.enterprise_id%TYPE,
      structure_type              hr_lookups.meaning%TYPE,
      read_only_attr              NUMBER,
      detail_attr                 NUMBER,
      competence_alias            per_competences.competence_alias%TYPE,
      GLOBAL                      VARCHAR2 (1),
      description                 per_competences.description%TYPE,
      date_from                   per_competences.date_from%TYPE,
      certification_required      per_competences.certification_required%TYPE,
      behavioural_indicator       per_competences.behavioural_indicator%TYPE,
      low_step_value              per_rating_levels_vl.step_value%TYPE,
      low_step_name               per_rating_levels_vl.NAME%TYPE,
      high_step_value             per_rating_levels_vl.step_value%TYPE,
      high_step_name              per_rating_levels_vl.NAME%TYPE,
      lookup_code                 hr_lookups.lookup_code%TYPE,
      minimum_proficiency         VARCHAR2 (100),
      maximum_proficiency         VARCHAR2 (100),
      TYPE                        per_competence_elements.TYPE%TYPE
   );

   TYPE sel_comp_tab IS TABLE OF bus_rules_comps
      INDEX BY BINARY_INTEGER;

   TYPE competences_rc IS RECORD (
      competence_id   per_competences.competence_id%TYPE
   );

   TYPE competences_tbl IS TABLE OF competences_rc
      INDEX BY BINARY_INTEGER;

   TYPE appr_prds_rc IS RECORD (
      appraisal_period_id     per_appraisal_periods.appraisal_period_id%TYPE,
      appraisal_template_id   per_appraisal_periods.appraisal_template_id%TYPE,
      business_group_id       per_appraisal_templates.business_group_id%TYPE
   );

   TYPE appr_prds_tbl IS TABLE OF appr_prds_rc
      INDEX BY BINARY_INTEGER;

   -- added for PERF ADMIN ACTIONS
   TYPE t_selected_entities IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   g_selected_entities           t_selected_entities;

   TYPE t_plan_rec IS TABLE OF per_perf_mgmt_plans%ROWTYPE
      INDEX BY BINARY_INTEGER;

   g_plan_rec                    t_plan_rec;
   g_plan_dtls                   t_plan_rec;
   g_appraisals_exist            VARCHAR2 (1)                                := 'N';

    -- END Changes for PERF ADMIN ACTIONS
--
-- ----------------------------------------------------------------------------
-- |----------------------< initialize_logging >------------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE initialize_logging (p_action_parameter_group_id IN NUMBER, p_log_output IN VARCHAR2)
   IS
      --
      -- Gets an action parameter value.
      --
      CURSOR csr_get_action_param (p_parameter_name IN VARCHAR2)
      IS
         SELECT pap.parameter_value
           FROM pay_action_parameters pap
          WHERE pap.parameter_name = p_parameter_name;

      l_logging      pay_action_parameters.parameter_value%TYPE;
      l_max_errors   pay_action_parameters.parameter_value%TYPE;
      l_string       VARCHAR2 (500);
   BEGIN
      --
      -- Reset the package globals.
      --
      g_errbuf                   := NULL;
      g_retcode                  := success;
      g_max_errors               := 0;
      g_error_txt                := '';

      --
      -- If the action parameter ID is passed in, the action param group
      -- is set.  Native dynamic PL/SQL is used to eliminate the
      -- the dependency on the pay package procedure.

      -- This option we disabled because thriough application we pass explicit null
       -- but when run through concurrent program this validation can fail
       -- so keeping at par with application submit of cp we bypass this validation.
      /* IF p_action_parameter_group_id IS NOT NULL THEN

           l_string :=
               'BEGIN
                    pay_core_utils.set_pap_group_id(p_pap_group_id => ' ||
                        to_char(p_action_parameter_group_id) || ');
                END;';

           EXECUTE IMMEDIATE l_string;

       END IF;*/

      --
      IF (p_log_output = 'Y' AND fnd_global.conc_request_id > 0)
      THEN
         -- Call from concurrent program
         g_dbg                      := TRUE;
         g_dbg_type                 := g_fnd_log;

         --
         -- Get the Payroll Action logging parameter
         --
         OPEN csr_get_action_param (LOGGING);

         FETCH csr_get_action_param
          INTO l_logging;

         CLOSE csr_get_action_param;

         --
         -- If logging is set to General in Payroll Action parameters, enable debugging.
         --
         IF (INSTR (NVL (l_logging, 'N'), 'G') <> 0)
         THEN
            g_log_level                := g_debug_log;
         ELSE
            g_log_level                := g_regular_log;
         END IF;
      ELSIF (p_log_output <> 'Y')
      THEN
         -- Call from API
         IF (g_debug)
         THEN
            g_dbg                      := TRUE;
            g_dbg_type                 := g_pipe;
            g_log_level                := g_debug_log;
         END IF;
      END IF;

      --
      -- Set the max number of errors allowed.
      --
      OPEN csr_get_action_param (max_errors);

      FETCH csr_get_action_param
       INTO l_max_errors;

      CLOSE csr_get_action_param;

      g_max_errors               := NVL (TO_NUMBER (l_max_errors), 0);
   END initialize_logging;

--
-- ----------------------------------------------------------------------------
-- |----------------------< op >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE op (p_msg IN VARCHAR2, p_log_level IN NUMBER, p_location IN NUMBER DEFAULT NULL)
   IS
      l_msg   VARCHAR2 (32000) := p_msg;
   BEGIN
      IF (g_dbg_type IS NOT NULL AND p_msg IS NOT NULL AND p_log_level <= g_log_level)
      THEN
         --
         -- Break the output into chunks of 70 characters.
         --
         WHILE LENGTH (l_msg) > 0
         LOOP
            IF g_dbg_type = g_pipe OR g_debug
            THEN
               IF p_location IS NOT NULL
               THEN
                  hr_utility.set_location (SUBSTR (l_msg, 1, 70), p_location);
               ELSE
                  hr_utility.TRACE (SUBSTR (l_msg, 1, 70));
               END IF;
            ELSIF g_dbg_type = g_fnd_log
            THEN
               IF p_location IS NOT NULL
               THEN
                  fnd_file.put_line (fnd_file.LOG,
                                     SUBSTR (l_msg, 1, 70) || ', ' || TO_CHAR (p_location)
                                    );
               ELSE
                  fnd_file.put_line (fnd_file.LOG, SUBSTR (l_msg, 1, 70));
               END IF;
            END IF;

            l_msg                      := SUBSTR (l_msg, 71);
         END LOOP;
      END IF;
   END op;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_publishing_status >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the status code is a valid for Publish o Reverse Publish plan
--   action.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the status is valid.
--
-- Post Failure:
--  An application error is raised if the status code is not valid.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE chk_publishing_status (p_reverse_mode IN VARCHAR2, p_status_code IN VARCHAR2)
   IS
      -- Declare local variables
      l_proc                  VARCHAR2 (72) := g_package || 'chk_publishing_status';
      e_status_check_failed   EXCEPTION;
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --
      IF (    p_reverse_mode = 'N'
          AND p_status_code NOT IN ('DRAFT', 'UPDATED', 'SUBMITTED', 'RESUBMITTED')
         )
      THEN
         -- Set the message name, so that exception handler can get translated text
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 20);
         END IF;

         fnd_message.set_name ('PER', 'HR_50294_WPM_INV_PLAN_STS_PUB');
         g_error_txt                := NVL (fnd_message.get, 'HR_50294_WPM_INV_PLAN_STS_PUB');
         RAISE e_status_check_failed;
      ELSIF (p_reverse_mode <> 'N' AND p_status_code NOT IN ('PUBLISHED'))
      THEN
         -- Set the message name, so that exception handler can get translated text
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 30);
         END IF;

         fnd_message.set_name ('PER', 'HR_50295_WPM_INV_PLAN_STS_RPUB');
         g_error_txt                := NVL (fnd_message.get, 'HR_50295_WPM_INV_PLAN_STS_RPUB');
         RAISE e_status_check_failed;
      END IF;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         g_retcode                  := warning;
         g_errbuf                   := g_error_txt;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         RAISE;
   END chk_publishing_status;

--
-- ----------------------------------------------------------------------------
-- |---------------------< populate_qual_plan_population >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the qualifying plan population and loads in cache(i.e. PLSQL table
--    with index as assignment id and other values.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues on successful population.
--
-- Post Failure:
--  An application error is raised if population fails.

   --
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE populate_qual_plan_population (
      p_plan_rec         IN   per_perf_mgmt_plans%ROWTYPE,
      p_effective_date   IN   DATE
   )
   IS
      -- Declare local variables
      l_proc                   VARCHAR2 (72)        := g_package || 'populate_qual_plan_population';
      l_temp_pop_tbl           g_qual_pop_t;

      -- Supervisor Hierarchy population
      -- Includes supervisor assignment and person assignments that are in not more than N level
      -- below in hierarchy, where N is the value specified in hierarchy level attribute of the plan
      --
      CURSOR csr_sup_hier_pop
      IS
         SELECT     *
               FROM (SELECT asg.assignment_id,
                            asg.person_id,
                            asg.business_group_id,
                            asg.supervisor_id,
                            asg.supervisor_assignment_id,
                            asg.organization_id,
                            asg.position_id
                       FROM per_all_assignments_f asg
                      WHERE (   (    p_plan_rec.assignment_types_code IN ('E', 'C')
                                 AND asg.assignment_type = p_plan_rec.assignment_types_code
                                )
                             OR (    p_plan_rec.assignment_types_code = 'EC'
                                 AND asg.assignment_type IN ('E', 'C')
                                )
                            )
                        AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
                        AND (   (p_plan_rec.primary_asg_only_flag = 'N')
                             OR p_plan_rec.primary_asg_only_flag = 'Y' AND asg.primary_flag = 'Y'
                            )
                        AND 'x' =
                               (SELECT 'x'
                                  FROM per_all_people_f ppf
                                 WHERE asg.person_id = ppf.person_id
                                   AND p_effective_date BETWEEN ppf.effective_start_date
                                                            AND ppf.effective_end_date
                                   AND ('Y' =
                                           DECODE (p_plan_rec.assignment_types_code,
                                                   'E', ppf.current_employee_flag,
                                                   'C', ppf.current_npw_flag,
                                                   'EC', (SELECT 'Y'
                                                            FROM DUAL
                                                           WHERE ppf.current_employee_flag = 'Y'
                                                              OR ppf.current_npw_flag = 'Y')
                                                  )
                                       ))) o
         CONNECT BY o.supervisor_id = PRIOR o.person_id
                AND LEVEL <= NVL (p_plan_rec.hierarchy_levels, LEVEL) + 1
         START WITH o.person_id = p_plan_rec.supervisor_id;

      --  Supervisor Assignment Hierarchy  population
      -- Includes supervisor assignment and person assignments that are in not more than N level
      -- below in hierarchy, where N is the value specified in hierarchy level attribute of the plan
      --
      CURSOR csr_sup_asg_hier_pop
      IS
         SELECT     *
               FROM (SELECT asg.assignment_id,
                            asg.person_id,
                            asg.business_group_id,
                            asg.supervisor_id,
                            asg.supervisor_assignment_id,
                            asg.organization_id,
                            asg.position_id
                       FROM per_all_assignments_f asg
                      WHERE (   (    p_plan_rec.assignment_types_code IN ('E', 'C')
                                 AND asg.assignment_type = p_plan_rec.assignment_types_code
                                )
                             OR (    p_plan_rec.assignment_types_code = 'EC'
                                 AND asg.assignment_type IN ('E', 'C')
                                )
                            )
                        AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
                        AND 'x' =
                               (SELECT 'x'
                                  FROM per_all_people_f ppf
                                 WHERE asg.person_id = ppf.person_id
                                   AND p_effective_date BETWEEN ppf.effective_start_date
                                                            AND ppf.effective_end_date
                                   AND ('Y' =
                                           DECODE (p_plan_rec.assignment_types_code,
                                                   'E', ppf.current_employee_flag,
                                                   'C', ppf.current_npw_flag,
                                                   'EC', (SELECT 'Y'
                                                            FROM DUAL
                                                           WHERE ppf.current_employee_flag = 'Y'
                                                              OR ppf.current_npw_flag = 'Y')
                                                  )
                                       ))) o
         CONNECT BY o.supervisor_assignment_id = PRIOR o.assignment_id
                AND LEVEL <= NVL (p_plan_rec.hierarchy_levels, LEVEL) + 1
         START WITH o.assignment_id = p_plan_rec.supervisor_assignment_id;

      --  Organization hierarchy population
      -- Includes assignment where assignment organization is top organization or in next N levels of the plan
      -- organization hierarchy, where N is the value specified in hierarchy level attribute of the plan
      --
      CURSOR csr_org_hier_pop
      IS
         SELECT asg.assignment_id,
                asg.person_id,
                asg.business_group_id,
                asg.supervisor_id,
                asg.supervisor_assignment_id,
                asg.organization_id,
                asg.position_id
           FROM per_all_assignments_f asg
          WHERE (   (p_plan_rec.assignment_types_code IN ('E', 'C') AND asg.assignment_type = 'E')
                 OR (p_plan_rec.assignment_types_code = 'EC' AND asg.assignment_type IN ('E', 'C')
                    )
                )
            AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
            AND (   (p_plan_rec.primary_asg_only_flag = 'N')
                 OR p_plan_rec.primary_asg_only_flag = 'Y' AND asg.primary_flag = 'Y'
                )
            AND 'x' =
                   (SELECT 'x'
                      FROM per_all_people_f ppf
                     WHERE asg.person_id = ppf.person_id
                       AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                       AND ('Y' =
                               DECODE (p_plan_rec.assignment_types_code,
                                       'E', ppf.current_employee_flag,
                                       'C', ppf.current_npw_flag,
                                       'EC', (SELECT 'Y'
                                                FROM DUAL
                                               WHERE ppf.current_employee_flag = 'Y'
                                                  OR ppf.current_npw_flag = 'Y')
                                      )
                           ))
            AND asg.organization_id IN (
                   SELECT o.organization_id_child
                     FROM (SELECT     o.organization_id_child
                                 FROM per_org_structure_elements o
                           CONNECT BY o.organization_id_parent = PRIOR o.organization_id_child
                                  AND o.org_structure_version_id = PRIOR o.org_structure_version_id
                                  AND LEVEL <= NVL (p_plan_rec.hierarchy_levels, LEVEL)
                           START WITH o.organization_id_parent = p_plan_rec.top_organization_id
                                  AND o.org_structure_version_id =
                                                                 p_plan_rec.org_structure_version_id
                           UNION
                           SELECT p_plan_rec.top_organization_id organization_id_child
                             FROM DUAL) o,
                          hr_organization_units org
                    WHERE o.organization_id_child = org.organization_id
                      AND p_effective_date BETWEEN org.date_from AND NVL (org.date_to,
                                                                          p_effective_date
                                                                         ));

      -- Position Hierarchy population
      -- Includes assignments whose assignment position is top position or in next N levels of
      -- plan position hierarchy, where N is the value specified in hierarchy level attribute of the plan
      --
      CURSOR csr_pos_hier_pop
      IS
         SELECT asg.assignment_id,
                asg.person_id,
                asg.business_group_id,
                asg.supervisor_id,
                asg.supervisor_assignment_id,
                asg.organization_id,
                asg.position_id
           FROM per_all_assignments_f asg
          WHERE (   (    p_plan_rec.assignment_types_code IN ('E', 'C')
                     AND asg.assignment_type = p_plan_rec.assignment_types_code
                    )
                 OR (p_plan_rec.assignment_types_code = 'EC' AND asg.assignment_type IN ('E', 'C')
                    )
                )
            AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
            AND (   (p_plan_rec.primary_asg_only_flag = 'N')
                 OR p_plan_rec.primary_asg_only_flag = 'Y' AND asg.primary_flag = 'Y'
                )
            AND 'x' =
                   (SELECT 'x'
                      FROM per_all_people_f ppf
                     WHERE asg.person_id = ppf.person_id
                       AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                       AND ('Y' =
                               DECODE (p_plan_rec.assignment_types_code,
                                       'E', ppf.current_employee_flag,
                                       'C', ppf.current_npw_flag,
                                       'EC', (SELECT 'Y'
                                                FROM DUAL
                                               WHERE ppf.current_employee_flag = 'Y'
                                                  OR ppf.current_npw_flag = 'Y')
                                      )
                           ))
            AND (asg.position_id IN (
                    SELECT o.subordinate_position_id
                      FROM (SELECT     p.subordinate_position_id
                                  FROM per_pos_structure_elements p
                            CONNECT BY p.parent_position_id = PRIOR p.subordinate_position_id
                                   AND p.pos_structure_version_id = PRIOR p.pos_structure_version_id
                                   AND LEVEL <= NVL (p_plan_rec.hierarchy_levels, LEVEL)
                            START WITH p.parent_position_id = p_plan_rec.top_position_id
                                   AND p.pos_structure_version_id =
                                                                 p_plan_rec.pos_structure_version_id) o,
                           per_positions pos
                     WHERE o.subordinate_position_id = pos.position_id
                       AND p_effective_date BETWEEN pos.date_effective
                                                AND NVL (pos.date_end, p_effective_date)
                    UNION
                    SELECT p_plan_rec.top_position_id subordinate_position_id
                      FROM DUAL)
                );

      CURSOR csr_apprl_periods (p_pln_id per_perf_mgmt_plans.plan_id%TYPE)
      IS
         SELECT prds.appraisal_period_id,
                prds.appraisal_template_id,
                templ.business_group_id
           FROM per_appraisal_periods prds, per_appraisal_templates templ
          WHERE prds.plan_id = p_pln_id AND templ.appraisal_template_id = prds.appraisal_template_id;

      l_last_bg_id             per_appraisal_templates.business_group_id%TYPE;
      l_bg_change              BOOLEAN                                          DEFAULT FALSE;
      l_check_cross_bg_templ   BOOLEAN                                          DEFAULT FALSE;
      l_appr_prds_tbl          appr_prds_tbl;
      e_invl_templ_popl        EXCEPTION;
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --
      g_plan_pop_known_t.DELETE;

      --
      -- Check the hierarchy_type and populate the assignment table
      --
      IF (p_plan_rec.hierarchy_type_code = 'SUP')
      THEN
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 20);
         END IF;

         --
         OPEN csr_sup_hier_pop;

         FETCH csr_sup_hier_pop
         BULK COLLECT INTO l_temp_pop_tbl;

         CLOSE csr_sup_hier_pop;
      --
      ELSIF (p_plan_rec.hierarchy_type_code = 'SUP_ASG')
      THEN
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 30);
         END IF;

         --
         OPEN csr_sup_asg_hier_pop;

         FETCH csr_sup_asg_hier_pop
         BULK COLLECT INTO l_temp_pop_tbl;

         CLOSE csr_sup_asg_hier_pop;
      --
      ELSIF (p_plan_rec.hierarchy_type_code = 'ORG')
      THEN
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 40);
         END IF;

         --
         OPEN csr_org_hier_pop;

         FETCH csr_org_hier_pop
         BULK COLLECT INTO l_temp_pop_tbl;

         CLOSE csr_org_hier_pop;
      --
      ELSIF (p_plan_rec.hierarchy_type_code = 'POS')
      THEN
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 50);
         END IF;

         --
         OPEN csr_pos_hier_pop;

         FETCH csr_pos_hier_pop
         BULK COLLECT INTO l_temp_pop_tbl;

         CLOSE csr_pos_hier_pop;
      --
      END IF;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 60);
      END IF;

      --
      OPEN csr_apprl_periods (p_plan_rec.plan_id);

      FETCH csr_apprl_periods
      BULK COLLECT INTO l_appr_prds_tbl;

      CLOSE csr_apprl_periods;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 60);
      END IF;

      --
      IF l_appr_prds_tbl.COUNT > 0
      THEN
         FOR i IN l_appr_prds_tbl.FIRST .. l_appr_prds_tbl.LAST
         LOOP
            IF g_dbg
            THEN
               op (   ' Entered Appraisal Template Local Check '
                   || l_appr_prds_tbl (i).appraisal_period_id,
                   g_debug_log,
                   60
                  );
            END IF;

            IF (l_appr_prds_tbl (i).business_group_id IS NOT NULL)
            THEN
               l_check_cross_bg_templ     := TRUE;
               EXIT WHEN l_check_cross_bg_templ;
            END IF;
         END LOOP;
      END IF;

      IF l_check_cross_bg_templ
      THEN
         IF g_dbg
         THEN
            op (' Entered l_check_cross_bg_templ ', g_debug_log, 60);
         END IF;

         FOR i IN l_temp_pop_tbl.FIRST .. l_temp_pop_tbl.LAST
         LOOP
            FOR j IN l_appr_prds_tbl.FIRST .. l_appr_prds_tbl.LAST
            LOOP
               IF (l_appr_prds_tbl (j).business_group_id <> l_temp_pop_tbl (i).business_group_id)
               THEN
                  l_bg_change                := TRUE;

                  IF g_dbg
                  THEN
                     op (' Selected Population is not in Appraisal Template BG ', g_regular_log,
                         90);
                  END IF;

                  IF g_dbg
                  THEN
                     op (   ' Appraisal Template BG='
                         || l_appr_prds_tbl (j).business_group_id
                         || ' Person Id='
                         || l_temp_pop_tbl (i).assignment_id
                         || ' BG='
                         || l_temp_pop_tbl (i).business_group_id,
                         g_regular_log,
                         90
                        );
                  END IF;

                  EXIT WHEN l_bg_change;
               END IF;
            END LOOP;

            IF (NOT l_bg_change)
            THEN
               IF (i = 1)
               THEN
                  l_last_bg_id               := l_temp_pop_tbl (i).business_group_id;
               ELSE
                  IF (l_last_bg_id <> l_temp_pop_tbl (i).business_group_id)
                  THEN
                     l_bg_change                := TRUE;

                     IF g_dbg
                     THEN
                        op (' Population is spanned across Business Groups  ', g_regular_log, 90);
                     END IF;

                     EXIT WHEN l_bg_change;
                  ELSE
                     l_last_bg_id               := l_temp_pop_tbl (i).business_group_id;
                  END IF;
               END IF;
            ELSE
               EXIT WHEN l_bg_change;
            END IF;
         END LOOP;
      END IF;

      IF (l_bg_change)
      THEN
         RAISE e_invl_templ_popl;
      END IF;

      --
      -- Populate the plan population global cache
      -- with index as assignment id and  other values in respective columns
      --
      IF l_temp_pop_tbl.COUNT > 0
      THEN
         FOR i IN l_temp_pop_tbl.FIRST .. l_temp_pop_tbl.LAST
         LOOP
            --
            IF g_dbg
            THEN
               op ('Assignment Id = ' || l_temp_pop_tbl (i).assignment_id, g_debug_log);
            END IF;

            --
            IF NOT g_qual_pop_tbl.EXISTS (l_temp_pop_tbl (i).assignment_id)
            THEN
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).assignment_id :=
                                                                   l_temp_pop_tbl (i).assignment_id;
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).person_id :=
                                                                       l_temp_pop_tbl (i).person_id;
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).business_group_id :=
                                                               l_temp_pop_tbl (i).business_group_id;
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).supervisor_id :=
                                                                   l_temp_pop_tbl (i).supervisor_id;
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).supervisor_assignment_id :=
                                                        l_temp_pop_tbl (i).supervisor_assignment_id;
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).organization_id :=
                                                                 l_temp_pop_tbl (i).organization_id;
               g_qual_pop_tbl (l_temp_pop_tbl (i).assignment_id).position_id :=
                                                                     l_temp_pop_tbl (i).position_id;
            END IF;
         END LOOP;
      --
      END IF;

      --
      g_plan_pop_known_t (p_plan_rec.plan_id) := TRUE;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN e_invl_templ_popl
      THEN
         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         fnd_message.set_name ('PER', 'HR_WPM_INVL_TMPL_POPL');
         g_error_txt                := NVL (fnd_message.get, 'HR_WPM_INVL_TMPL_POPL');
         g_retcode                  := error;
         g_errbuf                   := g_error_txt;
         RAISE;
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END populate_qual_plan_population;

--
-- ----------------------------------------------------------------------------
-- |---------------------< populate_curr_plan_population >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the current plan population and loads in cache(i.e. PLSQL table
--    with index as assignment id and other values.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues on successful population.
--
-- Post Failure:
--  An application error is raised if population fails.

   --
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE populate_curr_plan_population (p_plan_id IN NUMBER)
   IS
      -- Declare local variables
      l_proc           VARCHAR2 (72)   := g_package || 'populate_curr_plan_population';
      l_temp_pop_tbl   g_curr_sc_pop_t;

      -- Current Plan population
      CURSOR csr_curr_plan_pop
      IS
         SELECT assignment_id,
                scorecard_id,
                object_version_number,
                status_code
           FROM per_personal_scorecards
          WHERE creator_type = 'AUTO' AND plan_id = p_plan_id AND status_code <> 'TRANSFER_OUT';
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Get the plan population and populate the current population table
      --
      OPEN csr_curr_plan_pop;

      FETCH csr_curr_plan_pop
      BULK COLLECT INTO l_temp_pop_tbl;

      CLOSE csr_curr_plan_pop;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 60);
      END IF;

      --

      --
      -- Populate the plan population global cache
      -- with index as assignment id and other values in respective columns
      --
      IF l_temp_pop_tbl.COUNT > 0
      THEN
         FOR i IN l_temp_pop_tbl.FIRST .. l_temp_pop_tbl.LAST
         LOOP
            --
            IF g_dbg
            THEN
               op ('Assignment Id = ' || l_temp_pop_tbl (i).assignment_id, g_debug_log);
            END IF;

            --
            IF NOT g_curr_sc_pop_tbl.EXISTS (l_temp_pop_tbl (i).assignment_id)
            THEN
               g_curr_sc_pop_tbl (l_temp_pop_tbl (i).assignment_id).assignment_id :=
                                                                   l_temp_pop_tbl (i).assignment_id;
               g_curr_sc_pop_tbl (l_temp_pop_tbl (i).assignment_id).scorecard_id :=
                                                                    l_temp_pop_tbl (i).scorecard_id;
               g_curr_sc_pop_tbl (l_temp_pop_tbl (i).assignment_id).object_version_number :=
                                                           l_temp_pop_tbl (i).object_version_number;
               g_curr_sc_pop_tbl (l_temp_pop_tbl (i).assignment_id).status_code :=
                                                                     l_temp_pop_tbl (i).status_code;
            END IF;
         END LOOP;
      --
      END IF;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
         END IF;
   END populate_curr_plan_population;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< populate_qual_objectives >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the qualifying objectives for a given plan period (i.e. PLSQL table
--    with index as assignment id and boolean value.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues on successful population.
--
-- Post Failure:
--  An application error is raised if population fails.

   --
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE populate_qual_objectives (p_start_date IN DATE, p_end_date IN DATE)
   IS
      -- Declare local variables
      l_proc           VARCHAR2 (72) := g_package || 'populate_qual_objectives';
      l_temp_obj_tbl   g_qual_obj_t;

      -- Current Plan population
      CURSOR csr_qual_objectives
      IS
         SELECT objective_id,
                objective_name,
                valid_from,
                valid_to,
                target_date,
                next_review_date,
                group_code,
                priority_code,
                appraise_flag,
                weighting_percent,
                target_value,
                uom_code,
                measurement_style_code,
                measure_name,
                measure_type_code,
                measure_comments,
                details,
                success_criteria,
                comments,
                elig.elig_obj_id
           FROM per_objectives_library pol, ben_elig_obj_f elig
          WHERE (   pol.valid_from BETWEEN p_start_date AND p_end_date
                 OR p_start_date BETWEEN pol.valid_from
                                     AND NVL (pol.valid_to, TO_DATE ('31-12-4712', 'DD-MM-YYYY'))
                )
            AND pol.eligibility_type_code <> 'N_P'
            AND elig.table_name = 'PER_OBJECTIVES_LIBRARY'
            AND column_name = 'OBJECTIVE_ID'
            AND elig.COLUMN_VALUE = pol.objective_id
            -- added 23-Jun-2009 schowdhu
            AND TRUNC (SYSDATE) BETWEEN elig.effective_start_date AND elig.effective_end_date;
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Get the plan population and populate the qualifying objectives for plan
      --
      OPEN csr_qual_objectives;

      FETCH csr_qual_objectives
      BULK COLLECT INTO l_temp_obj_tbl;

      CLOSE csr_qual_objectives;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 20);
      END IF;

      --

      --
      -- Populate the plan population global cache
      -- with index as library objective id and other values in respective columns
      --
      IF l_temp_obj_tbl.COUNT > 0
      THEN
         FOR i IN l_temp_obj_tbl.FIRST .. l_temp_obj_tbl.LAST
         LOOP
            --
            IF g_dbg
            THEN
               op ('Objective Id = ' || l_temp_obj_tbl (i).objective_id, g_debug_log);
            END IF;

            --
            --   Condition removed for bug no 6875448
            --IF NOT g_curr_sc_pop_tbl.EXISTS(l_temp_obj_tbl(i).objective_id) THEN
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).objective_id :=
                                                                     l_temp_obj_tbl (i).objective_id;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).objective_name :=
                                                                   l_temp_obj_tbl (i).objective_name;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).valid_from :=
                                                                       l_temp_obj_tbl (i).valid_from;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).valid_to := l_temp_obj_tbl (i).valid_to;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).target_date :=
                                                                      l_temp_obj_tbl (i).target_date;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).next_review_date :=
                                                                 l_temp_obj_tbl (i).next_review_date;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).group_code :=
                                                                       l_temp_obj_tbl (i).group_code;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).priority_code :=
                                                                    l_temp_obj_tbl (i).priority_code;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).appraise_flag :=
                                                                    l_temp_obj_tbl (i).appraise_flag;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).weighting_percent :=
                                                                l_temp_obj_tbl (i).weighting_percent;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).target_value :=
                                                                     l_temp_obj_tbl (i).target_value;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).uom_code := l_temp_obj_tbl (i).uom_code;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).measurement_style_code :=
                                                           l_temp_obj_tbl (i).measurement_style_code;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).measure_name :=
                                                                     l_temp_obj_tbl (i).measure_name;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).measure_type_code :=
                                                                l_temp_obj_tbl (i).measure_type_code;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).measure_comments :=
                                                                 l_temp_obj_tbl (i).measure_comments;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).details := l_temp_obj_tbl (i).details;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).success_criteria :=
                                                                 l_temp_obj_tbl (i).success_criteria;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).comments := l_temp_obj_tbl (i).comments;
            g_qual_obj_tbl (l_temp_obj_tbl (i).objective_id).elig_obj_id :=
                                                                      l_temp_obj_tbl (i).elig_obj_id;
         -- END IF;
         END LOOP;
      --
      END IF;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END populate_qual_objectives;

--
-- ----------------------------------------------------------------------------
-- |---------------------< populate_curr_sc_objectives >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the current objectivesfor a gives scorecard (i.e. PLSQL table
--    with index as library objective id and other values.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues on successful population.
--
-- Post Failure:
--  An application error is raised if population fails.

   --
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE populate_curr_sc_objectives (p_scorecard_id IN NUMBER)
   IS
      -- Declare local variables
      l_proc           VARCHAR2 (72)   := g_package || 'populate_curr_sc_objectives';
      l_temp_obj_tbl   g_curr_sc_obj_t;

      -- Current scorecard objectives
      CURSOR csr_curr_sc_objs
      IS
         SELECT copied_from_library_id,
                objective_id,
                object_version_number
           FROM per_objectives pob
          WHERE pob.copied_from_library_id IS NOT NULL AND pob.scorecard_id = p_scorecard_id;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Initialize the objectivestables that is used for different scorecards in loop
      --
      -- g_curr_sc_obj_tbl := l_temp_obj_tbl;
      g_curr_sc_obj_tbl.DELETE;

      --
      -- Get the plan population and populate the current scorecard objectives
      --
      OPEN csr_curr_sc_objs;

      FETCH csr_curr_sc_objs
      BULK COLLECT INTO l_temp_obj_tbl;

      CLOSE csr_curr_sc_objs;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 60);
      END IF;

      --

      --
      -- Populate the plan population global cache
      -- with index as library objective id and other values in respective columns
      --
      IF l_temp_obj_tbl.COUNT > 0
      THEN
         FOR i IN l_temp_obj_tbl.FIRST .. l_temp_obj_tbl.LAST
         LOOP
            --
            IF g_dbg
            THEN
               op ('Objective Id = ' || l_temp_obj_tbl (i).objective_id, g_debug_log);
            END IF;

            --
            --      Condition removed for bug no 6875448
            --IF NOT g_curr_sc_pop_tbl.EXISTS(l_temp_obj_tbl(i).copied_from_library_id) THEN
            g_curr_sc_obj_tbl (l_temp_obj_tbl (i).copied_from_library_id).copied_from_library_id :=
                                                           l_temp_obj_tbl (i).copied_from_library_id;
            g_curr_sc_obj_tbl (l_temp_obj_tbl (i).copied_from_library_id).objective_id :=
                                                                     l_temp_obj_tbl (i).objective_id;
            g_curr_sc_obj_tbl (l_temp_obj_tbl (i).copied_from_library_id).object_version_number :=
                                                            l_temp_obj_tbl (i).object_version_number;
         --END IF;
         END LOOP;
      --
      END IF;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END populate_curr_sc_objectives;

--
-- ----------------------------------------------------------------------------
-- |---------------------< populate_plan_apprsl_periods >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populates the appraisal periods for a given plan.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues on successful population.
--
-- Post Failure:
--  An application error is raised if population fails.

   --
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE populate_plan_apprsl_periods (p_plan_id IN NUMBER)
   IS
      -- Declare local variables
      l_proc   VARCHAR2 (72) := g_package || 'populate_plan_apprsl_periods';

      -- Current scorecard objectives
      CURSOR csr_plan_apprsl_pds
      IS
         SELECT appraisal_period_id,
                appraisal_template_id,
                start_date,
                end_date,
                task_start_date,
                task_end_date,
                initiator_code,
                appraisal_system_type,
                auto_conc_process,
                days_before_task_st_dt,
                appraisal_assmt_status,
                appraisal_type
           FROM per_appraisal_periods pap
          WHERE pap.plan_id = p_plan_id;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Get the plan appraisal periods
      --
      OPEN csr_plan_apprsl_pds;

      FETCH csr_plan_apprsl_pds
      BULK COLLECT INTO g_plan_aprsl_pds_tbl;

      CLOSE csr_plan_apprsl_pds;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 60);
      END IF;

      --

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END populate_plan_apprsl_periods;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_scorecard_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates scorecard for a given person when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if scorecard is created.
--
-- Post Failure:
--  An application error is raised if scorecard is not created.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE create_scorecard_for_person (
      p_effective_date   IN              DATE,
      p_scorecard_name   IN              VARCHAR2,
      p_assignment_id    IN              NUMBER,
      p_start_date       IN              DATE,
      p_end_date         IN              DATE,
      p_plan_id          IN              NUMBER,
      p_creator_type     IN              VARCHAR2,
      p_status_code      IN              VARCHAR2,
      p_scorecard_id     OUT NOCOPY      NUMBER
   )
   IS
      -- Declare local variables
      l_proc                     VARCHAR2 (72) := g_package || 'create_scorecard_for_person';
      --
      l_scorecard_id             NUMBER;
      l_object_version_number    NUMBER;
      --l_status_code                 varchar2(30);
      l_duplicate_name_warning   BOOLEAN;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call create_scorecard
      --
      hr_personal_scorecard_api.create_scorecard
                                               (p_effective_date              => p_effective_date,
                                                p_scorecard_name              => p_scorecard_name,
                                                p_assignment_id               => p_assignment_id,
                                                p_start_date                  => p_start_date,
                                                p_end_date                    => p_end_date,
                                                p_plan_id                     => p_plan_id,
                                                p_creator_type                => p_creator_type,
                                                p_scorecard_id                => l_scorecard_id,
                                                p_object_version_number       => l_object_version_number,
                                                p_status_code                 => p_status_code,
                                                p_duplicate_name_warning      => l_duplicate_name_warning
                                               );
      -- Out parameter
      p_scorecard_id             := l_scorecard_id;

      IF g_dbg
      THEN
         op ('Scorecard Id = ' || l_scorecard_id, g_debug_log);
      END IF;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         -- WPM  Logging changes
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TYPE := 'E';
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_NUMBER := 'OTHER';
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TEXT := SQLERRM;
         hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).processing_status := 'ERROR'; -- Error

         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END create_scorecard_for_person;

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_scorecard_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Updates the given scorecard  when plan is republished.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if scorecard is updated.
--
-- Post Failure:
--  An application error is raised if scorecard is not updated.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE update_scorecard_for_person (
      p_effective_date          IN   DATE,
      p_scorecard_id            IN   NUMBER,
      p_object_version_number   IN   NUMBER,
      p_scorecard_name          IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_start_date              IN   DATE DEFAULT hr_api.g_date,
      p_end_date                IN   DATE DEFAULT hr_api.g_date,
      p_status_code             IN   VARCHAR2 DEFAULT hr_api.g_varchar2
   )
   IS
      -- Declare local variables
      l_proc                     VARCHAR2 (72) := g_package || 'update_scorecard_for_person';
      --
      l_duplicate_name_warning   BOOLEAN;
      l_object_version_number    NUMBER        := p_object_version_number;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call update_scorecard
      --
      hr_personal_scorecard_api.update_scorecard
                                               (p_effective_date              => p_effective_date,
                                                p_scorecard_id                => p_scorecard_id,
                                                p_object_version_number       => l_object_version_number,
                                                p_scorecard_name              => p_scorecard_name,
                                                p_start_date                  => p_start_date,
                                                p_end_date                    => p_end_date,
                                                p_status_code                 => p_status_code,
                                                p_duplicate_name_warning      => l_duplicate_name_warning
                                               );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         -- WPM  Logging changes
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TYPE := 'E';
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_NUMBER := 'OTHER';
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TEXT := SQLERRM;
         hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).processing_status := 'ERROR'; -- Error

         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END update_scorecard_for_person;

--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_scorecard_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Delete the given scorecard.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if scorecard is deleted.
--
-- Post Failure:
--  An application error is raised if scorecard is not deleted.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE delete_scorecard_for_person (p_scorecard_id IN NUMBER, p_object_version_number IN NUMBER)
   IS
      -- Declare local variables
      l_proc                      VARCHAR2 (72) := g_package || 'delete_scorecard_for_person';
      --
      l_created_by_plan_warning   BOOLEAN;
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call update_scorecard
      --
      hr_personal_scorecard_api.delete_scorecard
                                             (p_scorecard_id                 => p_scorecard_id,
                                              p_object_version_number        => p_object_version_number,
                                              p_created_by_plan_warning      => l_created_by_plan_warning
                                             );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END delete_scorecard_for_person;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_scorecard_objective >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates objective for a given scorecard when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if objective is created.
--
-- Post Failure:
--  An application error is raised if objective is not created.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE create_scorecard_objective (
      p_effective_date           IN   DATE,
      p_business_group_id        IN   NUMBER,
      p_person_id                IN   NUMBER,
      p_scorecard_id             IN   NUMBER,
      p_start_date               IN   DATE,
      p_end_date                 IN   DATE,
      p_objective_name           IN   VARCHAR2,
      p_valid_from               IN   DATE,
      p_valid_to                 IN   DATE,
      p_target_date              IN   DATE,
      p_copied_from_library_id   IN   NUMBER,
      p_next_review_date         IN   DATE,
      p_group_code               IN   VARCHAR2,
      p_priority_code            IN   VARCHAR2,
      p_appraise_flag            IN   VARCHAR2,
      p_weighting_percent        IN   NUMBER,
      p_target_value             IN   NUMBER,
      p_uom_code                 IN   VARCHAR2,
      p_measurement_style_code   IN   VARCHAR2,
      p_measure_name             IN   VARCHAR2,
      p_measure_type_code        IN   VARCHAR2,
      p_measure_comments         IN   VARCHAR2,
      p_details                  IN   VARCHAR2,
      p_success_criteria         IN   VARCHAR2,
      p_comments                 IN   VARCHAR2
   )
   IS
      -- Declare local variables
      l_proc                           VARCHAR2 (72) := g_package || 'create_scorecard_objective';
      --
      l_objective_id                   NUMBER;
      l_object_version_number          NUMBER;
      l_duplicate_name_warning         BOOLEAN       := FALSE;
      l_comb_weight_over_100_warning   BOOLEAN       := FALSE;
      l_weighting_appraisal_warning    BOOLEAN       := FALSE;
      l_pc_v_act_mismatch_warning      BOOLEAN       := FALSE;
      l_quant_met_not_pc_warning       BOOLEAN       := FALSE;
      l_qual_met_not_pc_warning        BOOLEAN       := FALSE;
      --
      l_start_date                     DATE;
      l_target_date                    DATE;
      l_next_review_date               DATE;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Derive objective target date p_target_date < p_start date is added to fix 5233771
      --
      IF (p_target_date IS NULL OR p_target_date > p_end_date OR p_target_date < p_start_date)
      THEN
         l_target_date              := p_end_date;
      ELSE
         l_target_date              := p_target_date;
      END IF;

      -- while fixing 5233771, following is added to be in synch with Duncans mail
      -- and the same is incorporated in copy functionality from ui
      -- Derive Next review date
      --
      IF (   p_next_review_date IS NULL
          OR p_next_review_date > p_end_date
          OR p_next_review_date < p_start_date
         )
      THEN
         l_next_review_date         := NULL;
      ELSE
         l_next_review_date         := p_next_review_date;
      END IF;

      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 20);
      END IF;

      --

      --
      -- Call create_objective
      --
      hr_objectives_api.create_objective
                                    (p_effective_date                   => p_effective_date,
                                     p_business_group_id                => p_business_group_id
-- below param value is changed to -3 as per requirement.
      ,
                                     p_owning_person_id                 => -3          --p_person_id
                                                                             ,
                                     p_scorecard_id                     => p_scorecard_id,
                                     p_start_date                       => p_start_date,
                                     p_name                             => p_objective_name,
                                     p_target_date                      => l_target_date,
                                     p_copied_from_library_id           => p_copied_from_library_id,
                                     p_next_review_date                 => l_next_review_date,
                                     p_group_code                       => p_group_code,
                                     p_priority_code                    => p_priority_code,
                                     p_appraise_flag                    => p_appraise_flag,
                                     p_weighting_percent                => p_weighting_percent,
                                     p_target_value                     => p_target_value,
                                     p_uom_code                         => p_uom_code,
                                     p_measurement_style_code           => p_measurement_style_code,
                                     p_measure_name                     => p_measure_name,
                                     p_measure_type_code                => p_measure_type_code,
                                     p_measure_comments                 => p_measure_comments,
                                     p_detail                           => p_details,
                                     p_comments                         => p_comments,
                                     p_success_criteria                 => p_success_criteria,
                                     p_objective_id                     => l_objective_id,
                                     p_object_version_number            => l_object_version_number
--    ,p_duplicate_name_warning         =>  l_duplicate_name_warning
      ,
                                     p_weighting_over_100_warning       => l_comb_weight_over_100_warning
--    ,p_comb_weight_over_100_warning   =>  l_comb_weight_over_100_warning
      ,
                                     p_weighting_appraisal_warning      => l_weighting_appraisal_warning
--    ,p_pc_v_act_mismatch_warning      =>  l_pc_v_act_mismatch_warning
--    ,p_quant_met_not_pc_warning       =>  l_quant_met_not_pc_warning
--    ,p_qual_met_not_pc_warning        =>  l_qual_met_not_pc_warning
                                    );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END create_scorecard_objective;

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_scorecard_objective >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Updates objective for a given scorecard when plan is republished.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if objective is updated.
--
-- Post Failure:
--  An application error is raised if objective is not updated.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE update_scorecard_objective (
      p_effective_date           IN   DATE,
      p_objective_id             IN   NUMBER,
      p_object_version_number    IN   NUMBER,
      p_scorecard_id             IN   NUMBER DEFAULT hr_api.g_number,
      p_start_date               IN   DATE DEFAULT hr_api.g_date,
      p_end_date                 IN   DATE DEFAULT hr_api.g_date,
      p_objective_name           IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_valid_from               IN   DATE DEFAULT hr_api.g_date,
      p_valid_to                 IN   DATE DEFAULT hr_api.g_date,
      p_target_date              IN   DATE DEFAULT hr_api.g_date,
      p_copied_from_library_id   IN   NUMBER DEFAULT hr_api.g_number,
      p_next_review_date         IN   DATE DEFAULT hr_api.g_date,
      p_group_code               IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_priority_code            IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_appraise_flag            IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_weighting_percent        IN   NUMBER DEFAULT hr_api.g_number,
      p_target_value             IN   NUMBER DEFAULT hr_api.g_number,
      p_uom_code                 IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_measurement_style_code   IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_measure_name             IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_measure_type_code        IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_measure_comments         IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_details                  IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_success_criteria         IN   VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_comments                 IN   VARCHAR2 DEFAULT hr_api.g_varchar2
   )
   IS
      -- Declare local variables
      l_proc                           VARCHAR2 (72) := g_package || 'update_scorecard_objective';
      --
      l_object_version_number          NUMBER        := p_object_version_number;
      l_duplicate_name_warning         BOOLEAN       := FALSE;
      l_comb_weight_over_100_warning   BOOLEAN       := FALSE;
      l_weighting_appraisal_warning    BOOLEAN       := FALSE;
      l_pc_v_act_mismatch_warning      BOOLEAN       := FALSE;
      l_quant_met_not_pc_warning       BOOLEAN       := FALSE;
      l_qual_met_not_pc_warning        BOOLEAN       := FALSE;
      --
      l_start_date                     DATE;
      l_target_date                    DATE;
      l_next_review_date               DATE;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --
      --
      -- Derive objective target date p_target_date < p_start date is added to fix 5233771
      --
      IF (p_target_date IS NULL OR p_target_date > p_end_date OR p_target_date < p_start_date)
      THEN
         l_target_date              := p_end_date;
      ELSE
         l_target_date              := p_target_date;
      END IF;

      -- while fixing 5233771, following is added to be in synch with Duncans mail
      -- and the same is incorporated in copy functionality from ui
      -- Derive Next review date
      --
      IF (   p_next_review_date IS NULL
          OR p_next_review_date > p_end_date
          OR p_next_review_date < p_start_date
         )
      THEN
         l_next_review_date         := NULL;
      ELSE
         l_next_review_date         := p_next_review_date;
      END IF;

      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 20);
      END IF;

      --

      --
      -- Call update_objective
      --
      hr_objectives_api.update_objective
                                    (p_effective_date                   => p_effective_date,
                                     p_objective_id                     => p_objective_id,
                                     p_object_version_number            => l_object_version_number,
                                     p_scorecard_id                     => p_scorecard_id,
                                     p_start_date                       => p_start_date,
                                     p_name                             => p_objective_name,
                                     p_target_date                      => l_target_date,
                                     p_copied_from_library_id           => p_copied_from_library_id,
                                     p_next_review_date                 => l_next_review_date,
                                     p_group_code                       => p_group_code,
                                     p_priority_code                    => p_priority_code,
                                     p_appraise_flag                    => p_appraise_flag,
                                     p_weighting_percent                => p_weighting_percent,
                                     p_target_value                     => p_target_value,
                                     p_uom_code                         => p_uom_code,
                                     p_measurement_style_code           => p_measurement_style_code,
                                     p_measure_name                     => p_measure_name,
                                     p_measure_type_code                => p_measure_type_code,
                                     p_measure_comments                 => p_measure_comments,
                                     p_detail                           => p_details,
                                     p_comments                         => p_comments,
                                     p_success_criteria                 => p_success_criteria
                                                                                             --    ,p_duplicate_name_warning         =>  l_duplicate_name_warning
      ,
                                     p_weighting_over_100_warning       => l_comb_weight_over_100_warning
                                                                                                         --    ,p_comb_weight_over_100_warning   =>  l_comb_weight_over_100_warning
      ,
                                     p_weighting_appraisal_warning      => l_weighting_appraisal_warning
                                    --    ,p_pc_v_act_mismatch_warning      =>  l_pc_v_act_mismatch_warning
                                    --    ,p_quant_met_not_pc_warning       =>  l_quant_met_not_pc_warning
                                    --    ,p_qual_met_not_pc_warning        =>  l_qual_met_not_pc_warning
                                    );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END update_scorecard_objective;

--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_scorecard_objective >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Deletes a given objective.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if objective is deleted.
--
-- Post Failure:
--  An application error is raised if objective is not deleted.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE delete_scorecard_objective (p_objective_id IN NUMBER, p_object_version_number IN NUMBER)
   IS
      -- Declare local variables
      l_proc   VARCHAR2 (72) := g_package || 'delete_scorecard_objective';
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call delete_objective
      --
      hr_objectives_api.delete_objective (p_objective_id               => p_objective_id,
                                          p_object_version_number      => p_object_version_number
                                         );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END delete_scorecard_objective;

   FUNCTION get_appraisal_config_params (
      p_appr_initiator_code   IN              per_appraisal_periods.initiator_code%TYPE,
      p_function_id           IN OUT NOCOPY   fnd_form_functions.function_id%TYPE,
      p_function_name         IN OUT NOCOPY   fnd_form_functions.function_name%TYPE,
      p_func_parameters       IN OUT NOCOPY   fnd_form_functions.PARAMETERS%TYPE,
      p_appraisal_sys_type    IN OUT NOCOPY   per_appraisals.appraisal_system_status%TYPE
   )
      RETURN BOOLEAN
   IS
      l_resp_id               NUMBER;
      l_appraisal_mgr_menu    fnd_menus.menu_name%TYPE                DEFAULT NULL;
      l_appraisal_empl_menu   fnd_menus.menu_name%TYPE                DEFAULT NULL;
      l_selected_menu         fnd_menus.menu_name%TYPE                DEFAULT NULL;
      l_function_id           fnd_form_functions.function_id%TYPE;
      l_function_name         fnd_form_functions.function_name%TYPE;
      l_initiation_type       VARCHAR2 (10)                           DEFAULT NULL;
      l_func_params           fnd_form_functions.PARAMETERS%TYPE;
      l_system_type           VARCHAR2 (50);
      l_menu_id               fnd_menus.menu_id%TYPE;

      CURSOR get_appraisal_function (p_menu_name fnd_menus.menu_name%TYPE, p_search_func VARCHAR2)
      IS
         SELECT menu_functions.function_id,
                ff.function_name,
                ff.PARAMETERS,
                menu_id
           FROM fnd_compiled_menu_functions menu_functions, fnd_form_functions ff
          WHERE menu_id = (SELECT menu_id
                             FROM fnd_menus
                            WHERE menu_name = p_menu_name)
            AND ff.function_id = menu_functions.function_id
            AND ff.PARAMETERS LIKE p_search_func;
   BEGIN
      -- to be derived from plan id

      /*
          fnd_global.apps_initialize(user_id =>1922,
                                        resp_id =>21540,
                                        resp_appl_id=> 800);
      */
      IF g_dbg
      THEN
         op ('p_appr_initiator_code = ' || p_appr_initiator_code, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('login person = ' || fnd_global.user_id, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('login name = ' || fnd_global.user_name, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('resp id = ' || fnd_global.resp_id, g_debug_log);
      END IF;

      l_initiation_type          := 'MGR';
      l_resp_id                  := fnd_global.resp_id;
      l_appraisal_mgr_menu       :=
         fnd_profile.value_specific (NAME                   => 'HR_MANAGER_APPRAISALS_MENU',
                                     responsibility_id      => l_resp_id
                                    );

      IF g_dbg
      THEN
         op ('MGR MENU = ' || fnd_profile.VALUE ('HR_MANAGER_APPRAISALS_MENU'), g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('EMP MENU = ' || fnd_profile.VALUE ('HR_WORKER_APPRAISALS_MENU'), g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('l_appraisal_mgr_menu = ' || l_appraisal_mgr_menu, g_debug_log);
      END IF;

      l_appraisal_empl_menu      :=
         fnd_profile.value_specific (NAME                   => 'HR_WORKER_APPRAISALS_MENU',
                                     responsibility_id      => l_resp_id
                                    );

      IF g_dbg
      THEN
         op ('l_appraisal_empl_menu = ' || l_appraisal_empl_menu, g_debug_log);
      END IF;

      IF (p_appr_initiator_code = 'MGR' AND l_appraisal_mgr_menu IS NOT NULL)
      THEN
         l_selected_menu            := l_appraisal_mgr_menu;
         p_appraisal_sys_type       := p_appr_initiator_code || p_appraisal_sys_type;
         l_system_type              := '%' || p_appr_initiator_code || p_appraisal_sys_type || '%';
      ELSIF (p_appr_initiator_code = 'EMP' AND l_appraisal_empl_menu IS NOT NULL)
      THEN
         l_selected_menu            := l_appraisal_empl_menu;
         p_appraisal_sys_type       := p_appr_initiator_code || p_appraisal_sys_type;
         l_system_type              := '%' || p_appr_initiator_code || p_appraisal_sys_type || '%';
      END IF;

      IF g_dbg
      THEN
         op ('l_selected_menu = ' || l_selected_menu, g_debug_log);
      END IF;

      OPEN get_appraisal_function (l_selected_menu, l_system_type);

      FETCH get_appraisal_function
       INTO l_function_id,
            l_function_name,
            l_func_params,
            l_menu_id;

      IF get_appraisal_function%NOTFOUND
      THEN
         RETURN FALSE;
      ELSE
         p_function_id              := l_function_id;
         p_function_name            := l_function_name;
         p_func_parameters          :=
               l_func_params
            || '&'
            || 'pFunctionId='
            || l_function_id
            || '&'
            || 'pMenuId='
            || l_menu_id
            || '&'
            || 'OAFunc='
            || l_function_name;
      END IF;

      IF g_dbg
      THEN
         op ('l_function_id = ' || l_function_id, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('l_function_name = ' || l_function_name, g_debug_log);
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         RAISE;
   END;

   PROCEDURE apply_overridding_rules (
      p_enterprise_id     IN              NUMBER,
      p_organization_id   IN              NUMBER,
      p_job_id            IN              NUMBER,
      p_position_id       IN              NUMBER,
      p_skip_duplicate                    BOOLEAN,
      l_sel_comp_table    IN OUT NOCOPY   sel_comp_tab
   )
   IS
      CURSOR get_asgn_req_comps (enterprise_id NUMBER, org_id NUMBER, job_id NUMBER, pos_id NUMBER)
      IS
         SELECT pc.NAME competence_name,
                pce.competence_id,
                pce.competence_element_id,
                pce.mandatory,
                pce.proficiency_level_id,
                pce.high_proficiency_level_id,
                pce.organization_id,
                NVL (pce.job_id, -1) job_id,
                NVL (pce.position_id, -1) position_id,
                pce.valid_grade_id,
                NVL (pce.business_group_id, -1) business_group_id,
                pce.enterprise_id,
                hrl.meaning structure_type,
                DECODE (job_id, NULL, DECODE (position_id, NULL, 1, 0), 0) read_only_attr,
                0 detail_attr,
                pc.competence_alias,
                DECODE (pc.business_group_id, NULL, 'Y', 'N') GLOBAL,
                pc.description,
                pc.date_from,
                pc.certification_required,
                pc.behavioural_indicator,
                r1.step_value low_step_value,
                r1.NAME low_step_name,
                r2.step_value high_step_value,
                r2.NAME high_step_name,
                hrl.lookup_code,
                DECODE (r1.step_value, NULL, NULL, r1.step_value || ' - ' || r1.NAME)
                                                                                minimum_proficiency,
                DECODE (r2.step_value, NULL, NULL, r2.step_value || ' - ' || r2.NAME)
                                                                                maximum_proficiency,
                pce.TYPE
           FROM per_competence_elements pce,
                per_competences_vl pc,
                hr_lookups hrl,
                per_rating_levels_vl r1,
                per_rating_levels_vl r2
          WHERE pce.TYPE = 'REQUIREMENT'
            AND pce.competence_id = pc.competence_id
            AND TRUNC (SYSDATE) BETWEEN NVL (pce.effective_date_from, TRUNC (SYSDATE))
                                    AND NVL (pce.effective_date_to, TRUNC (SYSDATE))
            AND hrl.lookup_type(+) = 'STRUCTURE_TYPE'
            AND hrl.lookup_code(+) =
                   DECODE (pce.organization_id,
                           NULL, (DECODE (pce.job_id,
                                          NULL, (DECODE (pce.position_id, NULL, 'BUS', 'POS')),
                                          'JOB'
                                         )
                            ),
                           'ORG'
                          )
            AND pce.proficiency_level_id = r1.rating_level_id(+)
            AND pce.high_proficiency_level_id = r2.rating_level_id(+)
            AND pce.business_group_id = enterprise_id
            AND (   pce.enterprise_id = NVL (enterprise_id, -1)
                 OR pce.organization_id = NVL (org_id, -1)
                 OR pce.job_id = NVL (job_id, -1)
                 OR pce.position_id = NVL (pos_id, -1)
                );

      l_mat_comp_table        sel_comp_tab;
      i                       INTEGER      DEFAULT 0;
      issamecompetence        BOOLEAN      DEFAULT FALSE;
      issamestructuretype     BOOLEAN      DEFAULT FALSE;
      isignore                BOOLEAN      DEFAULT FALSE;
      isbessential            BOOLEAN      DEFAULT FALSE;
      isbdesired              BOOLEAN      DEFAULT FALSE;
      markouterrowforignore   BOOLEAN;
      isessentialdesired      BOOLEAN;
   BEGIN
      IF g_dbg
      THEN
         op ('p_enterprise_id = ' || p_enterprise_id, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('p_organization_id = ' || p_organization_id, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('p_job_id = ' || p_job_id, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('p_position_id = ' || p_position_id, g_debug_log);
      END IF;

      OPEN get_asgn_req_comps (p_enterprise_id, p_organization_id, p_job_id, p_position_id);

      FETCH get_asgn_req_comps
      BULK COLLECT INTO l_sel_comp_table;

      CLOSE get_asgn_req_comps;

      l_mat_comp_table           := l_sel_comp_table;

-- execute the cursor and apply the overriding rules
      FOR j IN 1 .. l_sel_comp_table.COUNT
      LOOP
         markouterrowforignore      := FALSE;

         FOR k IN 1 .. l_mat_comp_table.COUNT
         LOOP
            BEGIN
               issamecompetence           :=
                         (l_sel_comp_table (j).competence_id = l_mat_comp_table (k).competence_id
                         );
               issamestructuretype        :=
                              (l_sel_comp_table (j).lookup_code = l_mat_comp_table (k).lookup_code
                              );
               isignore                   := ('I' = l_mat_comp_table (k).mandatory);

               IF (NOT isignore AND issamecompetence AND NOT issamestructuretype)
               THEN
                  IF ('POS' = l_mat_comp_table (k).lookup_code)
                  THEN
                     markouterrowforignore      := TRUE;
                     GOTO end_block;
                  END IF;

                  IF (    ('POS' = l_sel_comp_table (j).lookup_code)
                      AND (NOT 'POS' = l_mat_comp_table (k).lookup_code)
                     )
                  THEN
                     l_mat_comp_table (k).mandatory := 'I';
                     GOTO end_block;
                  END IF;

                  isbessential               :=
                     ('Y' = l_mat_comp_table (k).mandatory AND 'Y' = l_sel_comp_table (j).mandatory
                     );
                  isbdesired                 :=
                     ('N' = l_mat_comp_table (k).mandatory AND 'N' = l_sel_comp_table (j).mandatory
                     );

                  IF (    isbessential
                      AND 'ORG' = l_sel_comp_table (j).lookup_code
                      AND 'JOB' = l_mat_comp_table (k).lookup_code
                     )
                  THEN
                     l_mat_comp_table (k).mandatory := 'I';
                     GOTO end_block;
                  END IF;

                  IF (    isbessential
                      AND 'JOB' = l_sel_comp_table (j).lookup_code
                      AND 'ORG' = l_mat_comp_table (k).lookup_code
                     )
                  THEN
                     markouterrowforignore      := TRUE;
                     GOTO end_block;
                  END IF;

                  IF (    isbdesired
                      AND (   (    'ORG' = l_sel_comp_table (j).lookup_code
                               AND 'JOB' = l_mat_comp_table (k).lookup_code
                              )
                           OR (    'JOB' = l_sel_comp_table (j).lookup_code
                               AND 'ORG' = l_mat_comp_table (k).lookup_code
                              )
                          )
                     )
                  THEN
                     IF (    (l_mat_comp_table (k).low_step_value IS NOT NULL)
                         AND (l_sel_comp_table (j).low_step_value IS NOT NULL)
                        )
                     THEN
                        --fix for bug 3063145.
                        IF (l_mat_comp_table (k).low_step_value >=
                                                                 l_sel_comp_table (j).low_step_value
                           )
                        THEN
                           l_sel_comp_table (j).low_step_value :=
                                                                l_mat_comp_table (k).low_step_value;
                           l_mat_comp_table (k).mandatory := 'I';
                        END IF;
                     ELSIF (    l_mat_comp_table (k).low_step_value IS NOT NULL
                            AND l_sel_comp_table (j).low_step_value IS NULL
                           )
                     THEN
                        l_sel_comp_table (j).low_step_value := l_mat_comp_table (k).low_step_value;
                        l_mat_comp_table (k).mandatory := 'I';
                     ELSE
                        l_mat_comp_table (k).mandatory := 'I';
                     END IF;

                     IF (    (l_mat_comp_table (k).high_step_value IS NOT NULL)
                         AND (l_sel_comp_table (j).high_step_value IS NOT NULL)
                        )
                     THEN
                        --fix for bug 3063145.
                        IF (l_mat_comp_table (k).high_step_value <=
                                                                l_sel_comp_table (j).high_step_value
                           )
                        THEN
                           l_sel_comp_table (j).high_step_value :=
                                                               l_mat_comp_table (k).high_step_value;
                           l_mat_comp_table (k).mandatory := 'I';
                        END IF;
                     ELSIF (    (l_mat_comp_table (k).high_step_value IS NOT NULL)
                            AND (l_sel_comp_table (j).high_step_value IS NULL)
                           )
                     THEN
                        l_sel_comp_table (j).high_step_value :=
                                                               l_mat_comp_table (k).high_step_value;
                        l_mat_comp_table (k).mandatory := 'I';
                     ELSE
                        l_mat_comp_table (k).mandatory := 'I';
                     END IF;
                  END IF;

                  IF (p_skip_duplicate)
                  THEN
                     isessentialdesired         :=
                        (   (    'Y' = l_sel_comp_table (j).mandatory
                             AND 'N' = l_mat_comp_table (k).mandatory
                            )
                         OR (    'N' = l_sel_comp_table (j).mandatory
                             AND 'Y' = l_mat_comp_table (k).mandatory
                            )
                        );

                     IF (       isessentialdesired
                            AND ((    'ORG' = l_sel_comp_table (j).lookup_code
                                  AND 'JOB' = l_mat_comp_table (k).lookup_code
                                 )
                                )
                         OR ((    'ORG' = l_mat_comp_table (k).lookup_code
                              AND 'JOB' = l_sel_comp_table (j).lookup_code
                             )
                            )
                        )
                     THEN
                        l_mat_comp_table (k).mandatory := 'I';
                     END IF;
                  END IF;

                  IF (    'BUS' = l_sel_comp_table (j).lookup_code
                      AND 'BUS' = l_mat_comp_table (k).lookup_code
                     )
                  THEN
                     l_mat_comp_table (k).mandatory := 'I';
                  END IF;
               END IF;

               <<end_block>>
               NULL;
            END;
         END LOOP;

         IF (markouterrowforignore)
         THEN
            l_sel_comp_table (j).mandatory := 'I';
         END IF;

         FOR i IN 1 .. l_sel_comp_table.COUNT
         LOOP
            IF (l_sel_comp_table (i).mandatory = 'I')
            THEN
               l_sel_comp_table (i)       := NULL;
            END IF;
         END LOOP;
      END LOOP;

      FOR j IN 1 .. l_sel_comp_table.COUNT
      LOOP
         IF g_dbg
         THEN
            op (   ' from overriding comp = '
                || l_sel_comp_table (j).competence_id
                || '   '
                || l_sel_comp_table (j).NAME,
                g_debug_log
               );
         END IF;
      END LOOP;
   END apply_overridding_rules;

-- ----------------------------------------------------------------------------
-- |----------------------< create_appraisal_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates Appraisal for a given person when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if Appraisal is created.
--
-- Post Failure:
--  An application error is raised if scorecard is not created.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE create_appraisal_for_person (
      p_score_card_id                       per_personal_scorecards.scorecard_id%TYPE,
      p_appraisal_templ_id                  per_appraisal_templates.appraisal_template_id%TYPE,
      p_effective_date                      DATE,
      p_appraisal_start_date                DATE,
      p_appraisal_end_date                  DATE,
      p_appraisal_status                    per_appraisals.status%TYPE DEFAULT 'PLANNED',
      p_type                                per_appraisals.TYPE%TYPE DEFAULT NULL,
      p_appraisal_date                      per_appraisals.appraisal_date%TYPE,
--       p_appraisal_system_status per_appraisals.appraisal_system_status%TYPE,
      p_plan_id                             NUMBER,
      p_next_appraisal_date                 per_appraisals.next_appraisal_date%TYPE DEFAULT NULL,
      p_status                              per_appraisals.status%TYPE DEFAULT NULL,
      p_comments                            per_appraisals.comments%TYPE DEFAULT NULL,
      p_appraisee_access                    per_appraisals.appraisee_access%TYPE DEFAULT NULL,
      p_appraisal_initiator                 per_appraisal_periods.initiator_code%TYPE,
      p_return_status          OUT NOCOPY   VARCHAR2
   )
   IS
      CURSOR get_scorecard_info (p_scorecard_id per_personal_scorecards.scorecard_id%TYPE)
      IS
         SELECT scorecard_id,
                assignment_id,
                person_id,
                scorecard_name
           FROM per_personal_scorecards
          WHERE scorecard_id = p_scorecard_id;

      CURSOR get_assignment_info (p_assignment_id per_all_assignments_f.assignment_id%TYPE)
      IS
         SELECT assignment_id,
                business_group_id,
                grade_id,
                position_id,
                job_id,
                organization_id,
                supervisor_id,
                effective_start_date
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id
            AND TRUNC (SYSDATE) BETWEEN effective_start_date AND effective_end_date;

      CURSOR get_appraisal_templ_info (
         p_appraisal_templ_id   per_appraisals.appraisal_template_id%TYPE
      )
      IS
         SELECT appraisal_template_id,
                assessment_type_id,
                objective_asmnt_type_id,
                business_group_id
           FROM per_appraisal_templates
          WHERE appraisal_template_id = p_appraisal_templ_id;

      CURSOR get_assess_templ_comps (
         p_assess_type_id   per_competence_elements.assessment_type_id%TYPE
      )
      IS
         SELECT ce.competence_id,
                ce.competence_element_id,
                ce.TYPE,
                ce.parent_competence_element_id,
                c.NAME,
                RANK () OVER (PARTITION BY ce.competence_id ORDER BY ce.competence_element_id) RANK
           FROM per_competence_elements a, per_competence_elements ce, per_competences_vl c
          WHERE a.assessment_type_id = p_assess_type_id
            AND a.TYPE = 'ASSESSMENT_GROUP'
            AND (NVL (c.date_from, TRUNC (SYSDATE)) <= TRUNC (SYSDATE))
            AND NVL (c.date_to, TRUNC (SYSDATE)) >= TRUNC (SYSDATE)
            AND a.competence_element_id = ce.parent_competence_element_id
            AND ce.competence_id = c.competence_id;

      CURSOR check_default_job_competency (
         p_assessment_type_id   per_assessment_types.assessment_type_id%TYPE
      )
      IS
         SELECT default_job_competencies
           FROM per_assessment_types
          WHERE assessment_type_id = p_assessment_type_id;

      CURSOR get_scorecard_objectives (p_scorecard_id per_objectives.scorecard_id%TYPE)
      IS
         SELECT objective_id,
                scorecard_id,
                object_version_number,
                NAME
           FROM per_objectives
          WHERE scorecard_id = p_scorecard_id AND appraise_flag = 'Y';

      CURSOR get_assess_templ_info (p_assess_templ per_appraisal_templates.assessment_type_id%TYPE)
      IS
         SELECT default_job_competencies,
                assessment_type_id
           FROM per_assessment_types
          WHERE assessment_type_id = p_assess_templ;

      l_scorecard_info                scorecard_info;
      no_score_card_with_this_id      EXCEPTION;
      l_assignment_info               assignment_info;
      no_assignment_with_this_id      EXCEPTION;
      l_appraisal_ovn                 per_appraisals.object_version_number%TYPE;
      l_apprl_return_status           VARCHAR2 (10)                                     DEFAULT NULL;
      l_assess_comp_return_status     VARCHAR2 (10)                                     DEFAULT NULL;
      l_assess_obj_return_status      VARCHAR2 (10)                                     DEFAULT NULL;
      l_apprl_id                      per_appraisals.appraisal_id%TYPE                  DEFAULT NULL;
      l_apprl_templ_info              appraisal_templ_info;
      no_apprl_templ_with_this_id     EXCEPTION;
      l_assessment_comp_id            per_assessments.assessment_id%TYPE;
      l_assessment_obj_id             per_assessments.assessment_id%TYPE;
      l_assessment_comp_ovn           per_assessments.object_version_number%TYPE;
      l_assessment_obj_ovn            per_assessments.object_version_number%TYPE;
      l_assess_comps                  assess_comps_info;
      l_check_default_job_comps       VARCHAR2 (2)                                        DEFAULT '';
      l_comp_ele_id                   per_competence_elements.competence_element_id%TYPE;
      l_comp_ovn                      per_competence_elements.object_version_number%TYPE;
      l_return_status                 VARCHAR2 (10)                                       DEFAULT '';
      l_competence_error              VARCHAR2 (1000)                                   DEFAULT NULL;
      module_name                     VARCHAR2 (100)               DEFAULT 'MASS APPRAISAL CREATION';
      l_error_message                 VARCHAR2 (1000)                                   DEFAULT NULL;
      appraisal_creation_error        EXCEPTION;
      assess_comp_error               EXCEPTION;
      assess_obj_error                EXCEPTION;
      l_appraisal_sys_type            VARCHAR2 (10);
      function_360_exists             BOOLEAN                                          DEFAULT FALSE;
      appraisal_system_type_error     EXCEPTION;
      l_weighting_over_100_warning    BOOLEAN;
      l_weighting_appraisal_warning   BOOLEAN;
      no_apprl_function_defined       EXCEPTION;
      l_function_id                   fnd_form_functions.function_id%TYPE;
      l_function_name                 fnd_form_functions.function_name%TYPE;
      l_func_params                   fnd_form_functions.PARAMETERS%TYPE;
      l_object_id                     NUMBER;
      l_assess_comps_processed        competences_tbl;
      z                               PLS_INTEGER;
      l_def_job_comps                 sel_comp_tab;
      appraisal_setup_issue           EXCEPTION;
      -- Declare local variables
      l_proc                          VARCHAR2 (72)    := g_package || 'create_appraisal_for_person';
      --
      l_scorecard_id                  NUMBER;
      l_object_version_number         NUMBER;
      --l_status_code                 varchar2(30);
      l_duplicate_name_warning        BOOLEAN;
      l_found_comp                    BOOLEAN;
      --
      l_templ_def_job_comps           per_assessment_types.default_job_competencies%TYPE;
      l_assess_type_id                per_assessment_types.assessment_type_id%TYPE;
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_debug_log, 10);
      END IF;

      --

      --
      -- Call create_scorecard
      --
      l_scorecard_info.scorecard_id := NULL;
      l_scorecard_info.assignment_id := NULL;

      OPEN get_scorecard_info (p_score_card_id);

      FETCH get_scorecard_info
       INTO l_scorecard_info;

      CLOSE get_scorecard_info;

      IF (l_scorecard_info.scorecard_id IS NULL OR l_scorecard_info.assignment_id IS NULL)
      THEN
         RAISE no_score_card_with_this_id;
      END IF;

      IF g_dbg
      THEN
         op (' get_scorecard_info ' || l_proc, g_debug_log, 20);
      END IF;

      l_assignment_info.assignment_id := NULL;

      OPEN get_assignment_info (l_scorecard_info.assignment_id);

      FETCH get_assignment_info
       INTO l_assignment_info;

      CLOSE get_assignment_info;

      IF (l_assignment_info.assignment_id IS NULL)
      THEN
         RAISE no_assignment_with_this_id;
      END IF;

      IF g_dbg
      THEN
         op (' get_assignment_info ' || l_proc, g_debug_log, 20);
      END IF;

      OPEN get_appraisal_templ_info (p_appraisal_templ_id);

      FETCH get_appraisal_templ_info
       INTO l_apprl_templ_info;

      CLOSE get_appraisal_templ_info;

      IF (l_apprl_templ_info.appraisal_template_id IS NULL)
      THEN
         RAISE no_apprl_templ_with_this_id;
      END IF;

      IF g_dbg
      THEN
         op (' get_appraisal_templ_info ' || l_proc, g_debug_log, 20);
      END IF;

      l_appraisal_sys_type       := p_type;
      function_360_exists        :=
         get_appraisal_config_params (p_appr_initiator_code      => p_appraisal_initiator,
                                      p_function_id              => l_function_id,
                                      p_function_name            => l_function_name,
                                      p_func_parameters          => l_func_params,
                                      p_appraisal_sys_type       => l_appraisal_sys_type
                                     );

      IF g_dbg
      THEN
         op ('l_function_id = ' || l_function_id, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('l_function_name = ' || l_function_name, g_debug_log);
      END IF;

      IF g_dbg
      THEN
         op ('l_func_params = ' || l_func_params, g_debug_log);
      END IF;

      IF (l_function_id IS NULL OR l_appraisal_sys_type IS NULL)
      THEN
         IF g_dbg
         THEN
            op ('Could not derive Appraisal Function or Appraisal System Type', g_debug_log);
         END IF;

         RAISE appraisal_setup_issue;
      END IF;

/*
    IF (function_360_exists = true) then
      IF g_dbg THEN op(' Appraisal System Function ' || l_appraisal_sys_status, g_DEBUG_LOG); END IF;
    end if;

    -- throw exception as there is no Function
    if(function_360_exists = false) then
        raise NO_APPRL_FUNCTION_DEFINED;
        IF g_dbg THEN op(' Appraisal System Function ' || l_appraisal_sys_status, g_DEBUG_LOG); END IF;

    end if;
*/

      --function_360_exists := true;  -- to be changed

      /*

      if(function_360_exists = false) then
          raise APPRAISAL_SYSTEM_TYPE_ERROR;
      end if;

      */

      --fnd_log.string(fnd_log.level_error,module_name,' Appraisal Creation for Score Card ' || l_scorecard_info.scorecard_name);

      -- to be, in case of Position Hierarchy we need get the supervisor id using the Plan and
      --  position hierarchy cursor.
      hr_appraisals_api.create_appraisal
                                 (p_validate                         => FALSE,
                                  p_effective_date                   => p_effective_date,
                                  p_business_group_id                => l_assignment_info.business_group_id,
                                  p_appraisal_template_id            => p_appraisal_templ_id,
                                  p_appraisee_person_id              => l_scorecard_info.person_id,
                                  p_appraiser_person_id              => l_assignment_info.supervisor_id,
                                  --to be changed for position
                                  p_appraisal_date                   => p_appraisal_date,
                                  p_appraisal_period_start_date      => p_appraisal_start_date,
                                  p_appraisal_period_end_date        => p_appraisal_end_date,
                                  p_type                             => p_type,              -- ANN,
                                  p_next_appraisal_date              => p_next_appraisal_date,
                                  p_status                           => p_status,
                                  -- PLANNED,TRANSFER,RFC,
                                  p_comments                         => p_comments,
                                  p_system_type                      => l_appraisal_sys_type,
                                  --MGR360 EMP360
                                  p_system_params                    => l_func_params,
                                  --p_appraisee_access,
                                  p_main_appraiser_id                => l_assignment_info.supervisor_id,
                                  --to be changed for position
                                  p_assignment_id                    => l_assignment_info.assignment_id,
                                  p_assignment_start_date            => l_assignment_info.effective_state_date,
                                  p_asg_business_group_id            => l_assignment_info.business_group_id,
                                  p_assignment_organization_id       => l_assignment_info.org_id,
                                  p_assignment_job_id                => l_assignment_info.job_id,
                                  --p_assignment_position_id = l_assignment_info.position_id  ,
                                  p_assignment_grade_id              => l_assignment_info.grade_id,
                                  p_appraisal_id                     => l_apprl_id,
                                  p_object_version_number            => l_appraisal_ovn,
                                  p_appraisal_system_status          => p_appraisal_status,
                                  p_plan_id                          => p_plan_id
                                 );

      IF g_dbg
      THEN
         op ('Appraisal Id = ' || l_apprl_id, g_debug_log);
      END IF;

      IF (l_apprl_id IS NOT NULL AND l_apprl_templ_info.assessment_type_id IS NOT NULL)
      THEN
         hr_assessments_api.create_assessment
                                    (p_assessment_id                     => l_assessment_comp_id,
                                     p_assessment_type_id                => l_apprl_templ_info.assessment_type_id,
                                     p_business_group_id                 => l_assignment_info.business_group_id,
                                     p_person_id                         => l_scorecard_info.person_id,
                                     --p_assessment_group_id,
                                     p_assessment_period_start_date      => p_appraisal_start_date,
                                     p_assessment_period_end_date        => p_appraisal_end_date,
                                     p_assessment_date                   => p_appraisal_date,
                                     p_assessor_person_id                => l_assignment_info.supervisor_id,
                                     --to be changed for position
                                     p_appraisal_id                      => l_apprl_id,
                                     --p_comments,
                                     p_object_version_number             => l_assessment_comp_ovn,
                                     p_validate                          => FALSE,
                                     p_effective_date                    => p_effective_date
                                    );
      END IF;

      IF g_dbg
      THEN
         op ('Competence Assesment Id = ' || l_assessment_comp_id, g_debug_log);
      END IF;

      -- this record is created for final ratings on Objectives.
      IF (l_apprl_id IS NOT NULL AND l_apprl_templ_info.objective_asmnt_type_id IS NOT NULL)
      THEN
         hr_assessments_api.create_assessment
                                    (p_assessment_id                     => l_assessment_obj_id,
                                     p_assessment_type_id                => l_apprl_templ_info.assessment_type_id,
                                     p_business_group_id                 => l_assignment_info.business_group_id,
                                     p_person_id                         => l_scorecard_info.person_id,
                                     --p_assessment_group_id,
                                     p_assessment_period_start_date      => p_appraisal_start_date,
                                     p_assessment_period_end_date        => p_appraisal_end_date,
                                     p_assessment_date                   => p_appraisal_date,
                                     p_assessor_person_id                => l_assignment_info.supervisor_id,
                                     --to be changed for position
                                     p_appraisal_id                      => l_apprl_id,
                                     --p_comments,
                                     p_object_version_number             => l_assessment_obj_ovn,
                                     p_validate                          => FALSE,
                                     p_effective_date                    => p_effective_date
                                    );
      END IF;

      IF g_dbg
      THEN
         op ('Objective Assessment Id = ' || l_assessment_obj_id, g_debug_log);
      END IF;

      -- to be
      IF (p_appraisal_initiator = 'MA')
      THEN
         l_object_id                := l_assignment_info.supervisor_id;
      ELSIF (p_appraisal_initiator = 'A')
      THEN
         l_object_id                := l_scorecard_info.person_id;
      END IF;

      z                          := 1;

      IF (l_assessment_comp_id IS NOT NULL)
      THEN
         FOR competences IN get_assess_templ_comps (l_apprl_templ_info.assessment_type_id)
         LOOP
            BEGIN
               l_return_status            := '';
               l_competence_error         := NULL;
               l_assess_comps_processed (z).competence_id := competences.competence_id;
               hr_competence_element_api.create_competence_element
                                       (p_validate                   => FALSE,
                                        p_competence_element_id      => l_comp_ele_id,
                                        p_object_version_number      => l_comp_ovn,
                                        p_type                       => 'ASSESSMENT',
                                        p_business_group_id          => l_assignment_info.business_group_id,
                                        p_competence_id              => competences.competence_id,
                                        p_assessment_id              => l_assessment_comp_id,
                                        p_effective_date_from        => p_appraisal_start_date,
                                        p_effective_date             => p_effective_date,
                                        p_object_name                => 'ASSESSOR_ID',
                                        p_object_id                  => l_object_id
                                       );
               z                          := z + 1;

               IF g_dbg
               THEN
                  op ('Competence Element Id = ' || l_comp_ele_id, g_debug_log);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  -- to be added a message to identify competence element error
                  IF g_dbg
                  THEN
                     op (SQLERRM, g_regular_log);
                  END IF;
            END;
         END LOOP;
      END IF;

      OPEN get_assess_templ_info (l_apprl_templ_info.assessment_type_id);

      FETCH get_assess_templ_info
       INTO l_templ_def_job_comps,
            l_assess_type_id;

      CLOSE get_assess_templ_info;

      IF (l_templ_def_job_comps = 'Y')
      THEN
         apply_overridding_rules (p_enterprise_id        => l_assignment_info.business_group_id,
                                  p_organization_id      => l_assignment_info.org_id,
                                  p_job_id               => l_assignment_info.job_id,
                                  p_position_id          => l_assignment_info.position_id,
                                  p_skip_duplicate       => TRUE,
                                  l_sel_comp_table       => l_def_job_comps
                                 );

         -- create the Job Comps eliminating duplicates
         IF (l_assessment_comp_id IS NOT NULL)
         THEN
            FOR j IN 1 .. l_def_job_comps.COUNT
            LOOP
               BEGIN
                  l_found_comp               := FALSE;

                  FOR k IN 1 .. l_assess_comps_processed.COUNT
                  LOOP
                     IF (    l_def_job_comps (j).competence_id IS NOT NULL
                         AND l_def_job_comps (j).competence_id =
                                                          l_assess_comps_processed (k).competence_id
                        )
                     THEN
                        l_found_comp               := TRUE;
                     END IF;
                  END LOOP;

                  IF (l_def_job_comps (j).competence_id IS NOT NULL AND NOT l_found_comp)
                  THEN
                     hr_competence_element_api.create_competence_element
                                       (p_validate                   => FALSE,
                                        p_competence_element_id      => l_comp_ele_id,
                                        p_object_version_number      => l_comp_ovn,
                                        p_type                       => 'ASSESSMENT',
                                        p_business_group_id          => l_assignment_info.business_group_id,
                                        p_competence_id              => l_def_job_comps (j).competence_id,
                                        p_assessment_id              => l_assessment_comp_id,
                                        p_effective_date_from        => p_appraisal_start_date,
                                        p_effective_date             => p_effective_date,
                                        p_object_name                => 'ASSESSOR_ID',
                                        p_object_id                  => l_object_id
                                       );

                     IF g_dbg
                     THEN
                        op (   ' Def Job Competence Id and Element Id = '
                            || l_comp_ele_id
                            || l_def_job_comps (j).competence_id,
                            g_debug_log
                           );
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     -- to be added a message to identify competence element error
                     IF g_dbg
                     THEN
                        op (SQLERRM, g_regular_log);
                     END IF;
               END;
            END LOOP;
         END IF;
      END IF;

      IF (l_apprl_id IS NOT NULL)
      THEN
         FOR objectives IN get_scorecard_objectives (p_score_card_id)
         LOOP
            BEGIN
               hr_objectives_api.update_objective
                                    (p_validate                         => FALSE,
                                     p_objective_id                     => objectives.objective_id,
                                     p_object_version_number            => objectives.object_version_number,
                                     p_effective_date                   => p_effective_date,
                                     p_appraisal_id                     => l_apprl_id,
                                     -- to be changed in SWI,API,RHI
                                     p_weighting_over_100_warning       => l_weighting_over_100_warning,
                                     p_weighting_appraisal_warning      => l_weighting_appraisal_warning
                                    );

               IF g_dbg
               THEN
                  op ('Linked objective Id to Appraisal = ' || objectives.objective_id,
                      g_debug_log);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  -- to be added a message to identify update objective error
                  IF g_dbg
                  THEN
                     op (SQLERRM, g_regular_log);
                  END IF;
            END;
         END LOOP;
      END IF;

      -- Out parameter

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END create_appraisal_for_person;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_appraisal_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates appraisal for a given person when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if appraisal is created.
--
-- Post Failure:
--  An application error is raised if appraisal is not created.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE create_appraisal_for_person (
      p_effective_date                IN   DATE,
      p_business_group_id             IN   NUMBER,
      p_appraisal_template_id         IN   NUMBER,
      p_appraisee_person_id           IN   NUMBER,
      p_appraiser_person_id           IN   NUMBER,
      p_appraisal_period_start_date   IN   DATE,
      p_appraisal_period_end_date     IN   DATE
   )
   IS
      -- Declare local variables
      l_proc                    VARCHAR2 (72) := g_package || 'create_appraisal_for_person ';
      --
      l_appraisal_id            NUMBER;
      l_object_version_number   NUMBER;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call create_appraisal
      --
      hr_appraisals_api.create_appraisal
                                    (p_effective_date                   => p_effective_date,
                                     p_business_group_id                => p_business_group_id,
                                     p_appraisal_template_id            => p_appraisal_template_id,
                                     p_appraisee_person_id              => p_appraisee_person_id,
                                     p_appraiser_person_id              => p_appraiser_person_id,
                                     p_appraisal_period_start_date      => p_appraisal_period_start_date,
                                     p_appraisal_period_end_date        => p_appraisal_period_end_date,
                                     p_appraisal_id                     => l_appraisal_id,
                                     p_object_version_number            => l_object_version_number
                                    );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END create_appraisal_for_person;

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_appraisal_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Updates appraisal for a given person when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if appraisal is updated.
--
-- Post Failure:
--  An application error is raised if appraisal is not updated.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE update_appraisal_for_person (
      p_effective_date                IN   DATE,
      p_appraisal_id                  IN   NUMBER,
      p_object_version_number         IN   NUMBER,
      p_appraiser_person_id           IN   NUMBER,
      p_appraisal_period_start_date   IN   DATE,
      p_appraisal_period_end_date     IN   DATE
   )
   IS
      -- Declare local variables
      l_proc                    VARCHAR2 (72) := g_package || 'update_appraisal_for_person ';
      --
      l_object_version_number   NUMBER        := p_object_version_number;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call update_appraisal
      --
      hr_appraisals_api.update_appraisal
                                    (p_effective_date                   => p_effective_date,
                                     p_appraisal_id                     => p_appraisal_id,
                                     p_object_version_number            => l_object_version_number,
                                     p_appraiser_person_id              => p_appraiser_person_id,
                                     p_appraisal_period_start_date      => p_appraisal_period_start_date,
                                     p_appraisal_period_end_date        => p_appraisal_period_end_date
                                    );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END update_appraisal_for_person;

--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_appraisal_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Deletes appraisal for a given person when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if appraisal is deleted.
--
-- Post Failure:
--  An application error is raised if appraisal is not deleted.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
   PROCEDURE delete_appraisal_for_person (p_appraisal_id IN NUMBER, p_object_version_number IN NUMBER)
   IS
      -- Declare local variables
      l_proc   VARCHAR2 (72) := g_package || 'delete_appraisal_for_person ';

      CURSOR get_assessm_for_apprl (apprl_id per_appraisals.appraisal_id%TYPE)
      IS
         SELECT assessment_id,
                object_version_number
           FROM per_assessments
          WHERE appraisal_id = apprl_id;

      CURSOR get_competences (assess_id per_assessments.assessment_id%TYPE)
      IS
         SELECT   competence_element_id,
                  object_version_number
             FROM per_competence_elements
            WHERE assessment_id = assess_id
         ORDER BY competence_element_id DESC;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --

      --
      -- Call delete_appraisal
      --
      FOR assess_records IN get_assessm_for_apprl (p_appraisal_id)
      LOOP
         FOR assess_comps IN get_competences (assess_records.assessment_id)
         LOOP
            hr_competence_element_api.delete_competence_element
                                    (p_validate                   => FALSE,
                                     p_competence_element_id      => assess_comps.competence_element_id,
                                     p_object_version_number      => assess_comps.object_version_number
                                    );
         END LOOP;

         hr_assessments_api.delete_assessment
                                    (p_validate                   => FALSE,
                                     p_assessment_id              => assess_records.assessment_id,
                                     p_object_version_number      => assess_records.object_version_number
                                    );
      END LOOP;

      hr_appraisals_api.delete_appraisal (p_validate                   => FALSE,
                                          p_appraisal_id               => p_appraisal_id,
                                          p_object_version_number      => p_object_version_number
                                         );

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   END delete_appraisal_for_person;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_plan_action >----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE get_plan_action (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
--
      l_action   VARCHAR2 (30);
--
   BEGIN
--
      IF (funcmode = 'RUN')
      THEN
         --
         l_action                   :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_ACTION'
                                      );

         --
         IF (l_action IN ('PUBLISH', 'REVERSE_PUBLISH'))
         THEN
            resultout                  := 'COMPLETE:' || l_action;
         ELSE
            resultout                  := 'ERROR' || 'Y';
         END IF;
      ELSE
         resultout                  := 'ERROR' || 'Y';
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'GET_PLAN_ACTION',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END get_plan_action;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_plan_method >----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE get_plan_method (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
--
      l_method   VARCHAR2 (30);
--
   BEGIN
--
      IF (funcmode = 'RUN')
      THEN
         --
         l_method                   :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_METHOD'
                                      );

         --
         IF (l_method IN ('CAS', 'PAR'))
         THEN
            resultout                  := 'COMPLETE:' || l_method;
         ELSE
            resultout                  := 'ERROR' || 'Y';
         END IF;
      ELSE
         resultout                  := 'ERROR' || 'Y';
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'GET_PLAN_METHOD',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END get_plan_method;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< start_process >----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE start_process (
      p_plan_rec         IN   per_perf_mgmt_plans%ROWTYPE,
      p_effective_date   IN   DATE,
      p_reverse_mode     IN   VARCHAR2,
      p_item_type        IN   VARCHAR2,
      p_wf_process       IN   VARCHAR2
   )
   IS
      -- Declare local variables
      l_proc                     VARCHAR2 (72)                := g_package || 'start_process';
      --
      l_item_key                 VARCHAR2 (30);
      l_item_user_key            VARCHAR2 (80)                := p_plan_rec.plan_id;
      l_plan_action              VARCHAR2 (80);
      l_top_msg_hdr              VARCHAR2 (2000);
      l_top_msg_txt              VARCHAR2 (2000);
      l_mbr_msg_hdr              VARCHAR2 (2000);
      l_mbr_msg_txt              VARCHAR2 (2000);
      l_role_name                wf_roles.NAME%TYPE;
      l_role_displayname         wf_roles.display_name%TYPE;
      l_admin_role_name          wf_roles.NAME%TYPE;
      l_admin_role_displayname   wf_roles.display_name%TYPE;
      l_wfthreshold              NUMBER;
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --
      --
      -- Derive the item key
      --
      SELECT hr_workflow_item_key_s.NEXTVAL
        INTO l_item_key
        FROM DUAL;

      --
      -- Derive the other values based on plan action
      --
      IF (p_reverse_mode = 'N')
      THEN
         l_plan_action              := 'PUBLISH';
      ELSIF (p_reverse_mode = 'Y')
      THEN
         l_plan_action              := 'REVERSE_PUBLISH';
      END IF;

      -- WF Process
      wf_engine.createprocess (itemtype      => p_item_type,
                               itemkey       => l_item_key,
                               process       => p_wf_process
                              );
      -- Item User Key
      wf_engine.setitemuserkey (itemtype      => p_item_type,
                                itemkey       => l_item_key,
                                userkey       => l_item_user_key
                               );
      -- Effective Date
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'EFFECTIVE_DATE',
                                 avalue        => p_effective_date
                                );
      -- Plan Id
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_ID',
                                 avalue        => p_plan_rec.plan_id
                                );
      -- Plan Name
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN',
                                 avalue        => p_plan_rec.plan_name
                                );
      -- Plan Action
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_ACTION',
                                 avalue        => l_plan_action
                                );
      -- Plan Method
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_METHOD',
                                 avalue        => p_plan_rec.method_code
                                );
      -- Plan Hierarchy
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_HIERARCHY',
                                 avalue        => p_plan_rec.hierarchy_type_code
                                );
      -- Plan Supervisor Id
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_SUPERVISOR_ID',
                                 avalue        => p_plan_rec.supervisor_id
                                );
      -- Plan Supervisor Assignment Id
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_SUPERVISOR_ASG_ID',
                                 avalue        => p_plan_rec.supervisor_assignment_id
                                );
      -- Plan Top Organization Id
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_TOP_ORG_ID',
                                 avalue        => p_plan_rec.top_organization_id
                                );
      -- Plan Top Position Id
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'WPM_PLAN_TOP_POS_ID',
                                 avalue        => p_plan_rec.top_position_id
                                );
      -- Objective Setting Start Date
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'OBJ_SET_START',
                                 avalue        => p_plan_rec.obj_setting_start_date
                                );
      -- Objective Setting End Date
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'OBJ_SET_FINISH',
                                 avalue        => p_plan_rec.obj_setting_deadline
                                );
      -- start changes for Bug#5903006
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'HR_WPM_OBJ_SETTING_FLAG',
                                 avalue        => p_plan_rec.include_obj_setting_flag
                                );
      -- End Changes for bug#5903006

      --
-- ------------------------------------
-- Get the Role for plan Administrator
-- ------------------------------------
--
      wf_directory.getrolename (p_orig_system         => 'PER',
                                p_orig_system_id      => p_plan_rec.administrator_person_id,
                                p_name                => l_admin_role_name,
                                p_display_name        => l_admin_role_displayname
                               );
      --
      -- Plan Administrator
      --
      wf_engine.setitemattrtext (itemtype      => p_item_type,
                                 itemkey       => l_item_key,
                                 aname         => 'HR_WPM_PLAN_ADMINISTRATOR',
                                 avalue        => l_admin_role_name
                                );
--
-- ---------------------------------
-- Get the Role for the Owner
-- ---------------------------------
--
      wf_directory.getrolename (p_orig_system         => 'FND_USR',
                                p_orig_system_id      => fnd_global.user_id,
                                p_name                => l_role_name,
                                p_display_name        => l_role_displayname
                               );
      --
      wf_engine.setitemowner (itemtype => p_item_type, itemkey => l_item_key, owner => l_role_name);
      --
      -- Changes by KMG for fixing BUG#7710591
      l_wfthreshold              := NVL (wf_engine.threshold, 50);
      wf_engine.threshold        := -1;                                -- Ensures a deferred process
      wf_engine.startprocess (itemtype => p_item_type, itemkey => l_item_key);
      wf_engine.threshold        := l_wfthreshold;

      --
      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_regular_log, 80);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := error;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         RAISE;
   END start_process;

--
-- ----------------------------------------------------------------------------
-- |----------------------< populate_plan_members_cache >---------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE populate_plan_members_cache (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      --
      l_plan_id          NUMBER;
      l_effective_date   DATE;

      -- Plan record
      CURSOR csr_get_plan_rec (p_plan_id NUMBER)
      IS
         SELECT *
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      --
      l_plan_rec         per_perf_mgmt_plans%ROWTYPE;
   BEGIN
      --
      IF (funcmode = 'RUN')
      THEN
         -- Get the workwlow attribute values
         l_plan_id                  :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_ID'
                                      );
         l_effective_date           :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'EFFECTIVE_DATE'
                                      );

         --
         -- Get plan record
         --
         OPEN csr_get_plan_rec (l_plan_id);

         FETCH csr_get_plan_rec
          INTO l_plan_rec;

         CLOSE csr_get_plan_rec;

         -- populate plan cache table
         populate_qual_plan_population (l_plan_rec, l_effective_date);

         --
         IF (g_plan_pop_known_t (l_plan_id) AND g_qual_pop_tbl.COUNT > 0)
         THEN
            resultout                  := 'COMPLETE:' || 'Y';
         ELSE
            resultout                  := 'COMPLETE:' || 'N';
         END IF;
      ELSE
         -- function mode is not Run
         resultout                  := 'ERROR' || 'Y';
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'POPULATE_PLAN_MEMBERS_CACHE',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END populate_plan_members_cache;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_plan_member >----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE get_plan_member (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      --
      l_plan_id            NUMBER;
      l_role_name          wf_roles.NAME%TYPE;
      l_role_displayname   wf_roles.display_name%TYPE;
   --
   BEGIN
      --
      IF (funcmode = 'RUN')
      THEN
         -- Get the workwlow attribute values
         l_plan_id                  :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_ID'
                                      );

         -- If plan population is known
         IF (g_plan_pop_known_t (l_plan_id))
         THEN
            --  Get the current plan member index
            IF (g_fetched_plan_member_index IS NULL)
            THEN
               g_fetched_plan_member_index := g_qual_pop_tbl.FIRST;
            ELSE
               g_fetched_plan_member_index := g_qual_pop_tbl.NEXT (g_fetched_plan_member_index);
            END IF;

            -- Loop till member is found with wf role
            WHILE (g_fetched_plan_member_index IS NOT NULL)
            LOOP
               -- Get the Role for the Owner
               wf_directory.getrolename
                        (p_orig_system         => 'PER',
                         p_orig_system_id      => g_qual_pop_tbl (g_fetched_plan_member_index).person_id,
                         p_name                => l_role_name,
                         p_display_name        => l_role_displayname
                        );

               --
               IF (l_role_name IS NOT NULL)
               THEN
                  wf_engine.setitemattrtext (itemtype, itemkey, 'WPM_PLAN_MEMBER', l_role_name);
                  resultout                  := 'COMPLETE:' || 'Y';
                  RETURN;
               END IF;

               --
               g_fetched_plan_member_index := g_qual_pop_tbl.NEXT (g_fetched_plan_member_index);
            --
            END LOOP;

            -- Loop complete wf role is not found for any plan member
            resultout                  := 'COMPLETE:' || 'N';
         --
         ELSE
            -- Plan population is not known
            resultout                  := 'ERROR' || 'Y';
         END IF;
      ELSE
         -- function mode is not Run
         resultout                  := 'ERROR' || 'Y';
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'GET_PLAN_MEMBER',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END get_plan_member;

--
-- ----------------------------------------------------------------------------
-- |------------------------< get_top_plan_member >--------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE get_top_plan_member (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      --
      l_plan_id            NUMBER;
      l_plan_hierarchy     VARCHAR2 (30);
      l_top_id             NUMBER;
      l_role_name          wf_roles.NAME%TYPE;
      l_role_displayname   wf_roles.display_name%TYPE;
   --
   BEGIN
      --
      IF (funcmode = 'RUN')
      THEN
         -- Get the workwlow attribute values
         l_plan_id                  :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_ID'
                                      );
         --
         l_plan_hierarchy           :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_HIERARCHY'
                                      );

         IF (l_plan_hierarchy = 'SUP')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_SUPERVISOR_ID'
                                         );
         ELSIF (l_plan_hierarchy = 'SUP_ASG')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_SUPERVISOR_ASG_ID'
                                         );
         ELSIF (l_plan_hierarchy = 'ORG')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_TOP_ORG_ID'
                                         );
         ELSIF (l_plan_hierarchy = 'POS')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_TOP_POS_ID'
                                         );
         END IF;

         -- If plan population is known
         IF (g_plan_pop_known_t (l_plan_id))
         THEN
            --  Get the current plan member index
            IF (g_fetched_plan_member_index IS NULL)
            THEN
               g_fetched_plan_member_index := g_qual_pop_tbl.FIRST;
            ELSE
               g_fetched_plan_member_index := g_qual_pop_tbl.NEXT (g_fetched_plan_member_index);
            END IF;

            -- Loop till member is found with wf role
            WHILE (g_fetched_plan_member_index IS NOT NULL)
            LOOP
               IF    (    l_plan_hierarchy = 'SUP'
                      AND g_qual_pop_tbl (g_fetched_plan_member_index).person_id = l_top_id
                     )
                  OR (    l_plan_hierarchy = 'SUP_ASG'
                      AND g_qual_pop_tbl (g_fetched_plan_member_index).assignment_id = l_top_id
                     )
                  OR (    l_plan_hierarchy = 'ORG'
                      AND g_qual_pop_tbl (g_fetched_plan_member_index).organization_id = l_top_id
                     )
                  OR (    l_plan_hierarchy = 'POS'
                      AND g_qual_pop_tbl (g_fetched_plan_member_index).position_id = l_top_id
                     )
               THEN
                  -- Get the Role for the Owner
                  wf_directory.getrolename
                        (p_orig_system         => 'PER',
                         p_orig_system_id      => g_qual_pop_tbl (g_fetched_plan_member_index).person_id,
                         p_name                => l_role_name,
                         p_display_name        => l_role_displayname
                        );

                  --
                  IF (l_role_name IS NOT NULL)
                  THEN
                     wf_engine.setitemattrtext (itemtype, itemkey, 'WPM_PLAN_MEMBER', l_role_name);
                     resultout                  := 'COMPLETE:' || 'Y';
                     RETURN;
                  END IF;
               --
               END IF;

               --
               g_fetched_plan_member_index := g_qual_pop_tbl.NEXT (g_fetched_plan_member_index);
            --
            END LOOP;

            -- Loop complete wf role is not found for any plan member
            resultout                  := 'COMPLETE:' || 'N';
         --
         ELSE
            -- Plan population is not known
            resultout                  := 'ERROR' || 'Y';
         END IF;
      ELSE
         -- function mode is not Run
         resultout                  := 'ERROR' || 'Y';
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'GET_TOP_PLAN_MEMBER',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END get_top_plan_member;

--
-- ----------------------------------------------------------------------------
-- |----------------------< get_non_top_plan_member >-------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE get_non_top_plan_member (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      --
      l_plan_id            NUMBER;
      l_plan_hierarchy     VARCHAR2 (30);
      l_top_id             NUMBER;
      l_role_name          wf_roles.NAME%TYPE;
      l_role_displayname   wf_roles.display_name%TYPE;
      l_sc_exists          VARCHAR2 (20);

      CURSOR csr_chk_sc_exists (p_assignment_id NUMBER, p_plan_id NUMBER)
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (SELECT 'X'
                          FROM per_personal_scorecards
                         WHERE plan_id = p_plan_id AND assignment_id = p_assignment_id);
   --
   BEGIN
      --
      IF (funcmode = 'RUN')
      THEN
         -- Get the workwlow attribute values
         l_plan_id                  :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_ID'
                                      );
         --
         l_plan_hierarchy           :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_HIERARCHY'
                                      );

         IF (l_plan_hierarchy = 'SUP')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_SUPERVISOR_ID'
                                         );
         ELSIF (l_plan_hierarchy = 'SUP_ASG')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_SUPERVISOR_ASG_ID'
                                         );
         ELSIF (l_plan_hierarchy = 'ORG')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_TOP_ORG_ID'
                                         );
         ELSIF (l_plan_hierarchy = 'POS')
         THEN
            --
            l_top_id                   :=
               wf_engine.getitemattrtext (itemtype      => itemtype,
                                          itemkey       => itemkey,
                                          aname         => 'WPM_PLAN_TOP_POS_ID'
                                         );
         END IF;

         -- If plan population is known
         IF (g_plan_pop_known_t (l_plan_id))
         THEN
            --  Get the current plan member index
            IF (g_fetched_plan_member_index IS NULL)
            THEN
               g_fetched_plan_member_index := g_qual_pop_tbl.FIRST;
            ELSE
               g_fetched_plan_member_index := g_qual_pop_tbl.NEXT (g_fetched_plan_member_index);
            END IF;

            -- Loop till member is found with wf role
            WHILE (g_fetched_plan_member_index IS NOT NULL)
            LOOP
               l_sc_exists                := 'N';

--changed by schowdhu 8865480 08-Sep-09
               OPEN csr_chk_sc_exists (g_fetched_plan_member_index, l_plan_id);

               FETCH csr_chk_sc_exists
                INTO l_sc_exists;

               CLOSE csr_chk_sc_exists;

               IF NVL (l_sc_exists, 'N') = 'Y'
               THEN

                  IF    (    l_plan_hierarchy = 'SUP'
                         AND g_qual_pop_tbl (g_fetched_plan_member_index).person_id <> l_top_id
                        )
                     OR (    l_plan_hierarchy = 'SUP_ASG'
                         AND g_qual_pop_tbl (g_fetched_plan_member_index).assignment_id <> l_top_id
                        )
                     OR (    l_plan_hierarchy = 'ORG'
                         AND g_qual_pop_tbl (g_fetched_plan_member_index).organization_id <>
                                                                                            l_top_id
                        )
                     OR (    l_plan_hierarchy = 'POS'
                         AND g_qual_pop_tbl (g_fetched_plan_member_index).position_id <> l_top_id
                        )
                  THEN
                     -- Get the Role for the Owner
                     wf_directory.getrolename
                        (p_orig_system         => 'PER',
                         p_orig_system_id      => g_qual_pop_tbl (g_fetched_plan_member_index).person_id,
                         p_name                => l_role_name,
                         p_display_name        => l_role_displayname
                        );

                     --
                     IF (l_role_name IS NOT NULL)
                     THEN
                        wf_engine.setitemattrtext (itemtype,
                                                   itemkey,
                                                   'WPM_PLAN_MEMBER',
                                                   l_role_name
                                                  );
                        resultout                  := 'COMPLETE:' || 'Y';
                        RETURN;
                     END IF;
                  --
                  END IF;
               END IF;                                                                -- l_sc_exists

               --
               g_fetched_plan_member_index := g_qual_pop_tbl.NEXT (g_fetched_plan_member_index);
            --
            END LOOP;

            -- Loop complete wf role is not found for any plan member
            resultout                  := 'COMPLETE:' || 'N';
         --
         ELSE
            -- Plan population is not known
            resultout                  := 'ERROR' || 'Y';
         END IF;
      ELSE
         -- function mode is not Run
         resultout                  := 'ERROR' || 'Y';
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'GET_NON_TOP_PLAN_MEMBER',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END get_non_top_plan_member;

--
-- ----------------------------------------------------------------------------
-- |---------------------< submit_publish_plan_cp >---------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE submit_publish_plan_cp (
      p_effective_date          IN              VARCHAR2,
      p_plan_id                 IN              NUMBER,
      p_reverse_mode            IN              VARCHAR2,
      p_item_type               IN              VARCHAR2,
      p_wf_process              IN              VARCHAR2,
      p_object_version_number   IN OUT NOCOPY   NUMBER,
      p_status_code             IN OUT NOCOPY   VARCHAR2
   )
   IS
      --
      l_object_version_number   NUMBER                                 := p_object_version_number;
      l_status_code             per_perf_mgmt_plans.status_code%TYPE;
      l_dummy                   BOOLEAN;
      l_request_id              NUMBER;
      l_effective_date          DATE                     := NVL (p_effective_date, TRUNC (SYSDATE));

      -- Plan record
      CURSOR csr_get_plan_rec
      IS
         SELECT *
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      l_plan_rec                per_perf_mgmt_plans%ROWTYPE;
   --
   BEGIN
      -- Submit the request
      l_request_id               :=
         fnd_request.submit_request (application      => 'PER',
                                     program          => 'PERPLNPUB',
                                     sub_request      => FALSE,
                                     argument1        => fnd_date.date_to_canonical
                                                                                   (l_effective_date),
                                     argument2        => p_plan_id,
                                     argument3        => p_reverse_mode,
                                     argument4        => 'N',
                                     argument5        => 'Y',
                                     argument6        => NULL,
                                     argument7        => 'HRWPM',
                                     argument8        => 'HR_NOTIFY_WPM_PLAN_POP_PRC'
                                    );

      --
      IF l_request_id > 0
      THEN
         -- Update the status of plan
         IF (p_status_code = 'DRAFT')
         THEN
            l_status_code              := 'SUBMITTED';
         ELSIF (p_status_code = 'UPDATED' OR p_status_code = 'FAILED')
         THEN
            l_status_code              := 'RESUBMITTED';
         END IF;

         --
         per_pmp_upd.upd (p_plan_id                     => p_plan_id,
                          p_effective_date              => l_effective_date,
                          p_object_version_number       => l_object_version_number,
                          p_status_code                 => l_status_code,
                          p_duplicate_name_warning      => l_dummy,
                          p_no_life_events_warning      => l_dummy
                         );
         --
         p_object_version_number    := l_object_version_number;
         p_status_code              := l_status_code;

         --
         -- Get Plan record
         --
         OPEN csr_get_plan_rec;

         FETCH csr_get_plan_rec
          INTO l_plan_rec;

         CLOSE csr_get_plan_rec;

         --
         -- Send notification to administrator that plan publish errored
         --
         send_fyi_admin (p_plan_rec        => l_plan_rec,
                         p_status          => 'SUBMITTED',
                         p_request_id      => l_request_id
                        );
      ELSE
         p_status_code              := 'E';
      END IF;
   --
   END submit_publish_plan_cp;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< publish_plan_cp >----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE publish_plan_cp (
      errbuf                        OUT NOCOPY      VARCHAR2,
      retcode                       OUT NOCOPY      NUMBER,
      p_effective_date              IN              VARCHAR2,
      p_plan_id                     IN              NUMBER,
      p_reverse_mode                IN              VARCHAR2 DEFAULT 'N',
      p_what_if                     IN              VARCHAR2 DEFAULT 'N',
      p_log_output                  IN              VARCHAR2 DEFAULT 'N',
      p_action_parameter_group_id   IN              NUMBER DEFAULT NULL,
      p_item_type                   IN              VARCHAR2 DEFAULT 'HRWPM',
      p_wf_process                  IN              VARCHAR2 DEFAULT 'HR_NOTIFY_WPM_PLAN_POP_PRC'
   )
   IS
--
      CURSOR csr_plan_ovn
      IS
         SELECT object_version_number
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      CURSOR csr_plan_status_code
      IS
         SELECT status_code
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      l_object_version_number   NUMBER;
      l_status_code             per_perf_mgmt_plans.status_code%TYPE;
      l_dummy                   BOOLEAN;
	  l_wpm_batch_action_id VARCHAR2(30);
--
   BEGIN

     -- WPM Logging Changes
--     HR_WPM_MASS_APR_PUSH.l_current_wpm_batch_action_id := per_wpm_batch_actions_s.NEXTVAL;
          SELECT per_wpm_batch_actions_s.NEXTVAL
		    INTO l_wpm_batch_action_id
 			FROM dual;

          HR_WPM_MASS_APR_PUSH.l_current_wpm_batch_action_id := l_wpm_batch_action_id;

          INSERT INTO per_wpm_batch_actions
	       (WPM_BATCH_ACTION_ID,
					CONC_REQUEST_ID,
					CONC_PROGRAM_NAME,
					PLAN_ID,
					APPRAISAL_PERIOD_ID,
					STATUS,
					START_DATE,
					END_DATE
        )
		    VALUES (l_wpm_batch_action_id,
		           fnd_global.conc_request_id,
		           'PERPLNPUB',
		            p_plan_id,
		            NULL,
		            'PENDING',
		             sysdate, --p_effective_date, -- trunc(sysdate)
		             null
    );
    COMMIT;

      --
      -- Derive the object version number of plan record
      --
      OPEN csr_plan_ovn;

      FETCH csr_plan_ovn
       INTO l_object_version_number;

      CLOSE csr_plan_ovn;

-- get the status of plan, if it is called from scheduled concureent program status should be chsnged to resubmitted.
      OPEN csr_plan_status_code;

      FETCH csr_plan_status_code
       INTO l_status_code;

      CLOSE csr_plan_status_code;

      -- Initialize return status
      retcode                    := warning;

-- (bug 6460457) changes to allow published plan to be rerun through scheduled concurrent prgms.
      IF l_status_code IN ('PUBLISHED', 'FAILED')
      THEN
         l_status_code              := 'RESUBMITTED';
         per_pmp_upd.upd (p_plan_id                     => p_plan_id,
                          p_effective_date              => fnd_date.canonical_to_date
                                                                                   (p_effective_date),
                          p_object_version_number       => l_object_version_number,
                          p_status_code                 => l_status_code,
                          p_duplicate_name_warning      => l_dummy,
                          p_no_life_events_warning      => l_dummy
                         );

         -- get the new ovn number to pass it to publish_plan function as update is called before this once
         OPEN csr_plan_ovn;

         FETCH csr_plan_ovn
          INTO l_object_version_number;

         CLOSE csr_plan_ovn;
      END IF;

      -- WPM Logging Changes  Post Review
      -- to avoid caching issues
      hr_wpm_mass_apr_push.g_wpm_person_actions.DELETE;
      hr_wpm_mass_apr_push.log_records_index := NULL;

      --
      --  Call the publish plan
      --
      publish_plan (p_effective_date                 => fnd_date.canonical_to_date (p_effective_date),
                    p_plan_id                        => p_plan_id,
                    p_object_version_number          => l_object_version_number,
                    p_reverse_mode                   => p_reverse_mode,
                    p_what_if                        => p_what_if,
                    p_log_output                     => p_log_output,
                    p_action_parameter_group_id      => p_action_parameter_group_id,
                    p_item_type                      => p_item_type,
                    p_wf_process                     => p_wf_process
                   );
      --
      errbuf                     := g_errbuf;
      retcode                    := g_retcode;
      --
         -- WPM Logging Changes
         HR_WPM_MASS_APR_PUSH.print_cache();
         UPDATE per_wpm_batch_actions
	   SET END_DATE = sysdate, STATUS = decode(g_retcode,0,'SUCCESS','WARNING')
	   WHERE WPM_BATCH_ACTION_ID = HR_WPM_MASS_APR_PUSH.l_current_wpm_batch_action_id;

      COMMIT;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
            -- WPM Logging Changes
            HR_WPM_MASS_APR_PUSH.print_cache();
            UPDATE per_wpm_batch_actions
            SET STATUS = 'ERROR', END_DATE = sysdate
            WHERE WPM_BATCH_ACTION_ID = HR_WPM_MASS_APR_PUSH.l_current_wpm_batch_action_id;
            COMMIT;

         --
         -- update status of the plan to 'Failed'
         --
         UPDATE per_perf_mgmt_plans
            SET status_code = 'FAILED'
          WHERE plan_id = p_plan_id;

         COMMIT;
         --
         errbuf                     := g_errbuf;
         retcode                    := g_retcode;
   --
   END publish_plan_cp;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< publish_plan >-----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE publish_plan (
      p_effective_date              IN              DATE,
      p_plan_id                     IN              NUMBER,
      p_object_version_number       IN OUT NOCOPY   NUMBER,
      p_reverse_mode                IN              VARCHAR2 DEFAULT 'N',
      p_what_if                     IN              VARCHAR2 DEFAULT 'N',
      p_log_output                  IN              VARCHAR2 DEFAULT 'N',
      p_action_parameter_group_id   IN              NUMBER DEFAULT NULL,
      p_item_type                   IN              VARCHAR2 DEFAULT 'HRWPM',
      p_wf_process                  IN              VARCHAR2 DEFAULT 'HR_NOTIFY_WPM_PLAN_POP_PRC'
   )
   IS
      --
      -- Declare cursors and local variables
      --
      l_proc                    VARCHAR2 (72)                        := g_package || 'publish_plan';
      l_logging                 pay_action_parameters.parameter_value%TYPE;
      l_debug                   BOOLEAN                                       := FALSE;
      l_effective_date          DATE                     := TRUNC (NVL (p_effective_date, SYSDATE));
      l_object_version_number   NUMBER;
      l_status_code             per_perf_mgmt_plans.status_code%TYPE;
      l_dummy                   BOOLEAN;
      --
      l_scorecard_id            per_personal_scorecards.scorecard_id%TYPE;
      --
      l_message_count           NUMBER                                        := 0;
      l_message                 VARCHAR2 (256);
      l_qual_pop_index          BINARY_INTEGER;
      l_curr_sc_pop_index       BINARY_INTEGER;
      l_qual_obj_index          BINARY_INTEGER;
      l_plan_aprsl_pds_index    BINARY_INTEGER;
      l_curr_sc_obj_index       BINARY_INTEGER;
      l_appr_ret_status         VARCHAR2 (1);
      l_check_elig              VARCHAR2 (1);
      l_check_elig_person       VARCHAR2 (1);
      --
      l_submit_new_req          BOOLEAN                                       := TRUE;
      l_conc_request_id         NUMBER                                        := 0;
      e                         EXCEPTION;
      l_ret                     BOOLEAN;
      l_message_req             VARCHAR (2000);

        --
      -- Cursor to get the  Participants of an appraisal other than MA
      CURSOR csr_get_appr_part (p_appraisal_id per_appraisals.appraisal_id%TYPE)
      IS
         SELECT participant_id,
                object_version_number,
                participation_type
           FROM per_participants
          WHERE participation_in_id = p_appraisal_id
            AND participation_in_table = 'PER_APPRAISALS'
            AND participation_in_column = 'APPRAISAL_ID'
            AND participation_type <> 'MAINAP'
            AND participation_status = 'OPEN';

--Cursor to get pending Requests
      CURSOR previous_concurrent_requests (
         plan_id               per_appraisals.plan_id%TYPE,
         appraisal_period_id   per_appraisal_periods.appraisal_period_id%TYPE
      )
      IS
         SELECT cr.request_id,
                cr.phase_code
           FROM fnd_concurrent_programs cp, fnd_concurrent_requests cr
          WHERE cp.concurrent_program_name = 'WPMAPRPUSH'
            AND cp.application_id = 800
            AND cp.concurrent_program_id = cr.concurrent_program_id
            AND cr.argument2 = TO_CHAR (plan_id)
            AND cr.argument3 = TO_CHAR (appraisal_period_id)
            AND cr.actual_start_date IS NULL
            AND cr.actual_completion_date IS NULL
            AND cr.phase_code = 'P';

      -- Plan record
      CURSOR csr_get_plan_rec
      IS
         SELECT *
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      -- Scorecard Objectives
      CURSOR csr_sc_objectives (p_scorecard_id NUMBER)
      IS
         SELECT objective_id,
                object_version_number
           FROM per_objectives
          WHERE scorecard_id = p_scorecard_id;

      CURSOR csr_plan_appraisals (plan_id per_appraisals.plan_id%TYPE)
      IS
         SELECT appraisal_id,
                object_version_number
           FROM per_appraisals
          WHERE plan_id = plan_id;

      CURSOR csr_find_appr_for_scorecard (
         p_plan_id        per_appraisals.plan_id%TYPE,
         p_scorecard_id   per_personal_scorecards.scorecard_id%TYPE
      )
      IS
         SELECT pa.appraisal_id,
                pa.object_version_number,
                pa.appraisal_system_status
           FROM per_appraisals pa, per_personal_scorecards pps
          WHERE pa.plan_id = p_plan_id
            AND appraisee_person_id = pps.person_id
            AND pps.scorecard_id = p_scorecard_id;

      -- cursor added
      -- 23-Jun-2009 schowdhu Eligibility Profile Enhc.
      CURSOR get_elig_obj_id_for_person (p_plan_id IN per_perf_mgmt_plans.plan_id%TYPE)
      IS
         SELECT elig.elig_obj_id
           FROM ben_elig_obj_f elig
          WHERE elig.table_name = 'PER_PERF_MGMT_PLANS'
            AND elig.column_name = 'PLAN_ID'
            AND elig.COLUMN_VALUE = p_plan_id
            AND TRUNC (SYSDATE) BETWEEN elig.effective_start_date AND elig.effective_end_date;

      CURSOR get_person_name (p_person_id IN per_all_people_f.person_id%TYPE)
      IS
         SELECT full_name
           FROM per_all_people_f ppf
          WHERE ppf.person_id = p_person_id
            AND l_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

      l_plan_rec                per_perf_mgmt_plans%ROWTYPE;
      l_obj_date                DATE                                          := TRUNC (SYSDATE);
      l_scorecard_status_code   VARCHAR2 (30);
      l_process_date            DATE;
      l_process_date_char       VARCHAR2 (50);
      l_request_id              NUMBER;
      l_appr_ovn                per_appraisals.object_version_number%TYPE;
      l_appr_id                 per_appraisals.appraisal_id%TYPE;
      l_appr_sys_status         per_appraisals.appraisal_system_status%TYPE;
      l_appraiser_person_id     per_appraisals.appraiser_person_id%TYPE;
      l_elig_obj_id             ben_elig_obj_f.elig_obj_id%TYPE;
      l_person_name             per_all_people_f.full_name%TYPE;
   BEGIN
      --
      -- Initialize logging
      --
      initialize_logging (p_action_parameter_group_id      => p_action_parameter_group_id,
                          p_log_output                     => p_log_output
                         );

      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --
      -- Get Plan record
      --
      OPEN csr_get_plan_rec;

      FETCH csr_get_plan_rec
       INTO l_plan_rec;

      CLOSE csr_get_plan_rec;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 20);
      END IF;

      l_request_id               := fnd_global.conc_request_id;

      IF g_dbg
      THEN
         op ('Plan Name: ' || SUBSTR (l_plan_rec.plan_name, 1, 40), g_debug_log, 21);
      END IF;

      IF g_dbg
      THEN
         op ('Concurrent Request ID: ' || TO_CHAR (l_request_id), g_debug_log, 22);
      END IF;

      --
      -- Checks that the status is valid for PLAN PUBLISH OR REVERSE PUBLISH
      --
      chk_publishing_status (p_reverse_mode, l_plan_rec.status_code);

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 30);
      END IF;

      -- If objective setting flag or appraisals flag is set then
      -- populate qualifying population table
      IF ((l_plan_rec.include_obj_setting_flag = 'Y') OR (l_plan_rec.include_appraisals_flag = 'Y')
         )
      THEN
         --
         -- Get the qualifying plan population
         -- g_qual_pop_tbl is populated with index as 'assignment_id'
         --
         populate_qual_plan_population (l_plan_rec, l_effective_date);

         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 40);
         END IF;
      END IF;

      -- If objective setting flag is set then
      -- populate current population and qualifying objectives tables
      IF ((l_plan_rec.include_obj_setting_flag = 'Y') OR (l_plan_rec.include_appraisals_flag = 'Y')
         )
      THEN
         --
         -- Get existing plan population if plan is republished or reverse published
         -- g_curr_sc_pop_tbl is populated with index as 'assignment_id'
         --
         IF (l_plan_rec.status_code IN ('UPDATED', 'RESUBMITTED', 'PUBLISHED'))
         THEN
            --
            IF g_dbg
            THEN
               op (l_proc, g_debug_log, 50);
            END IF;

            populate_curr_plan_population (p_plan_id);
         END IF;

         --
         -- Get the qualifying objectives
         -- g_qual_obj_tbl is populated with index as 'objective_id'
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 60);
         END IF;

         --
         IF (l_plan_rec.automatic_allocation_flag = 'Y')
         THEN
            populate_qual_objectives (l_plan_rec.start_date, l_plan_rec.end_date);
         END IF;
      END IF;

      -- If appraisals flag is set then
      -- populate appraisala period table
      IF (l_plan_rec.include_appraisals_flag = 'Y')
      THEN
         --
         -- Get the qualifying plan periods
         -- g_plan_aprsl_pds_tbl is populated with details
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 70);
         END IF;

         --
         populate_plan_apprsl_periods (l_plan_rec.plan_id);
      END IF;

      --
      -- Loop through plan population to create/update/delete scorecards, objectives and appraisal
      --
      l_qual_pop_index           := g_qual_pop_tbl.FIRST;

      WHILE (l_qual_pop_index IS NOT NULL)
      LOOP
        -- WPM Logging Changes
        hr_wpm_mass_apr_push.log_records_index := g_qual_pop_tbl (l_qual_pop_index).assignment_id;
        IF NOT hr_wpm_mass_apr_push.g_wpm_person_actions.EXISTS (hr_wpm_mass_apr_push.log_records_index)
        THEN
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).wpm_person_action_id := -1;
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).wpm_batch_action_id := hr_wpm_mass_apr_push.l_current_wpm_batch_action_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).person_id := g_qual_pop_tbl (l_qual_pop_index).person_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).assignment_id := g_qual_pop_tbl (l_qual_pop_index).assignment_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).business_group_id := g_qual_pop_tbl (l_qual_pop_index).business_group_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).processing_status := 'P'; -- Processing
        hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).transaction_ref_table := 'PER_PERSONAL_SCORECARDS';
        hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).eligibility_status := 'Y'; -- Default handling cases of plan republish
        END IF;

         --
         l_qual_obj_index           := g_qual_obj_tbl.FIRST;

         IF (   l_plan_rec.status_code IN ('DRAFT', 'SUBMITTED')
             OR (    l_plan_rec.status_code IN ('UPDATED', 'RESUBMITTED')
                 AND NOT g_curr_sc_pop_tbl.EXISTS (l_qual_pop_index)
                )
            )
         THEN
            -- If objective setting flag is set
            IF (   (l_plan_rec.include_obj_setting_flag = 'Y')
                OR (l_plan_rec.include_appraisals_flag = 'Y')
               )
            THEN
               --Check for the elibility of the employee/assignment
               --23-Jun-2009 schowdhu Eligibility Profile Enhc.- start
               OPEN get_elig_obj_id_for_person (l_plan_rec.plan_id);

               FETCH get_elig_obj_id_for_person
                INTO l_elig_obj_id;

               CLOSE get_elig_obj_id_for_person;

               OPEN get_person_name (g_qual_pop_tbl (l_qual_pop_index).person_id);

               FETCH get_person_name
                INTO l_person_name;

               CLOSE get_person_name;

                 IF (l_elig_obj_id IS NULL)
                THEN
                  -- WPM Logging Changes
                  hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).eligibility_status := 'Y';
               END IF;

               IF (l_elig_obj_id IS NOT NULL)                        -- Eligiblity profile is chosen
               THEN
                  BEGIN
                     --
                     ben_env_object.init
                        (p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                         p_thread_id              => NULL,
                         p_chunk_size             => NULL,
                         p_threads                => NULL,
                         p_max_errors             => NULL,
                         p_benefit_action_id      => NULL,
                         p_effective_date         => l_obj_date
                        );
                     --
                     l_check_elig_person        :=
                        ben_per_asg_elig.eligible
                                                 (g_qual_pop_tbl (l_qual_pop_index).person_id,
                                                  g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                                  l_elig_obj_id,
                                                  l_obj_date,
                                                  g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                                                  'Y' ---KMG -- Added to Allow CWK's
                                                 );
                        -- WPM Logging Changes
                       hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).eligibility_status :=  l_check_elig_person;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_check_elig_person        := 'N';
                        -- WPM Logging Changes
                       hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).eligibility_status :=  l_check_elig_person;
                       -- WPM Logging Changes Post Review
                       hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TYPE := 'E';
                       hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_NUMBER := 'OTHER';
                       hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TEXT := SQLERRM;
                       hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).processing_status := 'ERROR'; -- Error

                        op (   'Eligibility Check errored for: '
                            || l_person_name
                            || ' ('
                            || g_qual_pop_tbl (l_qual_pop_index).person_id
                            || '). No Scorecard created.',
                            g_regular_log
                           );
                        op (SQLERRM, g_regular_log, 331);

                        --logged if the topmost person is excluded from the plan population     schowdhu 8744109
                        IF    (    l_plan_rec.hierarchy_type_code = 'SUP'
                               AND l_plan_rec.supervisor_id =
                                                         g_qual_pop_tbl (l_qual_pop_index).person_id
                              )
                           OR (    l_plan_rec.hierarchy_type_code = 'SUP_ASG'
                               AND l_plan_rec.supervisor_assignment_id =
                                                     g_qual_pop_tbl (l_qual_pop_index).assignment_id
                              )
                           OR (    l_plan_rec.hierarchy_type_code IN ('POS')
                               AND l_plan_rec.top_position_id =
                                                       g_qual_pop_tbl (l_qual_pop_index).position_id
                              )
                           OR (    l_plan_rec.hierarchy_type_code = 'ORG'
                               AND is_supervisor_in_org (l_plan_rec.top_organization_id,
                                                         g_qual_pop_tbl (l_qual_pop_index).person_id
                                                        ) = 1
                              )
                        THEN
                           op
                              ('+-------------------------------------------------------------------+',
                               g_regular_log
                              );
                           op (   'Warning: Eligibility Check errored for the topmost person '
                               || l_person_name
                               || ' ('
                               || g_qual_pop_tbl (l_qual_pop_index).person_id
                               || ').',
                               g_regular_log
                              );
                           op
                              ('+-------------------------------------------------------------------+',
                               g_regular_log
                              );
                           g_retcode                  := warning;
                        END IF;
                  END;
               END IF;

--     l_elig_obj_id null check                                      -- Eligiblity profile is chosen END
               IF (l_check_elig_person = 'N')
               THEN
                  op (   ' Not Eligible. Publish plan SKIPPED for '
                      || l_person_name
                      || ' ('
                      || g_qual_pop_tbl (l_qual_pop_index).person_id
                      || ').',
                      g_regular_log
                     );

                  --logged if the topmost person is excluded from the plan population     schowdhu 8744109
                  IF    (    l_plan_rec.hierarchy_type_code = 'SUP'
                         AND l_plan_rec.supervisor_id = g_qual_pop_tbl (l_qual_pop_index).person_id
                        )
                     OR (    l_plan_rec.hierarchy_type_code = 'SUP_ASG'
                         AND l_plan_rec.supervisor_assignment_id =
                                                     g_qual_pop_tbl (l_qual_pop_index).assignment_id
                        )
                     OR (    l_plan_rec.hierarchy_type_code IN ('POS')
                         AND l_plan_rec.top_position_id =
                                                       g_qual_pop_tbl (l_qual_pop_index).position_id
                        )
                     OR (    l_plan_rec.hierarchy_type_code = 'ORG'
                         AND is_supervisor_in_org (l_plan_rec.top_organization_id,
                                                   g_qual_pop_tbl (l_qual_pop_index).person_id
                                                  ) = 1
                        )
                  THEN
                     op ('+-------------------------------------------------------------------+',
                         g_regular_log
                        );
                     op
                        (   'Warning: Topmost person '
                         || l_person_name
                         || ' ('
                         || g_qual_pop_tbl (l_qual_pop_index).person_id
                         || ') '
                         || 'is excluded from   the plan as he is ineligble as per the eligibility profile attached. ',
                         g_regular_log
                        );
                     op ('+-------------------------------------------------------------------+',
                         g_regular_log
                        );
                     g_retcode                  := warning;
                  END IF;
               END IF;

-- end 23-Jun-2009 schowdhu Eligibility Profile Enhc.
               IF (   l_check_elig_person = 'Y'
                   OR (l_check_elig_person IS NULL AND l_elig_obj_id IS NULL)
                  )
               THEN
                  -- Create the scorecard for this assignment
                  IF g_dbg
                  THEN
                     op (l_proc, g_debug_log, 80);
                  END IF;

                  IF l_plan_rec.method_code = 'CAS'
                  THEN
                     IF    (    l_plan_rec.hierarchy_type_code = 'SUP'
                            AND l_plan_rec.supervisor_id =
                                                         g_qual_pop_tbl (l_qual_pop_index).person_id
                           )
                        OR (    l_plan_rec.hierarchy_type_code = 'SUP_ASG'
                            AND l_plan_rec.supervisor_assignment_id =
                                                     g_qual_pop_tbl (l_qual_pop_index).assignment_id
                           )
                        OR (    l_plan_rec.hierarchy_type_code IN ('POS')
                            AND l_plan_rec.top_position_id =
                                                       g_qual_pop_tbl (l_qual_pop_index).position_id
                           )
                        OR (    l_plan_rec.hierarchy_type_code = 'ORG'
                            AND is_supervisor_in_org (l_plan_rec.top_organization_id,
                                                      g_qual_pop_tbl (l_qual_pop_index).person_id
                                                     ) = 1
                           )
                     THEN
                        l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
                     ELSE
                        l_scorecard_status_code    := 'NOT_STARTED_WITH_MGR';
                     END IF;
                  ELSE
                     l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
                  END IF;

                  --
                  create_scorecard_for_person
                                 (p_effective_date      => l_effective_date,
                                  p_scorecard_name      => l_plan_rec.plan_name,
                                  p_assignment_id       => g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                  p_start_date          => l_plan_rec.start_date,
                                  p_end_date            => l_plan_rec.end_date,
                                  p_plan_id             => l_plan_rec.plan_id,
                                  p_creator_type        => 'AUTO',
                                  p_status_code         => l_scorecard_status_code,
                                  p_scorecard_id        => l_scorecard_id
                                 );

                  -- Loop through objectives and create the qualifying objectives for scorecard
                  -- make sure objectives are not created if scorecard is not created
                  IF (l_plan_rec.automatic_allocation_flag = 'Y' AND l_scorecard_id IS NOT NULL)
                  THEN
                     l_qual_obj_index           := g_qual_obj_tbl.FIRST;

                     WHILE (l_qual_obj_index IS NOT NULL)
                     LOOP
                        -- Following is commented, and l_obj_date is being set to sysdate bug# 5211538
                        -- l_obj_date is being seto to sysdate in the declare block itself
                        /*
                        -- objective date should be later of plan start date on obgective valif_from date
                        l_obj_date := l_plan_rec.start_date;
                        IF (l_plan_rec.start_date < g_qual_obj_tbl(l_qual_obj_index).valid_from) THEN
                          l_obj_date := g_qual_obj_tbl(l_qual_obj_index).valid_from;
                        END IF;
                        */
                          --
                          -- Enclose the call to eligibility within a block, so that if for any
                          -- reason the eligibility engine errors, then process can still
                          -- continue by skipping the current person/assignemnt as not eligible
                          --
                        BEGIN
                           --
                           ben_env_object.init
                              (p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                               p_thread_id              => NULL,
                               p_chunk_size             => NULL,
                               p_threads                => NULL,
                               p_max_errors             => NULL,
                               p_benefit_action_id      => NULL,
                               p_effective_date         => l_obj_date
                              );

                           --
                           IF g_dbg
                           THEN
                              op (l_proc, g_debug_log, 222);
                              op (l_proc || g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                  g_debug_log,
                                  222
                                 );
                              op (l_proc, g_debug_log, 222);
                           END IF;

                           --
                           l_check_elig               :=
                              ben_per_asg_elig.eligible
                                                 (g_qual_pop_tbl (l_qual_pop_index).person_id,
                                                  g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                                  g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                                  l_obj_date,
                                                  g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                                                  'Y' ---KMG -- Added to Allow CWK's
                                                 );
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              l_check_elig               := 'N';

                              IF g_dbg
                              THEN
                                 op (l_proc, g_debug_log, 333);
                              END IF;

                              IF g_dbg
                              THEN
                                 op (   l_proc
                                     || ' SKIPPED '
                                     || g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                     g_debug_log,
                                     333
                                    );
                              END IF;
                        END;

                        IF (l_check_elig = 'Y')
                        THEN
                           -- Create the objective
                           create_scorecard_objective
                              (p_effective_date              => l_effective_date,
                               p_scorecard_id                => l_scorecard_id,
                               p_business_group_id           => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                               p_person_id                   => g_qual_pop_tbl (l_qual_pop_index).person_id,
                               p_start_date                  => l_plan_rec.start_date,
                               p_end_date                    => l_plan_rec.end_date,
                               p_objective_name              => g_qual_obj_tbl (l_qual_obj_index).objective_name,
                               p_valid_from                  => g_qual_obj_tbl (l_qual_obj_index).valid_from,
                               p_valid_to                    => g_qual_obj_tbl (l_qual_obj_index).valid_to,
                               p_target_date                 => g_qual_obj_tbl (l_qual_obj_index).target_date,
                               p_copied_from_library_id      => g_qual_obj_tbl (l_qual_obj_index).objective_id,
                               p_next_review_date            => g_qual_obj_tbl (l_qual_obj_index).next_review_date,
                               p_group_code                  => g_qual_obj_tbl (l_qual_obj_index).group_code,
                               p_priority_code               => g_qual_obj_tbl (l_qual_obj_index).priority_code,
                               p_appraise_flag               => g_qual_obj_tbl (l_qual_obj_index).appraise_flag,
                               p_weighting_percent           => g_qual_obj_tbl (l_qual_obj_index).weighting_percent,
                               p_target_value                => g_qual_obj_tbl (l_qual_obj_index).target_value,
                               p_uom_code                    => g_qual_obj_tbl (l_qual_obj_index).uom_code,
                               p_measurement_style_code      => g_qual_obj_tbl (l_qual_obj_index).measurement_style_code,
                               p_measure_name                => g_qual_obj_tbl (l_qual_obj_index).measure_name,
                               p_measure_type_code           => g_qual_obj_tbl (l_qual_obj_index).measure_type_code,
                               p_measure_comments            => g_qual_obj_tbl (l_qual_obj_index).measure_comments,
                               p_details                     => g_qual_obj_tbl (l_qual_obj_index).details,
                               p_success_criteria            => g_qual_obj_tbl (l_qual_obj_index).success_criteria,
                               p_comments                    => g_qual_obj_tbl (l_qual_obj_index).comments
                              );
                        END IF;

                        --
                        l_qual_obj_index           := g_qual_obj_tbl.NEXT (l_qual_obj_index);
                     --
                     END LOOP;                                       -- l_qual_obj_index IS NOT NULL
                  END IF;                                    -- l_plan_rec.automatic_allocation_flag

                  --
                  -- Copy past objectives if the flag is set and previous plan id is available
                  --
                  IF (    l_plan_rec.copy_past_objectives_flag = 'Y'
                      AND l_plan_rec.previous_plan_id IS NOT NULL
                     )
                  THEN
                     --
                     copy_past_objectives
                        (p_effective_date         => l_effective_date,
                         p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                         p_person_id              => g_qual_pop_tbl (l_qual_pop_index).person_id,
                         p_scorecard_id           => l_scorecard_id,
                         p_start_date             => l_plan_rec.start_date,
                         p_end_date               => l_plan_rec.end_date,
                         p_target_date            => NULL,
                         p_assignemnt_id          => g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                         p_prev_plan_id           => l_plan_rec.previous_plan_id,
                         p_curr_plan_id           => l_plan_rec.plan_id
                        );
                  --
                  END IF;                                                 -- Copying past Objectives
               --

               --
               END IF;
            END IF;                                                            -- Elig Profile Check
         ELSIF (    l_plan_rec.status_code IN ('UPDATED', 'RESUBMITTED')
                AND g_curr_sc_pop_tbl.EXISTS (l_qual_pop_index)
               )
         THEN
            -- If objective setting flag is set
            IF (   (l_plan_rec.include_obj_setting_flag = 'Y')
                OR (l_plan_rec.include_appraisals_flag = 'Y')
               )
            THEN
               -- Update the scorecard for this assignment
               IF g_dbg
               THEN
                  op (l_proc, g_debug_log, 90);
               END IF;

               l_scorecard_id             := g_curr_sc_pop_tbl (l_qual_pop_index).scorecard_id;

               -- additional AND clause added to the IF condition, as we do not want to change the
               -- scorecard status unless status is PUBLISHED
               IF (    NVL (l_plan_rec.change_sc_status_flag, 'N') = 'Y'
                   AND g_curr_sc_pop_tbl (l_qual_pop_index).status_code = 'PUBLISHED'
                  )
               THEN
                  IF l_plan_rec.method_code = 'CAS'
                  THEN
                     --
                     IF    (    l_plan_rec.hierarchy_type_code = 'SUP'
                            AND l_plan_rec.supervisor_id =
                                                         g_qual_pop_tbl (l_qual_pop_index).person_id
                           )
                        OR (    l_plan_rec.hierarchy_type_code = 'SUP_ASG'
                            AND l_plan_rec.supervisor_assignment_id =
                                                     g_qual_pop_tbl (l_qual_pop_index).assignment_id
                           )
                        OR (    l_plan_rec.hierarchy_type_code IN ('POS')
                            AND l_plan_rec.top_position_id =
                                                       g_qual_pop_tbl (l_qual_pop_index).position_id
                           )
                        OR (    l_plan_rec.hierarchy_type_code = 'ORG'
                            AND is_supervisor_in_org (l_plan_rec.top_organization_id,
                                                      g_qual_pop_tbl (l_qual_pop_index).person_id
                                                     ) = 1
                           )
                     THEN
                        l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
                     ELSE
                        l_scorecard_status_code    := 'NOT_STARTED_WITH_MGR';
                     END IF;
                  ELSE
                     l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
                  END IF;

                  --
                  update_scorecard_for_person
                     (p_effective_date             => l_effective_date,
                      p_scorecard_id               => l_scorecard_id,
                      p_object_version_number      => g_curr_sc_pop_tbl (l_qual_pop_index).object_version_number,
                      p_scorecard_name             => l_plan_rec.plan_name,
                      p_start_date                 => l_plan_rec.start_date,
                      p_end_date                   => l_plan_rec.end_date,
                      p_status_code                => l_scorecard_status_code
                     );
               ELSE
                  update_scorecard_for_person
                     (p_effective_date             => l_effective_date,
                      p_scorecard_id               => l_scorecard_id,
                      p_object_version_number      => g_curr_sc_pop_tbl (l_qual_pop_index).object_version_number,
                      p_scorecard_name             => l_plan_rec.plan_name,
                      p_start_date                 => l_plan_rec.start_date,
                      p_end_date                   => l_plan_rec.end_date
                     );
               END IF;

               --
               IF g_dbg
               THEN
                  op (l_proc, g_debug_log, 100);
               END IF;

                    --
                    -- Populate existing objectives for this scorecard
               -- g_curr_sc_obj_tbl is populated with index as 'copied_from_library_id'
               --
               populate_curr_sc_objectives (l_scorecard_id);

               -- Loop through objectives and create the qualifying objectives for scorecard
               -- make sure objectives are not created if scorecard is not created
               IF (l_plan_rec.automatic_allocation_flag = 'Y' AND l_scorecard_id IS NOT NULL)
               THEN
                  l_qual_obj_index           := g_qual_obj_tbl.FIRST;

                  WHILE (l_qual_obj_index IS NOT NULL)
                  LOOP
                     -- Following is commented, and l_obj_date is being set to sysdate bug# 5211538
                     -- l_obj_date is being seto to sysdate in the declare block itself
                     /*
                     -- objective date should be later of plan start date on obgective valif_from date
                     l_obj_date := l_plan_rec.start_date;
                     IF (l_plan_rec.start_date < g_qual_obj_tbl(l_qual_obj_index).valid_from) THEN
                       l_obj_date := g_qual_obj_tbl(l_qual_obj_index).valid_from;
                     END IF;
                     */
                     --
                     -- Enclose the call to eligibility within a block, so that if for any
                     -- reason the eligibility engine errors, then process can still
                     -- continue by skipping the current person/assignemnt as not eligible
                     --
                     BEGIN
                        --
                        ben_env_object.init
                           (p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                            p_thread_id              => NULL,
                            p_chunk_size             => NULL,
                            p_threads                => NULL,
                            p_max_errors             => NULL,
                            p_benefit_action_id      => NULL,
                            p_effective_date         => l_obj_date
                           );

                        --
                        IF g_dbg
                        THEN
                           op (l_proc, g_debug_log, 222);
                           op (l_proc || g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                               g_debug_log,
                               222
                              );
                           op (l_proc, g_debug_log, 222);
                        END IF;

                        --
                        l_check_elig               :=
                           ben_per_asg_elig.eligible
                                                 (g_qual_pop_tbl (l_qual_pop_index).person_id,
                                                  g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                                  g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                                  l_obj_date,
                                                  g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                                                  'Y' ---KMG -- Added to Allow CWK's
                                                 );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_check_elig               := 'N';

                           IF g_dbg
                           THEN
                              op (l_proc, g_debug_log, 333);
                           END IF;

                           IF g_dbg
                           THEN
                              op (   l_proc
                                  || '-- SKIPPED --'
                                  || g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                  g_debug_log,
                                  333
                                 );
                           END IF;
                     END;

                     --
                     IF (l_check_elig = 'Y')
                     THEN
                        --
                        -- if it's newly qualified objective then create else update
                        --
                        IF (NOT g_curr_sc_obj_tbl.EXISTS
                                                      (g_qual_obj_tbl (l_qual_obj_index).objective_id
                                                      )
                           )
                        THEN
                           -- Create the objective
                           create_scorecard_objective
                              (p_effective_date              => l_effective_date,
                               p_scorecard_id                => l_scorecard_id,
                               p_business_group_id           => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                               p_person_id                   => g_qual_pop_tbl (l_qual_pop_index).person_id,
                               p_start_date                  => l_plan_rec.start_date,
                               p_end_date                    => l_plan_rec.end_date,
                               p_objective_name              => g_qual_obj_tbl (l_qual_obj_index).objective_name,
                               p_valid_from                  => g_qual_obj_tbl (l_qual_obj_index).valid_from,
                               p_valid_to                    => g_qual_obj_tbl (l_qual_obj_index).valid_to,
                               p_target_date                 => g_qual_obj_tbl (l_qual_obj_index).target_date,
                               p_copied_from_library_id      => g_qual_obj_tbl (l_qual_obj_index).objective_id,
                               p_next_review_date            => g_qual_obj_tbl (l_qual_obj_index).next_review_date,
                               p_group_code                  => g_qual_obj_tbl (l_qual_obj_index).group_code,
                               p_priority_code               => g_qual_obj_tbl (l_qual_obj_index).priority_code,
                               p_appraise_flag               => g_qual_obj_tbl (l_qual_obj_index).appraise_flag,
                               p_weighting_percent           => g_qual_obj_tbl (l_qual_obj_index).weighting_percent,
                               p_target_value                => g_qual_obj_tbl (l_qual_obj_index).target_value,
                               p_uom_code                    => g_qual_obj_tbl (l_qual_obj_index).uom_code,
                               p_measurement_style_code      => g_qual_obj_tbl (l_qual_obj_index).measurement_style_code,
                               p_measure_name                => g_qual_obj_tbl (l_qual_obj_index).measure_name,
                               p_measure_type_code           => g_qual_obj_tbl (l_qual_obj_index).measure_type_code,
                               p_measure_comments            => g_qual_obj_tbl (l_qual_obj_index).measure_comments,
                               p_details                     => g_qual_obj_tbl (l_qual_obj_index).details,
                               p_success_criteria            => g_qual_obj_tbl (l_qual_obj_index).success_criteria,
                               p_comments                    => g_qual_obj_tbl (l_qual_obj_index).comments
                              );
                        --
                        ELSE
                           IF (NVL (l_plan_rec.update_library_objectives, 'N') = 'Y')
                           THEN                                                  -- 8740021 bug fix
                              -- Update the objective
                              update_scorecard_objective
                                 (p_effective_date              => l_effective_date,
                                  p_objective_id                => g_curr_sc_obj_tbl
                                                                                   (l_qual_obj_index).objective_id,
                                  p_object_version_number       => g_curr_sc_obj_tbl
                                                                                   (l_qual_obj_index).object_version_number,
                                  p_scorecard_id                => l_scorecard_id,
                                  p_start_date                  => l_plan_rec.start_date,
                                  p_end_date                    => l_plan_rec.end_date,
                                  p_objective_name              => g_qual_obj_tbl (l_qual_obj_index).objective_name,
                                  p_valid_from                  => g_qual_obj_tbl (l_qual_obj_index).valid_from,
                                  p_valid_to                    => g_qual_obj_tbl (l_qual_obj_index).valid_to,
                                  p_target_date                 => g_qual_obj_tbl (l_qual_obj_index).target_date,
                                  p_copied_from_library_id      => g_qual_obj_tbl (l_qual_obj_index).objective_id,
                                  p_next_review_date            => g_qual_obj_tbl (l_qual_obj_index).next_review_date,
                                  p_group_code                  => g_qual_obj_tbl (l_qual_obj_index).group_code,
                                  p_priority_code               => g_qual_obj_tbl (l_qual_obj_index).priority_code,
                                  p_appraise_flag               => g_qual_obj_tbl (l_qual_obj_index).appraise_flag,
                                  p_weighting_percent           => g_qual_obj_tbl (l_qual_obj_index).weighting_percent,
                                  p_target_value                => g_qual_obj_tbl (l_qual_obj_index).target_value,
                                  p_uom_code                    => g_qual_obj_tbl (l_qual_obj_index).uom_code,
                                  p_measurement_style_code      => g_qual_obj_tbl (l_qual_obj_index).measurement_style_code,
                                  p_measure_name                => g_qual_obj_tbl (l_qual_obj_index).measure_name,
                                  p_measure_type_code           => g_qual_obj_tbl (l_qual_obj_index).measure_type_code,
                                  p_measure_comments            => g_qual_obj_tbl (l_qual_obj_index).measure_comments,
                                  p_details                     => g_qual_obj_tbl (l_qual_obj_index).details,
                                  p_success_criteria            => g_qual_obj_tbl (l_qual_obj_index).success_criteria,
                                  p_comments                    => g_qual_obj_tbl (l_qual_obj_index).comments
                                 );
                           END IF;                                                -- 8740021 bug fix
                        END IF;
                     --
                     ELSE
                        --
                             --  End date objectives that qulify but are not eligible anymore and exists in current objectives
                             --
                        IF g_dbg
                        THEN
                           op (l_proc, g_debug_log, 110);
                        END IF;

                        --
                        IF (g_curr_sc_obj_tbl.EXISTS (g_qual_obj_tbl (l_qual_obj_index).objective_id)
                           )
                        THEN
                           update_scorecard_objective
                              (p_effective_date             => l_effective_date,
                               p_start_date                 => l_plan_rec.start_date,
                               p_objective_id               => g_curr_sc_obj_tbl (l_qual_obj_index).objective_id,
                               p_object_version_number      => g_curr_sc_obj_tbl (l_qual_obj_index).object_version_number,
                               p_end_date                   => l_effective_date
                              );
                        END IF;
                     --
                     END IF;                                                        --Eligible check

                     --
                     l_qual_obj_index           := g_qual_obj_tbl.NEXT (l_qual_obj_index);
                  --
                  END LOOP;
               --
               END IF;                                                   --automatic_allocation_flag
                 --
                 -- Copy past objectives if the flag is set and previous plan id is available
                 --
                --  7707697 Bug fix, Copy Past Objectives method need not be called during
                 --  scorecard update, hence commenting it
              /*   IF (l_plan_rec.copy_past_objectives_flag = 'Y' AND l_plan_rec.previous_plan_id is not NULL)
                 THEN
                 --
                   copy_past_objectives
                     (p_effective_date            => l_effective_date
                     ,p_business_group_id         => g_qual_pop_tbl(l_qual_pop_index).business_group_id
                     ,p_person_id                 => g_qual_pop_tbl(l_qual_pop_index).person_id
                     ,p_scorecard_id              => l_scorecard_id
                     ,p_start_date                => l_plan_rec.start_date
                     ,p_end_date                  => l_plan_rec.end_date
                     ,p_target_date               => null
                     ,p_assignemnt_id             => g_qual_pop_tbl(l_qual_pop_index).assignment_id
                     ,p_prev_plan_id              => l_plan_rec.previous_plan_id
                     ,p_curr_plan_id              => l_plan_rec.plan_id);
                   --
                 END IF;  */
                 --
            -- End date objectives that exists in current scorecard objectives but does not qualify anymore
            --
               /* Commenting as this code is rdundant.. for fixing bug#7560950
            l_curr_sc_obj_index := g_curr_sc_obj_tbl.FIRST;
                 WHILE(l_curr_sc_obj_index IS NOT NULL)
                 LOOP
              IF (NOT g_qual_obj_tbl.EXISTS(l_curr_sc_obj_index)) THEN
                     --
                     IF g_dbg THEN op(l_proc, g_DEBUG_LOG, 120); END IF;
                     --
                     update_scorecard_objective(
                          p_effective_date        =>  l_effective_date
                         ,p_start_date             => l_plan_rec.start_date
                         ,p_objective_id          =>  g_curr_sc_obj_tbl(l_curr_sc_obj_index).objective_id
                         ,p_object_version_number =>  g_curr_sc_obj_tbl(l_curr_sc_obj_index).object_version_number
                         ,p_end_date              =>  l_effective_date);
              END IF;
                   --
              l_curr_sc_obj_index := g_curr_sc_obj_tbl.NEXT(l_curr_sc_obj_index);
              --
                 END LOOP;
              --commented upto here for bug#7560950*/
            END IF;
            --
           /* ELSIF (l_plan_rec.status_code = 'PUBLISHED') THEN
         -- If objective setting flag is set
         IF (l_plan_rec.include_obj_setting_flag = 'Y') THEN

           IF g_dbg THEN op(l_proc, g_DEBUG_LOG, 130); END IF;
           -- Loop though and delete the objectives for scorecard
                FOR obj_rec IN csr_sc_objectives(g_curr_sc_pop_tbl(l_qual_pop_index).scorecard_id)
                LOOP
                  delete_scorecard_objective(p_objective_id          =>  obj_rec.objective_id
                                            ,p_object_version_number =>  obj_rec.object_version_number);
                END LOOP;

           -- Delete the scorecard
                delete_scorecard_for_person(g_curr_sc_pop_tbl(l_qual_pop_index).scorecard_id
                                           ,g_curr_sc_pop_tbl(l_qual_pop_index).object_version_number);
              END IF;
              --
              IF (l_plan_rec.include_appraisals_flag = 'Y') THEN
                FOR plan_appraisals IN csr_plan_appraisals(p_plan_id)
                LOOP
                  delete_appraisal_for_person(plan_appraisals.appraisal_id,plan_appraisals.object_version_number);
                END LOOP;
              END IF;*/
            --
         END IF;

         --
         --  Get the next index value
         --
         l_qual_pop_index           := g_qual_pop_tbl.NEXT (l_qual_pop_index);
         -- WPM  Logging changes
          IF hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).processing_status = 'P'
          THEN
                hr_wpm_mass_apr_push.g_wpm_person_actions (hr_wpm_mass_apr_push.log_records_index).processing_status := 'SUCCESS' ;  -- Success
         END IF;
      --
      END LOOP;

--
--    ===========================================================================================
--- DELETE the non qualifying scorecards and the appraisals( for terminated employees) changes for 6460457
      l_curr_sc_pop_index        := g_curr_sc_pop_tbl.FIRST;

      WHILE (l_curr_sc_pop_index IS NOT NULL)
      LOOP
         BEGIN
            IF (    l_plan_rec.status_code IN ('UPDATED', 'RESUBMITTED')
                AND NOT g_qual_pop_tbl.EXISTS (l_curr_sc_pop_index)
               )
            THEN
               -- If objective setting flag is set

               --IF (l_plan_rec.include_obj_setting_flag = 'Y') THEN
               IF g_dbg
               THEN
                  op (l_proc, g_debug_log, 130);
               END IF;

     -- Loop though and delete the objectives for scorecard
-- 7321947 will not delete any record for non-qualifying scorecards.
        /*  FOR obj_rec IN csr_sc_objectives(g_curr_sc_pop_tbl(l_curr_sc_pop_index).scorecard_id)
          LOOP

            delete_scorecard_objective(p_objective_id          =>  obj_rec.objective_id
                                      ,p_object_version_number =>  obj_rec.object_version_number);
          END LOOP;*/
       -- END IF;
              --- delete the appraisals for the person
               IF (l_plan_rec.include_appraisals_flag = 'Y')
               THEN
                  --  FOR plan_appraisals IN csr_plan_appraisals(p_plan_id)
                  OPEN csr_find_appr_for_scorecard
                                               (p_plan_id,
                                                g_curr_sc_pop_tbl (l_curr_sc_pop_index).scorecard_id
                                               );

                  LOOP
                     hr_utility.set_location ('Before transfer out _for_person', 107);

                     FETCH csr_find_appr_for_scorecard
                      INTO l_appr_id,
                           l_appr_ovn,
                           l_appr_sys_status;

                     EXIT WHEN csr_find_appr_for_scorecard%NOTFOUND;

                     IF l_appr_sys_status <> 'COMPLETED'
                     THEN
                        UPDATE per_appraisals
                           SET appraisal_system_status = 'TRANSFER_OUT'
                         WHERE appraisal_id = l_appr_id;

-- revoke the participant statuses and close them.NOt deleting them if feedback is already provided.
                        FOR i IN csr_get_appr_part (l_appr_id)
                        LOOP
                           UPDATE per_participants
                              SET participation_status = 'CLOSED'
                            WHERE participant_id = i.participant_id;
                        END LOOP;
-- we are doing a direct update as update API will not work for terminated and traansfer employees
-- update it to transfer out so as to not show the details anywhere
                     END IF;

                     hr_utility.set_location
                                       (   'After transfer out appraisal_for_person appraisal_id: '
                                        || l_appr_id,
                                        107
                                       );
                  END LOOP;

                  CLOSE csr_find_appr_for_scorecard;
               END IF;

               -- Delete the scorecard

               /*  delete_scorecard_for_person(g_curr_sc_pop_tbl(l_curr_sc_pop_index).scorecard_id
                                            ,g_curr_sc_pop_tbl(l_curr_sc_pop_index).object_version_number);    */
               hr_personal_scorecard_api.update_scorecard
                  (p_effective_date              => TRUNC (SYSDATE),
                   p_scorecard_id                => g_curr_sc_pop_tbl (l_curr_sc_pop_index).scorecard_id,
                   p_object_version_number       => g_curr_sc_pop_tbl (l_curr_sc_pop_index).object_version_number,
                   p_duplicate_name_warning      => l_dummy,
                   p_status_code                 => 'TRANSFER_OUT'
                  );
            --

            --
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN

         -- WPM  Logging changes
         /*
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TYPE := 'E';
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_NUMBER := 'OTHER';
         hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).MESSAGE_TEXT := SQLERRM;
      */

               IF g_dbg
               THEN
                  op ('Leaving:' || l_proc, g_regular_log, 90);
               END IF;

               --
               fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
               g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
               g_retcode                  := warning;
               g_errbuf                   := g_cp_error_txt;
               g_num_errors               := g_num_errors + 1;

               IF g_dbg
               THEN
                  op (g_error_txt, g_regular_log);
               END IF;

               IF g_dbg
               THEN
                  op (SQLERRM, g_regular_log);
               END IF;

               --
               -- If the max number of errors has been exceeded, raise the error and
               -- terminate processing of this plan.
               --
               IF g_num_errors > g_max_errors
               THEN
                  fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
                  g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
                  g_retcode                  := error;
                  g_errbuf                   := g_error_txt;
                  RAISE;
               END IF;
         END;

         --------- iterate the loop
         l_curr_sc_pop_index        := g_curr_sc_pop_tbl.NEXT (l_curr_sc_pop_index);
      END LOOP;

---  DELETE logic ends( replaced by 7321947 changes)
--============================================================================================
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 140);
      END IF;

          --
          -- If the plan is republished, End date scorecards, objectives and
          -- appraisals for existing population that does not qualify anymore
          --
       /* Bug# 6648036 changes Begin Commenting the if Condition
       IF (l_plan_rec.status_code in ('UPDATED','RESUBMITTED') AND l_plan_rec.include_obj_setting_flag = 'Y') THEN
            --
            l_curr_sc_pop_index := g_curr_sc_pop_tbl.FIRST;
            WHILE (l_curr_sc_pop_index IS NOT NULL)
            LOOP
              IF (NOT g_qual_pop_tbl.EXISTS(l_curr_sc_pop_index)) THEN
                --
           IF g_dbg THEN op(l_proc, g_DEBUG_LOG, 150); END IF;
                --
           -- Loop though objectives for scorecards
                FOR obj_rec IN csr_sc_objectives(g_curr_sc_pop_tbl(l_curr_sc_pop_index).scorecard_id)
           LOOP
                  update_scorecard_objective(
                       p_effective_date        =>  l_effective_date
                      ,p_start_date             => l_plan_rec.start_date
                      ,p_objective_id          =>  obj_rec.objective_id
                      ,p_object_version_number =>  obj_rec.object_version_number
                      ,p_end_date              =>  l_effective_date);
                END LOOP;

                --
           IF g_dbg THEN op(l_proc, g_DEBUG_LOG, 160); END IF;
           --
                  update_scorecard_for_person(
                       p_effective_date        =>  l_effective_date
                      ,p_start_date            =>  l_plan_rec.start_date --Added for 5725110
                      ,p_scorecard_id          =>  g_curr_sc_pop_tbl(l_curr_sc_pop_index).scorecard_id
                      ,p_object_version_number =>  g_curr_sc_pop_tbl(l_curr_sc_pop_index).object_version_number
                      ,p_end_date              =>  l_effective_date);
              END IF;
            --
            l_curr_sc_pop_index := g_curr_sc_pop_tbl.NEXT(l_curr_sc_pop_index);
            --
            END LOOP;
          END IF;

      Bug# 6648036 Changes End */

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 170);
      END IF;

      --
      -- Update the plan status
      --
      l_object_version_number    := l_plan_rec.object_version_number;

      IF (p_reverse_mode = 'Y')
      THEN
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 180);
         END IF;

         l_status_code              := 'DRAFT';
      ELSE
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 190);
         END IF;

         l_status_code              := 'PUBLISHED';
      END IF;

      --
      per_pmp_upd.upd (p_plan_id                     => l_plan_rec.plan_id,
                       p_effective_date              => l_effective_date,
                       p_object_version_number       => l_object_version_number,
                       p_status_code                 => l_status_code,
                       p_change_sc_status_flag       => NULL,
                       p_duplicate_name_warning      => l_dummy,
                       p_no_life_events_warning      => l_dummy
                      );
      -- Return the new object version number
      p_object_version_number    := l_object_version_number;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 200);
      END IF;

      --
      -- Submit the workflow process for notifying plan population
      -- Commented out the following line. No matter what this flag,
      -- notifications to be sent. Bug# 5225196
      --IF (l_plan_rec.include_obj_setting_flag = 'Y' AND
      IF (l_plan_rec.notify_population_flag = 'Y')
      THEN
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 210);
         END IF;

         --
         start_process (p_plan_rec            => l_plan_rec,
                        p_effective_date      => l_effective_date,
                        p_reverse_mode        => p_reverse_mode,
                        p_item_type           => p_item_type,
                        p_wf_process          => p_wf_process
                       );
      END IF;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 220);
      END IF;

      --
      -- Always Send notification to administrator that plan has been published.
      --
      send_fyi_admin (p_plan_rec        => l_plan_rec,
                      p_status          => 'PUBLISHED',
                      p_request_id      => fnd_global.conc_request_id
                     );

      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 210);
      END IF;

      --
      COMMIT;

      IF (   l_plan_rec.status_code IN ('DRAFT', 'SUBMITTED')
          OR (    l_plan_rec.status_code IN ('UPDATED', 'RESUBMITTED')
              AND NOT g_curr_sc_pop_tbl.EXISTS (l_qual_pop_index)
             )
         )
      THEN
         --
         -- Create Appraisals if flag is set
         --
         IF (l_plan_rec.include_appraisals_flag = 'Y')
         THEN
            --
            l_plan_aprsl_pds_index     := g_plan_aprsl_pds_tbl.FIRST;

            WHILE (l_plan_aprsl_pds_index IS NOT NULL)
            LOOP
               --
               IF (g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).auto_conc_process = 'Y')
               THEN
                  l_process_date             :=
                       g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).task_start_date
                     - NVL (g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).days_before_task_st_dt, 0);
                  l_process_date_char        :=
                           TO_CHAR (l_process_date, fnd_conc_date.get_date_format (TRUNC (SYSDATE)));

                  --
                  IF g_dbg
                  THEN
                     op ('Eff_date is ' || p_effective_date, g_debug_log, 90);
                     op ('l_process_date is ' || l_process_date, g_debug_log, 90);
                     op ('l_process_date_CHAR is ' || l_process_date_char, g_debug_log, 90);
                  END IF;

                             --
                             -- Do not call appraisal_push, if process_date < sysdate.
                             --
                  -- changes for cancelling pending requests
                  BEGIN
                     FOR conc IN
                        previous_concurrent_requests
                                  (p_plan_id,
                                   g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).appraisal_period_id
                                  )
                     LOOP
                        l_conc_request_id          := conc.request_id;
                        l_ret                      :=
                                     fnd_concurrent.cancel_request (conc.request_id, l_message_req);

                        IF l_ret
                        THEN
                           l_submit_new_req           := TRUE;
                        ELSE
                           RAISE e;
                        END IF;
                     END LOOP;
                  EXCEPTION
                     WHEN e
                     THEN
                        l_submit_new_req           := FALSE;
                  END;

                  IF NOT l_submit_new_req
                  THEN
                     IF g_dbg
                     THEN
                        op ('Unable to cancel request ' || l_conc_request_id, g_regular_log, 10);
                     END IF;
                  ELSE
                     IF g_dbg
                     THEN
                        op ('Able to  cancel all pending requests ', g_regular_log, 10);
                     END IF;
                  END IF;

                  IF l_process_date >= TRUNC (SYSDATE) AND l_submit_new_req
                  THEN
                     hr_wpm_mass_apr_push.submit_appraisal_cp
                        (p_effective_date           => l_process_date,
                         p_start_date               => l_process_date_char,
                         p_plan_id                  => p_plan_id,
                         p_appraisal_period_id      => g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).appraisal_period_id,
                         p_log_output               => p_log_output
                        );
                  END IF;                                     -- run only if process date >= sysdate
               END IF;

               --
               l_plan_aprsl_pds_index     := g_plan_aprsl_pds_tbl.NEXT (l_plan_aprsl_pds_index);
            --
            END LOOP;

            -- populate the hierarchy for appraisal summary
            per_wpm_summary_pkg.populate_plan_hierarchy (p_plan_id             => p_plan_id,
                                                         p_effective_date      => TRUNC (SYSDATE)
                                                        );
         --
         END IF;                                                            --include appraisal flag
      --
      END IF;

      --
      -- Error logging
      --
      l_message_count            := per_accrual_message_pkg.count_messages;

      FOR j IN 1 .. l_message_count
      LOOP
         l_message                  := per_accrual_message_pkg.GET_MESSAGE (j);

         IF g_dbg
         THEN
            op (l_message, g_regular_log);
         END IF;
      END LOOP;

      --
      IF g_dbg
      THEN
         op ('Max Errors Allowed is: ' || TO_CHAR (g_max_errors), g_regular_log, 988);
         op ('Errors encountered is: ' || TO_CHAR (g_num_errors), g_regular_log, 989);
         op ('Leaving: ' || l_proc, g_regular_log, 990);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 90);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := error;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op ('Max Errors Allowed is: ' || TO_CHAR (g_max_errors), g_regular_log);
            op ('Errors encountered is: ' || TO_CHAR (g_num_errors), g_regular_log);
            op (g_error_txt, g_regular_log);
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- Send notification to administrator that plan publish errored
         --
         send_fyi_admin (p_plan_rec        => l_plan_rec,
                         p_status          => 'ERROR',
                         p_request_id      => fnd_global.conc_request_id
                        );

         IF g_dbg
         THEN
            op ('Leaving:' || l_proc, g_regular_log, 91);
         END IF;

         --
         RAISE;
   END publish_plan;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< send_fyi_ntf >------------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE send_fyi_ntf (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      prole                wf_users.NAME%TYPE;                                      -- Fix 3210283.
      l_role_name          wf_roles.NAME%TYPE;
      expand_role          VARCHAR2 (1);
      l_msg                VARCHAR2 (30);
      -- Start changes for bug#5903006
      l_obj_setting_flag   VARCHAR2 (30);
  --end changes for bug#5903006
--
   BEGIN
      IF (funcmode <> wf_engine.eng_run)
      THEN
         resultout                  := wf_engine.eng_null;
         RETURN;
      END IF;

      l_role_name                :=
         wf_engine.getitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'WPM_PLAN_MEMBER'
                                   );
      l_msg                      :=
                    UPPER (wf_engine.getactivityattrtext (itemtype, itemkey, actid, 'MESSAGE_NAME'));
      -- Start Changes for bug#5903006
      l_obj_setting_flag         :=
         wf_engine.getitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'HR_WPM_OBJ_SETTING_FLAG'
                                   );

      IF NVL (l_obj_setting_flag, 'N') = 'N'
      THEN
         IF l_msg = 'WPM_PLAN_PUB_ALL_POP_MSG'
         THEN
            l_msg                      := 'WPM_PLAN_PUB_ALL_NO_OBJ_MSG';
         ELSIF l_msg = 'WPM_PLAN_PUB_NON_TOP_POP_MSG'
         THEN
            l_msg                      := 'WPM_PLAN_PUB_NON_TOP_NOOBJ_MSG';
         ELSIF l_msg = 'WPM_PLAN_PUB_TOP_POP_MSG'
         THEN
            l_msg                      := 'WPM_PLAN_PUB_TOP_NO_OBJ_MSG';
         END IF;
      END IF;

      -- End Changes for bug#5903006
      expand_role                := 'N';

      IF l_role_name IS NULL
      THEN
         wf_core.token ('TYPE', itemtype);
         wf_core.token ('ACTID', TO_CHAR (actid));
         wf_core.RAISE ('WFENG_NOTIFICATION_PERFORMER');
      END IF;

      --
      wf_engine_util.notification_send (itemtype,
                                        itemkey,
                                        actid,
                                        l_msg,
                                        'HRWPM',
                                        l_role_name,
                                        expand_role,
                                        resultout
                                       );
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END send_fyi_ntf;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< send_fyi_ntf_admin >------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE send_fyi_ntf_admin (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      prole                wf_users.NAME%TYPE;
      l_role_name          wf_roles.NAME%TYPE;
      l_role_displayname   wf_roles.display_name%TYPE;
      expand_role          VARCHAR2 (1);
      l_msg                VARCHAR2 (30);
      l_plan_id            NUMBER;

      CURSOR csr_get_admin
      IS
         SELECT administrator_person_id,
                supervisor_id
           FROM per_perf_mgmt_plans
          WHERE plan_id = l_plan_id;

      l_admin_person_id    NUMBER;
      l_supervisor_id      NUMBER;
--
   BEGIN
      IF (funcmode <> wf_engine.eng_run)
      THEN
         resultout                  := wf_engine.eng_null;
         RETURN;
      END IF;

      --
      -- get plan id
      --
      l_plan_id                  :=
         wf_engine.getitemattrnumber (itemtype      => itemtype,
                                      itemkey       => itemkey,
                                      aname         => 'WPM_PLAN_ID'
                                     );

      --
      -- get administrator person id from plan
      --
      OPEN csr_get_admin;

      FETCH csr_get_admin
       INTO l_admin_person_id,
            l_supervisor_id;

      CLOSE csr_get_admin;

      --
      -- Continue only if supervisor id is different from admin person id
      --
      IF l_admin_person_id <> NVL (l_supervisor_id, -1)
      THEN
         -- Get the Role for the Owner
         wf_directory.getrolename (p_orig_system         => 'PER',
                                   p_orig_system_id      => l_admin_person_id,
                                   p_name                => l_role_name,
                                   p_display_name        => l_role_displayname
                                  );
/*
  l_role_name :=wf_engine.GetItemAttrText(
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'WPM_PLAN_MEMBER');
  */
         l_msg                      :=
                    UPPER (wf_engine.getactivityattrtext (itemtype, itemkey, actid, 'MESSAGE_NAME'));
         expand_role                := 'N';

         IF l_role_name IS NULL
         THEN
            wf_core.token ('TYPE', itemtype);
            wf_core.token ('ACTID', TO_CHAR (actid));
            wf_core.RAISE ('WFENG_NOTIFICATION_PERFORMER');
         END IF;

         --
         wf_engine_util.notification_send (itemtype,
                                           itemkey,
                                           actid,
                                           l_msg,
                                           'HRWPM',
                                           l_role_name,
                                           expand_role,
                                           resultout
                                          );
      END IF;                                                           --l_admin <> l_supervisor_id
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END send_fyi_ntf_admin;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< send_fyi_admin >--------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE send_fyi_admin (
      p_plan_rec     IN   per_perf_mgmt_plans%ROWTYPE,
      p_status       IN   VARCHAR2,
      p_request_id   IN   NUMBER
   )
   IS
      l_to_role_name            wf_roles.NAME%TYPE;
      l_to_role_displayname     wf_roles.display_name%TYPE;
      l_from_role_name          wf_roles.NAME%TYPE;
      l_from_role_displayname   wf_roles.display_name%TYPE;
      expand_role               VARCHAR2 (1);
      l_msg                     VARCHAR2 (30);
      l_notification_id         NUMBER;
      from_role_not_exists      EXCEPTION;
      to_role_not_exists        EXCEPTION;
      l_subject                 VARCHAR2 (200)               DEFAULT NULL;
      l_proc                    VARCHAR2 (72)                := g_package || 'send_fyi_admin';
--
   BEGIN
      IF g_dbg
      THEN
         op (l_proc, g_regular_log, 10);
      END IF;

      --

      -- Get the Role for the Owner
      wf_directory.getrolename (p_orig_system         => 'PER',
                                p_orig_system_id      => p_plan_rec.administrator_person_id,
                                p_name                => l_to_role_name,
                                p_display_name        => l_to_role_displayname
                               );

      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 20);
      END IF;

      --
      IF l_to_role_name IS NULL
      THEN
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 25);
         END IF;

         RAISE to_role_not_exists;
      END IF;

      /* Owner is always administrator, we don;t need to check for the from role
        -- ---------------------------------
        -- Get the Role for the Owner
        -- ---------------------------------
        --
        wf_directory.getRoleName
          (p_orig_system    => 'FND_USR'
          ,p_orig_system_id => fnd_global.user_id
          ,p_name           => l_from_role_name
          ,p_display_name   => l_from_role_displayname);
          --
        IF g_dbg THEN op(l_proc, g_DEBUG_LOG, 30); END IF;
        if l_from_role_name is null then
          IF g_dbg THEN op(l_proc, g_DEBUG_LOG, 45); END IF;
          raise from_role_not_exists;
        end if;
      */
      expand_role                := 'N';

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 50);
      END IF;

      IF p_status = 'PUBLISHED'
      THEN
         l_notification_id          :=
            wf_notification.send (ROLE              => l_to_role_name,
                                  msg_type          => 'HRWPM',
                                  msg_name          => 'WPM_PLAN_PUB_ADMIN_MSG',
                                  callback          => NULL,
                                  CONTEXT           => NULL,
                                  send_comment      => NULL,
                                  priority          => 50
                                 );
         wf_notification.setattrtext (l_notification_id, 'PUB_PLAN_NAME', p_plan_rec.plan_name);
         wf_notification.setattrnumber (l_notification_id, 'PUB_REQ_ID', p_request_id);
      ELSIF p_status = 'ERROR'
      THEN
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 51);
         END IF;

         l_notification_id          :=
            wf_notification.send (ROLE              => l_to_role_name,
                                  msg_type          => 'HRWPM',
                                  msg_name          => 'WPM_PLANPUB_ERROR_ADMIN_MSG',
                                  callback          => NULL,
                                  CONTEXT           => NULL,
                                  send_comment      => NULL,
                                  priority          => 50
                                 );
         wf_notification.setattrtext (l_notification_id, 'FAILED_PLAN_NAME', p_plan_rec.plan_name);
         wf_notification.setattrnumber (l_notification_id, 'FAILED_REQ_ID', p_request_id);

         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 52);
         END IF;
      ELSIF p_status = 'SUBMITTED'
      THEN
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 52);
         END IF;

         l_notification_id          :=
            wf_notification.send (ROLE              => l_to_role_name,
                                  msg_type          => 'HRWPM',
                                  msg_name          => 'WPM_PLAN_SUBMIT_ADMIN_MSG',
                                  callback          => NULL,
                                  CONTEXT           => NULL,
                                  send_comment      => NULL,
                                  priority          => 50
                                 );
         wf_notification.setattrtext (l_notification_id, 'SUBMIT_PLAN_NAME', p_plan_rec.plan_name);
         wf_notification.setattrnumber (l_notification_id, 'SUBMIT_REQ_ID', p_request_id);
      ELSE
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 53);
         END IF;

         NULL;
      END IF;

      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 60);
      END IF;

      wf_notification.setattrtext (l_notification_id, '#FROM_ROLE', l_to_role_name);
      wf_notification.setattrtext (l_notification_id, 'WPM_PLAN', p_plan_rec.plan_name);
      wf_notification.setattrtext (l_notification_id, 'PLAN_START_DATE', p_plan_rec.start_date);
      wf_notification.setattrtext (l_notification_id, 'PLAN_END_DATE', p_plan_rec.end_date);
      wf_notification.setattrnumber (l_notification_id, 'CONCREQID', p_request_id);

      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 70);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op (l_proc, g_regular_log, 100);
         END IF;

         RAISE;
   END send_fyi_admin;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_past_objectives >---------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE copy_past_objectives (
      p_effective_date      IN   DATE,
      p_business_group_id   IN   NUMBER,
      p_person_id           IN   NUMBER,
      p_scorecard_id        IN   NUMBER,
      p_start_date          IN   DATE,
      p_end_date            IN   DATE,
      p_target_date         IN   DATE DEFAULT NULL,
      p_assignemnt_id       IN   NUMBER,
      p_prev_plan_id        IN   NUMBER,
      p_curr_plan_id        IN   NUMBER
   )
   IS
      --
      -- Declare local variables
      --
      l_proc                           VARCHAR2 (72) := g_package || 'copy_past_objectives';
      l_objective_id                   NUMBER;
      l_object_version_number          NUMBER;
      l_duplicate_name_warning         BOOLEAN       := FALSE;
      l_comb_weight_over_100_warning   BOOLEAN       := FALSE;
      l_weighting_appraisal_warning    BOOLEAN       := FALSE;
      l_pc_v_act_mismatch_warning      BOOLEAN       := FALSE;
      l_quant_met_not_pc_warning       BOOLEAN       := FALSE;
      l_qual_met_not_pc_warning        BOOLEAN       := FALSE;
      --
      l_start_date                     DATE;
      l_target_date                    DATE;
      l_next_review_date               DATE;

      --
      CURSOR past_obj
      IS
         SELECT obj.*
           FROM per_objectives obj, per_personal_scorecards psc
          WHERE psc.plan_id = p_prev_plan_id
            AND psc.assignment_id = p_assignemnt_id
            AND psc.scorecard_id = obj.scorecard_id
            AND obj.achievement_date IS NULL
            AND obj.appraisal_id IS NULL
            AND NOT EXISTS (
                   SELECT 'X'
                     FROM per_personal_scorecards psc1, per_objectives pobj1
                    WHERE psc1.plan_id = p_curr_plan_id
                      AND psc1.assignment_id = psc.assignment_id
                      AND psc1.scorecard_id = pobj1.scorecard_id
                      AND pobj1.copied_from_objective_id = obj.objective_id);
   --
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      --
      FOR pobj IN past_obj
      LOOP
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 20);
         END IF;

         --
         BEGIN
            l_objective_id             := NULL;
            l_object_version_number    := NULL;
            l_duplicate_name_warning   := FALSE;
            l_comb_weight_over_100_warning := FALSE;
            l_weighting_appraisal_warning := FALSE;
            l_pc_v_act_mismatch_warning := FALSE;
            l_quant_met_not_pc_warning := FALSE;
            l_qual_met_not_pc_warning  := FALSE;

             --
             -- Derive objective target date
             --
             --    8670717  bug fix changes
            /* IF (p_target_date IS NULL OR p_target_date > p_end_date OR p_target_date < p_start_date
                )
             THEN
                l_target_date              := p_end_date;
             ELSE
                l_target_date              := p_target_date;
             END IF;    */
            IF p_target_date IS NULL
            THEN
               l_target_date              := pobj.target_date;
            ELSE
               l_target_date              := p_target_date;
            END IF;

            IF (l_target_date IS NULL OR l_target_date > p_end_date OR l_target_date < p_start_date
               )
            THEN
               l_target_date              := p_end_date;
            -- ELSE -- l_target_date := p_target_date;
            END IF;

            --
            --
            IF (   pobj.next_review_date IS NULL
                OR pobj.next_review_date < p_start_date
                OR pobj.next_review_date > p_end_date
               )
            THEN
               l_next_review_date         := NULL;
            ELSE
               l_next_review_date         := pobj.next_review_date;
            END IF;

            --
            IF g_dbg
            THEN
               op (l_proc, g_debug_log, 40);
            END IF;

            --
            -- Call create_objective
            --
            hr_objectives_api.create_objective
                                    (p_effective_date                   => p_effective_date,
                                     p_business_group_id                => p_business_group_id,
                                     p_owning_person_id                 => pobj.owning_person_id,
                                     p_scorecard_id                     => p_scorecard_id,
                                     p_start_date                       => p_start_date,
                                     p_appraise_flag                    => pobj.appraise_flag,
                                     p_name                             => pobj.NAME,
                                     p_target_date                      => l_target_date,
                                     p_copied_from_objective_id         => pobj.objective_id,
                                     p_complete_percent                 => pobj.complete_percent,
                                     p_next_review_date                 => l_next_review_date,
                                     p_group_code                       => pobj.group_code,
                                     p_priority_code                    => pobj.priority_code,
                                     p_weighting_percent                => pobj.weighting_percent,
                                     p_target_value                     => pobj.target_value,
                                     p_uom_code                         => pobj.uom_code,
                                     p_measurement_style_code           => pobj.measurement_style_code,
                                     p_measure_name                     => pobj.measure_name,
                                     p_measure_type_code                => pobj.measure_type_code,
                                     p_measure_comments                 => pobj.measure_comments,
                                     p_detail                           => pobj.detail,
                                     p_comments                         => pobj.comments,
                                     p_success_criteria                 => pobj.success_criteria,
                                     p_objective_id                     => l_objective_id,
                                     p_object_version_number            => l_object_version_number,
                                     p_weighting_appraisal_warning      => l_weighting_appraisal_warning,
                                     p_weighting_over_100_warning       => l_comb_weight_over_100_warning,
                                    --,p_duplicate_name_warning         =>  l_duplicate_name_warning
                                    --,p_comb_weight_over_100_warning   =>  l_comb_weight_over_100_warning
                                    --,p_pc_v_act_mismatch_warning      =>  l_pc_v_act_mismatch_warning
                                    --,p_quant_met_not_pc_warning       =>  l_quant_met_not_pc_warning
                                    --,p_qual_met_not_pc_warning        =>  l_qual_met_not_pc_warning

				    --9450977
					p_attribute1                  => pobj.attribute1,
					p_attribute2                  => pobj.attribute2,
					p_attribute3                  => pobj.attribute3,
					p_attribute4                  => pobj.attribute4,
					p_attribute5                  => pobj.attribute5,
					p_attribute6                  => pobj.attribute6,
					p_attribute7                  => pobj.attribute7,
					p_attribute8                  => pobj.attribute8,
					p_attribute9                  => pobj.attribute9,

					p_attribute10                 => pobj.attribute10,
					p_attribute11                 => pobj.attribute11,
					p_attribute12                 => pobj.attribute12,
					p_attribute13                 => pobj.attribute13,
					p_attribute14                 => pobj.attribute14,
					p_attribute15                 => pobj.attribute15,
					p_attribute16                 => pobj.attribute16,
					p_attribute17                 => pobj.attribute17,
					p_attribute18                 => pobj.attribute18,
					p_attribute19                 => pobj.attribute19,
					p_attribute20                 => pobj.attribute20,

					p_attribute21                 => pobj.attribute21,
					p_attribute22                 => pobj.attribute22,
					p_attribute23                 => pobj.attribute23,
					p_attribute24                 => pobj.attribute24,
					p_attribute25                 => pobj.attribute25,
					p_attribute26                 => pobj.attribute26,
					p_attribute27                 => pobj.attribute27,
					p_attribute28                 => pobj.attribute28,
					p_attribute29                 => pobj.attribute29,
					p_attribute30                 => pobj.attribute30
                                    );

            --
            IF g_dbg
            THEN
               op (l_proc, g_regular_log, 50);
            END IF;
           --
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               IF g_dbg
               THEN
                  op ('Leaving Inner:' || l_proc, g_regular_log, 90);
               END IF;

               --
               fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
               g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
               g_retcode                  := warning;
               g_errbuf                   := g_cp_error_txt;
               g_num_errors               := g_num_errors + 1;

               IF g_dbg
               THEN
                  op (g_error_txt, g_regular_log);
               END IF;

               IF g_dbg
               THEN
                  op (SQLERRM, g_regular_log);
               END IF;

               --
               -- If the max number of errors has been exceeded, raise the error and
               -- terminate processing of this plan.
               --
               IF g_num_errors > g_max_errors
               THEN
                  fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
                  g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
                  g_retcode                  := error;
                  g_errbuf                   := g_error_txt;
                  RAISE;
               END IF;
         END;
      END LOOP;

      --
      IF g_dbg
      THEN
         op ('Leaving:' || l_proc, g_debug_log, 190);
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Leaving Outer:' || l_proc, g_regular_log, 200);
         END IF;

         --
         fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
         g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
         g_retcode                  := warning;
         g_errbuf                   := g_cp_error_txt;
         g_num_errors               := g_num_errors + 1;

         IF g_dbg
         THEN
            op (g_error_txt, g_regular_log);
         END IF;

         IF g_dbg
         THEN
            op (SQLERRM, g_regular_log);
         END IF;

         --
         -- If the max number of errors has been exceeded, raise the error and
         -- terminate processing of this plan.
         --
         IF g_num_errors > g_max_errors
         THEN
            fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
            g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
            g_retcode                  := error;
            g_errbuf                   := g_error_txt;
            RAISE;
         END IF;
   --
   END copy_past_objectives;

----------------------------------------------------------------------------------
-----------------< is_supervisor_in_org >-----------------------------------------
----------------------------------------------------------------------------------
-- changed by schowdhu for bug 8740114 30-JUL-09
   FUNCTION is_supervisor_in_org (p_top_organization_id IN NUMBER, p_person_id IN NUMBER)
      RETURN NUMBER
   IS
      --- Declare cursors and local variables
      ---- cursor to get the organisation of the person.
      CURSOR csr_get_org (p_person_id IN NUMBER)
      IS
         SELECT paa.organization_id
           FROM per_all_assignments_f paa
          WHERE (TRUNC (SYSDATE) BETWEEN paa.effective_start_date AND paa.effective_end_date)
            AND paa.person_id = p_person_id
            AND paa.primary_flag = 'Y';

      --- cursor variable
      get_per_org   csr_get_org%ROWTYPE;
   BEGIN
      ------- get the supervisor id of the person
      OPEN csr_get_org (p_person_id);

      FETCH csr_get_org
       INTO get_per_org;

      CLOSE csr_get_org;

      IF (get_per_org.organization_id <> p_top_organization_id)
      THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   END;

---------------------------------------------------------------------------------------
-----------------< change_plan_active_status >-----------------------------------------
---------------------------------------------------------------------------------------
   PROCEDURE change_plan_active_status (p_plan_id IN NUMBER)
   IS
      l_status_code   per_perf_mgmt_plans.status_code%TYPE;
   BEGIN
      SELECT status_code
        INTO l_status_code
        FROM per_perf_mgmt_plans
       WHERE plan_id = p_plan_id;

--- this is the logic for dectivating a published plan .
      IF (l_status_code = 'PUBLISHED')
      THEN
         UPDATE per_perf_mgmt_plans
            SET status_code = 'INACTIVE'
          WHERE plan_id = p_plan_id;

         COMMIT;
--- logic for status code updated to published if already inactive
      ELSIF (l_status_code = 'INACTIVE')
      THEN
         UPDATE per_perf_mgmt_plans
            SET status_code = 'PUBLISHED'
          WHERE plan_id = p_plan_id;

         COMMIT;
-- UI allows only published plan and Inactivate plan to access this function through the functional button.
-- if any other call is made it will not do anything.
      END IF;
   END;

--
--
   PROCEDURE log_message (p_message_text IN VARCHAR2)
   IS
   BEGIN
      IF fnd_global.conc_request_id = -1
      THEN
         hr_utility.TRACE (SUBSTR (p_message_text, 1, 200));
         hr_utility.TRACE (SUBSTR (p_message_text, 201, 200));
      ELSE
         fnd_file.put_line (fnd_file.LOG, p_message_text);
      END IF;
   END log_message;

--
--
--
   PROCEDURE report_plan_summary (
      p_plan_id             IN   NUMBER,
      p_sc_summary          IN   VARCHAR2,
      p_appraisal_summary   IN   VARCHAR2
   )
   IS
      CURSOR csr_sc_summary (p_plan_id IN NUMBER)
      IS
         SELECT   hr_general.decode_lookup ('HR_WPM_SCORECARD_STATUS', status_code) status,
                  COUNT (*) COUNT
             FROM per_personal_scorecards
            WHERE plan_id = p_plan_id
         GROUP BY hr_general.decode_lookup ('HR_WPM_SCORECARD_STATUS', status_code)
         ORDER BY hr_general.decode_lookup ('HR_WPM_SCORECARD_STATUS', status_code);

--
      CURSOR csr_appraisal_summary (p_plan_id IN NUMBER)
      IS
         SELECT   hr_general.decode_lookup ('APPRAISAL_SYSTEM_STATUS', appraisal_system_status)
                                                                                             status,
                  pat.NAME appraisal_template_name,
                  pa.appraisal_period_start_date,
                  pa.appraisal_period_end_date,
                  COUNT (*) COUNT
             FROM per_appraisals pa, per_appraisal_templates pat
            WHERE pa.plan_id = p_plan_id AND pa.appraisal_template_id = pat.appraisal_template_id
         GROUP BY hr_general.decode_lookup ('APPRAISAL_SYSTEM_STATUS', appraisal_system_status),
                  pat.NAME,
                  pa.appraisal_period_start_date,
                  pa.appraisal_period_end_date
         ORDER BY hr_general.decode_lookup ('APPRAISAL_SYSTEM_STATUS', appraisal_system_status),
                  pat.NAME,
                  pa.appraisal_period_start_date,
                  pa.appraisal_period_end_date;
   BEGIN
      IF p_sc_summary = 'Y'
      THEN
         log_message ('Score card summary by status:');
         log_message ('------------------------------------------------------------');
         log_message ('Status                                               Count
'        );
         log_message ('------------------------------------------------------------');

         FOR i IN csr_sc_summary (p_plan_id)
         LOOP
            log_message (i.status || '                     ' || i.COUNT);
         END LOOP;

         log_message ('------------------------------------------------------------');
      END IF;

      IF p_appraisal_summary = 'Y'
      THEN
         log_message ('Appraisal summary by status:');
         log_message ('------------------------------------------------------------------------');
         log_message ('Template Name           Start Date   End Date   Status
Count  ' );
         log_message ('------------------------------------------------------------------------');

         FOR i IN csr_appraisal_summary (p_plan_id)
         LOOP
            log_message (   i.appraisal_template_name
                         || '   '
                         || TO_CHAR (i.appraisal_period_start_date, 'DD/MM/YYYY')
                         || '   '
                         || TO_CHAR (i.appraisal_period_end_date, 'DD/MM/YYYY')
                         || i.status
                         || i.COUNT
                        );
         END LOOP;

         log_message ('------------------------------------------------------------------------');
      END IF;
   ---
   END report_plan_summary;

--
--
   PROCEDURE delete_scorecards (p_plan_id IN NUMBER)
   IS
      CURSOR csr_sc_ids (p_plan_id IN NUMBER)
      IS
         SELECT scorecard_id
           FROM per_personal_scorecards
          WHERE plan_id = p_plan_id;

      TYPE t_sc_ids IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      l_sc_ids   t_sc_ids;
   BEGIN
--
      log_message ('Deleting Score cards for the plan');

      OPEN csr_sc_ids (p_plan_id);

      LOOP
         FETCH csr_sc_ids
         BULK COLLECT INTO l_sc_ids LIMIT 1000;

         --Delete any transactions from HR_API_Transactions and transaction steps
         FORALL i IN l_sc_ids.FIRST .. l_sc_ids.LAST
            DELETE FROM hr_api_transaction_steps step
                  WHERE step.transaction_id IN (
                           SELECT trn.transaction_id
                             FROM hr_api_transactions trn
                            WHERE trn.transaction_ref_id = l_sc_ids (i)
                              AND trn.transaction_ref_table = 'PER_PERSONAL_SCORECARDS');
         FORALL i IN l_sc_ids.FIRST .. l_sc_ids.LAST
            DELETE FROM hr_api_transactions
                  WHERE transaction_ref_id = l_sc_ids (i)
                    AND transaction_ref_table = 'PER_PERSONAL_SCORECARDS';
         -- Delete all score card objectives
         FORALL i IN l_sc_ids.FIRST .. l_sc_ids.LAST
            DELETE FROM per_objectives
                  WHERE scorecard_id = l_sc_ids (i);
         -- Delete all score cards now
         FORALL i IN l_sc_ids.FIRST .. l_sc_ids.LAST
            DELETE FROM per_personal_scorecards
                  WHERE scorecard_id = l_sc_ids (i);
         EXIT WHEN csr_sc_ids%NOTFOUND;
      END LOOP;

      CLOSE csr_sc_ids;

      log_message ('Score cards deleted successfully for the plan');
--
   EXCEPTION
      WHEN OTHERS
      THEN
         log_message ('Error while deleting score cards');
         log_message (SQLERRM);
         RAISE;
   END delete_scorecards;

--
--
--
   PROCEDURE delete_appraisals (p_plan_id IN NUMBER)
   IS
      CURSOR csr_appr (p_plan_id IN NUMBER)
      IS
         SELECT appraisal_id,
                object_version_number
           FROM per_appraisals
          WHERE plan_id = p_plan_id;
   BEGIN
      log_message ('Deleting Appraisals for the plan');

      FOR i IN csr_appr (p_plan_id)
      LOOP
         -- hr_appraisals_api.delete_appraisal
         delete_appraisal_for_person (p_appraisal_id               => i.appraisal_id,
                                      p_object_version_number      => i.object_version_number
                                     );
      END LOOP;

      log_message ('Appraisals deleted successfully for the plan');
   EXCEPTION
      WHEN OTHERS
      THEN
         log_message ('Error while deleting appraisals');
         log_message (SQLERRM);
         RAISE;
   END delete_appraisals;

--
--
   FUNCTION backout_perf_mgmt_plan_cp (
      p_effective_date   IN   DATE,
      p_plan_id          IN   NUMBER,
      p_report_only      IN   VARCHAR2 DEFAULT 'Y'
   )
      RETURN NUMBER
   IS
      l_request_id   NUMBER;
      l_proc         VARCHAR2 (72) := g_package || 'backout_perf_mgmt_plan_cp';
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);

      IF p_plan_id IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'BACKOUT_PERF_MGMT_PLAN_CP',
                                     p_argument            => 'P_PLAN_ID',
                                     p_argument_value      => p_plan_id
                                    );
      END IF;

      IF p_effective_date IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'BACKOUT_PERF_MGMT_PLAN_CP',
                                     p_argument            => 'P_EFFECTIVE_DATE',
                                     p_argument_value      => p_effective_date
                                    );
      END IF;

      l_request_id               :=
         fnd_request.submit_request (application      => 'PER',
                                     program          => 'PERWPMBKOUT',
                                     sub_request      => FALSE,
                                     argument1        => fnd_date.date_to_canonical
                                                                                   (p_effective_date),
                                     argument2        => p_plan_id,
                                     argument3        => p_report_only
                                    );
      COMMIT;
      hr_utility.TRACE ('Request id: ' || l_request_id);
      hr_utility.set_location ('Leaving ' || l_proc, 20);
      RETURN l_request_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_location ('Error submitting the request.' || l_proc, 30);
         RETURN -1;
         RAISE;
   END backout_perf_mgmt_plan_cp;

-- ----------------------------------------------------------------------------
-- |----------------------------< backout_perf_mgmt_plan>----------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE backout_perf_mgmt_plan (
      errbuf             OUT NOCOPY      VARCHAR2,
      retcode            OUT NOCOPY      NUMBER,
      p_effective_date   IN              VARCHAR2,
      p_plan_id          IN              NUMBER,
      p_report_only      IN              VARCHAR2 DEFAULT 'Y'
   )
   IS
      l_proc                    VARCHAR2 (72)              := g_package || 'backout_perf_mgmt_plan';

      CURSOR csr_valid_plan (p_plan_id IN NUMBER)
      IS
         SELECT *
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      l_plan_rec                csr_valid_plan%ROWTYPE;

--psugumar 7294077
      CURSOR csr_person_ids (p_plan_id IN NUMBER)
      IS
         SELECT person_id
           FROM per_personal_scorecards
          WHERE plan_id = p_plan_id;

      l_plan_name               per_perf_mgmt_plans.plan_name%TYPE;

      TYPE tab_person_id IS TABLE OF per_appraisals.appraisee_person_id%TYPE
         INDEX BY BINARY_INTEGER;

      person_ids                tab_person_id;
      l_effective_date          DATE;
      l_object_version_number   NUMBER;
      l_status_code             per_perf_mgmt_plans.status_code%TYPE;
      l_dummy                   BOOLEAN;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);

--Bug7294077
      OPEN csr_person_ids (p_plan_id);

      FETCH csr_person_ids
      BULK COLLECT INTO person_ids LIMIT 1000;

      CLOSE csr_person_ids;

      IF p_plan_id IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'BACKOUT_PERF_MGMT_PLAN',
                                     p_argument            => 'P_PLAN_ID',
                                     p_argument_value      => p_plan_id
                                    );
      END IF;

      IF p_effective_date IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'BACKOUT_PERF_MGMT_PLAN',
                                     p_argument            => 'P_EFFECTIVE_DATE',
                                     p_argument_value      => p_effective_date
                                    );
      END IF;

      l_effective_date           := fnd_date.canonical_to_date (p_effective_date);

      OPEN csr_valid_plan (p_plan_id);

      FETCH csr_valid_plan
       INTO l_plan_rec;

      IF csr_valid_plan%NOTFOUND
      THEN
         hr_utility.set_message (800, 'HR_50264_PMS_INVALID_PLAN');
         log_message ('Perf. Management Plan doesn''t exist.');
         hr_utility.raise_error;
      END IF;

      CLOSE csr_valid_plan;

      IF l_plan_rec.status_code IN ('DRAFT', 'INACTIVE')
      THEN
         fnd_message.set_name ('PER', 'HR_50780_WPM_INVALID_STATUS_BACKOUT');
         log_message (   'This plan cannot be backed out as this is currently in
'
                      || l_plan_rec.status_code
                     );
         fnd_message.set_token ('STATUS', l_plan_rec.status_code);
         hr_utility.raise_error;
      END IF;

      IF TRUNC (SYSDATE) > TRUNC (l_plan_rec.end_date)
      THEN
         log_message ('This plan cannot be backed out as this plan is Completed');
         hr_utility.raise_error;
      END IF;

      log_message ('Details of the Plan: ' || l_plan_rec.plan_name);
      log_message ('--------------------------------------------------------------');
      log_message (   'Administrator                    :
'
                   || hr_general.decode_person_name (l_plan_rec.administrator_person_id)
                  );
      log_message (   'Start Date                       :
'
                   || TO_CHAR (l_plan_rec.start_date, 'DD/MM/YYYY')
                  );
      log_message (   'End Date                         :
'
                   || TO_CHAR (l_plan_rec.start_date, 'DD/MM/YYYY')
                  );
      log_message (   'Status                           :
'
                   || hr_general.decode_lookup ('HR_WPM_PLAN_STATUS', l_plan_rec.status_code)
                  );
      log_message (   'Objective Setting Included?      :
'
                   || hr_general.decode_lookup ('YES_NO', l_plan_rec.include_obj_setting_flag)
                  );
      log_message (   'Appraisals Included?             :
'
                   || hr_general.decode_lookup ('YES_NO', l_plan_rec.include_appraisals_flag)
                  );
      log_message (   'Sharing/Align Objectives Enabled?:
'
                   || hr_general.decode_lookup ('YES_NO', l_plan_rec.sharing_alignment_task_flag)
                  );
      log_message (   'Appraisals Included?             :
'
                   || hr_general.decode_lookup ('YES_NO', l_plan_rec.include_appraisals_flag)
                  );
      log_message ('--------------------------------------------------------------');
      report_plan_summary (p_plan_id                => p_plan_id,
                           p_sc_summary             => NVL (l_plan_rec.include_obj_setting_flag,
                                                            'N'),
                           p_appraisal_summary      => NVL (l_plan_rec.include_appraisals_flag, 'N')
                          );

      IF p_report_only = 'Y'
      THEN
         RETURN;
      END IF;

--Update the  plan status to SUBMITTED so that no further updates can happen to the plan
      l_object_version_number    := l_plan_rec.object_version_number;
      l_status_code              := 'SUBMITTED';
      per_pmp_upd.upd (p_plan_id                     => p_plan_id,
                       p_effective_date              => l_effective_date,
                       p_object_version_number       => l_object_version_number,
                       p_status_code                 => l_status_code,
                       p_duplicate_name_warning      => l_dummy,
                       p_no_life_events_warning      => l_dummy
                      );
      COMMIT;

      IF NVL (l_plan_rec.include_obj_setting_flag, 'N') = 'Y'
      THEN
         delete_scorecards (p_plan_id);
      END IF;

      IF NVL (l_plan_rec.include_appraisals_flag, 'N') = 'Y'
      THEN
         delete_appraisals (p_plan_id);
      END IF;

      --
      -- reset the plan status to DRAFT now
      l_status_code              := 'DRAFT';
      per_pmp_upd.upd (p_plan_id                     => p_plan_id,
                       p_effective_date              => l_effective_date,
                       p_object_version_number       => l_object_version_number,
                       p_status_code                 => l_status_code,
                       p_duplicate_name_warning      => l_dummy,
                       p_no_life_events_warning      => l_dummy
                      );

      --remove the plan details from hierarchy table as plan is rolled back.
      DELETE      per_wpm_plan_hierarchy
            WHERE plan_id = p_plan_id;

      --remove the plan details from Appraisal Summary table as plan is rolled back.
      DELETE      per_wpm_appraisal_summary
            WHERE plan_id = p_plan_id;

--7294077
      FOR j IN 1 .. person_ids.COUNT
      LOOP
         send_message_notification (person_ids (j), 'WPM_PLAN_ROLLBACK_MSG', p_plan_id, NULL);
      END LOOP;

      COMMIT;
      hr_utility.set_location ('Leaving:' || l_proc, 50);
   EXCEPTION
      WHEN OTHERS
      THEN
         retcode                    := error;
         errbuf                     := SQLERRM;
         ROLLBACK;
         l_status_code              := 'PUBLISHED';
         per_pmp_upd.upd (p_plan_id                     => p_plan_id,
                          p_effective_date              => l_effective_date,
                          p_object_version_number       => l_object_version_number,
                          p_status_code                 => l_status_code,
                          p_duplicate_name_warning      => l_dummy,
                          p_no_life_events_warning      => l_dummy
                         );
         COMMIT;
         RAISE;
   END backout_perf_mgmt_plan;

--
--
   FUNCTION plan_admin_actions_cp (
      p_effective_date           IN   DATE,
      p_plan_id                  IN   NUMBER,
      p_selected_entities_list   IN   VARCHAR2,
      p_task_code                IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      l_request_id   NUMBER;
      l_proc         VARCHAR2 (72) := g_package || 'plan_admin_actions_cp';
   BEGIN
      --
      hr_utility.set_location ('Entering ' || l_proc, 10);

      IF p_plan_id IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_PLAN_ID',
                                     p_argument_value      => p_plan_id
                                    );
      END IF;

      IF p_effective_date IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_EFFECTIVE_DATE',
                                     p_argument_value      => p_effective_date
                                    );
      END IF;

      IF p_selected_entities_list IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_SELECTED_ENTITIES_LIST',
                                     p_argument_value      => p_selected_entities_list
                                    );
      END IF;

      IF p_task_code IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_TASK_CODE',
                                     p_argument_value      => p_task_code
                                    );
      END IF;

      IF hr_api.not_exists_in_hr_lookups (p_effective_date      => p_effective_date,
                                          p_lookup_type         => 'HR_WPM_ADMIN_ACTIONS',
                                          p_lookup_code         => p_task_code
                                         )
      THEN
         log_message ('Invalid task code selected.' || p_task_code);
         hr_utility.set_message (800, 'HR_WPM_TASK_CODE_NOT_EXISTS');
         hr_utility.raise_error;
      END IF;

      --
      l_request_id               :=
         fnd_request.submit_request (application      => 'PER',
                                     program          => 'PERWPMADMINCP',
                                     sub_request      => FALSE,
                                     argument1        => fnd_date.date_to_canonical
                                                                                   (p_effective_date),
                                     argument2        => p_plan_id,
                                     argument3        => p_selected_entities_list,
                                     argument4        => p_task_code
                                    );
      COMMIT;
      hr_utility.TRACE ('Request id: ' || l_request_id);
      hr_utility.set_location ('Leaving ' || l_proc, 20);
      --
      RETURN l_request_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.set_location ('Error submitting the request.' || l_proc, 30);
         RAISE;
   END plan_admin_actions_cp;

--
--
   FUNCTION string_to_array (p_selected_entities_list IN VARCHAR2)
      RETURN NUMBER
   IS
      i            NUMBER;
      l_pos        NUMBER;
      l_sel_list   VARCHAR2 (32767);
   BEGIN
      -- Delete existing pl/sql table, if any.
      g_selected_entities.DELETE;
      l_sel_list                 := p_selected_entities_list;
      i                          := 0;
      l_pos                      := INSTR (l_sel_list, ',');

      LOOP
         IF l_pos <> 0
         THEN
            g_selected_entities (i)    := SUBSTR (l_sel_list, 1, l_pos - 1);
         ELSE
            g_selected_entities (i)    := l_sel_list;
         END IF;

         EXIT WHEN l_sel_list IS NULL OR l_pos = 0;
         l_sel_list                 := SUBSTR (l_sel_list, l_pos + 1);
         i                          := i + 1;
         l_pos                      := INSTR (l_sel_list, ',');
      END LOOP;

      RETURN g_selected_entities.COUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END string_to_array;

--
   FUNCTION chk_assignment_in_population (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_chk   VARCHAR2 (1)   := 'N';
      i       BINARY_INTEGER;
   BEGIN
      IF g_qual_pop_tbl.COUNT > 0
      THEN
         IF g_qual_pop_tbl.EXISTS (p_assignment_id)
         THEN
            l_chk                      := 'Y';
         END IF;
      END IF;

      RETURN l_chk;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END chk_assignment_in_population;

--
--
   PROCEDURE enroll_a_person (
      p_plan_id          IN   NUMBER,
      p_assignment_id    IN   NUMBER,
      p_person_id        IN   NUMBER,
      p_effective_date   IN   DATE
   )
   IS
      l_effective_date          DATE                              := p_effective_date;
      l_qual_pop_index          BINARY_INTEGER;
      l_scorecard_status_code   VARCHAR2 (40);
      l_scorecard_id            NUMBER;
      l_qual_obj_index          BINARY_INTEGER;
      l_obj_date                DATE                              := TRUNC (SYSDATE);
      l_check_elig              VARCHAR2 (1);
      l_check_period_elig       VARCHAR2 (1);
      l_plan_aprsl_pds_index    BINARY_INTEGER;
      l_appr_ret_status         VARCHAR2 (30);
      l_elig_obj_id             ben_elig_obj_f.elig_obj_id%TYPE;
      l_proc                    VARCHAR2 (72)                     := g_package || 'enroll_a_person';

      -- cursor added
      -- 23-Jun-2009 schowdhu Eligibility Profile Enhc.
      CURSOR get_elig_obj_id_for_period (
         p_appraisal_period_id   IN   per_appraisal_periods.appraisal_period_id%TYPE
      )
      IS
         SELECT elig.elig_obj_id
           FROM ben_elig_obj_f elig
          WHERE elig.table_name = 'PER_APPRAISAL_PERIODS'
            AND elig.column_name = 'APPRAISAL_PERIOD_ID'
            AND elig.COLUMN_VALUE = p_appraisal_period_id
            AND TRUNC (SYSDATE) BETWEEN elig.effective_start_date AND elig.effective_end_date;
   BEGIN
      IF (g_plan_dtls (1).automatic_allocation_flag = 'Y')
      THEN
         populate_qual_objectives (g_plan_dtls (1).start_date, g_plan_dtls (1).end_date);
      END IF;

      IF (g_plan_dtls (1).include_appraisals_flag = 'Y')
      THEN
         populate_plan_apprsl_periods (g_plan_dtls (1).plan_id);
      END IF;

      --
      -- Loop through plan population to create/update/delete scorecards, objectives and appraisal
      --
      l_qual_pop_index           := p_assignment_id;

      IF g_plan_dtls (1).status_code = 'PUBLISHED'
      THEN
         ----
                -- If objective setting flag is set
         IF (   (g_plan_dtls (1).include_obj_setting_flag = 'Y')
             OR (g_plan_dtls (1).include_appraisals_flag = 'Y')
            )
         THEN
            -- Create the scorecard for this assignment
            IF g_plan_dtls (1).method_code = 'CAS'
            THEN
               IF    (    g_plan_dtls (1).hierarchy_type_code = 'SUP'
                      AND g_plan_dtls (1).supervisor_id =
                                                         g_qual_pop_tbl (l_qual_pop_index).person_id
                     )
                  OR (    g_plan_dtls (1).hierarchy_type_code = 'SUP_ASG'
                      AND g_plan_dtls (1).supervisor_assignment_id =
                                                     g_qual_pop_tbl (l_qual_pop_index).assignment_id
                     )
                  OR (    g_plan_dtls (1).hierarchy_type_code IN ('POS')
                      AND g_plan_dtls (1).top_position_id =
                                                       g_qual_pop_tbl (l_qual_pop_index).position_id
                     )
                  OR (    g_plan_dtls (1).hierarchy_type_code = 'ORG'
                      AND is_supervisor_in_org (g_plan_dtls (1).top_organization_id,
                                                g_qual_pop_tbl (l_qual_pop_index).person_id
                                               ) = 1
                     )
               THEN
                  l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
               ELSE
                  l_scorecard_status_code    := 'NOT_STARTED_WITH_MGR';
               END IF;
            ELSE
               l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
            END IF;

            --
            create_scorecard_for_person
                                 (p_effective_date      => l_effective_date,
                                  p_scorecard_name      => g_plan_dtls (1).plan_name,
                                  p_assignment_id       => g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                  p_start_date          => g_plan_dtls (1).start_date,
                                  p_end_date            => g_plan_dtls (1).end_date,
                                  p_plan_id             => g_plan_dtls (1).plan_id,
                                  p_creator_type        => 'AUTO',
                                  p_status_code         => l_scorecard_status_code,
                                  p_scorecard_id        => l_scorecard_id
                                 );
            -- Now update the plan hierarchy for this person
            per_wpm_summary_pkg.build_hierarchy_for_sc (p_plan_id      => g_plan_dtls (1).plan_id,
                                                        p_sc_id        => l_scorecard_id
                                                       );

            -- added the above line to update hierarchy for this sc.
            IF (g_plan_dtls (1).automatic_allocation_flag = 'Y' AND l_scorecard_id IS NOT NULL)
            THEN
               l_qual_obj_index           := g_qual_obj_tbl.FIRST;

               WHILE (l_qual_obj_index IS NOT NULL)
               LOOP
                  --
                  -- Enclose the call to eligibility within a block, so that if for any
                  -- reason the eligibility engine errors, then process can still
                  -- continue by skipping the current person/assignemnt as not eligible
                  --
                  BEGIN
                     --
                     ben_env_object.init
                        (p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                         p_thread_id              => NULL,
                         p_chunk_size             => NULL,
                         p_threads                => NULL,
                         p_max_errors             => NULL,
                         p_benefit_action_id      => NULL,
                         p_effective_date         => l_obj_date
                        );
                     --
                     --
                     l_check_elig               :=
                        ben_per_asg_elig.eligible
                                                 (g_qual_pop_tbl (l_qual_pop_index).person_id,
                                                  g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                                  g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                                  l_obj_date,
                                                  g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                                                  'Y' ---KMG -- Added to Allow CWK's
                                                 );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;

                  IF (l_check_elig = 'Y')
                  THEN
                     -- Create the objective
                     create_scorecard_objective
                        (p_effective_date              => l_effective_date,
                         p_scorecard_id                => l_scorecard_id,
                         p_business_group_id           => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                         p_person_id                   => g_qual_pop_tbl (l_qual_pop_index).person_id,
                         p_start_date                  => g_plan_dtls (1).start_date,
                         p_end_date                    => g_plan_dtls (1).end_date,
                         p_objective_name              => g_qual_obj_tbl (l_qual_obj_index).objective_name,
                         p_valid_from                  => g_qual_obj_tbl (l_qual_obj_index).valid_from,
                         p_valid_to                    => g_qual_obj_tbl (l_qual_obj_index).valid_to,
                         p_target_date                 => g_qual_obj_tbl (l_qual_obj_index).target_date,
                         p_copied_from_library_id      => g_qual_obj_tbl (l_qual_obj_index).objective_id,
                         p_next_review_date            => g_qual_obj_tbl (l_qual_obj_index).next_review_date,
                         p_group_code                  => g_qual_obj_tbl (l_qual_obj_index).group_code,
                         p_priority_code               => g_qual_obj_tbl (l_qual_obj_index).priority_code,
                         p_appraise_flag               => g_qual_obj_tbl (l_qual_obj_index).appraise_flag,
                         p_weighting_percent           => g_qual_obj_tbl (l_qual_obj_index).weighting_percent,
                         p_target_value                => g_qual_obj_tbl (l_qual_obj_index).target_value,
                         p_uom_code                    => g_qual_obj_tbl (l_qual_obj_index).uom_code,
                         p_measurement_style_code      => g_qual_obj_tbl (l_qual_obj_index).measurement_style_code,
                         p_measure_name                => g_qual_obj_tbl (l_qual_obj_index).measure_name,
                         p_measure_type_code           => g_qual_obj_tbl (l_qual_obj_index).measure_type_code,
                         p_measure_comments            => g_qual_obj_tbl (l_qual_obj_index).measure_comments,
                         p_details                     => g_qual_obj_tbl (l_qual_obj_index).details,
                         p_success_criteria            => g_qual_obj_tbl (l_qual_obj_index).success_criteria,
                         p_comments                    => g_qual_obj_tbl (l_qual_obj_index).comments
                        );
                  END IF;

                  --
                  l_qual_obj_index           := g_qual_obj_tbl.NEXT (l_qual_obj_index);
               --
               END LOOP;
            END IF;                                                     --auto allocation flag = 'y'

            IF (    g_plan_dtls (1).copy_past_objectives_flag = 'Y'
                AND g_plan_dtls (1).previous_plan_id IS NOT NULL
               )
            THEN
               --
               copy_past_objectives
                        (p_effective_date         => l_effective_date,
                         p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                         p_person_id              => g_qual_pop_tbl (l_qual_pop_index).person_id,
                         p_scorecard_id           => l_scorecard_id,
                         p_start_date             => g_plan_dtls (1).start_date,
                         p_end_date               => g_plan_dtls (1).end_date,
                         p_target_date            => NULL,
                         p_assignemnt_id          => g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                         p_prev_plan_id           => g_plan_dtls (1).previous_plan_id,
                         p_curr_plan_id           => g_plan_dtls (1).plan_id
                        );
            --
            END IF;                                                                                --

            -- Create appraisals for this person only if there exists any appraisals for this plan.
            IF g_plan_dtls (1).include_appraisals_flag = 'Y' AND g_appraisals_exist = 'Y'
            THEN
               l_plan_aprsl_pds_index     := g_plan_aprsl_pds_tbl.FIRST;

               WHILE (l_plan_aprsl_pds_index IS NOT NULL)
               LOOP
                  --23-Jun-2009 schowdhu Eligibility Profile Enhc.-start
                   --
                   -- Enclose the call to eligibility within a block, so that if for any
                   -- reason the eligibility engine errors, then process can still
                   -- continue by skipping the current person/assignemnt as not eligible
                   --
                  OPEN get_elig_obj_id_for_period
                                  (g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).appraisal_period_id
                                  );

                  FETCH get_elig_obj_id_for_period
                   INTO l_elig_obj_id;

                  CLOSE get_elig_obj_id_for_period;

                  IF (l_elig_obj_id IS NOT NULL)
                  THEN
                     BEGIN
                        --
                        ben_env_object.init
                           (p_business_group_id      => g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                            p_thread_id              => NULL,
                            p_chunk_size             => NULL,
                            p_threads                => NULL,
                            p_max_errors             => NULL,
                            p_benefit_action_id      => NULL,
                            p_effective_date         => l_obj_date
                           );
                        --
                        --
                        l_check_period_elig        :=
                           ben_per_asg_elig.eligible
                                                 (p_person_id,
                                                  p_assignment_id,
                                                  l_elig_obj_id,
                                                  l_obj_date,
                                                  g_qual_pop_tbl (l_qual_pop_index).business_group_id,
                                                  'Y' ---KMG -- Added to Allow CWK's
                                                 );
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_check_period_elig        := 'N';

                           IF g_dbg
                           THEN
                              op (l_proc, g_debug_log, 330);
                           END IF;

                           IF g_dbg
                           THEN
                              op
                                 (   l_proc
                                  || ' enroll_a_person skipped for appraisal period: '
                                  || g_plan_aprsl_pds_tbl (l_plan_aprsl_pds_index).appraisal_period_id
                                  || ' assignment_id: '
                                  || g_qual_pop_tbl (l_qual_pop_index).assignment_id,
                                  g_debug_log,
                                  330
                                 );
                           END IF;
                     END;
                  END IF;                                                -- l_elig_obj_id null check

--23-Jun-2009 schowdhu Eligibility Profile Enhc.-start
                  IF (   l_check_period_elig = 'Y'
                      OR (l_check_period_elig IS NULL AND l_elig_obj_id IS NULL)
                     )
                  THEN
                     hr_wpm_mass_apr_push.create_appraisal_for_person
                        (p_score_card_id              => l_scorecard_id,
                         p_appraisal_templ_id         => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).appraisal_template_id,
                         p_effective_date             => p_effective_date,         --to be validated
                         p_appraisal_start_date       => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).start_date,
                         p_appraisal_end_date         => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).end_date,
                         p_appraisal_date             => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).task_start_date,
                         p_appraisal_status           => 'PLANNED',        -- decided in the meeting
                         p_plan_id                    => p_plan_id,
                         p_next_appraisal_date        => NULL,                              -- to be
                         p_appraisal_initiator        => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).initiator_code,
                         p_type                       => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).appraisal_type,
                         -- A column to be added to UI and table in per_appraisal_periods
                         p_appraisal_system_type      => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).appraisal_system_type,
                         p_return_status              => l_appr_ret_status
                        );
                  END IF;                                                       -- eligibility check

                  --
                  l_plan_aprsl_pds_index     := g_plan_aprsl_pds_tbl.NEXT (l_plan_aprsl_pds_index);
               --
               END LOOP;
            END IF;
         END IF;                                           -- appraisal = y or objective setting 'y'
      END IF;                                                                       -- plan PUBLISHD
   END enroll_a_person;

--
--
   PROCEDURE admin_enroll_into_plan (p_plan_id IN NUMBER, p_effective_date IN DATE)
   IS
      l_proc                   VARCHAR2 (72)               := g_package || 'admin_enroll_into_plan';
      l_plan_name              per_perf_mgmt_plans.plan_name%TYPE;

      --
      CURSOR csr_person_dtls (p_assignment_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT papf.person_id,
                papf.full_name full_name,
                paaf.assignment_id,
                paaf.assignment_number,
                paaf.position_id,
                paaf.organization_id,
                paaf.supervisor_id,
                paaf.supervisor_assignment_id,
                suppapf.full_name supervisor_name
           FROM per_people_f papf, per_assignments_f paaf, per_all_people_f suppapf
          WHERE paaf.assignment_id = p_assignment_id
            AND papf.person_id = paaf.person_id
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND paaf.supervisor_id = suppapf.person_id(+)
            --8632500 Modified
            AND p_effective_date BETWEEN suppapf.effective_start_date(+) AND suppapf.effective_end_date(+);

      --
      l_person_rec             csr_person_dtls%ROWTYPE;

      --
      --
      CURSOR csr_apprs_exist (p_plan_id IN NUMBER)
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (SELECT 'x'
                          FROM per_appraisals
                         WHERE plan_id = p_plan_id);

      l_chk_exists             VARCHAR2 (1);

      --
      --
      CURSOR csr_asg_enrolled (p_assignment_id IN NUMBER, p_plan_id IN NUMBER)
      IS
         SELECT 'Y'
           FROM per_personal_scorecards
          WHERE plan_id = p_plan_id
            AND assignment_id = p_assignment_id
            AND status_code <> 'TRANSFER_OUT';

      l_asg_already_enrolled   VARCHAR2 (1);
      l_person_id              NUMBER;
   BEGIN
      hr_utility.set_location ('Entering:' || l_proc, 10);
      g_qual_pop_tbl.DELETE;
      populate_qual_plan_population (g_plan_dtls (1), p_effective_date);
      hr_utility.set_location (l_proc, 11);

      IF (g_plan_dtls (1).automatic_allocation_flag = 'Y')
      THEN
         populate_qual_objectives (g_plan_dtls (1).start_date, g_plan_dtls (1).end_date);
      END IF;

      hr_utility.set_location (l_proc, 12);

      IF (g_plan_dtls (1).include_appraisals_flag = 'Y')
      THEN
         populate_plan_apprsl_periods (g_plan_dtls (1).plan_id);

         OPEN csr_apprs_exist (p_plan_id);

         FETCH csr_apprs_exist
          INTO g_appraisals_exist;

         CLOSE csr_apprs_exist;
      END IF;

      hr_utility.set_location (l_proc, 13);
--
      l_asg_already_enrolled     := 'N';

      FOR i IN g_selected_entities.FIRST .. g_selected_entities.LAST
      LOOP
         hr_utility.set_location (l_proc, 14);

         OPEN csr_asg_enrolled (g_selected_entities (i), p_plan_id);

         FETCH csr_asg_enrolled
          INTO l_asg_already_enrolled;

         CLOSE csr_asg_enrolled;

         -- Bug 7277335  Fix
         -- IF NVL(l_asg_already_enrolled,'N') = 'N' THEN
         FOR j IN csr_person_dtls (g_selected_entities (i), p_effective_date)
         LOOP
            l_chk_exists               := chk_assignment_in_population (j.assignment_id);
            hr_utility.set_location (l_proc, 15);
            l_person_id                := j.person_id;

            IF l_chk_exists = 'N'
            THEN
               log_message (   j.full_name
                            || '-'
                            || j.assignment_id
                            || '-'
                            || j.assignment_number
                            || ' is not in the plan population. Cannot enroll.'
                           );
               g_num_errors               := NVL (g_num_errors, 0) + 1;
            --EDIT -- write a message to the conc.log
            ELSE
               BEGIN
                  IF NVL (l_asg_already_enrolled, 'N') = 'N'
                  THEN
                     log_message (   j.full_name
                                  || '-'
                                  || j.assignment_number
                                  || ' is in the plan population. Trying to enroll.'
                                 );
                     enroll_a_person (p_plan_id             => p_plan_id,
                                      p_assignment_id       => j.assignment_id,
                                      p_person_id           => j.person_id,
                                      p_effective_date      => p_effective_date
                                     );
                     log_message (   'Successfully enrolled '
                                  || j.full_name
                                  || '-'
                                  || j.assignment_number
                                  || '.'
                                 );
                   -- Ntf should be sent if person is successfully enrolled
                  send_message_notification (l_person_id, 'WPM_AP_ENROLL_MSG', p_plan_id, NULL);  -- 9014013 Bug Fix
                  ELSE
                     log_message (   j.full_name
                                  || '-'
                                  || j.assignment_id
                                  || '-'
                                  || j.assignment_number
                                  || ' is already Enrolled '
                                 );
                     g_num_errors               := NVL (g_num_errors, 0) + 1;
                  END IF;
               -- Commenting this as Ntf should not be sent if person is already enrolled .
               -- send_message_notification (l_person_id, 'WPM_AP_ENROLL_MSG', p_plan_id, NULL);  -- 9014013 Bug Fix
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     log_message (   'Error
enrolling:'
                                  || j.full_name
                                  || '-'
                                  || j.assignment_number
                                  || '.'
                                 );
                     log_message (SQLERRM);
                     g_num_errors               := NVL (g_num_errors, 0) + 1;
               END;
            END IF;
         END LOOP;

        -- send_message_notification (l_person_id, 'WPM_AP_ENROLL_MSG', p_plan_id, NULL);  -- 9014013 Bug Fix
      --  END IF; -- asg not enrolled
      END LOOP;

      hr_utility.set_location ('Leaving:' || l_proc, 100);
   END admin_enroll_into_plan;

--
--
   PROCEDURE revert_appraisal_details (
      p_appraisal_id     IN   NUMBER,
      p_plan_id          IN   NUMBER,
      p_effective_date   IN   DATE
   )
   IS
      CURSOR csr_event_dtls (p_appraisal_id NUMBER)
      IS
         SELECT pa.appraisee_person_id,
                pe.event_id,
                pe.object_version_number event_ovn,
                ppr.performance_review_id,
                ppr.object_version_number review_ovn
           FROM per_appraisals pa, per_events pe, per_performance_reviews ppr
          WHERE pa.appraisal_id = p_appraisal_id
            AND pa.event_id = pe.event_id
            AND pe.event_id = ppr.event_id;

      l_appraisee_person_id           NUMBER;

      --
      CURSOR csr_appr_objs (p_appraisal_id NUMBER)
      IS
         SELECT po.objective_id,
                po.object_version_number
           FROM per_objectives po
          WHERE appraisal_id = p_appraisal_id;

      --
      CURSOR csr_sc_obj (p_sc_id NUMBER, p_objective_id NUMBER)
      IS
         SELECT po.objective_id,
                po.object_version_number
           FROM per_objectives po
          WHERE scorecard_id = p_sc_id AND copied_from_objective_id = p_objective_id;

      --
      CURSOR csr_sc_id (p_appraisee_person_id NUMBER, p_plan_id NUMBER)
      IS
         SELECT scorecard_id
           FROM per_personal_scorecards sc
          WHERE person_id = p_appraisee_person_id AND plan_id = p_plan_id;

      l_sc_id                         NUMBER;
-- Variables for IN/OUT parameters
      l_weighting_over_100_warning    BOOLEAN;
      l_weighting_appraisal_warning   BOOLEAN;
      l_object_version_number         NUMBER;
   BEGIN
      -- Delete the event that is created and the performance review row as well
      FOR i IN csr_event_dtls (p_appraisal_id)
      LOOP
         l_appraisee_person_id      := i.appraisee_person_id;
         hr_perf_review_api.delete_perf_review (p_performance_review_id      => i.performance_review_id,
                                                p_object_version_number      => i.review_ovn
                                               );
         --
         per_events_api.delete_event (p_event_id                   => i.event_id,
                                      p_object_version_number      => i.event_ovn
                                     );
      END LOOP;

      OPEN csr_sc_id (l_appraisee_person_id, p_plan_id);

      FETCH csr_sc_id
       INTO l_sc_id;

      CLOSE csr_sc_id;

      --
      -- Update the scorecard_id back in all the appraisal objectives
      -- and delete the duplicated objectives from the sc
      IF l_sc_id IS NOT NULL
      THEN
         FOR j IN csr_appr_objs (p_appraisal_id)
         LOOP
            l_object_version_number    := j.object_version_number;
            hr_objectives_api.update_objective
                                   (p_validate                         => FALSE,
                                    p_effective_date                   => p_effective_date,
                                    p_objective_id                     => j.objective_id,
                                    p_object_version_number            => l_object_version_number,
                                    p_scorecard_id                     => l_sc_id,
                                    p_weighting_over_100_warning       => l_weighting_over_100_warning,
                                    p_weighting_appraisal_warning      => l_weighting_appraisal_warning,
                                    p_appraise_flag                    => 'Y'
                                   );

            --now delete the duplicated objective from the SC
            FOR i IN csr_sc_obj (l_sc_id, j.objective_id)
            LOOP
               hr_objectives_api.delete_objective
                                                (p_validate                   => FALSE,
                                                 p_objective_id               => i.objective_id,
                                                 p_object_version_number      => i.object_version_number
                                                );
            END LOOP;
         END LOOP;
      END IF;
   --
   END revert_appraisal_details;

--
--
   PROCEDURE admin_reopen_plan_appraisals (p_plan_id IN NUMBER, p_effective_date IN DATE)
   IS
      CURSOR csr_appraisal_dtls (
         p_appraisal_id     IN   NUMBER,
         p_plan_id          IN   NUMBER,
         p_effective_date   IN   DATE
      )
      IS
         SELECT pa.appraisal_id,
                pa.main_appraiser_id,
                pa.appraisee_person_id,
                papf.full_name "MAIN_APPRAISER_NAME",
                papf1.full_name "APPRAISEE_NAME",
                TO_CHAR (appraisal_period_start_date, 'DD-MON-YYYY') appraisal_period_start_date,
                TO_CHAR (appraisal_period_end_date, 'DD-MON-YYYY') appraisal_period_end_date,
                TO_CHAR (appraisal_date, 'DD-MON-YYYY') appraisal_date,
                pa.status,
                pa.assignment_id
           FROM per_appraisals pa, per_people_f papf, per_people_f papf1
          WHERE pa.appraisal_id = p_appraisal_id
            AND pa.plan_id = p_plan_id
            AND pa.main_appraiser_id = papf.person_id
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
            AND pa.appraisee_person_id = papf1.person_id
            AND p_effective_date BETWEEN papf1.effective_start_date AND papf1.effective_end_date;

      l_appraisal_dtls   VARCHAR2 (4000);
      l_person_id        per_appraisals.appraisee_person_id%TYPE;
      l_assignment_id    per_appraisals.assignment_id%TYPE;
      l_full_name        per_people_f.full_name%TYPE;
   BEGIN
      FOR i IN g_selected_entities.FIRST .. g_selected_entities.LAST
      LOOP
         BEGIN
            FOR j IN csr_appraisal_dtls (g_selected_entities (i), p_plan_id, p_effective_date)
            LOOP
               log_message ('Opening appraisal for: ' || j.appraisee_name);
               log_message (   'This appraisal will be assigned to the main appraiser,'
                            || j.main_appraiser_name
                            || ' in Ongoing Status.'
                           );
               l_appraisal_dtls           :=
                     j.appraisee_name
                  || '-'
                  || j.appraisal_period_start_date
                  || ' - '
                  || j.appraisal_period_end_date;
               l_person_id                := j.appraisee_person_id;
               l_assignment_id            := j.assignment_id;
               l_full_name                := j.appraisee_name;
            END LOOP;

            --
            revert_appraisal_details (p_appraisal_id        => g_selected_entities (i),
                                      p_plan_id             => p_plan_id,
                                      p_effective_date      => p_effective_date
                                     );

            --
            UPDATE per_appraisals pa
               SET system_params =
                                 SUBSTR (system_params, 1, INSTR (pa.system_params, 'pItemKey=') - 2),
                   appraisal_system_status = 'ONGOING',
                   event_id = NULL
             WHERE pa.appraisal_id = g_selected_entities (i);

            --
            --
            send_message_notification (get_manager_id (l_person_id, l_assignment_id),
                                       'WPM_APPRAISAL_REOPEN_MGR_MSG',
                                       p_plan_id,
                                       l_full_name
                                      );
            send_message_notification (l_person_id, 'WPM_APPRAISAL_REOPEN_WKR_MSG', p_plan_id, NULL);
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               log_message ('Error reopening appraisal:' || l_appraisal_dtls || '.');
               log_message (SQLERRM);
               g_num_errors               := NVL (g_num_errors, 0) + 1;
         END;
      END LOOP;
   END admin_reopen_plan_appraisals;

--
--
   PROCEDURE remove_scorecard_details (p_scorecard_id IN NUMBER)
   IS
   BEGIN
      DELETE FROM hr_api_transaction_steps step
            WHERE step.transaction_id IN (
                     SELECT trn.transaction_id
                       FROM hr_api_transactions trn
                      WHERE trn.transaction_ref_id = p_scorecard_id
                        AND trn.transaction_ref_table = 'PER_PERSONAL_SCORECARDS');

      DELETE FROM hr_api_transactions
            WHERE transaction_ref_id = p_scorecard_id
              AND transaction_ref_table = 'PER_PERSONAL_SCORECARDS';

      --
      DELETE FROM per_objectives
            WHERE scorecard_id = p_scorecard_id;
   END remove_scorecard_details;

   PROCEDURE admin_remove_scorecard (p_plan_id IN NUMBER, p_effective_date IN DATE)
   IS
      CURSOR csr_sc_dtls (p_sc_id IN NUMBER, p_plan_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT pc.scorecard_id,
                pc.person_id,
                papf.full_name scorecard_owner,
                pc.status_code
           FROM per_personal_scorecards pc, per_people_f papf
          WHERE pc.scorecard_id = p_sc_id
            AND pc.plan_id = p_plan_id
            AND pc.person_id = papf.person_id
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;

      --
      CURSOR csr_appr_dtls (p_person_id NUMBER, p_plan_id NUMBER)
      IS
         SELECT appraisal_id,
                object_version_number
           FROM per_appraisals
          WHERE plan_id = p_plan_id AND appraisee_person_id = p_person_id;

      --
      l_sc_dtls     VARCHAR2 (500);
      l_person_id   per_personal_scorecards.person_id%TYPE;
   BEGIN
      FOR i IN g_selected_entities.FIRST .. g_selected_entities.LAST
      LOOP
         BEGIN
            FOR j IN csr_sc_dtls (g_selected_entities (i), p_plan_id, p_effective_date)
            LOOP
               log_message ('Removing scorecard for: ' || j.scorecard_owner);
               l_sc_dtls                  := j.scorecard_owner || '- ' || j.status_code;
               -- no  need to remove score card details
               remove_scorecard_details (g_selected_entities (i));

               -- UPdate the status of score card to DELETED
               DELETE      per_personal_scorecards
                     WHERE scorecard_id = g_selected_entities (i);

               --
               FOR k IN csr_appr_dtls (j.person_id, p_plan_id)
               LOOP
                  delete_appraisal_for_person (k.appraisal_id, k.object_version_number);
               END LOOP;

               -- remove the node from the hierarchy
               DELETE FROM per_wpm_plan_hierarchy
                     WHERE employee_person_id = j.person_id;

               --
               l_person_id                := j.person_id;
            END LOOP;

            send_message_notification (l_person_id, 'WPM_SC_REMOVE_MSG', p_plan_id, NULL);
         --
         EXCEPTION
            WHEN OTHERS
            THEN
               log_message ('Error removing scorecard:' || l_sc_dtls || '.');
               log_message (SQLERRM);
               g_num_errors               := NVL (g_num_errors, 0) + 1;
         END;
      END LOOP;
--
   END admin_remove_scorecard;

--
--
   PROCEDURE admin_reopen_scorecard (p_plan_id IN NUMBER, p_effective_date IN DATE)
   IS
      CURSOR csr_sc_dtls (p_sc_id IN NUMBER, p_plan_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT pc.scorecard_id,
                pc.person_id,
                papf.full_name scorecard_owner,
                pc.status_code,
                papf.business_group_id,
                paaf.organization_id,
                paaf.position_id,
                paaf.job_id,
                pc.assignment_id,
                paaf.supervisor_id                                                    --  Bug7567079
           FROM per_personal_scorecards pc, per_people_f papf, per_assignments_f paaf
          WHERE pc.scorecard_id = p_sc_id
            AND pc.plan_id = p_plan_id
            AND pc.assignment_id = paaf.assignment_id
            AND pc.person_id = papf.person_id
            AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;

      CURSOR csr_appr_in_progress (p_plan_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT 'Y'
           FROM per_appraisal_periods
          WHERE plan_id = p_plan_id AND p_effective_date BETWEEN task_start_date AND task_end_date;

      l_appraisals_in_progress   VARCHAR2 (1)   := 'N';
      l_sc_dtls                  VARCHAR2 (500);
      l_scorecard_status_code    VARCHAR2 (30);
   --Bug7567079 l_sup_id per_all_assignments_f.supervisor_id%type default null;
   BEGIN
      OPEN csr_appr_in_progress (p_plan_id, p_effective_date);

      FETCH csr_appr_in_progress
       INTO l_appraisals_in_progress;

      CLOSE csr_appr_in_progress;

      FOR i IN g_selected_entities.FIRST .. g_selected_entities.LAST
      LOOP
         FOR j IN csr_sc_dtls (g_selected_entities (i), p_plan_id, p_effective_date)
         LOOP
            BEGIN
               log_message ('Reopening scorecard for: ' || j.scorecard_owner);
               l_sc_dtls                  := j.scorecard_owner || '- ' || j.status_code;

               IF (   TRUNC (SYSDATE) BETWEEN g_plan_dtls (1).obj_setting_start_date
                                          AND g_plan_dtls (1).obj_setting_deadline
                   OR (    g_plan_dtls (1).obj_set_outside_period_flag = 'Y'
                       AND NVL (l_appraisals_in_progress, 'N') = 'N'
                      )
                  )
               THEN
                  log_message ('Within Objective setting deadline, so reopening the score
card.'            );

                   --included for fixing bug#6918115
                  -- IF g_plan_dtls(1).method_code = 'CAS' THEN
                  IF    (    g_plan_dtls (1).hierarchy_type_code = 'SUP'
                         AND g_plan_dtls (1).supervisor_id = j.person_id
                        )
                     OR (    g_plan_dtls (1).hierarchy_type_code = 'SUP_ASG'
                         AND g_plan_dtls (1).supervisor_assignment_id = j.assignment_id
                        )
                     OR (    g_plan_dtls (1).hierarchy_type_code IN ('POS')
                         AND g_plan_dtls (1).top_position_id = j.position_id
                        )
                     OR (    g_plan_dtls (1).hierarchy_type_code = 'ORG'
                         AND is_supervisor_in_org (g_plan_dtls (1).top_organization_id, j.person_id) =
                                                                                                   1
                        )
                  THEN
                     l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
                  ELSE
                     l_scorecard_status_code    := 'MGR';
                  END IF;

                  --ELSE
                   --    l_scorecard_status_code := 'MGR';
                  --END IF;
                  UPDATE per_personal_scorecards
                     SET status_code = l_scorecard_status_code
                   WHERE scorecard_id = g_selected_entities (i);

                  --l_sup_id := get_manager_id(j.person_id);
                  send_message_notification (j.person_id, 'WPM_SC_REOPEN_WKR_MSG', p_plan_id, NULL);
                  send_message_notification (j.supervisor_id,
                                             'WPM_SC_REOPEN_MGR_MSG',
                                             p_plan_id,
                                             j.scorecard_owner
                                            );
               ELSE
                  log_message
                     ('Score card is outside the Objective setting deadline, so
cannot be reopened.'
                     );
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  log_message ('Error reopening scorecard:' || l_sc_dtls || '.');
                  log_message (SQLERRM);
                  g_num_errors               := NVL (g_num_errors, 0) + 1;
            END;
         END LOOP;
      END LOOP;
   --
   END admin_reopen_scorecard;

--
   PROCEDURE admin_refresh_scorecard (p_plan_id IN NUMBER, p_effective_date IN DATE)
   IS
      CURSOR csr_sc_dtls (p_sc_id IN NUMBER, p_plan_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT pc.scorecard_id,
                pc.person_id,
                papf.full_name scorecard_owner,
                pc.status_code,
                papf.business_group_id,
                paaf.organization_id,
                paaf.position_id,
                paaf.job_id,
                pc.assignment_id,
                paaf.supervisor_id                                                    --  Bug7567079
           FROM per_personal_scorecards pc, per_people_f papf, per_assignments_f paaf
          WHERE pc.scorecard_id = p_sc_id
            AND pc.plan_id = p_plan_id
            AND pc.assignment_id = paaf.assignment_id
            AND pc.person_id = papf.person_id
            AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;

      l_sc_rec                  csr_sc_dtls%ROWTYPE;
      l_qual_obj_index          BINARY_INTEGER;
      l_scorecard_id            NUMBER;
      l_obj_date                DATE                                       := TRUNC (SYSDATE);
      l_scorecard_status_code   VARCHAR2 (30);
      l_check_elig              VARCHAR2 (10);

      CURSOR csr_sc_dup_obj (p_scorecard_id IN NUMBER, p_library_id IN NUMBER)
      IS
         SELECT 'Y'
           FROM per_objectives
          WHERE scorecard_id = p_scorecard_id AND copied_from_library_id = p_library_id;

      l_sc_dup_obj              VARCHAR2 (1);
      l_sup_id                  per_all_assignments_f.supervisor_id%TYPE   DEFAULT NULL;
   BEGIN
      IF (g_plan_dtls (1).automatic_allocation_flag = 'Y')
      THEN
         populate_qual_objectives (g_plan_dtls (1).start_date, g_plan_dtls (1).end_date);
      END IF;

      FOR i IN g_selected_entities.FIRST .. g_selected_entities.LAST
      LOOP
         l_scorecard_id             := g_selected_entities (i);
         log_message ('Processing Scorecard:' || l_scorecard_id);

         BEGIN
            OPEN csr_sc_dtls (l_scorecard_id, p_plan_id, p_effective_date);

            FETCH csr_sc_dtls
             INTO l_sc_rec;

            CLOSE csr_sc_dtls;

-- No need remove details. reevaluate objectives eligibility and insert any not existing ones
--       remove_scorecard_details(l_scorecard_id);
       --
            log_message ('select scorecard_id rec:' || l_sc_rec.scorecard_owner);

            IF (g_plan_dtls (1).automatic_allocation_flag = 'Y')
            THEN
               l_qual_obj_index           := g_qual_obj_tbl.FIRST;

               WHILE (l_qual_obj_index IS NOT NULL)
               LOOP
                  --
                  -- Enclose the call to eligibility within a block, so that if for any
                  -- reason the eligibility engine errors, then process can still
                  -- continue by skipping the current person/assignemnt as not eligible
                  --
                  log_message ('Evaluating: ' || g_qual_obj_tbl (l_qual_obj_index).objective_name);

                  BEGIN
                     --
                     ben_env_object.init (p_business_group_id      => l_sc_rec.business_group_id,
                                          p_thread_id              => NULL,
                                          p_chunk_size             => NULL,
                                          p_threads                => NULL,
                                          p_max_errors             => NULL,
                                          p_benefit_action_id      => NULL,
                                          p_effective_date         => l_obj_date
                                         );
                     --
                     --
                     l_check_elig               :=
                        ben_per_asg_elig.eligible (l_sc_rec.person_id,
                                                   l_sc_rec.assignment_id,
                                                   g_qual_obj_tbl (l_qual_obj_index).elig_obj_id,
                                                   l_obj_date,
                                                   l_sc_rec.business_group_id,
                                                   'Y' ---KMG -- Added to Allow CWK's
                                                  );
                     log_message ('eLIGI CHECK:' || l_check_elig);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        log_message (   'Error while evaluating eligibility for'
                                     || g_qual_obj_tbl (l_qual_obj_index).objective_name
                                    );
                        log_message (SQLERRM);
                        NULL;
                  END;

                  IF (l_check_elig = 'Y')
                  THEN
                     -- Create the objective
                     OPEN csr_sc_dup_obj (l_scorecard_id,
                                          g_qual_obj_tbl (l_qual_obj_index).objective_id
                                         );

                     FETCH csr_sc_dup_obj
                      INTO l_sc_dup_obj;

                     IF csr_sc_dup_obj%NOTFOUND
                     THEN
                        create_scorecard_objective
                           (p_effective_date              => p_effective_date,
                            p_scorecard_id                => l_scorecard_id,
                            p_business_group_id           => l_sc_rec.business_group_id,
                            p_person_id                   => l_sc_rec.person_id,
                            p_start_date                  => g_plan_dtls (1).start_date,
                            p_end_date                    => g_plan_dtls (1).end_date,
                            p_objective_name              => g_qual_obj_tbl (l_qual_obj_index).objective_name,
                            p_valid_from                  => g_qual_obj_tbl (l_qual_obj_index).valid_from,
                            p_valid_to                    => g_qual_obj_tbl (l_qual_obj_index).valid_to,
                            p_target_date                 => g_qual_obj_tbl (l_qual_obj_index).target_date,
                            p_copied_from_library_id      => g_qual_obj_tbl (l_qual_obj_index).objective_id,
                            p_next_review_date            => g_qual_obj_tbl (l_qual_obj_index).next_review_date,
                            p_group_code                  => g_qual_obj_tbl (l_qual_obj_index).group_code,
                            p_priority_code               => g_qual_obj_tbl (l_qual_obj_index).priority_code,
                            p_appraise_flag               => g_qual_obj_tbl (l_qual_obj_index).appraise_flag,
                            p_weighting_percent           => g_qual_obj_tbl (l_qual_obj_index).weighting_percent,
                            p_target_value                => g_qual_obj_tbl (l_qual_obj_index).target_value,
                            p_uom_code                    => g_qual_obj_tbl (l_qual_obj_index).uom_code,
                            p_measurement_style_code      => g_qual_obj_tbl (l_qual_obj_index).measurement_style_code,
                            p_measure_name                => g_qual_obj_tbl (l_qual_obj_index).measure_name,
                            p_measure_type_code           => g_qual_obj_tbl (l_qual_obj_index).measure_type_code,
                            p_measure_comments            => g_qual_obj_tbl (l_qual_obj_index).measure_comments,
                            p_details                     => g_qual_obj_tbl (l_qual_obj_index).details,
                            p_success_criteria            => g_qual_obj_tbl (l_qual_obj_index).success_criteria,
                            p_comments                    => g_qual_obj_tbl (l_qual_obj_index).comments
                           );
                     END IF;                  -- create only if the objective is not already copied.

                     CLOSE csr_sc_dup_obj;
                  END IF;

                  --
                  l_qual_obj_index           := g_qual_obj_tbl.NEXT (l_qual_obj_index);
               --
               END LOOP;
            END IF;                                                     --auto allocation flag = 'y'

            --
            IF g_plan_dtls (1).method_code = 'CAS'
            THEN
               IF    (    g_plan_dtls (1).hierarchy_type_code = 'SUP'
                      AND g_plan_dtls (1).supervisor_id = l_sc_rec.person_id
                     )
                  OR (    g_plan_dtls (1).hierarchy_type_code = 'SUP_ASG'
                      AND g_plan_dtls (1).supervisor_assignment_id = l_sc_rec.assignment_id
                     )
                  OR (    g_plan_dtls (1).hierarchy_type_code IN ('POS')
                      AND g_plan_dtls (1).top_position_id = l_sc_rec.position_id
                     )
                  OR (    g_plan_dtls (1).hierarchy_type_code = 'ORG'
                      AND is_supervisor_in_org (g_plan_dtls (1).top_organization_id,
                                                l_sc_rec.person_id
                                               ) = 1
                     )
               THEN
                  l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
               ELSE
                  l_scorecard_status_code    := 'NOT_STARTED_WITH_MGR';
               END IF;
            ELSE
               l_scorecard_status_code    := 'NOT_STARTED_WITH_WKR';
            END IF;

            UPDATE per_personal_scorecards
               SET status_code = l_scorecard_status_code
             WHERE scorecard_id = l_scorecard_id;

            --Bug7567079         l_sup_id := get_manager_id(l_sc_rec.person_id);
            send_message_notification (l_sc_rec.person_id, 'WPM_SC_REFRESH_WKR', p_plan_id, NULL);
            send_message_notification (l_sc_rec.supervisor_id,
                                       'WPM_SC_REFRESH_MGR',
                                       p_plan_id,
                                       l_sc_rec.scorecard_owner
                                      );
         EXCEPTION
            WHEN OTHERS
            THEN
               log_message ('Error refreshing
scorecard:' ||              l_sc_rec.scorecard_owner || '.');
               log_message (SQLERRM);
               g_num_errors               := NVL (g_num_errors, 0) + 1;
         END;
      END LOOP;
   END admin_refresh_scorecard;

--
--
   PROCEDURE plan_admin_actions (
      errbuf                     OUT NOCOPY      VARCHAR2,
      retcode                    OUT NOCOPY      NUMBER,
      p_effective_date           IN              VARCHAR2,
      p_plan_id                  IN              NUMBER,
      p_selected_entities_list   IN              VARCHAR2,
      p_task_code                IN              VARCHAR2
   )
   IS
      l_proc             VARCHAR2 (72) := g_package || 'plan_admin_actions';
      l_person_count     NUMBER;

      CURSOR csr_plan_dtls (p_plan_id IN NUMBER)
      IS
         SELECT *
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      l_effective_date   DATE;
   BEGIN
      --
      hr_utility.set_location ('Entering ' || l_proc, 10);
      g_plan_dtls.DELETE;

      OPEN csr_plan_dtls (p_plan_id);

      FETCH csr_plan_dtls
       INTO g_plan_dtls (1);

      CLOSE csr_plan_dtls;

      g_num_errors               := 0;

      --
      IF p_plan_id IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_PLAN_ID',
                                     p_argument_value      => p_plan_id
                                    );
      END IF;

      IF p_effective_date IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_EFFECTIVE_DATE',
                                     p_argument_value      => p_effective_date
                                    );
      END IF;

      IF p_selected_entities_list IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_SELECTED_ENTITIES_LIST',
                                     p_argument_value      => p_selected_entities_list
                                    );
      END IF;

      IF p_task_code IS NULL
      THEN
         hr_api.mandatory_arg_error (p_api_name            => 'PLAN_ADMIN_ACTIONS_CP',
                                     p_argument            => 'P_TASK_CODE',
                                     p_argument_value      => p_task_code
                                    );
      END IF;

      l_effective_date           := fnd_date.canonical_to_date (p_effective_date);

      IF hr_api.not_exists_in_hr_lookups (p_effective_date      => l_effective_date,
                                          p_lookup_type         => 'HR_WPM_ADMIN_ACTIONS',
                                          p_lookup_code         => p_task_code
                                         )
      THEN
         log_message ('Invalid task code selected.' || p_task_code);
         hr_utility.set_message (800, 'HR_WPM_TASK_CODE_NOT_EXISTS');
         hr_utility.raise_error;
      END IF;

      l_person_count             :=
                              string_to_array (p_selected_entities_list      => p_selected_entities_list);
      log_message ('Number of selected persons: ' || l_person_count);

      IF p_task_code = 'ENROLL_PLAN'
      THEN
         admin_enroll_into_plan (p_plan_id => p_plan_id, p_effective_date => l_effective_date);
      ELSIF p_task_code = 'REOPEN_APPRAISALS'
      THEN
         admin_reopen_plan_appraisals (p_plan_id             => p_plan_id,
                                       p_effective_date      => l_effective_date);
      ELSIF p_task_code = 'REMOVE_SC'
      THEN
         admin_remove_scorecard (p_plan_id => p_plan_id, p_effective_date => l_effective_date);
      ELSIF p_task_code = 'REOPEN_SC'
      THEN
         admin_reopen_scorecard (p_plan_id => p_plan_id, p_effective_date => l_effective_date);
      ELSIF p_task_code = 'REFRESH_SC'
      THEN
         admin_refresh_scorecard (p_plan_id => p_plan_id, p_effective_date => l_effective_date);
      ELSE
         log_message ('Invalid task code selected.' || p_task_code);
         hr_utility.set_message (800, 'HR_WPM_TASK_CODE_NOT_VALID');
         hr_utility.raise_error;
      END IF;

      --
      --
      COMMIT;

      IF g_num_errors > 0
      THEN
         log_message ('No. of persons errored: ' || g_num_errors);
         retcode                    := warning;
         errbuf                     :=
            'Errors occured processing the selected persons. Pl. check the
concurrent log for details.';
      END IF;

      hr_utility.set_location ('Leaving ' || l_proc, 100);
   EXCEPTION
      WHEN OTHERS
      THEN
         log_message ('Error Completing the process.');
         errbuf                     := SQLERRM;
         retcode                    := error;
         ROLLBACK;
         RAISE;
   END plan_admin_actions;

--
   PROCEDURE send_message_notification (
      p_person_id   IN   NUMBER,
      p_message          VARCHAR2,
      p_plan_id          per_perf_mgmt_plans.plan_id%TYPE DEFAULT NULL,
      p_full_name        per_all_people_f.full_name%TYPE
   )
   IS
      CURSOR get_role (person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT wf.NAME role_name
           FROM wf_roles wf
          WHERE wf.orig_system = 'PER' AND wf.orig_system_id = person_id;

      CURSOR csr_plan_det (p_plan_id per_perf_mgmt_plans.plan_id%TYPE)
      IS
         SELECT plan_name,
                administrator_person_id
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      l_plan_rec             csr_plan_det%ROWTYPE;
      to_role_not_exists     EXCEPTION;
      from_role_not_exists   EXCEPTION;
      err_msg                VARCHAR2 (2000);
      l_to_role              wf_local_roles.NAME%TYPE   DEFAULT NULL;
      l_from_role            wf_local_roles.NAME%TYPE   DEFAULT NULL;
      ln_notification_id     NUMBER;
   BEGIN
      OPEN get_role (p_person_id);

      FETCH get_role
       INTO l_to_role;

      CLOSE get_role;

      IF l_to_role IS NULL
      THEN
         RAISE to_role_not_exists;
      END IF;

      IF p_plan_id IS NOT NULL
      THEN
         OPEN csr_plan_det (p_plan_id);

         FETCH csr_plan_det
          INTO l_plan_rec;

         CLOSE csr_plan_det;
      END IF;

      OPEN get_role (l_plan_rec.administrator_person_id);

      FETCH get_role
       INTO l_from_role;

      CLOSE get_role;

      IF l_from_role IS NULL
      THEN
         RAISE from_role_not_exists;
      END IF;

      OPEN get_role (p_person_id);

      FETCH get_role
       INTO l_to_role;

      CLOSE get_role;

      ln_notification_id         :=
         wf_notification.send (ROLE              => l_to_role,
                               msg_type          => 'HRWPM',
                               --  msg_name => 'HR_WPM_SC_REMOVE',
                               msg_name          => p_message,
                               callback          => NULL,
                               CONTEXT           => NULL,
                               send_comment      => NULL,
                               priority          => 50
                              );
      wf_notification.setattrtext (ln_notification_id, '#FROM_ROLE', l_from_role);

      IF (   p_message = 'WPM_AP_ENROLL_MSG'
          OR p_message = 'WPM_SC_REMOVE_MSG'
          OR p_message = 'WPM_PLAN_ROLLBACK_MSG'
         )
      THEN
         wf_notification.setattrtext (ln_notification_id, 'HR_WPM_PLAN_NAME', l_plan_rec.plan_name);
      ELSIF p_message = 'WPM_SC_REOPEN_MGR_MSG' OR p_message = 'WPM_SC_REFRESH_MGR'
      THEN
         wf_notification.setattrtext (ln_notification_id, 'SCORE_CARD_EMP_NAME', p_full_name);
      ELSIF p_message = 'WPM_APPRAISAL_REOPEN_MGR_MSG'
      THEN
         wf_notification.setattrtext (ln_notification_id, 'APPRAISAL_EMP_NAME', p_full_name);
      END IF;

      wf_notification.denormalize_notification (ln_notification_id, NULL, NULL);
   EXCEPTION
      WHEN OTHERS
      THEN
         err_msg                    :=
                                   SUBSTR ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM, 1,
                                           255);
   END send_message_notification;

   FUNCTION get_manager_id (
      p_person_id       IN   per_all_assignments_f.person_id%TYPE,
      p_assignment_id        per_all_assignments_f.assignment_id%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR get_supervisor_id (person_id per_all_people_f.person_id%TYPE)
      IS
         --8262552 Changes to get the correct supervisor Id based on assignment Id
         SELECT supervisor_id
           FROM per_all_assignments_f
          WHERE person_id = p_person_id
            AND TRUNC (SYSDATE) BETWEEN effective_start_date AND effective_end_date
            AND assignment_id = p_assignment_id;

      l_super_visor_id   per_all_assignments_f.supervisor_id%TYPE;
      l_role             wf_local_roles.NAME%TYPE                   DEFAULT NULL;
   BEGIN
      OPEN get_supervisor_id (p_person_id);

      FETCH get_supervisor_id
       INTO l_super_visor_id;

      CLOSE get_supervisor_id;

      RETURN l_super_visor_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END get_manager_id;

   --
   PROCEDURE send_fyi_ntf (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2,
      rolename    IN              VARCHAR2
   )
   IS
      prole                wf_users.NAME%TYPE;                                      -- Fix 3210283.
      l_role_name          wf_roles.NAME%TYPE;
      expand_role          VARCHAR2 (1);
      l_msg                VARCHAR2 (30);
      -- Start changes for bug#5903006
      l_obj_setting_flag   VARCHAR2 (30);
  --end changes for bug#5903006
--
   BEGIN
      IF (funcmode <> wf_engine.eng_run)
      THEN
         resultout                  := wf_engine.eng_null;
         RETURN;
      END IF;

      l_role_name                := rolename;
      l_msg                      :=
                    UPPER (wf_engine.getactivityattrtext (itemtype, itemkey, actid, 'MESSAGE_NAME'));
      -- Start Changes for bug#5903006
      l_obj_setting_flag         :=
         wf_engine.getitemattrtext (itemtype      => itemtype,
                                    itemkey       => itemkey,
                                    aname         => 'HR_WPM_OBJ_SETTING_FLAG'
                                   );

      IF NVL (l_obj_setting_flag, 'N') = 'N'
      THEN
         IF l_msg = 'WPM_PLAN_PUB_ALL_POP_MSG'
         THEN
            l_msg                      := 'WPM_PLAN_PUB_ALL_NO_OBJ_MSG';
         ELSIF l_msg = 'WPM_PLAN_PUB_NON_TOP_POP_MSG'
         THEN
            l_msg                      := 'WPM_PLAN_PUB_NON_TOP_NOOBJ_MSG';
         ELSIF l_msg = 'WPM_PLAN_PUB_TOP_POP_MSG'
         THEN
            l_msg                      := 'WPM_PLAN_PUB_TOP_NO_OBJ_MSG';
         END IF;
      END IF;

      -- End Changes for bug#5903006
      expand_role                := 'N';

      IF l_role_name IS NULL
      THEN
         wf_core.token ('TYPE', itemtype);
         wf_core.token ('ACTID', TO_CHAR (actid));
         wf_core.RAISE ('WFENG_NOTIFICATION_PERFORMER');
      END IF;

      --
      wf_engine_util.notification_send (itemtype,
                                        itemkey,
                                        actid,
                                        l_msg,
                                        'HRWPM',
                                        l_role_name,
                                        expand_role,
                                        resultout
                                       );
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END send_fyi_ntf;

--
   PROCEDURE notify_plan_population (
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   )
   IS
      l_plan_id            NUMBER;
      l_role_name          wf_roles.NAME%TYPE;
      l_role_displayname   wf_roles.display_name%TYPE;
      --
      l_member_index       NUMBER;
      l_result             VARCHAR2 (100);
      l_count              NUMBER                       := 0;
      l_sc_exists          VARCHAR2 (20);

      CURSOR csr_chk_sc_exists (p_assignment_id NUMBER, p_plan_id NUMBER)
      IS
         SELECT 'Y'
           FROM DUAL
          WHERE EXISTS (SELECT 'X'
                          FROM per_personal_scorecards
                         WHERE plan_id = p_plan_id AND assignment_id = p_assignment_id);
   BEGIN
      --
      IF (funcmode = 'RUN')
      THEN
         -- Get the workwlow attribute values
         l_plan_id                  :=
            wf_engine.getitemattrtext (itemtype      => itemtype,
                                       itemkey       => itemkey,
                                       aname         => 'WPM_PLAN_ID'
                                      );

         -- If plan population is known
         IF (g_plan_pop_known_t (l_plan_id))
         THEN
            l_member_index             := g_qual_pop_tbl.FIRST;

            WHILE (l_member_index IS NOT NULL)
            LOOP
               l_sc_exists                := 'N';

--changed by schowdhu 8865480 08-Sep-09
               OPEN csr_chk_sc_exists (l_member_index, l_plan_id);

               FETCH csr_chk_sc_exists
                INTO l_sc_exists;

               CLOSE csr_chk_sc_exists;

               IF NVL (l_sc_exists, 'N') = 'Y'
               THEN
                  -- Get the Role for the Owner
                  wf_directory.getrolename
                                     (p_orig_system         => 'PER',
                                      p_orig_system_id      => g_qual_pop_tbl (l_member_index).person_id,
                                      p_name                => l_role_name,
                                      p_display_name        => l_role_displayname
                                     );

                  --
                  IF (l_role_name IS NOT NULL)
                  THEN
                     --
                     send_fyi_ntf (itemtype, itemkey, actid, funcmode, l_result, l_role_name);
                     l_count                    := l_count + 1;
                  END IF;
               END IF;                                                              --  IF sc exists

               --
               l_member_index             := g_qual_pop_tbl.NEXT (l_member_index);
            --
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         wf_core.CONTEXT ('HR_PERF_MGMT_PLANS_INTERNAL',
                          'POPULATE_PLAN_MEMBERS_CACHE',
                          itemtype,
                          itemkey,
                          TO_CHAR (actid),
                          funcmode
                         );
         RAISE;
   END notify_plan_population;
--============================================
END hr_perf_mgmt_plan_internal;

/
