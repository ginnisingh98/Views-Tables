--------------------------------------------------------
--  DDL for Package Body JG_ZZ_ENTITY_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_ENTITY_ASSOC_PKG" AS
/* $Header: jgzzieab.pls 115.6 2002/11/21 18:00:18 thwon ship $  */

PROCEDURE insert_row( x_rowid IN OUT NOCOPY VARCHAR2,
                      x_entity_association_id NUMBER,
                      x_primary_id_number VARCHAR2,
                      x_associated_entity_id NUMBER,
                      x_id_type VARCHAR2,
                      x_id_number VARCHAR2,
                      x_description VARCHAR2,
                      x_effective_date DATE,
                      x_ineffective_date DATE,
                      x_attribute_category VARCHAR2,
                      x_attribute1 VARCHAR2,
                      x_attribute2 VARCHAR2,
                      x_attribute3 VARCHAR2,
                      x_attribute4 VARCHAR2,
                      x_attribute5 VARCHAR2,
                      x_attribute6 VARCHAR2,
                      x_attribute7 VARCHAR2,
                      x_attribute8 VARCHAR2,
                      x_attribute9 VARCHAR2,
                      x_attribute10 VARCHAR2,
                      x_attribute11 VARCHAR2,
                      x_attribute12 VARCHAR2,
                      x_attribute13 VARCHAR2,
                      x_attribute14 VARCHAR2,
                      x_attribute15 VARCHAR2,
                      x_attribute16 VARCHAR2,
                      x_attribute17 VARCHAR2,
                      x_attribute18 VARCHAR2,
                      x_attribute19 VARCHAR2,
                      x_attribute20 VARCHAR2,
                      x_created_by NUMBER,
                      x_creation_date DATE,
                      x_last_updated_by NUMBER,
                      x_last_update_date DATE,
                      x_last_update_login NUMBER ) IS

  CURSOR C IS SELECT rowid
              FROM jg_zz_entity_assoc
              WHERE entity_association_id = x_entity_association_id;
BEGIN

  INSERT INTO jg_zz_entity_assoc( entity_association_id,
                                  primary_id_number,
                                  associated_entity_id,
                                  id_type,
                                  id_number,
                                  description,
                                  effective_date,
                                  ineffective_date,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15,
                                  attribute16,
                                  attribute17,
                                  attribute18,
                                  attribute19,
                                  attribute20,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login
                                  ) VALUES (
                                  x_entity_association_id,
                                  x_primary_id_number,
                                  x_associated_entity_id,
                                  x_id_type,
                                  x_id_number,
                                  x_description,
                                  x_effective_date,
                                  x_ineffective_date,
                                  x_attribute_category,
                                  x_attribute1,
                                  x_attribute2,
                                  x_attribute3,
                                  x_attribute4,
                                  x_attribute5,
                                  x_attribute6,
                                  x_attribute7,
                                  x_attribute8,
                                  x_attribute9,
                                  x_attribute10,
                                  x_attribute11,
                                  x_attribute12,
                                  x_attribute13,
                                  x_attribute14,
                                  x_attribute15,
                                  x_attribute16,
                                  x_attribute17,
                                  x_attribute18,
                                  x_attribute19,
                                  x_attribute20,
                                  x_created_by,
                                  x_creation_date,
                                  x_last_updated_by,
                                  x_last_update_date,
                                  x_last_update_login );

  OPEN C;
  FETCH C INTO x_rowid;

  IF ( C%NOTFOUND ) THEN

    CLOSE C;
    RAISE NO_DATA_FOUND;

  END IF;

  CLOSE C;

END insert_row;


PROCEDURE lock_row( x_rowid VARCHAR2,
                    x_entity_association_id NUMBER,
                    x_primary_id_number VARCHAR2,
                    x_associated_entity_id NUMBER,
                    x_id_type VARCHAR2,
                    x_id_number VARCHAR2,
                    x_description VARCHAR2,
                    x_effective_date DATE,
                    x_ineffective_date DATE,
                    x_attribute_category VARCHAR2,
                    x_attribute1 VARCHAR2,
                    x_attribute2 VARCHAR2,
                    x_attribute3 VARCHAR2,
                    x_attribute4 VARCHAR2,
                    x_attribute5 VARCHAR2,
                    x_attribute6 VARCHAR2,
                    x_attribute7 VARCHAR2,
                    x_attribute8 VARCHAR2,
                    x_attribute9 VARCHAR2,
                    x_attribute10 VARCHAR2,
                    x_attribute11 VARCHAR2,
                    x_attribute12 VARCHAR2,
                    x_attribute13 VARCHAR2,
                    x_attribute14 VARCHAR2,
                    x_attribute15 VARCHAR2,
                    x_attribute16 VARCHAR2,
                    x_attribute17 VARCHAR2,
                    x_attribute18 VARCHAR2,
                    x_attribute19 VARCHAR2,
                    x_attribute20 VARCHAR2,
                    x_created_by NUMBER,
                    x_creation_date DATE,
                    x_last_updated_by NUMBER,
                    x_last_update_date DATE,
                    x_last_update_login NUMBER ) IS

  CURSOR C IS SELECT *
              FROM jg_zz_entity_assoc
              WHERE rowid = x_rowid
              FOR UPDATE OF entity_association_id NOWAIT;

  recinfo C%ROWTYPE;

