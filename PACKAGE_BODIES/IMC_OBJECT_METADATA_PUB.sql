--------------------------------------------------------
--  DDL for Package Body IMC_OBJECT_METADATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IMC_OBJECT_METADATA_PUB" AS
/* $Header: imcomdb.pls 115.4 2002/11/12 21:53:08 tsli noship $ */

/*=======================================================================*/

FUNCTION Object_Metadata_Exists (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN VARCHAR2 AS

  l_dummy	NUMBER;

BEGIN

  /* Required Param Validation */
  IF p_object_type IS NULL THEN
    /* object type is invalid */
    FND_MESSAGE.SET_NAME('IMC', g_invalid_object_type);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT 1
  INTO l_dummy
  FROM IMC_OBJECT_METADATA
  WHERE OBJECT_TYPE = p_object_type
  AND ROWNUM = 1;

  RETURN 'Y';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';

  WHEN FND_API.G_EXC_ERROR THEN
     RETURN FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IMC', g_metadata_api_others_ex);
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;

END Object_Metadata_Exists;

/*=======================================================================*/

PROCEDURE Update_Record (
  p_object_type		IN IMC_OBJECT_METADATA.object_type%TYPE,
  p_description		IN IMC_OBJECT_METADATA.description%TYPE,
  p_function_name	IN IMC_OBJECT_METADATA.function_name%TYPE,
  p_parameter_name	IN IMC_OBJECT_METADATA.parameter_name%TYPE,
  p_enabled		IN IMC_OBJECT_METADATA.enabled%TYPE,
  p_application_id	IN IMC_OBJECT_METADATA.application_id%TYPE,
  p_additional_value1	IN IMC_OBJECT_METADATA.additional_value1%TYPE,
  p_additional_value2	IN IMC_OBJECT_METADATA.additional_value2%TYPE,
  p_additional_value3	IN IMC_OBJECT_METADATA.additional_value3%TYPE,
  p_additional_value4	IN IMC_OBJECT_METADATA.additional_value4%TYPE,
  p_additional_value5	IN IMC_OBJECT_METADATA.additional_value5%TYPE,
  p_created_by		IN IMC_OBJECT_METADATA.created_by%TYPE,
  p_creation_date	IN IMC_OBJECT_METADATA.creation_date%TYPE,
  p_last_updated_by	IN IMC_OBJECT_METADATA.last_updated_by%TYPE,
  p_last_update_date	IN IMC_OBJECT_METADATA.last_update_date%TYPE,
  p_last_update_login	IN IMC_OBJECT_METADATA.last_update_login%TYPE
) AS

BEGIN

  UPDATE IMC_OBJECT_METADATA SET
    DESCRIPTION = p_description,
    FUNCTION_NAME = p_function_name,
    PARAMETER_NAME = p_parameter_name,
    ENABLED = p_enabled,
    APPLICATION_ID = DECODE(p_application_id, FND_API.G_MISS_NUM, NULL, p_application_id),
    ADDITIONAL_VALUE1 = DECODE(p_additional_value1, FND_API.G_MISS_CHAR, NULL, p_additional_value1),
    ADDITIONAL_VALUE2 = DECODE(p_additional_value2, FND_API.G_MISS_CHAR, NULL, p_additional_value2),
    ADDITIONAL_VALUE3 = DECODE(p_additional_value3, FND_API.G_MISS_CHAR, NULL, p_additional_value3),
    ADDITIONAL_VALUE4 = DECODE(p_additional_value4, FND_API.G_MISS_CHAR, NULL, p_additional_value4),
    ADDITIONAL_VALUE5 = DECODE(p_additional_value5, FND_API.G_MISS_CHAR, NULL, p_additional_value5),
    CREATED_BY = p_created_by,
    CREATION_DATE = p_creation_date,
    LAST_UPDATED_BY = p_last_updated_by,
    LAST_UPDATE_DATE = p_last_update_date,
    LAST_UPDATE_LOGIN = p_last_update_login
  WHERE OBJECT_TYPE = p_object_type;

  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

  COMMIT;

END Update_Record;

/*=======================================================================*/

PROCEDURE Insert_Record (
  p_metadata_id		IN IMC_OBJECT_METADATA.metadata_id%TYPE,
  p_object_type		IN IMC_OBJECT_METADATA.object_type%TYPE,
  p_description		IN IMC_OBJECT_METADATA.description%TYPE,
  p_function_name	IN IMC_OBJECT_METADATA.function_name%TYPE,
  p_parameter_name	IN IMC_OBJECT_METADATA.parameter_name%TYPE,
  p_enabled		IN IMC_OBJECT_METADATA.enabled%TYPE,
  p_application_id	IN IMC_OBJECT_METADATA.application_id%TYPE,
  p_additional_value1	IN IMC_OBJECT_METADATA.additional_value1%TYPE,
  p_additional_value2	IN IMC_OBJECT_METADATA.additional_value2%TYPE,
  p_additional_value3	IN IMC_OBJECT_METADATA.additional_value3%TYPE,
  p_additional_value4	IN IMC_OBJECT_METADATA.additional_value4%TYPE,
  p_additional_value5	IN IMC_OBJECT_METADATA.additional_value5%TYPE,
  p_created_by		IN IMC_OBJECT_METADATA.created_by%TYPE,
  p_creation_date	IN IMC_OBJECT_METADATA.creation_date%TYPE,
  p_last_updated_by	IN IMC_OBJECT_METADATA.last_updated_by%TYPE,
  p_last_update_date	IN IMC_OBJECT_METADATA.last_update_date%TYPE,
  p_last_update_login	IN IMC_OBJECT_METADATA.last_update_login%TYPE
) AS

BEGIN

  INSERT INTO IMC_OBJECT_METADATA (
    METADATA_ID,
    OBJECT_TYPE,
    DESCRIPTION,
    FUNCTION_NAME,
    PARAMETER_NAME,
    ENABLED,
    APPLICATION_ID,
    ADDITIONAL_VALUE1,
    ADDITIONAL_VALUE2,
    ADDITIONAL_VALUE3,
    ADDITIONAL_VALUE4,
    ADDITIONAL_VALUE5,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (
    p_metadata_id,
    p_object_type,
    p_description,
    p_function_name,
    p_parameter_name,
    p_enabled,
    DECODE(p_application_id, FND_API.G_MISS_NUM, NULL, p_application_id),
    DECODE(p_additional_value1, FND_API.G_MISS_CHAR, NULL, p_additional_value1),
    DECODE(p_additional_value2, FND_API.G_MISS_CHAR, NULL, p_additional_value2),
    DECODE(p_additional_value3, FND_API.G_MISS_CHAR, NULL, p_additional_value3),
    DECODE(p_additional_value4, FND_API.G_MISS_CHAR, NULL, p_additional_value4),
    DECODE(p_additional_value5, FND_API.G_MISS_CHAR, NULL, p_additional_value5),
    p_created_by,
    p_creation_date,
    p_last_updated_by,
    p_last_update_date,
    p_last_update_login
  );

  COMMIT;

END Insert_Record;

/*=======================================================================*/

PROCEDURE Add_Object_Metadata (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE,
  p_description			IN IMC_OBJECT_METADATA.description%TYPE,
  p_function_name		IN IMC_OBJECT_METADATA.function_name%TYPE,
  p_parameter_name		IN IMC_OBJECT_METADATA.parameter_name%TYPE,
  p_enabled			IN IMC_OBJECT_METADATA.enabled%TYPE,
  p_application_id		IN IMC_OBJECT_METADATA.application_id%TYPE,
  p_additional_value1		IN IMC_OBJECT_METADATA.additional_value1%TYPE,
  p_additional_value2		IN IMC_OBJECT_METADATA.additional_value2%TYPE,
  p_additional_value3		IN IMC_OBJECT_METADATA.additional_value3%TYPE,
  p_additional_value4		IN IMC_OBJECT_METADATA.additional_value4%TYPE,
  p_additional_value5		IN IMC_OBJECT_METADATA.additional_value5%TYPE,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
) AS

  l_metadata_id		IMC_OBJECT_METADATA.metadata_id%TYPE;
  l_last_update_login	IMC_OBJECT_METADATA.last_update_login%TYPE;

BEGIN

  /* init last_update_login */
  IF (FND_GLOBAL.conc_login_id = -1) OR (FND_GLOBAL.conc_login_id IS NULL) THEN
    l_last_update_login := FND_GLOBAL.login_id;
  ELSE
    l_last_update_login := FND_GLOBAL.conc_login_id;
  END IF;

  IF Object_Metadata_Exists(p_object_type) = 'Y' THEN
    Update_Record (
      p_object_type,
      p_description,
      p_function_name,
      p_parameter_name,
      nvl(p_enabled, 'Y'),
      p_application_id,
      p_additional_value1,
      p_additional_value2,
      p_additional_value3,
      p_additional_value4,
      p_additional_value5,
      nvl(FND_GLOBAL.user_id, -1), /* Created by */
      SYSDATE, /* Creation date */
      nvl(FND_GLOBAL.user_id, -1), /* Last updated by */
      SYSDATE, /* Last update date */
      l_last_update_login /* Last update login */
    );
  ELSE
    /* init metadata id */
    SELECT IMC_OBJECT_METADATA_S.NEXTVAL INTO l_metadata_id FROM DUAL;

    Insert_Record (
      l_metadata_id,
      p_object_type,
      p_description,
      p_function_name,
      p_parameter_name,
      nvl(p_enabled, 'Y'),
      p_application_id,
      p_additional_value1,
      p_additional_value2,
      p_additional_value3,
      p_additional_value4,
      p_additional_value5,
      nvl(FND_GLOBAL.user_id, -1), /* Created by */
      SYSDATE, /* Creation date */
      nvl(FND_GLOBAL.user_id, -1), /* Last updated by */
      SYSDATE, /* Last update date */
      l_last_update_login /* Last update login */
    );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

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

END Add_Object_Metadata;

/*=======================================================================*/

PROCEDURE Remove_Object_Metadata (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
) AS

BEGIN

  DELETE FROM IMC_OBJECT_METADATA
  WHERE OBJECT_TYPE = p_object_type;

  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MESSAGE.SET_NAME('IMC', g_no_metadata_for_obj_type);
    FND_MSG_PUB.ADD;
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

END Remove_Object_Metadata;

/*=======================================================================*/

PROCEDURE Get_Object_Metadata (
  p_object_type                 IN IMC_OBJECT_METADATA.object_type%TYPE,
  x_metadata_info		OUT NOCOPY ref_cursor_obj_metadata,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY VARCHAR2,
  x_msg_data			OUT NOCOPY VARCHAR2
) AS

  l_query	VARCHAR2(1000);

BEGIN

  l_query := 'SELECT object_type, description, function_name, parameter_name, enabled, application_id, additional_value1, additional_value2, additional_value3, additional_value4, additional_value5 ';
  l_query := l_query || 'FROM IMC_OBJECT_METADATA ';

  IF p_object_type IS NOT NULL THEN
    l_query := l_query || 'WHERE OBJECT_TYPE = ''' || p_object_type || '''';
  ELSE
    l_query := l_query || 'ORDER BY OBJECT_TYPE';
  END IF;

  OPEN x_metadata_info FOR l_query;

  IF x_metadata_info%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IMC', g_no_metadata_for_obj_type);
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

END Get_Object_Metadata;

/*=======================================================================*/

FUNCTION Get_Function_Name (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN IMC_OBJECT_METADATA.function_name%TYPE AS

  l_return_val	IMC_OBJECT_METADATA.function_name%TYPE;

BEGIN

  IF p_object_type IS NULL THEN
    RETURN NULL;
  ELSE
    SELECT function_name
    INTO l_return_val
    FROM IMC_OBJECT_METADATA
    WHERE OBJECT_TYPE = p_object_type
    AND ROWNUM = 1;
  END IF;

  RETURN l_return_val;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END Get_Function_Name;

/*=======================================================================*/

FUNCTION Get_Parameter_Name (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN IMC_OBJECT_METADATA.parameter_name%TYPE AS

  l_return_val	IMC_OBJECT_METADATA.parameter_name%TYPE;

BEGIN

  IF p_object_type IS NULL THEN
    RETURN NULL;
  ELSE
    SELECT parameter_name
    INTO l_return_val
    FROM IMC_OBJECT_METADATA
    WHERE OBJECT_TYPE = p_object_type
    AND ROWNUM = 1;
  END IF;

  RETURN l_return_val;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END Get_Parameter_Name;

/*=======================================================================*/

FUNCTION Get_Additional_Value (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE,
  p_index			IN NUMBER
) RETURN VARCHAR2 AS

  l_return_val	VARCHAR2(150); /* Type of all additional value columns */
  l_cursorId	INTEGER;
  l_column_name	VARCHAR2(30);
  l_query	VARCHAR2(1000);
  l_dummy	INTEGER;

BEGIN

  IF p_object_type IS NULL THEN
    RETURN NULL;
  ELSE
    -- TO-DO: Execute query, return column value.
    l_cursorId := DBMS_SQL.OPEN_CURSOR;
    l_column_name := 'ADDITIONAL_VALUE' || p_index;
    l_query := 'SELECT ' || l_column_name || ' ' ||
               'FROM IMC_OBJECT_METADATA ' ||
               'WHERE OBJECT_TYPE = ''' || p_object_type || ''' ' ||
               'AND ROWNUM = 1';
    DBMS_SQL.PARSE(l_cursorId, l_query, DBMS_SQL.V7);
    DBMS_SQL.DEFINE_COLUMN(l_cursorId, 1, l_return_val, 150);

    l_dummy := DBMS_SQL.EXECUTE(l_cursorId);

    LOOP
      IF DBMS_SQL.FETCH_ROWS(l_cursorId) = 0 THEN
        RAISE NO_DATA_FOUND;
      ELSE
        DBMS_SQL.COLUMN_VALUE(l_cursorId, 1, l_return_val);
        DBMS_SQL.CLOSE_CURSOR(l_cursorId);
        RETURN l_return_val;
      END IF;
    END LOOP;

  END IF;

  RETURN l_return_val;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursorId);
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursorId);
    RETURN NULL;

END Get_Additional_Value;

/*=======================================================================*/

FUNCTION Get_File_Name (
  p_object_type			IN IMC_OBJECT_METADATA.object_type%TYPE
) RETURN VARCHAR2 AS

  l_function_name	IMC_OBJECT_METADATA.function_name%TYPE;
  l_return_val		VARCHAR2(30);

BEGIN

  IF p_object_type IS NULL THEN
    RETURN NULL;
  ELSE
    SELECT FUNCTION_NAME
    INTO l_function_name
    FROM IMC_OBJECT_METADATA
    WHERE OBJECT_TYPE = p_object_type
    AND ROWNUM = 1;
  END IF;

  SELECT WEB_HTML_CALL
  INTO l_return_val
  FROM FND_FORM_FUNCTIONS
  WHERE FUNCTION_NAME = l_function_name;

  RETURN l_return_val;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END Get_File_Name;

END IMC_OBJECT_METADATA_PUB;

/
