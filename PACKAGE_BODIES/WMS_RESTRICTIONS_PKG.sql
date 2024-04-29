--------------------------------------------------------
--  DDL for Package Body WMS_RESTRICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RESTRICTIONS_PKG" AS
/* $Header: WMSHPREB.pls 120.1 2005/06/21 02:18:42 appldev ship $ */

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
  )IS
    CURSOR C IS SELECT ROWID FROM WMS_RESTRICTIONS
      WHERE rule_id = x_rule_id
        AND sequence_number = x_sequence_number;
BEGIN

   INSERT INTO WMS_RESTRICTIONS (
       rule_id
      ,sequence_number
      ,last_updated_by
      ,last_update_date
      ,created_by
      ,creation_date
      ,last_update_login
      ,parameter_id
      ,operator_code
      ,operand_type_code
      ,operand_constant_number
      ,operand_constant_character
      ,operand_constant_date
      ,operand_parameter_id
      ,operand_expression
      ,operand_flex_value_set_id
      ,logical_operator_code
      ,bracket_open
      ,bracket_close
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
    ) values (
       x_rule_id
      ,x_sequence_number
      ,x_last_updated_by
      ,x_last_update_date
      ,x_created_by
      ,x_creation_date
      ,x_last_update_login
      ,x_parameter_id
      ,x_operator_code
      ,x_operand_type_code
      ,x_operand_constant_number
      ,x_operand_constant_character
      ,x_operand_constant_date
      ,x_operand_parameter_id
      ,x_operand_expression
      ,x_operand_flex_value_set_id
      ,x_logical_operator_code
      ,x_bracket_open
      ,x_bracket_close
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
   );

  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
     CLOSE C;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END INSERT_ROW;

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
  )IS
    CURSOR C IS SELECT
       rule_id
      ,sequence_number
      ,parameter_id
      ,operator_code
      ,operand_type_code
      ,operand_constant_number
      ,operand_constant_character
      ,operand_constant_date
      ,operand_parameter_id
      ,operand_expression
      ,operand_flex_value_set_id
      ,logical_operator_code
      ,bracket_open
      ,bracket_close
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
     FROM WMS_RESTRICTIONS
     WHERE rowid = x_rowid
     FOR UPDATE OF rule_id NOWAIT;

  recinfo c%ROWTYPE;
