--------------------------------------------------------
--  DDL for Package Body HXT_HXC_RETRIEVAL_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXC_RETRIEVAL_PROCESS" AS
/* $Header: hxthcrtp.pkb 120.12.12010000.7 2009/07/10 09:56:31 asrajago ship $ */
   g_debug                   BOOLEAN         := hr_utility.debug_enabled;

   TYPE t_time_recipient IS TABLE OF VARCHAR2 (1)
      INDEX BY BINARY_INTEGER;

   g_status                  VARCHAR2 (30);
   g_exception_description   VARCHAR2 (2000);
   e_record_error            EXCEPTION;
   e_no_details              EXCEPTION;
   e_error                   EXCEPTION;

--------------------------- syncronize_deletes_in_otlr ----------------------
   PROCEDURE synchronize_deletes_in_otlr (
      p_time_building_blocks   IN              hxc_self_service_time_deposit.timecard_info,
      p_time_att_info          IN              hxc_self_service_time_deposit.app_attributes_info,
      p_messages               IN OUT NOCOPY   hxc_self_service_time_deposit.message_table,
      p_timecard_source	       IN VARCHAR	-- added for 5137310
   )
   IS
      l_time_building_blocks   hxc_self_service_time_deposit.timecard_info
                                                    := p_time_building_blocks;
      l_time_att_info          hxc_self_service_time_deposit.app_attributes_info
                                                           := p_time_att_info;

      CURSOR c_get_sum_id (day_bb_id NUMBER)
      IS
         SELECT ID, tim_id
           FROM hxt_sum_hours_worked_f
          WHERE time_building_block_id = day_bb_id;

-- Cursor to get those rows(from HXC tables) that have been deleted in OTL
-- but this delete not yet been reflected in the OTLR tables because of the
-- 'Transfer Time from OTL to BEE' process not run yet.

 -- Bug 8672797
 -- Forced hints to get rid of perf issue.
      CURSOR c_get_day_bb_id (l_parent_start_time DATE, l_resource_id NUMBER)
      IS
         SELECT tbb.time_building_block_id
           FROM hxc_time_building_blocks tbb
          WHERE tbb.parent_building_block_id IN (
                   SELECT /*+ INDEX( tbb1 HXC_TIME_BUILDING_BLOCKS_FK2)*/
                          time_building_block_id
                     FROM hxc_time_building_blocks tbb1
                    WHERE tbb1.resource_id = l_resource_id
                      AND tbb1.resource_type = 'PERSON'
                      AND tbb1.start_time = l_parent_start_time
                      AND tbb1.SCOPE = 'DAY')
            AND tbb.object_version_number =
                   (SELECT /*+ NO_UNNEST */
                           MAX (dyovn.object_version_number)
                      FROM hxc_time_building_blocks dyovn
                     WHERE dyovn.time_building_block_id =
                                                    tbb.time_building_block_id
                       AND dyovn.date_to <> hr_general.end_of_time)
            AND tbb.date_to <> hr_general.end_of_time
            AND EXISTS (
                   SELECT /*+ LEADING(txd)
                   	      INDEX(txd HXC_TRANSACTION_DETAILS_FK1)
                   	      INDEX(tx HXC_TRANSACTIONS_PK) */
                          'x'
                     FROM hxc_transaction_details txd, hxc_transactions tx
                    WHERE tx.transaction_process_id = -1
                      AND tx.TYPE = 'RETRIEVAL'
                      AND tx.status = 'SUCCESS'
                      AND tx.transaction_id = txd.transaction_id
                      AND txd.status = 'SUCCESS'
                      AND txd.time_building_block_id =
                                                    tbb.time_building_block_id
                      AND txd.time_building_block_ovn <=
                                                     tbb.object_version_number);

/*AND NOT EXISTS
           (select 'x'
         FROM  hxc_transaction_details txd1
                  ,hxc_transactions tx1
         WHERE tx1.transaction_process_id    = -1
         AND   tx1.type                 = 'RETRIEVAL'
         AND   tx1.status                   = 'SUCCESS'
          AND     tx1.transaction_id             = txd1.transaction_id
         AND   txd1.status                   = 'SUCCESS'
          AND  txd1.time_building_block_id      = tbb.time_building_block_id
          AND     txd1.time_building_block_ovn   = tbb.object_version_number
          );*/
      l_bb_id                  NUMBER (15);
      l_ovn                    NUMBER (9);
      l_check_bb_id            NUMBER (15);
      l_check_bb_ovn           NUMBER (9);
      l_parent_bb_ovn          NUMBER (9);
      l_type                   VARCHAR2 (30);
      l_measure                hxc_time_building_blocks.measure%TYPE;
      l_start_time             DATE;
      l_parent_start_time      DATE;
      l_stop_time              DATE;
      l_date_to                DATE;
      l_parent_bb_id           NUMBER (15);
      l_scope                  VARCHAR2 (30);
      l_resource_id            NUMBER (15);
      l_resource_type          VARCHAR2 (30);
      l_comment_text           VARCHAR2 (2000);
      l_new                    VARCHAR2 (30);
      l_cnt                    NUMBER;
      j                        NUMBER;
      l_valid                  VARCHAR2 (1)                             := 'N';
      l_day_bb_id              NUMBER (15);
      l_time_summary_id        NUMBER (15);
      l_batch_status           VARCHAR2 (30);
      l_batch_id               NUMBER (15);
      l_proc                   VARCHAR2 (250);
      l_dt_update_mode         VARCHAR2 (30);
      l_otm_error              VARCHAR2 (2000);
      o_return_code            NUMBER (15);
      e_error                  EXCEPTION;
      l_session_id             NUMBER;
      l_tim_id                 NUMBER (15);
      l_measure_count          NUMBER;
   BEGIN
      g_debug := hr_utility.debug_enabled;
      hr_kflex_utility.set_session_date (p_effective_date      => SYSDATE,
                                         p_session_id          => l_session_id
                                        );
      -- Verify for each valid detail block if any of the detail blocks for the
      -- day were deleted in HXC and this delete not yet reflected in OTLR.
      -- This information is required when the details records are deleted
      -- in OTL and the transfer process hasn't been run before entering a
      -- new row for the same day. Since the transfer process hasn't been run yet,
      -- it results in an incorrect OTLR validation taking place between the new
      -- rows entered in OTL and the old rows in OTLR that have already been
      -- deleted in OTL.
      -- In order to fix this , we need to find out, when entering new rows in OTL,
      -- whether any rows related to this day have been deleted or not.
      -- If yes, then delete the corresponding row in HXT tables, so that the OTLR
      -- validation takes place against the latest changes done in OTL and
      -- reflected in OTLR.
      l_cnt := l_time_building_blocks.FIRST;

      LOOP
         EXIT WHEN NOT l_time_building_blocks.EXISTS (l_cnt);

         --
         IF g_debug
         THEN
            l_proc := 'hxt_hxc_retrieval_process.synchronize_deletes_in_otlr';
            hr_utility.set_location (l_proc, 10);
            hr_utility.TRACE
                        ('***********  NEW TIME BUILDING BLOCK  ************');
         END IF;

         --
         l_bb_id := l_time_building_blocks (l_cnt).time_building_block_id;
         l_ovn := l_time_building_blocks (l_cnt).object_version_number;
         l_type := l_time_building_blocks (l_cnt).TYPE;
         l_measure := l_time_building_blocks (l_cnt).measure;
         l_start_time := l_time_building_blocks (l_cnt).start_time;
         l_stop_time := l_time_building_blocks (l_cnt).stop_time;
         l_parent_bb_id :=
                       l_time_building_blocks (l_cnt).parent_building_block_id;
         l_parent_bb_ovn :=
                      l_time_building_blocks (l_cnt).parent_building_block_ovn;
         l_scope := l_time_building_blocks (l_cnt).SCOPE;
         l_resource_id := l_time_building_blocks (l_cnt).resource_id;
         l_resource_type := l_time_building_blocks (l_cnt).resource_type;
         l_comment_text := l_time_building_blocks (l_cnt).comment_text;
         l_new := l_time_building_blocks (l_cnt).NEW;
         l_date_to := l_time_building_blocks (l_cnt).date_to;

         --
         IF g_debug
         THEN
            hr_utility.TRACE ('Time BB ID is : ' || TO_CHAR (l_bb_id));
            hr_utility.TRACE ('Type is : ' || l_type);
            hr_utility.TRACE ('Measure is : ' || TO_CHAR (l_measure));
            hr_utility.TRACE (   'l_start_time is '
                              || TO_CHAR (l_start_time,
                                          'DD-MON-YYYY HH:MI:SS')
                             );
            hr_utility.TRACE (   'l_stop_time is '
                              || TO_CHAR (l_stop_time, 'DD-MON-YYYY HH:MI:SS')
                             );
            hr_utility.TRACE ('l_scope is ' || l_scope);
            hr_utility.TRACE ('l_resource_id is ' || TO_CHAR (l_resource_id));
            hr_utility.TRACE ('l_resource_type is ' || l_resource_type);
            --
            hr_utility.TRACE (   'UOM is : '
                              || l_time_building_blocks (l_cnt).unit_of_measure
                             );
            hr_utility.TRACE
               (   'Parent BB ID is : '
                || TO_CHAR
                       (l_time_building_blocks (l_cnt).parent_building_block_id
                       )
               );
            hr_utility.TRACE (   'PARENT_IS_NEW is : '
                              || l_time_building_blocks (l_cnt).parent_is_new
                             );
            hr_utility.TRACE
                 (   'OVN is : '
                  || TO_CHAR
                          (l_time_building_blocks (l_cnt).object_version_number
                          )
                 );
            hr_utility.TRACE (   'APPROVAL_STATUS is : '
                              || l_time_building_blocks (l_cnt).approval_status
                             );
            hr_utility.TRACE
                            (   'DATE_FROM is : '
                             || TO_CHAR
                                     (l_time_building_blocks (l_cnt).date_from,
                                      'DD-MON-YYYY'
                                     )
                            );
            hr_utility.TRACE (   'DATE_TO is : '
                              || TO_CHAR
                                       (l_time_building_blocks (l_cnt).date_to,
                                        'DD-MON-YYYY'
                                       )
                             );
            hr_utility.TRACE ('NEW is : '
                              || l_time_building_blocks (l_cnt).NEW
                             );
            --
            hr_utility.set_location (l_proc, 20);
         END IF;

         --
         IF (       (   (l_type = 'MEASURE' AND l_measure IS NOT NULL)
                     OR (    l_type = 'RANGE'
                         AND l_start_time IS NOT NULL
                         AND l_stop_time IS NOT NULL
                        )
                    )
                AND (   l_date_to = hr_general.end_of_time
                     OR (l_date_to <> hr_general.end_of_time AND l_new = 'N'
                        )
                    )
             OR (    (   (l_type = 'MEASURE' AND l_measure IS NULL)
                      OR (    l_type = 'RANGE'
                          AND l_start_time IS NULL
                          AND l_stop_time IS NULL
                         )
                     )
                 AND l_date_to <> hr_general.end_of_time
                 AND l_new = 'N'
                )
            )
         THEN
            --
            l_valid := 'Y';
         ELSE
            l_valid := 'N';
         END IF;

         --
         -- We need to take into consideration, the entire Timecard and not just
         -- the Detail Blocks, for bug 4676079. Here what happens is that the user
         -- deletes(i.e., clears up an entry for the day while updating the TC)
         -- and submits the TC for Approval.
         -- Now when the Approver clicks on Detail button to review the details
         -- of the Timecard, at that point the TC structure sent to OTLR code
         -- doesn't include an entry for the detail record that was cleared off
         -- by the employee. As such syncronize_deletes_in_otlr wasn't able to
         -- syncronize the data for the day. That's why we need to consider the
         -- entire TC structure when performing thsi task.
         IF l_valid = 'Y'
         THEN
            IF l_scope = 'DETAIL'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
                  hr_utility.TRACE ('l_parent_bb_id :' || l_parent_bb_id);
                  hr_utility.TRACE ('l_parent_bb_ovn :' || l_parent_bb_ovn);
               END IF;

               j := l_time_building_blocks.FIRST;

               LOOP
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 51);
                  END IF;

                  EXIT WHEN NOT l_time_building_blocks.EXISTS (j);

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 52);
                  END IF;

                  --
                  l_check_bb_id :=
                             l_time_building_blocks (j).time_building_block_id;
                  l_check_bb_ovn :=
                              l_time_building_blocks (j).object_version_number;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_parent_bb_id :' || l_parent_bb_id);
                     hr_utility.TRACE ('l_parent_bb_ovn:' || l_parent_bb_ovn);
                  END IF;

                  IF     l_check_bb_id = l_parent_bb_id
                     AND l_check_bb_ovn = l_parent_bb_ovn
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 53);
                     END IF;

                     l_parent_start_time :=
                                         l_time_building_blocks (j).start_time;
                     EXIT;
                  ELSE
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 54);
                     END IF;

                     j := l_time_building_blocks.NEXT (j);
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 55);
                  END IF;
               END LOOP;
            ELSE
               l_parent_start_time := l_start_time;
            END IF;

            /* select start_time into l_parent_start_time
                from hxc_time_building_blocks
                where time_building_block_id = l_parent_bb_id
                and   object_version_number  = l_parent_bb_ovn; */
            IF g_debug
            THEN
               hr_utility.TRACE ('l_parent_start_time:' || l_parent_start_time
                                );
               hr_utility.TRACE ('l_resource_id:' || l_resource_id);
            END IF;

            -- Find out if any detail records(siblings) for this day
            -- deleted or updated in OTL and not yet transferred to OTLR.
            OPEN c_get_day_bb_id (l_parent_start_time, l_resource_id);

            LOOP
               FETCH c_get_day_bb_id
                INTO l_day_bb_id;

               EXIT WHEN c_get_day_bb_id%NOTFOUND;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_day_bb_id:' || l_day_bb_id);
               END IF;

               -- If such records found in OTL, then find the corresponding
               -- summary record in OTLR, so that the summary and detail rows in HXT
               -- tables can also be deleted to reflect the latest changes in OTL.
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 60);
               END IF;

               l_tim_id := NULL;

               OPEN c_get_sum_id (l_day_bb_id);

               FETCH c_get_sum_id
                INTO l_time_summary_id, l_tim_id;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 70);
                  hr_utility.TRACE ('l_time_summary_id:' || l_time_summary_id);
               END IF;

               -- If corresponding summary record found then delete its details
               -- and the summary record itself from HXT tables.
               IF c_get_sum_id%FOUND
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 80);
                  END IF;

                  hxt_td_util.retro_restrict_edit
                                         (p_tim_id             => l_tim_id,
                                          p_session_date       => SYSDATE,
                                          o_dt_update_mod      => l_dt_update_mode,
                                          o_error_message      => l_otm_error,
                                          o_return_code        => o_return_code,
                                          p_parent_id          => l_time_summary_id
                                         );

                  -- p_timecard_source <> 'Timecard Review' - added for 5137310
		  IF (p_timecard_source <> 'Timecard Review' AND o_return_code = 1) OR l_otm_error IS NOT NULL
                  THEN
                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                         (p_message_table               => p_messages,
                          p_message_name                => 'HXT_TC_CANNOT_BE_CHANGED_TODAY',
                          p_message_token               => NULL,
                          p_message_level               => 'ERROR',
                          p_message_field               => NULL,
                          p_application_short_name      => 'HXT',
                          p_timecard_bb_id              => NULL,
                          p_time_attribute_id           => NULL,
                          p_timecard_bb_ovn             => NULL,
                          p_time_attribute_ovn          => NULL
                         );
                     RETURN;
                  END IF;

		  -- added for 5137310
		  IF(l_dt_update_mode IS NULL)
                  THEN
                     l_dt_update_mode := 'UPDATE';
                  END IF;


                  -- If this is a Retro change(=> l_dt_update_mode returned as 'UPDATE'
                  -- by retro_restrict_edit) then we dont need to synchronize the deletes in
                  -- otlr since now we raise an error message to let the user know that he needs
                  -- to enter zero hours instead of deleting the row.
                  -- This error message is raised only for Retro changes therefore
                  -- synchronize deletes procedure will still be required for
                  -- non Retro timecard changes.
                  --

                  --Bug 4890370 Fix Start
		  IF l_dt_update_mode = 'UPDATE'
		  THEN
		     -- Check if user has entered zero hours while deleting a TC row in which case
		     -- we need to synchronize the deletes in OTLR. We also need to synchronize the deletes
		     -- in case user has replaced straight hours with start/stop time
		     BEGIN
		        SELECT count(*)
                        INTO   l_measure_count
		        FROM   hxc_time_building_blocks
		        WHERE  time_building_block_id = l_day_bb_id
			AND    ((measure = 0)  or (start_time is not null and stop_time is not null))
			AND    scope = 'DETAIL'
		        AND    date_to = hr_general.end_of_time;
		     END;
                  END IF;
		  --Bug 4890370 Fix Ends

                  -- Begin Bug 4590163
                  IF (l_dt_update_mode = 'CORRECTION')
			OR (l_dt_update_mode = 'UPDATE' AND  l_measure_count <> 0)   /*** 4890370 ***/
                  THEN
                     -- End Bug 4590163
                     --
                     -- Delete detail rows associated with summary row.
                     --
                     DELETE FROM hxt_det_hours_worked_f
                           WHERE parent_id = l_time_summary_id;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 90);
                     END IF;

                     --
                     -- Delete the summary row itself.
                     --
                     DELETE FROM hxt_sum_hours_worked_f
                           WHERE ID = l_time_summary_id;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 100);
                     END IF;

                     CLOSE c_get_sum_id;

                     EXIT;
                  END IF;
               END IF;

               CLOSE c_get_sum_id;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 110);
               END IF;
            END LOOP;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 110.5);
            END IF;

            CLOSE c_get_day_bb_id;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 120);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 130);
         END IF;

         l_cnt := l_time_building_blocks.NEXT (l_cnt);
      END LOOP;

      hr_kflex_utility.unset_session_date (p_session_id => l_session_id);
   END;

