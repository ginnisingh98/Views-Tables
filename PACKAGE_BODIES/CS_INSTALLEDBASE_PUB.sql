--------------------------------------------------------
--  DDL for Package Body CS_INSTALLEDBASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INSTALLEDBASE_PUB" AS
/* $Header: cspibb.pls 120.1 2005/08/29 16:34:31 epajaril noship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_InstalledBase_PUB';
--G_USER CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- Define private procedures (not in package spec)
-- ---------------------------------------------------------

PROCEDURE Record_Split_In_Audit
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level		IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_split_cp_id			IN	NUMBER,
	p_new_cp_id			IN	NUMBER,
	p_old_cp_qty			IN	NUMBER,
	p_current_cp_qty		IN	NUMBER,
	p_reason_code			IN	VARCHAR2
) IS

BEGIN
   null;
END Record_Split_In_Audit;

-- ---------------------------------------------------------
-- Define public procedures (which are in package spec)
-- ---------------------------------------------------------
PROCEDURE Create_Base_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rec				IN	CP_Prod_Rec_Type,
	p_created_manually_flag	IN	VARCHAR2 DEFAULT 'N',
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_cp_id				OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Create_Base_Product;


PROCEDURE Record_Shipment_Info
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ship_rec			IN	CP_Ship_Rec_Type,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_new_cp_id			OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Record_Shipment_Info;


PROCEDURE Upgrade_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_old_cp_status_id		IN   NUMBER,
	p_cp_rec				IN	CP_Prod_Rec_Type,
	p_inherit_contacts		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_new_cp_id			OUT NOCOPY	NUMBER,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_qty_mismatch_ok		IN	VARCHAR2	DEFAULT FND_API.G_FALSE
) IS

BEGIN
   null;
END Upgrade_Product;


PROCEDURE Replace_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_old_cp_status_id		IN   NUMBER,
	p_cp_rec				IN	CP_Prod_Rec_Type,
	p_inherit_contacts		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_upgrade				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	x_new_cp_id			OUT NOCOPY	NUMBER,
	p_qty_mismatch_ok		IN	VARCHAR2	DEFAULT FND_API.G_FALSE
) IS

BEGIN
	null;
END Replace_Product;


PROCEDURE Update_Product
(
 	p_api_version					IN	NUMBER,
 	p_init_msg_list				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
 	p_commit						IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
 	x_return_status				OUT NOCOPY	VARCHAR2,
 	x_msg_count					OUT NOCOPY	NUMBER,
 	x_msg_data					OUT NOCOPY	VARCHAR2,
 	p_cp_id						IN	NUMBER,
 	p_as_of_date					IN	DATE	DEFAULT sysdate,
 	p_cp_rec						IN	CP_Prod_Rec_Type,
 	p_ship_rec					IN	CP_Ship_Rec_Type,
	p_comments					IN	VARCHAR2 DEFAULT NULL,
	p_update_by_customer_flag		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
 	p_abort_on_warn_flag			IN	Abort_Upd_On_Warn_Rec_Type,
 	p_cascade_updates_flag			IN	Cascade_Upd_Flag_Rec_Type,
	p_cascade_inst_date_change_war	IN	VARCHAR2	DEFAULT FND_API.G_TRUE,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM
) IS

BEGIN
  null;
END Update_Product;


PROCEDURE Create_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_rev_inv_item_id		IN	NUMBER,
	p_order_info			IN	OrderInfo_Rec_Type,
	p_desc_flex			IN	DFF_Rec_Type,
	p_start_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_end_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_delivered_flag		IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
	x_cp_rev_id			OUT NOCOPY	NUMBER,
	x_curr_rev_of_cp_updtd	OUT NOCOPY	VARCHAR2,
	x_object_version_number	OUT NOCOPY	NUMBER
)
IS

BEGIN
   null;
END Create_Revision;


PROCEDURE Update_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rev_id			IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_start_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_end_date_active		IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Update_Revision;

PROCEDURE Specify_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_contact_rec			IN	CP_Contact_Rec_Type,
	x_cs_contact_id		OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
) IS

BEGIN
  null;
END Specify_Contact;


PROCEDURE Update_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_contact_rec			IN	CP_Contact_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
) IS

BEGIN
  null;
END Update_Contact;


PROCEDURE Delete_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER
) IS

BEGIN
   null;
END Delete_Contact;



PROCEDURE Get_CP_ID
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_reference_number		IN	NUMBER,
	x_cp_id				OUT NOCOPY	NUMBER
) IS
	l_api_name	CONSTANT	VARCHAR2(30)	:= 'Get_CP_ID';
	l_api_version	CONSTANT	NUMBER		:= 1.0;
BEGIN
   null;
END Get_CP_ID;


PROCEDURE Get_Reference_Number
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	x_reference_number		OUT NOCOPY	NUMBER
) IS
BEGIN
   null;
END Get_Reference_Number;


PROCEDURE Get_CP_ID
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_serial_number		IN	VARCHAR2,
	p_config_type			IN	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
	p_as_of_date			IN	DATE		DEFAULT FND_API.G_MISS_DATE,
	p_customer_id			IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
	p_inv_item_id			IN	NUMBER	DEFAULT FND_API.G_MISS_NUM,
	x_unique_flag			OUT NOCOPY	VARCHAR2,
	x_reference_number		OUT NOCOPY	NUMBER,
	x_cp_id				OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Get_CP_ID;


PROCEDURE Get_Configuration
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_config_type			IN	VARCHAR2	DEFAULT NULL,
	p_as_of_date			IN	DATE		DEFAULT sysdate,
	x_config_tbl			OUT NOCOPY	Config_Tbl_Type,
	x_config_tbl_count		OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Get_Configuration;


PROCEDURE Get_Immediate_Components
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_id             IN      NUMBER,
	p_config_type       IN      VARCHAR2	DEFAULT NULL,
	p_as_of_date        IN      DATE    DEFAULT SYSDATE,
	x_config_tbl        OUT NOCOPY     Config_Tbl_Type,
	x_config_tbl_count  OUT NOCOPY     NUMBER
) IS

BEGIN
  null;
END Get_Immediate_Components;


PROCEDURE Get_ProductInfo
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_as_of_date			IN	DATE		DEFAULT sysdate,
	x_cp_rec				OUT NOCOPY	CP_Prod_Rec_Type,
	x_ship_rec			OUT NOCOPY	CP_Ship_Rec_Type,
	x_created_manually_flag	OUT NOCOPY	VARCHAR2
) IS

BEGIN
   null;
END Get_ProductInfo;


PROCEDURE Split_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_qty1				IN	NUMBER,
	p_qty2				IN	NUMBER,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM,
	p_reason_code			IN	VARCHAR2,

	x_new_parent_cp_id		OUT NOCOPY	NUMBER
) IS

BEGIN
   null;
END Split_Product;


PROCEDURE Split_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_reason_code			IN	VARCHAR2,
    p_org_id                IN NUMBER DEFAULT FND_API.G_MISS_NUM
) IS

BEGIN
   null;
END Split_Product;


PROCEDURE Create_Product_Parameters
(
	p_api_version			IN      NUMBER,
	p_init_msg_list		IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY     VARCHAR2,
	x_msg_count			OUT NOCOPY     NUMBER,
	x_msg_data			OUT NOCOPY     VARCHAR2,
	p_cp_param_rec			IN      CP_Param_Rec_Type,
	x_cp_parameter_id		OUT NOCOPY     NUMBER,
	x_object_version_number	OUT NOCOPY	   NUMBER
) IS
BEGIN
   null;
END Create_Product_Parameters;


PROCEDURE Update_Product_Parameters
(
	p_api_version			IN      NUMBER,
	p_init_msg_list		IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY     VARCHAR2,
	x_msg_count			OUT NOCOPY     NUMBER,
	x_msg_data			OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id		IN      NUMBER,
	p_object_version_number	IN	   NUMBER,
	p_cp_param_rec			IN      CP_Param_Rec_Type,
	x_object_version_number	OUT NOCOPY	   NUMBER
) IS

BEGIN
   null;
END Update_Product_Parameters;


PROCEDURE Delete_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id   IN      NUMBER
) IS

BEGIN
   null;
END Delete_Product_Parameters;

END CS_InstalledBase_PUB;

/
