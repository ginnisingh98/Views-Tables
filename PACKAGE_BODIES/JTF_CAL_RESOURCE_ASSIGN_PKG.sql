--------------------------------------------------------
--  DDL for Package Body JTF_CAL_RESOURCE_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_RESOURCE_ASSIGN_PKG" AS
/* $Header: jtfclrab.pls 120.1.12010000.2 2009/05/20 09:10:49 anangupt ship $ */
PROCEDURE INSERT_ROW (
  X_ERROR OUT NOCOPY VARCHAR2,
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CAL_RESOURCE_ASSIGN_ID IN OUT NOCOPY NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_START_DATE_TIME IN DATE,
  X_END_DATE_TIME IN DATE,
  X_CALENDAR_ID IN NUMBER,
  X_RESOURCE_ID IN NUMBER,
  X_RESOURCE_TYPE_CODE IN VARCHAR2,
  X_PRIMARY_CALENDAR_FLAG IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS

v_flag CHAR := 'F';
v_count NUMBER := 0;
v_dup NUMBER := 0;
v_resource_name VARCHAR2(100);
v_calendar_name VARCHAR2(100);
prime_flag_count NUMBER := 0;

-- Added by jawang on 06/05/2002 to fix bug 2180182
l_temp_fnd_end_date date := to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR');

  CURSOR C IS SELECT ROWID FROM JTF_CAL_RESOURCE_ASSIGN
    WHERE CAL_RESOURCE_ASSIGN_ID = X_CAL_RESOURCE_ASSIGN_ID;

  CURSOR C_RES_NAME IS SELECT RESOURCE_NAME
    FROM  JTF_TASK_RESOURCES_VL
   WHERE   RESOURCE_ID = X_RESOURCE_ID
     AND   RESOURCE_TYPE = X_RESOURCE_TYPE_CODE;

  CURSOR C_CAL_NAME IS SELECT CALENDAR_NAME
     FROM JTF_CALENDARS_TL
    WHERE CALENDAR_ID =
       (SELECT CALENDAR_ID
          FROM JTF_CAL_RESOURCE_ASSIGN
          WHERE resource_id = X_RESOURCE_ID
          AND resource_type_code = X_RESOURCE_TYPE_CODE)
      AND LANGUAGE=USERENV('LANG');

	v_error CHAR := 'N';
	v_shift_id NUMBER;
        v_cal_resource_assign_id NUMBER;
BEGIN
   		Fnd_Msg_Pub.initialize;
        IF Jtf_Cal_Resource_Assign_Pkg.NOT_NULL(TO_CHAR(X_RESOURCE_ID)) = FALSE THEN
		Fnd_Message.set_name('JTF', 'JTF_CAL_REQUIRED');
			Fnd_Message.set_token('P_NAME', X_RESOURCE_ID);
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
		END IF;

		IF Jtf_Cal_Resource_Assign_Pkg.NOT_NULL(X_START_DATE_TIME) = FALSE THEN
					Fnd_Message.set_name('JTF', 'JTF_CAL_START_DATE');
			Fnd_Msg_Pub.ADD;

			v_error := 'Y';
		END IF;

		IF Jtf_Cal_Resource_Assign_Pkg.END_GREATER_THAN_BEGIN(X_START_DATE_TIME, X_END_DATE_TIME) = FALSE 										THEN
			--fnd_message.set_name('JTF', 'END_DATE IS INCORRECT');
		        --app_exception.raise_exception;
			Fnd_Message.set_name('JTF', 'JTF_CAL_END_DATE');
			Fnd_Message.set_token('P_Start_Date', X_START_DATE_TIME);
			Fnd_Message.set_token('P_End_Date', X_END_DATE_TIME);
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
		END IF;

   	SELECT COUNT(1) INTO prime_flag_count FROM jtf_cal_resource_assign
        WHERE resource_id = X_RESOURCE_ID
        AND resource_type_code = X_RESOURCE_TYPE_CODE
        AND primary_calendar_flag = 'Y'
        -- Modified by jawang on 06/05/2002 to fix bug 2180182
        AND (( X_START_DATE_TIME <=  start_date_time AND NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
	                                                       >= NVL(end_date_time,l_temp_fnd_end_date) )
	        OR  ( X_START_DATE_TIME BETWEEN  start_date_time AND  NVL(end_date_time,l_temp_fnd_end_date))
	        OR  ( NVL(X_END_DATE_TIME,Fnd_Api.g_miss_date)   BETWEEN  start_date_time AND
	                                                         NVL(end_date_time,l_temp_fnd_end_date))
	        OR  ((X_START_DATE_TIME <  start_date_time) AND (NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
	                                                          > NVL(end_date_time,l_temp_fnd_end_date)))
	        OR  ((X_START_DATE_TIME >  start_date_time) AND (NVL(X_END_DATE_TIME,l_temp_fnd_end_date) <
                                                              NVL(end_date_time,l_temp_fnd_end_date))));


        /*AND (( X_START_DATE_TIME <=  start_date_time AND NVL(X_END_DATE_TIME,Fnd_Api.g_miss_date)
                                                       >= NVL(end_date_time,Fnd_Api.g_miss_date) )
        OR  ( X_START_DATE_TIME BETWEEN  start_date_time AND  NVL(end_date_time,Fnd_Api.g_miss_date))
        OR  ( NVL(X_END_DATE_TIME,Fnd_Api.g_miss_date)   BETWEEN  start_date_time AND
                                                         NVL(end_date_time,Fnd_Api.g_miss_date))
        OR  ((X_START_DATE_TIME <  start_date_time) AND (NVL(X_END_DATE_TIME,Fnd_Api.g_miss_date)
                                                          > NVL(end_date_time,Fnd_Api.g_miss_date)))
        OR  ((X_START_DATE_TIME >  start_date_time) AND (NVL(X_END_DATE_TIME,Fnd_Api.g_miss_date) <
                                                              NVL(end_date_time,Fnd_Api.g_miss_date))));
        */


        /* this has been changed for date nls issue on using dd-mon-yyyy format
        and (( X_START_DATE_TIME <=  start_date_time and nvl(X_END_DATE_TIME,'31-DEC-4712')  >= nvl(end_date_time,'31-DEC-4712') )
        OR  ( X_START_DATE_TIME BETWEEN  start_date_time and  nvl(end_date_time,'31-DEC-4712'))
        OR  ( nvl(X_END_DATE_TIME,'31-DEC-4712')   BETWEEN  start_date_time and  nvl(end_date_time,'31-DEC-4712'))
        OR  ((X_START_DATE_TIME <  start_date_time) AND (nvl(X_END_DATE_TIME,'31-DEC-4712') > nvl(end_date_time,'31-DEC-4712')))
        OR  ((X_START_DATE_TIME >  start_date_time) AND (nvl(X_END_DATE_TIME,'31-DEC-4712') < nvl(end_date_time,'31-DEC-4712'))));
        */

         IF prime_flag_count >= 1 AND X_PRIMARY_CALENDAR_FLAG = 'Y' THEN
            --get resource name
            OPEN C_RES_NAME;
            FETCH C_RES_NAME INTO v_resource_name;
            CLOSE C_RES_NAME;
            --get calendar name
            OPEN C_CAL_NAME;
            FETCH C_CAL_NAME INTO v_calendar_name;
            CLOSE C_CAL_NAME;
            Fnd_Message.set_name('JTF', 'JTF_CAL_DUP_PRIMARY_CAL_FLAG');
            Fnd_Message.set_token('RESOURCE_NAME',v_resource_name);
            Fnd_Message.set_token('CALENDAR_NAME',v_calendar_name);
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
          END IF;

        SELECT COUNT(*) INTO v_count FROM jtf_cal_resource_assign
        WHERE resource_id = X_RESOURCE_ID
        AND resource_type_code = X_RESOURCE_TYPE_CODE
        AND primary_calendar_flag = 'N'
        AND (( X_START_DATE_TIME <=  start_date_time AND NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
                                                                >= NVL(end_date_time,l_temp_fnd_end_date))
        OR  ( X_START_DATE_TIME BETWEEN  start_date_time AND NVL(end_date_time,l_temp_fnd_end_date))
        OR  ( NVL(X_END_DATE_TIME,l_temp_fnd_end_date)   BETWEEN
                                              start_date_time AND NVL(end_date_time,l_temp_fnd_end_date))
        OR  ((X_START_DATE_TIME <  start_date_time) AND (NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
                                                          > NVL(end_date_time,l_temp_fnd_end_date))));


      /*   check_dup_rec
            (v_COUNT,
             X_CALENDAR_ID ,
             X_RESOURCE_TYPE_CODE ,
             X_RESOURCE_ID,
             X_START_DATE_TIME,
             nvl(X_END_DATE_TIME,'31-DEC-4712'),
             v_dup);
    */
 --   IF v_count > 0 OR v_dup > 1 THEN
        IF v_count >= 1 AND X_PRIMARY_CALENDAR_FLAG = 'N' THEN
           	Fnd_Message.set_name('JTF', 'JTF_CAL_DUPLICATE_ROW');
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
          END IF;


		IF v_error = 'Y' THEN
			X_ERROR := 'Y';
			RETURN;
		ELSE
                     SELECT jtf_cal_resource_assign_s.NEXTVAL
                     INTO   v_cal_resource_assign_id
                     FROM  dual;

                     X_CAL_RESOURCE_ASSIGN_ID := v_cal_resource_assign_id;

	  INSERT INTO JTF_CAL_RESOURCE_ASSIGN (
	    OBJECT_VERSION_NUMBER,
	    ATTRIBUTE5,
	    ATTRIBUTE6,
	    ATTRIBUTE7,
	    ATTRIBUTE8,
	    ATTRIBUTE9,
	    ATTRIBUTE10,
	    ATTRIBUTE11,
	    ATTRIBUTE12,
	    ATTRIBUTE13,
	    ATTRIBUTE14,
	    ATTRIBUTE15,
	    ATTRIBUTE_CATEGORY,
	    CAL_RESOURCE_ASSIGN_ID,
	    START_DATE_TIME,
	    END_DATE_TIME,
	    CALENDAR_ID,
	    RESOURCE_ID,
        RESOURCE_TYPE_CODE,
	    PRIMARY_CALENDAR_FLAG,
	    CREATED_BY,
	    CREATION_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATE_LOGIN,
	    ATTRIBUTE1,
	    ATTRIBUTE2,
	    ATTRIBUTE3,
	    ATTRIBUTE4
	  ) VALUES
	  ( 1,
	    X_ATTRIBUTE5,
	    X_ATTRIBUTE6,
	    X_ATTRIBUTE7,
	    X_ATTRIBUTE8,
	    X_ATTRIBUTE9,
	    X_ATTRIBUTE10,
	    X_ATTRIBUTE11,
	    X_ATTRIBUTE12,
	    X_ATTRIBUTE13,
	    X_ATTRIBUTE14,
	    X_ATTRIBUTE15,
	    X_ATTRIBUTE_CATEGORY,
	    v_CAL_RESOURCE_ASSIGN_ID,
	    X_START_DATE_TIME,
	    X_END_DATE_TIME,
	    X_CALENDAR_ID,
	    X_RESOURCE_ID,
         X_RESOURCE_TYPE_CODE,
	    X_PRIMARY_CALENDAR_FLAG,
	    Fnd_Global.USER_ID,
	    SYSDATE,
	    Fnd_Global.USER_ID,
	    SYSDATE,
	    NULL,
	    X_ATTRIBUTE1,
	    X_ATTRIBUTE2,
	    X_ATTRIBUTE3,
	    X_ATTRIBUTE4);

	END IF;
/*
	  open c;
	  fetch c into X_ROWID;
	  if (c%notfound) then
	    close c;
	    raise no_data_found;
	  end if;
	  close c;
*/
END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_CAL_RESOURCE_ASSIGN_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_START_DATE_TIME IN DATE,
  X_END_DATE_TIME IN DATE,
  X_CALENDAR_ID IN NUMBER,
  X_RESOURCE_ID IN NUMBER,
  X_PRIMARY_CALENDAR_FLAG IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2
) IS
  CURSOR c1 IS SELECT
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      START_DATE_TIME,
      END_DATE_TIME,
      CALENDAR_ID,
      RESOURCE_ID,
      PRIMARY_CALENDAR_FLAG,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      CAL_RESOURCE_ASSIGN_ID
    FROM JTF_CAL_RESOURCE_ASSIGN
    WHERE CAL_RESOURCE_ASSIGN_ID = X_CAL_RESOURCE_ASSIGN_ID
    FOR UPDATE OF CAL_RESOURCE_ASSIGN_ID NOWAIT;
