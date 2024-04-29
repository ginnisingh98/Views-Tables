--------------------------------------------------------
--  DDL for Package EDR_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: EDRUTILS.pls 120.2.12010000.2 2009/03/26 17:12:33 srpuri ship $ */

-- Bug 3621309: Start
-- variable that determines the usage context of generate_xml api
validate_setup_ui_ctx                  CONSTANT VARCHAR2(20)   := 'VALIDATE_SETUP';
-- Bug 3621309: End


--Bug 2674799 : start
SUBTYPE APPROVERS_TABLE IS AME_UTIL.APPROVERSTABLE2;
SUBTYPE ID_LIST IS AME_UTIL.IDLIST;
SUBTYPE STRING_LIST IS AME_UTIL.STRINGLIST;

--Bug 4160412: Start
TYPE STRING_TABLE is TABLE of VARCHAR2(4000) INDEX by BINARY_INTEGER;
--Bug 4160412: End

PROCEDURE PRINTCLOB(result IN OUT NOCOPY CLOB);


PROCEDURE VERIFY_SETUP(ERRBUF       OUT NOCOPY VARCHAR2,
                       RETCODE      OUT NOCOPY VARCHAR2,
                       P_EVENT      IN  VARCHAR2,
                       P_EVENT_KEY  IN  VARCHAR2

                      );

PROCEDURE GENERATE_ERECORD(P_XML IN CLOB,
                           P_XSL IN CLOB,
                           P_DOC OUT NOCOPY VARCHAR2);

PROCEDURE GENERATE_XML(P_MAP_CODE      IN  VARCHAR2,
                       P_DOCUMENT_ID   IN  VARCHAR2,
                       P_XML           OUT NOCOPY CLOB,
                       P_ERROR_CODE    OUT NOCOPY NUMBER,
                       P_ERROR_MSG     OUT NOCOPY VARCHAR2,
                       P_LOG_FILE      OUT NOCOPY VARCHAR2);

PROCEDURE TEMP_DATA_CLEANUP(ERRBUF       OUT NOCOPY VARCHAR2,
                            RETCODE      OUT NOCOPY VARCHAR2);

--This function would take the original string and use the delimiter to return the substring
--from the start of the string till the delimiter. The original script along with the
--substring are returned to the calling function

FUNCTION GET_DELIMITED_STRING(p_original_string IN OUT NOCOPY VARCHAR2,
                              p_delimiter       IN VARCHAR2) return varchar2;

PROCEDURE EDR_RAISE3(	p_event_name	IN 	varchar2,
                	p_event_key    	IN 	varchar2,
                	p_event_data 	IN 	clob default NULL,
			p_param_list	IN OUT	NOCOPY FND_TABLE_OF_VARCHAR2_255,
			p_send_date  	IN 	date   default NULL,
			p_param_value	IN OUT	NOCOPY FND_TABLE_OF_VARCHAR2_255
		    );


PROCEDURE EDR_NTF_HISTORY(  document_id   in varchar2,
                            display_type  in varchar2,
                            document      in out NOCOPY varchar2,
                            document_type in out  NOCOPY varchar2);

--This procdeure would return the value of the standard WHO columns
--for a table. It can be sued while inserting or updating an existing
--row in any of the table.
--This is a PRIVATE procedure

-- Start of comments
-- API name             : getWhoColumns
-- Type                 : Private Utility.
-- Function             : Gets the WHO columns for inserting a row
-- Pre-reqs             : None.
-- Parameters           :
-- OUT                  : creation_date         out date
--                        created_by            out number
--                        last_update_date      out date
--                        last_updated_by       out number
--                        last_update_login     out number
--
-- End of comments

PROCEDURE getWhoColumns(creation_date     out nocopy date,
                        created_by        out nocopy number,
                        last_update_date  out nocopy date,
                        last_updated_by   out nocopy number,
                        last_update_login out nocopy number);

--Bug 3164491 : start

--This function would return the userdisplayname for the
--username passed. It would be used in ERES and would not be
--exposed to public.

-- Start of comments
-- API name             : getUserDisplayName
-- Type                 : Private Utility.
-- Function             : Gets the User Display name for the username
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_username in varchar2
-- RETURN               : varchar2 userdisplayname
--
-- End of comments
FUNCTION getUserDisplayName(p_username in varchar2) return varchar2;

