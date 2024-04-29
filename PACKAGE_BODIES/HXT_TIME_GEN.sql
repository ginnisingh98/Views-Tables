--------------------------------------------------------
--  DDL for Package Body HXT_TIME_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIME_GEN" AS
/* $Header: hxttgen.pkb 120.0.12010000.4 2010/02/12 08:34:48 sabvenug ship $ */

   PROCEDURE call_gen_error (
      a_hrw_id         NUMBER,
      a_error_text     VARCHAR2,
      a_ora_err_text   VARCHAR2 DEFAULT NULL
   );

   PROCEDURE manage_fnd_sessions; --SIR520

   PROCEDURE update_batch_ref (l_batch_id NUMBER, a_reference_num VARCHAR2); --SIR71

   FUNCTION convert_time (
      a_date       DATE,
      a_time_in    NUMBER,
      a_time_out   NUMBER DEFAULT NULL
   )
      RETURN DATE;

   FUNCTION convert_time (
      a_date       DATE,
      a_time_in    VARCHAR2,
      a_time_out   VARCHAR2 DEFAULT NULL
   )
      RETURN DATE;

   PROCEDURE del_existing_hrw (a_tim_id NUMBER);

   PROCEDURE del_obsolete_tim;

   FUNCTION chk_timecard_exists (
      a_payroll_id       NUMBER,
      a_time_period_id   NUMBER,
      a_person_id        NUMBER
   )
      RETURN NUMBER;

   PROCEDURE get_holiday_info (
      a_date     IN              DATE,
      a_hcl_id   IN              NUMBER,
      a_elt_id   OUT NOCOPY      NUMBER,
      a_hours    OUT NOCOPY      NUMBER
   );

   -- Get all assignment segments valid for this payroll sometime during
   -- this time period (auto-gen='Y', pay_status='P')

   -- Bug 7359347
   -- Changed the below cursor to use global session date variable
   -- instead of the views referring FND_SESSIONS
   -- Added outer join to all the session date conditions.
   /*
   CURSOR g_cur_asm (a_payroll_id NUMBER, a_time_period_id NUMBER)
   IS
      SELECT   ppl.person_id, ppl.last_name, ppl.first_name,
               asm.assignment_id, asm.business_group_id,
               asm.assignment_number, asm.time_normal_start normal_start,
               asm.time_normal_finish normal_finish, asm.normal_hours -- delete C243 by BC
                                                                      --, asmv.hxt_work_plan tws_id
                                                                     ,
               NULL osp_id, NULL sdf_id, aeiv.hxt_rotation_plan rtp_id,
               aeiv.hxt_earning_policy egp_id,
               aeiv.hxt_hour_deduction_policy hdp_id,
               aeiv.hxt_shift_differential_policy sdp_id
--       -- use the latest of ppd_start and asm_start
       -- use the latest of ptp_start, asm_start, and aeiv_start
                                                        ,
               GREATEST (
                  ptp.start_date,
                  asm.effective_start_date,
                  aeiv.effective_start_date
               )
                     start_date -- use the earliest of ppd_end, asm_end, aeiv_end
                               ,
               LEAST (
                  ptp.end_date,
                  asm.effective_end_date,
                  aeiv.effective_end_date
               ) end_date,
               tim.id tim_id, tim.batch_id, tim.auto_gen_flag,
               egp.fcl_earn_type egp_type, egp.egt_id, egp.hcl_id, egp.pep_id,
               egp.pip_id, ptp.ROWID ptp_rowid, egp.effective_start_date,
               egp.effective_end_date
          FROM per_time_periods ptp,
               hxt_timecards tim,
               per_people_f ppl,
               hxt_earning_policies egp,
               hxt_per_aei_ddf_v aeiv,
               per_assignment_status_types ast,
               per_assignments_f asm
         WHERE ptp.payroll_id = asm.payroll_id
           AND ast.assignment_status_type_id = asm.assignment_status_type_id
           AND ast.pay_system_status = 'P' -- Check payroll status
           AND ast.per_system_status = 'ACTIVE_ASSIGN'
           AND aeiv.assignment_id = asm.assignment_id
           AND aeiv.effective_start_date <= ptp.end_date
           AND aeiv.effective_end_date >= ptp.start_date
           AND aeiv.hxt_autogen_hours_yn = 'Y'
           AND egp.id(+) = aeiv.hxt_earning_policy
           -- get policy valid for this time frame
           AND (   (    egp.effective_start_date <=
                              LEAST (
                                 ptp.end_date,
                                 asm.effective_end_date,
                                 aeiv.effective_end_date
                              )
                    AND egp.effective_end_date >=
                              GREATEST (
                                 ptp.start_date,
                                 asm.effective_start_date,
                                 aeiv.effective_start_date
                              )
                    AND egp.id IS NOT NULL
                   )
                OR egp.id IS NULL
               )
           AND ppl.person_id = asm.person_id
           -- use ptp.end_date - may be hired after start_date --
           AND ptp.end_date BETWEEN ppl.effective_start_date
                                AND ppl.effective_end_date
           AND tim.for_person_id(+) = asm.person_id
           AND tim.time_period_id(+) = a_time_period_id
           -- ignore timecards that have been manually entered, we will report to the user on these later
           -- get all assignments valid sometime during pay period --
           AND asm.effective_start_date <= ptp.end_date
           AND asm.effective_end_date >= ptp.start_date
           AND ptp.time_period_id = a_time_period_id
           AND ptp.payroll_id = a_payroll_id
	   AND not exists											-- added 2772781
		   (											-- added 2772781
		   select '1' from  HXT_BATCH_STATES							-- added 2772781
		   where (hxt_batch_states.STATUS  ='VT' and hxt_batch_states.batch_id=tim.batch_id)	-- added 2772781
		   )											-- added 2772781
      ORDER BY tim.batch_id,
               ppl.person_id,
               asm.assignment_number,
               GREATEST (
                  ptp.start_date,
                  asm.effective_start_date,
                  aeiv.effective_start_date
               );

       */

   CURSOR g_cur_asm (a_payroll_id NUMBER, a_time_period_id NUMBER,session_date DATE)
   IS
      SELECT   ppl.person_id, ppl.last_name, ppl.first_name,
               asm.assignment_id, asm.business_group_id,
               asm.assignment_number, asm.time_normal_start normal_start,
               asm.time_normal_finish normal_finish, asm.normal_hours -- delete C243 by BC
                                                                      --, asmv.hxt_work_plan tws_id
                                                                     ,
               NULL osp_id, NULL sdf_id, aeiv.hxt_rotation_plan rtp_id,
               aeiv.hxt_earning_policy egp_id,
               aeiv.hxt_hour_deduction_policy hdp_id,
               aeiv.hxt_shift_differential_policy sdp_id,
               GREATEST (
                  ptp.start_date,
                  asm.effective_start_date,
                  aeiv.effective_start_date
               )
                     start_date -- use the earliest of ppd_end, asm_end, aeiv_end
                               ,
               LEAST (
                  ptp.end_date,
                  asm.effective_end_date,
                  aeiv.effective_end_date
               ) end_date,
               tim.id tim_id, tim.batch_id, tim.auto_gen_flag,
               egp.fcl_earn_type egp_type, egp.egt_id, egp.hcl_id, egp.pep_id,
               egp.pip_id, ptp.ROWID ptp_rowid, egp.effective_start_date,
               egp.effective_end_date
          FROM per_time_periods ptp,
               hxt_timecards_f tim,
               per_people_f ppl,
               hxt_earning_policies egp,
               hxt_per_aei_ddf_v aeiv,
               per_assignment_status_types ast,
               per_assignments_f asm
         WHERE ptp.payroll_id = asm.payroll_id
           AND session_date  BETWEEN tim.effective_start_date(+)
                                 AND tim.effective_end_date(+)
           AND ast.assignment_status_type_id = asm.assignment_status_type_id
           AND ast.pay_system_status = 'P' -- Check payroll status
           AND ast.per_system_status = 'ACTIVE_ASSIGN'
           AND aeiv.assignment_id = asm.assignment_id
           AND aeiv.effective_start_date <= ptp.end_date
           AND aeiv.effective_end_date >= ptp.start_date
           AND aeiv.hxt_autogen_hours_yn = 'Y'
           AND egp.id(+) = aeiv.hxt_earning_policy
           -- get policy valid for this time frame
           AND (   (    egp.effective_start_date <=
                              LEAST (
                                 ptp.end_date,
                                 asm.effective_end_date,
                                 aeiv.effective_end_date
                              )
                    AND egp.effective_end_date >=
                              GREATEST (
                                 ptp.start_date,
                                 asm.effective_start_date,
                                 aeiv.effective_start_date
                              )
                    AND egp.id IS NOT NULL
                   )
                OR egp.id IS NULL
               )
           AND ppl.person_id = asm.person_id
           -- use ptp.end_date - may be hired after start_date --
           AND ptp.end_date BETWEEN ppl.effective_start_date
                                AND ppl.effective_end_date
           AND tim.for_person_id(+) = asm.person_id
           AND tim.time_period_id(+) = a_time_period_id
           AND asm.effective_start_date <= ptp.end_date
           AND asm.effective_end_date >= ptp.start_date
           AND ptp.time_period_id = a_time_period_id
           AND ptp.payroll_id = a_payroll_id
	   AND not exists											-- added 2772781
		   (											-- added 2772781
		   select '1' from  HXT_BATCH_STATES							-- added 2772781
		   where (hxt_batch_states.STATUS  ='VT' and hxt_batch_states.batch_id=tim.batch_id)	-- added 2772781
		   )											-- added 2772781
      ORDER BY tim.batch_id,
               ppl.person_id,
               asm.assignment_number,
               GREATEST (
                  ptp.start_date,
                  asm.effective_start_date,
                  aeiv.effective_start_date
               );



   g_asm_rec   g_cur_asm%ROWTYPE;


