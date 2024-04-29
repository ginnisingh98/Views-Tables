--------------------------------------------------------
--  DDL for Package OE_OE_HTML_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_HTML_LINE" AUTHID CURRENT_USER AS
/* $Header: ONTHLINS.pls 120.0 2005/06/01 00:36:16 appldev noship $ */

TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE Varchar2_Tbl_Type IS TABLE OF Varchar2(2000)
    INDEX BY BINARY_INTEGER;

G_NULL_NUMBER_TBL        Number_Tbl_Type;
G_NULL_VARCHAR2_TBL      Varchar2_Tbl_Type;

--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   x_line_Rec                      IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   x_line_val_rec                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Rec_Type
,   p_header_Rec                      IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
);

--  Procedure   :   Change_Attribute


PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type DEFAULT G_NULL_NUMBER_TBL
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type DEFAULT G_NULL_VARCHAR2_TBL
,   p_reason			    IN  VARCHAR2
,   p_comments			    IN  VARCHAR2
,   x_line_Rec                      IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   x_old_line_rec                  IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   x_line_val_rec                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Rec_Type

);


--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
);


--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_lock_control                  IN  NUMBER

);

Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                     IN  NUMBER
);

END Oe_Oe_Html_Line;



 

/
