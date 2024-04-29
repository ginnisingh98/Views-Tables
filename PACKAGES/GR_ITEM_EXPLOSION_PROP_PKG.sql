--------------------------------------------------------
--  DDL for Package GR_ITEM_EXPLOSION_PROP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ITEM_EXPLOSION_PROP_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIEPS.pls 120.0 2005/07/08 11:03:00 methomas noship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_actual_hazard IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_actual_hazard IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_actual_hazard IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_actual_hazard IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_actual_hazard IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_actual_hazard IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
		  PROCEDURE Check_Primary_Key
		  		 (p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_ITEM_EXPLOSION_PROP_PKG;

 

/
