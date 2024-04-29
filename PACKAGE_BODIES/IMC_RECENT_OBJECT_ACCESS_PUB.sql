--------------------------------------------------------
--  DDL for Package Body IMC_RECENT_OBJECT_ACCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_RECENT_OBJECT_ACCESS_PUB" AS
/* $Header: imcroab.pls 115.8 2002/11/12 21:53:25 tsli noship $ */

/*=======================================================================*/

FUNCTION Record_Exists (
  p_user_id	IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type	IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_object_id	IN IMC_RECENT_ACCESSED_OBJ.object_id%TYPE,
  p_object_name	IN IMC_RECENT_ACCESSED_OBJ.object_name%TYPE
) RETURN VARCHAR2 AS

  l_dummy	NUMBER;

BEGIN

  /* Required Params Validation */
  IF p_user_id IS NULL THEN
    /* user id is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_user_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_object_type IS NULL THEN
    /* object type is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_object_type);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_object_id IS NULL THEN
    /* object id is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_object_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_object_name IS NULL THEN
    /* object name is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_object_name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- dbms_output.put_line('Inside record_exists...');

  l_dummy := 0;

  SELECT  1
  INTO    l_dummy
  FROM    IMC_RECENT_ACCESSED_OBJ
  WHERE   USER_ID = p_user_id
  -- AND     OBJECT_TYPE = p_object_type
  AND     OBJECT_ID = p_object_id
  -- AND     OBJECT_NAME = p_object_name
  AND     ROWNUM = 1;

  -- dbms_output.put_line('l_dummy = ' || l_dummy);

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IMC', g_recent_api_others_ex);
    FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;
    RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Record_Exists;

/*=======================================================================*/

PROCEDURE Update_Record (
  p_old_access_id		IN IMC_RECENT_ACCESSED_OBJ.access_id%TYPE,
  p_new_access_id		IN IMC_RECENT_ACCESSED_OBJ.access_id%TYPE,
  p_user_id			IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type			IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_object_id			IN IMC_RECENT_ACCESSED_OBJ.object_id%TYPE,
  p_object_name			IN IMC_RECENT_ACCESSED_OBJ.object_name%TYPE,
  p_application_id		IN IMC_RECENT_ACCESSED_OBJ.application_id%TYPE,
  p_date_created		IN IMC_RECENT_ACCESSED_OBJ.date_created%TYPE,
  p_additional_value1		IN IMC_RECENT_ACCESSED_OBJ.additional_value1%TYPE,
  p_additional_value2		IN IMC_RECENT_ACCESSED_OBJ.additional_value2%TYPE,
  p_additional_value3		IN IMC_RECENT_ACCESSED_OBJ.additional_value3%TYPE,
  p_additional_value4		IN IMC_RECENT_ACCESSED_OBJ.additional_value4%TYPE,
  p_additional_value5		IN IMC_RECENT_ACCESSED_OBJ.additional_value5%TYPE,
  p_object_version_number	IN IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE,
  p_created_by			IN IMC_RECENT_ACCESSED_OBJ.created_by%TYPE,
  p_creation_date		IN IMC_RECENT_ACCESSED_OBJ.creation_date%TYPE,
  p_last_updated_by		IN IMC_RECENT_ACCESSED_OBJ.last_updated_by%TYPE,
  p_last_update_date		IN IMC_RECENT_ACCESSED_OBJ.last_update_date%TYPE,
  p_last_update_login		IN IMC_RECENT_ACCESSED_OBJ.last_update_login%TYPE
) AS

