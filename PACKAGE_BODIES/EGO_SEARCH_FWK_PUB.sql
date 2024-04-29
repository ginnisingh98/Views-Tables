--------------------------------------------------------
--  DDL for Package Body EGO_SEARCH_FWK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_SEARCH_FWK_PUB" AS
/* $Header: EGOPSFWB.pls 120.5.12000000.2 2007/05/03 12:38:19 ksathupa ship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Search Framework                     |
 +---------------------------------------------------------------------------*/

  G_PKG_NAME    CONSTANT VARCHAR2(30):= 'EGO_SEARCH_FWK_PUB';
  g_current_user_id         NUMBER := FND_GLOBAL.User_Id;
  g_current_login_id        NUMBER := FND_GLOBAL.Login_Id;
  g_app_name                VARCHAR2(3) := 'EGO';
  g_null_value              VARCHAR2(6) := '*NULL*';


  --Update the default information
  PROCEDURE Update_Result_Format_Default
  (
    X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
    X_REGION_APPLICATION_ID        IN NUMBER,
    X_REGION_CODE                  IN VARCHAR2,
    X_WEB_USER_ID                  IN NUMBER,
    X_CUSTOMIZATION_LEVEL_ID       IN NUMBER,
    X_IMPORT_FLAG                  IN VARCHAR2,
    X_CLASSIFICATION_1             IN VARCHAR2,
    X_CLASSIFICATION_2             IN VARCHAR2,
    X_CLASSIFICATION_3             IN VARCHAR2,
    X_DATA_LEVEL                   IN VARCHAR2
  )
  IS

    l_count NUMBER;
    l_name  VARCHAR2(2000);

    CURSOR fetch_custmztn_code IS
     select name_query.customization_code customization_code
     from
     AK_CUSTOM_REGIONS_TL name_query ,
     AK_CUSTOM_REGIONS level_id_query ,
     AK_CUSTOM_REGIONS user_id_query ,
     EGO_CUSTOMIZATION_EXT ect ,
     AK_CUSTOM_REGIONS data_level_query
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and name_query.customization_application_id = level_id_query.customization_application_id
     and name_query.customization_code = level_id_query.customization_code
     and name_query.region_application_id = level_id_query.region_application_id
     and name_query.region_code = level_id_query.region_code
     and level_id_query.property_name = 'CUSTOMIZATION_LEVEL_ID'
     and name_query.customization_application_id = ect.customization_application_id
     and name_query.customization_code = ect.customization_code
     and name_query.region_application_id = ect.region_application_id
     and name_query.region_code = ect.region_code
     and data_level_query.property_name (+) = 'DATA_LEVEL'
     and name_query.customization_application_id = data_level_query.customization_application_id(+)
     and name_query.customization_code = data_level_query.customization_code (+)
     and name_query.region_application_id = data_level_query.region_application_id(+)
     and name_query.region_code = data_level_query.region_code(+)
     and user_id_query.property_name = 'WEB_USER_ID'
     and name_query.customization_application_id = user_id_query.customization_application_id
     and name_query.customization_code = user_id_query.customization_code
     and name_query.region_application_id = user_id_query.region_application_id
     and name_query.region_code = user_id_query.region_code
     and name_query.customization_application_id = x_customization_application_id
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code
     and level_id_query.property_number_value = x_customization_level_id
     and nvl(user_id_query.property_number_value, -1) = nvl(x_web_user_id, -1)
     and nvl(ect.classification1, g_null_value) = nvl(x_classification_1, g_null_value)
     and nvl(ect.classification2, g_null_value) = nvl(x_classification_2, g_null_value)
     and nvl(ect.classification3, g_null_value) = nvl(x_classification_3, g_null_value)
     and nvl(data_level_query.property_varchar2_value, g_null_value) = nvl(x_data_level, g_null_value);

    TYPE custmztn_code_tbl IS TABLE OF EGO_RESULTS_FORMAT_V.CUSTOMIZATION_CODE%TYPE INDEX BY BINARY_INTEGER;

    l_custmztn_code_tbl custmztn_code_tbl;

  BEGIN

    OPEN fetch_custmztn_code;
    FETCH fetch_custmztn_code BULK COLLECT INTO l_custmztn_code_tbl;
    CLOSE fetch_custmztn_code;

    FORALL i IN 1..l_custmztn_code_tbl.COUNT
        UPDATE AK_CUSTOM_REGIONS
      SET
        PROPERTY_VARCHAR2_VALUE = 'N'
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND PROPERTY_NAME = 'DEFAULT_RESULT_FLAG'
        AND CUSTOMIZATION_CODE = l_custmztn_code_tbl(i);

    FORALL i IN 1..l_custmztn_code_tbl.COUNT
        UPDATE AK_CUSTOM_REGIONS_TL
      SET
        PROPERTY_VARCHAR2_VALUE = 'N'
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND PROPERTY_NAME = 'DEFAULT_RESULT_FLAG'
        AND CUSTOMIZATION_CODE = l_custmztn_code_tbl(i);

  END;

  --Test whether or not this criteria template name is in existence

  PROCEDURE Check_Result_Format_Deletion
  (
    X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
    X_CUSTOMIZATION_CODE           IN VARCHAR2,
    X_REGION_APPLICATION_ID        IN NUMBER,
    X_REGION_CODE                  IN VARCHAR2,
    X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE,
    X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
    X_ERRORCODE                    OUT NOCOPY NUMBER
  )
  IS

    l_count NUMBER;
    l_name  VARCHAR2(2000);

    CURSOR get_name IS
     select name_query.property_varchar2_value name
     from AK_CUSTOM_REGIONS_TL name_query
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and name_query.customization_application_id = x_customization_application_id
     and name_query.customization_code = x_customization_code
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code;

  BEGIN

    IF FND_API.To_Boolean(x_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
    END IF;

    SELECT
      COUNT(*)
    INTO
      l_count
    FROM
      EGO_CUSTOMIZATION_EXT
    WHERE
      RF_CUSTOMIZATION_APPL_ID = X_CUSTOMIZATION_APPLICATION_ID
      AND RF_CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
      AND RF_REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
      AND RF_REGION_CODE = X_REGION_CODE;

    IF (l_count > 0) THEN
      FOR name_rec IN get_name LOOP
        l_name := name_rec.name;
        exit;
      END LOOP;

      FND_MESSAGE.Set_Name(g_app_name, 'EGO_RF_RF_EXISTS');
      FND_MESSAGE.Set_Token('NAME', l_name);
      FND_MSG_PUB.Add;

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    ELSE

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    END IF;

  END Check_Result_Format_Deletion;

  FUNCTION Criteria_Template_Name_Exists
  (
    X_NAME                          IN     VARCHAR2,
    X_WEB_USER_ID                   IN     NUMBER,
    X_CUSTOMIZATION_CODE            IN     VARCHAR2 DEFAULT NULL,
    X_CUSTOMIZATION_APPLICATION_ID  IN     NUMBER,
    X_REGION_APPLICATION_ID         IN     NUMBER,
    X_REGION_CODE                   IN     VARCHAR2,
    X_CUSTOMIZATION_LEVEL_ID        IN     NUMBER,
    X_CLASSIFICATION1               IN     VARCHAR2,
    X_CLASSIFICATION2               IN     VARCHAR2,
    X_CLASSIFICATION3               IN     VARCHAR2
  )
  RETURN BOOLEAN
  IS

    l_count    NUMBER;

  BEGIN

    IF (X_CUSTOMIZATION_CODE IS NOT NULL) THEN

      IF (X_CUSTOMIZATION_LEVEL_ID = 30) THEN

        SELECT
          COUNT(*)
        INTO
          l_count
        FROM
          EGO_CRITERIA_TEMPLATES_V
        WHERE
          NAME = X_NAME
          AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND (CUSTOMIZATION_LEVEL_ID = 60 OR (CUSTOMIZATION_LEVEL_ID = 30 AND WEB_USER_ID = X_WEB_USER_ID))
          AND CUSTOMIZATION_CODE <> X_CUSTOMIZATION_CODE
          AND NVL(X_CLASSIFICATION1, g_null_value) = NVL(CLASSIFICATION1, g_null_value)
          AND NVL(X_CLASSIFICATION2, g_null_value) = NVL(CLASSIFICATION2, g_null_value)
          AND NVL(X_CLASSIFICATION3, g_null_value) = NVL(CLASSIFICATION3, g_null_value);

      ELSE

        SELECT
          COUNT(*)
        INTO
          l_count
        FROM
          EGO_CRITERIA_TEMPLATES_V
        WHERE
          NAME = X_NAME
          AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND CUSTOMIZATION_CODE <> X_CUSTOMIZATION_CODE
          AND NVL(X_CLASSIFICATION1, g_null_value) = NVL(CLASSIFICATION1, g_null_value)
          AND NVL(X_CLASSIFICATION2, g_null_value) = NVL(CLASSIFICATION2, g_null_value)
          AND NVL(X_CLASSIFICATION3, g_null_value) = NVL(CLASSIFICATION3, g_null_value);

      END IF;

    ELSE

      IF (X_CUSTOMIZATION_LEVEL_ID = 30) THEN

        SELECT
          COUNT(*)
        INTO
          l_count
        FROM
          EGO_CRITERIA_TEMPLATES_V
        WHERE
          NAME = X_NAME
          AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND (CUSTOMIZATION_LEVEL_ID = 60 OR (CUSTOMIZATION_LEVEL_ID = 30 AND WEB_USER_ID = X_WEB_USER_ID))
          AND NVL(X_CLASSIFICATION1, g_null_value) = NVL(CLASSIFICATION1, g_null_value)
          AND NVL(X_CLASSIFICATION2, g_null_value) = NVL(CLASSIFICATION2, g_null_value)
          AND NVL(X_CLASSIFICATION3, g_null_value) = NVL(CLASSIFICATION3, g_null_value);

      ELSE

        SELECT
          COUNT(*)
        INTO
          l_count
        FROM
          EGO_CRITERIA_TEMPLATES_V
        WHERE
          NAME = X_NAME
          AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND NVL(X_CLASSIFICATION1, g_null_value) = NVL(CLASSIFICATION1, g_null_value)
          AND NVL(X_CLASSIFICATION2, g_null_value) = NVL(CLASSIFICATION2, g_null_value)
          AND NVL(X_CLASSIFICATION3, g_null_value) = NVL(CLASSIFICATION3, g_null_value);

      END IF;

    END IF;

    RETURN l_count > 0;

  END Criteria_Template_Name_Exists;

  FUNCTION Results_Format_Name_Exists
  (
    X_NAME                          IN     VARCHAR2,
    X_WEB_USER_ID                   IN     NUMBER,
    X_CUSTOMIZATION_CODE            IN     VARCHAR2,
    X_CUSTOMIZATION_APPLICATION_ID  IN     NUMBER,
    X_REGION_APPLICATION_ID         IN     NUMBER,
    X_REGION_CODE                   IN     VARCHAR2,
    X_CUSTOMIZATION_LEVEL_ID        IN     NUMBER,
    X_CLASSIFICATION1               IN     VARCHAR2,
    X_CLASSIFICATION2               IN     VARCHAR2,
    X_CLASSIFICATION3               IN     VARCHAR2
  )
  RETURN BOOLEAN
  IS

    l_count    NUMBER;

    -- get count with customization code (wcc) , with level id (wlv)
    CURSOR get_cnt_wccwlv IS
     select count(*) count
     from
     AK_CUSTOM_REGIONS_TL name_query ,
     AK_CUSTOM_REGIONS level_id_query ,
     AK_CUSTOM_REGIONS user_id_query ,
     EGO_CUSTOMIZATION_EXT ect
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and name_query.customization_application_id = level_id_query.customization_application_id
     and name_query.customization_code = level_id_query.customization_code
     and name_query.region_application_id = level_id_query.region_application_id
     and name_query.region_code = level_id_query.region_code
     and level_id_query.property_name = 'CUSTOMIZATION_LEVEL_ID'
     and name_query.customization_application_id = ect.customization_application_id
     and name_query.customization_code = ect.customization_code
     and name_query.region_application_id = ect.region_application_id
     and name_query.region_code = ect.region_code
     and user_id_query.property_name = 'WEB_USER_ID'
     and name_query.customization_application_id = user_id_query.customization_application_id
     and name_query.customization_code = user_id_query.customization_code
     and name_query.region_application_id = user_id_query.region_application_id
     and name_query.region_code = user_id_query.region_code
     and name_query.property_varchar2_value = x_name
     and name_query.customization_application_id = x_customization_application_id
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code
     and (level_id_query.property_number_value = 60
          OR
         (level_id_query.property_number_value = 30 AND
          user_id_query.property_number_value = x_web_user_id))
     and name_query.customization_code <> x_customization_code
     and nvl(ect.classification1, g_null_value) = nvl(x_classification1, g_null_value)
     and nvl(ect.classification2, g_null_value) = nvl(x_classification2, g_null_value)
     and nvl(ect.classification3, g_null_value) = nvl(x_classification3, g_null_value);

    -- get count with customization code (wcc) , without level id (wolv)
    CURSOR get_cnt_wccwolv IS
     select count(*) count
     from
     AK_CUSTOM_REGIONS_TL name_query ,
     AK_CUSTOM_REGIONS level_id_query ,
     AK_CUSTOM_REGIONS user_id_query ,
     EGO_CUSTOMIZATION_EXT ect
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and name_query.customization_application_id = level_id_query.customization_application_id
     and name_query.customization_code = level_id_query.customization_code
     and name_query.region_application_id = level_id_query.region_application_id
     and name_query.region_code = level_id_query.region_code
     and level_id_query.property_name = 'CUSTOMIZATION_LEVEL_ID'
     and name_query.customization_application_id = ect.customization_application_id
     and name_query.customization_code = ect.customization_code
     and name_query.region_application_id = ect.region_application_id
     and name_query.region_code = ect.region_code
     and user_id_query.property_name = 'WEB_USER_ID'
     and name_query.customization_application_id = user_id_query.customization_application_id
     and name_query.customization_code = user_id_query.customization_code
     and name_query.region_application_id = user_id_query.region_application_id
     and name_query.region_code = user_id_query.region_code
     and name_query.property_varchar2_value = x_name
     and name_query.customization_application_id = x_customization_application_id
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code
     and name_query.customization_code <> x_customization_code
     and nvl(ect.classification1, g_null_value) = nvl(x_classification1, g_null_value)
     and nvl(ect.classification2, g_null_value) = nvl(x_classification2, g_null_value)
     and nvl(ect.classification3, g_null_value) = nvl(x_classification3, g_null_value);

    -- get count without customization code (wocc) , with level id (wlv)
    CURSOR get_cnt_woccwlv IS
     select count(*) count
     from
     AK_CUSTOM_REGIONS_TL name_query ,
     AK_CUSTOM_REGIONS level_id_query ,
     AK_CUSTOM_REGIONS user_id_query ,
     EGO_CUSTOMIZATION_EXT ect
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and name_query.customization_application_id = level_id_query.customization_application_id
     and name_query.customization_code = level_id_query.customization_code
     and name_query.region_application_id = level_id_query.region_application_id
     and name_query.region_code = level_id_query.region_code
     and level_id_query.property_name = 'CUSTOMIZATION_LEVEL_ID'
     and name_query.customization_application_id = ect.customization_application_id
     and name_query.customization_code = ect.customization_code
     and name_query.region_application_id = ect.region_application_id
     and name_query.region_code = ect.region_code
     and user_id_query.property_name = 'WEB_USER_ID'
     and name_query.customization_application_id = user_id_query.customization_application_id
     and name_query.customization_code = user_id_query.customization_code
     and name_query.region_application_id = user_id_query.region_application_id
     and name_query.region_code = user_id_query.region_code
     and name_query.property_varchar2_value = x_name
     and name_query.customization_application_id = x_customization_application_id
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code
     and (level_id_query.property_number_value = 60
          OR
         (level_id_query.property_number_value = 30 AND
          user_id_query.property_number_value = x_web_user_id))
     and nvl(ect.classification1, g_null_value) = nvl(x_classification1, g_null_value)
     and nvl(ect.classification2, g_null_value) = nvl(x_classification2, g_null_value)
     and nvl(ect.classification3, g_null_value) = nvl(x_classification3, g_null_value);

    -- get count without customization code (wocc) , without level id (wolv)
    CURSOR get_cnt_woccwolv IS
     select count(*) count
     from
     AK_CUSTOM_REGIONS_TL name_query ,
     AK_CUSTOM_REGIONS level_id_query ,
     AK_CUSTOM_REGIONS user_id_query ,
     EGO_CUSTOMIZATION_EXT ect
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and name_query.customization_application_id = level_id_query.customization_application_id
     and name_query.customization_code = level_id_query.customization_code
     and name_query.region_application_id = level_id_query.region_application_id
     and name_query.region_code = level_id_query.region_code
     and level_id_query.property_name = 'CUSTOMIZATION_LEVEL_ID'
     and name_query.customization_application_id = ect.customization_application_id
     and name_query.customization_code = ect.customization_code
     and name_query.region_application_id = ect.region_application_id
     and name_query.region_code = ect.region_code
     and user_id_query.property_name = 'WEB_USER_ID'
     and name_query.customization_application_id = user_id_query.customization_application_id
     and name_query.customization_code = user_id_query.customization_code
     and name_query.region_application_id = user_id_query.region_application_id
     and name_query.region_code = user_id_query.region_code
     and name_query.property_varchar2_value = x_name
     and name_query.customization_application_id = x_customization_application_id
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code
     and nvl(ect.classification1, g_null_value) = nvl(x_classification1, g_null_value)
     and nvl(ect.classification2, g_null_value) = nvl(x_classification2, g_null_value)
     and nvl(ect.classification3, g_null_value) = nvl(x_classification3, g_null_value);

  BEGIN

    IF (X_CUSTOMIZATION_CODE IS NOT NULL) THEN

      IF (X_CUSTOMIZATION_LEVEL_ID = 30) THEN

        FOR count_rec IN get_cnt_wccwlv LOOP
           l_count := count_rec.count;
        END LOOP;

      ELSE

        FOR count_rec IN get_cnt_wccwolv LOOP
           l_count := count_rec.count;
        END LOOP;

      END IF;

    ELSE

      IF (X_CUSTOMIZATION_LEVEL_ID = 30) THEN

        FOR count_rec IN get_cnt_woccwlv LOOP
           l_count := count_rec.count;
        END LOOP;

      ELSE

        FOR count_rec IN get_cnt_woccwolv LOOP
           l_count := count_rec.count;
        END LOOP;

      END IF;

    END IF;

    RETURN l_count > 0;

  END Results_Format_Name_Exists;


  PROCEDURE Create_Criteria_Template
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_VERTICALIZATION_ID           IN     VARCHAR2,
     X_LOCALIZATION_CODE            IN     VARCHAR2,
     X_ORG_ID                       IN     NUMBER,
     X_SITE_ID                      IN     NUMBER,
     X_RESPONSIBILITY_ID            IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_DEFAULT_CUSTOMIZATION_FLAG   IN     VARCHAR2,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_START_DATE_ACTIVE            IN     DATE,
     X_END_DATE_ACTIVE              IN     DATE,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER   DEFAULT NULL,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2 DEFAULT NULL,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER   DEFAULT NULL,
     X_RF_REGION_CODE               IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2 := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY   VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY   NUMBER
  )
  IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);
  l_current_user           NUMBER;

  BEGIN

    IF (FND_API.To_Boolean(x_init_msg_list) = TRUE) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --first check unique constraint

    IF (Criteria_Template_Name_Exists(X_NAME
                                     ,X_WEB_USER_ID
                                     ,NULL
                                     ,X_CUSTOMIZATION_APPLICATION_ID
                                     ,X_REGION_APPLICATION_ID
                                     ,X_REGION_CODE
                                     ,X_CUSTOMIZATION_LEVEL_ID
                                     ,X_CLASSIFICATION_1
                                     ,X_CLASSIFICATION_2
                                     ,X_CLASSIFICATION_3) = FALSE) THEN

      -- first thing updating other criteria template default flag if "Y" in this one
      -- only update the one with same customization_level
      -- if user level customization, only update his default

      IF(X_DEFAULT_CUSTOMIZATION_FLAG = 'Y') THEN

        UPDATE
          AK_CUSTOMIZATIONS
        SET
          DEFAULT_CUSTOMIZATION_FLAG = 'N'
        WHERE
          CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND CUSTOMIZATION_LEVEL_ID = X_CUSTOMIZATION_LEVEL_ID
          AND NVL(WEB_USER_ID, -1) = NVL(X_WEB_USER_ID, -1)
          AND CUSTOMIZATION_CODE IN (
                                     SELECT
                                       CUSTOMIZATION_CODE
                                     FROM
                                       EGO_CUSTOMIZATION_EXT
                                     WHERE
                                       CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
                                       AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
                                       AND REGION_CODE = X_REGION_CODE
                                       AND NVL(CLASSIFICATION1, ' ') = NVL(X_CLASSIFICATION_1, ' ')
                                       AND NVL(CLASSIFICATION2, ' ') = NVL(X_CLASSIFICATION_2, ' ')
                                       AND NVL(CLASSIFICATION3, ' ') = NVL(X_CLASSIFICATION_3, ' ')
                                     );
       END IF;

       IF( X_CREATED_BY IS NOT NULL) THEN --added for bug 3964722;
          l_current_user := X_CREATED_BY;
       ELSE
          l_current_user := g_current_user_id;
       END IF;


       AK_CUSTOMIZATIONS_PKG.INSERT_ROW
       (
         X_ROWID                        => l_rowid,
         X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
         X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
         X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
         X_REGION_CODE                  => X_REGION_CODE,
         X_NAME                         => X_NAME,
         X_DESCRIPTION                  => X_DESCRIPTION,
         X_VERTICALIZATION_ID           => X_VERTICALIZATION_ID,
         X_LOCALIZATION_CODE            => X_LOCALIZATION_CODE,
         X_ORG_ID                       => X_ORG_ID,
         X_SITE_ID                      => X_SITE_ID,
         X_RESPONSIBILITY_ID            => X_RESPONSIBILITY_ID,
         X_WEB_USER_ID                  => X_WEB_USER_ID,
         X_DEFAULT_CUSTOMIZATION_FLAG   => X_DEFAULT_CUSTOMIZATION_FLAG,
         X_CUSTOMIZATION_LEVEL_ID       => X_CUSTOMIZATION_LEVEL_ID,
         X_CREATED_BY                   => X_CREATED_BY,
         X_CREATION_DATE                => X_CREATION_DATE,
         X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
         X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
         X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
         X_START_DATE_ACTIVE            => X_START_DATE_ACTIVE,
         X_END_DATE_ACTIVE              => X_END_DATE_ACTIVE
       );

      INSERT INTO EGO_CUSTOMIZATION_EXT
      (
        CUSTOMIZATION_APPLICATION_ID,
        CUSTOMIZATION_CODE,
        REGION_APPLICATION_ID,
        REGION_CODE,
        CLASSIFICATION1,
        CLASSIFICATION2,
        CLASSIFICATION3,
        RF_CUSTOMIZATION_APPL_ID,
        RF_CUSTOMIZATION_CODE,
        RF_REGION_APPLICATION_ID,
        RF_REGION_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        X_CUSTOMIZATION_APPLICATION_ID,
        X_CUSTOMIZATION_CODE,
        X_REGION_APPLICATION_ID,
        X_REGION_CODE,
        X_CLASSIFICATION_1,
        X_CLASSIFICATION_2,
        X_CLASSIFICATION_3,
        X_RF_CUSTOMIZATION_APPL_ID,
        X_RF_CUSTOMIZATION_CODE,
        X_RF_REGION_APPLICATION_ID,
        X_RF_REGION_CODE,
        l_current_user,
        l_Sysdate,
        l_current_user,
        l_Sysdate,
        l_current_user
      );

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE

      FND_MESSAGE.Set_Name(g_app_name, 'EGO_DUP_CRITERIA_TEMPLATE');
      FND_MSG_PUB.Add;

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    END IF;

  END Create_Criteria_Template;

