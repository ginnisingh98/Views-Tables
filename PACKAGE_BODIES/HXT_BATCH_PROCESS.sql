--------------------------------------------------------
--  DDL for Package Body HXT_BATCH_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_BATCH_PROCESS" AS
/* $Header: hxtbat.pkb 120.12.12010000.7 2010/04/28 06:22:14 amakrish ship $ */
g_debug boolean := hr_utility.debug_enabled;
  g_time_period_id      NUMBER := NULL;
  g_lookup_not_found    EXCEPTION;
  g_error_ins_batch_lines    EXCEPTION;  --SIR517 PWM 18FEB00
  FUNCTION Call_Gen_Error(p_batch_id IN NUMBER
                         ,p_location IN VARCHAR2
                         ,p_error_text IN VARCHAR2
                         ,p_oracle_error_text IN VARCHAR2 default NULL )
  RETURN NUMBER;
  FUNCTION Get_Transfer_Batch_Status(p_batch_id  NUMBER,
				     p_batch_status OUT NOCOPY VARCHAR2)
  RETURN NUMBER;  -- SPR C352 by BC
-----------------------------------------------------------------

/********Bug: 4620315 **********/

/* Function to set the default value for the profile 'HXT_MERGE_BATCH_TIMECARDS' */

FUNCTION merge_batches
   RETURN fnd_profile_option_values.profile_option_value%TYPE
AS
   l_merge_batches                    fnd_profile_option_values.profile_option_value%TYPE;
   l_merge_batches_default   CONSTANT fnd_profile_option_values.profile_option_value%TYPE := 'N';

BEGIN
   l_merge_batches := fnd_profile.VALUE ('HXT_MERGE_BATCH_TIMECARDS');

   IF (l_merge_batches IS NULL)
   THEN
      l_merge_batches := l_merge_batches_default;
   END IF;

   RETURN l_merge_batches;
END merge_batches;

/* Procedure to merge all TCs in the Batch range processed during Validate for BEE (normal and retro)
   process into new separate consolidated batches for Valid/Warning/error TC's and deleting the
   empty batches left behind. All the TC's that pass validation get copied into a new BEE Batch
   containing all valid TCs. All TCs that fail with warning in the validation get copied into a new
   BEE Batch containing all warning TCs. All TCs that fail with Error in the validation get copied
   into a new BEE Batch containing all Errored TCs. */

PROCEDURE merge_batches (p_merge_batch_name	VARCHAR2,
			 p_merge_batches	MERGE_BATCHES_TYPE_TABLE,
			 p_del_empty_batches    DEL_EMPTY_BATCHES_TYPE_TABLE,
			 p_bus_group_id		NUMBER,
                         p_mode		        VARCHAR2
			)
IS
   l_valid_batch_id		PAY_BATCH_HEADERS.BATCH_ID%TYPE;
   l_error_batch_id		PAY_BATCH_HEADERS.BATCH_ID%TYPE;
   l_warning_batch_id		PAY_BATCH_HEADERS.BATCH_ID%TYPE;
   l_temp_batch_upd_id	        PAY_BATCH_HEADERS.BATCH_ID%TYPE;
   l_batch_name		        PAY_BATCH_HEADERS.BATCH_NAME%TYPE;
   l_valid_batch_name		PAY_BATCH_HEADERS.BATCH_NAME%TYPE;
   l_error_batch_name		PAY_BATCH_HEADERS.BATCH_NAME%TYPE;
   l_warning_batch_name	        PAY_BATCH_HEADERS.BATCH_NAME%TYPE;
   l_object_version_number	PAY_BATCH_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
   l_ovn			HXT_TIMECARDS_F.OBJECT_VERSION_NUMBER%TYPE;
   l_string1                    VARCHAR2(5);
   l_string2                    VARCHAR2(5);
   l_loop_index1                BINARY_INTEGER;
   l_loop_index2                BINARY_INTEGER;
   l_proc			VARCHAR2(72);
   l_assignment_no		PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER%TYPE;
   l_parent_batch_name		PAY_BATCH_HEADERS.BATCH_NAME%TYPE;
   l_batch_type                 VARCHAR2(10);

BEGIN
   g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
      l_proc := 'hxt_batch_process.merge_batches';
      hr_utility.set_location('Entering: '||l_proc, 10);
   END IF;

   l_batch_name := p_merge_batch_name;

   IF p_mode = 'NR' THEN /* Non-Retro */
      l_string1 := ' C';
      l_string2 := '_C_';
   ELSIF p_mode = 'R' THEN /* Retro */
      l_string1 := ' C R';
      l_string2 := '_C_R';
   END IF;

   l_loop_index1 := p_merge_batches.first;

   /***  To loop through all  validated TCs and merge them into new separate consolidated batches for
         Valid/Warning/error TCs based on the TCs 'valid_tc_retcode' value.  ***/
   LOOP

      EXIT WHEN NOT p_merge_batches.exists(l_loop_index1);

      IF g_debug THEN
         hr_utility.set_location('Inside merge_batches proc loop: '||p_merge_batches(l_loop_index1).batch_id, 20);
      END IF;

      l_temp_batch_upd_id := null;
      l_batch_type := null;

      IF p_merge_batches(l_loop_index1).valid_tc_retcode = 0 THEN  /* For valid Tcs */

         IF l_valid_batch_id is null THEN
	    l_valid_batch_name := l_batch_name;
	    IF g_debug THEN
	       hr_utility.set_location('Before creating new valid batch header', 30);
	    END IF;
	    pay_batch_element_entry_api.create_batch_header (p_session_date               => sysdate,
                                                             p_batch_name                 => l_valid_batch_name,
	    					             p_business_group_id          => p_bus_group_id,
                                                             p_action_if_exists           => 'I',
							     p_batch_reference            => l_valid_batch_name||l_string1,
                                                             p_batch_source               => 'OTM',
							     p_reject_if_future_changes   => 'N',
                                                             p_batch_id                   => l_valid_batch_id,
                                                             p_object_version_number      => l_object_version_number
                                                            ); /* For creating new batch for valid Tcs. */
	    IF g_debug THEN
	       hr_utility.set_location('After creating new valid batch header: '||l_valid_batch_id, 40);
	    END IF;
	    l_valid_batch_name := l_valid_batch_name||l_string2||to_char(l_valid_batch_id);
	    pay_batch_element_entry_api.update_batch_header (p_session_date               => sysdate,
					                     p_batch_id                   => l_valid_batch_id,
					                     p_object_version_number      => l_object_version_number,
					                     p_batch_name                 => l_valid_batch_name
							    ); /* For updating the batch_name of the newly created batch */

	    fnd_file.put_line (fnd_file.log, 'Successful Batch Name: '||l_valid_batch_name);

	    IF g_debug THEN
	       hr_utility.set_location('After updating valid batch name: '||l_valid_batch_name, 50);
            END IF;
	    BEGIN
	       UPDATE hxt_batch_states
	       SET    status = 'VV'
	       WHERE  batch_id = l_valid_batch_id; /* For updating the status of the newly created batch */
	    END;
	    IF g_debug THEN
	       hr_utility.set_location('After updating valid batch status in hxt_batch_states', 60);
	    END IF;
	 END IF;

	 l_temp_batch_upd_id := l_valid_batch_id;

      ELSIF p_merge_batches(l_loop_index1).valid_tc_retcode = 1 THEN  /* For warning Tcs */

	 IF l_warning_batch_id is null THEN
	    l_warning_batch_name := l_batch_name||'_W';
	    IF g_debug THEN
	       hr_utility.set_location('Before creating new warning batch header', 70);
	    END IF;
	    pay_batch_element_entry_api.create_batch_header (p_session_date               => sysdate,
                                                             p_batch_name                 => l_warning_batch_name,
		   					     p_business_group_id          => p_bus_group_id,
                                                             p_action_if_exists           => 'I',
                                                             p_batch_reference            => l_warning_batch_name||l_string1,
                                                             p_batch_source               => 'OTM',
							     p_reject_if_future_changes   => 'N',
                                                             p_batch_id                   => l_warning_batch_id,
                                                             p_object_version_number      => l_object_version_number
                                                            ); /* For creating new batch for warning Tcs. */
	    IF g_debug THEN
	       hr_utility.set_location('After creating new warning batch header: '||l_warning_batch_id, 80);
	    END IF;
	    l_warning_batch_name := l_warning_batch_name||l_string2||to_char(l_warning_batch_id);
	    pay_batch_element_entry_api.update_batch_header (p_session_date               => sysdate,
						             p_batch_id                   => l_warning_batch_id,
					                     p_object_version_number      => l_object_version_number,
				                             p_batch_name                 => l_warning_batch_name
							    ); /* For updating the batch_name of the newly created batch */

	    fnd_file.put_line (fnd_file.log, 'Warning Batch Name: '||l_warning_batch_name);

	    IF g_debug THEN
	       hr_utility.set_location('After updating warning batch name: '||l_warning_batch_name, 90);
	    END IF;
	    BEGIN
	       UPDATE hxt_batch_states
	       SET    status = 'VW'
	       WHERE  batch_id = l_warning_batch_id; /* For updating the status of the newly created batch */
	    END;
	    IF g_debug THEN
	       hr_utility.set_location('After updating warning batch status in hxt_batch_states', 100);
	    END IF;
	 END IF;

	 l_temp_batch_upd_id := l_warning_batch_id;
	 l_batch_type := 'Warning';

      ELSIF p_merge_batches(l_loop_index1).valid_tc_retcode >= 2 THEN  /* For errored Tcs */

	 IF l_error_batch_id is null THEN
	    l_error_batch_name := l_batch_name||'_E';
	    IF g_debug THEN
	       hr_utility.set_location('Before creating new error batch header', 110);
	    END IF;
	    pay_batch_element_entry_api.create_batch_header (p_session_date               => sysdate,
                                                             p_batch_name                 => l_error_batch_name,
							     p_business_group_id          => p_bus_group_id,
                                                             p_action_if_exists           => 'I',
                                                             p_batch_reference            => l_error_batch_name||l_string1,
							     p_batch_source               => 'OTM',
							     p_reject_if_future_changes   => 'N',
                                                             p_batch_id                   => l_error_batch_id,
                                                             p_object_version_number      => l_object_version_number
                                                            ); /* For creating new batch for erroded Tcs. */
   	    IF g_debug THEN
	       hr_utility.set_location('after creating new error batch header: '||l_error_batch_id, 120);
	    END IF;
	    l_error_batch_name := l_error_batch_name||l_string2||to_char(l_error_batch_id);
	    pay_batch_element_entry_api.update_batch_header (p_session_date               => sysdate,
				                             p_batch_id                   => l_error_batch_id,
				                             p_object_version_number      => l_object_version_number,
				                             p_batch_name                 => l_error_batch_name
				                            ); /* For updating the batch_name of the newly created batch */

	    fnd_file.put_line (fnd_file.log, 'Error Batch Name: '||l_error_batch_name);

	    IF g_debug THEN
	       hr_utility.set_location('After updating error batch name: '||l_error_batch_name, 130);
	    END IF;
	    BEGIN
	       UPDATE hxt_batch_states
	       SET    status = 'VE'
	       WHERE  batch_id = l_error_batch_id; /* For updating the status of the newly created batch */
	    END;
	    IF g_debug THEN
	       hr_utility.set_location('After updating error batch status in hxt_batch_states', 140);
	    END IF;
	 END IF;

	 l_temp_batch_upd_id := l_error_batch_id;
	 l_batch_type := 'Error';

      END IF;

      IF g_debug THEN
         hr_utility.set_location('Before updating TC reference: '||p_merge_batches(l_loop_index1).tc_id||
				 ' Mode: '||p_mode, 150);
      END IF;

      IF p_mode = 'NR' THEN  /* For updating the TC references of Non-Retro Batches to the newly created batch */
	 l_ovn := p_merge_batches(l_loop_index1).object_version_number;
	 HXT_DML.UPDATE_HXT_TIMECARDS (p_rowid		       => p_merge_batches(l_loop_index1).tc_rowid,
	   			       p_id		       => p_merge_batches(l_loop_index1).tc_id,
				       p_for_person_id	       => p_merge_batches(l_loop_index1).for_person_id,
				       p_time_period_id	       => p_merge_batches(l_loop_index1).time_period_id,
				       p_auto_gen_flag	       => p_merge_batches(l_loop_index1).auto_gen_flag,
				       p_batch_id	       => l_temp_batch_upd_id,
				       p_approv_person_id      => p_merge_batches(l_loop_index1).approv_person_id,
				       p_approved_timestamp    => p_merge_batches(l_loop_index1).approved_timestamp,
				       p_created_by	       => p_merge_batches(l_loop_index1).created_by,
				       p_creation_date	       => p_merge_batches(l_loop_index1).creation_date,
				       p_last_updated_by       => p_merge_batches(l_loop_index1).last_updated_by,
				       p_last_update_date      => p_merge_batches(l_loop_index1).last_update_date,
				       p_last_update_login     => p_merge_batches(l_loop_index1).last_update_login,
				       p_payroll_id	       => p_merge_batches(l_loop_index1).payroll_id,
				       p_status		       => p_merge_batches(l_loop_index1).status,
				       p_effective_start_date  => p_merge_batches(l_loop_index1).effective_start_date,
				       p_effective_end_date    => p_merge_batches(l_loop_index1).effective_end_date,
				       p_object_version_number => l_ovn
				      );
      ELSIF p_mode = 'R' THEN  /* For updating the TC references of Retro Batches to the newly created batch */
	 BEGIN
	    UPDATE hxt_det_hours_worked_f
	    SET    retro_batch_id = l_temp_batch_upd_id,
	           object_version_number = object_version_number + 1
	    WHERE  retro_batch_id = p_merge_batches(l_loop_index1).batch_id
	    AND    tim_id = p_merge_batches(l_loop_index1).tc_id;
	 END;

	 IF l_batch_type in ('Warning', 'Error') THEN
            BEGIN
	       SELECT assignment_number
	       INTO   l_assignment_no
	       FROM   per_all_assignments_f
	       WHERE  person_id = (SELECT for_person_id
			  	   FROM   hxt_timecards_x
				   WHERE  id = p_merge_batches(l_loop_index1).tc_id
				  )
               AND    sysdate between effective_start_date and effective_end_date;

               SELECT pbh.batch_name
	       INTO   l_parent_batch_name
	       FROM   pay_batch_headers pbh
	       WHERE  pbh.batch_id = (SELECT tc.batch_id
			              FROM   hxt_timecards_x tc
		    	              WHERE  tc.id = p_merge_batches(l_loop_index1).tc_id
				     );

	    EXCEPTION
	       WHEN others THEN
                  null;
	    END;

	    fnd_file.put_line (fnd_file.log, 'Assignment# = '|| l_assignment_no||
			       ' has an '||l_batch_type||' Timecard in the Batch: '||l_parent_batch_name);
         END IF;

      END IF;

      IF g_debug THEN
         hr_utility.set_location('After updating TC reference', 160);
      END IF;

      l_loop_index1 := p_merge_batches.next(l_loop_index1);

   END LOOP;

   l_loop_index2 := p_del_empty_batches.first;

   LOOP /* To loop through empty batches left behind and delete them */

      EXIT WHEN NOT p_del_empty_batches.exists(l_loop_index2);
      IF g_debug THEN
         hr_utility.set_location('Before deleting empty batches: '||p_del_empty_batches(l_loop_index2).batch_id||
				 ' ovn: '||p_del_empty_batches(l_loop_index2).batch_ovn, 170);
      END IF;

      pay_batch_element_entry_api.delete_batch_header (p_batch_id              => p_del_empty_batches(l_loop_index2).batch_id,
						       p_object_version_number => p_del_empty_batches(l_loop_index2).batch_ovn
						      );
      IF g_debug THEN
         hr_utility.set_location('After deleting empty batches', 180);
      END IF;

      BEGIN
	 DELETE FROM hxt_batch_states
	 WHERE  batch_id = p_del_empty_batches(l_loop_index2).batch_id;
      END;

      IF g_debug THEN
         hr_utility.set_location('After deleting empty batches from hxt_batch_states', 190);
      END IF;

      l_loop_index2 := p_del_empty_batches.next(l_loop_index2);

   END LOOP;

   IF g_debug THEN
      hr_utility.set_location('Leaving: '||l_proc, 200);
   END IF;

