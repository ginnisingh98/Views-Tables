--------------------------------------------------------
--  DDL for Package Body GHR_PROC_FUT_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PROC_FUT_MT" AS
/* $Header: ghprocmt.pkb 120.5.12010000.4 2008/11/17 06:20:55 vmididho ship $ */
-- Global variable to Store return code

g_futr_proc_name VARCHAR2(100);

TYPE lt_request_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_request_ids lt_request_ids;
-- ============================================================================
--                        << Procedure: execute_mt >>
--  Description:
--  	This procedure is called from concurrent program. This procedure will
--  determine the batch size and call sub programs.
-- ============================================================================
PROCEDURE EXECUTE_MT(  p_errbuf OUT NOCOPY VARCHAR2,
                       p_retcode OUT NOCOPY NUMBER,
                       p_poi IN ghr_pois.personnel_office_id%TYPE,
					   p_batch_size IN NUMBER,
					   p_thread_size IN NUMBER)
IS
   -- Cursor for Future actions when POI parameter is entered
     CURSOR   c_futr_actions_poi(c_poi ghr_pois.personnel_office_id%TYPE) IS
     SELECT   a.person_id,a.effective_date,noa.order_of_processing,
              a.pa_request_id,a.first_noa_code,a.object_version_number,
              a.employee_last_name, a.employee_first_name,a.employee_national_identifier
       FROM   ghr_pa_requests a, ghr_pa_routing_history b,ghr_nature_of_actions noa
       WHERE  effective_date <= sysdate
       AND    pa_notification_id IS NULL
       AND    approval_date IS NOT NULL
       AND    a.pa_request_id = b.pa_request_id
	   AND    noa.code  = a.first_noa_code
       AND    c_poi   =
               (SELECT POEI_INFORMATION3 FROM per_position_extra_info
                WHERE information_type = 'GHR_US_POS_GRP1'
                AND   position_id = NVL(a.to_position_id,a.from_position_id))
       AND     action_taken    = 'FUTURE_ACTION'
       AND     EXISTS
                (SELECT 1
                 FROM per_people_f per
                 WHERE per.person_id = a.person_id
                 AND a.effective_date BETWEEN
                 per.effective_start_date AND per.effective_end_date )
      AND     b.pa_routing_history_id = (SELECT max(pa_routing_history_id)
                                          FROM ghr_pa_routing_history
                                          WHERE pa_request_id = a.pa_request_id)
      ORDER BY person_id,effective_date,order_of_processing;

-- Cursor to find total future action records if POI parameter is entered
CURSOR c_tot_futr_actions_poi(c_poi ghr_pois.personnel_office_id%TYPE) IS
 SELECT  COUNT(*) fut_cnt
       FROM   ghr_pa_requests a, ghr_pa_routing_history b,ghr_nature_of_actions noa
       WHERE  effective_date <= sysdate
       AND    pa_notification_id IS NULL
       AND    approval_date IS NOT NULL
       AND    a.pa_request_id = b.pa_request_id
	   AND    noa.code  = a.first_noa_code
       AND    c_poi   =
               (SELECT POEI_INFORMATION3 FROM per_position_extra_info
                WHERE information_type = 'GHR_US_POS_GRP1'
                AND   position_id = NVL(a.to_position_id,a.from_position_id))
       AND     action_taken    = 'FUTURE_ACTION'
       AND     EXISTS
                (SELECT 1
                 FROM per_people_f per
                 WHERE per.person_id = a.person_id
                 AND a.effective_date BETWEEN
                 per.effective_start_date AND per.effective_end_date )
      AND     b.pa_routing_history_id = (SELECT max(pa_routing_history_id)
                                          FROM ghr_pa_routing_history
                                          WHERE pa_request_id = a.pa_request_id);


-- Cursor to fetch future action records when POI parameter is not entered.

      CURSOR c_futr_actions IS
      SELECT  a.person_id,a.effective_date,noa.order_of_processing,
              a.pa_request_id,a.first_noa_code,a.object_version_number,
              a.employee_last_name, a.employee_first_name,a.employee_national_identifier
       FROM   ghr_pa_requests a, ghr_pa_routing_history b,ghr_nature_of_actions noa
       WHERE  effective_date <= sysdate
       AND    pa_notification_id IS NULL
       AND    approval_date IS NOT NULL
       AND    a.pa_request_id = b.pa_request_id
	   AND    noa.code  = a.first_noa_code
       AND     action_taken    = 'FUTURE_ACTION'
       AND     EXISTS
                (SELECT 1
                 FROM per_people_f per
                 WHERE per.person_id = a.person_id
                 AND a.effective_date BETWEEN
                 per.effective_start_date AND per.effective_end_date )
      AND     b.pa_routing_history_id = (SELECT max(pa_routing_history_id)
                                          FROM ghr_pa_routing_history
                                          WHERE pa_request_id = a.pa_request_id)
      ORDER BY person_id,effective_date,order_of_processing;

-- Cursor to find total future action records when POI parameter is not entered.
CURSOR c_tot_futr_actions IS
 SELECT COUNT(*) fut_cnt
       FROM   ghr_pa_requests a, ghr_pa_routing_history b,ghr_nature_of_actions noa
       WHERE  effective_date <= sysdate
       AND    pa_notification_id IS NULL
       AND    approval_date IS NOT NULL
       AND    a.pa_request_id = b.pa_request_id
	   AND    noa.code  = a.first_noa_code
       AND     action_taken    = 'FUTURE_ACTION'
       AND     EXISTS
                (SELECT 1
                 FROM per_people_f per
                 WHERE per.person_id = a.person_id
                 AND a.effective_date BETWEEN
                 per.effective_start_date AND per.effective_end_date )
      AND     b.pa_routing_history_id = (SELECT max(pa_routing_history_id)
                                          FROM ghr_pa_routing_history
                                          WHERE pa_request_id = a.pa_request_id);