-------------------------------------------------------------

  PROCEDURE Update_Criteria_Template
  (
    X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
    X_CUSTOMIZATION_CODE           IN     VARCHAR2,
    X_REGION_APPLICATION_ID        IN     NUMBER,
    X_REGION_CODE                  IN     VARCHAR2,
    X_NAME                         IN     VARCHAR2,
    X_DESCRIPTION                  IN     VARCHAR2,
    X_VERTICALIZATION_ID           IN     VARCHAR2,
    X_LOCALIZATION_CODE            IN     VARCHAR2,
    X_ORG_ID                       IN     NUMBER,
    X_SITE_ID                      IN     NUMBER,
    X_RESPONSIBILITY_ID            IN     NUMBER,
    X_WEB_USER_ID                  IN     NUMBER,
    X_DEFAULT_CUSTOMIZATION_FLAG   IN     VARCHAR2,
    X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
    X_LAST_UPDATED_BY              IN     NUMBER,
    X_LAST_UPDATE_DATE             IN     DATE,
    X_LAST_UPDATE_LOGIN            IN     NUMBER,
    X_START_DATE_ACTIVE            IN     DATE,
    X_END_DATE_ACTIVE              IN     DATE,
    X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
    X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
    X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
    X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER DEFAULT NULL,
    X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2 DEFAULT NULL,
    X_RF_REGION_APPLICATION_ID     IN     NUMBER DEFAULT NULL,
    X_RF_REGION_CODE               IN     VARCHAR2 DEFAULT NULL,
    X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
    X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
    X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
  IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);

  BEGIN

    IF FND_API.To_Boolean(x_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
    END IF;

    IF (Criteria_Template_Name_Exists(X_NAME
                                     ,X_WEB_USER_ID
                                     ,X_CUSTOMIZATION_CODE
                                     ,X_CUSTOMIZATION_APPLICATION_ID
                                     ,X_REGION_APPLICATION_ID
                                     ,X_REGION_CODE
                                     ,X_CUSTOMIZATION_LEVEL_ID
                                     ,X_CLASSIFICATION_1
                                     ,X_CLASSIFICATION_2
                                     ,X_CLASSIFICATION_3) = FALSE) THEN

      -- first thing updating other criteria template default flag if "Y" in this one

      IF( X_DEFAULT_CUSTOMIZATION_FLAG = 'Y') THEN

      UPDATE
        AK_CUSTOMIZATIONS
      SET
        DEFAULT_CUSTOMIZATION_FLAG = 'N'
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND CUSTOMIZATION_LEVEL_ID = X_CUSTOMIZATION_LEVEL_ID
        AND NVL(WEB_USER_ID, -1) = NVL(X_WEB_USER_ID, -1)
        AND CUSTOMIZATION_CODE IN (
                                   SELECT
                                     CUSTOMIZATION_CODE
                                   FROM
                                     EGO_CUSTOMIZATION_EXT
                                   WHERE
                                     CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
                                     AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
                                     AND REGION_CODE = X_REGION_CODE
                                     AND NVL(CLASSIFICATION1, ' ') = NVL(X_CLASSIFICATION_1, ' ')
                                     AND NVL(CLASSIFICATION2, ' ') = NVL(X_CLASSIFICATION_2, ' ')
                                     AND NVL(CLASSIFICATION3, ' ') = NVL(X_CLASSIFICATION_3, ' ')
                                  );
       END IF;


       AK_CUSTOMIZATIONS_PKG.UPDATE_ROW
       (
         X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
         X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
         X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
         X_REGION_CODE                  => X_REGION_CODE,
         X_NAME                         => X_NAME,
         X_DESCRIPTION                  => X_DESCRIPTION,
         X_VERTICALIZATION_ID           => X_VERTICALIZATION_ID,
         X_LOCALIZATION_CODE            => X_LOCALIZATION_CODE,
         X_ORG_ID                       => X_ORG_ID,
         X_SITE_ID                      => X_SITE_ID,
         X_RESPONSIBILITY_ID            => X_RESPONSIBILITY_ID,
         X_WEB_USER_ID                  => X_WEB_USER_ID,
         X_DEFAULT_CUSTOMIZATION_FLAG   => X_DEFAULT_CUSTOMIZATION_FLAG,
         X_CUSTOMIZATION_LEVEL_ID       => X_CUSTOMIZATION_LEVEL_ID,
         X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
         X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
         X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
         X_START_DATE_ACTIVE            => X_START_DATE_ACTIVE,
         X_END_DATE_ACTIVE              => X_END_DATE_ACTIVE
       );

      --Now we try to update the results format

      UPDATE
        EGO_CUSTOMIZATION_EXT
      SET
        RF_CUSTOMIZATION_APPL_ID = X_RF_CUSTOMIZATION_APPL_ID,
        RF_CUSTOMIZATION_CODE = X_RF_CUSTOMIZATION_CODE,
        RF_REGION_APPLICATION_ID = X_RF_REGION_APPLICATION_ID,
        RF_REGION_CODE = X_RF_REGION_CODE
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE

      FND_MESSAGE.Set_Name(g_app_name, 'EGO_DUP_CRITERIA_TEMPLATE');
      FND_MSG_PUB.Add;

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    END IF;

  END Update_Criteria_Template;

-------------------------------------------------------------

 PROCEDURE Delete_Criteria_Template
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  )
  IS

  l_name                   VARCHAR2(2000);
  l_count                  NUMBER := NULL;

  BEGIN

    IF FND_API.To_Boolean(x_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
    END IF;

    SELECT
      COUNT(*)
    INTO
      l_count
    FROM
      EGO_CUSTOMIZATION_RF
    WHERE
      RF_CUSTOMIZATION_APPL_ID = X_CUSTOMIZATION_APPLICATION_ID
      AND RF_CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
      AND RF_REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
      AND RF_REGION_CODE = X_REGION_CODE;

    IF (l_count = 0) THEN

      AK_CUSTOMIZATIONS_PKG.DELETE_ROW
      (
         X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
         X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
         X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
         X_REGION_CODE                  => X_REGION_CODE
      );

      DELETE
      FROM
        EGO_CUSTOMIZATION_EXT
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE;

      DELETE
      FROM
        EGO_CUSTOMIZATION_RF
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE;

      DELETE
      FROM
        AK_CRITERIA
      WHERE
        CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE

      SELECT
        NAME INTO l_name
      FROM
        EGO_CRITERIA_TEMPLATES_V
      WHERE
       CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
       AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
       AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
       AND REGION_CODE = X_REGION_CODE;

      FND_MESSAGE.Set_Name(g_app_name, 'EGO_CT_RF_EXISTS');
      FND_MESSAGE.Set_Token('NAME', l_name);
      FND_MSG_PUB.Add;

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    END IF;

  END Delete_Criteria_Template;

  PROCEDURE translate_criteria_template
  (  p_customization_application_id  IN   NUMBER
    ,p_customization_code            IN   VARCHAR2
    ,p_region_application_id         IN   NUMBER
    ,p_region_code                   IN   VARCHAR2
    ,p_customization_level_id        IN   NUMBER
    ,p_last_update_date              IN   VARCHAR2
    ,p_last_updated_by               IN   NUMBER
    ,p_name                          IN   VARCHAR2
    ,p_description                   IN   VARCHAR2
    ,x_return_status                 OUT  NOCOPY VARCHAR2
    ,x_msg_data                      OUT  NOCOPY VARCHAR2
  ) IS

  CURSOR c_get_last_update_info IS
  SELECT last_updated_by, last_update_date
  FROM   ak_customizations_tl
  WHERE  customization_application_id = p_customization_application_id
    AND  customization_code      =  p_customization_code
    AND  region_application_id   =  p_region_application_id
    AND  region_code             =  p_region_code
    AND  USERENV('LANG') IN (language, source_lang);

    l_last_update_date            ak_customizations.last_update_date%TYPE;
    l_last_updated_by             ak_customizations.last_updated_by%TYPE;
    l_verticalization_id          ak_customizations.verticalization_id%TYPE;
    l_localization_code           ak_customizations.localization_code%TYPE;
    l_org_id                      ak_customizations.org_id%TYPE;
    l_site_id                     ak_customizations.site_id%TYPE;
    l_responsibility_id           ak_customizations.responsibility_id%TYPE;
    l_web_user_id                 ak_customizations.web_user_id%TYPE;
    l_default_customization_flag  ak_customizations.default_customization_flag%TYPE;
    l_customization_level_id      ak_customizations.customization_level_id%TYPE;
    l_start_date_active           ak_customizations.start_date_active%TYPE;
    l_end_date_active             ak_customizations.end_date_active%TYPE;

  BEGIN

    OPEN C_get_last_update_info;
    FETCH c_get_last_update_info
    INTO  l_last_updated_by, l_last_update_date;
    CLOSE c_get_last_update_info;

    IF (fnd_load_util.upload_test(p_last_updated_by
                                 ,p_last_update_date
                                 ,l_last_updated_by
                                 ,l_last_update_date
                                 ,NULL)) THEN
      SELECT
         verticalization_id
        ,localization_code
        ,org_id
        ,site_id
        ,responsibility_id
        ,web_user_id
        ,default_customization_flag
        ,customization_level_id
        ,start_date_active
        ,end_date_active
      INTO
         l_verticalization_id
        ,l_localization_code
        ,l_org_id
        ,l_site_id
        ,l_responsibility_id
        ,l_web_user_id
        ,l_default_customization_flag
        ,l_customization_level_id
        ,l_start_date_active
        ,l_end_date_active
      FROM  ak_customizations
      WHERE CUSTOMIZATION_APPLICATION_ID = p_customization_application_id
        AND CUSTOMIZATION_CODE           = p_customization_code
        AND REGION_APPLICATION_ID        = p_region_application_id
        AND REGION_CODE                  = p_region_code
        AND CUSTOMIZATION_LEVEL_ID       = p_customization_level_id;

      AK_CUSTOMIZATIONS_PKG.UPDATE_ROW
       (
         X_CUSTOMIZATION_APPLICATION_ID => p_customization_application_id,
         X_CUSTOMIZATION_CODE           => p_customization_code,
         X_REGION_APPLICATION_ID        => p_region_application_id,
         X_REGION_CODE                  => p_region_code,
         X_NAME                         => p_name,
         X_DESCRIPTION                  => p_description,
         X_VERTICALIZATION_ID           => l_verticalization_id,
         X_LOCALIZATION_CODE            => l_localization_code,
         X_ORG_ID                       => l_org_id,
         X_SITE_ID                      => l_site_id,
         X_RESPONSIBILITY_ID            => l_responsibility_id,
         X_WEB_USER_ID                  => l_web_user_id,
         X_DEFAULT_CUSTOMIZATION_FLAG   => l_default_customization_flag,
         X_CUSTOMIZATION_LEVEL_ID       => p_customization_level_id,
         X_LAST_UPDATED_BY              => p_last_updated_by,
         X_LAST_UPDATE_DATE             => SYSDATE,
         X_LAST_UPDATE_LOGIN            => fnd_global.login_id,
         X_START_DATE_ACTIVE            => l_start_date_active,
         X_END_DATE_ACTIVE              => l_end_date_active
       );
    END IF;
    x_return_status  := 'S';
  EXCEPTION
    WHEN OTHERS THEN
     x_return_status  := 'E';
     x_msg_data       := SQLERRM;
  END translate_criteria_template;


---------------------------------------------------------
  PROCEDURE create_criteria_template_rf
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER,
     X_RF_REGION_CODE               IN     VARCHAR2,
     X_RF_TAG                       IN     VARCHAR2,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
  IS

  l_Sysdate                DATE := Sysdate;

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

  IF (X_RF_CUSTOMIZATION_CODE IS NOT NULL) THEN

    INSERT INTO EGO_CUSTOMIZATION_RF
    (
      CUSTOMIZATION_APPLICATION_ID,
      CUSTOMIZATION_CODE,
      REGION_APPLICATION_ID,
      REGION_CODE,
      RF_CUSTOMIZATION_APPL_ID,
      RF_CUSTOMIZATION_CODE,
      RF_REGION_APPLICATION_ID,
      RF_REGION_CODE,
      RF_TAG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      X_CUSTOMIZATION_APPLICATION_ID,
      X_CUSTOMIZATION_CODE,
      X_REGION_APPLICATION_ID,
      X_REGION_CODE,
      X_RF_CUSTOMIZATION_APPL_ID,
      X_RF_CUSTOMIZATION_CODE,
      X_RF_REGION_APPLICATION_ID,
      X_RF_REGION_CODE,
      X_RF_TAG,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN
    );
  END IF;

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END create_criteria_template_rf;


  PROCEDURE update_criteria_template_rf
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_RF_CUSTOMIZATION_APPL_ID     IN     NUMBER,
     X_RF_CUSTOMIZATION_CODE        IN     VARCHAR2,
     X_RF_REGION_APPLICATION_ID     IN     NUMBER,
     X_RF_REGION_CODE               IN     VARCHAR2,
     X_RF_TAG                       IN     VARCHAR2,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
  IS

  l_Sysdate                DATE := Sysdate;
  l_count                 NUMBER;

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

  SELECT
    COUNT(*) INTO l_count
  FROM
    EGO_CUSTOMIZATION_RF
  WHERE
    CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND RF_TAG = X_RF_TAG;

  IF (l_count > 0) THEN

    IF (X_RF_CUSTOMIZATION_CODE IS NULL) THEN
      DELETE_CRITERIA_TEMPLATE_RF(
                                   X_CUSTOMIZATION_APPLICATION_ID
                                  ,X_CUSTOMIZATION_CODE
                                  ,X_REGION_APPLICATION_ID
                                  ,X_REGION_CODE
                                  ,X_RF_TAG
                                  ,FND_API.G_FALSE
                                  ,X_RETURN_STATUS
                                  ,X_ERRORCODE
                                 );
    ELSE


      UPDATE EGO_CUSTOMIZATION_RF SET
        RF_CUSTOMIZATION_APPL_ID = X_RF_CUSTOMIZATION_APPL_ID,
        RF_CUSTOMIZATION_CODE = X_RF_CUSTOMIZATION_CODE,
        RF_REGION_APPLICATION_ID = X_RF_REGION_APPLICATION_ID,
        RF_REGION_CODE = X_RF_REGION_CODE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
      WHERE
        CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND RF_TAG = X_RF_TAG;

    END IF;

  END IF;

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';

  END update_criteria_template_rf;


  PROCEDURE delete_criteria_template_rf
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_RF_TAG                       IN     VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
  IS

  l_Sysdate                DATE := Sysdate;
  l_count                 NUMBER;

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

  SELECT
    COUNT(*) INTO l_count
  FROM
    EGO_CUSTOMIZATION_RF
  WHERE
    CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND RF_TAG = X_RF_TAG;

  IF (l_count > 0) THEN

    DELETE FROM EGO_CUSTOMIZATION_RF
    WHERE
      CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
      AND CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
      AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
      AND REGION_CODE = X_REGION_CODE
      AND RF_TAG = X_RF_TAG;

  END IF;

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';

  END delete_criteria_template_rf;

---------------------------------------------------------------
  PROCEDURE create_result_format
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_NUM_ROWS_DISPLAYED           IN     NUMBER,
     X_DEFAULT_RESULT_FLAG          IN     VARCHAR2,
     X_SITE_ID                      IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_IMPORT_FLAG                  IN     VARCHAR2 DEFAULT NULL,
     X_DATA_LEVEL                   IN     VARCHAR2 DEFAULT NULL,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

    --first check unique constraint

  IF (Results_Format_Name_Exists(X_NAME
                               ,X_WEB_USER_ID
                               ,NULL
                               ,X_CUSTOMIZATION_APPLICATION_ID
                               ,X_REGION_APPLICATION_ID
                               ,X_REGION_CODE
                               ,X_CUSTOMIZATION_LEVEL_ID
                               ,X_CLASSIFICATION_1
                               ,X_CLASSIFICATION_2
                               ,X_CLASSIFICATION_3) = FALSE) THEN

         AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'RESULT_NAME',
X_PROPERTY_VARCHAR2_VALUE      => X_NAME,
X_PROPERTY_NUMBER_VALUE        => NULL,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

         AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'RESULT_DESCRIPTION',
X_PROPERTY_VARCHAR2_VALUE      => X_DESCRIPTION,
X_PROPERTY_NUMBER_VALUE        => NULL,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

-- first thing updating other result format default flag if "Y" in this one

   IF( X_DEFAULT_RESULT_FLAG = 'Y') THEN


     Update_Result_Format_Default
     (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_WEB_USER_ID,
       X_CUSTOMIZATION_LEVEL_ID,
       X_IMPORT_FLAG,
       X_CLASSIFICATION_1,
       X_CLASSIFICATION_2,
       X_CLASSIFICATION_3,
       X_DATA_LEVEL
     );

   END IF;

         AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'DEFAULT_RESULT_FLAG',
X_PROPERTY_VARCHAR2_VALUE      => X_DEFAULT_RESULT_FLAG,
X_PROPERTY_NUMBER_VALUE        => NULL,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

         AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'NUM_ROWS_DISPLAY',
X_PROPERTY_VARCHAR2_VALUE      => NULL,
X_PROPERTY_NUMBER_VALUE        => X_NUM_ROWS_DISPLAYED,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

         AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'SITE_ID',
X_PROPERTY_VARCHAR2_VALUE      => NULL,
X_PROPERTY_NUMBER_VALUE        => X_SITE_ID,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

         AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'WEB_USER_ID',
X_PROPERTY_VARCHAR2_VALUE      => NULL,
X_PROPERTY_NUMBER_VALUE        => X_WEB_USER_ID,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

        AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_PROPERTY_NAME                => 'CUSTOMIZATION_LEVEL_ID',
X_PROPERTY_VARCHAR2_VALUE      => NULL,
X_PROPERTY_NUMBER_VALUE        => X_CUSTOMIZATION_LEVEL_ID,
X_CRITERIA_JOIN_CONDITION      => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

       IF (X_IMPORT_FLAG IS NOT NULL) THEN

          AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
  X_ROWID                        => l_rowid,
  X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
  X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
  X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
  X_REGION_CODE                  => X_REGION_CODE,
  X_PROPERTY_NAME                => 'IMPORT_FLAG',
  X_PROPERTY_VARCHAR2_VALUE      => X_IMPORT_FLAG,
  X_PROPERTY_NUMBER_VALUE        => NULL,
  X_CRITERIA_JOIN_CONDITION      => NULL,
  X_CREATED_BY                   => X_CREATED_BY,
  X_CREATION_DATE                => X_CREATION_DATE,
  X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
  X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
            );

          AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
  X_ROWID                        => l_rowid,
  X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
  X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
  X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
  X_REGION_CODE                  => X_REGION_CODE,
  X_PROPERTY_NAME                => 'DATA_LEVEL',
  X_PROPERTY_VARCHAR2_VALUE      => X_DATA_LEVEL,
  X_PROPERTY_NUMBER_VALUE        => NULL,
  X_CRITERIA_JOIN_CONDITION      => NULL,
  X_CREATED_BY                   => X_CREATED_BY,
  X_CREATION_DATE                => X_CREATION_DATE,
  X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
  X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
            );


      END IF;

  INSERT INTO EGO_CUSTOMIZATION_EXT
    (
  CUSTOMIZATION_APPLICATION_ID,
  CUSTOMIZATION_CODE,
  REGION_APPLICATION_ID,
  REGION_CODE,
  CLASSIFICATION1,
  CLASSIFICATION2,
  CLASSIFICATION3,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN
   )
    VALUES
    (
  X_CUSTOMIZATION_APPLICATION_ID,
  X_CUSTOMIZATION_CODE,
  X_REGION_APPLICATION_ID,
  X_REGION_CODE,
  X_CLASSIFICATION_1,
  X_CLASSIFICATION_2,
  X_CLASSIFICATION_3,
  g_current_user_id,
  l_Sysdate,
  g_current_user_id,
  l_Sysdate,
  g_current_user_id
    );

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE


      FND_MESSAGE.Set_Name(g_app_name, 'EGO_DUP_RESULTS_FORMAT');
      FND_MSG_PUB.Add;

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;


    END IF;

  END create_result_format;

