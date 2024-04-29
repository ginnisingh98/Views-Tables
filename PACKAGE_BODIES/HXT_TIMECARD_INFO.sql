--------------------------------------------------------
--  DDL for Package Body HXT_TIMECARD_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIMECARD_INFO" AS
/* $Header: hxctimotm.pkb 120.2 2005/09/23 09:37:04 nissharm noship $ */

   g_debug boolean := hr_utility.debug_enabled;

   PROCEDURE get_holiday_info (
      p_date     IN              DATE,
      p_hcl_id   IN              NUMBER,
      p_elt_id   OUT NOCOPY      NUMBER,
      p_hours    OUT NOCOPY      NUMBER
   );

   FUNCTION convert_time (
      p_date       DATE,
      p_time_in    NUMBER,
      p_time_out   NUMBER DEFAULT NULL
   )
      RETURN DATE;

   FUNCTION convert_timecard_time (
      p_date       DATE,
      p_time_in    NUMBER,
      p_time_out   NUMBER DEFAULT NULL
   )
      RETURN DATE;


-- Get all assignment information for the resource_id
   CURSOR g_asg_cur (p_resource_id NUMBER, p_start_time DATE, p_stop_time DATE)
   IS
      SELECT paf.person_id resource_id, paf.assignment_id,
             paf.business_group_id, paf.assignment_number,
             aeiv.hxt_rotation_plan rtp_id, aeiv.hxt_earning_policy egp_id,
             egp.hcl_id, aeiv.hxt_rotation_plan
        FROM per_assignments_f paf,
             hxt_per_aei_ddf_v aeiv,
             hxt_earning_policies egp,
             per_assignment_status_types typ
       WHERE aeiv.assignment_id = paf.assignment_id
         AND egp.id = aeiv.hxt_earning_policy
         AND paf.effective_start_date <= p_stop_time
         AND paf.effective_end_date >= p_start_time
         AND aeiv.effective_start_date <= p_stop_time
         AND aeiv.effective_end_date >= p_start_time
         AND paf.person_id = p_resource_id
         AND paf.primary_flag = 'Y'
         AND paf.assignment_status_type_id = typ.assignment_status_type_id
         AND typ.per_system_status = 'ACTIVE_ASSIGN';


--smummini : Added above three checks for getting active primary assignment
--           Bug num : 2397763

   g_asg_rec   g_asg_cur%ROWTYPE;


--------------------------------------------------------------------------------
                                -- PUBLIC --
