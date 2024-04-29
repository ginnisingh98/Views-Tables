--------------------------------------------------------
--  DDL for Package Body CN_INT_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_INT_ASSIGN_PKG" AS
/* $Header: cntintab.pls 120.2 2005/09/19 12:05:01 ymao noship $ */
--
-- Package Name
--   CN_INT_ASSIGN_PKG
-- Purpose
--   Table handler for CN_CAL_PER_INT_TYPES
-- Form
--   CNINTTP
-- Block
--   INTERVAL_ASSIGNS
--
-- History
--   16-Aug-99  Yonghong Mao  Created

PROCEDURE insert_row
  ( x_cal_per_int_type_id  IN OUT  NOCOPY cn_cal_per_int_types.cal_per_int_type_id%TYPE,
    x_org_id                       cn_cal_per_int_types.org_id%TYPE,
    x_interval_type_id             cn_cal_per_int_types.interval_type_id%TYPE,
    x_cal_period_id                cn_cal_per_int_types.cal_period_id%TYPE,
    x_interval_number              cn_cal_per_int_types.interval_number%TYPE,
    x_last_update_date             cn_cal_per_int_types.last_update_date%TYPE,
    x_last_updated_by              cn_cal_per_int_types.last_updated_by%TYPE,
    x_creation_date                cn_cal_per_int_types.creation_date%TYPE,
    x_created_by                   cn_cal_per_int_types.created_by%TYPE,
    x_last_update_login            cn_cal_per_int_types.last_update_login%TYPE
    ) IS
       CURSOR c IS
	  SELECT ROWID
	    FROM cn_cal_per_int_types_all
	    WHERE cal_per_int_type_id = x_cal_per_int_type_id;
       l_dummy ROWID;
BEGIN
   IF (x_cal_per_int_type_id IS NULL) THEN
     SELECT cn_cal_per_int_types_s.NEXTVAL
     INTO   x_cal_per_int_type_id
     FROM dual;
   END IF;

   INSERT INTO cn_cal_per_int_types
     (cal_per_int_type_id,
      interval_type_id,
      cal_period_id,
      interval_number,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      org_id
      )
     VALUES
     (x_cal_per_int_type_id,
      x_interval_type_id,
      x_cal_period_id,
      x_interval_number,
      Decode(x_last_update_date,
	     NULL, g_last_update_date,
	     x_last_update_date),
      Decode(x_last_updated_by,
	     NULL, g_last_updated_by,
	     x_last_updated_by),
      Decode(x_creation_date,
	     NULL, g_creation_date,
	     x_creation_date),
      Decode(x_created_by,
	     NULL, g_created_by,
	     x_created_by),
      Decode(x_last_update_login,
	     NULL, g_last_update_login,
	     x_last_update_login),
	  x_org_id
      );

   OPEN c;
   FETCH c INTO l_dummy;
   IF (c%notfound) THEN
      CLOSE c;
      RAISE no_data_found;
   END IF;
   CLOSE c;

END insert_row;

PROCEDURE update_row
  ( x_cal_per_int_type_id     cn_cal_per_int_types.cal_per_int_type_id%TYPE,
    x_interval_number         cn_cal_per_int_types.interval_number%TYPE,
    x_last_update_date        cn_cal_per_int_types.last_update_date%TYPE,
    x_last_updated_by         cn_cal_per_int_types.last_updated_by%TYPE,
    x_last_update_login       cn_cal_per_int_types.last_update_login%TYPE
    )
IS
       CURSOR c IS
	  SELECT cal_period_id, interval_number, interval_type_id, org_id
	    FROM cn_cal_per_int_types_all
	    WHERE cal_per_int_type_id = x_cal_per_int_type_id
	    FOR UPDATE OF cal_per_int_type_id nowait;

       rec c%ROWTYPE;

       CURSOR name(p_org_id number) IS
	  SELECT name
	    FROM cn_interval_types
	    WHERE interval_type_id = rec.interval_type_id
		  AND org_id = p_org_id;

       l_object_name VARCHAR2(80);

       CURSOR dates(p_org_id number) IS
	  SELECT start_date, end_date
	    FROM cn_period_statuses_all
	    WHERE period_id = rec.cal_period_id
		  AND org_id = p_org_id;

       l_start_date DATE;
       l_end_date DATE;
BEGIN
   OPEN c;
   FETCH c INTO rec;

   IF (c%notfound) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c;

   UPDATE cn_cal_per_int_types_all SET
     interval_number       = x_interval_number,
     last_update_date      = x_last_update_date,
     last_updated_by       = x_last_updated_by,
     last_update_login     = x_last_update_login
     WHERE cal_per_int_type_id = x_cal_per_int_type_id;

   IF (SQL%notfound) THEN
      RAISE no_data_found;
   END IF;

   -- mark the "CHANGE_PERIOD_INTERVAL_NUMBER" event for intelligent calculation
   IF (rec.interval_number <> x_interval_number AND fnd_profile.value('CN_MARK_EVENTS') = 'Y' ) THEN
      -- get the object name which is the name of the interval type here.
      OPEN name(rec.org_id);
      FETCH name INTO l_object_name;
      CLOSE name;

      -- get the start_date and end_date of the corresponding period
      OPEN dates(rec.org_id);
      FETCH dates INTO l_start_date, l_end_date;
      CLOSE dates;

      cn_mark_events_pkg.mark_event_interval_number('CHANGE_PERIOD_INTERVAL_NUMBER',
						       l_object_name,
						       rec.interval_type_id,
						       NULL,
						       l_start_date,
						       NULL,
						       l_end_date,
						       rec.interval_type_id,
						       rec.interval_number,
						       x_interval_number,
							   rec.org_id);
   END IF;


END update_row;

PROCEDURE lock_row
  ( x_cal_per_int_type_id     cn_cal_per_int_types.cal_per_int_type_id%TYPE,
    x_cal_period_id           cn_cal_per_int_types.cal_period_id%TYPE,
    x_interval_type_id        cn_cal_per_int_types.interval_type_id%TYPE,
    x_interval_number         cn_cal_per_int_types.interval_number%TYPE
    ) IS
       CURSOR c IS
	  SELECT *
	    FROM cn_cal_per_int_types
	    WHERE cal_per_int_type_id = x_cal_per_int_type_id
	    FOR UPDATE OF cal_per_int_type_id nowait;

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

   IF ((recinfo.cal_per_int_type_id = x_cal_per_int_type_id) AND
       (recinfo.cal_period_id       = x_cal_period_id) AND
       (recinfo.interval_type_id    = x_interval_type_id) AND
       (recinfo.interval_number     = x_interval_number))
     THEN
      RETURN;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   END IF;

END lock_row;

END CN_INT_ASSIGN_PKG;

/* show errors package CN_INT_ASSIGN_PKG

SELECT to_date('SQLEROR') FROM user_errors
WHERE  name = 'CN_INT_ASSIGN_PKG'
  AND    type = 'PACKAGE'
*/

/
