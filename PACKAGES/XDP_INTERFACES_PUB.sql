--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_PUB" AUTHID CURRENT_USER AS
/* $Header: XDPINPBS.pls 120.2 2006/04/07 03:34:41 dputhiye ship $ */
/*#
 * A public interface for Service Fulfillment Manager that is used to submit,
 * retrieve details or cancel Service Fulfillment Orders. Upstream systems
 * can provide an external order number and version which can be used to track the
 * corresponding SFM order created. The type definitions of the parameters to the
 * APIs can be found in the PL/SQL package XDP_TYPES.
 * @rep:scope	 	public
 * @rep:product		XDP
 * @rep:lifecycle	active
 * @rep:displayname	Service Fulfillment Order Processing
 * @rep:category	BUSINESS_ENTITY	XDP_SERVICE_ORDER
 * @rep:comment @see	XDP_TYPES#SERVICE_ORDER_HEADER
 * @rep:comment @see	XDP_TYPES#SERVICE_ORDER_PARAM_LIST
 * @rep:comment @see	XDP_TYPES#SERVICE_ORDER_LINE_LIST
 * @rep:comment @see	XDP_TYPES#SERVICE_LINE_PARAM_LIST
*/

-- Start of comments
--	API name 	: Process_Order
--	Type		: Public
--	Function	: This API is used for submitting a service order to SFM.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--				p_init_msg_list:	VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit:	   	VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--					When calling this API via a database link, this
--					parameter must be FND_API.G_FALSE
--				p_validation_level	NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_order_header:	XDP_TYPES.ORDER_HEADER Required
--					Order header information which requires the
--					following atrribute values to be supplied:
--					order_number:
--						The order identifier which is assigned by the
--						calling system
--					order_version:
--						The version of the order.  This attribute
--						can be NULL
--					provisioning_date:
--						The date this order is supposed to begin
--						fulfillment.  If the value is not supplied then
--						it will be default to the sysdate.
--					order_action:
--						The fulfillment action which can be applied
--						to all the lines in the order.  This attribute is
--						optional.
--					jeopardy_enabled_flag:
--						The flag indicates whether the jeopardy analysis
--						should be enabled for the order or not.  The user
--						can then use this flag combine with other order
--						information in the post process user hook package
--						to determine whether to start a jeopardy timer or
--						not.  This attribute is optional.
--				p_order_parameter: XDP_TYPES.ORDER_PARAMETER_LIST Required
--					The parameters that can be accessed by all
--					the order lines. The list can be empty.
--				p_order_line_list: XDP_TYPES.ORDER_LINE_LIST Required
--					The list of order line items which requires
--					the following attribute values to be supplied:
--					line_number:
--					The index number of the current line
--					line_item_name:
--					The name of the service item
--					version:
--					The version of the service item
--					action:
--					The fulfillment action of the current line.  If this
--					value is not supplied, SFM will default it to the order
--					action
--					provisioning_date:
--					The date this order line is scheduled to
--					be fulfilled.  If the value is not supplied SFM will
--					default it to order provisioning date.
--					provisioning_sequence:
--					SFM uses this attrribute to determine dependency between
--					order lines.  If the value is not supplied SFM will
--					assume there is not dependency for this line.
--				p_line_parameter_list:	XDP_TYPES.LINE_PARAM_LIST Required
--					The list of the parameters for each order line. The list
--					can be empty.  For every record in the list, the
--					following attribute values to be supplied:
--					line_number:
--					The line number of this parameter is associated with
--					parameter_name:
--					The name of the parameter
--					parameter_value:
--					The value of the parameter.  It can be null.
--					parameter_ref_value:
--					The reference value of the parameter. This
--					attribute is optional.
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The caller must examine this parameter value
--					after the call is completed.  If the value is
--					FND_API.G_RET_STS_SUCCESS, the caller routine
--					must do commit, otherwise, the caller routine
--					must do rollback.
--				x_msg_count:		NUMBER
--				x_msg_data:			VARCHAR2(2000)
--				x_sdp_Order_id:		NUMBER
--				The internal order ID which is assigned by SFM
--				when an order is successfully submitted to SFM
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to submit a
--		service order to SFM. If the customer wishes to perform order
--		dependency and jeopardy analysis, he or she can put the
--		business logic in the post process API under the customer
--		hook package which will be supported by SFM per CRM coding
--		standard.
--
-- End of comments
 PROCEDURE Process_Order(
	p_api_version 		IN 	   NUMBER,
	p_init_msg_list		IN 	   VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	   VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	   NUMBER := FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count	        OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
 	P_ORDER_HEADER 		IN         XDP_TYPES.ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN         XDP_TYPES.ORDER_PARAMETER_LIST,
 	P_ORDER_LINE_LIST 	IN         XDP_TYPES.ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN         XDP_TYPES.LINE_PARAM_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY NUMBER);

