--------------------------------------------------------
--  DDL for Package MRP_SOURCING_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_SOURCING_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: MRPVSRLS.pls 115.1 99/07/16 12:41:45 porting ship $ */

--  Start of Comments
--  API name    Process_Sourcing_Rule
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type :=
                                        MRP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_old_Sourcing_Rule_rec         IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_Receiving_Org_tbl             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_TBL
,   p_old_Receiving_Org_tbl         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_TBL
,   p_Shipping_Org_tbl              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_TBL
,   p_old_Shipping_Org_tbl          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_TBL
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Sourcing_Rule
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_Receiving_Org_tbl             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_TBL
,   p_Shipping_Org_tbl              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_TBL
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
);

--  Start of Comments
--  API name    Get_Sourcing_Rule
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Sourcing_Rule_Id              IN  NUMBER
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
);

END MRP_Sourcing_Rule_PVT;

 

/
