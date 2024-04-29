--------------------------------------------------------
--  DDL for Package Body FND_OAM_MET_GRPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_MET_GRPS_PKG" AS
  /* $Header: AFOAMMGB.pls 120.2 2005/10/19 11:29:39 ilawler noship $ */
  procedure LOAD_ROW (
    X_METRIC_GROUP_ID     in  VARCHAR2,
    X_SEQUENCE            in    VARCHAR2,
    X_OWNER               in    VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2) is
  begin

     fnd_oam_met_grps_pkg.LOAD_ROW (
       X_METRIC_GROUP_ID => X_METRIC_GROUP_ID,
       X_SEQUENCE => X_SEQUENCE,
       X_OWNER => X_OWNER,
       X_METRIC_GROUP_DISPLAY_NAME => X_METRIC_GROUP_DISPLAY_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       x_custom_mode => '',
       x_last_update_date => '');

  end LOAD_ROW;

  procedure LOAD_ROW (
    X_METRIC_GROUP_ID     in  VARCHAR2,
    X_SEQUENCE            in    VARCHAR2,
    X_OWNER               in    VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2) is

      mgroup_id number;
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db

      cursor c1 is
        select last_updated_by, last_update_date
        from fnd_oam_met_grps_tl
        where metric_group_id = to_number(X_METRIC_GROUP_ID)
        order by last_update_date asc;
    begin
      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(x_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      begin
        -- added for bug fix 2507658
        -- check if this metric group id already exists.
        select metric_group_id
        into mgroup_id
        from   fnd_oam_met_grps_tl
        where  metric_group_id = to_number(X_METRIC_GROUP_ID)
        and rownum = 1;

        -- obtain the last update stamp; pick the first row
        for rec in c1 loop
                db_luby := rec.last_updated_by;
                db_ludate := rec.last_update_date;
                exit when 1=1;
        end loop;

        --select metric_group_id,LAST_UPDATED_BY, LAST_UPDATE_DATE
        --into mgroup_id, db_luby, db_ludate
        --from   fnd_oam_met_grps_tl
        --where  metric_group_id = to_number(X_METRIC_GROUP_ID)
        --and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        fnd_oam_met_grps_pkg.UPDATE_ROW (
          X_METRIC_GROUP_ID => mgroup_id,
          X_SEQUENCE => to_number(X_SEQUENCE),
          X_METRIC_GROUP_DISPLAY_NAME => X_METRIC_GROUP_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        fnd_oam_met_grps_pkg.INSERT_ROW (
          X_ROWID => row_id,
          X_METRIC_GROUP_ID => to_number(X_METRIC_GROUP_ID),
          X_SEQUENCE => to_number(X_SEQUENCE),
          X_METRIC_GROUP_DISPLAY_NAME => X_METRIC_GROUP_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
  end LOAD_ROW;

  procedure TRANSLATE_ROW (
    X_METRIC_GROUP_ID             in    VARCHAR2,
    X_OWNER                     in      VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2) is
  begin

  FND_OAM_MET_GRPS_PKG.translate_row(
    x_metric_group_id => x_metric_group_id,
    x_owner => x_owner,
    x_metric_group_display_name => x_metric_group_display_name,
    x_description => x_description,
    x_custom_mode => '',
    x_last_update_date => '');

  end TRANSLATE_ROW;


  procedure TRANSLATE_ROW (
    X_METRIC_GROUP_ID       in  VARCHAR2,
    X_OWNER               in    VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION               in      VARCHAR2,
    X_CUSTOM_MODE               in      VARCHAR2,
    X_LAST_UPDATE_DATE  in      VARCHAR2) is

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
      from fnd_oam_met_grps_tl
      where metric_group_id = to_number(X_METRIC_GROUP_ID)
      and LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        update fnd_oam_met_grps_tl set
          metric_group_display_name = nvl(X_METRIC_GROUP_DISPLAY_NAME, metric_group_display_name),
          description         = nvl(X_DESCRIPTION, description),
          source_lang         = userenv('LANG'),
          last_update_date    = f_ludate,
          last_updated_by     = f_luby,
          last_update_login   = 0
        where metric_group_id = to_number(X_METRIC_GROUP_ID)
          and userenv('LANG') in (language, source_lang);
      end if;
    exception
      when no_data_found then
        null;
    end;

  end TRANSLATE_ROW;

  procedure INSERT_ROW (
    X_ROWID             IN OUT NOCOPY   VARCHAR2,
    X_METRIC_GROUP_ID   in      NUMBER,
    X_SEQUENCE  in      VARCHAR2,
    X_METRIC_GROUP_DISPLAY_NAME in      VARCHAR2,
    X_DESCRIPTION       in      VARCHAR2,
    X_CREATED_BY                in      NUMBER,
    X_CREATION_DATE     in      DATE,
    X_LAST_UPDATED_BY   in      NUMBER,
    X_LAST_UPDATE_DATE  in      DATE,
    X_LAST_UPDATE_LOGIN         in      NUMBER)
  is
    cursor C is select ROWID from FND_OAM_MET_GRPS_TL
      where METRIC_GROUP_ID = X_METRIC_GROUP_ID;
  begin
    insert into FND_OAM_MET_GRPS_TL (
      METRIC_GROUP_ID,
      SEQUENCE,
      METRIC_GROUP_DISPLAY_NAME,
      DESCRIPTION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) select
      X_METRIC_GROUP_ID,
      X_SEQUENCE,
      X_METRIC_GROUP_DISPLAY_NAME,
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
      from FND_OAM_MET_GRPS_TL T
      where T.METRIC_GROUP_ID = X_METRIC_GROUP_ID
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
    X_METRIC_GROUP_ID in NUMBER,
    X_SEQUENCE in NUMBER,
    X_METRIC_GROUP_DISPLAY_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_LAST_UPDATE_DATE in DATE,
    X_LAST_UPDATED_BY in NUMBER,
    X_LAST_UPDATE_LOGIN in NUMBER
  ) is
  begin
    update FND_OAM_MET_GRPS_TL set
      SEQUENCE = X_SEQUENCE,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where METRIC_GROUP_ID = X_METRIC_GROUP_ID;

    update FND_OAM_MET_GRPS_TL set
      METRIC_GROUP_DISPLAY_NAME = X_METRIC_GROUP_DISPLAY_NAME,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      SOURCE_LANG = userenv('LANG')
    where METRIC_GROUP_ID = X_METRIC_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end UPDATE_ROW;

  procedure DELETE_ROW (
    X_METRIC_GROUP_ID in NUMBER
  ) is
  begin
    delete from FND_OAM_MET_GRPS_TL
    where METRIC_GROUP_ID = X_METRIC_GROUP_ID;

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

    update FND_OAM_MET_GRPS_TL T set (
        SEQUENCE,
        METRIC_GROUP_DISPLAY_NAME,
        DESCRIPTION
      ) = (select
        B.SEQUENCE,
        B.METRIC_GROUP_DISPLAY_NAME,
        B.DESCRIPTION
      from FND_OAM_MET_GRPS_TL B
      where B.METRIC_GROUP_ID = T.METRIC_GROUP_ID
      and B.LANGUAGE = T.SOURCE_LANG)
    where (
        T.METRIC_GROUP_ID,
        T.LANGUAGE
    ) in (select
        SUBT.METRIC_GROUP_ID,
        SUBT.LANGUAGE
      from FND_OAM_MET_GRPS_TL SUBB, FND_OAM_MET_GRPS_TL SUBT
      where SUBB.METRIC_GROUP_ID = SUBT.METRIC_GROUP_ID
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and (SUBB.METRIC_GROUP_DISPLAY_NAME <> SUBT.METRIC_GROUP_DISPLAY_NAME
        or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
        or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
        or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
    ));
*/

    insert into FND_OAM_MET_GRPS_TL (
      METRIC_GROUP_ID,
      SEQUENCE,
      METRIC_GROUP_DISPLAY_NAME,
      DESCRIPTION,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) select
      B.METRIC_GROUP_ID,
      B.SEQUENCE,
      B.METRIC_GROUP_DISPLAY_NAME,
      B.DESCRIPTION,
      B.CREATED_BY,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
    from FND_OAM_MET_GRPS_TL B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    and not exists
      (select NULL
      from FND_OAM_MET_GRPS_TL T
      where T.METRIC_GROUP_ID = B.METRIC_GROUP_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);
  end ADD_LANGUAGE;

END fnd_oam_met_grps_pkg;

/