-- Start of comments
--	API name 	: Cancel_Order
--	Type		: Public
--	Function	: This API is used for canceling a service order
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--				p_init_msg_list:	VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit:	   	VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--					This API is an autonomous routine which
--					handles the database transaction independently.
--					The value of p_commit parameter will be ignored.
--				p_validation_level	NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_sdp_Order_id:		NUMBER Required
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM
--				p_caller_name:		VARCHAR2  Required
--					The name of the user who is calling this API
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The execution status of the API call.
--				x_msg_count:		NUMBER
--				x_msg_data:			VARCHAR2(2000)
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to cancel
--		a service order which was submitted to SFM previously.
--
-- End of comments

 PROCEDURE Cancel_Order(
	p_api_version 	IN 	NUMBER,
	p_init_msg_list	IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER :=
							FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_caller_name 		IN VARCHAR2 );

-- Start of comments
--	API name 	: Get_Order_Parameter_List
--	Type		: Public
--	Function	: This API is used for retrieve order parameter list
--	Pre-reqs	: XDP_ENGIN.PARAMETER_LIST
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--				p_sdp_Order_id:		NUMBER Required
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM
--				p_caller_name:		VARCHAR2  Required
--					The name of the user who is calling this API
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The execution status of the API call.
--				x_return_msg:			VARCHAR2(2000)
--					The execution comments of the API call
--				x_order_param_list:		XDP_ENGINE.PARAMETER_LIST;
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to retrieve order parameter list
--		for further used to acquire order parameter value.
--
-- End of comments

PROCEDURE Get_Order_Parameter_List(
	p_api_version 	IN 	NUMBER,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_RETURN_MSG		OUT NOCOPY VARCHAR2,
	x_ORDER_PARAM_LIST	OUT NOCOPY XDP_ENGINE.PARAMETER_LIST,
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_CALLER_NAME 		IN VARCHAR2 );

-- Start of comments
--	API name 	: Get_Order_Parameter_Value
--	Type		: Public
--	Function	: This API is used for retrieve order parameter value
--	Pre-reqs	:
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--				p_sdp_Order_id:		NUMBER Required
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM
--				p_order_param_name:		VARCHAR2  Required
--					The name of the order parameter whose value will be retrieved
--					by calling this API
--				p_caller_name:		VARCHAR2  Required
--					The name of the user who is calling this API
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The execution status of the API call.
--				x_return_msg:			VARCHAR2(2000)
--					The execution comments of the API call
--				x_order_param_value:		VARCHAR2;
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to retrieve order parameter value.
--
-- End of comments

PROCEDURE Get_Order_Parameter_Value(
	p_api_version 	IN 	NUMBER,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_RETURN_MSG		OUT NOCOPY VARCHAR2,
	x_ORDER_PARAM_VALUE	OUT NOCOPY VARCHAR2,
 	p_SDP_ORDER_ID 		IN NUMBER,
 	p_ORDER_PARAM_NAME	IN VARCHAR2,
	p_CALLER_NAME 		IN VARCHAR2 );

-- Start of comments
--	API name 	: Get_Line_Parameter_Value
--	Type		: Public
--	Function	: This API is used for retrieve order line item parameter value
--	Pre-reqs	:
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--				p_sdp_Order_id:		NUMBER Required
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM
--				p_Line_Number:		NUMBER Required
--					The line number supplied by upstream ordering system when
--					submiting an order
--				p_Line_param_name:		VARCHAR2  Required
--					The name of the order parameter whose value will be retrieved
--					by calling this API
--				p_caller_name:		VARCHAR2  Required
--					The name of the user who is calling this API
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The execution status of the API call.
--				x_return_msg:			VARCHAR2(2000)
--					The execution comments of the API call
--				x_Line_param_value:		VARCHAR2;
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to retrieve order line item parameter value.
--
-- End of comments

