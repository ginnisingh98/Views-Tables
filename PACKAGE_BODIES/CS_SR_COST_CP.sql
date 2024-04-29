--------------------------------------------------------
--  DDL for Package Body CS_SR_COST_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_COST_CP" AS
/* $Header: csvcstpgb.pls 120.4.12010000.3 2008/09/25 23:03:38 bkanimoz ship $ */
  g_pkg_name CONSTANT VARCHAR2(30) := 'CS_SR_COST_CP';

PROCEDURE Write_cost_Output
(
  p_cost_batch_size               IN              NUMBER
, p_request_id                    IN              NUMBER
, p_worker_id                     IN              NUMBER := NULL
);

PROCEDURE Create_Cost
(
  errbuf                          OUT NOCOPY    VARCHAR2
, errcode                         OUT NOCOPY    NUMBER
, p_api_version_number            IN            NUMBER
, p_init_msg_list                 IN            VARCHAR2
, p_commit                        IN            VARCHAR2
, p_validation_level              IN            NUMBER
, p_creation_from_date	          IN	        VARCHAR2
, p_creation_to_date		  IN	        VARCHAR2
, p_sr_status			  IN	        VARCHAR2
, p_number_of_workers             IN            NUMBER  --Number of Worker Threads to be started
, p_cost_batch_size               IN            NUMBER  --Number of Service Requests to be processed in a batch
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(60) := 'CREATE_COST_FOR_SERVICEREQUESTS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255):= 'csvcstpgb.pls' || L_API_NAME_FULL || '.';

TYPE t_worker_conc_req_arr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

L_EXC_COST_WARNING             EXCEPTION;

x_msg_index_out                 NUMBER;
x_msg_count                     NUMBER;
x_msg_data                      VARCHAR2(1000);
x_return_status                 VARCHAR2(1);

-- Request id of the current
-- concurrent request.

l_request_id                    NUMBER;

-- Request data used to identify if the concurrent
-- request is started for the first time or if it
-- is resumed from a PAUSED state.

l_request_data                  VARCHAR2(1);

-- variables defined for holding the validated
-- value of the dates that are received as
-- VARCHARs from the concurrent program UI

l_creation_from_date            DATE;
l_creation_to_date              DATE;


l_row_count                     NUMBER;
l_ret                           BOOLEAN;

-- Actual number of worker concurrent requests
-- to be started based on the number of SRs in
-- the costset.

l_number_of_workers             NUMBER := p_number_of_workers;

-- Table of request ids of the worker concurrent request

l_worker_conc_req_arr           t_worker_conc_req_arr;

-- Variables holding the status information of each
-- worker concurrent request

l_worker_conc_req_phase         VARCHAR2(100);
l_worker_conc_req_status        VARCHAR2(100);
l_worker_conc_req_dev_phase     VARCHAR2(100);
l_worker_conc_req_dev_status    VARCHAR2(100);
l_worker_conc_req_message       VARCHAR2(512);

-- Variables holding the status information of
-- the parent concurrent request

l_main_conc_req_phase           VARCHAR2(100);
l_main_conc_req_status          VARCHAR2(100);
l_main_conc_req_dev_phase       VARCHAR2(100);
l_main_conc_req_dev_status      VARCHAR2(100);
l_main_conc_req_message         VARCHAR2(512);
l_child_message                 VARCHAR2(4000);

CURSOR c_child_request
(
  c_request_id    NUMBER
)
IS
  SELECT
    request_id
  FROM
    fnd_concurrent_requests
  WHERE
    parent_request_id = c_request_id;



BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

--logging the input parameters

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start_time'
    , 'The start time is ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'errbuf:' || errbuf
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'errcode:' || errcode
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_validation_level:' || p_validation_level
    );
     FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_creation_from_date' ||p_creation_from_date
    );
      FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 8'
    , 'p_creation_to_date' ||p_creation_to_date
    );
     FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 9'
    , 'p_sr_status:' || p_sr_status
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 10'
    , 'p_number_of_workers:' || p_number_of_workers
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 11'
    , 'p_cost_batch_size:' ||p_cost_batch_size
    );
END IF;


   IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , g_pkg_name
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ---

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'get_request_info_start'
    , 'Getting Current Concurrent Request ID '
    );
  END IF;



  -- preserving this concurrent request's
  -- request_id in a local variable

   -- Read the value from REQUEST_DATA.  If this is the
   -- first run of the program, then this value will be
   -- null.
   -- Otherwise, this will be the value that we passed to
   -- SET_REQ_GLOBALS on the previous run.


  l_request_id   := fnd_global.conc_request_id;
  l_request_data := fnd_conc_global.request_data; --This package is used for submitting sub-requests from PL/SQL concurrent programs.

IF l_request_data IS NULL then

    -- This portion of the code is executed when the concurrent request is
    -- invokedby the user. This time, the request data is NULL indicating
    -- that the request is started newly.



  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'cleanup_start'
      , 'deleting rows in staging table that were not cleared earlier'
      );
    END IF;

  ----------------------------------------------------------------------------
    -- Cleanup process: Delete all the rows in the staging table corresponding
    -- to completed concurrent programs that have been left behind by an earlier
    -- execution of this concurrent program.
    ----------------------------------------------------------------------------


	    DELETE cs_cost_staging
	    WHERE
	      concurrent_request_id IN
	      (
	      SELECT
		request_id
	      FROM
		fnd_concurrent_requests r
	      , fnd_concurrent_programs p
	      WHERE
		  r.phase_code              = 'C'
	      AND p.concurrent_program_id   = r.concurrent_program_id
	      AND p.concurrent_program_name = 'CSCSTPG'
	      AND p.application_id          = 170
	      );

    l_row_count := SQL%ROWCOUNT;


IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'cleanup_end'
      , 'after deleting rows in staging table that were not cleared earlier '
        || l_row_count || ' rows'
      );
    END IF;
 -- Committing the changes in order to make
    -- the rows unavailable to all sessions.
    COMMIT;





       IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_validate_param_start'
      , 'Calling procedure to validate cost  parameters'
      );
    END IF;


    -- calling a private procedure to perform validations on all the
    -- cost parameters and throw corresponding exceptions in case
    -- there are any errors