CURSOR c_completion_status(c_session_id NUMBER) IS
SELECT max(completion_status) max_status
FROM GHR_MTS_TEMP
WHERE session_id = c_session_id;

-- Declaration of Local variables
l_person_id per_all_people.person_id%type;
l_effective_date ghr_pa_requests.effective_date%type;
l_batch_size NUMBER;
l_thread_size NUMBER;
l_batch_no NUMBER;
l_batch_counter NUMBER;
l_session_id NUMBER;
l_parent_request_id NUMBER;
l_completion_status NUMBER;
l_request_id NUMBER;
l_log_text	VARCHAR2(2000);
l_user_name VARCHAR2(200);
l_new_line VARCHAR2(1);
l_result VARCHAR2(200);
l_status BOOLEAN;
l_count NUMBER;
-- Bug # 7510344
l_curr_business_group_id  per_all_people_f.business_group_id%type;

rphase varchar2(80);
rstatus varchar2(80);
dphase varchar2(30);
dstatus varchar2(30);
message varchar2(240);
call_status boolean;

BEGIN
	-- Initialization of variables.
	l_batch_counter := 0;
	l_batch_no := 1;
	l_session_id := USERENV('SESSIONID');
	l_parent_request_id := fnd_profile.VALUE ('CONC_REQUEST_ID');
	l_status := TRUE;
	g_request_ids.DELETE;
	g_futr_proc_name := 'GHR_Proc_Futr_Act' || '_' || l_parent_request_id;
	-- Bug # 7510344
        l_curr_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

	-- Thread size should be minimum of 10.
	IF p_thread_size IS NULL OR p_thread_size < 10 THEN
		l_thread_size := 10;
	ELSIF p_thread_size > 35 THEN
		l_thread_size := 35;
	ELSE
		l_thread_size := p_thread_size;
	END IF;

	-- Batch size should be minimum of 1000.
	IF p_batch_size IS NULL OR p_batch_size < 1000 THEN
		l_batch_size := 1000;
	ELSE
		l_batch_size := p_batch_size;
	END IF;

	-- Find out Total future action records
	IF  p_poi IS NULL THEN
		FOR l_tot_futr_actions IN c_tot_futr_actions LOOP
			l_count := l_tot_futr_actions.fut_cnt;
		END LOOP;
	ELSE
		FOR l_tot_futr_actions_poi IN c_tot_futr_actions_poi(p_poi) LOOP
			l_count := l_tot_futr_actions_poi.fut_cnt;
		END LOOP;
	END IF;

	-- Revise the batch size if the total future action record is more than
	-- the product of thread size and batch size.
	IF l_count > (l_thread_size * l_batch_size) THEN
		l_batch_size := CEIL(l_count/l_thread_size);
	END IF;

	-- If Personnel office ID is entered, call the cursor c_futr_actions_poi
	-- else call c_futr_actions
	IF p_poi IS NULL THEN

		-- Loop through the future actions and insert them into the appropriate batch.
		-- If the batch size exceeds the limit and if the record belongs to different
		-- person, insert the following records into the next batch.
		FOR l_c_futr_actions IN c_futr_actions LOOP
            l_result := NULL;
            -- Bug#3726290 New business rule for NOAC 355
            IF l_c_futr_actions.first_noa_code = '355' THEN
                verify_355_business_rule(l_c_futr_actions.person_id,
                                         l_c_futr_actions.effective_date,
                                         l_result);
			END IF;
			IF NVL(l_result,'NOT EXISTS') = 'NOT EXISTS' THEN
                -- If there is another record for the same person on same effective date, skip that record.
                -- Bug 4127797 TAR 4256507.995
                IF (NVL(l_person_id,hr_api.g_number) = l_c_futr_actions.person_id AND
                    NVL(l_effective_date,hr_api.g_eot) = l_c_futr_actions.effective_date) THEN
                    NULL;
                ELSE
                    IF l_batch_counter >= l_batch_size AND NVL(l_person_id,hr_api.g_number) <> l_c_futr_actions.person_id THEN
                        l_batch_no := l_batch_no + 1;
                        l_batch_counter := 0;
                    END IF;
                    --Bug#3726290 Add the separation Business Rule here.

                    -- Insert values into the table
                    INSERT INTO GHR_MTS_TEMP(session_id, batch_no, pa_request_id, action_type)
                    VALUES(l_session_id,l_batch_no,l_c_futr_actions.pa_request_id, 'FUTURE');
                    l_person_id := l_c_futr_actions.person_id;
                    l_effective_date := l_c_futr_actions.effective_date;
                    l_batch_counter := l_batch_counter + 1;
                END IF;
           ELSE
                --Bug#3726290 close the RPA, if p_result <> 'NOT EXISTS'
                fnd_profile.get('USERNAME',l_user_name);
                --bug#4896738
		--hr_utility.set_location('Intial value of g_skip_grp_box '||decode(g_skip_grp_box,TRUE,1,0),9876);
		g_skip_grp_box := TRUE;
         	--hr_utility.set_location('value before calling end sf52 g_skip_grp_box '||decode(g_skip_grp_box,TRUE,1,0),9875);
        BEGIN --Bug# 6753024, Since we r not able to reproduce the issue. Fixing the issue as suggested by the
              --customers. ref: 37668_CustomizedFuturesCode.doc
            ghr_SF52_api.end_SF52
                    (p_validate                    => false
                    ,p_pa_request_id               => l_c_futr_actions.pa_request_id
                    ,p_par_object_version_number   => l_c_futr_actions.object_version_number
                    ,p_action_taken                => 'CANCELED'
                    ,p_user_name                   => l_user_name
                    ,p_first_noa_code              => '355'
                    );
                    l_log_text :=  substr(
                        'PA_REQUEST_ID: ' || to_char(l_c_futr_actions.pa_request_id) ||  ' ; '  ||
                        'Employee Name: ' || l_c_futr_actions.employee_last_name || ' ; ' || l_c_futr_actions.employee_first_name || l_new_line ||
                        'SSN: ' || l_c_futr_actions.employee_national_identifier ||  ' ; '  ||
                        'First NOA Code: ' || l_c_futr_actions.first_noa_code ||
                        ' has been closed as pending conversion action/Temp Appointment action '  || l_new_line ||
                        'is pending.' , 1, 2000);
                    create_ghr_errorlog(
                                p_program_name	=> g_futr_proc_name,
                                p_log_text	=> l_log_text,
                                p_message_name	=> '355_Business_Rule_Violation',
                                p_log_date	=> sysdate
                               );
                    l_person_id := l_c_futr_actions.person_id;
                    l_effective_date := l_c_futr_actions.effective_date;
                    l_batch_counter := l_batch_counter + 1;
             --bug#4896738
            g_skip_grp_box := FALSE;
            -- hr_utility.set_location('value after resetting '||decode(g_skip_grp_box,TRUE,1,0),9874);
        --Begin Bug# 6753024
        EXCEPTION
            WHEN OTHERS
            THEN
              l_log_text  := SUBSTR (
                                 'PA_REQUEST_ID: '
                              || TO_CHAR (l_c_futr_actions.pa_request_id)
                              || ' ; '
                              || 'Employee Name: '
                              || l_c_futr_actions.employee_last_name
                              || ' ; '
                              || l_c_futr_actions.employee_first_name
                              || l_new_line
                              || 'SSN: '
                              || l_c_futr_actions.employee_national_identifier
                              || ' ; '
                              || 'First NOA Code: '
                              || l_c_futr_actions.first_noa_code
                              || l_new_line
                              || ' Error Code: '
                              || SQLCODE
                              || ' Error Msg: '
                              || SQLERRM
                              || l_new_line,
                              1,
                              2000
                            );
              create_ghr_errorlog (
                p_program_name   => g_futr_proc_name,
                p_log_text       => l_log_text,
                p_message_name   => '355_Buss_Rule_error',
                p_log_date       => SYSDATE
              );

        END;
        --End Bug# 6753024
        END IF;
		END LOOP;
	ELSE
		FOR l_c_futr_actions IN c_futr_actions_poi(p_poi) LOOP
            l_result := NULL;
            -- Bug#3726290 New business rule for NOAC 355
            IF l_c_futr_actions.first_noa_code = '355' THEN
                verify_355_business_rule(l_c_futr_actions.person_id,
                                         l_c_futr_actions.effective_date,
                                         l_result);
			END IF;
			IF NVL(l_result,'NOT EXISTS') = 'NOT EXISTS' THEN
                -- If there is another record for the same person on same effective date, skip that record.
                -- Bug 4127797 TAR 4256507.995
                    IF (NVL(l_person_id,hr_api.g_number) = l_c_futr_actions.person_id AND
                        NVL(l_effective_date,hr_api.g_eot) = l_c_futr_actions.effective_date) THEN
                        NULL;
                    ELSE
                        IF l_batch_counter >= l_batch_size AND NVL(l_person_id,hr_api.g_number) <> l_c_futr_actions.person_id THEN
                            l_batch_no := l_batch_no + 1;
                            l_batch_counter := 0;
                        END IF;
                        -- Insert values into the table
                        INSERT INTO GHR_MTS_TEMP(session_id, batch_no, pa_request_id, action_type)
                        VALUES(l_session_id,l_batch_no,l_c_futr_actions.pa_request_id, 'FUTURE');
                        l_person_id := l_c_futr_actions.person_id;
                        l_effective_date := l_c_futr_actions.effective_date;
                        l_batch_counter := l_batch_counter + 1;
                    END IF;
            ELSE
                --Bug#3726290 close the RPA, if p_result <> 'NOT EXISTS'
                fnd_profile.get('USERNAME',l_user_name);
               --bug#4896738
		--hr_utility.set_location('Intial value of g_skip_grp_box '||g_skip_grp_box,9873);
		g_skip_grp_box := TRUE;
         	--hr_utility.set_location('value before calling end sf52 g_skip_grp_box '||g_skip_grp_box,9872);
        BEGIN --Bug# 6753024
		ghr_SF52_api.end_SF52
                (p_validate                    => false
                ,p_pa_request_id               => l_c_futr_actions.pa_request_id
                ,p_par_object_version_number   => l_c_futr_actions.object_version_number
                ,p_action_taken                => 'CANCELED'
                ,p_user_name                   => l_user_name
                ,p_first_noa_code              => '355'
                );
                l_log_text :=  substr(
                    'PA_REQUEST_ID: ' || to_char(l_c_futr_actions.pa_request_id) || ' ; ' ||
                    'Employee Name: ' || l_c_futr_actions.employee_last_name || ' ; ' || l_c_futr_actions.employee_first_name || l_new_line ||
                    'SSN: ' || l_c_futr_actions.employee_national_identifier || ' ; '||
                    'First NOA Code: ' || l_c_futr_actions.first_noa_code ||
                    ' has been closed as pending conversion action/Temp Appointment action '  || l_new_line ||
                    'is pending.' , 1, 2000);
                create_ghr_errorlog(
                            p_program_name	=> g_futr_proc_name,
                            p_log_text	=> l_log_text,
                            p_message_name	=> '355_Business_Rule_Violation',
                            p_log_date	=> sysdate
                           );
                l_person_id := l_c_futr_actions.person_id;
                l_effective_date := l_c_futr_actions.effective_date;
             --bug#4896738
             g_skip_grp_box := FALSE;
	    -- hr_utility.set_location('value after resetting '||g_skip_grp_box,9871);
        --Begin Bug# 6753024
        EXCEPTION
            WHEN OTHERS
            THEN
              l_log_text  := SUBSTR (
                                 'PA_REQUEST_ID: '
                              || TO_CHAR (l_c_futr_actions.pa_request_id)
                              || ' ; '
                              || 'Employee Name: '
                              || l_c_futr_actions.employee_last_name
                              || ' ; '
                              || l_c_futr_actions.employee_first_name
                              || l_new_line
                              || 'SSN: '
                              || l_c_futr_actions.employee_national_identifier
                              || ' ; '
                              || 'First NOA Code: '
                              || l_c_futr_actions.first_noa_code
                              || l_new_line
                              || ' Error Code: '
                              || SQLCODE
                              || ' Error Msg: '
                              || SQLERRM
                              || l_new_line,
                              1,
                              2000
                            );
              create_ghr_errorlog (
                p_program_name   => g_futr_proc_name,
                p_log_text       => l_log_text,
                p_message_name   => '355_Buss_Rule_error',
                p_log_date       => SYSDATE
              );
         END; --End Bug# 6753024
         END IF;
		END LOOP;
	END IF;
	COMMIT;

	-- Call child concurrent programs for each and every thread
	l_log_text := 'Total number of employees: ' || l_count || ' : Number of Batches  ' || l_batch_no || ' : Batch size ' || l_batch_size;
	create_ghr_errorlog(
						p_program_name	=> g_futr_proc_name,
						p_log_text		=> l_log_text,
						p_message_name	=> 'Number of Batches',
						p_log_date		=> sysdate
					);
	COMMIT;
	-- Commented for testing
	FOR l_thread IN 1..l_batch_no LOOP
		-- Concurrent program
		l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                   application => 'GHR',
				   program => 'GHSUBPROCFUTMT',
				   sub_request => FALSE,
				   argument1=> l_session_id, -- Session ID
				   argument2=> l_thread, -- Batch no
				   argument3=> l_parent_request_id -- Parent request id
                 );
		g_request_ids(l_thread) := l_request_id;
