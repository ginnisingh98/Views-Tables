--------------------------------------------------------
--  DDL for Package OE_PURCHASE_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PURCHASE_RELEASE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVDSPS.pls 120.0.12010000.1 2008/07/25 07:59:37 appldev ship $ */


-- Modes for Purchase Release
G_MODE_CONCURRENT               VARCHAR2(30) := 'CONCURRENT';
G_MODE_ONLINE                   VARCHAR2(30) := 'ONLINE';

-- Results for Workflow
G_RES_INCOMPLETE                VARCHAR2(30) := 'INCOMPLETE';
G_RES_NOT_APPLICABLE            VARCHAR2(30) := 'NOT_APPLICABLE';
G_RES_COMPLETE                  VARCHAR2(30) := 'COMPLETE';
G_RES_ONHOLD                    VARCHAR2(30) := 'ONHOLD';

TYPE Drop_Ship_Line_Rec_Type IS RECORD
(header_id                       NUMBER         := FND_API.G_MISS_NUM,
 order_type_name                 VARCHAR2(240)  := FND_API.G_MISS_CHAR,
 order_number                    NUMBER         := FND_API.G_MISS_NUM,
 line_number                     NUMBER         := FND_API.G_MISS_NUM,
 line_id                         NUMBER         := FND_API.G_MISS_NUM,
 item_type_code                  VARCHAR2(30)   := FND_API.G_MISS_CHAR,
 inventory_item_id               NUMBER         := FND_API.G_MISS_NUM,
 ship_from_org_id                NUMBER         := FND_API.G_MISS_NUM,
 open_quantity                   NUMBER         := FND_API.G_MISS_NUM,
 open_quantity2                  NUMBER         := FND_API.G_MISS_NUM,
 project_id                      NUMBER         := FND_API.G_MISS_NUM,
 task_id                         NUMBER         := FND_API.G_MISS_NUM,
 end_item_unit_number            VARCHAR2(30)   := FND_API.G_MISS_CHAR,
 user_name                       VARCHAR2(100)  := FND_API.G_MISS_CHAR, -- Bug# 4189838
 employee_id                     NUMBER         := FND_API.G_MISS_NUM,
 request_date                    DATE           := FND_API.G_MISS_DATE,
 schedule_ship_date              DATE           := FND_API.G_MISS_DATE,
 source_type_code                VARCHAR2(30)   := FND_API.G_MISS_CHAR,
 charge_account_id               NUMBER         := FND_API.G_MISS_NUM,
 accrual_account_id              NUMBER         := FND_API.G_MISS_NUM,
 ship_to_org_id                  NUMBER         := FND_API.G_MISS_NUM,
 deliver_to_location_id          NUMBER         := FND_API.G_MISS_NUM,
 return_status                   VARCHAR2(1)    := FND_API.G_MISS_CHAR,
 result                          VARCHAR2(30)   := FND_API.G_MISS_CHAR,
 uom_code                        VARCHAR2(3)    := FND_API.G_MISS_CHAR,
 uom2_code                       VARCHAR2(3)    := FND_API.G_MISS_CHAR,
 preferred_grade                 VARCHAR2(150)    := FND_API.G_MISS_CHAR, -- INVCONV 4091955
 unit_list_price                 NUMBER         := FND_API.G_MISS_NUM,
 item_description                VARCHAR2(1000) := FND_API.G_MISS_CHAR
);

G_MISS_DROP_SHIP_LINE_REC           Drop_Ship_Line_Rec_Type;

TYPE Drop_Ship_Tbl_Type IS TABLE OF Drop_Ship_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

Procedure Purchase_Release
(    p_api_version_number            IN  NUMBER
,    p_drop_ship_tbl                 IN  Drop_Ship_Tbl_Type
,    p_mode                          IN  VARCHAR2 := G_MODE_ONLINE
, x_drop_ship_tbl OUT NOCOPY Drop_Ship_Tbl_Type

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

);

Procedure Insert_Into_Po_Req_Interface
(p_drop_ship_line_rec     IN  Drop_Ship_Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2

,p_user_id                IN NUMBER
,p_resp_id                IN NUMBER
,p_application_id         IN NUMBER
,p_org_id                 IN NUMBER
,p_login_id               IN NUMBER
,p_drop_ship_source_id    IN NUMBER
);

Procedure Insert_Drop_Ship_Source
( p_drop_ship_line_rec   IN  Drop_Ship_Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2

,p_user_id               IN  NUMBER
,p_resp_id               IN  NUMBER
,p_application_id        IN  NUMBER
,p_org_id                IN  NUMBER
,p_login_id              IN  NUMBER
,p_drop_ship_source_id   IN  NUMBER
);

Procedure Associate_address(p_drop_ship_line_rec   IN Drop_Ship_Line_Rec_Type
,x_drop_ship_line_rec OUT NOCOPY Drop_Ship_Line_Rec_Type

,x_return_status OUT NOCOPY VARCHAR2);


Procedure Get_Eligible_lines
(p_line_id          IN  NUMBER
,x_drop_ship_tbl OUT NOCOPY Drop_Ship_Tbl_Type

,x_return_status OUT NOCOPY VARCHAR2

);

Procedure Process_DropShip_CMS_Requests
(p_request_tbl      IN OUT NOCOPY OE_ORDER_PUB.Request_Tbl_Type
,x_return_status       OUT NOCOPY VARCHAR2
);


END OE_Purchase_Release_PVT;

/