------------------------------------------------------------------
                        -- PUBLIC --
------------------------------------------------------------------
   PROCEDURE generate_time (
      errbuf               OUT NOCOPY      VARCHAR2,
      retcode              OUT NOCOPY      NUMBER,
      a_payroll_id         IN              NUMBER,
      a_time_period_id     IN              NUMBER,
      a_reference_number   IN              VARCHAR2
   )
   IS --SPR C167 BY BC
      -- Declare local variables
      l_batch_id           hxt_timecards.batch_id%TYPE;
      l_pre_bat_id         hxt_timecards.batch_id%TYPE              DEFAULT 0; --SPR C362 by BC
      l_person_id          hxt_timecards.for_person_id%TYPE; -- null to see new person in first loop
      l_tim_id             hxt_timecards.id%TYPE; -- to hold tim_id for same person
      l_request_id         NUMBER          := fnd_profile.VALUE ('CONC_REQUEST_ID');
      l_tim_cntr           NUMBER                                   := g_batch_size; -- set to create batch in first loop
      l_retcode            NUMBER;
      l_errors             EXCEPTION;
      v_retcode            NUMBER                                   := 0; --SIR60
      a_person_id          NUMBER; --SIR60
      l_reference_number   pay_batch_headers.batch_reference%TYPE
                                                        := a_reference_number;
      l_tccount  BOOLEAN;						-- added 2772781
									--this flag is used to indicate that at
									--least one timecard has got autogenerated or
									--change.If it remains false then log file will show message
									--saying there no timecard is generated.
   BEGIN




      -- Bug 7359347
      -- Set session date.
      IF g_gen_session_date IS NULL
      THEN
         g_gen_session_date := hxt_tim_col_util.return_session_date;
      END IF;

      manage_fnd_sessions;
      -- Save parameters to globals



      /*Bug 9118639


      Initializing all global params for session dates.
      This was missed out since in normal Explosion flow, all the initialization was
      done in hxt_time_collection, which was not passed throuhg while autogenerating

       */

      -- Bug 9118639
      hxt_time_summary.g_sum_session_date := g_gen_session_date;
      hxt_time_detail.g_det_session_date  := g_gen_session_date;
      hxt_time_pay.g_pay_session_date     := g_gen_session_date;
      hxt_time_gen.g_gen_session_date     := g_gen_session_date;
      hxt_td_util.g_td_session_date       := g_gen_session_date;





      g_payroll_id := a_payroll_id;
      g_time_period_id := a_time_period_id;
      -- Delete timecards that were autogen'ed for this period that won't be auto-
      -- gen'ed again.  Hours worked and error records will be cascade-deleted.
      g_err_loc := 'Autogen  '; -- SPR C336 by BC
      g_autogen_error := NULL;
      g_sub_loc := 'Del_Obsolete_Tim';
      del_obsolete_tim;
      -- Step through assignment segments
      g_sub_loc := 'Cursor G_Cur_Asm';
      l_tccount:=FALSE;			-- added 2772781

     -- Bug 7359347
     -- Added session date parameter.
     FOR asm_rec IN g_cur_asm (g_payroll_id, g_time_period_id,g_gen_session_date)
      LOOP
         -- Populate global record
         g_asm_rec := asm_rec;
         a_person_id := g_asm_rec.person_id; --SIR60
         g_bus_group_id := g_asm_rec.business_group_id; --GLOBAL
	 l_tccount:=TRUE;					-- added 2772781
         -- Use block to handle exceptions and continue loop
         BEGIN
            v_retcode := chk_timecard_exists (
                            a_payroll_id,
                            a_time_period_id,
                            a_person_id
                         ); --SIR60

            IF v_retcode = 1
            THEN --SIR60
               -- Check if different person from last loop
               IF g_asm_rec.person_id <> NVL (l_person_id, 0)
               THEN
                  -- Check if no timecard exists
                  IF g_asm_rec.tim_id IS NULL
                  THEN
                     -- Create batch if timecard/batch limit is reached
                     g_sub_loc := 'Create_Batch';

                     --BEGIN SPR C167 BY BC
                     IF l_reference_number IS NULL
                     THEN
                        g_autogen_error := NULL;
                        hxt_user_exits.define_reference_number (
                           g_payroll_id,
                           g_time_period_id,
                           g_asm_rec.assignment_id,
                           g_asm_rec.person_id,
                           g_user_name,
                           'A', --CLOCK BY BC
                           l_reference_number,
                           g_autogen_error
                        );

                        IF g_autogen_error IS NOT NULL
                        THEN
                           RAISE g_form_level_error;
                        END IF;
                     END IF;

                     l_retcode :=
                                 create_batch (l_tim_cntr, l_reference_number);

                     -- Save new batch ID and reset timecard counter if new batch created
                     IF l_retcode IS NOT NULL
                     THEN
                        l_batch_id := l_retcode;
                        l_tim_cntr := 0;
                        COMMIT;
                     END IF;

                     -- Create timecard record and save id in cursor global
                     g_sub_loc := 'Create_Timecard';
                     g_asm_rec.batch_id := l_batch_id; -- SPR C349 by BC
                     g_asm_rec.tim_id := create_timecard (l_batch_id);
                     l_tim_cntr :=   l_tim_cntr
                                   + 1;
                  -- Otherwise, timecard already generated
                  ELSE
                     -- Delete prior entries, including any errors
                     g_sub_loc := 'Del_Existing_Hrw';
                     del_existing_hrw (g_asm_rec.tim_id);

                     -- Set who update columns on timecard
                     -- Set previous batches back to a hold status
                     IF l_pre_bat_id <> g_asm_rec.batch_id
                     THEN
                        hxt_batch_process.set_batch_status (
                           NULL,
                           g_asm_rec.batch_id,
                           'H'
                        );
                     END IF;

                     l_pre_bat_id := g_asm_rec.batch_id;

                     IF l_reference_number IS NOT NULL
                     THEN
                        g_sub_loc := 'Update_Batch_Ref';
                        l_batch_id := g_asm_rec.batch_id;
                        update_batch_ref (l_batch_id, l_reference_number);
                     END IF;
                      --end SPR C362 by BC
                  -- end timecard exists or not
                  END IF;
               -- restore previous timecard id
               ELSE
                  g_asm_rec.tim_id := l_tim_id;
               END IF; -- end same person or not
            END IF; --SIR60  end if v_retcode 1;

            -- Create hours worked records.
            -- On the assignment flex, the user is only allowed to set autogen to Y with a rotation plan.
            -- begin C257 C261 J35 by BC
            IF v_retcode = 1
            THEN --SIR60
               g_sub_loc := 'Gen_Rot_Plan';

               IF g_asm_rec.egp_id IS NULL
               THEN -- SPR C258 by BC
                  fnd_message.set_name ('HXT', 'HXT_39287_AG_ERR_NO_ERN_POL');
                  fnd_message.set_token (
                     'ASSIGN',
                     g_asm_rec.assignment_number
                  );
                  g_autogen_error := '';
                  RAISE g_form_level_error;
               END IF;

               IF g_asm_rec.rtp_id IS NULL
               THEN
                  fnd_message.set_name ('HXT', 'HXT_39289_AG_ERR_NO_ROT_PLAN');
                  fnd_message.set_token (
                     'ASSIGN',
                     g_asm_rec.assignment_number
                  );
                  g_autogen_error := '';
                  RAISE g_form_level_error;
               END IF;

               IF g_asm_rec.effective_start_date > g_asm_rec.end_date
               THEN
                  fnd_message.set_name ('HXT', 'HXT_39326_INV_ERN_STRT_DATE');
                  g_autogen_error := '';
                  RAISE g_form_level_error;
               END IF;

               IF g_asm_rec.effective_end_date < g_asm_rec.start_date
               THEN
                  fnd_message.set_name ('HXT', 'HXT_39325_ERN_POL_EXP');
                  g_autogen_error := '';
                  RAISE g_form_level_error;
               END IF;

               -- generate all autogen hours
               IF g_asm_rec.start_date = NULL
               THEN
                  fnd_message.set_name ('HXT', 'HXT_39310_START_DATE_NF');
                  g_autogen_error := '';
                  RAISE g_form_level_error;
               END IF;

               IF g_asm_rec.end_date = NULL
               THEN
                  fnd_message.set_name ('HXT', 'HXT_39309_END_DATE_NF');
                  g_autogen_error := '';
                  RAISE g_form_level_error;
               END IF;

               gen_rot_plan (
                  g_asm_rec.start_date,
                  g_asm_rec.end_date,
                  g_asm_rec.rtp_id
               );
            END IF;
         EXCEPTION
            -- insert user error and tech error to hxt_errors
            WHEN g_date_worked_error
            THEN
               call_gen_error (NULL, g_autogen_error, g_sqlerrm);

