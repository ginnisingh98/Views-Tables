--------------------------------------------------------
--  DDL for Package Body CN_SEC_PROF_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SEC_PROF_ASSIGNS_PKG" AS
/* $Header: cntspfab.pls 115.6 2001/10/29 17:16:56 pkm ship    $ */
--
-- Package Name
--   CN_SEC_PROF_ASSIGNS_PKG
-- Purpose
--   Table handler for CN_SEC_PROF_ASSIGNS
-- Form
--   CNSPROF
-- Block
--   CN_SVC_GRP_ASSIGNS
--
-- History
--   28-Jul-99  Yonghong Mao  Created

PROCEDURE get_sec_prof_assign_id(x_sec_prof_assign_id  IN OUT NUMBER) IS
BEGIN
   SELECT cn_sec_prof_assigns_s.NEXTVAL
     INTO x_sec_prof_assign_id
     FROM dual;
END get_sec_prof_assign_id;

PROCEDURE Insert_Row( x_new_rec IN OUT sec_prof_assign_rec_type) IS
   CURSOR c IS
      SELECT 1
	FROM cn_sec_prof_assigns
	WHERE sec_prof_assign_id = x_new_rec.sec_prof_assign_id;
   l_dummy number;
BEGIN
   IF x_new_rec.sec_prof_assign_id IS NULL THEN
      get_sec_prof_assign_id(x_new_rec.sec_prof_assign_id);
   END IF;

   SELECT
     Decode(x_new_rec.end_date,
	    fnd_api.g_miss_date, NULL,
	    x_new_rec.end_date),
     Decode(x_new_rec.attribute_category,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute_category),
     Decode(x_new_rec.attribute1,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute1),
     Decode(x_new_rec.attribute2,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute2),
     Decode(x_new_rec.attribute3,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute3),
     Decode(x_new_rec.attribute4,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute4),
     Decode(x_new_rec.attribute5,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute5),
     Decode(x_new_rec.attribute6,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute6),
     Decode(x_new_rec.attribute7,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute7),
     Decode(x_new_rec.attribute8,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute8),
     Decode(x_new_rec.attribute9,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute9),
     Decode(x_new_rec.attribute10,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute10),
     Decode(x_new_rec.attribute11,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute11),
     Decode(x_new_rec.attribute12,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute12),
     Decode(x_new_rec.attribute13,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute13),
     Decode(x_new_rec.attribute14,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute14),
     Decode(x_new_rec.attribute15,
	    fnd_api.g_miss_char, NULL,
	    x_new_rec.attribute15),
     Decode(x_new_rec.created_by,
	    cn_api.g_miss_id, g_created_by,
	    x_new_rec.created_by),
     Decode(x_new_rec.creation_date,
	    fnd_api.g_miss_date, g_creation_date,
	    x_new_rec.creation_date),
     Decode(x_new_rec.last_update_login,
	    cn_api.g_miss_id, g_last_update_login,
	    x_new_rec.last_update_login),
     Decode(x_new_rec.last_update_date,
	    fnd_api.g_miss_date, g_last_update_date,
	    x_new_rec.last_update_date),
     Decode(x_new_rec.last_updated_by,
	    cn_api.g_miss_id, g_last_updated_by,
	    x_new_rec.last_updated_by)
     INTO
     x_new_rec.end_date,
     x_new_rec.attribute_category,
     x_new_rec.attribute1,
     x_new_rec.attribute2,
     x_new_rec.attribute3,
     x_new_rec.attribute4,
     x_new_rec.attribute5,
     x_new_rec.attribute6,
     x_new_rec.attribute7,
     x_new_rec.attribute8,
     x_new_rec.attribute9,
     x_new_rec.attribute10,
     x_new_rec.attribute11,
     x_new_rec.attribute12,
     x_new_rec.attribute13,
     x_new_rec.attribute14,
     x_new_rec.attribute15,
     x_new_rec.created_by,
     x_new_rec.creation_date,
     x_new_rec.last_update_login,
     x_new_rec.last_update_date,
     x_new_rec.last_updated_by
     FROM dual;

   INSERT INTO cn_sec_prof_assigns
     (sec_prof_assign_id,
      security_profile_id,
      salesrep_id,
      start_date,
      end_date,
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
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by
      )
     VALUES
     (x_new_rec.sec_prof_assign_id,
      x_new_rec.security_profile_id,
      x_new_rec.salesrep_id,
      x_new_rec.start_date,
      x_new_rec.end_date,
      x_new_rec.attribute_category,
      x_new_rec.attribute1,
      x_new_rec.attribute2,
      x_new_rec.attribute3,
      x_new_rec.attribute4,
      x_new_rec.attribute5,
      x_new_rec.attribute6,
      x_new_rec.attribute7,
      x_new_rec.attribute8,
      x_new_rec.attribute9,
      x_new_rec.attribute10,
      x_new_rec.attribute11,
      x_new_rec.attribute12,
      x_new_rec.attribute13,
      x_new_rec.attribute14,
      x_new_rec.attribute15,
      x_new_rec.created_by,
      x_new_rec.creation_date,
      x_new_rec.last_update_login,
      x_new_rec.last_update_date,
      x_new_rec.last_updated_by
      );

   OPEN c;
   FETCH c INTO l_dummy;
   IF (c%notfound) THEN
      CLOSE c;
      RAISE no_data_found;
   END IF;
   CLOSE c;

