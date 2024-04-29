--------------------------------------------------------
--  DDL for Package Body BNE_GRAPHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_GRAPHS_PKG" as
/* $Header: bnegraphb.pls 120.1 2005/08/30 03:18:46 dagroves noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAYOUT_APP_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_GRAPH_DIMENSION_CODE in VARCHAR2,
  X_GRAPH_TYPE_CODE in VARCHAR2,
  X_AUTO_GRAPH_FLAG in VARCHAR2,
  X_CHART_TITLE in VARCHAR2,
  X_X_AXIS_LABEL in VARCHAR2,
  X_Y_AXIS_LABEL in VARCHAR2,
  X_Z_AXIS_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LAST_UPDATE_DATE in DATE
) is
  cursor C is select ROWID from BNE_GRAPHS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    ;
begin
  insert into BNE_GRAPHS_B (
    APPLICATION_ID,
    INTEGRATOR_CODE,
    SEQUENCE_NUM,
    OBJECT_VERSION_NUMBER,
    LAYOUT_APP_ID,
    LAYOUT_CODE,
    GRAPH_DIMENSION_CODE,
    GRAPH_TYPE_CODE,
    AUTO_GRAPH_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE

  ) values (
    X_APPLICATION_ID,
    X_INTEGRATOR_CODE,
    X_SEQUENCE_NUM,
    X_OBJECT_VERSION_NUMBER,
    X_LAYOUT_APP_ID,
    X_LAYOUT_CODE,
    X_GRAPH_DIMENSION_CODE,
    X_GRAPH_TYPE_CODE,
    X_AUTO_GRAPH_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE
  );

  insert into BNE_GRAPHS_TL (
    APPLICATION_ID,
    INTEGRATOR_CODE,
    SEQUENCE_NUM,
    CHART_TITLE,
    X_AXIS_LABEL,
    Y_AXIS_LABEL,
    Z_AXIS_LABEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_INTEGRATOR_CODE,
    X_SEQUENCE_NUM,
    X_CHART_TITLE,
    X_X_AXIS_LABEL,
    X_Y_AXIS_LABEL,
    X_Z_AXIS_LABEL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BNE_GRAPHS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.INTEGRATOR_CODE = X_INTEGRATOR_CODE
    and T.SEQUENCE_NUM = X_SEQUENCE_NUM
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
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAYOUT_APP_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_GRAPH_DIMENSION_CODE in VARCHAR2,
  X_GRAPH_TYPE_CODE in VARCHAR2,
  X_AUTO_GRAPH_FLAG in VARCHAR2,
  X_CHART_TITLE in VARCHAR2,
  X_X_AXIS_LABEL in VARCHAR2,
  X_Y_AXIS_LABEL in VARCHAR2,
  X_Z_AXIS_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LAST_UPDATE_DATE in DATE
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      LAYOUT_APP_ID,
      LAYOUT_CODE,
      GRAPH_DIMENSION_CODE,
      GRAPH_TYPE_CODE,
      AUTO_GRAPH_FLAG
    from BNE_GRAPHS_B
    where APPLICATION_ID = X_APPLICATION_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CHART_TITLE,
      X_AXIS_LABEL,
      Y_AXIS_LABEL,
      Z_AXIS_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BNE_GRAPHS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and INTEGRATOR_CODE = X_INTEGRATOR_CODE
    and SEQUENCE_NUM = X_SEQUENCE_NUM
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
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.GRAPH_DIMENSION_CODE = X_GRAPH_DIMENSION_CODE)
           OR ((recinfo.GRAPH_DIMENSION_CODE is null) AND (X_GRAPH_DIMENSION_CODE is null)))
      AND ((recinfo.GRAPH_TYPE_CODE = X_GRAPH_TYPE_CODE)
           OR ((recinfo.GRAPH_TYPE_CODE is null) AND (X_GRAPH_TYPE_CODE is null)))
      AND ((recinfo.LAYOUT_APP_ID = X_LAYOUT_APP_ID)
           OR ((recinfo.LAYOUT_APP_ID is null) AND (X_LAYOUT_APP_ID is null)))
      AND ((recinfo.LAYOUT_CODE = X_LAYOUT_CODE)
           OR ((recinfo.LAYOUT_CODE is null) AND (X_LAYOUT_CODE is null)))
      AND ((recinfo.AUTO_GRAPH_FLAG = X_AUTO_GRAPH_FLAG)
           OR ((recinfo.AUTO_GRAPH_FLAG is null) AND (X_AUTO_GRAPH_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.CHART_TITLE = X_CHART_TITLE)
               OR ((tlinfo.CHART_TITLE is null) AND (X_CHART_TITLE is null)))
          AND ((tlinfo.X_AXIS_LABEL = X_X_AXIS_LABEL)
               OR ((tlinfo.X_AXIS_LABEL is null) AND (X_X_AXIS_LABEL is null)))
          AND ((tlinfo.Y_AXIS_LABEL = X_Y_AXIS_LABEL)
               OR ((tlinfo.Y_AXIS_LABEL is null) AND (X_Y_AXIS_LABEL is null)))
          AND ((tlinfo.Z_AXIS_LABEL = X_Z_AXIS_LABEL)
               OR ((tlinfo.Z_AXIS_LABEL is null) AND (X_Z_AXIS_LABEL is null)))
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
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAYOUT_APP_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_GRAPH_DIMENSION_CODE in VARCHAR2,
  X_GRAPH_TYPE_CODE in VARCHAR2,
  X_AUTO_GRAPH_FLAG in VARCHAR2,
  X_CHART_TITLE in VARCHAR2,
  X_X_AXIS_LABEL in VARCHAR2,
  X_Y_AXIS_LABEL in VARCHAR2,
  X_Z_AXIS_LABEL in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LAST_UPDATE_DATE in DATE
) is
begin
  update BNE_GRAPHS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAYOUT_APP_ID =  X_LAYOUT_APP_ID,
    LAYOUT_CODE =  X_LAYOUT_CODE,
    GRAPH_DIMENSION_CODE = X_GRAPH_DIMENSION_CODE,
    GRAPH_TYPE_CODE = X_GRAPH_TYPE_CODE,
    AUTO_GRAPH_FLAG = X_AUTO_GRAPH_FLAG,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BNE_GRAPHS_TL set
    CHART_TITLE =  X_CHART_TITLE,
    X_AXIS_LABEL = X_X_AXIS_LABEL,
    Y_AXIS_LABEL =  X_Y_AXIS_LABEL,
    Z_AXIS_LABEL =  X_Z_AXIS_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
) is
begin
  delete from BNE_GRAPHS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BNE_GRAPHS_B
  where APPLICATION_ID = X_APPLICATION_ID
  and INTEGRATOR_CODE = X_INTEGRATOR_CODE
  and SEQUENCE_NUM = X_SEQUENCE_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from BNE_GRAPHS_TL T
  where not exists
    (select NULL
    from BNE_GRAPHS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTEGRATOR_CODE = T.INTEGRATOR_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    );

  update BNE_GRAPHS_TL T set (
      CHART_TITLE,
      X_AXIS_LABEL,
      Y_AXIS_LABEL,
      Z_AXIS_LABEL
    ) = (select
      B.CHART_TITLE,
      B.X_AXIS_LABEL,
      B.Y_AXIS_LABEL,
      B.Z_AXIS_LABEL
    from BNE_GRAPHS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.INTEGRATOR_CODE = T.INTEGRATOR_CODE
    and B.SEQUENCE_NUM = T.SEQUENCE_NUM
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.INTEGRATOR_CODE,
      T.SEQUENCE_NUM,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.INTEGRATOR_CODE,
      SUBT.SEQUENCE_NUM,
      SUBT.LANGUAGE
    from BNE_GRAPHS_TL SUBB, BNE_GRAPHS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.INTEGRATOR_CODE = SUBT.INTEGRATOR_CODE
    and SUBB.SEQUENCE_NUM = SUBT.SEQUENCE_NUM
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and  (SUBB.CHART_TITLE <> SUBT.CHART_TITLE
      or (SUBB.CHART_TITLE is null and SUBT.CHART_TITLE is not null)
      or (SUBB.CHART_TITLE is not null and SUBT.CHART_TITLE is null)
      or SUBB.X_AXIS_LABEL <> SUBT.X_AXIS_LABEL
      or (SUBB.X_AXIS_LABEL is null and SUBT.X_AXIS_LABEL is not null)
      or (SUBB.X_AXIS_LABEL is not null and SUBT.X_AXIS_LABEL is null)
      or SUBB.Y_AXIS_LABEL <> SUBT.Y_AXIS_LABEL
      or (SUBB.Y_AXIS_LABEL is null and SUBT.Y_AXIS_LABEL is not null)
      or (SUBB.Y_AXIS_LABEL is not null and SUBT.Y_AXIS_LABEL is null)
      or SUBB.Z_AXIS_LABEL <> SUBT.Z_AXIS_LABEL
      or (SUBB.Z_AXIS_LABEL is null and SUBT.Z_AXIS_LABEL is not null)
      or (SUBB.Z_AXIS_LABEL is not null and SUBT.Z_AXIS_LABEL is null)
  ));

  insert into BNE_GRAPHS_TL (
    APPLICATION_ID,
    INTEGRATOR_CODE,
    SEQUENCE_NUM,
    CHART_TITLE,
    X_AXIS_LABEL,
    Y_AXIS_LABEL,
    Z_AXIS_LABEL,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.INTEGRATOR_CODE,
    B.SEQUENCE_NUM,
    B.CHART_TITLE,
    B.X_AXIS_LABEL,
    B.Y_AXIS_LABEL,
    B.Z_AXIS_LABEL,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BNE_GRAPHS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BNE_GRAPHS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.INTEGRATOR_CODE = B.INTEGRATOR_CODE
    and T.SEQUENCE_NUM = B.SEQUENCE_NUM
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--------------------------------------------------------------------------------
--  PROCEDURE:   TRANSLATE_ROW                                                --
--                                                                            --
--  DESCRIPTION: Load a translation into the BNE_GRAPHS entity.               --
--               This proc is called from the apps loader.                    --
--                                                                            --
--  SEE:   http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt         --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  2-Aug-05   PACROSS   CREATED                                              --
--------------------------------------------------------------------------------
procedure TRANSLATE_ROW(
  x_integrator_asn        in VARCHAR2,
  x_integrator_code       in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_chart_title           in VARCHAR2,
  x_x_axis_label          in VARCHAR2,
  x_y_axis_label          in VARCHAR2,
  x_z_axis_label          in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
)
is
  l_app_id          number;
  f_luby            number;  -- entity owner in file
  f_ludate          date;    -- entity update date in file
  db_luby           number;  -- entity owner in db
  db_ludate         date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id        := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_GRAPHS_TL
    where APPLICATION_ID      = l_app_id
    and   INTEGRATOR_CODE     = x_integrator_code
    and   SEQUENCE_NUM        = x_sequence_num
    and   LANGUAGE            = userenv('LANG');

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then

      update BNE_GRAPHS_TL
      set CHART_TITLE  = x_chart_title,
          X_AXIS_LABEL = x_x_axis_label,
          Y_AXIS_LABEL = x_y_axis_label,
          Z_AXIS_LABEL = x_z_axis_label,
          LAST_UPDATE_DATE  = f_ludate,
          LAST_UPDATED_BY   = f_luby,
          LAST_UPDATE_LOGIN = 0,
          SOURCE_LANG       = userenv('LANG')
      where APPLICATION_ID      = l_app_id
      AND   INTEGRATOR_CODE     = x_integrator_code
      AND   SEQUENCE_NUM        = x_sequence_num
      AND   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      ;
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;


--------------------------------------------------------------------------------
--  PROCEDURE:     LOAD_ROW                                                   --
--                                                                            --
--  DESCRIPTION:   Load a row into the BNE_GRAPHS entity.                     --
--                 This proc is called from the apps loader.                  --
--                                                                            --
--  SEE:     http://www-apps.us.oracle.com/atg/plans/r115/fndloadqr.txt       --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  2-Aug-05   PACROSS   CREATED                                              --
--------------------------------------------------------------------------------
procedure LOAD_ROW(
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_layout_asn                  in VARCHAR2,
  x_layout_code                 in VARCHAR2,
  x_graph_dimension_code        in VARCHAR2,
  x_graph_type_code             in VARCHAR2,
  x_auto_graph_flag             in VARCHAR2,
  x_chart_title                 in VARCHAR2,
  x_x_axis_label                in VARCHAR2,
  x_y_axis_label                in VARCHAR2,
  x_z_axis_label                in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_custom_mode                 in VARCHAR2)
is
  l_app_id                    number;
  l_layout_app_id             number;
  l_row_id                    varchar2(64);
  f_luby                      number;  -- entity owner in file
  f_ludate                    date;    -- entity update date in file
  db_luby                     number;  -- entity owner in db
  db_ludate                   date;    -- entity update date in db
begin
  -- translate values to IDs
  l_app_id          := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_integrator_asn);
  l_layout_app_id   := BNE_LCT_TOOLS_PKG.ASN_TO_APP_ID(x_layout_asn);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);
  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from BNE_GRAPHS_B
    where APPLICATION_ID  = l_app_id
    and   INTEGRATOR_CODE = x_integrator_code
    and   SEQUENCE_NUM = x_sequence_num;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, x_custom_mode)) then
      -- Update existing row
      BNE_GRAPHS_PKG.Update_Row(
        X_APPLICATION_ID        => l_app_id,
        X_INTEGRATOR_CODE       => x_integrator_code,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_LAYOUT_APP_ID         => l_layout_app_id,
        X_LAYOUT_CODE           => x_layout_code,
        X_GRAPH_DIMENSION_CODE  => x_graph_dimension_code,
        X_GRAPH_TYPE_CODE       => x_graph_type_code,
        X_AUTO_GRAPH_FLAG       => x_auto_graph_flag,
        X_CHART_TITLE           => x_chart_title,
        X_X_AXIS_LABEL          => x_x_axis_label,
        X_Y_AXIS_LABEL          => x_y_axis_label,
        X_Z_AXIS_LABEL          => x_z_axis_label,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0,
        X_LAST_UPDATE_DATE      => f_ludate
      );

    end if;
  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
      BNE_GRAPHS_PKG.Insert_Row(
        X_ROWID                 => l_row_id,
        X_APPLICATION_ID        => l_app_id,
        X_INTEGRATOR_CODE       => x_integrator_code,
        X_SEQUENCE_NUM          => x_sequence_num,
        X_OBJECT_VERSION_NUMBER => x_object_version_number,
        X_LAYOUT_APP_ID         => l_layout_app_id,
        X_LAYOUT_CODE           => x_layout_code,
        X_GRAPH_DIMENSION_CODE  => x_graph_dimension_code,
        X_GRAPH_TYPE_CODE       => x_graph_type_code,
        X_AUTO_GRAPH_FLAG       => x_auto_graph_flag,
        X_CHART_TITLE           => x_chart_title,
        X_X_AXIS_LABEL          => x_x_axis_label,
        X_Y_AXIS_LABEL          => x_y_axis_label,
        X_Z_AXIS_LABEL          => x_z_axis_label,
        X_CREATION_DATE         => f_ludate,
        X_CREATED_BY            => f_luby,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0,
        X_LAST_UPDATE_DATE      => f_ludate
      );
  end;
end LOAD_ROW;


end BNE_GRAPHS_PKG;

/
