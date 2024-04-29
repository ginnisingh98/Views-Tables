--------------------------------------------------------
--  DDL for Package Body MSC_E1APS_DEMCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_E1APS_DEMCL" AS -- body
                --# $Header: MSCE1DMB.pls 120.0.12010000.19 2009/09/09 07:26:23 nyellank noship $
                /* Function to call  MSC_E1APS_ODIScenarioExecute*/
        FUNCTION CALL_ODIEXE( scenario_name    IN VARCHAR2,
                              scenario_version IN VARCHAR2,
                              scenario_param   IN VARCHAR2,
                              wsurl            IN VARCHAR2)
                RETURN BOOLEAN
        IS
                err_message VARCHAR2(1900);
                start_index INTEGER;
                ebd_index   INTEGER;
                return_str  VARCHAR2(2000);
                session_num VARCHAR2(10);
        BEGIN
                /*execute ODI scenario*/
                BEGIN
                        IF wsurl IS NULL THEN
                                RETURN TRUE;
                        END IF;
                        SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIScenarioExecute(scenario_name,scenario_version,scenario_param,wsurl)
                        INTO   return_str
                        FROM   dual;

                EXCEPTION
                WHEN OTHERS THEN
                        SELECT instr(return_str,'#')
                        INTO   start_index
                        FROM   dual;

                        SELECT SUBSTR(return_str,start_index+1,1800)
                        INTO   err_message
                        FROM   dual;

                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario'
                        || scenario_name
                        || ' execution failed.'
                        || err_message);
                        RETURN FALSE;
                END;
                SELECT instr(return_str,'#')
                INTO   start_index
                FROM   dual;

                SELECT SUBSTR(return_str,0,start_index-1)
                INTO   session_num
                FROM   dual;

                SELECT SUBSTR(return_str,start_index+1,1800)
                INTO   err_message
                FROM   dual;

                IF session_num = '-1' THEN
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario '
                        || scenario_name
                        || ' executed with errors. Session #: '
                        || session_num
                        || ' , Error Message: '
                        || err_message);
                        RETURN FALSE;
                END IF;
                IF session_num <>'-1' AND LENGTH(err_message) > 0 THEN
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario '
                        || scenario_name
                        || ' executed with errors. Session #: '
                        || session_num
                        || ' , Error Message: '
                        || err_message);
                        RETURN FALSE;
                END IF;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario '
                || scenario_name
                || ' execution is successful.');
                RETURN TRUE;
        END CALL_ODIEXE;
        /* PROCEDURE For Collect Price List And UOM */
PROCEDURE DEM_PL_UOM(ERRBUF OUT NOCOPY  VARCHAR2,
                     RETCODE OUT NOCOPY VARCHAR2,
                     p_instance_id IN     NUMBER,
                     p_price_list  IN     NUMBER,
                     p_uom         IN     NUMBER)
IS

        /* Variables to Call PL CM */
        v_request_id1      NUMBER(20) DEFAULT 0;
        p_start_date       VARCHAR2(20);
        p_end_date         VARCHAR2(20);
        p_include_all      NUMBER(20);
        p_include_prl_list VARCHAR2(1000);
        p_exclude_prl_list VARCHAR2(1000);
        total_rows         NUMBER(10);
        /* Variables to Call UOM CM */
        v_request_id2      NUMBER(20) DEFAULT 0;
        p_include_uom_list VARCHAR2(1000);
        p_exclude_uom_list VARCHAR2(1000);
        l_instance_code    VARCHAR2(3);
        scenario_name      VARCHAR2(200);
        scenario_version   VARCHAR2(100);
        scenario_param     VARCHAR2(200);
        pre_process_odi    BOOLEAN;
        ret_value1         BOOLEAN;
        odi_url            VARCHAR2(1000);


