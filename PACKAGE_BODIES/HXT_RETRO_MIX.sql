--------------------------------------------------------
--  DDL for Package Body HXT_RETRO_MIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_RETRO_MIX" AS
/* $Header: hxtrmix.pkb 120.7.12010000.6 2010/04/15 10:06:44 asrajago ship $ */

/* Outline for retro processing:

   There are two kinds of detail rows
       - hours rows
       - amount rows.

   Step 1: Loop thru each hour detail row that is effective today.
           For every row found, look for a previous version of the row with
           pay_status='C'.
           Compare the hours.
               if old.hours = new.hours  then do nothing.
               if old.hours <> new.hours then
                    send to paymix an adjustment row of
                       new.hours - old.hours
   Step 2: Loop thru each amount detail row that is effective today.
           For every row found, look for a previous version of the row with
           pay_status='C'.
           Compare the amounts.
               if old.amount = new.amount  then do nothing.
               if old.amount <> new.amount then
                    send to paymix an adjustment row of
                       new.amount - old.amount
   Step 3/4. We want to have only one set of rows with pay_status='C'.  After
             retro processing is complete (2 more steps), the retro_rows will
             be marked to 'C', so we need to mark the previous rows to show
             how they became adjusted, backed out nocopy or replaced.

             First, update previous detail pay_status='A' (adjusted if there
               exists a current version of the row where only the
               hours/amount are different.
             Second, update previous detail pay_status='D'(dead) if there exists
               a current version of the row where the hours/amount are equal.
             Third, for any detail rows where pay_status='C' and the row
               is expired, send backout transaction to PayMIX.

   Step 5.   Set rows on timecard to pay_status='C' if pay_status='R'.
*/
   g_debug boolean := hr_utility.debug_enabled;

   PROCEDURE mark_prev_hours_rows (p_tim_id IN NUMBER);

   PROCEDURE mark_prev_amount_rows (p_tim_id IN NUMBER);

   PROCEDURE back_out_leftover_hours (p_batch_id NUMBER, p_tim_id NUMBER);

   PROCEDURE back_out_leftover_amount (p_batch_id NUMBER, p_tim_id NUMBER);

   PROCEDURE mark_retro_rows_complete (p_tim_id NUMBER);

   g_lookup_not_found        EXCEPTION; --GLOBAL
   g_error_ins_batch_lines   EXCEPTION; --SIR517 PWM 18FEB00


--
-- This function created to get the lookup_code for translated input-value names
--
   FUNCTION get_lookup_code (p_meaning IN VARCHAR2, p_date_active IN DATE)
      RETURN VARCHAR2
   IS
      l_lookup_code   hr_lookups.lookup_code%TYPE;

      CURSOR get_lookup_code_cur
      IS
         SELECT lookup_code
           FROM hr_lookups
          WHERE meaning = p_meaning
            AND lookup_type = 'NAME_TRANSLATIONS'
            AND enabled_flag = 'Y'
            AND p_date_active BETWEEN NVL (start_date_active, p_date_active)
                                  AND NVL (end_date_active, p_date_active);
   BEGIN
      hxt_util.DEBUG (
            'get_lookup_ code  for meaning = '
         || p_meaning
         || ' type = '
         || 'NAME_TRANSLATIONS'
         || ' date = '
         || fnd_date.date_to_chardate (p_date_active)
      ); --FORMS60 --HXT115

      IF p_meaning IS NOT NULL
      THEN
         OPEN get_lookup_code_cur;
         FETCH get_lookup_code_cur INTO l_lookup_code;

         IF get_lookup_code_cur%NOTFOUND
         THEN

--      FND_MESSAGE.SET_NAME('HXT','HXT_39483_LOOKUP_NOT_FOUND');
--      FND_MESSAGE.SET_TOKEN('CODE', p_meaning);           --SIR517 PWM 18FEB00
--      FND_MESSAGE.SET_TOKEN('TYPE', 'NAME_TRANSLATIONS'); --SIR517 PWM 18FEB00
--      RAISE g_lookup_not_found;
            NULL; -- This is to fix bug 1761779.  Fassadi 16-may-2001
         END IF;
      ELSE
         l_lookup_code := p_meaning;
      END IF;

      RETURN l_lookup_code;
   END get_lookup_code;


--BEGIN GLOBAL
   FUNCTION convert_lookup (
      p_lookup_code   IN   VARCHAR2,
      p_lookup_type   IN   VARCHAR2,
      p_date_active   IN   DATE
   )
      RETURN VARCHAR2
   IS
      l_meaning   hr_lookups.meaning%TYPE;

      CURSOR get_meaning_cur (p_code VARCHAR2, p_type VARCHAR2, p_date DATE)
      IS
         SELECT fcl.meaning
           FROM hr_lookups fcl --FORMS60
          WHERE fcl.lookup_code = p_code
            AND fcl.lookup_type = p_type
            AND fcl.enabled_flag = 'Y'
            AND p_date BETWEEN NVL (fcl.start_date_active, p_date)
                           AND NVL (fcl.end_date_active, p_date);
   BEGIN
      hxt_util.DEBUG (
            'convert_lookup - code = '
         || p_lookup_code
         || ' type = '
         || p_lookup_type
         || ' date = '
         || fnd_date.date_to_chardate (p_date_active)
      ); --FORMS60 --HXT115

      -- Bug 8888777
      -- Added the below condition to restrict IV conversion to
      -- display value.
      IF  p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL
      AND hxt_batch_process.g_IV_format = 'N'
      THEN
         OPEN get_meaning_cur (p_lookup_code, p_lookup_type, p_date_active);
         FETCH get_meaning_cur INTO l_meaning;

         IF get_meaning_cur%NOTFOUND
         THEN
            fnd_message.set_name ('HXT', 'HXT_39483_LOOKUP_NOT_FOUND');
            fnd_message.set_token ('CODE', p_lookup_code);
            fnd_message.set_token ('TYPE', p_lookup_type);
            RAISE g_lookup_not_found;
         END IF;
      ELSE
         l_meaning := p_lookup_code;
      END IF;

      RETURN l_meaning;
   END convert_lookup;

   PROCEDURE insert_pay_batch_lines (
      p_batch_id                     NUMBER,
      p_batch_line_id               OUT NOCOPY  NUMBER,
      p_assignment_id                NUMBER,
      p_assignment_number            VARCHAR2,
      p_amount                       NUMBER,
      p_cost_allocation_keyflex_id   NUMBER,
      p_concatenated_segments        VARCHAR2,
      p_segment1                     VARCHAR2,
      p_segment2                     VARCHAR2,
      p_segment3                     VARCHAR2,
      p_segment4                     VARCHAR2,
      p_segment5                     VARCHAR2,
      p_segment6                     VARCHAR2,
      p_segment7                     VARCHAR2,
      p_segment8                     VARCHAR2,
      p_segment9                     VARCHAR2,
      p_segment10                    VARCHAR2,
      p_segment11                    VARCHAR2,
      p_segment12                    VARCHAR2,
      p_segment13                    VARCHAR2,
      p_segment14                    VARCHAR2,
      p_segment15                    VARCHAR2,
      p_segment16                    VARCHAR2,
      p_segment17                    VARCHAR2,
      p_segment18                    VARCHAR2,
      p_segment19                    VARCHAR2,
      p_segment20                    VARCHAR2,
      p_segment21                    VARCHAR2,
      p_segment22                    VARCHAR2,
      p_segment23                    VARCHAR2,
      p_segment24                    VARCHAR2,
      p_segment25                    VARCHAR2,
      p_segment26                    VARCHAR2,
      p_segment27                    VARCHAR2,
      p_segment28                    VARCHAR2,
      p_segment29                    VARCHAR2,
      p_segment30                    VARCHAR2,
      p_element_type_id              NUMBER,
      p_element_name                 VARCHAR2,
      p_hourly_rate                  NUMBER,
      p_locality_worked              VARCHAR2,
      p_rate_code                    VARCHAR2,
      p_rate_multiple                NUMBER,
      p_separate_check_flag          VARCHAR2,
      p_tax_separately_flag          VARCHAR2,
      p_hours                        NUMBER,
      p_date_worked                  DATE,
      p_reason                       VARCHAR2,
      p_batch_sequence               NUMBER,
      p_state_name                   VARCHAR2 default null,  --dd
      p_county_name                 VARCHAR2 default null,
      p_city_name                   VARCHAR2 default null,
      p_zip_code                    varchar2 default null,
      p_parent_id                   NUMBER default 0
   )
   IS
   -- l_batch_sequence   NUMBER;
      l_return           NUMBER; --SIR517 PWM 18FEB00
      l_batch_line_id number;
	l_batch_line_ovn number;

      TYPE input_value_record IS RECORD (
         SEQUENCE                      pay_input_values_f.input_value_id%TYPE,
         NAME                          pay_input_values_f_tl.NAME%TYPE, --FORMS60
         lookup                        pay_input_values_f.lookup_type%TYPE);

      TYPE input_values_table IS TABLE OF input_value_record
         INDEX BY BINARY_INTEGER;

      hxt_value          input_values_table;

      TYPE pbl_values_table IS TABLE OF pay_batch_lines.value_1%TYPE
         INDEX BY BINARY_INTEGER;

      pbl_value          pbl_values_table;
      l_value_meaning    hr_lookups.meaning%TYPE;

      CURSOR c_date_input_value (
         cp_element_type_id   NUMBER,
         cp_assignment_id     NUMBER,
         cp_effective_date    DATE
      )
      IS
         SELECT DISTINCT piv.NAME -- PIV.display_sequence
                    FROM --pay_element_types_f PET
                         pay_input_values_f piv,
                         pay_accrual_plans pap,
                         pay_net_calculation_rules pncr
                   WHERE --PET.element_type_id      = cp_element_type_id

-- AND    PET.element_type_id      = PIV.element_type_id
                         piv.element_type_id = cp_element_type_id
                     AND cp_effective_date BETWEEN piv.effective_start_date
                                               AND piv.effective_end_date
                     AND pncr.date_input_value_id = piv.input_value_id
                     AND pncr.input_value_id <> pap.pto_input_value_id
                     AND pncr.input_value_id <> pap.co_input_value_id
                     AND pncr.accrual_plan_id = pap.accrual_plan_id
                     AND pap.accrual_plan_id IN
                               (SELECT papl.accrual_plan_id
                                  FROM pay_accrual_plans papl,
                                       pay_element_links_f pel,
                                       pay_element_entries_f pee
                                 WHERE pel.element_type_id =
                                            papl.accrual_plan_element_type_id
                                   AND cp_effective_date
                                          BETWEEN pel.effective_start_date
                                              AND pel.effective_end_date
                                   AND pee.element_link_id =
                                                          pel.element_link_id
                                   AND pee.assignment_id = cp_assignment_id
                                   AND cp_effective_date
                                          BETWEEN pee.effective_start_date
                                              AND pee.effective_end_date);

      l_piv_name         VARCHAR2 (30);
      lv_pbl_flag        VARCHAR2 (1)              := 'N';
   BEGIN

      if g_debug then
      	    hr_utility.set_location ('insert_pay_batch_lines', 10);
      end if;

      -- Initialize tables
      FOR i IN 1 .. 15
      LOOP
         hxt_value (i).SEQUENCE := NULL;
         hxt_value (i).NAME := NULL;
         hxt_value (i).lookup := NULL;
         pbl_value (i) := NULL;
      END LOOP;

      -- Get input values details for this element
      pay_paywsqee_pkg.get_input_value_details (
         p_element_type_id,
         p_date_worked,
         hxt_value (1).SEQUENCE,
         hxt_value (2).SEQUENCE,
         hxt_value (3).SEQUENCE,
         hxt_value (4).SEQUENCE,
         hxt_value (5).SEQUENCE,
         hxt_value (6).SEQUENCE,
         hxt_value (7).SEQUENCE,
         hxt_value (8).SEQUENCE,
         hxt_value (9).SEQUENCE,
         hxt_value (10).SEQUENCE,
         hxt_value (11).SEQUENCE,
         hxt_value (12).SEQUENCE,
         hxt_value (13).SEQUENCE,
         hxt_value (14).SEQUENCE,
         hxt_value (15).SEQUENCE,
         hxt_value (1).NAME,
         hxt_value (2).NAME,
         hxt_value (3).NAME,
         hxt_value (4).NAME,
         hxt_value (5).NAME,
         hxt_value (6).NAME,
         hxt_value (7).NAME,
         hxt_value (8).NAME,
         hxt_value (9).NAME,
         hxt_value (10).NAME,
         hxt_value (11).NAME,
         hxt_value (12).NAME,
         hxt_value (13).NAME,
         hxt_value (14).NAME,
         hxt_value (15).NAME,
         hxt_value (1).lookup,
         hxt_value (2).lookup,
         hxt_value (3).lookup,
         hxt_value (4).lookup,
         hxt_value (5).lookup,
         hxt_value (6).lookup,
         hxt_value (7).lookup,
         hxt_value (8).lookup,
         hxt_value (9).lookup,
         hxt_value (10).lookup,
         hxt_value (11).lookup,
         hxt_value (12).lookup,
         hxt_value (13).lookup,
         hxt_value (14).lookup,
         hxt_value (15).lookup
      );
      if g_debug then
      	    hr_utility.set_location ('insert_pay_batch_lines', 20);
      end if;
      -- Place OTM data into BEE values per input values
      hxt_util.DEBUG ('Putting OTM data into BEE values per input values'); --HXT115


--
-- In order to get the input-value logic work in diiferent legislations we need
-- to create (SEED) new lookups for 'Hours', 'Hourly Rate', 'Rate Multiple',
-- and 'Rate Code' with lookup_type of 'NAME_TRANSLATION' and lookup_code of
-- 'HOURS', 'HOURLY_RATE', 'RATE_MULTIPLE' and 'RATE_CODE' respectively.
-- Then the customers in different countries need to create the above input
-- values with the name which is directly translated from the above names for
-- OTM elements.
--
-- For example: In French the user must create an input value for 'Hours' to
-- be 'Heures' and then to determine which input value 'Heures' is associated
-- with we look at the hr_lookups and if we find an entry with lookup_type =
-- 'NAME_TRANSLATIONS' and lookup_code = 'HOURS' and Meaning to be 'Heures'
-- then we know that this input vale woul map to 'Hours'.
--
-- What need to be noted that it is the customer's responsibilty to create
-- input values which are the direct translation of 'Hours','Hourly Rate',
-- 'Pay Value' , 'Rate Multiple' and 'Rate Code'
--
      FOR i IN 1 .. 15
      LOOP

--
-- We need to get the lookup_code for the input_value names before processing
-- the further logic on the screen value for the input values.
--
         lv_pbl_flag := 'N';
          if g_debug then
         	 hr_utility.set_location ('insert_pay_batch_lines', 30);

		 hr_utility.TRACE (
		       'hxt_value_name_'
		    || TO_CHAR (i)
		    || ' :'
		    || hxt_value (i).NAME
		 );
		 hr_utility.TRACE (   'p_date_worked:'
				   || p_date_worked);
          end if;
		 l_value_meaning :=
				  get_lookup_code (hxt_value (i).NAME, p_date_worked);
          if g_debug then
		 hr_utility.TRACE (   'l_value_meaning :'
				   || l_value_meaning);
          end if;
         --if hxt_value(i).name = 'Hours' then
         IF l_value_meaning = 'HOURS'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 40);
            end if;
            pbl_value (i) :=
                convert_lookup (p_hours, hxt_value (i).lookup, p_date_worked);
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
            end if;
         --elsif hxt_value(i).name = 'Pay Value' then
         ELSIF l_value_meaning = 'AMOUNT'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 50);
            end if;
            pbl_value (i) :=
               convert_lookup (p_amount, hxt_value (i).lookup, p_date_worked);
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
            end if;
         --elsif hxt_value(i).name = 'Multiple' then
         ELSIF l_value_meaning = 'RATE_MULTIPLE'
         THEN
            if g_debug then
             	   hr_utility.set_location ('insert_pay_batch_lines', 60);
            end if;
            pbl_value (i) := convert_lookup (
                                p_rate_multiple,
                                hxt_value (i).lookup,
                                p_date_worked
                             );

            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
	    end if;

         ELSIF l_value_meaning = 'HOURLY_RATE'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 70);
            end if;
            pbl_value (i) := convert_lookup (
                                p_hourly_rate,
                                hxt_value (i).lookup,
                                p_date_worked
                             );
	    if g_debug then

	            hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
            end if;


         --elsif hxt_value(i).name = 'Rate' then
         ELSIF l_value_meaning = 'RATE'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 70);
            end if;
            pbl_value (i) := convert_lookup (
                                p_hourly_rate,
                                hxt_value (i).lookup,
                                p_date_worked
                             );
	    if g_debug then

	            hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
	    end if;
         --elsif hxt_value(i).name = 'Rate Code' then
         ELSIF l_value_meaning = 'RATE_CODE'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 80);
            end if;
            pbl_value (i) := convert_lookup (
                                p_rate_code,
                                hxt_value (i).lookup,
                                p_date_worked
                             );
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
            end if;

