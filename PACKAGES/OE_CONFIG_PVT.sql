--------------------------------------------------------
--  DDL for Package OE_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCFGS.pls 120.1.12010000.1 2008/07/25 07:58:43 appldev ship $ */

-- to avoid recursive calls to process_order.
OECFG_VALIDATE_CONFIG          VARCHAR2(1)    := 'Y';

-- to do pricing only once for a call to save options
OECFG_CONFIGURATION_PRICING    VARCHAR2(1)    := 'N';

-- to freeze included items at entry.
-- we will store line_id in apply_attribute_changes.

TYPE OE_FREEZE_INC_ITEMS IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

OE_FREEZE_INC_ITEMS_TBL        OE_FREEZE_INC_ITEMS;

OE_MODIFY_INC_ITEMS_TBL        OE_Order_PUB.request_tbl_type
                               := OE_Order_Pub.G_MISS_REQUEST_TBL;


G_CONFIG_INSTANCE_TBL   csi_datastructures_pub.instance_cz_tbl;

Procedure Process_Config
( p_header_id           IN  NUMBER
 ,p_config_hdr_id       IN  NUMBER
 ,p_config_rev_nbr      IN  NUMBER
 ,p_top_model_line_id   IN  NUMBER
 ,p_ui_flag             IN  VARCHAR2
                        := 'Y'
 ,p_config_instance_tbl IN csi_datastructures_pub.instance_cz_tbl
                        := G_CONFIG_INSTANCE_TBL
 ,x_change_flag         OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
 ,x_return_status       OUT NOCOPY VARCHAR2);


Procedure Delete_Config
(p_config_hdr_id      IN  NUMBER ,
 p_config_rev_nbr     IN  NUMBER ,
 x_return_status      OUT NOCOPY VARCHAR2);


Procedure Copy_Config
(p_top_model_line_id  IN  NUMBER ,
 p_config_hdr_id      IN  NUMBER ,
 p_config_rev_nbr     IN  NUMBER ,
 p_configuration_id   IN  NUMBER ,
 p_remnant_flag       IN  VARCHAR2 ,
 x_return_status      OUT NOCOPY VARCHAR2 );


-- below temp
Procedure Copy_Config1
(p_config_hdr_id      IN  NUMBER ,
 p_config_rev_nbr     IN  NUMBER ,
 x_config_hdr_id      OUT NOCOPY NUMBER ,
 x_config_rev_nbr     OUT NOCOPY NUMBER ,
 x_return_status      OUT NOCOPY VARCHAR2 );


PROCEDURE  put_hold_and_release_hold
( p_header_id        IN  NUMBER,
  p_line_id          IN  NUMBER,
  p_valid_config     IN  VARCHAR2,
  p_complete_config  IN  VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER ,
  x_msg_data         OUT NOCOPY VARCHAR2 ,
  x_return_status    OUT NOCOPY VARCHAR2 );


Procedure Explode_Bill
( p_model_line_rec        IN  OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_do_update             IN  BOOLEAN   := TRUE
 ,p_check_effective_date  IN  VARCHAR2  := 'Y'
 ,x_config_effective_date OUT NOCOPY    DATE
 ,x_frozen_model_bill     OUT NOCOPY    VARCHAR2
 ,x_return_status         OUT NOCOPY    VARCHAR2);



PROCEDURE Call_Process_Order
( p_line_tbl          IN  OUT NOCOPY  OE_Order_Pub.Line_Tbl_Type
 ,p_class_line_tbl    IN  OE_Order_Pub.Line_Tbl_Type
                          := OE_ORDER_PUB.G_MISS_LINE_TBL
 ,p_control_rec       IN  OUT NOCOPY  OE_GLOBALS.Control_Rec_Type
 ,p_ui_flag           IN  VARCHAR2    := 'N'
 ,p_top_model_line_id IN  NUMBER      := null
 ,p_config_hdr_id     IN  NUMBER      := null
 ,p_config_rev_nbr    IN  NUMBER      := null
 ,p_update_columns    IN  BOOLEAN     := FALSE
,x_return_status OUT NOCOPY VARCHAR2);


Procedure Change_Columns
( p_top_model_line_id IN NUMBER
 ,p_config_hdr_id     IN NUMBER
 ,p_config_rev_nbr    IN NUMBER
 ,p_ui_flag           IN VARCHAR2 := 'N'
 ,p_operation         IN VARCHAR2 := 'A');


PROCEDURE Included_Items_DML
( p_x_line_tbl         IN  OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
 ,p_top_model_line_id  IN  NUMBER
 ,p_ui_flag            IN  VARCHAR2
,x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Modify_Included_Items
(x_return_status OUT NOCOPY VARCHAR2);


PROCEDURE Is_Cancel_OR_Delete
( p_line_id          IN NUMBER
 ,p_change_reason    IN VARCHAR2 := null
 ,p_change_comments  IN VARCHAR2 := null
 ,x_cancellation     OUT NOCOPY BOOLEAN
 ,x_line_rec         IN OUT NOCOPY OE_Order_Pub.line_rec_type);

END Oe_Config_Pvt;

/
