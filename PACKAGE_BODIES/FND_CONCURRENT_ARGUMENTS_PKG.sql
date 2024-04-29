--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT_ARGUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT_ARGUMENTS_PKG" as
/* $Header: AFCPPCPB.pls 115.0 2003/10/04 07:29:28 aranjeet noship $ */


procedure INSERT_ROW (
  X_ROWID in out nocopy              VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION     in VARCHAR2,
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2,
  X_END_USER_COLUMN_NAME          in VARCHAR2,
  X_LAST_UPDATE_DATE              in DATE,
  X_LAST_UPDATED_BY               in NUMBER,
  X_CREATION_DATE                 in DATE,
  X_CREATED_BY                    in NUMBER,
  X_LAST_UPDATE_LOGIN             in NUMBER,
  X_COLUMN_SEQ_NUM                in NUMBER,
  X_ENABLED_FLAG                  in VARCHAR2,
  X_REQUIRED_FLAG                 in VARCHAR2,
  X_SECURITY_ENABLED_FLAG         in VARCHAR2,
  X_DISPLAY_FLAG                  in VARCHAR2,
  X_DISPLAY_SIZE                  in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN       in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE  in NUMBER,
  X_FLEX_VALUE_SET_ID             in NUMBER,
  X_RANGE_CODE                    in VARCHAR2,
  X_DEFAULT_TYPE                  in VARCHAR2,
  X_DEFAULT_VALUE                 in VARCHAR2,
  X_SRW_PARAM                     in VARCHAR2,
  X_FORM_LEFT_PROMPT              in VARCHAR2,
  X_FORM_ABOVE_PROMPT             in VARCHAR2,
  X_DESCRIPTION                   in VARCHAR2
) IS
    LANG VARCHAR2(30);
    CURSOR C IS SELECT rowid FROM fnd_descr_flex_column_usages
                 WHERE application_id = X_APPLICATION_ID
                 AND   descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME
                 AND   descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD
                 AND   application_column_name = X_APPLICATION_COLUMN_NAME;
   BEGIN

       INSERT INTO fnd_descr_flex_column_usages(
              application_id,
              descriptive_flexfield_name,
              descriptive_flex_context_code,
              application_column_name,
              end_user_column_name,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              column_seq_num,
              enabled_flag,
              required_flag,
              security_enabled_flag,
              display_flag,
              display_size,
              maximum_description_len,
              concatenation_description_len,
              flex_value_set_id,
              range_code,
              default_type,
              default_value,
              srw_param
             ) VALUES (
              X_APPLICATION_ID,
              X_DESCRIPTIVE_FLEXFIELD_NAME,
              X_DESCRIPTIVE_FLEX_CONTEXT_COD,
              X_APPLICATION_COLUMN_NAME,
              X_END_USER_COLUMN_NAME,
              X_LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY,
              X_CREATION_DATE,
              X_CREATED_BY,
              X_LAST_UPDATE_LOGIN,
              X_COLUMN_SEQ_NUM,
              X_ENABLED_FLAG,
              X_REQUIRED_FLAG,
              X_SECURITY_ENABLED_FLAG,
              X_DISPLAY_FLAG,
              X_DISPLAY_SIZE,
              X_MAXIMUM_DESCRIPTION_LEN,
              X_CONCATENATION_DESCRIPTION_LE,
              X_FLEX_VALUE_SET_ID,
              X_RANGE_CODE,
              X_DEFAULT_TYPE,
              X_DEFAULT_VALUE,
              X_SRW_PARAM
             );

    OPEN C;
    FETCH C INTO X_ROWID;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  --
  -- Insert translated columns in _TL table.
  --

      INSERT INTO fnd_descr_flex_col_usage_TL
      (
        application_id,
        descriptive_flexfield_name,
        descriptive_flex_context_code,
        language,
        application_column_name,
        form_left_prompt,
        form_above_prompt,
        description,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        source_lang
      ) SELECT
        X_APPLICATION_ID,
        X_DESCRIPTIVE_FLEXFIELD_NAME,
        X_DESCRIPTIVE_FLEX_CONTEXT_COD,
        L.LANGUAGE_CODE,
        X_APPLICATION_COLUMN_NAME,
        X_FORM_LEFT_PROMPT,
        X_FORM_ABOVE_PROMPT,
        X_DESCRIPTION,
        X_CREATED_BY,
        X_CREATION_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATE_LOGIN,
        userenv('LANG')
      FROM FND_LANGUAGES L
      WHERE L.installed_flag in ('I', 'B')
        AND not exists
          (SELECT NULL
           FROM fnd_descr_flex_col_usage_TL T
           WHERE T.application_id = X_APPLICATION_ID
           AND T.descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME
           AND T.descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD
           AND T.application_column_name = X_APPLICATION_COLUMN_NAME
           AND T.language = L.language_code);

  END Insert_Row;



