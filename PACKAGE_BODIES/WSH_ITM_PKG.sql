--------------------------------------------------------
--  DDL for Package Body WSH_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_PKG" AS
/* $Header: WSHITPCB.pls 120.2.12010000.3 2010/02/16 17:21:29 skanduku ship $ */

    G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_PKG';
    G_SUB_PICK_RELEASE_EXCEPTION CONSTANT VARCHAR2(30) := 'WSH_PR_SUB_EXPORT_COMPL';
    G_SUB_SHIP_CONFIRM_EXCEPTION CONSTANT VARCHAR2(30) := 'WSH_SC_SUB_EXPORT_COMPL';
    G_FAIL_EXP_COMPL_EXCEPTION   CONSTANT VARCHAR2(30) := 'WSH_EXPORT_COMPL_FAILED';
    G_PICK_RELEASE_EVENT         CONSTANT VARCHAR2(20) := 'PICK_RELEASE';
    G_SHIP_CONFIRM_EVENT         CONSTANT VARCHAR2(20) := 'SHIP_CONFIRM';
    G_SERVICE_TYPE_CODE          CONSTANT VARCHAR2(30) := 'WSH_EXPORT_COMPLIANCE';


    G_WF_PICK_RELEASE_EVENT_NAME CONSTANT VARCHAR2(100) :=
	  		      	'oracle.apps.wsh.delivery.itm.responsereceivedatdelcreate';
    G_WF_SHIP_CONFIRM_EVENT_NAME CONSTANT VARCHAR2(100) :=
				'oracle.apps.wsh.delivery.itm.responsereceivedatship';



    /*==========================================================================+
    | PROCEDURE                                                                 |
    |              WSH_ITM_WSH                                                  |
    | PARAMETERS                                                                |
    |                                                                           |
    |  p_request_control_id => This is the request_control which uniquely       |
    |                            identifies the request information from the    |
    |                            request control table.                         |
    |   p_request_set_id    => This parameter is not being used in the current  |
    |                            procedure,but is included to comply with       |
    |                            itm standards.                                 |
    | DESCRIPTION                                                               |
    |              This procedure is called by ITM Application                  |
    |              When a response is recived from The Partner Application      |
    |              Informing  the status of export compliance request.          |
    |              This API does the post processing operations depending on    |
    |              the status of screening.                                     |
    |                                                                           |
    |                                                                           |
    |                                                                           |
    +===========================================================================*/



        PROCEDURE WSH_ITM_WSH (
                               p_request_control_id IN NUMBER,
                               p_request_set_id IN NUMBER
                              )
                               IS


                --Declaration Cursor  For Export Compliance Query
                --Bug 9277386:Added column Interpreted_Value_Code from WSH_ITM_RESPONSE_RULES
                CURSOR C_EXP_COMPL_QUERY(p_req_ctrl_id NUMBER, p_status VARCHAR2) is
                         SELECT RL.EXPORT_COMPLIANCE_TYPE COMPL_TYPE,
                                DECODE(RL.EXPORT_COMPLIANCE_SUCCESS, 'Y', 'COMPLIANT', 'N', 'NOT_COMPLIANT') COMPL_STATUS,
                                RL.EXPORT_COMPLIANCE_DESCRIPTION COMPL_DESC,
                                RL.ERROR_CODE ERROR_CODE,
                                RL.ERROR_TYPE ERROR_TYPE,
                                RL.ERROR_TEXT ERROR_TEXT,
                                WRR.INTERPRETED_VALUE_CODE INTERPRETED_VALUE
                         FROM   WSH_ITM_RESPONSE_HEADERS RH,
                                WSH_ITM_RESPONSE_LINES RL,
                                WSH_ITM_REQUEST_CONTROL  REQ,
                                WSH_ITM_RESPONSE_RULES WRR
                         WHERE
                                REQ.REQUEST_CONTROL_ID = p_req_ctrl_id  AND
                                REQ.RESPONSE_HEADER_ID = RH.RESPONSE_HEADER_ID AND
                                RH.RESPONSE_HEADER_ID = RL.RESPONSE_HEADER_ID AND
                                UPPER(RH.EXPORT_COMPLIANCE_STATUS) = p_status AND
                                WRR.ERROR_CODE(+) = RL.error_code AND
                                WRR.ERROR_TYPE(+) =RL.ERROR_TYPE;


               -- Declaration Section For Log/close Exception Section

                i                       number;

                l_api_version           NUMBER := 1.0;
                l_return_status         VARCHAR2(1);
                l_msg_count             NUMBER;
                l_msg_data              VARCHAR2(2000); --Bug 7125729:Increasing message buffer size
                l_validation_level      NUMBER  default  FND_API.G_VALID_LEVEL_FULL;

                l_old_status            VARCHAR2(30);
                l_new_status            VARCHAR2(30);
                l_default_status        VARCHAR2(1);

                l_exception_message     varchar2(2000);
                l_exception_name        varchar2(30);

                l_location_id           NUMBER;
                l_delivery_id           NUMBER;
                l_delivery_name         VARCHAR2(30);
                l_exception_id          NUMBER;
                xx_exception_id         NUMBER;

                l_exception_found       boolean := true;
                l_event_name            VARCHAR2(20);

                --
                l_process_flag          NUMBER;
                l_interpreted_value    VARCHAR2(10);--Bug 9277386
		--for Workflow process
		l_wf_event_name  VARCHAR2(1000);
		l_wf_return_status  VARCHAR2(1);
		l_organization_id NUMBER;

           BEGIN


                SAVEPOINT WSH_ITM_POST_COMPL;

                -------------------------------------------------------------------------------
                -- Post Processing Section
                -------------------------------------------------------------------------------

		-- This sub section checks if the process is completed
                SELECT PROCESS_FLAG INTO L_PROCESS_FLAG
                FROM WSH_ITM_REQUEST_CONTROL
                WHERE REQUEST_CONTROL_ID = P_REQUEST_CONTROL_ID;



                -- This Sub Section Fetches The Location Code,Delivery Name for Submitted Exception

                BEGIN
                        SELECT  WE.EXCEPTION_LOCATION_ID,
                                WE.DELIVERY_ID,
                                WE.DELIVERY_NAME,
                                WE.EXCEPTION_ID,
                                IRC.TRIGGERING_POINT,
                                WE.STATUS,
				IRC.ORGANIZATION_ID
                        INTO    l_location_id,
                                l_delivery_id,
                                l_delivery_name,
                                l_exception_id,
                                l_event_name,
                                l_old_status,
				l_organization_id
                        FROM    WSH_EXCEPTIONS WE ,
                                WSH_ITM_REQUEST_CONTROL IRC
                        WHERE WE.DELIVERY_ID =  IRC.ORIGINAL_SYSTEM_REFERENCE
                        AND  WE.EXCEPTION_NAME = DECODE(IRC.TRIGGERING_POINT,G_PICK_RELEASE_EVENT,G_SUB_PICK_RELEASE_EXCEPTION,G_SHIP_CONFIRM_EVENT,G_SUB_SHIP_CONFIRM_EXCEPTION)
                        AND  IRC.REQUEST_CONTROL_ID = P_REQUEST_CONTROL_ID
			AND WE.STATUS <> 'CLOSED';

			--Raise Functional Event that could be customized by the Workflow
			IF l_event_name= 'PICK_RELEASE' THEN
				l_wf_event_name := G_WF_PICK_RELEASE_EVENT_NAME;
			ELSIF l_event_name = 'SHIP_CONFIRM' THEN
				l_wf_event_name := G_WF_SHIP_CONFIRM_EVENT_NAME;
			END IF;

			WSH_ITM_EXPORT_SCREENING.RAISE_ITM_EVENT
			(
				p_event_name => l_wf_event_name ,
				p_delivery_id => l_delivery_id,
				p_organization_id => l_organization_id,
				x_return_status => l_wf_return_status
			);

			--End of Functional Event that could be customized by the Workflow
                EXCEPTION
                        WHEN OTHERS THEN
                                 RETURN;
                END;

                -- This Section Takes The Required Action Based on Process Flag and Compliance's Success
                IF l_process_flag  = 1 THEN

                        l_exception_message := NULL;

                        --Retreiving Type, Success and Description columns from the
                        -- Response lines table.
                        FOR l_nonComplRec IN C_EXP_COMPL_QUERY(p_request_control_id, 'NOT_COMPLIANT') LOOP
                                l_exception_message := l_exception_message||' - '||l_nonComplRec.COMPL_TYPE||
                                                        ' '|| l_nonComplRec.COMPL_STATUS ||
                                                        ' '||l_nonComplRec.COMPL_DESC;
                        END LOOP;
                        -- When Compliance Failed
                        IF l_exception_message is NOT NULL THEN
                                -- Sub Section Logs a new Exception For Compliance Failure
                                l_return_status  := NULL;
                                l_msg_count      := NULL;
                                l_msg_data       := NULL;
                                xx_exception_id   := NULL;
                                l_exception_name := G_FAIL_EXP_COMPL_EXCEPTION;

                                WSH_XC_UTIL.log_exception(
                                                p_api_version             => l_api_version,
                                                p_init_msg_list           => FND_API.G_FALSE,
                                                p_commit                  => FND_API.G_FALSE,
                                                p_validation_level        => l_validation_level,
                                                x_return_status           => l_return_status,
                                                x_msg_count               => l_msg_count,
                                                x_msg_data                => l_msg_data,
                                                x_exception_id            => xx_exception_id,
                                                p_exception_location_id   => l_location_id,
                                                p_logged_at_location_id   => l_location_id,
                                                p_logging_entity          => 'SHIPPER',
                                                p_logging_entity_id       => l_delivery_id,
                                                p_exception_name          => l_exception_name,
                                                p_message                 => l_exception_message,
                                                p_delivery_id             => l_delivery_id,
                                                p_delivery_name           => l_delivery_name
                                                );

                                IF l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN


                                        if l_msg_count IS NOT NULL then
                                                WSH_UTIL_CORE.Add_Message(l_return_status);
                                                for i in 1 ..l_msg_count loop
                                                        l_msg_data := FND_MSG_PUB.get(p_msg_index => i,
                                                                                      p_encoded => 'F');

                                                end loop;
                                        END IF;

                                        -- Cleaning Operation
                                        ROLLBACK TO WSH_ITM_POST_COMPL;


                                        RETURN;
                                 END IF;
                        END IF; -- End of Compliance Failure IF Block

             --Bug 6371639: NO AUDIT TRAIL PROVIDED FOR SHIPMENTS SCREENED BY ITM FOR SUCCESSFULLY SCREENED REQUEST.
             -- Commenting the below Delete Statements to retain the Records in WSH_ITM tables

	/*		delete from wsh_itm_response_lines where response_header_id IN
                        (
                                select response_header_id
                                from wsh_itm_response_headers
                                where  request_control_id   = p_request_control_id
                        );

              		 delete from wsh_itm_response_headers where request_control_id = p_request_control_id;
	                delete from wsh_itm_request_control  where request_control_id = p_request_control_id;    */



                ELSIF l_process_flag = 2 THEN
                        -- System And Data Error Handling
                        l_exception_message := NULL;
                        FOR l_errorRec IN C_EXP_COMPL_QUERY(p_request_control_id, 'ERROR') LOOP
                                l_exception_message := l_exception_message||' - '||l_errorRec.ERROR_CODE ||
                                                        ' '|| l_errorRec.ERROR_TYPE ||
                                                        ' '||l_errorRec.ERROR_TEXT;
                                 --Bug 9277286
                                 l_interpreted_value := l_errorRec.INTERPRETED_VALUE;

                        END LOOP;
                        --Bug 9277386:Populating existing Exception's Error Message, when respose STATUS is ERROR.
                        UPDATE wsh_exceptions
                           SET error_message = l_exception_message ,
                               last_update_date = SYSDATE ,
                               last_updated_by = fnd_global.user_id
                         WHERE exception_id = l_exception_id;
                        --Bug 9277386:When the error code from Response XML is interpreted as  'SUCCESS',
                        --            updating process_flag to 1 and closing the existing ITM exceptions.
                        IF l_interpreted_value =  'SUCCESS' THEN

                            UPDATE wsh_itm_request_control
                               SET process_flag = 1 ,
                                   last_update_date= sysdate,
                                   last_updated_by = fnd_global.user_id
                             WHERE request_control_id = p_request_control_id;

                            GOTO   CLOSE_EXCEPTION;
                        ELSE
                            RETURN;
                        END IF;
                        --Bug 9277386:Whens status is 'ERROR', the exception WSH_EXPORT_COMPL_FAILED should not be logged
                        --            Deleted the code that logs new exception when status is 'ERROR'.
                END IF; -- End of Process Flag (If Block)
                ----------------------------------------------------------------------------------------
                -- Purges the data in ITM Request and Response Tables
                ----------------------------------------------------------------------------------------

               /*delete from wsh_itm_response_lines where response_header_id IN
                        (
                                select response_header_id
                                from wsh_itm_response_headers
                                where  request_control_id   = p_request_control_id
                        );
*/
              -- delete from wsh_itm_response_headers where request_control_id = p_request_control_id;
               -- delete from wsh_itm_request_control  where request_control_id = p_request_control_id;

                ----------------------------------------------------------------------------------------
                -- Handle Submitted For Export Screening Exception
                ----------------------------------------------------------------------------------------
                -- Section(Applies For Both Compliance Failure and Success) to Handle 'Submitted For Export Screening'
                <<CLOSE_EXCEPTION>>
                l_return_status  := NULL;
                l_msg_count      := NULL;
                l_msg_data       := NULL;

                l_new_status     := 'CLOSED';
                l_default_status := 'F';

                IF l_old_status = 'CLOSED' THEN
                        RETURN;
                END IF;

                WSH_XC_UTIL.change_status (
                                        p_api_version           => l_api_version,
                                        p_init_msg_list         => FND_API.G_FALSE,
                                        p_commit                => FND_API.G_FALSE,
                                        p_validation_level      => l_validation_level,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => l_msg_count,
                                        x_msg_data              => l_msg_data,
                                        p_exception_id          => l_exception_id,
                                        p_old_status            => l_old_status,
                                        p_set_default_status    => l_default_status,
                                        x_new_status            => l_new_status
                                 );

                IF l_return_status <>  WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN



                        if l_msg_count IS NOT NULL then
                                WSH_UTIL_CORE.Add_Message(l_return_status);
                                for i in 1 ..l_msg_count loop
                                        l_msg_data := FND_MSG_PUB.get(p_msg_index => i,
                                                                      p_encoded => 'F');

                                end loop;
                        end if;
                        -- Cleaning Operation
                        ROLLBACK TO WSH_ITM_POST_COMPL;
                        RETURN;

                END IF;


        EXCEPTION
                WHEN OTHERS THEN
                ROLLBACK TO WSH_ITM_POST_COMPL;
    END WSH_ITM_WSH;

END WSH_ITM_PKG;

/
