--------------------------------------------------------
--  DDL for Package Body HXC_ABS_RETRIEVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ABS_RETRIEVAL_PKG" AS
/* $Header: hxcabsret.pkb 120.0.12010000.22 2010/05/10 10:26:06 asrajago noship $ */

   g_package varchar2(30) 	:= 'hxc_abs_retrieval_pkg.';
   g_debug boolean 		:= hr_utility.debug_enabled;

   g_resource_id                 NUMBER			:= NULL;
   g_tc_start                    DATE			:= NULL;
   g_tc_stop                     DATE			:= NULL;
   g_tc_status                   VARCHAR2 (10)		:= NULL;

   g_abs_integ_enabled           VARCHAR2 (1)           := 'N';
   g_abs_prepop_edit             VARCHAR2 (1)           := 'N';
   g_all_id_tab			 hxc_abs_retrieval_pkg.NUMTAB;
   g_all_ovn_tab		 hxc_abs_retrieval_pkg.NUMTAB;
   g_success_create_msg          VARCHAR2 (100):= 'This absence detail was successfully created in Absences module';
   g_success_delete_msg          VARCHAR2 (100):= 'This absence detail was successfully deleted in Absences module';
   g_fail_create_msg             VARCHAR2 (50) := ' (Online Retrieval Failed)';
   g_business_group_id           NUMBER			:= NULL;
   g_error_message		 VARCHAR2(50)           := NULL;
   g_transaction_id              hxc_transactions.transaction_id%TYPE  := NULL;

   PROCEDURE post_absences (p_resource_id IN NUMBER,
   			    p_tc_start    IN DATE,
   			    p_tc_stop     IN DATE,
   			    p_tc_status   IN VARCHAR2,
   			    p_messages    IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE )
   AS

      CURSOR c_abs_from_temp (c_resource_id NUMBER,
      			      c_tc_start    DATE,
      			      c_tc_stop     DATE )
      IS
         SELECT time_building_block_id,
		object_version_number,
		resource_id,
		in_time,
		out_time,
		absence_attendance_type_id,
		uom,
		cost_allocation_keyflex_id,
		absence_attendance_id,
		day_start,
		day_stop,
		retrieval_status,
		absences_action,
		element_type_id,
		link_time_building_block_id
           FROM hxc_abs_ret_temp
          WHERE resource_id = c_resource_id
            AND TRUNC (day_start) >= TRUNC (c_tc_start)
            AND TRUNC (day_stop) <= TRUNC (c_tc_stop)
       ORDER BY absences_action ASC,
                uom ASC,
                absence_attendance_type_id ASC,
                cost_allocation_keyflex_id ASC,
                day_start ASC;

      -- get cost center information from ATTRIBUTE table
      CURSOR get_cost_attributes
      IS
      SELECT /*+      INDEX(htau HXC_TIME_ATTRIBUTE_USAGES_FK2)
         	      INDEX(hta HXC_TIME_ATTRIBUTES_PK) */
                temp.time_building_block_id  time_building_block_id,
                temp.object_version_number   object_version_number,
                hta.attribute1 attribute1, hta.attribute2 attribute2,
                hta.attribute3 attribute3, hta.attribute4 attribute4,
                hta.attribute5 attribute5, hta.attribute6 attribute6,
                hta.attribute7 attribute7, hta.attribute8 attribute8,
                hta.attribute9 attribute9, hta.attribute10 attribute10,
                hta.attribute11 attribute11, hta.attribute12 attribute12,
                hta.attribute13 attribute13, hta.attribute14 attribute14,
                hta.attribute15 attribute15, hta.attribute16 attribute16,
                hta.attribute17 attribute17, hta.attribute18 attribute18,
                hta.attribute19 attribute19, hta.attribute20 attribute20,
                hta.attribute21 attribute21, hta.attribute22 attribute22,
                hta.attribute23 attribute23, hta.attribute24 attribute24,
                hta.attribute25 attribute25, hta.attribute26 attribute26,
                hta.attribute27 attribute27, hta.attribute28 attribute28,
                hta.attribute29 attribute29, hta.attribute30 attribute30,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                0 cost_allocation_keyflex_id
        FROM    hxc_time_attributes hta,
                hxc_time_attribute_usages htau,
                hxc_abs_ret_temp temp
       WHERE    temp.time_building_block_id = htau.time_building_block_id
         AND    temp.object_version_number = htau.time_building_block_ovn
         AND    htau.time_attribute_id = hta.time_attribute_id
         AND    hta.attribute_category = 'Dummy Cost Context';

      -- ABSENCES DELETE/UPDATE IMMEDIATELY AFTER PREPOPULATION

      -- get prepopulated absence_attendance_ids which has to be deleted because of updation/deletion in TC
      -- immediately after prepopulation
      -- returns the days information as well
      CURSOR c_delete_prepop_abs
      IS
         SELECT absco.absence_attendance_id,
                absco.uom,
                trunc(absco.start_date) start_date,
                trunc(absco.end_date)   end_date,
                absco.time_building_block_id,
                absco.object_version_number
           FROM hxc_abs_co_details absco
          WHERE absco.resource_id = g_resource_id
            AND TRUNC (absco.start_time) >= TRUNC (g_tc_start)
            AND TRUNC (absco.stop_time) <= TRUNC (g_tc_stop)
            AND absco.stage <> 'RET'
            AND
            NOT EXISTS (SELECT /*+ LEADING(htd HXC_TRANSACTION_DETAILS_FK1)
                 	  	      INDEX(ht HXC_TRANSACTIONS_PK)
                 	  	      INDEX(ht HXC_TRANSACTIONS_N3) */
                 	         1
                  	  FROM hxc_transaction_details htd, hxc_transactions ht
                  	 WHERE absco.time_building_block_id = htd.time_building_block_id
                    	   AND htd.transaction_id = ht.transaction_id
                   	   AND ht.transaction_process_id = g_retrieval_process_id
                   	   AND ht.TYPE = 'RETRIEVAL'
                   	   AND ht.status = 'SUCCESS'
                   	   AND htd.status = 'SUCCESS')
          ORDER BY uom ASC, absence_attendance_id ASC, start_date ASC;


      -- RETRIEVED ABSENCES DELETE/UPDATE

      -- get retrieved absence_attendance_ids which has to be deleted because of updation/deletion in TC
      CURSOR c_delete_ret_abs
      IS
         SELECT absence_attendance_id,
                uom,
                trunc(day_start)  start_date,
                trunc(day_stop)   end_date,
                time_building_block_id,
                object_version_number
           FROM hxc_abs_ret_temp
          WHERE absence_attendance_id IS NOT NULL
            AND absences_action = 'DELETE'
          ORDER BY uom ASC, absence_attendance_id ASC, start_date ASC;


      -- this info is used to create TXNS
      CURSOR c_success_from_temp (c_resource_id NUMBER,
      				  c_tc_start DATE,
      				  c_tc_stop DATE)
      IS
         SELECT temp.time_building_block_id,
		temp.object_version_number,
		latest.object_version_number,
		temp.absences_action,
		detail.date_to
           FROM hxc_abs_ret_temp temp,
                hxc_latest_details latest,
                hxc_time_building_blocks detail
          WHERE temp.resource_id = c_resource_id
            AND TRUNC (temp.day_start) >= TRUNC (c_tc_start)
            AND TRUNC (temp.day_stop) <= TRUNC (c_tc_stop)
            AND temp.retrieval_status = 'SUCCESS'
            AND temp.time_building_block_id = latest.time_building_block_id
            AND latest.time_building_block_id = detail.time_building_block_id
            AND latest.object_version_number = detail.object_version_number
       ORDER BY absences_action ASC;


      TYPE t_delete_absences IS TABLE OF c_delete_prepop_abs%ROWTYPE
      INDEX BY BINARY_INTEGER;

      new_absences_tab          t_absences;
      edited_abs_tab            t_absences;
      all_abs_tab		t_absences;
      l_tbb_ix			NUMBER := 0;
      abs_ix			BINARY_INTEGER;
      l_cost_segment            t_cost_attributes;
      l_id_tab		        hxc_abs_retrieval_pkg.NUMTAB;
      l_ovn_tab			hxc_abs_retrieval_pkg.NUMTAB;

      l_prepop_delete_absences  t_delete_absences;
      l_ret_delete_absences     t_delete_absences;
      l_edited_days             t_edited_days;
      days_tab                  t_absences;
      hours_tab                 t_absences;
      l_abs_retrieval_rule      VARCHAR2 (50);
      l_retrieval_rule_grp_id   hxc_retrieval_rule_groups_v.retrieval_rule_group_id%TYPE;
      l_emp_name                per_all_people_f.full_name%TYPE;
      l_temp_row                hxc_abs_ret_temp%ROWTYPE;
      l_count                   NUMBER;
      l_days_ix                 NUMBER;
      l_d_ix			BINARY_INTEGER  := 0;
      l_h_ix			BINARY_INTEGER  := 0;
      l_abs_ix			BINARY_INTEGER  := 0;
      l_uom  		        VARCHAR2(1);

      l_temp_id_tab		NUMTAB;
      l_temp_ovn_tab		NUMTAB;
      l_latest_ovn_tab		NUMTAB;
      l_action_tab		VARCHARTAB;
      l_create_id_tab		NUMTAB;
      l_create_ovn_tab	 	NUMTAB;
      l_delete_id_tab		NUMTAB;
      l_delete_ovn_tab       	NUMTAB;
      l_latest_date_to_tab	DATETAB;

      l_txn_index		NUMBER  := 0;
      l_pref_table              hxc_preference_evaluation.t_pref_table;
      l_absence_attendance_id   hxc_abs_co_details.absence_attendance_id%TYPE;
      l_proc 			VARCHAR2(100);
      l_ed_days_ix 		BINARY_INTEGER  := 0;
      l_call_delete		BOOLEAN;
      ret_rules_not_set		EXCEPTION;

   BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
         l_proc := g_package||'post_absences';
         hr_utility.set_location('ABS:Processing '||l_proc, 10);
      END IF;

      g_abs_integ_enabled          := 'N';
      g_abs_prepop_edit            := 'N';
      g_business_group_id          := NULL;
      g_transaction_id		   := NULL;
      g_resource_id		   := p_resource_id;
      g_tc_start		   := p_tc_start;
      g_tc_stop			   := p_tc_stop;
      g_tc_status		   := p_tc_status;

      IF g_debug THEN
         hr_utility.TRACE ('ABS:g_resource_id = ' || g_resource_id);
         hr_utility.TRACE ('ABS:g_tc_start = '    || g_tc_start);
         hr_utility.TRACE ('ABS:g_tc_stop = '     || g_tc_stop);
         hr_utility.TRACE ('ABS:g_tc_status = '   || g_tc_status);
      END IF;

      SELECT full_name, business_group_id
        INTO l_emp_name, g_business_group_id
        FROM per_all_people_f
       WHERE person_id = g_resource_id
         AND g_tc_start between effective_start_date and effective_end_date;

      IF g_debug THEN
      	hr_utility.TRACE ('ABS:g_business_group_id = ' || g_business_group_id);
      	hr_utility.TRACE ('ABS:l_emp_name = ' || l_emp_name);
      END IF;

      IF g_retrieval_process_id IS NULL THEN
	      SELECT retrieval_process_id
	        INTO g_retrieval_process_id
	        FROM hxc_retrieval_processes
	       WHERE NAME = 'BEE Retrieval Process';
      END IF;

      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 20);
      END IF;

      -- Evaluate preferences to get the retrieval rule group preference value and
      -- other absence preferences
      hxc_preference_evaluation.resource_preferences(g_resource_id,
                                                    g_tc_start,
                                                    g_tc_start,
                                                    l_pref_table);


      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 30);
      END IF;

      IF l_pref_table.COUNT > 0
      THEN
          FOR i IN l_pref_table.FIRST..l_pref_table.LAST
          LOOP
              IF l_pref_table(i).preference_code = 'TS_ABS_PREFERENCES'
              THEN

	         g_abs_integ_enabled  := l_pref_table (i).attribute1;
	         g_abs_prepop_edit    := NVL (l_pref_table (i).attribute2, 'N');
	         l_abs_retrieval_rule := NVL(l_pref_table (i).attribute4, 'RRG');

	         EXIT;

	      END IF;
	  END LOOP;

       -- Bug 9394444
       -- Added the following code to delete Absences prepopulated
       -- earlier from the retrieval table.

       -- Bug 9688040
       -- Added hxc_transactions and details in the below query to
       -- avoid issues with prepop and edited(or from SS) absences.

       IF g_abs_integ_enabled = 'Y'
       THEN
           DELETE FROM hxc_pay_latest_details
                 WHERE (time_building_block_id,object_version_number)
                    IN ( SELECT co.time_building_block_id,
                                co.object_version_number
                           FROM hxc_abs_co_details co,
                                hxc_transaction_details htd,
                                hxc_transactions ht
                          WHERE co.resource_id = g_resource_id
                            AND co.start_time = g_tc_start
                            AND TRUNC(co.stop_time) = TRUNC(g_tc_stop)
                            AND htd.time_building_block_id = co.time_building_block_id
                            AND htd.time_building_block_ovn = co.object_version_number
                            AND htd.transaction_id = ht.transaction_id
                            AND ht.transaction_process_id = g_retrieval_process_id
                            AND action IS NULL );
       END IF;



             -- if absences retrieval rule is set to follow the retrieval rule group preference then
          IF (l_abs_retrieval_rule = 'RRG' and g_abs_integ_enabled = 'Y') THEN

       	     FOR i IN l_pref_table.FIRST..l_pref_table.LAST
             LOOP

                IF (l_pref_table(i).preference_code = 'TS_PER_RETRIEVAL_RULES') THEN

	         	l_retrieval_rule_grp_id  := l_pref_table (i).attribute1;

                        l_abs_retrieval_rule := get_retrieval_rule ( l_retrieval_rule_grp_id );

         	 	IF l_abs_retrieval_rule = 'NODATA'
         	 	THEN
         	 	   RAISE ret_rules_not_set;
         	 	END IF;
	        END IF;

	      END LOOP;

	   END IF;
      END IF;

      IF g_debug THEN
             hr_utility.set_location('ABS:Processing '||l_proc, 40);
      END IF;

      IF g_debug THEN
      	hr_utility.TRACE ('ABS:g_abs_integ_enabled = ' || g_abs_integ_enabled);
      	hr_utility.TRACE ('ABS:g_abs_prepop_edit = ' || g_abs_prepop_edit);
      	hr_utility.TRACE ('ABS:l_abs_retrieval_rule = ' || l_abs_retrieval_rule);
      END IF;


      IF (    g_abs_integ_enabled = 'Y'
          AND g_tc_status <> 'ERROR'
         )
      THEN                                                              -- if1
         IF    (l_abs_retrieval_rule = g_tc_status)
            OR (l_abs_retrieval_rule = 'WORKING')
            OR (g_tc_status = 'APPROVED'
                AND l_abs_retrieval_rule = 'SUBMITTED'
               )
            OR (g_tc_status = 'DELETED')
         THEN                                                           -- if2

            IF g_debug THEN
               hr_utility.set_location('ABS:Processing '||l_proc, 50);
            END IF;

	    -- Populate TEMP table with absences data that has to be created
            -- Absences which are new and not yet retrieved

   	    INSERT INTO hxc_abs_ret_temp (
   		SELECT /*+ LEADING (latest HXC_LATEST_DETAILS_N1)
   		      	    INDEX(detail HXC_TIME_BUILDING_BLOCKS_PK)
   		      	    INDEX(htau HXC_TIME_ATTRIBUTE_USAGES_FK2)
   		      	    INDEX(hta HXC_TIME_ATTRIBUTES_PK) */
   	             detail.time_building_block_id,   	--time_building_block_id,
   	             detail.object_version_number ,   	--object_version_number,
   	             detail.resource_id           ,   	--resource_id,
   	             detail.start_time            ,   	--in_time,
   	             detail.stop_time             ,   	--out_time,
   	             hate.absence_attendance_type_id, 	--absence_attendance_type_id,
   	             SUBSTR (hate.uom, 1, 1)        , 	--uom,
   	             0                              , 	--cost_allocation_keyflex_id,
   	             NULL                           , 	--absence_attendance_id,
   	             latest.start_time              , 	--day_start,
   	             latest.stop_time               , 	--day_stop,
   	             NULL                           , 	--retrieval_status,
   	             'CREATE'                       , 	--absences_action,
   	             to_number(
   	             SUBSTR(hta.attribute_category, 11)
   	             ) 				    ,	--element_type_id,
   	             NULL                              	--link_time_building_block_id
   	     FROM    hxc_latest_details latest,
   	             hxc_time_building_blocks detail,
   	             hxc_time_attribute_usages htau,
   	             hxc_time_attributes hta,
   	             hxc_absence_type_elements hate
   	    WHERE    latest.resource_id = g_resource_id
   	      AND    TRUNC (latest.start_time) BETWEEN TRUNC (g_tc_start) AND TRUNC (g_tc_stop)
   	      AND    latest.time_building_block_id = detail.time_building_block_id
   	      AND    latest.object_version_number = detail.object_version_number
   	      AND    detail.time_building_block_id = htau.time_building_block_id
   	      AND    detail.object_version_number = htau.time_building_block_ovn
   	      AND    detail.date_to = hr_general.end_of_time
   	      AND    htau.time_attribute_id = hta.time_attribute_id
   	      AND    hta.attribute_category like 'ELEMENT - %'
   	      AND    to_number(SUBSTR(hta.attribute_category, 11)) = hate.element_type_id
   	      AND NOT EXISTS (
   	              SELECT /*+ LEADING(htd HXC_TRANSACTION_DETAILS_FK1)
   	                	      INDEX(ht HXC_TRANSACTIONS_PK)
   	                	      INDEX(ht HXC_TRANSACTIONS_N3) */
   	                       1
   	               FROM hxc_transaction_details htd, hxc_transactions ht
   	              WHERE latest.time_building_block_id = htd.time_building_block_id
   	                AND latest.object_version_number = htd.time_building_block_ovn
   	                AND htd.transaction_id = ht.transaction_id
   	                AND ht.transaction_process_id = g_retrieval_process_id
   	                AND ht.TYPE = 'RETRIEVAL'
   	                AND ht.status = 'SUCCESS'
   	                AND htd.status = 'SUCCESS') );


            IF g_debug THEN
               hr_utility.TRACE (   'ABS:new absences COUNT = ' || SQL%ROWCOUNT);
	    END IF;

            IF g_debug THEN
               hr_utility.set_location('ABS:Processing '||l_proc, 60);
            END IF;

            -- Populate TEMP table with updated/deleted absences data
      	    -- This cursor returns Absences which were retrieved earlier and have undergone a change during
      	    -- next retrieval
   	    INSERT INTO hxc_abs_ret_temp (
	      SELECT  detail.time_building_block_id ,    --time_building_block_id,
          	      detail.object_version_number  ,    --object_version_number,
          	      detail.resource_id            ,    --resource_id,
          	      detail.start_time             ,    --in_time,
          	      detail.stop_time              ,    --out_time,
          	      absatt.absence_attendance_type_id, --absence_attendance_type_id,
          	      absco.uom			  ,      --uom,
          	      0                           ,      --cost_allocation_keyflex_id,
          	      absco.absence_attendance_id ,      --absence_attendance_id,
          	      TRUNC (DAY.start_time)      ,      --day_start,
          	      TRUNC (DAY.stop_time)       ,      --day_stop,
          	      NULL                        ,      --retrieval_status,
          	      'DELETE'                    ,      --absences_action,
          	      absco.element_type_id       ,      --element_type_id,
          	      NULL                              --link_time_building_block_id
        	FROM  hxc_abs_co_details absco,
        	      hxc_time_building_blocks detail,
        	      hxc_time_building_blocks DAY,
        	      per_absence_attendances absatt
	       WHERE  absco.resource_id = g_resource_id
	         AND  TRUNC (absco.start_time) = TRUNC (g_tc_start)
	         AND  TRUNC (absco.stop_time) = TRUNC (g_tc_stop)
	         AND  absco.absence_attendance_id IS NOT NULL
	         AND  detail.time_building_block_id = absco.time_building_block_id
	         AND  detail.object_version_number =
	                   (SELECT /*+ LEADING(htd HXC_TRANSACTION_DETAILS_FK1)
	                   	      INDEX(ht HXC_TRANSACTIONS_PK)
	                   	      INDEX(ht HXC_TRANSACTIONS_N3) */
	                   	   MAX (htd.time_building_block_ovn)
	                      FROM hxc_transactions ht, hxc_transaction_details htd
	                     WHERE ht.transaction_process_id = g_retrieval_process_id
	                       AND htd.time_building_block_id = absco.time_building_block_id
	                       AND htd.transaction_id = ht.transaction_id
	                       AND htd.status = 'SUCCESS'
	                       AND ht.TYPE = 'RETRIEVAL'
	                       AND ht.status = 'SUCCESS')
	         AND  DAY.time_building_block_id = detail.parent_building_block_id
	         AND  DAY.object_version_number = detail.parent_building_block_ovn
	         AND  detail.date_to <> hr_general.end_of_time
	         AND  absco.absence_attendance_id = absatt.absence_attendance_id ) ;


	    IF g_debug THEN
               hr_utility.TRACE ('ABS:edited abs COUNT = ' || SQL%ROWCOUNT );
	    END IF;

            IF g_debug THEN
               hr_utility.set_location('ABS:Processing '||l_proc, 70);
            END IF;


            -- Bug 9394444
            -- Added the DELETE to avoid Abs details getting into
            -- retrieval tables.

            DELETE FROM hxc_pay_latest_details
                  WHERE (time_building_block_id,object_version_number)
                     IN ( SELECT time_building_block_id,
                                 object_version_number
                            FROM hxc_abs_ret_temp );




	    OPEN c_abs_from_temp(g_resource_id,
	                         g_tc_start,
	                         g_tc_stop);
	    FETCH c_abs_from_temp BULK COLLECT INTO all_abs_tab;
	    CLOSE c_abs_from_temp;

	    IF all_abs_tab.COUNT > 0 THEN
	        abs_ix := all_abs_tab.FIRST;

	    	LOOP
	    	 l_tbb_ix := all_abs_tab(abs_ix).time_building_block_id;

	    	 IF (all_abs_tab(abs_ix).absences_action = 'CREATE') THEN
	    	   new_absences_tab(l_tbb_ix).time_building_block_id 	:= all_abs_tab(abs_ix).time_building_block_id;
	    	   new_absences_tab(l_tbb_ix).object_version_number 	:= all_abs_tab(abs_ix).object_version_number;
	    	   new_absences_tab(l_tbb_ix).resource_id 		:= all_abs_tab(abs_ix).resource_id;
	    	   new_absences_tab(l_tbb_ix).in_time 			:= all_abs_tab(abs_ix).in_time;
	    	   new_absences_tab(l_tbb_ix).out_time 			:= all_abs_tab(abs_ix).out_time;
	    	   new_absences_tab(l_tbb_ix).absence_attendance_type_id := all_abs_tab(abs_ix).absence_attendance_type_id;
	    	   new_absences_tab(l_tbb_ix).uom 			:= all_abs_tab(abs_ix).uom;
	    	   new_absences_tab(l_tbb_ix).cost_allocation_keyflex_id := all_abs_tab(abs_ix).cost_allocation_keyflex_id;
	    	   new_absences_tab(l_tbb_ix).absence_attendance_id 	 := all_abs_tab(abs_ix).absence_attendance_id;
	    	   new_absences_tab(l_tbb_ix).day_start 	:= all_abs_tab(abs_ix).day_start;
	    	   new_absences_tab(l_tbb_ix).day_stop 		:= all_abs_tab(abs_ix).day_stop;
	    	   new_absences_tab(l_tbb_ix).retrieval_status  := all_abs_tab(abs_ix).retrieval_status;
	    	   new_absences_tab(l_tbb_ix).absences_action   := all_abs_tab(abs_ix).absences_action;
	    	   new_absences_tab(l_tbb_ix).element_type_id   := all_abs_tab(abs_ix).element_type_id;
	    	   new_absences_tab(l_tbb_ix).link_time_building_block_id := all_abs_tab(abs_ix).link_time_building_block_id;
	    	 ELSE
	    	   edited_abs_tab(l_tbb_ix).time_building_block_id 	:= all_abs_tab(abs_ix).time_building_block_id;
	    	   edited_abs_tab(l_tbb_ix).object_version_number 	:= all_abs_tab(abs_ix).object_version_number;
	    	   edited_abs_tab(l_tbb_ix).resource_id 		:= all_abs_tab(abs_ix).resource_id;
	    	   edited_abs_tab(l_tbb_ix).in_time 			:= all_abs_tab(abs_ix).in_time;
	    	   edited_abs_tab(l_tbb_ix).out_time 			:= all_abs_tab(abs_ix).out_time;
	    	   edited_abs_tab(l_tbb_ix).absence_attendance_type_id := all_abs_tab(abs_ix).absence_attendance_type_id;
	    	   edited_abs_tab(l_tbb_ix).uom 			:= all_abs_tab(abs_ix).uom;
	    	   edited_abs_tab(l_tbb_ix).cost_allocation_keyflex_id := all_abs_tab(abs_ix).cost_allocation_keyflex_id;
	    	   edited_abs_tab(l_tbb_ix).absence_attendance_id 	 := all_abs_tab(abs_ix).absence_attendance_id;
	    	   edited_abs_tab(l_tbb_ix).day_start 	:= all_abs_tab(abs_ix).day_start;
	    	   edited_abs_tab(l_tbb_ix).day_stop 		:= all_abs_tab(abs_ix).day_stop;
	    	   edited_abs_tab(l_tbb_ix).retrieval_status  := all_abs_tab(abs_ix).retrieval_status;
	    	   edited_abs_tab(l_tbb_ix).absences_action   := all_abs_tab(abs_ix).absences_action;
	    	   edited_abs_tab(l_tbb_ix).element_type_id   := all_abs_tab(abs_ix).element_type_id;
	    	   edited_abs_tab(l_tbb_ix).link_time_building_block_id := all_abs_tab(abs_ix).link_time_building_block_id;
	    	 END IF;

	    	abs_ix := all_abs_tab.NEXT (abs_ix);
		EXIT WHEN NOT all_abs_tab.EXISTS (abs_ix);
	      END LOOP;

	    END IF; --  all_abs_tab.COUNT > 0

	    IF g_debug THEN
               hr_utility.TRACE ('ABS:new_absences_tab.COUNT = ' || new_absences_tab.COUNT );
               hr_utility.TRACE ('ABS:edited_abs_tab.COUNT = ' || edited_abs_tab.COUNT );
	    END IF;

            -- update the TEMP table with the Dummy Cost Context segment value
            IF (new_absences_tab.COUNT > 0 OR edited_abs_tab.COUNT > 0)
            THEN

               IF g_debug THEN
                  hr_utility.TRACE ('ABS:Update TEMP table with cost information');
	       END IF;

               OPEN get_cost_attributes;

               FETCH get_cost_attributes
               BULK COLLECT INTO l_cost_segment;

               CLOSE get_cost_attributes;

               IF g_debug THEN
                  hr_utility.TRACE (   'ABS:l_cost_segment.COUNT = ' || l_cost_segment.COUNT );
	       END IF;

               IF (l_cost_segment.COUNT > 0)
               THEN
                  populate_cost_keyflex (l_cost_segment);
                  FOR l_ix IN l_cost_segment.FIRST .. l_cost_segment.LAST
                  LOOP
                     UPDATE hxc_abs_ret_temp
                        SET cost_allocation_keyflex_id = l_cost_segment (l_ix).cost_allocation_keyflex_id
                      WHERE time_building_block_id = l_cost_segment (l_ix).time_building_block_id
                        AND object_version_number = l_cost_segment (l_ix).object_version_number;
                  END LOOP;
               END IF;

               l_cost_segment.DELETE;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 80);
               END IF;


      -- The following processing is for records which only has a OVN change and no "Hours Type" or "detail" change
      -- When multiple OVN changes happen before retrieval with no attribute or detail change,
      -- these changes should not be considered for retrieval, instead the TXNS and CO tables have to updated with the
      -- latest ovn, by doing this we avoid a unnecessary delete and recreate of exactly same absences in HR
      -- This processing is only for unplanned absence records,
      -- for prepopulated ones, this ovn update happens during validation phase itself.

	     IF g_debug THEN
	        hr_utility.TRACE ('ABS:Process records with only ovn updates');
	     END IF;

	     IF (new_absences_tab.COUNT > 0) THEN
	       abs_ix := new_absences_tab.FIRST;
	       LOOP

	        l_tbb_ix := new_absences_tab(abs_ix).time_building_block_id;

	        IF edited_abs_tab.EXISTS(l_tbb_ix) THEN

	         IF new_absences_tab(l_tbb_ix).uom = 'H' and edited_abs_tab(l_tbb_ix).uom = 'H' THEN

	          IF new_absences_tab(l_tbb_ix).time_building_block_id = edited_abs_tab(l_tbb_ix).time_building_block_id
	             AND
	             new_absences_tab(l_tbb_ix).in_time = edited_abs_tab(l_tbb_ix).in_time
	             AND
	             new_absences_tab(l_tbb_ix).out_time = edited_abs_tab(l_tbb_ix).out_time
	             AND
	             new_absences_tab(l_tbb_ix).absence_attendance_type_id = edited_abs_tab(l_tbb_ix).absence_attendance_type_id
	             AND
	             new_absences_tab(l_tbb_ix).cost_allocation_keyflex_id = edited_abs_tab(l_tbb_ix).cost_allocation_keyflex_id
	  	  THEN

	  	     l_txn_index := l_txn_index + 1;
	  	     l_id_tab(l_txn_index) := new_absences_tab(l_tbb_ix).time_building_block_id;
	  	     l_ovn_tab(l_txn_index) := new_absences_tab(l_tbb_ix).object_version_number;

	  	  END IF;
	  	 END IF;

	         IF new_absences_tab(l_tbb_ix).uom = 'D' and edited_abs_tab(l_tbb_ix).uom = 'D' THEN

	          IF new_absences_tab(l_tbb_ix).time_building_block_id = edited_abs_tab(l_tbb_ix).time_building_block_id
	             AND
	             new_absences_tab(l_tbb_ix).absence_attendance_type_id = edited_abs_tab(l_tbb_ix).absence_attendance_type_id
	             AND
	             new_absences_tab(l_tbb_ix).cost_allocation_keyflex_id = edited_abs_tab(l_tbb_ix).cost_allocation_keyflex_id
	  	  THEN

	  	     l_txn_index := l_txn_index + 1;
	  	     l_id_tab(l_txn_index) := new_absences_tab(l_tbb_ix).time_building_block_id;
	  	     l_ovn_tab(l_txn_index) := new_absences_tab(l_tbb_ix).object_version_number;

	  	  END IF;
	  	 END IF;

	        END IF;

	        abs_ix := new_absences_tab.NEXT (abs_ix);
	        EXIT WHEN NOT new_absences_tab.EXISTS (abs_ix);
	       END LOOP;
	     END IF;  -- new_absences_tab.COUNT > 0

	       IF g_debug THEN
                  hr_utility.TRACE ('ABS:Delete records from temp having only OVN change'||l_id_tab.COUNT);
               END IF;

               IF (l_id_tab.COUNT > 0)
               THEN

                  FORALL l_ix IN l_id_tab.FIRST .. l_id_tab.LAST
                     DELETE FROM hxc_abs_ret_temp
                           WHERE time_building_block_id =  l_id_tab(l_ix);

                  FORALL l_ix IN l_ovn_tab.FIRST .. l_ovn_tab.LAST
                     UPDATE hxc_abs_co_details
                        SET object_version_number =  l_ovn_tab (l_ix)
                      WHERE time_building_block_id = l_id_tab(l_ix)
                        AND stage = 'RET';

                  create_transactions (l_id_tab,
                  		       l_ovn_tab,
                                       'SUCCESS',
                                       g_success_create_msg
                                      );
               END IF;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 90);
               END IF;

               l_id_tab.DELETE;
               l_ovn_tab.DELETE;

            END IF;         --   new_absences_tab.COUNT + edited_abs_tab.COUNT

            new_absences_tab.DELETE;
            edited_abs_tab.DELETE;

	    all_abs_tab.DELETE;
            g_all_id_tab.DELETE;
            g_all_ovn_tab.DELETE;

	    OPEN c_abs_from_temp(g_resource_id,
	                         g_tc_start,
	                         g_tc_stop);
	    FETCH c_abs_from_temp BULK COLLECT INTO all_abs_tab;
	    CLOSE c_abs_from_temp;

	    IF g_debug THEN
               hr_utility.TRACE (   'ABS:Records to be processed in TEMP table = '|| all_abs_tab.COUNT );
            END IF;

	   IF (all_abs_tab.COUNT > 0) THEN
            FOR abs_ix IN all_abs_tab.FIRST .. all_abs_tab.LAST
            LOOP
             -- g_all_id_tab stored all rows in TEMP table, this is used for audit purposes in case of exception
             g_all_id_tab(abs_ix) := all_abs_tab(abs_ix).time_building_block_id;
             g_all_ovn_tab(abs_ix) := all_abs_tab(abs_ix).object_version_number;

             -- build pl/sql tables

             -- build pl/sql tables for days and hours CREATE records
             IF (all_abs_tab(abs_ix).absences_action = 'CREATE'
                 AND
                 all_abs_tab(abs_ix).absence_attendance_id IS NULL) THEN

             	-- build days_tab for 'D' Create records
             	IF (all_abs_tab(abs_ix).uom = 'D') THEN
             	   l_d_ix := l_d_ix + 1;
	    	   days_tab(l_d_ix).time_building_block_id 	:= all_abs_tab(abs_ix).time_building_block_id;
	    	   days_tab(l_d_ix).object_version_number 	:= all_abs_tab(abs_ix).object_version_number;
	    	   days_tab(l_d_ix).resource_id 		:= all_abs_tab(abs_ix).resource_id;
	    	   days_tab(l_d_ix).in_time 		:= all_abs_tab(abs_ix).in_time;
	    	   days_tab(l_d_ix).out_time 		:= all_abs_tab(abs_ix).out_time;
	    	   days_tab(l_d_ix).absence_attendance_type_id := all_abs_tab(abs_ix).absence_attendance_type_id;
	    	   days_tab(l_d_ix).uom 			   := all_abs_tab(abs_ix).uom;
	    	   days_tab(l_d_ix).cost_allocation_keyflex_id := all_abs_tab(abs_ix).cost_allocation_keyflex_id;
	    	   days_tab(l_d_ix).absence_attendance_id 	   := all_abs_tab(abs_ix).absence_attendance_id;
	    	   days_tab(l_d_ix).day_start 	  := all_abs_tab(abs_ix).day_start;
	    	   days_tab(l_d_ix).day_stop 	  := all_abs_tab(abs_ix).day_stop;
	    	   days_tab(l_d_ix).retrieval_status  := all_abs_tab(abs_ix).retrieval_status;
	    	   days_tab(l_d_ix).absences_action   := all_abs_tab(abs_ix).absences_action;
	    	   days_tab(l_d_ix).element_type_id   := all_abs_tab(abs_ix).element_type_id;
	    	   days_tab(l_d_ix).link_time_building_block_id := all_abs_tab(abs_ix).link_time_building_block_id;
	        ELSE
             	-- build hours_tab for 'H' Create records
	    	   l_h_ix := l_h_ix + 1;
	    	   hours_tab(l_h_ix).time_building_block_id := all_abs_tab(abs_ix).time_building_block_id;
	    	   hours_tab(l_h_ix).object_version_number 	:= all_abs_tab(abs_ix).object_version_number;
	    	   hours_tab(l_h_ix).resource_id 		:= all_abs_tab(abs_ix).resource_id;
	    	   hours_tab(l_h_ix).in_time 		:= all_abs_tab(abs_ix).in_time;
	    	   hours_tab(l_h_ix).out_time 		:= all_abs_tab(abs_ix).out_time;
	    	   hours_tab(l_h_ix).absence_attendance_type_id := all_abs_tab(abs_ix).absence_attendance_type_id;
	    	   hours_tab(l_h_ix).uom 			    := all_abs_tab(abs_ix).uom;
	    	   hours_tab(l_h_ix).cost_allocation_keyflex_id := all_abs_tab(abs_ix).cost_allocation_keyflex_id;
	    	   hours_tab(l_h_ix).absence_attendance_id 	    := all_abs_tab(abs_ix).absence_attendance_id;
	    	   hours_tab(l_h_ix).day_start 	  := all_abs_tab(abs_ix).day_start;
	    	   hours_tab(l_h_ix).day_stop 	  := all_abs_tab(abs_ix).day_stop;
	    	   hours_tab(l_h_ix).retrieval_status := all_abs_tab(abs_ix).retrieval_status;
	    	   hours_tab(l_h_ix).absences_action  := all_abs_tab(abs_ix).absences_action;
	    	   hours_tab(l_h_ix).element_type_id  := all_abs_tab(abs_ix).element_type_id;
	    	   hours_tab(l_h_ix).link_time_building_block_id := all_abs_tab(abs_ix).link_time_building_block_id;
             	END IF;
	     END IF;

            END LOOP;
           END IF;  -- all_abs_tab.COUNT > 0

