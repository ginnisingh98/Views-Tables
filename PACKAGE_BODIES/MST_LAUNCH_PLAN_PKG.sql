--------------------------------------------------------
--  DDL for Package Body MST_LAUNCH_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_LAUNCH_PLAN_PKG" AS
 /* $Header: MSTPLAPB.pls 120.0 2005/05/26 17:44:13 appldev noship $ */

    PROCEDURE mst_launch_plan (
                                errbuf                  OUT NOCOPY VARCHAR2,
                                retcode                 OUT NOCOPY NUMBER,
                                arg_plan_id             IN         NUMBER,
                                arg_reuse_files         IN	   NUMBER,
                                arg_audit_mode		IN	   NUMBER ,
                                arg_launch_planner      IN         NUMBER,
                                arg_plan_start_date     IN         VARCHAR2 ,
                                arg_plan_cutoff_date    IN         VARCHAR2,
                                arg_netchange_mode      IN         NUMBER DEFAULT NULL
				 )
IS
    var_snapshot_req_id        INTEGER;
    var_audit_req_id        INTEGER;
    var_planner_req_id        INTEGER;
    var_user_id             INTEGER;
    v_plan_id                       NUMBER;
    v_desig_id                      NUMBER;
    v_completion_date               date;
    l_platform_type NUMBER := 0;
    l_call_status      boolean;
    l_phase            varchar2(80);
    l_status           varchar2(80);
    l_dev_phase        varchar2(80);
    l_dev_status       varchar2(80);
    l_message          varchar2(2048);
    l_industry    VARCHAR2(30);
    l_schema    VARCHAR2(30);
    v_lookup_name           varchar2(100);
    v_req_data              number;
    v_ex_error_plan_launch       EXCEPTION;
    lLaunchPlanner  NUMBER ;
    lNetchange       NUMBER ;
    lAuditMode    NUMBER ;
    lReUseFiles   NUMBER ;
    lStartDate	  VARCHAR2(30) ;
    lCutoffDate   VARCHAR2(30) ;
    CURSOR C1(p_plan_id in number) IS
    SELECT
           Plan_Type, request_id, plan_completion_date,
           compile_designator,audit_request_id
    FROM mst_plans
    WHERE plan_id = p_plan_id;

v_rec_c1 c1%rowtype;

BEGIN
    lLaunchPlanner  := arg_launch_planner;
    lNetchange := arg_netchange_mode;
    lAuditMode := arg_audit_mode;
    lReUseFiles := arg_reuse_files;
    lStartDate :=  arg_plan_start_date;
    lCutoffDate := arg_plan_cutoff_date;

v_plan_id := arg_plan_id;


v_req_data := fnd_conc_global.request_data;
IF v_req_data is null then
        open c1(v_plan_id);
        fetch c1 into v_rec_c1;
        Close c1;

       IF ( v_rec_c1.request_id is not null ) Then
        -- -------------------------------------
            -- Check if previous plan output exists.
            -- if existing, check for the status of
            -- of the plan output.
            -- -------------------------------------
            l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                                                ( v_rec_c1.request_id,
                                                  NULL,
                                                  NULL,
                                                  l_phase,
                                                  l_status,
                                                  l_dev_phase,
                                                  l_dev_status,
                                                  l_message);

            IF v_rec_c1.plan_completion_date is not null then
                IF upper(l_dev_phase) <>'COMPLETE' then
                      v_lookup_name := 'MST_POST_PROCESSING_RUNNING';
                      raise v_ex_error_plan_launch;
                END IF;
            ELSE
               IF upper(l_dev_phase) <>'COMPLETE' then
                      v_lookup_name := 'MST_PLAN_RUNNING';
                      raise v_ex_error_plan_launch;
               END IF;
	    END IF;

        END IF; --v_rec_c1.request_id

       IF ( v_rec_c1.audit_request_id is not null ) Then
        -- -------------------------------------
            --  check for the status of
            -- of the  audit request
            -- -------------------------------------
            l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                                                ( v_rec_c1.audit_request_id,
                                                  NULL,
                                                  NULL,
                                                  l_phase,
                                                  l_status,
                                                  l_dev_phase,
                                                  l_dev_status,
                                                  l_message);

               IF upper(l_dev_phase) <> 'COMPLETE' then
                      v_lookup_name := 'MST_AUDIT_RUNNING';
                      raise v_ex_error_plan_launch;
               END IF;

       END IF; --v_rec_c1.audit_request_id

 END IF;

  -- if net change snapshot has to be launched
  IF arg_netchange_mode = SYS_YES THEN
    lReUseFiles := SYS_NO;
  ELSE
    lNetchange := SYS_NO;

  END IF;



            var_snapshot_req_id := NULL;

               var_snapshot_req_id := FND_REQUEST.SUBMIT_REQUEST(
                	'MST', -- application
                	'MSTSNPMPRC', -- program
                	NULL,  -- description
                	NULL, -- start time
                	FALSE, -- sub_request
                	v_plan_id,
			lStartDate, -- plan start date
			lCutoffDate, -- plan cutoff date
                	lLaunchPlanner,
                	0, -- snapshot_worker
                	0, -- monitor_pipe
                	0, -- monitor_request_id
                	lNetchange,  -- Netchange_mode
                	lReUseFiles,  -- Reuse set up files
                	lAuditMode  -- audit mode
			  );

             UPDATE mst_plans
             SET     request_id =  var_snapshot_req_id
             WHERE   plan_id =     v_plan_id;

        COMMIT;
        MSC_UTIL.msc_Debug('Launched Snapshot:'||
                      to_char(var_snapshot_req_id));

    retcode := 0;
    errbuf := NULL;
    return;

