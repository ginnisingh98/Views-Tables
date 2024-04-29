--------------------------------------------------------
--  DDL for Package Body WSH_ITM_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_OVERRIDE" as
/* $Header: WSHITOVB.pls 120.1.12010000.2 2010/02/09 18:19:42 rvarghes ship $ */
  --
  -- Package: WSH_ITM_OVERRIDE
  --
  -- Purpose: To Override the errors encountered during the Adapter Processing.
  --
  --

  -- Procedure Name
  --  Call_Custom_API
  --
  -- Purpose
  --
  --  This procedure accepts the request_control_id, request_set_id,
  --  Application ID and calls the Application Specific API
  --
  -- Parameters
  --
  --   p_request_control_id    Request Control ID
  --   p_request_set_id        Request Set ID
  --   p_appl_id               Application ID
  --   x_return_status         Return Status


PROCEDURE Call_Custom_API
  (
    p_request_control_id  IN NUMBER ,
    p_request_set_id      IN NUMBER ,
    p_appl_id             IN NUMBER,
    x_return_status       OUT NOCOPY  VARCHAR2
  )
IS

l_appl_short_name        VARCHAR2(50);
l_procedure_name         VARCHAR2(150);
l_error_code             NUMBER;
l_exists                 VARCHAR2(2);
l_error_text             VARCHAR2(2000);

CURSOR Get_Application_Short_Name(appl_id NUMBER) IS
   SELECT application_short_name
   FROM   fnd_application_vl
   WHERE  application_id = appl_id;

CURSOR Get_Process_Flag(req_set_id NUMBER) IS
   SELECT 'x'
   FROM   WSH_ITM_REQUEST_CONTROL
   WHERE  request_set_id = req_set_id
   AND    process_flag not in (1,3);


BEGIN

     WSH_UTIL_CORE.println(' Inside procedure CALL_CUSTOM_API');

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      ----------------------------------------------------------
      -- Select the application short name which will be later
      -- used to call the Application Specific custom procedure.
      ----------------------------------------------------------

      OPEN Get_Application_Short_name(p_appl_id);
      FETCH Get_Application_Short_Name INTO l_appl_short_name;
      CLOSE Get_Application_Short_Name;

      WSH_UTIL_CORE.println('Application Short Name :' || l_appl_short_name);
      WSH_UTIL_CORE.println('                        ');

       -- 9172419
       -- ONLY 2 parameters for WSH, 3 FOR ONT
      IF l_appl_short_name = 'ONT' THEN
        l_procedure_name := ' BEGIN ' ||  l_appl_short_name || '_ITM_PKG.WSH_ITM_' || l_appl_short_name ||
          '(:p_request_control_id,:p_request_set_id,:p_status_code); END;';
      ELSE
        l_procedure_name := ' BEGIN ' ||  l_appl_short_name || '_ITM_PKG.WSH_ITM_' || l_appl_short_name ||
        '(:p_request_control_id,:p_request_set_id); END;';
      END IF;

  IF p_request_set_id IS NULL THEN

       WSH_UTIL_CORE.println('Request Set Id is Null..');
       WSH_UTIL_CORE.println('Building the procedure name dynamically');

       ------------------------------------------------------
       -- The Procedure Name is getting built dynamiclly here.
       -- The generic syntax is :
       -- <appl short name>_ITM_PK.WSH_ITM_<appl short name>
       -- It then gets executed by the EXECUTE IMMEDIATE
       -- command.
       ------------------------------------------------------
       --
       WSH_UTIL_CORE.println('Calling Application specific API');
       WSH_UTIL_CORE.println(l_procedure_name);
       WSH_UTIL_CORE.println('                                   ');

       -- 9172419
       IF l_appl_short_name = 'ONT' THEN
          EXECUTE IMMEDIATE l_procedure_name
          USING p_request_control_id,
          p_request_set_id,
          'OVERRIDE';
       ELSE
          EXECUTE IMMEDIATE l_procedure_name
          USING p_request_control_id,
          p_request_set_id;
       END IF;

       WSH_UTIL_CORE.println('Out of the Application Specific Procedure');

 ELSE         -- if request_set_id is not null

       WSH_UTIL_CORE.println('Request Set Id is not Null..');
       WSH_UTIL_CORE.println('Request Set Id is :' || p_request_set_id);

       ----------------------------------------------------
       --  All other requests with the same request_set_id
       --  must have process flag as 1 or 3. Only then call
       --  the Application Specific API.
       ----------------------------------------------------

       OPEN Get_Process_Flag(p_request_set_id);
       FETCH Get_Process_Flag INTO l_exists;

          IF Get_Process_Flag%NOTFOUND THEN

            WSH_UTIL_CORE.println('Calling Application specific API');
            WSH_UTIL_CORE.println(l_procedure_name);
            WSH_UTIL_CORE.println('                                 ');

            -- 9172419
            IF l_appl_short_name = 'ONT' THEN
               EXECUTE IMMEDIATE l_procedure_name
               USING p_request_control_id,
               p_request_set_id,
               'OVERRIDE';
            ELSE
               EXECUTE IMMEDIATE l_procedure_name
               USING p_request_control_id,
               p_request_set_id;
            END IF;

          END IF;

       CLOSE Get_Process_Flag;
  END IF;         -- request_set_id null


  EXCEPTION

     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_code := SQLCODE;
      l_error_text := SQLERRM;

      WSH_UTIL_CORE.PrintMsg('Failed in Procedure Call_Custom_API');
      WSH_UTIL_CORE.PrintMsg('The unexpected error is '||l_error_code||':' || l_error_text);

