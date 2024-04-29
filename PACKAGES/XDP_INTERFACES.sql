--------------------------------------------------------
--  DDL for Package XDP_INTERFACES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES" AUTHID CURRENT_USER AS
/* $Header: XDPINTFS.pls 120.1 2005/06/08 23:54:30 appldev  $ */


-- Start of comments
--	API name 	: Process_Order
--	Type		: Private
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_header:	XDP_TYPES.ORDER_HEADER Required
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
--	OUT		:	sdp_order_id:	NUMBER
--					The internal order ID which is assigned by SFM
--					which an order is successfully submitted to SFM
--				return_code:  NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--					The caller must examine this parameter value
--					after the call is completed.  If the value is
--					0, the caller routine must do commit, otherwise,
--					the caller routine must do rollback.
--				error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--
--	Version	: Current version	11.5
--	Notes	:
--		This API is used as an internal API to submit a
--		service order to SFM.
--
-- End of comments
 PROCEDURE Process_Order(
 	P_ORDER_HEADER 		IN  XDP_TYPES.ORDER_HEADER,
 	P_ORDER_PARAMETER 	IN  XDP_TYPES.ORDER_PARAMETER_LIST,
 	P_ORDER_LINE_LIST 	IN  XDP_TYPES.ORDER_LINE_LIST,
 	P_LINE_PARAMETER_LIST 	IN  XDP_TYPES.LINE_PARAM_LIST,
	SDP_ORDER_ID		   OUT NOCOPY NUMBER,
 	RETURN_CODE 		IN OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	IN OUT NOCOPY VARCHAR2);
