--------------------------------------------------------
--  DDL for Package Body FND_CONC_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_PP" as
/* $Header: AFCPPPIB.pls 120.2 2005/08/22 06:54:37 aweisber ship $ */


/* Exceptions */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501); -- program error

/* Message buffer */
internal_messages VARCHAR2(10000);


--
-- Set the contents of the message buffer
--
PROCEDURE message_add(msg VARCHAR2) IS
BEGIN
   internal_messages := internal_messages || msg || fnd_global.newline;
END;


--
-- Returns the contents of the message buffer
--

FUNCTION message return varchar2 is
Begin
   return(internal_messages);
end;


--
-- Clear the message buffer.
--
PROCEDURE message_init IS
BEGIN
   internal_messages := '';
END;

/* ------------------------------------------------------------ */
PROCEDURE check_notnull(val IN VARCHAR2) IS
BEGIN
   IF(val IS NULL) THEN
      message_add('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN NUMBER) IS
BEGIN
   IF(val IS NULL) THEN
      message_add('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN DATE) IS
BEGIN
   IF(val IS NULL) THEN
      message_add('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;
/* ------------------------------------------------------------ */


--
-- get the application id, given the name (or short name)
--
FUNCTION application_id_f(application_name_in IN VARCHAR2)
  RETURN fnd_application.application_id%TYPE
  IS
     application_id_ret fnd_application.application_id%TYPE;
BEGIN
   IF(application_name_in IS NULL) THEN
      message_add('A null application_name was specified.');
      RAISE bad_parameter;
   END IF;
   /* Check the short name first. */
   SELECT application_id
     INTO application_id_ret
     FROM fnd_application
     WHERE application_short_name = application_name_in;
   RETURN application_id_ret;
EXCEPTION
   WHEN no_data_found THEN  /* Try the translated name. */
     BEGIN
       SELECT application_id
         INTO application_id_ret
         FROM fnd_application_tl
        WHERE application_name = application_name_in
          AND rownum = 1;
       RETURN application_id_ret;
     EXCEPTION
       when NO_DATA_FOUND then
         message_add('Invalid application name: ' || application_name_in);
         RAISE bad_parameter;
     END;
END;

/* Get a concurrent executable ID given appl ID and subroutine name */
FUNCTION concurrent_executable_id_f(program_application_id number,
                                 exec_name varchar2) return number is
  exec_id number;

BEGIN
   IF(exec_name IS NULL) THEN
      message_add('A null executable name was specified.');
      RAISE bad_parameter;
   END IF;

  SELECT EXECUTABLE_ID
    INTO exec_id
    FROM FND_EXECUTABLES
   WHERE application_id = program_application_id
     AND executable_name = exec_name;

  RETURN exec_id;

EXCEPTION
  WHEN no_data_found THEN
    message_add('Could not find executable: '||exec_name);
    RAISE bad_parameter;
END;


-- Procedure
--   Assign
--
-- Purpose
--   Assign a stored procedure to a request.  Returns step number if successful,--   a negative number if not.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Exec_Name	     - Executable Name
--
--   Req_ID	     - request ID
--
--   S_Flag	     - do we execute if request was successful? ['Y'/'N']
--
--   W_Flag	     - do we execute if request completed with status warning?
--			['Y'/'N']
--
--   F_Flag	     - do we execute if request failed? ['Y'/'N']
--
--   Arg1 ->  Arg10  - Arguments that may be retrieved during execution.
--
FUNCTION	Assign(	Application 	IN Varchar2,
			Executable_Name IN Varchar2,
			Req_ID		IN Number,
			S_Flag		IN Varchar2,
			W_Flag		IN Varchar2,
			F_Flag		IN Varchar2,
			Arg1		IN Varchar2,
			Arg2		IN Varchar2,
			Arg3		IN Varchar2,
			Arg4		IN Varchar2,
			Arg5		IN Varchar2,
			Arg6		IN Varchar2,
			Arg7		IN Varchar2,
			Arg8		IN Varchar2,
			Arg9		IN Varchar2,
			Arg10		IN Varchar2) return number is

  app_id number;
  login_id number;
  user_id number;
  exec_id number;
  step_id number;
  ins_num number;
begin
   message_init;

   begin
	select OPS_INSTANCE into
 	ins_num
	from fnd_concurrent_requests
	where request_id = Req_ID;
   Exception when others then
        message_add('Bad request ID.');
        return(-1);
   end;

   begin
	login_id := fnd_global.login_id;

	user_id := FND_GLOBAL.user_id;
          if (user_id is null) then
         	user_id := -1;
          end if;
   Exception when others then
        message_add('Error while getting login_id/user_id.');
        return(-1);
   End;

   begin
        app_id := application_id_f(Application);
  	exec_id := concurrent_executable_id_f(app_id, Executable_Name);
   Exception
        when bad_parameter then
           return -1;
        when others then
           message_add('Unknown error while getting application/executable id.');
           return(-1);
   End;

   begin
	Select count(*)
  	into step_id
   	from fnd_conc_pp_actions
   	where concurrent_request_id = Req_ID
   	and Action_Type = 4;

   	If (step_id > 0) then
     		Select max(SEQUENCE)
     		into step_id
     		from fnd_conc_pp_actions
     		where concurrent_request_id = Req_ID
     		and Action_Type = 4;
   	End If;

   Exception when others then
        message_add('Error while querying fnd_conc_pp_actions.');
	return(-1);
   End;


   step_id := step_id + 1;

   begin
	Insert into fnd_conc_pp_actions
     	   (CONCURRENT_REQUEST_ID,ACTION_TYPE, STATUS_S_FLAG, STATUS_W_FLAG,
	   STATUS_F_FLAG, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
	   LAST_UPDATE_LOGIN, CREATED_BY, PROGRAM_APPLICATION_ID, PROGRAM_ID,
	   Argument1, Argument2, Argument3, Argument4, Argument5,
	   Argument6, Argument7, Argument8, Argument9, Argument10,
	   SEQUENCE, OPS_INSTANCE)
     	Select Req_ID, 4, S_Flag, W_Flag,
           F_Flag, sysdate, user_id, sysdate,
           fnd_global.login_id, user_id, app_id, exec_id,
           Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10,
	   step_id, ins_num from dual;
   Exception when others then
        message_add('Error while inserting into fnd_conc_pp_actions.');
        return(-1);
   End;

   return step_id;

end;

-- Procedure
--  Retrieve
--
-- Purpose
--  Retrieve stored arguments
--
-- Arguments:
--   Req_ID	     - request ID
--
--   Step Number     - Step Number
--
--   Arg1 ->  Arg10  - Arguments that were set at assignment.
--
--   Returns negative number on failure
--
FUNCTION       Retrieve(Req_ID		IN Number,
			Step  		IN Number,
                        app_short_name	OUT NOCOPY VARCHAR2,
                        exec_name	OUT NOCOPY VARCHAR2,
                        S_Flag          OUT NOCOPY Varchar2,
                        W_Flag          OUT NOCOPY Varchar2,
                        F_Flag          OUT NOCOPY Varchar2,
			Arg1		OUT NOCOPY Varchar2,
			Arg2		OUT NOCOPY Varchar2,
			Arg3		OUT NOCOPY Varchar2,
			Arg4		OUT NOCOPY Varchar2,
			Arg5		OUT NOCOPY Varchar2,
			Arg6		OUT NOCOPY Varchar2,
			Arg7		OUT NOCOPY Varchar2,
			Arg8		OUT NOCOPY Varchar2,
			Arg9		OUT NOCOPY Varchar2,
			Arg10		OUT NOCOPY Varchar2) return number is

app_id number;
exec_id number;

begin
   begin
      select STATUS_S_FLAG, STATUS_W_FLAG, STATUS_F_FLAG,
    	PROGRAM_APPLICATION_ID, PROGRAM_ID,
	Argument1, Argument2, Argument3, Argument4, Argument5,
	Argument6, Argument7, Argument8, Argument9, Argument10
      into S_Flag, W_Flag, F_Flag, app_id, exec_id,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9, Arg10
      from fnd_conc_pp_actions
      where CONCURRENT_REQUEST_ID = Req_ID and
	sequence = Step and
	action_type = 4;
   exception
      when NO_DATA_FOUND then
           message_add('Request ID, Sequence, Action Type ('||to_char(Req_ID)||
		', ' || TO_CHAR(Step) || ', 4) not found.');
           return(-1);
      when others then
           message_add('Error while querying fnd_conc_pp_actions.');
           return(-1);
   End;

   begin
      select Application_short_name
      into app_short_name
      from FND_APPLICATION
      where application_id = app_id;
   exception
      when NO_DATA_FOUND then
           message_add('Bad Application ID');
           return(-1);
      when others then
           message_add('Error while querying fnd_application.');
           return(-1);
   end;

   begin
      select Executable_Name
      into exec_name
      from FND_EXECUTABLES
      where application_id = app_id
	and executable_id = exec_id;
   exception
      when NO_DATA_FOUND then
           message_add('Bad Executible ID');
           return(-1);
      when others then
           message_add('Error while querying fnd_executables.');
           return(-1);
   end;

   return 0;
end;

end FND_CONC_PP;

/
