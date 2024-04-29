--------------------------------------------------------
--  DDL for Package Body OZF_SD_CUSTOMER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_CUSTOMER_PKG" AS
/* $Header: ozftcdtb.pls 120.1 2008/01/03 06:21:48 bkunjan noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_SD_CUSTOMER_PKG';
G_FILE_NAME CONSTANT VARCHAR2(15) := 'ozftcdtb.pls';

PROCEDURE Insert_Row(
    p_request_customer_id        NUMBER,
    p_request_header_id      	 NUMBER,
    p_cust_account_id        	 NUMBER,
    p_party_id               	 NUMBER,
    p_site_use_id            	 NUMBER,
    p_cust_usage_code	         VARCHAR2,
    p_security_group_id      	 NUMBER,
    p_creation_date          	 DATE,
    p_created_by             	 NUMBER,
    p_last_update_date       	 DATE,
    p_last_updated_by        	 NUMBER,
    p_last_update_login      	 NUMBER,
    p_object_version_number  	 NUMBER,
    p_attribute_category     	 VARCHAR2,
    p_attribute1             	 VARCHAR2,
    p_attribute2             	 VARCHAR2,
    p_attribute3             	 VARCHAR2,
    p_attribute4             	 VARCHAR2,
    p_attribute5             	 VARCHAR2,
    p_attribute6             	 VARCHAR2,
    p_attribute7             	 VARCHAR2,
    p_attribute8             	 VARCHAR2,
    p_attribute9             	 VARCHAR2,
    p_attribute10            	 VARCHAR2,
    p_attribute11            	 VARCHAR2,
    p_attribute12            	 VARCHAR2,
    p_attribute13            	 VARCHAR2,
    p_attribute14            	 VARCHAR2,
    p_attribute15		 VARCHAR2,
    p_end_customer_flag          VARCHAR2)
IS
BEGIN
INSERT INTO OZF_SD_CUSTOMER_DETAILS(
        request_customer_id,
        request_header_id,
        cust_account_id,
        party_id,
        site_use_id,
        cust_usage_code,
        security_group_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        object_version_number,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        end_customer_flag)
VALUES(
        p_request_customer_id,
        p_request_header_id,
        p_cust_account_id,
        p_party_id,
        p_site_use_id,
        p_cust_usage_code,
        p_security_group_id,
        p_creation_date,
        p_created_by,
        p_last_update_date,
        p_last_updated_by,
        p_last_update_login,
        p_object_version_number,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_end_customer_flag);
END Insert_Row;

PROCEDURE Update_Row(
    p_request_customer_id     	 NUMBER,
    p_request_header_id      	 NUMBER,
    p_cust_account_id        	 NUMBER,
    p_party_id               	 NUMBER,
    p_site_use_id            	 NUMBER,
    p_cust_usage_code	         VARCHAR2,
    p_security_group_id      	 NUMBER,
    p_last_update_date       	 DATE,
    p_last_updated_by        	 NUMBER,
    p_last_update_login      	 NUMBER,
    p_object_version_number  	 NUMBER,
    p_attribute_category     	 VARCHAR2,
    p_attribute1             	 VARCHAR2,
    p_attribute2             	 VARCHAR2,
    p_attribute3             	 VARCHAR2,
    p_attribute4             	 VARCHAR2,
    p_attribute5             	 VARCHAR2,
    p_attribute6             	 VARCHAR2,
    p_attribute7             	 VARCHAR2,
    p_attribute8             	 VARCHAR2,
    p_attribute9             	 VARCHAR2,
    p_attribute10            	 VARCHAR2,
    p_attribute11            	 VARCHAR2,
    p_attribute12            	 VARCHAR2,
    p_attribute13            	 VARCHAR2,
    p_attribute14            	 VARCHAR2,
    p_attribute15		 VARCHAR2,
    p_end_customer_flag          VARCHAR2)
IS
BEGIN

UPDATE OZF_SD_CUSTOMER_DETAILS
SET request_header_id      	=	p_request_header_id,
    cust_account_id        	=	p_cust_account_id,
    party_id               	=	p_party_id,
    site_use_id            	=	p_site_use_id,
    cust_usage_code	        =	p_cust_usage_code,
    security_group_id      	=	p_security_group_id,
    last_update_date       	=	p_last_update_date,
    last_updated_by        	=	p_last_updated_by,
    last_update_login      	=	p_last_update_login,
    object_version_number  	=	p_object_version_number,
    attribute_category     	=	p_attribute_category,
    attribute1             	=	p_attribute1,
    attribute2             	=	p_attribute2,
    attribute3             	=	p_attribute3,
    attribute4             	=	p_attribute4,
    attribute5             	=	p_attribute5,
    attribute6             	=	p_attribute6,
    attribute7             	=	p_attribute7,
    attribute8             	=	p_attribute8,
    attribute9             	=	p_attribute9,
    attribute10            	=	p_attribute10,
    attribute11            	=	p_attribute11,
    attribute12            	=	p_attribute12,
    attribute13            	=	p_attribute13,
    attribute14            	=	p_attribute14,
    attribute15			=	p_attribute15,
    end_customer_flag		=   p_end_customer_flag
WHERE request_customer_id=p_request_customer_id;

END Update_Row;
END OZF_SD_CUSTOMER_PKG;

/