--This function would return the overriding details for the username
-- passed. It would be used in ERES and would not be exposed to public.

-- Start of comments
-- API name             : getOverridingDetails
-- Type                 : Private Utility.
-- Function             : Gets the User Display name for the username
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_username in varchar2
-- RETURN               : varchar2 overridingdetails
--
-- End of comments
FUNCTION getOverridingDetails(p_username in varchar2) return varchar2;

--This function would return the actual recipient for the username
-- passed. It would be used in ERES and would not be exposed to public.

-- Start of comments
-- API name             : getActualRecipient
-- Type                 : Private Utility.
-- Function             : Gets the User Display name for the username
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_username in varchar2
-- RETURN               : varchar2 actualrecipient
--
-- End of comments
FUNCTION getActualRecipient(p_username in varchar2) return varchar2;

--This procedure would get the userid and usergroupname for the
--groupname passed. It would return a list of the userid and
-- usergroupname with 1:1 relationship

-- Start of comments
-- API name             : getUseridFromAme
-- Type                 : Private Utility.
-- Function             : Gets the userid and usergroupname for the partial
--                        groupname
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_groupname       in varchar2
-- OUT                  : x_userid          out FND_TABLE_OF_VARCHAR2_255
--                        x_usergroupname   out FND_TABLE_OF_VARCHAR2_255
--
-- End of comments

--Bug 3589701 : start
--Unsupport the functionality to search by group as ame has not released it.
--Whenever ame supports it, we will uncomment this.
/*
PROCEDURE getUseridFromAme(p_groupname in varchar2,
                            x_userid    out NOCOPY FND_TABLE_OF_VARCHAR2_255,
                            x_usergroupname out NOCOPY FND_TABLE_OF_VARCHAR2_255);
*/
--Bug 3589701 : end
--Bug 3164491 : end

--Bug 3465204 : start
--This procedure would return the profile option value for the profile specified
--As the profile option values are being cached now. we need to create our
--wrapper to avoid it.

-- Start of comments
-- API name             : getProfileValue
-- Type                 : Private Utility.
-- Function             : Gets the profile option value
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_profile in varchar2
-- OUT                  : x_profileValue out varchar2
--
-- End of comments
procedure getProfileValue (p_profile in varchar2, x_profileValue out nocopy varchar2);


--This procedure would return the profile option value for the profile specified
--As the profile option values are being cached now. we need to create our
--wrapper to avoid it.

-- Start of comments
-- API name             : getProfileValueSpecific
-- Type                 : Private Utility.
-- Function             : Gets the profile option value
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_profile in varchar2
--                        p_user_id in number default null
--                        p_responsibility_id in number default null
--                        p_org_id in number default null
--                        p_server_id in number default null
-- OUT                  : x_profileValue out varchar2
--
-- End of comments
procedure getProfileValueSpecific  (p_profile in varchar2,
                                    p_user_id in number default null,
                                    p_responsibility_id in number default null,
                                    p_application_id in number default null,
                                    p_org_id in number default null,
                                    p_server_id number default null,
                                    x_profilevalue out nocopy varchar2);
--Bug 3465204 : end

--Bug 3437422: Start
-- Start of comments
-- API name             : GET_USER_DATA
-- Type                 : Private.
-- Function             : Returns the contents of the USER_DATA node in xml payload
--                        of any ERES event
-- Pre-reqs             : None
-- Returns              : VARCHAR2(2000) containing the user_data xml node
--                        contents

FUNCTION GET_USER_DATA RETURN VARCHAR2;

-- Start of comments
-- API name             : REPLACE_USER_DATA_TOKEN
-- Type                 : Private.
-- Function             : Replaces the placeholder for user_data node contents
--                        in the XML payload of a document with actual contents
--                        of that node
-- Pre-reqs             : None
-- IN/OUT               : CLOB containing the xml payload that needs to be changed
--                        This XML is changed such that iff it contains user data
--                        token its replaced by actual contents of the USER_DATA
--                        node
PROCEDURE REPLACE_USER_DATA_TOKEN
(P_IN_XML          IN OUT NOCOPY   CLOB);

