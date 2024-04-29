--------------------------------------------------------
--  DDL for Package GR_ORGANIZATION_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ORGANIZATION_CONTACTS_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIORCS.pls 115.2 2002/10/28 17:00:00 methomas ship $*/
	   PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Foreign_Keys
	   			 (p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2);
	   PROCEDURE Check_Primary_Key
		  		 (p_orgn_code IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
END GR_ORGANIZATION_CONTACTS_PKG;

 

/