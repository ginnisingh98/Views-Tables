--------------------------------------------------------
--  DDL for Package Body FND_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MANAGER" AS
/* $Header: AFCPMGRB.pls 120.2.12000000.2 2007/07/13 10:02:52 ggupta ship $ */


/* Exceptions */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501); -- program error

/* Flag for datamerge or customer data */
who_mode VARCHAR2(20) := 'customer_data';  /* customer_data or seed_data */

/* Message buffer */
internal_messages VARCHAR2(10000);

--
-- Set the contents of the message buffer */
--
PROCEDURE message(msg VARCHAR2) IS
BEGIN
   internal_messages := internal_messages || msg || fnd_global.newline;
END;

--
-- Clear the message buffer.
--
PROCEDURE message_init IS
BEGIN
   internal_messages := '';
END;


/* ------------------------------------------------------------ */
/*  who information functions                                   */
/* ------------------------------------------------------------ */

FUNCTION customer_mode RETURN BOOLEAN IS
BEGIN
   IF(who_mode = 'customer_data') THEN
      RETURN TRUE;
    ELSIF(who_mode = 'seed_data') THEN
      RETURN FALSE;
    ELSE
      message('bad session mode:' || who_mode);
      message('use set_session_mode to specify');
      RAISE bad_parameter;
   END IF;
END;


FUNCTION last_updated_by_f(l_updated_by IN NUMBER DEFAULT NULL)
  RETURN NUMBER IS
BEGIN
   IF(l_updated_by IS NOT NULL) THEN
      RETURN l_updated_by;
    ELSIF(customer_mode) THEN
      RETURN -1;
    ELSE
      RETURN 1;
   END IF;
END;

FUNCTION last_update_date_f(l_update_date IN DATE DEFAULT NULL)
  RETURN DATE IS
BEGIN
   IF(l_update_date IS NOT NULL) THEN
      RETURN l_update_date;
    ELSE
       RETURN Sysdate;
    END IF;
END;

FUNCTION created_by_f(c_updated_by IN NUMBER DEFAULT NULL)
  RETURN NUMBER IS
BEGIN
    RETURN last_updated_by_f(c_updated_by);
END;

FUNCTION creation_date_f(c_update_date IN DATE DEFAULT NULL)
  RETURN DATE IS
BEGIN
   IF(c_update_date IS NOT NULL) THEN
      RETURN c_update_date;
    ELSIF(customer_mode) THEN
       RETURN Sysdate;
    ELSE
       RETURN To_date('01011980', 'MMDDYYYY');
   END IF;
END;

FUNCTION last_update_login_f RETURN NUMBER IS
BEGIN
   return 0;
END;


/* ------------------------------------------------------------ */
PROCEDURE check_notnull(val IN VARCHAR2) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN NUMBER) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
      RAISE bad_parameter;
   END IF;
END;

PROCEDURE check_notnull(val IN DATE) IS
BEGIN
   IF(val IS NULL) THEN
      message('A NULL value was specified for a NOT NULL parameter.');
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
      message('A null application_name was specified.');
      RAISE bad_parameter;
   END IF;
   /* Check the short name first. */
   SELECT application_id
     INTO application_id_ret
     FROM fnd_application
     WHERE upper(application_short_name) = upper(application_name_in);
   RETURN application_id_ret;
EXCEPTION
   WHEN no_data_found THEN  /* Try the translated name. */
     BEGIN
       SELECT application_id
         INTO application_id_ret
         FROM fnd_application_tl
        WHERE upper(application_name) = upper(application_name_in)
          AND rownum = 1;
       RETURN application_id_ret;
     EXCEPTION
       when NO_DATA_FOUND then
         message('Invalid application name: ' || application_name_in);
         RAISE bad_parameter;
     END;
END;


--
-- Get a concurrent program ID given appl ID and short name
--
FUNCTION concurrent_program_id_f(program_application_id number,
				 program_short_name varchar2) return number is
  program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
BEGIN
  SELECT concurrent_program_id
    INTO program_id
    FROM fnd_concurrent_programs
   WHERE application_id = program_application_id
     AND upper(concurrent_program_name) = upper(program_short_name);

  RETURN program_id;

EXCEPTION
  WHEN no_data_found THEN
    message('Could not find program: '||program_short_name);
    RAISE bad_parameter;
END;

--
-- Get a concurrent library ID given appl ID and name
--
FUNCTION library_id_f(lib_appl_id number,
		      lib_name varchar2) return number is
  lib_id fnd_concurrent_processors.concurrent_processor_id%type;
begin
  select concurrent_processor_id
    into lib_id
    from fnd_concurrent_processors
   where application_id = lib_appl_id
     and lib_name = concurrent_processor_name;

  return lib_id;

exception
  when no_data_found then
    message('Could not find library: '|| lib_name);
    raise bad_parameter;
end;

--
-- Get a manager ID given appl ID and name
--
FUNCTION manager_id_f(mgr_appl_id number,
		      mgr_name varchar2) return number is
  mgr_id fnd_concurrent_queues.concurrent_queue_id%type;
begin
  select concurrent_queue_id
    into mgr_id
    from fnd_concurrent_queues
   where application_id = mgr_appl_id
     and upper(mgr_name) = upper(concurrent_queue_name);

  return mgr_id;

exception
  when no_data_found then
    message('Could not find manager: '|| mgr_name);
    raise bad_parameter;
end;

--
-- Get a Service ID given sevice handle
--
FUNCTION service_id_f(svc_handle varchar2) return number is
  svc_id number;
begin
  select SERVICE_ID
    into svc_id
    from FND_CP_SERVICES
   where upper(svc_handle) = upper(SERVICE_HANDLE);

  return svc_id;

exception
  when no_data_found then
    message('Could not find service handle: '|| svc_handle);
    raise bad_parameter;
end;

--
-- Get a Node given node name
--
FUNCTION node_name_f(nodename varchar2) return varchar2 is
  nname varchar2(31);
begin
  select node_name
    into nname
    from FND_NODES
   where upper(nodename) = upper(NODE_NAME);

  return nname;

exception
  when no_data_found then
    message('Could not find node: '|| nodename);
    raise bad_parameter;
end;

/* ------------------------------------------------------------ */

--
-- Procedure
--   SET_SESSION_MODE
--
-- Purpose
--   Sets the package mode for the current session.
--customer_data
-- Arguments:
--   session_mode - 'seed_data' if new data is for Datamerge.
--                  'customer_data' is the default.
--
PROCEDURE set_session_mode(session_mode IN VARCHAR2) IS
BEGIN
   IF(lower(session_mode) NOT IN ('customer_data', 'seed_data')) THEN
      message('bad mode:'|| session_mode);
      message('valid values are: customer_data, seed_data');
      RAISE bad_parameter;
   END IF;
   who_mode := lower(session_mode);
END;


-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
FUNCTION message RETURN VARCHAR2 IS
BEGIN
   RETURN internal_messages;
END;