---------------PHASE 1------------------------------

            -- PREPOPULATED ABSENCES which are deleted/updated from OTL timecard immediately after prepopulation
            -- has to get updated in HR Absences as well.
            -- Process these first, because if there are Absences which spread across time periods for a
            -- single absence_attendance_id, then we need to delete the whole Absence record and recreate
            -- the needed ones which are not deleted via OTL timecard.

            l_call_delete := FALSE;

            OPEN c_delete_prepop_abs;

            FETCH c_delete_prepop_abs
            BULK COLLECT INTO l_prepop_delete_absences;

            CLOSE c_delete_prepop_abs;

	    IF g_debug THEN
               hr_utility.TRACE(   'ABS:** Prepopulation ** Count of prepop rows updated = ' || l_prepop_delete_absences.COUNT);
	    END IF;

            -- call for delete and recreation, if any
            IF (l_prepop_delete_absences.COUNT > 0)
            THEN
               l_abs_ix := l_prepop_delete_absences.FIRST;

               LOOP
                  l_ed_days_ix := l_ed_days_ix + 1;
      		  l_edited_days(l_ed_days_ix).day_start := l_prepop_delete_absences (l_abs_ix).start_date;
                  l_edited_days(l_ed_days_ix).day_stop := l_prepop_delete_absences (l_abs_ix).end_date;
      		  l_edited_days(l_ed_days_ix).time_building_block_id := l_prepop_delete_absences (l_abs_ix).time_building_block_id;
                  l_edited_days(l_ed_days_ix).object_version_number := l_prepop_delete_absences (l_abs_ix).object_version_number;

                  l_absence_attendance_id := l_prepop_delete_absences (l_abs_ix).absence_attendance_id;
                  l_uom  := l_prepop_delete_absences (l_abs_ix).uom;

	          l_abs_ix := l_abs_ix + 1;

	          IF (l_prepop_delete_absences.EXISTS (l_abs_ix)) THEN
	           IF (l_prepop_delete_absences (l_abs_ix).absence_attendance_id <> l_absence_attendance_id)  THEN
	             l_call_delete := TRUE;
	           ELSE
	             l_call_delete := FALSE;
	           END IF;
	          ELSE
	           l_call_delete := TRUE;
	          END IF;

	          IF l_call_delete THEN

	             IF g_debug THEN
                        hr_utility.TRACE(   'ABS:Process delete for Absence attendance id = '
                                 || l_absence_attendance_id );
                     END IF;

                     -- call delete absences for each absence_attendance_id
                     delete_absences
                         (l_absence_attendance_id,
                          l_edited_days,
                          l_uom
                         );

	             IF g_debug THEN
                        hr_utility.TRACE(   'ABS:Completed delete for Absence attendance id = '
                                 || l_absence_attendance_id );
                     END IF;

	             l_ed_days_ix := 0;
	             l_edited_days.DELETE;

	          END IF;
	       EXIT WHEN NOT l_prepop_delete_absences.EXISTS (l_abs_ix);
	       END LOOP;

            END IF;

            IF g_debug THEN
               hr_utility.set_location('ABS:Processing '||l_proc, 100);
            END IF;

            l_prepop_delete_absences.DELETE;
            l_edited_days.DELETE;

            -- Proceed furthur ONLY if there is data in the TEMP table
            IF (g_all_id_tab.COUNT <> 0)
            THEN
               --  ABSENCES which are deleted from OTL timecard and have been retrieved earlier
               --  has to get deleted in HR Absences as well.
               -- Process these next, because if there are Absences which spread across time periods for a
               -- single absence_attendance_id, then we need to delete the whole Absence record and recreate
               -- the needed ones which are not deleted via OTL timecard.

	       l_call_delete := FALSE;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 110);
               END IF;

               OPEN c_delete_ret_abs;

               FETCH c_delete_ret_abs
               BULK COLLECT INTO l_ret_delete_absences;

               CLOSE c_delete_ret_abs;

	       IF g_debug THEN
                  hr_utility.TRACE (   'ABS:** Retrieved ** Count of retrieved rows updated = ' || l_ret_delete_absences.COUNT );
	       END IF;

	      l_ed_days_ix := 0;

              -- call for delete and recreation, if any
              IF (l_ret_delete_absences.COUNT > 0)
              THEN
               l_abs_ix := l_ret_delete_absences.FIRST;

               LOOP
                  l_ed_days_ix := l_ed_days_ix + 1;
      		  l_edited_days(l_ed_days_ix).day_start := l_ret_delete_absences (l_abs_ix).start_date;
                  l_edited_days(l_ed_days_ix).day_stop := l_ret_delete_absences (l_abs_ix).end_date;
      		  l_edited_days(l_ed_days_ix).time_building_block_id := l_ret_delete_absences (l_abs_ix).time_building_block_id;
                  l_edited_days(l_ed_days_ix).object_version_number := l_ret_delete_absences (l_abs_ix).object_version_number;

                  l_absence_attendance_id := l_ret_delete_absences (l_abs_ix).absence_attendance_id;
                  l_uom  := l_ret_delete_absences (l_abs_ix).uom;

	          l_abs_ix := l_abs_ix + 1;

	          IF (l_ret_delete_absences.EXISTS (l_abs_ix)) THEN
	           IF (l_ret_delete_absences (l_abs_ix).absence_attendance_id <> l_absence_attendance_id)  THEN
	             l_call_delete := TRUE;
	           ELSE
	             l_call_delete := FALSE;
	           END IF;
	          ELSE
	           l_call_delete := TRUE;
	          END IF;

	          IF l_call_delete THEN

	             IF g_debug THEN
                        hr_utility.TRACE(   'ABS:Process delete for Absence attendance id = '
                                 || l_absence_attendance_id );
                     END IF;

                     -- call delete absences for each absence_attendance_id
                     delete_absences
                         (l_absence_attendance_id,
                          l_edited_days,
                          l_uom
                         );

	             IF g_debug THEN
                        hr_utility.TRACE(   'ABS:Completed delete for Absence attendance id = '
                                 || l_absence_attendance_id );
                     END IF;

	             l_ed_days_ix := 0;
	             l_edited_days.DELETE;

	          END IF;
	          EXIT WHEN NOT l_ret_delete_absences.EXISTS (l_abs_ix);
	        END LOOP;

              END IF;


               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 120);
               END IF;

               l_ret_delete_absences.DELETE;
               l_edited_days.DELETE;

               IF g_debug THEN
                  hr_utility.trace('ABS: Start processing CREATE Absence records in TEMP table');
               END IF;

               -- Process CREATE records with UOM = DAYS, this is for fresh unplanned absences
               -- logic for continuous posting for DAYS
               l_days_ix := days_tab.FIRST;
               l_count := days_tab.COUNT;

               IF g_debug THEN
                  hr_utility.TRACE ('ABS:current count - days = ' || days_tab.COUNT);
               END IF;

               IF (l_count > 0)
               THEN
                  LOOP
                     EXIT WHEN l_days_ix > l_count;

                     IF (days_tab.EXISTS (l_days_ix + 1))
                     THEN

                        IF (    days_tab (l_days_ix + 1).absence_attendance_type_id =
                                   days_tab (l_days_ix).absence_attendance_type_id
                            AND days_tab (l_days_ix + 1).cost_allocation_keyflex_id =
                                   days_tab (l_days_ix).cost_allocation_keyflex_id
                            AND TRUNC (days_tab (l_days_ix + 1).day_stop) =
                                      TRUNC (days_tab (l_days_ix).day_stop) + 1
                           )
                        THEN
                           IF g_debug THEN
                              hr_utility.TRACE ('ABS:difference of 1 in dates');
 			   END IF;

                           days_tab (l_days_ix + 1).day_start := days_tab (l_days_ix).day_start;

                           UPDATE hxc_abs_ret_temp
                              SET link_time_building_block_id = days_tab (l_days_ix + 1).time_building_block_id
                            WHERE time_building_block_id = days_tab (l_days_ix).time_building_block_id
                              AND absences_action = 'CREATE';

                           days_tab.DELETE (l_days_ix);
                        ELSIF (    days_tab (l_days_ix + 1).absence_attendance_type_id =
                                      days_tab (l_days_ix).absence_attendance_type_id
                               AND days_tab (l_days_ix + 1).cost_allocation_keyflex_id =
                                      days_tab (l_days_ix).cost_allocation_keyflex_id
                               AND TRUNC (days_tab (l_days_ix + 1).day_stop) =
                                         TRUNC (days_tab (l_days_ix).day_stop)
                              )
                        THEN

                           IF g_debug THEN
                              hr_utility.TRACE ('ABS:no difference in dates');
 			   END IF;

                           l_temp_row := days_tab (l_days_ix);
                           days_tab (l_days_ix) := days_tab (l_days_ix + 1);
                           days_tab (l_days_ix + 1) := l_temp_row;
                        END IF;
                     END IF;

                     l_days_ix := l_days_ix + 1;
                  END LOOP;

                  IF g_debug THEN
                     hr_utility.set_location('ABS:Processing '||l_proc, 130);
                  END IF;

                  -- send to absences module
                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:CALLING create_absences for DAYS');
                  END IF;

                  create_absences (days_tab,
                                   'D');

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:COMPLETED create_absences for DAYS');
                  END IF;

               END IF;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 140);
               END IF;

               -- Process CREATE records with UOM = HOURS (fresh unplanned absences)
               IF g_debug THEN
                  hr_utility.TRACE ('ABS:current count - hours = ' || hours_tab.COUNT);
               END IF;

               -- send to absences module, there is no continuous posting for HOURS
               IF (hours_tab.COUNT > 0)
               THEN

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:CALLING create_absences for HOURS');
                  END IF;

                  create_absences (hours_tab,
                                   'H');

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:COMPLETED create_absences for HOURS');
                  END IF;

               END IF;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 150);
               END IF;


		-- Processing for TXN DETAILS creation starts
 	       OPEN c_success_from_temp (p_resource_id, p_tc_start, p_tc_stop);

               FETCH c_success_from_temp BULK COLLECT INTO l_temp_id_tab,
               						   l_temp_ovn_tab,
               						   l_latest_ovn_tab,
               						   l_action_tab,
               						   l_latest_date_to_tab;

               CLOSE c_success_from_temp;

               l_d_ix := 0;
               l_h_ix := 0;

               IF (l_temp_id_tab.COUNT > 0) THEN
                FOR l_ix IN l_temp_id_tab.FIRST .. l_temp_id_tab.LAST
                LOOP

                 IF (l_action_tab(l_ix) = 'CREATE')  THEN
                   l_d_ix := l_d_ix + 1;
                   l_create_id_tab(l_d_ix) := l_temp_id_tab(l_ix);
                   l_create_ovn_tab(l_d_ix) := l_temp_ovn_tab(l_ix);
                 ELSE
                   l_h_ix := l_h_ix + 1;
                   l_delete_id_tab(l_h_ix) := l_temp_id_tab(l_ix);

                   IF l_latest_date_to_tab(l_ix) <> hr_general.end_of_time THEN
                   	l_delete_ovn_tab(l_h_ix) := l_latest_ovn_tab(l_ix);
                   ELSE
                   	l_delete_ovn_tab(l_h_ix) := l_temp_ovn_tab(l_ix);
                   END IF;
                 END IF;

                END LOOP;
               END IF;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 160);
                  hr_utility.trace('create txn records - '||l_create_id_tab.COUNT);
                  hr_utility.trace('delete txn records - '||l_delete_id_tab.COUNT);
               END IF;

               -- Process CREATE absence records from TEMP table which are successfully sent to Absences
               -- Make an entry for these retrieved Absence details in TXN tables.
               IF (l_create_id_tab.COUNT > 0)
               THEN

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:CALLING create_transactions for CREATE records - '||l_create_id_tab.COUNT);
                  END IF;

                  create_transactions (l_create_id_tab,
                  		       l_create_ovn_tab,
                                       'SUCCESS',
                                       g_success_create_msg
                                      );

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:COMPLETED create_transactions for CREATE records');
                  END IF;

                  FORALL l_tx_index IN l_create_id_tab.FIRST .. l_create_id_tab.LAST
                     DELETE FROM hxc_abs_ret_temp
                           WHERE time_building_block_id = l_create_id_tab(l_tx_index);

                  IF g_debug THEN
                     hr_utility.set_location('ABS:Processing '||l_proc, 170);
                  END IF;

               END IF;

	       l_create_id_tab.DELETE;
	       l_create_ovn_tab.DELETE;



               -- Fetch all DELETE absence records from TEMP table which are successfully sent to Absences
               -- Make an entry for these retrieved Absence details in TXN tables.
               IF (l_delete_id_tab.COUNT > 0)
               THEN

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:CALLING create_transactions for DELETE records - '||l_delete_id_tab.COUNT);
                  END IF;

                  create_transactions (l_delete_id_tab,
                  		       l_delete_ovn_tab,
                                       'SUCCESS',
                                       g_success_delete_msg
                                      );

                  IF g_debug THEN
                     hr_utility.TRACE ('ABS:COMPLETED create_transactions for DELETE records');
                  END IF;

                  FORALL l_tx_index IN l_delete_id_tab.FIRST .. l_delete_id_tab.LAST
                     DELETE FROM hxc_abs_ret_temp
                           WHERE time_building_block_id = l_delete_id_tab(l_tx_index);

                  IF g_debug THEN
                     hr_utility.set_location('ABS:Processing '||l_proc, 180);
                  END IF;

               END IF;

	       l_delete_id_tab.DELETE;
	       l_delete_ovn_tab.DELETE;

               IF g_debug THEN
                  hr_utility.set_location('ABS:Processing '||l_proc, 190);
               END IF;


               IF g_debug THEN
                  hr_utility.set_location('ABS:Leaving '||l_proc, 200);
               END IF;



            END IF;                 -- end if for g_all_id_tab.COUNT <> 0
         END IF;                  -- endif for if2
      END IF;                   -- endif for if1 --- g_abs_integ_enabled = 'Y'

   EXCEPTION

      WHEN ret_rules_not_set
      THEN
         IF g_debug THEN
            hr_utility.TRACE ('ABS:EXCEPTION IN POST_ABSENCES - Retrieval Rules not set');
         END IF;

         hxc_timecard_message_helper.addErrorToCollection
        					(p_messages
 						,'HXC_GNUTL_NO_RET_RULE_FOR_RET'
 						,hxc_timecard.c_error
 						,null
 						,'EMP&'||nvl(l_emp_name, 'unknown')
 						,'HXC'
 						,null
 						,null
 						,null
 						,null );

 	 addTkError(l_emp_name);

      WHEN OTHERS
      THEN
         IF g_debug THEN
            hr_utility.TRACE ('ABS:EXCEPTION RAISED FROM POST_ABSENCES');
         END IF;
         -- Bug 9394444
         -- Added this backtrace to error stack because
         -- we are calling an OTHERS exception.
         -- Removed all other OTHERS exception blocks because that was
         -- either way unnecessary.
         hr_utility.trace(dbms_utility.format_error_backtrace);

         IF (g_all_id_tab.COUNT > 0) THEN
             create_transactions (p_tbb_id            => g_all_id_tab,
             			  p_tbb_ovn	      => g_all_ovn_tab,
                                  p_status            => 'ERRORS',
                                  p_description       =>    SUBSTR (SQLERRM, 1,  2000  ) || g_fail_create_msg
                                 );


             DELETE FROM hxc_abs_ret_temp
             WHERE resource_id = g_resource_id
               AND trunc(day_start) >= trunc(g_tc_start)
               AND trunc(day_stop) <= trunc(g_tc_stop);

         END IF;

         hxc_timecard_message_helper.addErrorToCollection
        					(p_messages
 						,nvl(g_error_message, 'HXC_ABS_RET_FAILED')
 						,hxc_timecard.c_error
 						,null
 						,'EMP_NAME&'||nvl(l_emp_name, 'unknown')
 						,'HXC'
 						,null
 						,null
 						,null
 						,null );

 	 addTkError(l_emp_name);


   END post_absences;

                                  /*********CALLED PROCEDURES**********/