END merge_batches;

/********Bug: 4620315 **********/

PROCEDURE Main_Process (
  errbuf                OUT NOCOPY     VARCHAR2,
  retcode               OUT NOCOPY     NUMBER,
  p_payroll_id          IN      NUMBER,
  p_date_earned         IN      VARCHAR2,             --ORA128  --FAS111
  p_time_period_id      IN      NUMBER DEFAULT NULL,  -- SPR C166
  p_from_batch_num      IN      NUMBER DEFAULT NULL,
  p_to_batch_num        IN      NUMBER DEFAULT NULL,
  p_ref_num             IN      VARCHAR2 DEFAULT NULL,
  p_process_mode        IN      VARCHAR2,
  p_bus_group_id        IN      NUMBER,
  p_merge_flag		IN	VARCHAR2 DEFAULT '0',
  p_merge_batch_name	IN	VARCHAR2 DEFAULT NULL,
  p_merge_batch_specified IN	VARCHAR2 DEFAULT NULL
  ) IS
  -- Cursor returns all batch's with timecards for specified payroll,
  -- time period, batch id, and batch ref that haven't been transferred.
l_date_earned DATE := to_date(p_date_earned,'YYYY/MM/DD HH24:MI:SS');
  CURSOR cur_batch(c_payroll_id NUMBER,
                   c_time_period_id NUMBER,
                   c_batch_num NUMBER,
                   c_reference_num VARCHAR2) IS
           SELECT pbh.batch_id,
                  hbs.status batch_status,             --SIR020
                  pbh.batch_reference  ,
                  pbh.object_version_number
             FROM pay_batch_headers pbh,               --GLOBAL
                  hxt_batch_states hbs                 --SIR020
            WHERE pbh.business_group_id = p_bus_group_id --GLOBAL
              AND hbs.batch_id = pbh.batch_id          --SIR020
              AND pbh.batch_id BETWEEN nvl(c_batch_num,0)
		          AND nvl(c_batch_num,999999999999)
              AND (pbh.batch_reference LIKE nvl(c_reference_num , '%')
                   OR (pbh.batch_reference IS NULL
					AND c_reference_num IS NULL))
              AND exists (SELECT 'x'
                            FROM hxt_timecards_x tim       --SIR017
                           WHERE tim.batch_id = pbh.batch_id
                                               )                                  --bug 5748118
              AND  pbh.batch_status = 'U' ;                     --bug 2709527
--
-- local variables
--
  l_batch_id            NUMBER;
  l_batch_requested     NUMBER      DEFAULT NULL;          -- SPR C166 BY BC
  l_do_cursor           VARCHAR2(1) DEFAULT 'N';
  l_starting_batch_num  NUMBER;                            -- SPR C166
  l_ending_batch_num    NUMBER;                            -- SPR C166
  l_process_mode        VARCHAR2(80);
  l_session_date        DATE;
  l_batch_status        VARCHAR2(30);
  l_pay_retcode         NUMBER      DEFAULT 0;
  l_valid_retcode       NUMBER      DEFAULT 0;
  l_sum_retcode         NUMBER      DEFAULT 0;
  l_main_retcode        NUMBER      DEFAULT 0;
  l_final_pay_retcode   NUMBER      DEFAULT 0;
  l_final_valid_retcode NUMBER      DEFAULT 0;
  l_final_main_retcode  NUMBER      DEFAULT 0;
  l_final_sum_retcode   NUMBER      DEFAULT 0;
  l_rollback_retcode    NUMBER      DEFAULT 0;    -- SPR C163
  l_final_rollback_retcode NUMBER   DEFAULT 0;    -- SPR C163
  l_errbuf              VARCHAR2(80)DEFAULT NULL;
  l_retcode             NUMBER      DEFAULT 0;