-- Start of comments
-- API name             : CLOB_REPLACE
-- Type                 : Public.
-- Function             : Function to replace a string with another one in a CLOB
-- Pre-reqs             : None
-- IN                   : p_source the source clob
--                        p_srch_str the string to be replaced
--                        p_replace_str the string that would replace the existing string
-- RETURNS              : new CLOB with the replaced string
FUNCTION CLOB_REPLACE
(p_source                  IN CLOB,
 p_srch_str                IN VARCHAR2,
 p_replace_str             IN VARCHAR2)
return CLOB;

--Bug 3437422: End


--Bug 3101047 : Start
-- Start of comments
-- API name             : GETUSERROLEINFO
-- Type                 : Private.
-- Function             : This API is used to obtain the USER DISPLAY NAME, ORIG SYSTEM NAME and SYSTEM ID for a
--			                  given USER NAME. The values are fetched from FND tables.
-- Pre-reqs             : None
-- IN                   : P_USER_NAME
-- OUT			            : X_USER_DISPLAY_NAME
--			                : X_ORIG_SYSTEM
--                			: X_ORIG_SYSTEM_ID
PROCEDURE GETUSERROLEINFO
(P_USER_NAME		IN VARCHAR2,
 X_USER_DISPLAY_NAME	OUT NOCOPY VARCHAR2,
 X_ORIG_SYSTEM		OUT NOCOPY VARCHAR2,
 X_ORIG_SYSTEM_ID	OUT NOCOPY NUMBER);


-- Start of comments
-- API name             : GET_EVENT_DESCRIPTION
-- Type                 : Private Utility.
-- Function             : This API is used to obtain the actual event display name for a given event name.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_EVENT Name of the event
-- OUT                  : P_DESCRIPTION  Display name of the Event

PROCEDURE GET_EVENT_DESCRIPTION(P_EVENT IN VARCHAR2,
                                P_DESCRIPTION OUT NOCOPY VARCHAR2);

-- Bug 3863508 : Start
-- Changed signature to use P_SIGNATURE_ID instead of P_DOCUMENT_ID

-- Start of comments
-- API name             : FETCH_USER_DISPLAY_NAME
-- Type                 : Private Utility.
-- Function             : This API is used to obtain the USER DISPLAY NAME for a given USER NAME.
--                        If the entry in EDR_PSIG_DETAILS is null, then it is fetched from WF_ROLES.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_USER_NAME The user name for which the display name is to be obtained.
--			: P_SIGNATURE_ID The SIGNATURE_ID for the document in EDR_PSIG_DETAILS table
-- OUT                  : X_USER_DISPLAY_NAME: The corresponding User Display Name

/*PROCEDURE FETCH_USER_DISPLAY_NAME(P_USER_NAME IN VARCHAR2,
			     P_DOCUMENT_ID IN VARCHAR2,
			     X_USER_DISPLAY_NAME OUT NOCOPY VARCHAR2);
*/

PROCEDURE FETCH_USER_DISPLAY_NAME(P_USER_NAME IN VARCHAR2,
                                  P_SIGNATURE_ID NUMBER,
                                  X_USER_DISPLAY_NAME OUT NOCOPY VARCHAR2);


--Bug 3863508 : End

--Bug 3101047 : End


-- Bug 3630380 : Start
-- Start of comments
-- API name             : FETCH_USER_DISPLAY_NAME
-- Type                 : Private Utility.
-- Function             : This API is used to obtain the USER DISPLAY NAME for a given USER ID.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_USER_ID The user id for which the display name is to be obtained.
-- OUT                  : X_USER_DISPLAY_NAME: The corresponding User Display Name

PROCEDURE FETCH_USER_DISPLAY_NAME(P_USER_ID IN NUMBER,
			     X_USER_DISPLAY_NAME OUT NOCOPY VARCHAR2);

-- Bug 3630380 : End


-- Bug 2674799 :start
-- changed to use new approversTable table type of EDR_UTILITIES.

