--------------------------------------------------------
--  DDL for Package JTF_FM_UTL_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_UTL_V" AUTHID CURRENT_USER AS
/* $Header: jtfvfmus.pls 115.14 2004/02/10 13:44:12 applrt ship $ */


   G_LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
   G_LEVEL_ERROR      CONSTANT NUMBER  := 5;
   G_LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
   G_LEVEL_EVENT      CONSTANT NUMBER  := 3;
   G_LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
   G_LEVEL_STATEMENT  CONSTANT NUMBER  := 1;


---------------------------------------------------------------------
-- Function
--    Confirm_Pasta_Printable
--
-- PURPOSE
--    Confirm whether any of the documents attached is not an
--	RTF or PDF
--
-- PARAMETERS
--    	  p_request_id   : request_id
-- RETURNS
-- 	  True		: If all the files are RTF or PDF
--	  False 	: If any of the files is not an RTF or PDF
--
--
---------------------------------------------------------------------
FUNCTION CONFIRM_PASTA_PRINTABLE
(
	p_request_id NUMBER
)
RETURN VARCHAR2;


---------------------------------------------------------------------
-- Function
--    Confirm_Rtf
--
-- PURPOSE
--    Confirm whether a file is an RTF file or not
--
-- PARAMETERS
--    	  p_file_id     : File id in FND_LOBS
-- RETURNS
-- 	  True		: If the file is an RTF file
--	  False 	: If the file is not an RTF file

--
---------------------------------------------------------------------
FUNCTION CONFIRM_RTF
(
p_file_id IN NUMBER
)
RETURN BOOLEAN;

---------------------------------------------------------------------
-- Function
--    Confirm_PDF
--
-- PURPOSE
--    Confirm whether a file is an PDF file or not
--
-- PARAMETERS
--    	  p_file_id     : File id in FND_LOBS
-- RETURNS
-- 	  True		: If the file is an PDF file
--	  False 	: If the file is not an PDF file
---------------------------------------------------------------------
FUNCTION CONFIRM_PDF
(
p_file_id IN NUMBER
)
RETURN BOOLEAN;

