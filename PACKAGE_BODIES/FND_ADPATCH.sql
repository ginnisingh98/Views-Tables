--------------------------------------------------------
--  DDL for Package Body FND_ADPATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ADPATCH" AS
/* $Header: AFADPATB.pls 120.5 2006/07/26 21:59:40 mfisher noship $ */


FUNCTION Post_Patch(
	Session_ID in Number,   -- Autopatch Session ID
 	Message out nocopy Varchar2)	-- "Executed Successfully" or error.
    RETURN VARCHAR2 is		-- "TRUE" or "FALSE"

    appl_id number;
    resp_id number;
    user_id number;
    user_name varchar2(80);
    resp_name varchar2(80);
    resp_key varchar2(50);
    retcode number := null;
    num_pend number;

  BEGIN
      -- if requests exist short circuit return
      select count(*)
        into num_pend
        from fnd_application a,
             fnd_concurrent_programs p,
             fnd_concurrent_requests r
       where a.application_short_name = 'FND'
         and a.application_id = p.application_id
         and p.concurrent_program_name = 'FNDIRLOAD'
         and r.concurrent_program_id = p.concurrent_program_id
         and a.application_id = r.program_application_id
         and r.argument1 = to_char(Session_ID)
         and r.phase_code = 'P'
         and r.hold_flag='N'
         and r.requested_start_date <= sysdate + 0.01;

      if (num_pend > 0) then
             Message := 'Executed successfully - Pending iRep requests exist.';
             RETURN( 'TRUE' );
      end if;

      -- looks like a new request is needed, let's set context
      select application_id, responsibility_id, responsibility_key
        into appl_id, resp_id, resp_key
          from fnd_responsibility
        where responsibility_key = 'SYSTEM_ADMINISTRATOR';

      select user_id, user_name
        into user_id, user_name
          from fnd_user
      where user_name = 'SYSADMIN';

      -- Now initialize the environment for SYSADMIN
      fnd_global.apps_initialize(user_id, resp_id, appl_id);

      retcode := fnd_request.submit_request(
					application=>'FND',
					program=>'FNDIRLOAD',
					argument1 => Session_ID
					);

     if ((retcode is null) or (retcode <= 0)) then
             Message := fnd_message.get;
             RETURN ( 'FALSE' );
     else
	     Message := 'Executed successfully - iRep Loader request = ' ||
				to_char(retcode);
             RETURN( 'TRUE' );
     end if;

end;

end;

/