-- Procedure to Create Absences in HR module and update HXC_ABS_CO_DETAILS with the latest absence info.

   PROCEDURE create_absences (
      p_absences   IN   hxc_abs_retrieval_pkg.t_absences,
      p_uom        IN   VARCHAR2
   )
   AS
      CURSOR get_create_abs_details (c_tbb_id NUMBER)
      IS
         SELECT time_building_block_id,
                object_version_number,
                trunc(day_start) day_start,
                trunc(day_stop) day_stop
           FROM hxc_abs_ret_temp temp
          START WITH time_building_block_id = c_tbb_id
        CONNECT BY PRIOR time_building_block_id =  link_time_building_block_id;

      l_id_tab 			    NUMTAB;
      l_ovn_tab			    NUMTAB;

      l_day_start_tab		    DATETAB;
      l_day_stop_tab		    DATETAB;

      l_element_type_id		    NUMBER;
      l_in_time			    DATE;
      l_out_time		    DATE;
      l_absence_attendance_type_id  NUMBER;
      l_abs_ix                      NUMBER;
      l_absence_hours               NUMBER                            := NULL;
      l_absence_days                NUMBER;
      l_occurrence                  NUMBER;
      l_object_version_number       NUMBER;
      l_absence_attendance_id       NUMBER;
      l_dur_dys_less_warning        BOOLEAN;
      l_dur_hrs_less_warning        BOOLEAN;
      l_exceeds_pto_entit_warning   BOOLEAN;
      l_exceeds_run_total_warning   BOOLEAN;
      l_dur_overwritten_warning     BOOLEAN;
      l_abs_day_after_warning       BOOLEAN;
      l_abs_overlap_warning         BOOLEAN;
      l_time_start                  VARCHAR2 (10)                     := NULL;
      l_time_end                    VARCHAR2 (10)                     := NULL;
      l_day_start                   DATE;
      l_day_stop                    DATE;

      l_proc 			    VARCHAR2(100);

      --set_to_view_only_c  EXCEPTION;

   BEGIN

      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
         l_proc := g_package||'create_absences';
         hr_utility.set_location('ABS:Processing '||l_proc, 200);
      END IF;

      IF g_debug THEN
    	 hr_utility.TRACE ('ABS:p_uom = ' || p_uom);
      END IF;

      IF (p_uom = 'D')
      THEN
         l_absence_hours := NULL;
      ELSE
         l_absence_days := NULL;
      END IF;

      l_abs_ix := p_absences.FIRST;

      LOOP

       -- Removed this check for bug 8932359
      	/* IF (is_view_only(p_absences (l_abs_ix).absence_attendance_type_id)) THEN
      	       IF g_debug THEN
	          hr_utility.trace('ABS:This Absence Type is changed to VIEW ONLY before retrieval - Wrong Setup');
	       END IF;

	       RAISE set_to_view_only_c;

         END IF;*/

         IF (p_uom = 'D')
         THEN
            l_day_start := TRUNC (p_absences (l_abs_ix).day_start);
            l_day_stop := TRUNC (p_absences (l_abs_ix).day_stop);
            l_absence_days := (l_day_stop - l_day_start) + 1;

         ELSE
            l_absence_hours := (  p_absences (l_abs_ix).out_time - p_absences (l_abs_ix).in_time ) * 24;
            l_day_start := TRUNC (p_absences (l_abs_ix).in_time);
            l_day_stop := TRUNC (p_absences (l_abs_ix).out_time);
            l_time_start := TO_CHAR (p_absences (l_abs_ix).in_time, 'HH24:MI');
            l_time_end := TO_CHAR (p_absences (l_abs_ix).out_time, 'HH24:MI');
         END IF;

         l_absence_attendance_type_id := p_absences (l_abs_ix).absence_attendance_type_id;
         l_element_type_id  := p_absences (l_abs_ix).element_type_id;
         l_in_time := p_absences (l_abs_ix).in_time;
         l_out_time := p_absences (l_abs_ix).out_time;

         IF g_debug THEN
            hr_utility.TRACE ('ABS: Parameters passed to HR CREATE API');
            hr_utility.TRACE ('ABS:person_id = ' || p_absences (l_abs_ix).resource_id);
            hr_utility.TRACE ('ABS:g_business_group_id = ' || g_business_group_id);
            hr_utility.TRACE ('ABS:absence_attendance_type_id = ' || l_absence_attendance_type_id);
            hr_utility.TRACE ('ABS:l_day_start = ' || l_day_start);
            hr_utility.TRACE ('ABS:l_time_start = ' || l_time_start);
            hr_utility.TRACE ('ABS:l_day_stop = ' || l_day_stop);
            hr_utility.TRACE ('ABS:l_time_end = ' || l_time_end);
            hr_utility.TRACE ('ABS:l_absence_days = ' || l_absence_days);
            hr_utility.TRACE ('ABS:l_absence_hours = ' || l_absence_hours);
            hr_utility.TRACE ('ABS:Calling HR CREATE API');
         END IF;


         -- send data to absences
         hr_person_absence_api.create_person_absence
            (p_validate                        => FALSE,
             p_effective_date                  => SYSDATE,
             p_person_id                       => p_absences (l_abs_ix).resource_id,
             p_business_group_id               => g_business_group_id,
             p_absence_attendance_type_id      => l_absence_attendance_type_id,
             p_date_notification               => SYSDATE,
             p_date_start                      => l_day_start,
             p_time_start                      => l_time_start,
             p_date_end                        => l_day_stop,
             p_time_end                        => l_time_end,
             p_absence_days                    => l_absence_days,
             p_absence_hours                   => l_absence_hours,
             p_program_application_id          => 809,
             p_called_from                     => 809,
             p_absence_attendance_id           => l_absence_attendance_id,
             p_object_version_number           => l_object_version_number,
             p_occurrence                      => l_occurrence,
             p_dur_dys_less_warning            => l_dur_dys_less_warning,
             p_dur_hrs_less_warning            => l_dur_hrs_less_warning,
             p_exceeds_pto_entit_warning       => l_exceeds_pto_entit_warning,
             p_exceeds_run_total_warning       => l_exceeds_run_total_warning,
             p_dur_overwritten_warning         => l_dur_overwritten_warning,
             p_abs_day_after_warning           => l_abs_day_after_warning,
             p_abs_overlap_warning             => l_abs_overlap_warning
            );

         IF g_debug THEN
            hr_utility.TRACE ('ABS:completed HR CREATE API');
            hr_utility.TRACE ('ABS:Created Absence Attendance Id - '||l_absence_attendance_id);
         END IF;

         OPEN get_create_abs_details (p_absences (l_abs_ix).time_building_block_id);

         FETCH get_create_abs_details BULK COLLECT INTO l_id_tab  ,
      							l_ovn_tab ,
      							l_day_start_tab ,
      							l_day_stop_tab	;


         CLOSE get_create_abs_details;

         IF l_id_tab.COUNT > 0
         THEN

            -- update the absence_attendance_id column for the details sent as SINGLE continuous absence entry
            FORALL l_index IN l_id_tab.FIRST .. l_id_tab.LAST
               UPDATE hxc_abs_ret_temp
                  SET retrieval_status = 'SUCCESS',
                      absence_attendance_id = l_absence_attendance_id
                WHERE time_building_block_id = l_id_tab(l_index)
                  AND absence_attendance_id IS NULL;

            IF g_debug THEN
               hr_utility.TRACE ('ABS:updated temp table = ' || SQL%ROWCOUNT);
            END IF;

            -- update absence details if it is already present in CO table
            FORALL l_index IN l_id_tab.FIRST .. l_id_tab.LAST
               UPDATE hxc_abs_co_details
                  SET object_version_number = l_ovn_tab(l_index),
                      absence_type_id = l_absence_attendance_type_id,
                      absence_attendance_id = l_absence_attendance_id,
                      element_type_id = l_element_type_id,
                      uom = SUBSTR(p_uom,1,1),
                      measure = nvl(l_absence_hours, 1),
                      start_date = nvl(l_in_time, l_day_start_tab(l_index)),
                      end_date = nvl(l_out_time, l_day_stop_tab(l_index))
                WHERE time_building_block_id = l_id_tab(l_index)
                  AND stage = 'RET';


            FORALL l_index IN l_id_tab.FIRST .. l_id_tab.LAST
               UPDATE hxc_abs_co_details
                  SET absence_attendance_id = l_absence_attendance_id
                WHERE time_building_block_id = l_id_tab(l_index)
                  AND stage <> 'RET';

            IF g_debug THEN
               hr_utility.TRACE ('ABS:Updated HXC_ABS_CO_DETAILS');
            END IF;

         END IF;

         -- HXC_ABS_CO_DETAILS should contain only unique records for each detail id belonging to the timecard
         -- inserting fresh unplanned absence records
         INSERT INTO hxc_abs_co_details
               (TIME_BUILDING_BLOCK_ID,
 		OBJECT_VERSION_NUMBER ,
 		ABSENCE_TYPE_ID       ,
 		ABSENCE_ATTENDANCE_ID ,
 		ELEMENT_TYPE_ID       ,
 		UOM                   ,
 		MEASURE               ,
 		START_DATE            ,
 		END_DATE              ,
 		STAGE                 ,
 		RESOURCE_ID           ,
 		START_TIME            ,
 		STOP_TIME)
            (SELECT time_building_block_id,
                    object_version_number,
                    absence_attendance_type_id,
                    absence_attendance_id,
                    element_type_id,
                    uom,
                    nvl(l_absence_hours, 1),
                    NVL (in_time, TRUNC (day_start)),
                    NVL (out_time, TRUNC (day_stop)),
                    'RET',
                    g_resource_id,
                    g_tc_start,
                    g_tc_stop
               FROM hxc_abs_ret_temp temp
              WHERE temp.absence_attendance_id = l_absence_attendance_id
                AND temp.retrieval_status = 'SUCCESS'
                AND NOT EXISTS (
                       SELECT 1
                         FROM hxc_abs_co_details absco
                        WHERE absco.time_building_block_id = temp.time_building_block_id));

	 IF g_debug THEN
            hr_utility.TRACE ('ABS:Created new records in CO table = ' || SQL%ROWCOUNT);
 	 END IF;

         -- update the ELEMENT ENTRY with the COST CENTER information if the element is costed in HR
         IF (p_absences (l_abs_ix).cost_allocation_keyflex_id <> 0)
         THEN
            update_cost_center
                             (l_absence_attendance_id,
                              p_absences (l_abs_ix).cost_allocation_keyflex_id
                             );
         END IF;

         IF g_debug THEN
            hr_utility.trace('ABS:Process next');
         END IF;

         l_abs_ix := p_absences.NEXT (l_abs_ix);
         EXIT WHEN NOT p_absences.EXISTS (l_abs_ix);
      END LOOP;

      IF g_debug THEN
         hr_utility.set_location('ABS:Leaving '||l_proc, 210);
      END IF;


   -- Commented code for bug 8932359
      /*WHEN set_to_view_only_c
      THEN
         IF g_debug THEN
            hr_utility.TRACE ('ABS:EXCEPTION IN CREATE_ABSENCES - set_to_view_only_c');
         END IF;

	 g_error_message := NULL;
	 g_error_message :=  'HXC_ABS_VIEW_ONLY';

	 RAISE;  */


   END create_absences;