--SIR015  Set_Updated_By('E');
               g_sqlerrm := NULL;
               g_errors := TRUE; -- SPR C389
            WHEN g_form_level_error
            THEN
               call_gen_error (NULL, g_autogen_error, g_sqlerrm);

--SIR015  Set_Updated_By('E');
               g_sqlerrm := NULL;
               g_errors := TRUE; -- SPR C389
         END; -- end exception block

         -- Save id of current person being processed
         l_person_id := g_asm_rec.person_id;
         -- Save id of current timecard being processed
         l_tim_id := g_asm_rec.tim_id;
         -- Reset error location
         g_err_loc := 'Autogen  '; -- SPR C336 by BC
      END LOOP; -- autogen loop

	--if l_count variable is FALSE then, no timecards have
	--been changed ot have been autogenerated.

      -- Check for errors
      IF g_errors
      THEN
         -- begin SPR C348 by BC
         fnd_message.set_name ('HXT', 'HXT_39364_AUTOGEN_COMP_W_ERRS');
         errbuf := fnd_message.get;
         fnd_message.CLEAR;
         retcode := 2;
      ELSE

  	If not l_tccount then				 		  -- added 2772781
	    FND_MESSAGE.SET_NAME('HXT','HXT_AUTOGEN_PROCESS');            -- added 2772781
	else
         fnd_message.set_name ('HXT', 'HXT_39365_AUTOGEN_COMP_NORM');
	end IF;
         errbuf := fnd_message.get;
         fnd_message.CLEAR;
         retcode := 0;
      END IF;

      DELETE FROM fnd_sessions
            WHERE session_id = USERENV ('SESSIONID');

      COMMIT;
   EXCEPTION
      WHEN g_del_obs_tim_error
      THEN
         DELETE FROM fnd_sessions
               WHERE session_id = USERENV ('SESSIONID');

         COMMIT;
         errbuf := g_sqlerrm;
         fnd_message.CLEAR;
         call_gen_error (NULL, g_sqlerrm, SQLERRM);
         retcode := 2;
      WHEN OTHERS
      THEN
         DELETE FROM fnd_sessions
               WHERE session_id = USERENV ('SESSIONID');

         fnd_message.set_name ('HXT', 'HXT_39366_AUTOGEN_SYST_ERR');
         fnd_message.set_token ('SQLERR', SQLERRM);
         errbuf := fnd_message.get;
         fnd_message.CLEAR;
         retcode := 2;
         COMMIT;
   END;


