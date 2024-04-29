--------------------------------------------------------
--  DDL for Package WMS_RESTRICTION_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RESTRICTION_FORM_PKG" AUTHID CURRENT_USER AS
/* $Header: WMSFPRES.pls 120.1 2005/06/20 05:09:40 appldev ship $ */

procedure insert_restriction
  (
    p_api_version         	     IN  NUMBER
   ,p_init_msg_list       	     IN  VARCHAR2 := fnd_api.g_false
   ,p_validation_level    	     IN  NUMBER   := fnd_api.g_valid_level_full
   ,x_return_status       	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_msg_count           	     OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_msg_data            	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_operator_code                  IN  NUMBER
   ,p_operand_type_code              IN  NUMBER
   ,p_operand_constant_number        IN  NUMBER
   ,p_operand_constant_character     IN  VARCHAR2
   ,p_operand_constant_date          IN  DATE
   ,p_operand_parameter_id           IN  NUMBER
   ,p_operand_expression             IN  VARCHAR2
   ,p_operand_flex_value_set_id      IN  NUMBER
   ,p_logical_operator_code          IN  NUMBER
   ,p_bracket_open                   IN  VARCHAR2
   ,p_bracket_close                  IN  VARCHAR2
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
  );

procedure lock_restriction (
    p_api_version         	     IN  NUMBER
   ,p_init_msg_list       	     IN  VARCHAR2 := fnd_api.g_false
   ,p_validation_level    	     IN  NUMBER   := fnd_api.g_valid_level_full
   ,x_return_status       	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_msg_count           	     OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_msg_data            	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rowid                          IN  VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_operator_code                  IN  NUMBER
   ,p_operand_type_code              IN  NUMBER
   ,p_operand_constant_number        IN  NUMBER
   ,p_operand_constant_character     IN  VARCHAR2
   ,p_operand_constant_date          IN  DATE
   ,p_operand_parameter_id           IN  NUMBER
   ,p_operand_expression             IN  VARCHAR2
   ,p_operand_flex_value_set_id      IN  NUMBER
   ,p_logical_operator_code          IN  NUMBER
   ,p_bracket_open                   IN  VARCHAR2
   ,p_bracket_close                  IN  VARCHAR2
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
  );

procedure update_restriction (
    p_api_version         	     IN  NUMBER
   ,p_init_msg_list       	     IN  VARCHAR2 := fnd_api.g_false
   ,p_validation_level    	     IN  NUMBER   := fnd_api.g_valid_level_full
   ,x_return_status       	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_msg_count           	     OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_msg_data            	     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,p_rowid                          IN  VARCHAR2
   ,p_rule_id                        IN  NUMBER
   ,p_sequence_number                IN  NUMBER
   ,p_parameter_id                   IN  NUMBER
   ,p_operator_code                  IN  NUMBER
   ,p_operand_type_code              IN  NUMBER
   ,p_operand_constant_number        IN  NUMBER
   ,p_operand_constant_character     IN  VARCHAR2
   ,p_operand_constant_date          IN  DATE
   ,p_operand_parameter_id           IN  NUMBER
   ,p_operand_expression             IN  VARCHAR2
   ,p_operand_flex_value_set_id      IN  NUMBER
   ,p_logical_operator_code          IN  NUMBER
   ,p_bracket_open                   IN  VARCHAR2
   ,p_bracket_close                  IN  VARCHAR2
   ,p_attribute_category             IN  VARCHAR2
   ,p_attribute1                     IN  VARCHAR2
   ,p_attribute2                     IN  VARCHAR2
   ,p_attribute3                     IN  VARCHAR2
   ,p_attribute4                     IN  VARCHAR2
   ,p_attribute5                     IN  VARCHAR2
   ,p_attribute6                     IN  VARCHAR2
   ,p_attribute7                     IN  VARCHAR2
   ,p_attribute8                     IN  VARCHAR2
   ,p_attribute9                     IN  VARCHAR2
   ,p_attribute10                    IN  VARCHAR2
   ,p_attribute11                    IN  VARCHAR2
   ,p_attribute12                    IN  VARCHAR2
   ,p_attribute13                    IN  VARCHAR2
   ,p_attribute14                    IN  VARCHAR2
   ,p_attribute15                    IN  VARCHAR2
  ) ;

procedure delete_restriction (
  p_api_version               in  NUMBER,
  p_init_msg_list             in  varchar2 := fnd_api.g_false,
  p_validation_level          in  number   := fnd_api.g_valid_level_full,
  x_return_status             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_rowid                     IN  VARCHAR2,
  p_rule_id                   IN  NUMBER,
  p_sequence_number           IN  NUMBER
			      );

-- this private procedure should be used only by the wms_rule_form_pkg.delete_rule
-- no validation is done whatsoever
procedure delete_restrictions (
  p_rule_id                   IN  NUMBER
 );

end WMS_RESTRICTION_FORM_PKG;

 

/
