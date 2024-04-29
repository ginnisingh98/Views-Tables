--------------------------------------------------------
--  DDL for Package Body AR_CASH_AUTOMATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CASH_AUTOMATCH_PKG" as
/* $Header: ARCAUMTB.pls 120.0.12010000.1 2009/09/19 01:17:46 rravikir noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_AUTOMATCH_ID in NUMBER,
  X_AUTOMATCH_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MATCHING_OPTION in VARCHAR2,
  X_AUTO_MATCH_THRESHOLD in NUMBER,
  X_SUGG_MATCH_THRESHOLD in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MATCH_DATE_BY in VARCHAR2,
  X_USE_MATCHING_DATE in VARCHAR2,
  X_USE_MATCHING_AMOUNT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_CASH_AUTOMATCHES
    where AUTOMATCH_ID = X_AUTOMATCH_ID;
begin
  insert into AR_CASH_AUTOMATCHES (
		AUTOMATCH_ID,
		MATCHING_OPTION,
		AUTO_MATCH_THRESHOLD,
		SUGG_MATCH_THRESHOLD,
		START_DATE,
		END_DATE,
		ACTIVE_FLAG,
		MATCH_DATE_BY,
		USE_MATCHING_DATE ,
		USE_MATCHING_AMOUNT,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
  ) values (
		X_AUTOMATCH_ID,
		X_MATCHING_OPTION,
		X_AUTO_MATCH_THRESHOLD,
		X_SUGG_MATCH_THRESHOLD,
		X_START_DATE,
		X_END_DATE,
		X_ACTIVE_FLAG,
		X_MATCH_DATE_BY,
		X_USE_MATCHING_DATE ,
		X_USE_MATCHING_AMOUNT,
		X_CREATED_BY,
		X_CREATION_DATE,
		X_LAST_UPDATED_BY,
		X_LAST_UPDATE_DATE,
		X_LAST_UPDATE_LOGIN
  );

  insert into AR_CASH_AUTOMATCHES_TL (
		AUTOMATCH_ID,
        AUTOMATCH_NAME,
    	DESCRIPTION,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN,
    	LANGUAGE,
    	SOURCE_LANG
  ) select
    X_AUTOMATCH_ID,
    X_AUTOMATCH_NAME,
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
    from AR_CASH_AUTOMATCHES_TL T
    where T.AUTOMATCH_ID = X_AUTOMATCH_ID
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
  X_AUTOMATCH_ID in NUMBER,
  X_AUTOMATCH_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MATCHING_OPTION in VARCHAR2,
  X_AUTO_MATCH_THRESHOLD in NUMBER,
  X_SUGG_MATCH_THRESHOLD in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MATCH_DATE_BY in VARCHAR2,
  X_USE_MATCHING_DATE in VARCHAR2,
  X_USE_MATCHING_AMOUNT in VARCHAR2
) is
  cursor c is select
		MATCHING_OPTION     ,
		AUTO_MATCH_THRESHOLD,
		SUGG_MATCH_THRESHOLD,
		START_DATE          ,
		END_DATE            ,
		ACTIVE_FLAG         ,
		MATCH_DATE_BY       ,
		USE_MATCHING_DATE   ,
		USE_MATCHING_AMOUNT
    from AR_CASH_AUTOMATCHES
    where AUTOMATCH_ID = X_AUTOMATCH_ID
    for update of AUTOMATCH_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      AUTOMATCH_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_CASH_AUTOMATCHES_TL
    where AUTOMATCH_ID = X_AUTOMATCH_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of AUTOMATCH_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.MATCHING_OPTION = X_MATCHING_OPTION)
  	  AND (recinfo.AUTO_MATCH_THRESHOLD = X_AUTO_MATCH_THRESHOLD)
  	  AND (recinfo.SUGG_MATCH_THRESHOLD = X_SUGG_MATCH_THRESHOLD)
  	  AND (recinfo.START_DATE = X_START_DATE)
  	  AND (recinfo.END_DATE = X_END_DATE)
      AND ((recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
           OR ((recinfo.ACTIVE_FLAG is null) AND (X_ACTIVE_FLAG is null)))
      AND ((recinfo.MATCH_DATE_BY = X_MATCH_DATE_BY)
           OR ((recinfo.MATCH_DATE_BY is null) AND (X_MATCH_DATE_BY is null)))
      AND ((recinfo.USE_MATCHING_DATE = X_USE_MATCHING_DATE)
           OR ((recinfo.USE_MATCHING_DATE is null) AND (X_USE_MATCHING_DATE is null)))
      AND ((recinfo.USE_MATCHING_AMOUNT = X_USE_MATCHING_AMOUNT)
           OR ((recinfo.USE_MATCHING_AMOUNT is null) AND (X_USE_MATCHING_AMOUNT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.AUTOMATCH_NAME = X_AUTOMATCH_NAME)
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
  X_AUTOMATCH_ID in NUMBER,
  X_AUTOMATCH_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MATCHING_OPTION in VARCHAR2,
  X_AUTO_MATCH_THRESHOLD in NUMBER,
  X_SUGG_MATCH_THRESHOLD in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MATCH_DATE_BY in VARCHAR2,
  X_USE_MATCHING_DATE in VARCHAR2,
  X_USE_MATCHING_AMOUNT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_CASH_AUTOMATCHES set
	AUTOMATCH_ID         = X_AUTOMATCH_ID,
	MATCHING_OPTION      = X_MATCHING_OPTION,
	AUTO_MATCH_THRESHOLD = X_AUTO_MATCH_THRESHOLD,
	SUGG_MATCH_THRESHOLD = X_SUGG_MATCH_THRESHOLD,
	START_DATE           = X_START_DATE,
	END_DATE             = X_END_DATE,
	ACTIVE_FLAG          = X_ACTIVE_FLAG,
	MATCH_DATE_BY        = X_MATCH_DATE_BY,
	USE_MATCHING_DATE    = X_USE_MATCHING_DATE,
	USE_MATCHING_AMOUNT   = X_USE_MATCHING_AMOUNT,
	LAST_UPDATED_BY       = X_LAST_UPDATED_BY,
	LAST_UPDATE_DATE      = X_LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN     = X_LAST_UPDATE_LOGIN
  where AUTOMATCH_ID = X_AUTOMATCH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_CASH_AUTOMATCHES_TL set
    AUTOMATCH_NAME = X_AUTOMATCH_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where AUTOMATCH_ID = X_AUTOMATCH_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_AUTOMATCH_ID in NUMBER
) is
begin
  delete from AR_CASH_AUTOMATCHES_TL
  where AUTOMATCH_ID = X_AUTOMATCH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_CASH_AUTOMATCHES
  where AUTOMATCH_ID = X_AUTOMATCH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_CASH_AUTOMATCHES_TL T
  where not exists
    (select NULL
    from AR_CASH_AUTOMATCHES B
    where B.AUTOMATCH_ID = T.AUTOMATCH_ID
    );

  update AR_CASH_AUTOMATCHES_TL T set (
      AUTOMATCH_NAME,
      DESCRIPTION
    ) = (select
      B.AUTOMATCH_NAME,
      B.DESCRIPTION
    from AR_CASH_AUTOMATCHES_TL B
    where B.AUTOMATCH_ID = T.AUTOMATCH_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.AUTOMATCH_ID,
      T.LANGUAGE
  ) in (select
      SUBT.AUTOMATCH_ID,
      SUBT.LANGUAGE
    from AR_CASH_AUTOMATCHES_TL SUBB, AR_CASH_AUTOMATCHES_TL SUBT
    where SUBB.AUTOMATCH_ID = SUBT.AUTOMATCH_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.AUTOMATCH_NAME <> SUBT.AUTOMATCH_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AR_CASH_AUTOMATCHES_TL (
		AUTOMATCH_ID,
        AUTOMATCH_NAME,
    	DESCRIPTION,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN,
    	LANGUAGE,
    	SOURCE_LANG
  ) select
		B.AUTOMATCH_ID,
        B.AUTOMATCH_NAME,
    	B.DESCRIPTION,
    	B.CREATED_BY,
    	B.CREATION_DATE,
    	B.LAST_UPDATED_BY,
    	B.LAST_UPDATE_DATE,
    	B.LAST_UPDATE_LOGIN,
    	B.LANGUAGE,
    	B.SOURCE_LANG
  from AR_CASH_AUTOMATCHES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_CASH_AUTOMATCHES_TL T
    where T.AUTOMATCH_ID = B.AUTOMATCH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_AUTOMATCH_ID in NUMBER,
  X_AUTOMATCH_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_CASH_AUTOMATCHES_TL
      set AUTOMATCH_NAME = X_AUTOMATCH_NAME,
      	  DESCRIPTION = X_DESCRIPTION,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where AUTOMATCH_ID = X_AUTOMATCH_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_AUTOMATCH_ID in NUMBER,
  X_AUTOMATCH_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MATCHING_OPTION in VARCHAR2,
  X_AUTO_MATCH_THRESHOLD in NUMBER,
  X_SUGG_MATCH_THRESHOLD in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_ACTIVE_FLAG in VARCHAR2,
  X_MATCH_DATE_BY in VARCHAR2,
  X_USE_MATCHING_DATE in VARCHAR2,
  X_USE_MATCHING_AMOUNT in VARCHAR2,
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

    AR_CASH_AUTOMATCH_PKG.UPDATE_ROW (
  		X_AUTOMATCH_ID          => X_AUTOMATCH_ID,
  		X_AUTOMATCH_NAME 		=> X_AUTOMATCH_NAME,
  		X_DESCRIPTION 			=> X_DESCRIPTION,
		X_MATCHING_OPTION 		=> X_MATCHING_OPTION,
  		X_AUTO_MATCH_THRESHOLD  => X_AUTO_MATCH_THRESHOLD,
  		X_SUGG_MATCH_THRESHOLD  => X_SUGG_MATCH_THRESHOLD,
  		X_START_DATE 			=> X_START_DATE,
  		X_END_DATE 				=> X_END_DATE,
  		X_ACTIVE_FLAG 			=> X_ACTIVE_FLAG,
  		X_MATCH_DATE_BY 		=> X_MATCH_DATE_BY,
  		X_USE_MATCHING_DATE 	=> X_USE_MATCHING_DATE,
  		X_USE_MATCHING_AMOUNT 	=> X_USE_MATCHING_AMOUNT,
  		X_LAST_UPDATE_DATE 		=> sysdate,
  		X_LAST_UPDATED_BY 		=> user_id,
  		X_LAST_UPDATE_LOGIN 	=> 0);
    exception
       when NO_DATA_FOUND then
           AR_CASH_AUTOMATCH_PKG.INSERT_ROW (
                X_ROWID 				=> row_id,
  				X_AUTOMATCH_ID          => X_AUTOMATCH_ID,
		  		X_AUTOMATCH_NAME 		=> X_AUTOMATCH_NAME,
  				X_DESCRIPTION 			=> X_DESCRIPTION,
				X_MATCHING_OPTION 		=> X_MATCHING_OPTION,
  				X_AUTO_MATCH_THRESHOLD  => X_AUTO_MATCH_THRESHOLD,
		  		X_SUGG_MATCH_THRESHOLD  => X_SUGG_MATCH_THRESHOLD,
  				X_START_DATE 			=> X_START_DATE,
		  		X_END_DATE 				=> X_END_DATE,
  				X_ACTIVE_FLAG 			=> X_ACTIVE_FLAG,
		  		X_MATCH_DATE_BY 		=> X_MATCH_DATE_BY,
  				X_USE_MATCHING_DATE 	=> X_USE_MATCHING_DATE,
		  		X_USE_MATCHING_AMOUNT 	=> X_USE_MATCHING_AMOUNT,
  				X_CREATION_DATE 		=> sysdate,
				X_CREATED_BY 			=> user_id,
  				X_LAST_UPDATE_DATE 		=> sysdate,
		  		X_LAST_UPDATED_BY 		=> user_id,
  				X_LAST_UPDATE_LOGIN 	=> 0);
    end;
end LOAD_ROW;

end AR_CASH_AUTOMATCH_PKG;

/
