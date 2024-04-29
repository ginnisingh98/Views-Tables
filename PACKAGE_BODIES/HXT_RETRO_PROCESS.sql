--------------------------------------------------------
--  DDL for Package Body HXT_RETRO_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_RETRO_PROCESS" AS
/* $Header: hxtrprc.pkb 120.1.12000000.3 2007/06/11 14:57:34 nissharm noship $ */
  g_debug boolean := hr_utility.debug_enabled;
  FUNCTION Call_Gen_Error( p_batch_id IN NUMBER
			 , p_location IN VARCHAR2
                         , p_error_text IN VARCHAR2
                         , p_oracle_error_text IN VARCHAR2 default NULL ) RETURN NUMBER;


-----------------------------------------------------------------
PROCEDURE Main_Retro (
  errbuf   	 OUT NOCOPY VARCHAR2,
  retcode  	 OUT NOCOPY NUMBER,
  p_payroll_id		IN	NUMBER,
  p_date_earned         IN      VARCHAR2,
  p_retro_batch_id      IN      NUMBER DEFAULT NULL,
  p_retro_batch_id_end  IN      NUMBER DEFAULT NULL,
  p_ref_num             IN      VARCHAR2 DEFAULT NULL,
  p_process_mode        IN      VARCHAR2,
  p_bus_group_id        IN      NUMBER,
  p_merge_flag		IN	VARCHAR2 DEFAULT '0',
  p_merge_batch_name	IN	VARCHAR2 DEFAULT NULL,
  p_merge_batch_specified IN	VARCHAR2 DEFAULT NULL
  ) IS
  -- Cursor returns all batch's with timecards for specified payroll,
  -- time period, batch id, and batch ref that haven't been transferred.
  CURSOR cur_batch(c_payroll_id NUMBER,
                   c_retro_batch_id NUMBER,
                   c_reference_num VARCHAR2) IS
   	   SELECT distinct(det.retro_batch_id) batch_id,
                  tim.id tim_id,
                  tbs.status batch_status,
		  pbh.object_version_number
   	     FROM pay_batch_headers    pbh,
                  hxt_batch_states     tbs,
                  hxt_timecards_x      tim,
                  hxt_det_hours_worked_x det
            WHERE det.pay_status = 'R'
              AND tbs.batch_id = det.retro_batch_id
              AND det.retro_batch_id BETWEEN nvl(c_retro_batch_id,0)
                    AND nvl(c_retro_batch_id,999999999999)
              AND (pbh.batch_reference LIKE nvl(c_reference_num , '%')
                  OR (pbh.batch_reference IS NULL AND c_reference_num IS NULL))
              AND tbs.status in ('VE','H','VT','VV','VW') -- RETROPAY
              AND tim.id = det.tim_id
              AND pbh.batch_id = tbs.batch_id
              AND pbh.business_group_id = p_bus_group_id;

  batch_rec cur_batch%ROWTYPE;
--
-- v115.11 start
-- Adding cursor to retrieve all valid batch ranges.
  cursor c_batch_ranges is
  SELECT   pbh.batch_name, pbh.batch_id
      FROM pay_batch_headers pbh
     WHERE pbh.business_group_id = p_bus_group_id
       AND EXISTS (SELECT 'x'
                     FROM hxt_det_hours_worked_x det, hxt_batch_states hbs
                    WHERE hbs.batch_id = pbh.batch_id
                      AND det.retro_batch_id = hbs.batch_id
                      AND hbs.status in ('VE','H','VT','VV','VW'))
  ORDER BY pbh.batch_id;
