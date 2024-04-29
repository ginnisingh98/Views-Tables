--------------------------------------------------------
--  DDL for Package WMS_SORT_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SORT_CRITERIA_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSHPCRS.pls 120.1 2005/06/21 02:13:13 appldev ship $ */

PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY VARCHAR2
  ,x_rule_id                        IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_order_code                     IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
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
  );

PROCEDURE LOCK_ROW (
   x_rowid                          IN     VARCHAR2
  ,x_rule_id                        IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_order_code                     IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
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
  );

PROCEDURE UPDATE_ROW (
   x_rowid                          IN     VARCHAR2
  ,x_rule_id                        IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_order_code                     IN     NUMBER
  ,x_attribute_category             IN     VARCHAR2
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
  );

PROCEDURE DELETE_ROW (
  x_rowid			   IN VARCHAR2
  );

PROCEDURE LOAD_ROW (
  X_RULE_ID                       IN  NUMBER
 ,x_OWNER                         IN  VARCHAR2
 ,X_SEQUENCE_NUMBER               IN  NUMBER
 ,X_PARAMETER_ID                  IN  NUMBER
 ,X_ORDER_CODE                    IN  NUMBER
 ,X_ATTRIBUTE_CATEGORY            IN  VARCHAR2
 ,X_ATTRIBUTE1                    IN  VARCHAR2
 ,X_ATTRIBUTE2                    IN  VARCHAR2
 ,X_ATTRIBUTE3                    IN  VARCHAR2
 ,X_ATTRIBUTE4                    IN  VARCHAR2
 ,X_ATTRIBUTE5                    IN  VARCHAR2
 ,X_ATTRIBUTE6                    IN  VARCHAR2
 ,X_ATTRIBUTE7                    IN  VARCHAR2
 ,X_ATTRIBUTE8                    IN  VARCHAR2
 ,X_ATTRIBUTE9                    IN  VARCHAR2
 ,X_ATTRIBUTE10                   IN  VARCHAR2
 ,X_ATTRIBUTE11                   IN  VARCHAR2
 ,X_ATTRIBUTE12                   IN  VARCHAR2
 ,X_ATTRIBUTE13                   IN  VARCHAR2
 ,X_ATTRIBUTE14                   IN  VARCHAR2
 ,X_ATTRIBUTE15                   IN  VARCHAR2
);
END WMS_SORT_CRITERIA_PKG;

 

/