---------------------------------------------------------

  PROCEDURE update_result_format
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_NAME                         IN     VARCHAR2,
     X_DESCRIPTION                  IN     VARCHAR2,
     X_NUM_ROWS_DISPLAYED           IN     NUMBER,
     X_DEFAULT_RESULT_FLAG          IN     VARCHAR2,
     X_SITE_ID                      IN     NUMBER,
     X_WEB_USER_ID                  IN     NUMBER,
     X_CUSTOMIZATION_LEVEL_ID       IN     NUMBER,
     X_IMPORT_FLAG                  IN     VARCHAR2 DEFAULT NULL,
     X_DATA_LEVEL		    IN	   VARCHAR2 DEFAULT NULL,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_CLASSIFICATION_1             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_2             IN     VARCHAR2 DEFAULT NULL,
     X_CLASSIFICATION_3             IN     VARCHAR2 DEFAULT NULL,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
 IS
    l_Sysdate                DATE := Sysdate;
    l_count                  NUMBER;
    l_rowid                  VARCHAR2(255);
    l_data_level             VARCHAR2(4000);

    CURSOR get_data_level IS
     select data_level_query.property_varchar2_value data_level
     from
     AK_CUSTOM_REGIONS_TL name_query ,
     AK_CUSTOM_REGIONS data_level_query
     where name_query.property_name = 'RESULT_NAME'
     and name_query.language = USERENV('LANG')
     and data_level_query.property_name (+) = 'DATA_LEVEL'
     and name_query.customization_application_id = data_level_query.customization_application_id(+)
     and name_query.customization_code = data_level_query.customization_code (+)
     and name_query.region_application_id = data_level_query.region_application_id(+)
     and name_query.region_code = data_level_query.region_code(+)
     and name_query.customization_code = x_customization_code
     and name_query.customization_application_id = x_customization_application_id
     and name_query.region_application_id = x_region_application_id
     and name_query.region_code = x_region_code;

 BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

    IF (Results_Format_Name_Exists(X_NAME
                                  ,X_WEB_USER_ID
                                  ,X_CUSTOMIZATION_CODE
                                  ,X_CUSTOMIZATION_APPLICATION_ID
                                  ,X_REGION_APPLICATION_ID
                                  ,X_REGION_CODE
                                  ,X_CUSTOMIZATION_LEVEL_ID
                                  ,X_CLASSIFICATION_1
                                  ,X_CLASSIFICATION_2
                                  ,X_CLASSIFICATION_3) = FALSE) THEN

        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'RESULT_NAME',
            X_PROPERTY_VARCHAR2_VALUE      => X_NAME,
            X_PROPERTY_NUMBER_VALUE        => NULL,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'RESULT_DESCRIPTION',
            X_PROPERTY_VARCHAR2_VALUE      => X_DESCRIPTION,
            X_PROPERTY_NUMBER_VALUE        => NULL,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

