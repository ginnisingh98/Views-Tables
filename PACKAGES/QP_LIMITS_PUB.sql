--------------------------------------------------------
--  DDL for Package QP_LIMITS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMITS_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPLMTS.pls 120.1 2005/06/13 00:32:16 appldev  $ */

--  Limits record type

TYPE Limits_Rec_Type IS RECORD
(   amount                        NUMBER         := FND_API.G_MISS_NUM
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
,   basis                         VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   limit_exceed_action_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   limit_hold_flag               VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   limit_id                      NUMBER         := FND_API.G_MISS_NUM
,   limit_level_code              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   limit_number                  NUMBER         := FND_API.G_MISS_NUM
,   list_header_id                NUMBER         := FND_API.G_MISS_NUM
,   list_line_id                  NUMBER         := FND_API.G_MISS_NUM
,   multival_attr1_type           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr1_context        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attribute1           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr1_datatype       VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   multival_attr2_type           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr2_context        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attribute2           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr2_datatype       VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   organization_flag             VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Limits_Tbl_Type IS TABLE OF Limits_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Limits value record type

TYPE Limits_Val_Rec_Type IS RECORD
(   limit_exceed_action           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   limit                         VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   limit_level                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_header                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   list_line                     VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   organization                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Limits_Val_Tbl_Type IS TABLE OF Limits_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Limit_Attrs record type

TYPE Limit_Attrs_Rec_Type IS RECORD
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
,   comparison_operator_code      VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   limit_attribute               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   limit_attribute_context       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   limit_attribute_id            NUMBER         := FND_API.G_MISS_NUM
,   limit_attribute_type          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   limit_attr_datatype           VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   limit_attr_value              VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   limit_id                      NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Limit_Attrs_Tbl_Type IS TABLE OF Limit_Attrs_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Limit_Attrs value record type

TYPE Limit_Attrs_Val_Rec_Type IS RECORD
(   comparison_operator           VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   limit_attribute               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   limit                         VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Limit_Attrs_Val_Tbl_Type IS TABLE OF Limit_Attrs_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Limit_Balances record type

TYPE Limit_Balances_Rec_Type IS RECORD
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
,   available_amount              NUMBER         := FND_API.G_MISS_NUM
,   consumed_amount               NUMBER         := FND_API.G_MISS_NUM
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   limit_balance_id              NUMBER         := FND_API.G_MISS_NUM
,   limit_id                      NUMBER         := FND_API.G_MISS_NUM
,   multival_attr1_type           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr1_context        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attribute1           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr1_value          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   multival_attr1_datatype       VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   multival_attr2_type           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr2_context        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attribute2           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   multival_attr2_value          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   multival_attr2_datatype       VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   organization_attr_context     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   organization_attribute        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   organization_attr_value       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   reserved_amount               NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Limit_Balances_Tbl_Type IS TABLE OF Limit_Balances_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Limit_Balances value record type

TYPE Limit_Balances_Val_Rec_Type IS RECORD
(   limit_balance                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   limit                         VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Limit_Balances_Val_Tbl_Type IS TABLE OF Limit_Balances_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_LIMITS_REC             Limits_Rec_Type;
G_MISS_LIMITS_VAL_REC         Limits_Val_Rec_Type;
G_MISS_LIMITS_TBL             Limits_Tbl_Type;
G_MISS_LIMITS_VAL_TBL         Limits_Val_Tbl_Type;
G_MISS_LIMIT_ATTRS_REC        Limit_Attrs_Rec_Type;
G_MISS_LIMIT_ATTRS_VAL_REC    Limit_Attrs_Val_Rec_Type;
G_MISS_LIMIT_ATTRS_TBL        Limit_Attrs_Tbl_Type;
G_MISS_LIMIT_ATTRS_VAL_TBL    Limit_Attrs_Val_Tbl_Type;
G_MISS_LIMIT_BALANCES_REC     Limit_Balances_Rec_Type;
G_MISS_LIMIT_BALANCES_VAL_REC Limit_Balances_Val_Rec_Type;
G_MISS_LIMIT_BALANCES_TBL     Limit_Balances_Tbl_Type;
G_MISS_LIMIT_BALANCES_VAL_TBL Limit_Balances_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Limits
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

PROCEDURE Process_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  Limits_Rec_Type :=
                                        G_MISS_LIMITS_REC
,   p_LIMITS_val_rec                IN  Limits_Val_Rec_Type :=
                                        G_MISS_LIMITS_VAL_REC
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_ATTRS_val_tbl           IN  Limit_Attrs_Val_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_VAL_TBL
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_TBL
,   p_LIMIT_BALANCES_val_tbl        IN  Limit_Balances_Val_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_VAL_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Limits
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

PROCEDURE Lock_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  Limits_Rec_Type :=
                                        G_MISS_LIMITS_REC
,   p_LIMITS_val_rec                IN  Limits_Val_Rec_Type :=
                                        G_MISS_LIMITS_VAL_REC
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_ATTRS_val_tbl           IN  Limit_Attrs_Val_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_VAL_TBL
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_TBL
,   p_LIMIT_BALANCES_val_tbl        IN  Limit_Balances_Val_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_VAL_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Limits
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

PROCEDURE Get_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_id                      IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_limit                         IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
);

END QP_Limits_PUB;

 

/