--------------------------------------------------------------------------------
   PROCEDURE generate_time (
      p_resource_id      IN            NUMBER,
      p_start_time       IN            DATE,
      p_stop_time        IN            DATE,
      p_app_attributes      OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info,
      p_timecard            OUT NOCOPY hxc_self_service_time_deposit.timecard_info,
      p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
   )
   IS
      -- Declare local variables
      l_person_id    per_people_f.person_id%TYPE   := p_resource_id;
      l_start_time   DATE                          := p_start_time;
      l_stop_time    DATE                          := p_stop_time;
      l_row_num      NUMBER                        := 0;
      l_error        EXCEPTION;
      l_rtp_err      EXCEPTION;
      l_egp_err      EXCEPTION;

   BEGIN
      g_debug := hr_utility.debug_enabled;

      if g_debug then
      	hr_utility.set_location ('Generate_Time', 10);
      end if;
      IF p_app_attributes.COUNT > 0
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 20);
         end if;
         FOR l IN p_app_attributes.FIRST .. p_app_attributes.LAST
         LOOP
            p_app_attributes (l).time_attribute_id := NULL;
            p_app_attributes (l).building_block_id := NULL;
            p_app_attributes (l).attribute_name := NULL;
            p_app_attributes (l).attribute_value := NULL;
            p_app_attributes (l).bld_blk_info_type := NULL;
            p_app_attributes (l).CATEGORY := NULL;
            p_app_attributes (l).updated := NULL;
            p_app_attributes (l).changed := NULL;
         END LOOP;
         p_app_attributes.DELETE;
      END IF;
      IF p_timecard.COUNT > 0
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 30);
         end if;
         FOR l IN p_timecard.FIRST .. p_timecard.LAST
         LOOP
            p_timecard (l).time_building_block_id := NULL;
            p_timecard (l).TYPE := NULL;
            p_timecard (l).measure := NULL;
            p_timecard (l).unit_of_measure := NULL;
            p_timecard (l).start_time := NULL;
            p_timecard (l).stop_time := NULL;
            p_timecard (l).parent_building_block_id := NULL;
            p_timecard (l).parent_is_new := NULL;
            p_timecard (l).SCOPE := NULL;
            p_timecard (l).object_version_number := NULL;
            p_timecard (l).approval_status := NULL;
            p_timecard (l).resource_id := NULL;
            p_timecard (l).resource_type := NULL;
            p_timecard (l).approval_style_id := NULL;
            p_timecard (l).date_from := NULL;
            p_timecard (l).date_to := NULL;
            p_timecard (l).comment_text := NULL;
            p_timecard (l).parent_building_block_ovn := NULL;
            p_timecard (l).NEW := NULL;
            p_timecard (l).changed := NULL;
         END LOOP;
         p_timecard.DELETE;
      END IF;
      /* Start of Main Cursor */

      if g_debug then
      	hr_utility.trace('l_person_id :'||l_person_id);
      	hr_utility.trace('l_start_time:'||l_start_time);
      	hr_utility.trace('l_stop_time :'||l_stop_time);
      end if;

      FOR asg_rec IN g_asg_cur (l_person_id, l_start_time, l_stop_time)
      LOOP
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 40);
         end if;
         g_asg_rec := asg_rec;
         l_row_num :=   l_row_num
                      + 1;
         if g_debug then
         	hr_utility.TRACE (   'l_row_num :'
         	                  || l_row_num);
         end if;
         IF g_asg_rec.egp_id IS NULL
         THEN
            if g_debug then
            	hr_utility.set_location ('Generate_Time', 50);
            end if;
            RAISE l_egp_err;
         END IF;
         IF g_asg_rec.rtp_id IS NULL
         THEN
            if g_debug then
            	hr_utility.set_location ('Generate_Time', 60);
            end if;
            RAISE l_rtp_err;
         END IF;
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 70);

         	hr_utility.trace('l_start_time     :'||l_start_time);
         	hr_utility.trace('l_stop_time      :'||l_stop_time);
         	hr_utility.trace('g_asg_rec.rtp_id :'||g_asg_rec.rtp_id);
         end if;

         gen_rot_plan (
            l_start_time,
            l_stop_time,
            g_asg_rec.rtp_id,
            p_app_attributes,
            p_timecard
         );

         if g_debug then
         	hr_utility.set_location ('Generate_Time', 80);
         end if;
         FOR l_cnt IN
             p_timecard.FIRST .. p_timecard.LAST
         LOOP
            if g_debug then
            	hr_utility.TRACE (
            	      'p_timecard BB ID is : '
            	   || TO_CHAR (
            	         p_timecard (l_cnt).time_building_block_id
            	      )
            	);
            	hr_utility.TRACE (
            	      'p_timecard Scope is : '
            	   || (
            	         p_timecard (l_cnt).scope
            	      )
            	);
            	 hr_utility.TRACE (
            	      'p_timecard start_time is : '
            	   || TO_CHAR (p_timecard (l_cnt).start_time,
            	                                 'dd-mon-yyyy hh24:mi:ss')
            	);
            	 hr_utility.TRACE (
            	      'p_timecard stop_time is : '
            	   || TO_CHAR (p_timecard (l_cnt).stop_time,
            	                                 'dd-mon-yyyy hh24:mi:ss')
            	);
            end if;
         END LOOP;

         if g_debug then
         	hr_utility.set_location ('Generate_Time', 90);
         end if;

      END LOOP;

      if g_debug then
      	hr_utility.set_location ('Generate_Time', 100);
      end if;

      IF l_row_num = 0
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 110);
         end if;
         RAISE l_error;
      END IF;


   EXCEPTION
      WHEN l_error
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 100);
         end if;
         --if g_debug then
         	--hr_utility.TRACE (   'l_row_num:'
         	--                   || l_row_num);
         --end if;
         --fnd_message.set_name ('HXC', 'HXC_366279_NO_WRKPLAN_ERR');
         --fnd_message.raise_error;
	     if g_debug then
	     	hr_utility.trace('Adding Up message NoWorkplan');
	     end if;
	     hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		      => 'HXC_366279_NO_WRKPLAN_ERR'
                    ,   p_message_level		      => 'ERROR'
                    ,   p_message_field		      => NULL
                    ,   p_message_tokens	      => NULL
                    ,   p_application_short_name  => 'HXC'
		            ,   p_time_building_block_id  => NULL
		            ,   p_time_building_block_ovn => NULL
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );
	     if g_debug then
	     	hr_utility.trace('The count of p_messages is: ' || p_messages.count);
	     end if;
      WHEN l_egp_err
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 110);
         end if;
         --fnd_message.set_name ('HXC', 'HXC_366280_ERR_NO_ERN_POL');
         --fnd_message.raise_error;
	     hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		      => 'HXC_366280_ERR_NO_ERN_POL'
                    ,   p_message_level		      => 'ERROR'
                    ,   p_message_field		      => NULL
                    ,   p_message_tokens	      => NULL
                    ,   p_application_short_name  => 'HXC'
		            ,   p_time_building_block_id  => NULL
                    ,   p_time_building_block_ovn => NULL
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );
         if g_debug then
         	hr_utility.trace('The count of p_messages is: ' || p_messages.count);
         end if;
      WHEN l_rtp_err
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 120);
         end if;
         --if g_debug then
         	--hr_utility.TRACE (   'ROT_PLAN_ERR:'
         	                  --|| g_asg_rec.rtp_id);
         --end if;
         --fnd_message.set_name ('HXC', 'HXC_366281_ERR_NO_ROT_PLAN');
         --fnd_message.raise_error;
	     hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		      => 'HXC_366281_ERR_NO_ROT_PLAN'
                    ,   p_message_level		      => 'ERROR'
                    ,   p_message_field		      => NULL
                    ,   p_message_tokens	      => NULL
                    ,   p_application_short_name  => 'HXC'
		            ,   p_time_building_block_id  => NULL
                    ,   p_time_building_block_ovn => NULL
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );
         if g_debug then
         	hr_utility.trace('The count of p_messages is: ' || p_messages.count);
         end if;

      WHEN OTHERS
      THEN
         if g_debug then
         	hr_utility.set_location ('Generate_Time', 130);
         end if;
         --fnd_message.set_name ('HXC', 'HXC_366282_AUTOGEN_ERR');
         --fnd_message.raise_error;
	     hxc_timecard_message_helper.adderrortocollection (
                        p_messages                => p_messages
                    ,   p_message_name 		      => 'HXC_366282_AUTOGEN_ERR'
                    ,   p_message_level		      => 'ERROR'
                    ,   p_message_field		      => NULL
                    ,   p_message_tokens	      => NULL
                    ,   p_application_short_name  => 'HXC'
		            ,   p_time_building_block_id  => NULL
                    ,   p_time_building_block_ovn => NULL
                    ,   p_time_attribute_id       => NULL
                    ,   p_time_attribute_ovn      => NULL );
         if g_debug then
         	hr_utility.trace('The count of p_messages is: ' || p_messages.count);
         end if;
   END;
