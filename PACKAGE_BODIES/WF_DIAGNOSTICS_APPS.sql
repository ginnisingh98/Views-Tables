--------------------------------------------------------
--  DDL for Package Body WF_DIAGNOSTICS_APPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DIAGNOSTICS_APPS" as
/* $Header: WFDGAPPB.pls 120.3.12010000.4 2010/04/09 08:56:12 sstomar ship $ */

-- Header
g_head varchar2(50) := '<html><body>';
g_end  varchar2(50) := '</body></html>';

-- variable to store previous trace level as can be used procedure TRACE_UTIL
g_prev_trace_level number := -1;

-- Queue owner
g_qowner varchar2(30) := Wf_Core.Translate('WF_SCHEMA');

-- No WF Service instance Excpetion
No_Service_Instance EXCEPTION;
PRAGMA EXCEPTION_INIT(No_Service_Instance, -20100);


--
-- Get_GSM_Setup_Info - <Explained in WFDGAPPS.pls>
--
function Get_GSM_Setup_Info(p_value out nocopy clob)
                                             return varchar2 is

    l_service_instances fnd_concurrent.service_instance_tab_type;
    l_gsm_enabled VARCHAR2(10);
    l_service_enabed VARCHAR2(20);
    l_user_concurrent_queue_name VARCHAR2(300);
    l_temp_result varchar2(32000);
    l_value clob;
    l_app_id NUMBER;
    l_managerid NUMBER;
    l_activep NUMBER;
    l_targetp NUMBER;
    l_pmon_method VARCHAR2(80);
    l_callstat NUMBER;
    l_status VARCHAR2(1);
    l_srv_instance varchar2(30);

    l_temp_value  varchar2(1024);

    -- cusrsor to get env. variables
    cursor cr_env (p_qname in varchar2, p_appId in NUMBER ) IS
	select VARIABLE_NAME, VALUE
	from FND_ENV_CONTEXT
	where CONCURRENT_PROCESS_ID in
	      (select  max(CONCURRENT_PROCESS_ID)
	       from FND_CONCURRENT_PROCESSES fcp , FND_CONCURRENT_QUEUES fcq
	       where fcp.CONCURRENT_QUEUE_ID = fcq.CONCURRENT_QUEUE_ID
	       and   fcq.CONCURRENT_QUEUE_NAME= p_qname
	       and   fcp.QUEUE_APPLICATION_ID  = p_appId  )
        and VARIABLE_NAME in ('APPL_TOP', 'APPLCSF', 'APPLLOG', 'FND_TOP',
			      'AF_CLASSPATH', 'AFJVAPRG', 'AFJRETOP', 'CLASSPATH',
			      'PATH', 'LD_LIBRARY_PATH', 'ORACLE_HOME', 'NLS_LANG',
	                      'AF_LD_LIBRARY_PATH')
       order by VARIABLE_NAME;