BEGIN
   OPEN c;
   FETCH c INTO recinfo;
   IF (c%notfound) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c;
   IF (    (recinfo.rule_id = x_rule_id)
       AND (recinfo.sequence_number = x_sequence_number)
       AND (recinfo.parameter_id = x_parameter_id)
       AND (recinfo.operator_code = x_operator_code)
       AND (recinfo.operand_type_code = x_operand_type_code)
       AND ((recinfo.operand_constant_number = x_operand_constant_number)
             OR ((recinfo.operand_constant_number IS NULL)
            AND (x_operand_constant_number IS NULL)))
       AND ((recinfo.operand_constant_character = x_operand_constant_character)
             OR ((recinfo.operand_constant_character IS NULL)
            AND (x_operand_constant_character IS NULL)))
       AND ((recinfo.operand_constant_date = x_operand_constant_date)
             OR ((recinfo.operand_constant_date IS NULL)
            AND (x_operand_constant_date IS NULL)))
       AND ((recinfo.operand_parameter_id = x_operand_parameter_id)
             OR ((recinfo.operand_parameter_id IS NULL)
            AND (x_operand_parameter_id IS NULL)))
       AND ((recinfo.operand_expression = x_operand_expression)
             OR ((recinfo.operand_expression IS NULL)
            AND (x_operand_expression IS NULL)))
       AND ((recinfo.operand_flex_value_set_id = x_operand_flex_value_set_id)
             OR ((recinfo.operand_flex_value_set_id IS NULL)
            AND (x_operand_flex_value_set_id IS NULL)))
       AND ((recinfo.logical_operator_code = x_logical_operator_code)
             OR ((recinfo.logical_operator_code IS NULL)
            AND (x_logical_operator_code IS NULL)))
       AND ((recinfo.bracket_open = x_bracket_open)
             OR ((recinfo.bracket_open IS NULL)
            AND (x_bracket_open IS NULL)))
       AND ((recinfo.bracket_close = x_bracket_close)
             OR ((recinfo.bracket_close IS NULL)
            AND (x_bracket_close IS NULL)))
       AND ((recinfo.attribute_category = x_attribute_category)
             OR ((recinfo.attribute_category IS NULL)
            AND (x_attribute_category IS NULL)))
       AND ((recinfo.attribute1 = x_attribute1)
             OR ((recinfo.attribute1 IS NULL)
            AND (x_attribute1 IS NULL)))
       AND ((recinfo.attribute2 = x_attribute2)
             OR ((recinfo.attribute2 IS NULL)
            AND (x_attribute2 IS NULL)))
       AND ((recinfo.attribute3 = x_attribute3)
             OR ((recinfo.attribute3 IS NULL)
            AND (x_attribute3 IS NULL)))
       AND ((recinfo.attribute4 = x_attribute4)
             OR ((recinfo.attribute4 IS NULL)
            AND (x_attribute4 IS NULL)))
       AND ((recinfo.attribute5 = x_attribute5)
             OR ((recinfo.attribute5 IS NULL)
            AND (x_attribute5 IS NULL)))
       AND ((recinfo.attribute6 = x_attribute6)
             OR ((recinfo.attribute6 IS NULL)
            AND (x_attribute6 IS NULL)))
       AND ((recinfo.attribute7 = x_attribute7)
             OR ((recinfo.attribute7 IS NULL)
            AND (x_attribute7 IS NULL)))
       AND ((recinfo.attribute8 = x_attribute8)
             OR ((recinfo.attribute8 IS NULL)
            AND (x_attribute8 IS NULL)))
       AND ((recinfo.attribute9 = x_attribute9)
             OR ((recinfo.attribute9 IS NULL)
            AND (x_attribute9 IS NULL)))
       AND ((recinfo.attribute10 = x_attribute10)
             OR ((recinfo.attribute10 IS NULL)
            AND (x_attribute10 IS NULL)))
       AND ((recinfo.attribute11 = x_attribute11)
             OR ((recinfo.attribute11 IS NULL)
            AND (x_attribute11 IS NULL)))
       AND ((recinfo.attribute12 = x_attribute12)
             OR ((recinfo.attribute12 IS NULL)
            AND (x_attribute12 IS NULL)))
       AND ((recinfo.attribute13 = x_attribute13)
             OR ((recinfo.attribute13 IS NULL)
            AND (x_attribute13 IS NULL)))
       AND ((recinfo.attribute14 = x_attribute14)
             OR ((recinfo.attribute14 IS NULL)
            AND (x_attribute14 IS NULL)))
       AND ((recinfo.attribute15 = x_attribute15)
             OR ((recinfo.attribute15 IS NULL)
            AND (x_attribute15 IS NULL)))

   ) THEN
     NULL;
   ELSE
     fnd_message.set_name('FND','FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   END IF;
END LOCK_ROW;

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
  )IS
