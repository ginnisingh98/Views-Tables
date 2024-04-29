--------------------------------------------------------
--  DDL for Package Body MSC_E1APS_DSMCOLL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_E1APS_DSMCOLL" AS --body
--# $Header: MSCE1DSB.pls 120.0.12010000.14 2009/06/05 14:10:34 nyellank noship $
	/* Global variables */

	ReturnStr varchar2(5000);
	SessionNum varchar2(10);
	ErrMessage varchar2(1900);
	ErrLength integer;
	StartIndex integer;
	EndIndex integer;
	WSURL varchar2(1000);
	source_file varchar2(200);
	destination_file varchar2(200);
	fc_url varchar2(1000);
	l_wf_lookup_code varchar2(1000);
	errbuf VARCHAR2(1000);
	retcode NUMBER;
	process_id VARCHAR2(10);



	FUNCTION MSC_E1APS_ODIExecute(scrName IN VARCHAR2,WSURL IN VARCHAR2)
		RETURN BOOLEAN
	AS

	BEGIN

		IF WSURL IS NOT NULL THEN
			begin
				/* Execute ODI scenarios */
				select MSC_E1APS_UTIL.MSC_E1APS_ODIScenarioExecute(scrName,'001','',WSURL) into ReturnStr from dual;
			EXCEPTION
				WHEN OTHERS THEN
					select instr(ReturnStr,'#') into StartIndex from dual;
					select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
					MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario' || scrName|| ' execution failed.' || ErrMessage);
					RETURN FALSE;
			end;

			select instr(ReturnStr,'#') into StartIndex from dual;
			select substr(ReturnStr,0,StartIndex-1) into SessionNum from dual;
			select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
			if (SessionNum = '-1') then
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || scrName|| ' executed with errors. Session #: ' || SessionNum || ' , Error Message: ' || ErrMessage);
				RETURN FALSE;
			end if;

			if (SessionNum <> '-1' and length(ErrMessage) > 0) then
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || scrName|| ' executed with errors. Session #: ' || SessionNum || ' , Error Message: ' || ErrMessage);
				RETURN FALSE;
			end if;

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || scrName || ' execution is successful.');
			RETURN TRUE;
		END IF;

		RETURN TRUE;

	END; --Procedure MSC_E1APS_DSMExecute


	PROCEDURE MSC_DSM_COLLECTIONS(ERRBUF OUT NOCOPY VARCHAR2,
								RETCODE OUT NOCOPY VARCHAR2,
								parInstanceID IN VARCHAR2,
								parLoadPayCnf IN NUMBER,
								parLoadDed in NUMBER)
	AS
		ODILaunchFlag BOOLEAN;
		mailstat      BOOLEAN;
		ret_value     BOOLEAN;
		l_user_id     number;
		fc_ret_value  BOOLEAN;
		scenario_name    VARCHAR2(200);
    scenario_version VARCHAR2(100);
    scenario_param   VARCHAR2(200);
    l_instance_code  VARCHAR2(3);
    pre_process_odi  BOOLEAN;
    post_process_odi BOOLEAN;
    ret_value1       BOOLEAN;

	BEGIN

      /* Launching  Collect DSM Pre-Proces Custom Hook*/
       MSC_E1APS_HOOK.COL_DSM_DATA_PRE_PROCESS(ERRBUF,RETCODE);
       IF RETCODE = MSC_UTIL.G_ERROR THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
           RETCODE := MSC_UTIL.G_ERROR;
           RETURN;
      END IF;

  /* Checking ODI Profile*/
        WSURL := fnd_profile.value('MSC_E1APS_ODIURL');
         IF WSURL IS NOT NULL THEN
                /* Launching Pre-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code
                from msc_apps_instances
                where instance_id = parInstanceID;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.COL_DSM_DATA;
                pre_process_odi   :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);

                 IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END IF;
         END IF;

		select ATTRIBUTE14,ATTRIBUTE13 into source_file,destination_file from MSC_APPS_INSTANCES where INSTANCE_ID = parInstanceID;

		/* Bug#8224935 - APP ID */
		l_user_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                     'COMP_PTP',
                                                                     1,
                                                                     'user_id'));
		/*Initialize ODI*/
		 WSURL:= fnd_profile.value('MSC_E1APS_ODIURL');
		IF WSURL IS NOT NULL THEN
			BEGIN
				MSC_UTIL.MSC_DEBUG('INITIALIZING ODI ....');
				select MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(WSURL,2) into ReturnStr from dual;

			EXCEPTION
			WHEN OTHERS THEN
				select instr(ReturnStr,'#') into StartIndex from dual;
				select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
				RETCODE := MSC_UTIL.G_ERROR;
        RETURN;
			END;
			  select instr(ReturnStr,'#') into StartIndex from dual;
				select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;

			 IF(length(ErrMessage) > 0) THEN
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
				RETCODE := MSC_UTIL.G_ERROR;
				return;
			end if;

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');


		END IF;

		IF parLoadPayCnf = MSC_UTIL.SYS_YES THEN

		 ODILaunchFlag := MSC_E1APS_ODIExecute('LOADE1APCONFIRMDATATODMPKG',WSURL);

		fc_url := fnd_profile.value('MSC_E1APS_FCURL');
		fc_ret_value:=TRUE;
		if fc_url is not null and ODILaunchFlag then
			fc_ret_value := MSC_E1APS_ODIExecute('IMPORTFILESTODEMANTRASERVER',fc_url);
			if fc_ret_value = FALSE then
			   /* Launch Mail */
			   mailstat := MSC_E1APS_ODIExecute('MAIL',WSURL);

				 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.'  );
				 RETCODE := MSC_UTIL.G_ERROR;
				 RETURN;
		 end if;
  else
			/* Launch Mail */
			mailstat := MSC_E1APS_ODIExecute('MAIL',WSURL);
      fc_ret_value:=ODILaunchFlag;

			IF ODILaunchFlag = FALSE THEN
			 RETCODE := MSC_UTIL.G_ERROR;
			 RETURN;
			END IF;

		 end if;

		IF fc_ret_value THEN
				/* Calling DEM WorkFlow*/
				l_wf_lookup_code := 'WF_AIA_E1_PTP_APCONFIRM_IMPORT';
				retcode := 0;

				/* Lauch Demantra Work Flow */
				MSC_E1APS_UTIL.DEM_WORKFLOW(errbuf, retcode, l_wf_lookup_code,process_id,l_user_id);

				if retcode = -1 or process_id= -1 then
					msd_dem_common_utilities.log_message('DEM WORKFLOW NOT LAUNCHED');
					RETCODE := MSC_UTIL.G_ERROR;
					RETURN;
				else
					msd_dem_common_utilities.log_message('DEM WORKFLOW LAUNCHED. Process ID: ' || process_id );
				end if;
		       END IF;

	   END IF;

		IF parLoadDed = MSC_UTIL.SYS_YES THEN

		ODILaunchFlag := MSC_E1APS_ODIExecute('LOADE1DEDUCTIONSDATATODMPKG',WSURL);

			fc_url := fnd_profile.value('MSC_E1APS_FCURL');
			fc_ret_value:=TRUE;
			if fc_url is not null and ODILaunchFlag then
				fc_ret_value := MSC_E1APS_ODIExecute('IMPORTFILESTODEMANTRASERVER',fc_url);
				if fc_ret_value = FALSE then
				  /* Launch Mail */
				   mailstat := MSC_E1APS_ODIExecute('MAIL',WSURL);

           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.'  );
					 RETCODE := MSC_UTIL.G_ERROR;
					 RETURN;
				 end if;
			 else
			     /* Launch Mail */
				    mailstat := MSC_E1APS_ODIExecute('MAIL',WSURL);
				    fc_ret_value:=ODILaunchFlag;

          IF ODILaunchFlag = FALSE THEN
			       RETCODE := MSC_UTIL.G_ERROR;
			      -- RETURN;
			    END IF;

			 end if;

			/* Launch Mail */
				mailstat := MSC_E1APS_ODIExecute('MAIL',WSURL);
   	 IF fc_ret_value THEN
				/* Calling DEM WorkFlow*/
				l_wf_lookup_code := 'WF_AIA_E1_DSM_NEWDEDUCT_DWNLD';
				retcode := 0;

				/* Lauch Demantra Work Flow */
				MSC_E1APS_UTIL.DEM_WORKFLOW(errbuf, retcode, l_wf_lookup_code,process_id,l_user_id);

				if retcode= -1 then
					msd_dem_common_utilities.log_message('DEM WORKFLOW NOT LAUNCHED');
				  RETCODE := MSC_UTIL.G_ERROR;
					RETURN;
				else
					msd_dem_common_utilities.log_message('DEM WORKFLOW LAUNCHED. Process ID: ' || process_id );
				end if;

			 END IF;
		   END IF;

              /* Launching Post-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code
                from msc_apps_instances
                where instance_id = parInstanceID;

                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.COL_DSM_DATA;

                   post_process_odi :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);

                    IF post_process_odi = FALSE THEN
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                     ELSE
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);
                     END IF;

		   /* Launching  Collect DSM Post-Proces Custom Hook*/
       MSC_E1APS_HOOK.COL_DSM_DATA_PRE_PROCESS(ERRBUF,RETCODE);
       IF RETCODE = MSC_UTIL.G_ERROR THEN
           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
           RETCODE := MSC_UTIL.G_ERROR;
           RETURN;
      END IF;

	END; -- Procedure MSC_DSM_COLLECTIONS

END MSC_E1APS_DSMCOLL;


/