---------------------------------------------------------------------
-- Function
--    Confirm_Text_Html
--
-- PURPOSE
--    Confirm whether a file is an HTML or Text File
--
-- PARAMETERS
--    	  p_file_id     : File id in FND_LOBS
-- RETURNS
-- 	  True		: If the file is an HTML file or Text file
--	  False 	: If the file is not an HTML file or Text file
------------------------------------------------------------------------
FUNCTION CONFIRM_TEXT_HTML
(
p_file_id IN NUMBER
)
RETURN BOOLEAN;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Message
--
-- PURPOSE
--    Gets a Message.
--
-- PARAMETERS
--    p_application_code : 'JTF' for fulfillment
--	  p_message_nm : The name of the message
-- 	  p_arg1 : Token one value
-- 	  p_arg2 : Token two value
-- 	  x_message	: Translated Output message with tokens inserted
-- NOTES
--    1. Currently gets ERROR messages only
--	  2. The taken names must be ARG1 and ARG2
---------------------------------------------------------------------
PROCEDURE Get_Message
(
     p_api_version         	IN  NUMBER,
 	 p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_commit              	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	 x_return_status       	OUT NOCOPY VARCHAR2,
 	 x_msg_count           	OUT NOCOPY NUMBER,
 	 x_msg_data            	OUT NOCOPY VARCHAR2,
	 p_application_code     IN  VARCHAR2,
	 p_message_nm			IN  VARCHAR2,
	 p_arg1					IN  VARCHAR2 := NULL,
	 p_arg2					IN  VARCHAR2 := NULL,
	 x_message				OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Post_Message
--
-- PURPOSE
--    Posts a Message.
--
-- PARAMETERS
--    p_application_code : 'JTF' for fulfillment
--	  p_message_nm : The name of the message
-- 	  p_arg1 : Token one value
-- 	  p_arg2 : Token two value
--
-- NOTES
--    1. Currently gets ERROR messages only
--	  2. The taken names must be ARG1 and ARG2
---------------------------------------------------------------------
PROCEDURE Post_Message
(
     p_api_version         	IN  NUMBER,
 	 p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_commit              	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	 x_return_status       	OUT NOCOPY VARCHAR2,
 	 x_msg_count           	OUT NOCOPY NUMBER,
 	 x_msg_data            	OUT NOCOPY VARCHAR2,
	 p_application_code     IN  VARCHAR2,
	 p_message_nm			IN  VARCHAR2,
	 p_arg1					IN  VARCHAR2 := NULL,
	 p_arg2					IN  VARCHAR2 := NULL
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Post_Message
--
-- PURPOSE
--    Posts and Gets the Message in one call.
--
-- PARAMETERS
--    p_application_code : 'JTF' for fulfillment
--	  p_message_nm : The name of the message
-- 	  p_arg1 : Token one value
-- 	  p_arg2 : Token two value
-- 	  x_message	: Translated Output message with tokens inserted
--
-- NOTES
--    1. Currently gets ERROR messages only
--	  2. The taken names must be ARG1 and ARG2
---------------------------------------------------------------------
PROCEDURE Get_Post_Message
(
     p_api_version         	IN  NUMBER,
 	 p_init_msg_list       	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_commit              	IN  VARCHAR2 := FND_API.G_FALSE,
 	 p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	 x_return_status       	OUT NOCOPY VARCHAR2,
 	 x_msg_count           	OUT NOCOPY NUMBER,
 	 x_msg_data            	OUT NOCOPY VARCHAR2,
	 p_application_code     IN  VARCHAR2,
	 p_message_nm			IN  VARCHAR2,
	 p_arg1					IN  VARCHAR2 := NULL,
	 p_arg2					IN  VARCHAR2 := NULL,
	 x_message				OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    PRINT_Message
--
-- PURPOSE
--    Logs Messages
--
-- PARAMETERS

--	  p_message : The message
-- 	  p_log_level : Logging Level
--    p_module_name: 'module that logs the message'

--
-- NOTES
--    1. This procedure will be used by all Fulfillment API's to
--    centrally log messages
--     Date : June 2nd 2003

---------------------------------------------------------------------
PROCEDURE Print_Message
(

	 p_message          IN  VARCHAR2,
	 p_log_level        IN  NUMBER,
	 p_module_name      IN  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    ADD_ERROR_MESSAGE
--
-- PURPOSE
--    IN TURN CALLS PRINT_MESSAGE.
--
-- PARAMETERS

--	  p_api_name : The api where error occured
-- 	  p_error_msg : The error message

--
-- NOTES
--    1. This procedure will be used by all Fulfillment API's to
--    centrally log messages
--     Date : June 2nd 2003

---------------------------------------------------------------------
PROCEDURE Add_Error_Message
(
     p_api_name       IN  VARCHAR2,
     p_error_msg      IN  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    GET_ERROR_MESSAGE
--
-- PURPOSE
--    TO GET THE LAST ERROR MESSAGE
--
-- PARAMETERS

--	ONLY ONE OUT PARAMETER WHICH IS THE LAST MESSAGE IN THE STACK

--
-- NOTES
--     Date : June 2nd 2003

---------------------------------------------------------------------

PROCEDURE Get_Error_Message
(
     x_msg_data       OUT NOCOPY VARCHAR2
) ;


---------------------------------------------------------------------
-- PROCEDURE
--    HANDLE_ERROR
--
-- PURPOSE
--    TO RAISE THE APPROPRIATE ERROR
--
-- PARAMETERS
	-- P_name the key of the message
	-- p_token the arguments to the message
-- NOTES
--     Date : June 2nd 2003

---------------------------------------------------------------------
PROCEDURE HANDLE_ERROR(
      p_name  IN VARCHAR2,
	  p_token  IN VARCHAR2

);
PROCEDURE HANDLE_ERROR( p_name  IN VARCHAR2);

----------------------------------------------------------------------
-- INSERT_EMAIL_STATS
---------------------------------------------------------------------
PROCEDURE INSERT_EMAIL_STATS
(
   p_request_id     IN NUMBER
);

-----------------------------------------------------------------------

type fm_pvt_rec_type is record
 (
    content_xml         VARCHAR2(32767),
    request_id          NUMBER,
    party_id            NUMBER,
    queue               VARCHAR2(2),
    preview             VARCHAR2(30),
    priority            NUMBER,
    doc_id              NUMBER,
    doc_ref             VARCHAR2(30),
    param_names           JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
    param_values           JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE
 );
--functions moevd from other modules within our apis.

FUNCTION IS_FLD_VALID( p_string IN  VARCHAR2) RETURN BOOLEAN;
FUNCTION IS_FLD_VALID( p_number IN  NUMBER) RETURN BOOLEAN;
FUNCTION GET_ENCODING RETURN VARCHAR2;
FUNCTION REPLACE_TAG(p_string IN  VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_MEDIA(p_content_xml  IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_MEDIA_TYPE(  p_content_xml  IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE Get_Dtd(p_dtd IN OUT NOCOPY VARCHAR2);
PROCEDURE FM_SUBMIT_REQ_V1
(p_api_version            IN  NUMBER,
 p_init_msg_list          IN  VARCHAR2,
 p_commit                 IN  VARCHAR2,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY NUMBER,
 x_msg_data               OUT NOCOPY VARCHAR2,
 p_fulfill_electronic_rec IN JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE,
 fm_pvt_rec               IN FM_PVT_REC_TYPE

) ;


END JTF_FM_UTL_V;

 

/