-- Bug 3607477 : Start
-- Start of comments
-- API name             : GET_UNIQUE_AME_APPROVERS
-- Type                 : Private Utility.
-- Function             : This API is used to obtain the  unique ame approvers
--                        after filtering out the duplicate and deleted approvers. This function will
--                        filter the approvers having approval status as REPEATE and SUPPRESS.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_APPROVER_LIST EDR approvers_Table containing all approvers.
-- RETURNS              : approvers_Table  EDR approver Table containing unique approvers

FUNCTION  GET_UNIQUE_AME_APPROVERS(P_APPROVER_LIST IN APPROVERS_TABLE)
RETURN  approvers_Table;

-- Bug 3607477 : End
-- Bug 2674799 : end


-- Bug 2674799 :start
--
-- Start of comments
-- API name             : GET_APPROVERS
-- Type                 : Private Utility.
-- Function             : This API is used to obtain the  unique ame approvers
--                        after filtering out the duplicate and deleted approvers.
-- Pre-reqs             : None.
-- Parameters           :
-- P_APPLICATION_ID      : APPLICATION ID
-- P_TRANSACTION_TYPE    : TRANSACTION TYPE NAME as defined in AME
-- P_TRANSACTION_ID      : TRANSACTION ID
-- APPROVERSOUT         : TABLE OF APPROVERS
-- X_RULE_IDS           : TABLE OF RULE IDS
-- X_RULE_DESCRIPTIONS  : TABLE OF RULE NAMES
-- RETURNS              : EDR_UTILITIES.approversTable approver Table containing unique approvers

PROCEDURE GET_APPROVERS(
        P_APPLICATION_ID  IN NUMBER,
        P_TRANSACTION_ID IN VARCHAR2,
        P_TRANSACTION_TYPE IN VARCHAR2,
        X_APPROVERS OUT NOCOPY APPROVERS_TABLE,
        X_RULE_IDS OUT NOCOPY ID_LIST,
        X_RULE_DESCRIPTIONS OUT NOCOPY STRING_LIST
     );

--Bug 2674799: end

-- Bug 3667036: Start

-- Start of comments
-- API name             : GET_XML_ATTRIBUTE
-- Type                 : Private Utility.
-- Function             : Obtain the required XPATH value for a given event name and event key
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_EVENT_NAME	    IN  VARCHAR2: The event name
--			                : P_EVENT_KEY	      IN  VARCHAR2: The event key
--			                : P_XPATH_EXPRESSION  IN  VARCHAR2: The xpath expression
-- RETURNS              : The value for the specified xpath expression
--                        If the xpath is invalid: returns null
--                        If the xpath returns duplicate values: returns null
--                        In case of any unexpected exception: returns null
FUNCTION GET_XML_ATTRIBUTE
(
  P_EVENT_NAME       VARCHAR2,
  P_EVENT_KEY        VARCHAR2,
  p_XPATH_EXPRESSION VARCHAR2
) RETURN VARCHAR2;

-- Bug 3667036: End


--Bug 3621309: Start

-- Start of comments
-- API name             : GENERATE_XML_PAYLOAD
-- Type                 : Private Utility.
-- Function             : Create the XML run time payload by performing the
--                        required XML gateway operation.
--
-- Pre-reqs             : None.
-- Parameters           :
--
-- IN
--                      : P_MAP_CODE    IN  VARCHAR2: The XML gateway map code.
--			                : P_DOCUMENT_ID	IN  VARCHAR2: The event key
--			                : P_RAW_XML     IN  CLOB:     The raw xml payload
--                      : P_EVENT_NAME  IN  VARCHAR2: The event name identifying the transaction
--                      : P_USE_CONTEXT IN  VARCHAR2: The usage context
--
--  OUT
--                      : X_XML_PAYLOAD OUT CLOB: The transformed XML payload
--                      : X_DISPLAY_XML OUT CLOB: The XML payload with some more transformation
--                                                to ensure that it is displayable in
--                                                a UI bean of an OA page.
--
PROCEDURE GENERATE_XML_PAYLOAD( P_MAP_CODE      IN         VARCHAR2,
                                P_DOCUMENT_ID   IN         VARCHAR2,
                                P_RAW_XML       IN         CLOB      DEFAULT NULL,
                                P_EVENT_NAME    IN         VARCHAR2  DEFAULT NULL,
                                P_USE_CONTEXT   IN         VARCHAR2  DEFAULT NULL,
                                X_XML_PAYLOAD   OUT NOCOPY CLOB,
                                X_DISPLAY_XML   OUT NOCOPY CLOB);