END Insert_Row;

PROCEDURE Update_Row(x_new_rec  sec_prof_assign_rec_type) IS
     CURSOR c IS
	SELECT *
	  FROM cn_sec_prof_assigns
	  WHERE sec_prof_assign_id = x_new_rec.sec_prof_assign_id
	  FOR UPDATE OF sec_prof_assign_id nowait;

     rec c%ROWTYPE;

BEGIN
   OPEN c;
   FETCH c INTO rec;

   IF (c%notfound) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c;
   SELECT
     Decode(x_new_rec.security_profile_id,
	    cn_api.g_miss_id, rec.security_profile_id,
	    x_new_rec.security_profile_id),
     Decode(x_new_rec.salesrep_id,
	    cn_api.g_miss_id, rec.salesrep_id,
	    x_new_rec.salesrep_id),
     Decode(x_new_rec.start_date,
	    fnd_api.g_miss_date, rec.start_date,
	    x_new_rec.start_date),
     Decode(x_new_rec.end_date,
	    fnd_api.g_miss_date, rec.end_date,
	    x_new_rec.end_date),
     Decode(x_new_rec.attribute_category,
	    fnd_api.g_miss_char, rec.attribute_category,
	    x_new_rec.attribute_category),
     Decode(x_new_rec.attribute1,
	    fnd_api.g_miss_char, rec.attribute1,
	    x_new_rec.attribute1),
     Decode(x_new_rec.attribute2,
	    fnd_api.g_miss_char, rec.attribute2,
	    x_new_rec.attribute2),
     Decode(x_new_rec.attribute3,
	    fnd_api.g_miss_char, rec.attribute3,
	    x_new_rec.attribute3),
     Decode(x_new_rec.attribute4,
	    fnd_api.g_miss_char, rec.attribute4,
	    x_new_rec.attribute4),
     Decode(x_new_rec.attribute5,
	    fnd_api.g_miss_char, rec.attribute5,
	    x_new_rec.attribute5),
     Decode(x_new_rec.attribute6,
	    fnd_api.g_miss_char, rec.attribute6,
	    x_new_rec.attribute6),
     Decode(x_new_rec.attribute7,
	    fnd_api.g_miss_char, rec.attribute7,
	    x_new_rec.attribute7),
     Decode(x_new_rec.attribute8,
	    fnd_api.g_miss_char, rec.attribute8,
	    x_new_rec.attribute8),
     Decode(x_new_rec.attribute9,
	    fnd_api.g_miss_char, rec.attribute9,
	    x_new_rec.attribute9),
     Decode(x_new_rec.attribute10,
	    fnd_api.g_miss_char, rec.attribute10,
	    x_new_rec.attribute10),
     Decode(x_new_rec.attribute11,
	    fnd_api.g_miss_char, rec.attribute11,
	    x_new_rec.attribute11),
     Decode(x_new_rec.attribute12,
	    fnd_api.g_miss_char, rec.attribute12,
	    x_new_rec.attribute12),
     Decode(x_new_rec.attribute13,
	    fnd_api.g_miss_char, rec.attribute13,
	    x_new_rec.attribute13),
     Decode(x_new_rec.attribute14,
	    fnd_api.g_miss_char, rec.attribute14,
	    x_new_rec.attribute14),
     Decode(x_new_rec.attribute15,
	    fnd_api.g_miss_char, rec.attribute15,
	    x_new_rec.attribute15),
     Decode(x_new_rec.last_update_login,
	    cn_api.g_miss_id, g_last_update_login,
	    x_new_rec.last_update_login),
     Decode(x_new_rec.last_update_date,
	    fnd_api.g_miss_date, g_last_update_date,
	    x_new_rec.last_update_date),
     Decode(x_new_rec.last_updated_by,
	    cn_api.g_miss_id, g_last_updated_by,
	    x_new_rec.last_updated_by)
     INTO
     rec.security_profile_id,
     rec.salesrep_id,
     rec.start_date,
     rec.end_date,
     rec.attribute_category,
     rec.attribute1,
     rec.attribute2,
     rec.attribute3,
     rec.attribute4,
     rec.attribute5,
     rec.attribute6,
     rec.attribute7,
     rec.attribute8,
     rec.attribute9,
     rec.attribute10,
     rec.attribute11,
     rec.attribute12,
     rec.attribute13,
     rec.attribute14,
     rec.attribute15,
     rec.last_update_login,
     rec.last_update_date,
     rec.last_updated_by
     FROM dual;

   UPDATE cn_sec_prof_assigns SET
     security_profile_id = rec.security_profile_id,
     salesrep_id = rec.salesrep_id,
     start_date = rec.start_date,
     end_date   = rec.end_date,
     attribute_category = rec.attribute_category,
     attribute1 = rec.attribute1,
     attribute2 = rec.attribute2,
     attribute3 = rec.attribute3,
     attribute4 = rec.attribute4,
     attribute5 = rec.attribute5,
     attribute6 = rec.attribute6,
     attribute7 = rec.attribute7,
     attribute8 = rec.attribute8,
     attribute9 = rec.attribute9,
     attribute10 = rec.attribute10,
     attribute11 = rec.attribute11,
     attribute12 = rec.attribute12,
     attribute13 = rec.attribute13,
     attribute14 = rec.attribute14,
     attribute15 = rec.attribute15,
     last_update_login = rec.last_update_login,
     last_update_date = rec.last_update_date,
     last_updated_by = rec.last_updated_by
     WHERE sec_prof_assign_id = x_new_rec.sec_prof_assign_id;

   IF (SQL%notfound) THEN
      RAISE no_data_found;
   END IF;