BEGIN

  UPDATE IMC_RECENT_ACCESSED_OBJ SET
    ACCESS_ID = p_new_access_id,
    OBJECT_TYPE = p_object_type,
    OBJECT_ID = p_object_id,
    OBJECT_NAME = DECODE(p_object_name, FND_API.G_MISS_CHAR, NULL, p_object_name),
    APPLICATION_ID = DECODE(p_application_id, FND_API.G_MISS_NUM, NULL, p_application_id),
    DATE_CREATED = p_date_created,
    ADDITIONAL_VALUE1 = DECODE(p_additional_value1, FND_API.G_MISS_CHAR, NULL, p_additional_value1),
    ADDITIONAL_VALUE2 = DECODE(p_additional_value2, FND_API.G_MISS_CHAR, NULL, p_additional_value2),
    ADDITIONAL_VALUE3 = DECODE(p_additional_value3, FND_API.G_MISS_CHAR, NULL, p_additional_value3),
    ADDITIONAL_VALUE4 = DECODE(p_additional_value4, FND_API.G_MISS_CHAR, NULL, p_additional_value4),
    ADDITIONAL_VALUE5 = DECODE(p_additional_value5, FND_API.G_MISS_CHAR, NULL, p_additional_value5),
    OBJECT_VERSION_NUMBER = p_object_version_number,
    CREATED_BY = p_created_by,
    CREATION_DATE = p_creation_date,
    LAST_UPDATED_BY = p_last_updated_by,
    LAST_UPDATE_DATE = p_last_update_date,
    LAST_UPDATE_LOGIN = p_last_update_login
  WHERE ACCESS_ID = p_old_access_id;

  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

  COMMIT;

END Update_Record;

/*=======================================================================*/

PROCEDURE Insert_Record (
  p_access_id			IN IMC_RECENT_ACCESSED_OBJ.access_id%TYPE,
  p_user_id			IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type			IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_object_id			IN IMC_RECENT_ACCESSED_OBJ.object_id%TYPE,
  p_object_name			IN IMC_RECENT_ACCESSED_OBJ.object_name%TYPE,
  p_application_id		IN IMC_RECENT_ACCESSED_OBJ.application_id%TYPE,
  p_date_created		IN IMC_RECENT_ACCESSED_OBJ.date_created%TYPE,
  p_additional_value1		IN IMC_RECENT_ACCESSED_OBJ.additional_value1%TYPE,
  p_additional_value2		IN IMC_RECENT_ACCESSED_OBJ.additional_value2%TYPE,
  p_additional_value3		IN IMC_RECENT_ACCESSED_OBJ.additional_value3%TYPE,
  p_additional_value4		IN IMC_RECENT_ACCESSED_OBJ.additional_value4%TYPE,
  p_additional_value5		IN IMC_RECENT_ACCESSED_OBJ.additional_value5%TYPE,
  p_object_version_number	IN IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE,
  p_created_by			IN IMC_RECENT_ACCESSED_OBJ.created_by%TYPE,
  p_creation_date		IN IMC_RECENT_ACCESSED_OBJ.creation_date%TYPE,
  p_last_updated_by		IN IMC_RECENT_ACCESSED_OBJ.last_updated_by%TYPE,
  p_last_update_date		IN IMC_RECENT_ACCESSED_OBJ.last_update_date%TYPE,
  p_last_update_login		IN IMC_RECENT_ACCESSED_OBJ.last_update_login%TYPE
) AS

