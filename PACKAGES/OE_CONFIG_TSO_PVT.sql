--------------------------------------------------------
--  DDL for Package OE_CONFIG_TSO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_TSO_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVTSOS.pls 120.3.12010000.1 2008/07/25 08:07:55 appldev ship $ */

/*
TYPE Instance_Rec_type IS RECORD
(
--Instance_header_id	NUMBER
--, Instance_rev_nbr	NUMBER
--, Ship_to_org_id	NUMBER
--, Bill_to_org_id	NUMBER
 item_instance_id             NUMBER
,config_instance_hdr_id       NUMBER
,config_instance_rev_number   NUMBER
,config_instance_item_id      NUMBER
,bill_to_site_use_id          NUMBER
,ship_to_site_use_id          NUMBER
,instance_name                VARCHAR2(255)
--, Config_instance_item_id   NUMBER
);
*/

--TYPE Instance_Tbl_Type IS TABLE OF Instance_Rec_Type
--INDEX BY BINARY_INTEGER;


MACD_SYSTEM_CALL           VARCHAR2(1)    := 'N';

PROCEDURE Is_Part_of_Container_Model
( p_line_id               IN   NUMBER DEFAULT NULL
, p_top_model_line_id     IN   NUMBER DEFAULT NULL
, p_ato_line_id           IN   NUMBER DEFAULT NULL
, p_inventory_item_id     IN   NUMBER DEFAULT NULL
, p_operation             IN   VARCHAR2 DEFAULT NULL
, p_org_id		  IN   NUMBER DEFAULT NULL --Bug 5524710
, x_top_container_model   OUT  NOCOPY VARCHAR2
, x_part_of_container     OUT  NOCOPY VARCHAR2
);

/*
PROCEDURE Get_MACD_Action_Mode
( p_line_id             IN  NUMBER
, p_top_model_line_id   IN  NUMBER   DEFAULT NULL
, p_ato_line_id         IN  NUMBER   DEFAULT NULL
, p_check_if_container  IN  VARCHAR2 DEFAULT NULL
, x_top_container_model OUT NOCOPY   VARCHAR2
, x_config_mode         OUT NOCOPY   VARCHAR2
);
*/

PROCEDURE Get_MACD_Action_Mode
( p_line_rec          IN OE_Order_pub.Line_Rec_Type := null
, p_line_id           IN NUMBER := null
, p_top_model_line_id IN NUMBER := null
, p_check_ibreconfig  IN VARCHAR2 := null
, x_config_mode       OUT NOCOPY NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
);


PROCEDURE Validate_Container_Model
( p_line_rec           IN             OE_Order_pub.Line_Rec_Type
, p_old_line_rec       IN             OE_Order_Pub.Line_Rec_Type
, x_return_status      OUT NOCOPY     VARCHAR2
);

PROCEDURE Remove_Unchanged_Lines
( p_top_model_line_id   IN           NUMBER
, p_line_id             IN           NUMBER
, p_ato_line_id         IN           NUMBER
, x_msg_count           OUT NOCOPY   NUMBER
, x_msg_data            OUT NOCOPY   VARCHAR2
, x_return_status       OUT NOCOPY   VARCHAR2
);

PROCEDURE Remove_Unchanged_Components
( p_header_id          IN            NUMBER
, p_line_id            IN            NUMBER
, p_top_model_line_id  IN            NUMBER
, p_ato_line_id        IN            NUMBER
, x_msg_data           OUT NOCOPY    VARCHAR2
, x_msg_count          OUT NOCOPY    NUMBER
, x_return_status      OUT NOCOPY    VARCHAR2
);

PROCEDURE Populate_TSO_Order_Lines
( p_header_id          IN           NUMBER
, p_top_model_line_id  IN           NUMBER
--, p_instance_tbl     IN           Instance_Tbl_Type
, p_instance_tbl       IN           csi_datastructures_pub.instance_cz_tbl
, p_mode               IN           NUMBER
, x_msg_data           OUT NOCOPY   VARCHAR2
, x_msg_count          OUT NOCOPY   NUMBER
, x_return_status      OUT NOCOPY   VARCHAR2
);

Procedure Process_MACD_Order
(P_api_version_number     IN  NUMBER,
 P_caller                 IN  VARCHAR2,
 P_x_header_id            IN  OUT NOCOPY NUMBER,
 P_sold_to_org_id         IN  NUMBER,
 P_MACD_Action            IN  VARCHAR2,
 P_x_line_tbl             IN  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
 P_Instance_Tbl           IN  csi_datastructures_pub.instance_cz_tbl,
 P_Extended_Attrib_Tbl    IN  csi_datastructures_pub.ext_attrib_values_tbl,
 x_container_line_id      OUT NOCOPY NUMBER,
 x_number_of_containers   OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY VARCHAR2,
 x_msg_data               OUT NOCOPY VARCHAR2
);

END OE_CONFIG_TSO_PVT;

/
