--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHDDGPS.pls 120.2.12010000.1 2008/07/29 05:59:29 appldev ship $ */


-- ---------------------------------------------------------------------------------------------------------
-- Procedure: delivery_detail_to_delivery
--
-- Parameters:    1) table of delivery_detail_ids
--        2) action: assign/unassign
--        3) delivery_id: need to specify delivery id or delivery nameif the action is 'ASSIGN'
--        4) delivery_name: need to specify delivery id or delivery name if the action is 'ASSIGN'
--        5) other standard parameters
--
-- Description: This procedure assign/unassign delivery_details to a delivery
--
-- History:
--          06-OCT-00 Changed container_name width from 50 to 30 for meeting wms requirements/changes
-- ---------------------------------------------------------------------------------------------------------

TYPE ID_TAB_TYPE IS table of number INDEX BY BINARY_INTEGER;

PROCEDURE detail_to_delivery(
  -- Standard parameters
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit             IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level   IN   NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,
  -- program specific parameters
  p_TabOfDelDets    IN    WSH_UTIL_CORE.ID_TAB_TYPE,
  p_action      IN    VARCHAR2,
  p_delivery_id   IN    NUMBER DEFAULT FND_API.G_MISS_NUM,
  p_delivery_name IN    VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type   -- J-IB-NPARIKH
);

--This procedure is for backward compatibility only. Do not use this.
PROCEDURE detail_to_delivery(
  -- Standard parameters
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit             IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_validation_level   IN   NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,
  -- program specific parameters
  p_TabOfDelDets    IN    WSH_UTIL_CORE.ID_TAB_TYPE,
  p_action      IN    VARCHAR2,
  p_delivery_id   IN    NUMBER DEFAULT FND_API.G_MISS_NUM,
  p_delivery_name IN    VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
);


-- ----------------------------------------------------------------------
-- Procedure:    split_line
-- Parameters:     p_from_detail_id: The delivery detail ID to be split
--                x_new_detail_id:  The new delivery detail ID x_split_quantity:  The split quantity
--
-- Description:   This procedure splits a delivery_deatil line
--
--  ----------------------------------------------------------------------

PROCEDURE split_line(
  -- Standard parameters
  p_api_version   IN    NUMBER,
  p_init_msg_list     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit            IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level  IN    NUMBER  DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY    VARCHAR2,
  x_msg_count   OUT NOCOPY    NUMBER,
  x_msg_data    OUT NOCOPY    VARCHAR2,

  -- program specific parameters
  p_from_detail_id  IN    NUMBER,
  x_new_detail_id OUT NOCOPY    NUMBER,
  x_split_quantity  IN  OUT NOCOPY  NUMBER,
  x_split_quantity2 IN  OUT NOCOPY  NUMBER,
        p_manual_split          IN      VARCHAR2 DEFAULT NULL,-- HW added for OPM
        p_converted_flag        IN      VARCHAR2 DEFAULT NULL -- HW added for OPM
        );


