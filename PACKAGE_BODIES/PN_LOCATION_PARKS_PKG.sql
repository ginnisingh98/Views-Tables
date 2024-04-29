--------------------------------------------------------
--  DDL for Package Body PN_LOCATION_PARKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_LOCATION_PARKS_PKG" AS
  -- $Header: PNTRGOFB.pls 115.11 2002/11/12 23:10:48 stripath ship $

PROCEDURE Insert_Row (
                       x_rowid                         IN OUT NOCOPY  VARCHAR2,
                       x_location_park_id                      NUMBER,
                       x_location_park_type                    VARCHAR2,
                       x_parent_location_park_id               NUMBER,
                       x_name                                  VARCHAR2,
                       x_description                           VARCHAR2,
                       x_creation_date                         DATE,
                       x_created_by                            NUMBER,
                       x_last_update_date                      DATE,
                       x_last_updated_by                       NUMBER,
                       x_last_update_login                     NUMBER,
                       x_attribute_category                    VARCHAR2,
                       x_attribute1                            VARCHAR2,
                       x_attribute2                            VARCHAR2,
                       x_attribute3                            VARCHAR2,
                       x_attribute4                            VARCHAR2,
                       x_attribute5                            VARCHAR2,
                       x_attribute6                            VARCHAR2,
                       x_attribute7                            VARCHAR2,
                       x_attribute8                            VARCHAR2,
                       x_attribute9                            VARCHAR2,
                       x_attribute10                           VARCHAR2,
                       x_attribute11                           VARCHAR2,
                       x_attribute12                           VARCHAR2,
                       x_attribute13                           VARCHAR2,
                       x_attribute14                           VARCHAR2,
                       x_attribute15                           VARCHAR2
                     )
IS

   CURSOR c IS
      SELECT rowid
      FROM   pn_location_parks
      WHERE  location_park_id = x_location_park_id
      AND    language = userenv('LANG');

BEGIN

   INSERT INTO pn_location_parks
   (
    location_park_id,
    name,
    location_park_type,
    parent_location_park_id,
    description,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    language,
    source_lang,
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
    attribute15
   )
   SELECT x_location_park_id,
          x_name,
          x_location_park_type,
          x_parent_location_park_id,
          x_description,
          x_last_update_date,
          x_last_updated_by,
          x_creation_date,
          x_created_by,
          x_last_update_login,
          l.language_code,
          userenv('LANG'),
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
          x_attribute15
   FROM   fnd_languages l
   WHERE  l.installed_flag IN ('I', 'B')
   AND    NOT EXISTS (SELECT NULL
                      FROM   pn_location_parks t
                      WHERE  t.location_park_id = x_location_park_id
                      AND    t.language = l.language_code);

   OPEN c;
      FETCH c
      INTO  x_rowid;
      IF c%NOTFOUND THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

END Insert_Row;


PROCEDURE Lock_Row (
                       x_location_park_id              IN     NUMBER,
                       x_location_park_type            IN     VARCHAR2,
                       x_parent_location_park_id       IN     NUMBER,
                       x_name                          IN     VARCHAR2,
                       x_description                   IN     VARCHAR2,
                       x_attribute_category            IN     VARCHAR2,
                       x_attribute1                    IN     VARCHAR2,
                       x_attribute2                    IN     VARCHAR2,
                       x_attribute3                    IN     VARCHAR2,
                       x_attribute4                    IN     VARCHAR2,
                       x_attribute5                    IN     VARCHAR2,
                       x_attribute6                    IN     VARCHAR2,
                       x_attribute7                    IN     VARCHAR2,
                       x_attribute8                    IN     VARCHAR2,
                       x_attribute9                    IN     VARCHAR2,
                       x_attribute10                   IN     VARCHAR2,
                       x_attribute11                   IN     VARCHAR2,
                       x_attribute12                   IN     VARCHAR2,
                       x_attribute13                   IN     VARCHAR2,
                       x_attribute14                   IN     VARCHAR2,
                       x_attribute15                   IN     VARCHAR2
                     )
IS

   CURSOR c1 IS
      SELECT *
      FROM   pn_location_parks
      WHERE  location_park_id = x_location_park_id
      AND    language = userenv('LANG')
      FOR UPDATE OF location_park_id NOWAIT;

   tlinfo c1%ROWTYPE;

