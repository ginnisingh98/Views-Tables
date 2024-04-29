--------------------------------------------------------
--  DDL for Package Body FND_GSM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GSM_UTIL" as
/* $Header: AFCPGUTB.pls 120.8.12010000.7 2017/05/26 05:11:45 rdayala ship $ */


  ctx_file_clob clob := null;
  contextfile_handle varchar2(128);

  --
  -- GENERIC_ERROR (Internal)
  --
  -- Set error message and raise exception for unexpected sql errors.
  --
  procedure GENERIC_ERROR(routine in varchar2,
                          errcode in number,
                          errmsg in varchar2) is
    begin
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', routine);
      fnd_message.set_token('ERRNO', errcode);
      fnd_message.set_token('REASON', errmsg);
    end;

  /* returns TRUE if FND_DATABASES table exists else FALSE */
  function db_model_exists return boolean is
    TableNotFound EXCEPTION;
    PRAGMA EXCEPTION_INIT(TableNotFound, -942);
    cnt number;
  begin
    execute immediate 'select count(*) from fnd_databases' into cnt;

    return TRUE;

   exception
      when TableNotFound then
         return FALSE;

  end;


  --
  -- procedure
  --   Append_ctx_fragment
  --
  -- Purpose
  --   Used to upload a context file into a clob for parsing.
  --   A temporary clob is created on the first call.  This clob
  --   will be freed when the upload_context_file procedure is called.
  --
  -- In Arguments:
  --   buffer - Context file, or fragment of a context file.
  --
  -- Out Arguments:
  --   retcode - 0 on success, >0 on error.
  --   message - Error message, up to 2000 bytes.
  --
  procedure append_ctx_fragment(buffer  in  varchar2,
                                retcode out nocopy number,
                                message out nocopy varchar2) is
    buffer_length number;
  begin

    -- Create the temp clob if necessary
    if ctx_file_clob is null then
      dbms_lob.createtemporary(ctx_file_clob, true, dbms_lob.session);
    end if;

    -- Append the buffer to the clob
if buffer IS NULL then
   retcode := 0;
   return;
else
    buffer_length := length(buffer);
    if (buffer_length > 0) then
    	dbms_lob.writeappend (ctx_file_clob, buffer_length, buffer);
    	retcode := 0;
        return;
    else
	retcode := 0;
  	return;
    end if;

end if;

  exception
    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_GSM_UTIL.APPEND_CTX_FRAGMENT');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;
      retcode := 1;

  end append_ctx_fragment;



  --
  -- Procedure
  --   upload_context_file
  --
  -- Purpose
  --   Parse the context file stored in the temporary clob and create
  --   the appropriate service instance definitions for GSM.  The clob is
  --   created by the append_ctx_fragment
  --
  -- In Arguments:
  --   filepath - Full path to the context file.  Used for bookkeeping.
  --   context_type - 'APPS' Application middle tier,
  --                  'DATABASE' Database context
  --   file_type  - 'CONTEXT' - Instantiated Context file
  --                'TEMPLATE' - Template file for Context file.
  --
  -- Out Arguments:
  --   retcode - 0 on success, >0 on error.
  --   message - Error message, up to 2000 bytes.
  --
  procedure upload_context_file(filepath in varchar2,
                                retcode out nocopy number,
                                message out nocopy varchar2,
				context_type in varchar2 default 'APPS',
				file_type in varchar2 default 'CONTEXT') is
  primary_node  varchar2(256);
  platform_name varchar2(30);
  domain_name   varchar2(64);
  tmp_node_name varchar2(320);
  reports_port  varchar2(20);
  forms_port    varchar2(20);
  methost_node  varchar2(256);
  met_data_port varchar2(20);
  met_req_port  varchar2(20);
  web_port      varchar2(20);
  web_pls_port  varchar2(20);
  apache_top    varchar2(512);
  web_pid_file  varchar2(510);
  web_pls_pid_file  varchar2(510);
  mod_pls_exists boolean;
  tech_stack    varchar2(128);
  logs_dir      varchar2(510);

  message_name varchar2(30);
  service_name varchar2(255);
  short_name   varchar2(30);
  ctrl_script  varchar2(512);
  port         varchar2(20);
  status       varchar2(30);
  service_handle varchar2(8);
  parameters     varchar(2000);
  process_name   varchar2(512);
  process_log    varchar2(512);
  reports_short_name varchar2(128);

  queue_id          number;
  queue_appl_id     number;
  fcq_enabled_flag  varchar2(1);

  my_parser    xmlParser.parser;
  my_doc       xmlDOM.DOMDocument;
  my_nodelist  xmlDOM.DOMNodeList;
  my_nodelist2 xmlDOM.DOMNodeList;
  my_contextlist xmlDOM.DOMNodeList;
  my_node      xmlDOM.DOMNode;
  my_node2     xmlDOM.DOMNode;
  my_context   xmlDOM.DOMNode;
  my_nodemap   xmlDOM.DOMNamedNodeMap;
  my_attr      xmlDOM.DOMAttr;
  my_element   xmlDOM.DOMElement;
  server_type  varchar2(128);
  oh_type      varchar2(128);
  i            number;
  listlength   number;
  file_found   boolean := FALSE;
  my_cdata     xmlDOM.DOMCharacterData;

  sr_num      varchar2(128);
  f_sr_num    number;
  db_sr_num   number;
  file_ver     varchar2(128);
  db_ver_str   varchar2(30);
  db_ver       number;
  f_ver        number;
  context_name varchar2(512);
  element_name varchar2(40);
  missing_elem      exception;
  exceeded_length   exception;
  null_context_name exception;
  metadata_file     exception;
  filesys_low_ver   exception;
  packagenotexists  exception;
  PRAGMA EXCEPTION_INIT(packagenotexists, -06550);
  sql_str      varchar2(1000);
  db_name      varchar2(8);
  db_domain    varchar2(255);
  db_host      varchar2(255);
  db_port      number;
  db_sid       varchar2(255);
  ret_val      number;
  inst_name    varchar2(16);
  inst_num     number;
  c_null       varchar2(1);
  n_null       number;
  v_result     integer;
  comp         number;

  begin


    if ctx_file_clob is null then
      retcode := 1;
      message := 'Developer error: Must call append_ctx_fragment first.';
      return;
    end if;

    /* Parse Context File */
    my_parser := xmlparser.newParser;
    xmlparser.parseClob(my_parser, ctx_file_clob);
