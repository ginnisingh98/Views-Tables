--------------------------------------------------------
--  DDL for Package AHL_VWP_VISIT_CST_PR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_VISIT_CST_PR_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVVCPS.pls 115.1 2003/10/23 00:03:58 yazhou noship $ */
 ---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE cost_price_rec_type IS RECORD (
        Visit_task_id               NUMBER,
        Visit_id                    NUMBER,
        Mr_id                       NUMBER,
        Actual_cost                 NUMBER,
        Estimated_cost              NUMBER,
        Actual_price                NUMBER,
        Estimated_price             NUMBER,
        Currency                    VARCHAR2(80),
        Snapshot_Id                 NUMBER,
        Object_version_number       NUMBER,
        Estimated_Profit            NUMBER,
        Actual_Profit               NUMBER,
        Outside_party_flag          VARCHAR2(1),
        Is_outside_pty_flag_updt    VARCHAR2(1),
        Is_Cst_Pr_Info_Required     VARCHAR2(1),
        Is_Cst_Struc_updated        VARCHAR2(1),
        Price_list_Id               NUMBER,
        Price_List_Name             VARCHAR2(80),
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
        Visit_Task_Number           NUMBER,
        MR_Title                    VARCHAR2(80),
        MR_Description              VARCHAR2(2000),
        Billing_Item_Id             NUMBER,
        Item_Name                   VARCHAR2(400),
        Item_Description            VARCHAR2(240),
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


----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE cost_price_tbl_type IS TABLE OF cost_price_rec_type INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
-- Procedure to get visit cost details for a specific visit --
--------------------------------------------------------------------------
PROCEDURE get_visit_cost_details(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

--------------------------------------------------------------------------
-- Procedure to estimate visit cost for a specific visit --
--------------------------------------------------------------------------
PROCEDURE estimate_visit_cost(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

--------------------------------------------------------------------------
-- Procedure to estimate visit price for a specific visit --
--------------------------------------------------------------------------
PROCEDURE estimate_visit_price(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

--------------------------------------------------------------------------
-- Procedure to take a price snapshot for a specific visit --
--------------------------------------------------------------------------
PROCEDURE create_price_snapshot(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_visit_id              IN             NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

--------------------------------------------------------------------------
-- Procedure to take a cost snapshot for a specific visit --
--------------------------------------------------------------------------
PROCEDURE create_cost_snapshot(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

--------------------------------------------------------------------------
-- Procedure to get visit cost details for a specific visit --
--------------------------------------------------------------------------
PROCEDURE update_visit_cost_details(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := 'JSP',
    p_x_cost_price_rec      IN OUT NOCOPY  AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

PROCEDURE Get_Visit_Items_no_price
    (
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  :=NULL,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2,
    p_cost_price_rec        IN             AHL_VWP_VISIT_CST_PR_PVT.cost_price_rec_type,
    x_cost_price_tbl        OUT NOCOPY     Cost_Price_Tbl_Type
    );
--------------------------------------------------------------------------------
------- Check various conditions and release visit if needed
---------------------------------------------------------------------------------
PROCEDURE  check_for_release_visit
(
  p_visit_id                    IN  NUMBER,
  x_release_visit_required      OUT NOCOPY        VARCHAR2
);

END AHL_VWP_VISIT_CST_PR_PVT;

 

/