END Call_Custom_API;

 -- Procedure Name
  --  Handle_Exception
  --
  -- Purpose
  --
  --  Close all the exception logged for a delivery and log another skip exception
  --
  -- Parameters
  --
  --   p_request_control_id    Request Control ID


PROCEDURE Handle_exception (
                          p_request_control_id IN NUMBER
			)
IS

    l_exception_name  		VARCHAR2(30);
    l_exception_id 			NUMBER;
    l_status 			VARCHAR2(10);

    l_api_version                   NUMBER  := 1.0;
    l_Return_status                 VARCHAR2(20);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(200);
    x_exception_id                  NUMBER;
    l_old_status                    VARCHAR2(30);
    l_new_status                    VARCHAR2(30);
    l_default_status                VARCHAR2(100);
    l_validation_level              NUMBER default  FND_API.G_VALID_LEVEL_FULL;
    l_varchar_status_tab            WSH_UTIL_CORE.Column_Tab_Type;
    l_num_delivery_id_tab           WSH_UTIL_CORE.Id_Tab_Type;

    l_logged_at_location_id 	number ;
    l_exception_location_id 	number;
    L_EXCEPTION_MESSAGE 		VARCHAR2(200);
    l_delivery_id number;
    l_delivery_name 		varchar2(20);

    CURSOR delivery_skip(l_request_control_id NUMBER) IS
    SELECT
          exception_name,
          exception_id,status,logged_at_location_id,exception_location_id,delivery_id,delivery_name
    FROM
          wsh_exceptions wex,
          wsh_itm_request_control wrc
    WHERE
           wrc.ORIGINAL_SYSTEM_REFERENCE=wex.delivery_id
           AND wrc.request_control_id = l_request_control_id
           AND (wex.exception_name LIKE 'WSH_PR%'OR wex.exception_name LIKE 'WSH_SC%' OR       wex.exception_name LIKE
           'WSH_EXPORT_COMPL_FAILED') AND WEX.STATUS <> 'CLOSED';

BEGIN

    l_return_status  := NULL;
    l_msg_count      :=NULL;
    l_msg_data       := NULL;
    l_new_status     := 'CLOSED';

    WSH_UTIL_CORE.println('Call to shipping to log close the previous exception and log a  new skip exception');
    WSH_UTIL_CORE.println('Request Control Id is'||p_request_control_id);



    OPEN DELIVERY_SKIP(p_request_control_id);
    LOOP
         FETCH delivery_skip INTO
           l_exception_name,l_exception_id,l_status,l_logged_at_location_id,l_exception_location_id,l_delivery_id,l_delivery_name;

        WSH_UTIL_CORE.println('The exception name is '||l_exception_name);
        WSH_UTIL_CORE.println('The exception is is '||l_exception_id);


        EXIT WHEN DELIVERY_SKIP%NOTFOUND;

                    l_return_status  := NULL;
                            l_msg_count      := NULL;
                            l_msg_data       := NULL;
                            l_old_status     := 'OPEN';
                            l_new_status     := 'CLOSED';
                            l_default_status := 'F';


                            WSH_XC_UTIL.change_status ( p_api_version           => l_api_version,
                                                        p_init_msg_list         => FND_API.g_false,
                                                        p_commit                => FND_API.g_false,
                                                        p_validation_level      => l_validation_level,
                                                        x_return_status         => l_return_status,
                                                        x_msg_count             => l_msg_count,
                                                        x_msg_data              => l_msg_data,
                                                        p_exception_id          => l_exception_id,
                                                        p_old_status            => l_old_status,
                                                        p_set_default_status    => l_default_status,
                                                        x_new_status            => l_new_status
                                                );



                   l_return_status  := NULL;
                       l_msg_count      := NULL;
                       l_msg_data       := NULL;
                       l_exception_id   := NULL;
                       l_exception_message := 'Delivery has skipped export screening';
                       l_exception_name := 'WSH_EXPORT_COMPL_SKIP';



                     WSH_XC_UTIL.log_exception(
                        p_api_version            => l_api_version,
                                p_init_msg_list          => FND_API.g_false,
                                p_commit                 => FND_API.g_false,
                                p_validation_level       => l_validation_level,
                                x_return_status          => l_return_status,
                                x_msg_count              => l_msg_count,
                                x_msg_data               => l_msg_data,
                               x_exception_id           => l_exception_id,
                                p_exception_location_id  => l_exception_location_id,
                                p_logged_at_location_id  => l_logged_at_location_id,
                                p_logging_entity         => 'SHIPPER',
                                p_logging_entity_id      =>  FND_GLOBAL.USER_ID,
                                p_exception_name         =>  l_exception_name,
                                p_message                =>  l_exception_message,
                                p_delivery_id            =>  l_delivery_id,
                                p_delivery_name          => l_delivery_name
                        );

        WSH_UTIL_CORE.println('End of call to shipping ');


  END LOOP;
  CLOSE delivery_skip;