END Update_Row;

PROCEDURE Lock_Row(x_rec   sec_prof_assign_rec_type) IS
   CURSOR c IS
      SELECT *
	FROM cn_sec_prof_assigns
	WHERE sec_prof_assign_id = x_rec.sec_prof_assign_id
	FOR UPDATE OF sec_prof_assign_id nowait;
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

   IF ( (recinfo.sec_prof_assign_id = x_rec.sec_prof_assign_id) AND
	(recinfo.security_profile_id  = x_rec.security_profile_id) AND
	(recinfo.salesrep_id        = x_rec.salesrep_id) AND
	(recinfo.start_date        = x_rec.start_date) AND
	(
	  (recinfo.end_date        = x_rec.end_date) OR
	  (recinfo.end_date IS NULL AND x_rec.end_date IS NULL)
	) AND
	(
	  (recinfo.attribute_category = x_rec.attribute_category) OR
	  (recinfo.attribute_category IS NULL AND x_rec.attribute_category IS NULL)
	) AND
	(
	  (recinfo.attribute1      = x_rec.attribute1) OR
	  (recinfo.attribute1 IS NULL AND x_rec.attribute1 IS NULL)
	) AND
	(
	  (recinfo.attribute2      = x_rec.attribute2) OR
	  (recinfo.attribute2 IS NULL AND x_rec.attribute2 IS NULL)
	) AND
	(
	  (recinfo.attribute3      = x_rec.attribute3) OR
	  (recinfo.attribute3 IS NULL AND x_rec.attribute3 IS NULL)
	) AND
	(
	  (recinfo.attribute4      = x_rec.attribute4) OR
	  (recinfo.attribute4 IS NULL AND x_rec.attribute4 IS NULL)
	) AND
	(
	  (recinfo.attribute5      = x_rec.attribute5) OR
	  (recinfo.attribute5 IS NULL AND x_rec.attribute5 IS NULL)
	) AND
	(
	  (recinfo.attribute6      = x_rec.attribute6) OR
	  (recinfo.attribute6 IS NULL AND x_rec.attribute6 IS NULL)
	) AND
	(
	  (recinfo.attribute7      = x_rec.attribute7) OR
	  (recinfo.attribute7 IS NULL AND x_rec.attribute7 IS NULL)
	) AND
	(
	  (recinfo.attribute8      = x_rec.attribute8) OR
	  (recinfo.attribute8 IS NULL AND x_rec.attribute8 IS NULL)
	) AND
	(
	  (recinfo.attribute9      = x_rec.attribute9) OR
	  (recinfo.attribute9 IS NULL AND x_rec.attribute9 IS NULL)
	) AND
	(
	  (recinfo.attribute10      = x_rec.attribute10) OR
	  (recinfo.attribute10 IS NULL AND x_rec.attribute10 IS NULL)
	) AND
	(
	  (recinfo.attribute11      = x_rec.attribute11) OR
	  (recinfo.attribute11 IS NULL AND x_rec.attribute11 IS NULL)
	) AND
	(
	  (recinfo.attribute12      = x_rec.attribute12) OR
	  (recinfo.attribute12 IS NULL AND x_rec.attribute12 IS NULL)
	) AND
	(
	  (recinfo.attribute13      = x_rec.attribute13) OR
	  (recinfo.attribute13 IS NULL AND x_rec.attribute13 IS NULL)
	) AND
	(
	  (recinfo.attribute14      = x_rec.attribute14) OR
	  (recinfo.attribute14 IS NULL AND x_rec.attribute14 IS NULL)
	) AND
	(
	  (recinfo.attribute15     = x_rec.attribute15) OR
	  (recinfo.attribute15 IS NULL AND x_rec.attribute15 IS NULL)
	)
      ) THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   END IF;

END Lock_Row;

PROCEDURE Delete_Row(x_sec_prof_assign_id                NUMBER) IS
BEGIN
   DELETE cn_sec_prof_assigns
     WHERE sec_prof_assign_id = x_sec_prof_assign_id;

   IF (SQL%notfound) THEN
      RAISE no_data_found;
   END IF;

END Delete_Row;

END CN_SEC_PROF_ASSIGNS_PKG;

/
