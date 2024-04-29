--------------------------------------------------------
--  DDL for Package Body HXT_BATCH_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_BATCH_VAL" AS
/* $Header: hxtbtval.pkb 120.11.12010000.5 2009/06/13 13:06:34 asrajago ship $ */
   -- Global package name
   g_package   CONSTANT VARCHAR2 (33) := 'hxt_batch_val.';
   -- Global Error Level - used to store worst error that occured
   g_error_level        NUMBER (1)    := 0;
   g_tc_error_level     NUMBER (1)    := 0;
   g_debug boolean := hr_utility.debug_enabled;

   -- Bug 6785744
   -- Global variable to record the date inserted into fnd_sessions when
   -- the process starts. In case the process crosses over a midnight, a new
   -- date is put in.

   g_start_sysdate  DATE := TRUNC(SYSDATE);

-- Bug 8584436
-- Global variables added to pick up error message and description from
-- HXT_TIMECARD_VALIDATION
g_lookup_error   VARCHAR2(500);
g_lookup_desc    VARCHAR2(500);


   FUNCTION error_level
      RETURN NUMBER
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (
		    '   returning error level '
		 || g_error_level,
		 20
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN g_error_level;
   END error_level;

   FUNCTION tc_error_level
      RETURN NUMBER
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'tc_error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (
		    '   returning timecard error level '
		 || g_tc_error_level,
		 20
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN g_tc_error_level;
   END tc_error_level;

   PROCEDURE set_tc_error_level (p_tc_error_level IN NUMBER)
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'set_tc_error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      g_tc_error_level := p_tc_error_level;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
   END set_tc_error_level;

   PROCEDURE set_tc_error_level (p_valid IN VARCHAR, p_msg_level IN VARCHAR2)
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'set_tc_error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF p_valid = 'N'  THEN
         IF (p_msg_level = 'S') THEN
            set_tc_error_level (p_tc_error_level => 3);
         ELSIF (p_msg_level = 'E') THEN
            set_tc_error_level (p_tc_error_level => 2);
         ELSIF (p_msg_level = 'W') THEN
            set_tc_error_level (p_tc_error_level => 1);
         END IF;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
   END set_tc_error_level;

   PROCEDURE set_error_level (p_error_level IN NUMBER)
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'set_error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      g_error_level := p_error_level;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
   END set_error_level;

   PROCEDURE reset_error_level
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                                || 'reset_error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      g_error_level := 0;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
   END reset_error_level;

   PROCEDURE set_error_level (p_valid IN VARCHAR, p_msg_level IN VARCHAR2)
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'set_error_level';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF p_valid = 'N'
      THEN
         IF (p_msg_level = 'S')
         THEN
            set_error_level (p_error_level => 3);
         ELSIF ((p_msg_level = 'E') AND (NVL (error_level, 0) < 3))
         THEN
            set_error_level (p_error_level => 2);
         ELSIF ((p_msg_level = 'W') AND (NVL (error_level, 0) < 2))
         THEN
            set_error_level (p_error_level => 1);
         END IF;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
   END set_error_level;

   PROCEDURE delete_prev_val_errors (
      p_batch_id   IN   hxt_timecards_f.batch_id%TYPE
   )
   AS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'delete_prev_val_errors';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      DELETE FROM hxt_errors_x
            WHERE ppb_id = p_batch_id AND location LIKE 'Validate%';

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
   END delete_prev_val_errors;

   PROCEDURE delete_prev_val_errors (p_tim_id IN hxt_timecards_f.id%TYPE)
   AS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'delete_prev_val_errors';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      DELETE FROM hxt_errors_x
            WHERE tim_id = p_tim_id AND location LIKE 'Validate%';

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
   END delete_prev_val_errors;

   FUNCTION errors_exist (p_tim_id IN hxt_timecards.id%TYPE)
      RETURN BOOLEAN
   AS
      l_proc    VARCHAR2 (72) ;

      CURSOR find_errors (p_tim_id hxt_timecards.id%TYPE)
      IS
         SELECT 1
           FROM hxt_errors_x
          WHERE tim_id = p_tim_id;

      l_find_error      NUMBER;
      l_error_exist     BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'errors_exist';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN find_errors (p_tim_id);
      FETCH find_errors INTO l_find_error;

      IF find_errors%FOUND
      THEN
         if g_debug then
 		 hr_utility.set_location (
		       '   Errors exist for TC '
		    || p_tim_id,
		    20
		 );
         end if;
         l_error_exist := TRUE;
      ELSE
         l_error_exist := FALSE;
      END IF;

      CLOSE find_errors;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_error_exist;
   END errors_exist;

   FUNCTION timecard_end_date (p_tim_id IN hxt_timecards_f.id%TYPE)
      RETURN per_time_periods.end_date%TYPE
   AS
      l_proc    VARCHAR2 (72) ;

      CURSOR csr_timecard_end_date (p_tim_id hxt_timecards_f.id%TYPE)
      IS
         SELECT ptp.end_date
           FROM per_time_periods ptp, hxt_timecards_x htx
          WHERE ptp.time_period_id = htx.time_period_id AND htx.id = p_tim_id;

      l_tc_end_dt       per_time_periods.end_date%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'timecard_end_date';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_timecard_end_date (p_tim_id);
      FETCH csr_timecard_end_date INTO l_tc_end_dt;
      CLOSE csr_timecard_end_date;
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_tc_end_dt, 30);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
      RETURN l_tc_end_dt;
   END timecard_end_date;

   FUNCTION person_effective_at_tc_end (
      p_person_id   IN   per_people_f.person_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   )
      RETURN BOOLEAN
   IS
      l_proc       VARCHAR2 (72);


      CURSOR csr_person_effective (
         p_effective_date   per_people_f.effective_end_date%TYPE,
         p_person_id        per_people_f.person_id%TYPE
      )
      IS
         SELECT 1
           FROM per_people_f ppf
          WHERE person_id = p_person_id
            AND p_effective_date BETWEEN ppf.effective_start_date
                                     AND ppf.effective_end_date;

      l_person_effective   BOOLEAN;
      l_found_person       NUMBER;
      l_eff_dt             per_people_f.effective_end_date%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'person_effective_at_tc_end';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_eff_dt := timecard_end_date (p_tim_id => p_tim_id);
      OPEN csr_person_effective (l_eff_dt, p_person_id);
      FETCH csr_person_effective INTO l_found_person;

      IF (csr_person_effective%FOUND)
      THEN
         if g_debug then
		 hr_utility.set_location (
		       '   Person '
		    || p_person_id
		    || ' is effective on '
		    || l_eff_dt
		    || '.',
		    20
		 );
         end if;
        l_person_effective := TRUE;
      ELSE
         l_person_effective := FALSE;
      END IF;

      CLOSE csr_person_effective;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
      RETURN l_person_effective;
   END person_effective_at_tc_end;

   PROCEDURE record_error (
      p_batch_id     IN   NUMBER,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_error_code   IN   VARCHAR2
   )
   AS
      l_proc             VARCHAR2 (72)  ;
      l_validate_time   CONSTANT VARCHAR2 (72)  := 'Validate Time';
      l_error_msg                VARCHAR2 (255);
      l_valid                    VARCHAR2 (1);
      l_msg_level                VARCHAR2 (1);
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'record_error';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      hxt_util.set_timecard_error (
         p_batch_id,
         p_tim_id,
         NULL,
         p_period_id,
         l_error_msg,
         l_validate_time,
         SQLERRM,
         p_error_code,
         l_valid,
         l_msg_level
      );
      set_error_level (p_valid => l_valid, p_msg_level => l_msg_level);
      set_tc_error_level (p_valid => l_valid, p_msg_level => l_msg_level);
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END record_error;

   PROCEDURE person_validation (
      p_batch_id    IN   NUMBER,
      p_person_id   IN   hxt_timecards.for_person_id%TYPE,
      p_period_id   IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   )
   AS
      l_proc    VARCHAR2 (72)  ;
      l_error_msg       VARCHAR2 (255);
      l_valid           VARCHAR2 (1);
      l_msg_level       VARCHAR2 (1);
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'person_validation';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF NOT (person_effective_at_tc_end (
                 p_person_id=> p_person_id,
                 p_tim_id=> p_tim_id
              )
             )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39316_person_nf,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);

     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('PERIOD_END_DATE',period_end_date(p_period_id));
     FND_MESSAGE.set_token('TIMECARD_ID',p_tim_id);
     FND_MESSAGE.set_token('NAME',person_name(p_person_id));
     g_errtab(c_39316_person_nf).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39316_person_nf).errtype := g_lookup_desc;


         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39316_person_nf
         );
      g_errtab.DELETE(c_39316_person_nf);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END person_validation;

   PROCEDURE excess_pto (
      p_batch_id    IN   NUMBER,
      p_calculation_date IN hxt_sum_hours_worked_x.date_worked%TYPE,
      p_person_id   IN   hxt_timecards.for_person_id%TYPE,
      p_period_id   IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   )
   IS
      l_proc        VARCHAR2 (72) ;
      l_accrual_plan_name   pay_accrual_plans.accrual_plan_name%TYPE;
      l_charged_hrs         NUMBER;
      l_accrued_hrs         NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'excess_pto';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;

      -- M.Bhammar - Bug:5107665
      -- hr_session_utilities.insert_session_row (TO_DATE (SYSDATE,'YYYY/MM/DD'));
      -- hr_session_utilities.insert_session_row (SYSDATE); /* Bug 6024976 */

      IF (hxt_util.accrual_exceeded (
             p_tim_id,
--         M.Bhammar - bug 5214727
--         timecard_end_date (p_tim_id => p_tim_id),
             p_calculation_date,
             l_accrual_plan_name,
             l_charged_hrs,
             l_accrued_hrs
          )
         )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39335_exceeded_accrued_hrs,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);

     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('USED_HRS',l_charged_hrs);
     FND_MESSAGE.set_token('ACCRUED_HRS',l_accrued_hrs);
     FND_MESSAGE.set_token('NAME',person_name(p_person_id));
     g_errtab(c_39335_exceeded_accrued_hrs).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39335_exceeded_accrued_hrs).errtype := g_lookup_desc;


         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39335_exceeded_accrued_hrs
         );
      g_errtab.DELETE(c_39335_exceeded_accrued_hrs);
      END IF;

      -- hr_session_utilities.remove_session_row; /* Bug 6024976 */
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END excess_pto;

   FUNCTION primary_assignment_id (
      p_person_id        IN   per_people_f.person_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN per_all_assignments_f.assignment_id%TYPE
   IS
      l_proc    VARCHAR2 (72) ;

      CURSOR csr_prim_asg_id (
         p_person_id        per_people_f.person_id%TYPE,
         p_effective_date   DATE
      )
      IS

SELECT /*+ ORDERED
           INDEX(paf PER_ASSIGNMENTS_F_N12)
           INDEX(past PER_ASSIGNMENT_STATUS_TYPE_PK) */
       /* Hints supplied to always force the correct execution plan */
       paf.assignment_id
FROM
       per_assignments_f paf,
       per_assignment_status_types past
WHERE
       paf.person_id = p_person_id AND
       p_effective_date  BETWEEN
       paf.effective_start_date AND paf.effective_end_date AND
       paf.primary_flag = 'Y'
AND
       past.assignment_status_type_id = paf.assignment_status_type_id AND
       past.per_system_status = 'ACTIVE_ASSIGN';

      l_prim_asg_id     per_all_assignments_f.assignment_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'primary_assignment_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_prim_asg_id (p_person_id, p_effective_date);
      FETCH csr_prim_asg_id INTO l_prim_asg_id;
      CLOSE csr_prim_asg_id;
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_prim_asg_id, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_prim_asg_id;
   END primary_assignment_id;

   FUNCTION holiday_calendar_id (
      p_person_id        IN   per_people_f.person_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN hxt_holiday_calendars.id%TYPE
   IS
      l_proc          VARCHAR2 (72) ;
      l_holiday_calendar_id   hxt_holiday_calendars.id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'holiday_calendar_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
     l_holiday_calendar_id :=
            holiday_calendar_id (
               p_assignment_id=> primary_assignment_id (
                           p_person_id=> p_person_id,
                           p_effective_date=> p_effective_date
                        ),
               p_effective_date=> p_effective_date
            );
      if g_debug then
	      hr_utility.set_location (
		    '   returning '
		 || l_holiday_calendar_id,
		 20
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
     RETURN l_holiday_calendar_id;
   END holiday_calendar_id;

   FUNCTION holiday_calendar_id (
      p_assignment_id    IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN hxt_holiday_calendars.id%TYPE
   IS
      l_proc          VARCHAR2 (72) ;

      CURSOR csr_holiday_calendar_id (
         p_assignment_id    per_all_assignments_f.assignment_id%TYPE,
         p_effective_date   DATE
      )
      IS
         SELECT hhc.id
           FROM hxt_holiday_calendars hhc,
                hxt_earning_policies hep,
                hxt_add_assign_info_f haaif
          WHERE p_effective_date BETWEEN hhc.effective_start_date
                                     AND hhc.effective_end_date
            AND hep.hcl_id = hhc.id
            AND p_effective_date BETWEEN hep.effective_start_date
                                     AND hep.effective_end_date
            AND haaif.earning_policy = hep.id
            AND p_effective_date BETWEEN haaif.effective_start_date
                                     AND haaif.effective_end_date
            AND haaif.assignment_id = p_assignment_id;

      l_holiday_calendar_id   hxt_holiday_calendars.id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'holiday_calendar_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_holiday_calendar_id (p_assignment_id, p_effective_date);
      FETCH csr_holiday_calendar_id INTO l_holiday_calendar_id;
      CLOSE csr_holiday_calendar_id;
      if g_debug then
 	      hr_utility.set_location (
		    '   returning '
		 || l_holiday_calendar_id,
		 20
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_holiday_calendar_id;
   END holiday_calendar_id;

   FUNCTION holiday_element_id (p_hol_cal_id IN hxt_holiday_calendars.id%TYPE)
      RETURN hxt_holiday_calendars.element_type_id%TYPE
   IS
      l_proc         VARCHAR2 (72);

      CURSOR csr_holiday_element_id (
         p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
      )
      IS
         SELECT hhc.element_type_id
           FROM hxt_holiday_calendars hhc
          WHERE hhc.id = p_hol_cal_id;

      l_holiday_element_id   hxt_holiday_calendars.element_type_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'holiday_element_id';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   p_hol_cal_id IN = '
				       || p_hol_cal_id, 20);
      end if;
      OPEN csr_holiday_element_id (p_hol_cal_id);
      FETCH csr_holiday_element_id INTO l_holiday_element_id;
      CLOSE csr_holiday_element_id;
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_holiday_element_id, 30);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 40);
      end if;
      RETURN l_holiday_element_id;
   END holiday_element_id;

   FUNCTION day_is_holiday (
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE,
      p_day          IN   DATE
   )
      RETURN BOOLEAN
   IS
      l_proc        VARCHAR2 (72);

      CURSOR csr_holiday_today (
         p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE,
         p_day               DATE
      )
      IS
         SELECT 1
           FROM hxt_holiday_calendars hhc, hxt_holiday_days hhd
          WHERE hhc.id = p_hol_cal_id
            AND hhc.id = hhd.hcl_id
            AND hhd.holiday_date = p_day
            AND hhd.hours >= 0;

      l_rec_holiday_today   csr_holiday_today%ROWTYPE;
      l_holiday_today       BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'day_is_holiday';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_holiday_today (p_hol_cal_id, p_day);
      FETCH csr_holiday_today INTO l_rec_holiday_today;

      IF csr_holiday_today%FOUND
      THEN
         if g_debug then
		 hr_utility.set_location (   '   '
					  || p_day
					  || ' is a holiday', 20);
         end if;
         l_holiday_today := TRUE;
      ELSE
         l_holiday_today := FALSE;
      END IF;

      CLOSE csr_holiday_today;
      if g_debug then
 	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_holiday_today;
   END day_is_holiday;

   FUNCTION timecard_approved (
      p_tim_id        IN   hxt_holiday_calendars.id%TYPE,
      p_approver_id   IN   hxt_timecards_f.approv_person_id%TYPE,
      p_source_flag   IN   hxt_timecards_f.auto_gen_flag%TYPE
   )
      RETURN BOOLEAN
   IS
      l_proc    VARCHAR2 (72) ;
      l_approved        BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'timecard_approved';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (NVL (p_source_flag, 'NOT S') = 'S')
      THEN
         if g_debug then
		 hr_utility.set_location (   '   '
					  || p_tim_id
					  || ' is approved', 20);
         end if;
         l_approved := TRUE;
      ELSE
         IF (p_approver_id IS NOT NULL)
         THEN
            if g_debug then
		    hr_utility.set_location (   '   '
					     || p_tim_id
					     || ' is approved', 30);
            end if;
            l_approved := TRUE;
         ELSE
            l_approved := FALSE;
         END IF;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
      RETURN l_approved;
   END timecard_approved;

   PROCEDURE tcard_approved (
      p_batch_id      IN   NUMBER,
      p_person_id     IN   hxt_timecards.for_person_id%TYPE,
      p_period_id     IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id        IN   hxt_timecards.id%TYPE,
      p_approver_id   IN   hxt_timecards_f.approv_person_id%TYPE,
      p_source_flag   IN   hxt_timecards_f.auto_gen_flag%TYPE
   )
   IS
      l_proc        VARCHAR2 (72) ;
      l_accrual_plan_name   pay_accrual_plans.accrual_plan_name%TYPE;
      l_charged_hrs         NUMBER;
      l_accrued_hrs         NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'tcard_approved';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF NOT (timecard_approved (
                 p_tim_id=> p_tim_id,
                 p_approver_id=> p_approver_id,
                 p_source_flag=> p_source_flag
              )
             )
      THEN


      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39337_timecard_not_apprved,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);

     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('PERIOD_END_DATE',period_end_date(p_period_id));
     FND_MESSAGE.set_token('TIMECARD_ID',p_tim_id);
     FND_MESSAGE.set_token('NAME',person_name(p_person_id));
     g_errtab(c_39337_timecard_not_apprved).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39337_timecard_not_apprved).errtype := g_lookup_desc;


         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39337_timecard_not_apprved
         );
      g_errtab.DELETE(   c_39337_timecard_not_apprved);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END tcard_approved;

   FUNCTION legislation_code (
      p_bg_id   IN   per_business_groups.business_group_id%TYPE
   )
      RETURN VARCHAR2 -- per_business_groups.legislation_code%TYPE
   IS
      l_proc       VARCHAR2 (72) ;

      CURSOR csr_legislation_code (
         p_bg_id   IN   hr_all_organization_units.business_group_id%TYPE
      )
      IS
         SELECT pbg.legislation_code
           FROM per_business_groups pbg
          WHERE pbg.business_group_id = p_bg_id;

      l_legislation_code   per_business_groups.legislation_code%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'legislation_code';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_legislation_code (p_bg_id);
      FETCH csr_legislation_code INTO l_legislation_code;
      CLOSE csr_legislation_code;
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_legislation_code, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_legislation_code;
   END legislation_code;

   FUNCTION legislation_code (
      p_asg_id           IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN per_business_groups.legislation_code%TYPE
   IS
      l_proc        VARCHAR2 (72) ;

      CURSOR csr_business_group (
         p_asg_id           per_all_assignments_f.assignment_id%TYPE,
         p_effective_date   DATE
      )
      IS
         SELECT paf.business_group_id
           FROM per_assignments_f paf
          WHERE paf.assignment_id = p_asg_id
            AND p_effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date;

      l_business_group_id   per_assignments_f.business_group_id%TYPE;
      l_legislation_code    per_business_groups.legislation_code%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'legislation_code';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_business_group (p_asg_id, p_effective_date);
      FETCH csr_business_group INTO l_business_group_id;
      CLOSE csr_business_group;
      l_legislation_code := legislation_code (p_bg_id => l_business_group_id);
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || l_legislation_code, 20);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_legislation_code;
   END legislation_code;

   FUNCTION assignment_is_active (
      p_asg_id           IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date   IN   DATE
   )
      RETURN BOOLEAN
   IS
      l_proc            VARCHAR2 (72)  ;

      CURSOR csr_active_assignment (
         p_asg_id           IN   per_all_assignments_f.assignment_id%TYPE,
         p_effective_date        DATE
      )
      IS