BEGIN

        /* Launching Price List and UOM Pre-Proces Custom Hook*/
        MSC_E1APS_HOOK.COL_PRC_UOM_PRE_PROCESS(ERRBUF,RETCODE);

        IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
         END IF;

        /* Launching ODI Pre-Process Custom Hook Scenarios */
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL'); --Checking ODI Profile
        IF odi_url IS NOT NULL THEN

                select instance_code into l_instance_code
                from msc_apps_instances
                where instance_id = p_instance_id;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.COL_PRC_UOM;
                pre_process_odi   :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                 IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END IF;
        END IF;

        /* Launching Price List Collections*/
        IF p_price_list = 1 THEN
                BEGIN
                        /* Step 1: Deleting all rows from MSD_DEM_PRICE_LISTS */
                        DELETE
                        FROM   MSD_DEM_PRICE_LISTS;

                        COMMIT;
                EXCEPTION
                WHEN OTHERS THEN
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows Deleted from MSD_DEM_PRICE_LISTS');
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Rows Deleted from MSD_DEM_PRICE_LISTS');

                /* Step 1: Inserting rows into MSD_DEM_PRICE_LISTS from MSD_ST_PRICE_LIST */
                BEGIN
                        INSERT
                        INTO   MSD_DEM_PRICE_LISTS
                               (      PRICE_LIST_NAME  ,
                                      LAST_UPDATE_LOGIN,
                                      LAST_UPDATE_DATE ,
                                      LAST_UPDATED_BY  ,
                                      CREATION_DATE    ,
                                      CREATED_BY
                               )
                        SELECT DISTINCT PRICE_LIST_NAME,
                                        -1             ,
                                        SYSDATE        ,
                                        -1             ,
                                        SYSDATE        ,
                                        -1
                        FROM            MSC_ST_PRICE_LIST;

                        COMMIT;
                EXCEPTION
                WHEN OTHERS THEN
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows Inserted into MSD_DEM_PRICE_LISTS from MSD_ST_PRICE_LIS');
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END;
                SELECT COUNT(*)
                INTO   total_rows
                FROM   MSD_DEM_PRICE_LISTS;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Inserted ' || total_rows || 'rows into MSD_DEM_PRICE_LISTS from MSD_ST_PRICE_LIS');


               p_start_date := fnd_profile.value('MSC_E1APS_DEM_START_DATE_IN_MONTHS');
               p_end_date   := fnd_profile.value('MSC_E1APS_DEM_END_DATE_IN_MONTHS');

                IF total_rows              <>0 THEN
                        p_start_date       := fnd_date.date_to_canonical(ADD_MONTHS(SYSDATE, - p_start_date));
                        p_end_date         := fnd_date.date_to_canonical(ADD_MONTHS(SYSDATE, + p_end_date));
                        p_include_all      := 1;
                        p_include_prl_list := NULL;
                        p_exclude_prl_list := NULL;

                        v_request_id1      := fnd_request.submit_request('MSD',       -- appln short name
                                                                         'MSDDEMPRL', -- short name of conc pgm
                                                                         NULL,        -- description
                                                                         NULL,        -- start date
                                                                         FALSE,       -- sub request
                                                                         p_instance_id,
                                                                         p_start_date,
                                                                         p_end_date,
                                                                         p_include_all,
                                                                         p_include_prl_list,
                                                                         p_exclude_prl_list);
                        IF v_request_id1 = 0 THEN
                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error in submitting concurrent program for Demantra Price List Collection');
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        ELSE
                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Demantra Price List Launched. Request Id:'
                                || v_request_id1 );



                        END IF;
                END IF;
        END IF;
        /* Launching UOM Collections */
        IF p_uom                   = 1 THEN
                p_include_all     := 1;
                p_include_uom_list:= NULL;
                p_exclude_uom_list:= NULL;

                v_request_id2     := fnd_request.submit_request('MSD',        -- appln short name
                                                                'MSDDEMUOM',  -- short name of conc pgm
                                                                NULL,         -- description
                                                                NULL,         -- start date
                                                                FALSE,        -- sub request
                                                                p_instance_id,
                                                                p_include_all,
                                                                p_include_uom_list,
                                                                p_exclude_uom_list);
                IF v_request_id2 = 0 THEN
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error in submitting concurrent program for Demantra UOM Collection');
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                ELSE
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Demantra UOM Collection Launched. Request Id:'
                        || v_request_id2 );
                END IF;
        END IF;

        /* Launching ODI Post-Process Custom Hook Scenarios */
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL'); --Checking ODI Profile
        IF odi_url IS NOT NULL THEN

                select instance_code into l_instance_code
                from msc_apps_instances
                where instance_id = p_instance_id;

                 scenario_name    := 'POSTPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.COL_PRC_UOM;
                pre_process_odi   :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                 /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF pre_process_odi = FALSE THEN
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                    END IF;
        END IF;

        /* Launching Price List and UOM Post-Proces Custom Hook*/
        MSC_E1APS_HOOK.COL_PRC_UOM_POST_PROCESS(ERRBUF,RETCODE);

        IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
         END IF;

END DEM_PL_UOM;
/*  Procedure for Loading Sales History*/
PROCEDURE DEM_SH(ERRBUF OUT NOCOPY  VARCHAR2,
                 RETCODE OUT NOCOPY VARCHAR2,
                 p_instance_id IN      NUMBER,
                 p_auto_run IN      NUMBER )
IS
        lv_request_id1   NUMBER(20);
        p_file_seperator VARCHAR(1);
        p_control_path   VARCHAR2(100);
        p_data_path      VARCHAR2(100);
        p_file_name      VARCHAR2(20);
        ReturnStr        VARCHAR2(2000);
        odi_url          VARCHAR2(1000);
        fc_url           VARCHAR2(1000);
        l_call_status    BOOLEAN;
        l_phase          VARCHAR2(80);
        l_status         VARCHAR2(80);
        l_dev_phase      VARCHAR2(80);
        l_dev_status     VARCHAR2(80);
        l_message        VARCHAR2(2048);
        ret_value        BOOLEAN DEFAULT FALSE;
        ret_value1       BOOLEAN DEFAULT FALSE;
        source_file      VARCHAR2(200);
        destination_file VARCHAR2(200);
        fc_ret_value     BOOLEAN DEFAULT FALSE;
        scenario_name    VARCHAR2(200);
        scenario_version VARCHAR2(100);
        scenario_param   VARCHAR2(200);
        v_request_id     NUMBER;
        l_sql            VARCHAR2(100);
        ErrMessage VARCHAR2(1900);
        STARTINDEX INTEGER;
        pre_process_odi  BOOLEAN;
        post_process_odi BOOLEAN;
        l_instance_code VARCHAR2(3);


