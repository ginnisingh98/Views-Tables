--------------------------------------------------------
--  DDL for Package Body IEB_SERVICE_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEB_SERVICE_LEVELS_PKG" as
/* $Header: IEBSVCLVLB.pls 120.3 2005/09/29 06:09:03 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SERVICE_LEVEL_ID in NUMBER,
  X_DIRECTION in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_HOURLY_QUOTA in NUMBER,
  X_MIN_AGENTS in NUMBER,
  X_GOAL_PERCENT in NUMBER,
  X_GOAL_TIME in NUMBER,
  X_MAX_WAIT_TIME in NUMBER,
  X_REROUTE_TIME in NUMBER,
  X_REROUTE_WARNING_TIME in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LEVEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEB_SERVICE_LEVELS_B
    where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID;
begin
  insert into IEB_SERVICE_LEVELS_B (
    SERVICE_LEVEL_ID,
    DIRECTION,
    MANDATORY_FLAG,
    HOURLY_QUOTA,
    MIN_AGENTS,
    GOAL_PERCENT,
    GOAL_TIME,
    MAX_WAIT_TIME,
    REROUTE_TIME,
    REROUTE_WARNING_TIME,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SERVICE_LEVEL_ID,
    X_DIRECTION,
    X_MANDATORY_FLAG,
    X_HOURLY_QUOTA,
    X_MIN_AGENTS,
    X_GOAL_PERCENT,
    X_GOAL_TIME,
    X_MAX_WAIT_TIME,
    X_REROUTE_TIME,
    X_REROUTE_WARNING_TIME,
    X_OBJECT_VERSION_NUMBER,
    X_SECURITY_GROUP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEB_SERVICE_LEVELS_TL (
    SERVICE_LEVEL_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEVEL_NAME,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SERVICE_LEVEL_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LEVEL_NAME,
    X_DESCRIPTION,
    X_OBJECT_VERSION_NUMBER,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEB_SERVICE_LEVELS_TL T
    where T.SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
    and T.SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
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
  X_SERVICE_LEVEL_ID in NUMBER,
  X_DIRECTION in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_HOURLY_QUOTA in NUMBER,
  X_MIN_AGENTS in NUMBER,
  X_GOAL_PERCENT in NUMBER,
  X_GOAL_TIME in NUMBER,
  X_MAX_WAIT_TIME in NUMBER,
  X_REROUTE_TIME in NUMBER,
  X_REROUTE_WARNING_TIME in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LEVEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DIRECTION,
      MANDATORY_FLAG,
      HOURLY_QUOTA,
      MIN_AGENTS,
      GOAL_PERCENT,
      GOAL_TIME,
      MAX_WAIT_TIME,
      REROUTE_TIME,
      REROUTE_WARNING_TIME,
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID
    from IEB_SERVICE_LEVELS_B
    where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
    and SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
    for update of SERVICE_LEVEL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LEVEL_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEB_SERVICE_LEVELS_TL
    where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
    and SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SERVICE_LEVEL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DIRECTION = X_DIRECTION)
      AND ((recinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
           OR ((recinfo.MANDATORY_FLAG is null) AND (X_MANDATORY_FLAG is null)))
      AND ((recinfo.HOURLY_QUOTA = X_HOURLY_QUOTA)
           OR ((recinfo.HOURLY_QUOTA is null) AND (X_HOURLY_QUOTA is null)))
      AND ((recinfo.MIN_AGENTS = X_MIN_AGENTS)
           OR ((recinfo.MIN_AGENTS is null) AND (X_MIN_AGENTS is null)))
      AND ((recinfo.GOAL_PERCENT = X_GOAL_PERCENT)
           OR ((recinfo.GOAL_PERCENT is null) AND (X_GOAL_PERCENT is null)))
      AND ((recinfo.GOAL_TIME = X_GOAL_TIME)
           OR ((recinfo.GOAL_TIME is null) AND (X_GOAL_TIME is null)))
      AND ((recinfo.MAX_WAIT_TIME = X_MAX_WAIT_TIME)
           OR ((recinfo.MAX_WAIT_TIME is null) AND (X_MAX_WAIT_TIME is null)))
      AND ((recinfo.REROUTE_TIME = X_REROUTE_TIME)
           OR ((recinfo.REROUTE_TIME is null) AND (X_REROUTE_TIME is null)))
      AND ((recinfo.REROUTE_WARNING_TIME = X_REROUTE_WARNING_TIME)
           OR ((recinfo.REROUTE_WARNING_TIME is null) AND (X_REROUTE_WARNING_TIME is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.LEVEL_NAME = X_LEVEL_NAME)
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
  X_SERVICE_LEVEL_ID in NUMBER,
  X_DIRECTION in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_HOURLY_QUOTA in NUMBER,
  X_MIN_AGENTS in NUMBER,
  X_GOAL_PERCENT in NUMBER,
  X_GOAL_TIME in NUMBER,
  X_MAX_WAIT_TIME in NUMBER,
  X_REROUTE_TIME in NUMBER,
  X_REROUTE_WARNING_TIME in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LEVEL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEB_SERVICE_LEVELS_B set
    DIRECTION = X_DIRECTION,
    MANDATORY_FLAG = X_MANDATORY_FLAG,
    HOURLY_QUOTA = X_HOURLY_QUOTA,
    MIN_AGENTS = X_MIN_AGENTS,
    GOAL_PERCENT = X_GOAL_PERCENT,
    GOAL_TIME = X_GOAL_TIME,
    MAX_WAIT_TIME = X_MAX_WAIT_TIME,
    REROUTE_TIME = X_REROUTE_TIME,
    REROUTE_WARNING_TIME = X_REROUTE_WARNING_TIME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
  and SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEB_SERVICE_LEVELS_TL set
    LEVEL_NAME = X_LEVEL_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
  and SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SERVICE_LEVEL_ID in NUMBER
) is
begin
  delete from IEB_SERVICE_LEVELS_TL
  where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEB_SERVICE_LEVELS_B
  where SERVICE_LEVEL_ID = X_SERVICE_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  p_service_level_id IN NUMBER,
  p_mandatory_flag   IN VARCHAR2,
  p_direction IN VARCHAR2,
  p_hourly_quota IN NUMBER,
  p_min_agents IN NUMBER,
  p_goal_percent IN NUMBER,
  p_goal_time IN NUMBER,
  p_max_wait_time IN NUMBER,
  p_reroute_time IN NUMBER,
  p_reroute_warning_time IN NUMBER,
  p_level_name IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_OWNER IN VARCHAR2) is

  BEGIN
    DECLARE
        user_id  number := 0;
        l_row_id varchar2(80);
    BEGIN

	 user_id := fnd_load_util.owner_id(p_OWNER);

    --select IEB_SVC_LEVEL_S1.nextval into l_row_id from dual;

  UPDATE_ROW(
        X_SERVICE_LEVEL_ID => p_service_level_id ,
        X_DIRECTION => p_direction,
        X_MANDATORY_FLAG => p_mandatory_flag ,
        X_HOURLY_QUOTA => p_hourly_quota ,
        X_MIN_AGENTS => p_min_agents ,
        X_GOAL_PERCENT => p_goal_percent,
        X_GOAL_TIME => p_goal_time,
        X_MAX_WAIT_TIME => p_max_wait_time,
        X_REROUTE_TIME => p_reroute_time ,
        X_REROUTE_WARNING_TIME => p_reroute_warning_time,
        X_LEVEL_NAME => p_level_name,
        X_DESCRIPTION => p_description ,
        X_OBJECT_VERSION_NUMBER => NULL,
        X_SECURITY_GROUP_ID => NULL,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN =>  1 );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
        INSERT_ROW (
          X_ROWID => l_row_id,
          X_SERVICE_LEVEL_ID => p_service_level_id ,
          X_DIRECTION => p_direction ,
          X_MANDATORY_FLAG => p_mandatory_flag ,
          X_HOURLY_QUOTA => p_hourly_quota ,
          X_MIN_AGENTS => p_min_agents ,
          X_GOAL_PERCENT => p_goal_percent ,
          X_GOAL_TIME => p_goal_time ,
          X_MAX_WAIT_TIME => p_max_wait_time ,
          X_REROUTE_TIME => p_reroute_time ,
          X_REROUTE_WARNING_TIME => p_reroute_warning_time ,
          X_OBJECT_VERSION_NUMBER => NULL ,
          X_SECURITY_GROUP_ID => NULL ,
          X_LEVEL_NAME => p_level_name ,
          X_DESCRIPTION => p_description ,
          X_CREATION_DATE => sysdate ,
          X_CREATED_BY => user_id ,
          X_LAST_UPDATE_DATE => sysdate ,
          X_LAST_UPDATED_BY => user_id ,
          X_LAST_UPDATE_LOGIN => 1 );

      END;
end LOAD_ROW;

procedure LOAD_SEED_ROW (
  p_service_level_id IN NUMBER,
  p_mandatory_flag   IN VARCHAR2,
  p_direction IN VARCHAR2,
  p_hourly_quota IN NUMBER,
  p_min_agents IN NUMBER,
  p_goal_percent IN NUMBER,
  p_goal_time IN NUMBER,
  p_max_wait_time IN NUMBER,
  p_reroute_time IN NUMBER,
  p_reroute_warning_time IN NUMBER,
  p_level_name IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_OWNER IN VARCHAR2,
  p_UPLOAD_MODE IN VARCHAR2) is
BEGIN
  if (p_UPLOAD_MODE = 'NLS') then
    IEB_SERVICE_LEVELS_PKG.TRANSLATE_ROW (
				       p_SERVICE_LEVEL_ID,
				       p_LEVEL_NAME,
				       p_DESCRIPTION,
				       p_OWNER);
  else
    IEB_SERVICE_LEVELS_PKG.LOAD_ROW (
              p_service_level_id ,
              p_mandatory_flag ,
              p_direction ,
              p_hourly_quota ,
              p_min_agents ,
              p_goal_percent ,
              p_goal_time ,
              p_max_wait_time ,
              p_reroute_time ,
              p_reroute_warning_time ,
              p_level_name ,
              p_DESCRIPTION ,
              p_OWNER );
  end if;
END LOAD_SEED_ROW;


procedure TRANSLATE_ROW (
  X_SERVICE_LEVEL_ID IN NUMBER,
  X_LEVEL_NAME       IN VARCHAR2,
  X_DESCRIPTION      IN VARCHAR2,
  X_OWNER            IN VARCHAR2) is

    BEGIN
      DECLARE
        user_id  number := 0;
      BEGIN

	   user_id := fnd_load_util.owner_id(X_OWNER);

       UPDATE ieb_service_levels_tl
        SET
          last_update_date=sysdate
        , last_updated_by=user_id
        , last_update_login=1
        , LEVEL_NAME = DECODE(X_LEVEL_NAME,FND_API.G_MISS_CHAR,
                                         NULL,X_LEVEL_NAME)
        , DESCRIPTION = DECODE(X_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,X_DESCRIPTION)
        , source_lang = USERENV('LANG')
         WHERE
            service_level_id = X_SERVICE_LEVEL_ID
         AND USERENV('LANG') IN (language, source_lang);

      END;

end TRANSLATE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEB_SERVICE_LEVELS_TL T
  where not exists
    (select NULL
    from IEB_SERVICE_LEVELS_B B
    where B.SERVICE_LEVEL_ID = T.SERVICE_LEVEL_ID
    and B.SERVICE_LEVEL_ID = T.SERVICE_LEVEL_ID
    );

  update IEB_SERVICE_LEVELS_TL T set (
      LEVEL_NAME,
      DESCRIPTION
    ) = (select
      B.LEVEL_NAME,
      B.DESCRIPTION
    from IEB_SERVICE_LEVELS_TL B
    where B.SERVICE_LEVEL_ID = T.SERVICE_LEVEL_ID
    and B.SERVICE_LEVEL_ID = T.SERVICE_LEVEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SERVICE_LEVEL_ID,
      T.SERVICE_LEVEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SERVICE_LEVEL_ID,
      SUBT.SERVICE_LEVEL_ID,
      SUBT.LANGUAGE
    from IEB_SERVICE_LEVELS_TL SUBB, IEB_SERVICE_LEVELS_TL SUBT
    where SUBB.SERVICE_LEVEL_ID = SUBT.SERVICE_LEVEL_ID
    and SUBB.SERVICE_LEVEL_ID = SUBT.SERVICE_LEVEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LEVEL_NAME <> SUBT.LEVEL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into IEB_SERVICE_LEVELS_TL (
    SERVICE_LEVEL_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEVEL_NAME,
    DESCRIPTION,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SERVICE_LEVEL_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LEVEL_NAME,
    B.DESCRIPTION,
    B.OBJECT_VERSION_NUMBER,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEB_SERVICE_LEVELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEB_SERVICE_LEVELS_TL T
    where T.SERVICE_LEVEL_ID = B.SERVICE_LEVEL_ID
    and T.SERVICE_LEVEL_ID = B.SERVICE_LEVEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEB_SERVICE_LEVELS_PKG;

/