BEGIN
  FOR tlinfo IN c1 LOOP
--    if (tlinfo.BASELANG = 'Y') then
      IF (    (tlinfo.CAL_RESOURCE_ASSIGN_ID = X_CAL_RESOURCE_ASSIGN_ID)
          AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER IS NULL) AND (X_OBJECT_VERSION_NUMBER IS NULL)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL)))
          AND (tlinfo.START_DATE_TIME = X_START_DATE_TIME)
          AND ((tlinfo.END_DATE_TIME = X_END_DATE_TIME)
               OR ((tlinfo.END_DATE_TIME IS NULL) AND (X_END_DATE_TIME IS NULL)))
          AND (tlinfo.CALENDAR_ID = X_CALENDAR_ID)
          AND (tlinfo.RESOURCE_ID = X_RESOURCE_ID)
          AND ((tlinfo.PRIMARY_CALENDAR_FLAG = X_PRIMARY_CALENDAR_FLAG)
               OR ((tlinfo.PRIMARY_CALENDAR_FLAG IS NULL) AND (X_PRIMARY_CALENDAR_FLAG IS NULL)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL)))
      ) THEN
        NULL;
      ELSE
        Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
        App_Exception.raise_exception;
      END IF;
--    end if;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ERROR OUT NOCOPY VARCHAR2,
  X_CAL_RESOURCE_ASSIGN_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_START_DATE_TIME IN DATE,
  X_END_DATE_TIME IN DATE,
  X_CALENDAR_ID IN NUMBER,
  X_RESOURCE_ID IN NUMBER,
  X_RESOURCE_TYPE_CODE IN VARCHAR2,
  X_PRIMARY_CALENDAR_FLAG IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER
) IS

    v_error CHAR := 'N';
    v_shift_id NUMBER;
    v_flag CHAR := 'F';
    v_count NUMBER := 1;
    v_dup NUMBER := 1;
    v_resource_name VARCHAR2(100);
    v_calendar_name VARCHAR2(100);
  prime_flag_count NUMBER := 0;

   CURSOR C_RES_NAME IS SELECT RESOURCE_NAME
     FROM  JTF_TASK_RESOURCES_VL
    WHERE   RESOURCE_ID = X_RESOURCE_ID
      AND   RESOURCE_TYPE = X_RESOURCE_TYPE_CODE;

  CURSOR C_CAL_NAME IS SELECT CALENDAR_NAME
     FROM JTF_CALENDARS_TL
    WHERE CALENDAR_ID =
       (SELECT CALENDAR_ID
          FROM JTF_CAL_RESOURCE_ASSIGN
          WHERE resource_id = X_RESOURCE_ID
          AND resource_type_code = X_RESOURCE_TYPE_CODE)
      AND LANGUAGE=USERENV('LANG');

