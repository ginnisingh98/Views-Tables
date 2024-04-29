--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_CA_FILTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_CA_FILTERS_PKG" as
/* $Header: jtfprecafiltertb.pls 120.1.12000000.3 2007/07/13 06:56:18 amaddula ship $ */
procedure INSERT_ROW (
  X_CA_FILTER_ID in NUMBER,
  X_CA_FILTER_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into JTF_PREFAB_CA_FILTERS_B (
    CA_FILTER_NAME,
    APPLICATION_ID,
    -- SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    CA_FILTER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CA_FILTER_NAME,
    X_APPLICATION_ID,
    -- X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CA_FILTER_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PREFAB_CA_FILTERS_TL (
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    CA_FILTER_ID,
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
    X_CA_FILTER_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PREFAB_CA_FILTERS_TL T
    where T.CA_FILTER_ID = X_CA_FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure LOCK_ROW (
  X_CA_FILTER_ID in NUMBER,
  X_CA_FILTER_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CA_FILTER_NAME,
      APPLICATION_ID,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from JTF_PREFAB_CA_FILTERS_B
    where CA_FILTER_ID = X_CA_FILTER_ID
    for update of CA_FILTER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PREFAB_CA_FILTERS_TL
    where CA_FILTER_ID = X_CA_FILTER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CA_FILTER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CA_FILTER_NAME = X_CA_FILTER_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      -- AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
      --     OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
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
  X_CA_FILTER_ID in NUMBER,
  X_CA_FILTER_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PREFAB_CA_FILTERS_B set
    CA_FILTER_NAME = X_CA_FILTER_NAME,
    APPLICATION_ID = X_APPLICATION_ID,
    -- SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CA_FILTER_ID = X_CA_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PREFAB_CA_FILTERS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CA_FILTER_ID = X_CA_FILTER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CA_FILTER_ID in NUMBER
) is
begin
  delete from JTF_PREFAB_CA_FILTERS_TL
  where CA_FILTER_ID = X_CA_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PREFAB_CA_FILTERS_B
  where CA_FILTER_ID = X_CA_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PREFAB_CA_FILTERS_TL T
  where not exists
    (select NULL
    from JTF_PREFAB_CA_FILTERS_B B
    where B.CA_FILTER_ID = T.CA_FILTER_ID
    );

  update JTF_PREFAB_CA_FILTERS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from JTF_PREFAB_CA_FILTERS_TL B
    where B.CA_FILTER_ID = T.CA_FILTER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CA_FILTER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CA_FILTER_ID,
      SUBT.LANGUAGE
    from JTF_PREFAB_CA_FILTERS_TL SUBB, JTF_PREFAB_CA_FILTERS_TL SUBT
    where SUBB.CA_FILTER_ID = SUBT.CA_FILTER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into JTF_PREFAB_CA_FILTERS_TL (
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    CA_FILTER_ID,
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
    B.CA_FILTER_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PREFAB_CA_FILTERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PREFAB_CA_FILTERS_TL T
    where T.CA_FILTER_ID = B.CA_FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_CA_FILTER_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
   	l_ca_filter_id  NUMBER;
   	l_host_app_id   NUMBER;

	cursor c is select nvl(max(CA_FILTER_ID), 0) from jtf_prefab_ca_filters_b where CA_FILTER_ID < 10000;
	cursor c_ha is select nvl(max(HA_FILTER_ID), 0) from jtf_prefab_ha_filters where HA_FILTER_ID < 10000;
	l_pseudo_seq	       NUMBER := NULL;
	l_pseudo_seq_ha	       NUMBER := NULL;

        CURSOR host_apps_cursor IS
          SELECT host_app_id
          FROM jtf_prefab_host_apps
          WHERE application_id = X_APPLICATION_ID;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT CA_FILTER_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
	  INTO l_ca_filter_id, db_luby, db_ludate
	  FROM JTF_PREFAB_CA_FILTERS_B
	  WHERE APPLICATION_ID = X_APPLICATION_ID AND
                CA_FILTER_NAME = X_CA_FILTER_NAME;

	  -- **** Entry is there, check if it's legal to update ****
	  IF ((X_CUSTOM_MODE = 'FORCE') OR
              ((f_luby = 0) AND (db_luby = 1)) OR
              ((f_luby = db_luby) AND (f_ludate > db_ludate))
             )
	  then
	      -- **** call Update row ****
              JTF_PREFAB_CA_FILTERS_PKG.UPDATE_ROW (
                  X_CA_FILTER_ID               =>   l_ca_filter_id,
                  X_CA_FILTER_NAME             =>   X_CA_FILTER_NAME,
                  X_APPLICATION_ID             =>   X_APPLICATION_ID,
                  X_SECURITY_GROUP_ID          =>   X_SECURITY_GROUP_ID,
                  X_OBJECT_VERSION_NUMBER      =>   X_OBJECT_VERSION_NUMBER,
                  X_DESCRIPTION                =>   X_DESCRIPTION,
                  X_LAST_UPDATE_DATE           =>   f_ludate,
                  X_LAST_UPDATED_BY            =>   f_luby,
                  X_LAST_UPDATE_LOGIN          =>   0);

              -- **** delete all the child entries ****
              DELETE FROM jtf_prefab_ca_fl_resps
              WHERE ca_filter_id = l_ca_filter_id;

              DELETE FROM jtf_prefab_ca_fl_langs
              WHERE ca_filter_id = l_ca_filter_id;
           end if;
      exception
  	   when no_data_found then
	      -- **** generate pseudo sequence ***
	      OPEN c;
	      FETCH c INTO l_pseudo_seq;
	      CLOSE c;

              l_pseudo_seq := l_pseudo_seq + 1;

              JTF_PREFAB_CA_FILTERS_PKG.INSERT_ROW (
                  X_CA_FILTER_ID                =>   l_pseudo_seq,
                  X_CA_FILTER_NAME              =>   X_CA_FILTER_NAME,
                  X_APPLICATION_ID              =>   X_APPLICATION_ID,
                  X_SECURITY_GROUP_ID           =>   X_SECURITY_GROUP_ID,
                  X_OBJECT_VERSION_NUMBER       =>   X_OBJECT_VERSION_NUMBER,
                  X_DESCRIPTION                 =>   X_DESCRIPTION,
                  X_CREATION_DATE               =>   f_ludate,
                  X_CREATED_BY                  =>   f_luby,
                  X_LAST_UPDATE_DATE            =>   f_ludate,
                  X_LAST_UPDATED_BY             =>   f_luby,
                  X_LAST_UPDATE_LOGIN           =>   0);

              -- for each application/host pair that the filter belongs to,
              -- add a row to ha_filters
	      OPEN c_ha;
	      FETCH c_ha INTO l_pseudo_seq_ha;
	      CLOSE c_ha;

              OPEN host_apps_cursor;
              FETCH host_apps_cursor INTO l_host_app_id;

              WHILE host_apps_cursor%FOUND LOOP
                l_pseudo_seq_ha := l_pseudo_seq_ha + 1;

                INSERT INTO jtf_prefab_ha_filters (ha_filter_id,
                                                   object_version_number,
                                                   created_by,
                                                   creation_date,
                                                   last_updated_by,
                                                   last_update_date,
                                                   last_update_login,
                                                   -- security_group_id,
                                                   host_app_id,
                                                   ca_filter_id,
                                                   cache_filter_enabled_flag)
                VALUES (l_pseudo_seq_ha,
                        X_OBJECT_VERSION_NUMBER,
                        f_luby,
                        f_ludate,
                        f_luby,
                        f_ludate,
                        0,
                        -- X_SECURITY_GROUP_ID,
                        l_host_app_id,
                        l_pseudo_seq,
                        't');
                FETCH host_apps_cursor INTO l_host_app_id;
              END LOOP;

              CLOSE host_apps_cursor;
      end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_CA_FILTER_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
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
    l_ca_filter_id      NUMBER;
begin

  if (X_OWNER = 'SEED') then
     f_luby := 1;
  else
     f_luby := 0;
  end if;

  f_ludate := X_LAST_UPDATE_DATE;

  begin
      SELECT tl.CA_FILTER_ID, tl.LAST_UPDATED_BY, tl.LAST_UPDATE_DATE
      INTO l_ca_filter_id, db_luby, db_ludate
      FROM JTF_PREFAB_CA_FILTERS_B b, JTF_PREFAB_CA_FILTERS_TL tl
      WHERE b.CA_FILTER_ID = tl.CA_FILTER_ID AND
            b.APPLICATION_ID = X_APPLICATION_ID AND
            b.CA_FILTER_NAME = X_CA_FILTER_NAME AND
            tl.LANGUAGE = userenv('LANG');

      if ((X_CUSTOM_MODE = 'FORCE') OR
          ((f_luby = 0) AND (db_luby = 1)) OR
          ((f_luby = db_luby) AND (f_ludate >= db_ludate))
         )
      then
          update JTF_PREFAB_CA_FILTERS_TL set
            DESCRIPTION = nvl(X_DESCRIPTION, DESCRIPTION),
	    LAST_UPDATE_DATE = f_ludate,
	    LAST_UPDATED_BY = f_luby,
	    LAST_UPDATE_LOGIN = 0,
	    SOURCE_LANG = userenv('LANG')
          where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
	        CA_FILTER_ID = l_ca_filter_id;
      end if;
   exception
	when no_data_found then null;
   end;
end TRANSLATE_ROW;

procedure LOAD_RESP_ROW (
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_CA_FILTER_NAME in VARCHAR2,
  X_RESPONSIBILITY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
   	l_ca_filter_id  NUMBER;

	cursor c is select nvl(max(CA_FL_RESP_ID), 0) from jtf_prefab_ca_fl_resps where CA_FL_RESP_ID < 10000;
	l_pseudo_seq	       NUMBER := NULL;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT child.LAST_UPDATED_BY, child.LAST_UPDATE_DATE
	  INTO db_luby, db_ludate
	  FROM JTF_PREFAB_CA_FL_RESPS child, JTF_PREFAB_CA_FILTERS_B parent
	  WHERE child.ca_filter_id = parent.ca_filter_id
          AND  parent.APPLICATION_ID = X_APPLICATION_ID
	  AND  parent.CA_FILTER_NAME = X_CA_FILTER_NAME
          AND  child.RESPONSIBILITY_ID = X_RESPONSIBILITY_ID;

          /*
	  -- **** Entry is there, check if it's legal to update ****
	  IF ((X_CUSTOM_MODE = 'FORCE') OR
              ((f_luby = 0) AND (db_luby = 1)) OR
              ((f_luby = db_luby) AND (f_ludate > db_ludate))
             )
	  then
	      -- **** do nothing ****
          end if;
           */
      exception
  	   when no_data_found then
	      -- **** generate pseudo sequence ***
	      OPEN c;
	      FETCH c INTO l_pseudo_seq;
	      CLOSE c;

              l_pseudo_seq := l_pseudo_seq + 1;

	      -- **** get ca_filter_id ***
              SELECT CA_FILTER_ID
              INTO l_ca_filter_id
              FROM JTF_PREFAB_CA_FILTERS_B
              WHERE APPLICATION_ID = X_APPLICATION_ID
              AND   CA_FILTER_NAME = X_CA_FILTER_NAME;

              INSERT INTO jtf_prefab_ca_fl_resps(ca_fl_resp_id,
                                                 object_version_number,
                                                 created_by,
                                                 creation_date,
                                                 last_updated_by,
                                                 last_update_date,
                                                 last_update_login,
                                                 -- security_group_id,
                                                 ca_filter_id,
                                                 responsibility_id)
              VALUES (l_pseudo_seq,
                      X_OBJECT_VERSION_NUMBER,
                      f_luby,
                      f_ludate,
                      f_luby,
                      f_ludate,
                      0,
                      -- NULL,
                      l_ca_filter_id,
                      X_RESPONSIBILITY_ID);
      end;

end LOAD_RESP_ROW;

procedure LOAD_LANG_ROW (
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_CA_FILTER_NAME in VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
   	l_ca_filter_id  NUMBER;

	cursor c is select nvl(max(CA_FL_LANG_ID), 0) from jtf_prefab_ca_fl_langs where CA_FL_LANG_ID < 10000;
	l_pseudo_seq	       NUMBER := NULL;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT child.LAST_UPDATED_BY, child.LAST_UPDATE_DATE
	  INTO db_luby, db_ludate
	  FROM JTF_PREFAB_CA_FL_LANGS child, JTF_PREFAB_CA_FILTERS_B parent
	  WHERE child.ca_filter_id = parent.ca_filter_id
          AND  parent.APPLICATION_ID = X_APPLICATION_ID
	  AND  parent.CA_FILTER_NAME = X_CA_FILTER_NAME
          AND  child.LANGUAGE_CODE = X_LANGUAGE_CODE;

          /*
	  -- **** Entry is there, check if it's legal to update ****
	  IF ((X_CUSTOM_MODE = 'FORCE') OR
              ((f_luby = 0) AND (db_luby = 1)) OR
              ((f_luby = db_luby) AND (f_ludate > db_ludate))
             )
	  then
	      -- **** do nothing ****
          end if;
           */
      exception
  	   when no_data_found then
	      -- **** generate pseudo sequence ***
	      OPEN c;
	      FETCH c INTO l_pseudo_seq;
	      CLOSE c;

              l_pseudo_seq := l_pseudo_seq + 1;

	      -- **** get ca_filter_id ***
              SELECT CA_FILTER_ID
              INTO l_ca_filter_id
              FROM JTF_PREFAB_CA_FILTERS_B
              WHERE APPLICATION_ID = X_APPLICATION_ID
              AND   CA_FILTER_NAME = X_CA_FILTER_NAME;

              INSERT INTO jtf_prefab_ca_fl_langs(ca_fl_lang_id,
                                                 object_version_number,
                                                 created_by,
                                                 creation_date,
                                                 last_updated_by,
                                                 last_update_date,
                                                 last_update_login,
                                                 -- security_group_id,
                                                 ca_filter_id,
                                                 language_code)
              VALUES (l_pseudo_seq,
                      X_OBJECT_VERSION_NUMBER,
                      f_luby,
                      f_ludate,
                      f_luby,
                      f_ludate,
                      0,
                      -- NULL,
                      l_ca_filter_id,
                      X_LANGUAGE_CODE);
      end;

end LOAD_LANG_ROW;

end JTF_PREFAB_CA_FILTERS_PKG;

/
