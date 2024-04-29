--------------------------------------------------------
--  DDL for Package Body JTF_CAL_SHIFT_CONSTRUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CAL_SHIFT_CONSTRUCTS_PKG" AS
  /* $Header: jtfclscb.pls 120.2.12000000.2 2007/10/12 13:32:48 venjayar ship $ */
  PROCEDURE insert_row(
    x_error                  OUT NOCOPY    VARCHAR2
  , x_rowid                  IN OUT NOCOPY VARCHAR2
  , x_shift_construct_id     IN OUT NOCOPY NUMBER
  , x_shift_id               IN            NUMBER
  , x_unit_of_time_value     IN            VARCHAR2
  , x_begin_time             IN            DATE
  , x_end_time               IN            DATE
  , x_start_date_active      IN            DATE
  , x_end_date_active        IN            DATE
  , x_availability_type_code IN            VARCHAR2
  , x_attribute1             IN            VARCHAR2
  , x_attribute2             IN            VARCHAR2
  , x_attribute3             IN            VARCHAR2
  , x_attribute4             IN            VARCHAR2
  , x_attribute5             IN            VARCHAR2
  , x_attribute6             IN            VARCHAR2
  , x_attribute7             IN            VARCHAR2
  , x_attribute8             IN            VARCHAR2
  , x_attribute9             IN            VARCHAR2
  , x_attribute10            IN            VARCHAR2
  , x_attribute11            IN            VARCHAR2
  , x_attribute12            IN            VARCHAR2
  , x_attribute13            IN            VARCHAR2
  , x_attribute14            IN            VARCHAR2
  , x_attribute15            IN            VARCHAR2
  , x_attribute_category     IN            VARCHAR2
  , x_creation_date          IN            DATE
  , x_created_by             IN            NUMBER
  , x_last_update_date       IN            DATE
  , x_last_updated_by        IN            NUMBER
  , x_last_update_login      IN            NUMBER
  ) IS
     /*  -- Commented By Sarvi B'cos was not used else where and also was raising an exception.
      cursor C is select ROWID from JTF_CAL_SHIFT_CONSTRUCTS
        where SHIFT_CONSTRUCT_ID = X_SHIFT_CONSTRUCT_ID;
    */
    v_error                 CHAR   := 'N';
    x_object_version_number NUMBER;
    v_shift_construct_id    NUMBER;
    p_rec                   NUMBER;
    chk_shift               NUMBER;
    v_begin_time            DATE;
    v_end_time              DATE;
  BEGIN
    fnd_msg_pub.initialize;
    x_object_version_number  := 1;

    IF jtf_cal_shift_constructs_pkg.not_null(x_begin_time) = FALSE THEN
      fnd_message.set_name('JTF', 'JTF_CAL_BEGIN_TIME');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF jtf_cal_shift_constructs_pkg.not_null(x_end_time) = FALSE THEN
      fnd_message.set_name('JTF', 'JTF_CAL_END_TIME');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF jtf_cal_shift_constructs_pkg.end_greater_than_begin(x_begin_time, x_end_time) = FALSE THEN
      fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_END_TIME');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF jtf_cal_shift_constructs_pkg.end_greater_than_begin(x_start_date_active, x_end_date_active) = FALSE THEN
      fnd_message.set_name('JTF', 'JTF_CAL_END_DATE');
      fnd_message.set_token('P_Start_Date', x_start_date_active);
      fnd_message.set_token('P_End_Date', x_end_date_active);
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;


    IF jtf_cal_shift_constructs_pkg.not_null_char(x_availability_type_code) = FALSE THEN
      fnd_message.set_name('JTF', 'JTF_CAL_AVAILABILITY_TYPE_CODE');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    SELECT COUNT(*)
      INTO p_rec
      FROM jtf_cal_shifts_b
     WHERE shift_id = x_shift_id;

    IF p_rec = 0 THEN
      fnd_message.set_name('JTF', 'JTF_CAL_PATTERN_SHIFT');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    --End of Validation
    IF v_error = 'Y' THEN
      x_error  := 'Y';
      RETURN;
    ELSE
      SELECT jtf_cal_shift_constructs_s.NEXTVAL
        INTO v_shift_construct_id
        FROM DUAL;

      -- Code Added by Venkat Putcha for duplicate sequence checking
      SELECT COUNT(*)
        INTO chk_shift
        FROM jtf_cal_shift_constructs
       WHERE shift_construct_id = v_shift_construct_id;

      IF chk_shift > 0 THEN
        fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_SEQ_NUM');
        fnd_message.set_token('P_SHIFT_SEQ_NUM', v_shift_construct_id);
        fnd_msg_pub.ADD;
        v_error  := 'Y';
        x_error  := 'Y';
        RETURN;
      END IF;

      -- End Of Validation
      x_shift_construct_id  := v_shift_construct_id;

            /* Add User Hook Check for INSERT by Jane Wang on 01/25/02 */
      /* Comment the User Hook Check out by Jane Wang on 03/12/02 */
                /*
                IF jtf_usr_hks.ok_to_execute(
                'JTF_CAL_SHIFT_CONSTRUCTS_PKG',
                'INSERT_ROW',
                'B',
                'C')
                THEN
                  JTF_CAL_SHIFT_CUHK.insert_shift_constructs_pre
                  (X_ERROR => X_ERROR,
                    X_ROWID => X_ROWID,
                    X_SHIFT_CONSTRUCT_ID => X_SHIFT_CONSTRUCT_ID ,
                    X_SHIFT_ID => X_SHIFT_ID,
                    X_UNIT_OF_TIME_VALUE => X_UNIT_OF_TIME_VALUE ,
                    X_BEGIN_TIME => X_BEGIN_TIME ,
                    X_END_TIME => X_END_TIME,
                    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE ,
                    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE ,
                    X_AVAILABILITY_TYPE_CODE => X_AVAILABILITY_TYPE_CODE ,
                    X_ATTRIBUTE1 => X_ATTRIBUTE1,
                    X_ATTRIBUTE2 => X_ATTRIBUTE2,
                    X_ATTRIBUTE3 => X_ATTRIBUTE3 ,
                    X_ATTRIBUTE4 => X_ATTRIBUTE4 ,
                    X_ATTRIBUTE5 => X_ATTRIBUTE5,
                    X_ATTRIBUTE6 => X_ATTRIBUTE6 ,
                    X_ATTRIBUTE7 => X_ATTRIBUTE7 ,
                    X_ATTRIBUTE8 => X_ATTRIBUTE8 ,
                    X_ATTRIBUTE9 => X_ATTRIBUTE9 ,
                    X_ATTRIBUTE10 => X_ATTRIBUTE10 ,
                    X_ATTRIBUTE11 => X_ATTRIBUTE11 ,
                    X_ATTRIBUTE12 => X_ATTRIBUTE12 ,
                    X_ATTRIBUTE13 => X_ATTRIBUTE13 ,
                    X_ATTRIBUTE14 => X_ATTRIBUTE14 ,
                    X_ATTRIBUTE15 => X_ATTRIBUTE15 ,
                    X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY ,
                    X_CREATION_DATE => X_CREATION_DATE,
                    X_CREATED_BY => X_CREATED_BY ,
                    X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE ,
                    X_LAST_UPDATED_BY => X_LAST_UPDATED_BY ,
                    X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN
                );

                END IF;  -- End of User Hook Check for INSERT
          */
      BEGIN
        INSERT INTO jtf_cal_shift_constructs
                    (
                     shift_construct_id
                   , shift_id
                   , unit_of_time_value
                   , begin_time
                   , end_time
                   , start_date_active
                   , end_date_active
                   , availability_type_code
                   , created_by
                   , creation_date
                   , last_updated_by
                   , last_update_date
                   , last_update_login
                   , attribute1
                   , attribute2
                   , attribute3
                   , attribute4
                   , attribute5
                   , attribute6
                   , attribute7
                   , attribute8
                   , attribute9
                   , attribute10
                   , attribute11
                   , attribute12
                   , attribute13
                   , attribute14
                   , attribute15
                   , attribute_category
                   , object_version_number
                    )
             VALUES (
                     v_shift_construct_id
                   , x_shift_id
                   , x_unit_of_time_value
                   , x_begin_time
                   , x_end_time
                   , x_start_date_active
                   , x_end_date_active
                   , x_availability_type_code
                   , fnd_global.user_id
                   , SYSDATE
                   , fnd_global.user_id
                   , SYSDATE
                   , fnd_global.login_id
                   , x_attribute1
                   , x_attribute2
                   , x_attribute3
                   , x_attribute4
                   , x_attribute5
                   , x_attribute6
                   , x_attribute7
                   , x_attribute8
                   , x_attribute9
                   , x_attribute10
                   , x_attribute11
                   , x_attribute12
                   , x_attribute13
                   , x_attribute14
                   , x_attribute15
                   , x_attribute_category
                   , x_object_version_number
                    );
      EXCEPTION
        WHEN OTHERS THEN
          --  fnd_message.set_name('JTF', 'JTF_FM_ADMIN_ADDERROR');
          fnd_message.set_name('JTF', SQLERRM);
          fnd_msg_pub.ADD;
          v_error  := 'Y';
          x_error  := 'Y';
      END;
    /*
          open c;
          fetch c into X_ROWID;
          if (c%notfound) then
            close c;
            raise no_data_found;
          end if;
          close c;
    */
    END IF;
  END insert_row;

  PROCEDURE lock_row(
    x_error                  OUT NOCOPY    VARCHAR2
  , x_shift_construct_id     IN            NUMBER
  , x_shift_id               IN            NUMBER
  , x_unit_of_time_value     IN            VARCHAR2
  , x_begin_time             IN            DATE
  , x_end_time               IN            DATE
  , x_start_date_active      IN            DATE
  , x_end_date_active        IN            DATE
  , x_availability_type_code IN            VARCHAR2
  , x_attribute1             IN            VARCHAR2
  , x_attribute2             IN            VARCHAR2
  , x_attribute3             IN            VARCHAR2
  , x_attribute4             IN            VARCHAR2
  , x_attribute5             IN            VARCHAR2
  , x_attribute6             IN            VARCHAR2
  , x_attribute7             IN            VARCHAR2
  , x_attribute8             IN            VARCHAR2
  , x_attribute9             IN            VARCHAR2
  , x_attribute10            IN            VARCHAR2
  , x_attribute11            IN            VARCHAR2
  , x_attribute12            IN            VARCHAR2
  , x_attribute13            IN            VARCHAR2
  , x_attribute14            IN            VARCHAR2
  , x_attribute15            IN            VARCHAR2
  , x_attribute_category     IN            VARCHAR2
  ) IS
    CURSOR c1 IS
      SELECT        shift_id
                  , unit_of_time_value
                  , begin_time
                  , end_time
                  , start_date_active
                  , end_date_active
                  , availability_type_code
                  , attribute1
                  , attribute2
                  , attribute3
                  , attribute4
                  , attribute5
                  , attribute6
                  , attribute7
                  , attribute8
                  , attribute9
                  , attribute10
                  , attribute11
                  , attribute12
                  , attribute13
                  , attribute14
                  , attribute15
                  , attribute_category
                  , shift_construct_id
               FROM jtf_cal_shift_constructs
              WHERE shift_construct_id = x_shift_construct_id
      FOR UPDATE OF shift_construct_id NOWAIT;

    v_error CHAR := 'N';
  BEGIN
    fnd_msg_pub.initialize;

    FOR tlinfo IN c1 LOOP
      IF (
              (tlinfo.shift_construct_id = x_shift_construct_id)
          AND (tlinfo.shift_id = x_shift_id)
          AND (tlinfo.unit_of_time_value = x_unit_of_time_value)
                   /* AND (tlinfo.BEGIN_TIME = X_BEGIN_TIME)
                    AND (tlinfo.END_TIME = X_END_TIME)
          */
          AND (
                  (tlinfo.start_date_active = x_start_date_active)
               OR ((tlinfo.start_date_active IS NULL) AND(x_start_date_active IS NULL))
              )
          AND (
                  (tlinfo.end_date_active = x_end_date_active)
               OR ((tlinfo.end_date_active IS NULL) AND(x_end_date_active IS NULL))
              )
          AND (tlinfo.availability_type_code = x_availability_type_code)
          AND ((tlinfo.attribute1 = x_attribute1) OR((tlinfo.attribute1 IS NULL) AND(x_attribute1 IS NULL)))
          AND ((tlinfo.attribute2 = x_attribute2) OR((tlinfo.attribute2 IS NULL) AND(x_attribute2 IS NULL)))
          AND ((tlinfo.attribute3 = x_attribute3) OR((tlinfo.attribute3 IS NULL) AND(x_attribute3 IS NULL)))
          AND ((tlinfo.attribute4 = x_attribute4) OR((tlinfo.attribute4 IS NULL) AND(x_attribute4 IS NULL)))
          AND ((tlinfo.attribute5 = x_attribute5) OR((tlinfo.attribute5 IS NULL) AND(x_attribute5 IS NULL)))
          AND ((tlinfo.attribute6 = x_attribute6) OR((tlinfo.attribute6 IS NULL) AND(x_attribute6 IS NULL)))
          AND ((tlinfo.attribute7 = x_attribute7) OR((tlinfo.attribute7 IS NULL) AND(x_attribute7 IS NULL)))
          AND ((tlinfo.attribute8 = x_attribute8) OR((tlinfo.attribute8 IS NULL) AND(x_attribute8 IS NULL)))
          AND ((tlinfo.attribute9 = x_attribute9) OR((tlinfo.attribute9 IS NULL) AND(x_attribute9 IS NULL)))
          AND ((tlinfo.attribute10 = x_attribute10) OR((tlinfo.attribute10 IS NULL) AND(x_attribute10 IS NULL)))
          AND ((tlinfo.attribute11 = x_attribute11) OR((tlinfo.attribute11 IS NULL) AND(x_attribute11 IS NULL)))
          AND ((tlinfo.attribute12 = x_attribute12) OR((tlinfo.attribute12 IS NULL) AND(x_attribute12 IS NULL)))
          AND ((tlinfo.attribute13 = x_attribute13) OR((tlinfo.attribute13 IS NULL) AND(x_attribute13 IS NULL)))
          AND ((tlinfo.attribute14 = x_attribute14) OR((tlinfo.attribute14 IS NULL) AND(x_attribute14 IS NULL)))
          AND ((tlinfo.attribute15 = x_attribute15) OR((tlinfo.attribute15 IS NULL) AND(x_attribute15 IS NULL)))
          AND (
                  (tlinfo.attribute_category = x_attribute_category)
               OR ((tlinfo.attribute_category IS NULL) AND(x_attribute_category IS NULL))
              )
         ) THEN
        NULL;
      ELSE
        fnd_message.set_name('JTF', 'FORM_RECORD_CHANGED');
        fnd_msg_pub.ADD;
        v_error  := 'Y';
      --        fnd_message.set_name('JTF',  'FORM_RECORD_CHANGED');
      --        app_exception.raise_exception;
      END IF;

      IF v_error = 'Y' THEN
        x_error  := 'Y';
        RETURN;
      END IF;
    END LOOP;

    RETURN;
  EXCEPTION
    WHEN app_exception.record_lock_exception THEN
      fnd_message.set_name('JTF', 'JTF_API_RECORD_NOT_FOUND');
      fnd_msg_pub.ADD;
      v_error  := 'Y';

      IF v_error = 'Y' THEN
        x_error  := 'Y';
        RETURN;
      END IF;
  END lock_row;

  PROCEDURE update_row(
    x_error                  OUT NOCOPY    VARCHAR2
  , x_shift_construct_id     IN            NUMBER
  , x_shift_id               IN            NUMBER
  , x_unit_of_time_value     IN            VARCHAR2
  , x_begin_time             IN            DATE
  , x_end_time               IN            DATE
  , x_start_date_active      IN            DATE
  , x_end_date_active        IN            DATE
  , x_availability_type_code IN            VARCHAR2
  , x_attribute1             IN            VARCHAR2
  , x_attribute2             IN            VARCHAR2
  , x_attribute3             IN            VARCHAR2
  , x_attribute4             IN            VARCHAR2
  , x_attribute5             IN            VARCHAR2
  , x_attribute6             IN            VARCHAR2
  , x_attribute7             IN            VARCHAR2
  , x_attribute8             IN            VARCHAR2
  , x_attribute9             IN            VARCHAR2
  , x_attribute10            IN            VARCHAR2
  , x_attribute11            IN            VARCHAR2
  , x_attribute12            IN            VARCHAR2
  , x_attribute13            IN            VARCHAR2
  , x_attribute14            IN            VARCHAR2
  , x_attribute15            IN            VARCHAR2
  , x_attribute_category     IN            VARCHAR2
  , x_last_update_date       IN            DATE
  , x_last_updated_by        IN            NUMBER
  , x_last_update_login      IN            NUMBER
  ) IS
    v_error                 CHAR   := 'N';
    l_object_version_number NUMBER;
  BEGIN
    fnd_msg_pub.initialize;

    IF jtf_cal_shift_constructs_pkg.not_null(x_begin_time) = FALSE THEN
      --fnd_message.set_name('JTF', 'BEGIN_TIME CANNOT BE NULL');
            --app_exception.raise_exception;
      fnd_message.set_name('JTF', 'JTF_CAL_BEGIN_TIME');
      --fnd_message.set_token('P_Name', 'BEGIN_TIME');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF jtf_cal_shift_constructs_pkg.not_null(x_end_time) = FALSE THEN
      --fnd_message.set_name('JTF', 'END_TIME CANNOT BE NULL');
            --app_exception.raise_exception;
      fnd_message.set_name('JTF', 'JTF_CAL_END_TIME');
      --fnd_message.set_token('P_Name', 'END_TIME');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF jtf_cal_shift_constructs_pkg.end_greater_than_begin(x_begin_time, x_end_time) = FALSE THEN
      --fnd_message.set_name('JTF', 'START_TIME IS GREATER THAN END_TIME');
            --app_exception.raise_exception;
      fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_END_TIME');
      --fnd_message.set_token('P_Start_Date', X_BEGIN_TIME);
      --fnd_message.set_token('P_End_Date', X_END_TIME);
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF jtf_cal_shift_constructs_pkg.end_greater_than_begin(x_start_date_active, x_end_date_active) = FALSE THEN
      --fnd_message.set_name('JTF', 'START_DATE IS GREATER THAN END DATE');
            --app_exception.raise_exception;
      fnd_message.set_name('JTF', 'JTF_CAL_END_DATE');
      fnd_message.set_token('P_Start_Date', x_start_date_active);
      fnd_message.set_token('P_End_Date', x_end_date_active);
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    /*
        IF JTF_CAL_SHIFT_CONSTRUCTS_PKG.NOT_NULL(X_AVAILABILITY_TYPE_CODE) = FALSE THEN
          --fnd_message.set_name('JTF', 'AVAILABILITY_TYPE_CODE CANNOT BE NULL');
                --app_exception.raise_exception;
          fnd_message.set_name('JTF', 'JTF_CAL_AVAILABILITY_TYPE_CODE');
          --fnd_message.set_token('P_Name', 'AVAILABILITY_TYPE_CODE');
          fnd_msg_pub.add;
          v_error := 'Y';
        END IF;

        --IF JTF_CAL_SHIFT_CONSTRUCTS_PKG.VALIDATE_FND_LOOKUPS(X_AVAILABILITY_TYPE_CODE, 'AVAILABILITY TYPE')
        --  = FALSE THEN
        --  fnd_message.set_name('JTF', 'AVAILABILITY_TYPE_CODE DOES NOT EXIST IN FND_LOOKUPS');
        --        app_exception.raise_exception;
        --  v_error := 'Y';
        --END IF;

        IF JTF_CAL_SHIFT_CONSTRUCTS_PKG.DUPLICATION_SHIFT(X_SHIFT_ID, X_UNIT_OF_TIME_VALUE,
                    X_BEGIN_TIME, X_END_TIME,
                    X_START_DATE_ACTIVE, X_END_DATE_ACTIVE) = FALSE THEN
          --fnd_message.set_name('JTF', 'SHIFT WITH THESE PARAMETERS ALREADY EXISTS');
                --app_exception.raise_exception;
          fnd_message.set_name('JTF', 'JTF_CAL_ALREADY_EXISTS');
          fnd_message.set_token('P_Name', 'SHIFT');
          fnd_msg_pub.add;
          v_error := 'Y';
        END IF;
    */
    IF jtf_cal_shift_constructs_pkg.not_null(x_start_date_active) = FALSE THEN
      --fnd_message.set_name('JTF', 'START_DATE_ACTIVE CANNOT BE NULL');
            --app_exception.raise_exception;
      fnd_message.set_name('JTF', 'JTF_CAL_START_DATE');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

                -- Comment out by Jane Wang on 03/12/2002
                -- To allow a user to define two shift patterns for the same day
                /*
    IF JTF_CAL_SHIFT_CONSTRUCTS_PKG.OVERLAP_SHIFT(X_SHIFT_ID, X_UNIT_OF_TIME_VALUE,
                X_BEGIN_TIME, X_END_TIME,
                X_START_DATE_ACTIVE, X_END_DATE_ACTIVE,
                                                                X_SHIFT_CONSTRUCT_ID) = FALSE THEN
      --fnd_message.set_name('JTF', 'SHIFT WITH THESE PARAMETERS ALREADY EXISTS');
            --app_exception.raise_exception;
      fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_PATTERN_OVERLAPS');
      fnd_msg_pub.add;
      v_error := 'Y';
    END IF;
                */
    IF v_error = 'Y' THEN
      x_error  := 'Y';
      RETURN;
    ELSE
      /* Add User Hook Check for UPDATE by Jane Wang on 01/25/02 */
      /* Comment the User Hook Check by Jane Wang on 03/12/02 */

      /*
                  IF jtf_usr_hks.ok_to_execute(
          'JTF_CAL_SHIFT_CONSTRUCTS_PKG',
        'UPDATE_ROW',
        'B',
        'C')
      THEN
              JTF_CAL_SHIFT_CUHK.update_shift_pre
              (X_ERROR => X_ERROR,
              X_SHIFT_ID => X_SHIFT_ID,
              X_OBJECT_VERSION_NUMBER  => L_OBJECT_VERSION_NUMBER,
              X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
              X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
              X_ATTRIBUTE1 => X_ATTRIBUTE1,
              X_ATTRIBUTE2 => X_ATTRIBUTE2,
              X_ATTRIBUTE3 => X_ATTRIBUTE3,
              X_ATTRIBUTE4 => X_ATTRIBUTE4,
              X_ATTRIBUTE5 => X_ATTRIBUTE5,
              X_ATTRIBUTE6 => X_ATTRIBUTE6,
              X_ATTRIBUTE7 => X_ATTRIBUTE7,
              X_ATTRIBUTE8 => X_ATTRIBUTE8,
              X_ATTRIBUTE9 => X_ATTRIBUTE9,
              X_ATTRIBUTE10 => X_ATTRIBUTE10,
              X_ATTRIBUTE11 => X_ATTRIBUTE11,
              X_ATTRIBUTE12 => X_ATTRIBUTE12,
              X_ATTRIBUTE13 => X_ATTRIBUTE13,
              X_ATTRIBUTE14 => X_ATTRIBUTE14,
              X_ATTRIBUTE15 => X_ATTRIBUTE15,
              X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
              X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
              X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN
              );
        END IF; -- End of User Hook Check for UPDATE
                          */
      BEGIN
        UPDATE jtf_cal_shift_constructs
           SET
               --          SHIFT_ID = X_SHIFT_ID,
               unit_of_time_value = x_unit_of_time_value
             , begin_time = x_begin_time
             , end_time = x_end_time
             , start_date_active = x_start_date_active
             , end_date_active = x_end_date_active
             , availability_type_code = x_availability_type_code
             , attribute1 = x_attribute1
             , attribute2 = x_attribute2
             , attribute3 = x_attribute3
             , attribute4 = x_attribute4
             , attribute5 = x_attribute5
             , attribute6 = x_attribute6
             , attribute7 = x_attribute7
             , attribute8 = x_attribute8
             , attribute9 = x_attribute9
             , attribute10 = x_attribute10
             , attribute11 = x_attribute11
             , attribute12 = x_attribute12
             , attribute13 = x_attribute13
             , attribute14 = x_attribute14
             , attribute15 = x_attribute15
             , attribute_category = x_attribute_category
             , shift_construct_id = x_shift_construct_id
             , last_update_date = SYSDATE
             , last_updated_by = fnd_global.user_id
             , last_update_login = fnd_global.login_id
             , object_version_number = NVL(object_version_number, 0) + 1
         WHERE shift_construct_id = x_shift_construct_id;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('JTF', 'JTF_FM_ADMIN_EDITERROR');
          fnd_msg_pub.ADD;
          v_error  := 'Y';
          x_error  := 'Y';
      END;
    --        if (sql%notfound) then
    --          raise no_data_found;
    --        end if;
    END IF;
  END update_row;

  PROCEDURE delete_row(x_error OUT NOCOPY VARCHAR2, x_shift_construct_id IN NUMBER) IS
    CURSOR c_sh_exist_in_task_assmt(p_shift_cons_id NUMBER) IS
      SELECT 1
        FROM jtf_task_assignments
       WHERE shift_construct_id = p_shift_cons_id AND ROWNUM = 1;

    l_exists NUMBER      := NULL;
    v_error  VARCHAR2(1) := 'N';
  BEGIN
    OPEN c_sh_exist_in_task_assmt(x_shift_construct_id);

    FETCH c_sh_exist_in_task_assmt
     INTO l_exists;

    CLOSE c_sh_exist_in_task_assmt;

    IF NVL(l_exists, 2) = 1 THEN
      fnd_message.set_name('JTF', 'JTF_CAL_SHIFT_DEL_VAL');
      fnd_msg_pub.ADD;
      v_error  := 'Y';
    END IF;

    IF v_error = 'Y' THEN
      x_error  := 'Y';
      RETURN;
    ELSE
      DELETE FROM jtf_cal_shift_constructs
            WHERE shift_construct_id = x_shift_construct_id;
    END IF;
  END delete_row;

  /*************************************************************************/
  FUNCTION not_null(column_to_check IN DATE)
    RETURN BOOLEAN IS
  BEGIN
    IF column_to_check IS NULL THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END;

  /*************************************************************************/
  FUNCTION not_null_char(column_to_check IN CHAR)
    RETURN BOOLEAN IS
  BEGIN
    IF column_to_check IS NULL THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END;

  /*************************************************************************/
  FUNCTION end_greater_than_begin(start_date IN DATE, end_date IN DATE)
    RETURN BOOLEAN IS
  BEGIN
    IF (start_date > end_date) THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END;

  /*************************************************************************/
  FUNCTION duplication_shift(
    x_shift_id           IN NUMBER
  , x_unit_of_time_value IN CHAR
  , x_begin_time         IN DATE
  , x_end_time           IN DATE
  , x_start_date_active  IN DATE
  , x_end_date_active    IN DATE
  )
    RETURN BOOLEAN IS
    CURSOR dup IS
      SELECT shift_id
           , unit_of_time_value
           , begin_time
           , end_time
           , start_date_active
           , end_date_active
        FROM jtf_cal_shift_constructs
       WHERE shift_id = x_shift_id;
  BEGIN
    -- Shift is unique
    FOR dup_rec IN dup LOOP
      IF (
              dup_rec.shift_id = x_shift_id
          AND dup_rec.unit_of_time_value = x_unit_of_time_value
          AND dup_rec.begin_time = x_begin_time
          AND dup_rec.end_time = x_end_time
          AND dup_rec.start_date_active = x_start_date_active
          AND dup_rec.end_date_active = x_end_date_active
         ) THEN
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    END LOOP;
  END duplication_shift;

  /*******************************************************************************************/
  FUNCTION overlap_shift(
    x_shift_id           IN NUMBER
  , x_unit_of_time_value IN CHAR
  , x_start_date_time    IN DATE
  , x_end_date_time      IN DATE
  , x_start_date_active  IN DATE
  , x_end_date_active    IN DATE
  , x_shift_construct_id IN NUMBER
  )
    RETURN BOOLEAN IS
    CURSOR dup IS
      SELECT shift_id
           , unit_of_time_value
           , begin_time
           , end_time
           , shift_construct_id
        FROM jtf_cal_shift_constructs
       WHERE shift_id = x_shift_id;

    l_error      NUMBER              := 1;

    CURSOR c_check_1(l_shift_id NUMBER, l_day DATE) IS
      SELECT shift_construct_id
        FROM jtf_cal_shift_constructs
       WHERE shift_id = l_shift_id AND begin_time <= l_day;

    r_check_1    c_check_1%ROWTYPE;

    CURSOR c_check_2(l_shift_id NUMBER, l_day DATE) IS
      SELECT begin_time
           , end_time
           , shift_construct_id
        FROM jtf_cal_shift_constructs
       WHERE shift_id = l_shift_id AND TRUNC(end_time) > TO_DATE('07/01/1995', 'DD/MM/YYYY');

    r_check_2    c_check_2%ROWTYPE;
    l_start_date DATE;
    l_end_date   DATE;
    l_no         NUMBER;
    l_day        DATE;
  BEGIN
    -- Shift is unique
    IF (x_shift_construct_id IS NULL) THEN
      FOR dup_rec IN dup LOOP
        IF (
                dup_rec.shift_id = x_shift_id
            AND (
                    (
                         x_start_date_time <= dup_rec.begin_time
                     AND NVL(x_end_date_time, fnd_api.g_miss_date) >= NVL(dup_rec.end_time, fnd_api.g_miss_date)
                    )
                 OR (x_start_date_time BETWEEN dup_rec.begin_time AND NVL(dup_rec.end_time, fnd_api.g_miss_date))
                 OR (
                     NVL(x_end_date_time, fnd_api.g_miss_date) BETWEEN dup_rec.begin_time
                                                                   AND NVL(dup_rec.end_time, fnd_api.g_miss_date)
                    )
                 OR (
                         (x_start_date_time > dup_rec.begin_time)
                     AND (NVL(x_end_date_time, fnd_api.g_miss_date) < NVL(dup_rec.end_time, fnd_api.g_miss_date))
                    )
                )
           ) THEN
          l_error  := 0;
          EXIT;
        END IF;
      END LOOP;

      IF (TRUNC(x_end_date_time) > TO_DATE('07/01/1995', 'DD/MM/YYYY')) THEN
        l_no   := TRUNC(x_end_date_time) - TO_DATE('07/01/1995', 'DD/MM/YYYY');
        l_day  := (TO_DATE('01/01/1995', 'DD/MM/YYYY') +(l_no - 1)) +(x_end_date_time - TRUNC(x_end_date_time));

        OPEN c_check_1(x_shift_id, l_day);

        FETCH c_check_1
         INTO r_check_1;

        IF (c_check_1%FOUND) THEN
          l_error  := 0;
        END IF;

        CLOSE c_check_1;
      ELSE
        OPEN c_check_2(x_shift_id, l_day);

        FETCH c_check_2
         INTO r_check_2;

        IF (c_check_2%FOUND) THEN
          l_no   := TRUNC(r_check_2.end_time) - TO_DATE('07/01/1995', 'DD/MM/YYYY');
          l_day  := (TO_DATE('01/01/1995', 'DD/MM/YYYY') +(l_no - 1))
                    +(r_check_2.end_time - TRUNC(r_check_2.end_time));

          IF ((x_start_date_time < l_day) OR(x_end_date_time < l_day)) THEN
            l_error  := 0;
          END IF;
        END IF;

        CLOSE c_check_2;
      END IF;
    ELSE
      FOR dup_rec IN dup LOOP
        IF (
                dup_rec.shift_id = x_shift_id
            AND dup_rec.shift_construct_id <> x_shift_construct_id
            AND (
                    (
                         x_start_date_time <= dup_rec.begin_time
                     AND NVL(x_end_date_time, fnd_api.g_miss_date) >= NVL(dup_rec.end_time, fnd_api.g_miss_date)
                    )
                 OR (x_start_date_time BETWEEN dup_rec.begin_time AND NVL(dup_rec.end_time, fnd_api.g_miss_date))
                 OR (
                     NVL(x_end_date_time, fnd_api.g_miss_date) BETWEEN dup_rec.begin_time
                                                                   AND NVL(dup_rec.end_time, fnd_api.g_miss_date)
                    )
                 OR (
                         (x_start_date_time > dup_rec.begin_time)
                     AND (NVL(x_end_date_time, fnd_api.g_miss_date) < NVL(dup_rec.end_time, fnd_api.g_miss_date))
                    )
                )
           ) THEN
          l_error  := 0;
          EXIT;
        END IF;
      END LOOP;

      IF (TRUNC(x_end_date_time) > TO_DATE('07/01/1995', 'DD/MM/YYYY')) THEN
        l_no   := TRUNC(x_end_date_time) - TO_DATE('07/01/1995', 'DD/MM/YYYY');
        l_day  := (TO_DATE('01/01/1995', 'DD/MM/YYYY') +(l_no - 1)) +(x_end_date_time - TRUNC(x_end_date_time));

        OPEN c_check_1(x_shift_id, l_day);

        FETCH c_check_1
         INTO r_check_1;

        IF ((c_check_1%FOUND) AND(r_check_1.shift_construct_id <> x_shift_construct_id)) THEN
          l_error  := 0;
        END IF;

        CLOSE c_check_1;
      ELSE
        OPEN c_check_2(x_shift_id, l_day);

        FETCH c_check_2
         INTO r_check_2;

        IF (c_check_2%FOUND) THEN
          l_no   := TRUNC(r_check_2.end_time) - TO_DATE('07/01/1995', 'DD/MM/YYYY');
          l_day  := (TO_DATE('01/01/1995', 'DD/MM/YYYY') +(l_no - 1))
                    +(r_check_2.end_time - TRUNC(r_check_2.end_time));

          IF (
                  ((x_start_date_time <= l_day) OR(x_end_date_time <= l_day))
              AND (r_check_2.shift_construct_id <> x_shift_construct_id)
             ) THEN
            l_error  := 0;
          END IF;
        END IF;

        CLOSE c_check_2;
      END IF;
    END IF;

    IF (l_error = 0) THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END overlap_shift;
/*************************************************************************/
/*  FUNCTION overlap_shift(X_SHIFT_ID IN NUMBER, X_UNIT_OF_TIME_VALUE IN CHAR,
          X_BEGIN_TIME IN DATE, X_END_TIME IN DATE,
          X_START_DATE_ACTIVE IN DATE, X_END_DATE_ACTIVE IN DATE) RETURN boolean IS
    cursor dup is
    select shift_id, unit_of_time_value, begin_time, end_time, start_date_active, end_date_active
    from   jtf_cal_shift_constructs
    where  shift_id = X_SHIFT_ID;

  BEGIN
  -- Shift is unique
      for dup_rec in dup loop
            IF         (dup_rec.SHIFT_ID = X_SHIFT_ID
        AND dup_rec.unit_of_time_value = X_UNIT_OF_TIME_VALUE
        AND dup_rec.begin_time BETWEEN X_BEGIN_TIME AND X_END_TIME
        AND dup_rec.start_date_active = X_START_DATE_ACTIVE
        AND dup_rec.end_date_active = X_END_DATE_ACTIVE) THEN

         return(FALSE);
      ELSE
         return(TRUE);
      END IF;
      end loop;
  END overlap_shift;
*/
END jtf_cal_shift_constructs_pkg;

/