-- Added by abraina to fix bug 4200240
l_temp_fnd_end_date date := to_date(to_char(FND_API.G_MISS_DATE,'dd-MM-RRRR'),'dd-MM-RRRR');
BEGIN
		Fnd_Msg_Pub.initialize;
        IF Jtf_Cal_Resource_Assign_Pkg.NOT_NULL(TO_CHAR(X_RESOURCE_ID)) = FALSE THEN
		Fnd_Message.set_name('JTF', 'JTF_CAL_REQUIRED');
			Fnd_Message.set_token('P_NAME', X_RESOURCE_ID);
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
		END IF;

		IF Jtf_Cal_Resource_Assign_Pkg.NOT_NULL(X_START_DATE_TIME) = FALSE THEN
			--fnd_message.set_name('JTF', 'START_DATE CANNOT BE NULL');
		        --app_exception.raise_exception;
			Fnd_Message.set_name('JTF', 'JTF_CAL_START_DATE');
			Fnd_Msg_Pub.ADD;

			v_error := 'Y';
		END IF;

		IF Jtf_Cal_Resource_Assign_Pkg.END_GREATER_THAN_BEGIN(X_START_DATE_TIME, X_END_DATE_TIME) = FALSE 										THEN
			--fnd_message.set_name('JTF', 'END_DATE IS INCORRECT');
		        --app_exception.raise_exception;
			Fnd_Message.set_name('JTF', 'JTF_CAL_END_DATE');
			Fnd_Message.set_token('P_Start_Date', X_START_DATE_TIME);
			Fnd_Message.set_token('P_End_Date', X_END_DATE_TIME);
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
		END IF;

