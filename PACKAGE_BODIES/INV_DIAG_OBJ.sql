--------------------------------------------------------
--  DDL for Package Body INV_DIAG_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_OBJ" as
/* $Header: INVDOBJB.pls 120.0.12000000.1 2007/06/22 01:09:11 musinha noship $ */

PROCEDURE init is
BEGIN
null;
END init;

PROCEDURE cleanup IS
BEGIN
 null;
NULL;
END cleanup;

PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                        report OUT NOCOPY JTF_DIAG_REPORT,
                        reportClob OUT NOCOPY CLOB) IS
 reportStr   LONG;           -- REPORT
 sqltxt    VARCHAR2(9999);  -- SQL select statement
 c_username  VARCHAR2(50);   -- accept input for username
 statusStr   VARCHAR2(50);   -- SUCCESS or FAILURE
 errStr      VARCHAR2(4000); -- error message
 fixInfo     VARCHAR2(4000); -- fix tip
 isFatal     VARCHAR2(50);   -- TRUE or FALSE
 dummy_num   NUMBER;
 row_limit   NUMBER;
 l_org_id    NUMBER;
 l_script    varchar2(30);
 l_app_id    NUMBER;
 l_app       varchar2(50);
 l_pkg       varchar2(30);
 l_file      varchar2(30);
 l_patch     varchar2(100);
 l_conc_prg  varchar2(30);

BEGIN
JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
-- accept input
l_script :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('CheckName',inputs);
l_app_id :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ApplicationId',inputs);
l_pkg :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('Package',inputs);
l_file :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('FileName',inputs);
l_patch :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('PatchNum',inputs);
l_conc_prg :=JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue('ConcurrentProgram',inputs);
row_limit :=INV_DIAG_GRP.g_max_row;

JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(':'||l_org_id||' Check '||l_script||' appId '||l_app_id);
JTF_DIAGNOSTIC_COREAPI.BRPrint;

if l_app_id is null then
   select APPLICATION_ID
     into l_app_id
     from FND_APPLICATION
    where APPLICATION_SHORT_NAME='INV';
    reportStr := ' INV';
    l_app :='INV';
else
   select trim(APPLICATION_SHORT_NAME)
     into l_app
     from FND_APPLICATION
    where APPLICATION_ID=l_app_id;
    reportStr := ' '||l_app;
end if;

if l_script = 'invalid' then
    sqltxt := 'SELECT owner "Owner", object_name "Name", object_type "Type" '||
              '   , status "Status", TO_CHAR( last_ddl_time, ''DD-MON-RR'' ) "Last Compile Date" '||
              '   , TO_CHAR( created, ''DD-MON-RR'' ) "Creation Date"  '||
              'FROM dba_objects WHERE owner = ''APPS'' and status=''INVALID'' AND  '||
              '    ( object_name LIKE ''INV%'' OR '||
              '      object_name LIKE ''MTL%'' OR '||
              '      object_name LIKE '''||l_app||'%'' OR '||
              '      object_name IN ( ''LOT_SPLIT_DATA_INSERT'' , ''ORG_FREIGHT_TL_PKG'' , '||
              '                       ''PERIOD_SUMMARY_TRANSFER_UTIL'' , ''RMA_UPDATE'' ,'||
              '                       ''RMA_UPDATE'' , ''LOT_SPLIT_DATA_INSERT'' , '||
              '                       ''SERIAL_CHECK'' , ''MISC_TRANSACTIONS_UTIL'', '||
              '                       ''USER_PKG_LOT'' )  )  '||
              'ORDER BY object_name, object_type';
    if l_app_id <> 401 then
       reportStr :=' and '||l_app;
    end if;
    dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Invalid database objects related to INV'||reportStr);

