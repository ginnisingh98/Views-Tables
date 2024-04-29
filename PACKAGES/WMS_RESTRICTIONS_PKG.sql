--------------------------------------------------------
--  DDL for Package WMS_RESTRICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RESTRICTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSHPRES.pls 120.1 2005/06/21 02:19:00 appldev ship $ */

PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY  VARCHAR2
  ,x_rule_id                        IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_operator_code                  IN     NUMBER
  ,x_operand_type_code              IN     NUMBER
  ,x_operand_constant_number        IN     NUMBER
  ,x_operand_constant_character     IN     VARCHAR2
  ,x_operand_constant_date          IN     DATE
  ,x_operand_parameter_id           IN     NUMBER
  ,x_operand_expression             IN     VARCHAR2
  ,x_operand_flex_value_set_id      IN     NUMBER
  ,x_logical_operator_code          IN     NUMBER
  ,x_bracket_open                   IN     VARCHAR2
  ,x_bracket_close                  IN     VARCHAR2
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
  ,x_operator_code                  IN     NUMBER
  ,x_operand_type_code              IN     NUMBER
  ,x_operand_constant_number        IN     NUMBER
  ,x_operand_constant_character     IN     VARCHAR2
  ,x_operand_constant_date          IN     DATE
  ,x_operand_parameter_id           IN     NUMBER
  ,x_operand_expression             IN     VARCHAR2
  ,x_operand_flex_value_set_id      IN     NUMBER
  ,x_logical_operator_code          IN     NUMBER
  ,x_bracket_open                   IN     VARCHAR2
  ,x_bracket_close                  IN     VARCHAR2
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
  ,x_operator_code                  IN     NUMBER
  ,x_operand_type_code              IN     NUMBER
  ,x_operand_constant_number        IN     NUMBER
  ,x_operand_constant_character     IN     VARCHAR2
  ,x_operand_constant_date          IN     DATE
  ,x_operand_parameter_id           IN     NUMBER
  ,x_operand_expression             IN     VARCHAR2
  ,x_operand_flex_value_set_id      IN     NUMBER
  ,x_logical_operator_code          IN     NUMBER
  ,x_bracket_open                   IN     VARCHAR2
  ,x_bracket_close                  IN     VARCHAR2
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
   x_rowid                          IN     VARCHAR2
  );

PROCEDURE LOAD_ROW (
  X_RULE_ID                       IN  VARCHAR2
 ,x_OWNER                         IN  VARCHAR2
 ,X_SEQUENCE_NUMBER               IN  VARCHAR2
 ,X_PARAMETER_ID                  IN  VARCHAR2
 ,X_OPERATOR_CODE                 IN  VARCHAR2
 ,X_OPERAND_TYPE_CODE             IN  VARCHAR2
 ,X_OPERAND_CONSTANT_NUMBER       IN  VARCHAR2
 ,X_OPERAND_CONSTANT_CHARACTER    IN  VARCHAR2
 ,X_OPERAND_CONSTANT_DATE         IN  VARCHAR2
 ,X_OPERAND_PARAMETER_ID          IN  VARCHAR2
 ,X_OPERAND_EXPRESSION            IN  VARCHAR2
 ,X_OPERAND_FLEX_VALUE_SET_ID     IN  VARCHAR2
 ,X_LOGICAL_OPERATOR_CODE         IN  VARCHAR2
 ,X_BRACKET_OPEN                  IN  VARCHAR2
 ,X_BRACKET_CLOSE                 IN  VARCHAR2
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
END WMS_RESTRICTIONS_PKG;

 

/
