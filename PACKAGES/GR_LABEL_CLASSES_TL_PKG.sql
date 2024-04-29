--------------------------------------------------------
--  DDL for Package GR_LABEL_CLASSES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_LABEL_CLASSES_TL_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHILCTS.pls 120.1 2006/06/16 21:40:07 pbamb noship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_class_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
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
				  p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_class_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
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
				  p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_class_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
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
				  p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_class_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
	              p_label_class_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_class_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_class_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_label_class_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
	PROCEDURE translate_row (
				X_LABEL_CLASS_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_LABEL_CLASS_DESCRIPTION IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				);

	PROCEDURE load_row (
				X_LABEL_CLASS_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_LABEL_CLASS_DESCRIPTION IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				);
	/*Bug# 5237433 */
	PROCEDURE translate_row (
				X_LABEL_CLASS_CODE IN VARCHAR2
				,X_LABEL_CLASS_DESCRIPTION IN VARCHAR2
   	                        ,X_OWNER       IN VARCHAR2
				);

	PROCEDURE load_row (
				X_LABEL_CLASS_CODE IN VARCHAR2
				,X_LABEL_CLASS_DESCRIPTION IN VARCHAR2
   	                        ,X_OWNER       IN VARCHAR2
				);
	   PROCEDURE New_Language;

END GR_LABEL_CLASSES_TL_PKG;

 

/