procedure LOCK_ROW (
  X_RUNTIME_PROPERTY_FUNCTION     in VARCHAR2,
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2,
  X_END_USER_COLUMN_NAME          in VARCHAR2,
  X_COLUMN_SEQ_NUM                in NUMBER,
  X_ENABLED_FLAG                  in VARCHAR2,
  X_REQUIRED_FLAG                 in VARCHAR2,
  X_SECURITY_ENABLED_FLAG         in VARCHAR2,
  X_DISPLAY_FLAG                  in VARCHAR2,
  X_DISPLAY_SIZE                  in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN       in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE  in NUMBER,
  X_FLEX_VALUE_SET_ID             in NUMBER,
  X_RANGE_CODE                    in VARCHAR2,
  X_DEFAULT_TYPE                  in VARCHAR2,
  X_DEFAULT_VALUE                 in VARCHAR2,
  X_SRW_PARAM                     in VARCHAR2,
  X_FORM_LEFT_PROMPT              in VARCHAR2,
  X_FORM_ABOVE_PROMPT             in VARCHAR2,
  X_DESCRIPTION                   in VARCHAR2
) IS
    Counter NUMBER;
    CURSOR C IS
        SELECT
          application_id,
          descriptive_flexfield_name,
          descriptive_flex_context_code,
          application_column_name,
          end_user_column_name,
          column_seq_num,
          enabled_flag,
          required_flag,
          security_enabled_flag,
          display_flag,
          display_size,
          maximum_description_len,
          concatenation_description_len,
          flex_value_set_id,
          range_code,
          default_type,
          default_value,
          srw_param
        FROM fnd_descr_flex_column_usages
        WHERE APPLICATION_ID = X_APPLICATION_ID AND
          DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME AND
          descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD AND
          application_column_name = X_APPLICATION_COLUMN_NAME
        FOR UPDATE of Application_Id NOWAIT;

    Recinfo C%ROWTYPE;
    CURSOR C1 IS
      SELECT application_column_name, form_left_prompt,
        form_above_prompt, description
      FROM fnd_descr_flex_col_usage_TL
      WHERE application_id = X_APPLICATION_ID
        AND descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME
        AND descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD
        AND application_column_name = X_APPLICATION_COLUMN_NAME
        AND language = userenv('LANG')
      FOR UPDATE of application_id NOWAIT;
    Tlinfo C1%ROWTYPE;
  BEGIN
    Counter := 0;
    LOOP
      BEGIN
        Counter := Counter + 1;
        OPEN C;
        FETCH C INTO Recinfo;
        if (C%NOTFOUND) then
          CLOSE C;
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
          app_exception.raise_exception;
        end if;
        CLOSE C;
        if (
               (Recinfo.application_id = X_APPLICATION_ID)
           AND (Recinfo.descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME)
           AND (Recinfo.descriptive_flex_context_code =  X_DESCRIPTIVE_FLEX_CONTEXT_COD)
           AND (Recinfo.application_column_name = X_APPLICATION_COLUMN_NAME)
           AND (Recinfo.end_user_column_name = X_END_USER_COLUMN_NAME)
           AND (Recinfo.column_seq_num = X_COLUMN_SEQ_NUM)
           AND (Recinfo.enabled_flag = X_ENABLED_FLAG)
           AND (Recinfo.required_flag = X_REQUIRED_FLAG)
           AND (Recinfo.security_enabled_flag = X_SECURITY_ENABLED_FLAG)
           AND (Recinfo.display_flag =  X_DISPLAY_FLAG)
           AND (Recinfo.display_size = X_DISPLAY_SIZE)
           AND (Recinfo.maximum_description_len = X_MAXIMUM_DESCRIPTION_LEN)
           AND (Recinfo.concatenation_description_len = X_CONCATENATION_DESCRIPTION_LE)
           AND (   (Recinfo.flex_value_set_id = X_FLEX_VALUE_SET_ID)
                OR ( (Recinfo.flex_value_set_id IS NULL)
                    AND (X_FLEX_VALUE_SET_ID IS NULL)))
           AND (   (Recinfo.range_code =  X_RANGE_CODE)
                OR (    (Recinfo.range_code IS NULL)
                    AND (X_RANGE_CODE IS NULL)))
           AND (   (Recinfo.default_type =  X_DEFAULT_TYPE)
                OR (    (Recinfo.default_type IS NULL)
                    AND (X_DEFAULT_TYPE IS NULL)))
           AND (   (Recinfo.default_value =  X_DEFAULT_VALUE)
                OR (    (Recinfo.default_value IS NULL)
                    AND (X_DEFAULT_VALUE IS NULL)))
           AND (   (Recinfo.srw_param =  X_SRW_PARAM)
                OR (    (Recinfo.srw_param IS NULL)
                    AND (X_SRW_PARAM IS NULL)))
        ) then
          null;
        else
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
          app_exception.raise_exception;
        end if;