PROCEDURE Get_Line_Parameter_Value(
	p_api_version 	IN 	NUMBER,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_RETURN_MSG		OUT NOCOPY VARCHAR2,
	x_LINE_PARAM_VALUE	OUT NOCOPY VARCHAR2,
 	p_SDP_ORDER_ID 		IN NUMBER,
 	P_LINE_NUMBER 		IN NUMBER,
 	p_LINE_PARAM_NAME	IN VARCHAR2,
	p_CALLER_NAME 		IN VARCHAR2 );
--
-- Implementation for Open Interface
-- 06/07/2001

-- Start of comments
--	API name 	: Process_Order
--	Type	 	: Public
--	Function	: This API is used for submitting a service order to SFM.
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		: p_api_version:	NUMBER	Required
--
--			  p_init_msg_list:	VARCHAR2 	Optional
--			      Default = FND_API.G_FALSE
--
--			  p_commit:	   	VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--				When calling this API via a database link, this
--				parameter must be FND_API.G_FALSE
--
--			  p_validation_level	NUMBER	Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--
--			  p_order_header: XDP_TYPES.SERVICE_ORDER_HEADER Required
--				Order header information which requires the
--				following atrribute values to be supplied:
--
--			 	order_number:
--					The order identifier which is assigned by the
--					calling system
--
--				order_version:
--					The version of the order.  This attribute
--					can be NULL
--
--				provisioning_date:
--					The date this order is supposed to begin
--					fulfillment.  If the value is not supplied then
--					it will be default to the sysdate.
--
--				jeopardy_enabled_flag:
--					The flag indicates whether the jeopardy analysis
--					should be enabled for the order or not.  The user
--					can then use this flag combine with other order
--					information in the post process user hook package
--					to determine whether to start a jeopardy timer or
--					not.  This attribute is optional.
--
--				order_ref_name:
--					This field is used to identify the type of the source system
--					for this order. It should be only of the following value
--					For Sales Orders:
--						ORDER_REF_NAME = 'SALES'
--					For Service Requests:
--						ORDER_REF_NAME = 'SERVICE_REQUEST'
--                  		execution_mode
--                      		This field indicate the order should be fulfilled sycn or asynchnorosly
--                      		Valid values are 'SYNC' and 'ASYNC'
--
--				account_id/account_number:
--					For whom the order is submitted on behalf of.
--                      		one of these two fields must be specified
--                      		The account must exist in the TCA model.
--
--			p_order_param_list: XDP_TYPES.SERVICE_ORDER_PARAM_LIST Required
--				The parameters that can be accessed by all
--				the order lines. The list can be empty.
--			p_order_line_list: XDP_TYPES.SERVICE_ORDER_LINE_LIST Required
--				The list of order line items which requires
--				the following attribute values to be supplied:
--
--        			line_number:
--		    			The index number of the current line
--
--				line_source:
--				    	Source object name of the upstream application
--
--  				inventory_item_id:
--	    				The item id in Oracle product catalog
--		    		service_item_name:
--			    		The item name in Oracle product catalog or workitem name in SFM
--
--				version:
--					The version of the workitem item. Only applicable when
--					serive_item_name is a workitem
--  				action_code:
--	    				The fulfillment action of the current line.
--
--		    		fulfillment_date:
--			    		The date this order line is scheduled to
--				    	be fulfilled.  If the value is not supplied SFM will
--					default it to order fulfillment date.
--
--			    	fulfillment_sequence:
--				    	SFM uses this attrribute to determine dependency between
--				    	order lines.  If the value is not supplied SFM will
--				    	assume there is not dependency for this line.
--
--				organization_code/organization_id:
--					SFM uses these attrributes to determine organization id for the
--                      		item in the inventory system.
--
--				site_use_id:
--					SFM uses this attrribute to determine install to address for this item
--
--				ib_source:
--					SFM uses this attrribute to determine
--                      		Oracle Installed Base system to which SFM will
--                      		update product installation information for the customer
--
--				ib_source_id:
--					SFM uses this attrribute to determine
--                      		value that uniquely identifies a transaction line detail
--                      		in Oracle Installed Base or an item instance in
--                      		Oracle Installed Base
--
--                  		required_fulfillment_date:
--                   			The date customer requires for this item to be fulfilled
--
--                  		bundle_id:
--                   			If this line item is part of a bundle, this fields identify
--                      		the bundle it belongs to. Reserved.
--
--                  		bundle_sequence:
--                   			If this line item is part of a bundle, this fields identify
--                      		the sequence of this itme in the bundle,  Reserved.
--
--                  		priority:
--           		    		The priority of the line item to be fulfilled.
--
--                  		due_date:
--                      		The data the order should be fulfilled, otherwise, a
--                      		jeopardy event could be fired.
--
--		    		jeopardy_enabled_flag:
--					The flag indicates whether the jeopardy analysis
--					should be enabled for the order or not.  The user
--					can then use this flag combine with other order
--					information in the post process user hook package
--					to determine whether to start a jeopardy timer or
--					not.  This attribute is optional.
--
--                  		starting_number:
--                      		NP number range
--
--                  		ending_number:
--                      		NP number range
--
--                  		attribute 1-20:
--                      		Descriptive flexfields.
--
--				p_line_param_list:	XDP_TYPES.G_MISS_LINE_PARAM_LIST Required
--					The list of the parameters for each order line. The list
--					can be empty.  For every record in the list, the
--					following attribute values to be supplied:
--					line_number:
--						The line number of this parameter is associated with
--					parameter_name:
--						The name of the parameter
--					parameter_value:
--						The value of the parameter.  It can be null.
--					parameter_ref_value:
--						The reference value of the parameter. This
--						attribute is optional.
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The caller must examine this parameter value
--					after the call is completed.  If the value is
--					FND_API.G_RET_STS_SUCCESS, the caller routine
--					must do commit, otherwise, the caller routine
--					must do rollback.
--				x_msg_count:		NUMBER
--				x_msg_data:			VARCHAR2(2000)
--				x_order_id:		    NUMBER
--				The internal order ID which is assigned by SFM
--				when an order is successfully submitted to SFM
--              		x_error_code	    VARCHAR2
--              		The application error code that is specific to SFM
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream systems to submit a
--		service order to SFM. If the customer wishes to perform order
--		dependency and jeopardy analysis, he or she can put the
--		business logic in the post process API under the customer
--		hook package which will be supported by SFM per CRM coding
--		standard.
--
-- End of comments
/*#
* Submit a Service Fulfillment Order for processing. The order information is to be submitted as a set of
* SFM order structures, which include the order header, order parameters, order lines and order line parameters.
* An external order number and version can be specified in the order header. The internal order id is returned.
*
*	@param	 p_api_version		API version used to check call compatibility. Current version is '11.5'.
*	@param	 p_init_msg_list	Flag indicating whether internal message tables should be initialized.
*	@param	 p_commit		Flag indicating whether this API should commit the transaction, if the call is successful.
*	@param	 p_validation_level	The level of input validation required from the API.
*	@param	 x_return_status	Return status of API call.
*	@param	 x_msg_count		Count of stored processing messages.
*	@param	 x_msg_data		List of all stored processing messages.
*       @param   x_error_code           SFM-specific application error code returned.
*	@param	 p_order_header		Header-level value information for the service order.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_HEADER}
*	@param	 p_order_param_list	List of header-level parameters. Each parameter is a name-value pair.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_PARAM_LIST}
*	@param	 p_order_line_list	Line-level value information for the service order.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_LINE_LIST}
*	@param	 p_line_param_list	List of line-level parameters. Each parameter is a name-value pair.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_LINE_PARAM_LIST}
*	@param	 x_order_id		The SFM order id for the service order.
*	@return				The internal service fulfillment order id
* @rep:scope	 	public
* @rep:lifecycle	active
* @rep:displayname	Process Service Fulfillment Order
*/
PROCEDURE Process_Order(
    p_api_version 	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2	:= 	FND_API.G_FALSE,
    p_commit	        IN  VARCHAR2	:= 	FND_API.G_FALSE,
    p_validation_level  IN  NUMBER 	:= 	FND_API.G_VALID_LEVEL_FULL,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count	        OUT NOCOPY NUMBER,
    x_msg_data	        OUT NOCOPY VARCHAR2,
    x_error_code	OUT NOCOPY VARCHAR2,
    p_order_header 	IN  XDP_TYPES.SERVICE_ORDER_HEADER := XDP_TYPES.G_MISS_SERVICE_ORDER_HEADER,
    p_order_param_list  IN  XDP_TYPES.SERVICE_ORDER_PARAM_LIST := XDP_TYPES.G_MISS_ORDER_PARAM_LIST,
    p_order_line_list   IN  XDP_TYPES.SERVICE_ORDER_LINE_LIST	:= XDP_TYPES.G_MISS_SERVICE_ORDER_LINE_LIST,
    p_line_param_list   IN  XDP_TYPES.SERVICE_LINE_PARAM_LIST := XDP_TYPES.G_MISS_LINE_PARAM_LIST,
    x_order_id	        OUT NOCOPY NUMBER
);