-- Used l_temp_fnd_end_date instead of FND_API.G_MISS_DATE to fix bug 4200240

	SELECT COUNT(1) INTO prime_flag_count FROM jtf_cal_resource_assign
        WHERE resource_id = X_RESOURCE_ID
        AND resource_type_code = X_RESOURCE_TYPE_CODE
        AND primary_calendar_flag = 'Y'
        AND CAL_RESOURCE_ASSIGN_ID <> X_CAL_RESOURCE_ASSIGN_ID
        AND (( X_START_DATE_TIME <=  start_date_time AND NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
                                                                 >= NVL(end_date_time,l_temp_fnd_end_date))
        OR  ( X_START_DATE_TIME BETWEEN  start_date_time AND NVL(end_date_time,l_temp_fnd_end_date))
        OR  ( NVL(X_END_DATE_TIME,l_temp_fnd_end_date)   BETWEEN  start_date_time AND NVL(end_date_time,l_temp_fnd_end_date))
        OR  ((X_START_DATE_TIME <  start_date_time) AND (NVL(X_END_DATE_TIME,l_temp_fnd_end_date) >
                                                                  NVL(end_date_time,l_temp_fnd_end_date)))
         OR  ((X_START_DATE_TIME >  start_date_time) AND (NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
                                                          < NVL(end_date_time,l_temp_fnd_end_date))));

        IF prime_flag_count = 1 AND X_PRIMARY_CALENDAR_FLAG = 'Y' THEN
             --get resource name
            OPEN C_RES_NAME;
            FETCH C_RES_NAME INTO v_resource_name;
            CLOSE C_RES_NAME;
            --get calendar name
            OPEN C_CAL_NAME;
            FETCH C_CAL_NAME INTO v_calendar_name;
            CLOSE C_CAL_NAME;
            Fnd_Message.set_name('JTF', 'JTF_CAL_DUP_PRIMARY_CAL_FLAG');
            Fnd_Message.set_token('RESOURCE_NAME',v_resource_name);
            Fnd_Message.set_token('CALENDAR_NAME',v_calendar_name);
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
          END IF;