------------------------------------------------------------------
   PROCEDURE get_work_day(
      a_date             IN              DATE,
      a_work_id          IN              NUMBER,
      a_osp_id           OUT NOCOPY      NUMBER,
      a_sdf_id           OUT NOCOPY      NUMBER,
      a_standard_start   OUT NOCOPY      NUMBER,
      a_standard_stop    OUT NOCOPY      NUMBER,
      a_early_start      OUT NOCOPY      NUMBER,
      a_late_stop        OUT NOCOPY      NUMBER --SIR212
                                               ,
      a_hours            OUT NOCOPY      NUMBER
   )
   IS --SIR212
      --
      --  Procedure GET_WORK_DAY
      --  Purpose:  Gets shift diff and off-shift premium for the person's
      --            assigned shift on an input date
      --
      --  Returns p_error:
      --    0     - No errors occured
      --    Other - Oracle error number
      --
      --
      --
      -- Modification Log:
      --
      --
      CURSOR work_day (a_wp_id NUMBER, a_date DATE)
      IS
         SELECT wsh.off_shift_prem_id, wsh.shift_diff_ovrrd_id,
                sht.standard_start, sht.standard_stop, sht.early_start,
                sht.late_stop, sht.hours
           FROM hxt_shifts sht,
                hxt_weekly_work_schedules wws,
                hxt_work_shifts wsh
          WHERE wsh.week_day = hxt_util.get_week_day(a_date)
            AND wws.id = wsh.tws_id
            AND a_date BETWEEN wws.date_from AND NVL (wws.date_to, a_date)
            AND wws.id = a_work_id
            AND sht.id = wsh.sht_id;
   BEGIN
      -- Get shift diff and off-shift premiums
      OPEN work_day (a_work_id, a_date);
      FETCH work_day INTO a_osp_id,
                          a_sdf_id,
                          a_standard_start,
                          a_standard_stop,
                          a_early_start,
                          a_late_stop,
                          a_hours;
      CLOSE work_day;

--
   EXCEPTION
      WHEN OTHERS
      THEN

--HXT11   g_autogen_error := 'ERROR Get_Work_Day (' || SQLERRM || ')';
         fnd_message.set_name ('HXT', 'HXT_39367_GET_WRK_DAY_ERR');
         fnd_message.set_token ('SQLERR', SQLERRM);
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         call_gen_error (NULL, g_autogen_error, g_sqlerrm); --SPR C389
         g_errors := TRUE; --SPR C389
   END get_work_day;


-----------------------------------------------------------------
   PROCEDURE gen_work_plan (a_start DATE, a_end DATE, a_tws_id NUMBER)
   IS
      --  Purpose
      --    Generate hours worked records FOR employees who have a work plan.
      l_location         VARCHAR2 (100);
      l_days             NUMBER;
      l_time_in          hxt_det_hours_worked.time_in%TYPE; --C421
      l_time_out         hxt_det_hours_worked.time_out%TYPE; --C421
      l_standard_start   NUMBER;
      l_standard_stop    NUMBER;
      l_early_start      NUMBER;
      l_late_stop        NUMBER;
      l_error            NUMBER;
      l_hours            NUMBER;
   -- l_group_id        hxt_sum_hours_worked.group_id%TYPE default null;
   BEGIN
      -- Update location path with function name
      g_err_loc := 'Autogen  Workplan';
      -- Get number of days to be generated
      l_days :=   a_end
                - a_start;

      -- Loop through number of days passed
      -- Get_Group_ID(l_group_id);
      FOR i IN 0 .. l_days
      LOOP
         get_work_day (
              a_start
            + i,
            a_tws_id,
            g_osp_id,
            g_sdf_id,
            l_standard_start,
            l_standard_stop,
            l_early_start,
            l_late_stop,
            l_hours
         );

         -- Create summary record - if holiday, time_out may be changed
         IF (l_hours IS NULL)
         THEN --SIR212
            l_time_in := convert_time (  a_start
                                       + i, l_standard_start);
            l_time_out := convert_time (
                               a_start
                             + i,
                             l_standard_start,
                             l_standard_stop
                          );
         END IF; --SIR212

         create_hrw (
            g_asm_rec.assignment_id,
              a_start
            + i,
            g_asm_rec.tim_id,
            l_time_in,
            l_time_out,
            a_start,
            l_hours
         );
      -- , l_group_id);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39368_GEN_WRK_PLAN_ERR');
         fnd_message.set_token ('SQLERR', SQLERRM);
         g_autogen_error := '';
         hxt_util.DEBUG (g_autogen_error);
         g_sqlerrm := SQLERRM;
         call_gen_error (NULL, g_autogen_error, g_sqlerrm);
         g_errors := TRUE; --SPR C389
   END gen_work_plan;


------------------------------------------------------------------
   PROCEDURE gen_rot_plan (a_start DATE, a_end DATE, a_rtp_id NUMBER)
   IS

--  Purpose
--    Generate hours worked records FOR employees who have a work plan
--    and rotation plan.
      CURSOR cur_sch (c_start DATE, c_end DATE, c_rtp_id NUMBER)
      IS
         SELECT   rt1.tws_id,
                  -- Use the latest of rotation plan start dates or assignment start date
                  TRUNC (
                     DECODE (
                        SIGN (  rt1.start_date
                              - c_start),
                        -1, c_start,
                        rt1.start_date
                     )
                  ) start_date,
                  -- Use the earliest of rotation plan end dates or assignment end date
                  NVL (
                     TRUNC (
                        DECODE (
                           SIGN (  MIN (  rt2.start_date
                                        - 1)
                                 - c_end),
                           -1, MIN (  rt2.start_date
                                    - 1),
                           c_end
                        )
                     ),
                     hr_general.end_of_time
                  ) end_date
             FROM hxt_rotation_schedules rt1, hxt_rotation_schedules rt2
            WHERE rt1.rtp_id = rt2.rtp_id(+)
              AND rt2.start_date(+) > rt1.start_date
              AND rt1.rtp_id = c_rtp_id
              AND c_end >= rt1.start_date
         GROUP BY rt1.tws_id, rt1.start_date
           HAVING c_start <=
                      NVL (  MIN (rt2.start_date)
                           - 1, hr_general.end_of_time)
         ORDER BY rt1.start_date;

      l_cntr   NUMBER := 1;
   BEGIN
      -- Set error location
      g_err_loc := 'Autogen  Rotation'; -- SPR C336 by BC

      <<sch_rec>>
      g_sub_loc := 'Cursor Cur_Sch';

      FOR sch_rec IN cur_sch (a_start, a_end, a_rtp_id)
      LOOP
         -- Report error if missing time on first pass
         IF  (l_cntr = 1) AND (a_start <> sch_rec.start_date)
         THEN
            fnd_message.set_name ('HXT', 'HXT_39288_AG_ERR_DATES');
            fnd_message.set_token (
               'A_START',
               fnd_date.date_to_chardate (a_start)
            );
            fnd_message.set_token (
               'START_DATE',
               fnd_date.date_to_chardate (sch_rec.start_date)
            );
            call_gen_error (NULL, '');
         END IF;

         -- Otherwise, generate time
         g_sub_loc := 'Gen_Work_Plan';
         gen_work_plan (sch_rec.start_date, sch_rec.end_date, sch_rec.tws_id);
         -- Reset error location
         g_err_loc := 'Autogen  Rotation';
         -- Increment loop counter
         l_cntr :=   l_cntr
                   + 1;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_sqlerrm := SQLERRM;
         RAISE g_form_level_error;
   END;


------------------------------------------------------------------
   FUNCTION create_batch (a_tim_cntr NUMBER, a_reference_num VARCHAR2)
      RETURN NUMBER
   IS
      l_batch_id     pay_batch_headers.batch_id%TYPE;
      l_batch_name   pay_batch_headers.batch_name%TYPE;
      l_object_version_number pay_batch_headers.object_version_number%TYPE;
   BEGIN
      -- Check if batch limit exceeded
      IF a_tim_cntr >= g_batch_size
      THEN
         -- Get next batch number
         g_sub_loc := 'Get_Next_Batch_Id';
