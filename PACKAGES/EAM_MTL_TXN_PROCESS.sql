--------------------------------------------------------
--  DDL for Package EAM_MTL_TXN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MTL_TXN_PROCESS" AUTHID CURRENT_USER AS
 /* $Header: EAMMTTXS.pls 120.1 2007/11/29 03:26:14 mashah ship $ */
Procedure  PROCESSMTLTXN(
                          p_txn_header_id    IN NUMBER,
                          p_item_id          IN OUT NOCOPY NUMBER,
                          p_item             IN VARCHAR2 := NULL,
                          p_revision         IN VARCHAR2 := NULL,
                          p_org_id           IN OUT NOCOPY NUMBER,
                          p_trx_action_id    IN NUMBER ,
                          p_subinv_code      IN OUT NOCOPY VARCHAR2 ,
                          p_tosubinv_code    IN VARCHAR2  := NULL,
                          p_locator_id       IN OUT NOCOPY NUMBER,
                          p_locator          IN VARCHAR2  := NULL,
                          p_tolocator_id     IN NUMBER    := NULL,
                          p_trx_type_id      IN NUMBER ,
                          p_trx_src_type_id  IN NUMBER ,
                          p_trx_qty          IN NUMBER ,
                          p_pri_qty          IN NUMBER ,
                          p_uom              IN VARCHAR2 ,
                          p_date             IN DATE     := sysdate,
                          p_reason_id        IN OUT NOCOPY NUMBER,
                          p_reason           IN VARCHAR2 := NULL ,
                          p_user_id          IN NUMBER ,
                          p_trx_src_id       IN NUMBER   := NULL,
                          x_trx_temp_id      OUT NOCOPY NUMBER ,
	                      p_operation_seq_num  IN NUMBER   := NULL,
                          p_wip_entity_type    IN NUMBER   := NULL,
                          p_trx_reference      IN VARCHAR2 := NULL,
                          p_negative_req_flag  IN NUMBER   := NULL,
                          p_serial_ctrl_code   IN NUMBER   := NULL,
                          p_lot_ctrl_code      IN NUMBER   := NULL,
                          p_from_ser_number    IN VARCHAR2 := NULL,
                          P_to_ser_number      IN VARCHAR2 := NULL,
                          p_lot_num            IN VARCHAR2 := NULL,
                          p_wip_supply_type    IN NUMBER   := NULL,
                          p_subinv_ctrl        IN NUMBER   := 0,
                          p_locator_ctrl       IN NUMBER   := 0,
                          p_wip_process        IN NUMBER   := NULL, -- determines to call WIP Transaction API
                                                                    -- 0 -> No call,1 -> Call
                          p_dateNotInFuture    IN NUMBER   := 1,    -- 1 --> do check,0 --> no check
                          x_error_flag        OUT NOCOPY NUMBER,           -- returns 0 if no error ,
                                                                                    -- 1 if any error ,error message name will be in x_error_mssg,
                                                                                    -- 2 if any error ,error message itself will be in x_error_mssg.
                          x_error_mssg        OUT NOCOPY VARCHAR2
) ;

/* This Procedure will return Locator control for a specified
** Organization,Subinventory,Item combination based on the
** Locator Control definition at those 3 levels .More over this
** API does take care of allowing 'Dynamic Entry' control based
** on Organization level  Negative Inv flag,Item level Restrict
** Locator flag and Specified Action .
*/
Procedure Get_LocatorControl_Code(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER,
                          x_locator_ctrl     OUT NOCOPY NUMBER,
                          x_error_flag       OUT NOCOPY NUMBER, -- returns 0 if no error ,1 if any error .
                          x_error_mssg       OUT NOCOPY VARCHAR2
) ;

/* This procedure will process the request for more of Inventory Item */

 PROCEDURE MoreMaterial_Add
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_organization_id           	IN      NUMBER,
        p_operation_seq_num             IN      NUMBER,
         p_item_id              		IN      NUMBER,
	p_required_quantity		IN	NUMBER,
        p_requested_quantity   IN  NUMBER,
        p_supply_subinventory  IN     VARCHAR2 DEFAULT NULL, --12.1 source sub project
        p_supply_locator_id 		IN     NUMBER DEFAULT NULL, --12.1 source sub project


        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );

/* This procedure will process the request for more of Direct Item */

PROCEDURE MoreDirectItem_Add
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_organization_id           	IN      NUMBER,
        p_operation_seq_num             IN      NUMBER,
       p_direct_item_type  IN NUMBER,
        p_item_id         		IN      NUMBER,
	p_need_by_date			IN	DATE,
	p_required_quantity		IN	NUMBER,
	 p_requested_quantity   IN  NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );
/*This procedure is called from the self service side page Re. New Inventory Items page.
It calls the wo api.
*/
PROCEDURE insert_into_wro(
                   p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_organization_id    IN       NUMBER
  		,p_inventory_item_id  IN    NUMBER
  	 	,p_description            IN   VARCHAR2
                  ,p_operation_seq_num    IN     NUMBER
   		,p_supply             	IN     NUMBER
                ,p_mode      IN   VARCHAR2  :=  'INSERT'
  		,p_required_date        IN     DATE
  		,p_quantity            IN      NUMBER
  		,p_comments            IN      VARCHAR2
  		,p_supply_subinventory  IN     VARCHAR2
  		,p_locator 		IN     VARCHAR2
  		,p_mrp_net_flag         IN     VARCHAR2
  		,p_material_release     IN     VARCHAR2
                 ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2
                 );


PROCEDURE insert_into_wdi(
                   p_api_version        IN       NUMBER
                  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                  ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                  ,p_wip_entity_id      IN       NUMBER
                  ,p_organization_id    IN       NUMBER
  		,p_direct_item_seq_id  IN   NUMBER  := NULL
  	 	,p_description            IN   VARCHAR2
                  ,p_operation_seq_num    IN     NUMBER
                  ,p_mode      IN   VARCHAR2 := 'INSERT'
                 ,p_direct_item_type    IN VARCHAR2 :='1'
                 ,p_purchasing_category_id     NUMBER          :=null
                 ,p_suggested_vendor_id	        NUMBER     :=null
                 ,p_suggested_vendor_name	        VARCHAR2    :=null
                 ,p_suggested_vendor_site	        VARCHAR2    :=null
                 ,p_suggested_vendor_contact      VARCHAR2    :=null
                  ,p_suggested_vendor_phone        VARCHAR2    :=null,
                  p_suggested_vendor_item_num     VARCHAR2    :=null,
                  p_unit_price                    NUMBER          :=null,
                 p_auto_request_material       VARCHAR2     :=null,
                 p_required_quantity            NUMBER          :=null,
                 p_uom                          VARCHAR2     :=null,
                  p_need_by_date                 DATE            :=null
                 ,x_return_status      OUT NOCOPY      VARCHAR2
                  ,x_msg_count          OUT NOCOPY      NUMBER
                  ,x_msg_data           OUT NOCOPY      VARCHAR2
                 );

/* This Function will return 'Y' if Locator entry is allowed
** for a specified Organization,Subinventory,Item combinations .
*/
Function Is_LocatorControlled(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER
) return VARCHAR2;

/* This function will return TRUE if 'Dynamic Entry' control
** is allowed based on Organization level  Negative Inv flag,Item
** level Restrict Locator flag and Specified Action .
*/
Function Dynamic_Entry_Not_Allowed(
                          p_restrict_flag IN NUMBER,
                          p_neg_flag      IN NUMBER,
                          p_action        IN NUMBER) return Boolean ;

END eam_mtl_txn_process;

/
