--------------------------------------------------------
--  DDL for Package Body FND_EID_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_GROUPS_PKG" as
/* $Header: fndeidgrpsb.pls 120.0.12010000.3 2012/10/09 01:34:01 rnagaraj noship $ */

procedure INSERT_ROW (
  X_EID_INSTANCE_ID             IN VARCHAR2,
  X_EID_INSTANCE_GROUP          IN VARCHAR2,
  X_EID_RELEASE_VERSION         IN VARCHAR2,
  X_EID_INSTANCE_GROUP_SEQ      IN VARCHAR2,
  X_EID_INSTANCE_GROUP_USER_SEQ IN VARCHAR2,
  X_GROUP_SOURCE                IN VARCHAR2,
  X_OBSOLETED_FLAG              IN VARCHAR2,
  X_OBSOLETED_EID_REL_VER       IN VARCHAR2,
  X_DISPLAY_NAME                IN VARCHAR2,
  X_GROUP_DESC                  IN VARCHAR2,
  X_USER_DISPLAY_NAME           IN VARCHAR2,
  X_USER_GROUP_DESC             IN VARCHAR2,
  X_LAST_UPDATE_DATE            IN VARCHAR2,
  X_APPLICATION_SHORT_NAME      IN VARCHAR2,
  X_OWNER                       IN VARCHAR2
 ) is
  cursor C is select ROWID from FND_EID_GROUPS_B
    where EID_INSTANCE_ID = X_EID_INSTANCE_ID
    and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP
    ;
  user_id  NUMBER;
  l_rowid  ROWID;
