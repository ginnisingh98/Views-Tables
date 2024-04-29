--------------------------------------------------------
--  DDL for Package OKE_COMM_ACT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_COMM_ACT_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEACTUS.pls 115.6 2003/10/13 05:27:16 yliou ship $ */


--
--  Name          : Update_Text
--  Pre-reqs      : None
--  Function      : This procedure updates communication text
--
PROCEDURE Update_Text(
             X_k_header_id                NUMBER,
             X_communication_num          VARCHAR2,
             X_text                       VARCHAR2
);


--
--  Name          : Action_Workflow
--  Pre-reqs      : None
--  Function      : This procedure launch the workflow when
--                  a communication was created
--                  or the communication action was changed
--
PROCEDURE Action_Workflow
( P_K_Header_ID        IN  NUMBER
, P_K_Line_ID          IN  NUMBER
, P_Deliverable_ID     IN  NUMBER
, P_Communication_Num  IN  VARCHAR2
, P_Type_Name          IN  VARCHAR2
, P_Reason_Name        IN  VARCHAR2
, P_Party_Name         IN  VARCHAR2
, P_Party_Location     IN  VARCHAR2
, P_Party_Role         IN  VARCHAR2
, P_Party_Contact      IN  VARCHAR2
, P_New_Action_Code    IN  VARCHAR2
, P_Owner              IN  NUMBER
, P_Priority_Name      IN  VARCHAR2
, P_Communication_Date IN  DATE
, P_Communication_Text IN  VARCHAR2
, P_Updated_By         IN  NUMBER
, P_Update_Date        IN  DATE
, P_Login_ID           IN  NUMBER
, P_WF_ITEM_KEY        OUT NOCOPY VARCHAR2
);


--
--  Name          : Status_Change
--  Pre-reqs      : None
--  Function      : This procedure performs utility functions when
--                  a communication applied.
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : None
--

PROCEDURE Comm_Action
( P_K_Header_ID        IN  NUMBER
, P_K_Line_ID          IN  NUMBER
, P_Deliverable_ID     IN  NUMBER
, P_Communication_Num  IN  VARCHAR2
, P_Type               IN  VARCHAR2
, P_Reason_Code        IN  VARCHAR2
, P_K_Party_ID         IN  NUMBER
, P_Party_Location     IN  VARCHAR2
, P_Party_Role         IN  VARCHAR2
, P_Party_Contact      IN  VARCHAR2
, P_New_Action_Code    IN  VARCHAR2
, P_Owner              IN  NUMBER
, P_Priority_Code      IN  VARCHAR2
, P_Communication_Date IN  DATE
, P_Communication_Text IN  VARCHAR2
, P_Updated_By         IN  NUMBER
, P_Update_Date        IN  DATE
, P_Login_ID           IN  NUMBER
, P_WF_ITEM_KEY        OUT NOCOPY VARCHAR2
);


END OKE_COMM_ACT_UTILS;

 

/