-- BEGIN US localization
         ELSIF hxt_value (i).NAME = 'Jurisdiction'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 90);
            end if;

    if(p_state_name is not null or
	         p_county_name is not null or
		 p_city_name is not null or
		 p_zip_code is not null) then
   pbl_value(i):=convert_lookup(pay_ac_utility.get_geocode(p_state_name,
							  p_county_name,
							  p_city_name,
							  p_zip_code),
				hxt_value(i).lookup,
				p_date_worked);
    else
    pbl_value (i) := convert_lookup (
                                p_locality_worked,
                                hxt_value (i).lookup,
                                p_date_worked
                             );
    end if;
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
	    end if;
         ELSIF hxt_value (i).NAME = 'Deduction Processing'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 100);
            end if;
            pbl_value (i) := convert_lookup (
                                p_tax_separately_flag,
                                hxt_value (i).lookup,
                                p_date_worked
                             );
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
            end if;
         ELSIF hxt_value (i).NAME = 'Separate Check'
         THEN
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 110);
            end if;
            pbl_value (i) := convert_lookup (
                                p_separate_check_flag,
                                hxt_value (i).lookup,
                                p_date_worked
                             );
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
	    end if;

-- END US localization

         ELSIF hxt_value (i).NAME IS NOT NULL
         THEN -- pbl_value(i) := NULL;
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 120);
                   hr_utility.TRACE (   'p_element_type_id :'
                                     || p_element_type_id);
                   hr_utility.TRACE (   'p_assignment_id   :'
                                     || p_assignment_id);
             	   hr_utility.TRACE (   'p_date_worked     :'
                                     || p_date_worked);
            end if;
            OPEN c_date_input_value (
               p_element_type_id,
               p_assignment_id,
               p_date_worked
            );

            LOOP
               if g_debug then
               	      hr_utility.set_location ('insert_pay_batch_lines', 130);
               	end if;
               FETCH c_date_input_value INTO l_piv_name;
               EXIT WHEN c_date_input_value%NOTFOUND;
               if g_debug then
               	      hr_utility.TRACE (   'l_piv_name  :'
                                        || l_piv_name);
                      hr_utility.TRACE (   'lv_pbl_flag :'
                                        || lv_pbl_flag);
               end if;

               IF l_piv_name = hxt_value (i).NAME
               THEN
                  if g_debug then
                  	 hr_utility.set_location ('insert_pay_batch_lines', 140);
                  end if;
                  --pbl_value(i) := to_char(p_date_worked,'DD-MON-YYYY');
                  pbl_value (i) := fnd_date.date_to_canonical (p_date_worked);
                  lv_pbl_flag := 'Y';
                  if g_debug then
			  hr_utility.TRACE (
				'pbl_value_'
			     || TO_CHAR (i)
			     || ' :'
			     || pbl_value (i)
			  );
		  end if;
                  EXIT;
               END IF;
            END LOOP;

            CLOSE c_date_input_value;

            -- Bug 8888777
      	    -- Control is here means that no fixed input value is encountered, but
      	    -- still some IV with a Non NULL name. Convert this and copy it.

      	    IF g_debug
      	      AND g_xiv_table.EXISTS(p_parent_id)
      	    THEN
      	        hr_utility.trace('IV : It came out here ');
      	        hr_utility.trace('IV : i = '||i);
      	        hr_utility.trace('IV : '||g_xiv_table(p_parent_id).attribute1);
      	    END IF;

      	    IF g_xiv_table.EXISTS(p_parent_id)
      	    THEN

      	       IF i = 1
      	       THEN pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute1,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  2
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute2,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  3
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute3,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  4
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute4,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  5
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute5,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  6
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute6,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  7
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute7,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  8
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute8,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i =  9
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute9,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i = 10
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute10,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i = 11
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute11,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i = 12
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute12,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i = 13
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute13,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i = 14
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute14,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       ELSIF i = 15
      	       THEN
      	             pbl_value(i) := convert_lookup(g_xiv_table(p_parent_id).attribute15,
      	                                            hxt_value (i).lookup,
      	                                            p_date_worked);
      	                   lv_pbl_flag := 'Y';
      	       END IF;
      	    END IF;


            IF lv_pbl_flag = 'N'
            THEN
               if g_debug then
               	      hr_utility.set_location ('insert_pay_batch_lines', 150);
               end if;
               pbl_value (i) := NULL;
               if g_debug then
		       hr_utility.TRACE (
			     'pbl_value_'
			  || TO_CHAR (i)
			  || ' :'
			  || pbl_value (i)
		       );
	       end if;
            END IF;

            if g_debug then
            	    hr_utility.TRACE (   'lv_pbl_flag :'
                                      || lv_pbl_flag);
            end if;
         ELSE
            if g_debug then
            	   hr_utility.set_location ('insert_pay_batch_lines', 160);
             end if;
            pbl_value (i) := NULL;
            if g_debug then
		    hr_utility.TRACE (
			  'pbl_value_'
		       || TO_CHAR (i)
		       || ' :'
		       || pbl_value (i)
		    );
	    end if;
         END IF;

         if g_debug then
         	hr_utility.set_location ('insert_pay_batch_lines', 170);
         end if;
         hxt_util.DEBUG (   'value_'
                         || TO_CHAR (i)
                         || ' = '
                         || pbl_value (i)); --HXT115
      END LOOP;

      -- Get next sequence number
      -- l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence (p_batch_id);
      hxt_util.DEBUG (   'batch_sequence = '
                      || TO_CHAR (p_batch_sequence)); --HXT115

      -- Add new hours data
PAY_BATCH_ELEMENT_ENTRY_API.create_batch_line
	  (p_session_date                  => sysdate
	  ,p_batch_id                      => p_batch_id
	  ,p_batch_line_status             => 'U'
	  ,p_assignment_id                 => p_assignment_id
	  ,p_assignment_number             => p_assignment_number
	  ,p_date_earned                   => p_date_worked
	  ,p_batch_sequence                => p_batch_sequence
	  ,p_concatenated_segments         => p_concatenated_segments
	  ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
	  ,p_effective_date                => p_date_worked
	  ,p_element_name                  => p_element_name
	  ,p_element_type_id               => p_element_type_id
	  ,p_entry_type                    => 'E'
	  ,p_reason                        => p_reason
	  ,p_segment1                      => p_segment1
	  ,p_segment2                      => p_segment2
	  ,p_segment3                      => p_segment3
	  ,p_segment4                      => p_segment4
	  ,p_segment5                      => p_segment5
	  ,p_segment6                      => p_segment6
	  ,p_segment7                      => p_segment7
	  ,p_segment8                      => p_segment8
	  ,p_segment9                      => p_segment9
	  ,p_segment10                     => p_segment10
	  ,p_segment11                     => p_segment11
	  ,p_segment12                     => p_segment12
	  ,p_segment13                     => p_segment13
	  ,p_segment14                     => p_segment14
	  ,p_segment15                     => p_segment15
	  ,p_segment16                     => p_segment16
	  ,p_segment17                     => p_segment17
	  ,p_segment18                     => p_segment18
	  ,p_segment19                     => p_segment19
	  ,p_segment20                     => p_segment20
	  ,p_segment21                     => p_segment21
	  ,p_segment22                     => p_segment22
	  ,p_segment23                     => p_segment23
	  ,p_segment24                     => p_segment24
	  ,p_segment25                     => p_segment25
	  ,p_segment26                     => p_segment26
	  ,p_segment27                     => p_segment27
	  ,p_segment28                     => p_segment28
	  ,p_segment29                     => p_segment29
	  ,p_segment30                     => p_segment30
	  ,p_value_1                       => pbl_value(1)
	  ,p_value_2                       => pbl_value(2)
	  ,p_value_3                       => pbl_value(3)
	  ,p_value_4                       => pbl_value(4)
	  ,p_value_5                       => pbl_value(5)
	  ,p_value_6                       => pbl_value(6)
	  ,p_value_7                       => pbl_value(7)
	  ,p_value_8                       => pbl_value(8)
	  ,p_value_9                       => pbl_value(9)
	  ,p_value_10                      => pbl_value(10)
	  ,p_value_11                      => pbl_value(11)
	  ,p_value_12                      => pbl_value(12)
	  ,p_value_13                      => pbl_value(13)
	  ,p_value_14                      => pbl_value(14)
	  ,p_value_15                      => pbl_value(15)
	  ,p_batch_line_id                 => l_batch_line_id
	  ,p_object_version_number         => l_batch_line_ovn
	  ,p_iv_all_internal_format        => hxt_batch_process.g_IV_format -- Bug 9156092
	  );

      p_batch_line_id  := l_batch_line_id;
   EXCEPTION
      WHEN g_lookup_not_found
      THEN
         hxt_util.DEBUG (
            'Oops...g_lookup_not_found in insert_pay_batch_lines'
         ); --HXT115
         RAISE g_lookup_not_found; --SIR517 PWM 18FEB00 Re-raise the exception for the calling procedure
      WHEN OTHERS
      THEN
         hxt_util.DEBUG (SQLERRM); --HXT115
         hxt_util.DEBUG ('Oops...others in insert_pay_batch_lines'); --HXT115
         fnd_message.set_name ('HXT', 'HXT_39354_ERR_INS_PAYMX_INFO');
         fnd_message.set_token ('SQLERR', SQLERRM);
         RAISE g_error_ins_batch_lines; --SIR517 PWM 18FEB00 Re-raise the exception for the calling procedure
   END insert_pay_batch_lines;


--END GLOBAL

   PROCEDURE retro_sum_to_mix (
      p_batch_id      IN              NUMBER,
      p_tim_id        IN              NUMBER,
      p_sum_retcode   OUT NOCOPY      NUMBER,
      p_err_buf       OUT NOCOPY      VARCHAR2
   )
   IS

      -- Bug 8888777
      -- Added this cursor to pick up input values from
      -- the summary table.
      CURSOR get_input_values(p_id IN NUMBER)
          IS SELECT
                   attribute1,
		   attribute2,
		   attribute3,
		   attribute4,
		   attribute5,
		   attribute6,
		   attribute7,
		   attribute8,
		   attribute9,
		   attribute10,
		   attribute11,
		   attribute12,
		   attribute13,
		   attribute14,
		   attribute15
              FROM hxt_sum_hours_worked_x
             WHERE id = p_id;


-- select current hours by detail where hours<>0 and amount=0
      CURSOR current_hours (p_tim_id NUMBER)
      IS
         SELECT   asm.assignment_number, elt.element_name, --FORMS60
                  eltv.hxt_premium_type, --SIR65
                                        eltv.hxt_premium_amount, --SIR65
                  eltv.hxt_earning_category, --SIR65
                  DECODE (
                     SIGN (
                          DECODE (
                             SIGN (
                                  ptp.start_date
                                - asm.effective_start_date
                             ),
                             1, ptp.start_date,
                             asm.effective_start_date
                          )
                        - elt.effective_start_date
                     ),
                     1, DECODE (
                           SIGN (  ptp.start_date
                                 - asm.effective_start_date),
                           1, ptp.start_date,
                           asm.effective_start_date
                        ),
                     elt.effective_start_date
                  )
                        from_date,
                  DECODE (
                     SIGN (
                          DECODE (
                             SIGN (  ptp.end_date
                                   - asm.effective_end_date),
                             -1, ptp.end_date,
                             asm.effective_end_date
                          )
                        - elt.effective_end_date
                     ),
                     -1, DECODE (
                            SIGN (  ptp.end_date
                                  - asm.effective_end_date),
                            -1, ptp.end_date,
                            asm.effective_end_date
                         ),
                     elt.effective_end_date
                  ) TO_DATE,
                  hrw.rate_multiple, hrw.hourly_rate,


                  loct.location_code locality_worked, --FORMS60
                  ffvr.flex_value rate_code, hrw.separate_check_flag,
                  hrw.fcl_tax_rule_code tax_separately_flag, hrw.amount,
                  hrw.hours hours_worked, hrw.assignment_id,
                  /* fk - assignment_number */
                  hrw.ffv_cost_center_id, /* fk - cost_center_code */ pcak.concatenated_segments,
                  pcak.segment1, pcak.segment2, pcak.segment3, pcak.segment4,
                  pcak.segment5, pcak.segment6, pcak.segment7, pcak.segment8,
                  pcak.segment9, pcak.segment10, pcak.segment11,
                  pcak.segment12, pcak.segment13, pcak.segment14,
                  pcak.segment15, pcak.segment16, pcak.segment17,
                  pcak.segment18, pcak.segment19, pcak.segment20,
                  pcak.segment21, pcak.segment22, pcak.segment23,
                  pcak.segment24, pcak.segment25, pcak.segment26,
                  pcak.segment27, pcak.segment28, pcak.segment29,
                  pcak.segment30, hrw.element_type_id,
                  hrw.location_id,
                  hrw.ffv_rate_code_id,
                  asm.effective_end_date asm_effective_end_date,
                  elt.effective_end_date elt_effective_end_date,
                  hrw.parent_id, hrw.ROWID hrw_rowid, -- OHM180
                  hcl.meaning reason, --GLOBAL
                  hrw.date_worked,  ptp.time_period_id,
                 hrw.state_name,
                  hrw.county_name,
                  hrw.city_name,
                  hrw.zip_code,
                  -- Bug 9159142
                  -- Added the following columns to pick up input values.
                  hsw.attribute1,
                  hsw.attribute2,
                  hsw.attribute3,
                  hsw.attribute4,
                  hsw.attribute5,
                  hsw.attribute6,
                  hsw.attribute7,
                  hsw.attribute8,
                  hsw.attribute9,
                  hsw.attribute10,
                  hsw.attribute11,
                  hsw.attribute12,
                  hsw.attribute13,
                  hsw.attribute14,
                  hsw.attribute15
             FROM hxt_timecards_x tim,
                  per_time_periods ptp,
                  hxt_det_hours_worked_x hrw,
                  hxt_sum_hours_worked_x hsw,
                  hr_lookups hcl, --GLOBAL
                  per_assignments_f asm,
                  pay_element_types_f elt,
                  hxt_pay_element_types_f_ddf_v eltv, --SIR65
                  pay_cost_allocation_keyflex pcak,
                  hr_locations_all_tl loct, --FORMS60
                  hr_locations_no_join loc, --FORMS60
                  fnd_flex_values ffvr
            WHERE hrw.ffv_rate_code_id = ffvr.flex_value_id(+)
              AND hrw.location_id = loc.location_id(+)
              AND hsw.id = hrw.parent_id
              AND loc.location_id = loct.location_id(+)
              AND DECODE (loct.location_id, NULL, '1', loct.LANGUAGE) =
              DECODE (loct.location_id, NULL, '1', USERENV ('LANG'))

--END FORMS60

              AND hrw.ffv_cost_center_id =
                                          pcak.cost_allocation_keyflex_id(+)
              AND hrw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND hrw.element_type_id = elt.element_type_id
              AND elt.element_type_id = eltv.element_type_id
              AND hrw.date_worked BETWEEN eltv.effective_start_date

                                      AND eltv.effective_end_date
              AND hrw.date_worked BETWEEN asm.effective_start_date
                                      AND asm.effective_end_date
              AND hrw.assignment_id = asm.assignment_id
              AND hrw.amount IS NULL


              AND hrw.tim_id = tim.id
              AND tim.id = p_tim_id
              AND tim.time_period_id = ptp.time_period_id

--BEGIN GLOBAL
              AND hrw.date_worked BETWEEN NVL (
                                             hcl.start_date_active(+),
                                             hrw.date_worked
                                          )
                                      AND NVL (
                                             hcl.end_date_active(+),
                                             hrw.date_worked
                                          )
              AND hcl.lookup_type(+) = 'ELE_ENTRY_REASON'
              AND hcl.lookup_code(+) = hrw.fcl_earn_reason_code

--END GLOBAL
         ORDER BY hrw.id; --SIR95