--bug 1747202: default these attributes so they won't be updated.
/* Not needed any more since we use WSH_INTERFACE.ChangedAttributeTabType
TYPE ChangedAttributeRecType IS RECORD (
  arrival_set_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ato_line_id     NUMBER    DEFAULT FND_API.G_MISS_NUM,
  attribute1      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute10     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute11     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute12     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute13     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute14     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute15     VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute2      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute3      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute4      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute5      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute6      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute7      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute8      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute9      VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
  attribute_category              VARCHAR2(150)   DEFAULT FND_API.G_MISS_CHAR,
  cancelled_quantity              NUMBER          DEFAULT FND_API.G_MISS_NUM,
  cancelled_quantity2             NUMBER          DEFAULT FND_API.G_MISS_NUM,
  carrier_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  classification                  VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  commodity_code_cat_id           NUMBER          DEFAULT FND_API.G_MISS_NUM,
  container_flag      VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  container_name      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  container_type_code             VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  country_of_origin               VARCHAR2(150)    DEFAULT FND_API.G_MISS_CHAR,
  currency_code                   VARCHAR2(15)    DEFAULT FND_API.G_MISS_CHAR,
  cust_model_serial_number        VARCHAR2(50)    DEFAULT FND_API.G_MISS_CHAR,
  cust_po_number      VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  customer_dock_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  customer_id                     NUMBER          DEFAULT FND_API.G_MISS_NUM,
  customer_item_id                NUMBER          DEFAULT FND_API.G_MISS_NUM,
  customer_job                    VARCHAR2(50)    DEFAULT FND_API.G_MISS_CHAR,
  customer_number           NUMBER    DEFAULT FND_API.G_MISS_NUM,
  customer_prod_seq   VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  customer_production_line        VARCHAR2(50)    DEFAULT FND_API.G_MISS_CHAR,
  customer_requested_lot_flag VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  cycle_count_quantity            NUMBER    DEFAULT FND_API.G_MISS_NUM,
  cycle_count_quantity2           NUMBER          DEFAULT FND_API.G_MISS_NUM,
  date_requested      DATE    DEFAULT FND_API.G_MISS_DATE,
  date_scheduled      DATE    DEFAULT FND_API.G_MISS_DATE,
  deliver_to_contact_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  deliver_to_org_code   VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  deliver_to_org_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  delivered_quantity              NUMBER          DEFAULT FND_API.G_MISS_NUM,
  delivered_quantity2             NUMBER          DEFAULT FND_API.G_MISS_NUM,
  delivery_detail_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  dep_plan_required_flag    VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  detail_container_item_id  NUMBER    DEFAULT FND_API.G_MISS_NUM,
  fill_percent                    NUMBER          DEFAULT FND_API.G_MISS_NUM,
  fob_code      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  fob_name      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  freight_carrier_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  freight_class_cat_id            NUMBER          DEFAULT FND_API.G_MISS_NUM,
  freight_terms_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  freight_terms_name    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  gross_weight      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  hazard_class_id                 NUMBER          DEFAULT FND_API.G_MISS_NUM,
  hold_code                       VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
  inspection_flag                 VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
  intmed_ship_to_contact_id NUMBER    DEFAULT FND_API.G_MISS_NUM,
  intmed_ship_to_org_code   VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  intmed_ship_to_org_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  inv_interfaced_flag             VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
  inventory_item_id               NUMBER          DEFAULT FND_API.G_MISS_NUM,
  item_description                VARCHAR2(250)   DEFAULT FND_API.G_MISS_CHAR,
  line_number           VARCHAR2(150)   DEFAULT FND_API.G_MISS_CHAR,
  load_seq_number                 NUMBER          DEFAULT FND_API.G_MISS_NUM,
  locator_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  lot_number      VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  lpn_content_id                  NUMBER          DEFAULT FND_API.G_MISS_NUM,
  lpn_id                          NUMBER          DEFAULT FND_API.G_MISS_NUM,
  master_container_item_id  NUMBER    DEFAULT FND_API.G_MISS_NUM,
  master_serial_number            VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  maximum_load_weight             NUMBER          DEFAULT FND_API.G_MISS_NUM,
  maximum_volume                  NUMBER          DEFAULT FND_API.G_MISS_NUM,
  minimum_fill_percent            NUMBER          DEFAULT FND_API.G_MISS_NUM,
  move_order_line_id              NUMBER          DEFAULT FND_API.G_MISS_NUM,
  movement_id                     NUMBER          DEFAULT FND_API.G_MISS_NUM,
  mvt_stat_status                 VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  net_weight      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  oe_interfaced_flag              VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
  order_quantity_uom    VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ordered_qty_unit_of_measure   VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR,
  ordered_qty_unit_of_measure2  VARCHAR2(25)  DEFAULT FND_API.G_MISS_CHAR,
  ordered_quantity    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ordered_quantity2   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ordered_quantity_uom2   VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  org_id                          NUMBER          DEFAULT FND_API.G_MISS_NUM,
  organization_id                 NUMBER          DEFAULT FND_API.G_MISS_NUM,
  original_subinventory           VARCHAR2(10)    DEFAULT FND_API.G_MISS_CHAR,
  packing_instructions    VARCHAR2(2000)  DEFAULT FND_API.G_MISS_CHAR,
  pickable_flag                   VARCHAR2(1)     DEFAULT FND_API.G_MISS_CHAR,
  picked_quantity                 NUMBER          DEFAULT FND_API.G_MISS_NUM,
  picked_quantity2                NUMBER          DEFAULT FND_API.G_MISS_NUM,
  preferred_grade     VARCHAR2(4) DEFAULT FND_API.G_MISS_CHAR,
  project_id                      NUMBER          DEFAULT FND_API.G_MISS_NUM,
  quality_control_quantity        NUMBER          DEFAULT FND_API.G_MISS_NUM,
  quality_control_quantity2       NUMBER          DEFAULT FND_API.G_MISS_NUM,
  released_status     VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  request_id                      NUMBER          DEFAULT FND_API.G_MISS_NUM,
  revision      VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  seal_code                       VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  serial_number     VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  ship_from_org_code    VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ship_from_org_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_model_complete_flag  VARCHAR2(1) DEFAULT FND_API.G_MISS_CHAR,
  ship_set_id     NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_to_contact_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_to_org_code    VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  ship_to_org_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_to_site_use_id             NUMBER          DEFAULT FND_API.G_MISS_NUM,
  ship_tolerance_above    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  ship_tolerance_below    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  shipment_priority_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  shipped_quantity                NUMBER    DEFAULT FND_API.G_MISS_NUM,
  shipped_quantity2               NUMBER          DEFAULT FND_API.G_MISS_NUM,
  shipping_instructions   VARCHAR2(2000)  DEFAULT FND_API.G_MISS_CHAR,
  shipping_method_code    VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  sold_to_contact_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  sold_to_org_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  source_code                     VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  source_header_id    NUMBER    DEFAULT FND_API.G_MISS_NUM,
  source_header_number            VARCHAR2(150)   DEFAULT FND_API.G_MISS_CHAR,
  source_header_type_id           NUMBER          DEFAULT FND_API.G_MISS_NUM,
  source_header_type_name         VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  source_line_id      NUMBER    DEFAULT FND_API.G_MISS_NUM,
  split_from_delivery_detail_id   NUMBER          DEFAULT FND_API.G_MISS_NUM,
  src_requested_quantity          NUMBER          DEFAULT FND_API.G_MISS_NUM,
  src_requested_quantity2         NUMBER          DEFAULT FND_API.G_MISS_NUM,
  src_requested_quantity_uom      VARCHAR2(3)     DEFAULT FND_API.G_MISS_CHAR,
  src_requested_quantity_uom2     VARCHAR2(3)     DEFAULT FND_API.G_MISS_CHAR,
  subinventory      VARCHAR2(10)  DEFAULT FND_API.G_MISS_CHAR,
  sublot_number     VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  task_id                         NUMBER          DEFAULT FND_API.G_MISS_NUM,
  to_serial_number                VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  top_model_line_id   NUMBER    DEFAULT FND_API.G_MISS_NUM,
  tp_attribute1                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute10                  VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute11                  VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute12                  VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute13                  VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute14                  VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute15                  VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute2                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute3                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute4                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute5                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute6                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute7                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute8                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute9                   VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tp_attribute_category           VARCHAR2(240)   DEFAULT FND_API.G_MISS_CHAR,
  tracking_number                 VARCHAR2(30)  DEFAULT FND_API.G_MISS_CHAR,
  transaction_temp_id             NUMBER          DEFAULT FND_API.G_MISS_NUM,
  unit_number                     VARCHAR2(30)    DEFAULT FND_API.G_MISS_CHAR,
  unit_price                      NUMBER          DEFAULT FND_API.G_MISS_NUM,
  volume        NUMBER    DEFAULT FND_API.G_MISS_NUM,
  volume_uom_code     VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  volume_uom_desc     VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR,
  weight_uom_code     VARCHAR2(3) DEFAULT FND_API.G_MISS_CHAR,
  weight_uom_desc     VARCHAR2(50)  DEFAULT FND_API.G_MISS_CHAR
  );

TYPE ChangedAttributeTabType IS TABLE OF ChangedAttributeRecType
  INDEX BY BINARY_INTEGER;*/

        -- Patchset I: Harmonization Project Changes Begin
  --