--    dbms_lob.freetemporary(ctx_file_clob);
--    ctx_file_clob := null;
    my_doc := xmlparser.getdocument(my_parser);


    /* TO DO:  Below we search for each element top down.   The
     * performance of this procedure can be increased if we use
     * our knowledge of the file to avoid restarting at the top
     * for each element.
     * I don't know how significant of an improvement it will be.
     * Since this program will run very infrequently, we will defer
     * this effort.
     */

    /* Get version */
    my_contextlist := xmldom.getElementsByTagName(my_doc, 'oa_context');
    listlength := xmldom.getLength(my_contextlist);
    if listlength < 1 then
      -- may be it is metadata file
      my_contextlist := xmldom.getElementsByTagName(my_doc,'oa_context_doc');
      listlength := xmldom.getLength(my_contextlist);
      if listlength < 1 then
         element_name := 'oa_context/oa_context_doc';
         dbms_lob.freetemporary(ctx_file_clob);
         ctx_file_clob := null;
         raise missing_elem;
      end if;
    end if;

    my_node := xmldom.item(my_contextlist, 0);
    my_element := xmldom.makeElement(my_node);
    file_ver := xmldom.getAttribute(my_element, 'version');

    file_ver := substr(file_ver, instr(file_ver,':',1,1) + 1);

    file_ver := rtrim(file_ver, '$');
    file_ver := ltrim(rtrim(file_ver));
  --  f_ver := to_number(NVL(substr(file_ver,instr(file_ver,'.',1,1) +1),0));

    /* Get Context name */
    if ( file_type = 'TEMPLATE' ) then
      context_name := 'TEMPLATE';
    else
      my_contextlist := xmldom.getElementsByTagName(my_doc, 'oa_context_name');
      listlength := xmldom.getLength(my_contextlist);
      if listlength < 1 then
        context_name := 'METADATA';
      else
        my_node := xmldom.item(my_contextlist, 0);
        my_node := xmldom.getFirstChild(my_node);
        if xmldom.isNull(my_node) then
           dbms_lob.freetemporary(ctx_file_clob);
           ctx_file_clob := null;
           raise null_context_name;
        else
           context_name := ltrim(rtrim(xmldom.getNodeValue(my_node)));
        end if;
      end if;
    end if;

    if ( context_name in  ('METADATA', 'TEMPLATE') ) then
       -- For metadata get node name from session
       -- I don't think we need to handle no_data_found
       select substr(machine, 1,
		     decode(instr(machine, '.', 1, 1),
				0, length(machine),
				instr(machine, '.', 1, 1)-1))
	 into primary_node
         from v$session
        where audsid=USERENV('SESSIONID');
    else
      /* Get Name of Node */
      my_nodelist := xmldom.getElementsByTagName(my_doc, 'host');
      listlength := xmldom.getLength(my_nodelist);
      if listlength < 1 then
        element_name := 'host';
        dbms_lob.freetemporary(ctx_file_clob);
        ctx_file_clob := null;
        raise missing_elem;
      end if;
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
         primary_node := null;
      else
         primary_node := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;

    /* Get Serial Number from context file */
    if ( context_name in ('METADATA', 'TEMPLATE')) then
      sr_num := '0';
    else
      my_nodelist := xmldom.getElementsByTagName(my_doc, 'oa_context_serial');
      listlength := xmldom.getLength(my_nodelist);
      if listlength < 1 then
        goto service_upld;
      end if;
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        sr_num := null;
      else
        sr_num := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;

    f_sr_num := to_number(NVL(sr_num,0));

    -- try inserting row into fnd_oam_context_files table
    -- fnd_oam_context_files.status values: (H)istory,(S)uccess,(F)ailure
    --pbasha added for synchronization
         if  (contextfile_handle is null)
          then
         dbms_lock.allocate_unique('contextfile_lock',contextfile_handle);
          end if;
    v_result := dbms_lock.request(lockhandle=>contextfile_handle,release_on_commit=>TRUE);
    begin
       select NVL(serial_number, 0), version into db_sr_num, db_ver_str
         from fnd_oam_context_files
        where (node_name = primary_node
          and  path = filepath
          and  name not in ('METADATA','TEMPLATE')
          and  (status is null or upper(status) in ('S','F')))
           or (path = filepath
          and  name in ( 'METADATA', 'TEMPLATE'))
          for update;

          file_found := TRUE;
          v_result := dbms_lock.release(contextfile_handle);
    exception
       when no_data_found then
          file_found := FALSE;
    end;