--         l_batch_id := get_next_batch_id;

      -- create a batch first
      pay_batch_element_entry_api.create_batch_header (
         p_session_date=> g_sysdatetime,
         p_batch_name=> to_char(sysdate, 'DD-MM-RRRR HH24:MI:SS'),
         p_batch_status=> 'U',
         p_business_group_id=> g_bus_group_id,
         p_action_if_exists=> 'I',
         p_batch_reference=> a_reference_num,
         p_batch_source=> 'OTM',
         p_purge_after_transfer=> 'N',
         p_reject_if_future_changes=> 'N',
         p_batch_id=> l_batch_id,
         p_object_version_number=> l_object_version_number
      );
      -- from the batch id, get the batch name

         hxt_user_exits.define_batch_name (
            l_batch_id,
            l_batch_name,
            g_autogen_error
         );
         g_sub_loc := 'INSERT INTO pay_batch_headers';
	       --update the batch name
      pay_batch_element_entry_api.update_batch_header (
         p_session_date=> g_sysdatetime,
         p_batch_id=> l_batch_id,
         p_object_version_number=> l_object_version_number,
         p_action_if_exists=> 'I',
         p_batch_name=> l_batch_name,
         p_batch_reference=> a_reference_num,
         p_batch_source=> 'OTM',
         p_batch_status=> 'U',
         p_purge_after_transfer=> 'N',
         p_reject_if_future_changes=> 'N'
      );

      /*   INSERT INTO pay_batch_headers
                     (batch_id, business_group_id, batch_name, batch_status,
                      action_if_exists, batch_reference, batch_source,
                      purge_after_transfer, reject_if_future_changes,
                      created_by, creation_date, last_updated_by,
                      last_update_date, last_update_login)
              VALUES (l_batch_id, g_bus_group_id, l_batch_name, 'U',
                      'I', a_reference_num, 'OTM',
                      'N', 'N',
                      g_user_id, g_sysdatetime, g_user_id,
                      g_sysdatetime, g_login_id);*/
      END IF;

      RETURN (l_batch_id);
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39284_AG_ERR_WRT_BATCHID');
         fnd_message.set_token ('BATCH_ID', TO_CHAR (l_batch_id));
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_form_level_error;
   END create_batch;


---------------------------------------------------------------------

  PROCEDURE update_batch_ref (l_batch_id NUMBER, a_reference_num VARCHAR2)
   IS


	CURSOR c_ovn is
	Select object_version_number
	From pay_batch_headers

	Where batch_id = l_batch_id;

	l_object_version_number pay_batch_headers.object_version_number%TYPE;

   BEGIN


	Open c_ovn;
	Fetch c_ovn into l_object_version_number;
	Close c_ovn;

    pay_batch_element_entry_api.update_batch_header (
         p_session_date => g_sysdatetime,
         p_batch_id=> l_batch_id,
         p_batch_reference=> a_reference_num,
         p_object_version_number => l_object_version_number
      );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39465_AG_ERR_WRT_REF_ID');
         fnd_message.set_token ('REF_ID', TO_CHAR (l_batch_id));
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_form_level_error;
   END update_batch_ref;


------------------------------------------------------------------
   FUNCTION create_timecard (a_batch_id NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      -- PUBLIC procedure to create timecard record.
      l_tim_id   NUMBER;
   BEGIN
      -- Get next sequence number
      g_sub_loc := 'Get_hxt_Seqno';
      l_tim_id := get_hxt_seqno;
      -- Insert timecard
      g_sub_loc := 'INSERT into hxt_timecards';

      INSERT INTO hxt_timecards_f
                  (id, for_person_id, payroll_id,
                   time_period_id, batch_id, auto_gen_flag, created_by,
                   creation_date, last_updated_by, last_update_date,
                   last_update_login, effective_start_date,
                   effective_end_date)
           VALUES (l_tim_id, g_asm_rec.person_id, g_payroll_id,
                   g_time_period_id, a_batch_id, 'A', g_user_id,
                   g_sysdatetime, g_user_id, g_sysdatetime,
                   g_login_id, g_sysdate,
                   hr_general.end_of_time);

      RETURN (l_tim_id);
   EXCEPTION
      WHEN OTHERS
      THEN --DEBUG ONLY
         fnd_message.set_name ('HXT', 'HXT_39285_AG_ERR_WRT_TIMCARD');
         fnd_message.set_token ('FIRST_NAME', g_asm_rec.first_name);
         fnd_message.set_token ('LAST_NAME', g_asm_rec.last_name);
         fnd_message.set_token ('EMP_NUMBER', TO_CHAR (g_asm_rec.person_id));
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_form_level_error;
   END create_timecard;


-------------------------------------------------------------------------------------------------
   PROCEDURE create_hrw (
      a_assignment_id   NUMBER,
      a_date_worked     DATE,
      a_tim_id          NUMBER,
      a_time_in         DATE,
      a_time_out        DATE,
      a_start           DATE,
      a_hours           NUMBER
   )
   IS
                        -- , a_group_id IN NUMBER) IS
      -- PUBLIC procedure to create hour worked record - returns incremented seqno.
      -- Calls HXT_TIME_SUMMARY.Generate_Details
      l_hrw_id        hxt_det_hours_worked.id%TYPE;
      l_elt_id        hxt_det_hours_worked.element_type_id%TYPE;
      l_seqno         hxt_det_hours_worked.seqno%TYPE; --C421
      l_hours         hxt_det_hours_worked.hours%TYPE             DEFAULT NULL;
      l_time_out      hxt_det_hours_worked.time_out%TYPE          := a_time_out;
      l_hol_yn        VARCHAR2 (1);
      l_retcode       NUMBER;
      l_seq_exceptn   EXCEPTION;
      l_time_in       hxt_det_hours_worked.time_in%TYPE           := a_time_in;
      l_rowid         ROWID;
      v_count         NUMBER;
   -- l_group_id    NUMBER;
   BEGIN
      -- Check for a holiday
      g_sub_loc := 'Get_Holiday_Info';
      l_elt_id := NULL;
      get_holiday_info (a_date_worked, g_asm_rec.hcl_id, l_elt_id, l_hours);


