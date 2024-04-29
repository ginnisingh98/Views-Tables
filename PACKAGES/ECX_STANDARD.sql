--------------------------------------------------------
--  DDL for Package ECX_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_STANDARD" AUTHID CURRENT_USER AS
-- $Header: ECXWACTS.pls 120.4.12010000.2 2008/11/18 18:13:21 cpeixoto ship $
/*#
 * The interface contains generic routines to be used by activity functions.
 * @rep:scope public
 * @rep:product ECX
 * @rep:lifecycle active
 * @rep:displayname XML Gateway Transformation
 * @rep:compatibility S
 */

-- setEventDetails (PUBLIC)
--   Standard XML Gateway Raise Event
-- IN:
--   eventname      - Event to be processes
--   eventkey       - Event key
--   parameter1..10 - Event Parameters
-- NOTE:
--   Called from the XML gateway engine as a post processing action

procedure setEventDetails
	(
	eventname	in	varchar2,
	eventkey	in	varchar2,
	parameter1	in	varchar2,
	parameter2	in	varchar2,
	parameter3	in	varchar2,
	parameter4	in	varchar2,
	parameter5	in	varchar2,
	parameter6	in	varchar2,
	parameter7	in	varchar2,
	parameter8	in	varchar2,
	parameter9	in	varchar2,
	parameter10	in	varchar2,
	retcode		OUT	NOCOPY pls_integer,
	retmsg		OUT	NOCOPY varchar2
	);

-- getEventDetails (PUBLIC)
--   Standard XML Gateway Event API
-- OUT:
--   eventname      - Event to the processes
--   eventkey       - Event key
-- NOTE:
--   Called from the MD maintained as a GLobal parameter by the XML gateway engine
procedure getEventDetails
	(
	eventname	out	NOCOPY varchar2,
	eventkey	out	NOCOPY varchar2,
	itemtype	out	NOCOPY varchar2,
	itemkey		out	NOCOPY varchar2,
	parentitemtype	out	NOCOPY varchar2,
	parentitemkey	out	NOCOPY varchar2,
	retcode		OUT	NOCOPY pls_integer,
	retmsg		OUT	NOCOPY varchar2
	);

-- getEventSystem (PUBLIC)
--   Standard XML Gateway Event API
-- OUT:
--   eventname      - Event to the processes
--   eventkey       - Event key
-- NOTE:
--   Called from the MD maintained as a GLobal parameter by the XML gateway engine
procedure getEventSystem
	(
	from_agent	out	NOCOPY varchar2,
	to_agent	out	NOCOPY varchar2,
	from_system	out	NOCOPY varchar2,
	to_system	out	NOCOPY varchar2,
	retcode		OUT	NOCOPY pls_integer,
	retmsg		OUT	NOCOPY varchar2
	);

-- EventDate (PUBLIC)
--   Standard XML Gateway to generate event data
-- IN:
--   p_event_name      - Event to be processes
--   p_event_key       - Event key
--   p_event  - Event Data list
-- OUT
--   CLOB	    - Event data
-- NOTE:
--   Called from the XML gateway engine as a post processing action
--
--
-- VS - Added paramter list??? Lets discuss.
--    - where and when will this be called from

function generate
	(
	p_event_name		in	varchar2,
	p_event_key		in 	varchar2,
	p_parameter_list        in 	wf_parameter_list_t
        ) return CLOB;

-- ProcessXML
-- Standard Workflow Activity processXML
-- Load XML Document into Application
-- OUT
--   result - null
-- ACTIVITY ATTRIBUTES REFERENCED
--   MAP_CODE          - text value
--   DEBUG_LEVEL       - number value
--   EVENT_MESSAGE     - event value
-- NOTE:

procedure processXML
     	(
	itemtype   	in varchar2,
	itemkey    	in varchar2,
	actid      	in number,
	funcmode   	in varchar2,
	resultout  	in out NOCOPY varchar2
	);

-- XMLtoXML
-- Standard Workflow Activity XMLtoXML
-- Transforms an Inbound XML to an Outbound XML
-- OUT
--   result - null
-- ACTIVITY ATTRIBUTES REFERENCED
--   MAP_CODE          - text value
--   DEBUG_LEVEL       - number value
--   EVENT_MESSAGE_IN  - event value
--   EVENT_MESSAGE_OUT - event value
-- NOTE:

procedure XMLtoXML
     	(
	itemtype   	in varchar2,
	itemkey    	in varchar2,
	actid      	in number,
	funcmode   	in varchar2,
	resultout  	in out NOCOPY varchar2
	);

-- IsDeliveryRequired
--   Standard ECX Workflow Activity
--   Deterin if trading partner is enabled to recieve document
-- OUT
--   result - T - Trading Partner is enabled
--            F - Trading Partner is NOT enabled
-- ACTIVITY ATTRIBUTES REFERENCED
--   TRANSACTION_TYPE    - text value
--   TRANSACTION_SUBTYPE - text value
--   PARTY_ID		 - number value
--   PARTY_SITE_ID	 - number value
-- NOTE:

procedure isDeliveryRequired
     	(
	itemtype   	in varchar2,
	itemkey    	in varchar2,
	actid      	in number,
	funcmode   	in varchar2,
	resultout  	in out NOCOPY varchar2
	);