-----------------------------------------------------------------
-- begin SPR C352 by BC
-- Because changes were so numerous,I have cut and re-edited the
-- entire main function for cleaner audit trailing.
-----------------------------------------------------------------
  l_counter             NUMBER      DEFAULT 0;
  l_payroll_id          VARCHAR2(30)DEFAULT NULL;
  l_return              NUMBER;
  l_trans_batch_status  NUMBER      DEFAULT 0;
  l_trans_status_code   VARCHAR2(10)DEFAULT NULL;
  b_we_have_batches     BOOLEAN     DEFAULT TRUE;
  b_range_is_active     BOOLEAN     DEFAULT FALSE;
  b_skip_this_one       BOOLEAN     DEFAULT FALSE;
  b_inverted_batch_nums BOOLEAN     DEFAULT FALSE;

  /********Bug: 4620315 **********/

  l_cnt			BINARY_INTEGER;
  l_count		BINARY_INTEGER;
  l_loop_index		BINARY_INTEGER;
  l_merge_batches	merge_batches_type_table;
  p_merge_batches	merge_batches_type_table;
  l_del_empty_batches	del_empty_batches_type_table;

  /********Bug: 4620315 **********/

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	hr_utility.trace(p_bus_group_id);
  	hr_utility.trace(g_time_period_id);
  	hr_utility.trace(l_batch_requested);
    	hr_utility.trace(    p_ref_num);
  end if;


  l_date_earned := to_date(to_char(trunc(l_date_earned),'DD/MM/RRRR'),'DD/MM/RRRR');
  HXT_UTIL.DEBUG('Start process.');-- debug only --HXT115
  g_time_period_id := p_time_period_id;
  l_payroll_id     := to_char(p_payroll_id);
  --
  --Validate and Transfer, Transfer, or Rollback TAMS/O data
  --
  l_ending_batch_num   := p_to_batch_num;
  l_starting_batch_num := p_from_batch_num;
  --
  -- Determine if the user selected a single batch in either field
  --
  IF l_ending_batch_num IS NULL THEN
    IF l_starting_batch_num IS NOT NULL THEN
       l_batch_requested := l_starting_batch_num;
    END IF;
  ELSE
    IF l_starting_batch_num IS NULL THEN
       l_batch_requested := l_ending_batch_num;
    END IF;
  END IF;
  --
  -- Determine if a range has been selected by the user
  --
  IF l_starting_batch_num IS NOT NULL AND l_ending_batch_num IS NOT NULL THEN
     HXT_UTIL.DEBUG('A range has been selected by the user');-- debug only --HXT115
     b_range_is_active := TRUE;
     l_batch_requested := l_starting_batch_num;
     IF l_starting_batch_num > l_ending_batch_num THEN
        b_we_have_batches := FALSE;
        b_inverted_batch_nums := TRUE;
     END IF;
  END IF;
  --
  -- Loop through all batches in range requested by the user
  -- (only once through this loop if single batch or no specific batch
  --  requested)
  --
  WHILE b_we_have_batches LOOP
    BEGIN
    HXT_UTIL.DEBUG('Beginning we have batches loop');-- debug only --HXT115
    --
    -- Select and process all user specified batches for this payroll/reference
    -- number
    -- Process batch range specified by the user, else do all available
    --


    FOR batch_rec IN cur_batch(p_payroll_id,
			       g_time_period_id,
			       l_batch_requested,
			       p_ref_num)
    LOOP
      HXT_UTIL.DEBUG('Batch number is ' || TO_CHAR(batch_rec.batch_id));
      l_batch_id := batch_rec.batch_id;
   --  l_counter := l_counter + 1;
      --
      -- rollback all PayMix data per user request
      --
      IF p_process_mode = 'D' and batch_rec.batch_status = 'VT' THEN     --2709527
        l_counter := l_counter + 1;
        HXT_UTIL.DEBUG('Now ROLLING BACK');-- debug only --HXT115
        -- Delete prior errors for this batch
        -- Del_Prior_Errors(batch_rec.batch_id);
        rollback_paymix(batch_rec.batch_id,
                 g_time_period_id, l_rollback_retcode); --SPR C166 BY BC
        IF l_rollback_retcode > l_final_rollback_retcode then
          l_final_rollback_retcode := l_rollback_retcode;
        END IF;
        IF l_rollback_retcode <> 0 THEN
             Set_Batch_Status(l_date_earned,
			      batch_rec.batch_id,
			      'VE');    --SIR020
        END IF;
        --
        -- process user requests to validate Timecards
        --
      ELSIF p_process_mode = 'V' and batch_rec.batch_status <> 'VT' THEN
                     l_counter := l_counter + 1;

        /********Bug: 4620315 **********/
	/*** To record the empty batch details ***/

	 IF p_merge_flag = '1' THEN
	    IF g_debug THEN
	       hr_utility.trace('Populating del_empty_batches record: '||'batchid: '||batch_rec.batch_id||
	                        ' ovn '||batch_rec.object_version_number);
	    END IF;
	    l_cnt := NVL(l_del_empty_batches.LAST,0) +1;
	    l_del_empty_batches(l_cnt).batch_id := batch_rec.batch_id;
	    l_del_empty_batches(l_cnt).batch_ovn := batch_rec.object_version_number;
	 END IF;

         /********Bug: 4620315 **********/

-- Check for a valid status code
--       IF batch_rec.batch_status = 'VT' THEN
--          null; -- Don't revalidate batches that have been sent to PayMIX ORA128
--          l_final_valid_retcode := 2;
--          FND_MESSAGE.SET_NAME('HXT','HXT_39348_TC_VAL_NOT_REPROC');   -- HXT11
--          Insert_Pay_Batch_Errors( batch_rec.batch_id,
--                                'VE',                                  --SIR020
--                                '',                                    --HXT11
--                                l_return);
--        ELSE
          --
          -- Validate batch, status:0=Normal, 1=Warning,
	  -- 2=Stop Level Data Error, 3=System
          --
          HXT_UTIL.DEBUG('Begin timecard validation.');-- debug only --HXT115
          -- Delete prior errors for this batch
          -- Del_Prior_Errors(batch_rec.batch_id);
          HXT_BATCH_VAL.Val_Batch(batch_rec.batch_id,
				  g_time_period_id,
				  l_valid_retcode,
		                  p_merge_flag,
		                  p_merge_batches);

	  /********Bug: 4620315 **********/
	  /*** To record the validated timecards details ***/

	  IF p_merge_flag = '1' THEN
	     l_loop_index := p_merge_batches.first;
	     LOOP
	        EXIT WHEN NOT p_merge_batches.exists(l_loop_index);
		l_count := NVL(l_merge_batches.LAST,0) +1;
                l_merge_batches(l_count).batch_id	       := p_merge_batches(l_loop_index).batch_id;
		l_merge_batches(l_count).tc_id		       := p_merge_batches(l_loop_index).tc_id;
		l_merge_batches(l_count).valid_tc_retcode      := p_merge_batches(l_loop_index).valid_tc_retcode;
		l_merge_batches(l_count).tc_rowid	       := p_merge_batches(l_loop_index).tc_rowid;
		l_merge_batches(l_count).for_person_id	       := p_merge_batches(l_loop_index).for_person_id;
		l_merge_batches(l_count).time_period_id	       := p_merge_batches(l_loop_index).time_period_id;
		l_merge_batches(l_count).auto_gen_flag	       := p_merge_batches(l_loop_index).auto_gen_flag;
		l_merge_batches(l_count).approv_person_id      := p_merge_batches(l_loop_index).approv_person_id;
		l_merge_batches(l_count).approved_timestamp    := p_merge_batches(l_loop_index).approved_timestamp;
		l_merge_batches(l_count).created_by	       := p_merge_batches(l_loop_index).created_by;
		l_merge_batches(l_count).creation_date	       := p_merge_batches(l_loop_index).creation_date;
		l_merge_batches(l_count).last_updated_by       := p_merge_batches(l_loop_index).last_updated_by;
		l_merge_batches(l_count).last_update_date      := p_merge_batches(l_loop_index).last_update_date;
		l_merge_batches(l_count).last_update_login     := p_merge_batches(l_loop_index).last_update_login;
		l_merge_batches(l_count).payroll_id	       := p_merge_batches(l_loop_index).payroll_id;
		l_merge_batches(l_count).status		       := p_merge_batches(l_loop_index).status;
		l_merge_batches(l_count).effective_start_date  := p_merge_batches(l_loop_index).effective_start_date;
		l_merge_batches(l_count).effective_end_date    := p_merge_batches(l_loop_index).effective_end_date;
		l_merge_batches(l_count).object_version_number := p_merge_batches(l_loop_index).object_version_number;
		l_loop_index := p_merge_batches.next(l_loop_index);
             END LOOP;
	  END IF;

	  /********Bug: 4620315 **********/

          --
          -- Set error return code from concurrent process
          --
          IF l_valid_retcode > l_final_valid_retcode then
            l_final_valid_retcode := l_valid_retcode;
          END IF;
          -- Successful Validation, Set batch to ready Status
          IF l_valid_retcode = 0 then
            HXT_UTIL.DEBUG('Successful timecard validation.');--debug onlyHXT115
            Set_Batch_Status(l_date_earned, batch_rec.batch_id, 'VV'); --SIR020
          END IF;
          -- set status to Warning and lets user know we have a TAMS/O
          -- User Level Data Error for this batch
          IF l_valid_retcode = 1 then
            HXT_UTIL.DEBUG('Timecard validation warnings.');-- debug only HXT115
            Set_Batch_Status(l_date_earned, batch_rec.batch_id, 'VW'); --SIR020
            FND_MESSAGE.SET_NAME('HXT','HXT_39349_CHK_IND_TCARD_ERRS'); -- HXT11
            Insert_Pay_Batch_Errors( batch_rec.batch_id,
                                  'W',
                                  '',                                   -- HXT11
                                  l_return);
          END IF;
          IF l_valid_retcode >= 2 THEN
            HXT_UTIL.DEBUG('Timecard validation errors.');-- debug only HXT115
            Set_Batch_Status(l_date_earned, batch_rec.batch_id, 'VE'); --SIR020
            FND_MESSAGE.SET_NAME('HXT','HXT_39349_CHK_IND_TCARD_ERRS'); --HXT11
            Insert_Pay_Batch_Errors( batch_rec.batch_id,
                                 'VE',                                  --SIR020
                                 '',                                    --HXT11
                                 l_return);
          END IF;
        --END IF; -- bug 2709527
      --
      -- Process transfer to PayMIX
      --
      ELSIF p_process_mode = 'T' and batch_rec.batch_status <> 'VT' THEN
           l_counter := l_counter + 1;
        -- Don't allow batches in a Hold status to be Transferred to PayMIX
        IF batch_rec.batch_status = 'H' THEN
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39350_CANT_TRANS_HLD_PAYMX');--HXT11
           Insert_Pay_Batch_Errors( batch_rec.batch_id,
                                   'VE',                                --SIR020
                                   '',                                  -- HXT11
                                   l_return);
          -- Don't move to PayMIX while Timecard errors exist
         ELSIF batch_rec.batch_status in ('VE','ET') THEN               --SIR020
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39351_CANT_TRANS_ERR_PAYMX');-- HXT11
           Insert_Pay_Batch_Errors( batch_rec.batch_id,
                                    'VE',                               --SIR020
                                    '',                                 -- HXT11
                                    l_return);