--------------------------------------------------------------------------------
   PROCEDURE get_work_day (
      p_date             IN              DATE,
      p_work_id          IN              NUMBER,
      p_standard_start   OUT NOCOPY      NUMBER,
      p_standard_stop    OUT NOCOPY      NUMBER,
      p_hours            OUT NOCOPY      NUMBER
   )
   IS
      --
      --  Procedure GET_WORK_DAY
      --  Purpose:  Gets shift start and stop time,and shift hours for the person's
      --            assigned shift on an input date

      CURSOR work_day (p_wp_id NUMBER, p_date DATE) --, p_weekday VARCHAR2)
      IS
         SELECT sht.standard_start, sht.standard_stop, sht.hours
           FROM hxt_shifts sht,
                hxt_weekly_work_schedules wws,
                hxt_work_shifts wsh
          WHERE wsh.week_day =   hxt_util.get_week_day(p_date)--p_weekday --to_char(p_date,'DY')
            AND wws.id = wsh.tws_id
            AND p_date BETWEEN wws.date_from AND NVL (wws.date_to, p_date)
            AND wws.id = p_work_id
            AND sht.id = wsh.sht_id;

      --l_lookup_code   VARCHAR2 (30);
   BEGIN
      g_debug := hr_utility.debug_enabled;

      if g_debug then
      	hr_utility.set_location ('Get_Work_Day', 10);
      end if;

      -- Select the lookup cod efo rthe weekday from hr_lookups in order to
      -- avoid translation issues

      /*SELECT lookup_code
        INTO l_lookup_code
        FROM fnd_lookup_values --hr_lookups
       WHERE lookup_type = 'HXT_DAY_OF_WEEK'
         AND UPPER (RTRIM (meaning)) = UPPER (RTRIM (TO_CHAR (p_date, 'DAY')));

      if g_debug then
      	hr_utility.TRACE (   'l_lookup_code :'
      	                  || l_lookup_code);
      	hr_utility.TRACE (   'p_work_id     :'
      	                  || p_work_id);
      	hr_utility.TRACE (   'p_date        :'
      	                  || p_date);
      	hr_utility.set_location ('Get_Work_Day', 20);
      end if;
      */
      OPEN work_day (p_work_id, p_date); --, l_lookup_code);
      FETCH work_day INTO p_standard_start, p_standard_stop, p_hours;
      CLOSE work_day;
      if g_debug then
      	hr_utility.TRACE (   'p_standard_start :'
      	                  || p_standard_start);
      	hr_utility.TRACE (   'p_standard_stop  :'
      	                  || p_standard_stop);
      end if;
   EXCEPTION
      WHEN OTHERS
      THEN
         if g_debug then
         	hr_utility.set_location ('Get_Work_Day', 30);
         end if;
         fnd_message.set_name ('HXC', 'HXC_366283_GET_WRK_DAY_ERR');
   END get_work_day;


