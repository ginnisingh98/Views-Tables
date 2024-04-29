--------------------------------------------------------
--  DDL for Package GR_INGRED_CONC_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_INGRED_CONC_DETAILS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHINCDS.pls 120.0 2005/07/08 11:23:29 methomas noship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
                                  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_level_hierarchy_code IN NUMBER,
				  p_work_concentration IN NUMBER,
				  p_uom IN VARCHAR2,
				  p_quantity IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
                                  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_level_hierarchy_code IN NUMBER,
				  p_work_concentration IN NUMBER,
				  p_uom IN VARCHAR2,
				  p_quantity IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
                                  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_level_hierarchy_code IN NUMBER,
				  p_work_concentration IN NUMBER,
				  p_uom IN VARCHAR2,
				  p_quantity IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
                                  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_level_hierarchy_code IN NUMBER,
				  p_work_concentration IN NUMBER,
				  p_uom IN VARCHAR2,
				  p_quantity IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
		      p_called_by_form IN VARCHAR2,
                      p_organization_id IN NUMBER,
		      p_inventory_item_id IN NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
		      x_oracle_error OUT NOCOPY NUMBER,
		      x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_level_hierarchy_code IN NUMBER,
				  p_work_concentration IN NUMBER,
				  p_uom IN VARCHAR2,
				  p_quantity IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
                                  p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_level_hierarchy_code IN NUMBER,
				  p_work_concentration IN NUMBER,
				  p_uom IN VARCHAR2,
				  p_quantity IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_organization_id IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_ingredient_item_id IN NUMBER,
				  p_source_item_id IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_INGRED_CONC_DETAILS_PKG;

 

/
