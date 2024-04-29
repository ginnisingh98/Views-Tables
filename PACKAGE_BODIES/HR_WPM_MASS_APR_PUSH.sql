--------------------------------------------------------
--  DDL for Package Body HR_WPM_MASS_APR_PUSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WPM_MASS_APR_PUSH" AS
/* $Header: pewpmaprpush.pkb 120.20.12010000.30 2010/05/13 13:22:52 kgowripe ship $ */
  -- Package Variables
  --
   g_package                     VARCHAR2 (33)                           := 'hr_wpm_mass_apr_push.';
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
   -- Private user-defined types.
   --
   -- Used for populating plan appraisal periods
   TYPE g_plan_aprsl_pds_r IS RECORD (
      appraisal_period_id         per_appraisal_periods.appraisal_period_id%TYPE,
      appraisal_template_id       per_appraisal_periods.appraisal_template_id%TYPE,
      start_date                  per_appraisal_periods.start_date%TYPE,
      end_date                    per_appraisal_periods.end_date%TYPE,
      task_start_date             per_appraisal_periods.task_start_date%TYPE,
      task_end_date               per_appraisal_periods.task_end_date%TYPE,
      initiator_code              per_appraisal_periods.initiator_code%TYPE,
      appraisal_system_type       per_appraisal_periods.appraisal_system_type%TYPE,
      auto_conc_process           per_appraisal_periods.auto_conc_process%TYPE,
      days_before_task_st_dt      per_appraisal_periods.days_before_task_st_dt%TYPE,
      appraisal_assmt_status      per_appraisal_periods.appraisal_assmt_status%TYPE,
      appraisal_type              per_appraisal_periods.appraisal_type%TYPE,
      participation_type          per_appraisal_periods.participation_type%TYPE,
      questionnaire_template_id   per_appraisal_periods.questionnaire_template_id%TYPE
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
      effective_state_date   per_all_assignments_f.effective_start_date%TYPE,
      empl_start_date        per_all_people_f.effective_start_date%TYPE,
      empl_end_date          per_all_people_f.effective_end_date%TYPE,
      person_id              per_all_people_f.person_id%TYPE
   );

   --
   -- Following is added with more details to be captured
   -- done by tpapired for 115.20 version of this file
   TYPE appraisal_templ_info IS RECORD (
      appraisal_template_id      per_appraisal_templates.appraisal_template_id%TYPE,
      assessment_type_id         per_appraisal_templates.assessment_type_id%TYPE,
      objective_asmnt_type_id    per_appraisal_templates.objective_asmnt_type_id%TYPE,
      business_group_id          per_appraisal_templates.business_group_id%TYPE,
      show_competency_ratings    per_appraisal_templates.show_competency_ratings%TYPE,
      show_objective_ratings     per_appraisal_templates.show_objective_ratings%TYPE,
      show_questionnaire_info    per_appraisal_templates.show_questionnaire_info%TYPE,
      show_participant_details   per_appraisal_templates.show_participant_details%TYPE,
      show_participant_ratings   per_appraisal_templates.show_participant_ratings%TYPE,
      show_participant_names     per_appraisal_templates.show_participant_names%TYPE,
      show_overall_ratings       per_appraisal_templates.show_overall_ratings%TYPE,
      disable_provide_feed       per_appraisal_templates.provide_overall_feedback%TYPE,
      --Bug7393131
      show_overall_comments      per_appraisal_templates.show_overall_comments%TYPE
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
      --
      IF p_action_parameter_group_id IS NOT NULL
      THEN
         l_string                   :=
               'BEGIN
                 pay_core_utils.set_pap_group_id(p_pap_group_id => '
            || TO_CHAR (p_action_parameter_group_id)
            || ');
             END;';

         EXECUTE IMMEDIATE l_string;
      END IF;

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
   PROCEDURE populate_plan_apprsl_periods (p_plan_id IN NUMBER, p_appr_period_id IN NUMBER)
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
                appraisal_type,
                participation_type,
                questionnaire_template_id
           FROM per_appraisal_periods pap
          WHERE pap.plan_id = p_plan_id AND pap.appraisal_period_id = p_appr_period_id;
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

      IF g_dbg
      THEN
         op (' p_appraisal_sys_type = ' || p_appraisal_sys_type, g_debug_log);
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
         l_system_type              := '%' || p_appraisal_sys_type || '%';
      ELSIF (p_appr_initiator_code = 'EMP' AND l_appraisal_empl_menu IS NOT NULL)
      THEN
         l_selected_menu            := l_appraisal_empl_menu;
         p_appraisal_sys_type       := p_appr_initiator_code || p_appraisal_sys_type;
         l_system_type              := '%' || p_appraisal_sys_type || '%';
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
--8239025 Modified the cursors
      CURSOR get_asgn_req_comps_bus (p_enterprise_id NUMBER)
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
            AND hrl.lookup_type = 'STRUCTURE_TYPE'
            AND hrl.lookup_code = 'BUS'
            AND pce.proficiency_level_id = r1.rating_level_id(+)
            AND pce.high_proficiency_level_id = r2.rating_level_id(+)
            AND pce.business_group_id = p_enterprise_id
            AND pce.enterprise_id = p_enterprise_id
            AND pce.job_id IS NULL
            AND pce.organization_id IS NULL
            AND pce.position_id IS NULL;

      CURSOR get_asgn_req_comps_org (p_in_org_id NUMBER, p_enterprise_id NUMBER)
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
            AND hrl.lookup_type = 'STRUCTURE_TYPE'
            AND hrl.lookup_code = 'ORG'
            AND pce.proficiency_level_id = r1.rating_level_id(+)
            AND pce.high_proficiency_level_id = r2.rating_level_id(+)
            AND pce.business_group_id = p_enterprise_id
            AND pce.organization_id = p_in_org_id
            AND pce.enterprise_id IS NULL
            AND pce.job_id IS NULL
            AND pce.position_id IS NULL;

      CURSOR get_asgn_req_comps_pos (p_in_pos_id NUMBER, p_enterprise_id NUMBER)
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
            AND hrl.lookup_type = 'STRUCTURE_TYPE'
            AND hrl.lookup_code = 'POS'
            AND pce.proficiency_level_id = r1.rating_level_id(+)
            AND pce.high_proficiency_level_id = r2.rating_level_id(+)
            AND pce.business_group_id = p_enterprise_id
            AND pce.position_id = p_in_pos_id
            AND pce.organization_id IS NULL
            AND pce.job_id IS NULL
            AND pce.enterprise_id IS NULL;

      CURSOR get_asgn_req_comps_job (p_in_job_id NUMBER, p_enterprise_id NUMBER)
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
            AND hrl.lookup_type = 'STRUCTURE_TYPE'
            AND hrl.lookup_code = 'JOB'
            AND pce.proficiency_level_id = r1.rating_level_id(+)
            AND pce.high_proficiency_level_id = r2.rating_level_id(+)
            AND pce.business_group_id = p_enterprise_id
            AND pce.job_id = p_in_job_id
            AND pce.organization_id IS NULL
            AND pce.position_id IS NULL
            AND pce.enterprise_id IS NULL;

      l_mat_comp_table        sel_comp_tab;
      i                       INTEGER      DEFAULT 0;
      l_temp_comp_table       sel_comp_tab;
      l_comp_index            INTEGER;
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
         op ('p_business_group_id = ' || p_enterprise_id, g_debug_log);
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

--8239025 Fix Starts
      FOR pos_rec IN get_asgn_req_comps_pos (p_position_id, p_enterprise_id)
      LOOP
         l_temp_comp_table (pos_rec.competence_id) := pos_rec;
      END LOOP;

      FOR job_rec IN get_asgn_req_comps_job (p_job_id, p_enterprise_id)
      LOOP
         IF NOT l_temp_comp_table.EXISTS (job_rec.competence_id)
         THEN
            l_temp_comp_table (job_rec.competence_id) := job_rec;
         END IF;
      END LOOP;

      FOR org_rec IN get_asgn_req_comps_org (p_organization_id, p_enterprise_id)
      LOOP
         IF NOT l_temp_comp_table.EXISTS (org_rec.competence_id)
         THEN
            l_temp_comp_table (org_rec.competence_id) := org_rec;
         END IF;
      END LOOP;

      FOR bus_rec IN get_asgn_req_comps_bus (p_enterprise_id)
      LOOP
         IF NOT l_temp_comp_table.EXISTS (bus_rec.competence_id)
         THEN
            l_temp_comp_table (bus_rec.competence_id) := bus_rec;
         END IF;
      END LOOP;

      l_comp_index               := l_temp_comp_table.FIRST;
      i                          := 1;

      WHILE (l_comp_index IS NOT NULL)
      LOOP
         IF g_dbg
         THEN
            op (' from overriding comp = ' || l_temp_comp_table (l_comp_index).NAME, g_debug_log);
         END IF;

         l_sel_comp_table (i)       := l_temp_comp_table (l_comp_index);
         l_comp_index               := l_temp_comp_table.NEXT (l_comp_index);
         i                          := i + 1;
      END LOOP;
   END apply_overridding_rules;

--
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
      p_score_card_id                               per_personal_scorecards.scorecard_id%TYPE,
      p_appraisal_templ_id                          per_appraisal_templates.appraisal_template_id%TYPE,
      p_effective_date                              DATE,
      p_appraisal_start_date                        DATE,
      p_appraisal_end_date                          DATE,
      p_appraisal_status                            per_appraisals.status%TYPE DEFAULT 'PLANNED',
      p_type                                        per_appraisals.TYPE%TYPE DEFAULT NULL,
      p_appraisal_date                              per_appraisals.appraisal_date%TYPE,
--       p_appraisal_system_status per_appraisals.appraisal_system_status%TYPE,
      p_plan_id                                     NUMBER,
      p_next_appraisal_date                         per_appraisals.next_appraisal_date%TYPE DEFAULT NULL,
      p_status                                      per_appraisals.status%TYPE DEFAULT NULL,
      p_comments                                    per_appraisals.comments%TYPE DEFAULT NULL,
      p_appraisee_access                            per_appraisals.appraisee_access%TYPE DEFAULT NULL,
      p_appraisal_initiator                         per_appraisal_periods.initiator_code%TYPE,
      p_appraisal_system_type       IN              per_appraisal_periods.appraisal_system_type%TYPE,
      p_participation_type          IN              per_appraisal_periods.participation_type%TYPE DEFAULT NULL,
      p_questionnaire_template_id   IN              per_appraisal_periods.questionnaire_template_id%TYPE DEFAULT NULL,
      p_return_status               OUT NOCOPY      VARCHAR2
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

      --changed cursor for fixing 6924829
      CURSOR get_assignment_info (p_person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT paf.assignment_id,
                paf.business_group_id,
                paf.grade_id,
                paf.position_id,
                paf.job_id,
                paf.organization_id,
                paf.supervisor_id,
                paf.effective_start_date,
                pps.date_start empl_start_date,
                ppf.effective_end_date empl_end_date,
                ppf.person_id
           FROM per_all_assignments_f paf, per_all_people_f ppf, per_periods_of_service pps
          WHERE paf.person_id = p_person_id                                        --8780710 bug fix
            AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date AND paf.effective_end_date
            AND paf.person_id = ppf.person_id
            AND paf.assignment_type = 'E'
            AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND pps.period_of_service_id = paf.period_of_service_id
            AND paf.primary_flag = 'Y'
         UNION ALL
         SELECT paf.assignment_id,
                paf.business_group_id,
                paf.grade_id,
                paf.position_id,
                paf.job_id,
                paf.organization_id,
                paf.supervisor_id,
                paf.effective_start_date,
                pps.date_start empl_start_date,
                ppf.effective_end_date empl_end_date,
                ppf.person_id
           FROM per_all_assignments_f paf, per_all_people_f ppf, per_periods_of_placement pps
          WHERE paf.person_id = p_person_id                                        --8780710 bug fix
            AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date AND paf.effective_end_date
            AND paf.assignment_type = 'C'
            AND paf.person_id = ppf.person_id
            AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND pps.date_start = paf.period_of_placement_date_start
            AND pps.person_id = paf.person_id
            AND paf.primary_flag = 'Y';                                            --8780710 bug fix

      -- 8529866 Bug Fix
      CURSOR get_ma_start_date (p_ma_person_id per_people_f.person_id%TYPE)
      IS
         SELECT date_start
           FROM per_periods_of_service
          WHERE person_id = p_ma_person_id
            AND TRUNC (SYSDATE) BETWEEN date_start AND NVL (actual_termination_date,
                                                            TRUNC (SYSDATE))
         UNION ALL
         SELECT date_start
           FROM per_periods_of_placement
          WHERE person_id = p_ma_person_id
            AND TRUNC (SYSDATE) BETWEEN date_start AND NVL (actual_termination_date,
                                                            TRUNC (SYSDATE));

      CURSOR get_appraisal_templ_info (
         p_appraisal_templ_id   per_appraisals.appraisal_template_id%TYPE
      )
      IS
         SELECT appraisal_template_id,
                assessment_type_id,
                objective_asmnt_type_id,
                business_group_id,
                show_competency_ratings,
                show_objective_ratings,
                show_questionnaire_info,
                show_participant_details,
                show_participant_ratings,
                show_participant_names,
                show_overall_ratings,
                provide_overall_feedback,                                              -- Bug7393131
                show_overall_comments
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

      CURSOR get_sec_asg_supervisors (p_person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT DISTINCT (supervisor_id)
                    FROM per_all_assignments_f
                   WHERE person_id = p_person_id AND primary_flag <> 'Y';

      CURSOR find_appraisal (
         p_plan_id               per_perf_mgmt_plans.plan_id%TYPE,
         p_appr_prd_st_dt        per_appraisals.appraisal_period_start_date%TYPE,
         p_appr_prd_ed_dt        per_appraisals.appraisal_period_end_date%TYPE,
         p_appraisee_person_id   per_appraisals.appraisee_person_id%TYPE,
          --     p_appraiser_person_id per_appraisals.appraiser_person_id%TYPE,
         --      p_main_appraiser_id per_appraisals.main_appraiser_id%TYPE,
         p_appr_templ_id         per_appraisals.appraisal_template_id%TYPE
      )
      IS
         SELECT appraisal_id,
                appraisal_system_status
           FROM per_appraisals
          WHERE plan_id = p_plan_id
            AND appraisal_period_start_date = p_appr_prd_st_dt
            --5194541 to_date(p_appr_prd_st_dt,'RRRR-MM-DD')
            AND appraisal_period_end_date = p_appr_prd_ed_dt
            --5194541 to_date(p_appr_prd_ed_dt,'RRRR-MM-DD')
            AND appraisee_person_id = p_appraisee_person_id
            AND appraisal_system_status <> 'TRANSFER_OUT'                                 -- 7321947
            --   and appraiser_person_id = p_appraiser_person_id
            --   and main_appraiser_id = p_main_appraiser_id
            AND appraisal_template_id = p_appr_templ_id;

      l_appraisal_status              VARCHAR2 (20);
      l_scorecard_info                scorecard_info;
      no_score_card_with_this_id      EXCEPTION;
      l_assignment_info               assignment_info;
      no_assignment_with_this_id      EXCEPTION;
      l_ma_start_date                 per_appraisals.appraisal_date%TYPE;
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
      l_appraisal_sys_type            per_appraisal_periods.appraisal_system_type%TYPE;
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
      l_appraiser_id                  per_people_f.person_id%TYPE;
      l_main_appraiser_id             per_people_f.person_id%TYPE;
      l_found_appraisal_id            per_appraisals.appraisal_id%TYPE;
      l_found_appraisal               BOOLEAN;
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
      l_appraisal_period_start_date   per_appraisals.appraisal_period_start_date%TYPE;
      l_appraisal_date                per_appraisals.appraisal_date%TYPE;
	  l_participant_id                per_participants.participant_id%TYPE;
      l_default_participant           VARCHAR2 (30)               := NVL (p_participation_type, 'N');
   BEGIN
      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_regular_log, 10);
      END IF;

      IF g_dbg
      THEN
         op ('Processing Appraisal for scorecard ' || p_score_card_id, g_debug_log, 10);
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
         -- WPM Logging Changes
         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
         g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := fnd_message.GET_NUMBER('PER','NO_SCORE_CARD_WITH_THIS_ID');
         -- g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'NO_SCORE_CARD_WITH_THIS_ID';
        -- WPM Logging Changes Post Review
        g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'THERE IS NO SCORECARD WITH THIS ID';
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

         fnd_file.put_line (fnd_file.LOG, 'NO_SCORE_CARD_WITH_THIS_ID');
         RAISE no_score_card_with_this_id;
      END IF;

      IF g_dbg
      THEN
         op (' get_scorecard_info ' || l_proc, g_debug_log, 20);
      END IF;

      l_assignment_info.assignment_id := NULL;

      OPEN get_assignment_info (l_scorecard_info.person_id);

      FETCH get_assignment_info
       INTO l_assignment_info;

      CLOSE get_assignment_info;

      IF (l_assignment_info.assignment_id IS NULL)
      THEN
         -- WPM Logging Changes
         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
         g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := fnd_message.GET_NUMBER('PER','NO_ASSIGNMENT_WITH_THIS_ID');
         -- g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'NO_ASSIGNMENT_WITH_THIS_ID';
         -- WPM Logging Changes Post Review
         g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'THERE IS NO ASSIGNMENT WITH THIS ID';
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

         fnd_file.put_line (fnd_file.LOG, 'NO_ASSIGNMENT_WITH_THIS_ID');
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
         -- WPM Logging Changes
         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
         g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := fnd_message.GET_NUMBER('PER','NO_APPRL_TEMPL_WITH_THIS_ID');
         --     g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'NO_APPRL_TEMPL_WITH_THIS_ID';
         -- WPM Logging Changes Post Review
         g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'THERE IS NO APPRAISAL TEMPLATE WITH THIS ID';
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

         fnd_file.put_line (fnd_file.LOG, 'NO_APPRL_TEMPL_WITH_THIS_ID');
         RAISE no_apprl_templ_with_this_id;
      END IF;

      IF g_dbg
      THEN
         op (' get_appraisal_templ_info ' || l_proc, g_debug_log, 20);
      END IF;

      l_appraisal_sys_type       := p_appraisal_system_type;
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
         -- WPM Logging Changes
         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
         g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := fnd_message.GET_NUMBER('PER','APPRAISAL_SETUP_ISSUE');
         -- g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'APPRAISAL_SETUP_ISSUE';
         -- WPM Logging Changes Post Review
         g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'THERE IS AN APPRAISAL SET UP ISSUE';
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

         fnd_file.put_line (fnd_file.LOG, 'APPRAISAL_SETUP_ISSUE');
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
      IF (p_appraisal_initiator = 'MGR')
      THEN
         l_appraiser_id             := l_assignment_info.supervisor_id;
         l_main_appraiser_id        := l_assignment_info.supervisor_id;
      ELSIF (p_appraisal_initiator = 'EMP')
      THEN
         l_appraiser_id             := l_scorecard_info.person_id;
         l_main_appraiser_id        := l_assignment_info.supervisor_id;
      END IF;

      -- defaulting with employment start date if new joinee has joined after mass appraisal push
      IF (l_assignment_info.empl_start_date > p_appraisal_start_date)
      THEN
         l_appraisal_period_start_date := l_assignment_info.empl_start_date;
      ELSE
         l_appraisal_period_start_date := p_appraisal_start_date;
      END IF;

      -- validate it with MGR joining date as well bug 8529866
      OPEN get_ma_start_date (l_main_appraiser_id);

      FETCH get_ma_start_date
       INTO l_ma_start_date;

      CLOSE get_ma_start_date;

      /* commenting these changes for 8712025 bug fix
         IF (l_ma_start_date > l_appraisal_period_start_date)
         THEN
            l_appraisal_period_start_date := l_ma_start_date;
         END IF;
      */

      --- same logic goes for appraisal date which is defaulted as task start date in appraisal_push function
      IF (l_assignment_info.empl_start_date > p_appraisal_date)
      THEN
         l_appraisal_date           := l_assignment_info.empl_start_date;
      ELSE
         l_appraisal_date           := p_appraisal_date;
      END IF;

      -- validate it with MGR joining date as well bug 8529866
      IF (l_ma_start_date > l_appraisal_date)
      THEN
         l_appraisal_date           := l_ma_start_date;
      END IF;

      OPEN find_appraisal (p_plan_id,
                           l_appraisal_period_start_date,
                           p_appraisal_end_date,
                           l_scorecard_info.person_id,
                           -- l_appraiser_id, l_main_appraiser_id,
                           p_appraisal_templ_id
                          );

      FETCH find_appraisal
       INTO l_found_appraisal_id,
            l_appraisal_status;

      IF find_appraisal%FOUND
      THEN
         l_found_appraisal          := TRUE;
         -- WPM Logging Changes Post Review
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).transaction_ref_id := l_found_appraisal_id;
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'SUCCESS'; -- Success

         IF g_dbg
         THEN
            op (   ' find_appraisal: Found Appraisal for this Person '
                || l_scorecard_info.person_id
                || ':'
                || l_found_appraisal_id,
                g_debug_log,
                20
               );
         END IF;
      ELSE
         l_found_appraisal          := FALSE;
      END IF;

      CLOSE find_appraisal;

      --- added this part of the code to attach appraisal id to objectives
      --- of per_objectives records which are populated due to new eligible objectives in scorecards
      --- for already created appraisals.If new objectives are added to an existing scorecard
      --- that shud also be added to appraisals.Bug no 6015946

      --  if( l_found_appraisal and l_appraisal_status <> 'COMPLETED') then
-- 7475464 Bug Fix changes, i.e adding APPRFEEDBACK check inadditon to
-- completed appraisals check
      IF (l_found_appraisal AND l_appraisal_status NOT IN ('COMPLETED', 'APPRFEEDBACK'))
      THEN
-- added the completed appraisals check because if the plan is republished
-- within the same appraisal period.. appraisals will be found and objectives
-- with scorecard of the person will be updated with the appraisal_id.BUT
-- if the appraisal is already completed, It will have duplicate rows for
-- the same objective( one for appraisal and one for scorecard)
-- if the objectives with scorecard is again updated , then we will see
-- duplicate objectives in completed appraisal
--  we can restrict the view in completed appraisals also by scorecard!=null
--  check BUT this is not tried
--  as if appraisal is reopened we may lead to data issues.
         FOR objectives IN get_scorecard_objectives (p_score_card_id)
         LOOP
            BEGIN
               hr_objectives_api.update_objective
                                    (p_validate                         => FALSE,
                                     p_objective_id                     => objectives.objective_id,
                                     p_object_version_number            => objectives.object_version_number,
                                     p_effective_date                   => p_effective_date,
                                     p_appraisal_id                     => l_found_appraisal_id,
                                     -- modified by AM  --
                                     p_weighting_over_100_warning       => l_weighting_over_100_warning,
                                     p_weighting_appraisal_warning      => l_weighting_appraisal_warning
                                    );
            EXCEPTION
               WHEN OTHERS
               THEN
         -- WPM Logging Changes
         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
         g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
         g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

                  -- to be added a message to identify update objective error
                  IF g_dbg
                  THEN
                     op (SQLERRM, g_regular_log);
                  END IF;
            END;
         END LOOP;
      END IF;

      ---
      --- End of code new for Bug no 6015946
      ---
      IF (NOT l_found_appraisal)
      THEN
         IF l_main_appraiser_id IS NULL
         THEN
         -- WPM Logging Changes
         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
         -- g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := fnd_message.GET_NUMBER('PER','HR_50297_WPM_CP_ERROR');
         -- g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'HR_50297_WPM_CP_ERROR';
         -- WPM Logging Changes Post Review
         g_wpm_person_actions(log_records_index).MESSAGE_TEXT := 'UNABLE TO CREATE APPRAISAL FOR THIS PERSON AS MAIN APPRAISER COULD NOT BE IDENTIFIED';
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

            fnd_file.put_line (fnd_file.LOG,
                                  'Unable to create appraisal for : '
                               || l_scorecard_info.person_id
                               || ' as main appraiser could not be identified.'
                              );
            fnd_message.set_name ('PER', 'HR_50297_WPM_CP_ERROR');
            g_cp_error_txt             := NVL (fnd_message.get, 'HR_50297_WPM_CP_ERROR');
            g_retcode                  := warning;
            g_errbuf                   := g_cp_error_txt;
            g_num_errors               := g_num_errors + 1;

            --
            IF g_num_errors > g_max_errors
            THEN
               fnd_message.set_name ('PER', 'HR_50298_WPM_MAX_ERRORS');
               g_error_txt                := NVL (fnd_message.get, 'HR_50298_WPM_MAX_ERRORS');
               g_retcode                  := error;
               g_errbuf                   := g_error_txt;
               fnd_message.raise_error;                                                    --RAISE;
            END IF;

            RETURN;
         END IF;

         IF g_dbg
         THEN
            op (' Eff Date : ' || p_effective_date, g_debug_log);
         END IF;

         hr_appraisals_api.create_appraisal
                         (p_validate                         => FALSE,
                          p_open                             => NULL,
                          -- Its mandatory to pass null, as the defult is 'Y'.
                          p_effective_date                   => p_effective_date,
                          p_business_group_id                => l_assignment_info.business_group_id,
                          p_appraisal_template_id            => p_appraisal_templ_id,
                          p_show_competency_ratings          => l_apprl_templ_info.show_competency_ratings,
                          p_show_objective_ratings           => l_apprl_templ_info.show_objective_ratings,
                          p_show_questionnaire_info          => l_apprl_templ_info.show_questionnaire_info,
                          p_show_participant_details         => l_apprl_templ_info.show_participant_details,
                          p_show_participant_ratings         => l_apprl_templ_info.show_participant_ratings,
                          p_show_participant_names           => l_apprl_templ_info.show_participant_names,
                          p_show_overall_ratings             => l_apprl_templ_info.show_overall_ratings,
                          p_provide_overall_feedback         => l_apprl_templ_info.disable_provide_feed,
                          --Bug7393131
                          p_show_overall_comments            => l_apprl_templ_info.show_overall_comments,
                          p_update_appraisal                 => 'Y',
                          p_appraisee_person_id              => l_scorecard_info.person_id,
                          p_appraiser_person_id              => l_appraiser_id,
                          --to be changed for position
                          p_appraisal_date                   => l_appraisal_date,
                          p_appraisal_period_start_date      => l_appraisal_period_start_date,
                          p_appraisal_period_end_date        => p_appraisal_end_date,
                          p_type                             => p_type,                      -- ANN,
                          p_next_appraisal_date              => p_next_appraisal_date,
                          p_status                           => p_status,   -- PLANNED,TRANSFER,RFC,
                          p_comments                         => p_comments,
                          p_system_type                      => l_appraisal_sys_type,
                          --MGR360 EMP360
                          p_system_params                    => l_func_params,
                          --p_appraisee_access,
                          p_main_appraiser_id                => l_main_appraiser_id,
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

        -- WPM Logging Changes Post Review
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).transaction_ref_id := l_apprl_id;
         hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'SUCCESS'; -- Success

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
                                   p_assessment_period_start_date      => l_appraisal_period_start_date,
                                   p_assessment_period_end_date        => p_appraisal_end_date,
                                   p_assessment_date                   => l_appraisal_date,
                                   p_assessor_person_id                => l_appraiser_id,
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
                                p_assessment_type_id                => l_apprl_templ_info.objective_asmnt_type_id,
                                p_business_group_id                 => l_assignment_info.business_group_id,
                                p_person_id                         => l_scorecard_info.person_id,
                                --p_assessment_group_id,
                                p_assessment_period_start_date      => l_appraisal_period_start_date,
                                p_assessment_period_end_date        => p_appraisal_end_date,
                                p_assessment_date                   => l_appraisal_date,
                                p_assessor_person_id                => l_appraiser_id,
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
         IF (p_appraisal_initiator = 'MGR')
         THEN
            l_object_id                := l_assignment_info.supervisor_id;
         ELSIF (p_appraisal_initiator = 'EMP')
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
                               (p_validate                          => FALSE,
                                p_competence_element_id             => l_comp_ele_id,
                                p_object_version_number             => l_comp_ovn,
                                p_type                              => 'ASSESSMENT',
                                p_business_group_id                 => l_assignment_info.business_group_id,
                                p_competence_id                     => competences.competence_id,
                                p_assessment_id                     => l_assessment_comp_id,
                                p_effective_date_from               => l_appraisal_period_start_date,
                                p_effective_date                    => p_effective_date,
                                p_object_name                       => 'ASSESSOR_ID',
                                p_object_id                         => l_object_id,
                                p_parent_competence_element_id      => competences.competence_element_id
                               );
                  z                          := z + 1;

                  IF g_dbg
                  THEN
                     op ('Competence Element Id = ' || l_comp_ele_id, g_debug_log);
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                   -- WPM Logging Changes
                   g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
                   g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
                   g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
                   hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

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
                           (p_validate                          => FALSE,
                            p_competence_element_id             => l_comp_ele_id,
                            p_object_version_number             => l_comp_ovn,
                            p_type                              => 'ASSESSMENT',
                            p_business_group_id                 => l_assignment_info.business_group_id,
                            p_competence_id                     => l_def_job_comps (j).competence_id,
                            p_assessment_id                     => l_assessment_comp_id,
                            p_effective_date_from               => l_appraisal_period_start_date,
                            p_effective_date                    => p_effective_date,
                            p_object_name                       => 'ASSESSOR_ID',
                            p_object_id                         => l_object_id,
                            p_parent_competence_element_id      => l_def_job_comps (j).competence_element_id
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
                        -- WPM Logging Changes
                        g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
                        g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
                        g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
                        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error
                        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

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
                         g_debug_log
                        );
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     -- WPM Logging Changes
                     g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
                     g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
                     g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
                     hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

                     -- to be added a message to identify update objective error
                     IF g_dbg
                     THEN
                        op (SQLERRM, g_regular_log);
                     END IF;
               END;
            END LOOP;
         END IF;
         --schowdhu 8721163 9-Sep-2009
         -- Add secondary assignment supervisors as participants
         IF (l_apprl_id IS NOT NULL AND l_default_participant <> 'N')
         THEN
            FOR supervisors IN get_sec_asg_supervisors (l_scorecard_info.person_id)
            LOOP
               BEGIN
                  hr_participants_api.create_participant
                                       (p_effective_date                 => p_effective_date,
                                        p_business_group_id              => l_assignment_info.business_group_id,
                                        p_questionnaire_template_id      => p_questionnaire_template_id,
                                        p_participation_in_table         => 'PER_APPRAISALS',
                                        p_participation_in_column        => 'APPRAISAL_ID',
                                        p_participation_in_id            => l_apprl_id,
                                        p_participation_status           => 'OPEN',
                                        p_participation_type             => p_participation_type,
                                        p_person_id                      => supervisors.supervisor_id,
                                        p_participant_id                 => l_participant_id,
                                        p_object_version_number          => l_object_version_number
                                       );

                  IF g_dbg
                  THEN
                     op ('Participant Id = ' || l_participant_id, g_debug_log);
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     -- WPM Logging Changes
                     g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
                     g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
                     g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
                     hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

                     -- to be added a message to identify participant creation error
                     IF g_dbg
                     THEN
                        op (SQLERRM, g_regular_log);
                     END IF;
               END;
            END LOOP;
         END IF;                                                      -- end of participant creation
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
                     -- WPM Logging Changes
                     g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
                     g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
                     g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
                     hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

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
-- |---------------------< submit_apprisal_cp >---------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE submit_appraisal_cp (
      p_effective_date        IN   DATE,
      p_start_date            IN   VARCHAR2,
      p_plan_id               IN   NUMBER,
      p_appraisal_period_id   IN   NUMBER,
      p_log_output            IN   VARCHAR2
   )
   IS
      --
      l_object_version_number   NUMBER;
      l_status_code             per_perf_mgmt_plans.status_code%TYPE;
      l_dummy                   BOOLEAN;
      l_request_id              NUMBER;
      l_effective_date          VARCHAR2 (30)
                            := fnd_date.date_to_canonical (NVL (p_effective_date, TRUNC (SYSDATE)));
   --
   BEGIN
      -- Submit the request
      l_request_id               :=
         fnd_request.submit_request (application      => 'PER',
                                     program          => 'WPMAPRPUSH',
                                     sub_request      => FALSE,
                                     start_time       => p_start_date,
                                     argument1        => l_effective_date,
                                     argument2        => p_plan_id,
                                     argument3        => p_appraisal_period_id,
                                     argument4        => p_log_output
                                    );

      --
      IF l_request_id > 0
      THEN
         NULL;
      END IF;
   --
   END submit_appraisal_cp;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< appraisal_cp >----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE appraisal_cp (
      errbuf                   OUT NOCOPY      VARCHAR2,
      retcode                  OUT NOCOPY      NUMBER,
      p_effective_date         IN              VARCHAR2,
      p_plan_id                IN              NUMBER,
      p_appraisal_period_id    IN              NUMBER,
      p_log_output             IN              VARCHAR2 DEFAULT 'N',
      p_delete_pending_trans   IN              VARCHAR2 DEFAULT 'N'
   )
   IS
--
      CURSOR csr_plan_ovn
      IS
         SELECT object_version_number
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

      l_object_version_number         NUMBER;
      l_effective_date                DATE
                             := fnd_date.canonical_to_date (NVL (p_effective_date, TRUNC (SYSDATE)));

      CURSOR csr_pend_trans (p_plan_id IN NUMBER)
      IS
         SELECT 'x'
           FROM DUAL
          WHERE EXISTS (
                   SELECT 'x'
                     FROM hr_api_transactions t, per_personal_scorecards sc
                    WHERE t.transaction_ref_table = 'PER_PERSONAL_SCORECARDS'
                      AND t.transaction_ref_id = sc.scorecard_id
                      AND sc.plan_id = p_plan_id);

      l_chk                           VARCHAR2 (10);
      scorecard_pending_transaction   EXCEPTION;
--
   BEGIN

     -- WPM Logging Changes
--     l_current_wpm_batch_action_id := per_wpm_batch_actions_s.NEXTVAL;
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
		    VALUES (per_wpm_batch_actions_s.NEXTVAL,
		           fnd_global.conc_request_id,
		           'WPMAPRPUSH',
		            p_plan_id,
		            p_appraisal_period_id,
		            'PENDING',
		             sysdate, --p_effective_date, -- trunc(sysdate)
		             null
    ) RETURNING wpm_batch_action_id INTO l_current_wpm_batch_action_id ;
    COMMIT;

/*
  --
  -- Derive the object version number of plan record
  --
  open  csr_plan_ovn;
  fetch csr_plan_ovn into l_object_version_number;
  close csr_plan_ovn;
*/-- Initialize return status
      retcode                    := warning;

       --
      -- Raise an error if there are any pending transactions
       --
      IF NVL (p_delete_pending_trans, 'N') = 'N'
      THEN
         OPEN csr_pend_trans (p_plan_id);

         FETCH csr_pend_trans
          INTO l_chk;

         IF csr_pend_trans%FOUND
         THEN
            CLOSE csr_pend_trans;

            RAISE scorecard_pending_transaction;
         END IF;

         CLOSE csr_pend_trans;
      END IF;

      -- WPM Logging Changes  Post Review
      -- to avoid caching issues
      g_wpm_person_actions.DELETE;
      log_records_index := NULL;

      --
      --  Call the publish plan
      --
      appraisal_push (p_effective_date           => l_effective_date,
                      p_plan_id                  => p_plan_id,
                      p_appraisal_period_id      => p_appraisal_period_id,
                      p_log_output               => 'Y'                               --p_log_output
                     );
      --
      errbuf                     := g_errbuf;
      retcode                    := g_retcode;
      --
         -- WPM Logging Changes
         print_cache();
         UPDATE per_wpm_batch_actions
	   SET END_DATE = sysdate, STATUS = decode(g_retcode,0,'SUCCESS','WARNING')
	   WHERE WPM_BATCH_ACTION_ID = l_current_wpm_batch_action_id;

      COMMIT;
   --
   EXCEPTION
      WHEN scorecard_pending_transaction
      THEN
         retcode                    := error;
         fnd_message.set_name ('PER', 'HR_SC_PENDING_TXN_ERR');
         errbuf                     := NVL (fnd_message.get, 'HR_SC_PENDING_TXN_ERR');
         ROLLBACK;
            -- WPM Logging Changes
            print_cache();
            UPDATE per_wpm_batch_actions
            SET STATUS = 'ERROR', END_DATE = sysdate
            WHERE WPM_BATCH_ACTION_ID = l_current_wpm_batch_action_id;
            COMMIT;

      WHEN OTHERS
      THEN
         ROLLBACK;
            -- WPM Logging Changes
            print_cache();
            UPDATE per_wpm_batch_actions
            SET STATUS = 'ERROR', END_DATE = sysdate
            WHERE WPM_BATCH_ACTION_ID = l_current_wpm_batch_action_id;
            COMMIT;

         --
         errbuf                     := g_errbuf;
         retcode                    := g_retcode;
   --
   END appraisal_cp;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< appraisal_push>-----------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE appraisal_push (
      p_effective_date        IN   DATE,
      p_plan_id               IN   NUMBER,
      p_appraisal_period_id   IN   NUMBER,
      p_log_output            IN   VARCHAR2
   )
   IS
      --
      -- Declare cursors and local variables
      --
      l_proc                    VARCHAR2 (72)                      := g_package || 'appraisal_push';
      l_logging                 pay_action_parameters.parameter_value%TYPE;
      l_debug                   BOOLEAN                                      := FALSE;
      l_effective_date          DATE                     := TRUNC (NVL (p_effective_date, SYSDATE));
      l_object_version_number   NUMBER;
      l_status_code             per_perf_mgmt_plans.status_code%TYPE;
      l_dummy                   BOOLEAN;
      --
      l_scorecard_id            per_personal_scorecards.scorecard_id%TYPE;
      --
      l_message_count           NUMBER                                       := 0;
      l_message                 VARCHAR2 (256);
      l_qual_pop_index          BINARY_INTEGER;
      l_curr_sc_pop_index       BINARY_INTEGER;
      l_qual_obj_index          BINARY_INTEGER;
      l_plan_aprsl_pds_index    BINARY_INTEGER;
      l_curr_sc_obj_index       BINARY_INTEGER;
      l_appr_ret_status         VARCHAR2 (1);

      -- Plan record
      CURSOR csr_get_plan_rec
      IS
         SELECT *
           FROM per_perf_mgmt_plans
          WHERE plan_id = p_plan_id;

/*
    -- Scorecard Objectives
    CURSOR csr_sc_objectives(p_scorecard_id number) IS
    select objective_id, object_version_number
    from   per_objectives
    where  scorecard_id = p_scorecard_id;
*/
      CURSOR csr_plan_appraisals (plan_id per_appraisals.plan_id%TYPE)
      IS
         SELECT appraisal_id,
                object_version_number
           FROM per_appraisals
          WHERE plan_id = plan_id;

       --
       -- Scorecard cursor modified
      -- schowdhu 6156964 23-Jun-2009  Eligibility Profile Enhc.
      CURSOR csr_get_scorecards
      IS
         SELECT pc.scorecard_id,
                pc.plan_id,
                pc.object_version_number,
                papf.business_group_id,
                pc.assignment_id,
                pc.person_id,
                pc.status_code,
                papf.full_name
           FROM per_personal_scorecards pc, per_people_f papf, per_assignments_f paaf
          WHERE pc.plan_id = p_plan_id
            AND pc.assignment_id = paaf.assignment_id
            AND pc.person_id = papf.person_id
            AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;

      CURSOR csr_get_elig_obj_id (p_appr_period_id per_appraisal_periods.appraisal_period_id%TYPE)
      IS
         SELECT elig.elig_obj_id
           FROM ben_elig_obj_f elig
          WHERE elig.table_name = 'PER_APPRAISAL_PERIODS'
            AND elig.column_name = 'APPRAISAL_PERIOD_ID'
            AND elig.COLUMN_VALUE = p_appr_period_id
            AND TRUNC (SYSDATE) BETWEEN elig.effective_start_date AND elig.effective_end_date;

      --
      l_plan_rec                per_perf_mgmt_plans%ROWTYPE;
      l_obj_date                DATE                                         := TRUNC (SYSDATE);
      l_scorecard_status_code   VARCHAR2 (30);
      l_check_elig              VARCHAR2 (1);
      l_elig_obj_id             ben_elig_obj_f.elig_obj_id%TYPE;

      --
      -- cursor to select pending transactions for a given scorecard
      --
      CURSOR c_trx (p_sc_card_id NUMBER)
      IS
         SELECT transaction_id
           FROM hr_api_transactions
          WHERE transaction_ref_table = 'PER_PERSONAL_SCORECARDS'
            AND transaction_ref_id = p_sc_card_id;

      l_sc_ovn                  NUMBER;
      l_trx_id                  NUMBER;
   --
   BEGIN
      --
      -- Initialize logging
      --
      initialize_logging (p_action_parameter_group_id => NULL, p_log_output => p_log_output);

      --
      IF g_dbg
      THEN
         op ('Entering:' || l_proc, g_debug_log, 10);
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

      IF g_dbg
      THEN
         op ('Plan Name: ' || SUBSTR (l_plan_rec.plan_name, 1, 40), g_debug_log, 21);
      END IF;

      IF g_dbg
      THEN
         op ('Concurrent Request ID: ' || TO_CHAR (fnd_global.conc_request_id), g_debug_log, 22);
      END IF;

--
-- Checks that the status is valid for PLAN PUBLISH OR REVERSE PUBLISH
--
--*****************************************
--*********check later for plan-publish status
--*****************************************
--chk_publishing_status(p_reverse_mode, l_plan_rec.status_code);
--
-- If appraisals flag is set then populate appraisala period table
      IF (l_plan_rec.include_appraisals_flag = 'Y')
      THEN
         --
         -- Get the qualifying plan periods
         -- g_plan_aprsl_pds_tbl is populated with details
         --
         IF g_dbg
         THEN
            op (l_proc, g_debug_log, 30);
         END IF;

         --

         -- This needs to be checked, as we no longer need plan_id for populating,
         -- as we will be hanling one appraisal period at a time now
         populate_plan_apprsl_periods (l_plan_rec.plan_id, p_appraisal_period_id);
      END IF;

      --
      IF g_dbg
      THEN
         op (l_proc, g_debug_log, 40);
      END IF;

      --
      FOR curr_scorecard IN csr_get_scorecards
      LOOP
        -- WPM Logging Changes
        log_records_index := curr_scorecard.assignment_id;
        IF NOT hr_wpm_mass_apr_push.g_wpm_person_actions.EXISTS (curr_scorecard.assignment_id)
        THEN
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).wpm_person_action_id := -1;
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).wpm_batch_action_id := l_current_wpm_batch_action_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).person_id := curr_scorecard.person_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).assignment_id := curr_scorecard.assignment_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).business_group_id := curr_scorecard.business_group_id;
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'P'; -- Processing
        -- hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).transaction_ref_table := 'PER_PERSONAL_SCORECARDS';
        -- hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).transaction_ref_id := curr_scorecard.scorecard_id;
        -- WPM Logging Changes  Post Review
        hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).transaction_ref_table := 'PER_APPRAISALS';

        END IF;

         IF (curr_scorecard.status_code <> 'TRANSFER_OUT')
         THEN
            IF g_dbg
            THEN
               op (l_proc, g_debug_log, 50);
            END IF;

            --
            -- Create Appraisals if flag is set
            --
            IF (l_plan_rec.include_appraisals_flag = 'Y')
            THEN
               --
               IF g_dbg
               THEN
                  op (l_proc, g_debug_log, 60);
               END IF;

               l_plan_aprsl_pds_index     := g_plan_aprsl_pds_tbl.FIRST;

               WHILE (l_plan_aprsl_pds_index IS NOT NULL)
               LOOP
                  --
                  IF g_dbg
                  THEN
                     op (l_proc, g_debug_log, 70);
                  END IF;

                  -- schowdhu 6156964 23-Jun-2009  Eligibility Profile Enhc.  start
                  OPEN csr_get_elig_obj_id (p_appraisal_period_id);

                  FETCH csr_get_elig_obj_id
                   INTO l_elig_obj_id;

                  CLOSE csr_get_elig_obj_id;

               IF (l_elig_obj_id IS NULL)
                THEN
                  -- WPM Logging Changes
                  hr_wpm_mass_apr_push.g_wpm_person_actions(hr_wpm_mass_apr_push.log_records_index).eligibility_status := 'Y';
               END IF;

                  IF (l_elig_obj_id IS NOT NULL)
                  THEN
                     BEGIN
                        --
                        ben_env_object.init
                                          (p_business_group_id      => curr_scorecard.business_group_id,
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
                           ben_per_asg_elig.eligible (curr_scorecard.person_id,
                                                      curr_scorecard.assignment_id,
                                                      l_elig_obj_id,
                                                      l_obj_date,
                                                      curr_scorecard.business_group_id,
                                                      'Y' ---KMG  added to allow CWK's for eligibility check
                                                     );
                         -- WPM Logging Changes
                         g_wpm_person_actions(log_records_index).eligibility_status :=  l_check_elig;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_check_elig               := 'N';
                         -- WPM Logging Changes
                         g_wpm_person_actions(log_records_index).eligibility_status :=  l_check_elig;
                         -- WPM Logging Changes
                         g_wpm_person_actions(log_records_index).MESSAGE_TYPE := 'E';
                         g_wpm_person_actions(log_records_index).MESSAGE_NUMBER := 'OTHER';
                         g_wpm_person_actions(log_records_index).MESSAGE_TEXT := SQLERRM;
	hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'ERROR'; -- Error

                           op ('Error while evaluating eligibility for: ', g_regular_log);
                           op (   '       '
                               || curr_scorecard.full_name
                               || ' ('
                               || curr_scorecard.person_id
                               || ')',
                               g_regular_log,
                               108
                              );
                           op (SQLERRM, g_regular_log, 108);
                           NULL;
                     END;
                  END IF;                                                -- l_elig_obj_id null check

                  IF (l_check_elig = 'N')
                  THEN
                     op ('+-------------------------------------------------------------------+',
                         g_regular_log
                        );
                     op ('Not Eligible. Appraisal creation skipped for: ', g_regular_log);
                     op (   '          '
                         || curr_scorecard.full_name
                         || ' ('
                         || curr_scorecard.person_id
                         || ')',
                         g_regular_log
                        );
                     op ('+-------------------------------------------------------------------+',
                         g_regular_log
                        );
                  END IF;

                  IF (l_check_elig = 'Y' OR (l_check_elig IS NULL AND l_elig_obj_id IS NULL))
                  THEN
                     -- schowdhu 6156964 23-Jun-2009  Eligibility Profile Enhc. end
                     create_appraisal_for_person
                        (p_score_card_id                  => curr_scorecard.scorecard_id,
                         p_appraisal_templ_id             => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).appraisal_template_id,
                         p_effective_date                 => p_effective_date,     --to be validated
                         p_appraisal_start_date           => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).start_date,
                         p_appraisal_end_date             => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).end_date,
                         p_appraisal_date                 => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).task_start_date,
                         p_appraisal_status               => 'PLANNED',    -- decided in the meeting
                         p_plan_id                        => p_plan_id,
                         p_next_appraisal_date            => NULL,                          -- to be
                         p_appraisal_initiator            => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).initiator_code,
                         p_type                           => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).appraisal_type,
                         -- A column to be added to UI and table in per_appraisal_periods
                         p_appraisal_system_type          => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).appraisal_system_type,
                         p_participation_type             => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).participation_type,
                         p_questionnaire_template_id      => g_plan_aprsl_pds_tbl
                                                                             (l_plan_aprsl_pds_index).questionnaire_template_id,
                         p_return_status                  => l_appr_ret_status
                        );
                  END IF;                                           -- Eligibility Profile Check End

                  IF g_dbg
                  THEN
                     op (l_proc, g_debug_log, 80);
                  END IF;

                  --
                  l_plan_aprsl_pds_index     := g_plan_aprsl_pds_tbl.NEXT (l_plan_aprsl_pds_index);

                  -- WPM Logging Changes
                  IF hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status = 'P'
                  THEN
	 hr_wpm_mass_apr_push.g_wpm_person_actions (log_records_index).processing_status := 'SUCCESS' ;  -- Success
                 END IF;

               --
               END LOOP;

               --
               IF g_dbg
               THEN
                  op (l_proc, g_debug_log, 90);
               END IF;

               --
               -- Delete all pending transactions.. once this appraisal push
               -- completes, then these transactions are not needed anymore.
               --
               BEGIN
                  OPEN c_trx (curr_scorecard.scorecard_id);

                  FETCH c_trx
                   INTO l_trx_id;

                  CLOSE c_trx;

                  IF l_trx_id IS NOT NULL
                  THEN
                     BEGIN
                        DELETE FROM hr_api_transaction_steps
                              WHERE transaction_id = l_trx_id;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     --
                     BEGIN
                        DELETE FROM hr_api_transactions
                              WHERE transaction_id = l_trx_id;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  --
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               --
               -- Need to change the status of the scorecard to 'PUBLISHED'
               --
               l_sc_ovn                   := curr_scorecard.object_version_number;

               BEGIN
                  hr_personal_scorecard_api.update_scorecard_status
                                                    (p_effective_date             => TRUNC (SYSDATE),
                                                     p_scorecard_id               => curr_scorecard.scorecard_id,
                                                     p_object_version_number      => l_sc_ovn,
                                                     p_status_code                => 'PUBLISHED'
                                                    );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            --
            END IF;                                                         --include appraisal flag

            --
            IF g_dbg
            THEN
               op (l_proc, g_debug_log, 100);
            END IF;
         END IF;
      END LOOP;

      --
      IF g_dbg
      THEN
         op ('Number of errors occured:' || TO_CHAR (g_num_errors), g_regular_log, 108);
         op ('Maximum errors allowed:' || g_max_errors, g_regular_log, 109);
         op ('Leaving:' || l_proc, g_regular_log, 110);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_dbg
         THEN
            op ('Number of errors occured:' || TO_CHAR (g_num_errors), g_regular_log, 88);
            op ('Maximum errors allowed:' || g_max_errors, g_regular_log, 89);
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
   END appraisal_push;