--------------------------------------------------------------------------------
   PROCEDURE gen_work_plan (
      p_start                            DATE,
      p_end                              DATE,
      p_tws_id                           NUMBER,
      p_app_attributes   IN OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_timecard         IN OUT NOCOPY   hxc_self_service_time_deposit.timecard_info
   )
   IS
      --  Purpose
      --    Generate hours worked records FOR the employee who has a work plan.
      l_days                       NUMBER;
      l_elt_id                     NUMBER;
      p_elt_id                     NUMBER;
      l_time_in                    DATE;
      l_time_out                   DATE;
      l_time_in_timecard           DATE;
      l_time_out_timecard          DATE;
      l_time_in_day                DATE;
      l_time_out_day               DATE;
      l_standard_start             NUMBER;
      l_standard_stop              NUMBER;
      l_hours                      NUMBER;
      p_hours                      NUMBER;
      l_hcl_hours                  NUMBER;
      l_type                       VARCHAR2 (9);
      l_next_index                 BINARY_INTEGER := 0;
      l_time_building_block_id     NUMBER         := 0;
      l_time_attribute_id          NUMBER         := 0;
      l_parent_building_block_id   NUMBER;
      l_parent_id                  NUMBER;

      CURSOR c_get_base_hours_type (p_earning_policy_id NUMBER)
      IS
         SELECT egr.element_type_id
           FROM hxt_earning_rules egr, hxt_add_elem_info_f aei
          WHERE egr.egp_id = p_earning_policy_id
            AND aei.element_type_id = egr.element_type_id
            AND aei.earning_category = 'REG';
      l_update_flag varchar2(1) := 'N';

   BEGIN
      g_debug := hr_utility.debug_enabled;

      if g_debug then
      	hr_utility.set_location ('Gen_Work_Plan', 10);
      end if;
      l_update_flag := 'N';

   -- Get number of days to be generated
      l_days :=   p_end
                - p_start;

      if g_debug then
      	hr_utility.TRACE (   'l_days :'
      	                  || l_days);
      end if;
      IF l_days < 0
      THEN
         if g_debug then
         	hr_utility.set_location ('Gen_Work_Plan', 20);
         end if;
         fnd_message.set_name ('HXC', 'HXC_366284_NUM_DAYS_ERR');
         fnd_message.raise_error;
      END IF;

      if g_debug then
      	hr_utility.TRACE (   'l_days:'
      	                  || l_days);
      end if;
