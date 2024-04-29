--------------------------------------------------------
--  DDL for Package Body CSF_ACCESS_HOURS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_ACCESS_HOURS_PVT" as
/* $Header: CSFVACHB.pls 120.1.12010000.2 2009/09/12 13:13:48 vakulkar ship $ */
-- Start of Comments
--
-- Package name     : CSF_ACCESS_HOURS_PVT
-- Purpose          :
-- History          :
-- 17-AUG-2004 	    : Changed the package name from CSF_ACCESS_HOURS_PKG to CSF_ACCESS_HOURS_PVT
--                  :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_ACCESS_HOUR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'CSFVACHB.pls';
 -- ---------------------------------
  -- private global package variables
  -- ---------------------------------
  g_user_id  number;
  g_login_id number;
  -----------------------------------
  --public api's
  -----------------------------------


PROCEDURE CREATE_ACCESS_HOURS(
	  p_API_VERSION              IN                     NUMBER,
	  p_INIT_MSG_LIST            IN                     VARCHAR2 ,
          x_ACCESS_HOUR_ID OUT NOCOPY NUMBER,
          p_TASK_ID    NUMBER,
          p_ACCESS_HOUR_REQD VARCHAR2 ,
          p_AFTER_HOURS_FLAG VARCHAR2 ,
          p_MONDAY_FIRST_START DATE ,
          p_MONDAY_FIRST_END DATE ,
          p_TUESDAY_FIRST_START DATE ,
          p_TUESDAY_FIRST_END DATE ,
          p_WEDNESDAY_FIRST_START DATE ,
          p_WEDNESDAY_FIRST_END DATE ,
          p_THURSDAY_FIRST_START DATE ,
          p_THURSDAY_FIRST_END DATE ,
          p_FRIDAY_FIRST_START DATE ,
          p_FRIDAY_FIRST_END DATE ,
          p_SATURDAY_FIRST_START DATE ,
          p_SATURDAY_FIRST_END DATE ,
          p_SUNDAY_FIRST_START DATE ,
          p_SUNDAY_FIRST_END DATE ,
          p_MONDAY_SECOND_START DATE ,
          p_MONDAY_SECOND_END DATE ,
          p_TUESDAY_SECOND_START DATE ,
          p_TUESDAY_SECOND_END DATE  ,
          p_WEDNESDAY_SECOND_START DATE ,
          p_WEDNESDAY_SECOND_END DATE ,
          p_THURSDAY_SECOND_START DATE ,
          p_THURSDAY_SECOND_END DATE ,
          p_FRIDAY_SECOND_START DATE ,
          p_FRIDAY_SECOND_END DATE ,
          p_SATURDAY_SECOND_START DATE ,
          p_SATURDAY_SECOND_END DATE ,
          p_SUNDAY_SECOND_START DATE ,
          p_SUNDAY_SECOND_END DATE ,
          p_DESCRIPTION VARCHAR2 ,
          px_object_version_number in out nocopy number,
          p_CREATED_BY    NUMBER ,
          p_CREATION_DATE    DATE ,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE ,
          p_LAST_UPDATE_LOGIN    NUMBER ,
          p_commit in     varchar2 ,
          x_return_status            OUT NOCOPY            VARCHAR2,
	      x_msg_data                 OUT NOCOPY            VARCHAR2,
	      x_msg_count                OUT NOCOPY            NUMBER,
		  p_data_chg_frm_ui			 VARCHAR2
)

          IS
   CURSOR c_next_seq IS SELECT CSF_ACCESS_HOURS_B_S1.nextval FROM sys.dual;

   l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PVT.CREATE_ACCESS_HOURS';
--   l_access_hour_rec Access_Hours_Rec_Type;
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_temp_b           rowid;
   l_temp_tl          rowid;

Cursor c_check_b is select ROWID from csf_access_hours_b where access_hour_id=x_access_hour_id;
Cursor c_check_tl is select ROWID from csf_access_hours_tl where access_hour_id=x_access_hour_id;