-- Start of comments
-- API name             : ADJUST_CLOB_FOR_DISPLAY
-- Type                 : Private Utility.
-- Function             : Adjusts the payload provided as per the
--                      : payload type. If the payload is of type "XMLPAYLOAD"
--                        then the whole payload would be placed between <pre>
--                        </pre> tags and all '<', '>' would be replaced by
--                        '&lt' and '&gt' respectively. If the payload is of
--                        any other type then it is adjusted to be prefixed and
--                        suffixed with the <pre> and </pre> tags respectively.
--                        This is primarily done to ensure that the payload is
--                        rendered properly on the UI bean of an OA page. The
--                        manipulated payload is returned.
--
-- Pre-reqs             : None.
-- Parameters           :
--
-- IN
--                      : P_PAYLOAD      IN   CLOB: The XML Payload to be
--                                                  adjusted.
--
--			                : P_PAYLOAD_TYPE IN   CLOB: The payload type.
--
-- RETURNS              : The adjusted payload.

FUNCTION ADJUST_CLOB_FOR_DISPLAY(P_PAYLOAD      IN CLOB,
                                 P_PAYLOAD_TYPE IN VARCHAR2)
RETURN CLOB;


-- Start of comments
-- API name             : XSLT_TRANSFORMATION
-- Type                 : Private Utility.
-- Function             : This API is used to apply the specified XSL style
--                        sheet on the XML payload provided.
--
-- Pre-reqs             : None.
-- Parameters           :
--
-- IN
--                      : P_XML_FILE              IN  CLOB:     The XML payload
--			                : P_XSLT_FILE_NAME	      IN  VARCHAR2: The XSL file to be applied
--                                                              on the XML payload.

--			                : P_XSLT_APPLICATION_CODE IN  CLOB:     The application code to which
--                                                              the style sheet belongs.
--
--
--  OUT
--                      : X_OUTPUT  CLOB:   The transformed XML payload
--                      : X_RETCODE NUMBER: The execution status code of the API
--                      : X_RETMSG  CLOB:   The return message indicating the
--                                          actual execution details performed
--                                          and any errors that occurred.
--

PROCEDURE XSLT_TRANSFORMATION ( P_XML_FILE               IN         CLOB,
                                P_XSLT_FILE_NAME         IN         VARCHAR2,
                        				P_XSLT_APPLICATION_CODE  IN         VARCHAR2,
                                P_XSLT_FILE_VER          IN         VARCHAR2,
                          			X_OUTPUT                 OUT NOCOPY CLOB,
                                X_RETCODE                OUT NOCOPY NUMBER,
                        				X_RETMSG                 OUT NOCOPY VARCHAR2);


-- Start of comments
-- API name             : SAVE_RAW_XML
-- Type                 : Private Utility.
-- Function             : This API stores the specified transaction data into
--                        ERES temp(functional) table EDR_RAW_XML_T. If a row
--                        already exists for the specified event name and key
--                        combination, then the row is updated.
--
-- Pre-reqs             : None.

-- Parameters           :
--
-- IN
--                      : P_TRANSACTION_NAME  IN  VARCHAR2: The event name representing the transaction.
--			                : P_TRANSACTION_KEY	  IN  VARCHAR2: The event key identifying the transaction.
--			                : P_RAW_XML           IN  CLOB:     The runtime transaction data.
--

PROCEDURE SAVE_RAW_XML( P_TRANSACTION_NAME IN VARCHAR2,
                        P_TRANSACTION_KEY  IN VARCHAR2,
                        P_RAW_XML          IN CLOB);

