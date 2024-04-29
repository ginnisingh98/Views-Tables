--------------------------------------------------------
--  DDL for Package Body FND_SYSTEM_ALERT_INTG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SYSTEM_ALERT_INTG_UTIL" AS
/* $Header: AFOAMSAINGB.pls 120.4 2005/09/28 13:47:03 ravmohan noship $ */

  /**
    *  This function will return sql for creating xml.
    *  param p_logSEQ  in - Log Sequence
    **/
  function GET_SQL(p_logSEQ in varchar2) return varchar2
  is
     retu varchar2(5000);
  begin
 retu := 'SELECT fpg.APPLICATIONS_SYSTEM_NAME, fpg.RELEASE_NAME'
   || '  , flue.severity, flue.status, fnd_date.DATE_TO_DISPLAYDT(flm.timestamp, ''GMT'') TIMESTAMP_GMT, flue.category, flue.english_message'
   || '  , flm.log_sequence,  flue.unique_exception_id'
   || '  , fltc.component_type, fltc.component_id, fac.component_name,  nvl(fac.display_name,''UNKNOWN'') COMP_DISPLAY_NAME, fac.description COMP_DESCRIPTION'
   || '  , fltc.component_appl_id, fa.application_short_name COMPONENT_APPL_SHORT_NAME, fat.application_name COMPONENT_APPL_NAME, flm.module'
   || '  , fltc.user_id, fu.user_name,  fltc.responsibility_id, fr.responsibility_key, frt.responsibility_name'
   || '  , fltc.resp_appl_id, fra.application_short_name RESP_APPL_SHORT_NAME, frat.application_name RESP_APPL_NAME'
   || '  , flm.audsid, gvi.instance_name, flm.db_instance,  fle.session_module, fle.session_action'
   || '  , fltc.session_id, flm.node, flm.node_ip_address, fltc.security_group_id, fsg.security_group_key, fsgt.security_group_name'
   || '  , flm.process_id, flm.thread_id, flm.jvm_id'
   || '  , fltc.transaction_context_id, fltc.transaction_type, fltc.transaction_id'
   || '  FROM'
   || '    fnd_log_transaction_context fltc,  fnd_log_messages flm,  fnd_log_attachments flattach'
   || '  , fnd_log_exceptions fle,  fnd_log_unique_exceptions flue,  fnd_user fu,  fnd_app_components_vl fac'
   || '  , fnd_application fa,  fnd_application_tl fat,  fnd_responsibility fr,  fnd_responsibility_tl frt'
   || '  , fnd_application fra,  fnd_application_tl frat,  fnd_security_groups fsg,  fnd_security_groups_tl fsgt'
   || '  , gv$instance gvi,  fnd_product_groups fpg'
   || '  WHERE  '
   || '     fltc.transaction_context_id = flm.transaction_context_id  and flm.log_sequence = fle.log_sequence'
   || '  and  fle.unique_exception_id = flue.unique_exception_id  and	flm.user_id = fu.user_id (+)  '
   || '  and  fltc.component_type = fac.component_type (+)  and 	fltc.component_appl_id = fac.application_id (+)'
   || '  and  fltc.component_id = fac.component_id (+)  and 	fltc.component_appl_id = fa.application_id (+)'
   || '  and  fltc.responsibility_id = fr.responsibility_id (+)  and	fltc.resp_appl_id = fra.application_id (+)'
   || '  and  fltc.security_group_id = fsg.security_group_id (+)  and flm.db_instance = gvi.instance_number (+)'
   || '  and  flm.log_sequence = flattach.log_sequence (+)  and fa.application_id = fat.application_id (+)'
   || '  and  fat.language (+) = userenv(''LANG'')  and fr.responsibility_id = frt.responsibility_id (+)'
   || '  and  frt.language (+) = userenv(''LANG'')  and fra.application_id = frat.application_id (+)'
   || '  and  frat.language (+) = userenv(''LANG'')  and fsg.security_group_id = fsgt.security_group_id (+)'
   || '  and  fsgt.language (+) = userenv(''LANG'')  AND flm.log_sequence = ' || p_logSEQ;