--------------------------- otm_validate_process ----------------------------
   PROCEDURE otm_validate_process (
      p_operation              IN              VARCHAR2,
      p_time_building_blocks   IN OUT NOCOPY   VARCHAR2,
      p_time_attributes        IN OUT NOCOPY   VARCHAR2,
      p_messages               IN OUT NOCOPY   VARCHAR2
   )
   IS
      l_blocks       hxc_self_service_time_deposit.timecard_info;
      l_attributes   hxc_self_service_time_deposit.app_attributes_info;
      l_messages     hxc_self_service_time_deposit.message_table;
      l_proc         VARCHAR2 (100);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := 'hxt_hxc_retrieval_process.OTM_VALIDATE_PROCESS';
         hr_utility.set_location (l_proc, 10);
         hr_utility.TRACE (   'p_time_building_blocks is : '
                           || SUBSTR (p_time_building_blocks, 1, 2000)
                          );
      END IF;

      l_blocks :=
         hxc_deposit_wrapper_utilities.string_to_blocks
                                                       (p_time_building_blocks);

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 30);
      END IF;

      l_attributes :=
         hxc_deposit_wrapper_utilities.string_to_attributes (p_time_attributes);

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 40);
      END IF;

      l_messages :=
                 hxc_deposit_wrapper_utilities.string_to_messages (p_messages);
      validate_timecard (p_operation                 => p_operation,
                         p_time_building_blocks      => l_blocks,
                         p_time_attributes           => l_attributes,
                         p_messages                  => l_messages
                        );
      p_time_building_blocks :=
                     hxc_deposit_wrapper_utilities.blocks_to_string (l_blocks);
      p_time_attributes :=
             hxc_deposit_wrapper_utilities.attributes_to_string (l_attributes);
      p_messages :=
                 hxc_deposit_wrapper_utilities.messages_to_string (l_messages);
   END otm_validate_process;

--------------------------- validate_timecard ------------------------------
   PROCEDURE validate_timecard (
      p_operation              IN              VARCHAR2,
      p_time_building_blocks   IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_time_attributes        IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_messages               IN OUT NOCOPY   hxc_self_service_time_deposit.message_table
   )
   IS
      CURSOR get_timecard_id (p_tim_sum_id NUMBER)
      IS
         SELECT hshw.tim_id, ht.time_period_id
           FROM hxt_sum_hours_worked hshw, hxt_timecards ht
          WHERE hshw.ID = p_tim_sum_id AND hshw.tim_id = ht.ID;

      CURSOR get_debug
      IS
         SELECT 'X'
           FROM hxc_debug
          WHERE process = 'otm_validate_timecard'
            AND TRUNC (debug_date) <= SYSDATE;

-- local tables
      TYPE t_tim_sum_id_tab IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      l_field_name            hxt_otc_retrieval_interface.t_field_name;
      l_value                 hxt_otc_retrieval_interface.t_value;
      l_context               hxt_otc_retrieval_interface.t_field_name;
      l_category              hxt_otc_retrieval_interface.t_field_name;
      l_segment               hxt_otc_retrieval_interface.t_segment;
      l_bb_id                 NUMBER (15);
      l_ovn                   NUMBER (9);
      l_type                  VARCHAR2 (30);
      l_measure               hxc_time_building_blocks.measure%TYPE;
      l_start_time            DATE;
      l_stop_time             DATE;
      l_date_to               DATE;
      l_parent_bb_id          NUMBER (15);
      l_scope                 VARCHAR2 (30);
      l_resource_id           NUMBER (15);
      l_resource_type         VARCHAR2 (30);
      l_comment_text          VARCHAR2 (2000);
      l_person_id             NUMBER (9);
      l_date_worked           DATE;
      l_effective_date        DATE;
      l_assignment_id         NUMBER (9);
      l_payroll_id            NUMBER (9);
      l_bg_id                 NUMBER (9);
      l_created_tim_sum_id    hxt_sum_hours_worked.ID%TYPE        DEFAULT NULL;
      l_otm_error             VARCHAR2 (240)                      DEFAULT NULL;
      l_oracle_error          VARCHAR2 (512)                      DEFAULT NULL;
      l_time_summary_id       NUMBER;
      l_time_sum_start_date   DATE;
      l_time_sum_end_date     DATE;
      l_earn_policy           VARCHAR2 (30);
      l_task                  VARCHAR2 (30);
      l_hours_type            VARCHAR2 (80);
      l_earn_reason_code      VARCHAR2 (30);
      l_project               VARCHAR2 (30);
      l_location              VARCHAR2 (30);
      l_comment               VARCHAR2 (30);
      l_rate_multiple         NUMBER;
      l_hourly_rate           NUMBER;
      l_amount                NUMBER;
      l_sep_check_flag        VARCHAR2 (30);
      l_hours                 NUMBER;
      l_valid                 VARCHAR2 (1)                              := 'N';
      l_no_times              VARCHAR2 (1)                              := 'N';
      l_new                   VARCHAR2 (30);
      l_session_id            NUMBER;
      l_att                   NUMBER;
      l_debug                 VARCHAR2 (1);
      l_next_index            BINARY_INTEGER                            := 0;
      i                       BINARY_INTEGER;
      loop_ok                 BOOLEAN                                  := TRUE;
      l_time_period_id        NUMBER;
      l_timecard_id           NUMBER;
      l_tim_sum_id_tab        t_tim_sum_id_tab;
      l_timecards             t_tim_sum_id_tab;
      l_cnt                   NUMBER;                          --Added 2804510
      l_cnt_att               NUMBER;                          --Added 2804510
      l_day                   NUMBER;                          --Added 2804510
      e_error                 EXCEPTION;
      l_proc                  VARCHAR2 (100);
      l_delete                VARCHAR2 (1);
      l_tim_sum               BINARY_INTEGER;
      l_state_name            hxt_sum_hours_worked_f.state_name%TYPE;
      l_county_name           hxt_sum_hours_worked_f.county_name%TYPE;
      l_city_name             hxt_sum_hours_worked_f.city_name%TYPE;
      l_zip_code              hxt_sum_hours_worked_f.zip_code%TYPE;
      l_tim_id                NUMBER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         l_proc := 'hxt_hxc_retrieval_process.VALIDATE_TIMECARD';
         hr_utility.set_location (l_proc, 1);
      END IF;

      OPEN get_debug;

      FETCH get_debug
       INTO l_debug;

      IF get_debug%FOUND
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3);
         END IF;
      END IF;

      CLOSE get_debug;

      hxt_time_collection.set_cache (FALSE);
      hr_kflex_utility.set_session_date (p_effective_date      => SYSDATE,
                                         p_session_id          => l_session_id
                                        );

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 4);
      END IF;

      SAVEPOINT otm_validate;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 5);
      END IF;

-- Loop through all the building blocks and validate the details.
-------------------------------------------------------------------------------
--Bug 2804510
--the FOR loop used to loop through p_timecard table has beed removed
--as the Timekeeper doesn't have pl/sql table populated in the ordered manner
--hence p_time_building_blocks.first..p_time_building_blocks.last was failing
--used loop ...end loop control structure for looping
-------------------------------------------------------------------------------

      -- Bugs 3384941, 3382457, 3381642 fix
      -- Added the following FOR LOOP to validate the detail records in the
      -- following order:
      -- Deleted detail records processed first i.e., i = 1
      -- Updated detail records processed next i.e., i = 2
      -- New Inserted detail records processes last i.e., i = 3
      FOR i IN 1 .. 3
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 6);
         END IF;

         l_cnt := p_time_building_blocks.FIRST;                --Added 2804510

         IF g_debug
         THEN
            hr_utility.TRACE ('l_cnt :' || l_cnt);
         END IF;

         LOOP                                                  --Added 2804510
            EXIT WHEN NOT p_time_building_blocks.EXISTS (l_cnt);

            --Added 2804510

            --
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 10);
               hr_utility.TRACE
                        ('***********  NEW TIME BUILDING BLOCK  ************');
            END IF;

            --
            l_bb_id := p_time_building_blocks (l_cnt).time_building_block_id;
            l_ovn := p_time_building_blocks (l_cnt).object_version_number;
            l_type := p_time_building_blocks (l_cnt).TYPE;
            l_measure := p_time_building_blocks (l_cnt).measure;
            l_start_time := p_time_building_blocks (l_cnt).start_time;
            l_stop_time := p_time_building_blocks (l_cnt).stop_time;
            l_parent_bb_id :=
                       p_time_building_blocks (l_cnt).parent_building_block_id;
            l_scope := p_time_building_blocks (l_cnt).SCOPE;
            l_resource_id := p_time_building_blocks (l_cnt).resource_id;
            l_resource_type := p_time_building_blocks (l_cnt).resource_type;
            l_comment_text := p_time_building_blocks (l_cnt).comment_text;
            l_new := p_time_building_blocks (l_cnt).NEW;
            l_no_times := 'N';
            l_date_to := p_time_building_blocks (l_cnt).date_to;


            -- Bug 8486310
            -- Save the Alias Defn put up as per preferences if it is not already
            -- there. This would be done only once per timecard, and would
            -- use the first block's start_time -- meaning the Timecard Scope's
            -- start time.
            IF g_alias_id IS NULL
            THEN
               g_alias_id := hxc_preference_evaluation.resource_preferences ( l_resource_id,
                                                                             'TC_W_TCRD_ALIASES',
                                                                             1,
                                                                             l_start_time
                                                                             );
            END IF;

            --
            IF g_debug
            THEN
               hr_utility.TRACE ('Time BB ID is : ' || TO_CHAR (l_bb_id));
               hr_utility.TRACE ('Type is : ' || l_type);
               hr_utility.TRACE ('Measure is : ' || TO_CHAR (l_measure));
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
               hr_utility.TRACE ('l_resource_id is '
                                 || TO_CHAR (l_resource_id)
                                );
               hr_utility.TRACE ('l_resource_type is ' || l_resource_type);
               --
               hr_utility.TRACE (   'UOM is : '
                                 || p_time_building_blocks (l_cnt).unit_of_measure
                                );
               hr_utility.TRACE
                  (   'Parent BB ID is : '
                   || TO_CHAR
                         (p_time_building_blocks (l_cnt).parent_building_block_id
                         )
                  );
               hr_utility.TRACE (   'PARENT_IS_NEW is : '
                                 || p_time_building_blocks (l_cnt).parent_is_new
                                );
               hr_utility.TRACE
                  (   'OVN is : '
                   || TO_CHAR
                          (p_time_building_blocks (l_cnt).object_version_number
                          )
                  );
               hr_utility.TRACE (   'APPROVAL_STATUS is : '
                                 || p_time_building_blocks (l_cnt).approval_status
                                );
               hr_utility.TRACE
                     (   'APPROVAL_STYLE_ID is : '
                      || TO_CHAR
                              (p_time_building_blocks (l_cnt).approval_style_id
                              )
                     );
               hr_utility.TRACE
                            (   'DATE_FROM is : '
                             || TO_CHAR
                                     (p_time_building_blocks (l_cnt).date_from,
                                      'DD-MON-YYYY'
                                     )
                            );
               hr_utility.TRACE
                              (   'DATE_TO is : '
                               || TO_CHAR
                                       (p_time_building_blocks (l_cnt).date_to,
                                        'DD-MON-YYYY'
                                       )
                              );
               hr_utility.TRACE (   'COMMENT_TEXT is : '
                                 || p_time_building_blocks (l_cnt).comment_text
                                );
               hr_utility.TRACE
                  (   'Parent OVN is : '
                   || TO_CHAR
                         (p_time_building_blocks (l_cnt).parent_building_block_ovn
                         )
                  );
               hr_utility.TRACE (   'NEW is : '
                                 || p_time_building_blocks (l_cnt).NEW
                                );
               --
               --
               hr_utility.set_location (l_proc, 20);
            END IF;

--Bug 2966729
--Description
--We ensure that if the block is deleted then it must be an existing block
--and not a new entry. In that case the existing blocks would get deleted from the hxt tables.
--If the block is deleted and its a new block then we dont delete them in
--the hxt tables as this does not have any meaning.
--We send non deleted blocks to hxt tables as usual.
--Bug 2966729 over

            --

            -- Bugs 3384941, 3382457, 3381642 fix
            IF     (   (    (   (l_type = 'MEASURE' AND l_measure IS NOT NULL
                                )
                             OR (    l_type = 'RANGE'
                                 AND l_start_time IS NOT NULL
                                 AND l_stop_time IS NOT NULL
                                )
                            )
                        AND (          -- First process deleted detail records
                                (    l_date_to <> hr_general.end_of_time
                                 AND l_new = 'N'
                                 AND i = 1
                                )
                             -- Next process the updated detail records
                             OR (    l_date_to = hr_general.end_of_time
                                 AND l_new = 'N'
                                 AND i = 2
                                )
                             -- And the last to be processed are the Inserts
                             OR (    l_date_to = hr_general.end_of_time
                                 AND l_new = 'Y'
                                 AND i = 3
                                )
                            )                                        --2966729
                       )
                    -- bug 3650967
                    OR (    (   (l_type = 'MEASURE' AND l_measure IS NULL)
                             OR (    l_type = 'RANGE'
                                 AND l_start_time IS NULL
                                 AND l_stop_time IS NULL
                                )
                            )
                        AND l_date_to <> hr_general.end_of_time
                        AND l_new = 'N'
                        AND i = 1
                       )
                   -- bug 3650967
                   )
               AND l_scope = 'DETAIL'
            THEN
