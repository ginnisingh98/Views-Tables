--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_MEMBERS_AUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_MEMBERS_AUD_PKG" as
/* $Header: jtfrstfb.pls 120.0 2005/05/11 08:22:11 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_MEMBER_AUDIT_ID in NUMBER,
  X_GROUP_MEMBER_ID in NUMBER,
  X_NEW_GROUP_ID in NUMBER,
  X_OLD_GROUP_ID in NUMBER,
  X_NEW_RESOURCE_ID in NUMBER,
  X_OLD_RESOURCE_ID in NUMBER,
  X_NEW_PERSON_ID in NUMBER,
  X_OLD_PERSON_ID in NUMBER,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_GROUP_MEMBERS_AUD
    where GROUP_MEMBER_AUDIT_ID = X_GROUP_MEMBER_AUDIT_ID
    ;
begin
  insert into JTF_RS_GROUP_MEMBERS_AUD (
    GROUP_MEMBER_AUDIT_ID,
    GROUP_MEMBER_ID,
    NEW_GROUP_ID,
    OLD_GROUP_ID,
    NEW_RESOURCE_ID,
    OLD_RESOURCE_ID,
    NEW_PERSON_ID,
    OLD_PERSON_ID,
    NEW_OBJECT_VERSION_NUMBER,
    OLD_OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) values (
    X_GROUP_MEMBER_AUDIT_ID,
    X_GROUP_MEMBER_ID,
    X_NEW_GROUP_ID,
    X_OLD_GROUP_ID,
    X_NEW_RESOURCE_ID,
    X_OLD_RESOURCE_ID,
    X_NEW_PERSON_ID,
    X_OLD_PERSON_ID,
    X_NEW_OBJECT_VERSION_NUMBER,
    X_OLD_OBJECT_VERSION_NUMBER,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_GROUP_MEMBER_AUDIT_ID in NUMBER,
  X_GROUP_MEMBER_ID in NUMBER,
  X_NEW_GROUP_ID in NUMBER,
  X_OLD_GROUP_ID in NUMBER,
  X_NEW_RESOURCE_ID in NUMBER,
  X_OLD_RESOURCE_ID in NUMBER,
  X_NEW_PERSON_ID in NUMBER,
  X_OLD_PERSON_ID in NUMBER,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
      GROUP_MEMBER_ID,
      NEW_GROUP_ID,
      OLD_GROUP_ID,
      NEW_RESOURCE_ID,
      OLD_RESOURCE_ID,
      NEW_PERSON_ID,
      OLD_PERSON_ID,
      NEW_OBJECT_VERSION_NUMBER,
      OLD_OBJECT_VERSION_NUMBER
    from JTF_RS_GROUP_MEMBERS_AUD
    where GROUP_MEMBER_AUDIT_ID = X_GROUP_MEMBER_AUDIT_ID
    for update of GROUP_MEMBER_AUDIT_ID nowait;
tlinfo c1%rowtype;
begin
 open c1;
   fetch c1 into tlinfo;
        if (c1%notfound) then
                   fnd_message.set_name('FND','FORM_RECORD_DELETED');
                 app_exception.raise_exception;
            close c1;
         end if;
   close c1;

      if (    (tlinfo.GROUP_MEMBER_ID = X_GROUP_MEMBER_ID)
          AND ((tlinfo.NEW_GROUP_ID = X_NEW_GROUP_ID)
               OR ((tlinfo.NEW_GROUP_ID is null) AND (X_NEW_GROUP_ID is null)))
          AND ((tlinfo.OLD_GROUP_ID = X_OLD_GROUP_ID)
               OR ((tlinfo.OLD_GROUP_ID is null) AND (X_OLD_GROUP_ID is null)))
          AND ((tlinfo.NEW_RESOURCE_ID = X_NEW_RESOURCE_ID)
               OR ((tlinfo.NEW_RESOURCE_ID is null) AND (X_NEW_RESOURCE_ID is null)))
          AND ((tlinfo.OLD_RESOURCE_ID = X_OLD_RESOURCE_ID)
               OR ((tlinfo.OLD_RESOURCE_ID is null) AND (X_OLD_RESOURCE_ID is null)))
          AND ((tlinfo.NEW_PERSON_ID = X_NEW_PERSON_ID)
               OR ((tlinfo.NEW_PERSON_ID is null) AND (X_NEW_PERSON_ID is null)))
          AND ((tlinfo.OLD_PERSON_ID = X_OLD_PERSON_ID)
               OR ((tlinfo.OLD_PERSON_ID is null) AND (X_OLD_PERSON_ID is null)))
          AND ((tlinfo.NEW_OBJECT_VERSION_NUMBER = X_NEW_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.NEW_OBJECT_VERSION_NUMBER is null) AND (X_NEW_OBJECT_VERSION_NUMBER is null)))
          AND ((tlinfo.OLD_OBJECT_VERSION_NUMBER = X_OLD_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OLD_OBJECT_VERSION_NUMBER is null) AND (X_OLD_OBJECT_VERSION_NUMBER is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_GROUP_MEMBER_AUDIT_ID in NUMBER,
  X_GROUP_MEMBER_ID in NUMBER,
  X_NEW_GROUP_ID in NUMBER,
  X_OLD_GROUP_ID in NUMBER,
  X_NEW_RESOURCE_ID in NUMBER,
  X_OLD_RESOURCE_ID in NUMBER,
  X_NEW_PERSON_ID in NUMBER,
  X_OLD_PERSON_ID in NUMBER,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_GROUP_MEMBERS_AUD set
    GROUP_MEMBER_ID = X_GROUP_MEMBER_ID,
    NEW_GROUP_ID = X_NEW_GROUP_ID,
    OLD_GROUP_ID = X_OLD_GROUP_ID,
    NEW_RESOURCE_ID = X_NEW_RESOURCE_ID,
    OLD_RESOURCE_ID = X_OLD_RESOURCE_ID,
    NEW_PERSON_ID = X_NEW_PERSON_ID,
    OLD_PERSON_ID = X_OLD_PERSON_ID,
    NEW_OBJECT_VERSION_NUMBER = X_NEW_OBJECT_VERSION_NUMBER,
    OLD_OBJECT_VERSION_NUMBER = X_OLD_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GROUP_MEMBER_AUDIT_ID = X_GROUP_MEMBER_AUDIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GROUP_MEMBER_AUDIT_ID in NUMBER
) is
begin
  delete from JTF_RS_GROUP_MEMBERS_AUD
  where GROUP_MEMBER_AUDIT_ID = X_GROUP_MEMBER_AUDIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end JTF_RS_GROUP_MEMBERS_AUD_PKG;

/
