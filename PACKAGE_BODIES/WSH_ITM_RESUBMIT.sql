--------------------------------------------------------
--  DDL for Package Body WSH_ITM_RESUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_RESUBMIT" as
/* $Header: WSHITRSB.pls 120.1 2005/10/23 23:51:30 bradha noship $ */

  --
  -- Package: WSH_ITM_RESUBMIT
  --
  -- Purpose: To Resubmit requests for Adapter Processing.
  --
  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Name
 --  Handle exception
  -- Purpose
  --   Closes all the exception logged for that delivery
  --   and log another exception skip of low severity to inform the shipper
  --   that delivery has skipped screening
  -- Arguments
  -- P_REQUEST_CONTROL_ID               Value for Request control ID
  --
  -- Returns [ for functions ]
  --
  -- Notes
  --
PROCEDURE Handle_Exception
(
   p_request_control_id IN NUMBER
)
IS

l_exception_name           VARCHAR2(30);
l_exception_id                     NUMBER;
l_status                   VARCHAR2(10);
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
l_logged_at_location_id    number ;
l_exception_location_id            number;
L_EXCEPTION_MESSAGE                VARCHAR2(200);
l_delivery_id number;
l_delivery_name varchar2(20);
l_triggering_point varchar2(20);
l_request_control_id number;
l_flag               boolean;

	cursor triggering_point(c_request_control_id number) is
		SELECT DISTINCT
			TRIGGERING_POINT
		FROM WSH_ITM_REQUEST_CONTROL
		WHERE request_control_id= c_request_control_id;

	cursor delivery_resubmit(c_request_control_id number) is
		SELECT
		   exception_id,status,logged_at_location_id,exception_location_id,DELIVERY_ID,delivery_name
		FROM
		  wsh_exceptions wex,
		  wsh_itm_request_control wrc
		WHERE
		  wrc.original_system_reference =wex.delivery_id
		  AND wex.exception_name LIKE 'WSH_EXPORT_COMPL_FAILED' AND WEX.STATUS='OPEN'
		  AND WRC.REQUEST_CONTROL_ID = C_REQUEST_CONTROL_ID
		ORDER BY wex.creation_date;

BEGIN

    WSH_UTIL_CORE.println('Start of Handle exception for the request control id'||p_request_control_id);
    WSH_UTIL_CORE.println('Closes all failed exception for that request control id and logs another submit exception for it');

    l_flag :=FALSE;

        OPEN DELIVERY_RESUBMIT(p_request_control_id);
        LOOP
        FETCH delivery_RESUBMIT INTO
        l_exception_id,l_status,l_logged_at_location_id,l_exception_locatiON_ID,L_DELIVERY_ID,L_DELIVERY_NAME;


        l_return_status  := NULL;
        l_msg_count      := NULL;
        l_msg_data       := NULL;
        l_new_status     := 'CLOSED';

        EXIT WHEN DELIVERY_RESUBMIT%NOTFOUND;


        WSH_UTIL_CORE.println('Exception id    		 :'||l_exception_id);
        WSH_UTIL_CORE.println('The status    		 :'||l_status);
        WSH_UTIL_CORE.println('Location id    		 :'||l_logged_at_location_id);
        WSH_UTIL_CORE.println('Exception location id     :'||l_exception_location_id);
        WSH_UTIL_CORE.println('Delivery id 		 :'||l_delivery_id);
        WSH_UTIL_CORE.println('Delivery name    	 :'||l_delivery_name);

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

    END LOOP;
    CLOSE delivery_RESUBMIT;


    OPEN triggering_point(p_request_control_id);

    FETCH triggering_point  into l_triggering_point;

    CLOSE triggering_point;

    WSH_UTIL_CORE.println('Triggering point is'|| l_triggering_point);
    IF l_triggering_point= 'PICK_RELEASE' THEN
        L_EXCEPTION_NAME := 'WSH_PR_SUB_EXPORT_COMPL';
    ELSE
        L_EXCEPTION_NAME := 'WSH_SC_SUB_EXPORT_COMPL';
    END IF;


    l_return_status  := NULL;
       l_msg_count      := NULL;
       l_msg_data       := NULL;
       l_exception_id   := NULL;

       l_exception_message := 'Delivery has been submitted for export screening';
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

    WSH_UTIL_CORE.println('End of Call Shipping');

    /*		 UPDATE wsh_itm_request_control
                    SET    process_flag = 0,
                           response_header_id = NULL
                    WHERE  request_control_id = p_request_control_id;
    */
     COMMIT;

    EXCEPTION

    WHEN OTHERS THEN
         ROLLBACK TO WSH_ITM_RESUBMIT;
         WSH_UTIL_CORE.println(' Error while hadling the exceptions');

END Handle_Exception;