--       (l_date_to = hr_general.end_of_time) THEN

               --Bug 2770487 Sonarasi 04-Apr-2003
--Commented the above check l_date_to = hr_general.end_of_time because we need
--the deleted blocks also to be considered for explosion.
--Bug 2770487 Sonarasi Over

               --
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 21);
               END IF;

               l_valid := 'Y';
            ELSE
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 22);
               END IF;

               l_valid := 'N';
            END IF;

            --
            -- Only care about valid DETAIL Blocks.
            --
            IF l_valid = 'Y'
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 23);
               END IF;

               -- Get the start and stop times from the parent DAY block if DETAIL is
               -- a measure.
               IF    l_type = 'MEASURE' AND l_start_time IS NULL
                  -- start bug 3650967
                  OR (   (l_type = 'MEASURE' AND l_measure IS NULL)
                      OR     (    l_type = 'RANGE'
                              AND l_start_time IS NULL
                              AND l_stop_time IS NULL
                             )
                         AND l_date_to <> hr_general.end_of_time
                         AND l_new = 'N'
                         AND i = 1
                     )                                      -- end bug 3650967
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 24);
                  END IF;

                  l_day := p_time_building_blocks.FIRST;       --Added 2804510

                  LOOP                                         --Added 2804510
                     EXIT WHEN NOT p_time_building_blocks.EXISTS (l_day);

                     --Added 2804510
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 30);
                     END IF;

                     IF     (p_time_building_blocks (l_day).time_building_block_id =
                                                                l_parent_bb_id
                            )
                        AND (p_time_building_blocks (l_day).SCOPE = 'DAY')
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 31);
                        END IF;

                        --
                        l_start_time :=
                                     p_time_building_blocks (l_day).start_time;
                        l_stop_time :=
                                      p_time_building_blocks (l_day).stop_time;
                        l_no_times := 'Y';

                        --
                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_start_time is '
                                             || TO_CHAR
                                                       (l_start_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                            );
                           hr_utility.TRACE (   'l_stop_time is '
                                             || TO_CHAR
                                                       (l_stop_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                            );
                        END IF;

                        EXIT;
                     END IF;

                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 32);
                     END IF;

                     l_day := p_time_building_blocks.NEXT (l_day);
                  --Added 2804510
                  END LOOP;                                    --Added 2804510

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 33);
                  END IF;
               END IF;                                     -- l_type = MEASURE

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 34);
               END IF;

               l_person_id := NULL;

               IF l_resource_type = 'PERSON'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 35);
                  END IF;

                  l_person_id := l_resource_id;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'l_person_id is '
                                       || TO_CHAR (l_person_id)
                                      );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 36);
               END IF;

               l_effective_date := TRUNC (l_start_time);

               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_effective_date is :'
                                    || TO_CHAR (l_effective_date,
                                                'DD-MON-YYYY'
                                               )
                                   );
               END IF;

               BEGIN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 37);
                  END IF;

                  SELECT full_name, business_group_id
                    INTO hxt_otc_retrieval_interface.g_full_name, l_bg_id
                    FROM per_all_people_f
                   WHERE person_id = l_person_id
                     AND l_effective_date BETWEEN effective_start_date
                                              AND effective_end_date;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 38);
                     END IF;

                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                           (p_message_table               => p_messages,
                            p_message_name                => 'HR_52365_PTU_NO_PERSON_EXISTS',
                            p_message_token               => NULL,
                            p_message_level               => 'ERROR',
                            p_message_field               => NULL,
                            p_application_short_name      => 'PER',
                            p_timecard_bb_id              => l_bb_id,
                            p_time_attribute_id           => NULL,
                            p_timecard_bb_ovn             => l_ovn,
                            p_time_attribute_ovn          => NULL
                           );
                     RAISE e_error;
               END;

               -- Get Employee Number
               --
               -- l_employee_number := hxt_otc_retrieval_interface.get_employee_number(
               --                                             l_person_id,
               --                                             l_effective_date);
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 39);
               END IF;

               hxt_otc_retrieval_interface.get_assignment_id
                                         (p_person_id           => l_person_id,
                                          p_payroll_id          => l_payroll_id,
                                          p_bg_id               => l_bg_id,
                                          p_assignment_id       => l_assignment_id,
                                          p_effective_date      => l_effective_date
                                         );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               l_field_name.DELETE;
               l_value.DELETE;
               l_category.DELETE;
               l_context.DELETE;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 55);
                  hr_utility.TRACE (   'number of attr is : '
                                    || TO_CHAR (p_time_attributes.COUNT)
                                   );
               END IF;

               -- Get the attributes for this detail building block.
               IF p_time_attributes.COUNT <> 0
               THEN
                  l_att := 1;
                  l_cnt_att := p_time_attributes.FIRST;       --Added 2804510

                  LOOP                                        --Added 2804510
                     EXIT WHEN NOT p_time_attributes.EXISTS (l_cnt_att);

                     --Added 2804510
                     IF l_bb_id =
                              p_time_attributes (l_cnt_att).building_block_id
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                           ('------ In Attribute Loop ------');
                        END IF;

                        l_field_name (l_att) :=
                                  p_time_attributes (l_cnt_att).attribute_name;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_field_name(l_att) is '
                                             || l_field_name (l_att)
                                            );
                        END IF;

                        l_value (l_att) :=
                                 p_time_attributes (l_cnt_att).attribute_value;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_value(l_att) is '
                                             || l_value (l_att)
                                            );
                        END IF;

                        l_context (l_att) :=
                               p_time_attributes (l_cnt_att).bld_blk_info_type;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_context(l_att) is '
                                             || l_context (l_att)
                                            );
                        END IF;

                        l_category (l_att) :=
                                        p_time_attributes (l_cnt_att).CATEGORY;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_category(l_att) is '
                                             || l_category (l_att)
                                            );
                        END IF;

                        l_att := l_att + 1;
                     END IF;

                     l_cnt_att := p_time_attributes.NEXT (l_cnt_att);
                  --Added 2804510
                  END LOOP;                                    --Added 2804510
               END IF;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_att is ' || TO_CHAR (l_att));
                  hr_utility.set_location (l_proc, 60);
               END IF;

               hxt_otc_retrieval_interface.parse_attributes
                                          (p_category           => l_category,
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
                                           p_project            => l_project,
                                           p_task               => l_task,
                                           p_state_name         => l_state_name,
                                           p_county_name        => l_county_name,
                                           p_city_name          => l_city_name,
                                           p_zip_code           => l_zip_code
                                          );

               IF (l_no_times = 'Y')
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 61);
                  END IF;

                  l_start_time := NULL;
                  l_stop_time := NULL;
               END IF;

               l_time_summary_id := NULL;
               l_time_sum_start_date := NULL;
               l_time_sum_end_date := NULL;

               IF l_new = 'N'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 62);
                  END IF;

                  -- Bug 7415291
                  -- Added new parameter l_tim_id
                  hxt_otc_retrieval_interface.find_existing_timecard
                              (p_payroll_id               => l_payroll_id,
                               p_date_worked              => l_date_worked,
                               p_person_id                => l_person_id,
                               p_old_ovn                  => l_ovn,
                               p_bb_id                    => l_bb_id,
                               p_time_summary_id          => l_time_summary_id,
                               p_time_sum_start_date      => l_time_sum_start_date,
                               p_time_sum_end_date        => l_time_sum_end_date,
                               p_tim_id                   => l_tim_id
                              );

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 63);
                     hr_utility.TRACE ('after find_existing_timecard');
                     hr_utility.TRACE (   'l_time_summary_id is: '
                                       || TO_CHAR (l_time_summary_id)
                                      );
                  END IF;

                  IF l_time_summary_id IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 64);
                     END IF;

                     DELETE FROM hxt_det_hours_worked_f
                           WHERE parent_id = l_time_summary_id;
                  END IF;
               END IF;

               --Bug 2770487 Sonarasi 04-Apr-2003
               IF (l_date_to = hr_general.end_of_time)
               THEN
                  l_delete := 'N';
               ELSE
                  l_delete := 'Y';
               END IF;

--Here We are setting the delete flag based on whether we would like to
--delete the blocks or retail them.Therefore those blocks which are end
--dated will have the l_delete flag set to 'Y'. We will be passing the
--l_delete as a value to the parameter delete_yn of the record_time api.
--Bug 2770487 Sonarasi Over
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 65);
               END IF;

               hxt_time_collection.record_time
                             (timecard_source                => 'Time Store',
                              employee_number                => TO_CHAR
                                                                   (l_person_id
                                                                   )
                                                                    -- l_employee_number
               ,
                              batch_name                     => 'OTL_SS_DEP_VAL',
                              date_worked                    => l_date_worked,
                              start_time                     => l_start_time,
                              end_time                       => l_stop_time,
                              hours                          => l_hours,
                              wage_code                      => NULL,
                              earning_policy                 => l_earn_policy,
                              hours_type                     => l_hours_type,
                              earn_reason_code               => l_earn_reason_code,
                              project                        => l_project,
                              task_number                    => l_task,
                              location_code                  => l_location,
                              COMMENT                        => l_comment,
                              rate_multiple                  => l_rate_multiple,
                              hourly_rate                    => l_hourly_rate,
                              amount                         => l_amount,
                              separate_check_flag            => l_sep_check_flag,
                              business_group_id              => l_bg_id,
                              cost_segment1                  => l_segment (1),
                              cost_segment2                  => l_segment (2),
                              cost_segment3                  => l_segment (3),
                              cost_segment4                  => l_segment (4),
                              cost_segment5                  => l_segment (5),
                              cost_segment6                  => l_segment (6),
                              cost_segment7                  => l_segment (7),
                              cost_segment8                  => l_segment (8),
                              cost_segment9                  => l_segment (9),
                              cost_segment10                 => l_segment (10),
                              cost_segment11                 => l_segment (11),
                              cost_segment12                 => l_segment (12),
                              cost_segment13                 => l_segment (13),
                              cost_segment14                 => l_segment (14),
                              cost_segment15                 => l_segment (15),
                              cost_segment16                 => l_segment (16),
                              cost_segment17                 => l_segment (17),
                              cost_segment18                 => l_segment (18),
                              cost_segment19                 => l_segment (19),
                              cost_segment20                 => l_segment (20),
                              cost_segment21                 => l_segment (21),
                              cost_segment22                 => l_segment (22),
                              cost_segment23                 => l_segment (23),
                              cost_segment24                 => l_segment (24),
                              cost_segment25                 => l_segment (25),
                              cost_segment26                 => l_segment (26),
                              cost_segment27                 => l_segment (27),
                              cost_segment28                 => l_segment (28),
                              cost_segment29                 => l_segment (29),
                              cost_segment30                 => l_segment (30),
                              time_summary_id                => l_time_summary_id,
                              tim_sum_eff_start_date         => l_time_sum_start_date,
                              tim_sum_eff_end_date           => l_time_sum_end_date,
                              created_by                     => '-1',
                              last_updated_by                => '-1',
                              last_update_login              => '-1',
                              dt_update_mode                 => 'CORRECTION',
                              created_tim_sum_id             => l_created_tim_sum_id,
                              otm_error                      => l_otm_error,
                              oracle_error                   => l_oracle_error,
                              p_time_building_block_id       => l_bb_id,
                              p_time_building_block_ovn      => l_ovn,
                              p_validate                     => FALSE,
                              delete_yn                      => l_delete,
                              p_state_name                   => l_state_name,
                              p_county_name                  => l_county_name,
                              p_city_name                    => l_city_name,
                              p_zip_code                     => l_zip_code
                             );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 66);
               END IF;

               IF g_otm_messages.COUNT > 0
               THEN
                  FOR i IN g_otm_messages.FIRST .. g_otm_messages.LAST
                  LOOP
                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                        (p_message_table               => p_messages,
                         p_message_name                => g_otm_messages (i).message_name,
                         p_message_token               => g_otm_messages (i).message_tokens,
                         p_message_level               => g_otm_messages (i).message_level,
                         p_message_field               => NULL,
                         p_application_short_name      => g_otm_messages (i).application_short_name,
                         p_timecard_bb_id              => l_bb_id,
                         p_time_attribute_id           => NULL,
                         p_timecard_bb_ovn             => l_ovn,
                         p_time_attribute_ovn          => NULL
                        );
                  END LOOP;

                  g_otm_messages.DELETE;
                  l_otm_error := NULL;
                  l_oracle_error := NULL;
                  RAISE e_error;
               ELSE
                  --to capture any errors which are not added to g_otm_messages table but
                  --l_otm_error has not null values
                  IF l_otm_error IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 1000);
                        hr_utility.TRACE ('l_otm_error :' || l_otm_error);
                     END IF;

                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => p_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_OTMERR',
                                   p_message_token               => SUBSTR
                                                                       (   'ERROR&'
                                                                        || l_otm_error,
                                                                        1,
                                                                        100
                                                                       ),
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );
                     RAISE e_error;
                  END IF;

                  IF l_oracle_error IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 1050);
                        hr_utility.TRACE ('l_oracle_error :' || l_oracle_error
                                         );
                     END IF;

                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => p_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_ORAERR',
                                   p_message_token               =>    'ERROR&'
                                                                    || l_oracle_error,
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );
                     RAISE e_error;
                  END IF;
               END IF;                                        --g_otm_messages

               l_next_index := l_next_index + 1;
               l_tim_sum_id_tab (l_next_index) := l_created_tim_sum_id;
            END IF;                        -- l_valid = Y and l_scope = DETAIL

            l_cnt := p_time_building_blocks.NEXT (l_cnt);      --Added 2804510
         END LOOP;                                             --Added 2804510
      END LOOP;

      l_timecards.DELETE;
      l_tim_sum := l_tim_sum_id_tab.FIRST;

      LOOP
         EXIT WHEN NOT l_tim_sum_id_tab.EXISTS (l_tim_sum);

         --Bug 2770487 Sonarasi 04-Apr-2003
         --the following if condition i.e if l_tim_sum_id_tab(l_tim_sum) is not null then
         --is added because incase of deleted blocks we may have null time summary ids
         --this may cause problems if the time summary id table returns a null value
         --Hence adding a check to prevent that scenario.
         --Bug 2770487 Sonarasi Over
         IF l_tim_sum_id_tab (l_tim_sum) IS NOT NULL
         THEN
            DELETE FROM hxt_det_hours_worked_f
                  WHERE parent_id = l_tim_sum_id_tab (l_tim_sum);

            OPEN get_timecard_id (p_tim_sum_id      => l_tim_sum_id_tab
                                                                    (l_tim_sum)
                                 );

            FETCH get_timecard_id
             INTO l_timecard_id, l_time_period_id;

            IF (get_timecard_id%FOUND)
            THEN
               IF g_debug
               THEN
                  hr_utility.TRACE (   'TIM_SUM_ID IS : '
                                    || TO_CHAR (l_tim_sum_id_tab (l_tim_sum))
                                   );
                  hr_utility.TRACE (   'l_timecard_id is : '
                                    || TO_CHAR (l_timecard_id)
                                   );
                  hr_utility.TRACE (   'l_time_period_id is : '
                                    || TO_CHAR (l_time_period_id)
                                   );
               END IF;

               IF (NOT l_timecards.EXISTS (l_time_period_id))
               THEN
                  l_timecards (l_time_period_id) := l_timecard_id;
               END IF;
            END IF;

            CLOSE get_timecard_id;
         END IF;             --if l_tim_sum_id_tab(l_tim_sum) is not null then

         l_tim_sum := l_tim_sum_id_tab.NEXT (l_tim_sum);
      END LOOP;

      loop_ok := TRUE;
      i := l_timecards.FIRST;

      IF i IS NOT NULL
      THEN
         WHILE loop_ok
         LOOP
            hxt_time_collection.re_explode_timecard
                                             (timecard_id             => l_timecards
                                                                            (i),
                                              tim_eff_start_date      => NULL,
                                              -- Not Being Used
                                              tim_eff_end_date        => NULL,
                                              -- Not Being Used
                                              dt_update_mode          => 'CORRECTION',
                                              otm_error               => l_otm_error,
                                              oracle_error            => l_oracle_error
                                             );

            IF g_otm_messages.COUNT > 0
            THEN
               FOR i IN g_otm_messages.FIRST .. g_otm_messages.LAST
               LOOP
                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                     (p_message_table               => g_messages,
                      p_message_name                => g_otm_messages (i).message_name,
                      p_message_token               => g_otm_messages (i).message_tokens,
                      p_message_level               => g_otm_messages (i).message_level,
                      p_message_field               => NULL,
                      p_application_short_name      => g_otm_messages (i).application_short_name,
                      p_timecard_bb_id              => l_bb_id,
                      p_time_attribute_id           => NULL,
                      p_timecard_bb_ovn             => l_ovn,
                      p_time_attribute_ovn          => NULL
                     );
               END LOOP;

               g_otm_messages.DELETE;
               l_otm_error := NULL;
               l_oracle_error := NULL;
               RAISE e_error;
            ELSE
               --to capture any errors which are not added to g_otm_messages table but
               --l_otm_error has not null values
               IF l_otm_error IS NOT NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 2000);
                     hr_utility.TRACE ('l_otm_error :' || l_otm_error);
                  END IF;

                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => g_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_OTMERR',
                                   p_message_token               => SUBSTR
                                                                       (   'ERROR&'
                                                                        || l_otm_error,
                                                                        1,
                                                                        100
                                                                       ),
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'g_messages.message_name is : '
                                       || g_messages (1).message_name
                                      );
                  END IF;

                  RAISE e_error;
               END IF;

               IF l_oracle_error IS NOT NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 2050);
                     hr_utility.TRACE ('l_oracle_error :' || l_oracle_error);
                  END IF;

                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => g_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_ORAERR',
                                   p_message_token               =>    'ERROR&'
                                                                    || l_oracle_error,
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'g_messages.message_name is : '
                                       || g_messages (1).message_name
                                      );
                  END IF;

                  RAISE e_error;
               END IF;
            END IF;

            i := l_timecards.NEXT (i);

            IF i IS NULL
            THEN
               loop_ok := FALSE;
            END IF;
         END LOOP;
      END IF;

      hr_kflex_utility.unset_session_date (p_session_id => l_session_id);
      ROLLBACK TO otm_validate;

      IF g_debug
      THEN
         hr_utility.TRACE ('After RollBack');
      END IF;
   EXCEPTION
      WHEN e_error
      THEN
         ROLLBACK TO otm_validate;
         RETURN;
      WHEN OTHERS
      THEN
         ROLLBACK TO otm_validate;
         RETURN;
   END validate_timecard;

   FUNCTION test_aps_vs_rtr (
      p_rtr_tr   t_time_recipient,
      p_aps_tr   t_time_recipient
   )
      RETURN BOOLEAN
   IS
      l_rtr_index   BINARY_INTEGER;
      l_return      BOOLEAN        := FALSE;
   BEGIN
      l_rtr_index := p_rtr_tr.FIRST;

      WHILE (l_rtr_index IS NOT NULL)
      LOOP
         IF NOT p_aps_tr.EXISTS (l_rtr_index)
         THEN
            l_return := TRUE;
            EXIT;
         END IF;

         l_rtr_index := p_rtr_tr.NEXT (l_rtr_index);
      END LOOP;

      RETURN l_return;
   END test_aps_vs_rtr;

