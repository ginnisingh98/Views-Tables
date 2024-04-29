--------------------------------------------------------
--  DDL for Package GR_EXPOSURE_AUTHS_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_EXPOSURE_AUTHS_TL_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIEATS.pls 115.6 2002/10/29 20:42:23 mgrosser ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_exposure_authority_desc IN VARCHAR2,
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
				  p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_exposure_authority_desc IN VARCHAR2,
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
				  p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_exposure_authority_desc IN VARCHAR2,
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
				  p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_exposure_authority_desc IN VARCHAR2,
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
	              p_exposure_authority_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_exposure_authority_desc IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_exposure_authority_desc IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_exposure_authority_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
	PROCEDURE translate_row (
				X_EXPOSURE_AUTHORITY_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_EXPOSURE_AUTHORITY_DESC IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				);

	PROCEDURE load_row (
				X_EXPOSURE_AUTHORITY_CODE IN VARCHAR2
				,X_LANGUAGE IN VARCHAR2
				,X_EXPOSURE_AUTHORITY_DESC IN VARCHAR2
				,X_SOURCE_LANG IN VARCHAR2
				);


  procedure NEW_LANGUAGE;

END GR_EXPOSURE_AUTHS_TL_PKG;

 

/
