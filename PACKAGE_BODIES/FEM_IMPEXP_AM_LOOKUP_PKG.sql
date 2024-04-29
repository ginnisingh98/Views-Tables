--------------------------------------------------------
--  DDL for Package Body FEM_IMPEXP_AM_LOOKUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_IMPEXP_AM_LOOKUP_PKG" as
/* $Header: FEMILKPB.pls 120.0 2005/06/06 20:13:12 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_AM_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_IMPEXP_AM_LOOKUP
    where OBJECT_TYPE_CODE = X_OBJECT_TYPE_CODE
    ;
begin
  insert into FEM_IMPEXP_AM_LOOKUP(
    OBJECT_TYPE_CODE,
    AM_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values
  (
    X_OBJECT_TYPE_CODE,
    X_AM_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_AM_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_IMPEXP_AM_LOOKUP set
    AM_NAME = X_AM_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_TYPE_CODE = X_OBJECT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_TYPE_CODE in VARCHAR2
) is
begin
  delete from FEM_IMPEXP_AM_LOOKUP
  where OBJECT_TYPE_CODE = X_OBJECT_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW(
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_AM_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2) is

        row_id varchar2(64);
        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
    begin

         -- Translate owner to file_last_updated_by
         if (X_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FEM_IMPEXP_AM_LOOKUP
          where OBJECT_TYPE_CODE = X_OBJECT_TYPE_CODE;

          -- Update record, honoring customization mode.
          -- Record should be updated only if:
          -- a. CUSTOM_MODE = FORCE, or
          -- b. file owner is CUSTOM, db owner is SEED
          -- c. owners are the same, and file_date > db_date
          if ((X_CUSTOM_MODE = 'FORCE') or
              ((f_luby = 0) and (db_luby = 1)) or
              ((f_luby = db_luby) and (f_ludate > db_ludate)))
          then
            FEM_IMPEXP_AM_LOOKUP_PKG.UPDATE_ROW(
		  X_OBJECT_TYPE_CODE => X_OBJECT_TYPE_CODE,
		  X_AM_NAME => X_AM_NAME,
		  X_LAST_UPDATE_DATE => f_ludate,
                  X_LAST_UPDATED_BY => f_luby,
                  X_LAST_UPDATE_LOGIN => 0);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases
            FEM_IMPEXP_AM_LOOKUP_PKG.Insert_Row(
              X_ROWID => row_id,
              X_OBJECT_TYPE_CODE => X_OBJECT_TYPE_CODE,
              X_AM_NAME => X_AM_NAME,
              X_CREATION_DATE => f_ludate,
              X_CREATED_BY => f_luby,
              X_LAST_UPDATE_DATE => f_ludate,
              X_LAST_UPDATED_BY => f_luby,
              X_LAST_UPDATE_LOGIN => 0);
     end LOAD_ROW;
end FEM_IMPEXP_AM_LOOKUP_PKG;

/
