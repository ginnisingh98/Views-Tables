--------------------------------------------------------
--  DDL for Package Body PA_STATUS_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUS_LISTS_PKG" as
/* $Header: PACISLTB.pls 120.0 2005/05/30 17:22:42 appldev noship $ */
procedure INSERT_ROW (
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_STATUS_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PA_STATUS_LISTS
    where STATUS_LIST_ID = X_STATUS_LIST_ID
    ;
  l_rowid rowid;
begin
  insert into PA_STATUS_LISTS (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    STATUS_LIST_ID,
    STATUS_TYPE,
    NAME,
    RECORD_VERSION_NUMBER,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    DESCRIPTION,
    CREATION_DATE
  ) values (
    sysdate,
    fnd_global.user_id,
    fnd_global.user_id,
    fnd_global.user_id,
    X_STATUS_LIST_ID,
    X_STATUS_TYPE,
    X_NAME,
    X_RECORD_VERSION_NUMBER,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_DESCRIPTION,
    sysdate);

  open c;
  fetch c into l_rowid;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
 ) IS
Resource_Busy             EXCEPTION;
Invalid_Rec_Change        EXCEPTION;
PRAGMA exception_init(Resource_Busy,-00054);
l_rec_ver_no NUMBER;
g_module_name      VARCHAR2(100) := 'pa.plsql.PA_STATUS_LISTS';
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
BEGIN

           l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

	 IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'STATUS_LISTS',
                                      p_debug_mode => l_debug_mode );
	 END IF;


     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'X_STATUS_LIST_ID = '|| X_STATUS_LIST_ID;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);
             pa_debug.g_err_stage:= 'X_RECORD_VERSION_NUMBER = '|| X_RECORD_VERSION_NUMBER;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                      l_debug_level5);

     END IF;
           IF l_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'in lock row method,ABOUT TO EXECUTE QUERY';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
		  pa_debug.reset_curr_function;
	   END IF;
	   select record_version_number into l_rec_ver_no
	   from pa_status_lists
	   where status_list_id = X_STATUS_LIST_ID
	   for update nowait;
	   if(X_RECORD_VERSION_NUMBER <> l_rec_ver_no) then
		   raise Invalid_Rec_Change;
	   end if;
	   IF l_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'in lock row method,query executed';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
		  pa_debug.reset_curr_function;
	  END IF;
EXCEPTION
	   when NO_DATA_FOUND then
	   PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'FND',
                     p_msg_name       => 'FND_RECORD_DELETED_ERROR');
		     rollback to sp;
	   when Invalid_Rec_Change then
	   PA_UTILS.ADD_MESSAGE
		    (p_app_short_name => 'FND',
                     p_msg_name       => 'FND_RECORD_CHANGED_ERROR');
		     rollback to sp;
	   when Resource_Busy then
	   PA_UTILS.ADD_MESSAGE
		    (p_app_short_name => 'FND',
                     p_msg_name       => 'FND_LOCK_RECORD_ERROR');
		     rollback to sp;
END LOCK_ROW;

procedure UPDATE_ROW (
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_STATUS_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PA_STATUS_LISTS set
    STATUS_TYPE = X_STATUS_TYPE,
    NAME = X_NAME,
    RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER+1,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    DESCRIPTION = X_DESCRIPTION,
    STATUS_LIST_ID = X_STATUS_LIST_ID,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = fnd_global.user_id,
    LAST_UPDATE_LOGIN = fnd_global.user_id
  where STATUS_LIST_ID = X_STATUS_LIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
) is
begin
  delete from PA_STATUS_LISTS
  where STATUS_LIST_ID = X_STATUS_LIST_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end PA_STATUS_LISTS_PKG;

/
