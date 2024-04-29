--------------------------------------------------------
--  DDL for Package Body HZ_MATCH_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MATCH_RULES_PKG" AS
/*$Header: ARHDQMRB.pls 120.13 2006/05/05 18:52:30 repuri noship $ */

procedure INSERT_ROW (
  X_MATCH_RULE_ID in out NOCOPY NUMBER,
  X_RULE_PURPOSE in VARCHAR2,
  X_MATCH_ALL_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NO_OVERRIDE_SCORE in NUMBER,
  X_AUTO_MERGE_SCORE in NUMBER,
  X_COMPILATION_FLAG in VARCHAR2,
  X_MATCH_SCORE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_AUTOMERGE_FLAG IN VARCHAR2,
  X_MATCH_RULE_TYPE  IN VARCHAR2,
  X_USE_CONTACT_ADDR_FLAG IN VARCHAR2 DEFAULT NULL,
  X_USE_CONTACT_CPT_FLAG IN VARCHAR2 DEFAULT NULL

) is

   CURSOR C2 IS SELECT  HZ_MATCH_RULES_s.nextval FROM sys.dual;
   l_success VARCHAR2(1) := 'N';
 BEGIN
    WHILE l_success = 'N' LOOP
    BEGIN
      IF ( X_MATCH_RULE_ID IS NULL) OR (X_MATCH_RULE_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO X_MATCH_RULE_ID;
        CLOSE C2;
      END IF;

      insert into HZ_MATCH_RULES_B (
        RULE_PURPOSE,
        MATCH_ALL_FLAG,
        ACTIVE_FLAG,
        NO_OVERRIDE_SCORE,
        AUTO_MERGE_SCORE,
        COMPILATION_FLAG,
        MATCH_RULE_ID,
        MATCH_SCORE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER,
        AUTOMERGE_FLAG,
        MATCH_RULE_TYPE,
        USE_CONTACT_ADDR_FLAG,
        USE_CONTACT_CPT_FLAG
      ) values (
        X_RULE_PURPOSE,
        X_MATCH_ALL_FLAG,
        X_ACTIVE_FLAG,
        X_NO_OVERRIDE_SCORE,
        X_AUTO_MERGE_SCORE,
        X_COMPILATION_FLAG,
        X_MATCH_RULE_ID,
        X_MATCH_SCORE,
        hz_utility_v2pub.creation_date,
        X_CREATED_BY,
        hz_utility_v2pub.last_update_date,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN,
        1,
        X_AUTOMERGE_FLAG,
	X_MATCH_RULE_TYPE,
        X_USE_CONTACT_ADDR_FLAG,
        X_USE_CONTACT_CPT_FLAG
      );


      l_success := 'Y';
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
         IF INSTRB( SQLERRM, 'HZ_MATCH_RULES_B_U1' ) <> 0 THEN
            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);
            BEGIN
              l_count := 1;
              WHILE l_count > 0 LOOP
                 SELECT  HZ_MATCH_RULES_s.nextval
		  into  X_MATCH_RULE_ID FROM sys.dual;
                 BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM HZ_MATCH_RULES_B
                  WHERE MATCH_RULE_ID =  X_MATCH_RULE_ID;
                  l_count := 1;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                  l_count := 0;
                 END;
             END LOOP;
          END;
        END IF;
     END;
  END LOOP;

  insert into HZ_MATCH_RULES_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    DESCRIPTION,
    RULE_NAME,
    MATCH_RULE_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    OBJECT_VERSION_NUMBER
  ) select
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_DESCRIPTION,
    X_RULE_NAME,
    X_MATCH_RULE_ID,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    1
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_MATCH_RULES_TL T
    where T.MATCH_RULE_ID = X_MATCH_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


 end INSERT_ROW;

