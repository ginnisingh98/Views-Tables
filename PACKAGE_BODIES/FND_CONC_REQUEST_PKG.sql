--------------------------------------------------------
--  DDL for Package Body FND_CONC_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_REQUEST_PKG" as
/* $Header: AFCPFCRB.pls 120.4.12010000.3 2012/07/16 19:52:43 jtoruno ship $ */

-- Placing the cursor outside the function will
-- prevent reparsing on each call.  (I think.)

/* Globals */
FNDCPQCR_ACTIVE       boolean default FALSE;
FNDCPQCR_SYS_MODE     boolean default FALSE;
FNDCPQCR_RESP_ACCESS  boolean default FALSE;
FNDCPQCR_USER_ID      number  default NULL;
FNDCPQCR_RESP_APPL_ID number  default NULL;
FNDCPQCR_RESP_ID      number  default NULL;


PHASE_LOOKUP_TYPE      CONSTANT VARCHAR2(16) := 'CP_PHASE_CODE';
STATUS_LOOKUP_TYPE     CONSTANT VARCHAR2(16) := 'CP_STATUS_CODE';

/* Will placing the cursor outside of the function keep it from
 * reparsing with each call?   I hope so.
 */
cursor attribute_numbers(appl_id number, prog_name varchar2) is
  select to_number(substr(application_column_name, 10)) num
    from fnd_descr_flex_column_usages
   where application_id = appl_id
     and descriptive_flexfield_name = '$SRS$.'||prog_name
     and descriptive_flex_context_code = 'Global Data Elements'
     and enabled_flag = 'Y'
   order by column_seq_num;


procedure get_program_info (cpid  in number,
			    appid in number,
			    pname out nocopy varchar2,
			    sname out nocopy varchar2,
			    srs   in out nocopy varchar2,
			    eflag in out nocopy varchar2,
			    rflag in out nocopy varchar2,
			    qcode in out nocopy varchar2,
			    eopts in out nocopy varchar2,
			    prntr in out nocopy varchar2,
			    pstyl in out nocopy varchar2,
			    rstyl in out nocopy varchar2) is

begin
  select user_concurrent_program_name,
	 concurrent_program_name,
	 srs_flag,
	 enabled_flag,
	 run_alone_flag,
	 queue_method_code,
	 execution_options,
	 printer_name,
	 output_print_style,
	 required_style
    into pname,
	 sname,
	 srs,
	 eflag,
	 rflag,
	 qcode,
	 eopts,
	 prntr,
	 pstyl,
	 rstyl
    from fnd_concurrent_programs_vl
   where concurrent_program_id = cpid
     and application_id = appid;

  exception
    when no_data_found then
      pname := NULL;
      eflag := 'N';
end get_program_info;


function get_user_name (uid	in number)
		    	return	varchar2 is

uname fnd_user.user_name%TYPE;

begin
  if (uid is NULL) then
    return (NULL);
  end if;

  select user_name
    into uname
    from fnd_user
   where user_id = uid;

  return (uname);

  exception
    when no_data_found then
      return (NULL);
end get_user_name;


function get_user_print_style (pstyl	in varchar2)
		    	       return 	varchar2 is

ustyl fnd_printer_styles_vl.user_printer_style_name%TYPE;

begin
  if (pstyl is NULL) then
    return (NULL);
  end if;

  select user_printer_style_name
    into ustyl
    from fnd_printer_styles_vl
   where printer_style_name = pstyl;

  return (ustyl);

  exception
    when no_data_found then
      return (NULL);
end get_user_print_style;


procedure get_phase_status (pcode  in char,
			    scode  in char,
			    hold   in char,
			    enbld  in char,
			    cancel in char,
			    stdate in date,
			    rid    in number,
			    phase  out nocopy varchar2,
			    status out nocopy varchar2) is
  upcode	char;
  uscode	char;
begin
    get_phase_status(pcode, scode, hold, enbld, cancel, stdate,
		     rid, phase, status, upcode, uscode);

end get_phase_status;



