--------------------------------------------------------
--  DDL for Package EAM_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REQUIREMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: EAMMRTHS.pls 120.2 2005/09/22 23:12:35 grajan noship $ */

/************************************************
 * Default Values:				*
 * These are just indicative values. Actual	*
 * default values are in procedure spec.	*
 ************************************************/
Default_Repetitive_Schedule_Id	NUMBER := null;  -- No Repetitive Schedule
Default_MPS_Required_Quantity	NUMBER := null;
Default_MPS_Date_Required	DATE := null;

PROCEDURE Pre_Insert;

PROCEDURE Insert_Row   (X_row_id		IN OUT NOCOPY	VARCHAR2,
			X_inventory_item_id	IN 	NUMBER,
  			X_organization_id	IN	NUMBER,
  			X_wip_entity_id		IN	NUMBER,
  			X_operation_seq_num	IN	NUMBER,
  			X_repetitive_schedule_id IN	NUMBER	default null,
  			X_last_update_date	IN	DATE,
  			X_last_updated_by	IN	NUMBER,
  			X_creation_date		IN	DATE,
  			X_created_by		IN	NUMBER,
  			X_last_update_login	IN	NUMBER,
  			X_department_id		IN	NUMBER,
  			X_wip_supply_type	IN	NUMBER,
  			X_date_required		IN	DATE,
  			X_required_quantity	IN	NUMBER,
  			X_quantity_issued	IN	NUMBER,
  			X_quantity_per_assembly	IN	NUMBER,
  			X_comments		IN	VARCHAR2,
  			X_supply_subinventory	IN	VARCHAR2,
  			X_supply_locator_id	IN	NUMBER,
  			X_mrp_net_flag		IN	NUMBER,
  			X_mps_required_quantity	IN	NUMBER	default null,
  			X_mps_date_required	IN	DATE	default null,
  			X_attribute_category	IN	VARCHAR2,
  			X_attribute1		IN	VARCHAR2,
  			X_attribute2		IN	VARCHAR2,
  			X_attribute3		IN	VARCHAR2,
  			X_attribute4		IN	VARCHAR2,
  			X_attribute5		IN	VARCHAR2,
  			X_attribute6		IN	VARCHAR2,
  			X_attribute7		IN	VARCHAR2,
  			X_attribute8		IN	VARCHAR2,
  			X_attribute9		IN	VARCHAR2,
  			X_attribute10		IN	VARCHAR2,
  			X_attribute11		IN	VARCHAR2,
  			X_attribute12		IN	VARCHAR2,
  			X_attribute13		IN	VARCHAR2,
  			X_attribute14		IN	VARCHAR2,
  			X_attribute15		IN	VARCHAR2,
			X_auto_request_material IN      VARCHAR2,
			X_L_EAM_MAT_REC	 OUT NOCOPY 	EAM_PROCESS_WO_PUB.eam_mat_req_rec_type,
			X_material_shortage_flag	 OUT NOCOPY 	VARCHAR2,
			X_material_shortage_check_date	 OUT NOCOPY 	DATE
			);



PROCEDURE Update_Row   (X_row_id		IN	VARCHAR2,
			X_inventory_item_id	IN 	NUMBER,
  			X_organization_id	IN	NUMBER,
  			X_wip_entity_id		IN	NUMBER,
  			X_operation_seq_num	IN	NUMBER,
  			X_repetitive_schedule_id IN	NUMBER	default null,
  			X_last_update_date	IN	DATE,
  			X_last_updated_by	IN	NUMBER,
  			X_last_update_login	IN	NUMBER,
  			X_department_id		IN	NUMBER,
  			X_wip_supply_type	IN	NUMBER,
  			X_date_required		IN	DATE,
  			X_required_quantity	IN	NUMBER,
  			X_quantity_issued	IN	NUMBER,
  			X_quantity_per_assembly	IN	NUMBER,
  			X_comments		IN	VARCHAR2,
  			X_supply_subinventory	IN	VARCHAR2,
  			X_supply_locator_id	IN	NUMBER,
  			X_mrp_net_flag		IN	NUMBER,
  			X_mps_required_quantity	IN	NUMBER	default null,
  			X_mps_date_required	IN	DATE	default null,
  			X_attribute_category	IN	VARCHAR2,
  			X_attribute1		IN	VARCHAR2,
  			X_attribute2		IN	VARCHAR2,
  			X_attribute3		IN	VARCHAR2,
  			X_attribute4		IN	VARCHAR2,
  			X_attribute5		IN	VARCHAR2,
  			X_attribute6		IN	VARCHAR2,
  			X_attribute7		IN	VARCHAR2,
  			X_attribute8		IN	VARCHAR2,
  			X_attribute9		IN	VARCHAR2,
  			X_attribute10		IN	VARCHAR2,
  			X_attribute11		IN	VARCHAR2,
  			X_attribute12		IN	VARCHAR2,
  			X_attribute13		IN	VARCHAR2,
  			X_attribute14		IN	VARCHAR2,
  			X_attribute15		IN	VARCHAR2,
  			X_auto_request_material IN      VARCHAR2,
			X_L_EAM_MAT_REC	 OUT NOCOPY  	EAM_PROCESS_WO_PUB.eam_mat_req_rec_type,
			X_material_shortage_flag	 OUT NOCOPY 	VARCHAR2,
			X_material_shortage_check_date	 OUT NOCOPY 	DATE
			);