-- Function
--  GET_SPECIALIZATION_TYPE_ID
--
-- Purpose
--  Get a Type (Object) ID  from FND_CONCURRENT_QUEUE_CONTENT
--  (fcqc.TYPE_ID) given the Object's Name, Application ID, and
--  Lookup Code
--
-- Arguments:
--  obj_name    - The name of the specialization object
--                (complex rule name/oracle username/program name/
--                request class name/apps username)
--  obj_appl_id - The application id (fcqc.TYPE_APPLICATION_ID) of the
--                specialization object
--  obj_code    - The lookup code (fcqc.TYPE_CODE) of the specialization
--                object which corresponds to CP_SPECIAL_RULES lookup type
--                (C/O/P/R/U)

FUNCTION get_specialization_type_id(obj_name varchar2,
                                    obj_appl_id number,
                                    obj_code varchar2) return number is

  obj_id number;

begin
  if (obj_code = 'C') then
    begin
      select complex_rule_id
        into obj_id
        from fnd_concurrent_complex_rules
       where application_id = obj_appl_id
         and complex_rule_name = obj_name;
    exception
      when no_data_found then
        message('Could not find rule: '||obj_name);
        raise bad_parameter;
    end;
  elsif (obj_code = 'O') then
    begin
      select oracle_id
        into obj_id
        from fnd_oracle_userid
       where oracle_username = obj_name;
    exception
      when no_data_found then
        message('Could not find Oracle ID: '|| obj_name);
        raise bad_parameter;
    end;
  elsif (obj_code = 'P') then
    if (obj_name is not null) then
      obj_id := concurrent_program_id_f(obj_appl_id, obj_name);
    end if;
  elsif (obj_code = 'R') then
    begin
      select request_class_id
        into obj_id
        from fnd_concurrent_request_class
       where application_id = obj_appl_id
         and request_class_name = obj_name;
    exception
      when no_data_found then
        message('Could not find request type: '||obj_name);
        raise bad_parameter;
    end;
  else
    begin
      select user_id
        into obj_id
        from fnd_user
       where user_name = obj_name;
    exception
      when no_data_found then
        message('Could not find user: '||obj_name);
        raise bad_parameter;
    end;
  end if;
  return obj_id;
end;

/* ------------------------------------------------------------ */

-- Procedure
--   REGISTER
--
-- Purpose
--   Register a concurrent manager.
--
-- Arguments
--   Manager         - Concurrent manager name.
--   Application     - Manager application short name.
--   Short_Name      - Manager short (non-translated) name.
--   Description     - Manager description (Optional).
--   Type            - 'Concurrent Manager', 'Internal Monitor', or
--                     'Transaction Manager'.
--   Cache_Size      - Request cache size (Optional; Concurrent Managers only).
--   Data_Group      - Data group name (Transaction Managers only).
--   Primary_Node    - Primary node (optional).
--   Primary_Queue   - Primary OS queue (Optional).
--   Secondary_Node  - Secondary node (optional).
--   Secondary_Queue - Secondary OS queue (Optional).
--   Library         - Concurrent processing library (e.g. FNDLIBR).
--   Library_Application - Library application short name.
--   Data_Group_id   - Optional.  Overrides 'data_group' parameter.
--   Language_code   - Language code for translated values.
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE register(manager		IN VARCHAR2,
		   application          IN VARCHAR2,
                   short_name           IN VARCHAR2,
		   description		IN VARCHAR2 DEFAULT NULL,
		   type			IN VARCHAR2,
		   cache_size		IN NUMBER   DEFAULT NULL,
		   data_group		IN VARCHAR2 DEFAULT NULL,
		   primary_node		IN VARCHAR2 DEFAULT NULL,
		   primary_queue        IN VARCHAR2 DEFAULT NULL,
		   secondary_node       IN VARCHAR2 DEFAULT NULL,
		   secondary_queue 	IN VARCHAR2 DEFAULT NULL,
		   library		IN VARCHAR2,
		   library_application  IN VARCHAR2,
		   data_group_id        IN NUMBER   DEFAULT NULL,
                   language_code        IN VARCHAR2 DEFAULT 'US',
                   last_update_date     IN DATE     DEFAULT NULL,
                   last_updated_by      IN NUMBER   DEFAULT NULL
                   ) is

  mgr_appl_id fnd_application.application_id%TYPE;
  mgr_id      fnd_concurrent_queues.concurrent_queue_id%TYPE;
  type_code   fnd_concurrent_queues.manager_type%TYPE;
  dg_id       fnd_data_groups.data_group_id%TYPE;
  lib_appl_id fnd_application.application_id%TYPE;
  lib_id      fnd_concurrent_processors.concurrent_processor_id%TYPE;

  last_update_login fnd_concurrent_queues.last_update_login%TYPE
    := last_update_login_f;
  l_update_date fnd_concurrent_queues.last_update_date%TYPE
    := last_update_date_f(last_update_date);
  l_updated_by fnd_concurrent_queues.last_updated_by%TYPE
    := last_updated_by_f(last_updated_by);
  creation_date fnd_concurrent_queues.creation_date%TYPE
    := creation_date_f(last_update_date);
  created_by fnd_concurrent_queues.created_by%TYPE
    := created_by_f(last_updated_by);

begin
  message_init;

  check_notnull(manager);
  check_notnull(short_name);
  check_notnull(application);
  check_notnull(type);
  check_notnull(library);
  check_notnull(library_application);

  /* Get new ID */
  select fnd_concurrent_queues_s.nextval
    into mgr_id
    from sys.dual;

  mgr_appl_id := application_id_f(application);
  lib_appl_id := application_id_f(library_application);

  /* Get type code */
  begin
    select lookup_code
      into type_code
      from fnd_lookup_values
      where lookup_type = 'CP_MANAGER_TYPE'
        and upper(meaning) = upper(type)
        and rownum = 1;
  exception
    when no_data_found then
      message('Invalid manager type: ' || type);
      raise bad_parameter;
  end;

  /* Check shortname for invalid spaces */
  if ( instr(short_name, ' ') > 0 ) then
    message('Short Name must not contain spaces ');
    raise bad_parameter;
  end if;

  if (type_code = 0) then
    message('Cannot create an Internal Manager');
    raise bad_parameter;
  end if;

  /* Check cache size */
  if (type_code <> 1 and cache_size is not null) then
    message('cache_size cannot be specified for a '||type);
    raise bad_parameter;
  end if;

  if (cache_size is not null and cache_size < 0) then
    message('Invalid cache_size: '||to_char(cache_size));
    raise bad_parameter;
  end if;

  /* Check data group */
  if (type_code <> 3 and
     (data_group is not null or data_group_id is not null)) then
    message('Specify a data group only for Transaction Managers');
    raise bad_parameter;
  elsif (type_code = 3 and data_group is null
         and data_group_id is null) then
    message('Data group must be specified for Transaction Managers');
    raise bad_parameter;
  end if;

  if (data_group_id is not null) then
    begin
      select fdg.data_group_id
        into dg_id
        from fnd_data_groups fdg
       where fdg.data_group_id = register.data_group_id;
    exception
      when no_data_found then
        message('Cannot find data group with id: '||data_group_id);
        raise bad_parameter;
    end;
  elsif (data_group is not null) then
    begin
      select fdg.data_group_id
        into dg_id
        from fnd_data_groups fdg
       where data_group = data_group_name;
    exception
      when no_data_found then
        message('Cannot find data group: '||data_group);
        raise bad_parameter;
    end;
  end if;

  /* Get Library */
  lib_id := library_id_f(lib_appl_id, library);

  /* Make sure no bad data in tl table */
  delete from fnd_concurrent_queues_tl
   where application_id = mgr_appl_id
     and language in  (select l.language_code
                       from fnd_languages l
                      where l.installed_flag in ('I', 'B'))
     and (concurrent_queue_name = short_name
      or user_concurrent_queue_name = manager);

 /* Do the insert */
  insert into fnd_concurrent_queues
		(application_id, concurrent_queue_id, concurrent_queue_name,
		 processor_application_id, concurrent_processor_id,
		 running_processes, max_processes, creation_date, created_by,
		 last_update_date, last_updated_by, last_update_login,
		 cache_size, control_code, manager_type,
		 node_name, node_name2, os_queue, os_queue2, data_group_id,
                 enabled_flag)
	 values
		(mgr_appl_id, mgr_id, short_name,
		 lib_appl_id, lib_id,
		 0, 0, creation_date, created_by,
		 l_update_date, l_updated_by, last_update_login,
		 cache_size, 'E', type_code,
		 primary_node, secondary_node, primary_queue, secondary_queue,
		 dg_id, 'Y');

  insert into FND_CONCURRENT_QUEUES_TL (
    user_concurrent_queue_name, application_id, concurrent_queue_id,
    concurrent_queue_name, creation_date, created_by,
    last_update_date, last_updated_by, last_update_login,
    description, language, source_lang
  ) select
    manager, mgr_appl_id, mgr_id, short_name,
    register.creation_date, register.created_by,  l_update_date,
    l_updated_by, register.last_update_login, register.description,
    l.language_code, register.language_code
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_CONCURRENT_QUEUES_TL T
    where T.APPLICATION_ID = mgr_appl_id
    and T.CONCURRENT_QUEUE_ID = mgr_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