--        ELSIF (batch_rec.batch_status = 'VT') THEN
--           l_final_valid_retcode := 2;
--           FND_MESSAGE.SET_NAME('HXT','HXT_39352_BTCHS_PREV_TRANS');    -- HXT11
--           Insert_Pay_Batch_Errors( batch_rec.batch_id,
--                                   'VE',                                --SIR020
--                                   '',                                  -- HXT11
--                                   l_return);
         ELSIF batch_rec.batch_status in ('VV','VW') THEN               --SIR020
           -- move to PayMIX
           HXT_UTIL.DEBUG('Now moving to BEE.');-- debug only --HXT115
           sum_to_mix(batch_rec.batch_id, g_time_period_id, l_sum_retcode);
           IF l_sum_retcode > l_final_sum_retcode then
              l_final_sum_retcode := l_sum_retcode;
           END IF;
           IF (l_sum_retcode = 0) then
              HXT_UTIL.DEBUG('Successful move to BEE.');-- debug only --HXT115
		-- bug 848062 Fassadi the p_date_earned replaced with l_date_earned.
              Set_Batch_Status(l_date_earned, batch_rec.batch_id, 'VT');
           END IF;
           IF (l_sum_retcode = 3) then
              HXT_UTIL.DEBUG('Error moving to BEE.');-- debug only --HXT115
              Set_Batch_Status(l_date_earned, batch_rec.batch_id, 'VE');--SIR020
           END IF;
        ELSE
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39353_BTCHS_MST_BE_VALDTED');-- HXT11
           Insert_Pay_Batch_Errors( batch_rec.batch_id,
                                   'VE',                                --SIR020
                                   '',                                  -- HXT11
                                   l_return);
        END IF; -- check status before processing
      ELSE
     	NULL; --bug2709527
      END IF; -- end process selections
      l_valid_retcode := 0;
      l_sum_retcode := 0;
    END LOOP; -- for loop process specific batch
    --
    -- Select the next batch in the range if applicable, else exit loop
    --
    IF b_range_is_active THEN
       IF l_batch_requested < l_ending_batch_num THEN
         l_batch_requested := l_batch_requested + 1;
         b_skip_this_one := FALSE;
       ELSE
         b_we_have_batches := FALSE;
       END IF;
    ELSE
       b_we_have_batches := FALSE;
    END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          IF b_range_is_active THEN
            IF l_batch_requested < l_ending_batch_num THEN
              l_batch_requested := l_batch_requested + 1;
              b_skip_this_one := FALSE;
            ELSE
              b_we_have_batches := FALSE;
            END IF;
          ELSE
            b_we_have_batches := FALSE;
          END IF;
       WHEN g_lookup_not_found THEN --SIR517 PWM 18FEB00
		  raise g_lookup_not_found ; --propogate to the next level
       WHEN OTHERS THEN
          Set_Batch_Status(l_date_earned, l_batch_id, 'VE');
          Insert_Pay_Batch_Errors( l_batch_id,
                                   'VE',
                                   sqlerrm,
                                   l_return);
          --commit;
          IF b_range_is_active THEN
            IF l_batch_requested < l_ending_batch_num THEN
              l_batch_requested := l_batch_requested + 1;
              b_skip_this_one := FALSE;
            ELSE
              b_we_have_batches := FALSE;
            END IF;
          ELSE
            b_we_have_batches := FALSE;
          END IF;
    END; -- batches
  END LOOP;   -- while more batches exist in the range
  -- end SPR C166 BY BC
  -- Check for error totals to return a status from concurrent manager.
  -- Normal
  FND_MESSAGE.SET_NAME('HXT','HXT_39358_COMP_NORMAL');                  -- HXT11
  l_errbuf := FND_MESSAGE.GET;                                          -- HXT11
  FND_MESSAGE.CLEAR;                                                    -- HXT11
  l_retcode := 0;
  -- No batches seleceted at all
  IF l_counter = 0 THEN
     FND_MESSAGE.SET_NAME('HXT','HXT_39359_NO_BATCHES_SEL');            -- HXT11
     l_errbuf := FND_MESSAGE.GET;                                       -- HXT11
     FND_MESSAGE.CLEAR;                                                 -- HXT11
     l_retcode := 2;
  END IF;
  IF b_inverted_batch_nums = TRUE THEN
     FND_MESSAGE.SET_NAME('HXT','HXT_39360_STR_BTCH_NUM_TOO_LRG');      --HXT11
     l_errbuf := FND_MESSAGE.GET;                                       -- HXT11
     FND_MESSAGE.CLEAR;                                                 -- HXT11
     l_retcode := 2;
  END IF;
  IF l_final_rollback_retcode > 0 THEN
     FND_MESSAGE.SET_NAME('HXT','HXT_39361_ERR_DURING_ROLLBACK');       -- HXT11
     l_errbuf := FND_MESSAGE.GET;                                       -- HXT11
     FND_MESSAGE.CLEAR;                                                 -- HXT11
     l_retcode := 2;
  END IF;
  -- A warning was returned from the validate process
  IF l_final_valid_retcode = 1 THEN
     l_retcode := 1;
  END IF;
  IF l_final_valid_retcode = 2 THEN
     HXT_UTIL.DEBUG('l_final_valid_retcode is 2');-- debug only --HXT115
     FND_MESSAGE.SET_NAME('HXT','HXT_39362_BATCH_ERROR');       -- HXT11
     l_errbuf := FND_MESSAGE.GET;                               -- HXT11
     FND_MESSAGE.CLEAR;                                             -- HXT11
     l_retcode := 2;
  END IF;
  -- a system level error occured somewhere during processing
  IF (l_final_valid_retcode = 3 OR l_final_sum_retcode = 3) THEN
     FND_MESSAGE.SET_NAME('HXT','HXT_39363_SYSTEM_ERROR');          -- HXT11
     l_errbuf := FND_MESSAGE.GET;                                   -- HXT11
     FND_MESSAGE.CLEAR;                                             -- HXT11
     l_retcode := 2;
  END IF;
  retcode := l_retcode;
  errbuf  := l_errbuf;
  HXT_UTIL.DEBUG('Retcode:' || TO_CHAR(l_retcode) || ' ' || l_errbuf);-- debug only

  /********Bug: 4620315 **********/
  /*** To merge the batch TCs by calling 'merge_batches' procedure ***/

  IF p_merge_flag = '1' and p_process_mode = 'V' THEN
     IF g_debug THEN
        hr_utility.trace('Before calling merge_batches proc');
     END IF;
        merge_batches (p_merge_batch_name,
		       l_merge_batches,
		       l_del_empty_batches,
		       p_bus_group_id,
		       'NR'
		      );
  END IF;

  /********Bug: 4620315 **********/

  IF retcode = 2 THEN /* Bug: 6064910 */
   COMMIT;
  END IF;

  EXCEPTION
    WHEN g_lookup_not_found THEN --SIR517 PWM 18FEB00 TESTING
    HXT_UTIL.DEBUG('Oops...g_lookup_not_found in procedure sum_to_mix');
    l_errbuf := substr(FND_MESSAGE.GET,1,65);
    errbuf  := l_errbuf;
    HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( l_batch_id,
                 'VE', -- RETROPAY
                 '',
                 l_return);
     retcode := 2;
     Set_Batch_Status(l_date_earned, l_batch_id, 'VE');
     --commit;
     IF retcode = 2 THEN /* Bug: 6064910 */
      COMMIT;
     END IF;
     WHEN OTHERS THEN
        retcode := 2;
     FND_MESSAGE.SET_NAME('HXT','HXT_39363_SYSTEM_ERROR');
     l_errbuf := FND_MESSAGE.GET;
     FND_MESSAGE.CLEAR;
        errbuf  := l_errbuf;
         Set_Batch_Status(l_date_earned, l_batch_id, 'VE');
         Insert_Pay_Batch_Errors( l_batch_id,
                                 'VE',
                                 sqlerrm,
                                 l_return);
        --commit;
	IF retcode = 2 THEN /* Bug: 6064910 */
          COMMIT;
        END IF;
END main_process;
--------------------------------------------------------------------------------
FUNCTION convert_lookup (p_lookup_code IN VARCHAR2,
                         p_lookup_type IN VARCHAR2,
                         p_date_active IN DATE)
RETURN VARCHAR2 IS
  l_meaning HR_LOOKUPS.MEANING%TYPE;
  cursor get_meaning_cur(p_code VARCHAR2, p_type VARCHAR2, p_date DATE) is
    SELECT fcl.meaning
      FROM hr_lookups fcl
     WHERE fcl.lookup_code = p_code
       AND fcl.lookup_type = p_type
       AND fcl.enabled_flag = 'Y'
       AND p_date BETWEEN nvl(fcl.start_date_active, p_date)
                      AND nvl(fcl.end_date_active, p_date);
