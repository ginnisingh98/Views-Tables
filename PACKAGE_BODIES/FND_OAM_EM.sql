--------------------------------------------------------
--  DDL for Package Body FND_OAM_EM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_EM" AS
/* $Header: AFOAMEMB.pls 120.1.12000000.4 2007/04/25 22:04:43 ssuprasa ship $ */


  /* DONE FOR LEVEL 1 */
  FUNCTION get_native_svcs return oam_em_srvcs_table_type IS
    results oam_em_srvcs_table_type := oam_em_srvcs_table_type();
    tmp_sts_code NUMBER :=0;
    tmp_svc_message VARCHAR2(1024);
  	i NUMBER;

    tmp_status INTEGER:=0;
    tmp_target_procs INTEGER:=0;
    tmp_actual_procs INTEGER:=0;

    CURSOR l_srvc_arr_pair_csr IS
      select q.user_concurrent_queue_name srvc_name,
        q.concurrent_queue_id conc_queue_id,
        a.application_id appl_id,
        a.application_name srvc_app_name,
        a.application_short_name srvc_app_short_name,
        q.concurrent_queue_name srvc_short_name,
	s.service_handle srvc_handle
      from fnd_concurrent_queues_vl q, fnd_application_vl a,
	   fnd_cp_services s
      where q.application_id = a.application_id
	and s.service_id = q.manager_type;

  BEGIN

    i:=1;

    FOR service_arr_pair IN l_srvc_arr_pair_csr LOOP
       results.extend(1);

       results(i) := oam_em_srvcs_type('','','','',0,0,0,'','');

       results(i).name := service_arr_pair.srvc_name;
       results(i).srvc_short_name := service_arr_pair.srvc_short_name;
       results(i).srvc_handle := service_arr_pair.srvc_handle;

       results(i).srvc_app_name := service_arr_pair.srvc_app_name;
       results(i).srvc_app_short_name := service_arr_pair.srvc_app_short_name;
       tmp_svc_message :='';
       FND_OAM.get_svc_inst_status
         (service_arr_pair.appl_id,
          service_arr_pair.conc_queue_id,
          tmp_target_procs,
          tmp_actual_procs,
          tmp_status,
          results(i).message,
          tmp_sts_code,
          tmp_svc_message);

       results(i).tgt_procs:=tmp_target_procs;
       results(i).act_procs:=tmp_actual_procs;


       IF  tmp_status = 2 THEN
          results(i).status:= 'DOWN';
       ELSIF tmp_status = 0 THEN
          results(i).status:= 'UP';
       ELSIF tmp_status = 1 THEN
          results(i).status := 'WARNING';
       ELSIF tmp_status = 3 THEN
          results(i).status := 'NOT_STARTED';
       ELSE
          results(i).status := 'NA';
       END IF;
       i := i+1;

    END LOOP;
    i:=i-1;
    return results;
  END get_native_svcs;




  /* DONE FOR LEVEL 1*/
  FUNCTION get_wf_agent_activity return oam_cursor_type IS
    ret oam_cursor_type;

    ready INTEGER:=0;
    waiting INTEGER:=0;
    processed INTEGER:=0;
    expired INTEGER:=0;
    undeliverable INTEGER:=0;
    errored INTEGER:=0;

  BEGIN

    wf_queue.getcntmsgst('%',ready,waiting,processed,expired,undeliverable,errored);

    OPEN ret FOR
      SELECT  to_char(ready),
              to_char(waiting),
              to_char(processed),
              to_char(expired),
              to_char(undeliverable),
              to_char(errored)
        FROM  dual;
    return ret;

  END get_wf_agent_activity;




  /* DONE FOR LEVEL 1*/
  FUNCTION get_apps_sys_status return oam_cursor_type IS
    ret oam_cursor_type;
  BEGIN
    fnd_oam_collection.refresh_app_sys_status;

    OPEN ret FOR
      SELECT  foa.metric_short_name,
              decode(fcq.user_concurrent_queue_name,NULL,'N/A',fcq.user_concurrent_queue_name),
              decode(fcq.description,NULL,'N/A',fcq.description),
              decode(foa.name,NULL,'N/A',foa.name),
              to_char(foa.status_code),
              decode(foa.node_name,NULL,'N/A',foa.node_name),
              decode(fl.meaning,NULL,'N/A',fl.meaning) platform,
              to_char(foa.last_update_date,'yyyy/MM/dd HH:mm:ss') last_update_date,
              decode(foa.type,NULL,'N/A',foa.type),
              decode(fcq.manager_type,NULL,'N/A',fcq.manager_type)

        FROM  fnd_oam_app_sys_status foa,
              fnd_concurrent_queues_vl fcq,
              FND_OAM_FNDNODES_VL fn,
              fnd_lookups fl
       WHERE  foa.application_id = fcq.application_id (+)
         AND  foa.concurrent_queue_name = fcq.concurrent_queue_name (+)
         AND  upper(foa.node_name) = upper(fn.node_name (+))
         AND  nvl(fn.platform_code, '-x') = fl.lookup_code(+)
         AND  fl.lookup_type(+) = 'PLATFORM';

    return ret;
  END get_apps_sys_status;




  /* DONE FOR LEVEL 1*/
  FUNCTION get_conf_changed return oam_cursor_type IS
    ret oam_cursor_type;
    PATCHES VARCHAR2(256);
    PROFILE_OPT  VARCHAR2(256);
    CONTEXT_FILES_EDITED VARCHAR2(256);
    INVALID_OBJECTS VARCHAR2(256);
    LAST_UPDATE_DATE VARCHAR2(256);
  BEGIN

    FOR pairs IN
    (
       SELECT   fom.METRIC_SHORT_NAME metric_name,
                fom.METRIC_VALUE value,
                to_char(fom.LAST_UPDATE_DATE,'yyyy/MM/dd HH:mm:ss') last_update
          FROM  fnd_oam_metval fom
         WHERE  fom.METRIC_SHORT_NAME in
                ('PATCHES','PROFILE_OPT','CONTEXT_FILES_EDITED','INVALID_OBJECTS')
    )
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      LAST_UPDATE_DATE:=pairs.last_update;
      IF pairs.metric_name='PATCHES' THEN
        PATCHES:=pairs.value;
      ELSIF pairs.metric_name='PROFILE_OPT'  THEN
        PROFILE_OPT:=pairs.value;
      ELSIF  pairs.metric_name='CONTEXT_FILES_EDITED'  THEN
        CONTEXT_FILES_EDITED:=pairs.value;
      ELSIF  pairs.metric_name='INVALID_OBJECTS'  THEN
        INVALID_OBJECTS:=pairs.value;
      END IF;
    END LOOP;

    OPEN ret FOR
      SELECT    PATCHES,
                PROFILE_OPT,
                CONTEXT_FILES_EDITED,
                INVALID_OBJECTS,
                LAST_UPDATE_DATE
        FROM    dual;

    return ret;
  END get_conf_changed;


  /* DONE FOR LEVEL 1*/
  FUNCTION get_web_components_status return oam_cursor_type IS
    ret oam_cursor_type;

    PL_SQL_AGNT_GEN VARCHAR2(256);
    SERVLET_AGNT_GEN VARCHAR2(256);
    JSP_AGNT_GEN VARCHAR2(256);
    JTF_GEN VARCHAR2(256);
    DISCOVERER_GEN VARCHAR2(256);
    PHP_GEN VARCHAR2(256);
    TCF_GEN VARCHAR2(256);
    LAST_UPDATE_DATE VARCHAR2(256);

  BEGIN
    FOR pairs IN
    (
       SELECT   fom.METRIC_SHORT_NAME metric_name,
                decode(to_char(fom.status_code),NULL,'NA','2','DOWN','0','UP','1','WARNING','3','NOT_STARTED','NA') value,
                to_char(fom.LAST_UPDATE_DATE,'yyyy/MM/dd HH:mm:ss') last_update
        FROM    fnd_oam_metval fom
       WHERE    fom.GROUP_ID = 8
    )
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      LAST_UPDATE_DATE:=pairs.last_update;
      IF pairs.metric_name='PL_SQL_AGNT_GEN' THEN
        PL_SQL_AGNT_GEN:=pairs.value;
      ELSIF pairs.metric_name='SERVLET_AGNT_GEN'  THEN
        SERVLET_AGNT_GEN:=pairs.value;
      ELSIF  pairs.metric_name='JSP_AGNT_GEN'  THEN
        JSP_AGNT_GEN:=pairs.value;
      ELSIF  pairs.metric_name='JTF_GEN'  THEN
        JTF_GEN:=pairs.value;
      ELSIF pairs.metric_name='DISCOVERER_GEN'  THEN
        DISCOVERER_GEN:=pairs.value;
      ELSIF  pairs.metric_name='PHP_GEN'  THEN
        PHP_GEN:=pairs.value;
      ELSIF  pairs.metric_name='TCF_GEN'  THEN
        TCF_GEN:=pairs.value;
      END IF;
    END LOOP;



    OPEN ret FOR
       SELECT     PL_SQL_AGNT_GEN,
                  SERVLET_AGNT_GEN,
                  JSP_AGNT_GEN,
                  JTF_GEN,
                  DISCOVERER_GEN,
                  PHP_GEN,
                  TCF_GEN,
                  LAST_UPDATE_DATE
        FROM    dual;


    return ret;
  END get_web_components_status;


  /* DONE FOR LEVEL 1*/
  FUNCTION get_ebiz_int_sys_alerts return oam_cursor_type IS
    ret oam_cursor_type;
    CRIT_UNPR_EXCEP VARCHAR2(256);
    CRIT_PR_EXCEP  VARCHAR2(256);
    CRIT_TOTAL_UNPR_EXCEP VARCHAR2(256);
    OPEN_OCC VARCHAR2(256);
    LAST_UPDATE_DATE VARCHAR2(256);
  BEGIN

    FOR pairs IN
    (
       SELECT   fom.METRIC_SHORT_NAME metric_name,
                fom.METRIC_VALUE value,
                to_char(fom.LAST_UPDATE_DATE,'yyyy/MM/dd HH:mm:ss') last_update
          FROM  fnd_oam_metval fom
         WHERE  fom.METRIC_SHORT_NAME in
                ('CRIT_UNPR_EXCEP','CRIT_PR_EXCEP','CRIT_TOTAL_UNPR_EXCEP','OPEN_OCC')
    )
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      LAST_UPDATE_DATE:=pairs.last_update;
      IF (pairs.metric_name='CRIT_UNPR_EXCEP') THEN
        CRIT_UNPR_EXCEP:=pairs.value;
      ELSIF (pairs.metric_name='CRIT_PR_EXCEP') THEN
        CRIT_PR_EXCEP:=pairs.value;
      ELSIF (pairs.metric_name='CRIT_TOTAL_UNPR_EXCEP') THEN
        CRIT_TOTAL_UNPR_EXCEP:=pairs.value;
      ELSIF (pairs.metric_name='OPEN_OCC') THEN
        OPEN_OCC:=pairs.value;
      END IF;
    END LOOP;

    OPEN ret FOR
      SELECT    CRIT_UNPR_EXCEP,
                CRIT_PR_EXCEP,
                CRIT_TOTAL_UNPR_EXCEP,
                OPEN_OCC,
                LAST_UPDATE_DATE
        FROM    dual;

    return ret;

  END get_ebiz_int_sys_alerts;
  /*
  FUNCTION get_apps_general_info return oam_cursor_type IS
    ret oam_cursor_type;
    oam_root_url VARCHAR2(1024);
    apps_name VARCHAR2(1024);
    apps_version VARCHAR2(1024);
    multi_org VARCHAR2(1024);
    multi_lingual VARCHAR2(1024);
    multi_currency VARCHAR2(1024);
    products_installed VARCHAR2(1024);
  BEGIN

		FOR p_r_pair IN
  		( SELECT  ( decode(substr(profile_option_value,length(profile_option_value)), '/', substr(profile_option_value,1,length(profile_option_value)-1), profile_option_value)
		   ||'/servlets/weboam/') p_v
	   FROM  fnd_profile_options_vl ovl,
                fnd_profile_option_values v
         WHERE  (v.level_id(+) = 10001)
           AND  (ovl.application_id = 0 or ovl.application_id = 178)
           AND  ovl.profile_option_name='APPS_FRAMEWORK_AGENT'
           AND  ovl.application_id = v.application_id(+)
           AND  ovl.profile_option_id=v.profile_option_id(+)
			)
		LOOP
	  	oam_root_url := p_r_pair.p_v;
		END LOOP;

		FOR p_r_pair IN
  		( select APPLICATIONS_SYSTEM_NAME apps_name,
                RELEASE_NAME  version,
                MULTI_ORG_FLAG m_org,
                decode(MULTI_LINGUAL_FLAG,null,' ',MULTI_LINGUAL_FLAG)  m_li,
                MULTI_CURRENCY_FLAG  m_cur
           from fnd_product_groups
        )
		LOOP
      apps_name:=p_r_pair.apps_name;
	  	apps_version := p_r_pair.version;
      multi_org:=p_r_pair.m_org;
	  	multi_lingual := p_r_pair.m_li;
	  	multi_currency := p_r_pair.m_cur;
		END LOOP;


		FOR p_r_pair IN
  		( select to_char(count(*)) ac
          from fnd_oracle_userid o,
               fnd_application a,
               fnd_product_installations fpi
         where      fpi.application_id = a.application_id
                and fpi.oracle_id = o.oracle_id and status <>'N'
      )
		LOOP
	  	products_installed := p_r_pair.ac;
		END LOOP;




  	-- open the cursor to return
		OPEN ret FOR
	    SELECT  fnd_oam_em.get_apps_level apps_level,
              oam_root_url,
              apps_name,
              apps_version,
              multi_org,
              multi_lingual,
              multi_currency,
              products_installed
		  FROM dual;

    return ret;
  END get_apps_general_info;


  FUNCTION get_apps_level return CHAR IS
    ret CHAR:='1';
  BEGIN
    return ret;
  END get_apps_level;


*/