SELECT /*+ ORDERED
           INDEX(paf PER_ASSIGNMENTS_F_PK)
           INDEX(past PER_ASSIGNMENT_STATUS_TYPE_PK) */
       /* Hints supplied to always force the correct execution plan */
       1
FROM
       per_assignments_f paf,
       per_assignment_status_types past
WHERE
       paf.assignment_id = p_asg_id AND
       p_effective_date BETWEEN
       paf.effective_start_date AND paf.effective_end_date
AND
       past.assignment_status_type_id = paf.assignment_status_type_id AND
       ( past.business_group_id = paf.business_group_id OR
         past.business_group_id IS NULL) AND
       ( past.legislation_code IS NULL OR
         past.legislation_code = hxt_batch_val.legislation_code(paf.business_group_id)) AND
       past.per_system_status = 'ACTIVE_ASSIGN';

      l_rec_active_assignment   csr_active_assignment%ROWTYPE;
      l_active_assignment       BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'assignment_is_active';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_active_assignment (p_asg_id, p_effective_date);
      FETCH csr_active_assignment INTO l_rec_active_assignment;

      IF csr_active_assignment%FOUND
      THEN
         if g_debug then
		 hr_utility.set_location (
		       '   assignment '
		    || p_asg_id
		    || ' is active on '
		    || p_effective_date,
		    20
		 );
         end if;
        l_active_assignment := TRUE;
      ELSE
         l_active_assignment := FALSE;
      END IF;

      CLOSE csr_active_assignment;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_active_assignment;
   END assignment_is_active;

   PROCEDURE inactive_emp_tcard (
      p_batch_id        IN   NUMBER,
      p_person_id       IN   hxt_timecards.for_person_id%TYPE,
      p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
      p_period_id       IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id          IN   hxt_timecards.id%TYPE,
      p_day             IN   DATE
   )
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'inactive_emp_tcard';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF NOT (assignment_is_active (
                 p_asg_id=> p_assignment_id,
                 p_effective_date=> p_day
              )
             )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39317_empl_inactive,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);


     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('PERIOD_END_DATE',period_end_date(p_period_id));
     FND_MESSAGE.set_token('TIMECARD_ID',p_tim_id);
     FND_MESSAGE.set_token('NAME',person_name(p_person_id));
     g_errtab(c_39317_empl_inactive).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39317_empl_inactive).errtype := g_lookup_desc;



         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39317_empl_inactive
         );
         g_errtab.DELETE(c_39317_empl_inactive);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END inactive_emp_tcard;

   PROCEDURE get_holiday_info (
      p_day                   IN              DATE,
      p_hol_cal_id            IN              hxt_holiday_calendars.id%TYPE,
      p_hol_hours             OUT NOCOPY      hxt_holiday_days.hours%TYPE,
      p_hol_element_type_id   OUT NOCOPY      hxt_holiday_calendars.element_type_id%TYPE
   )
   IS
      l_proc    VARCHAR2 (72) :=    g_package
                                         || 'get_holiday_info';

      CURSOR csr_holiday_info (
         p_hol_cal_id   hxt_holiday_calendars.id%TYPE,
         p_day          DATE
      )
      IS
         SELECT hhd.hours, hhc.element_type_id
           FROM hxt_holiday_days hhd, hxt_holiday_calendars hhc
          WHERE hhd.holiday_date = p_day
            AND hhc.id = p_hol_cal_id
            AND hhd.hcl_id = hhc.id;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   p_hol_cal_id = '
				       || p_hol_cal_id, 20);
	      hr_utility.set_location (   '   p_day = '
				       || p_day, 30);
      end if;
      OPEN csr_holiday_info (p_hol_cal_id, p_day);
      FETCH csr_holiday_info INTO p_hol_hours, p_hol_element_type_id;
      CLOSE csr_holiday_info;
      if g_debug then
	      hr_utility.set_location (
		    '   Found p_hol_hours = '
		 || p_hol_hours,
		 40
	      );
	      hr_utility.set_location (
		    '         p_hol_element_type_id = '
		 || p_hol_element_type_id,
		 50
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END get_holiday_info;

   PROCEDURE get_holiday_info (
      p_person_id             IN              per_people_f.person_id%TYPE,
      p_day                   IN              DATE,
      p_effective_date        IN              DATE,
      p_hol_hours             OUT NOCOPY      hxt_holiday_days.hours%TYPE,
      p_hol_element_type_id   OUT NOCOPY      hxt_holiday_calendars.element_type_id%TYPE
   )
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                               || 'get_holiday_info';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      get_holiday_info (
         p_day => p_day,
         p_hol_cal_id=> holiday_calendar_id (
                     p_person_id=> p_person_id,
                     p_effective_date=> p_effective_date
                  ),
         p_hol_hours=> p_hol_hours,
         p_hol_element_type_id=> p_hol_element_type_id
      );
      if g_debug then
 	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
   END get_holiday_info;

   FUNCTION sum_unexploded_hours (
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   hxt_det_hours_worked_f.date_worked%TYPE,
      p_hours_type   IN   hxt_det_hours_worked_f.hours%TYPE DEFAULT NULL
   )
      RETURN NUMBER
   AS
      l_proc    VARCHAR2 (72) ;

      -- Sum the hours of one day
      --    .If an hours type is passed in we only sum those hours
      --    .If no hours type is passed in we sum all hours, with our without
      --     hours override
      CURSOR csr_sum_hours (
         p_tim_id       IN   hxt_timecards.id%TYPE,
         p_day               hxt_det_hours_worked_f.date_worked%TYPE,
         p_hours_type        hxt_det_hours_worked_f.hours%TYPE
      )
      IS
         SELECT SUM (hshwx.hours)
           FROM hxt_sum_hours_worked_x hshwx
          WHERE hshwx.tim_id = p_tim_id
            AND hshwx.date_worked = p_day
            AND (   (p_hours_type IS NULL)
                 OR (    (p_hours_type IS NOT NULL)
                     AND (p_hours_type = hshwx.element_type_id)
                    )
                );

      l_sum_hours       NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'sum_unexploded_hours';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      OPEN csr_sum_hours (p_tim_id, p_day, p_hours_type);
      FETCH csr_sum_hours INTO l_sum_hours;
      CLOSE csr_sum_hours;
      if g_debug then
	      hr_utility.set_location (   '   returning '
				       || NVL (l_sum_hours, 0), 30);
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
      RETURN NVL (l_sum_hours, 0);
   END sum_unexploded_hours;

   PROCEDURE holiday_mismatch (
      p_batch_id     IN   NUMBER,
      p_person_id    IN   hxt_timecards.for_person_id%TYPE,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   DATE,
      p_hours_type   IN   hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
   )
   IS
      l_proc    VARCHAR2 (72)  ;
      l_hol_hours       hxt_holiday_days.hours%TYPE;
      l_hol_element     hxt_holiday_calendars.element_type_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'holiday_mismatch';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      get_holiday_info (
         p_day => p_day,
         p_hol_cal_id=> p_hol_cal_id,
         p_hol_hours=> l_hol_hours,
         p_hol_element_type_id=> l_hol_element
      );

      IF (    (l_hol_hours <>
                     sum_unexploded_hours (
                        p_tim_id=> p_tim_id,
                        p_day => p_day,
                        p_hours_type=> l_hol_element
                     )
              )
          AND (NVL (p_hours_type, -1) = l_hol_element)
         )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39334_hrs_chged_ne_cal_hrs,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);

     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;


     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('DATE_WORKED',to_char(p_day,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
     FND_MESSAGE.set_token('CAL_HRS',l_hol_hours);
     g_errtab(c_39334_hrs_chged_ne_cal_hrs).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39334_hrs_chged_ne_cal_hrs).errtype := g_lookup_desc;



         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39334_hrs_chged_ne_cal_hrs
         );

      g_errtab.DELETE(c_39334_hrs_chged_ne_cal_hrs);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END holiday_mismatch;

   PROCEDURE holiday_valid (
      p_batch_id     IN   NUMBER,
      p_person_id    IN   hxt_timecards.for_person_id%TYPE,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   DATE,
      p_hours_type   IN   hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
   )
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'holiday_valid';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF      (NVL (p_hours_type, -1) =
                            holiday_element_id (p_hol_cal_id => p_hol_cal_id)
              )
          AND NOT (day_is_holiday (
                      p_day => p_day,
                      p_hol_cal_id=> p_hol_cal_id
                   )
                  )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39333_hol_not_valid_on_cal,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);


     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('DATE_WORKED',to_char(p_day,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
     FND_MESSAGE.set_token('HOLIDAY_CAL',holiday_calendar_name(p_hol_cal_id));
     FND_MESSAGE.set_token('ASSIGN',assignment(p_person_id));
     g_errtab(c_39333_hol_not_valid_on_cal).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39333_hol_not_valid_on_cal).errtype := g_lookup_desc;


         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39333_hol_not_valid_on_cal
         );
         g_errtab.DELETE(c_39333_hol_not_valid_on_cal);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 20);
      end if;
   END holiday_valid;

   FUNCTION element_link (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_assignment_id     IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date    IN   DATE
   )
      RETURN pay_element_links_f.element_link_id%TYPE
   IS
      l_proc      VARCHAR2 (72) ;
      l_element_link_id   NUMBER;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'element_link';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      BEGIN
         SELECT el.element_link_id
           INTO l_element_link_id
           FROM per_assignments_f asg, pay_element_links_f el
          WHERE asg.assignment_id = p_assignment_id
            AND   el.business_group_id
                + 0 =   asg.business_group_id
                      + 0
            AND el.element_type_id = p_element_type_id
            AND p_effective_date BETWEEN asg.effective_start_date
                                     AND asg.effective_end_date
            AND p_effective_date BETWEEN el.effective_start_date
                                     AND el.effective_end_date
            AND (   (    el.payroll_id IS NOT NULL
                     AND el.payroll_id = asg.payroll_id
                    )
                 OR (    el.link_to_all_payrolls_flag = 'Y'
                     AND asg.payroll_id IS NOT NULL
                    )
                 OR (    el.payroll_id IS NULL
                     AND el.link_to_all_payrolls_flag = 'N'
                    )
                )
            AND (   el.job_id IS NULL
                 OR el.job_id = asg.job_id
                )
            AND (   el.grade_id IS NULL
                 OR el.grade_id = asg.grade_id
                )
            AND (   el.position_id IS NULL
                 OR el.position_id = asg.position_id
                )
            AND (   el.organization_id IS NULL
                 OR el.organization_id = asg.organization_id
                )
            AND (   el.location_id IS NULL
                 OR el.location_id = asg.location_id
                )
            AND (   el.pay_basis_id IS NULL
                 OR el.pay_basis_id = asg.pay_basis_id
                )
            AND (   el.employment_category IS NULL
                 OR el.employment_category = asg.employment_category
                )
            AND (   el.people_group_id IS NULL
                 OR EXISTS (
                          SELECT NULL
                            FROM pay_assignment_link_usages_f alu
                           WHERE alu.assignment_id = asg.assignment_id
                             AND alu.element_link_id = el.element_link_id
                             AND p_effective_date
                                    BETWEEN alu.effective_start_date
                                        AND alu.effective_end_date)
                );

         if g_debug then
		 hr_utility.set_location (   'Leaving:'
					  || l_proc, 20);
         end if;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_element_link_id := NULL;
      END;

      if g_debug then
	      hr_utility.set_location (
		    '   returning l_element_link_id = '
		 || l_element_link_id,
		 20
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_element_link_id;
   END element_link;

   FUNCTION element_linked (
      p_element_type_id   IN   pay_element_types_f.element_type_id%TYPE,
      p_assignment_id     IN   per_all_assignments_f.assignment_id%TYPE,
      p_effective_date    IN   DATE
   )
      RETURN BOOLEAN
   IS
      l_proc      VARCHAR2 (72);
      l_element_linked    BOOLEAN;
      l_element_link_id   pay_element_links_f.element_link_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'element_linked';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_element_link_id :=
            element_link (
               p_element_type_id=> p_element_type_id,
               p_assignment_id=> p_assignment_id,
               p_effective_date=> p_effective_date
            );

      IF (l_element_link_id IS NOT NULL)
      THEN
         if g_debug then
		 hr_utility.set_location (
		       '   '
		    || p_element_type_id
		    || ' is a valid element for asg '
		    || p_assignment_id
		    || ' on '
		    || p_effective_date,
		    20
		 );
         end if;
         l_element_linked := TRUE;
      ELSE
         l_element_linked := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_element_linked;
   END element_linked;

   FUNCTION valid_for_summing (
      p_element_id          IN   pay_element_types_f.element_type_id%TYPE,
      p_earnings_category   IN   hxt_add_elem_info_f.earning_category%TYPE,
      p_day                 IN   DATE,
      p_assignment_id       IN   per_all_assignments_f.assignment_id%TYPE,
      p_hol_cal_id          IN   hxt_holiday_calendars.id%TYPE,
      p_valid_earn_cat1     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat2     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat3     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat4     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat5     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat6     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL,
      p_valid_earn_cat7     IN   hxt_add_elem_info_f.earning_category%TYPE
            DEFAULT NULL
   )
      RETURN BOOLEAN
   IS
      l_proc        VARCHAR2 (72) ;
      l_valid_for_summing   BOOLEAN;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'valid_for_summing';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (    (element_linked (
                  p_element_type_id=> p_element_id,
                  p_assignment_id=> p_assignment_id,
                  p_effective_date=> p_day
               )
              )
          AND (p_element_id <>
                   NVL (holiday_element_id (p_hol_cal_id => p_hol_cal_id), -1)
              )
          AND (p_earnings_category IN (p_valid_earn_cat1,
                                       p_valid_earn_cat2,
                                       p_valid_earn_cat3,
                                       p_valid_earn_cat4,
                                       p_valid_earn_cat5,
                                       p_valid_earn_cat6,
                                       p_valid_earn_cat7
                                      )
              )
         )
      THEN
         if g_debug then
		 hr_utility.set_location (
		       '   element '
		    || p_element_id
		    || ' is valid for summing',
		    20
		 );
         end if;
         l_valid_for_summing := TRUE;
      ELSE
         l_valid_for_summing := FALSE;
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN l_valid_for_summing;
   END valid_for_summing;

   FUNCTION sum_valid_det_hours (
      p_tim_id          IN   hxt_timecards.id%TYPE,
      p_day             IN   DATE,
      p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
      p_hol_cal_id      IN   hxt_holiday_calendars.id%TYPE
   )
      RETURN NUMBER
   IS
      l_proc    VARCHAR2 (72) ;

      CURSOR csr_det_hours (
         p_tim_id        hxt_timecards.id%TYPE,
         p_date_worked   hxt_det_hours_worked_f.date_worked%TYPE
      )
      IS
         SELECT   SUM (hdhwx.hours) hours, hdhwx.element_type_id,
                  haeif.earning_category
             FROM hxt_det_hours_worked_x hdhwx, hxt_add_elem_info_f haeif
            WHERE hdhwx.tim_id = p_tim_id
              AND hdhwx.date_worked = p_date_worked
              AND hdhwx.element_type_id = haeif.element_type_id
              AND hdhwx.date_worked BETWEEN haeif.effective_start_date
                                        AND haeif.effective_end_date
         GROUP BY hdhwx.date_worked,
                  hdhwx.element_type_id,
                  haeif.earning_category;

      l_summed_hours    NUMBER        := 0;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'sum_valid_det_hours';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      FOR rec_det_hours IN csr_det_hours (p_tim_id, p_day)
      LOOP
         IF (valid_for_summing (
                p_element_id=> rec_det_hours.element_type_id,
                p_earnings_category=> rec_det_hours.earning_category,
                p_assignment_id=> p_assignment_id,
                p_day => p_day,
                p_hol_cal_id=> p_hol_cal_id,
                p_valid_earn_cat1=> 'REG',
                p_valid_earn_cat2=> 'OVT',
                p_valid_earn_cat3=> 'ABS'
             )
            )
         THEN
            l_summed_hours :=   l_summed_hours
                              + rec_det_hours.hours;
         END IF;
      END LOOP;
      if g_debug then
	      hr_utility.set_location (
		    '   returning l_summed_hours = '
		 || l_summed_hours,
		 20
	      );
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 30);
      end if;
      RETURN NVL (l_summed_hours, 0);
   END sum_valid_det_hours;

   PROCEDURE day_over_24 (
      p_batch_id        IN   NUMBER,
      p_person_id       IN   hxt_timecards.for_person_id%TYPE,
      p_assignment_id   IN   per_all_assignments_f.assignment_id%TYPE,
      p_period_id       IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id          IN   hxt_timecards.id%TYPE,
      p_day             IN   DATE,
      p_hol_cal_id      IN   hxt_holiday_calendars.id%TYPE
   )
   IS
      l_proc    VARCHAR2 (72) ;
      l_hol_hours       hxt_holiday_days.hours%TYPE;
      l_hol_element     hxt_holiday_calendars.element_type_id%TYPE;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'day_over_24';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      IF (sum_valid_det_hours (
             p_tim_id=> p_tim_id,
             p_day => p_day,
             p_assignment_id=> p_assignment_id,
             p_hol_cal_id=> p_hol_cal_id
          ) > 24
         )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39315_max_hrs_exceeded,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);

     IF ( g_lookup_error = 'XXX' )
     THEN
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
         fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
         fnd_message.raise_error;
     END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('DATE_WORKED',to_char(p_day,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
     FND_MESSAGE.set_token('NAME',person_name(p_person_id));
     g_errtab(c_39315_max_hrs_exceeded).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39315_max_hrs_exceeded).errtype := g_lookup_desc;


         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39315_max_hrs_exceeded
         );
        g_errtab.DELETE(c_39315_max_hrs_exceeded);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END day_over_24;

   PROCEDURE holiday_as_reg (
      p_batch_id     IN   NUMBER,
      p_person_id    IN   hxt_timecards.for_person_id%TYPE,
      p_period_id    IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN   hxt_timecards.id%TYPE,
      p_day          IN   DATE,
      p_hours_type   IN   hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   IN   hxt_holiday_calendars.id%TYPE
   )
   IS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
 	      l_proc :=    g_package
                              || 'holiday_as_reg';
 	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
	      hr_utility.set_location (   '   p_hours_type = '
				       || p_hours_type, 20);
      end if;
      IF (    (day_is_holiday (p_day => p_day, p_hol_cal_id => p_hol_cal_id))
          AND (NVL (p_hours_type, -1) <>
                            holiday_element_id (p_hol_cal_id => p_hol_cal_id)
              )
         )
      THEN

      -- Bug 8584436
      -- Picking and processing the message with tokens before recording
      -- into hxt_errors_f.

      hxt_util.get_quick_codes(c_39332_day_on_hol_cal,
                       'HXT_TIMECARD_VALIDATION',
                       808,
                       g_lookup_error,
                       g_lookup_desc);

      IF ( g_lookup_error = 'XXX' )
      THEN
          fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
          fnd_message.set_token('PROCEDURE', 'HXTBTVAL');
          fnd_message.set_token('STEP','Invalid HXT_TIMECARD_VALIDATION-'||g_lookup_error);
          fnd_message.raise_error;
      END IF;

     FND_MESSAGE.SET_NAME('HXT',g_lookup_error);
     FND_MESSAGE.set_token('DATE_WORKED',to_char(p_day,fnd_profile.value('ICX_DATE_FORMAT_MASK')));
     FND_MESSAGE.set_token('HOLIDAY_CAL',holiday_calendar_name(p_hol_cal_id));
     FND_MESSAGE.set_token('ASSIGN',assignment(p_person_id));
     g_errtab(c_39332_day_on_hol_cal).errmsg := FND_MESSAGE.GET;
     g_errtab(c_39332_day_on_hol_cal).errtype := g_lookup_desc;


         record_error (
            p_batch_id=> p_batch_id,
            p_tim_id=> p_tim_id,
            p_period_id=> p_period_id,
            p_error_code=> c_39332_day_on_hol_cal
         );
        g_errtab.DELETE(c_39332_day_on_hol_cal);
      END IF;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END holiday_as_reg;

   PROCEDURE perform_holiday_validations (
      p_batch_id     IN              NUMBER,
      p_person_id    IN              hxt_timecards.for_person_id%TYPE,
      p_period_id    IN              hxt_timecards.time_period_id%TYPE,
      p_tim_id       IN              hxt_timecards.id%TYPE,
      p_day          IN              DATE,
      p_hours_type   IN              hxt_sum_hours_worked_f.element_type_id%TYPE,
      p_hol_cal_id   OUT NOCOPY      hxt_holiday_calendars.id%TYPE
   )
   AS
      l_proc    VARCHAR2 (72);

      l_hol_cal_id      hxt_holiday_calendars.id%TYPE;
   BEGIN

      if g_debug then
	      l_proc :=    g_package
                            || 'perform_holiday_validations';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      l_hol_cal_id := holiday_calendar_id (
                         p_person_id=> p_person_id,
                         p_effective_date=> p_day
                      );
      holiday_mismatch (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id,
         p_day => p_day,
         p_hours_type=> p_hours_type,
         p_hol_cal_id=> l_hol_cal_id
      );
      holiday_valid (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id,
         p_day => p_day,
         p_hours_type=> p_hours_type,
         p_hol_cal_id=> l_hol_cal_id
      );
      holiday_as_reg (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id,
         p_day => p_day,
         p_hours_type=> p_hours_type,
         p_hol_cal_id=> l_hol_cal_id
      );
      p_hol_cal_id := l_hol_cal_id;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END perform_holiday_validations;

   PROCEDURE perform_day_validations (
      p_batch_id    IN   NUMBER,
      p_person_id   IN   hxt_timecards.for_person_id%TYPE,
      p_period_id   IN   hxt_timecards.time_period_id%TYPE,
      p_tim_id      IN   hxt_timecards.id%TYPE
   )
   AS
      l_proc    VARCHAR2 (72) ;

      CURSOR csr_days (p_tim_id hxt_timecards.id%TYPE)
      IS
         SELECT DISTINCT hshwx.date_worked, hshwx.element_type_id,
                         hshwx.assignment_id
                    FROM hxt_sum_hours_worked_x hshwx
                   WHERE tim_id = p_tim_id
                     AND hshwx.effective_end_date = hr_general.end_of_time;

      CURSOR c_no_mid_period_change (p_person_id in number)
      is
      select 'Y'
      from per_all_assignments_f p1,
      hxt_timecards_x tim
      where tim.effective_start_date between p1.effective_start_date and p1.effective_end_date
      and tim.effective_end_date between p1.effective_start_date and p1.effective_end_date
      and p1.person_id = p_person_id
      and p1.primary_flag = 'Y'
      and tim.id = p_tim_id;


      l_hol_cal_id      hxt_holiday_calendars.id%TYPE;
      l_no_mid_period_change varchar2(1);

   BEGIN

      if g_debug then
	      l_proc :=    g_package
                              || 'perform_day_validations';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;

      open c_no_mid_period_change(p_person_id );
      fetch c_no_mid_period_change into l_no_mid_period_change;

      if c_no_mid_period_change%notfound then
      	l_no_mid_period_change := 'N';
      end if;

      close c_no_mid_period_change;

      if g_debug then
      	      hr_utility.trace ('l_no_mid_period_change - '||l_no_mid_period_change);
      end if;

      FOR rec_days IN csr_days (p_tim_id)
      LOOP
         perform_holiday_validations (
            p_batch_id=> p_batch_id,
            p_person_id=> p_person_id,
            p_period_id=> p_period_id,
            p_tim_id=> p_tim_id,
            p_day => rec_days.date_worked,
            p_hours_type=> rec_days.element_type_id,
            p_hol_cal_id=> l_hol_cal_id
         );
         inactive_emp_tcard (
            p_batch_id=> p_batch_id,
            p_person_id=> p_person_id,
            p_assignment_id=> rec_days.assignment_id,
            p_period_id=> p_period_id,
            p_tim_id=> p_tim_id,
            p_day => rec_days.date_worked
         );
         day_over_24 (
            p_batch_id=> p_batch_id,
            p_person_id=> p_person_id,
            p_assignment_id=> rec_days.assignment_id,
            p_period_id=> p_period_id,
            p_tim_id=> p_tim_id,
            p_day => rec_days.date_worked,
            p_hol_cal_id=> l_hol_cal_id
         );

         if l_no_mid_period_change = 'N' then
         excess_pto (
            p_batch_id=> p_batch_id,
            p_calculation_date=>rec_days.date_worked,
            p_person_id=> p_person_id,
            p_period_id=> p_period_id,
            p_tim_id=> p_tim_id
         );
         end if;
      END LOOP;

       if l_no_mid_period_change = 'Y' then
	excess_pto (
	         p_batch_id=> p_batch_id,
	         p_calculation_date=> timecard_end_date (p_tim_id => p_tim_id),
	         p_person_id=> p_person_id,
	         p_period_id=> p_period_id,
	         p_tim_id=> p_tim_id
      		   );
       end if;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END perform_day_validations;

   PROCEDURE validate_tc (
      p_batch_id           IN              NUMBER,
      p_tim_id             IN              hxt_timecards.id%TYPE,
      p_person_id          IN              hxt_timecards.for_person_id%TYPE,
      p_period_id          IN              hxt_timecards.time_period_id%TYPE,
      p_approv_person_id   IN              hxt_timecards.approv_person_id%TYPE,
      p_auto_gen_flag      IN              hxt_timecards.auto_gen_flag%TYPE,
      p_error_level        IN OUT NOCOPY   NUMBER
   )
   AS
      l_proc    VARCHAR2 (72) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                             || 'validate_tc';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;


      -- Bug 6785744
      -- Process started its run on g_start_sysdate.
      -- If the current sysdate is not equal to the start date
      -- ie. in case the process ran thru a midnight, update the date
      -- and reassign g_start_sysdate.

      IF g_start_sysdate <> TRUNC(SYSDATE)
      THEN
           hr_session_utilities.insert_session_row (SYSDATE);
           g_start_sysdate := TRUNC(SYSDATE);
      END IF;

      perform_day_validations (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id
      );

      -- Bug 6785744
      -- No need to remove the session row after each timecard.
      -- hr_session_utilities.remove_session_row; /* Bug 6024976 */