-- select current amounts by detail where hours=0 and amount is not null
      CURSOR current_amount (p_tim_id NUMBER)
      IS
         SELECT   asm.assignment_number, elt.element_name, --FORMS60
                  DECODE (
                     SIGN (
                          DECODE (
                             SIGN (
                                  ptp.start_date
                                - asm.effective_start_date
                             ),
                             1, ptp.start_date,
                             asm.effective_start_date
                          )
                        - elt.effective_start_date
                     ),
                     1, DECODE (
                           SIGN (  ptp.start_date
                                 - asm.effective_start_date),
                           1, ptp.start_date,
                           asm.effective_start_date
                        ),
                     elt.effective_start_date
                  )
                        from_date,
                  DECODE (
                     SIGN (
                          DECODE (
                             SIGN (  ptp.end_date
                                   - asm.effective_end_date),
                             -1, ptp.end_date,
                             asm.effective_end_date
                          )
                        - elt.effective_end_date
                     ),
                     -1, DECODE (
                            SIGN (  ptp.end_date
                                  - asm.effective_end_date),
                            -1, ptp.end_date,
                            asm.effective_end_date
                         ),
                     elt.effective_end_date
                  ) TO_DATE,
                  rate_multiple, hrw.hourly_rate,


                  loct.location_code locality_worked, --FORMS60
                  ffvr.flex_value rate_code, hrw.separate_check_flag,
                  hrw.fcl_tax_rule_code tax_separately_flag,
                  hrw.hours hours_worked, hrw.amount amount,
                  hrw.assignment_id, hrw.ffv_cost_center_id,

                  pcak.concatenated_segments, pcak.segment1, pcak.segment2,
                  pcak.segment3, pcak.segment4, pcak.segment5, pcak.segment6,
                  pcak.segment7, pcak.segment8, pcak.segment9, pcak.segment10,
                  pcak.segment11, pcak.segment12, pcak.segment13,
                  pcak.segment14, pcak.segment15, pcak.segment16,
                  pcak.segment17, pcak.segment18, pcak.segment19,
                  pcak.segment20, pcak.segment21, pcak.segment22,
                  pcak.segment23, pcak.segment24, pcak.segment25,
                  pcak.segment26, pcak.segment27, pcak.segment28,
                  pcak.segment29, pcak.segment30, hrw.element_type_id,



                  hrw.location_id,  hrw.ffv_rate_code_id,

                  asm.effective_end_date asm_effective_end_date,
                  elt.effective_end_date elt_effective_end_date,
                  hrw.parent_id, hrw.ROWID hrw_rowid, -- OHM180
                                                     hcl.meaning reason, --GLOBAL
                  hrw.date_worked,  ptp.time_period_id,
		  hrw.state_name,
		  hrw.county_name,
		  hrw.city_name,
		  hrw.zip_code
             FROM hxt_timecards_x tim,
                  per_time_periods ptp,
                  hxt_det_hours_worked_x hrw,
                  hr_lookups hcl, --GLOBAL
                  per_assignments_f asm,
                  pay_element_types_f elt,
                  pay_cost_allocation_keyflex pcak,


                  hr_locations_all_tl loct, --FORMS60
                  hr_locations_no_join loc, --FORMS60
                  fnd_flex_values ffvr
            WHERE hrw.ffv_rate_code_id = ffvr.flex_value_id(+)
              AND hrw.location_id = loc.location_id(+)

--BEGIN FORMS60
              AND loc.location_id = loct.location_id(+)
              AND DECODE (loct.location_id, NULL, '1', loct.LANGUAGE) =
                        DECODE (loct.location_id, NULL, '1', USERENV ('LANG'))

--END FORMS60

              AND hrw.ffv_cost_center_id =
                                          pcak.cost_allocation_keyflex_id(+)
              AND hrw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND hrw.element_type_id = elt.element_type_id
              AND hrw.date_worked BETWEEN asm.effective_start_date
                                      AND asm.effective_end_date
              AND hrw.assignment_id = asm.assignment_id
              AND hrw.amount IS NOT NULL


              AND hrw.tim_id = tim.id
              AND tim.id = p_tim_id
              AND tim.time_period_id = ptp.time_period_id

--BEGIN GLOBAL
              AND hrw.date_worked BETWEEN NVL (
                                             hcl.start_date_active(+),
                                             hrw.date_worked
                                          )
                                      AND NVL (
                                             hcl.end_date_active(+),
                                             hrw.date_worked
                                          )
              AND hcl.lookup_type(+) = 'ELE_ENTRY_REASON'
              AND hcl.lookup_code(+) = hrw.fcl_earn_reason_code

--END GLOBAL
         ORDER BY hrw.id; --SIR95


-- select previous (before retro) hours by detail where hours<>0 and amount is null
      -- Bug 9159142
      -- Changed the below cursor to take in IV attributes also,
      -- and compare them while picking up records.
      CURSOR prev_hours (
         p_tim_id                   NUMBER,
         p_assignment_id            NUMBER, -- fk - assignment_number
         p_asm_effective_end_date   DATE,
         p_ffv_cost_center_id       NUMBER, -- fk - cost_center_code
         p_element_type_id          NUMBER, -- fk - element_name
         p_elt_effective_end_date   DATE,
         p_from_date                DATE,
         p_hourly_rate              NUMBER,


         p_location_id              NUMBER, -- fk - locality_worked
         p_ffv_rate_code_id         NUMBER, -- fk - rate_code
         p_rate_multiple            NUMBER,
         p_separate_check_flag      VARCHAR2,
         p_fcl_tax_rule_code        VARCHAR2,
         p_to_date                  DATE,
         p_parent_id                NUMBER,
	 p_state_name		 VARCHAR2,
	 p_COUNTY_name		 VARCHAR2,
	 p_CITY_name		 VARCHAR2,
	 p_ZIP_CODE		 VARCHAR2      ,
         p_attribute_list        VARCHAR2  )
      IS
         SELECT   hrw.hours hours_worked, hrw.ROWID hrw_rowid -- OHM199
             FROM hxt_timecards_x tim,
                  per_time_periods ptp,
                  hxt_det_hours_worked_f hrw,
                  hxt_sum_hours_worked_f hsw,
                  per_assignments_f asm,
                  pay_element_types_f elt
            WHERE hrw.assignment_id = p_assignment_id
              AND asm.assignment_id = hrw.assignment_id
              AND hrw.parent_id  = hsw.id
              AND hsw.effective_end_date = hrw.effective_end_date
              AND NVL(p_attribute_list,'XXX') =
                   NVL(hsw.attribute1||
                   hsw.attribute2||
                   hsw.attribute3||
                   hsw.attribute4||
                   hsw.attribute5||
                   hsw.attribute6||
                   hsw.attribute7||
                   hsw.attribute8||
                   hsw.attribute9||
                   hsw.attribute10||
                   hsw.attribute11||
                   hsw.attribute12||
                   hsw.attribute13||
                   hsw.attribute14||
                   hsw.attribute15,'XXX')
              AND asm.effective_end_date = p_asm_effective_end_date
              AND NVL (hrw.ffv_cost_center_id, 999999999999999) =
                                  NVL (p_ffv_cost_center_id, 999999999999999)
              AND hrw.element_type_id = p_element_type_id
              AND elt.element_type_id = hrw.element_type_id
              AND elt.effective_end_date = p_elt_effective_end_date
              AND p_from_date =
                        DECODE (
                           SIGN (
                                DECODE (
                                   SIGN (
                                        ptp.start_date
                                      - asm.effective_start_date
                                   ),
                                   1, ptp.start_date,
                                   asm.effective_start_date
                                )
                              - elt.effective_start_date
                           ),
                           1, DECODE (
                                 SIGN (
                                      ptp.start_date
                                    - asm.effective_start_date
                                 ),
                                 1, ptp.start_date,
                                 asm.effective_start_date
                              ),
                           elt.effective_start_date
                        )
              AND NVL (hrw.hourly_rate, 999999999999999) =
                                         NVL (p_hourly_rate, 999999999999999)

              AND NVL (hrw.location_id, 999999999999999) =
                                         NVL (p_location_id, 999999999999999)
              AND NVL (hrw.ffv_rate_code_id, 999999999999999) =
                                    NVL (p_ffv_rate_code_id, 999999999999999)
              AND NVL (hrw.rate_multiple, 999999999999999) =
                                       NVL (p_rate_multiple, 999999999999999)
              AND NVL (hrw.separate_check_flag, 'ZZZZZZZZZZ') =
                                     NVL (p_separate_check_flag, 'ZZZZZZZZZZ')
              AND NVL (hrw.fcl_tax_rule_code, 'ZZZZZZZZZZ') =
                                       NVL (p_fcl_tax_rule_code, 'ZZZZZZZZZZ')
              AND p_to_date =
                        DECODE (
                           SIGN (
                                DECODE (
                                   SIGN (
                                        ptp.end_date
                                      - asm.effective_end_date
                                   ),
                                   -1, ptp.end_date,
                                   asm.effective_end_date
                                )
                              - elt.effective_end_date
                           ),
                           -1, DECODE (
                                  SIGN (
                                       ptp.end_date
                                     - asm.effective_end_date
                                  ),
                                  -1, ptp.end_date,
                                  asm.effective_end_date
                               ),
                           elt.effective_end_date
                        )
              AND hrw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND hrw.date_worked BETWEEN asm.effective_start_date
                                      AND asm.effective_end_date
              AND hrw.amount IS NULL
              AND hrw.parent_id = p_parent_id
              AND hrw.tim_id = tim.id
              AND tim.id = p_tim_id
              AND tim.time_period_id = ptp.time_period_id
              AND hrw.pay_status = 'C'
              AND NVL (hrw.state_name, 'ZZZZZZZZZZ') =
                                       NVL (p_state_name, 'ZZZZZZZZZZ')
              AND NVL (hrw.county_name, 'ZZZZZZZZZZ') =
                                       NVL (p_county_name, 'ZZZZZZZZZZ')
              AND NVL (hrw.city_name, 'ZZZZZZZZZZ') =
                                       NVL (p_city_name, 'ZZZZZZZZZZ')
              AND NVL (hrw.zip_code, 'ZZZZZZZZZZ') =
                                       NVL (p_zip_code, 'ZZZZZZZZZZ')

         ORDER BY hrw.id; --SIR95


-- select previous (before retro) amounts by detail where hours=0 and amount<>0
      CURSOR prev_amount (
         p_tim_id                   NUMBER,
         p_assignment_id            NUMBER, -- fk - assignment_number
         p_asm_effective_end_date   DATE,
         p_ffv_cost_center_id       NUMBER, -- fk - cost_center_code
         p_element_type_id          NUMBER, -- fk - element_name
         p_elt_effective_end_date   DATE,
         p_from_date                DATE,
         p_hourly_rate              NUMBER,


         p_location_id              NUMBER, -- fk - locality_worked
         p_ffv_rate_code_id         NUMBER, -- fk - rate_code
         p_rate_multiple            NUMBER,
         p_separate_check_flag      VARCHAR2,
         p_fcl_tax_rule_code        VARCHAR2,
         p_to_date                  DATE,
         p_parent_id                NUMBER,
	 p_state_name		 VARCHAR2,
	 p_COUNTY_name		 VARCHAR2,
	 p_CITY_name		 VARCHAR2,
	 p_ZIP_CODE		 VARCHAR2      )

      IS
         SELECT   hrw.amount amount, hrw.ROWID hrw_rowid -- OHM199
             FROM hxt_timecards_x tim,
                  per_time_periods ptp,
                  hxt_det_hours_worked_f hrw,
                  per_assignments_f asm,
                  pay_element_types_f elt
            WHERE hrw.assignment_id = p_assignment_id
              AND asm.assignment_id = hrw.assignment_id
              AND asm.effective_end_date = p_asm_effective_end_date
              AND NVL (hrw.ffv_cost_center_id, 999999999999999) =
                                  NVL (p_ffv_cost_center_id, 999999999999999)
              AND hrw.element_type_id = p_element_type_id
              AND elt.element_type_id = hrw.element_type_id
              AND elt.effective_end_date = p_elt_effective_end_date
              AND p_from_date =
                        DECODE (
                           SIGN (
                                DECODE (
                                   SIGN (
                                        ptp.start_date
                                      - asm.effective_start_date
                                   ),
                                   1, ptp.start_date,
                                   asm.effective_start_date
                                )
                              - elt.effective_start_date
                           ),
                           1, DECODE (
                                 SIGN (
                                      ptp.start_date
                                    - asm.effective_start_date
                                 ),
                                 1, ptp.start_date,
                                 asm.effective_start_date
                              ),
                           elt.effective_start_date
                        )
              AND NVL (hrw.hourly_rate, 999999999999999) =
                                         NVL (p_hourly_rate, 999999999999999)


              AND NVL (hrw.location_id, 999999999999999) =
                                         NVL (p_location_id, 999999999999999)
              AND NVL (hrw.ffv_rate_code_id, 999999999999999) =
                                    NVL (p_ffv_rate_code_id, 999999999999999)
              AND NVL (hrw.rate_multiple, 999999999999999) =
                                       NVL (p_rate_multiple, 999999999999999)
              AND NVL (hrw.separate_check_flag, 'ZZZZZZZZZZ') =
                                     NVL (p_separate_check_flag, 'ZZZZZZZZZZ')
              AND NVL (hrw.fcl_tax_rule_code, 'ZZZZZZZZZZ') =
                                       NVL (p_fcl_tax_rule_code, 'ZZZZZZZZZZ')
              AND p_to_date =
                        DECODE (
                           SIGN (
                                DECODE (
                                   SIGN (
                                        ptp.end_date
                                      - asm.effective_end_date
                                   ),
                                   -1, ptp.end_date,
                                   asm.effective_end_date
                                )
                              - elt.effective_end_date
                           ),
                           -1, DECODE (
                                  SIGN (
                                       ptp.end_date
                                     - asm.effective_end_date
                                  ),
                                  -1, ptp.end_date,
                                  asm.effective_end_date
                               ),
                           elt.effective_end_date
                        )
              AND hrw.date_worked BETWEEN elt.effective_start_date
                                      AND elt.effective_end_date
              AND hrw.date_worked BETWEEN asm.effective_start_date
                                      AND asm.effective_end_date
              AND hrw.amount IS NOT NULL
              AND hrw.parent_id > 0
              AND hrw.parent_id = p_parent_id
              AND hrw.tim_id = tim.id
              AND tim.id = p_tim_id
              AND tim.time_period_id = ptp.time_period_id
              AND hrw.pay_status = 'C'
              AND NVL (hrw.state_name, 'ZZZZZZZZZZ') =
                                       NVL (p_state_name, 'ZZZZZZZZZZ')
              AND NVL (hrw.county_name, 'ZZZZZZZZZZ') =
                                       NVL (p_county_name, 'ZZZZZZZZZZ')
              AND NVL (hrw.city_name, 'ZZZZZZZZZZ') =
                                       NVL (p_city_name, 'ZZZZZZZZZZ')
              AND NVL (hrw.zip_code, 'ZZZZZZZZZZ') =
                                       NVL (p_zip_code, 'ZZZZZZZZZZ')

         ORDER BY hrw.id; --SIR95

      l_return               NUMBER;

--BSE128         l_hours_rec current_hours%ROWTYPE;
      l_prev_hours_rec       prev_hours%ROWTYPE;

--BSE128         l_amount_rec current_amount%ROWTYPE;
      l_prev_amount_rec      prev_amount%ROWTYPE;
      l_expired_pay_status   CHAR (1);
--      l_nextval              NUMBER (15);
      l_batch_line_id        NUMBER (15);
      l_hours_to_send        NUMBER (7, 3);
      l_amount_to_send       NUMBER (15, 5);
      l_retcode              NUMBER;                              /* BSE107 */
      l_location             VARCHAR2 (20);

      l_batch_sequence PAY_BATCH_LINES.BATCH_SEQUENCE%TYPE;

   BEGIN

      -- Bug 8888777

      g_iv_upgrade := hxt_batch_process.get_upgrade_status(p_batch_id);

      hxt_util.DEBUG ('retro_mix started.'); -- debug only --HXT115

