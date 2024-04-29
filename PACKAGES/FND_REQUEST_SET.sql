--------------------------------------------------------
--  DDL for Package FND_REQUEST_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_REQUEST_SET" AUTHID CURRENT_USER as
/* $Header: AFRSSUBS.pls 120.2.12010000.2 2014/06/30 19:35:10 ckclark ship $ */


  -- Name
  --   STANDARD_STAGE_EVALUATION
  --
  -- Purpose
  --   Standard evaluation function for Request Set Stages.
  --   Returns 'E' if any errors occurred in the stage requests.
  --   Returns 'W' if there were any Warnings and no Errors in the
  --   stage requests.
  --   Returns 'S' if all requests were sucessfull.
  --   Will also return 'S' if there are no requests to evaluate.
  --
  function standard_stage_evaluation return varchar2;

  --
  -- These values can be used to tune the amount of time the standard
  -- stage evaluation function will wait on running requests
  -- stage_looptimes = the number of times it will loop, waiting for the request to finish
  -- stage_sleeptime = the number of seconds it will sleep
  -- Set these values higher if you are experiencing requests that take a longer time to complete.
  --
  stage_looptimes        integer := 5;
  stage_sleeptime        integer := 10;


  -- Name
  --   STAGE_REQUEST_INFO
  --
  -- Purpose
  --   Cursor to be used in stage functions to retrieve
  --   info about the critical requests in the stage.
  --
  cursor stage_request_info is
    select
      r.request_id,
      a.application_short_name program_appl_short_name,
      p.concurrent_program_name program_short_name,
      decode(r.status_code, 'C', 'S', 'G', 'W', 'R', 'R', 'E') exit_status,
      r.post_request_status,
      r.req_information request_data
    from fnd_concurrent_requests r,
         fnd_application a,
         fnd_concurrent_programs p
    where r.program_application_id = a.application_id
      and r.program_application_id = p.application_id
      and r.concurrent_program_id = p.concurrent_program_id
      and r.parent_request_id = fnd_global.conc_request_id
      and r.critical = 'Y'
    order by request_id;


  -- Name
  --   GET_STAGE_PARAMETER
  --
  -- Purpose
  --  Used by stage functions to retrieve parameter
  --  values for the current stage.
  --
  function get_stage_parameter(name in varchar2) return varchar2;


  -- Name
  --   FNDRSSUB
  -- Purpose
  --   Request set master program.  Submit request set
  --   stages and collect results.
  --
  -- Arguments
  --   errbuff  - Completion message.
  --   retcode  - 0 = Success, 1 = Waring, 2 = Failure
  --   appl_id  - Set Application ID
  --   set_id   - Request Set ID

  procedure fndrssub(
            errbuf    out nocopy varchar2,
            retcode   out nocopy number,
	    appl_id   in number,
	    set_id    in number);


  -- Name
  --   FNDRSSTG
  -- Purpose
  --   Request set stage master program.  Submit request set
  --   programs and collect results.
  --
  -- Arguments
  --   errbuff  - Completion message.
  --   retcode  - 0 = Success, 1 = Waring, 2 = Failure
  --   appl_id  - Set Application ID
  --   set_id   - Request Set ID
  --   stage_id - Request Set Stage ID

  procedure fndrsstg(
            errbuf    out nocopy varchar2,
            retcode   out nocopy number,
            appl_id   in number,
            set_id    in number,
            stage_id  in number,
            parent_id in number,
            restart_flag in number default 0);

end FND_REQUEST_SET;

/
