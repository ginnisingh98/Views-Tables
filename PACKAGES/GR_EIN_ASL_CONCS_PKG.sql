--------------------------------------------------------
--  DDL for Package GR_EIN_ASL_CONCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_EIN_ASL_CONCS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIEICS.pls 115.3 2002/10/29 16:31:35 mgrosser noship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Rows
	   		         (p_commit IN VARCHAR2,
		 		  p_called_by_form IN VARCHAR2,
				  p_european_index_number IN VARCHAR2,
			          x_return_status OUT NOCOPY VARCHAR2,
	   			  x_oracle_error OUT NOCOPY NUMBER,
		      		  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_european_index_number IN VARCHAR2,
				  p_hazard_classification_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
	   			 (p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_EIN_ASL_CONCS_PKG;

 

/