--		fnd_conc_global.set_req_globals(conc_status => 'PAUSED');
	END LOOP;

	COMMIT;

	IF g_request_ids.COUNT > 0 THEN
		-- Wait for the child concurrent programs to get finished
		FOR l_thread_count IN 1..l_batch_no LOOP
			l_status := TRUE;
			hr_utility.set_location('batch ' || l_thread_count,1000);
			hr_utility.set_location('request id  ' || g_request_ids(l_thread_count),1000);
			WHILE l_status = TRUE LOOP
				call_status := FND_CONCURRENT.GET_REQUEST_STATUS(g_request_ids(l_thread_count),'','',rphase,rstatus,dphase,dstatus, message);
				hr_utility.set_location('dphase  ' || dphase,1000);
				IF dphase = 'COMPLETE' THEN
					l_status := FALSE;
				ELSE
					dbms_lock.sleep(5);
				END IF;
			END LOOP;
		END LOOP;
	END IF;

	FOR l_cur_compl_status IN c_completion_status(l_session_id) LOOP
		l_completion_status := l_cur_compl_status.max_status;
	END LOOP;

	--hr_utility.trace_off;
	-- Assigning Return codes
	IF l_completion_status = 2 THEN
		p_retcode := 2;
		p_errbuf  := 'There were errors in SF52''s which could NOT be routed to approver''s Inbox. Detail in GHR_PROCESS_LOG';
	ELSIF l_completion_status = 1 THEN
		p_retcode := 1;
		p_errbuf  := 'There were errors in SF52''s which were routed to approver''s Inbox. Detail in GHR_PROCESS_LOG' ;
	ELSE
		p_retcode := 0;
    END IF;

       -- Bug # 7510344
       --setting back the business group
       if l_curr_business_group_id <> fnd_profile.value('PER_BUSINESS_GROUP_ID') then
          fnd_profile.put('PER_BUSINESS_GROUP_ID',l_curr_business_group_id);
       end if;

	-- Delete the temporary table data.
	DELETE FROM GHR_MTS_TEMP
		WHERE session_id = l_session_id;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		p_retcode := 1;
		p_errbuf := SQLERRM;
	DELETE FROM GHR_MTS_TEMP
		WHERE session_id = l_session_id;
	COMMIT;