BEGIN
   IF (x_rowid IS NOT NULL) THEN
      UPDATE WMS_RESTRICTIONS SET
       rule_id = x_rule_id
      ,sequence_number = x_sequence_number
      ,last_updated_by = x_last_updated_by
      ,last_update_date = x_last_update_date
      ,last_update_login = x_last_update_login
      ,parameter_id = x_parameter_id
      ,operator_code = x_operator_code
      ,operand_type_code = x_operand_type_code
      ,operand_constant_number = x_operand_constant_number
      ,operand_constant_character = x_operand_constant_character
      ,operand_constant_date = x_operand_constant_date
      ,operand_parameter_id = x_operand_parameter_id
      ,operand_expression = x_operand_expression
      ,operand_flex_value_set_id = x_operand_flex_value_set_id
      ,logical_operator_code = x_logical_operator_code
      ,bracket_open = x_bracket_open
      ,bracket_close = x_bracket_close
      ,attribute_category = x_attribute_category
      ,attribute1 = x_attribute1
      ,attribute2 = x_attribute2
      ,attribute3 = x_attribute3
      ,attribute4 = x_attribute4
      ,attribute5 = x_attribute5
      ,attribute6 = x_attribute6
      ,attribute7 = x_attribute7
      ,attribute8 = x_attribute8
      ,attribute9 = x_attribute9
      ,attribute10 = x_attribute10
      ,attribute11 = x_attribute11
      ,attribute12 = x_attribute12
      ,attribute13 = x_attribute13
      ,attribute14 = x_attribute14
      ,attribute15 = x_attribute15
      WHERE rowid = x_rowid;
   ELSE
      UPDATE WMS_RESTRICTIONS SET
       rule_id = x_rule_id
      ,sequence_number = x_sequence_number
      ,last_updated_by = x_last_updated_by
      ,last_update_date = x_last_update_date
      ,last_update_login = x_last_update_login
      ,parameter_id = x_parameter_id
      ,operator_code = x_operator_code
      ,operand_type_code = x_operand_type_code
      ,operand_constant_number = x_operand_constant_number
      ,operand_constant_character = x_operand_constant_character
      ,operand_constant_date = x_operand_constant_date
      ,operand_parameter_id = x_operand_parameter_id
      ,operand_expression = x_operand_expression
      ,operand_flex_value_set_id = x_operand_flex_value_set_id
      ,logical_operator_code = x_logical_operator_code
      ,bracket_open = x_bracket_open
      ,bracket_close = x_bracket_close
      ,attribute_category = x_attribute_category
      ,attribute1 = x_attribute1
      ,attribute2 = x_attribute2
      ,attribute3 = x_attribute3
      ,attribute4 = x_attribute4
      ,attribute5 = x_attribute5
      ,attribute6 = x_attribute6
      ,attribute7 = x_attribute7
      ,attribute8 = x_attribute8
      ,attribute9 = x_attribute9
      ,attribute10 = x_attribute10
      ,attribute11 = x_attribute11
      ,attribute12 = x_attribute12
      ,attribute13 = x_attribute13
      ,attribute14 = x_attribute14
      ,attribute15 = x_attribute15
   WHERE rule_id         = x_rule_id
   AND   sequence_number = x_sequence_number;
  END IF;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
	x_rowid	IN 	VARCHAR2
  )IS
