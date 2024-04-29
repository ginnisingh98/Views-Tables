--------------------------------------------------------
--  DDL for Package Body PA_ROLE_LIST_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_LIST_MEMBERS_PKG" as
/*$Header: PARLMBRB.pls 120.2 2005/08/22 02:09:56 raluthra noship $*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_ROLE_LIST_ID NUMBER,
  X_PROJECT_ROLE_ID NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY NUMBER,
  X_LAST_UPDATE_DATE DATE,
  X_LAST_UPDATED_BY NUMBER,
  X_LAST_UPDATE_LOGIN NUMBER
) is
  cursor C is select ROWID from PA_ROLE_LIST_MEMBERS
    where ROLE_LIST_ID = X_ROLE_LIST_ID
    AND PROJECT_ROLE_ID = X_PROJECT_ROLE_ID
  ;
  l_rowid	ROWID; -- Bug 4565156. Added for Manual NOCOPY Fix.
begin
  l_rowid := X_ROWID; -- Bug 4565156. Storing original value. Added for Manual NOCOPY Fix.

  insert into PA_ROLE_LIST_MEMBERS (
    ROLE_LIST_ID,
    PROJECT_ROLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    RECORD_VERSION_NUMBER
  )VALUES (
    X_ROLE_LIST_ID,
    X_PROJECT_ROLE_ID,
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
    X_ROWID := l_rowid; -- Bug 4565156. Resetting to original value. For Manual NOCOPY Fix.
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
    from PA_ROLE_LIST_MEMBERS
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
      return;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_ROLE_LIST_ID NUMBER,
  X_PROJECT_ROLE_ID NUMBER,
  X_CREATION_DATE DATE,
  X_CREATED_BY NUMBER,
  X_LAST_UPDATE_DATE DATE,
  X_LAST_UPDATED_BY NUMBER,
  X_LAST_UPDATE_LOGIN NUMBER
) is
begin
  update PA_ROLE_LIST_MEMBERS set
    ROLE_LIST_ID = X_ROLE_LIST_ID,
    PROJECT_ROLE_ID = X_PROJECT_ROLE_ID,
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
  delete from PA_ROLE_LIST_MEMBERS
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end PA_ROLE_LIST_MEMBERS_PKG;

/