BEGIN

  if g_debug then
  	hr_utility.set_location('convert_lookup',10);
  end if;
  HXT_UTIL.DEBUG('convert_lookup - code = '||p_lookup_code||'
     type = '||p_lookup_type||' date = '||fnd_date.date_to_chardate(p_date_active));


  -- Bug 8888777
  -- Need to do a conversion only if IV expected is in Display format.
  -- Skip the conversion if IV_format is INTERNAL = Y
  IF p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL
     AND g_IV_format = 'N'
  THEN
    if g_debug then
    	  hr_utility.set_location('convert_lookup',20);
    end if;
    OPEN get_meaning_cur(p_lookup_code, p_lookup_type, p_date_active);
    FETCH get_meaning_cur into l_meaning;
    if g_debug then
    	  hr_utility.trace('l_meaning :'||l_meaning);
    end if;
    IF get_meaning_cur%NOTFOUND then
      if g_debug then
      	    hr_utility.set_location('convert_lookup',30);
      end if;
      FND_MESSAGE.SET_NAME('HXT','HXT_39483_LOOKUP_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE', p_lookup_code);
      FND_MESSAGE.SET_TOKEN('TYPE', p_lookup_type);
      RAISE g_lookup_not_found;
    END IF;
  ELSE
    if g_debug then
    	  hr_utility.set_location('convert_lookup',40);
    end if;
    l_meaning := p_lookup_code;
    if g_debug then
    	  hr_utility.trace('l_meaning :'||l_meaning);
    end if;
  END IF;
  if g_debug then
  	hr_utility.set_location('convert_lookup',50);
  end if;
  RETURN l_meaning;
END convert_lookup;
--
-- This function is crated to get the lookup_code for translated
-- input-value names
--
FUNCTION get_lookup_code (p_meaning IN VARCHAR2,
                         p_date_active IN DATE)
RETURN VARCHAR2 IS
  l_lookup_code HR_LOOKUPS.lookup_code%TYPE;
  cursor get_lookup_code_cur is
    SELECT lookup_code
      FROM fnd_lookup_values
     WHERE meaning = p_meaning
       AND lookup_type = 'NAME_TRANSLATIONS'
       AND enabled_flag = 'Y'
       AND p_date_active BETWEEN nvl(start_date_active, p_date_active)
                      AND nvl(end_date_active, p_date_active);
BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	hr_utility.set_location('get_lookup_code',10);
  end if;
  HXT_UTIL.DEBUG('get_lookup_ code  for meaning = '||p_meaning||'
   type = '||'NAME_TRANSLATIONS'||' date = '||fnd_date.date_to_chardate(p_date_active));
  if g_debug then
  	hr_utility.trace('p_meaning :'||p_meaning);
  end if;
  IF p_meaning IS NOT NULL  THEN
  if g_debug then
  	hr_utility.set_location('get_lookup_code',20);
  end if;
    OPEN get_lookup_code_cur;
    FETCH get_lookup_code_cur into l_lookup_code;
    if g_debug then
    	  hr_utility.trace('l_lookup_code :'||l_lookup_code);
    end if;
    IF get_lookup_code_cur%NOTFOUND then
        if g_debug then
              hr_utility.set_location('get_lookup_code',30);
              hr_utility.trace('get_lookup_code_cur NOT FOUND');
        end if;
  --    FND_MESSAGE.SET_NAME('HXT','HXT_39483_LOOKUP_NOT_FOUND');
  --    FND_MESSAGE.SET_TOKEN('CODE', p_meaning);           --SIR517 PWM 18FEB00
  --    FND_MESSAGE.SET_TOKEN('TYPE', 'NAME_TRANSLATIONS'); --SIR517 PWM 18FEB00
  --    RAISE g_lookup_not_found;
    null;  -- This is done to fix bug 1761779  -- 17/May/2001
    END IF;
  ELSE
    if g_debug then
    	  hr_utility.set_location('get_lookup_code',40);
    end if;
    l_lookup_code := p_meaning;
    if g_debug then
    	  hr_utility.trace('p_meaning is null');
          hr_utility.trace('l_lookup_code:'||l_lookup_code);
    end if;
  END IF;
  if g_debug then
  	hr_utility.trace('l_lookup_code :'||l_lookup_code);
  	hr_utility.set_location('get_lookup_code',50);
  end if;
  RETURN l_lookup_code;
END get_lookup_code;
-- Place OTM data into BEE values per input values
-- HXT_UTIL.DEBUG('Putting OTM data into BEE values per input values'); --HXT115
-- In order to get the input-value logic work in different legislations we need
-- to create (SEED) new lookups for 'Hours' , 'Hourly Rate', 'Rate Multiple',
-- and 'Rate Code' with lookup_type of 'NAME_TRANSLATION' and lookup_code
-- of 'HOURS', 'HOURLY_RATE', 'RATE_MULTIPLE' and 'RATE_CODE' respectively.
-- Then the customers in different countries need to create the above input
-- values with the name which is directly translated from the above names for
-- OTM elements.
-- For example: In French the user must create an input value for 'Hours'
-- to be 'Heures' and then to determine which input value 'Heures' is
-- associated with we look at the hr_lookups and if we find an entry with
-- lookup_type = 'NAME_TRANSLATIONS' and lookup_code = 'HOURS' and
-- Meaning to be 'Heures' then we know that this input value would map
-- to 'Hours'.
-- What need to be noted that it is the customer's responsibilty to create
-- input values which are the direct translation of 'Hours','Hourly Rate',
-- 'Pay Value' , 'Rate Multiple' and 'Rate Code'
--
PROCEDURE dtl_to_BEE(p_values_rec IN HXT_BATCH_VALUES_V%ROWTYPE,
                     p_sum_retcode IN OUT NOCOPY NUMBER,
                     p_batch_sequence IN NUMBER)
IS
--l_batch_sequence PAY_BATCH_LINES.BATCH_SEQUENCE%TYPE;
  l_batch_line_id PAY_BATCH_LINES.BATCH_LINE_ID%TYPE;
  l_value_meaning hr_lookups.meaning%TYPE;
  l_return NUMBER;
  l_line_ovn number;

  TYPE input_value_record IS RECORD
    (sequence PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE,
     name     PAY_INPUT_VALUES_F_TL.NAME%TYPE,  --FORMS60
     lookup   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE);

  TYPE input_values_table IS TABLE OF input_value_record
    INDEX BY BINARY_INTEGER;
  hxt_value input_values_table;

  TYPE pbl_values_table IS TABLE OF PAY_BATCH_LINES.VALUE_1%TYPE
    INDEX BY BINARY_INTEGER;
  pbl_value pbl_values_table;

  CURSOR c_date_input_value(cp_element_type_id NUMBER
                         ,cp_assignment_id   NUMBER
                         ,cp_effective_date  DATE) IS
   SELECT distinct PIV.name -- PIV.display_sequence
   FROM --pay_element_types_f PET
          pay_input_values_f  PIV
         ,pay_accrual_plans PAP
         ,pay_net_calculation_rules PNCR
   WHERE--PET.element_type_id      = cp_element_type_id
 --AND    PET.element_type_id      = PIV.element_type_id
          PIV.element_type_id      = cp_element_type_id
   AND    cp_effective_date between PIV.effective_start_date
                                and PIV.effective_end_date
   AND    PNCR.date_input_value_id = PIV.input_value_id
   AND    PNCR.input_value_id     <> PAP.pto_input_value_id
   AND    PNCR.input_value_id     <> PAP.co_input_value_id
   AND    PNCR.accrual_plan_id     = PAP.accrual_plan_id
   AND    PAP.accrual_plan_id IN
                (SELECT PAPL.accrual_plan_id
                 FROM   pay_accrual_plans PAPL
                       ,pay_element_links_f PEL
                       ,pay_element_entries_f PEE
                 WHERE  PEL.element_type_id  = PAPL.accrual_plan_element_type_id
                 AND    cp_effective_date between PEL.effective_start_date
                                              and PEL.effective_end_date
                 AND    PEE.element_link_id  = PEL.element_link_id
                 AND    PEE.assignment_id    = cp_assignment_id
                 AND    cp_effective_date between PEE.effective_start_date
                                              and PEE.effective_end_date
                 );


      -- Bug 8888777
      -- Added the following cursor, to pick up Input values from
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
              FROM hxt_sum_hours_worked_f
             WHERE id = p_id;



l_piv_name varchar2(30);
lv_pbl_flag varchar2(1) := 'N';


BEGIN

  if g_debug then
  	hr_utility.set_location('dtl_to_BEE',10);
  end if;
  -- Initialize table
  FOR i in 1..15 LOOP
    hxt_value(i).sequence := null;
    hxt_value(i).name := null;
    hxt_value(i).lookup := null;
  END LOOP;

     -- Bug 8888777
     -- Added the following call to pick up required input values
     -- from the summary table.
     IF NOT g_xiv_table.EXISTS(p_values_rec.parent_id)
     THEN
        OPEN get_input_values(p_values_rec.parent_id);
        FETCH get_input_values
          INTO g_xiv_table(p_values_rec.parent_id);
        CLOSE get_input_values;
     END IF;

  -- Get input values details for this element
HXT_UTIL.DEBUG('Getting input values for element '||to_char(p_values_rec.element_type_id)||' date '||fnd_date.date_to_chardate(p_values_rec.date_worked)); --FORMS60 --HXT115
  pay_paywsqee_pkg.GET_INPUT_VALUE_DETAILS(p_values_rec.element_type_id,
                                           p_values_rec.date_worked,
                                           hxt_value(1).sequence,
                                           hxt_value(2).sequence,
                                           hxt_value(3).sequence,
                                           hxt_value(4).sequence,
                                           hxt_value(5).sequence,
                                           hxt_value(6).sequence,
                                           hxt_value(7).sequence,
                                           hxt_value(8).sequence,
                                           hxt_value(9).sequence,
                                           hxt_value(10).sequence,
                                           hxt_value(11).sequence,
                                           hxt_value(12).sequence,
                                           hxt_value(13).sequence,
                                           hxt_value(14).sequence,
                                           hxt_value(15).sequence,
                                           hxt_value(1).name,
                                           hxt_value(2).name,
                                           hxt_value(3).name,
                                           hxt_value(4).name,
                                           hxt_value(5).name,
                                           hxt_value(6).name,
                                           hxt_value(7).name,
                                           hxt_value(8).name,
                                           hxt_value(9).name,
                                           hxt_value(10).name,
                                           hxt_value(11).name,
                                           hxt_value(12).name,
                                           hxt_value(13).name,
                                           hxt_value(14).name,
                                           hxt_value(15).name,
                                           hxt_value(1).lookup,
                                           hxt_value(2).lookup,
                                           hxt_value(3).lookup,
                                           hxt_value(4).lookup,
                                           hxt_value(5).lookup,
                                           hxt_value(6).lookup,
                                           hxt_value(7).lookup,
                                           hxt_value(8).lookup,
                                           hxt_value(9).lookup,
                                           hxt_value(10).lookup,
                                           hxt_value(11).lookup,
                                           hxt_value(12).lookup,
                                           hxt_value(13).lookup,
                                           hxt_value(14).lookup,
                                           hxt_value(15).lookup);
     if g_debug then
     	   hr_utility.set_location('dtl_to_BEE',20);
     end if;
  -- Place OTM data into BEE values per input values
  HXT_UTIL.DEBUG('Putting OTM data into BEE values per input values'); --HXT115
  --
  -- In order to get the input-value logic work in different legislations we
  -- need to create (SEED) new lookups for 'Hours', 'Hourly Rate',
  -- 'Rate Multiple', and 'Rate Code' with lookup_type of 'NAME_TRANSLATION'
  -- and lookup_code of 'HOURS', 'HOURLY_RATE', 'RATE_MULTIPLE' and
  -- 'RATE_CODE' respectively.  Then the customers in different countries
  -- need to create the above input values with the name which is directly
  -- translated from the above names for OTM elements.
  --
  -- For example: In French the user must create an input value for 'Hours'
  -- to be 'Heures' and then to determine which input value 'Heures' is
  -- associated with we look at the hr_lookups and if we find an entry with
  -- lookup_type = 'NAME_TRANSLATIONS' and lookup_code = 'HOURS' and Meaning
  -- to be 'Heures' then we know that this input vale woul map to 'Hours'.
  --
  -- What need to be noted that it is the customer's responsibilty to create
  -- input values which are the direct translation of 'Hours','Hourly Rate',
  -- 'Pay Value' , 'Rate Multiple' and 'Rate Code'
  --
  FOR i in 1..15 LOOP
  --
  -- We need to get the lookup_code for the input_value names before
  -- processing the further logic on the screen value for the input values.
  --
    lv_pbl_flag := 'N';
    if g_debug then
    	  hr_utility.set_location('dtl_to_BEE',30);
    	  hr_utility.trace('hxt_value_name_'||to_char(i)||' :'|| hxt_value(i).name);
          hr_utility.trace('p_values_rec.date_worked:'||p_values_rec.date_worked);
    end if;
    l_value_meaning := get_lookup_code (hxt_value(i).name,
                                        p_values_rec.date_worked);
    if g_debug then
    	  hr_utility.trace('l_value_meaning :'|| l_value_meaning);
    end if;
    if l_value_meaning = 'HOURS' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',40);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.hours,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif l_value_meaning = 'AMOUNT' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',50);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.amount,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif l_value_meaning  = 'RATE_MULTIPLE' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',60);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.rate_multiple,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif l_value_meaning = 'HOURLY_RATE' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',70);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.hourly_rate,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif l_value_meaning = 'RATE' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',80);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.hourly_rate,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif l_value_meaning = 'RATE_CODE' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',90);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.rate_code,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