--Loop through number of days passed
      FOR i IN 0 .. l_days
      LOOP
         get_work_day (
              p_start
            + i,
            p_tws_id,
            l_standard_start,
            l_standard_stop,
            l_hours
         );
         --Calculate Start Date and End Date for TIMECARD and DAY Scope
         l_time_in_timecard := convert_timecard_time (p_start, 000000);

         if g_debug then
         	hr_utility.trace('l_time_in_timecard:'||l_time_in_timecard);
         	hr_utility.set_location ('Gen_Work_Plan', 21);
         end if;

         l_time_out_timecard := convert_timecard_time (p_end, 000000, 000000);
         if g_debug then
         	hr_utility.trace('l_time_out_timecard:'||l_time_out_timecard);
         	hr_utility.trace('FYI...........');
         end if;

         IF p_timecard.count > 0 THEN
           if g_debug then
           	hr_utility.set_location ('Gen_Work_Plan', 22);
           end if;
           FOR l_cnt IN
             p_timecard.FIRST .. p_timecard.LAST
           LOOP
            if g_debug then
            	hr_utility.TRACE (
            	      'p_timecard BB ID is : '
            	   || TO_CHAR (
            	         p_timecard (l_cnt).time_building_block_id
            	      )
            	);
            	hr_utility.TRACE (
            	      'p_timecard Scope is : '
            	   || (
            	         p_timecard (l_cnt).scope
            	      )
            	);
            	 hr_utility.TRACE (
            	      'p_timecard start_time is : '
            	   || TO_CHAR (p_timecard (l_cnt).start_time,
            	                                 'dd-mon-yyyy hh24:mi:ss')
            	);
            	 hr_utility.TRACE (
            	      'p_timecard stop_time is : '
            	   || TO_CHAR (p_timecard (l_cnt).stop_time,
            	                                 'dd-mon-yyyy hh24:mi:ss')
            	);
            end if;
           END LOOP;
         END IF;
         if g_debug then
         	hr_utility.trace('END FYI..............');
         end if;

      -- Check if a row with the TIMECARD Scope has already been populated in
      -- the pl/sql building block table. If so, then we do not need to create
      -- a new row with TIMECARD Scope, instead extend the existing Timecard
      -- scope block if you come accross another one with the end date of the
      -- later Timecard.
         IF p_timecard.count > 0 THEN
           if g_debug then
           	hr_utility.set_location ('Gen_Work_Plan', 23);
           end if;
           FOR l_timecard IN
             p_timecard.FIRST .. p_timecard.LAST
           LOOP
             if g_debug then
             	hr_utility.set_location ('Gen_Work_Plan', 25);
             end if;

             IF (p_timecard (l_timecard).SCOPE = 'TIMECARD')
             THEN
                l_parent_id := p_timecard (l_timecard).time_building_block_id;
                if g_debug then
                	hr_utility.set_location ('Gen_Work_Plan', 26);
                	hr_utility.trace('p_timecard(l_timecard).stop_time:'
                	       ||p_timecard(l_timecard).stop_time);
                	hr_utility.trace('l_time_out_timecard:'
                	       ||l_time_out_timecard);
                end if;

                IF p_timecard(l_timecard).stop_time < l_time_out_timecard
                THEN
                  if g_debug then
                  	hr_utility.set_location ('Gen_Work_Plan', 26.5);
                  end if;
                  p_timecard(l_timecard).stop_time := l_time_out_timecard;
                  l_update_flag := 'Y';
                END IF;

                if g_debug then
                	hr_utility.set_location ('Gen_Work_Plan', 27);
                end if;
               EXIT;
               if g_debug then
               	hr_utility.set_location ('Gen_Work_Plan', 28);
               end if;
             END IF;
           END LOOP;
         END IF;

         l_time_in_day := convert_timecard_time (  p_start
                                                 + i, 000000);
         l_time_out_day :=
                        convert_timecard_time (  p_start
                                               + i, 000000, 235959);
         if g_debug then
         	hr_utility.TRACE (   'hours from get_work_day:'
         	                  || l_hours);
         end if;
         -- Create summary record
         IF (l_hours IS NULL)
         THEN
            l_type := 'RANGE';
            l_time_in := convert_time (  p_start
                                       + i, l_standard_start);
            l_time_out := convert_time (
                               p_start
                             + i,
                             l_standard_start,
                             l_standard_stop
                          );
         --   l_hours    := NULL;--24*(l_time_out - l_time_in);
         ELSE
            l_type := 'MEASURE';
            l_time_in := NULL; --p_start + i ;
            l_time_out := NULL; --p_start + i ;
         END IF;
         l_elt_id := NULL;
         p_hours := l_hours;
         if g_debug then
         	hr_utility.TRACE (   'p_hours:'
         	                  || p_hours);
         end if;
         get_holiday_info (
              p_start
            + i,
            g_asg_rec.hcl_id,
            l_elt_id,
            l_hcl_hours
         );
         IF l_elt_id IS NOT NULL
         THEN
            p_elt_id := l_elt_id;
            --l_time_in  := p_start + i;
            --l_time_out := p_start + i;
            IF (fnd_profile.VALUE ('HXT_HOL_HOURS_FROM_HOL_CAL') = 'Y')
            THEN
               l_type := 'MEASURE';
               p_hours := l_hcl_hours;
               l_time_in := NULL;
               l_time_out := NULL;
            END IF;
         ELSE
            OPEN c_get_base_hours_type (g_asg_rec.egp_id);
            FETCH c_get_base_hours_type INTO p_elt_id;
            CLOSE c_get_base_hours_type;
         END IF;

         if g_debug then
         	hr_utility.TRACE (   'p_hours after getting holday info:'
         	                  || p_hours);
         end if;

         IF i = 0 and l_update_flag = 'N'
         THEN
            if g_debug then
            	hr_utility.TRACE (
            	   '---------- Entering TIMECARD Scope -------------------'
            	);
            end if;
            -- Enter the TIMECARD Scope in the pl/sql table
            l_next_index :=   p_timecard.COUNT
                            + 1;
            /* Fix for bug 2397763 */
            /*l_time_building_block_id   := l_time_building_block_id + 1;*/
            l_time_building_block_id := p_timecard.COUNT;
            l_parent_id := l_time_building_block_id;
            p_timecard (l_next_index).time_building_block_id :=
                                                     l_time_building_block_id;
            p_timecard (l_next_index).TYPE := 'RANGE';
            p_timecard (l_next_index).measure := NULL;
            p_timecard (l_next_index).unit_of_measure := 'HOURS';
            p_timecard (l_next_index).start_time := l_time_in_timecard;
            p_timecard (l_next_index).stop_time := l_time_out_timecard;
            p_timecard (l_next_index).parent_building_block_id := NULL;
            p_timecard (l_next_index).parent_is_new := NULL;
            p_timecard (l_next_index).SCOPE := 'TIMECARD';
            p_timecard (l_next_index).object_version_number := NULL;
            p_timecard (l_next_index).approval_status := NULL;
            p_timecard (l_next_index).resource_id := g_asg_rec.resource_id;
            p_timecard (l_next_index).resource_type := 'PERSON';
            p_timecard (l_next_index).approval_style_id := NULL;
            p_timecard (l_next_index).date_from := NULL;
            p_timecard (l_next_index).date_to := NULL;
            p_timecard (l_next_index).comment_text := NULL;
            p_timecard (l_next_index).parent_building_block_ovn := NULL;
            p_timecard (l_next_index).NEW := 'Y';
            p_timecard (l_next_index).changed := NULL;
            if g_debug then
            	hr_utility.TRACE (
            	      'TIME_BUILDING_BLOCK_ID:'
            	   || p_timecard (l_next_index).time_building_block_id
            	);
            	hr_utility.TRACE (
            	      'MEASURE :'
            	   || p_timecard (l_next_index).measure
            	);
            	hr_utility.TRACE (
            	      'START_TIME :'
            	   || p_timecard (l_next_index).start_time
            	);
            	hr_utility.TRACE (
            	      'STOP_TIME :'
            	   || p_timecard (l_next_index).stop_time
            	);
            	hr_utility.TRACE (
            	      'PARENT_BUILDING_BLOCK_ID :'
            	   || p_timecard (l_next_index).parent_building_block_id
            	);
            	hr_utility.TRACE (   'SCOPE :'
            	                  || p_timecard (l_next_index).SCOPE);
            	hr_utility.TRACE (
            	      'RESOURCE_ID :'
            	   || p_timecard (l_next_index).resource_id
            	);
            	hr_utility.TRACE (   'NEW:'
            	                  || p_timecard (l_next_index).NEW);
            end if;
         END IF;


         if g_debug then
         	hr_utility.TRACE (
         	   '---------- Entering DAY Scope -------------------'
         	);
         end if;
         l_next_index :=   p_timecard.COUNT
                         + 1;
         if g_debug then
         	hr_utility.trace('l_next_index:'||l_next_index);
         end if;
         l_time_building_block_id := p_timecard.COUNT--  l_time_building_block_id
                                     + 1;
         if g_debug then
         	hr_utility.trace('l_time_building_block_id:'
                	         ||l_time_building_block_id);
         end if;
         l_parent_building_block_id := l_time_building_block_id;
         p_timecard (l_next_index).time_building_block_id :=
                                                      l_time_building_block_id;
         p_timecard (l_next_index).TYPE := 'RANGE';
         p_timecard (l_next_index).measure := NULL;
         p_timecard (l_next_index).unit_of_measure := 'HOURS';
         p_timecard (l_next_index).start_time := l_time_in_day;
         p_timecard (l_next_index).stop_time := l_time_out_day;
         p_timecard (l_next_index).parent_building_block_id := l_parent_id;
         p_timecard (l_next_index).parent_is_new := NULL;
         p_timecard (l_next_index).SCOPE := 'DAY';
         p_timecard (l_next_index).object_version_number := NULL;
         p_timecard (l_next_index).approval_status := NULL;
         p_timecard (l_next_index).resource_id := g_asg_rec.resource_id;
         p_timecard (l_next_index).resource_type := 'PERSON';
         p_timecard (l_next_index).approval_style_id := NULL;
         p_timecard (l_next_index).date_from := NULL;
         p_timecard (l_next_index).date_to := NULL;
         p_timecard (l_next_index).comment_text := NULL;
         p_timecard (l_next_index).parent_building_block_ovn := NULL;
         p_timecard (l_next_index).NEW := 'Y';
         p_timecard (l_next_index).changed := NULL;
         if g_debug then
         	hr_utility.TRACE (
         	      'TIME_BUILDING_BLOCK_ID:'
         	   || p_timecard (l_next_index).time_building_block_id
         	);
         	hr_utility.TRACE (   'MEASURE :'
         	                  || p_timecard (l_next_index).measure);
         	hr_utility.TRACE (
         	      'START_TIME :'
         	   || p_timecard (l_next_index).start_time
         	);
         	hr_utility.TRACE (
         	      'STOP_TIME :'
         	   || p_timecard (l_next_index).stop_time
         	);
         	hr_utility.TRACE (
         	      'PARENT_BUILDING_BLOCK_ID :'
         	   || p_timecard (l_next_index).parent_building_block_id
         	);
         	hr_utility.TRACE (   'SCOPE :'
         	                  || p_timecard (l_next_index).SCOPE);
         	hr_utility.TRACE (
         	      'RESOURCE_ID :'
         	   || p_timecard (l_next_index).resource_id
         	);
         	hr_utility.TRACE (   'NEW:'
         	                  || p_timecard (l_next_index).NEW);
         end if;
         IF (   (NVL (l_standard_start, 0) <> 0)
             OR (NVL (l_standard_stop, 0) <> 0)
             OR (NVL (l_hours, 0) <> 0)
            )
         THEN
            l_next_index :=   p_timecard.COUNT
                            + 1;
            l_time_building_block_id :=   l_time_building_block_id
                                        + 1;
            /* Fix for bug 2397763 */
            /*l_time_attribute_id      := l_time_attribute_id + 1;*/
            l_time_attribute_id :=   p_app_attributes.COUNT
                                   + 1;
            if g_debug then
            	hr_utility.TRACE (
            	   '---------- Entering DETAIL Scope -------------------'
            	);
            end if;
            p_timecard (l_next_index).time_building_block_id :=
                                                     l_time_building_block_id;
            p_timecard (l_next_index).TYPE := l_type;
            p_timecard (l_next_index).measure := p_hours;
            p_timecard (l_next_index).unit_of_measure := 'HOURS';
            p_timecard (l_next_index).start_time := l_time_in;
            p_timecard (l_next_index).stop_time := l_time_out;
            p_timecard (l_next_index).parent_building_block_id :=
                                                   l_parent_building_block_id;
            p_timecard (l_next_index).parent_is_new := NULL;
            p_timecard (l_next_index).SCOPE := 'DETAIL';
            p_timecard (l_next_index).object_version_number := NULL;
            p_timecard (l_next_index).approval_status := NULL;
            p_timecard (l_next_index).resource_id := g_asg_rec.resource_id;
            p_timecard (l_next_index).resource_type := 'PERSON';
            p_timecard (l_next_index).approval_style_id := NULL;
            p_timecard (l_next_index).date_from := NULL;
            p_timecard (l_next_index).date_to := NULL;
            p_timecard (l_next_index).comment_text := NULL;
            p_timecard (l_next_index).parent_building_block_ovn := NULL;
            p_timecard (l_next_index).NEW := 'Y';
            p_timecard (l_next_index).changed := NULL;
            p_app_attributes (l_next_index).time_attribute_id :=
                                                          l_time_attribute_id;
            p_app_attributes (l_next_index).building_block_id :=
                                                     l_time_building_block_id;
            p_app_attributes (l_next_index).attribute_name :=
                                                      'Dummy Element Context';
            p_app_attributes (l_next_index).attribute_value :=
                                          'ELEMENT'
                                       || ' '
                                       || '-'
                                       || ' '
                                       || p_elt_id;
            p_app_attributes (l_next_index).bld_blk_info_type :=
                                                      'Dummy Element Context';
            p_app_attributes (l_next_index).CATEGORY := 'ELEMENT';
            p_app_attributes (l_next_index).updated := NULL;
            p_app_attributes (l_next_index).changed := NULL;
            if g_debug then
            	hr_utility.TRACE (
            	   '---------- DETAIL Scope timecard info-------------------'
            	);
            	hr_utility.TRACE (
            	      'TIME_BUILDING_BLOCK_ID:'
            	   || p_timecard (l_next_index).time_building_block_id
            	);
            	hr_utility.TRACE (   'TYPE:'
            	                  || p_timecard (l_next_index).TYPE);
            	hr_utility.TRACE (
            	      'MEASURE :'
            	   || p_timecard (l_next_index).measure
            	);
            	hr_utility.TRACE (
            	      'START_TIME :'
            	   || p_timecard (l_next_index).start_time
            	);
            	hr_utility.TRACE (
            	      'STOP_TIME :'
            	   || p_timecard (l_next_index).stop_time
            	);
            	hr_utility.TRACE (
            	      'PARENT_BUILDING_BLOCK_ID :'
            	   || p_timecard (l_next_index).parent_building_block_id
            	);
            	hr_utility.TRACE (   'SCOPE :'
            	                  || p_timecard (l_next_index).SCOPE);
            	hr_utility.TRACE (
            	      'RESOURCE_ID :'
            	   || p_timecard (l_next_index).resource_id
            	);
            	hr_utility.TRACE (   'NEW:'
            	                  || p_timecard (l_next_index).NEW);
            	hr_utility.TRACE (
            	   '---------- DETAIL Scope attributes info-------------------'
            	);
            	hr_utility.TRACE (
            	      'TIME_ATTRIBUTE_ID:'
            	   || p_app_attributes (l_next_index).time_attribute_id
            	);
            	hr_utility.TRACE (
            	      'BUILDING_BLOCK_ID :'
            	   || p_app_attributes (l_next_index).building_block_id
            	);
            	hr_utility.TRACE (
            	      'ATTRIBUTE_NAME :'
            	   || p_app_attributes (l_next_index).attribute_name
            	);
            	hr_utility.TRACE (
            	      'ATTRIBUTE_VALUE :'
            	   || p_app_attributes (l_next_index).attribute_value
            	);
            	hr_utility.TRACE (
            	      'BLD_BLK_INFO_TYPE:'
            	   || p_app_attributes (l_next_index).bld_blk_info_type
            	);
            	hr_utility.TRACE (
            	      'CATEGORY :'
            	   || p_app_attributes (l_next_index).CATEGORY
            	);
            end if;
         END IF;
      END LOOP;


   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXC', 'HXC_366285_GEN_WRK_PLAN_ERR');
   END gen_work_plan;

