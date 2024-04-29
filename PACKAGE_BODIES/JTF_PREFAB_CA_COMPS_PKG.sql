--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_CA_COMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_CA_COMPS_PKG" as
/* $Header: jtfprecacomptb.pls 120.8.12000000.5 2007/07/27 08:35:51 amaddula ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CA_COMP_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_COMP_NAME in VARCHAR2,
  X_COMPONENT_KEY in VARCHAR2,
  X_LOADER_CLASS_NAME in VARCHAR2,
  X_TIMEOUT_TYPE in VARCHAR2,
  X_TIMEOUT in NUMBER,
  X_TIMEOUT_UNIT in VARCHAR2,
  X_SGID_ENABLED_FLAG in VARCHAR2,
  X_STAT_ENABLED_FLAG in VARCHAR2,
  X_DISTRIBUTED_FLAG in VARCHAR2,
  X_CACHE_GENERIC_FLAG in VARCHAR2,
  X_BUSINESS_EVENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
	l_ca_comp_id  NUMBER;
--  cursor C is select ROWID from JTF_PREFAB_CA_COMPS_B
--    where CA_COMP_ID = X_CA_COMP_ID;
begin
  -- The following select is required as we are referring the X_CA_COMP_ID in
  -- two insert statements and calling JTF.CA_COMP_ID_SEQ.nextval twice will return two different values.
  select JTF.CA_COMP_ID_SEQ.nextval into l_ca_comp_id from dual;
  insert into JTF_PREFAB_CA_COMPS_B (
    -- SECURITY_GROUP_ID,
    APPLICATION_ID,
    COMP_NAME,
    COMPONENT_KEY,
    LOADER_CLASS_NAME,
    TIMEOUT_TYPE,
    TIMEOUT,
    TIMEOUT_UNIT,
    SGID_ENABLED_FLAG,
    STAT_ENABLED_FLAG,
    DISTRIBUTED_FLAG,
    CACHE_GENERIC_FLAG,
    BUSINESS_EVENT_NAME,
    CA_COMP_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    -- X_SECURITY_GROUP_ID,
    X_APPLICATION_ID,
    X_COMP_NAME,
    X_COMPONENT_KEY,
    X_LOADER_CLASS_NAME,
    X_TIMEOUT_TYPE,
    X_TIMEOUT,
    X_TIMEOUT_UNIT,
    X_SGID_ENABLED_FLAG,
    X_STAT_ENABLED_FLAG,
    X_DISTRIBUTED_FLAG,
    X_CACHE_GENERIC_FLAG,
    X_BUSINESS_EVENT_NAME,
--    X_CA_COMP_ID,
    l_ca_comp_id,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PREFAB_CA_COMPS_TL (
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    CA_COMP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    -- X_SECURITY_GROUP_ID,
    --X_CA_COMP_ID,
    l_ca_comp_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PREFAB_CA_COMPS_TL T
    where T.CA_COMP_ID = l_ca_comp_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

--  open c;
--  fetch c into X_ROWID;
--  if (c%notfound) then
--    close c;
--    raise no_data_found;
--  end if;
--  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CA_COMP_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_COMP_NAME in VARCHAR2,
  X_COMPONENT_KEY in VARCHAR2,
  X_LOADER_CLASS_NAME in VARCHAR2,
  X_TIMEOUT_TYPE in VARCHAR2,
  X_TIMEOUT in NUMBER,
  X_TIMEOUT_UNIT in VARCHAR2,
  X_SGID_ENABLED_FLAG in VARCHAR2,
  X_STAT_ENABLED_FLAG in VARCHAR2,
  X_DISTRIBUTED_FLAG in VARCHAR2,
  X_CACHE_GENERIC_FLAG in VARCHAR2,
  X_BUSINESS_EVENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_ID,
      APPLICATION_ID,
      COMP_NAME,
      COMPONENT_KEY,
      LOADER_CLASS_NAME,
      TIMEOUT_TYPE,
      TIMEOUT,
      TIMEOUT_UNIT,
      SGID_ENABLED_FLAG,
      STAT_ENABLED_FLAG,
      DISTRIBUTED_FLAG,
      CACHE_GENERIC_FLAG,
      BUSINESS_EVENT_NAME,
      OBJECT_VERSION_NUMBER
    from JTF_PREFAB_CA_COMPS_B
    where CA_COMP_ID = X_CA_COMP_ID
    for update of CA_COMP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PREFAB_CA_COMPS_TL
    where CA_COMP_ID = X_CA_COMP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CA_COMP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
      (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      -- AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
      --     OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.COMP_NAME = X_COMP_NAME)
      AND (recinfo.COMPONENT_KEY = X_COMPONENT_KEY)
      AND (recinfo.LOADER_CLASS_NAME = X_LOADER_CLASS_NAME)
      AND (recinfo.TIMEOUT_TYPE = X_TIMEOUT_TYPE)
      AND (recinfo.TIMEOUT = X_TIMEOUT)
      AND (recinfo.TIMEOUT_UNIT = X_TIMEOUT_UNIT)
      AND (recinfo.SGID_ENABLED_FLAG = X_SGID_ENABLED_FLAG)
      AND (recinfo.STAT_ENABLED_FLAG = X_STAT_ENABLED_FLAG)
      AND (recinfo.DISTRIBUTED_FLAG = X_DISTRIBUTED_FLAG)
      AND (recinfo.CACHE_GENERIC_FLAG = X_CACHE_GENERIC_FLAG)
      AND (recinfo.BUSINESS_EVENT_NAME = X_BUSINESS_EVENT_NAME)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_CA_COMP_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_COMP_NAME in VARCHAR2,
  X_COMPONENT_KEY in VARCHAR2,
  X_LOADER_CLASS_NAME in VARCHAR2,
  X_TIMEOUT_TYPE in VARCHAR2,
  X_TIMEOUT in NUMBER,
  X_TIMEOUT_UNIT in VARCHAR2,
  X_SGID_ENABLED_FLAG in VARCHAR2,
  X_STAT_ENABLED_FLAG in VARCHAR2,
  X_DISTRIBUTED_FLAG in VARCHAR2,
  X_CACHE_GENERIC_FLAG in VARCHAR2,
  X_BUSINESS_EVENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PREFAB_CA_COMPS_B set
    -- SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    APPLICATION_ID = X_APPLICATION_ID,
    COMP_NAME = X_COMP_NAME,
    COMPONENT_KEY = X_COMPONENT_KEY,
    LOADER_CLASS_NAME = X_LOADER_CLASS_NAME,
    TIMEOUT_TYPE = X_TIMEOUT_TYPE,
    TIMEOUT = X_TIMEOUT,
    TIMEOUT_UNIT = X_TIMEOUT_UNIT,
    SGID_ENABLED_FLAG = X_SGID_ENABLED_FLAG,
    STAT_ENABLED_FLAG = X_STAT_ENABLED_FLAG,
    DISTRIBUTED_FLAG = X_DISTRIBUTED_FLAG,
    CACHE_GENERIC_FLAG = X_CACHE_GENERIC_FLAG,
    BUSINESS_EVENT_NAME = X_BUSINESS_EVENT_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CA_COMP_ID = X_CA_COMP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PREFAB_CA_COMPS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CA_COMP_ID = X_CA_COMP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

--  Customized cached seed-data have last_updated_by column as -1.
--  To apply patches on them, modify the last_updated_by column to -1

procedure UPDATE_ROW_1 (
  X_CA_COMP_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER
) is
begin
  update JTF_PREFAB_CA_COMPS_B set
    LAST_UPDATED_BY = X_LAST_UPDATED_BY
  where CA_COMP_ID = X_CA_COMP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW_1;

procedure DELETE_ROW (
  X_CA_COMP_ID in NUMBER
) is
begin
  delete from JTF_PREFAB_CA_COMPS_TL
  where CA_COMP_ID = X_CA_COMP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PREFAB_CA_COMPS_B
  where CA_COMP_ID = X_CA_COMP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PREFAB_CA_COMPS_TL T
  where not exists
    (select NULL
    from JTF_PREFAB_CA_COMPS_B B
    where B.CA_COMP_ID = T.CA_COMP_ID
    );

  update JTF_PREFAB_CA_COMPS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from JTF_PREFAB_CA_COMPS_TL B
    where B.CA_COMP_ID = T.CA_COMP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CA_COMP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CA_COMP_ID,
      SUBT.LANGUAGE
    from JTF_PREFAB_CA_COMPS_TL SUBB, JTF_PREFAB_CA_COMPS_TL SUBT
    where SUBB.CA_COMP_ID = SUBT.CA_COMP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into JTF_PREFAB_CA_COMPS_TL (
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    CA_COMP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    -- B.SECURITY_GROUP_ID,
    B.CA_COMP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PREFAB_CA_COMPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PREFAB_CA_COMPS_TL T
    where T.CA_COMP_ID = B.CA_COMP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_COMP_NAME in VARCHAR2,
  X_COMPONENT_KEY in VARCHAR2,
  X_LOADER_CLASS_NAME in VARCHAR2,
  X_TIMEOUT_TYPE in VARCHAR2,
  X_TIMEOUT in NUMBER,
  X_TIMEOUT_UNIT in VARCHAR2,
  X_SGID_ENABLED_FLAG in VARCHAR2,
  X_STAT_ENABLED_FLAG in VARCHAR2,
  X_DISTRIBUTED_FLAG in VARCHAR2,
  X_CACHE_GENERIC_FLAG in VARCHAR2,
  X_BUSINESS_EVENT_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
	l_row_id  VARCHAR2(255);
 	f_luby  NUMBER;
 	f_ludate  DATE;
 	db_luby NUMBER;
 	db_ludate DATE;
	l_ca_comp_id  NUMBER;
  l_host_app_id NUMBER;

--	cursor c is select nvl(max(CA_COMP_ID), 0) from jtf_prefab_ca_comps_b where CA_COMP_ID < 10000;
--	cursor c_ha is select nvl(max(HA_COMP_ID), 0) from jtf_prefab_ha_comps where HA_COMP_ID < 10000;
	l_pseudo_seq  NUMBER := NULL;
  l_pseudo_seq_ha NUMBER := NULL;

  CURSOR host_apps_cursor IS
  SELECT host_app_id
  FROM jtf_prefab_host_apps
  WHERE application_id = X_APPLICATION_ID;

  CURSOR host_apps_cursor_gen IS
  SELECT host_app_id
  FROM jtf_prefab_host_apps
  WHERE application_id = -1;

  begin
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(X_OWNER);

    -- Translate char last_update_date to date
    f_ludate := X_LAST_UPDATE_DATE;


    begin
 	    SELECT CA_COMP_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
	    INTO l_ca_comp_id, db_luby, db_ludate
	    FROM JTF_PREFAB_CA_COMPS_B
	    WHERE APPLICATION_ID = X_APPLICATION_ID AND
		  COMPONENT_KEY = X_COMPONENT_KEY;

	    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE)) then
	      -- **** call Update row ****
        JTF_PREFAB_CA_COMPS_PKG.UPDATE_ROW (
          X_CA_COMP_ID                 =>    l_ca_comp_id,
          X_SECURITY_GROUP_ID          =>    X_SECURITY_GROUP_ID,
          X_APPLICATION_ID             =>    X_APPLICATION_ID,
          X_COMP_NAME                  =>    X_COMP_NAME,
          X_COMPONENT_KEY              =>    X_COMPONENT_KEY,
          X_LOADER_CLASS_NAME          =>    X_LOADER_CLASS_NAME,
          X_TIMEOUT_TYPE               =>    X_TIMEOUT_TYPE,
          X_TIMEOUT                    =>    X_TIMEOUT,
          X_TIMEOUT_UNIT               =>    X_TIMEOUT_UNIT,
          X_SGID_ENABLED_FLAG          =>    X_SGID_ENABLED_FLAG,
          X_STAT_ENABLED_FLAG          =>    X_STAT_ENABLED_FLAG,
          X_DISTRIBUTED_FLAG           =>    X_DISTRIBUTED_FLAG,
          X_CACHE_GENERIC_FLAG         =>    X_CACHE_GENERIC_FLAG,
          X_BUSINESS_EVENT_NAME        =>    X_BUSINESS_EVENT_NAME,
          X_OBJECT_VERSION_NUMBER      =>    X_OBJECT_VERSION_NUMBER,
          X_DESCRIPTION                =>    X_DESCRIPTION,
          X_LAST_UPDATE_DATE           =>    f_ludate,
          X_LAST_UPDATED_BY            =>    f_luby,
          X_LAST_UPDATE_LOGIN          =>    0);
        end if;
      exception
  	   when no_data_found then
	      -- **** generate pseudo sequence ***
--	      OPEN c;
--	      FETCH c INTO l_pseudo_seq;
--        CLOSE c;

-- this is just to pass some integer number to the insert_row proc.
-- in the insert_row proc we replace this value with the JTF.CA_COMP_ID_SEQ.nextval/JTF.CA_COMP_ID_SEQ.currval wherever required
-- so this value is just a dummy value
        l_pseudo_seq := 1;
        JTF_PREFAB_CA_COMPS_PKG.INSERT_ROW (
          X_ROWID                       =>   l_row_id,
          X_CA_COMP_ID                  =>   l_pseudo_seq,
          X_SECURITY_GROUP_ID           =>   X_SECURITY_GROUP_ID,
          X_APPLICATION_ID              =>   X_APPLICATION_ID,
          X_COMP_NAME                   =>   X_COMP_NAME,
          X_COMPONENT_KEY               =>   X_COMPONENT_KEY,
          X_LOADER_CLASS_NAME           =>   X_LOADER_CLASS_NAME,
          X_TIMEOUT_TYPE                =>   X_TIMEOUT_TYPE,
          X_TIMEOUT                     =>   X_TIMEOUT,
          X_TIMEOUT_UNIT                =>   X_TIMEOUT_UNIT,
          X_SGID_ENABLED_FLAG           =>   X_SGID_ENABLED_FLAG,
          X_STAT_ENABLED_FLAG           =>   X_STAT_ENABLED_FLAG,
          X_DISTRIBUTED_FLAG            =>   X_DISTRIBUTED_FLAG,
          X_CACHE_GENERIC_FLAG          =>   X_CACHE_GENERIC_FLAG,
          X_BUSINESS_EVENT_NAME         =>   X_BUSINESS_EVENT_NAME,
          X_OBJECT_VERSION_NUMBER       =>   X_OBJECT_VERSION_NUMBER,
          X_DESCRIPTION                 =>   X_DESCRIPTION,
          X_CREATION_DATE               =>   f_ludate,
          X_CREATED_BY                  =>   f_luby,
          X_LAST_UPDATE_DATE            =>   f_ludate,
          X_LAST_UPDATED_BY             =>   f_luby,
          X_LAST_UPDATE_LOGIN           =>   0);

        -- for each application/host pair that the filter belongs to,
              -- add a row to ha_filters
--        OPEN c_ha;
--	      FETCH c_ha INTO l_pseudo_seq_ha;
--	      CLOSE c_ha;

        IF X_CACHE_GENERIC_FLAG = 'f' THEN
          OPEN host_apps_cursor;
          FETCH host_apps_cursor INTO l_host_app_id;

          WHILE host_apps_cursor%FOUND LOOP
          -- we are inserting into only one table so get the value from JTF.HA_COMP_ID_SEQ
          -- l_pseudo_seq_ha := l_pseudo_seq_ha + 1;
            INSERT INTO jtf_prefab_ha_comps (ha_comp_id,
                                             object_version_number,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_date,
                                             last_update_login,
                                             -- security_group_id,
                                             host_app_id,
                                             ca_comp_id,
                                             cache_policy,
                                             cache_clear_flag,
                                             cache_reload_flag)
              VALUES (JTF.HA_COMP_ID_SEQ.nextval,
                      X_OBJECT_VERSION_NUMBER,
                      f_luby,
                      f_ludate,
                      f_luby,
                      f_ludate,
                      0,
                      -- NULL,
                      l_host_app_id,
                      --as we have already inserted comp_id value into JTF_PREFAB_CA_COMPS_B table
                      JTF.CA_COMP_ID_SEQ.currval,
--                      l_pseudo_seq,
                      'CO',
                      'f',
                      'f');
              FETCH host_apps_cursor INTO l_host_app_id;
            END LOOP;
            CLOSE host_apps_cursor;
          END IF;

          IF X_CACHE_GENERIC_FLAG = 't' THEN
            OPEN host_apps_cursor_gen;
            FETCH host_apps_cursor_gen INTO l_host_app_id;

            WHILE host_apps_cursor_gen%FOUND LOOP
            -- we are inserting into only one table so get the value from JTF.HA_COMP_ID_SEQ
            -- l_pseudo_seq_ha := l_pseudo_seq_ha + 1;
              INSERT INTO jtf_prefab_ha_comps (ha_comp_id,
                                               object_version_number,
                                               created_by,
                                               creation_date,
                                               last_updated_by,
                                               last_update_date,
                                               last_update_login,
                                               -- security_group_id,
                                               host_app_id,
                                               ca_comp_id,
                                               cache_policy,
                                               cache_clear_flag,
                                               cache_reload_flag)
              VALUES (JTF.HA_COMP_ID_SEQ.nextval,
                      X_OBJECT_VERSION_NUMBER,
                      f_luby,
                      f_ludate,
                      f_luby,
                      f_ludate,
                      0,
                      -- NULL,
                      l_host_app_id,
                      --as we have already inserted comp_id value into JTF_PREFAB_CA_COMPS_B table
                      JTF.CA_COMP_ID_SEQ.currval,
--                      l_pseudo_seq,
                      'CO',
                      'f',
                      'f');
              FETCH host_apps_cursor_gen INTO l_host_app_id;
            END LOOP;
            CLOSE host_apps_cursor_gen;
          END IF;
      end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_COMPONENT_KEY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
    -- **** local variables *****
    f_luby		NUMBER;
    f_ludate    	DATE;
    db_luby		NUMBER;
    db_ludate		DATE;
    l_ca_comp_id        NUMBER;
begin

  f_luby := fnd_load_util.owner_id(X_OWNER);

  f_ludate := X_LAST_UPDATE_DATE;

  begin
      SELECT tl.CA_COMP_ID, tl.LAST_UPDATED_BY, tl.LAST_UPDATE_DATE
      INTO l_ca_comp_id, db_luby, db_ludate
      FROM JTF_PREFAB_CA_COMPS_B b, JTF_PREFAB_CA_COMPS_TL tl
      WHERE b.CA_COMP_ID = tl.CA_COMP_ID AND
            b.APPLICATION_ID = X_APPLICATION_ID AND
            b.COMPONENT_KEY = X_COMPONENT_KEY AND
            tl.LANGUAGE = userenv('LANG');

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE))
      then
          update JTF_PREFAB_CA_COMPS_TL set
            DESCRIPTION = nvl(X_DESCRIPTION, DESCRIPTION),
            LAST_UPDATE_DATE = f_ludate,
            LAST_UPDATED_BY = f_luby,
            LAST_UPDATE_LOGIN = 0,
            SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
	          CA_COMP_ID = l_ca_comp_id;
      end if;
   exception
	when no_data_found then null;
   end;
end TRANSLATE_ROW;

end JTF_PREFAB_CA_COMPS_PKG;

/