-- WPM Logging Changes
PROCEDURE print_cache
   IS
      l_proc           VARCHAR2 (80)                 := g_package || 'print_cache';
      l_evaluated      NUMBER (9)                    := 0;
      l_successful     NUMBER (9)                    := 0;
      l_error          NUMBER (9)                    := 0;
      l_warning        NUMBER (9)                    := 0;
      l_person_name    per_people_f.full_name%TYPE;
      l_person_index   BINARY_INTEGER;

      CURSOR get_person_name (p_person_id IN per_all_people_f.person_id%TYPE)
      IS
         SELECT full_name
           FROM per_all_people_f ppf
          WHERE ppf.person_id = p_person_id
            AND TRUNC (SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date;
   BEGIN
      op ('Entering:' || l_proc, g_regular_log, 10);
      op ('Time before printing cache ' || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'),
          g_regular_log,
          10
         );
      op ('Populating records into reporting table...', g_regular_log, 10);
      l_person_index             := g_wpm_person_actions.FIRST;

      WHILE (l_person_index IS NOT NULL)
      LOOP
         BEGIN
            OPEN get_person_name (g_wpm_person_actions (l_person_index).person_id);

            FETCH get_person_name
             INTO l_person_name;

            CLOSE get_person_name;

            INSERT INTO per_wpm_person_actions
                        (wpm_person_action_id,
                         wpm_batch_action_id,
                         person_id,
                         assignment_id,
                         business_group_id,
                         processing_status,
                         eligibility_status,
                         MESSAGE_TYPE,
                         message_number,
                         MESSAGE_TEXT,
                         transaction_ref_table,
                         transaction_ref_id,
                         information_category,
                         information1,
                         information2,
                         information3,
                         information4,
                         information5,
                         information6,
                         information7,
                         information8,
                         information9,
                         information10,
                         information11,
                         information12,
                         information13,
                         information14,
                         information15,
                         information16,
                         information17,
                         information18,
                         information19,
                         information20
                        )
                 VALUES (per_wpm_person_actions_s.NEXTVAL,
                         g_wpm_person_actions (l_person_index).wpm_batch_action_id,
                         g_wpm_person_actions (l_person_index).person_id,
                         g_wpm_person_actions (l_person_index).assignment_id,
                         g_wpm_person_actions (l_person_index).business_group_id,
                         g_wpm_person_actions (l_person_index).processing_status,
                         g_wpm_person_actions (l_person_index).eligibility_status,
                         g_wpm_person_actions (l_person_index).MESSAGE_TYPE,
                         g_wpm_person_actions (l_person_index).message_number,
                         g_wpm_person_actions (l_person_index).MESSAGE_TEXT,
                         g_wpm_person_actions (l_person_index).transaction_ref_table,
                         g_wpm_person_actions (l_person_index).transaction_ref_id,
                         g_wpm_person_actions (l_person_index).information_category,
                         g_wpm_person_actions (l_person_index).information1,
                         g_wpm_person_actions (l_person_index).information2,
                         g_wpm_person_actions (l_person_index).information3,
                         g_wpm_person_actions (l_person_index).information4,
                         g_wpm_person_actions (l_person_index).information5,
                         g_wpm_person_actions (l_person_index).information6,
                         g_wpm_person_actions (l_person_index).information7,
                         g_wpm_person_actions (l_person_index).information8,
                         g_wpm_person_actions (l_person_index).information9,
                         g_wpm_person_actions (l_person_index).information10,
                         g_wpm_person_actions (l_person_index).information11,
                         g_wpm_person_actions (l_person_index).information12,
                         g_wpm_person_actions (l_person_index).information13,
                         g_wpm_person_actions (l_person_index).information14,
                         g_wpm_person_actions (l_person_index).information15,
                         g_wpm_person_actions (l_person_index).information16,
                         g_wpm_person_actions (l_person_index).information17,
                         g_wpm_person_actions (l_person_index).information18,
                         g_wpm_person_actions (l_person_index).information19,
                         g_wpm_person_actions (l_person_index).information20
                        );

            IF (g_wpm_person_actions (l_person_index).MESSAGE_TYPE = 'E')
            THEN
               l_error                    := l_error + 1;
            ELSIF (g_wpm_person_actions (l_person_index).MESSAGE_TYPE = 'W')
            THEN
               l_warning                  := l_warning + 1;
            ELSE
               l_successful               := l_successful + 1;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_error                    := l_error + 1;
               op (SQLERRM, g_regular_log, 10);
               op (   'Insertion falied for: '
                   || l_person_name
                   || '('
                   || g_wpm_person_actions (l_person_index).person_id
                   || ').',
                   g_regular_log,
                   10
                  );
         END;

         l_person_index             := g_wpm_person_actions.NEXT (l_person_index);
      END LOOP;

      op ('Time at the end of printing cache ' || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'),
          g_regular_log,
          10
         );
      --
      l_evaluated                := l_successful + l_error + l_warning;
      op ('=======================Summary of the run =========================', g_regular_log, 10);
      op ('No of assignments evaluated in this run.' || l_evaluated, g_regular_log, 10);
      op ('No of assignments successful in this run. ' || l_successful, g_regular_log, 10);
      op ('No of assignments with warning in this run. ' || l_warning, g_regular_log, 10);
      op ('No of assignments errored in this run. ' || l_error, g_regular_log, 10);
   END print_cache;

--
END hr_wpm_mass_apr_push;

/
