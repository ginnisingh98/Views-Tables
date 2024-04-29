--------------------------------------------------------
--  DDL for Package Body FND_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC" as
/* $Header: AFCPDIGB.pls 120.4.12010000.2 2009/08/27 20:24:16 jtoruno ship $ */
--
-- Private variables

   -- These statuses represent "internal" states, i.e. these
   -- status codes will never be returned or used outside this package.
   -- They are used to tell apart different reasons why a pending
   -- request would be inactive. These states will all be
   -- mapped externally to the 'Inactive/No Manager' state.
   STATUS_INACTIVE_RUNALONE    constant varchar2(1) := '1';
   STATUS_INACTIVE_WKSHIFT     constant varchar2(1) := '2';
   STATUS_INACTIVE_MGR_DOWN    constant varchar2(1) := '3';
   STATUS_INACTIVE_MGR_TROUBLE constant varchar2(1) := '4';
   STATUS_INACTIVE_CP_DOWN     constant varchar2(1) := '5';



    P_USER_STATUS_CODE       varchar2(1);
    P_USER_PHASE_CODE        varchar2(1);
    P_CONTROLLING_MANAGER    number;
    P_REQUEST_ID             number;
    P_ACTUAL_START_DATE      date;
    P_LAST_UPDATE_DATE       date;
    P_REQUESTOR              varchar2(100);
    P_PARENT_REQUEST_ID      number;
    P_UPDATED_BY_NAME        varchar2(100);
    P_APPLICATION_NAME       varchar2(240);
    P_USER_CONC_PROG_NAME    varchar2(240);
    P_QUEUE_CONTROL_FLAG     varchar2(1);
    P_CD_ID                  number;
    P_ACTUAL_COMPLETION_DATE date;
    P_COMPLETION_TEXT        varchar2(1000);
    P_HOLD_FLAG              varchar2(1);
    P_PHASE                  varchar2(80);
    P_STATUS                 varchar2(80);
    P_PHASE_CODE             varchar2(1);
    P_STATUS_CODE            varchar2(1);
    P_ENABLED                varchar2(1);
    -- Increased size to P_PROGRAM to to fix the bug 4097622.
    -- This is required because we are storing
    -- R.Description||' ('||CP.User_Concurrent_Program_Name||')' into
    -- the P_PROGRAM in diagnose method.(240+240+1+1+1)
    P_PROGRAM                varchar2(483);
    P_REQUESTED_START_DATE   date;
    P_REQUEST_DATE           date;
    P_QUEUE_METHOD_CODE      varchar2(1);
    P_RUN_ALONE_FLAG         varchar2(1);
    P_SINGLE_THREAD_FLAG     varchar2(1);
    P_REQLIMIT_FLAG          varchar2(1);


date_fmt varchar2(24):= 'DD-MON-YYYY HH24:MI:SS';
date_fmt_nongreg varchar2(24):= 'YYYY.MM.DD HH24:MI:SS';


-- ================================================
-- PRIVATE FUNCTIONS/PROCEDURES
-- ================================================

PROCEDURE init_pvt_vars is
begin
    P_USER_STATUS_CODE       := null;
    P_USER_PHASE_CODE        := null;
    P_CONTROLLING_MANAGER    := null;
    P_REQUEST_ID             := null;
    P_ACTUAL_START_DATE      := null;
    P_LAST_UPDATE_DATE       := null;
    P_REQUESTOR              := null;
    P_PARENT_REQUEST_ID      := null;
    P_UPDATED_BY_NAME        := null;
    P_APPLICATION_NAME       := null;
    P_USER_CONC_PROG_NAME    := null;
    P_QUEUE_CONTROL_FLAG     := null;
    P_CD_ID                  := null;
    P_ACTUAL_COMPLETION_DATE := null;
    P_COMPLETION_TEXT        := null;
    P_HOLD_FLAG              := null;
    P_PHASE                  := null;
    P_STATUS                 := null;
    P_PHASE_CODE             := null;
    P_STATUS_CODE            := null;
    P_ENABLED                := null;
    P_PROGRAM                := null;
    P_REQUESTED_START_DATE   := null;
    P_REQUEST_DATE           := null;
    P_QUEUE_METHOD_CODE      := null;
    P_RUN_ALONE_FLAG         := null;
    P_SINGLE_THREAD_FLAG     := null;
    P_REQLIMIT_FLAG          := null;

end;

--
-- PROCEDURE
--   date_text
--
function date_text(date_in date) return varchar2 is
  text  varchar2(240);
begin
  text := to_char(date_in, date_fmt);
  return text;
end;



--
-- PROCEDURE
--   request_stats (reqid, pcode, help_text)
-- Purpose
--   Put in request statistics of request.
-- Arguments
--   reqid     - request id.
--   pcode     - phase code.
--   help_text - accumulate the help text message.
-- Notes
--   For now, we only give the average time of previous runs and
--   if pcode == 'R', when the request is expected to finish.