---------------------- otlr validation required ---------------------
   PROCEDURE otlr_validation_required (
      p_operation              IN              VARCHAR2,
      p_otm_explosion          IN              VARCHAR2,
      p_otm_rtr_id             IN              NUMBER,
      p_app_set_id             IN              NUMBER,
      p_timecard_id            IN              NUMBER,
      p_timecard_ovn           IN              NUMBER,
      p_time_building_blocks   IN              hxc_self_service_time_deposit.timecard_info,
      p_time_att_info          IN              hxc_self_service_time_deposit.app_attributes_info,
      p_messages               IN OUT NOCOPY   hxc_self_service_time_deposit.message_table
   )
   IS
      -- retrieves list of time recipients in retrieval rule group
      CURSOR csr_get_rtr (p_rtr_id NUMBER)
      IS
         SELECT DISTINCT (rrc.time_recipient_id)
                    FROM hxc_retrieval_rule_comps rrc,
                         hxc_retrieval_rules rr
                   WHERE rr.retrieval_rule_id = p_rtr_id
                     AND rrc.retrieval_rule_id = rr.retrieval_rule_id
                     AND rrc.status <> 'WORKING';

      -- retrieves list of time recipients in application set
      CURSOR csr_get_app_sets (p_app_set_id NUMBER)
      IS
         SELECT apsc.time_recipient_id
           FROM hxc_application_set_comps_v apsc, hxc_application_sets_v aps
          WHERE aps.application_set_id = p_app_set_id
            AND apsc.application_set_id = aps.application_set_id;

      t_aps_tr                 t_time_recipient;
      t_rtr_tr                 t_time_recipient;
      l_rtr_tr_id              hxc_time_recipients.time_recipient_id%TYPE;
      l_aps_tr_id              hxc_time_recipients.time_recipient_id%TYPE;
      l_time_building_blocks   hxc_self_service_time_deposit.timecard_info
                                                     := p_time_building_blocks;
      l_time_att_info          hxc_self_service_time_deposit.app_attributes_info
                                                            := p_time_att_info;
      l_proc                   VARCHAR2 (250);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF (p_otm_explosion = 'Y')
      THEN
         -- Get the application set time recipients
         OPEN csr_get_app_sets (p_app_set_id);

         FETCH csr_get_app_sets
          INTO l_aps_tr_id;

         WHILE csr_get_app_sets%FOUND
         LOOP
            t_aps_tr (l_aps_tr_id) := 'N';

            FETCH csr_get_app_sets
             INTO l_aps_tr_id;
         END LOOP;

         CLOSE csr_get_app_sets;

         IF (p_otm_rtr_id IS NULL)
         THEN
            hxc_time_entry_rules_utils_pkg.add_error_to_table
               (p_message_table               => p_messages,
                p_message_name                => 'HR_6153_ALL_PROCEDURE_FAIL',
                p_application_short_name      => 'PAY',
                p_message_token               => 'PROCEDURE&no rtr id for rules evaluation&STEP&2',
                p_message_level               => 'ERROR',
                p_message_field               => NULL,
                p_timecard_bb_id              => p_timecard_id,
                p_time_attribute_id           => NULL,
                p_timecard_bb_ovn             => p_timecard_ovn,
                p_time_attribute_ovn          => NULL
               );
         END IF;                                         -- is otm rtr is null

         OPEN csr_get_rtr (p_otm_rtr_id);

         FETCH csr_get_rtr
          INTO l_rtr_tr_id;

         WHILE csr_get_rtr%FOUND
         LOOP
            t_rtr_tr (l_rtr_tr_id) := 'N';

            FETCH csr_get_rtr
             INTO l_rtr_tr_id;
         END LOOP;

         CLOSE csr_get_rtr;

         -- Now test to see if the retrieval rule group time recipients
         -- is at least a subset of the application set time recipients
         IF (test_aps_vs_rtr (t_rtr_tr, t_aps_tr))
         THEN
            hxc_time_entry_rules_utils_pkg.add_error_to_table
                                 (p_message_table           => p_messages,
                                  p_message_name            => 'HXC_VLD_APS_VS_RTR_GRP',
                                  p_message_token           => NULL,
                                  p_message_level           => 'ERROR',
                                  p_message_field           => NULL,
                                  p_timecard_bb_id          => p_timecard_id,
                                  p_time_attribute_id       => NULL,
                                  p_timecard_bb_ovn         => p_timecard_ovn,
                                  p_time_attribute_ovn      => NULL
                                 );
         END IF;

         -- skip this if we are SAVING
         IF g_debug
         THEN
            l_proc := 'hxt_hxc_retrieval_process.otlr_validation_required';
            hr_utility.TRACE ('p_operation:' || p_operation);
         END IF;

         SAVEPOINT rollback_validation;

         -- Bug 7557568
         -- Added call to this function to find out if there was any
         -- deleted detail, which came in after a SAVE.
         check_restrict_edit(p_time_building_blocks,
                             p_messages);

         IF p_messages.COUNT > 0
         THEN
            ROLLBACK TO rollback_validation;
            RETURN;
         END IF;

         -- Bug 3321951 fix start.
         synchronize_deletes_in_otlr
                            (p_time_building_blocks      => l_time_building_blocks,
                             p_time_att_info             => l_time_att_info,
                             p_messages                  => p_messages,
                             p_timecard_source		 => NULL
                            );

         IF p_messages.COUNT > 0
         THEN
            ROLLBACK TO rollback_validation;
            RETURN;
         END IF;

         -- Bug 3321951 fix stop.
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 20);
         END IF;

         -- need to do OTM validation
         validate_timecard (p_operation                 => p_operation,
                            p_time_building_blocks      => l_time_building_blocks,
                            p_time_attributes           => l_time_att_info,
                            p_messages                  => p_messages
                           );
         ROLLBACK TO rollback_validation;
      END IF;
   END otlr_validation_required;

--
------------------------------ otlr_review_details -----------------------------
--
   PROCEDURE otlr_review_details (
      p_time_building_blocks   IN              hxc_self_service_time_deposit.timecard_info,
      p_time_attributes        IN              hxc_self_service_time_deposit.app_attributes_info,
      p_messages               IN OUT NOCOPY   hxc_self_service_time_deposit.message_table,
      p_detail_build_blocks    IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info,
      p_detail_attributes      IN OUT NOCOPY   hxc_self_service_time_deposit.building_block_attribute_info
   )
   IS
      CURSOR get_otm_records (p_tim_sum_id NUMBER)
      IS
         SELECT date_worked, hours, time_in, time_out, element_type_id
           FROM hxt_det_hours_worked
          WHERE parent_id = p_tim_sum_id;

      CURSOR get_timecard_id (p_tim_sum_id NUMBER)
      IS
         SELECT hshw.tim_id, ht.time_period_id
           FROM hxt_sum_hours_worked hshw, hxt_timecards ht
          WHERE hshw.ID = p_tim_sum_id AND hshw.tim_id = ht.ID;

      CURSOR get_debug
      IS
         SELECT 'X'
           FROM hxc_debug
          WHERE process = 'hxt_hxc_retrieval_process'
            AND TRUNC (debug_date) <= SYSDATE;

      TYPE t_tim_sum_id_tab IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      l_timecard_detail          hxc_self_service_time_deposit.timecard_info;
      l_detail_attributes        hxc_self_service_time_deposit.app_attributes_info;
      l_field_name               hxt_otc_retrieval_interface.t_field_name;
      l_value                    hxt_otc_retrieval_interface.t_value;
      l_context                  hxt_otc_retrieval_interface.t_field_name;
      l_category                 hxt_otc_retrieval_interface.t_field_name;
      l_segment                  hxt_otc_retrieval_interface.t_segment;
      l_bb_id                    NUMBER (15);
      l_bb_ovn                   NUMBER (15);
      l_type                     VARCHAR2 (30);
      l_measure                  hxc_time_building_blocks.measure%TYPE;
      l_uom                      hxc_time_building_blocks.unit_of_measure%TYPE;
      l_start_time               DATE;
      l_stop_time                DATE;
      l_parent_bb_id             NUMBER (15);
      l_parent_bb_ovn            NUMBER (15);
      l_parent_new               VARCHAR2 (1);
      l_scope                    VARCHAR2 (30);
      l_resource_id              NUMBER (15);
      l_resource_type            VARCHAR2 (30);
      l_comment_text             VARCHAR2 (2000);
      l_appr_status              hxc_time_building_blocks.approval_status%TYPE;
      l_appr_style_id            hxc_time_building_blocks.approval_style_id%TYPE;
      l_date_from                hxc_time_building_blocks.date_from%TYPE;
      l_date_to                  hxc_time_building_blocks.date_to%TYPE;
      l_person_id                NUMBER (9);
      l_date_worked              DATE;
      l_effective_date           DATE;
      l_assignment_id            NUMBER (9);
      l_payroll_id               NUMBER (9);
      l_bg_id                    NUMBER (9);
      l_created_tim_sum_id       hxt_sum_hours_worked.ID%TYPE     DEFAULT NULL;
      l_otm_error                VARCHAR2 (240)                   DEFAULT NULL;
      l_oracle_error             VARCHAR2 (512)                   DEFAULT NULL;
      l_time_summary_id          NUMBER;
      l_time_sum_start_date      DATE;
      l_time_sum_end_date        DATE;
      l_project                  VARCHAR2 (30);
      l_task                     VARCHAR2 (30);
      l_hours_type               VARCHAR2 (80);
      l_comment                  VARCHAR2 (30);
      l_hours                    NUMBER;
      l_valid                    VARCHAR2 (1)                           := 'N';
      l_no_times                 VARCHAR2 (1)                           := 'N';
      l_new                      VARCHAR2 (30);
      l_session_id               NUMBER;
      l_att                      NUMBER;
      l_proc                     VARCHAR2 (100);
      detail_date_worked         hxt_det_hours_worked_f.date_worked%TYPE;
      detail_hours               hxt_det_hours_worked_f.hours%TYPE;
      detail_time_in             hxt_det_hours_worked_f.time_in%TYPE;
      detail_time_out            hxt_det_hours_worked_f.time_out%TYPE;
      detail_hours_type          hxt_det_hours_worked_f.element_type_id%TYPE;
      detail_type                VARCHAR2 (30);
      l_det_cnt                  NUMBER (15);
      l_min_bb_id                NUMBER (15);
      l_next_index               BINARY_INTEGER                           := 0;
      l_next_att_index           BINARY_INTEGER                           := 0;
      l_master_index             BINARY_INTEGER                           := 0;
      l_num_rec                  NUMBER                                   := 0;
      l_time_building_block_id   NUMBER                                   := 0;
      l_time_attribute_id        NUMBER                                   := 0;
      i                          BINARY_INTEGER;
      loop_ok                    BOOLEAN                               := TRUE;
      l_time_period_id           NUMBER;
      l_timecard_id              NUMBER;
      l_debug                    VARCHAR2 (1);
      l_tim_sum_id_tab           t_tim_sum_id_tab;
      l_timecards                t_tim_sum_id_tab;
      l_delete                   VARCHAR2 (1);
      l_hrstype_entered          VARCHAR2 (1)                           := 'N';
      l_tim_sum                  BINARY_INTEGER;
      -- Bug 3012684
      l_error_flag               VARCHAR2 (1)                           := 'N';
      l_state_name               hxt_sum_hours_worked_f.state_name%TYPE;
      l_county_name              hxt_sum_hours_worked_f.county_name%TYPE;
      l_city_name                hxt_sum_hours_worked_f.city_name%TYPE;
      l_zip_code                 hxt_sum_hours_worked_f.zip_code%TYPE;
      l_time_building_blocks     hxc_self_service_time_deposit.timecard_info
                                                     := p_time_building_blocks;
      l_time_attributes          hxc_self_service_time_deposit.app_attributes_info
                                                          := p_time_attributes;
      l_tim_id                   NUMBER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

      OPEN get_debug;

      FETCH get_debug
       INTO l_debug;

      IF get_debug%FOUND
      THEN
         hr_utility.trace_on (NULL, 'OTLR');
      END IF;

      hxt_time_collection.set_cache (FALSE);

      CLOSE get_debug;

      SAVEPOINT review_details;

      -- Bug 8655664
      -- Nulling out the global tables so that the earlier values
      -- are lost.
      g_alias_id := NULL;
      g_an_id.DELETE;

      synchronize_deletes_in_otlr
                            (p_time_building_blocks      => l_time_building_blocks,
                             p_time_att_info             => l_time_attributes,
                             p_messages                  => p_messages,
			     p_timecard_source           => 'Timecard Review'
                            );

      IF p_messages.COUNT > 0
      THEN
         ROLLBACK TO review_details;
         RETURN;
      END IF;

      IF g_debug
      THEN
         l_proc := 'hxt_hxc_retrieval_process.otlr_review_details';
         hr_utility.TRACE ('******** IN POPULATE DETAILS **********');
      END IF;

      IF l_timecard_detail.COUNT > 0
      THEN
         -- Bug 8486310
         -- Alright, when we are Deleting the table, why NULL out first ??
         /*
         FOR l IN l_timecard_detail.FIRST .. l_timecard_detail.LAST
         LOOP
            l_timecard_detail (l).time_building_block_id := NULL;
            l_timecard_detail (l).TYPE := NULL;
            l_timecard_detail (l).measure := NULL;
            l_timecard_detail (l).unit_of_measure := NULL;
            l_timecard_detail (l).start_time := NULL;
            l_timecard_detail (l).stop_time := NULL;
            l_timecard_detail (l).parent_building_block_id := NULL;
            l_timecard_detail (l).parent_is_new := NULL;
            l_timecard_detail (l).SCOPE := NULL;
            l_timecard_detail (l).object_version_number := NULL;
            l_timecard_detail (l).approval_status := NULL;
            l_timecard_detail (l).resource_id := NULL;
            l_timecard_detail (l).resource_type := NULL;
            l_timecard_detail (l).approval_style_id := NULL;
            l_timecard_detail (l).date_from := NULL;
            l_timecard_detail (l).date_to := NULL;
            l_timecard_detail (l).comment_text := NULL;
            l_timecard_detail (l).parent_building_block_ovn := NULL;
            l_timecard_detail (l).NEW := NULL;
            l_timecard_detail (l).changed := NULL;
         END LOOP;
	 */
         l_timecard_detail.DELETE;
      END IF;

      IF l_detail_attributes.COUNT > 0
      THEN
         /*
         FOR l IN l_detail_attributes.FIRST .. l_detail_attributes.LAST
         LOOP
            l_detail_attributes (l).time_attribute_id := NULL;
            l_detail_attributes (l).building_block_id := NULL;
            l_detail_attributes (l).attribute_name := NULL;
            l_detail_attributes (l).attribute_value := NULL;
            l_detail_attributes (l).bld_blk_info_type := NULL;
            l_detail_attributes (l).CATEGORY := NULL;
            l_detail_attributes (l).updated := NULL;
            l_detail_attributes (l).changed := NULL;
         END LOOP;
	 */
         l_detail_attributes.DELETE;
      END IF;

      g_messages := p_messages;
      hr_kflex_utility.set_session_date (p_effective_date      => SYSDATE,
                                         p_session_id          => l_session_id
                                        );
      l_tim_sum_id_tab.DELETE;
   -- SAVEPOINT populate_tables;