/*
  FUNCTION get_ebiz_activity return oam_cursor_type IS
    ret oam_cursor_type;
    ACTIVE_USERS VARCHAR2(256);
    SERVICE_PROCS VARCHAR2(256);
    RUNNING_REQ VARCHAR2(256);

  BEGIN
    SELECT to_char(count(F.login_id))
    INTO ACTIVE_USERS
    FROM fnd_login_resp_forms F,
         gv$session S
    WHERE F.AUDSID = S.AUDSID;


    SELECT to_char(count(*))
    INTO SERVICE_PROCS
    FROM fnd_concurrent_processes
    WHERE process_status_code in ('R','A','P','C','M','D','T');

    SELECT to_char(count(*))
    INTO RUNNING_REQ
    FROM  fnd_concurrent_requests
    WHERE phase_code = 'R';

    OPEN ret FOR
      SELECT    ACTIVE_USERS,
                SERVICE_PROCS,
                RUNNING_REQ
        FROM    dual;

    return ret;

  END get_ebiz_activity;

*/





/*
  FUNCTION get_wf_notification return oam_cursor_type IS
    ret oam_cursor_type;
    errored_ct INTEGER:=0;
    unsent_ct INTEGER:=0;
  BEGIN

		FOR pair_1 IN
  		( SELECT  count(*) p_v
          FROM  wf_notifications
         WHERE  mail_status in ('ERRORED','FAILED')
			)
		LOOP
	  	errored_ct := pair_1.p_v;
		END LOOP;

		FOR pair_2 IN
  		( SELECT  count(*) p_v
          FROM  wf_notifications
         WHERE  mail_status in ('UNSENT')
			)
		LOOP
	  	unsent_ct := pair_2.p_v;
		END LOOP;

  	-- open the cursor to return
		OPEN ret FOR
	    SELECT  to_char(errored_ct),to_char(unsent_ct)
		  FROM dual;

    return ret;
  END get_wf_notification;

*/
/*
  FUNCTION get_ebiz_status return oam_cursor_type IS
    ret oam_cursor_type;
    status INTEGER:=1;
  BEGIN

		FOR pair_1 IN
	  ( SELECT  foa.status_code sta
        FROM  fnd_oam_app_sys_status foa,
              fnd_concurrent_queues_vl fcq,
              FND_OAM_FNDNODES_VL fn,
              fnd_lookups fl
       WHERE  foa.application_id = fcq.application_id (+)
         AND  foa.concurrent_queue_name = fcq.concurrent_queue_name (+)
         AND  upper(foa.node_name) = upper(fn.node_name (+))
         AND  nvl(fn.platform_code, '-x') = fl.lookup_code(+)
         AND  fl.lookup_type(+) = 'PLATFORM'
         AND  (    foa.metric_short_name='WEB_SERVER_OVERALL'
                OR foa.metric_short_name='ADMIN_SERVER_OVERALL'
                OR foa.metric_short_name='DATA_SERVER_OVERALL'
                OR foa.metric_short_name='FORMS_SERVER_OVERALL'
                OR foa.metric_short_name='CP_SERVER_OVERALL'
                )
    )
		LOOP
      EXIT WHEN SQL%NOTFOUND;
	  	IF (pair_1.sta>0) THEN
        status:=0;
      END IF;
		END LOOP;

  	-- open the cursor to return
		OPEN ret FOR
	    SELECT  to_char(status)
		  FROM dual;

    return ret;
  END get_ebiz_status;
*/

