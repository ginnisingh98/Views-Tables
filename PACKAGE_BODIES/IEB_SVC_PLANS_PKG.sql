--------------------------------------------------------
--  DDL for Package Body IEB_SVC_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEB_SVC_PLANS_PKG" as
/* $Header: IEBSVCPB.pls 120.3 2005/09/29 06:17:12 appldev noship $ */

procedure INSERT_ROW_B (
  P_SVCPLN_ID             IN NUMBER,
  P_SERVICE_PLAN_NAME     IN VARCHAR2,
  P_DIRECTION             IN VARCHAR2,
  P_TREATMENT             IN VARCHAR2,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_MEDIA_TYPE_ID         IN NUMBER,
  P_OWNER_ID			 IN NUMBER,
  X_ROWID                 IN OUT NOCOPY VARCHAR2
) is
  cursor C is select ROWID from IEB_SERVICE_PLANS
    where SVCPLN_ID = P_SVCPLN_ID ;
begin

  insert into IEB_SERVICE_PLANS (
    SVCPLN_ID,
    SERVICE_PLAN_NAME,
    DIRECTION,
    TREATMENT,
    OBJECT_VERSION_NUMBER ,
    MEDIA_TYPE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_SVCPLN_ID,
    P_SERVICE_PLAN_NAME,
    P_DIRECTION,
    P_TREATMENT,
    P_OBJECT_VERSION_NUMBER,
    P_MEDIA_TYPE_ID,
    SYSDATE,
    P_OWNER_ID,
    SYSDATE,
    P_OWNER_ID,
    FND_GLOBAL.LOGIN_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW_B;


procedure INSERT_ROW_TL (
  P_SVCPLN_ID             IN NUMBER,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_OWNER_ID			 IN NUMBER,
  X_ROWID                 IN OUT NOCOPY VARCHAR2
) is
  cursor C is select ROWID from IEB_SERVICE_PLANS_TL
    where SERVICE_PLAN_ID = P_SVCPLN_ID;
begin

  insert into IEB_SERVICE_PLANS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    SERVICE_PLAN_ID,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    PLAN_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    SYSDATE,
    P_OWNER_ID,
    SYSDATE,
    P_OWNER_ID,
    P_SVCPLN_ID,
    P_OBJECT_VERSION_NUMBER,
    P_DESCRIPTION,
    FND_GLOBAL.LOGIN_ID,
    P_PLAN_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  FROM FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEB_SERVICE_PLANS_TL T
    where T.SERVICE_PLAN_ID = P_SVCPLN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW_TL;

procedure LOCK_ROW (
  P_SVCPLN_ID             IN NUMBER,
  P_SERVICE_PLAN_NAME     IN VARCHAR2,
  P_DIRECTION             IN VARCHAR2,
  P_TREATMENT             IN VARCHAR2,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_MEDIA_TYPE_ID         IN NUMBER
) is
  cursor c is select
      SERVICE_PLAN_NAME,
      DIRECTION,
      TREATMENT,
      OBJECT_VERSION_NUMBER,
      MEDIA_TYPE_ID
    FROM IEB_SERVICE_PLANS
    WHERE SVCPLN_ID = P_SVCPLN_ID
    FOR update of SVCPLN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PLAN_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    FROM IEB_SERVICE_PLANS_TL
    WHERE SERVICE_PLAN_ID = P_SVCPLN_ID
    AND userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    FOR update of SERVICE_PLAN_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SERVICE_PLAN_NAME = P_SERVICE_PLAN_NAME)
      AND (recinfo.DIRECTION = P_DIRECTION)
      AND ((recinfo.TREATMENT = P_TREATMENT)
           OR ((recinfo.TREATMENT is null) AND (P_TREATMENT is null)))
      AND ((recinfo.MEDIA_TYPE_ID = P_MEDIA_TYPE_ID)
           OR ((recinfo.MEDIA_TYPE_ID is null) AND (P_MEDIA_TYPE_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER))
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PLAN_NAME = P_PLAN_NAME)
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

procedure UPDATE_ROW_B (
  P_SVCPLN_ID             IN NUMBER,
  P_SERVICE_PLAN_NAME             IN VARCHAR2,
  P_DIRECTION             IN VARCHAR2,
  P_TREATMENT             IN VARCHAR2,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_MEDIA_TYPE_ID         IN NUMBER,
  P_OWNER_ID			 IN NUMBER
) is
begin
  update IEB_SERVICE_PLANS set
    SERVICE_PLAN_NAME = P_SERVICE_PLAN_NAME,
    DIRECTION = P_DIRECTION,
    TREATMENT = P_TREATMENT,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    MEDIA_TYPE_ID = P_MEDIA_TYPE_ID,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = P_OWNER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
  where SVCPLN_ID = P_SVCPLN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW_B;

procedure UPDATE_ROW_TL (
  P_SVCPLN_ID             IN NUMBER,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_OWNER_ID              IN NUMBER
) is
begin
  update IEB_SERVICE_PLANS_TL set
    PLAN_NAME = P_PLAN_NAME,
    DESCRIPTION = P_DESCRIPTION,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = P_OWNER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
    SOURCE_LANG = userenv('LANG')
  where SERVICE_PLAN_ID = P_SVCPLN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW_TL;