-- Start of comments
--	API name 	: Cancel_Order
--	Type		: Public
--	Function	: This API is used for canceling a service order
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--
--				p_init_msg_list:	VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--
--				p_commit:	   	VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--					This API is an autonomous routine which
--					handles the database transaction independently.
--					The value of p_commit parameter will be ignored.
--
--				p_validation_level	NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--				p_order_id:		NUMBER requried if p_order_number is null
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM
--
--				p_order_number:	 VARCHAR2  requried if p_order_id is null
--                  			The order number given by the caller when the order is submitted.
--                  			This field with p_version will be used to identify which order
--                  			to cancel
--
--				p_order_version:		VARCHAR2 Required
--
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--					The execution status of the API call.
--				x_msg_count:		NUMBER
--				x_msg_data:			VARCHAR2(2000)
--              x_error_code	    VARCHAR2
--                  The application error code that is specific to SFM
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to cancel
--		a service order which was submitted to SFM previously.
--
-- End of comments
/*#
* Cancel a Service Fulfillment Order. A known external order number and version or a known SFM order id must be supplied.
* The given order number and version are references specified by the upstream ordering system while submitting a new service order.
* SFM order id is the internal order identifier for a service order in SFM.
*
*	@param	 p_api_version		API version used to check call compatibility. Current version is '11.5'.
*	@param	 p_init_msg_list	Flag indicating whether internal message tables should be initialized.
*	@param	 p_commit		This parameter is ignored. This API is an autonomous routine, which handles the database transaction independently.
*	@param	 p_validation_level	The level of input validation required from the API.
*	@param	 x_return_status	Return status of API call.
*	@param	 x_msg_count		Count of stored processing messages.
*	@param	 x_msg_data		List of all stored processing messages.
*	@param	 p_order_number		The external order number reference value.
*	@param	 p_order_version	The external order version reference value. This parameter is optional and is defaulted to '1'.
*	@param	 p_order_id		The SFM order id. This value is optional if p_order_number is specified.
*	@param	 x_error_code		SFM-specific error code returned in case of errors.
*	@param	 p_caller_name		The calling user/module. This parameter is optional.
* @rep:scope	 	public
* @rep:lifecycle	active
* @rep:displayname	Cancel Service Fulfillment Order
*/
PROCEDURE Cancel_Order(
    p_api_version 	IN         NUMBER	:= 	FND_API.G_MISS_NUM,
    p_init_msg_list	IN         VARCHAR2	:= 	FND_API.G_FALSE,
    p_commit	        IN         VARCHAR2	:= 	FND_API.G_FALSE,
    p_validation_level  IN         NUMBER 	:= 	FND_API.G_VALID_LEVEL_FULL,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count	        OUT NOCOPY NUMBER,
    x_msg_data	        OUT NOCOPY VARCHAR2,
    p_order_number  	IN         VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
    p_order_version	IN         VARCHAR2 	DEFAULT	'1',
    p_order_id 	        IN         NUMBER	:= 	FND_API.G_MISS_NUM,
    x_error_code	OUT NOCOPY VARCHAR2,
    p_caller_name       IN         VARCHAR2     DEFAULT	FND_API.G_MISS_CHAR
);