/*
  FUNCTION get_web_user_last_hour return oam_cursor_type IS
    ret oam_cursor_type;
  BEGIN
		OPEN ret FOR
	    SELECT to_char(count(*))
      FROM   ( select distinct user_id from icx_sessions
               where last_connect >= sysdate - (1/24)
--		            and (function_type is null or function_type != 'FORM')
             );
    return ret;
  END get_web_user_last_hour;
*/

/*
  FUNCTION get_active_requests_by_app return oam_cursor_type IS
    ret oam_cursor_type;
  BEGIN
		OPEN ret FOR
	    select asn,an,to_char(sum(nac)),to_char(sum(ac)) from
		      (
      			SELECT a.application_short_name asn, a.application_name an, COUNT(*) nac, 0 ac
			          FROM fnd_concurrent_requests r, fnd_application_vl a
		      	    WHERE r.program_application_id = a.application_id
	  			    AND phase_code in ('P', 'R')
      			    AND r.resubmit_time is null
			       GROUP BY a.application_short_name,a.application_name
		     UNION ALL
     				SELECT a.application_short_name asn, a.application_name an, 0 nac, COUNT(*) ac
				 FROM  fnd_concurrent_requests r, fnd_application_vl a
				  WHERE r.program_application_id = a.application_id
				    AND phase_code in ('P', 'R')
      			    AND r.resubmit_time is not null
			      GROUP BY a.application_short_name,a.application_name
		      )
			   group by asn,an;

    return ret;
  END get_active_requests_by_app;
	*/
  /*
  FUNCTION get_hourly_completed_requests return oam_cursor_type IS
    ret oam_cursor_type;
  BEGIN
		OPEN ret FOR
  			SELECT to_char(a.a), to_char(b.b), to_char(c.c),
		       a.a/decode(a.a+b.b+c.c, 0, 1, a.a+b.b+c.c)*100,
		       b.b/decode(a.a+b.b+c.c, 0, 1, a.a+b.b+c.c)*100,
		       c.c/decode(a.a+b.b+c.c, 0, 1, a.a+b.b+c.c)*100
			FROM
			  (
			    SELECT COUNT(*) a
			      FROM fnd_concurrent_requests
			      WHERE phase_code = 'C' AND status_code = 'C'
			        AND actual_completion_date between (sysdate - 1/24) and sysdate
			  ) a,
			  (
			    SELECT COUNT(*) b
			      FROM fnd_concurrent_requests
			      WHERE phase_code = 'C' AND status_code = 'G'
			        AND actual_completion_date between (sysdate - 1/24) and sysdate
			  ) b,
			  (
			    SELECT COUNT(*) c
			      FROM fnd_concurrent_requests
			      WHERE phase_code = 'C' AND status_code = 'E'
		        AND actual_completion_date between (sysdate - 1/24) and sysdate
			  ) c ;

    return ret;
  END get_hourly_completed_requests;

*/
/*
  FUNCTION get_apps_framework_agent return oam_cursor_type IS
    ret oam_cursor_type;
    frame_agent VARCHAR2(1024);

  BEGIN

		FOR p_r_pair IN
  		( SELECT  (profile_option_value||'/servlets/weboam/') p_v
          FROM  fnd_profile_options_vl ovl,
                fnd_profile_option_values v
         WHERE  (v.level_id(+) = 10001)
           AND  (ovl.application_id = 0 or ovl.application_id = 178)
           AND  ovl.profile_option_name='APPS_FRAMEWORK_AGENT'
           AND  ovl.application_id = v.application_id(+)
           AND  ovl.profile_option_id=v.profile_option_id(+)
			)
		LOOP
	  	frame_agent := p_r_pair.p_v;
		END LOOP;


  	-- open the cursor to return
		OPEN ret FOR
	    SELECT  frame_agent
		  FROM dual;

    return ret;
  END get_apps_framework_agent;

*/
/*  FUNCTION get_rqsts_stats return oam_cursor_type IS

    result oam_cursor_type;
    pending_scheduled_ct INTEGER:=0;
    pending_normal_ct INTEGER:=0;
    pending_standby_ct INTEGER:=0;
    no_manager_ct INTEGER:=0;
    on_hold_ct INTEGER:=0;
    running_ct INTEGER:=0;

  BEGIN
    FOR p_r_pair_1 IN
	  	( SELECT count(*) prc, status_code
			    FROM fnd_concurrent_requests
			   WHERE status_code IN ('I', 'Q'  )
			     AND requested_start_date <= sysdate
			     AND phase_code = 'P'
			     AND hold_flag = 'N'
			GROUP BY status_code
			)
		LOOP
		  IF p_r_pair_1.status_code = 'I' THEN
			  pending_normal_ct := p_r_pair_1.prc;
      ELSIF p_r_pair_1.status_code = 'Q' THEN
			  pending_standby_ct := p_r_pair_1.prc;
			END IF;
		END LOOP;


		FOR p_r_pair_2 IN
  		( SELECT count(*) prc
			    FROM fnd_concurrent_requests
			   WHERE phase_code = 'P'
			     AND hold_flag = 'N'
			     AND (    (status_code = 'P' )
	               OR (     status_code IN( 'I', 'Q')
	                    AND requested_start_date > sysdate
	  							  )
						   )
		  )
    LOOP
  		pending_scheduled_ct := p_r_pair_2.prc;
		END LOOP;

		FOR p_r_pair_3 IN
  		( SELECT count(*) prc
			    FROM fnd_concurrent_requests
			   WHERE status_code IN( 'R', 'T')
			)
		LOOP
	  	running_ct := p_r_pair_3.prc;
		END LOOP;

		FOR p_r_pair_4 IN
  		( SELECT count(*) prc
			    FROM fnd_concurrent_requests
			   WHERE phase_code  = 'P' AND status_code = 'M'
			)
		LOOP
	  	no_manager_ct := p_r_pair_4.prc;
		END LOOP;

		FOR p_r_pair_5 IN
  		( SELECT count(*) prc
			    FROM fnd_concurrent_requests
			   WHERE phase_code  = 'P' AND hold_flag = 'Y'
			)
		LOOP
	  	on_hold_ct := p_r_pair_5.prc;
		END LOOP;

  	-- open the cursor to return
		OPEN result FOR
	    SELECT  to_char(pending_normal_ct),
              to_char(pending_standby_ct),
              to_char(pending_scheduled_ct),
              to_char(no_manager_ct),
              to_char(on_hold_ct),
              to_char(running_ct)
		  FROM dual;

	  return result;

  END get_rqsts_stats;

*/

