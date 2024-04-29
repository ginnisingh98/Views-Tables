--------------------------------------------------------
--  DDL for Package Body WSH_ITM_ASYN_MSGMAP_ASSISTANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_ASYN_MSGMAP_ASSISTANT" AS
/* $Header: WSHITMAB.pls 120.2.12010000.4 2010/04/08 13:09:15 skanduku ship $ */
     --
        G_PKG_NAME CONSTANT   VARCHAR2(50) := 'WSH_ITM_ASYN_MSGMAP_ASSISTANT';
        G_ITM_LOG_LEVEL       WSH_ITM_PARAMETER_SETUPS_B.VALUE%TYPE;
        G_LOG_FILENAME        VARCHAR2(100);
        G_FILE_PTR            UTL_FILE.File_Type;
        G_REQ_CONTROL_ID      VARCHAR(50); --Bug 9226895 changed from number
        G_PRV_REQ_CONTROL_ID  VARCHAR(50):= '-1';--Bug 9226895
        G_DEBUG_PROCESS       BOOLEAN;
        --
        PROCEDURE Close_Debug;
        --
	/*
        ** This procedure is used have a post process Procedure call
        ** that updates the request control table with appropriate
        ** response header and process flag values
        **
        ** p_request_control_id - REQUEST CONTROL ID
        ** p_response_header_id - RESPONSE HEADER ID
        ** p_process_flag       - PROCESS FLAG
        **
        */
        PROCEDURE UPDATE_REQCTRL_REC( p_request_control_id      IN      NUMBER,
                                      p_response_header_id      IN      NUMBER,
                                      p_process_flag            IN      NUMBER) IS
        --
           l_debug_on    BOOLEAN;
           l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_REQCTRL_REC';
        --
        BEGIN
	--

                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_request_control_id', p_request_control_id );
                       WSH_DEBUG_SV.Log(l_module_name, 'p_response_header_id', p_response_header_id );
                       WSH_DEBUG_SV.Log(l_module_name, 'p_process_flag', p_process_flag );
                   END IF;

                --UPDATING TABLE WSH_ITM_REQUEST_CONTROL WITH RESPECTIVE
                --      RESPONSE_HEADER_ID and PROCESS_FLAG

                UPDATE WSH_ITM_REQUEST_CONTROL SET
                        RESPONSE_HEADER_ID = p_response_header_id,
                        PROCESS_FLAG = p_process_flag
                          WHERE REQUEST_CONTROL_ID = p_request_control_id;
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --

        END UPDATE_REQCTRL_REC;

        /*
        ** This procedure is used when there is an error tag in the header
        ** level, i.e.. under response tag and it for multiple requests clubbed
        ** in a single XML Request. In this case, multiple response headers
        ** should be created for the respective request records and their request
        ** records updated with the appropriate values.
        **
        ** p_message_id         - MESSAGE ID (part of incoming response message)
        ** p_error_code         - ERROR CODE
        ** p_error_type         - ERROR TYPE
        ** p_error_text         - ERROR MESSAGE
        **
        */
        PROCEDURE INSERT_ERROR( p_message_id    IN      VARCHAR2,
                                p_error_code    IN      VARCHAR2,
                                p_error_type    IN      VARCHAR2,
                                p_error_text    IN      VARCHAR2) IS
                l_reqclrt_ids           VARCHAR2(2000); --Bug 9226895
                l_service_type_code     VARCHAR2(10);
                l_vendor_id             VARCHAR2(10);
                l_reqclrt_id            VARCHAR2(50);
                l_response_header_id    NUMBER  DEFAULT -99;
                --
                l_debug_on    BOOLEAN;
                l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ERROR';
                --
         BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_message_id', p_message_id );
                       WSH_DEBUG_SV.Log(l_module_name, 'p_error_code', p_error_code );
                       WSH_DEBUG_SV.Log(l_module_name, 'p_error_type', p_error_type );
                       WSH_DEBUG_SV.Log(l_module_name, 'p_error_text', p_error_text );
                   END IF;
                   --

                TOKENIZE_MESSAGEID(p_message_id, l_reqclrt_ids, l_service_type_code, l_vendor_id);

                LOOP
                        l_reqclrt_id := SUBSTR(l_reqclrt_ids, 0, (INSTR(l_reqclrt_ids, '-')-1));
                        IF (l_reqclrt_id IS NULL) THEN


                                BEGIN
                                        SELECT WSH_ITM_RESPONSE_HEADERS_S.NEXTVAL INTO l_response_header_id FROM DUAL;
                                        INSERT INTO WSH_ITM_RESPONSE_HEADERS
                                        (
                                                RESPONSE_HEADER_ID,
                                                REQUEST_CONTROL_ID,
                                                VENDOR_ID,
                                                SERVICE_TYPE_CODE,
                                                MESSAGE_ID,
                                                RESPONSE_DATE,
                                                ERROR_TYPE,
                                                ERROR_CODE,
                                                ERROR_TEXT,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_LOGIN
                                        )
                                        VALUES
                                        (
                                                l_response_header_id,
                                                l_reqclrt_ids,
                                                l_vendor_id,
                                                l_service_type_code,
                                                p_message_id,
                                                SYSDATE,
                                                p_error_type,
                                                p_error_code,
                                                p_error_text,
                                                SYSDATE,
                                                1,
                                                SYSDATE,
                                                1,
                                                1
                                        );
                                EXCEPTION
                                        WHEN OTHERS THEN
                                                NULL;
                                END;

                                UPDATE WSH_ITM_REQUEST_CONTROL SET
                                        PROCESS_FLAG = 2,
                                        RESPONSE_HEADER_ID = l_response_header_id
                                        WHERE REQUEST_CONTROL_ID=l_reqclrt_ids;

                                EXIT;
                        ELSE

                                BEGIN

                                        SELECT WSH_ITM_RESPONSE_HEADERS_S.NEXTVAL INTO l_response_header_id FROM DUAL;
                                        INSERT INTO WSH_ITM_RESPONSE_HEADERS
                                        (
                                                RESPONSE_HEADER_ID,
                                                REQUEST_CONTROL_ID,
                                                VENDOR_ID,
                                                SERVICE_TYPE_CODE,
                                                MESSAGE_ID,
                                                RESPONSE_DATE,
                                                ERROR_TYPE,
                                                ERROR_CODE,
                                                ERROR_TEXT,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                CREATION_DATE,
                                                CREATED_BY,
                                                LAST_UPDATE_LOGIN
                                        )
                                        VALUES
                                        (
                                                l_response_header_id,
                                                l_reqclrt_id,
                                                l_vendor_id,
                                                l_service_type_code,
                                                p_message_id,
                                                SYSDATE,
                                                p_error_type,
                                                p_error_code,
                                                p_error_text,
                                                SYSDATE,
                                                1,
                                                SYSDATE,
                                                1,
                                                1
                                        );
                                EXCEPTION
                                        WHEN OTHERS THEN
                                                NULL;
                                END;

                                UPDATE WSH_ITM_REQUEST_CONTROL SET
                                        PROCESS_FLAG = 2,
                                        RESPONSE_HEADER_ID = l_response_header_id
                                        WHERE REQUEST_CONTROL_ID = l_reqclrt_id;

                        END IF;
                        l_reqclrt_ids := SUBSTR(l_reqclrt_ids, (INSTR(l_reqclrt_ids, '-')+1));
                END LOOP;
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --

        END INSERT_ERROR;

        /*
        ** This procedure is used especially for parsing the message_id
        ** value and returns req_ctrl_ids, service_code for the request, vendor_id.

        **
        ** p_message_id         - MESSAGE ID
        ** x_reqclrt_ids        - REQUEST CONTROL IDs separated by '-'
        ** x_service_type_code  - SERVICE CODES for current trasaction
        ** x_vendor_id          - VENDOR Id of vendor used for the
        **                              transaction
        **
        */
        PROCEDURE TOKENIZE_MESSAGEID( p_message_id              IN      VARCHAR2,
                                      x_reqclrt_ids             OUT NOCOPY      VARCHAR2,
                                      x_service_type_code       OUT NOCOPY      VARCHAR2,
                                      x_vendor_id               OUT NOCOPY      VARCHAR2) IS
                   l_temp_id       VARCHAR2(500);
                   --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TOKENIZE_MESSAGEID';
                   --

	BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_message_id', p_message_id );
                   END IF;
                   --

                x_reqclrt_ids           := substr(p_message_id, 0, (instr(p_message_id, '~')-1));
                l_temp_id               := substr(p_message_id, (instr(p_message_id, '~')+1));
                x_service_type_code     := substr(l_temp_id, 0, (instr(l_temp_id, '~')-1));
                x_vendor_id             := substr(l_temp_id,    (instr(l_temp_id, '~')+1));
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --
        END TOKENIZE_MESSAGEID;

        /*
        ** This procedure is used especially for parsing the party ID
        ** which comes as part of the incoming XML response and
        ** retuns the party_id that maps to WSH_ITM_PARTIES Table as out variables.
        **
        ** p_party_id           - PARTY ID AS PER THE RESPONSE XML MESSAGE
        ** x_actual_party_id    - Party ID as per in WSH_ITM_PARTIES Table
        **
        */
        PROCEDURE TOKENIZE_PARTYID(     p_party_id      IN      VARCHAR2,
                                        x_actual_party_id OUT NOCOPY    VARCHAR2) IS
                  --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TOKENIZE_PARTYID';
                  --
	BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_party_id', p_party_id );
                   END IF;
                   --

                x_actual_party_id := substr(p_party_id, (instr(p_party_id, '-')+1));
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --

        END TOKENIZE_PARTYID;

        /*
        ** For processing response Acknowledgements, in case the request is sent
        ** Asynchronously and the acknowledgment is also received Asynchronously,
        ** the Message Map has calls this procedure to update the process flag to
        ** '-4'(Marking the request record as ACKNOLEDGMENT received.
        **
        ** p_message_id         - MESSAGE ID for which acknowledgement is received.
        **
        */
        PROCEDURE PROCESS_ACK_RECEIPT(p_message_id      IN      VARCHAR2) IS
                l_reqclrt_ids           VARCHAR2(2000); --Bug 9226895
                l_reqclrt_id            varchar2(50);
                l_service_type_code     VARCHAR2(250);
                l_vendor_id             VARCHAR2(100);
                  --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_ACK_RECEIPT';
                  --
       BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_message_id', p_message_id );
                   END IF;
                   --

                --GET THE ERQUEST CONTROL IDS
                TOKENIZE_MESSAGEID(p_message_id, l_reqclrt_ids, l_service_type_code, l_vendor_id);
                --CURRENTLY WE UPDATE THE WSH_REQUEST_CONTROL TABLE
                -- PROCESS FLAG TO -4  FOR ALL REQUEST_CONTROL_IDS
                -- WHO HAVE NOT RECEIVED ANY ACTUAL RESPONSES.
                loop
                        l_reqclrt_id := substr(l_reqclrt_ids, 0, (instr(l_reqclrt_ids, '-')-1));
                        IF (l_reqclrt_id IS NULL) THEN

                                UPDATE WSH_ITM_REQUEST_CONTROL
                                        SET PROCESS_FLAG = -4
                                        WHERE REQUEST_CONTROL_ID = l_reqclrt_ids
                                        AND PROCESS_FLAG IN (-2, -3);
                                EXIT;
                        ELSE
                                UPDATE WSH_ITM_REQUEST_CONTROL
                                        SET PROCESS_FLAG = -4
                                        WHERE REQUEST_CONTROL_ID = l_reqclrt_id
                                        AND PROCESS_FLAG IN (-2, -3);
                        END IF;
                        l_reqclrt_ids := substr(l_reqclrt_ids, (instr(l_reqclrt_ids, '-')+1));
                end loop;
                  --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --

        END PROCESS_ACK_RECEIPT;

        /*
        ** This procedure is used to update DENIED_PARTY_MATCH flag in WSH_ITM_RESPONSE_LINES
        ** Table if a DENIED_PARTY_MATCH tag is found in the response.
        **
        ** p_response_line_id - RESPONSE LINE ID FOR WHICH DENIED PARTY HAS BEEN
        **                      FOUND IN THE RECEIVED RESPONSE.
        **
        */
        PROCEDURE UPDATE_DENIED_PARTY_MATCH(p_response_line_id  IN NUMBER) IS
                  --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DENIED_PARTY_MATCH';
                   --
	BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_response_line_id', p_response_line_id );
                   END IF;
                   --

                --UPDATE WSH_ITM_RESPONSE_LINES SET DENIED_PARTY_MATCH = 'y'
                UPDATE WSH_ITM_RESPONSE_LINES
                        SET DENIED_PARTY_FLAG = 'Y'
                        WHERE RESPONSE_LINE_ID = p_response_line_id;
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --
       END UPDATE_DENIED_PARTY_MATCH;

        /*
        ** Create a new response header record in case x_create_resp_hdr = 1
        ** else, uses the response header ID returned to create the lines
        ** record for the header.
        **
        ** p_request_control_id         - REQUEST CONTROL ID
        ** x_response_header_id         - RESPONSE HEADER ID
        ** x_create_resp_hdr            1    - HEADER EXISTING (NO NEED TO CREATE)
        **                              NULL - NEW HEADER (INSERT DATA TO HDR TABLE)
        **
        */
        PROCEDURE GET_RESPONSE_HDR(p_request_control_id IN NUMBER,
                                   x_response_header_id OUT NOCOPY  NUMBER,
                                   x_create_resp_hdr    OUT NOCOPY  NUMBER) IS
                  --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_RESPONSE_HDR';
                   --
        BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_request_control_id', p_request_control_id );
                   END IF;
                   --
                BEGIN

                        SELECT RESPONSE_HEADER_ID INTO x_response_header_id
                                FROM WSH_ITM_REQUEST_CONTROL
                                        WHERE REQUEST_CONTROL_ID = p_request_control_id
                                        AND ROWNUM < 2;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                x_response_header_id := NULL;
                END;

                IF x_response_header_id IS NULL THEN
                        SELECT WSH_ITM_RESPONSE_HEADERS_S.NEXTVAL INTO
                                x_response_header_id FROM DUAL;
                        x_create_resp_hdr := 1;
                ELSE
                        x_create_resp_hdr := NULL;
                END IF;
                  --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --
        END GET_RESPONSE_HDR;

        /*
        ** As message Map calls with message ID a new procedure which first
        ** parses the message id and then calls WSH_ITM_POST_PROCESS_HANDLER.CHECK_PENDING_CALL_API
        ** for further processing.
        **
        ** p_message_ID         - MESSAGE ID received.
        **
        */
        PROCEDURE MESSAGE_POSTPROCESS(p_message_ID IN VARCHAR2) IS

                l_reqclrt_ids           VARCHAR2(2000); --Bug 9226895
                l_service_type_code     VARCHAR2(100);
                l_vendor_id             VARCHAR2(5);
                l_reqclrt_id            NUMBER;
                l_request_set_id        NUMBER;
                l_application_id        NUMBER;
                  --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MESSAGE_POSTPROCESS1';
                   --
        BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_message_ID', p_message_ID );
                   END IF;
                   --


                -- get request control IDs
                TOKENIZE_MESSAGEID(p_message_ID,
                                 l_reqclrt_ids,
                                 l_service_type_code,
                                 l_vendor_id);
                LOOP
                        l_reqclrt_id := substr(l_reqclrt_ids, 0, (instr(l_reqclrt_ids, '-')-1));
                        IF (l_reqclrt_id IS NULL) THEN
                                l_reqclrt_id := l_reqclrt_ids;
                                SELECT REQUEST_SET_ID,
                                       APPLICATION_ID
                                INTO   l_request_set_id,
                                       l_application_id
                                FROM   WSH_ITM_REQUEST_CONTROL
                                WHERE  REQUEST_CONTROL_ID = l_reqclrt_id;

                                WSH_ITM_POST_PROCESS_HANDLER.CHECK_PENDING_CALL_API(l_reqclrt_id,
                                                                                    l_request_set_id,
                                                                                    l_application_id,
                                                                                    'ITM'); --Bug 9226895  replaced ECX with ITM
                                EXIT;
                        ELSE
                                SELECT REQUEST_SET_ID,
                                       APPLICATION_ID
                                INTO   l_request_set_id,
                                       l_application_id
                                FROM   WSH_ITM_REQUEST_CONTROL
                                WHERE  REQUEST_CONTROL_ID = l_reqclrt_id;

                                WSH_ITM_POST_PROCESS_HANDLER.CHECK_PENDING_CALL_API(l_reqclrt_id,
                                                                                    l_request_set_id,
                                                                                    l_application_id,
                                                                                    'ITM'); --Bug 9226895  replaced ECX with ITM
                        END IF;
                        l_reqclrt_ids := substr(l_reqclrt_ids, (instr(l_reqclrt_ids, '-')+1));

                END LOOP;
                  --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --

                   Close_Debug;

        END MESSAGE_POSTPROCESS;

        /*
        ** As message Map calls with requestCtrl ID a new procedure which first
        ** gets the requestSetID and application id and then calls
        ** WSH_ITM_POST_PROCESS_HANDLER.CHECK_PENDING_CALL_API
        ** for further processing.
        **
        ** p_reqCtrlID          - REQUEST CONTROL ID received.
        **
        */
        PROCEDURE MESSAGE_POSTPROCESS(p_reqCtrlID  NUMBER) IS
                l_request_set_id        NUMBER;
                l_application_id        NUMBER;
                  --
                   l_debug_on    BOOLEAN;
                   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'MESSAGE_POSTPROCESS';
                   --
        BEGIN
                   --
                   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
                   --
                   IF ( l_debug_on IS NULL )
                   THEN
                       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
                   END IF;
                   --
                   IF l_debug_on THEN
                       WSH_DEBUG_SV.Push(l_module_name);
                       WSH_DEBUG_SV.Log(l_module_name, 'p_request_control_id', p_reqCtrlID );
                   END IF;
                   --

                SELECT NVL(REQUEST_SET_ID, 0),
                       APPLICATION_ID
                INTO   l_request_set_id,
                       l_application_id
                FROM   WSH_ITM_REQUEST_CONTROL
                WHERE  REQUEST_CONTROL_ID = p_reqCtrlID;

                WSH_ITM_POST_PROCESS_HANDLER.CHECK_PENDING_CALL_API(p_reqCtrlID,
                                                                    l_request_set_id,
                                                                    l_application_id,
                                                                    'ITM');--Bug 9226895  replaced ECX with ITM

                  --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.Pop(l_module_name);
                   END IF;
                   --
        END MESSAGE_POSTPROCESS;
          PROCEDURE Initialize_Debug(p_reference_id VARCHAR2) IS
              l_file_ptr        UTL_FILE.File_Type;
              l_log_directory   VARCHAR2(4000);
              l_log_filename    VARCHAR2(100);
              l_dbg_level       VARCHAR2(100);
              l_dbg_module      VARCHAR2(100);
              l_req_control_ids VARCHAR2(2000); --Bug 9226895
              --
              l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Initialize_Debug';
              --
           BEGIN

              l_req_control_ids := substr(p_reference_id, 0, (instr(p_reference_id, '~')-1)); --Bug 9226895  seperate out Request control ids

              g_req_control_id := substr(l_req_control_ids, 0, (instr(l_req_control_ids, '-')-1)); --Bug 9226895  take out the first Request control id

              IF ( g_req_control_id IS NULL )--Bug 9226895  if only one Request control id is present.
              THEN
              --{
                   g_req_control_id := l_req_control_ids;
              --}
              END IF;

              IF G_ITM_LOG_LEVEL IS NULL THEN
              BEGIN
                 select value
                 into   G_ITM_LOG_LEVEL
                 from   WSH_ITM_PARAMETER_SETUPS_B
                 where  parameter_name = 'WSH_ITM_LOG_SEVERITY';

              EXCEPTION
                 when no_data_found then
                    G_ITM_LOG_LEVEL := '0';
              END;
              END IF;

              IF G_ITM_LOG_LEVEL = '1' THEN
              BEGIN
                 IF G_LOG_FILENAME IS NULL OR
                    G_PRV_REQ_CONTROL_ID <> G_REQ_CONTROL_ID
                 THEN
                    --Generating log file for each Request Control even if it processed
                    --within one concurrent process
                    --Close the file if its already open
                    IF G_PRV_REQ_CONTROL_ID <> G_REQ_CONTROL_ID THEN
                       IF utl_file.is_open(g_file_ptr) THEN
                          utl_file.fclose(g_file_ptr);
                       END IF;
                    END IF;

                    G_PRV_REQ_CONTROL_ID := G_REQ_CONTROL_ID;

                    --Get profile option value from SITE level for debug log directory
                    l_log_directory := FND_PROFILE.VALUE_SPECIFIC( 'WSH_DEBUG_LOG_DIRECTORY', -1, -1, -1, -1, -1 );
                    l_dbg_level     := FND_PROFILE.VALUE_SPECIFIC( 'WSH_DEBUG_LEVEL', -1, -1, -1, -1, -1 );
                    l_dbg_module    := FND_PROFILE.VALUE_SPECIFIC( 'WSH_DEBUG_MODULE', -1, -1, -1, -1, -1 );

                    FND_PROFILE.PUT('WSH_DEBUG_LEVEL', l_dbg_level);
                    FND_PROFILE.PUT('WSH_DEBUG_MODULE',l_dbg_module);

                    --G_LOG_FILENAME := 'wshitm_async_' || g_req_control_id || '.dbg';

                    G_LOG_FILENAME := 'wshitm_' || g_req_control_id  || '_' || to_char(sysdate,'MMYYHH24MISS') ||'.dbg';

                    l_file_ptr := UTL_FILE.Fopen(l_log_directory, G_LOG_FILENAME, 'a');

                    --Debug messages will be generated in a log file instead of
                    --being printed in concurrent request log file
                    WSH_DEBUG_SV.G_ITM_ASYN_PROC := TRUE;

                    WSH_DEBUG_INTERFACE.Start_Debugger(
                       p_dir_name    => l_log_directory,
                       p_file_name   => G_LOG_FILENAME,
                       p_file_handle => l_file_ptr );
                    OE_DEBUG_PUB.Start_ONT_Debugger(
                       p_directory   => l_log_directory,
                       p_filename    => G_LOG_FILENAME,
                       p_file_handle => l_file_ptr );

                    G_FILE_PTR := l_file_ptr;
                    G_DEBUG_PROCESS := TRUE;

                    --Deleting pl/sql table g_CallStack so that debug messages
                    --will be indented properly if more than one ITM request
                    --controls are processed by same concurrent process.
                    WSH_DEBUG_SV.g_CallStack.DELETE;
                    --Calling Set_Debug_Count to reinitialize debug global
                    --variables in debug package WSH_DEBUG_SV
                    WSH_DEBUG_SV.Set_Debug_Count;

                    WSH_DEBUG_SV.Push(l_module_name);
                    WSH_DEBUG_SV.Log(l_module_name, 'Concurrent Request Id', fnd_global.conc_request_id );
                    WSH_DEBUG_SV.Log(l_module_name, 'User Name', fnd_global.user_name );
                    WSH_DEBUG_SV.Log(l_module_name, 'Responsibility Id', fnd_global.resp_id );
                    WSH_DEBUG_SV.Log(l_module_name, 'Responsibility Application Id', fnd_global.resp_appl_id );
                    WSH_DEBUG_SV.Pop(l_module_name);
                 ELSE
                    G_DEBUG_PROCESS := FALSE;
                 END IF;

              -- Added Exception handler so that we will proceed further
              -- even if file handling raises any exception.
              EXCEPTION
                WHEN OTHERS THEN
                  G_DEBUG_PROCESS := FALSE;
              END;
              END IF;
           END Initialize_Debug;

           PROCEDURE Close_Debug IS
              --
              l_debug_on    BOOLEAN;
              l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Close_Debug';
              --
           BEGIN
              --
              l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
              --
              IF ( l_debug_on IS NULL )
              THEN
                  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
              END IF;
              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.Push(l_module_name);
                  WSH_DEBUG_SV.Logmsg(l_module_name, 'Closing debug log file' );
                  WSH_DEBUG_SV.Pop(l_module_name);

                  --If ITM Log Severity is set to DEBUG then disable Shipping and OM Debugging
                  WSH_DEBUG_INTERFACE.stop_debugger;
                  OE_DEBUG_PUB.STOP_ONT_DEBUGGER;
                  --
              END IF;
              --

              IF ( G_DEBUG_PROCESS ) THEN
                 IF utl_file.is_open(g_file_ptr) THEN
                    utl_file.fclose(g_file_ptr);
                 END IF;
              END IF;

           -- Added Exception handler so that we will proceed further
           -- even if file handling raises any exception.
           EXCEPTION
              WHEN OTHERS THEN
                 null;
           END Close_Debug;
           --Added the procedure Get_Valid_Reference_Id for the bug 9544400
           -- Inputs: reference_id VARCHAR2
           --         request_control_id NUMBER
           --         The API removes the given request_control_id from the string 'reference_id'.
           PROCEDURE Get_Valid_Reference_Id
                    ( p_reference_id IN OUT NOCOPY VARCHAR2 ,
                      p_request_ctrl_id IN NUMBER)IS

             l_reference_id VARCHAR2(2000);
             --
             l_debug_on    BOOLEAN;
             l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Valid_Reference_Id';
             --
             BEGIN
               --
               l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
               --
               IF ( l_debug_on IS NULL ) THEN
                   l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
               END IF;
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.push(l_module_name);
                   WSH_DEBUG_SV.Log(l_module_name, 'p_reference_id',p_reference_id);
                   WSH_DEBUG_SV.Log(l_module_name, 'Request_control_id that will be removed from p_reference_id',p_request_ctrl_id);
               END IF;

               --
               SELECT Decode(InStr(p_reference_id, '-' ||p_request_ctrl_id),0, REPLACE(p_reference_id, p_request_ctrl_id||'-', ''),REPLACE(p_reference_id, '-'||p_request_ctrl_id, '') )
               INTO
               l_reference_id
               FROM dual;

               IF l_debug_on THEN
                   WSH_DEBUG_SV.Log(l_module_name, 'New p_reference_id',l_reference_id);
                   WSH_DEBUG_SV.pop(l_module_name);
               END IF;

               p_reference_id := l_reference_id;
                   /*No exception block is being added, since The caller(ECX)
                     would take care and stop the process if any exception is raised here */
           END Get_Valid_Reference_Id;


END WSH_ITM_ASYN_MSGMAP_ASSISTANT;

/