procedure INSERT_ROW (
  X_MATCH_RULE_ID in out NOCOPY NUMBER,
  X_RULE_PURPOSE in VARCHAR2,
  X_MATCH_ALL_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NO_OVERRIDE_SCORE in NUMBER,
  X_AUTO_MERGE_SCORE in NUMBER,
  X_COMPILATION_FLAG in VARCHAR2,
  X_MATCH_SCORE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_AUTOMERGE_FLAG IN VARCHAR2 DEFAULT 'N',
  X_USE_CONTACT_ADDR_FLAG IN VARCHAR2 DEFAULT NULL,
  X_USE_CONTACT_CPT_FLAG IN VARCHAR2 DEFAULT NULL
) is

 BEGIN
  INSERT_ROW(X_MATCH_RULE_ID,X_RULE_PURPOSE,X_MATCH_ALL_FLAG,X_ACTIVE_FLAG,X_NO_OVERRIDE_SCORE,
             X_AUTO_MERGE_SCORE,X_COMPILATION_FLAG,X_MATCH_SCORE,X_RULE_NAME,X_DESCRIPTION,
	     X_CREATION_DATE,X_CREATED_BY,X_LAST_UPDATE_DATE,X_LAST_UPDATED_BY,X_LAST_UPDATE_LOGIN,
	     X_OBJECT_VERSION_NUMBER,X_AUTOMERGE_FLAG,'SINGLE',X_USE_CONTACT_ADDR_FLAG, X_USE_CONTACT_CPT_FLAG );
 end INSERT_ROW;