-- this procedure will validate the params  p_creation_from_date, p_creation_to_date and p_sr_status


   Validate_params(   p_creation_from_date  =>  p_creation_from_date
		    , p_creation_to_date    =>  p_creation_to_date
		    , p_sr_status	    =>  p_sr_status
		    , x_creation_from_date  =>  l_creation_from_date
		    , x_creation_to_date    =>  l_creation_to_date
		    , x_msg_count           =>  x_msg_count
                    , x_msg_data            =>  x_msg_data
		    );



    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_validate_param_end'
      , 'After calling procedure to validate cost parameters'
      );
    END IF;




    ----------------------------------------------------------------------------
    -- Preparation of Staging Table Data and Submission of Child Requests
    ----------------------------------------------------------------------------

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_form_and_exec_statement_start'
      , 'Calling procedure to form and execute statement to fill staging table'
      );
    END IF;



    Form_And_Exec_Statement -- this will insert data into the staging table
    (
      p_sr_status             => p_sr_status
    , p_creation_from_date    => l_creation_from_date
    , p_creation_to_date      => l_creation_to_date
    , p_number_of_workers     => l_number_of_workers
    , p_cost_batch_size      => p_cost_batch_size
    , p_request_id            => l_request_id
    , p_row_count             => l_row_count
    );

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'call_form_and_exec_statement_end'
      , 'After calling procedure to form and execute statement to '
        || 'fill staging table ' || l_row_count
      );
    END IF;



  IF l_row_count = 0
    THEN
      -- If there were no SRs selected, return
      -- from the concurrent program with a warning

	      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
	      THEN
		FND_LOG.String
		(
		  FND_LOG.level_unexpected
		, L_LOG_MODULE || 'no_rows'
		, 'There were no rows picked up. Row count was ' || l_row_count
		);
	      END IF ;

	      FND_MESSAGE.Set_Name('CS', 'CS_SR_NO_SRS_TO_CREATE_COST');
	      FND_MSG_PUB.ADD;

	      RAISE L_EXC_COST_WARNING;
    END IF;

    -- Start worker concurrent programs:

  FOR
      j IN 1..l_number_of_workers
    LOOP
      l_worker_conc_req_arr(j) := FND_REQUEST.Submit_Request
      (
        application => 'CS'
      , program     => 'CSCSTPGW'
      , description => TO_CHAR(j)
      , start_time  => NULL
      , sub_request => TRUE
      , argument1   => 1-- p_api_version_number
      , argument2   => 'T'--p_init_msg_list
      , argument3   => 'T'--p_commit
      , argument4   => 100--p_validation_level
      , argument5   => j                             -- p_worker_id
      , argument6   => 1000--p_cost_batch_size
      , argument7   => l_request_id                  -- p_cost_set_id
      );



      IF
        l_worker_conc_req_arr(j) = 0
      THEN
        -- If the worker request was not created successfully
        -- raise an unexpected exception and terminate the
        -- process.

		IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
		THEN
		  FND_LOG.String
		  (
		    FND_LOG.level_unexpected
		  , L_LOG_MODULE || 'create_workers_error'
		  , 'Failed while starting worker concurrent request'
		  );
		END IF;

		FND_MESSAGE.Set_Name('CS', 'CS_SR_SUBMIT_CHILD_FAILED');
		FND_MSG_PUB.ADD;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

	      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	      THEN
		FND_LOG.String
		(
		  FND_LOG.level_statement
		, L_LOG_MODULE || 'create_workers_doing'
		, 'After starting worker ' || l_worker_conc_req_arr(j)
		);
	      END IF;
    END LOOP;

    -- Committing so that the worker concurrent program that
    -- was submitted above is started by the concurrent manager.

    COMMIT;



  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'create_workers_end'
      , 'After starting all worker concurrent requests'
      );
    END IF;

    ---

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'move_parent_to_paused_start'
      , 'Moving parent concurrent request to paused status'
      );
    END IF;

    COMMIT;

 IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'move_parent_to_paused_end'
      , 'After moving parent concurrent request to paused status'
      );
    END IF;


     fnd_conc_global.set_req_globals
    (
      conc_status  => 'PAUSED'
    , request_data => '1'
    );



elsif l_request_data IS NOT NULL then --ELSIF l_request_data IS NOT NULL then



 -- If the concurrent request is restarted from the PAUSED state,
    -- this portion of the code is executed. When all the child
    -- requests have completed their work, (their PHASE_CODE
    -- is 'COMPLETED') the concurrent manager restarts the parent. This
    -- time, the request_data returns a Non NULL value and so this
    -- portion of the code is executed.



    l_main_conc_req_dev_status := 'NORMAL';

    -- check status of worker concurrent request
    -- to arrive at the parent request's
    -- completion status

    FOR r_child_request IN c_child_request(l_request_id)
    LOOP
		      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		      THEN
			FND_LOG.String
			(
			  FND_LOG.level_statement
			, L_LOG_MODULE || 'collect_a_child_status'
			, 'Worker Concurrent Request No : ' || r_child_request.request_id
			);
		      END IF;

	      IF  FND_CONCURRENT.Get_Request_Status
		  (
		    request_id => r_child_request.request_id
		  , phase      => l_worker_conc_req_phase
		  , status     => l_worker_conc_req_status
		  , dev_phase  => l_worker_conc_req_dev_phase
		  , dev_status => l_worker_conc_req_dev_status
		  , message    => l_worker_conc_req_message
		  )
	      THEN
		IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		THEN
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'child_return_status'
		  , 'l_worker_conc_req_phase:' || l_worker_conc_req_phase
		  );
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'child_return_status'
		  , 'l_worker_conc_req_status:' || l_worker_conc_req_status
		  );
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'child_return_status'
		  , 'l_worker_conc_req_dev_phase:' || l_worker_conc_req_dev_phase
		  );
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'child_return_status'
		  , 'l_worker_conc_req_dev_status:' || l_worker_conc_req_dev_status
		  );
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'child_return_status'
		  , 'l_worker_conc_req_message:' || l_worker_conc_req_message
		  );
		END IF;

		IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		THEN
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'resolve_main_dev_status_start'
		  , 'Resolving l_main_conc_req_dev_status'
		  );
		END IF;

        -- If the current worker has completed its work, based
        -- on the return status of the worker, mark the completion
        -- status of the main concurrent request.

		IF l_worker_conc_req_dev_status <> 'NORMAL'
		THEN
		  IF  l_main_conc_req_dev_status IN ('WARNING', 'NORMAL')
		  AND l_worker_conc_req_dev_status IN ('ERROR', 'DELETED', 'TERMINATED')
		  THEN
		    l_main_conc_req_dev_status := 'ERROR';
		    l_child_message            := l_worker_conc_req_message;
		  ELSIF l_main_conc_req_dev_status = 'NORMAL'
		  AND l_worker_conc_req_dev_status = 'WARNING'
		  THEN
		    l_main_conc_req_dev_status := 'WARNING';
		    l_child_message            := l_worker_conc_req_message;
		  END IF;
		END IF;

        IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		THEN
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'resolve_main_dev_status_end'
		  , 'After resolving l_main_conc_req_dev_status:'
		    || l_main_conc_req_dev_status
		  );
		  FND_LOG.String
		  (
		    FND_LOG.level_statement
		  , L_LOG_MODULE || 'resolve_main_dev_status_end'
		  , 'After resolving l_main_conc_req_dev_status - child_message :'
		    || l_child_message
		  );
		END IF;

      ELSE

        -- There was a failure while collecting a child request
        -- status, raising an unexpected exception

			IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
			THEN
			  FND_LOG.String
			  (
			    FND_LOG.level_unexpected
			  , L_LOG_MODULE || 'collect_child_status_failed'
			  , 'Call to function fnd_concurrent.get_request_status failed. '
			    || l_main_conc_req_message
			  );
			END IF;

			FND_MESSAGE.Set_Name('CS', 'CS_SR_GET_CHILD_STAT_FAILED');
			FND_MESSAGE.Set_Token('ERROR', SQLERRM);
			FND_MSG_PUB.ADD;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;


	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'collect_child_status_end'
	      , 'After collecting child completion status'
	      );
	    END IF;





	   IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'Write_cost_Output_start'
      , 'Calling procedure to Write_cost_Output'
      );
    END IF;



