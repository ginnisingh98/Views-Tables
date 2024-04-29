--------------------------------------------------------
--  DDL for Package Body PA_PERF_THRESHOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_THRESHOLDS_PKG" as
/* $Header: PAPETHTB.pls 120.1 2005/08/19 16:39:58 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_THRESHOLD_ID in NUMBER,
  X_RULE_TYPE in VARCHAR2,
  X_THRES_OBJ_ID in NUMBER,
  X_FROM_VALUE in NUMBER,
  X_TO_VALUE in NUMBER,
  X_INDICATOR_CODE in VARCHAR2,
  X_EXCEPTION_FLAG in VARCHAR2,
  X_WEIGHTING in NUMBER,
  X_ACCESS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER ,
  X_CREATION_DATE in DATE ,
  X_CREATED_BY in NUMBER ,
  X_LAST_UPDATE_DATE in DATE ,
  X_LAST_UPDATED_BY in NUMBER ,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_PERF_THRESHOLDS
    where THRESHOLD_ID = X_THRESHOLD_ID
    ;
begin
  insert into PA_PERF_THRESHOLDS (
    THRESHOLD_ID,
    RULE_TYPE,
    THRES_OBJ_ID,
    FROM_VALUE,
    TO_VALUE,
    INDICATOR_CODE,
    EXCEPTION_FLAG,
    WEIGHTING,
    ACCESS_LIST_ID,
    RECORD_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN )
  values (
    X_THRESHOLD_ID,
    X_RULE_TYPE,
    X_THRES_OBJ_ID,
    X_FROM_VALUE,
    X_TO_VALUE,
    X_INDICATOR_CODE,
    X_EXCEPTION_FLAG,
    X_WEIGHTING,
    X_ACCESS_LIST_ID,
    NVL(X_RECORD_VERSION_NUMBER,1),
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

procedure LOCK_ROW (
  X_THRESHOLD_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
 ) IS
Resource_Busy             EXCEPTION;
Invalid_Rec_Change        EXCEPTION;
PRAGMA exception_init(Resource_Busy,-00054);
l_rec_ver_no NUMBER;
g_module_name      VARCHAR2(100) := 'pa.plsql.PA_PERF_THRESHOLDS';
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function   => 'PERF_THRESHOLDS',
                                     p_debug_mode => l_debug_mode );
     END IF;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'X_THRESHOLD_ID = '|| X_THRESHOLD_ID;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'X_RECORD_VERSION_NUMBER = '|| X_RECORD_VERSION_NUMBER;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);

     END IF;

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'in lock row method,ABOUT TO EXECUTE QUERY';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,l_debug_level3);
        pa_debug.reset_curr_function;
     END IF;

     select record_version_number into l_rec_ver_no
     from pa_perf_thresholds
     where threshold_id = X_THRESHOLD_ID
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
  X_THRESHOLD_ID in NUMBER,
  X_RULE_TYPE in VARCHAR2,
  X_THRES_OBJ_ID in NUMBER,
  X_FROM_VALUE in NUMBER,
  X_TO_VALUE in NUMBER,
  X_INDICATOR_CODE in VARCHAR2,
  X_EXCEPTION_FLAG in VARCHAR2,
  X_WEIGHTING in NUMBER,
  X_ACCESS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_PERF_THRESHOLDS set
    RULE_TYPE = X_RULE_TYPE,
    THRES_OBJ_ID = X_THRES_OBJ_ID,
    FROM_VALUE = X_FROM_VALUE,
    TO_VALUE = X_TO_VALUE,
    INDICATOR_CODE = X_INDICATOR_CODE,
    EXCEPTION_FLAG = X_EXCEPTION_FLAG,
    WEIGHTING = X_WEIGHTING,
    ACCESS_LIST_ID = X_ACCESS_LIST_ID,
    THRESHOLD_ID = X_THRESHOLD_ID,
    RECORD_VERSION_NUMBER = NVL(X_RECORD_VERSION_NUMBER,RECORD_VERSION_NUMBER+1),
    LAST_UPDATE_DATE = NVL(X_LAST_UPDATE_DATE,sysdate),
    LAST_UPDATED_BY = NVL(X_LAST_UPDATED_BY,fnd_global.user_id),
    LAST_UPDATE_LOGIN = NVL(X_LAST_UPDATE_LOGIN,fnd_global.login_id)
  where THRESHOLD_ID = X_THRESHOLD_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_THRESHOLD_ID in NUMBER
) is
begin
  delete from PA_PERF_THRESHOLDS
  where THRESHOLD_ID = X_THRESHOLD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end PA_PERF_THRESHOLDS_PKG;

/
