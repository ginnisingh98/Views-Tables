--------------------------------------------------------
--  DDL for Package QA_EDR_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_EDR_STANDARD" AUTHID CURRENT_USER AS
/* $Header: qaedrs.pls 115.4 2004/02/18 01:55:12 isivakum noship $

/* Global Variables */

G_SIGNATURE_STATUS varchar2(80):=NULL; -- Global variable which hold the status of workflow ('APPROVED','REJECTED')

/* Global Record Groups */

Type eventDetails is record(
                     event_name varchar2(240),
                     event_key  varchar2(240),
                     key_type   VARCHAR2(40)
                    );
Type eventQuery is table of eventDetails index by binary_integer;

 --Below from EDR_ERES_EVENT_PUB
 -- Table of erecord ids
TYPE ERECORD_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Record type to represent an ERES event
--Bug 3136403: Start
--Change the definition of the record type to denormalize the payload parameters
/*
TYPE ERES_EVENT_REC_TYPE IS RECORD
( EVENT_NAME                              VARCHAR2(80)                       ,
  EVENT_KEY                               VARCHAR2(240)                      ,
  PAYLOAD                                 FND_WF_EVENT.PARAM_TABLE           ,
  ERECORD_ID                              NUMBER                             ,
  EVENT_STATUS                            VARCHAR2(20)
);
*/

TYPE ERES_EVENT_REC_TYPE IS RECORD
( EVENT_NAME                              VARCHAR2(80)                       ,
  EVENT_KEY                               VARCHAR2(240)                      ,
  ERECORD_ID                              NUMBER                             ,
  EVENT_STATUS                            VARCHAR2(20)    DEFAULT NULL       ,
  PARAM_NAME_1                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_1                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_2                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_2                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_3                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_3                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_4                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_4                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_5                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_5                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_6                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_6                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_7                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_7                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_8                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_8                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_9                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_9                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_10                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_10                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_11                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_11                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_12                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_12                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_13                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_13                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_14                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_14                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_15                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_15                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_16                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_16                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_17                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_17                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_18                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_18                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_19                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_19                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_20                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_20                          VARCHAR2(2000)  DEFAULT NULL
);
--Bug 3136403: End

-- A table of ERES Events

TYPE ERES_EVENT_TBL_TYPE IS TABLE OF ERES_EVENT_REC_TYPE INDEX BY BINARY_INTEGER;

--Below added for bug 3265661 so Fuad can call this from engwkfwb.pls
TYPE params_rec IS RECORD (Param_Name VARCHAR2(80),
                           Param_Value VARCHAR2(4000),
                           Param_displayname varchar2(240));

TYPE Params_tbl_type IS TABLE of params_rec INDEX by Binary_INTEGER;

----------------------------------------------------------------

-- ---------------------------------------

PROCEDURE Get_PsigStatus (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 		in    	varchar2,
	p_event_key		in    	varchar2,
      	x_psig_status    	out 	NOCOPY varchar2   ) ;


-- ---------------------------------------

PROCEDURE Is_eSig_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eSig      	OUT 	NOCOPY VARCHAR2  ) ;



-- ---------------------------------------

PROCEDURE Is_eRec_Required  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	IN   	varchar2,
	x_isRequired_eRec     	OUT 	NOCOPY VARCHAR2   ) ;


-- ---------------------------------------

Procedure Get_QueryId_OnEvents (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_eventQuery_recTbl 	IN	qa_edr_standard.eventQuery,
	x_query_id		OUT	NOCOPY NUMBER  );


-- --------------------------------------

PROCEDURE DISPLAY_DATE_PUB (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_DATE_IN  		IN  	DATE ,
	x_date_out 		OUT 	NOCOPY Varchar2 ) ;


-- ---------------------------------------

Procedure Is_AuditValue_Old (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_table_name 		IN 	VARCHAR2,
	p_column_name   	IN 	VARCHAR2,
	p_primKey_name     	IN 	VARCHAR2,
	p_primKey_value    	IN 	VARCHAR2,
	x_isOld_auditValue	OUT	NOCOPY VARCHAR2   );

-- ---------------------------------------
PROCEDURE Get_Lookup_Meaning (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_lookup_type 		IN 	VARCHAR2,
	p_lookup_code 		IN 	VARCHAR2,
	x_lkup_meaning 		OUT 	NOCOPY VARCHAR2  );




------------------------------------------------------------------
--This function is replaced by a new public API formatted procedure
--called Get_QueryId_OnEvents
--Please use that instead. This function is temporarily still kept here
FUNCTION PSIG_QUERY(p_eventQuery QA_EDR_STANDARD.eventQuery) return number;


-- This Function Returns a display date formatted for xml document
-- There is a new public API formatted procedure
-- called DISPLAY_DATE_PUB . Please use that if you prefer that format
  PROCEDURE DISPLAY_DATE(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) ;

--for interevents raising
PROCEDURE RAISE_ERES_EVENT
( p_api_version         IN                NUMBER                          ,
  p_init_msg_list       IN                VARCHAR2,
  p_validation_level    IN                NUMBER,
  x_return_status       OUT NOCOPY        VARCHAR2                        ,
  x_msg_count           OUT NOCOPY        NUMBER                          ,
  x_msg_data            OUT NOCOPY        VARCHAR2                        ,
  p_child_erecords      IN                ERECORD_ID_TBL_TYPE             ,
  x_event               IN OUT NOCOPY     ERES_EVENT_REC_TYPE
);

