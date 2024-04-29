--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_UTILS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKEPDUTS.pls 120.0 2005/05/25 17:52:22 appldev noship $ */

--
--  Name          : MDS_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether certain
--   		    Action has been executed
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION MDS_Initiated_Yn ( P_Action_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : WSH_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether shipping
--   		    Action has been executed
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION WSH_Initiated_Yn ( P_Action_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : REQ_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether procure
--   		    Action has been executed
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION REQ_Initiated_Yn ( P_Action_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : Item_Defined_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    has been defined for the action
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Defined_Yn ( P_Deliverable_ID 	NUMBER ) RETURN VARCHAR2;


--
--  Name          : Item_Exist_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    has been created for the deliverable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	PA Deliverable Version ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Exist_Yn ( P_Deliverable_ID 	NUMBER ) RETURN VARCHAR2;

--
--  Name          : Ready_To_Ship_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether ready_to_ship
--   		    has been checked for the action
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Ready_To_Ship_Yn ( P_Action_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : Ready_To_Procure_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether ready_to_procure
--   		    has been checked for the action
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Ready_To_Procure_Yn ( P_Action_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : Item_Shippable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    is shippable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	Deliverable ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Shippable_Yn ( P_Deliverable_ID NUMBER ) RETURN VARCHAR2;


--
--  Name          : Item_Billable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    is billable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	Deliverable ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Billable_Yn ( P_Deliverable_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : Item_Purchasable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether item
--   		    is purchasable
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID  	Deliverable ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Item_Purchasable_Yn ( P_Deliverable_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : Action_Deletable_Yn
--  Pre-reqs      : N/A
--  Function      : This function returns result to indicate whether action
--   		    is deletable
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--

FUNCTION Action_Deletable_Yn ( P_Action_ID NUMBER ) RETURN VARCHAR2;

--
--  Name          : Copy_Item
--  Pre-reqs      : N/A
--  Function      : This procedure copies item info between deliverables
--
--
--  Parameters    :
--  IN            : SOURCE_PROJECT_ID
--  IN		  : TARGET_PROJECT_ID
--  IN		  : SOURCE_DELIVERABLE_ID
--  IN		  : TARGET_DELIVERABLE_ID
--  IN		  : TARGET_DELIVERABLE_NUMBER
--  IN 		  : P_COPY_ITEM_DETAILS_FLAG
--  OUT           : X_RETURN_STATUS
--  OUT 	  : X_MSG_COUNT
--  OUT		  : X_MSG_DATA
--
--  Returns       : N/A
--
PROCEDURE Copy_Item ( P_Source_Project_ID 	NUMBER
		, P_Target_Project_ID		NUMBER
		, P_Source_Deliverable_ID	NUMBER
		, P_Target_Deliverable_ID	NUMBER
		, P_Target_Deliverable_Number	VARCHAR2
		, P_Copy_Item_Details_Flag 	VARCHAR2
		, X_Return_Status	    OUT NOCOPY VARCHAR2
 		, X_Msg_Count		    OUT NOCOPY NUMBER
		, X_Msg_Data		    OUT NOCOPY VARCHAR2 );
--
--  Name          : Copy_Action
--  Pre-reqs      : N/A
--  Function      : This procedure copies action info between deliverables
--
--
--  Parameters    :
--  IN            : SOURCE_PROJECT_ID
--  IN		  : TARGET_PROJECT_ID
--  IN		  : SOURCE_DELIVERABLE_ID
--  IN		  : TARGET_DELIVERABLE_ID
--  IN		  : SOURCE_ACTION_ID
--  IN 		  : TARGET_ACTION_ID
--  IN		  : TARGET_ACTION_NAME
--  OUT           : X_RETURN_STATUS
--  OUT 	  : X_MSG_COUNT
--  OUT		  : X_MSG_DATA
--
--  Returns       : N/A
--
PROCEDURE Copy_Action ( P_Source_Project_ID 	NUMBER
		, P_Target_Project_ID		NUMBER
		, P_Source_Deliverable_ID	NUMBER
		, P_Target_Deliverable_ID	NUMBER
		, P_Source_Action_ID		NUMBER
		, P_Target_Action_ID		NUMBER
		, P_Target_Action_Name		VARCHAR2
		, P_Target_Action_Date		DATE
		, X_Return_Status	    OUT NOCOPY VARCHAR2
		, X_Msg_Count		    OUT NOCOPY NUMBER
		, X_Msg_Data		    OUT NOCOPY VARCHAR2);

FUNCTION Unit_Price ( P_Item_ID NUMBER, P_Org_ID NUMBER )
RETURN NUMBER;


FUNCTION Currency_Code ( P_Item_ID NUMBER, P_Org_ID NUMBER )
RETURN VARCHAR2;

--
--  Name          : Delete_Deliverable
--  Pre-reqs      : N/A
--  Function      : This procedure delete deliverable based on id
--
--
--  Parameters    :
--  IN            : P_DELIVERABLE_ID
--  OUT           : X_RETURN_STATUS
--  OUT 	  : X_MSG_COUNT
--  OUT		  : X_MSG_DATA
--
--  Returns       : N/A
--

PROCEDURE Delete_Deliverable ( P_Deliverable_ID NUMBER
			, X_Return_Status	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 );


--
--  Name          : Delete_Action
--  Pre-reqs      : N/A
--  Function      : This procedure delete action based on action_id
--
--
--  Parameters    :
--  IN            : P_ACTION_ID - PA_ACTION_ID
--  OUT           : X_RETURN_STATUS
--  OUT 	  : X_MSG_COUNT
--  OUT		  : X_MSG_DATA
--
--  Returns       : N/A
--

PROCEDURE Delete_Action ( P_Action_ID 		NUMBER
			, X_Return_Status	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 );


--
--  Name          : Delete_Demand
--  Pre-reqs      : N/A
--  Function      : This procedure delete Demand for shipping
--                  action based on action_id (not Pa_Action_Id)
--                  if it was initiated
--  Parameters    :
--  IN            : P_ACTION_ID - OKE Action_ID for Shipping action
--  OUT           : X_RETURN_STATUS
--  OUT 	  : X_MSG_COUNT
--  OUT		  : X_MSG_DATA
--
--  Returns       : N/A
--

PROCEDURE Delete_Demand ( P_Action_ID 		NUMBER
			, X_Return_Status	OUT NOCOPY VARCHAR2
			, X_Msg_Count		OUT NOCOPY NUMBER
			, X_Msg_Data		OUT NOCOPY VARCHAR2 );

--
--  Name          : WSH_Initiated_Yn
--  Pre-reqs      : N/A
--  Function      : Batch initiate demand for deliverables not initiated
--   		    demand.
--                  If no project specified, batch all eligible, else
--		    batch within the project. If task is specified for the
-- 		    project, batch within the task.
--
--
--  Parameters    :
--  IN            : P_Action_ID  	Deliverable action ID
--  OUT           : None
--
--  Returns       : VARCHAR2
--
PROCEDURE Batch_MDS ( P_Project_ID NUMBER
		, P_Task_ID NUMBER
		, P_Init_Msg_List VARCHAR2
		, X_Return_Status OUT NOCOPY VARCHAR2
		, X_Msg_Count OUT NOCOPY NUMBER
		, X_Msg_Data OUT NOCOPY VARCHAR2 );

--
--  Name          : Batch_Wsh
--  Pre-reqs      : N/A
--  Function      : Batch initiate requisition for deliverables not initiated
--   		    shipmentt.
--                  If no project specified, batch all eligible, else
--		    batch within the project. If task is specified for the
--                  project, batch within the task
--
--
--  Parameters    :
--  IN            :
--  OUT           :
--
--  Returns       :
--
PROCEDURE Batch_WSH ( P_Project_ID NUMBER
		, P_Task_ID NUMBER
		, P_Init_Msg_List VARCHAR2
		, X_Return_Status OUT NOCOPY VARCHAR2
		, X_Msg_Count OUT NOCOPY NUMBER
		, X_Msg_Data OUT NOCOPY VARCHAR2 );

--
--  Name          : Batch_Req
--  Pre-reqs      : N/A
--  Function      : Batch initiate requisition for new deliverables and those
--   		    had initiated requisition previously but failed in req
--                  import. If no project specified, batch all eligible, else
--		    batch within the project. If task is specified, batch
--		    within the task
--
--  Parameters    :
--  IN            :
--
--  OUT           :
--
--  Returns       : VARCHAR2
--
PROCEDURE Batch_REQ ( P_Project_ID NUMBER
		, P_Task_ID NUMBER
		, P_Init_Msg_List VARCHAR2
		, X_Return_Status OUT NOCOPY VARCHAR2
		, X_Msg_Count OUT NOCOPY NUMBER
		, X_Msg_Data OUT NOCOPY VARCHAR2 );

--
--  Name          : Default_Action
--  Pre-reqs      : N/A
--  Function      : Default dummy actions when source actions
--		    are defaulted
--
--  Parameters    :
--  IN            : P_Source_Code  'PA' for Projects
-- 		  : P_Action_Type  'REQ' for Requisition
--				   'WSH' for Shipping
--				   'MDS' for Demand
--		  : P_Source_Action_Name
-- 		  : P_Source_Deliverable_ID
-- 		  : P_Source_Action_ID
--
--  OUT           :
--
--  Returns       : VARCHAR2
--
PROCEDURE Default_Action ( P_Source_Code VARCHAR2
		, P_Action_Type VARCHAR2
		, P_Source_Action_Name VARCHAR2
		, P_Source_Deliverable_ID NUMBER
		, P_Source_Action_ID NUMBER
		, P_Action_Date	DATE );

FUNCTION Task_Used_In_Wsh ( P_Task_ID NUMBER ) RETURN VARCHAR2;

FUNCTION Task_Used_In_Req ( P_Task_ID NUMBER ) RETURN VARCHAR2;


END;

 

/
