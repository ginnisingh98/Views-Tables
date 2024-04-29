--------------------------------------------------------
--  DDL for Package Body MSC_CL_PROFILE_LOADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_PROFILE_LOADERS" AS -- body
/* $Header: MSCPROFLDB.pls 115.0 2003/01/19 19:01:14 rawasthi noship $ */
  -- ========= Global Parameters ===========

   -- User Environment --
   v_current_date               DATE:= sysdate;
   v_current_user               NUMBER;
   v_applsys_schema             VARCHAR2(32);
   v_monitor_request_id         NUMBER;
   v_request_id                 NumTblTyp:= NumTblTyp(0);
   v_ctl_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dat_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_bad_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dis_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dat_file_path              VARCHAR2(1000):='';
   v_path_seperator             VARCHAR2(5):= '/';
   v_ctl_file_path              VARCHAR2(1000):= '';

   v_task_pointer               NUMBER:= 0;

   v_debug                      boolean := FALSE;

  -- =========== Private Functions =============

   PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

-- =====Local Procedures =========

   PROCEDURE GET_FILE_NAMES(  pDataFileName   VARCHAR2, pCtlFileName VARCHAR2)
   IS
   lv_file_name_length            NUMBER:= 0;
   lv_bad_file_name               VARCHAR2(1000):= '';
   lv_dis_file_name               VARCHAR2(1000):= '';

   BEGIN
		v_ctl_file.EXTEND;
		v_dat_file.EXTEND;
		v_bad_file.EXTEND;
		v_dis_file.EXTEND;

            v_task_pointer:= v_task_pointer + 1;

        	lv_file_name_length:= instr(pDataFileName, '.', -1);

	  	IF lv_file_name_length = 0 then

	  		lv_bad_file_name:= pDataFileName ||'.bad';
	  		lv_dis_file_name:= pDataFileName ||'.dis';

	  	ELSE

	  		lv_bad_file_name:= substr(pDataFileName, 1, lv_file_name_length)||'bad';
	  		lv_dis_file_name:= substr(pDataFileName, 1, lv_file_name_length)||'dis';

	  	END IF;

	     	v_ctl_file(v_task_pointer):= v_ctl_file_path || pCtlFileName;
		v_dat_file(v_task_pointer):= v_dat_file_path || pDataFileName;
		v_bad_file(v_task_pointer):= v_dat_file_path || lv_bad_file_name;
		v_dis_file(v_task_pointer):= v_dat_file_path || lv_dis_file_name;

		IF v_debug THEN
			LOG_MESSAGE('v_ctl_file('||v_task_pointer||'): '||v_ctl_file(v_task_pointer));
			LOG_MESSAGE('v_dat_file('||v_task_pointer||'): '||v_dat_file(v_task_pointer));
			LOG_MESSAGE('v_bad_file('||v_task_pointer||'): '||v_bad_file(v_task_pointer));
			LOG_MESSAGE('v_dis_file('||v_task_pointer||'): '||v_dis_file(v_task_pointer));
		END IF;

   END GET_FILE_NAMES;

   FUNCTION is_request_completed (p_request_id NUMBER)  RETURN NUMBER
   IS

      l_call_status           boolean;
      l_phase                 varchar2(80);
      l_status                varchar2(80);
      l_dev_phase             varchar2(80);
      l_dev_status            varchar2(80);
      l_message               varchar2(2048);
      l_num                   number;
      l_request_id            number;

   BEGIN

   l_request_id := p_request_id;

   LOOP
      dbms_lock.sleep(30);
      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

       IF l_call_status=FALSE THEN
         LOG_MESSAGE( l_message);
         RETURN 0;
       END IF;
      exit when l_dev_phase='COMPLETE';
     END LOOP;

   IF
      l_dev_phase='COMPLETE' and l_dev_status='NORMAL' then
      RETURN 1;
   ELSIF l_dev_phase='COMPLETE' and l_dev_status='ERROR' then
    RETURN 2;
   END IF;

 END is_request_completed;


   FUNCTION is_request_status_running RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);

      l_request_id       NUMBER;

   BEGIN

	l_request_id:= FND_GLOBAL.CONC_REQUEST_ID;

      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

      IF l_call_status=FALSE THEN
         LOG_MESSAGE( l_message);
         RETURN SYS_NO;
      END IF;

      IF l_dev_phase='RUNNING' THEN
         RETURN SYS_YES;
      ELSE
         RETURN SYS_NO;
      END IF;

   END is_request_status_running;

   FUNCTION active_loaders RETURN NUMBER IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);
      l_request_id       NUMBER;
	l_active_loaders	 NUMBER:= 0 ;

   BEGIN

      FOR lc_i IN 1..(v_request_id.COUNT) LOOP

          l_request_id:= v_request_id(lc_i);

          l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

           IF l_call_status=FALSE THEN
              LOG_MESSAGE( l_message);
           END IF;

           IF l_dev_phase IN ( 'PENDING','RUNNING') THEN
              l_active_loaders:= l_active_loaders + 1;
           END IF;

       END LOOP;

       RETURN l_active_loaders;

   END active_loaders;

   FUNCTION LAUNCH_LOADER (  ERRBUF      OUT NOCOPY VARCHAR2,
	                     RETCODE	 OUT NOCOPY NUMBER)
   RETURN NUMBER IS

   lv_request_id		NUMBER;
   lv_parameters		VARCHAR2(2000):= '';

   BEGIN

        lv_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCSLD', /* loader program called */
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- TRUE,
   				     v_ctl_file(v_task_pointer),
		                 v_dat_file(v_task_pointer),
				     v_dis_file(v_task_pointer),
				     v_bad_file(v_task_pointer),
				     null,
				     '10000000' ); -- NUM_OF_ERRORS
       COMMIT;

       IF lv_request_id = 0 THEN
          FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_LAUNCH_LOADER_FAIL');
          ERRBUF:= FND_MESSAGE.GET;
          LOG_MESSAGE( ERRBUF);
          RETCODE:= G_ERROR;
	    RETURN -1;
       ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_LOADER_REQUEST_ID');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_request_id);
         LOG_MESSAGE(FND_MESSAGE.GET);
       END IF;

      IF is_request_completed(lv_request_id)=2 THEN
       LOG_MESSAGE('ATTENTION: If Loader Worker has completed with ERROR, then user has to delete the records from MSC_ST_PROFILES with process flag 1 for that particular preference set,correct the data file and load it again');
      LOG_MESSAGE('The syntax of deleting from staging is:');
      LOG_MESSAGE('delete from MSC_ST_PROFILES where preference_set_name=PREFERENCE_SET_NAME and process_flag=1');
       ERRBUF  := SQLERRM;
       RETCODE := G_ERROR;
      END IF;

	RETURN lv_request_id;
   EXCEPTION
   WHEN OTHERS THEN
         LOG_MESSAGE( SQLERRM);
	   RETURN -1;
   END LAUNCH_LOADER;