END Handle_Exception;



  -- Name
  --
  --   ITM_Launch_Override
  --
  -- Purpose
  --   This procedure selects all the eligible records from the tables
  --   WSH_ITM_REQUEST_CONTROL, WSH_ITM_RESPONSE_HEADERS
  --   and WSH_ITM_RESPONSE_LINES  for Override.
  --
  --   For every record, it first updates the process_flag in the table
  --   WSH_ITM_REQUEST_CONTROL to 3, meaning OVERRIDE and calls Application
  --   specific custom procedure.
  --
  --   Arguments
  --   ERRBUF                   Required by Concurrent Processing.
  --   RETCODE                  Required by Concurrent Processing.
  --   P_APPLICATION_ID         Application ID
  --   P_OVERRIDE_TYPE          Denotes SYSTEM/DATA/UNPROCESSED
  --   P_ERROR_TYPE             Values for Error Type
  --   P_ERROR_CODE             Values for Error Code.
  --   P_REFERENCE_ID           Reference Number for Integrating Application
  --                            Ex: Order Number for OM.
  --   P_REFERENCE_LINE_ID      Reference Line for Integrating Application
  --                            Ex : Order Line Number for OM.
  --   P_VENDOR_ID              Value for Vendor ID.
  --   P_PARTY_TYPE             Value for Party Type
  --   P_PARTY_Id               Value for Party ID
  --
  --   Returns [ for functions ]
  --
  -- Notes
  --

PROCEDURE ITM_Launch_Override
(
    errbuf                     OUT NOCOPY   VARCHAR2  ,
    retcode                    OUT NOCOPY   NUMBER    ,
    p_application_id           IN   NUMBER    ,
    p_override_type            IN   VARCHAR2  ,
    p_reference_id             IN   NUMBER    ,
    p_dummy                    IN   NUMBER  DEFAULT NULL,
    p_reference_line_id        IN   NUMBER    ,
    p_error_type               IN   VARCHAR2  ,
    p_error_code               IN   VARCHAR2  ,
    p_vendor_id                IN   NUMBER    ,
    p_party_type               IN   VARCHAR2  ,
    p_party_id               IN   NUMBER
)

IS


l_response_header_id     NUMBER;
l_exists                 VARCHAR2(1);
l_completion_status      VARCHAR2(30);
l_temp                   BOOLEAN;
l_error_code             NUMBER;
l_error_text             VARCHAR2(2000);
l_log_level              VARCHAR2(240);
l_return_status          VARCHAR2(3);
l_SrvTab                 WSH_ITM_RESPONSE_PKG.SrvTabTyp;
l_interpreted_value      VARCHAR2(30);
l_request_control_id     NUMBER;
l_request_set_id         NUMBER;
l_flag                   NUMBER;
Response_Analyser_Failed EXCEPTION;
Call_Custom_API_Failed   EXCEPTION;

--Added variables for bug 4688380
l_sql_string             VARCHAR2(5000);
l_CursorID               INTEGER;
l_ignore                 INTEGER;
i                        NUMBER;
l_sub_str                VARCHAR2(5000);

CURSOR Get_Request_Control_ship IS
  SELECT  DISTINCT
          wrc.request_control_id,
          wrc.request_set_id
  FROM
          WSH_ITM_REQUEST_CONTROL wrc,
          WSH_ITM_RESPONSE_HEADERS wrh

  WHERE
          wrc.response_header_id  = wrh.response_header_id
  AND     nvl(wrh.vendor_id,-99)  = nvl(p_vendor_id, nvl(wrh.vendor_id,-99))
  AND     nvl(wrh.error_type,-99) = nvl(p_error_type, nvl(wrh.error_type,-99))
  AND     nvl(wrh.error_code,-99) = nvl(p_error_code, nvl(wrh.error_code,-99))
  AND     nvl(wrc.original_system_reference,-99) = nvl(p_reference_id,
                                          nvl(wrc.original_system_reference,-99))
  AND     wrc.process_flag = 2
  AND     wrc.application_id=665;

