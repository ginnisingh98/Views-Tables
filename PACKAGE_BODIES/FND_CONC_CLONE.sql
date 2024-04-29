--------------------------------------------------------
--  DDL for Package Body FND_CONC_CLONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_CLONE" as
/* $Header: AFCPCLNB.pls 120.1.12010000.6 2015/08/13 14:53:17 ckclark ship $ */


  --This two variable are used to store the database user name of
  --FND and JTF objects
  OracleUserFND varchar2(30) := null ;
  OracleUserJTF varchar2(30) := null ;

/*
 * procedure : get_database_user
 *
 * purpose   : Database user for FND objects and JTF objects are retrieved
 *             form table and stored into the package
 *             variable OracleUserFND and OracleUserJTF
 *             Changed is done to remove the 'APPLSYS' and 'JTF' hard coding. Bug 3335806
 */
procedure get_database_user is

begin
    if (OracleUserFND is null) then
      begin
        SELECT fou.oracle_username into OracleUserFND
               FROM fnd_oracle_userid fou,
                    fnd_product_installations fpi,
                    fnd_application a
              WHERE fou.oracle_id = fpi.oracle_id
                AND fpi.application_id = a.application_id
                AND a.application_short_name = 'FND' ;
      exception
          when NO_DATA_FOUND then
	      OracleUserFND := null;
      end;
    end if;


    if (OracleUserJTF is null) then
      begin
        SELECT fou.oracle_username into OracleUserJTF
               FROM fnd_oracle_userid fou,
                    fnd_product_installations fpi,
                    fnd_application a
              WHERE fou.oracle_id = fpi.oracle_id
                AND fpi.application_id = a.application_id
                AND a.application_short_name = 'JTF' ;
      exception
          when NO_DATA_FOUND then
	      OracleUserJTF := null;
      end;
    end if;

end;



/*
 * procedure: truncate_table
 *
 * Purpose: To truncate a table
 *
 * Arguments: schema name, table_name
 *
 */

procedure truncate_table(p_schema varchar2,
                         p_table  varchar2) is
    TableNotFound EXCEPTION;
    PRAGMA EXCEPTION_INIT(TableNotFound, -942);
begin

   if ( p_schema is null ) then
     return;
   end if;

   execute immediate 'truncate table ' || p_schema || '.' || p_table;


   exception
      when TableNotFound then
         null;
end;


/*
 * procedure: target_clean
 *
 * ***************************************************************************
 * NOTE: If you are not sure what you are doing do not run this procedure.
 *       This API is for Rapid Install team use only.
 * ***************************************************************************
 *
 * Purpose: To clean up target database for cloning purpose.
 *   It is callers responsibility to do the commit after calling target_clean
 *   target_clean does not handle any exceptions.
 *
 * Arguments: none
 *
 */
procedure target_clean is
    TableNotFound EXCEPTION;
    PRAGMA EXCEPTION_INIT(TableNotFound, -942);
begin

     -- Delete info from FND_CONCURRENT_QUEUE_SIZE table
     Delete From fnd_Concurrent_Queue_Size
      where concurrent_queue_id in
           (Select concurrent_queue_id
              from fnd_concurrent_queues
             where manager_type in (2,6));

     Delete from fnd_concurrent_queue_size
      where concurrent_queue_id in
           (select concurrent_queue_id
              from fnd_concurrent_queues
             where manager_type in
                  ( select service_id
                      from fnd_cp_services
                     where upper(service_handle) in
                                ('FORMSL', 'FORMSMS', 'FORMSMC',
                                 'REPSERV', 'TCF', 'APACHE',
                                 'JSERV', 'OAMGCS')));

      -- Delete from FND_CONCURRENT_QUEUES_TL table
      Delete From fnd_Concurrent_Queues_tl
       where concurrent_queue_id in
            (Select concurrent_queue_id
               from fnd_concurrent_queues
              where manager_type in (2,6));

      Delete from fnd_concurrent_queues_tl
       where concurrent_queue_id in
            (select concurrent_queue_id
               from fnd_concurrent_queues
              where manager_type in
                   (select service_id
                      from fnd_cp_services
                     where upper(service_handle) in
                                ('FORMSL', 'FORMSMS', 'FORMSMC',
                                 'REPSERV', 'TCF', 'APACHE',
                                 'JSERV', 'OAMGCS')));

      -- Delete from FND_CONCURRENT_QUEUES table
      Delete from fnd_concurrent_queues
       where manager_type in (2,6);

      Delete from fnd_concurrent_queues
       where manager_type in
            (select service_id
               from fnd_cp_services
              where upper(service_handle) in
                         ('FORMSL', 'FORMSMS', 'FORMSMC',
                          'REPSERV', 'TCF', 'APACHE',
                          'JSERV', 'OAMGCS'));

      -- Delete from FND_CONCURRENT_PROCESSES table
      Delete from fnd_concurrent_processes;

      -- Delete from FND_NODES table
      Delete from fnd_nodes;

      -- Delete from FND_CONFLICTS_DOMAIN table
      --
      -- NOTE: DELETION from FND_CONFLICTS_DOMAIN uses
      --       column DYNAMIC which was introduced in a patch.
      --       This column exists from 11.5.9 onwards.
  execute immediate 'delete from fnd_conflicts_domain fcd ' ||
                    ' where dynamic = ''Y''' ||
                    ' and not exists (select ''X''' ||
                    ' from fnd_concurrent_requests fcr ' ||
                    '  where fcr.cd_id = fcd.cd_id ' ||
                    '  and phase_code in (''P'', ''R''))';


      -- Reset FND_CONCURRENT_QUEUES table
      Update fnd_concurrent_queues
         set diagnostic_level = null,
             target_node = null, max_processes = 0,
	     node_name = null, node_name2 = null,
             running_processes = 0;

      -- Reset control codes in fnd_concurrent_queues table
      Update fnd_concurrent_queues
         set control_code = NULL
       where control_code not in ('E', 'R', 'X')
         and control_code IS NOT NULL;