procedure DELETE_ROW (
  P_SVCPLN_ID in NUMBER
) is
begin
  delete from IEB_SERVICE_PLANS
  where SVCPLN_ID = P_SVCPLN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEB_SERVICE_PLANS_TL
  where SERVICE_PLAN_ID = P_SVCPLN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEB_SERVICE_PLANS_TL T
  where not exists
    (select NULL
    from IEB_SERVICE_PLANS B
    where B.SVCPLN_ID = T.SERVICE_PLAN_ID
    );

  update IEB_SERVICE_PLANS_TL T set (
      PLAN_NAME,
      DESCRIPTION
    ) = (select
      B.PLAN_NAME,
      B.DESCRIPTION
    from IEB_SERVICE_PLANS_TL B
    where B.SERVICE_PLAN_ID = T.SERVICE_PLAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SERVICE_PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SERVICE_PLAN_ID,
      SUBT.LANGUAGE
    from IEB_SERVICE_PLANS_TL SUBB, IEB_SERVICE_PLANS_TL SUBT
    where SUBB.SERVICE_PLAN_ID = SUBT.SERVICE_PLAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PLAN_NAME <> SUBT.PLAN_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into IEB_SERVICE_PLANS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    SERVICE_PLAN_ID,
    OBJECT_VERSION_NUMBER,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    PLAN_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.SERVICE_PLAN_ID,
    B.OBJECT_VERSION_NUMBER,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.PLAN_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEB_SERVICE_PLANS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEB_SERVICE_PLANS_TL T
    where T.SERVICE_PLAN_ID = B.SERVICE_PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  P_SVCPLN_ID   IN NUMBER,
  P_PLAN_NAME   IN VARCHAR2,
  P_DESCRIPTION IN VARCHAR2,
  P_OWNER       IN VARCHAR2
) IS

BEGIN
  --only update rows that have not been altered by user
  UPDATE IEB_SERVICE_PLANS_TL
  SET
    PLAN_NAME = P_PLAN_NAME,
    SOURCE_LANG = userenv( 'LANG' ),
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = fnd_load_util.owner_id(P_OWNER),
    LAST_UPDATE_LOGIN = 0
  WHERE
    SERVICE_PLAN_ID = P_SVCPLN_ID
  AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

END TRANSLATE_ROW;


procedure LOAD_ROW (
  P_SVCPLN_ID             IN NUMBER,
  P_SERVICE_PLAN_NAME     IN VARCHAR2,
  P_DIRECTION             IN VARCHAR2,
  P_TREATMENT             IN VARCHAR2,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_MEDIA_TYPE_ID         IN NUMBER,
  P_OWNER                 IN VARCHAR2
) IS

BEGIN

    DECLARE
       user_id NUMBER := 0;
       rowid   VARCHAR2(50);
    BEGIN

      user_id := fnd_load_util.owner_id(P_OWNER);

      BEGIN
        UPDATE_ROW_B (
          P_SVCPLN_ID             ,
          P_SERVICE_PLAN_NAME     ,
          P_DIRECTION             ,
          P_TREATMENT             ,
          P_PLAN_NAME             ,
          P_DESCRIPTION           ,
          P_OBJECT_VERSION_NUMBER ,
          P_MEDIA_TYPE_ID         ,
		user_id
        );

        EXCEPTION
          when no_data_found then

        INSERT_ROW_B (
          P_SVCPLN_ID             ,
          P_SERVICE_PLAN_NAME     ,
          P_DIRECTION             ,
          P_TREATMENT             ,
          P_PLAN_NAME             ,
          P_DESCRIPTION           ,
          P_OBJECT_VERSION_NUMBER ,
          P_MEDIA_TYPE_ID         ,
		user_id,
          rowid
        );
      END;

      BEGIN
        UPDATE_ROW_TL (
          P_SVCPLN_ID             ,
          P_PLAN_NAME             ,
          P_DESCRIPTION           ,
          P_OBJECT_VERSION_NUMBER ,
		user_id
        );

        EXCEPTION
          when no_data_found then

        INSERT_ROW_TL (
          P_SVCPLN_ID             ,
          P_PLAN_NAME             ,
          P_DESCRIPTION           ,
          P_OBJECT_VERSION_NUMBER ,
		user_id,
          rowid
        );
      END;
    END;

END LOAD_ROW;

procedure LOAD_SEED_ROW (
  P_SVCPLN_ID             IN NUMBER,
  P_SERVICE_PLAN_NAME     IN VARCHAR2,
  P_DIRECTION             IN VARCHAR2,
  P_TREATMENT             IN VARCHAR2,
  P_PLAN_NAME             IN VARCHAR2,
  P_DESCRIPTION           IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_MEDIA_TYPE_ID         IN NUMBER,
  P_OWNER                 IN VARCHAR2,
  P_UPLOAD_MODE           IN VARCHAR2
 ) IS
 BEGIN
 IF (P_UPLOAD_MODE = 'NLS') THEN
   IEB_SVC_PLANS_PKG.TRANSLATE_ROW (
                  P_SVCPLN_ID,
	             P_PLAN_NAME,
			   P_DESCRIPTION,
			   P_OWNER );
 ELSE
   IEB_SVC_PLANS_PKG.LOAD_ROW(
             P_SVCPLN_ID,
             P_SERVICE_PLAN_NAME,
	        P_DIRECTION,
	        P_TREATMENT,
	        P_PLAN_NAME,
	        P_DESCRIPTION,
	        P_OBJECT_VERSION_NUMBER,
	        P_MEDIA_TYPE_ID,
	        P_OWNER );
  END IF;
 END LOAD_SEED_ROW;

end IEB_SVC_PLANS_PKG;

/