/* do not use type action_parameters_rec_type, use the one defined in
   wsh_glbl_var_strct_grp
*/
        TYPE action_parameters_rec_type IS RECORD
        (
            -- Generic
            Caller              VARCHAR2(32767),
            Action_Code         VARCHAR2(32767),
            Phase               NUMBER,
            -- Assign/Unassign
            delivery_id   NUMBER ,
            delivery_name VARCHAR2(32767),
            -- Calculate weight and volume
            wv_override_flag  VARCHAR2(32767),
            -- Cycle Count
            quantity_to_split NUMBER,
            quantity2_to_split  NUMBER,
            -- Pack, Unpack
            container_name      VARCHAR2(32767),
            container_instance_id NUMBER,
            container_flag      VARCHAR2(1),
            delivery_flag       VARCHAR2(1),
            -- Autopack
            group_id_tab        wsh_util_core.id_tab_type,
            -- Split Line
            split_quantity        NUMBER,
            split_quantity2       NUMBER,
            -- Process Deliveries
            group_by_header_flag       VARCHAR(1)
            );
        --
        --
  --
/* do not use default_parameters_rec_type, use the record defined in
   wsh_glbl_var_strct_grp
*/
        TYPE default_parameters_rec_type IS RECORD
        (
            --
            quantity_to_cc  NUMBER,
            quantity2_to_cc NUMBER,
            detail_group_params wsh_delivery_autocreate.grp_attr_rec_type
        );
        --
        --
  --
        TYPE trip_rec_type IS RECORD
        (
            --
            trip_id         NUMBER,
            trip_name       VARCHAR2(32767)
        );
        --
