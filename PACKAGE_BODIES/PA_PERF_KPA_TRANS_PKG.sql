--------------------------------------------------------
--  DDL for Package Body PA_PERF_KPA_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_KPA_TRANS_PKG" as
/* $Header: PAPEKPTB.pls 120.1 2005/08/19 16:38:52 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_KPA_SUMMARY_DET_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_CREATION_DATE in DATE ,
  X_CREATED_BY in NUMBER ,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_PERF_KPA_TRANS
    where KPA_SUMMARY_DET_ID = X_KPA_SUMMARY_DET_ID
    and PERF_TXN_ID = X_PERF_TXN_ID
    ;
begin
  insert into PA_PERF_KPA_TRANS (
    KPA_SUMMARY_DET_ID,
    PERF_TXN_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN )
  values (
    X_KPA_SUMMARY_DET_ID,
    X_PERF_TXN_ID,
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
  X_KPA_SUMMARY_DET_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE  ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_PERF_KPA_TRANS set
    KPA_SUMMARY_DET_ID = X_KPA_SUMMARY_DET_ID,
    PERF_TXN_ID = X_PERF_TXN_ID,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,sysdate),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id)
  where KPA_SUMMARY_DET_ID = X_KPA_SUMMARY_DET_ID
  and PERF_TXN_ID = X_PERF_TXN_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_KPA_SUMMARY_DET_ID in NUMBER,
  X_PERF_TXN_ID in NUMBER
) is
begin
  delete from PA_PERF_KPA_TRANS
  where KPA_SUMMARY_DET_ID = X_KPA_SUMMARY_DET_ID
  and PERF_TXN_ID  = X_PERF_TXN_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end PA_PERF_KPA_TRANS_PKG;

/
