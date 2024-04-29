--------------------------------------------------------
--  DDL for Package Body HXC_TPD_END
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TPD_END" AS
/* $Header: hxcendtp.pkb 120.8.12010000.6 2009/02/27 11:14:17 asrajago ship $ */

-- g_time_periods time_periods_table;
   g_debug   BOOLEAN := hr_utility.debug_enabled;

   -- Bug 6998662
   -- Added these global variables to manipulate the
   -- global tables for missing periods.  Used in
   -- populate_missing_time_periods
   g_resource_id    NUMBER := 0;
   g_tim_rec_id     NUMBER := 0 ;
   g_appln_set_id   NUMBER := 0 ;
   g_assignment_id  NUMBER := 0;


-- This change is in accordance to the changes in the report query
-- Q_Resource_Pref_Eval.
-- Since Application is one of the Sort Option, Application_Id needs to be
-- fetched from the query.
-- This function is called from the query to fetch the Application_Id by call
-- to Preference_Evaluation package.
   FUNCTION appl_id (p_person_id IN NUMBER)
      RETURN NUMBER
   IS
      l_appl_id   NUMBER;
      l_message   VARCHAR2 (80);
   BEGIN
      l_appl_id :=
         hxc_preference_evaluation.resource_pref_errcode
                                                (p_person_id,
                                                 'TS_PER_APPLICATION_SET|1|',
                                                 l_message,
                                                 SYSDATE
                                                );
      RETURN (l_appl_id);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (NULL);
   END;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_supervisor_name >----------------------------|
