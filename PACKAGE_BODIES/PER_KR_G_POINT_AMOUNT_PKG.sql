--------------------------------------------------------
--  DDL for Package Body PER_KR_G_POINT_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_G_POINT_AMOUNT_PKG" AS
/* $Header: pekrsg04.pkb 115.1 2002/12/03 09:42:21 viagarwa noship $ */
-------------------------------------------------------------------------------------
PROCEDURE insert_row
(p_row_id                IN OUT NOCOPY VARCHAR2
,p_grade_point_amount_id IN OUT NOCOPY NUMBER
,p_effective_start_date         DATE
,p_effective_end_date           DATE
,p_grade_point_id               NUMBER
,p_grade_point_amount           NUMBER
,p_object_version_number        NUMBER
,p_last_update_date             DATE
,p_last_updated_by              NUMBER
,p_last_update_login            NUMBER
,p_created_by                   NUMBER
,p_creation_date                DATE
,p_attribute_category           VARCHAR2
,p_attribute1                   VARCHAR2
,p_attribute2                   VARCHAR2
,p_attribute3                   VARCHAR2
,p_attribute4                   VARCHAR2
,p_attribute5                   VARCHAR2
,p_attribute6                   VARCHAR2
,p_attribute7                   VARCHAR2
,p_attribute8                   VARCHAR2
,p_attribute9                   VARCHAR2
,p_attribute10                  VARCHAR2
,p_attribute11                  VARCHAR2
,p_attribute12                  VARCHAR2
,p_attribute13                  VARCHAR2
,p_attribute14                  VARCHAR2
,p_attribute15                  VARCHAR2
,p_attribute16                  VARCHAR2
,p_attribute17                  VARCHAR2
,p_attribute18                  VARCHAR2
,p_attribute19                  VARCHAR2
,p_attribute20                  VARCHAR2
,p_attribute21                  VARCHAR2
,p_attribute22                  VARCHAR2
,p_attribute23                  VARCHAR2
,p_attribute24                  VARCHAR2
,p_attribute25                  VARCHAR2
,p_attribute26                  VARCHAR2
,p_attribute27                  VARCHAR2
,p_attribute28                  VARCHAR2
,p_attribute29                  VARCHAR2
,p_attribute30                  VARCHAR2
) IS
  --
  CURSOR c_s1 IS
    SELECT per_kr_g_point_amount_s.NEXTVAL
    FROM   dual;
  --
BEGIN
  --
  OPEN c_s1;
  FETCH c_s1 INTO p_grade_point_amount_id;
  IF (c_s1%NOTFOUND) THEN
    CLOSE c_s1;
    RAISE NO_DATA_FOUND;
  END IF;
  --
  CLOSE c_s1;
  --
  INSERT INTO per_kr_g_point_amount_f
    (grade_point_amount_id
    ,effective_start_date
    ,effective_end_date
    ,grade_point_id
    ,grade_point_amount
    ,object_version_number
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
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
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,attribute21
    ,attribute22
    ,attribute23
    ,attribute24
    ,attribute25
    ,attribute26
    ,attribute27
    ,attribute28
    ,attribute29
    ,attribute30
    ) VALUES (
     p_grade_point_amount_id
    ,p_effective_start_date
    ,p_effective_end_date
    ,p_grade_point_id
    ,p_grade_point_amount
    ,p_object_version_number
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    ,p_created_by
    ,p_creation_date
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_attribute21
    ,p_attribute22
    ,p_attribute23
    ,p_attribute24
    ,p_attribute25
    ,p_attribute26
    ,p_attribute27
    ,p_attribute28
    ,p_attribute29
    ,p_attribute30
    )
    returning rowidtochar(rowid) into p_row_id;
  --
