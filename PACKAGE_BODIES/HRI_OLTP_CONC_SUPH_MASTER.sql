--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_CONC_SUPH_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_CONC_SUPH_MASTER" AS
/* $Header: hriocshh.pkb 120.0 2005/05/29 07:27:23 appldev noship $ */

error_launching_thread        EXCEPTION;
request_error                 EXCEPTION;

-- Write to log if debugging is set
PROCEDURE dbg(p_message IN VARCHAR2) IS

BEGIN
  HRI_BPL_CONC_LOG.dbg(p_message);
END dbg;

FUNCTION get_stage RETURN VARCHAR2 IS

-- Used to store the return value of fnd_conc_global.request_data. If
-- it is non null then this indicates that the process has returned
-- from a paused state.
  l_request_data    VARCHAR2(240);

-- Variables to hold results of cursor
  l_program_name    VARCHAR2(240);
  l_phase_code      VARCHAR2(30);
  l_status_code     VARCHAR2(30);

-- Return variable holding process stage
  l_child           VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_process_stage   VARCHAR2(240);

-- Get request name and status
  CURSOR request_csr(v_request_id  NUMBER) IS
  SELECT
   fcp.concurrent_program_name
  ,fcr.phase_code
  ,fcr.status_code
  FROM
   fnd_concurrent_requests  fcr
  ,fnd_concurrent_programs  fcp
  WHERE fcr.request_id = v_request_id
  AND fcr.concurrent_program_id = fcp.concurrent_program_id
  AND fcr.program_application_id = fcp.application_id;

BEGIN

-- Call fnd_conc_global.request_data, to see if this program is re-entering
-- after being paused.
  l_request_data := fnd_conc_global.request_data;

-- Check whether a previous child request is completed
  IF l_request_data IS NOT NULL THEN

  -- A child request has just completed - get the details
    OPEN request_csr(l_request_data);
    FETCH request_csr INTO
      l_program_name,
      l_phase_code,
      l_status_code;
    CLOSE request_csr;

  -- Check if error
    IF (l_status_code = 'E') THEN
      l_status := 'ERROR';
    ELSE
      l_status := 'COMPLETE';
    END IF;

  -- Check which child ran
    IF (l_program_name = 'HRI_CS_ASGN_SUPH_EVENTS_CT') THEN
      l_child := 'FIRST';
    ELSE
      l_child := 'SECOND';
    END IF;

  -- Set the return variable
    l_process_stage := l_child || '_CHILD_' || l_status;

  ELSE

  -- Initial call
    l_process_stage := 'INITIAL';

  END IF;

  RETURN l_process_stage;

END get_stage;

PROCEDURE launch_process(p_program_name   IN VARCHAR2,
                         p_argument1      IN VARCHAR2 DEFAULT NULL,
                         p_argument2      IN VARCHAR2 DEFAULT NULL,
                         p_argument3      IN VARCHAR2 DEFAULT NULL,
                         p_argument4      IN VARCHAR2 DEFAULT NULL,
                         p_argument5      IN VARCHAR2 DEFAULT NULL) IS

  l_request_id   NUMBER;

BEGIN

  l_request_id := fnd_request.submit_request
                   (application => 'HRI'
                   ,program     => p_program_name
                   ,sub_request => TRUE
                   ,argument1   => p_argument1
                   ,argument2   => p_argument2
                   ,argument3   => p_argument3
                   ,argument4   => p_argument4
                   ,argument5   => p_argument5);

-- Raise exception if submission failed
  IF l_request_id = 0 then
    RAISE error_launching_thread;
  END IF;

-- Wait for process to complete
  fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                  request_data=> TO_CHAR(l_request_id));

END launch_process;

-- ----------------------------------------------------------------------------
-- Entry point to be called from the concurrent manager
-- ----------------------------------------------------------------------------
PROCEDURE load_all_managers(errbuf          OUT NOCOPY  VARCHAR2,
                            retcode         OUT NOCOPY VARCHAR2,
                            p_chunk_size    IN NUMBER,
                            p_start_date    IN VARCHAR2,
                            p_end_date      IN VARCHAR2,
                            p_full_refresh  IN VARCHAR2) IS

  l_business_group_id  NUMBER;
  l_stage              VARCHAR2(30);

BEGIN

-- Initialize business group id
  l_business_group_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');

-- Get the process stage
  l_stage := get_stage;

dbg('Procedure start - phase:  ' || l_stage);

-- Take action corresponding to the process stage
  IF (l_stage = 'INITIAL') THEN

  -- Initial stage - submit first child process
    launch_process
     (p_program_name => 'HRI_CS_ASGN_SUPH_EVENTS_CT',
      p_argument1    => 'HRI_OPL_SUPH_EVENTS',
      p_argument2    => to_char(l_business_group_id),
      p_argument3    => p_start_date,
      p_argument4    => fnd_date.date_to_canonical(trunc(sysdate)),
      p_argument5    => p_full_refresh);

dbg('Launched helper request');

  ELSIF (l_stage = 'FIRST_CHILD_COMPLETE') THEN

  -- First child process is complete - submit second
    launch_process
     (p_program_name => 'HRI_CS_SUPH',
      p_argument1    => 'HRI_OPL_SUPH_HST',
      p_argument2    => to_char(l_business_group_id),
      p_argument3    => p_start_date,
      p_argument4    => fnd_date.date_to_canonical(trunc(sysdate)),
      p_argument5    => p_full_refresh);

dbg('Launched main request');

  ELSIF (l_stage = 'SECOND_CHILD_COMPLETE') THEN

  -- Both child processes complete - log success
    null;

  ELSE

  -- An error occurred
    RAISE request_error;

  END IF;

EXCEPTION
  --
  WHEN OTHERS THEN
    --
dbg('Exception');
    errbuf := SQLERRM;
    retcode := SQLCODE;
    --
    RAISE;
    --
END load_all_managers;

END hri_oltp_conc_suph_master;

/
