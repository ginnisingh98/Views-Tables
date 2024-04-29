--------------------------------------------------------
--  DDL for Package QP_PRICE_FORMULA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_FORMULA_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPPRFS.pls 120.1 2005/06/13 02:45:16 appldev  $ */
/*#
 * This package consists of entities to support the formulas window.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Formula Setup
 * @rep:category BUSINESS_ENTITY QP_PRICE_FORMULA
 */

--  Formula record type

TYPE Formula_Rec_Type IS RECORD
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
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   end_date_active               DATE           := FND_API.G_MISS_DATE
/* Increased the length of formula field for bug 1539041 */
,   formula                       VARCHAR2(2000)  := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_formula_id              NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Formula_Tbl_Type IS TABLE OF Formula_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Formula value record type

TYPE Formula_Val_Rec_Type IS RECORD
(   price_formula                 VARCHAR2(2000)  := FND_API.G_MISS_CHAR
); /* increased the size of the price_formula to 2000, to fix the bug 1539041 */

TYPE Formula_Val_Tbl_Type IS TABLE OF Formula_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Formula_Lines record type

TYPE Formula_Lines_Rec_Type IS RECORD
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
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   numeric_constant              NUMBER         := FND_API.G_MISS_NUM
,   price_formula_id              NUMBER         := FND_API.G_MISS_NUM
,   price_formula_line_id         NUMBER         := FND_API.G_MISS_NUM
,   formula_line_type_code        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   price_list_line_id            NUMBER         := FND_API.G_MISS_NUM
,   price_modifier_list_id        NUMBER         := FND_API.G_MISS_NUM
,   pricing_attribute             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   pricing_attribute_context     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   step_number                   NUMBER         := FND_API.G_MISS_NUM
,   reqd_flag                     VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Formula_Lines_Tbl_Type IS TABLE OF Formula_Lines_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Formula_Lines value record type

TYPE Formula_Lines_Val_Rec_Type IS RECORD
(   price_formula                 VARCHAR2(2000)  := FND_API.G_MISS_CHAR
/* Increased the length of price_formula to 2000, to fix the bug 1539041 */
,   price_formula_line            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_formula_line_type       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_list_line               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_modifier_list           VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Formula_Lines_Val_Tbl_Type IS TABLE OF Formula_Lines_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_FORMULA_REC            Formula_Rec_Type;
G_MISS_FORMULA_VAL_REC        Formula_Val_Rec_Type;
G_MISS_FORMULA_TBL            Formula_Tbl_Type;
G_MISS_FORMULA_VAL_TBL        Formula_Val_Tbl_Type;
G_MISS_FORMULA_LINES_REC      Formula_Lines_Rec_Type;
G_MISS_FORMULA_LINES_VAL_REC  Formula_Lines_Val_Rec_Type;
G_MISS_FORMULA_LINES_TBL      Formula_Lines_Tbl_Type;
G_MISS_FORMULA_LINES_VAL_TBL  Formula_Lines_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Price_Formula
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

/*#
 * This API performs the insert, update, and delete of a formula header and
 * lines.
 *
 * @param p_api_version_number the api version number
 * @param p_init_msg_list true or false if there is an initial message list
 * @param p_return_values true or false if there are return values
 * @param p_commit true or false if the modifier should be committed
 * @param x_return_status the return status
 * @param x_msg_count the message count
 * @param x_msg_data the message data
 * @param p_FORMULA_rec the input record corresponding to the columns in
 *        QP_PRICE_FORMULAS_VL
 * @param p_FORMULA_val_rec the input record corresponding to the values for the
 *        columns in QP_PRICE_FORMULAS_VL
 * @param p_FORMULA_LINES_tbl the input table corresponding to the columns in
 *        QP_PRICE_FORMULA_LINES
 * @param p_FORMULA_LINES_val_tbl the input table corresponding to the values for
 *        the columns in QP_PRICE_FORMULA_LINES
 * @param x_FORMULA_rec the output record corresponding to the columns in
 *        QP_PRICE_FORMULAS_VL
 * @param x_FORMULA_val_rec the output record corresponding to the values for the
 *        columns in QP_PRICE_FORMULAS_VL
 * @param x_FORMULA_LINES_tbl the output table for QP_PRICE_FORMULA_LINES
 * @param x_FORMULA_LINES_val_tbl the output table for the values in
 *        QP_PRICE_FORMULA_LINES
 *
 * @rep:displayname Process Price Formula
 */
PROCEDURE Process_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  Formula_Rec_Type :=
                                        G_MISS_FORMULA_REC
,   p_FORMULA_val_rec               IN  Formula_Val_Rec_Type :=
                                        G_MISS_FORMULA_VAL_REC
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_TBL
,   p_FORMULA_LINES_val_tbl         IN  Formula_Lines_Val_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_VAL_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Price_Formula
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

PROCEDURE Lock_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  Formula_Rec_Type :=
                                        G_MISS_FORMULA_REC
,   p_FORMULA_val_rec               IN  Formula_Val_Rec_Type :=
                                        G_MISS_FORMULA_VAL_REC
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_TBL
,   p_FORMULA_LINES_val_tbl         IN  Formula_Lines_Val_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_VAL_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Price_Formula
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

PROCEDURE Get_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_formula_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_formula                 IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
);

END QP_Price_Formula_PUB;

 

/