PROCEDURE Lock_Row(	X_row_id		IN	VARCHAR2,
			X_inventory_item_id	IN 	NUMBER,
  			X_organization_id	IN	NUMBER,
  			X_wip_entity_id		IN	NUMBER,
  			X_operation_seq_num	IN	NUMBER,
  			X_department_id		IN	NUMBER,
  			X_wip_supply_type	IN	NUMBER,
  			X_date_required		IN	DATE,
  			X_required_quantity	IN	NUMBER,
  			X_quantity_issued	IN	NUMBER,
  			X_quantity_per_assembly	IN	NUMBER,
  			X_comments		IN	VARCHAR2,
  			X_supply_subinventory	IN	VARCHAR2,
  			X_supply_locator_id	IN	NUMBER,
  			X_mrp_net_flag		IN	NUMBER,
  			X_attribute_category	IN	VARCHAR2,
  			X_attribute1		IN	VARCHAR2,
  			X_attribute2		IN	VARCHAR2,
  			X_attribute3		IN	VARCHAR2,
  			X_attribute4		IN	VARCHAR2,
  			X_attribute5		IN	VARCHAR2,
  			X_attribute6		IN	VARCHAR2,
  			X_attribute7		IN	VARCHAR2,
  			X_attribute8		IN	VARCHAR2,
  			X_attribute9		IN	VARCHAR2,
  			X_attribute10		IN	VARCHAR2,
  			X_attribute11		IN	VARCHAR2,
  			X_attribute12		IN	VARCHAR2,
  			X_attribute13		IN	VARCHAR2,
  			X_attribute14		IN	VARCHAR2,
  			X_attribute15		IN	VARCHAR2,
  			X_auto_request_material IN      VARCHAR2);


PROCEDURE Delete_Row(X_row_id		IN	VARCHAR2,
		     X_material_shortage_flag	 OUT NOCOPY 	VARCHAR2,
		     X_material_shortage_check_date	 OUT NOCOPY 	DATE);


--
-- baroy - API to delete a requirements row from SS
--
PROCEDURE Delete_Row_SS(
  p_api_version             IN    NUMBER,
  p_init_msg_list           IN    VARCHAR2,
  p_commit                  IN    VARCHAR2,
  p_validate_only           IN    VARCHAR2,
  p_record_version_number   IN    NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  p_inventory_item_id	    IN 	  NUMBER,
  p_organization_id	        IN	  NUMBER,
  p_wip_entity_id		    IN	  NUMBER,
  p_operation_seq_num       IN    NUMBER);

-- Procuedure to delete a description based direct item

PROCEDURE Delete_Desc_Row_SS(
  p_api_version             IN    NUMBER,
  p_init_msg_list           IN    VARCHAR2,
  p_commit                  IN    VARCHAR2,
  p_validate_only           IN    VARCHAR2,
  p_record_version_number   IN    NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  p_di_sequence_id	    IN 	  NUMBER,
  p_organization_id	    IN	  NUMBER,
  p_wip_entity_id	    IN	  NUMBER,
  p_operation_seq_num       IN    NUMBER);


END EAM_REQUIREMENTS_PKG;

 

/
