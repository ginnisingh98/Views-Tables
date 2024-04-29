--------------------------------------------------------
--  DDL for Package EDR_STANDARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_STANDARD_PUB" AUTHID CURRENT_USER AS
/* $Header: EDRPSTDS.pls 120.0.12000000.1 2007/01/18 05:54:52 appldev ship $ */
/*#
 * This package contains all general Oracle E-Records utilities.
 * @rep:scope public
 * @rep:metalink 268669.1 Oracle E-Records API User's Guide
 * @rep:product EDR
 * @rep:displayname Oracle E-Records Utility
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EDR_EVIDENCE_STORE
 */

-- Public Record Type Decleration

TYPE EventDetail_tbl_type IS TABLE of edr_standard.eventDetails INDEX by binary_integer;

TYPE InputVar_Values_tbl_type IS TABLE of edr_standard.RuleInputValues index by binary_integer;

-- Global Variables

G_SIGNATURE_STATUS varchar2(80) := NULL;    -- hold the status of workflow ('APPROVED','REJECTED')


Type Flex_ColnName_Rec_Type is record (
	P_COLUMN1_NAME		VARCHAR2(30),
	P_COLUMN2_NAME		VARCHAR2(30),
	P_COLUMN3_NAME		VARCHAR2(30),
	P_COLUMN4_NAME		VARCHAR2(30),
	P_COLUMN5_NAME		VARCHAR2(30),
	P_COLUMN6_NAME		VARCHAR2(30),
	P_COLUMN7_NAME		VARCHAR2(30),
	P_COLUMN8_NAME		VARCHAR2(30),
	P_COLUMN9_NAME		VARCHAR2(30),
	P_COLUMN10_NAME      	VARCHAR2(30),
	P_COLUMN11_NAME      	VARCHAR2(30),
	P_COLUMN12_NAME		VARCHAR2(30),
	P_COLUMN13_NAME		VARCHAR2(30),
	P_COLUMN14_NAME		VARCHAR2(30),
	P_COLUMN15_NAME		VARCHAR2(30),
	P_COLUMN16_NAME		VARCHAR2(30),
	P_COLUMN17_NAME		VARCHAR2(30),
	P_COLUMN18_NAME		VARCHAR2(30),
	P_COLUMN19_NAME		VARCHAR2(30),
	P_COLUMN20_NAME		VARCHAR2(30),
	P_COLUMN21_NAME		VARCHAR2(30),
	P_COLUMN22_NAME		VARCHAR2(30),
	P_COLUMN23_NAME		VARCHAR2(30),
	P_COLUMN24_NAME		VARCHAR2(30),
	P_COLUMN25_NAME		VARCHAR2(30),
	P_COLUMN26_NAME		VARCHAR2(30),
	P_COLUMN27_NAME		VARCHAR2(30),
	P_COLUMN28_NAME		VARCHAR2(30),
	P_COLUMN29_NAME		VARCHAR2(30),
	P_COLUMN30_NAME		VARCHAR2(30)	);

Type Flex_ColnPrompt_Rec_Type is record (
	P_COLUMN1_PROMPT	VARCHAR2(80),
	P_COLUMN2_PROMPT	VARCHAR2(80),
	P_COLUMN3_PROMPT	VARCHAR2(80),
	P_COLUMN4_PROMPT	VARCHAR2(80),
	P_COLUMN5_PROMPT	VARCHAR2(80),
	P_COLUMN6_PROMPT	VARCHAR2(80),
	P_COLUMN7_PROMPT	VARCHAR2(80),
	P_COLUMN8_PROMPT	VARCHAR2(80),
	P_COLUMN9_PROMPT	VARCHAR2(80),
	P_COLUMN10_PROMPT	VARCHAR2(80),
	P_COLUMN11_PROMPT	VARCHAR2(80),
	P_COLUMN12_PROMPT	VARCHAR2(80),
	P_COLUMN13_PROMPT	VARCHAR2(80),
	P_COLUMN14_PROMPT	VARCHAR2(80),
	P_COLUMN15_PROMPT	VARCHAR2(80),
	P_COLUMN16_PROMPT	VARCHAR2(80),
	P_COLUMN17_PROMPT	VARCHAR2(80),
	P_COLUMN18_PROMPT	VARCHAR2(80),
	P_COLUMN19_PROMPT	VARCHAR2(80),
	P_COLUMN20_PROMPT	VARCHAR2(80),
	P_COLUMN21_PROMPT	VARCHAR2(80),
	P_COLUMN22_PROMPT	VARCHAR2(80),
	P_COLUMN23_PROMPT	VARCHAR2(80),
	P_COLUMN24_PROMPT	VARCHAR2(80),
	P_COLUMN25_PROMPT	VARCHAR2(80),
	P_COLUMN26_PROMPT	VARCHAR2(80),
	P_COLUMN27_PROMPT	VARCHAR2(80),
	P_COLUMN28_PROMPT	VARCHAR2(80),
	P_COLUMN29_PROMPT	VARCHAR2(80),
	P_COLUMN30_PROMPT	VARCHAR2(80)	);




