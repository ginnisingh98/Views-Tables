--------------------------------------------------------
--  DDL for Package GR_MAIN_HEADINGS_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_MAIN_HEADINGS_TL_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIMHTS.pls 115.4 2002/10/28 16:45:33 methomas ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_main_heading_description IN VARCHAR2,
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
				  p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_main_heading_description IN VARCHAR2,
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
				  p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_main_heading_description IN VARCHAR2,
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
				  p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_main_heading_description IN VARCHAR2,
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
	              p_main_heading_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_main_heading_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_main_heading_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_main_heading_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);

	PROCEDURE translate_row (
				X_MAIN_HEADING_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_MAIN_HEADING_DESCRIPTION IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				);

	PROCEDURE load_row (
				X_MAIN_HEADING_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_MAIN_HEADING_DESCRIPTION IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				);
	PROCEDURE New_Language;
END GR_MAIN_HEADINGS_TL_PKG;

 

/
