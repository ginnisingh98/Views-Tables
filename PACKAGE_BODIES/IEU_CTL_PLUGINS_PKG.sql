--------------------------------------------------------
--  DDL for Package Body IEU_CTL_PLUGINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_CTL_PLUGINS_PKG" as
/* $Header: IEUCTLPB.pls 120.4 2005/08/04 23:16:32 appldev ship $ */
procedure INSERT_ROW (
  P_PLUGIN_ID             IN NUMBER,
  P_INIT_ERROR_MSG_NAME   IN VARCHAR2,
  P_APPLICATION_ID        IN NUMBER,
  P_IS_REQUIRED_FLAG      IN VARCHAR2,
  P_DO_LAUNCH_FUNC        IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_CLASS_NAME            IN VARCHAR2,
  P_IMAGE_FILE_NAME       IN VARCHAR2,
  P_AUDIO_FILE_NAME       IN VARCHAR2,
  P_NAME                  IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  X_ROWID                 IN OUT NOCOPY VARCHAR2
) is
  cursor C is select ROWID from IEU_CTL_PLUGINS_B
    where PLUGIN_ID = P_PLUGIN_ID
    ;
begin
  insert into IEU_CTL_PLUGINS_B (
    INIT_ERROR_MSG_NAME,
    APPLICATION_ID,
    IS_REQUIRED_FLAG,
    DO_LAUNCH_FUNC,
    PLUGIN_ID,
    OBJECT_VERSION_NUMBER,
    CLASS_NAME,
    IMAGE_FILE_NAME,
    AUDIO_FILE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_INIT_ERROR_MSG_NAME,
    P_APPLICATION_ID,
    P_IS_REQUIRED_FLAG,
    P_DO_LAUNCH_FUNC,
    P_PLUGIN_ID,
    P_OBJECT_VERSION_NUMBER,
    P_CLASS_NAME,
    P_IMAGE_FILE_NAME,
    P_AUDIO_FILE_NAME,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    FND_GLOBAL.LOGIN_ID
  );

  insert into IEU_CTL_PLUGINS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    PLUGIN_ID,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    P_PLUGIN_ID,
    P_OBJECT_VERSION_NUMBER,
    P_DESCRIPTION,
    FND_GLOBAL.LOGIN_ID,
    P_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEU_CTL_PLUGINS_TL T
    where T.PLUGIN_ID = P_PLUGIN_ID
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
  P_PLUGIN_ID             IN NUMBER,
  P_INIT_ERROR_MSG_NAME   IN VARCHAR2,
  P_APPLICATION_ID        IN NUMBER,
  P_IS_REQUIRED_FLAG      IN VARCHAR2,
  P_DO_LAUNCH_FUNC        IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_CLASS_NAME            IN VARCHAR2,
  P_IMAGE_FILE_NAME       IN VARCHAR2,
  P_AUDIO_FILE_NAME       IN VARCHAR2,
  P_NAME                  IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2
) is
  cursor c is select
      INIT_ERROR_MSG_NAME,
      APPLICATION_ID,
      IS_REQUIRED_FLAG,
      DO_LAUNCH_FUNC,
      OBJECT_VERSION_NUMBER,
      CLASS_NAME,
      IMAGE_FILE_NAME,
      AUDIO_FILE_NAME
    from IEU_CTL_PLUGINS_B
    where PLUGIN_ID = P_PLUGIN_ID
    for update of PLUGIN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_CTL_PLUGINS_TL
    where PLUGIN_ID = P_PLUGIN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PLUGIN_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.INIT_ERROR_MSG_NAME = P_INIT_ERROR_MSG_NAME)
           OR ((recinfo.INIT_ERROR_MSG_NAME is null) AND (P_INIT_ERROR_MSG_NAME is null)))
      AND ((recinfo.APPLICATION_ID = P_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (P_APPLICATION_ID is null)))
      AND ((recinfo.IS_REQUIRED_FLAG = P_IS_REQUIRED_FLAG)
           OR ((recinfo.IS_REQUIRED_FLAG is null) AND (P_IS_REQUIRED_FLAG is null)))
      AND ((recinfo.DO_LAUNCH_FUNC = P_DO_LAUNCH_FUNC)
           OR ((recinfo.DO_LAUNCH_FUNC is null) AND (P_DO_LAUNCH_FUNC is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
      AND (recinfo.CLASS_NAME = P_CLASS_NAME)
      AND (recinfo.IMAGE_FILE_NAME = P_IMAGE_FILE_NAME)
      AND ((recinfo.AUDIO_FILE_NAME = P_AUDIO_FILE_NAME)
           OR ((recinfo.AUDIO_FILE_NAME is null) AND (P_AUDIO_FILE_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = P_NAME)
          AND (tlinfo.DESCRIPTION = P_DESCRIPTION)
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
  P_PLUGIN_ID             IN NUMBER,
  P_INIT_ERROR_MSG_NAME   IN VARCHAR2,
  P_APPLICATION_ID        IN NUMBER,
  P_IS_REQUIRED_FLAG      IN VARCHAR2,
  P_DO_LAUNCH_FUNC        IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_CLASS_NAME            IN VARCHAR2,
  P_IMAGE_FILE_NAME       IN VARCHAR2,
  P_AUDIO_FILE_NAME       IN VARCHAR2,
  P_NAME                  IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2
) is
begin
  update IEU_CTL_PLUGINS_B set
    INIT_ERROR_MSG_NAME = P_INIT_ERROR_MSG_NAME,
    APPLICATION_ID = P_APPLICATION_ID,
    IS_REQUIRED_FLAG = P_IS_REQUIRED_FLAG,
    DO_LAUNCH_FUNC = P_DO_LAUNCH_FUNC,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    CLASS_NAME = P_CLASS_NAME,
    IMAGE_FILE_NAME = P_IMAGE_FILE_NAME,
    AUDIO_FILE_NAME = P_AUDIO_FILE_NAME,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
  where PLUGIN_ID = P_PLUGIN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEU_CTL_PLUGINS_TL set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
    SOURCE_LANG = userenv('LANG')
  where PLUGIN_ID = P_PLUGIN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_PLUGIN_ID in NUMBER
) is
begin
  delete from IEU_CTL_PLUGINS_TL
  where PLUGIN_ID = P_PLUGIN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_CTL_PLUGINS_B
  where PLUGIN_ID = P_PLUGIN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_CTL_PLUGINS_TL T
  where not exists
    (select NULL
    from IEU_CTL_PLUGINS_B B
    where B.PLUGIN_ID = T.PLUGIN_ID
    );

  update IEU_CTL_PLUGINS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from IEU_CTL_PLUGINS_TL B
    where B.PLUGIN_ID = T.PLUGIN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PLUGIN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PLUGIN_ID,
      SUBT.LANGUAGE
    from IEU_CTL_PLUGINS_TL SUBB, IEU_CTL_PLUGINS_TL SUBT
    where SUBB.PLUGIN_ID = SUBT.PLUGIN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into IEU_CTL_PLUGINS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    PLUGIN_ID,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.PLUGIN_ID,
    B.OBJECT_VERSION_NUMBER,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_CTL_PLUGINS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_CTL_PLUGINS_TL T
    where T.PLUGIN_ID = B.PLUGIN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  P_PLUGIN_ID   IN NUMBER,
  P_NAME        IN VARCHAR2,
  P_DESCRIPTION IN VARCHAR2,
  P_OWNER       IN VARCHAR2
) IS
user_id NUMBER := 0;
BEGIN
  --only update rows that have not been altered by user

  user_id := fnd_load_util.owner_id(P_OWNER);

  UPDATE IEU_CTL_PLUGINS_TL
  SET
    NAME = P_NAME,
    SOURCE_LANG = userenv( 'LANG' ),
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = SYSDATE,
    --LAST_UPDATED_BY = decode( P_OWNER, 'SEED', 1, 0 ),
    LAST_UPDATED_BY = user_id,
    LAST_UPDATE_LOGIN = 0
  WHERE
    PLUGIN_ID = P_PLUGIN_ID
  AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

END TRANSLATE_ROW;


procedure LOAD_ROW (
  P_PLUGIN_ID             IN NUMBER,
  P_INIT_ERROR_MSG_NAME   IN VARCHAR2,
  P_APPLICATION_ID        IN NUMBER,
  P_IS_REQUIRED_FLAG      IN VARCHAR2,
  P_DO_LAUNCH_FUNC        IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_CLASS_NAME            IN VARCHAR2,
  P_IMAGE_FILE_NAME       IN VARCHAR2,
  P_AUDIO_FILE_NAME       IN VARCHAR2,
  P_NAME                  IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OWNER                 IN VARCHAR2
) IS

BEGIN

    DECLARE
       user_id NUMBER := 0;
       rowid   VARCHAR2(50);
    BEGIN

      --IF (P_OWNER = 'SEED') then
      --      user_id := 1;
      --END IF;

      user_id := fnd_load_util.owner_id(P_OWNER);

      UPDATE_ROW (
        P_PLUGIN_ID             ,
        P_INIT_ERROR_MSG_NAME   ,
        P_APPLICATION_ID        ,
        P_IS_REQUIRED_FLAG      ,
        P_DO_LAUNCH_FUNC        ,
        P_OBJECT_VERSION_NUMBER ,
        P_CLASS_NAME            ,
        P_IMAGE_FILE_NAME       ,
        P_AUDIO_FILE_NAME       ,
        P_NAME                  ,
        P_DESCRIPTION
      );

      EXCEPTION
        when no_data_found then

      INSERT_ROW (
        P_PLUGIN_ID             ,
        P_INIT_ERROR_MSG_NAME   ,
        P_APPLICATION_ID        ,
        P_IS_REQUIRED_FLAG      ,
        P_DO_LAUNCH_FUNC        ,
        P_OBJECT_VERSION_NUMBER ,
        P_CLASS_NAME            ,
        P_IMAGE_FILE_NAME       ,
        P_AUDIO_FILE_NAME       ,
        P_NAME                  ,
        P_DESCRIPTION           ,
        rowid
      );
    END;

END LOAD_ROW;

procedure LOAD_SEED_ROW (
  P_UPLOAD_MODE           IN VARCHAR2,
  P_PLUGIN_ID             IN NUMBER,
  P_INIT_ERROR_MSG_NAME   IN VARCHAR2,
  P_APPLICATION_ID        IN NUMBER,
  P_IS_REQUIRED_FLAG      IN VARCHAR2,
  P_DO_LAUNCH_FUNC        IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_CLASS_NAME            IN VARCHAR2,
  P_IMAGE_FILE_NAME       IN VARCHAR2,
  P_AUDIO_FILE_NAME       IN VARCHAR2,
  P_NAME                  IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OWNER                 IN VARCHAR2
) IS

BEGIN

IF ( P_UPLOAD_MODE = 'NLS' ) THEN
      TRANSLATE_ROW (
          P_PLUGIN_ID,
          P_NAME,
          P_DESCRIPTION,
          P_OWNER );
ELSE
      LOAD_ROW(
          P_PLUGIN_ID,
          P_INIT_ERROR_MSG_NAME,
          P_APPLICATION_ID,
          P_IS_REQUIRED_FLAG,
          P_DO_LAUNCH_FUNC,
          P_OBJECT_VERSION_NUMBER,
          P_CLASS_NAME,
          P_IMAGE_FILE_NAME,
          P_AUDIO_FILE_NAME,
          P_NAME,
          P_DESCRIPTION,
          P_OWNER);
END IF;

END LOAD_SEED_ROW;

end IEU_CTL_PLUGINS_PKG;

/