procedure LOCK_ROW (
  X_MATCH_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is
  cursor c is select
     OBJECT_VERSION_NUMBER
    from HZ_MATCH_RULES_B
    where MATCH_RULE_ID = X_MATCH_RULE_ID
    for update of MATCH_RULE_ID nowait;
  recinfo c%rowtype;

begin
  open c;

   fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if(
       ( recinfo.OBJECT_VERSION_NUMBER IS NULL AND X_object_version_number IS NULL )
       OR ( recinfo.OBJECT_VERSION_NUMBER IS NOT NULL AND
          X_object_version_number IS NOT NULL AND
          recinfo.OBJECT_VERSION_NUMBER = X_object_version_number )
     ) then
       null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

PROCEDURE uncompile_match_rule_sets(p_rule_id NUMBER)
IS

BEGIN
 UPDATE HZ_MATCH_RULES_B
 SET    COMPILATION_FLAG = 'U'
 WHERE  MATCH_RULE_ID IN (SELECT DISTINCT MATCH_RULE_SET_ID
			  FROM  HZ_MATCH_RULE_CONDITIONS
			  WHERE CONDITION_MATCH_RULE_ID = p_rule_id
			 )
 AND   nvl(COMPILATION_FLAG,'N') = 'C';

END;

procedure UPDATE_ROW (
  X_MATCH_RULE_ID in NUMBER,
  X_RULE_PURPOSE in VARCHAR2,
  X_MATCH_ALL_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NO_OVERRIDE_SCORE in NUMBER,
  X_AUTO_MERGE_SCORE in NUMBER,
  X_COMPILATION_FLAG in VARCHAR2,
  X_MATCH_SCORE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
  X_AUTOMERGE_FLAG IN VARCHAR2 DEFAULT NULL,
  X_USE_CONTACT_ADDR_FLAG IN VARCHAR2 DEFAULT NULL,
  X_USE_CONTACT_CPT_FLAG IN VARCHAR2 DEFAULT NULL
) is

 p_object_version_number number;
begin

  p_object_version_number := NVL(X_object_version_number, 1) + 1;

 update HZ_MATCH_RULES_B set
    RULE_PURPOSE = X_RULE_PURPOSE,
    MATCH_ALL_FLAG = X_MATCH_ALL_FLAG,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    NO_OVERRIDE_SCORE = X_NO_OVERRIDE_SCORE,
    AUTO_MERGE_SCORE = X_AUTO_MERGE_SCORE,
    COMPILATION_FLAG = X_COMPILATION_FLAG,
    MATCH_SCORE = X_MATCH_SCORE,
    LAST_UPDATE_DATE = hz_utility_v2pub.last_update_date,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER,
    AUTOMERGE_FLAG =   NVL(X_AUTOMERGE_FLAG,AUTOMERGE_FLAG),
    USE_CONTACT_ADDR_FLAG = X_USE_CONTACT_ADDR_FLAG,
    USE_CONTACT_CPT_FLAG =  X_USE_CONTACT_CPT_FLAG
  where MATCH_RULE_ID = X_MATCH_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HZ_MATCH_RULES_TL set
    RULE_NAME = X_RULE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE =hz_utility_v2pub.last_update_date,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
    OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER
  where MATCH_RULE_ID = X_MATCH_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

 X_OBJECT_VERSION_NUMBER := p_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
   --Uncompile all the match rule sets having this match rule as a condition match rule.
   uncompile_match_rule_sets(X_MATCH_RULE_ID);
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MATCH_RULE_ID in NUMBER
) is
begin
  --Uncompile all the match rule sets having this match rule as a condition match rule.
  uncompile_match_rule_sets(X_MATCH_RULE_ID);

  -- Start of changes for Bug 3962742
  --Delete associated entries in following entities
  DELETE FROM HZ_SECONDARY_TRANS
  WHERE  secondary_attribute_id IN (SELECT secondary_attribute_id
                                    FROM  HZ_MATCH_RULE_SECONDARY
                                    WHERE match_rule_id = X_MATCH_RULE_ID);

  DELETE FROM HZ_PRIMARY_TRANS
  WHERE  primary_attribute_id  IN (SELECT primary_attribute_id
                                   FROM   HZ_MATCH_RULE_PRIMARY
                                   WHERE match_rule_id = X_MATCH_RULE_ID);

  DELETE FROM HZ_MATCH_RULE_SECONDARY
  WHERE  MATCH_RULE_ID = X_MATCH_RULE_ID;

  DELETE FROM HZ_MATCH_RULE_PRIMARY
  WHERE  MATCH_RULE_ID = X_MATCH_RULE_ID;

  -- End of changes for Bug 3962742

  delete from HZ_MATCH_RULES_TL
  where MATCH_RULE_ID = X_MATCH_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_MATCH_RULES_B
  where MATCH_RULE_ID = X_MATCH_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HZ_MATCH_RULES_TL T
  where not exists
    (select NULL
    from HZ_MATCH_RULES_B B
    where B.MATCH_RULE_ID = T.MATCH_RULE_ID
    );

  update HZ_MATCH_RULES_TL T set (
      RULE_NAME,
      DESCRIPTION
    ) = (select
      B.RULE_NAME,
      B.DESCRIPTION
    from HZ_MATCH_RULES_TL B
    where B.MATCH_RULE_ID = T.MATCH_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
         T.MATCH_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MATCH_RULE_ID,
      SUBT.LANGUAGE
    from HZ_MATCH_RULES_TL SUBB, HZ_MATCH_RULES_TL SUBT
    where SUBB.MATCH_RULE_ID = SUBT.MATCH_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RULE_NAME <> SUBT.RULE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into HZ_MATCH_RULES_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    DESCRIPTION,
    RULE_NAME,
    MATCH_RULE_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.DESCRIPTION,
    B.RULE_NAME,
    B.MATCH_RULE_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_MATCH_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and L.LANGUAGE_CODE <> B.LANGUAGE
  and not exists
    (select NULL
    from HZ_MATCH_RULES_TL T
    where T.MATCH_RULE_ID = B.MATCH_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_MATCH_RULE_ID in NUMBER,
  X_RULE_PURPOSE in VARCHAR2,
  X_MATCH_ALL_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NO_OVERRIDE_SCORE in NUMBER,
  X_AUTO_MERGE_SCORE in NUMBER,
  X_COMPILATION_FLAG in VARCHAR2,
  X_MATCH_SCORE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2,
  X_AUTOMERGE_FLAG IN VARCHAR2 DEFAULT NULL,
  X_USE_CONTACT_ADDR_FLAG IN VARCHAR2 DEFAULT NULL,
  X_USE_CONTACT_CPT_FLAG IN VARCHAR2 DEFAULT NULL
  ) IS

begin

  declare
     user_id		number := 0;
     row_id     	varchar2(64);
     L_MATCH_RULE_ID NUMBER := X_MATCH_RULE_ID;
     L_OBJECT_VERSION_NUMBER number;

   begin
      if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

    L_OBJECT_VERSION_NUMBER := NVL(X_OBJECT_VERSION_NUMBER,1) + 1;

    HZ_MATCH_RULES_PKG.UPDATE_ROW(
    X_MATCH_RULE_ID => X_MATCH_RULE_ID,
    X_RULE_PURPOSE => X_RULE_PURPOSE,
    X_MATCH_ALL_FLAG => X_MATCH_ALL_FLAG,
    X_ACTIVE_FLAG => X_ACTIVE_FLAG,
    X_NO_OVERRIDE_SCORE => X_NO_OVERRIDE_SCORE,
    X_AUTO_MERGE_SCORE => X_AUTO_MERGE_SCORE,
    X_COMPILATION_FLAG => X_COMPILATION_FLAG,
    X_MATCH_SCORE => X_MATCH_SCORE,
    X_RULE_NAME => X_RULE_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => user_id,
    X_LAST_UPDATE_LOGIN =>0,
    X_OBJECT_VERSION_NUMBER  => L_OBJECT_VERSION_NUMBER,
    X_AUTOMERGE_FLAG => X_AUTOMERGE_FLAG,
    X_USE_CONTACT_ADDR_FLAG => X_USE_CONTACT_ADDR_FLAG,
    X_USE_CONTACT_CPT_FLAG => X_USE_CONTACT_CPT_FLAG
    );

    exception
       when NO_DATA_FOUND then

    HZ_MATCH_RULES_PKG.INSERT_ROW(
    X_MATCH_RULE_ID => L_MATCH_RULE_ID,
    X_RULE_PURPOSE => X_RULE_PURPOSE,
    X_MATCH_ALL_FLAG => X_MATCH_ALL_FLAG,
    X_ACTIVE_FLAG => X_ACTIVE_FLAG,
    X_NO_OVERRIDE_SCORE => X_NO_OVERRIDE_SCORE,
    X_AUTO_MERGE_SCORE => X_AUTO_MERGE_SCORE,
    X_COMPILATION_FLAG => X_COMPILATION_FLAG,
    X_MATCH_SCORE => X_MATCH_SCORE,
    X_RULE_NAME => X_RULE_NAME,
    X_DESCRIPTION => X_DESCRIPTION,
    X_CREATION_DATE => sysdate,
    X_CREATED_BY => user_id,
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => user_id,
    X_LAST_UPDATE_LOGIN =>0,
    X_OBJECT_VERSION_NUMBER  => 1,
    X_AUTOMERGE_FLAG => X_AUTOMERGE_FLAG,
    X_USE_CONTACT_ADDR_FLAG => X_USE_CONTACT_ADDR_FLAG,
    X_USE_CONTACT_CPT_FLAG => X_USE_CONTACT_CPT_FLAG
    );

   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_MATCH_RULE_ID in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user
 UPDATE hz_match_rules_tl set
 RULE_NAME   = X_RULE_NAME,
 DESCRIPTION = X_DESCRIPTION,
 source_lang = userenv('LANG'),
 last_update_date = sysdate,
 last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
 last_update_login = 0
 where match_rule_id = X_MATCH_RULE_ID
 and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

end HZ_MATCH_RULES_PKG;

/