-- first thing updating other result format default flag if "Y" in this one

   IF( X_DEFAULT_RESULT_FLAG = 'Y') THEN

     FOR data_rec IN get_data_level LOOP
       l_data_level := data_rec.data_level;
       exit;
     END LOOP;

     Update_Result_Format_Default
     (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_WEB_USER_ID,
       X_CUSTOMIZATION_LEVEL_ID,
       X_IMPORT_FLAG,
       X_CLASSIFICATION_1,
       X_CLASSIFICATION_2,
       X_CLASSIFICATION_3,
       l_data_level
     );

   END IF;


        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'DEFAULT_RESULT_FLAG',
            X_PROPERTY_VARCHAR2_VALUE      => X_DEFAULT_RESULT_FLAG,
            X_PROPERTY_NUMBER_VALUE        => NULL,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'NUM_ROWS_DISPLAY',
            X_PROPERTY_VARCHAR2_VALUE      => NULL,
            X_PROPERTY_NUMBER_VALUE        => X_NUM_ROWS_DISPLAYED,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'SITE_ID',
            X_PROPERTY_VARCHAR2_VALUE      => NULL,
            X_PROPERTY_NUMBER_VALUE        => X_SITE_ID,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'WEB_USER_ID',
            X_PROPERTY_VARCHAR2_VALUE      => NULL,
            X_PROPERTY_NUMBER_VALUE        => X_WEB_USER_ID,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'CUSTOMIZATION_LEVEL_ID',
            X_PROPERTY_VARCHAR2_VALUE      => NULL,
            X_PROPERTY_NUMBER_VALUE        => X_CUSTOMIZATION_LEVEL_ID,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

    SELECT COUNT(*) INTO l_count
    FROM AK_CUSTOM_REGIONS
    WHERE
      CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
      AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
      AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
      AND REGION_CODE = X_REGION_CODE
      AND PROPERTY_NAME = 'IMPORT_FLAG';

    IF (l_count > 0) THEN

      IF (X_IMPORT_FLAG IS NULL) THEN
        DELETE FROM AK_CUSTOM_REGIONS
        WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND PROPERTY_NAME = 'IMPORT_FLAG';
      ELSE
        AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
          X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
          X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_PROPERTY_NAME                => 'IMPORT_FLAG',
          X_PROPERTY_VARCHAR2_VALUE      => X_IMPORT_FLAG,
          X_PROPERTY_NUMBER_VALUE        => NULL,
          X_CRITERIA_JOIN_CONDITION      => NULL,
          X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );
      END IF;

    ELSE

      IF (X_IMPORT_FLAG IS NOT NULL) THEN

        AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
            X_ROWID                        => l_rowid,
            X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
            X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
            X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
            X_REGION_CODE                  => X_REGION_CODE,
            X_PROPERTY_NAME                => 'IMPORT_FLAG',
            X_PROPERTY_VARCHAR2_VALUE      => X_IMPORT_FLAG,
            X_PROPERTY_NUMBER_VALUE        => NULL,
            X_CRITERIA_JOIN_CONDITION      => NULL,
            X_CREATED_BY                   => X_LAST_UPDATED_BY,
            X_CREATION_DATE                => X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
            );

      END IF;

    END IF;

    --Bug 6011948
    -- Update data level also if a value is supplied for it..

    IF (X_DATA_LEVEL IS NOT NULL) THEN

	    SELECT COUNT(*) INTO l_count
	    FROM AK_CUSTOM_REGIONS
	    WHERE
	      CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
	      AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
	      AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
	      AND REGION_CODE = X_REGION_CODE
	      AND PROPERTY_NAME = 'DATA_LEVEL';

	    IF (l_count > 0) THEN
		  AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
		  X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
		  X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
		  X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
		  X_REGION_CODE                  => X_REGION_CODE,
		  X_PROPERTY_NAME                => 'DATA_LEVEL',
		  X_PROPERTY_VARCHAR2_VALUE      => X_DATA_LEVEL,
		  X_PROPERTY_NUMBER_VALUE        => NULL,
		  X_CRITERIA_JOIN_CONDITION      => NULL,
		  X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
		  X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
		  X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
		  );

	    ELSE

		AK_CUSTOM_REGIONS_PKG.INSERT_ROW(
		    X_ROWID                        => l_rowid,
		    X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
		    X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
		    X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
		    X_REGION_CODE                  => X_REGION_CODE,
		    X_PROPERTY_NAME                => 'DATA_LEVEL',
		    X_PROPERTY_VARCHAR2_VALUE      => X_DATA_LEVEL,
		    X_PROPERTY_NUMBER_VALUE        => NULL,
		    X_CRITERIA_JOIN_CONDITION      => NULL,
		    X_CREATED_BY                   => X_LAST_UPDATED_BY,
		    X_CREATION_DATE                => X_LAST_UPDATE_DATE,
		    X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
		    X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
		    X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
		    );

	    END IF;
    END IF;







    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE

      FND_MESSAGE.Set_Name(g_app_name, 'EGO_DUP_RESULTS_FORMAT');
      FND_MSG_PUB.Add;

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    END IF;

