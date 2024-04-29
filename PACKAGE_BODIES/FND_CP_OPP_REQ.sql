--------------------------------------------------------
--  DDL for Package Body FND_CP_OPP_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_OPP_REQ" AS
/* $Header: AFCPOPRB.pls 120.11.12010000.8 2019/08/02 20:27:00 pferguso ship $ */

-- Default timeout values for waiting on a response to a request (seconds)
TIMEOUT1   constant number := 120;
TIMEOUT2   constant number := 300;


-- Default wait time when OPP service is still initializing
DEFAULT_SLEEP constant number := 30;

--
-- published_request
--
-- Given a request id, determine if this request has publishing actions
--
function published_request(reqid in number) return boolean is

prog_name       varchar2(30) := null;
appl_name       varchar2(30) := null;

begin

  select fcp.concurrent_program_name, a.application_short_name
    into prog_name, appl_name
    from fnd_concurrent_requests fcr,
         fnd_concurrent_programs fcp, fnd_application a
    where fcr.request_id = reqid
    and fcp.concurrent_program_id = fcr.concurrent_program_id
    and fcp.application_id = fcr.program_application_id
    and fcp.application_id = a.application_id
    and rownum = 1;


   if prog_name = 'FNDREPRINT' and appl_name = 'FND' then
     return TRUE;
   end if;


   return fnd_conc_sswa.layout_enabled(appl_name, prog_name);

end;



-- ============================
-- OPP service procedures
-- ============================


--
-- update_actions_table
--
-- Used by the OPP service to update the FND_CONC_PP_ACTIONS table
-- The table is only updated if it has not been previously updated by another process
--
-- reqid   - Concurrent request id
-- procid  - Concurrent process id of the service. FND_CONC_PP_ACTIONS.PROCESSOR_ID will be updated
--           with this value for all pp actions for this request
-- success - Y if the table was updated, N if the table has already been updated.
--
procedure update_actions_table(reqid in number, procid in number,
				success out NOCOPY varchar2) is

  cnt   number;
begin
    select count(*)
	  into cnt
	  from fnd_conc_pp_actions
	  where concurrent_request_id = reqid
	  and processor_id is not null;

	if cnt > 0 then
	  success := 'N';
	  return;
    end if;


	update fnd_conc_pp_actions
	  set processor_id = procid
	  where concurrent_request_id = reqid;

	success := 'Y';

end;





-- =======================================
-- Request-Processing Manager procedures
-- =======================================


--
-- wait_for_reply
-- Wait for a reply message on the OPP AQ
--
-- cpid    - Concurrent process id of the receiver
-- timeout - timeout in seconds
-- result  - SUCCESS if success message received from OPP service
--           TIMEOUT if timeout occurred
--           ERROR if error occurred receiving message, errmsg will contain error message
--           FAILED if failure message received from OPP service. errmsg will contain reason.
-- errmsg  - Reason for failure
--
procedure wait_for_reply(cpid    in number,
                         reqid   in number,
                         timeout in number,
			 result  out NOCOPY varchar,
			 errmsg  out NOCOPY varchar) is

flag       varchar2(1);
msgtype    number;
message    varchar2(240);
params     varchar2(2000);
sender     varchar2(30);
msggroup   varchar2(30);
end_time   date;

begin

  end_time := sysdate + (timeout / (24 * 60 * 60));

  loop

    fnd_cp_opp_ipc.get_message(cpid, flag, msgtype, msggroup, message, params, sender, timeout, reqid);

    -- if flag = N then a timeout or exception occurred
    if flag <> 'Y' then

      -- timed out waiting
      if flag = 'T' then
        result := 'TIMEOUT';
      else
        result := 'ERROR';
	errmsg := message;
      end if;

      return;
    end if;

    -- flag == 'Y', received a message
    if message = 'SUCCESS' then

      -- make sure the request id matches
      if params = reqid then
        result := 'SUCCESS';
	return;
      else
	 -- Yikes, the request id does not match, log an error message
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	   fnd_message.set_name('FND','CONC-OPP MESSAGE MISMATCH');
	   fnd_message.set_token('REQID', reqid, FALSE);
	   fnd_message.set_token('MGRID', cpid, FALSE);
	   fnd_log.message(FND_LOG.LEVEL_ERROR,
	                   'fnd.plsql.fnd_cp_opp_req.wait_for_reply', TRUE);
	 end if;

	 -- debug
         if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
	                'fnd.plsql.fnd_cp_opp_req.wait_for_reply',
	                'Message mismatch in wait_for_reply, expected ' || reqid || ' but got ' || params);

         end if;
      end if;

    else
      -- otherwise the postprocessing failed
      result := 'FAILED';
      errmsg := params;
      return;
    end if;

    -- If time still left continue the loop
    if sysdate >= end_time then
      result := 'TIMEOUT';
      return;
    end if;

  end loop;

