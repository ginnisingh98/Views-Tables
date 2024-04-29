--------------------------------------------------------
--  DDL for Package CS_INSTALLEDBASE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INSTALLEDBASE_VUHK" AUTHID CURRENT_USER AS
/* $Header: cshibs.pls 115.1 2002/12/11 20:25:40 epajaril ship $ */

PROCEDURE Pre_Create_Base_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rec				IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	x_cp_id				OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Pre_Record_Shipment_Info
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ship_rec			IN	CS_InstalledBase_PUB.CP_Ship_Rec_Type,
	x_new_cp_id			OUT NOCOPY	NUMBER
);

PROCEDURE Pre_Replace_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_old_cp_status_id		IN   NUMBER,
	p_cp_rec				IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_inherit_contacts		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_upgrade				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_new_cp_id			OUT NOCOPY	NUMBER,
	p_qty_mismatch_ok		IN	VARCHAR2	DEFAULT FND_API.G_FALSE
);

PROCEDURE Pre_Update_Product
(
	p_api_version					IN	NUMBER,
	p_init_msg_list				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit						IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status				OUT NOCOPY	VARCHAR2,
	x_msg_count					OUT NOCOPY	NUMBER,
	x_msg_data					OUT NOCOPY	VARCHAR2,
	p_cp_id						IN	NUMBER,
	p_as_of_date					IN	DATE	DEFAULT sysdate,
	p_cp_rec						IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_ship_rec					IN	CS_InstalledBase_PUB.CP_Ship_Rec_Type,
	p_abort_on_warn_flag			IN	CS_InstalledBase_PUB.Abort_Upd_On_Warn_Rec_Type,
	p_cascade_updates_flag			IN	CS_InstalledBase_PUB.Cascade_Upd_Flag_Rec_Type,
	p_cascade_inst_date_change_war	IN	VARCHAR2	DEFAULT FND_API.G_TRUE
);

PROCEDURE Pre_Create_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_rev_inv_item_id		IN	NUMBER,
	p_order_info			IN	CS_InstalledBase_PUB.OrderInfo_Rec_Type,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	p_start_date_active		IN	DATE		,
	p_end_date_active		IN	DATE		,
	p_delivered_flag		IN	VARCHAR2	,
	x_cp_rev_id			OUT NOCOPY	NUMBER,
	x_curr_rev_of_cp_updtd	OUT NOCOPY	VARCHAR2,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Pre_Update_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rev_id			IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_start_date_active		IN	DATE		,
	p_end_date_active		IN	DATE		,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Pre_Specify_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_contact_rec			IN	CS_InstalledBase_PUB.CP_Contact_Rec_Type,
	x_cs_contact_id		OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Pre_Update_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_contact_rec			IN	CS_InstalledBase_PUB.CP_Contact_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Pre_Delete_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER
);

PROCEDURE Pre_Split_Product
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
	p_reason_code			IN	VARCHAR2,
	x_new_parent_cp_id		OUT NOCOPY	NUMBER
) ;

PROCEDURE Pre_Create_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_param_rec      IN      CS_InstalledBase_PUB.CP_Param_Rec_Type,
	x_cp_parameter_id   OUT NOCOPY     NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);


PROCEDURE Pre_Update_Product_Parameters
(
	p_api_version			IN      NUMBER,
	p_init_msg_list		IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY     VARCHAR2,
	x_msg_count			OUT NOCOPY     NUMBER,
	x_msg_data			OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id		IN      NUMBER,
	p_object_version_number	IN	   NUMBER,
	p_cp_param_rec			IN      CS_InstalledBase_PUB.CP_Param_Rec_Type,
	x_object_version_number	OUT NOCOPY	   NUMBER
);


PROCEDURE Pre_Delete_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id   IN      NUMBER
);


PROCEDURE Post_Create_Base_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rec				IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	x_cp_id				OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Post_Record_Shipment_Info
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_ship_rec			IN	CS_InstalledBase_PUB.CP_Ship_Rec_Type,
	x_new_cp_id			OUT NOCOPY	NUMBER
);

