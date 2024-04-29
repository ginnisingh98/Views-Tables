--------------------------------------------------------
--  DDL for Package GR_ITEM_DISCLOSURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ITEM_DISCLOSURES_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIIDS.pls 115.4 2002/10/25 20:16:47 methomas ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
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
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
	              p_item_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_ITEM_DISCLOSURES_PKG;

 

/
