--------------------------------------------------------
--  DDL for Package XDP_NOTIFICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_NOTIFICATIONS" AUTHID CURRENT_USER AS
/* $Header: XDPNOTFS.pls 120.1 2005/06/09 00:19:44 appldev  $ */

-- Start of comments
--	API name 	: NotificationResponse
--	Type		: Private
--	Function	: Respond to a provisioning error with new set of data
--	Pre-reqs	: None.
--	Version	: Current version	11.5
--	Notes	:
--		  		This API is used by the notification form.
-- End of comments
 PROCEDURE NotificationResponse(
	p_response IN VARCHAR2,
	p_order_id in NUMBER,
 	P_workitem_instance_id IN NUMBER,
 	P_fa_instance_id IN NUMBER default null,
 	P_ORDER_RETRY_PARAMS IN OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
 	P_workitem_RETRY_PARAMS IN OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
 	P_FA_RETRY_PARAMS IN OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
 	p_workflow_Item_Type IN VARCHAR2 ,
	p_workflow_ItemKey   IN VARCHAR2 ,
	RETURN_CODE IN OUT NOCOPY NUMBER,
	ERROR_DESCRIPTION IN OUT NOCOPY VARCHAR2);

-- Start of comments
--	API name 	: NotificationResponse
--	Type		: Private
--	Function	: Get the latest service parameter changes for a work item
--	Pre-reqs	: None.
--	Version	: Current version	11.5
--	Notes	:
--
-- End of comments
Procedure Get_Latest_FMC_Changes(
	p_workitem_instance_id IN NUMBER,
	p_order_id  OUT NOCOPY NUMBER,
	p_service_name OUT NOCOPY VARCHAR2,
	p_service_version OUT NOCOPY VARCHAR2,
	p_action_code OUT NOCOPY VARCHAR2,
	p_workitem_name OUT NOCOPY VARCHAR2,
	p_fmc_response OUT NOCOPY VARCHAR2,
	p_order_param_change_list OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
	p_wi_param_change_list OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
	p_fa_param_change_list OUT NOCOPY XDP_TYPES.FMC_RETRY_PARAM_LIST,
    return_code OUT NOCOPY NUMBER,
    error_description OUT NOCOPY VARCHAR2);


-- Start of comments
--      API name        : WI_Response
--      Type            : Private
--      Function        : wrapper for OA 5.6 framework
--      Pre-reqs        : None.
--      Notes   :
--
-- End of comments

Procedure WI_Response(
        P_workitem_instance_id IN NUMBER,
        P_PARAMETER_NAME IN   VARCHAR2,
        P_PARAMETER_VALUE IN  VARCHAR2,
        P_PARAMETER_OLD_VALUE IN VARCHAR2,
        P_ORDER_ID IN VARCHAR2,
        P_ITEMTYPE IN VARCHAR2,
        P_ITEMKEY  IN VARCHAR2);

-- Start of comments
--      API name        : Get_WI_Update_URL
--      Type            : Private
--      Function        : Procedure to get URL for modifying WI params
--      Pre-reqs        : None.
--      Notes   :
--
-- End of comments
Procedure Get_WI_Update_URL(
        p_workitem_instance_id IN NUMBER,
        p_order_id             IN NUMBER,
        p_itemtype             IN VARCHAR2,
        p_itemkey              IN VARCHAR2,
        x_url                 OUT NOCOPY VARCHAR2);


END XDP_NOTIFICATIONS;

 

/
