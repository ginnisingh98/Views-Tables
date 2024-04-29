--------------------------------------------------------
--  DDL for Package AMW_PROCESS_OBJECTIVES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROCESS_OBJECTIVES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtpros.pls 115.2 2004/02/06 02:32:17 abedajna noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCESS_OBJECTIVES_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
		  X_ROWID in out NOCOPY VARCHAR2,
          x_last_updated_by    NUMBER,
          x_last_update_date    DATE,
          x_created_by    NUMBER,
          x_creation_date    DATE,
          x_last_update_login    NUMBER,
          x_objective_type    VARCHAR2,
          x_start_date    DATE,
          x_end_date    DATE,
          x_attribute_category    VARCHAR2,
          x_attribute1    VARCHAR2,
          x_attribute2    VARCHAR2,
          x_attribute3    VARCHAR2,
          x_attribute4    VARCHAR2,
          x_attribute5    VARCHAR2,
          x_attribute6    VARCHAR2,
          x_attribute7    VARCHAR2,
          x_attribute8    VARCHAR2,
          x_attribute9    VARCHAR2,
          x_attribute10    VARCHAR2,
          x_attribute11    VARCHAR2,
          x_attribute12    VARCHAR2,
          x_attribute13    VARCHAR2,
          x_attribute14    VARCHAR2,
          x_attribute15    VARCHAR2,
          x_security_group_id    NUMBER,
          x_object_version_number  NUMBER,
          x_process_objective_id   NUMBER,
		  x_requestor_id NUMBER,
		  X_NAME in VARCHAR2,
  		  X_DESCRIPTION in VARCHAR2);

PROCEDURE Update_Row(
          x_last_updated_by    NUMBER,
          x_last_update_date    DATE,
          --x_created_by    NUMBER,
          --x_creation_date    DATE,
          x_last_update_login    NUMBER,
          x_objective_type    VARCHAR2,
          x_start_date    DATE,
          x_end_date    DATE,
          x_attribute_category    VARCHAR2,
          x_attribute1    VARCHAR2,
          x_attribute2    VARCHAR2,
          x_attribute3    VARCHAR2,
          x_attribute4    VARCHAR2,
          x_attribute5    VARCHAR2,
          x_attribute6    VARCHAR2,
          x_attribute7    VARCHAR2,
          x_attribute8    VARCHAR2,
          x_attribute9    VARCHAR2,
          x_attribute10    VARCHAR2,
          x_attribute11    VARCHAR2,
          x_attribute12    VARCHAR2,
          x_attribute13    VARCHAR2,
          x_attribute14    VARCHAR2,
          x_attribute15    VARCHAR2,
          x_security_group_id    NUMBER,
          x_object_version_number    NUMBER,
          x_process_objective_id    NUMBER,
		  X_NAME in VARCHAR2,
  		  X_DESCRIPTION in VARCHAR2,
		  x_requestor_id NUMBER);

PROCEDURE Delete_Row(
    x_PROCESS_OBJECTIVE_ID  NUMBER);

PROCEDURE Lock_Row(
          --x_last_updated_by    NUMBER,
          --x_last_update_date    DATE,
          --x_created_by    NUMBER,
          --x_creation_date    DATE,
          --x_last_update_login    NUMBER,
          x_objective_type    VARCHAR2,
          x_start_date    DATE,
          x_end_date    DATE,
          x_attribute_category    VARCHAR2,
          x_attribute1    VARCHAR2,
          x_attribute2    VARCHAR2,
          x_attribute3    VARCHAR2,
          x_attribute4    VARCHAR2,
          x_attribute5    VARCHAR2,
          x_attribute6    VARCHAR2,
          x_attribute7    VARCHAR2,
          x_attribute8    VARCHAR2,
          x_attribute9    VARCHAR2,
          x_attribute10    VARCHAR2,
          x_attribute11    VARCHAR2,
          x_attribute12    VARCHAR2,
          x_attribute13    VARCHAR2,
          x_attribute14    VARCHAR2,
          x_attribute15    VARCHAR2,
          x_security_group_id    NUMBER,
          x_object_version_number    NUMBER,
          x_process_objective_id    NUMBER,
		  X_NAME in VARCHAR2,
  		  X_DESCRIPTION in VARCHAR2,
		  x_requestor_id NUMBER);

procedure ADD_LANGUAGE;


procedure delete_proc_obj (
p_object_type			varchar2,
p_pk1				number,
p_commit			in varchar2 := FND_API.G_FALSE,
p_validation_level		IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
);

END AMW_PROCESS_OBJECTIVES_B_PKG;

 

/
