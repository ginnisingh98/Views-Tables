--------------------------------------------------------
--  DDL for Package IBE_ORDER_SAVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ORDER_SAVE_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVORDS.pls 120.1.12010000.3 2016/03/11 09:07:23 kdosapat ship $ */

 -- Different SaveTypes to identify the flow.
SAVE_ADDITEMS       NUMBER := 0;
SAVE_NORMAL         NUMBER := 1;
SAVE_REMOVEITEMS    NUMBER := 2;
CHECK_CONSTRAINTS   NUMBER := 3;

TYPE x_qtyfail_LineType IS TABLE OF VARCHAR2(240)
  INDEX BY BINARY_INTEGER;


PROCEDURE Save(
     p_api_version_number       IN  NUMBER     := 1
    ,p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2   := FND_API.G_FALSE
    ,p_order_header_rec         IN  OE_Order_PUB.Header_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC
    ,p_order_line_tbl           IN  OE_Order_PUB.Line_Tbl_Type   := OE_ORDER_PUB.G_MISS_LINE_TBL
    ,p_submit_control_rec       IN  IBE_Order_W1_PVT.Control_Rec_Type := IBE_Order_W1_PVT.G_MISS_Control_Rec
    ,p_save_type                IN  NUMBER := FND_API.G_MISS_NUM
    ,p_party_id                 IN  NUMBER := FND_API.G_MISS_NUM
    ,p_shipto_partysite_id      IN  NUMBER  := FND_API.G_MISS_NUM
    ,p_billto_partysite_id      IN  NUMBER  := FND_API.G_MISS_NUM
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,x_order_header_id          OUT NOCOPY NUMBER
    ,x_order_number             OUT NOCOPY NUMBER
    ,x_flow_status_code         OUT NOCOPY VARCHAR2
    ,x_last_update_date         OUT NOCOPY DATE
    ,X_failed_line_ids          OUT NOCOPY JTF_VARCHAR2_TABLE_300  --3272918
    );

PROCEDURE CheckConstraint(
     p_api_version_number       IN  NUMBER     := 1
    ,p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2   := FND_API.G_FALSE
    ,p_order_header_rec         IN  OE_Order_PUB.Header_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC
    ,p_order_line_tbl           IN  OE_Order_PUB.Line_Tbl_Type   := OE_ORDER_PUB.G_MISS_LINE_TBL
    ,p_submit_control_rec       IN  IBE_Order_W1_PVT.Control_Rec_Type := IBE_Order_W1_PVT.G_MISS_Control_Rec
    ,p_combine_same_lines       IN  VARCHAR2 := FND_API.G_MISS_CHAR
    ,p_party_id                 IN  NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,x_error_lineids            OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_last_update_date         OUT NOCOPY DATE
    );


PROCEDURE UpdateLineShippingBilling(
     p_api_version_number       IN  NUMBER     := 1
    ,p_init_msg_list            IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2   := FND_API.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,p_order_header_id          IN NUMBER := FND_API.G_MISS_NUM
    ,p_order_line_id            IN NUMBER := FND_API.G_MISS_NUM
    ,p_billto_party_id          IN NUMBER := FND_API.G_MISS_NUM
    ,p_billto_cust_acct_id      IN NUMBER := FND_API.G_MISS_NUM
    ,p_billto_party_site_id     IN NUMBER := FND_API.G_MISS_NUM
    ,p_shipto_party_id          IN NUMBER := FND_API.G_MISS_NUM
    ,p_shipto_cust_acct_id      IN NUMBER := FND_API.G_MISS_NUM
    ,p_shipto_party_site_id     IN NUMBER := FND_API.G_MISS_NUM
    ,p_last_update_date         IN DATE
    );


PROCEDURE Retrieve_OE_Messages;

END IBE_Order_Save_pvt;

/
