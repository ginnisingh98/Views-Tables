--------------------------------------------------------
--  DDL for Package XDP_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ENGINE" AUTHID CURRENT_USER AS
/* $Header: XDPENGNS.pls 120.1 2005/06/15 22:56:36 appldev  $ */


-- Datastructure Definitions

TYPE PARAMETER_REC IS RECORD(
    PARAMETER_NAME VARCHAR2(80),
    IS_VALUE_EVALUATED_FLAG Varchar2(1),
    PARAMETER_VALUE VARCHAR2(2000),
    PARAMETER_REFERENCE_VALUE VARCHAR2(2000) DEFAULT NULL);

-- list of the activation parameter
  TYPE PARAMETER_LIST IS TABLE OF PARAMETER_REC
    INDEX BY BINARY_INTEGER;


  pv_FeAttributeList XDP_TYPES.ORDER_PARAMETER_LIST;

  pv_evalModeUponReceipt varchar2(80) := 'ON_ORDER_RECEIPT';
  pv_evalModeDeferred varchar2(80) := 'ON_PROCESS_ORDER';
  pv_evalModeWIStart varchar2(80) := 'ON_WORKITEM_START';

-- API specifications

-- Start of comments
--	API name 	: GET_WORKITEM_PARAM_VALUE
--	Type		: Public
--	Function	: Get a workitem parameter value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the work item parameter
--	@return		The value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
--   Get a workitem parameter value.  The macro
--   $WI.<parameter_name> in FP actually uses this
--   function for runtime value substitution.
-- End of comments
 FUNCTION GET_WORKITEM_PARAM_VALUE(
	p_wi_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--	API name 	: GET_WORKITEM_PARAM_REF_VALUE
--	Type		: Public
--	Function	: Get a workitem parameter reference value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the work item parameter
--	@return		The reference value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
--   Get a workitem parameter reference value.  The macro
--   $WI_REF.<parameter_name> in FP actually uses this
--   function for runtime value substitution.
-- End of comments
 FUNCTION GET_WORKITEM_PARAM_REF_VALUE(
	p_wi_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--	API name 	: GET_WORKITEM_PARAM_VALUE
--	Type		: Private
--	Function	: Get the additional information for a work item parameter.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the work item parameter
--	OUT		:	p_param_val:			VARCHAR2
--					The value of the parameter.
--				p_parameter_ref_val:	VARCHAR2
--					The reference value of the parameter.
--				p_log_value_flag:	BOOLEAN
--					Indicate that the value should be stored in audit trail table or not
--				p_return_code:		NUMBER
--					Indicate the status of the API call.  Any non-zero values represents error.
--				p_error_description:	VARCHAR2
--					The description of error which is raised by the API
--
--	Version	: Current version	11.5
--	Notes	:
--  This procedure is used by SEND function to
--  get the additional information regarding
--  an workitem parameter.  It will also return a flag
--  to indicate if the parameter contains value
--  for a data sensitive parameter.  If it does, the command
--  string which SFM is about to send will not be logged
--  in our command audit trail tables.
-- End of comments
 PROCEDURE GET_WORKITEM_PARAM_VALUE(
	p_wi_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_param_val	     OUT NOCOPY VARCHAR2,
	p_param_ref_val  OUT NOCOPY VARCHAR2,
	p_log_value_flag  OUT NOCOPY BOOLEAN,
	p_return_code   OUT NOCOPY number,
	p_error_description  OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: GET_WORKITEM_PARAM_List
--	Type		: Private
--	Function	: Get a list of parameter value for a given work item.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--	@return		The list of values for all the parameters of a given work item
--	Version	: Current version	11.5
--	Notes	:
--   Get a list of the parameter values for
--   a given workitem instance
-- End of comments
 FUNCTION GET_WORKITEM_PARAM_List(
	p_wi_instance_id IN NUMBER)
   RETURN XDP_ENGINE.PARAMETER_LIST;

-- Start of comments
--	API name 	: SET_WORKITEM_PARAM_VALUE
--	Type		: Public
--	Function	: Set the value for a work item parameter.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the work item parameter
--				p_parameter_value:	VARCHAR2 	Required
--					The new value of the work item parameter
--				p_parameter_reference_value:	VARCHAR2 	Optional
--					The new reference value of the work item parameter
--					Default to be NULL.
--				p_evaluation_required:	BOOLEAN 	Optional
--					Indicate that the evaluation procedure should be executed if applicable.
--					Default to be FALSE.
--
--	Version	: Current version	11.5
--	Notes	:
--   Set the workitem parameter value for
--   a given workitem instance.  The parameter
--   evaluation procedure will be executed if
--   applicable.
-- End of comments
 PROCEDURE Set_Workitem_Param_value(
		p_wi_instance_id IN NUMBER,
		p_parameter_name IN VARCHAR2,
		p_parameter_value IN VARCHAR2,
		p_parameter_reference_value IN VARCHAR2 DEFAULT NULL,
		p_evaluation_required IN BOOLEAN DEFAULT FALSE);

-- Start of comments
--	API name 	: GET_WORKITEM_PROV_DATE
--	Type		: Public
--	Function	: Get the Fulfillment Date for a Workitem Instance.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--	@return		The work item Fulfillment date.
--
--	Version	: Current version	11.5
--	Notes	:
--   Get the Fulfillment Date for a Workitem Instance
-- End of comments
 FUNCTION GET_WORKITEM_PROV_DATE(
               p_wi_instance_id IN NUMBER)
   RETURN DATE;

-- Start of comments
--	API name 	: SET_WORKITEM_PROV_DATE
--	Type		: Public
--	Function	: Set the Fulfillment Date for a Workitem Instance.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_wi_instance_id:	NUMBER	Required
--					The runtime ID for a given work item instance
--				p_prov_date			DATE	Required
--					The Fulfillment Date for a Workitem Instance
--	OUT		:	p_return_code:		NUMBER
--					Indicate the status of the API call.  Any non-zero values represents error.
--				p_error_description:	VARCHAR2
--					The description of error which is raised by the API
--
--	Version	: Current version	11.5
--	Notes	:
--  Set the Fulfillment Date for a Workitem Instance
--  If the Workitem is being processed or already processed an error code is returned
-- End of comments
  PROCEDURE SET_WORKITEM_PROV_DATE(
		p_wi_instance_id in NUMBER,
		p_prov_date IN DATE,
     	p_return_code   OUT NOCOPY NUMBER,
        p_error_description  OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: GET_FA_PARAM_VALUE
--	Type		: Public
--	Function	: Get a fulfillment action parameter value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fa_instance_id:	NUMBER	Required
--					The runtime ID for a given fulfillment action instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the fulfillment action parameter
--	@return		The value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
--  Get an FA parameter value.  The macro
--  $FA.<parameter_name> in FP actually uses this
--  function for runtime value substitution.
-- End of comments
 FUNCTION GET_FA_PARAM_VALUE(
	p_fa_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--	API name 	: GET_FA_PARAM_REF_VALUE
--	Type		: Public
--	Function	: Get a fulfillment action parameter reference value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fa_instance_id:	NUMBER	Required
--					The runtime ID for a given fulfillment action instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the fulfillment action parameter
--	@return		The reference value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
--  Get an FA parameter reference value.  The macro
--  $FA_REF.<parameter_name> in FP actually uses this
--  function for runtime value substitution.
-- End of comments
 FUNCTION GET_FA_PARAM_REF_VALUE(
	p_fa_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--	API name 	: GET_FA_PARAM_VALUE
--	Type		: Private
--	Function	: Get the additional information for FA parameter.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fa_instance_id:	NUMBER	Required
--					The runtime ID for a given fulfillment action instance
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the fulfillment action parameter
--	OUT		:	p_param_val:			VARCHAR2
--					The value of the parameter.
--				p_parameter_ref_val:	VARCHAR2
--					The reference value of the parameter.
--				p_log_value_flag:	BOOLEAN
--					Indicate that the value should be stored in audit trail table or not
--				p_return_code:		NUMBER
--					Indicate the status of the API call.  Any non-zero values represents error.
--				p_error_description:	VARCHAR2
--					The description of error which is raised by the API
--
--	Version	: Current version	11.5
--	Notes	:
--  This procedure is used by SEND function to
--  get the additional information regarding
--  an FA parameter.  It will also return a flag
--  to indicate if the parameter contains decrypted value
--  for an encypted parameter.  If it does, the command
--  string which SFM is about to send will not be logged
--  in our command audit trail tables.
-- End of comments
 PROCEDURE GET_FA_PARAM(
	p_fa_instance_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_param_val	     OUT NOCOPY VARCHAR2,
	p_param_ref_val  OUT NOCOPY VARCHAR2,
	p_log_value_flag  OUT NOCOPY BOOLEAN,
	p_return_code   OUT NOCOPY number,
	p_error_description  OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: GET_FA_PARAM_List
--	Type		: Private
--	Function	: Get a list of parameter values for a given fulfillment action instance.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fa_instance_id:	NUMBER	Required
--					The runtime ID for a given fulfillment action instance
--	@return		The list of values for all the parameters of a given fulfillment action
--
--	Version	: Current version	11.5
--	Notes	:
--  Get a list of the parameter values for
--  a given FA instance
-- End of comments
 FUNCTION GET_FA_PARAM_List(
	p_fa_instance_id IN NUMBER)
   RETURN XDP_ENGINE.PARAMETER_LIST;

-- Start of comments
--	API name 	: SET_FA_PARAM_VALUE
--	Type		: Public
--	Function	: Set the value for a fulfillment action parameter.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fa_instance_id:	NUMBER	Required
--					The runtime ID for a given fulfillment action instance
--				p_fa_parameter_name:	VARCHAR2 	Required
--					The name of the fulfillment action parameter
--				p_parameter_value:	VARCHAR2 	Required
--					The new value of the fulfillment action parameter
--				p_parameter_reference_value:	VARCHAR2 	Optional
--					The new reference value of the fulfillment action parameter
--					Default to be NULL.
--				p_evaluation_required:	BOOLEAN 	Optional
--					Indicate that the evaluation procedure should be executed if applicable.
--
--	Version	: Current version	11.5
--	Notes	:
--   Set the FA parameter value for
--   a given FA instance.  The parameter
--   evaluation procedure will be executed if
--   applicable.
-- End of comments
 PROCEDURE Set_FA_Param_value(
		p_fa_instance_id IN NUMBER,
		p_parameter_name IN VARCHAR2,
		p_parameter_value IN VARCHAR2,
		p_parameter_reference_value IN VARCHAR2 DEFAULT NULL,
		p_evaluation_required IN BOOLEAN DEFAULT FALSE);


-- Start of comments
--	API name 	: GET_ORDER_PARAM_VALUE
--	Type		: Public
--	Function	: Get an order parameter value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_id:	NUMBER	Required
--					The internal ID for a given order
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the order parameter
--	@return		The value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
--  Get the value of an order parameter
-- End of comments
 FUNCTION GET_ORDER_PARAM_VALUE(
	p_order_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--
--	Version	: Current version	11.5
--	API name 	: GET_ORDER_PARAM_List
--	Type		: Private
--	Function	: Get a list of parameter values for a given order.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_id:	NUMBER	Required
--					The internal ID for a given order
--	@return		The list of values for all the order parameters of a given order
--
--	Notes	:
-- End of comments
 FUNCTION GET_ORDER_PARAM_List(
	p_order_id IN NUMBER  )
   RETURN XDP_ENGINE.PARAMETER_LIST;

-- Start of comments
--	API name 	: SET_ORDER_PARAM_VALUE
--	Type		: Public
--	Function	: Set the value for an order parameter.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_id:	NUMBER	Required
--					The internal ID for a given order
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the order parameter
--				p_parameter_value:	VARCHAR2 	Required
--					The new value of the order parameter
--
--	Version	: Current version	11.5
--	Notes	:
--  Set an order parameter value
-- End of comments
 PROCEDURE Set_ORDER_Param_value(
		p_order_id IN NUMBER,
		p_parameter_name IN VARCHAR2,
		p_parameter_value IN VARCHAR2);

-- Start of comments
--	API name 	: GET_LINE_PARAM_VALUE
--	Type		: Public
--	Function	: Get an order line parameter value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_line_item_id:	NUMBER	Required
--					The internal ID for a given order line
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the order line parameter
--	@return		The value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
--  Get the value of a line parameter
-- End of comments
 FUNCTION GET_LINE_PARAM_VALUE(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--	API name 	: GET_LINE_PARAM_REF_VALUE
--	Type		: Public
--	Function	: Get an order line parameter reference value.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_line_item_id:	NUMBER	Required
--					The internal ID for a given order line
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the order line parameter
--	@return		The reference value of the parameter will be returned.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 FUNCTION GET_LINE_PARAM_REF_VALUE(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2)
   RETURN VARCHAR2;

-- Start of comments
--	API name 	: ADD_LINE_PARAM
--	Type		: Public
--	Function	: Add a new runtime parameter to a given line.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_line_item_id:	NUMBER	Required
--					The internal ID for a given order line
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the order line parameter
--				p_parameter_value:	VARCHAR2 	Required
--					The value of the order line parameter
--				p_parameter_reference_value:	VARCHAR2 	Optional
--					The reference value of the order line parameter
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 PROCEDURE ADD_LINE_PARAM(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_parameter_value IN VARCHAR2,
	p_parameter_reference_value IN VARCHAR2 DEFAULT NULL);

-- Start of comments
--	API name 	: SET_LINE_PARAM_VALUE
--	Type		: Public
--	Function	: Update an existing parameter value for a given line.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_line_item_id:	NUMBER	Required
--					The internal ID for a given order line
--				p_parameter_name:	VARCHAR2 	Required
--					The name of the order line parameter
--				p_parameter_value:	VARCHAR2 	Required
--					The value of the order line parameter
--				p_parameter_reference_value:	VARCHAR2 	Optional
--					The reference value of the order line parameter
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 PROCEDURE Set_LINE_PARAM_Value(
	p_line_item_id IN NUMBER,
	p_parameter_name IN VARCHAR2,
	p_parameter_value IN VARCHAR2,
	p_parameter_reference_value IN VARCHAR2 DEFAULT NULL);

-- Start of comments
--	API name 	: Get_FE_ConfigInfo
--	Type		: Public
--	Function	: Retrieve the configuration data for a given fulfillment element.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fe:	VARCHAR2	Required
--					The name of the fulfillment element
--	OUT		:	p_fe_id:			NUMBER
--					Internal ID for the FE.
--				p_fetype_id:		NUMBER
--					Internal id for the Fulfillment Element type
--				p_fetype:			VARCHAR2
--					Name of the Fulfillment Element TYPE.
--				p_fe_sw_generic:	VARCHAR2
--					The current software generic of the Fulfillment Element.
--				p_adapter_type:		VARCHAR2
--					The current adapter type of the Fulfillment Element.
--
--	Version	: Current version	11.5
--	Notes	:
--  Retrieve the configuration data
--  for a given fulfillment element
-- End of comments
 PROCEDURE Get_FE_ConfigInfo(
		p_fe IN VARCHAR2,
		p_fe_id   OUT NOCOPY NUMBER,
		p_fetype_id OUT NOCOPY NUMBER,
		p_fetype    OUT NOCOPY VARCHAR2,
		p_fe_sw_generic  OUT NOCOPY varchar2,
		p_adapter_type OUT NOCOPY varchar2 );

-- Start of comments
--	API name 	: Get_FE_ConfigInfo
--	Type		: Public
--	Function	: Retrieve the configuration data for a given fulfillment element.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_fe_id:	NUMBER	Required
--					Internal ID for the FE.
--	OUT		:	p_fe_name:			VARCHAR2
--					The name of the fulfillment element
--				p_fetype_id:		NUMBER
--					Internal id for the Fulfillment Element type
--				p_fetype:			VARCHAR2
--					Name of the Fulfillment Element TYPE.
--				p_fe_sw_generic:	VARCHAR2
--					The current software generic of the Fulfillment Element.
--				p_adapter_type:		VARCHAR2
--					The current adapter type of the Fulfillment Element.
--
--	Version	: Current version	11.5
--	Notes	:
--  Retrieve the configuration data
--  for a given fulfillment element
-- End of comments
 PROCEDURE Get_FE_ConfigInfo(
		p_fe_id IN NUMBER,
		p_fe_name   OUT NOCOPY VARCHAR2,
		p_fetype_id OUT NOCOPY NUMBER,
		p_fetype    OUT NOCOPY VARCHAR2,
		p_fe_sw_generic  OUT NOCOPY varchar2,
		p_adapter_type OUT NOCOPY varchar2 );


-- Start of comments
--	API name 	: Get_FE_AttributeVal
--	Type		: Group
--	Function	: Retrieve the FE Attribute value for a given fulfillment element.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  Retrieve the FE Attribute value
--  for a given fulfillment element
-- End of comments
 FUNCTION  Get_FE_AttributeVal(
		p_fe_name IN VARCHAR2,
		p_attribute_name IN VARCHAR2)
  return varchar2;

-- Start of comments
--	API name 	: Get_FE_AttributeVal
--	Type		: Group
--	Function	: Overload function.  Retrieve the FE Attribute value for a given fulfillment element.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  Retrieve the FE Attribute value
--  for a given fulfillment element
-- End of comments
 FUNCTION  Get_FE_AttributeVal(
		p_fe_id IN NUMBER,
		p_attribute_name IN VARCHAR2)
  return varchar2;

-- Start of comments
--	API name 	: Get_FE_AttributeVal_List
--	Type		: Group
--	Function	: Retrieve all the FE Attribute value for a given fulfillment element.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 FUNCTION  Get_FE_AttributeVal_List(
		  p_fe_name in varchar2)
   RETURN XDP_TYPES.ORDER_PARAMETER_LIST;


-- Start of comments
--	API name 	: Get_FE_AttributeVal_List
--	Type		: Group
--	Function	: Retrieve all the FE Attribute value for a given
--			  fulfillment element ID.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 FUNCTION  Get_FE_AttributeVal_List(
		  p_fe_id in number)
   RETURN XDP_TYPES.ORDER_PARAMETER_LIST;


 Procedure PreFetch_FeAttrList( p_fe_name in varchar2,
				p_attr_count OUT NOCOPY number);

 Procedure Fetch_FeAttrFromList(p_index in number,
				p_attr_name OUT NOCOPY varchar2,
				p_attr_value OUT NOCOPY varchar2);


-- Start of comments
--	API name 	: Get_FE_ConnectionProc
--	Type		: Group
--	Function	: Retrieve the connect/disconnect procedure name for a given fulfillment element.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 PROCEDURE  Get_FE_ConnectionProc(
		p_fe_name IN VARCHAR2,
		p_connect_proc_name OUT NOCOPY VARCHAR2,
		p_disconnect_proc_name OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_FE_ConnectionProc
--	Type		: Group
--	Function	: Overload Function. Get the connect/disconnect procedure name for a given fulfillment element.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--   Retrieve the FE connect/disconnect procedure name
--   for a given fulfillment element
-- End of comments
 PROCEDURE  Get_FE_ConnectionProc(
		p_fe_id IN NUMBER,
		p_connect_proc_name OUT NOCOPY VARCHAR2,
		p_disconnect_proc_name OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Is_fe_valid
--	Type		: Public
--	Function	: Check if a Fulfillment is valid as of today
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 Function Is_Fe_Valid(p_fe_name in varchar2) return BOOLEAN;

-- Start of comments
--	API name 	: Is_fe_valid
--	Type		: Public
--	Function	: Check if a Fulfillment is valid as of today
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
 Function Is_Fe_Valid(p_fe_id in number) return BOOLEAN;


-- Start of comments
--	API name 	: Get_Workitem_List
--	Type		: Public
--	Function	: Retrieve the list of the workitems SFM has executed for the given order.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
Function Get_Workitem_List(
	p_sdp_order_id NUMBER)
  return XDP_TYPES.WORKITEM_LIST;

-- Start of comments
--	API name 	: Get_FA_List
--	Type		: Public
--	Function	: Retrieve the list of the fulfillment actions SFM has executed for the given workitem.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
Function Get_FA_List(
	p_wi_instance_id NUMBER)
  return XDP_TYPES.FULFILLMENT_ACTION_LIST;

-- Start of comments
--	API name 	: Get_FA_AUDIT_TRAILS
--	Type		: Public
--	Function	: Get the list of commands wnd responses which have been sent and received by the given FA
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
Function Get_FA_AUDIT_TRAILS(
	p_fa_instance_id NUMBER)
  return XDP_TYPES.FA_COMMAND_AUDIT_TRAIL;

-- Start of comments
--	API name 	: Reset_Sync_Registration
--	Type		: Public
--	Function	: Reset a Synchronisation Request
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE Reset_Sync_Registration (
    pp_sync_label	IN  VARCHAR2
   ,po_error_code       OUT NOCOPY NUMBER
   ,po_error_msg	OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: RECALCULATE
--	Type		: Public
--	Function	: Recalculate timers
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE recalculate
  (
    p_reference_id  IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: RECALCULATE_ALL
--	Type		: Public
--	Function	: Recalculate all timers.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE recalculate_all
  (
    p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: GET_TIMER_STATUS
--	Type		: Public
--	Function	: Get timer status using reference_id and timer message code.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE get_timer_status
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_timer_id OUT NOCOPY NUMBER
    ,x_status OUT NOCOPY VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: UPDATE_TIMER_STATUS
--	Type		: Public
--	Function	: Update timer status using reference_id and timer_message_code.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE update_timer_status
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,p_status IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: REMOVE_TIMER
--	Type		: Public
--	Function	: Remove timer using reference_id and timer_message_code.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE remove_timer
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: RESTART
--	Type		: Public
--	Function	: Restart a timer using a reference_id and timer_message_code.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE restart
  (
    p_reference_id IN VARCHAR2
    ,p_timer_message_code IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: DEREGISTER
--	Type		: Public
--	Function	: Deregister timers for an order_id.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE deregister
  (
    p_order_id IN NUMBER
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
  );

-- Start of comments
--	API name 	: RESTART_ALL
--	Type		: Public
--	Function	: Restart all timers using reference_id.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE restart_all
  (
    p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2

  );

-- Start of comments
--	API name 	: START_RELATED_TIMERS
--	Type		: Public
--	Function	: Start timers related to a message.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
  PROCEDURE start_related_timers
  (
    p_message_code IN VARCHAR2
    ,p_reference_id IN VARCHAR2
    ,x_error_code OUT NOCOPY NUMBER
    ,x_error_message OUT NOCOPY VARCHAR2
    ,p_opp_reference_id IN VARCHAR2 DEFAULT NULL
    ,p_sender_name IN VARCHAR2 DEFAULT NULL
    ,p_recipient_name IN VARCHAR2 DEFAULT NULL
    ,p_order_id IN NUMBER DEFAULT NULL
    ,p_wi_instance_id IN NUMBER DEFAULT NULL
    ,p_fa_instance_id IN NUMBER DEFAULT NULL
  );

-- Start of Comment
--	API name 	: Set_Order_Reference
--	Type		: Group
--	Function	: API to set the order reference information.
--	Pre-reqs	: None.
--  Notes		:
--	API to set the order reference information such as order
-- reference name, order reference value, service provider
-- order number, and service provider user ID
-- End of Comment
 PROCEDURE Set_Order_Reference
 (
   p_order_id IN NUMBER,
   p_order_ref_name IN VARCHAR2,
   p_order_ref_value IN VARCHAR2,
   p_sp_order_number IN VARCHAR2 DEFAULT NULL,
   p_sp_user_id  IN NUMBER DEFAULT NULL,
   x_return_code OUT NOCOPY NUMBER,
   x_error_description OUT NOCOPY VARCHAR2
  );

-- Start of Comment
--	API name 	: XDP_SYNC_LINE_ITEM_PV
--	Type		: Group
--	Function	: API to change parameter values for line items according to their workitems
--	Parameters	:
--
--	IN			: p_line_item_id	line item id in XDP.
--	Pre-reqs	: None.
--  Notes		:
--
-- End of Comment
  PROCEDURE XDP_SYNC_LINE_ITEM_PV(
		p_line_item_id IN XDP_ORDER_LINE_ITEMS.LINE_ITEM_ID%TYPE,
		x_return_code OUT NOCOPY NUMBER,
   		x_error_description OUT NOCOPY VARCHAR2
  );


-- Start of Comment
--	API name 	: EvaluateWIParamsOnStart
--	Type		: Group
--	Function	: API to Evaluate all Workitem Parameters marked as
--			  "Upon Workitem Start"
--	Parameters	:
--
--	IN			: p_wi_instance_id	workitem instance id
--	Pre-reqs	: None.
--  Notes		:
--
-- End of Comment
  PROCEDURE EvaluateWIParamsOnStart(p_wi_instance_id in number);

END XDP_ENGINE;

 

/
