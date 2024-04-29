--------------------------------------------------------
--  DDL for Package Body HR_NAVIGATION_NODE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAVIGATION_NODE_USAGES_PKG" as
/* $Header: hrnvnlct.pkb 115.3 2004/01/08 01:24:36 adudekul noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAV_NODE_USAGE_ID in NUMBER,
  X_WORKFLOW_ID in NUMBER,
  X_NAV_NODE_ID in NUMBER,
  X_TOP_NODE in VARCHAR2
) is
  cursor C is select ROWID from HR_NAVIGATION_NODE_USAGES
    where NAV_NODE_USAGE_ID = X_NAV_NODE_USAGE_ID
    ;
begin
  insert into HR_NAVIGATION_NODE_USAGES (
    NAV_NODE_USAGE_ID,
    WORKFLOW_ID,
    NAV_NODE_ID,
    TOP_NODE
  ) values (
    X_NAV_NODE_USAGE_ID,
    X_WORKFLOW_ID,
    X_NAV_NODE_ID,
    X_TOP_NODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_NAV_NODE_USAGE_ID in NUMBER,
  X_WORKFLOW_ID in NUMBER,
  X_NAV_NODE_ID in NUMBER,
  X_TOP_NODE in VARCHAR2
) is
  cursor c1 is select
      WORKFLOW_ID,
      NAV_NODE_ID,
      TOP_NODE
    from HR_NAVIGATION_NODE_USAGES
    where NAV_NODE_USAGE_ID = X_NAV_NODE_USAGE_ID
    for update of NAV_NODE_USAGE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.TOP_NODE = X_TOP_NODE)
          AND (tlinfo.WORKFLOW_ID = X_WORKFLOW_ID)
          AND (tlinfo.NAV_NODE_ID = X_NAV_NODE_ID)
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
  X_NAV_NODE_USAGE_ID in NUMBER,
  X_WORKFLOW_ID in NUMBER,
  X_NAV_NODE_ID in NUMBER,
  X_TOP_NODE in VARCHAR2
) is
begin
  update HR_NAVIGATION_NODE_USAGES set
    WORKFLOW_ID = X_WORKFLOW_ID,
    NAV_NODE_ID = X_NAV_NODE_ID,
    TOP_NODE = X_TOP_NODE
  where NAV_NODE_USAGE_ID = X_NAV_NODE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAV_NODE_USAGE_ID in NUMBER
) is
begin
  delete from HR_NAVIGATION_NODE_USAGES
  where NAV_NODE_USAGE_ID = X_NAV_NODE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW(
  X_WORKFLOW_NAME in VARCHAR2,
  X_NODE_NAME in VARCHAR2,
  X_TOP_NODE in VARCHAR2
) is
X_NAV_NODE_USAGE_ID NUMBER;
X_WORKFLOW_ID NUMBER;
X_NAV_NODE_ID NUMBER;
X_ROWID VARCHAR2(30);
begin

  if hr_workflows_pkg.g_load_taskflow <> 'N' then

    if X_WORKFLOW_NAME is not null then
      select WORKFLOW_ID
      into X_WORKFLOW_ID
      from HR_WORKFLOWS
      where WORKFLOW_NAME = X_WORKFLOW_NAME;
    else
      X_WORKFLOW_ID := null;
    end if;

    if X_NODE_NAME is not null then
      select NAV_NODE_ID
      into X_NAV_NODE_ID
      from HR_NAVIGATION_NODES
      where NAME = X_NODE_NAME;
    else
      X_NAV_NODE_ID := null;
    end if;

    begin
      select NAV_NODE_USAGE_ID
      into X_NAV_NODE_USAGE_ID
      from HR_NAVIGATION_NODE_USAGES
      where WORKFLOW_ID = X_WORKFLOW_ID
      and NAV_NODE_ID = X_NAV_NODE_ID
      and TOP_NODE = X_TOP_NODE;
    exception
        when no_data_found then
          select HR_NAVIGATION_NODE_USAGES_S.NEXTVAL
          into X_NAV_NODE_USAGE_ID
          from dual;
   --
   -- Fix for bug 3274423 starts here.
   -- Before updating the record, compare the database row with the row in ldt file.
   -- The SELECT statement above is checking for all the columns in the table. So no
   -- need for explicit check. Therefore if not found then insert.
   --
   /* end;

    begin
      UPDATE_ROW(
        X_NAV_NODE_USAGE_ID,
        X_WORKFLOW_ID,
        X_NAV_NODE_ID,
        X_TOP_NODE
      );
    exception
        when no_data_found then  */

    --
    -- Fix for bug 3274423 ends here.
    --
          INSERT_ROW(
            X_ROWID,
            X_NAV_NODE_USAGE_ID,
            X_WORKFLOW_ID,
            X_NAV_NODE_ID,
            X_TOP_NODE
          );
    end;

  end if;

end LOAD_ROW;

end HR_NAVIGATION_NODE_USAGES_PKG;

/
