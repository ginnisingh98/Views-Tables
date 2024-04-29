--------------------------------------------------------
--  DDL for Package GR_RISK_COMBINATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_RISK_COMBINATIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIRCS.pls 115.2 2002/10/28 16:15:09 gkelly ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_combination_sequence IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
				  p_combination_group_number IN NUMBER,
				  p_risk_phrase_code_combo IN VARCHAR2,
				  p_display_order IN NUMBER,
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
				  p_combination_sequence IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
				  p_combination_group_number IN NUMBER,
				  p_risk_phrase_code_combo IN VARCHAR2,
				  p_display_order IN NUMBER,
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
				  p_combination_sequence IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
				  p_combination_group_number IN NUMBER,
				  p_risk_phrase_code_combo IN VARCHAR2,
				  p_display_order IN NUMBER,
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
				  p_combination_sequence IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
				  p_combination_group_number IN NUMBER,
				  p_risk_phrase_code_combo IN VARCHAR2,
				  p_display_order IN NUMBER,
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
	              p_risk_phrase_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
				 (p_combination_sequence IN NUMBER,
	   			  p_risk_phrase_code IN VARCHAR2,
				  p_combination_group_number IN NUMBER,
				  p_risk_phrase_code_combo IN VARCHAR2,
				  p_display_order IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_combination_sequence IN NUMBER,
	   			  p_risk_phrase_code IN VARCHAR2,
				  p_combination_group_number IN NUMBER,
				  p_risk_phrase_code_combo IN VARCHAR2,
				  p_display_order IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
		  PROCEDURE Check_Primary_Key
		  		 (p_combination_sequence IN NUMBER,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_RISK_COMBINATIONS_PKG;

 

/