-- Start of comments
--	API name 	: Get_Order_Details
--	Type		: Public
--	Function	: This API is used for retrieving current information about
--                a service order
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--
--				p_init_msg_list:	VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--
--				p_commit:   	VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--					This API is an autonomous routine which
--					handles the database transaction independently.
--					The value of p_commit parameter will be ignored.
--
--				p_validation_level	NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL.
--
--				p_order_id:		NUMBER requried if p_order_number is null
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM.
--
--				p_order_number:	 VARCHAR2  requried if p_order_id is null
--                  The order number given by the caller when the order is submitted.
--                  This field with p_version will be used to identify which order
--                  to cancel.
--
--				p_order_version: VARCHAR2, Optional.
--
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--				    The execution status of the API call.
--
--				x_msg_count:		NUMBER
--
--				x_msg_data:			VARCHAR2(2000)
--
--              x_error_code	    VARCHAR2
--                  The application error code that is specific to SFM
--
--              x_order_header
--					Order header information which contains current information
--                  in SFM systme for the following atrributes:
--
--					order_number:
--						The order identifier which is assigned by the
--						calling system
--
--					order_version:
--						The version of the order.  This attribute
--						can be NULL
--
--					provisioning_date:
--						The date this order is supposed to begin
--						fulfillment.  If the value is not supplied then
--						it will be default to the sysdate.
--
--					jeopardy_enabled_flag:
--						The flag indicates whether the jeopardy analysis
--						should be enabled for the order or not.  The user
--						can then use this flag combine with other order
--						information in the post process user hook package
--						to determine whether to start a jeopardy timer or
--						not.  This attribute is optional.
--
--                  execution_mode
--                      This field indicate the order should be fulfilled sycn or asynchnorosly
--                      Valid values are 'SYNC' and 'ASYNC'
--
--					account_id/account_number:
--						For whom the order is submitted on behalf of.
--                      one of these two fields must be specified
--                      The account must exist in the TCA model.
--                  order_status
--                      Current SFM order status
--
--                  fulfillment_status
--                      Current value of order parameter "Fulfillemnt Status"
--
--                  fulfillment_result
--                      Current value of order parameter "Fulfillemnt Result"
--
--                  actual_fulfillment_date
--                      The date when the fulfillment process was started for this order
--
--                  completiont_date
--                      The date when this order is fulfilled
--
--              x_order_param_list
--                  The list of name value pair for this order. Values are the most updated ones
--
--              x_line_item_list
--                  The table of line items of this order. Each record contains updated information
--                  about this line item. For more details about field of this record, please refer
--                  to the definition of record Service_Line_Item.
--
--              x_line_param_list
--                  The list of name value pair for line items of this order. Values are the most updated ones
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used for upstream ordering system to cancel
--		a service order which was submitted to SFM previously.
--
-- End of comments
/*#
* Retrieve order header, lines and other information from a Service Fulfillment Order. An external order number and version or a known SFM order id must be supplied.
* The given order number and version are references specified by the upstream ordering system while submitting a new service order. SFM order id is the
* internally assigned order identifier for a service order in SFM.
*	@param	 p_api_version		API version used to check call compatibility. Current version is '11.5'.
*	@param	 p_init_msg_list	Flag indicating whether internal message tables should be initialized.
*	@param	 p_commit		This parameter is optional and is ignored.
*	@param	 p_validation_level	The level of input validation required from the API.
*	@param	 x_return_status	Return status of API call.
*	@param	 x_msg_count		Count of stored processing messages.
*	@param	 x_msg_data		List of all stored processing messages.
*	@param	 x_error_code		SFM-specific error code returned in case of errors.
*	@param	 p_order_number		The external order number reference value.
*	@param	 p_order_version	The external order version reference value. This parameter is optional and is defaulted to '1'.
*	@param	 p_order_id		The SFM order id. This value is optional if p_order_number is specified.
*	@param	 x_order_header		Header-level value information retrieved from the service order.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_HEADER}
*	@param	 x_order_param_list	List of header-level parameters retrieved from the service order. Each parameter is a name-value pair.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_PARAM_LIST}
*	@param	 x_line_item_list	Line-level value information retrieved from the service order.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_LINE_LIST}
*	@param	 x_line_param_list	List of line-level parameters retrieved from the service order. Each record is a name-value pair.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_LINE_PARAM_LIST}
*       @return		Header-level value information, List of header-level parameters, Line-level value information and List of line-level parameters
* @rep:scope	 	public
* @rep:lifecycle	active
* @rep:displayname	Get Service Fulfillment Order Details
*/
PROCEDURE Get_Order_Details(
    p_api_version 	IN  NUMBER	,
    p_init_msg_list	IN  VARCHAR2	DEFAULT 	FND_API.G_FALSE,
    p_commit		IN  VARCHAR2	DEFAULT	FND_API.G_FALSE,
    p_validation_level	IN  NUMBER 	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    x_error_code	OUT NOCOPY VARCHAR2,
    p_order_number  	IN  VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
    p_order_version	IN  VARCHAR2 	DEFAULT	'1',
    p_order_id 		IN  NUMBER		DEFAULT	FND_API.G_MISS_NUM,
    x_order_header	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
    x_order_param_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    x_line_item_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    x_line_param_list	OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST
);

