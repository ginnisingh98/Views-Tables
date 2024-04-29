--------------------------------------------------------
--  DDL for Package AHL_MEL_CDL_ATA_SEQS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MEL_CDL_ATA_SEQS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVATAS.pls 120.2 2005/09/12 04:07 tamdas noship $ */

G_APP_NAME  CONSTANT    VARCHAR2(3)     := 'AHL';                           -- Use for all FND_MESSAGE.SET_NAME calls
G_PKG_NAME  CONSTANT    VARCHAR2(30)    := 'AHL_MEL_CDL_ATA_SEQS_PVT'; -- Use for all debug messages, FND_API.COMPATIBLE_API_CALL, etc

-------------------------------
-- Define records and tables --
-------------------------------
TYPE Ata_Sequence_Rec_Type IS RECORD
(
    MEL_CDL_ATA_SEQUENCE_ID     NUMBER,
    OBJECT_VERSION_NUMBER       NUMBER,
    MEL_CDL_HEADER_ID           NUMBER,
    REPAIR_CATEGORY_ID          NUMBER,
    REPAIR_CATEGORY_NAME        VARCHAR2 (30),
    ATA_CODE                    VARCHAR2 (30),
    INSTALLED_NUMBER            NUMBER,
    DISPATCH_NUMBER             NUMBER,
    ATTRIBUTE_CATEGORY          VARCHAR2 (30),
    ATTRIBUTE1                  VARCHAR2 (150),
    ATTRIBUTE2                  VARCHAR2 (150),
    ATTRIBUTE3                  VARCHAR2 (150),
    ATTRIBUTE4                  VARCHAR2 (150),
    ATTRIBUTE5                  VARCHAR2 (150),
    ATTRIBUTE6                  VARCHAR2 (150),
    ATTRIBUTE7                  VARCHAR2 (150),
    ATTRIBUTE8                  VARCHAR2 (150),
    ATTRIBUTE9                  VARCHAR2 (150),
    ATTRIBUTE10                 VARCHAR2 (150),
    ATTRIBUTE11                 VARCHAR2 (150),
    ATTRIBUTE12                 VARCHAR2 (150),
    ATTRIBUTE13                 VARCHAR2 (150),
    ATTRIBUTE14                 VARCHAR2 (150),
    ATTRIBUTE15                 VARCHAR2 (150),
    REMARKS_NOTE                VARCHAR2 (32767),
    DML_OPERATION               VARCHAR2 (1)
);

TYPE Ata_Sequence_Tbl_Type IS TABLE OF Ata_Sequence_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Mo_Procedure_Rec_Type IS RECORD
(
    MEL_CDL_MO_PROCEDURE_ID     NUMBER,
    OBJECT_VERSION_NUMBER       NUMBER,
    ATA_SEQUENCE_ID             NUMBER,
    MR_HEADER_ID                NUMBER,
    MR_TITLE                    VARCHAR2(80),
    MR_VERSION_NUMBER           NUMBER,
    ATTRIBUTE_CATEGORY          VARCHAR2 (30),
    ATTRIBUTE1                  VARCHAR2 (150),
    ATTRIBUTE2                  VARCHAR2 (150),
    ATTRIBUTE3                  VARCHAR2 (150),
    ATTRIBUTE4                  VARCHAR2 (150),
    ATTRIBUTE5                  VARCHAR2 (150),
    ATTRIBUTE6                  VARCHAR2 (150),
    ATTRIBUTE7                  VARCHAR2 (150),
    ATTRIBUTE8                  VARCHAR2 (150),
    ATTRIBUTE9                  VARCHAR2 (150),
    ATTRIBUTE10                 VARCHAR2 (150),
    ATTRIBUTE11                 VARCHAR2 (150),
    ATTRIBUTE12                 VARCHAR2 (150),
    ATTRIBUTE13                 VARCHAR2 (150),
    ATTRIBUTE14                 VARCHAR2 (150),
    ATTRIBUTE15                 VARCHAR2 (150),
    DML_OPERATION               VARCHAR2 (1)
);

