--------------------------------------------------------
--  DDL for Package Body HXT_TD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TD_UTIL" AS
/* $Header: hxttdutl.pkb 120.4.12010000.3 2009/02/25 15:45:34 asrajago ship $ */
g_debug boolean := hr_utility.debug_enabled;
-------------------------------------
--   PROCEDURE retro_restrict_edit --
-------------------------------------
-- The purpose of this procedure is to control the datetrack mode that can
-- be used to update a detail record.
--
-- Once data has been transferred to BEE, we should not allow DT Corrections
-- anymore. This correction would overwrite the record in the database and we
-- would not know anymore which data was transferred to BEE (and we do need to
-- know this as you will see later).  So only data that has not been transferred
-- yet to BEE can be DT CORRECTED.
--
-- Data that has been Transferred already can only be DT UPDATED. This will
-- retain the record that was transferred and create a new DT record with the
-- updated information.
--
-- The problem with datetrack however is that it does not allow DT UPDATES on
-- records that are created on the current session date.  E.g. a record that
-- was created on 01-JAN-2003 cannot be UPDATED on 01-JAN-2003 because the
-- datetrack granularity is on day level so we cannot have a DT record active
-- from 01-JAN-2003 00:01 till 01-JAN-2003 12:00 and another one from
-- 01-JAN-2003 12:01 till 31-DEC-4712. Because of this DT restriction, we cannot
-- allow ANY updates on detail records if they have been transferred already
-- and were updated today. The fact that it has already been transferred means
-- we need to do a DT UPDATE, but we can't because it was already update today.
-- This procedure will raise an error for such a situation.
--
-- The reason we need to keep records that already have been transferred to BEE
-- intact is because any update after that is send as a delta between the old
-- (already send record) and the update (new DT) record. A correction would wipe
-- out the old record and we would not be able to to a delta anymore.

-- Added for Bug 6067007
-- There was one corner scenario, when the timecard is transferred to BEE
-- and the next day a change is made to it. This time, the code allows only
-- an update. But once this is transferred to PUI, the status of the detail
-- records changes to R. ( for retro ). If you try to update again, the time
-- card will let you CORRECT the timecard ( even delete a day's entry and add
-- another entry.) Now when this data moves to BEE, it would create overpayment
-- because the day is already having an entry for a given attribute, and a newer
-- entry is brought in with retro ( this time a different attribute, so the
-- existing entry wont be reversed). This can be avoided only by switching to
-- UPDATE only allowed while doing a retro change. So after this change, any
-- timecard which has history of transfer to BEE can be updated only, no delete
-- is allowed.

   PROCEDURE retro_restrict_edit (
      p_tim_id          IN              hxt_det_hours_worked_f.tim_id%TYPE,
      p_session_date    IN              DATE,
      o_dt_update_mod   OUT NOCOPY      VARCHAR2,
      o_error_message   OUT NOCOPY      VARCHAR2,
      o_return_code     OUT NOCOPY      NUMBER,
      p_parent_id       IN              hxt_det_hours_worked_f.parent_id%TYPE
   )
   IS

      -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

      /*
      CURSOR csr_not_transferred (
         v_tim_id      hxt_det_hours_worked_f.tim_id%TYPE,
         v_parent_id   hxt_det_hours_worked_f.parent_id%TYPE
      )
      IS
         SELECT 1
           FROM hxt_det_hours_worked hdhw
          WHERE hdhw.tim_id = v_tim_id
            AND hdhw.pay_status =  'P'                      -- Bug 6067007
            AND hdhw.pa_status  =  'P'                      -- Bug 6067007
            AND NOT EXISTS ( SELECT 1
                               FROM hxt_det_hours_worked_f hdhw2
                              WHERE hdhw.tim_id = hdhw2.tim_id
                                AND hdhw2.effective_start_date >
                                                    hdhw.effective_start_date);
      */
      CURSOR csr_not_transferred (
         v_tim_id      hxt_det_hours_worked_f.tim_id%TYPE,
         v_parent_id   hxt_det_hours_worked_f.parent_id%TYPE,
         v_session_date DATE
      )
      IS
         SELECT 1
           FROM hxt_det_hours_worked_f hdhw
          WHERE hdhw.tim_id = v_tim_id
            AND v_session_date BETWEEN hdhw.effective_start_date
                                   AND hdhw.effective_end_date
            AND hdhw.pay_status =  'P'                      -- Bug 6067007
            AND hdhw.pa_status  =  'P'                      -- Bug 6067007
            AND NOT EXISTS ( SELECT 1
                               FROM hxt_det_hours_worked_f hdhw2
                              WHERE hdhw.tim_id = hdhw2.tim_id
                                AND hdhw2.effective_start_date >
                                                    hdhw.effective_start_date);



-- Bug 6067007
      CURSOR csr_transferred_retro (
         v_tim_id      hxt_det_hours_worked_f.tim_id%TYPE,
         v_parent_id   hxt_det_hours_worked_f.parent_id%TYPE
      )
      IS
         SELECT 1
           FROM hxt_det_hours_worked_f hdhw
          WHERE hdhw.tim_id = v_tim_id
            AND (   hdhw.pay_status = 'R'
                 OR hdhw.pa_status = 'R'
                );
