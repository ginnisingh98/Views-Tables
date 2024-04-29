--------------------------------------------------------
--  DDL for Package CS_SYSTEMS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SYSTEMS_ALL_PKG" AUTHID CURRENT_USER as
/* $Header: csxdcss.pls 115.8 2003/02/28 18:57:26 epajaril ship $ */

  PROCEDURE Insert_Row(	X_Rowid                 	IN OUT VARCHAR2,
              		X_system_id			IN OUT NUMBER,
              		X_last_update_date		IN DATE,
              		X_last_updated_by		IN NUMBER,
              		X_creation_date			IN DATE,
              		X_created_by			IN NUMBER,
              		X_last_update_login		IN NUMBER,
              		X_name				IN OUT VARCHAR2,
              		X_customer_id			IN NUMBER,
              		X_system_type_code		IN VARCHAR2,
              		X_description			IN VARCHAR2,
              		X_serial_number			IN VARCHAR2,
              		X_parent_system_id		IN NUMBER,
              		X_technical_contact_id		IN NUMBER,
              		X_service_admin_contact_id	IN NUMBER,
              		X_install_site_use_id		IN NUMBER,
              		X_bill_to_contact_id		IN NUMBER,
              		X_bill_to_site_use_id		IN NUMBER,
              		X_ship_to_site_use_id		IN NUMBER,
              		X_ship_to_contact_id		IN NUMBER,
              		X_coterminate_day_month		IN VARCHAR2,
              		X_start_date_active		IN DATE,
              		X_end_date_active		IN DATE,
              		X_autocreated_from_system_id	IN NUMBER,
              		X_attribute1			IN VARCHAR2,
              		X_attribute2			IN VARCHAR2,
              		X_attribute3			IN VARCHAR2,
              		X_attribute4			IN VARCHAR2,
              		X_attribute5			IN VARCHAR2,
              		X_attribute6			IN VARCHAR2,
              		X_attribute7			IN VARCHAR2,
              		X_attribute8			IN VARCHAR2,
              		X_attribute9			IN VARCHAR2,
              		X_attribute10			IN VARCHAR2,
              		X_attribute11			IN VARCHAR2,
              		X_attribute12			IN VARCHAR2,
              		X_attribute13			IN VARCHAR2,
              		X_attribute14			IN VARCHAR2,
              		X_attribute15			IN VARCHAR2,
              		X_context			IN VARCHAR2,
			X_config_system_type		IN VARCHAR2,
                        X_org_id                        IN NUMBER DEFAULT NULL);


  PROCEDURE Lock_Row(	X_Rowid                 	IN VARCHAR2,
              		X_system_id			IN NUMBER,
              		X_last_update_date		IN DATE,
              		X_last_updated_by		IN NUMBER,
              		X_creation_date			IN DATE,
              		X_created_by			IN NUMBER,
              		X_last_update_login		IN NUMBER,
              		X_name				IN VARCHAR2,
              		X_customer_id			IN NUMBER,
              		X_system_type_code		IN VARCHAR2,
              		X_description			IN VARCHAR2,
              		X_serial_number			IN VARCHAR2,
              		X_parent_system_id		IN NUMBER,
              		X_technical_contact_id		IN NUMBER,
              		X_service_admin_contact_id	IN NUMBER,
              		X_install_site_use_id		IN NUMBER,
              		X_bill_to_contact_id		IN NUMBER,
              		X_bill_to_site_use_id		IN NUMBER,
              		X_ship_to_site_use_id		IN NUMBER,
              		X_ship_to_contact_id		IN NUMBER,
              		X_coterminate_day_month		IN VARCHAR2,
              		X_start_date_active		IN DATE,
              		X_end_date_active		IN DATE,
              		X_autocreated_from_system_id	IN NUMBER,
              		X_attribute1			IN VARCHAR2,
              		X_attribute2			IN VARCHAR2,
              		X_attribute3			IN VARCHAR2,
              		X_attribute4			IN VARCHAR2,
              		X_attribute5			IN VARCHAR2,
              		X_attribute6			IN VARCHAR2,
              		X_attribute7			IN VARCHAR2,
              		X_attribute8			IN VARCHAR2,
              		X_attribute9			IN VARCHAR2,
              		X_attribute10			IN VARCHAR2,
              		X_attribute11			IN VARCHAR2,
              		X_attribute12			IN VARCHAR2,
              		X_attribute13			IN VARCHAR2,
              		X_attribute14			IN VARCHAR2,
              		X_attribute15			IN VARCHAR2,
              		X_context			IN VARCHAR2,
			X_config_system_type		IN VARCHAR2);


  PROCEDURE Update_Row(	X_Rowid                 	IN VARCHAR2,
              		X_system_id			IN NUMBER,
              		X_last_update_date		IN DATE,
              		X_last_updated_by		IN NUMBER,
              		X_creation_date			IN DATE,
              		X_created_by			IN NUMBER,
              		X_last_update_login		IN NUMBER,
              		X_name				IN VARCHAR2,
              		X_customer_id			IN NUMBER,
              		X_system_type_code		IN VARCHAR2,
              		X_description			IN VARCHAR2,
              		X_serial_number			IN VARCHAR2,
              		X_parent_system_id		IN NUMBER,
              		X_technical_contact_id		IN NUMBER,
              		X_service_admin_contact_id	IN NUMBER,
              		X_install_site_use_id		IN NUMBER,
              		X_bill_to_contact_id		IN NUMBER,
              		X_bill_to_site_use_id		IN NUMBER,
              		X_ship_to_site_use_id		IN NUMBER,
              		X_ship_to_contact_id		IN NUMBER,
              		X_coterminate_day_month		IN VARCHAR2,
              		X_start_date_active		IN DATE,
              		X_end_date_active		IN DATE,
              		X_autocreated_from_system_id	IN NUMBER,
              		X_attribute1			IN VARCHAR2,
              		X_attribute2			IN VARCHAR2,
              		X_attribute3			IN VARCHAR2,
              		X_attribute4			IN VARCHAR2,
              		X_attribute5			IN VARCHAR2,
              		X_attribute6			IN VARCHAR2,
              		X_attribute7			IN VARCHAR2,
              		X_attribute8			IN VARCHAR2,
              		X_attribute9			IN VARCHAR2,
              		X_attribute10			IN VARCHAR2,
              		X_attribute11			IN VARCHAR2,
              		X_attribute12			IN VARCHAR2,
              		X_attribute13			IN VARCHAR2,
              		X_attribute14			IN VARCHAR2,
              		X_attribute15			IN VARCHAR2,
              		X_context			IN VARCHAR2,
			X_config_system_type		IN VARCHAR2,
			X_Install_Site_Use_ID_Old	IN NUMBER,
			X_Technical_Contact_ID_Old	IN NUMBER,
			X_Service_Admin_Contact_ID_Old	IN NUMBER,
			X_Bill_To_Site_Use_ID_Old	IN NUMBER,
			X_Bill_To_Contact_ID_Old	IN NUMBER,
			X_Ship_To_Site_Use_ID_Old	IN NUMBER,
			X_Ship_To_Contact_ID_Old	IN NUMBER,
			X_Tech_Cont_Change_Flag		IN VARCHAR2,
			X_Bill_To_Cont_Change_Flag	IN VARCHAR2,
			X_Ship_To_Cont_Change_Flag	IN VARCHAR2,
			X_Serv_Admin_Cont_Change_Flag	IN VARCHAR2,
			X_Bill_To_Site_Use_Change_Flag	IN VARCHAR2,
			X_Ship_To_Site_Use_Change_Flag	IN VARCHAR2,
			Terminate_CPS_Flag		IN VARCHAR2,
		    	System_Decision_Window_Code	IN VARCHAR2,
			CP_Term_Status_ID		IN NUMBER,
                        X_org_id                        IN NUMBER DEFAULT NULL);


  PROCEDURE Delete_Row( X_Rowid 			IN VARCHAR2,
              		X_system_id			IN NUMBER,
			X_user_id			IN NUMBER,
			X_login_id			IN NUMBER);


  PROCEDURE Autocreate_Systems(
			Systems_To_Create		IN NUMBER,
              		X_system_id			IN NUMBER,
              		X_user_id			IN NUMBER,
              		X_login_id			IN NUMBER,
              		X_customer_id			IN NUMBER,
              		X_system_type_code		IN VARCHAR2,
              		X_description			IN VARCHAR2,
              		X_parent_system_id		IN NUMBER,
              		X_technical_contact_id		IN NUMBER,
              		X_service_admin_contact_id	IN NUMBER,
              		X_install_site_use_id		IN NUMBER,
              		X_bill_to_contact_id		IN NUMBER,
              		X_bill_to_site_use_id		IN NUMBER,
              		X_ship_to_site_use_id		IN NUMBER,
              		X_ship_to_contact_id		IN NUMBER,
              		X_coterminate_day_month		IN VARCHAR2,
              		X_start_date_active		IN DATE,
              		X_end_date_active		IN DATE,
              		X_attribute1			IN VARCHAR2,
              		X_attribute2			IN VARCHAR2,
              		X_attribute3			IN VARCHAR2,
              		X_attribute4			IN VARCHAR2,
              		X_attribute5			IN VARCHAR2,
              		X_attribute6			IN VARCHAR2,
              		X_attribute7			IN VARCHAR2,
              		X_attribute8			IN VARCHAR2,
              		X_attribute9			IN VARCHAR2,
              		X_attribute10			IN VARCHAR2,
              		X_attribute11			IN VARCHAR2,
              		X_attribute12			IN VARCHAR2,
              		X_attribute13			IN VARCHAR2,
              		X_attribute14			IN VARCHAR2,
              		X_attribute15			IN VARCHAR2,
              		X_context			IN VARCHAR2,
			X_config_system_type		IN VARCHAR2);



  PROCEDURE Autocreated_Systems_Update(
			X_Rowid                 	IN VARCHAR2,
              		X_system_id			IN NUMBER,
              		X_last_update_date		IN DATE,
              		X_last_updated_by		IN NUMBER,
              		X_creation_date			IN DATE,
              		X_created_by			IN NUMBER,
              		X_last_update_login		IN NUMBER,
              		X_name				IN VARCHAR2,
              		X_customer_id			IN NUMBER,
              		X_system_type_code		IN VARCHAR2,
              		X_description			IN VARCHAR2,
              		X_serial_number			IN VARCHAR2,
              		X_parent_system_id		IN NUMBER,
              		X_technical_contact_id		IN NUMBER,
              		X_service_admin_contact_id	IN NUMBER,
              		X_install_site_use_id		IN NUMBER,
              		X_bill_to_contact_id		IN NUMBER,
              		X_bill_to_site_use_id		IN NUMBER,
              		X_ship_to_site_use_id		IN NUMBER,
              		X_ship_to_contact_id		IN NUMBER,
              		X_coterminate_day_month		IN VARCHAR2,
              		X_start_date_active		IN DATE,
              		X_end_date_active		IN DATE,
              		X_autocreated_from_system_id	IN NUMBER,
              		X_attribute1			IN VARCHAR2,
              		X_attribute2			IN VARCHAR2,
              		X_attribute3			IN VARCHAR2,
              		X_attribute4			IN VARCHAR2,
              		X_attribute5			IN VARCHAR2,
              		X_attribute6			IN VARCHAR2,
              		X_attribute7			IN VARCHAR2,
              		X_attribute8			IN VARCHAR2,
              		X_attribute9			IN VARCHAR2,
              		X_attribute10			IN VARCHAR2,
              		X_attribute11			IN VARCHAR2,
              		X_attribute12			IN VARCHAR2,
              		X_attribute13			IN VARCHAR2,
              		X_attribute14			IN VARCHAR2,
              		X_attribute15			IN VARCHAR2,
              		X_context			IN VARCHAR2,
			X_config_system_type		IN VARCHAR2,
			X_Install_Site_Use_ID_Old	IN NUMBER,
			X_Technical_Contact_ID_Old	IN NUMBER,
			X_Tech_Cont_Change_Flag		IN VARCHAR2);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW
			 (
        x_system_id    IN     NUMBER,
        x_name         IN     VARCHAR2,
        x_description  IN     VARCHAR2,
        x_owner        IN     VARCHAR2
                );

END CS_SYSTEMS_ALL_PKG;

 

/