CURSOR Get_Unprocessed_Records_1_ship IS
  SELECT  DISTINCT
          wrc.request_control_id,
          wrc.request_set_id
  FROM
          WSH_ITM_REQUEST_CONTROL wrc
  WHERE
         nvl(wrc.original_system_reference,-99) = nvl(p_reference_id,
                                          nvl(wrc.original_system_reference,-99))
  AND     wrc.process_flag in  (0,-4);


CURSOR Get_Unprocessed_Records_2_ship IS
  SELECT  DISTINCT
          wrc.request_control_id,
          wrc.request_set_id
  FROM
          WSH_ITM_REQUEST_CONTROL wrc,
          WSH_ITM_SERVICE_PREFERENCES wsp,
          WSH_ITM_VENDOR_SERVICES wvs
  WHERE
         nvl(wrc.original_system_reference,-99) = nvl(p_reference_id,
                                          nvl(wrc.original_system_reference,-99))
  AND     wrc.application_id = wsp.application_id
  AND     wrc.master_organization_id = wsp.master_organization_id
  AND     wsp.active_flag = 'Y'
  AND     wsp.vendor_service_id = wvs.vendor_service_id
  AND     wrc.service_type_code = wvs.service_type
  AND     wvs.vendor_id = p_vendor_id
  AND     wrc.process_flag in (0,-4);

