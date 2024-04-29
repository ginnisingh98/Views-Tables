--------------------------------------------------------
--  DDL for Package Body BEN_REOPEN_LER_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REOPEN_LER_CONC" AS
/* $Header: benrecon.pkb 120.4.12000000.1 2007/07/12 10:08:18 gsehgal noship $ */
/*
--------------------------------------------------------------------------------
rem Name
rem   Reopen Life Event Process
rem Purpose
rem   This package is used to reopen latest life event for all the persons
rem --------------------------------------------------------------------------------
rem History
rem -------
rem   Version Date       Author     Comment
rem   -------+----------+----------+------------------------------------------------
rem   115.0   8/9/2006   gsehgal    Created.
rem   115.2   8/9/2006   nhunur     person selection rule changes.
rem   115.3   10/3/2006  gsehgal    SSN no was not printed and from date parameter
rem				    was not displayed
rem   115.4   10/13/2006 gsehgal    Bug: 5589226. Process was erroring out when
rem				    no persons were selected.
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
*/


--
-- global variables
   g_package           VARCHAR2 (80)              := 'ben_reopen_ler_conc';
   g_max_person_err    NUMBER                     := 100;
   g_persons_errored   NUMBER                     := 0;
   g_persons_procd     NUMBER                     := 0;
   g_cache_per_proc    g_cache_person_process_rec;
   l_pend_approvals    BOOLEAN;
--
-- this main process is called for the executable(BENROLER) defined for "Reopen Life Events" Concurrent Program
--
   PROCEDURE process (
      errbuf                  OUT NOCOPY      VARCHAR2,
      retcode                 OUT NOCOPY      NUMBER,
      p_benefit_action_id     IN              NUMBER,
      p_effective_date        IN              VARCHAR2,
      p_validate              IN              VARCHAR2 DEFAULT 'N',
      p_business_group_id     IN              NUMBER,
      p_ler_id                IN              NUMBER DEFAULT NULL,
      p_from_ocrd_date        IN              VARCHAR2 DEFAULT NULL,
      p_organization_id       IN              NUMBER DEFAULT NULL,
      p_location_id           IN              NUMBER DEFAULT NULL,
      p_benfts_grp_id         IN              NUMBER DEFAULT NULL,
      p_legal_entity_id       IN              NUMBER DEFAULT NULL,
      p_person_selection_rl   IN              NUMBER DEFAULT NULL,
      p_debug_messages        IN              VARCHAR2 DEFAULT 'N'
   )
   IS
      --
      -- Local variable declaration.
      --
      l_proc                    VARCHAR2 (100) := g_package || '.process';
      l_effective_date          DATE;
      l_person_ok               VARCHAR2 (30)  := 'Y';
      l_person_actn_cnt         NUMBER (15)    := 0;
      l_start_person_actn_id    NUMBER (15);
      l_end_person_actn_id      NUMBER (15);
      l_object_version_number   NUMBER (15);
      l_datetrack_mode          VARCHAR2 (80);
      l_actn                    VARCHAR2 (80);
      l_request_id              NUMBER (15);
      l_benefit_action_id       NUMBER (15);
      l_person_id               NUMBER (15);
      l_person_action_id        NUMBER (15);
      l_ler_id                  NUMBER (15);
      l_range_id                NUMBER (15);
      l_chunk_size              NUMBER         := 20;
      l_chunk_num               NUMBER         := 1;
      l_threads                 NUMBER (5)     := 1;
      l_step                    NUMBER         := 0;
      l_num_ranges              NUMBER         := 0;
      l_from_ocrd_date          DATE;
      l_commit                  NUMBER;
      -- Exceptions
      l_no_one_to_process       EXCEPTION;
      l_err_message  varchar2(2000);
