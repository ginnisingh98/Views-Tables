--------------------------------------------------------
--  DDL for Package QP_PRICE_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_FORMULA_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVPRFS.pls 120.1 2005/06/15 03:44:55 appldev  $ */

--  Start of Comments
--  API name    Process_Price_Formula
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

PROCEDURE Process_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_FORMULA_LINES_tbl             IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_TBL
,   p_old_FORMULA_LINES_tbl         IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Price_Formula
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

PROCEDURE Lock_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_FORMULA_LINES_tbl             IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
);

--  Start of Comments
--  API name    Get_Price_Formula
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

PROCEDURE Get_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_formula_id              IN  NUMBER
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
);

END QP_Price_Formula_PVT;

 

/