BEGIN

  OPEN C;
  FETCH C INTO recinfo;

  IF ( C%NOTFOUND ) THEN

    CLOSE C;
    fnd_message.set_name( 'FND', 'FORM_RECORD_DELETED' );
    app_exception.raise_exception;

  END IF;

  CLOSE C;

  IF(     ( recinfo.entity_association_id = x_entity_association_id )
      AND ( recinfo.primary_id_number = x_primary_id_number )
      AND ( recinfo.associated_entity_id = x_associated_entity_id )
      AND ( recinfo.id_type = x_id_type )
      AND ( recinfo.id_number = x_id_number )
      AND (   ( recinfo.description = x_description )
           OR (    (recinfo.description IS NULL)
               AND (x_description IS NULL)))
      AND ( recinfo.effective_date = x_effective_date )
      AND (   ( recinfo.ineffective_date = x_ineffective_date )
           OR (    (recinfo.ineffective_date IS NULL)
               AND (x_ineffective_date IS NULL)))
      AND (   (recinfo.attribute_category = x_attribute_category)
           OR (    (recinfo.attribute_category IS NULL)
               AND (x_attribute_category IS NULL)))
      AND (   (recinfo.attribute1 = x_attribute1)
           OR (    (recinfo.attribute1 IS NULL)
               AND (x_attribute1 IS NULL)))
      AND (   (recinfo.attribute2 = x_attribute2)
           OR (    (recinfo.attribute2 IS NULL)
               AND (x_attribute2 IS NULL)))
      AND (   (recinfo.attribute3 = x_attribute3)
           OR (    (recinfo.attribute3 IS NULL)
               AND (x_attribute3 IS NULL)))
      AND (   (recinfo.attribute4 = x_attribute4)
           OR (    (recinfo.attribute4 IS NULL)
               AND (x_attribute4 IS NULL)))
      AND (   (recinfo.attribute5 = x_attribute5)
           OR (    (recinfo.attribute5 IS NULL)
               AND (x_attribute5 IS NULL)))
      AND (   (recinfo.attribute6 = x_attribute6)
           OR (    (recinfo.attribute6 IS NULL)
               AND (x_attribute6 IS NULL)))
      AND (   (recinfo.attribute7 = x_attribute7)
           OR (    (recinfo.attribute7 IS NULL)
               AND (x_attribute7 IS NULL)))
      AND (   (recinfo.attribute8 = x_attribute8)
           OR (    (recinfo.attribute8 IS NULL)
               AND (x_attribute8 IS NULL)))
      AND (   (recinfo.attribute9 = x_attribute9)
           OR (    (recinfo.attribute9 IS NULL)
               AND (x_attribute9 IS NULL)))
      AND (   (recinfo.attribute10 = x_attribute10)
           OR (    (recinfo.attribute10 IS NULL)
               AND (x_attribute10 IS NULL)))
      AND (   (recinfo.attribute11 = x_attribute11)
           OR (    (recinfo.attribute11 IS NULL)
               AND (x_attribute11 IS NULL)))
      AND (   (recinfo.attribute12 = x_attribute12)
           OR (    (recinfo.attribute12 IS NULL)
               AND (x_attribute12 IS NULL)))
      AND (   (recinfo.attribute13 = x_attribute13)
           OR (    (recinfo.attribute13 IS NULL)
               AND (x_attribute13 IS NULL)))
      AND (   (recinfo.attribute14 = x_attribute14)
           OR (    (recinfo.attribute14 IS NULL)
               AND (x_attribute14 IS NULL)))
      AND (   (recinfo.attribute15 = x_attribute15)
           OR (    (recinfo.attribute15 IS NULL)
               AND (x_attribute15 IS NULL)))
      AND (   (recinfo.attribute16 = x_attribute16)
           OR (    (recinfo.attribute16 IS NULL)
               AND (x_attribute16 IS NULL)))
      AND (   (recinfo.attribute17 = x_attribute17)
           OR (    (recinfo.attribute17 IS NULL)
               AND (x_attribute17 IS NULL)))
      AND (   (recinfo.attribute18 = x_attribute18)
           OR (    (recinfo.attribute18 IS NULL)
               AND (x_attribute18 IS NULL)))
      AND (   (recinfo.attribute19 = x_attribute19)
           OR (    (recinfo.attribute19 IS NULL)
               AND (x_attribute19 IS NULL)))
      AND (   (recinfo.attribute20 = x_attribute20)
           OR (    (recinfo.attribute20 IS NULL)
               AND (x_attribute20 IS NULL)))
      AND ( recinfo.created_by = x_created_by )
      AND ( recinfo.creation_date = x_creation_date )
      AND ( recinfo.last_updated_by = x_last_updated_by )
      AND ( recinfo.last_update_date = x_last_update_date )
      AND (   (recinfo.last_update_login = x_last_update_login)
           OR (    (recinfo.last_update_login IS NULL)
               AND (x_last_update_login IS NULL)))
  ) THEN

    return;

  ELSE

    fnd_message.set_name( 'FND', 'FORM_RECORD_CHANGED' );
    app_exception.raise_exception;

  END IF;

