--------------------------------------------------------
--  DDL for Package GR_TOXIC_SPECIES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_TOXIC_SPECIES_B_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHITSS.pls 115.6 2002/10/28 21:41:11 gkelly ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_toxic_species_code IN VARCHAR2,
/* Bug 1323951 28-Jan-2002 M. Thomas Added the following for Toxicity Calculation */
				  p_hierarchy_seq IN NUMBER,
/* Bug 1323951 28-Jan-2002 M. Thomas End of the changes  for Toxicity Calculation */
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY  VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_toxic_species_code IN VARCHAR2,
/* Bug 1323951 28-Jan-2002 M. Thomas Added the following for Toxicity Calculation */
				  p_hierarchy_seq IN NUMBER,
/* Bug 1323951 28-Jan-2002 M. Thomas End of the changes  for Toxicity Calculation */
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_toxic_species_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_toxic_species_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_toxic_species_code IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_toxic_species_code IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Check_Primary_Key
	   			 (p_toxic_species_code IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY  VARCHAR2,
				  x_key_exists OUT NOCOPY  VARCHAR2);
END GR_TOXIC_SPECIES_B_PKG;

 

/
