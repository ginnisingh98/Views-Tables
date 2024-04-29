--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_RESOURCES_PKG" AS
 /* $Header: PAXATRSB.pls 120.2 2005/08/19 16:18:57 ramurthy noship $  */
procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2,
  X_RULE_ID 			in NUMBER,
  X_MEMBER_TYPE 		in VARCHAR2,
  X_RESOURCE_LIST_MEMBER_ID 	in NUMBER,
  X_EXCLUDE_FLAG 		in VARCHAR2,
  X_TARGET_EXPND_TYPE 		in VARCHAR2,
  X_OFFSET_EXPND_TYPE 		in VARCHAR2,
  X_RESOURCE_PERCENTAGE 	in NUMBER,
  X_CREATED_BY			in NUMBER,
  X_CREATION_DATE		in DATE,
  X_LAST_UPDATE_DATE		in DATE,
  X_LAST_UPDATED_BY		in NUMBER,
  X_LAST_UPDATE_LOGIN		in NUMBER
  ) is
    cursor C is select ROWID from PA_ALLOC_RESOURCES
      where RULE_ID = X_RULE_ID
      and MEMBER_TYPE = X_MEMBER_TYPE
      and RESOURCE_LIST_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID;

begin

  insert into PA_ALLOC_RESOURCES (
    RULE_ID,
    MEMBER_TYPE,
    RESOURCE_LIST_MEMBER_ID,
    EXCLUDE_FLAG,
    TARGET_EXPND_TYPE,
    OFFSET_EXPND_TYPE,
    RESOURCE_PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RULE_ID,
    X_MEMBER_TYPE,
    X_RESOURCE_LIST_MEMBER_ID,
    X_EXCLUDE_FLAG,
    X_TARGET_EXPND_TYPE,
    X_OFFSET_EXPND_TYPE,
    X_RESOURCE_PERCENTAGE,
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
  X_RULE_ID 			in NUMBER,
  X_MEMBER_TYPE 		in VARCHAR2,
  X_RESOURCE_LIST_MEMBER_ID 	in NUMBER,
  X_EXCLUDE_FLAG 		in VARCHAR2,
  X_TARGET_EXPND_TYPE 		in VARCHAR2,
  X_OFFSET_EXPND_TYPE 		in VARCHAR2,
  X_RESOURCE_PERCENTAGE 	in NUMBER
) is
  cursor c1 is select
      EXCLUDE_FLAG,
      TARGET_EXPND_TYPE,
      OFFSET_EXPND_TYPE,
      RESOURCE_PERCENTAGE
    from PA_ALLOC_RESOURCES
    where RULE_ID = X_RULE_ID
    and MEMBER_TYPE = X_MEMBER_TYPE
    and RESOURCE_LIST_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID
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

  if ( (tlinfo.EXCLUDE_FLAG = X_EXCLUDE_FLAG)
      AND ((tlinfo.TARGET_EXPND_TYPE = X_TARGET_EXPND_TYPE)
           OR ((tlinfo.TARGET_EXPND_TYPE is null)
               AND (X_TARGET_EXPND_TYPE is null)))
      AND ((tlinfo.OFFSET_EXPND_TYPE = X_OFFSET_EXPND_TYPE)
           OR ((tlinfo.OFFSET_EXPND_TYPE is null)
               AND (X_OFFSET_EXPND_TYPE is null)))
      AND ((tlinfo.RESOURCE_PERCENTAGE = X_RESOURCE_PERCENTAGE)
           OR ((tlinfo.RESOURCE_PERCENTAGE is null)
               AND (X_RESOURCE_PERCENTAGE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID 			in varchar2,
  X_RULE_ID 			in NUMBER,
  X_MEMBER_TYPE 		in VARCHAR2,
  X_RESOURCE_LIST_MEMBER_ID 	in NUMBER,
  X_EXCLUDE_FLAG 		in VARCHAR2,
  X_TARGET_EXPND_TYPE 		in VARCHAR2,
  X_OFFSET_EXPND_TYPE 		in VARCHAR2,
  X_RESOURCE_PERCENTAGE 	in NUMBER,
  X_LAST_UPDATE_DATE		in DATE,
  X_LAST_UPDATED_BY		in NUMBER,
  X_LAST_UPDATE_LOGIN		in NUMBER
  )
is

begin

  update PA_ALLOC_RESOURCES set
    RESOURCE_LIST_MEMBER_ID = X_RESOURCE_LIST_MEMBER_ID,
    EXCLUDE_FLAG = X_EXCLUDE_FLAG,
    TARGET_EXPND_TYPE = X_TARGET_EXPND_TYPE,
    OFFSET_EXPND_TYPE = X_OFFSET_EXPND_TYPE,
    RESOURCE_PERCENTAGE = X_RESOURCE_PERCENTAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (X_ROWID in varchar2
) is
begin
  delete from PA_ALLOC_RESOURCES
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PA_ALLOC_RESOURCES_PKG;

/