-- Loop through all the building blocks, which will be of Scope 'DAY'
-- and populate the pl/sql table with the 'DETAIL' records for the Day.
      l_min_bb_id := -1;

      IF g_debug
      THEN
         hr_utility.TRACE ('***********  FIND MIN BB ID  ************');
      END IF;

      FOR l_cnt IN p_time_building_blocks.FIRST .. p_time_building_blocks.LAST
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 5);
         END IF;

         IF p_time_building_blocks (l_cnt).time_building_block_id <
                                                                   l_min_bb_id
         THEN
            l_min_bb_id :=
                        p_time_building_blocks (l_cnt).time_building_block_id;
         END IF;
      END LOOP;

      IF g_debug
      THEN
         hr_utility.TRACE ('MIN BB ID IS : ' || TO_CHAR (l_min_bb_id));
      END IF;

      l_time_building_block_id := l_min_bb_id;

      -- Bugs 3384941, 3382457, 3381642 fix
      -- Added the following FOR LOOP to validate the detail records in the
      -- following order:
      -- Deleted detail records processed first i.e., i = 1
      -- Updated detail records processed next i.e., i = 2
      -- New Inserted detail records processes last i.e., i = 3
      FOR i IN 1 .. 3
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 6);
         END IF;

         FOR l_cnt IN
            p_time_building_blocks.FIRST .. p_time_building_blocks.LAST
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 10);
               hr_utility.TRACE
                        ('***********  NEW TIME BUILDING BLOCK  ************');
            END IF;

            l_bb_id := p_time_building_blocks (l_cnt).time_building_block_id;
            l_bb_ovn := p_time_building_blocks (l_cnt).object_version_number;
            l_type := p_time_building_blocks (l_cnt).TYPE;
            l_measure := p_time_building_blocks (l_cnt).measure;
            l_uom := p_time_building_blocks (l_cnt).unit_of_measure;
            l_start_time := p_time_building_blocks (l_cnt).start_time;
            l_stop_time := p_time_building_blocks (l_cnt).stop_time;
            l_parent_bb_id :=
                       p_time_building_blocks (l_cnt).parent_building_block_id;
            l_parent_bb_ovn :=
                      p_time_building_blocks (l_cnt).parent_building_block_ovn;
            l_parent_new := p_time_building_blocks (l_cnt).parent_is_new;
            l_scope := p_time_building_blocks (l_cnt).SCOPE;
            l_resource_id := p_time_building_blocks (l_cnt).resource_id;
            l_resource_type := p_time_building_blocks (l_cnt).resource_type;
            l_comment_text := p_time_building_blocks (l_cnt).comment_text;
            l_new := p_time_building_blocks (l_cnt).NEW;
            l_no_times := 'N';
            l_appr_status := p_time_building_blocks (l_cnt).approval_status;
            l_appr_style_id :=
                              p_time_building_blocks (l_cnt).approval_style_id;
            l_date_from := p_time_building_blocks (l_cnt).date_from;
            l_date_to := p_time_building_blocks (l_cnt).date_to;

            IF g_debug
            THEN
               hr_utility.TRACE ('Time Bld Blk ID is   :' || TO_CHAR (l_bb_id)
                                );
               hr_utility.TRACE ('Type is              :' || l_type);
               hr_utility.TRACE (   'Measure is           :'
                                 || TO_CHAR (l_measure)
                                );
               hr_utility.TRACE (   'Start time is        :'
                                 || TO_CHAR (l_start_time,
                                             'DD-MON-YYYY HH:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'Stop time is         :'
                                 || TO_CHAR (l_stop_time,
                                             'DD-MON-YYYY HH:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('Scope is             :' || l_scope);
               hr_utility.TRACE (   'Resource id is       :'
                                 || TO_CHAR (l_resource_id)
                                );
               hr_utility.TRACE ('Resource type is     :' || l_resource_type);
               --
               hr_utility.TRACE (   'Unit of Measure is   :'
                                 || p_time_building_blocks (l_cnt).unit_of_measure
                                );
               hr_utility.TRACE
                  (   'Parent Bld Blk ID is :'
                   || TO_CHAR
                         (p_time_building_blocks (l_cnt).parent_building_block_id
                         )
                  );
               hr_utility.TRACE (   'Parent is new ?      :'
                                 || p_time_building_blocks (l_cnt).parent_is_new
                                );
               hr_utility.TRACE
                  (   'OVN is               :'
                   || TO_CHAR
                          (p_time_building_blocks (l_cnt).object_version_number
                          )
                  );
               hr_utility.TRACE (   'Approval Status is   :'
                                 || p_time_building_blocks (l_cnt).approval_status
                                );
               hr_utility.TRACE
                     (   'Approval Style ID is :'
                      || TO_CHAR
                              (p_time_building_blocks (l_cnt).approval_style_id
                              )
                     );
               hr_utility.TRACE
                            (   'Date From is         :'
                             || TO_CHAR
                                     (p_time_building_blocks (l_cnt).date_from,
                                      'DD-MON-YYYY'
                                     )
                            );
               hr_utility.TRACE
                              (   'Date To is           :'
                               || TO_CHAR
                                       (p_time_building_blocks (l_cnt).date_to,
                                        'DD-MON-YYYY'
                                       )
                              );
               hr_utility.TRACE (   'Comment Text is      :'
                                 || p_time_building_blocks (l_cnt).comment_text
                                );
               hr_utility.TRACE
                  (   'Parent OVN is        :'
                   || TO_CHAR
                         (p_time_building_blocks (l_cnt).parent_building_block_ovn
                         )
                  );
               hr_utility.TRACE (   'NEW is               :'
                                 || p_time_building_blocks (l_cnt).NEW
                                );
               --
               hr_utility.set_location (l_proc, 20);
            END IF;


            -- Bug 8655664
            -- Save the Alias Defn put up as per preferences if it is not already
            -- there. This would be done only once per timecard, and would
            -- use the first block's start_time -- meaning the Timecard Scope's
            -- start time.
            -- Done for bug 8486310 for validate_timecard.
            IF g_alias_id IS NULL
            THEN
               g_alias_id := hxc_preference_evaluation.resource_preferences ( l_resource_id,
                                                                             'TC_W_TCRD_ALIASES',
                                                                             1,
                                                                             l_start_time
                                                                             );
            END IF;



--Bug 2966729
--Description
--We ensure that if the block is deleted then it must be an existing block
--and not a new entry. In that case the existing blocks would get deleted from the hxt tables.
--If the block is deleted and its a new block then we dont delete them in
--the hxt tables as this does not have any meaning.
--We send non deleted blocks to hxt tables as usual.
--Bug 2966729 over

            --
            -- Bugs 3384941, 3382457, 3381642 fix
            IF     (   (    (   (l_type = 'MEASURE' AND l_measure IS NOT NULL
                                )
                             OR (    l_type = 'RANGE'
                                 AND l_start_time IS NOT NULL
                                 AND l_stop_time IS NOT NULL
                                )
                            )
                        AND (          -- First process deleted detail records
                                (    l_date_to <> hr_general.end_of_time
                                 AND l_new = 'N'
                                 AND i = 1
                                )
                             -- Next process the updated detail records
                             OR (    l_date_to = hr_general.end_of_time
                                 AND l_new = 'N'
                                 AND i = 2
                                )
                             -- And the last to be processed are the Inserts
                             OR (    l_date_to = hr_general.end_of_time
                                 AND l_new = 'Y'
                                 AND i = 3
                                )
                            )                                        --2966729
                       )
                    -- start bug 3650967
                    OR (    (   (l_type = 'MEASURE' AND l_measure IS NULL)
                             OR (    l_type = 'RANGE'
                                 AND l_start_time IS NULL
                                 AND l_stop_time IS NULL
                                )
                            )
                        AND l_date_to <> hr_general.end_of_time
                        AND l_new = 'N'
                        AND i = 1
                       )
                   -- end bug 3650967
                   )
               AND l_scope = 'DETAIL'
            THEN
--       (l_date_to = hr_general.end_of_time) THEN

               --Bug 2770487 Sonarasi 04-Apr-2003
--Commented the above check l_date_to = hr_general.end_of_time because we need
--the deleted blocks also to be considered for explosion.
--Bug 2770487 Sonarasi Over
          --
               l_valid := 'Y';
            ELSE
               l_valid := 'N';
            END IF;

            -- Only care about valid DETAIL Blocks
            IF l_valid = 'Y'
            THEN
               -- Get the start and stop times from the DAY block
               IF    l_type = 'MEASURE' AND l_start_time IS NULL
                  -- start bug 3650967
                  OR (   (l_type = 'MEASURE' AND l_measure IS NULL)
                      OR     (    l_type = 'RANGE'
                              AND l_start_time IS NULL
                              AND l_stop_time IS NULL
                             )
                         AND l_date_to <> hr_general.end_of_time
                         AND l_new = 'N'
                         AND i = 1
                     )                                      -- end bug 3650967
               THEN
                  FOR l_day IN
                     p_time_building_blocks.FIRST .. p_time_building_blocks.LAST
                  LOOP
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 30);
                     END IF;

                     IF     (p_time_building_blocks (l_day).time_building_block_id =
                                                                l_parent_bb_id
                            )
                        AND (p_time_building_blocks (l_day).SCOPE = 'DAY')
                     THEN
                        l_start_time :=
                                    p_time_building_blocks (l_day).start_time;
                        l_stop_time :=
                                     p_time_building_blocks (l_day).stop_time;
                        l_no_times := 'Y';

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'l_start_time is '
                                             || TO_CHAR
                                                       (l_start_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                            );
                           hr_utility.TRACE (   'l_stop_time is '
                                             || TO_CHAR
                                                       (l_stop_time,
                                                        'DD-MON-YYYY HH:MI:SS'
                                                       )
                                            );
                        END IF;

                        EXIT;
                     END IF;
                  END LOOP;
               END IF;                                     -- l_type = MEASURE

               l_person_id := NULL;

               IF l_resource_type = 'PERSON'
               THEN
                  l_person_id := l_resource_id;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'l_person_id is '
                                       || TO_CHAR (l_person_id)
                                      );
                  END IF;
               END IF;

               l_effective_date := TRUNC (l_start_time);

               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_effective_date is :'
                                    || TO_CHAR (l_effective_date,
                                                'DD-MON-YYYY'
                                               )
                                   );
               END IF;

               BEGIN
                  SELECT full_name, business_group_id
                    INTO g_full_name, l_bg_id
                    FROM per_all_people_f
                   WHERE person_id = l_person_id
                     AND l_effective_date BETWEEN effective_start_date
                                              AND effective_end_date;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                          (p_message_table               => g_messages,
                           p_message_name                => 'HR_52365_PTU_NO_PERSON_EXISTS',
                           p_message_token               => NULL,
                           p_message_level               => 'ERROR',
                           p_message_field               => NULL,
                           p_application_short_name      => 'PER',
                           p_timecard_bb_id              => l_bb_id,
                           p_time_attribute_id           => NULL,
                           p_timecard_bb_ovn             => l_bb_ovn,
                           p_time_attribute_ovn          => NULL
                          );
                     -- Bug 3012684
                               --RAISE e_error;
                     l_error_flag := 'Y';
               END;

               hxt_otc_retrieval_interface.get_assignment_id
                                         (p_person_id           => l_person_id,
                                          p_payroll_id          => l_payroll_id,
                                          p_bg_id               => l_bg_id,
                                          p_assignment_id       => l_assignment_id,
                                          p_effective_date      => l_effective_date
                                         );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 50);
               END IF;

               l_field_name.DELETE;
               l_value.DELETE;
               l_category.DELETE;
               l_context.DELETE;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 55);
                  hr_utility.TRACE (   'number of attr is :'
                                    || TO_CHAR (p_time_attributes.COUNT)
                                   );
                  hr_utility.set_location (l_proc, 56);
                  hr_utility.TRACE ('l_person_id  :' || l_person_id);
               END IF;

               --
               -- Get the attributes for this detail building block.
               --
               IF p_time_attributes.COUNT <> 0
               THEN
                  l_att := 1;

                  FOR l_cnt_att IN
                     p_time_attributes.FIRST .. p_time_attributes.LAST
                  LOOP
                     IF g_debug
                     THEN
                        hr_utility.TRACE ('l_bb_id:' || l_bb_id);
                        hr_utility.TRACE
                              (   'p_time_attributes'
                               || (l_cnt_att)
                               || '.building_block_id:'
                               || p_time_attributes (l_cnt_att).building_block_id
                              );
                     END IF;

                     IF l_bb_id =
                               p_time_attributes (l_cnt_att).building_block_id
                     THEN
                        IF g_debug
                        THEN
                           hr_utility.TRACE
                                  ('----------- In Attribute Loop ----------');
                        END IF;

                        l_field_name (l_att) :=
                                  p_time_attributes (l_cnt_att).attribute_name;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'field name('
                                             || l_att
                                             || ') is :'
                                             || l_field_name (l_att)
                                            );
                        END IF;

                        l_value (l_att) :=
                                 p_time_attributes (l_cnt_att).attribute_value;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'value('
                                             || l_att
                                             || ') is      : '
                                             || l_value (l_att)
                                            );
                        END IF;

                        l_context (l_att) :=
                               p_time_attributes (l_cnt_att).bld_blk_info_type;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'context('
                                             || l_att
                                             || ') is    :'
                                             || l_context (l_att)
                                            );
                        END IF;

                        l_category (l_att) :=
                                        p_time_attributes (l_cnt_att).CATEGORY;

                        IF g_debug
                        THEN
                           hr_utility.TRACE (   'category('
                                             || l_att
                                             || ') is   :'
                                             || l_category (l_att)
                                            );
                        END IF;

                        --
                        -- Start Bug 2930933
                        --
                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 56.5);
                        END IF;

                        IF     l_field_name (l_att) = 'Dummy Element Context'
                           AND l_context (l_att) = 'Dummy Element Context'
                           AND l_category (l_att) = 'ELEMENT'
                        THEN
                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 56.6);
                           END IF;

                           IF l_value (l_att) IS NOT NULL
                           THEN
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 57);
                              END IF;

                              l_hrstype_entered := 'Y';
                           ELSE
                              IF g_debug
                              THEN
                                 hr_utility.set_location (l_proc, 58);
                              END IF;

                              l_hrstype_entered := 'N';
                           END IF;

                           IF g_debug
                           THEN
                              hr_utility.set_location (l_proc, 58.5);
                           END IF;
                        END IF;

                        IF g_debug
                        THEN
                           hr_utility.set_location (l_proc, 59);
                        END IF;

                        -- End Bug 2930933
                        l_att := l_att + 1;
                     --
                     -- p_time_attributes.delete(l_cnt_att);
                     --
                     END IF;
                  END LOOP;
               END IF;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_att is: ' || TO_CHAR (l_att));
               END IF;

               -- Bug 2930933
               IF g_debug
               THEN
                  hr_utility.TRACE (   'l_hrstype_entered    :'
                                    || l_hrstype_entered
                                   );
                  hr_utility.set_location (l_proc, 60);
               END IF;

               IF l_hrstype_entered = 'N' AND i <> 1  -- Check for Bug 4548871
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 61);
                  END IF;

                  -- Raise an error
                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                              (p_message_table               => g_messages,
                               p_message_name                => 'HXC_366384_NO_HRS_TYPE_ERR',
                               p_message_token               => NULL,
                               p_message_level               => 'ERROR',
                               p_message_field               => NULL,
                               p_application_short_name      => 'HXC',
                               p_timecard_bb_id              => l_bb_id,
                               p_time_attribute_id           => NULL,
                               p_timecard_bb_ovn             => l_bb_ovn,
                               p_time_attribute_ovn          => NULL
                              );
                  -- Bug 3012684
                  l_error_flag := 'Y';
               --RAISE e_error;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 62);
               END IF;

               hxt_otc_retrieval_interface.parse_attributes
                                          (p_category           => l_category,
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
                                           p_project            => l_project,
                                           p_task               => l_task,
                                           p_state_name         => l_state_name,
                                           p_county_name        => l_county_name,
                                           p_city_name          => l_city_name,
                                           p_zip_code           => l_zip_code
                                          );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 63);
               END IF;

               --
               -- Pass in Person ID for employee number - issue with going
               -- from employee number to person ID in OTM API.  Hence bypass it
               -- and just pass in person ID.
               --
               IF (l_no_times = 'Y')
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 64);
                  END IF;

                  l_start_time := NULL;
                  l_stop_time := NULL;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 65);
               END IF;

               l_time_summary_id := NULL;
               l_time_sum_start_date := NULL;
               l_time_sum_end_date := NULL;

               IF l_new = 'N'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 66);
                  END IF;

                  -- Bug 7415291
                  -- Added new parameter l_tim_id
                  hxt_otc_retrieval_interface.find_existing_timecard
                              (p_payroll_id               => l_payroll_id,
                               p_date_worked              => l_date_worked,
                               p_person_id                => l_person_id,
                               p_old_ovn                  => l_bb_ovn,
                               p_bb_id                    => l_bb_id,
                               p_time_summary_id          => l_time_summary_id,
                               p_time_sum_start_date      => l_time_sum_start_date,
                               p_time_sum_end_date        => l_time_sum_end_date,
                               p_tim_id                   => l_tim_id
                              );

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('after find_existing_timecard');
                     hr_utility.TRACE (   'l_time_summary_id is: '
                                       || TO_CHAR (l_time_summary_id)
                                      );
                  END IF;

                  IF l_time_summary_id IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 67);
                     END IF;

                     DELETE FROM hxt_det_hours_worked_f
                           WHERE parent_id = l_time_summary_id;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 68);
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 69);
               END IF;

               --Bug 2770487 Sonarasi 04-Apr-2003
               IF (l_date_to = hr_general.end_of_time)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 70);
                  END IF;

                  l_delete := 'N';
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 71);
                  END IF;

                  l_delete := 'Y';
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 72);
               END IF;

