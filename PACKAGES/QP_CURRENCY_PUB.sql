--------------------------------------------------------
--  DDL for Package QP_CURRENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CURRENCY_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPCURS.pls 120.1 2005/06/13 00:25:01 appldev  $ */
/*#
 * This package consists of entities to set up Multi-Currency Conversion.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Multi-Currency Conversion Setup
 * @rep:category BUSINESS_ENTITY QP_PRICE_LIST
 */

--  Curr_Lists record type

TYPE Curr_Lists_Rec_Type IS RECORD
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
,   base_currency_code            VARCHAR2(15)   := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   currency_header_id            NUMBER         := FND_API.G_MISS_NUM
,   description                   VARCHAR2(2000) := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   name                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   base_rounding_factor          NUMBER         := FND_API.G_MISS_NUM
,   base_markup_formula_id        NUMBER         := FND_API.G_MISS_NUM
,   base_markup_operator          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   base_markup_value             NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
-- ,   row_id                        NUMBER         := FND_API.G_MISS_NUM  -- Commented by Sunil
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Curr_Lists_Tbl_Type IS TABLE OF Curr_Lists_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Curr_Lists value record type

TYPE Curr_Lists_Val_Rec_Type IS RECORD
(   base_currency                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   currency_header               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   base_markup_formula           VARCHAR2(240)  := FND_API.G_MISS_CHAR
-- ,   row                           VARCHAR2(240)  := FND_API.G_MISS_CHAR  -- Commented by Sunil
);

TYPE Curr_Lists_Val_Tbl_Type IS TABLE OF Curr_Lists_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Curr_Details record type

TYPE Curr_Details_Rec_Type IS RECORD
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
,   conversion_date               DATE           := FND_API.G_MISS_DATE
,   conversion_date_type          VARCHAR2(30)   := FND_API.G_MISS_CHAR
-- ,   conversion_method             VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   conversion_type               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   currency_detail_id            NUMBER         := FND_API.G_MISS_NUM
,   currency_header_id            NUMBER         := FND_API.G_MISS_NUM
,   end_date_active               DATE           := FND_API.G_MISS_DATE
,   fixed_value                   NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   markup_formula_id             NUMBER         := FND_API.G_MISS_NUM
,   markup_operator               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   markup_value                  NUMBER         := FND_API.G_MISS_NUM
,   price_formula_id              NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   rounding_factor               NUMBER         := FND_API.G_MISS_NUM
,   selling_rounding_factor       NUMBER         := FND_API.G_MISS_NUM
,   start_date_active             DATE           := FND_API.G_MISS_DATE
,   to_currency_code              VARCHAR2(15)   := FND_API.G_MISS_CHAR
,   curr_attribute_type           VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   curr_attribute_context        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   curr_attribute                VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   curr_attribute_value          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   precedence                    NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
);

TYPE Curr_Details_Tbl_Type IS TABLE OF Curr_Details_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Curr_Details value record type

TYPE Curr_Details_Val_Rec_Type IS RECORD
(   currency_detail               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   currency_header               VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   markup_formula                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   price_formula                 VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   to_currency                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Curr_Details_Val_Tbl_Type IS TABLE OF Curr_Details_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_CURR_LISTS_REC         Curr_Lists_Rec_Type;
G_MISS_CURR_LISTS_VAL_REC     Curr_Lists_Val_Rec_Type;
G_MISS_CURR_LISTS_TBL         Curr_Lists_Tbl_Type;
G_MISS_CURR_LISTS_VAL_TBL     Curr_Lists_Val_Tbl_Type;
G_MISS_CURR_DETAILS_REC       Curr_Details_Rec_Type;
G_MISS_CURR_DETAILS_VAL_REC   Curr_Details_Val_Rec_Type;
G_MISS_CURR_DETAILS_TBL       Curr_Details_Tbl_Type;
G_MISS_CURR_DETAILS_VAL_TBL   Curr_Details_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Currency
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
 * Use this API to create and update Multi-Currency Conversions. The
 * Multi-Currency Conversion cannot be deleted but it can be inactivated by
 * setting the effective dates.
 *
 * @param p_api_version_number the api version number
 * @param p_init_msg_list true or false if there is an initial message list
 * @param p_return_values true or false if there are return values
 * @param p_commit true or false if the modifier should be committed
 * @param x_return_status the return status
 * @param x_msg_count the message count
 * @param x_msg_data the message data
 * @param p_CURR_LISTS_rec the input record corresponding to the columns in the
 *        multi-currency header tables QP_CURRENCY_LISTS_B and
 *        QP_CURRENCY_LISTS_TL
 * @param p_CURR_LISTS_val_rec the input record that stores the meaning of id or
 *        code columns in the multi-currency header table
 *        QP_CURRENCY_LISTS_B
 * @param p_CURR_DETAILS_tbl input table corresponding to the columns in the
 *        multi-currency conversion line table
 *        QP_CURRENCY_DETAILS
 * @param p_CURR_DETAILS_val_tbl the input record that stores the meaning of id
 *        or code columns in the multi-currency conversion
 *        line table QP_CURRENCY_DETAILS
 * @param x_CURR_LISTS_rec the output record corresponding to the columns in the
 *        multi-currency header tables QP_CURRENCY_LISTS_B and
 *        QP_CURRENCY_LISTS_TL
 * @param x_CURR_LISTS_val_rec the output record that stores the meaning of id or
 *        code columns in the multi-currency header table
 *        QP_CURRENCY_LISTS_B
 * @param x_CURR_DETAILS_tbl the output table corresponding to the columns in the
 *        multi-currency conversion line table
 *        QP_CURRENCY_DETAILS
 * @param x_CURR_DETAILS_val_tbl the output record that stores the meaning of id
 *        or code columns in the multi-currency conversion
 *        line table QP_CURRENCY_DETAILS
 *
 *
 * @rep:displayname Process Currency
 */
PROCEDURE Process_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type :=
                                        G_MISS_CURR_LISTS_REC
,   p_CURR_LISTS_val_rec            IN  Curr_Lists_Val_Rec_Type :=
                                        G_MISS_CURR_LISTS_VAL_REC
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_TBL
,   p_CURR_DETAILS_val_tbl          IN  Curr_Details_Val_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_VAL_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Currency
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

PROCEDURE Lock_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type :=
                                        G_MISS_CURR_LISTS_REC
,   p_CURR_LISTS_val_rec            IN  Curr_Lists_Val_Rec_Type :=
                                        G_MISS_CURR_LISTS_VAL_REC
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_TBL
,   p_CURR_DETAILS_val_tbl          IN  Curr_Details_Val_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_VAL_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Currency
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

PROCEDURE Get_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_header_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_currency_header               IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
);

END QP_Currency_PUB;

 

/