end;


--
-- update_req_pp_status
--
-- Helper procedure for postprocess
-- Updates FND_CONCURRENT_REQUESTS with the post-processing start date, end date and status
--
procedure update_req_pp_status(reqid in number, status in varchar2) is


begin

 if status = PP_PENDING then

   update fnd_concurrent_requests
    set pp_start_date = sysdate, post_request_status = status
	where request_id = reqid;

 else

  update fnd_concurrent_requests
    set pp_end_date = sysdate, post_request_status = status
	where request_id = reqid;

 end if;



end;



--
-- update_pp_action
--
-- Helper procedure for postprocess
-- Updates fnd_conc_pp_actions, setting the processor_id for a request,
-- so the post-processor will not pick it up and process it
--
procedure update_pp_action(reqid in number, cpid in number) is

pragma autonomous_transaction;

begin
  update fnd_conc_pp_actions
    set processor_id = cpid
	where concurrent_request_id = reqid;

  commit;

end;



function get_one_subscriber(localnode in varchar2) return varchar2 is

node_name  fnd_concurrent_processes.node_name%type;
subscriber varchar2(30);

begin
   -- Check to see if a service is running on the local node
   if (fnd_cp_opp_ipc.check_group_subscribers(localnode) >= 1) then
	  return localnode;
   end if;

   -- if not, select a random service
   subscriber := fnd_cp_opp_ipc.select_random_subscriber;
   if subscriber is null then
	  return null;
   end if;

   -- use that service's node
   begin
	  select fcp.node_name
	    into node_name
		from fnd_concurrent_processes fcp
	    where fcp.concurrent_process_id = subscriber
	    and fcp.process_status_code in ('A', 'Z');
	exception
	  when no_data_found then
	    return null;
   end;
   return node_name;


end;


--
-- select_postprocessor
--
-- Looks for a post-processor service to post-process a request
-- First uses the same node name the manager is running on.
-- If a PP service is running there, it returns that node name.
-- If one is not found, it picks a random PP service.
-- Errcode will be 0 if a post-processor was found.
-- If no post-processor is available, or an error occurs, errcode
-- will be < 0.
--
-- Note: Can only be called from a concurrent manager
--

--
-- bug6056627 - reimplementation of fix in 5358039
-- Instead of using session id from environment, use request_id
-- to find out the host name.  Previous to this change, spawned
-- programs were not able to use OPP as it could not find which
-- manager was running the program.  With this change, regardless
-- of the program type, it will always find the host.  Now, all
-- types of programs can use OPP.
--

procedure select_postprocessor(opp_name out NOCOPY varchar2,
				errcode out NOCOPY number,
				requestid  in number) is

 node_name   fnd_concurrent_requests.outfile_node_name%type;
 init_count  number;
 sleeptime   number;
 prof_buffer varchar2(32);

begin

  -- Select our local node
  begin
	select fcr.outfile_node_name
	  into node_name
	  from fnd_concurrent_requests fcr
	  where request_id = requestid;
   exception
     when no_data_found then
	   opp_name := null;
	   errcode := -1;
	   return;
   end;


  -- Find a subscriber
  opp_name := get_one_subscriber(node_name);
  if opp_name is not null then
	 errcode := 0;
	 return;
  end if;

  -- No subscribers found right now. Check to see if the OPP service is still initializing
  select count(*)
  into init_count
  from fnd_concurrent_processes fcp,
       fnd_concurrent_queues fcq,
       fnd_cp_services fcs
  where fcs.service_handle = 'FNDOPP'
  and fcs.service_id = fcq.manager_type
  and fcq.concurrent_queue_id = fcp.concurrent_queue_id
  and fcq.application_id = fcp.queue_application_id
  and fcp.process_status_code = 'Z';

  -- If no services are initializing, nothing we can do.
  if init_count = 0 then
	 errcode := -2;
	 return;
  end if;

  -- At this point at least one OPP service is still initializing, wait a little while for it...
  fnd_profile.get('CONC_PP_INIT_DELAY', prof_buffer);
  if prof_buffer is null then
    sleeptime := DEFAULT_SLEEP;
  else
    sleeptime := to_number(prof_buffer);
  end if;

  dbms_lock.sleep(sleeptime);

  -- And try one more time...
  opp_name := get_one_subscriber(node_name);
  if opp_name is null then
	 errcode := -3;
  end if;

