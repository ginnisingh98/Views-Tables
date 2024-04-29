--------------------------------------------------------
--  DDL for Package OE_CONFIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONFIG_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUCFGS.pls 120.2.12010000.3 2011/02/24 10:29:29 snimmaga ship $ */

-- Constants
G_ENTITY_CONTRACT              CONSTANT VARCHAR2(30) := 'CONTRACT';
OE_BMX_ITEM_OP_SEQ             CONSTANT NUMBER := 2;
OE_BMX_ENG                     CONSTANT NUMBER := 2;
OE_BMX_IMPLEMENTED_ONLY        CONSTANT NUMBER := 1;
OE_BMX_CURRENT                 CONSTANT NUMBER := 2;
-- OE version of exploder
OE_BMX_ORDER_ENTRY_MODULE      CONSTANT NUMBER := 3;
-- included items only
OE_BMX_STD_COMPS_ONLY          CONSTANT VARCHAR2(30) := 'INCLUDED';
-- all components
OE_BMX_ALL_COMPS               CONSTANT VARCHAR2(30) := 'ALL';
-- orderable components only
OE_BMX_OPTION_COMPS            CONSTANT VARCHAR2(30) := 'OPTIONAL';
-- maximum number of levels
OE_BMX_MAX_LEVELS              CONSTANT NUMBER := 60;

-- flag to avoid recursion of cascading.
CASCADE_CHANGES_FLAG   VARCHAR2(1) 	:= 'N';
G_UPGRADED_FLAG        VARCHAR2(1)      := 'N';
-- if user used configurator or options window, this will be set.
G_CONFIG_UI_USED       VARCHAR2(1)      := 'N';

/* Bug # 5036404 Start */
-- Retreive the profile values
G_FREEZE_METHOD               VARCHAR2(30) := FND_PROFILE.VALUE('ONT_INCLUDED_ITEM_FREEZE_METHOD');
G_COPY_MODEL_DFF              VARCHAR2(30) := nvl(FND_PROFILE.VALUE('ONT_COPY_MODEL_DFF'),'N');
/* Bug # 5036404 End */

