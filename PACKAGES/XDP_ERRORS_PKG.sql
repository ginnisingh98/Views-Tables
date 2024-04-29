--------------------------------------------------------
--  DDL for Package XDP_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ERRORS_PKG" AUTHID CURRENT_USER AS
/* $Header: XDPERRRS.pls 120.1 2005/06/15 22:58:21 appldev  $ */

pv_MsgParamSeparator 	VARCHAR2(10) 	:= '#XDP#';
pv_MsgParamSeparatorSize	NUMBER 	:= LENGTH(pv_MsgParamSeparator);
pv_NameValueSeparator 	VARCHAR2(10) 	:= '=';

-- Error Types
pv_typeSystem		VARCHAR2(30)	:= 'SYSTEM';
pv_typeBusiness		VARCHAR2(30)	:= 'BUSINESS';


--   Inserts the message name and its parameters in the XDP_ERROR_LOG table
--   Message parameters are separated by #XDP#, for e.g.,
--   for message "Invalid status for adapter ADAPTER_NAME. Current status is STATUS"
--   parameters will be "ADAPTER_NAME=SuperTel1#XDP#STATUS=SUSPENDED#XDP#"

 PROCEDURE Set_Message (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_message_name 		IN VARCHAR2,
		p_message_parameters	IN VARCHAR2,
		p_error_type		IN VARCHAR2 DEFAULT pv_typeSystem);

--  Same as Set_Message, just that this is autonomous

 PROCEDURE Set_Message_Auto (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_message_name 		IN VARCHAR2,
		p_message_parameters	IN VARCHAR2,
		p_error_type		IN VARCHAR2 DEFAULT pv_typeSystem);

--  Wrapper to log workflow errors..
Procedure LOG_WF_ERROR (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2);


--   Gets the last MLS message text associated with the object instance

 PROCEDURE Get_Last_Message (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_message 		OUT NOCOPY VARCHAR2,
		p_error_type		OUT NOCOPY VARCHAR2,
		p_message_timestamp 	OUT NOCOPY DATE);

--   Parses the message parameters and returns the MLS message text associated with the
--   the message. This function is used in the view XDP_ERROR_LOG_V

 FUNCTION GET_MESSAGE (
		p_message_name 		IN VARCHAR2,
		p_message_parameters	IN VARCHAR2)
	return VARCHAR2;

--   Updates (or inserts) error count for the specified object type and key. By default,
--   resets the error count to 0.

 PROCEDURE Update_Error_Count (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_error_count		IN NUMBER DEFAULT 0);

--   Gets error count for the specified object type and key. In case of "no data found",
--   returns error count of 0.

 Function Get_Error_Count (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2)
	return NUMBER;

END XDP_ERRORS_PKG;

 

/