--
  -- Package: WSH_ITM_RESUBMIT
  --
  -- Purpose: To Resubmit requests for Adapter Processing.
  --
  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Name
  --   Resubmit_Requests
  -- Purpose
  --   This procedure selects all the eligible records from the tables
  --   WSH_ITM_REQUEST_CONTROL, WSH_ITM_RESPONSE_HEADERS
  --   and WSH_ITM_RESPONSE_LINES  for Resubmit.
  --   For every record, it first updates the process_flag in the table
  --   WSH_ITM_REQUEST_CONTROL to 0, meaning RESUBMIT
  --
  -- Arguments
  -- ERRBUF                   Required by Concurrent Processing.
  -- RETCODE                  Required by Concurrent Processing.
  -- P_APPLICATION_ID         Application ID
  -- P_RESUBMIT_TYPE          Denotes SYSTEM/DATA
  -- P_ERROR_TYPE             Values for Error Type
  -- P_ERROR_CODE             Values for Error Code.
  -- P_PREFERENCE_ID          Reference Number for Integrating Application
  --                          Ex: Order Number for OM.
  -- P_REFERENCE_LINE_ID      Reference Line for Integrating Application
  --                          Ex : Order Line Number for OM.
  -- P_VENDOR_ID              Value for Vendor ID.
  -- P_PARTY_TYPE             Value for Party Type
  -- P_PARTY_ID               Value for Party ID
  --
  -- Returns [ for functions ]
  --
  -- Notes
  --




PROCEDURE ITM_Resubmit_Requests
(
    errbuf                     OUT NOCOPY   VARCHAR2,
    retcode                    OUT NOCOPY   NUMBER,
    p_application_id           IN   NUMBER,
    p_resubmit_type            IN   VARCHAR2 ,
    p_dummy                    IN   NUMBER default NULL,
    p_reference_id             IN   NUMBER   ,
    p_error_type               IN   VARCHAR2 ,
    p_error_code               IN   VARCHAR2 ,
    p_vendor_id                IN   NUMBER   ,
    p_reference_line_id        IN   NUMBER   ,
    p_party_type               IN   VARCHAR2 ,
    p_party_id                 IN   NUMBER
)

IS

l_process_flag           NUMBER;
l_error_code             NUMBER;
l_temp                   BOOLEAN;
l_error_text             VARCHAR2(2000);
l_log_level              NUMBER;
l_completion_status      VARCHAR2(30);
l_SrvTab                 WSH_ITM_RESPONSE_PKG.SrvTabTyp;
l_return_status          VARCHAR2(1);
l_interpreted_value      VARCHAR2(30);
l_request_control_id     NUMBER;
Response_Analyser_Failed EXCEPTION;

l_sql_string             VARCHAR2(4000);
l_CursorID               INTEGER;
l_ignore                 INTEGER;
i                        NUMBER;
l_sub_str                VARCHAR2(4000);

CURSOR Get_Request_Control_ship IS
  SELECT  DISTINCT
          wrc.request_control_id
  FROM
          WSH_ITM_REQUEST_CONTROL wrc,
          WSH_ITM_RESPONSE_HEADERS wrh
  WHERE
          wrc.response_header_id  = wrh.response_header_id
  AND     nvl(wrh.vendor_id,-99)  = nvl(p_vendor_id, nvl(wrh.vendor_id,-99))
  AND     nvl(wrh.error_type,-99) = nvl(p_error_type, nvl(wrh.error_type,-99))
  AND     nvl(wrh.error_code,-99) = nvl(p_error_code, nvl(wrh.error_code,-99))
  AND    nvl( wrc.original_system_reference,-99) = nvl(p_reference_id,
                                          nvl(wrc.original_system_reference,-99))
  AND     wrc.process_flag  = 2
  AND     wrc.application_id =665;


