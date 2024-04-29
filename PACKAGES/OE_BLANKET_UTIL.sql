--------------------------------------------------------
--  DDL for Package OE_BLANKET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BLANKET_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUBSOS.pls 120.2.12010000.3 2008/11/18 01:50:03 smusanna ship $ */

G_Header_Rec OE_Blanket_PUB.Header_rec_type ;
G_Request_Tbl  oe_blanket_pub.Request_Tbl_Type ;
g_old_header_hist_rec OE_Blanket_PUB.Header_rec_type ;
g_old_line_hist_tbl OE_Blanket_PUB.line_tbl_type ;
g_old_version_captured BOOLEAN := FALSE;

-- 11i10 Pricing Change
-- Move globals to package spec.
g_line_id_tbl                 OE_BLANKET_PUB.line_tbl_type;
g_new_price_list              boolean := false ;
g_new_modifier_list           BOOLEAN := FALSE;

-- CustomerRelationship Support for BSA
g_customer_relations           VARCHAR2(1) := NVL(OE_SYS_PARAMETERS.VALUE('CUSTOMER_RELATIONSHIPS_FLAG'), 'N');

PROCEDURE Validate_Attributes
(   p_x_header_rec       IN  OUT NOCOPY OE_Blanket_PUB.Header_rec_type
,  p_old_header_rec       IN   OE_Blanket_PUB.Header_rec_type
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Attributes
(   p_x_line_rec       IN  OUT NOCOPY OE_Blanket_PUB.line_rec_type
, p_old_line_rec       IN   OE_Blanket_PUB.line_rec_type
,  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Entity
(   p_line_rec       IN  OUT NOCOPY OE_Blanket_PUB.line_rec_type
, p_old_line_rec       IN   OE_Blanket_PUB.Line_rec_type :=
			OE_Blanket_PUB.G_MISS_BLANKET_LINE_REC
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Entity
(   p_header_rec       IN  OUT NOCOPY OE_Blanket_PUB.Header_rec_type
,  p_old_header_rec       IN   OE_Blanket_PUB.Header_rec_type :=
			OE_Blanket_PUB.G_MISS_HEADER_REC
,   x_return_status                 OUT NOCOPY VARCHAR2
);


PROCEDURE Insert_Row
(   p_header_rec       IN   OE_Blanket_PUB.Header_rec_type
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Row
(   p_header_rec       IN   OE_Blanket_PUB.Header_rec_type
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_header_id      IN   NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Insert_Row
(p_line_rec IN OE_BLANKET_PUB.Line_Rec_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Row
(   p_line_rec       IN   OE_Blanket_PUB.Line_rec_type
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Row
(   p_line_id      IN   NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
);


PROCEDURE Query_Header
(   p_header_id     IN   NUMBER
    , p_version_number IN NUMBER := NULL
    , p_phase_change_flag IN VARCHAR2 := NULL
    , x_header_rec IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
    ,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Query_Lines
(   p_line_id     IN   NUMBER := NULL
    , p_header_id   IN NUMBER := NULL
    , p_version_number IN NUMBER := NULL
    , p_phase_change_flag IN VARCHAR2 := NULL
    , x_line_tbl IN OUT NOCOPY OE_Blanket_PUB.line_tbl_type
    ,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Query_blanket
(   p_header_id     IN   NUMBER
    , p_version_number IN NUMBER := NULL
    , p_phase_change_flag IN VARCHAR2 := NULL
    , p_x_header_rec IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
    , p_x_line_tbl IN OUT NOCOPY OE_Blanket_PUB.line_tbl_type
    , x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION Query_Row
(   p_line_id                        NUMBER
    , p_version_number IN NUMBER := NULL
    , p_phase_change_flag IN VARCHAR2 := NULL
) RETURN OE_Blanket_PUB.Line_Rec_Type;

PROCEDURE Lock_Row
(   x_return_status             OUT NOCOPY VARCHAR2
,   p_blanket_id                IN NUMBER
,   p_blanket_line_id           IN NUMBER
,   p_x_lock_control            IN OUT NOCOPY NUMBER
,   x_msg_count                 OUT NOCOPY NUMBER
,   x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE Default_Attributes
    (p_x_header_rec IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
   ,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE Default_Attributes
    (p_x_line_rec IN OUT NOCOPY OE_Blanket_PUB.line_rec_type
   ,   p_default_from_header IN BOOLEAN
   ,   x_return_status                 OUT NOCOPY VARCHAR2
);

Procedure Load_Header(p_header_id IN NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
);

PROCEDURE get_order_number(
	p_x_header_rec IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
	 x_return_status OUT NOCOPY varchar2 );

PROCEDURE Process_Object(x_return_status OUT NOCOPY varchar2) ;

PROCEDURE VALIDATE_LINE_NUMBER( p_req_ind IN NUMBER
     ,   x_return_status                 OUT NOCOPY VARCHAR2
);
PROCEDURE VALIDATE_ITEM_UNIQUENESS( p_req_ind IN NUMBER
     ,   x_return_status                 OUT NOCOPY VARCHAR2
);

Procedure create_price_list(
                            p_index in NUMBER,
                            x_return_status OUT NOCOPY varchar2);
Procedure Add_price_list_line(p_req_ind IN NUMBER,
                            x_return_status OUT NOCOPY varchar2);
--for bug 3309427
Procedure Clear_price_list_line(p_req_ind IN NUMBER,
                            x_return_status OUT NOCOPY varchar2);

FUNCTION IS_BLANKET_PRICE_LIST(p_price_list_id NUMBER
                               -- 11i10 Pricing Change
                               ,p_blanket_header_id NUMBER DEFAULT NULL)
RETURN BOOLEAN;

PROCEDURE RECORD_BLANKET_HISTORY(p_version_flag in varchar2 := null,
                                 p_phase_change_flag in varchar2 := null,
                                 X_return_status out nocopy varchar2);

Procedure Copy_Blanket (p_header_id IN NUMBER,
                        p_version_number IN NUMBER,
                        x_header_id     OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2);

Procedure Return_Lines_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER );

Procedure Release_Lines_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER );

Procedure Release_Headers_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER );

Procedure Open_Release_Lines_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER );

Procedure Open_Release_Headers_Exist( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER );

Procedure Is_Expired( p_application_id IN NUMBER,
					p_entity_short_name in VARCHAR2,
					p_validation_entity_short_name in VARCHAR2,
					p_validation_tmplt_short_name in VARCHAR2,
					p_record_set_tmplt_short_name in VARCHAR2,
					p_scope in VARCHAR2,
					p_result OUT NOCOPY NUMBER );

Procedure IS_Batch_Call( p_application_id IN NUMBER,
                                        p_entity_short_name in VARCHAR2,
                                        p_validation_entity_short_name in VARCHAR2,
                                        p_validation_tmplt_short_name in VARCHAR2,
                                        p_record_set_tmplt_short_name in VARCHAR2,
                                        p_scope in VARCHAR2,
                                        p_result OUT NOCOPY NUMBER );
-- Function to initialize view%rowtype record

FUNCTION G_MISS_OE_AK_BLKT_HEADER_REC
RETURN OE_AK_BLANKET_HEADERS_V%ROWTYPE;

-- Procedure API_Rec_To_Rowtype_Rec

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_rec                    IN  OE_Blanket_PUB.HEADER_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_BLANKET_HEADERS_V%ROWTYPE
);

-- Procedure Rowtype_Rec_To_API_Rec

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_BLANKET_HEADERS_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Blanket_PUB.HEADER_Rec_Type
);

-- Function to initialize view%rowtype record

FUNCTION G_MISS_OE_AK_BLKT_LINE_REC
RETURN OE_AK_BLANKET_LINES_V%ROWTYPE;

-- Procedure API_Rec_To_Rowtype_Rec

PROCEDURE Line_API_Rec_To_Rowtype_Rec
(   p_LINE_rec                    IN  OE_Blanket_PUB.LINE_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_BLANKET_LINES_V%ROWTYPE
);

-- Procedure Rowtype_Rec_To_API_Rec

PROCEDURE Line_Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_BLANKET_LINES_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Blanket_PUB.LINE_Rec_Type
);

Procedure Get_Inventory_Item
(   p_x_line_rec       IN OUT NOCOPY    OE_Blanket_Pub.Line_Rec_Type
    ,x_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);
--Introduced as a part of the bug #4447494
PROCEDURE validate_sold_to
(   p_header_id                IN NUMBER,
    p_sold_to_org_id           IN NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2);
-- New procedure added for 5528599
PROCEDURE valid_blanket_dates
( p_header_id                 IN NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2);
-- New procedure added for 5528599
END OE_Blanket_UTIL;

/