/************************************************************/
-- Step 1 - retro processing where hours<>0, amount=0
/************************************************************/
      l_location := 'Step 1A';

   -- bug 3217343 fix BEGIN
   -- get the next batch_seq for this batch_id only once and increment the
   -- sequence by 1 whenever insert_pay_batch_lines is called.
   -- This way the multiple expensive calls to
   -- pay_paywsqee_pkg.next_batch_sequence in insert_pay_batch_lines procedure
   -- can be avoided.

      l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence(p_batch_id);

   -- bug 3217343 fix END
      FOR l_hours_rec IN current_hours (p_tim_id)
      LOOP
         hxt_util.DEBUG (
               'retro row is '
            || l_hours_rec.element_name
            || ' '
            || TO_CHAR (l_hours_rec.hours_worked)
            || ' '
         ); -- debug only --HXT115
         l_hours_to_send := l_hours_rec.hours_worked;

         -- Bug 8888777
         -- Added the below code to pick up the input values.

         OPEN get_input_values(l_hours_rec.parent_id);
         FETCH get_input_values INTO g_xiv_table(l_hours_rec.parent_id);
         CLOSE get_input_values;
         IF g_xiv_table.EXISTS(l_hours_rec.parent_id)
          AND g_debug
         THEN
            hr_utility.trace('parent = '||l_hours_rec.parent_id);
            hr_utility.trace('attribute 1  ='||g_xiv_table(l_hours_rec.parent_id).attribute1	);
            hr_utility.trace('attribute 2  ='||g_xiv_table(l_hours_rec.parent_id).attribute2	);
            hr_utility.trace('attribute 3  ='||g_xiv_table(l_hours_rec.parent_id).attribute3	);
            hr_utility.trace('attribute 4  ='||g_xiv_table(l_hours_rec.parent_id).attribute4	);
            hr_utility.trace('attribute 5  ='||g_xiv_table(l_hours_rec.parent_id).attribute5	);
            hr_utility.trace('attribute 6  ='||g_xiv_table(l_hours_rec.parent_id).attribute6	);
            hr_utility.trace('attribute 7  ='||g_xiv_table(l_hours_rec.parent_id).attribute7	);
            hr_utility.trace('attribute 8  ='||g_xiv_table(l_hours_rec.parent_id).attribute8	);
            hr_utility.trace('attribute 9  ='||g_xiv_table(l_hours_rec.parent_id).attribute9	);
            hr_utility.trace('attribute 10 ='||g_xiv_table(l_hours_rec.parent_id).attribute10	);
            hr_utility.trace('attribute 11 ='||g_xiv_table(l_hours_rec.parent_id).attribute11	);
            hr_utility.trace('attribute 12 ='||g_xiv_table(l_hours_rec.parent_id).attribute12	);
            hr_utility.trace('attribute 13 ='||g_xiv_table(l_hours_rec.parent_id).attribute13	);
            hr_utility.trace('attribute 14 ='||g_xiv_table(l_hours_rec.parent_id).attribute14	);
            hr_utility.trace('attribute 15 ='||g_xiv_table(l_hours_rec.parent_id).attribute15	);
        END IF;



         OPEN prev_hours (
            p_tim_id,
            l_hours_rec.assignment_id, -- fk - assignment_number
            l_hours_rec.asm_effective_end_date,
            l_hours_rec.ffv_cost_center_id, -- fk - cost_center_code
            l_hours_rec.element_type_id, -- fk - element_name
            l_hours_rec.elt_effective_end_date,
            l_hours_rec.from_date,
            l_hours_rec.hourly_rate,

/*TA36                 l_hours_rec.ffv_labor_account_id,*/ -- fk - labor_dist_code
            l_hours_rec.location_id, -- fk - locality_worked
            l_hours_rec.ffv_rate_code_id, -- fk - rate_code
            l_hours_rec.rate_multiple,
            l_hours_rec.separate_check_flag,
            l_hours_rec.tax_separately_flag, -- fcl_tax_rule_code
            l_hours_rec.TO_DATE,
            l_hours_rec.parent_id,
 	    l_hours_rec.state_name, --dd
   	    l_hours_rec.county_name,
   	    l_hours_rec.city_name,
   	    l_hours_rec.zip_code,
            l_hours_rec.attribute1||
            l_hours_rec.attribute2||
            l_hours_rec.attribute3||
            l_hours_rec.attribute4||
            l_hours_rec.attribute5||
            l_hours_rec.attribute6||
            l_hours_rec.attribute7||
            l_hours_rec.attribute8||
            l_hours_rec.attribute9||
            l_hours_rec.attribute10||
            l_hours_rec.attribute11||
            l_hours_rec.attribute12||
            l_hours_rec.attribute13||
            l_hours_rec.attribute14||
            l_hours_rec.attribute15
         );
         FETCH prev_hours INTO l_prev_hours_rec;

         IF prev_hours%FOUND
         THEN
            hxt_util.DEBUG (
                  'orig row is '
               || TO_CHAR (l_prev_hours_rec.hours_worked)
               || ' '
            ); -- debug only --HXT115
            l_hours_to_send :=
                     l_hours_rec.hours_worked
                   - l_prev_hours_rec.hours_worked;
            l_location := 'Step 1B';


-- begin OHM199
            IF l_hours_to_send = 0
            THEN
               UPDATE hxt_det_hours_worked_f
                  SET pay_status = 'D',
                      last_update_date = SYSDATE
                WHERE ROWID = l_prev_hours_rec.hrw_rowid
                  -- ADDED BY MV: IF THERE IS ONLY ONE ROW, PREV and CURR records
                  -- are the same; we should not update such records.
                  AND l_prev_hours_rec.hrw_rowid <> l_hours_rec.hrw_rowid;
            ELSE
               UPDATE hxt_det_hours_worked_f
                  SET pay_status = 'A',
                      last_update_date = SYSDATE
                WHERE ROWID = l_prev_hours_rec.hrw_rowid;
            END IF;

-- end OHM199
         END IF;

         hxt_util.DEBUG (   ' hours to send - '
                         || TO_CHAR (l_hours_to_send)); -- debug only --HXT115
         l_location := 'Step 1C';

         IF (l_hours_to_send <> 0)
         THEN
            --begin SIR65
            IF l_hours_rec.hxt_earning_category NOT IN ('REG', 'OVT', 'ABS')
            THEN
               IF l_hours_rec.hxt_premium_type = 'FACTOR'
               THEN
                  IF l_hours_rec.rate_multiple IS NULL
                  THEN
                     l_hours_rec.rate_multiple :=
                                               l_hours_rec.hxt_premium_amount;
                  END IF;

                  IF l_hours_rec.hourly_rate IS NULL
                  THEN
                     l_retcode :=
                           hxt_td_util.get_hourly_rate (
                              l_hours_rec.date_worked,
                              l_hours_rec.time_period_id,
                              l_hours_rec.assignment_id,
                              l_hours_rec.hourly_rate
                           );
                  END IF;
               ELSIF l_hours_rec.hxt_premium_type = 'RATE'
               THEN
                  IF l_hours_rec.hourly_rate IS NULL
                  THEN
                     l_hours_rec.hourly_rate :=
                                               l_hours_rec.hxt_premium_amount;
                  END IF;
               END IF;
            ELSE
               --end SIR65
                 --BEGIN BSE107 - OHM SPR200
               IF l_hours_rec.hourly_rate IS NULL
               THEN -- OHM205
                  l_retcode :=
                        hxt_td_util.get_hourly_rate (
                           l_hours_rec.date_worked,
                           l_hours_rec.time_period_id,
                           l_hours_rec.assignment_id,
                           l_hours_rec.hourly_rate
                        );
               END IF; -- OHM205
            --END BSE107 - OHM SPR200
            END IF; --SIR65


--BEGIN GLOBAL
--          select pay_pdt_batch_lines_s.nextval
--            SELECT pay_batch_lines_s.NEXTVAL

--END GLOBAL
  --            INTO l_nextval
    --          FROM DUAL;

            l_location := 'Step 1D';
            hxt_util.DEBUG (' insert hours to paymix.'); -- debug only --HXT115

--BEGIN GLOBAL
--          INSERT into pay_pdt_batch_lines
--           (batch_id, line_id,
--            assignment_number, adjustment_type_code,
--            amount,
--            apply_this_period,
--     cost_allocation_keyflex_id,concatenated_segments,
--     segment1,segment2,segment3,segment4,
--     segment5,segment6,segment7,segment8,
--     segment9,segment10,segment11,segment12,
--     segment13,segment14,segment15,segment16,
--     segment17,segment18,segment19,segment20,
--     segment21,segment22,segment23,segment24,
--     segment25,segment26,segment27,segment28,
--     segment29,segment30,
--            element_name, from_date,
--            to_date, hourly_rate, inc_asc_balance,
--            labor_dist_code,
--            line_status, locality_worked, new_salary, pay_effective_date,
--            pcnt_increase, rate_code, rate_multiple, rating_code,
--            separate_check_flag, shift_type, state_worked,
--            tax_separately_flag, vol_ded_proc_ovd,
--            hours_worked)
--          VALUES(
--            p_batch_id, l_nextval,
--            l_hours_rec.assignment_number, '',
--            l_hours_rec.amount,
--            '',
--     l_hours_rec.ffv_cost_center_id,l_hours_rec.concatenated_segments,
--     l_hours_rec.segment1,l_hours_rec.segment2,l_hours_rec.segment3,l_hours_rec.segment4,
--     l_hours_rec.segment5,l_hours_rec.segment6,l_hours_rec.segment7,l_hours_rec.segment8,
--     l_hours_rec.segment9,l_hours_rec.segment10,l_hours_rec.segment11,l_hours_rec.segment12,
--     l_hours_rec.segment13,l_hours_rec.segment14,l_hours_rec.segment15,l_hours_rec.segment16,
--     l_hours_rec.segment17,l_hours_rec.segment18,l_hours_rec.segment19,l_hours_rec.segment20,
--     l_hours_rec.segment21,l_hours_rec.segment22,l_hours_rec.segment23,l_hours_rec.segment24,
--     l_hours_rec.segment25,l_hours_rec.segment26,l_hours_rec.segment27,l_hours_rec.segment28,
--     l_hours_rec.segment29,l_hours_rec.segment30,
--            l_hours_rec.element_name, '',
--            '', l_hours_rec.hourly_rate, '',
--            /*TA36l_hours_rec.labor_dist_code*/ NULL,
--            '', l_hours_rec.locality_worked, '', '',
--            '', l_hours_rec.rate_code, l_hours_rec.rate_multiple, '',
--            l_hours_rec.separate_check_flag, '', '',
--            l_hours_rec.tax_separately_flag, '',
--            l_hours_to_send
--            );
            -- Bug 8888777
            -- Added parent_id in the below call.
            insert_pay_batch_lines (
               p_batch_id,
               l_batch_line_id,
               l_hours_rec.assignment_id,
               l_hours_rec.assignment_number,
               l_hours_rec.amount,
               l_hours_rec.ffv_cost_center_id,
               l_hours_rec.concatenated_segments,
               l_hours_rec.segment1,
               l_hours_rec.segment2,
               l_hours_rec.segment3,
               l_hours_rec.segment4,
               l_hours_rec.segment5,
               l_hours_rec.segment6,
               l_hours_rec.segment7,
               l_hours_rec.segment8,
               l_hours_rec.segment9,
               l_hours_rec.segment10,
               l_hours_rec.segment11,
               l_hours_rec.segment12,
               l_hours_rec.segment13,
               l_hours_rec.segment14,
               l_hours_rec.segment15,
               l_hours_rec.segment16,
               l_hours_rec.segment17,
               l_hours_rec.segment18,
               l_hours_rec.segment19,
               l_hours_rec.segment20,
               l_hours_rec.segment21,
               l_hours_rec.segment22,
               l_hours_rec.segment23,
               l_hours_rec.segment24,
               l_hours_rec.segment25,
               l_hours_rec.segment26,
               l_hours_rec.segment27,
               l_hours_rec.segment28,
               l_hours_rec.segment29,
               l_hours_rec.segment30,
               l_hours_rec.element_type_id,
               l_hours_rec.element_name,
               l_hours_rec.hourly_rate,
               l_hours_rec.locality_worked,
               l_hours_rec.rate_code,
               l_hours_rec.rate_multiple,
               l_hours_rec.separate_check_flag,
               l_hours_rec.tax_separately_flag,
               l_hours_to_send,
               l_hours_rec.date_worked,
               l_hours_rec.reason,
               l_batch_sequence,
	       l_hours_rec.state_name,
	       l_hours_rec.county_name,
	       l_hours_rec.city_name,
	       l_hours_rec.zip_code,
               l_hours_rec.parent_id
            );

--END GLOBAL
            l_location := 'Step 1E';


-- begin OHM180
            UPDATE hxt_det_hours_worked_f
               SET retro_pbl_line_id = l_batch_line_id
             WHERE ROWID = l_hours_rec.hrw_rowid;

-- end OHM180

            l_batch_sequence := l_batch_sequence + 1;

         END IF;

         CLOSE prev_hours;
      END LOOP;


/************************************************************/
-- Step 2 - retro processing where hours=0, amount<>0
/************************************************************/
      l_location := 'Step 2A';

      l_batch_sequence := l_batch_sequence + 1;

      FOR l_amount_rec IN current_amount (p_tim_id)
      LOOP
         hxt_util.DEBUG (
               'retro row is '
            || l_amount_rec.element_name
            || ' '
            || TO_CHAR (l_amount_rec.amount)
            || ' '
         ); -- debug only --HXT115
         l_amount_to_send := l_amount_rec.amount;
         OPEN prev_amount (
            p_tim_id,
            l_amount_rec.assignment_id, -- fk - assignment_number
            l_amount_rec.asm_effective_end_date,
            l_amount_rec.ffv_cost_center_id, -- fk - cost_center_code
            l_amount_rec.element_type_id, -- fk - element_name
            l_amount_rec.elt_effective_end_date,
            l_amount_rec.from_date,
            l_amount_rec.hourly_rate,

/*TA36                      l_amount_rec.ffv_labor_account_id,*/  -- fk - labor_dist_code
            l_amount_rec.location_id, -- fk - locality_worked
            l_amount_rec.ffv_rate_code_id, -- fk - rate_code
            l_amount_rec.rate_multiple,
            l_amount_rec.separate_check_flag,
            l_amount_rec.tax_separately_flag, -- fcl_tax_rule_code
            l_amount_rec.TO_DATE,
            l_amount_rec.parent_id,
 	    l_amount_rec.state_name, --dd
   	    l_amount_rec.county_name,
   	    l_amount_rec.city_name,
   	    l_amount_rec.zip_code

         );
         FETCH prev_amount INTO l_prev_amount_rec;

         IF prev_amount%FOUND
         THEN
            hxt_util.DEBUG (
                  'orig row is '
               || TO_CHAR (l_prev_amount_rec.amount)
               || ' '
            ); -- debug only --HXT115
            l_amount_to_send :=
                               l_amount_rec.amount
                             - l_prev_amount_rec.amount;
            l_location := 'Step 2B';


-- begin OHM199
            IF l_amount_to_send = 0
            THEN
               UPDATE hxt_det_hours_worked_f
                  SET pay_status = 'D',
                      last_update_date = SYSDATE
                WHERE ROWID = l_prev_amount_rec.hrw_rowid
                  -- ADDED BY MV: IF THERE IS ONLY ONE ROW, PREV and CURR records
                  -- are the same; we should not update such records.
                  AND l_prev_amount_rec.hrw_rowid <> l_amount_rec.hrw_rowid;
            ELSE
               UPDATE hxt_det_hours_worked_f
                  SET pay_status = 'A',
                      last_update_date = SYSDATE
                WHERE ROWID = l_prev_amount_rec.hrw_rowid;
            END IF;

-- end OHM199
         END IF;

         hxt_util.DEBUG (   ' amount to send - '
                         || TO_CHAR (l_amount_to_send)); -- debug only --HXT115
         l_location := 'Step 2C';

         IF (l_amount_to_send <> 0)
         THEN

/*  CODE ADDED PER BSE107 */
--BSE130      l_retcode := HXT_TD_UTIL.get_hourly_rate(l_amount_rec.date_worked,
--BSE130                                              l_amount_rec.time_period_id,
--BSE130                                              l_amount_rec.assignment_id,
--BSE130                                              l_amount_rec.hourly_rate);

/* END BSE107 */
--BEGIN GLOBAL
--          select pay_pdt_batch_lines_s.nextval
--            SELECT pay_batch_lines_s.NEXTVAL

--END GLOBAL
--              INTO l_nextval
--              FROM DUAL;

            l_location := 'Step 2D';

