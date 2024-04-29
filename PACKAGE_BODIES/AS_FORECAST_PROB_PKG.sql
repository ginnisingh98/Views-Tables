--------------------------------------------------------
--  DDL for Package Body AS_FORECAST_PROB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_FORECAST_PROB_PKG" as
/* #$Header: asxtfpbb.pls 120.1 2005/06/05 22:53:02 appldev  $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AS_FORECAST_PROB_ALL_B
    where PROBABILITY_VALUE = X_PROBABILITY_VALUE
    ;
begin
  insert into AS_FORECAST_PROB_ALL_B (
    USAGE_INDICATOR,
    INTERNAL_UPGRADE_PROB_VALUE,
    PROBABILITY_VALUE,
    START_DATE_ACTIVE,
    ENABLED_FLAG,
    LEAD_STATUS_CHANGE_CODE,
    END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_USAGE_INDICATOR,
    X_INTERNAL_UPGRADE_PROB_VALUE,
    X_PROBABILITY_VALUE,
    X_START_DATE_ACTIVE,
    X_ENABLED_FLAG,
    X_LEAD_STATUS_CHANGE_CODE,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AS_FORECAST_PROB_ALL_TL (
    PROBABILITY_VALUE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MEANING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PROBABILITY_VALUE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_MEANING,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AS_FORECAST_PROB_ALL_TL T
    where T.PROBABILITY_VALUE = X_PROBABILITY_VALUE
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
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2
) is
  cursor c is select
      USAGE_INDICATOR,
      INTERNAL_UPGRADE_PROB_VALUE,
      START_DATE_ACTIVE,
      ENABLED_FLAG,
      LEAD_STATUS_CHANGE_CODE,
      END_DATE_ACTIVE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from AS_FORECAST_PROB_ALL_B
    where PROBABILITY_VALUE = X_PROBABILITY_VALUE
    for update of PROBABILITY_VALUE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AS_FORECAST_PROB_ALL_TL
    where PROBABILITY_VALUE = X_PROBABILITY_VALUE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PROBABILITY_VALUE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.USAGE_INDICATOR = X_USAGE_INDICATOR)
           OR ((recinfo.USAGE_INDICATOR is null) AND (X_USAGE_INDICATOR is null)))
      AND ((recinfo.INTERNAL_UPGRADE_PROB_VALUE = X_INTERNAL_UPGRADE_PROB_VALUE)
           OR ((recinfo.INTERNAL_UPGRADE_PROB_VALUE is null) AND
(X_INTERNAL_UPGRADE_PROB_VALUE is null)))
      AND (recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.LEAD_STATUS_CHANGE_CODE = X_LEAD_STATUS_CHANGE_CODE)
           OR ((recinfo.LEAD_STATUS_CHANGE_CODE is null) AND (X_LEAD_STATUS_CHANGE_CODE is
null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.MEANING = X_MEANING)
               OR ((tlinfo.MEANING is null) AND (X_MEANING is null)))
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
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AS_FORECAST_PROB_ALL_B set
    USAGE_INDICATOR = X_USAGE_INDICATOR,
    INTERNAL_UPGRADE_PROB_VALUE = X_INTERNAL_UPGRADE_PROB_VALUE,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LEAD_STATUS_CHANGE_CODE = X_LEAD_STATUS_CHANGE_CODE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROBABILITY_VALUE = X_PROBABILITY_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AS_FORECAST_PROB_ALL_TL set
    MEANING = X_MEANING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PROBABILITY_VALUE = X_PROBABILITY_VALUE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PROBABILITY_VALUE in NUMBER
) is
begin
  delete from AS_FORECAST_PROB_ALL_TL
  where PROBABILITY_VALUE = X_PROBABILITY_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AS_FORECAST_PROB_ALL_B
  where PROBABILITY_VALUE = X_PROBABILITY_VALUE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_OWNER   in VARCHAR2
)
IS
begin
  declare
     user_id            number := 0;
     row_id             varchar2(64);

  cursor custom_exist(p_PROBABILITY_VALUE NUMBER) is
	select 'Y'
	from AS_FORECAST_PROB_ALL_B
	where last_updated_by <> 1
	and PROBABILITY_VALUE = p_PROBABILITY_VALUE;

  l_custom_exist varchar2(1) := 'N';


  begin

  OPEN custom_exist(X_PROBABILITY_VALUE);
  FETCH custom_exist into l_custom_exist;
  CLOSE custom_exist;
  IF nvl(l_custom_exist, 'N') = 'N' THEN

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     begin
     AS_FORECAST_PROB_PKG.UPDATE_ROW (
       X_PROBABILITY_VALUE 		     => X_PROBABILITY_VALUE,
    	  X_USAGE_INDICATOR 		     => X_USAGE_INDICATOR,
    	  X_INTERNAL_UPGRADE_PROB_VALUE    => X_INTERNAL_UPGRADE_PROB_VALUE,
    	  X_START_DATE_ACTIVE 		     => X_START_DATE_ACTIVE,
    	  X_ENABLED_FLAG 		          => X_ENABLED_FLAG,
    	  X_LEAD_STATUS_CHANGE_CODE 	     => X_LEAD_STATUS_CHANGE_CODE,
    	  X_END_DATE_ACTIVE 		     => X_END_DATE_ACTIVE,
    	  X_ATTRIBUTE_CATEGORY 		     => X_ATTRIBUTE_CATEGORY,
    	  X_ATTRIBUTE1 			     => X_ATTRIBUTE1,
    	  X_ATTRIBUTE2 			     => X_ATTRIBUTE2,
    	  X_ATTRIBUTE3 			     => X_ATTRIBUTE3,
    	  X_ATTRIBUTE4 			     => X_ATTRIBUTE4,
    	  X_ATTRIBUTE5 			     => X_ATTRIBUTE5,
    	  X_ATTRIBUTE6 			     => X_ATTRIBUTE6,
    	  X_ATTRIBUTE7 			     => X_ATTRIBUTE7,
    	  X_ATTRIBUTE8 			     => X_ATTRIBUTE8,
    	  X_ATTRIBUTE9 			     => X_ATTRIBUTE9,
    	  X_ATTRIBUTE10 		          => X_ATTRIBUTE10,
    	  X_ATTRIBUTE11 		          => X_ATTRIBUTE11,
    	  X_ATTRIBUTE12 		          => X_ATTRIBUTE12,
    	  X_ATTRIBUTE13 		          => X_ATTRIBUTE13,
    	  X_ATTRIBUTE14 		          => X_ATTRIBUTE14,
    	  X_ATTRIBUTE15 		          => X_ATTRIBUTE15,
    	  X_MEANING 			          => X_MEANING,
    	  X_LAST_UPDATE_DATE		     => sysdate,
    	  X_LAST_UPDATED_BY 		     => user_id,
    	  X_LAST_UPDATE_LOGIN 		     => 0
	    );
       exception
        when NO_DATA_FOUND then
           AS_FORECAST_PROB_PKG.INSERT_ROW (
        		X_ROWID			             => row_id,
        		X_PROBABILITY_VALUE 	        => X_PROBABILITY_VALUE,
        	  	X_USAGE_INDICATOR 		        => X_USAGE_INDICATOR,
        	  	X_INTERNAL_UPGRADE_PROB_VALUE    => X_INTERNAL_UPGRADE_PROB_VALUE,
        		X_START_DATE_ACTIVE 		   => X_START_DATE_ACTIVE,
        		X_ENABLED_FLAG 			   => X_ENABLED_FLAG,
        		X_LEAD_STATUS_CHANGE_CODE 	   => X_LEAD_STATUS_CHANGE_CODE,
        		X_END_DATE_ACTIVE 		        => X_END_DATE_ACTIVE,
        		X_ATTRIBUTE_CATEGORY 		   => X_ATTRIBUTE_CATEGORY,
        		X_ATTRIBUTE1 			        => X_ATTRIBUTE1,
        		X_ATTRIBUTE2 			        => X_ATTRIBUTE2,
        		X_ATTRIBUTE3 			        => X_ATTRIBUTE3,
        		X_ATTRIBUTE4 			        => X_ATTRIBUTE4,
        		X_ATTRIBUTE5 			        => X_ATTRIBUTE5,
        		X_ATTRIBUTE6 			        => X_ATTRIBUTE6,
        		X_ATTRIBUTE7 			        => X_ATTRIBUTE7,
        		X_ATTRIBUTE8 			        => X_ATTRIBUTE8,
        		X_ATTRIBUTE9 			        => X_ATTRIBUTE9,
        		X_ATTRIBUTE10 		   	        => X_ATTRIBUTE10,
        		X_ATTRIBUTE11 		             => X_ATTRIBUTE11,
        		X_ATTRIBUTE12 		  	        => X_ATTRIBUTE12,
        		X_ATTRIBUTE13 			        => X_ATTRIBUTE13,
        		X_ATTRIBUTE14 			        => X_ATTRIBUTE14,
        		X_ATTRIBUTE15 			        => X_ATTRIBUTE15,
        		X_MEANING 			        => X_MEANING,
               X_CREATION_DATE     		   => sysdate,
               X_CREATED_BY        		   => 0,
        		X_LAST_UPDATE_DATE		        => sysdate,
        		X_LAST_UPDATED_BY 		        => user_id,
        		X_LAST_UPDATE_LOGIN 		   => 0
	          );
     end;

  END IF;
  end;
end LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AS_FORECAST_PROB_ALL_TL T
  where not exists
    (select NULL
    from AS_FORECAST_PROB_ALL_B B
    where B.PROBABILITY_VALUE = T.PROBABILITY_VALUE
    );

  update AS_FORECAST_PROB_ALL_TL T set (
      MEANING
    ) = (select
      B.MEANING
    from AS_FORECAST_PROB_ALL_TL B
    where B.PROBABILITY_VALUE = T.PROBABILITY_VALUE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROBABILITY_VALUE,
      T.LANGUAGE
  ) in (select
      SUBT.PROBABILITY_VALUE,
      SUBT.LANGUAGE
    from AS_FORECAST_PROB_ALL_TL SUBB, AS_FORECAST_PROB_ALL_TL SUBT
    where SUBB.PROBABILITY_VALUE = SUBT.PROBABILITY_VALUE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or (SUBB.MEANING is null and SUBT.MEANING is not null)
      or (SUBB.MEANING is not null and SUBT.MEANING is null)
  ));

  insert into AS_FORECAST_PROB_ALL_TL (
    PROBABILITY_VALUE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MEANING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PROBABILITY_VALUE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.MEANING,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AS_FORECAST_PROB_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_FORECAST_PROB_ALL_TL T
    where T.PROBABILITY_VALUE = B.PROBABILITY_VALUE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_PROBABILITY_VALUE in NUMBER,
  X_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
begin
  -- only update rows that have not been altered by user
   update AS_FORECAST_PROB_ALL_TL
     set MEANING  = X_MEANING,
         source_lang = userenv('LANG'),
	    last_update_date = sysdate,
	    last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
	    last_update_login = 0
      where PROBABILITY_VALUE = X_PROBABILITY_VALUE
	 and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

end AS_FORECAST_PROB_PKG;

/