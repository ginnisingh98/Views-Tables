--------------------------------------------------------
--  DDL for Package QP_ATTRIBUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ATTRIBUTES_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPATRS.pls 120.2 2005/08/03 07:37:43 srashmi noship $ */

--  Con record type

TYPE Con_Rec_Type IS RECORD
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
,   prc_context_code           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   prc_context_id                NUMBER         := FND_API.G_MISS_NUM
,   prc_context_type              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   seeded_description            VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   seeded_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   seeded_prc_context_name       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   user_description              VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   user_prc_context_name         VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Con_Tbl_Type IS TABLE OF Con_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Con value record type

TYPE Con_Val_Rec_Type IS RECORD
(   enabled                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   prc_context                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   seeded                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Con_Val_Tbl_Type IS TABLE OF Con_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Seg record type

TYPE Seg_Rec_Type IS RECORD
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
,   availability_in_basic         VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   prc_context_id                NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   seeded_flag                   VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   seeded_format_type            VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   seeded_precedence             NUMBER         := FND_API.G_MISS_NUM
,   seeded_segment_name           VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   seeded_description		  VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   seeded_valueset_id            NUMBER         := FND_API.G_MISS_NUM
,   segment_code               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   segment_id                    NUMBER         := FND_API.G_MISS_NUM
-- Added application_id by : Abhijit
,   application_id                NUMBER         := FND_API.G_MISS_NUM
,   segment_mapping_column        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   user_format_type              VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   user_precedence               NUMBER         := FND_API.G_MISS_NUM
,   user_segment_name             VARCHAR2(80)   := FND_API.G_MISS_CHAR
,   user_description	 	  VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   user_valueset_id              NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   required_flag		  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   party_hierarchy_enabled_flag       VARCHAR2(1)    := FND_API.G_MISS_CHAR -- Added for TCA
);

TYPE Seg_Tbl_Type IS TABLE OF Seg_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Seg value record type

TYPE Seg_Val_Rec_Type IS RECORD
(   prc_context                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   seeded                        VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   seeded_valueset               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   segment                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   user_valueset                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Seg_Val_Tbl_Type IS TABLE OF Seg_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_CON_REC                Con_Rec_Type;
G_MISS_CON_VAL_REC            Con_Val_Rec_Type;
G_MISS_CON_TBL                Con_Tbl_Type;
G_MISS_CON_VAL_TBL            Con_Val_Tbl_Type;
G_MISS_SEG_REC                Seg_Rec_Type;
G_MISS_SEG_VAL_REC            Seg_Val_Rec_Type;
G_MISS_SEG_TBL                Seg_Tbl_Type;
G_MISS_SEG_VAL_TBL            Seg_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Attributes
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

PROCEDURE Process_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  Con_Rec_Type :=
                                        G_MISS_CON_REC
,   p_CON_val_rec                   IN  Con_Val_Rec_Type :=
                                        G_MISS_CON_VAL_REC
,   p_SEG_tbl                       IN  Seg_Tbl_Type :=
                                        G_MISS_SEG_TBL
,   p_SEG_val_tbl                   IN  Seg_Val_Tbl_Type :=
                                        G_MISS_SEG_VAL_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Attributes
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

PROCEDURE Lock_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  Con_Rec_Type :=
                                        G_MISS_CON_REC
,   p_CON_val_rec                   IN  Con_Val_Rec_Type :=
                                        G_MISS_CON_VAL_REC
,   p_SEG_tbl                       IN  Seg_Tbl_Type :=
                                        G_MISS_SEG_TBL
,   p_SEG_val_tbl                   IN  Seg_Val_Tbl_Type :=
                                        G_MISS_SEG_VAL_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Attributes
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

PROCEDURE Get_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_prc_context_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_prc_context                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
);

END QP_Attributes_PUB;

 

/