/*
  FUNCTION get_procs_rqsts_per_conc return oam_em_prpc_table_type IS
    results oam_em_prpc_table_type := oam_em_prpc_table_type();
    i NUMBER:=0;
  BEGIN
    i:=1;
  	FOR record_pair IN
	  (      SELECT  user_concurrent_queue_name r_n,
              fnd_conc_request_pkg.running_requests(concurrent_queue_name,
                  application_id) r_c,
              (select count(*)
                 from fnd_concurrent_processes cp
                where cp.queue_application_id = cq.application_id
                 and cp.concurrent_queue_id = cq.concurrent_queue_id
                 and (cp.process_status_code in ('C','M')
                      or (cp.process_status_code  in ('A', 'D', 'T')
                          and exists (select 1 from gv$session
                                      where cp.session_id = audsid)
                         )
                     )
              ) a_p,
              fnd_oam_em.get_pend_rqsts('I',application_id,concurrent_queue_id) n_c,
              fnd_oam_em.get_pend_rqsts('Q',application_id,concurrent_queue_id) s_c

        FROM  fnd_concurrent_queues_vl CQ,
        WHERE manager_type = 1
        ORDER BY decode(CQ.control_code, 'X',2,'E',2,1), user_concurrent_queue_name
    )
	  LOOP
      EXIT WHEN SQL%NOTFOUND;
      results.extend(1);

      results(i) := oam_em_prpc_type(record_pair.r_n,
                                     record_pair.a_p,
                                     record_pair.r_c,
                                     record_pair.n_c,
                                     record_pair.s_c
                                     );

  		i := i+1;
  	END LOOP;

    i:=i-1;


    return results;

  END get_procs_rqsts_per_conc;
*/