BEGIN

        /* Launching Sales History  Pre-Proces Custom Hook*/
        MSC_E1APS_HOOK.COL_PRC_UOM_PRE_PROCESS(ERRBUF,RETCODE);

         IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
         END IF;

        /*Checking ODI Profile */
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
        IF odi_url IS NOT NULL THEN
            /* Launching Pre-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code from msc_apps_instances
                where instance_id = p_instance_id;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.COL_SALES_HST;
                pre_process_odi   :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                 IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END IF;
        END IF;
        /* Truncating T_SRC_SALES_TMPL table */
        Begin
           l_sql:= 'Truncate table '
                    || MSD_DEM_DEMANTRA_UTILITIES.GET_DEMANTRA_SCHEMA
                    || '.T_SRC_SALES_TMPL';
           EXECUTE immediate l_sql;
         EXCEPTION
        WHEN OTHERS THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows Truncated from T_SRC_SALES_TMPL');
                RETCODE := MSC_UTIL.G_ERROR;
                RETURN;
        END;
        /*  Accessing instance_id from MSC_APPS_INSTANCES*/
        SELECT ATTRIBUTE13,
               ATTRIBUTE12,
               ATTRIBUTE13,
               ATTRIBUTE14
        INTO   p_data_path     ,
               p_control_path  ,
               destination_file,
               source_file
        FROM   MSC_APPS_INSTANCES
        WHERE  INSTANCE_ID = p_instance_id;

        BEGIN
                /* Step 1: Deleting all rows and extracting data from MSC_CALENDARS */
                DELETE
                FROM   MSD_DEM_CALENDARS;

                COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows Deleted from MSD_DEM_CALENDARS');
                RETCODE := MSC_UTIL.G_ERROR;
                RETURN;
        END;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Rows Deleted from MSD_DEM_CALENDARS');
        BEGIN
                INSERT
                INTO   MSD_DEM_CALENDARS
                       (
                              INSTANCE        ,
                              CALENDAR_TYPE   ,
                              CALENDAR_CODE   ,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY ,
                              CREATION_DATE   ,
                              CREATED_BY      ,
                              LAST_UPDATE_LOGIN
                       )
                SELECT MAI.INSTANCE_CODE  ,
                       'Manufacturing'    ,
                       MC.CALENDAR_CODE   ,
                       MC.LAST_UPDATE_DATE,
                       MC.LAST_UPDATED_BY ,
                       MC.CREATION_DATE   ,
                       MC.CREATED_BY      ,
                       MC.LAST_UPDATE_LOGIN
                FROM   MSC_CALENDARS MC,
                       MSC_APPS_INSTANCES MAI
                WHERE  MC.SR_INSTANCE_ID = p_instance_id
                   AND MAI.INSTANCE_ID   = MC.SR_INSTANCE_ID;

                COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows Inserted into MSD_DEM_CALENDARS from MSC_CALENDARS');
                RETCODE := MSC_UTIL.G_ERROR;
                RETURN;
        END;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Rows Inserted into MSD_DEM_CALENDARS from MSC_CALENDARS');
        /*ODI Initialize*/
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
        IF odi_url IS NOT NULL THEN
                BEGIN
                        SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(odi_url,2)
                        INTO   ReturnStr
                        FROM   dual;

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
                        RETURN;
                END IF;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');
         END IF;
        /*Calling 'MSC_E1APS_ODIScenarioExecute' Function by using the 'CALL_ODIEXE' function */
        scenario_name    := 'LOADE1SALESORDERHISTORYDATATODMPKG';
        scenario_version := '001';
        scenario_param   := '';
        ret_value        :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
        /* Copies the file from source path to destination Path */
        fc_url      := fnd_profile.value('MSC_E1APS_FCURL');

        IF fc_url IS NOT NULL AND ret_value THEN
                scenario_name    := 'IMPORTFILETOAPSSERVER';
                scenario_version := '001';
                scenario_param   := '';
                fc_ret_value     :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, fc_url);

                IF fc_ret_value THEN
                  /* Executing  Mail Scenario */
                    scenario_name    := 'MAIL';
                    scenario_version := '001';
                    scenario_param   := '';
                    ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copied Successfully .' );
                    fc_ret_value:=ret_value;

                ELSE
                    /* Executing  Mail Scenario */
                    scenario_name    := 'MAIL';
                    scenario_version := '001';
                    scenario_param   := '';
                    ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.' );
                    RETCODE := MSC_UTIL.G_ERROR;
                    RETURN;
                END IF;
          ELSE

                /* Executing  Mail Scenario */
                scenario_name    := 'MAIL';
                scenario_version := '001';
                scenario_param   := '';
                ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                fc_ret_value:=ret_value;
                IF ret_value =FALSE then
                  RETCODE := MSC_UTIL.G_ERROR;
                  RETURN;
                END IF;
        END IF;

        IF fc_ret_value THEN
                p_file_seperator := '/';
                p_file_name := 'DemHistory.dat';
                /* Step 3: Launching Demantra Collections */
                msd_dem_ssl_rs.run_rs(errbuf, retcode, p_instance_id, p_auto_run, p_file_seperator, p_control_path, p_data_path, p_file_name );
                IF NVL(to_number(retcode),0) <>0 THEN
                        msd_dem_common_utilities.log_message('Error Loading msd_dem_ssl_rs.run_rs Concurrent Request'
                        || errbuf
                        || retcode);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                ELSE
                        msd_dem_common_utilities.log_message('Demantra Collections Launched successfully');
                END IF;
                /*Launching CP for Calender */
                v_request_id := fnd_request.submit_request('MSD',      -- appln short name
                                                           'MSDDEMDC', -- short name of conc pgm
                                                            NULL,      -- description
                                                            NULL,      -- start date
                                                            FALSE,     -- sub request
                                                            1 );
                IF v_request_id = 0 THEN
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error in submitting concurrent program for Demantra Calenders Collection');
                         RETCODE := MSC_UTIL.G_ERROR;
                         RETURN;
                ELSE
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Demantra Calenders Collections Launched. Request Id:'
                        || v_request_id );
                END IF;
        END IF;

          /*Checking ODI Profile */
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
        IF odi_url IS NOT NULL THEN

              /* Launching Post-Process Custom Hook ODI Scenario */
                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.COL_SALES_HST;
                   post_process_odi :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF post_process_odi = FALSE THEN
                         /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                    ELSE
                         /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                    END IF;
         END IF;

         /* Launching Sales History  Post-Proces Custom Hook*/
         MSC_E1APS_HOOK.COL_PRC_UOM_POST_PROCESS(ERRBUF,RETCODE);

         IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
         ELSE
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Post Process Custom Hook Procedure Excecuted Successfully');
         END IF;

END DEM_SH;
/*Procedure for PTP Collections*/
PROCEDURE DEM_PTP(ERRBUF OUT NOCOPY  VARCHAR2,
                  RETCODE OUT NOCOPY VARCHAR2,
                  p_instance_id      IN      NUMBER,
                  p_list_price    IN      NUMBER,
                  p_item_cost     IN      NUMBER,
                  p_price_history IN      NUMBER)
IS
        ReturnStr        VARCHAR2(2000);
        WSURL            VARCHAR2(1000);
        l_call_status    BOOLEAN;
        l_phase          VARCHAR2(80);
        l_status         VARCHAR2(80);
        l_dev_phase      VARCHAR2(80);
        l_dev_status     VARCHAR2(80);
        l_message        VARCHAR2(2048);
        l_wf_lookup_code VARCHAR2(200);
        l_user_id        NUMBER;
        odi_url          VARCHAR2(300);
        fc_url           VARCHAR2(1000);
        ret_value        BOOLEAN;
        ret_value1       BOOLEAN;
        source_file      VARCHAR2(200);
        destination_file VARCHAR2(200);
        fc_ret_value     BOOLEAN;
        scenario_name    VARCHAR2(200);
        scenario_version VARCHAR2(100);
        scenario_param   VARCHAR2(200);
        process_id       VARCHAR2(10);
        ErrMessage VARCHAR2(1900);
        STARTINDEX INTEGER;
        l_instance_code VARCHAR2(3);
        pre_process_odi  BOOLEAN;
        post_process_odi BOOLEAN;