--added newly
    Write_cost_Output
    (
      p_cost_batch_size  => p_cost_batch_size
    , p_request_id       => l_request_id
    );


	    -- Cleaning up the staging table

	    /*DELETE cs_cost_staging
	    WHERE
	      concurrent_request_id = l_request_id;

	    l_row_count := SQL%ROWCOUNT;*/

	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'staging_table_cleanup_end'
	      , 'After cleaning up staging table ' || l_row_count
	      );
	    END IF;

    ---

	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'act_on_ret_status_start'
	      , 'Acting on the main concurrent request return status:'
		|| l_main_conc_req_dev_status
	      );
	    END IF;


    ---

 -- commented now

     -- Cleaning up the staging table

   /* DELETE cs_cost_staging
    WHERE
      concurrent_request_id = l_request_id;

    l_row_count := SQL%ROWCOUNT;*/


     -- Set the completion status of the main concurrent request
    -- by raising corresponding exceptions.

	    IF l_main_conc_req_dev_status = 'WARNING'
	    THEN
	      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_RET_STAT');
	      FND_MSG_PUB.ADD;

	      RAISE L_EXC_COST_WARNING;
	    ELSIF l_main_conc_req_dev_status = 'ERROR'
	    THEN
	      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_RET_STAT');
	      FND_MSG_PUB.ADD;

	      RAISE FND_API.G_EXC_ERROR;
	    END IF;


	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'act_on_ret_status_end'
	      , 'after Acting on the main concurrent request return status:'
		|| l_main_conc_req_dev_status
	      );
	    END IF;

    ---

	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'set_comp_stat_normal_start'
	      , 'Setting completion status for parent concurrent request as NORMAL'
	      );
	    END IF;

    ---
 -- Setting the completion status of this concurrent
    -- request as COMPLETED NORMALLY

    l_ret := fnd_concurrent.set_completion_status
    (
      'NORMAL'
    , ' '
    );

	       IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'set_comp_stat_normal_end'
	      , 'After setting completion status for parent concurrent '
		|| 'request as NORMAL'
	      );
	    END IF;



end if;


	 IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    IF  FND_CONCURRENT.Get_Request_Status
		(
		  request_id => l_request_id
		, phase      => l_main_conc_req_phase
		, status     => l_main_conc_req_status
		, dev_phase  => l_main_conc_req_dev_phase
		, dev_status => l_main_conc_req_dev_status
		, message    => l_main_conc_req_message
		)
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_procedure
	      , L_LOG_MODULE || 'request_status_1'
	      , 'l_main_conc_req_phase:' || l_main_conc_req_phase
	      );
	      FND_LOG.String
	      (
		FND_LOG.level_procedure
	      , L_LOG_MODULE || 'request_status_2'
	      , 'l_main_conc_req_status:' || l_main_conc_req_status
	      );
	      FND_LOG.String
	      (
		FND_LOG.level_procedure
	      , L_LOG_MODULE || 'request_status_3'
	      , 'l_main_conc_req_dev_phase:' || l_main_conc_req_dev_phase
	      );
	      FND_LOG.String
	      (
		FND_LOG.level_procedure
	      , L_LOG_MODULE || 'request_status_4'
	      , 'l_main_conc_req_dev_status:' || l_main_conc_req_dev_status
	      );
	      FND_LOG.String
	      (
		FND_LOG.level_procedure
	      , L_LOG_MODULE || 'request_status_5'
	      , 'l_main_conc_req_message:' || l_main_conc_req_message
	      );
	    END IF;
	  END IF ;

  ---

	  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    (
	      FND_LOG.level_procedure
	    , L_LOG_MODULE || 'end'
	    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
	      || x_return_status
	    );
	    FND_LOG.String
	    (
	      FND_LOG.level_procedure
	    , L_LOG_MODULE || 'end_time'
	    , 'The end time is ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
	    );
	  END IF ;



EXCEPTION

  WHEN L_EXC_COST_WARNING THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- setting the completion status as WARNING since
    -- there was a warning in the execution of this
    -- request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'WARNING'
    , SUBSTR(x_msg_data, 1, 240)
    );

--Added for bug 7168775
fnd_file.put_line(fnd_file.log, 'Error encountered is : ' || x_msg_data || ' [Index:' || x_msg_index_out || ']');


    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'error'
      , 'Inside WHEN L_EXC_COST_WARNING of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- setting the completion status as ERROR since
    -- there was an error in the execution of this
    -- request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

