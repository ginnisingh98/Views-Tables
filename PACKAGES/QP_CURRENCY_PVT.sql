--------------------------------------------------------
--  DDL for Package QP_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CURRENCY_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVCURS.pls 120.1 2005/06/14 21:55:49 appldev  $ */

--  Start of Comments
--  API name    Process_Currency
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

PROCEDURE Process_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_CURR_DETAILS_tbl              IN  QP_Currency_PUB.Curr_Details_Tbl_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_TBL
,   p_old_CURR_DETAILS_tbl          IN  QP_Currency_PUB.Curr_Details_Tbl_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Currency
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

PROCEDURE Lock_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_CURR_DETAILS_tbl              IN  QP_Currency_PUB.Curr_Details_Tbl_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
);

--  Start of Comments
--  API name    Get_Currency
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

PROCEDURE Get_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_header_id            IN  NUMBER
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
);

END QP_Currency_PVT;

 

/