-- Send
--   Standard ECX Workflow Activity
--   Send Event to AQ fro delivery
-- OUT
--   result - null
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   TRANSACTION_TYPE    - text value
--   TRANSACTION_SUBTYPE - text value
--   PARTY_ID		 - number value
--   PARTY_SITE_ID	 - number value
--   DOCUMENT_D		 - text value
--   PARAMETER1..5	 - text value
--   SEND_MODE		 - Text (lookup (SYNCH ASYNCH )
-- NOTE:

procedure send
     	(
	itemtype   	in varchar2,
	itemkey    	in varchar2,
	actid      	in number,
	funcmode   	in varchar2,
	resultout  	in out NOCOPY varchar2
	);


-- GetXMLTP
--   Standard ECX Workflow Activity
--   Retrieve XML document
-- OUT
--   result - null
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   TRANSACTION_TYPE    - text value (Required)
--   TRANSACTION_SUBTYPE - text value (Required)
--   PARTY_SITE_ID	 - text value (Required)
--   PARTY_ID		 - text value (optional)
--   DOCUMENT_D		 - text value (Required)
--   EVENT_NAME		 - text value (optional)
--   EVENT_KEY		 - text value (optional)
--   PARAMETER1..5	 - text value (optional)
--
--   EVENT_MESSAGE       - Item ATTR  (required)
-- NOTE:

procedure GetXMLTP(itemtype   in varchar2,
		   itemkey    in varchar2,
		   actid      in number,
		   funcmode   in varchar2,
	 	   resultout  in out NOCOPY varchar2);




-- GetXML
--   Standard ECX Workflow Activity
--   Retrieve XML document
-- OUT
--   result - null
--
-- ACTIVITY ATTRIBUTES REFERENCED
--   MAP_CODE		 - text value (required)
--   EVENT_NAME		 - text value (optional)
--   EVENT_KEY		 - text value (optional)
--   PARAMETER1..5	 - text value (optional)
--
--   EVENT_MESSAGE       - Item ATTR  (required)
-- NOTE:

procedure GetXML
	(
	itemtype   in varchar2,
	itemkey    in varchar2,
	actid      in number,
	funcmode   in varchar2,
	resultout  in out NOCOPY varchar2
	);

/**
Reprocesses a Given Inbound Activity. The inputs are the
Message Id,Trigger Id and the Debug Level.
**/
procedure Reprocess_Inbound(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	result    in out NOCOPY varchar2
	);

/**
Resends a Given Outbound Message . The input is the
Message Id.
**/
procedure resend
	(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	result    in out NOCOPY varchar2
	);

/**
Exposed for use by ecx_rule.inbound_rule2
**/

procedure processXMLCover
        (
        i_map_code              IN      varchar2,
        i_inpayload             IN      CLOB,
        i_debug_level           IN      pls_integer
        );
function getReferenceId
	return varchar2;

/*#
 * This interface is used to apply a style sheet to an XML message
 * and return the transformed XML message for further processing
 * by the calling environment.
 * The DTD file name, version, and root element are required input
 * parameters for this API, therefore the associated DTDs must be loaded
 * into the XML Gateway repository.
 * This API is independent of the Message Designer: XSLT Transformation
 * action. This API is not intended for use in a message map.
 * Note: The profile option ECX_XML_VALIDATE_FLAG must
 * be set to 'Y' for this action to be performed.
 * @param i_xml_file The XML message to be transformed.This is an 'in out' parameter transformed XML will also be assigned to it.
 * @param i_xslt_file_name The XSLT style sheet file to be used for the transformation
 * @param i_xslt_file_ver The version of the XSLT style sheet file.
 * @param i_xslt_application_code The name of the subdirectory where the XSLT style sheet is source controlled
 * @param i_dtd_file_name The name of the DTD used in the XML message
 * @param i_dtd_root_element The root element of the DTD used in the XML message
 * @param i_dtd_version Version of the DTD used in the XML message.
 * @param i_retcode Return code for the procedure
 * @param i_retmsg Return message for the procedure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname XML Gateway Transformation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY ECX_TRANSFORMATION
 */
procedure perform_xslt_transformation
	(
	i_xml_file		in out	NOCOPY clob,
	i_xslt_file_name	in	varchar2,
	i_xslt_file_ver		in	varchar2	default null,
	i_xslt_application_code	in	varchar2,
        i_retcode		out	NOCOPY pls_integer,
	i_retmsg		out	NOCOPY varchar2,
        i_dtd_file_name         in      varchar2        default null,
        i_dtd_root_element      in      varchar2        default null,
        i_dtd_version           in      varchar2        default null
	);



-- -------------------------------------------------------------------------------------------
-- API name 	: GET_VALUE_FOR_XPATH
--
-- Type		    : Public
--
-- Pre-reqs	  : None
--
-- Function	  : Returns Value of the Node from the XML Document for the specified XPATH.
--              Incase of multiple occurrences, a list of comma-separated values is returned
--
-- Parameters
--	IN    : p_api_version       IN    NUMBER
--            : p_XML_DOCUMENT      IN    CLOB
--            : p_XPATH_EXPRESSION  IN    VARCHAR2
--
--	OUT   : x_return_status     OUT   VARCHAR2
--	      : x_msg_data	    OUT   VARCHAR2
--            : x_XPATH_VALUE       OUT  NOCOPY VARCHAR2
--
--	Version		: Current version       1.0
--			  Initial version 	1.0
--
--	Notes		  :
--
-- -------------------------------------------------------------------------------------------

PROCEDURE GET_VALUE_FOR_XPATH (
  p_api_version       IN                        NUMBER,
  x_return_status	    OUT   NOCOPY	VARCHAR2,
  x_msg_data		    OUT   NOCOPY	VARCHAR2,
  p_XML_DOCUMENT      IN    CLOB,
  p_XPATH_EXPRESSION  IN    VARCHAR2,
  x_XPATH_VALUE       OUT   NOCOPY	VARCHAR2
);


end ecx_standard;

/