--Added for bug 7168775
fnd_file.put_line(fnd_file.log, 'Error encountered is : ' || x_msg_data || ' [Index:' || x_msg_index_out || ']');

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'error'
      , 'Inside WHEN FND_API.G_EXC_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- setting the completion status as ERROR since
    -- there was an unexpected error in the execution
    -- of this request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

--Added for bug 7168775
fnd_file.put_line(fnd_file.log, 'Error encountered is : ' || x_msg_data || ' [Index:' || x_msg_index_out || ']');


    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          FND_LOG.String
          (
            FND_LOG.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_COST_MAIN_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    -- setting the completion status as ERROR since
    -- there was an unexpected error in the execution
    -- of this request.

    x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count > 0
    THEN
      FND_MSG_PUB.Get
      (
        p_msg_index     => 1
      , p_encoded       => 'F'
      , p_data          => x_msg_data
      , p_msg_index_out => x_msg_index_out
      );
    END IF;

    l_ret := fnd_concurrent.set_completion_status
    (
      'ERROR'
    , SUBSTR(x_msg_data, 1, 240)
    );

--Added for bug 7168775
fnd_file.put_line(fnd_file.log, 'Error encountered is : ' || x_msg_data || ' [Index:' || x_msg_index_out || ']');


    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;


END create_cost;

---------------------------------
-- VALIDATE_PARAMS
---------------------------------


PROCEDURE   Validate_params
                   (
                     p_creation_from_date   IN varchar2
		    , p_creation_to_date    IN varchar2
		    , p_sr_status	    IN VARCHAR2
		    , x_creation_from_date  OUT NOCOPY  DATE
		    , x_creation_to_date    OUT NOCOPY  DATE
		    , x_msg_count	    OUT NOCOPY  NUMBER
                    , x_msg_data            OUT NOCOPY  VARCHAR2
		    ) IS

L_API_NAME      CONSTANT VARCHAR2(30) := 'VALIDATE_COST_PARAMS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_creation_from_date            DATE;
l_creation_to_date              DATE;
l_prompt                VARCHAR2(250);

TIME_23_59_59 	CONSTANT  NUMBER := 1 - 1 / (24*60*59);


BEGIN


  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'check_blind_cost_start'
    , 'checking for blind search'
    );
  END IF;


IF  p_creation_from_date IS NULL
OR  p_creation_to_date   IS NULL
OR  p_sr_status		 IS NULL
THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'no_params'
      , 'no parameters were supplied to the Concurrent program'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_NO_COST_PARAMS');
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_ERROR;



END IF;


  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'check_blind_cost_end'
    , 'after checking for blind search'
    );
  END IF;

IF p_creation_from_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_start_1'
      , 'checking if p_creation_from_date is in the format '
        || fnd_date.user_mask
      );

    END IF;

    -- Check if p_creation_from_date is of the format
    -- as maintained in the profile option ICX_DATE_FORMAT
    -- and if not, throw an error.

    x_creation_from_date := fnd_date.string_to_date
    (
      p_creation_from_date
    , fnd_date.user_mask
    );

    IF x_creation_from_date IS NULL
    THEN
	      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
	      THEN
		FND_LOG.String
		(
		  FND_LOG.level_unexpected
		, L_LOG_MODULE || 'crtfrmdt_format_invalid'
		, 'format of field p_creation_from_date is invalid. should be  '
		  || fnd_date.user_mask
		);

	      END IF ;

	      SELECT
		form_left_prompt
	      INTO
		l_prompt
	      FROM
		fnd_descr_flex_col_usage_vl
	      WHERE
		  end_user_column_name       = 'P_CREATION_FROM_DATE'
	      AND application_id             = 170
	      AND descriptive_flexfield_name = '$SRS$.CSCSTPG';

	      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_FORMAT_ERR');
	      FND_MESSAGE.Set_Token('DATEFIELDNAME', l_prompt);
	      FND_MESSAGE.Set_Token('FORMAT', fnd_date.user_mask);
	      FND_MSG_PUB.ADD;

	      RAISE FND_API.G_EXC_ERROR;




    END IF;

    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'check_date_format_end_1'
      , 'after checking if p_creation_from_date is in the format '
        || fnd_date.user_mask
      );
    END IF;