-- ----------------------------------------------------------------------------
--
   FUNCTION get_supervisor_name (
      p_supervisor_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2
   IS
      CURSOR c_supervisor_name (
         cp_supervisor_id    IN   NUMBER,
         cp_effective_date   IN   DATE
      )
      IS
         SELECT ppf.full_name
           FROM per_people_f ppf
          WHERE ppf.person_id = cp_supervisor_id
            AND cp_effective_date BETWEEN ppf.effective_start_date
                                      AND ppf.effective_end_date;

      supervisor_name   per_people_f.full_name%TYPE;
   BEGIN
      OPEN c_supervisor_name (p_supervisor_id, p_effective_date);

      FETCH c_supervisor_name
       INTO supervisor_name;

      CLOSE c_supervisor_name;

      RETURN (supervisor_name);
   END;

--
-- ----------------------------------------------------------------------------
-- |---------------------< populate_missing_time_periods >--------------------|
-- ----------------------------------------------------------------------------

-- An addition parameter p_assignment_id is included in this function.
-- This parameter is needed since a resource will have different assignments for
-- diff range of period mainly because of Hire-Terminate-ReHire action.
-- In such case, assignment_id valid for that date range is imp to display only
-- those time_periods valid for that range of time.

-- Bug 6998662
-- Added new paramters time recipient id and application_set_id
-- We need these two to correctly process complex application sets
-- like Projects and Payroll.

   FUNCTION populate_missing_time_periods (
      p_resource_id     IN   NUMBER,
      p_assignment_id   IN   NUMBER,
      p_start_date      IN   DATE,
      p_end_date        IN   DATE,
      p_appln_set_id    IN   NUMBER,
      p_tim_rec_id      IN   NUMBER
   )
      RETURN NUMBER
   IS
      p_period_end               DATE;
      p_period_start             DATE;
      l_recurring_period_id      NUMBER (11);
      l_number_per_fiscal_year   NUMBER (15);
      l_start_date               DATE;
      l_end_date                 DATE;
      l_period_end_date          DATE;
      l_period_type              VARCHAR2 (30);
      l_duration_in_days         NUMBER (10);
      l_next_index               BINARY_INTEGER                          := 0;
      lv_end_date                DATE                           := p_end_date;
      lv_exists                  VARCHAR2 (6)                         := NULL;
      l_add_to_start_date        NUMBER (2);
      l_pref_tc_period           VARCHAR2 (80);
-- Bug 2900824 and 2801769
      l_p_start_date             DATE;
      l_p_end_date               DATE;

      CURSOR c_period_exists (
         cp_resource_id    IN   NUMBER,
         cp_period_start   IN   DATE,
         cp_period_end     IN   DATE
      )
      IS
         SELECT htb.start_time, htb.stop_time
           FROM hxc_timecard_summary htb
          WHERE htb.resource_id = cp_resource_id
            AND cp_period_start <= htb.stop_time
            AND cp_period_end >= htb.start_time;

      CURSOR c_period_exists_chk (
         cp_resource_id    IN   NUMBER,
         cp_period_start   IN   DATE,
         cp_period_end     IN   DATE
      )
      IS
         SELECT 'x'
           FROM DUAL
          WHERE EXISTS (
                   SELECT 'x'
                     FROM hxc_timecard_summary htb
                    WHERE htb.resource_id = cp_resource_id
                      AND cp_period_start <= htb.stop_time
                      AND cp_period_end >= htb.start_time);

      p_message                  VARCHAR2 (30);
      lv_start_time              hxc_time_building_blocks.start_time%TYPE;
      lv_stop_time               hxc_time_building_blocks.stop_time%TYPE;
      ld_period_start_date       DATE;
      ld_period_end_date         DATE;
      lv_row_found               VARCHAR2 (1)                           := 'N';
      lv_exists1                 VARCHAR2 (1);
      l_temp_periods             hxc_period_evaluation.period_list;
      l_index                    NUMBER;
      l_period_list              hxc_period_evaluation.period_list;
      i                          BINARY_INTEGER                           := 1;


      -- Bug 6998662
      -- This variable ensures the termination dates display
      -- instead of period end dates
      l_asg_end_date             DATE;



      -- Bug 6998662
      -- Added conditions to check for Application period also
      -- in the following condition -- a period is valid in the
      -- current call only if the application set given is correct
      -- and the time recipient is valid.

      Function check_valid_period (p_resource_id IN NUMBER,
                                   p_start_date  IN DATE,
				   p_end_date    IN DATE,
                                   p_appln_set_id IN NUMBER,
                                   p_tim_rec_id   IN NUMBER,
                                   p_range_start  IN DATE,
                                   p_range_stop   IN DATE
				  )
         RETURN  BOOLEAN
      IS
         l_cnt	 NUMBER;
         l_pref  NUMBER := 0;

      BEGIN

      -- Bug: 5971387 - The following query has been modified to drive the person_type_id
      -- thru the per_person_type_usages table as opposed to per_person_types table.

         SELECT count(*)
	 INTO   l_cnt
         FROM   per_person_types ppt,
                per_person_type_usages_f ptu,
                per_people_f per
         WHERE  per.person_id = p_resource_id
	 AND    ptu.person_id = per.person_id
         AND    ptu.person_type_id = ppt.person_type_id
--         AND    ppt.system_person_type NOT IN ('EMP', 'EMP_APL', 'CWK') -- Bug 6486974
--         AND    per.effective_start_date <=  p_end_date
--         AND    per.effective_end_date   >=  p_start_date;
         AND    ppt.system_person_type IN ('EMP', 'EMP_APL', 'CWK')
         AND  (  p_end_date between per.effective_start_date
                           and per.effective_end_date
            OR   p_start_date between per.effective_start_date
                             and per.effective_end_date );


         -- Bug 6998662
         -- The following if condition looks at the global pref
         -- tables already loaded by Load_preferences call.
         -- The given period is valid only if a valid application
         -- set and a valid time recipient is being passed.

         IF  ( check_appln_set(p_resource_id,
                               p_range_start,
                               p_range_stop,
                               p_start_date,
                               p_end_date ) = p_appln_set_id)
           AND ( check_tc_required(p_resource_id           => p_resource_id,
                                   p_start_date            => p_range_start,
                                   p_stop_date             => p_range_stop,
                                   p_evaluation_start_date => p_start_date,
                                   p_evaluation_stop_date  => p_end_date,
                                   p_time_rec_id           => p_tim_rec_id ) = 'Y' )
         THEN
            l_pref := 1;
         END IF;

         -- Return valid only if the above conditions are satisfied.
         IF (l_cnt > 0 ) AND (l_pref = 1)
         THEN
	    RETURN TRUE;
	 ELSE
	    RETURN FALSE;
	 END IF;
      END check_valid_period;

   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug
      THEN
         hr_utility.TRACE ('Inside populate missing timecard function');
         hr_utility.set_location ('populate_missing_time_periods', 10);
      END IF;

      IF g_time_periods.COUNT > 0
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('populate_missing_time_periods', 20);
         END IF;

-- Following piece of code not needed since g_time_periods.delete is sufficient.

--      FOR i in g_time_periods.first .. g_time_periods.last LOOP
--          g_time_periods(i).start_time := null;
--          g_time_periods(i).stop_time  := null;
--        g_time_periods(i).resource_id  := null;
--      END LOOP;
         IF g_debug
         THEN
            hr_utility.TRACE ('Deleted PL/SQL table');
         END IF;

         -- Bug 6998662
         -- Need all the three below conditions
         -- It might be the same person, but might have a
         -- different time recipient or assignment, so delete
         -- the global table if anything is different.
         IF p_resource_id <> g_resource_id
           OR  p_tim_rec_id  <> g_tim_rec_id
           OR p_assignment_id <> g_assignment_id
           --AND  p_appln_set_id <> g_appln_set_id
         THEN
            g_time_periods.DELETE;
            -- Get the current values into the global variables to
            --  compare with the next iteration.
            g_resource_id   := p_resource_id;
            g_tim_rec_id    := p_tim_rec_id;
            g_appln_set_id  := p_appln_set_id;
            g_assignment_id := p_assignment_id;
         END IF;


      END IF;

      IF g_debug
      THEN
         hr_utility.set_location ('populate_missing_time_periods', 25);
         hr_utility.TRACE (   'p_start_date:'
                           || TO_CHAR (p_start_date, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'p_end_date  :'
                           || TO_CHAR (p_end_date, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE ('p_resource_id   :'|| p_resource_id);
         hr_utility.TRACE ('p_assignment_id :'||p_assignment_id);
         hr_utility.TRACE ('p_appln_set_id  :'||p_appln_set_id);
         hr_utility.TRACE ('p_tim_rec_id    :'||p_tim_rec_id);

      END IF;

      l_p_start_date := p_start_date;
      l_p_end_date := p_end_date;

      BEGIN
-- Incase Hiredate is between p_date_from and p_date_to,
-- then set starting date range as Hire date instead of p_start_from.

-- Also, here we need to consider assignment start and end date
-- for cases of Hire - Terminate - Re Hire where assignments are diff
-- before/after termination and re-hire.
/*
   select min(ppf.effective_start_date), max(ppf.effective_end_date)
   into l_p_start_date, l_p_end_date
   from per_people_f ppf, per_assignments_f paf
   where ppf.person_id = p_resource_id
   and paf.person_id = ppf.person_id
   and paf.assignment_id = p_assignment_id
   and paf.effective_start_date between ppf.effective_start_date
                                    and ppf.effective_end_date;
*/

/* select min(ppf.effective_start_date), max(ppf.effective_end_date)
   into l_p_start_date, l_p_end_date
      from per_people_f ppf,
           per_assignments_f paf,
      per_person_types ppt,
      per_person_type_usages_f ptu
   where ppf.person_id = p_resource_id
   and paf.person_id = ppf.person_id
   and ptu.person_id = ppf.person_id
   and ptu.person_type_id=ppt.person_type_id
   and ppt.system_person_type in ('EMP','EMP_APL','CWK')
   and paf.assignment_id = p_assignment_id
   and paf.effective_start_date between ppf.effective_start_date
                                    and ppf.effective_end_date
   and ppf.effective_start_date between ptu.effective_start_date
                                    and ptu.effective_end_date;
*/
/*
SELECT
       min(per.effective_start_date),
       max(per.effective_end_date)
INTO
       l_p_start_date, l_p_end_date
FROM
       per_person_types ppt,
       per_people_f per
WHERE
      per.person_id = p_resource_id
AND   ppt.person_type_id = per.person_type_id
AND   ppt.system_person_type in ('EMP','EMP_APL','CWK')
AND   per.effective_start_date =
                (select min(perMin.effective_start_date)
                 from per_people_f perMin
                 where perMin.person_id = per.person_id
                 AND   perMin.effective_start_date <=  p_end_date
                 AND   perMin.effective_end_date   >=  p_start_date)
AND EXISTS ( SELECT 'x'
             FROM   per_assignment_status_types ast,
                    per_assignments_f asm
             WHERE  asm.person_id = per.person_id
             AND    asm.primary_flag = 'Y'
             AND
                  (
                     asm.effective_start_date  <=  per.effective_end_date
                     AND
                     asm.effective_end_date    >=  per.effective_start_date
                  )
             AND    ast.assignment_status_type_id
                     = asm.assignment_status_type_id
             AND    ast.pay_system_status = 'P' );
*/

-- The above query changed as follows for bug 4687842. Basically the query has
-- been changed to drive the person_type_id thru the per_person_type_usages
-- table as opposed to per_person_types table as is the case in the above query
-- which causes bug 4687842.
         SELECT MIN (per.effective_start_date), MAX (per.effective_end_date)
           INTO l_p_start_date, l_p_end_date
           FROM per_person_type_usages_f ptu,
                per_person_types ppt,
                per_people_f per
          WHERE per.person_id = p_resource_id
            AND ptu.person_id = per.person_id
            AND ptu.person_type_id = ppt.person_type_id
            AND ppt.system_person_type IN ('EMP', 'EMP_APL', 'CWK')
            AND (per.effective_start_date =
                   (SELECT MIN (permin.effective_start_date)
                      FROM per_people_f permin
                     WHERE permin.person_id = per.person_id
                       AND permin.effective_start_date <= p_end_date
                       AND permin.effective_end_date >= p_start_date)
		 OR
		 per.effective_start_date =
                   (SELECT MAX(permin.effective_start_date)
                      FROM per_people_f permin
                     WHERE permin.person_id = per.person_id
                       AND permin.effective_start_date <= p_end_date
                       AND permin.effective_end_date >= p_start_date)
		)
            AND EXISTS (
                   SELECT 'x'
                     FROM per_assignment_status_types ast,
                          per_assignments_f asm
                    WHERE asm.person_id = per.person_id
                      AND asm.primary_flag = 'Y'
                      -- Bug 6998662 -- Added the assignment check here.
                      AND asm.assignment_id = p_assignment_id
                      AND (    asm.effective_start_date <=
                                                        per.effective_end_date
                           AND asm.effective_end_date >=
                                                      per.effective_start_date
                          )
                      AND ast.assignment_status_type_id =
                                                 asm.assignment_status_type_id
                      AND NVL (ast.pay_system_status, 'P') =
                             DECODE (ast.per_system_status,
                                     'ACTIVE_CWK', 'D',
                                     'P'
                                    ));

         IF g_debug
         THEN
            hr_utility.TRACE (   'l_p_start_date:'|| TO_CHAR (l_p_start_date,'dd-mon-yyyy hh24:mi:ss'));
            hr_utility.TRACE (   'l_p_end_date:'  || TO_CHAR (l_p_end_date,'dd-mon-yyyy hh24:mi:ss'));
         END IF;

         IF (l_p_start_date IS NULL OR l_p_end_date IS NULL)
         THEN
            RETURN (0);
-- Incase HireDate or Termianation Date of the resource is not between
-- p_date_from and p_date_to,
-- then the input date range is valid.
         ELSE
            IF (l_p_start_date < p_start_date)
            THEN
               l_p_start_date := p_start_date;
            END IF;

            IF (l_p_end_date > p_end_date)
            THEN
               l_p_end_date := p_end_date;
            ELSE
               lv_end_date := l_p_end_date;
            END IF;
         END IF;
      END;

     -- Bug 6998662
     l_asg_end_date := l_p_end_date;

      IF g_debug
      THEN
         hr_utility.set_location ('populate_missing_time_periods', 26);
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE (   'l_p_start_date:'
                           || TO_CHAR (l_p_start_date,
                                       'DD-MON-YYYY HH24:MI:SS'
                                      )
                          );
         hr_utility.TRACE (   'l_p_end_date  :'
                           || TO_CHAR (l_p_end_date, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'lv_end_date  :'
                           || TO_CHAR (lv_end_date, 'DD-MON-YYYY HH24:MI:SS')
                          );
      END IF;

/* FOR i in c_people(p_business_group_id,p_resource_id) LOOP
      lv_resource_id := i.person_id;
*/
      l_pref_tc_period :=
         hxc_preference_evaluation.resource_pref_errcode
                                                       (p_resource_id,
                                                        'TC_W_TCRD_PERIOD|1|',
                                                        p_message
                                                       );

      IF g_debug
      THEN
         hr_utility.set_location ('populate_missing_time_periods', 30);
         hr_utility.TRACE ('l_pref_tc_period = ' || l_pref_tc_period);
      END IF;

      SELECT hrp.recurring_period_id, hrp.start_date, hrp.end_date,
             hrp.period_type, hrp.duration_in_days
        INTO l_recurring_period_id, l_start_date, l_end_date,
             l_period_type, l_duration_in_days
        FROM hxc_recurring_periods hrp
       WHERE hrp.recurring_period_id = l_pref_tc_period;

      IF g_debug
      THEN
         hr_utility.TRACE ('l_recurring_period_id:' || l_recurring_period_id);
         hr_utility.TRACE (   'l_start_date         :'
                           || TO_CHAR (l_start_date, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE (   'l_end_date           :'
                           || TO_CHAR (l_end_date, 'DD-MON-YYYY HH24:MI:SS')
                          );
         hr_utility.TRACE ('l_period_type        :' || l_period_type);
         hr_utility.TRACE ('l_duration_in_days   :' || l_duration_in_days);
         hr_utility.set_location ('populate_missing_time_periods', 50);
      END IF;

      IF l_end_date IS NULL
      THEN
         l_end_date := hr_general.end_of_time;
      --to_date('31/12/4712','DD/MM/YYYY');
      END IF;

/*   IF  lv_end_date < l_start_date
    OR lv_end_date > l_end_date THEN

    p_error_message := 'The Timecard does not belong to this Period';

    RETURN;
   END IF;
*/
      IF g_debug
      THEN
         hr_utility.set_location ('populate_missing_time_periods', 60);
      END IF;

      l_temp_periods :=
         hxc_period_evaluation.get_period_list
                            (p_current_date               => SYSDATE,
                             p_recurring_period_type      => l_period_type,
                             p_duration_in_days           => l_duration_in_days,
                             p_rec_period_start_date      => l_start_date,
                             p_max_date_in_futur          => p_end_date,
                             p_max_date_in_past           => p_start_date - 1
                             );

      IF g_debug
      THEN
         hr_utility.TRACE ('l_temp_periods.count ' || l_temp_periods.COUNT);
      END IF;



      -- Since the l_temp_periods pl sql table index is not in sequence,
      -- move these periods to l_period_list pl sql table with sequenced index
      IF l_temp_periods.COUNT > 0
      THEN
         l_index := l_temp_periods.FIRST;

         -- Bug 6998662
         -- Looping thru and printing out the values, nothing more.
         IF g_debug
         THEN
             hr_utility.trace('Printing l_temp_periods ');
             FOR i IN l_temp_periods.FIRST..l_temp_periods.LAST
             LOOP
                IF l_temp_periods.EXISTS(i)
                THEN
                    hr_utility.trace(TO_CHAR (l_temp_periods(i).start_date,'DD-MON-YYYY')||
                               '--'||TO_CHAR (l_temp_periods(i).end_date,'DD-MON-YYYY'));
                END IF;
             END LOOP;
         END IF;


         LOOP
            IF g_debug
            THEN
               hr_utility.set_location ('populate_missing_time_periods', 65);
            END IF;

            EXIT WHEN NOT l_temp_periods.EXISTS (l_index);
            l_period_list (i).start_date :=
                                           l_temp_periods (l_index).start_date;
            l_period_list (i).end_date := l_temp_periods (l_index).end_date;
            l_index := l_temp_periods.NEXT (l_index);
            i := i + 1;
         END LOOP;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('FYI');
      END IF;

      IF l_period_list.COUNT <> 0
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('populate_missing_time_periods', 70);
         END IF;

         FOR l_cnt IN l_period_list.FIRST .. l_period_list.LAST
         LOOP
            IF g_debug
            THEN
               hr_utility.TRACE (   'l_period_list.start_date is:'
                                 || TO_CHAR (l_period_list (l_cnt).start_date,
                                             'DD-MON-YYYY'
                                            )
                                );
               hr_utility.TRACE (   'l_period_list.end_date is:'
                                 || TO_CHAR (l_period_list (l_cnt).end_date,
                                             'DD-MON-YYYY'
                                            )
                                );
            END IF;
         END LOOP;

         IF g_debug
         THEN
            hr_utility.set_location ('populate_missing_time_periods', 75);
         END IF;
      END IF;

--------------------------------------------------------------------------------
      IF g_debug
      THEN
         hr_utility.set_location ('populate_missing_time_periods', 80);
      END IF;

     IF l_period_list.COUNT <> 0 THEN /* Bug: 5484502 */

      FOR i IN REVERSE l_period_list.FIRST .. l_period_list.LAST
      LOOP
         IF g_debug
         THEN
            hr_utility.set_location ('populate_missing_time_periods', 84);
            hr_utility.TRACE ('i :' || i);
         END IF;

         EXIT WHEN NOT l_period_list.EXISTS (i);

         IF g_debug
         THEN
            hr_utility.set_location ('populate_missing_time_periods', 85);
         END IF;

         l_start_date := l_period_list (i).start_date;
         l_period_end_date := l_period_list (i).end_date;

         IF( l_start_date < l_p_start_date)
         THEN
             l_start_date := l_p_start_date;
         END IF;

         IF g_debug
         THEN
            hr_utility.TRACE (   'lv_end_date = '
                              || TO_CHAR (lv_end_date,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
            hr_utility.TRACE (   'l_start_date = '
                              || TO_CHAR (l_start_date,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
            hr_utility.TRACE (   'l_period_end_date = '
                              || TO_CHAR (l_period_end_date,
                                          'DD-MON-YYYY HH24:MI:SS'
                                         )
                             );
         END IF;

         IF lv_end_date >= l_start_date AND lv_end_date <= l_period_end_date
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('populate_missing_time_periods', 90);
               hr_utility.TRACE ('p_resource_id = ' || p_resource_id);
               hr_utility.TRACE (   'lv_end_date = '
                                 || TO_CHAR (lv_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'l_start_date = '
                                 || TO_CHAR (l_start_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'l_period_end_date = '
                                 || TO_CHAR (l_period_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;

            p_period_start := l_start_date;
            p_period_end := l_period_end_date;
            lv_end_date := p_period_start - 1;

            IF g_debug
            THEN
               hr_utility.TRACE (   'lv_end_date:'
                                 || TO_CHAR (lv_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;

            ld_period_start_date := p_period_start;
            ld_period_end_date := p_period_end;

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_period_start :'
                                 || TO_CHAR (p_period_start,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'p_period_end   :'
                                 || TO_CHAR (p_period_end,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'lv_end_date    :'
                                 || TO_CHAR (lv_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'l_start_date   :'
                                 || TO_CHAR (l_start_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'l_period_end_date :'
                                 || TO_CHAR (l_period_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;

            OPEN c_period_exists (p_resource_id, p_period_start, p_period_end);

            LOOP
               IF g_debug
               THEN
                  hr_utility.set_location ('populate_missing_time_periods',
                                           95
                                          );
               END IF;

               FETCH c_period_exists
                INTO lv_start_time, lv_stop_time;

               IF g_debug
               THEN
                  hr_utility.TRACE ('p_resource_id  :' || p_resource_id);
                  hr_utility.TRACE ('lv_row_found  :' || lv_row_found);
                  hr_utility.TRACE (   'lv_start_time :'
                                    || TO_CHAR (lv_start_time,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'lv_stop_time  :'
                                    || TO_CHAR (lv_stop_time,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'ld_period_start_date:'
                                    || TO_CHAR (ld_period_start_date,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'ld_period_end_date  :'
                                    || TO_CHAR (ld_period_end_date,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'p_period_start :'
                                    || TO_CHAR (p_period_start,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
                  hr_utility.TRACE (   'p_period_end  :'
                                    || TO_CHAR (p_period_end,
                                                'DD-MON-YYYY HH24:MI:SS'
                                               )
                                   );
               END IF;

               IF c_period_exists%NOTFOUND AND lv_row_found = 'N'
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location
                                            ('populate_missing_time_periods',
                                             100
                                            );
                  END IF;

		  -- Bug 6998662
		  -- Changed the below call to pass the new values.
		  IF check_valid_period(p_resource_id,
		                        ld_period_start_date,
		                        ld_period_end_date,
		                        p_appln_set_id,
		                        p_tim_rec_id,
		                        p_start_date,
                                        p_end_date)
		  THEN
                     l_next_index := g_time_periods.COUNT;
                     g_time_periods (l_next_index).start_time :=
                                                             ld_period_start_date;
                     g_time_periods (l_next_index).stop_time :=
                                                          -- to take care of assig end dates.
                                                          --ld_period_end_date;
                                                          LEAST(ld_period_end_date,l_asg_end_date);
                     g_time_periods (l_next_index).resource_id := p_resource_id;
		  END IF;
               END IF;

               IF c_period_exists%NOTFOUND
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location
                                            ('populate_missing_time_periods',
                                             110
                                            );
                  END IF;

                  EXIT;
               END IF;

               lv_row_found := 'Y';

               IF g_debug
               THEN
                  hr_utility.set_location ('populate_missing_time_periods',
                                           120
                                          );
               END IF;

               IF     TRUNC (p_period_start) < TRUNC (lv_start_time)
                  AND TRUNC (p_period_end) < TRUNC (lv_stop_time)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location
                                            ('populate_missing_time_periods',
                                             130
                                            );
                  END IF;

                  ld_period_start_date := p_period_start;
                  ld_period_end_date := lv_start_time - 1;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'ld_period_start_date:'
                                       || TO_CHAR (ld_period_start_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'ld_period_end_date  :'
                                       || TO_CHAR (ld_period_end_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.set_location ('populate_missing_time_periods',
                                              140
                                             );
                  END IF;

                  OPEN c_period_exists_chk (p_resource_id,
                                            ld_period_start_date,
                                            ld_period_end_date
                                           );

                  FETCH c_period_exists_chk
                   INTO lv_exists1;

                  IF c_period_exists_chk%NOTFOUND
                  THEN
                     IF g_debug
                     THEN
                        hr_utility.set_location
                                            ('populate_missing_time_periods',
                                             150
                                            );
                     END IF;

		     -- Bug 6998662
		     -- Changed the below call to pass the new values.
		     IF check_valid_period(p_resource_id,
		                           ld_period_start_date,
		                           ld_period_end_date,
		                           p_appln_set_id,
		                           p_tim_rec_id,
		                           p_start_date,
                                           p_end_date )
		     THEN
                        l_next_index := g_time_periods.COUNT;
                        g_time_periods (l_next_index).start_time :=
                                                             ld_period_start_date;
                        g_time_periods (l_next_index).stop_time :=
                                                          -- to take care of assig end dates.
                                                          --ld_period_end_date;
                                                          LEAST(ld_period_end_date,l_asg_end_date);
                        g_time_periods (l_next_index).resource_id :=
                                                                    p_resource_id;
                     END IF;
                  END IF;

                  CLOSE c_period_exists_chk;
               ELSIF     TRUNC (p_period_start) > TRUNC (lv_start_time)
                     AND TRUNC (p_period_end) > TRUNC (lv_stop_time)
               THEN
                  IF g_debug
                  THEN
                     hr_utility.set_location
                                            ('populate_missing_time_periods',
                                             160
                                            );
                  END IF;

                  ld_period_start_date := lv_stop_time + 1;
                  ld_period_end_date := p_period_end;

                  IF g_debug
                  THEN
                     hr_utility.TRACE (   'ld_period_start_date:'
                                       || TO_CHAR (ld_period_start_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE (   'ld_period_end_date  :'
                                       || TO_CHAR (ld_period_end_date,
                                                   'DD-MON-YYYY HH24:MI:SS'
                                                  )
                                      );
                     hr_utility.TRACE ('p_resource_id       :'
                                       || p_resource_id
                                      );
                  END IF;

                  OPEN c_period_exists_chk (p_resource_id,
                                            ld_period_start_date,
                                            ld_period_end_date
                                           );

                  FETCH c_period_exists_chk
                   INTO lv_exists1;

                  IF c_period_exists_chk%NOTFOUND
                  THEN
  		     -- Bug 6998662
  		     -- Changed the below call to pass the new values.
  		     IF check_valid_period(p_resource_id,
		                           ld_period_start_date,
		                           ld_period_end_date,
		                           p_appln_set_id,
		                           p_tim_rec_id,
		                           p_start_date,
                                           p_end_date )
		     THEN
                        l_next_index := g_time_periods.COUNT;
                        g_time_periods (l_next_index).start_time :=
                                                            ld_period_start_date;
                        g_time_periods (l_next_index).stop_time :=
                                                          -- to take care of assig end dates.
                                                          --ld_period_end_date;
                                                          LEAST(ld_period_end_date,l_asg_end_date);
                        g_time_periods (l_next_index).resource_id :=
                                                                   p_resource_id;
	             END IF;
                  END IF;

                  CLOSE c_period_exists_chk;

                  IF g_debug
                  THEN
                     hr_utility.set_location
                                            ('populate_missing_time_periods',
                                             170
                                            );
                  END IF;
               END IF;

               IF g_debug
               THEN
                  hr_utility.set_location ('populate_missing_time_periods',
                                           180
                                          );
               END IF;
            END LOOP;

            CLOSE c_period_exists;

            lv_row_found := 'N';

            IF g_debug
            THEN
               hr_utility.set_location ('populate_missing_time_periods', 190);
               hr_utility.TRACE (   'lv_end_date   :'
                                 || TO_CHAR (lv_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'p_start_date  :'
                                 || TO_CHAR (p_start_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
            END IF;

            --  EXIT when lv_end_date < p_start_date;
            EXIT WHEN lv_end_date < l_p_start_date;
         ELSE
            IF g_debug
            THEN
               hr_utility.set_location ('populate_missing_time_periods', 200);
            END IF;

            p_period_start := '';
            p_period_end := '';
            l_start_date := '';
            l_period_end_date := '';
            lv_end_date := l_p_end_date;
            lv_row_found := 'N';

            IF g_debug
            THEN
               hr_utility.TRACE (   'p_period_start     :'
                                 || TO_CHAR (p_period_start,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'p_period_end       :'
                                 || TO_CHAR (p_period_end,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'l_start_date       :'
                                 || TO_CHAR (l_start_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'l_period_end_date  :'
                                 || TO_CHAR (l_period_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE (   'lv_end_date        :'
                                 || TO_CHAR (lv_end_date,
                                             'DD-MON-YYYY HH24:MI:SS'
                                            )
                                );
               hr_utility.TRACE ('lv_row_found       :' || lv_row_found);
            END IF;
         END IF;

         IF g_debug
         THEN
            hr_utility.set_location ('populate_missing_time_periods', 210);
         END IF;

         l_index := l_period_list.NEXT (l_index);
      END LOOP;
     END IF; /* Bug: 5484502 */

      IF g_debug
      THEN
         hr_utility.set_location ('populate_missing_time_periods', 220);
      END IF;

      IF g_time_periods.COUNT > 0
      THEN
         FOR i IN g_time_periods.FIRST .. g_time_periods.LAST
         LOOP
            IF g_debug
            THEN
               hr_utility.set_location ('populate_missing_time_periods', 230);
               hr_utility.TRACE ('i ' || i);
               hr_utility.TRACE (   'Start time '
                                 || TO_CHAR (g_time_periods (i).start_time,
                                             'dd/mm/yyyy'
                                            )
                                );
               hr_utility.TRACE (   'Stop time '
                                 || TO_CHAR (g_time_periods (i).stop_time,
                                             'dd/mm/yyyy'
                                            )
                                );
            END IF;
         END LOOP;
      END IF;

      IF g_debug
      THEN
         hr_utility.TRACE ('g_time_periods.count ' || g_time_periods.COUNT);
      END IF;

      RETURN (g_time_periods.COUNT);
   END populate_missing_time_periods;

--
-- ----------------------------------------------------------------------------
-- |---------------------< retrieve_missing_time_periods >--------------------|
-- ----------------------------------------------------------------------------

-- Adding additional parameter p_resource_id.
-- This is to retrieve missing TC periods of that resource only.
   -- Bug 6998662
   -- Added a new parameter assignment id.
   -- As of now, not being used, but since we added the data link,
   -- using this now.
   FUNCTION retrieve_missing_time_periods (
      p_resource_id   IN   NUMBER,
      p_assignment_id IN   NUMBER DEFAULT NULL,
      p_rownum        IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      --l_count      number;
      l_start_time    DATE;
      l_stop_time     DATE;
      l_resource_id   NUMBER;
   BEGIN
      g_debug := hr_utility.debug_enabled;

--if p_rownum <= g_time_periods.count then
      IF (    p_rownum <= g_time_periods.COUNT
          AND p_resource_id = g_time_periods (p_rownum - 1).resource_id
         )
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('retrieve_missing_time_periods', 10);
            hr_utility.TRACE ('p_rownum ' || p_rownum);
            --l_count      := p_count - p_rownum;
            hr_utility.TRACE (   'Start time '
                              || TO_CHAR
                                      (g_time_periods (p_rownum - 1).start_time,
                                       'dd/mm/yyyy'
                                      )
                             );
            hr_utility.TRACE (   'Stop time '
                              || TO_CHAR
                                       (g_time_periods (p_rownum - 1).stop_time,
                                        'dd/mm/yyyy'
                                       )
                             );
         END IF;

         l_start_time := TO_CHAR (g_time_periods (p_rownum - 1).start_time);
         l_stop_time := TO_CHAR (g_time_periods (p_rownum - 1).stop_time);
         l_resource_id := g_time_periods (p_rownum - 1).resource_id;
-- if g_debug then
--   for i in g_time_periods.first .. g_time_periods.last loop
--       hr_utility.set_location('retrieve_missing_time_periods', 160);
--       hr_utility.trace('i '|| i);
--       hr_utility.trace('Start time '
--          || to_char(g_time_periods(i).start_time, 'dd/mm/yyyy'));
--       hr_utility.trace('Stop time '
--          || to_char(g_time_periods(i).stop_time, 'dd/mm/yyyy'));
--   end loop;
--       hr_utility.trace('g_time_periods.count '|| g_time_periods.count);
-- end if;
         RETURN (l_start_time || l_stop_time || l_resource_id);
      ELSE
         IF g_debug
         THEN
            hr_utility.TRACE ('Passed values did not match, abt to delete the table.');
         END IF;

         IF g_time_periods.COUNT > 0
         THEN
            IF g_debug
            THEN
               hr_utility.set_location ('populate_missing_time_periods', 20);
            END IF;

            -- Bug 6998662
            -- Commented out the below loop -- when you are deleting,
            --  its pretty pointless to have the values NULLed out first.
            /*
            FOR i IN g_time_periods.FIRST .. g_time_periods.LAST
            LOOP
               g_time_periods (i).start_time := NULL;
               g_time_periods (i).stop_time := NULL;
               g_time_periods (i).resource_id := NULL;
            END LOOP;
            */

            IF g_debug
            THEN
               hr_utility.TRACE ('Deleted PL/SQL table');
            END IF;

            g_time_periods.DELETE;
         END IF;

         RETURN NULL;
      END IF;
   END retrieve_missing_time_periods;

   FUNCTION return_archived_status (p_date DATE)
      RETURN VARCHAR2
   IS
      CURSOR c_status
      IS
         SELECT 'Y'
           FROM hxc_data_sets
          WHERE status IN
                   ('OFF_LINE', 'BACKUP_IN_PROGRESS', 'RESTORE_IN_PROGRESS')
            AND TRUNC (p_date) BETWEEN start_date AND end_date;

      l_dummy   VARCHAR2 (1);
   BEGIN
      OPEN c_status;

      FETCH c_status
       INTO l_dummy;

      IF (c_status%FOUND)
      THEN
         CLOSE c_status;

         RETURN hr_bis.bis_decode_lookup ('YES_NO', 'Y');
      ELSE
         CLOSE c_status;

         RETURN hr_bis.bis_decode_lookup ('YES_NO', 'N');
      END IF;
   END return_archived_status;



   -- Bug 6998662
   -- All the below functions added for the above bug number.
   -- Originally logged for duplicate records issue for
   --   rehired employees with a name change, but also includes
   --   a complete preferences processing -- earlier, the report
   --   only looked at the SYSDATE's preferences.


   -- Sorts the nested table passed in, in the order of dates.

   PROCEDURE sort_pref_table( p_in_table  IN   MISTC_PREF_TABLE,
                              p_out_table OUT NOCOPY  MISTC_PREF_TABLE)
   IS

    TYPE DATE_ASSOC_ARRAY IS TABLE OF NUMBER INDEX BY VARCHAR2(10);

    temp_pref_table  MISTC_PREF_TABLE;
    temp_array       DATE_ASSOC_ARRAY;
    ind              NUMBER := 0;
    idx              VARCHAR2(10);

   BEGIN

      -- This is a tweak around algorithm to sort, but I am more
      -- than sure this works faster than any other sort algorithm
      -- implemented in plsql.  Read thru the comments inline.

      -- I have tableA of varchar2, indexed by number, which I want to sort.
      --   Create an associative array of type Number, indexed by Varchar2,
      --    Lets call this temp array.
      --   Loop thru tableA, and copy the index of tableA as the value of
      --    temp array, and the value as the index.
      --   Loop thru temp array from First to Last index -- this would come sorted.
      --    Assign tableA(temp array value) to a tableB.

      --  Now, tableB is a sorted copy of tableA.
      --  The same algorithm is followed in the below construct, only sorted
      --   for date in YYYYMMDD format.



      -- Copy the structure into a temporary table.
      temp_pref_table := p_in_table;
      -- Loop thru the table to sort.
      FOR i IN temp_pref_table.FIRST..temp_pref_table.LAST
      LOOP
         -- In the above temp assoc array, copy the index as the value
         --  and the value as the index. Watch out the format conversion.
         temp_array(TO_CHAR(temp_pref_table(i).start_date,'yyyymmdd')) :=
                     i;
      END LOOP;

      -- Loop thru the associative array.
      idx := temp_array.FIRST;
      LOOP
         ind := ind+1;
         -- Copy to out table, using the value from the temp array as the
         --  index of the original table..
         p_out_table(ind) := temp_pref_table(temp_array(idx));
         idx := temp_array.NEXT(idx);
         EXIT WHEN idx IS NULL;
      END LOOP;

      -- You have the sorted out table now.

   END sort_pref_table ;



   -- Just calls up procedure Load_preferences.
   -- This function is created to call from the report query,
   --  to load preferences.
   FUNCTION load_preferences( p_resource_id   IN NUMBER,
                              p_start_date    IN DATE,
                              p_stop_date     IN DATE )
   RETURN NUMBER
   IS

   BEGIN
          load_preferences(p_resource_id,
                           p_start_date,
                           p_stop_date );
          RETURN 1;
   END load_preferences;



   -- Loads preferences for the person passed for the given
   -- date range.
   PROCEDURE load_preferences( p_resource_id    IN NUMBER,
                               p_start_date     IN DATE,
                               p_stop_date      IN DATE )
   IS

   pref_table       hxc_preference_evaluation.t_pref_table;
   tc_req_table     MISTC_PREF_TABLE;
   appln_set_table  MISTC_PREF_TABLE;
   tc_idx           NUMBER := 0;
   app_idx          NUMBER := 0;


   -- Description on the data structures.

   -- We want a two dimensional table, but since that is not possible, we
   --  created a table of tables.
   --  g_mistc_pref_list is a table of tables.
   --   It has three members. -- resource_id
   --                            tcard_req_table
   --                            appln_set_table

   -- tcard_req_table and appln_set_table are both tables of
   --             resource_id
   --             start_date
   --             end_date
   --             attributelist.

   -- So effectively you are managing two tables for each resource.

   BEGIN

       -- Pick up all preferences, because if you pass the pref code,
       -- evaluation happens twice.
       hxc_preference_evaluation.resource_preferences(p_resource_id           => p_resource_id,
                                                      p_start_evaluation_date => p_start_date,
                                                      p_end_evaluation_date   => p_stop_date,
                                                      p_pref_table            => pref_table);

       IF pref_table.COUNT > 0
       THEN
          -- Loop thru the pref table, and find out only the required
          --  preferences.
          FOR i IN pref_table.FIRST..pref_table.LAST
          LOOP
             -- Timestore timecard required pref should be a collection of
             --  time recipients.  Copy the attributes to the table structure.
             IF pref_table(i).preference_code = 'TS_PER_TCARD_REQUIRED'
             THEN
                tc_idx := tc_idx + 1;
                tc_req_table(tc_idx).resource_id := p_resource_id ;
                tc_req_table(tc_idx).start_date := pref_table(i).start_date;
                tc_req_table(tc_idx).stop_date := pref_table(i).end_date;
                tc_req_table(tc_idx).attributelist :=
                      '-'||pref_table(i).attribute1||
                      '-'||pref_table(i).attribute2||
                      '-'||pref_table(i).attribute3||
                      '-'||pref_table(i).attribute4||
                      '-'||pref_table(i).attribute5||
                      '-'||pref_table(i).attribute6||
                      '-'||pref_table(i).attribute7||
                      '-'||pref_table(i).attribute8||
                      '-'||pref_table(i).attribute9||
                      '-'||pref_table(i).attribute10||
                      '-'||pref_table(i).attribute11||
                      '-'||pref_table(i).attribute12||
                      '-'||pref_table(i).attribute13||
                      '-'||pref_table(i).attribute14||
                      '-'||pref_table(i).attribute15||'-' ;
              -- Time store application set is just an application set id
              --  Copy this value into the table structure.
              ELSIF pref_table(i).preference_code = 'TS_PER_APPLICATION_SET'
              THEN
                 app_idx := app_idx + 1;
                 appln_set_table(app_idx).resource_id := p_resource_id ;
                 appln_set_table(app_idx).start_date  := pref_table(i).start_date;
                 appln_set_table(app_idx).stop_date  :=  pref_table(i).end_date;
                 appln_set_table(app_idx).attributelist  :=
                                                   pref_table(i).attribute1;
             END IF;
         END LOOP;

         -- Put up the values into the master table.
         g_mistc_pref_list(p_resource_id).resource_id := p_resource_id;

         -- Put the sorted pref values into the master table.for this resource.
         sort_pref_table(tc_req_table,g_mistc_pref_list(p_resource_id).tcard_req_table);
         sort_pref_table(appln_set_table,g_mistc_pref_list(p_resource_id).appln_set_table);
       END IF;
   END load_preferences;



   FUNCTION check_tc_required ( p_resource_id           IN NUMBER,
                                p_start_date      	IN DATE   DEFAULT NULL,
                                p_stop_date       	IN DATE   DEFAULT NULL,
                                p_evaluation_start_date IN DATE,
                                p_evaluation_stop_date  IN DATE,
                                p_time_rec_id           IN NUMBER )
   RETURN VARCHAR2
   IS

   BEGIN

        -- If the preference does not exist, load it.
        IF NOT g_mistc_pref_list.EXISTS(p_resource_id)
           AND p_start_date IS NOT NULL
           AND p_stop_date IS NOT NULL
        THEN
           load_preferences(p_resource_id,
                            p_start_date,
                            p_stop_date) ;
        END IF;

        -- Loop thru the preference values.
        FOR i IN g_mistc_pref_list(p_resource_id).tcard_req_table.FIRST..
                         g_mistc_pref_list(p_resource_id).tcard_req_table.LAST
        LOOP
           -- Are there any more values ?? If yes go to the one where the given
           --  range fits in .
           IF g_mistc_pref_list(p_resource_id).tcard_req_table.EXISTS(i+1)
           THEN
               -- The below condition would stop where the ranges coincide.
               IF g_mistc_pref_list(p_resource_id).tcard_req_table(i+1).start_date
                                > p_evaluation_start_date
                AND  g_mistc_pref_list(p_resource_id).tcard_req_table(i).start_date
                               <= p_evaluation_start_date
               THEN
                   -- If the given time recipient id is in the list, return N
                   --  Else Y.
                   IF INSTR(g_mistc_pref_list(p_resource_id).tcard_req_table(i).attributelist,
                               '-'||p_time_rec_id||'-') <> 0
                   THEN
                      RETURN 'N';
                   ELSE
                      RETURN 'Y' ;
                   END IF;
               ELSIF g_mistc_pref_list(p_resource_id).tcard_req_table(i).start_date
                      <= p_evaluation_stop_date
                 AND g_mistc_pref_list(p_resource_id).tcard_req_table(i+1).start_date
                                > p_evaluation_start_date
               THEN
                   -- If the given time recipient id is in the list, return N
                   --  Else Y.
                   IF INSTR(g_mistc_pref_list(p_resource_id).tcard_req_table(i).attributelist,
                               '-'||p_time_rec_id||'-') <> 0
                   THEN
                      RETURN 'N';
                   ELSE
                      RETURN 'Y' ;
                   END IF;
               ELSE
                  NULL;
               END IF;
           -- If there are no multiple ranges to check against, check if the date
           -- falls in here.
           ELSIF g_mistc_pref_list(p_resource_id).tcard_req_table(i).start_date
                           <= p_evaluation_start_date
              OR g_mistc_pref_list(p_resource_id).tcard_req_table(i).start_date
                           <= p_evaluation_start_date
           THEN
                   -- Check if the time recipient exists here.
                   IF INSTR(g_mistc_pref_list(p_resource_id).tcard_req_table(i).attributelist,
                               '-'||p_time_rec_id||'-') <> 0
                   THEN
                      RETURN 'N';
                   ELSE
                      RETURN 'Y' ;
                   END IF;
            ELSE
                  -- The pref range is completely outside the given range, so
                  --  return Y anyway.
                  RETURN 'Y';
            END IF;
         END LOOP;

   END check_tc_required;



   FUNCTION check_appln_set ( p_resource_id           IN NUMBER,
                              p_start_date            IN DATE  DEFAULT NULL,
                              p_stop_date             IN DATE  DEFAULT NULL,
                              p_evaluation_start_date IN DATE,
                              p_evaluation_stop_date  IN DATE )
   RETURN varchar2
   IS
   BEGIN

        -- If the preference does not exist, load it.
        IF NOT g_mistc_pref_list.EXISTS(p_resource_id)
           AND p_start_date IS NOT NULL
           AND p_stop_date IS NOT NULL
        THEN
           load_preferences(p_resource_id,
                            p_start_date,
                            p_stop_date) ;
        END IF;

        -- Loop thru the table and find out if the preference matches.
        FOR i IN g_mistc_pref_list(p_resource_id).appln_set_table.FIRST..
                         g_mistc_pref_list(p_resource_id).appln_set_table.LAST
        LOOP
           IF g_mistc_pref_list(p_resource_id).appln_set_table.EXISTS(i+1)
           THEN
               IF g_mistc_pref_list(p_resource_id).appln_set_table(i+1).start_date
                                > p_evaluation_start_date
                  AND  g_mistc_pref_list(p_resource_id).appln_set_table(i).start_date
                               <= p_evaluation_start_date
               THEN
                      RETURN NVL(g_mistc_pref_list(p_resource_id).appln_set_table(i).attributelist,'0');

               ELSIF g_mistc_pref_list(p_resource_id).appln_set_table(i).start_date
                      <= p_evaluation_stop_date
                    AND g_mistc_pref_list(p_resource_id).appln_set_table(i+1).start_date
                                > p_evaluation_stop_date
               THEN
                   RETURN NVL(g_mistc_pref_list(p_resource_id).appln_set_table(i).attributelist,'0');

               ELSE
                  NULL;

               END IF;

           ELSIF g_mistc_pref_list(p_resource_id).appln_set_table(i).start_date
                           <= p_evaluation_start_date
                   OR g_mistc_pref_list(p_resource_id).appln_set_table(i).start_date
                           <= p_evaluation_stop_date
           THEN
                      RETURN NVL(g_mistc_pref_list(p_resource_id).appln_set_table(i).attributelist,'0');

           ELSE
                      RETURN 0;

           END IF;

         END LOOP;

     END check_appln_set;


     PROCEDURE clear_global_tables
     IS

     BEGIN
          g_mistc_pref_list.DELETE;
          g_time_periods.DELETE;
     END clear_global_tables;




     -- Function returns a Yes if the application set is ever
     --  in the person's preference.
     FUNCTION check_appln_set_id (p_resource_id     IN NUMBER,
                                  p_start_date      IN DATE,
                                  p_stop_date       IN DATE,
                                  p_appln_set_id    IN NUMBER )
     RETURN VARCHAR2
     IS

      BEGIN

          IF NOT g_mistc_pref_list.EXISTS(p_resource_id)
             AND p_start_date IS NOT NULL
             AND p_stop_date  IS NOT NULL
          THEN
             load_preferences(p_resource_id,
                              p_start_date,
                              p_stop_date) ;
          END IF;

          -- Loop thru the preferences and find out if you ever
          --  have the given application set id, for any date range.
          -- Used the report queries.
          FOR i IN g_mistc_pref_list(p_resource_id).appln_set_table.FIRST..
                           g_mistc_pref_list(p_resource_id).appln_set_table.LAST
          LOOP
             IF g_mistc_pref_list(p_resource_id).appln_set_table(i).attributelist
                                     = to_char(p_appln_set_id)
             THEN
                 RETURN 'Y';
             END IF;
          END LOOP;

          RETURN 'N';
      END ;


-- Returns a full name for the given date, no big deal.
FUNCTION get_full_name(p_resource_id     IN NUMBER,
                       p_date            IN DATE )
RETURN VARCHAR2
IS

 l_full_name varchar2(255);
BEGIN
    SELECT full_name
      INTO l_full_name
      FROM per_all_people_f ppf
    WHERE person_id = p_resource_id
      AND p_date BETWEEN effective_start_date
                     AND effective_end_date;

   RETURN l_full_name;

END;


-- Calls hr_person_type_usage_info.get_user_person_type.
-- Just a wrapper function, because it threw errors in the report
-- queries because of the length.
FUNCTION person_type(p_date        IN DATE,
                     p_resource_id IN NUMBER)
RETURN VARCHAR2
IS

BEGIN

    RETURN hr_person_type_usage_info.get_user_person_type(p_date,p_resource_id);

END person_type;


END hxc_tpd_end;

/