end register;

-- Procedure
--   REGISTER_SVC
--
-- Purpose
--   Register a Service .
--
-- Arguments
--   Service_name     - Service name.
--   Service_Handle  - Service Handle
--   DESCRIPTION
--   CARTRIDGE_HANDLE
--   ALLOW_MULTIPLE_PROC_INSTANCE -Y/N
--   ALLOW_MULTIPLE_PROC_NODE -Y/N
--   MIGRATE_ON_FAILURE -Y/N
--   ALLOW_SUSPEND -Y/N
--   ALLOW_VERIFY -Y/N
--   ALLOW_PARAMETER -Y/N
--   ALLOW_START -Y/N
--   ALLOW_RESTART -Y/N
--   ALLOW_RCG -Y/N
--   ALLOW_CREATE - Y/N
--   ALLOW_EDIT - Y/N
--   PARAMETER_CHANGE_ACTION  V=Verify, R=Restart
--   DEVELOPER_PARAMETERS
--   SERVER_TYPE
--   ENV_FILE_NAME -might not be used
--   SERVICE_CLASS
--   SERVICE_INSTANCE_CLASS
--   OAM_DISPLAY_ORDER    -if null default to max(OAM_DISPLAY_ORDER) +10
--   language_code        IN VARCHAR2 DEFAULT 'US'
--   DEBUG_CHANGE_ACTION N=No followup action V=Verify X=Dynamic change off
--   ENABLED -Y/N
--   CARTRIDGE_APPLICATION - Defaults to 'FND'
--   DEBUG_TYPE
--   SERVICE_PLURAL_NAME
--   ALLOW_MULTIPLE_PROC_SI -Y/N
--   DEFAULT_DEBUG_LEVEL

PROCEDURE register_svc (
 SERVICE_NAME                    IN  VARCHAR2,
 SERVICE_HANDLE                  IN  VARCHAR2,
 DESCRIPTION                     IN  VARCHAR2 DEFAULT NULL,
 CARTRIDGE_HANDLE                IN  VARCHAR2,
 ALLOW_MULTIPLE_PROC_INSTANCE    IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_MULTIPLE_PROC_NODE        IN  VARCHAR2 DEFAULT 'Y',
 MIGRATE_ON_FAILURE              IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_SUSPEND                   IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_VERIFY                    IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_PARAMETER                 IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_START                     IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_RESTART                   IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_RCG                       IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_CREATE                    IN  VARCHAR2 DEFAULT 'Y',
 ALLOW_EDIT                      IN  VARCHAR2 DEFAULT 'Y',
 PARAMETER_CHANGE_ACTION         IN  VARCHAR2 DEFAULT 'V',
 DEVELOPER_PARAMETERS            IN  VARCHAR2 DEFAULT NULL,
 SERVER_TYPE                     IN  VARCHAR2 DEFAULT 'C',
 language_code        		 IN  VARCHAR2 DEFAULT 'US',
 ENV_FILE_NAME                   IN  VARCHAR2 DEFAULT NULL,
 SERVICE_CLASS                   IN  VARCHAR2 DEFAULT NULL,
 SERVICE_INSTANCE_CLASS          IN  VARCHAR2 DEFAULT NULL,
 OAM_DISPLAY_ORDER               IN  NUMBER   DEFAULT NULL,
 DEBUG_CHANGE_ACTION             IN  VARCHAR2 DEFAULT 'N',
 ENABLED                         IN  VARCHAR2 DEFAULT 'Y',
 CARTRIDGE_APPLICATION           IN  VARCHAR2 DEFAULT NULL,
 DEBUG_TYPE                      IN  VARCHAR2 DEFAULT NULL,
 SERVICE_PLURAL_NAME             IN  VARCHAR2 DEFAULT NULL,
 ALLOW_MULTIPLE_PROC_SI          IN  VARCHAR2 DEFAULT 'Y',
 DEFAULT_DEBUG_LEVEL	 	 IN  VARCHAR2 DEFAULT NULL,
 last_updated_by		 IN  NUMBER   DEFAULT NULL) is


 svc_id number;
 oam_d_o number;
 cart_appl_id number := 0;
 LAST_UPDATE_DATE_v date;
 LAST_UPDATED_BY_v  number;
 LAST_UPDATE_LOGIN_v number;
 CREATION_DATE_v date;
 CREATED_BY_v number;