END lock_row;


PROCEDURE update_row( x_rowid VARCHAR2,
                      x_entity_association_id NUMBER,
                      x_primary_id_number VARCHAR2,
                      x_associated_entity_id NUMBER,
                      x_id_type VARCHAR2,
                      x_id_number VARCHAR2,
                      x_description VARCHAR2,
                      x_effective_date DATE,
                      x_ineffective_date DATE,
                      x_attribute_category VARCHAR2,
                      x_attribute1 VARCHAR2,
                      x_attribute2 VARCHAR2,
                      x_attribute3 VARCHAR2,
                      x_attribute4 VARCHAR2,
                      x_attribute5 VARCHAR2,
                      x_attribute6 VARCHAR2,
                      x_attribute7 VARCHAR2,
                      x_attribute8 VARCHAR2,
                      x_attribute9 VARCHAR2,
                      x_attribute10 VARCHAR2,
                      x_attribute11 VARCHAR2,
                      x_attribute12 VARCHAR2,
                      x_attribute13 VARCHAR2,
                      x_attribute14 VARCHAR2,
                      x_attribute15 VARCHAR2,
                      x_attribute16 VARCHAR2,
                      x_attribute17 VARCHAR2,
                      x_attribute18 VARCHAR2,
                      x_attribute19 VARCHAR2,
                      x_attribute20 VARCHAR2,
                      x_created_by NUMBER,
                      x_creation_date DATE,
                      x_last_updated_by NUMBER,
                      x_last_update_date DATE,
                      x_last_update_login NUMBER ) IS
BEGIN

  UPDATE jg_zz_entity_assoc
  SET entity_association_id = x_entity_association_id,
      primary_id_number     = x_primary_id_number,
      associated_entity_id  = x_associated_entity_id,
      id_type               = x_id_type,
      id_number             = x_id_number,
      description           = x_description,
      effective_date        = x_effective_date,
      ineffective_date      = x_ineffective_date,
      attribute_category    = x_attribute_category,
      attribute1            = x_attribute1,
      attribute2            = x_attribute2,
      attribute3            = x_attribute3,
      attribute4            = x_attribute4,
      attribute5            = x_attribute5,
      attribute6            = x_attribute6,
      attribute7            = x_attribute7,
      attribute8            = x_attribute8,
      attribute9            = x_attribute9,
      attribute10           = x_attribute10,
      attribute11           = x_attribute11,
      attribute12           = x_attribute12,
      attribute13           = x_attribute13,
      attribute14           = x_attribute14,
      attribute15           = x_attribute15,
      attribute16           = x_attribute16,
      attribute17           = x_attribute17,
      attribute18           = x_attribute18,
      attribute19           = x_attribute19,
      attribute20           = x_attribute20,
      created_by            = x_created_by,
      creation_date         = x_creation_date,
      last_updated_by       = x_last_updated_by,
      last_update_date      = x_last_update_date,
      last_update_login     = x_last_update_login
  WHERE rowid = x_rowid;

  IF ( SQL%NOTFOUND ) THEN

    RAISE NO_DATA_FOUND;

  END IF;

END update_row;


END JG_ZZ_ENTITY_ASSOC_PKG;

/