-- Used l_temp_fnd_end_date instead of FND_API.G_MISS_DATE to fix bug 4200240

    SELECT COUNT(*) INTO v_count FROM jtf_cal_resource_assign
        WHERE resource_id = X_RESOURCE_ID
        AND resource_type_code = X_RESOURCE_TYPE_CODE
        AND primary_calendar_flag = 'N'
        AND CAL_RESOURCE_ASSIGN_ID <> X_CAL_RESOURCE_ASSIGN_ID
        AND (( X_START_DATE_TIME <=  start_date_time AND NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
                                                                  >= NVL(end_date_time,l_temp_fnd_end_date))
         OR  ( X_START_DATE_TIME BETWEEN  start_date_time AND NVL(end_date_time,l_temp_fnd_end_date))
        OR  ( NVL(X_END_DATE_TIME,l_temp_fnd_end_date)   BETWEEN
                                       start_date_time AND NVL(end_date_time,l_temp_fnd_end_date))
        OR  ((X_START_DATE_TIME <  start_date_time) AND (NVL(X_END_DATE_TIME,l_temp_fnd_end_date)
                                                                 > NVL(end_date_time,l_temp_fnd_end_date))));

/*        check_dup_rec
            (v_COUNT,
             X_CALENDAR_ID ,
             X_RESOURCE_TYPE_CODE ,
             X_RESOURCE_ID,
             X_START_DATE_TIME,
             X_END_DATE_TIME,
             v_dup);
 */
