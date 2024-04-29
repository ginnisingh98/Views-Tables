--------------------------------------------------------
--  DDL for Package Body WMS_DOCK_APPOINTMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DOCK_APPOINTMENTS_PUB" AS
/* $Header: WMSDKAPB.pls 120.8 2008/05/02 07:00:15 shikapoo ship $ */

--Global variable to hold the package name
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WMS_DOCK_APPOINTMENTS_PUB';

--Global variable used in print_debug utility
G_VERSION_PRINTED   BOOLEAN      := FALSE;

g_debug NUMBER  :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);

/* Debug Utility*/

PROCEDURE print_debug
  (
   p_err_msg   VARCHAR2
   , p_level   NUMBER
  ) IS
  BEGIN
    IF (g_debug = 1) THEN
      IF(G_VERSION_PRINTED = FALSE ) THEN
        inv_log_util.trace (
          p_message   =>  '$Header: WMSDKAPB.pls 120.8 2008/05/02 07:00:15 shikapoo ship $'
        , p_module    =>  G_PKG_NAME
        , p_level     =>  9);
        G_VERSION_PRINTED :=TRUE;
      END IF;
      inv_log_util.trace (
        p_message   =>  p_err_msg
      , p_module    =>  G_PKG_NAME
      , p_level     =>  p_level);
    END IF;
    --dbms_output.put_line(substr(p_err_msg,1,200));
END print_debug;

FUNCTION get_trip_stop
  (
   x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
   , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , p_dock_locator_id           IN  NUMBER)
  RETURN NUMBER
  IS
     l_trip_stop NUMBER := -1;
BEGIN
   SELECT trip_stop
     INTO l_trip_stop
     FROM wms_dock_appointments_b
     WHERE dock_id = p_dock_locator_id
     AND appointment_status = 2  -- occupied
     AND start_time <= Sysdate
     AND end_time >= Sysdate;

   RETURN l_trip_stop;

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_TRIP_STOP_NOT_FOUND');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count	=>	x_msg_count,
	 p_data		=>	x_msg_data
	 );

      RETURN l_trip_stop;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_trip_stop;

END get_trip_stop;



PROCEDURE update_dock_appointment
  (
    x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_msg_count                   OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_msg_data                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_dock_appointments_v_rec     IN wms_dock_appointments_v%ROWTYPE
   )
  IS
BEGIN
   SAVEPOINT update_dock_sp;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   UPDATE wms_dock_appointments_b
     SET
     APPOINTMENT_TYPE = p_dock_appointments_v_rec.APPOINTMENT_TYPE,
     DOCK_ID = p_dock_appointments_v_rec.DOCK_ID,
     ORGANIZATION_ID = p_dock_appointments_v_rec.ORGANIZATION_ID,
     START_TIME = p_dock_appointments_v_rec.START_TIME,
     END_TIME = p_dock_appointments_v_rec.END_TIME,
     CARRIER_CODE = p_dock_appointments_v_rec.CARRIER_CODE,
     TRIP_STOP = p_dock_appointments_v_rec.TRIP_STOP,
     SOURCE_TYPE = p_dock_appointments_v_rec.SOURCE_TYPE,
     SOURCE_HEADER_ID = p_dock_appointments_v_rec.SOURCE_HEADER_ID,
     SOURCE_LINE_ID = p_dock_appointments_v_rec.SOURCE_LINE_ID,
     CREATED_BY = p_dock_appointments_v_rec.CREATED_BY,
     CREATION_DATE = p_dock_appointments_v_rec.CREATION_DATE,
     LAST_UPDATED_BY = p_dock_appointments_v_rec.LAST_UPDATED_BY,
     LAST_UPDATE_DATE = p_dock_appointments_v_rec.LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN = p_dock_appointments_v_rec.LAST_UPDATE_LOGIN
     WHERE
     DOCK_APPOINTMENT_ID = p_dock_appointments_v_rec.DOCK_APPOINTMENT_ID;


   UPDATE wms_dock_appointments_tl
     SET
     SUBJECT = p_dock_appointments_v_rec.SUBJECT,
     DESCRIPTION = p_dock_appointments_v_rec.DESCRIPTION,
     SOURCE_LANG = USERENV('LANG'),
     CREATED_BY = p_dock_appointments_v_rec.CREATED_BY,
     CREATION_DATE = p_dock_appointments_v_rec.CREATION_DATE,
     LAST_UPDATED_BY = p_dock_appointments_v_rec.LAST_UPDATED_BY,
     LAST_UPDATE_DATE = p_dock_appointments_v_rec.LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN = p_dock_appointments_v_rec.LAST_UPDATE_LOGIN
     WHERE
     DOCK_APPOINTMENT_ID = p_dock_appointments_v_rec.dock_appointment_id
     AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO update_dock_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_UPDATE_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count => x_msg_count,
	 p_data	 => x_msg_data
	 );

END update_dock_appointment;


PROCEDURE update_rep_appointments
  (
    x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    x_msg_count                   OUT NOCOPY /* file.sql.39 change */ NUMBER,
    x_msg_data                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    p_orig_id                     IN NUMBER,
    p_dock_appointments_v_rec     IN wms_dock_appointments_v%ROWTYPE
    )
  IS
