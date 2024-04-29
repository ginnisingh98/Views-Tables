--------------------------------------------------------
--  DDL for Package Body HR_NAV_UNIT_GLOBAL_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAV_UNIT_GLOBAL_USAGES_PKG" as
/* $Header: hrnvulct.pkb 115.4 2004/01/08 01:28:45 adudekul noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GLOBAL_USAGE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_GLOBAL_NAME in VARCHAR2,
  X_IN_OR_OUT in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2
) is
  cursor C is select ROWID from HR_NAV_UNIT_GLOBAL_USAGES
    where GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID
    ;
begin
  insert into HR_NAV_UNIT_GLOBAL_USAGES (
    GLOBAL_USAGE_ID,
    NAV_UNIT_ID,
    GLOBAL_NAME,
    IN_OR_OUT,
    MANDATORY_FLAG
  ) values (
    X_GLOBAL_USAGE_ID,
    X_NAV_UNIT_ID,
    X_GLOBAL_NAME,
    X_IN_OR_OUT,
    X_MANDATORY_FLAG);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_GLOBAL_USAGE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_GLOBAL_NAME in VARCHAR2,
  X_IN_OR_OUT in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2
) is
  cursor c1 is select
      NAV_UNIT_ID,
      GLOBAL_NAME,
      IN_OR_OUT,
      MANDATORY_FLAG
    from HR_NAV_UNIT_GLOBAL_USAGES
    where GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID
    for update of GLOBAL_USAGE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.GLOBAL_NAME = X_GLOBAL_NAME)
          AND (tlinfo.NAV_UNIT_ID = X_NAV_UNIT_ID)
          AND (tlinfo.IN_OR_OUT = X_IN_OR_OUT)
          AND (tlinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
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
  X_GLOBAL_USAGE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_GLOBAL_NAME in VARCHAR2,
  X_IN_OR_OUT in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2
) is
begin
  update HR_NAV_UNIT_GLOBAL_USAGES set
    NAV_UNIT_ID = X_NAV_UNIT_ID,
    GLOBAL_NAME = X_GLOBAL_NAME,
    IN_OR_OUT = X_IN_OR_OUT,
    MANDATORY_FLAG = X_MANDATORY_FLAG
  where GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GLOBAL_USAGE_ID in NUMBER
) is
begin
  delete from HR_NAV_UNIT_GLOBAL_USAGES
  where GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW(
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_GLOBAL_NAME in VARCHAR2,
  X_IN_OR_OUT in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2
) is
X_GLOBAL_USAGE_ID NUMBER;
X_NAV_UNIT_ID NUMBER;
X_ROWID VARCHAR2(30);
Y_MANDATORY_FLAG VARCHAR2(30);
begin

  if hr_workflows_pkg.g_load_taskflow <> 'N' then

    if X_FORM_NAME is not null then
      select NAV_UNIT_ID
      into X_NAV_UNIT_ID
      from HR_NAVIGATION_UNITS
      where FORM_NAME = X_FORM_NAME
      and nvl(BLOCK_NAME,hr_api.g_varchar2) = nvl(X_BLOCK_NAME,hr_api.g_varchar2);
    end if;

    begin
      select GLOBAL_USAGE_ID,  MANDATORY_FLAG
      into X_GLOBAL_USAGE_ID, Y_MANDATORY_FLAG
      from HR_NAV_UNIT_GLOBAL_USAGES
      where GLOBAL_NAME = X_GLOBAL_NAME
      and IN_OR_OUT = X_IN_OR_OUT
      and NAV_UNIT_ID = X_NAV_UNIT_ID;

      --
      -- Fix for bug 3274423 starts here.
      -- Before updating the record, compare the database row with the row in ldt file.
      -- If both are same skip updating.
      --
     IF X_MANDATORY_FLAG <> Y_MANDATORY_FLAG THEN
      UPDATE_ROW(
        X_GLOBAL_USAGE_ID,
        X_NAV_UNIT_ID,
        X_GLOBAL_NAME,
        X_IN_OR_OUT,
        X_MANDATORY_FLAG
      );
     END IF;

    exception
        when no_data_found then
          select HR_NAV_UNIT_GLOBAL_USAGES_S.NEXTVAL
          into X_GLOBAL_USAGE_ID
          from DUAL;

          INSERT_ROW(
          X_ROWID,
          X_GLOBAL_USAGE_ID,
          X_NAV_UNIT_ID,
          X_GLOBAL_NAME,
          X_IN_OR_OUT,
          X_MANDATORY_FLAG
          );
    end;
    --
    -- Fix for bug 3274423 ends here.
    --

  end if;

end LOAD_ROW;

end HR_NAV_UNIT_GLOBAL_USAGES_PKG;

/