--
-- curosrs
   --
   -- this cursor will fetch all the processed life events with the ler id
   -- given from ben_per_in_ler. We will to check whether this life event is
   -- latest or not at the time reopening life event api
      CURSOR c_pil
      IS
         SELECT   per.person_id, pil.per_in_ler_id
             FROM per_all_people_f per, ben_per_in_ler pil, ben_ler_f ler
            WHERE pil.person_id = per.person_id
              AND pil.per_in_ler_stat_cd = 'PROCD'
              AND pil.ler_id = p_ler_id
              AND pil.ler_id = ler.ler_id
              AND l_effective_date BETWEEN ler.effective_start_date
                                       AND ler.effective_end_date
              AND l_effective_date BETWEEN per.effective_start_date
                                       AND per.effective_end_date
              AND ler.typ_cd NOT IN ('GSP', 'COMP', 'SCHEDDU', 'ABS', 'IREC')
              AND pil.lf_evt_ocrd_dt >= l_from_ocrd_date
              AND (   p_organization_id IS NULL
                   OR EXISTS (
                         SELECT NULL
                           FROM per_all_assignments_f paa
                          WHERE paa.person_id = per.person_id
                            AND l_effective_date
                                   BETWEEN paa.effective_start_date
                                       AND paa.effective_end_date
                            AND paa.business_group_id = per.business_group_id
                            AND paa.primary_flag = 'Y'
                            AND paa.organization_id = p_organization_id)
                  )
              AND (   p_location_id IS NULL
                   OR EXISTS (
                         SELECT NULL
                           FROM per_all_assignments_f paa
                          WHERE paa.person_id = per.person_id
                            AND l_effective_date
                                   BETWEEN paa.effective_start_date
                                       AND paa.effective_end_date
                            AND paa.business_group_id = per.business_group_id
                            AND paa.primary_flag = 'Y'
                            AND paa.location_id = p_location_id)
                  )
              AND (   p_benfts_grp_id IS NULL
                   OR EXISTS (
                         SELECT NULL
                           FROM per_all_people_f pap
                          WHERE pap.person_id = per.person_id
                            AND pap.business_group_id = per.business_group_id
                            AND l_effective_date
                                   BETWEEN pap.effective_start_date
                                       AND pap.effective_end_date
                            AND pap.benefit_group_id = p_benfts_grp_id)
                  )
              AND (   p_legal_entity_id IS NULL
                   OR EXISTS (
                         SELECT NULL
                           FROM per_assignments_f paf,
                                hr_soft_coding_keyflex soft
                          WHERE paf.person_id = per.person_id
                            AND paf.assignment_type <> 'C'
                            AND l_effective_date
                                   BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date
                            AND paf.business_group_id = per.business_group_id
                            AND paf.primary_flag = 'Y'
                            AND soft.soft_coding_keyflex_id =
                                                    paf.soft_coding_keyflex_id
                            AND soft.segment1 = TO_CHAR (p_legal_entity_id))
                  )
         ORDER BY pil.person_id ASC, pil.lf_evt_ocrd_dt DESC;
      --
      -- Type declarations
      --
   --
   BEGIN
      -- hr_utility.trace_on (NULL, 'ORACLE');
      hr_utility.set_location ('Entering ' || l_proc, 10);
      -- changing in date format
      hr_utility.set_location ('Changing date formats ', 20);
      l_effective_date :=
                        TRUNC (fnd_date.canonical_to_date (p_effective_date));
      l_from_ocrd_date :=
                        TRUNC (fnd_date.canonical_to_date (p_from_ocrd_date));
           --
      -- Put row in fnd_sessions
      --
      dt_fndate.change_ses_date (p_ses_date      => l_effective_date,
                                 p_commit        => l_commit
                                );
      hr_utility.set_location ('Created fnd session ', 30);
      --
      -- Check business rules and mandatory parameters
      -- as effective date, ler_id and from occured date are mandatory
      hr_api.mandatory_arg_error (p_api_name            => l_proc,
                                  p_argument            => 'p_effective_date',
                                  p_argument_value      => p_effective_date
                                 );
      --
      hr_api.mandatory_arg_error (p_api_name            => l_proc,
                                  p_argument            => 'p_ler_id',
                                  p_argument_value      => p_ler_id
                                 );
      --
      hr_api.mandatory_arg_error (p_api_name            => l_proc,
                                  p_argument            => 'p_from_ocrd_date',
                                  p_argument_value      => p_from_ocrd_date
                                 );
      hr_utility.set_location ('Checked mandatory checks ', 20);
      --
      --
      -- Initialize the batch process.
      --
      ben_batch_utils.ini (p_actn_cd => 'PROC_INFO');
      --
      -- Get the parameters defined for the batch process.
      --
      benutils.get_parameter (p_business_group_id      => p_business_group_id,
                              p_batch_exe_cd           => 'BENROLER',
                              p_threads                => l_threads,
                              p_chunk_size             => l_chunk_size,
                              p_max_errors             => g_max_person_err
                             );
      hr_utility.set_location ('l_chunk_size ' || TO_CHAR (l_chunk_size),70);
      hr_utility.set_location ('l_threads ' || TO_CHAR (l_threads),70);

      --
      -- If p_benefit_action_id is null then this is a new batch process. Create the
      -- batch ranges and person actions. Else restart using the benefit_action_id.
      --
      --
      IF p_benefit_action_id IS NULL
      THEN
         --
         ben_benefit_actions_api.create_benefit_actions
                        (p_validate                    => FALSE,
                         p_benefit_action_id           => l_benefit_action_id,
                         p_process_date                => l_effective_date,
                         p_mode_cd                     => 'S',
                         p_derivable_factors_flag      => 'N',
                         p_validate_flag               => p_validate,
                         p_business_group_id           => p_business_group_id,
                         p_no_programs_flag            => 'N',
                         p_no_plans_flag               => 'N',
                         p_person_selection_rl         => p_person_selection_rl,
                         p_ler_id                      => p_ler_id,
                         p_organization_id             => p_organization_id,
                         p_benfts_grp_id               => p_benfts_grp_id,
                         p_location_id                 => p_location_id,
                         p_legal_entity_id             => p_legal_entity_id,
                         p_debug_messages_flag         => p_debug_messages,
                         p_object_version_number       => l_object_version_number,
                         p_effective_date              => l_effective_date,
                         p_request_id                  => fnd_global.conc_request_id,
                         p_program_application_id      => fnd_global.prog_appl_id,
                         p_program_id                  => fnd_global.conc_program_id,
                         p_program_update_date         => SYSDATE,
                         p_date_from                   => l_from_ocrd_date
                        );
         --
         benutils.g_benefit_action_id := l_benefit_action_id;
         --
         benutils.g_thread_id := 99;
         --
         l_actn := 'Removing batch ranges ';

         --
         DELETE FROM ben_batch_ranges
               WHERE benefit_action_id = l_benefit_action_id;

         --
         -- Loop through rows in ben_per_in_ler_f based on the parameters passed and
         -- create person actions for the selected people.
         --
         FOR l_rec IN c_pil
         LOOP
            --
            -- set variables for this iteration
            --
            hr_utility.set_location('processing from c_pil for person_id: '|| TO_CHAR (l_rec.person_id),40);
            l_person_ok := 'Y';
            --
            -- Check the person selection rule.
            --
            If p_person_selection_rl is not NULL then
            --
              ben_batch_utils.person_selection_rule
                      (p_person_id               => l_rec.person_id
                      ,p_business_group_id       => p_business_group_id
                      ,p_person_selection_rule_id=> p_person_selection_rl
                      ,p_effective_date          => l_effective_date
                      ,p_return                  => l_person_ok
                      ,p_err_message             => l_err_message );

                 if l_err_message  is not null
		 then
		     Ben_batch_utils.write(p_text =>
        		'<< Person id : '||to_char(l_person_id)||' failed.'||
			'   Reason : '|| l_err_message ||' >>' );
                    l_err_message := NULL ;
	         end if ;
            --
            End if;

            IF l_person_ok = 'Y'
            THEN
               --
               -- Either no person sel rule or person selection rule passed. Create a
               -- person action row.
               --
               ben_person_actions_api.create_person_actions
                         (p_validate                   => FALSE,
                          p_person_action_id           => l_person_action_id,
                          p_person_id                  => l_rec.person_id,
                          p_ler_id                     => l_rec.per_in_ler_id,
                          p_benefit_action_id          => l_benefit_action_id,
                          p_action_status_cd           => 'U',
                          p_chunk_number               => l_chunk_num,
                          p_object_version_number      => l_object_version_number,
                          p_effective_date             => l_effective_date
                         );
               --
               -- increment the person action count
               --
               l_person_actn_cnt := l_person_actn_cnt + 1;
               --
               -- Set the ending person action id to the last person action id that got
               -- created
               --
               l_end_person_actn_id := l_person_action_id;

               --
               -- We have to create batch ranges based on the number of person actions
               -- created and the chunk size defined for the batch process.
               --
               IF MOD (l_person_actn_cnt, l_chunk_size) = 1
                  OR l_chunk_size = 1
               THEN
                  --
                  -- This is the first person action id in a new range.
                  --
                  l_start_person_actn_id := l_person_action_id;
               --
               END IF;

               --
               IF MOD (l_person_actn_cnt, l_chunk_size) = 0
                  OR l_chunk_size = 1
               THEN
                  --
                  -- The number of person actions that got created equals the chunk
                  -- size. Create a batch range for the person actions.
                  --
                  hr_utility.set_location ('l_range_id: '||to_char(l_range_id),60);
                  hr_utility.set_location ('l_start_person_actn_id '||to_char(l_start_person_actn_id),60);
                  hr_utility.set_location ('l_end_person_actn_id '||to_char(l_end_person_actn_id),60);

		  ben_batch_ranges_api.create_batch_ranges
                      (p_validate                       => FALSE,
                       p_effective_date                 => l_effective_date,
                       p_benefit_action_id              => l_benefit_action_id,
                       p_range_id                       => l_range_id,
                       p_range_status_cd                => 'U',
                       p_starting_person_action_id      => l_start_person_actn_id,
                       p_ending_person_action_id        => l_end_person_actn_id,
                       p_object_version_number          => l_object_version_number
                      );
                  --
                  l_num_ranges := l_num_ranges + 1;
                  l_chunk_num := l_chunk_num + 1;
               --
               END IF;
            --
            END IF;
         --
         END LOOP;
         hr_utility.set_location ('l_num_ranges: ' || TO_CHAR (l_num_ranges),60);
         hr_utility.set_location ('l_chunck_num ' || TO_CHAR (l_chunk_num),70);
         --
         -- There may be a few person actions left over from the loop above that may
         -- not have got inserted into a batch range because the number was less than
         -- the chunk size. Create a range for the remaining person actions. This
         -- also applies when only one person gets selected.
         --
         IF l_person_actn_cnt > 0
            AND MOD (l_person_actn_cnt, l_chunk_size) <> 0
         THEN
            --
            ben_batch_ranges_api.create_batch_ranges
                      (p_validate                       => FALSE,
                       p_effective_date                 => l_effective_date,
                       p_benefit_action_id              => l_benefit_action_id,
                       p_range_id                       => l_range_id,
                       p_range_status_cd                => 'U',
                       p_starting_person_action_id      => l_start_person_actn_id,
                       p_ending_person_action_id        => l_end_person_actn_id,
                       p_object_version_number          => l_object_version_number
                      );
            --
            l_num_ranges := l_num_ranges + 1;
         --
         END IF;
      --
      ELSE
         --
         -- Benefit action id is not null i.e. the batch process is being restarted
         -- for a certain benefit action id. Create batch ranges and person actions
         -- for restarting.
         --
         l_benefit_action_id := p_benefit_action_id;
         --
         hr_utility.set_location (   'Restarting for benefit action id : '|| TO_CHAR (l_benefit_action_id),10);
         --
         ben_batch_utils.create_restart_person_actions
                                  (p_benefit_action_id      => p_benefit_action_id,
                                   p_effective_date         => l_effective_date,
                                   p_chunk_size             => l_chunk_size,
                                   p_threads                => l_threads,
                                   p_num_ranges             => l_num_ranges,
                                   p_num_persons            => l_person_actn_cnt
                                  );
      --
      END IF;
      --
      COMMIT;
      --
      -- Submit requests to the concurrent manager based on the number of ranges
      -- that got created.
      --
      IF l_num_ranges > 1
      THEN
         --
         hr_utility.set_location ('More than one range got created.', 10);
         --
         --
         -- Set the number of threads to the lesser of the defined number of threads
         -- and the number of ranges created above. There's no point in submitting
         -- 5 threads for only two ranges.
         --
         l_threads := LEAST (l_threads, l_num_ranges);

         --
         FOR l_count IN 1 .. (l_threads - 1)
         LOOP
            --
            -- We are subtracting one from the number of threads because the main
            -- process will act as the last thread and will be able to keep track of
            -- the child requests that get submitted.
            --
            hr_utility.set_location ('Submitting request no: '|| TO_CHAR (l_count),10);
            --
            l_request_id :=
	       -- submitting the process for multi threading
	       fnd_request.submit_request (application      => 'BEN',
                                           program          => 'BENROLERT',
                                           description      => NULL,
                                           sub_request      => FALSE,
                                           argument1        => p_validate,
                                           argument2        => l_benefit_action_id,
                                           argument3        => p_effective_date,
                                           argument4        => p_business_group_id,
                                           argument5        => p_ler_id,
                                           argument6        => l_count
                                          );
            --
            -- Store the request id of the concurrent request
            --
            ben_batch_utils.g_num_processes :=
                                           ben_batch_utils.g_num_processes + 1;
            ben_batch_utils.g_processes_tbl (ben_batch_utils.g_num_processes) :=
                                                                  l_request_id;
            COMMIT;
         --
         END LOOP;
      ELSIF (l_num_ranges = 0)
      THEN
         --
         hr_utility.set_location ('l_num_ranges = 0 ', 50);
         hr_utility.set_location ('p_validate ' || p_validate, 10);
         ben_batch_utils.print_parameters
                        (p_thread_id                     => 99,
                         p_benefit_action_id             => l_benefit_action_id,
                         p_validate                      => p_validate,
                         p_business_group_id             => p_business_group_id,
                         p_effective_date                => l_effective_date,
                         p_person_selection_rule_id      => p_person_selection_rl,
                         p_ler_id                        => p_ler_id,
                         p_organization_id               => p_organization_id,
                         p_benfts_grp_id                 => p_benfts_grp_id,
                         p_location_id                   => p_location_id,
                         p_legal_entity_id               => p_legal_entity_id
                        );

         --
	       -- bug: 5578779
         ben_batch_utils.write (p_text =>'From Occured Date          :'
				|| to_char(l_from_ocrd_date,'DD/MM/YYYY'));
         --
         fnd_message.set_name ('BEN', 'BEN_91769_NOONE_TO_PROCESS');
         fnd_message.set_token ('PROC', l_proc);
         -- changed bug: 5589226
	 RAISE l_no_one_to_process;
         -- fnd_message.raise_error;
      END IF;
      --
      -- Carry on with the master. This will ensure that the master finishes last.
      --
      hr_utility.set_location ('Submitting the master process', 10);
      --
      do_multithread (errbuf                   => errbuf,
                      retcode                  => retcode,
                      p_validate               => p_validate,
                      p_benefit_action_id      => l_benefit_action_id,
                      p_effective_date         => p_effective_date,
                      p_business_group_id      => p_business_group_id,
                      p_ler_id                 => p_ler_id,
		      p_thread_id              => l_threads + 1
                     );

      --
      -- Check if all the slave processes are finished.
      --
      ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
      --
      -- End the process.
      --
      ben_batch_utils.end_process (p_benefit_action_id      => l_benefit_action_id,
                                   p_person_selected        => l_person_actn_cnt,
                                   p_business_group_id      => p_business_group_id
                                  );
      --
      -- Submit reports.
      --
      submit_all_reports;
      --
      hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
   EXCEPTION
      -- bug: 5589226
        when l_no_one_to_process then
	benutils.write(p_text => fnd_message.get);
        benutils.write_table_and_file(p_table => TRUE, p_file  => TRUE);
      -- end
      WHEN OTHERS
      THEN
         --
         DECLARE
            l_sqlerrm   VARCHAR2 (100);
         BEGIN
            l_sqlerrm := SUBSTR (SQLERRM, 1, 100);
            hr_utility.set_location ('Un identified Exception ', 80);
            hr_utility.set_location (l_sqlerrm, 90);
         END;

         ben_batch_utils.rpt_error (p_proc           => l_proc,
                                    p_last_actn      => l_actn,
                                    p_rpt_flag       => TRUE
                                   );
         --
         benutils.WRITE (p_text => fnd_message.get);
         benutils.WRITE (p_text => SQLERRM);
         benutils.write_table_and_file (p_table => TRUE, p_file => TRUE);

         --
         IF l_num_ranges > 0
         THEN
            --
            ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
            --
            ben_batch_utils.end_process
                                 (p_benefit_action_id      => l_benefit_action_id,
                                  p_person_selected        => l_person_actn_cnt,
                                  p_business_group_id      => p_business_group_id
                                 );
            --
            submit_all_reports;
         --
         END IF;

         --
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', l_proc);
         fnd_message.set_token ('STEP', l_actn);
         fnd_message.raise_error;
   --
   END process;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
   PROCEDURE do_multithread (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      NUMBER,
      p_validate            IN              VARCHAR2 DEFAULT 'N',
      p_benefit_action_id   IN              NUMBER,
      p_effective_date      IN              VARCHAR2,
      p_business_group_id   IN              NUMBER,
      p_ler_id              IN              NUMBER,
      p_thread_id           IN              NUMBER
   )
   IS
      --
      -- Local variable declaration
      --
      l_proc                     VARCHAR2 (80)
                                            := g_package || '.do_multithread';
      l_person_id                ben_person_actions.person_id%TYPE;
      l_person_action_id         ben_person_actions.person_action_id%TYPE;
      l_object_version_number    ben_person_actions.object_version_number%TYPE;
      l_lf_evt_ocrd_dt           DATE;
      l_ler_id                   ben_person_actions.ler_id%TYPE;
      l_range_id                 ben_batch_ranges.range_id%TYPE;
      l_record_number            NUMBER                                  := 0;
      l_start_person_action_id   NUMBER                                  := 0;
      l_end_person_action_id     NUMBER                                  := 0;
      l_actn                     VARCHAR2 (80);
      l_cnt                      NUMBER (5)                              := 0;
      l_chunk_size               NUMBER (15);
      l_threads                  NUMBER (15);
      l_effective_date           DATE;
      l_from_ocrd_date           DATE;
      l_validate                 BOOLEAN                             := FALSE;
      l_ler_name                 ben_ler_f.NAME%TYPE;
      --
      -- bug: 5578779
      l_per_rec           per_all_people_f%rowtype;
      -- Cursors declaration
      --
      CURSOR c_range_thread
      IS
         -- to fetch all the ranges
         SELECT        ran.range_id, ran.starting_person_action_id,
                       ran.ending_person_action_id
                  FROM ben_batch_ranges ran
                 WHERE ran.range_status_cd = 'U'
                   AND ran.benefit_action_id = p_benefit_action_id
                   AND ROWNUM < 2
         FOR UPDATE OF ran.range_status_cd;

      --
      CURSOR c_person_thread
      IS
         -- to fetch all the persons actions
         SELECT   ben.person_id, ben.person_action_id,
                  ben.object_version_number, ben.ler_id
             FROM ben_person_actions ben
            WHERE ben.benefit_action_id = p_benefit_action_id
              AND ben.action_status_cd <> 'P'
              AND ben.person_action_id BETWEEN l_start_person_action_id
                                           AND l_end_person_action_id
         ORDER BY ben.person_action_id;

      --
      CURSOR c_parameter
      IS
         -- fetch all the parameters of the process from ben_benefit actions
         SELECT *
           FROM ben_benefit_actions ben
          WHERE ben.benefit_action_id = p_benefit_action_id;

      --
      CURSOR c_ler
      IS
         SELECT NAME
           FROM ben_ler_f
          WHERE ler_id = p_ler_id;

      --
      CURSOR c_per_in_ler (p_per_in_ler_id IN NUMBER)
      IS
         SELECT lf_evt_ocrd_dt, object_version_number
           FROM ben_per_in_ler
          WHERE per_in_ler_id = p_per_in_ler_id;