--------------------------------------------------------------------------------
   PROCEDURE gen_rot_plan (
      p_start                         DATE,
      p_end                           DATE,
      p_rtp_id                        NUMBER,
      p_app_attributes   OUT NOCOPY   hxc_self_service_time_deposit.app_attributes_info,
      p_timecard         OUT NOCOPY   hxc_self_service_time_deposit.timecard_info
   )
   IS

--  Purpose
--    Generate hours worked records FOR employees who have a work plan
--    and rotation plan.
      CURSOR cur_hrs (p_start DATE, p_end DATE, p_rtp_id NUMBER)
      IS
         SELECT   rt1.tws_id tws_id,
                  -- Use the latest of rotation plan start dates or assignment start date
                  TRUNC (
                     DECODE (
                        SIGN (  rt1.start_date
                              - p_start),
                        -1, p_start,
                        rt1.start_date
                     )
                  ) start_date,
                  -- simplification of the above code as follows:
                  -- reverting back this change since teh cursor returns wrong
                  -- start_date when rt1.start_date is NULL
               /* greatest(rt1.start_date,p_start) start_date,*/
                  -- Use the earliest of rotation plan end dates or assignment end date
                  NVL (
                     TRUNC (
                        DECODE (
                           SIGN (  MIN (  rt2.start_date
                                        - 1)
                                 - p_end),
                           -1, MIN (  rt2.start_date
                                    - 1),
                           p_end
                        )
                     ),
                     hr_general.end_of_time
                  ) end_date
                  -- simplification of the above code as follows:
                  -- reverting back this change since the cursor returns wrong
                  -- end_date when rt2.start_date is NULL
                  /* NVL(least(min(rt2.start_date-1),p_end)
                       ,hr_general.end_of_time ) end_date*/
             FROM hxt_rotation_schedules rt1, hxt_rotation_schedules rt2
            WHERE rt1.rtp_id = rt2.rtp_id(+)
              AND rt2.start_date(+) > rt1.start_date
              AND rt1.rtp_id = p_rtp_id
              AND p_end >= rt1.start_date
         GROUP BY rt1.tws_id, rt1.start_date
           HAVING p_start <=
                      NVL (  MIN (rt2.start_date)
                           - 1, hr_general.end_of_time)
         ORDER BY rt1.start_date;

      l_next_index   BINARY_INTEGER;
      l_proc varchar2(100);

   BEGIN
      g_debug := hr_utility.debug_enabled;

      if g_debug then
      	l_proc := 'HXT_TIMECARD_INFO.gen_rot_plan';
      	hr_utility.set_location(l_proc,10);

      	hr_utility.trace('p_start    :'||p_start);
      	hr_utility.trace('p_end      :'||p_end);
      	hr_utility.trace('p_rtp_id   :'||p_rtp_id);
      end if;

      FOR hrs_rec IN cur_hrs (p_start, p_end, p_rtp_id)
      LOOP
         if g_debug then
         	hr_utility.set_location(l_proc,20);
         end if;

         gen_work_plan (
            hrs_rec.start_date,
            hrs_rec.end_date,
            hrs_rec.tws_id,
            p_app_attributes,
            p_timecard
         );

         if g_debug then
         	hr_utility.set_location(l_proc,30);
         end if;

      END LOOP;
      if g_debug then
      	hr_utility.set_location(l_proc,40);
      end if;

   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXC', 'HXC_366286_GEN_ROT_PLAN_ERR');
         fnd_message.raise_error;
   END;