--
-- Check translated columns in _TL table
--
        OPEN C1;
        FETCH C1 INTO Tlinfo;
        if (C1%NOTFOUND) then
            CLOSE C1;
            RETURN;
        end if;
        CLOSE C1;

        if (
            (Tlinfo.form_left_prompt =  X_FORM_LEFT_PROMPT)
           AND (Tlinfo.form_above_prompt =  X_FORM_ABOVE_PROMPT)
           AND (   (Tlinfo.description =  X_DESCRIPTION)
                OR (    (TLinfo.description IS NULL)
                    AND (X_DESCRIPTION IS NULL)))
            ) then
          null;
        else
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
----          FND_MESSAGE.Set_Name('FND', 'ST:'||Tlinfo.form_left_prompt ||':'||X_FORM_LEFT_PROMPT||':'||Tlinfo.description||':'||X_DESCRIPTION||':'||Tlinfo.form_above_prompt||':'||X_FORM_ABOVE_PROMPT||':END');
          app_exception.raise_exception;
        end if;
        return;


      EXCEPTION
        When APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION then
          if (c%isopen) then
            close c;
          end if;
          if (c1%isopen) then
            close c1;
          end if;
      END;
    end LOOP;
  END Lock_Row;



procedure UPDATE_ROW (
  X_RUNTIME_PROPERTY_FUNCTION     in VARCHAR2,
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2,
  X_END_USER_COLUMN_NAME          in VARCHAR2,
  X_LAST_UPDATE_DATE              in DATE,
  X_LAST_UPDATED_BY               in NUMBER,
  X_LAST_UPDATE_LOGIN             in NUMBER,
  X_COLUMN_SEQ_NUM                in NUMBER,
  X_ENABLED_FLAG                  in VARCHAR2,
  X_REQUIRED_FLAG                 in VARCHAR2,
  X_SECURITY_ENABLED_FLAG         in VARCHAR2,
  X_DISPLAY_FLAG                  in VARCHAR2,
  X_DISPLAY_SIZE                  in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN       in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE  in NUMBER,
  X_FLEX_VALUE_SET_ID             in NUMBER,
  X_RANGE_CODE                    in VARCHAR2,
  X_DEFAULT_TYPE                  in VARCHAR2,
  X_DEFAULT_VALUE                 in VARCHAR2,
  X_SRW_PARAM                     in VARCHAR2,
  X_FORM_LEFT_PROMPT              in VARCHAR2,
  X_FORM_ABOVE_PROMPT             in VARCHAR2,
  X_DESCRIPTION                   in VARCHAR2
) IS
  BEGIN

     UPDATE fnd_descr_flex_column_usages
       SET
         application_id                  = X_APPLICATION_ID,
         descriptive_flexfield_name      = X_DESCRIPTIVE_FLEXFIELD_NAME,
         descriptive_flex_context_code   = X_DESCRIPTIVE_FLEX_CONTEXT_COD,
         application_column_name         = X_APPLICATION_COLUMN_NAME,
         end_user_column_name            = X_END_USER_COLUMN_NAME,
         last_update_date                = X_LAST_UPDATE_DATE,
         last_updated_by                 = X_LAST_UPDATED_BY,
         last_update_login               = X_LAST_UPDATE_LOGIN,
         column_seq_num                  = X_COLUMN_SEQ_NUM,
         enabled_flag                    = X_ENABLED_FLAG,
         required_flag                   = X_REQUIRED_FLAG,
         security_enabled_flag           = X_SECURITY_ENABLED_FLAG,
         display_flag                    = X_DISPLAY_FLAG,
         display_size                    = X_DISPLAY_SIZE,
         maximum_description_len         = X_MAXIMUM_DESCRIPTION_LEN,
         concatenation_description_len   = X_CONCATENATION_DESCRIPTION_LE,
         flex_value_set_id               = X_FLEX_VALUE_SET_ID,
         range_code                      = X_RANGE_CODE,
         default_type                    = X_DEFAULT_TYPE,
         default_value                   = X_DEFAULT_VALUE,
         srw_param                       = X_SRW_PARAM
      WHERE APPLICATION_ID = X_APPLICATION_ID AND
        DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME AND
        descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD AND
        application_column_name = X_APPLICATION_COLUMN_NAME;


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