begin

  check_notnull(SERVICE_NAME);
  check_notnull(SERVICE_HANDLE);
  check_notnull(CARTRIDGE_HANDLE);

  LAST_UPDATE_DATE_v := LAST_UPDATE_DATE_f;
  LAST_UPDATED_BY_v := last_updated_by_f(last_updated_by);
  LAST_UPDATE_LOGIN_v := LAST_UPDATE_LOGIN_f;
  CREATION_DATE_v := CREATION_DATE_f;
  CREATED_BY_v := CREATED_BY_f;

  /* Get new ID */
  if ( service_handle = 'FNDICM' ) then
     svc_id := 0;
  elsif ( service_handle = 'FNDRPM' ) then
     svc_id := 1;
  elsif (service_handle = 'FNDIM') then
     svc_id := 2;
  elsif ( service_handle = 'FNDTM' ) then
     svc_id := 3;
  elsif ( service_handle = 'FNDCRM' ) then
     svc_id := 4;
  elsif ( service_handle = 'FNDSCH' ) then
     svc_id := 5;
  elsif ( service_handle = 'FNDSM' ) then
     svc_id := 6;
  else
     select fnd_cp_services_s.nextval
       into svc_id
       from sys.dual;
  end if;

  /* Default OAM_DISPLAY_ORDER */

  if ( OAM_DISPLAY_ORDER is NULL) then
	select (NVL(max(OAM_DISPLAY_ORDER),0) + 10)
	into oam_d_o
	from FND_CP_SERVICES;
  else
	oam_d_o := OAM_DISPLAY_ORDER;
  end if;

  /* Get Cartridge Application Id */

  if (CARTRIDGE_APPLICATION is not NULL) then
    begin
	select APPLICATION_ID
	into cart_appl_id
	from FND_APPLICATION
	where APPLICATION_SHORT_NAME = CARTRIDGE_APPLICATION;
    exception
      when others then
        cart_appl_id := 0;
    end;
  end if;

  /* Do the insert */
  insert into fnd_cp_services
               (SERVICE_ID, SERVICE_HANDLE, ALLOW_MULTIPLE_PROC_INSTANCE,
		ALLOW_MULTIPLE_PROC_NODE, MIGRATE_ON_FAILURE, SERVER_TYPE,
		ALLOW_SUSPEND, ALLOW_VERIFY, ALLOW_PARAMETER, ALLOW_START,
		ALLOW_RESTART, PARAMETER_CHANGE_ACTION, LAST_UPDATE_DATE,
		LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY,
		ENV_FILE_NAME, CARTRIDGE_HANDLE, DEVELOPER_PARAMETERS,
		ALLOW_RCG, ALLOW_CREATE, ALLOW_EDIT, SERVICE_CLASS,
		SERVICE_INSTANCE_CLASS,	OAM_DISPLAY_ORDER, DEBUG_CHANGE_ACTION,
		ENABLED, CARTRIDGE_APPLICATION_ID,DEBUG_TYPE,
		ALLOW_MULTIPLE_PROC_SI, DEFAULT_DEBUG_LEVEL)
         Select svc_id, SERVICE_HANDLE, ALLOW_MULTIPLE_PROC_INSTANCE,
		ALLOW_MULTIPLE_PROC_NODE, MIGRATE_ON_FAILURE, SERVER_TYPE,
		ALLOW_SUSPEND, ALLOW_VERIFY, ALLOW_PARAMETER, ALLOW_START,
                ALLOW_RESTART, PARAMETER_CHANGE_ACTION, LAST_UPDATE_DATE_v,
		LAST_UPDATED_BY_v, LAST_UPDATE_LOGIN_v, CREATION_DATE_v,
		CREATED_BY_v,
		ENV_FILE_NAME, CARTRIDGE_HANDLE, DEVELOPER_PARAMETERS,
                ALLOW_RCG, ALLOW_CREATE, ALLOW_EDIT, SERVICE_CLASS,
		SERVICE_INSTANCE_CLASS, oam_d_o, DEBUG_CHANGE_ACTION,
		ENABLED, cart_appl_id, DEBUG_TYPE, ALLOW_MULTIPLE_PROC_SI,
		DEFAULT_DEBUG_LEVEL
	 from sys.dual;

  insert into fnd_cp_services_tl (
    SERVICE_ID, LANGUAGE, SOURCE_LANG, SERVICE_NAME, LAST_UPDATE_DATE,
    LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE, CREATED_BY, DESCRIPTION,
    SERVICE_PLURAL_NAME)
  select
    svc_id, l.language_code, register_svc.language_code, SERVICE_NAME,
    LAST_UPDATE_DATE_v, LAST_UPDATED_BY_v,LAST_UPDATE_LOGIN_v,
    CREATION_DATE_v, CREATED_BY_v, DESCRIPTION,SERVICE_PLURAL_NAME
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from fnd_cp_services_tl T
    where T.SERVICE_ID = svc_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

end register_svc;

-- Procedure
--   REGISTER_SI
--
-- Purpose
--   Register a Service Instance.
--
-- Arguments
--   Manager         - Service Instance name.
--   Application     - Manager application short name.
--   Short_Name      - Short (non-translated) name
--   Description     - Manager description (Optional).
--   Service_Type    -
--   Primary_Node    - Primary node (optional).
--   Primary_Queue   - Primary OS queue (Optional).
--   Secondary_Node  - Secondary node (optional).
--   Secondary_Queue - Secondary OS queue (Optional).
--   Language_code   - Langauge code for translated values.
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE register_si (manager          IN VARCHAR2,
                   application          IN VARCHAR2,
                   short_name           IN VARCHAR2,
                   description          IN VARCHAR2 DEFAULT NULL,
                   service_handle       IN VARCHAR2,
                   primary_node         IN VARCHAR2 DEFAULT NULL,
                   primary_queue        IN VARCHAR2 DEFAULT NULL,
                   secondary_node       IN VARCHAR2 DEFAULT NULL,
                   secondary_queue      IN VARCHAR2 DEFAULT NULL,
                   language_code        IN VARCHAR2 DEFAULT 'US',
                   last_update_date     IN DATE     DEFAULT NULL,
                   last_updated_by      IN VARCHAR2 DEFAULT NULL) is

svc_id number;
si_id  number;
mgr_appl_id number;


begin
   /* have register do most of the work- pretend it is a copy of FNDLIBR */
   register(manager, application, short_name, description,
     'Concurrent Manager', NULL, NULL, primary_node, primary_queue,
     secondary_node, secondary_queue, 'FNDSVC', 'FND', NULL, language_code,
     last_update_date, last_updated_by);

   mgr_appl_id := application_id_f(application);
   si_id := manager_id_f(mgr_appl_id, short_name);
   svc_id := service_id_f(service_handle);

   update fnd_concurrent_queues
   set manager_type = svc_id
   where APPLICATION_ID = mgr_appl_id
   and CONCURRENT_QUEUE_ID = si_id;

end register_si;

-- Procedure
--   ASSIGN_WORK_SHIFT
--
-- Purpose
--   Assign a work shift to a manager.
--
-- Arguments
--   Manager_Short_Name  - Concurrent manager short name.
--   Manager_Application - Manager application short name.
--   Work_Shift          - Work shift name.
--   Processes           - Number of concurrent processes.
--   Sleep_Seconds       - Length of sleep interval.
--   Work_Shift_ID       - ID of Work Shift (Optional, overrides parameter
--                         'work_shift')
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE assign_work_shift(manager_short_name IN VARCHAR2,
                            manager_application IN VARCHAR2,
                            work_shift          IN VARCHAR2 DEFAULT NULL,
			    processes           IN NUMBER,
			    sleep_seconds       IN NUMBER,
			    work_shift_id       IN NUMBER   DEFAULT NULL,
			    svc_params          in VARCHAR2 DEFAULT NULL,
                            last_update_date    IN DATE     DEFAULT NULL,
                            last_updated_by      IN VARCHAR2 DEFAULT NULL) is

  mgr_appl_id fnd_application.application_id%TYPE;
  mgr_id      fnd_concurrent_queues.concurrent_queue_id%TYPE;
  ws_id       fnd_concurrent_time_periods.concurrent_time_period_id%TYPE;
  dg_id       fnd_data_groups.data_group_id%TYPE;
  lib_appl_id fnd_application.application_id%TYPE;
  lib_id      fnd_concurrent_processors.concurrent_processor_id%TYPE;
  mgr_type    fnd_concurrent_queues.manager_type%TYPE;

  last_update_login fnd_concurrent_queue_size.last_update_login%TYPE
    := last_update_login_f;
  l_update_date fnd_concurrent_queue_size.last_update_date%TYPE
    := last_update_date_f(last_update_date);
  l_updated_by fnd_concurrent_queue_size.last_updated_by%TYPE
    := last_updated_by_f(last_updated_by);
  creation_date fnd_concurrent_queue_size.creation_date%TYPE
    := creation_date_f(last_update_date);
  created_by fnd_concurrent_queue_size.created_by%TYPE
    := created_by_f(last_updated_by);
