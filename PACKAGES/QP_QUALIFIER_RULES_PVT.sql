--------------------------------------------------------
--  DDL for Package QP_QUALIFIER_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFIER_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVQRQS.pls 120.1 2005/06/16 00:06:00 appldev  $ */
--  Start of Comments
--  API name    Process_Qualifier_Rules
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--  13-Dec-99   Modified
--              Added Copy_Qualifier_rule Procedure
--  Notes
--
--  End of Comments

PROCEDURE Process_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_old_QUALIFIERS_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Qualifier_Rules
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

PROCEDURE Lock_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
);

--  Start of Comments
--  API name    Get_Qualifier_Rules
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

PROCEDURE Get_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_rule_id             IN  NUMBER
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
);
--  Start of Comments
--  API name    Copy_Qualifier_Rule
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


PROCEDURE    Copy_Qualifier_Rule
    (   p_api_version_number              IN NUMBER
    ,   p_init_msg_list                   IN VARCHAR2 := FND_API.G_FALSE
    ,   p_commit                          IN VARCHAR2 := FND_API.G_FALSE
    ,   x_return_status                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,   x_msg_count                       OUT NOCOPY /* file.sql.39 change */ NUMBER
    ,   x_msg_data                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,   p_qualifier_rule_id               IN NUMBER :=FND_API.G_MISS_NUM
    ,   p_to_qualifier_rule               IN VARCHAR2 :=FND_API.G_MISS_CHAR
    ,   p_to_description                  IN VARCHAR2 := FND_API.G_MISS_CHAR
    ,   x_qualifier_rule_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
    );

-- Blanket Agreement

PROCEDURE Create_Blanket_Qualifier
(   p_list_header_id            IN      NUMBER
,   p_old_list_header_id        IN      NUMBER
,   p_blanket_id                IN      NUMBER
,   p_operation                 IN      VARCHAR2
,   x_return_status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

END QP_Qualifier_Rules_PVT;

 

/