END IF;--p_creation_from_date IS NOT NULL

  ------------------------------------------------------

  IF p_creation_to_date IS NOT NULL
  THEN
	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'check_date_format_start_2'
	      , 'checking if p_creation_to_date is in the format '
		|| fnd_date.user_mask
	      );
	    END IF;

    -- Check if p_creation_to_date is of the format
    -- as maintained in the profile option ICX_DATE_FORMAT
    -- and if not, throw an error.

    x_creation_to_date := fnd_date.string_to_date
    (
      p_creation_to_date
    , fnd_date.user_mask
    );

	    IF x_creation_to_date IS NULL
	    THEN
		      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
		      THEN
			FND_LOG.String
			(
			  FND_LOG.level_unexpected
			, L_LOG_MODULE || 'crttodt_format_invalid'
			, 'format of field p_creation_to_date is invalid. should be ' ||
			    fnd_date.user_mask
			);
		      END IF ;

		      SELECT
			form_left_prompt
		      INTO
			l_prompt
		      FROM
			fnd_descr_flex_col_usage_vl
		      WHERE
			end_user_column_name         = 'P_CREATION_TO_DATE'
		      AND application_id             = 170
		      AND descriptive_flexfield_name = '$SRS$.CSCSTPG';

		      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_FORMAT_ERR');
		      FND_MESSAGE.Set_Token('DATEFIELDNAME', l_prompt);
		      FND_MESSAGE.Set_Token('FORMAT', fnd_date.user_mask);
		      FND_MSG_PUB.ADD;

		      RAISE FND_API.G_EXC_ERROR;



	    END IF;

	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'check_date_format_end_2'
	      , 'after checking if p_creation_to_date is in the format ' ||
		fnd_date.user_mask
	      );
	    END IF;

    ---

    -- If the user_mask does not contain the time, then appending the time
    -- 23:59:59 to the date so that the whole day is covered. This is to
    -- take care of conditions where the from and to dates are the same day.
    --
    -- For ex., if the from date is 1-jan-1999 and to date is also 1-jan-1999,
    -- since there is no time given for these dates, the condition "where
    -- creation_date >= from_date and creation_date <= to_date" will not
    -- return any rows because if the creation date is 1-jan-1999 12:00:01,
    -- the condition creation_date >= from_date will be satisfied but the
    -- condition creation_date <= to_date will not be satisfied. In this
    -- situation, no rows will be picked up. To correct this issue, if the
    -- to_date contains the time 23:59:59, both the conditions will be
    -- satisfied.

	    IF TRUNC(x_creation_to_date) = x_creation_to_date
	    THEN
		      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		      THEN
			FND_LOG.String
			(
			  FND_LOG.level_statement
			, L_LOG_MODULE || 'add_time_to_todate_start'
			, 'adding time to x_creation_to_date if it does not have time'
			);
		      END IF;

	      x_creation_to_date := x_creation_to_date + TIME_23_59_59;

		      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
		      THEN
			FND_LOG.String
			(
			  FND_LOG.level_statement
			, L_LOG_MODULE || 'add_time_to_todate_end'
			, 'adding time to x_creation_to_date if it does not have time ' ||
			    TO_CHAR(x_creation_to_date, 'DD-MON-YYYY HH24:MI:SS')
			);
		      END IF;
	    END IF;
  END IF;--p_creation_to_date IS NOT NULL



  ---

  IF  x_creation_from_date IS NOT NULL
  AND x_creation_to_date IS NOT NULL
  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'date_crossvalid_start_1'
      , 'doing cross field validations x_creation_from_date '
        || '> x_creation_to_date '
      );
    END IF;

    -- if both x_creation_from_date and x_creation_to_date are
    -- entered then x_creation_from_date should be before
    -- x_creation_to_date

    IF x_creation_from_date > x_creation_to_date
    THEN
	      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
	      THEN
		FND_LOG.String
		(
		  FND_LOG.level_unexpected
		, L_LOG_MODULE || 'crtfrmdt_after_crttodt'
		, 'it is invalid to have x_creation_from_date > x_creation_to_date'
		);
	      END IF ;

	      FND_MESSAGE.Set_Name('CS', 'CS_SR_DATE_VALUE_ERR');

	      SELECT
		form_left_prompt
	      INTO
		l_prompt
	      FROM
		fnd_descr_flex_col_usage_vl
	      WHERE
		  end_user_column_name       = 'P_CREATION_FROM_DATE'
	      AND application_id             = 170
	      AND descriptive_flexfield_name = '$SRS$.CSCSTPG';

	      FND_MESSAGE.Set_Token('DATEFIELDNAME1', l_prompt);

	      SELECT
		form_left_prompt
	      INTO
		l_prompt
	      FROM
		fnd_descr_flex_col_usage_vl
	      WHERE
		  end_user_column_name       = 'P_CREATION_TO_DATE'
	      AND application_id             = 170
	      AND descriptive_flexfield_name = '$SRS$.CSCSTPG';

	      FND_MESSAGE.Set_Token('DATEFIELDNAME2', l_prompt);
	      FND_MSG_PUB.ADD;

	      RAISE FND_API.G_EXC_ERROR;
    END IF;

	    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	    THEN
	      FND_LOG.String
	      (
		FND_LOG.level_statement
	      , L_LOG_MODULE || 'date_crossvalid_end_1'
	      , 'after doing cross field validations x_creation_from_date > '
		|| 'x_creation_to_date '
	      );
	    END IF;
  END IF;

  ---



END Validate_params;


---------------------------------------
    -- Form_And_Exec_Statement
---------------------------------------

PROCEDURE Form_And_Exec_Statement
(
  p_creation_from_date            IN              DATE
, p_creation_to_date              IN              DATE
, p_sr_status		          IN              VARCHAR2
, p_number_of_workers             IN OUT NOCOPY   NUMBER
, p_cost_batch_size               IN              NUMBER
, p_request_id                    IN              NUMBER
, p_row_count                     OUT NOCOPY      NUMBER
)
IS

L_API_NAME      CONSTANT VARCHAR2(30) := 'FORM_AND_EXEC_STATEMENT';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';


CURSOR  get_estimate_id IS
SELECT  ced.estimate_detail_id
FROM    cs_incidents_all_b    cia
       ,cs_incident_statuses  cis
       ,cs_estimate_details   ced
WHERE Nvl(cis.close_flag,'N') IN  (decode( p_sr_status,'OPEN','N','CLOSED','Y'   ,'ALL',Nvl(cis.close_flag,'N')))
and cis.incident_subtype='INC'
and     cia.incident_status_id = cis.incident_status_id
and     cia.incident_id  = ced.incident_id
--and      ced.estimate_Detail_id =115538
and     trunc(cia.creation_date) between trunc(p_creation_from_date) and trunc(p_creation_to_date);

l_number_of_workers             NUMBER;
l_row_count                     NUMBER;
l_estimate_detail_id            NUMBER;

BEGIN

   OPEN get_estimate_id;
   LOOP
   FETCH get_estimate_id INTO l_estimate_detail_id;
   EXIT WHEN get_estimate_id%NOTFOUND;

   INSERT INTO cs_cost_staging
	   (
		estimate_detail_id,
		worker_id,
		concurrent_request_id
	    )
    VALUES
	   (
	       l_estimate_Detail_id,
	       NULL,
	       p_request_id
	   );

    COMMIT;
    END LOOP;

p_row_count :=get_estimate_id%rowcount;

CLOSE get_estimate_id;


COMMIT;


-- Computing the number of worker concurrent
  -- requests required for purging the SRs.
  -- The approach followed to decide on howmany
  -- workers is required is as follows:
  -- 1. If the no. of rows < batch size, only 1 worker
  --    is required for processing the cost set.
  -- 2. If the no. of rows > batch size, ceil(batch_size / no_of_rows)
  --    is the no. of workers required for processing the cost set.
  --    But if this is more than the no. of workers asked for,
  --    no. of workers is = p_number_of_workers. Otherwise, it will
  --    be the result of the above formula.



  IF p_row_count <= p_cost_batch_size
  THEN
    l_number_of_workers := 1;
  ELSIF p_row_count > p_cost_batch_size
  THEN
    l_number_of_workers := LEAST
    (
        p_number_of_workers
    , CEIL(p_row_count / p_cost_batch_size)
    );
  END IF;