--   || '  and  fpg.ROW_NUM=1';


   return retu;
  end GET_SQL;


  /**
    * This is the generate function used for business event
    *
    *  This function will return the System alert exception in XML format.
    *  param p_event_name in - Workflow Business Event Name
    *  param p_event_key  in - Workflow Business Event Key
    *  param wf_parameter_list_t  in - Event parameter List
    *  param  errbuf out type - If any error occurs it will have error message
    *             else null
    **/
  function GET_EXCPETION_DETAILS(p_event_name in varchar2
           , p_event_key in varchar2
           , p_parameter_list in wf_parameter_list_t default null) return clob
  is
      queryCtx DBMS_XMLquery.ctxType;
      result CLOB;
      lSQL VARCHAR2(5000);
  begin
     -- set up the query context...!
     lSQL := GET_SQL(p_event_key);
     queryCtx := DBMS_XMLQuery.newContext(lSQL);
     DBMS_XMLQuery.setRowTag(queryCtx,'OCCURANCE'); -- sets the row tag name
     DBMS_XMLQuery.setRowSetTag(queryCtx,'ALERT'); -- sets rowset tag name

     -- get the result..!
     result := DBMS_XMLQuery.getXML(queryCtx);
     DBMS_XMLQuery.closeContext(queryCtx);  -- you must close the query handle..

     return result;
  end GET_EXCPETION_DETAILS;






  /**
   * Debug methods
   **/
  procedure fdebug(msg in varchar2)
  IS
  l_msg 		VARCHAR2(1000);
  BEGIN
     --l_msg := dbms_utility.get_time || '   ' || msg;
     ---dbms_output.put_line(dbms_utility.get_time || ' ' || msg);
     ---fnd_file.put_line( fnd_file.log, dbms_utility.get_time || ' ' || msg);
     l_msg := 'm';
  END fdebug;

  procedure printClobOut(result IN OUT NOCOPY CLOB) is
     config_file UTL_FILE.FILE_TYPE;
     xmlstr varchar2(32767);
     line varchar2(2000);
  begin
       config_file := UTL_FILE.FOPEN ('/slot03/oracle/oam12devdb/9.2.0/appsutil/outbound/oam12dev', 'sqlQ.txt', 'W');
       xmlstr := dbms_lob.SUBSTR(result,32767);
       loop
          exit when xmlstr is null;
          --line := substr(xmlstr,1,instr(xmlstr,chr(10))-1);
          --dbms_output.put_line('| '||line);
          UTL_FILE.PUT_LINE(config_file, line);
          --xmlstr := substr(xmlstr,instr(xmlstr,chr(10))+1);
        end loop;
       UTL_FILE.fclose(config_file);
  end;

  procedure writeString(msg in varchar2) is
     config_file UTL_FILE.FILE_TYPE;
     startIndex number;
     lineLength number;
     line varchar2(255);
   begin
       config_file := UTL_FILE.FOPEN ('/slot03/oracle/oam12devdb/9.2.0/appsutil/outbound/oam12dev', 'sqlQ.txt', 'W');
       startIndex :=1;
       lineLength := 255;
       line := substr(msg, startIndex, lineLength);

       loop
          exit when line is null;
          ---dbms_output.put_line(line);
          UTL_FILE.PUT_LINE(config_file, line);
          startIndex := startIndex  + lineLength;
          line := substr(msg, startIndex, lineLength);
        end loop;

       UTL_FILE.fclose(config_file);
  end;


  /**
    * For Testing all API's
    * After testing it will put the Apps mode in the original state.
    **/
  procedure TEST
  is
    result CLOB;
  begin
    fdebug('Testing: GET_EXCPETION_DETAILS');
     writeString(GET_SQL('499635'));
     result := GET_EXCPETION_DETAILS('test', '586182');
     -- Now you can use the result to put it in tables/send as messages..
     -- Comment out lines in printclob
     printClobOut(result);
  end;



 END FND_SYSTEM_ALERT_INTG_UTIL;

/