END insert_row;
-------------------------------------------------------------------------------------
PROCEDURE lock_row
(p_row_id                VARCHAR2
,p_grade_point_amount_id NUMBER
,p_effective_start_date  DATE
,p_effective_end_date    DATE
,p_grade_point_id        NUMBER
,p_grade_point_amount    NUMBER
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
,p_attribute_category    VARCHAR2
,p_attribute1            VARCHAR2
,p_attribute2            VARCHAR2
,p_attribute3            VARCHAR2
,p_attribute4            VARCHAR2
,p_attribute5            VARCHAR2
,p_attribute6            VARCHAR2
,p_attribute7            VARCHAR2
,p_attribute8            VARCHAR2
,p_attribute9            VARCHAR2
,p_attribute10           VARCHAR2
,p_attribute11           VARCHAR2
,p_attribute12           VARCHAR2
,p_attribute13           VARCHAR2
,p_attribute14           VARCHAR2
,p_attribute15           VARCHAR2
,p_attribute16           VARCHAR2
,p_attribute17           VARCHAR2
,p_attribute18           VARCHAR2
,p_attribute19           VARCHAR2
,p_attribute20           VARCHAR2
,p_attribute21           VARCHAR2
,p_attribute22           VARCHAR2
,p_attribute23           VARCHAR2
,p_attribute24           VARCHAR2
,p_attribute25           VARCHAR2
,p_attribute26           VARCHAR2
,p_attribute27           VARCHAR2
,p_attribute28           VARCHAR2
,p_attribute29           VARCHAR2
,p_attribute30           VARCHAR2
) IS
  --
  CURSOR c1 IS
    SELECT grade_point_amount_id
          ,effective_start_date
          ,effective_end_date
          ,grade_point_id
          ,grade_point_amount
          ,object_version_number
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
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
          ,attribute16
          ,attribute17
          ,attribute18
          ,attribute19
          ,attribute20
          ,attribute21
          ,attribute22
          ,attribute23
          ,attribute24
          ,attribute25
          ,attribute26
          ,attribute27
          ,attribute28
          ,attribute29
          ,attribute30
    FROM per_kr_g_point_amount_f
    WHERE rowid = chartorowid(p_row_id)
    FOR UPDATE OF grade_point_amount_id NOWAIT;
  --
  recinfo    c1%ROWTYPE;
  --
