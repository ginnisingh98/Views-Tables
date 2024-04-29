--------------------------------------------------------
--  DDL for Package Body MSC_E1APS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_E1APS_UTIL" AS -- body
                --# $Header: MSCE1ULB.pls 120.1.12010000.16 2009/08/26 13:15:26 nyellank noship $
        FUNCTION MSC_E1APS_ODIScenarioExecute ( ScenarioName    IN VARCHAR2,
                                                ScenarioVersion IN VARCHAR2,
                                                ScenarioParam   IN VARCHAR2,
                                                WsUrl           IN VARCHAR2 )
                RETURN       VARCHAR2 AS soap_request VARCHAR2(30000);
                soap_respond VARCHAR2(30000);
                http_req utl_http.req;
                http_resp utl_http.resp;
                StartIndex INTEGER;
                EndIndex   INTEGER;
                returnStr  VARCHAR2(2000);
                Time_Out   INTEGER;
                BEGIN
                        soap_request:= '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://odiws.msc.com/">'
                        || '<env:Body>'
                        || '<ns0:ExecuteScenario>'
                        || '<ns0:ScenarioName>'
                        ||ScenarioName
                        ||'</ns0:ScenarioName>'
                        || '<ns0:ScenarioVersion>'
                        ||ScenarioVersion
                        ||'</ns0:ScenarioVersion>'
                        || '<ns0:ODIParameter>'
                        ||ScenarioParam
                        ||'</ns0:ODIParameter>'
                        || '</ns0:ExecuteScenario>'
                        || '</env:Body>'
                        ||'</env:Envelope>';

                        Time_Out := fnd_profile.value('MSC:E1APS_WS_TIME_OUT');
                        UTL_HTTP.set_transfer_timeout(Time_Out);
                       -- UTL_HTTP.set_transfer_timeout(36000);

                        http_req:= utl_http.begin_request ( WsUrl, 'POST', 'HTTP/1.1' );
                        utl_http.set_header(http_req, 'Content-Type', 'text/xml');
                        utl_http.set_header(http_req, 'Content-Length', LENGTH(soap_request));
                        utl_http.set_header(http_req, 'SOAPAction', '');
                        utl_http.write_text(http_req, soap_request);
                        http_resp:= utl_http.get_response(http_req);
                        utl_http.read_text(http_resp, soap_respond);
                        utl_http.end_response(http_resp);
                        SELECT instr(soap_respond,'<ns0:return>')
                        INTO   StartIndex
                        FROM   dual;

                        SELECT instr(soap_respond,'</ns0:return>')
                        INTO   EndIndex
                        FROM   dual;

                        SELECT SUBSTR(soap_respond,StartIndex+12,EndIndex-(StartIndex+12))
                        INTO   returnStr
                        FROM   dual;

                        RETURN returnStr;
                EXCEPTION
                WHEN OTHERS THEN
                        returnStr:= '-1#Error in execution of ODI Scenario:'
                        ||ScenarioName
                        ||'. Please check Application Server Log.';
                        RETURN returnStr;
                END MSC_E1APS_ODIScenarioExecute;
        FUNCTION MSC_E1APS_ODIInitialize ( WsUrl IN VARCHAR2,
                                           BaseDate INTEGER )
                RETURN       VARCHAR2 AS soap_request VARCHAR2(30000);
                soap_respond VARCHAR2(30000);
                http_req utl_http.req;
                http_resp utl_http.resp;
                StartIndex     INTEGER;
                EndIndex       INTEGER;
                SessionNum     VARCHAR2(10);
                ErrMessage     VARCHAR2(1900);
                ErrLength      INTEGER;
                returnStr      VARCHAR2(2000);
                finalreturnStr VARCHAR2(5000);
                Time_Out   INTEGER;
                BEGIN
                        finalreturnStr:=NULL;
                        /*SYNCHRONIZE_XML*/
                        BEGIN
                                soap_request:= '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://odiws.msc.com/">'
                                || '<env:Body>'
                                || '<ns0:ExecuteScenario>'
                                || '<ns0:ScenarioName>SYNCHRONIZE_XML</ns0:ScenarioName>'
                                || '<ns0:ScenarioVersion>001</ns0:ScenarioVersion>'
                                || '<ns0:ODIParameter></ns0:ODIParameter>'
                                || '</ns0:ExecuteScenario>'
                                || '</env:Body>'
                                ||'</env:Envelope>';

                                Time_Out := fnd_profile.value('MSC:E1APS_WS_TIME_OUT');
                                UTL_HTTP.set_transfer_timeout(Time_Out);
                               -- UTL_HTTP.set_transfer_timeout(36000);
                                http_req:= utl_http.begin_request ( WsUrl, 'POST', 'HTTP/1.1' );
                                utl_http.set_header(http_req, 'Content-Type', 'text/xml');
                                utl_http.set_header(http_req, 'Content-Length', LENGTH(soap_request));
                                utl_http.set_header(http_req, 'SOAPAction', '');
                                utl_http.write_text(http_req, soap_request);
                                http_resp:= utl_http.get_response(http_req);
                                utl_http.read_text(http_resp, soap_respond);
                                utl_http.end_response(http_resp);
                                SELECT instr(soap_respond,'<ns0:return>')
                                INTO   StartIndex
                                FROM   dual;

                                SELECT instr(soap_respond,'</ns0:return>')
                                INTO   EndIndex
                                FROM   dual;

                                SELECT SUBSTR(soap_respond,StartIndex+12,EndIndex-(StartIndex+12))
                                INTO   returnStr
                                FROM   dual;

                                SELECT instr(returnStr,'#')
                                INTO   StartIndex
                                FROM   dual;

                                SELECT SUBSTR(returnStr,0,StartIndex-1)
                                INTO   SessionNum
                                FROM   dual;

                                SELECT SUBSTR(returnStr,StartIndex+1,1800)
                                INTO   ErrMessage
                                FROM   dual;

                                IF SessionNum          = '-1' THEN
                                        finalreturnStr:= 'ODI Scenario:'
                                        ||'SYNCHRONIZE_XML'
                                        ||'#ODI Session No.#Error Message='
                                        ||returnStr;
                                        RETURN finalreturnStr;
                                END IF;
                                IF SessionNum         <> '-1' AND LENGTH(ErrMessage) > 0 THEN
                                        finalreturnStr:= 'ODI Scenario:'
                                        ||'SYNCHRONIZE_XML'
                                        ||'#ODI Session No.#Error Message='
                                        ||returnStr;
                                        RETURN finalreturnStr;
                                END IF;
                        EXCEPTION
                        WHEN OTHERS THEN
                                finalreturnStr:= 'ODI Scenario:'
                                ||'SYNCHRONIZE_XML'
                                ||'#ODI Session No.#Error Message=-1#Error in invoking Web Service. Please check Application Server Log.';
                                RETURN finalreturnStr;
                        END;

                        /*LOADPARAMETERSDATATOWORKREPPKG*/
                        BEGIN
                                soap_request:= '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://odiws.msc.com/">'
                                || '<env:Body>'
                                || '<ns0:ExecuteScenario>'
                                || '<ns0:ScenarioName>LOADPARAMETERSDATATOWORKREPPKG</ns0:ScenarioName>'
                                || '<ns0:ScenarioVersion>001</ns0:ScenarioVersion>'
                                || '<ns0:ODIParameter></ns0:ODIParameter>'
                                || '</ns0:ExecuteScenario>'
                                || '</env:Body>'
                                ||'</env:Envelope>';

                                Time_Out := fnd_profile.value('MSC:E1APS_WS_TIME_OUT');
                                UTL_HTTP.set_transfer_timeout(Time_Out);
                               -- UTL_HTTP.set_transfer_timeout(36000);
                                http_req:= utl_http.begin_request ( WsUrl, 'POST', 'HTTP/1.1' );
                                utl_http.set_header(http_req, 'Content-Type', 'text/xml');
                                utl_http.set_header(http_req, 'Content-Length', LENGTH(soap_request));
                                utl_http.set_header(http_req, 'SOAPAction', '');
                                utl_http.write_text(http_req, soap_request);
                                http_resp:= utl_http.get_response(http_req);
                                utl_http.read_text(http_resp, soap_respond);
                                utl_http.end_response(http_resp);
                                SELECT instr(soap_respond,'<ns0:return>')
                                INTO   StartIndex
                                FROM   dual;

                                SELECT instr(soap_respond,'</ns0:return>')
                                INTO   EndIndex
                                FROM   dual;

                                SELECT SUBSTR(soap_respond,StartIndex+12,EndIndex-(StartIndex+12))
                                INTO   returnStr
                                FROM   dual;

                                SELECT instr(returnStr,'#')
                                INTO   StartIndex
                                FROM   dual;

                                SELECT SUBSTR(returnStr,0,StartIndex-1)
                                INTO   SessionNum
                                FROM   dual;

                                SELECT SUBSTR(returnStr,StartIndex+1,1800)
                                INTO   ErrMessage
                                FROM   dual;

                                IF SessionNum          = '-1' THEN
                                        finalreturnStr:= 'ODI Scenario:'
                                        ||'LOADPARAMETERSDATATOWORKREPPKG'
                                        ||'#ODI Session No.#Error Message='
                                        ||returnStr;
                                        RETURN finalreturnStr;
                                END IF;
                                IF SessionNum         <> '-1' AND LENGTH(ErrMessage) > 0 THEN
                                        finalreturnStr:= 'ODI Scenario:'
                                        ||'LOADPARAMETERSDATATOWORKREPPKG'
                                        ||'#ODI Session No.#Error Message='
                                        ||returnStr;
                                        RETURN finalreturnStr;
                                END IF;
                        EXCEPTION
                        WHEN OTHERS THEN
                                finalreturnStr:= 'ODI Scenario:'
                                ||'LOADPARAMETERSDATATOWORKREPPKG'
                                ||'#ODI Session No.#Error Message=-1#Error in execution of ODI scenario. Please check Application Server Log.';
                                RETURN finalreturnStr;
                        END;

                        /*UPDATEVARIABLE*/
                        BEGIN
                                soap_request:= '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://odiws.msc.com/">'
                                || '<env:Body>'
                                || '<ns0:ExecuteScenario>'
                                || '<ns0:ScenarioName>UPDATEVARIABLE</ns0:ScenarioName>'
                                || '<ns0:ScenarioVersion>001</ns0:ScenarioVersion>'
                                || '<ns0:ODIParameter>E1TOAPSPROJECT.PVD_BASE_DATE='||BaseDate ||'</ns0:ODIParameter>'
                                || '</ns0:ExecuteScenario>'
                                || '</env:Body>'
                                ||'</env:Envelope>';
                                UTL_HTTP.set_transfer_timeout(36000);
                                http_req:= utl_http.begin_request ( WsUrl, 'POST', 'HTTP/1.1' );
                                utl_http.set_header(http_req, 'Content-Type', 'text/xml');
                                utl_http.set_header(http_req, 'Content-Length', LENGTH(soap_request));
                                utl_http.set_header(http_req, 'SOAPAction', '');
                                utl_http.write_text(http_req, soap_request);
                                http_resp:= utl_http.get_response(http_req);
                                utl_http.read_text(http_resp, soap_respond);
                                utl_http.end_response(http_resp);
                                SELECT instr(soap_respond,'<ns0:return>')
                                INTO   StartIndex
                                FROM   dual;

                                SELECT instr(soap_respond,'</ns0:return>')
                                INTO   EndIndex
                                FROM   dual;

                                SELECT SUBSTR(soap_respond,StartIndex+12,EndIndex-(StartIndex+12))
                                INTO   returnStr
                                FROM   dual;

                                SELECT instr(returnStr,'#')
                                INTO   StartIndex
                                FROM   dual;

                                SELECT SUBSTR(returnStr,0,StartIndex-1)
                                INTO   SessionNum
                                FROM   dual;

                                SELECT SUBSTR(returnStr,StartIndex+1,1800)
                                INTO   ErrMessage
                                FROM   dual;

                                IF SessionNum          = '-1' THEN
                                        finalreturnStr:= 'ODI Scenario:'
                                        ||'UPDATEVARIABLE'
                                        ||'#ODI Session No.#Error Message='
                                        ||returnStr;
                                        RETURN finalreturnStr;
                                END IF;
                                IF SessionNum         <> '-1' AND LENGTH(ErrMessage) > 0 THEN
                                        finalreturnStr:= 'ODI Scenario:'
                                        ||'UPDATEVARIABLE'
                                        ||'#ODI Session No.#Error Message='
                                        ||returnStr;
                                        RETURN finalreturnStr;
                                END IF;
                        EXCEPTION
                        WHEN OTHERS THEN
                                finalreturnStr:= 'ODI Scenario:'
                                ||'UPDATEVARIABLE'
                                ||'#ODI Session No.#Error Message=-1#Error in execution of ODI Scenario. Please check Application Server Log.';
                                RETURN finalreturnStr;
                        END;

                        RETURN finalreturnStr;
                END MSC_E1APS_ODIInitialize ;
                /* Procedure to call Demantra WorkFlow */
        PROCEDURE DEM_WORKFLOW(errbuf OUT NOCOPY     VARCHAR2,
                               retcode OUT NOCOPY    VARCHAR2,
                               l_wf_lookup_code IN   VARCHAR2,
                               process_id OUT NOCOPY VARCHAR2,
                               p_user_id IN          NUMBER )
        IS
                /* Variables to Launch Dem WorkFlow */
                l_sql       VARCHAR2(1000);
                DEM_SCHEMA  VARCHAR2(100);
                l_url       VARCHAR2(1000);
                l_dummy     VARCHAR2(100);
                l_user_name VARCHAR2(30);
                l_password  VARCHAR2(30);
                l_user_id   NUMBER;
                -- Bug#7199587    syenamar
                l_schema_name VARCHAR2(255);
                l_schema_id   NUMBER;
        BEGIN
                msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_history_data.run_load - '
                || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                DEM_SCHEMA := fnd_profile.value('MSD_DEM_SCHEMA');
                IF fnd_profile.value('MSD_DEM_SCHEMA') IS NOT NULL THEN
                        l_user_id := p_user_id;
                        IF l_user_id IS NOT NULL THEN
                                l_sql := 'select user_name, password from '
                                ||dem_schema
                                ||'.user_id where user_id = '
                                ||l_user_id;
                                EXECUTE immediate l_sql INTO l_user_name, l_password;
                        ELSE
                                /* Bug#8224935 - APP ID */
                                l_user_id := to_number(msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_SOP', 1, 'user_id'));
                                IF l_user_id IS NOT NULL THEN
                                        l_sql := 'select user_name, password from '
                                        ||dem_schema
                                        ||'.user_id where user_id = '
                                        ||l_user_id;
                                        EXECUTE immediate l_sql INTO l_user_name, l_password;
                                ELSE
                                        msd_dem_common_utilities.log_message('Component is not found.');
                                END IF;
                        END IF;
                        IF l_user_name IS NOT NULL THEN
                                l_url := fnd_profile.value('MSD_DEM_HOST_URL');
                                -- Bug#7199587    syenamar
                                -- Do not hard-code 'EBS Full Download' workflow name here. Get its ID from lookup, get its name from demantra schema using the ID.
                                /* Bug#8224935 - APP ID */
                                -- l_wf_lookup_code is a schema_id in the database and meaning column in common lookup
                                l_schema_name := msd_dem_common_utilities.get_app_id_text ('MSD_DEM_DEMANTRA_OBJECT_ID', l_wf_lookup_code, 1, 'schema_name');
                                l_schema_name := trim(l_schema_name);
                                l_sql         := NULL;
                                l_sql         := 'SELECT
                                utl_http.request('''
                                ||l_url
                                ||'/WorkflowServer?action=run_proc&user='
                                ||l_user_name
                                ||'&password='
                                ||l_password
                                ||'&schema='
                                || REPLACE(l_schema_name, ' ', '%20')
                                ||'&sync=no'') FROM  dual';
                                msd_dem_common_utilities.log_debug (l_sql);
                                EXECUTE immediate l_sql INTO process_id;
                                --  msd_dem_common_utilities.log_message('Process Id:'||l_dummy);
                                -- syenamar
                        ELSE
                                msd_dem_common_utilities.log_message('Error in launching the download workflow.');
                                retcode := -1;
                                RETURN;
                        END IF;
                ELSE
                        msd_dem_common_utilities.log_message('Demantra Schema not set');
                END IF;
                /*  ELSE
                msd_dem_common_utilities.log_message ('Auto Run Download - No ');
                msd_dem_common_utilities.log_message ('Exiting without launching the download workflow.');
                END IF; */
                msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_history_data.run_load - '
                || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
        EXCEPTION
        WHEN OTHERS THEN
                errbuf  := SUBSTR(SQLERRM,1,150);
                retcode := -1 ;
                -- l_stmt := 'begin ' || DEM_SCHEMA || '.DATA_LOAD.LOG_EP_LOAD_FAILURE; end;';
                -- execute immediate l_stmt;
                --    l_stmt := 'alter session set current_schema=APPS';
                --    execute immediate l_stmt;
                msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_history_data.run_load - '
                || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
                msd_dem_common_utilities.log_message (errbuf);
                RETURN;
        END DEM_WORKFLOW;

/*Function To Launch Demantra Workflow and  Executes ODI*/
FUNCTION PUBLISH_DEM_WORKFLOW(ERRBUF OUT NOCOPY    VARCHAR2  ,
                               RETCODE OUT NOCOPY  VARCHAR2 ,
                               p_instance_id    IN NUMBER   ,
                               l_wf_lookup_code IN VARCHAR2 ,
                               scenario_name    IN VARCHAR2 ,
                               p_user_id        IN NUMBER)
RETURN Number AS
        /* Variables to Check Demantra WorkFlow is Completed */
        dem_cnt           NUMBER(2):=0;
        dem_status        NUMBER(2);
        dem_flag          NUMBER(2):= DEM_SUCCESS;
        ret_process_id    VARCHAR2(10);
        v_sql             VARCHAR2(200);
        g_demantra_schema VARCHAR2(30);
        /* Variables to Initialize and Execute ODI */
        scenario_version VARCHAR2(100):= '001';
        odi_url          VARCHAR2(300);
        ReturnStr        VARCHAR2(2000);
        -- ret_value   boolean;
        /* Variables to Execute FileCopy */
        fc_url       VARCHAR2(1000);
        fc_ret_value BOOLEAN DEFAULT TRUE;
        ret_value    BOOLEAN DEFAULT TRUE;
        ret_value1   BOOLEAN DEFAULT TRUE;
        ret_value2   BOOLEAN DEFAULT TRUE;
        ERRMESSAGE VARCHAR2(1900);
        StartIndex INTEGER;
        sleepTime  NUMBER(2) :=60;
        demTimeOut NUMBER;

BEGIN
        /* Calling DEM WorkFlow */
        DEM_WORKFLOW(errbuf, retcode, l_wf_lookup_code, ret_process_id, p_user_id);

        /* Profile for Demantra WorkFlow TimeOut */
        demTimeOut := fnd_profile.value('MSC_E1APS_DEM_WF_TIME_OUT');

        IF retcode= -1 OR ret_process_id = -1 THEN
                msd_dem_common_utilities.log_message('DEM WORKFLOW NOT LAUNCHED');
                RETURN 2;
        ELSE
                msd_dem_common_utilities.log_message('DEM WORKFLOW LAUNCHED.Process Id:'
                                                     ||ret_process_id );
                g_demantra_schema := msd_dem_demantra_utilities.get_demantra_schema;
                LOOP
                        dem_cnt:=dem_cnt+ 1; -- +1 indicates 60 seconds
                        v_sql  := 'select status  from '
                                  || g_demantra_schema
                                  || '.wf_process_log'
                                  || ' where '
                                  || ' process_id '
                                  || '='
                                  || ret_process_id;
                        EXECUTE immediate v_sql INTO dem_status;
                        DBMS_LOCK.sleep(sleepTime);
                        IF dem_status = 0 THEN
                                msd_dem_common_utilities.log_message('DEMANTRA WORKFLOW COMPLETED SUCCESSFULLY');
                                EXIT;
                        elsif dem_cnt  = demTimeOut THEN
                                msd_dem_common_utilities.log_message('DEMANTRA WORKFLOW TIMEOUT');
                                msd_dem_common_utilities.log_message('PLEASE CHECK THE DEMANTRA WORKFLOW STATUS.');
                                dem_flag:= DEM_WARNING;
                                EXIT;
                        elsif dem_status = -1 THEN
                                msd_dem_common_utilities.log_message('DEMANTRA WORKFLOW FAILED.');
                                dem_flag:= DEM_FAILURE;
                                EXIT;
                        END IF;
                END LOOP;
                IF dem_flag = DEM_WARNING  THEN
                    RETURN DEM_WARNING;
                END IF;

                IF dem_flag = DEM_FAILURE  THEN
                    RETURN DEM_FAILURE;
                END IF;

                IF dem_flag = DEM_SUCCESS THEN
                        /*Copies the file from  Demantra Server  To E1_file_DS  */
                        fc_url      := fnd_profile.value('MSC_E1APS_FCURL');
                        IF fc_url IS NOT NULL THEN
                                fc_ret_value   :=MSC_E1APS_DEMCL.CALL_ODIEXE('EXPORTFILESFROMDEMANTRASERVER' ,scenario_version ,'' ,fc_url);
                                 IF fc_ret_value = FALSE THEN
                                       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'File copy failed.' );
                                       RETURN DEM_FAILURE;
                                  END IF;
                        ELSE
                              RETURN DEM_SUCCESS;
                        END IF;

                        IF fc_ret_value THEN
                                ret_value1:=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name ,scenario_version ,'' ,fc_url);
                        END IF;

                          IF ret_value1 THEN
                                RETURN DEM_SUCCESS;
                          ELSE
                                RETURN DEM_FAILURE;
                          END IF;
                  END IF;
        END IF;
 END PUBLISH_DEM_WORKFLOW;
END MSC_E1APS_UTIL;

/
