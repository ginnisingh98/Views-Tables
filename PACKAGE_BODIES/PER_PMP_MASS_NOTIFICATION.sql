--------------------------------------------------------
--  DDL for Package Body PER_PMP_MASS_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMP_MASS_NOTIFICATION" AS
/* $Header: pepmpmas.pkb 120.0.12010000.7 2009/12/25 15:32:43 schowdhu noship $ */
-- Declare Global variables
   g_package    VARCHAR2 (40) := 'per_pmp_mass_notification.';
   g_userdtls   t_userdtls;
   g_reqid      NUMBER;

----
   PROCEDURE WRITE (p_text IN VARCHAR2)
   IS
   BEGIN
      IF NVL (g_reqid, -1) = -1
      THEN
         hr_utility.TRACE (SUBSTR (p_text, 1, 240));
      ELSE
         fnd_file.put_line (fnd_file.LOG, p_text);
      END IF;
   END WRITE;

--
--
   PROCEDURE get_user_details (
      p_plan_id             NUMBER,
      p_effective_date      DATE,
      p_target_population   VARCHAR2,
      p_target_person_id    NUMBER
   )
   IS
      cnt   NUMBER;

      -- target person details
      CURSOR csr_person_dtls (p_person_id NUMBER, p_effective_date DATE)
      IS
         SELECT ppf.person_id,
                usr.NAME user_name,
                ppf.full_name
           FROM per_people_f ppf, wf_roles usr
          WHERE ppf.person_id = p_person_id
            AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND ppf.person_id = usr.orig_system_id(+)
            AND usr.orig_system(+) = 'PER';

      --
      -- All Eligible Workers of the plan
      CURSOR csr_all_workers (p_plan_id IN NUMBER, p_effective_date DATE)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_personal_scorecards sc,
                         per_assignments_f paf,
                         per_people_f ppf,
                         wf_roles usr
                   WHERE sc.plan_id = p_plan_id
                     AND p_effective_date BETWEEN sc.start_date AND sc.end_date
                     AND sc.assignment_id = paf.assignment_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.person_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND ppf.person_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';

      ---
      --- All managers with atleast one eligible worker
      --- Bug 9002011 person should be within plan population
      CURSOR csr_all_mgrs (p_plan_id IN NUMBER, p_effective_date DATE)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_personal_scorecards sc,
                         per_assignments_f paf,
                         per_people_f ppf,
                         wf_roles usr
                   WHERE sc.plan_id = p_plan_id
                     AND p_effective_date BETWEEN sc.start_date AND sc.end_date
                     AND sc.assignment_id = paf.assignment_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.supervisor_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.supervisor_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER'
                     AND paf.supervisor_id IN (SELECT person_id
                                                 FROM per_personal_scorecards
                                                WHERE plan_id = p_plan_id);

--
--
--  All managers with scorecards with a particular status
      CURSOR csr_mgr_scs (p_plan_id IN NUMBER, p_effective_date IN DATE, p_status IN VARCHAR2)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_personal_scorecards sc,
                         per_assignments_f paf,
                         per_people_f ppf,
                         wf_roles usr
                   WHERE sc.plan_id = p_plan_id
                     AND p_effective_date BETWEEN sc.start_date AND sc.end_date
                     AND sc.status_code = p_status
                     AND sc.assignment_id = paf.assignment_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.supervisor_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.supervisor_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';

--
-- All workers with scorecard with a particular status
--
      CURSOR csr_wkr_scs (p_plan_id IN NUMBER, p_effective_date IN DATE, p_status IN VARCHAR2)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_personal_scorecards sc,
                         per_assignments_f paf,
                         per_people_f ppf,
                         wf_roles usr
                   WHERE sc.plan_id = p_plan_id
                     AND p_effective_date BETWEEN sc.start_date AND sc.end_date
                     AND sc.status_code = p_status
                     AND sc.assignment_id = paf.assignment_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.person_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.person_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';