BEGIN

  INSERT INTO IMC_RECENT_ACCESSED_OBJ (
    ACCESS_ID,
    USER_ID,
    OBJECT_TYPE,
    OBJECT_ID,
    OBJECT_NAME,
    APPLICATION_ID,
    DATE_CREATED,
    ADDITIONAL_VALUE1,
    ADDITIONAL_VALUE2,
    ADDITIONAL_VALUE3,
    ADDITIONAL_VALUE4,
    ADDITIONAL_VALUE5,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (
    p_access_id,
    p_user_id,
    p_object_type,
    p_object_id,
    DECODE(p_object_name, FND_API.G_MISS_CHAR, NULL, p_object_name),
    DECODE(p_application_id, FND_API.G_MISS_NUM, NULL, p_application_id),
    p_date_created,
    DECODE(p_additional_value1, FND_API.G_MISS_CHAR, NULL, p_additional_value1),
    DECODE(p_additional_value2, FND_API.G_MISS_CHAR, NULL, p_additional_value2),
    DECODE(p_additional_value3, FND_API.G_MISS_CHAR, NULL, p_additional_value3),
    DECODE(p_additional_value4, FND_API.G_MISS_CHAR, NULL, p_additional_value4),
    DECODE(p_additional_value5, FND_API.G_MISS_CHAR, NULL, p_additional_value5),
    p_object_version_number,
    p_created_by,
    p_creation_date,
    p_last_updated_by,
    p_last_update_date,
    p_last_update_login
  );

  COMMIT;

END Insert_Record;

/*=======================================================================*/

PROCEDURE Add_Recently_Accessed_Object (
  p_user_id			IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type			IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_object_id			IN IMC_RECENT_ACCESSED_OBJ.object_id%TYPE,
  p_object_name			IN IMC_RECENT_ACCESSED_OBJ.object_name%TYPE,
  p_application_id		IN IMC_RECENT_ACCESSED_OBJ.application_id%TYPE,
  p_additional_value1		IN IMC_RECENT_ACCESSED_OBJ.additional_value1%TYPE,
  p_additional_value2		IN IMC_RECENT_ACCESSED_OBJ.additional_value2%TYPE,
  p_additional_value3		IN IMC_RECENT_ACCESSED_OBJ.additional_value3%TYPE,
  p_additional_value4		IN IMC_RECENT_ACCESSED_OBJ.additional_value4%TYPE,
  p_additional_value5		IN IMC_RECENT_ACCESSED_OBJ.additional_value5%TYPE,
  p_object_version_number	IN IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
) AS

  CURSOR records_for_this_user IS
    SELECT *
    FROM IMC_RECENT_ACCESSED_OBJ
    WHERE USER_ID = p_user_id
    ORDER BY access_id;

  l_user_record			records_for_this_user%ROWTYPE;
  l_exists			VARCHAR2(1);
  l_maintain			VARCHAR2(30);
  l_curr_count			NUMBER;
  l_max_records			NUMBER;
  l_old_access_id		IMC_RECENT_ACCESSED_OBJ.access_id%TYPE;
  l_new_access_id		IMC_RECENT_ACCESSED_OBJ.access_id%TYPE;
  l_object_version_number	IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE;
  l_last_update_login		IMC_RECENT_ACCESSED_OBJ.last_update_login%TYPE;

BEGIN

  l_exists := Record_Exists(p_user_id, p_object_type, p_object_id, p_object_name);

  -- dbms_output.put_line('l_exists = ' || l_exists);

  IF (l_exists = 'Y') THEN
    /* Record exists; Update details of access. */
    SELECT  access_id
    INTO    l_old_access_id
    FROM    IMC_RECENT_ACCESSED_OBJ
    WHERE   USER_ID = p_user_id
    -- AND     OBJECT_TYPE = p_object_type
    AND     OBJECT_ID = p_object_id
    AND     ROWNUM = 1;

    /* init access_id */
    SELECT IMC_RECENT_ACCESSED_OBJ_S.NEXTVAL INTO l_new_access_id FROM DUAL;

    /* init object version number */
    l_object_version_number := NVL(p_object_version_number, g_object_version_number);

    /* init last_update_login */
    IF (FND_GLOBAL.conc_login_id = -1) OR (FND_GLOBAL.conc_login_id IS NULL) THEN
      l_last_update_login := FND_GLOBAL.login_id;
    ELSE
      l_last_update_login := FND_GLOBAL.conc_login_id;
    END IF;

    -- dbms_output.put_line('l_old_access_id = ' || l_old_access_id);
    -- dbms_output.put_line('l_new_access_id = ' || l_new_access_id);
    -- dbms_output.put_line('l_object_version_number = ' || l_object_version_number);
    -- dbms_output.put_line('l_last_update_login = ' || l_last_update_login);

    -- dbms_output.put_line('Going to update record...');

    Update_Record (
      l_old_access_id,
      l_new_access_id,
      p_user_id,
      p_object_type,
      p_object_id,
      p_object_name,
      p_application_id,
      SYSDATE,
      p_additional_value1,
      p_additional_value2,
      p_additional_value3,
      p_additional_value4,
      p_additional_value5,
      l_object_version_number,
      nvl(FND_GLOBAL.user_id, -1), /* Created by */
      SYSDATE, /* Creation date */
      nvl(FND_GLOBAL.user_id, -1), /* Last updated by */
      SYSDATE, /* Last update date */
      l_last_update_login /* Last update login */
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSIF (l_exists = 'N') THEN
    /* Record doesn't exist; Create */

    /* init access_id */
    SELECT IMC_RECENT_ACCESSED_OBJ_S.NEXTVAL INTO l_new_access_id FROM DUAL;

    /* init object version number */
    l_object_version_number := NVL(p_object_version_number, g_object_version_number);

    /* init last_update_login */
    IF (FND_GLOBAL.conc_login_id = -1) OR (FND_GLOBAL.conc_login_id IS NULL) THEN
      l_last_update_login := FND_GLOBAL.login_id;
    ELSE
      l_last_update_login := FND_GLOBAL.conc_login_id;
    END IF;

    -- dbms_output.put_line('l_new_access_id = ' || l_new_access_id);
    -- dbms_output.put_line('l_object_version_number = ' || l_object_version_number);
    -- dbms_output.put_line('l_last_update_login = ' || l_last_update_login);

    -- l_max_records := NVL(FND_PROFILE.value(g_store_max_profile), g_default_max_store);
    l_max_records := NVL(FND_PROFILE.value(g_display_max_profile), g_default_max_display);
    -- dbms_output.put_line('l_max_records = ' || l_max_records);

    -- l_maintain := NVL(FND_PROFILE.value(g_maintenance_profile), g_default_maintenance);
    -- Table will now be maintained, by default.
    l_maintain := 'Y';
    -- dbms_output.put_line('l_maintain = ' || l_maintain);

    OPEN records_for_this_user;

    IF l_maintain = 'Y' OR l_maintain = 'Yes' THEN
      SELECT count(*)
      INTO l_curr_count
      FROM IMC_RECENT_ACCESSED_OBJ
      WHERE USER_ID = p_user_id;

      -- dbms_output.put_line('l_curr_count = ' || l_curr_count);

      IF l_curr_count < l_max_records THEN
        -- dbms_output.put_line('Going to insert record...');

        Insert_Record (
          l_new_access_id,
          p_user_id,
          p_object_type,
          p_object_id,
          p_object_name,
          p_application_id,
          SYSDATE,
          p_additional_value1,
          p_additional_value2,
          p_additional_value3,
          p_additional_value4,
          p_additional_value5,
          l_object_version_number,
          nvl(FND_GLOBAL.user_id, -1), /* Created by */
          SYSDATE, /* Creation date */
          nvl(FND_GLOBAL.user_id, -1), /* Last updated by */
          SYSDATE, /* Last update date */
          l_last_update_login /* Last update login */
        );
      ELSE
        FETCH records_for_this_user INTO l_user_record;

        l_old_access_id := l_user_record.access_id;
        -- dbms_output.put_line('l_old_access_id = ' || l_old_access_id);

        -- dbms_output.put_line('Going to insert record...');

        Update_Record (
          l_old_access_id,
          l_new_access_id,
          p_user_id,
          p_object_type,
          p_object_id,
          p_object_name,
          p_application_id,
          SYSDATE,
          p_additional_value1,
          p_additional_value2,
          p_additional_value3,
          p_additional_value4,
          p_additional_value5,
          l_object_version_number,
          nvl(FND_GLOBAL.user_id, -1), /* Created by */
          SYSDATE, /* Creation date */
          nvl(FND_GLOBAL.user_id, -1), /* Last updated by */
          SYSDATE, /* Last update date */
          l_last_update_login /* Last update login */
        );

      END IF;

      CLOSE records_for_this_user;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        -- dbms_output.put_line('Going to insert record...');

        Insert_Record (
          l_new_access_id,
          p_user_id,
          p_object_type,
          p_object_id,
          p_object_name,
          p_application_id,
          SYSDATE,
          p_additional_value1,
          p_additional_value2,
          p_additional_value3,
          p_additional_value4,
          p_additional_value5,
          l_object_version_number,
          nvl(FND_GLOBAL.user_id, -1), /* Created by */
          SYSDATE, /* Creation date */
          nvl(FND_GLOBAL.user_id, -1), /* Last updated by */
          SYSDATE, /* Last update date */
          l_last_update_login /* Last update login */
        );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSIF (l_exists = FND_API.G_RET_STS_ERROR) THEN
    /* Error */
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_exists = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    /* Unexpected error */
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );

END Add_Recently_Accessed_Object;

/*=======================================================================*/

PROCEDURE Get_Recently_Accessed_Objects (
  p_user_id                     IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  p_object_type                 IN IMC_RECENT_ACCESSED_OBJ.object_type%TYPE,
  p_application_id              IN IMC_RECENT_ACCESSED_OBJ.application_id%TYPE,
  p_object_version_number       IN IMC_RECENT_ACCESSED_OBJ.object_version_number%TYPE,
  x_object_info			OUT NOCOPY ref_cursor_rec_obj_acc,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
) AS

  l_query		VARCHAR2(1000);
  l_where_clause	VARCHAR2(500);
  l_order_by_clause	VARCHAR2(100);
  l_max_records         NUMBER;

BEGIN

  /* Required Params Validation */
  IF p_user_id IS NULL THEN
    /* user id is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_user_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    l_query := 'SELECT object_type, object_id, object_name, date_created ' ||
               'FROM IMC_RECENT_ACCESSED_OBJ ';

    l_where_clause := 'WHERE user_id = ' || p_user_id || ' ';

    IF p_object_type IS NOT NULL THEN
      l_where_clause := l_where_clause ||
                        'AND object_type = ''' || p_object_type || ''' ';
    END IF;

    IF p_application_id IS NOT NULL THEN
      l_where_clause := l_where_clause ||
                        'AND application_id = ' || p_application_id || ' ';
    END IF;

    IF p_object_version_number IS NOT NULL THEN
      l_where_clause := l_where_clause ||
                        'AND object_version_number = ' || p_object_version_number || ' ';
    END IF;

    /* Only return the number of records specified in the profile */
    l_max_records := NVL(FND_PROFILE.value(g_display_max_profile), g_default_max_display);

    l_where_clause := l_where_clause ||
                      'AND ROWNUM <= ' || l_max_records || ' ';

    l_order_by_clause := 'ORDER BY access_id DESC';

    l_query := l_query || l_where_clause || l_order_by_clause;

    OPEN x_object_info FOR l_query;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MESSAGE.SET_NAME('IMC', g_no_objs_recently_accessed);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );

