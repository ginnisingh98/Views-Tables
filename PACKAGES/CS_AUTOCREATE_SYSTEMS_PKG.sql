--------------------------------------------------------
--  DDL for Package CS_AUTOCREATE_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_AUTOCREATE_SYSTEMS_PKG" AUTHID CURRENT_USER as
/* $Header: csxacsss.pls 115.6 2000/09/15 16:41:52 pkm ship   $ */

TYPE Name_Rec_Type IS RECORD
(
	system_id		NUMBER,
	name			VARCHAR2(50)
);

TYPE Name_Tbl_Type IS TABLE OF Name_Rec_Type
INDEX BY BINARY_INTEGER;

PROCEDURE AUTOCREATE
(
	p_customer_id				IN	NUMBER,
	p_name					IN 	VARCHAR2 DEFAULT NULL,
	p_description				IN	VARCHAR2 DEFAULT NULL,
	p_system_type_code			IN	VARCHAR2,
	p_number_to_create 			IN	NUMBER,
	p_install_site_use_id    	IN	NUMBER DEFAULT NULL,
	p_technical_contact_id   	IN	NUMBER DEFAULT NULL,
	p_service_admin_contact_id	IN	NUMBER DEFAULT NULL,
	p_ship_to_site_use_id		IN	NUMBER DEFAULT NULL,
	p_ship_to_contact_id		IN	NUMBER DEFAULT NULL,
	p_bill_to_site_use_id		IN	NUMBER DEFAULT NULL,
	p_bill_to_contact_id		IN	NUMBER DEFAULT NULL,
	p_config_system_type		IN	VARCHAR2 DEFAULT NULL,
	p_start_date_active  		IN	DATE DEFAULT NULL,
	p_end_date_active  	     	IN	DATE DEFAULT NULL,
	p_attribute1				IN	VARCHAR2 DEFAULT NULL,
	p_attribute2				IN	VARCHAR2 DEFAULT NULL,
	p_attribute3				IN	VARCHAR2 DEFAULT NULL,
	p_attribute4				IN	VARCHAR2 DEFAULT NULL,
	p_attribute5				IN	VARCHAR2 DEFAULT NULL,
	p_attribute6				IN	VARCHAR2 DEFAULT NULL,
	p_attribute7				IN	VARCHAR2 DEFAULT NULL,
	p_attribute8				IN	VARCHAR2 DEFAULT NULL,
	p_attribute9				IN	VARCHAR2 DEFAULT NULL,
	p_attribute10				IN	VARCHAR2 DEFAULT NULL,
	p_attribute11				IN	VARCHAR2 DEFAULT NULL,
	p_attribute12				IN	VARCHAR2 DEFAULT NULL,
	p_attribute13				IN	VARCHAR2 DEFAULT NULL,
	p_attribute14				IN	VARCHAR2 DEFAULT NULL,
	p_attribute15				IN	VARCHAR2 DEFAULT NULL,
	p_context					IN	VARCHAR2 DEFAULT NULL,
	x_name_tbl				OUT	Name_Tbl_Type
);

END CS_AUTOCREATE_SYSTEMS_PKG;

 

/
