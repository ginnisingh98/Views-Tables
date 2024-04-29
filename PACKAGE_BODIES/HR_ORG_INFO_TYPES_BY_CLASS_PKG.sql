--------------------------------------------------------
--  DDL for Package Body HR_ORG_INFO_TYPES_BY_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORG_INFO_TYPES_BY_CLASS_PKG" as
/* $Header: hroiclct.pkb 120.3.12000000.1 2007/01/21 17:34:47 appldev ship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ORG_CLASSIFICATION in VARCHAR2,
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_ORG_INFO_TYPES_BY_CLASS
    where ORG_CLASSIFICATION = X_ORG_CLASSIFICATION
    and ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
    ;
begin
  insert into HR_ORG_INFO_TYPES_BY_CLASS (
    ORG_CLASSIFICATION,
    ORG_INFORMATION_TYPE,
    MANDATORY_FLAG,
    ENABLED_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE
  ) values(
    X_ORG_CLASSIFICATION,
    X_ORG_INFORMATION_TYPE,
    X_MANDATORY_FLAG,
    X_ENABLED_FLAG,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ORG_CLASSIFICATION in VARCHAR2,
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2
) is
  cursor c1 is select
      MANDATORY_FLAG
    from HR_ORG_INFO_TYPES_BY_CLASS
    where ORG_CLASSIFICATION = X_ORG_CLASSIFICATION
    and ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
    for update of ORG_CLASSIFICATION nowait;
begin
  for tlinfo in c1 loop
       if (tlinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
       then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ORG_CLASSIFICATION in VARCHAR2,
  X_ORG_INFORMATION_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_ORG_INFO_TYPES_BY_CLASS set
    MANDATORY_FLAG = X_MANDATORY_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ORG_CLASSIFICATION = X_ORG_CLASSIFICATION
  and ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ORG_CLASSIFICATION in VARCHAR2,
  X_ORG_INFORMATION_TYPE in VARCHAR2
) is
begin
  delete from HR_ORG_INFO_TYPES_BY_CLASS
  where ORG_CLASSIFICATION = X_ORG_CLASSIFICATION
  and ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW(
X_ORG_INFORMATION_TYPE  IN VARCHAR2,
X_ORG_CLASSIFICATION    IN VARCHAR2,
X_MANDATORY_FLAG        IN VARCHAR2,
X_ENABLED_FLAG          IN VARCHAR2 default 'Y',
X_OWNER                 IN VARCHAR2,
X_LAST_UPDATE_DATE      IN VARCHAR2 default sysdate,
X_CUSTOM_MODE           IN VARCHAR2 default null
) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  l_enabled_flag varchar2(1):=nvl(X_ENABLED_FLAG,'Y');
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
 -- Translate owner to file_last_updated_by
 f_luby := fnd_load_util.owner_id(X_OWNER);
 -- Translate char last_update_date to date
 f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        select LAST_UPDATED_BY, LAST_UPDATE_DATE
        into db_luby, db_ludate
        from HR_ORG_INFO_TYPES_BY_CLASS
        where ORG_INFORMATION_TYPE = X_ORG_INFORMATION_TYPE
        and ORG_CLASSIFICATION=X_ORG_CLASSIFICATION;

        -- Test for customization and version
        if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
            -- Update existing row

                    UPDATE_ROW (
                            X_ORG_CLASSIFICATION ,
                            X_ORG_INFORMATION_TYPE ,
                            X_MANDATORY_FLAG ,
                            l_enabled_flag,
                            f_ludate ,
                            f_luby ,
                            0 );
        END IF;
exception
 when no_data_found then
	      INSERT_ROW (
		        X_ROWID ,
		        X_ORG_CLASSIFICATION ,
		        X_ORG_INFORMATION_TYPE ,
		        X_MANDATORY_FLAG ,
		        l_enabled_flag,
		        f_luby ,
		        f_ludate ,
		        f_ludate ,
		        f_luby ,
		        0 );
end LOAD_ROW;
end HR_ORG_INFO_TYPES_BY_CLASS_PKG;

/
