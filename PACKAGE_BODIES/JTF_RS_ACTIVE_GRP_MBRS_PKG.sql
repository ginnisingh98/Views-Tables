--------------------------------------------------------
--  DDL for Package Body JTF_RS_ACTIVE_GRP_MBRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ACTIVE_GRP_MBRS_PKG" as
/* $Header: jtfrshab.pls 120.0 2005/05/11 08:20:05 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GROUP_MEMBER_ID in NUMBER,
  X_GROUP_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_ACTIVE_GRP_MBRS
    where GROUP_MEMBER_ID = X_GROUP_MEMBER_ID
    ;
begin
  insert into JTF_RS_ACTIVE_GRP_MBRS (
    OBJECT_VERSION_NUMBER,
    GROUP_MEMBER_ID,
    GROUP_ID,
    RESOURCE_ID,
    PERSON_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    1,
    X_GROUP_MEMBER_ID,
    X_GROUP_ID,
    X_RESOURCE_ID,
    X_PERSON_ID,
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
  X_GROUP_MEMBER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      GROUP_MEMBER_ID
    from JTF_RS_ACTIVE_GRP_MBRS
    where GROUP_MEMBER_ID = X_GROUP_MEMBER_ID
    for update of GROUP_MEMBER_ID nowait;
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
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.GROUP_MEMBER_ID = X_GROUP_MEMBER_ID))
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_GROUP_MEMBER_ID in NUMBER,
  X_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_ACTIVE_GRP_MBRS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    GROUP_MEMBER_ID = X_GROUP_MEMBER_ID,
    RESOURCE_ID = X_RESOURCE_ID,
    PERSON_ID = X_PERSON_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GROUP_MEMBER_ID = X_GROUP_MEMBER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_GROUP_MEMBER_ID in NUMBER
) is
begin
  delete from JTF_RS_ACTIVE_GRP_MBRS
  where GROUP_MEMBER_ID = X_GROUP_MEMBER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end JTF_RS_ACTIVE_GRP_MBRS_PKG;

/