begin

    l_status := 'S';

    dbms_lob.CreateTemporary(l_value, TRUE, dbms_lob.Session);
    -- Set up Header
    l_temp_result := g_head;
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    -- If GSM is enabled in ICM
    select decode(fnd_profile.value('CONC_GSM_ENABLED'), 'Y', 'ENABLED', 'NOT ENABLED')
    into   l_gsm_enabled from dual;

    l_temp_result := '<br><table>' || '<tr><td class="OraHeaderSub" >GSM is ' || l_gsm_enabled ||
                     '</td></tr>' || '</table>';

    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    if (l_gsm_enabled = 'NOT ENABLED') then
      l_status := 'E';
    end if;

    -- Check if ICM is running.
    FND_CONCURRENT.GET_MANAGER_STATUS (
			    applid      => 0,
			    managerid   => 1,
			    targetp     => l_targetp,
			    activep     => l_activep,
			    pmon_method => l_pmon_method,
			    callstat    => l_callstat);

    l_temp_result := ' <br> <table>' ;

    IF l_callstat <> 0 THEN
      l_temp_result := l_temp_result || '<tr><td class="OraHeaderSub" >Could not verify if ICM is running => '
                      || l_callstat ||  ', Please check $AF_CLASSPATH, $ AF_LD_LIBRARY_PATH '
		      || ' and $PATH etc. on Concurrent Node </td></tr>' || '</table>';
      l_status := 'E';
    ELSE
      IF l_activep > 0 THEN
        l_temp_result := l_temp_result || '<tr><td class="OraHeaderSub" > ICM is running '
                         ||  '</td></tr>' || '</table>';
      ELSE
        l_temp_result := l_temp_result || '<tr><td class="OraHeaderSub" >ICM is down -> Actual: '
                         || l_activep || ', Target: ' || l_targetp
                         || l_callstat ||  '</td></tr>' || '</table>';
        l_status := 'E';
      END IF;
    END IF;

    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    -- If the Service Instance are enabled
    l_temp_result :=  ' <br> <table width="100%">';
    l_temp_result :=  l_temp_result|| '<tr><td colspan="3" class="OraHeaderSub" >Workflow GSC Services status:</td></tr>';

    l_temp_result := l_temp_result||'<tr><td width="50%" class="OraTableHeaderLink">  Service Type </td>';
    l_temp_result := l_temp_result||'<td width="20%" class="OraTableHeaderLink">  Enable Status </td>';
    l_temp_result := l_temp_result||'<td width="30%" class="OraTableHeaderLink"> Running Status  </td> </tr>';

    begin
      -- FND_CP_SERVICES  and FND_CONCURRENT_QUEUES tables
      l_service_instances := fnd_concurrent.get_service_instances (svc_handle => 'FNDCPGSC');
    exception
       -- Handle -20100 error
       When No_Service_Instance then
       --  WHEN OTHERS THEN
      l_temp_result := l_temp_result || ' <tr><td colspan="3" class="OraTableCellText" > ' ||
                       ' No Workflow Service Instances Found under '||
                       ' FNDCPGSC Service Handle  </td></tr>';

    end;

    -- Check Each Service instance's data
    IF (l_Service_Instances.COUNT > 0) THEN


       FOR i IN 1..l_Service_Instances.COUNT LOOP

	 -- show env. vars for Mailer Service only,
	 if( l_service_instances(i).instance_name = 'WFMLRSVC' ) THEN
           l_srv_instance := l_service_instances(i).instance_name;
	 END if;

	 -- If Mailer Service instance name did not find, take any of them.
	 if(l_srv_instance IS null) then
             l_srv_instance := l_service_instances(i).instance_name;
	 END if;


         IF (l_Service_Instances.EXISTS(i)) THEN

	     -- Get application_id
             SELECT application_id INTO l_app_id
             FROM fnd_application
             WHERE application_short_name = l_service_instances(i).application;

             -- If we are here it means that seed data is present in DB
             begin

		-- Get concurrent queue name
	        SELECT  user_concurrent_queue_name,
			concurrent_queue_id,
			decode(enabled_flag, 'Y', 'ENABLED', 'NOT ENABLED')
		INTO    l_user_concurrent_queue_name, l_managerid, l_service_enabed
		FROM    fnd_concurrent_queues_vl
		WHERE   concurrent_queue_name = l_service_instances(i).instance_name;

		-- Check if the service is enabled and running,
               l_temp_result := l_temp_result || '<tr><td class="OraTableCellText"> ' ||
                                l_user_concurrent_queue_name || '</td>';
               l_temp_result := l_temp_result || '<td class="OraTableCellText"> ' ||l_service_enabed || '</td>';

		-- Get each Workflow Service Container status.
		-- MANAGER_TYPE=1052 and CartType is 'AQCART'
		-- Other errors are being handled within GET_MANAGER_STATUS API itself
	        FND_CONCURRENT.GET_MANAGER_STATUS (
                  applid => l_app_id,
                  managerid => l_managerid,
                  targetp => l_targetp,
                  activep     => l_activep,
                  pmon_method => l_pmon_method,
                  callstat    => l_callstat);

		-- l_callstat <>0 mean there is no process exist in
		-- fnd_concurrent_processes and gv$session
                IF l_callstat <> 0 THEN
                  l_temp_result := l_temp_result || '<td class="OraTableCellText"> could not get ' ||
						   ' actual and target process count </td></tr>';

                  l_status := 'E';
                ELSE
  	              l_temp_result := l_temp_result || '<td class="OraTableCellText"> ' || 'Actual: ' ||
                                       l_activep || ', Target: ' || l_targetp || '</td></tr>';

                END IF;

             EXCEPTION
               -- Handle fetch on fnd_concurrent_queues_vl
	       when no_data_found then
                  l_temp_result := l_temp_result || '<tr><td colspan="3" class="OraTableCellText"> ' ||
		                                    'Could not find concurrent queue for '||
		                                   l_service_instances(i).instance_name ||
						   ' Service Instance. </td></tr>';
	     end;

	 end if; -- Service Instances EXIST

       END LOOP; -- Loop for each service instance



    else -- count LT 0
      l_temp_result := l_temp_result || '<tr><td colspan="3"  class="OraTableCellText" >No Service Found under '||
                             'FNDCPGSC Service Handle</td></tr>';
      l_status := 'E';

    END IF; -- count GT 0

    l_temp_result := l_temp_result ||'</table><br>';
    dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    -- Show the classpath etc. based on if it has ever started before
    -- TODO : Whether these VARS should be displayd for each Service Instance or only
    --        Once.
    if(l_srv_instance IS not NULL) THEN

       l_temp_result :=  '<br> <table width="100%"><tr> '||
                         ' <td width="10%" colspan=2 class="OraHeaderSub"> ' ||
                         ' Concurrent Tier Environment Variables being used ' ||
			 ' by Workflow Services </td></tr>';


       for l_prec IN cr_env (l_srv_instance, l_app_id) LOOP

          l_temp_result := l_temp_result || '<tr><td class="OraTableColumnHeader"> ' ||
	                                   l_prec.variable_name ||
					   '  </td> ';
          l_temp_value  := l_prec.value;

	  -- Non-Windows OS: Break path's value so that they will apear properly
	  if( instr(l_temp_value ,':') > 0 ) THEN
             l_temp_value  := replace(l_temp_value, ':', ': ');
          else
             l_temp_value  := replace(l_temp_value, ';', '; ');
	  END if;

          l_temp_result := l_temp_result || '<td class="OraTableCellText"> ' ||
	                                   l_temp_value ||
			                   ' </td> </tr>';
      end loop;

      l_temp_result := l_temp_result ||'</table><br>';
      dbms_lob.WriteAppend(l_value, length(l_temp_result), l_temp_result);

    end if; -- Env .variables

    -- Send the final HTML Output to the caller
    dbms_lob.WriteAppend(l_value, length(g_end), g_end);
    p_value := l_value;

    return l_status;