BEGIN
SAVEPOINT create_access_hours_pvt;
x_return_status := fnd_api.g_ret_sts_success;

/*  If (px_ACCESS_HOUR_ID IS NULL) OR (px_ACCESS_HOUR_ID = FND_API.G_MISS_NUM) then*/
       OPEN c_next_seq;
       FETCH c_next_seq INTO x_ACCESS_HOUR_ID;
       CLOSE c_next_seq;
  /* End If;*/


      if px_object_version_number is null
      then
        px_object_version_number := 1;
      end if;

     INSERT INTO CSF_ACCESS_HOURS_B(
          ACCESS_HOUR_ID,
          TASK_ID  ,
          CREATED_BY ,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          ACCESSHOUR_REQUIRED,
          AFTER_HOURS_FLAG,
          MONDAY_FIRST_START,
          MONDAY_FIRST_END,
          TUESDAY_FIRST_START,
          TUESDAY_FIRST_END ,
          WEDNESDAY_FIRST_START,
          WEDNESDAY_FIRST_END,
          THURSDAY_FIRST_START ,
          THURSDAY_FIRST_END ,
          FRIDAY_FIRST_START ,
          FRIDAY_FIRST_END ,
          SATURDAY_FIRST_START,
          SATURDAY_FIRST_END ,
          SUNDAY_FIRST_START ,
          SUNDAY_FIRST_END,
          MONDAY_SECOND_START,
          MONDAY_SECOND_END,
          TUESDAY_SECOND_START,
          TUESDAY_SECOND_END ,
          WEDNESDAY_SECOND_START,
          WEDNESDAY_SECOND_END,
          THURSDAY_SECOND_START ,
          THURSDAY_SECOND_END ,
          FRIDAY_SECOND_START ,
          FRIDAY_SECOND_END ,
          SATURDAY_SECOND_START,
          SATURDAY_SECOND_END ,
          SUNDAY_SECOND_START ,
          SUNDAY_SECOND_END,
          OBJECT_VERSION_NUMBER,
		  DATA_CHANGED_FRM_UI

          ) VALUES (
           x_ACCESS_HOUR_ID,
           p_TASK_ID,
           fnd_global.user_id,
           sysdate,
           g_user_id,
           sysdate,
           g_login_id,
           p_ACCESS_HOUR_REQD,
           p_AFTER_HOURS_FLAG,
           decode( p_MONDAY_FIRST_START,TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||TO_CHAR(p_MONDAY_FIRST_START,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_MONDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||to_char(p_MONDAY_FIRST_END,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_TUESDAY_FIRST_START, TO_DATE(NULL),TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_TUESDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_WEDNESDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_WEDNESDAY_FIRST_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_THURSDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_THURSDAY_FIRST_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_FRIDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_FRIDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SATURDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SATURDAY_FIRST_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SUNDAY_FIRST_START,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SUNDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_MONDAY_SECOND_START,TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||TO_CHAR(p_MONDAY_SECOND_START,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_MONDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||to_char(p_MONDAY_SECOND_END,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_TUESDAY_SECOND_START, TO_DATE(NULL),TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_TUESDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_WEDNESDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_WEDNESDAY_SECOND_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_THURSDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_THURSDAY_SECOND_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_FRIDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_FRIDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SATURDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SATURDAY_SECOND_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SUNDAY_SECOND_START,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode( p_SUNDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
           decode (px_OBJECT_VERSION_NUMBER,NULL,1,px_OBJECT_VERSION_NUMBER),
		   nvl(p_data_chg_frm_ui,'N')

           );

open c_check_b ;
fetch c_check_b into l_temp_b ;
If c_check_b%notfound then
 close c_check_b;
 raise no_data_found;
end if;
close c_check_b;


    insert into CSF_ACCESS_HOURS_TL(
    ACCESS_HOUR_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    x_ACCESS_HOUR_ID,
    p_DESCRIPTION,
   fnd_global.user_id,
           sysdate,
           g_user_id,
           sysdate,
           g_login_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where l.installed_flag in ('I','B')
  and not exists
    (select NULL
    from CSF_ACCESS_HOURS_TL T
    where T.ACCESS_HOUR_ID= x_ACCESS_HOUR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


open c_check_tl ;
fetch c_check_tl into l_temp_tl ;
If c_check_tl%notfound then
 close c_check_tl;
 raise no_data_found;
end if;
close c_check_tl;



   -- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit) THEN
    commit work;
  END IF;

fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
EXCEPTION

WHEN  fnd_api.g_exc_error then
ROLLBACK TO create_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

When fnd_api.g_exc_unexpected_error then
Rollback TO create_access_hours_pvt;
x_return_status:= fnd_api.g_ret_sts_unexp_error;
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

When others then
Rollback TO create_access_hours_pvt;
x_return_status:= fnd_api.g_ret_sts_unexp_error;
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

End CREATE_ACCESS_HOURS;

PROCEDURE Update_Access_Hours(
	  p_API_VERSION              IN                     NUMBER,
	  p_INIT_MSG_LIST            IN                     VARCHAR2 ,
          p_ACCESS_HOUR_ID   IN  NUMBER,
          p_TASK_ID    NUMBER,
          p_ACCESS_HOUR_REQD VARCHAR2,
          p_AFTER_HOURS_FLAG VARCHAR2 ,
          p_MONDAY_FIRST_START DATE ,
          p_MONDAY_FIRST_END DATE ,
          p_TUESDAY_FIRST_START DATE ,
          p_TUESDAY_FIRST_END DATE  ,
          p_WEDNESDAY_FIRST_START DATE ,
          p_WEDNESDAY_FIRST_END DATE ,
          p_THURSDAY_FIRST_START DATE,
          p_THURSDAY_FIRST_END DATE ,
          p_FRIDAY_FIRST_START DATE ,
          p_FRIDAY_FIRST_END DATE,
          p_SATURDAY_FIRST_START DATE ,
          p_SATURDAY_FIRST_END DATE ,
          p_SUNDAY_FIRST_START DATE ,
          p_SUNDAY_FIRST_END DATE ,
          p_MONDAY_SECOND_START DATE,
          p_MONDAY_SECOND_END DATE ,
          p_TUESDAY_SECOND_START DATE ,
          p_TUESDAY_SECOND_END DATE  ,
          p_WEDNESDAY_SECOND_START DATE ,
          p_WEDNESDAY_SECOND_END DATE,
          p_THURSDAY_SECOND_START DATE,
          p_THURSDAY_SECOND_END DATE ,
          p_FRIDAY_SECOND_START DATE ,
          p_FRIDAY_SECOND_END DATE ,
          p_SATURDAY_SECOND_START DATE ,
          p_SATURDAY_SECOND_END DATE ,
          p_SUNDAY_SECOND_START DATE ,
          p_SUNDAY_SECOND_END DATE,
           p_DESCRIPTION VARCHAR2,
          px_object_version_number in out nocopy number,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE ,
          p_LAST_UPDATED_BY    NUMBER ,
          p_LAST_UPDATE_DATE    DATE ,
          p_LAST_UPDATE_LOGIN    NUMBER ,
          p_commit in     varchar2,
          x_return_status            OUT NOCOPY            VARCHAR2,
	      x_msg_data                 OUT NOCOPY            VARCHAR2,
	      x_msg_count                OUT NOCOPY            NUMBER,
		  p_data_chg_frm_ui			 VARCHAR2
          )

 IS
          l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PVT.UPDATE_ACCESS_HOURS';
        -- l_access_hour_rec Access_Hours_Rec_Type;
          l_return_status    varchar2(100);
          l_msg_count        NUMBER;
          l_msg_data         varchar2(1000);
 BEGIN

x_return_status := fnd_api.g_ret_sts_success;
    px_object_version_number:=px_object_version_number+1;
   Update CSF_ACCESS_HOURS_B
    SET

  LAST_UPDATE_DATE            = sysdate,
  LAST_UPDATED_BY             = g_user_id,
  LAST_UPDATE_LOGIN           = g_login_id,
  ACCESSHOUR_REQUIRED         = p_ACCESS_HOUR_REQD,
  AFTER_HOURS_FLAG            = p_AFTER_HOURS_FLAG,
  MONDAY_FIRST_START                = decode( p_MONDAY_FIRST_START,TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||TO_CHAR(p_MONDAY_FIRST_START,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
  MONDAY_FIRST_END                  = decode( p_MONDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||to_char(p_MONDAY_FIRST_END,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
  TUESDAY_FIRST_START               = decode( p_TUESDAY_FIRST_START, TO_DATE(NULL),TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  TUESDAY_FIRST_END                 = decode( p_TUESDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  WEDNESDAY_FIRST_START             = decode( p_WEDNESDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  WEDNESDAY_FIRST_END               = decode( p_WEDNESDAY_FIRST_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  THURSDAY_FIRST_START              = decode( p_THURSDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  THURSDAY_FIRST_END                = decode( p_THURSDAY_FIRST_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  FRIDAY_FIRST_START                = decode( p_FRIDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  FRIDAY_FIRST_END                  = decode( p_FRIDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SATURDAY_FIRST_START              = decode( p_SATURDAY_FIRST_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SATURDAY_FIRST_END                = decode( p_SATURDAY_FIRST_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SUNDAY_FIRST_START                = decode( p_SUNDAY_FIRST_START,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_FIRST_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SUNDAY_FIRST_END                  = decode( p_SUNDAY_FIRST_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_FIRST_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  MONDAY_SECOND_START                = decode( p_MONDAY_SECOND_START,TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||TO_CHAR(p_MONDAY_SECOND_START,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
  MONDAY_SECOND_END                  = decode( p_MONDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('5-01-1970 '||to_char(p_MONDAY_SECOND_END,'hh24:mi'),'DD-MM-RRRR HH24:MI:SS')),
  TUESDAY_SECOND_START               = decode( p_TUESDAY_SECOND_START, TO_DATE(NULL),TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  TUESDAY_SECOND_END                 = decode( p_TUESDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('6-01-1970'||to_char(p_TUESDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  WEDNESDAY_SECOND_START             = decode( p_WEDNESDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  WEDNESDAY_SECOND_END               = decode( p_WEDNESDAY_SECOND_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('7-01-1970'||to_char(p_WEDNESDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  THURSDAY_SECOND_START              = decode( p_THURSDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  THURSDAY_SECOND_END                = decode( p_THURSDAY_SECOND_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('1-01-1970'||to_char(p_THURSDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  FRIDAY_SECOND_START                = decode( p_FRIDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  FRIDAY_SECOND_END                  = decode( p_FRIDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('2-01-1970'||to_char(p_FRIDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SATURDAY_SECOND_START              = decode( p_SATURDAY_SECOND_START, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SATURDAY_SECOND_END                = decode( p_SATURDAY_SECOND_END,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('3-01-1970'||to_char(p_SATURDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SUNDAY_SECOND_START                = decode( p_SUNDAY_SECOND_START,  TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_SECOND_START,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  SUNDAY_SECOND_END                  = decode( p_SUNDAY_SECOND_END, TO_DATE(NULL), TO_DATE(NULL), TO_DATE('4-01-1970'||to_char(p_SUNDAY_SECOND_END,'hh24:mi:ss'),'DD-MM-RRRR HH24:MI:SS')),
  OBJECT_VERSION_NUMBER       		 = px_object_version_number,
  DATA_CHANGED_FRM_UI                = nvl(p_data_chg_frm_ui,'N')
  where ACCESS_HOUR_ID = p_ACCESS_HOUR_ID
  and   TASK_ID=p_TASK_ID;

    If (SQL%NOTFOUND) then
       -- RAISE NO_DATA_FOUND;
 Raise fnd_api.g_exc_unexpected_error;
      end if;


 update CSF_ACCESS_HOURS_TL set
    DESCRIPTION = p_DESCRIPTION,
    LAST_UPDATE_DATE            = sysdate,
  LAST_UPDATED_BY             = g_user_id,
  LAST_UPDATE_LOGIN           = g_login_id,
    SOURCE_LANG = userenv('LANG')
  where ACCESS_HOUR_ID = p_ACCESS_HOUR_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   If (SQL%NOTFOUND) then
     --   RAISE NO_DATA_FOUND;
 Raise fnd_api.g_exc_unexpected_error;
      end if;


       -- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit) THEN
    commit work;
  END IF;
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION

WHEN  fnd_api.g_exc_error then
--ROLLBACK TO delete_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
--ROLLBACK TO  delete_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
--ROLLBACK TO  delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

END Update_Access_Hours;

PROCEDURE Delete_Access_Hours(
	  p_API_VERSION              IN                     NUMBER,
	  p_INIT_MSG_LIST            IN                     VARCHAR2 ,
      p_ACCESS_HOUR_ID  		 NUMBER,
      p_commit in     			 varchar2 ,
      x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER
)
 IS
   l_return_status    varchar2(100);
   l_msg_count        NUMBER;
   l_msg_data         varchar2(1000);
   l_api_name_full constant varchar2(50) := 'CSF_ACCESS_HOURS_PVT.DELETE_ACCESS_HOURS';
 BEGIN
 x_return_status := fnd_api.g_ret_sts_success;
 DELETE FROM CSF_ACCESS_HOURS_TL
    WHERE ACCESS_HOUR_ID=p_ACCESS_HOUR_ID;
   If (SQL%NOTFOUND) then
  --     RAISE NO_DATA_FOUND;
 Raise fnd_api.g_exc_unexpected_error;
     end if;

   DELETE FROM CSF_ACCESS_HOURS_B
    WHERE ACCESS_HOUR_ID=p_ACCESS_HOUR_ID;
   If (SQL%NOTFOUND) then
--       RAISE NO_DATA_FOUND;
 Raise fnd_api.g_exc_unexpected_error;
       end if;

-- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit) THEN
    commit work;
  END IF;

fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION

WHEN  fnd_api.g_exc_error then
--ROLLBACK TO delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
--ROLLBACK TO  delete_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
--ROLLBACK TO  delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

 END Delete_Access_Hours;


PROCEDURE lock_Access_hours
  (
	  p_API_VERSION              IN                     NUMBER,
	  p_INIT_MSG_LIST            IN                     VARCHAR2 default NULL,
	  p_access_hour_id in number
      , p_object_version_number  in number,
      x_return_status            OUT NOCOPY            VARCHAR2,
	  x_msg_data                 OUT NOCOPY            VARCHAR2,
	  x_msg_count                OUT NOCOPY            NUMBER
)



  IS
    cursor c_ovn
    is
      select object_version_number
      from csf_access_hours_b
      where access_hour_id = p_access_hour_id
      for update of access_hour_id nowait;

    l_rec c_ovn%rowtype;



  BEGIN

 x_return_status := fnd_api.g_ret_sts_success;
    open c_ovn;
    fetch c_ovn into l_rec;
    if c_ovn%notfound
    then
      close c_ovn;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
    close c_ovn;

    if l_rec.object_version_number = p_object_version_number
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION

WHEN  fnd_api.g_exc_error then
--ROLLBACK TO delete_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  fnd_api.g_exc_unexpected_error then
--ROLLBACK TO  delete_access_hours_pub;
x_return_status :=fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);

WHEN  OTHERS then
--ROLLBACK TO  delete_access_hours_pub;
x_return_status := fnd_api.g_ret_sts_unexp_error;
/*x_msg_count     := l_msg_count;
x_msg_data      := l_msg_data;*/
fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data => x_msg_data);
  END lock_Access_Hours;


BEGIN
-- ADD SESSION INFO
 g_user_id  := fnd_global.user_id;
 g_login_id := fnd_global.login_id;

END CSF_ACCESS_HOURS_PVT;

/
