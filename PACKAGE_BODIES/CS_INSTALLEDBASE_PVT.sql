--------------------------------------------------------
--  DDL for Package Body CS_INSTALLEDBASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INSTALLEDBASE_PVT" AS
/* $Header: csvibb.pls 115.117 2003/01/28 19:55:48 rmamidip ship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME      CONSTANT        VARCHAR2(30)    := 'CS_InstalledBase_PVT';
--G_USER                CONSTANT        VARCHAR2(30)    := FND_GLOBAL.USER_ID;
--------------------------------------------------------------------------

-- ---------------------------------------------------------
-- Define private procedures accessible only within this package
-- ---------------------------------------------------------

PROCEDURE Cascade_To_Child_Entities
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_cp_id                         IN      NUMBER,
        p_new_cp_id                     IN      NUMBER
) IS

BEGIN

  null;

END Cascade_To_Child_Entities;


PROCEDURE Record_Split_In_Audit
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_split_cp_id                   IN      NUMBER,
        p_new_cp_id                     IN      NUMBER,
        p_old_cp_qty                    IN      NUMBER,
        p_current_cp_qty                IN      NUMBER,
        p_reason_code                   IN      VARCHAR2
) IS

BEGIN
  null;
END Record_Split_In_Audit;


PROCEDURE Initialize_Order_Info
(
        p_order_info    IN      CS_InstalledBase_PUB.OrderInfo_Rec_Type,
        l_order_info    OUT     CS_InstalledBase_PUB.OrderInfo_Rec_Type
) IS

BEGIN

  null;
END Initialize_Order_Info;


PROCEDURE Initialize_CP_Rec_Param
(
        p_cp_rec        IN      CS_InstalledBase_PUB.CP_Prod_Rec_Type,
        l_cp_rec        OUT     CS_InstalledBase_PUB.CP_Prod_Rec_Type
) IS

BEGIN
  null;
END Initialize_CP_Rec_Param;


PROCEDURE Initialize_Ship_Rec_Param
(
        p_ship_rec      IN      CS_InstalledBase_PUB.CP_Ship_Rec_Type,
        l_ship_rec      OUT     CS_InstalledBase_PUB.CP_Ship_Rec_Type
) IS

BEGIN

   null;
END Initialize_Ship_Rec_Param;

--------------------------------------------------------------------------

-- Start of comments
--  API name     :     Ship_Revision
--  Type         :     Private
--  Function     :     Marks a revision as having shipped and records shipment
--                     related information.
--  Pre-reqs     :     None.
--
--  IN Parameters:
--      p_cp_revision_id        IN     NUMBER     Required
--      p_shipped_date          IN     DATE       Required
--      p_revision              IN     VARCHAR2   Required
--      p_serial_number         IN     VARCHAR2   Required
--   p_lot_number            IN     VARCHAR2   Required

--  OUT parameters:
--      None
--
--  Version     :       Current version 1.0
--                              Initial version 1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Ship_Revision
(
        p_cp_revision_id                IN      NUMBER,
        p_shipped_date                  IN      DATE,
        p_revision                      IN      VARCHAR2,
        p_serial_number         IN      VARCHAR2,
        p_lot_number                    IN      VARCHAR2
) IS

BEGIN
  null;
END Ship_Revision;


--------------------------------------------------------------------------

-- Start of comments
--  API name     :     Ship_CP_Or_Revision
--  Type         :     Private
--  Function     :     Determines whether a revision or an entire product was
--                     shipped and takes appropriate action. If an entire
--                     product was shipped,it also activates the contracts if
--                     any, on that product.
--  Pre-reqs     :     None.
--
--  IN Parameters:
--   p_cp_id                        IN   NUMBER   Required
--      p_cp_revision_id               IN   NUMBER   Required
--      p_shipped_date                 IN   DATE     Required
--      p_revision                     IN   VARCHAR2 Required
--      p_serial_number                IN   VARCHAR2 Required
--   p_lot_number                   IN   VARCHAR2 Required
--   p_actual_ship_to_site_use_id   IN   NUMBER   Optional
--                                                Default = FND_API.G_MISS_NUM
--   p_current_cp_rev_id_of_cp      IN   NUMBER   Optional
--                                                Default = FND_API.G_MISS_NUM
--   p_shipped_order_line_id        IN   NUMBER   Optional
--                                                Default = FND_API.G_MISS_NUM
--   p_unshipped_order_line_id      IN   NUMBER   Optional
--                                                Default = FND_API.G_MISS_NUM

--  OUT parameters:
--      None
--
--  Version     :       Current version 1.0
--                              Initial version 1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Ship_CP_Or_Revision
(
        p_cp_id                                 IN      NUMBER,
        p_cp_revision_id                        IN      NUMBER,
        p_shipped_date                          IN      DATE,
        p_revision                              IN      VARCHAR2,
        p_serial_number                 IN      VARCHAR2,
        p_lot_number                            IN      VARCHAR2,
        p_actual_ship_to_site_use_id    IN      NUMBER  DEFAULT FND_API.G_MISS_NUM,
        p_current_cp_rev_id_of_cp       IN      NUMBER  DEFAULT FND_API.G_MISS_NUM,
        p_shipped_order_line_id         IN      NUMBER  DEFAULT FND_API.G_MISS_NUM,
        p_unshipped_order_line_id       IN      NUMBER  DEFAULT FND_API.G_MISS_NUM
) IS


BEGIN
  null;
END Ship_CP_Or_Revision;

PROCEDURE Initialize_Price_Attribs
(
        p_price_attribs IN      CS_InstalledBase_PUB.PRICE_ATT_Rec_Type,
        l_price_attribs OUT     CS_InstalledBase_PUB.PRICE_ATT_Rec_Type
) IS
BEGIN

  null;
END Initialize_Price_Attribs;

-- ---------------------------------------------------------
-- Define procedures also specified in the spec of this package.
-- ---------------------------------------------------------

PROCEDURE Initialize_Desc_Flex
(
        p_desc_flex     IN      CS_InstalledBase_PUB.DFF_Rec_Type,
        l_desc_flex     OUT     CS_InstalledBase_PUB.DFF_Rec_Type
) IS

BEGIN
  null;
END Initialize_Desc_Flex;


PROCEDURE Create_Base_Product
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_cp_rec                                IN      CS_InstalledBase_PUB.CP_Prod_Rec_Type,
        p_created_manually_flag IN      VARCHAR2 DEFAULT 'N',
        p_create_revision               IN      VARCHAR2        DEFAULT FND_API.G_TRUE,
        p_create_contacts               IN      VARCHAR2        DEFAULT FND_API.G_TRUE, -- 1787841 srramakr
        p_notify_contracts              IN      VARCHAR2  DEFAULT FND_API.G_TRUE,
        p_allow_cp_with_ctr_qty_gt_one  IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
        x_cp_id                         OUT     NUMBER,
        x_object_version_number OUT     NUMBER
) IS
BEGIN
  null;
END Create_Base_Product;


PROCEDURE Create_Revision
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_cp_id                         IN      NUMBER,
        p_rev_inv_item_id               IN      NUMBER,
        p_order_info                    IN      CS_InstalledBase_PUB.OrderInfo_Rec_Type,
        p_desc_flex                     IN      CS_InstalledBase_PUB.DFF_Rec_Type,
        p_start_date_active             IN      DATE            DEFAULT FND_API.G_MISS_DATE,
        p_end_date_active               IN      DATE            DEFAULT FND_API.G_MISS_DATE,
        p_delivered_flag                IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
        x_cp_rev_id                     OUT     NUMBER,
        x_curr_rev_of_cp_updtd  OUT     VARCHAR2,
        x_object_version_number OUT     NUMBER
) IS

BEGIN

  null;
END Create_Revision;


PROCEDURE Update_Revision
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_cp_rev_id                     IN      NUMBER,
        p_object_version_number IN      NUMBER,
        p_start_date_active             IN      DATE            DEFAULT FND_API.G_MISS_DATE,
        p_end_date_active               IN      DATE            DEFAULT FND_API.G_MISS_DATE,
        p_desc_flex                     IN      CS_InstalledBase_PUB.DFF_Rec_Type,
        x_object_version_number OUT     NUMBER
) IS

BEGIN
  null;
END Update_Revision;

PROCEDURE Record_Shipment_Info
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_ship_rec                      IN      CS_InstalledBase_PUB.CP_Ship_Rec_Type,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
        x_new_cp_id                     OUT     NUMBER,
        p_savepoint_rec_lvl             IN      NUMBER  DEFAULT 1
) IS
BEGIN

  null;
END Record_Shipment_Info;


PROCEDURE Upgrade_Product
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_cp_id                         IN      NUMBER,
        p_old_cp_status_id              IN   NUMBER,
        p_cp_rec                                IN      CS_InstalledBase_PUB.CP_Prod_Rec_Type,
        p_inherit_contacts              IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_upgrade                               IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        x_new_cp_id                     OUT     NUMBER,
        p_move_upg_in_tree              IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_savepoint_rec_lvl             IN      NUMBER  DEFAULT 1,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
        p_qty_mismatch_ok               IN      VARCHAR2        DEFAULT FND_API.G_FALSE
) IS
BEGIN

  null;
END Upgrade_Product;


PROCEDURE Update_Product
(
        p_api_version                                   IN      NUMBER,
        p_init_msg_list                         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level                              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status                         OUT     VARCHAR2,
        x_msg_count                                     OUT     NUMBER,
        x_msg_data                                      OUT     VARCHAR2,
        p_cp_id                                         IN      NUMBER,
        p_as_of_date                                    IN      DATE    DEFAULT sysdate,
        p_cp_rec                                                IN      CS_InstalledBase_PUB.CP_Prod_Rec_Type,
        p_ship_rec                                      IN      CS_InstalledBase_PUB.CP_Ship_Rec_Type,
        p_comments                                      IN      VARCHAR2 DEFAULT NULL,
        p_split_cp_id                                   IN      NUMBER   DEFAULT NULL,
        p_split_reason_code                             IN      VARCHAR2 DEFAULT NULL,
        p_update_by_customer_flag               IN      VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_abort_on_warn_flag                    IN      CS_InstalledBase_PUB.Abort_Upd_On_Warn_Rec_Type,
        p_cascade_updates_flag                  IN      CS_InstalledBase_PUB.Cascade_Upd_Flag_Rec_Type,
        p_cascade_inst_date_change_war  IN      VARCHAR2        DEFAULT FND_API.G_TRUE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
        p_savepoint_rec_lvl                             IN      NUMBER  DEFAULT 1
) IS
BEGIN

  null;

END Update_Product;


PROCEDURE Specify_Contact
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_commit                                IN      VARCHAR2        DEFAULT FND_API.G_FALSE,
        p_validation_level              IN      VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT     VARCHAR2,
        x_msg_count                     OUT     NUMBER,
        x_msg_data                      OUT     VARCHAR2,
        p_contact_rec                   IN      CS_InstalledBase_PUB.CP_Contact_Rec_Type,
        x_cs_contact_id         OUT     NUMBER,
        x_object_version_number OUT     NUMBER
) IS
BEGIN

  null;
END Specify_Contact;

PROCEDURE Update_CP_Status(ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER) IS

BEGIN
  null;
END Update_CP_Status;

END CS_InstalledBase_PVT;

/
