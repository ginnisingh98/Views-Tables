--------------------------------------------------------
--  DDL for Package Body HR_NAVIGATION_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAVIGATION_NODES_PKG" as
/* $Header: hrdwnlct.pkb 120.0 2005/05/30 23:56:41 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAV_NODE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
) is
  cursor C is select ROWID from HR_NAVIGATION_NODES
    where NAV_NODE_ID = X_NAV_NODE_ID
    ;
begin
  insert into HR_NAVIGATION_NODES (
    NAV_NODE_ID,
    NAV_UNIT_ID,
    NAME,
    CUSTOMIZED_RESTRICTION_ID
  ) values (
    X_NAV_NODE_ID,
    X_NAV_UNIT_ID,
    X_NAME,
    X_CUSTOMIZED_RESTRICTION_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_NAV_NODE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
) is
  cursor c1 is select
      NAV_UNIT_ID,
      CUSTOMIZED_RESTRICTION_ID,
      NAME
    from HR_NAVIGATION_NODES
    where NAV_NODE_ID = X_NAV_NODE_ID
    for update of NAV_NODE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.NAV_UNIT_ID = X_NAV_UNIT_ID)
          AND ((tlinfo.CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID)
               OR ((tlinfo.CUSTOMIZED_RESTRICTION_ID is null) AND (X_CUSTOMIZED_RESTRICTION_ID is null)))
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
  X_NAV_NODE_ID in NUMBER,
  X_NAV_UNIT_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CUSTOMIZED_RESTRICTION_ID in NUMBER
) is
begin
  update HR_NAVIGATION_NODES set
    NAV_UNIT_ID = X_NAV_UNIT_ID,
    NAME = X_NAME,
    CUSTOMIZED_RESTRICTION_ID = X_CUSTOMIZED_RESTRICTION_ID
  where NAV_NODE_ID = X_NAV_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAV_NODE_ID in NUMBER
) is
begin
  delete from HR_NAVIGATION_NODES
  where NAV_NODE_ID = X_NAV_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_NODE_NAME in VARCHAR2,
  X_NAV_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_ORG_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CUSTOMIZED_FORM_NAME in VARCHAR2,
  X_CUSTOMIZATION_NAME in VARCHAR2
) is
X_NAV_NODE_ID NUMBER;
X_NAV_UNIT_ID NUMBER;
X_ROWID VARCHAR2(30);
X_CUSTOMIZED_RESTRICTION_ID NUMBER;
X_APPLICATION_ID NUMBER;
X_BUSINESS_GROUP_ID NUMBER;
Y_NAV_UNIT_ID NUMBER;
Y_NODE_NAME VARCHAR2(80);
Y_CUSTOMIZED_RESTRICTION_ID NUMBER;
begin

  if hr_workflows_pkg.g_load_taskflow <> 'N' then

    if X_NAV_FORM_NAME is not null then
      select NAV_UNIT_ID
      into X_NAV_UNIT_ID
      from HR_NAVIGATION_UNITS
      where FORM_NAME = X_NAV_FORM_NAME
      and nvl(BLOCK_NAME,hr_api.g_varchar2) = nvl(X_BLOCK_NAME,hr_api.g_varchar2);
    else
      X_NAV_UNIT_ID := null;
    end if;

    if X_APPLICATION_SHORT_NAME is not null then
      select APPLICATION_ID
      into X_APPLICATION_ID
      from FND_APPLICATION
      where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME;
    else
      X_APPLICATION_ID := null;
    end if;

    if X_ORG_NAME is not null then
      select ORGANIZATION_ID
      into X_BUSINESS_GROUP_ID
      from HR_ORGANIZATION_UNITS
      where NAME = X_ORG_NAME;
    else
      X_BUSINESS_GROUP_ID := null;
    end if;

    if X_CUSTOMIZATION_NAME is not null
    and X_APPLICATION_SHORT_NAME is not null
    and X_CUSTOMIZED_FORM_NAME is not null then
      BEGIN
	select CUSTOMIZED_RESTRICTION_ID
	into X_CUSTOMIZED_RESTRICTION_ID
	from PAY_CUSTOMIZED_RESTRICTIONS
	where NAME = X_CUSTOMIZATION_NAME
	and APPLICATION_ID = X_APPLICATION_ID
	and FORM_NAME = X_CUSTOMIZED_FORM_NAME
	and nvl(BUSINESS_GROUP_ID,hr_api.g_number) =
            nvl(X_BUSINESS_GROUP_ID,hr_api.g_number)
	and nvl(LEGISLATION_CODE,hr_api.g_varchar2) =
            nvl(X_LEGISLATION_CODE,hr_api.g_varchar2);
      EXCEPTION
        when no_data_found then
          X_CUSTOMIZED_RESTRICTION_ID := null;
        when others then
          raise;
      END;
    else
      X_CUSTOMIZED_RESTRICTION_ID := null;
    end if;

    begin
      select NAV_NODE_ID, NAV_UNIT_ID, NAME, CUSTOMIZED_RESTRICTION_ID
      into X_NAV_NODE_ID, Y_NAV_UNIT_ID, Y_NODE_NAME, Y_CUSTOMIZED_RESTRICTION_ID
      from HR_NAVIGATION_NODES
      where NAME = X_NODE_NAME;
      --
      -- Fix for bug 3274423 starts here.
      -- Before updating the record, compare the database row with the row in ldt file.
      -- If both are same skip updating.
      --
      -- bug 3503352 Starts Here
      -- Description : modified the condition for CUSTOMIZED_RESTRICTION_ID.
      IF X_NAV_UNIT_ID <> Y_NAV_UNIT_ID OR
         X_NODE_NAME   <> Y_NODE_NAME   OR
         X_CUSTOMIZED_RESTRICTION_ID is null and Y_CUSTOMIZED_RESTRICTION_ID is not null OR
         X_CUSTOMIZED_RESTRICTION_ID is not null and Y_CUSTOMIZED_RESTRICTION_ID is null OR
         (X_CUSTOMIZED_RESTRICTION_ID is not null and Y_CUSTOMIZED_RESTRICTION_ID is not null
         and X_CUSTOMIZED_RESTRICTION_ID <> Y_CUSTOMIZED_RESTRICTION_ID) THEN
        UPDATE_ROW(
        X_NAV_NODE_ID,
        X_NAV_UNIT_ID,
        X_NODE_NAME,
        X_CUSTOMIZED_RESTRICTION_ID
        );
      END IF;
    exception
        when no_data_found then
          select HR_NAVIGATION_NODES_S.NEXTVAL
          into X_NAV_NODE_ID
          from DUAL;

          INSERT_ROW(
            X_ROWID,
            X_NAV_NODE_ID,
            X_NAV_UNIT_ID,
            X_NODE_NAME,
            X_CUSTOMIZED_RESTRICTION_ID
          );
    end;
    -- bug 3503352 Ends Here
    --
    -- Fix for bug 3274423 ends here.
    --


  end if;

end LOAD_ROW;

end HR_NAVIGATION_NODES_PKG;

/