procedure get_phase_status (pcode  in char,
			    scode  in char,
			    hold   in char,
			    enbld  in char,
			    cancel in char,
			    stdate in date,
			    rid    in number,
			    phase  out nocopy varchar2,
			    status out nocopy varchar2,
			    upcode out nocopy varchar2,
			    uscode out nocopy varchar2) is

begin
  if (pcode is NULL) then
    phase := NULL;
    return;
  end if;

  upcode := pcode;
  uscode := scode;

  if ((pcode = 'P') and (hold = 'Y')) then
    upcode := 'I';
    uscode := 'H';
  elsif ((pcode = 'P') and (enbld = 'N')) then
    upcode := 'I';
    uscode := 'U';
  elsif ((pcode = 'P') and (scode = 'A')) then
    upcode := 'P';
    uscode := 'A';
  elsif (pcode = 'P') then
    if ((scode = 'P') or (stdate > sysdate)) then
      upcode := 'P';
      uscode := 'P';
    else
      select 'I',
	     'M'
        into upcode,
	     uscode
	from sys.dual
       where not exists (select null
			   from fnd_concurrent_worker_requests
			  where request_id = rid
			    and running_processes > 0
			    and (not (queue_application_id = 0
				      and concurrent_queue_id in (1,4))
				 or queue_control_flag = 'Y'));
    end if;
  end if;

  raise no_data_found;

  exception
    when no_data_found then
    /*changed query for BUG#5007915 SQLID#14602738 */
    select ph.meaning into phase
    from fnd_lookups ph
    where ph.lookup_type = PHASE_LOOKUP_TYPE
    and ph.lookup_code = upcode;

    select st.meaning into status
    from fnd_lookups st
    where st.lookup_type = STATUS_LOOKUP_TYPE
    and st.lookup_code = uscode;
end get_phase_status;


function get_user_phase_code (phase in varchar2)
			      return varchar2 is

  upcode fnd_lookups.lookup_code%TYPE;

begin
  if (phase is null) then
    return (NULL);
  end if;

  select lookup_code
    into upcode
    from fnd_lookups
   where lookup_type = PHASE_LOOKUP_TYPE
     and meaning like phase
order by lookup_code;

  return (upcode);

  exception
    when no_data_found then
      return ('0');		-- A non-null non-phase code
end get_user_phase_code;


function get_user_status_code (status in varchar2)
			       return varchar2 is

  uscode fnd_lookups.lookup_code%TYPE;

begin
  if (status is null) then
    return (NULL);
  end if;

  select lookup_code
    into uscode
    from fnd_lookups
   where lookup_type = STATUS_LOOKUP_TYPE
     and meaning like status
order by lookup_code;

  return (uscode);

  exception
    when no_data_found then
      return ('0');		-- A non-null non-status code
end get_user_status_code;


function lock_parent (rid in number)
		      return boolean is

  dummy char;

begin
  select status_code
    into dummy
    from fnd_concurrent_requests
   where request_id = rid
     and has_sub_request = 'Y'
     and status_code = 'W'
     for update of status_code;

  return (TRUE);

  exception
    when no_data_found then
      return (FALSE);
end lock_parent;


function restart_parent (rid	in number,
			 prid	in number,
			 uid	in number)
			 return	boolean is

begin
  update fnd_concurrent_requests
     set status_code = 'I',
	 last_update_date = sysdate,
	 last_updated_by  = uid
   where request_id = prid
     and has_sub_request = 'Y'
     and status_code = 'W'
     and not exists (select null
		       from fnd_concurrent_requests
		      where parent_request_id = prid
			and request_id <> rid
			and is_sub_request = 'Y'
			and status_code between 'I' and 'T');

  return (not (SQL%NOTFOUND));
end restart_parent;


procedure delete_children (rid	in number,
			   uid	in number) is

begin
  update fnd_concurrent_requests
     set phase_code = decode (status_code,
			      'R',	'R',
					'C'),
	 status_code = decode (phase_code,
			       'R',	decode (status_code,
					        'R',	'T',
							'X'),
					'D'),
	 last_update_date = sysdate,
	 last_updated_by = uid
   where request_id in (select request_id
			  from fnd_concurrent_requests
			 where phase_code <> 'C' and status_code <> 'T'
		       connect by prior request_id = parent_request_id
			 start with request_id = rid);
