--------------------------------------------------------
--  DDL for Package GR_ITEM_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ITEM_PROPERTIES_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIIPS.pls 115.6 2002/10/24 21:26:20 gkelly ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_property_id IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_number_value IN NUMBER,
				  p_alpha_value VARCHAR2,
				  p_date_value IN DATE,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_print_tech_parm IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_property_id IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_number_value IN NUMBER,
				  p_alpha_value VARCHAR2,
				  p_date_value IN DATE,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_print_tech_parm IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_property_id IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_number_value IN NUMBER,
				  p_alpha_value VARCHAR2,
				  p_date_value IN DATE,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_print_tech_parm IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_property_id IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_number_value IN NUMBER,
				  p_alpha_value VARCHAR2,
				  p_date_value IN DATE,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_print_tech_parm IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_delete_option IN VARCHAR2,
				  p_item_code IN VARCHAR2,
	              p_label_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_item_code IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_property_id IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_number_value IN NUMBER,
				  p_alpha_value VARCHAR2,
				  p_date_value IN DATE,
				  p_print_tech_parm IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_item_code IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_property_id IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_number_value IN NUMBER,
				  p_alpha_value VARCHAR2,
				  p_date_value IN DATE,
				  p_print_tech_parm IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_item_code IN VARCHAR2,
		  		  p_label_code IN VARCHAR2,
				  p_property_id IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_ITEM_PROPERTIES_PKG;

 

/
