--------------------------------------------------------
--  DDL for Package OZF_SD_CUSTOMER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SD_CUSTOMER_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftcdts.pls 120.2 2008/01/03 13:28:07 bkunjan noship $ */

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
    p_end_customer_flag          VARCHAR2);

PROCEDURE Update_Row(
    p_request_customer_id        NUMBER,
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
    p_end_customer_flag          VARCHAR2);

END OZF_SD_CUSTOMER_PKG;

/