-- BEGIN US localization
    elsif hxt_value(i).name = 'Jurisdiction' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',100);
      end if;
          if( p_values_rec.state_name is not null or
          p_values_rec.county_name is not null or
          p_values_rec.city_name is not null or
          p_values_rec.zip_code is not null)
         then
         pbl_value(i):= convert_lookup(  pay_ac_utility.get_geocode
                 (p_values_rec.state_name, p_values_rec.county_name, p_values_rec.city_name,
                 p_values_rec.zip_code),
                 hxt_value(i).lookup,
                 p_values_rec.date_worked);
         else
              pbl_value(i) := convert_lookup(p_values_rec.location_code,
                                             hxt_value(i).lookup,
                                             p_values_rec.date_worked);
         end if;

      if g_debug
      then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif hxt_value(i).name = 'Deduction Processing' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',110);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.fcl_tax_rule_code,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    elsif hxt_value(i).name = 'Separate Check' then
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',120);
      end if;
      pbl_value(i) := convert_lookup(p_values_rec.separate_check_flag,
                                     hxt_value(i).lookup,
                                     p_values_rec.date_worked);
      if g_debug then
      	    hr_utility.trace('pbl_value_'||to_char(i)||' :'|| pbl_value(i));
      end if;
    -- END US localization
    elsif hxt_value(i).name is not null THEN -- pbl_value(i) := NULL;
      if g_debug then
      	    hr_utility.set_location('dtl_to_BEE',130);
      end if;
      OPEN c_date_input_value(p_values_rec.element_type_id
                             ,p_values_rec.assignment_id
                             ,p_values_rec.date_worked);
      LOOP
          if g_debug then
          	hr_utility.set_location('dtl_to_BEE',140);
          end if;
          FETCH c_date_input_value into l_piv_name;
          EXIT WHEN c_date_input_value%NOTFOUND;
          if g_debug then
          	hr_utility.trace('l_piv_name  :'||l_piv_name);
          	hr_utility.trace('lv_pbl_flag :'||lv_pbl_flag);
          end if;
          IF l_piv_name = hxt_value(i).name THEN
             if g_debug then
             	   hr_utility.set_location('dtl_to_BEE',150);
             end if;
          -- pbl_value(i) := to_char(p_values_rec.date_worked,'DD-MON-YYYY');
             pbl_value(i) := fnd_date.date_to_canonical(p_values_rec.date_worked);
             lv_pbl_flag := 'Y';
             if g_debug then
             	   hr_utility.trace('pbl_value_'||to_char(i)||' :'||pbl_value(i));
             end if;
             exit;
          END IF;
      END LOOP;
      CLOSE c_date_input_value;


      -- Bug 9650990
      -- Do this processing only if pbl_value(i) is still not set for input values with non NULL name.
      if g_debug then
       	hr_utility.trace('Before : lv_pbl_flag :'||lv_pbl_flag);
      end if;

      IF lv_pbl_flag = 'N' THEN
	      -- Bug 8888777
	      -- Control is here means that no fixed input value is encountered, but
	      -- still some IV with a Non NULL name. Convert this and copy it.
	      IF i = 1 THEN pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute1,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  2
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute2,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  3
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute3,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  4
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute4,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  5
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute5,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  6
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute6,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  7
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute7,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  8
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute8,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i =  9
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute9,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i = 10
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute10,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i = 11
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute11,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i = 12
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute12,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i = 13
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute13,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i = 14
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute14,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      ELSIF i = 15
	      THEN
		    pbl_value(i) := convert_lookup(g_xiv_table(p_values_rec.parent_id).attribute15,
						   hxt_value (i).lookup,
						   p_values_rec.date_worked);
		     lv_pbl_flag := 'Y';
	      END IF;

      END IF;

      if lv_pbl_flag = 'N' then
         if g_debug then
         	hr_utility.set_location('dtl_to_BEE',160);
         end if;
         pbl_value(i) := NULL;
         if g_debug then
         	hr_utility.trace('pbl_value_'||to_char(i)||' :'||pbl_value(i));
         end if;
      end if;
         if g_debug then
         	hr_utility.trace('lv_pbl_flag :'||lv_pbl_flag);
         end if;
    else
         if g_debug then
         	hr_utility.set_location('dtl_to_BEE',180);
         end if;
         pbl_value(i) := NULL;
         if g_debug then
         	hr_utility.trace('pbl_value_'||to_char(i)||' :'||pbl_value(i));
         end if;
    end if;
    if g_debug then
    	  hr_utility.set_location('dtl_to_BEE',190);
    end if;
    HXT_UTIL.DEBUG('value_'||to_char(i)||' = '||pbl_value(i)); --HXT115
  END LOOP;
  -- Get Batch Line ID
    if g_debug then
    	  hr_utility.set_location('dtl_to_BEE',200);
    end if;
  -- Get next sequence number
  -- l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence(p_values_rec.batch_id);
  if g_debug then
  	hr_utility.set_location('dtl_to_BEE',210);
  end if;
  HXT_UTIL.DEBUG('batch_sequence = '||to_char(p_batch_sequence)); --HXT115
  -- Insert data into BEE table
  PAY_BATCH_ELEMENT_ENTRY_API.create_batch_line
  (p_session_date                  => sysdate
  ,p_batch_id                      => p_values_rec.batch_id
  ,p_batch_line_status             => 'U'
  ,p_assignment_id                 => p_values_rec.assignment_id
  ,p_assignment_number             => p_values_rec.assignment_number
  ,p_batch_sequence                => p_batch_sequence
  ,p_concatenated_segments         => p_values_rec.concatenated_segments
  ,p_cost_allocation_keyflex_id    => p_values_rec.cost_allocation_keyflex_id
  ,p_effective_date                => p_values_rec.date_worked
  ,p_effective_start_date          => p_values_rec.date_worked
  ,p_effective_end_date            => p_values_rec.date_worked
  ,p_element_name                  => p_values_rec.element_name
  ,p_element_type_id               => p_values_rec.element_type_id
  ,p_entry_type                    => 'E'
  ,p_date_earned                   => p_values_rec.date_worked
  ,p_reason                        => p_values_rec.reason
  ,p_segment1                      => p_values_rec.segment1
  ,p_segment2                      => p_values_rec.segment2
  ,p_segment3                      => p_values_rec.segment3
  ,p_segment4                      => p_values_rec.segment4
  ,p_segment5                      => p_values_rec.segment5
  ,p_segment6                      => p_values_rec.segment6
  ,p_segment7                      => p_values_rec.segment7
  ,p_segment8                      => p_values_rec.segment8
  ,p_segment9                      => p_values_rec.segment9
  ,p_segment10                     => p_values_rec.segment10
  ,p_segment11                     => p_values_rec.segment11
  ,p_segment12                     => p_values_rec.segment12
  ,p_segment13                     => p_values_rec.segment13
  ,p_segment14                     => p_values_rec.segment14
  ,p_segment15                     => p_values_rec.segment15
  ,p_segment16                     => p_values_rec.segment16
  ,p_segment17                     => p_values_rec.segment17
  ,p_segment18                     => p_values_rec.segment18
  ,p_segment19                     => p_values_rec.segment19
  ,p_segment20                     => p_values_rec.segment20
  ,p_segment21                     => p_values_rec.segment21
  ,p_segment22                     => p_values_rec.segment22
  ,p_segment23                     => p_values_rec.segment23
  ,p_segment24                     => p_values_rec.segment24
  ,p_segment25                     => p_values_rec.segment25
  ,p_segment26                     => p_values_rec.segment26
  ,p_segment27                     => p_values_rec.segment27
  ,p_segment28                     => p_values_rec.segment28
  ,p_segment29                     => p_values_rec.segment29
  ,p_segment30                     => p_values_rec.segment30
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
  ,p_object_version_number         => l_line_ovn
  ,p_iv_all_internal_format          => g_IV_format	    -- Bug 8888777
  );
HXT_UTIL.DEBUG('Successful INSERT INTO pay_batch_lines'); --HXT115
  -- Update OTM detail row to show BEE line entry id
  IF p_values_rec.hrw_rowid IS NOT NULL THEN
    UPDATE HXT_DET_HOURS_WORKED_F
      set PBL_LINE_ID = l_batch_line_id
    WHERE rowid = p_values_rec.hrw_rowid;
  END IF;
HXT_UTIL.DEBUG('Successful UPDATE hxt_det_hours_worked_f'); --HXT115
EXCEPTION
  WHEN g_lookup_not_found THEN
    HXT_UTIL.DEBUG('Oops...g_lookup_not_found'); --HXT115
    p_sum_retcode := 3;
    RAISE g_lookup_not_found; --SIR517 PWM 18FEB00 Re-raise the exception for the calling procedure
  WHEN others THEN
HXT_UTIL.DEBUG(sqlerrm); --HXT115
HXT_UTIL.DEBUG('Oops...others'); --HXT115
    FND_MESSAGE.SET_NAME('HXT','HXT_39354_ERR_INS_PAYMX_INFO');
    FND_MESSAGE.SET_TOKEN('SQLERR', sqlerrm);
    Insert_Pay_Batch_Errors( p_values_rec.batch_id, 'VE', '', l_return);
    p_sum_retcode := 3;
    RAISE g_error_ins_batch_lines; --SIR517 PWM 18FEB00 Re-raise the exception for the calling procedure
END dtl_to_BEE;


PROCEDURE sum_to_mix (p_batch_id IN NUMBER,
                      p_time_period_id IN NUMBER,
                      p_sum_retcode IN OUT NOCOPY NUMBER) IS
  PRAGMA AUTONOMOUS_TRANSACTION; --115.37
  CURSOR hxt_values_cur IS
  SELECT *
    FROM hxt_batch_values_v
   WHERE batch_id = p_batch_id ;
  CURSOR hxt_hours_cur IS
  SELECT *
    FROM hxt_batch_sum_hours_rollup_v
   WHERE batch_id = p_batch_id;
  CURSOR hxt_amounts_cur IS
  SELECT *
    FROM hxt_batch_sum_amounts_v
   WHERE batch_id = p_batch_id;
  l_values_rec hxt_values_cur%ROWTYPE;
  we_have_lines BOOLEAN;
  l_return NUMBER;
  l_batch_sequence PAY_BATCH_LINES.BATCH_SEQUENCE%TYPE;
BEGIN
  p_sum_retcode := 0;

  -- Bug 8888777
  -- Added the following call to pick up the upgrade status during the run.

  g_iv_upgrade := get_upgrade_status(p_batch_id);
  --
  -- If profile value set to 'Y', sum hours only to send to BEE
  --
  IF (nvl(fnd_profile.value('HXT_ROLLUP_BATCH_HOURS'),'N') = 'Y') THEN
    OPEN hxt_hours_cur;
    FETCH hxt_hours_cur into l_values_rec;
    IF hxt_hours_cur%FOUND THEN
      we_have_lines := TRUE;
    ELSE
      we_have_lines := FALSE;
    END IF;
  --
  -- Otherwise, do not sum hours, send hours and amounts to BEE
  --
  ELSE
    OPEN  hxt_values_cur;
    FETCH hxt_values_cur into l_values_rec;
    IF hxt_values_cur%FOUND THEN
      we_have_lines := TRUE;
    ELSE
      we_have_lines := FALSE;
    END IF;
  END IF;
  l_batch_sequence := pay_paywsqee_pkg.next_batch_sequence(l_values_rec.batch_id);
  WHILE we_have_lines AND p_sum_retcode = 0 LOOP
    dtl_to_BEE(l_values_rec, p_sum_retcode,l_batch_sequence);
    --
    -- If profile value set to 'Y', then we're sending sum of hours only
    --
    IF (nvl(fnd_profile.value('HXT_ROLLUP_BATCH_HOURS'),'N') = 'Y') THEN
      FETCH hxt_hours_cur into l_values_rec;
      IF hxt_hours_cur%FOUND THEN
        we_have_lines := TRUE;
        l_batch_sequence := l_batch_sequence + 1;
      ELSE
        we_have_lines := FALSE;
      END IF;
    --
    -- Otherwise, we're sending hours and amounts
    --
    ELSE
      FETCH hxt_values_cur into l_values_rec;
      IF hxt_values_cur%FOUND THEN
        we_have_lines := TRUE;
        l_batch_sequence := l_batch_sequence + 1;
      ELSE
        we_have_lines := FALSE;
      END IF;
    END IF;
  END LOOP;
  --
  -- Close appropriate cursor
  --
  IF (nvl(fnd_profile.value('HXT_ROLLUP_BATCH_HOURS'),'N') = 'Y') THEN
    CLOSE hxt_hours_cur;
  ELSE
    CLOSE hxt_values_cur;
  END IF;
  --
  -- If profile value is set to 'Y', now send amounts only to BEE
  --
  IF (nvl(fnd_profile.value('HXT_ROLLUP_BATCH_HOURS'),'N') = 'Y') THEN
    OPEN hxt_amounts_cur;
    FETCH hxt_amounts_cur into l_values_rec;
    IF hxt_amounts_cur%FOUND THEN
      we_have_lines := TRUE;
    ELSE
      we_have_lines := FALSE;
    END IF;
    l_batch_sequence := l_batch_sequence + 1;
    WHILE we_have_lines AND p_sum_retcode = 0 LOOP
      dtl_to_BEE(l_values_rec, p_sum_retcode,l_batch_sequence);
  --  dtl_to_BEE(l_values_rec, p_sum_retcode);
      FETCH hxt_amounts_cur into l_values_rec;
      IF hxt_amounts_cur%FOUND THEN
        we_have_lines := TRUE;
        l_batch_sequence := l_batch_sequence + 1;
      ELSE
        we_have_lines := FALSE;
      END IF;
    END LOOP;
    CLOSE hxt_amounts_cur;
  END IF;
  HXT_RETRO_VAL.Mark_Rows_Complete(p_batch_id);