/*
 *  DELETE all PRINTER Profile option values other than 'noprint'
 */

      -- Delete all PRITNER Profile option values other than 'noprint'
      Delete from fnd_profile_option_values
       where profile_option_value <> 'noprint'
         and profile_option_id =
            (select profile_option_id
               from fnd_profile_options
              where profile_option_name = 'PRINTER');

      -- Delete fnd_printer info
      Delete from fnd_printer
       where printer_name <> 'noprint';

      Delete from fnd_printer_tl
       where printer_name <> 'noprint';

      -- Update FND_CONCURRENT_PROGRAMS to reset PRINTER_NAME, ENABLE_TRACE
      Update fnd_concurrent_programs
         set printer_name = null,
             enable_trace = 'N'
       where printer_name is not null or enable_trace = 'Y';

      -- Delete All completed/running Concurrent Requests
      Delete from fnd_concurrent_requests
       where phase_code in ('C', 'R');

      -- Delete all pending Oracle Report requests
      Delete from fnd_concurrent_requests
       where phase_code = 'P'
         and (PROGRAM_APPLICATION_ID, CONCURRENT_PROGRAM_ID) in
               (select application_id, concurrent_program_id
                  from fnd_concurrent_programs
                 where execution_method_code = 'P');

      --
      -- TRUNCATE TABLES
      --
      -- Find out the database user for FND and JTF objects
      get_database_user;

      truncate_table(OracleUserFND, 'FND_ENV_CONTEXT');

      truncate_table(OracleUserFND, 'FND_EVENTS');

      truncate_table(OracleUserFND, 'FND_EVENT_TOKENS');

      truncate_table(OracleUserFND, 'FND_CONCURRENT_DEBUG_INFO');

      truncate_table(OracleUserFND, 'FND_CONC_REQ_STAT');

      truncate_table(OracleUserFND, 'FND_CRM_HISTORY');

      truncate_table(OracleUserFND, 'FND_TM_EVENTS');

      -- Login Related tables.

      truncate_table(OracleUserFND, 'FND_LOGINS');

      truncate_table(OracleUserFND, 'FND_LOGIN_RESPONSIBILITIES');

      truncate_table(OracleUserFND, 'FND_LOGIN_RESP_FORMS');

      truncate_table(OracleUserFND, 'FND_UNSUCCESSFUL_LOGINS');

      -- FND_LOG related tables.

      truncate_table(OracleUserFND, 'FND_LOG_MESSAGES');

      truncate_table(OracleUserFND, 'FND_LOG_EXCEPTIONS');

      truncate_table(OracleUserFND, 'FND_LOG_METRICS');

      truncate_table(OracleUserFND, 'FND_LOG_TRANSACTION_CONTEXT');

      truncate_table(OracleUserFND, 'FND_LOG_UNIQUE_EXCEPTIONS');

      -- OAM Transaction related tables.

      truncate_table(OracleUserFND, 'FND_OAM_APP_SYS_STATUS');

      truncate_table(OracleUserFND, 'FND_OAM_FORMS_RTI');

      truncate_table(OracleUserFND, 'FND_OAM_FRD_LOG');

      truncate_table(OracleUserFND, 'FND_OAM_UPLOAD_STATUS');