-- This procedure is used to recreate absences which are not edited but part of a deleted absence attendance id
-- Scenario : When a absence record holds absences info from 01-jan-2009 to 10-jan-2009
-- After prepopulation, if 3-jan-2009 and 7-jan-2009 only are deleted/updated, then delete the single absence entry in HR and
-- recreate absences for the remaining untouched days

   PROCEDURE recreate_absences (
      p_absences                    IN   hxc_abs_retrieval_pkg.t_absences_details,
      p_uom                         IN   VARCHAR2,
      p_old_absence_attendance_id   IN   NUMBER
   )
   AS
      l_abs_ix                      NUMBER;
      l_absence_hours               NUMBER                            := NULL;
      l_absence_days                NUMBER;
      l_occurrence                  NUMBER;
      l_object_version_number       NUMBER;
      l_new_absence_attendance_id   NUMBER;
      l_dur_dys_less_warning        BOOLEAN;
      l_dur_hrs_less_warning        BOOLEAN;
      l_exceeds_pto_entit_warning   BOOLEAN;
      l_exceeds_run_total_warning   BOOLEAN;
      l_dur_overwritten_warning     BOOLEAN;
      l_abs_day_after_warning       BOOLEAN;
      l_abs_overlap_warning         BOOLEAN;
      l_time_start                  VARCHAR2 (10)                     := NULL;
      l_time_end                    VARCHAR2 (10)                     := NULL;
      l_date_start                  DATE;
      l_date_end                    DATE;

      l_proc 			VARCHAR2(100);

   BEGIN

      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
         l_proc := g_package||'recreate_absences';
         hr_utility.set_location('ABS:Processing '||l_proc, 300);
      END IF;

      IF (p_uom = 'D')
      THEN
         l_absence_hours := NULL;
      ELSE
         l_absence_days := NULL;
      END IF;

      l_abs_ix := p_absences.FIRST;

      LOOP
         l_date_start := TRUNC (p_absences (l_abs_ix).date_start);
         l_date_end := TRUNC (p_absences (l_abs_ix).date_end);

         IF (p_uom = 'D')
         THEN
            l_absence_days := (l_date_end - l_date_start) + 1;
         ELSE
            l_absence_hours :=
                 (  TO_DATE (   TO_CHAR (l_date_end, 'DD-MON-YYYY')
                             || p_absences (l_abs_ix).time_end,
                             'DD-MON-YYYY HH24:MI:SS'
                            )
                  - TO_DATE (   TO_CHAR (l_date_start, 'DD-MON-YYYY')
                             || p_absences (l_abs_ix).time_start,
                             'DD-MON-YYYY HH24:MI:SS'
                            )
                 ) * 24;
            l_time_start := p_absences (l_abs_ix).time_start;
            l_time_end := p_absences (l_abs_ix).time_end;
         END IF;

         IF g_debug THEN
            hr_utility.TRACE ('ABS: Recreation');
            hr_utility.TRACE ('ABS: Parameters passed to HR CREATE API');
            hr_utility.TRACE ('ABS:person_id = ' || p_absences (l_abs_ix).person_id);
            hr_utility.TRACE ('ABS:g_business_group_id = ' || g_business_group_id);
            hr_utility.TRACE ('ABS:absence_attendance_type_id = ' || p_absences (l_abs_ix).absence_attendance_type_id);
            hr_utility.TRACE ('ABS:l_day_start = ' || l_date_start);
            hr_utility.TRACE ('ABS:l_time_start = ' || l_time_start);
            hr_utility.TRACE ('ABS:l_day_stop = ' || l_date_end);
            hr_utility.TRACE ('ABS:l_time_end = ' || l_time_end);
            hr_utility.TRACE ('ABS:l_absence_days = ' || l_absence_days);
            hr_utility.TRACE ('ABS:l_absence_hours = ' || l_absence_hours);
            hr_utility.TRACE ('ABS:Calling HR CREATE API');
         END IF;

         -- send data to absences
         hr_person_absence_api.create_person_absence
            (p_validate                        => FALSE,
             p_effective_date                  => SYSDATE,
             p_person_id                       => p_absences (l_abs_ix).person_id,
             p_business_group_id               => g_business_group_id,
             p_absence_attendance_type_id      => p_absences (l_abs_ix).absence_attendance_type_id,
             p_date_notification               => SYSDATE,
             p_date_start                      => l_date_start,
             p_time_start                      => l_time_start,
             p_date_end                        => l_date_end,
             p_time_end                        => l_time_end,
             p_absence_days                    => l_absence_days,
             p_absence_hours                   => l_absence_hours,
             p_program_application_id          => 809,
             p_called_from                     => 809,
             p_absence_attendance_id           => l_new_absence_attendance_id,
             p_object_version_number           => l_object_version_number,
             p_occurrence                      => l_occurrence,
             p_dur_dys_less_warning            => l_dur_dys_less_warning,
             p_dur_hrs_less_warning            => l_dur_hrs_less_warning,
             p_exceeds_pto_entit_warning       => l_exceeds_pto_entit_warning,
             p_exceeds_run_total_warning       => l_exceeds_run_total_warning,
             p_dur_overwritten_warning         => l_dur_overwritten_warning,
             p_abs_day_after_warning           => l_abs_day_after_warning,
             p_abs_overlap_warning             => l_abs_overlap_warning
            );


         IF g_debug THEN
            hr_utility.TRACE ('ABS:completed HR CREATE API');
            hr_utility.TRACE ('ABS:Created Absence Attendance Id - '||l_new_absence_attendance_id);
         END IF;

         -- update the CO table with the new absence attendance id for those untouched absence details
         -- which are not edited but recreated

         UPDATE hxc_abs_co_details
            SET absence_attendance_id = l_new_absence_attendance_id
          WHERE TRUNC (start_date) BETWEEN TRUNC (l_date_start)
                                       AND TRUNC (l_date_end)
            AND absence_attendance_id = p_old_absence_attendance_id;

         l_abs_ix := p_absences.NEXT (l_abs_ix);
         EXIT WHEN NOT p_absences.EXISTS (l_abs_ix);
      END LOOP;

      IF g_debug THEN
         hr_utility.set_location('ABS:Leaving '||l_proc, 310);
      END IF;


   END recreate_absences;




   -- delete absences from HR for updated/modified TC absences details
   PROCEDURE delete_absences (
      p_absence_attendance_id   IN   NUMBER,
      p_edited_days             IN   hxc_abs_retrieval_pkg.t_edited_days,
      p_uom                     IN   VARCHAR2
   )
   AS
      CURSOR get_absences_details_cur
      IS
         SELECT absatt.absence_attendance_type_id,
         	trunc(absatt.date_start),
         	trunc(absatt.date_end),
         	absatt.time_start,
                absatt.time_end, absatt.person_id,
                absatt.program_application_id,
                hate.edit_flag
           FROM per_absence_attendances absatt,
           	hxc_absence_type_elements hate
          WHERE absatt.absence_attendance_id = p_absence_attendance_id
            AND absatt.absence_attendance_type_id = hate.absence_attendance_type_id;

      CURSOR co_details_cur
      IS
         SELECT trunc(start_date) start_date,
                trunc(end_date) end_date,
	        to_char(start_date, 'HH24:MI') time_start,
	        to_char(end_date, 'HH24:MI') time_end,
	        start_time,
	        stop_time
	   FROM hxc_abs_co_details absco
	  WHERE absco.absence_attendance_id = p_absence_attendance_id
	    AND absco.time_building_block_id > 0
	    AND NOT EXISTS(select 1 from hxc_abs_ret_temp temp
                  where temp.time_building_block_id = absco.time_building_block_id)
          ORDER BY 1 asc ;

      TYPE t_co_details IS TABLE OF co_details_cur%ROWTYPE;
      l_co_details t_co_details;

      l_absence_attendance_type_id   per_absence_attendances.absence_attendance_type_id%TYPE;
      l_date_start                   per_absence_attendances.date_start%TYPE;
      l_date_end                     per_absence_attendances.date_end%TYPE;
      l_time_start                   per_absence_attendances.time_start%TYPE;
      l_time_end                     per_absence_attendances.time_end%TYPE;
      l_person_id                    per_absence_attendances.person_id%TYPE;
      l_program_application_id       per_absence_attendances.program_application_id%TYPE;
      l_edit_flag		     hxc_absence_type_elements.edit_flag%TYPE;
      l_absences_details             t_absences_details;
      l_abs_index                    BINARY_INTEGER                      := 0;
      l_left                         NUMBER                              := 0;
      l_right                        NUMBER                              := 0;
      l_orig_date_start		     DATE;
      l_orig_date_end		     DATE;
      l_temp_date		     DATE;
      l_old_tc_start                 DATE;
      l_old_tc_stop		     DATE;

      l_proc 			     VARCHAR2(100);
      pref_changed_before_ret	     EXCEPTION;
      --set_to_view_only_d   EXCEPTION;

   BEGIN

      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
         l_proc := g_package||'delete_absences';
         hr_utility.set_location('ABS:Processing '||l_proc, 400);
      END IF;

      IF g_debug THEN
         hr_utility.TRACE (   'ABS:Process DELETE for Absence attendance id  = ' || p_absence_attendance_id );
      END IF;

      -- get absences information from per_absence_attendances table
      OPEN get_absences_details_cur;

      FETCH get_absences_details_cur
       INTO l_absence_attendance_type_id,
            l_date_start,
            l_date_end,
            l_time_start,
            l_time_end,
            l_person_id,
            l_program_application_id,
            l_edit_flag;

      IF get_absences_details_cur%NOTFOUND
      THEN
         IF g_debug THEN
            hr_utility.TRACE ('ABS:Absence record already deleted from HR');
         END IF;

         RETURN;
      END IF;

      CLOSE get_absences_details_cur;

      IF g_debug THEN
        hr_utility.TRACE ('ABS:l_absence_attendance_type_id = '||l_absence_attendance_type_id);
        hr_utility.TRACE ('ABS:l_date_start = '||l_date_start);
        hr_utility.TRACE ('ABS:l_date_end = '||l_date_end);
        hr_utility.TRACE ('ABS:l_time_start = '||l_time_start);
        hr_utility.TRACE ('ABS:l_time_end = '||l_time_end);
        hr_utility.TRACE ('ABS:l_person_id = '||l_person_id);
        hr_utility.TRACE ('ABS:l_program_application_id = '||l_program_application_id);
        hr_utility.TRACE ('ABS:l_edit_flag = '||l_edit_flag);
      END IF;

      IF g_debug THEN
        hr_utility.set_location('ABS:Processing '||l_proc, 410);
      END IF;

      -- delete absences attached to HOURS based absences created by OTL from absences module
      IF (p_uom IN ('H', 'HOURS') AND l_program_application_id = '809')
      THEN

         IF g_debug THEN
            hr_utility.TRACE ('ABS:Call HR DELETE API for absence (hours) = ' || p_absence_attendance_id );
         END IF;

         hr_person_absence_api.delete_person_absence
                          (p_validate                   => FALSE,
                           p_absence_attendance_id      => p_absence_attendance_id,
                           p_object_version_number      => NULL,
                           p_called_from		=> 809
                          );

         UPDATE hxc_abs_co_details
            SET absence_attendance_id = NULL
          WHERE absence_attendance_id = p_absence_attendance_id;

         IF g_debug THEN
            hr_utility.TRACE ('ABS:Rows update (1) - ' || SQL%ROWCOUNT);
	 END IF;

	 IF g_debug THEN
           hr_utility.set_location('ABS:Processing '||l_proc, 420);
         END IF;

         UPDATE hxc_abs_ret_temp
            SET retrieval_status = 'SUCCESS'
          WHERE absence_attendance_id = p_absence_attendance_id;


         RETURN;

      -- If there is a HOURS update,
      -- the new value would go through the regular Create_Absences picked up from TEMP

      END IF;


      -- delete absences and recreate untouched absences
      IF    (l_program_application_id = '809' AND p_uom IN('D', 'DAYS'))
         OR (l_program_application_id = '800' AND g_abs_prepop_edit = 'Y')
      THEN


      	 IF (l_edit_flag = 'N' and l_program_application_id = '800' and g_tc_status = 'DELETED')
      	 THEN
            IF g_debug THEN
	       hr_utility.set_location('ABS:Processing '||l_proc, 425);
            END IF;

            IF g_debug THEN
              hr_utility.trace('ABS:These prepop absences are set to View Only and not deleted from HR on timecard delete');
            END IF;

            UPDATE hxc_abs_co_details
               SET absence_attendance_id = NULL
             WHERE absence_attendance_id = p_absence_attendance_id;

            UPDATE hxc_abs_ret_temp
               SET retrieval_status = 'SUCCESS'
             WHERE absence_attendance_id = p_absence_attendance_id;

            IF g_debug THEN
              hr_utility.set_location('ABS:Processing '||l_proc, 428);
            END IF;

            RETURN;

       	 END IF;


         IF g_debug THEN
            hr_utility.TRACE ('ABS:Call HR DELETE API for absence = ' || p_absence_attendance_id );
         END IF;

         hr_person_absence_api.delete_person_absence
                         (p_validate                   => FALSE,
                          p_absence_attendance_id      => p_absence_attendance_id,
                          p_object_version_number      => NULL,
                          p_called_from		       => 809
                         );

	 IF g_debug THEN
            hr_utility.TRACE ('ABS:Start Splitting the periods');
         END IF;

         -- when recreating DAYS based absences with program application id = 809, it has to still be
         -- recreated as continuous entries whereas for HOURS it has to be recreated as entry for each day
	 IF (p_uom in ('D', 'DAYS')) THEN

           IF g_debug THEN
              hr_utility.TRACE ('ABS:Splitting days' );
           END IF;
	   -- cut the right and left details from the current TC period, if it exists
           -- cutting the left
           IF (l_date_start < g_tc_start)
           THEN
              l_abs_index := l_abs_index + 1;
              l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
              l_absences_details (l_abs_index).date_start := l_date_start;
              l_absences_details (l_abs_index).date_end :=  TRUNC (g_tc_start - 1);
              l_absences_details (l_abs_index).time_start := l_time_start;
              l_absences_details (l_abs_index).time_end := l_time_end;
              l_absences_details (l_abs_index).person_id := l_person_id;
              l_absences_details (l_abs_index).program_application_id :=   l_program_application_id;
              l_left := 1;
           END IF;

           IF g_debug THEN
             hr_utility.set_location('ABS:Processing '||l_proc, 430);
           END IF;

           -- cutting the right
           IF (l_date_end > g_tc_stop)
           THEN
              l_abs_index := l_abs_index + 1;
              l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
              l_absences_details (l_abs_index).date_start :=  TRUNC (g_tc_stop + 1);
              l_absences_details (l_abs_index).date_end := l_date_end;
              l_absences_details (l_abs_index).time_start := l_time_start;
              l_absences_details (l_abs_index).time_end := l_time_end;
              l_absences_details (l_abs_index).person_id := l_person_id;
              l_absences_details (l_abs_index).program_application_id := l_program_application_id;
              l_right := 1;
           END IF;

           IF g_debug THEN
             hr_utility.set_location('ABS:Processing '||l_proc, 440);
           END IF;

           /*
           4 scenarios
           left   right
           0  0, absence_id spreads within the TC period
           0  1, absence_id spreads across current and next TC period
           1  0, absence_id spreads across previous and current TC period
           1  1, absence_id spreads across previous, current and next TC periods
           */
           IF (l_left = 1 AND l_right = 1)
           THEN
              l_date_start := g_tc_start;
              l_date_end := g_tc_stop;
           END IF;

           IF (l_left = 1 AND l_right = 0)
           THEN
              l_date_start := TRUNC (g_tc_start);
              l_date_end := l_date_end;                            -- no change
           END IF;

           IF (l_left = 0 AND l_right = 1)
           THEN
              l_date_start := l_date_start;                        -- no change
              l_date_end := TRUNC (g_tc_stop);
           END IF;

           IF (l_left = 0 AND l_right = 0)
           THEN
              l_date_start := l_date_start;                        -- no change
              l_date_end := l_date_end;                            -- no change
           END IF;

           IF g_debug THEN
             hr_utility.set_location('ABS:Processing '||l_proc, 440);
           END IF;


	   IF g_debug THEN
	      hr_utility.TRACE ('ABS:Process within timecard period');
              hr_utility.TRACE ('ABS:l_date_start = ' || l_date_start);
              hr_utility.TRACE ('ABS:l_date_end = ' || l_date_end);
              hr_utility.TRACE ('ABS:p_edited_days.count = ' || p_edited_days.COUNT);
           END IF;

           -- split based on the days which are updated/deleted within the timecard period
           IF (p_edited_days.COUNT > 0)
           THEN
              FOR l_days IN p_edited_days.FIRST .. p_edited_days.LAST
              LOOP
                 IF (l_date_start < p_edited_days (l_days).day_start)
                 THEN
                    hr_utility.TRACE ('IF - 1');
                    l_abs_index := l_abs_index + 1;
                    l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
                    l_absences_details (l_abs_index).date_start := l_date_start;
                    l_absences_details (l_abs_index).date_end :=  p_edited_days (l_days).day_stop - 1;
                    l_absences_details (l_abs_index).time_start := l_time_start;
                    l_absences_details (l_abs_index).time_end := l_time_end;
                    l_absences_details (l_abs_index).person_id := l_person_id;
                    l_absences_details (l_abs_index).program_application_id := l_program_application_id;
                 END IF;

                 l_date_start := p_edited_days (l_days).day_start + 1;

              END LOOP;

              IF (l_date_start <= l_date_end)
              THEN
                 hr_utility.TRACE ('IF - 2');
                 l_abs_index := l_abs_index + 1;
                 l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
                 l_absences_details (l_abs_index).date_start := l_date_start;
                 l_absences_details (l_abs_index).date_end := l_date_end;
                 l_absences_details (l_abs_index).time_start := l_time_start;
                 l_absences_details (l_abs_index).time_end := l_time_end;
                 l_absences_details (l_abs_index).person_id := l_person_id;
                 l_absences_details (l_abs_index).program_application_id := l_program_application_id;
              END IF;
           END IF;                                    -- p_edited_days.COUNT > 0

           IF g_debug THEN
             hr_utility.set_location('ABS:Processing '||l_proc, 450);
           END IF;

         END IF;  -- p_uom in ('D', 'DAYS')

         -- when recreating HOURS based absences with program application id = 809, it has to be
         -- recreated for each day and hence the logic differs for HOURS and DAYS
	 IF (p_uom in ('H', 'HOURS')) THEN

           IF g_debug THEN
              hr_utility.TRACE ('ABS:Splitting hours' );
           END IF;

	   l_orig_date_start := l_date_start;
	   l_orig_date_end := l_date_end;

	   OPEN co_details_cur;
	   FETCH co_details_cur BULK COLLECT INTO l_co_details;
	   CLOSE co_details_cur;


           IF g_debug THEN
              hr_utility.TRACE ('ABS:l_co_details.COUNT = '||l_co_details.COUNT);
           END IF;

	   IF (l_co_details.COUNT = 0) THEN
	     RETURN;
	   END IF;

           -- recreate absences for periods which fall to the left of the first start_time in l_co_details
	   IF l_date_start < l_co_details (l_co_details.FIRST).start_time THEN

             IF g_debug THEN
               hr_utility.TRACE ('ABS: Processing left for HOURS');
             END IF;

	     LOOP
	     EXIT WHEN l_date_start = l_co_details (l_co_details.FIRST).start_time;

       	       l_abs_index := l_abs_index + 1;

               l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
               l_absences_details (l_abs_index).date_start := l_date_start;
               l_absences_details (l_abs_index).date_end := l_date_start;
               l_absences_details (l_abs_index).time_start := '00:00';
               l_absences_details (l_abs_index).time_end := '23:59';
               l_absences_details (l_abs_index).person_id := l_person_id;
               l_absences_details (l_abs_index).program_application_id := l_program_application_id;

               l_date_start := l_date_start + 1;
             END LOOP;
	   END IF;

           IF g_debug THEN
              hr_utility.set_location('ABS:Processing '||l_proc, 451);
           END IF;

           -- recreate absences for periods which fall to the right of the last stop_time in l_co_details
	   IF l_date_end > l_co_details (l_co_details.LAST).stop_time THEN

             IF g_debug THEN
               hr_utility.TRACE ('ABS: Processing right for HOURS');
             END IF;

	     LOOP
	     EXIT WHEN l_date_end = l_co_details (l_co_details.LAST).stop_time;

       	       l_abs_index := l_abs_index + 1;

               l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
               l_absences_details (l_abs_index).date_start := l_date_end;
               l_absences_details (l_abs_index).date_end := l_date_end;
               l_absences_details (l_abs_index).time_start := '00:00';
               l_absences_details (l_abs_index).time_end := '23:59';
               l_absences_details (l_abs_index).person_id := l_person_id;
               l_absences_details (l_abs_index).program_application_id := l_program_application_id;

               l_date_end := l_date_end - 1;
             END LOOP;
	   END IF;

           IF g_debug THEN
              hr_utility.set_location('ABS:Processing '||l_proc, 452);
           END IF;

	   -- recreate absences with for the time periods in l_co_details
           IF g_debug THEN
             hr_utility.TRACE ('ABS: Processing within CO for HOURS');
           END IF;

           FOR l_days IN l_co_details.FIRST .. l_co_details.LAST
           LOOP
       	    l_abs_index := l_abs_index + 1;

            l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
            l_absences_details (l_abs_index).date_start := l_co_details (l_days).start_date;
            l_absences_details (l_abs_index).date_end := l_co_details (l_days).end_date;
            l_absences_details (l_abs_index).time_start := l_co_details (l_days).time_start;
            l_absences_details (l_abs_index).time_end := l_co_details (l_days).time_end;
            l_absences_details (l_abs_index).person_id := l_person_id;
            l_absences_details (l_abs_index).program_application_id := l_program_application_id;

	   END LOOP;

           IF g_debug THEN
              hr_utility.set_location('ABS:Processing '||l_proc, 453);
           END IF;

	   l_old_tc_start := l_co_details(l_co_details.FIRST).start_time;
	   l_old_tc_stop := l_co_details(l_co_details.FIRST).stop_time;

	   -- recreate absences for left out time periods which fall within the first and last timecard
	   -- period in l_co_details
           FOR l_days IN l_co_details.FIRST .. l_co_details.LAST
           LOOP
       	    IF (l_co_details(l_days).start_time - l_old_tc_stop > 1) THEN

             IF g_debug THEN
               hr_utility.TRACE ('ABS: Processing missing time periods within CO for HOURS');
             END IF;

       	     l_temp_date := l_old_tc_stop + 1;

	     LOOP
	     EXIT WHEN l_co_details(l_days).start_time = l_temp_date;

       	       l_abs_index := l_abs_index + 1;

               l_absences_details (l_abs_index).absence_attendance_type_id := l_absence_attendance_type_id;
               l_absences_details (l_abs_index).date_start := l_temp_date;
               l_absences_details (l_abs_index).date_end := l_temp_date;
               l_absences_details (l_abs_index).time_start := '00:00';
               l_absences_details (l_abs_index).time_end := '23:59';
               l_absences_details (l_abs_index).person_id := l_person_id;
               l_absences_details (l_abs_index).program_application_id := l_program_application_id;

               l_temp_date := l_temp_date + 1;
             END LOOP;


       	    END IF;

 	    l_old_tc_start := l_co_details(l_days).start_time;
	    l_old_tc_stop := l_co_details(l_days).stop_time;



	   END LOOP;

           IF g_debug THEN
              hr_utility.set_location('ABS:Processing '||l_proc, 454);
           END IF;


           IF (l_absences_details.COUNT > 0) THEN
             IF l_absences_details(l_absences_details.FIRST).date_start = l_orig_date_start THEN
               l_absences_details (l_absences_details.FIRST).time_start := l_time_start;
             END IF;

             IF l_absences_details(l_absences_details.LAST).date_end = l_orig_date_end THEN
               l_absences_details (l_absences_details.LAST).time_end := l_time_end;
             END IF;
           END IF;

           IF g_debug THEN
              hr_utility.set_location('ABS:Processing '||l_proc, 455);
           END IF;

         END IF;  -- p_uom in ('H', 'HOURS')

         IF g_debug THEN
            hr_utility.set_location('ABS:Processing '||l_proc, 458);
         END IF;


         -- delete absences details from absco table which are updated/deleted from Timecard
         UPDATE hxc_abs_co_details
            SET absence_attendance_id = NULL
          WHERE time_building_block_id IN (
                   SELECT time_building_block_id
                     FROM hxc_abs_ret_temp
                    WHERE absence_attendance_id = p_absence_attendance_id
                      AND absences_action = 'DELETE')
             OR time_building_block_id < 0
            AND absence_attendance_id = p_absence_attendance_id;

         IF g_debug THEN
           hr_utility.set_location('ABS:Processing '||l_proc, 460);
         END IF;

         -- periods which has to be recreated due to absence_attendance_id deletion
         IF l_absences_details.COUNT > 0
         THEN
            IF g_debug THEN
               hr_utility.TRACE ('ABS:split periods');
            END IF;

            FOR l_abs_ix IN l_absences_details.FIRST .. l_absences_details.LAST
            LOOP
              IF g_debug THEN
                 hr_utility.TRACE ('ABS:abs type id'||l_absences_details (l_abs_ix).absence_attendance_type_id );
                 hr_utility.TRACE ('ABS:start date'||l_absences_details (l_abs_ix).date_start);
                 hr_utility.TRACE ('ABS:end date'||l_absences_details (l_abs_ix).date_end);
              END IF;
            END LOOP;

            -- call recreate_absences for the split periods
            IF g_debug THEN
               hr_utility.TRACE ('ABS:Calling recreate_absences proc');
            END IF;

            recreate_absences (l_absences_details,
                               p_uom,
                               p_absence_attendance_id
                              );

            IF g_debug THEN
               hr_utility.TRACE ('ABS:Completed recreate_absences proc');
            END IF;

         END IF;

         UPDATE hxc_abs_ret_temp
            SET retrieval_status = 'SUCCESS'
          WHERE absence_attendance_id = p_absence_attendance_id;

         IF g_debug THEN
           hr_utility.set_location('ABS:Processing '||l_proc, 470);
         END IF;

          RETURN;
      END IF;

      IF (l_program_application_id = '800' AND g_abs_prepop_edit = 'N')
      THEN
         IF (g_tc_status = 'DELETED') THEN

           IF g_debug THEN
             hr_utility.trace('ABS:Absences with source HR are not allowed to be deleted on timecard delete');
           END IF;

           UPDATE hxc_abs_co_details
              SET absence_attendance_id = NULL
            WHERE absence_attendance_id = p_absence_attendance_id;

           UPDATE hxc_abs_ret_temp
              SET retrieval_status = 'SUCCESS'
            WHERE absence_attendance_id = p_absence_attendance_id;

           IF g_debug THEN
             hr_utility.set_location('ABS:Processing '||l_proc, 480);
           END IF;
         ELSE
           IF g_debug THEN
             hr_utility.trace('ABS:This prepopulated absence was allowed to be edited in Timecard and later set to EDIT NOT ALLOWED before retrieval');
             hr_utility.trace('ABS:Change in preference setup before Absence Retrieval - WRONG SETUP');
           END IF;

           RAISE pref_changed_before_ret;
         END IF;
      END IF;

   EXCEPTION

	-- Commented code for bug 8932359
      /*WHEN set_to_view_only_d
      THEN
         IF g_debug THEN
            hr_utility.TRACE ('ABS:EXCEPTION IN DELETE_ABSENCES - set_to_view_only_d');
         END IF;

	 g_error_message := NULL;
	 g_error_message :=  'HXC_ABS_VIEW_ONLY';

	 RAISE;*/

      WHEN pref_changed_before_ret
      THEN
         IF g_debug THEN
            hr_utility.TRACE ('ABS:EXCEPTION IN DELETE_ABSENCES - pref_changed_before_ret');
         END IF;

	 g_error_message := NULL;
	 g_error_message :=  'HXC_ABS_NO_EDIT_PREP';

	 RAISE;


   END delete_absences;