begin
  message_init;

  check_notnull(manager_short_name);
  check_notnull(manager_application);
  check_notnull(processes);
  check_notnull(sleep_seconds);

  if (last_update_date IS NOT NULL) then
    l_update_date := last_update_date;
    creation_date := last_update_date;
  end if;

  if (last_updated_by IS NOT NULL) then
    l_updated_by := last_updated_by;
    created_by := last_updated_by;
  end if;

  /* Get manager ID */
  mgr_appl_id := application_id_f(manager_application);
  mgr_id := manager_id_f(mgr_appl_id, manager_short_name);

  /* Check type */
  select manager_type
    into mgr_type
    from fnd_concurrent_queues
   where application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  if (mgr_type = 0) then
    message('Work Shifts cannot be assigned to the ICM.');
    raise bad_parameter;
  end if;

  /* Get work shift ID */
  begin
    if (work_shift_id is not null) then
      select concurrent_time_period_id
        into ws_id
        from fnd_concurrent_time_periods
       where concurrent_time_period_id = work_shift_id
         and application_id = 0;
    else
      select concurrent_time_period_id
        into ws_id
        from fnd_concurrent_time_periods
       where concurrent_time_period_name = work_shift
         and application_id = 0;
    end if;
  exception
    when no_data_found then
      if (work_shift_id is not null) then
        message('Could not find work shift with ID: '||work_shift_id);
      else
        message('Could not find work shift: '||work_shift);
      end if;
      raise bad_parameter;
  end;

  /* Check processes */
  if (processes < 0) then
    message('Invalid number of processes: '||to_char(processes));
    raise bad_parameter;
  end if;

  /* Check sleep seconds */
  if (sleep_seconds < 0) then
    message('Invalid sleep seconds: '||to_char(sleep_seconds));
    raise bad_parameter;
  end if;

  /* do the insert */
  insert into fnd_concurrent_queue_size
	      (queue_application_id, concurrent_queue_id,
	       period_application_id, concurrent_time_period_id,
	       last_update_date, last_updated_by, creation_date,
	       last_update_login, created_by, min_processes, sleep_seconds,
	       SERVICE_PARAMETERS)
	 values
	      (mgr_appl_id, mgr_id, 0, ws_id,
	       l_update_date, l_updated_by, creation_date,
	       last_update_login, created_by, processes, sleep_seconds,
		svc_params);

end assign_work_shift;


-- Procedure
--   CREATE_LIBRARY
--
-- Purpose
--   Create a concurrent program library.
--
-- Arguments
--   Library		- Library name.
--   Application 	- Library application short name.
--   Description	- Library description.
--   Type 		- 'Concurrent Programs Library' or
--                        'Transaction Programs Library '
--
PROCEDURE create_library(library	IN VARCHAR2,
			 application    IN VARCHAR2,
			 description    IN VARCHAR2 DEFAULT NULL,
			 type           IN VARCHAR2) is

  lib_appl_id fnd_application.application_id%TYPE;
  lib_id      fnd_concurrent_processors.concurrent_processor_id%TYPE;
  type_code   fnd_concurrent_processors.library_type%type;

  last_update_login fnd_concurrent_queues.last_update_login%TYPE
    := last_update_login_f;
  last_update_date fnd_concurrent_queues.last_update_date%TYPE
    := last_update_date_f;
  last_updated_by fnd_concurrent_queues.last_updated_by%TYPE
    := last_updated_by_f;
  creation_date fnd_concurrent_queues.creation_date%TYPE
    := creation_date_f;
  created_by fnd_concurrent_queues.created_by%TYPE
    := created_by_f;
begin
  message_init;

  check_notnull(library);
  check_notnull(application);
  check_notnull(type);

  lib_appl_id := application_id_f(application);

  /* Get type */
  begin
    select lookup_code
      into type_code
      from fnd_lookup_values
      where lookup_type = 'CP_PROGRAM_LIBRARY_TYPE'
        and upper(meaning) = upper(type)
        and rownum = 1;
  exception
    when no_data_found then
      message('Invalid library type: ' || type);
      raise bad_parameter;
  end;

  /* Get new library ID */
  select fnd_concurrent_processors_s.nextval
    into lib_id
    from sys.dual;

  insert into fnd_concurrent_processors
  	      (application_id, concurrent_processor_id,
	       concurrent_processor_name, last_update_date,
	       last_updated_by, creation_date, created_by,
	       last_update_login, description, library_type)
	 values
	      (lib_appl_id, lib_id, library, last_update_date,
	       last_updated_by, creation_date, created_by,
	       last_update_login, description, type_code);

end create_library;


-- Procedure
--   ADD_PROGRAM_TO_LIBRARY
--
-- Purpose
--   Add a concurrent program to a concurrent library.
--
-- Arguments
--   Library		 - Library name.
--   Library_Application - Library application short name.
--   Program 	 	 - Program short name.
--   Program_Application - Program application short name.
--
PROCEDURE add_program_to_library(library		IN VARCHAR2,
			 	 library_application    IN VARCHAR2,
			 	 program	    	IN VARCHAR2,
			 	 program_application    IN VARCHAR2)
				 is
  lib_appl_id fnd_application.application_id%TYPE;
  lib_id      fnd_concurrent_processors.concurrent_processor_id%TYPE;
  prg_appl_id fnd_application.application_id%TYPE;
  prg_id      fnd_concurrent_programs.concurrent_program_id%TYPE;

  last_update_login fnd_concurrent_queues.last_update_login%TYPE
    := last_update_login_f;
  last_update_date fnd_concurrent_queues.last_update_date%TYPE
    := last_update_date_f;
  last_updated_by fnd_concurrent_queues.last_updated_by%TYPE
    := last_updated_by_f;
  creation_date fnd_concurrent_queues.creation_date%TYPE
    := creation_date_f;
  created_by fnd_concurrent_queues.created_by%TYPE
    := created_by_f;
