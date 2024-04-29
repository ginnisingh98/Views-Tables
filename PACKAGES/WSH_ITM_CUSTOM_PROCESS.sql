--------------------------------------------------------
--  DDL for Package WSH_ITM_CUSTOM_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_CUSTOM_PROCESS" AUTHID CURRENT_USER AS
/* $Header: WSHITPPS.pls 120.0.12010000.3 2008/11/28 06:06:37 sankarun ship $ */

     PROCEDURE PRE_PROCESS_WSH_REQUEST (
                    p_request_control_id IN NUMBER
                    );
     PROCEDURE POST_PROCESS_WSH_REQUEST (
                    p_request_control_id IN NUMBER
                    );

     PROCEDURE PRE_PROCESS_ONT_REQUEST(
                    p_request_control_id IN NUMBER,
                    p_line_id     IN  NUMBER
                     );

     PROCEDURE POST_PROCESS_ONT_REQUEST(
                    p_request_control_id IN NUMBER
                     );

     /* Bug 7284454 - Added funciton GRP_MODEL_LINES_IN_SINGLE_REQ, to provide
                      option to customer to send all components of PTO model
		      in Single Request XML
		    - Return variable should not be more than one character        */

     FUNCTION GRP_MODEL_LINES_IN_SINGLE_REQ Return Varchar2;

END;

/
