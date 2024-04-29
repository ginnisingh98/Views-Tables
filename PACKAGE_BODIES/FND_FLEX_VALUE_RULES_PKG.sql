--------------------------------------------------------
--  DDL for Package Body FND_FLEX_VALUE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_VALUE_RULES_PKG" as
/* $Header: AFFFVLRB.pls 120.2.12010000.1 2008/07/25 14:14:52 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_FLEX_VALUE_RULE_ID in NUMBER,
  X_FLEX_VALUE_RULE_NAME in VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_ERROR_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_FLEX_VALUE_RULES
    where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID
    ;
begin
  insert into FND_FLEX_VALUE_RULES (
    FLEX_VALUE_RULE_ID,
    FLEX_VALUE_RULE_NAME,
    FLEX_VALUE_SET_ID,
    PARENT_FLEX_VALUE_LOW,
    PARENT_FLEX_VALUE_HIGH,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FLEX_VALUE_RULE_ID,
    X_FLEX_VALUE_RULE_NAME,
    X_FLEX_VALUE_SET_ID,
    X_PARENT_FLEX_VALUE_LOW,
    X_PARENT_FLEX_VALUE_HIGH,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_FLEX_VALUE_RULES_TL (
    DESCRIPTION,
    FLEX_VALUE_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ERROR_MESSAGE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_FLEX_VALUE_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ERROR_MESSAGE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_FLEX_VALUE_RULES_TL T
    where T.FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID
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
  X_FLEX_VALUE_RULE_ID in NUMBER,
  X_FLEX_VALUE_RULE_NAME in VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_ERROR_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      FLEX_VALUE_RULE_NAME,
      FLEX_VALUE_SET_ID,
      PARENT_FLEX_VALUE_LOW,
      PARENT_FLEX_VALUE_HIGH
    from FND_FLEX_VALUE_RULES
    where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID
    for update of FLEX_VALUE_RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ERROR_MESSAGE,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_FLEX_VALUE_RULES_TL
    where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FLEX_VALUE_RULE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.FLEX_VALUE_RULE_NAME = X_FLEX_VALUE_RULE_NAME)
      AND (recinfo.FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID)
      AND ((recinfo.PARENT_FLEX_VALUE_LOW = X_PARENT_FLEX_VALUE_LOW)
           OR ((recinfo.PARENT_FLEX_VALUE_LOW is null) AND (X_PARENT_FLEX_VALUE_LOW is null)))
      AND ((recinfo.PARENT_FLEX_VALUE_HIGH = X_PARENT_FLEX_VALUE_HIGH)
           OR ((recinfo.PARENT_FLEX_VALUE_HIGH is null) AND (X_PARENT_FLEX_VALUE_HIGH is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.ERROR_MESSAGE = X_ERROR_MESSAGE)
               OR ((tlinfo.ERROR_MESSAGE is null) AND (X_ERROR_MESSAGE is null)))
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
  X_FLEX_VALUE_RULE_ID in NUMBER,
  X_FLEX_VALUE_RULE_NAME in VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_ERROR_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_FLEX_VALUE_RULES set
    FLEX_VALUE_RULE_NAME = X_FLEX_VALUE_RULE_NAME,
    FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID,
    PARENT_FLEX_VALUE_LOW = X_PARENT_FLEX_VALUE_LOW,
    PARENT_FLEX_VALUE_HIGH = X_PARENT_FLEX_VALUE_HIGH,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_FLEX_VALUE_RULES_TL set
    ERROR_MESSAGE = X_ERROR_MESSAGE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FLEX_VALUE_RULE_ID in NUMBER
) is
begin
  delete from FND_FLEX_VALUE_RULES_TL
  where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_FLEX_VALUE_RULES
  where FLEX_VALUE_RULE_ID = X_FLEX_VALUE_RULE_ID;

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

   delete from FND_FLEX_VALUE_RULES_TL T
   where not exists
     (select NULL
     from FND_FLEX_VALUE_RULES B
     where B.FLEX_VALUE_RULE_ID = T.FLEX_VALUE_RULE_ID
     );

   update FND_FLEX_VALUE_RULES_TL T set (
       ERROR_MESSAGE,
       DESCRIPTION
     ) = (select
       B.ERROR_MESSAGE,
       B.DESCRIPTION
     from FND_FLEX_VALUE_RULES_TL B
     where B.FLEX_VALUE_RULE_ID = T.FLEX_VALUE_RULE_ID
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.FLEX_VALUE_RULE_ID,
       T.LANGUAGE
   ) in (select
       SUBT.FLEX_VALUE_RULE_ID,
       SUBT.LANGUAGE
     from FND_FLEX_VALUE_RULES_TL SUBB, FND_FLEX_VALUE_RULES_TL SUBT
     where SUBB.FLEX_VALUE_RULE_ID = SUBT.FLEX_VALUE_RULE_ID
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.ERROR_MESSAGE <> SUBT.ERROR_MESSAGE
       or (SUBB.ERROR_MESSAGE is null and SUBT.ERROR_MESSAGE is not null)
       or (SUBB.ERROR_MESSAGE is not null and SUBT.ERROR_MESSAGE is null)
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

   insert into FND_FLEX_VALUE_RULES_TL (
     DESCRIPTION,
     FLEX_VALUE_RULE_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     ERROR_MESSAGE,
     LANGUAGE,
     SOURCE_LANG
   ) select
     B.DESCRIPTION,
     B.FLEX_VALUE_RULE_ID,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.ERROR_MESSAGE,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_FLEX_VALUE_RULES_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from FND_FLEX_VALUE_RULES_TL T
     where T.FLEX_VALUE_RULE_ID = B.FLEX_VALUE_RULE_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE load_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_parent_flex_value_low        IN VARCHAR2,
   x_flex_value_rule_name         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_parent_flex_value_high       IN VARCHAR2,
   x_error_message                IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
     l_flex_value_set_id  NUMBER := NULL;
     l_flex_value_rule_id NUMBER;
     l_validation_type    VARCHAR2(1);
     l_rowid              VARCHAR2(64);
BEGIN
   SELECT flex_value_set_id, validation_type
     INTO l_flex_value_set_id, l_validation_type
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = x_flex_value_set_name;

   BEGIN
      IF (l_validation_type = 'D') THEN
	 SELECT flex_value_rule_id
	   INTO l_flex_value_rule_id
	   FROM fnd_flex_value_rules
	   WHERE flex_value_set_id = l_flex_value_set_id
	   AND flex_value_rule_name = x_flex_value_rule_name
	   AND (parent_flex_value_low = x_parent_flex_value_low OR
		(parent_flex_value_low IS NULL AND
		 x_parent_flex_value_low IS NULL));
       ELSE
	 SELECT flex_value_rule_id
	   INTO l_flex_value_rule_id
	   FROM fnd_flex_value_rules
	   WHERE flex_value_set_id = l_flex_value_set_id
	   AND flex_value_rule_name = x_flex_value_rule_name;
      END IF;

      fnd_flex_value_rules_pkg.update_row
	(X_FLEX_VALUE_RULE_ID           => l_flex_value_rule_id,
	 X_FLEX_VALUE_RULE_NAME         => x_flex_value_rule_name,
	 X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
	 X_DESCRIPTION                  => x_description,
	 X_PARENT_FLEX_VALUE_LOW        => x_parent_flex_value_low,
	 X_PARENT_FLEX_VALUE_HIGH       => x_parent_flex_value_high,
	 X_ERROR_MESSAGE                => x_error_message,
	 X_LAST_UPDATE_DATE             => x_who.last_update_date,
	 X_LAST_UPDATED_BY              => x_who.last_updated_by,
	 X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
	 SELECT fnd_flex_value_rules_s.NEXTVAL
	   INTO l_flex_value_rule_id
	   FROM dual;

	 fnd_flex_value_rules_pkg.insert_row
	   (X_ROWID                        => l_rowid,
	    X_FLEX_VALUE_RULE_ID           => l_flex_value_rule_id,
	    X_FLEX_VALUE_RULE_NAME         => x_flex_value_rule_name,
	    X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
	    X_DESCRIPTION                  => x_description,
	    X_PARENT_FLEX_VALUE_LOW        => x_parent_flex_value_low,
	    X_PARENT_FLEX_VALUE_HIGH       => x_parent_flex_value_high,
	    X_ERROR_MESSAGE                => x_error_message,
	    X_CREATION_DATE                => x_who.creation_date,
  	    X_CREATED_BY                   => x_who.created_by,
	    X_LAST_UPDATE_DATE             => x_who.last_update_date,
	    X_LAST_UPDATED_BY              => x_who.last_updated_by,
	    X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   END;
END load_row;


PROCEDURE translate_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_parent_flex_value_low        IN VARCHAR2,
   x_flex_value_rule_name         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_error_message                IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_flex_value_rules_tl SET
     error_message     = Nvl(x_error_message, error_message),
     description       = Nvl(x_description, description),
     last_update_date  = x_who.last_update_date,
     last_updated_by   = x_who.last_updated_by,
     last_update_login = x_who.last_update_login,
     source_lang       = userenv('LANG')
     WHERE (flex_value_rule_id =
	    (SELECT flex_value_rule_id
	     FROM fnd_flex_value_rules fvr, fnd_flex_value_sets fvs
	     WHERE fvr.flex_value_set_id = fvs.flex_value_set_id
	     AND fvs.flex_value_set_name = x_flex_value_set_name
	     AND fvr.flex_value_rule_name = x_flex_value_rule_name
	     AND ((fvs.validation_type NOT IN ('D', 'Y')) OR
		  (fvs.validation_type IN ('D', 'Y') AND
		   ((fvr.parent_flex_value_low = x_parent_flex_value_low) OR
		    (fvr.parent_flex_value_low IS NULL AND
		     x_parent_flex_value_low IS NULL))))))
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_FLEX_VALUE_RULES_PKG;

/
