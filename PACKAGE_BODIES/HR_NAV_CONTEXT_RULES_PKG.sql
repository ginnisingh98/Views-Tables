--------------------------------------------------------
--  DDL for Package Body HR_NAV_CONTEXT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAV_CONTEXT_RULES_PKG" as
/* $Header: hrwcrlct.pkb 115.3 2004/01/08 01:25:22 adudekul noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAV_CONTEXT_RULE_ID in NUMBER,
  X_GLOBAL_USAGE_ID in NUMBER,
  X_EVALUATION_TYPE_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
) is
  cursor C is select ROWID from HR_NAVIGATION_CONTEXT_RULES
    where NAV_CONTEXT_RULE_ID = X_NAV_CONTEXT_RULE_ID
    ;
begin
  insert into HR_NAVIGATION_CONTEXT_RULES (
    NAV_CONTEXT_RULE_ID,
    GLOBAL_USAGE_ID,
    EVALUATION_TYPE_CODE,
    VALUE
  ) values (
    X_NAV_CONTEXT_RULE_ID,
    X_GLOBAL_USAGE_ID,
    X_EVALUATION_TYPE_CODE,
    X_VALUE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_NAV_CONTEXT_RULE_ID in NUMBER,
  X_GLOBAL_USAGE_ID in NUMBER,
  X_EVALUATION_TYPE_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
) is
  cursor c1 is select
      GLOBAL_USAGE_ID,
      EVALUATION_TYPE_CODE,
      VALUE
    from HR_NAVIGATION_CONTEXT_RULES
    where NAV_CONTEXT_RULE_ID = X_NAV_CONTEXT_RULE_ID
    for update of NAV_CONTEXT_RULE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.EVALUATION_TYPE_CODE = X_EVALUATION_TYPE_CODE)
          AND (tlinfo.GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID)
          AND ((tlinfo.VALUE = X_VALUE)
               OR ((tlinfo.VALUE is null) AND (X_VALUE is null)))
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
  X_NAV_CONTEXT_RULE_ID in NUMBER,
  X_GLOBAL_USAGE_ID in NUMBER,
  X_EVALUATION_TYPE_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
) is
begin
  update HR_NAVIGATION_CONTEXT_RULES set
    GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID,
    EVALUATION_TYPE_CODE = X_EVALUATION_TYPE_CODE,
    VALUE = X_VALUE
  where NAV_CONTEXT_RULE_ID = X_NAV_CONTEXT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAV_CONTEXT_RULE_ID in NUMBER
) is
begin
  delete from HR_NAVIGATION_CONTEXT_RULES
  where NAV_CONTEXT_RULE_ID = X_NAV_CONTEXT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_GLOBAL_NAME in VARCHAR2,
  X_IN_OR_OUT in VARCHAR2,
  X_EVALUATION_TYPE_CODE in VARCHAR2,
  X_VALUE in VARCHAR2
) is
X_NAV_CONTEXT_RULE_ID NUMBER;
X_GLOBAL_USAGE_ID NUMBER;
X_ROWID VARCHAR2(30);
X_NAV_UNIT_ID NUMBER;
begin

  if hr_workflows_pkg.g_load_taskflow <> 'N' then

    begin
      select NAV_UNIT_ID
      into X_NAV_UNIT_ID
      from HR_NAVIGATION_UNITS
      where FORM_NAME = X_FORM_NAME
      and nvl(BLOCK_NAME,hr_api.g_varchar2) = nvl(X_BLOCK_NAME,hr_api.g_varchar2);
    end;

    select GLOBAL_USAGE_ID
    into X_GLOBAL_USAGE_ID
    from HR_NAV_UNIT_GLOBAL_USAGES
    where GLOBAL_NAME = X_GLOBAL_NAME
    and IN_OR_OUT = X_IN_OR_OUT
    and NAV_UNIT_ID = X_NAV_UNIT_ID;

    --
    -- Fix for bug 3274423 starts here.
    -- Before updating the record, compare the database row with the row in ldt file.
    -- The SELECT statement is comparing for the complete row. So no need for explicit check.
    -- Therefore, if no data found INSERT.
    --
    begin
      select NCR.NAV_CONTEXT_RULE_ID
      into X_NAV_CONTEXT_RULE_ID
      from HR_NAVIGATION_CONTEXT_RULES NCR
      where NCR.EVALUATION_TYPE_CODE = X_EVALUATION_TYPE_CODE
      and nvl(NCR.VALUE,hr_api.g_varchar2) = nvl(X_VALUE,hr_api.g_varchar2)
      and NCR.GLOBAL_USAGE_ID = X_GLOBAL_USAGE_ID;
    exception
        when no_data_found then
          select HR_NAVIGATION_CONTEXT_RULES_S.NEXTVAL
          into X_NAV_CONTEXT_RULE_ID
          from DUAL;

           INSERT_ROW(
            X_ROWID,
            X_NAV_CONTEXT_RULE_ID,
            X_GLOBAL_USAGE_ID,
            X_EVALUATION_TYPE_CODE,
            X_VALUE
          );

        when too_many_rows then
          raise_application_error(-20001,X_EVALUATION_TYPE_CODE||':'||X_VALUE||':'||X_GLOBAL_USAGE_ID);
    end;

    /*begin
      UPDATE_ROW(
        X_NAV_CONTEXT_RULE_ID,
        X_GLOBAL_USAGE_ID,
        X_EVALUATION_TYPE_CODE,
        X_VALUE
      );
    exception
        when no_data_found then
          INSERT_ROW(
            X_ROWID,
            X_NAV_CONTEXT_RULE_ID,
            X_GLOBAL_USAGE_ID,
            X_EVALUATION_TYPE_CODE,
            X_VALUE
          );
    end; */
   --
   -- Fix for bug 3274423 ends here.
   --

  end if;

end LOAD_ROW;

end HR_NAV_CONTEXT_RULES_PKG;

/
