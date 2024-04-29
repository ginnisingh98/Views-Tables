--------------------------------------------------------
--  DDL for Package Body FND_DESCR_FLEX_COL_USAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DESCR_FLEX_COL_USAGE_PKG" as
/* $Header: AFFFDFSB.pls 120.2.12010000.3 2017/01/13 16:26:33 hgeorgi ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_END_USER_COLUMN_NAME in VARCHAR2,
  X_COLUMN_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_SRW_PARAM in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
) is
    l_application_column_name     VARCHAR2(30);

  cursor C is select ROWID from FND_DESCR_FLEX_COLUMN_USAGES
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME
    ;

begin
/* Bug 1732116 - Remove row level delete of report parameters from here. */

  insert into FND_DESCR_FLEX_COLUMN_USAGES (
    APPLICATION_ID,
    DESCRIPTIVE_FLEXFIELD_NAME,
    DESCRIPTIVE_FLEX_CONTEXT_CODE,
    APPLICATION_COLUMN_NAME,
    END_USER_COLUMN_NAME,
    COLUMN_SEQ_NUM,
    ENABLED_FLAG,
    REQUIRED_FLAG,
    SECURITY_ENABLED_FLAG,
    DISPLAY_FLAG,
    DISPLAY_SIZE,
    MAXIMUM_DESCRIPTION_LEN,
    CONCATENATION_DESCRIPTION_LEN,
    FLEX_VALUE_SET_ID,
    RANGE_CODE,
    DEFAULT_TYPE,
    DEFAULT_VALUE,
    RUNTIME_PROPERTY_FUNCTION,
    SRW_PARAM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN /*,
    SEGMENT_INSERT_FLAG,
    SEGMENT_UPDATE_FLAG */
  ) values (
    X_APPLICATION_ID,
    X_DESCRIPTIVE_FLEXFIELD_NAME,
    X_DESCRIPTIVE_FLEX_CONTEXT_COD,
    X_APPLICATION_COLUMN_NAME,
    X_END_USER_COLUMN_NAME,
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
    X_RUNTIME_PROPERTY_FUNCTION,
    X_SRW_PARAM,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN /*,
    X_SEGMENT_INSERT_FLAG,
    X_SEGMENT_UPDATE_FLAG */
  );

  insert into FND_DESCR_FLEX_COL_USAGE_TL (
    APPLICATION_ID,
    DESCRIPTIVE_FLEXFIELD_NAME,
    DESCRIPTIVE_FLEX_CONTEXT_CODE,
    APPLICATION_COLUMN_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    FORM_LEFT_PROMPT,
    FORM_ABOVE_PROMPT,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_DESCRIPTIVE_FLEXFIELD_NAME,
    X_DESCRIPTIVE_FLEX_CONTEXT_COD,
    X_APPLICATION_COLUMN_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_FORM_LEFT_PROMPT,
    X_FORM_ABOVE_PROMPT,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DESCR_FLEX_COL_USAGE_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and T.DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    and T.APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_END_USER_COLUMN_NAME in VARCHAR2,
  X_COLUMN_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_SRW_PARAM in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2 /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
) is
  cursor c is select
      END_USER_COLUMN_NAME,
      COLUMN_SEQ_NUM,
      ENABLED_FLAG,
      REQUIRED_FLAG,
      SECURITY_ENABLED_FLAG,
      DISPLAY_FLAG,
      DISPLAY_SIZE,
      MAXIMUM_DESCRIPTION_LEN,
      CONCATENATION_DESCRIPTION_LEN,
      FLEX_VALUE_SET_ID,
      RANGE_CODE,
      DEFAULT_TYPE,
      DEFAULT_VALUE,
      RUNTIME_PROPERTY_FUNCTION,
      SRW_PARAM /*,
      SEGMENT_INSERT_FLAG,
      SEGMENT_UPDATE_FLAG */
    from FND_DESCR_FLEX_COLUMN_USAGES
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FORM_LEFT_PROMPT,
      FORM_ABOVE_PROMPT,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_DESCR_FLEX_COL_USAGE_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.END_USER_COLUMN_NAME = X_END_USER_COLUMN_NAME)
      AND (recinfo.COLUMN_SEQ_NUM = X_COLUMN_SEQ_NUM)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
      AND (recinfo.SECURITY_ENABLED_FLAG = X_SECURITY_ENABLED_FLAG)
      AND (recinfo.DISPLAY_FLAG = X_DISPLAY_FLAG)
