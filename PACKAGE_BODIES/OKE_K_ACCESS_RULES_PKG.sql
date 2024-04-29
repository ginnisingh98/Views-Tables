--------------------------------------------------------
--  DDL for Package Body OKE_K_ACCESS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_ACCESS_RULES_PKG" as
/* $Header: OKEKACRB.pls 120.1 2005/06/02 12:00:37 appldev  $ */
procedure INSERT_ROW (
  X_ROWID                   IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
  X_ACCESS_RULE_ID          IN OUT NOCOPY /* file.sql.39 change */    NUMBER,
  X_CREATION_DATE           in        DATE,
  X_CREATED_BY              in        NUMBER,
  X_LAST_UPDATE_DATE        in        DATE,
  X_LAST_UPDATED_BY         in        NUMBER,
  X_LAST_UPDATE_LOGIN       in        NUMBER,
  X_ROLE_ID                 in        NUMBER,
  X_SECURED_OBJECT_NAME     in        VARCHAR2,
  X_ATTRIBUTE_GROUP_TYPE    in        VARCHAR2,
  X_ATTRIBUTE_GROUP_CODE    in        VARCHAR2,
  X_ATTRIBUTE_CODE          in        VARCHAR2,
  X_ACCESS_LEVEL            in        VARCHAR2
) is
  cursor C is select ROWID from OKE_K_ACCESS_RULES
    where ACCESS_RULE_ID = X_ACCESS_RULE_ID
    ;
begin
  select OKE_K_ACCESS_RULES_S.nextval
  into   X_ACCESS_RULE_ID
  from   dual;

  insert into OKE_K_ACCESS_RULES (
    ACCESS_RULE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ROLE_ID,
    SECURED_OBJECT_NAME,
    ATTRIBUTE_GROUP_TYPE,
    ATTRIBUTE_GROUP_CODE,
    ATTRIBUTE_CODE,
    ACCESS_LEVEL
  ) values (
    X_ACCESS_RULE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ROLE_ID,
    X_SECURED_OBJECT_NAME,
    X_ATTRIBUTE_GROUP_TYPE,
    X_ATTRIBUTE_GROUP_CODE,
    X_ATTRIBUTE_CODE,
    X_ACCESS_LEVEL
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
  X_ACCESS_RULE_ID          in        NUMBER,
  X_ROLE_ID                 in        NUMBER,
  X_SECURED_OBJECT_NAME     in        VARCHAR2,
  X_ATTRIBUTE_GROUP_TYPE    in        VARCHAR2,
  X_ATTRIBUTE_GROUP_CODE    in        VARCHAR2,
  X_ATTRIBUTE_CODE          in        VARCHAR2,
  X_ACCESS_LEVEL            in        VARCHAR2
) is
  cursor c is select
      ROLE_ID,
      SECURED_OBJECT_NAME,
      ATTRIBUTE_GROUP_TYPE,
      ATTRIBUTE_GROUP_CODE,
      ATTRIBUTE_CODE,
      ACCESS_LEVEL
    from OKE_K_ACCESS_RULES
    where ACCESS_RULE_ID = X_ACCESS_RULE_ID
    for update of ACCESS_RULE_ID nowait;
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
  if (    (recinfo.ROLE_ID = X_ROLE_ID)
      AND (recinfo.SECURED_OBJECT_NAME = X_SECURED_OBJECT_NAME)
      AND (recinfo.ACCESS_LEVEL = X_ACCESS_LEVEL)
      AND ((recinfo.ATTRIBUTE_GROUP_TYPE = X_ATTRIBUTE_GROUP_TYPE)
           OR ((recinfo.ATTRIBUTE_GROUP_TYPE is null) AND (X_ATTRIBUTE_GROUP_TYPE is null)))
      AND ((recinfo.ATTRIBUTE_GROUP_CODE = X_ATTRIBUTE_GROUP_CODE)
           OR ((recinfo.ATTRIBUTE_GROUP_CODE is null) AND (X_ATTRIBUTE_GROUP_CODE is null)))
      AND ((recinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
           OR ((recinfo.ATTRIBUTE_CODE is null) AND (X_ATTRIBUTE_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ACCESS_RULE_ID          in        NUMBER,
  X_LAST_UPDATE_DATE        in        DATE,
  X_LAST_UPDATED_BY         in        NUMBER,
  X_LAST_UPDATE_LOGIN       in        NUMBER,
  X_ROLE_ID                 in        NUMBER,
  X_SECURED_OBJECT_NAME     in        VARCHAR2,
  X_ATTRIBUTE_GROUP_TYPE    in        VARCHAR2,
  X_ATTRIBUTE_GROUP_CODE    in        VARCHAR2,
  X_ATTRIBUTE_CODE          in        VARCHAR2,
  X_ACCESS_LEVEL            in        VARCHAR2
) is
begin
  update OKE_K_ACCESS_RULES set
    LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN,
    ROLE_ID              = X_ROLE_ID,
    SECURED_OBJECT_NAME  = X_SECURED_OBJECT_NAME,
    ATTRIBUTE_GROUP_TYPE = X_ATTRIBUTE_GROUP_TYPE,
    ATTRIBUTE_GROUP_CODE = X_ATTRIBUTE_GROUP_CODE,
    ATTRIBUTE_CODE       = X_ATTRIBUTE_CODE,
    ACCESS_LEVEL         = X_ACCESS_LEVEL
  where ACCESS_RULE_ID = X_ACCESS_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACCESS_RULE_ID          in        NUMBER
) is
begin
  delete from OKE_K_ACCESS_RULES
  where ACCESS_RULE_ID = X_ACCESS_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure DELETE_ALL (
  X_ROLE_ID                 in        NUMBER
) is
begin
  delete from OKE_K_ACCESS_RULES
  where ROLE_ID = X_ROLE_ID;

  delete from OKE_COMPILED_ACCESS_RULES
  where ROLE_ID = X_ROLE_ID;

end DELETE_ALL;

end OKE_K_ACCESS_RULES_PKG;

/