/*
  FUNCTION get_pend_rqsts(status_code CHAR, app_id NUMBER, mgr_id NUMBER)
    return NUMBER IS
    ret NUMBER:=0;

    TYPE   cursor_type IS REF CURSOR;
    data_cursor  cursor_type;
    sql_stmt VARCHAR2(1024);

  BEGIN
    sql_stmt := 'SELECT 	count(R.Request_ID) rc '||
       ' FROM Fnd_concurrent_worker_requests '||
       ' WHERE phase_code = ''P'''||
       '   AND 	status_code = :status_code'||
       '   AND 	queue_application_id = :app_id'||
       '   AND 	concurrent_queue_id = :mgr_id'||
       '   AND 	hold_flag != ''Y'''||
       '   AND 	CWR.requested_start_date <= sysdate';


    OPEN data_cursor FOR sql_stmt
      USING status_code, app_id, mgr_id;
    LOOP
      FETCH data_cursor INTO ret;
      EXIT WHEN data_cursor%NOTFOUND;
    END LOOP;
    CLOSE data_cursor;


    return ret;
  END get_pend_rqsts;
*/
/*
  FUNCTION get_workitem_metrics return oam_cursor_type IS

    ret oam_cursor_type;
    active_count INTEGER:=0;
    deferred_count INTEGER:=0;
    suspended_count INTEGER:=0;
    errored_count INTEGER:=0;
  BEGIN

    FOR pairs IN(
      SELECT  count(distinct(item_key)) ac
      FROM wf_items
      WHERE end_date is null)
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      active_count := pairs.ac;
    END LOOP;


    FOR pairs IN(
      SELECT  count(*) ac
        FROM  wf_item_activity_statuses
       WHERE  activity_status = 'DEFERRED')
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      deferred_count := pairs.ac;
    END LOOP;


    FOR pairs IN(
      SELECT  count(*) ac
        FROM  wf_item_activity_statuses
       WHERE  activity_status = 'SUSPEND')
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      suspended_count := pairs.ac;
    END LOOP;



    FOR pairs IN(
      SELECT  count(distinct(item_key)) ac
        FROM  wf_item_activity_statuses
       WHERE  activity_status = 'ERROR')
    LOOP
      EXIT WHEN SQL%NOTFOUND;
      errored_count := pairs.ac;
    END LOOP;

    OPEN ret FOR
      SELECT  to_char(active_count),
              to_char(deferred_count),
              to_char(suspended_count),
              to_char(errored_count)
        FROM  dual;
    return ret;

  END get_workitem_metrics;
*/
/*  FUNCTION get_block_icm_crm return oam_cursor_type IS
    ret oam_cursor_type;

  BEGIN

    OPEN ret FOR
				SELECT hs.audsid, hs.program, hs.osuser, hs.process,
				    hs.machine, hs.terminal,
            hl.ctime,
            hl.type, to_char(hl.id1), to_char(hl.id2),
				    DECODE(hl.lmode, 1, 'NULL', 2, 'ROW SHARE', 3, 'ROW EXCLUSIVE',
				      4, 'SHARE', 5, 'SHARE ROW EXCLUSIVE', 6, 'EXCLUSIVE', '?')
				  FROM fnd_concurrent_processes p, v$session ws, v$lock wl, v$lock hl ,
				    v$session hs
				  WHERE p.queue_application_id = 0 AND p.concurrent_queue_id IN (1,4)
				    AND p.session_id = ws.audsid AND ws.lockwait IS NOT NULL
				    AND ws.lockwait = wl.kaddr AND wl.id1 = hl.id1 AND wl.id2 = hl.id2
				    AND hl.sid = hs.sid AND hl.request = 0;
    return ret;

  END get_block_icm_crm;
*/