-- ===============================================================

   PROCEDURE LAUNCH_PROFILE_MON( ERRBUF      OUT NOCOPY VARCHAR2,
	         RETCODE                     OUT NOCOPY NUMBER,
	         p_timeout                   IN  NUMBER,
                 p_path_separator            IN  VARCHAR2 DEFAULT '/',
                 p_ctl_file_path             IN  VARCHAR2,
	         p_directory_path            IN  VARCHAR2,
	         p_total_worker_num          IN  NUMBER,
                 p_get_profile_value          IN VARCHAR2 DEFAULT NULL)
   IS

   lc_i                 PLS_INTEGER;
   lv_process_time      NUMBER:= 0;
   lv_check_point       NUMBER:= 0;
   lv_request_id        NUMBER:= -1;
   lv_start_time        DATE;

   lv_active_loaders    NUMBER:=0;

   EX_PROCESS_TIME_OUT EXCEPTION;

   BEGIN
-- ===== Switch on debug based on MRP: Debug Profile

        v_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

-- print the parameters coming in

   IF v_debug THEN
    LOG_MESSAGE('p_timeout: '||p_timeout);
    LOG_MESSAGE('p_path_separator: '||p_path_separator);
    LOG_MESSAGE('p_ctl_file_path: '||p_ctl_file_path);
    LOG_MESSAGE('p_directory_path: '||p_directory_path);
    LOG_MESSAGE('p_total_worker_num: '||p_total_worker_num);
    LOG_MESSAGE('p_get_profile_value: '||p_get_profile_value);

   END IF;

