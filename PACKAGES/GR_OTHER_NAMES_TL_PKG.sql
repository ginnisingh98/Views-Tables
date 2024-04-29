--------------------------------------------------------
--  DDL for Package GR_OTHER_NAMES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_OTHER_NAMES_TL_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIONTS.pls 115.5 2002/10/28 17:02:51 methomas ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Add_Language
	             (p_commit IN VARCHAR2,
	              p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
/*
**		p_delete_option has one of three values.
**	    'I' - Delete all rows for the item in p_item_code.
**		'O' - Delete all rows for the specified organisation in p_orgn_code.
**		'B' - Delete all rows for the specified item and orgn code.
*/
	   PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
	              p_delete_option IN VARCHAR2,
	              p_item_code IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_item_code IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
	   PROCEDURE New_Language;
END GR_OTHER_NAMES_TL_PKG;

 

/