-- v115.11 end
-- local variables
--
  l_batch_id		NUMBER;
  l_process_mode	VARCHAR2(80);
  l_session_date	DATE;
  l_batch_status	VARCHAR2(30);
  l_pay_retcode		NUMBER      DEFAULT 0;
  l_valid_retcode	NUMBER      DEFAULT 0;
  l_sum_retcode		NUMBER      DEFAULT 0;
  l_main_retcode	NUMBER	    DEFAULT 0;
  l_final_pay_retcode	NUMBER      DEFAULT 0;
  l_final_valid_retcode	NUMBER      DEFAULT 0;
  l_final_main_retcode	NUMBER      DEFAULT 0;
  l_final_sum_retcode	NUMBER      DEFAULT 0;
  l_rollback_retcode    NUMBER      DEFAULT 0;
  l_final_rollback_retcode NUMBER   DEFAULT 0;
  l_errbuf		VARCHAR2(80)DEFAULT NULL;
  v_err_buf		VARCHAR2(65)DEFAULT NULL;
  l_retcode		NUMBER      DEFAULT 0;
  l_date_earned DATE := to_date(p_date_earned,'YYYY/MM/DD HH24:MI:SS');
  l_kounter             NUMBER      DEFAULT 0;
  l_payroll_id		VARCHAR2(30)DEFAULT NULL;
  l_retro_batch_id      NUMBER;   --BSE115M
  l_return		NUMBER;
  l_trans_batch_status  NUMBER      DEFAULT 0;
  l_trans_status_code   VARCHAR2(10)DEFAULT NULL;
  l_period_end_date     DATE;
  b_we_have_batches     BOOLEAN     DEFAULT TRUE;
  -- v115.11 start
  -- adding new variables
      l_starting_batch_num  NUMBER;
      l_ending_batch_num    NUMBER;

      TYPE v_bat_rec IS RECORD (
            batch_id             NUMBER (15));

      TYPE r_bat_rec IS TABLE OF v_bat_rec
       INDEX BY BINARY_INTEGER;

      list_batch_rec_ids       r_bat_rec;
      l_index                  BINARY_INTEGER;

      b_start       BOOLEAN;
      b_stop        BOOLEAN;

  -- v115.11 end

 /********Bug: 4620315 **********/

  l_cnt 		BINARY_INTEGER;
  l_count		BINARY_INTEGER;
  l_loop_index		BINARY_INTEGER;
  l_loop_flag		BOOLEAN;
  l_merge_batches	HXT_BATCH_PROCESS.MERGE_BATCHES_TYPE_TABLE;
  p_merge_batches	HXT_BATCH_PROCESS.MERGE_BATCHES_TYPE_TABLE;
  l_del_empty_batches	HXT_BATCH_PROCESS.DEL_EMPTY_BATCHES_TYPE_TABLE;

  /********Bug: 4620315 **********/

BEGIN
   g_debug := hr_utility.debug_enabled;
-- commented out. using sysdate view, now. RTF
--  insert into fnd_sessions values (userenv('SESSIONID'), trunc(SYSDATE));
--  commit;
  --HXT_UTIL.DEBUG('Start process.');-- debug only --HXT115
  -- time period will be ignored completely when passed in as NULL
  l_date_earned := to_date(to_char(trunc(l_date_earned),'DD/MM/RRRR'),'DD/MM/RRRR');
  l_payroll_id     := to_char(p_payroll_id);
  l_retro_batch_id := p_retro_batch_id;   --BSE115M
  --
  --Validate , Transfer, or Rollback TAMS/O data
  --
  --
    -- v115.11 start
    -- check for ranges
      l_starting_batch_num := p_retro_batch_id;
      l_ending_batch_num   := p_retro_batch_id_end;
  --
  -- Table population
  l_index := 1;
    IF l_ending_batch_num IS NULL THEN
      IF l_starting_batch_num IS NOT NULL THEN
         list_batch_rec_ids(l_index).batch_id := l_starting_batch_num;
      ELSE
         list_batch_rec_ids(l_index).batch_id := null;
      END IF;
    ELSE
      IF l_starting_batch_num IS NULL THEN
         list_batch_rec_ids(l_index).batch_id := l_ending_batch_num;
      END IF;
    END IF;
    --
    -- Initialize booleans
    b_start := FALSE;
    b_stop  := FALSE;

    IF l_starting_batch_num > l_ending_batch_num THEN
  	  b_stop  := TRUE;
    END IF;

    --
    -- Determine if a range has been selected by the user
    --
    IF l_starting_batch_num IS NOT NULL AND l_ending_batch_num IS NOT NULL AND b_stop = FALSE
     THEN

    For C_All_batches in c_batch_ranges
    Loop
    	if (C_All_batches.batch_id = l_starting_batch_num)
    	 then
    	 	b_start := TRUE;
    	 end if;

    	-- Add to table
    	if b_start = TRUE then
    	    list_batch_rec_ids(l_index).batch_id := C_All_batches.batch_id;
    	    l_index := l_index+1;
    	end if;

          if (C_All_batches.batch_id = l_ending_batch_num)
   	  	 then
   	  	 	b_start := FALSE;
     	 end if;
     End Loop; -- C_All_batches
  End If; -- l_starting_batch_num and l_ending_batch_num IS NOT NULL

    --
    -- v115.11 end
  --
  --
  -- Loop through all retro batches in payroll specified by user
  --
  -- v115.11
  -- Change looping to use the newly populated PL/SQL table list_batch_rec_ids

  l_index := null;
  l_index := list_batch_rec_ids.first;

  WHILE l_index is not null LooP
      BEGIN
    --HXT_UTIL.DEBUG('Beginning we have batches loop');
    --
    -- Select and process all user specified batches for this payroll/reference number
    -- Process batch range specified by the user, else do all available
    --
    l_loop_flag := TRUE;