-- Start of comments
--	API name 	: Get_Order_Status
--	Type		: Public
--	Function	: This API is used for retrieving status of
--                a service order
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_api_version:	NUMBER	Required
--
--				p_init_msg_list:	VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--
--				p_commit:   	VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--					This API is an autonomous routine which
--					handles the database transaction independently.
--					The value of p_commit parameter will be ignored.
--
--				p_validation_level	NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL.
--
--				p_order_id:		NUMBER requried if p_order_number is null
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM.
--
--				p_order_number:	 VARCHAR2  requried if p_order_id is null
--                  The order number given by the caller when the order is submitted.
--                  This field with p_version will be used to identify which order
--                  to cancel.
--
--				p_order_version: VARCHAR2, Optional.
--
--
--	OUT		:	x_return_status:	VARCHAR2(1) Required
--				    The execution status of the API call.
--
--				x_msg_count:		NUMBER
--
--				x_msg_data:			VARCHAR2(2000)
--
--              x_error_code	    VARCHAR2
--                  The application error code that is specific to SFM
--
--              x_order_status      SERVICE_ORDER_STATUS
--                  Record that holds order status information which contains the
--                  following fields
--
--  				order_id:		NUMBER
--					The internal order ID which was assigned by SFM
--					when an order was successfully submitted to SFM.
--
--				    order_number:	VARCHAR2
--                  The order number given by the caller when the order is submitted.
--                  This field with p_version will be used to identify which order
--                  to cancel.
--
--				    order_version:  VARCHAR2