p_number_of_workers := l_number_of_workers;


  UPDATE cs_cost_staging
  SET
    worker_id = MOD
    (
      ROWNUM - 1
    , l_number_of_workers
    ) + 1;

  l_row_count := SQL%ROWCOUNT;

  COMMIT;


END Form_And_Exec_Statement;


---------------------------------------
    -- COST_WORKER
---------------------------------------
-- -----------------------------------------------------------------------------
-- Modification History
-- Date        Name      Desc
-- --------    --------- ----------------------------------------------------------
-- 04-Jun-2008 bkanimoz  Bug 7146881.Additional condition added to
--                       Update the Staging table status to 'S' only if cost record exist
--                       exists in costing table for the passed estimate_detail_id

-- -----------------------------------------------------------------------------

PROCEDURE Cost_Worker
(
  errbuf                          OUT NOCOPY VARCHAR2
, errcode                         OUT NOCOPY NUMBER
, p_api_version_number            IN NUMBER
, p_init_msg_list                 IN VARCHAR2
, p_commit                        IN VARCHAR2
, p_validation_level              IN NUMBER
, p_worker_id                     IN NUMBER
, p_cost_batch_size               IN NUMBER
, p_cost_set_id                   IN NUMBER
)
IS


L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'COST_WORKER';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

x_msg_count                 NUMBER;
x_msg_index_out             NUMBER;
x_msg_data                  VARCHAR2(1000);
x_return_status             VARCHAR2(1);
x_object_version_number     NUMBER;
l_Cost_rec		    cs_cost_details_pub.COST_REC_TYPE;
x_cost_id		    NUMBER;

l_conc_req_phase            VARCHAR2(100);
l_conc_req_status           VARCHAR2(100);
l_conc_req_dev_phase        VARCHAR2(100);
l_conc_req_dev_status       VARCHAR2(100);
l_conc_req_message          VARCHAR2(512);

l_request_id                NUMBER;

l_processing_set_id         NUMBER;
l_row_count                 NUMBER;
l_ret                       BOOLEAN;
l_has_any_batch_failed      BOOLEAN := FALSE;

l_message                  VARCHAR2(1000);
p_estimate_detail_id       NUMBER;

-- PL/SQL table to hold the incident_ids retrieved
-- from the staging table, a batch at a time.

TYPE t_incident_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_incident_id_tbl           t_incident_id_tbl;

-- PL/SQL table to hold the incident ids that had
-- errors while performing validations with other
-- products before purging the SRs. This table is
-- used only when one of these procedures encountered
-- an ORACLE EXCEPTION.

l_err_incident_id_tbl       t_incident_id_tbl;

-- PL/SQL table to hold the error messages retrieved
-- from the staging table when one of the procedures
-- in the worker encounters an ORACLE EXCEPTION.
-- This table is only used under these circumstances.

TYPE t_cost_error_message_tbl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
l_cost_error_message_tbl   t_cost_error_message_tbl;


CURSOR c_staging IS
  SELECT
    estimate_detail_id
  FROM
    cs_cost_staging
  WHERE
      worker_id             = p_worker_id
  AND concurrent_request_id = p_cost_set_id
  AND status IS NULL;
--Bug fix for 7146881
CURSOR c_check_cost IS
SELECT cost_id
FROM   cs_cost_details
WHERE  estimate_detail_id = p_estimate_detail_id;

 j              NUMBER :=1;
 l_estimate_id  NUMBER;
 l_temp_count   NUMBER;
 l_cost_id      NUMBER;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- capturing the request id of the
  -- worker thread into a local variable.

  l_request_id := fnd_global.conc_request_id;

  IF  p_worker_id                     IS NULL
  OR  p_cost_set_id                 IS NULL
  OR  p_cost_batch_size              IS NULL


  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'worker_params_not_enuf'
      , 'no parameters were supplied to the cost worker program'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_PARAM_NULL');
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   BEGIN
    SELECT
      1
    INTO
      l_row_count
    FROM
      fnd_concurrent_requests r
    , fnd_concurrent_programs p
    WHERE
        r.request_id              = p_cost_set_id
    AND p.concurrent_program_id   = r.concurrent_program_id
    AND p.concurrent_program_name = 'CSCSTPG'
    AND p.application_id          = 170
    AND r.status_code             <> 'C';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_unexpected
        , L_LOG_MODULE || 'worker_purgset_invalid'
        , 'invalid cost set id supplied to the worker concurrent program'
        );
      END IF ;

      FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKER_COSTSET_INV');
      FND_MSG_PUB.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

    -- Opening the cursor inside the loop to avoid
    -- the ORA-1555 snapshot too old problem

begin
 OPEN c_staging;
LOOP

    -- main loop of the worker thread that collects
    -- incident_ids that need to be inserted into a
    -- pl/sql table, a batch at a time and inserts
    -- into the global temp table and calls the
    -- SR delete API.


    FETCH   c_staging  INTO l_temp_count;
    exit when c_staging%notfound;

    --BULK COLLECT
    --  LIMIT    p_cost_batch_size;
    --    EXIT WHEN c_staging%notfound;
     l_cost_rec.estimate_detail_id := l_temp_count;