/*
      AND (recinfo.SEGMENT_INSERT_FLAG = X_SEGMENT_INSERT_FLAG)
      AND (recinfo.SEGMENT_UPDATE_FLAG = X_SEGMENT_UPDATE_FLAG)
*/
      AND (recinfo.DISPLAY_SIZE = X_DISPLAY_SIZE)
      AND (recinfo.MAXIMUM_DESCRIPTION_LEN = X_MAXIMUM_DESCRIPTION_LEN)
      AND (recinfo.CONCATENATION_DESCRIPTION_LEN = X_CONCATENATION_DESCRIPTION_LE)
      AND ((recinfo.FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID)
           OR ((recinfo.FLEX_VALUE_SET_ID is null) AND (X_FLEX_VALUE_SET_ID is null)))
      AND ((recinfo.RANGE_CODE = X_RANGE_CODE)
           OR ((recinfo.RANGE_CODE is null) AND (X_RANGE_CODE is null)))
      AND ((recinfo.DEFAULT_TYPE = X_DEFAULT_TYPE)
           OR ((recinfo.DEFAULT_TYPE is null) AND (X_DEFAULT_TYPE is null)))
      AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
      AND ((recinfo.RUNTIME_PROPERTY_FUNCTION = X_RUNTIME_PROPERTY_FUNCTION)
           OR ((recinfo.RUNTIME_PROPERTY_FUNCTION is null) AND (X_RUNTIME_PROPERTY_FUNCTION is null)))
      AND ((recinfo.SRW_PARAM = X_SRW_PARAM)
           OR ((recinfo.SRW_PARAM is null) AND (X_SRW_PARAM is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FORM_LEFT_PROMPT = X_FORM_LEFT_PROMPT)
          AND (tlinfo.FORM_ABOVE_PROMPT = X_FORM_ABOVE_PROMPT)
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

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_END_USER_COLUMN_NAME in VARCHAR2,
  X_COLUMN_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_SRW_PARAM in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
) is
begin
  update FND_DESCR_FLEX_COLUMN_USAGES set
    END_USER_COLUMN_NAME = X_END_USER_COLUMN_NAME,
    COLUMN_SEQ_NUM = X_COLUMN_SEQ_NUM,
    ENABLED_FLAG = X_ENABLED_FLAG,
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    SECURITY_ENABLED_FLAG = X_SECURITY_ENABLED_FLAG,
    DISPLAY_FLAG = X_DISPLAY_FLAG,
    DISPLAY_SIZE = X_DISPLAY_SIZE,
    MAXIMUM_DESCRIPTION_LEN = X_MAXIMUM_DESCRIPTION_LEN,
    CONCATENATION_DESCRIPTION_LEN = X_CONCATENATION_DESCRIPTION_LE,
    FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID,
    RANGE_CODE = X_RANGE_CODE,
    DEFAULT_TYPE = X_DEFAULT_TYPE,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    RUNTIME_PROPERTY_FUNCTION = X_RUNTIME_PROPERTY_FUNCTION,
    SRW_PARAM = X_SRW_PARAM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN /*,
    SEGMENT_INSERT_FLAG = X_SEGMENT_INSERT_FLAG,
    SEGMENT_UPDATE_FLAG = X_SEGMENT_UPDATE_FLAG */
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
  and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_DESCR_FLEX_COL_USAGE_TL set
    FORM_LEFT_PROMPT = X_FORM_LEFT_PROMPT,
    FORM_ABOVE_PROMPT = X_FORM_ABOVE_PROMPT,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
  and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2
) is
begin
  delete from FND_DESCR_FLEX_COL_USAGE_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
  and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_DESCR_FLEX_COLUMN_USAGES
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
  and APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
 is
 begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*
   delete from FND_DESCR_FLEX_COL_USAGE_TL T
   where not exists
     (select NULL
     from FND_DESCR_FLEX_COLUMN_USAGES B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     and B.DESCRIPTIVE_FLEX_CONTEXT_CODE = T.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and B.APPLICATION_COLUMN_NAME = T.APPLICATION_COLUMN_NAME
     );

   update FND_DESCR_FLEX_COL_USAGE_TL T set (
       FORM_LEFT_PROMPT,
       FORM_ABOVE_PROMPT,
       DESCRIPTION
     ) = (select
       B.FORM_LEFT_PROMPT,
       B.FORM_ABOVE_PROMPT,
       B.DESCRIPTION
     from FND_DESCR_FLEX_COL_USAGE_TL B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     and B.DESCRIPTIVE_FLEX_CONTEXT_CODE = T.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and B.APPLICATION_COLUMN_NAME = T.APPLICATION_COLUMN_NAME
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.APPLICATION_ID,
       T.DESCRIPTIVE_FLEXFIELD_NAME,
       T.DESCRIPTIVE_FLEX_CONTEXT_CODE,
       T.APPLICATION_COLUMN_NAME,
       T.LANGUAGE
   ) in (select
       SUBT.APPLICATION_ID,
       SUBT.DESCRIPTIVE_FLEXFIELD_NAME,
       SUBT.DESCRIPTIVE_FLEX_CONTEXT_CODE,
       SUBT.APPLICATION_COLUMN_NAME,
       SUBT.LANGUAGE
     from FND_DESCR_FLEX_COL_USAGE_TL SUBB, FND_DESCR_FLEX_COL_USAGE_TL SUBT
     where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
     and SUBB.DESCRIPTIVE_FLEXFIELD_NAME = SUBT.DESCRIPTIVE_FLEXFIELD_NAME
     and SUBB.DESCRIPTIVE_FLEX_CONTEXT_CODE = SUBT.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and SUBB.APPLICATION_COLUMN_NAME = SUBT.APPLICATION_COLUMN_NAME
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.FORM_LEFT_PROMPT <> SUBT.FORM_LEFT_PROMPT
       or SUBB.FORM_ABOVE_PROMPT <> SUBT.FORM_ABOVE_PROMPT
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

   insert /*+ append parallel(tt) */ into FND_DESCR_FLEX_COL_USAGE_TL tt (
     APPLICATION_ID,
     DESCRIPTIVE_FLEXFIELD_NAME,
     DESCRIPTIVE_FLEX_CONTEXT_CODE,
     APPLICATION_COLUMN_NAME,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     FORM_LEFT_PROMPT,
     FORM_ABOVE_PROMPT,
     DESCRIPTION,
     LANGUAGE,
     SOURCE_LANG
   )
     select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
        (select /*+ no_merge ordered parallel(b) */
     B.APPLICATION_ID,
     B.DESCRIPTIVE_FLEXFIELD_NAME,
     B.DESCRIPTIVE_FLEX_CONTEXT_CODE,
     B.APPLICATION_COLUMN_NAME,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.FORM_LEFT_PROMPT,
     B.FORM_ABOVE_PROMPT,
     B.DESCRIPTION,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_DESCR_FLEX_COL_USAGE_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   ) v, FND_DESCR_FLEX_COL_USAGE_TL t
   where t.application_id(+) = v.application_id
   and t.descriptive_flexfield_name(+) =  v.descriptive_flexfield_name
   and t.descriptive_flex_context_code(+) =  v.descriptive_flex_context_code
   and t.application_column_name(+) =  v.application_column_name
   and t.language(+) = v.language_code
   and t.application_id is NULL
   and t.descriptive_flexfield_name is NULL
   and t.descriptive_flex_context_code is NULL
   and t.application_column_name is NULL;

end ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_end_user_column_name         IN VARCHAR2,
   x_column_seq_num               IN NUMBER,
   x_enabled_flag                 IN VARCHAR2,
   x_required_flag                IN VARCHAR2,
   x_security_enabled_flag        IN VARCHAR2,
   x_display_flag                 IN VARCHAR2,
   x_display_size                 IN NUMBER,
   x_maximum_description_len      IN NUMBER,
   x_concatenation_description_le IN NUMBER,
   x_flex_value_set_name          IN VARCHAR2,
   x_range_code                   IN VARCHAR2,
   x_default_type                 IN VARCHAR2,
   x_default_value                IN VARCHAR2,
   x_runtime_property_function    IN VARCHAR2,
   x_srw_param                    IN VARCHAR2,
   x_form_left_prompt             IN VARCHAR2,
   x_form_above_prompt            IN VARCHAR2,
   x_description                  IN VARCHAR2 /*,
   x_segment_insert_flag          IN VARCHAR2,
   x_segment_update_flag          IN VARCHAR2 */)
  IS
     l_application_id    NUMBER;
     l_flex_value_set_id NUMBER := NULL;
     l_vc2               VARCHAR2(2000);
     l_rowid             VARCHAR2(64);