/*
  l_group_id := a_group_id;
  if (l_elt_id IS NOT NULL) then
    Get_Group_ID(l_group_id);
  end if;
*/
  -- Derive time-out if holiday
      IF l_hours IS NOT NULL
      THEN
         IF (   fnd_profile.VALUE ('HXT_HOL_HOURS_FROM_HOL_CAL') = 'Y'
             OR fnd_profile.VALUE ('HXT_HOL_HOURS_FROM_HOL_CAL') IS NULL
            )
         THEN --SIR212
            l_time_out := NULL; -- SPR C332 by BC
            l_time_in := NULL; -- SPR C332 by BC
         ELSIF a_hours IS NOT NULL
         THEN
            l_hours := a_hours;
            l_time_out := NULL;
            l_time_in := NULL;
         ELSE
            l_hours := 24 * (  a_time_out
                             - a_time_in
                            );

            IF l_hours = 0
            THEN
               l_time_out := NULL;
               l_time_in := NULL;
            ELSE
               l_time_out := a_time_out;
               l_time_in := a_time_in;
            END IF;
         END IF;

         l_hol_yn := 'Y';
      -- Otherwise, use time-out passed and derive hours
      ELSE
         --l_time_out := a_time_out;
         IF a_hours IS NOT NULL
         THEN
            l_hours := a_hours;
            l_time_out := NULL;
            l_time_in := NULL;
         ELSE
            l_hours := 24 * (  a_time_out
                             - a_time_in
                            );

            IF (l_hours = 0)
            THEN
               l_time_out := NULL;
               l_time_in := NULL;
            END IF;
         END IF;

         l_hol_yn := 'N';
      END IF;

      -- Get ID
      g_sub_loc := 'Get_hxt_Seqno';
      l_hrw_id := get_hxt_seqno;

      IF l_hrw_id IS NULL
      THEN -- C257 C261 by BC
         RAISE l_seq_exceptn;
      END IF;

      -- Get next available line seqno
      g_sub_loc := 'HXT_UTIL.Get_Next_Seqno';

      IF g_sub_loc IS NULL
      THEN -- C257 C261 by BC
         RAISE l_seq_exceptn;
      END IF;

      l_seqno := hxt_util.get_next_seqno (a_tim_id, a_date_worked);

      IF l_seqno IS NULL
      THEN -- C257 C261 by BC
         RAISE l_seq_exceptn;
      END IF;

      -- Insert hour worked record
      g_sub_loc := 'INSERT into hxt_hours_worked';


--SIR012  INSERT into hxt_sum_hours_worked --C431
-- 1704149 Commented the lines which insert values into WHO columns.
      INSERT INTO hxt_sum_hours_worked_f
                  (id, tim_id, date_worked, seqno,
                   hours, assignment_id, element_type_id, time_in, time_out
--  , created_by
--  , creation_date
--  , last_updated_by
--  , last_update_date
--  , last_update_login
                                                                           ,
                   effective_start_date, effective_end_date, earn_pol_id)
           -- , group_id)
           VALUES (l_hrw_id, g_asm_rec.tim_id, a_date_worked, l_seqno,
                   l_hours, a_assignment_id, l_elt_id, l_time_in, l_time_out
--  , g_user_id
--  , g_sysdatetime
--  , g_user_id
--  , g_sysdatetime
--  , g_login_id
                                                                            ,
                   g_sysdate, hr_general.end_of_time, g_asm_rec.egp_id);

      -- , l_group_id);
      COMMIT;

      -- begin SIR012. need rowid for call to generate_details.
      SELECT ROWID
        INTO l_rowid
        FROM hxt_sum_hours_worked_f
       WHERE id = l_hrw_id;

      -- Create detail records
      g_sub_loc := 'HXT_TIME_SUMMARY.Generate_Details';
      l_retcode :=
            hxt_time_summary.generate_details (
               g_asm_rec.egp_id,
               g_asm_rec.egp_type,
               g_asm_rec.egt_id,
               g_asm_rec.sdp_id,
               g_asm_rec.hdp_id,
               g_asm_rec.hcl_id -- Fassadi 13/MAR/01  bug 1680151 was fixed.
                               ,
               g_asm_rec.pep_id,
               g_asm_rec.pip_id,
               g_sdf_id --SPR C389
                       ,
               g_osp_id --SPR C389
                       ,
               NULL -- standard_start
                   ,
               NULL -- standard_stop
                   ,
               NULL -- early_start
                   ,
               NULL -- late_stop
                   ,
               l_hol_yn,
               g_asm_rec.person_id,
               g_err_loc,
               l_hrw_id,
               a_tim_id,
               a_date_worked,
               g_asm_rec.assignment_id,
               l_hours,
               l_time_in -- SPR C332 by BC
                        ,
               l_time_out,
               l_elt_id -- element_type_id
                       ,
               NULL -- FCL_EARN_REASON_CODE
                   ,
               NULL -- FFV_COST_CENTER_ID
                   ,
               NULL -- FFV_LABOR_ACCOUNT_ID
                   ,
               NULL -- TAS_ID
                   ,
               NULL -- LOCATION_ID
                   ,
               NULL -- SHT_ID
                   ,
               NULL -- HRW_COMMENT
                   ,
               NULL -- FFV_RATE_CODE_ID
                   ,
               NULL -- RATE_MULTIPLE
                   ,
               NULL -- HOURLY_RATE
                   ,
               NULL -- AMOUNT
                   ,
               NULL -- FCL_TAX_RULE_CODE
                   ,
               NULL -- SEPARATE_CHECK_FLAG
                   ,
               l_seqno -- SEQNO
                      ,
               g_user_id -- CREATED_BY
                        ,
               g_sysdatetime -- CREATION_DATE
                            ,
               g_user_id -- LAST_UPDATED_BY
                        ,
               g_sysdatetime -- LAST_UPDATE_DATE
                            ,
               g_login_id -- LAST_UPDATE_LOGIN
                         ,
               a_start -- START DATE SPR C389
                      ,
               l_rowid,
               g_sysdate,
               hr_general.end_of_time,
               NULL -- PROJACCT Project_id
                   ,
               NULL -- TA35     Job_id
                   ,
               'P' -- RETROPAY Pay_Status
                  ,
               'P' -- PROJACCT PA_Status
                  ,
               NULL -- RETROPAY Retro_Batch_Id
                   ,
               'CORRECTION' -- RETROPAY DT_UPDATE_MODE
            -- , l_group_id             -- HXT11i1
            );

      -- Check for errors
      IF l_retcode = 2
      THEN
         g_errors := TRUE;
         fnd_message.set_name ('HXT', 'HXT_39268_ERR_IN_TIME_GEN');
         g_autogen_error := '';
         call_gen_error (NULL, g_autogen_error, g_sqlerrm); --SPR C389
      END IF;
   EXCEPTION
      WHEN l_seq_exceptn
      THEN
         fnd_message.set_name ('HXT', 'HXT_39278_AG_ERR_SEL_SEQNO');
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_date_worked_error;
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39277_AG_ERR_INS_HRS_WKED');
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_date_worked_error;
   END create_hrw;


------------------------------------------------------------------
   FUNCTION get_hxt_seqno
      RETURN NUMBER
   IS
      -- PUBLIC procedure to get next sequence number from HXT_SEQNO.
      CURSOR cur_id
      IS
         SELECT hxt_seqno.NEXTVAL
           FROM DUAL;

      l_nextval   NUMBER;
   BEGIN
      -- Get next value
      g_sub_loc := 'OPEN cur_id';
      OPEN cur_id;
      FETCH cur_id INTO l_nextval;
      CLOSE cur_id;
      RETURN (l_nextval);
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39283_AG_ERR_GET_SEQNO2');
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_form_level_error;
   END get_hxt_seqno;


------------------------------------------------------------------
   FUNCTION get_next_batch_id
      RETURN NUMBER
   IS
      -- PUBLIC procedure to get next BATCH sequence number
      l_nextval   NUMBER;
   BEGIN
      -- Get next value
      g_sub_loc := 'OPEN cur_id';

      SELECT pay_batch_headers_s.NEXTVAL
        INTO l_nextval
        FROM DUAL; --SPR C166 BY BC

      RETURN (l_nextval);
   EXCEPTION
      WHEN OTHERS
      THEN
         g_sqlerrm := SQLERRM;
         fnd_message.set_name ('HXT', 'HXT_39282_AG_ERR_GET_BATCHID');
         g_autogen_error := '';
         RAISE g_form_level_error;
   END get_next_batch_id;