end;



--
-- postprocess
--
-- Post-process a request
-- Used by request-processing managers to submit a request to the post-processor
--
-- reqid        - Request id to postprocess
-- groupid      - Group to send request to
-- success_flag - Y if request was postprocessed successfully, N otherwise
-- errmsg       - Reason for failure
--
procedure postprocess(reqid        in number,
                      groupid      in varchar2,
			  success_flag out NOCOPY varchar2,
			  errmsg       out NOCOPY varchar2) is


cpid         number;
result       varchar2(30);
pp_id        number;
prof_buffer  varchar2(32);
timeout      number;

begin

  success_flag := 'N';

  update_req_pp_status(reqid, PP_PENDING);

--
-- bug6056627
-- Use request-id to find the controlling manager.  Spawned programs
-- may call OPP.  Depending on rquest_id, instead of session_id allows
-- controlling manager to be always derrived.
--
  begin
	select fcr.controlling_manager
	  into cpid
	  from fnd_concurrent_requests fcr
	  where request_id = reqid;
   exception
     when no_data_found then
	   errmsg := fnd_message.get_string('FND', 'CONC-PP CMGR ONLY');
	   return ;
  end;




  fnd_cp_opp_ipc.send_request(groupid, cpid, reqid, '');

  fnd_profile.get('CONC_PP_RESPONSE_TIMEOUT', prof_buffer);
  if prof_buffer is null then
    timeout := TIMEOUT1;
  else
    timeout := to_number(prof_buffer);
  end if;

  wait_for_reply(cpid, reqid, timeout, result, errmsg);

  if result = 'SUCCESS' then
    update_req_pp_status(reqid, PP_COMPLETE);
    success_flag := 'Y';
    return;
  end if;

  if result = 'ERROR' or result = 'FAILED' then
    update_req_pp_status(reqid, PP_ERROR);
    return;
  end if;



  -- at this point we have a timeout
  -- see if the postprocessor has started on it

  select processor_id
	  into pp_id
	  from fnd_conc_pp_actions
	  where concurrent_request_id = reqid
	  and action_type = 6
	  and sequence = 1;

  -- has not started yet
  if pp_id is null then

	  -- ??? what to do here?
	  -- update the pp_actions table so the post-processor will not process this req
	  update_pp_action(reqid, cpid);
	  update_req_pp_status(reqid, PP_ERROR);
	  errmsg := fnd_message.get_string('FND', 'CONC-PP NO RESPONSE');
	  return;

  else
	  -- processing has started, wait some more

	  prof_buffer := null;
          fnd_profile.get('CONC_PP_PROCESS_TIMEOUT', prof_buffer);
          if prof_buffer is null then
              timeout := TIMEOUT2;
          else
              timeout := to_number(prof_buffer);
          end if;

	  wait_for_reply(cpid, reqid, timeout, result, errmsg);


      if result = 'SUCCESS' then
	    update_req_pp_status(reqid, PP_COMPLETE);
	    success_flag := 'Y';
        return;
      end if;

      if result = 'ERROR' or result = 'FAILED' then
	    update_req_pp_status(reqid, PP_ERROR);
        return;
      end if;

      -- timed out again??
	  -- send terminate command to OPP service
	  -- BUG 9062358 GSI:GLOBAL ENQUEUE SERVICES DEADLOCK DETECTED
	  -- fnd_cp_opp_cmd.terminate_opp_request(reqid, cpid);
	  fnd_cp_opp_cmd.terminate_opp_request_this_txn(reqid, cpid);


	  update_req_pp_status(reqid, PP_TIMEOUT);
	  errmsg := fnd_message.get_string('FND', 'CONC-PP TIMEOUT');
	  return;

  end if;



exception
  when others then
    update_req_pp_status(reqid, PP_ERROR);
	errmsg := sqlerrm;
    return;

end;


-- Added for bug Bug 6275963
--
-- published_request
--
-- Used to determine whether the request is a published request. If the request is a
-- simple reprint request of a published request in that case parent request id is passed
-- as the published request in the out parameter pub_req_id
--
-- reqid        - Concurrent request id
-- is_published - boolean variable to return whether the request is a published request
-- pub_reqid    - Request id of the published request. Incase the request passed as reqid
--                is a simple reprint of a published request then the parent request id
--                will be passed as pub_reqid else it will be same as reqid

