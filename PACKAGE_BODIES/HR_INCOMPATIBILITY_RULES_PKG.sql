--------------------------------------------------------
--  DDL for Package Body HR_INCOMPATIBILITY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INCOMPATIBILITY_RULES_PKG" as
/* $Header: hrwirlct.pkb 115.2 2002/12/11 11:17:12 raranjan noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
) is
  cursor C is select ROWID from HR_INCOMPATIBILITY_RULES
    where FROM_NAV_UNIT_ID = X_FROM_NAV_UNIT_ID
    and TO_NAV_UNIT_ID = X_TO_NAV_UNIT_ID
    ;
begin
  insert into HR_INCOMPATIBILITY_RULES (
    FROM_NAV_UNIT_ID,
    TO_NAV_UNIT_ID
  ) values (
    X_FROM_NAV_UNIT_ID,
    X_TO_NAV_UNIT_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
) is
  cursor c1 is select
      TO_NAV_UNIT_ID
    from HR_INCOMPATIBILITY_RULES
    where FROM_NAV_UNIT_ID = X_FROM_NAV_UNIT_ID
    and TO_NAV_UNIT_ID = X_TO_NAV_UNIT_ID
    for update of FROM_NAV_UNIT_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.TO_NAV_UNIT_ID = X_TO_NAV_UNIT_ID)
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
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
) is
begin
  update HR_INCOMPATIBILITY_RULES set
    TO_NAV_UNIT_ID = X_TO_NAV_UNIT_ID
  where FROM_NAV_UNIT_ID = X_FROM_NAV_UNIT_ID
  and TO_NAV_UNIT_ID = X_TO_NAV_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FROM_NAV_UNIT_ID in NUMBER,
  X_TO_NAV_UNIT_ID in NUMBER
) is
begin
  delete from HR_INCOMPATIBILITY_RULES
  where FROM_NAV_UNIT_ID = X_FROM_NAV_UNIT_ID
  and TO_NAV_UNIT_ID = X_TO_NAV_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW(
  X_FROM_FORM_NAME in VARCHAR2,
  X_FROM_BLOCK_NAME in VARCHAR2,
  X_TO_FORM_NAME in VARCHAR2,
  X_TO_BLOCK_NAME in VARCHAR2,
  X_NAV_FLAG  in varchar2
) is
X_ROWID VARCHAR2(30);
X_FROM_NAV_UNIT_ID NUMBER;
X_TO_NAV_UNIT_ID NUMBER;
l_flag varchar2(1) := 'Y';
begin

-- Note that for incompatibility rules, the upload will fail if either
-- of the nav_unit_id's have not been extracted in the download or are
-- not already present on the remote site.  This can happen because a
-- navigation unit can exist across taskflows and therefore need not
-- be extracted for a particular taskflow.  However, to ensure that
-- this does not stop the data upload on the remote site, the uploader
-- traps and surpresses any error raised because of this.  Since the
-- downloader downloads for the occurrence of navigation unit in both
-- from and to nav_unit_id columns, the relevant records will get
-- populated when the other navigation unit is being loaded.
-- x_nav_flag is used to raise an application error if no data is
-- found when 'to' navigation units are being handled.  The l_flag
-- is used to surpress errors when 'from' navigtion units are being
-- handled.

  if hr_workflows_pkg.g_load_taskflow <> 'N' then

    l_flag := 'Y';

    begin

      select NAV_UNIT_ID
      into X_FROM_NAV_UNIT_ID
      from HR_NAVIGATION_UNITS
      where FORM_NAME = X_FROM_FORM_NAME
      and nvl(BLOCK_NAME,hr_api.g_varchar2)  = nvl(X_FROM_BLOCK_NAME,hr_api.g_varchar2);

    exception
      when no_data_found then
        if x_nav_flag = 'FROM' then
          raise;
        else
          l_flag := 'N';
        end if;
    end;


    begin

      select NAV_UNIT_ID
      into X_TO_NAV_UNIT_ID
      from HR_NAVIGATION_UNITS
      where FORM_NAME = X_TO_FORM_NAME
      and nvl(BLOCK_NAME,hr_api.g_varchar2)  = nvl(X_TO_BLOCK_NAME,hr_api.g_varchar2);

    exception
      when no_data_found then
        if x_nav_flag = 'TO' then
          raise;
        else
          l_flag := 'N';
        end if;
    end;

    if l_flag = 'Y' then

      begin
        UPDATE_ROW(
          X_FROM_NAV_UNIT_ID,
          X_TO_NAV_UNIT_ID
        );
      exception
          when no_data_found then
            INSERT_ROW(
              X_ROWID,
              X_FROM_NAV_UNIT_ID,
              X_TO_NAV_UNIT_ID
              );
      end;

    end if;

  end if;

end LOAD_ROW;

end HR_INCOMPATIBILITY_RULES_PKG;

/
