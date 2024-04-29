--------------------------------------------------------
--  DDL for Package Body WMS_STRATEGY_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_STRATEGY_MEMBERS_PKG" AS
/* $Header: WMSPPSMB.pls 120.1 2005/06/20 02:41:10 appldev ship $ */
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
  ,x_date_type_code                 IN     VARCHAR2
  ,x_date_type_lookup_type          IN     VARCHAR2
  ,x_date_type_from                 IN     NUMBER
  ,x_date_type_to                   IN     NUMBER
  )IS
    CURSOR C IS SELECT ROWID FROM WMS_STRATEGY_MEMBERS
      WHERE strategy_id = x_strategy_id
        AND sequence_number = x_sequence_number;
BEGIN

   INSERT INTO WMS_STRATEGY_MEMBERS (
       strategy_id
      ,sequence_number
      ,last_updated_by
      ,last_update_date
      ,created_by
      ,creation_date
      ,last_update_login
      ,rule_id
      ,partial_success_allowed_flag
      ,effective_from
      ,effective_to
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
      ,date_type_code
      ,date_type_lookup_type
      ,date_type_from
      ,date_type_to
    ) values (
       x_strategy_id
      ,x_sequence_number
      ,x_last_updated_by
      ,x_last_update_date
      ,x_created_by
      ,x_creation_date
      ,x_last_update_login
      ,x_rule_id
      ,x_partial_success_allowed_flag
      ,x_effective_from
      ,x_effective_to
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
      ,x_date_type_code
      ,x_date_type_lookup_type
      ,x_date_type_from
      ,x_date_type_to
   );

  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
     CLOSE C;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END INSERT_ROW;
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
  )IS
    CURSOR C IS SELECT
       strategy_id
      ,sequence_number
      ,rule_id
      ,partial_success_allowed_flag
      ,effective_from
      ,effective_to
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
      ,date_type_code
      ,date_type_lookup_type
      ,date_type_from
      ,date_type_to
     FROM WMS_STRATEGY_MEMBERS
     WHERE rowid = x_rowid
     FOR UPDATE OF strategy_id NOWAIT;

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
   IF (    (recinfo.strategy_id = x_strategy_id)
       AND (recinfo.sequence_number = x_sequence_number)
       AND (recinfo.rule_id = x_rule_id)
       AND (recinfo.partial_success_allowed_flag = x_partial_success_allowed_flag)
       AND ((recinfo.effective_from = x_effective_from)
             OR ((recinfo.effective_from IS NULL)
            AND (x_effective_from IS NULL)))
       AND ((recinfo.effective_to = x_effective_to)
             OR ((recinfo.effective_to IS NULL)
            AND (x_effective_to IS NULL)))
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
       AND ((recinfo.date_type_code = x_date_type_code)
             OR ((recinfo.date_type_code IS NULL)
            AND (x_date_type_code IS NULL)))
       AND ((recinfo.date_type_lookup_type = x_date_type_lookup_type)
             OR ((recinfo.date_type_lookup_type IS NULL)
            AND (x_date_type_lookup_type IS NULL)))
       AND ((recinfo.date_type_from = x_date_type_from)
             OR ((recinfo.date_type_from IS NULL)
            AND (x_date_type_from IS NULL)))
       AND ((recinfo.date_type_to = x_date_type_to)
             OR ((recinfo.date_type_to IS NULL)
            AND (x_date_type_to IS NULL)))

   ) THEN
     NULL;
   ELSE
     fnd_message.set_name('FND','FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   END IF;
END LOCK_ROW;
--
PROCEDURE UPDATE_ROW (
   x_rowid                          IN     VARCHAR2
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
  )IS
BEGIN
   IF (x_rowid IS NOT NULL) THEN
      UPDATE WMS_STRATEGY_MEMBERS SET
          strategy_id = x_strategy_id
         ,sequence_number = x_sequence_number
         ,last_updated_by = x_last_updated_by
         ,last_update_date = x_last_update_date
         ,last_update_login = x_last_update_login
         ,rule_id = x_rule_id
         ,partial_success_allowed_flag = x_partial_success_allowed_flag
         ,effective_from = x_effective_from
         ,effective_to = x_effective_to
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
         ,date_type_code = x_date_type_code
         ,date_type_lookup_type = x_date_type_lookup_type
         ,date_type_from = x_date_type_from
         ,date_type_to = x_date_type_to
      WHERE rowid     = x_rowid;
   ELSE
      UPDATE WMS_STRATEGY_MEMBERS SET
          strategy_id = x_strategy_id
         ,sequence_number = x_sequence_number
         ,last_updated_by = x_last_updated_by
         ,last_update_date = x_last_update_date
         ,last_update_login = x_last_update_login
         ,rule_id = x_rule_id
         ,partial_success_allowed_flag = x_partial_success_allowed_flag
         ,effective_from = x_effective_from
         ,effective_to = x_effective_to
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
         ,date_type_code = x_date_type_code
         ,date_type_lookup_type = x_date_type_lookup_type
         ,date_type_from = x_date_type_from
         ,date_type_to = x_date_type_to
      WHERE strategy_id     = x_strategy_id
      AND   sequence_number = x_sequence_number;
   END IF;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;--
PROCEDURE DELETE_ROW (
   x_rowid IN VARCHAR2
  )IS
BEGIN

   DELETE FROM WMS_STRATEGY_MEMBERS
   WHERE rowid = x_rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE LOAD_ROW
  (
   x_strategy_id                    IN     NUMBER
  ,x_owner                          IN     VARCHAR2
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
  ) IS
BEGIN
   DECLARE
      l_strategy_id         NUMBER;
      l_rule_id              NUMBER;
      l_sequence_number      NUMBER;
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
      l_strategy_id := fnd_number.canonical_to_number(x_strategy_id);
      l_rule_id  := fnd_number.canonical_to_number(x_rule_id );
      l_sequence_number :=
	fnd_number.canonical_to_number(x_sequence_number);
      l_date_type_from  :=
        fnd_number.canonical_to_number(x_date_type_from );
      l_date_type_to  :=
        fnd_number.canonical_to_number(x_date_type_to );

      wms_strategy_members_pkg.update_row
	(
	  x_rowid                     => NULL
	 ,x_strategy_id               => l_strategy_id
	 ,x_sequence_number           => l_sequence_number
	 ,x_last_updated_by           => l_user_id
	 ,x_last_update_date          => l_sysdate
	 ,x_last_update_login         => 0
	 ,x_rule_id                   => l_rule_id
	,x_partial_success_allowed_flag => x_partial_success_allowed_flag
	 ,x_effective_from            => x_effective_from
	 ,x_effective_to              => x_effective_to
	 ,x_attribute_category        => x_attribute_category
	 ,x_attribute1                => x_attribute1
	 ,x_attribute2                => x_attribute2
	 ,x_attribute3                => x_attribute3
	 ,x_attribute4                => x_attribute4
	 ,x_attribute5                => x_attribute5
	 ,x_attribute6                => x_attribute6
	 ,x_attribute7                => x_attribute7
	 ,x_attribute8                => x_attribute8
	 ,x_attribute9                => x_attribute9
	 ,x_attribute10               => x_attribute10
	 ,x_attribute11               => x_attribute11
	 ,x_attribute12               => x_attribute12
	 ,x_attribute13               => x_attribute13
	 ,x_attribute14               => x_attribute14
	 ,x_attribute15               => x_attribute15
	 ,x_date_type_code            => x_date_type_code
	 ,x_date_type_lookup_type     => x_date_type_lookup_type
	 ,x_date_type_from            => l_date_type_from
	 ,x_date_type_to              => l_date_type_to
	 );
   EXCEPTION
      WHEN no_data_found THEN
        wms_strategy_members_pkg.insert_row
	(
          x_rowid                     => l_row_id
	 ,x_strategy_id               => l_strategy_id
	 ,x_sequence_number           => l_sequence_number
	 ,x_last_updated_by           => l_user_id
	 ,x_last_update_date          => l_sysdate
         ,x_created_by                => l_user_id
	 ,x_creation_date             => l_sysdate
	 ,x_last_update_login         => 0
	 ,x_rule_id                   => l_rule_id
	,x_partial_success_allowed_flag => x_partial_success_allowed_flag
	 ,x_effective_from            => x_effective_from
	 ,x_effective_to              => x_effective_to
	 ,x_attribute_category        => x_attribute_category
	 ,x_attribute1                => x_attribute1
	 ,x_attribute2                => x_attribute2
	 ,x_attribute3                => x_attribute3
	 ,x_attribute4                => x_attribute4
	 ,x_attribute5                => x_attribute5
	 ,x_attribute6                => x_attribute6
	 ,x_attribute7                => x_attribute7
	 ,x_attribute8                => x_attribute8
	 ,x_attribute9                => x_attribute9
	 ,x_attribute10               => x_attribute10
	 ,x_attribute11               => x_attribute11
	 ,x_attribute12               => x_attribute12
	 ,x_attribute13               => x_attribute13
	 ,x_attribute14               => x_attribute14
	 ,x_attribute15               => x_attribute15
	 ,x_date_type_code            => x_date_type_code
	 ,x_date_type_lookup_type     => x_date_type_lookup_type
	 ,x_date_type_from            => l_date_type_from
	 ,x_date_type_to              => l_date_type_to
	 );
   END;
END load_row;
END WMS_STRATEGY_MEMBERS_PKG;


/
