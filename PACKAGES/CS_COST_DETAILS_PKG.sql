--------------------------------------------------------
--  DDL for Package CS_COST_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COST_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: csxcsts.pls 120.1 2008/01/18 07:00:14 bkanimoz noship $ */

/*=========================================
         Procedure Insert Row
 ===========================================
*/

PROCEDURE Insert_Row
(

p_incident_id NUMBER,
p_estimate_detail_id NUMBER,
p_transaction_type_id NUMBER,
p_txn_billing_type_id NUMBER,
p_inventory_item_id NUMBER,
p_quantity NUMBER,
p_unit_cost NUMBER,
p_extended_cost NUMBER,
p_override_ext_cost_flag VARCHAR2,
p_transaction_date DATE,
p_source_id NUMBER,
p_source_code VARCHAR2,
p_unit_of_measure_code VARCHAR2,
p_currency_code VARCHAR2,
p_org_id NUMBER,
p_inventory_org_id NUMBER,
p_attribute1 VARCHAR2,
p_attribute2 VARCHAR2,
p_attribute3 VARCHAR2,
p_attribute4 VARCHAR2,
p_attribute5 VARCHAR2,
p_attribute6 VARCHAR2,
p_attribute7 VARCHAR2,
p_attribute8 VARCHAR2,
p_attribute9 VARCHAR2,
p_attribute10 VARCHAR2,
p_attribute11 VARCHAR2,
p_attribute12 VARCHAR2,
p_attribute13 VARCHAR2,
p_attribute14 VARCHAR2,
p_attribute15 VARCHAR2,
p_last_update_date DATE,
p_last_updated_by NUMBER,
p_last_update_login NUMBER,
p_created_by NUMBER,
p_creation_date DATE,
x_object_version_number OUT NOCOPY NUMBER,
x_cost_id OUT NOCOPY NUMBER
);

/*=========================================
         Procedure Update Row
 ===========================================
*/


PROCEDURE Update_Row
(
p_cost_id NUMBER,
p_incident_id NUMBER,
p_estimate_detail_id NUMBER,
p_transaction_type_id NUMBER,
p_txn_billing_type_id NUMBER,
p_inventory_item_id NUMBER,
p_quantity NUMBER,
p_unit_cost NUMBER,
p_extended_cost NUMBER,
p_override_ext_cost_flag VARCHAR2,
p_transaction_date DATE,
p_source_id NUMBER,
p_source_code VARCHAR2,
p_unit_of_measure_code VARCHAR2,
p_currency_code VARCHAR2,
p_org_id NUMBER,
p_inventory_org_id NUMBER,
p_attribute1 VARCHAR2,
p_attribute2 VARCHAR2,
p_attribute3 VARCHAR2,
p_attribute4 VARCHAR2,
p_attribute5 VARCHAR2,
p_attribute6 VARCHAR2,
p_attribute7 VARCHAR2,
p_attribute8 VARCHAR2,
p_attribute9 VARCHAR2,
p_attribute10 VARCHAR2,
p_attribute11 VARCHAR2,
p_attribute12 VARCHAR2,
p_attribute13 VARCHAR2,
p_attribute14 VARCHAR2,
p_attribute15 VARCHAR2,
p_last_update_date DATE,
p_last_updated_by NUMBER,
p_last_update_login NUMBER,
p_created_by NUMBER,
p_creation_date DATE,
x_object_version_number IN OUT NOCOPY NUMBER

);

/*=========================================
         Procedure Delete Row
 ===========================================
*/

PROCEDURE Delete_Row
(
p_cost_id NUMBER
);

END CS_COST_DETAILS_PKG;


/
