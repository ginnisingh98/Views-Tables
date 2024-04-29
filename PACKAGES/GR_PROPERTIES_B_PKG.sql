--------------------------------------------------------
--  DDL for Package GR_PROPERTIES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_PROPERTIES_B_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIPROS.pls 120.0.12010000.1 2008/07/30 07:13:07 appldev ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_property_id IN VARCHAR2,
				  p_property_type_indicator IN VARCHAR2,
				  p_length IN NUMBER,
				  p_precision IN NUMBER,
				  p_range_min IN NUMBER,
				  p_range_max IN NUMBER,
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
				  p_property_id IN VARCHAR2,
				  p_property_type_indicator IN VARCHAR2,
				  p_length IN NUMBER,
				  p_precision IN NUMBER,
				  p_range_min IN NUMBER,
				  p_range_max IN NUMBER,
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
				  p_property_id IN VARCHAR2,
				  p_property_type_indicator IN VARCHAR2,
				  p_length IN NUMBER,
				  p_precision IN NUMBER,
				  p_range_min IN NUMBER,
				  p_range_max IN NUMBER,
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
				  p_property_id IN VARCHAR2,
				  p_property_type_indicator IN VARCHAR2,
				  p_length IN NUMBER,
				  p_precision IN NUMBER,
				  p_range_min IN NUMBER,
				  p_range_max IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_property_id IN VARCHAR2,
				  p_property_type_indicator IN VARCHAR2,
				  p_length IN NUMBER,
				  p_precision IN NUMBER,
				  p_range_min IN NUMBER,
				  p_range_max IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_property_id IN VARCHAR2,
				  p_property_type_indicator IN VARCHAR2,
				  p_length IN NUMBER,
				  p_precision IN NUMBER,
				  p_range_min IN NUMBER,
				  p_range_max IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_property_id IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY  VARCHAR2,
				  x_key_exists OUT NOCOPY  VARCHAR2);
END GR_PROPERTIES_B_PKG;

/
