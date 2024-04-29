--------------------------------------------------------
--  DDL for Package WMS_DB_OBJ_REF_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_DB_OBJ_REF_MEMBERS_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSPPRMS.pls 120.1 2005/06/20 03:04:59 appldev ship $ */
--
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,x_db_object_reference_id         IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_db_object_id                   IN     NUMBER
  ,x_table_alias                    IN     VARCHAR2
  ,x_user_defined_flag              IN     VARCHAR2
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_attribute_category             IN     VARCHAR2
  );
--
PROCEDURE LOCK_ROW (
   x_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,x_db_object_reference_id         IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_db_object_id                   IN     NUMBER
  ,x_table_alias                    IN     VARCHAR2
  ,x_user_defined_flag              IN     VARCHAR2
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_attribute_category             IN     VARCHAR2
  );
--
PROCEDURE UPDATE_ROW (
   x_db_object_reference_id         IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_db_object_id                   IN     NUMBER
  ,x_table_alias                    IN     VARCHAR2
  ,x_user_defined_flag              IN     VARCHAR2
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_attribute1                     IN     VARCHAR2
  ,x_attribute2                     IN     VARCHAR2
  ,x_attribute3                     IN     VARCHAR2
  ,x_attribute4                     IN     VARCHAR2
  ,x_attribute5                     IN     VARCHAR2
  ,x_attribute6                     IN     VARCHAR2
  ,x_attribute7                     IN     VARCHAR2
  ,x_attribute8                     IN     VARCHAR2
  ,x_attribute9                     IN     VARCHAR2
  ,x_attribute10                    IN     VARCHAR2
  ,x_attribute11                    IN     VARCHAR2
  ,x_attribute12                    IN     VARCHAR2
  ,x_attribute13                    IN     VARCHAR2
  ,x_attribute14                    IN     VARCHAR2
  ,x_attribute15                    IN     VARCHAR2
  ,x_attribute_category             IN     VARCHAR2
  );
--
PROCEDURE DELETE_ROW (
   x_rowid IN VARCHAR2
  );
PROCEDURE load_row
  (
    x_db_object_reference_id         IN    VARCHAR2
   ,x_sequence_number                IN    VARCHAR2
   ,x_owner                          IN    VARCHAR2
   ,x_db_object_id                   IN    VARCHAR2
   ,x_table_alias                    IN    VARCHAR2
   ,x_user_defined_flag              IN    VARCHAR2
   ,x_attribute1                     IN    VARCHAR2
   ,x_attribute2                     IN    VARCHAR2
   ,x_attribute3                     IN    VARCHAR2
   ,x_attribute4                     IN    VARCHAR2
   ,x_attribute5                     IN    VARCHAR2
   ,x_attribute6                     IN    VARCHAR2
   ,x_attribute7                     IN    VARCHAR2
   ,x_attribute8                     IN    VARCHAR2
   ,x_attribute9                     IN    VARCHAR2
   ,x_attribute10                    IN    VARCHAR2
   ,x_attribute11                    IN    VARCHAR2
   ,x_attribute12                    IN    VARCHAR2
   ,x_attribute13                    IN    VARCHAR2
   ,x_attribute14                    IN    VARCHAR2
   ,x_attribute15                    IN    VARCHAR2
   ,x_attribute_category             IN    VARCHAR2
   );
END WMS_DB_OBJ_REF_MEMBERS_PKG;

 

/