BEGIN
   SAVEPOINT update_rep_dock_sp;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   UPDATE wms_dock_appointments_b
     SET
     APPOINTMENT_TYPE = p_dock_appointments_v_rec.APPOINTMENT_TYPE,
     DOCK_ID = p_dock_appointments_v_rec.DOCK_ID,
     ORGANIZATION_ID = p_dock_appointments_v_rec.ORGANIZATION_ID,
     START_TIME = trunc(start_time) + (p_dock_appointments_v_rec.START_TIME - trunc(p_dock_appointments_v_rec.START_TIME)),
     END_TIME = trunc(end_time) + (p_dock_appointments_v_rec.END_TIME - trunc(p_dock_appointments_v_rec.END_TIME)),
     CARRIER_CODE = p_dock_appointments_v_rec.CARRIER_CODE,
     TRIP_STOP = p_dock_appointments_v_rec.TRIP_STOP,
     SOURCE_TYPE = p_dock_appointments_v_rec.SOURCE_TYPE,
     SOURCE_HEADER_ID = p_dock_appointments_v_rec.SOURCE_HEADER_ID,
     SOURCE_LINE_ID = p_dock_appointments_v_rec.SOURCE_LINE_ID,
     CREATED_BY = p_dock_appointments_v_rec.CREATED_BY,
     CREATION_DATE = p_dock_appointments_v_rec.CREATION_DATE,
     LAST_UPDATED_BY = p_dock_appointments_v_rec.LAST_UPDATED_BY,
     LAST_UPDATE_DATE = p_dock_appointments_v_rec.LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN = p_dock_appointments_v_rec.LAST_UPDATE_LOGIN
     WHERE
     REP_ORIGIN = p_orig_id;


   UPDATE wms_dock_appointments_tl
     SET
     SUBJECT = p_dock_appointments_v_rec.SUBJECT,
     DESCRIPTION = p_dock_appointments_v_rec.DESCRIPTION,
     SOURCE_LANG = USERENV('LANG'),
     CREATED_BY = p_dock_appointments_v_rec.CREATED_BY,
     CREATION_DATE = p_dock_appointments_v_rec.CREATION_DATE,
     LAST_UPDATED_BY = p_dock_appointments_v_rec.LAST_UPDATED_BY,
     LAST_UPDATE_DATE = p_dock_appointments_v_rec.LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN = p_dock_appointments_v_rec.LAST_UPDATE_LOGIN
     WHERE
     DOCK_APPOINTMENT_ID IN
     (SELECT dock_appointment_id
      FROM wms_dock_appointments_b
      WHERE REP_ORIGIN = p_orig_id)
     AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO update_rep_dock_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_UPDATE_REP_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count => x_msg_count,
	 p_data	 => x_msg_data
	 );

  END update_rep_appointments;


PROCEDURE insert_dock_appointment
  (
   x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
   , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , p_dock_appointments_v_rec   IN wms_dock_appointments_v%ROWTYPE
   )
  IS
BEGIN
   SAVEPOINT insert_dock_sp;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO wms_dock_appointments_b
     (DOCK_APPOINTMENT_ID,
      APPOINTMENT_TYPE,
      DOCK_ID,
      ORGANIZATION_ID,
      START_TIME,
      END_TIME,
      CARRIER_CODE,
      TRIP_STOP,
      SOURCE_TYPE,
      SOURCE_HEADER_ID,
      SOURCE_LINE_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REP_FREQUENCY,
      REP_START_DATE,
      REP_END_DATE,
      REP_ORIGIN,
      APPOINTMENT_STATUS)
     VALUES
     (p_dock_appointments_v_rec.DOCK_APPOINTMENT_ID,
      p_dock_appointments_v_rec.APPOINTMENT_TYPE,
      p_dock_appointments_v_rec.DOCK_ID,
      p_dock_appointments_v_rec.ORGANIZATION_ID,
      p_dock_appointments_v_rec.START_TIME,
      p_dock_appointments_v_rec.END_TIME,
      p_dock_appointments_v_rec.CARRIER_CODE,
      p_dock_appointments_v_rec.TRIP_STOP,
      p_dock_appointments_v_rec.SOURCE_TYPE,
      p_dock_appointments_v_rec.SOURCE_HEADER_ID,
      p_dock_appointments_v_rec.SOURCE_LINE_ID,
      p_dock_appointments_v_rec.CREATED_BY,
      p_dock_appointments_v_rec.CREATION_DATE,
      p_dock_appointments_v_rec.LAST_UPDATED_BY,
      p_dock_appointments_v_rec.LAST_UPDATE_DATE,
      p_dock_appointments_v_rec.LAST_UPDATE_LOGIN,
      p_dock_appointments_v_rec.REP_FREQUENCY,
      p_dock_appointments_v_rec.REP_START_DATE,
      p_dock_appointments_v_rec.REP_END_DATE,
      p_dock_appointments_v_rec.DOCK_APPOINTMENT_ID,
      p_dock_appointments_v_rec.APPOINTMENT_STATUS);

   INSERT INTO wms_dock_appointments_tl
     (DOCK_APPOINTMENT_ID,
      SUBJECT,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN)
     SELECT
     p_dock_appointments_v_rec.DOCK_APPOINTMENT_ID,
     p_dock_appointments_v_rec.SUBJECT,
     p_dock_appointments_v_rec.DESCRIPTION,
     l.language_code,
     USERENV('LANG'),
     p_dock_appointments_v_rec.CREATED_BY,
     p_dock_appointments_v_rec.CREATION_DATE,
     p_dock_appointments_v_rec.LAST_UPDATED_BY,
     p_dock_appointments_v_rec.LAST_UPDATE_DATE,
     p_dock_appointments_v_rec.LAST_UPDATE_LOGIN
     FROM fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND NOT exists
     (SELECT NULL
      FROM wms_dock_appointments_tl t
      WHERE t.dock_appointment_id = p_dock_appointments_v_rec.dock_appointment_id
      AND t.language = l.language_code);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO insert_dock_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_INSERT_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count => x_msg_count,
	 p_data	 => x_msg_data
	 );