END Get_Recently_Accessed_Objects;

/*=======================================================================*/

PROCEDURE Flush (
  p_user_id			IN IMC_RECENT_ACCESSED_OBJ.user_id%TYPE,
  x_flush_count			OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
) AS

  CURSOR records_for_this_user IS
    SELECT *
    FROM IMC_RECENT_ACCESSED_OBJ
    WHERE USER_ID = p_user_id
    ORDER BY access_id;

  l_user_record		records_for_this_user%ROWTYPE;
  l_curr_count		NUMBER;
  l_max_records		NUMBER;
  l_num_to_delete	NUMBER;

BEGIN

  /* Required Params Validation */
  IF p_user_id IS NULL THEN
    /* user id is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_user_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- l_max_records := NVL(FND_PROFILE.value(g_store_max_profile), g_default_max_store);
    l_max_records := NVL(FND_PROFILE.value(g_display_max_profile), g_default_max_display);
    x_flush_count := 0;

    OPEN records_for_this_user;

    SELECT count(*)
    INTO l_curr_count
    FROM IMC_RECENT_ACCESSED_OBJ
    WHERE USER_ID = p_user_id;

    IF l_curr_count <= l_max_records THEN
      /* Nothing to do */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      l_num_to_delete := l_curr_count - l_max_records;

      WHILE x_flush_count < l_num_to_delete LOOP
        FETCH records_for_this_user INTO l_user_record;

        DELETE FROM IMC_RECENT_ACCESSED_OBJ
        WHERE ACCESS_ID = l_user_record.access_id;

        IF SQL%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
        END IF;

        x_flush_count := x_flush_count + 1;
      END LOOP;

      COMMIT;

    END IF;

    CLOSE records_for_this_user;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IMC', g_could_not_delete_entry);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );

END Flush;

END IMC_RECENT_OBJECT_ACCESS_PUB;

/