------------------------------------------------------------------
                        -- PRIVATE --
------------------------------------------------------------------
   PROCEDURE call_gen_error (
      a_hrw_id         NUMBER,
      a_error_text     VARCHAR2,
      a_ora_err_text   VARCHAR2 DEFAULT NULL
   )
   IS
   -- PRIVATE procedure to create error table entries for this package
   -- Parameters for call to Gen_Error:
   BEGIN
      -- Insert into error table
      hxt_util.gen_error (
         g_asm_rec.batch_id,
         g_asm_rec.tim_id,
         NULL,
         g_time_period_id,
         a_error_text,
         g_err_loc,
         a_ora_err_text,
         g_sysdate,
         hr_general.end_of_time,
         'ERR'
      );
      -- Set error flag
      g_errors := TRUE;
   END call_gen_error;


------------------------------------------------------------------
   FUNCTION convert_time (
      a_date       DATE,
      a_time_in    NUMBER,
      a_time_out   NUMBER DEFAULT NULL
   )
      RETURN DATE
   IS
      l_date      DATE   := a_date;
      l_convert   NUMBER := NVL (a_time_out, a_time_in);
   BEGIN
      IF      (a_time_out IS NOT NULL)
          AND (   a_time_out < a_time_in
               OR (a_time_out = a_time_in AND a_time_in <> 0)
              )
      THEN
         l_date :=   l_date
                   + 1; -- use next day if past midnight
      END IF;

      RETURN (TO_DATE (
                    TO_CHAR (l_date, 'MMDDYYYY')
                 || TO_CHAR (l_convert, '0009'),
                 'MMDDYYYYHH24MI'
              )
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39280_AG_ERR_DAT_DESC');
         fnd_message.set_token ('DATE', fnd_date.date_to_chardate (l_date));
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_date_worked_error;
   END convert_time;


------------------------------------------------------------------
   FUNCTION convert_time (
      a_date       DATE,
      a_time_in    VARCHAR2,
      a_time_out   VARCHAR2 DEFAULT NULL
   )
      RETURN DATE
   IS
   BEGIN
      RETURN (convert_time (
                 a_date,
                 TO_NUMBER (REPLACE (a_time_in, ':')),
                 TO_NUMBER (REPLACE (a_time_out, ':'))
              )
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39281_AG_ERR_CONV_TIME');
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_date_worked_error;
   END convert_time;


------------------------------------------------------------------
   PROCEDURE del_obsolete_tim
   IS
   -- PRIVATE procedure to delete timecards that were autogen'ed for this period
   -- that won't be autogen'ed again.  Hours worked and error records will
   -- cascade-delete.

CURSOR c_get_tim_id IS
      SELECT id  FROM hxt_timecards_f tim
            WHERE tim.auto_gen_flag = 'A'
              AND tim.time_period_id = g_time_period_id
       	      AND exists										-- added 2772781
		   (
		   select '1' from  HXT_BATCH_STATES							-- added 2772781
		   where (hxt_batch_states.STATUS  <>'VT' and hxt_batch_states.batch_id=tim.batch_id)	-- added 2772781
		   OR     tim.batch_id is null								-- added 2772781
		   )
              AND NOT EXISTS (
                        SELECT 'x'
                          FROM per_time_periods ptp,
                               hxt_per_aei_ddf_v aeiv,
                               per_assignments_f asm
                         WHERE asm.person_id = tim.for_person_id
                           AND ptp.start_date
                                  BETWEEN asm.effective_start_date
                                      AND asm.effective_end_date
                           AND aeiv.assignment_id = asm.assignment_id --ORACLE
                           AND ptp.start_date
                                  BETWEEN aeiv.effective_start_date
                                      AND aeiv.effective_end_date
                           AND aeiv.hxt_autogen_hours_yn = 'Y' --ORACLE
                           AND ptp.time_period_id = tim.time_period_id);

BEGIN
      -- Delete obsolete timecards
      g_sub_loc := 'DELETE from hxt_timecards';
FOR l_record IN c_get_tim_id
   LOOP
      DELETE FROM hxt_det_hours_worked_f
            WHERE tim_id = l_record.id;

      DELETE FROM hxt_sum_hours_worked_f
            WHERE tim_id = l_record.id;

      DELETE FROM hxt_timecards_f
            WHERE id = l_record.id;
   END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39466_TCARD_DEL_FAIL');
         fnd_message.set_token ('SQLERR', SQLERRM);
         g_sqlerrm := fnd_message.get;
         RAISE g_del_obs_tim_error;
   END del_obsolete_tim;


------------------------------------------------------------------
--Begin SIR60
------------------------------------------------------------------
   FUNCTION chk_timecard_exists (
      a_payroll_id       NUMBER,
      a_time_period_id   NUMBER,
      a_person_id        NUMBER
   )
      RETURN NUMBER
   IS

-- function to check to see if timecards exists where AutoGen
-- flag set not equal to 'A'.  If there are any then get out of loop above
-- because do not want to re-autogen anything that is 'C', 'M', 'U', 'T'.
--  g_sub_loc := 'Chk Timecards Exists from ta_timecards';

--There was a problem with the initial cursor g_cur_asm where it was returning
--records that should not have been returned - for example, timecards with
--autogen flag = 'C' were being returned when they shouldn't have and that
--was causing record to be passed into loop which in turn created a second
--timecard with source of autogen for same payroll and time period.  This code
-- returns a value of 1 if no data found which in turn falls through regular
-- code to create autogen timecard, otherwise don't create autogen record
-- and so get out of loop.
      v_retcode         NUMBER;
      f_auto_gen_flag   VARCHAR (1);
      f_person_id       NUMBER (10); -- 30-Nov-98  THis is for R115 changes.


--BEGIN SIR435
      CURSOR cur_tim_exists
      IS
         SELECT auto_gen_flag, for_person_id
           FROM hxt_timecards_f tim
          WHERE tim.auto_gen_flag <> 'A'
            AND tim.for_person_id = a_person_id
            AND tim.time_period_id = a_time_period_id
            AND tim.payroll_id = a_payroll_id
            -- MV: 03-DEC-2002
            -- I did some investigation with regards to this query and I do not see why
            -- we need the exists statement in this query.  It checks if the autogen flag
            -- is set for the assignment, but it will always be set because the driving query
            -- g_cur_asm already has this check.
            -- For now we leave it in because from experience we know that drastic changes
            -- in OTM like this have a knock on effect on other code in OTM which is dificult
            -- to spot.  We only change the statement to be in line with the driving cursor
            -- so it can handle mid period hiring and firing
            -- Again I do not think that this is the correct solution because it will
            -- return all assignment records within a payroll period, this could be
            -- multiple records, one for every datetrack update on the assignment or aei
            -- so there might still be an issue when an assignment switches from autogen
            -- to no-autogen mid-period.  We will need to look at this later.
            AND EXISTS ( SELECT 'x'
                           FROM per_time_periods ptp,
                                hxt_per_aei_ddf_v asmv,
                                per_assignments_f asm
                          WHERE asm.person_id = tim.for_person_id
                            -- next 2 lines copied from g_cur_asm
                            AND asm.effective_start_date <= ptp.end_date
                            AND asm.effective_end_date >= ptp.start_date
                            /* AND ptp.start_date BETWEEN asm.effective_start_date
                                                   AND asm.effective_end_date */
                            AND asmv.assignment_id = asm.assignment_id
                            -- next 2 lines copied from g_cur_asm
                            AND asmv.effective_start_date <= ptp.end_date
                            AND asmv.effective_end_date >= ptp.start_date
                            /* AND ptp.start_date BETWEEN asmv.effective_start_date
                                                   AND asmv.effective_end_date */
                            AND asmv.hxt_autogen_hours_yn = 'Y'
                            AND ptp.time_period_id = tim.time_period_id);
   BEGIN
      OPEN cur_tim_exists;
      FETCH cur_tim_exists INTO f_auto_gen_flag, f_person_id;

      IF cur_tim_exists%FOUND
      THEN
         v_retcode := 0;
         RETURN (v_retcode);
      ELSE
         v_retcode := 1;
         RETURN (v_retcode);
      END IF;
   END chk_timecard_exists;


------------------------------------------------------------------
   PROCEDURE del_existing_hrw (a_tim_id NUMBER)
   IS
   -- PRIVATE procedure to delete hours-worked that were autogen'ed for this
   -- period that will be autogen'ed again.  Error records will cascade-delete.
   BEGIN
      -- Delete existing hour-worked entries
      fnd_message.set_name ('HXT', 'HXT_39276_AG_ERR_DEL_HRS_WKED');
      g_autogen_error := '';
      g_sub_loc := 'DELETE from hxt_det_hours_worked';

      -- Bug 7359347
      -- Set session date.
      IF g_gen_session_date IS NULL
      THEN
         g_gen_session_date := hxt_tim_col_util.return_session_date;
      END IF;

      DELETE FROM hxt_det_hours_worked_f --C421
            WHERE tim_id = a_tim_id;

      --SIR012 DELETE from hxt_sum_hours_worked
      -- Bug 7359347
      -- Delete from the table instead of the view so FND_SESSIONS is not required.
      /*
      DELETE FROM hxt_sum_hours_worked
            WHERE tim_id = a_tim_id; --C421
      */
      DELETE FROM hxt_sum_hours_worked_f
            WHERE tim_id = a_tim_id
              AND g_gen_session_date BETWEEN effective_start_date
                                         AND effective_end_date; --C421

      COMMIT;
      -- Delete existing hxt_errors records for this timecard
      fnd_message.set_name ('HXT', 'HXT_39275_AG_ERR_DEL_ERRS');
      g_autogen_error := '';

      DELETE FROM hxt_errors
            WHERE tim_id = a_tim_id
              AND (   location LIKE 'Autogen%'
                   OR location LIKE 'AUTO%'
                  ); --C336

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_sqlerrm := SQLERRM;
         RAISE g_form_level_error;
   END del_existing_hrw;


------------------------------------------------------------------
   PROCEDURE get_holiday_info (
      a_date     IN              DATE,
      a_hcl_id   IN              NUMBER,
      a_elt_id   OUT NOCOPY      NUMBER,
      a_hours    OUT NOCOPY      NUMBER
   )
   IS

-- Procedure
--    Get_Holiday_Info
-- Purpose
--    Return holiday earning and default hours for input holiday
--    calendar if input day is holiday.
-- Arguments
--    a_date      The date being checked.
--    a_hcl_id    The Holiday Calendar to be checked.
-- Returns:
--      a_elt_id - holiday earning ID or null
--      a_hours  - paid hours for holiday
-- Modification Log:
-- 01/31/96   PJA   Created.
      CURSOR cur_hcl (c_date DATE, c_hcl_id NUMBER)
      IS
         -- SELECT hcl.element_type_id, hdy.hours -- SPR C332 by BC
         SELECT DECODE (hdy.hours, NULL, NULL, hcl.element_type_id), hdy.hours -- SPR C332 by BC
           FROM hxt_holiday_calendars hcl, hxt_holiday_days hdy
          WHERE hdy.holiday_date = c_date
            AND hcl.id = hdy.hcl_id
            AND c_date BETWEEN hcl.effective_start_date
                           AND hcl.effective_end_date
            AND hcl.id = c_hcl_id;
   BEGIN
      -- Get holiday data
      g_sub_loc := 'Cur_Hcl';
      OPEN cur_hcl (a_date, a_hcl_id);
      FETCH cur_hcl INTO a_elt_id, a_hours;
      CLOSE cur_hcl;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXT', 'HXT_39286_AG_ERR_SEL_HOL_HRS');
         g_autogen_error := '';
         g_sqlerrm := SQLERRM;
         RAISE g_date_worked_error;
   END get_holiday_info;


------------------------------------------------------------------
--BEGIN HXT11i1
/*
PROCEDURE Get_Group_ID (a_group_id OUT NOCOPY NUMBER) IS
--
-- This procedure returns the next group id.  Group IDs are used to tie
-- together summary and detail rows on the timecard.
--
  CURSOR C IS
      SELECT  HXT_GROUP_ID_S.NEXTVAL
      FROM    SYS.DUAL;
BEGIN
    g_sub_loc := 'Get_Group_ID';
    OPEN C;
    FETCH C
    INTO    a_group_id;
    CLOSE C;
  EXCEPTION
    WHEN OTHERS THEN
     IF g_autogen_error IS NULL THEN
       g_autogen_error :=  'Autogen failed trying to get Group ID for summary/detail rows';
     END IF;
     IF g_sqlerrm IS NULL THEN
       g_sqlerrm := SQLERRM;
     END IF;
    RAISE g_date_worked_error;
END Get_Group_ID;
*/
   PROCEDURE manage_fnd_sessions
   IS
      CURSOR old_row_exists_cur
      IS
         SELECT '1'
           FROM fnd_sessions
          WHERE session_id = USERENV ('SESSIONID')
            AND effective_date < TRUNC (  SYSDATE
                                        - 1);

      CURSOR row_exists_cur
      IS
         SELECT '1'
           FROM fnd_sessions
          WHERE session_id = USERENV ('SESSIONID')
            AND TRUNC (effective_date) BETWEEN TRUNC (  SYSDATE
                                                      - 1)
                                           AND SYSDATE;

      l_dummy   VARCHAR2 (1);
   BEGIN
      IF g_gen_session_date IS NULL
      THEN
          OPEN old_row_exists_cur;
      	  FETCH old_row_exists_cur INTO l_dummy;

      	  IF old_row_exists_cur%FOUND
      	  THEN
      	     DELETE FROM fnd_sessions
      	           WHERE session_id = USERENV ('SESSIONID')
      	             AND effective_date < TRUNC (  SYSDATE
      	                                         - 1);

      	     COMMIT;
      	  END IF;
      	  OPEN row_exists_cur;
      	  FETCH row_exists_cur INTO l_dummy;

      	  IF row_exists_cur%NOTFOUND
      	  THEN
      	     INSERT INTO fnd_sessions
      	                 (session_id, effective_date)
      	          VALUES (USERENV ('SESSIONID'), TRUNC (SYSDATE));

      	     COMMIT;
      	  END IF;

      	  -- Bug 7359347
      	  -- Set session date.
      	  g_gen_session_date := hxt_tim_col_util.return_session_date;

      END IF;

   END;
------------------------------------------------------------------
END hxt_time_gen;

/