--for j in 1..l_incident_id_tbl.COUNT loop

      CS_COST_DETAILS_PVT.Create_cost_details
	(
		p_api_version			=> 1.0		,
		p_init_msg_list			=> 'T'	,
		p_commit			=> 'T'	,
		p_validation_level		=> 100,
		x_return_status			=> x_return_status   ,
		x_msg_count			=> x_msg_count	,
		x_object_version_number		=> x_object_version_number,
		x_msg_data			=> x_msg_data	,
		x_cost_id			=> x_cost_id	,
		p_resp_appl_id			=> FND_GLOBAL.RESP_APPL_ID,
		p_resp_id			=> FND_GLOBAL.RESP_ID,
		p_user_id			=> FND_GLOBAL.USER_ID,
		p_login_id			=> NULL		,
		p_transaction_control		=> 'T'	,
		p_Cost_Rec			=>  l_cost_rec	,
		p_cost_creation_override	=> 'N'
	);



	IF x_return_status = FND_API.G_RET_STS_SUCCESS  then
	  p_estimate_detail_id := l_temp_count;

	   OPEN c_check_cost;
           FETCH c_check_cost into l_cost_id;
		   if  c_check_cost%notfound then
			 UPDATE cs_cost_staging
			 SET  status      = 'E'
			     ,error_message =  x_msg_data
			 WHERE estimate_detail_id  = l_temp_count ;
		   else
			 UPDATE cs_cost_staging
			 SET    status      = 'S'
			 WHERE  estimate_detail_id  = l_temp_count ;
		   end if;
	   CLOSE c_check_cost;

	   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	      OR    x_return_status = FND_API.G_RET_STS_ERROR

		-- If there was an error or unexpected error
		-- while executing the SR delete API

	      THEN

	            UPDATE cs_cost_staging
		    SET
		    status      = 'E'
		  , error_message =  x_msg_data
		  WHERE
		      estimate_detail_id  = l_temp_count
		  AND NVL(status, 'S') = 'S';

         END IF;

END LOOP;
exception
WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'exception : '||sqlerrm);
end;
--END LOOP;

CLOSE c_staging;


  Write_cost_Output
    (
      p_cost_batch_size  => p_cost_batch_size
    , p_request_id       => p_cost_set_id
    , p_worker_id        => p_worker_id
    );

END COST_WORKER;


PROCEDURE Write_cost_Output
(
  p_cost_batch_size     IN   NUMBER
, p_request_id           IN   NUMBER
, p_worker_id            IN   NUMBER := NULL
)
IS
--------------------------------------------------------------------------------

L_API_NAME      CONSTANT VARCHAR2(300) := 'Write_cost_Output';
L_API_NAME_FULL CONSTANT VARCHAR2(300) := g_pkg_name || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(1000) := 'cs.plsql.' || L_API_NAME_FULL || '.';

TYPE t_varchar_arr IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE t_number_arr  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Cursor used to fetch all the SRs for which cost could not created due to business reasons as indicated
-- by the various validation routines, along with
-- the basic information of those SRs, to be used
-- to generate a report of such SRs.

CURSOR c_cost_staging_err
IS
      SELECT
         cia.incident_number       incident_number
	,ced.estimate_detail_id    estimate_detail_id
	,ced.line_number           line_number
--	, css.error_message		   cost_error_message
--,	substr(css.error_message,instr(css.error_message,':',1)+1)  cost_error_message
,case when length(css.error_message)>120 then
substr(css.error_message,1,75)
else
substr(css.error_message,instr(css.error_message,':',1)+1)
end
--  , p.party_number          customer_number
  --, i.segment1              item_number
--  , t.summary               summary

  FROM
    cs_cost_staging   css
  , cs_estimate_Details         ced
  , cs_incidents_all_b         cia
--  , mtl_system_items_b          i
 -- , hz_parties                  p
  WHERE
      css.status          = 'E'
	  and css.ESTIMATE_DETAIL_ID = ced.ESTIMATE_DETAIL_ID
	  and ced.incident_id = cia.incident_id
	  and css.CONCURRENT_REQUEST_ID =p_request_id
	  and css.worker_id=NVL(1, css.worker_id) ;




l_incident_number_arr           t_number_arr;
l_estimate_detail_id_arr       t_number_arr;
l_line_number_arr               t_varchar_arr;
--l_summary_arr                   t_varchar_arr;
l_cost_error_message_arr       t_varchar_arr;

l_row_count                     NUMBER;
l_report_caption                VARCHAR2(4000);
l_text                          VARCHAR2(4000);
l_error_code_loc                NUMBER;
l_error_message_loc             NUMBER;
l_error_message_text            VARCHAR2(4000);

l_exec_count                    NUMBER := 0;