--
-- Update translated columns in _TL for current language
--
  UPDATE fnd_descr_flex_col_usage_tl SET
    form_left_prompt  =    X_FORM_LEFT_PROMPT,
    form_above_prompt =    X_FORM_ABOVE_PROMPT,
    description       =    X_DESCRIPTION,
    last_update_date  =    X_LAST_UPDATE_DATE,
    last_updated_by   =    X_LAST_UPDATED_BY,
    last_update_login =    X_LAST_UPDATE_LOGIN,
    source_lang       =    userenv('LANG')
  where application_id = X_application_id
    and descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME
    and descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    and application_column_name = X_APPLICATION_COLUMN_NAME
    and language = userenv('LANG');

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END UPDATE_ROW;



procedure DELETE_ROW (
  X_APPLICATION_ID                in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME    in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD  in VARCHAR2,
  X_APPLICATION_COLUMN_NAME       in VARCHAR2
) IS
  BEGIN
    DELETE FROM fnd_descr_flex_column_usages
    WHERE APPLICATION_ID = X_APPLICATION_ID AND
      DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME AND
      DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD AND
      APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    DELETE FROM fnd_descr_flex_col_usage_TL
     WHERE application_id = X_APPLICATION_ID
       AND descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME
       AND descriptive_flex_context_code = X_DESCRIPTIVE_FLEX_CONTEXT_COD
       AND application_column_name = X_APPLICATION_COLUMN_NAME;

    UPDATE fnd_descriptive_flexs
       SET last_update_date = SYSDATE
     WHERE application_id = X_APPLICATION_ID
       AND descriptive_flexfield_name = X_DESCRIPTIVE_FLEXFIELD_NAME;

  END DELETE_ROW;

end FND_CONCURRENT_ARGUMENTS_PKG;

/