HXT_UTIL.DEBUG('payroll_id = '||to_char(p_payroll_id)||' retro_batch_id = '
           ||to_char(list_batch_rec_ids(l_index).batch_id)||' ref_num = '||p_ref_num);
    FOR batch_rec IN cur_batch(p_payroll_id, list_batch_rec_ids(l_index).batch_id, p_ref_num ) LOOP
      --HXT_UTIL.DEBUG('Batch number is ' || TO_CHAR(batch_rec.batch_id));
      l_batch_id := batch_rec.batch_id;
      l_kounter := l_kounter + 1;
      --
      -- rollback all PayMix data per user request
      --
      IF p_process_mode = 'V' THEN

	/********Bug: 4620315 **********/
        /*** To record empty batch details ***/

        IF (p_merge_flag = '1' and l_loop_flag = TRUE) THEN

	   IF g_debug THEN
	      hr_utility.trace('Populating del_empty_batches record: '||'batchid: '||batch_rec.batch_id||
	                       ' ovn '||batch_rec.object_version_number);
	   END IF;

	   l_cnt := NVL(l_del_empty_batches.LAST,0) +1;
	   l_del_empty_batches(l_cnt).batch_id := batch_rec.batch_id;
	   l_del_empty_batches(l_cnt).batch_ovn := batch_rec.object_version_number;
	   l_loop_flag := FALSE;
	END IF;

	/********Bug: 4620315 **********/

        -- Check for a valid status code
        IF (batch_rec.batch_status = 'VT') THEN
          l_final_valid_retcode := 2;
          FND_MESSAGE.SET_NAME('HXT','HXT_39348_TC_VAL_NOT_REPROC');  --HXT111
          HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
				'VE',
                                '',
				l_return);
        ELSE
          --
          -- Validate batch, status:0=Normal, 1=Warning, 2=Stop Level Data Error, 3=System
          --
          --HXT_UTIL.DEBUG('Begin timecard validation.');
          -- Delete prior errors for this batch
          HXT_BATCH_PROCESS.Del_Prior_Errors(batch_rec.batch_id);
          HXT_RETRO_VAL.Val_Retro_Timecard(batch_rec.batch_id,
                                          batch_rec.tim_id,
                                          l_valid_retcode,
					  p_merge_flag,
		  		          p_merge_batches);

	  /********Bug: 4620315 **********/
	  /*** To record validated TCs details ***/

	  IF p_merge_flag = '1' THEN
	     l_loop_index := p_merge_batches.first;
	     LOOP
		EXIT WHEN NOT p_merge_batches.exists(l_loop_index);
		l_count := NVL(l_merge_batches.LAST,0) +1;
                l_merge_batches(l_count).batch_id	       := p_merge_batches(l_loop_index).batch_id;
		l_merge_batches(l_count).tc_id		       := p_merge_batches(l_loop_index).tc_id;
		l_merge_batches(l_count).valid_tc_retcode      := p_merge_batches(l_loop_index).valid_tc_retcode;
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
            --HXT_UTIL.DEBUG('Successful timecard validation.');
            HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, batch_rec.batch_id, 'VV');
          END IF;
          -- set status to Warning and lets user know we have a TAMS/O
          -- User Level Data Error for this batch
          IF l_valid_retcode = 1 then
            --HXT_UTIL.DEBUG('Timecard validation warnings.');
            HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, batch_rec.batch_id, 'VW');
            FND_MESSAGE.SET_NAME('HXT','HXT_39349_CHK_IND_TCARD_ERRS'); --HXT111
            HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
	        	          'W',
                                  '',
  		                  l_return);
          END IF;
          IF l_valid_retcode > 2 THEN
            --HXT_UTIL.DEBUG('Timecard validation errors.');
	    HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, batch_rec.batch_id, 'VE');
            FND_MESSAGE.SET_NAME('HXT','HXT_39349_CHK_IND_TCARD_ERRS');
            HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
		                 'VE',
                                 '',
			         l_return);
          END IF;
        END IF; -- valid status code
      --
      -- Process transfer to PayMIX
      --
      ELSIF p_process_mode = 'T' THEN
        -- Don't allow batches in a Hold status to be Transferred to PayMIX
        IF batch_rec.batch_status = 'H' THEN
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39350_CANT_TRANS_HLD_PAYMX');
           HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
    		                   'VE',
                                   '',
	  			   l_return);
          -- Don't move to PayMIX while Timecard errors exist
        ELSIF batch_rec.batch_status in ('VE','ET') THEN -- RETROPAY
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39351_CANT_TRANS_ERR_PAYMX');
           HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
    		                    'VE',
                                    '',
		 		    l_return);
        ELSIF (batch_rec.batch_status = 'VT') THEN
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39352_BTCHS_PREV_TRANS');
           HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
    		                   'VE',
                                   '',
		 		   l_return);
        ELSIF batch_rec.batch_status in ('VV','VW') THEN -- RETROPAY
           HXT_UTIL.DEBUG('Now moving to PayMIX.');
           HXT_RETRO_MIX.retro_sum_to_mix(batch_rec.batch_id,
                                         batch_rec.tim_id, l_sum_retcode,
                                         v_err_buf);
           HXT_UTIL.DEBUG('back from moving to PayMIX. v_er_buf is '||v_err_buf);
           HXT_UTIL.DEBUG('back from moving to PayMIX. l_sum_retcode is '||to_char(l_sum_retcode));
           IF l_sum_retcode > l_final_sum_retcode then
              l_final_sum_retcode := l_sum_retcode;
           END IF;
           IF (l_sum_retcode = 0) then
              --HXT_UTIL.DEBUG('Successful move to PayMIX.');
              HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, batch_rec.batch_id, 'VT');
           ELSE
              retcode := 2;
             FND_MESSAGE.SET_NAME('HXT','HXT_39452_RETRO_SYSTEM_ERROR');
             IF v_err_buf IS NULL THEN
               FND_MESSAGE.SET_TOKEN('ERR_BUF',sqlerrm);
             ELSE
               FND_MESSAGE.SET_TOKEN('ERR_BUF',v_err_buf);
             END IF;
             l_errbuf := FND_MESSAGE.GET;
             FND_MESSAGE.CLEAR;
              errbuf  := l_errbuf;
              HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, l_batch_id, 'VE');
              HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( l_batch_id,
	                        'VE',
                                sqlerrm,
				l_return);
              commit;
              return;

           END IF;
           IF (l_sum_retcode = 3) then
	      HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, batch_rec.batch_id, 'VE');
           END IF;
        ELSE
           l_final_valid_retcode := 2;
           FND_MESSAGE.SET_NAME('HXT','HXT_39353_BTCHS_MST_BE_VALDTED');
           HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( batch_rec.batch_id,
    		                   'VE', -- RETROPAY
                                   '',
		 		   l_return);
        END IF; -- check status before processing
      END IF; -- end process selections
      l_valid_retcode := 0;
      l_sum_retcode := 0;
    END LOOP; -- for loop process specific batch
    --
    -- Select the next batch in the range if applicable, else exit loop
    --
    l_index := list_batch_rec_ids.NEXT(l_index);
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_index := null;

       WHEN OTHERS THEN
          HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, batch_rec.batch_id, 'VE');
    HXT_UTIL.DEBUG('Other exception.'||sqlerrm);
          	l_index := null;
    END; -- batches
  END LOOP;   -- while more batches exist in the range l_index not equal to null
  -- Check for error totals to return a status from concurrent manager.
  -- Normal
  FND_MESSAGE.SET_NAME('HXT','HXT_39358_COMP_NORMAL');
  l_errbuf := FND_MESSAGE.GET;
  FND_MESSAGE.CLEAR;