--                  order_status
--                      Current SFM order status
--
--                  fulfillment_status
--                      Current value of order parameter "Fulfillemnt Status"
--
--                  fulfillment_result
--                      Current value of order parameter "Fulfillemnt Result"
--
--                  actual_fulfillment_date
--                      The date when the fulfillment process was started for this order
--
--                  completion_date
--                      The date when this order is fulfilled
--
-- End of comments
/*#
* Retrieve the fulfillment status of a Service Fulfillment Order. An external order number and version or a known SFM order id must be supplied.
* The given order number and version are references specified by the upstream ordering system while submitting a new service order. SFM order id is the
* internally assigned order identifier for a service order in SFM.
*	@param	 p_api_version		API version used to check call compatibility. Current version is '11.5'.
*	@param	 p_init_msg_list	Flag indicating whether internal message tables should be initialized.
*	@param	 p_commit		This parameter is optional and is ignored.
*	@param	 p_validation_level	The level of input validation required from the API.
*	@param	 x_return_status	Return status of API call.
*	@param	 x_msg_count		Count of stored processing messages.
*	@param	 x_msg_data		List of all stored processing messages.
*	@param	 x_error_code		SFM-specific error code returned in case of errors.
*	@param	 p_order_number		The external order number reference value.
*	@param	 p_order_version	The external order version reference value. This parameter is optional and is defaulted to '1'.
*	@param	 p_order_id		The SFM order id. This value is optional if p_order_number is specified.
*	@param	 x_order_status		Status information record for the service order.
*       @paraminfo      {@rep:innertype XDP_TYPES.SERVICE_ORDER_STATUS}
* @return		Processing status record for the service order
* @rep:scope	 	public
* @rep:lifecycle	active
* @rep:displayname	Get Service Fulfillment Order Status
*/
PROCEDURE Get_Order_Status(
    p_api_version 	IN  NUMBER,
    p_init_msg_list	IN  VARCHAR2	DEFAULT 	FND_API.G_FALSE,
    p_commit		IN  VARCHAR2	DEFAULT 	FND_API.G_FALSE,
    p_validation_level	IN  NUMBER 	DEFAULT 	FND_API.G_VALID_LEVEL_FULL,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count		OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2,
    x_error_code	OUT NOCOPY VARCHAR2,
    p_order_number  	IN  VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
    p_order_version	IN  VARCHAR2 	DEFAULT	'1',
    p_order_id 		IN  NUMBER	DEFAULT	FND_API.G_MISS_NUM,
    x_order_status	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS
);

END XDP_INTERFACES_PUB;

 

/