PROCEDURE Post_Replace_Product
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_old_cp_status_id		IN   NUMBER,
	p_cp_rec				IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_inherit_contacts		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_upgrade				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_new_cp_id			OUT NOCOPY	NUMBER,
	p_qty_mismatch_ok		IN	VARCHAR2	DEFAULT FND_API.G_FALSE
);

PROCEDURE Post_Update_Product
(
	p_api_version					IN	NUMBER,
	p_init_msg_list				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit						IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status				OUT NOCOPY	VARCHAR2,
	x_msg_count					OUT NOCOPY	NUMBER,
	x_msg_data					OUT NOCOPY	VARCHAR2,
	p_cp_id						IN	NUMBER,
	p_as_of_date					IN	DATE	DEFAULT sysdate,
	p_cp_rec						IN	CS_InstalledBase_PUB.CP_Prod_Rec_Type,
	p_ship_rec					IN	CS_InstalledBase_PUB.CP_Ship_Rec_Type,
	p_abort_on_warn_flag			IN	CS_InstalledBase_PUB.Abort_Upd_On_Warn_Rec_Type,
	p_cascade_updates_flag			IN	CS_InstalledBase_PUB.Cascade_Upd_Flag_Rec_Type,
	p_cascade_inst_date_change_war	IN	VARCHAR2	DEFAULT FND_API.G_TRUE
);

PROCEDURE Post_Create_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_id				IN	NUMBER,
	p_rev_inv_item_id		IN	NUMBER,
	p_order_info			IN	CS_InstalledBase_PUB.OrderInfo_Rec_Type,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	p_start_date_active		IN	DATE		,
	p_end_date_active		IN	DATE		,
	p_delivered_flag		IN	VARCHAR2	,
	x_cp_rev_id			OUT NOCOPY	NUMBER,
	x_curr_rev_of_cp_updtd	OUT NOCOPY	VARCHAR2,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Post_Update_Revision
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cp_rev_id			IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_start_date_active		IN	DATE		,
	p_end_date_active		IN	DATE		,
	p_desc_flex			IN	CS_InstalledBase_PUB.DFF_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Post_Specify_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_contact_rec			IN	CS_InstalledBase_PUB.CP_Contact_Rec_Type,
	x_cs_contact_id		OUT NOCOPY	NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Post_Update_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER,
	p_object_version_number	IN	NUMBER,
	p_contact_rec			IN	CS_InstalledBase_PUB.CP_Contact_Rec_Type,
	x_object_version_number	OUT NOCOPY	NUMBER
);

PROCEDURE Post_Delete_Contact
(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
	p_cs_contact_id		IN	NUMBER
);

PROCEDURE Post_Split_Product
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
	p_reason_code			IN	VARCHAR2,
	x_new_parent_cp_id		OUT NOCOPY	NUMBER
) ;

PROCEDURE Post_Create_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_param_rec      IN      CS_InstalledBase_PUB.CP_Param_Rec_Type,
	x_cp_parameter_id   OUT NOCOPY     NUMBER,
	x_object_version_number	OUT NOCOPY	NUMBER
);


PROCEDURE Post_Update_Product_Parameters
(
	p_api_version			IN      NUMBER,
	p_init_msg_list		IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit				IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status		OUT NOCOPY     VARCHAR2,
	x_msg_count			OUT NOCOPY     NUMBER,
	x_msg_data			OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id		IN      NUMBER,
	p_object_version_number	IN	   NUMBER,
	p_cp_param_rec			IN      CS_InstalledBase_PUB.CP_Param_Rec_Type,
	x_object_version_number	OUT NOCOPY	   NUMBER
);


PROCEDURE Post_Delete_Product_Parameters
(
	p_api_version		IN      NUMBER,
	p_init_msg_list     IN      VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit            IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status     OUT NOCOPY     VARCHAR2,
	x_msg_count         OUT NOCOPY     NUMBER,
	x_msg_data          OUT NOCOPY     VARCHAR2,
	p_cp_parameter_id   IN      NUMBER
);

END CS_InstalledBase_VUHK;

 

/