--HXT111  l_errbuf := 'Completed Normal.';
  l_retcode := 0;
  -- No batches selected at all
  IF l_kounter = 0 THEN
     FND_MESSAGE.SET_NAME('HXT','HXT_39359_NO_BATCHES_SEL');
     l_errbuf := FND_MESSAGE.GET;
     FND_MESSAGE.CLEAR;
--HXT111     l_errbuf := 'ERROR: No batches selected for processing, check batch status.';
     l_retcode := 2;
  END IF;
  -- v115.11 start
      IF b_stop = TRUE Then
         FND_MESSAGE.SET_NAME('HXT','HXT_39360_STR_BTCH_NUM_TOO_LRG');
         l_errbuf := FND_MESSAGE.GET;
         FND_MESSAGE.CLEAR;
         l_retcode := 2;
      END IF;
  -- v115.11 end
  IF l_final_rollback_retcode > 0 THEN
     IF v_err_buf IS NULL THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39361_ERR_DURING_ROLLBACK');
     ELSE
       FND_MESSAGE.SET_NAME('HXT','HXT_39450_RETRO_ROLLBACK_ERROR');
       FND_MESSAGE.SET_TOKEN('ERR_BUF',v_err_buf);
     END IF;
     l_errbuf := FND_MESSAGE.GET;
     FND_MESSAGE.CLEAR;
     l_retcode := 2;
  END IF;
  -- A warning was returned from the validate process
  IF l_final_valid_retcode = 1 THEN
     l_retcode := 1;
  END IF;
  -- A stop-level error was returned from the validate process
  IF l_final_valid_retcode = 2 THEN
     IF v_err_buf IS NULL THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39362_BATCH_ERROR');
     ELSE
       FND_MESSAGE.SET_NAME('HXT','HXT_39451_RETRO_BATCH_ERROR');
       FND_MESSAGE.SET_TOKEN('ERR_BUF',v_err_buf);
     END IF;
     l_errbuf := FND_MESSAGE.GET;
     FND_MESSAGE.CLEAR;
     l_retcode := 2;
  END IF;
  -- a system level error occured somewhere during processing
  IF (l_final_valid_retcode = 3 OR l_final_sum_retcode = 3) THEN
     IF v_err_buf IS NULL THEN
       FND_MESSAGE.SET_NAME('HXT','HXT_39363_SYSTEM_ERROR');
     ELSE
       FND_MESSAGE.SET_NAME('HXT','HXT_39452_RETRO_SYSTEM_ERROR');
       FND_MESSAGE.SET_TOKEN('ERR_BUF',v_err_buf);
     END IF;
     l_errbuf := FND_MESSAGE.GET;
     FND_MESSAGE.CLEAR;
     l_retcode := 2;
  END IF;
  retcode := l_retcode;
  errbuf  := l_errbuf;
  --HXT_UTIL.DEBUG('Retcode:' || TO_CHAR(l_retcode) || ' ' || l_errbuf);