TYPE Mo_Procedure_Tbl_Type IS TABLE OF Mo_Procedure_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Relationship_Rec_Type IS RECORD
(
    MEL_CDL_RELATIONSHIP_ID     NUMBER,
    OBJECT_VERSION_NUMBER       NUMBER,
    ATA_SEQUENCE_ID             NUMBER,
    RELATED_ATA_SEQUENCE_ID     NUMBER,
    ATTRIBUTE_CATEGORY          VARCHAR2 (30),
    ATTRIBUTE1                  VARCHAR2 (150),
    ATTRIBUTE2                  VARCHAR2 (150),
    ATTRIBUTE3                  VARCHAR2 (150),
    ATTRIBUTE4                  VARCHAR2 (150),
    ATTRIBUTE5                  VARCHAR2 (150),
    ATTRIBUTE6                  VARCHAR2 (150),
    ATTRIBUTE7                  VARCHAR2 (150),
    ATTRIBUTE8                  VARCHAR2 (150),
    ATTRIBUTE9                  VARCHAR2 (150),
    ATTRIBUTE10                 VARCHAR2 (150),
    ATTRIBUTE11                 VARCHAR2 (150),
    ATTRIBUTE12                 VARCHAR2 (150),
    ATTRIBUTE13                 VARCHAR2 (150),
    ATTRIBUTE14                 VARCHAR2 (150),
    ATTRIBUTE15                 VARCHAR2 (150),
    DML_OPERATION               VARCHAR2 (1)
);

TYPE Relationship_Tbl_Type IS TABLE OF Relationship_Rec_Type INDEX BY BINARY_INTEGER;

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name      : Process_Ata_Sequences
--  Type                : Private
--  Description         : This procedure creates, updates and deletes Ata Sequences attached with MELs/CDLs.
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_x_ata_sequences_tbl   Ata_Sequence_Tbl_Type                       Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Process_Ata_Sequences
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_FALSE,
    p_commit                    IN          VARCHAR2    := FND_API.G_FALSE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_ata_sequences_tbl       IN OUT NOCOPY   Ata_Sequence_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name      : Process_Mo_Procedures
--  Type                : Private
--  Description         : This procedure creates and deletes association of M&O procedures with Ata Sequence.
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_x_mo_procedures_tbl   Mo_Procedure_Tbl_Type                       Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Process_Mo_Procedures
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_mo_procedures_tbl       IN OUT NOCOPY   Mo_Procedure_Tbl_Type
);

--  Start of Comments  --
--
--  Procedure name      : Process_Ata_Relations
--  Type                : Private
--  Description         : This procedures creates and deletes association of Ata Sequences from other MELs/CDLs with Ata Sequence.
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_x_ata_relations_tbl   Relationship_Tbl_Type                       Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Process_Ata_Relations
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_x_ata_relations_tbl       IN OUT NOCOPY   Relationship_Tbl_Type
);

--
--  Procedure name      : Copy_MO_Proc_Revision
--  Type                : Private
--  Description         : This procedures copies new revision of M & O Procedures to the ATA Sequences to which the old revision is also associated
--  Pre-reqs            :
--
--  Standard IN  Parameters :
--      p_api_version       NUMBER                                          Required
--      p_init_msg_list     VARCHAR2    := FND_API.G_FALSE
--      p_commit            VARCHAR2    := FND_API.G_FALSE
--      p_validation_level  NUMBER      := FND_API.G_VALID_LEVEL_FULL
--      p_default           VARCHAR2    := FND_API.G_FALSE
--      p_module_type       VARCHAR2    := NULL
--
--  Standard OUT Parameters :
--      x_return_status     VARCHAR2                                        Required
--      x_msg_count         NUMBER                                          Required
--      x_msg_data          VARCHAR2                                        Required
--
--  Procedure IN, OUT, IN/OUT params :
--      p_old_mr_header_id  NUMBER                                          Required
--      p_new_mr_header_id  NUMBER                                          Required
--
--  Version :
--      Initial Version     1.0
--
--  End of Comments  --
PROCEDURE Copy_MO_Proc_Revision
(
    -- Standard IN params
    p_api_version               IN          NUMBER,
    p_init_msg_list             IN          VARCHAR2    := FND_API.G_TRUE,
    p_commit                    IN          VARCHAR2    := FND_API.G_TRUE,
    p_validation_level          IN          NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_default                   IN          VARCHAR2    := FND_API.G_FALSE,
    p_module_type               IN          VARCHAR2    := NULL,
    -- Standard OUT params
    x_return_status             OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY  NUMBER,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    -- Procedure IN, OUT, IN/OUT params
    p_old_mr_header_id          IN          NUMBER,
    p_new_mr_header_id          IN          NUMBER
);

End AHL_MEL_CDL_ATA_SEQS_PVT;

 

/