--Here We are setting the delete flag based on whether we would like to
--delete the blocks or retail them.Therefore those blocks which are end
--dated will have the l_delete flag set to 'Y'. We will be passing the
--l_delete as a value to the parameter delete_yn of the record_time api.
--Bug 2770487 Sonarasi Over
               hxt_time_collection.record_time
                             (timecard_source                => 'Time Store',
                              batch_ref                      => 'OTL_SS_DEP_VAL',
                              batch_name                     => 'OTL_SS_DEP_VAL',
                              approver_number                => NULL,
                              employee_number                => TO_CHAR
                                                                   (l_person_id
                                                                   ),
                              date_worked                    => l_date_worked,
                              start_time                     => l_start_time,
                              end_time                       => l_stop_time,
                              hours                          => l_hours,
                              wage_code                      => NULL,
                              earning_policy                 => NULL,
                              hours_type                     => l_hours_type,
                              earn_reason_code               => NULL,
                              project                        => NULL,
                              task_number                    => NULL,
                              location_code                  => NULL,
                              COMMENT                        => NULL,
                              rate_multiple                  => NULL,
                              hourly_rate                    => NULL,
                              amount                         => NULL,
                              separate_check_flag            => NULL,
                              business_group_id              => l_bg_id,
                              cost_segment1                  => l_segment (1),
                              cost_segment2                  => l_segment (2),
                              cost_segment3                  => l_segment (3),
                              cost_segment4                  => l_segment (4),
                              cost_segment5                  => l_segment (5),
                              cost_segment6                  => l_segment (6),
                              cost_segment7                  => l_segment (7),
                              cost_segment8                  => l_segment (8),
                              cost_segment9                  => l_segment (9),
                              cost_segment10                 => l_segment (10),
                              cost_segment11                 => l_segment (11),
                              cost_segment12                 => l_segment (12),
                              cost_segment13                 => l_segment (13),
                              cost_segment14                 => l_segment (14),
                              cost_segment15                 => l_segment (15),
                              cost_segment16                 => l_segment (16),
                              cost_segment17                 => l_segment (17),
                              cost_segment18                 => l_segment (18),
                              cost_segment19                 => l_segment (19),
                              cost_segment20                 => l_segment (20),
                              cost_segment21                 => l_segment (21),
                              cost_segment22                 => l_segment (22),
                              cost_segment23                 => l_segment (23),
                              cost_segment24                 => l_segment (24),
                              cost_segment25                 => l_segment (25),
                              cost_segment26                 => l_segment (26),
                              cost_segment27                 => l_segment (27),
                              cost_segment28                 => l_segment (28),
                              cost_segment29                 => l_segment (29),
                              cost_segment30                 => l_segment (30),
                              time_summary_id                => l_time_summary_id,
                              tim_sum_eff_start_date         => l_time_sum_start_date,
                              tim_sum_eff_end_date           => l_time_sum_end_date,
                              created_by                     => '-1',
                              last_updated_by                => '-1',
                              last_update_login              => '-1',
                              dt_update_mode                 => 'CORRECTION',
                              created_tim_sum_id             => l_created_tim_sum_id,
                              otm_error                      => l_otm_error,
                              oracle_error                   => l_oracle_error,
                              p_time_building_block_id       => l_bb_id,
                              p_time_building_block_ovn      => l_bb_ovn,
                              p_validate                     => FALSE,
                              delete_yn                      => l_delete,
                              p_state_name                   => l_state_name,
                              p_county_name                  => l_county_name,
                              p_city_name                    => l_city_name,
                              p_zip_code                     => l_zip_code
                             );

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 73);
               END IF;

               IF g_otm_messages.COUNT > 0
               THEN
                  FOR i IN g_otm_messages.FIRST .. g_otm_messages.LAST
                  LOOP
                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                        (p_message_table               => g_messages,
                         p_message_name                => g_otm_messages (i).message_name,
                         p_message_token               => g_otm_messages (i).message_tokens,
                         p_message_level               => g_otm_messages (i).message_level,
                         p_message_field               => NULL,
                         p_application_short_name      => g_otm_messages (i).application_short_name,
                         p_timecard_bb_id              => l_bb_id,
                         p_time_attribute_id           => NULL,
                         p_timecard_bb_ovn             => l_bb_ovn,
                         p_time_attribute_ovn          => NULL
                        );
                  END LOOP;

                  l_error_flag := 'Y';
                  l_otm_error := NULL;
                  l_oracle_error := NULL;
                  g_otm_messages.DELETE;
               ELSE
                  --to capture any errors which are not added to g_otm_messages table but
                  --l_otm_error has not null values
                  IF l_otm_error IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 74);
                        hr_utility.TRACE ('l_otm_error :' || l_otm_error);
                     END IF;

                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => g_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_OTMERR',
                                   p_message_token               => SUBSTR
                                                                       (   'ERROR&'
                                                                        || l_otm_error,
                                                                        1,
                                                                        100
                                                                       ),
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_bb_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'g_messages.message_name is : '
                                          || g_messages (1).message_name
                                         );
                        hr_utility.set_location (l_proc, 75);
                     END IF;

                     -- Bug 3012684
                     l_error_flag := 'Y';
                  --RAISE e_error;
                  END IF;

                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 76);
                  END IF;

                  IF l_oracle_error IS NOT NULL
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location (l_proc, 77);
                        hr_utility.TRACE ('l_oracle_error :' || l_oracle_error
                                         );
                     END IF;

                     hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => g_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_ORAERR',
                                   p_message_token               =>    'ERROR&'
                                                                    || l_oracle_error,
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_bb_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );

                     IF g_debug
                     THEN
                        hr_utility.TRACE (   'g_messages.message_name is : '
                                          || g_messages (1).message_name
                                         );
                        hr_utility.set_location (l_proc, 78);
                     END IF;

                     -- Bug 3012684
                     l_error_flag := 'Y';
                  -- RAISE e_error;
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 79);
               END IF;

               l_next_index := l_timecard_detail.COUNT + 1;
               l_time_building_block_id := l_time_building_block_id - 1;
               l_time_attribute_id := l_time_attribute_id + 1;
               l_tim_sum_id_tab (l_next_index) := l_created_tim_sum_id;
               l_timecard_detail (l_next_index).time_building_block_id :=
                                                      l_time_building_block_id;
               l_timecard_detail (l_next_index).unit_of_measure := 'HOURS';
               l_timecard_detail (l_next_index).parent_building_block_id :=
                                                                l_parent_bb_id;
               l_timecard_detail (l_next_index).parent_building_block_ovn :=
                                                               l_parent_bb_ovn;
               l_timecard_detail (l_next_index).parent_is_new := l_parent_new;
               l_timecard_detail (l_next_index).SCOPE := 'DETAIL';
               l_timecard_detail (l_next_index).object_version_number := NULL;
               l_timecard_detail (l_next_index).approval_status :=
                                                                 l_appr_status;
               l_timecard_detail (l_next_index).resource_id := l_resource_id;
               l_timecard_detail (l_next_index).resource_type :=
                                                               l_resource_type;
               l_timecard_detail (l_next_index).approval_style_id :=
                                                               l_appr_style_id;
               l_timecard_detail (l_next_index).date_from := l_date_from;
               l_timecard_detail (l_next_index).date_to := l_date_to;
               l_timecard_detail (l_next_index).comment_text := l_comment_text;
               l_timecard_detail (l_next_index).NEW := 'Y';
               l_timecard_detail (l_next_index).changed := 'Y';
               l_detail_attributes (l_next_index).time_attribute_id :=
                                                           l_time_attribute_id;
               l_detail_attributes (l_next_index).building_block_id :=
                                                      l_time_building_block_id;
               l_detail_attributes (l_next_index).attribute_name :=
                                                       'Dummy Element Context';
               l_detail_attributes (l_next_index).bld_blk_info_type :=
                                                       'Dummy Element Context';
               l_detail_attributes (l_next_index).CATEGORY := 'ELEMENT';
               l_detail_attributes (l_next_index).updated := NULL;
               l_detail_attributes (l_next_index).changed := NULL;

               -- Get rid of this DETAIL record - it will be copied over
               -- in the end.
               --
               -- p_time_building_blocks.delete(l_cnt);
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 80);
               END IF;
            END IF;                                             -- l_valid = Y

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 81);
            END IF;

            l_hrstype_entered := 'N';

            IF g_debug
            THEN
               hr_utility.TRACE ('l_hrstype_entered :' || l_hrstype_entered);
               hr_utility.set_location (l_proc, 81);
            END IF;
         END LOOP;
      END LOOP;

      -- Bug 3012684
      IF (l_error_flag = 'Y')
      THEN
         RAISE e_error;
      END IF;

      l_timecards.DELETE;
      l_tim_sum := l_tim_sum_id_tab.FIRST;

      LOOP
         EXIT WHEN NOT l_tim_sum_id_tab.EXISTS (l_tim_sum);

         --Bug 2770487 Sonarasi 04-Apr-2003
         --the following if condition i.e if l_tim_sum_id_tab(l_tim_sum) is not null then
         --is added because incase of deleted blocks we may have null time summary ids
         --this may cause problems if the time summary id table returns a null value
         --Hence adding a check to prevent that scenario.
         --Bug 2770487 Sonarasi Over
         IF l_tim_sum_id_tab (l_tim_sum) IS NOT NULL
         THEN
            DELETE FROM hxt_det_hours_worked_f
                  WHERE parent_id = l_tim_sum_id_tab (l_tim_sum);

            OPEN get_timecard_id (p_tim_sum_id      => l_tim_sum_id_tab
                                                                    (l_tim_sum)
                                 );

            FETCH get_timecard_id
             INTO l_timecard_id, l_time_period_id;

            IF (get_timecard_id%FOUND)
            THEN
               IF g_debug
               THEN
                  hr_utility.TRACE (   'TIM_SUM_ID IS : '
                                    || TO_CHAR (l_tim_sum_id_tab (l_tim_sum))
                                   );
                  hr_utility.TRACE (   'l_timecard_id is : '
                                    || TO_CHAR (l_timecard_id)
                                   );
                  hr_utility.TRACE (   'l_time_period_id is : '
                                    || TO_CHAR (l_time_period_id)
                                   );
               END IF;

               IF (NOT l_timecards.EXISTS (l_time_period_id))
               THEN
                  l_timecards (l_time_period_id) := l_timecard_id;
               END IF;
            END IF;

            CLOSE get_timecard_id;
         END IF;             --if l_tim_sum_id_tab(l_tim_sum) is not null then

         l_tim_sum := l_tim_sum_id_tab.NEXT (l_tim_sum);
      END LOOP;

      loop_ok := TRUE;
      i := l_timecards.FIRST;

      IF i IS NOT NULL
      THEN
         WHILE loop_ok
         LOOP
            hxt_time_collection.re_explode_timecard
                                             (timecard_id             => l_timecards
                                                                            (i),
                                              tim_eff_start_date      => NULL,
                                              -- Not Being Used
                                              tim_eff_end_date        => NULL,
                                              -- Not Being Used
                                              dt_update_mode          => 'CORRECTION',
                                              otm_error               => l_otm_error,
                                              oracle_error            => l_oracle_error
                                             );

            IF g_otm_messages.COUNT > 0
            THEN
               FOR i IN g_otm_messages.FIRST .. g_otm_messages.LAST
               LOOP
                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                     (p_message_table               => g_messages,
                      p_message_name                => g_otm_messages (i).message_name,
                      p_message_token               => g_otm_messages (i).message_tokens,
                      p_message_level               => g_otm_messages (i).message_level,
                      p_message_field               => NULL,
                      p_application_short_name      => g_otm_messages (i).application_short_name,
                      p_timecard_bb_id              => l_bb_id,
                      p_time_attribute_id           => NULL,
                      p_timecard_bb_ovn             => l_bb_ovn,
                      p_time_attribute_ovn          => NULL
                     );
               END LOOP;

               g_otm_messages.DELETE;
               l_otm_error := NULL;
               l_oracle_error := NULL;
               RAISE e_error;
            ELSE
               --to capture any errors which are not added to g_otm_messages table but
               --l_otm_error has not null values
               IF l_otm_error IS NOT NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 2000);
                     hr_utility.TRACE ('l_otm_error :' || l_otm_error);
                  END IF;

                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => g_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_OTMERR',
                                   p_message_token               => SUBSTR
                                                                       (   'ERROR&'
                                                                        || l_otm_error,
                                                                        1,
                                                                        100
                                                                       ),
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_bb_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'g_messages.message_name is : '
                                       || g_messages (1).message_name
                                      );
                  END IF;

                  RAISE e_error;
               END IF;

               IF l_oracle_error IS NOT NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 2050);
                     hr_utility.TRACE ('l_oracle_error :' || l_oracle_error);
                  END IF;

                  hxc_time_entry_rules_utils_pkg.add_error_to_table
                                  (p_message_table               => g_messages,
                                   p_message_name                => 'HXC_HXT_DEP_VAL_ORAERR',
                                   p_message_token               =>    'ERROR&'
                                                                    || l_oracle_error,
                                   p_message_level               => 'ERROR',
                                   p_message_field               => NULL,
                                   p_application_short_name      => 'HXC',
                                   p_timecard_bb_id              => l_bb_id,
                                   p_time_attribute_id           => NULL,
                                   p_timecard_bb_ovn             => l_bb_ovn,
                                   p_time_attribute_ovn          => NULL
                                  );

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'g_messages.message_name is : '
                                       || g_messages (1).message_name
                                      );
                  END IF;

                  RAISE e_error;
               END IF;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 2055);
            END IF;

            i := l_timecards.NEXT (i);

            IF i IS NULL
            THEN
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 2060);
               END IF;

               loop_ok := FALSE;
            END IF;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 2065);
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 2070);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 2075);
      END IF;

      l_next_index := 0;
      l_tim_sum := l_tim_sum_id_tab.FIRST;

      LOOP
         EXIT WHEN NOT l_tim_sum_id_tab.EXISTS (l_tim_sum);

         --Bug 2770487 Sonarasi 04-Apr-2003
         --the following if condition i.e if l_tim_sum_id_tab(l_tim_sum) is not null then
         --is added because incase of deleted blocks we may have null time summary ids
         --this may cause problems if the time summary id table returns a null value
         --Hence adding a check to prevent that scenario.
         --Bug 2770487 Sonarasi Over
         IF l_tim_sum_id_tab (l_tim_sum) IS NOT NULL
         THEN
            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 2080);
            END IF;

            l_master_index := l_tim_sum;
            l_num_rec := 0;

            IF g_debug
            THEN
               hr_utility.TRACE (   'TIM_SUM_ID IS : '
                                 || TO_CHAR (l_tim_sum_id_tab (l_tim_sum))
                                );
            END IF;

            --
            -- select count(*)
            -- into l_det_cnt
            -- from hxt_det_hours_worked_f
            -- where parent_id = l_tim_sum_id_tab(l_tim_sum);
            --if g_debug then
               -- hr_utility.trace('l_det_cnt IS : ' || to_char(l_det_cnt));
            --end if;
            --
            OPEN get_otm_records (p_tim_sum_id      => l_tim_sum_id_tab
                                                                    (l_tim_sum));

            LOOP
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 2085);
               END IF;

               FETCH get_otm_records
                INTO detail_date_worked, detail_hours, detail_time_in,
                     detail_time_out, detail_hours_type;

               IF g_debug
               THEN
                  hr_utility.TRACE (   'detail_date_worked :'
                                    || detail_date_worked
                                   );
                  hr_utility.TRACE ('detail_hours       :' || detail_hours);
                  hr_utility.TRACE ('detail_time_in     :' || detail_time_in);
                  hr_utility.TRACE ('detail_time_out    :' || detail_time_out);
                  hr_utility.TRACE ('detail_hours_type  :'
                                    || detail_hours_type
                                   );
               END IF;

               EXIT WHEN get_otm_records%NOTFOUND;

               --
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 2085);
               END IF;

               l_num_rec := l_num_rec + 1;

               IF g_debug
               THEN
                  hr_utility.TRACE ('l_num_rec :' || l_num_rec);
                  hr_utility.TRACE (   'detail_date_worked is : '
                                    || TO_CHAR (detail_date_worked,
                                                'DD-MON-YYYY HH:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'detail_hours is : '
                                    || TO_CHAR (detail_hours)
                                   );
                  hr_utility.TRACE (   'detail_time_in is : '
                                    || TO_CHAR (detail_time_in,
                                                'DD-MON-YYYY HH:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'detail_time_out is : '
                                    || TO_CHAR (detail_time_out,
                                                'DD-MON-YYYY HH:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'detail_hours_type : '
                                    || TO_CHAR (detail_hours_type)
                                   );
               END IF;

               IF l_num_rec = 1
               THEN
                  --
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 2090);
                     hr_utility.TRACE ('l_num_rec is 1');
                  END IF;

                  --
                  l_next_index := l_tim_sum;

                  IF g_debug
                  THEN
                     hr_utility.TRACE ('l_next_index :' || l_next_index);
                  END IF;
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 2095);
                     hr_utility.TRACE ('l_num_rec is NOT 1');
                  END IF;

                  l_next_index := l_timecard_detail.COUNT + 1;
                  l_time_building_block_id := l_time_building_block_id - 1;
                  l_timecard_detail (l_next_index).time_building_block_id :=
                                                      l_time_building_block_id;
                  l_timecard_detail (l_next_index).unit_of_measure := 'HOURS';
                  l_timecard_detail (l_next_index).parent_building_block_id :=
                     l_timecard_detail (l_master_index).parent_building_block_id;
                  l_timecard_detail (l_next_index).parent_building_block_ovn :=
                     l_timecard_detail (l_master_index).parent_building_block_ovn;
                  l_timecard_detail (l_next_index).parent_is_new :=
                              l_timecard_detail (l_master_index).parent_is_new;
                  l_timecard_detail (l_next_index).SCOPE := 'DETAIL';
                  l_timecard_detail (l_next_index).object_version_number :=
                                                                          NULL;
                  l_timecard_detail (l_next_index).approval_status :=
                            l_timecard_detail (l_master_index).approval_status;
                  l_timecard_detail (l_next_index).resource_id :=
                                l_timecard_detail (l_master_index).resource_id;
                  l_timecard_detail (l_next_index).resource_type :=
                              l_timecard_detail (l_master_index).resource_type;
                  l_timecard_detail (l_next_index).approval_style_id :=
                          l_timecard_detail (l_master_index).approval_style_id;
                  l_timecard_detail (l_next_index).date_from :=
                                  l_timecard_detail (l_master_index).date_from;
                  l_timecard_detail (l_next_index).date_to :=
                                    l_timecard_detail (l_master_index).date_to;
                  l_timecard_detail (l_next_index).comment_text :=
                               l_timecard_detail (l_master_index).comment_text;
                  l_timecard_detail (l_next_index).NEW := 'Y';
                  l_timecard_detail (l_next_index).changed := 'Y';
                  l_detail_attributes (l_next_index).time_attribute_id :=
                        l_detail_attributes (l_master_index).time_attribute_id;
                  l_detail_attributes (l_next_index).building_block_id :=
                                                      l_time_building_block_id;
                  l_detail_attributes (l_next_index).attribute_name :=
                                                       'Dummy Element Context';
                  l_detail_attributes (l_next_index).bld_blk_info_type :=
                                                       'Dummy Element Context';
                  l_detail_attributes (l_next_index).CATEGORY := 'ELEMENT';
                  l_detail_attributes (l_next_index).updated := NULL;
                  l_detail_attributes (l_next_index).changed := NULL;
               END IF;

               IF detail_hours IS NULL
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 3000);
                  END IF;

                  detail_type := 'RANGE';
               ELSE
                  IF g_debug
                  THEN
                     hr_utility.set_location (l_proc, 3005);
                  END IF;

                  detail_type := 'MEASURE';
               END IF;

               -- Populate the pl/sql tables before rolling back to the savepoint.
               IF g_debug
               THEN
                  hr_utility.set_location (l_proc, 3010);
                  hr_utility.TRACE (   'l_next_index is : '
                                    || TO_CHAR (l_next_index)
                                   );
               END IF;

               l_timecard_detail (l_next_index).TYPE := detail_type;
               l_timecard_detail (l_next_index).measure := detail_hours;
               l_timecard_detail (l_next_index).start_time := detail_time_in;
               l_timecard_detail (l_next_index).stop_time := detail_time_out;
               l_detail_attributes (l_next_index).attribute_value :=
                           'ELEMENT' || ' ' || '-' || ' ' || detail_hours_type;

               -- Bug 8486310
               -- Call the below procedure to store the Alternate Name identifier
               -- associated with this element
               save_an_ids (l_detail_attributes(l_next_index).attribute_value);

               IF g_debug
               THEN
                  hr_utility.TRACE ('done');
                  hr_utility.set_location (l_proc, 3015);
               END IF;
            END LOOP;

            IF g_debug
            THEN
               hr_utility.set_location (l_proc, 3020);
               hr_utility.TRACE ('After End Loop');
            END IF;

            CLOSE get_otm_records;
         END IF;             --if l_tim_sum_id_tab(l_tim_sum) is not null then

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3025);
         END IF;

         l_tim_sum := l_tim_sum_id_tab.NEXT (l_tim_sum);
      END LOOP;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 3030);
         hr_utility.set_location (l_proc, 3035);
      END IF;

      ROLLBACK TO review_details;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 3040);
         hr_utility.TRACE ('After RollBack');
         hr_utility.set_location (l_proc, 3045);
      END IF;

      IF l_timecard_detail.COUNT <> 0
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3050);
         END IF;

         FOR l_cnt IN l_timecard_detail.FIRST .. l_timecard_detail.LAST
         LOOP
            IF g_debug
            THEN
               hr_utility.TRACE
                    (   'l_timecard_detail BB ID is : '
                     || TO_CHAR
                              (l_timecard_detail (l_cnt).time_building_block_id
                              )
                    );
            END IF;
         END LOOP;

         FOR l_cnt IN l_detail_attributes.FIRST .. l_detail_attributes.LAST
         LOOP
            IF g_debug
            THEN
               hr_utility.TRACE
                       (   'l_detail_attributes BB ID is : '
                        || TO_CHAR
                                 (l_detail_attributes (l_cnt).building_block_id
                                 )
                       );
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3055);
         END IF;
      END IF;

      IF g_debug
      THEN
         hr_utility.set_location (l_proc, 3060);
         hr_utility.TRACE ('END FYI');
      END IF;

      p_messages := g_messages;
      p_detail_build_blocks := l_timecard_detail;
      p_detail_attributes := build_attributes (l_detail_attributes);

      IF p_detail_build_blocks.COUNT <> 0
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3065);

         -- Bug 8486310
         -- Nothing relevant to the bug, but the below construct is illogical.
         -- You actually need to loop only if you have the trace set.
         -- Rewriting it.
         -- And why do we need these successive IFs ?
            FOR l_cnt IN
               p_detail_build_blocks.FIRST .. p_detail_build_blocks.LAST
            LOOP
                  hr_utility.TRACE
                     (   'p_detail_build_blocks BB ID is : '
                      || TO_CHAR
                             (p_detail_build_blocks (l_cnt).time_building_block_id
                             )
                     );
                  hr_utility.TRACE (   'p_detail_build_blocks Hours is : '
                                    || TO_CHAR
                                            (p_detail_build_blocks (l_cnt).measure
                                            )
                                   );
            END LOOP;

            FOR l_cnt IN p_detail_attributes.FIRST .. p_detail_attributes.LAST
            LOOP
                  hr_utility.TRACE
                          (   'p_detail_attributes BB ID is : '
                           || TO_CHAR
                                    (p_detail_attributes (l_cnt).building_block_id
                                    )
                          );
                  hr_utility.TRACE (   'p_detail_attributes ATTR category is : '
                                    || p_detail_attributes (l_cnt).attribute_category
                                   );
            END LOOP;

            hr_utility.set_location (l_proc, 3070);
         END IF;
      END IF;

      hr_kflex_utility.unset_session_date (p_session_id => l_session_id);
   EXCEPTION
      WHEN e_error
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3075);
         END IF;

         p_messages := g_messages;
         -- Rollback to the savepoint
         ROLLBACK TO review_details;
         RETURN;

         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 3080);
            hr_utility.TRACE ('THE END');
         END IF;
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location (l_proc, 4000);
         END IF;

         p_messages := g_messages;
         -- Rollback to the savepoint
         ROLLBACK TO review_details;
         RETURN;
   END otlr_review_details;