END update_result_format;

-------------------------------------------------------------

 PROCEDURE delete_result_format
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  )
  IS

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

    Check_Result_Format_Deletion
     (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       FND_API.G_FALSE,
       X_RETURN_STATUS,
       X_ERRORCODE
     );

    IF (X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS) THEN

  DELETE FROM AK_CUSTOM_REGIONS
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE;

 DELETE FROM AK_CUSTOM_REGIONS_TL
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE;

  DELETE FROM EGO_CUSTOMIZATION_EXT
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE;

 DELETE FROM AK_CUSTOM_REGION_ITEMS
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE;

 DELETE FROM AK_CUSTOM_REGION_ITEMS_TL
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  ELSE

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  END IF;

  END delete_result_format;


  PROCEDURE translate_result_format
  (  p_customization_application_id  IN   NUMBER
    ,p_customization_code            IN   VARCHAR2
    ,p_region_application_id         IN   NUMBER
    ,p_region_code                   IN   VARCHAR2
    ,p_last_update_date              IN   VARCHAR2
    ,p_last_updated_by               IN   NUMBER
    ,p_name                          IN   VARCHAR2
    ,p_description                   IN   VARCHAR2
    ,x_return_status                 OUT  NOCOPY VARCHAR2
    ,x_msg_data                      OUT  NOCOPY VARCHAR2
  ) IS

    l_last_update_login     ak_customizations.last_update_login%TYPE;
    l_last_update_date      ak_customizations.last_update_date%TYPE;
    l_last_updated_by       ak_customizations.last_updated_by%TYPE;

  CURSOR c_get_last_update_info (cp_property_name IN VARCHAR2) IS
  SELECT last_updated_by, last_update_date
  FROM   ak_custom_regions_tl
  WHERE  customization_application_id = p_customization_application_id
    AND  customization_code      =  p_customization_code
    AND  region_application_id   =  p_region_application_id
    AND  region_code             =  p_region_code
    AND  property_name           =  cp_property_name
    AND  USERENV('LANG') IN (language, source_lang);

  BEGIN

    l_last_update_login := FND_GLOBAL.Login_Id;

    OPEN c_get_last_update_info (cp_property_name => 'RESULT_NAME');
    FETCH c_get_last_update_info
    INTO l_last_updated_by, l_last_update_date;
    CLOSE c_get_last_update_info;

    IF (fnd_load_util.upload_test(p_last_updated_by
                                 ,p_last_update_date
                                 ,l_last_updated_by
                                 ,l_last_update_date
                                 ,NULL)) THEN

      AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
          X_CUSTOMIZATION_APPLICATION_ID => p_customization_application_id,
          X_CUSTOMIZATION_CODE           => p_customization_code,
          X_REGION_APPLICATION_ID        => p_region_application_id,
          X_REGION_CODE                  => p_region_code,
          X_PROPERTY_NAME                => 'RESULT_NAME',
          X_PROPERTY_VARCHAR2_VALUE      => p_name,
          X_PROPERTY_NUMBER_VALUE        => NULL,
          X_CRITERIA_JOIN_CONDITION      => NULL,
          X_LAST_UPDATED_BY              => p_last_updated_by,
          X_LAST_UPDATE_DATE             => SYSDATE,
          X_LAST_UPDATE_LOGIN            => l_last_update_login
          );
    END IF;

    OPEN c_get_last_update_info (cp_property_name => 'RESULT_DESCRIPTION');
    FETCH c_get_last_update_info
    INTO l_last_updated_by, l_last_update_date;
    CLOSE c_get_last_update_info;

    IF (fnd_load_util.upload_test(p_last_updated_by
                                 ,p_last_update_date
                                 ,l_last_updated_by
                                 ,l_last_update_date
                                 ,NULL)) THEN
      AK_CUSTOM_REGIONS_PKG.UPDATE_ROW(
          X_CUSTOMIZATION_APPLICATION_ID => p_customization_application_id,
          X_CUSTOMIZATION_CODE           => p_customization_code,
          X_REGION_APPLICATION_ID        => p_region_application_id,
          X_REGION_CODE                  => p_region_code,
          X_PROPERTY_NAME                => 'RESULT_DESCRIPTION',
          X_PROPERTY_VARCHAR2_VALUE      => p_description,
          X_PROPERTY_NUMBER_VALUE        => NULL,
          X_CRITERIA_JOIN_CONDITION      => NULL,
          X_LAST_UPDATED_BY              => p_last_updated_by,
          X_LAST_UPDATE_DATE             => SYSDATE,
          X_LAST_UPDATE_LOGIN            => l_last_update_login
          );
    END IF;
    x_return_status  := 'S';
  EXCEPTION
    WHEN OTHERS THEN
     x_return_status  := 'E';
     x_msg_data       := SQLERRM;
  END translate_result_format;