--BEGIN GLOBAL
--          INSERT into pay_pdt_batch_lines
--           (batch_id, line_id,
--            assignment_number, adjustment_type_code,
--            amount,
--            apply_this_period,
--     cost_allocation_keyflex_id,concatenated_segments,
--     segment1,segment2,segment3,segment4,
--     segment5,segment6,segment7,segment8,
--     segment9,segment10,segment11,segment12,
--     segment13,segment14,segment15,segment16,
--     segment17,segment18,segment19,segment20,
--     segment21,segment22,segment23,segment24,
--     segment25,segment26,segment27,segment28,
--     segment29,segment30,
--            element_name, from_date,
--            to_date, hourly_rate, inc_asc_balance,
--            labor_dist_code,
--            line_status, locality_worked, new_salary, pay_effective_date,
--            pcnt_increase, rate_code, rate_multiple, rating_code,
--            separate_check_flag, shift_type, state_worked,
--            tax_separately_flag, vol_ded_proc_ovd,
--            hours_worked)
--          VALUES(
--            p_batch_id, l_nextval,
--            l_amount_rec.assignment_number, '',
--            l_amount_to_send,
--            '',
--     l_amount_rec.ffv_cost_center_id,l_amount_rec.concatenated_segments,
--     l_amount_rec.segment1,l_amount_rec.segment2,l_amount_rec.segment3,l_amount_rec.segment4,
--     l_amount_rec.segment5,l_amount_rec.segment6,l_amount_rec.segment7,l_amount_rec.segment8,
--     l_amount_rec.segment9,l_amount_rec.segment10,l_amount_rec.segment11,l_amount_rec.segment12,
--     l_amount_rec.segment13,l_amount_rec.segment14,l_amount_rec.segment15,l_amount_rec.segment16,
--     l_amount_rec.segment17,l_amount_rec.segment18,l_amount_rec.segment19,l_amount_rec.segment20,
--     l_amount_rec.segment21,l_amount_rec.segment22,l_amount_rec.segment23,l_amount_rec.segment24,
--     l_amount_rec.segment25,l_amount_rec.segment26,l_amount_rec.segment27,l_amount_rec.segment28,
--     l_amount_rec.segment29,l_amount_rec.segment30,
--            l_amount_rec.element_name, '',
--            '', l_amount_rec.hourly_rate, '',
--/*TA36           l_amount_rec.labor_dist_code*/NULL,
--            '', l_amount_rec.locality_worked, '', '',
--            '', l_amount_rec.rate_code, l_amount_rec.rate_multiple, '',
--            l_amount_rec.separate_check_flag, '', '',
--            l_amount_rec.tax_separately_flag, '',
--            l_amount_rec.hours_worked
--            );
            insert_pay_batch_lines (
               p_batch_id,
               l_batch_line_id,
               l_amount_rec.assignment_id,
               l_amount_rec.assignment_number,
               l_amount_to_send,
               l_amount_rec.ffv_cost_center_id,
               l_amount_rec.concatenated_segments,
               l_amount_rec.segment1,
               l_amount_rec.segment2,
               l_amount_rec.segment3,
               l_amount_rec.segment4,
               l_amount_rec.segment5,
               l_amount_rec.segment6,
               l_amount_rec.segment7,
               l_amount_rec.segment8,
               l_amount_rec.segment9,
               l_amount_rec.segment10,
               l_amount_rec.segment11,
               l_amount_rec.segment12,
               l_amount_rec.segment13,
               l_amount_rec.segment14,
               l_amount_rec.segment15,
               l_amount_rec.segment16,
               l_amount_rec.segment17,
               l_amount_rec.segment18,
               l_amount_rec.segment19,
               l_amount_rec.segment20,
               l_amount_rec.segment21,
               l_amount_rec.segment22,
               l_amount_rec.segment23,
               l_amount_rec.segment24,
               l_amount_rec.segment25,
               l_amount_rec.segment26,
               l_amount_rec.segment27,
               l_amount_rec.segment28,
               l_amount_rec.segment29,
               l_amount_rec.segment30,
               l_amount_rec.element_type_id,
               l_amount_rec.element_name,
               l_amount_rec.hourly_rate,
               l_amount_rec.locality_worked,
               l_amount_rec.rate_code,
               l_amount_rec.rate_multiple,
               l_amount_rec.separate_check_flag,
               l_amount_rec.tax_separately_flag,
               l_amount_rec.hours_worked,
               l_amount_rec.date_worked,
               l_amount_rec.reason,
               l_batch_sequence,
	       l_amount_rec.state_name,
	       l_amount_rec.county_name,
	       l_amount_rec.city_name,
	       l_amount_rec.zip_code
            );

--END GLOBAL
            l_location := 'Step 2E';
            hxt_util.DEBUG (' insert amount to paymix.'); -- debug only --HXT115


-- begin OHM180
            UPDATE hxt_det_hours_worked_f
               SET retro_pbl_line_id = l_batch_line_id
             WHERE ROWID = l_amount_rec.hrw_rowid;

-- end OHM180

             l_batch_sequence := l_batch_sequence + 1;

         END IF;

         CLOSE prev_amount;
      END LOOP;


/************************************************************/
-- Step 3 - loop thru retro rows, mark matching rows 'A' or 'D'
/************************************************************/
  --OHM199 commented out because now we mark in loops above.
  --OHM199mark_prev_hours_rows (p_tim_id);
  --OHM199mark_prev_amount_rows (p_tim_id);


/************************************************************/
-- Step 4 - send whatever is left over as backout transactions
/************************************************************/

      g_xiv_table.DELETE;

      l_location := 'Step 4A';
      back_out_leftover_hours (p_batch_id, p_tim_id);
      l_location := 'Step 4B';
      back_out_leftover_amount (p_batch_id, p_tim_id);

/************************************************************/
-- Step 5 - mark retro rows on timecard complete
/************************************************************/
      l_location := 'Step 5A';
      mark_retro_rows_complete (p_tim_id);
      l_location := 'Step 5B';
      p_sum_retcode := 0;
      p_err_buf := '';
	  -- Bug 9494444
      snap_retrieval_details(p_batch_id,p_tim_id);

      RETURN;
   EXCEPTION
      WHEN g_lookup_not_found
      THEN --SIR517 PWM 18FEB00
         hxt_util.DEBUG (
            'Oops...g_lookup_not_found in procedure retro_sum_to_mix'
         ); --HXT115
         p_err_buf := SUBSTR (fnd_message.get, 1, 65); --HXT111
         hxt_batch_process.insert_pay_batch_errors (
            p_batch_id,
            'VE', -- RETROPAY
            '',
            l_return
         );
         RETURN;
      WHEN g_error_ins_batch_lines
      THEN --SIR517 PWM 18FEB00
         hxt_util.DEBUG ('Error attempting to insert paymix information'); -- debug only --HXT115
         fnd_message.set_name ('HXT', 'HXT_39354_ERR_INS_PAYMX_INFO'); --HXT111
         fnd_message.set_token ('SQLERR', SQLERRM); --HXT111
         p_err_buf := SUBSTR (fnd_message.get, 1, 65); --HXT111
         hxt_batch_process.insert_pay_batch_errors (
            p_batch_id,
            'VE', -- RETROPAY
            '',
            l_return
         );
         hxt_util.DEBUG (' back from calling insert_pay_batch_errors'); -- debug only --HXT115
         RETURN;
      WHEN OTHERS
      THEN
         hxt_util.DEBUG (
               ' exception received at '
            || l_location
            || '.  '
            || SQLERRM
         ); -- debug only --HXT115
         p_sum_retcode := 3;

--HXT111    p_err_buf := substr(' exception received at '||l_location||'.  '||sqlerrm,1,65);
         fnd_message.set_name ('HXT', 'HXT_39453_EXCPT_RCVD_AT'); --HXT111
         fnd_message.set_token ('LOCATION', l_location); --HXT111
         fnd_message.set_token ('SQLERR', SQLERRM); --HXT111
         p_err_buf := SUBSTR (fnd_message.get, 1, 65); --HXT111
         hxt_batch_process.insert_pay_batch_errors (
            p_batch_id,
            'VE', -- RETROPAY

--HXT111         'Error attempting to insert paymix information: (' || sqlerrm || ')',
            '', --HXT111
            l_return
         );
         hxt_util.DEBUG (' back from calling insert_pay_batch_errors'); -- debug only --HXT115
         RETURN;
   END retro_sum_to_mix;

   PROCEDURE mark_prev_hours_rows (p_tim_id IN NUMBER)
   IS
   BEGIN
      UPDATE hxt_det_hours_worked_f
         SET pay_status = 'D',
             last_update_date = SYSDATE
       WHERE ROWID IN
                   (SELECT hrw.ROWID
                      FROM hxt_det_hours_worked_f hrw
                     WHERE hrw.tim_id = p_tim_id
                       AND hrw.pay_status = 'C'
                       AND hrw.amount IS NULL
                       AND hrw.parent_id > 0
                       AND EXISTS ( SELECT 'X'
                                      FROM hxt_det_hours_worked_x retro
                                     WHERE hrw.parent_id = retro.parent_id
                                       AND retro.pay_status = 'R'
                                       AND hrw.hours = retro.hours
                                       AND hrw.amount IS NULL
				       and NVL(hrw.state_name,'ZZZZZZZZZZ')=
				       NVL(retro.state_name,'ZZZZZZZZZZ')
				       and NVL(hrw.county_name,'ZZZZZZZZZZ')=
				       NVL(retro.county_name,'ZZZZZZZZZZ')
				       and NVL(hrw.city_name,'ZZZZZZZZZZ')=
				       NVL(retro.city_name,'ZZZZZZZZZZ')
				       and NVL(hrw.zip_code,'ZZZZZZZZZZ')=
				       NVL(retro.zip_code,'ZZZZZZZZZZ')
                                       AND hrw.assignment_id =
                                                          retro.assignment_id
                                       AND NVL (
                                              hrw.ffv_cost_center_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_cost_center_id,
                                                  999999999999999
                                               )
                                       AND hrw.element_type_id =
                                                        retro.element_type_id
                                       AND NVL (
                                              hrw.hourly_rate,
                                              999999999999999
                                           ) = NVL (
                                                  retro.hourly_rate,
                                                  999999999999999
                                               )

                                       AND NVL (
                                              hrw.location_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.location_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.ffv_rate_code_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_rate_code_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.rate_multiple,
                                              999999999999999
                                           ) = NVL (
                                                  retro.rate_multiple,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.separate_check_flag,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.separate_check_flag,
                                                  'ZZZZZZZZZZ'
                                               )
                                       AND NVL (
                                              hrw.fcl_tax_rule_code,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.fcl_tax_rule_code,
                                                  'ZZZZZZZZZZ'
                                               )));

      UPDATE hxt_det_hours_worked_f
         SET pay_status = 'A',
             last_update_date = SYSDATE
       WHERE ROWID IN
                   (SELECT hrw.ROWID
                      FROM hxt_det_hours_worked_f hrw
                     WHERE hrw.tim_id = p_tim_id
                       AND hrw.pay_status = 'C'
                       AND hrw.amount IS NULL
                       AND hrw.parent_id > 0
                       AND EXISTS ( SELECT 'X'
                                      FROM hxt_det_hours_worked_x retro
                                     WHERE hrw.parent_id = retro.parent_id
                                       AND retro.pay_status = 'R'
                                       AND hrw.hours <> retro.hours
                                       AND hrw.amount IS NULL
                                       AND hrw.assignment_id =
                                                          retro.assignment_id
				       and NVL(hrw.state_name,'ZZZZZZZZZZ')=
				       NVL(retro.state_name,'ZZZZZZZZZZ')
				       and NVL(hrw.county_name,'ZZZZZZZZZZ')=
				       NVL(retro.county_name,'ZZZZZZZZZZ')
				       and NVL(hrw.city_name,'ZZZZZZZZZZ')=
				       NVL(retro.city_name,'ZZZZZZZZZZ')
				       and NVL(hrw.zip_code,'ZZZZZZZZZZ')=
				       NVL(retro.zip_code,'ZZZZZZZZZZ')
                                       AND NVL (
                                              hrw.ffv_cost_center_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_cost_center_id,
                                                  999999999999999
                                               )
                                       AND hrw.element_type_id =
                                                        retro.element_type_id
                                       AND NVL (
                                              hrw.hourly_rate,
                                              999999999999999
                                           ) = NVL (
                                                  retro.hourly_rate,
                                                  999999999999999
                                               )

                                       AND NVL (
                                              hrw.location_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.location_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.ffv_rate_code_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_rate_code_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.rate_multiple,
                                              999999999999999
                                           ) = NVL (
                                                  retro.rate_multiple,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.separate_check_flag,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.separate_check_flag,
                                                  'ZZZZZZZZZZ'
                                               )
                                       AND NVL (
                                              hrw.fcl_tax_rule_code,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.fcl_tax_rule_code,
                                                  'ZZZZZZZZZZ'
                                               )));
   END mark_prev_hours_rows;

   PROCEDURE mark_prev_amount_rows (p_tim_id IN NUMBER)
   IS
   BEGIN
      UPDATE hxt_det_hours_worked_f
         SET pay_status = 'D',
             last_update_date = SYSDATE
       WHERE ROWID IN
                   (SELECT hrw.ROWID
                      FROM hxt_det_hours_worked_f hrw
                     WHERE hrw.tim_id = p_tim_id
                       AND hrw.pay_status = 'C'
                       AND hrw.amount IS NOT NULL
                       AND hrw.parent_id > 0
                       AND EXISTS ( SELECT 'X'
                                      FROM hxt_det_hours_worked_x retro
                                     WHERE hrw.parent_id = retro.parent_id
                                       AND retro.pay_status = 'R'
                                       AND hrw.amount = retro.amount
                                       AND hrw.amount IS NOT NULL
                                       AND hrw.assignment_id =
                                                          retro.assignment_id
				       and NVL(hrw.state_name,'ZZZZZZZZZZ')=
				       NVL(retro.state_name,'ZZZZZZZZZZ')
				       and NVL(hrw.county_name,'ZZZZZZZZZZ')=
				       NVL(retro.county_name,'ZZZZZZZZZZ')
				       and NVL(hrw.city_name,'ZZZZZZZZZZ')=
				       NVL(retro.city_name,'ZZZZZZZZZZ')
				       and NVL(hrw.zip_code,'ZZZZZZZZZZ')=
				       NVL(retro.zip_code,'ZZZZZZZZZZ')

                                       AND NVL (
                                             hrw.ffv_cost_center_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_cost_center_id,
                                                  999999999999999
                                               )
                                       AND hrw.element_type_id =
                                                        retro.element_type_id
                                       AND NVL (
                                              hrw.hourly_rate,
                                              999999999999999
                                           ) = NVL (
                                                  retro.hourly_rate,
                                                  999999999999999
                                               )

                                       AND NVL (
                                              hrw.location_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.location_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.ffv_rate_code_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_rate_code_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.rate_multiple,
                                              999999999999999
                                           ) = NVL (
                                                  retro.rate_multiple,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.separate_check_flag,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.separate_check_flag,
                                                  'ZZZZZZZZZZ'
                                               )
                                       AND NVL (
                                              hrw.fcl_tax_rule_code,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.fcl_tax_rule_code,
                                                  'ZZZZZZZZZZ'
                                               )));

      UPDATE hxt_det_hours_worked_f
         SET pay_status = 'A',
             last_update_date = SYSDATE
       WHERE ROWID IN
                   (SELECT hrw.ROWID
                      FROM hxt_det_hours_worked_f hrw
                     WHERE hrw.tim_id = p_tim_id
                       AND hrw.pay_status = 'C'
                       AND hrw.amount IS NOT NULL
                       AND hrw.parent_id > 0
                       AND EXISTS ( SELECT 'X'
                                      FROM hxt_det_hours_worked_x retro
                                     WHERE hrw.parent_id = retro.parent_id
                                       AND retro.pay_status = 'R'
                                       AND hrw.amount <> retro.amount
                                       AND hrw.amount IS NOT NULL
                                       AND hrw.assignment_id =
                                                          retro.assignment_id
				       and NVL(hrw.state_name,'ZZZZZZZZZZ')=
				       NVL(retro.state_name,'ZZZZZZZZZZ')
				       and NVL(hrw.county_name,'ZZZZZZZZZZ')=
				       NVL(retro.county_name,'ZZZZZZZZZZ')
				       and NVL(hrw.city_name,'ZZZZZZZZZZ')=
				       NVL(retro.city_name,'ZZZZZZZZZZ')
				       and NVL(hrw.zip_code,'ZZZZZZZZZZ')=
				       NVL(retro.zip_code,'ZZZZZZZZZZ')

                                       AND NVL (
                                              hrw.ffv_cost_center_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_cost_center_id,
                                                  999999999999999
                                               )
                                       AND hrw.element_type_id =
                                                        retro.element_type_id
                                       AND NVL (
                                              hrw.hourly_rate,
                                              999999999999999
                                           ) = NVL (
                                                  retro.hourly_rate,
                                                  999999999999999
                                               )

                                       AND NVL (
                                              hrw.location_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.location_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.ffv_rate_code_id,
                                              999999999999999
                                           ) = NVL (
                                                  retro.ffv_rate_code_id,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.rate_multiple,
                                              999999999999999
                                           ) = NVL (
                                                  retro.rate_multiple,
                                                  999999999999999
                                               )
                                       AND NVL (
                                              hrw.separate_check_flag,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.separate_check_flag,
                                                  'ZZZZZZZZZZ'
                                               )
                                       AND NVL (
                                              hrw.fcl_tax_rule_code,
                                              'ZZZZZZZZZZ'
                                           ) = NVL (
                                                  retro.fcl_tax_rule_code,
                                                  'ZZZZZZZZZZ'
                                               )));
   END mark_prev_amount_rows;

   PROCEDURE mark_retro_rows_complete (p_tim_id NUMBER)
   IS
   BEGIN
      UPDATE hxt_det_hours_worked_f
         SET pay_status = 'C',
             last_update_date = SYSDATE
       WHERE ROWID IN (SELECT hrw.ROWID
                         FROM hxt_det_hours_worked_x hrw
                        WHERE hrw.parent_id > 0
                          AND hrw.pay_status = 'R'
                          AND hrw.tim_id = p_tim_id);
   END mark_retro_rows_complete;

   PROCEDURE back_out_leftover_hours (p_batch_id NUMBER, p_tim_id NUMBER)
   IS

      -- Bug 9159142
      -- Added the below cursor to pick up input values for
      -- leftover hours to create backout rows.
      CURSOR get_prev_input_values(p_id  IN NUMBER)
          IS SELECT
                   attribute1,
		   attribute2,
		   attribute3,
		   attribute4,
		   attribute5,
		   attribute6,
		   attribute7,
		   attribute8,
		   attribute9,
		   attribute10,
		   attribute11,
		   attribute12,
		   attribute13,
		   attribute14,
		   attribute15
              FROM hxt_sum_hours_worked_f
             WHERE id = p_id
               AND effective_end_date <> hr_general.end_of_time
           ORDER BY effective_end_date DESC;

      CURSOR leftover_hours (p_tim_id NUMBER)
      IS
         SELECT hrw.ROWID hrw_rowid,
                NVL (hrw.retro_pbl_line_id, hrw.pbl_line_id) line_id,
                /* TA36 01/09/98 */
                asm.assignment_number, elt.element_name, --FORMS60
                eltv.hxt_premium_type, --SIR65
                                      eltv.hxt_premium_amount, --SIR65
                eltv.hxt_earning_category, --SIR65
                DECODE (
                   SIGN (
                        DECODE (
                           SIGN (  ptp.start_date
                                 - asm.effective_start_date),
                           1, ptp.start_date,
                           asm.effective_start_date
                        )
                      - elt.effective_start_date
                   ),
                   1, DECODE (
                         SIGN (  ptp.start_date
                               - asm.effective_start_date),
                         1, ptp.start_date,
                         asm.effective_start_date
                      ),
                   elt.effective_start_date
                )
                      from_date,
                DECODE (
                   SIGN (
                        DECODE (
                           SIGN (  ptp.end_date
                                 - asm.effective_end_date),
                           -1, ptp.end_date,
                           asm.effective_end_date
                        )
                      - elt.effective_end_date
                   ),
                   -1, DECODE (
                          SIGN (  ptp.end_date
                                - asm.effective_end_date),
                          -1, ptp.end_date,
                          asm.effective_end_date
                       ),
                   elt.effective_end_date
                ) TO_DATE,
                rate_multiple, hrw.hourly_rate, hrw.ffv_cost_center_id,
                /* fk - cost_center_code */
                pcak.concatenated_segments, pcak.segment1, pcak.segment2,
                pcak.segment3, pcak.segment4, pcak.segment5, pcak.segment6,
                pcak.segment7, pcak.segment8, pcak.segment9, pcak.segment10,
                pcak.segment11, pcak.segment12, pcak.segment13,
                pcak.segment14, pcak.segment15, pcak.segment16,
                pcak.segment17, pcak.segment18, pcak.segment19,
                pcak.segment20, pcak.segment21, pcak.segment22,
                pcak.segment23, pcak.segment24, pcak.segment25,
                pcak.segment26, pcak.segment27, pcak.segment28,
                pcak.segment29, pcak.segment30,