procedure published_request (reqid in number,
                             is_published out NOCOPY boolean,
			     pub_req_id out NOCOPY number) is


prog_name       varchar2(30) := null;
appl_name       varchar2(50) := null;
parent_req_id	varchar2(240) :=null;
output_exists	number;
action_type	number;

begin

-- Select Parent_request_id (argument1) for the FNDREPRINT request

  is_published := false;

  select fcp.concurrent_program_name, a.application_short_name, argument1
    into prog_name, appl_name, parent_req_id
    from fnd_concurrent_requests fcr,
         fnd_concurrent_programs fcp, fnd_application a
    where fcr.request_id = reqid
    and fcp.concurrent_program_id = fcr.concurrent_program_id
    and fcp.application_id = fcr.program_application_id
    and fcp.application_id = a.application_id
    and rownum = 1;

   if (prog_name = 'FNDREPRINT' and appl_name = 'FND') then


   -- Check if the request itself is a published request, if not then check
   -- whether the parent request is a published request.

     select count(1) into action_type from fnd_conc_pp_actions
     where concurrent_request_id=reqid and action_type=6;

     select count(1) into output_exists from fnd_conc_req_outputs
     where concurrent_request_id = decode(action_type, 1, reqid, to_number(parent_req_id))
     and file_size>0;

     if (action_type=1 and output_exists=1) then
        is_published := true;
	pub_req_id := reqid;
     elsif(action_type=0 and output_exists=1) then
        is_published := true;
        pub_req_id := to_number(parent_req_id);
     end if;

   else
     select count(1) into output_exists from fnd_conc_req_outputs
	where concurrent_request_id = reqid
        and file_size>0;

     if ( output_exists=1) then
	   pub_req_id := reqid;
           is_published := true;
     end if;
   end if;

end;
-- ============================
-- Reprint procedures
-- ============================


--
-- adjust_outfile
--
-- Used by the Republish/Reprint program to properly set its output file for
-- republishing and/or reprinting
--
-- cur_reqid    - Current request id
-- prev_reqid   - Request to reprint/republish
-- success_flag - Y if output file updated, N otherwise
-- errmsg       - Reason for failure
--
procedure adjust_outfile(cur_reqid    in number,
                         prev_reqid   in number,
				 success_flag out NOCOPY varchar2,
				 errmsg       out NOCOPY varchar2) is

pragma autonomous_transaction;

outfile     fnd_conc_req_outputs.file_name%type      := NULL;
outnode     fnd_conc_req_outputs.file_node_name%type := NULL;
outtype     fnd_conc_req_outputs.file_type%type      := NULL;
cnt         number;
nlschar	    varchar2(2) := NULL;
codeset     varchar2(30) := NULL;

begin

  success_flag := 'N';

  -- see if any publishing actions for this request
  select count(*)
    into cnt
	from fnd_conc_pp_actions
	where action_type = 6
	and concurrent_request_id = cur_reqid;

  if cnt = 0 then

    -- reprinting only, check to see if the previous request has a published file
    -- Bug 6040814. Select output_file_type to copy from parent request.
	if published_request(prev_reqid) then
	  begin
        select fcro.file_name, fcro.file_node_name, fcro.file_type
          into outfile, outnode, outtype
          from fnd_conc_req_outputs fcro
          where fcro.concurrent_request_id = prev_reqid;
      exception
        when no_data_found then
	      errmsg := 'Could not find published output file for previous request';
		  rollback;
		  return;
      end;
    end if;
  end if;

  -- Bug 6040814. Select output_file_type to copy from parent request.
  if outfile is null then

    begin
      select outfile_name, outfile_node_name, output_file_type, nls_numeric_characters, nls_codeset
        into outfile, outnode, outtype, nlschar, codeset
        from fnd_concurrent_requests
        where request_id = prev_reqid;
    exception
      when no_data_found then
	    errmsg := 'Could not find previous request: ' || prev_reqid;
		rollback;
	    return;
    end;

  end if;

  -- Bug 6040814. Update output_file_type from parent request.

  -- File type EXCEL will not fit in fnd_concurrent_requests table, use XLS instead
  if outtype = 'EXCEL' then
    outtype := 'XLS';
  end if;

  update fnd_concurrent_requests
    set outfile_name = outfile,
	outfile_node_name = outnode,
    output_file_type = outtype,
    nls_numeric_characters = nlschar,
    nls_codeset = codeset
	where request_id = cur_reqid;

  success_flag := 'Y';
  commit;


exception
  when others then
    errmsg := sqlerrm;
    rollback;

end;


END fnd_cp_opp_req;

/