-- Bug 6067007


      CURSOR csr_transferred (
         v_tim_id      hxt_det_hours_worked_f.tim_id%TYPE,
         v_parent_id   hxt_det_hours_worked_f.parent_id%TYPE
      )
      IS
         SELECT 1
           FROM hxt_det_hours_worked_f hdhw
          WHERE hdhw.tim_id = v_tim_id
            AND (   hdhw.pay_status = 'C'
                 OR hdhw.pa_status = 'C'
                );

      CURSOR csr_changed_today (
         v_tim_id       hxt_det_hours_worked_f.tim_id%TYPE,
         v_parent_id    hxt_det_hours_worked_f.parent_id%TYPE,
         v_session_dt   DATE
      )
      IS
         SELECT 1
           FROM hxt_det_hours_worked_f hdhw
          WHERE hdhw.tim_id = v_tim_id
           AND trunc(hdhw.effective_start_date)
	         = trunc(v_session_dt);


      l_transferred       csr_transferred%ROWTYPE       := NULL;
      l_transfered_retro  csr_transferred_retro%ROWTYPE := NULL;   -- Bug 6067007
      l_not_transferred   csr_not_transferred%ROWTYPE   := NULL;
      l_changed_today     csr_changed_today%ROWTYPE     := NULL;
      l_proc              VARCHAR2 (30) ;

      FUNCTION details (p_tim_id IN hxt_det_hours_worked_f.tim_id%TYPE,
                        p_date   IN DATE)
         RETURN BOOLEAN
      IS
         -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

         /*
         CURSOR csr_debug (v_tim_id hxt_det_hours_worked_f.tim_id%TYPE)
         IS
            SELECT hdhw.id, hdhw.parent_id, hdhw.date_worked, hdhw.pay_status,
                   hdhw.effective_start_date
              FROM hxt_det_hours_worked hdhw
             WHERE hdhw.tim_id = v_tim_id;
          */

         CURSOR csr_debug (v_tim_id hxt_det_hours_worked_f.tim_id%TYPE,
                           v_sess_date  DATE)
         IS
            SELECT hdhw.id, hdhw.parent_id, hdhw.date_worked, hdhw.pay_status,
                   hdhw.effective_start_date
              FROM hxt_det_hours_worked_f hdhw
             WHERE hdhw.tim_id = v_tim_id
               AND v_sess_date BETWEEN hdhw.effective_start_date
                                   AND hdhw.effective_end_date;


         l_details   BOOLEAN := FALSE;
      BEGIN

         FOR rec_debug IN csr_debug (p_tim_id,p_date)
         LOOP
            l_details := TRUE;
            if g_debug then

		    hr_utility.TRACE (
			  LPAD (rec_debug.id, 10)
		       || ' '
		       || LPAD (rec_debug.parent_id, 10)
		       || ' '
		       || LPAD (rec_debug.date_worked, 10)
		       || ' '
		       || LPAD (rec_debug.pay_status, 10)
		       || ' '
		       || LPAD (rec_debug.effective_start_date, 10)
		    );
	    end if;
         END LOOP;

         RETURN l_details;
      END details;
   BEGIN

         -- Bug 7359347
         -- Setting session date
         g_td_session_date := p_session_date;


      g_debug :=hr_utility.debug_enabled;
      o_return_code := 0; -- indicates all is OK
      if g_debug then
       	      l_proc := 'retro_restrict_edit';
       	      hr_utility.set_location (   'Entering '
                                       || l_proc, 10);
              hr_utility.set_location ('Parameters In: ', 20);
              hr_utility.set_location (   '   p_tim_id = '
                                       || p_tim_id, 30);
	      hr_utility.set_location (
		    '   p_session_date = '
		 || p_session_date,
		 40
	      );
              hr_utility.set_location (   '   p_parent_id = '
                                       || p_parent_id, 50);
      end if;

      -- Bug 7359347
      -- Setting session date
      -- Check this before processing further because
      -- you already have this in cache.

      IF g_rre_details_tab.EXISTS(TO_CHAR(p_tim_id))
      THEN
         o_dt_update_mod := g_rre_details_tab(TO_CHAR(p_tim_id)).upd_mode;
         o_return_code   := g_rre_details_tab(TO_CHAR(p_tim_id)).ret_code;
         RETURN;
      ELSE

         IF p_tim_id IS NOT NULL
         THEN
            g_rre_details_tab(TO_CHAR(p_tim_id)).session_date := p_session_date;
         END IF;

         -- Bug 7359347
         -- Passing in session date to the function.
         IF (details (p_tim_id,p_session_date))
      	 THEN
      	    -- First we check if the records have not been transferred yet
      	    -- Bug 7359347
      	    OPEN csr_not_transferred (p_tim_id, p_parent_id,p_session_date);
      	    FETCH csr_not_transferred INTO l_not_transferred;

      	    IF csr_not_transferred%FOUND
      	    THEN -- we can do a correction
      	       if g_debug then
      	       	     hr_utility.set_location ('Do CORRECTION', 60);
      	       end if;

      	       o_dt_update_mod := 'CORRECTION';

      	    ELSE -- look for records that have been transferred and undergoing RETRO


      	         -- Bug 6067007 - Addition
      	        OPEN csr_transferred_retro (p_tim_id, p_parent_id);
	      FETCH csr_transferred_retro INTO l_transfered_retro;

	      IF csr_transferred_retro%FOUND
	      THEN -- TC undergoing RETRO now, only UPDATE allowed.

	            if g_debug then
	          	  hr_utility.set_location ('Do UPDATE', 70);
	            end if;
	            o_dt_update_mod := 'UPDATE';
	       -- Bug 6067007


	      ELSE -- look for records that have been transferred

      	              OPEN csr_transferred (p_tim_id, p_parent_id);
      	              FETCH csr_transferred INTO l_transferred;

      	              IF csr_transferred%FOUND
      	              THEN -- Was it already updated today?
      	                    OPEN csr_changed_today (p_tim_id, p_parent_id, p_session_date);
      	                    FETCH csr_changed_today INTO l_changed_today;

      	                    IF csr_changed_today%FOUND
      	                    THEN -- DT will not allow an update so error
      	                        o_return_code := 1; -- this means that an error should be raised
      	                        o_dt_update_mod := NULL;
      	                    ELSE -- We can allow an DT UPDATE because that will keep the history
      	                        if g_debug then
      	                	     hr_utility.set_location ('Do UPDATE', 70);
      	                        end if;
      	                        o_dt_update_mod := 'UPDATE';
      	                    END IF; -- IF csr_changed_today%FOUND

      	                    CLOSE csr_changed_today;
      	              ELSE -- We can allow an DT UPDATE because that will keep the history
      	                    if g_debug then
      	                         hr_utility.set_location ('Do UPDATE', 80);
      	                    end if;
      	                    o_dt_update_mod := 'UPDATE';
      	              END IF; -- IF csr_transferred%FOUND
      	              CLOSE csr_transferred;

      	        END IF; -- IF  csr_transferred_retro%FOUND
      	        CLOSE csr_transferred_retro;

      	    END IF; -- IF csr_not_transferred%FOUND
      	    CLOSE csr_not_transferred;

      	 ELSE -- if details
      	    if g_debug then
      	    	 hr_utility.set_location ('Do CORRECTION', 90);
      	    end if;
      	    o_dt_update_mod := 'CORRECTION';
      	 END IF;

         -- Bug  7359347
         -- Cache this value if tim id is not null
         IF p_tim_id IS NOT NULL
         THEN
      	    g_rre_details_tab(TO_CHAR(p_tim_id)).upd_mode := o_dt_update_mod ;
      	    g_rre_details_tab(TO_CHAR(p_tim_id)).ret_code := o_return_code ;
      	 END IF;
      	 RETURN;
     END IF;


   EXCEPTION
      WHEN OTHERS
      THEN
         o_return_code := 4;
         o_error_message :=    'Error('
                            || SQLERRM
                            || ') occured in Retro_restrict_edit procedure';
         RETURN;
   END retro_restrict_edit;

   FUNCTION get_weekly_total (
      a_location               IN   VARCHAR2,
      a_date_worked            IN   DATE,
      a_start_day_of_week      IN   VARCHAR2,
      a_tim_id                 IN   NUMBER,
      a_base_element_type_id   IN   NUMBER,
      a_ep_id                  IN   NUMBER,

-- Added the following parameter for
-- OTLR Recurring Period Preference Support.
      a_for_person_id          IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_weekly_total   NUMBER;


-- MHANDA changed this cursor to get total weekly hours between
-- start_day_of_week and (g_date_worked - 1) to support 3tier weekly rules for
-- SPECIAL Earning Policy.

-- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

/*
      CURSOR weekly_total
      IS
         SELECT NVL (SUM (hrw.hours), 0)
           FROM hxt_det_hours_worked hrw, --C421
                hxt_timecards tim,
                hxt_earn_groups erg,
                hxt_earn_group_types egt,
                hxt_earning_policies erp
          -- WHERE  tim.id = a_tim_id
          -- AND    hrw.tim_id = a_tim_id

          -- Changed  the above where clause as follows for supporting the
          -- OTLR Recurring Period Preference.
          WHERE tim.for_person_id = a_for_person_id
            AND hrw.tim_id = tim.id

-- This has been changed back to get total weekly hours between
-- start_day_of_week and (g_date_worked) as it was not calculating the totals
-- correctly when entering hours on more than one summary row for the same day
--  AND hrw.date_worked between NEXT_DAY(a_date_worked-7,a_start_day_of_week)
--                          and (a_date_worked - 1)

            AND hrw.date_worked BETWEEN NEXT_DAY (
                                             a_date_worked
                                           - 7,
                                           a_start_day_of_week
                                        )
                                    AND a_date_worked

-- only include earnings to be counted toward
-- hours to be worked before being eligible for overtime.
            AND erp.id = a_ep_id
            AND egt.id = erp.egt_id
            AND erg.egt_id = egt.id
            AND erg.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN erp.effective_start_date
                                    AND erp.effective_end_date;  */


      CURSOR weekly_total(session_date  DATE)
      IS
         SELECT NVL (SUM (hrw.hours), 0)
           FROM hxt_det_hours_worked_f hrw,
                hxt_timecards_f tim,
                hxt_earn_groups erg,
                hxt_earn_group_types egt,
                hxt_earning_policies erp
          WHERE tim.for_person_id = a_for_person_id
            AND session_date between hrw.effective_start_date
                                      and hrw.effective_end_Date

            AND session_date between tim.effective_start_date
                                      and tim.effective_end_Date
            AND hrw.tim_id = tim.id
            AND hrw.date_worked BETWEEN NEXT_DAY (
                                             a_date_worked
                                           - 7,
                                           a_start_day_of_week
                                        )
                                    AND a_date_worked
            AND erp.id = a_ep_id
            AND egt.id = erp.egt_id
            AND erg.egt_id = egt.id
            AND erg.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN erp.effective_start_date
                                    AND erp.effective_end_date;



      l_proc           VARCHAR2 (200) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc := 'hxt_td_util.GET_WEEKLY_TOTAL';
	      hr_utility.set_location (l_proc, 10);
	      hr_utility.TRACE (
		    'a_date_worked :'
		 || TO_CHAR (a_date_worked, 'dd-mon-yyyy hh24:mi:ss')
	      );
	      hr_utility.TRACE (   'a_start_day_of_week    :'
				|| a_start_day_of_week);
	      hr_utility.TRACE (   'a_tim_id               :'
				|| a_tim_id);
	      hr_utility.TRACE (
		    'a_base_element_type_id :'
		 || a_base_element_type_id
	      );
	      hr_utility.TRACE (   'a_ep_id                :'
				|| a_ep_id);
	      hr_utility.TRACE (   'a_for_person_id        :'
				|| a_for_person_id);
      end if;
      -- Bug 7359347
      -- Pass session date to the cursor.
      OPEN weekly_total(g_td_session_date);

      FETCH weekly_total INTO l_weekly_total;
      if g_debug then
	      hr_utility.TRACE (   'l_weekly_total :'
				|| l_weekly_total);
      end if;
      CLOSE weekly_total;
      if g_debug then
      	      hr_utility.set_location (l_proc, 20);
      end if;
      RETURN l_weekly_total;
   END;

   FUNCTION get_weekly_total_prev_days (
      a_location               IN   VARCHAR2,
      a_date_worked            IN   DATE,
      a_start_day_of_week      IN   VARCHAR2,
      a_tim_id                 IN   NUMBER,
      a_base_element_type_id   IN   NUMBER,
      a_ep_id                  IN   NUMBER,

-- Added the following parameter for
-- OTLR Recurring Period Preference Support.
      a_for_person_id          IN   NUMBER
   )
      RETURN NUMBER
   IS
      l_weekly_total   NUMBER;


-- MHANDA changed this cursor to get total weekly hours between
-- start_day_of_week and (g_date_worked - 1) to support 3tier weekly rules for
-- SPECIAL Earning Policy.

-- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

/*
      CURSOR weekly_total
      IS
         SELECT NVL (SUM (hrw.hours), 0)
           FROM hxt_det_hours_worked hrw, --C421
                hxt_timecards tim,
                hxt_earn_groups erg,
                hxt_earn_group_types egt,
                hxt_earning_policies erp
          -- WHERE  tim.id = a_tim_id
          -- AND    hrw.tim_id = a_tim_id

          -- Changed  the above where clause as follows for supporting the
          -- OTLR Recurring Period Preference.
          WHERE tim.for_person_id = a_for_person_id
            AND hrw.tim_id = tim.id

-- This has been changed back to get total weekly hours between
-- start_day_of_week and (g_date_worked) as it was not calculating the totals
-- correctly when entering hours on more than one summary row for the same day
--  AND hrw.date_worked between NEXT_DAY(a_date_worked-7,a_start_day_of_week)
--                          and (a_date_worked - 1)

            AND hrw.date_worked BETWEEN NEXT_DAY (
                                             a_date_worked
                                           - 7,
                                           a_start_day_of_week
                                        )
                                    AND   a_date_worked
                                        - 1

-- only include earnings to be counted toward
-- hours to be worked before being eligible for overtime.
            AND erp.id = a_ep_id
            AND egt.id = erp.egt_id
            AND erg.egt_id = egt.id
            AND erg.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN erp.effective_start_date
                                    AND erp.effective_end_date;

*/

      CURSOR weekly_total(session_date  DATE)
      IS
         SELECT NVL (SUM (hrw.hours), 0)
           FROM hxt_det_hours_worked_f hrw, --C421
                hxt_timecards_f tim,
                hxt_earn_groups erg,
                hxt_earn_group_types egt,
                hxt_earning_policies erp
          WHERE tim.for_person_id = a_for_person_id
            AND hrw.tim_id = tim.id
            AND session_date BETWEEN hrw.effective_start_date
                                       AND hrw.effective_end_date
            AND session_date BETWEEN tim.effective_start_date
                                       AND tim.effective_end_date
            AND hrw.date_worked BETWEEN NEXT_DAY (
                                             a_date_worked
                                           - 7,
                                           a_start_day_of_week
                                        )
                                    AND   a_date_worked
                                        - 1
            AND erp.id = a_ep_id
            AND egt.id = erp.egt_id
            AND erg.egt_id = egt.id
            AND erg.element_type_id = hrw.element_type_id
            AND hrw.date_worked BETWEEN erp.effective_start_date
                                    AND erp.effective_end_date;


      l_proc           VARCHAR2 (200) ;
   BEGIN
      g_debug :=hr_utility.debug_enabled;
      if g_debug then
	      l_proc := 'hxt_td_util.GET_WEEKLY_TOTAL';
	      hr_utility.set_location (l_proc, 10);
	      hr_utility.TRACE (
		    'a_date_worked :'
		 || TO_CHAR (a_date_worked, 'dd-mon-yyyy hh24:mi:ss')
	      );
	      hr_utility.TRACE (   'a_start_day_of_week    :'
				|| a_start_day_of_week);
	      hr_utility.TRACE (   'a_tim_id               :'
				|| a_tim_id);
	      hr_utility.TRACE (
		    'a_base_element_type_id :'
		 || a_base_element_type_id
	      );
	      hr_utility.TRACE (   'a_ep_id                :'
				|| a_ep_id);
	      hr_utility.TRACE (   'a_for_person_id        :'
				|| a_for_person_id);
      end if;
      -- Bug 7359347
      -- Pass session date to the cursor.
      OPEN weekly_total(g_td_session_date);
      FETCH weekly_total INTO l_weekly_total;
      if g_debug then
	      hr_utility.TRACE (   'l_weekly_total :'
				|| l_weekly_total);
      end if;
      CLOSE weekly_total;
      if g_debug then
      	      hr_utility.set_location (l_proc, 20);
      end if;
      RETURN l_weekly_total;
   END get_weekly_total_prev_days;


--
----------------- Include For ot Cap ---------------------------------
   FUNCTION include_for_ot_cap (
      a_earn_group     IN   NUMBER,
      a_element_type   IN   NUMBER,
      a_base_element   IN   NUMBER,
      a_date_worked    IN   DATE
   )
      RETURN BOOLEAN
   IS

--  returns true if a particular earning is counted toward the weekly overtime cap
      returned_element   NUMBER;
   BEGIN
      IF a_element_type = a_base_element
      THEN
         RETURN TRUE;
      END IF;

      SELECT 1
        INTO returned_element
        FROM hxt_earn_group_types egt
       WHERE egt.fcl_eg_type = 'INCLUDE'
         AND a_date_worked BETWEEN egt.effective_start_date
                               AND egt.effective_end_date
         AND egt.id = a_earn_group
         AND EXISTS ( SELECT 'x'
                        FROM hxt_earn_groups egr
                       WHERE egr.egt_id = egt.id
                         AND egr.element_type_id = a_element_type);

      IF returned_element = 1
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END;


--
------------------ Load Changed Status -------------------------------
   FUNCTION load_changed_status (a_hrw_id IN NUMBER)
      RETURN VARCHAR2
   IS
      v_status   CHAR (1) := ''; --HXT11i1 Return null instead of space


      -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

      CURSOR changed_cur(session_date  DATE)
      IS
         SELECT 'C'
           FROM hxt_sum_hours_worked_f hrwp
          WHERE hrwp.id = a_hrw_id
            AND session_date BETWEEN hrwp.effective_start_date
                                 AND hrwp.effective_end_date
            AND (   creation_date <> last_update_date
                 OR EXISTS ( SELECT '1'
                               FROM hxt_sum_hours_worked_f hrw
                              WHERE hrw.id = a_hrw_id
                                AND hrw.effective_start_date <>
                                                    hrwp.effective_start_date)
                );
   BEGIN
      -- Bug 7359347
      -- Pass session date to the cursor.
      OPEN changed_cur(g_td_session_date);
      FETCH changed_cur INTO v_status;
      CLOSE changed_cur;
      RETURN v_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'X';
   END;


--
------------------- Load Error Status -------------------------------
--BEGIN HXT11i1
/***************************************************************************
** Modify Load_Error_Status to select the Value stored in ERR_TYPE from   **
** HXT_ERRORS rather then selecting a hard coded 'E' if the record exists. **
***************************************************************************/
   FUNCTION load_error_status (a_hrw_id IN NUMBER)
      RETURN VARCHAR2
   IS
      returned_status   VARCHAR2 (03) := '';

      CURSOR error_status
      IS
         SELECT err_type
           FROM hxt_errors err
          WHERE err.hrw_id = a_hrw_id;
   BEGIN
      OPEN error_status;
      FETCH error_status INTO returned_status;
      CLOSE error_status;
      RETURN returned_status;
   END load_error_status;


---------------------- Determine Fixed Premium ------------------------
/* Begin OHM104 RJT; put into TA35 May27,97  RTF  */
/* ******************************************************************
   *  FUNCTION determine_fixed_premium                              *
   *                                                                *
   *  Purpose                                                       *
   *    To determine if a element is fixed premium and the of the   *
   *    fixed premium.  The amount of the fixed premium is place in *
   *    amount field on the time card.                              *
   *     rate                                                       *
   *                                                                *
   *  Returns                                                       *
   *    p_return_code - 0 - no errors  2 - errors occured.          *
   *    p_amount      - Null if the element is not a fixed premium  *
   *                  - The amount of the fixed premium             *
   *                                                                *
   *  Arguments                                                     *
   *    p_element_type_id - The hours type.                         *
   *                                                                *
   *****************************************************************/
   FUNCTION determine_fixed_premium (
      p_tim_id                              NUMBER,
      p_id                                  NUMBER,
      p_hours                               NUMBER,
      p_element_type_id                     NUMBER,
      p_effective_start_date                DATE,
      p_effective_end_date                  DATE,
      p_return_code            OUT NOCOPY   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR fixed_amount_cur (c_element_type_id NUMBER)
      IS
         SELECT petv.hxt_premium_amount
           FROM hxt_pay_element_types_f_ddf_v petv
          WHERE petv.hxt_earning_category = 'OTH'
            AND petv.hxt_premium_type = 'FIXED'
            AND petv.element_type_id = c_element_type_id
            AND petv.effective_start_date <= p_effective_start_date
            AND petv.effective_end_date >= p_effective_end_date;

      v_amount   hxt_det_hours_worked_f.amount%TYPE;
   BEGIN

-- Determine if the element is a fixed amount and what the fixed amount is.

      OPEN fixed_amount_cur (p_element_type_id);
      FETCH fixed_amount_cur INTO v_amount;

      IF fixed_amount_cur%NOTFOUND
      THEN
         CLOSE fixed_amount_cur;
         RETURN NULL;
      END IF;

      CLOSE fixed_amount_cur;


-- Ensure that the hours field is null.

      IF p_hours > 0
      THEN
         p_return_code := 2;
         fnd_message.set_name ('HXT', 'HXT_39467_NO_HRS_4_FIX_PREM');
         hxt_util.gen_error (
            p_tim_id,
            p_id,
            NULL,
            NULL,
            '',
            'tdutilbd.determine_fixed_premium ',
            NULL,
            p_effective_start_date,
            p_effective_end_date,
            'ERR'
         );
         RETURN NULL;
      END IF;

      p_return_code := 0;
      RETURN v_amount;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_return_code := 2;
         fnd_message.set_name ('HXT', 'HXT_39468_OR_ERR_SEL_PREM_AMT');
         hxt_util.gen_error (
            p_tim_id,
            p_id,
            NULL,
            NULL,
            '',
            'tdutilbd.fixed_amount. ',
            SQLERRM,
            p_effective_start_date,
            p_effective_end_date,
            'ERR'
         );
         RETURN NULL;
   END determine_fixed_premium;


--
--------------------- Get Hourly Rate ------------------------
-- begin CERTPAY
   FUNCTION get_hourly_rate (
      p_eff_date                     DATE,
      p_ptp_id                       NUMBER,
      p_assignment_id                NUMBER,
      p_hourly_rate     OUT NOCOPY   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR sal_cur
      IS
         SELECT pro.proposed_salary, ppb.pay_basis
           FROM per_pay_proposals pro,
                per_pay_bases ppb,
                per_assignments_f asg
          WHERE pro.assignment_id = p_assignment_id
            AND ppb.pay_basis_id = asg.pay_basis_id
            AND asg.assignment_id = pro.assignment_id
            AND p_eff_date BETWEEN asg.effective_start_date
                               AND asg.effective_end_date
            AND pro.approved = 'Y'
            AND pro.change_date = (SELECT MAX (pro2.change_date)
                                     FROM per_pay_proposals pro2
                                    WHERE pro2.assignment_id =
                                                              p_assignment_id
                                      AND pro2.approved = 'Y'
                                      AND p_eff_date >= pro2.change_date);

      CURSOR num_periods_cur
      IS
         SELECT ptpt.number_per_fiscal_year
           FROM per_time_periods ptp, per_time_period_types ptpt
          WHERE p_ptp_id = ptp.time_period_id
            AND ptp.period_type = ptpt.period_type;

      v_proposed_salary      per_pay_proposals_v.proposed_salary%TYPE;
      v_pay_basis            per_pay_proposals_v.pay_basis%TYPE;
      l_hours_per_year       NUMBER (22, 5)
                      := TO_NUMBER (fnd_profile.VALUE ('HXT_HOURS_PER_YEAR'));
      v_annual_pay_periods   per_time_period_types.number_per_fiscal_year%TYPE;
   BEGIN
      OPEN sal_cur;
      FETCH sal_cur INTO v_proposed_salary, v_pay_basis;

      IF sal_cur%NOTFOUND
      THEN
         RETURN 1; -- 'No salary information for the employee'
      END IF;

      OPEN num_periods_cur;
      FETCH num_periods_cur INTO v_annual_pay_periods;

      IF num_periods_cur%NOTFOUND
      THEN
         RETURN 2; -- 'Unable to determine number of pay periods.'
      END IF;


-- Calculate an hourly rate for the salary basis
      IF v_pay_basis = 'ANNUAL'
      THEN
         p_hourly_rate := v_proposed_salary / l_hours_per_year;
      ELSIF v_pay_basis = 'MONTHLY'
      THEN
         p_hourly_rate :=   (v_proposed_salary * 12)
                          / l_hours_per_year;
      ELSIF v_pay_basis = 'PERIOD'
      THEN
         p_hourly_rate :=
                 (v_proposed_salary * v_annual_pay_periods)
               / l_hours_per_year;
      ELSE -- 'HOURLY'
         p_hourly_rate := v_proposed_salary;
      END IF;

      RETURN 0;
   END;


-- end CERTPAY
--BEGIN HXT11i1
/*****************************************************************
*  FUNCTION Load_Tim_Error_Status     -- ER177  SDM 09-03-98     *
*                                                                *
*  Purpose                                                       *
*    Select and return the value ERR_TYPE from the Table         *
*    HXT_ERRORS where the tim_id passed in = HXT_ERRORS.TIM_ID.  *
*                                                                *
*  Returns                                                       *
*    returned_status - Value of ERR_TYPE where tim_id passed in  *
*    equals HXT_ERRORS.TIM_ID.0                                  *
*                                                                *
*  Arguments                                                     *
*    p_tim_id      - Time Card ID                                *
*                                                                *
*****************************************************************/
   FUNCTION load_tim_error_status (p_tim_id IN NUMBER)
      RETURN VARCHAR2
   IS
      returned_status   VARCHAR2 (3) := '';

      CURSOR error_status
      IS
         SELECT   err_type
             FROM hxt_errors err
            WHERE err.tim_id = p_tim_id
         ORDER BY err_type; -- So that 'ERR' has precedence over 'WRN'
   BEGIN
      OPEN error_status;
      FETCH error_status INTO returned_status;
      CLOSE error_status;
      RETURN returned_status;
   END load_tim_error_status;


/*****************************************************************
*  FUNCTION Load_HRW_Error_Change_Status -- ER177  SDM 09-03-98  *
*                                                                *
*  Purpose                                                       *
*    Retrieve Error Type and Change Type for HRW row and retrun  *
*    Concatenated value.                                         *
*                                                                *
*  Returns                                                       *
*    returned_status - Value of Concatenated value of Error type *
*                      and changed type                          *
*                                                                *
*  Arguments                                                     *
*    p_hrw_id      - ID of summary Row                           *
*    p_tim_status  - Error type of the time card record          *
*                                                                *
*****************************************************************/
   FUNCTION load_hrw_error_change_status (
      p_hrw_id       IN   NUMBER,
      p_tim_status   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      hrw_status      VARCHAR2 (01);
      change_status   VARCHAR2 (01);
   BEGIN

-- Bug Fix : 2538832
-- Added return statement to ensure that the function returns
-- only the error status, if timecard status is Error.
-- i.e. ignore Change status.

      IF p_tim_status = 'E'
      THEN
         hrw_status := SUBSTR (load_error_status (p_hrw_id), 1, 1);
         RETURN hrw_status;
      END IF;

      change_status := load_changed_status (p_hrw_id);
      RETURN    hrw_status
             || change_status;
   END load_hrw_error_change_status;


/*****************************************************************
*  FUNCTION Get_Sum_Hours_Worked         -- ER183  SDM 09-03-98  *
*                                                                *
*  Purpose                                                       *
*    Get the sum of the hours from hxt_sum_hours_worked based on *
*    parameters passed in.  Return this value to the calling     *
*    module                                                      *
*                                                                *
*  Returns                                                       *
*    total_hrs - Total hrs employee worked based on the date     *
*                passed in                                       *
*                                                                *
*  Arguments                                                     *
*    p_tim_id      - ID of Timecard Row                          *
*    p_hrw_id      - ID of summary Row                           *
*    p_date_worked - Date the hours are to be summed upon        *
*                                                                *
*****************************************************************/
   FUNCTION get_sum_hours_worked (
      p_tim_id        IN   NUMBER, -- p_hrw_group_id IN NUMBER,
      p_date_worked   IN   DATE
   )
      RETURN NUMBER
   IS
      -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

      /*
      CURSOR edit24_cur
      IS
         SELECT SUM (hours)
           FROM hxt_sum_hours_worked
          WHERE tim_id = p_tim_id -- AND GROUP_ID <> NVL(p_hrw_group_id, 0)
                                  AND date_worked = p_date_worked;
       */
      CURSOR edit24_cur
      IS
         SELECT SUM (hours)
           FROM hxt_sum_hours_worked_f
          WHERE tim_id = p_tim_id -- AND GROUP_ID <> NVL(p_hrw_group_id, 0)
            AND date_worked = p_date_worked
            AND g_td_session_date BETWEEN effective_start_date
                                      AND effective_end_date;


      l_total_hours   NUMBER;
   BEGIN
      OPEN edit24_cur;
      FETCH edit24_cur INTO l_total_hours;

      IF edit24_cur%NOTFOUND
      THEN
         l_total_hours := 0;
      END IF;

      CLOSE edit24_cur;
      RETURN l_total_hours;
   END get_sum_hours_worked;


-----------------------------------------------------------------------------
-- This procedure cannot be used for OVT calculation.  That's because
-- it doesn't check the Include for OT group in the case of Absences.
-- See package TIMDETBD.PLS  get_contig_hours for an example of how
-- to do that.
-- This procedure is intended to be used for shift differential calculations.
-----------------------------------------------------------------------------
   PROCEDURE get_contig_hrs_and_start (
      p_date_worked       IN              DATE,
      p_person_id         IN              NUMBER,
      p_current_time_in   IN              DATE,
      p_egt_id            IN              NUMBER,
      p_tim_id            IN              NUMBER,
      o_first_time_in     OUT NOCOPY      DATE,
      o_contig_hrs        OUT NOCOPY      NUMBER
   )
   IS

-- We do not want to get records where the time_out is the exact time and day
-- as the time_in of a previous record.  This is an error condition that should
-- never happen, but did due to an autogen error.  This code prevents endless
-- looping. SIR282
      -- Bug 7359347
         -- Changed the below cursor to pick up session date from global variable
         -- instead of fnd_sessions table.

      /*
      CURSOR contig_hrs (
         c_date_worked       DATE,
         c_current_time_in   DATE,
         c_tim_id            NUMBER
      )
      IS
         SELECT hrw.time_in, hrw.time_out, hrw.hours, hrw.element_type_id,
                hrw.date_worked, eltv.hxt_earning_category
           FROM hxt_det_hours_worked hrw,
                hxt_pay_element_types_f_ddf_v eltv,
                pay_element_types_f elt
          WHERE elt.element_type_id = hrw.element_type_id
            AND eltv.hxt_earning_category IN ('REG', 'OVT', 'ABS')
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND eltv.element_type_id = elt.element_type_id
            AND hrw.date_worked BETWEEN eltv.effective_start_date
                                    AND eltv.effective_end_date
            AND hrw.tim_id = c_tim_id
            AND hrw.time_out = c_current_time_in
            AND hrw.time_in <> hrw.time_out; --FIX endless loop PWM 01/28/99 SIR282
        */
      CURSOR contig_hrs (
         c_date_worked       DATE,
         c_current_time_in   DATE,
         c_tim_id            NUMBER,
         c_session_date      DATE
      )
      IS
         SELECT hrw.time_in, hrw.time_out, hrw.hours, hrw.element_type_id,
                hrw.date_worked, eltv.hxt_earning_category
           FROM hxt_det_hours_worked_f hrw,
                hxt_pay_element_types_f_ddf_v eltv,
                pay_element_types_f elt
          WHERE elt.element_type_id = hrw.element_type_id
            AND eltv.hxt_earning_category IN ('REG', 'OVT', 'ABS')
            AND c_session_date BETWEEN hrw.effective_start_date
                                   AND hrw.effective_end_date
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND eltv.element_type_id = elt.element_type_id
            AND hrw.date_worked BETWEEN eltv.effective_start_date
                                    AND eltv.effective_end_date
            AND hrw.tim_id = c_tim_id
            AND hrw.time_out = c_current_time_in
            AND hrw.time_in <> hrw.time_out; --FIX endless loop PWM 01/28/99 SIR282


      l_rec               contig_hrs%ROWTYPE;
      l_contig_hrs        NUMBER (7, 3)        := 0;
      l_continue          BOOLEAN              := TRUE;
      l_current_time_in   DATE                 := p_current_time_in;
      l_date_worked       DATE                 := p_date_worked;
      loop_counter        NUMBER               := 0; --  counts loop iterations for checking     SIR282
      error_code          NUMBER               := 0; -- PWM Fix for endless loop 01/28/99           SIR282
   BEGIN
      hxt_util.DEBUG (
            'Top of get_contig_hrs. time_in = '
         || TO_CHAR (l_current_time_in, 'HH24:MI')
      );

      WHILE l_continue = TRUE
      LOOP
         -- Bug 7359347
         -- Pass session date to the cursor.
         OPEN contig_hrs (l_date_worked, l_current_time_in, p_tim_id,g_td_session_date);
         FETCH contig_hrs INTO l_rec;

         IF contig_hrs%FOUND
         THEN
            hxt_util.DEBUG (
                  ' previous summary found. time_in = '
               || TO_CHAR (l_rec.time_in, 'HH24:MI')
            );
            l_contig_hrs :=   l_contig_hrs
                            + l_rec.hours;
            l_current_time_in := l_rec.time_in;
            l_date_worked := l_rec.date_worked;
            CLOSE contig_hrs;
         ELSE
            CLOSE contig_hrs;
            l_continue := FALSE;
         END IF;

         loop_counter :=   loop_counter
                         + 1; --PWM 01/28/99 Fix for endless loop SIR282

         IF loop_counter > 50
         THEN
            l_continue := FALSE;
            fnd_message.set_name ('HXT', 'HXT_39506_LOOP_COUNT_EXCEEDED');
            hxt_util.gen_error (
               p_tim_id,
               NULL,
               NULL,
               '',
               'hxttdutl.get_contig_hrs_and_start ',
               SQLERRM,
               p_date_worked,
               p_date_worked,
               'ERR'
            );
         END IF;
      END LOOP;

      hxt_util.DEBUG ('');
      hxt_util.DEBUG (   'Done. hours = '
                      || TO_CHAR (l_contig_hrs));
      o_contig_hrs := l_contig_hrs;
      o_first_time_in := l_current_time_in;
   END;
--END HXT11i1
END;

/
