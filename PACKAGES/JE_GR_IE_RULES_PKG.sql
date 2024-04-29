--------------------------------------------------------
--  DDL for Package JE_GR_IE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_GR_IE_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: jegrers.pls 120.5 2006/04/27 09:26:22 samalhot ship $ */
PROCEDURE INSERT_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN OUT NOCOPY 	NUMBER,
  p_rule_name 			IN 	VARCHAR2,
  p_enabled_flag 		IN 	VARCHAR2,
  p_description 		IN 	VARCHAR2,
  p_attribute_category     	IN      VARCHAR2,
  p_attribute1			IN 	VARCHAR2,
  p_attribute2			IN 	VARCHAR2,
  p_attribute3			IN 	VARCHAR2,
  p_attribute4			IN 	VARCHAR2,
  p_attribute5			IN 	VARCHAR2,
  p_attribute6			IN 	VARCHAR2,
  p_attribute7			IN 	VARCHAR2,
  p_attribute8			IN 	VARCHAR2,
  p_attribute9			IN 	VARCHAR2,
  p_attribute10			IN 	VARCHAR2,
  p_attribute11			IN 	VARCHAR2,
  p_attribute12			IN 	VARCHAR2,
  p_attribute13			IN 	VARCHAR2,
  p_attribute14			IN 	VARCHAR2,
  p_attribute15			IN 	VARCHAR2,
  p_creation_date 		IN 	DATE,
  p_created_by 			IN 	NUMBER,
  p_last_update_date 		IN 	DATE,
  p_last_updated_by 		IN 	NUMBER,
  p_last_update_login 		IN 	NUMBER,
  p_legal_entity_id           	IN	NUMBER
);

PROCEDURE LOCK_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_rule_name 			IN 	VARCHAR2,
  p_description 		IN 	VARCHAR2,
  p_enabled_flag		IN	VARCHAR2,
  p_attribute_category     	IN      VARCHAR2,
  p_attribute1			IN 	VARCHAR2,
  p_attribute2			IN 	VARCHAR2,
  p_attribute3			IN 	VARCHAR2,
  p_attribute4			IN 	VARCHAR2,
  p_attribute5			IN 	VARCHAR2,
  p_attribute6			IN 	VARCHAR2,
  p_attribute7			IN 	VARCHAR2,
  p_attribute8			IN 	VARCHAR2,
  p_attribute9			IN 	VARCHAR2,
  p_attribute10			IN 	VARCHAR2,
  p_attribute11			IN 	VARCHAR2,
  p_attribute12			IN 	VARCHAR2,
  p_attribute13			IN 	VARCHAR2,
  p_attribute14			IN 	VARCHAR2,
  p_attribute15			IN 	VARCHAR2
);

PROCEDURE UPDATE_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_rule_name 			IN 	VARCHAR2,
  p_description 		IN 	VARCHAR2,
  p_enabled_flag 		IN 	VARCHAR2,
  p_attribute_category     	IN      VARCHAR2,
  p_attribute1			IN 	VARCHAR2,
  p_attribute2			IN 	VARCHAR2,
  p_attribute3			IN 	VARCHAR2,
  p_attribute4			IN 	VARCHAR2,
  p_attribute5			IN 	VARCHAR2,
  p_attribute6			IN 	VARCHAR2,
  p_attribute7			IN 	VARCHAR2,
  p_attribute8			IN 	VARCHAR2,
  p_attribute9			IN 	VARCHAR2,
  p_attribute10			IN 	VARCHAR2,
  p_attribute11			IN 	VARCHAR2,
  p_attribute12			IN 	VARCHAR2,
  p_attribute13			IN 	VARCHAR2,
  p_attribute14			IN 	VARCHAR2,
  p_attribute15			IN 	VARCHAR2,
  p_last_update_date 		IN 	DATE,
  p_last_updated_by 		IN 	NUMBER,
  p_last_update_login 		IN 	NUMBER,
  p_legal_entity_id 		IN	NUMBER
);

PROCEDURE DELETE_ROW (
  p_application_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER
);
end JE_GR_IE_RULES_PKG;

 

/