elsif l_script ='profile' then
   sqltxt :='SELECT b.user_profile_option_name "Long Name"  '||
            '   , a.profile_option_name "Short Name"  '||
            '   , DECODE( c.level_id, 10001, ''Site''  '||
            '                       , 10002, ''Application''  '||
            '                       , 10003, ''Responsibility''  '||
            '                       , 10004, ''User''  '||
            '                       , ''Unknown'') "Level"  '||
            '   , DECODE( c.level_id, 10001, ''Site''  '||
            '             , 10002, NVL(h.application_short_name,to_char(c.level_value))  '||
            '             , 10003, NVL(g.responsibility_name,to_char(c.level_value))  '||
            '             , 10004, NVL(e.user_name,to_char(c.level_value))  '||
            '             , ''Unknown'') "Level Value"  '||
            '   , c.profile_option_value "Profile Value"  '||
            '   , c.profile_option_id "Profile ID"  '||
            '   , TO_CHAR( c.last_update_date , ''DD-MON-RR HH24:MI'' ) "Updated Date"   '||
            '   , NVL(d.user_name, TO_CHAR(c.last_updated_by)) "Updated By"  '||
            ' FROM fnd_profile_options a  '||
            '    , fnd_profile_options_vl b  '||
            '    , fnd_profile_option_values c  '||
            '    , fnd_user d  '||
            '    , fnd_user e  '||
            '    , fnd_responsibility_vl g  '||
            '    , fnd_application h  '||
            'WHERE a.application_id = '||l_app_id||
            ' AND a.profile_option_name = b.profile_option_name  '||
            ' AND a.profile_option_id = c.profile_option_id  '||
            ' AND a.application_id = c.application_id  '||
            ' AND c.last_updated_by = d.user_id (+)  '||
            ' AND c.level_value = e.user_id (+)  '||
            ' AND c.level_value = g.responsibility_id (+)  '||
            ' AND c.level_value = h.application_id (+)  '||
            'ORDER BY b.user_profile_option_name, c.level_id, c.profile_option_value';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Profileoptions and settings for applicationId '||l_app_id);