-- Start of comments
-- API name             : GET_RULES_AND_VARIABLES
-- Type                 : Private Utility.
-- Function             : This API is used to obtain the AME rule ids, rule descriptions
--                        that are applicable for the specified transaction.
--                        Also the rule variable names and values are also obtained.
--
-- Pre-reqs             : None.
-- Parameters           :
--
-- IN
--                      : P_EVENT_NAME  IN  VARCHAR2: The event name representing the transaction.
--                    	: P_EVENT_KEY   IN  VARCHAR2: The event key identifying the transaction.
--
--  OUT
--                      : X_AME_RULE_IDS           FND_TABLE_OF_VARCHAR2_255: The AME rule ids.
--                      : X_AME_RULE_DESCRIPTIONS  FND_TABLE_OF_VARCHAR2_255: The AME rule descriptions.
--                      : X_VARIABLE_NAMES         FND_TABLE_OF_VARCHAR2_255: The rule variable names.
--                      : X_VARIABLE_VALUES        FND_TABLE_OF_VARCHAR2_255: The rule variable values.
--

PROCEDURE GET_RULES_AND_VARIABLES
(
         P_EVENT_NAME              IN         VARCHAR2,
      	 P_EVENT_KEY               IN         VARCHAR2 DEFAULT NULL,
         X_AME_RULE_IDS            OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
         X_AME_RULE_DESCRIPTIONS   OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
         X_VARIABLE_NAMES          OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
         X_VARIABLE_VALUES         OUT NOCOPY FND_TABLE_OF_VARCHAR2_255
);

--Bug 3621309 : End

-- Bug 3575265 :Start
-- Start of comments
-- API Name 		: GET_TEST_SCENARIO_XML
-- Type 		: PRIVATE UTILITY
-- Function		: This API is called by XML Gateway while producing EDR
--			  ERES OAF Inter Event 4 Payload
-- Pre-reqs 		: None
-- Parameters		:
-- IN			: P_TEST_SCENARIO_ID - TestScenarioId of the event being
--			 tested
-- OUT 		        : P_PARTIAL_XML - XML returned to XML gateway which will
--                        be part of event payload
-- OUT 		        : P_TEST_SCENARIO - XML returned to XML gateway which will
--                        be part of event payload
-- OUT 		        : P_TEST_SCENARIO_INSTANCE - XML returned to XML gateway which will
--                        be part of event payload

PROCEDURE GET_TEST_SCENARIO_XML
(
	P_TEST_SCENARIO_ID IN NUMBER,
	P_PARTIAL_XML OUT NOCOPY VARCHAR2,
	P_TEST_SCENARIO OUT NOCOPY VARCHAR2,
	P_TEST_SCENARIO_INSTANCE OUT NOCOPY VARCHAR2
);

-- Bug 3575265 : End



-- Bug 3882605 : start
/* Utility procedures for Print option */

-- Start of comments
-- API name             : GET_PARENT_ERECORD_ID
-- Type                 : Private Utility.
-- Function             : fetches Parent eRecord ID for a given erecord. P_PARENT_ERECORD_ID will be NULL if not found
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERECORD_ID eRecord id for which parent erecord id need to be retrieved
-- OUT                  : P_PARENT_ERECORD_ID Parent eRecord id of a given eRecord

-- End of comments
PROCEDURE GET_PARENT_ERECORD_ID(P_ERECORD_ID IN NUMBER,
                                P_PARENT_ERECORD_ID OUT NOCOPY NUMBER);

-- Bug 3882605 : end

--Bug 3893101: Start
-- Start of comments
-- API name             : GENERATE_XML_FOR_INTER_EVENT_FORM
-- Type                 : Private Utility.
-- Function             : Generates the XML payload for the inter event form.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_EVENT_KEY The event key of the event raised in
--                                    the inter event form.
-- IN                   : P_XML_CLOB_ID The XML CLOB ID to be used.

-- End of comments
PROCEDURE GENERATE_EVENT_PAYLOAD (P_EVENT_KEY   IN VARCHAR2,
                                  P_XML_CLOB_ID IN NUMBER);
--Bug 3893101: End


--Bug 4122622: Start
-- Start of comments
-- API name             : REPEATING_NUMBERS_EXIST
-- Type                 : Private Utility.
-- Function             : Checks if any of the number in the method
--                        are repeated. If so it returns true. Else it returns
--                        false.

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_NUMBERS IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE
--                      : Array of numbers.
-- RETURNS              : Boolean valye which indicates if any of the e-record ids
--                      : are repeating.