--    db_ver := to_number(NVL(substr(db_ver_str,instr(db_ver_str,'.',1,1) +1),0));

    if ( not file_found ) then
        insert into fnd_oam_context_files
                     (name, version, path, last_synchronized,
                      text, creation_date, created_by, last_update_date,
                      last_updated_by, last_update_login, node_name,
                      status, ctx_type)
              values (context_name, file_ver, filepath, sysdate,
                      ctx_file_clob, sysdate, FND_GLOBAL.user_id, sysdate,
                      FND_GLOBAL.user_id, FND_GLOBAL.login_id, primary_node,
                      'S',
                      DECODE(context_type, 'APPS', 'A', 'DATABASE','D','A'));
       v_result := dbms_lock.release(contextfile_handle);

    else
      -- overwrite the database copy of context file if the serial # of the
      -- file being uploaded is >= to the copy in the DB.
      -- or context version is > version in file(due to template patch)
      -- for METADATA file we don't need to check for serial number.

         comp  := version_check(file_ver,db_ver_str);
      if ( (( (f_sr_num >= db_sr_num) OR (comp > 0))
              AND (context_name not in ('METADATA', 'TEMPLATE'))
           OR context_name in ('METADATA', 'TEMPLATE'))) then
	 -- bug6739946
	 -- added status to be set to S to mark upload of template
	 -- to already existing row
         update fnd_oam_context_files
            set path = filepath,
                last_synchronized = sysdate,
                text = ctx_file_clob,
                last_update_date = sysdate,
                last_updated_by  = fnd_global.user_id,
                last_update_login = fnd_global.login_id,
                node_name = primary_node,
                version = file_ver,
                status = 'S'
          where (node_name = primary_node
            and  path = filepath
            and  name not in ('METADATA', 'TEMPLATE')
            and  (status is null or upper(status) in ('S','F')))
             or (path = filepath
            and  name in ( 'METADATA', 'TEMPLATE'));
       else
          raise filesys_low_ver;
       end if;
    end if;

    <<service_upld>>

    -- clear clob
    dbms_lob.freetemporary(ctx_file_clob);
    ctx_file_clob := null;
    if ( context_name in ('METADATA', 'TEMPLATE')
           or context_type = 'DATABASE') then
       -- for metadata we don't need to register service definitions.
       -- for database context file we don't need to register service def
       raise metadata_file;
    end if;

    -- if FND_DATABASES data model exists then try to insert topology info
    if ( db_model_exists ) then
    begin
      sql_str := 'declare b boolean; Begin b := ' ||
		'fnd_conc_database.register_database(:1,:2,:3,:4,:5); ' ||
		' if (b) then :6 := 1; else :6 := 0; end if; end;';
      select substr(sys_context('userenv','db_name'),1,8) into db_name
        from dual;
      select substr(value,1,255) into db_domain
        from v$parameter where name='db_domain';

      execute immediate sql_str using in db_name,
                  in db_domain, in c_null, in c_null, in n_null, out ret_val;


      /* Get db_host value */
      my_nodelist := xmldom.getElementsByTagName(my_doc, 'dbhost');
      listlength := xmldom.getLength(my_nodelist);
      if listlength < 1 then
        element_name := 'dbhost';
        raise missing_elem;
      end if;
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        db_host := null;
      else
        db_host := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;

      /* Get db_sid value */
      my_nodelist := xmldom.getElementsByTagName(my_doc, 'dbsid');
      listlength := xmldom.getLength(my_nodelist);
      if listlength < 1 then
        element_name := 'dbsid';
        raise missing_elem;
      end if;
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        db_sid := null;
      else
        db_sid := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;

      /* Get db_port value */
      my_nodelist := xmldom.getElementsByTagName(my_doc, 'dbport');
      listlength := xmldom.getLength(my_nodelist);
      if listlength < 1 then
        element_name := 'dbport';
        raise missing_elem;
      end if;
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        db_port := null;
      else
        db_port := to_number(ltrim(rtrim(xmldom.getNodeValue(my_node))));
      end if;

      select instance_number,instance_name
        into inst_num, inst_name
        from v$instance;

      sql_str := 'declare b boolean; Begin b := ' ||
		'fnd_conc_database.register_instance( ' ||
                ':1,:2,:3,:4,:5,:6,:7,:8,:9); ' ||
		' if (b) then :10 := 1; else :10 := 0; end if; end;';
      execute immediate sql_str using in db_name,
		in inst_name, in inst_num, in db_sid, in db_host, in db_port,
		in db_sid, in c_null, in c_null, out ret_val;


      exception
        /* Ignore package(FND_CONC_DATABASE) not available cases. */
        when packagenotexists then
           null;
      end;
     end if;



    /* Get Name of platform */
    my_nodelist := xmldom.getElementsByTagName(my_doc, 'platform');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'platform';
      raise missing_elem;
    end if;
    my_node := xmldom.item(my_nodelist, 0);
    my_node := xmldom.getFirstChild(my_node);
    if xmldom.isNull(my_node) then
      platform_name := null;
    else
      platform_name := ltrim(rtrim(xmldom.getNodeValue(my_node)));
    end if;


    -- Tru64 UNIX Alpha need hostname.domain_name as node name

    if ( platform_name = 'UNIX Alpha' ) then
	    /* Get Name of domain */
        my_nodelist := xmldom.getElementsByTagName(my_doc, 'domain');
        listlength := xmldom.getLength(my_nodelist);
        if listlength < 1 then
          element_name := 'domain';
          raise missing_elem;
        end if;
        my_node := xmldom.item(my_nodelist, 0);
        my_node := xmldom.getFirstChild(my_node);
        if xmldom.isNull(my_node) then
          domain_name := null;
        else
          domain_name := substr(ltrim(rtrim(xmldom.getNodeValue(my_node))), 1, 64);
	    end if;

        tmp_node_name := primary_node || '.' || domain_name;
        if (length(tmp_node_name) > 256) then
            raise exceeded_length;
        else
            primary_node := tmp_node_name;
        end if;
    end if;

    /* Since port info is stored separately from the process info,
       we first retrieve the ports, and then loop through the processes
       to register the services. */


    /* Get the Reports port */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'reports_port');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'reports_port';
      -- To fix 4684481
      -- raise missing_elem;
    else
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        reports_port := null;
      else
        reports_port := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;



    /* Get the Forms port */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'forms_port');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'forms_port';
      -- To fix bug 5151130
      -- raise missing_elem;
    end if;
    my_node := xmldom.item(my_nodelist, 0);
    my_node := xmldom.getFirstChild(my_node);
    if xmldom.isNull(my_node) then
      forms_port := null;
    else
      forms_port := ltrim(rtrim(xmldom.getNodeValue(my_node)));
    end if;

    /* Get the Metrics Server Node */

    methost_node := null;

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'hostname');
    listlength := xmldom.getLength(my_nodelist);

    if listlength > 1 then
      for i in 0..listlength-1 loop
        my_node := xmldom.item(my_nodelist, i);
	my_element := xmldom.makeElement(my_node);
	oh_type := xmldom.getAttribute(my_element, 'oa_var');
	exit when oh_type = 's_methost';
      end loop;
    end if;

    if (oh_type = 's_methost') then
      my_node := xmldom.getFirstChild(my_node);
      if not xmldom.isNull(my_node) then
        methost_node := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;
    if methost_node is null then
      methost_node := primary_node;
    end if;

    /* Get the metrics request port */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'met_req_port');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'met_req_port';
      -- To fix bug 5151130
      -- raise missing_elem;
    else
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        met_req_port := null;
      else
        met_req_port := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;


    /* Get the metrics data port */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'met_data_port');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'met_data_port';
      -- To fix bug 5151130
      -- raise missing_elem;
    else
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if xmldom.isNull(my_node) then
        met_data_port := null;
      else
        met_data_port := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;

    /* Get the web port */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'web_port');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'web_port';
      raise missing_elem;
    end if;
    my_node := xmldom.item(my_nodelist, 0);
    my_node := xmldom.getFirstChild(my_node);
    if xmldom.isNull(my_node) then
      web_port := null;
    else
      web_port := ltrim(rtrim(xmldom.getNodeValue(my_node)));
    end if;

    /* Get web pls port if any */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'web_port_pls');
    listlength := xmldom.getLength(my_nodelist);
    if listlength > 0 then
       my_node := xmldom.item(my_nodelist, 0);
       my_node := xmldom.getFirstChild(my_node);
       if xmldom.isNull(my_node) then
         web_pls_port := null;
       else
         web_pls_port := ltrim(rtrim(xmldom.getNodeValue(my_node)));
       end if;
    else
       web_pls_port := null;
    end if;


    /* Get the Apache_Top */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'ORACLE_HOME');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
      element_name := 'ORACLE_HOME oa_var=s_web_oh';
      raise missing_elem;
    end if;

    for i in 0..listlength-1 loop
      my_node := xmldom.item(my_nodelist, i);
      my_element := xmldom.makeElement(my_node);
      oh_type := xmldom.getAttribute(my_element, 'oa_var');
      exit when oh_type = 's_weboh_oh';
    end loop;

    if (oh_type = 's_weboh_oh') then
        my_node := xmldom.getFirstChild(my_node);
        if xmldom.isNull(my_node) then
          apache_top := null;
        else
          apache_top := ltrim(rtrim(xmldom.getNodeValue(my_node)));
        end if;
    else
      element_name := 'ORACLE_HOME oa_var=s_web_oh';
      raise missing_elem;
    end if;


    /* Get the web pid file if any, do not show this an error */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'web_pid_file');
    listlength := xmldom.getLength(my_nodelist);
    if listlength > 0 then
       my_node := xmldom.item(my_nodelist, 0);
       my_node := xmldom.getFirstChild(my_node);
       if xmldom.isNull(my_node) then
         web_pid_file := null;
       else
         web_pid_file := ltrim(rtrim(xmldom.getNodeValue(my_node)));
       end if;
    end if;

    /* bug11844982                                                */
    /* Get the web pls pid file if any, do not show this an error */

    web_pls_pid_file := null;

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'httpd_pls_pid_file');
    listlength := xmldom.getLength(my_nodelist);
    if listlength > 0 then
      my_node := xmldom.item(my_nodelist, 0);
      my_node := xmldom.getFirstChild(my_node);
      if not xmldom.isNull(my_node) then
        web_pls_pid_file := ltrim(rtrim(xmldom.getNodeValue(my_node)));
      end if;
    end if;
    if web_pls_pid_file is null then
      web_pls_pid_file := apache_top||'/Apache/Apache/logs/httpd_pls.pid';
    end if;

    /* Get logs_dir value, used for reports */
    my_nodelist := xmldom.getElementsByTagName(my_doc, 'logs_dir');
    listlength := xmldom.getLength(my_nodelist);
    if listlength > 0 then
       my_node := xmldom.item(my_nodelist, 0);
       my_node := xmldom.getFirstChild(my_node);
       if xmldom.isNull(my_node) then
         logs_dir := null;
       else
         logs_dir := ltrim(rtrim(xmldom.getNodeValue(my_node)));
       end if;
    else
       element_name := 'logs_dir oa_var=s_logdir';
       raise missing_elem;
    end if;


    /* Get techstack value */
    my_nodelist := xmldom.getElementsByTagName(my_doc, 'config_option');
    listlength := xmldom.getLength(my_nodelist);
    if listlength < 1 then
       tech_stack := null;
    end if;

    for i in 0..listlength-1 loop
      my_node := xmldom.item(my_nodelist, i);
      my_element := xmldom.makeElement(my_node);
      oh_type := xmldom.getAttribute(my_element, 'oa_var');
      exit when oh_type = 's_techstack';
    end loop;

    if (oh_type = 's_techstack') then
        my_node := xmldom.getFirstChild(my_node);
        if xmldom.isNull(my_node) then
          tech_stack := null;
        else
          tech_stack := ltrim(rtrim(xmldom.getNodeValue(my_node)));
        end if;
    else
        tech_stack := null;
    end if;


    /* find out mod_pls process is exists or not. If exists then pass
       'core' to Apache control script, else old stuff.
     */

    mod_pls_exists := FALSE;
    my_nodelist := xmldom.getElementsByTagname(my_doc, 'oa_process');
    listlength := xmldom.getLength(my_nodelist);
    for i in 0..(listlength -1 ) loop
      my_node := xmldom.item(my_nodelist, i);
      my_element := xmldom.makeElement(my_node);
      server_type := xmldom.getAttribute(my_element, 'type');

      if (server_type = 'apache_pls' ) then
         mod_pls_exists := TRUE;
      end if;
    end loop;


    /* Register Services */

    my_nodelist := xmldom.getElementsByTagName(my_doc, 'oa_process');
    listlength := xmldom.getLength(my_nodelist);
    for i in 0..(listlength - 1) loop
      my_node := xmldom.item(my_nodelist, i);
      my_element := xmldom.makeElement(my_node);
      server_type := xmldom.getAttribute(my_element, 'type');


      /* Get the process name */
      my_nodelist2 := xmldom.getElementsByTagName(my_element,
                                                      'oa_process_name');
      listlength := xmldom.getLength(my_nodelist2);
      if listlength < 1 then
        element_name := 'oa_process_name';
        raise missing_elem;
      end if;
      my_node2 := xmldom.item(my_nodelist2, 0);
      my_node2 := xmldom.getFirstChild(my_node2);
      if xmldom.isNull(my_node2) then
        process_name := null;
      else
        process_name := ltrim(rtrim(
                            xmldom.getNodeValue(my_node2), '" '), '" ');
      end if;


      /* Get the control script name. */
      my_nodelist2 := xmldom.getElementsByTagName(my_element,
                                                 'ctrl_script');
      listlength := xmldom.getLength(my_nodelist2);
      if listlength < 1 then
        element_name := 'ctrl_script';
        raise missing_elem;
      end if;
      my_node2 := xmldom.item(my_nodelist2, 0);
      my_node2 := xmldom.getFirstChild(my_node2);
      if xmldom.isNull(my_node2) then
        ctrl_script := null;
      else
        ctrl_script := ltrim(rtrim(
                             xmldom.getNodeValue(my_node2), '" '), '" ');
      end if;


      /* Get the log file name name. */
      my_nodelist2 := xmldom.getElementsByTagName(my_element,
                                                 'oa_process_log');
      listlength := xmldom.getLength(my_nodelist2);
      if listlength < 1 then
        element_name := 'oa_process_log';
        raise missing_elem;
      end if;
      my_node2 := xmldom.item(my_nodelist2, 0);
      my_node2 := xmldom.getFirstChild(my_node2);
      if xmldom.isNull(my_node2) then
        process_log := null;
      else
        process_log := ltrim(rtrim(
                             xmldom.getNodeValue(my_node2), '" '), '" ');
      end if;


      if server_type in ('apache','forms','met_cl','met_srv',
                         'reports', 'apache_pls') then

        /* Determine full name, port, and short name */
        if server_type  = 'apache' then
          message_name := 'GSM-APACHE SVC INST';
          port := web_port;
          short_name := 'APACHE_'||substrb(primary_node, 1, 12)||'_'||
                        substr(port, 1, 8);
          service_handle := 'Apache';

          /* if mod_pls_exists then pass 'core' to regular apache */
          if (mod_pls_exists) then
             parameters :=  'START=PATH,'|| ctrl_script||' start core;'||
                         'STOP=PATH,'||ctrl_script||' stop core;'||
                         'LOG='||process_log||';';
          else
             parameters := 'START=PATH,'|| ctrl_script||' start;'||
                           'STOP=PATH,'||ctrl_script||' stop;'||
                           'LOG='||process_log||';';
          end if;

          /* determine pid file for ias10 */
          if ( tech_stack = 'ias10' ) then
              if ( substr(upper(platform_name),
                           length(platform_name)-1) <> 'NT' ) then
		web_pid_file := apache_top || '/Apache/Apache/logs/httpds.pid';
              else
                web_pid_file := apache_top || '/Apache/Apache/logs/httpd.pid';
              end if;
          end if;

          if (apache_top is not null) then
            /* if pid file is there then use it */
            if ( web_pid_file is not null) then
              parameters := parameters || 'PID=FILE,PATH,' ||web_pid_file||
                            ';'|| 'SERVICE='||process_name;
            else
              parameters := parameters || 'PID=FILE,PATH,'||apache_top||
                           '/Apache/Apache/logs/httpds.pid;'||
                           'SERVICE='||process_name;
            end if;
          else
            parameters := parameters || 'SERVICE='||process_name;
          end if;

        elsif server_type  = 'apache_pls' then
          message_name := 'GSM-MOD PLS SVC INST';
          port := web_pls_port;
          short_name := 'APACHE_'||substrb(primary_node, 1, 12)||'_'||
                        substr(port, 1, 8);
          service_handle := 'Apache';

          parameters :=  'START=PATH,'|| ctrl_script||' start pls;'||
                         'STOP=PATH,'||ctrl_script||' stop pls;'||
                         'LOG='||process_log||';';

          /* designate the pls pid file */
          if (apache_top is not null) then
              parameters := parameters || 'PID=FILE,PATH,' ||web_pls_pid_file||
                            ';'|| 'SERVICE='||process_name;
          else
            parameters := parameters || 'SERVICE='||process_name;
          end if;

          /* The PID file won't be used on NT, so the Unix style
             directory delimiters above should not be a problem. */


        elsif server_type  = 'forms' then
          message_name := 'GSM-FORMS SVC INST';
          port := forms_port;
          short_name := 'FORMS_'||substr(primary_node, 1, 12)||'_'||
                         substrb(port, 1, 8);
          service_handle := 'FormsL';
          parameters :=  'START=PATH,'|| ctrl_script||' start;'||
                         'STOP=PATH,'||ctrl_script||' stop;'||
                         'LOG='||process_log||';'||
                         'PID=FIND,f60srvm,'||primary_node||'_'||port||';'||
                         'SERVICE='||process_name;


        elsif server_type  = 'met_cl' then
          message_name := 'GSM-METRICS CL SVC INST';
          port := met_data_port;
          short_name := 'MET_CL_'||substr(primary_node, 1, 12)||'_'||
                         substrb(met_data_port, 1, 8);
          service_handle := 'FormsMC';
          parameters :=  'START=PATH,'|| ctrl_script||' start;'||
                         'STOP=PATH,'||ctrl_script||' stop;'||
                         'LOG='||process_log||';'||
                         'PID=FIND,d2lc60,'||methost_node||
                         ','||met_data_port||';'||
                         'SERVICE='||process_name;

        elsif server_type  = 'met_srv' then
          message_name := 'GSM-METRICS SRV SVC INST';
          port := met_req_port;
          short_name := 'MET_SRV_'||substr(primary_node, 1, 12)||'_'||
                         substrb(met_req_port, 1, 8);
          service_handle := 'FormsMS';
          parameters :=  'START=PATH,'|| ctrl_script||' start;'||
                         'STOP=PATH,'||ctrl_script||' stop;'||
                         'LOG='||process_log||';'||
                         'PID=FIND,d2ls60,'||met_data_port||
                         ','||met_req_port||';'||
                         'SERVICE='||process_name;

        elsif server_type  = 'reports' then
          /* Note the service name has the format:
           *    "Oracle Reports Server [short_name]"
           * Here we extract the short_name.                     */
          reports_short_name := rtrim(substr(process_name,
                                       instr(process_name,'[')+1), '] ');
          /* replace Rep60 with REP60
           * using parse mechanism instead of replace func
           */
          reports_short_name := upper(substr(reports_short_name, 1,
                                       instr(reports_short_name,'_'))) ||
				substr(reports_short_name,
					instr(reports_short_name,'_')+1);

	  /* 3578632 adrepctl now uses REP60_%s_dbSid% as the REPSERV_NAME,
           *  instead of s_reptname as we do here.                          */
	  if (db_sid is not null ) then
		reports_short_name := 'REP60_' || db_sid;
	  end if;

          message_name := 'GSM-REPORTS SRV SVC INST';
          port := reports_port;
          short_name := 'REPORTS_'||substrb(primary_node, 1, 12)||'_'||
                        substr(port, 1, 8);
          service_handle := 'RepServ';

          parameters :=  'START=PATH,'|| ctrl_script||' start;'||
                         'STOP=PATH,'||ctrl_script||' stop;'||
                         'LOG='||process_log||';'||
                         'PID=FILE,PATH,'||logs_dir||'/'||reports_short_name||
			 '.PID'||';'||'SERVICE='||process_name;
       end if;

        /* Is the service enabled? */
        my_nodelist2 := xmldom.getElementsByTagName(my_element,
                                                    'oa_process_status');
        listlength := xmldom.getLength(my_nodelist2);
        if listlength < 1 then
          element_name := 'oa_process_status';
          raise missing_elem;
        end if;
        my_node2 := xmldom.item(my_nodelist2, 0);
        my_node2 := xmldom.getFirstChild(my_node2);
        if xmldom.isNull(my_node2) then
          status := 'disabled';
        else
          status := ltrim(rtrim(xmldom.getNodeValue(my_node2), '" '), '" ');
        end if;

        if status = 'enabled' then
          /* Does the service exist in GSM? */
          begin
            select concurrent_queue_id, application_id, enabled_flag
              into queue_id, queue_appl_id, fcq_enabled_flag
              from fnd_concurrent_queues
             where application_id = 0
               and concurrent_queue_name = short_name;

            /* Yes, the service exists.  Otherwise, there would *
             * have been a no_data_found exception.             */


            /* Update the workshift parameters. */

            update fnd_concurrent_queue_size
               set service_parameters = parameters
             where concurrent_queue_id = queue_id
               and queue_application_id = queue_appl_id;


          exception

            when no_data_found then
              /* The service is not registered with GSM */
              /* Do the registration now. */
              fnd_message.set_name('FND', message_name);
              fnd_message.set_token('NODE', primary_node);
              fnd_message.set_token('PORT', port);
              service_name := substrb(fnd_message.get, 1, 240);

              begin
                fnd_manager.register_si(manager => service_name,
                                        application => 'FND',
                                        short_name => short_name,
                                        service_handle => service_handle,
                                        primary_node => upper(primary_node),
                                        language_code => userenv('LANG'));


                fnd_manager.assign_work_shift(
                                        manager_short_name => short_name,
                                        manager_application => 'FND',
                                        processes => 1,
                                        sleep_seconds => 1,
                                        work_shift_id => 0,
                                        svc_params => parameters);

                 /* Now update enabled flag to 'N' */
                select concurrent_queue_id, application_id, enabled_flag
                  into queue_id, queue_appl_id, fcq_enabled_flag
                  from fnd_concurrent_queues
                 where application_id = 0
                   and concurrent_queue_name = short_name;

                update fnd_concurrent_queues
                   set enabled_flag = 'N'
                 where concurrent_queue_id = queue_id
                   and application_id = queue_appl_id;

              exception
                when program_error then
                  message := fnd_manager.message;

                  if (not xmldom.isNull(my_doc)) then
                     xmldom.freeDocument (my_doc);
                  end if;
                  xmlparser.freeParser (my_parser);

                  retcode := 1;
                  return;

                when others then
                  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                  fnd_message.set_token('ROUTINE',
                                        'FND_GSM_UTIL.upload_context_file');
                  fnd_message.set_token('ERRNO', SQLCODE);
                  fnd_message.set_token('REASON', SQLERRM);
                  message :=  fnd_message.get;

                  if (not xmldom.isNull(my_doc)) then
                     xmldom.freeDocument (my_doc);
                  end if;
                  xmlparser.freeParser (my_parser);

                  retcode := 1;
                  return;
              end;
          end;

        else /* Service is disabled in context file. */

          /* Update fcq if necessary */
          update fnd_concurrent_queues
             set enabled_flag = 'N'
           where application_id = 0
             and concurrent_queue_name = short_name;

        end if;

      end if;

    end loop;

    if (not xmldom.isNull(my_doc)) then
       xmldom.freeDocument (my_doc);
    end if;

    xmlparser.freeParser (my_parser);

    retcode := 0;

  exception
    when metadata_file then
      if (not xmldom.isNull(my_doc)) then
         xmldom.freeDocument (my_doc);
      end if;
      xmlparser.freeParser (my_parser);

      retcode := 0;

    when null_context_name then
      fnd_message.set_name('FND', 'GSM-CTX NULL CONTEXT');
      fnd_message.set_token('FILE', filepath);
      message := fnd_message.get;

      if (not xmldom.isNull(my_doc)) then
         xmldom.freeDocument (my_doc);
      end if;
      xmlparser.freeParser (my_parser);

      retcode := 1;

    when filesys_low_ver then
      fnd_message.set_name('FND', 'GSM-CTX FILE SYS COPY LOW');
      fnd_message.set_token('FILE', filepath);
      message := fnd_message.get;

      if (not xmldom.isNull(my_doc)) then
         xmldom.freeDocument (my_doc);
      end if;
      xmlparser.freeParser (my_parser);

      retcode := 1;

    when missing_elem then
      fnd_message.set_name('FND', 'GSM-CTX ELEMENT MISSING');
      fnd_message.set_token('ELEMENT', element_name);
      fnd_message.set_token('FILE', filepath);
      message :=  fnd_message.get;

      if (not xmldom.isNull(my_doc)) then
         xmldom.freeDocument (my_doc);
      end if;
      xmlparser.freeParser (my_parser);

      retcode := 1;

    when exceeded_length then
      fnd_message.set_name('FND', 'GSM-CTX NODE NAME TOO LONG');
      fnd_message.set_token('NODE_NAME', tmp_node_name);
      message := fnd_message.get;

      if (not xmldom.isNull(my_doc)) then
         xmldom.freeDocument (my_doc);
      end if;
      xmlparser.freeParser (my_parser);

      retcode := 1;

    when others then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'FND_GSM_UTIL.upload_context_file');
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      message :=  fnd_message.get;

      if (not xmldom.isNull(my_doc)) then
         xmldom.freeDocument (my_doc);
      end if;
      xmlparser.freeParser (my_parser);

      retcode := 1;

  end upload_context_file;