end delete_children;


function request_position (rid    in number,
			   pri    in number,
			   stdate in date,
			   qname  in varchar2,
			   qappid in number)
		    	   return number is

reqpos number;

begin
  select count (*) + 1
    into reqpos
    from fnd_concurrent_worker_requests b
   where (b.priority < pri
	  or (b.priority = pri
	      and b.requested_start_date < stdate)
	  or (b.priority = pri
	      and b.requested_start_date = stdate)
              and b.request_id <= rid)
     and b.concurrent_queue_name = qname
     and b.queue_application_id = qappid
     and b.phase_code = 'P'
     and b.hold_flag <> 'Y'
     and b.requested_start_date <= sysdate;

  return (reqpos);

  exception
    when no_data_found then
      return (NULL);

end request_position;


function running_requests (qname  in varchar2,
			   qappid in number)
			   return number is

runreqs number;

begin
  select count (*)
    into runreqs
    from fnd_concurrent_worker_requests
   where concurrent_queue_name = qname
     and queue_application_id = qappid
     and phase_code = 'R';

  return (runreqs);

  exception
    when no_data_found then
      return (NULL);

end running_requests;


function pending_requests (qname  in varchar2,
			   qappid in number)
			   return number is

pendreqs number;

begin
  select count (*)
    into pendreqs
    from fnd_concurrent_worker_requests
   where concurrent_queue_name = qname
     and queue_application_id = qappid
     and phase_code = 'P'
     and hold_flag <> 'Y'
     and requested_start_date <= sysdate;

  return (pendreqs);

  exception
    when no_data_found then
      return (NULL);

end pending_requests;


function encode_attribute_order (srs_flag         in varchar2,
                                 requested_by     in number,
                                 req_resp_id      in number,
                                 req_resp_appl_id in number,
                                 prog_appl_id     in number,
                                 prog_name        in varchar2)
                                 return varchar2 is
  encoded_string varchar2(100);

begin
  /* Are we being called from within a QCR session? */
  if ((not FNDCPQCR_ACTIVE) or (srs_flag = 'N')) then
    return Null;
  end if;

  /* Do we (possibly) have access to the report? */
  if ((not FNDCPQCR_SYS_MODE)
       and (requested_by <> FNDCPQCR_USER_ID)
       and (not FNDCPQCR_RESP_ACCESS)) then
    return Null;
  end if;

  /* The resp must match for the flex to be active. */
  /* 12821152 Allow access to System Admin and user-owned request. */
  if (((req_resp_id <> FNDCPQCR_RESP_ID) or
      (req_resp_appl_id <> FNDCPQCR_RESP_APPL_ID)) and
      ((not FNDCPQCR_SYS_MODE) and (not (requested_by = FNDCPQCR_USER_ID)))) then
    return Null;
  end if;

  encoded_string := NULL;

  for rec in attribute_numbers(prog_appl_id, prog_name) loop
    encoded_string := encoded_string || fnd_global.local_chr(rec.num);
  end loop;

  return encoded_string;

exception
  when others then
    return NULL;
end;


procedure fndcpqcr_init(sys_mode boolean, resp_access boolean) is
begin
  FNDCPQCR_ACTIVE := TRUE;
  FNDCPQCR_SYS_MODE := sys_mode;
  FNDCPQCR_RESP_ACCESS := resp_access;
  FNDCPQCR_USER_ID := fnd_global.user_id;
  FNDCPQCR_RESP_APPL_ID := fnd_global.resp_appl_id;
  FNDCPQCR_RESP_ID := fnd_global.resp_id;
end;

function role_info( in_name in varchar2,
                    in_system in varchar2,
                    in_system_id in number)
         return varchar2 is
   disp_name varchar2(80);
begin
   -- get the display_name from wf_roles with constants in
   -- in where condition.
   select display_name
     into disp_name
     from wf_roles
    where orig_system_id = in_system_id
      and orig_system    = in_system
      and name           = in_name;

   return disp_name;

   exception
      when no_data_found then
          disp_name := null;
          return disp_name;
      when others then
          disp_name := null;
          return disp_name;
end;

end FND_CONC_REQUEST_PKG;

/
