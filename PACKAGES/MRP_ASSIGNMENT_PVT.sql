--------------------------------------------------------
--  DDL for Package MRP_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ASSIGNMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: MRPVASNS.pls 115.2 99/07/16 12:41:14 porting ship $ */

--  Start of Comments
--  API name    Process_Assignment
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

PROCEDURE Process_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type :=
                                        MRP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_tbl                IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_TBL
,   p_old_Assignment_tbl            IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_TBL
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT MRP_Src_Assignment_PUB.Assignment_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Assignment
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

PROCEDURE Lock_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_tbl                IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_TBL
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT MRP_Src_Assignment_PUB.Assignment_Tbl_Type
);

--  Start of Comments
--  API name    Get_Assignment
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

PROCEDURE Get_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_Assignment_Set_Id             IN  NUMBER
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT MRP_Src_Assignment_PUB.Assignment_Tbl_Type
);

END MRP_Assignment_PVT;

 

/
