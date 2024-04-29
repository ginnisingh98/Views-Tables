--------------------------------------------------------
--  DDL for Package Body PA_PERF_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_TRANSACTIONS_PKG" as
/* $Header: PAPEEXTB.pls 120.1 2005/08/19 16:38:45 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_PERF_TXN_ID in NUMBER,
  X_PERF_TXN_OBJ_TYPE in VARCHAR2,
  X_PERF_TXN_OBJ_ID in NUMBER,
  X_OBJECT_RULE_ID in NUMBER,
  X_RELATED_OBJ_TYPE in VARCHAR2,
  X_RELATED_OBJ_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_KPA_CODE in VARCHAR2,
  X_MEASURE_ID in NUMBER,
  X_MEASURE_VALUE in NUMBER,
  X_PERIOD_NAME in VARCHAR2,
  X_INDICATOR_CODE in VARCHAR2,
  X_THRESHOLD_FROM in NUMBER,
  X_THRESHOLD_TO in NUMBER,
  X_WEIGHTING in NUMBER,
  X_PRECISION in NUMBER,
  X_PERIOD_TYPE in VARCHAR2,
  X_CURRENCY_TYPE in VARCHAR2,
  X_MEASURE_FORMAT in VARCHAR2,
  X_PROGRAM_ID in NUMBER,
  X_DATE_CHECKED in DATE,
  X_EXCEPTION_FLAG in VARCHAR2,
  X_CURRENT_FLAG in VARCHAR2,
  X_INCLUDED_IN_SCORING in VARCHAR2,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE ,
  X_CREATED_BY in NUMBER ,
  X_LAST_UPDATE_DATE in DATE ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_PERF_TRANSACTIONS
    where PERF_TXN_ID = X_PERF_TXN_ID
    ;
begin
  insert into PA_PERF_TRANSACTIONS (
    PERF_TXN_ID,
    PERF_TXN_OBJ_TYPE,
    PERF_TXN_OBJ_ID,
    OBJECT_RULE_ID,
    RELATED_OBJ_TYPE,
    RELATED_OBJ_ID,
    RULE_ID,
    PROJECT_ID,
    KPA_CODE,
    MEASURE_ID,
    MEASURE_VALUE,
    PERIOD_NAME,
    INDICATOR_CODE,
    THRESHOLD_FROM,
    THRESHOLD_TO,
    WEIGHTING,
    PRECISION,
    PERIOD_TYPE,
    CURRENCY_TYPE,
    MEASURE_FORMAT,
    PROGRAM_ID,
    DATE_CHECKED,
    EXCEPTION_FLAG,
    CURRENT_FLAG,
    INCLUDED_IN_SCORING,
    RECORD_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN )
  values (
    X_PERF_TXN_ID,
    X_PERF_TXN_OBJ_TYPE,
    X_PERF_TXN_OBJ_ID,
    X_OBJECT_RULE_ID,
    X_RELATED_OBJ_TYPE,
    X_RELATED_OBJ_ID,
    X_RULE_ID,
    X_PROJECT_ID,
    X_KPA_CODE,
    X_MEASURE_ID,
    X_MEASURE_VALUE,
    X_PERIOD_NAME,
    X_INDICATOR_CODE,
    X_THRESHOLD_FROM,
    X_THRESHOLD_TO,
    X_WEIGHTING,
    X_PRECISION,
    X_PERIOD_TYPE,
    X_CURRENCY_TYPE,
    X_MEASURE_FORMAT,
    X_PROGRAM_ID,
    X_DATE_CHECKED,
    X_EXCEPTION_FLAG,
    X_CURRENT_FLAG,
    X_INCLUDED_IN_SCORING,
    NVL(X_RECORD_VERSION_NUMBER,1),
    NVL(X_CREATION_DATE,sysdate),
    NVL(X_CREATED_BY,fnd_global.user_id),
    NVL(X_LAST_UPDATE_DATE,sysdate),
    NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id)
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
  X_PERF_TXN_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
 ) IS
Resource_Busy             EXCEPTION;
Invalid_Rec_Change        EXCEPTION;
PRAGMA exception_init(Resource_Busy,-00054);
l_rec_ver_no       NUMBER;
g_module_name      VARCHAR2(100) := 'pa.plsql.PA_PERF_TRANSACTIONS_PKG';
l_debug_mode       VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN


     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function   => 'PERF_TRANSACTIONS',
                                     p_debug_mode => l_debug_mode );
     END IF;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'X_PERF_TXN_ID = '|| X_PERF_TXN_ID;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'X_RECORD_VERSION_NUMBER = '|| X_RECORD_VERSION_NUMBER;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);

     END IF;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'in lock row method,about to execute query';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level3);
        pa_debug.reset_curr_function;
     END IF;

     select record_version_number into l_rec_ver_no
     from pa_perf_transactions
     where perf_txn_id = X_PERF_TXN_ID
     for update nowait;

     if(X_RECORD_VERSION_NUMBER <> l_rec_ver_no) then
           raise Invalid_Rec_Change;
     end if;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'in lock row method,query executed';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level3);
        pa_debug.reset_curr_function;
     END IF;
EXCEPTION
     when NO_DATA_FOUND then
        PA_UTILS.ADD_MESSAGE
        ( p_app_short_name => 'PA',
          p_msg_name       => 'FND_RECORD_DELETED_ERROR');
        rollback to sp;

      when Invalid_Rec_Change then
         PA_UTILS.ADD_MESSAGE
         ( p_app_short_name => 'PA',
           p_msg_name       => 'FND_RECORD_CHANGED_ERROR');
         rollback to sp;

      when Resource_Busy then
         PA_UTILS.ADD_MESSAGE
         ( p_app_short_name => 'PA',
           p_msg_name       => 'FND_LOCK_RECORD_ERROR');
         rollback to sp;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_PERF_TXN_ID in NUMBER,
  X_PERF_TXN_OBJ_TYPE in VARCHAR2,
  X_PERF_TXN_OBJ_ID in NUMBER,
  X_OBJECT_RULE_ID in NUMBER,
  X_RELATED_OBJ_TYPE in VARCHAR2,
  X_RELATED_OBJ_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_KPA_CODE in VARCHAR2,
  X_MEASURE_ID in NUMBER,
  X_MEASURE_VALUE in NUMBER,
  X_PERIOD_NAME in VARCHAR2,
  X_INDICATOR_CODE in VARCHAR2,
  X_THRESHOLD_FROM in NUMBER,
  X_THRESHOLD_TO in NUMBER,
  X_WEIGHTING in NUMBER,
  X_PRECISION in NUMBER,
  X_PERIOD_TYPE in VARCHAR2,
  X_CURRENCY_TYPE in VARCHAR2,
  X_MEASURE_FORMAT in VARCHAR2,
  X_PROGRAM_ID in NUMBER,
  X_DATE_CHECKED in DATE,
  X_EXCEPTION_FLAG in VARCHAR2,
  X_CURRENT_FLAG in VARCHAR2,
  X_INCLUDED_IN_SCORING in VARCHAR2,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE  ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_PERF_TRANSACTIONS set
    PERF_TXN_ID = X_PERF_TXN_ID,
    PERF_TXN_OBJ_TYPE = X_PERF_TXN_OBJ_TYPE,
    PERF_TXN_OBJ_ID = X_PERF_TXN_OBJ_ID,
    OBJECT_RULE_ID = X_OBJECT_RULE_ID,
    RELATED_OBJ_TYPE = X_RELATED_OBJ_TYPE,
    RELATED_OBJ_ID = X_RELATED_OBJ_ID,
    RULE_ID = X_RULE_ID,
    PROJECT_ID = X_PROJECT_ID,
    KPA_CODE = X_KPA_CODE,
    MEASURE_ID = X_MEASURE_ID,
    MEASURE_VALUE = X_MEASURE_VALUE,
    PERIOD_NAME = X_PERIOD_NAME,
    INDICATOR_CODE = X_INDICATOR_CODE,
    THRESHOLD_FROM = X_THRESHOLD_FROM,
    THRESHOLD_TO = X_THRESHOLD_TO,
    WEIGHTING = X_WEIGHTING,
    PRECISION = X_PRECISION,
    PERIOD_TYPE = X_PERIOD_TYPE,
    CURRENCY_TYPE = X_CURRENCY_TYPE,
    MEASURE_FORMAT = X_MEASURE_FORMAT,
    PROGRAM_ID = X_PROGRAM_ID,
    DATE_CHECKED = X_DATE_CHECKED,
    EXCEPTION_FLAG = X_EXCEPTION_FLAG,
    CURRENT_FLAG = X_CURRENT_FLAG,
    INCLUDED_IN_SCORING = X_INCLUDED_IN_SCORING,
    RECORD_VERSION_NUMBER = NVL(X_RECORD_VERSION_NUMBER,RECORD_VERSION_NUMBER+1),
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,sysdate),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id)
  where PERF_TXN_ID = X_PERF_TXN_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERF_TXN_ID in NUMBER
) is
begin
  delete from PA_PERF_TRANSACTIONS
  where PERF_TXN_ID = X_PERF_TXN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end PA_PERF_TRANSACTIONS_PKG;

/
