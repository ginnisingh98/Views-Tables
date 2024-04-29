--------------------------------------------------------
--  DDL for Package Body EGO_CATG_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CATG_MAP_PKG" as
/* $Header: EGOCTMPB.pls 120.1 2005/12/08 01:55:50 lparihar noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CATG_MAP_ID in NUMBER,
  X_SOURCE_CATG_SET_ID in NUMBER,
  X_TARGET_CATG_SET_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CATG_MAP_NAME in VARCHAR2,
  X_CATG_MAP_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from EGO_CATG_MAP_HDRS_B
    where CATG_MAP_ID = X_CATG_MAP_ID
    ;
begin
  insert into EGO_CATG_MAP_HDRS_B (
    CATG_MAP_ID,
    SOURCE_CATG_SET_ID,
    TARGET_CATG_SET_ID,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CATG_MAP_ID,
    X_SOURCE_CATG_SET_ID,
    X_TARGET_CATG_SET_ID,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EGO_CATG_MAP_HDRS_TL (
    CATG_MAP_ID,
    CATG_MAP_NAME,
    CATG_MAP_DESC,
    CREATION_DATE,
    CREATED_BY,
   LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CATG_MAP_ID,
    X_CATG_MAP_NAME,
    X_CATG_MAP_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EGO_CATG_MAP_HDRS_TL T
    where T.CATG_MAP_ID = X_CATG_MAP_ID
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
  X_CATG_MAP_ID in NUMBER,
  X_SOURCE_CATG_SET_ID in NUMBER,
  X_TARGET_CATG_SET_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CATG_MAP_NAME in VARCHAR2,
  X_CATG_MAP_DESC in VARCHAR2
) is
  cursor c is select
      SOURCE_CATG_SET_ID,
      TARGET_CATG_SET_ID,
      ENABLED_FLAG
    from EGO_CATG_MAP_HDRS_B
   where CATG_MAP_ID = X_CATG_MAP_ID
    for update of CATG_MAP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CATG_MAP_NAME,
      CATG_MAP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EGO_CATG_MAP_HDRS_TL
    where CATG_MAP_ID = X_CATG_MAP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CATG_MAP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SOURCE_CATG_SET_ID = X_SOURCE_CATG_SET_ID)
           OR ((recinfo.SOURCE_CATG_SET_ID is null) AND (X_SOURCE_CATG_SET_ID is null)))
     AND ((recinfo.TARGET_CATG_SET_ID = X_TARGET_CATG_SET_ID)
           OR ((recinfo.TARGET_CATG_SET_ID is null) AND (X_TARGET_CATG_SET_ID is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.CATG_MAP_NAME = X_CATG_MAP_NAME)
               OR ((tlinfo.CATG_MAP_NAME is null) AND (X_CATG_MAP_NAME is null)))
          AND ((tlinfo.CATG_MAP_DESC = X_CATG_MAP_DESC)
               OR ((tlinfo.CATG_MAP_DESC is null) AND (X_CATG_MAP_DESC is null)))
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
  X_CATG_MAP_ID in NUMBER,
  X_SOURCE_CATG_SET_ID in NUMBER,
  X_TARGET_CATG_SET_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CATG_MAP_NAME in VARCHAR2,
  X_CATG_MAP_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
BEGIN
  update EGO_CATG_MAP_HDRS_B set
    SOURCE_CATG_SET_ID = X_SOURCE_CATG_SET_ID,
    TARGET_CATG_SET_ID = X_TARGET_CATG_SET_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CATG_MAP_ID = X_CATG_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update EGO_CATG_MAP_HDRS_TL set
    CATG_MAP_NAME = X_CATG_MAP_NAME,
    CATG_MAP_DESC = X_CATG_MAP_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CATG_MAP_ID = X_CATG_MAP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_CATG_MAP_ID in NUMBER
) is
begin
  delete from EGO_CATG_MAP_HDRS_TL
  where CATG_MAP_ID = X_CATG_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from EGO_CATG_MAP_HDRS_B
  where CATG_MAP_ID = X_CATG_MAP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Load_Row
(
  X_CATG_MAP_ID          in NUMBER,
  X_SOURCE_CATG_SET_NAME in VARCHAR2,
  X_TARGET_CATG_SET_NAME in VARCHAR2,
  X_ENABLED_FLAG         in VARCHAR2,
  X_OWNER                in VARCHAR2,
  X_LAST_UPDATE_DATE     in VARCHAR2,
  X_CATG_MAP_NAME        in VARCHAR2,
  X_CATG_MAP_DESC        in VARCHAR2
) IS
  l_catg_map_id            NUMBER;
  l_source_catg_set_id     NUMBER;
  l_target_catg_set_id     NUMBER;
  l_current_user_id        NUMBER       := EGO_SCTX.Get_User_Id();
  l_current_login_id       NUMBER       := FND_GLOBAL.Login_Id;


  CURSOR get_catg_map_id(l_source_catg_set_id NUMBER, l_target_catg_set_id NUMBER)
  IS
  SELECT CATG_MAP_ID
    FROM EGO_CATG_MAP_HDRS_B
   WHERE SOURCE_CATG_SET_ID = l_source_catg_set_id
     AND TARGET_CATG_SET_ID = l_target_catg_set_id;

  BEGIN

    BEGIN
      -- getting the source catg set id by passing the source category_set_name
      SELECT CATEGORY_SET_ID SOURCE_CATG_SET_ID
	INTO l_source_catg_set_id
	FROM MTL_CATEGORY_SETS
       WHERE CATEGORY_SET_NAME = X_SOURCE_CATG_SET_NAME;

    EXCEPTION
      WHEN no_data_found THEN
	fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
	fnd_message.set_token('ROUTINE','Category Mapping');
	fnd_message.set_token('REASON','Source Category Set ' || X_SOURCE_CATG_SET_NAME || ' does not exist ' );
	app_exception.raise_exception;
    END;

    BEGIN
      -- getting the target catg set id by passing the target category_set_name
      SELECT CATEGORY_SET_ID TARGET_CATG_SET_ID
	INTO l_target_catg_set_id
	FROM MTL_CATEGORY_SETS
       WHERE CATEGORY_SET_NAME = X_TARGET_CATG_SET_NAME;

    EXCEPTION
	  WHEN no_data_found THEN
	    fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
	    fnd_message.set_token('ROUTINE','Category Mapping');
	    fnd_message.set_token('REASON','Target Category Set ' || X_TARGET_CATG_SET_NAME || ' does not exist ' );
	    app_exception.raise_exception;
    END;

    -- trying to findout whether the catg_map id exists for the source and target category sets
    OPEN get_catg_map_id(l_source_catg_set_id, l_target_catg_set_id);
    -- if it doesn't exist, inserting in to the ego_catg_map_header table
    FETCH get_catg_map_id INTO l_catg_map_id;
    if (get_catg_map_id%NOTFOUND) THEN
      select EGO_CATG_MAPS_S.nextval into l_catg_map_id from dual;

      INSERT INTO EGO_CATG_MAP_HDRS_B
      (
	CATG_MAP_ID,
	SOURCE_CATG_SET_ID,
	TARGET_CATG_SET_ID,
	ENABLED_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
      )  VALUES
      (
	 l_catg_map_id,
	 l_source_catg_set_id,
	 l_target_catg_set_id,
	 X_ENABLED_FLAG,
	 l_current_user_id,
	 sysdate,
	 l_current_user_id,
	 sysdate,
	 l_current_login_id
       );

       INSERT INTO EGO_CATG_MAP_HDRS_TL
	(
	  CATG_MAP_ID,
	  LANGUAGE,
	  SOURCE_LANG,
	  CATG_MAP_NAME,
	  CATG_MAP_DESC,
	  CREATED_BY,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN)
	SELECT
	  l_catg_map_id,
	  L.LANGUAGE_CODE,
	  USERENV('LANG'),
	  X_CATG_MAP_NAME,
	  X_CATG_MAP_DESC,
	  l_current_user_id,
	  sysdate,
	  l_current_user_id,
	  sysdate,
	  l_current_login_id
	  FROM FND_LANGUAGES L
	 WHERE L.INSTALLED_FLAG IN ('I','B')
	   AND NOT EXISTS(SELECT 'X' FROM EGO_CATG_MAP_HDRS_TL A
			   WHERE A.CATG_MAP_ID = l_catg_map_id
			     AND A.LANGUAGE = L.LANGUAGE_CODE);
     ELSE

       -- if it does exist updating the enabled flag and description
       UPDATE EGO_CATG_MAP_HDRS_B
	  SET ENABLED_FLAG      = X_ENABLED_FLAG,
	      LAST_UPDATED_BY   = l_current_user_id,
	      LAST_UPDATE_DATE  = sysdate,
	      LAST_UPDATE_LOGIN = l_current_login_id
	WHERE SOURCE_CATG_SET_ID = l_source_catg_set_id
	  AND TARGET_CATG_SET_ID = l_target_catg_set_id
	  AND CATG_MAP_ID = l_catg_map_id;

       UPDATE EGO_CATG_MAP_HDRS_TL
	  SET CATG_MAP_DESC     = X_CATG_MAP_DESC,
	      LAST_UPDATED_BY   = l_current_user_id,
	      LAST_UPDATE_DATE  = sysdate,
	      LAST_UPDATE_LOGIN = l_current_login_id
	WHERE CATG_MAP_ID = l_catg_map_id
	 AND  USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);
     END IF;
     CLOSE get_catg_map_id;

END Load_Row;


PROCEDURE Load_Row
(
  X_CATG_MAP_ID          in NUMBER,
  X_SOURCE_CATG_SET_NAME in VARCHAR2,
  X_TARGET_CATG_SET_NAME in VARCHAR2,
  X_OWNER                in VARCHAR2,
  X_LAST_UPDATE_DATE     in VARCHAR2,
  X_SOURCE_CATG_NAME     in VARCHAR2,
  X_TARGET_CATG_NAME     in VARCHAR2
) IS

  l_source_catg_id       NUMBER;
  l_target_catg_id       NUMBER;
  l_current_user_id      NUMBER       := EGO_SCTX.Get_User_Id();
  l_current_login_id     NUMBER       := FND_GLOBAL.Login_Id;
  l_source_catg_set_id   NUMBER;
  l_target_catg_set_id   NUMBER;
  l_catg_map_id          NUMBER;
  l_count                NUMBER;

  CURSOR get_catg_map_id(l_source_catg_set_id NUMBER, l_target_catg_set_id NUMBER)
  IS
  SELECT CATG_MAP_ID
    FROM EGO_CATG_MAP_HDRS_B
   WHERE SOURCE_CATG_SET_ID = l_source_catg_set_id
     AND TARGET_CATG_SET_ID = l_target_catg_set_id;

  CURSOR is_catg_map_dtls_exists(l_catg_map_id NUMBER,
                                 l_source_catg_id NUMBER,
                                 l_target_catg_id NUMBER)
  IS
  SELECT 1
   FROM EGO_CATG_MAP_DTLS
  WHERE CATG_MAP_ID = l_catg_map_id
    AND SOURCE_CATG_ID = l_source_catg_id
    AND TARGET_CATG_ID = l_target_catg_id
    AND ROWNUM = 1;

 BEGIN

    -- getting the source catg set id by passing the source category_set_name
    SELECT B.CATEGORY_SET_ID SOURCE_CATG_SET_ID
      INTO l_source_catg_set_id
      FROM MTL_CATEGORY_SETS B
     WHERE B.CATEGORY_SET_NAME = X_SOURCE_CATG_SET_NAME;

    -- getting the target catg set id by passing the target category_set_name
    SELECT CATEGORY_SET_ID TARGET_CATG_SET_ID
      INTO l_target_catg_set_id
      FROM MTL_CATEGORY_SETS
     WHERE CATEGORY_SET_NAME = X_TARGET_CATG_SET_NAME;

    -- getting the source category id by passing the source category_name
    BEGIN
      SELECT A.CATEGORY_ID SOURCE_CATG_ID
	INTO l_source_catg_id
	FROM MTL_CATEGORIES_B_KFV A,
	     MTL_CATEGORY_SETS B
       WHERE B.CATEGORY_SET_ID = l_source_catg_set_id
	 AND A.STRUCTURE_ID = B.STRUCTURE_ID
	 AND A.CONCATENATED_SEGMENTS = X_SOURCE_CATG_NAME;
    EXCEPTION
       WHEN no_data_found THEN
	 fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
	 fnd_message.set_token('ROUTINE','Category Mapping');
	 fnd_message.set_token('REASON','Source Category ' || X_SOURCE_CATG_NAME || ' does not exist under catalog ' || X_SOURCE_CATG_SET_NAME );
	-- app_exception.raise_exception;
    END;

    -- getting the target category id by passing the target category_name
    BEGIN

      SELECT A.CATEGORY_ID TARGET_CATG_ID
	INTO l_target_catg_id
	FROM MTL_CATEGORIES_B_KFV A,
	     MTL_CATEGORY_SETS B
       WHERE B.CATEGORY_SET_ID = l_target_catg_set_id
	 AND A.STRUCTURE_ID = B.STRUCTURE_ID
	 AND A.CONCATENATED_SEGMENTS = X_TARGET_CATG_NAME;
    EXCEPTION
       WHEN no_data_found THEN
	 fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
	 fnd_message.set_token('ROUTINE','Category Mapping');
	 fnd_message.set_token('REASON','Target Category ' || X_TARGET_CATG_NAME || ' does not exist under catalog ' || X_TARGET_CATG_SET_NAME);
      --    app_exception.raise_exception;
    END;


    -- Getting the category map id based on the source and the target catg sets
    OPEN get_catg_map_id(l_source_catg_set_id,
			 l_target_catg_set_id);
    FETCH get_catg_map_id INTO l_catg_map_id;
    CLOSE get_catg_map_id;

    OPEN is_catg_map_dtls_exists(l_catg_map_id,
				 l_source_catg_id,
				 l_target_catg_id);

    -- if it doesn't exists, inserting the data in to the ego_catg_map_dtls table
    FETCH is_catg_map_dtls_exists INTO l_count;
    if (is_catg_map_dtls_exists%NOTFOUND) THEN


    BEGIN
      INSERT INTO EGO_CATG_MAP_DTLS
      (
	 CATG_MAP_ID,
	 SOURCE_CATG_ID,
	 TARGET_CATG_ID,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATE_LOGIN
      ) VALUES
      (
	 l_catg_map_id,
	 l_source_catg_id,
	 l_target_catg_id,
	 l_current_user_id,
	 sysdate,
	 l_current_user_id,
	 sysdate,
	 l_current_login_id
	 );

    EXCEPTION
     WHEN OTHERS THEN
      null;
    END;

    END IF;
    CLOSE is_catg_map_dtls_exists;

 END Load_Row;

PROCEDURE Translate_Row
(
  X_CATG_MAP_ID          in NUMBER,
  X_SOURCE_CATG_SET_NAME in VARCHAR2,
  X_TARGET_CATG_SET_NAME in VARCHAR2,
  X_ENABLED_FLAG         in VARCHAR2,
  X_OWNER                in VARCHAR2,
  X_LAST_UPDATE_DATE     in VARCHAR2,
  X_CATG_MAP_NAME        in VARCHAR2,
  X_CATG_MAP_DESC        in VARCHAR2
) IS

  f_luby         NUMBER;  -- entity owner in file
  f_ludate       DATE;    -- entity update date in file
  db_luby        NUMBER;  -- entity owner in db
  db_ludate      DATE;    -- entity update date in db

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby   := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := SYSDATE;

  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
  INTO   db_luby, db_ludate
  FROM   EGO_CATG_MAP_HDRS_TL TL
  WHERE  TL.catg_map_id = X_CATG_MAP_ID
  AND    userenv('LANG') IN (language, source_lang);

  IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, NULL)) THEN

     UPDATE  EGO_CATG_MAP_HDRS_TL TL
     SET  TL.CATG_MAP_NAME  = NVL(x_CATG_MAP_NAME, CATG_MAP_NAME)
       ,  TL.CATG_MAP_DESC  = NVL(x_CATG_MAP_DESC, CATG_MAP_DESC)
       ,  last_update_date  = db_ludate
       ,  last_updated_by   = db_luby
       ,  last_update_login = 0
       ,  source_lang       = userenv('LANG')
     WHERE  TL.catg_map_id = X_CATG_MAP_ID
     AND  userenv('LANG') IN (language, source_lang);

  END IF;
END Translate_Row;



procedure ADD_LANGUAGE
is
begin
  delete from EGO_CATG_MAP_HDRS_TL T
  where not exists
    (select NULL
    from EGO_CATG_MAP_HDRS_B B
    where B.CATG_MAP_ID = T.CATG_MAP_ID
    );

  update EGO_CATG_MAP_HDRS_TL T set (
      CATG_MAP_NAME,
      CATG_MAP_DESC
    ) = (select
      B.CATG_MAP_NAME,
      B.CATG_MAP_DESC
    from EGO_CATG_MAP_HDRS_TL B
    where B.CATG_MAP_ID = T.CATG_MAP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATG_MAP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATG_MAP_ID,
      SUBT.LANGUAGE
    from EGO_CATG_MAP_HDRS_TL SUBB, EGO_CATG_MAP_HDRS_TL SUBT
    where SUBB.CATG_MAP_ID = SUBT.CATG_MAP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CATG_MAP_NAME <> SUBT.CATG_MAP_NAME
      or (SUBB.CATG_MAP_NAME is null and SUBT.CATG_MAP_NAME is not null)
      or (SUBB.CATG_MAP_NAME is not null and SUBT.CATG_MAP_NAME is null)
      or SUBB.CATG_MAP_DESC <> SUBT.CATG_MAP_DESC
      or (SUBB.CATG_MAP_DESC is null and SUBT.CATG_MAP_DESC is not null)
      or (SUBB.CATG_MAP_DESC is not null and SUBT.CATG_MAP_DESC is null)
  ));

  insert into EGO_CATG_MAP_HDRS_TL (
    CATG_MAP_ID,
    CATG_MAP_NAME,
    CATG_MAP_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CATG_MAP_ID,
    B.CATG_MAP_NAME,
    B.CATG_MAP_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_CATG_MAP_HDRS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_CATG_MAP_HDRS_TL T
    where T.CATG_MAP_ID = B.CATG_MAP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end EGO_CATG_MAP_PKG;

/