BEGIN


  l_completion_status := 'NORMAL';
  l_log_level         := FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

  IF l_log_level IS NOT NULL THEN
     WSH_UTIL_CORE.Set_Log_Level(l_log_level);
  END IF;


  WSH_UTIL_CORE.println('*** Inside PROCEDURE  ITM_Launch_Override ***');
  WSH_UTIL_CORE.println('                                            ');

  ------------------------------------------
  -- Print the values of all the parameters.
  ------------------------------------------

  WSH_UTIL_CORE.println('Application Id     : ' || p_application_id);
  WSH_UTIL_CORE.println('Override Type      : ' || p_override_type);
  WSH_UTIL_CORE.println('Reference Id       : ' || p_reference_id);
  WSH_UTIL_CORE.println('Reference Line Id  : ' || p_reference_line_id);
  WSH_UTIL_CORE.println('Error Type         : ' || p_error_type);
  WSH_UTIL_CORE.println('Error Code         : ' || p_error_code);
  WSH_UTIL_CORE.println('Vendor Id          : ' || p_vendor_id);
  WSH_UTIL_CORE.println('Party Type         : ' || p_party_type);
  WSH_UTIL_CORE.println('Party ID         : '   || p_party_id);
  WSH_UTIL_CORE.println('                                            ');

      --Issue a Savepoint
        SAVEPOINT WSH_ITM_OVERRIDE;
   IF p_override_type = 'UNPROCESSED' OR
      p_override_type IS NULL THEN

       WSH_UTIL_CORE.println('Override type is UNPROCESSED');

             If p_vendor_id  is NULL THEN
                    WSH_UTIL_CORE.println('Start the loop for Get_Unprocessed_Records_1');
                    if p_application_id=660 then
                        l_sql_string := 'SELECT DISTINCT wrc.request_control_id, wrc.request_set_id ';
                        l_sql_string := l_sql_string || 'FROM   WSH_ITM_REQUEST_CONTROL wrc ';

                        IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
                           l_sql_string := l_sql_string || '  , WSH_ITM_PARTIES wp ';
                        END IF;

                        l_sql_string := l_sql_string || 'WHERE  wrc.process_flag in ( 0, -4 ) ';

                        IF ( p_reference_id is NOT NULL ) THEN
                           l_sql_string := l_sql_string || 'AND    wrc.original_system_reference = :x_reference_id ';
                        END IF;

                        IF ( p_reference_line_id is NOT NULL ) THEN
                           l_sql_string := l_sql_string || 'AND    wrc.original_system_line_reference = :x_reference_line_id ';
                        END IF;

                        IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
                        --{
                           l_sql_string := l_sql_string || 'AND    wrc.request_control_id = wp.request_control_id ';
                           IF ( p_party_type is NOT NULL ) THEN
                              l_sql_string := l_sql_string || 'AND   wp.party_type = :x_party_type ';
                           END IF;

                           IF ( p_party_id is NOT NULL ) THEN
                              l_sql_string := l_sql_string || 'AND   wp.source_org_id = :x_party_id';
                           END IF;
                        --}
                        END IF;

                        i := 1;
                        LOOP
                           IF i > length(l_sql_string) THEN
                              EXIT;
                           END IF;
                           l_sub_str := SUBSTR(l_sql_string, i , 80);
                           WSH_UTIL_CORE.println(l_sub_str);
                           i := i + 80;
                        END LOOP;

                        l_CursorID := DBMS_SQL.Open_Cursor;
                        DBMS_SQL.Parse(l_CursorID, l_sql_string, DBMS_SQL.v7 );
                        DBMS_SQL.Define_Column(l_CursorID, 1,  l_request_control_id);
                        DBMS_SQL.Define_Column(l_CursorID, 2,  l_request_set_id);

                        IF p_party_type IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_party_type', p_party_type);
                        END IF;

                        IF p_party_id IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_party_id', p_party_id);
                        END IF;

                        IF p_reference_id IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_reference_id', p_reference_id);
                        END IF;

                        IF p_reference_line_id IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_reference_line_id', p_reference_line_id);
                        END IF;

                        l_ignore := DBMS_SQL.Execute(l_CursorID);
                    --}
                    else
                        open Get_Unprocessed_Records_1_ship;
                       WSH_UTIL_CORE.println('Start The processing for Shipping Records :');
                        if p_override_type= null and p_reference_id is not null then
                            WSH_UTIL_CORE.println('The delivery contains errored request ' );
                            l_flag := 1;
                            WSH_UTIL_CORE.println('Start Processing for Request Control :' || l_flag);
                        end if;
                    end if;
            ELSE
                    WSH_UTIL_CORE.println('Start the loop for Get_Unprocessed_Records_2');
                    if p_application_id=660 then
                        l_sql_string := 'SELECT DISTINCT wrc.request_control_id, wrc.request_set_id ';
                        l_sql_string := l_sql_string || 'FROM   WSH_ITM_REQUEST_CONTROL wrc, ';
                        l_sql_string := l_sql_string || '       WSH_ITM_SERVICE_PREFERENCES wsp, ';
                        l_sql_string := l_sql_string || '       WSH_ITM_VENDOR_SERVICES wvs ';

                        IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
                           l_sql_string := l_sql_string || '  , WSH_ITM_PARTIES wp ';
                        END IF;

                        l_sql_string := l_sql_string || 'WHERE  wrc.process_flag in ( 0, -4 ) ';
                        l_sql_string := l_sql_string || 'AND    wrc.service_type_code = wvs.service_type ';
                        l_sql_string := l_sql_string || 'AND    wsp.vendor_service_id = wvs.vendor_service_id ';
                        l_sql_string := l_sql_string || 'AND    wsp.active_flag = ''Y'' ';
                        l_sql_string := l_sql_string || 'AND    wrc.master_organization_id = wsp.master_organization_id ';
                        l_sql_string := l_sql_string || 'AND    wrc.application_id = wsp.application_id ';
                        l_sql_string := l_sql_string || 'AND    wvs.vendor_id = :x_vendor_id ';

                        IF ( p_reference_id is NOT NULL ) THEN
                           l_sql_string := l_sql_string || 'AND    wrc.original_system_reference = :x_reference_id ';
                        END IF;

                        IF ( p_reference_line_id is NOT NULL ) THEN
                           l_sql_string := l_sql_string || 'AND    wrc.original_system_line_reference = :x_reference_line_id ';
                        END IF;

                        IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
                        --{
                           l_sql_string := l_sql_string || 'AND    wrc.request_control_id = wp.request_control_id ';
                           IF ( p_party_type is NOT NULL ) THEN
                              l_sql_string := l_sql_string || 'AND   wp.party_type = :x_party_type ';
                           END IF;

                           IF ( p_party_id is NOT NULL ) THEN
                              l_sql_string := l_sql_string || 'AND   wp.source_org_id = :x_party_id';
                           END IF;
                        --}
                        END IF;

                        i := 1;
                        LOOP
                           IF i > length(l_sql_string) THEN
                              EXIT;
                           END IF;
                           l_sub_str := SUBSTR(l_sql_string, i , 80);
                           WSH_UTIL_CORE.println(l_sub_str);
                           i := i + 80;
                        END LOOP;

                        l_CursorID := DBMS_SQL.Open_Cursor;
                        DBMS_SQL.Parse(l_CursorID, l_sql_string, DBMS_SQL.v7 );
                        DBMS_SQL.Define_Column(l_CursorID, 1,  l_request_control_id);
                        DBMS_SQL.Define_Column(l_CursorID, 2,  l_request_set_id);

                        DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_vendor_id', p_vendor_id);
                        IF p_party_type IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_party_type', p_party_type);
                        END IF;

                        IF p_party_id IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_party_id', p_party_id);
                        END IF;

                        IF p_reference_id IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_reference_id', p_reference_id);
                        END IF;

                        IF p_reference_line_id IS NOT NULL THEN
                           DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_reference_line_id', p_reference_line_id);
                        END IF;

                        l_ignore := DBMS_SQL.Execute(l_CursorID);
                    else
                        open Get_UNprocessed_Records_2_ship;
                        if p_override_type= null and p_reference_id is not null then
                            l_flag := 1;
                        end if;
                    end if;

             END IF;

             LOOP
              If p_vendor_id  is NULL THEN
                     if p_application_id=660 then
                         IF DBMS_SQL.Fetch_Rows(l_cursorID) = 0 THEN
                            DBMS_SQL.Close_Cursor(l_cursorID);
                            EXIT;
                         ELSE
                            DBMS_SQL.Column_Value(l_CursorID, 1, l_request_control_id);
                            DBMS_SQL.Column_Value(l_CursorID, 2, l_request_set_id);
                         END IF;
                    else

                    EXIT WHEN l_flag=1;
                     WSH_UTIL_CORE.println('Start Processing for Request Control :' || l_flag);

                     Fetch Get_Unprocessed_Records_1_ship into
                             l_request_control_id,
                             l_request_set_id;
                     WSH_UTIL_CORE.println('Start Processing for Request Control :' || l_request_control_id);
                         EXIT WHEN Get_Unprocessed_Records_1_ship%NOTFOUND;

                     end if;
               Else
                if p_application_id=660 then
                                IF DBMS_SQL.Fetch_Rows(l_cursorID) = 0 THEN
                                   DBMS_SQL.Close_Cursor(l_cursorID);
                                   EXIT;
                                ELSE
                                   DBMS_SQL.Column_Value(l_CursorID, 1, l_request_control_id);
                                   DBMS_SQL.Column_Value(l_CursorID, 2, l_request_set_id);
                                END IF;
                        else
                    EXIT WHEN l_flag=1;
                                Fetch Get_Unprocessed_Records_2_ship into
                                l_request_control_id,
                                l_request_set_id;
                                EXIT WHEN Get_Unprocessed_Records_2_ship%NOTFOUND;
                 end if;

               End If;
               WSH_UTIL_CORE.println('Start Processing for Request Control :' || l_request_control_id);


               WSH_UTIL_CORE.println('Updating Process Flag');

               update wsh_itm_request_control
               SET    process_flag = 3
               WHERE  request_control_id = l_request_control_id;

                if p_application_id=665 then
                     Handle_Exception(l_request_control_id);
                end if;
                   BEGIN
                WSH_UTIL_CORE.println('Calling Procedure Call_Custom_API');
                    Call_Custom_API
                    (
                      p_request_control_id => l_request_control_id,
                      p_request_set_id     => l_request_set_id,
                      p_appl_id            => p_application_id,
                      x_return_status      => l_return_status
                    );

                    WSH_UTIL_CORE.println('After Call to Call_Custom_API');
                    WSH_UTIL_CORE.println('Return Status from Call_Custom_API:' || l_return_status);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE Call_Custom_API_Failed;
                    END IF;
                    commit;

                    EXCEPTION
                          WHEN Call_Custom_API_Failed THEN
                         ROLLBACK TO WSH_ITM_OVERRIDE;
                             WSH_UTIL_CORE.println('Failed in Call_Custom_API for request control:' || l_request_control_id);

                     END;

               WSH_UTIL_CORE.println('Finished processing for Request Control :' || l_request_control_id);

             END LOOP;

             If p_vendor_id  is NULL THEN
                if p_application_id=660 then
                   IF DBMS_SQL.IS_Open(l_cursorID) THEN
                      DBMS_SQL.Close_Cursor(l_cursorID);
                   END IF;
                else
                   close Get_Unprocessed_Records_1_ship;
                end if;
            ELSE
                        if p_application_id=660 then
                           IF DBMS_SQL.IS_Open(l_cursorID) THEN
                              DBMS_SQL.Close_Cursor(l_cursorID);
                           END IF;
                        else
                           close Get_Unprocessed_Records_2_ship;
                        end if;
             END IF;