BEGIN

  l_completion_status := 'NORMAL';
  l_log_level         :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

   IF l_log_level IS NOT NULL THEN
     WSH_UTIL_CORE.Set_Log_Level(l_log_level);
   END IF;

  ------------------------------------------
  -- Print the values of all the parameters.
  ------------------------------------------

  WSH_UTIL_CORE.println('Application Id     : ' || p_application_id);
  WSH_UTIL_CORE.println('Resubmit Type      : ' || p_resubmit_type);
  WSH_UTIL_CORE.println('Reference No.      : ' || p_reference_id);
  WSH_UTIL_CORE.println('Reference Line No. : ' || p_reference_line_id);
  WSH_UTIL_CORE.println('Error Type         : ' || p_error_type);
  WSH_UTIL_CORE.println('Error Code         : ' || p_error_code);
  WSH_UTIL_CORE.println('Vendor Id          : ' || p_vendor_id);
  WSH_UTIL_CORE.println('Party Type         : ' || p_party_type);
  WSH_UTIL_CORE.println('Party id           : ' || p_party_id);

  WSH_UTIL_CORE.println('*** Inside PROCEDURE ITM_Resubmit_Requests ***');

  IF p_application_id = 660 THEN --{

     l_sql_string := 'SELECT  DISTINCT wrc.request_control_id '||
                     'FROM    WSH_ITM_REQUEST_CONTROL wrc '||
                     ',       WSH_ITM_RESPONSE_HEADERS wrh '||
                     ',       OE_ORDER_HEADERS_ALL oh ';

     IF (p_party_type IS NOT NULL) OR (p_party_id IS NOT NULL) THEN
         l_sql_string :=  l_sql_string || ', WSH_ITM_PARTIES wp ';
     END IF;
     l_sql_string :=  l_sql_string || ' WHERE wrc.response_header_id  = wrh.response_header_id '||
                                      ' AND   wrc.original_system_reference = oh.header_id '||
                                      ' AND   oh.flow_status_code <> ''CLOSED'' '||
                                      ' AND   wrc.process_flag = 2 '||
                                      ' AND   wrc.application_id = 660 ';
     IF p_vendor_id IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrh.vendor_id = :x_vendor_id ';
     END IF;
     IF p_error_type IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrh.error_type = :x_error_type ';
     END IF;
     IF p_error_code IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrh.error_code = :x_error_code ';
     END IF;
     IF p_reference_id IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrc.original_system_reference = :x_reference_id ';
     END IF;
     IF p_reference_line_id IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrc.original_system_line_reference = :x_reference_line_id ';
     END IF;
     IF (p_party_type IS NOT NULL) OR (p_party_id IS NOT NULL) THEN
         l_sql_string :=  l_sql_string || ' AND   wrc.request_control_id = wp.request_control_id ';
         IF p_party_type IS NOT NULL THEN
            l_sql_string :=  l_sql_string || ' AND   wp.party_type = :x_party_type ';
         END IF;
         IF p_party_id IS NOT NULL THEN
            l_sql_string :=  l_sql_string || ' AND   wp.source_org_id = :x_party_id ';
         END IF;
     END IF;
     l_sql_string :=  l_sql_string || ' UNION '||
                                      ' SELECT DISTINCT wrc.request_control_id '||
                                      ' FROM    WSH_ITM_REQUEST_CONTROL wrc '||
                                      ' ,       WSH_ITM_RESPONSE_HEADERS wrh '||
                                      ' ,       WSH_ITM_RESPONSE_LINES wrl '||
                                      ' ,       OE_ORDER_LINES_ALL ol ';
     IF (p_party_type IS NOT NULL) OR (p_party_id IS NOT NULL) THEN
         l_sql_string :=  l_sql_string || ', WSH_ITM_PARTIES wp ';
     END IF;
     l_sql_string :=  l_sql_string || ' WHERE wrc.response_header_id  = wrh.response_header_id '||
                                      ' AND   wrh.response_header_id  = wrl.response_header_id '||
                                      ' AND   wrc.original_system_line_reference = ol.line_id '||
                                      ' AND   ol.flow_status_code <> ''CLOSED'' '||
                                      ' AND   wrc.process_flag = 2 '||
                                      ' AND   wrc.application_id = 660 ';
     IF p_vendor_id IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrh.vendor_id = :x_vendor_id ';
     END IF;
     IF p_error_type IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrl.error_type = :x_error_type ';
     END IF;
     IF p_error_code IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrl.error_code = :x_error_code ';
     END IF;
     IF p_reference_id IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrc.original_system_reference = :x_reference_id ';
     END IF;
     IF p_reference_line_id IS NOT NULL THEN
        l_sql_string :=  l_sql_string || ' AND   wrc.original_system_line_reference = :x_reference_line_id ';
     END IF;
     IF (p_party_type IS NOT NULL) OR (p_party_id IS NOT NULL) THEN
         l_sql_string :=  l_sql_string || ' AND   wrc.request_control_id = wp.request_control_id ';
         IF p_party_type IS NOT NULL THEN
            l_sql_string :=  l_sql_string || ' AND   wp.party_type = :x_party_type ';
         END IF;
         IF p_party_id IS NOT NULL THEN
            l_sql_string :=  l_sql_string || ' AND   wp.source_org_id = :x_party_id ';
         END IF;
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

     IF p_party_type IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_party_type', p_party_type);
     END IF;
     IF p_party_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_party_id', p_party_id);
     END IF;
     IF p_vendor_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_vendor_id', p_vendor_id);
     END IF;
     IF p_error_type IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_error_type', p_error_type);
     END IF;
     IF p_error_code IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_error_code', p_error_code);
     END IF;
     IF p_reference_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_reference_id', p_reference_id);
     END IF;
     IF p_reference_line_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_CursorID,':x_reference_line_id', p_reference_line_id);
     END IF;

     l_ignore := DBMS_SQL.Execute(l_CursorID);
  --}
  ELSE
     OPEN Get_Request_Control_ship;
  END IF;

  LOOP --{

    --Issue a Savepoint
    SAVEPOINT WSH_ITM_RESUBMIT;

    IF p_application_id = 660 THEN
      IF DBMS_SQL.Fetch_Rows(l_cursorID) = 0 THEN
         DBMS_SQL.Close_Cursor(l_cursorID);
         EXIT;
      ELSE
         DBMS_SQL.Column_Value(l_CursorID, 1,  l_request_control_id);
	      WSH_UTIL_CORE.println('Request Control Id is' || l_request_control_id);
      END IF;
    ELSE
      fetch Get_Request_Control_ship into l_request_control_id;

      WSH_UTIL_CORE.println('Request Control Id for application  shipping is' || l_request_control_id);
      exit when Get_request_control_ship%notfound;
      WSH_UTIL_CORE.println('Before the handle exception '||l_request_control_id);
      Handle_Exception(l_request_control_id);
      WSH_UTIL_CORE.println('After the handle exception'||l_request_control_id);
      WSH_UTIL_CORE.println('Request Control Id after handling the exception for  shipping is' || l_request_control_id);
    END IF;

    WSH_UTIL_CORE.println('Request Control Id is' || l_request_control_id);

    WSH_UTIL_CORE.println('                                 ');
    WSH_UTIL_CORE.println('Start Processing for Request control : ' || l_request_control_id);


    WSH_UTIL_CORE.println('Calling the Response Analyser');
    WSH_UTIL_CORE.println('Request Control Id :' || l_request_control_id);

    -----------------------------------------------------------
    --  Calling the Response Analyser to Get the Interpretation
    -----------------------------------------------------------


    WSH_ITM_RESPONSE_PKG.ONT_RESPONSE_ANALYSER
          (
            p_request_control_id => l_request_control_id,
            x_interpreted_value => l_interpreted_value,
            x_return_status     => l_return_status,
            x_SrvTab            => l_SrvTab
           );

    WSH_UTIL_CORE.println('                                 ');
    WSH_UTIL_CORE.println('After Call to Response Analyser');
    WSH_UTIL_CORE.println('Response from Response Analyser :' || l_interpreted_value);

    IF  (p_application_id =660 AND l_interpreted_value ='DATA') then
         WSH_UTIL_CORE.println('Data errors will not be processes for Order Management');
    ELSE

         BEGIN
           IF l_return_Status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE Response_Analyser_Failed;
           END IF;


           IF (l_interpreted_value = p_resubmit_type OR p_resubmit_type IS NULL) THEN

               WSH_UTIL_CORE.println('Updating process flag to 0');

               --------------------------------
               --  Update the Process Flag to 0
               --------------------------------

               UPDATE wsh_itm_request_control
               SET    process_flag = 0,
                      response_header_id = NULL
               WHERE  request_control_id = l_request_control_id;


               WSH_UTIL_CORE.println('Commiting the records..');
               commit;
               WSH_UTIL_CORE.println('Finished processing for Request Control :' || l_request_control_id);
               WSH_UTIL_CORE.println('    ');

           ELSE

               WSH_UTIL_CORE.println('Response from Response Analyser is different from parameter p_resubmit_type');
               WSH_UTIL_CORE.println('So will not process this record');

           END IF;

         EXCEPTION
           WHEN Response_Analyser_Failed THEN
                ROLLBACK TO WSH_ITM_RESUBMIT;
                WSH_UTIL_CORE.println('Processing Failed in Response Analyser');
         END;
    END IF;

  END LOOP; --}

  IF p_application_id=660 THEN
     IF DBMS_SQL.IS_Open(l_cursorID) THEN
        DBMS_SQL.Close_Cursor(l_cursorID);
     END IF;
  ELSE
     CLOSE  Get_Request_Control_ship;
  END IF;


  WSH_UTIL_CORE.println('End of the Loop for the  Cursor ');

  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');


EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK TO WSH_ITM_RESUBMIT;
    IF DBMS_SQL.IS_Open(l_cursorID) THEN
       DBMS_SQL.Close_Cursor(l_cursorID);
    END IF;
    IF Get_Request_Control_ship%ISOPEN THEN
       CLOSE Get_Request_Control_ship;
    END IF;
    l_completion_status := 'ERROR';
    l_error_code        := SQLCODE;
    l_error_text        := SQLERRM;
    WSH_UTIL_CORE.PrintMsg('In the exception Block');
    WSH_UTIL_CORE.PrintMsg('Processing failed with an error');
    WSH_UTIL_CORE.PrintMsg('The unexpected error is '||l_error_code||':' || l_error_text);
    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');

END ITM_Resubmit_Requests;

END WSH_ITM_RESUBMIT;

/