/* do not use action_out_rec_type, use the record defined in
   wsh_glbl_var_strct_grp
*/
       TYPE action_out_rec_type IS RECORD
       (
        valid_id_tab          WSH_UTIL_CORE.id_tab_type,
        selection_issue_flag  VARCHAR2(1),
        delivery_id_tab       WSH_UTIL_CORE.id_tab_type,
        result_id_tab         WSH_UTIL_CORE.id_tab_type,
        split_quantity        NUMBER,
        split_quantity2       NUMBER);

        --

/* do not use ActionsInOutRecType, use the record defined in
   wsh_glbl_var_strct_grp
*/
       TYPE actionsInOutRecType  IS RECORD
       (
          split_quantity   NUMBER,
          split_quantity2  NUMBER
       );
        --
/* do not use SerialRangeRecType, use the record defined in
   wsh_glbl_var_strct_grp
*/
        TYPE serialRangeRecType IS RECORD
        (
          delivery_detail_id NUMBER,
          from_serial_number VARCHAR2(30),
          to_serial_number   VARCHAR2(30),
          quantity           NUMBER,
          attribute_category VARCHAR2(30),
          attribute1         VARCHAR2(150),
          attribute2         VARCHAR2(150),
          attribute3         VARCHAR2(150),
          attribute4         VARCHAR2(150),
          attribute5         VARCHAR2(150),
          attribute6         VARCHAR2(150),
          attribute7         VARCHAR2(150),
          attribute8         VARCHAR2(150),
          attribute9         VARCHAR2(150),
          attribute10        VARCHAR2(150),
          attribute11        VARCHAR2(150),
          attribute12        VARCHAR2(150),
          attribute13        VARCHAR2(150),
          attribute14        VARCHAR2(150),
          attribute15        VARCHAR2(150)
        );
        --
/* do not use serialRangeTabType, use the table defined in wsh_glbl_var_strct_grp */

        TYPE serialRangeTabType IS TABLE OF serialRangeRecType
        INDEX BY BINARY_INTEGER;

/* do not use detailInRecType, use the table defined in wsh_glbl_var_strct_grp */
        TYPE detailInRecType IS RECORD
        (
            --
            caller        VARCHAR2(32767),
            action_code       VARCHAR2(32767),
            phase       NUMBER,
            container_item_id     NUMBER,
            container_item_name   VARCHAR2(32767),
            container_item_seg    FND_FLEX_EXT.SegmentArray,
            organization_id       NUMBER,
            organization_code     VARCHAR2(32767),
            name_prefix           VARCHAR2(32767),
            name_suffix           VARCHAR2(32767),
            base_number           NUMBER,
            num_digits            NUMBER,
            quantity              NUMBER,
            container_name        VARCHAR2(32767),
            lpn_ids               wsh_util_core.id_tab_type
        );

  --
/* do not use detailOutRecType, use the table defined in wsh_glbl_var_strct_grp */
        TYPE detailOutRecType    IS   RECORD
        (
           --
           detail_ids WSH_UTIL_CORE.Id_Tab_Type
        );

        -- Patchset I: Harmonization Project Changes End

--===================
-- PROCEDURES
--===================


--========================================================================
-- PROCEDURE : Update_Shipping_Attributes
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         initialize message stack
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--            p_changed_attributes    changed attributes for delivery details
--             p_source_code           source system
--
--
-- COMMENT   : Validates Organization_id and Organization_code against view
--             org_organization_definitions. If both values are
--             specified then only Org_Id is used
--========================================================================

PROCEDURE Update_Shipping_Attributes (
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_changed_attributes     IN OUT  NOCOPY  WSH_INTERFACE.ChangedAttributeTabType
, p_source_code            IN     VARCHAR2
, p_container_flag         IN     VARCHAR2 DEFAULT NULL
);

PROCEDURE Get_Detail_Status(
  p_delivery_detail_id  IN NUMBER
, x_line_status         OUT NOCOPY  VARCHAR2
, x_return_status       OUT NOCOPY  VARCHAR2
);

