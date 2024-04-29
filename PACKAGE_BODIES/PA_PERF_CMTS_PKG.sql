--------------------------------------------------------
--  DDL for Package Body PA_PERF_CMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_CMTS_PKG" as
/* $Header: PAPEECTB.pls 120.1 2005/08/19 16:38:25 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_COMMENT_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_COMMENT_TEXT in VARCHAR2,
  X_COMMENTED_BY in NUMBER,
  X_COMMENT_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_PERF_COMMENTS
    where COMMENT_ID = X_COMMENT_ID
    ;
begin
  insert into PA_PERF_COMMENTS (
    COMMENT_ID,
    PERF_TXN_ID,
    COMMENT_TEXT,
    COMMENTED_BY,
    COMMENT_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN )
  values (
    X_COMMENT_ID,
    X_PERF_TXN_ID,
    X_COMMENT_TEXT,
    X_COMMENTED_BY,
    X_COMMENT_DATE,
    NVL(X_CREATION_DATE,sysdate),
    NVL(X_CREATED_BY,fnd_global.user_id),
    NVL(X_LAST_UPDATE_DATE,sysdate),
    NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id));

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


procedure UPDATE_ROW (
  X_COMMENT_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_COMMENT_TEXT in VARCHAR2,
  X_COMMENTED_BY in NUMBER,
  X_COMMENT_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_PERF_COMMENTS set
    PERF_TXN_ID = X_PERF_TXN_ID,
    COMMENT_TEXT = X_COMMENT_TEXT,
    COMMENTED_BY = X_COMMENTED_BY,
    COMMENT_DATE = X_COMMENT_DATE,
    COMMENT_ID = X_COMMENT_ID,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,sysdate),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id)
  where COMMENT_ID = X_COMMENT_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COMMENT_ID in NUMBER
) is
begin
  delete from PA_PERF_COMMENTS
  where COMMENT_ID = X_COMMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end PA_PERF_CMTS_PKG;


/