BEGIN

   DELETE FROM WMS_RESTRICTIONS
   WHERE rowid = x_rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

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
) IS
BEGIN
   DECLARE
      l_rule_id                   NUMBER;
      l_sequence_number           NUMBER;
      l_parameter_id              NUMBER;
      l_operator_code             NUMBER;
      l_operator_type_code        NUMBER;
      l_operand_type_code         NUMBER;
      l_operand_constant_number   NUMBER;
      l_operand_parameter_id      NUMBER;
      l_operand_flex_value_set_id NUMBER;
      l_logical_operator_code     NUMBER;
      l_operand_constant_date     date;
      l_user_id              NUMBER := 0;
      l_row_id               VARCHAR2(64);
      l_sysdate              DATE;
      l_date_type_from       NUMBER := 0;
      l_date_type_to         NUMBER := 0;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_rule_id := fnd_number.canonical_to_number(x_rule_id);
      l_parameter_id  := fnd_number.canonical_to_number(x_parameter_id );
      l_sequence_number :=
	fnd_number.canonical_to_number(x_sequence_number);
      l_operator_code  :=
        fnd_number.canonical_to_number(x_operator_code );
      l_operand_type_code  :=
        fnd_number.canonical_to_number(x_operand_type_code );
      l_operand_constant_number  :=
        fnd_number.canonical_to_number(x_operand_constant_number );
      l_operand_flex_value_set_id  :=
        fnd_number.canonical_to_number(x_operand_flex_value_set_id );
      l_logical_operator_code  :=
        fnd_number.canonical_to_number(x_logical_operator_code );
      l_operand_parameter_id  :=
         fnd_number.canonical_to_number(x_operand_parameter_id );

      l_operand_constant_date := to_date(x_operand_constant_date, 'YYYY/MM/DD');

      wms_restrictions_pkg.update_row
	(
	  x_rowid                       => NULL
	 ,x_rule_id                     => l_rule_id
	 ,x_sequence_number            => l_sequence_number
	 ,x_last_updated_by            => l_user_id
	 ,x_last_update_date           => l_sysdate
	 ,x_last_update_login          => 0
	 ,x_parameter_id               => l_parameter_id
	 ,x_operator_code              => l_operator_code
	 ,x_operand_type_code          => l_operand_type_code
	 ,x_operand_constant_number    => l_operand_constant_number
	 ,x_operand_constant_character  => x_operand_constant_character
	 ,x_operand_constant_date      => x_operand_constant_date
	 ,x_operand_parameter_id       => l_operand_parameter_id
	 ,x_operand_expression         => x_operand_expression
	 ,x_operand_flex_value_set_id  => l_operand_flex_value_set_id
	 ,x_logical_operator_code      => l_logical_operator_code
	 ,x_bracket_open               => x_bracket_open
	 ,x_bracket_close              => x_bracket_close
	 ,x_attribute_category         => x_attribute_category
	 ,x_attribute1                 => x_attribute1
	 ,x_attribute2                 => x_attribute2
	 ,x_attribute3                 => x_attribute3
	 ,x_attribute4                 => x_attribute4
	 ,x_attribute5                 => x_attribute5
	 ,x_attribute6                 => x_attribute6
	 ,x_attribute7                 => x_attribute7
	 ,x_attribute8                 => x_attribute8
	 ,x_attribute9                 => x_attribute9
	 ,x_attribute10                => x_attribute10
	 ,x_attribute11                => x_attribute11
	 ,x_attribute12                => x_attribute12
	 ,x_attribute13                => x_attribute13
	 ,x_attribute14                => x_attribute14
	 ,x_attribute15                => x_attribute15
	 );
   EXCEPTION
      WHEN no_data_found THEN
      wms_restrictions_pkg.insert_row
	(
          x_rowid                      => l_row_id
	 ,x_rule_id                    => l_rule_id
	 ,x_sequence_number            => l_sequence_number
	 ,x_last_updated_by            => l_user_id
	 ,x_last_update_date           => l_sysdate
         ,x_created_by                 => l_user_id
	 ,x_creation_date              => l_sysdate
	 ,x_last_update_login          => 0
	 ,x_parameter_id               => l_parameter_id
	 ,x_operator_code              => l_operator_code
	 ,x_operand_type_code          => l_operand_type_code
	 ,x_operand_constant_number    => l_operand_constant_number
	 ,x_operand_constant_character  => x_operand_constant_character
	 ,x_operand_constant_date      => x_operand_constant_date
	 ,x_operand_parameter_id       => x_operand_parameter_id
	 ,x_operand_expression         => x_operand_expression
	 ,x_operand_flex_value_set_id  => l_operand_flex_value_set_id
	 ,x_logical_operator_code      => l_logical_operator_code
	 ,x_bracket_open               => x_bracket_open
	 ,x_bracket_close              => x_bracket_close
	 ,x_attribute_category         => x_attribute_category
	 ,x_attribute1                 => x_attribute1
	 ,x_attribute2                 => x_attribute2
	 ,x_attribute3                 => x_attribute3
	 ,x_attribute4                 => x_attribute4
	 ,x_attribute5                 => x_attribute5
	 ,x_attribute6                 => x_attribute6
	 ,x_attribute7                 => x_attribute7
	 ,x_attribute8                 => x_attribute8
	 ,x_attribute9                 => x_attribute9
	 ,x_attribute10                => x_attribute10
	 ,x_attribute11                => x_attribute11
	 ,x_attribute12                => x_attribute12
	 ,x_attribute13                => x_attribute13
	 ,x_attribute14                => x_attribute14
	 ,x_attribute15                => x_attribute15
	 );
   END;
END load_row;
END WMS_RESTRICTIONS_PKG;

/