/*TA36       ffvl.flex_value labor_dist_code,*/
                loct.location_code locality_worked, --FORMS60
                                                   ffvr.flex_value rate_code,
                hrw.separate_check_flag,
                hrw.fcl_tax_rule_code tax_separately_flag, hrw.amount,
                hrw.hours hours_worked, hrw.element_type_id, --GLOBAL
                hcl.meaning reason, --GLOBAL
                                   hrw.date_worked, /* BSE107 */ ptp.time_period_id,
                /* BSE107 */
                hrw.assignment_id,                                 /* BSE107 */
		hrw.state_name,
		hrw.county_name,
		hrw.city_name,
		hrw.zip_code,
                hrw.parent_id
           FROM hxt_timecards_x tim,                  /* SIR416 PWM 21MAR00 */
                per_time_periods ptp,
                hxt_det_hours_worked_f hrw,
                hr_lookups hcl, --GLOBAL
                per_assignments_f asm,
                pay_element_types_f elt,
                hxt_pay_element_types_f_ddf_v eltv, --SIR65
                pay_cost_allocation_keyflex pcak,

/*TA36fnd_flex_values ffvl, */
                hr_locations_all_tl loct, --FORMS60
                hr_locations_no_join loc, --FORMS60
                fnd_flex_values ffvr
          WHERE hrw.ffv_rate_code_id = ffvr.flex_value_id(+)
            AND hrw.location_id = loc.location_id(+)

--BEGIN FORMS60
            AND loc.location_id = loct.location_id(+)
            AND DECODE (loct.location_id, NULL, '1', loct.LANGUAGE) =
                        DECODE (loct.location_id, NULL, '1', USERENV ('LANG'))

--END FORMS60
/*TA36AND hrw.ffv_labor_account_id = ffvl.flex_value_id(+)*/
            AND hrw.ffv_cost_center_id = pcak.cost_allocation_keyflex_id(+)
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND hrw.element_type_id = elt.element_type_id

/*GLOBAL        AND elt.rowid=eltv.row_id --SIR65 */
            AND elt.element_type_id = eltv.element_type_id        /* GLOBAL */
            AND hrw.date_worked BETWEEN eltv.effective_start_date /* GLOBAL */
                                    AND eltv.effective_end_date   /* GLOBAL */
            AND hrw.date_worked BETWEEN asm.effective_start_date
                                    AND asm.effective_end_date
            AND hrw.assignment_id = asm.assignment_id
            AND hrw.amount IS NULL

/* GLOBAL       AND hrw.parent_id > 0 */
            AND hrw.tim_id = tim.id
            AND tim.id = p_tim_id
            AND tim.time_period_id = ptp.time_period_id

--BEGIN GLOBAL
            AND hrw.date_worked BETWEEN NVL (
                                           hcl.start_date_active(+),
                                           hrw.date_worked
                                        )
                                    AND NVL (
                                           hcl.end_date_active(+),
                                           hrw.date_worked
                                        )
            AND hcl.lookup_type(+) = 'ELE_ENTRY_REASON'
            AND hcl.lookup_code(+) = hrw.fcl_earn_reason_code

--END GLOBAL
            AND hrw.pay_status = 'C'
            AND hrw.effective_end_date < hr_general.end_of_time; --SIR149 --FORMS60


--BSE128             l_leftover leftover_hours %ROWTYPE;
--      l_nextval         NUMBER (15);
      l_batch_line_id   NUMBER (15);
      l_retcode         NUMBER;                                   /* BSE107 */

--BEGIN GLOBAL
--  l_hourly_rate       pay_pdt_batch_lines.hourly_rate%TYPE := NULL; --SIR65
      l_hourly_rate     hxt_det_hours_worked_f.hourly_rate%TYPE   := NULL;


--CURSOR rate_paid_cur(c_line_id NUMBER) IS --SIR65
--SELECT pbl.hourly_rate                    --SIR65
--  FROM pay_pdt_batch_lines pbl            --SIR65
-- WHERE pbl.line_id=c_line_id;             --SIR65
      CURSOR rate_paid_cur (c_line_id NUMBER)
      IS
         SELECT pbl.value_1, pbl.value_2, pbl.value_3, pbl.value_4,
                pbl.value_5, pbl.value_6, pbl.value_7, pbl.value_8,
                pbl.value_9, pbl.value_10, pbl.value_11, pbl.value_12,
                pbl.value_13, pbl.value_14, pbl.value_15
           FROM pay_batch_lines pbl
          WHERE pbl.batch_line_id = c_line_id;

      TYPE input_value_record IS RECORD (
         SEQUENCE                      pay_input_values_f.input_value_id%TYPE,
         NAME                          pay_input_values_f_tl.NAME%TYPE, --FORMS60
         lookup                        pay_input_values_f.lookup_type%TYPE);

      TYPE input_values_table IS TABLE OF input_value_record
         INDEX BY BINARY_INTEGER;

      hxt_value         input_values_table;

      TYPE pbl_values_table IS TABLE OF pay_batch_lines.value_1%TYPE
         INDEX BY BINARY_INTEGER;

      pbl_value         pbl_values_table;

--END GLOBAL
      l_value_meaning   hr_lookups.meaning%TYPE;

      l_batch_sequence PAY_BATCH_LINES.BATCH_SEQUENCE%TYPE;

   BEGIN

      l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence(p_batch_id);

      FOR l_leftover IN leftover_hours (p_tim_id)
      LOOP
         --begin SIR65
         -- Check PayMIX first for the Original rate paid,
         -- if one exists use it.
         -- Added to always back out the original rate sent.

          OPEN get_prev_input_values(l_leftover.parent_id);
          FETCH get_prev_input_values INTO g_xiv_table(l_leftover.parent_id);
          CLOSE get_prev_input_values;

--BEGIN GLOBAL
    -- Initialize tables
         FOR i IN 1 .. 15
         LOOP
            hxt_value (i).SEQUENCE := NULL;
            hxt_value (i).NAME := NULL;
            hxt_value (i).lookup := NULL;
            pbl_value (i) := NULL;
         END LOOP;


--     OPEN rate_paid_cur(l_leftover.line_id);
--     FETCH rate_paid_cur INTO l_hourly_rate;
--     CLOSE rate_paid_cur;
         OPEN rate_paid_cur (l_leftover.line_id);
         FETCH rate_paid_cur INTO pbl_value (1),
                                  pbl_value (2),
                                  pbl_value (3),
                                  pbl_value (4),
                                  pbl_value (5),
                                  pbl_value (6),
                                  pbl_value (7),
                                  pbl_value (8),
                                  pbl_value (9),
                                  pbl_value (10),
                                  pbl_value (11),
                                  pbl_value (12),
                                  pbl_value (13),
                                  pbl_value (14),
                                  pbl_value (15);
         CLOSE rate_paid_cur;
         -- Get input values details for this element
         pay_paywsqee_pkg.get_input_value_details (
            l_leftover.element_type_id,
            l_leftover.date_worked,
            hxt_value (1).SEQUENCE,
            hxt_value (2).SEQUENCE,
            hxt_value (3).SEQUENCE,
            hxt_value (4).SEQUENCE,
            hxt_value (5).SEQUENCE,
            hxt_value (6).SEQUENCE,
            hxt_value (7).SEQUENCE,
            hxt_value (8).SEQUENCE,
            hxt_value (9).SEQUENCE,
            hxt_value (10).SEQUENCE,
            hxt_value (11).SEQUENCE,
            hxt_value (12).SEQUENCE,
            hxt_value (13).SEQUENCE,
            hxt_value (14).SEQUENCE,
            hxt_value (15).SEQUENCE,
            hxt_value (1).NAME,
            hxt_value (2).NAME,
            hxt_value (3).NAME,
            hxt_value (4).NAME,
            hxt_value (5).NAME,
            hxt_value (6).NAME,
            hxt_value (7).NAME,
            hxt_value (8).NAME,
            hxt_value (9).NAME,
            hxt_value (10).NAME,
            hxt_value (11).NAME,
            hxt_value (12).NAME,
            hxt_value (13).NAME,
            hxt_value (14).NAME,
            hxt_value (15).NAME,
            hxt_value (1).lookup,
            hxt_value (2).lookup,
            hxt_value (3).lookup,
            hxt_value (4).lookup,
            hxt_value (5).lookup,
            hxt_value (6).lookup,
            hxt_value (7).lookup,
            hxt_value (8).lookup,
            hxt_value (9).lookup,
            hxt_value (10).lookup,
            hxt_value (11).lookup,
            hxt_value (12).lookup,
            hxt_value (13).lookup,
            hxt_value (14).lookup,
            hxt_value (15).lookup
         );


--
-- In order to get the input-value logic work in diiferent legislations we need
-- to create (SEED) new lookups for 'Hours', 'Hourly Rate', 'Rate Multiple',
-- and 'Rate Code' with lookup_type of 'NAME_TRANSLATION' and lookup_code of
-- 'HOURS', 'HOURLY_RATE', 'RATE_MULTIPLE' and 'RATE_CODE' respectively.
-- Then the customers in different countries need to create the above input
-- values with the name which is directly translated from the above names for
-- OTM elements.
--
-- For example: In French the user must create an input value for 'Hours' to
-- be 'Heures' and then to determine which input value 'Heures' is associated
-- with we look at the hr_lookups and if we find an entry with lookup_type =
-- 'NAME_TRANSLATIONS' and lookup_code = 'HOURS' and Meaning to be 'Heures'
-- then we know that this input vale woul map to 'Hours'.
--
-- What need to be noted that it is the customer's responsibilty to create
-- input values which are the direct translation of 'Hours','Hourly Rate',
-- 'Pay Value' , 'Rate Multiple' and 'Rate Code'
--
         FOR i IN 1 .. 15
         LOOP

-- We need to get the lookup_code for the input_value names before processing
-- the further logic on the screen value for the input values.
--
            l_value_meaning :=
                 get_lookup_code (hxt_value (i).NAME, l_leftover.date_worked);

            --IF hxt_value(i).name = 'Rate' THEN
            IF l_value_meaning = 'HOURLY_RATE'
            THEN
               l_hourly_rate := pbl_value (i);
            END IF;
         END LOOP;


--END GLOBAL

         IF (   l_hourly_rate IS NULL
             OR l_leftover.hxt_premium_type = 'FACTOR'
            )
         THEN
            IF l_leftover.hxt_earning_category NOT IN ('REG', 'OVT', 'ABS')
            THEN
               IF l_leftover.hxt_premium_type = 'FACTOR'
               THEN
                  IF l_leftover.rate_multiple IS NULL
                  THEN
                     l_leftover.rate_multiple :=
                                                l_leftover.hxt_premium_amount;
                  END IF;

                  IF l_leftover.hourly_rate IS NULL
                  THEN
                     l_retcode :=
                           hxt_td_util.get_hourly_rate (
                              l_leftover.date_worked,
                              l_leftover.time_period_id,
                              l_leftover.assignment_id,
                              l_leftover.hourly_rate
                           );
                  END IF;
               ELSIF l_leftover.hxt_premium_type = 'RATE'
               THEN
                  IF l_leftover.hourly_rate IS NULL
                  THEN
                     l_leftover.hourly_rate := l_leftover.hxt_premium_amount;
                  END IF;
               END IF;
            ELSE
               --end SIR65
               --BEGIN BSE107 - OHM SPR200
               IF l_leftover.hourly_rate IS NULL
               THEN -- OHM205
                  l_retcode :=
                        hxt_td_util.get_hourly_rate (
                           l_leftover.date_worked,
                           l_leftover.time_period_id,
                           l_leftover.assignment_id,
                           l_leftover.hourly_rate
                        );
               END IF; -- OHM SPR200
            --END BSE107 - OHM SPR200
            --begin SIR65
            END IF;
         ELSE
            l_leftover.hourly_rate := l_hourly_rate;
         END IF;

         --end SIR65

--BEGIN GLOBAL
--     select pay_pdt_batch_lines_s.nextval
--         SELECT pay_batch_lines_s.NEXTVAL

--END GLOBAL
--           INTO l_nextval
--           FROM DUAL;