---------------------------------------------------------


  PROCEDURE create_result_column
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_ORDER_SEQUENCE               IN     NUMBER,
     X_ORDER_DIRECTION              IN     VARCHAR2,
     X_COLUMN_NAME                  IN     VARCHAR2 := NULL,
     X_SHOW_TOTAL                   IN     VARCHAR2 := NULL,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

  AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
    X_ROWID                        => l_rowid,
    X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
    X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
    X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
    X_REGION_CODE                  => X_REGION_CODE,
    X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
    X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
    X_PROPERTY_NAME                => 'DISPLAY_SEQUENCE',
    X_PROPERTY_VARCHAR2_VALUE      => NULL,
    X_PROPERTY_NUMBER_VALUE        => X_DISPLAY_SEQUENCE,
    X_PROPERTY_DATE_VALUE          => NULL,
    X_CREATED_BY                   => X_CREATED_BY,
    X_CREATION_DATE                => X_CREATION_DATE,
    X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
  );

  IF (X_ORDER_SEQUENCE IS NOT NULL) THEN

    AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
      X_ROWID                        => l_rowid,
      X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
      X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
      X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
      X_REGION_CODE                  => X_REGION_CODE,
      X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
      X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
      X_PROPERTY_NAME                => 'ORDER_SEQUENCE',
      X_PROPERTY_VARCHAR2_VALUE      => NULL,
      X_PROPERTY_NUMBER_VALUE        => X_ORDER_SEQUENCE,
      X_PROPERTY_DATE_VALUE          => NULL,
      X_CREATED_BY                   => X_CREATED_BY,
      X_CREATION_DATE                => X_CREATION_DATE,
      X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
    );

  END IF;

  IF (X_ORDER_DIRECTION IS NOT NULL) THEN

   AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
      X_ROWID                        => l_rowid,
      X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
      X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
      X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
      X_REGION_CODE                  => X_REGION_CODE,
      X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
      X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
      X_PROPERTY_NAME                => 'ORDER_DIRECTION',
      X_PROPERTY_VARCHAR2_VALUE      => X_ORDER_DIRECTION,
      X_PROPERTY_NUMBER_VALUE        => NULL,
      X_PROPERTY_DATE_VALUE          => NULL,
      X_CREATED_BY                   => X_CREATED_BY,
      X_CREATION_DATE                => X_CREATION_DATE,
      X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
    );
  END IF;

  IF (X_COLUMN_NAME IS NOT NULL) THEN

   AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
      X_ROWID                        => l_rowid,
      X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
      X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
      X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
      X_REGION_CODE                  => X_REGION_CODE,
      X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
      X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
      X_PROPERTY_NAME                => 'COLUMN_NAME',
      X_PROPERTY_VARCHAR2_VALUE      => X_COLUMN_NAME,
      X_PROPERTY_NUMBER_VALUE        => NULL,
      X_PROPERTY_DATE_VALUE          => NULL,
      X_CREATED_BY                   => X_CREATED_BY,
      X_CREATION_DATE                => X_CREATION_DATE,
      X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
    );
  END IF;

  IF (X_SHOW_TOTAL IS NOT NULL) THEN

   AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
      X_ROWID                        => l_rowid,
      X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
      X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
      X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
      X_REGION_CODE                  => X_REGION_CODE,
      X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
      X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
      X_PROPERTY_NAME                => 'SHOW_TOTAL',
      X_PROPERTY_VARCHAR2_VALUE      => X_SHOW_TOTAL,
      X_PROPERTY_NUMBER_VALUE        => NULL,
      X_PROPERTY_DATE_VALUE          => NULL,
      X_CREATED_BY                   => X_CREATED_BY,
      X_CREATION_DATE                => X_CREATION_DATE,
      X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
    );
  END IF;

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END create_result_column;


