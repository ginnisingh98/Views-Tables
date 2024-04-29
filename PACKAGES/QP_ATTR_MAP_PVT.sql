--------------------------------------------------------
--  DDL for Package QP_ATTR_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ATTR_MAP_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVMAPS.pls 120.3 2005/08/18 15:47:36 sfiresto ship $ */

--  Start of Comments
--  API name    Process_Attr_Mapping
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

PROCEDURE Process_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_RQT_tbl                       IN  QP_Attr_Map_PUB.Rqt_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_TBL
,   p_old_RQT_tbl                   IN  QP_Attr_Map_PUB.Rqt_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_TBL
,   p_SSC_tbl                       IN  QP_Attr_Map_PUB.Ssc_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_TBL
,   p_old_SSC_tbl                   IN  QP_Attr_Map_PUB.Ssc_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_TBL
,   p_PSG_tbl                       IN  QP_Attr_Map_PUB.Psg_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_TBL
,   p_old_PSG_tbl                   IN  QP_Attr_Map_PUB.Psg_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_TBL
,   p_SOU_tbl                       IN  QP_Attr_Map_PUB.Sou_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_TBL
,   p_old_SOU_tbl                   IN  QP_Attr_Map_PUB.Sou_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_TBL
,   p_FNA_tbl                       IN  QP_Attr_Map_PUB.Fna_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_TBL
,   p_old_FNA_tbl                   IN  QP_Attr_Map_PUB.Fna_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Attr_Mapping
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

PROCEDURE Lock_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_RQT_tbl                       IN  QP_Attr_Map_PUB.Rqt_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_TBL
,   p_SSC_tbl                       IN  QP_Attr_Map_PUB.Ssc_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_TBL
,   p_PSG_tbl                       IN  QP_Attr_Map_PUB.Psg_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_TBL
,   p_SOU_tbl                       IN  QP_Attr_Map_PUB.Sou_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_TBL
,   p_FNA_tbl                       IN  QP_Attr_Map_PUB.Fna_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
);

--  Start of Comments
--  API name    Get_Attr_Mapping
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

PROCEDURE Get_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lookup_code                   IN  VARCHAR2
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
);

--  Start of Comments
--  API name    Check_Enabled_Fnas
--  Type        Private
--  Function  Executes Delayed Request to check for enabled functional areas
--            within the updated PTE/SS combinations.  If there are any PTE/SS
--            combinations that have no enabled fnareas, it adds warning
--            messages to the stack.
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

PROCEDURE Check_Enabled_Fnas
( x_msg_data       OUT NOCOPY VARCHAR2
, x_msg_count      OUT NOCOPY NUMBER
, x_return_status  OUT NOCOPY VARCHAR2);

END QP_Attr_Map_PVT;

 

/