--------------------------------------------------------------------------------
   PROCEDURE get_holiday_info (
      p_date     IN              DATE,
      p_hcl_id   IN              NUMBER,
      p_elt_id   OUT NOCOPY      NUMBER,
      p_hours    OUT NOCOPY      NUMBER
   )
   IS

-- Procedure
--    Get_Holiday_Info
-- Purpose
--    Return holiday earning and default hours for input holiday
--    calendar if input day is holiday.
-- Arguments
--    p_date      The date being checked.
--    p_hcl_id    The Holiday Calendar to be checked.
-- Returns:
--    p_elt_id  - holiday earning ID(element_type_id) or null
--    p_hours   - paid hours for holiday

      CURSOR cur_hcl (p_date DATE, p_hcl_id NUMBER)
      IS
         SELECT DECODE (hhd.hours, NULL, NULL, hcl.element_type_id), hhd.hours
           FROM hxt_holiday_calendars hcl, hxt_holiday_days hhd
          WHERE hhd.holiday_date = p_date
            AND hcl.id = hhd.hcl_id
            AND p_date BETWEEN hcl.effective_start_date
                           AND hcl.effective_end_date
            AND hcl.id = p_hcl_id;
   BEGIN
      OPEN cur_hcl (p_date, p_hcl_id);
      FETCH cur_hcl INTO p_elt_id, p_hours;
      CLOSE cur_hcl;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXC', 'HXC_366287_GET_HOL_ERR');
   END get_holiday_info;