BEGIN



  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'sr_submit_count_start'
    , 'Getting number of SRs submitted for Cost Creation'
    );
  END IF;

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<html><body>'
  );



  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_COST_RESULT'
  );

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<h3>' || l_report_caption
    || '</h3><table border cellspacing=0 cellpadding=5 width=40%>'
  );


  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_COST_SUBMIT_COUNT'
  );

  -- Query to find out the total number of SRs
  -- submitted for COST

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_cost_staging s
  WHERE
    s.worker_id = NVL(p_worker_id, s.worker_id);

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<tr><td><b>' || l_report_caption || '</b></td><td><b>'
    || l_row_count || '</b></td></tr>'
  );




  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_COST_SUCCESS_COUNT'
  );

  -- Query to find out the total number of SRs
  -- successfully Created

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_cost_staging s
  WHERE
      status = 'S'
  AND s.worker_id = NVL(p_worker_id, s.worker_id);

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '<tr><td><b>' || l_report_caption || '</b></td><td><font color=green><b>'
    || l_row_count || '</b></font></td></tr>'
  );



  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_COST_NOTDONE_COUNT'
  );

  -- Query to find out the total number of SRs
  -- successfully cost Created

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_cost_staging s
  WHERE
      status IS NULL
  AND s.worker_id = NVL(p_worker_id, s.worker_id);

  IF l_row_count > 0

    -- if there were some rows that were not
    -- processed, display that too in the report.

  THEN
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<tr><td><b>' || l_report_caption
      || '</b></td><td><font color=blue><b>'
      || l_row_count || '</b></font></td></tr>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_5'
      , '<tr><td><b>' || l_report_caption
        || '</b></td><td><font color=blue><b>' || l_row_count
        || '</b></font></td></tr>'
      );
    END IF;
  END IF;




  l_report_caption := FND_MESSAGE.Get_String
  (
    'CS'
  , 'CS_SR_COST_FAILURE_COUNT'
  );

  -- Query to find out the total number of SRs
  -- failed while attempting to create cost due to
  -- failure in validations

  SELECT
    count(1)
  INTO
    l_row_count
  FROM
    cs_cost_staging s
  WHERE
      status = 'E'
  AND s.worker_id = NVL(p_worker_id, s.worker_id);

  IF l_row_count > 0

    -- if there were some rows that failed during
    -- processing, display that in the report.

  THEN
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<tr><td><b>' || l_report_caption
      || '</b></td><td><font color=red><b>' || l_row_count
      || '</b></font></td></tr></table>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_6'
      , '<tr><td><b>' || l_report_caption
        || '</b></td><td><font color=red><b>' || l_row_count
        || '</b></font></td></tr></table>'
      );
    END IF;
  END IF;



  IF l_row_count > 0

    -- if there are any rows in the staging
    -- table with cost_status = E

  THEN
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'sr_failure_report_start'
      , 'Listing all SRs that failed with details and error message'
      );
    END IF;

    -- Starting to print the report on all the SRs that failed
    -- cost creation due to business reasons along with the vital details

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<h3>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_7'
      , '<h3>'
      );
    END IF;

    l_report_caption := FND_MESSAGE.Get_String
    (
      'CS'
    , 'CS_SR_FAILED_ESTIMATE_REPORT'
    );
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , l_report_caption
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_8'
      , l_report_caption
      );
    END IF;

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '</h3>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_9'
      , '</h3>'
      );
    END IF;

    ---


    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '<table border cellspacing=0 width=100%><tr>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_10'
      , '<table border cellspacing=0 width=100%><tr>'
      );
    END IF;

    l_report_caption := FND_MESSAGE.Get_String
    (
      'CS'
    , 'CS_SR_COST_FAILED_RPT_HEAD'
    );
    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , l_report_caption
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_11'
      , l_report_caption
      );
    END IF;

    fnd_file.put_line
    (
      FND_FILE.OUTPUT
    , '</tr>'
    );
    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'html_output_12'
      , '</tr>'
      );
    END IF;

    -- Opening cursor on staging table that lists
    -- all the SRs that failed due to business reasons
    -- along with the vital details of the SR

    OPEN c_cost_staging_err;

    -- Loop that retrieves the rows from the staging table
    -- in batches and prints the output file.

    LOOP
      FETCH c_cost_staging_err
      BULK COLLECT INTO
        l_incident_number_arr
      , l_estimate_detail_id_arr
      , l_line_number_arr
      --, l_summary_arr
      , l_cost_error_message_arr
      LIMIT p_cost_batch_size;

      IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
      THEN
        FND_LOG.String
        (
          FND_LOG.level_statement
        , L_LOG_MODULE || 'report_fetch_count'
        , 'Fetched ' || l_incident_number_arr.COUNT
          || ' rows during this execution'
        );
      END IF;

      IF l_incident_number_arr.COUNT > 0
      THEN

        -- Inner loop that inserts the current batch of
        -- SRs into the output file. Here, it is assumed
        -- that the cost_error_message field contains
        -- messages in the format
        -- <product>:<message code>~<concurrent request text-message>
        -- using which the message text is retrieved from
        -- the message dictionary.

        FOR j IN l_incident_number_arr.FIRST..l_incident_number_arr.LAST
        LOOP
          fnd_file.put_line
          (
            FND_FILE.OUTPUT
          , '<tr>'
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'html_output_13'
            , '<tr>'
            );
          END IF;

          l_text := '<td>' || l_incident_number_arr(j)
                    ||  '</td><td>' || l_estimate_detail_id_arr(j)
                    ||  '</td><td>' || NVL(l_line_number_arr(j), '-')
--                    ||  '</td><td>' || l_summary_arr(j)
                    ||  '</td><td>';

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'compute_text'
            , 'framing l_text = ' || l_text
            );
          END IF;

          l_error_code_loc := INSTR
          (
            l_cost_error_message_arr(j)
          , ':'
          , 1
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'compute_text_1'
            , 'getting l_error_code_loc = ' || l_error_code_loc
            );
          END IF;

          l_error_message_loc := INSTR
          (
            l_cost_error_message_arr(j)
          , '~'
          , 1
          );


	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'compute_text_2'
            , 'getting l_error_message_loc = ' || l_error_message_loc
            );
          END IF;

          IF l_error_message_loc > 0 THEN


            l_error_message_text := FND_MESSAGE.Get_String

            (
              SUBSTR
              (
                  l_cost_error_message_arr(j)
              , 1
              , l_error_code_loc - 1
              )
            , SUBSTR
              (
                  l_cost_error_message_arr(j)
              , l_error_code_loc + 1
              , l_error_message_loc - l_error_code_loc - 1
              )
            )
            || ' - '
            || SUBSTR
            (
              l_cost_error_message_arr(j)
            , l_error_message_loc + 1
            );

            IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
            THEN
              FND_LOG.String
              (
                FND_LOG.level_statement
              , L_LOG_MODULE || 'compute_text_3.1'
              , 'getting l_error_message_text = ' || l_error_message_text
              );
            END IF;
          ELSIF l_error_message_loc <= 0
          THEN
            l_error_message_text := FND_MESSAGE.Get_String
            (
              SUBSTR
              (
                l_cost_error_message_arr(j)
              , 1
              , l_error_code_loc - 1
              )
            , SUBSTR
              (
                l_cost_error_message_arr(j)
              , l_error_code_loc + 1
              )
            );

            IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
            THEN
              FND_LOG.String
              (
                FND_LOG.level_statement
              , L_LOG_MODULE || 'compute_text_3.2'
              , 'getting l_error_message_text = ' || l_error_message_text
              );
            END IF;
          END IF;

          l_text := l_text || NVL(l_error_message_text, '-') || '</td>';

          fnd_file.put_line
          (
            FND_FILE.OUTPUT
          , l_text
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'html_output_14'
            , l_text
            );
          END IF;

          fnd_file.put_line
          (
            FND_FILE.OUTPUT
          , '</tr>'
          );

          IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
          THEN
            FND_LOG.String
            (
              FND_LOG.level_statement
            , L_LOG_MODULE || 'html_output_15'
            , '</tr>'
            );
          END IF;
        END LOOP;
      END IF;

      EXIT WHEN c_cost_staging_err%NOTFOUND;
    END LOOP;

    CLOSE c_cost_staging_err;



    IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_statement
      , L_LOG_MODULE || 'sr_failure_report_end'
      , 'After listing all SRs that failed with details and error message'
      );
    END IF;
  END IF;

  fnd_file.put_line
  (
    FND_FILE.OUTPUT
  , '</table></body></html>'
  );
  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'html_output_16'
    , '</table></body></html>'
    );
  END IF;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with Success'
    );
  END IF ;
END Write_cost_Output;
--------------------------------------------------------------------------------

END CS_SR_COST_CP ;


/
