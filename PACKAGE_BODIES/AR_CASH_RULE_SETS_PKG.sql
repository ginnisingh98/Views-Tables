--------------------------------------------------------
--  DDL for Package Body AR_CASH_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CASH_RULE_SETS_PKG" as
/* $Header: ARCAURSB.pls 120.0.12010000.1 2009/09/19 01:17:57 rravikir noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_AUTOMATCH_SET_ID in NUMBER,
  X_AUTOMATCH_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE      in DATE,
  X_END_DATE        in DATE,
  X_ACTIVE_FLAG     in VARCHAR2,
  X_EXCEPTION_REASON in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_CASH_AUTO_RULE_SETS
    where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID
    ;
begin
  insert into AR_CASH_AUTO_RULE_SETS (
	AUTOMATCH_SET_ID,
	START_DATE,
	END_DATE ,
	ACTIVE_FLAG,
	EXCEPTION_REASON,
	CREATED_BY      ,
	CREATION_DATE   ,
	LAST_UPDATED_BY ,
	LAST_UPDATE_DATE ,
	LAST_UPDATE_LOGIN
  ) values (
	X_AUTOMATCH_SET_ID,
	X_START_DATE,
	X_END_DATE ,
	X_ACTIVE_FLAG,
	X_EXCEPTION_REASON,
	X_CREATED_BY      ,
	X_CREATION_DATE   ,
	X_LAST_UPDATED_BY ,
	X_LAST_UPDATE_DATE ,
	X_LAST_UPDATE_LOGIN
  );

  insert into AR_CASH_AUTO_RULE_SETS_TL (
	AUTOMATCH_SET_ID ,
	AUTOMATCH_SET_NAME,
	DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
	X_AUTOMATCH_SET_ID,
	X_AUTOMATCH_SET_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AR_CASH_AUTO_RULE_SETS_TL T
    where T.AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID
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
  X_AUTOMATCH_SET_ID in NUMBER,
  X_AUTOMATCH_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE      in DATE,
  X_END_DATE        in DATE,
  X_ACTIVE_FLAG     in VARCHAR2,
  X_EXCEPTION_REASON in VARCHAR2
) is
  cursor c is select
    START_DATE,
	END_DATE,
	ACTIVE_FLAG,
	EXCEPTION_REASON
    from AR_CASH_AUTO_RULE_SETS
    where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID
    for update of AUTOMATCH_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      AUTOMATCH_SET_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_CASH_AUTO_RULE_SETS_TL
    where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of AUTOMATCH_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.START_DATE = X_START_DATE)
  	  AND (recinfo.END_DATE = X_END_DATE)
      AND ((recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
           OR ((recinfo.ACTIVE_FLAG is null) AND (X_ACTIVE_FLAG is null)))
      AND ((recinfo.EXCEPTION_REASON = X_EXCEPTION_REASON)
           OR ((recinfo.EXCEPTION_REASON is null) AND (X_EXCEPTION_REASON is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.AUTOMATCH_SET_NAME = X_AUTOMATCH_SET_NAME)
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
  X_AUTOMATCH_SET_ID in NUMBER,
  X_AUTOMATCH_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE      in DATE,
  X_END_DATE        in DATE,
  X_ACTIVE_FLAG     in VARCHAR2,
  X_EXCEPTION_REASON in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_CASH_AUTO_RULE_SETS set
	START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    EXCEPTION_REASON = X_EXCEPTION_REASON,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_CASH_AUTO_RULE_SETS_TL set
    AUTOMATCH_SET_NAME = X_AUTOMATCH_SET_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_AUTOMATCH_SET_ID in NUMBER
) is
begin
  delete from AR_CASH_AUTO_RULE_SETS_TL
  where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_CASH_AUTO_RULE_SETS
  where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_CASH_AUTO_RULE_SETS_TL T
  where not exists
    (select NULL
    from AR_CASH_AUTO_RULE_SETS B
    where B.AUTOMATCH_SET_ID = T.AUTOMATCH_SET_ID
    );

  update AR_CASH_AUTO_RULE_SETS_TL T set (
      AUTOMATCH_SET_NAME,
      DESCRIPTION
    ) = (select
      B.AUTOMATCH_SET_NAME,
      B.DESCRIPTION
    from AR_CASH_AUTO_RULE_SETS_TL B
    where B.AUTOMATCH_SET_ID = T.AUTOMATCH_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.AUTOMATCH_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.AUTOMATCH_SET_ID,
      SUBT.LANGUAGE
    from AR_CASH_AUTO_RULE_SETS_TL SUBB, AR_CASH_AUTO_RULE_SETS_TL SUBT
    where SUBB.AUTOMATCH_SET_ID = SUBT.AUTOMATCH_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.AUTOMATCH_SET_NAME <> SUBT.AUTOMATCH_SET_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AR_CASH_AUTO_RULE_SETS_TL (
    AUTOMATCH_SET_ID,
    AUTOMATCH_SET_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.AUTOMATCH_SET_ID,
    B.AUTOMATCH_SET_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_CASH_AUTO_RULE_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_CASH_AUTO_RULE_SETS_TL T
    where T.AUTOMATCH_SET_ID = B.AUTOMATCH_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_AUTOMATCH_SET_ID in NUMBER,
  X_AUTOMATCH_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_CASH_AUTO_RULE_SETS_TL
      set AUTOMATCH_SET_NAME = X_AUTOMATCH_SET_NAME,
      	  DESCRIPTION = X_DESCRIPTION,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_AUTOMATCH_SET_ID in NUMBER,
  X_AUTOMATCH_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE      in DATE,
  X_END_DATE        in DATE,
  X_ACTIVE_FLAG     in VARCHAR2,
  X_EXCEPTION_REASON in VARCHAR2,
  X_OWNER IN VARCHAR2
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_CASH_RULE_SETS_PKG.UPDATE_ROW (
  		X_AUTOMATCH_SET_ID       => X_AUTOMATCH_SET_ID,
  		X_AUTOMATCH_SET_NAME     => X_AUTOMATCH_SET_NAME,
  		X_DESCRIPTION            => X_DESCRIPTION,
  		X_START_DATE             => X_START_DATE,
  		X_END_DATE               => X_END_DATE,
  		X_ACTIVE_FLAG            => X_ACTIVE_FLAG,
		X_EXCEPTION_REASON       => X_EXCEPTION_REASON,
        X_LAST_UPDATE_DATE 		 => sysdate,
        X_LAST_UPDATED_BY 	 	 => user_id,
        X_LAST_UPDATE_LOGIN 	 => 0);
    exception
       when NO_DATA_FOUND then
           AR_CASH_RULE_SETS_PKG.INSERT_ROW (
                X_ROWID 				 => row_id,
  				X_AUTOMATCH_SET_ID       => X_AUTOMATCH_SET_ID,
  				X_AUTOMATCH_SET_NAME     => X_AUTOMATCH_SET_NAME,
  				X_DESCRIPTION            => X_DESCRIPTION,
  				X_START_DATE             => X_START_DATE,
  				X_END_DATE               => X_END_DATE,
  				X_ACTIVE_FLAG            => X_ACTIVE_FLAG,
				X_EXCEPTION_REASON       => X_EXCEPTION_REASON,
				X_CREATION_DATE 	     => sysdate,
                X_CREATED_BY 			 => user_id,
                X_LAST_UPDATE_DATE 		 => sysdate,
                X_LAST_UPDATED_BY 		 => user_id,
                X_LAST_UPDATE_LOGIN 	 => 0);
    end;
end LOAD_ROW;

end AR_CASH_RULE_SETS_PKG;

/