function version_check(version1 varchar,version2 varchar) return number is
         l_version1      varchar2(500) default version1 || '.';
	 l_version2      varchar2(500) default version2 || '.';
	 TYPE data IS TABLE OF varchar2(100);
         l_data1  data := data();
	 l_data2  data := data();
	 n number;
	 m number;
	 x number;
	 p number;

  begin

      loop
           exit when l_version1 is null and l_version2 is null;
	   if l_version1 is not null then
              n := instr( l_version1, '.' );
              l_data1.extend;
              l_data1(l_data1.count) := ltrim( rtrim( substr( l_version1, 1, n-1 ) ) );
              l_version1 := substr( l_version1, n+1 );
	   end if;
	   if l_version2 is not null then
	      m := instr( l_version2, '.' );
              l_data2.extend;
              l_data2(l_data2.count) := ltrim( rtrim( substr( l_version2, 1, m-1 ) ) );
              l_version2 := substr( l_version2, m+1 );
	    end if;

     end loop;

         if (l_data1.count < l_data2.count) then
                x := l_data1.count;
          else
	        x := l_data2.count;
           end if;
     for i in 1 .. x
        loop
          p:=  to_number(NVL(l_data1(i),0))-to_number(NVL(l_data2(i),0));
	  if (p <> 0) then
	      return p;
	  end if;
       end loop;
         return l_data1.count - l_data2.count;
  end version_check;
end fnd_gsm_util;

/