END EXECUTE_MT;

-- ============================================================================
--                        << Procedure: sub_proc_futr_act >>
--  Description:
--  	This procedure is called from master conc. program. This procedure will
--  call RPA processing method. Also whenever error occurs the same is reported
--  to the process log.
-- ============================================================================

PROCEDURE SUB_PROC_FUTR_ACT(p_errbuf OUT NOCOPY VARCHAR2,
	                        p_retcode OUT NOCOPY NUMBER,
							p_session_id IN NUMBER,
							p_batch_no IN NUMBER,
							p_parent_request_id IN NUMBER)
IS
CURSOR c_batch_mts(c_session_id IN NUMBER,
				   c_batch_no IN NUMBER) IS
SELECT pa_request_id, batch_no
FROM  GHR_MTS_TEMP
WHERE session_id = c_session_id
AND batch_no = c_batch_no;

CURSOR  c_get_req(c_pa_request_id IN ghr_pa_requests.pa_request_id%type) IS
   SELECT *
   FROM ghr_pa_requests
   WHERE  pa_request_id = c_pa_request_id;

CURSOR c_sessionid is
        select userenv('sessionid') sesid  from dual;
-- Local Variables
l_sf52_rec	ghr_pa_requests%rowtype;
l_new_line VARCHAR2(1);
l_log_text	VARCHAR2(2000);
l_futr_proc_name VARCHAR2(50);
e_refresh EXCEPTION; -- Exception for refresh
l_retcode NUMBER;
l_result VARCHAR2(30);
l_error_message VARCHAR2(2000);
l_proc		varchar2(30);
l_sid           NUMBER;


 -- Start of Bug 3602261

   l_object_version_number      ghr_pa_requests.object_version_number%type;

   CURSOR c_ovn (p_pa_request_id ghr_pa_requests.pa_request_id%type)  IS        -- 3769917
     SELECT par.object_version_number
     FROM   ghr_pa_requests par
     WHERE  par.pa_request_id = p_pa_request_id;           -- 3769917