elsif l_script = 'version' then

   if l_pkg is not null then
      sqltxt := ' select text "Package(Spec/Body)" from dba_source where owner =''APPS'' and name= upper('''||l_pkg||''') and line=2';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Version of the package '||l_pkg);
   elsif l_file is null then
      sqltxt := ' select name "Package(Spec/Body)", text "File Info" from dba_source where owner =''APPS'' and name like '''||l_app||'_%'' and line=2 order by name';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Version of all packages from application '||l_app);
   end if;

   if l_file is not null then
      sqltxt := ' select f.filename Name, subdir Directory, version'||
                ' from ad_file_versions v, ad_files f'||
                ' where v.file_id=f.file_id'||
                ' and file_version_id='||
                '  (select max(fv.file_version_id)'||
                '  from ad_file_versions fv'||
                '  where fv.file_id=v.file_id) '||
                ' and f.filename like '''||l_file||'%''';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Latest Patched Version of the file: '||l_pkg);
   elsif l_pkg is null then
      sqltxt := ' select f.filename Name, subdir Directory, version'||
                ' from ad_file_versions v, ad_files f'||
                ' where v.file_id=f.file_id'||
                ' and file_version_id='||
                '  (select max(fv.file_version_id)'||
                '  from ad_file_versions fv'||
                '  where fv.file_id=v.file_id) '||
                ' and subdir like ''forms%'' '||
                ' and f.app_short_name = '''||l_app||''''||
                ' order by subdir, f.last_update_date';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Latest Patched Forms from Application: '||l_app);

      sqltxt := ' select f.filename Name, subdir Directory, version'||
                ' from ad_file_versions v, ad_files f'||
                ' where v.file_id=f.file_id'||
                ' and file_version_id='||
                '  (select max(fv.file_version_id)'||
                '  from ad_file_versions fv'||
                '  where fv.file_id=v.file_id) '||
                ' and subdir = ''resource'' '||
                ' and f.app_short_name = '''||l_app||''''||
                ' order by subdir, f.last_update_date';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Latest Patched Libraries from Application: '||l_app);

      sqltxt := ' select f.filename Name, subdir Directory, version'||
                ' from ad_file_versions v, ad_files f'||
                ' where v.file_id=f.file_id'||
                ' and file_version_id='||
                '  (select max(fv.file_version_id)'||
                '  from ad_file_versions fv'||
                '  where fv.file_id=v.file_id) '||
                ' and subdir like ''java%'' '||
                ' and f.app_short_name = '''||l_app||''''||
                ' order by subdir, f.last_update_date';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Latest Patched Java Classes from Application: '||l_app);

      sqltxt := ' select f.filename Name, subdir Directory, version'||
                ' from ad_file_versions v, ad_files f'||
                ' where v.file_id=f.file_id'||
                ' and file_version_id='||
                '  (select max(fv.file_version_id)'||
                '  from ad_file_versions fv'||
                '  where fv.file_id=v.file_id) '||
                ' and subdir = ''patch/115/odf'' '||
                ' and f.app_short_name = '''||l_app||''''||
                ' order by subdir, f.last_update_date';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Latest Patched odf files from Application: '||l_app);

      sqltxt := ' select f.filename Name, subdir Directory, version'||
                ' from ad_file_versions v, ad_files f'||
                ' where v.file_id=f.file_id'||
                ' and file_version_id='||
                '  (select max(fv.file_version_id)'||
                '  from ad_file_versions fv'||
                '  where fv.file_id=v.file_id) '||
                ' and subdir like ''reports%'' '||
                ' and f.app_short_name = '''||l_app||''''||
                ' order by subdir, f.last_update_date';
      dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Latest Patched Reports from Application: '||l_app);
   end if;

elsif l_script = 'lock' then
   sqltxt :='select a.*,b.module,p.spid from (select s.sid,to_char(s.logon_time,''DD-MON-YY HH:MI:SS'') logon_time, s.serial#,'||
            '       decode(s.process, null,'||
            '          decode(substr(p.username,1,1), ''?'',   upper(s.osuser), p.username),'||
            '          decode(       p.username, ''ORACUSR '', upper(s.osuser), s.process)'||
            '       ) process,'||
            '       nvl(s.username, ''SYS (''||substr(p.username,1,4)||'')'') username,'||
            '       decode(l.type,'||
            '              ''TM'', ''DML/DATA ENQ'',   ''TX'', ''TRANSAC ENQ'','||
            '              ''UL'', ''PLS USR LOCK'','||
            '              ''BL'', ''BUF HASH TBL'',  ''CF'', ''CONTROL FILE'','||
            '              ''CI'', ''CROSS INST F'',  ''DF'', ''DATA FILE   '','||
            '              ''CU'', ''CURSOR BIND '','||
            '              ''DL'', ''DIRECT LOAD '',  ''DM'', ''MOUNT/STRTUP'','||
            '              ''DR'', ''RECO LOCK   '',  ''DX'', ''DISTRIB TRAN'','||
            '              ''FS'', ''FILE SET    '',  ''IN'', ''INSTANCE NUM'','||
            '              ''FI'', ''SGA OPN FILE'','||
            '              ''IR'', ''INSTCE RECVR'',  ''IS'', ''GET STATE   '','||
            '              ''IV'', ''LIBCACHE INV'',  ''KK'', ''LOG SW KICK '','||
            '              ''LS'', ''LOG SWITCH  '','||
            '              ''MM'', ''MOUNT DEF   '',  ''MR'', ''MEDIA RECVRY'','||
            '              ''PF'', ''PWFILE ENQ  '',  ''PR'', ''PROCESS STRT'','||
            '              ''RT'', ''REDO THREAD '',  ''SC'', ''SCN ENQ     '','||
            '              ''RW'', ''ROW WAIT    '','||
            '              ''SM'', ''SMON LOCK   '',  ''SN'', ''SEQNO INSTCE'','||
            '              ''SQ'', ''SEQNO ENQ   '',  ''ST'', ''SPACE TRANSC'','||
            '              ''SV'', ''SEQNO VALUE '',  ''TA'', ''GENERIC ENQ '','||
            '              ''TD'', ''DLL ENQ     '',  ''TE'', ''EXTEND SEG  '','||
            '              ''TS'', ''TEMP SEGMENT'',  ''TT'', ''TEMP TABLE  '','||
            '              ''UN'', ''USER NAME   '',  ''WL'', ''WRITE REDO  '','||
            '              ''TYPE=''||l.type) type,'||
            '       decode(l.lmode, 0, ''NONE'', 1, ''NULL'', 2, ''RS'', 3, ''RX'','||
            '               4, ''S'',    5, ''RSX'',  6, ''X'','||
            '               to_char(l.lmode) ) lmode,'||
            '       decode(l.request, 0, ''NONE'', 1, ''NULL'', 2, ''RS'', 3, ''RX'','||
            '               4, ''S'', 5, ''RSX'', 6, ''X'','||
            '               to_char(l.request) ) lrequest,'||
            '       decode(l.type, ''MR'', decode(u.name, null,'||
            '              ''DICTIONARY OBJECT'', u.name||''.''||o.name),'||
            '              ''TD'', u.name||''.''||o.name,'||
            '              ''TM'', u.name||''.''||o.name,'||
            '              ''RW'', ''FILE#=''||substr(l.id1,1,3)||'||
            '              '' BLOCK#=''||substr(l.id1,4,5)||'' ROW=''||l.id2,'||
            '              ''TX'', ''RS+SLOT#''||l.id1||'' WRP#''||l.id2,'||
            '              ''WL'', ''REDO LOG FILE#=''||l.id1,'||
            '              ''RT'', ''THREAD=''||l.id1,'||
            '              ''TS'', decode(l.id2, 0, ''ENQUEUE'','||
            '                                     ''NEW BLOCK ALLOCATION''),'||
            '              ''ID1=''||l.id1||'' ID2=''||l.id2) object'||
            ' from   sys.v_$lock l, sys.v_$session s, sys.obj$ o, sys.user$ u,'||
            '       sys.v_$process p'||
            ' where  s.paddr  = p.addr(+)'||
            '  and  l.sid    = s.sid'||
            '  and  l.id1    = o.obj#(+)'||
            '  and  o.owner# = u.user#(+)'||
            '  and  l.type   <> ''MR'''||
            ' UNION ALL                         '||
            ' select s.sid,to_char(s.logon_time,''DD-MON-YY HH:MI:SS'') logon_time, s.serial#, s.process, s.username, '||
            '       ''LATCH'', ''X'', ''NONE'', h.name||'' ADDR=''||rawtohex(laddr)'||
            ' from   sys.v_$process p, sys.v_$session s, sys.v_$latchholder h'||
            ' where  h.pid  = p.pid'||
            '  and  p.addr = s.paddr'||
            ' UNION ALL'||
            ' select s.sid,to_char(s.logon_time,''DD-MON-YY HH:MI:SS'') logon_time, s.serial#, s.process, '||
            ' s.username, ''LATCH'', ''NONE'', ''X'', name||'' LATCH=''||p.latchwait'||
            ' from   sys.v_$session s, sys.v_$process p, sys.v_$latch l'||
            ' where  latchwait is not null'||
            '  and  p.addr      = s.paddr'||
            '  and  p.latchwait = l.addr) a , v$session b,v$process p where'||
            ' a.sid=b.sid and a.object like ''%MTL%'' and b.paddr = p.addr(+)';

   sqltxt := 'select * from ('||sqltxt||') WHERE ROWNUM <= '||row_limit;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Display database locks and latches');