---------------------------------------------------------


  PROCEDURE update_result_column
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_ORDER_SEQUENCE               IN     NUMBER,
     X_ORDER_DIRECTION              IN     VARCHAR2,
     X_COLUMN_NAME                  IN     VARCHAR2 := NULL,
     X_SHOW_TOTAL                   IN     VARCHAR2 := NULL,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);
  l_count                  NUMBER;

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

   AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW(
     X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
     X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
     X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
     X_REGION_CODE                  => X_REGION_CODE,
     X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
     X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
     X_PROPERTY_NAME                => 'DISPLAY_SEQUENCE',
     X_PROPERTY_VARCHAR2_VALUE      => NULL,
     X_PROPERTY_NUMBER_VALUE        => X_DISPLAY_SEQUENCE,
     X_PROPERTY_DATE_VALUE          => NULL,
     X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
     X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
     X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
   );

  SELECT
    COUNT(*) INTO l_count
  FROM
    AK_CUSTOM_REGION_ITEMS
  WHERE
    CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
    AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    AND PROPERTY_NAME = 'ORDER_SEQUENCE';

  IF (X_ORDER_SEQUENCE IS NULL) THEN

    IF (l_count > 0) THEN
      DELETE FROM AK_CUSTOM_REGION_ITEMS
        WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
        AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
        AND PROPERTY_NAME = 'ORDER_SEQUENCE';
    END IF;

  ELSE

    IF (l_count > 0) THEN

      AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW(
        X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
        X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
        X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
        X_REGION_CODE                  => X_REGION_CODE,
        X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
        X_PROPERTY_NAME                => 'ORDER_SEQUENCE',
        X_PROPERTY_VARCHAR2_VALUE      => NULL,
        X_PROPERTY_NUMBER_VALUE        => X_ORDER_SEQUENCE,
        X_PROPERTY_DATE_VALUE          => NULL,
        X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
      );

    ELSE

       AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
          X_ROWID                        => l_rowid,
          X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
          X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
          X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
          X_PROPERTY_NAME                => 'ORDER_SEQUENCE',
          X_PROPERTY_VARCHAR2_VALUE      => NULL,
          X_PROPERTY_NUMBER_VALUE        => X_ORDER_SEQUENCE,
          X_PROPERTY_DATE_VALUE          => NULL,
          X_CREATED_BY                   => X_LAST_UPDATED_BY,
          X_CREATION_DATE                => SYSDATE,
          X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
        );

    END IF;

  END IF;


  SELECT
    COUNT(*) INTO l_count
  FROM
    AK_CUSTOM_REGION_ITEMS
  WHERE
    CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
    AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    AND PROPERTY_NAME = 'ORDER_DIRECTION';

  IF (X_ORDER_DIRECTION IS NULL) THEN

    IF (l_count > 0) THEN
      DELETE FROM AK_CUSTOM_REGION_ITEMS
        WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
        AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
        AND PROPERTY_NAME = 'ORDER_DIRECTION';
    END IF;

  ELSE

    IF (l_count > 0) THEN

      AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW(
        X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
        X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
        X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
        X_REGION_CODE                  => X_REGION_CODE,
        X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
        X_PROPERTY_NAME                => 'ORDER_DIRECTION',
        X_PROPERTY_VARCHAR2_VALUE      => X_ORDER_DIRECTION,
        X_PROPERTY_NUMBER_VALUE        => NULL,
        X_PROPERTY_DATE_VALUE          => NULL,
        X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
      );

    ELSE

       AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
          X_ROWID                        => l_rowid,
          X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
          X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
          X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
          X_PROPERTY_NAME                => 'ORDER_DIRECTION',
          X_PROPERTY_VARCHAR2_VALUE      => X_ORDER_DIRECTION,
          X_PROPERTY_NUMBER_VALUE        => NULL,
          X_PROPERTY_DATE_VALUE          => NULL,
          X_CREATED_BY                   => X_LAST_UPDATED_BY,
          X_CREATION_DATE                => SYSDATE,
          X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
        );

    END IF;

  END IF;

  SELECT
    COUNT(*) INTO l_count
  FROM
    AK_CUSTOM_REGION_ITEMS
  WHERE
    CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
    AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    AND PROPERTY_NAME = 'COLUMN_NAME';

  IF (X_COLUMN_NAME IS NULL) THEN

    IF (l_count > 0) THEN
      DELETE FROM AK_CUSTOM_REGION_ITEMS
        WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
        AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
        AND PROPERTY_NAME = 'COLUMN_NAME';
    END IF;

  ELSE

    IF (l_count > 0) THEN

      AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW(
        X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
        X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
        X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
        X_REGION_CODE                  => X_REGION_CODE,
        X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
        X_PROPERTY_NAME                => 'COLUMN_NAME',
        X_PROPERTY_VARCHAR2_VALUE      => X_COLUMN_NAME,
        X_PROPERTY_NUMBER_VALUE        => NULL,
        X_PROPERTY_DATE_VALUE          => NULL,
        X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
      );

    ELSE

       AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
          X_ROWID                        => l_rowid,
          X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
          X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
          X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
          X_PROPERTY_NAME                => 'COLUMN_NAME',
          X_PROPERTY_VARCHAR2_VALUE      => X_COLUMN_NAME,
          X_PROPERTY_NUMBER_VALUE        => NULL,
          X_PROPERTY_DATE_VALUE          => NULL,
          X_CREATED_BY                   => X_LAST_UPDATED_BY,
          X_CREATION_DATE                => SYSDATE,
          X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
        );

    END IF;

  END IF;

  SELECT
    COUNT(*) INTO l_count
  FROM
    AK_CUSTOM_REGION_ITEMS
  WHERE
    CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
    AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    AND PROPERTY_NAME = 'SHOW_TOTAL';

  IF (X_SHOW_TOTAL IS NULL) THEN

    IF (l_count > 0) THEN
      DELETE FROM AK_CUSTOM_REGION_ITEMS
        WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
        AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
        AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
        AND REGION_CODE = X_REGION_CODE
        AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
        AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
        AND PROPERTY_NAME = 'SHOW_TOTAL';
    END IF;

  ELSE

    IF (l_count > 0) THEN

      AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW(
        X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
        X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
        X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
        X_REGION_CODE                  => X_REGION_CODE,
        X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
        X_PROPERTY_NAME                => 'SHOW_TOTAL',
        X_PROPERTY_VARCHAR2_VALUE      => X_SHOW_TOTAL,
        X_PROPERTY_NUMBER_VALUE        => NULL,
        X_PROPERTY_DATE_VALUE          => NULL,
        X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
      );

    ELSE

       AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
          X_ROWID                        => l_rowid,
          X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
          X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
          X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
          X_PROPERTY_NAME                => 'SHOW_TOTAL',
          X_PROPERTY_VARCHAR2_VALUE      => X_SHOW_TOTAL,
          X_PROPERTY_NUMBER_VALUE        => NULL,
          X_PROPERTY_DATE_VALUE          => NULL,
          X_CREATED_BY                   => X_LAST_UPDATED_BY,
          X_CREATION_DATE                => SYSDATE,
          X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
          X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
        );

    END IF;

  END IF;


--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END update_result_column;

-------------------------------------------------------------

 PROCEDURE delete_result_column
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  )
  IS

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

 DELETE FROM AK_CUSTOM_REGION_ITEMS
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE
  AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
  AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;

 DELETE FROM AK_CUSTOM_REGION_ITEMS_TL
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE
  AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
  AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END delete_result_column;