-- End of Bug 3602261

-- Bug # 7510344
cursor c_per_bus_group_id(p_person_id in per_people_f.person_id%TYPE,
                          p_effective_date in date)
    is
    select ppf.business_group_id
    from per_people_f ppf
    where ppf.person_id = p_person_id
    and p_effective_date between ppf.effective_start_date
    and ppf.effective_end_date;

l_bus_group_id   per_all_people_f.business_group_id%type;
-- End of Bug # 7510344


BEGIN

 FOR s_id IN c_sessionid
   LOOP
     l_sid  := s_id.sesid;
   EXIT;
 END LOOP;

  BEGIN
      UPDATE fnd_sessions SET SESSION_ID = l_sid
      WHERE  SESSION_ID = l_sid;
      IF SQL%NOTFOUND THEN
         INSERT INTO fnd_sessions
            (SESSION_ID,EFFECTIVE_DATE)
         VALUES
            (l_sid,sysdate);
      END IF;
  END;

-- Local initialization
l_new_line := substr('
',1,1);
l_proc := 'SUB_PROC_FUTR_ACT';
g_futr_proc_name := 'GHR_Proc_Futr_Act' || '_' || p_parent_request_id;
-- Loop through the temporary table for that batch number and session id
FOR l_batch_mts IN c_batch_mts(p_session_id,p_batch_no) LOOP
	-- Loop through the RPA record
	FOR l_get_req IN c_get_req(l_batch_mts.pa_request_id) LOOP
		l_sf52_rec := l_get_req;
		--============================================
		BEGIN
			-- Process RPA
				-- Bug 2639698 If To Pay is less than From Pay, no need to process. Just route it to inbox

                -- FWFA Changes Bug#4444609 Added the following ELSIF condition
                IF UPPER(SUBSTR(l_sf52_rec.request_number,1,3)) IN ('MTC','MSL')  AND
                      l_sf52_rec.pay_rate_determinant IN ('3','4','J','K','U','V') AND
					  l_sf52_rec.effective_date >= to_date('01/05/2005','dd/mm/yyyy') AND
						(l_sf52_rec.to_retention_allowance is NOT NULL OR
						   l_sf52_rec.to_retention_allow_percentage is NOT NULL)THEN
							l_log_text := 'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
								'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
								'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,'
											  || l_sf52_rec.employee_first_name || l_new_line ||
								'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
								'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
								'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
								'Warning: The person has an existing retention allowance authorization. ' ||  l_new_line ||
								'Action: Please review the retention allowance amount for this employee,' || l_new_line ||
								'and process the action' ;    -- Bug 3320086 Changed error message.

						hr_utility.set_location(l_log_text,1511);
						create_ghr_errorlog(
							p_program_name	=> g_futr_proc_name,
							p_log_text		=> l_log_text,
							p_message_name	=> 'SF52 Routed to Inbox',
							p_log_date		=> sysdate
							);
						Route_Errored_SF52(
						   p_sf52   => l_sf52_rec,
						   p_error  => l_log_text,
						   p_result => l_result
						 );
						 l_retcode := 5; -- Error - but route to inbox
				-- Bug 4699780 For cases with to salary less than from salary, it should be routed to inbox
				-- only if it's not FWFA
				/*ELSIF ( UPPER(SUBSTR(l_sf52_rec.request_number,1,3)) = 'MSL' AND l_sf52_rec.first_noa_code = '894')
				AND (l_sf52_rec.to_basic_pay < l_sf52_rec.from_basic_pay) AND
					NOT (l_sf52_rec.pay_rate_determinant IN ('3','4','J','K','U','V') AND
						l_sf52_rec.effective_date >= to_date('01/05/2005','dd/mm/yyyy')) THEN
						l_log_text := 'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
								'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
								'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,'
											  || l_sf52_rec.employee_first_name || l_new_line ||
								'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
								'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
								'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
								'Error: The From Side Basic Pay exceeds the To Side Basic Pay. ' ||  l_new_line ||
								'Cause: The Personnel Action attempted to update the employee''s salary with a ' || l_new_line ||
								'decreased amount of Basic Pay. ' || l_new_line ||
								'Action: Please review the personnel action to verify the Grade and Step, Pay Table amounts,' || l_new_line ||
								'and Pay Rate Determinant code for this employee.' ;    -- Bug 3320086 Changed error message.

						hr_utility.set_location(l_log_text,1511);
						create_ghr_errorlog(
							p_program_name	=> g_futr_proc_name,
							p_log_text		=> l_log_text,
							p_message_name	=> 'SF52 Routed to Inbox',
							p_log_date		=> sysdate
							);
						Route_Errored_SF52(
						   p_sf52   => l_sf52_rec,
						   p_error  => l_log_text,
						   p_result => l_result
						 );
						 l_retcode := 5; -- Error - but route to inbox --
                -- FWFA Changes
				*/
                ELSE

		   --7510344
                  If l_sf52_rec.person_id is not null then
                     for c_per_bus_rec in c_per_bus_group_id(l_sf52_rec.person_id,l_sf52_rec.effective_date)
                     loop
                       l_bus_group_id := c_per_bus_rec.business_group_id;
                       exit;
                     end loop;
                  end if;

                  if l_bus_group_id <> fnd_profile.value('PER_BUSINESS_GROUP_ID') then
                    --Putting the BUSINESS GROUP_ID
                      fnd_profile.put('PER_BUSINESS_GROUP_ID',l_bus_group_id);
                  end if;
                  --7510344


					SAVEPOINT future_Action;
					GHR_PROCESS_SF52.Process_SF52(
								p_sf52_data		=> l_sf52_rec,
								p_process_type	=> 'FUTURE');

					--  Start of Bug 3602261
                                ghr_sf52_post_update.get_notification_details
				  (p_pa_request_id                  =>  l_sf52_rec.pa_request_id,
				   p_effective_date                 =>  l_sf52_rec.effective_date,
				   p_from_position_id               =>  l_sf52_rec.from_position_id,
				   p_to_position_id                 =>  l_sf52_rec.to_position_id,
				   p_agency_code                    =>  l_sf52_rec.agency_code,
				   p_from_agency_code               =>  l_sf52_rec.from_agency_code,
				   p_from_agency_desc               =>  l_sf52_rec.from_agency_desc,
				   p_from_office_symbol             =>  l_sf52_rec.from_office_symbol,
				   p_personnel_office_id            =>  l_sf52_rec.personnel_office_id,
				   p_employee_dept_or_agency        =>  l_sf52_rec.employee_dept_or_agency,
				   p_to_office_symbol               =>  l_sf52_rec.to_office_symbol
				   );
				 FOR ovn_rec IN c_ovn (l_sf52_rec.pa_request_id) LOOP
				     l_object_version_number := ovn_rec.object_version_number;
				 END LOOP;
				 ghr_par_upd.upd
				   (p_pa_request_id                  =>  l_sf52_rec.pa_request_id,
				    p_object_version_number          =>  l_object_version_number,
				    p_from_position_id               =>  l_sf52_rec.from_position_id,
				    p_to_position_id                 =>  l_sf52_rec.to_position_id,
				    p_agency_code                    =>  l_sf52_rec.agency_code,
				    p_from_agency_code               =>  l_sf52_rec.from_agency_code,
				    p_from_agency_desc               =>  l_sf52_rec.from_agency_desc,
				    p_from_office_symbol             =>  l_sf52_rec.from_office_symbol,
				    p_personnel_office_id            =>  l_sf52_rec.personnel_office_id,
				    p_employee_dept_or_agency        =>  l_sf52_rec.employee_dept_or_agency,
				    p_to_office_symbol               =>  l_sf52_rec.to_office_symbol
				   );
-- End of Bug 3602261

					l_log_text := 'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
							'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
							'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,'
										  || l_sf52_rec.employee_first_name || l_new_line ||
							'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
							'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
							'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
							'Processed Successfully';

					create_ghr_errorlog(
						p_program_name	=> g_futr_proc_name,
						p_log_text		=> l_log_text,
						p_message_name	=> 'SF52 Processed Successfully',
						p_log_date		=> sysdate
						);
				 END IF; -- IF ( UPPER(SUBSTR(l_sf52_rec.request_number,1,3)) = 'MSL'
		EXCEPTION
            --Bug# 5634990 added the package GHR_PROCESS_SF52 exception and modified error msg
			WHEN GHR_PROCESS_SF52.e_refresh THEN
			BEGIN
				ROLLBACK TO future_Action;
				IF NVL(l_retcode, 0) <> 2 THEN
					l_retcode := 1; /* warning */
				END IF;
				-- Enter a record in process log
				l_log_text := SUBSTR(
						'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
						'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
						'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,' ||
                                                                            l_sf52_rec.employee_first_name || l_new_line ||
						'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line  ||
						'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
						'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
						'Action: RPA related information has changed. Retrieve the RPA from the groupbox to review the refreshed information, make necessary changes, and update HR',1,2000);
				create_ghr_errorlog(
					p_program_name	=> g_futr_proc_name,
					p_log_text		=> l_log_text,
					p_message_name	=> 'Future SF52 Routed to Inbox',--Bug#5634990
					p_log_date		=> sysdate
			        );
				l_error_message := 'Action: RPA related information has changed. Retrieve the RPA from the groupbox to review the refreshed information, make necessary changes, and update HR';--Bug#5634990
				Route_Errored_SF52(
				   p_sf52   => l_sf52_rec,
				   p_error  => substr(l_error_message,1 ,512),
				   p_result => l_result
				 );
				COMMIT;
			END;

			WHEN OTHERS THEN
			BEGIN
				IF SQLCODE = -6508 then
					-- Program Unit not found
					-- This usually happens and the only solution know so far is
					-- to re-start the conc. manager. So all the SF52's are routed unnecessarily
					l_retcode := 2; /* Error*/
					p_errbuf := ' Program raised Error - Program Unit not Found. Details in Process Log.';
					l_log_text := substr('Initiate Process Future Dated SF52 Due For Processing Terminated due to following error :  ' || Sqlerrm(sqlcode), 1, 2000);

					ROLLBACK TO future_Action;
					create_ghr_errorlog(
						p_program_name	=> g_futr_proc_name,
						p_log_text		=> l_log_text,
						p_message_name	=> 'Process Terminated',
						p_log_date		=> sysdate
					);
					COMMIT;
					RETURN;
				END IF;

				ROLLBACK TO future_Action;
				IF nvl(l_retcode, 0) <> 2 THEN
					l_retcode := 1; /* warning */
				END IF;

				-- Enter a record in process log
				l_log_text := substr(
						'Request Number : ' || l_sf52_rec.request_number || l_new_line ||
						'PA_REQUEST_ID : ' || to_char(l_sf52_rec.pa_request_id) || l_new_line ||
						'Employee Name : ' || l_sf52_rec.employee_last_name || ' ,' ||
                                        l_sf52_rec.employee_first_name || l_new_line ||
						'SSN           : ' || l_sf52_rec.employee_national_identifier || l_new_line ||
						'First NOA Code: ' || l_sf52_rec.first_noa_code || l_new_line ||
						'Second NOA Code: ' || l_sf52_rec.second_noa_code || l_new_line ||
						'Error : ' || sqlerrm(sqlcode) , 1, 2000);
				create_ghr_errorlog(
					p_program_name	=> g_futr_proc_name,
					p_log_text		=> l_log_text,
					p_message_name	=> 'SF52 Errored Out',
					p_log_date		=> sysdate
			        );
				COMMIT;
				EXCEPTION
				WHEN OTHERS THEN
					-- Error
					l_retcode := 2;
					p_errbuf  := 'Process was errored out while creating Error Log. Error: ' || substr(sqlerrm(sqlcode), 1, 50);
					RETURN;
				END;
                l_error_message := substr(sqlerrm(sqlcode), 1, 512);
                Route_Errored_SF52(
                  p_sf52   => l_sf52_rec,
                  p_error  => substr(l_error_message,1 ,512),
                  p_result => l_result
                  );
                IF l_result = '2' THEN
                  l_retcode := 2;
                END IF;
                COMMIT;
		END; -- End RPA Processing

	END LOOP;

END LOOP;
 -- Set Concurrent program completion messages

 IF l_retcode = 2 THEN
	p_retcode := 2;
		hr_utility.set_location('Ret code ' || to_char(l_retcode),1);
	p_errbuf  := 'There were errors in SF52''s which could NOT be routed to approver''s Inbox. Detail in GHR_PROCESS_LOG';
 ELSIF l_retcode = 5 THEN
	p_retcode := 2;
		hr_utility.set_location('Ret code ' || to_char(l_retcode),1);
	p_errbuf  := 'There were errors in SF52''s which were routed to approver''s Inbox. Detail in GHR_PROCESS_LOG';
 ELSIF l_retcode IS NOT NULL THEN
	-- Warning
	p_retcode := 1;
	p_errbuf  := 'There were errors in SF52''s which were routed to approver''s Inbox. Detail in GHR_PROCESS_LOG' ;
 ELSIF l_retcode IS NULL THEN
	p_retcode := 0;
 END IF;

 -- Update the completion status.
 UPDATE GHR_MTS_TEMP
 SET completion_status = p_retcode
 WHERE session_id = p_session_id
 AND batch_no = p_batch_no;

 COMMIT;


END SUB_PROC_FUTR_ACT;


--

-- ============================================================================
--                        << Procedure: create_ghr_errorlog >>
--  Description:
--  	This procedure inserts the log text into Federal Process log
-- ============================================================================

PROCEDURE create_ghr_errorlog(
        p_program_name           in     ghr_process_log.program_name%type,
        p_log_text               in     ghr_process_log.log_text%type,
        p_message_name           in     ghr_process_log.message_name%type,
        p_log_date               in     ghr_process_log.log_date%type
        ) is

	l_proc		varchar2(30);
Begin
	l_proc		:=  'create_ghr_errorlog';
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
     insert into ghr_process_log
	(process_log_id
      ,program_name
      ,log_text
      ,message_name
      ,log_date
      )
     values
	(ghr_process_log_s.nextval
      ,p_program_name
      ,p_log_text
      ,p_message_name
      ,p_log_date
     );
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);

END create_ghr_errorlog;


Procedure Route_Errored_SF52(
				p_sf52   in out nocopy ghr_pa_requests%rowtype,
				p_error	 in varchar2,
				p_result out nocopy varchar2) is

	l_u_prh_object_version_number		number;
	l_i_pa_routing_history_id	     	number;
	l_i_prh_object_version_number		number;

	l_log_text				varchar2(2000);
	l_proc					varchar2(30);
        l_new_line				varchar2(1);
	l_sf52					ghr_pa_requests%rowtype ;
Begin
        l_proc := 'Route_Errerd_SF52';
        l_new_line := substr('
 ',1,1);
	l_sf52 := p_sf52; --NOCOPY Changes
	hr_utility.set_location( 'Entering : ' || l_proc, 10);
	savepoint route_errored_sf52;
	hr_utility.set_location( l_proc, 20);
	l_log_text := 'Request Number : ' || p_sf52.request_number || l_new_line ||
			  'PA_REQUEST_ID : ' || to_char(p_sf52.pa_request_id) ||
                    ' has errors.' || l_new_line ||
                    'Error :         ' || p_error || l_new_line ||
                    'Errored while routing it to the approver''s Inbox ';

	ghr_api.call_workflow(
		p_pa_request_id	=>	p_sf52.pa_request_id,
		p_action_taken	=>	'CONTINUE',
		p_error		=>	p_error);
	hr_utility.set_location( 'Leaving : ' || l_proc, 20);
Exception
when others then
	hr_utility.set_location(l_proc || ' workflow errored out', 30);
	rollback to route_errored_sf52;
	p_result := '0';
	l_log_text := substr(
			'Request Number : ' || p_sf52.request_number || l_new_line ||
			'PA_REQUEST_ID : ' || to_char(p_sf52.pa_request_id) || l_new_line ||
			'Employee Name : ' || p_SF52.employee_last_name || ' ,' || p_sf52.employee_first_name || l_new_line ||
			'SSN           : ' || p_sf52.employee_national_identifier || l_new_line ||
			'First NOA Code: ' || p_sf52.first_noa_code || l_new_line ||
			'Second NOA Code: ' || p_sf52.second_noa_code || l_new_line ||
			'Errored while routing it to the approver''s Inbox '  || l_new_line ||
			'Error : ' || sqlerrm(sqlcode), 1, 2000);
	create_ghr_errorlog(
		p_program_name	=> g_futr_proc_name,
		p_log_text		=> l_log_text,
		p_message_name	=> 'Routing Error',
		p_log_date		=> sysdate
	);
	hr_utility.set_location(l_proc , 40);
	p_result := '2';
	p_sf52 := l_sf52; --Added for nocopy changes

End Route_Errored_SF52;

-- ============================================================================
--                        << Procedure: verify_355_business_rule >>
--  Bug#3726290
--  Description:
--  This procedure verifies the business rule implemented for NOA code 355
-- ============================================================================
--  created the procedure to implement new business rule for NOAC 355

PROCEDURE verify_355_business_rule(
                                    p_person_id      IN     NUMBER,
                                    p_effective_date IN     DATE,
                                    p_result         OUT    NOCOPY  VARCHAR2
                                  ) IS

	l_proc		VARCHAR2(30);
	l_dummy  	VARCHAR2(30);
	l_ovn           NUMBER;

       CURSOR c_pending_action_exists(c_person_id NUMBER, c_effective_date Date) IS
	   SELECT  'X'
       FROM   ghr_pa_requests a, ghr_pa_routing_history b
       WHERE  a.effective_date between (c_effective_date - 2) and (c_effective_date + 1)
       AND    a.person_id     = c_person_id
       AND    (substr(a.first_noa_code,1,1) = '5' OR a.first_noa_code IN ('760','762','765'))
       AND    pa_notification_id IS NULL
       AND    approval_date IS NOT NULL
       AND    a.pa_request_id = b.pa_request_id
       AND     action_taken    = 'FUTURE_ACTION'
       AND     EXISTS
                (SELECT 1
                 FROM per_people_f per
                 WHERE per.person_id = a.person_id
                 AND a.effective_date BETWEEN
                 per.effective_start_date AND per.effective_end_date )
      AND     b.pa_routing_history_id = (SELECT max(pa_routing_history_id)
                                          FROM ghr_pa_routing_history
                                          WHERE pa_request_id = a.pa_request_id);
     CURSOR c_processed_action_exists(c_person_id NUMBER, c_effective_date DATE) IS
     SELECT 'Y'
     FROM   ghr_pa_requests
     WHERE  effective_date between (c_effective_date - 14) and (c_effective_date + 1)
     AND    person_id = c_person_id
     AND    (substr(first_noa_code,1,1) = '5' OR first_noa_code IN ('760','762','765'))
     AND    pa_notification_id IS NOT NULL
     AND    (NVL(first_noa_cancel_or_correct,'C') <> 'CANCEL' OR NVL(second_noa_cancel_or_correct,'C') <> 'CANCEL');

BEGIN
    l_proc		:=  'verify_355_business_rule';
    hr_utility.set_location( 'Entering : ' || l_proc, 10);
    OPEN c_pending_action_exists(p_person_id,p_effective_date);
    FETCH c_pending_action_exists into l_dummy;
    IF c_pending_action_exists%NOTFOUND THEN
        close c_pending_action_exists;
	    OPEN c_processed_action_exists(p_person_id,p_effective_date);
        FETCH c_processed_action_exists into l_dummy;
	    IF c_processed_action_exists%NOTFOUND THEN
		    p_result := 'NOT EXISTS';
        ELSE
            p_result := 'EXISTS';
        END IF;
        CLOSE c_processed_action_exists;
    ELSE
       p_result := 'EXISTS';
       close c_pending_action_exists;
    END IF;

    hr_utility.set_location( 'Leaving : ' || l_proc, 20);
EXCEPTION
  WHEN OTHERS THEN
      p_result := NULL;
      raise;
END verify_355_business_rule;


END GHR_PROC_FUT_MT;

/