BEGIN

       /* Launching Collect PTP Pre-Proces Custom Hook*/
       MSC_E1APS_HOOK.COL_PTP_DATA_PRE_PROCESS(ERRBUF,RETCODE);

       IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
      END IF;

         /* Checking ODI Profile*/
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
         IF odi_url IS NOT NULL THEN
                /* Launching Pre-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code from msc_apps_instances
                where instance_id = p_instance_id;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.COL_PTP_DATA;
                pre_process_odi   :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                 IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END IF;
         END IF;


        /* Checking ODI Profile*/
        odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
        /* Invoke ODISenario*/
        IF odi_url IS NOT NULL THEN
                BEGIN
                        SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(odi_url,2)
                        INTO   ReturnStr
                        FROM   dual;

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
                        RETURN;
                END IF;
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');

               END IF;
        SELECT ATTRIBUTE14,
               ATTRIBUTE13
        INTO   source_file,
               destination_file
        FROM   MSC_APPS_INSTANCES
        WHERE  INSTANCE_ID = p_instance_id;

        /* Bug#8224935 - APP ID */
        l_user_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_PTP', 1, 'user_id'));
        /*Launching  LIST PRICE ODI Senario*/
        IF p_list_price = 1 THEN
                /*Calling 'MSC_E1APS_ODIScenarioExecute' Function by using the 'CALL_ODIEXE' function
                by passing the Senario name, version,parameter,odiurl */
                scenario_name    := 'LOADE1LISTPRICEDATATODMPKG';
                scenario_version := '001';
                scenario_param   := '';
                ret_value        :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

               /* Copies the file from source path to destination Path */
                fc_url      := fnd_profile.value('MSC_E1APS_FCURL');
                fc_ret_value:=TRUE;
              IF fc_url IS NOT NULL AND ret_value THEN
                        scenario_name    := 'IMPORTFILESTODEMANTRASERVER';
                        scenario_version := '001';
                        scenario_param   := '';
                        fc_ret_value     :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, fc_url);

                   IF fc_ret_value = FALSE THEN
                        /* Executing  Mail Scenario */
                      scenario_name    := 'MAIL';
                      scenario_version := '001';
                      scenario_param   := '';
                      ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.' );
                      RETCODE := MSC_UTIL.G_ERROR;
                      RETURN;
                  END IF;
             ELSE

                /* Executing  Mail Scenario */
                scenario_name    := 'MAIL';
                scenario_version := '001';
                scenario_param   := '';
                ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                  fc_ret_value:=ret_value;
                  IF ret_value =FALSE then
                    RETCODE := MSC_UTIL.G_ERROR;
                    RETURN;
                  END IF;
             END IF;

                IF fc_ret_value THEN
                        /* Calling LIST PRICE DEM WorkFlow*/
                        l_wf_lookup_code := 'WF_AIA_E1_PTP_PROMOPRICE_DWNLD';
                        MSC_E1APS_UTIL.DEM_WORKFLOW(errbuf, RETCODE,l_wf_lookup_code , process_id, l_user_id);
                        IF retcode= -1 OR process_id= -1 THEN
                                msd_dem_common_utilities.log_message('LIST PRICE DEM WORKFLOW NOT LAUNCHED. Process ID: ' || process_id);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        ELSE
                                msd_dem_common_utilities.log_message('LIST PRICE DEM WORKFLOW LAUNCHED. Process ID: ' || process_id);
                        END IF;
                END IF;
        END IF;
        /*Launching ITEM COST ODI Senario*/
        IF p_item_cost = 1 THEN
                /*Calling 'MSC_E1APS_ODIScenarioExecute' Function by using the 'CALL_ODIEXE' function
                by passing the Senario name, version,parameter,odiurl */
                scenario_name    := 'LOADE1ITEMCOSTDATATODMPKG';
                scenario_version := '001';
                scenario_param   := '';
                ret_value        :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                /* Copies the file from source path to destination Path */

                fc_url      := fnd_profile.value('MSC_E1APS_FCURL');
                fc_ret_value:=TRUE;
                IF fc_url IS NOT NULL AND ret_value THEN
                        scenario_name    := 'IMPORTFILESTODEMANTRASERVER';
                        scenario_version := '001';
                        scenario_param   := '';
                        fc_ret_value     :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, fc_url);

                        IF fc_ret_value   = FALSE THEN
                               /* Executing  Mail Scenario */
                              scenario_name    := 'MAIL';
                              scenario_version := '001';
                              scenario_param   := '';
                              ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.' );
                              RETCODE := MSC_UTIL.G_ERROR;
                              RETURN;
                        END IF;
                ELSE
                        /* Executing Mail Scenario*/
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                        fc_ret_value:=ret_value;
                         IF ret_value =FALSE then
                          RETCODE := MSC_UTIL.G_ERROR;
                          RETURN;
                        END IF;
                END IF;

                IF fc_ret_value THEN
                        /* Calling DEM WorkFlow*/
                        l_wf_lookup_code := 'WF_AIA_E1_PTP_PROMOCOST_DWNLD';
                        MSC_E1APS_UTIL.DEM_WORKFLOW(errbuf, RETCODE,l_wf_lookup_code , process_id, l_user_id);
                        IF retcode= -1 OR process_id= -1 THEN
                                msd_dem_common_utilities.log_message('ITEM COST DEM WORKFLOW NOT LAUNCHED.' || process_id);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        ELSE
                                msd_dem_common_utilities.log_message('ITEM COST DEM WORKFLOW LAUNCHED. Process ID: ' || process_id);
                        END IF;
                END IF;
        END IF;
        /*Launching PRICE HISTORY ODI Senario*/
        IF p_price_history = 1 THEN
                /*Calling 'MSC_E1APS_ODIScenarioExecute' Function by using the 'CALL_ODIEXE' function  */
                scenario_name    := 'LOADE1PRICEHISTORYDATATODMPKG';
                scenario_version := '001';
                scenario_param   := '';
                ret_value        :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                /* Copies the file from source path to destination Path */
                fc_url      := fnd_profile.value('MSC_E1APS_FCURL');
                fc_ret_value:=TRUE;
                IF fc_url IS NOT NULL AND ret_value THEN
                        scenario_name    := 'IMPORTFILESTODEMANTRASERVER';
                        scenario_version := '001';
                        scenario_param   := '';
                        fc_ret_value     :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, fc_url);
                        IF fc_ret_value   = FALSE THEN
                               /* Executing  Mail Scenario */
                              scenario_name    := 'MAIL';
                              scenario_version := '001';
                              scenario_param   := '';
                              ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.' );
                              RETCODE := MSC_UTIL.G_ERROR;
                              RETURN;
                        END IF;
                ELSE
                        /* Executing Mail Scenario*/
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                        fc_ret_value:=ret_value;
                        IF ret_value =FALSE then
                          RETCODE := MSC_UTIL.G_ERROR;
                          RETURN;
                        END IF;
                END IF;

                IF fc_ret_value THEN
                        /* Calling DEM WorkFlow*/
                        l_wf_lookup_code := 'WF_AIA_E1_PTP_PRICEHIST_DWNLD';
                        MSC_E1APS_UTIL.DEM_WORKFLOW(errbuf, RETCODE,l_wf_lookup_code , process_id, l_user_id);
                        IF retcode= -1 OR process_id= -1 THEN
                                msd_dem_common_utilities.log_message('PRICE HISTORY DEM WORKFLOW NOT LAUNCHED.Process ID: '   || process_id);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        ELSE
                                msd_dem_common_utilities.log_message('PRICE HISTORY DEM WORKFLOW LAUNCHED. Process ID: '   || process_id);
                        END IF;
                END IF;
        END IF;

        /* Launching Post-Process Custom Hook ODI Scenario */
                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.COL_PTP_DATA;

                   post_process_odi :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF post_process_odi = FALSE THEN
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                     ELSE
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                     END IF;
        /* Launching  Collect PTP Post-Proces Custom Hook*/
       MSC_E1APS_HOOK.COL_PTP_DATA_POST_PROCESS(ERRBUF,RETCODE);

       IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
         END IF;