--          IF v_count > 1 or v_dup = 1 THEN
            IF v_count = 1 AND X_PRIMARY_CALENDAR_FLAG = 'N' THEN
          	Fnd_Message.set_name('JTF', 'JTF_CAL_DUPLICATE_ROW');
			Fnd_Msg_Pub.ADD;
			v_error := 'Y';
          END IF;

		IF v_error = 'Y' THEN
			X_ERROR := 'Y';
			RETURN;
		ELSE
	X_ERROR := 'N';
	X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;

  UPDATE JTF_CAL_RESOURCE_ASSIGN SET
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    START_DATE_TIME = X_START_DATE_TIME,
    END_DATE_TIME = X_END_DATE_TIME,
    CALENDAR_ID = X_CALENDAR_ID,
    RESOURCE_ID = X_RESOURCE_ID,
    PRIMARY_CALENDAR_FLAG = X_PRIMARY_CALENDAR_FLAG,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    CAL_RESOURCE_ASSIGN_ID = X_CAL_RESOURCE_ASSIGN_ID,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = Fnd_Global.USER_ID,
    LAST_UPDATE_LOGIN = Fnd_Global.LOGIN_ID
  WHERE CAL_RESOURCE_ASSIGN_ID = X_CAL_RESOURCE_ASSIGN_ID;

END IF;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  X_CAL_RESOURCE_ASSIGN_ID IN NUMBER
) IS
BEGIN
  DELETE FROM JTF_CAL_RESOURCE_ASSIGN
  WHERE CAL_RESOURCE_ASSIGN_ID = X_CAL_RESOURCE_ASSIGN_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END DELETE_ROW;
/************************************************************************/
-- This procedure is under construction.  The logic to prevent duplicate --
-- will come here.                                                      --
/***********************************************************************/

