--------------------------------------------------------
--  DDL for Package Body PA_PERF_BZ_MEASURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_BZ_MEASURES_PKG" as
/* $Header: PAPEBZTB.pls 120.1 2005/08/19 16:38:09 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_MEASURE_ID in NUMBER,
  X_BZ_EVENT_CODE in VARCHAR2,
  X_CREATION_DATE in DATE ,
  X_CREATED_BY in NUMBER ,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_PERF_BZ_MEASURES
    where MEASURE_ID = X_MEASURE_ID
    ;
begin
  insert into PA_PERF_BZ_MEASURES (
    MEASURE_ID,
    BZ_EVENT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN)
  values (
    X_MEASURE_ID,
    X_BZ_EVENT_CODE,
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
  X_MEASURE_ID in NUMBER,
  X_BZ_EVENT_CODE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_PERF_BZ_MEASURES set
    BZ_EVENT_CODE = X_BZ_EVENT_CODE,
    MEASURE_ID = X_MEASURE_ID,
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,sysdate),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id)
  where MEASURE_ID = X_MEASURE_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MEASURE_ID in NUMBER
) is
begin
  delete from PA_PERF_BZ_MEASURES
  where MEASURE_ID = X_MEASURE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end PA_PERF_BZ_MEASURES_PKG;

/
