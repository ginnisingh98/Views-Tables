--------------------------------------------------------
--  DDL for Package Body FNDCP_CRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FNDCP_CRM" as
/* $Header: AFCPCRMB.pls 120.1.12010000.3 2016/09/19 20:54:56 pferguso ship $ */



--
-- Returns the number of mgr procs mgr procs that can run the request
--

function mgr_up (reqid in number) return number is

  up number := 0;

begin
  select count(*)
    into up
    from Fnd_Concurrent_CRM_Requests
   where request_id = reqid;

  return (up);

  exception
    when no_data_found then
      return (0);
end mgr_up;


-- The following function is used by FND_REQUEST package in AFCPREQ*.pls
-- and src/process/fdprrc.lpc.  This used to be in AFCPREQ*.pls, but due
-- to the infamous 64K limit, had to move out to here.

  --
  -- Get conflicts domain id.
  --
  -- Extract the value in parameter named by cd_param.
  -- This value is a Conflicts Domain Name.
  -- If the domain by this name exists, return its cd_id.
  -- Else, insert a new domain by the name and return the new cd_id.
  --
  -- The routine is used at request submission time by programs that
  -- have the Conflicts Domain name defined in a parameter.
  --
  function get_cd_id (app      in varchar2,
		      program  in varchar2,
		      user_id  in number,
		      login_id in number,
		      cd_param in varchar2,
		      nargs    in number,
		      a1       in varchar2 default chr(0),
		      a2       in varchar2 default chr(0),
		      a3       in varchar2 default chr(0),
		      a4       in varchar2 default chr(0),
		      a5       in varchar2 default chr(0),
		      a6       in varchar2 default chr(0),
		      a7       in varchar2 default chr(0),
		      a8       in varchar2 default chr(0),
		      a9       in varchar2 default chr(0),
		      a10      in varchar2 default chr(0),
		      a11      in varchar2 default chr(0),
		      a12      in varchar2 default chr(0),
		      a13      in varchar2 default chr(0),
		      a14      in varchar2 default chr(0),
		      a15      in varchar2 default chr(0),
		      a16      in varchar2 default chr(0),
		      a17      in varchar2 default chr(0),
		      a18      in varchar2 default chr(0),
		      a19      in varchar2 default chr(0),
		      a20      in varchar2 default chr(0),
		      a21      in varchar2 default chr(0),
		      a22      in varchar2 default chr(0),
		      a23      in varchar2 default chr(0),
		      a24      in varchar2 default chr(0),
		      a25      in varchar2 default chr(0),
		      a26      in varchar2 default chr(0),
		      a27      in varchar2 default chr(0),
		      a28      in varchar2 default chr(0),
		      a29      in varchar2 default chr(0),
		      a30      in varchar2 default chr(0),
		      a31      in varchar2 default chr(0),
		      a32      in varchar2 default chr(0),
		      a33      in varchar2 default chr(0),
		      a34      in varchar2 default chr(0),
		      a35      in varchar2 default chr(0),
		      a36      in varchar2 default chr(0),
		      a37      in varchar2 default chr(0),
		      a38      in varchar2 default chr(0),
		      a39      in varchar2 default chr(0),
		      a40      in varchar2 default chr(0),
		      a41      in varchar2 default chr(0),
		      a42      in varchar2 default chr(0),
		      a43      in varchar2 default chr(0),
		      a44      in varchar2 default chr(0),
		      a45      in varchar2 default chr(0),
		      a46      in varchar2 default chr(0),
		      a47      in varchar2 default chr(0),
		      a48      in varchar2 default chr(0),
		      a49      in varchar2 default chr(0),
		      a50      in varchar2 default chr(0),
		      a51      in varchar2 default chr(0),
		      a52      in varchar2 default chr(0),
		      a53      in varchar2 default chr(0),
		      a54      in varchar2 default chr(0),
		      a55      in varchar2 default chr(0),
		      a56      in varchar2 default chr(0),
		      a57      in varchar2 default chr(0),
		      a58      in varchar2 default chr(0),
		      a59      in varchar2 default chr(0),
		      a60      in varchar2 default chr(0),
		      a61      in varchar2 default chr(0),
		      a62      in varchar2 default chr(0),
		      a63      in varchar2 default chr(0),
		      a64      in varchar2 default chr(0),
		      a65      in varchar2 default chr(0),
		      a66      in varchar2 default chr(0),
		      a67      in varchar2 default chr(0),
		      a68      in varchar2 default chr(0),
		      a69      in varchar2 default chr(0),
		      a70      in varchar2 default chr(0),
		      a71      in varchar2 default chr(0),
		      a72      in varchar2 default chr(0),
		      a73      in varchar2 default chr(0),
		      a74      in varchar2 default chr(0),
		      a75      in varchar2 default chr(0),
		      a76      in varchar2 default chr(0),
		      a77      in varchar2 default chr(0),
		      a78      in varchar2 default chr(0),
		      a79      in varchar2 default chr(0),
		      a80      in varchar2 default chr(0),
		      a81      in varchar2 default chr(0),
		      a82      in varchar2 default chr(0),
		      a83      in varchar2 default chr(0),
		      a84      in varchar2 default chr(0),
		      a85      in varchar2 default chr(0),
		      a86      in varchar2 default chr(0),
		      a87      in varchar2 default chr(0),
		      a88      in varchar2 default chr(0),
		      a89      in varchar2 default chr(0),
		      a90      in varchar2 default chr(0),
		      a91      in varchar2 default chr(0),
		      a92      in varchar2 default chr(0),
		      a93      in varchar2 default chr(0),
		      a94      in varchar2 default chr(0),
		      a95      in varchar2 default chr(0),
		      a96      in varchar2 default chr(0),
		      a97      in varchar2 default chr(0),
		      a98      in varchar2 default chr(0),
		      a99      in varchar2 default chr(0),
		      a100     in varchar2 default chr(0)) return number is

	cd_pos    number := 0;
	cdname    varchar2(30);
	cdid	  number := -1;
	flexfield fnd_dflex.dflex_r;
	flexinfo  fnd_dflex.dflex_dr;
	contexts  fnd_dflex.contexts_dr;
	segments  fnd_dflex.segments_dr;

	insert_error exception;

  begin

	fnd_dflex.get_flexfield (app, '$SRS$.'||program, flexfield, flexinfo);
	fnd_dflex.get_contexts (flexfield, contexts);
	fnd_dflex.get_segments (fnd_dflex.make_context (
					flexfield, contexts.context_code (
						contexts.global_context)),
				segments,
				TRUE);

	for i in 1..segments.nsegments loop
	  if segments.segment_name (i) = cd_param then
	    cd_pos := i;
	    exit;
	  end if;
	end loop;

	if (cd_pos = 0) or (cd_pos > nargs) then
	  return (-1);
	end if;

	if cd_pos =  1 then cdname :=  a1; goto end_cd; end if;
	if cd_pos =  2 then cdname :=  a2; goto end_cd; end if;
	if cd_pos =  3 then cdname :=  a3; goto end_cd; end if;
	if cd_pos =  4 then cdname :=  a4; goto end_cd; end if;
	if cd_pos =  5 then cdname :=  a5; goto end_cd; end if;
	if cd_pos =  6 then cdname :=  a6; goto end_cd; end if;
	if cd_pos =  7 then cdname :=  a7; goto end_cd; end if;
	if cd_pos =  8 then cdname :=  a8; goto end_cd; end if;
	if cd_pos =  9 then cdname :=  a9; goto end_cd; end if;
	if cd_pos = 10 then cdname := a10; goto end_cd; end if;
	if cd_pos = 11 then cdname := a11; goto end_cd; end if;
	if cd_pos = 12 then cdname := a12; goto end_cd; end if;
	if cd_pos = 13 then cdname := a13; goto end_cd; end if;
	if cd_pos = 14 then cdname := a14; goto end_cd; end if;
	if cd_pos = 15 then cdname := a15; goto end_cd; end if;
	if cd_pos = 16 then cdname := a16; goto end_cd; end if;
	if cd_pos = 17 then cdname := a17; goto end_cd; end if;
	if cd_pos = 18 then cdname := a18; goto end_cd; end if;
	if cd_pos = 19 then cdname := a19; goto end_cd; end if;
	if cd_pos = 20 then cdname := a20; goto end_cd; end if;
	if cd_pos = 21 then cdname := a21; goto end_cd; end if;
	if cd_pos = 22 then cdname := a22; goto end_cd; end if;
	if cd_pos = 23 then cdname := a23; goto end_cd; end if;
	if cd_pos = 24 then cdname := a24; goto end_cd; end if;
	if cd_pos = 25 then cdname := a25; goto end_cd; end if;
	if cd_pos = 26 then cdname := a26; goto end_cd; end if;
	if cd_pos = 27 then cdname := a27; goto end_cd; end if;
	if cd_pos = 28 then cdname := a28; goto end_cd; end if;
	if cd_pos = 29 then cdname := a29; goto end_cd; end if;
	if cd_pos = 30 then cdname := a30; goto end_cd; end if;
	if cd_pos = 31 then cdname := a31; goto end_cd; end if;
	if cd_pos = 32 then cdname := a32; goto end_cd; end if;
	if cd_pos = 33 then cdname := a33; goto end_cd; end if;
	if cd_pos = 34 then cdname := a34; goto end_cd; end if;
	if cd_pos = 35 then cdname := a35; goto end_cd; end if;
	if cd_pos = 36 then cdname := a36; goto end_cd; end if;
	if cd_pos = 37 then cdname := a37; goto end_cd; end if;
	if cd_pos = 38 then cdname := a38; goto end_cd; end if;
	if cd_pos = 39 then cdname := a39; goto end_cd; end if;
	if cd_pos = 40 then cdname := a40; goto end_cd; end if;
	if cd_pos = 41 then cdname := a41; goto end_cd; end if;
	if cd_pos = 42 then cdname := a42; goto end_cd; end if;
	if cd_pos = 43 then cdname := a43; goto end_cd; end if;
	if cd_pos = 44 then cdname := a44; goto end_cd; end if;
	if cd_pos = 45 then cdname := a45; goto end_cd; end if;
	if cd_pos = 46 then cdname := a46; goto end_cd; end if;
	if cd_pos = 47 then cdname := a47; goto end_cd; end if;
	if cd_pos = 48 then cdname := a48; goto end_cd; end if;
	if cd_pos = 49 then cdname := a49; goto end_cd; end if;
	if cd_pos = 50 then cdname := a50; goto end_cd; end if;
	if cd_pos = 51 then cdname := a51; goto end_cd; end if;
	if cd_pos = 52 then cdname := a52; goto end_cd; end if;
	if cd_pos = 53 then cdname := a53; goto end_cd; end if;
	if cd_pos = 54 then cdname := a54; goto end_cd; end if;
	if cd_pos = 55 then cdname := a55; goto end_cd; end if;
	if cd_pos = 56 then cdname := a56; goto end_cd; end if;
	if cd_pos = 57 then cdname := a57; goto end_cd; end if;
	if cd_pos = 58 then cdname := a58; goto end_cd; end if;
	if cd_pos = 59 then cdname := a59; goto end_cd; end if;
	if cd_pos = 60 then cdname := a60; goto end_cd; end if;
	if cd_pos = 61 then cdname := a61; goto end_cd; end if;
	if cd_pos = 62 then cdname := a62; goto end_cd; end if;
	if cd_pos = 63 then cdname := a63; goto end_cd; end if;
	if cd_pos = 64 then cdname := a64; goto end_cd; end if;
	if cd_pos = 65 then cdname := a65; goto end_cd; end if;
	if cd_pos = 66 then cdname := a66; goto end_cd; end if;
	if cd_pos = 67 then cdname := a67; goto end_cd; end if;
	if cd_pos = 68 then cdname := a68; goto end_cd; end if;
	if cd_pos = 69 then cdname := a69; goto end_cd; end if;
	if cd_pos = 70 then cdname := a70; goto end_cd; end if;
	if cd_pos = 71 then cdname := a71; goto end_cd; end if;
	if cd_pos = 72 then cdname := a72; goto end_cd; end if;
	if cd_pos = 73 then cdname := a73; goto end_cd; end if;
	if cd_pos = 74 then cdname := a74; goto end_cd; end if;
	if cd_pos = 75 then cdname := a75; goto end_cd; end if;
	if cd_pos = 76 then cdname := a76; goto end_cd; end if;
	if cd_pos = 77 then cdname := a77; goto end_cd; end if;
	if cd_pos = 78 then cdname := a78; goto end_cd; end if;
	if cd_pos = 79 then cdname := a79; goto end_cd; end if;
	if cd_pos = 80 then cdname := a80; goto end_cd; end if;
	if cd_pos = 81 then cdname := a81; goto end_cd; end if;
	if cd_pos = 82 then cdname := a82; goto end_cd; end if;
	if cd_pos = 83 then cdname := a83; goto end_cd; end if;
	if cd_pos = 84 then cdname := a84; goto end_cd; end if;
	if cd_pos = 85 then cdname := a85; goto end_cd; end if;
	if cd_pos = 86 then cdname := a86; goto end_cd; end if;
	if cd_pos = 87 then cdname := a87; goto end_cd; end if;
	if cd_pos = 88 then cdname := a88; goto end_cd; end if;
	if cd_pos = 89 then cdname := a89; goto end_cd; end if;
	if cd_pos = 90 then cdname := a90; goto end_cd; end if;
	if cd_pos = 91 then cdname := a91; goto end_cd; end if;
	if cd_pos = 92 then cdname := a92; goto end_cd; end if;
	if cd_pos = 93 then cdname := a93; goto end_cd; end if;
	if cd_pos = 94 then cdname := a94; goto end_cd; end if;
	if cd_pos = 95 then cdname := a95; goto end_cd; end if;
	if cd_pos = 96 then cdname := a96; goto end_cd; end if;
	if cd_pos = 97 then cdname := a97; goto end_cd; end if;
	if cd_pos = 98 then cdname := a98; goto end_cd; end if;
	if cd_pos = 99 then cdname := a99; goto end_cd; end if;
	if cd_pos = 100 then cdname := a100; end if;

	<<end_cd>>

	begin -- select block
	  select cd_id
	    into cdid
	    from fnd_conflicts_domain
	   where cd_name = cdname;

	  exception
	    when no_data_found then
	      begin -- insert block
		select fnd_conflicts_domain_s.nextval
		  into cdid
		  from sys.dual;

		insert
		  into fnd_conflicts_domain (
		       cd_id,
		       cd_name,
		       user_cd_name,
		       runalone_flag,
		       last_update_date,
		       last_updated_by,
		       creation_date,
		       created_by,
		       last_update_login,
                       dynamic)
		values (
		       cdid,
		       cdname,
		       cdname,
		       'N',
		       sysdate,
		       user_id,
		       sysdate,
		       user_id,
		       login_id,
		       'Y');

		if (sql%rowcount = 0) then
		  raise insert_error;
		end if;

		exception
		  when no_data_found then
		    fnd_message.set_name ('FND',
					  'Too many rows in sys.dual');
		    return (-1);

		  when insert_error then
		    fnd_message.set_name ('FND', 'SQL-Generic error');
		    fnd_message.set_token ('ERRNO', sqlcode, FALSE);
		    fnd_message.set_token ('REASON', sqlerrm, FALSE);
		    fnd_message.set_token ('ROUTINE',
			'SUBMIT: conflicts_domain_insert_error', FALSE);
		    return (-1);

		  when dup_val_on_index then
		    select cd_id
	            into cdid
	            from fnd_conflicts_domain
		    where cd_name = cdname;


		  when others then
		    raise;
	      end; -- insert block

	    when others then
	      raise;
	end; -- select block

	return (cdid);

	exception
	  when others then
	    fnd_message.set_name ('FND', 'SQL-Generic error');
	    fnd_message.set_token ('ERRNO', sqlcode, FALSE);
	    fnd_message.set_token ('REASON', sqlerrm, FALSE);
	    fnd_message.set_token (
				'ROUTINE', 'SUBMIT: conflicts_domain', FALSE);
	  return (-1);

  end get_cd_id;


--
-- Remove all unused 'dynamic' conflict domains
-- in order to manage the size of the table.
--
procedure purge_dynamic_domains is
begin

    delete from fnd_conflicts_domain fcd
    where dynamic = 'Y'
    and not exists (select 'X'
                    from fnd_concurrent_requests fcr
		    where fcr.cd_id = fcd.cd_id
		    and phase_code in ('P', 'R'));



end purge_dynamic_domains;


--
-- Used by the CRM to determine if a request has been picked up by a manager
-- If the row is not locked and the phase is still 'P' we will consider it not running.
-- If the row is locked or the phase is not 'P' then assume a manager has picked it up
--
function is_req_running (reqid in number) return varchar2 is

phase  varchar2(1);
resource_busy   exception;
pragma exception_init( resource_busy, -54 );

begin

  select phase_code into phase from fnd_concurrent_requests where request_id = reqid for update of phase_code nowait;

  -- We got the lock. Request is not running only if the phase code is still P
  if phase = 'P' then
    return 'N';
  else
    return 'Y';
  end if;

exception
  when resource_busy then
    -- We didn't get the lock, assume manager is running request.
    return 'Y';
  when others then
    return 'N';

end is_req_running;


end FNDCP_CRM;

/