BEGIN

   OPEN c1;
      FETCH c1
      INTO  tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.name = x_name)
   THEN
      pn_var_rent_pkg.lock_row_exception('NAME',tlinfo.name);
   END IF;

   IF NOT ((tlinfo.description = x_description)
       OR ((tlinfo.description IS NULL) AND (x_description IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('DESCRIPTION',tlinfo.description);
   END IF;

   IF NOT (tlinfo.location_park_type = x_location_park_type)
   THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_PARK_TYPE',tlinfo.location_park_type);
   END IF;

   IF NOT ((tlinfo.parent_location_park_id = x_parent_location_park_id)
       OR ((tlinfo.parent_location_park_id IS NULL) AND (x_parent_location_park_id IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('PARENT_LOCATION_PARK_ID',tlinfo.parent_location_park_id);
   END IF;

   IF NOT ((tlinfo.attribute_category = x_attribute_category)
       OR ((tlinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.attribute_category);
   END IF;

   IF NOT ((tlinfo.attribute1 = x_attribute1)
       OR ((tlinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.attribute1);
   END IF;

   IF NOT ((tlinfo.attribute2 = x_attribute2)
       OR ((tlinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.attribute2);
   END IF;

   IF NOT ((tlinfo.attribute3 = x_attribute3)
       OR ((tlinfo.attribute3 IS NULL) AND (x_attribute3 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.attribute3);
   END IF;

   IF NOT ((tlinfo.attribute4 = x_attribute4)
       OR ((tlinfo.attribute4 IS NULL) AND (x_attribute4 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.attribute4);
   END IF;

   IF NOT ((tlinfo.attribute5 = x_attribute5)
       OR ((tlinfo.attribute5 IS NULL) AND (x_attribute5 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.attribute5);
   END IF;

   IF NOT ((tlinfo.attribute6 = x_attribute6)
       OR ((tlinfo.attribute6 IS NULL) AND (x_attribute6 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.attribute6);
   END IF;

   IF NOT ((tlinfo.attribute7 = x_attribute7)
       OR ((tlinfo.attribute7 IS NULL) AND (x_attribute7 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.attribute7);
   END IF;

   IF NOT ((tlinfo.attribute8 = x_attribute8)
       OR ((tlinfo.attribute8 IS NULL) AND (x_attribute8 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.attribute8);
   END IF;

   IF NOT ((tlinfo.attribute9 = x_attribute9)
       OR ((tlinfo.attribute9 IS NULL) AND (x_attribute9 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.attribute9);
   END IF;

   IF NOT ((tlinfo.attribute10 = x_attribute10)
       OR ((tlinfo.attribute10 IS NULL) AND (x_attribute10 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.attribute10);
   END IF;

   IF NOT ((tlinfo.attribute11 = x_attribute11)
       OR ((tlinfo.attribute11 IS NULL) AND (x_attribute11 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.attribute11);
   END IF;

   IF NOT ((tlinfo.attribute12 = x_attribute12)
       OR ((tlinfo.attribute12 IS NULL) AND (x_attribute12 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.attribute12);
   END IF;

   IF NOT ((tlinfo.attribute13 = x_attribute13)
       OR ((tlinfo.attribute13 IS NULL) AND (x_attribute13 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.attribute13);
   END IF;

   IF NOT ((tlinfo.attribute14 = x_attribute14)
       OR ((tlinfo.attribute14 IS NULL) AND (x_attribute14 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.attribute14);
   END IF;

   IF NOT ((tlinfo.attribute15 = x_attribute15)
       OR ((tlinfo.attribute15 IS NULL) AND (x_attribute15 IS NULL)))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.attribute15);
   END IF;

   RETURN;

END Lock_Row;


PROCEDURE Update_Row (
                       x_location_park_id              IN NUMBER,
                       x_location_park_type            IN VARCHAR2,
                       x_parent_location_park_id       IN NUMBER,
                       x_name                          IN VARCHAR2,
                       x_description                   IN VARCHAR2,
                       x_last_update_date              IN DATE,
                       x_last_updated_by               IN NUMBER,
                       x_last_update_login             IN NUMBER,
                       x_attribute_category            IN VARCHAR2,
                       x_attribute1                    IN VARCHAR2,
                       x_attribute2                    IN VARCHAR2,
                       x_attribute3                    IN VARCHAR2,
                       x_attribute4                    IN VARCHAR2,
                       x_attribute5                    IN VARCHAR2,
                       x_attribute6                    IN VARCHAR2,
                       x_attribute7                    IN VARCHAR2,
                       x_attribute8                    IN VARCHAR2,
                       x_attribute9                    IN VARCHAR2,
                       x_attribute10                   IN VARCHAR2,
                       x_attribute11                   IN VARCHAR2,
                       x_attribute12                   IN VARCHAR2,
                       x_attribute13                   IN VARCHAR2,
                       x_attribute14                   IN VARCHAR2,
                       x_attribute15                   IN VARCHAR2
                     )
IS
BEGIN
   UPDATE pn_location_parks
   SET    location_park_type          = x_location_park_type,
          parent_location_park_id     = x_parent_location_park_id,
          name                        = x_name,
          description                 = x_description,
          last_update_date            = x_last_update_date,
          last_updated_by             = x_last_updated_by,
          last_update_login           = x_last_update_login,
          source_lang                 = USERENV('lang'),
          attribute_category          = x_attribute_category,
          attribute1                  = x_attribute1,
          attribute2                  = x_attribute2,
          attribute3                  = x_attribute3,
          attribute4                  = x_attribute4,
          attribute5                  = x_attribute5,
          attribute6                  = x_attribute6,
          attribute7                  = x_attribute7,
          attribute8                  = x_attribute8,
          attribute9                  = x_attribute9,
          attribute10                 = x_attribute10,
          attribute11                 = x_attribute11,
          attribute12                 = x_attribute12,
          attribute13                 = x_attribute13,
          attribute14                 = x_attribute14,
          attribute15                 = x_attribute15
   WHERE  location_park_id = x_location_park_id
   AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Update_Row;


PROCEDURE Delete_Row (
                       x_location_park_id              IN     NUMBER
                     )
IS
BEGIN
   DELETE FROM pn_location_parks
   WHERE location_park_id = x_location_park_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_Row;


PROCEDURE Add_Language
IS
BEGIN
   UPDATE pn_location_parks t
   SET (
        name,
        description
       ) =
       (
        SELECT b.name,
               b.description
        FROM pn_location_parks b
        WHERE b.location_park_id = t.location_park_id
        AND b.language = t.source_lang
       )
   WHERE (t.location_park_id,
          t.language
         ) IN
         (SELECT subt.location_park_id,
                 subt.language
          FROM pn_location_parks subb, pn_location_parks subt
          WHERE subb.location_park_id = subt.location_park_id
          AND subb.language = subt.source_lang
          AND (subb.name <> subt.name
               OR subb.description <> subt.description
               OR (subb.description IS NULL AND subt.description IS NOT NULL)
               OR (subb.description IS NOT NULL AND subt.description IS NULL)
              )
         );


   INSERT INTO pn_location_parks
   (
    location_park_id,
    name,
    location_park_type,
    parent_location_park_id,
    description,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    language,
    source_lang,
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
    attribute15
   )
   SELECT
    b.location_park_id,
    b.name,
    b.location_park_type,
    b.parent_location_park_id,
    b.description,
    b.last_update_date,
    b.last_updated_by,
    b.creation_date,
    b.created_by,
    b.last_update_login,
    l.language_code,
    b.source_lang ,
    b.attribute_category,
    b.attribute1,
    b.attribute2,
    b.attribute3,
    b.attribute4,
    b.attribute5,
    b.attribute6,
    b.attribute7,
    b.attribute8,
    b.attribute9,
    b.attribute10,
    b.attribute11,
    b.attribute12,
    b.attribute13,
    b.attribute14,
    b.attribute15
   FROM pn_location_parks b, fnd_languages l
   WHERE l.installed_flag IN ('I', 'B')
   AND b.language = userenv('LANG')
   AND NOT EXISTS (SELECT null
                   FROM pn_location_parks t
                   WHERE t.location_park_id = b.location_park_id
                   AND t.language = l.language_code);

END Add_Language;

END pn_location_parks_pkg;

/