/* M.Bhammar - bug 5214727
      excess_pto (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id
      );
*/
      tcard_approved (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id,
         p_approver_id=> p_approv_person_id,
         p_source_flag=> p_auto_gen_flag
      );
      person_validation (
         p_batch_id=> p_batch_id,
         p_person_id=> p_person_id,
         p_period_id=> p_period_id,
         p_tim_id=> p_tim_id
      );
      p_error_level := error_level;
      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END validate_tc;

   PROCEDURE val_batch (
      p_batch_id         IN              NUMBER,
      p_time_period_id   IN              NUMBER,
      p_valid_retcode    IN OUT NOCOPY   NUMBER,
      p_merge_flag	 IN		 VARCHAR2 DEFAULT '0',
      p_merge_batches    OUT NOCOPY      HXT_BATCH_PROCESS.MERGE_BATCHES_TYPE_TABLE
   )
   IS
      l_proc    VARCHAR2 (72)  ;
      l_msg_level       VARCHAR2 (1)   := 'E';
      l_valid           VARCHAR2 (1)   := 'Y';
      l_ret             NUMBER;
      l_msg             VARCHAR2 (240);
      l_loc             VARCHAR2 (70);
      l_sql_error       VARCHAR2 (80);
      l_id              NUMBER;
      l_cnt             BINARY_INTEGER;

      CURSOR csr_tcs_in_batch (p_batch_id hxt_timecards_f.batch_id%TYPE)
      IS
         SELECT tim.id tim_id, tim.for_person_id, tim.time_period_id,
                tim.approv_person_id, tim.auto_gen_flag,
		tim.approved_timestamp   , tim.created_by,
		tim.creation_date        , tim.last_updated_by,
		tim.last_update_date     , tim.last_update_login,
		tim.payroll_id           , tim.status,
		tim.effective_start_date , tim.effective_end_date,
		tim.object_version_number, tim.rowid
           FROM hxt_timecards_x tim
          WHERE tim.batch_id = p_batch_id;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc :=    g_package
                              || 'val_batch';
	      hr_utility.set_location (   'Entering:'
				       || l_proc, 10);
      end if;
      reset_error_level;
      delete_prev_val_errors (p_batch_id => p_batch_id);

      -- Bug 6785744
      -- Insert a new row in fnd_sessions before processing this batch.

      hr_session_utilities.insert_session_row (SYSDATE);
      <<process_all_tcs_in_batch>>
      FOR rec_tcs_in_batch IN csr_tcs_in_batch (p_batch_id)
      LOOP
	 set_tc_error_level(p_tc_error_level => 0);

         /********Bug: 5037996 **********/

        -- IF p_merge_flag = 'Y' THEN  /* commented for bug: 5112412 */
            delete_prev_val_errors (p_tim_id => rec_tcs_in_batch.tim_id);
	-- END IF;

	 /********Bug: 5037996 **********/

         if g_debug then
		 hr_utility.set_location (
		       '   process timecard '
		    || rec_tcs_in_batch.tim_id,
		    20
		 );
		 hr_utility.set_location (
		       '   Error Level at start = '
		    || error_level,
		    30
		 );
         end if;
         IF (errors_exist (p_tim_id => rec_tcs_in_batch.tim_id))
         THEN
            p_valid_retcode := 2;
         ELSE
            validate_tc (
               p_batch_id=> p_batch_id,
               p_tim_id=> rec_tcs_in_batch.tim_id,
               p_person_id=> rec_tcs_in_batch.for_person_id,
               p_period_id=> rec_tcs_in_batch.time_period_id,
               p_approv_person_id=> rec_tcs_in_batch.approv_person_id,
               p_auto_gen_flag=> rec_tcs_in_batch.auto_gen_flag,
               p_error_level=> p_valid_retcode
            );
         END IF;

         -- Bug 6795140

         COMMIT;

	 /********Bug: 5037996 **********/
	 /*** To record the validated timecards details ***/

	 IF p_merge_flag = '1' THEN

	    if g_debug then
		hr_utility.trace('Populating merge_batches record'||
			             ' batch_id: '||p_batch_id||' tc_id '||rec_tcs_in_batch.tim_id);
            end if;

	    l_cnt := NVL(p_merge_batches.LAST,0) +1;
	    p_merge_batches(l_cnt).batch_id		 := p_batch_id;
	    p_merge_batches(l_cnt).tc_id		 := rec_tcs_in_batch.tim_id;
	    p_merge_batches(l_cnt).valid_tc_retcode	 := tc_error_level;
	    p_merge_batches(l_cnt).tc_rowid		 := rec_tcs_in_batch.rowid;
	    p_merge_batches(l_cnt).for_person_id	 := rec_tcs_in_batch.for_person_id;
	    p_merge_batches(l_cnt).time_period_id	 := rec_tcs_in_batch.time_period_id;
	    p_merge_batches(l_cnt).auto_gen_flag	 := rec_tcs_in_batch.auto_gen_flag;
	    p_merge_batches(l_cnt).approv_person_id	 := rec_tcs_in_batch.approv_person_id;
	    p_merge_batches(l_cnt).approved_timestamp	 := rec_tcs_in_batch.approved_timestamp;
	    p_merge_batches(l_cnt).created_by		 := rec_tcs_in_batch.created_by;
	    p_merge_batches(l_cnt).creation_date	 := rec_tcs_in_batch.creation_date;
	    p_merge_batches(l_cnt).last_updated_by	 := rec_tcs_in_batch.last_updated_by;
	    p_merge_batches(l_cnt).last_update_date	 := rec_tcs_in_batch.last_update_date;
	    p_merge_batches(l_cnt).last_update_login	 := rec_tcs_in_batch.last_update_login;
	    p_merge_batches(l_cnt).payroll_id		 := rec_tcs_in_batch.payroll_id;
	    p_merge_batches(l_cnt).status		 := rec_tcs_in_batch.status;
	    p_merge_batches(l_cnt).effective_start_date	 := rec_tcs_in_batch.effective_start_date;
	    p_merge_batches(l_cnt).effective_end_date	 := rec_tcs_in_batch.effective_end_date;
	    p_merge_batches(l_cnt).object_version_number := rec_tcs_in_batch.object_version_number;

	 END IF;

	 /********Bug: 5037996 **********/

      END LOOP process_all_tcs_in_batch;

      -- Bug 6785744
      -- Remove the session row after processing this batch.

      hr_session_utilities.remove_session_row;

      if g_debug then
	      hr_utility.set_location (   'Leaving:'
				       || l_proc, 100);
      end if;
   END val_batch;


   -- Bug 8584436
   -- Added the following functions to return appropriate values for the
   -- tokens.

   FUNCTION person_name ( p_person_id  IN NUMBER)
   RETURN VARCHAR2
   IS

   BEGIN
       IF g_name_tab.EXISTS(p_person_id)
       THEN
          RETURN g_name_tab(p_person_id);
       ELSE
          SELECT full_name
            INTO g_name_tab(p_person_id)
            FROM per_all_people_f
           WHERE person_id = p_person_id
             AND SYSDATE BETWEEN effective_start_date
                             AND effective_end_date;
            RETURN g_name_tab(p_person_id);
       END IF;
   END person_name;


   FUNCTION holiday_calendar_name ( p_hcl_id   IN NUMBER)
   RETURN VARCHAR2
   IS

   BEGIN
       IF g_holiday_calendar.EXISTS(p_hcl_id)
       THEN
          RETURN g_holiday_calendar(p_hcl_id);
       ELSE
          SELECT name
            INTO g_holiday_calendar(p_hcl_id)
            FROM hxt_holiday_calendars
           WHERE id = p_hcl_id ;
            RETURN g_holiday_calendar(p_hcl_id);
       END IF;
   END holiday_calendar_name;


   FUNCTION assignment ( p_person_id IN NUMBER)
   RETURN VARCHAR2
   IS

   BEGIN
       IF g_assig_tab.EXISTS(p_person_id)
       THEN
          RETURN g_assig_tab(p_person_id);
       ELSE
          SELECT employee_number
            INTO g_assig_tab(p_person_id)
            FROM per_all_people_f
           WHERE person_id = p_person_id
             AND SYSDATE BETWEEN effective_start_date
                             AND effective_end_date;
            RETURN g_assig_tab(p_person_id);
       END IF;
   END assignment;

   FUNCTION period_end_date( p_period_id  IN NUMBER)
   RETURN VARCHAR2
   IS

   BEGIN
       IF g_period_end_date.EXISTS(p_period_id)
       THEN
          RETURN g_period_end_date(p_period_id);
       ELSE
          SELECT TO_CHAR(end_date,FND_profile.value('ICX_DATE_FORMAT_MASK'))
            INTO g_period_end_date(p_period_id)
            FROM per_time_periods
          WHERE time_period_id = p_period_id;
          RETURN g_period_end_date(p_period_id);
       END IF;

   END period_end_date;



END hxt_batch_val;

/
