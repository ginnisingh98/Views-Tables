--------------------------------------------------------
--  DDL for Package QP_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ATTRIBUTES_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVATRS.pls 120.1 2005/06/14 01:21:18 appldev  $ */

--  Start of Comments
--  API name    Process_Attributes
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

PROCEDURE Process_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_SEG_tbl                       IN  QP_Attributes_PUB.Seg_Tbl_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_TBL
,   p_old_SEG_tbl                   IN  QP_Attributes_PUB.Seg_Tbl_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Attributes
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

PROCEDURE Lock_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_SEG_tbl                       IN  QP_Attributes_PUB.Seg_Tbl_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
);

--  Start of Comments
--  API name    Get_Attributes
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

PROCEDURE Get_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_prc_context_id                IN  NUMBER
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
);

END QP_Attributes_PVT;

 

/