begin
  message_init;

  check_notnull(library);
  check_notnull(library_application);
  check_notnull(program);
  check_notnull(program_application);

  lib_appl_id := application_id_f(library_application);
  lib_id := library_id_f(lib_appl_id, library);
  prg_appl_id := application_id_f(program_application);
  prg_id := concurrent_program_id_f(prg_appl_id, program);

  insert into fnd_conc_processor_programs
	      (processor_application_id, concurrent_processor_id,
	       program_application_id, concurrent_program_id,
	       last_update_date, last_updated_by, creation_date,
	       created_by, last_update_login)
 	 values
	      (lib_appl_id, lib_id, prg_appl_id, prg_id,
	       last_update_date, last_updated_by, creation_date,
	       created_by, last_update_login);
end add_program_to_library;


-- Procedure
--   SPECIALIZE
--
-- Purpose
--   Register a specialization rule for a manager.
--
-- Arguments
--   manager_short_name  - Concurrent manager name.
--   manager_application - Manager application short name.
--   action              - 'Include' or 'Exclude'.
--   object_type         - 'Combined Rule', 'Oracle ID', 'Program',
--                         'Request Type', 'User'.
--   object_name         - Name of the object being included or excluded.
--                         (Short name for Programs.)
--   object_application  - Application short name of the object being
--                         included or excluded. (Not used for Oracle IDs
--                         or Users.)
--   Last_Update_Date- Who information for FNDLOAD standards
--   Last_Updated_By - Who information for FNDLOAD standards
--
PROCEDURE specialize(manager_short_name 		 in VARCHAR2,
		     manager_application in VARCHAR2,
		     action              in VARCHAR2,
		     object_type         in VARCHAR2,
		     object_name	 in VARCHAR2 DEFAULT NULL,
		     object_application  in VARCHAR2 DEFAULT NULL,
                     last_update_date    in DATE     DEFAULT NULL,
                     last_updated_by     in NUMBER   DEFAULT NULL) is
  mgr_appl_id  fnd_application.application_id%TYPE;
  mgr_id       fnd_concurrent_queues.concurrent_queue_id%type;
  action_code  fnd_concurrent_queue_content.include_flag%type;
  type_code    fnd_concurrent_queue_content.type_code%type;
  type_id      fnd_concurrent_queue_content.type_id%type;
  type_appl_id fnd_application.application_id%TYPE;
  mgr_type     fnd_concurrent_queues.manager_type%TYPE;

  last_update_login fnd_concurrent_queue_content.last_update_login%TYPE
    := last_update_login_f;
  l_update_date fnd_concurrent_queue_content.last_update_date%TYPE
    := last_update_date_f(last_update_date);
  l_updated_by fnd_concurrent_queue_content.last_updated_by%TYPE
    := last_updated_by_f(last_updated_by);
  creation_date fnd_concurrent_queue_content.creation_date%TYPE
    := creation_date_f(last_update_date);
  created_by fnd_concurrent_queue_content.created_by%TYPE
    := created_by_f(last_updated_by);

begin
  message_init;

  check_notnull(manager_application);
  check_notnull(manager_short_name);
  check_notnull(action);
  check_notnull(object_type);

  mgr_appl_id := application_id_f(manager_application);
  mgr_id := manager_id_f(mgr_appl_id, manager_short_name);

  if (last_update_date IS NOT NULL) then
    l_update_date := last_update_date;
    creation_date := last_update_date;
  end if;

  if (last_updated_by IS NOT NULL) then
    l_updated_by := last_updated_by;
    created_by := last_updated_by;
  end if;


  /* Check manager type */
  select manager_type
    into mgr_type
    from fnd_concurrent_queues
   where application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  if (mgr_type <> 1) then
    message('This manager is of a type which cannot be specialized.');
    raise bad_parameter;
  end if;

  /* Get action code */
  begin
    select lookup_code
      into action_code
      from fnd_lookup_values
     where lookup_type = 'INCLUDE_EXCLUDE'
       and upper(meaning) = upper(action)
       and rownum = 1;
  exception
    when no_data_found then
      message('Invalid action: '||action);
      raise bad_parameter;
  end;

  /* Get object type */
  begin
    select lookup_code
      into type_code
      from fnd_lookup_values
     where lookup_type = 'CP_SPECIAL_RULES'
       and upper(meaning) = upper(object_type)
       and lookup_code in ('C','O','P','R','U')
       and rownum = 1;
  exception
    when no_data_found then
      message('Invalid object type: '||object_type);
      raise bad_parameter;
  end;

  /* get object id */
  if (object_application is null) then
    if (type_code in ('C','P','R')) then
      message('Application required for object of type '||object_type);
      raise bad_parameter;
    end if;
  elsif (type_code in ('O', 'U')) then
    message('Application cannot be specified for an object of type: '
	     || object_type);
    raise bad_parameter;
  else
    type_appl_id := application_id_f(object_application);
  end if;

  type_id := get_specialization_type_id(object_name,
                                        type_appl_id,
                                        type_code);

  insert into fnd_concurrent_queue_content
		(queue_application_id, concurrent_queue_id, type_code,
		 type_application_id, type_id, last_update_date,
		 last_updated_by, creation_date, created_by,
		 last_update_login, include_flag)
	 values (mgr_appl_id, mgr_id, type_code,
		 type_appl_id, type_id, l_update_date,
		 l_updated_by, creation_date, created_by,
		 last_update_login, action_code);
end specialize;


-- Function
--   MANAGER_EXISTS
--
-- Purpose
--   Return TRUE if a manager exists.
--
-- Arguments
--   Manager_Short_Name - Manager short name.
--   Application - Manager application short name.
--
FUNCTION manager_exists(manager_short_name		IN VARCHAR2,
			application     IN VARCHAR2)
			RETURN BOOLEAN is
  mgr_appl_id fnd_application.application_id%TYPE;
  dummy varchar2(4);
begin
  message_init;

  mgr_appl_id := application_id_f(application);

  select 'Y'
    into dummy
    from fnd_concurrent_queues
   where application_id = mgr_appl_id
     and concurrent_queue_name = manager_short_name;

  return TRUE;
exception
  when others then
    return FALSE;
end manager_exists;

-- Function
--   SERVICE_EXISTS
--
-- Purpose
--   Return TRUE if a service exists.
--
-- Arguments
--   svc_handle - service_handle.
--
FUNCTION Service_exists(svc_handle IN VARCHAR2) RETURN BOOLEAN is
  dummy varchar2(4);
begin
  message_init;

  select 'Y'
    into dummy
    from fnd_cp_services
   where svc_handle = SERVICE_HANDLE;

  return TRUE;
exception
  when others then
    return FALSE;
end Service_exists;

-- Function
--   MANAGER_WORK_SHIFT_EXISTS
--
-- Purpose
--   Return TRUE if a manager has an assignment for a work shift.
--
-- Arguments
--   Manager_Short_Name  - Manager short name.
--   Manager_Application - Manager application short name.
--   Work_Shift		 - Work shift name.
--   Work_Shift_ID       - ID of Work Shift (Optional, overrides parameter
--                         'work_shift')
--
FUNCTION manager_work_shift_exists(
			manager_short_name      	    IN VARCHAR2,
			manager_application IN VARCHAR2,
	           	work_shift          IN VARCHAR2 DEFAULT NULL,
                        work_shift_id       IN NUMBER   DEFAULT NULL)
			RETURN BOOLEAN is
  mgr_appl_id fnd_application.application_id%TYPE;
  mgr_id      fnd_concurrent_queues.concurrent_queue_id%TYPE;
  dummy varchar2(4);