--
      l_parm                     c_parameter%ROWTYPE;
      l_commit                   NUMBER;
      l_encoded_message          VARCHAR2 (2000);
      l_app_short_name           VARCHAR2 (2000);
      l_message_name             VARCHAR2 (2000);
      g_rec                      ben_type.g_report_rec;
--
   BEGIN
      hr_utility.set_location ('Entering ' || l_proc, 10);
      l_effective_date :=
                        TRUNC (fnd_date.canonical_to_date (p_effective_date));
      --
      -- Put row in fnd_sessions
      --
      dt_fndate.change_ses_date (p_ses_date      => l_effective_date,
                                 p_commit        => l_commit
                                );
      --
      OPEN c_ler;
      LOOP
         FETCH c_ler INTO l_ler_name;
         EXIT WHEN c_ler%NOTFOUND;
      END LOOP;
      CLOSE c_ler;
      --
      l_actn := 'Calling benutils.get_parameter...';
      benutils.get_parameter (p_business_group_id      => p_business_group_id,
                              p_batch_exe_cd           => 'BENROLER',
                              p_threads                => l_threads,
                              p_chunk_size             => l_chunk_size,
                              p_max_errors             => g_max_person_err
                             );
      --
      -- Set up benefits environment
      --
      ben_env_object.init (p_business_group_id      => p_business_group_id,
                           p_effective_date         => l_effective_date,
                           p_thread_id              => p_thread_id,
                           p_chunk_size             => l_chunk_size,
                           p_threads                => l_threads,
                           p_max_errors             => g_max_person_err,
                           p_benefit_action_id      => p_benefit_action_id
                          );
      --
      g_persons_procd := 0;
      g_persons_errored := 0;
      --
      ben_batch_utils.ini;
      --
      benutils.g_benefit_action_id := p_benefit_action_id;
      benutils.g_thread_id := p_thread_id;
      --
      -- Fetch the parameters defined for the batch process.
      --
      OPEN c_parameter;
      FETCH c_parameter INTO l_parm;
      CLOSE c_parameter;
      --
      IF p_validate = 'Y'
      -- as he argument passed to reopen_single_life event
      -- is boolean
      THEN
         l_validate := TRUE;
      ELSE
         l_validate := FALSE;
      END IF;
      --
      -- Print the parameters to the log file.
      --
      hr_utility.set_location ('p_validate ' || p_validate, 10);
      ben_batch_utils.print_parameters
                    (p_thread_id                     => p_thread_id,
                     p_benefit_action_id             => p_benefit_action_id,
                     p_validate                      => p_validate,
                     p_business_group_id             => p_business_group_id,
                     p_effective_date                => l_effective_date,
                     p_person_selection_rule_id      => l_parm.person_selection_rl,
                     p_organization_id               => l_parm.organization_id,
                     p_benfts_grp_id                 => l_parm.benfts_grp_id,
                     p_location_id                   => l_parm.location_id,
                     p_legal_entity_id               => l_parm.legal_entity_id,
                     p_ler_id                        => p_ler_id
                    );
      -- bug: 5578779
      ben_batch_utils.write (p_text =>'From Occured Date          :'
				|| to_char(l_parm.date_from,'DD/MM/YYYY'));
      --
      LOOP
         --
         OPEN c_range_thread;
         FETCH c_range_thread INTO l_range_id, l_start_person_action_id, l_end_person_action_id;
         --
         EXIT WHEN c_range_thread%NOTFOUND;
         --
         CLOSE c_range_thread;
         --
         -- Update the range status code to processed 'P'
         --
         UPDATE ben_batch_ranges ran
            SET ran.range_status_cd = 'P'
          WHERE ran.range_id = l_range_id;
         --
         hr_utility.set_location ('Updated range '|| TO_CHAR (l_range_id)|| ' status code to P',10);
         --
         COMMIT;
         --
         -- Remove all records from cache
         --
         g_cache_per_proc.DELETE;
         --
         OPEN c_person_thread;
         --
         l_record_number := 0;
         --
         hr_utility.set_location ('Load person actions into the cache', 10);
         --
         LOOP
            --
            FETCH c_person_thread
             INTO g_cache_per_proc (l_record_number + 1).person_id,
                  g_cache_per_proc (l_record_number + 1).person_action_id,
                  g_cache_per_proc (l_record_number + 1).object_version_number,
                  g_cache_per_proc (l_record_number + 1).ler_id;
            --
            EXIT WHEN c_person_thread%NOTFOUND;
            --
            l_record_number := l_record_number + 1;
            --
            l_actn := 'Updating person_ations.';
            --
            UPDATE ben_person_actions
               SET action_status_cd = 'T'
             WHERE person_action_id = l_person_action_id;
         --
         END LOOP;
         --
         CLOSE c_person_thread;
         --
         COMMIT;
         --
         IF l_record_number > 0
         THEN
            --
            FOR l_cnt IN 1 .. l_record_number
            LOOP
               --
 	       IF g_persons_errored = g_max_person_err
	       THEN
		  fnd_message.set_name('BEN','BEN_94665_BENROLER_ERROR_LIMIT');
		  fnd_message.raise_error;
	       END IF;
               hr_utility.set_location('Reopening Life event for '|| TO_CHAR(g_cache_per_proc (l_cnt).person_id),10);
               --
               hr_utility.set_location ('Printing person details ', 20);
               -- Storing the value for a person
               l_person_id := g_cache_per_proc (l_cnt).person_id;
               ben_manage_life_events.person_header
                            (p_person_id              => g_cache_per_proc(l_cnt).person_id,
                             p_business_group_id      => p_business_group_id,
                             p_effective_date         => l_effective_date
                            );
               hr_utility.set_location ('Printed person header', 30);

               BEGIN
		  hr_utility.set_location('Before Api call ',10);
                  OPEN c_per_in_ler (g_cache_per_proc (l_cnt).ler_id);
                  LOOP
                     FETCH c_per_in_ler
                      INTO l_lf_evt_ocrd_dt, l_object_version_number;
                     EXIT;
                  END LOOP;
                  CLOSE c_per_in_ler;
                  hr_utility.set_location ('Calling main proc', 10);
                  -- call the procedure for reopening here
                  ben_close_enrollment.reopen_single_life_event
                          (p_per_in_ler_id              => g_cache_per_proc(l_cnt).ler_id,
                           p_person_id                  => g_cache_per_proc(l_cnt).person_id,
                           p_lf_evt_ocrd_dt             => l_lf_evt_ocrd_dt,
                           p_effective_date             => l_effective_date,
                           p_business_group_id          => p_business_group_id,
                           p_object_version_number      => l_object_version_number,
                           p_validate                   => l_validate
                          );

                  UPDATE ben_person_actions
                     SET action_status_cd = 'P'
                   WHERE person_action_id = g_cache_per_proc (l_cnt).person_action_id;

                  fnd_message.set_name ('BEN', 'BEN_94646_LF_EVT_REOPENED');
                  fnd_message.set_token ('LIFE_EVENT', l_ler_name);
		  benutils.WRITE (p_text => fnd_message.get);
                  g_persons_procd := g_persons_procd + 1;
               --
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     --- in the excption handler writing the errored person
                     --- in the log file along with error text
                                                        --
                     IF c_per_in_ler%ISOPEN
                     THEN
                        CLOSE c_per_in_ler;
                     END IF;

                     -- bug: 5578779
		     ben_person_object.get_object(p_person_id =>  g_cache_per_proc (l_cnt).person_id,
				       p_rec       => l_per_rec);
		     g_rec.national_identifier := l_per_rec.national_identifier;
		     -- end 5578779
		     l_encoded_message := fnd_message.get_encoded;
                     fnd_message.parse_encoded
                                        (encoded_message      => l_encoded_message,
                                         app_short_name       => l_app_short_name,
                                         message_name         => l_message_name
                                        );
                     fnd_message.set_encoded(encoded_message      => l_encoded_message);
                     --
                     g_rec.text := fnd_message.get;
                     --
                     g_rec.error_message_code :=
                        NVL (l_message_name, NVL (g_rec.error_message_code, SQLCODE));
                     g_rec.text := NVL (g_rec.text,NVL (g_rec.text, SUBSTR (SQLERRM, 1, 400)));
                     g_rec.rep_typ_cd := 'ERROR';
                     g_rec.person_id := g_cache_per_proc (l_cnt).person_id;

                     benutils.WRITE (p_rec => g_rec);

                     UPDATE ben_person_actions
                        SET action_status_cd = 'E'
                      WHERE person_action_id = g_cache_per_proc(l_cnt).person_action_id;

                     g_persons_errored := g_persons_errored + 1;
		     /*
		     IF g_persons_errored = g_max_person_err
		     THEN
			fnd_message.set_name('BEN','BEN_94665_BENROLER_ERROR_LIMIT');
			fnd_message.raise_error;
		     END IF;
		     */
               END;
            --
            END LOOP;
         ELSE
            --
            hr_utility.set_location ('No records found. Erroring out.', 10);
            --
            l_actn := 'Reporting error since there is no record found';
            --
            fnd_message.set_name ('BEN', 'BEN_91906_PER_NOT_FND_IN_RNG');
            fnd_message.set_token ('PROC', l_proc);
            fnd_message.set_token ('BENEFIT_ACTION_ID',
                                   TO_CHAR (p_benefit_action_id)
                                  );
            fnd_message.set_token ('BG_ID', TO_CHAR (p_business_group_id));
            fnd_message.set_token ('EFFECTIVE_DATE', p_effective_date);
            fnd_message.raise_error;
         --
         END IF;

         --
         benutils.write_table_and_file (p_table => TRUE, p_file => TRUE);
         --
         COMMIT;
      --
      END LOOP;

      --
      benutils.write_table_and_file (p_table => TRUE, p_file => TRUE);
      --
      COMMIT;
      --
      l_actn := 'Calling log_beneadeb_statistics...';
      --
      ben_batch_utils.write_logfile (p_num_pers_processed      => g_persons_procd,
                                     p_num_pers_errored        => g_persons_errored
                                    );
      --
      hr_utility.set_location ('Leaving ' || l_proc, 70);
   --
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         --
         ROLLBACK;
         --
         hr_utility.set_location ('BENROLER Super Error ' || l_proc, 10);
         hr_utility.set_location (SQLERRM, 10);
         benutils.rollback_cache;
         g_rec.rep_typ_cd := 'FATAL';
         g_rec.text := fnd_message.get;
         g_rec.person_id := l_person_id;

	 benutils.Write(p_text => benutils.g_banner_minus);
         benutils.WRITE (p_text => SQLERRM);
	 benutils.WRITE (p_rec => g_rec);
         /*
	 ben_batch_utils.rpt_error (p_proc           => l_proc,
                                    p_last_actn      => l_actn,
                                    p_rpt_flag       => TRUE
                                   );
	*/
         benutils.write_table_and_file (p_table => TRUE, p_file => TRUE);
         --
         ben_batch_utils.write_logfile
                                     (p_num_pers_processed      => g_persons_procd,
                                      p_num_pers_errored        => g_persons_errored
                                     );
         --
	 COMMIT;
         --
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', l_proc);
         fnd_message.set_token ('STEP', l_actn);
         fnd_message.raise_error;
   --
   END do_multithread;