-- --------------------------------------
-- API name 	: Get_PsigStatus
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains signature status ('PENDING','COMPLETE','ERROR') for a given event
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_status	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.Psig_Status
-- ---------------------------------------
/*#
 * This API obtains current e-signature status for an event.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get current e-signature status
 */

PROCEDURE Get_PsigStatus (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 		in    	varchar2,
	p_event_key		in    	varchar2,
      	x_psig_status    	out 	NOCOPY varchar2   ) ;


-- --------------------------------------
-- API name 	: Is_Psig_Required
-- Type		: Public
-- Pre-reqs	: None
-- Function	: return True/False on signature requirement for a given event
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_required	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.PSIG_REQUIRED
-- ---------------------------------------
/*#
 * This API checks if a signature is required for an event.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Determine if the e-signature is required
 */

PROCEDURE Is_eSig_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eSig      	OUT 	NOCOPY VARCHAR2  ) ;


-- --------------------------------------
-- API name 	: Is_eRec_Required
-- Type		: Public
-- Pre-reqs	: None
-- Function	: return True/False on eRecord Requirement for a given event
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_erec_required	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.EREC_REQUIRED
-- ---------------------------------------
/*#
 * This API checks if an e-record is required for an event.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Determine if the e-record is required
 */

PROCEDURE Is_eRec_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eRec     	OUT 	NOCOPY VARCHAR2   ) ;


-- --------------------------------------
-- API name 	: Get_PsigQuery_Id
-- Type		: Public
-- Pre-reqs	: None
-- Function	: obtain a query id for events based on records of event informations
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_status	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.PSIG_QUERY
-- ---------------------------------------
/*#
 * This API obtains a query ID for a list of events passed to the API as p_eventQuery_recTbl.
 * This API is used in the context of querying the e-record repository.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get query ID
 */

Procedure Get_QueryId_OnEvents (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_eventQuery_recTbl 	IN	EventDetail_tbl_type,
	x_query_id		OUT	NOCOPY NUMBER  );


-- --------------------------------------
-- API name 	: DISPLAY_DATE
-- Type		: Public
-- Pre-reqs	: None
-- Function	: convert a date to string
-- Parameters
-- IN   :       p_api_version  NUMBER   1.0
--              p_init_msg_list VARCHAR2
--              p_date_in       DATE   date that need to be converted
-- OUT  :       x_return_status VARCHAR2
--              x_msg_count     NUMBER
--              x_msg_data      VARCHAR2
--              x_date_out      VARCHAR2  converted date
-- Versions	: 1.0	17-Jul-03	created from edr_standard.DISPLAY_DATE
-- ---------------------------------------

PROCEDURE DISPLAY_DATE (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_DATE_IN  		IN  	DATE ,
	x_date_out 		OUT 	NOCOPY Varchar2 ) ;

-- --------------------------------------
-- API name     : DISPLAY_DATE_ONLY
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string
-- Parameters
-- IN   :       p_api_version  NUMBER   1.0
--              p_init_msg_list VARCHAR2
--              p_date_in       DATE   date that need to be converted
-- OUT  :       x_return_status VARCHAR2
--              x_msg_count     NUMBER
--              x_msg_data      VARCHAR2
--              x_date_out      VARCHAR2  converted date
-- Versions     : 1.0   7-Nov-03       created from edr_standard.DISPLAY_DATE_ONLY
-- ---------------------------------------

