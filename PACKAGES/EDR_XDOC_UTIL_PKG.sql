--------------------------------------------------------
--  DDL for Package EDR_XDOC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_XDOC_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: EDRXDUS.pls 120.4.12000000.1 2007/01/18 05:56:50 appldev ship $ */

-- EDR_XDOC_UTIL_PKG.GENERATE_ERECORD Procedure is called from STORE_ERECORD
-- procedure of RULE FUNCTION. Its purpose is to call the JSP with all the
-- required parameters passed in URL and return ERECORD or return error message
-- if there is any error in this processing.

-- P_EDR_EVENT_ID  - Unique event id for the event being executed, for which
--                   eRecord is to be generated
-- P_ERECORD_ID    - ERecord Id for the eRecord to be generated.
-- P_STYLE_SHEET_REPOSITORY - Name of template repository to be used to generate the
--                            eRecord
-- P_STYLE_SHEET   - Template File Name as Setup in AME / Transaction Variable for
--                   this event
-- P_STYLE_SHEET_VER - Version Label of the template file as setup in AME / Transaction Variable for
--                   this event
-- X_OUTPUT_FORMAT - Format of eRecord Output viz. PDF, DOC, HTML, TEXT
-- X_ERROR_CODE    - Error Code in case of any errors
-- X_ERROR_MESSAGE - Error Message in case of any errors.

-- Bug 3170251 : start : rvsingh
-- Bug 3761813 : start : rvsingh
procedure GENERATE_ERECORD
        (
         p_edr_event_id  NUMBER,
         p_erecord_id   NUMBER,
         p_style_sheet_repository VARCHAR2,
         p_style_sheet   VARCHAR2,
         p_style_sheet_ver    VARCHAR2,
         p_application_code VARCHAR2,
         p_redline_mode VARCHAR2,
         x_output_format OUT NOCOPY VARCHAR2,
         x_error_code    OUT NOCOPY NUMBER,
         x_error_msg     OUT NOCOPY VARCHAR2
        );
-- Bug 3761813 : end : rvsingh
-- Bug 3170251 : End
-- EDR_XDOC_UTIL_PKG.EDR_CREATE_ATTACHEMENT is called from EDRRuleXMLPublisher Object.
-- It creates an FND Attachment for the eRecord PDF to be generated and returns
-- the file_id created in FND_LOBS table.

-- P_ERECORD_ID    - ERecord Id for the eRecord to be generated.
-- P_FILE_NAME     - Name of EReocrd File
-- P_STYLE_SHEET   - ERecord File Description
-- P_CONTENT_TYPE  - ERecord File Content Type
-- X_File_ID       - MediaId (FND_LOBS File Id) of the ERecord Attachement
--                   created

procedure EDR_CREATE_ATTACHMENT (
                     p_eRecord_ID NUMBER,
                     P_FILE_NAME VARCHAR2,
                     p_description VARCHAR2,
                     p_content_type  VARCHAR2,
                     p_file_format VARCHAR2,
                     p_source_lang  VARCHAR2,
                     x_FILE_id  OUT NOCOPY NUMBER);

-- EDR_XDOC_UTIL_PKG.GET_NTF_MESSAGE_BODY is called from Workflow while rendering the
-- Notification for rendering E-Record Message "Please read the attached ... eRecord_XXXX.pdf"
-- This procedure follows PLSQL Document Attrubute Format API Call conventions

-- p_document_id   - This field is used to pass eRecord Id -- > ERECORD_ID
-- p_display_type  - Format of display text/palin, text/html etc...
-- x_document      - Document rendered in VARCHAR2 string is returned
--                            eRecord
-- x_document_type - Document type i.e. text, rtf, doc, etc...

procedure GET_NTF_MESSAGE_BODY
(	   p_document_id in varchar2,
	   p_display_type in varchar2,
	   x_document in out nocopy varchar2,
	   x_document_type in out nocopy varchar2
);


-- EDR_XDOC_UTIL_PKG.REQUEST_HTTP provides a wrapper over UTL_HTTP calls
-- It performs all the checks required on URL before calling UTL_HTTP.REQUEST
-- This FUNCTION follows PLSQL API Call conventions.

-- p_request_url    - Request URL over which UTL_HTTP call is to be made.
-- returns varchar2 - HTTP_RESPONSE returned from UTL_HTTP.REQUEST

function REQUEST_HTTP
(
         p_request_url in varchar2

) return varchar2;

-- Bug 4450651  Start
-- EDR_XDOC_UTIL_PKG.GET_SERVICE_TICKET_STRING function is called before HTTP request call is made.
-- and append the request ticket to HTTP URL .Its purpose is to make  JSP call to be secured.
-- p_request_service_name - Service name
function GET_SERVICE_TICKET_STRING
(
         p_request_service_name in varchar2
)  return varchar2 ;

-- EDR_XDOC_UTIL_PKG.COMPARE_SERVICE_TICKET_STRINGS function is called after HTTP request call is made.
-- and  requested ticket with HTTP URL is compared with new ticket .if both the ticket are same then
-- call has been made from valid source and request can be processed else abort the process .
-- P_TICKET1 - request ticket from http url

function VALIDATE_SERVICE_TICKET(P_TICKET in varchar2)
    return varchar2;

-- Bug 4450651  End

end EDR_XDOC_UTIL_PKG;

 

/