PROCEDURE RAISE_INTER_EVENT
( p_api_version          IN               NUMBER                          ,
  p_init_msg_list        IN               VARCHAR2,
  p_validation_level     IN               NUMBER,
  x_return_status        OUT NOCOPY       VARCHAR2                        ,
  x_msg_count            OUT NOCOPY       NUMBER                          ,
  x_msg_data             OUT NOCOPY       VARCHAR2                        ,
  x_events               IN OUT NOCOPY    ERES_EVENT_TBL_TYPE             ,
  x_overall_status 	 OUT NOCOPY       VARCHAR2
);


PROCEDURE GET_ERECORD_ID ( p_api_version   IN	NUMBER	    ,
                           p_init_msg_list IN	VARCHAR2  ,
                           x_return_status OUT	NOCOPY VARCHAR2 ,
                           x_msg_count	 OUT	NOCOPY NUMBER   ,
                           x_msg_data	 OUT	NOCOPY VARCHAR2 ,
                           p_event_name    IN   VARCHAR2        ,
                           p_event_key     IN   VARCHAR2        ,
                           x_erecord_id	 OUT NOCOPY 	NUMBER         );

--For Acknowledgement (Transaction Acknowledgement) feature
procedure SEND_ACKN
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY 	NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_event_name           IN            	VARCHAR2  			   ,
  p_event_key            IN            	VARCHAR2  			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2          		   ,
  p_ackn_note	         IN		VARCHAR2 			   ,
  p_autonomous_commit	 IN  		VARCHAR2
);

-- ----------------------------------------
-- API name 	: wrapper for edr Capture_Signature
-- Reference	: edr_evidencestore_pub.capture_signature for documentation
-- Function	: capture the signature for single event
-- BUG: Below added for bug 3265661 so Fuad can call this from engwkfwb.pls
-- ---------------------------------------

PROCEDURE Capture_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_psig_xml		IN 	CLOB default null,
	p_psig_document		IN 	CLOB default null,
	p_psig_docFormat	IN 	VARCHAR2,
	p_psig_requester	IN 	VARCHAR2,
	p_psig_source		IN 	VARCHAR2,
	p_event_name		IN 	VARCHAR2,
	p_event_key		IN 	VARCHAR2,
	p_wf_notif_id		IN 	NUMBER,
	x_document_id		OUT	NOCOPY NUMBER,
	p_doc_parameters_tbl	IN	qa_edr_standard.Params_tbl_type,
	p_user_name		IN	VARCHAR2,
	p_original_recipient	IN	VARCHAR2 default null,
	p_overriding_comment	IN	VARCHAR2 default null,
	x_signature_id		OUT	NOCOPY NUMBER,
	p_evidenceStore_id	IN	NUMBER,
	p_user_response		IN	VARCHAR2,
	p_sig_parameters_tbl	IN	qa_edr_standard.Params_tbl_type );

  FUNCTION IS_INSTALLED RETURN VARCHAR2;
  --Above is a new function added as per bug 3253566
  --it returns 'F' in the stub version and 'T' in real version

   -- ALL OF BELOW 6 Procedures added due to Bug 3447098 as requested by
   -- ENG-Eres team developer Fuad Abdi
-- ----------------------------------------
-- API name 	: Open_Document (Bug 3447098)
-- Type		: Public
-- Function	: create a document instance for signature
--		: and can associate signatures before closing the docuemnt
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE open_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_PSIG_XML    		IN 	CLOB DEFAULT NULL,
    P_PSIG_DOCUMENT  	IN 	CLOB DEFAULT NULL,
    P_PSIG_DOCUMENTFORMAT  	IN 	VARCHAR2 DEFAULT NULL,
    P_PSIG_REQUESTER	IN 	VARCHAR2,
    P_PSIG_SOURCE    	IN 	VARCHAR2 DEFAULT NULL,
    P_EVENT_NAME  		IN 	VARCHAR2 DEFAULT NULL,
    P_EVENT_KEY  		IN 	VARCHAR2 DEFAULT NULL,
    p_WF_Notif_ID           IN 	NUMBER   DEFAULT NULL,
    x_DOCUMENT_ID          	OUT 	NOCOPY NUMBER	);

-- ----------------------------------------
-- API name 	: Post_DocumentParameter (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_DocumentParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    p_document_id          	IN  	NUMBER,
    p_doc_parameters_tbl  	IN  	qa_edr_standard.Params_tbl_type   );

-- ----------------------------------------
-- API name 	: Close_Document (Bug 3447098)
-- Type		: Public
-- Function	: close a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Close_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    P_DOCUMENT_ID          	IN  	NUMBER	);

-- ----------------------------------------
-- API name 	: Request_Signature (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Request_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    P_DOCUMENT_ID         	IN 	NUMBER,
	P_USER_NAME           	IN 	VARCHAR2,
    P_ORIGINAL_RECIPIENT  	IN 	VARCHAR2 DEFAULT NULL,
    P_OVERRIDING_COMMENT 	IN 	VARCHAR2 DEFAULT NULL,
    x_signature_id         	OUT 	NOCOPY NUMBER      );


-- ----------------------------------------
-- API name 	: Post_Signature (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    P_DOCUMENT_ID         	IN 	NUMBER,
	p_evidenceStore_id  	IN 	VARCHAR2,
	P_USER_NAME          	IN 	VARCHAR2,
	P_USER_RESPONSE      	IN 	VARCHAR2,
    P_ORIGINAL_RECIPIENT  	IN 	VARCHAR2 DEFAULT NULL,
    P_OVERRIDING_COMMENT 	IN 	VARCHAR2 DEFAULT NULL,
    x_signature_id         	OUT 	NOCOPY NUMBER        );



-- ----------------------------------------
-- API name 	: Post_SignatureParameter (Bug 3447098)
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_SignatureParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    p_signature_id         	IN  	NUMBER,
    p_sig_parameters_tbl	IN  	qa_edr_standard.Params_tbl_type   );

end qa_edr_standard;

 

/
