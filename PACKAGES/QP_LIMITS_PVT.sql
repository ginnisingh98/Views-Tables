--------------------------------------------------------
--  DDL for Package QP_LIMITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMITS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVLMTS.pls 120.1 2005/06/14 23:29:57 appldev  $ */

--  Start of Comments
--  API name    Process_Limits
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

PROCEDURE Process_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_LIMIT_ATTRS_tbl               IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_TBL
,   p_old_LIMIT_ATTRS_tbl           IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_BALANCES_tbl            IN  QP_Limits_PUB.Limit_Balances_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_TBL
,   p_old_LIMIT_BALANCES_tbl        IN  QP_Limits_PUB.Limit_Balances_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Limits
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

PROCEDURE Lock_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_LIMIT_ATTRS_tbl               IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_BALANCES_tbl            IN  QP_Limits_PUB.Limit_Balances_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
);

--  Start of Comments
--  API name    Get_Limits
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

PROCEDURE Get_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_id                      IN  NUMBER
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
);

END QP_Limits_PVT;

 

/