END insert_dock_appointment;


PROCEDURE insert_rep_dock_appointments
  (
   x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
   , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , p_rep_orig_id                   IN NUMBER
   , p_dock_appointments_v_rec   IN wms_dock_appointments_v%ROWTYPE
   )
  IS
BEGIN
   SAVEPOINT insert_rep_dock_sp;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO wms_dock_appointments_b
     (DOCK_APPOINTMENT_ID,
      APPOINTMENT_TYPE,
      DOCK_ID,
      ORGANIZATION_ID,
      START_TIME,
      END_TIME,
      CARRIER_CODE,
      TRIP_STOP,
      SOURCE_TYPE,
      SOURCE_HEADER_ID,
      SOURCE_LINE_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      REP_FREQUENCY,
      REP_START_DATE,
      REP_END_DATE,
      REP_ORIGIN,
      APPOINTMENT_STATUS)
     VALUES
     (p_dock_appointments_v_rec.DOCK_APPOINTMENT_ID,
      p_dock_appointments_v_rec.APPOINTMENT_TYPE,
      p_dock_appointments_v_rec.DOCK_ID,
      p_dock_appointments_v_rec.ORGANIZATION_ID,
      p_dock_appointments_v_rec.START_TIME,
      p_dock_appointments_v_rec.END_TIME,
      p_dock_appointments_v_rec.CARRIER_CODE,
      p_dock_appointments_v_rec.TRIP_STOP,
      p_dock_appointments_v_rec.SOURCE_TYPE,
      p_dock_appointments_v_rec.SOURCE_HEADER_ID,
      p_dock_appointments_v_rec.SOURCE_LINE_ID,
      p_dock_appointments_v_rec.CREATED_BY,
      p_dock_appointments_v_rec.CREATION_DATE,
      p_dock_appointments_v_rec.LAST_UPDATED_BY,
      p_dock_appointments_v_rec.LAST_UPDATE_DATE,
      p_dock_appointments_v_rec.LAST_UPDATE_LOGIN,
      p_dock_appointments_v_rec.REP_FREQUENCY,
      p_dock_appointments_v_rec.REP_START_DATE,
      p_dock_appointments_v_rec.REP_END_DATE,
      p_rep_orig_id,
      p_dock_appointments_v_rec.APPOINTMENT_STATUS);

   INSERT INTO wms_dock_appointments_tl
     (DOCK_APPOINTMENT_ID,
      SUBJECT,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN)
     SELECT
     p_dock_appointments_v_rec.DOCK_APPOINTMENT_ID,
     p_dock_appointments_v_rec.SUBJECT,
     p_dock_appointments_v_rec.DESCRIPTION,
     l.language_code,
     USERENV('LANG'),
     p_dock_appointments_v_rec.CREATED_BY,
     p_dock_appointments_v_rec.CREATION_DATE,
     p_dock_appointments_v_rec.LAST_UPDATED_BY,
     p_dock_appointments_v_rec.LAST_UPDATE_DATE,
     p_dock_appointments_v_rec.last_update_login
     FROM fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND NOT exists
     (SELECT NULL
      FROM wms_dock_appointments_tl t
      WHERE t.dock_appointment_id = p_dock_appointments_v_rec.dock_appointment_id
      AND t.language = l.language_code);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO insert_rep_dock_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_INSERT_REP_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count => x_msg_count,
	 p_data	 => x_msg_data
	 );
END insert_rep_dock_appointments;



PROCEDURE delete_dock_appointment
  (
   x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
   , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , p_dock_appointment_id       IN NUMBER
   )
  IS
BEGIN
   SAVEPOINT delete_dock_sp;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE wms_dock_appointments_b
   WHERE DOCK_APPOINTMENT_ID = p_dock_appointment_id;

   DELETE wms_dock_appointments_tl
   WHERE DOCK_APPOINTMENT_ID = p_dock_appointment_id;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_dock_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_DELETE_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count => x_msg_count,
	 p_data	 => x_msg_data
	 );
END delete_dock_appointment;


PROCEDURE delete_rep_dock_appointment
  (
   x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , x_msg_count                 OUT NOCOPY /* file.sql.39 change */ NUMBER
   , x_msg_data                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   , p_rep_orig_id               IN NUMBER
   )
  IS
BEGIN
   SAVEPOINT delete_rep_dock_sp;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE wms_dock_appointments_tl
     WHERE dock_appointment_id IN
     (SELECT dock_appointment_id
      FROM wms_dock_appointments_b
      WHERE REP_ORIGIN = p_rep_orig_id);

   DELETE wms_dock_appointments_b
     WHERE REP_ORIGIN = p_rep_orig_id;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_rep_dock_sp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_DELETE_REP_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get
	(p_count => x_msg_count,
	 p_data	 => x_msg_data
	 );