--
   PROCEDURE submit_all_reports (p_rpt_flag IN BOOLEAN DEFAULT FALSE)
   IS
      -- local variables
      l_proc         VARCHAR2 (80) := g_package || '.submit_all_reports';
      l_actn         VARCHAR2 (80);
      l_request_id   NUMBER;
   --
   BEGIN
      --
      hr_utility.set_location ('Entering ' || l_proc, 05);

      --
      IF fnd_global.conc_request_id <> -1
      THEN
                --
         -- Submit the generic error by error type and error by person reports.
         --
         l_actn := 'ben_batch_reporting.batch_reports ERROR_BY_ERROR_TYPE...';
         ben_batch_reporting.batch_reports
                      (p_concurrent_request_id      => fnd_global.conc_request_id,
                       p_report_type                => 'ERROR_BY_ERROR_TYPE'
                      );
         --
         l_actn := 'ben_batch_reporting.batch_reports ERROR_BY_PERSON...';
         ben_batch_reporting.batch_reports
                       (p_concurrent_request_id      => fnd_global.conc_request_id,
                        p_report_type                => 'ERROR_BY_PERSON'
                       );
      --
      END IF;

      --
      hr_utility.set_location ('Leaving ' || l_proc, 10);
   --
   EXCEPTION
      --
      WHEN OTHERS
      THEN
         --
         ben_batch_utils.rpt_error (p_proc           => l_proc,
                                    p_last_actn      => l_actn,
                                    p_rpt_flag       => p_rpt_flag
                                   );
         --
         RAISE;
    --
--
   END submit_all_reports;
END ben_reopen_ler_conc;                                   -- end package body

/
