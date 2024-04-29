--------------------------------------------------------
--  DDL for Package OE_OE_HTML_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_HTML_HEADER" AUTHID CURRENT_USER AS
/* $Header: ONTHHDRS.pls 120.0 2005/06/01 00:47:56 appldev noship $ */

--  Procedure : Default_Attributes
--



TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE Varchar2_Tbl_Type IS TABLE OF Varchar2(2000)
    INDEX BY BINARY_INTEGER;

G_NULL_NUMBER_TBL        Number_Tbl_Type;
G_NULL_VARCHAR2_TBL      Varchar2_Tbl_Type;

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   x_header_rec                    IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   p_transaction_phase_code        IN VARCHAR2
);

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type
,   x_header_rec                 IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
);

PROCEDURE Save_Header
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_process                       IN  BOOLEAN DEFAULT FALSE
,   x_header_rec                 IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec             IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
);
PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
);


--  Procedure       Process_Object
--

PROCEDURE Process_Object
(
  p_init_msg_list IN VARCHAR2:=FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, x_cascade_flag OUT NOCOPY BOOLEAN
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_lock_control                  IN  NUMBER
);



Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
);


Procedure Delete_All_Requests
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);

Procedure Populate_Transient_Attributes
(
  P_header_rec               IN Oe_Order_Pub.header_rec_type
, x_header_val_rec           OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Val_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
);


END Oe_Oe_Html_Header;

 

/