--      execute immediate 'TRUNCATE TABLE ' || OracleUserFND || '.FND_OAM_METVAL';

      truncate_table(OracleUserFND, 'FND_OAM_CONTEXT_FILES');


      -- Added following JTF tables based on bug 2949216

      truncate_table(OracleUserJTF, 'JTF_PREFAB_HA_COMPS');
      truncate_table(OracleUserJTF, 'JTF_PREFAB_HA_FILTERS');
      truncate_table(OracleUserJTF, 'JTF_PREFAB_HOST_APPS');
      truncate_table(OracleUserJTF, 'JTF_PREFAB_WSH_POES_B');
      truncate_table(OracleUserJTF, 'JTF_PREFAB_WSH_POES_TL');
      truncate_table(OracleUserJTF, 'JTF_PREFAB_WSHP_POLICIES');
      truncate_table(OracleUserJTF, 'JTF_PREFAB_CACHE_STATS');

   exception
      when TableNotFound then
         null;
end;



/*
 * procedure: truncate_table_topology
 *
 * Purpose:  To clean all the topology related tables
 *
 * Arguments: null
 *
 */
procedure truncate_table_topology is
begin

   -- Find out the database user for FND and JTF objects
   get_database_user;

   truncate_table(OracleUserFND,'FND_APPS_SYSTEM');
   truncate_table(OracleUserFND,'FND_APP_SERVERS');
   truncate_table(OracleUserFND,'FND_SYSTEM_SERVER_MAP');
   truncate_table(OracleUserFND,'FND_DATABASES');
   truncate_table(OracleUserFND,'FND_DATABASE_INSTANCES');
   truncate_table(OracleUserFND,'FND_DATABASE_SERVICES');
   truncate_table(OracleUserFND,'FND_DB_SERVICE_MEMBERS');
   truncate_table(OracleUserFND,'FND_DATABASE_ASSIGNMENTS');
   truncate_table(OracleUserFND,'FND_TNS_LISTENERS');
   truncate_table(OracleUserFND,'FND_TNS_LISTENER_PORTS');
   truncate_table(OracleUserFND,'FND_TNS_ALIASES');
   truncate_table(OracleUserFND,'FND_TNS_ALIAS_ADDRESSES');
   truncate_table(OracleUserFND,'FND_TNS_ALIAS_SETS');
   truncate_table(OracleUserFND,'FND_TNS_ALIAS_SET_USAGE');
   truncate_table(OracleUserFND,'FND_OAM_CONTEXT_FILES');
   truncate_table(OracleUserFND,'FND_APPL_TOPS');
   truncate_table(OracleUserFND,'FND_ORACLE_HOMES');
   truncate_table(OracleUserFND,'FND_TNS_ALIAS_DESCRIPTIONS');
   truncate_table(OracleUserFND,'FND_TNS_ALIAS_ADDRESS_LISTS');
   truncate_table(OracleUserFND,'FND_DB_INSTANCE_PARAMS');
end;

/*
 * Procedure: setup_clean
 *
 * ***************************************************************************
 * NOTE: If you are not sure what you are doing do not run this procedure.
 *       This API is for Cloning instance and will be used by cloning.
 * ***************************************************************************
 *
 * Purpose: To clean up target database in a cloning case.
 *   It is callers responsibility to do the commit after calling
 *   setup_clean.  setup_clean does not handle any exceptions.
 *
 * Arguments: none
 *
 */

