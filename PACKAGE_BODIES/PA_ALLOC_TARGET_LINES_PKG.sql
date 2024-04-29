--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_TARGET_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_TARGET_LINES_PKG" AS
 /* $Header: PAXATTLB.pls 120.2 2005/08/19 16:19:08 ramurthy noship $  */
procedure INSERT_ROW (
  X_ROWID 		in out NOCOPY VARCHAR2,
  X_RULE_ID 		in NUMBER,
  X_LINE_NUM 		in NUMBER,
  X_PROJECT_ORG_ID 	in NUMBER,
  X_TASK_ORG_ID 	in NUMBER,
  X_PROJECT_TYPE 	in VARCHAR2,
  X_CLASS_CATEGORY 	in VARCHAR2,
  X_CLASS_CODE 		in VARCHAR2,
  X_SERVICE_TYPE 	in VARCHAR2,
  X_PROJECT_ID 		in NUMBER,
  X_TASK_ID 		in NUMBER,
  X_EXCLUDE_FLAG 	in VARCHAR2,
  X_BILLABLE_ONLY_FLAG 	in VARCHAR2,
  X_LINE_PERCENT 	in NUMBER,
  X_CREATED_BY		in NUMBER,
  X_CREATION_DATE 	in DATE,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER
  ) is
    cursor C is select ROWID from PA_ALLOC_TARGET_LINES
      where RULE_ID = X_RULE_ID
      and LINE_NUM = X_LINE_NUM;
  begin
  insert into PA_ALLOC_TARGET_LINES (
    RULE_ID,
    LINE_NUM,
    PROJECT_ORG_ID,
    TASK_ORG_ID,
    PROJECT_TYPE,
    CLASS_CATEGORY,
    CLASS_CODE,
    SERVICE_TYPE,
    PROJECT_ID,
    TASK_ID,
    EXCLUDE_FLAG,
    BILLABLE_ONLY_FLAG,
    LINE_PERCENT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RULE_ID,
    X_LINE_NUM,
    X_PROJECT_ORG_ID,
    X_TASK_ORG_ID,
    X_PROJECT_TYPE,
    X_CLASS_CATEGORY,
    X_CLASS_CODE,
    X_SERVICE_TYPE,
    X_PROJECT_ID,
    X_TASK_ID,
    X_EXCLUDE_FLAG,
    X_BILLABLE_ONLY_FLAG,
    X_LINE_PERCENT,
    X_CREATED_BY,
    X_CREATION_DATE,
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
  X_RULE_ID 		in NUMBER,
  X_LINE_NUM 		in NUMBER,
  X_PROJECT_ORG_ID 	in NUMBER,
  X_TASK_ORG_ID 	in NUMBER,
  X_PROJECT_TYPE 	in VARCHAR2,
  X_CLASS_CATEGORY 	in VARCHAR2,
  X_CLASS_CODE 		in VARCHAR2,
  X_SERVICE_TYPE 	in VARCHAR2,
  X_PROJECT_ID 		in NUMBER,
  X_TASK_ID 		in NUMBER,
  X_EXCLUDE_FLAG 	in VARCHAR2,
  X_BILLABLE_ONLY_FLAG 	in VARCHAR2,
  X_LINE_PERCENT 	in NUMBER
) is
  cursor c1 is select
      PROJECT_ORG_ID,
      TASK_ORG_ID,
      PROJECT_TYPE,
      CLASS_CATEGORY,
      CLASS_CODE,
      SERVICE_TYPE,
      PROJECT_ID,
      TASK_ID,
      EXCLUDE_FLAG,
      BILLABLE_ONLY_FLAG,
      LINE_PERCENT
    from PA_ALLOC_TARGET_LINES
    where RULE_ID = X_RULE_ID
    and LINE_NUM = X_LINE_NUM
    for update of RULE_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.PROJECT_ORG_ID = X_PROJECT_ORG_ID)
           OR ((tlinfo.PROJECT_ORG_ID is null)
               AND (X_PROJECT_ORG_ID is null)))
      AND ((tlinfo.TASK_ORG_ID = X_TASK_ORG_ID)
           OR ((tlinfo.TASK_ORG_ID is null)
               AND (X_TASK_ORG_ID is null)))
      AND ((tlinfo.PROJECT_TYPE = X_PROJECT_TYPE)
           OR ((tlinfo.PROJECT_TYPE is null)
               AND (X_PROJECT_TYPE is null)))
      AND ((tlinfo.CLASS_CATEGORY = X_CLASS_CATEGORY)
           OR ((tlinfo.CLASS_CATEGORY is null)
               AND (X_CLASS_CATEGORY is null)))
      AND ((tlinfo.CLASS_CODE = X_CLASS_CODE)
           OR ((tlinfo.CLASS_CODE is null)
               AND (X_CLASS_CODE is null)))
      AND ((tlinfo.SERVICE_TYPE = X_SERVICE_TYPE)
           OR ((tlinfo.SERVICE_TYPE is null)
               AND (X_SERVICE_TYPE is null)))
      AND ((tlinfo.PROJECT_ID = X_PROJECT_ID)
           OR ((tlinfo.PROJECT_ID is null)
               AND (X_PROJECT_ID is null)))
      AND ((tlinfo.TASK_ID = X_TASK_ID)
           OR ((tlinfo.TASK_ID is null)
               AND (X_TASK_ID is null)))
      AND (tlinfo.EXCLUDE_FLAG = X_EXCLUDE_FLAG)
      AND ((tlinfo.BILLABLE_ONLY_FLAG = X_BILLABLE_ONLY_FLAG)
           OR ((tlinfo.BILLABLE_ONLY_FLAG is null)
               AND (X_BILLABLE_ONLY_FLAG is null)))
      AND ((tlinfo.LINE_PERCENT = X_LINE_PERCENT)
           OR ((tlinfo.LINE_PERCENT is null)
               AND (X_LINE_PERCENT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID		in VARCHAR2,
  X_RULE_ID 		in NUMBER,
  X_LINE_NUM 		in NUMBER,
  X_PROJECT_ORG_ID 	in NUMBER,
  X_TASK_ORG_ID 	in NUMBER,
  X_PROJECT_TYPE 	in VARCHAR2,
  X_CLASS_CATEGORY 	in VARCHAR2,
  X_CLASS_CODE 		in VARCHAR2,
  X_SERVICE_TYPE 	in VARCHAR2,
  X_PROJECT_ID 		in NUMBER,
  X_TASK_ID 		in NUMBER,
  X_EXCLUDE_FLAG 	in VARCHAR2,
  X_BILLABLE_ONLY_FLAG 	in VARCHAR2,
  X_LINE_PERCENT 	in NUMBER,
  X_LAST_UPDATE_DATE 	in DATE,
  X_LAST_UPDATED_BY 	in NUMBER,
  X_LAST_UPDATE_LOGIN 	in NUMBER
  ) is

begin

  update PA_ALLOC_TARGET_LINES set
    LINE_NUM = X_LINE_NUM,
    PROJECT_ORG_ID = X_PROJECT_ORG_ID,
    TASK_ORG_ID = X_TASK_ORG_ID,
    PROJECT_TYPE = X_PROJECT_TYPE,
    CLASS_CATEGORY = X_CLASS_CATEGORY,
    CLASS_CODE = X_CLASS_CODE,
    SERVICE_TYPE = X_SERVICE_TYPE,
    PROJECT_ID = X_PROJECT_ID,
    TASK_ID = X_TASK_ID,
    EXCLUDE_FLAG = X_EXCLUDE_FLAG,
    BILLABLE_ONLY_FLAG = X_BILLABLE_ONLY_FLAG,
    LINE_PERCENT = X_LINE_PERCENT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
--RULE_ID = X_RULE_ID
--  and LINE_NUM = X_LINE_NUM

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (X_ROWID in VARCHAR2
  --X_RULE_ID in NUMBER,
  --X_LINE_NUM in NUMBER
) is
begin
  delete from PA_ALLOC_TARGET_LINES
  where ROWID = X_ROWID;
--RULE_ID = X_RULE_ID
--  and LINE_NUM = X_LINE_NUM;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end PA_ALLOC_TARGET_LINES_PKG;

/