/*
  FUNCTION get_apps_sys_metrics return oam_cursor_type IS
    ret oam_cursor_type;
  BEGIN

    OPEN ret FOR
      SELECT

                fsm.metric_short_name,
                fsm.metric_display_name,
                fsm.metric_value,
                decode(fsm.description,NULL,'N/A',fsm.description),
                to_char(decode(fsm.status_code,NULL,-1,fsm.status_code)),
                to_char(fsm.last_update_date,'yyyy/MM/dd HH:mm:ss') last_update_date,
                to_char(fsm.sequence),
                to_char(fsm.group_id),
                to_char(fsmg.sequence),
                fsmg.metric_group_display_name


        FROM    fnd_oam_metval_vl fsm,
                fnd_oam_met_grps_vl fsmg,
                FND_OAM_FNDNODES_VL fn
        WHERE   fsm.group_id = fsmg.metric_group_id
          AND   upper(fsm.node_name) = upper(fn.node_name (+))
     ORDER BY   fsmg.sequence, fsm.sequence;


    return ret;
  END get_apps_sys_metrics;
*/


  FUNCTION get_icm_status return NUMBER IS
           PRAGMA AUTONOMOUS_TRANSACTION;
   appId number;
   mgrId number;
   target number;
   active number;
   pmon   varchar2(30);
   stat number;
   retu number(1);
  BEGIN
    appId :=0;
    mgrId :=1;

    fnd_concurrent.get_manager_status(APPLID=>appId, MANAGERID=>mgrId, targetp =>target, activep=>active, pmon_method =>pmon, callstat =>stat);
    --dbms_output.put_line('stat=' || stat);
    --dbms_output.put_line('active=' || active);
    --dbms_output.put_line('target=' || target);
    --dbms_output.put_line('pmon=' || pmon);

    if((stat=0) AND (active > 0)) THEN
      retu := 1;
    else
      retu := 0;
    end if;

    --dbms_output.put_line('retu=' || retu);

    return retu;
  END get_icm_status;

/*
  FUNCTION get_icm_statusV return varchar2 IS
   appId number(10);
   mgrId number(10);
   target number(10);
   active number(10);
   pmon   varchar2(30);
   stat number(10);
   retu varchar2(10);
  BEGIN
    appId :=0;
    mgrId :=0;

    fnd_concurrent.get_manager_status(APPLID=>appId, MANAGERID=>mgrId, targetp =>target, activep=>active, pmon_method =>pmon, callstat =>stat);
    --dbms_output.put_line('stat=' || stat);
    --dbms_output.put_line('active=' || active);
    --dbms_output.put_line('target=' || target);
    --dbms_output.put_line('pmon=' || pmon);

    if((stat=0) AND (active > 0)) THEN
      retu := '1';
    else
      retu := '0';
    end if;

    --dbms_output.put_line('retu=' || retu);

    return 'active=' || active || ' stat=' || stat || 'pMon=' || pmon || ' target=' || target ||'retu=' || retu;
  END get_icm_statusV;
*/


END fnd_oam_em;

/

  GRANT EXECUTE ON "APPS"."FND_OAM_EM" TO "EM_OAM_MONITOR_ROLE";