PROCEDURE request_stats (reqid     in     number,
                         pcode     in     char,
                         help_text in out nocopy varchar2) is

  avg_mins      number;        -- Average run times
  avg_hrs       number;
  avg_days      number;
  expctd_finish varchar2(22);    -- Expected finish date in
                                --   DD-MON-YYYY HH24:MI:SS format

begin
  -- Select only statistics# == -5 and n > 0
  select mod (floor (minval/60), 60),
     mod (floor (minval/3600), 24),
     floor (minval/86400),
     decode (pcode, 'R', decode (sign (actual_start_date + minval/86400
                                 - sysdate),
                    -1, null,
                    to_char (
                      actual_start_date + minval/86400,
                      date_fmt)),
                 null)
    into avg_mins,
     avg_hrs,
     avg_days,
     expctd_finish
    from fnd_conc_stat_summary,
     fnd_concurrent_requests r,
     fnd_concurrent_programs p
   where request_id = reqid
     and program_application_id = application_id
     and p.concurrent_program_id = r.concurrent_program_id
     and concurrent_program_name = program_name
     and statistic# = -5
     and daily = 'F'
     and n > 0
     and minval > 0;

  -- Average runs are less than a minute.
  if avg_mins < 1 and avg_hrs < 1 and avg_days < 1 then
    fnd_message.set_name ('FND', 'CONC-DG-STAT-LESS THAN A MIN');
    help_text := help_text || fnd_message.get;
    return;
  else
  -- Average runs are more than a minute.
    fnd_message.set_name ('FND', 'CONC-DG-STAT-PREVIOUS RUNS');
    help_text := fnd_message.get;
  end if;

  if avg_days > 0 then
    fnd_message.set_name ('FND', 'CONC-DG-STAT-AVG DAYS');
    fnd_message.set_token ('AVG_DAYS', to_char (avg_days));
    help_text := help_text || fnd_message.get;
  end if;

  if avg_hrs > 0 then
    fnd_message.set_name ('FND', 'CONC-DG-STAT-AVG_HRS');
    fnd_message.set_token ('AVG_HRS', to_char (avg_hrs));
    help_text := help_text || fnd_message.get;
  end if;

  if avg_mins > 0 then
    fnd_message.set_name ('FND', 'CONC-DG-STAT-AVG MINS');
    fnd_message.set_token ('AVG_MINS', to_char (avg_mins));
    help_text := help_text || fnd_message.get;
  end if;

  -- Expected finish date and time.
  if pcode = 'R' and expctd_finish is not null then
    fnd_message.set_name ('FND', 'CONC-DG-STAT-EXPCTD FINISH');
    fnd_message.set_token ('EXPCTD_FINISH', expctd_finish);
    help_text := help_text || fnd_message.get;
    fnd_message.set_name ('FND', 'CONC-DG-STAT-DISCLAIMER');
    help_text := help_text || fnd_message.get;
  end if;

  -- Punt on any exception
  exception
    when others then
      return;

end request_stats;