-- ---------------------------------------------------------------------
-- Procedure: Autocreate_Deliveries
--
-- change on 8/24/2005 : p_caller is added
--                       refer to bug 4467032 (R12 Routing Guide)
-- -----------------------------------------------------------------------
PROCEDURE Autocreate_Deliveries(
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, p_caller                 IN     VARCHAR2 DEFAULT NULL
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows             IN     WSH_UTIL_CORE.id_tab_type
, p_group_by_header_flag   IN     VARCHAR2 DEFAULT NULL
, x_del_rows                  OUT NOCOPY  wsh_util_core.id_tab_type
);

PROCEDURE Autocreate_del_trip(
  p_api_version_number     IN     NUMBER
, p_init_msg_list          IN     VARCHAR2
, p_commit                 IN     VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_line_rows              IN     WSH_UTIL_CORE.id_tab_type
, x_del_rows                  OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
, x_trip_rows                 OUT NOCOPY  WSH_UTIL_CORE.id_tab_type
);

    -- ---------------------------------------------------------------------
    -- Procedure: Delivery_Detail_Action
    --
    -- Parameters:
    --
    -- Description:  This procedure is the core group API for the
    --               delivery_detail_action. This is for called by STF directly.
    --         Public API and other product APIs call the wrapper version.
    --               The wrapper version, in turn, calls this procedure.
    -- Created during the Patchset I: Harmonization Project
    -- -----------------------------------------------------------------------

    PROCEDURE Delivery_Detail_Action(
    -- Standard Parameters
       p_api_version_number        IN       NUMBER,
       p_init_msg_list             IN       VARCHAR2,
       p_commit                    IN       VARCHAR2,
       x_return_status             OUT NOCOPY     VARCHAR2,
       x_msg_count                 OUT NOCOPY     NUMBER,
       x_msg_data                  OUT NOCOPY     VARCHAR2,

    -- Procedure specific Parameters
       p_rec_attr_tab              IN     WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_action_prms               IN     WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
       x_defaults                  OUT NOCOPY    WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type, -- defaults
       x_action_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type
       );


    -- ---------------------------------------------------------------------
    -- Procedure: Create_Update_Delivery_Detail
    --
    -- Parameters:
    --
    -- Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
    -- Created during the Patchset I: Harmonization Project
    -- -----------------------------------------------------------------------

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number  IN  NUMBER,
       p_init_msg_list           IN    VARCHAR2,
       p_commit                  IN    VARCHAR2,
       x_return_status           OUT     NOCOPY  VARCHAR2,
       x_msg_count               OUT   NOCOPY  NUMBER,
       x_msg_data                OUT   NOCOPY  VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_IN_rec                  IN   WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.detailOutRecType
    );



/*    ---------------------------------------------------------------------
    Procedure: Create_Update_Delivery_Detail (OVERLOADED)

    Parameters:

    Description:  This procedure is the new API for wrapping the logic of CREATE/UPDATE of delivery details
                     This OVERLOADED procedure has the additional parameter 'p_serial_range_tab'
    Created during the Patchset I: Harmonization Project
    ----------------------------------------------------------------------- */

    PROCEDURE Create_Update_Delivery_Detail
    (
       -- Standard Parameters
       p_api_version_number  IN  NUMBER,
       p_init_msg_list           IN    VARCHAR2,
       p_commit                  IN    VARCHAR2,
       x_return_status           OUT     NOCOPY  VARCHAR2,
       x_msg_count               OUT   NOCOPY  NUMBER,
       x_msg_data                OUT   NOCOPY  VARCHAR2,

       -- Procedure Specific Parameters
       p_detail_info_tab         IN   WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type,
       p_IN_rec                  IN   WSH_GLBL_VAR_STRCT_GRP.detailInRecType,
       x_OUT_rec                 OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.detailOutRecType,
       p_serial_range_tab        IN  WSH_GLBL_VAR_STRCT_GRP.ddSerialRangeTabType
    );

    -- ---------------------------------------------------------------------
    -- Procedure: Get_Carton_Grouping
    --
    -- Parameters:
    --
    -- Description:  This procedure is the new API for wrapping the logic of autcreate_deliveries.
    -- Usage: Called by WMS code to return carton grouping table.
    -- -----------------------------------------------------------------------
    PROCEDURE Get_Carton_Grouping (p_line_rows             IN          WSH_UTIL_CORE.id_tab_type,
                                   x_grouping_rows         OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
                                   x_return_status         OUT NOCOPY  VARCHAR2);


END WSH_DELIVERY_DETAILS_GRP;

/