--BEGIN GLOBAL
--     INSERT into pay_pdt_batch_lines
--      (batch_id, line_id,
--       assignment_number, adjustment_type_code,
--       amount,
--       apply_this_period,
--       cost_allocation_keyflex_id,concatenated_segments,
--       segment1,segment2,segment3,segment4,
--       segment5,segment6,segment7,segment8,
--       segment9,segment10,segment11,segment12,
--       segment13,segment14,segment15,segment16,
--       segment17,segment18,segment19,segment20,
--       segment21,segment22,segment23,segment24,
--       segment25,segment26,segment27,segment28,
--       segment29,segment30,
--       element_name, from_date,
--       to_date, hourly_rate, inc_asc_balance,
--       labor_dist_code,
--       line_status, locality_worked, new_salary, pay_effective_date,
--       pcnt_increase, rate_code, rate_multiple, rating_code,
--       separate_check_flag, shift_type, state_worked,
--       tax_separately_flag, vol_ded_proc_ovd,
--       hours_worked)
--     VALUES(
--       p_batch_id, l_nextval,
--       l_leftover.assignment_number, '',
--       l_leftover.amount,
--       '',
--       l_leftover.ffv_cost_center_id,l_leftover.concatenated_segments,
--       l_leftover.segment1,l_leftover.segment2,l_leftover.segment3,l_leftover.segment4,
--       l_leftover.segment5,l_leftover.segment6,l_leftover.segment7,l_leftover.segment8,
--       l_leftover.segment9,l_leftover.segment10,l_leftover.segment11,l_leftover.segment12,
--       l_leftover.segment13,l_leftover.segment14,l_leftover.segment15,l_leftover.segment16,
--       l_leftover.segment17,l_leftover.segment18,l_leftover.segment19,l_leftover.segment20,
--       l_leftover.segment21,l_leftover.segment22,l_leftover.segment23,l_leftover.segment24,
--       l_leftover.segment25,l_leftover.segment26,l_leftover.segment27,l_leftover.segment28,
--       l_leftover.segment29,l_leftover.segment30,
--        l_leftover.element_name, '',
--       '', l_leftover.hourly_rate, '',
--/*TA36      l_leftover.labor_dist_code*/NULL,
--       '', l_leftover.locality_worked, '', '',
--       '', l_leftover.rate_code, l_leftover.rate_multiple, '',
--       l_leftover.separate_check_flag, '', '',
--       l_leftover.tax_separately_flag, '',
--       0 - l_leftover.hours_worked
--       );
         insert_pay_batch_lines (
            p_batch_id,
            l_batch_line_id,
            l_leftover.assignment_id,
            l_leftover.assignment_number,
            l_leftover.amount,
            l_leftover.ffv_cost_center_id,
            l_leftover.concatenated_segments,
            l_leftover.segment1,
            l_leftover.segment2,
            l_leftover.segment3,
            l_leftover.segment4,
            l_leftover.segment5,
            l_leftover.segment6,
            l_leftover.segment7,
            l_leftover.segment8,
            l_leftover.segment9,
            l_leftover.segment10,
            l_leftover.segment11,
            l_leftover.segment12,
            l_leftover.segment13,
            l_leftover.segment14,
            l_leftover.segment15,
            l_leftover.segment16,
            l_leftover.segment17,
            l_leftover.segment18,
            l_leftover.segment19,
            l_leftover.segment20,
            l_leftover.segment21,
            l_leftover.segment22,
            l_leftover.segment23,
            l_leftover.segment24,
            l_leftover.segment25,
            l_leftover.segment26,
            l_leftover.segment27,
            l_leftover.segment28,
            l_leftover.segment29,
            l_leftover.segment30,
            l_leftover.element_type_id,
            l_leftover.element_name,
            l_leftover.hourly_rate,
            l_leftover.locality_worked,
            l_leftover.rate_code,
            l_leftover.rate_multiple,
            l_leftover.separate_check_flag,
            l_leftover.tax_separately_flag,
            0-l_leftover.hours_worked,
            l_leftover.date_worked,
            l_leftover.reason,
            l_batch_sequence,
	    l_leftover.state_name,
	    l_leftover.county_name,
	    l_leftover.city_name,
	    l_leftover.zip_code,
            l_leftover.parent_id
         );


--END GLOBAL
         UPDATE hxt_det_hours_worked_f
            SET pay_status = 'B',
                last_update_date = SYSDATE,
                retro_pbl_line_id = l_batch_line_id -- OHM180
          WHERE ROWID = l_leftover.hrw_rowid;

          l_batch_sequence := l_batch_sequence + 1;

      END LOOP;
   END back_out_leftover_hours;

   PROCEDURE back_out_leftover_amount (p_batch_id NUMBER, p_tim_id NUMBER)
   IS
      CURSOR leftover_amount (p_tim_id NUMBER)
      IS
         SELECT hrw.ROWID hrw_rowid, asm.assignment_number, elt.element_name, --FORMS60
                DECODE (
                   SIGN (
                        DECODE (
                           SIGN (  ptp.start_date
                                 - asm.effective_start_date),
                           1, ptp.start_date,
                           asm.effective_start_date
                        )
                      - elt.effective_start_date
                   ),
                   1, DECODE (
                         SIGN (  ptp.start_date
                               - asm.effective_start_date),
                         1, ptp.start_date,
                         asm.effective_start_date
                      ),
                   elt.effective_start_date
                )
                      from_date,
                DECODE (
                   SIGN (
                        DECODE (
                           SIGN (  ptp.end_date
                                 - asm.effective_end_date),
                           -1, ptp.end_date,
                           asm.effective_end_date
                        )
                      - elt.effective_end_date
                   ),
                   -1, DECODE (
                          SIGN (  ptp.end_date
                                - asm.effective_end_date),
                          -1, ptp.end_date,
                          asm.effective_end_date
                       ),
                   elt.effective_end_date
                ) TO_DATE,
                rate_multiple, hrw.hourly_rate, hrw.ffv_cost_center_id,
                /* fk - cost_center_code */
                pcak.concatenated_segments, pcak.segment1, pcak.segment2,
                pcak.segment3, pcak.segment4, pcak.segment5, pcak.segment6,
                pcak.segment7, pcak.segment8, pcak.segment9, pcak.segment10,
                pcak.segment11, pcak.segment12, pcak.segment13,
                pcak.segment14, pcak.segment15, pcak.segment16,
                pcak.segment17, pcak.segment18, pcak.segment19,
                pcak.segment20, pcak.segment21, pcak.segment22,
                pcak.segment23, pcak.segment24, pcak.segment25,
                pcak.segment26, pcak.segment27, pcak.segment28,
                pcak.segment29, pcak.segment30,

/*TA36       ffvl.flex_value labor_dist_code,*/
                loct.location_code locality_worked, --FORMS60
                                                   ffvr.flex_value rate_code,
                hrw.separate_check_flag,
                hrw.fcl_tax_rule_code tax_separately_flag, hrw.amount,
                hrw.hours hours_worked, hrw.element_type_id, --GLOBAL
                hcl.meaning reason, --GLOBAL
                                   hrw.date_worked, /* BSE107 */ ptp.time_period_id,
                /* BSE107 */
                hrw.assignment_id ,
		hrw.state_name,
		hrw.county_name,
		hrw.city_name,
		hrw.zip_code
		/* BSE107 */
           FROM hxt_timecards_x tim,                  /* SIR416 PWM 21MAR00 */
                per_time_periods ptp,
                hxt_det_hours_worked_f hrw,
                hr_lookups hcl, --GLOBAL
                per_assignments_f asm,
                pay_element_types_f elt,
                pay_cost_allocation_keyflex pcak,

/*TA36fnd_flex_values ffvl, */
                hr_locations_all_tl loct, --FORMS60
                hr_locations_no_join loc, --FORMS60
                fnd_flex_values ffvr
          WHERE hrw.ffv_rate_code_id = ffvr.flex_value_id(+)
            AND hrw.location_id = loc.location_id(+)

--BEGIN FORMS60
            AND loc.location_id = loct.location_id(+)
            AND DECODE (loct.location_id, NULL, '1', loct.LANGUAGE) =
                        DECODE (loct.location_id, NULL, '1', USERENV ('LANG'))

--END FORMS60
/*TA36AND hrw.ffv_labor_account_id = ffvl.flex_value_id(+)*/
            AND hrw.ffv_cost_center_id = pcak.cost_allocation_keyflex_id(+)
            AND hrw.date_worked BETWEEN elt.effective_start_date
                                    AND elt.effective_end_date
            AND hrw.element_type_id = elt.element_type_id
            AND hrw.date_worked BETWEEN asm.effective_start_date
                                    AND asm.effective_end_date
            AND hrw.assignment_id = asm.assignment_id
            AND hrw.amount IS NOT NULL

/* GLOBAL   AND hrw.parent_id > 0 */
            AND hrw.tim_id = tim.id
            AND tim.id = p_tim_id
            AND tim.time_period_id = ptp.time_period_id

--BEGIN GLOBAL
            AND hrw.date_worked BETWEEN NVL (
                                           hcl.start_date_active(+),
                                           hrw.date_worked
                                        )
                                    AND NVL (
                                           hcl.end_date_active(+),
                                           hrw.date_worked
                                        )
            AND hcl.lookup_type(+) = 'ELE_ENTRY_REASON'
            AND hcl.lookup_code(+) = hrw.fcl_earn_reason_code

--END GLOBAL
            AND hrw.pay_status = 'C'
            AND hrw.effective_end_date < hr_general.end_of_time; --SIR149 --FORMS60

      l_leftover   leftover_amount%ROWTYPE;
--      l_nextval    NUMBER (15);
      l_batch_line_id NUMBER (15);
      l_retcode    NUMBER;                                        /* BSE107 */

      l_batch_sequence PAY_BATCH_LINES.BATCH_SEQUENCE%TYPE;

   BEGIN

      l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence(p_batch_id);

      FOR l_leftover IN leftover_amount (p_tim_id)
      LOOP

/* BEGIN BSE107 - OHM SPR200*/
--not needed   l_retcode := HXT_TD_UTIL.get_hourly_rate(l_leftover.date_worked,
--not needed                                           l_leftover.time_period_id,
--not needed                                           l_leftover.assignment_id,
--not needed                                           l_leftover.hourly_rate);

/* END BSE107 - OHM SPR200*/

--BEGIN GLOBAL
--     select pay_pdt_batch_lines_s.nextval
--         SELECT pay_batch_lines_s.NEXTVAL

--END GLOBAL
--           INTO l_nextval
--           FROM DUAL;


--BEGIN GLOBAL
--     INSERT into pay_pdt_batch_lines
--      (batch_id, line_id,
--       assignment_number, adjustment_type_code,
--       amount,
--       apply_this_period,
--       cost_allocation_keyflex_id,concatenated_segments,
--       segment1,segment2,segment3,segment4,
--       segment5,segment6,segment7,segment8,
--       segment9,segment10,segment11,segment12,
--       segment13,segment14,segment15,segment16,
--       segment17,segment18,segment19,segment20,
--       segment21,segment22,segment23,segment24,
--       segment25,segment26,segment27,segment28,
--       segment29,segment30,
--       element_name, from_date,
--       to_date, hourly_rate, inc_asc_balance,
--       labor_dist_code,
--       line_status, locality_worked, new_salary, pay_effective_date,
--       pcnt_increase, rate_code, rate_multiple, rating_code,
--       separate_check_flag, shift_type, state_worked,
--       tax_separately_flag, vol_ded_proc_ovd,
--       hours_worked)
--     VALUES(
--       p_batch_id, l_nextval,
--       l_leftover.assignment_number, '',
--       0 - l_leftover.amount,
--       '',
--       l_leftover.ffv_cost_center_id,l_leftover.concatenated_segments,
--       l_leftover.segment1,l_leftover.segment2,l_leftover.segment3,l_leftover.segment4,
--       l_leftover.segment5,l_leftover.segment6,l_leftover.segment7,l_leftover.segment8,
--       l_leftover.segment9,l_leftover.segment10,l_leftover.segment11,l_leftover.segment12,
--       l_leftover.segment13,l_leftover.segment14,l_leftover.segment15,l_leftover.segment16,
--       l_leftover.segment17,l_leftover.segment18,l_leftover.segment19,l_leftover.segment20,
--       l_leftover.segment21,l_leftover.segment22,l_leftover.segment23,l_leftover.segment24,
--       l_leftover.segment25,l_leftover.segment26,l_leftover.segment27,l_leftover.segment28,
--       l_leftover.segment29,l_leftover.segment30,
--       l_leftover.element_name, '',
--       '', l_leftover.hourly_rate, '',
--/*TA36      l_leftover.labor_dist_code*/NULL,
--       '', l_leftover.locality_worked, '', '',
--       '', l_leftover.rate_code, l_leftover.rate_multiple, '',
--       l_leftover.separate_check_flag, '', '',
--       l_leftover.tax_separately_flag, '',
--       l_leftover.hours_worked
--       );
         insert_pay_batch_lines (
            p_batch_id,
            l_batch_line_id,
            l_leftover.assignment_id,
            l_leftover.assignment_number,
              0
            - l_leftover.amount,
            l_leftover.ffv_cost_center_id,
            l_leftover.concatenated_segments,
            l_leftover.segment1,
            l_leftover.segment2,
            l_leftover.segment3,
            l_leftover.segment4,
            l_leftover.segment5,
            l_leftover.segment6,
            l_leftover.segment7,
            l_leftover.segment8,
            l_leftover.segment9,
            l_leftover.segment10,
            l_leftover.segment11,
            l_leftover.segment12,
            l_leftover.segment13,
            l_leftover.segment14,
            l_leftover.segment15,
            l_leftover.segment16,
            l_leftover.segment17,
            l_leftover.segment18,
            l_leftover.segment19,
            l_leftover.segment20,
            l_leftover.segment21,
            l_leftover.segment22,
            l_leftover.segment23,
            l_leftover.segment24,
            l_leftover.segment25,
            l_leftover.segment26,
            l_leftover.segment27,
            l_leftover.segment28,
            l_leftover.segment29,
            l_leftover.segment30,
            l_leftover.element_type_id,
            l_leftover.element_name,
            l_leftover.hourly_rate,
            l_leftover.locality_worked,
            l_leftover.rate_code,
            l_leftover.rate_multiple,
            l_leftover.separate_check_flag,
            l_leftover.tax_separately_flag,
            l_leftover.hours_worked,
            l_leftover.date_worked,
            l_leftover.reason,
            l_batch_sequence,
	    l_leftover.state_name,
	    l_leftover.county_name,
	    l_leftover.city_name,
	    l_leftover.zip_code
         );


--END GLOBAL
         UPDATE hxt_det_hours_worked_f
            SET pay_status = 'B',
                last_update_date = SYSDATE,
                retro_pbl_line_id = l_batch_line_id -- OHM180
          WHERE ROWID = l_leftover.hrw_rowid;

          l_batch_sequence := l_batch_sequence +1;

      END LOOP;
   END back_out_leftover_amount;
--begin
-- Bug 9494444
-- Added this procedure to pick up details to be updated
-- for Retrieval Dashboard.

PROCEDURE snap_retrieval_details(p_batch_id   IN NUMBER,
                                 p_tim_id     IN NUMBER)
