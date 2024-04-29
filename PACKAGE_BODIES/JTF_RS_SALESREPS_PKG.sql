--------------------------------------------------------
--  DDL for Package Body JTF_RS_SALESREPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SALESREPS_PKG" as
/* $Header: jtfrstsb.pls 120.1 2005/06/23 22:46:47 baianand ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SALESREP_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_SALES_CREDIT_TYPE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ORG_ID in NUMBER,
  X_GL_ID_REV in NUMBER,
  X_GL_ID_FREIGHT in NUMBER,
  X_GL_ID_REC in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_SALESREP_NUMBER in VARCHAR2,
  X_EMAIL_ADDRESS in VARCHAR2,
  X_WH_UPDATE_DATE in DATE,
  X_PERSON_ID in NUMBER,
  X_SALES_TAX_GEOCODE in VARCHAR2,
  X_SALES_TAX_INSIDE_CITY_LIMITS in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_SALESREPS
    where SALESREP_ID = X_SALESREP_ID
    ;
begin

  --dbms_output.put_line ('Inside Table Handler');

  insert into JTF_RS_SALESREPS (
    SALESREP_ID,
    RESOURCE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SALES_CREDIT_TYPE_ID,
    NAME,
    STATUS,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ORG_ID,
    GL_ID_REV,
    GL_ID_FREIGHT,
    GL_ID_REC,
    SET_OF_BOOKS_ID,
    SALESREP_NUMBER,
    EMAIL_ADDRESS,
    WH_UPDATE_DATE,
    PERSON_ID,
    SALES_TAX_GEOCODE,
    SALES_TAX_INSIDE_CITY_LIMITS,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15
  ) values (
    X_SALESREP_ID,
    X_RESOURCE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SALES_CREDIT_TYPE_ID,
    X_NAME,
    X_STATUS,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ORG_ID,
    X_GL_ID_REV,
    X_GL_ID_FREIGHT,
    X_GL_ID_REC,
    X_SET_OF_BOOKS_ID,
    X_SALESREP_NUMBER,
    X_EMAIL_ADDRESS,
    X_WH_UPDATE_DATE,
    X_PERSON_ID,
    X_SALES_TAX_GEOCODE,
    X_SALES_TAX_INSIDE_CITY_LIMITS,
    1,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15);

--dbms_output.put_line ('After insert through Table Handler');

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_SALESREP_ID in NUMBER,
  X_ORG_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER
    from JTF_RS_SALESREPS
    where SALESREP_ID = X_SALESREP_ID
    and   NVL(ORG_ID,-99) = NVL(X_ORG_ID,-99)
    for update of SALESREP_ID nowait;
    tlinfo c1%rowtype ;
begin
        open c1;
        fetch c1 into tlinfo;
        if (c1%notfound) then
                close c1;
                fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
            app_exception.raise_exception;
         end if;
         close c1;

  if (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_SALESREP_ID in NUMBER,
  X_RESOURCE_ID in NUMBER,
  X_SALES_CREDIT_TYPE_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_GL_ID_REV in NUMBER,
  X_GL_ID_FREIGHT in NUMBER,
  X_GL_ID_REC in NUMBER,
  X_SET_OF_BOOKS_ID in NUMBER,
  X_SALESREP_NUMBER in VARCHAR2,
  X_EMAIL_ADDRESS in VARCHAR2,
  X_WH_UPDATE_DATE in DATE,
  X_PERSON_ID in NUMBER,
  X_SALES_TAX_GEOCODE in VARCHAR2,
  X_SALES_TAX_INSIDE_CITY_LIMITS in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_SALESREPS set
    RESOURCE_ID = X_RESOURCE_ID,
    SALES_CREDIT_TYPE_ID = X_SALES_CREDIT_TYPE_ID,
    NAME = X_NAME,
    STATUS = X_STATUS,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    GL_ID_REV = X_GL_ID_REV,
    GL_ID_FREIGHT = X_GL_ID_FREIGHT,
    GL_ID_REC = X_GL_ID_REC,
    SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID,
    SALESREP_NUMBER = X_SALESREP_NUMBER,
    EMAIL_ADDRESS = X_EMAIL_ADDRESS,
    WH_UPDATE_DATE = X_WH_UPDATE_DATE,
    PERSON_ID = X_PERSON_ID,
    SALES_TAX_GEOCODE = X_SALES_TAX_GEOCODE,
    SALES_TAX_INSIDE_CITY_LIMITS = X_SALES_TAX_INSIDE_CITY_LIMITS,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SALESREP_ID = X_SALESREP_ID
  and   NVL(ORG_ID,-99) = NVL(X_ORG_ID,-99);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SALESREP_ID in NUMBER,
  X_ORG_ID in NUMBER
) is
begin
  delete from JTF_RS_SALESREPS
  where SALESREP_ID = X_SALESREP_ID
  and   NVL(ORG_ID,-99) = NVL(X_ORG_ID,-99);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end JTF_RS_SALESREPS_PKG;

/
