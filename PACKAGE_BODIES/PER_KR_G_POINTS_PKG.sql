--------------------------------------------------------
--  DDL for Package Body PER_KR_G_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_G_POINTS_PKG" AS
/* $Header: pekrsg03.pkb 115.1 2002/12/03 09:40:42 viagarwa noship $ */
-------------------------------------------------------------------------------------
PROCEDURE insert_row
(p_row_id         IN OUT NOCOPY VARCHAR2
,p_grade_point_id IN OUT NOCOPY NUMBER
,p_grade_id              NUMBER
,p_grade_point_name      VARCHAR2
,p_sequence              NUMBER
,p_enabled_flag          VARCHAR2
,p_start_date_active     DATE
,p_end_date_active       DATE
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
) IS
  --
  CURSOR c_s1 IS
    SELECT per_kr_g_points_s.NEXTVAL
    FROM   dual;
  --
BEGIN
  --
  OPEN c_s1;
  FETCH c_s1 INTO p_grade_point_id;
  IF (c_s1%NOTFOUND) THEN
    CLOSE c_s1;
    RAISE NO_DATA_FOUND;
  END IF;
  --
  CLOSE c_s1;
  --
  INSERT INTO per_kr_g_points
    (grade_point_id
    ,grade_id
    ,grade_point_name
    ,sequence
    ,enabled_flag
    ,start_date_active
    ,end_date_active
    ,object_version_number
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    ) VALUES (
     p_grade_point_id
    ,p_grade_id
    ,p_grade_point_name
    ,p_sequence
    ,p_enabled_flag
    ,p_start_date_active
    ,p_end_date_active
    ,p_object_version_number
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    ,p_created_by
    ,p_creation_date
    )
    returning rowidtochar(rowid) into p_row_id;
  --
END insert_row;
-------------------------------------------------------------------------------------
PROCEDURE lock_row
(p_row_id                VARCHAR2
,p_grade_point_id        NUMBER
,p_grade_id              NUMBER
,p_grade_point_name      VARCHAR2
,p_sequence              NUMBER
,p_enabled_flag          VARCHAR2
,p_start_date_active     DATE
,p_end_date_active       DATE
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
) IS
  --
  CURSOR c1 IS
    SELECT grade_point_id
          ,grade_id
          ,grade_point_name
          ,sequence
          ,enabled_flag
          ,start_date_active
          ,end_date_active
          ,object_version_number
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
    FROM per_kr_g_points
    WHERE rowid = chartorowid(p_row_id)
    FOR UPDATE of grade_point_id NOWAIT;
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
  IF
     (     (recinfo.grade_point_id    = p_grade_point_id)
     AND   (recinfo.grade_id          = p_grade_id)
     AND   (recinfo.grade_point_name  = p_grade_point_name)
     AND   (recinfo.sequence          = p_sequence)
     AND   (recinfo.enabled_flag      = p_enabled_flag)
     AND   (  (recinfo.start_date_active = p_start_date_active)
           OR (   (recinfo.start_date_active IS NULL)
              AND (p_start_date_active IS NULL)))
     AND   (  (recinfo.end_date_active = p_end_date_active)
           OR (   (recinfo.end_date_active IS NULL)
              AND (p_end_date_active IS NULL)))
     AND   (  (recinfo.object_version_number = p_object_version_number)
           OR (   (recinfo.object_version_number IS NULL)
              AND (p_object_version_number IS NULL)))
     AND   (  (recinfo.last_update_date = p_last_update_date)
           OR (   (recinfo.last_update_date IS NULL)
              AND (p_last_update_date IS NULL)))
     AND   (  (recinfo.last_updated_by = p_last_updated_by)
           OR (   (recinfo.last_updated_by IS NULL))
              AND (p_last_updated_by IS NULL))
     AND   (  (recinfo.last_update_login = p_last_update_login)
           OR (   (recinfo.last_update_login IS NULL)
              AND (p_last_update_login IS NULL)))
     AND   (  (recinfo.created_by = p_created_by)
           OR (   (recinfo.last_updated_by IS NULL)
              AND (p_created_by IS NULL)))
     AND   (  (recinfo.creation_date = p_creation_date)
           OR (   (recinfo.creation_date IS NULL)
              AND (p_creation_date IS NULL)))
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
,p_grade_point_id        NUMBER
,p_grade_id              NUMBER
,p_grade_point_name      VARCHAR2
,p_sequence              NUMBER
,p_enabled_flag          VARCHAR2
,p_start_date_active     DATE
,p_end_date_active       DATE
,p_object_version_number NUMBER
,p_last_update_date      DATE
,p_last_updated_by       NUMBER
,p_last_update_login     NUMBER
,p_created_by            NUMBER
,p_creation_date         DATE
) IS
BEGIN
  UPDATE per_kr_g_points
  SET sequence                 =p_sequence
     ,grade_point_name         =p_grade_point_name
     ,enabled_flag             =p_enabled_flag
     ,start_date_active        =p_start_date_active
     ,end_date_active          =p_end_date_active
     ,object_version_number    =p_object_version_number
     ,last_update_date         =p_last_update_date
     ,last_updated_by          =p_last_updated_by
     ,last_update_login        =p_last_update_login
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
  DELETE FROM per_kr_g_points
  WHERE rowid = chartorowid(p_row_id);
  --
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
  --
END delete_row;
-------------------------------------------------------------------------------------
END per_kr_g_points_pkg;

/