-- Bug 9494444
-- New call for Retrieval Dashboard's detail section
-- Need to pick up line by line details of this batch and
-- update in the Retrieval Dashboard tables.
  snap_retrieval_details(p_batch_id);

  COMMIT; --115.37
HXT_UTIL.DEBUG('Successful COMMIT');
EXCEPTION
  WHEN g_lookup_not_found THEN --SIR517 PWM 18FEB00
    ROLLBACK; --115.37
    HXT_UTIL.DEBUG('Oops...g_lookup_not_found in procedure sum_to_mix');
    p_sum_retcode := 3;
	raise g_lookup_not_found ; --propogate to the calling procedure
  WHEN g_error_ins_batch_lines THEN --SIR517 PWM 18FEB00
    ROLLBACK; --115.37
    HXT_UTIL.DEBUG('Error attempting to insert paymix information');
    FND_MESSAGE.SET_NAME('HXT','HXT_39354_ERR_INS_PAYMX_INFO');
    FND_MESSAGE.SET_TOKEN('SQLERR',sqlerrm);
    Insert_Pay_Batch_Errors( p_batch_id, 'VE', '', l_return);
    HXT_UTIL.DEBUG(' back from calling insert_pay_batch_errors');
    p_sum_retcode := 3;
    raise g_error_ins_batch_lines ;
  WHEN others THEN
    ROLLBACK; --115.37
    HXT_UTIL.DEBUG(sqlerrm);
    HXT_UTIL.DEBUG('Oops...others');
    FND_MESSAGE.SET_NAME('HXT','HXT_39354_ERR_INS_PAYMX_INFO');
    FND_MESSAGE.SET_TOKEN('SQLERR', sqlerrm);
    Insert_Pay_Batch_Errors( p_batch_id, 'VE', '', l_return);
    p_sum_retcode := 3;
END sum_to_mix;
--------------------------------------------------------------------------------
PROCEDURE Transfer_To_Payroll( p_batch_id       IN NUMBER
                             , p_payroll_id     IN VARCHAR2
                             , p_batch_status   IN VARCHAR2
                             , p_ref_num        IN VARCHAR2
                             , p_process_mode   IN VARCHAR2
                             , p_pay_retcode    IN OUT NOCOPY NUMBER) IS
 CURSOR cur_sess_date IS
          SELECT fnd_date.date_to_chardate(end_date) end_date --SIR149 --FORMS60
          FROM per_time_periods
          WHERE time_period_id = g_time_period_id;
  l_req_id              NUMBER;
  l_errbuf              VARCHAR2(80);
  l_retcode             NUMBER;
  l_session_date        VARCHAR2(30);
  l_to_batch            NUMBER := p_batch_id;
  l_num                 NUMBER;
  l_process_mode        VARCHAR2(80);
  l_return              NUMBER;  -- SPR C352 by BC
  l_message             VARCHAR2(256);
  g_pipe_session        VARCHAR2(30);
  get_next_item         BOOLEAN default TRUE;
  kount                 NUMBER default 0;
BEGIN
-- Clear retcode
   p_pay_retcode := 0;
   l_process_mode := p_process_mode;
-- Get session date
  --begin SPR C166
  IF g_time_period_id IS NULL THEN
     l_session_date := fnd_date.date_to_chardate(SYSDATE); --SIR149 --FORMS60
  ELSE
     OPEN cur_sess_date;
     FETCH cur_sess_date INTO l_session_date;
     CLOSE cur_sess_date;
  END IF;
/*--DEBUG ONLY BEGIN

  select 'PIPE' || userenv('sessionid')
    into   g_pipe_session
    from   dual;
    if g_debug then
    	  hr_utility.set_location('PAY_US_PDT_PROCESS.TRANSFER_TO_PAYROLL', 1);
    end if;
--DEBUG ONLY END*/
     EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('HXT','HXT_39357_BATCH_ERR');
            FND_MESSAGE.SET_TOKEN('MESSAGE', l_errbuf);
            FND_MESSAGE.SET_TOKEN('SQLERR', sqlerrm);
            Insert_Pay_Batch_Errors(
                        p_batch_id,
                        'VE',
                        '',
                        l_return);
            p_pay_retcode := 3;
END transfer_to_payroll;
---------------------------------------------
FUNCTION Call_Gen_Error( p_batch_id 		IN NUMBER
                        ,p_location 		IN VARCHAR2
                        ,p_error_text 		IN VARCHAR2
                        ,p_oracle_error_text 	IN VARCHAR2 default NULL )
RETURN NUMBER IS
  --  calls error processing procedure  --
BEGIN
           HXT_UTIL.GEN_EXCEPTION
                        (p_location||'. Batch Id = '||to_char(p_batch_id)
                        ,p_error_text
                        ,p_oracle_error_text
                        ,null);
   RETURN 2;
END call_gen_error;
-- begin SPR C352 by BC-----------------------------
PROCEDURE Del_Prior_Errors( p_batch_id  NUMBER ) IS
  -- delete all prior batch level errors
  BEGIN
    NULL;
END del_prior_errors;
---------------------------------------------------------------------
PROCEDURE Set_batch_status(p_date_earned DATE,
			   p_batch_id  NUMBER,
			   p_status VARCHAR2 )IS
BEGIN
     IF (p_status = 'VT' AND p_date_earned IS NOT NULL) THEN
        UPDATE hxt_batch_states
        SET    date_earned = p_date_earned
        WHERE  batch_id = p_batch_id;
     END IF;
     UPDATE hxt_batch_states
     SET    status = p_status
     WHERE  batch_id = p_batch_id;
  --COMMIT;
END Set_batch_status;
------------------------------------------------------------------
FUNCTION Get_Transfer_Batch_Status(p_batch_id  NUMBER,
				   p_batch_status OUT NOCOPY VARCHAR2 )
RETURN NUMBER IS
  l_batch_status        VARCHAR2(10);
BEGIN
          SELECT status
          INTO l_batch_status
          FROM hxt_batch_states
          WHERE batch_id = p_batch_id;
  p_batch_status := l_batch_status;
  IF l_batch_status in ('E','VE') THEN
        return(2);
  ELSIF l_batch_status in ('VW','TW') THEN
        return(1);
  ELSE
        return(0);
  END IF;
  EXCEPTION
        WHEN OTHERS THEN
             RETURN(3);
END Get_Transfer_Batch_Status;
-----------------------------------------------------------
PROCEDURE rollback_PayMIX(p_batch_id IN NUMBER,
			  p_time_period_id IN NUMBER,
                          p_rollback_retcode OUT NOCOPY NUMBER) IS
  l_return            NUMBER DEFAULT 0;
  l_line_id           NUMBER DEFAULT NULL;
  l_sql_error         VARCHAR2(80) DEFAULT NULL;
  l_new_batch         NUMBER DEFAULT 0;
  l_payroll_id        NUMBER;
  l_business_group_id NUMBER;
  l_batch_name        VARCHAR2(30);
  l_batch_reference   VARCHAR2(30);
  l_tim_id            NUMBER;
  l_batch_created     boolean;
  -- Obtain start and end dates.
  -- If period not specified by user or period is unavailable,
  -- process all dates in the batch
  --
  -- Delete PayMIX cursor
  -- only batch lines for the time period selected by the user, all if
  -- none specified
  --
--HXT11 not needed. declared in FOR loop batch_line_rec batch_line_cur%ROWTYPE;
     CURSOR batch_line_cur IS
SELECT line.assignment_number, line.effective_date, line.batch_line_id,line.OBJECT_VERSION_NUMBER
  FROM pay_batch_lines line
 WHERE line.batch_id = p_batch_id;
 cursor c_get_batch_lines(p_batch_id number) is
select batch_line_id,object_version_number
 from pay_batch_lines
where batch_id = p_batch_id;
  cursor c_get_retro_batch_ids(p_batch_id number) is
  SELECT distinct(hrw.retro_batch_id) retro_batch_id,pbh.object_version_number
    FROM hxt_det_hours_worked_f hrw,
         hxt_timecards_f tim,
         pay_batch_headers pbh
   WHERE hrw.tim_id = tim.id
     AND tim.batch_id = pbh.batch_id
     AND tim.batch_id = p_batch_id
     AND hrw.retro_batch_id IS NOT NULL;
     CURSOR c_get_batch_ovn(p_batch_id number) is
select object_version_number
from pay_batch_headers
where batch_id = p_batch_id;
l_batch_ovn pay_batch_headers.object_version_number%type;
l_batch_line_id pay_batch_lines.batch_line_id%type;
l_line_ovn pay_batch_headers.object_version_number%type;
BEGIN
  -- if no time period is specified, delete all PayMIX entries
  IF p_time_period_id IS NULL THEN
        -- Delete PayMIX
        --
for l_rec in c_get_batch_lines(p_batch_id) loop
	PAY_BATCH_ELEMENT_ENTRY_API.delete_batch_line
	  (p_batch_line_id            => l_rec.batch_line_id
	  ,p_object_version_number    => l_rec.object_version_number
	  );
end loop;
        -- Update Batch status
        --
--BEGIN GLOBAL - we no longer need to manipulate PayMIX/BEE batch status;
--               but we still need to manipulate HXT_BATCH_STATES
        UPDATE hxt_batch_states
           SET status = 'H'
         WHERE batch_id = p_batch_id;
-- step 1 - delete retro_batch lines for any timecards in this (regular) batch.
--Then we loop through the cursor and delete the batch lines and batches as follows.
for l_rec in c_get_retro_batch_ids(p_batch_id) loop
   -- delete the batch lines
    for l_line_rec in c_get_batch_lines(l_rec.retro_batch_id) loop
			PAY_BATCH_ELEMENT_ENTRY_API.delete_batch_line
			  (p_batch_line_id            => l_line_rec.batch_line_id
			  ,p_object_version_number    => l_line_rec.object_version_number
			  );
	end loop;
    -- delete the batch
	PAY_BATCH_ELEMENT_ENTRY_API.delete_batch_header
	  (p_batch_id               => l_rec.retro_batch_id
	  ,p_object_version_number  => l_rec.object_version_number
	  );
