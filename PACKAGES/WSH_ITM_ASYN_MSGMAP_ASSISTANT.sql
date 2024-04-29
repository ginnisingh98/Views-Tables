--------------------------------------------------------
--  DDL for Package WSH_ITM_ASYN_MSGMAP_ASSISTANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_ASYN_MSGMAP_ASSISTANT" AUTHID CURRENT_USER AS
/* $Header: WSHITMAS.pls 120.0.12010000.3 2010/04/08 13:08:11 skanduku ship $ */
        /*
                Procedure to set the process flag
        */
        PROCEDURE UPDATE_REQCTRL_REC(p_request_control_id       IN      NUMBER,
                                      p_response_header_id      IN      NUMBER,
                                      p_process_flag            IN      NUMBER);

        PROCEDURE INSERT_ERROR( p_message_id    IN      VARCHAR2,
                                p_error_code    IN      VARCHAR2,
                                p_error_type    IN      VARCHAR2,
                                p_error_text    IN      VARCHAR2);

        PROCEDURE TOKENIZE_MESSAGEID( p_message_id              IN      VARCHAR2,
                                   x_reqclrt_ids        OUT NOCOPY      VARCHAR2,
                                   x_service_type_code  OUT NOCOPY      VARCHAR2,
                                   x_vendor_id          OUT NOCOPY      VARCHAR2);

        PROCEDURE TOKENIZE_PARTYID(     p_party_id      IN      VARCHAR2,
                                        x_actual_party_id OUT NOCOPY    VARCHAR2);

        PROCEDURE PROCESS_ACK_RECEIPT(p_message_id      IN      VARCHAR2);

        PROCEDURE UPDATE_DENIED_PARTY_MATCH(p_response_line_id  NUMBER);

        PROCEDURE GET_RESPONSE_HDR(p_request_control_id IN NUMBER,
                                   x_response_header_id OUT NOCOPY  NUMBER,
                                   x_create_resp_hdr    OUT NOCOPY  NUMBER);
        PROCEDURE MESSAGE_POSTPROCESS(p_message_ID VARCHAR2);

        PROCEDURE MESSAGE_POSTPROCESS(p_reqCtrlID  NUMBER);

        PROCEDURE Initialize_Debug(p_reference_id VARCHAR2); --Bug 9226895

        --Added the procedure Get_Valid_Reference_Id for bug 9544400
        -- Inputs: reference_id VARCHAR2
        --         request_control_id NUMBER
        --         The API removes the given request_control_id from the string 'reference_id'.

        PROCEDURE Get_Valid_Reference_Id (p_reference_id IN OUT NOCOPY VARCHAR2 ,
                                          p_request_ctrl_id IN NUMBER );


END WSH_ITM_ASYN_MSGMAP_ASSISTANT;

/