-- begin C431
-- commented out. using sysdate view, now. RTF
--delete from fnd_sessions where session_id = userenv('SESSIONID');

  /********Bug: 4620315 **********/
  /*** To merge the batch TCs by calling 'merge_batches' procedure ***/

  IF p_merge_flag = '1' and p_process_mode = 'V' THEN

    IF g_debug THEN
       hr_utility.trace('before calling merge_batches proc');
    END IF;

    HXT_BATCH_PROCESS.merge_batches (p_merge_batch_name,
				     l_merge_batches,
				     l_del_empty_batches,
		   		     p_bus_group_id,
		  		     'R'
				    );
  END IF;

  /********Bug: 4620315 **********/

  commit;
-- end C431

  EXCEPTION

     WHEN OTHERS THEN
-- commented out. using sysdate view, now. RTF
--      delete from fnd_sessions where session_id = userenv('SESSIONID');
--      commit;
        retcode := 2;
        IF v_err_buf IS NULL THEN
          FND_MESSAGE.SET_NAME('HXT','HXT_39363_SYSTEM_ERROR');
        ELSE
          FND_MESSAGE.SET_NAME('HXT','HXT_39452_RETRO_SYSTEM_ERROR');
          FND_MESSAGE.SET_TOKEN('ERR_BUF',v_err_buf);
        END IF;
        l_errbuf := FND_MESSAGE.GET;
        FND_MESSAGE.CLEAR;
        errbuf  := l_errbuf;
        HXT_BATCH_PROCESS.Set_batch_status(l_date_earned, l_batch_id, 'VE');
        HXT_BATCH_PROCESS.Insert_Pay_Batch_Errors( l_batch_id,
	                        'VE', -- RETROPAY
                                sqlerrm,
				l_return);
        commit;
END main_retro;
---------------------------------------------
FUNCTION Call_Gen_Error( p_batch_id IN NUMBER
			,p_location IN VARCHAR2
                        ,p_error_text IN VARCHAR2
                        ,p_oracle_error_text IN VARCHAR2 default NULL ) RETURN NUMBER IS
  --  calls error processing procedure  --
BEGIN
   HXT_UTIL.Gen_Error(p_batch_id, 0, 0, /*g_time_period_id*/NULL, p_error_text,
		     p_location, p_oracle_error_text
                     ,trunc(sysdate)   -- C431
                     ,hr_general.end_of_time
                     ,'ERR');

   RETURN 2;
END call_gen_error;
---------------------------------------------------------------------
END hxt_retro_process;

/