--
-- All workers who have atleast one incomplete scorecard
      CURSOR csr_wkr_incomplete (p_plan_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_assignments_f paf,
                         per_personal_scorecards sc,
                         per_people_f ppf,
                         wf_roles usr
                   WHERE sc.plan_id = p_plan_id
                     AND p_effective_date BETWEEN sc.start_date AND sc.end_date
                     AND sc.status_code <> 'PUBLISHED'
                     AND sc.status_code <> 'TRANSFER_OUT'
                     AND sc.assignment_id = paf.assignment_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.person_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.person_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';

--
-- All managers who have atleast one incomplete scorecard
      CURSOR csr_mgr_incomplete (p_plan_id IN NUMBER, p_effective_date IN DATE)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_assignments_f paf,
                         per_personal_scorecards sc,
                         per_people_f ppf,
                         wf_roles usr
                   WHERE sc.plan_id = p_plan_id
                     AND p_effective_date BETWEEN sc.start_date AND sc.end_date
                     AND sc.status_code <> 'PUBLISHED'
                     AND sc.status_code <> 'TRANSFER_OUT'
                     AND sc.assignment_id = paf.assignment_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.supervisor_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.supervisor_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';

--
-- All workers who have their appraisals as ongoing
      CURSOR csr_appr_wkr (p_plan_id IN NUMBER, p_status_code IN VARCHAR2)
      IS
         SELECT DISTINCT paf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_assignments_f paf, per_appraisals apr, per_people_f ppf, wf_roles usr
                   WHERE apr.plan_id = p_plan_id
                     AND apr.appraisal_system_status = p_status_code
                     AND apr.appraisee_person_id = paf.person_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.person_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.person_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';

--
-- All managers who have their appraisals as ongoing
      CURSOR csr_appr_mgr (p_plan_id IN NUMBER, p_status_code IN VARCHAR2)
      IS
         SELECT DISTINCT ppf.person_id,
                         usr.NAME user_name,
                         ppf.full_name
                    FROM per_assignments_f paf, per_appraisals apr, per_people_f ppf, wf_roles usr
                   WHERE apr.plan_id = p_plan_id
                     AND apr.appraisal_system_status = p_status_code
                     AND apr.main_appraiser_id = paf.person_id
                     AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                     AND paf.person_id = ppf.person_id
                     AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                     AND paf.person_id = usr.orig_system_id(+)
                     AND usr.orig_system(+) = 'PER';
   BEGIN
      --
      IF p_target_person_id IS NOT NULL
      THEN
         OPEN csr_person_dtls (p_target_person_id, p_effective_date);

         FETCH csr_person_dtls
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_person_dtls;

         RETURN;
      END IF;

      --
      IF p_target_population = 'ALL_WRKS'
      THEN
         OPEN csr_all_workers (p_plan_id, p_effective_date);

         FETCH csr_all_workers
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_all_workers;
      ELSIF p_target_population = 'ALL_MGRS'
      THEN
         OPEN csr_all_mgrs (p_plan_id, p_effective_date);

         FETCH csr_all_mgrs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_all_mgrs;
-- all managers with atleast one scorecard pending for review (MGR status)
      ELSIF p_target_population = 'SC_MGR_MGR'
      THEN
         OPEN csr_mgr_scs (p_plan_id, p_effective_date, 'MGR');

         FETCH csr_mgr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_mgr_scs;

         cnt                        := g_userdtls.COUNT + 1;

         FOR i IN csr_mgr_scs (p_plan_id, p_effective_date, 'APPROVAL')
         LOOP
            g_userdtls (cnt) := i;
            cnt                        := cnt + 1;
         END LOOP;
-- All managers with atleast one scorecard not started with manager status
      ELSIF p_target_population = 'SC_MGR_NOT_STRTD'
      THEN
         OPEN csr_mgr_scs (p_plan_id, p_effective_date, 'NOT_STARTED_WITH_MGR');

         FETCH csr_mgr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_mgr_scs;
--All managers with atleast one scorecard struck in transfer status
      ELSIF p_target_population = 'SC_MGR_TRANSFER'
      THEN
         OPEN csr_mgr_scs (p_plan_id, p_effective_date, 'TRANSFER');

         FETCH csr_mgr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_mgr_scs;
--All managers with atleast one scorecard   in transfer-out status
      ELSIF p_target_population = 'SC_MGR_TRANSFER_OUT'
      THEN
         OPEN csr_mgr_scs (p_plan_id, p_effective_date, 'TRANSFER_OUT');

         FETCH csr_mgr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_mgr_scs;
      --All managers who have atleast one incomplete scorecard
      ELSIF p_target_population = 'SC_MGR_INCOMPLETE'
      THEN
         OPEN csr_mgr_incomplete (p_plan_id, p_effective_date);

         FETCH csr_mgr_incomplete
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_mgr_incomplete;
-- all workers with  scorecard pending for review (MGR status)
      ELSIF p_target_population = 'SC_WKR_MGR'
      THEN
         OPEN csr_wkr_scs (p_plan_id, p_effective_date, 'MGR');

         FETCH csr_wkr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_wkr_scs;

         cnt                        := g_userdtls.COUNT + 1;

         FOR i IN csr_wkr_scs (p_plan_id, p_effective_date, 'APPROVAL')
         LOOP
            g_userdtls (cnt) := i;
            cnt                        := cnt + 1;
         END LOOP;
-- all workers with  scorecard pending with worker (WKR)
      ELSIF p_target_population = 'SC_WKR_WKR'
      THEN
         OPEN csr_wkr_scs (p_plan_id, p_effective_date, 'WKR');

         FETCH csr_wkr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_wkr_scs;
-- all workers with  scorecard not started with worker (WKR)
      ELSIF p_target_population = 'SC_WKR_NOT_STRTD'
      THEN
         OPEN csr_wkr_scs (p_plan_id, p_effective_date, 'NOT_STARTED_WITH_WKR');

         FETCH csr_wkr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_wkr_scs;
--All workers with atleast one scorecard struck in transfer status
      ELSIF p_target_population = 'SC_WKR_TRANSFER'
      THEN
         OPEN csr_wkr_scs (p_plan_id, p_effective_date, 'TRANSFER');

         FETCH csr_wkr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_wkr_scs;
--All managers with atleast one scorecard transfered out
      ELSIF p_target_population = 'SC_WKR_TRANSFER_OUT'
      THEN
         OPEN csr_wkr_scs (p_plan_id, p_effective_date, 'TRANSFER_OUT');

         FETCH csr_wkr_scs
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_wkr_scs;
      --All workers who have atleast one incomplete scorecard
      ELSIF p_target_population = 'SC_WKR_INCOMPLETE'
      THEN
         OPEN csr_wkr_incomplete (p_plan_id, p_effective_date);

         FETCH csr_wkr_incomplete
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_wkr_incomplete;
--All managers who have atleast one ongoing appraisal
      ELSIF p_target_population = 'APR_MGR_ONGOING'
      THEN
         OPEN csr_appr_mgr (p_plan_id, 'ONGOING');

         FETCH csr_appr_mgr
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_appr_mgr;
--All workers who have atleast one ongoing appraisal
      ELSIF p_target_population = 'APR_WKR_ONGOING'
      THEN
         OPEN csr_appr_wkr (p_plan_id, 'ONGOING');

         FETCH csr_appr_wkr
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_appr_wkr;
--All workers who have atleast one ongoing appraisal
      ELSIF p_target_population = 'APR_WKR_FEEDBACK'
      THEN
         OPEN csr_appr_wkr (p_plan_id, 'APPRFEEDBACK');

         FETCH csr_appr_wkr
         BULK COLLECT INTO g_userdtls;

         CLOSE csr_appr_wkr;
      END IF;
   --
   END get_user_details;

--
--
   PROCEDURE notify (
      p_plan_id           IN   NUMBER,
      p_effective_date    IN   DATE,
      p_message_subject   IN   VARCHAR2,
      p_message_body      IN   VARCHAR2
   )
   IS
      item_key               wf_notifications.item_key%TYPE;
      --item_type wf_notifications.item_type%type default 'HRWPM';
      l_administrator_role   wf_local_roles.NAME%TYPE;
      l_admin_person_id      per_perf_mgmt_plans.administrator_person_id%TYPE;
      to_role                wf_local_roles.NAME%TYPE;
      l_message_body         VARCHAR2 (4000);

      CURSOR get_wf_role (p_person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT NAME
           FROM wf_roles
          WHERE orig_system_id = p_person_id AND orig_system = 'PER';

      CURSOR csr_appl_name (p_message_name VARCHAR2)
      IS
         SELECT a.application_short_name
           FROM fnd_new_messages m, fnd_application a
          WHERE m.message_name = p_message_name
            AND m.language_code = USERENV ('LANG')
            AND m.application_id = a.application_id;

      l_appl_short_name      VARCHAR2 (30);
   BEGIN
      WRITE ('Inside Notify');

      -- get administrartor role as notification  sender
      SELECT administrator_person_id
        INTO l_admin_person_id
        FROM per_perf_mgmt_plans
       WHERE plan_id = p_plan_id;

      OPEN get_wf_role (l_admin_person_id);

      FETCH get_wf_role
       INTO l_administrator_role;

      CLOSE get_wf_role;

      WRITE ('admin role (From Role) : ' || l_administrator_role);

      IF l_administrator_role IS NULL
      THEN
         WRITE ('Plan Administrator''s role is not defined. Cannot proceed further');
         RETURN;
      END IF;

--
      FOR i IN g_userdtls.FIRST .. g_userdtls.LAST
      LOOP
         IF g_userdtls (i).user_name IS NULL
         THEN
            WRITE (   'Could not send notification for:'
                   || g_userdtls (i).user_display_name
                   || ' as no user exists'
                  );
         ELSE
            BEGIN
               WRITE (   'sending notification for '
                      || g_userdtls (i).user_display_name
                      || ' :user_name: '
                      || g_userdtls (i).user_name
                      || 'person_id : '
                      || g_userdtls (i).person_id
                     );
               to_role                    := g_userdtls (i).user_name;
               WRITE ('got role to send: ' || to_role);

               -- initiallize the wf process
               SELECT hr_workflow_item_key_s.NEXTVAL
                 INTO item_key
                 FROM DUAL;

               --
               OPEN csr_appl_name (p_message_body);

               FETCH csr_appl_name
                INTO l_appl_short_name;

               CLOSE csr_appl_name;

               fnd_message.set_name (l_appl_short_name, p_message_body);
               l_message_body             := fnd_message.get;

               IF l_message_body IS NULL
               THEN
                  l_message_body             := p_message_body;
               END IF;

               wf_engine.createprocess (itemtype        => 'HRWPM',
                                        itemkey         => item_key,
                                        process         => 'PER_PERF_MGMT_NTF_POPULATION',
                                        user_key        => item_key,
                                        owner_role      => l_administrator_role
                                       );
               -- set the required attributes
               wf_engine.setitemattrtext ('HRWPM',
                                          item_key,
                                          'MASS_NTF_FROM_ROLE',
                                          l_administrator_role
                                         );
               wf_engine.setitemattrtext ('HRWPM', item_key, 'MASS_NTF_TO_ROLE', to_role);
               wf_engine.setitemattrtext ('HRWPM', item_key, 'MASS_NTF_MSG_TEXT', l_message_body);
               wf_engine.setitemattrtext ('HRWPM',
                                          item_key,
                                          'MASS_NTF_MSG_HEADER',
                                          p_message_subject
                                         );
               wf_engine.startprocess (itemtype => 'HRWPM', itemkey => item_key);
               WRITE (   'Started process with item_key: '
                      || item_key
                      || ' for person '
                      || g_userdtls (i).user_display_name
                     );
            EXCEPTION
               WHEN OTHERS
               THEN
                  WRITE (   'Failed to send ntf for user '
                         || g_userdtls (i).user_display_name
                         || SUBSTR (SQLERRM, 0, 200)
                        );
            END;
         END IF;                                                               -- user_name not null
--
      END LOOP;
--
   END notify;

--
--
   PROCEDURE mass_notify (
      errbuf                    OUT NOCOPY      VARCHAR2,
      retcode                   OUT NOCOPY      NUMBER,
      p_plan_id                 IN              NUMBER,
      p_effective_date          IN              VARCHAR2,
      p_message_subject         IN              VARCHAR2,
      p_message_body            IN              VARCHAR2,
      p_target_population       IN              VARCHAR2 DEFAULT NULL,
      p_target_person_id        IN              NUMBER DEFAULT NULL,
      p_person_selection_rule   IN              NUMBER DEFAULT NULL
   )
   IS
      l_effective_date   DATE;
      l_proc             VARCHAR2 (80)   := 'mass_notify' || g_package;
      l_message          VARCHAR2 (2000);
   BEGIN
      g_reqid                    := fnd_global.conc_request_id;
      WRITE ('Entering : ' || l_proc);
      WRITE ('Parameter values:');
      WRITE ('-----------------');
      WRITE ('p_plan_id : ' || p_plan_id);
      WRITE ('p_target_population : ' || p_target_population);
      WRITE ('p_target_person_id : ' || p_target_person_id);
      WRITE ('-----------------');
      hr_api.mandatory_arg_error (p_api_name            => 'per_pmp_mass_notification.mass_notify',
                                  p_argument            => 'p_plan_id',
                                  p_argument_value      => p_plan_id
                                 );
      hr_api.mandatory_arg_error (p_api_name            => 'per_pmp_mass_notification.mass_notify',
                                  p_argument            => 'p_effective_date',
                                  p_argument_value      => p_effective_date
                                 );
      hr_api.mandatory_arg_error (p_api_name            => 'per_pmp_mass_notification.mass_notify',
                                  p_argument            => 'p_message_subject',
                                  p_argument_value      => p_message_subject
                                 );
      hr_api.mandatory_arg_error (p_api_name            => 'per_pmp_mass_notification.mass_notify',
                                  p_argument            => 'p_message_body',
                                  p_argument_value      => p_message_body
                                 );

      --
      IF     p_target_population IS NULL
         AND p_target_person_id IS NULL
         AND p_person_selection_rule IS NULL
      THEN
         fnd_message.set_name ('PER', 'PER_NO_POPULATION_TO_NOTIFY');
         l_message                  := fnd_message.get;
         WRITE (l_message);
         fnd_message.raise_error;
      END IF;

      --
      l_effective_date           := fnd_date.canonical_to_date (p_effective_date);

      --
      IF hr_api.not_exists_in_hr_lookups (l_effective_date,
                                          'PER_PERF_MGMT_NTF_POPULATION',
                                          p_target_population
                                         )
      THEN
         fnd_message.set_name ('PER', 'PER_PMP_INVALID_POPULATION');
         fnd_message.raise_error;
      END IF;

      --
      g_userdtls.DELETE;
      WRITE ('calling get_user_details');
      --
      get_user_details (p_plan_id                => p_plan_id,
                        p_effective_date         => l_effective_date,
                        p_target_population      => p_target_population,
                        p_target_person_id       => p_target_person_id
                       );
      WRITE ('No of users to be notified:' || g_userdtls.COUNT);

      IF g_userdtls.COUNT > 0
      THEN
         notify (p_plan_id              => p_plan_id,
                 p_effective_date       => l_effective_date,
                 p_message_subject      => p_message_subject,
                 p_message_body         => p_message_body
                );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         errbuf                     := SQLERRM;
         retcode                    := 2;
         WRITE (errbuf);
         RAISE;
   END mass_notify;
--
END per_pmp_mass_notification;

/
