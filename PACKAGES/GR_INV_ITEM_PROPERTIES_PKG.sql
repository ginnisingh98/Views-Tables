--------------------------------------------------------
--  DDL for Package GR_INV_ITEM_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_INV_ITEM_PROPERTIES_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIIIPS.pls 120.0 2005/07/08 11:10:34 methomas noship $*/
   PROCEDURE Insert_Row
        (p_commit             IN VARCHAR2,
         p_called_by_form     IN VARCHAR2,
         p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_sequence_number    IN NUMBER,
         p_property_id        IN VARCHAR2,
         p_label_code         IN VARCHAR2,
         p_number_value       IN NUMBER,
         p_alpha_value        IN VARCHAR2,
         p_date_value         IN DATE,
         p_created_by         IN NUMBER,
         p_creation_date      IN DATE,
         p_last_updated_by    IN NUMBER,
         p_last_update_date   IN DATE,
         p_last_update_login  IN NUMBER,
         x_rowid             OUT NOCOPY VARCHAR2,
         x_return_status     OUT NOCOPY VARCHAR2,
         x_oracle_error      OUT NOCOPY NUMBER,
         x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Update_Row
        (p_commit             IN VARCHAR2,
         p_called_by_form     IN VARCHAR2,
         p_rowid              IN VARCHAR2,
         p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_sequence_number    IN NUMBER,
         p_property_id        IN VARCHAR2,
         p_label_code         IN VARCHAR2,
         p_number_value       IN NUMBER,
         p_alpha_value        IN VARCHAR2,
         p_date_value         IN DATE,
         p_created_by         IN NUMBER,
         p_creation_date      IN DATE,
         p_last_updated_by    IN NUMBER,
         p_last_update_date   IN DATE,
         p_last_update_login  IN NUMBER,
         x_return_status     OUT NOCOPY VARCHAR2,
         x_oracle_error      OUT NOCOPY NUMBER,
         x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Lock_Row
        (p_commit             IN VARCHAR2,
         p_called_by_form     IN VARCHAR2,
         p_rowid              IN VARCHAR2,
         p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_sequence_number    IN NUMBER,
         p_property_id        IN VARCHAR2,
         p_label_code         IN VARCHAR2,
         p_number_value       IN NUMBER,
         p_alpha_value        IN VARCHAR2,
         p_date_value         IN DATE,
         p_created_by         IN NUMBER,
         p_creation_date      IN DATE,
         p_last_updated_by    IN NUMBER,
         p_last_update_date   IN DATE,
         p_last_update_login  IN NUMBER,
         x_return_status     OUT NOCOPY VARCHAR2,
         x_oracle_error      OUT NOCOPY NUMBER,
         x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Delete_Row
        (p_commit             IN VARCHAR2,
         p_called_by_form     IN VARCHAR2,
         p_rowid              IN VARCHAR2,
         p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_sequence_number    IN NUMBER,
         p_property_id        IN VARCHAR2,
         p_label_code         IN VARCHAR2,
         p_number_value       IN NUMBER,
         p_alpha_value        IN VARCHAR2,
         p_date_value         IN DATE,
         p_created_by         IN NUMBER,
         p_creation_date      IN DATE,
         p_last_updated_by    IN NUMBER,
         p_last_update_date   IN DATE,
         p_last_update_login  IN NUMBER,
         x_return_status     OUT NOCOPY VARCHAR2,
         x_oracle_error      OUT NOCOPY NUMBER,
         x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Delete_Rows
        (p_commit             IN VARCHAR2,
         p_called_by_form     IN VARCHAR2,
         p_delete_option      IN VARCHAR2,
         p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_label_code         IN VARCHAR2,
         x_return_status     OUT NOCOPY VARCHAR2,
         x_oracle_error      OUT NOCOPY NUMBER,
         x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Check_Foreign_Keys
        (p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_sequence_number    IN NUMBER,
         p_property_id        IN VARCHAR2,
         p_label_code         IN VARCHAR2,
         p_number_value       IN NUMBER,
         p_alpha_value        IN VARCHAR2,
         p_date_value         IN DATE,
         x_return_status     OUT NOCOPY VARCHAR2,
         x_oracle_error      OUT NOCOPY NUMBER,
         x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Check_Integrity
	(p_called_by_form     IN VARCHAR2,
         p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
	 p_sequence_number    IN NUMBER,
	 p_property_id        IN VARCHAR2,
	 p_label_code         IN VARCHAR2,
	 p_number_value       IN NUMBER,
	 p_alpha_value        IN VARCHAR2,
	 p_date_value         IN DATE,
	 x_return_status     OUT NOCOPY VARCHAR2,
	 x_oracle_error      OUT NOCOPY NUMBER,
	 x_msg_data          OUT NOCOPY VARCHAR2);
   PROCEDURE Check_Primary_Key
 	(p_organization_id    IN NUMBER,
         p_inventory_item_id  IN NUMBER,
         p_label_code         IN VARCHAR2,
         p_property_id        IN VARCHAR2,
         p_called_by_form     IN VARCHAR2,
         x_rowid             OUT NOCOPY VARCHAR2,
         x_key_exists        OUT NOCOPY VARCHAR2);
END GR_INV_ITEM_PROPERTIES_PKG;

 

/