---------------------------------------------------------

 PROCEDURE insert_criterion
  (
     X_ROWID                        IN OUT NOCOPY VARCHAR2,
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_SEQUENCE_NUMBER              IN     NUMBER,
     X_OPERATION                    IN     VARCHAR2,
     X_VALUE_VARCHAR2               IN     VARCHAR2,
     X_SECOND_VALUE_VARCHAR2        IN     VARCHAR2,
     X_VALUE_NUMBER                 IN     NUMBER,
     X_SECOND_VALUE_NUMBER          IN     NUMBER,
     X_VALUE_DATE                   IN     DATE,
     X_SECOND_VALUE_DATE            IN     DATE,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_START_DATE_ACTIVE            IN     DATE,
     X_END_DATE_ACTIVE              IN     DATE,
     X_USE_KEYWORD_SEARCH           IN     VARCHAR2 := 'Y',
     X_MATCH_CONDITION              IN     VARCHAR2 := 'ALL',
     X_FUZZY                        IN     VARCHAR2 := 'N',
     X_STEMMING                     IN     VARCHAR2 := 'N',
     X_SYNONYMS                     IN     VARCHAR2 := 'N',
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE
  )
  IS

  BEGIN

    IF FND_API.To_Boolean(x_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
    END IF;

    AK_CRITERIA_PKG.insert_row
    (
       X_ROWID,
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_ATTRIBUTE_APPLICATION_ID,
       X_ATTRIBUTE_CODE,
       X_SEQUENCE_NUMBER,
       X_OPERATION,
       X_VALUE_VARCHAR2,
       X_VALUE_NUMBER,
       X_VALUE_DATE,
       X_CREATED_BY,
       X_CREATION_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATE_LOGIN,
       X_START_DATE_ACTIVE,
       X_END_DATE_ACTIVE
    );

  -- Now we see if we need to insert another (for between operators)
  IF (X_SECOND_VALUE_NUMBER IS NOT NULL OR X_SECOND_VALUE_DATE IS NOT NULL OR X_SECOND_VALUE_VARCHAR2 IS NOT NULL) THEN
    AK_CRITERIA_PKG.insert_row
    (
       X_ROWID,
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_ATTRIBUTE_APPLICATION_ID,
       X_ATTRIBUTE_CODE,
       -1*X_SEQUENCE_NUMBER,
       X_OPERATION,
       X_SECOND_VALUE_VARCHAR2,
       X_SECOND_VALUE_NUMBER,
       X_SECOND_VALUE_DATE,
       X_CREATED_BY,
       X_CREATION_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATE_LOGIN,
       X_START_DATE_ACTIVE,
       X_END_DATE_ACTIVE
    );
  END IF;

    -- Matching
    INSERT INTO EGO_CRITERIA_EXT
     (
       CUSTOMIZATION_APPLICATION_ID,
       CUSTOMIZATION_CODE,
       REGION_APPLICATION_ID,
       REGION_CODE,
       ATTRIBUTE_APPLICATION_ID,
       ATTRIBUTE_CODE,
       SEQUENCE_NUMBER,
       USE_KEYWORD_SEARCH,
       MATCH_CONDITION,
       FUZZY,
       STEMMING,
       SYNONYMS,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATED_DATE,
       LAST_UPDATE_LOGIN
     )
    VALUES
     (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_ATTRIBUTE_APPLICATION_ID,
       X_ATTRIBUTE_CODE,
       X_SEQUENCE_NUMBER,
       X_USE_KEYWORD_SEARCH,
       X_MATCH_CONDITION,
       X_FUZZY,
       X_STEMMING,
       X_SYNONYMS,
       X_CREATED_BY,
       X_CREATION_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATE_LOGIN
      );
    -- Matching

  END insert_criterion;

  PROCEDURE update_criterion
  (
     X_ROWID                        IN OUT NOCOPY VARCHAR2,
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_SEQUENCE_NUMBER              IN NUMBER,
     X_OPERATION                    IN VARCHAR2,
     X_VALUE_VARCHAR2               IN VARCHAR2,
     X_SECOND_VALUE_VARCHAR2        IN VARCHAR2,
     X_VALUE_NUMBER                 IN NUMBER,
     X_SECOND_VALUE_NUMBER          IN NUMBER,
     X_VALUE_DATE                   IN DATE,
     X_SECOND_VALUE_DATE            IN DATE,
     X_LAST_UPDATED_BY              IN NUMBER,
     X_LAST_UPDATE_DATE             IN DATE,
     X_LAST_UPDATE_LOGIN            IN NUMBER,
     X_START_DATE_ACTIVE            IN DATE,
     X_END_DATE_ACTIVE              IN DATE,
     X_USE_KEYWORD_SEARCH           IN     VARCHAR2 := 'Y',
     X_MATCH_CONDITION              IN     VARCHAR2 := 'ALL',
     X_FUZZY                        IN     VARCHAR2 := 'N',
     X_STEMMING                     IN     VARCHAR2 := 'N',
     X_SYNONYMS                     IN     VARCHAR2 := 'N',
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE
  )
  IS

  l_count        NUMBER;

  BEGIN

    IF FND_API.To_Boolean(x_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    AK_CRITERIA_PKG.update_row
    (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_ATTRIBUTE_APPLICATION_ID,
       X_ATTRIBUTE_CODE,
       X_SEQUENCE_NUMBER,
       X_OPERATION,
       X_VALUE_VARCHAR2,
       X_VALUE_NUMBER,
       X_VALUE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATE_LOGIN,
       X_START_DATE_ACTIVE,
       X_END_DATE_ACTIVE
    );

  --See if we need to update, delete, or insert a second row

  SELECT
    COUNT(*) INTO l_count
  FROM
    AK_CRITERIA
  WHERE
    CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
    AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
    AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
    AND REGION_CODE = X_REGION_CODE
    AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
    AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
    AND SEQUENCE_NUMBER = -1*X_SEQUENCE_NUMBER;

  IF (X_SECOND_VALUE_NUMBER IS NOT NULL OR X_SECOND_VALUE_DATE IS NOT NULL OR X_SECOND_VALUE_VARCHAR2 IS NOT NULL) THEN
    --We either need to insert or update a row
    BEGIN

      IF (l_count = 0) THEN

        AK_CRITERIA_PKG.insert_row
        (
           X_ROWID,
           X_CUSTOMIZATION_APPLICATION_ID,
           X_CUSTOMIZATION_CODE,
           X_REGION_APPLICATION_ID,
           X_REGION_CODE,
           X_ATTRIBUTE_APPLICATION_ID,
           X_ATTRIBUTE_CODE,
           -1*X_SEQUENCE_NUMBER,
           X_OPERATION,
           X_SECOND_VALUE_VARCHAR2,
           X_SECOND_VALUE_NUMBER,
           X_SECOND_VALUE_DATE,
           X_LAST_UPDATED_BY,
           X_LAST_UPDATE_DATE,
           X_LAST_UPDATED_BY,
           X_LAST_UPDATE_DATE,
           X_LAST_UPDATE_LOGIN,
           X_START_DATE_ACTIVE,
           X_END_DATE_ACTIVE
        );

      ELSE

        UPDATE
          AK_CRITERIA
        SET
          VALUE_VARCHAR2 = X_SECOND_VALUE_VARCHAR2,
          VALUE_NUMBER = X_SECOND_VALUE_NUMBER,
          VALUE_DATE = X_SECOND_VALUE_DATE
        WHERE
          CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
          AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
          AND SEQUENCE_NUMBER = -1*X_SEQUENCE_NUMBER;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  ELSE

    --We may need to delete a row
    BEGIN

      IF (l_count > 0) THEN

        DELETE FROM
          AK_CRITERIA
        WHERE
          CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
          AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
          AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
          AND REGION_CODE = X_REGION_CODE
          AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
          AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
          AND SEQUENCE_NUMBER = -1*X_SEQUENCE_NUMBER;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;

  END IF;
-- Matching
  UPDATE
    EGO_CRITERIA_EXT
  SET
    USE_KEYWORD_SEARCH = X_USE_KEYWORD_SEARCH,
    MATCH_CONDITION    = X_MATCH_CONDITION,
    FUZZY              = X_FUZZY,
    STEMMING           = X_STEMMING,
    SYNONYMS           = X_SYNONYMS
  WHERE
    CUSTOMIZATION_APPLICATION_ID  = X_CUSTOMIZATION_APPLICATION_ID AND
    CUSTOMIZATION_CODE            = X_CUSTOMIZATION_CODE AND
    REGION_APPLICATION_ID         = X_REGION_APPLICATION_ID AND
    REGION_CODE                   = X_REGION_CODE AND
    ATTRIBUTE_APPLICATION_ID      = X_ATTRIBUTE_APPLICATION_ID AND
    ATTRIBUTE_CODE                = X_ATTRIBUTE_CODE AND
    SEQUENCE_NUMBER               = X_SEQUENCE_NUMBER;
-- Matching
  IF(SQL%ROWCOUNT = 0)
  THEN
    INSERT INTO EGO_CRITERIA_EXT
    (
       CUSTOMIZATION_APPLICATION_ID,
       CUSTOMIZATION_CODE,
       REGION_APPLICATION_ID,
       REGION_CODE,
       ATTRIBUTE_APPLICATION_ID,
       ATTRIBUTE_CODE,
       SEQUENCE_NUMBER,
       USE_KEYWORD_SEARCH,
       MATCH_CONDITION,
       FUZZY,
       STEMMING,
       SYNONYMS,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATED_DATE,
       LAST_UPDATE_LOGIN
     )
    VALUES
     (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_ATTRIBUTE_APPLICATION_ID,
       X_ATTRIBUTE_CODE,
       X_SEQUENCE_NUMBER,
       X_USE_KEYWORD_SEARCH,
       X_MATCH_CONDITION,
       X_FUZZY,
       X_STEMMING,
       X_SYNONYMS,
       X_LAST_UPDATED_BY,  -- X_CREATED_BY,
       X_LAST_UPDATE_DATE, -- X_CREATION_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATE_LOGIN
      );
  END IF;
END update_criterion;

  PROCEDURE delete_criterion
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_SEQUENCE_NUMBER              IN NUMBER,
     X_INIT_MSG_LIST                IN VARCHAR2   := FND_API.G_FALSE
  )
  IS

  l_count  NUMBER;

  BEGIN

    IF FND_API.To_Boolean(x_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
    END IF;

    AK_CRITERIA_PKG.delete_row
    (
       X_CUSTOMIZATION_APPLICATION_ID,
       X_CUSTOMIZATION_CODE,
       X_REGION_APPLICATION_ID,
       X_REGION_CODE,
       X_ATTRIBUTE_APPLICATION_ID,
       X_ATTRIBUTE_CODE,
       X_SEQUENCE_NUMBER
    );

    SELECT
      COUNT(*) INTO l_count
    FROM
      AK_CRITERIA
    WHERE
      CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
      AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
      AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
      AND REGION_CODE = X_REGION_CODE
      AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
      AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
      AND SEQUENCE_NUMBER = -1*X_SEQUENCE_NUMBER;

    IF (l_count > 0) THEN
      AK_CRITERIA_PKG.delete_row
      (
         X_CUSTOMIZATION_APPLICATION_ID,
         X_CUSTOMIZATION_CODE,
         X_REGION_APPLICATION_ID,
         X_REGION_CODE,
         X_ATTRIBUTE_APPLICATION_ID,
         X_ATTRIBUTE_CODE,
         -1*X_SEQUENCE_NUMBER
      );

    END IF;
  -- Matching
  DELETE
    EGO_CRITERIA_EXT
  WHERE
    CUSTOMIZATION_APPLICATION_ID  = X_CUSTOMIZATION_APPLICATION_ID AND
    CUSTOMIZATION_CODE            = X_CUSTOMIZATION_CODE AND
    REGION_APPLICATION_ID         = X_REGION_APPLICATION_ID AND
    REGION_CODE                   = X_REGION_CODE AND
    ATTRIBUTE_APPLICATION_ID      = X_ATTRIBUTE_APPLICATION_ID AND
    ATTRIBUTE_CODE                = X_ATTRIBUTE_CODE AND
    SEQUENCE_NUMBER               = X_SEQUENCE_NUMBER;
  -- Matching
  -- No issues even if the row is not there
  END delete_criterion;

  PROCEDURE create_result_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_CREATED_BY                   IN     NUMBER,
     X_CREATION_DATE                IN     DATE,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

         AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW(
X_ROWID                        => l_rowid,
X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
X_REGION_CODE                  => X_REGION_CODE,
X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
X_PROPERTY_NAME                => 'SECTION_SEQUENCE',
X_PROPERTY_VARCHAR2_VALUE      => NULL,
X_PROPERTY_NUMBER_VALUE        => X_DISPLAY_SEQUENCE,
X_PROPERTY_DATE_VALUE          => NULL,
X_CREATED_BY                   => X_CREATED_BY,
X_CREATION_DATE                => X_CREATION_DATE,
X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END create_result_section;


---------------------------------------------------------


  PROCEDURE update_result_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN     NUMBER,
     X_CUSTOMIZATION_CODE           IN     VARCHAR2,
     X_REGION_APPLICATION_ID        IN     NUMBER,
     X_REGION_CODE                  IN     VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN     NUMBER,
     X_ATTRIBUTE_CODE               IN     VARCHAR2,
     X_DISPLAY_SEQUENCE             IN     NUMBER,
     X_LAST_UPDATED_BY              IN     NUMBER,
     X_LAST_UPDATE_DATE             IN     DATE,
     X_LAST_UPDATE_LOGIN            IN     NUMBER,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT    NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT    NOCOPY NUMBER
  )
IS

  l_Sysdate                DATE := Sysdate;
  l_rowid                  VARCHAR2(255);

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

  AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW(
    X_CUSTOMIZATION_APPLICATION_ID => X_CUSTOMIZATION_APPLICATION_ID,
    X_CUSTOMIZATION_CODE           => X_CUSTOMIZATION_CODE,
    X_REGION_APPLICATION_ID        => X_REGION_APPLICATION_ID,
    X_REGION_CODE                  => X_REGION_CODE,
    X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
    X_ATTRIBUTE_CODE               => X_ATTRIBUTE_CODE,
    X_PROPERTY_NAME                => 'SECTION_SEQUENCE',
    X_PROPERTY_VARCHAR2_VALUE      => NULL,
    X_PROPERTY_NUMBER_VALUE        => X_DISPLAY_SEQUENCE,
    X_PROPERTY_DATE_VALUE          => NULL,
    X_LAST_UPDATED_BY              => X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE             => X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN
          );

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END update_result_section;

-------------------------------------------------------------

 PROCEDURE delete_result_section
  (
     X_CUSTOMIZATION_APPLICATION_ID IN NUMBER,
     X_CUSTOMIZATION_CODE           IN VARCHAR2,
     X_REGION_APPLICATION_ID        IN NUMBER,
     X_REGION_CODE                  IN VARCHAR2,
     X_ATTRIBUTE_APPLICATION_ID     IN NUMBER,
     X_ATTRIBUTE_CODE               IN VARCHAR2,
     X_INIT_MSG_LIST                IN     VARCHAR2   := FND_API.G_FALSE,
     X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
     X_ERRORCODE                    OUT NOCOPY NUMBER
  )
  IS

  BEGIN

  IF FND_API.To_Boolean(x_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

 DELETE FROM AK_CUSTOM_REGION_ITEMS
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE
  AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
  AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;

 DELETE FROM AK_CUSTOM_REGION_ITEMS_TL
  WHERE CUSTOMIZATION_APPLICATION_ID = X_CUSTOMIZATION_APPLICATION_ID
  AND CUSTOMIZATION_CODE = X_CUSTOMIZATION_CODE
  AND REGION_APPLICATION_ID = X_REGION_APPLICATION_ID
  AND REGION_CODE = X_REGION_CODE
  AND ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
  AND ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;

--  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_RETURN_STATUS := 'T';


  END delete_result_section;
---------------------------------------------------------

END EGO_SEARCH_FWK_PUB;

/