END IF;      --  p_override_type is UNPROCESSED

 IF p_override_type = 'SYSTEM' OR
    p_override_type = 'DATA' OR
    p_override_type IS NULL THEN


        WSH_UTIL_CORE.println('p_override_type is not unprocessed');
        if p_application_id =660 THEN
        -- {
        -- Using Dynamic Cursor instead of static cursor for performance.
            l_sql_string := 'SELECT DISTINCT wrc.request_control_id, wrc.request_set_id ';
            l_sql_string := l_sql_string || 'FROM   WSH_ITM_REQUEST_CONTROL  wrc, ';
            l_sql_string := l_sql_string || '       WSH_ITM_RESPONSE_HEADERS wrh ';

            IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || '  , WSH_ITM_PARTIES wp ';
            END IF;

            l_sql_string := l_sql_string || 'WHERE  wrc.response_header_id = wrh.response_header_id ';
            l_sql_string := l_sql_string || 'AND    wrc.process_flag = 2 ';
            l_sql_string := l_sql_string || 'AND    wrc.application_id = 660 ';

            IF ( p_vendor_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrh.vendor_id = :x_vendor_id ';
            END IF;

            IF ( p_error_type is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrh.error_type = :x_error_type ';
            END IF;

            IF ( p_error_code is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrh.error_code = :x_error_code ';
            END IF;

            IF ( p_reference_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrc.original_system_reference = :x_reference_id ';
            END IF;

            IF ( p_reference_line_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrc.original_system_line_reference = :x_reference_line_id ';
            END IF;

            IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
            --{
               l_sql_string := l_sql_string || 'AND    wrc.request_control_id = wp.request_control_id ';

               IF ( p_party_type is NOT NULL ) THEN
                  l_sql_string := l_sql_string || 'AND    wp.party_type = :x_party_type ';
               END IF;

               IF ( p_party_id is NOT NULL ) THEN
                  l_sql_string := l_sql_string || 'AND    wp.source_org_id = :x_party_id ';
               END IF;
            --}
            END IF;

            l_sql_string := l_sql_string || 'UNION ';
            l_sql_string := l_sql_string || 'SELECT DISTINCT wrc.request_control_id, wrc.request_set_id ';
            l_sql_string := l_sql_string || 'FROM   WSH_ITM_REQUEST_CONTROL wrc, ';
            l_sql_string := l_sql_string || '       WSH_ITM_RESPONSE_HEADERS wrh, ';
            l_sql_string := l_sql_string || '       WSH_ITM_RESPONSE_LINES wrl ';

            IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || '  , WSH_ITM_PARTIES wp ';
            END IF;

            l_sql_string := l_sql_string || 'WHERE  wrc.response_header_id = wrh.response_header_id ';
            l_sql_string := l_sql_string || 'AND    wrh.response_header_id = wrl.response_header_id ';
            l_sql_string := l_sql_string || 'AND    wrc.process_flag = 2 ';
            l_sql_string := l_sql_string || 'AND    wrc.application_id = 660 ';

            IF ( p_vendor_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrh.vendor_id = :x_vendor_id ';
            END IF;

            IF ( p_error_type is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrl.error_type = :x_error_type ';
            END IF;

            IF ( p_error_code is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrl.error_code = :x_error_code ';
            END IF;

            IF ( p_reference_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrc.original_system_reference = :x_reference_id ';
            END IF;

            IF ( p_reference_line_id is NOT NULL ) THEN
               l_sql_string := l_sql_string || 'AND    wrc.original_system_line_reference = :x_reference_line_id ';
            END IF;

            IF ( p_party_type is NOT NULL or p_party_id is NOT NULL ) THEN
            --{
               l_sql_string := l_sql_string || 'AND    wrc.request_control_id = wp.request_control_id ';

               IF ( p_party_type is NOT NULL ) THEN
                  l_sql_string := l_sql_string || 'AND    wp.party_type = :x_party_type ';
               END IF;

               IF ( p_party_id is NOT NULL ) THEN
                  l_sql_string := l_sql_string || 'AND    wp.source_org_id = :x_party_id ';
               END IF;
            --}
            END IF;

            i := 1;
            LOOP
               IF i > length(l_sql_string) THEN
                  EXIT;
               END IF;
               l_sub_str := SUBSTR(l_sql_string, i , 80);
               WSH_UTIL_CORE.println(l_sub_str);
               i := i + 80;
            END LOOP;

            l_CursorID := DBMS_SQL.Open_Cursor;
            DBMS_SQL.Parse(l_CursorID, l_sql_string, DBMS_SQL.v7 );
            DBMS_SQL.Define_Column(l_CursorID, 1,  l_request_control_id);
            DBMS_SQL.Define_Column(l_CursorID, 2,  l_request_set_id);

            IF p_party_type IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_party_type', p_party_type);
            END IF;

            IF p_party_id IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_party_id', p_party_id);
            END IF;

            IF p_vendor_id IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_vendor_id', p_vendor_id);
            END IF;

            IF p_error_type IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_error_type', p_error_type);
            END IF;

            IF p_error_code IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_error_code', p_error_code);
            END IF;

            IF p_reference_id IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_reference_id', p_reference_id);
            END IF;

            IF p_reference_line_id IS NOT NULL THEN
               DBMS_SQL.BIND_VARIABLE(l_CursorID, ':x_reference_line_id', p_reference_line_id);
            END IF;

            l_ignore := DBMS_SQL.Execute(l_CursorID);
        -- }
        ELSE
            open Get_Request_Control_ship;
        END IF;

        LOOP
            IF p_application_id = 660 THEN
            --{
                IF DBMS_SQL.Fetch_Rows(l_cursorID) = 0 THEN
                   DBMS_SQL.Close_Cursor(l_cursorID);
                   EXIT;
                ELSE
                   DBMS_SQL.Column_Value(l_CursorID, 1, l_request_control_id);
                   DBMS_SQL.Column_Value(l_CursorID, 2, l_request_set_id);
                END IF;
            -- }
            ELSE
                fetch Get_Request_Control_ship into l_request_control_id,l_request_set_id;
                EXIT WHEN Get_Request_Control_ship%NOTFOUND;
            END IF;

            WSH_UTIL_CORE.println('Start of Processing for Request Control : ' || l_request_control_id);

            ----------------------------------------------------------
            -- Call the Response Analyser API
            ----------------------------------------------------------

            WSH_UTIL_CORE.println(' Calling the Response Analyser');

            WSH_ITM_RESPONSE_PKG.ONT_RESPONSE_ANALYSER
            (
                p_request_control_id => l_request_control_id,
                x_interpreted_value  => l_interpreted_value,
                x_SrvTab             => l_SrvTab,
                x_return_status      => l_return_status
            );
            IF l_interpreted_value = 'DATA' AND   p_application_id =660 THEN
                IF p_override_type  ='SYSTEM' THEN
                   WSH_UTIL_CORE.println('Response from Response analyser is different from the override parameter entered by user.. ignoring this and processing next record');
                ELSE
                    WSH_UTIL_CORE.println('Cannot process data errors');
                END IF;
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE Response_Analyser_Failed;
                END IF;

            ELSE

                WSH_UTIL_CORE.println('After Calling the Response Analyser');
                WSH_UTIL_CORE.println('                                   ');


                WSH_UTIL_CORE.println('Response from Response analyser: '  || l_interpreted_value);
                WSH_UTIL_CORE.println('Return Status from Response analyser :' || l_return_status);
                WSH_UTIL_CORE.println('                                    ');

                BEGIN

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE Response_Analyser_Failed;
                END IF;

                IF l_interpreted_value = p_override_type OR
                p_override_type      IS NULL           THEN


                        WSH_UTIL_CORE.println('Updating process_flag to 3');

                        UPDATE wsh_itm_request_control
                        SET    process_flag = 3
                        WHERE  request_control_id = l_request_control_id;

                        IF p_application_id=665 THEN
                                Handle_Exception(l_request_control_id);
                        ELSE
                                Call_Custom_API
                                (
                                p_request_control_id => l_request_control_id,
                                p_request_set_id     => l_request_set_id,
                                p_appl_id            => p_application_id,
                                x_return_status      => l_return_status
                                );

                                WSH_UTIL_CORE.println('AFter Call_Custom_API');

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                    RAISE Call_Custom_API_Failed;
                                END IF;

                        END IF;

                        WSH_UTIL_CORE.println('Finished Processing for Request Control :' || l_request_control_id);
                        commit;
                ELSE
                       WSH_UTIL_CORE.println('Response from Response analyser is different from the override parameter entered by user.. ignoring this and processing next record');
                END IF;

                EXCEPTION
                WHEN Response_Analyser_Failed THEN
                ROLLBACK TO WSH_ITM_OVERRIDE;
                WSH_UTIL_CORE.println('Processing failed in Response Analyser');

                WHEN Call_Custom_API_Failed THEN
                ROLLBACK TO WSH_ITM_OVERRIDE;
                WSH_UTIL_CORE.println('Failed in Call_Custom_API for request control:' || l_request_control_id);

                END;
            END IF ;
      END LOOP;
            IF p_application_id=660 THEN
               IF DBMS_SQL.IS_Open(l_cursorID) THEN
                  DBMS_SQL.Close_Cursor(l_cursorID);
               END IF;
            ELSE
                close Get_Request_Control_ship;
            END IF;
END IF;

 WSH_UTIL_CORE.println('The Processing - Completed..');
 l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');


EXCEPTION


WHEN OTHERS THEN

  ROLLBACK TO WSH_ITM_OVERRIDE;
  l_completion_status := 'ERROR';
  l_error_code        := SQLCODE;
  l_error_text        := SQLERRM;
  WSH_UTIL_CORE.PrintMsg('Failed in Procedure ITM_Launch_Override');
  WSH_UTIL_CORE.PrintMsg('The unexpected error is '||l_error_code||':' || l_error_text);
  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');


  END ITM_Launch_Override;

END WSH_ITM_OVERRIDE;

/
