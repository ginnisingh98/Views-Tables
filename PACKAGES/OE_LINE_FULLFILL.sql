--------------------------------------------------------
--  DDL for Package OE_LINE_FULLFILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_FULLFILL" AUTHID CURRENT_USER AS
/* $Header: OEXVFULS.pls 120.0.12010000.1 2008/07/25 07:59:58 appldev ship $ */

TYPE Line_Set_Rec_Type	IS RECORD
(
	line_id				NUMBER := FND_API.G_MISS_NUM
,	set_id				NUMBER := FND_API.G_MISS_NUM
,	type				VARCHAR2(1) := FND_API.G_MISS_CHAR
,	fulfilled_flag		VARCHAR2(1) := FND_API.G_MISS_CHAR
,	ordered_quantity	NUMBER := FND_API.G_MISS_NUM
);

G_DEBUG_MSG  VARCHAR2(2000);

TYPE Line_Set_Tbl_Type IS TABLE OF Line_Set_Rec_Type
	INDEX BY BINARY_INTEGER;

TYPE processed_set IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

FUNCTION Is_Part_Of_Fulfillment_Set
(
	p_line_id					IN	NUMBER
) return VARCHAR2 ;

PROCEDURE Fulfill_Line
(
	p_line_rec				IN	OE_Order_Pub.Line_Rec_Type DEFAULT OE_Order_Pub.G_MISS_LINE_REC
,	p_line_tbl				IN	OE_Order_Pub.Line_Tbl_Type DEFAULT OE_Order_Pub.G_MISS_LINE_TBL
,	p_mode					IN	VARCHAR2
,	p_fulfillment_type		IN	VARCHAR2
,	p_fulfillment_activity	IN	VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Process_Fulfillment
(
	p_api_version_number	IN	NUMBER
,	p_line_id				IN	NUMBER
,	p_activity_id			IN	NUMBER
, x_result_out OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY VARCHAR2

, x_msg_data OUT NOCOPY VARCHAR2

);

PROCEDURE Get_Fulfillment_Activity
(
	p_item_key				IN	VARCHAR2
,	p_activity_id			IN	NUMBER
, x_fulfillment_activity OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Get_Activity_Result
(
	p_item_type				IN	VARCHAR2
,	p_item_key				IN	VARCHAR2
,	p_activity_name			IN	VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

, x_activity_result OUT NOCOPY VARCHAR2

, x_activity_status_code OUT NOCOPY VARCHAR2

, x_activity_id OUT NOCOPY NUMBER

);

-- Bug2068310: new parameter p_fulfill_operation added.
PROCEDURE Cancel_line
(
	p_line_id			IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

,       p_fulfill_operation             IN  VARCHAR2 DEFAULT 'N'
,       p_set_id                        IN  NUMBER DEFAULT NULL  -- 2525203
);

PROCEDURE Get_Fulfillment_Set
(
	p_line_id			IN	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

, x_set_tbl OUT NOCOPY Line_Set_Tbl_Type

);

PROCEDURE Fulfill_Service_Lines
(
	p_line_id			IN	NUMBER
,       p_header_id			IN	NUMBER DEFAULT NULL  -- 1717444
, x_return_status OUT NOCOPY VARCHAR2

);

end OE_LINE_FULLFILL;

/