FUNCTION REPEATING_NUMBERS_EXIST(P_NUMBERS IN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE)

return boolean;



-- Start of comments
-- API name             : GET_ERECORD_IDS
-- Type                 : Private Utility.
-- FUNCTION             : The procedure takes a comma separated string of
--                      : child e-record IDs and converts them into table of numbers.

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERECORD_IDS_STRING IN VARCHAR2
--                      : Comma separated string of child e-record IDs.
-- OUT                  : X_ERECORD_IDS_ARRAY
--                      : The array of e-record ID values.

PROCEDURE GET_ERECORD_IDS(P_ERECORD_IDS_STRING IN VARCHAR2,
                          X_ERECORD_IDS_ARRAY OUT NOCOPY EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE);

--Bug 4122622: End

--Bug 4160412: Start
-- Start of comments
-- API name             : GET_APPROVER_LIST
-- Type                 : Private Utility.
-- FUNCTION             : The procedure takes a comma separated string of
--                        approvers and converts them into table of approvers

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_APPROVING_USERS  - The comma separated string of approvers.

-- OUT                  : X_APPROVER_LIST       - The table of approvers.
--                      : X_ARE_APPROVERS_VALID - Flag indicating if the approvers provided are valid.
--                      : X_INVALID_APPROVERS   - Comma separated string of invalid approvers if they exist.
PROCEDURE GET_APPROVER_LIST(P_APPROVING_USERS       IN VARCHAR2,
                            X_APPROVER_LIST         OUT NOCOPY EDR_UTILITIES.APPROVERS_TABLE,
                            X_ARE_APPROVERS_VALID   OUT NOCOPY VARCHAR2,
                            X_INVALID_APPROVERS     OUT NOCOPY VARCHAR2);


-- Start of comments
-- API name             : ARE_APPROVERS_REPEATING
-- Type                 : Private Utility.
-- FUNCTION             : This function checks the table of approvers for any repetition.
--                        If any approver is repeated in the table then it returns true, else it
--                        returns false.

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_APPROVING_LIST  - Table of approvers to be validated for repetition.

-- RETURN                : The correspinding boolean value indicating the result of the validation.
FUNCTION ARE_APPROVERS_REPEATING(P_APPROVER_LIST IN EDR_UTILITIES.APPROVERS_TABLE)
RETURN BOOLEAN;

--Bug 4160412: End

-- FP Bug 5564086: Start
/* This function will compare audit values and return true or false based on the the results
 *
-- Start of comments
-- API Name            :  HAS_ATTRIBUTE_CHANGED
-- Type                :  Public Utility
-- Function             : fetches commited value of the given column from the given table and compare
                          with current value.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_TABLE_NAME Table to query
                        : P_COLUMN  Column whose value to be compared
                        : P_PKNAME   Primary key of the column to select a specific row
                        : P_TRACK_INSERT Y or N to identify if API should also consider
                          insert operation or changes only
-- RETURN               : 'true' or 'false' */

 FUNCTION HAS_ATTRIBUTE_CHANGED(P_TABLE_NAME IN VARCHAR2,
                              P_COLUMN     IN VARCHAR2,
                              P_PKNAME     IN VARCHAR2,
                              P_PKVALUE    IN VARCHAR2,
                              P_TRACK_INSERT IN VARCHAR2
                             )
             return varchar2;

/* This function will compare audit values and return true or false based on the the results
 *
-- Start of comments
-- API Name            :  HAS_ATTRIBUTE_CHANGED
-- Type                :  Public Utility
-- Function             : fetches commited value of the given column from the given table and compare
                          with current value.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_TABLE_NAME Table to query
                        : P_COLUMN  Column whose value to be compared
                        : P_PKNAME   Primary key of the column to select a specific row
-- RETURN               : 'true' or 'false' */

 FUNCTION HAS_ATTRIBUTE_CHANGED(P_TABLE_NAME IN VARCHAR2,
                              P_COLUMN     IN VARCHAR2,
                              P_PKNAME     IN VARCHAR2,
                              P_PKVALUE    IN VARCHAR2
                             )
             return varchar2;
-- Bug 5564086: Ends



END EDR_UTILITIES;

/