procedure setup_clean is
begin
     -- Delete info from FND_CONCURRENT_QUEUE_SIZE table

     Delete From fnd_Concurrent_Queue_Size
      where concurrent_queue_id in
           (Select concurrent_queue_id
              from fnd_concurrent_queues
             where manager_type in (2,6));

     Delete from fnd_concurrent_queue_size
      where concurrent_queue_id in
           (select concurrent_queue_id
              from fnd_concurrent_queues
             where manager_type in
                  ( select service_id
                      from fnd_cp_services
                     where upper(service_handle) in
                                ('FORMSL', 'FORMSMS', 'FORMSMC',
                                 'REPSERV', 'TCF', 'APACHE',
                                 'JSERV', 'OAMGCS')));

      -- Delete from FND_CONCURRENT_QUEUES_TL table
      Delete From fnd_Concurrent_Queues_tl
       where concurrent_queue_id in
            (Select concurrent_queue_id
               from fnd_concurrent_queues
              where manager_type in (2,6));

      Delete from fnd_concurrent_queues_tl
       where concurrent_queue_id in
            (select concurrent_queue_id
               from fnd_concurrent_queues
              where manager_type in
                   (select service_id
                      from fnd_cp_services
                     where upper(service_handle) in
                                ('FORMSL', 'FORMSMS', 'FORMSMC',
                                 'REPSERV', 'TCF', 'APACHE',
                                 'JSERV', 'OAMGCS')));

      -- Delete from FND_CONCURRENT_QUEUES table
      Delete from fnd_concurrent_queues
       where manager_type in (2,6);

      Delete from fnd_concurrent_queues
       where manager_type in
            (select service_id
               from fnd_cp_services
              where upper(service_handle) in
                         ('FORMSL', 'FORMSMS', 'FORMSMC',
                          'REPSERV', 'TCF', 'APACHE',
                          'JSERV', 'OAMGCS'));

      -- Delete from FND_CONCURRENT_PROCESSES table
      Delete from fnd_concurrent_processes;

      -- Delete from FND_NODES table
      Delete from fnd_nodes;

      -- Delete from FND_CONFLICTS_DOMAIN table
      Delete from fnd_conflicts_domain fcd
        where dynamic = 'Y'
        and not exists (select 'X'
           from fnd_concurrent_requests fcr
           where fcr.cd_id = fcd.cd_id
           and phase_code in ('P', 'R'));

      -- Reset FND_CONCURRENT_QUEUES table
      Update fnd_concurrent_queues
         set diagnostic_level = null,
             target_node = null, max_processes = 0,
	     node_name = null, node_name2 = null,
             running_processes = 0;

      -- Reset control codes in fnd_concurrent_queues table
      Update fnd_concurrent_queues
         set control_code = NULL
       where control_code not in ('E', 'R', 'X')
         and control_code IS NOT NULL;

      --
      -- TRUNCATE TABLES
      --
      -- Find out the database user for FND and JTF objects
      get_database_user;

      truncate_table(OracleUserFND, 'FND_ENV_CONTEXT');
      truncate_table(OracleUserFND, 'FND_CONCURRENT_DEBUG_INFO');
      truncate_table(OracleUserFND, 'FND_CONC_REQ_STAT');
      truncate_table(OracleUserFND, 'FND_CRM_HISTORY');
      truncate_table(OracleUserFND, 'FND_TM_EVENTS');
      truncate_table(OracleUserFND, 'FND_CONC_QUEUE_ENVIRON');

      truncate_table(OracleUserFND , 'FND_OAM_CONTEXT_FILES');
      truncate_table(OracleUserFND , 'FND_OAM_APP_SYS_STATUS');

      -- Added following JTF tables based on bug 2949216
      truncate_table(OracleUserJTF , 'JTF_PREFAB_HA_COMPS');
      truncate_table(OracleUserJTF , 'JTF_PREFAB_HA_FILTERS');
      truncate_table(OracleUserJTF , 'JTF_PREFAB_HOST_APPS');
      truncate_table(OracleUserJTF , 'JTF_PREFAB_WSH_POES_B');
      truncate_table(OracleUserJTF , 'JTF_PREFAB_WSH_POES_TL');
      truncate_table(OracleUserJTF , 'JTF_PREFAB_WSHP_POLICIES');
      truncate_table(OracleUserJTF , 'JTF_PREFAB_CACHE_STATS');


      -- TRUNCATE TABLES RELATED TO TOPOLOGY
      truncate_table_topology;
end;



/*
 * Procedure: cancel_all_pending
 *
 * ***************************************************************************
 * NOTE: If you are not sure what you are doing do not run this function.
 *       This API is for ATG internal use only.
 *       This function should be used only after a clone, and while
 *       no concurrent managers are running.
 * ***************************************************************************
 *
 * Purpose: To clean up target database in a cloning case.
 *   It is callers responsibility to do the commit after calling
 *   cancel_all_pending.  Exceptions will be set on the FND_MESSAGE stack.
 *
 * Arguments: none
 * Returns: Number of requests cancelled, -1 on error
 *
 */

function cancel_all_pending return number is
begin

  fnd_message.set_name ('FND', 'CONC-Cancelled by');
  fnd_message.set_token ('USER', 'FND_CONC_CLONE');

  update fnd_concurrent_requests
    set phase_code = 'C',
    status_code = 'D',
    completion_text = fnd_message.get,
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id
    where phase_code = 'P';

  return SQL%ROWCOUNT;

exception
  when others then
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', 'FND_CONC_CLONE.CANCEL_ALL_PENDING');
    fnd_message.set_token('ERRNO', SQLCODE);
    fnd_message.set_token('REASON', SQLERRM);
    return -1;

end cancel_all_pending;



end;

/