END delete_rep_dock_appointment;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
   DELETE FROM WMS_DOCK_APPOINTMENTS_TL T
     WHERE NOT exists
     (SELECT NULL
      FROM WMS_DOCK_APPOINTMENTS_B B
      WHERE B.DOCK_APPOINTMENT_ID = T.DOCK_APPOINTMENT_ID
      );

   UPDATE WMS_DOCK_APPOINTMENTS_TL T
     SET (
	  SUBJECT,
	  DESCRIPTION
	  ) = (SELECT
	       B.SUBJECT,
	       B.DESCRIPTION
	       FROM WMS_DOCK_APPOINTMENTS_TL B
	       WHERE B.DOCK_APPOINTMENT_ID = T.DOCK_APPOINTMENT_ID
	       AND B.LANGUAGE = T.SOURCE_LANG)
     WHERE (
	    T.DOCK_APPOINTMENT_ID,
	    T.LANGUAGE
	    ) IN (SELECT
		  SUBT.DOCK_APPOINTMENT_ID,
		  SUBT.LANGUAGE
		  FROM WMS_DOCK_APPOINTMENTS_TL SUBB, WMS_DOCK_APPOINTMENTS_TL SUBT
		  WHERE SUBB.DOCK_APPOINTMENT_ID = SUBT.DOCK_APPOINTMENT_ID
		  AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
		  AND (SUBB.SUBJECT <> SUBT.SUBJECT
		       OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
		       OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
		       OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
		       )
		  );

   INSERT INTO WMS_DOCK_APPOINTMENTS_TL
     (DOCK_APPOINTMENT_ID,
      SUBJECT,
      DESCRIPTION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
      ) SELECT /*+ ORDERED */
     B.DOCK_APPOINTMENT_ID,
     B.SUBJECT,
     B.DESCRIPTION,
     B.CREATED_BY,
     B.CREATION_DATE,
     B.LAST_UPDATED_BY,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATE_LOGIN,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
     FROM WMS_DOCK_APPOINTMENTS_TL B, FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
     AND B.LANGUAGE = userenv('LANG')
     AND NOT exists
     (SELECT NULL
      FROM WMS_DOCK_APPOINTMENTS_TL T
      WHERE T.DOCK_APPOINTMENT_ID = B.DOCK_APPOINTMENT_ID
      AND T.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;


procedure LOCK_ROW (
  x_dock_appointment_id  in NUMBER,
  x_carrier_code  in VARCHAR2,
  x_staging_lane_id  in NUMBER,
  x_trip_stop  in NUMBER,
  x_rep_start_date  in DATE,
  x_rep_end_date  in DATE,
  x_rep_origin  in NUMBER,
  x_rep_frequency  in NUMBER,
  x_appointment_status  in NUMBER,
  x_appointment_type  in NUMBER,
  x_dock_id  in NUMBER,
  x_organization_id  in NUMBER,
  x_start_time  in DATE,
  x_end_time  in DATE,
  x_source_type  in NUMBER,
  x_source_header_id  in NUMBER,
  x_source_line_id  in NUMBER,
  x_subject  in VARCHAR2,
  x_description  in VARCHAR2
) is
  cursor c is select
      CARRIER_CODE,
      STAGING_LANE_ID,
      TRIP_STOP,
      REP_START_DATE,
      REP_END_DATE,
      REP_ORIGIN,
      REP_FREQUENCY,
      APPOINTMENT_STATUS,
      APPOINTMENT_TYPE,
      DOCK_ID,
      ORGANIZATION_ID,
      START_TIME,
      END_TIME,
      SOURCE_TYPE,
      SOURCE_HEADER_ID,
      SOURCE_LINE_ID
    from WMS_DOCK_APPOINTMENTS_B
    where DOCK_APPOINTMENT_ID = X_DOCK_APPOINTMENT_ID
    for update of DOCK_APPOINTMENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SUBJECT,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_DOCK_APPOINTMENTS_TL
    where DOCK_APPOINTMENT_ID = X_DOCK_APPOINTMENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DOCK_APPOINTMENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CARRIER_CODE = X_CARRIER_CODE)
           OR ((recinfo.CARRIER_CODE is null) AND (X_CARRIER_CODE is null)))
      AND ((recinfo.STAGING_LANE_ID = X_STAGING_LANE_ID)
           OR ((recinfo.STAGING_LANE_ID is null) AND (X_STAGING_LANE_ID is null)))
      AND ((recinfo.TRIP_STOP = X_TRIP_STOP)
           OR ((recinfo.TRIP_STOP is null) AND (X_TRIP_STOP is null)))
      AND ((recinfo.REP_START_DATE = X_REP_START_DATE)
           OR ((recinfo.REP_START_DATE is null) AND (X_REP_START_DATE is null)))
      AND ((recinfo.REP_END_DATE = X_REP_END_DATE)
           OR ((recinfo.REP_END_DATE is null) AND (X_REP_END_DATE is null)))
      AND ((recinfo.REP_ORIGIN = X_REP_ORIGIN)
           OR ((recinfo.REP_ORIGIN is null) AND (X_REP_ORIGIN is null)))
      AND ((recinfo.REP_FREQUENCY = X_REP_FREQUENCY)
           OR ((recinfo.REP_FREQUENCY is null) AND (X_REP_FREQUENCY is null)))
      AND ((recinfo.APPOINTMENT_STATUS = X_APPOINTMENT_STATUS)
           OR ((recinfo.APPOINTMENT_STATUS is null) AND (X_APPOINTMENT_STATUS is null)))
      AND (recinfo.APPOINTMENT_TYPE = X_APPOINTMENT_TYPE)
      AND ((recinfo.DOCK_ID = X_DOCK_ID)
           OR ((recinfo.DOCK_ID is null) AND (X_DOCK_ID is null)))
      AND ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
      AND ((recinfo.START_TIME = X_START_TIME)
           OR ((recinfo.START_TIME is null) AND (X_START_TIME is null)))
      AND ((recinfo.END_TIME = X_END_TIME)
           OR ((recinfo.END_TIME is null) AND (X_END_TIME is null)))
      AND ((recinfo.SOURCE_TYPE = X_SOURCE_TYPE)
           OR ((recinfo.SOURCE_TYPE is null) AND (X_SOURCE_TYPE is null)))
      AND ((recinfo.SOURCE_HEADER_ID = X_SOURCE_HEADER_ID)
           OR ((recinfo.SOURCE_HEADER_ID is null) AND (X_SOURCE_HEADER_ID is null)))
      AND ((recinfo.SOURCE_LINE_ID = X_SOURCE_LINE_ID)
           OR ((recinfo.SOURCE_LINE_ID is null) AND (X_SOURCE_LINE_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SUBJECT = X_SUBJECT)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

  /*----------------------------------------------------------------------------*
  * API Name   : get_dock_appointment_range
  * Description: Given appointment attributes and time window
                 fetches a list of dock appointments

  *---------------------------------------------------------------------------*/

  PROCEDURE  get_dock_appointment_range (
      x_return_status    OUT NOCOPY  VARCHAR2
    , x_msg_count        OUT NOCOPY  NUMBER
    , x_msg_data         OUT NOCOPY  VARCHAR2
    , x_dock_appt_list   OUT NOCOPY  WMS_DOCK_APPOINTMENTS_PUB.dock_appt_tb_tp
    , p_api_version      IN          NUMBER    DEFAULT 1.0
    , p_init_msg_list    IN          VARCHAR2  DEFAULT FND_API.G_FALSE
    , p_organization_id  IN          NUMBER
    , p_start_date       IN          DATE
    , p_end_date         IN          DATE
    , p_appointment_type IN          NUMBER    DEFAULT NULL
    , p_supplier_id      IN          NUMBER    DEFAULT NULL
    , p_supplier_site_id IN          NUMBER    DEFAULT NULL
    , p_customer_id      IN          NUMBER    DEFAULT NULL
    , p_customer_site_id IN          NUMBER    DEFAULT NULL
    , p_carrier_code     IN          VARCHAR2  DEFAULT NULL
    , p_carrier_id       IN          VARCHAR2  DEFAULT NULL
    , p_trip_stop_id     IN          NUMBER    DEFAULT NULL
    , p_waybill_number   IN          VARCHAR2  DEFAULT NULL
    , p_bill_of_lading   IN          VARCHAR2  DEFAULT NULL
    , p_master_bol       IN          VARCHAR2  DEFAULT NULL) IS


    --Local variables
  l_progress       NUMBER;                        --Used to check progress of the procedure
  l_no_trip_rec    BOOLEAN                        := FALSE;
  l_carrier_code   WSH_CARRIERS.FREIGHT_CODE%TYPE;

  BEGIN

    l_progress :=10;

    --Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list to clear any existing messages if p_init_msg_list is set to TRUE
    IF fnd_api.To_Boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    l_progress := 20;

    IF(g_debug = 1 ) THEN
      print_debug('Entered procedure GET_DOCK_APPOINTMENT_RANGE at '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'),4);
      print_debug('Organization ID'        ||p_organization_id,4);
      print_debug('Appointment start date' ||p_start_date,4);
      print_debug('Appointment end date'   ||p_end_date,4);
      print_debug('Appointmnet Type'       ||p_appointment_type,4);
      print_debug('Supplier ID'            ||p_supplier_id,4);
      print_debug('Supplier Site ID'       ||p_supplier_site_id,4);
      print_debug('Customer ID'            ||p_customer_id,4);
      print_debug('Customer Site ID'       ||p_customer_site_id,4);
      print_debug('Carrier Code'           ||p_carrier_code,4);
      print_debug('Carrier Id'             ||p_carrier_id,4);
      print_debug('Trip Stop ID'           ||p_trip_stop_id,4);
      print_debug('Waybill Number'         ||p_waybill_number,4);
      print_debug('Bill of Lading'         ||p_bill_of_lading,4);
      print_debug('Master Bill of Lading'  ||p_master_bol,4);
    END IF;

    --check if atleast one attribute other than time window has a NOT NULL value
    IF(     p_supplier_id          IS NULL
        AND p_supplier_site_id     IS NULL
        AND p_customer_id          IS NULL
        AND p_customer_site_id     IS NULL
        AND p_trip_stop_id         IS NULL
        AND(
             (     p_carrier_code  IS NULL
               AND p_carrier_id    IS NULL
             )
             OR    p_end_date      IS NULL
           )
        AND p_waybill_number       IS NULL
        AND p_bill_of_lading       IS NULL
        AND p_master_bol           IS NULL
      ) THEN

      IF (g_debug = 1) THEN
        print_debug('Failure in get_wms_dock_appointment_range at level'
                     ||l_progress||'.All the attributes passed are NULL', 4);
      END IF;
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.add;
      RAISE   FND_API.G_EXC_ERROR;

    --Check if organization id is null
    ELSIF( p_organization_id IS NULL ) THEN
      IF (g_debug = 1) THEN
        print_debug('Failure in get_wms_dock_appointment_range at level'
                     ||l_progress||'.Organization ID is null', 4);
      END IF;
      fnd_message.set_name('INV', 'INV_ITM_MISS_ORG_ID');
      fnd_msg_pub.add;
      RAISE   FND_API.G_EXC_ERROR;

    --Check if p_start_date is null
    ELSIF( p_start_date IS NULL ) THEN
      IF (g_debug = 1) THEN
        print_debug('Failure in get_wms_dock_appointment_range at level'
                     ||l_progress||'.p_start_date is null', 4);
      END IF;
      fnd_message.set_name('INV', 'INV_EAM_GEN_NULL_START_DATE');
      fnd_msg_pub.add;
      RAISE   FND_API.G_EXC_ERROR;

    -- Check if start date is less than end date
    ELSIF( p_end_date is not null AND p_start_date > p_end_date ) THEN
      IF (g_debug = 1) THEN
        print_debug('Failure in get_wms_dock_appointment_range at level'
                     ||l_progress||'.p_start_date is greater than p_end_date', 4);
        print_debug('Exiting procedure without fetching appointments', 4);
      END IF;
      --Bug #5309213
      --Instead of raising an error, set the appointment list to NULL
      --and return control to the calling module.
      RETURN;
    END IF;

    l_progress := 30;

    --If carrier id is passed instead of carrier code,
    --fetching the carrier code from wsh_carriers table
    BEGIN
    IF( p_carrier_code IS NULL AND p_carrier_id IS NOT NULL ) THEN
      SELECT FREIGHT_CODE INTO l_carrier_code
      FROM   WSH_CARRIERS
      WHERE  CARRIER_ID  =  p_carrier_id;
    ELSIF (p_carrier_code IS NOT NULL) THEN
      --If carrier code is passed then using the same carrier code
      l_carrier_code     := p_carrier_code;
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN TOO_MANY_ROWS THEN
        NULL;
      WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_progress  := 40;

    --If trip stop Id is not null  then get the first appointment for that trip stop
    IF( p_trip_stop_id IS NOT NULL ) THEN
      IF (g_debug = 1) THEN
        print_debug('Fetching dock appointments for Trip Stop ID:'||p_trip_stop_id, 4);
      END IF;

      BEGIN
        SELECT     dock_appointment_id
                 , start_time
                 , end_time
        INTO      x_dock_appt_list(1)
        FROM      wms_dock_appointments_b
        WHERE
        start_time=(SELECT  min(start_time)
                    FROM    wms_dock_appointments_b
                    WHERE   organization_id     =  p_organization_id
                    AND     appointment_type    =  NVL(p_appointment_type, appointment_type)
                    AND start_time             >=  p_start_date
                    AND trip_stop               =  p_trip_stop_id
                   )
        AND organization_id         =  p_organization_id
        AND appointment_type        =  NVL(p_appointment_type, appointment_type)
        AND trip_stop               =  p_trip_stop_id
        AND ROWNUM                  =  1;

        l_progress  := 50;
        IF (g_debug = 1) THEN
          print_debug('Fetched record for Trip Stop ID with appointment id:'||x_dock_appt_list(1).dock_appointment_id, 4);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --Setting the trip flag to TRUE to further process by carrier id
          l_no_trip_rec := TRUE ;
        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    END IF;--p_trip_stop_id not null

    /* If trip stop Id is null or if no records are fetched for given trip stop id
     * and carrier code or carrier id is not null then get all the appointments for the l_carrier_code
     * within the given time window
     */
    IF((p_trip_stop_id IS NULL OR l_no_trip_rec = TRUE )AND l_carrier_code IS NOT NULL ) THEN
      IF (g_debug = 1) THEN
        print_debug('Fetching dock appointments for carrier code:'||l_carrier_code, 4);
      END IF;
      l_progress := 60;

      SELECT      dock_appointment_id
                , start_time
                , end_time
                BULK COLLECT
      INTO      x_dock_appt_list
      FROM      wms_dock_appointments_b
      WHERE     organization_id         =  p_organization_id
                AND appointment_type    =  NVL(p_appointment_type, appointment_type)
                AND carrier_code        =  l_carrier_code
                AND start_time         >=  p_start_date
                AND end_time           <=  p_end_date
      ORDER BY  start_time;
      l_progress := 70;
    END IF;  --p_trip_stop_id is null and l_carrier_code is not null

    IF (g_debug = 1) THEN
      print_debug('Procedure get_dock_appointment_range completed successfully at '||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (g_debug = 1) THEN
        print_debug('Execution error occured in get_dock_appointment_range at level:'||l_progress, 4);
      END IF;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('WMS','WMS_UNEXPECTED_ERROR');
      fnd_msg_pub.add;
      IF (g_debug = 1) THEN
        print_debug('Unexpected error occured in get_dock_appointment_range at level:'||l_progress, 4);
      END IF;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('WMS','WMS_UNEXPECTED_ERROR');
      fnd_msg_pub.add;
      IF (g_debug = 1) THEN
        print_debug('Unexpected error occured in get_dock_appointment_range at level:'||l_progress, 4);
      END IF;
      fnd_msg_pub.count_and_get (
          p_encoded =>  FND_API.G_FALSE
        , p_count   =>  x_msg_count
        , p_data    =>  x_msg_data );
  END get_dock_appointment_range;

  PROCEDURE OTM_Dock_Appointment
  (
	p_dock_appt_tab	IN DockApptTabType,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2
   ) IS

   l_dock_appointments_v_rec wms_dock_appointments_v%ROWTYPE;
   l_dock_appointment_id NUMBER;
   l_locator_id NUMBER;
   l_disable_date DATE;
   l_msg VARCHAR2(100);
   l_return_status VARCHAR2(1);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(4000);

   CURSOR Get_Appt_Info(v_trip_stop_id number, v_organization_id NUMBER) IS
	SELECT dock_appointment_id
	FROM wms_dock_appointments_b
	WHERE trip_stop = v_trip_stop_id
	AND organization_id = v_organization_id;

   CURSOR Check_Valid_Locator(v_locator_id NUMBER, v_organization_id NUMBER) IS
	SELECT inventory_location_id, disable_date
	FROM mtl_item_locations
	WHERE inventory_location_id = v_locator_id
	AND organization_id = v_organization_id
	AND inventory_location_type = 1
        AND NVL(disable_date, SYSDATE + 1) > SYSDATE;

   BEGIN
	IF WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 THEN
		-- Initialize the return status to success
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF g_debug = 1 THEN
	           print_debug('In OTM_Dock_Appointment API ', 4);
		   print_debug('p_dock_appt_tab.COUNT : '|| p_dock_appt_tab.COUNT, 4);
		END IF;
		SAVEPOINT otm_dock_sp;

		-- Loop through the dock appointments
		FOR i in p_dock_appt_tab.FIRST..p_dock_appt_tab.LAST LOOP
                    -- Check for Required Parameters
		    IF p_dock_appt_tab(i).Organization_id IS NULL THEN
		       IF g_debug = 1 THEN
			  print_debug('Organization id is required',4);
                       END IF;
                       FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_APPT_PARAM_REQD');
                       FND_MESSAGE.SET_TOKEN('PARAM', 'Organization');
                       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
		    ELSIF p_dock_appt_tab(i).Trip_Stop_id IS NULL THEN
		       IF g_debug = 1 THEN
			  print_debug('Trip Stop id is required',4);
                       END IF;
                       FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_APPT_PARAM_REQD');
                       FND_MESSAGE.SET_TOKEN('PARAM', 'Trip Stop');
                       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
		    END IF;

                    -- Check for Valid dock name
		    IF p_dock_appt_tab(i).Dock_Name IS NOT NULL
                    AND (SUBSTR(p_dock_appt_tab(i).Dock_Name, 1, 5) <> 'DOCK-'
                         OR LENGTH(p_dock_appt_tab(i).Dock_Name) <=5) THEN
                       IF g_debug = 1 THEN
                          print_debug('Dock Door Name is Invalid : '||p_dock_appt_tab(i).Dock_Name ,4);
                       END IF;
                       FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_DOCK_DOOR');
                       FND_MESSAGE.SET_TOKEN('DOCK_DOOR', p_dock_appt_tab(i).Dock_Name);
                       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
                    END IF;

		    -- Extract Locator_id from Dock Name and validate the locator
		    -- for the Organization
		    l_locator_id := SUBSTR(p_dock_appt_tab(i).Dock_Name, 6, 40);
		    IF g_debug = 1 THEN
		       print_debug('l_locator_id : '||l_locator_id, 4);
		       print_debug('Trip Stop : '||p_dock_appt_tab(i).Trip_Stop_id||' , Organization_id : '||p_dock_appt_tab(i).Organization_id, 4);
	            END IF;

		    -- Locator can be NULL for deleting appointments for a trip
		    IF l_locator_id IS NOT NULL THEN
		       OPEN Check_Valid_Locator(l_locator_id, p_dock_appt_tab(i).Organization_id);
		       FETCH Check_Valid_Locator INTO l_dock_appointments_v_rec.dock_id, l_disable_date;
		       IF Check_Valid_Locator%NOTFOUND THEN
		          CLOSE Check_Valid_Locator;
			  IF g_debug = 1 THEN
			     print_debug('Dock Door is Invalid for this Organization ', 4);
			  END IF;
                          FND_MESSAGE.SET_NAME('WMS', 'WMS_INVALID_DOCK_DOOR_ORG');
                          FND_MESSAGE.SET_TOKEN('DOCK_DOOR', p_dock_appt_tab(i).Dock_Name);
                          FND_MSG_PUB.ADD;
			  RAISE FND_API.G_EXC_ERROR;
		       END IF;
		       CLOSE Check_Valid_Locator;

                       -- End Date/Time should be greater than Start Date/Time
                       IF p_dock_appt_tab(i).Start_Time > p_dock_appt_tab(i).End_Time
                       OR p_dock_appt_tab(i).Start_Time  < SYSDATE OR p_dock_appt_tab(i).End_Time  < SYSDATE
                       OR trunc(NVL(l_disable_date, p_dock_appt_tab(i).End_Time + 1)) <= trunc(p_dock_appt_tab(i).End_Time) THEN
		          FND_MESSAGE.SET_NAME('WMS','WMS_INVALID_DATE');
			  IF g_debug = 1 THEN
			     print_debug('Invalid Dates entered', 4);
			  END IF;
                          FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_APPT_DATE_INVALID');
                          FND_MSG_PUB.ADD;
			  RAISE FND_API.G_EXC_ERROR;
		       END IF;

		       -- Check if appointment exists for the Locator
		       OPEN Get_Appt_Info(p_dock_appt_tab(i).Trip_Stop_id, p_dock_appt_tab(i).Organization_id);
		       FETCH Get_Appt_Info INTO l_dock_appointment_id;
		       -- Populate appointment record
		       l_dock_appointments_v_rec.dock_appointment_id := l_dock_appointment_id;
		       l_dock_appointments_v_rec.trip_stop := p_dock_appt_tab(i).Trip_Stop_id;
		       l_dock_appointments_v_rec.organization_id := p_dock_appt_tab(i).Organization_id;
		       l_dock_appointments_v_rec.appointment_type := 2; -- Outbound
		       l_dock_appointments_v_rec.start_time := p_dock_appt_tab(i).Start_Time;
		       l_dock_appointments_v_rec.end_time := p_dock_appt_tab(i).End_Time;
		       l_dock_appointments_v_rec.rep_origin := l_dock_appointments_v_rec.dock_appointment_id; -- same for Non-Repeating appts
		       l_dock_appointments_v_rec.rep_frequency := 1; -- Never Repeat
		       l_dock_appointments_v_rec.creation_date := SYSDATE;
		       l_dock_appointments_v_rec.created_by := FND_GLOBAL.User_Id;
		       l_dock_appointments_v_rec.last_updated_by := FND_GLOBAL.User_Id;
		       l_dock_appointments_v_rec.last_update_date := SYSDATE;
		       l_dock_appointments_v_rec.last_update_login := FND_GLOBAL.Login_Id;

		       -- Message text "Dock Appt for OTM Trip Stop <Trip Stop>"
		       FND_MESSAGE.SET_NAME('WMS','WMS_DOCK_APPT_TRIP');
		       FND_MESSAGE.SET_TOKEN('TRIP_STOP',p_dock_appt_tab(i).trip_stop_id);
		       l_msg := FND_MESSAGE.GET;
		       l_dock_appointments_v_rec.subject := 'OTM Planned Dock Appointment';
		       l_dock_appointments_v_rec.description := l_msg;

		       IF Get_Appt_Info%NOTFOUND THEN
			  SELECT wms_dock_appointments_s.nextval
			  INTO l_dock_appointments_v_rec.DOCK_APPOINTMENT_ID
		          FROM dual;
			  l_dock_appointments_v_rec.rep_origin := l_dock_appointments_v_rec.dock_appointment_id; -- same for Non-Repeating appts
			  IF g_debug = 1 THEN
			     print_debug('Calling Insert_dock_appointment API', 4);
			  END IF;
			  Insert_dock_appointment
					( x_return_status          => l_return_status,
					 x_msg_count              => l_msg_count,
					 x_msg_data               => l_msg_data,
					 p_dock_appointments_v_rec => l_dock_appointments_v_rec);
		          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     IF g_debug = 1 THEN
				print_debug('Unable to create Dock Door appt, return status : '||l_return_status, 4);
			     END IF;
		             FND_MESSAGE.SET_NAME('WMS','WMS_DOCK_APPT_TRIP');
                             FND_MSG_PUB.ADD;
			     RAISE FND_API.G_EXC_ERROR;
			  END IF;
		       ELSE
		          IF g_debug = 1 THEN
			     print_debug('Calling Update_dock_appointment API', 4);
			  END IF;
			  Update_dock_appointment
					(p_dock_appointments_v_rec => l_dock_appointments_v_rec,
					 x_return_status           => l_return_status,
					 x_msg_count               => l_msg_count,
					 x_msg_data                => l_msg_data);
			  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     IF g_debug = 1 THEN
			        print_debug('Unable to update Dock Door appt, return status : '||l_return_status, 4);
		             END IF;
		             FND_MESSAGE.SET_NAME('WMS','WMS_DOCK_APPT_TRIP');
                             FND_MSG_PUB.ADD;
			     RAISE FND_API.G_EXC_ERROR;
			  END IF;
		       END IF;
		       CLOSE Get_Appt_Info;
		    ELSE
		       -- Delete appointment for any locator for the Trip Stop and Organization
		       OPEN Get_Appt_Info(p_dock_appt_tab(i).trip_stop_id, p_dock_appt_tab(i).organization_id);
		       FETCH Get_Appt_Info INTO l_dock_appointment_id;
		       CLOSE Get_Appt_Info;
		       IF l_dock_appointment_id IS NOT NULL THEN
		          IF g_debug = 1 THEN
		             print_debug('Calling Delete_dock_appointment API', 4);
		          END IF;
		          DELETE_dock_appointment
					(x_return_status       => l_return_status,
					 x_msg_count           => l_msg_count,
					 x_msg_data            => l_msg_data,
					 p_dock_appointment_id => l_dock_appointment_id);
		          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			     IF g_debug = 1 THEN
			        print_debug('Unable to delete Dock Door appt, return status : '||l_return_status, 4);
			     END IF;
		             FND_MESSAGE.SET_NAME('WMS','WMS_DOCK_APPT_TRIP');
                             FND_MSG_PUB.ADD;
                             RAISE FND_API.G_EXC_ERROR;
			  END IF;
		       END IF;
		    END IF;
		END LOOP;

		IF g_debug = 1 THEN
	           print_debug('Exiting OTM_Dock_Door_Appointment API', 4);
		END IF;
	END IF;

	EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
	       ROLLBACK TO OTM_DOCK_SP;
               IF Get_Appt_Info%ISOPEN THEN
                  CLOSE Get_Appt_Info;
               END IF;
               IF Check_Valid_Locator%ISOPEN THEN
                  CLOSE Check_Valid_Locator;
               END IF;
	       IF g_debug = 1 THEN
	          print_debug('Expected error occurred, Exiting OTM_Dock_Door_Appointment API', 4);
	       END IF;
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       FND_MSG_PUB.Count_And_Get
	       (p_count => x_msg_count,
	        p_data  => x_msg_data);
	  WHEN OTHERS THEN
	       ROLLBACK TO OTM_DOCK_SP;
               IF Get_Appt_Info%ISOPEN THEN
                  CLOSE Get_Appt_Info;
               END IF;
               IF Check_Valid_Locator%ISOPEN THEN
                  CLOSE Check_Valid_Locator;
               END IF;
	       IF g_debug = 1 THEN
	          print_debug('Unexpected error occurred, Exiting OTM_Dock_Door_Appointment API', 4);
	          print_debug(SQLERRM, 4);
	       END IF;
	       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	       FND_MSG_PUB.Count_And_Get
	       (p_count => x_msg_count,
	        p_data  => x_msg_data);
END OTM_Dock_Appointment;

END WMS_DOCK_APPOINTMENTS_PUB;

/