begin
  message_init;

  mgr_appl_id := application_id_f(manager_application);
  mgr_id := manager_id_f(mgr_appl_id, manager_short_name);

  if (work_shift_id is null) then
    select 'Y'
      into dummy
      from fnd_concurrent_queue_size qs,
           fnd_concurrent_time_periods tp
      where tp.concurrent_time_period_name = work_shift
        and tp.application_id = 0
        and tp.concurrent_time_period_id = qs.concurrent_time_period_id
        and qs.concurrent_queue_id = mgr_id
        and qs.queue_application_id = mgr_appl_id
        and rownum = 1;
  else
    select 'Y'
      into dummy
      from fnd_concurrent_queue_size
      where work_shift_id = concurrent_time_period_id
        and concurrent_queue_id = mgr_id
        and queue_application_id = mgr_appl_id
        and rownum = 1;
  end if;

  return TRUE;

exception
  when others then
    return FALSE;
end manager_work_shift_exists;


-- Function
--   LIBRARY_EXISTS
--
-- Purpose
--   Return TRUE if a library exists.
--
-- Arguments
--   Library 	 - Library name.
--   Application - Library application short name.
--
FUNCTION library_exists(library		IN VARCHAR2,
			application     IN VARCHAR2)
		        RETURN BOOLEAN is
  lib_appl_id fnd_application.application_id%TYPE;
  dummy varchar2(4);
begin
  message_init;

  lib_appl_id := application_id_f(application);

  select 'Y'
    into dummy
    from fnd_concurrent_processors
   where application_id = lib_appl_id
     and concurrent_processor_name = library;

  return TRUE;

exception
  when others then
    return FALSE;
end library_exists;


-- Function
--   PROGRAM_IN_LIBRARY
--
-- Purpose
--   Return TRUE if a library exists.
--
-- Arguments
--   Library 	 	 - Library name.
--   Library_Application - Library application short name.
--   Program             - Program short name.
--   Program_Application - Program application short name.
--
FUNCTION program_in_library(library			IN VARCHAR2,
			    library_application		IN VARCHAR2,
                            program         		IN VARCHAR2,
                            program_application     	IN VARCHAR2)
			    RETURN BOOLEAN is
  lib_appl_id fnd_application.application_id%TYPE;
  prg_appl_id fnd_application.application_id%TYPE;
  lib_id      fnd_concurrent_processors.concurrent_processor_id%TYPE;
  dummy varchar2(4);
begin
  message_init;

  lib_appl_id := application_id_f(library_application);
  prg_appl_id := application_id_f(program_application);
  lib_id := library_id_f(lib_appl_id, library);

  select 'Y'
    into dummy
    from fnd_conc_processor_programs pp,
         fnd_concurrent_programs cp
   where pp.processor_application_id = lib_appl_id
     and pp.concurrent_processor_id = lib_id
     and pp.concurrent_program_id = cp.concurrent_program_id
     and cp.application_id = pp.program_application_id
     and cp.application_id = prg_appl_id
     and cp.concurrent_program_name = program;

  return TRUE;

exception
  when others then
    return FALSE;
end program_in_library;


-- FUNCTION
--   SPECIALIZATION_EXISTS
--
-- Purpose
--   Check if a manager has been specialized for an object.
--
-- Arguments
--   manager_short_name  - Concurrent manager short name.
--   manager_application - Manager application short name.
--   object_type         - 'Combined Rule', 'ORACLE ID', 'Program',
--                         'Request Type', 'User'.
--   object_name         - Name of the object being included or excluded.
--                         (Short name for Programs.)
--   object_application  - Application short name of the object being
--                         included or excluded. (Not used for Oracle IDs
--                         or Users.)
--
FUNCTION specialization_exists(
		    manager_short_name 	in VARCHAR2,
		    manager_application in VARCHAR2,
		    object_type         in VARCHAR2,
		    object_name	        in VARCHAR2 DEFAULT NULL,
		    object_application  in VARCHAR2 DEFAULT NULL)
		   return boolean is

  mgr_appl_id  fnd_application.application_id%TYPE;
  mgr_id       fnd_concurrent_queues.concurrent_queue_id%type;
  action_code  fnd_concurrent_queue_content.include_flag%type;
  obj_code     fnd_concurrent_queue_content.type_code%type;
  obj_id       fnd_concurrent_queue_content.type_id%type;
  obj_appl_id  fnd_application.application_id%TYPE;
  mgr_type     fnd_concurrent_queues.manager_type%TYPE;
  dummy        varchar2(4);
begin
  message_init;

  mgr_appl_id := application_id_f(manager_application);
  mgr_id := manager_id_f(mgr_appl_id, manager_short_name);

  /* Get object type */
  select lookup_code
    into obj_code
    from fnd_lookup_values
   where lookup_type = 'CP_SPECIAL_RULES'
     and upper(meaning) = upper(object_type)
     and lookup_code in ('C','O','P','R','U')
     and rownum = 1;

  /* get object id */
  if (object_application is null) then
    if (obj_code in ('C','P','R')) then
      message('Application required for object of type '||object_type);
      raise bad_parameter;
    end if;
  else
    obj_appl_id := application_id_f(object_application);
  end if;

  if (obj_code = 'C') then
    select complex_rule_id
      into obj_id
      from fnd_concurrent_complex_rules
     where application_id = obj_appl_id
       and complex_rule_name = object_name;
  elsif (obj_code = 'O') then
    select oracle_id
      into obj_id
      from fnd_oracle_userid
     where oracle_username = object_name;
  elsif (obj_code = 'P') then
    if (object_name is not null) then
      obj_id := concurrent_program_id_f(obj_appl_id, object_name);
    end if;
  elsif (obj_code = 'R') then
    select request_class_id
      into obj_id
      from fnd_concurrent_request_class
     where application_id = obj_appl_id
       and request_class_name = object_name;
  else
    select user_id
      into obj_id
      from fnd_user
     where user_name = object_name;
  end if;

  obj_id := get_specialization_type_id(object_name,
                                       obj_appl_id,
                                       obj_code);

  select 'Y'
    into dummy
    from fnd_concurrent_queue_content
   where concurrent_queue_id = mgr_id
     and queue_application_id = mgr_appl_id
     and type_code = obj_code
     and ((obj_id is null and type_id is null)
          or type_id = obj_id)
     and ((obj_appl_id is null and type_application_id is null)
          or obj_appl_id = type_application_id);

  return TRUE;

exception
  when others then
    return FALSE;
end specialization_exists;


-- Procedure
--   DELETE_MANAGER
--
-- Purpose
--   Delete a concurrent manager and all its dependent data.
--
-- Arguments
--   Manager_short_name - Concurrent manager short name.
--   Application     - Manager application short name.
--
-- Warning:
--   This will delete request and process data belonging to the
--   manager.
--
PROCEDURE delete_manager (manager_short_name	      IN VARCHAR2,
		          application         IN VARCHAR2) is

  mgr_appl_id  fnd_application.application_id%TYPE;
  mgr_id       fnd_concurrent_queues.concurrent_queue_id%type;

  targetp      number := 0;
  activep      number := 0;
  pmon         varchar2(10);
  callstat     number;
