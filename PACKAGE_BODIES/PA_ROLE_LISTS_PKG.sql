--------------------------------------------------------
--  DDL for Package Body PA_ROLE_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_LISTS_PKG" as
/*$Header: PAROLSTB.pls 120.2 2005/08/22 02:50:56 raluthra noship $*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_ROLE_LIST_ID NUMBER,
  X_NAME VARCHAR2,
  X_START_DATE_ACTIVE DATE,
  X_END_DATE_ACTIVE DATE,
  X_DESCRIPTION VARCHAR2,
  X_ATTRIBUTE_CATEGORY VARCHAR2,
  X_ATTRIBUTE1 VARCHAR2,
  X_ATTRIBUTE2 VARCHAR2,
  X_ATTRIBUTE3 VARCHAR2,
  X_ATTRIBUTE4 VARCHAR2,
  X_ATTRIBUTE5 VARCHAR2,
  X_ATTRIBUTE6 VARCHAR2,
  X_ATTRIBUTE7 VARCHAR2,
  X_ATTRIBUTE8 VARCHAR2,
  X_ATTRIBUTE9 VARCHAR2,
  X_ATTRIBUTE10 VARCHAR2,
  X_ATTRIBUTE11 VARCHAR2,
  X_ATTRIBUTE12 VARCHAR2,
  X_ATTRIBUTE13 VARCHAR2,
  X_ATTRIBUTE14 VARCHAR2,
  X_ATTRIBUTE15 VARCHAR2,
  X_CREATION_DATE DATE,
  X_CREATED_BY NUMBER,
  X_LAST_UPDATE_DATE DATE,
  X_LAST_UPDATED_BY NUMBER,
  X_LAST_UPDATE_LOGin NUMBER
) is
  cursor C is select ROWID from PA_ROLE_LISTS
    where ROLE_LIST_ID = X_ROLE_LIST_ID
    ;

  l_rowid	ROWID; -- Bug 4565156. Added for Manual NOCOPY Fix.
begin
  l_rowid := X_ROWID; -- Bug 456156. Storing original value that was passed in.

  insert into PA_ROLE_LISTS (
    ROLE_LIST_ID,
    NAME,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    DESCRIPTION,
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
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RECORD_VERSION_NUMBER
  )VALUES (
    X_ROLE_LIST_ID,
    X_NAME,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_DESCRIPTION,
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
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    1
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    X_ROWID := l_rowid; -- Bug 4565156. Resetting to original value since NO_DATA_FOUND Exception.
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;


procedure LOCK_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_RECORD_VERSION_NUMBER NUMBER
) is
  cursor c is
    select *
    from PA_ROLE_LISTS
    where ROWID = X_ROWID
    for update of ROLE_LIST_ID nowait;

    tlinfo c%rowtype;
begin
    Open c;
    Fetch c into tlinfo;
    if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
    end if;
    close c;

    if ((tlinfo.RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER)
	OR ((tlinfo.RECORD_VERSION_NUMBER is null)
	    AND (X_RECORD_VERSION_NUMBER is null))
    ) then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_ROLE_LIST_ID NUMBER,
  X_NAME VARCHAR2,
  X_START_DATE_ACTIVE DATE,
  X_END_DATE_ACTIVE DATE,
  X_DESCRIPTION VARCHAR2,
  X_ATTRIBUTE_CATEGORY VARCHAR2,
  X_ATTRIBUTE1 VARCHAR2,
  X_ATTRIBUTE2 VARCHAR2,
  X_ATTRIBUTE3 VARCHAR2,
  X_ATTRIBUTE4 VARCHAR2,
  X_ATTRIBUTE5 VARCHAR2,
  X_ATTRIBUTE6 VARCHAR2,
  X_ATTRIBUTE7 VARCHAR2,
  X_ATTRIBUTE8 VARCHAR2,
  X_ATTRIBUTE9 VARCHAR2,
  X_ATTRIBUTE10 VARCHAR2,
  X_ATTRIBUTE11 VARCHAR2,
  X_ATTRIBUTE12 VARCHAR2,
  X_ATTRIBUTE13 VARCHAR2,
  X_ATTRIBUTE14 VARCHAR2,
  X_ATTRIBUTE15 VARCHAR2,
  X_CREATION_DATE DATE,
  X_CREATED_BY NUMBER,
  X_LAST_UPDATE_DATE DATE,
  X_LAST_UPDATED_BY NUMBER,
  X_LAST_UPDATE_LOGIN NUMBER
) is
begin
  update PA_ROLE_LISTS set
    ROLE_LIST_ID = X_ROLE_LIST_ID,
    NAME = X_NAME,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    DESCRIPTION = X_DESCRIPTION,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
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
    CREATION_DATE = X_CREATION_DATE,
    CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    RECORD_VERSION_NUMBER = RECORD_VERSION_NUMBER + 1
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_ROWID VARCHAR2
) is
begin
  delete from PA_ROLE_LISTS
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PA_ROLE_LISTS_PKG;

/