--------------------------------------------------------
--  DDL for Package Body ALR_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_LOOKUPS_PKG" as
/* $Header: ALRLKUPB.pls 120.3.12010000.1 2008/07/27 06:58:44 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ALR_LOOKUPS
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    ;
begin
  insert into ALR_LOOKUPS (
    LOOKUP_TYPE,
    LOOKUP_CODE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    MEANING,
    ENABLED_FLAG,
    DESCRIPTION,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY
  ) values (
    X_LOOKUP_TYPE,
    X_LOOKUP_CODE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_MEANING,
    X_ENABLED_FLAG,
    X_DESCRIPTION,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOAD_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE_ACTIVE in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
     l_user_id number := 0;
     l_row_id varchar2(64);

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db


  begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

   -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from ALR_LOOKUPS
  where lookup_code = X_LOOKUP_CODE
  and   lookup_type = X_LOOKUP_TYPE;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                x_custom_mode)) then


     ALR_LOOKUPS_PKG.UPDATE_ROW (
       X_LOOKUP_TYPE => X_LOOKUP_TYPE,
       X_LOOKUP_CODE => X_LOOKUP_CODE,
       X_MEANING => X_MEANING,
       X_ENABLED_FLAG => X_ENABLED_FLAG,
       X_DESCRIPTION => X_DESCRIPTION,
       X_START_DATE_ACTIVE => to_date(X_START_DATE_ACTIVE,
                              'YYYY/MM/DD HH24:MI:SS'),
       X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,
                              'YYYY/MM/DD HH24:MI:SS'),
       X_LAST_UPDATE_DATE => f_ludate,
       X_LAST_UPDATED_BY => f_luby,
       X_LAST_UPDATE_LOGIN => 0 );

 end if;
  exception
     when NO_DATA_FOUND then

       ALR_LOOKUPS_PKG.INSERT_ROW (
         X_ROWID => l_row_id,
         X_LOOKUP_TYPE => X_LOOKUP_TYPE,
         X_LOOKUP_CODE => X_LOOKUP_CODE,
         X_MEANING => X_MEANING,
         X_ENABLED_FLAG => X_ENABLED_FLAG,
         X_DESCRIPTION => X_DESCRIPTION,
         X_START_DATE_ACTIVE => to_date(X_START_DATE_ACTIVE,
                                'YYYY/MM/DD HH24:MI:SS'),
         X_END_DATE_ACTIVE => to_date(X_END_DATE_ACTIVE,
                              'YYYY/MM/DD HH24:MI:SS'),
         X_CREATION_DATE => f_ludate,
         X_CREATED_BY => f_luby,
         X_LAST_UPDATE_DATE => f_ludate,
         X_LAST_UPDATED_BY => f_luby,
         X_LAST_UPDATE_LOGIN => 0 );
end LOAD_ROW;


procedure LOCK_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE
) is
  cursor c1 is select
      MEANING,
      ENABLED_FLAG,
      DESCRIPTION,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      LOOKUP_TYPE,
      LOOKUP_CODE
    from ALR_LOOKUPS
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    for update of LOOKUP_TYPE nowait;
begin
  for recinfo in c1 loop
      if (    (recinfo.LOOKUP_TYPE = X_LOOKUP_TYPE)
          AND (recinfo.LOOKUP_CODE = X_LOOKUP_CODE)
          AND (recinfo.MEANING = X_MEANING)
          AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
          AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
               OR ((recinfo.START_DATE_ACTIVE is null)
               AND (X_START_DATE_ACTIVE is null)))
          AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((recinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ALR_LOOKUPS set
    MEANING = X_MEANING,
    ENABLED_FLAG = X_ENABLED_FLAG,
    DESCRIPTION = X_DESCRIPTION,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LOOKUP_TYPE = X_LOOKUP_TYPE,
    LOOKUP_CODE = X_LOOKUP_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2
) is
begin
  delete from ALR_LOOKUPS
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end ALR_LOOKUPS_PKG;

/
