--------------------------------------------------------
--  DDL for Package Body FND_OAM_METVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_METVAL_PKG" AS
  /* $Header: AFOAMMTB.pls 120.2 2005/10/20 12:29:41 ilawler noship $ */

  -- PRIVATE -----------------

  --
  -- To update only those columns that are non-customizable by the
  -- user
  --
  procedure UPDATE_ROW_INTERNAL (
    X_METRIC_SHORT_NAME in VARCHAR2,
    X_GROUP_ID in NUMBER,
    X_SEQUENCE in NUMBER,
    X_NODE_NAME in VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_METRIC_DISPLAY_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2
  ) is
  begin
    update FND_OAM_METVAL set
      GROUP_ID = X_GROUP_ID,
      SEQUENCE = X_SEQUENCE,
      METRIC_TYPE = X_METRIC_TYPE,
      IS_SUPPORTED = nvl(X_IS_SUPPORTED, 'Y')
    where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME
    and (X_NODE_NAME is null or
      (X_NODE_NAME is not null and NODE_NAME = X_NODE_NAME));

    if (sql%notfound) then
      raise no_data_found;
    end if;

    update FND_OAM_METS_TL set
      METRIC_DISPLAY_NAME = X_METRIC_DISPLAY_NAME,
      DESCRIPTION = X_DESCRIPTION,
      SOURCE_LANG = userenv('LANG')
    where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end UPDATE_ROW_INTERNAL;

  procedure LOAD_ROW (
    X_METRIC_SHORT_NAME     in  VARCHAR2,
    X_METRIC_VALUE          in  VARCHAR2,
    X_STATUS_CODE           in  VARCHAR2,
    X_GROUP_ID              in  VARCHAR2,
    X_SEQUENCE              in  VARCHAR2,
    X_NODE_NAME             in  VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  VARCHAR2,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  VARCHAR2,
    X_OWNER                 in  VARCHAR2,
    X_METRIC_DISPLAY_NAME         in    VARCHAR2,
    X_DESCRIPTION                       in      VARCHAR2) is
  begin

     fnd_oam_metval_pkg.LOAD_ROW (
       X_METRIC_SHORT_NAME => X_METRIC_SHORT_NAME,
       X_METRIC_VALUE => X_METRIC_VALUE,
       X_STATUS_CODE => X_STATUS_CODE,
       X_GROUP_ID => X_GROUP_ID,
       X_SEQUENCE => X_SEQUENCE,
       X_NODE_NAME => X_NODE_NAME,
       X_METRIC_TYPE => X_METRIC_TYPE,
       X_THRESHOLD_OPERATOR => X_THRESHOLD_OPERATOR,
       X_THRESHOLD_VALUE => X_THRESHOLD_VALUE,
       X_ALERT_ENABLED_FLAG => X_ALERT_ENABLED_FLAG,
       X_COLLECTION_ENABLED_FLAG => X_COLLECTION_ENABLED_FLAG,
       X_LAST_COLLECTED_DATE => X_LAST_COLLECTED_DATE,
       X_IS_SUPPORTED => X_IS_SUPPORTED,
       X_IS_CUSTOMIZED => X_IS_CUSTOMIZED,
       X_INTERVAL_COUNTER => X_INTERVAL_COUNTER,
       X_OWNER => X_OWNER,
       X_METRIC_DISPLAY_NAME => X_METRIC_DISPLAY_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');

  end LOAD_ROW;

  procedure LOAD_ROW (
    X_METRIC_SHORT_NAME     in  VARCHAR2,
    X_METRIC_VALUE          in  VARCHAR2,
    X_STATUS_CODE           in  VARCHAR2,
    X_GROUP_ID              in  VARCHAR2,
    X_SEQUENCE              in  VARCHAR2,
    X_NODE_NAME             in  VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  VARCHAR2,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  VARCHAR2,
    X_OWNER                 in  VARCHAR2,
    X_METRIC_DISPLAY_NAME         in    VARCHAR2,
    X_DESCRIPTION                       in      VARCHAR2,
    x_custom_mode           in  varchar2,
    x_last_update_date      in  varchar2) is

      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db

      -- columns that are user customizable
      l_is_customized fnd_oam_metval.is_customized%TYPE;
      l_metric_value fnd_oam_metval.metric_value%TYPE;
      l_status_code fnd_oam_metval.status_code%TYPE;
      l_threshold_operator fnd_oam_metval.threshold_operator%TYPE;
      l_threshold_value fnd_oam_metval.threshold_value%TYPE;
      l_alert_enabled_flag fnd_oam_metval.alert_enabled_flag%TYPE;
      l_collection_enabled_flag fnd_oam_metval.collection_enabled_flag%TYPE;
      l_last_collected_date fnd_oam_metval.last_collected_date%TYPE;
      l_interval_counter fnd_oam_metval.interval_counter%TYPE;
    begin
      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(x_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      begin
        -- We need to distinguish between the case where node name is null
        -- or not
        -- because, metric_short_name and node_name will uniquely indentify a
        -- particular metric (and node_name is allowed to be null).
        select LAST_UPDATED_BY, LAST_UPDATE_DATE, is_customized,
          metric_value, status_code, threshold_operator,
          threshold_value, alert_enabled_flag, collection_enabled_flag,
          last_collected_date, interval_counter
        into db_luby, db_ludate, l_is_customized,
          l_metric_value, l_status_code, l_threshold_operator,
          l_threshold_value, l_alert_enabled_flag, l_collection_enabled_flag,
          l_last_collected_date, l_interval_counter
        from   fnd_oam_metval
        where  metric_short_name = X_METRIC_SHORT_NAME
          and (X_NODE_NAME is null or
                   (X_NODE_NAME is not null and NODE_NAME = X_NODE_NAME));

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        --dbms_output.put_line('fnd_load_util.upload_test -> true');
        begin
          if (l_is_customized is null or l_is_customized = 'N') then
            l_is_customized := X_IS_CUSTOMIZED;
            l_threshold_operator := X_THRESHOLD_OPERATOR;
            l_threshold_value := X_THRESHOLD_VALUE;
            l_alert_enabled_flag := X_ALERT_ENABLED_FLAG;
            l_collection_enabled_flag := X_COLLECTION_ENABLED_FLAG;
          end if;
          fnd_oam_metval_pkg.UPDATE_ROW (
            X_METRIC_SHORT_NAME => X_METRIC_SHORT_NAME,
            X_METRIC_VALUE => l_metric_value,
            X_STATUS_CODE => to_number(l_status_code),
            X_GROUP_ID => to_number(X_GROUP_ID),
            X_SEQUENCE => to_number(X_SEQUENCE),
            X_NODE_NAME => X_NODE_NAME,
            X_METRIC_TYPE => X_METRIC_TYPE,
            X_THRESHOLD_OPERATOR => l_threshold_operator,
            X_THRESHOLD_VALUE => l_threshold_value,
            X_ALERT_ENABLED_FLAG => l_alert_enabled_flag,
            X_COLLECTION_ENABLED_FLAG => l_collection_enabled_flag,
            X_LAST_COLLECTED_DATE => to_date(l_last_collected_date, 'YYYY/MM/DD'),
            X_IS_SUPPORTED => X_IS_SUPPORTED,
            X_IS_CUSTOMIZED => l_is_customized,
            X_INTERVAL_COUNTER => to_number(l_interval_counter),
            X_METRIC_DISPLAY_NAME => X_METRIC_DISPLAY_NAME,
            X_DESCRIPTION => X_DESCRIPTION,
            X_LAST_UPDATE_DATE => f_ludate,
            X_LAST_UPDATED_BY => f_luby,
            X_LAST_UPDATE_LOGIN => 0 );
        end;
       else
          -- dbms_output.put_line('fnd_load_util.upload_test -> false');
          -- fnd_load_util.upload_test returned false,
          -- which means the metric has been customized by the user
          -- but we would
          -- still like to update some columns that are not editable
          -- by the user.
          begin
                UPDATE_ROW_INTERNAL(
                  X_METRIC_SHORT_NAME => X_METRIC_SHORT_NAME,
                  X_GROUP_ID => to_number(X_GROUP_ID),
                  X_SEQUENCE => to_number(X_SEQUENCE),
                  X_NODE_NAME => X_NODE_NAME,
                  X_METRIC_TYPE => X_METRIC_TYPE,
                  X_IS_SUPPORTED => X_IS_SUPPORTED,
                  X_METRIC_DISPLAY_NAME => X_METRIC_DISPLAY_NAME,
                  X_DESCRIPTION => X_DESCRIPTION);
          exception
                when no_data_found then
                  -- somehow this row does not yet exist?
                  -- this should never happen
                  null;
          end;
        end if;
      exception
        when NO_DATA_FOUND then

        fnd_oam_metval_pkg.INSERT_ROW (
          X_ROWID => row_id,
          X_METRIC_SHORT_NAME => X_METRIC_SHORT_NAME,
          X_METRIC_VALUE => X_METRIC_VALUE,
          X_STATUS_CODE => to_number(X_STATUS_CODE),
          X_GROUP_ID => to_number(X_GROUP_ID),
          X_SEQUENCE => to_number(X_SEQUENCE),
          X_NODE_NAME => X_NODE_NAME,
          X_METRIC_TYPE => X_METRIC_TYPE,
          X_THRESHOLD_OPERATOR => X_THRESHOLD_OPERATOR,
          X_THRESHOLD_VALUE => X_THRESHOLD_VALUE,
          X_ALERT_ENABLED_FLAG => X_ALERT_ENABLED_FLAG,
          X_COLLECTION_ENABLED_FLAG => X_COLLECTION_ENABLED_FLAG,
          X_LAST_COLLECTED_DATE => to_date(X_LAST_COLLECTED_DATE, 'YYYY/MM/DD'),
          X_IS_SUPPORTED => X_IS_SUPPORTED,
          X_IS_CUSTOMIZED => X_IS_CUSTOMIZED,
          X_INTERVAL_COUNTER => to_number(X_INTERVAL_COUNTER),
          X_METRIC_DISPLAY_NAME => X_METRIC_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
  end LOAD_ROW;

  procedure TRANSLATE_ROW (
    X_METRIC_SHORT_NAME         in      VARCHAR2,
    X_OWNER                     in      VARCHAR2,
    X_METRIC_DISPLAY_NAME             in        VARCHAR2,
    X_DESCRIPTION                           in  VARCHAR2) is
  begin

  fnd_oam_metval_pkg.translate_row(
    x_metric_short_name => x_metric_short_name,
    x_owner => x_owner,
    x_metric_display_name => x_metric_display_name,
    x_description => x_description,
    x_custom_mode => '',
    x_last_update_date => '');

  end TRANSLATE_ROW;


  procedure TRANSLATE_ROW (
    X_METRIC_SHORT_NAME     in  VARCHAR2,
    X_OWNER                 in  VARCHAR2,
    X_METRIC_DISPLAY_NAME         in    VARCHAR2,
    X_DESCRIPTION                       in      VARCHAR2,
    X_CUSTOM_MODE                       in      VARCHAR2,
    X_LAST_UPDATE_DATE      in  VARCHAR2) is

      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db

  begin

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    begin

        select LAST_UPDATED_BY, LAST_UPDATE_DATE
        into db_luby, db_ludate
        from fnd_oam_mets_tl
        where metric_short_name = X_METRIC_SHORT_NAME
          and LANGUAGE = userenv('LANG');

        if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
          update fnd_oam_mets_tl set
            metric_display_name = nvl(X_METRIC_DISPLAY_NAME, metric_display_name),
            description         = nvl(X_DESCRIPTION, description),
            source_lang         = userenv('LANG'),
            last_update_date    = f_ludate,
            last_updated_by     = f_luby,
            last_update_login   = 0
          where metric_short_name = X_METRIC_SHORT_NAME
            and userenv('LANG') in (language, source_lang);
        end if;
    exception
      when no_data_found then
        null;
    end;

  end TRANSLATE_ROW;

  procedure INSERT_ROW (
    X_ROWID             IN OUT NOCOPY   VARCHAR2,
    X_METRIC_SHORT_NAME in VARCHAR2,
    X_METRIC_VALUE in VARCHAR2,
    X_STATUS_CODE in NUMBER,
    X_GROUP_ID in NUMBER,
    X_SEQUENCE  in      VARCHAR2,
    X_NODE_NAME in VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  DATE,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in NUMBER,
    X_METRIC_DISPLAY_NAME       in      VARCHAR2,
    X_DESCRIPTION       in      VARCHAR2,
    X_CREATED_BY                in      NUMBER,
    X_CREATION_DATE     in      DATE,
    X_LAST_UPDATED_BY   in      NUMBER,
    X_LAST_UPDATE_DATE  in      DATE,
    X_LAST_UPDATE_LOGIN         in      NUMBER)
  is
    cursor C is select ROWID from FND_OAM_METVAL
      where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME
      and (X_NODE_NAME is null or
        (X_NODE_NAME is not null and NODE_NAME = X_NODE_NAME));
  begin
    insert into FND_OAM_METVAL (
      METRIC_SHORT_NAME,
      METRIC_VALUE,
      STATUS_CODE,
      GROUP_ID,
      SEQUENCE,
      NODE_NAME,
      METRIC_TYPE,
      THRESHOLD_OPERATOR,
      THRESHOLD_VALUE,
      ALERT_ENABLED_FLAG,
      COLLECTION_ENABLED_FLAG,
      LAST_COLLECTED_DATE,
      IS_SUPPORTED,
      IS_CUSTOMIZED,
      INTERVAL_COUNTER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    ) values (
      X_METRIC_SHORT_NAME,
      X_METRIC_VALUE,
      X_STATUS_CODE,
      X_GROUP_ID,
      X_SEQUENCE,
      X_NODE_NAME,
      X_METRIC_TYPE,
      X_THRESHOLD_OPERATOR,
      X_THRESHOLD_VALUE,
      nvl(X_ALERT_ENABLED_FLAG, 'N'),
      nvl(X_COLLECTION_ENABLED_FLAG, 'Y'),
      X_LAST_COLLECTED_DATE,
      nvl(X_IS_SUPPORTED, 'Y'),
      nvl(X_IS_CUSTOMIZED, 'N'),
      X_INTERVAL_COUNTER,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN);

    insert into FND_OAM_METS_TL (
      METRIC_SHORT_NAME,
      METRIC_DISPLAY_NAME,
      DESCRIPTION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_METRIC_SHORT_NAME,
      X_METRIC_DISPLAY_NAME,
      X_DESCRIPTION,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      (select NULL
      from FND_OAM_METS_TL T
      where T.METRIC_SHORT_NAME = X_METRIC_SHORT_NAME
      and T.LANGUAGE = L.LANGUAGE_CODE);

    open c;
    fetch c into X_ROWID;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;
  END INSERT_ROW;

  procedure UPDATE_ROW (
    X_METRIC_SHORT_NAME in VARCHAR2,
    X_METRIC_VALUE in VARCHAR2,
    X_STATUS_CODE in NUMBER,
    X_GROUP_ID in NUMBER,
    X_SEQUENCE in NUMBER,
    X_NODE_NAME in VARCHAR2,
    X_METRIC_TYPE           in  VARCHAR2,
    X_THRESHOLD_OPERATOR    in  VARCHAR2,
    X_THRESHOLD_VALUE       in  VARCHAR2,
    X_ALERT_ENABLED_FLAG    in  VARCHAR2,
    X_COLLECTION_ENABLED_FLAG     in  VARCHAR2,
    X_LAST_COLLECTED_DATE   in  DATE,
    X_IS_SUPPORTED          in  VARCHAR2,
    X_IS_CUSTOMIZED            in  VARCHAR2,
    X_INTERVAL_COUNTER      in  NUMBER,
    X_METRIC_DISPLAY_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_LAST_UPDATED_BY in NUMBER,
    X_LAST_UPDATE_LOGIN in NUMBER
  ) is
  begin
    update FND_OAM_METVAL set
      METRIC_VALUE = X_METRIC_VALUE,
      STATUS_CODE = X_STATUS_CODE,
      GROUP_ID = X_GROUP_ID,
      SEQUENCE = X_SEQUENCE,
      METRIC_TYPE = X_METRIC_TYPE,
      THRESHOLD_OPERATOR = X_THRESHOLD_OPERATOR,
      THRESHOLD_VALUE = X_THRESHOLD_VALUE,
      ALERT_ENABLED_FLAG = nvl(X_ALERT_ENABLED_FLAG,'N'),
      COLLECTION_ENABLED_FLAG = nvl(X_COLLECTION_ENABLED_FLAG,'Y'),
      LAST_COLLECTED_DATE = X_LAST_COLLECTED_DATE,
      IS_SUPPORTED = nvl(X_IS_SUPPORTED,'Y'),
      IS_CUSTOMIZED = nvl(X_IS_CUSTOMIZED,'N'),
      INTERVAL_COUNTER = X_INTERVAL_COUNTER,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME
    and (X_NODE_NAME is null or
      (X_NODE_NAME is not null and NODE_NAME = X_NODE_NAME));

    if (sql%notfound) then
      raise no_data_found;
    end if;

    update FND_OAM_METS_TL set
      METRIC_DISPLAY_NAME = X_METRIC_DISPLAY_NAME,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      SOURCE_LANG = userenv('LANG')
    where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end UPDATE_ROW;

  procedure DELETE_ROW (
    X_METRIC_SHORT_NAME in VARCHAR2
  ) is
  begin
    delete from FND_OAM_METS_TL
    where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME;

    if (sql%notfound) then
      raise no_data_found;
    end if;

    delete from FND_OAM_METVAL
    where METRIC_SHORT_NAME = X_METRIC_SHORT_NAME;

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
    delete from FND_OAM_METS_TL T
    where not exists
      (select NULL
        from FND_OAM_METVAL B
        where B.METRIC_SHORT_NAME = T.METRIC_SHORT_NAME
      );

    update FND_OAM_METS_TL T set (
        METRIC_DISPLAY_NAME,
        DESCRIPTION
      ) = (select
        B.METRIC_DISPLAY_NAME,
        B.DESCRIPTION
      from FND_OAM_METS_TL B
      where B.METRIC_SHORT_NAME = T.METRIC_SHORT_NAME
      and B.LANGUAGE = T.SOURCE_LANG)
    where (
        T.METRIC_SHORT_NAME,
        T.LANGUAGE
    ) in (select
        SUBT.METRIC_SHORT_NAME,
        SUBT.LANGUAGE
      from FND_OAM_METS_TL SUBB, FND_OAM_METS_TL SUBT
      where SUBB.METRIC_SHORT_NAME = SUBT.METRIC_SHORT_NAME
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and (SUBB.METRIC_DISPLAY_NAME <> SUBT.METRIC_DISPLAY_NAME
        or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
        or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
        or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
    ));
*/

    insert into FND_OAM_METS_TL (
      METRIC_SHORT_NAME,
      METRIC_DISPLAY_NAME,
      DESCRIPTION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) select
      B.METRIC_SHORT_NAME,
      B.METRIC_DISPLAY_NAME,
      B.DESCRIPTION,
      B.CREATED_BY,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
    from FND_OAM_METS_TL B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    and not exists
      (select NULL
      from FND_OAM_METS_TL T
      where T.METRIC_SHORT_NAME = B.METRIC_SHORT_NAME
      and T.LANGUAGE = L.LANGUAGE_CODE);
  end ADD_LANGUAGE;

END fnd_oam_metval_pkg;

/