--
-- This is a backward compatibility implementation of
-- DRC orders. It is called by
-- XDP_DRC_UTIL_PUB.Process_DRC_ORDER
-- This will eventually be phased out
--
PROCEDURE Process_DRC_Order(
	p_workitem_id  IN NUMBER,
	p_task_parameter IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_order_id OUT NOCOPY NUMBER,
	x_return_code OUT NOCOPY NUMBER,
	x_error_description OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Cancel_Order
--	Type		: Private
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_sdp_order_id:	NUMBER 	Required
--					The order ID of the service order tobe cancelled
--				p_caller_name VARCHAR2	Required
--					The name of the CSR who cancel the order
--	OUT		:	return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		This API is used as an internal API to submit a
--		request to SFM for cancelling an order.
--
-- End of comments
 PROCEDURE Cancel_Order(
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_caller_name 		IN VARCHAR2 default user,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Cancel_Order
--	Type		: Private
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_number:	Varchar2 	Required
--					The external order number of the service
--					order to be cancelled
--				p_order_version VARCHAR2	Optional
--					The external order version of the service
--					order to be cancelled
--				p_caller_name VARCHAR2	Required
--					The name of the CSR who cancel the order
--	OUT		:	return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		Overload Function. This API is used as an internal API
--		to submit a request to SFM for cancelling an order.
--
-- End of comments
 PROCEDURE Cancel_Order(
 	P_ORDER_NUMBER 		IN VARCHAR2,
	p_order_version		IN VARCHAR2,
	p_caller_name 		IN VARCHAR2 default user,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_Order_Status
--	Type		: Group
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_sdp_order_id:	Number 	Required
--					The internal order ID which is assigned
--					by SFM upon order arrival
--	OUT		:	p_order_header 	XDP_TYPES.ORDER_HEADER
--					The order header record which contains
--					up to date order general information,
--					such as order status, state, etc..
--				P_Order_lines  	XDP_TYPES.ORDER_LINE_LIST
--					The list of order line record which contains
--					up to date general order line information for
--					all the lines in the order
--				return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		This API is used as a group API
--		to get the up to date information for a given order
--
-- End of comments
 PROCEDURE Get_Order_Status(
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_order_header		OUT NOCOPY XDP_TYPES.ORDER_HEADER,
	P_Order_lines		OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
 	RETURN_CODE 		OUT NOCOPY NUMBER,
 	ERROR_DESCRIPTION 	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_Order_Status
--	Type		: Group
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_sdp_order_id:	Number 	Required
--					The internal order ID which is assigned
--					by SFM upon order arrival
--	OUT		:	x_status	VARCHAR2
--					The current staus of the order
--				x_state	VARCHAR2
--					The current fulfillment state of the order
--				x_completion_date	DATE
--					The date when the order is completed
--				x_cancellation_date	DATE
--					The date when the order is canceled
--				x_return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				x_error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		Overload Function. A light-weight API for upstream
--		ordering system to retrieve only the key order status
--		information.
--
-- End of comments
 PROCEDURE Get_Order_Status(
 	P_SDP_ORDER_ID 		IN NUMBER,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_Order_Status
--	Type		: Group
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_number:		VARCHAR2 	Required
--					The order number which is assigned to
--					the order by the calling system
--				p_order_version:	VARCHAR2 	Optional
--					The order version which is assigned to
--					the order by the calling system, if any
--	OUT		:	x_status	VARCHAR2
--					The current staus of the order
--				x_state	VARCHAR2
--					The current fulfillment state of the order
--				x_completion_date	DATE
--					The date when the order is completed
--				x_cancellation_date	DATE
--					The date when the order is canceled
--				x_return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				x_error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		Overload Function. A light-weight API for upstream
--		ordering system to retrieve only the key order status
--		information.
--
-- End of comments
 PROCEDURE Get_Order_Status(
 	P_ORDER_NUMBER 		IN  VARCHAR2,
 	P_ORDER_VERSION		IN  VARCHAR2,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_Line_Status
--	Type		: Group
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_sdp_order_id:	Number 	Required
--					The internal order ID which is assigned
--					by SFM upon order arrival
--				p_line_number:	Number	Required
--					The line number of the order line to be
--					searched
--	OUT		:	x_status	VARCHAR2
--					The current staus of the order line
--				x_state	VARCHAR2
--					The current fulfillment state of the order line
--				x_completion_date	DATE
--					The date when the order line is completed
--				x_cancellation_date	DATE
--					The date when the order line is canceled
--				x_return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				x_error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		Overload Function. A light-weight API for upstream
--		ordering system to retrieve only the key line status
--		information.
--
-- End of comments
 PROCEDURE Get_Line_Status(
 	P_SDP_ORDER_ID 		IN NUMBER,
	p_line_number       IN NUMBER,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_Line_Status
--	Type		: Group
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_number:		VARCHAR2 	Required
--					The order number which is assigned to
--					the order by the calling system
--				p_order_version:	VARCHAR2 	Optional
--					The order version which is assigned to
--					the order by the calling system, if any
--				p_line_number:	Number	Required
--					The line number of the order line to be
--					searched
--	OUT		:	x_status	VARCHAR2
--					The current staus of the order line
--				x_state	VARCHAR2
--					The current fulfillment state of the order line
--				x_completion_date	DATE
--					The date when the order line is completed
--				x_cancellation_date	DATE
--					The date when the order line is canceled
--				x_return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				x_error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		Overload Function. A light-weight API for upstream
--		ordering system to retrieve only the key line status
--		information.
--
-- End of comments
 PROCEDURE Get_Line_Status(
 	P_ORDER_NUMBER 		IN  VARCHAR2,
 	P_ORDER_VERSION		IN  VARCHAR2,
	p_line_number       IN NUMBER,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: Get_Line_Status
--	Type		: Group
--	Function	:
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:	p_order_number:		VARCHAR2 	Required
--					The order number which is assigned to
--					the order by the calling system
--				p_order_version:	VARCHAR2 	Optional
--					The order version which is assigned to
--					the order by the calling system, if any
--				p_line_item_name:	VARCHAR2	Required
--					The service name of the order line to be
--					searched
--	OUT		:	x_status	VARCHAR2
--					The current staus of the order line
--				x_state	VARCHAR2
--					The current fulfillment state of the order line
--				x_completion_date	DATE
--					The date when the order line is completed
--				x_cancellation_date	DATE
--					The date when the order line is canceled
--				x_return_code:  	NUMBER
--					This output argument is to indicate if the API
--					call is made sucessfully.  The value of 0 means
--					the call is made sucessfully, while any non-zero
--					value means otherwise.
--				x_error_description:  VARCHAR2
--					The decription of the error encountered
--					when the return_code is not 0.
--	Version	: Current version	11.5
--	Notes	:
--		Overload Function. A light-weight API for upstream
--		ordering system to retrieve only the key line status
--		information.
--		This API will return error if more than one order line
--		have the same line item name
--
-- End of comments
 PROCEDURE Get_Line_Status(
 	P_ORDER_NUMBER 		IN  VARCHAR2,
 	P_ORDER_VERSION		IN  VARCHAR2,
	p_line_item_name    IN  VARCHAR2,
 	x_status 			OUT NOCOPY VARCHAR2,
        x_state                 OUT NOCOPY VARCHAR2,
 	x_completion_date	OUT NOCOPY DATE,
 	x_cancellation_date	OUT NOCOPY DATE,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2);

--
-- The following APIs are developed as part of integration with Oracle Sales for Comms.
-- 12/06/2000
-- By Anping Wang
--

--//
--//	API name 	: GET_ORD_FULFILLMENT_STATUS
--//	Type		: Group
--//	Function	:
--//	Pre-reqs	: None.
--//	Parameters	:
--//
--//	IN		:	p_order_id:		NUMBER 	Required
--//					The order id is SFM order id returned when process_order is called.
--//					The calling procedure should use this id
--//	OUT		:	x_fulfillment_status	VARCHAR2
--//					The current fulfillment status of the order in upper case
--//				x_fulfillment_result	VARCHAR2
--//					The current fulfillment status of the order
--//				x_return_code:  	NUMBER
--//					This output argument is to indicate if the API
--//					call is made sucessfully.  The value of 0 means
--//					the call is made sucessfully, while any non-zero
--//					value means otherwise.
--//				x_error_description:  VARCHAR2
--//					The decription of the error encountered
--//					when the return_code is not 0.
--//	Version	: Current version	11.5
--//	Notes	:
--//		Overload Function. A light-weight API for upstream
--//		ordering system to retrieve only the order fulfillment status
--//
--// End of comments
 PROCEDURE Get_Ord_Fulfillment_Status(
 	p_order_id		 		IN  VARCHAR2,
 	x_fulfillment_status	OUT NOCOPY VARCHAR2,
 	x_fulfillment_result	OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
 );

--//	API name 	: Get_Order_Param_Value
--//	Type		: Group
--//	Function	:
--//	Pre-reqs	: None.
--//	Parameters	:
--//
--//	IN		:	p_order_id:		NUMBER 	Required
--//					The order id is SFM order id returned when process_order is called.
--//					The calling procedure should use this id
--//				p_parameter_name:	VARCHAR2 	Optional
--//					The order version which is assigned to
--//					the order by the calling system, if any
--//	OUT		:	x_parameter_value	VARCHAR2
--//					The current fulfillment status of the order
--//				x_return_code:  	NUMBER
--//					This output argument is to indicate if the API
--//					call is made sucessfully.  The value of 0 means
--//					the call is made sucessfully, while any non-zero
--//					value means otherwise.
--//				x_error_description:  VARCHAR2
--//					The decription of the error encountered
--//					when the return_code is not 0.
--//	Version	: Current version	11.5
--//
--// End of comments
 PROCEDURE Get_Order_Param_Value(
 	p_order_id	 		IN  NUMBER,
	p_parameter_name		IN VARCHAR2,
	x_parameter_value		OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 			OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION		OUT NOCOPY VARCHAR2
);

--//	API name 	: Get_Order_Param_List
--//	Type		: Group
--//	Function	:
--//	Pre-reqs	: None.
--//	Parameters	:
--//
--//	IN		:	p_order_id:		NUMBER 	Required
--//					The order id is SFM order id returned when process_order is called.
--//					The calling procedure should use this id
--//	OUT		:	x_return_code:  	NUMBER
--//					This output argument is to indicate if the API
--//					call is made sucessfully.  The value of 0 means
--//					the call is made sucessfully, while any non-zero
--//					value means otherwise.
--//				x_error_description:  VARCHAR2
--//					The decription of the error encountered
--//					when the return_code is not 0.
--//	Version	: Current version	11.5
--//
--// End of comments

FUNCTION Get_Order_Param_List(
 	p_order_id		 		IN  NUMBER,
 	x_RETURN_CODE 			OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION		OUT NOCOPY VARCHAR2
) RETURN XDP_ENGINE.PARAMETER_LIST;

--//	API name 	: Get_Line_Param_Value
--//	Type		: Group
--//	Function	:
--//	Pre-reqs	: None.
--//	Parameters	:
--//
--//	IN		:	p_order_id:		NUMBER 	Required
--//					The order id is SFM order id returned when process_order is called.
--//					The calling procedure should use this id
--//				p_order_line_number:	VARCHAR2 	Required
--//					The order line number is the value passed to SFM by the calling application
--//					which is assigned to the order line item by the calling system
--//				p_parameter_name:	VARCHAR2 	Optional
--//					The order version which is assigned to
--//					the order by the calling system, if any
--//	OUT		:	x_parameter_value	VARCHAR2
--//					The current fulfillment status of the order
--//				x_return_code:  	NUMBER
--//					This output argument is to indicate if the API
--//					call is made sucessfully.  The value of 0 means
--//					the call is made sucessfully, while any non-zero
--//					value means otherwise.
--//				x_error_description:  VARCHAR2
--//					The decription of the error encountered
--//					when the return_code is not 0.
--//	Version	: Current version	11.5
--//
--// End of comments
PROCEDURE Get_Line_Param_Value(
 	p_order_id		 		IN  NUMBER,
	p_line_number			IN  VARCHAR2,
	p_parameter_name		IN VARCHAR2,
	x_parameter_value		OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 			OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION		OUT NOCOPY VARCHAR2
);

--//	API name 	: Set_Ord_Fulfillment_Status
--//	Type		: Group
--//	Function	:
--//	Pre-reqs	: None.
--//	Parameters	:
--//
--//	IN		:	p_order_id:		NUMBER 	Required
--//					The order id is SFM order id returned when process_order is called.
--//					The calling procedure should use this id
--//				p_fulfillment_status	VARCHAR2
--//					The current fulfillment status of the order
--//				p_fulfillment_result	VARCHAR2
--//					The current fulfillment status of the order
--//	OUT		:	x_return_code:  	NUMBER
--//					This output argument is to indicate if the API
--//					call is made sucessfully.  The value of 0 means
--//					the call is made sucessfully, while any non-zero
--//					value means otherwise.
--//				x_error_description:  VARCHAR2
--//					The decription of the error encountered
--//					when the return_code is not 0.
--//	Version	: Current version	11.5
--//
--// End of comments
PROCEDURE Set_Ord_Fulfillment_Status(
	p_order_id	IN	NUMBER,
	p_fulfillment_status	IN	VARCHAR2 DEFAULT NULL,
	p_fulfillment_result	IN	VARCHAR2 DEFAULT NULL,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
);

--
-- Following procedures are the new private APIs for order information
-- They are called by the public APIs.
--

-- This is the internal API for get order status. It is used
-- by public API to retrieve order status information.
-- Data is stored in x_order_status

Procedure Get_Order_Status(
        p_order_id 		    IN  NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        p_order_number  	IN  VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
        p_order_version	  	IN  VARCHAR2 	DEFAULT	'1',
        x_order_status      OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS,
 	    x_return_code 		OUT NOCOPY NUMBER,
 	    x_error_description	OUT NOCOPY VARCHAR2);

-- This is the internal API for get order details. It is used
-- by public API to retrieve order status information.
-- Data is stored in four data structures as defined in XDP_TYPES

Procedure Get_Order_Details(
        p_order_id 		    IN  NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        p_order_number  	IN  VARCHAR2	DEFAULT	FND_API.G_MISS_CHAR,
        p_order_version	  	IN  VARCHAR2 	DEFAULT	'1',
        x_order_header		OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
        x_order_param_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
        x_line_item_list	OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
        x_line_param_list	OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
 	    x_return_code 		OUT NOCOPY NUMBER,
 	    x_error_description	OUT NOCOPY VARCHAR2);

PROCEDURE Set_Line_Fulfillment_Status(
	p_line_item_id   	IN	NUMBER,
	p_fulfillment_status	IN	VARCHAR2 DEFAULT NULL,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
);

PROCEDURE Set_Line_Fulfillment_Status(
	p_order_id   	IN	NUMBER,
        p_line_number   IN      NUMBER,
	p_fulfillment_status	IN	VARCHAR2 DEFAULT NULL,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Line_Fulfillment_Status(
 	p_line_item_id		IN  NUMBER,
 	x_fulfillment_status	OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
 );

PROCEDURE Get_Line_Fulfillment_Status(
 	p_order_id		IN  NUMBER,
        p_line_number           IN  NUMBER,
 	x_fulfillment_status	OUT NOCOPY VARCHAR2,
 	x_RETURN_CODE 		OUT NOCOPY NUMBER,
 	x_ERROR_DESCRIPTION	OUT NOCOPY VARCHAR2
 );

END XDP_INTERFACES;

 

/