BEGIN
   SELECT application_id
     INTO l_application_id
     FROM fnd_application
     WHERE application_short_name = x_application_short_name;

   SELECT descriptive_flexfield_name
     INTO l_vc2
     FROM fnd_descriptive_flexs
     WHERE application_id = l_application_id
     AND descriptive_flexfield_name = x_descriptive_flexfield_name;

   SELECT descriptive_flex_context_code
     INTO l_vc2
     FROM fnd_descr_flex_contexts
     WHERE application_id = l_application_id
     AND descriptive_flexfield_name = x_descriptive_flexfield_name
     AND descriptive_flex_context_code = x_descriptive_flex_context_cod;

   IF (x_flex_value_set_name IS NOT NULL) THEN
      SELECT flex_value_set_id
        INTO l_flex_value_set_id
        FROM fnd_flex_value_sets
        WHERE flex_value_set_name = x_flex_value_set_name;
   END IF;

   BEGIN
      fnd_descr_flex_col_usage_pkg.update_row
        (X_APPLICATION_ID               => l_application_id,
         X_DESCRIPTIVE_FLEXFIELD_NAME   => x_descriptive_flexfield_name,
         X_DESCRIPTIVE_FLEX_CONTEXT_COD => x_descriptive_flex_context_cod,
         X_APPLICATION_COLUMN_NAME      => x_application_column_name,
         X_END_USER_COLUMN_NAME         => x_end_user_column_name,
         X_COLUMN_SEQ_NUM               => x_column_seq_num,
         X_ENABLED_FLAG                 => x_enabled_flag,
         X_REQUIRED_FLAG                => x_required_flag,
         X_SECURITY_ENABLED_FLAG        => x_security_enabled_flag,
         X_DISPLAY_FLAG                 => x_display_flag,
         X_DISPLAY_SIZE                 => x_display_size,
         X_MAXIMUM_DESCRIPTION_LEN      => x_maximum_description_len,
         X_CONCATENATION_DESCRIPTION_LE => x_concatenation_description_le,
         X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
         X_RANGE_CODE                   => x_range_code,
         X_DEFAULT_TYPE                 => x_default_type,
         X_DEFAULT_VALUE                => x_default_value,
         X_RUNTIME_PROPERTY_FUNCTION    => x_runtime_property_function,
         X_SRW_PARAM                    => x_srw_param,
         X_FORM_LEFT_PROMPT             => x_form_left_prompt,
         X_FORM_ABOVE_PROMPT            => x_form_above_prompt,
         X_DESCRIPTION                  => x_description,
         X_LAST_UPDATE_DATE             => x_who.last_update_date,
         X_LAST_UPDATED_BY              => x_who.last_updated_by,
         X_LAST_UPDATE_LOGIN            => x_who.last_update_login /*,
         X_SEGMENT_INSERT_FLAG          => x_segment_insert_flag,
         X_SEGMENT_UPDATE_FLAG          => x_segment_update_flag */);
   EXCEPTION
      WHEN no_data_found THEN
         fnd_descr_flex_col_usage_pkg.insert_row
           (X_ROWID                        => l_rowid,
            X_APPLICATION_ID               => l_application_id,
            X_DESCRIPTIVE_FLEXFIELD_NAME   => x_descriptive_flexfield_name,
            X_DESCRIPTIVE_FLEX_CONTEXT_COD => x_descriptive_flex_context_cod,
            X_APPLICATION_COLUMN_NAME      => x_application_column_name,
            X_END_USER_COLUMN_NAME         => x_end_user_column_name,
            X_COLUMN_SEQ_NUM               => x_column_seq_num,
            X_ENABLED_FLAG                 => x_enabled_flag,
            X_REQUIRED_FLAG                => x_required_flag,
            X_SECURITY_ENABLED_FLAG        => x_security_enabled_flag,
            X_DISPLAY_FLAG                 => x_display_flag,
            X_DISPLAY_SIZE                 => x_display_size,
            X_MAXIMUM_DESCRIPTION_LEN      => x_maximum_description_len,
            X_CONCATENATION_DESCRIPTION_LE => x_concatenation_description_le,
            X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
            X_RANGE_CODE                   => x_range_code,
            X_DEFAULT_TYPE                 => x_default_type,
            X_DEFAULT_VALUE                => x_default_value,
            X_RUNTIME_PROPERTY_FUNCTION    => x_runtime_property_function,
            X_SRW_PARAM                    => x_srw_param,
            X_FORM_LEFT_PROMPT             => x_form_left_prompt,
            X_FORM_ABOVE_PROMPT            => x_form_above_prompt,
            X_DESCRIPTION                  => x_description,
            X_CREATION_DATE                => x_who.creation_date,
            X_CREATED_BY                   => x_who.created_by,
            X_LAST_UPDATE_DATE             => x_who.last_update_date,
            X_LAST_UPDATED_BY              => x_who.last_updated_by,
            X_LAST_UPDATE_LOGIN            => x_who.last_update_login /*,
            X_SEGMENT_INSERT_FLAG          => x_segment_insert_flag,
            X_SEGMENT_UPDATE_FLAG          => x_segment_update_flag */);
   END;
END load_row;

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_form_left_prompt             IN VARCHAR2,
   x_form_above_prompt            IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_descr_flex_col_usage_tl SET
     form_left_prompt  = Nvl(x_form_left_prompt, form_left_prompt),
     form_above_prompt = Nvl(x_form_above_prompt, form_above_prompt),
     description       = Nvl(x_description, description),
     last_update_date  = x_who.last_update_date,
     last_updated_by   = x_who.last_updated_by,
     last_update_login = x_who.last_update_login,
     source_lang       = userenv('LANG')
     WHERE application_id = (SELECT application_id
                             FROM fnd_application
                             WHERE application_short_name = x_application_short_name)
     AND descriptive_flexfield_name = x_descriptive_flexfield_name
     AND descriptive_flex_context_code = x_descriptive_flex_context_cod
     AND application_column_name = x_application_column_name
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_DESCR_FLEX_COL_USAGE_PKG;

/