PROCEDURE check_dup_rec
 (X_COUNT OUT NOCOPY  NUMBER,
  X_CALENDAR_ID NUMBER,
  X_RESOURCE_TYPE_CODE  IN VARCHAR2,
  X_RESOURCE_ID IN NUMBER,
  X_START_DATE_TIME IN DATE,
  X_END_DATE_TIME IN DATE,
  X_DUP OUT NOCOPY NUMBER) IS


  v_start_date_time DATE;
  v_end_date_time DATE;
  v_count NUMBER:= 0;
  v_flag VARCHAR2(1) := 'T';
  --X_COUNT NUMBER := 0;
  temp_count NUMBER := 0;
  v_dup NUMBER := 0;



  CURSOR DUP IS
   SELECT resource_type_code,resource_id,start_date_time,end_date_time
   FROM JTF_CAL_RESOURCE_ASSIGN
   WHERE calendar_id = X_CALENDAR_ID
   AND resource_id = X_RESOURCE_ID
   AND RESOURCE_TYPE_CODE = X_RESOURCE_TYPE_CODE
   ORDER BY start_date_time
   ;
   BEGIN

   --v_start_date_time := TO_DATE(X_START_DATE_TIME,'DD-MON-RRRR HH24:MI');
   --v_end_date_time := TO_DATE(X_END_DATE_TIME,'DD-MON-RRRR HH24:MI');

    -- Jane Wang modified on 03/08/2002 to fix the GSCC Warning
   v_start_date_time := TO_DATE(X_START_DATE_TIME,'DD/MM/YYYY HH24:MI');
   v_end_date_time := TO_DATE(X_END_DATE_TIME,'DD/MM/YYYY HH24:MI');

   SELECT COUNT(*) INTO temp_count
   FROM JTF_CAL_RESOURCE_ASSIGN
  WHERE calendar_id = X_CALENDAR_ID
   AND resource_id = X_RESOURCE_ID
   AND RESOURCE_TYPE_CODE = X_RESOURCE_TYPE_CODE
  AND TRUNC(start_date_time) = TRUNC(v_start_date_time)
  AND TRUNC(end_date_time) = TRUNC(v_end_date_time);

   --fnd_msg_pub.initialize;

   v_count := 0;

   IF temp_count < 1 THEN
        FOR dup_rec IN dup LOOP

      IF dup_rec.end_date_time IS NULL THEN
        IF TRUNC(v_end_date_time) IS NULL THEN

           IF TRUNC(dup_rec.start_date_time) <= TRUNC(v_start_date_time)
            OR TRUNC(dup_rec.start_date_time) > TRUNC(v_start_date_time) THEN

            v_count := v_count+1;

            END IF;
         ELSIF TRUNC(v_end_date_time) > TRUNC(dup_rec.start_date_time) THEN
         v_count := v_count+1;
       END IF;
     END IF;
 IF TRUNC(dup_rec.end_date_time) IS NOT NULL THEN
       IF (TRUNC(dup_rec.start_date_time) = TRUNC(v_start_date_time)  AND TRUNC(dup_rec.end_date_time)
                                                                   = TRUNC(v_end_date_time)) THEN
         v_count :=v_count+1;

      ELSIF (TRUNC(dup_rec.start_date_time) < TRUNC(v_start_date_time) AND  TRUNC(dup_rec.end_date_time)
                                                              > TRUNC(v_end_date_time))THEN
      v_count :=v_count+1;

      ELSIF (TRUNC(dup_rec.start_date_time) > TRUNC(v_start_date_time) AND TRUNC(dup_rec.end_date_time) < TRUNC(v_end_date_time))THEN
      v_count :=v_count+1;

      ELSIF (TRUNC(dup_rec.start_date_time) = TRUNC(v_start_date_time) AND TRUNC(dup_rec.end_date_time) > TRUNC(v_end_date_time))THEN
       v_count :=v_count+1;

     ELSIF (TRUNC(dup_rec.start_date_time) = TRUNC(v_start_date_time) AND TRUNC(dup_rec.end_date_time) < TRUNC(v_end_date_time))THEN
       v_count :=v_count+1;

      ELSIF (TRUNC(dup_rec.start_date_time) > TRUNC(v_start_date_time) AND TRUNC(dup_rec.end_date_time) = TRUNC(v_end_date_time))THEN
      v_count :=v_count+1;

      ELSIF (TRUNC(dup_rec.start_date_time) < TRUNC(v_start_date_time) AND TRUNC(dup_rec.end_date_time) = TRUNC(v_end_date_time))THEN
      v_count :=v_count+1;

      END IF;
  END IF;
      END LOOP;
      END IF;
      x_count := v_count;
      x_dup := temp_count;
      RETURN;
      /*IF x_count > 0 OR temp_count = 1 THEN
          v_flag :='T'; -- Duplicate row
          X_FLAG := 'T';
           return;
        ELSE
        v_flag :='F';
         X_FLAG := 'F';
         return;
         END IF;
         */
      EXCEPTION
      WHEN OTHERS THEN
      NULL;
      RETURN;

   END;




/*************************************************************************/
	FUNCTION not_null(column_to_check IN CHAR) RETURN BOOLEAN IS
	BEGIN
		IF column_to_check IS NULL THEN
		   RETURN(FALSE);
		ELSE
		   RETURN(TRUE);
		END IF;
	END;

/*************************************************************************/
	FUNCTION end_greater_than_begin(start_date IN DATE, end_date IN DATE) RETURN BOOLEAN IS
	BEGIN
		IF start_date > end_date THEN
		   RETURN(FALSE);
		ELSE
		   RETURN(TRUE);
		END IF;
	END;


END Jtf_Cal_Resource_Assign_Pkg;

/