-- Create Transaction detail records for successfully retrieved absences
   PROCEDURE create_transactions (
      p_tbb_id         IN   hxc_abs_retrieval_pkg.NUMTAB,
      p_tbb_ovn        IN   hxc_abs_retrieval_pkg.NUMTAB,
      p_status         IN   VARCHAR2 DEFAULT NULL,
      p_description    IN   VARCHAR2 DEFAULT NULL
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

   BEGIN

      IF g_transaction_id IS NULL THEN
         insert_audit_header (p_status,
                              p_description,
                              g_transaction_id);
      END IF;

      insert_audit_details (p_tbb_id,
      			    p_tbb_ovn,
                            p_status,
                            p_description,
                            g_transaction_id
                           );

      COMMIT;

   END create_transactions;


   PROCEDURE insert_audit_header (
      p_status           IN              VARCHAR2,
      p_description      IN              VARCHAR2,
      p_transaction_id   OUT NOCOPY      hxc_transactions.transaction_id%TYPE
   )
   IS
      CURSOR c_transaction_sequence
      IS
         SELECT hxc_transactions_s.NEXTVAL
           FROM DUAL;

   BEGIN
      OPEN c_transaction_sequence;

      FETCH c_transaction_sequence
       INTO g_transaction_id;

      CLOSE c_transaction_sequence;

      INSERT INTO hxc_transactions
                  (transaction_id,
                   transaction_date,
                   TYPE,
                   transaction_process_id,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   status,
                   exception_description,
                   data_set_id
                  )
           VALUES (g_transaction_id,
                   SYSDATE,
                   'RETRIEVAL',
                   g_retrieval_process_id,
                   NULL,
                   SYSDATE,
                   NULL,
                   SYSDATE,
                   NULL,
                   p_status,
                   p_description,
                   NULL
                  );

      p_transaction_id := g_transaction_id;

   END insert_audit_header;



   PROCEDURE insert_audit_details (
      p_tbb_id           IN   hxc_abs_retrieval_pkg.NUMTAB,
      p_tbb_ovn          IN   hxc_abs_retrieval_pkg.NUMTAB,
      p_status           IN   VARCHAR2 DEFAULT NULL,
      p_description      IN   VARCHAR2 DEFAULT NULL,
      p_transaction_id   IN   hxc_transactions.transaction_id%TYPE
   )
   IS
      CURSOR c_transaction_detail_sequence
      IS
         SELECT hxc_transaction_details_s.NEXTVAL
           FROM DUAL;

      l_transaction_detail_id   hxc_transaction_details.transaction_detail_id%TYPE;
   BEGIN
      -- insert into hxc_transaction_details
      FOR l_tx_index IN p_tbb_id.FIRST .. p_tbb_id.LAST
      LOOP
         OPEN c_transaction_detail_sequence;

         FETCH c_transaction_detail_sequence
          INTO l_transaction_detail_id;

         CLOSE c_transaction_detail_sequence;


         INSERT INTO hxc_transaction_details
                     (transaction_detail_id,
                      time_building_block_id,
                      transaction_id,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      time_building_block_ovn,
                      status,
                      exception_description,
                      data_set_id
                     )
              VALUES (l_transaction_detail_id,
                      p_tbb_id (l_tx_index),
                      g_transaction_id,
                      NULL,
                      SYSDATE,
                      NULL,
                      SYSDATE,
                      NULL,
                      p_tbb_ovn (l_tx_index),
                      p_status,
                      p_description,
                      NULL
                     );
      END LOOP;
   END insert_audit_details;



   PROCEDURE update_cost_center (
      p_absence_attendance_id        NUMBER,
      p_cost_allocation_keyflex_id   NUMBER
   )
   AS
      CURSOR get_element_entry_info
      IS
         SELECT peef.element_entry_id, peef.effective_start_date,
                peef.effective_end_date,
                peef.object_version_number,
                pelf.costable_type
           FROM pay_element_entries_f peef, pay_element_links_f pelf
          WHERE peef.creator_id = p_absence_attendance_id
            AND peef.element_link_id = pelf.element_link_id
            AND peef.object_version_number =
                                 (SELECT /*+NO_UNNEST*/
                                         MAX (object_version_number)
                                    FROM pay_element_entries_f
                                   WHERE creator_id = p_absence_attendance_id);

      l_element_entry_id       NUMBER;
      l_effective_start_date   DATE;
      l_effective_end_date     DATE;
      l_ee_ovn                 NUMBER;
      l_costable_type          VARCHAR2 (30);
      l_update_warning         BOOLEAN;

      l_proc 			VARCHAR2(100);

   BEGIN

      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
         l_proc := g_package||'update_cost_center';
         hr_utility.set_location('ABS:Processing '||l_proc, 500);
      END IF;

      IF g_debug THEN
         hr_utility.TRACE
                (   'ABS:Entered update_cost_center for absence_attendance_id = '  || p_absence_attendance_id  );

      END IF;

      OPEN get_element_entry_info;

      FETCH get_element_entry_info
       INTO l_element_entry_id,
            l_effective_start_date,
            l_effective_end_date,
            l_ee_ovn,
            l_costable_type;

      CLOSE get_element_entry_info;

      IF g_debug THEN
         hr_utility.TRACE ('ABS:l_element_entry_id = ' || l_element_entry_id);
         hr_utility.TRACE ('ABS:l_costable_type = ' || l_costable_type);
      END IF;

      IF l_costable_type = 'C'
      THEN
         IF g_debug THEN
            hr_utility.TRACE (   'ABS:p_cost_allocation_keyflex_id = ' || p_cost_allocation_keyflex_id );
         END IF;

         -- update element entries with the cost allocation keyflex id
         py_element_entry_api.update_element_entry
                (p_validate                        => FALSE,
                 p_datetrack_update_mode           => hr_api.g_correction,
                 p_effective_date                  => TRUNC(l_effective_start_date),
                 p_business_group_id               => g_business_group_id,
                 p_element_entry_id                => l_element_entry_id,
                 p_object_version_number           => l_ee_ovn,
                 p_cost_allocation_keyflex_id      => p_cost_allocation_keyflex_id,
                 p_effective_start_date            => l_effective_start_date,
                 p_effective_end_date              => l_effective_end_date,
                 p_update_warning                  => l_update_warning
                );
      END IF;

      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 520);
      END IF;


   END update_cost_center;



   PROCEDURE populate_cost_keyflex (
      p_cost_attributes   IN OUT NOCOPY  hxc_abs_retrieval_pkg.t_cost_attributes
   )
   IS
      sql_stmt    		    VARCHAR2 (300);
      l_proc     		    VARCHAR2(100);
      l_cost_allocation_structure   VARCHAR2(150);
   BEGIN

      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
         l_proc := g_package||'populate_cost_keyflex';
         hr_utility.set_location('ABS:Processing '||l_proc, 600);
      END IF;


      sql_stmt :=
         'SELECT flex_value FROM fnd_flex_values WHERE flex_value_id = :id';

      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 610);
      END IF;

      FOR att_ix IN p_cost_attributes.FIRST .. p_cost_attributes.LAST
      LOOP

         << CONTINUE_TO_NEXT >>
         LOOP

         -- attribute1
         IF (p_cost_attributes (att_ix).attribute1 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value1
                        USING p_cost_attributes (att_ix).attribute1;


         END IF;

         -- attribute2
         IF (p_cost_attributes (att_ix).attribute2 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value2
                        USING p_cost_attributes (att_ix).attribute2;


         END IF;

         -- attribute3
         IF (p_cost_attributes (att_ix).attribute3 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value3
                        USING p_cost_attributes (att_ix).attribute3;


         END IF;

         -- attribute4
         IF (p_cost_attributes (att_ix).attribute4 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value4
                        USING p_cost_attributes (att_ix).attribute4;


         END IF;

         -- attribute5
         IF (p_cost_attributes (att_ix).attribute5 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value5
                        USING p_cost_attributes (att_ix).attribute5;


         END IF;

         -- attribute6
         IF (p_cost_attributes (att_ix).attribute6 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value6
                        USING p_cost_attributes (att_ix).attribute6;


         END IF;

         -- attribute7
         IF (p_cost_attributes (att_ix).attribute7 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value7
                        USING p_cost_attributes (att_ix).attribute7;


         END IF;

         -- attribute8
         IF (p_cost_attributes (att_ix).attribute8 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value8
                        USING p_cost_attributes (att_ix).attribute8;


         END IF;

         -- attribute9
         IF (p_cost_attributes (att_ix).attribute9 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value9
                        USING p_cost_attributes (att_ix).attribute9;


         END IF;

         -- attribute10
         IF (p_cost_attributes (att_ix).attribute10 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value10
                        USING p_cost_attributes (att_ix).attribute10;


         END IF;

         -- attribute11
         IF (p_cost_attributes (att_ix).attribute11 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value11
                        USING p_cost_attributes (att_ix).attribute11;


         END IF;

         -- attribute12
         IF (p_cost_attributes (att_ix).attribute11 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value12
                        USING p_cost_attributes (att_ix).attribute12;


         END IF;

         -- attribute13
         IF (p_cost_attributes (att_ix).attribute13 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value13
                        USING p_cost_attributes (att_ix).attribute13;


         END IF;

         -- attribute14
         IF (p_cost_attributes (att_ix).attribute14 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value14
                        USING p_cost_attributes (att_ix).attribute14;


         END IF;

         -- attribute15
         IF (p_cost_attributes (att_ix).attribute15 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value15
                        USING p_cost_attributes (att_ix).attribute15;


         END IF;

         -- attribute16
         IF (p_cost_attributes (att_ix).attribute16 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value16
                        USING p_cost_attributes (att_ix).attribute16;


         END IF;

         -- attribute17
         IF (p_cost_attributes (att_ix).attribute17 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value17
                        USING p_cost_attributes (att_ix).attribute17;


         END IF;

         -- attribute18
         IF (p_cost_attributes (att_ix).attribute18 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value18
                        USING p_cost_attributes (att_ix).attribute18;


         END IF;

         -- attribute19
         IF (p_cost_attributes (att_ix).attribute19 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value19
                        USING p_cost_attributes (att_ix).attribute19;


         END IF;

         -- attribute20
         IF (p_cost_attributes (att_ix).attribute20 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value20
                        USING p_cost_attributes (att_ix).attribute20;


         END IF;

         -- attribute21
         IF (p_cost_attributes (att_ix).attribute21 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value21
                        USING p_cost_attributes (att_ix).attribute21;


         END IF;

         -- attribute22
         IF (p_cost_attributes (att_ix).attribute22 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value22
                        USING p_cost_attributes (att_ix).attribute22;


         END IF;

         -- attribute23
         IF (p_cost_attributes (att_ix).attribute23 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value23
                        USING p_cost_attributes (att_ix).attribute23;


         END IF;

         -- attribute24
         IF (p_cost_attributes (att_ix).attribute24 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value24
                        USING p_cost_attributes (att_ix).attribute24;


         END IF;

         -- attribute25
         IF (p_cost_attributes (att_ix).attribute25 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value25
                        USING p_cost_attributes (att_ix).attribute25;


         END IF;

         -- attribute26
         IF (p_cost_attributes (att_ix).attribute26 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value26
                        USING p_cost_attributes (att_ix).attribute26;


         END IF;

         -- attribute27
         IF (p_cost_attributes (att_ix).attribute27 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value27
                        USING p_cost_attributes (att_ix).attribute27;


         END IF;

         -- attribute28
         IF (p_cost_attributes (att_ix).attribute28 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value28
                        USING p_cost_attributes (att_ix).attribute28;


         END IF;

         -- attribute29
         IF (p_cost_attributes (att_ix).attribute29 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value29
                        USING p_cost_attributes (att_ix).attribute29;


         END IF;

         -- attribute30
         IF (p_cost_attributes (att_ix).attribute30 IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE sql_stmt
                         INTO p_cost_attributes (att_ix).flex_value30
                        USING p_cost_attributes (att_ix).attribute30;


         END IF;

         -- Bug 8879182
         -- Added the below exit to avoid the infinite loop.

         EXIT CONTINUE_TO_NEXT;
         END LOOP CONTINUE_TO_NEXT;

      END LOOP;


      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 630);
      END IF;

  /*    -- log for attribute1
      FOR att_ix IN p_cost_attributes.FIRST .. p_cost_attributes.LAST
      LOOP
         IF (p_cost_attributes (att_ix).attribute1 IS NOT NULL)
         THEN
            hr_utility.TRACE (   'p_cost_attributes(att_ix).attribute1 = '
                              || p_cost_attributes (att_ix).attribute1
                             );
            hr_utility.TRACE (   'p_cost_attributes(att_ix).flex_value1 = '
                              || p_cost_attributes (att_ix).flex_value1
                             );
         END IF;
      END LOOP;*/

      l_cost_allocation_structure := get_cost_alloc_struct(g_business_group_id);

      -- Derive the cost_allocation_keyflex_id
      FOR att_ix IN p_cost_attributes.FIRST .. p_cost_attributes.LAST
      LOOP
         p_cost_attributes (att_ix).cost_allocation_keyflex_id :=
            hr_entry.maintain_cost_keyflex
                    (p_cost_keyflex_structure          => l_cost_allocation_structure,
                     p_cost_allocation_keyflex_id      => -1,
                     p_concatenated_segments           => NULL,
                     p_summary_flag                    => 'N',
                     p_start_date_active               => NULL,
                     p_end_date_active                 => NULL,
                     p_segment1                        => p_cost_attributes
                                                                       (att_ix).flex_value1,
                     p_segment2                        => p_cost_attributes
                                                                       (att_ix).flex_value2,
                     p_segment3                        => p_cost_attributes
                                                                       (att_ix).flex_value3,
                     p_segment4                        => p_cost_attributes
                                                                       (att_ix).flex_value4,
                     p_segment5                        => p_cost_attributes
                                                                       (att_ix).flex_value5,
                     p_segment6                        => p_cost_attributes
                                                                       (att_ix).flex_value6,
                     p_segment7                        => p_cost_attributes
                                                                       (att_ix).flex_value7,
                     p_segment8                        => p_cost_attributes
                                                                       (att_ix).flex_value8,
                     p_segment9                        => p_cost_attributes
                                                                       (att_ix).flex_value9,
                     p_segment10                       => p_cost_attributes
                                                                       (att_ix).flex_value10,
                     p_segment11                       => p_cost_attributes
                                                                       (att_ix).flex_value11,
                     p_segment12                       => p_cost_attributes
                                                                       (att_ix).flex_value12,
                     p_segment13                       => p_cost_attributes
                                                                       (att_ix).flex_value13,
                     p_segment14                       => p_cost_attributes
                                                                       (att_ix).flex_value14,
                     p_segment15                       => p_cost_attributes
                                                                       (att_ix).flex_value15,
                     p_segment16                       => p_cost_attributes
                                                                       (att_ix).flex_value16,
                     p_segment17                       => p_cost_attributes
                                                                       (att_ix).flex_value17,
                     p_segment18                       => p_cost_attributes
                                                                       (att_ix).flex_value18,
                     p_segment19                       => p_cost_attributes
                                                                       (att_ix).flex_value19,
                     p_segment20                       => p_cost_attributes
                                                                       (att_ix).flex_value20,
                     p_segment21                       => p_cost_attributes
                                                                       (att_ix).flex_value21,
                     p_segment22                       => p_cost_attributes
                                                                       (att_ix).flex_value22,
                     p_segment23                       => p_cost_attributes
                                                                       (att_ix).flex_value23,
                     p_segment24                       => p_cost_attributes
                                                                       (att_ix).flex_value24,
                     p_segment25                       => p_cost_attributes
                                                                       (att_ix).flex_value25,
                     p_segment26                       => p_cost_attributes
                                                                       (att_ix).flex_value26,
                     p_segment27                       => p_cost_attributes
                                                                       (att_ix).flex_value27,
                     p_segment28                       => p_cost_attributes
                                                                       (att_ix).flex_value28,
                     p_segment29                       => p_cost_attributes
                                                                       (att_ix).flex_value29,
                     p_segment30                       => p_cost_attributes
                                                                       (att_ix).flex_value30
                    );
      END LOOP;

      IF g_debug THEN
         hr_utility.set_location('ABS:Leaving '||l_proc, 640);
      END IF;


   END populate_cost_keyflex;


   FUNCTION is_view_only
      (p_absence_attendance_type_id NUMBER)
   RETURN BOOLEAN
   IS

     l_edit_flag VARCHAR2(1);

   BEGIN

     IF g_debug THEN
            hr_utility.trace('ABS:Inside function IS_VIEW_ONLY');
     END IF;

     SELECT edit_flag INTO l_edit_flag
       FROM hxc_absence_type_elements
      WHERE absence_attendance_type_id = p_absence_attendance_type_id;

      IF g_debug THEN
         hr_utility.trace('ABS:l_edit_flag = '||l_edit_flag);
      END IF;

     IF (l_edit_flag = 'Y') THEN
         IF g_debug THEN
         	hr_utility.trace('ABS:View and Edit');
         END IF;

         RETURN FALSE;
     ELSE
         IF g_debug THEN
         	hr_utility.trace('ABS:View Only');
         END IF;

         RETURN TRUE;
     END IF;


   END is_view_only;


   PROCEDURE addTkError( p_token   VARCHAR2 )
   IS

     l_index BINARY_INTEGER;
     l_msg_name VARCHAR2(50);

   BEGIN

     l_msg_name := 'HXC_ABS_RET_FAILED';

     if g_tk_ret_messages.COUNT = 0 then
       l_index := 0;
     else
       l_index := g_tk_ret_messages.LAST;
     end if;

     g_tk_ret_messages(l_index + 1).message_name := l_msg_name ;
     g_tk_ret_messages(l_index + 1).employee_name := p_token;

   END;

   FUNCTION get_cost_alloc_struct ( p_business_group_id IN NUMBER)
   RETURN VARCHAR2
   IS

   l_cost_alloc_struct   VARCHAR2(150);

   BEGIN
       IF g_cost_struct.EXISTS(p_business_group_id)
       THEN
           RETURN g_cost_struct(p_business_group_id).cost_allocation_structure;
       ELSE
      	   SELECT cost_allocation_structure
      	     INTO l_cost_alloc_struct
             FROM per_business_groups
            WHERE business_group_id = p_business_group_id;

	    g_cost_struct(p_business_group_id).business_group_id := p_business_group_id;
	    g_cost_struct(p_business_group_id).cost_allocation_structure := l_cost_alloc_struct;

            RETURN g_cost_struct(p_business_group_id).cost_allocation_structure;
       END IF;
   END get_cost_alloc_struct;


   FUNCTION get_retrieval_rule ( p_retrieval_rule_grp_id IN NUMBER)
   RETURN VARCHAR2
   IS

   l_ret_status  VARCHAR2(20);

   BEGIN
       IF g_ret_rules.EXISTS(p_retrieval_rule_grp_id)
       THEN
           RETURN g_ret_rules(p_retrieval_rule_grp_id).status;
       ELSE
	      SELECT rrc.status
	        INTO l_ret_status
	        FROM hxc_retrieval_rule_comps rrc,
	             hxc_retrieval_rules rr,
	             hxc_retrieval_rule_grp_comps_v rrgc,
	             hxc_retrieval_rule_groups_v rrg
	       WHERE rrg.retrieval_rule_group_id = p_retrieval_rule_grp_id
	         AND rrgc.retrieval_rule_group_id = rrg.retrieval_rule_group_id
	         AND rrgc.retrieval_process_id = g_retrieval_process_id
	         AND rr.retrieval_rule_id = rrgc.retrieval_rule_id
	         AND rrc.retrieval_rule_id = rr.retrieval_rule_id;

	    g_ret_rules(p_retrieval_rule_grp_id).retrieval_rule_group_id := p_retrieval_rule_grp_id;
	    g_ret_rules(p_retrieval_rule_grp_id).status := l_ret_status;

            RETURN g_ret_rules(p_retrieval_rule_grp_id).status;
       END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'NODATA';


   END get_retrieval_rule;



END hxc_abs_retrieval_pkg;


/
