--------------------------------------------------------
--  DDL for Package EAM_MATERIALISSUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MATERIALISSUE_PVT" AUTHID CURRENT_USER AS
  /* $Header: EAMMATTS.pls 120.1.12010000.2 2009/10/06 08:35:34 vchidura ship $*/
  -- g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_materialissue_pvt';
procedure Fork_Logic(  p_api_version   IN  NUMBER   := 1.0,
  p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
  p_commit                    IN      VARCHAR2 := fnd_api.g_false,
  p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
  x_return_status             OUT     NOCOPY VARCHAR2  ,
  x_msg_count                 OUT     NOCOPY NUMBER,
  x_msg_data                  OUT     NOCOPY VARCHAR2,

  p_wip_entity_type           IN      NUMBER,
  p_organization_id           IN      NUMBER,
  p_wip_entity_id             IN      NUMBER,
  p_operation_seq_num         IN      NUMBER   := null,
  p_inventory_item_id         IN      NUMBER   := null,
  p_revision                  IN      VARCHAR2 := null,
  p_requested_quantity        IN      NUMBER   := null,
  p_source_subinventory       IN      VARCHAR2 := null,
  p_source_locator            IN      VARCHAR2 := null,
  p_lot_number                IN      VARCHAR2 := null,
  p_fm_serial                 IN      VARCHAR2 := null,
  p_to_serial                 IN      VARCHAR2 := null,
  p_reasons                   IN      VARCHAR2   :=null,
  p_reference                 IN      VARCHAR2  :=null,
  p_date                      IN       date := sysdate,
  p_rebuild_item_id           IN     Number  :=null,
  p_rebuild_item_name         IN     varchar2 := null,
  p_rebuild_serial_number     IN     Varchar2  :=null,
  p_rebuild_job_name          IN  OUT NOCOPY  Varchar2  ,
  p_rebuild_activity_id       IN     Number  :=null,
  p_rebuild_activity_name     IN     varchar2 := null,
  p_user_id                   IN    Number  := null,
  p_inventory_item            IN    varchar2 := null,   --Added for bug 8661513
  p_locator_name              IN    varchar2 := null);  --Added for bug 8661513


PROCEDURE process_mmtt(
  p_api_version               IN      NUMBER   := 1.0,
  p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
  p_commit                    IN      VARCHAR2 := fnd_api.g_false,
  p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
  x_return_status             OUT     NOCOPY VARCHAR2,
  x_msg_count                 OUT     NOCOPY NUMBER,
  x_msg_data                  OUT     NOCOPY VARCHAR2,
  p_trx_tmp_id           IN  NUMBER);

  PROCEDURE insert_ser_trx(p_trx_tmp_id 		IN	VARCHAR2,
			 p_serial_trx_tmp_id 	IN 	NUMBER,
			 p_trx_header_id	IN	NUMBER,
			 p_user_id 		IN	NUMBER,
			 p_fm_ser_num 		IN	VARCHAR2,
			 p_to_ser_num		IN	VARCHAR2,
			 p_item_id		IN      NUMBER,
			 p_org_id		IN 	NUMBER,
			 x_err_code		OUT NOCOPY	NUMBER,
		 	 x_err_message  	OUT NOCOPY	VARCHAR2) ;

 PROCEDURE INSERT_REASON_REF_INTO_MMTT(l_reason_id  IN Number  :=NULL,
p_reference  IN varchar2   :=NULL,
p_transaction_temp_id  In Number) ;



 PROCEDURE ENTER_REBUILD_DETAILS(p_rebuild_item_id   IN Number ,
 p_rebuild_job_name  IN OUT NOCOPY Varchar2 ,
 p_rebuild_activity_id  IN Number:=null,
 p_rebuild_serial_number  IN varchar2 :=null,
 P_transaction_temp_id  IN Number,
 p_organization_id   IN Number );


 -- Procedure to cancel allocations if a material is deleted
 -- Author : amondal


 PROCEDURE cancel_alloc_matl_del (p_api_version        IN       NUMBER,
                     p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
                     p_commit             IN       VARCHAR2 := fnd_api.g_false,
                     p_validation_level   IN       NUMBER:= fnd_api.g_valid_level_full,
                     p_wip_entity_id IN NUMBER,
                     p_operation_seq_num  IN NUMBER,
                     p_inventory_item_id  IN NUMBER,
                     p_wip_entity_type    IN NUMBER,
                     p_repetitive_schedule_id IN NUMBER DEFAULT NULL,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_data OUT NOCOPY VARCHAR2,
                     x_msg_count OUT NOCOPY     NUMBER);

  -- Procedure to cancel allocations if required quantity for a material is decreased
  -- Procedure to create allocations if required quantity for a material is increased
  -- Both cases are for Released Work Orders
  -- Author : amondal

 PROCEDURE comp_alloc_chng_qty(p_api_version        IN       NUMBER,
                              p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
                              p_commit             IN       VARCHAR2 := fnd_api.g_false,
                              p_validation_level   IN       NUMBER:= fnd_api.g_valid_level_full,
                              p_wip_entity_id IN NUMBER,
                              p_organization_id  IN NUMBER,
                              p_operation_seq_num  IN NUMBER,
                              p_inventory_item_id  IN NUMBER,
                              p_qty_required       IN NUMBER,
                              p_supply_subinventory  IN     VARCHAR2 DEFAULT NULL, --12.1 source sub project
                              p_supply_locator_id    IN     NUMBER DEFAULT NULL, --12.1 source sub project
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY     NUMBER);


  -- Procedure to create new allocations for a newly added material to a Released Work Order
  -- Author : amondal

 PROCEDURE comp_alloc_new_mat(p_api_version        IN       NUMBER,
                              p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
                              p_commit             IN       VARCHAR2 := fnd_api.g_false,
                              p_validation_level   IN       NUMBER:= fnd_api.g_valid_level_full,
                              p_wip_entity_id IN NUMBER,
                              p_organization_id  IN NUMBER,
                              p_operation_seq_num  IN NUMBER,
                              p_inventory_item_id  IN NUMBER,
                              p_qty_required       IN NUMBER,
                              p_supply_subinventory  IN     VARCHAR2 DEFAULT NULL, --12.1 source sub project
                              p_supply_locator_id    IN     NUMBER DEFAULT NULL, --12.1 source sub project
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY     NUMBER);

 -- Procedure to create allocations during Release of a work order
 -- Procedure to cancel allocations during Cancel of a work order
 -- author : amondal

 PROCEDURE alloc_at_release_cancel (p_api_version        IN       NUMBER,
                              p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
                              p_commit             IN       VARCHAR2 := fnd_api.g_false,
                              p_validation_level   IN       NUMBER:= fnd_api.g_valid_level_full,
                              p_wip_entity_id IN NUMBER,
                              p_organization_id  IN NUMBER,
                              p_status_type   IN NUMBER,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                             x_msg_count                 OUT NOCOPY     NUMBER);

FUNCTION get_tx_processor_mode(p_dummy IN boolean := false
)
return number;


END EAM_MATERIALISSUE_PVT;

/
