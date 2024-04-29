--------------------------------------------------------
--  DDL for Package JE_GR_IE_RULE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_GR_IE_RULE_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: jegrerls.pls 115.1 2002/11/12 12:03:15 arimai ship $ */
PROCEDURE INSERT_ROW (
  p_rule_line_id 		IN OUT NOCOPY NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_application_id		IN 	NUMBER,
  p_lookup_type 		IN 	VARCHAR2,
  p_lookup_code 		IN 	VARCHAR2,
  p_exclude_flag		IN 	VARCHAR2,
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
  p_last_update_login 		IN 	NUMBER
);

PROCEDURE LOCK_ROW (
  p_rule_line_id 		IN  	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_application_id		IN 	NUMBER,
  p_lookup_type 		IN 	VARCHAR2,
  p_lookup_code 		IN 	VARCHAR2,
  p_exclude_flag		IN 	VARCHAR2,
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
  p_rule_line_id 		IN  	NUMBER,
  p_rule_id 			IN 	NUMBER,
  p_application_id		IN 	NUMBER,
  p_lookup_type 		IN 	VARCHAR2,
  p_lookup_code 		IN 	VARCHAR2,
  p_exclude_flag		IN 	VARCHAR2,
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
  p_last_update_login 		IN 	NUMBER
);

PROCEDURE DELETE_ROW (
  p_rule_line_id 		IN 	NUMBER,
  p_rule_id 			IN 	NUMBER
);
end JE_GR_IE_RULE_LINES_PKG;

 

/
