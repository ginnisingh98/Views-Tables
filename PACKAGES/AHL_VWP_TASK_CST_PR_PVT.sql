--------------------------------------------------------
--  DDL for Package AHL_VWP_TASK_CST_PR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_TASK_CST_PR_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVTCPS.pls 115.4 2003/10/22 00:18:31 yazhou noship $ */
-----------------------------------------------------------
-- PACKAGE
--    Ahl_VWP_TASK_CST_PR_PVT
--
-- PURPOSE
--    This package is a Private API to process Estimating Cost and Price
--    for a Task It contains specification for pl/sql records and tables
--
--
-- NOTES
--
--
-- HISTORY
-- 25-AUG-2003    SSURAPAN      Created.
-----------------------------------------------------------
TYPE cost_price_rec_type IS RECORD (
        Visit_task_id               NUMBER,
        Visit_id                    NUMBER,
        Mr_id                       NUMBER,
        Actual_cost                 NUMBER,
        Estimated_cost              NUMBER,
        Actual_price                NUMBER,
        Estimated_price             NUMBER,
        Currency                    VARCHAR2(80), --15,
        Snapshot_Id                 NUMBER,
        Object_version_number       NUMBER,
        Estimated_Profit            NUMBER,
        Actual_Profit               NUMBER,
        Outside_party_flag          VARCHAR2(1),
        Is_outside_pty_flag_updt    VARCHAR2(1),
        Is_Cst_Pr_Info_Required     VARCHAR2(1),
        Is_Cst_Struc_updated        VARCHAR2(1),
        Price_list_Id               NUMBER,
        Price_List_Name             VARCHAR2(80), --240
        Service_Request_Id          NUMBER,
        Customer_Id                 NUMBER,
        Organization_Id             NUMBER,
        Visit_Start_Date            DATE,
        Visit_End_Date              DATE,
        MR_Start_Date               DATE,
        MR_End_Date                 DATE,
        Task_Start_Date             DATE,
        Task_End_Date               DATE,
        Task_Name                   VARCHAR2(80),
        MR_Title                    VARCHAR2(80),
        MR_Description              VARCHAR2(2000),
        Billing_Item_Id             NUMBER,
        Item_Name                   VARCHAR2(400),
        Organization_name           VARCHAR2(240),
        Workorder_Id                NUMBER,
        Master_WO_Flag              VARCHAR2(1),
        MR_Session_Id               NUMBER,
        Cost_Session_Id             NUMBER,
        CREATED_BY                  NUMBER,
        CREATION_DATE               DATE,
        LAST_UPDATED_BY             NUMBER,
        LAST_UPDATE_DATE            DATE,
        LAST_UPDATE_LOGIN           NUMBER,
        ATTRIBUTE_CATEGORY          VARCHAR2(30),
        ATTRIBUTE1                  VARCHAR2(150),
        ATTRIBUTE2                  VARCHAR2(150),
        ATTRIBUTE3                  VARCHAR2(150),
        ATTRIBUTE4                  VARCHAR2(150),
        ATTRIBUTE5                  VARCHAR2(150),
        ATTRIBUTE6                  VARCHAR2(150),
        ATTRIBUTE7                  VARCHAR2(150),
        ATTRIBUTE8                  VARCHAR2(150),
        ATTRIBUTE9                  VARCHAR2(150),
        ATTRIBUTE10                 VARCHAR2(150),
        ATTRIBUTE11                 VARCHAR2(150),
        ATTRIBUTE12                 VARCHAR2(150),
        ATTRIBUTE13                 VARCHAR2(150),
        ATTRIBUTE14                 VARCHAR2(150),
        ATTRIBUTE15                 VARCHAR2(150)
        );

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Get_Task_Cost_Details
--  Type              : Private(Called from Estimate and cost/price Task details UI)
--
--  Function          :
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Get Task Cost Details Parameters:
--       p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type,
--         Contains Cost/Price infor mation relates to Vist and its Task
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_Task_Cost_Details (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  );

-- Start of Comments --
--  Procedure name    : Estimate_Task_Cost
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          : To get task estimated cost and actual cost
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Estimate Task Cost Parameters:
--       p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type,
--         Contains Cost/Price infor mation relates to Vist and its Task
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Estimate_Task_Cost (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  );
-- Start of Comments --
--  Procedure name    : Estimate_Task_Price
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          :To get Task Estimated Price and Actual Price
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Estimate Task Price Parameters:
--       p_x_cost_price_rec     IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_Price_Rec_Type,
--         Contains Cost/Price infor mation relates to Vist and its Task
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Estimate_Task_Price (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  );

-- Start of Comments --
--  Procedure name    : Update Task Cost Details
--  Type              : Private(Called from Estimate and cost/price Task UI
--
--  Function          : To update task price list
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create Material Request Parameters:
--       p_cost_price_rec              IN      Cost_price_rec_type,     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Update_Task_Cost_Details (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN            VARCHAR2  := NULL,
    p_cost_price_rec         IN    AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2
  );

-- Start of Comments --
--  Procedure name    : Get Node   Cost Details
--  Type              : Private called from Cost Structure Page to show the Page Context for the Task
--
--  Function          : To show the details of Estimated and the Actual Cost of the Task
--
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN      VARCHAR2     Default 'JSP'
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Get_Node_Cost_Details Parameters:
--       p_cost_price_rec              IN      Cost_price_rec_type,     Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.




PROCEDURE Get_Node_Cost_Details (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN             VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_x_cost_price_rec       IN OUT NOCOPY AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type
  );

--  GET_TASK_ITEMS_NO_PRICE Parameters:
--  Refer  for more details \\Industry1-nt\telecom\Advanced Services Online\300 DLD\11.5.10\VWP\Costing_DLD_Part2_V1.8.doc
--
--

PROCEDURE GET_TASK_ITEMS_NO_PRICE (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_module_type            IN             VARCHAR2  := NULL,
    x_return_status             OUT NOCOPY        VARCHAR2,
    x_msg_count                 OUT NOCOPY        NUMBER,
    x_msg_data                  OUT NOCOPY        VARCHAR2,
    p_cost_price_rec         IN             AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_cost_price_tbl         OUT    NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_tbl_type
  );

END AHL_VWP_TASK_CST_PR_PVT;

 

/