PROCEDURE DISPLAY_DATE_ONLY (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2 default NULL,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        P_DATE_IN               IN      DATE ,
        x_date_out              OUT     NOCOPY Varchar2 ) ;
-- --------------------------------------
-- API name     : DISPLAY_TIME_ONLY
-- Type         : Public
-- Pre-reqs     : None
-- Function     : convert a date to string
-- Parameters
-- IN   :       p_api_version  NUMBER   1.0
--              p_init_msg_list VARCHAR2
--              p_date_in       DATE   date that need to be converted
-- OUT  :       x_return_status VARCHAR2
--              x_msg_count     NUMBER
--              x_msg_data      VARCHAR2
--              x_date_out      VARCHAR2  converted time
-- Versions     : 1.0   12-Nov-03       created from edr_standard.DISPLAY_TIME_ONLY
-- ---------------------------------------

PROCEDURE DISPLAY_TIME_ONLY (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2 default NULL,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        P_DATE_IN               IN      DATE ,
        x_date_out              OUT     NOCOPY Varchar2 ) ;


-- Bug 3214495 : Start

-- --------------------------------------
-- API name 	: Get_AmeRule_VarValues
-- Type		: Public
-- Pre-reqs	: None
-- Function	: check if the table column has been audited with a different old value
-- Parameters
-- IN	:	p_transaction_name  	VARCHAR2	transaction name, eg GMI ERES Item Creation
--		p_ameRule_id		NUMBER		AME rule id, eg 11400
--		p_ameRule_name		VARCHAR2	AME rule name, eg Item Creation Rule
-- OUT	:	x_inputVar_values_tbl	inputvar_values_tbl_type	table of inputVar values
-- Versions	: 1.0	17-Jul-03	created from edr_standard.GET_AMERULE_INPUT_VALUES
-- ---------------------------------------


/*#
 * This API returns the table of configuration variables for an AME Transaction and Rule.
 * This API has been deprecated and replaced by GET_AMERULE_VARIABLEVALUES.
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:displayname Get AME rule level configuration values
 */


PROCEDURE Get_AmeRule_VarValues (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_transaction_name     	IN   	VARCHAR2,
        p_ameRule_id          	IN    	NUMBER,
        p_ameRule_name        	IN    	VARCHAR2,
        x_inputVar_values_tbl 	OUT 	NOCOPY InputVar_Values_tbl_type  ) ;



-- --------------------------------------
-- API name 	: Get_AmeRule_VariableValues
-- Type		: Public
-- Pre-reqs	: None
-- Function	: check if the table column has been audited with a different old value
-- Parameters
-- IN	:	p_transaction_id  	VARCHAR2	transaction id, eg oracle.apps.gme.batch.create
--		p_ameRule_id		NUMBER		AME rule id, eg 11400
--		p_ameRule_name		VARCHAR2	AME rule name, eg Item Creation Rule
-- OUT	:	x_inputVar_values_tbl	inputvar_values_tbl_type	table of inputVar values
-- Versions	: 1.0	19-Feb-05	created from edr_standard.GET_AMERULE_INPUT_VALUES
-- ---------------------------------------

/*#
 * This API returns the table of configuration variables for an AME Transaction and Rule.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get AME rule level configuration values
 */

PROCEDURE Get_AmeRule_VariableValues (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_transaction_id     	IN   	VARCHAR2,
        p_ameRule_id          	IN    	NUMBER,
        p_ameRule_name        	IN    	VARCHAR2,
        x_inputVar_values_tbl 	OUT 	NOCOPY InputVar_Values_tbl_type  ) ;

-- Bug 3214495 : End