-- get the ctl file path. If last character is not path seperator add it

       v_path_seperator:= p_path_separator;

       v_ctl_file_path := p_ctl_file_path;

        IF v_ctl_file_path IS NOT NULL THEN
                IF SUBSTR(v_ctl_file_path,-1,1) = v_path_seperator then
                        v_ctl_file_path:= v_ctl_file_path;
                ELSE
                        v_ctl_file_path:= v_ctl_file_path || v_path_seperator;
                END IF;
        END IF;

-- ===== Assign the data file directory path to a global variable ===========

-- If last character is not path seperator, add it. User may specify the path in the
-- file name itself. Hence, if path is null, do not add seperator

	IF p_directory_path IS NOT NULL THEN
	  	IF SUBSTR(p_directory_path,-1,1) = v_path_seperator then
	      	v_dat_file_path:= p_directory_path;
	  	ELSE
			v_dat_file_path:= p_directory_path || v_path_seperator;
	  	END IF;
	END IF;

-- ===== create the Control, Data, Bad, Discard Files lists ==================

      IF p_get_profile_value IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_get_profile_value, pCtlFileName => 'MSC_ST_PROFILE_VALUES.ctl');
        END IF;


      v_request_id.EXTEND(v_task_pointer);

      v_task_pointer:= 0;





  -- ============ Lauch the Loaders here ===============

     LOOP

	IF active_loaders < p_total_worker_num THEN

            EXIT WHEN is_request_status_running <> SYS_YES;

		IF v_task_pointer < (v_ctl_file.LAST - 1)  THEN

		   v_task_pointer:= v_task_pointer + 1;

		   lv_request_id:= LAUNCH_LOADER (ERRBUF        => ERRBUF,
					       RETCODE       => RETCODE);

		   IF lv_request_id <> -1 THEN
			v_request_id(v_task_pointer):= lv_request_id;
		   END IF;

                ELSIF active_loaders = 0 THEN

                   EXIT;

               ELSE

                  select (SYSDATE- START_TIME) into lv_process_time from dual;

                  IF lv_process_time > p_timeout/1440.0 THEN Raise EX_PROCESS_TIME_OUT;  END IF;

                      DBMS_LOCK.SLEEP( 5);

                  END IF;

	ELSE
   -- ============= Check the execution time ==============

         select (SYSDATE- START_TIME) into lv_process_time from dual;

         IF lv_process_time > p_timeout/1440.0 THEN Raise EX_PROCESS_TIME_OUT;  END IF;

         DBMS_LOCK.SLEEP( 5);

	END IF;

      END LOOP;

     lv_check_point:= 3;

     IF RETCODE= G_ERROR THEN RETURN; END IF;

   EXCEPTION

      WHEN EX_PROCESS_TIME_OUT THEN

         ROLLBACK;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_TIMEOUT');
         ERRBUF:= FND_MESSAGE.GET;
         RETCODE:= G_ERROR;
         LOG_MESSAGE( ERRBUF);

      WHEN others THEN

         ROLLBACK;

         ERRBUF := SQLERRM;
         RETCODE:= G_ERROR;
         LOG_MESSAGE( ERRBUF);

   END LAUNCH_PROFILE_MON;

END MSC_CL_PROFILE_LOADERS;

/
