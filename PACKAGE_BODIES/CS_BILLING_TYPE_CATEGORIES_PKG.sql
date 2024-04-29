--------------------------------------------------------
--  DDL for Package Body CS_BILLING_TYPE_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_BILLING_TYPE_CATEGORIES_PKG" as
/* $Header: csxchbcb.pls 115.4 2003/02/11 19:21:38 cnemalik noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_BILLING_TYPE in VARCHAR2,
  X_BILLING_CATEGORY in VARCHAR2,
  X_ROLLUP_ITEM_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CS_BILLING_TYPE_CATEGORIES
    where BILLING_TYPE = X_BILLING_TYPE
    ;
begin
  insert into CS_BILLING_TYPE_CATEGORIES (
    BILLING_TYPE,
    BILLING_CATEGORY,
    ROLLUP_ITEM_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SEEDED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BILLING_TYPE,
    X_BILLING_CATEGORY,
    X_ROLLUP_ITEM_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_SEEDED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
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


procedure LOCK_ROW (
  X_BILLING_TYPE in VARCHAR2,
  X_BILLING_CATEGORY in VARCHAR2,
  X_ROLLUP_ITEM_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE
) is
  cursor c is select
      BILLING_CATEGORY,
      ROLLUP_ITEM_ID,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from CS_BILLING_TYPE_CATEGORIES
    where BILLING_TYPE = X_BILLING_TYPE
    for update of BILLING_TYPE nowait;
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
  if (    (recinfo.BILLING_CATEGORY = X_BILLING_CATEGORY)
      AND ((recinfo.ROLLUP_ITEM_ID = X_ROLLUP_ITEM_ID)
           OR ((recinfo.ROLLUP_ITEM_ID is null) AND (X_ROLLUP_ITEM_ID is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_BILLING_TYPE in VARCHAR2,
  X_BILLING_CATEGORY in VARCHAR2,
  X_ROLLUP_ITEM_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CS_BILLING_TYPE_CATEGORIES set
    BILLING_CATEGORY = X_BILLING_CATEGORY,
    ROLLUP_ITEM_ID = X_ROLLUP_ITEM_ID,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SEEDED_FLAG = x_SEEDED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where BILLING_TYPE = X_BILLING_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_BILLING_TYPE in VARCHAR2
) is
begin
  delete from CS_BILLING_TYPE_CATEGORIES
  where BILLING_TYPE = X_BILLING_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE LOAD_ROW(
  x_billing_type        in VARCHAR2,
  x_billing_category    in VARCHAR2,
  x_start_date_active   in VARCHAR2,
  x_end_date_active     in VARCHAR2,
  x_rollup_item_id      in NUMBER,
  x_owner               in VARCHAR2,
  x_custom_mode         in VARCHAR2,
  x_seeded_flag         in VARCHAR2,
  x_last_update_date    in VARCHAR2 ) is

 l_user_id number;
 l_rowid varchar(30);

 row_id varchar2(64);
 v_audit_enabled_flag varchar2(1);
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 f_stdate  date;    -- entity start date active in file
 f_enddate date;    -- entity end date active in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db
 db_billing_type  varchar2(30);

begin

     if (x_owner = 'SEED') then
            l_user_id := 1;
     else
            l_user_id := 0;
     end if;

  -- Translate owner to file_last_updated_by
     f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char dates to dates
     f_ludate  := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
     f_stdate  := to_date(X_START_DATE_ACTIVE, 'YYYY/MM/DD');
     f_enddate := to_date(X_END_DATE_ACTIVE, 'YYYY/MM/DD');

     select billing_type, last_updated_by, last_update_date
     into db_billing_type, db_luby, db_ludate
     from cs_billing_type_categories
     where billing_type = X_BILLING_TYPE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then


     CS_BILLING_TYPE_CATEGORIES_PKG.UPDATE_ROW (
        X_BILLING_TYPE      => x_billing_type,
        X_BILLING_CATEGORY  => x_billing_category,
        X_ROLLUP_ITEM_ID    => x_rollup_item_id,
        X_START_DATE_ACTIVE => f_stdate,
        X_END_DATE_ACTIVE   => f_enddate,
        X_SEEDED_FLAG       => x_seeded_flag,
        X_LAST_UPDATE_DATE  => f_ludate,
        X_LAST_UPDATED_BY   => f_luby,
        X_LAST_UPDATE_LOGIN => 0);
  end if;

exception
   when no_data_found then

          CS_BILLING_TYPE_CATEGORIES_PKG.INSERT_ROW (
              X_ROWID             => l_rowid,
              X_BILLING_TYPE      => x_billing_type,
              X_BILLING_CATEGORY  => x_billing_category,
              X_ROLLUP_ITEM_ID    => x_rollup_item_id,
              X_START_DATE_ACTIVE => f_stdate,
              X_END_DATE_ACTIVE   => f_enddate,
              X_SEEDED_FLAG       => x_seeded_flag,
              X_CREATION_DATE     => f_ludate,
              X_CREATED_BY        => f_luby,
              X_LAST_UPDATE_DATE  => f_ludate,
              X_LAST_UPDATED_BY   => f_luby,
              X_LAST_UPDATE_LOGIN => 0);

end LOAD_ROW;

end CS_BILLING_TYPE_CATEGORIES_PKG;

/
