--------------------------------------------------------
--  DDL for Package WMS_STRATEGY_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_STRATEGY_MEMBERS_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSPPSMS.pls 120.1 2005/06/20 02:36:26 appldev ship $ */
--
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,x_strategy_id                    IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_rule_id                        IN     NUMBER
  ,x_partial_success_allowed_flag   IN     VARCHAR2
  ,x_effective_from                 IN     DATE
  ,x_effective_to                   IN     DATE
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
  ,x_date_type_code		    IN     VARCHAR2
  ,x_date_type_lookup_type          IN     VARCHAR2
  ,x_date_type_from                 IN     NUMBER
  ,x_date_type_to                   IN     NUMBER
);
--
PROCEDURE LOCK_ROW (
   x_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,x_strategy_id                    IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_rule_id                        IN     NUMBER
  ,x_partial_success_allowed_flag   IN     VARCHAR2
  ,x_effective_from                 IN     DATE
  ,x_effective_to                   IN     DATE
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
  ,x_date_type_code                 IN     VARCHAR2
  ,x_date_type_lookup_type          IN     VARCHAR2
  ,x_date_type_from                 IN     NUMBER
  ,x_date_type_to                   IN     NUMBER

  );
--
PROCEDURE UPDATE_ROW (
  x_rowid                           IN     VARCHAR2
  ,x_strategy_id                    IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_rule_id                        IN     NUMBER
  ,x_partial_success_allowed_flag   IN     VARCHAR2
  ,x_effective_from                 IN     DATE
  ,x_effective_to                   IN     DATE
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
  ,x_date_type_code                 IN     VARCHAR2
  ,x_date_type_lookup_type          IN     VARCHAR2
  ,x_date_type_from                 IN     NUMBER
  ,x_date_type_to                   IN     NUMBER
 );
--
PROCEDURE DELETE_ROW (
   x_rowid IN VARCHAR2
  );

PROCEDURE LOAD_ROW
  (
   x_strategy_id                    IN  NUMBER
  ,x_owner                          IN  VARCHAR2
  ,x_SEQUENCE_NUMBER                IN  NUMBER
  ,x_RULE_ID                        IN  NUMBER
  ,x_PARTIAL_SUCCESS_ALLOWED_FLAG   IN  VARCHAR2
  ,x_EFFECTIVE_FROM                 IN  DATE
  ,x_EFFECTIVE_TO                   IN  DATE
  ,x_DATE_TYPE_CODE                 IN  VARCHAR2
  ,x_DATE_TYPE_LOOKUP_TYPE          IN  VARCHAR2
  ,x_DATE_TYPE_FROM                 IN  NUMBER
  ,x_DATE_TYPE_TO                   IN  NUMBER
  ,x_ATTRIBUTE_CATEGORY             IN  VARCHAR2
  ,x_ATTRIBUTE1                     IN  VARCHAR2
  ,x_ATTRIBUTE2                     IN  VARCHAR2
  ,x_ATTRIBUTE3                     IN  VARCHAR2
  ,x_ATTRIBUTE4                     IN  VARCHAR2
  ,x_ATTRIBUTE5                     IN  VARCHAR2
  ,x_ATTRIBUTE6                     IN  VARCHAR2
  ,x_ATTRIBUTE7                     IN  VARCHAR2
  ,x_ATTRIBUTE8                     IN  VARCHAR2
  ,x_ATTRIBUTE9                     IN  VARCHAR2
  ,x_ATTRIBUTE10                    IN  VARCHAR2
  ,x_ATTRIBUTE11                    IN  VARCHAR2
  ,x_ATTRIBUTE12                    IN  VARCHAR2
  ,x_ATTRIBUTE13                    IN  VARCHAR2
  ,x_ATTRIBUTE14                    IN  VARCHAR2
  ,x_ATTRIBUTE15                    IN  VARCHAR2
  );
END WMS_STRATEGY_MEMBERS_PKG;

 

/
