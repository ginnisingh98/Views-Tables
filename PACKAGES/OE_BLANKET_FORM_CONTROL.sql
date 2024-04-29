--------------------------------------------------------
--  DDL for Package OE_BLANKET_FORM_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_FORM_CONTROL" AUTHID CURRENT_USER AS
/* $Header: OEXFBSOS.pls 120.1 2006/03/29 16:44:16 spooruli noship $ */
    G_PKG_NAME         VARCHAR2(30) := 'OE_Blanket_Form_Control';

    G_INCLUDE_ALL_REVISIONS         VARCHAR2(1) := 'N';

    PROCEDURE Header_Value_Conversion
    (   p_header_rec         IN  OUT NOCOPY OE_Blanket_PUB.Header_Rec_type
    ,   p_header_val_rec     IN  OUT NOCOPY OE_Order_PUB.Header_Val_Rec_Type
    );

    PROCEDURE Line_Value_Conversion
    (  p_line_rec            IN OUT  NOCOPY  OE_Blanket_PUB.Line_Rec_Type
    ,  p_line_val_rec        IN OUT  NOCOPY  OE_Order_PUB.Line_Val_Rec_Type
    );

    PROCEDURE Populate_Header_Values_ID
    (  p_Header_rec            IN OUT  NOCOPY  OE_Blanket_PUB.Header_Rec_Type
    ,  p_Header_val_rec        IN OUT  NOCOPY  OE_Order_PUB.Header_Val_Rec_Type
    );

    PROCEDURE Populate_Line_Values_ID
    (  p_line_rec            IN OUT  NOCOPY  OE_Blanket_PUB.line_Rec_Type
    ,  p_Line_val_rec        IN OUT  NOCOPY  OE_Order_PUB.Line_Val_Rec_Type
    );

    PROCEDURE Validate_Entity
    (p_header_rec         IN  OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2
    );

    PROCEDURE Validate_Entity
    (p_line_rec           IN  OUT NOCOPY OE_Blanket_PUB.line_rec_type,
     x_return_status      IN  OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2
    );

    PROCEDURE Insert_Row
    (p_header_rec         IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2);

    PROCEDURE Update_Row
    (p_header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2);

-- hashraf start pack J
  PROCEDURE Delete_Row
    (p_header_id         IN NUMBER,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2);
-- hashraf end pack J

    PROCEDURE Insert_Row
    (p_line_rec              IN OUT NOCOPY  OE_BLANKET_PUB.Line_Rec_Type,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2);

    PROCEDURE Update_Row
    (p_line_rec              IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2);

-- hashraf start pack J
   PROCEDURE Delete_Row
    (p_line_id         IN NUMBER,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2);
-- hashraf end pack J

    PROCEDURE Default_Attributes
    (p_x_header_rec          IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_return_status         OUT NOCOPY VARCHAR2);

    PROCEDURE Default_Attributes
    (p_x_line_rec            IN OUT NOCOPY OE_Blanket_PUB.line_rec_type,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_return_status         OUT NOCOPY VARCHAR2);

    PROCEDURE Process_Object
    (x_return_status         IN OUT NOCOPY varchar2,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2);

    PROCEDURE Check_Sec_Header_Attr
    (x_return_status         IN OUT NOCOPY varchar2,
     p_header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     p_old_header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     -- 11i10 security changes
     p_column_name           IN VARCHAR2 DEFAULT NULL,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2);

    PROCEDURE Check_Sec_Line_Attr
    (x_return_status         IN OUT NOCOPY varchar2,
     p_line_rec            IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     p_old_line_rec        IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2);

    PROCEDURE Check_Sec_Header_Entity
    (x_return_status         IN OUT NOCOPY varchar2,
     p_header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2);

    PROCEDURE Check_Sec_Line_Entity
    (x_return_status         IN OUT NOCOPY varchar2,
     p_line_rec            IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2);

    PROCEDURE Update_Header_Cache
    (p_x_header_rec            IN OUT NOCOPY OE_Blanket_PUB.header_rec_type,
     delete_flag               IN            Varchar2 DEFAULT NULL);

    PROCEDURE Update_Line_Cache
    (p_x_line_rec            IN OUT NOCOPY   OE_Blanket_PUB.line_rec_type,
     delete_flag             IN              Varchar2 DEFAULT NULL);

    PROCEDURE Lock_Header_Row
    (p_row_id                IN VARCHAR2);

    PROCEDURE Lock_Line_Row
    (p_row_id                IN VARCHAR2);

    PROCEDURE Load_Blanket_Line_Number
    (l_x_header_id      IN Varchar2);

    PROCEDURE Load_Blanket_Header_Rec
    (p_x_Header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
    ,p_x_old_Header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type);

    PROCEDURE Load_Blanket_Line_Rec
    (p_x_line_rec            IN  OE_Blanket_PUB.line_rec_type
    ,p_x_old_line_rec        IN OUT NOCOPY OE_Blanket_PUB.line_rec_type);

-- hashraf start pack J
Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   block_name           IN  VARCHAR2
);
-- hashraf end pack J

    FUNCTION Line_number
    ( p_header_id       IN  NUMBER
    ) RETURN number;

    FUNCTION Line_number_reset
    RETURN varchar2;

    FUNCTION Sales_Order_Type
    (p_order_type_id IN number)
    RETURN varchar2;

    FUNCTION item_identifier
    (p_item_identifier_type IN varchar2)
    RETURN varchar2;

    FUNCTION Get_Currency_Format
    (p_currency_code    IN VARCHAR2,
     p_field_length     IN NUMBER,
     p_percision        IN NUMBER default null,
     p_min_acct_unit    IN NUMBER default null)
     RETURN VARCHAR2;

    FUNCTION Get_Opr_Create
    RETURN varchar2;

    FUNCTION Get_Opr_Update
    RETURN varchar2;

-- hashraf start pack J
   FUNCTION Get_Opr_Delete
    RETURN varchar2;
-- hashraf end pack J

    FUNCTION Chk_for_header_release
    (p_blanket_number IN number)
    RETURN varchar2;

    FUNCTION Chk_for_line_release
    (p_blanket_number IN number,
     p_blanket_line_number IN number)
    RETURN varchar2;

    PROCEDURE Set_Include_All_Revisions
    (p_value IN Varchar2);

    FUNCTION Include_All_Revisions
    RETURN Varchar2;

    FUNCTION Chk_active_revision
    (p_blanket_number IN number,
     p_version_number IN number)
     RETURN varchar2;

    FUNCTION get_trxt_phase_from_order_type
    (p_order_type_id IN number)
    RETURN varchar2;

END OE_Blanket_Form_Control;

/
