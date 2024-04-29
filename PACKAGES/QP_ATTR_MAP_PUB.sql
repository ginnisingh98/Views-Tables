--------------------------------------------------------
--  DDL for Package QP_ATTR_MAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ATTR_MAP_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPMAPS.pls 120.2 2005/07/18 18:14:57 appldev ship $ */

--  Pte record type

TYPE Pte_Rec_Type IS RECORD
(   description                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   enabled_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   lookup_code                   VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   lookup_type                   VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   meaning                       VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Pte_Tbl_Type IS TABLE OF Pte_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Pte value record type

TYPE Pte_Val_Rec_Type IS RECORD
(   enabled                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   lookup                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Pte_Val_Tbl_Type IS TABLE OF Pte_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Rqt record type

TYPE Rqt_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   enabled_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   line_level_global_struct      VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   line_level_view_name          VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   order_level_global_struct     VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   order_level_view_name         VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   pte_code                      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   request_type_code             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   request_type_desc             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   row_id                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Rqt_Tbl_Type IS TABLE OF Rqt_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Rqt value record type

TYPE Rqt_Val_Rec_Type IS RECORD
(   enabled                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pte                           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   request_type                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   row                           VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Rqt_Val_Tbl_Type IS TABLE OF Rqt_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Ssc record type

TYPE Ssc_Rec_Type IS RECORD
(   application_short_name        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   enabled_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   pte_code                      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pte_source_system_id          NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Ssc_Tbl_Type IS TABLE OF Ssc_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Ssc value record type

TYPE Ssc_Val_Rec_Type IS RECORD
(   enabled                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pte                           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pte_source_system             VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Ssc_Val_Tbl_Type IS TABLE OF Ssc_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Psg record type

TYPE Psg_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   limits_enabled                VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   lov_enabled                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   pte_code                      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   seeded_sourcing_method        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   segment_id                    NUMBER         := FND_API.G_MISS_NUM
,   segment_level                 VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   segment_pte_id                NUMBER         := FND_API.G_MISS_NUM
,   sourcing_enabled              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   sourcing_status               VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   user_sourcing_method          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Psg_Tbl_Type IS TABLE OF Psg_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Psg value record type

TYPE Psg_Val_Rec_Type IS RECORD
(   pte                           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   segment                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   segment_pte                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Psg_Val_Tbl_Type IS TABLE OF Psg_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Sou record type

TYPE Sou_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute_sourcing_id         NUMBER         := FND_API.G_MISS_NUM
,   attribute_sourcing_level      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   application_id                NUMBER         := FND_API.G_MISS_NUM
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   enabled_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_type_code             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   seeded_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   seeded_sourcing_type          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   seeded_value_string           VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   segment_id                    NUMBER         := FND_API.G_MISS_NUM
,   user_sourcing_type            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   user_value_string             VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   PSG_index                     NUMBER         := FND_API.G_MISS_NUM
);

TYPE Sou_Tbl_Type IS TABLE OF Sou_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Sou value record type

TYPE Sou_Val_Rec_Type IS RECORD
(   attribute_sourcing            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   enabled                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   request_type                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   seeded                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   segment                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Sou_Val_Tbl_Type IS TABLE OF Sou_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Fna record type

TYPE Fna_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   enabled_flag                  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   functional_area_id            NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   pte_sourcesystem_fnarea_id    NUMBER         := FND_API.G_MISS_NUM
,   pte_source_system_id          NUMBER         := FND_API.G_MISS_NUM
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   seeded_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   SSC_index                     NUMBER         := FND_API.G_MISS_NUM
);

TYPE Fna_Tbl_Type IS TABLE OF Fna_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Fna value record type

TYPE Fna_Val_Rec_Type IS RECORD
(   enabled                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   functional_area               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pte_sourcesystem_fnarea       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   pte_source_system             VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   seeded                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Fna_Val_Tbl_Type IS TABLE OF Fna_Val_Rec_Type
    INDEX BY BINARY_INTEGER;


--  Variables representing missing records and tables

G_MISS_PTE_REC                Pte_Rec_Type;
G_MISS_PTE_VAL_REC            Pte_Val_Rec_Type;
G_MISS_PTE_TBL                Pte_Tbl_Type;
G_MISS_PTE_VAL_TBL            Pte_Val_Tbl_Type;
G_MISS_RQT_REC                Rqt_Rec_Type;
G_MISS_RQT_VAL_REC            Rqt_Val_Rec_Type;
G_MISS_RQT_TBL                Rqt_Tbl_Type;
G_MISS_RQT_VAL_TBL            Rqt_Val_Tbl_Type;
G_MISS_SSC_REC                Ssc_Rec_Type;
G_MISS_SSC_VAL_REC            Ssc_Val_Rec_Type;
G_MISS_SSC_TBL                Ssc_Tbl_Type;
G_MISS_SSC_VAL_TBL            Ssc_Val_Tbl_Type;
G_MISS_PSG_REC                Psg_Rec_Type;
G_MISS_PSG_VAL_REC            Psg_Val_Rec_Type;
G_MISS_PSG_TBL                Psg_Tbl_Type;
G_MISS_PSG_VAL_TBL            Psg_Val_Tbl_Type;
G_MISS_SOU_REC                Sou_Rec_Type;
G_MISS_SOU_VAL_REC            Sou_Val_Rec_Type;
G_MISS_SOU_TBL                Sou_Tbl_Type;
G_MISS_SOU_VAL_TBL            Sou_Val_Tbl_Type;
G_MISS_FNA_REC                Fna_Rec_Type;
G_MISS_FNA_VAL_REC            Fna_Val_Rec_Type;
G_MISS_FNA_TBL                Fna_Tbl_Type;
G_MISS_FNA_VAL_TBL            Fna_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Attr_Mapping
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
);

--  Start of Comments
--  API name    Process_Attr_Mapping (Overloaded)
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Attr_Mapping
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Attr_Mapping (Overloaded)
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  Pte_Rec_Type :=
                                        G_MISS_PTE_REC
,   p_PTE_val_rec                   IN  Pte_Val_Rec_Type :=
                                        G_MISS_PTE_VAL_REC
,   p_RQT_tbl                       IN  Rqt_Tbl_Type :=
                                        G_MISS_RQT_TBL
,   p_RQT_val_tbl                   IN  Rqt_Val_Tbl_Type :=
                                        G_MISS_RQT_VAL_TBL
,   p_SSC_tbl                       IN  Ssc_Tbl_Type :=
                                        G_MISS_SSC_TBL
,   p_SSC_val_tbl                   IN  Ssc_Val_Tbl_Type :=
                                        G_MISS_SSC_VAL_TBL
,   p_PSG_tbl                       IN  Psg_Tbl_Type :=
                                        G_MISS_PSG_TBL
,   p_PSG_val_tbl                   IN  Psg_Val_Tbl_Type :=
                                        G_MISS_PSG_VAL_TBL
,   p_SOU_tbl                       IN  Sou_Tbl_Type :=
                                        G_MISS_SOU_TBL
,   p_SOU_val_tbl                   IN  Sou_Val_Tbl_Type :=
                                        G_MISS_SOU_VAL_TBL
,   p_FNA_tbl                       IN  Fna_Tbl_Type :=
                                        G_MISS_FNA_TBL
,   p_FNA_val_tbl                   IN  Fna_Val_Tbl_Type :=
                                        G_MISS_FNA_VAL_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Attr_Mapping
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lookup_code                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_lookup                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ Fna_Tbl_Type
,   x_FNA_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Fna_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Attr_Mapping (Overloaded)
--  Type        Public
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
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lookup_code                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_lookup                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ Pte_Rec_Type
,   x_PTE_val_rec                   OUT NOCOPY /* file.sql.39 change */ Pte_Val_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ Rqt_Tbl_Type
,   x_RQT_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Rqt_Val_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ Ssc_Tbl_Type
,   x_SSC_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Ssc_Val_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ Psg_Tbl_Type
,   x_PSG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Psg_Val_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ Sou_Tbl_Type
,   x_SOU_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Sou_Val_Tbl_Type
);

END QP_Attr_Map_PUB;

 

/