------------------------------------------------------------------
   FUNCTION convert_time (
      p_date       DATE,
      p_time_in    NUMBER,
      p_time_out   NUMBER DEFAULT NULL
   )
      RETURN DATE
   IS
      l_date      DATE   := p_date;
      l_convert   NUMBER := NVL (p_time_out, p_time_in);
   BEGIN
      IF      (p_time_out IS NOT NULL)
          AND (   p_time_out < p_time_in
               OR (p_time_out = p_time_in AND p_time_in <> 0)
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
         fnd_message.set_name ('HXC', 'HXC_366288_CONVERT_TIME_ERR');
   END convert_time;


------------------------------------------------------------------------
   FUNCTION convert_timecard_time (
      p_date       DATE,
      p_time_in    NUMBER,
      p_time_out   NUMBER DEFAULT NULL
   )
      RETURN DATE
   IS
      l_date      DATE   := p_date;
      l_convert   NUMBER := NVL (p_time_out, p_time_in);
   BEGIN
      IF      (p_time_out IS NOT NULL)
          AND (   p_time_out < p_time_in
               OR (p_time_out = p_time_in AND p_time_in <> 0)
              )
      THEN
         l_date :=   l_date
                   + 1; -- use next day if past midnight
      END IF;

      RETURN (TO_DATE (
                    TO_CHAR (l_date, 'MMDDYYYY')
                 || TO_CHAR (l_convert, '000009'),
                 'MMDDYYYYHH24MISS'
              )
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('HXC', 'HXC_366288_CONVERT_TIME_ERR');
   END convert_timecard_time;
------------------------------------------------------------------------

--begin


END hxt_timecard_info;

/