BEGIN
  --
  OPEN c1;
  FETCH c1 INTO recinfo;
  --
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  --
  CLOSE c1;
  --
  IF (     (recinfo.grade_point_amount_id = p_grade_point_amount_id)
     AND   (recinfo.effective_start_date  = p_effective_start_date)
     AND   (recinfo.effective_end_date    = p_effective_end_date)
     AND   (recinfo.grade_point_id        = p_grade_point_id)
     AND   (  (recinfo.grade_point_amount = p_grade_point_amount)
           OR (   (recinfo.grade_point_amount IS NULL)
              AND (p_grade_point_amount IS NULL)))
     AND   (  (recinfo.object_version_number = p_object_version_number)
           OR (   (recinfo.object_version_number IS NULL)
              AND (p_object_version_number IS NULL)))
     AND   (  (recinfo.last_update_date = p_last_update_date)
           OR (   (recinfo.last_update_date IS NULL)
              AND (p_last_update_date IS NULL)))
     AND   (  (recinfo.last_updated_by = p_last_updated_by)
           OR (   (recinfo.last_updated_by IS NULL)
              AND (p_last_updated_by IS NULL)))
     AND   (  (recinfo.last_update_login = p_last_update_login)
           OR (   (recinfo.last_update_login IS NULL)
              AND (p_last_update_login IS NULL)))
     AND   (  (recinfo.created_by = p_created_by)
           OR (   (recinfo.created_by IS NULL)
              AND (p_created_by IS NULL)))
     AND   (  (recinfo.creation_date = p_creation_date)
           OR (   (recinfo.creation_date IS NULL)
              AND (p_creation_date IS NULL)))
     AND   (  (recinfo.attribute_category = p_attribute_category)
           OR (   (recinfo.attribute_category IS NULL)
              AND (p_attribute_category IS NULL)))
     AND   (  (recinfo.attribute1 = p_attribute1)
           OR (   (recinfo.attribute1 IS NULL)
              AND (p_attribute1 IS NULL)))
     AND   (  (recinfo.attribute2 = p_attribute2)
           OR (   (recinfo.attribute2 IS NULL)
              AND (p_attribute2 IS NULL)))
     AND   (  (recinfo.attribute3 = p_attribute3)
           OR (   (recinfo.attribute3 IS NULL)
              AND (p_attribute3 IS NULL)))
     AND   (  (recinfo.attribute4 = p_attribute4)
           OR (   (recinfo.attribute4 IS NULL)
              AND (p_attribute4 IS NULL)))
     AND   (  (recinfo.attribute5 = p_attribute5)
           OR (   (recinfo.attribute5 IS NULL)
              AND (p_attribute5 IS NULL)))
     AND   (  (recinfo.attribute6 = p_attribute6)
           OR (   (recinfo.attribute6 IS NULL)
              AND (p_attribute6 IS NULL)))
     AND   (  (recinfo.attribute7 = p_attribute7)
           OR (   (recinfo.attribute7 IS NULL)
              AND (p_attribute7 IS NULL)))
     AND   (  (recinfo.attribute8 = p_attribute8)
           OR (   (recinfo.attribute8 IS NULL)
              AND (p_attribute8 IS NULL)))
     AND   (  (recinfo.attribute9 = p_attribute9)
           OR (   (recinfo.attribute9 IS NULL)
              AND (p_attribute9 IS NULL)))
     AND   (  (recinfo.attribute10 = p_attribute10)
           OR (   (recinfo.attribute10 IS NULL)
              AND (p_attribute10 IS NULL)))
     AND   (  (recinfo.attribute11 = p_attribute11)
           OR (   (recinfo.attribute11 IS NULL)
              AND (p_attribute11 IS NULL)))
     AND   (  (recinfo.attribute12 = p_attribute12)
           OR (   (recinfo.attribute12 IS NULL)
              AND (p_attribute12 IS NULL)))
     AND   (  (recinfo.attribute13 = p_attribute13)
           OR (   (recinfo.attribute13 IS NULL)
              AND (p_attribute13 IS NULL)))
     AND   (  (recinfo.attribute14 = p_attribute14)
           OR (   (recinfo.attribute14 IS NULL)
              AND (p_attribute14 IS NULL)))
     AND   (  (recinfo.attribute15 = p_attribute15)
           OR (   (recinfo.attribute15 IS NULL)
              AND (p_attribute15 IS NULL)))
     AND   (  (recinfo.attribute16 = p_attribute16)
           OR (   (recinfo.attribute16 IS NULL)
              AND (p_attribute16 IS NULL)))
     AND   (  (recinfo.attribute17 = p_attribute17)
           OR (   (recinfo.attribute17 IS NULL)
              AND (p_attribute17 IS NULL)))
     AND   (  (recinfo.attribute18 = p_attribute18)
           OR (   (recinfo.attribute18 IS NULL)
              AND (p_attribute18 IS NULL)))
     AND   (  (recinfo.attribute19 = p_attribute19)
           OR (   (recinfo.attribute19 IS NULL)
              AND (p_attribute19 IS NULL)))
     AND   (  (recinfo.attribute20 = p_attribute20)
           OR (   (recinfo.attribute20 IS NULL)
              AND (p_attribute20 IS NULL)))
     AND   (  (recinfo.attribute21 = p_attribute21)
           OR (   (recinfo.attribute21 IS NULL)
              AND (p_attribute21 IS NULL)))
     AND   (  (recinfo.attribute22 = p_attribute22)
           OR (   (recinfo.attribute22 IS NULL)
              AND (p_attribute22 IS NULL)))
     AND   (  (recinfo.attribute23 = p_attribute23)
           OR (   (recinfo.attribute23 IS NULL)
              AND (p_attribute23 IS NULL)))
     AND   (  (recinfo.attribute24 = p_attribute24)
           OR (   (recinfo.attribute24 IS NULL)
              AND (p_attribute24 IS NULL)))
     AND   (  (recinfo.attribute25 = p_attribute25)
           OR (   (recinfo.attribute25 IS NULL)
              AND (p_attribute25 IS NULL)))
     AND   (  (recinfo.attribute26 = p_attribute26)
           OR (   (recinfo.attribute26 IS NULL)
              AND (p_attribute26 IS NULL)))
     AND   (  (recinfo.attribute27 = p_attribute27)
           OR (   (recinfo.attribute27 IS NULL)
              AND (p_attribute27 IS NULL)))
     AND   (  (recinfo.attribute28 = p_attribute28)
           OR (   (recinfo.attribute28 IS NULL)
              AND (p_attribute28 IS NULL)))
     AND   (  (recinfo.attribute29 = p_attribute29)
           OR (   (recinfo.attribute29 IS NULL)
              AND (p_attribute29 IS NULL)))
     AND   (  (recinfo.attribute30 = p_attribute30)
           OR (   (recinfo.attribute30 IS NULL)
              AND (p_attribute30 IS NULL)))
     ) THEN
      RETURN;
  ELSE
    fnd_message.set_name('FND','FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
--
END lock_row;
-------------------------------------------------------------------------------------
PROCEDURE update_row
(p_row_id                VARCHAR2
,p_grade_point_amount_id NUMBER
,p_effective_start_date  DATE
,p_effective_end_date    DATE
,p_grade_point_id        NUMBER
,p_grade_point_amount    NUMBER
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
,p_attribute_category    VARCHAR2
,p_attribute1            VARCHAR2
,p_attribute2            VARCHAR2
,p_attribute3            VARCHAR2
,p_attribute4            VARCHAR2
,p_attribute5            VARCHAR2
,p_attribute6            VARCHAR2
,p_attribute7            VARCHAR2
,p_attribute8            VARCHAR2
,p_attribute9            VARCHAR2
,p_attribute10           VARCHAR2
,p_attribute11           VARCHAR2
,p_attribute12           VARCHAR2
,p_attribute13           VARCHAR2
,p_attribute14           VARCHAR2
,p_attribute15           VARCHAR2
,p_attribute16           VARCHAR2
,p_attribute17           VARCHAR2
,p_attribute18           VARCHAR2
,p_attribute19           VARCHAR2
,p_attribute20           VARCHAR2
,p_attribute21           VARCHAR2
,p_attribute22           VARCHAR2
,p_attribute23           VARCHAR2
,p_attribute24           VARCHAR2
,p_attribute25           VARCHAR2
,p_attribute26           VARCHAR2
,p_attribute27           VARCHAR2
,p_attribute28           VARCHAR2
,p_attribute29           VARCHAR2
,p_attribute30           VARCHAR2
) IS
BEGIN
  UPDATE per_kr_g_point_amount_f
  SET effective_start_date  = p_effective_start_date
     ,effective_end_date    = p_effective_end_date
     ,grade_point_amount    = p_grade_point_amount
     ,object_version_number = p_object_version_number
     ,last_update_date      = p_last_update_date
     ,last_updated_by       = p_last_updated_by
     ,last_update_login     = p_last_update_login
     ,created_by            = p_created_by
     ,creation_date         = p_creation_date
     ,attribute_category    = p_attribute_category
     ,attribute1            = p_attribute1
     ,attribute2            = p_attribute2
     ,attribute3            = p_attribute3
     ,attribute4            = p_attribute4
     ,attribute5            = p_attribute5
     ,attribute6            = p_attribute6
     ,attribute7            = p_attribute7
     ,attribute8            = p_attribute8
     ,attribute9            = p_attribute9
     ,attribute10           = p_attribute10
     ,attribute11           = p_attribute11
     ,attribute12           = p_attribute12
     ,attribute13           = p_attribute13
     ,attribute14           = p_attribute14
     ,attribute15           = p_attribute15
     ,attribute16           = p_attribute16
     ,attribute17           = p_attribute17
     ,attribute18           = p_attribute18
     ,attribute19           = p_attribute19
     ,attribute20           = p_attribute20
     ,attribute21           = p_attribute21
     ,attribute22           = p_attribute22
     ,attribute23           = p_attribute23
     ,attribute24           = p_attribute24
     ,attribute25           = p_attribute25
     ,attribute26           = p_attribute26
     ,attribute27           = p_attribute27
     ,attribute28           = p_attribute28
     ,attribute29           = p_attribute29
     ,attribute30           = p_attribute30
  WHERE rowid = chartorowid(p_row_id);
  --
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
  --
END update_row;
-------------------------------------------------------------------------------------
PROCEDURE delete_row
(p_row_id VARCHAR2
) IS
BEGIN
  --
  DELETE FROM per_kr_g_point_amount_f
  WHERE rowid = chartorowid(p_row_id);
  --
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
--
END delete_row;
-------------------------------------------------------------------------------------
END per_kr_g_point_amount_pkg;

/