END DEM_PTP;
/* Publish  Progrmas */
/*Publish Planiing Results*/
PROCEDURE PUB_PPR(ERRBUF OUT NOCOPY  VARCHAR2
                  ,RETCODE OUT NOCOPY VARCHAR2
                  ,p_instance_id IN      NUMBER
                  ,p_plan_id  IN      VARCHAR2
                  ,p_purchase_plan IN NUMBER
                 ,p_deployment_plan IN NUMBER
                 ,p_detailed_production_plan IN NUMBER ) AS

        /* Variables To Launch the ODI */
        scenario_name    VARCHAR2(200);
        scenario_version VARCHAR2(100);
        scenario_param   VARCHAR2(100);
        ReturnStr        VARCHAR2(2000);
        ret_value1       BOOLEAN ;
        ret_value2       BOOLEAN ;
        ret_value3       BOOLEAN ;
        ret_value4       BOOLEAN ;
        odi_url          VARCHAR2(300);
        ErrMessage VARCHAR2(1900);
        STARTINDEX INTEGER;
        l_instance_code VARCHAR2(3);
        pre_process_odi  BOOLEAN;
        post_process_odi BOOLEAN;
        BEGIN

        /* Launching  Publish Planning Results Pre-Proces Custom Hook*/
          MSC_E1APS_HOOK.PUB_PLAN_RES_PRE_PROCESS(ERRBUF,RETCODE);

          IF RETCODE = MSC_UTIL.G_ERROR THEN
             MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
             RETCODE := MSC_UTIL.G_ERROR;
             RETURN;
         END IF;

                /* Checking ODI Profile*/
            odi_url := fnd_profile.value('MSC_E1APS_ODIURL');

         IF odi_url IS NOT NULL THEN
               /* Launching Pre-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code from msc_apps_instances
                where instance_id = p_instance_id;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.PUB_PLAN_RES ;
                pre_process_odi   :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END IF;
         END IF;

                 --Adding plan_id to scenario parameter
                scenario_version  := '001';
                scenario_param    := 'E1TOAPSPROJECT.PVV_PLAN_ID=';
                scenario_param    := scenario_param
                                     || p_plan_id;

                /* Checking ODI Profile*/
                odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
                /* Invoke ODISenario*/
                IF odi_url IS NOT NULL THEN
                        BEGIN
                                SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(odi_url,2)
                                INTO   ReturnStr
                                FROM   dual;

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
                                RETURN;
                        END IF;
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');

           END IF;

                /* Executing PurchasePlan ODI Scenarios */
                IF p_purchase_plan = MSC_UTIL.SYS_YES THEN
                    scenario_name:='LOADAPSPURCHASEPLANDATATOE1PKG';
                    ret_value1   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                END IF;

                IF  p_deployment_plan = MSC_UTIL.SYS_YES  THEN
                        scenario_name:='LOADAPSDEPLOYMENTPLANDATATOE1PKG';
                        ret_value2   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                END IF;
                IF p_detailed_production_plan = MSC_UTIL.SYS_YES THEN
                        scenario_name:='LOADAPSDETAILEDPRODPLANDATATOE1PKG';
                       ret_value3   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                END IF;

                 IF ret_value3 = false OR ret_value2 = false OR ret_value1 = false THEN
                        scenario_name :='MAIL';
                        scenario_param:='';
                        ret_value4   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                  END IF;

                IF ret_value3 OR ret_value2 OR ret_value1 THEN
                   /* Launching Post-Process Custom Hook ODI Scenario */
                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.PUB_PLAN_RES ;
                   post_process_odi :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF post_process_odi = FALSE THEN
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                     ELSE
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                    END IF;
                ELSE
                scenario_name :='MAIL';
                scenario_param:='';
                ret_value4   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                RETCODE := MSC_UTIL.G_ERROR;
                RETURN;
            END IF;

           /* Launching  Publish Planning Results Post-Proces Custom Hook*/
                MSC_E1APS_HOOK.PUB_PLAN_RES_POST_PROCESS(ERRBUF,RETCODE);

                IF RETCODE = MSC_UTIL.G_ERROR THEN
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                   RETCODE := MSC_UTIL.G_ERROR;
                   RETURN;
               END IF;

             END PUB_PPR;
        /* Procedure for Publish Forecast Source Systems */
