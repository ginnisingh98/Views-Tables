--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_POLICIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_POLICIES_PKG" as
/* $Header: jtfprefplcytb.pls 120.0 2005/11/08 21:57:33 emekala noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_POLICY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_POLICY_NAME in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALL_APPLICATIONS_FLAG in VARCHAR2,
  X_DEPTH in NUMBER,
  X_ALL_RESPONSIBILITIES_FLAG in VARCHAR2,
  X_ALL_USERS_FLAG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_INTERVAL_UNIT in VARCHAR2,
  X_START_TIME in NUMBER,
  X_END_TIME in NUMBER,
  X_RUN_ALWAYS_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_PREFAB_POLICIES_B
    where POLICY_ID = X_POLICY_ID
    ;
begin
  insert into JTF_PREFAB_POLICIES_B (
    POLICY_ID,
    OBJECT_VERSION_NUMBER,
    -- SECURITY_GROUP_ID,
    POLICY_NAME,
    PRIORITY,
    ENABLED_FLAG,
    APPLICATION_ID,
    ALL_APPLICATIONS_FLAG,
    DEPTH,
    ALL_RESPONSIBILITIES_FLAG,
    ALL_USERS_FLAG,
    REFRESH_INTERVAL,
    INTERVAL_UNIT,
    START_TIME,
    END_TIME,
    RUN_ALWAYS_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_POLICY_ID,
    X_OBJECT_VERSION_NUMBER,
    -- X_SECURITY_GROUP_ID,
    X_POLICY_NAME,
    X_PRIORITY,
    X_ENABLED_FLAG,
    X_APPLICATION_ID,
    X_ALL_APPLICATIONS_FLAG,
    X_DEPTH,
    X_ALL_RESPONSIBILITIES_FLAG,
    X_ALL_USERS_FLAG,
    X_REFRESH_INTERVAL,
    X_INTERVAL_UNIT,
    X_START_TIME,
    X_END_TIME,
    X_RUN_ALWAYS_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PREFAB_POLICIES_TL (
    POLICY_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_POLICY_ID,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    -- X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PREFAB_POLICIES_TL T
    where T.POLICY_ID = X_POLICY_ID
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
  X_POLICY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_POLICY_NAME in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALL_APPLICATIONS_FLAG in VARCHAR2,
  X_DEPTH in NUMBER,
  X_ALL_RESPONSIBILITIES_FLAG in VARCHAR2,
  X_ALL_USERS_FLAG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_INTERVAL_UNIT in VARCHAR2,
  X_START_TIME in NUMBER,
  X_END_TIME in NUMBER,
  X_RUN_ALWAYS_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID,
      POLICY_NAME,
      PRIORITY,
      ENABLED_FLAG,
      APPLICATION_ID,
      ALL_APPLICATIONS_FLAG,
      DEPTH,
      ALL_RESPONSIBILITIES_FLAG,
      ALL_USERS_FLAG,
      REFRESH_INTERVAL,
      INTERVAL_UNIT,
      START_TIME,
      END_TIME,
      RUN_ALWAYS_FLAG
    from JTF_PREFAB_POLICIES_B
    where POLICY_ID = X_POLICY_ID
    for update of POLICY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PREFAB_POLICIES_TL
    where POLICY_ID = X_POLICY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of POLICY_ID nowait;
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
      -- AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
      --     OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.POLICY_NAME = X_POLICY_NAME)
      AND (recinfo.PRIORITY = X_PRIORITY)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND (recinfo.ALL_APPLICATIONS_FLAG = X_ALL_APPLICATIONS_FLAG)
      AND (recinfo.DEPTH = X_DEPTH)
      AND (recinfo.ALL_RESPONSIBILITIES_FLAG = X_ALL_RESPONSIBILITIES_FLAG)
      AND (recinfo.ALL_USERS_FLAG = X_ALL_USERS_FLAG)
      AND (recinfo.REFRESH_INTERVAL = X_REFRESH_INTERVAL)
      AND (recinfo.INTERVAL_UNIT = X_INTERVAL_UNIT)
      AND (recinfo.START_TIME = X_START_TIME)
      AND (recinfo.END_TIME = X_END_TIME)
      AND (recinfo.RUN_ALWAYS_FLAG = X_RUN_ALWAYS_FLAG)
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
  X_POLICY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_POLICY_NAME in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALL_APPLICATIONS_FLAG in VARCHAR2,
  X_DEPTH in NUMBER,
  X_ALL_RESPONSIBILITIES_FLAG in VARCHAR2,
  X_ALL_USERS_FLAG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_INTERVAL_UNIT in VARCHAR2,
  X_START_TIME in NUMBER,
  X_END_TIME in NUMBER,
  X_RUN_ALWAYS_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PREFAB_POLICIES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    -- SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    POLICY_NAME = X_POLICY_NAME,
    PRIORITY = X_PRIORITY,
    ENABLED_FLAG = X_ENABLED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    ALL_APPLICATIONS_FLAG = X_ALL_APPLICATIONS_FLAG,
    DEPTH = X_DEPTH,
    ALL_RESPONSIBILITIES_FLAG = X_ALL_RESPONSIBILITIES_FLAG,
    ALL_USERS_FLAG = X_ALL_USERS_FLAG,
    REFRESH_INTERVAL = X_REFRESH_INTERVAL,
    INTERVAL_UNIT = X_INTERVAL_UNIT,
    START_TIME = X_START_TIME,
    END_TIME = X_END_TIME,
    RUN_ALWAYS_FLAG = X_RUN_ALWAYS_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where POLICY_ID = X_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PREFAB_POLICIES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where POLICY_ID = X_POLICY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_POLICY_ID in NUMBER
) is
begin
  delete from JTF_PREFAB_POLICIES_TL
  where POLICY_ID = X_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PREFAB_POLICIES_B
  where POLICY_ID = X_POLICY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PREFAB_POLICIES_TL T
  where not exists
    (select NULL
    from JTF_PREFAB_POLICIES_B B
    where B.POLICY_ID = T.POLICY_ID
    );

  update JTF_PREFAB_POLICIES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from JTF_PREFAB_POLICIES_TL B
    where B.POLICY_ID = T.POLICY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.POLICY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.POLICY_ID,
      SUBT.LANGUAGE
    from JTF_PREFAB_POLICIES_TL SUBB, JTF_PREFAB_POLICIES_TL SUBT
    where SUBB.POLICY_ID = SUBT.POLICY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into JTF_PREFAB_POLICIES_TL (
    POLICY_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.POLICY_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    -- B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PREFAB_POLICIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PREFAB_POLICIES_TL T
    where T.POLICY_ID = B.POLICY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_POLICY_NAME in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ALL_APPLICATIONS_FLAG in VARCHAR2,
  X_DEPTH in NUMBER,
  X_ALL_RESPONSIBILITIES_FLAG in VARCHAR2,
  X_ALL_USERS_FLAG in VARCHAR2,
  X_REFRESH_INTERVAL in NUMBER,
  X_INTERVAL_UNIT in VARCHAR2,
  X_START_TIME in NUMBER,
  X_END_TIME in NUMBER,
  X_RUN_ALWAYS_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
	l_row_id        VARCHAR2(255);

    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
   	l_policy_id    NUMBER;

	cursor c is select nvl(max(POLICY_ID), 0) from jtf_prefab_policies_b where POLICY_ID < 10000;
	l_pseudo_seq	       NUMBER := NULL;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT POLICY_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
	  INTO l_policy_id, db_luby, db_ludate
	  FROM JTF_PREFAB_POLICIES_B
	  WHERE APPLICATION_ID = X_APPLICATION_ID AND
                POLICY_NAME = X_POLICY_NAME;

	  -- **** Entry is there, check if it's legal to update ****
	  IF ((X_CUSTOM_MODE = 'FORCE') OR
              ((f_luby = 0) AND (db_luby = 1)) OR
              ((f_luby = db_luby) AND (f_ludate > db_ludate))
             )
	  then
	      -- **** call Update row ****
              JTF_PREFAB_POLICIES_PKG.UPDATE_ROW (
                  X_POLICY_ID                    =>  l_policy_id,
                  X_OBJECT_VERSION_NUMBER        =>  X_OBJECT_VERSION_NUMBER,
                  X_SECURITY_GROUP_ID            =>  X_SECURITY_GROUP_ID,
                  X_POLICY_NAME                  =>  X_POLICY_NAME,
                  X_PRIORITY                     =>  X_PRIORITY,
                  X_ENABLED_FLAG                 =>  X_ENABLED_FLAG,
                  X_APPLICATION_ID               =>  X_APPLICATION_ID,
                  X_ALL_APPLICATIONS_FLAG        =>  X_ALL_APPLICATIONS_FLAG,
                  X_DEPTH                        =>  X_DEPTH,
                  X_ALL_RESPONSIBILITIES_FLAG    =>  X_ALL_RESPONSIBILITIES_FLAG,
                  X_ALL_USERS_FLAG               =>  X_ALL_USERS_FLAG,
                  X_REFRESH_INTERVAL             =>  X_REFRESH_INTERVAL,
                  X_INTERVAL_UNIT                =>  X_INTERVAL_UNIT,
                  X_START_TIME                   =>  X_START_TIME,
                  X_END_TIME                     =>  X_END_TIME,
                  X_RUN_ALWAYS_FLAG              =>  X_RUN_ALWAYS_FLAG,
                  X_DESCRIPTION                  =>  X_DESCRIPTION,
                  X_LAST_UPDATE_DATE             =>  f_ludate,
                  X_LAST_UPDATED_BY              =>  f_luby,
                  X_LAST_UPDATE_LOGIN            =>  0);

              -- **** delete all the child entries ****
              DELETE FROM jtf_prefab_ur_policies
              WHERE policy_id = l_policy_id;
           end if;
      exception
  	   when no_data_found then
	      -- **** generate pseudo sequence ***
	      OPEN c;
	      FETCH c INTO l_pseudo_seq;
	      CLOSE c;

              JTF_PREFAB_POLICIES_PKG.INSERT_ROW (
                  X_ROWID                          =>   l_row_id,
                  X_POLICY_ID                      =>   (l_pseudo_seq + 1),
                  X_OBJECT_VERSION_NUMBER          =>   X_OBJECT_VERSION_NUMBER,
                  X_SECURITY_GROUP_ID              =>   X_SECURITY_GROUP_ID,
                  X_POLICY_NAME                    =>   X_POLICY_NAME,
                  X_PRIORITY                       =>   X_PRIORITY,
                  X_ENABLED_FLAG                   =>   X_ENABLED_FLAG,
                  X_APPLICATION_ID                 =>   X_APPLICATION_ID,
                  X_ALL_APPLICATIONS_FLAG          =>   X_ALL_APPLICATIONS_FLAG,
                  X_DEPTH                          =>   X_DEPTH,
                  X_ALL_RESPONSIBILITIES_FLAG      =>   X_ALL_RESPONSIBILITIES_FLAG,
                  X_ALL_USERS_FLAG                 =>   X_ALL_USERS_FLAG,
                  X_REFRESH_INTERVAL               =>   X_REFRESH_INTERVAL,
                  X_INTERVAL_UNIT                  =>   X_INTERVAL_UNIT,
                  X_START_TIME                     =>   X_START_TIME,
                  X_END_TIME                       =>   X_END_TIME,
                  X_RUN_ALWAYS_FLAG                =>   X_RUN_ALWAYS_FLAG,
                  X_DESCRIPTION                    =>   X_DESCRIPTION,
                  X_CREATION_DATE                  =>   f_ludate,
                  X_CREATED_BY                     =>   f_luby,
                  X_LAST_UPDATE_DATE               =>   f_ludate,
                  X_LAST_UPDATED_BY                =>   f_luby,
                  X_LAST_UPDATE_LOGIN              =>   0);
      end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_POLICY_NAME in VARCHAR2,
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
    l_policy_id        NUMBER;
begin

  if (X_OWNER = 'SEED') then
     f_luby := 1;
  else
     f_luby := 0;
  end if;

  f_ludate := X_LAST_UPDATE_DATE;

  begin
      SELECT tl.POLICY_ID, tl.LAST_UPDATED_BY, tl.LAST_UPDATE_DATE
      INTO l_policy_id, db_luby, db_ludate
      FROM JTF_PREFAB_POLICIES_B b, JTF_PREFAB_POLICIES_TL tl
      WHERE b.POLICY_ID = tl.POLICY_ID AND
            b.APPLICATION_ID = X_APPLICATION_ID AND
            b.POLICY_NAME = X_POLICY_NAME AND
            tl.LANGUAGE = userenv('LANG');

      if ((X_CUSTOM_MODE = 'FORCE') OR
          ((f_luby = 0) AND (db_luby = 1)) OR
          ((f_luby = db_luby) AND (f_ludate > db_ludate))
         )
      then
          update JTF_PREFAB_POLICIES_TL set
            DESCRIPTION = nvl(X_DESCRIPTION, DESCRIPTION),
	    LAST_UPDATE_DATE = f_ludate,
	    LAST_UPDATED_BY = f_luby,
	    LAST_UPDATE_LOGIN = 0,
	    SOURCE_LANG = userenv('LANG')
          where userenv('LANG') in (LANGUAGE, SOURCE_LANG) and
	        POLICY_ID = l_policy_id;
      end if;
   exception
	when no_data_found then null;
   end;
end TRANSLATE_ROW;

procedure LOAD_UR_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_POLICY_NAME in VARCHAR2,
  X_USERRESP_ID in NUMBER,
  X_USERRESP_TYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
	l_row_id        VARCHAR2(255);

    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
        l_policy_id     NUMBER;

	cursor c is select nvl(max(UR_POLICY_ID), 0) from jtf_prefab_ur_policies where UR_POLICY_ID < 10000;
	l_pseudo_seq	       NUMBER := NULL;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT po.POLICY_ID, ur.LAST_UPDATED_BY, ur.LAST_UPDATE_DATE
	  INTO l_policy_id, db_luby, db_ludate
	  FROM JTF_PREFAB_UR_POLICIES ur, JTF_PREFAB_POLICIES_B po
          WHERE po.POLICY_ID = ur.POLICY_ID AND
                po.APPLICATION_ID = X_APPLICATION_ID AND
                po.POLICY_NAME = X_POLICY_NAME AND
                ur.USERRESP_ID = X_USERRESP_ID AND
                ur.USERRESP_TYPE = X_USERRESP_TYPE;

	  -- **** Entry is there, check if it's legal to update ****
          /*
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

	      -- **** get policy id ***
              SELECT POLICY_ID
              INTO l_policy_id
              FROM JTF_PREFAB_POLICIES_B
              WHERE APPLICATION_ID = X_APPLICATION_ID
              AND   POLICY_NAME = X_POLICY_NAME;

              INSERT INTO jtf_prefab_ur_policies (ur_policy_id,
                                                  object_version_number,
                                                  created_by,
                                                  creation_date,
                                                  last_updated_by,
                                                  last_update_date,
                                                  last_update_login,
                                                  -- security_group_id,
                                                  policy_id,
                                                  userresp_id,
                                                  userresp_type)
              VALUES ((l_pseudo_seq + 1),
                      X_OBJECT_VERSION_NUMBER,
                      f_luby,
                      f_ludate,
                      f_luby,
                      f_ludate,
                      0,
                      -- X_SECURITY_GROUP_ID,
                      l_policy_id,
                      X_USERRESP_ID,
                      X_USERRESP_TYPE);
      end;

end LOAD_UR_ROW;

procedure LOAD_SYS_ROW (
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_START_FLAG in VARCHAR2,
  X_CPU in NUMBER,
  X_MEMORY in NUMBER,
  X_DISK_LOCATION in VARCHAR2,
  X_MAX_CONCURRENCY in NUMBER,
  X_USE_LOAD_BALANCER_FLAG in VARCHAR2,
  X_LOAD_BALANCER_URL in VARCHAR2,
  X_REFRESH_FLAG in VARCHAR2,
  X_INTERCEPTOR_ENABLED_FLAG in VARCHAR2,
  X_CACHE_MEMORY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
   	--****** local variables ******
	l_row_id        VARCHAR2(255);

    	f_luby		NUMBER;
    	f_ludate    	DATE;
    	db_luby		NUMBER;
    	db_ludate	DATE;
begin

      if (X_OWNER = 'SEED') then
	f_luby := 1;
      else
        f_luby := 0;
      end if;

      f_ludate := X_LAST_UPDATE_DATE;

      begin
	  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
	  INTO db_luby, db_ludate
	  FROM JTF_PREFAB_SYS_POLICIES;

	  -- **** Entry is there, check if it's legal to update ****
	  IF ((X_CUSTOM_MODE = 'FORCE') OR
              ((f_luby = 0) AND (db_luby = 1)) OR
              ((f_luby = db_luby) AND (f_ludate > db_ludate))
             )
	  then
	      -- **** update ****
              UPDATE jtf_prefab_sys_policies
              SET object_version_number = X_OBJECT_VERSION_NUMBER,
                  last_updated_by = f_luby,
                  last_update_date = f_ludate,
                  last_update_login = 0,
                  start_flag = X_START_FLAG,
                  cpu = X_CPU,
                  memory = X_MEMORY,
                  disk_location = X_DISK_LOCATION,
                  max_concurrency = X_MAX_CONCURRENCY,
                  use_load_balancer_flag = X_USE_LOAD_BALANCER_FLAG,
                  load_balancer_url = X_LOAD_BALANCER_URL,
                  refresh_flag = X_REFRESH_FLAG,
                  interceptor_enabled_flag = X_INTERCEPTOR_ENABLED_FLAG,
                  cache_memory = X_CACHE_MEMORY;
          end if;
      exception
  	   when no_data_found then
             INSERT INTO jtf_prefab_sys_policies (sys_policy_id,
                                                  object_version_number,
                                                  created_by,
                                                  creation_date,
                                                  last_updated_by,
                                                  last_update_date,
                                                  last_update_login,
                                                  -- security_group_id,
                                                  start_flag,
                                                  cpu,
                                                  memory,
                                                  disk_location,
                                                  max_concurrency,
                                                  use_load_balancer_flag,
                                                  load_balancer_url,
                                                  refresh_flag,
                                                  interceptor_enabled_flag,
                                                  cache_memory)
             VALUES (1,
                     X_OBJECT_VERSION_NUMBER,
                     f_luby,
                     f_ludate,
                     f_luby,
                     f_ludate,
                     0,
                     -- X_SECURITY_GROUP_ID,
                     X_START_FLAG,
                     X_CPU,
                     X_MEMORY,
                     X_DISK_LOCATION,
                     X_MAX_CONCURRENCY,
                     X_USE_LOAD_BALANCER_FLAG,
                     X_LOAD_BALANCER_URL,
                     X_REFRESH_FLAG,
                     X_INTERCEPTOR_ENABLED_FLAG,
                     X_CACHE_MEMORY);
      end;

end LOAD_SYS_ROW;

end JTF_PREFAB_POLICIES_PKG;

/