begin
  message_init;

  mgr_appl_id := application_id_f(application);

  begin
    mgr_id := manager_id_f(mgr_appl_id, manager_short_name);
  exception
    when others then -- No manager to delete.
      message_init;
      return;
  end;

  if (mgr_appl_id = 0 and mgr_id in (1,0,4)) then
    message('Cannot delete the Internal or Standard managers.');
    raise bad_parameter;
  end if;

  /* ------------------------------------------------------------ */
  /* Bug 2048187: Removed deletes for request and process history */
  /*       from tables fnd_run_requests, fnd_concurrent_requests, */
  /*       and fnd_concurrent_processes.                          */
  /* ------------------------------------------------------------ */

  /* Specialization Rules */
  delete from fnd_concurrent_queue_content
   where concurrent_queue_id = mgr_id
     and queue_application_id = mgr_appl_id;

  /* Work Shifts */
  delete from fnd_concurrent_queue_size
   where queue_application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  /* TL tables */
  delete from fnd_concurrent_queues_tl
   where concurrent_queue_id = mgr_id
     and application_id = mgr_appl_id;

  /* Manager */
  delete from fnd_concurrent_queues
   where concurrent_queue_id = mgr_id
     and application_id = mgr_appl_id;

end delete_manager;


-- Procedure
--   DELETE_LIBRARY
--
-- Purpose
--   Delete a concurrent program library.
--
-- Arguments
--   Library		- Library name.
--   Application 	- Library application short name.
--
PROCEDURE delete_library(library	IN VARCHAR2,
			 application    IN VARCHAR2) is

  lib_appl_id fnd_application.application_id%TYPE;
  lib_id      fnd_concurrent_processors.concurrent_processor_id%TYPE;

  i           number;
begin
  message_init;

  lib_appl_id := application_id_f(application);

  begin
    lib_id := library_id_f(lib_appl_id, library);
  exception
    when others then  -- No library to delete
      message_init;
      return;
  end;

  /* Check if in use */
  select count(*)
    into i
    from fnd_concurrent_queues
   where concurrent_processor_id = lib_id
     and processor_application_id = lib_appl_id;

  if ( i > 0 ) then
    message('Library ' || library || ' is in use.');
    raise bad_parameter;
  end if;

  /* Delete programs */
  delete from fnd_conc_processor_programs
   where concurrent_processor_id = lib_id
     and processor_application_id = lib_appl_id;

  /* Delete library */
  delete from fnd_concurrent_processors
   where concurrent_processor_id = lib_id
     and application_id = lib_appl_id;
end delete_library;


-- Procedure
--   STANDARDIZE
--
-- Purpose
--   Changes the value of a concurrent_queue_id and all references
--   to that ID.
--
-- Arguments
--   Manager_short_name - Concurrent manager short name.
--   Application     - Manager application short name.
--   Queue_ID        - New ID
--
--
PROCEDURE standardize (manager_short_name IN VARCHAR2,
		       application      IN VARCHAR2,
                       manager_id       IN number) is

  mgr_appl_id  fnd_application.application_id%TYPE;
  mgr_id       fnd_concurrent_queues.concurrent_queue_id%type;

  dummy number;

BEGIN

  message_init;

  check_notnull(application);
  check_notnull(manager_id);

  mgr_appl_id := application_id_f(application);
  mgr_id := manager_id_f(mgr_appl_id, manager_short_name);

  if (mgr_id = manager_id) then /* Do nothing */
    return;
  end if;

  if (mgr_appl_id = 0 and mgr_id in (1,0,4)) then
    message('Cannot change the Internal or Standard managers.');
    raise bad_parameter;
  end if;

  /* Ensure uniqueness */
  begin
    select 1 into dummy
      from sys.dual
      where not exists
            (select 1
               from fnd_concurrent_queues
              where concurrent_queue_id = manager_id);
  exception
    when no_data_found then
      message('ID '|| to_char(manager_id) || ' is already in use.');
      raise bad_parameter;
  end;

  /* Process data */
  update fnd_concurrent_processes
     set concurrent_queue_id = manager_id
   where queue_application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  /* Work Shifts */
  update fnd_concurrent_queue_size
     set concurrent_queue_id = manager_id
   where queue_application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  /* Process data */
  update fnd_concurrent_queue_content
     set concurrent_queue_id = manager_id
   where queue_application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  /* TL tables */
  update fnd_concurrent_queues_tl
     set concurrent_queue_id = manager_id
   where application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

  /* manager */
  update fnd_concurrent_queues
     set concurrent_queue_id = manager_id
   where application_id = mgr_appl_id
     and concurrent_queue_id = mgr_id;

END standardize;

-- Procedure
--   UPDATE_NODE
--
-- Purpose
--   Set Primary and/or Secondary Node assignment for a Service Instance
--
-- Arguments
--
--   Short_Name      - Concurrent Queue Name
--   Application     - Application short name
--   Primary_Node    - Primary node
--   Secondary_Node  - Secondary node
--
--   Node names may be set to null.

PROCEDURE update_node(short_name    IN VARCHAR2,
                  application       IN VARCHAR2,
                  primary_node      IN VARCHAR2 DEFAULT fnd_api.g_miss_char,
                  secondary_node    IN VARCHAR2 DEFAULT fnd_api.g_miss_char) IS

  mgr_appl_id  fnd_application.application_id%TYPE;
  mgr_id       fnd_concurrent_queues.concurrent_queue_id%type;
  pnode varchar2(31);
  snode varchar2(31);

BEGIN

  message_init;

  check_notnull(application);
  check_notnull(short_name);

  if (primary_node = fnd_api.g_miss_char and
      secondary_node = fnd_api.g_miss_char) then
	return;  /* Do nothing. */
  end if;

/* Get concurrent queue id */

  mgr_appl_id := application_id_f(application);
  mgr_id := manager_id_f(mgr_appl_id, short_name);

/* Verify node(s) */

 if (primary_node <> fnd_api.g_miss_char and
     primary_node is not null) then
	pnode := node_name_f(primary_node);
 else
        pnode := primary_node;
 end if;

 if (secondary_node <> fnd_api.g_miss_char and
     secondary_node is not null) then
	snode := node_name_f(secondary_node);
 else
        snode := secondary_node;
 end if;

/* Update */
 if (snode = fnd_api.g_miss_char) then  /* No secondary */
	update fnd_concurrent_queues
           set node_name = pnode
         where concurrent_queue_id = mgr_id
           and application_id = mgr_appl_id;

 elsif (pnode = fnd_api.g_miss_char) then /* No primary */
	update fnd_concurrent_queues
           set node_name2 = snode
         where concurrent_queue_id = mgr_id
           and application_id = mgr_appl_id;

   else                        /* primary and secondary */
	update fnd_concurrent_queues
           set node_name = pnode,
              node_name2 = snode
       where concurrent_queue_id = mgr_id
           and application_id = mgr_appl_id;

 end if;

END update_node;

end fnd_manager;

/