EXCEPTION
   when v_ex_error_plan_launch then
        retcode := 2;
        if v_lookup_name is not null then
                fnd_message.set_name('MST',v_lookup_name);
                fnd_message.set_token('PLAN_NAME',v_rec_c1.compile_designator);
                errbuf := fnd_message.get;
        end if;
   when OTHERS THEN
       retcode := 2;
        errbuf := sqlerrm;
END mst_launch_plan;


PROCEDURE refresh_snapshot(
	ERRBUF             OUT NOCOPY VARCHAR2,
        RETCODE            OUT NOCOPY NUMBER,
        pSNAPName in VARCHAR2,
        pDEGREE in NUMBER DEFAULT 0)
IS
lv_DEGREE               NUMBER;
lv_base_table_name        VARCHAR2(30);
lv_snap_schema            VARCHAR2(30);
lv_snapshot_str         VARCHAR2(2000); -- list of snapshots to be refreshed
lv_refresh_param        VARCHAR2(10);
lv_setup_source_objs    NUMBER;

 l_retval boolean;
 l_dummy1 varchar2(32);
 l_dummy2 varchar2(32);
 l_wsh_schema varchar2(32);

SOURCE_SETUP_ERROR EXCEPTION;

BEGIN
   lv_DEGREE := nvl(pDEGREE,0);
   lv_DEGREE := LEAST(lv_DEGREE,10);

   RETCODE := G_ERROR;

   IF FOUND_EXIST_OBJECTS = FALSE THEN
      lv_setup_source_objs := 1;
   ELSE
      SELECT  DECODE(NVL(fnd_profile.value('MST_SOURCE_SETUP') ,'1'), '1',1 ,2)
      INTO    lv_setup_source_objs
      FROM    DUAL;
   END IF;

   IF (lv_setup_source_objs = 1)  THEN
     IF SETUP_SOURCE_OBJECTS = FALSE THEN
       RAISE SOURCE_SETUP_ERROR;
     END IF;

  ELSE

     l_retval := FND_INSTALLATION.GET_APP_INFO
	( 'WSH',
	    l_dummy1,
	    l_dummy2,
	    l_wsh_schema);

      SELECT  owner,master
      INTO  lv_snap_schema,lv_base_table_name
     FROM  ALL_SNAPSHOTS
     WHERE  name = pSNAPName
     AND OWNER = l_wsh_schema ;


   lv_snapshot_str := lv_snap_schema||'.'||pSNAPName;
   lv_refresh_param := 'F';
     DBMS_SNAPSHOT.REFRESH ( lv_snapshot_str,
		lv_refresh_param,
		parallelism =>lv_DEGREE);
  END IF;

  COMMIT;

   RETCODE := G_SUCCESS;
EXCEPTION
    WHEN SOURCE_SETUP_ERROR  THEN
         MSC_UTIL.MSC_LOG('Error Setting Up Source Objects');
         RETCODE:= G_ERROR;

         ERRBUF:= SQLERRM;

   WHEN OTHERS THEN ROLLBACK;
        RETCODE := G_ERROR;
        ERRBUF := SQLERRM;