--------------------------- build_attributes ---------------------------
   FUNCTION build_attributes (
      p_detail_attributes   IN   hxc_self_service_time_deposit.app_attributes_info
   )
      RETURN hxc_self_service_time_deposit.building_block_attribute_info
   IS
      CURSOR csr_wtd_components (
         p_deposit_process_id   NUMBER,
         p_attribute_category   VARCHAR2,
         p_field_name           VARCHAR2
      )
      IS
         SELECT mc.SEGMENT, bbit.bld_blk_info_type_id
           FROM hxc_mapping_components mc,
                hxc_mapping_comp_usages mcu,
                hxc_mappings m,
                hxc_deposit_processes dp,
                hxc_bld_blk_info_types bbit,
                hxc_bld_blk_info_type_usages bbui
          WHERE dp.mapping_id = m.mapping_id
            AND dp.deposit_process_id = p_deposit_process_id             --AI3
            AND m.mapping_id = mcu.mapping_id
            AND mcu.mapping_component_id = mc.mapping_component_id
            AND mc.bld_blk_info_type_id = bbit.bld_blk_info_type_id
            AND mc.field_name = p_field_name
            AND bbit.bld_blk_info_type_id = bbui.bld_blk_info_type_id
            AND bbit.bld_blk_info_type = p_attribute_category;

      l_attributes             hxc_self_service_time_deposit.building_block_attribute_info;
      l_attribute              BINARY_INTEGER;
      l_attribute_index        BINARY_INTEGER                             := 0;
      l_proc                   VARCHAR2 (70)             := 'BUILD_ATTRIBUTES';
      l_exception              EXCEPTION;
      l_deposit_process_id     NUMBER;
      l_attribute_category     hxc_bld_blk_info_types.bld_blk_info_type%TYPE;
      l_segment                hxc_mapping_components.SEGMENT%TYPE;
      l_bld_blk_info_type_id   hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;
      -- Bug 8486310
      -- The below variables for AN Id calculation
      l_bbit                   hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE;
      l_hours_type             VARCHAR2(50);
   BEGIN
      SELECT dp.deposit_process_id
        INTO l_deposit_process_id
        FROM hxc_deposit_processes dp
       WHERE dp.NAME = 'OTL Deposit Process';


      -- Bug 8486310
      -- Pretty sure that this would return only one value, so no need of a cursor.
      SELECT bld_blk_info_type_id
        INTO l_bbit
        FROM hxc_bld_blk_info_types
       WHERE bld_blk_info_type = 'ALTERNATE NAME IDENTIFIERS';

      l_attributes.DELETE;
      l_attribute := p_detail_attributes.FIRST;

      LOOP
         EXIT WHEN NOT p_detail_attributes.EXISTS (l_attribute);

         OPEN csr_wtd_components
                         (l_deposit_process_id,
                          p_detail_attributes (l_attribute).bld_blk_info_type,
                          p_detail_attributes (l_attribute).attribute_name
                         );

         FETCH csr_wtd_components
          INTO l_segment, l_bld_blk_info_type_id;

         CLOSE csr_wtd_components;

         l_attribute_index := l_attribute_index + 1;
         l_attributes (l_attribute_index).time_attribute_id :=
                           p_detail_attributes (l_attribute).time_attribute_id;
         l_attributes (l_attribute_index).building_block_id :=
                           p_detail_attributes (l_attribute).building_block_id;
         l_attributes (l_attribute_index).bld_blk_info_type :=
                           p_detail_attributes (l_attribute).bld_blk_info_type;
         l_attributes (l_attribute_index).changed :=
                                     p_detail_attributes (l_attribute).changed;
         l_attributes (l_attribute_index).bld_blk_info_type_id :=
                                                        l_bld_blk_info_type_id;
         l_attributes (l_attribute_index).NEW := 'Y';

         IF l_segment = 'ATTRIBUTE1'
         THEN
            l_attributes (l_attribute_index).attribute1 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE2'
         THEN
            l_attributes (l_attribute_index).attribute2 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE3'
         THEN
            l_attributes (l_attribute_index).attribute3 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE4'
         THEN
            l_attributes (l_attribute_index).attribute4 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE5'
         THEN
            l_attributes (l_attribute_index).attribute5 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE6'
         THEN
            l_attributes (l_attribute_index).attribute6 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE7'
         THEN
            l_attributes (l_attribute_index).attribute7 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE8'
         THEN
            l_attributes (l_attribute_index).attribute8 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE9'
         THEN
            l_attributes (l_attribute_index).attribute9 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE10'
         THEN
            l_attributes (l_attribute_index).attribute10 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE11'
         THEN
            l_attributes (l_attribute_index).attribute11 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE12'
         THEN
            l_attributes (l_attribute_index).attribute12 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE13'
         THEN
            l_attributes (l_attribute_index).attribute13 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE14'
         THEN
            l_attributes (l_attribute_index).attribute14 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE15'
         THEN
            l_attributes (l_attribute_index).attribute15 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE16'
         THEN
            l_attributes (l_attribute_index).attribute16 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE17'
         THEN
            l_attributes (l_attribute_index).attribute17 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE18'
         THEN
            l_attributes (l_attribute_index).attribute18 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE19'
         THEN
            l_attributes (l_attribute_index).attribute19 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE20'
         THEN
            l_attributes (l_attribute_index).attribute20 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE21'
         THEN
            l_attributes (l_attribute_index).attribute21 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE22'
         THEN
            l_attributes (l_attribute_index).attribute22 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE23'
         THEN
            l_attributes (l_attribute_index).attribute23 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE24'
         THEN
            l_attributes (l_attribute_index).attribute24 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE25'
         THEN
            l_attributes (l_attribute_index).attribute25 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE26'
         THEN
            l_attributes (l_attribute_index).attribute26 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE27'
         THEN
            l_attributes (l_attribute_index).attribute27 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE28'
         THEN
            l_attributes (l_attribute_index).attribute28 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE29'
         THEN
            l_attributes (l_attribute_index).attribute29 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE30'
         THEN
            l_attributes (l_attribute_index).attribute30 :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSIF l_segment = 'ATTRIBUTE_CATEGORY'
         THEN
            l_attributes (l_attribute_index).attribute_category :=
                            p_detail_attributes (l_attribute).attribute_value;
         ELSE
            RAISE l_exception;
         END IF;

         -- Bug 8486310
         -- Added the below construct to check if the element is
         -- associated with an alternate name, and add it to the
         -- attributes table if it exists.
         IF (l_segment = 'ATTRIBUTE_CATEGORY')
           AND (p_detail_attributes(l_attribute).attribute_value LIKE 'ELEMENT -%')
         THEN
            l_hours_type :=p_detail_attributes(l_attribute).attribute_value;
            IF g_an_id.EXISTS(l_hours_type)
            THEN
               IF g_an_id(l_hours_type) IS NOT NULL
               THEN
                  l_attribute_index := l_attribute_index + 1;
                  l_attributes (l_attribute_index).time_attribute_id    :=
                           p_detail_attributes (l_attribute).time_attribute_id*5;
                  l_attributes (l_attribute_index).building_block_id    :=
                           p_detail_attributes (l_attribute).building_block_id;
                  l_attributes (l_attribute_index).bld_blk_info_type    :=
                           'ALTERNATE NAME IDENTIFIERS';
                  l_attributes (l_attribute_index).changed              :=
                           p_detail_attributes (l_attribute).changed;
                  l_attributes (l_attribute_index).bld_blk_info_type_id :=
                           l_bbit;
                  l_attributes (l_attribute_index).NEW                  := 'Y';
                  l_attributes(l_attribute_index).attribute1            :=
                           g_an_id(l_hours_type);
               END IF;
            END IF;
         END IF;

         l_attribute := p_detail_attributes.NEXT (l_attribute);
      END LOOP;

      -- Delete the id table for this session
      g_an_id.DELETE;

      RETURN l_attributes;
   END build_attributes;


   -- Bug 8486310
   -- Added the below function to save the Alt Name identifiers
   -- associated with the element, if any.

   PROCEDURE save_an_ids(p_element   IN VARCHAR2)
   IS

   -- Picking up only the first Alternate name if there are
   -- multiple alternate names ie. First one when Alt Name Ids are
   -- sorted.
   CURSOR get_an_id(p_element_id  IN NUMBER)
       IS SELECT attribute2
            FROM hxc_alias_values
           WHERE alias_definition_id = g_alias_id
             AND attribute1 = p_element_id
             AND attribute2 IS NOT NULL
           ORDER BY attribute2 ASC;

   l_an_id VARCHAR2(500);

   BEGIN

       IF NOT g_an_id.EXISTS(p_element)
       THEN
          -- Pass the element type id
          OPEN get_an_id(REPLACE(p_element,'ELEMENT - '));

          FETCH get_an_id INTO l_an_id;

          IF get_an_id%NOTFOUND
          THEN
             l_an_id := NULL;
          END IF;

          CLOSE get_an_id;

          -- Store this
          g_an_id(p_element) := l_an_id;

       END IF;
   END save_an_ids;



   -- Bug 7557568
   -- Added this new function to check if a deletion was done on
   -- the building blocks after a SAVE was done.
   PROCEDURE check_restrict_edit( p_time_building_blocks  IN            HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info,
                                  p_messages              IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.message_table )

   IS


   CURSOR get_sum_id( p_bb_id   IN NUMBER)
       IS SELECT tim_id,
                 id
            FROM hxt_sum_hours_worked_f sum,
                 fnd_sessions fnd
           WHERE time_building_block_id = p_bb_id
             AND fnd.effective_date BETWEEN sum.effective_start_date
                                        AND sum.effective_end_date
            ORDER BY time_building_block_ovn DESC;

   l_cnt            NUMBER;
   l_ind            VARCHAR2(50);
   l_day_bb_id      NUMBER;
   l_day_bb_ovn     NUMBER;
   l_day_id         VARCHAR2(50);
   l_detail_bb_id   NUMBER;
   l_detail_bb_ovn  NUMBER;
   l_detail_id      VARCHAR2(50);
   l_retrieved      NUMBER;

   l_tim_id         NUMBER;
   l_sum_id         NUMBER;

   l_dt_update_mode VARCHAR2(50);
   o_return_code    NUMBER;
   l_otm_error      VARCHAR2(50);

   i                VARCHAR2(50);


   BEGIN
       l_cnt := p_time_building_blocks.FIRST;

       LOOP
          EXIT WHEN NOT p_time_building_blocks.EXISTS(l_cnt);

          IF g_debug
          THEN
              hr_utility.trace('Detail '||l_cnt);
              hr_utility.trace('scope         '||p_time_building_blocks(l_cnt).scope);
              hr_utility.trace('date_to       '||p_time_building_blocks(l_cnt).date_to);
              hr_utility.trace('detail        '||p_time_building_blocks(l_cnt).time_building_block_id);
              hr_utility.trace('date_to       '||p_time_building_blocks(l_cnt).date_to);
              hr_utility.trace('detail_bb_ovn '||p_time_building_blocks(l_cnt).object_version_number);
              hr_utility.trace('start_time    '||p_time_building_blocks(l_cnt).start_time);
              hr_utility.trace('stop_time     '||p_time_building_blocks(l_cnt).stop_time);
          END IF;
          -- If its a DELETE or stop_time is missing
          IF (p_time_building_blocks(l_cnt).SCOPE = 'DETAIL' )
              AND (  (p_time_building_blocks(l_cnt).DATE_TO <> hr_general.end_of_time)
                   OR ( p_time_building_blocks(l_cnt).type = 'RANGE'
                       AND ( p_time_building_blocks(l_cnt).start_time IS NULL
                           OR p_time_building_blocks(l_cnt).stop_time IS NULL)
                      )
                  )
          THEN
             IF g_debug
             THEN
                 hr_utility.trace('It is a deleted detail');
             END IF;
             l_detail_id  := p_time_building_blocks(l_cnt).time_building_block_id||'-'||
                              p_time_building_blocks(l_cnt).object_version_number;
             g_detail_tab(l_detail_id).detail_bb_id  := p_time_building_blocks(l_cnt).time_building_block_id;
             g_detail_tab(l_detail_id).detail_bb_ovn := p_time_building_blocks(l_cnt).object_version_number ;
             g_detail_tab(l_detail_id).parent_id     := p_time_building_blocks(l_cnt).parent_building_block_id;
             g_detail_tab(l_detail_id).parent_ovn    := p_time_building_blocks(l_cnt).parent_building_block_ovn;
             g_detail_tab(l_detail_id).type          := p_time_building_blocks(l_cnt).type;
             g_detail_tab(l_detail_id).measure       := p_time_building_blocks(l_cnt).measure;
             g_detail_tab(l_detail_id).start_time    := p_time_building_blocks(l_cnt).start_time;
             g_detail_tab(l_detail_id).date_to       := p_time_building_blocks(l_cnt).date_to;
             g_detail_tab(l_detail_id).new           := p_time_building_blocks(l_cnt).new;
          END IF;
          l_cnt := p_time_building_blocks.NEXT(l_cnt);
       END LOOP;

       -- If there is a deletion
       IF g_detail_tab.COUNT > 0
       THEN
          IF g_debug
          THEN
             hr_utility.trace('There are deleted details, need to process ');
          END IF;
          i:= g_detail_tab.FIRST;
       	  LOOP
       	     EXIT WHEN i IS NULL;
       	        -- Check if this was ever retrieved.

       	        -- Bug 8631355
       	        -- Added an exception block below.
       	        BEGIN

       	        SELECT 1
       	          INTO l_retrieved
       	          FROM hxc_transaction_details td,
       	               hxc_transactions t
       	         WHERE td.time_building_block_id   = g_detail_tab(i).detail_bb_id
       	           AND td.time_building_block_ovn <= g_detail_tab(i).detail_bb_ovn
       	           AND td.status                   = 'SUCCESS'
       	           AND t.transaction_id            = td.transaction_id
       	           AND t.type                      = 'RETRIEVAL'
       	           AND t.transaction_process_id    = -1
       	           AND ROWNUM < 2;

       	          EXCEPTION
       	            WHEN NO_DATA_FOUND THEN
       	                l_retrieved := 0;
       	        END;

       	        IF l_retrieved = 1
       	        THEN
       	           OPEN get_sum_id(g_detail_tab(i).detail_bb_id);

       	           FETCH get_sum_id INTO l_tim_id,
       	                                 l_sum_id;

       	           CLOSE get_sum_id;
       	           -- Check restrict edit and throw errors.
       	           hxt_td_util.retro_restrict_edit
       	                                    (p_tim_id             => l_tim_id,
       	                                     p_session_date       => SYSDATE,
       	                                     o_dt_update_mod      => l_dt_update_mode,
       	                                     o_error_message      => l_otm_error,
       	                                     o_return_code        => o_return_code,
       	                                     p_parent_id          => l_sum_id
       	                                    );

                   IF g_debug
                   THEN
                      hr_utility.trace('update mode '||l_dt_update_mode);
                   END IF;
       	           IF l_dt_update_mode = 'UPDATE'
       	           THEN
       	               hxc_time_entry_rules_utils_pkg.add_error_to_table
       	                    (p_message_table               => p_messages,
       	                     p_message_name                => 'HXT_TC_CANNOT_BE_DELETED',
       	                     p_message_token               => NULL,
       	                     p_message_level               => 'ERROR',
       	                     p_message_field               => NULL,
       	                     p_application_short_name      => 'HXT',
       	                     p_timecard_bb_id              => g_detail_tab(i).detail_bb_id,
       	                     p_time_attribute_id           => NULL,
       	                     p_timecard_bb_ovn             => g_detail_tab(i).detail_bb_ovn,
       	                     p_time_attribute_ovn          => NULL
       	                    );
       	                g_detail_tab.DELETE;
       	                RETURN;
       	            ELSIF l_dt_update_mode IS NULL
       	            THEN
       	                hxc_time_entry_rules_utils_pkg.add_error_to_table
       	                    (p_message_table               => p_messages,
       	                     p_message_name                => 'HXT_TC_CANNOT_BE_CHANGED_TODAY',
       	                     p_message_token               => NULL,
       	                     p_message_level               => 'ERROR',
       	                     p_message_field               => NULL,
       	                     p_application_short_name      => 'HXT',
       	                     p_timecard_bb_id              => g_detail_tab(i).detail_bb_id,
       	                     p_time_attribute_id           => NULL,
       	                     p_timecard_bb_ovn             => g_detail_tab(i).detail_bb_ovn,
       	                     p_time_attribute_ovn          => NULL
       	                    );
       	                g_detail_tab.DELETE;
       	                RETURN;
       	             END IF;
       	        END IF;


       	   i:= g_detail_tab.NEXT(i);
       	   END LOOP;
      END IF;


   END check_restrict_edit;


END hxt_hxc_retrieval_process;

/
