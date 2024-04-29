--------------------------------------------------------
--  DDL for Package Body CS_SYSTEMS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SYSTEMS_ALL_PKG" as
/* $Header: csxdcsb.pls 115.15 2003/02/28 18:56:18 epajaril ship $ */

/* ----------------------------------
   PRIVATE SECTION
   ---------------------------------- */

  PROCEDURE Check_Unique(X_Rowid 	IN VARCHAR2,
			 X_Name  	IN VARCHAR2,
			 X_Customer_ID	IN NUMBER,
			 X_Serial_Num	IN VARCHAR2) IS

  BEGIN
	null;
  END Check_Unique;


  --
  -- Enforce the single-tier only parent_child relationship
  -- This procedure is only called for systems that have a parent system
  --
  PROCEDURE Check_Parent_Child_Constraint(X_System_ID 		IN NUMBER,
				   	  X_Parent_System_ID 	IN NUMBER) IS

  BEGIN

	null;
  END Check_Parent_Child_Constraint;



/* ----------------------------------
   PUBLIC SECTION
   ---------------------------------- */

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
                        X_org_id                        IN NUMBER DEFAULT NULL) IS
  BEGIN
	null;
  END Insert_Row;


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
			X_config_system_type		IN VARCHAR2) IS

  BEGIN
	null;
  END Lock_Row;


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
			X_Org_id	        	IN NUMBER) IS
  BEGIN
	null;
  END Update_Row;


  PROCEDURE Delete_Row( X_Rowid 			IN VARCHAR2,
              		X_system_id			IN NUMBER,
			X_user_id			IN NUMBER,
			X_login_id			IN NUMBER) IS

  BEGIN

	null;

  END Delete_Row;


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
			X_config_system_type		IN VARCHAR2) IS
  BEGIN
	null;
  END Autocreate_Systems;


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
			X_Tech_Cont_Change_Flag		IN VARCHAR2) IS
  BEGIN
	null;
  END Autocreated_Systems_Update;

procedure ADD_LANGUAGE
is
begin
	null;
end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW (
                x_system_id    IN     NUMBER,
                x_name         IN     VARCHAR2,
                x_description  IN     VARCHAR2,
			 x_owner        IN     VARCHAR2
                        ) IS
BEGIN
	null;
END TRANSLATE_ROW;

END CS_SYSTEMS_ALL_PKG;


/