END ;

 /* This function determines whether some necessary object for snapshot exists */
 FUNCTION FOUND_EXIST_OBJECTS RETURN BOOLEAN
 IS
     l_objs_count    NUMBER;

     BEGIN

     SELECT COUNT(object_name)
     INTO  l_objs_count
     FROM  ALL_OBJECTS
     WHERE UPPER(object_name) = 'MST_DELIVERY_DETAILS_SN_V' AND
           UPPER(object_type) = 'VIEW' AND
           UPPER(owner)       = 'APPS';

     IF ( l_objs_count < 1 ) THEN
       return FALSE;
     END IF;

  return TRUE;

 EXCEPTION

      WHEN OTHERS THEN

         MSC_UTIL.MSC_LOG( SQLERRM);
         return FALSE;
 END FOUND_EXIST_OBJECTS;


 /* This function will be called based on the profile option MST_SOURCE_SETUP*/
   FUNCTION SETUP_SOURCE_OBJECTS  RETURN BOOLEAN
   IS
    l_user_id         NUMBER;
    l_application_id  NUMBER;
    l_resp_id         NUMBER;

    lv_request_id_wsh NUMBER;
    lv_request_id_objs NUMBER;
    lv_success boolean:= TRUE;

    lv_out number;

    BEGIN
    /* Submit the request to drop and create snapshot*/
    lv_request_id_wsh := FND_REQUEST.SUBMIT_REQUEST(
                          'MST',
                          'MSTWSHSN',
                          NULL,
                          NULL,
                          FALSE);  -- sub request
      commit;
    MSC_UTIL.MSC_LOG( 'Request : ' ||
	 lv_request_id_wsh||' : WSH SNAPSHOT TABLE Creation request submitted');

    wait_for_request(lv_request_id_wsh, 10, lv_out);

    if lv_out = 2 THEN
	lv_success := FALSE ;
    else
	lv_success :=  TRUE;
    end if;

    /* Only if the Snapshot Creation Process is successfull then call the
	create triggers/view/synonyms */

        if lv_success THEN --create snapshots success
          lv_request_id_objs := FND_REQUEST.SUBMIT_REQUEST(
                                'MST',
                                'MSTSNETC',
                                NULL,
                                NULL,
                                FALSE);  -- sub request
          commit;
          MSC_UTIL.MSC_LOG( 'Request : '||lv_request_id_objs||' :Creates Triggesr/Views Submitted');

       end if;

   IF lv_success THEN
     begin
         MSC_UTIL.MSC_LOG('Updating Profile Option MSC_SOURCE_SETUP to No ');

         UPDATE FND_PROFILE_OPTION_VALUES
         SET    PROFILE_OPTION_VALUE = '2'
         WHERE  PROFILE_OPTION_ID = (SELECT PROFILE_OPTION_ID
                                  FROM FND_PROFILE_OPTIONS
                                  WHERE PROFILE_OPTION_NAME = 'MST_SOURCE_SETUP');
          MSC_UTIL.MSC_LOG('Profile Option MSC_SOURCE_SETUP has been updated No ');

         COMMIT;
         return TRUE;

         EXCEPTION
           WHEN OTHERS THEN
             MSC_UTIL.MSC_LOG ('Error Updating Profile MSC_SOURCE_SETUP: '||SQLERRM);
      end;
   ELSE
      MSC_UTIL.MSC_LOG ('Source Setup Objects Creation Requests did not complete Successfully');
      MSC_UTIL.MSC_LOG(lv_request_id_wsh);
      MSC_UTIL.MSC_LOG(lv_request_id_objs);
      return false;
   END IF;

  return true;

   EXCEPTION

      WHEN OTHERS THEN

         MSC_UTIL.MSC_LOG( SQLERRM);
         return FALSE;
   END SETUP_SOURCE_OBJECTS;


 PROCEDURE WAIT_FOR_REQUEST(
                      p_request_id in number,
                      p_timeout      IN  NUMBER,
                      o_retcode      OUT NOCOPY NUMBER)
   IS

   l_refreshed_flag           NUMBER;
   l_pending_timeout_flag     NUMBER;
   l_start_time               DATE;

   ---------------- used for fnd_concurrent ---------
   l_call_status      boolean;
   l_phase            varchar2(80);
   l_status           varchar2(80);
  l_dev_phase        varchar2(80);
   l_dev_status       varchar2(80);
   l_message          varchar2(240);
   l_request_id number;

   BEGIN
    l_request_id := p_request_id;
     l_start_time := SYSDATE;

     LOOP
     << begin_loop >>

       l_pending_timeout_flag := SIGN( SYSDATE - l_start_time - p_timeout/1440.0);

       l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                              ( l_request_id,
                                10,
                                10,
                                l_phase,
                               l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

       EXIT WHEN l_call_status=FALSE;
       IF l_dev_phase='PENDING' THEN
             EXIT WHEN l_pending_timeout_flag= 1;

       ELSIF l_dev_phase='RUNNING' THEN
             GOTO begin_loop;

       ELSIF l_dev_phase='COMPLETE' THEN
             IF l_dev_status = 'NORMAL' THEN
                o_retcode:= SYS_YES;
                RETURN;
             END IF;
             EXIT;

       ELSIF l_dev_phase='INACTIVE' THEN
             EXIT WHEN l_pending_timeout_flag= 1;
       END IF;

       DBMS_LOCK.SLEEP( 10);

     END LOOP;

     o_retcode:= SYS_NO;
     RETURN;
 END WAIT_FOR_REQUEST;

END mst_launch_plan_pkg; -- package

/
