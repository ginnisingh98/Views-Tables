--------------------------------------------------------
--  DDL for Package Body CS_AUTOCREATE_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_AUTOCREATE_SYSTEMS_PKG" as
/* $Header: csxacssb.pls 115.8 2000/09/15 16:41:50 pkm ship   $ */
-- This package has one procedure AUTOCREATE

PROCEDURE AUTOCREATE
(
	p_customer_id				IN	NUMBER,
	p_name					IN   VARCHAR2 DEFAULT NULL,
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
)
IS

l_coterminate_day_month   VARCHAR2(6);
l_system_id  		NUMBER := NULL;
l_system_name  	VARCHAR2(50);
l_system_date		DATE ;
l_system_match		NUMBER;
/*
l_null_varchar 	VARCHAR2(50) := NULL;
l_null_number 		NUMBER := NULL;
*/
l_rowid			VARCHAR2(50) := NULL;
l_name_tbl		Name_Tbl_Type;

BEGIN

	SAVEPOINT Autocreate_Systems_PVT;

	SELECT sysdate INTO l_system_date FROM dual;

	-- Getting the Value for the coterminate_day_month for the current
	-- customer from HZ_CUST_ACCOUNTS table
	BEGIN

		SELECT coterminate_day_month
		INTO   l_coterminate_day_month
		FROM   hz_cust_accounts
		WHERE  cust_account_id = p_customer_id;
		--AND    org_id = FND_PROFILE.Value('ORG_ID');

	EXCEPTION WHEN NO_DATA_FOUND THEN
		FND_MESSAGE.SET_NAME('CS','CS_API_INVALID CUSTOMER');
		FND_MESSAGE.SET_TOKEN('CUSTOMER_ID',p_customer_id);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	END;

	IF p_name IS NOT NULL THEN
		-- this procedure has been called not to autocreate systems but to
		-- create a particular system with a particular name.
		l_system_name := p_name;
	END IF;

	FOR i IN 1..p_number_to_create LOOP
		/*
	    l_null_varchar := NULL;
	    l_null_number := NULL;
		*/

	    CS_SYSTEMS_ALL_PKG.Insert_Row(
				X_Rowid				=> l_rowid,
				X_system_id			=> l_system_id,
				X_last_update_date		=> sysdate,
				X_last_updated_by		=> FND_GLOBAL.USER_ID,
				X_creation_date		=> sysdate,
				X_created_by			=> FND_GLOBAL.USER_ID,
				X_last_update_login		=> FND_GLOBAL.LOGIN_ID,
				X_name				=> l_system_name,
				X_customer_id			=> p_customer_id,
				X_system_type_code		=> p_system_type_code,
				X_description			=> p_description,
				X_serial_number		=> NULL,
				X_parent_system_id		=> NULL,
				X_technical_contact_id	=> p_technical_contact_id,
				X_service_admin_contact_id => p_service_admin_contact_id,
				X_install_site_use_id	=> p_install_site_use_id,
				X_bill_to_contact_id	=> p_bill_to_contact_id,
				X_bill_to_site_use_id	=> p_bill_to_site_use_id,
				X_ship_to_site_use_id	=> p_ship_to_site_use_id,
				X_ship_to_contact_id	=> p_ship_to_contact_id,
				X_coterminate_day_month	=> l_coterminate_day_month,
				X_start_date_active		=> p_start_date_active,
				X_end_date_active		=> p_end_date_active,
				X_autocreated_from_system_id => null,
				X_attribute1			=> p_attribute1,
				X_attribute2			=> p_attribute2,
				X_attribute3			=> p_attribute3,
				X_attribute4			=> p_attribute4,
				X_attribute5			=> p_attribute5,
				X_attribute6			=> p_attribute6,
				X_attribute7			=> p_attribute7,
				X_attribute8			=> p_attribute8,
				X_attribute9			=> p_attribute9,
				X_attribute10			=> p_attribute10,
				X_attribute11			=> p_attribute11,
				X_attribute12			=> p_attribute12,
				X_attribute13			=> p_attribute13,
				X_attribute14			=> p_attribute14,
				X_attribute15			=> p_attribute15,
				X_context				=> p_context,
				X_config_system_type	=> p_config_system_type);
		l_name_tbl(i).system_id := l_system_id;
		l_name_tbl(i).name := l_system_name;
		l_system_name := NULL;
		l_system_id := NULL;
		l_rowid := NULL;


	END LOOP;

	x_name_tbl := l_name_tbl;

EXCEPTION WHEN Others THEN
		APP_EXCEPTION.RAISE_EXCEPTION;
		ROLLBACK TO Autocreate_Systems_PVT;
		RETURN;

END AUTOCREATE;  -- Ends the procedure

END CS_AUTOCREATE_SYSTEMS_PKG;

/