--
-- PROCEDURE
--   diag_running
-- Purpose
--   Diagnostics for running requests.
-- Arguments
--   help_text - return statistics from request_stats. Not currently used.
-- Notes
--   *none*
--
PROCEDURE diag_running (help_text in out nocopy varchar2) is
  dummy        boolean;
  child_count  number;
  pp_cnt       number;
  proc_id      number;
  complete     varchar2(1);

  l_user_calendar   varchar2(80);
  l_start_date_conv varchar2(80);
  l_updat_date_conv varchar2(80);

  begin

    -- 7712376 gregorian to nongregorian changes
    l_user_calendar := nvl(fnd_profile.value('FND_FORMS_USER_CALENDAR'), 'GREGORIAN');
    if (l_user_calendar = 'GREGORIAN') then
       l_start_date_conv := date_text(P_ACTUAL_START_DATE);
       l_updat_date_conv := date_text(P_LAST_UPDATE_DATE);
    else
       l_start_date_conv := to_char(P_ACTUAL_START_DATE, date_fmt_nongreg,
                                                    'NLS_CALENDAR='''||l_user_calendar||'''');
       l_updat_date_conv := to_char(P_LAST_UPDATE_DATE, date_fmt_nongreg,
                                                    'NLS_CALENDAR='''||l_user_calendar||'''');
    end if;

    if (P_USER_STATUS_CODE = STATUS_RUNNING_NORMAL) then
      if (process_alive(P_CONTROLLING_MANAGER)) then -- mgr alive

	      -- se if the request has any pp actions
          select count(*)
		    into pp_cnt
			from fnd_conc_pp_actions
			where concurrent_request_id = P_REQUEST_ID
			and action_type = 6;                         -- REMOVE FOR PHASE 2


		  if pp_cnt > 0 then

		    select processor_id, completed
			  into proc_id, complete
			  from fnd_conc_pp_actions
			  where concurrent_request_id = P_REQUEST_ID
			  and action_type = 6;                         -- REMOVE FOR PHASE 2

			-- if processor_id has been updated, post-processing has begun
			if proc_id is not null then

		      -- if completed != Y then the request is currently in post-processing
		      if complete <> 'Y' then
			    request_stats (P_REQUEST_ID, 'R', help_text);
                help_text := help_text || fnd_message.get;
                fnd_message.set_name('FND', 'CONC-DG-PP ONGOING');

			  else
			    request_stats (P_REQUEST_ID, 'R', help_text);
			    help_text := help_text || fnd_message.get;
                fnd_message.set_name('FND', 'CONC-DG-PP COMPLETE');
			  end if;

		    end if;

		  end if;

		  -- If the request has no post-processing actions, or
		  -- post-processing has not begun, the request is running normal
		  if pp_cnt = 0 or proc_id is null then
		    request_stats (P_REQUEST_ID, 'R', help_text);
            help_text := help_text || fnd_message.get;
            fnd_message.set_name('FND', 'CONC-DG-RUNNING NORMAL');
            fnd_message.set_token('START_DATE', l_start_date_conv);
		  end if;


      else  -- Manager process died
        fnd_message.set_name('FND', 'CONC-DG-RUNNING DEAD');
      end if;

    elsif (P_USER_STATUS_CODE = STATUS_TERMINATING) then
      fnd_message.set_name('FND','CONC-DG-RUNNING ABORTING');
      fnd_message.set_token('ABORT_DATE', l_updat_date_conv);
      fnd_message.set_token('USER', P_REQUESTOR);

    elsif (P_USER_STATUS_CODE = STATUS_PAUSED) then

      dummy := icm_alive(TRUE);

      -- check to see if it has running children
      select count(*)
        into child_count
        from fnd_concurrent_requests
        where parent_request_id = P_REQUEST_ID
        and phase_code in (PHASE_PENDING, PHASE_RUNNING);

      if (child_count < 1) then
        fnd_message.set_name('FND', 'CONC-DG-WAITING NO CHILDREN');
      else
        fnd_message.set_name('FND', 'CONC-DG-RUNNING WAITING');
      end if;

      fnd_message.set_token('START_DATE', l_start_date_conv);

    elsif (P_USER_STATUS_CODE = STATUS_RESUMING) then
      dummy := icm_alive(TRUE);
      fnd_message.set_name('FND', 'CONC-DG-RUNNING RESUMING');
      fnd_message.set_token('START_DATE', l_start_date_conv);
      fnd_message.set_token('PARENT_REQUEST_ID',
                            P_PARENT_REQUEST_ID);
    else
      fnd_message.set_name('FND', 'CONC-DG-BAD STATUS');
    end if;
  end diag_running;


--
-- PROCEDURE
--   diag_inactive
-- Purpose
--   Diagnostics for running requests.
-- Arguments
--   *none*
-- Notes
--   *none*
--
PROCEDURE diag_inactive is
  ra_reqid  number;
  cd_name   fnd_conflicts_domain.user_cd_name%TYPE;
  l_user_calendar   varchar2(80);
  l_updat_date_conv varchar2(80);

  begin
    -- 7712376 gregorian to nongregorian changes
    l_user_calendar := nvl(fnd_profile.value('FND_FORMS_USER_CALENDAR'), 'GREGORIAN');
    if (l_user_calendar = 'GREGORIAN') then
       l_updat_date_conv := date_text(P_LAST_UPDATE_DATE);
    else
       l_updat_date_conv := to_char(P_LAST_UPDATE_DATE, date_fmt_nongreg,
                                                    'NLS_CALENDAR='''||l_user_calendar||'''');
    end if;

    if (P_USER_STATUS_CODE = STATUS_HOLD) then
      fnd_message.set_name('FND', 'CONC-DG-INACTIVE HOLD');
      fnd_message.set_token('USER', P_UPDATED_BY_NAME);
      fnd_message.set_token('HOLD_DATE', l_updat_date_conv);

    elsif (P_USER_STATUS_CODE = STATUS_DISABLED) then
      fnd_message.set_name('FND', 'CONC-DG-INACTIVE DISABLED');
      fnd_message.set_token('APPLICATION_NAME', P_APPLICATION_NAME);
      fnd_message.set_token('PROGRAM_NAME', P_USER_CONC_PROG_NAME);

    elsif (P_USER_STATUS_CODE = STATUS_NO_MANAGER) then
       fnd_message.set_name('FND', 'CONC-DG-INACTIVE NO MANAGER');

    elsif (P_USER_STATUS_CODE = STATUS_INACTIVE_RUNALONE) then

      select user_cd_name into cd_name from fnd_conflicts_domain
          where cd_id = P_CD_ID;

      begin
       /* changed query for BUG#5007915 SQLID#14602696 */
    select request_id
      into ra_reqid
      from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
     where fcp.run_alone_flag = 'Y'
       and fcp.concurrent_program_id = fcr.concurrent_program_id
       and fcp.application_id = fcr.program_application_id
       and fcr.phase_code = 'R'
       and fcr.cd_id = P_CD_ID;


        fnd_message.set_name('FND', 'CONC-DG-INACTIVE RUNALONE');
        fnd_message.set_token('RA_REQID', ra_reqid);
        fnd_message.set_token('CD_NAME', cd_name);

      exception
        when NO_DATA_FOUND then
              fnd_message.set_name('FND', 'CONC-DG-INACTIVE NO RUNALONE');
            fnd_message.set_token('CD_NAME', cd_name);
      end;

    elsif (P_USER_STATUS_CODE = STATUS_INACTIVE_WKSHIFT) then
       fnd_message.set_name('FND', 'CONC-DG-INACTIVE WRONG SHIFT');

    elsif (P_USER_STATUS_CODE = STATUS_INACTIVE_MGR_DOWN) then
       fnd_message.set_name('FND', 'CONC-DG-INACTIVE MANAGER DOWN');

    elsif (P_USER_STATUS_CODE = STATUS_INACTIVE_MGR_TROUBLE) then
       fnd_message.set_name('FND', 'CONC-DG-INACTIVE TROUBLED');

    elsif (P_USER_STATUS_CODE = STATUS_INACTIVE_CP_DOWN) then
       fnd_message.set_name('FND', 'CONC-DG-INACTIVE ICM DOWN');

    else
      fnd_message.set_name('FND', 'CONC-DG-BAD STATUS');
    end if;
  end diag_inactive;


--
-- PROCEDURE
--   diag_pending
-- Purpose
--   Diagnostics for pending requests.
-- Arguments
--   help_text - return statistics from request_stats. Not currently used.
-- Notes
--   *none*
--
PROCEDURE diag_pending (help_text in out nocopy varchar2) is

  dummy                boolean;
  parent_reqid         number;
  cnt                  number;
  l_user_calendar      varchar2(80);
  l_reqstart_date_conv varchar2(80);
  l_updat_date_conv    varchar2(80);

  begin
    -- 7712376 gregorian to nongregorian changes
    l_user_calendar := nvl(fnd_profile.value('FND_FORMS_USER_CALENDAR'), 'GREGORIAN');
    if (l_user_calendar = 'GREGORIAN') then
       l_reqstart_date_conv := date_text(P_REQUESTED_START_DATE);
       l_updat_date_conv := date_text(P_LAST_UPDATE_DATE);
    else
       l_reqstart_date_conv := to_char(P_REQUESTED_START_DATE, date_fmt_nongreg,
                                                    'NLS_CALENDAR='''||l_user_calendar||'''');
       l_updat_date_conv := to_char(P_LAST_UPDATE_DATE, date_fmt_nongreg,
                                                    'NLS_CALENDAR='''||l_user_calendar||'''');
    end if;

    -- check for invalid queue_method_code
    if (P_QUEUE_METHOD_CODE not in ('I', 'B')) then
      fnd_message.set_name('FND', 'CONC-DG-INVALID QM CODE');
      return;
    end if;

    if (P_USER_STATUS_CODE in (STATUS_NORMAL, STATUS_STANDBY)) then
      if (P_QUEUE_CONTROL_FLAG = 'Y') then
        if ( icm_alive(FALSE)) then
          fnd_message.set_name('FND', 'CONC-DG-PENDING NORMAL CONTROL');
        else
          fnd_message.set_name('FND', 'CONC-DG-INACTIVE QUEUE CONTROL');
        end if;
        fnd_message.set_token('USER', P_UPDATED_BY_NAME);
        fnd_message.set_token('SUBMIT_DATE', date_text(P_LAST_UPDATE_DATE));
        fnd_message.set_token('SUBMIT_DATE', l_updat_date_conv);
        return;
      end if;

      request_stats (P_REQUEST_ID, 'P', help_text);

      -- Pending Normal
      if (P_USER_STATUS_CODE = STATUS_NORMAL) then
        fnd_message.set_name('FND', 'CONC-DG-PENDING NORMAL');

      else
        -- Pending Standby
        -- Check for unconstrained req in Standby
        if (P_QUEUE_METHOD_CODE = 'I') then
          fnd_message.set_name('FND', 'CONC-DG-STANDBY UNCONSTRAINED');

        -- runalone request
        elsif (P_RUN_ALONE_FLAG = 'Y') then
          fnd_message.set_name('FND', 'CONC-DG-STANDBY RUNALONE');

		-- normal standby request
		elsif (P_SINGLE_THREAD_FLAG <> 'Y' and P_REQLIMIT_FLAG <> 'Y') then
		   fnd_message.set_name('FND', 'CONC-DG-PENDING STANDBY');

        else
           -- Here is a special case. If the user is invalid or end-dated,
           -- this request will never be released by the CRM.
           -- Check the user in FND_USER
           select count(*)
             into cnt
             from fnd_user fu, fnd_concurrent_requests fcr
             where fcr.request_id = P_REQUEST_ID
             and   fu.user_id = fcr.requested_by
             and (fu.end_date is null or fu.end_date > sysdate);

           if (cnt = 0) then
              fnd_message.set_name('FND', 'CONC-DG-STANDBY INVALID USER');

           -- single thread flag
           elsif (P_SINGLE_THREAD_FLAG = 'Y') then
             fnd_message.set_name('FND', 'CONC-DG-STANDBY SEQREQ');

           -- Active request limit flag
           elsif (P_REQLIMIT_FLAG = 'Y') then
             fnd_message.set_name('FND', 'CONC-DG-STANDBY REQLIMIT');

           -- normal standby request
           else
             fnd_message.set_name('FND', 'CONC-DG-PENDING STANDBY');
           end if;
        end if;
      end if;

      fnd_message.set_token('USER', P_REQUESTOR);
      fnd_message.set_token('SUBMIT_DATE', l_updat_date_conv);


    elsif (P_USER_STATUS_CODE = STATUS_SCHEDULED) then
      request_stats (P_REQUEST_ID, 'P', help_text);
      fnd_message.set_name('FND', 'CONC-DG-PENDING SCHEDULED');
      fnd_message.set_token('START_DATE', l_reqstart_date_conv);
      fnd_message.set_token('USER', P_REQUESTOR);

    elsif (P_USER_STATUS_CODE = STATUS_WAITING) then

      -- check for a running or pending parent request
      select count(*)
        into parent_reqid
        from fnd_concurrent_requests
        where request_id = P_PARENT_REQUEST_ID
        and phase_code in ('P', 'R');


      if (P_PARENT_REQUEST_ID is null or parent_reqid = 0) then
        fnd_message.set_name('FND', 'CONC-DG-WAITING NO PARENT');
      else
        fnd_message.set_name('FND', 'CONC-DG-PENDING WAITING');
        fnd_message.set_token('PARENT_REQUEST_ID', P_PARENT_REQUEST_ID);
      end if;

    else
      fnd_message.set_name('FND', 'CONC-DG-BAD STATUS');
    end if;

  end diag_pending;


--
-- PROCEDURE
--   diag_completed
-- Purpose
--   Diagnostics for pending requests.
-- Arguments
--   *none*
-- Notes
--   *none*
--
PROCEDURE diag_completed is

l_user_calendar   varchar2(80);
l_start_date_conv varchar2(80);
l_cmplt_date_conv varchar2(80);
l_updat_date_conv varchar2(80);

  begin

    -- 7712376 gregorian to nongregorian changes
    l_user_calendar := nvl(fnd_profile.value('FND_FORMS_USER_CALENDAR'), 'GREGORIAN');
    if (l_user_calendar = 'GREGORIAN') then
       l_start_date_conv := date_text(P_ACTUAL_START_DATE);
       l_cmplt_date_conv := date_text(P_ACTUAL_COMPLETION_DATE);
       l_updat_date_conv := date_text(P_LAST_UPDATE_DATE);
    else
       l_start_date_conv := to_char(P_ACTUAL_START_DATE, date_fmt_nongreg, 'NLS_CALENDAR='''||l_user_calendar||'''');
       l_cmplt_date_conv := to_char(P_ACTUAL_COMPLETION_DATE, date_fmt_nongreg, 'NLS_CALENDAR='''||l_user_calendar||'''');
       l_updat_date_conv := to_char(P_LAST_UPDATE_DATE, date_fmt_nongreg, 'NLS_CALENDAR='''||l_user_calendar||'''');
    end if;

    if (P_USER_STATUS_CODE = STATUS_COMPLETED_NORMAL) then
      fnd_message.set_name('FND', 'CONC-DG-COMPLETED NORMAL');
      fnd_message.set_token('START_DATE', l_start_date_conv);
      fnd_message.set_token('COMPLETION_DATE', l_cmplt_date_conv);

    elsif (P_USER_STATUS_CODE = STATUS_ERROR) then
      if (P_COMPLETION_TEXT is not null) then
         fnd_message.set_name('FND', 'CONC-DG-COMPLETED ERROR');
         fnd_message.set_token('COMPLETION_TEXT', P_COMPLETION_TEXT);
      else
         fnd_message.set_name('FND', 'CONC-DG-COMPLETED ERROR NO MSG');
      end if;
      fnd_message.set_token('START_DATE', l_start_date_conv);
      fnd_message.set_token('COMPLETION_DATE', l_cmplt_date_conv);

    elsif (P_USER_STATUS_CODE = STATUS_WARNING) then
      if (P_COMPLETION_TEXT is not null) then
        fnd_message.set_name('FND', 'CONC-DG-COMPLETED WARNING');
        fnd_message.set_token('COMPLETION_TEXT', P_COMPLETION_TEXT);
      else
        fnd_message.set_name('FND', 'CONC-DG-COMPLETED WARN NO MSG');
      end if;
      fnd_message.set_token('START_DATE', l_start_date_conv);
      fnd_message.set_token('COMPLETION_DATE', l_cmplt_date_conv);

    elsif (P_USER_STATUS_CODE = STATUS_TERMINATED) then
      fnd_message.set_name('FND', 'CONC-DG-COMPLETED ABORTED');
      fnd_message.set_token('ABORT_DATE', l_updat_date_conv);
      fnd_message.set_token('USER', P_UPDATED_BY_NAME);

    elsif (P_USER_STATUS_CODE  = STATUS_CANCELLED) then
      fnd_message.set_name('FND', 'CONC-DG-COMPLETED DELETED');
      fnd_message.set_token('USER', P_UPDATED_BY_NAME);
      fnd_message.set_token('ABORT_DATE', l_updat_date_conv);
    else
      fnd_message.set_name('FND', 'CONC-DG-BAD STATUS');
    end if;

  end diag_completed;



--
-- PROCEDURE
--   get_phase_status
-- Purpose
--   Calculate the user phase and status codes
--   from the request information.
-- Arguments
--  IN:
--   pcode  -- The DB phase code
--   scode  -- The DB status code
--   hold   -- Hold flag
--   enbld  -- Enabled flag
--   stdate -- Start date
--   rid    -- Request_id
--  OUT:
--   phase  -- User phase meaning
--   status -- User status meaning
--   upcode -- User phase code
--   uscode -- User status code
-- Notes
--   Private procedure only. May return special 'internal' status codes.
--
PROCEDURE get_phase_status (pcode  in varchar2,
                            scode  in varchar2,
                            hold   in varchar2,
                            enbld  in varchar2,
                            stdate in date,
                            rid    in number,
                            phase  out nocopy varchar2,
                            status out nocopy varchar2,
                            upcode in out nocopy varchar2,
                            uscode in out nocopy varchar2) is

  defined   boolean;
  active    boolean;
  workshift boolean;
  running   boolean;
  run_alone boolean;

  begin
    if (pcode is NULL) then
      phase := NULL;
      return;
    end if;

    upcode := pcode;
    uscode := scode;

    -- For Pending requests,
    -- check to see if phase and status needs to be modified
    if (pcode = PHASE_PENDING) then

      upcode := PHASE_INACTIVE;

      -- Check for Hold, Disabled, and Scheduled requests
      if (hold = 'Y') then
        uscode := STATUS_HOLD;

      elsif (enbld = 'N') then
        uscode := STATUS_DISABLED;

      elsif ((stdate > sysdate) or (scode = STATUS_SCHEDULED)) then
        upcode := PHASE_PENDING;
        uscode := STATUS_SCHEDULED;
      else

        -- See if the request needs to marked Inactive
        manager_check(rid,
                      P_CD_ID,
                      defined,
                      active,
                      workshift,
                      running,
                      run_alone);

        if (not defined) then
          uscode := STATUS_NO_MANAGER;              -- No manager defined
        elsif (not active) then
          uscode := STATUS_INACTIVE_MGR_DOWN;       -- Manager deactivated
        elsif (not workshift) then
          if not running and not icm_alive(false) then
            uscode := STATUS_INACTIVE_CP_DOWN;      -- All managers down
          else
            uscode := STATUS_INACTIVE_WKSHIFT;      -- Out of workshift
          end if;
        elsif (not running) then
          uscode := STATUS_INACTIVE_MGR_TROUBLE;    -- Manager troubled/dead
        elsif (run_alone) then
          uscode := STATUS_INACTIVE_RUNALONE;       -- Waiting for run alone
        else
          upcode := PHASE_PENDING;                  -- Normal pending request
        end if;
      end if;
    end if;


    phase := get_phase(upcode);
    status := get_status(uscode);


end get_phase_status;




-- ================================================
-- PUBLIC FUNCTIONS/PROCEDURES
-- ================================================



--
-- PROCEDURE
--   diagnose
-- Purpose
--   Perform diagnostics on a given request.
-- Arguments
--   request_id
--   phase       -- returns text string describing the phase
--   status      -- returns text string describing the status
--   help_text   -- returns translated diagnostic text
--
PROCEDURE diagnose ( request_id  in     number,
                     phase       out nocopy    varchar2,
                     status      out nocopy    varchar2,
                     help_text   in out nocopy varchar2
                   ) is

   l_phase          varchar2(80);
   l_status         varchar2(80);
   user_phase_code  varchar2(1);
   user_status_code varchar2(1);

   diagnose_error   exception;
begin
   -- Initialize the private variables before using them
   init_pvt_vars;
   help_text := '';

   -- Get the information about the request from the database and fill the
   -- private variables

   begin
      select R.request_id, R.phase_code, R.status_code, R.request_date,
             R.requested_start_date, R.hold_flag, R.parent_request_id,
             R.last_update_date, U1.user_name updated_by_name,
             R.actual_start_date, R.completion_text,
             R.actual_completion_date, U2.user_name requestor,
             FA.application_name application_name,
             CP.enabled_flag enabled, R.controlling_manager,
             Decode (R.Description,
               NULL, CP.User_Concurrent_Program_Name,
                     R.Description||' ('||CP.User_Concurrent_Program_Name||')')
             program_name, Queue_Control_Flag,
             R.queue_method_code, CP.run_alone_flag,
             R.single_thread_flag, R.request_limit, R.cd_id
        into P_REQUEST_ID, P_PHASE_CODE, P_STATUS_CODE, P_REQUEST_DATE,
         P_REQUESTED_START_DATE, P_HOLD_FLAG, P_PARENT_REQUEST_ID,
         P_LAST_UPDATE_DATE, P_UPDATED_BY_NAME,
         P_ACTUAL_START_DATE, P_COMPLETION_TEXT,
         P_ACTUAL_COMPLETION_DATE, P_REQUESTOR,
         P_APPLICATION_NAME,
         P_ENABLED, P_CONTROLLING_MANAGER,
         P_PROGRAM, P_QUEUE_CONTROL_FLAG,
         P_QUEUE_METHOD_CODE, P_RUN_ALONE_FLAG,
         P_SINGLE_THREAD_FLAG, P_REQLIMIT_FLAG, P_CD_ID
        from fnd_concurrent_requests R, fnd_concurrent_programs_vl CP,
             fnd_user U1, fnd_user U2,
             fnd_application_vl FA
       where R.request_id = diagnose.request_id
         and R.program_application_id = FA.application_id
         and R.program_application_id = CP.application_id (+)
         and R.concurrent_program_id  = CP.concurrent_program_id (+)
         and R.last_updated_by        = U1.user_id (+)
         and R.requested_by           = U2.user_id (+);

      exception
     when no_data_found then
            fnd_message.set_name('FND','CONC-Missing Request');
            fnd_message.set_token('ROUTINE', 'FND_CONC.DIAGNOSE');
            fnd_message.set_token('REQUEST', to_char(request_id));
        raise diagnose_error;
         when others then
            fnd_message.set_name ('FND', 'SQL-Generic error');
            fnd_message.set_token ('ERRNO', sqlcode, FALSE);
            fnd_message.set_token ('REASON', sqlerrm, FALSE);
            fnd_message.set_token (
                                'ROUTINE', 'FND_CONC.DIAGNOSE', FALSE);
        raise diagnose_error;
   end;

   get_phase_status(
                     P_PHASE_CODE,
                     P_STATUS_CODE,
                     P_HOLD_FLAG,
                     P_ENABLED,
                     P_REQUESTED_START_DATE,
                      P_REQUEST_ID,
                     l_phase,
                     l_status,
                     user_phase_code,
                     user_status_code);

    P_PHASE := l_phase;
    P_STATUS := l_status;
    phase    := l_phase;
    status   := l_status;
    P_USER_PHASE_CODE := user_phase_code;
    P_USER_STATUS_CODE := user_status_code;

    if (P_PROGRAM is NULL) then
      fnd_message.set_name('FND', 'CONC-DG-BAD PROGRAM ID');
    elsif (P_USER_PHASE_CODE = PHASE_RUNNING) then
      diag_running (help_text);
    elsif (P_USER_PHASE_CODE = PHASE_PENDING) then
      diag_pending (help_text);
    elsif (P_USER_PHASE_CODE = PHASE_COMPLETED) then
      diag_completed;
    elsif (P_USER_PHASE_CODE = PHASE_INACTIVE) then
      diag_inactive;
      -- if status was changed to one of the Inactive status codes,
      -- change it back to 'No Manager'
      if status is null then
        status := get_status(STATUS_NO_MANAGER);
      end if;
    else
      fnd_message.set_name('FND', 'CONC-DG-BAD PHASE');
    end if;

    help_text := fnd_message.get;

    exception
      when diagnose_error then
        help_text := fnd_message.get;

end diagnose;



--
-- Function
--   process_alive
-- Purpose
--   Return TRUE if the process is alive,
--   FALSE otherwise.
-- Arguments
--   pid - concurrent process ID
-- Notes
--   Return FALSE on error.
--
function process_alive(pid number) return boolean is
  manager_id  number;
  appl_id     number;
  result      number;
  alive       number;

  begin
    select queue_application_id, concurrent_queue_id
      into appl_id, manager_id
      from fnd_concurrent_processes
      where concurrent_process_id = pid;

     --
     -- Lock PMON method
     -- Bug 2093806: use fnd_dcp.check_process_status_by_ids
     --
    fnd_dcp.check_process_status_by_ids(
                    appl_id, manager_id, pid, result, alive);

    if (alive = 0) then
      -- got the lock handle for the process, process not alive.
      return FALSE;
    elsif ( (alive = 1) AND (result in (1, 2)) ) then
      -- lock not granted, process is alive
      return TRUE;
    else
      -- alive is 1 and result is 3, 5, or null.  This implies a
      -- problem in call to DMBS_LOCK. In order to continue, we assume
      -- manager is alive, since we did not get the lock. There is a
      -- message that was set in the dictionary by fnd_dcp.
      return TRUE;
    end if;

  exception
    when no_data_found then
      return FALSE;
  end process_alive;


--
-- Function
--   icm_alive
-- Purpose
--   If the ICM is dead, put the appropriate
--   message on the stack and return FALSE.
--   If the ICM is alive, TRUE is returned
-- Arguments
--   print   -- if FALSE, no message is put on the stack
--
function icm_alive(print boolean) return boolean is
  pid  number;

  begin
    select max(concurrent_process_id)
      into pid
      from fnd_concurrent_processes
      where  concurrent_process_id in
         (select concurrent_process_id
            from fnd_concurrent_processes
            where queue_application_id = 0
              and concurrent_queue_id = 1
              and process_status_code in ('A','M'));

    if (not process_alive(pid)) then
      raise no_data_found;
    end if;
    return TRUE;
  exception
    when no_data_found then
      if (print) then
        fnd_message.set_name('FND','CONC-DG-IM INACTIVE');
      end if;
      return FALSE;
  end icm_alive;


--
-- Function
--   service_alive
-- Purpose
--   Checks to see if any one of a service's processes are alive.
--   Returns TRUE if one or more is alive, if none are alive returns FALSE.
-- Arguments
--   queue_id     -- concurrent queue id of the service
--   app_id       -- application id of the service
-- Notes
--   Calls process_alive for each process id.
--
function service_alive(queue_id in number,
                       app_id   in number) return boolean is

   cursor service_curs(qid number, appid number) is
     select concurrent_process_id
	   from fnd_concurrent_processes
	   where concurrent_queue_id = qid
	   and queue_application_id = appid
	   and process_status_code in ('A', 'C');

begin

   for serv in service_curs(queue_id, app_id) loop
	  if process_alive(serv.concurrent_process_id) then
		 return true;
	  end if;

   end loop;

   return false;


end service_alive;




--
-- PROCEDURE
--   manager_check
-- Purpose
--   Checks status of managers that can run a request.
--
-- Arguments
--   IN:
--    req_id        -- request ID
--    cd_id         -- Conflict Domain ID
--   OUT:
--    mgr_defined   -- Is there a manager defined that will run
--                     the request?
--    mgr_active    -- Is there an active manager to run it?
--    mgr_workshift -- Will the request run in a current workshift?
--    mgr_running   -- Is there a manager running that can
--                     process the request?
--    run_alone     -- Is request waiting for run alone request?
--                     to complete.
--
PROCEDURE manager_check  (req_id        in  number,
                          cd_id         in  number,
                          mgr_defined   out nocopy boolean,
                          mgr_active    out nocopy boolean,
                          mgr_workshift out nocopy boolean,
                          mgr_running   out nocopy boolean,
                          run_alone     out nocopy boolean) is

    cursor mgr_cursor (rid number) is
	  select running_processes, max_processes,
		     concurrent_queue_id, queue_application_id,
             decode(control_code,
                    'T','N',       -- Abort
                    'X','N',       -- Aborted
                    'D','N',       -- Deactivate
                    'E','N',       -- Deactivated
                        'Y') active
        from fnd_concurrent_worker_requests
        where request_id = rid
          and not((queue_application_id = 0)
                  and (concurrent_queue_id in (1,4)));

    run_alone_flag  varchar2(1);

  begin
    mgr_defined := FALSE;
    mgr_active := FALSE;
    mgr_workshift := FALSE;
    mgr_running := FALSE;

    for mgr_rec in mgr_cursor(req_id) loop
      mgr_defined := TRUE;
      if (mgr_rec.active = 'Y') then
        mgr_active := TRUE;
        if (mgr_rec.max_processes > 0) then
          mgr_workshift := TRUE;
        end if;
		if (mgr_rec.running_processes > 0) then
		  -- says it has active processes, but does it really?
		  mgr_running := service_alive(mgr_rec.concurrent_queue_id,
			                           mgr_rec.queue_application_id);
        end if;
      end if;
    end loop;

    if (cd_id is null) then    -- However, I think we're changing the column to
      run_alone_flag := 'N';   -- NOT NULL in 11.0.2...
    else
      select runalone_flag
        into run_alone_flag
        from fnd_conflicts_domain d
        where d.cd_id = manager_check.cd_id;
    end if;
    if (run_alone_flag = 'Y') then
      run_alone := TRUE;
    else
      run_alone := FALSE;
    end if;

  end manager_check;


--
-- FUNCTION
--   get_phase
-- Purpose
--   Lookup meaning of a request phase_code.
--
function get_phase(pcode in varchar2) return varchar2 is
   ret_value varchar2(80);
   ltype     varchar2(32);
begin

   ltype := 'CP_PHASE_CODE';
   select meaning into ret_value
     from fnd_lookups
    where lookup_type  = ltype
      and lookup_code  = pcode;

   return ret_value;

   exception
      when no_data_found then
     return null;
      when others then
     return null;
end;


--
-- FUNCTION
--   get_status
-- Purpose
--    Lookup meaning of a request status_code.
--
function get_status(scode in varchar2) return varchar2 is
   ret_value varchar2(80);
   ltype     varchar2(32);
begin

   ltype := 'CP_STATUS_CODE';
   select meaning into ret_value
     from fnd_lookups
    where lookup_type  = ltype
      and lookup_code  = scode;

   return ret_value;

   exception
      when no_data_found then
     return null;
      when others then
     return null;
end;



end FND_CONC;

/