PROCEDURE DEM_PUB_FSS(ERRBUF OUT NOCOPY  VARCHAR2,
                      RETCODE OUT NOCOPY VARCHAR2,
                      p_instance_id IN      NUMBER ) AS
        /* Variables To Launch the ODI */
        l_wf_lookup_code VARCHAR2(200);
        scenario_name    VARCHAR2(200);
        scenario_param   VARCHAR2(100);
        scenario_version VARCHAR2(100);
        l_user_id        NUMBER;
        ret_value        NUMBER;
        ret_value1       BOOLEAN;
        odi_url          VARCHAR2(1000);
        l_instance_code  VARCHAR2(3);
        pre_process_odi  BOOLEAN;
        post_process_odi BOOLEAN;
        g_demantra_schema VARCHAR2(50):=null;
        g_data_profile_id 	number :=null;
        g_filter_id			number :=null;
        g_member_id			number :=null;
        x_sql			      varchar2(500) :=null;
        x_org_sql			  varchar2(500) :=null;
        TYPE REF_CURSOR_TYPE IS REF CURSOR;
        c_org	REF_CURSOR_TYPE;
        ErrMessage VARCHAR2(1900);
        ReturnStr  VARCHAR2(2000);
        STARTINDEX INTEGER;


        BEGIN

                 /* Launching  Publish Forecast Pre-Proces Custom Hook*/
                 MSC_E1APS_HOOK.PUB_FCST_PRE_PROCESS(ERRBUF,RETCODE);

                 IF RETCODE = MSC_UTIL.G_ERROR THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                     RETCODE := MSC_UTIL.G_ERROR;
                     RETURN;
                 END IF;

                /* Checking ODI Profile*/
            odi_url := fnd_profile.value('MSC_E1APS_ODIURL');

         IF odi_url IS NOT NULL THEN
               /* Launching Pre-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code from msc_apps_instances
                where instance_id = p_instance_id;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.PUB_FCST ;
                pre_process_odi   :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                END IF;
         END IF;
                g_demantra_schema:=MSD_DEM_DEMANTRA_UTILITIES.GET_DEMANTRA_SCHEMA;
                x_org_sql := 'select t_ep_organization_ep_id from ' || g_demantra_schema
                        			||'.t_ep_organization where organization IN ( select organization_code from msc_trading_partners '
                        			||'where sr_instance_id = ' || p_instance_id|| ' and partner_type=3) order by t_ep_organization_ep_id' ;

                x_sql := 'select id from '|| g_demantra_schema ||'.TRANSFER_QUERY where query_name like ''AIA-Forecast data''';
                execute immediate x_sql into g_data_profile_id ;

                x_sql := 'select filter_id from '|| g_demantra_schema ||'.transfer_query_filters where id = ' || g_data_profile_id ;
                execute immediate x_sql into g_filter_id ;

                x_sql := 'Delete from ' || g_demantra_schema ||'.transfer_query_filter_m where filter_id = ' || g_filter_id ;
                execute immediate x_sql ;
                commit;

                open c_org for x_org_sql;
                loop
                FETCH c_org INTO g_member_id;
                exit when c_org%notfound;
                x_sql := 'INSERT INTO ' || g_demantra_schema ||'.transfer_query_filter_m VALUES('||g_filter_id ||','||g_member_id || ')';
                execute immediate x_sql ;
                end loop;
                close c_org;
                commit;

                x_sql := 'Begin ' || g_demantra_schema || '.API_NOTIFY_APS_INTEGRATION(' ||g_data_profile_id|| '); End; ';
                execute immediate x_sql ;
                commit;

               /* Bug#8224935 - APP ID */
                l_user_id        := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_DM', 1, 'user_id'));
                l_wf_lookup_code := 'WF_AIA_FORECAST_EXPORT';
                scenario_name    := 'LOADDMFORECASTDATATOE1PKG';

                --Bug8740081
                /*ODI Initializing */
                       /*  Checking ODI Profile*/
                        odi_url := fnd_profile.value('MSC_E1APS_ODIURL');

                        /* Invoke ODISenario */
                        IF odi_url IS NOT NULL THEN
                                BEGIN
                                        SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(odi_url,2)
                                        INTO   ReturnStr
                                        FROM   dual;

                                EXCEPTION
                                WHEN OTHERS THEN
                                   select instr(ReturnStr,'#') into StartIndex from dual;
				                           select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;

                                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
                                   RETCODE := MSC_UTIL.G_ERROR;
                                   RETURN ;
                                END;

                                IF(length(ErrMessage) > 0) THEN
                                         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
                                         RETCODE := MSC_UTIL.G_ERROR;
                                         RETURN;
                                END IF;
                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');

                         END IF;

                /* Launching Demantra Workflow using function PUBLISH_DEM_WORKFLOW*/
                ret_value:=MSC_E1APS_UTIL.PUBLISH_DEM_WORKFLOW(ERRBUF, RETCODE, p_instance_id, l_wf_lookup_code , scenario_name,l_user_id );
                IF ret_value = MSC_E1APS_UTIL.DEM_SUCCESS THEN
                  /* Launching Post-Process Custom Hook ODI Scenario */
                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.PUB_PLAN_RES ;
                   post_process_odi :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF post_process_odi = FALSE THEN
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                     ELSE
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                    END IF;
                ELSIF ret_value = MSC_E1APS_UTIL.DEM_FAILURE THEN
                        scenario_name :='MAIL';
                        scenario_param:='';
                        ret_value1   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;

                ELSIF ret_value = MSC_E1APS_UTIL.DEM_WARNING THEN
                      scenario_name :='MAIL';
                      scenario_param:='';
                      ret_value1   :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                      RETCODE := MSC_UTIL.G_WARNING;
                      RETURN;
               END IF;

                /* Launching  Publish Forecast Post-Proces Custom Hook*/
                MSC_E1APS_HOOK.PUB_FCST_POST_PROCESS(ERRBUF,RETCODE);

                IF RETCODE = MSC_UTIL.G_ERROR THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                     RETCODE := MSC_UTIL.G_ERROR;
                     RETURN;
                END IF;
      END DEM_PUB_FSS;

              /*Procedure for Publish PTP*/
