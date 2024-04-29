--------------------------------------------------------
--  DDL for Package CS_INSTALLEDBASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INSTALLEDBASE_PVT" AUTHID CURRENT_USER AS
/* $Header: csvibs.pls 115.22 2003/01/28 19:57:01 rmamidip ship $ */

-- ---------------------------------------------------------
-- Declare global variables
-- ---------------------------------------------------------
-- Commented out as a part of the restricting the usage of the globals
-- G_MISS_CP_REC CS_InstalledBase_PUB.CP_Prod_Rec_Type;

--------------------------------------------------------------------------

PROCEDURE Initialize_Desc_Flex
(
	p_desc_flex	IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	l_desc_flex	OUT	CS_InstalledBase_PUB.DFF_Rec_Type
);

PROCEDURE Initialize_Price_Attribs
(
	p_price_attribs	IN	CS_InstalledBase_PUB.PRICE_ATT_Rec_Type,
	l_price_attribs	OUT	CS_InstalledBase_PUB.PRICE_ATT_Rec_Type
);

PROCEDURE Cascade_To_Child_Entities
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_new_cp_id			IN	NUMBER
);


PROCEDURE Create_Base_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_cp_rec				IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_created_manually_flag	IN	VARCHAR2 DEFAULT 'N',
	p_create_revision		IN	VARCHAR2	DEFAULT FND_API.G_TRUE,
	p_create_contacts		IN	VARCHAR2	DEFAULT FND_API.G_TRUE, -- 1787841 srramakr
	p_notify_contracts		IN	VARCHAR2  DEFAULT FND_API.G_TRUE,
	p_allow_cp_with_ctr_qty_gt_one	IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_cp_id				OUT	NUMBER,
	x_object_version_number	OUT	NUMBER
);


PROCEDURE Create_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_rev_inv_item_id		IN	NUMBER,
	p_order_info			IN	CS_InstalledBase_PUB.OrderInfo_Rec_Type,
	--p_net_amount			IN	NUMBER,
	--p_currency_code		IN	VARCHAR2,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	p_start_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_end_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_delivered_flag		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
	x_cp_rev_id			OUT	NUMBER,
	x_curr_rev_of_cp_updtd	OUT	VARCHAR2,
	x_object_version_number	OUT	NUMBER
);


PROCEDURE Update_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_cp_rev_id			IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_start_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_end_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_object_version_number	OUT	NUMBER
);

PROCEDURE Record_Shipment_Info
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_ship_rec			IN	CS_InstalledBase_PUB.CP_Ship_Rec_Type,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_new_cp_id			OUT	NUMBER,
	p_savepoint_rec_lvl		IN	NUMBER	DEFAULT 1
);


-- This API is called Replace_Product in the Public API.

PROCEDURE Upgrade_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_old_cp_status_id		IN   NUMBER,
	p_cp_rec				IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_inherit_contacts		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_upgrade				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_new_cp_id			OUT	NUMBER,
	p_move_upg_in_tree		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_savepoint_rec_lvl		IN	NUMBER	DEFAULT 1,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_qty_mismatch_ok		IN	VARCHAR2	DEFAULT FND_API.G_FALSE
);


PROCEDURE Update_Product
(
	p_api_version					IN	NUMBER,
	p_init_msg_list				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit						IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level				IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status				OUT	VARCHAR2,
	x_msg_count					OUT	NUMBER,
	x_msg_data					OUT	VARCHAR2,
	p_cp_id						IN	NUMBER,
	p_as_of_date					IN	DATE	DEFAULT SYSDATE,
	p_cp_rec						IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_ship_rec					IN	CS_InstalledBase_PUB.CP_Ship_Rec_Type,
	p_comments					IN	VARCHAR2 DEFAULT NULL,
	p_split_cp_id					IN	NUMBER   DEFAULT NULL,
	p_split_reason_code				IN	VARCHAR2 DEFAULT NULL,
	p_update_by_customer_flag		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_abort_on_warn_flag			IN	CS_InstalledBase_PUB.Abort_Upd_On_Warn_Rec_Type,
	p_cascade_updates_flag			IN	CS_InstalledBase_PUB.Cascade_Upd_Flag_Rec_Type,
	p_cascade_inst_date_change_war	IN	VARCHAR2	DEFAULT FND_API.G_TRUE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_savepoint_rec_lvl				IN	NUMBER	DEFAULT 1
);


PROCEDURE Specify_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_contact_rec			IN	CS_InstalledBase_PUB.CP_Contact_Rec_Type,
	x_cs_contact_id		OUT	NUMBER,
	x_object_version_number	OUT	NUMBER
);

PROCEDURE Update_CP_Status(ERRBUF OUT VARCHAR2, RETCODE OUT NUMBER);

END CS_InstalledBase_PVT;

 

/
