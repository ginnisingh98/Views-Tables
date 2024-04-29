--------------------------------------------------------
--  DDL for Package Body ONT_ACTIVITY_SUM_ORDER_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_ACTIVITY_SUM_ORDER_PURGE" AS
/* $Header: OEXACSUB.pls 120.2 2005/11/10 04:20:14 ddey noship $ */

 PROCEDURE activity_summarizer IS

 l_count number := 0;
 l_temp_name varchar2(100);
 l_requested_by fnd_concurrent_requests.requested_by%TYPE;
 l_count_logged_user number := 0;

    CURSOR c_concurrent_request IS
	SELECT  count(*) total
	  FROM fnd_concurrent_requests
	 WHERE phase_code = 'C'
	   AND program_application_id = 660
	   AND concurrent_program_id = (SELECT concurrent_program_id
					  FROM fnd_concurrent_programs
					 WHERE concurrent_program_name = 'ORDPUR'
					   AND application_id = 660)
	   AND requested_by = FND_GLOBAL.USER_ID;



BEGIN

 --
 -- FND_CONCURRENT_REQUEST table count
 -- The Number of times the Order Purge Concurrect Request is Submitted
 --

  l_temp_name := FND_MESSAGE.GET_STRING('ONT', 'ONT_CONC_REQUESTS');


	SELECT count(*)
	  INTO l_count
	  FROM fnd_concurrent_requests
	 WHERE phase_code = 'C'
	   AND program_application_id = 660
	   AND concurrent_program_id = (SELECT concurrent_program_id
					  FROM fnd_concurrent_programs
					 WHERE concurrent_program_name = 'ORDPUR'
					   AND application_id = 660);

   -- Insert this name, value pair in summarizer table by using summarizer API 'insert_row'

   fnd_conc_summarizer.insert_row(l_temp_name, to_char(l_count));


  --
  -- FND_CONCURRENT_REQUEST
  -- The Number of times the Purge Order Request was run by logged in user.
  --

   l_temp_name := fnd_message.get_string('ONT', 'ONT_PURGE_ORD_USER_COUNT');

       OPEN c_concurrent_request;
       FETCH c_concurrent_request INTO l_count_logged_user;

    -- Insert this name, value pair in summarizer table by using summarizer API 'insert_row'
      fnd_conc_summarizer.insert_row(l_temp_name, to_char(l_count_logged_user));
       CLOSE c_concurrent_request;

  --
  -- FND_CONCURRENT_PROCESSES
  -- The Number Concurrect Process is Submitted
  --


      l_temp_name := fnd_message.get_string('ONT', 'ONT_CONC_PROCESSES');


	SELECT COUNT (*)
	  INTO l_count
	  FROM fnd_concurrent_processes
	 WHERE process_status_code NOT IN ('A', 'C', 'T', 'M')
	   AND concurrent_process_id IN
		     (SELECT controlling_manager
			FROM fnd_concurrent_requests
		       WHERE phase_code = 'C'
			 AND program_application_id = 660
			 AND concurrent_program_id =
				   (SELECT concurrent_program_id
				      FROM fnd_concurrent_programs
				     WHERE concurrent_program_name = 'ORDPUR'
				       AND application_id = 660));


   -- Insert this name, value pair in summarizer table by using summarizer API 'insert_row'

     fnd_conc_summarizer.insert_row(l_temp_name, to_char(l_count));

  --
  -- FND_CRM_HISTORY
  -- The Conflict Resolution History Count
  --

    l_temp_name := fnd_message.get_string('FND', 'FND_CRM_HISTORY');

  	SELECT count(*)
	INTO l_count
	FROM fnd_crm_history
	WHERE work_start < sysdate -1 ;

     fnd_conc_summarizer.insert_row(l_temp_name, to_char(l_count));

  --
  -- FND_TM_EVENTS
  -- The Transaction Management Events Count
  --

   l_temp_name := fnd_message.get_string('FND', 'FND_TM_EVENTS');

	SELECT COUNT (*)
	  INTO l_count
	  FROM fnd_tm_events
	 WHERE TIMESTAMP <   SYSDATE - 1
	   AND (program_application_id, concurrent_program_id) IN
		     (SELECT application_id, concurrent_program_id
			FROM fnd_concurrent_programs
		       WHERE concurrent_program_name = 'ORDPUR'
			 AND application_id = 660);


    fnd_conc_summarizer.insert_row(l_temp_name, to_char(l_count));

 EXCEPTION WHEN OTHERS THEN
  null;
 END activity_summarizer;

END ont_activity_sum_order_purge;

/
