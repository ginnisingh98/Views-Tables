--------------------------------------------------------
--  DDL for Package ASO_LINE_NUM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_LINE_NUM_INT" AUTHID CURRENT_USER as
/* $Header: asoilnms.pls 120.1 2005/06/29 12:33:43 appldev ship $ */
-- Start of Comments
-- Package name     : aso_line_num_int
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call

    --Input Line Number pl/sql Record and table declaration
    TYPE In_Line_Number_Rec_Type IS RECORD
    (
        Quote_Line_ID   NUMBER  :=  FND_API.G_MISS_NUM
    );

    G_MISS_In_Line_Number_Rec   In_Line_Number_Rec_Type;

    TYPE In_Line_Number_Tbl_Type IS TABLE OF In_Line_Number_Rec_Type INDEX BY BINARY_INTEGER;

    G_MISS_In_Line_Number_Tbl  In_Line_Number_Tbl_Type;


    TYPE Out_Line_Number_Tbl_Type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;


    TYPE Line_Rec_Type IS RECORD
    (
        Quote_Line_ID               NUMBER       :=     FND_API.G_MISS_NUM,
        Item_Type_code              VARCHAR2(30) :=     FND_API.G_MISS_CHAR,
        Serviceable_Product_Flag    VARCHAR2(1)  :=     FND_API.G_MISS_CHAR,
        Service_Item_Flag           VARCHAR2(1)  :=     FND_API.G_MISS_CHAR,
        Service_Ref_Type_Code       VARCHAR2(30) :=     FND_API.G_MISS_CHAR,
        Config_Header_ID            NUMBER       :=     FND_API.G_MISS_NUM,
        Config_Revision_Num         NUMBER       :=     FND_API.G_MISS_NUM
    );

    G_MISS_Line_Rec   Line_Rec_Type;

    TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type INDEX BY BINARY_INTEGER;

    G_MISS_Line_Tbl   Line_Tbl_Type;


    PROCEDURE ASO_UI_LINE_NUMBER(
        P_In_Line_Number_Tbl        IN            ASO_LINE_NUM_INT.In_Line_Number_Tbl_Type,
        X_Out_Line_Number_Tbl       OUT NOCOPY /* file.sql.39 change */             ASO_LINE_NUM_INT.Out_Line_Number_Tbl_Type
        );

    PROCEDURE RESET_LINE_NUM;

    FUNCTION ASO_QUOTE_LINE_NUMBER(
        p_quote_line_id             in  number,
        p_item_type_code            in  varchar2,
        p_serviceable_product_flag  in  varchar2,
        p_service_item_flag         in  varchar2,
        p_service_ref_type_code     in  varchar2,
        p_config_header_id          in  number,
        p_config_revision_num       in  number
        )
    RETURN VARCHAR2;


    FUNCTION GET_UI_LINE_NUMBER(
        P_Quote_Line_Id             IN  NUMBER
        )
    RETURN VARCHAR2;

END ASO_LINE_NUM_INT;

 

/