end loop;
-- step 2 - delete retro_batch for any timecards in this (regular) batch.
--          we can delete it because retro processing does not re-use
--          batches.
-- step 3 - set pay_status, retro_batch_id for any timecards in this
--          (regular) batch.
--          this will set the whole timecard back to 'P', effectively
--          removing the retro nature of the timecard.  when the timecard
--          is resent to PayMIX, the detail rows with the most recent
--          effective dates will be sent.  This is what we want, because
--          those rows will include any adjustments made by time entry
--          personnel.
--SIR424 PWM 17JAN00 Clear the pbl_line_id during the rollback
        UPDATE hxt_det_hours_worked_f
           SET retro_batch_id = NULL,
               pay_status     = 'P',
			   pbl_line_id = NULL
         WHERE rowid in (
           SELECT hrw.rowid
             FROM hxt_det_hours_worked_f hrw,
                  hxt_timecards_f tim
            WHERE hrw.tim_id = tim.id
              AND tim.batch_id=p_batch_id);
-- step 4 - SET the date_earned (Process Date) back to NULL on the hxt_batch_states table
         UPDATE hxt_batch_states
            SET date_earned = NULL
          WHERE batch_id = p_batch_id;
        --COMMIT;
        p_rollback_retcode := 0;
  ELSE
        -- When time period is specified, a split batch could occurr.
        -- Create a new batch header id for timecards being rolled back
        -- This will allow the user to send any timecards remaining
        -- in PayMIX on to Payroll. Rollback timecards will always get
        -- a new batch id so they can be processed separately.
        l_new_batch := hxt_time_gen.Get_Next_Batch_Id;
        -- Update the corresponding timecards with the new batch number
        -- Delete batch lines for the time period selected by the user
        -- Delete any existing batch line errors
--HXT11FOR batch_line_rec IN batch_line_cur(l_period_start_date, l_period_end_date) LOOP
        FOR batch_line_rec IN batch_line_cur LOOP --HXT11
        -- HXT_UTIL.DEBUG(batch_line_rec.assignment_number);--debug only HXT115
        -- HXT_UTIL.DEBUG(TO_CHAR(batch_line_rec.from_date));--debug only HXT115
        -- HXT_UTIL.DEBUG(TO_CHAR(batch_line_rec.to_date));--debug only HXT115
        -- Locate the Timecard associated with this particular batch line.
        -- we will create a new batch, the first time we enter this loop
		if not l_batch_created then
			SELECT business_group_id, batch_name, batch_reference
			  INTO l_business_group_id, l_batch_name, l_batch_reference
			  FROM pay_batch_headers
			 WHERE batch_id = p_batch_id;
			PAY_BATCH_ELEMENT_ENTRY_API.create_batch_header
			  (p_session_date                  => sysdate
			  ,p_batch_name                    => l_batch_name
			  ,p_batch_status                  => 'U'
			  ,p_business_group_id             => l_business_group_id
			  ,p_action_if_exists              => 'R'
			  ,p_batch_reference               => l_batch_reference
			  ,p_batch_source                  => 'OTM'
			  ,p_purge_after_transfer          => 'N'
			  ,p_reject_if_future_changes      => 'N'
			  ,p_batch_id                      => l_new_batch
			  ,p_object_version_number         => l_batch_ovn
			  );
			l_batch_created := true;
        end if;
        --we lock the row corresponding to the batch line id and ovn
        pay_btl_shd.lck(p_batch_line_id         => batch_line_rec.batch_line_id
                       ,p_object_version_number => batch_line_rec.object_version_number
                       );
                SELECT DISTINCT(hrw.tim_id)
                INTO l_tim_id
                FROM hxt_det_hours_worked hrw, per_assignments_f asm --C421
                WHERE asm.assignment_number = batch_line_rec.assignment_number
                AND hrw.assignment_id = asm.assignment_id;
                /* AND hrw.parent_id > 0; HXT111*/
        -- Set a new batch number for timecards with elements being
        -- deleted from PayMIX
                UPDATE hxt_timecards tim
                SET tim.batch_id = l_new_batch
                 WHERE tim.batch_id = p_batch_id
                   AND tim.id = l_tim_id;
-- Delete actual PayMIX batch lines
       PAY_BATCH_ELEMENT_ENTRY_API.delete_batch_line
		  (p_batch_line_id            => batch_line_rec.batch_line_id
		  ,p_object_version_number    => batch_line_rec.object_version_number
		  );
END LOOP;
	-- Add the new batch header line for all rollback timecards
	OPEN c_get_batch_lines (p_batch_id);
FETCH c_get_batch_lines INTO l_batch_line_id, l_line_ovn;
IF c_get_batch_lines%NOTFOUND
THEN
    -- no batch lines found. So we can delete this batch
   OPEN c_get_batch_ovn (p_batch_id);
   FETCH c_get_batch_ovn INTO l_batch_ovn;
   CLOSE c_get_batch_ovn;
   pay_batch_element_entry_api.delete_batch_header (
      p_batch_id                   => p_batch_id,
      p_object_version_number      => l_batch_ovn
   );
END IF;
CLOSE c_get_batch_lines;
  END IF; -- timeperiod NULL
  --COMMIT;
  p_rollback_retcode := 0;
EXCEPTION
   WHEN OTHERS THEN
        HXT_UTIL.DEBUG('Error: ' || sqlerrm); --HXT115
        l_sql_error := sqlerrm;
        ROLLBACK;
        Insert_Pay_Batch_Errors( p_batch_id,
                                 'VE',
                                 l_sql_error,
                                 l_return);
        p_rollback_retcode := 3;
END rollback_PayMIX;
-------------------------------------------------------------------
PROCEDURE Insert_Pay_Batch_Errors( p_batch_id IN NUMBER,
                                   p_error_level IN VARCHAR2,
                                   p_exception_details IN VARCHAR2,
                                   p_return_code OUT NOCOPY NUMBER)IS
 l_error_msg     VARCHAR2(240);
BEGIN
  IF p_exception_details IS NULL THEN
     l_error_msg := FND_MESSAGE.GET;
     FND_MESSAGE.CLEAR;
  ELSE
     l_ERROR_MSG := p_exception_details;
  END IF;
     HXT_UTIL.GEN_EXCEPTION
                 ('Batch processing. Batch Id = '||to_char(p_batch_id)
                  ,l_error_msg
                  ,null
                  ,null);
  --COMMIT;
  p_return_code := 0;
  EXCEPTION
    WHEN OTHERS THEN
       p_return_code := 1;
END Insert_Pay_Batch_Errors;
------------------------------------------------------------------
-- end SPR C163, C166 by BC
------------------------------------------------------------------
PROCEDURE CALL_GEN_ERROR2 ( p_batch_id  IN NUMBER
                          , p_tim_id  IN NUMBER
                          , p_hrw_id  IN NUMBER
                          , p_time_period_id   IN NUMBER
                          , p_error_msg IN VARCHAR2
                          , p_loc IN VARCHAR2
                          , p_sql_err IN VARCHAR2
                          , p_TYPE IN VARCHAR2) IS                   --HXT11i1
 CURSOR  tim_dates is
 SELECT  effective_start_date,
         effective_end_date
 FROM    HXT_TIMECARDS_X
 WHERE   id = p_tim_id;
 l_eff_start  DATE;
 l_eff_end  DATE;
BEGIN
   OPEN tim_dates;
   FETCH tim_dates into l_eff_start, l_eff_end;
   if tim_dates%FOUND then
      HXT_UTIL.GEN_ERROR(p_batch_id
                        , p_tim_id
                        , p_hrw_id
                        , p_time_period_id
                        , p_error_msg
                        , p_loc
                        , p_sql_err
                        , l_eff_start
                        , l_eff_end
                        , p_type);                                --HXT11i1
   END IF;
   CLOSE tim_dates;
  END call_gen_error2;

-- Bug 8888777
-- Below function added to pick up the upgrade status.

FUNCTION get_upgrade_status(p_batch_id     IN  NUMBER)
RETURN VARCHAR2
IS

     CURSOR get_bg_id
         IS SELECT business_group_id
              FROM pay_batch_headers
             WHERE batch_id = p_batch_id;

     l_bg_id    NUMBER;

BEGIN
     OPEN get_bg_id;
     FETCH get_bg_id INTO l_bg_id;
     CLOSE get_bg_id;
     pay_core_utils.get_upgrade_status(l_bg_id,'BEE_IV_UPG',g_IV_UPGRADE);

     IF g_iv_upgrade = 'Y'
     THEN
        g_IV_format := 'Y';
     ELSE
        g_IV_format := 'N';
     END IF;
     RETURN g_iv_upgrade;

END get_upgrade_status;

-- Bug 9494444
-- Added this new procedure to snap the details of this
-- batch upto lines in pay_batch_lines to the tables for
-- recording this for Dashboard.

PROCEDURE snap_retrieval_details(p_batch_id  IN NUMBER)
IS


     -- Datatypes
     TYPE VARCHARTAB IS TABLE OF VARCHAR2(100);
     TYPE NUMBERTAB  IS TABLE OF NUMBER;
     TYPE DATETAB    IS TABLE OF DATE;

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

     -- To pick up each timecard in the batch.
     CURSOR get_timecards(p_batch_id   IN NUMBER)
         IS SELECT id
              FROM hxt_timecards_f
             WHERE batch_id = p_batch_id;


     -- To pick up the individual details

     CURSOR get_ret_details(p_tim_id   IN NUMBER,
                            p_batch_id IN NUMBER)
         IS
             SELECT /*+ INDEX(det HXT_DET_HOURS_WORKED_F_SUM_FK) */
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
	            det.pbl_line_id,
	            ret.retro_pbl_id,
	            ret.old_pbl_id,
	            FND_GLOBAL.conc_request_id,
	            ret.old_request_id,
	            p_batch_id,
	            ret.retro_batch_id,
	            ret.old_batch_id,
	            ROWIDTOCHAR(ret.rowid)
	       FROM hxt_sum_hours_worked_f sum,
	            hxt_det_hours_worked_f det,
	            hxc_ret_pay_latest_details ret
	      WHERE sum.tim_id = p_tim_id
	        AND sum.id = det.parent_id
	        AND ret.time_building_block_id = sum.time_building_block_id
	        AND ret.object_version_number = sum.time_building_block_ovn;


      l_tim_id   NUMBER;

BEGIN

    OPEN get_timecards(p_batch_id);
    LOOP
       -- Pick up the timecards.
       FETCH get_timecards INTO l_tim_id;
       EXIT WHEN get_timecards%NOTFOUND;

       -- For each timecard, pick up the details.
       -- The cursor is built in such a way that if there are multiple
       -- details per tbb id- OVN combination in hxt_det_hours_worked_f
       -- they get picked up multiple times.
       -- Eg. hxc_ret_pay_latest_details shows 12 hrs Reg
       --     In OTLR this is 8 hrs Reg and 4 hrs Overtime.
       --     So we pick up the 12 hrs Reg, delete the record
       --       and insert 8 hrs Reg and 4 hrs Overtime.
       OPEN get_ret_details(l_tim_id,p_batch_id);
       FETCH get_ret_details BULK COLLECT INTO
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

           COMMIT;

        CLOSE get_ret_details;

      END LOOP;
      CLOSE get_timecards;

END snap_retrieval_details;

--begin

END HXT_batch_process;

/