IS

     TYPE VARCHARTAB IS TABLE OF VARCHAR2(100);
     TYPE NUMBERTAB  IS TABLE OF NUMBER;
     TYPE DATETAB    IS TABLE OF DATE;


    -- This cursor picks up the details for which
    -- time store has been modified.
    CURSOR get_retro_ids( p_batch_id   IN NUMBER,
                          p_tim_id     IN NUMBER)
        IS SELECT det.retro_pbl_line_id,
                  p_batch_id,
                  ROWIDTOCHAR(ret.ROWID)
             FROM hxt_det_hours_worked_f det,
                  hxc_ret_pay_latest_details ret,
                  pay_batch_lines pbl
            WHERE det.pay_status = 'B'
              AND det.effective_end_date <> hr_general.end_of_time
      	      AND det.pbl_line_id = ret.old_pbl_id
              AND ret.retro_batch_id  IS NULL
              AND det.tim_id = p_tim_id
              AND pbl.batch_id = p_batch_id
              AND det.retro_pbl_line_id = pbl.batch_line_id;


    -- This cursor picks up the details for which time store
    -- has not been modified, but still a backout occured.
    CURSOR get_retro_ids2( p_batch_id   IN NUMBER,
                           p_tim_id     IN NUMBER)
        IS SELECT det.retro_pbl_line_id,
                  p_batch_id,
                  ROWIDTOCHAR(ret.ROWID)
             FROM hxt_det_hours_worked_f det,
                  hxc_ret_pay_latest_details ret,
                  pay_batch_lines pbl
            WHERE det.pay_status = 'B'
              AND det.effective_end_date <> hr_general.end_of_time
              AND det.pbl_line_id = ret.pbl_id
              AND ret.retro_batch_id  IS NULL
              AND det.tim_id = p_tim_id
              AND pbl.batch_id = p_batch_id
              AND det.retro_pbl_line_id = pbl.batch_line_id;

    -- This picks Details for tbb id ovn combos which are not edited in
    -- Self service, but got modified.
    CURSOR get_modified_values(p_batch_id   IN NUMBER,
                               p_tim_id     IN NUMBER)
        IS SELECT det.retro_pbl_line_id,
	          det.retro_batch_id,
	          det.hours,
                  ROWIDTOCHAR(ret.ROWID)
             FROM hxt_det_hours_worked_f det,
                  hxt_sum_hours_worked_f sum,
	          hxc_ret_pay_latest_details ret
            WHERE det.tim_id = p_tim_id
              AND det.effective_end_date = hr_general.end_of_time
              AND sum.id = det.parent_id
              AND sum.effective_end_date = hr_general.end_of_time
              AND det.retro_pbl_line_id IS NOT NULL
              AND det.retro_batch_id  = p_batch_id
              AND ret.time_building_block_id = sum.time_building_block_id
              AND ret.object_version_number = sum.time_building_block_ovn
              AND ret.old_attribute1 = det.element_type_id ;



     ret_pbl_tab                   NUMBERTAB;
     ret_batch_tab                 NUMBERTAB;
     hrs_tab                       NUMBERTAB;
     rowtab                        VARCHARTAB;


     resource_id_tab               NUMBERTAB;
     time_building_block_id_tab    NUMBERTAB;
     approval_status_tab           VARCHARTAB;
     start_time_tab                DATETAB;
     stop_time_tab                 DATETAB;
     org_id_tab                    NUMBERTAB;
     business_group_id_tab         NUMBERTAB;
     timecard_id_tab               NUMBERTAB;
     attribute1_tab                VARCHARTAB;
     attribute2_tab                VARCHARTAB;
     attribute3_tab                VARCHARTAB;
     measure_tab                   NUMBERTAB;
     object_version_number_tab     NUMBERTAB;
     old_ovn_tab                   NUMBERTAB;
     old_measure_tab               NUMBERTAB;
     old_attribute1_tab            VARCHARTAB;
     old_attribute2_tab            VARCHARTAB;
     old_attribute3_tab            VARCHARTAB;
     pbl_id_tab                    NUMBERTAB;
     retro_pbl_id_tab              NUMBERTAB;
     old_pbl_id_tab                NUMBERTAB;
     request_id_tab                NUMBERTAB;
     old_request_id_tab            NUMBERTAB;
     batch_id_tab                  NUMBERTAB;
     retro_batch_id_tab            NUMBERTAB;
     old_batch_id_tab              NUMBERTAB;
     rowid_tab                     VARCHARTAB;



     -- This picks up details for those tbb id ovn combos for which new
     -- elements came up in explosion.
     CURSOR pick_new_details(p_tim_id   IN NUMBER,
                             p_batch_id IN NUMBER)
         IS  SELECT resource_id,
	            time_building_block_id,
	            approval_status,
	            start_time,
	            stop_time,
	            org_id,
	            business_group_id,
	            timecard_id,
	            element_type_id,
	            attribute2,
	            attribute3,
	            hours,
	            object_version_number,
	            old_ovn,
	            old_measure,
	            old_attribute1,
	            old_attribute2,
	            old_attribute3,
	            pbl_id,
	            retro_pbl_id,
	            old_pbl_id,
	            request_id,
	            old_request_id,
	            batch_id,
	            retro_batch_id,
	            old_batch_id
               FROM ( SELECT /*+ INDEX(det HXT_DET_HOURS_WORKED_F_SUM_FK) */
	                     ret.resource_id,
	                     ret.time_building_block_id,
	                     ret.approval_status,
	                     ret.start_time,
	                     ret.stop_time,
	                     ret.org_id,
	                     ret.business_group_id,
	                     ret.timecard_id,
	                     det.element_type_id,
	                     ret.attribute2,
	                     ret.attribute3,
	                     det.hours,
	                     ret.object_version_number,
	                     NULL old_ovn,
	                     NULL old_measure,
	                     NULL old_attribute1,
	                     NULL old_attribute2,
	                     NULL old_attribute3,
	                     det.retro_pbl_line_id pbl_id,
	                     NULL retro_pbl_id,
	                     NULL old_pbl_id,
	                     FND_GLOBAL.conc_request_id request_id,
	                     NULL old_request_id,
	                     det.retro_batch_id batch_id,
	                     NULL retro_batch_id,
	                     NULL old_batch_id,
                             RANK() OVER (PARTITION BY ret.time_building_block_id,
	                                               ret.object_version_number
						ORDER BY ret.ROWID) rank
                        FROM hxt_det_hours_worked_f det,
                             hxt_sum_hours_worked_f sum,
                             hxc_ret_pay_latest_details ret
                       WHERE det.parent_id = sum.id
                         AND det.tim_id = p_tim_id
                         AND det.hours <> 0
                         AND det.retro_batch_id  = p_batch_id
                         AND det.effective_end_date = hr_general.end_of_time
                         AND sum.effective_end_date = hr_general.end_of_time
                         AND sum.time_building_block_id = ret.time_building_block_id
                         AND sum.time_building_block_ovn = ret.object_version_number
                         AND (ret.batch_id IS NOT NULL
                            OR ret.retro_batch_id IS NOT NULL
                            OR ret.old_batch_id   IS NOT NULL)
                         AND NOT EXISTS ( SELECT 1
                                            FROM hxc_ret_pay_latest_details ret2
   		                           WHERE ret.time_building_block_id = ret2.time_building_block_id
					     AND ret.object_version_number = ret2.object_version_number
					     AND ret2.old_attribute1 = det.element_type_id )
                    )
              WHERE rank = 1;

     -- This cursor picks up entirely new details.
     CURSOR pick_new_sum(p_tim_id   IN NUMBER,
                         p_batch_id IN NUMBER)
         IS SELECT
	            ret.resource_id,
	            ret.time_building_block_id,
	            ret.approval_status,
	            ret.start_time,
	            ret.stop_time,
	            ret.org_id,
	            ret.business_group_id,
	            ret.timecard_id,
	            det.element_type_id,
	            ret.attribute2,
	            ret.attribute3,
	            det.hours,
	            ret.object_version_number,
	            ret.old_ovn,
	            ret.old_measure,
	            ret.old_attribute1,
	            ret.old_attribute2,
	            ret.old_attribute3,
              det.retro_pbl_line_id,
	            ret.retro_pbl_id,
	            ret.old_pbl_id,
	            FND_GLOBAL.conc_request_id,
	            ret.old_request_id,
	            det.retro_batch_id,
	            ret.retro_batch_id,
	            ret.old_batch_id,
                   ROWIDTOCHAR(ret.ROWID)
              FROM hxt_det_hours_worked_f det,
                   hxt_sum_hours_worked_f sum,
	           hxc_ret_pay_latest_details ret
             WHERE det.tim_id = p_tim_id
               AND det.effective_end_date = hr_general.end_of_time
               AND det.retro_batch_id   = p_batch_id
               AND det.parent_id = sum.id
               AND sum.effective_end_date = hr_general.end_of_time
               AND sum.time_building_block_id = ret.time_building_block_id
               AND sum.time_building_block_ovn = ret.object_version_number
               AND det.retro_pbl_line_id IS NOT NULL
               AND ret.pbl_id IS NULL
               AND ret.old_pbl_id IS NULL;





BEGIN

     -- Case 1
     -- First pick up those entries which are backed out because
     -- of a Time store change.
     -- Eg. tbb id 1234, ovn 1 Reg 8 hrs changed to tbbid 1234 ovn 2 Reg 7 hrs.
     OPEN get_retro_ids(p_batch_id,p_tim_id);
     FETCH get_retro_ids BULK COLLECT INTO ret_pbl_tab,
                                           ret_batch_tab,
                                           rowtab;

     CLOSE get_retro_ids;

     -- Update the relevant retro batch details.
     FORALL i IN ret_pbl_tab.FIRST..ret_pbl_tab.LAST
       UPDATE hxc_ret_pay_latest_details
          SET retro_batch_id = ret_batch_tab(i),
              retro_pbl_id   = ret_pbl_tab(i),
              request_id     = FND_GLOBAL.conc_request_id
        WHERE ROWID = CHARTOROWID(rowtab(i));

     -- Case 2
     -- Next, pick up those entries which are backed out not because
     -- of a Time store change, but an explosion change
     -- Eg. tbb id 1234, ovn 1 Reg 8 hrs still remains the same, but
     -- because another detail is changed now it has become Overtime 8 hrs.

     OPEN get_retro_ids2(p_batch_id,p_tim_id);
     FETCH get_retro_ids2 BULK COLLECT INTO ret_pbl_tab,
                                            ret_batch_tab,
                                            rowtab;

     CLOSE get_retro_ids2;

     -- Update the relevant retro batch details.
     FORALL i IN ret_pbl_tab.FIRST..ret_pbl_tab.LAST
       UPDATE hxc_ret_pay_latest_details
          SET retro_batch_id = ret_batch_tab(i),
              retro_pbl_id   = ret_pbl_tab(i),
              old_pbl_id     = pbl_id,
              old_batch_id   = batch_id,
              old_request_id = request_id,
              old_measure    = measure,
              old_attribute1 = attribute1,
              old_attribute2 = attribute2,
              attribute1     = NULL,
              attribute2     = NULL,
              measure        = NULL,
              pbl_id         = NULL,
              request_id     = FND_GLOBAL.conc_request_id,
              batch_id       = NULL
        WHERE ROWID = CHARTOROWID(rowtab(i));


     -- Case 3
     -- Now pick up the entries which are not Timestore changes, but actual
     -- explosion changes following the backouts in Case 2.
     -- Eg. tbb id 1234, Reg 12 hours it was.
     -- Earlier, it was
     --  1234    1     Reg 8 hrs
     --  1234    1     Ovt 4 hrs.
     --
     -- Now the detail is not changed, total hours not changed, but because
     -- of some other detail's change, it became
     --
     --  1234    1     Reg 10 hrs
     --  1234    1     Ovt 2 hrs.
     -- The retro or backout entries for the earlier 8 and 4 would have gone out
     -- via Case 2.  This cursor would update the new values.
     --
     OPEN get_modified_values(p_batch_id,p_tim_id);
     FETCH get_modified_values BULK COLLECT INTO ret_pbl_tab,
                                                 ret_batch_tab,
                                                 hrs_tab,
                                                 rowtab;

     CLOSE get_modified_values;

     FORALL i IN ret_pbl_tab.FIRST..ret_pbl_tab.LAST
       UPDATE hxc_ret_pay_latest_details
          SET batch_id = ret_batch_tab(i),
              pbl_id   = ret_pbl_tab(i),
              attribute1      = old_attribute1,
              measure         = hrs_tab(i),
              request_id      = fnd_global.conc_request_id
        WHERE ROWID = CHARTOROWID(rowtab(i));


     -- Case 4
     -- Now pick up the entries which are not Timestore changes, but actual
     -- explosion changes following the backouts in Case 2.
     -- Eg. tbb id 1234, Reg 12 hours it was.
     -- Earlier, it was
     --  1234    1     Reg 8 hrs
     --  1234    1     Ovt 4 hrs.
     --
     -- Now the detail is not changed, total hours not changed, but because
     -- of some other detail's change, it became
     --
     --  1234    1     Ovt 4 hrs
     --  1234    1     Dbt 8 hrs.
     -- The retro or backout entries for the earlier 8 and 4 would have gone out
     -- via Case 2.  This cursor would update the new values.
     -- Here, Dbt 8 hours is a new entry altogether, while Ovt 4 hours is just
     -- a change.  Change would have been picked up by the earlier cursor.  This
     -- cursor would pick up the new entry.
     -- The cursor will pick up one record for each time building block id from
     -- hxc_ret_pay_latest_details just to provide the relevant details which are
     -- not in hxt_det_hours_worked_f

     OPEN pick_new_details(p_tim_id,p_batch_id);
     FETCH pick_new_details BULK COLLECT INTO
                                             resource_id_tab,
                                             time_building_block_id_tab,
                                             approval_status_tab,
                                             start_time_tab,
                                             stop_time_tab,
                                             org_id_tab,
                                             business_group_id_tab,
                                             timecard_id_tab,
                                             attribute1_tab,
                                             attribute2_tab,
                                             attribute3_tab,
                                             measure_tab,
                                             object_version_number_tab,
                                             old_ovn_tab,
                                             old_measure_tab,
                                             old_attribute1_tab,
                                             old_attribute2_tab,
                                             old_attribute3_tab,
                                             pbl_id_tab,
                                             retro_pbl_id_tab,
                                             old_pbl_id_tab,
                                             request_id_tab,
                                             old_request_id_tab,
                                             batch_id_tab,
                                             retro_batch_id_tab,
                                             old_batch_id_tab;


     FORALL i IN old_batch_id_tab.FIRST..old_batch_id_tab.LAST
           INSERT INTO hxc_ret_pay_latest_details
                    ( resource_id,
                      time_building_block_id,
                      approval_status,
                      start_time,
                      stop_time,
                      org_id,
                      business_group_id,
                      timecard_id,
                      attribute1,
                      attribute2,
                      attribute3,
                      measure,
                      object_version_number,
                      old_ovn,
                      old_measure,
                      old_attribute1,
                      old_attribute2,
                      old_attribute3,
                      pbl_id,
                      retro_pbl_id,
                      old_pbl_id,
                      request_id,
                      old_request_id,
                      batch_id,
                      retro_batch_id,
                      old_batch_id)
             VALUES ( resource_id_tab(i),
                      time_building_block_id_tab(i),
                      approval_status_tab(i),
                      start_time_tab(i),
                      stop_time_tab(i),
                      org_id_tab(i),
                      business_group_id_tab(i),
                      timecard_id_tab(i),
                      attribute1_tab(i),
                      attribute2_tab(i),
                      attribute3_tab(i),
                      measure_tab(i),
                      object_version_number_tab(i),
                      old_ovn_tab(i),
                      old_measure_tab(i),
                      old_attribute1_tab(i),
                      old_attribute2_tab(i),
                      old_attribute3_tab(i),
                      pbl_id_tab(i),
                      retro_pbl_id_tab(i),
                      old_pbl_id_tab(i),
                      request_id_tab(i),
                      old_request_id_tab(i),
                      batch_id_tab(i),
                      retro_batch_id_tab(i),
                      old_batch_id_tab(i));


     CLOSE pick_new_details;


     -- Case 5
     -- This cursor will pick up completely new entries
     -- from Time store, ie, new summaries.
     OPEN pick_new_sum(p_tim_id,p_batch_id);
     FETCH pick_new_sum BULK COLLECT INTO    resource_id_tab,
                                             time_building_block_id_tab,
                                             approval_status_tab,
                                             start_time_tab,
                                             stop_time_tab,
                                             org_id_tab,
                                             business_group_id_tab,
                                             timecard_id_tab,
                                             attribute1_tab,
                                             attribute2_tab,
                                             attribute3_tab,
                                             measure_tab,
                                             object_version_number_tab,
                                             old_ovn_tab,
                                             old_measure_tab,
                                             old_attribute1_tab,
                                             old_attribute2_tab,
                                             old_attribute3_tab,
                                             pbl_id_tab,
                                             retro_pbl_id_tab,
                                             old_pbl_id_tab,
                                             request_id_tab,
                                             old_request_id_tab,
                                             batch_id_tab,
                                             retro_batch_id_tab,
                                             old_batch_id_tab,
                                             rowid_tab;

        -- Delete the entries already there.
        FORALL i IN rowid_tab.FIRST..rowid_tab.LAST
           DELETE FROM hxc_ret_pay_latest_details
                 WHERE ROWID = CHARTOROWID(rowid_tab(i));

        -- Insert the new entries.
        FORALL i IN rowid_tab.FIRST..rowid_tab.LAST
           INSERT INTO hxc_ret_pay_latest_details
                    ( resource_id,
                      time_building_block_id,
                      approval_status,
                      start_time,
                      stop_time,
                      org_id,
                      business_group_id,
                      timecard_id,
                      attribute1,
                      attribute2,
                      attribute3,
                      measure,
                      object_version_number,
                      old_ovn,
                      old_measure,
                      old_attribute1,
                      old_attribute2,
                      old_attribute3,
                      pbl_id,
                      retro_pbl_id,
                      old_pbl_id,
                      request_id,
                      old_request_id,
                      batch_id,
                      retro_batch_id,
                      old_batch_id)
             VALUES ( resource_id_tab(i),
                      time_building_block_id_tab(i),
                      approval_status_tab(i),
                      start_time_tab(i),
                      stop_time_tab(i),
                      org_id_tab(i),
                      business_group_id_tab(i),
                      timecard_id_tab(i),
                      attribute1_tab(i),
                      attribute2_tab(i),
                      attribute3_tab(i),
                      measure_tab(i),
                      object_version_number_tab(i),
                      old_ovn_tab(i),
                      old_measure_tab(i),
                      old_attribute1_tab(i),
                      old_attribute2_tab(i),
                      old_attribute3_tab(i),
                      pbl_id_tab(i),
                      retro_pbl_id_tab(i),
                      old_pbl_id_tab(i),
                      request_id_tab(i),
                      old_request_id_tab(i),
                      batch_id_tab(i),
                      retro_batch_id_tab(i),
                      old_batch_id_tab(i));






END snap_retrieval_details;







END hxt_retro_mix;

/
