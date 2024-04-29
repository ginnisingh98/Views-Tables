--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_QUALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_QUALS_PKG" as
/* $Header: asxtslqb.pls 120.1 2005/06/24 17:05:28 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY  VARCHAR2,
  X_SEED_QUAL_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LOV_SQL in VARCHAR2,
  X_RANGE_FLAG in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AS_SALES_LEAD_QUALS_B
    where SEED_QUAL_ID = X_SEED_QUAL_ID
    ;
begin
  insert into AS_SALES_LEAD_QUALS_B (
    SEED_QUAL_ID,
    ENABLED_FLAG,
    LOV_SQL,
    RANGE_FLAG,
    DATA_TYPE,
    SOURCE_TABLE_NAME,
    SOURCE_COLUMN_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SEED_QUAL_ID,
    X_ENABLED_FLAG,
    X_LOV_SQL,
    X_RANGE_FLAG,
    X_DATA_TYPE,
    X_SOURCE_TABLE_NAME,
    X_SOURCE_COLUMN_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AS_SALES_LEAD_QUALS_TL (
    SEED_QUAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MEANING,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SEED_QUAL_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_MEANING,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AS_SALES_LEAD_QUALS_TL T
    where T.SEED_QUAL_ID = X_SEED_QUAL_ID
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
  X_SEED_QUAL_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LOV_SQL in VARCHAR2,
  X_RANGE_FLAG in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      LOV_SQL,
      RANGE_FLAG,
      DATA_TYPE,
      SOURCE_TABLE_NAME,
      SOURCE_COLUMN_NAME
    from AS_SALES_LEAD_QUALS_B
    where SEED_QUAL_ID = X_SEED_QUAL_ID
    for update of SEED_QUAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AS_SALES_LEAD_QUALS_TL
    where SEED_QUAL_ID = X_SEED_QUAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SEED_QUAL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ( (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.LOV_SQL = X_LOV_SQL)
      AND (recinfo.RANGE_FLAG = X_RANGE_FLAG)
      AND (recinfo.DATA_TYPE = X_DATA_TYPE)
      AND ((recinfo.SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME)
           OR ((recinfo.SOURCE_TABLE_NAME is null) AND (X_SOURCE_TABLE_NAME is null)))
      AND ((recinfo.SOURCE_COLUMN_NAME = X_SOURCE_COLUMN_NAME)
           OR ((recinfo.SOURCE_COLUMN_NAME is null) AND (X_SOURCE_COLUMN_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_SEED_QUAL_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LOV_SQL in VARCHAR2,
  X_RANGE_FLAG in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AS_SALES_LEAD_QUALS_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    LOV_SQL = X_LOV_SQL,
    RANGE_FLAG = X_RANGE_FLAG,
    DATA_TYPE = X_DATA_TYPE,
    SOURCE_TABLE_NAME = X_SOURCE_TABLE_NAME,
    SOURCE_COLUMN_NAME = X_SOURCE_COLUMN_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SEED_QUAL_ID = X_SEED_QUAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AS_SALES_LEAD_QUALS_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SEED_QUAL_ID = X_SEED_QUAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SEED_QUAL_ID in NUMBER
) is
begin
  delete from AS_SALES_LEAD_QUALS_TL
  where SEED_QUAL_ID = X_SEED_QUAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AS_SALES_LEAD_QUALS_B
  where SEED_QUAL_ID = X_SEED_QUAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_SEED_QUAL_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LOV_SQL in VARCHAR2,
  X_RANGE_FLAG in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_SOURCE_TABLE_NAME in VARCHAR2,
  X_SOURCE_COLUMN_NAME in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
    user_id            number := 0;
    row_id             varchar2(64);

    -- FFANG 112700 FOR bug 1505582
    CURSOR c_get_last_updated (c_SEED_QUAL_ID NUMBER) IS
        SELECT last_updated_by
        FROM AS_SALES_LEAD_QUALS_B
        WHERE seed_qual_id = c_seed_qual_id;
    l_last_updated_by  NUMBER;
    -- END FFANG 112700

begin
    -- FFANG 112700 FOR bug 1505582
    -- If last_updated_by is not 1, means this record has been updated by
    -- customer, we should not overwrite it.
    OPEN c_get_last_updated (x_SEED_QUAL_ID);
    FETCH c_get_last_updated INTO l_last_updated_by;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN
        if (X_OWNER = 'SEED') then
            user_id := 1;
        end if;

        AS_SALES_LEAD_QUALS_PKG.UPDATE_ROW(
      		X_SEED_QUAL_ID       => X_SEED_QUAL_ID ,
      		X_ENABLED_FLAG       => X_ENABLED_FLAG,
      		X_LOV_SQL            => X_LOV_SQL,
      		X_RANGE_FLAG         => X_RANGE_FLAG,
      		X_DATA_TYPE          => X_DATA_TYPE,
      		X_SOURCE_TABLE_NAME  => X_SOURCE_TABLE_NAME,
      		X_SOURCE_COLUMN_NAME => X_SOURCE_COLUMN_NAME,
      		X_MEANING            => X_MEANING,
      		X_DESCRIPTION        => X_DESCRIPTION,
      		X_LAST_UPDATE_DATE   => sysdate,
      		X_LAST_UPDATED_BY    => user_id,
      		X_LAST_UPDATE_LOGIN  => 0
          );
    END IF;

    exception
	  when NO_DATA_FOUND then
         	AS_SALES_LEAD_QUALS_PKG.INSERT_ROW(
  			X_ROWID              => row_id,
      		X_SEED_QUAL_ID       => X_SEED_QUAL_ID ,
      		X_ENABLED_FLAG       => X_ENABLED_FLAG,
      		X_LOV_SQL            => X_LOV_SQL,
      		X_RANGE_FLAG         => X_RANGE_FLAG,
      		X_DATA_TYPE          => X_DATA_TYPE,
      		X_SOURCE_TABLE_NAME  => X_SOURCE_TABLE_NAME,
      		X_SOURCE_COLUMN_NAME => X_SOURCE_COLUMN_NAME,
      		X_MEANING            => X_MEANING,
      		X_DESCRIPTION        => X_DESCRIPTION,
 		     X_CREATION_DATE      => sysdate,
  			X_CREATED_BY         => 0,
  			X_LAST_UPDATE_DATE   => sysdate,
  			X_LAST_UPDATED_BY    => user_id,
  			X_LAST_UPDATE_LOGIN  => 0
         );
end LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AS_SALES_LEAD_QUALS_TL T
  where not exists
    (select NULL
    from AS_SALES_LEAD_QUALS_B B
    where B.SEED_QUAL_ID = T.SEED_QUAL_ID
    );

  update AS_SALES_LEAD_QUALS_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from AS_SALES_LEAD_QUALS_TL B
    where B.SEED_QUAL_ID = T.SEED_QUAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SEED_QUAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SEED_QUAL_ID,
      SUBT.LANGUAGE
    from AS_SALES_LEAD_QUALS_TL SUBB, AS_SALES_LEAD_QUALS_TL SUBT
    where SUBB.SEED_QUAL_ID = SUBT.SEED_QUAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AS_SALES_LEAD_QUALS_TL (
    SEED_QUAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    MEANING,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SEED_QUAL_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.MEANING,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AS_SALES_LEAD_QUALS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_SALES_LEAD_QUALS_TL T
    where T.SEED_QUAL_ID = B.SEED_QUAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_SEED_QUAL_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
begin
 -- only update rows that have not been altered by user
    update AS_SALES_LEAD_QUALS_TL
    set description = X_DESCRIPTION,
	   meaning     = X_MEANING,
	   source_lang = userenv('LANG'),
	   last_update_date = sysdate,
	   last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0
     where seed_qual_id = X_SEED_QUAL_ID
	 and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

end AS_SALES_LEAD_QUALS_PKG;

/
