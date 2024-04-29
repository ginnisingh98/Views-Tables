--------------------------------------------------------
--  DDL for Package Body HR_WORKFLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WORKFLOWS_PKG" as
/* $Header: hrdwflct.pkb 115.7 2004/05/28 02:58:20 adhunter noship $ */

procedure CLEANUP_TASKFLOW_UPDATE (
  X_WORKFLOW_ID in NUMBER
) is
l_nav_node_usage_id NUMBER;
l_nav_path_id number;
CURSOR csr_node_usages IS
  SELECT nav_node_usage_id
  FROM   hr_navigation_node_usages
  WHERE  workflow_id = x_workflow_id;

CURSOR csr_nav_paths is
  SELECT nav_path_id
  FROM   hr_navigation_paths
  WHERE  from_nav_node_usage_id = l_nav_node_usage_id
  OR     to_nav_node_usage_id = l_nav_node_usage_id;
begin
   --
   -- For each node usage attached to a taskflow delete the navigation paths
   -- then delete the node usage record.
   --
   FOR node_usage_record IN csr_node_usages LOOP
   l_nav_node_usage_id := node_usage_record.nav_node_usage_id;
     --
     FOR nav_path_record IN csr_nav_paths LOOP
     l_nav_path_id := nav_path_record.nav_path_id;

       DELETE FROM hr_navigation_paths_tl
       WHERE       nav_path_id = l_nav_path_id;

       DELETE FROM hr_navigation_paths
       WHERE       from_nav_node_usage_id = l_nav_node_usage_id
       OR          to_nav_node_usage_id = l_nav_node_usage_id;
     --
     END LOOP;
     --
     DELETE FROM hr_navigation_node_usages
     WHERE       nav_node_usage_id = l_nav_node_usage_id;
     --
   END LOOP;
end CLEANUP_TASKFLOW_UPDATE;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_WORKFLOW_ID in NUMBER,
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
) is
  cursor C is select ROWID from HR_WORKFLOWS
    where WORKFLOW_ID = X_WORKFLOW_ID
    ;
begin
  insert into HR_WORKFLOWS (
    WORKFLOW_ID,
    WORKFLOW_NAME,
    LEGISLATION_CODE
  )
  values (X_WORKFLOW_ID,X_WORKFLOW_NAME,X_LEGISLATION_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_WORKFLOW_ID in NUMBER,
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
) is
  cursor c1 is select
      WORKFLOW_NAME,
      LEGISLATION_CODE
    from HR_WORKFLOWS
    where WORKFLOW_ID = X_WORKFLOW_ID
    for update of WORKFLOW_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.WORKFLOW_NAME = X_WORKFLOW_NAME)
          AND (tlinfo.LEGISLATION_CODE = X_LEGISLATION_CODE)
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
  X_WORKFLOW_ID in NUMBER,
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_CODE in VARCHAR2
) is
begin
  update HR_WORKFLOWS set
    WORKFLOW_NAME = X_WORKFLOW_NAME,
    LEGISLATION_CODE = X_LEGISLATION_CODE
  where WORKFLOW_ID = X_WORKFLOW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_WORKFLOW_ID in NUMBER
) is
begin
  delete from HR_WORKFLOWS
  where WORKFLOW_ID = X_WORKFLOW_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_WORKFLOW_NAME in VARCHAR2,
  X_LEGISLATION_NAME in VARCHAR2
) is
X_WORKFLOW_ID NUMBER;
X_LEGISLATION_CODE VARCHAR2(2);
X_ROWID VARCHAR2(30);
X_STATUS VARCHAR2(1);
X_ACTION VARCHAR2(1);
begin

  begin
    select TERRITORY_CODE
    into X_LEGISLATION_CODE
    from FND_TERRITORIES_VL
    where TERRITORY_SHORT_NAME=X_LEGISLATION_NAME;

  exception
      when no_data_found then
        null;
  end;

  if X_LEGISLATION_CODE is not null then

    begin

    select STATUS, ACTION
    into   X_STATUS, X_ACTION
    from   HR_LEGISLATION_INSTALLATIONS
    where  LEGISLATION_CODE = X_LEGISLATION_CODE
    and    APPLICATION_SHORT_NAME = 'PER';

    exception
    when no_data_found then
      X_STATUS := null;
      X_ACTION := null;
    end;

  end if;

  if (( X_LEGISLATION_CODE is null ) OR
     (  X_LEGISLATION_CODE is not null AND
        X_LEGISLATION_CODE = 'US' )) OR
     (( X_LEGISLATION_CODE is not null AND
        X_LEGISLATION_CODE <> 'US' ) AND
     (  X_STATUS = 'I' AND X_ACTION is null ) OR
     (( X_STATUS = 'I' OR X_STATUS is null ) AND
     (  X_ACTION in ('I','U','F')))) then

    begin
      select WORKFLOW_ID
      into   X_WORKFLOW_ID
      from   HR_WORKFLOWS
      where  WORKFLOW_NAME=X_WORKFLOW_NAME;

    exception
        when no_data_found then
          select HR_WORKFLOWS_S.NEXTVAL
          into   X_WORKFLOW_ID
          from   DUAL;
    end;

    begin
      cleanup_taskflow_update(X_WORKFLOW_ID);
      UPDATE_ROW(
        X_WORKFLOW_ID,
        X_WORKFLOW_NAME,
        X_LEGISLATION_CODE
      );
      exception
        when no_data_found then
          INSERT_ROW(
              X_ROWID,
              X_WORKFLOW_ID,
              X_WORKFLOW_NAME,
              X_LEGISLATION_CODE);
    end;

    g_load_taskflow := 'Y';

  else
    g_load_taskflow := 'N';

  end if;

end LOAD_ROW;

end HR_WORKFLOWS_PKG;

/