elsif l_script = 'patch' then
   sqltxt := 'select patch_name, patch_type , max(creation_date) "Applied Date" from ad_applied_patches ';
   if l_patch is not null then
      sqltxt := sqltxt||' where patch_name= '''||l_patch||'''';
   end if;
   sqltxt := sqltxt||' group by  patch_name, patch_type  order by max(creation_date) desc';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Display applied patch '||l_patch);

elsif l_script ='manager' then
   sqltxt :='SELECT  fa.application_name "Application Name"  '||
            '     , fa.application_short_name "Application|Shortname"  '||
            '     , fcp.concurrent_processor_name "Name"  '||
            '     , fcq.user_concurrent_queue_name "Manager"  '||
            '     , NVL( fcq.target_node,''n/a'') "Node"  '||
            '     , fcq.running_processes "Actual"  '||
            '     , fcq.max_processes "Target"  '||
            ' FROM fnd_concurrent_queues_vl fcq  '||
            '     , fnd_application_vl fa  '||
            '     , fnd_concurrent_processors fcp '||
            'WHERE fa.application_id = fcq.application_id  '||
            '  AND fcq.application_id = fcp.application_id  '||
            '  AND fcq.concurrent_processor_id = fcp.concurrent_processor_id  '||
            '  AND fa.application_short_name IN ( ''INV'' )  '||
            'ORDER BY fcp.application_id DESC  '||
            ', fcp.concurrent_processor_id  '||
            ', fcp.concurrent_processor_name';

   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Concurrent Managers related to Inventory');
   sqltxt :='SELECT PROCESS_TYPE "Manager"  '||
            '    , PROCESS_NAME "Internal|Name"  '||
            '    , WORKER_ROWS "Worker|Rows"  '||
            '    , TIMEOUT_HOURS || '':'' || TIMEOUT_MINUTES "Timeout|Hrs:Min"  '||
            '    , PROCESS_HOURS || '':'' || PROCESS_MINUTES || '':'' || PROCESS_SECONDS "Process Interval|Hrs:Min:Sec"  '||
            '    , MANAGER_PRIORITY "Manager|Priority"  '||
            '    , WORKER_PRIORITY "Worker|Priority"  '||
            '    , PROCESSING_TIMEOUT "Processing|Timeout"  '||
            '    , PROCESS_CODE'||
            '    , PROCESS_APP_SHORT_NAME'||
            ' FROM mtl_interface_proc_controls_v  '||
            'ORDER BY process_type ' ;
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt, 'Configuration of the INV Txn Manager');

   if l_conc_prg is not null then
       sqltxt :=' SELECT request_id "Request"  '||
                '      , fcp.concurrent_program_name "Concurrent Program"  '||
                '      , DECODE( phase_code, ''C'', ''Completed'',  '||
                '                            ''I'', ''Inactive'',  '||
                '                            ''P'', ''Pending'',  '||
                '                            ''R'', ''Running'',  '||
                '                phase_code ) "Phase"  '||
                '      , DECODE( status_code, ''A'', ''Waiting'', '||
                '                             ''B'', ''Resuming'', '||
                '                             ''C'', ''Normal'', '||
                '                             ''D'', ''Cancelled'', '||
                '                             ''E'', ''Error'', '||
                '                             ''G'', ''Warning'', '||
                '                             ''H'', ''On Hold'', '||
                '                             ''I'', '' Normal'', '||
                '                             ''M'', ''No Manager'', '||
                '                             ''P'', ''Scheduled'', '||
                '                             ''Q'', ''Standby'', '||
                '                             ''R'', ''  Normal'', '||
                '                             ''S'', ''Suspended'', '||
                '                             ''T'', ''Terminating'', '||
                '                             ''U'', ''Disabled'', '||
                '                             ''W'', ''Paused'', '||
                '                             ''X'', ''Terminated'', '||
                '                             ''Z'', ''Waiting'', '||
                '                status_code ) "Status"  '||
                '      , hold_flag "Hold"  '||
                '      , TO_CHAR( request_date, ''DD-MON-RR HH24:MI'' ) "Request Date"  '||
                '      , TO_CHAR( requested_start_date, ''DD-MON-RR HH24:MI'' ) "Requested Start|Date"  '||
                '      , resubmitted "Resubmitted"  '||
                '      , resubmit_interval "Resubmit|Interval"  '||
                '      , resubmit_interval_unit_code "Resubmit Interval|Unit Code"  '||
                '      , resubmit_time "Resubmit|Time"  '||
                '      , completion_text "Completion Text"  '||
                '   FROM fnd_concurrent_requests fcr, fnd_concurrent_programs fcp  '||
                '  WHERE fcp.concurrent_program_name = '''||l_conc_prg||''''||
                '    AND fcp.concurrent_program_id = fcr.concurrent_program_id  '||
                '    AND fcp.application_id = fcr.program_application_id  ';
       dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Concurrent request information');
   end if;

elsif l_script ='debug' then
   sqltxt :='SELECT b.user_profile_option_name "Long Name"  '||
            '    , a.profile_option_name "Short Name"  '||
            '    , DECODE( c.level_id, 10001, ''Site''  '||
            '                        , 10002, ''Application''  '||
            '                        , 10003, ''Responsibility''  '||
            '                        , 10004, ''User''  '||
            '                        , ''Unknown'') "Level"  '||
            '    , DECODE( c.level_id, 10001, ''Site''  '||
            '                        , 10002, NVL(h.application_short_name,  '||
            '                                     TO_CHAR( c.level_value))  '||
            '                        , 10003, NVL(g.responsibility_name,  '||
            '                                     TO_CHAR( c.level_value))  '||
            '                        , 10004, NVL(e.user_name,  '||
            '                                     TO_CHAR(c.level_value))  '||
            '                        , ''Unknown'') "Level Value"  '||
            '    , c.profile_option_value "Profile Value"  '||
            '    , TO_CHAR( c.last_update_date,''DD-MON-YYYY HH24:MI'')  '||
            '      "Updated Date"  '||
            '    , NVL(d.user_name, TO_CHAR( c.last_updated_by)) "Updated By"  '||
            ' FROM fnd_profile_options a  '||
            '    , fnd_profile_options_vl b  '||
            '    , fnd_profile_option_values c  '||
            '    , fnd_user d , fnd_user e  '||
            '    , fnd_responsibility_vl g  '||
            '    , fnd_application h  '||
            'WHERE a.profile_option_name = b.profile_option_name  '||
            '  AND a.profile_option_id = c.profile_option_id  '||
            '  AND a.application_id = c.application_id  '||
            '  AND c.last_updated_by = d.user_id (+)  '||
            '  AND c.level_value = e.user_id (+)  '||
            '  AND c.level_value = g.responsibility_id (+)  '||
            '  AND c.level_value = h.application_id (+)  '||
            '  AND a.profile_option_name IN (  '||
            '      ''AFLOG_ENABLED'' , ''AFLOG_FILENAME'' , ''AFLOG_LEVEL''  '||
            '    , ''AFLOG_MODULE''  '||
            '    , ''CONC_DEBUG'' , ''FND_AS_MSG_LEVEL_THRESHOLD''  '||
            '    , ''FLEXFIELDS:VALIDATE_ON_SERVER''  '||
            '    , ''FND_APPS_INIT_SQL'' , ''FND_INIT_SQL''  '||
            '    , ''INV_DEBUG_FILE'' , ''INV_DEBUG_LEVEL''  '||
            '    , ''INV_DEBUG_TRACE'' , ''MRP_DEBUG'' , ''MRP_TRACE''  '||
            '    , ''MWA_DEBUG_LEVEL'' , ''MWA_DEBUG_TRACE''  '||
            '    , ''OE_DEBUG_LEVEL'' , ''OE_DEBUG_LOG_DIRECTORY''  '||
            '    , ''OE_RPC_DEBUG_FLAGS'' , ''ONT_DEBUG_LEVEL''  '||
            '    , ''PO_RVCTP_ENABLE_TRACE''  '||
            '    , ''PO_SET_DEBUG_CONCURRENT_ON''  '||
            '    , ''PO_SET_DEBUG_WORKFLOW_ON'' , ''RCV_DEBUG_MODE''  '||
            '    , ''RCV_DEBUG_MODE'' , ''RCV_TP_MODE''  '||
            '    , ''SO_DEBUG'' , ''SO_DEBUG_TRACE''  '||
            '    , ''WIP_CONC_MESSAGE_LEVEL''  '||
            '    , ''WSH_DEBUG_LOG_DIRECTORY'' , ''WSH_DEBUG_MODE''  '||
            '        )  '||
            'ORDER BY b.user_profile_option_name, c.level_id';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'Debug- and Trace-related profileoptions');

   sqltxt :='SELECT name, value  '||
            'FROM v$parameter  '||
            'WHERE UPPER( name ) IN ( ''UTL_FILE_DIR'', ''USER_DUMP_DEST'', ''MAX_DUMP_FILE_SIZE'' )';
   dummy_num:= JTF_DIAGNOSTIC_COREAPI.display_sql(sqltxt,'DB parameters : UTL_FILE_DIR , USER_DUMP_DEST and MAX_DUMP_FILE_SIZE');
end if;
 -- construct report
 statusStr := 'SUCCESS';
 isFatal := 'FALSE';
 report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
 reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'D Information';
END getComponentName;

PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
descStr := 'Get Environment Information';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
name := 'Environment Information';
END getTestName;

PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL) IS
tempDependencies JTF_DIAG_DEPENDTBL;

BEGIN
    package_names := JTF_DIAGNOSTIC_ADAPTUTIL.initDependencyTable;
END getDependencies;

PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2) IS
BEGIN
  str := 'FALSE';
END isDependencyPipelined;


PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL) IS
  tempOutput JTF_DIAG_OUTPUTTBL;
BEGIN
  tempOutput := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
  outputValues := tempOutput;
EXCEPTION
 when others then
 outputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initOutputTable;
END getOutputValues;


PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'CheckName','LOV-oracle.apps.inv.diag.lov.EnvSetupLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ApplicationId','LOV-oracle.apps.inv.diag.lov.AppLov');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'Package','');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'FileName','');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PatchNum','');
tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ConcurrentProgram','');
defaultInputValues := tempInput;
EXCEPTION
when others then
defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

Function getTestMode return INTEGER IS
BEGIN
 return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;

END getTestMode;

END;

/