begin

  IF ( x_owner IS NOT NULL ) THEN
    user_id := fnd_load_util.owner_id(x_owner);
  ELSE
    user_id := -1;
  END IF;

  IF ( user_id > 0 ) THEN
  insert into FND_EID_GROUPS_B (
    EID_INSTANCE_ID,
    EID_INSTANCE_GROUP,
    EID_RELEASE_VERSION,
    EID_INSTANCE_GROUP_SEQ,
    EID_INSTANCE_GROUP_USER_SEQ,
    GROUP_SOURCE,
    OBSOLETED_FLAG,
    OBSOLETED_EID_RELEASE_VERSION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_EID_INSTANCE_ID,
    X_EID_INSTANCE_GROUP,
    X_EID_RELEASE_VERSION,
    X_EID_INSTANCE_GROUP_SEQ,
    X_EID_INSTANCE_GROUP_USER_SEQ,
    X_GROUP_SOURCE,
    X_OBSOLETED_FLAG,
    X_OBSOLETED_EID_REL_VER,
    TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
    user_id,
    TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
    user_id,
    0
  );

  insert into FND_EID_GROUPS_TL (
    EID_INSTANCE_ID,
    EID_INSTANCE_GROUP,
    DISPLAY_NAME,
    GROUP_DESC,
    USER_DISPLAY_NAME,
    USER_GROUP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_EID_INSTANCE_ID,
    X_EID_INSTANCE_GROUP,
    X_DISPLAY_NAME,
    X_GROUP_DESC,
    X_USER_DISPLAY_NAME,
    X_USER_GROUP_DESC,
    user_id,
    TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
    user_id,
    TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
    0,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_EID_GROUPS_TL T
    where T.EID_INSTANCE_ID = X_EID_INSTANCE_ID
    and T.EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_EID_INSTANCE_ID in NUMBER,
  X_EID_INSTANCE_GROUP in VARCHAR2,
  X_EID_RELEASE_VERSION in VARCHAR2,
  X_EID_INSTANCE_GROUP_SEQ in NUMBER,
  X_EID_INSTANCE_GROUP_USER_SEQ in NUMBER,
  X_GROUP_SOURCE in VARCHAR2,
  X_OBSOLETED_FLAG in VARCHAR2,
  X_OBSOLETED_EID_RELEASE_VERSIO in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_GROUP_DESC in VARCHAR2,
  X_USER_DISPLAY_NAME in VARCHAR2,
  X_USER_GROUP_DESC in VARCHAR2
) is
  cursor c is select
      EID_RELEASE_VERSION,
      EID_INSTANCE_GROUP_SEQ,
      EID_INSTANCE_GROUP_USER_SEQ,
      GROUP_SOURCE,
      OBSOLETED_FLAG,
      OBSOLETED_EID_RELEASE_VERSION
    from FND_EID_GROUPS_B
    where EID_INSTANCE_ID = X_EID_INSTANCE_ID
    and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP
    for update of EID_INSTANCE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      GROUP_DESC,
      USER_DISPLAY_NAME,
      USER_GROUP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_EID_GROUPS_TL
    where EID_INSTANCE_ID = X_EID_INSTANCE_ID
    and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of EID_INSTANCE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.EID_RELEASE_VERSION = X_EID_RELEASE_VERSION)
           OR ((recinfo.EID_RELEASE_VERSION is null) AND (X_EID_RELEASE_VERSION is null)))
      AND ((recinfo.EID_INSTANCE_GROUP_SEQ = X_EID_INSTANCE_GROUP_SEQ)
           OR ((recinfo.EID_INSTANCE_GROUP_SEQ is null) AND (X_EID_INSTANCE_GROUP_SEQ is null)))
      AND ((recinfo.EID_INSTANCE_GROUP_USER_SEQ = X_EID_INSTANCE_GROUP_USER_SEQ)
           OR ((recinfo.EID_INSTANCE_GROUP_USER_SEQ is null) AND (X_EID_INSTANCE_GROUP_USER_SEQ is null)))
      AND ((recinfo.GROUP_SOURCE = X_GROUP_SOURCE)
           OR ((recinfo.GROUP_SOURCE is null) AND (X_GROUP_SOURCE is null)))
      AND ((recinfo.OBSOLETED_FLAG = X_OBSOLETED_FLAG)
           OR ((recinfo.OBSOLETED_FLAG is null) AND (X_OBSOLETED_FLAG is null)))
      AND ((recinfo.OBSOLETED_EID_RELEASE_VERSION = X_OBSOLETED_EID_RELEASE_VERSIO)
           OR ((recinfo.OBSOLETED_EID_RELEASE_VERSION is null) AND (X_OBSOLETED_EID_RELEASE_VERSIO is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND ((tlinfo.GROUP_DESC = X_GROUP_DESC)
               OR ((tlinfo.GROUP_DESC is null) AND (X_GROUP_DESC is null)))
          AND ((tlinfo.USER_DISPLAY_NAME = X_USER_DISPLAY_NAME)
               OR ((tlinfo.USER_DISPLAY_NAME is null) AND (X_USER_DISPLAY_NAME is null)))
          AND ((tlinfo.USER_GROUP_DESC = X_USER_GROUP_DESC)
               OR ((tlinfo.USER_GROUP_DESC is null) AND (X_USER_GROUP_DESC is null)))
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
  X_EID_INSTANCE_ID                 IN VARCHAR2,
  X_EID_INSTANCE_GROUP              IN VARCHAR2,
  X_EID_RELEASE_VERSION             IN VARCHAR2,
  X_EID_INSTANCE_GROUP_SEQ          IN VARCHAR2,
  X_EID_INSTANCE_GROUP_USER_SEQ     IN VARCHAR2,
  X_GROUP_SOURCE                    IN VARCHAR2,
  X_OBSOLETED_FLAG                  IN VARCHAR2,
  X_OBSOLETED_EID_REL_VER           IN VARCHAR2,
  X_DISPLAY_NAME                    IN VARCHAR2,
  X_GROUP_DESC                      IN VARCHAR2,
  X_USER_DISPLAY_NAME               IN VARCHAR2,
  X_USER_GROUP_DESC                 IN VARCHAR2,
  X_LAST_UPDATE_DATE                IN VARCHAR2,
  X_APPLICATION_SHORT_NAME          IN VARCHAR2,
  X_OWNER                           IN VARCHAR2
 ) is
  user_id NUMBER;
begin

  IF ( x_owner IS NOT NULL ) THEN
    user_id := fnd_load_util.owner_id(x_owner);
  ELSE
    user_id := -1;
  END IF;

  IF ( user_id > 0 ) THEN
  update FND_EID_GROUPS_B set
    EID_RELEASE_VERSION = X_EID_RELEASE_VERSION,
    EID_INSTANCE_GROUP_SEQ = X_EID_INSTANCE_GROUP_SEQ,
    EID_INSTANCE_GROUP_USER_SEQ = X_EID_INSTANCE_GROUP_USER_SEQ,
    GROUP_SOURCE = X_GROUP_SOURCE,
    OBSOLETED_FLAG = X_OBSOLETED_FLAG,
    OBSOLETED_EID_RELEASE_VERSION = X_OBSOLETED_EID_REL_VER,
    LAST_UPDATE_DATE = TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
    LAST_UPDATED_BY = user_id,
    LAST_UPDATE_LOGIN = 0
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID
  and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_EID_GROUPS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    GROUP_DESC = X_GROUP_DESC,
    USER_DISPLAY_NAME = X_USER_DISPLAY_NAME,
    USER_GROUP_DESC = X_USER_GROUP_DESC,
    LAST_UPDATE_DATE = TO_DATE(X_LAST_UPDATE_DATE,'YYYY/MM/DD'),
    LAST_UPDATED_BY = user_id,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID
  and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  END IF;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_EID_INSTANCE_ID in NUMBER,
  X_EID_INSTANCE_GROUP in VARCHAR2
) is
begin
  delete from FND_EID_GROUPS_TL
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID
  and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_EID_GROUPS_B
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID
  and EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP;

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

  delete from FND_EID_GROUPS_TL T
  where not exists
    (select NULL
    from FND_EID_GROUPS_B B
    where B.EID_INSTANCE_ID = T.EID_INSTANCE_ID
    and B.EID_INSTANCE_GROUP = T.EID_INSTANCE_GROUP
    );

  update FND_EID_GROUPS_TL T set (
      DISPLAY_NAME,
      GROUP_DESC,
      USER_DISPLAY_NAME,
      USER_GROUP_DESC
    ) = (select
      B.DISPLAY_NAME,
      B.GROUP_DESC,
      B.USER_DISPLAY_NAME,
      B.USER_GROUP_DESC
    from FND_EID_GROUPS_TL B
    where B.EID_INSTANCE_ID = T.EID_INSTANCE_ID
    and B.EID_INSTANCE_GROUP = T.EID_INSTANCE_GROUP
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EID_INSTANCE_ID,
      T.EID_INSTANCE_GROUP,
      T.LANGUAGE
  ) in (select
      SUBT.EID_INSTANCE_ID,
      SUBT.EID_INSTANCE_GROUP,
      SUBT.LANGUAGE
    from FND_EID_GROUPS_TL SUBB, FND_EID_GROUPS_TL SUBT
    where SUBB.EID_INSTANCE_ID = SUBT.EID_INSTANCE_ID
    and SUBB.EID_INSTANCE_GROUP = SUBT.EID_INSTANCE_GROUP
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.GROUP_DESC <> SUBT.GROUP_DESC
      or (SUBB.GROUP_DESC is null and SUBT.GROUP_DESC is not null)
      or (SUBB.GROUP_DESC is not null and SUBT.GROUP_DESC is null)
      or SUBB.USER_DISPLAY_NAME <> SUBT.USER_DISPLAY_NAME
      or (SUBB.USER_DISPLAY_NAME is null and SUBT.USER_DISPLAY_NAME is not null)
      or (SUBB.USER_DISPLAY_NAME is not null and SUBT.USER_DISPLAY_NAME is null)
      or SUBB.USER_GROUP_DESC <> SUBT.USER_GROUP_DESC
      or (SUBB.USER_GROUP_DESC is null and SUBT.USER_GROUP_DESC is not null)
      or (SUBB.USER_GROUP_DESC is not null and SUBT.USER_GROUP_DESC is null)
  ));

*/

  insert into FND_EID_GROUPS_TL (
    EID_INSTANCE_ID,
    EID_INSTANCE_GROUP,
    DISPLAY_NAME,
    GROUP_DESC,
    USER_DISPLAY_NAME,
    USER_GROUP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.EID_INSTANCE_ID,
    B.EID_INSTANCE_GROUP,
    B.DISPLAY_NAME,
    B.GROUP_DESC,
    B.USER_DISPLAY_NAME,
    B.USER_GROUP_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_EID_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_EID_GROUPS_TL T
    where T.EID_INSTANCE_ID = B.EID_INSTANCE_ID
    and T.EID_INSTANCE_GROUP = B.EID_INSTANCE_GROUP
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_EID_GROUPS_PKG;

/
