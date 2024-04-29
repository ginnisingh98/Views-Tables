--------------------------------------------------------
--  DDL for Package XDP_DRC_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_DRC_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: XDPDRCUS.pls 120.2 2005/07/07 02:14:10 appldev ship $ */

-- Start of comments
--	API name 	: Process_DRC_Order
--	Type		: Public
--	Function	: API for processing a DRC order in a synchronous mode
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
-- 				P_WORKITEM_ID 		IN  NUMBER   Required
--					The internal ID of the work item to be executed
-- 				P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST
--					The list of parameters for the request
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--					The execution status of the API call.
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				x_sdp_Order_id		OUT NUMBER
--					The internal order ID which is assigned by SFM
--					when the request is fulfilled
--	Version	: Current version	11.5
--	Notes		:
--		This API is used for the test center to execute a work item synchronously.  The
--		process flow is as followed:
--		1) Check if the work item can be executed synchronously.  The condition is that
--		   the FA mapping type of the work item must be either STATIC or DYNAMIC. This
--		   API does not invoke any workflow.  It does not use any OP process queue
--		   either.
--		2)Create a dummy service order in SFM for tracking purpose only.  The internal order
--		  ID will be returned to the caller after the call is completed.
--		3)Find out all the FAs which have been mapped to this work item per configuration.
--		4)For each FA,  find out which FE it will be executed upon.
--		5)Find the available adapter for the given FE.  The usage code for the adapter must
--		  be TEST.
--		6)Execute the appropriate Fulfillment Procedure.
--		7)Return when all the FAs have been executed.
--
-- End of comments
 PROCEDURE Process_DRC_Order(
	p_api_version 	IN 	NUMBER,
	p_init_msg_list	IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER :=
							FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
 	P_WORKITEM_ID 		IN  NUMBER,
 	P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY NUMBER);

-- Start of comments
--	API name 	: Process_DRC_Order
--	Type		: Public
--	Function	: Wrapper on the above API with two extra out parameters
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
-- 				P_WORKITEM_ID 		IN  NUMBER   Required
--					The internal ID of the work item to be executed
-- 				P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST
--					The list of parameters for the request
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--					The execution status of the API call.
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				x_sdp_Order_id		OUT NUMBER
--					The internal order ID which is assigned by SFM
--					when the request is fulfilled
--				x_sdp_Fulfillment_Status		OUT VARCHAR2
--				x_sdp_Fulfillment_Status		OUT VARCHAR2
--	Version	: Current version	11.5
--	Notes		:
--		This API is used for the test center to execute a work item synchronously.  The
--		process flow is as followed:
--		1) Check if the work item can be executed synchronously.  The condition is that
--		   the FA mapping type of the work item must be either STATIC or DYNAMIC. This
--		   API does not invoke any workflow.  It does not use any OP process queue
--		   either.
--		2)Create a dummy service order in SFM for tracking purpose only.  The internal order
--		  ID will be returned to the caller after the call is completed.
--		3)Find out all the FAs which have been mapped to this work item per configuration.
--		4)For each FA,  find out which FE it will be executed upon.
--		5)Find the available adapter for the given FE.  The usage code for the adapter must
--		  be TEST.
--		6)Execute the appropriate Fulfillment Procedure.
--		7)Return when all the FAs have been executed.
--		8)Retreive fulfillment status
-- End of comments
 PROCEDURE Process_DRC_Order(
	p_api_version 	IN 	NUMBER,
	p_init_msg_list	IN 	VARCHAR2 := FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN 	NUMBER :=
							FND_API.G_VALID_LEVEL_FULL,
 	x_RETURN_STATUS 	OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
 	P_WORKITEM_ID 		IN  NUMBER,
 	P_TASK_PARAMETER 	IN XDP_TYPES.ORDER_PARAMETER_LIST,
	x_SDP_ORDER_ID		OUT NOCOPY NUMBER,
	x_sdp_Fulfillment_Status	OUT NOCOPY VARCHAR2,
	x_sdp_Fulfillment_Result	OUT NOCOPY VARCHAR2);

END XDP_DRC_UTIL_PUB;

 

/
