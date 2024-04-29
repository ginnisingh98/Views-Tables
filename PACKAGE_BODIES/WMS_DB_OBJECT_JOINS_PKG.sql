--------------------------------------------------------
--  DDL for Package Body WMS_DB_OBJECT_JOINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DB_OBJECT_JOINS_PKG" AS
/* $Header: WMSPDOJB.pls 120.1 2005/06/20 04:35:20 appldev ship $ */
--
PROCEDURE INSERT_ROW (
   x_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,x_db_object_id                   IN     NUMBER
  ,x_type_code                      IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_created_by                     IN     NUMBER
  ,x_creation_date                  IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_parent_parameter_id            IN     NUMBER
  ,x_user_defined_flag              IN     VARCHAR2
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
    CURSOR C IS SELECT ROWID FROM WMS_DB_OBJECT_JOINS
      WHERE db_object_id = x_db_object_id
        AND sequence_number = x_sequence_number;
BEGIN

   INSERT INTO WMS_DB_OBJECT_JOINS (
       db_object_id
      ,type_code
      ,sequence_number
      ,last_updated_by
      ,last_update_date
      ,created_by
      ,creation_date
      ,last_update_login
      ,parameter_id
      ,parent_parameter_id
      ,user_defined_flag
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
       x_db_object_id
      ,x_type_code
      ,x_sequence_number
      ,x_last_updated_by
      ,x_last_update_date
      ,x_created_by
      ,x_creation_date
      ,x_last_update_login
      ,x_parameter_id
      ,x_parent_parameter_id
      ,x_user_defined_flag
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
--
PROCEDURE LOCK_ROW (
   x_rowid                          IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,x_db_object_id                   IN     NUMBER
  ,x_type_code                      IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_parent_parameter_id            IN     NUMBER
  ,x_user_defined_flag              IN     VARCHAR2
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
       db_object_id
      ,type_code
      ,sequence_number
      ,parameter_id
      ,parent_parameter_id
      ,user_defined_flag
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
     FROM WMS_DB_OBJECT_JOINS
     WHERE rowid = x_rowid
     FOR UPDATE OF db_object_id NOWAIT;

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
   IF (    (recinfo.db_object_id = x_db_object_id)
       AND (recinfo.type_code    = x_type_code)
       AND (recinfo.sequence_number = x_sequence_number)
       AND (recinfo.parameter_id = x_parameter_id)
       AND (recinfo.parent_parameter_id = x_parent_parameter_id)
       AND (recinfo.user_defined_flag = x_user_defined_flag)
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
--
PROCEDURE UPDATE_ROW (
   x_db_object_id                   IN     NUMBER
  ,x_type_code                      IN     NUMBER
  ,x_sequence_number                IN     NUMBER
  ,x_last_updated_by                IN     NUMBER
  ,x_last_update_date               IN     DATE
  ,x_last_update_login              IN     NUMBER
  ,x_parameter_id                   IN     NUMBER
  ,x_parent_parameter_id            IN     NUMBER
  ,x_user_defined_flag              IN     VARCHAR2
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
   UPDATE WMS_DB_OBJECT_JOINS SET
       last_updated_by = x_last_updated_by
      ,last_update_date = x_last_update_date
      ,last_update_login = x_last_update_login
      ,parameter_id = x_parameter_id
      ,parent_parameter_id = x_parent_parameter_id
      ,user_defined_flag = x_user_defined_flag
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
   WHERE db_object_id    = x_db_object_id
   AND   type_code       = x_type_code
   AND   sequence_number = x_sequence_number;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;--
PROCEDURE DELETE_ROW (
   x_rowid IN VARCHAR2
  )IS
BEGIN

   DELETE FROM WMS_DB_OBJECT_JOINS
   WHERE rowid = x_rowid;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;
PROCEDURE load_row
  (
   x_db_object_id                   IN     VARCHAR2
  ,x_type_code                      IN     VARCHAR2
  ,x_sequence_number                IN     VARCHAR2
  ,x_owner                          IN     VARCHAR2
  ,x_parameter_id                   IN     VARCHAR2
  ,x_parent_parameter_id            IN     VARCHAR2
  ,x_user_defined_flag              IN     VARCHAR2
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
  ) IS
BEGIN
   DECLARE
      l_db_object_id         NUMBER;
      l_type_code            NUMBER;
      l_sequence_number      NUMBER;
      l_parameter_id         NUMBER;
      l_parent_parameter_id  NUMBER;
      l_user_id              NUMBER := 0;
      l_row_id               VARCHAR2(64);
      l_sysdate              DATE;
   BEGIN
      IF (x_owner = 'SEED') THEN
	 l_user_id := 1;
      END IF;
      --
      SELECT Sysdate INTO l_sysdate FROM dual;
      l_db_object_id := fnd_number.canonical_to_number(x_db_object_id);
      l_type_code :=
	fnd_number.canonical_to_number(x_type_code);
      l_sequence_number :=
	fnd_number.canonical_to_number(x_sequence_number);
      l_parameter_id :=
	fnd_number.canonical_to_number(x_parameter_id);
      l_parent_parameter_id :=
	fnd_number.canonical_to_number(x_parent_parameter_id);
      wms_db_object_joins_pkg.update_row
	(
	  x_db_object_id              => l_db_object_id
	 ,x_type_code                 => l_type_code
	 ,x_sequence_number           => l_sequence_number
	 ,x_last_updated_by           => l_user_id
	 ,x_last_update_date          => l_sysdate
	 ,x_last_update_login         => 0
	 ,x_parameter_id              => l_parameter_id
	 ,x_parent_parameter_id       => l_parent_parameter_id
	 ,x_user_defined_flag         => x_user_defined_flag
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
	 );
   EXCEPTION
      WHEN no_data_found THEN
	 wms_db_object_joins_pkg.insert_row
	   (
	     x_rowid                   => l_row_id
	    ,x_db_object_id            => l_db_object_id
	    ,x_type_code               => l_type_code
	    ,x_sequence_number         => l_sequence_number
	    ,x_last_updated_by         => l_user_id
	    ,x_last_update_date        => l_sysdate
 	    ,x_created_by              => l_user_id
	    ,x_creation_date           => l_sysdate
	    ,x_last_update_login       => 0
  	    ,x_parameter_id            => l_parameter_id
	    ,x_parent_parameter_id     => l_parent_parameter_id
	    ,x_user_defined_flag       => x_user_defined_flag
	    ,x_attribute_category      => x_attribute_category
	    ,x_attribute1              => x_attribute1
	    ,x_attribute2              => x_attribute2
	    ,x_attribute3              => x_attribute3
	    ,x_attribute4              => x_attribute4
	    ,x_attribute5              => x_attribute5
	    ,x_attribute6              => x_attribute6
	    ,x_attribute7              => x_attribute7
	    ,x_attribute8              => x_attribute8
	    ,x_attribute9              => x_attribute9
	    ,x_attribute10             => x_attribute10
	    ,x_attribute11             => x_attribute11
	    ,x_attribute12             => x_attribute12
	    ,x_attribute13             => x_attribute13
	    ,x_attribute14             => x_attribute14
	    ,x_attribute15	       => x_attribute15
	   );
   END;
END load_row;
END WMS_DB_OBJECT_JOINS_PKG;

/