-- --------------------------------------
-- API name 	: Is_AuditValue_Old
-- Type		: Public
-- Pre-reqs	: None
-- Function	: check if the table column has been audited with a different old value
-- Parameters
-- IN	:	p_table_name   		VARCHAR2	table being audited, eg oracle.apps.gmi.item.create
--		p_column_name		VARCHAR2	column to be checked, eg ItemNo3125
--		p_primKey_name		VARCHAR2	name of primary key, eg ItemNo3125
--		p_primKey_value		VARCHAR2	value of primary key, eg ItemNo3125
-- OUT	:	x_auditValue_old	VARCHAR2	indicate if the audited value is updated
-- Versions	: 1.0	17-Jul-03	created from edr_standard.COMPARE_AUDITVALUES
-- ---------------------------------------

Procedure Is_AuditValue_Old (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_table_name 		IN 	VARCHAR2,
	p_column_name   	IN 	VARCHAR2,
	p_primKey_name     	IN 	VARCHAR2,
	p_primKey_value    	IN 	VARCHAR2,
	x_isOld_auditValue	OUT	NOCOPY VARCHAR2   );


-- --------------------------------------
-- API name 	: Get_Notif_Routing_Info
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtain the overriding recipient and routing comment for a routed notification
-- Parameters
-- IN	:	p_original_recipient   	VARCHAR2	original recipient
--		p_message_type		VARCHAR2	message type
--		p_message_name		VARCHAR2	message name
-- OUT	:	x_final_recipient	VARCHAR2	final recipient
--		x_allrout_comments	VARCHAR2	all routing comments
-- Versions	: 1.0	17-Jul-03	created from edr_standard.FIND_WF_NTF_RECIPIENT
-- ---------------------------------------

PROCEDURE Get_Notif_Routing_Info (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_original_recipient 	IN 	VARCHAR2,
        p_message_type 		IN 	VARCHAR2,
        p_message_name 		IN 	VARCHAR2,
	x_final_recipient	OUT	NOCOPY VARCHAR2,
	x_allrout_comments	OUT	NOCOPY VARCHAR2   );



-- --------------------------------------
-- API name 	: Get_DescFlex_OnePrompt
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains a single descriptive flexfield prompt for designated column
-- Parameters
-- IN	:	p_application_id  	NUMBER		descriptive flexfield owner application id
--		p_descFlex_defName	VARCHAR2	name of flexfield definiation
--		p_descFlex_context	VARCHAR2	flex definition context (ATTRIBUTE_CATEGORY)
--		p_column_name		VARCHAR2	name of the column corresponding to a flex segment
--		p_prompt_type		VARCHAR2	indicate the field from which to return values
--					'LEFT' --> FORM_LEFT_PROMPT; 'ABOVE' --> FORM_ABOVE_PROMPT
-- OUT	:	x_column_prompt		VARCHAR2	the prompt values for the columns
-- Versions	: 1.0	17-Jul-03	created from edr_standard.GET_DESC_FLEX_SINGLE_PROMPT
-- ---------------------------------------

PROCEDURE Get_DescFlex_OnePrompt (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_application_id     	IN 	NUMBER,
	p_descFlex_defName 	IN 	VARCHAR2,
	p_descFlex_context  	IN 	VARCHAR2,
	P_COLUMN_NAME        	IN 	VARCHAR2,
	P_PROMPT_TYPE        	IN 	VARCHAR2 DEFAULT NULL,
	x_column_prompt      	OUT 	NOCOPY VARCHAR2   );



-- --------------------------------------
-- API name 	: Get_DescFlex_AllPrompts
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains all 30 descriptive flexfield prompts
-- Parameters
-- IN	:	p_application_id  	NUMBER		descriptive flexfield owner application id
--		p_descFlex_defName	VARCHAR2	name of flexfield definiation
--		p_descFlex_context	VARCHAR2	flex definition context (ATTRIBUTE_CATEGORY)
--		p_colnNames_rec		Flex_ColnName_Rec_Type
--							names of the columns corresponding to a flex segment
--		p_prompt_type		VARCHAR2	indicate the field from which to return values
--					'LEFT': FORM_LEFT_PROMPT; 'ABOVE': FORM_ABOVE_PROMPT
-- OUT	:	x_colnPrompts_rec 	Flex_ColnPrompt_Rec_Type
--							the prompt values for the columns
-- Versions	: 1.0	17-Jul-03	created from edr_standard.GET_DESC_FLEX_ALL_PROMPTS
-- ---------------------------------------