end Get_GSM_Setup_Info;

--
-- EcxTest - <Explained in WFDGAPPS.pls>
--
procedure EcxTest(
	outbound_ret_code out nocopy varchar2,
	outbound_errbuf   out nocopy varchar2,
	outbound_xmlfile  out nocopy varchar2,
	outbound_logfile  out nocopy varchar2,
	inbound_ret_code  out nocopy varchar2,
	inbound_errbuf    out nocopy varchar2,
	inbound_logfile   out nocopy varchar2)
is
p_xmldoc	CLOB;
p_ret_code	pls_integer;
p_errbuf	varchar2(2000);
p_logfile	varchar2(2000);
i_tmp			clob;
i_temp			clob;
i_buffer		varchar2(32767);
i_ret_code		pls_integer;
i_errbuf		varchar2(2000);
i_logfile		varchar2(2000);
sid 			number;
file			utl_file.file_type;
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

--i_file_name		varchar2(2000);
begin
fnd_profile.get('AFLOG_ENABLED',logging_enabled);
fnd_profile.get('AFLOG_MODULE',module);
if(logging_enabled = 'Y'
AND instrb(module,'ecx') > 0
AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
	ecx_logging_enabled := true;
end if;

	dbms_lob.createtemporary(p_xmldoc,true,dbms_lob.session);
	ecx_outbound.GETXML(
		i_map_code 	=> 'TestingDirectOut',
		i_debug_level	=> 3,
		i_xmldoc 	=> p_xmldoc,
		i_ret_code 	=> p_ret_code,
		i_errbuf 	=> p_errbuf,
		i_log_file	=> p_logfile
	);

--	i_file_name := 'OUT.'||ecx_utils.g_run_id||'.xml';
	outbound_ret_code := p_ret_code;
	outbound_errbuf := p_errbuf;
--	outbound_logfile := p_logfile;
	IF (ecx_logging_enabled) THEN
		outbound_xmlfile := 'FND-Logging AFLOG MODULE Name for XML File :'
		    ||ecx_debug.g_sqlprefix||'out.'||ecx_utils.g_run_id||'.xml';
		outbound_logfile := 'FND-Logging AFLOG MODULE Name for Log File :'
                    ||ecx_debug.g_sqlprefix||'out.'||ecx_utils.g_run_id||'.log';
	ElSE
		outbound_xmlfile := 'Please ensure that FND-Logging is enabled for module '
                    ||ecx_debug.g_sqlprefix||'%';
		outbound_logfile := 'Please ensure that FND-Logging is enabled for module '
                    ||ecx_debug.g_sqlprefix||'%';
	END IF;

--	dbms_lob.freetemporary(p_xmldoc);

	dbms_lob.createtemporary(i_tmp,true,dbms_lob.session);
  /*      file := utl_file.fopen(ecx_utils.g_logdir,i_file_name, 'r');
     	loop
        	begin
          		utl_file.get_line(file, i_buffer);
          		dbms_lob.writeappend(i_tmp,lengthb(i_buffer),i_buffer);
        	exception
          	when no_data_found then
            		exit;
          	when others then
--            		dbms_output.put_line(i_buffer);
            		exit;
        	end;
     	end loop;
*/
	ecx_inbound_trig.processXML
		(
		'TestingDirectIn',
		p_xmldoc,
		3,
		i_ret_code,
		i_errbuf,
		i_logfile,
		i_temp
		);

	dbms_lob.freetemporary(i_tmp);

	inbound_ret_code := i_ret_code;
	inbound_errbuf := i_errbuf;
--	inbound_logfile := i_logfile;
	IF (ecx_logging_enabled) THEN
		inbound_logfile := 'FND-Logging AFLOG MODULE Name for Log File :'
                    ||ecx_debug.g_sqlprefix||'in.'||ecx_utils.g_run_id||'.log';
	ElSE
		inbound_logfile := 'Please ensure that FND-Logging is enabled for module '
                    ||ecx_debug.g_sqlprefix||'%';
	END IF;
exception
  when others then
    dbms_lob.freetemporary(p_xmldoc);
    dbms_lob.freetemporary(i_tmp);

    outbound_ret_code := p_ret_code;
    outbound_errbuf := p_errbuf;
    outbound_logfile := p_logfile;

    inbound_ret_code := i_ret_code;
    inbound_errbuf := i_errbuf;
    inbound_logfile := i_logfile;
end ECXTEST;


--
-- TRACE_UTIL
--  Bug: 6964389
--   Enables/disables the SQL Trace at the specified level based
--   on the value of current Trace level of a component.
--   Constructs the TRACE FILE IDENTIFIER value as combination of
--   component id and time stamp.
--   Returns Trace file name, audsid and timestamp values
-- IN:
--   p_current_TraceLevel  -  Current Trace level value
--   p_comp_id              -  Component id
--
-- OUT:
--   p_trace_filename      -  The Trace file name
--   p_audsid              -  The audsid value
--   p_timestamp           -  The current timestamp
--
procedure TRACE_UTIL
         (p_current_TraceLevel in number,
	  p_comp_id in number,
	  p_trace_filename out nocopy  varchar2,
	  p_audsid out nocopy integer,
	  p_timestamp out nocopy varchar2
	 )
is

   l_trace_id varchar2(100);
   l_date date;
   l_date_str varchar2(20);
   l_trace_enabled boolean;


begin
   select sysdate into l_date from dual;

   if (p_current_TraceLevel = -1)then
      FND_TRACE.STOP_TRACE(g_prev_trace_level);
   else
      l_trace_id := 'WFAL_'||p_comp_id||'_'||to_char(l_date,'YYYYMMDDHH24MISS');
      FND_TRACE.SET_TRACE_IDENTIFIER(l_trace_id);
      FND_TRACE.START_TRACE(p_current_TraceLevel);
   end if;

   -- Store the current trace level in variable 'g_prev_trace_level',
   -- so that it can be used as the previous level in the next call
   g_prev_trace_level := p_current_TraceLevel;

   p_trace_filename := FND_TRACE.GET_TRACE_FILENAME();

   p_timestamp := to_char(l_date,'YYYYMMDDHH24MISS');
   p_audsid := sys_context('userenv','sessionid');


end TRACE_UTIL;


end WF_DIAGNOSTICS_APPS;

/