FUNCTION Config_Exists(p_line_rec IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN;

Procedure Complete_Config
( p_top_model_line_id IN  NUMBER
, x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Cascade_Changes
( p_parent_line_id     IN  NUMBER,
  p_request_rec        IN  OE_Order_Pub.Request_Rec_Type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


Procedure Change_Configuration
( p_request_rec        IN  OE_Order_Pub.Request_Rec_Type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

Procedure Query_Config_Line
(p_parent_line_id IN NUMBER
,x_line_rec       OUT NOCOPY  OE_ORDER_PUB.line_rec_type);

FUNCTION Validate_Cfgs_In_Order(p_header_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE Validate_Configuration
(p_model_line_id       IN  NUMBER,
 p_deleted_options_tbl IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_updated_options_tbl IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_validate_flag       IN  VARCHAR2 := 'Y',
 p_complete_flag       IN  VARCHAR2 := 'Y',
 p_caller              IN  VARCHAR2 := '',
 x_valid_config        OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_complete_config     OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Match_And_Reserve
( p_line_id         IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Delink_Config
( p_line_id         IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Delink_Config_batch
( p_line_id         IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

Procedure Link_Config
( p_line_id         IN  NUMBER
, p_config_item_id  IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


Procedure Query_Options
(p_top_model_line_id IN NUMBER
,p_send_cancel_lines IN VARCHAR2 := 'N'
,p_source_type       IN VARCHAR2 := ''
,x_line_tbl          OUT NOCOPY OE_ORDER_PUB.line_tbl_type);

Procedure Query_ATO_Options
(p_ato_line_id       IN NUMBER
,p_send_cancel_lines IN VARCHAR2 := 'N'
,p_source_type       IN VARCHAR2 := ''
,x_line_tbl          OUT NOCOPY OE_ORDER_PUB.line_tbl_type);

FUNCTION Freeze_Inc_Items_for_Order(p_header_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Freeze_Included_Items(p_line_id  IN  NUMBER)
RETURN VARCHAR2;

FUNCTION Process_Included_Items
(p_line_rec         IN OE_ORDER_PUB.line_rec_type := OE_ORDER_PUB.G_MISS_LINE_REC,
 p_line_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_freeze           IN  BOOLEAN,
 p_process_requests IN BOOLEAN DEFAULT FALSE)
RETURN VARCHAR2;

Procedure Query_Included_Items
( p_line_id           IN  NUMBER
, p_header_id         IN  NUMBER  := FND_API.G_MISS_NUM
, p_top_model_line_id IN  NUMBER  := FND_API.G_MISS_NUM
, p_send_cancel_lines IN VARCHAR2 := 'N'
, p_source_type       IN VARCHAR2 := ''
, x_line_tbl          OUT NOCOPY OE_ORDER_PUB.line_tbl_type);


Procedure Explode
( p_validation_org IN  NUMBER
, p_group_id       IN  NUMBER := NULL
, p_session_id     IN  NUMBER := NULL
, p_levels         IN  NUMBER := 60
, p_stdcompflag    IN  VARCHAR2
, p_exp_quantity   IN  NUMBER := NULL
, p_top_item_id    IN  NUMBER
, p_revdate        IN  DATE
, p_component_code IN  VARCHAR2 := NULL
, x_msg_data       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_error_code     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE  Supply_Reserved (
p_application_id               IN NUMBER,
p_entity_short_name            IN VARCHAR2,
p_validation_entity_short_name IN VARCHAR2,
p_validation_tmplt_short_name  IN VARCHAR2,
p_record_set_short_name        IN VARCHAR2,
p_scope                        IN VARCHAR2,
x_result                       OUT NOCOPY /* file.sql.39 change */  NUMBER);


PROCEDURE Validate_Configuration_upg
(p_model_line_id  IN     NUMBER,
 x_return_status  OUT NOCOPY /* file.sql.39 change */    VARCHAR2);


FUNCTION Is_ATO_Model
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 := OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_PTO_Model
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 := OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_Included_Option
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 := OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_Config_Item
(p_line_id   IN  NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec  IN  OE_Order_PUB.LINE_REC_TYPE
                 := OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_ATO_Option
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 := OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_PTO_Option
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_ATO_Class
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_PTO_Class
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_ATO_Subconfig
(p_line_id   IN   NUMBER
                  := FND_API.G_MISS_NUM ,
 p_line_rec  IN   OE_Order_PUB.LINE_REC_TYPE
                  :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_Kit
(p_line_id  IN   NUMBER
                 := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
                 :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

FUNCTION Is_ATO_Item
(p_line_id     IN NUMBER
                  := FND_API.G_MISS_NUM ,
 p_line_rec    IN OE_Order_PUB.LINE_REC_TYPE
                  :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN;

PROCEDURE Part_of_Configuration
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT NOCOPY /* file.sql.39 change */  NUMBER );

PROCEDURE Update_Comp_Seq_Id
( p_line_id        IN  NUMBER
 ,p_comp_seq_id    IN  NUMBER
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE  Update_Visible_Demand_Flag
( p_ato_line_id            IN  NUMBER
 ,p_visible_demand_flag    IN  VARCHAR2 := 'N'
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE  Update_Mfg_Comp_Seq_Id
( p_ato_line_id            IN  NUMBER
 ,p_mfg_comp_seq_id        IN  NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE  Update_Model_Group_Number
( p_ato_line_id            IN  NUMBER
 ,p_model_group_number     IN  NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE  Update_Cto_Columns
( p_ato_line_id            IN  NUMBER
 ,p_request_id             IN  NUMBER
 ,p_program_id             IN  NUMBER
 ,p_prog_update_date       IN  DATE
 ,p_prog_appl_id           IN  NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE Cascade_Updates_Deletes
( p_model_line_id       IN   NUMBER
 ,p_model_component     IN   VARCHAR2
 ,p_x_options_tbl       IN   OUT NOCOPY
                        Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_deleted_options_tbl IN   OE_Order_PUB.request_tbl_type
                             := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_updated_options_tbl IN   OE_Order_PUB.request_tbl_type
                             := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_ui_flag             IN   VARCHAR2 := 'N'
 ,x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE  Notify_CTO
( p_ato_line_id         IN  NUMBER
 ,p_request_rec         IN  OE_Order_Pub.Request_Rec_Type
                            := OE_Order_Pub.G_MISS_REQUEST_REC
 ,p_request_tbl         IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_split_tbl           IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_decimal_tbl         IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );


PROCEDURE Decimal_Ratio_Check
( p_top_model_line_id  IN NUMBER
 ,p_component_code     IN VARCHAR2
 ,p_ratio              IN NUMBER);


PROCEDURE Default_Child_Line
( p_parent_line_rec    IN   OE_Order_Pub.Line_Rec_Type
 ,p_x_child_line_rec   IN   OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_direct_save        IN   BOOLEAN := FALSE
 ,x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


--##1922440 bug fix.
PROCEDURE Is_Included_Item_Constrained
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT NOCOPY /* file.sql.39 change */  NUMBER );


PROCEDURE ATO_Remnant_Check
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT NOCOPY /* file.sql.39 change */  NUMBER );


PROCEDURE Launch_Supply_Workbench
( p_header_id          IN  NUMBER
 ,p_top_model_line_id  IN  NUMBER
 ,p_ato_line_id        IN  NUMBER
 ,p_line_id            IN  NUMBER
 ,p_item_type_code     IN  VARCHAR2
 ,x_wb_item_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Get_Config_Effective_Date
( p_model_line_rec        IN  OE_Order_Pub.Line_Rec_Type := null
 ,p_model_line_id         IN  NUMBER    := null
 ,x_old_behavior          OUT NOCOPY    VARCHAR2
 ,x_config_effective_date OUT NOCOPY    DATE
 ,x_frozen_model_bill     OUT NOCOPY    VARCHAR2);

PROCEDURE Create_hdr_xml
( p_model_line_id     IN  NUMBER ,
  p_ui_flag           IN  VARCHAR2 := 'N',
  x_xml_hdr           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE Send_input_xml
( p_model_line_id           IN  NUMBER ,
  p_deleted_options_tbl     IN  OE_Order_PUB.request_tbl_type
                              := OE_Order_Pub.G_MISS_REQUEST_TBL,
  p_updated_options_tbl     IN  OE_Order_PUB.request_tbl_type
                              := OE_Order_Pub.G_MISS_REQUEST_TBL,
  p_model_qty               IN  NUMBER,
  p_xml_hdr                 IN  VARCHAR2 := NULL,
  x_out_xml_msg             OUT NOCOPY /* file.sql.39 change */ LONG ,
  x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE parse_output_xml
( p_xml                IN  LONG,
  p_line_id            IN  NUMBER,
  x_valid_config       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_complete_config    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_config_header_id   OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_config_rev_nbr     OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

-- Added for DOO Pre Exploded Kit ER 9339742
PROCEDURE Process_Pre_Exploded_Kits
( p_top_model_line_id IN  NUMBER
, p_explosion_date    IN  DATE
, x_return_status     OUT NOCOPY VARCHAR2);

END OE_CONFIG_UTIL;

/