PROCEDURE Get_DescFlex_AllPrompts (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_application_id     	IN 	NUMBER,
	p_descFlex_defName 	IN 	VARCHAR2,
	p_descFlex_context  	IN 	VARCHAR2,
	p_colnNames_rec		IN	edr_standard_pub.Flex_ColnName_Rec_Type,
	p_prompt_type        	IN 	VARCHAR2 DEFAULT NULL,
	x_colnPrompts_rec	OUT	NOCOPY edr_standard_pub.Flex_ColnPrompt_Rec_Type  );



-- --------------------------------------
-- API name 	: Get_Lookup_Meaning
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Obtains lookup code meaning using fnd_lookups view
-- Parameters
-- IN	:	p_lookup_type   VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_lookup_code	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_psig_status	VARCHAR2	event psig status
-- Versions	: 1.0	17-Jul-03	created from edr_standard.Get_Meaning
-- ---------------------------------------

PROCEDURE Get_Lookup_Meaning (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_lookup_type 		IN 	VARCHAR2,
	p_lookup_code 		IN 	VARCHAR2,
	x_lkup_meaning 		OUT 	NOCOPY VARCHAR2  );


-- --------------------------------------
-- API name 	: Get_QueryId_OnParams
-- Type		: Public
-- Pre-reqs	: None
-- Function	: obtain a query id for events based on arrays of event parameters (name, key)
-- Parameters
-- IN	:	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--		p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_query_id	NUMBER		one query id for all events details
-- Versions	: 1.0	17-Jul-03	created from edr_standard.Psig_Status
-- ---------------------------------------

PROCEDURE Get_QueryId_OnParams (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_eventNames_tbl 	IN 	FND_TABLE_OF_VARCHAR2_255,
	p_eventKeys_tbl		IN 	FND_TABLE_OF_VARCHAR2_255,
	x_query_id		OUT 	NOCOPY NUMBER );

-- Start of comments
-- API name             : GET_ERECORD_ID
-- Type                 : public
-- Function             : accepts event name and event key and returns Latest eRecord ID
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_event_name           IN VARCHAR2     Required
--                       p_event_key            IN VARCHAR2     Required
--
-- OUT                  :x_return_status        OUT VARCHAR2(1)
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2(2000)
--                       x_erecord_id           OUT NUMBER
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :
--
--
-- End of comments
/*#
 * This API retreives the latest e-record ID.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retreive the latest e-record ID
 */

PROCEDURE GET_ERECORD_ID ( p_api_version   IN	NUMBER	    ,
                           p_init_msg_list IN	VARCHAR2 default NULL ,
                           x_return_status OUT	NOCOPY VARCHAR2 ,
                           x_msg_count	 OUT	NOCOPY NUMBER   ,
                           x_msg_data	 OUT	NOCOPY VARCHAR2 ,
                           p_event_name    IN   VARCHAR2        ,
                           p_event_key     IN   VARCHAR2        ,
                           x_erecord_id	 OUT NOCOPY 	NUMBER );

--Bug 3437422: Start
-- Start of comments
-- API name             : USER_DATA_XML
-- Type                 : public
-- Function             : Returns the value of the USER_DATA node in the
--                        XML payload of any ERES Event
--
-- Pre-reqs             : None.
-- Parameters           :
-- OUT                  :x_user_data        OUT VARCHAR2(2000)
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :
--
--
-- End of comments
PROCEDURE USER_DATA_XML (X_USER_DATA OUT NOCOPY VARCHAR2);
--Bug 3437422: End

-- Bug 3848049 : Start

-- API name             : GET_ERECORD_ID
-- Type                 : public
-- Function             : Accepts event name and event key and returns Latest
--                        eRecord ID
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_event_name           IN VARCHAR2     Required
--                        p_event_key            IN VARCHAR2     Required
--
-- Return Paramter
--                       erecord_id             Return Number
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :
--
--
-- End of comments



FUNCTION GET_ERECORD_ID ( p_event_name    IN   VARCHAR2,
                          p_event_key     IN   VARCHAR2) return NUMBER;
-- Bug 3848049 : End



END EDR_STANDARD_PUB;

 

/