PROCEDURE DEM_PUB_PTP(ERRBUF OUT NOCOPY  VARCHAR2 ,
                      RETCODE OUT NOCOPY VARCHAR2 ,
                      p_instance_id IN      NUMBER ) AS
        /* Variables To Launch the ODI */
        l_user_id        NUMBER;
        fc_ret_value     BOOLEAN;
        ret_value        BOOLEAN;
        ret_value1       BOOLEAN;
        ret_value2       Number;
        l_wf_lookup_code VARCHAR2(200);
        odi_url          VARCHAR2(1000);
        fc_url           VARCHAR2(1000);
        ReturnStr        VARCHAR2(2000);
        scenario_name    VARCHAR2(200);
        scenario_version VARCHAR2(100):='001';
        scenario_param   VARCHAR2(100);
        ErrMessage VARCHAR2(1900);
        STARTINDEX INTEGER;
        l_instance_code VARCHAR2(3);
        pre_process_odi  BOOLEAN;
        post_process_odi BOOLEAN;


        BEGIN
                /* Launching  Publish PTP Pre-Proces Custom Hook*/
                 MSC_E1APS_HOOK.PUB_PTP_RES_PRE_PROCESS(ERRBUF,RETCODE);

                 IF RETCODE = MSC_UTIL.G_ERROR THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                     RETCODE := MSC_UTIL.G_ERROR;
                     RETURN;
                 END IF;

                 /* Checking ODI Profile*/
            odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
           IF odi_url IS NOT NULL THEN
              /* Launching Pre-Process Custom Hook ODI Scenario */
                select instance_code into l_instance_code
                from msc_apps_instances
                where instance_id = p_instance_id;

                scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                scenario_param   := scenario_param
                                    ||l_instance_code
                                    || ':'
                                    || MSC_E1APS_UTIL.PUB_PTP_RES;

                pre_process_odi   :=CALL_ODIEXE('PREPROCESSHOOKPKG',
                                                scenario_version,
                                                scenario_param,
                                                odi_url);

                IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_version := '001';
                        ret_value1       :=CALL_ODIEXE('MAIL',scenario_version,'', odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN ;
                END IF;
           END IF;

           /* Bug#8224935 - APP ID */
                l_user_id        := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_PTP', 1, 'user_id'));
                l_wf_lookup_code := 'WF_AIA_PTP_E1_UPLD_PROM_PRIC';
                scenario_name    := 'LOADDMPROMOTIONPRICINGDATATOE1PKG';

                --Bug8740081
                  /* ODI Initialization  */

                /* Checking ODI Profile*/
                odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
                /* Invoke ODISenario*/
                IF odi_url IS NOT NULL THEN
                        BEGIN
                                SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(odi_url,2)
                                INTO   ReturnStr
                                FROM   dual;

                        EXCEPTION
                        WHEN OTHERS THEN
                          select instr(ReturnStr,'#') into StartIndex from dual;
				                  select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;

                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        END;
                       IF(length(ErrMessage) > 0) THEN
                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        END IF;
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');

           END IF;

                /* Launching Demantra Workflow using function PUBLISH_DEM_WORKFLOW*/
                ret_value2:= MSC_E1APS_UTIL.PUBLISH_DEM_WORKFLOW(ERRBUF ,RETCODE ,p_instance_id,l_wf_lookup_code ,scenario_name,l_user_id );


                IF ret_value2 = MSC_E1APS_UTIL.DEM_FAILURE THEN
                   scenario_name := 'MAIL';
                   scenario_version := '001';
                   scenario_param   := '';
                   ret_value1    :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                   RETCODE := MSC_UTIL.G_ERROR;
                   RETURN;
                END IF;

                 IF ret_value2 = MSC_E1APS_UTIL.DEM_WARNING THEN
                   scenario_name := 'MAIL';
                   scenario_version := '001';
                   scenario_param   := '';
                   ret_value1    :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                   RETCODE := MSC_UTIL.G_WARNING;
                   RETURN;
                 END IF;


                /* Copies the file from  Demantra Server  To E1_file_DS
                fc_url      := fnd_profile.value('MSC_E1APS_FCURL');
                fc_ret_value:=FALSE;
                IF fc_url IS NOT NULL THEN
                        scenario_version := '001';
                        scenario_param   := '';
                        fc_ret_value   :=CALL_ODIEXE('EXPORTFILESFROMDEMANTRASERVER' ,scenario_version ,scenario_param ,fc_url);

                        IF fc_ret_value = FALSE THEN
                           scenario_name := 'MAIL';
                           scenario_version := '001';
                           scenario_param   := '';
                           ret_value1    :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                           MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.' );
                           RETCODE := MSC_UTIL.G_ERROR;
                           RETURN;
                        END IF;
                END IF; */
                ret_value     := FALSE;
                scenario_name := 'LOADDMDELETEPROMOPRICINGDATATOE1PKG';
                IF ret_value2 = MSC_E1APS_UTIL.DEM_SUCCESS THEN
                        ret_value:=CALL_ODIEXE(scenario_name ,'001','',odi_url);
                END IF;

                IF ret_value THEN
                      /* Launching Post-Process Custom Hook ODI Scenario */

                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.PUB_PTP_RES;

                   post_process_odi :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF post_process_odi = FALSE THEN
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                     ELSE
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                    END IF;
                ELSE
                   scenario_name := 'MAIL';
                   scenario_param := '';
                   scenario_version := '001';
                   ret_value1    :=CALL_ODIEXE(scenario_name ,scenario_version,scenario_param ,odi_url);
                   RETCODE := MSC_UTIL.G_ERROR;
                   RETURN;
                END IF;

               /* Launching  Publish PTP Post-Proces Custom Hook*/
                 MSC_E1APS_HOOK.PUB_PTP_RES_PRE_PROCESS(ERRBUF,RETCODE);

                 IF RETCODE = MSC_UTIL.G_ERROR THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                     RETCODE := MSC_UTIL.G_ERROR;
                     RETURN;
                 END IF;

        END DEM_PUB_PTP;
        /*Procedure for Publish DSM*/
PROCEDURE DEM_PUB_DSM(ERRBUF OUT NOCOPY  VARCHAR2 ,
                      RETCODE OUT NOCOPY VARCHAR2 ,
                      p_instance_id       IN      NUMBER ,
                      p_pb_claims      IN      NUMBER ,
                      p_pb_dedu_dispos IN      NUMBER) AS
        /* Variables To Launch the ODI */
        l_user_id        NUMBER;
        l_wf_lookup_code VARCHAR2(200);
        ret_value        Number;
        ret_value1       Boolean;
        odi_url          VARCHAR2(1000);
        scenario_name    VARCHAR2(200);
        scenario_version VARCHAR2(100):='001';
        scenario_param   VARCHAR2(100);
        l_instance_code VARCHAR2(3);
        pre_process_odi  BOOLEAN;
        post_process_odi BOOLEAN;
        ErrMessage VARCHAR2(1900);
        ReturnStr  VARCHAR2(2000);
        STARTINDEX INTEGER;

        BEGIN

                /* Launching  Publish DSM Pre-Proces Custom Hook*/
                 MSC_E1APS_HOOK.PUB_DSM_RES_PRE_PROCESS(ERRBUF,RETCODE);

                 IF RETCODE = MSC_UTIL.G_ERROR THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                     RETCODE := MSC_UTIL.G_ERROR;
                     RETURN;
                 END IF;

              /* Checking ODI Profile*/
            odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
           IF odi_url IS NOT NULL THEN
               /* Updating ODI Pre-Process custom hook scenario_param */
                select instance_code into l_instance_code
                from msc_apps_instances
                where instance_id = p_instance_id;

                scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                scenario_param   := scenario_param
                                    ||l_instance_code
                                    || ':'
                                    || MSC_E1APS_UTIL.PUB_DSM_RES;
                pre_process_odi   :=CALL_ODIEXE('PREPROCESSHOOKPKG',
                                                scenario_version,
                                                scenario_param,
                                                odi_url);

                IF pre_process_odi = FALSE THEN
                      /* Executing  Mail Scenario */
                        scenario_version := '001';
                        ret_value1       :=CALL_ODIEXE('MAIL',scenario_version,'', odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN ;
                END IF;
           END IF;

                --Bug8740081
                --Bug8740081
                /*ODI Initialization*/
                 /* Checking ODI Profile*/
                odi_url := fnd_profile.value('MSC_E1APS_ODIURL');
                /* Invoke ODISenario*/
                IF odi_url IS NOT NULL THEN
                        BEGIN
                                SELECT MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(odi_url,2)
                                INTO   ReturnStr
                                FROM   dual;

                        EXCEPTION
                        WHEN OTHERS THEN
                          select instr(ReturnStr,'#') into StartIndex from dual;
				                  select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;

                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        END;
                       IF(length(ErrMessage) > 0) THEN
                                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error message' || ErrMessage);
                                RETCODE := MSC_UTIL.G_ERROR;
                                RETURN;
                        END IF;
                        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');

           END IF;

                /* Bug#8224935 - APP ID */
                l_user_id                := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_PTP', 1, 'user_id'));
                IF p_pb_claims            = MSC_UTIL.SYS_YES THEN
                        l_wf_lookup_code := 'WF_AIA_DSM_E1_CLAIM_EXP';
                        scenario_name    := 'LOADDMCLAIMDATATOE1PKG';
                    ret_value:=MSC_E1APS_UTIL.PUBLISH_DEM_WORKFLOW(ERRBUF ,RETCODE ,p_instance_id ,l_wf_lookup_code ,scenario_name,l_user_id);

                    IF ret_value = MSC_E1APS_UTIL.DEM_FAILURE THEN
                       RETCODE := MSC_UTIL.G_ERROR;
                       RETURN;
                    END IF;

                    IF ret_value = MSC_E1APS_UTIL.DEM_WARNING THEN
                       RETCODE := MSC_UTIL.G_WARNING;
                       RETURN;
                    END IF;
                END IF;

                IF p_pb_dedu_dispos       = MSC_UTIL.SYS_YES THEN
                        l_wf_lookup_code := 'WF_AIA_DSM_E1_DEDUCT_EXP';
                        scenario_name    := 'LOADDMDEDDISPOSITIONSDATATOE1PKG';
                        ret_value:=MSC_E1APS_UTIL.PUBLISH_DEM_WORKFLOW(ERRBUF ,RETCODE ,p_instance_id ,l_wf_lookup_code ,scenario_name ,l_user_id);

                    IF ret_value = MSC_E1APS_UTIL.DEM_FAILURE THEN
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                       RETCODE := MSC_UTIL.G_ERROR;
                       RETURN;
                    END IF;

                    IF ret_value = MSC_E1APS_UTIL.DEM_WARNING THEN
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                       RETCODE := MSC_UTIL.G_WARNING;
                       RETURN;
                    END IF;
                END IF;

              IF ret_value = MSC_E1APS_UTIL.DEM_SUCCESS THEN
                  /* Launching Post-Process Custom Hook ODI Scenario */
                   scenario_name    := 'POSTPROCESSHOOKPKG';
                   scenario_version := '001';
                   scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                   scenario_param   := scenario_param
                                       ||l_instance_code
                                       || ':'
                                       || MSC_E1APS_UTIL.PUB_PLAN_RES ;
                   post_process_odi :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);

                    IF post_process_odi = FALSE THEN
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                        RETCODE := MSC_UTIL.G_ERROR;
                        RETURN;
                     ELSE
                        /* Executing  Mail Scenario */
                        scenario_name    := 'MAIL';
                        scenario_version := '001';
                        scenario_param   := '';
                        ret_value1       :=CALL_ODIEXE(scenario_name, scenario_version, scenario_param, odi_url);
                    END IF;
                ELSE
                scenario_name :='MAIL';
                scenario_param:='';
                ret_value1  :=CALL_ODIEXE(scenario_name ,scenario_version ,scenario_param ,odi_url);
                RETCODE := MSC_UTIL.G_ERROR;
                RETURN;
            END IF;

                /* Launching  Publish DSM Post-Proces Custom Hook*/
                 MSC_E1APS_HOOK.PUB_DSM_RES_PRE_PROCESS(ERRBUF,RETCODE);

                 IF RETCODE = MSC_UTIL.G_ERROR THEN
                     MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                     RETCODE := MSC_UTIL.G_ERROR;
                     RETURN;
                 END IF;

        END DEM_PUB_DSM;
END MSC_E1APS_DEMCL;

/
