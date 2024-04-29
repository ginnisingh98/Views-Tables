--------------------------------------------------------
--  DDL for Package Body PV_STATUS_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_STATUS_NOTIFICATIONS_PKG" as
/* $Header: pvxtsnfb.pls 120.0 2005/07/11 23:13:09 appldev noship $ */

procedure INSERT_ROW (
  px_status_notification_id	 in out nocopy NUMBER,
  px_object_version_number	 in out nocopy NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_creation_date		 in DATE,
  p_created_by			 in NUMBER,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER) IS

begin
    px_object_version_number := 1;

  insert into PV_STATUS_NOTIFICATIONS (
    status_notification_id,
    object_version_number,
    status_type,
    status_code,
    enabled_flag,
    notify_pt_flag,
    notify_cm_flag,
    notify_am_flag,
    notify_others_flag,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login)
    VALUES
    (
     DECODE ( px_status_notification_id,FND_API.g_miss_num,NULL,px_status_notification_id ),
     DECODE ( px_object_version_number,FND_API.g_miss_num,NULL,px_object_version_number ),
     DECODE ( p_status_type,FND_API.g_miss_char, NULL,p_status_type ),
     DECODE ( p_status_code,FND_API.g_miss_char, NULL,p_status_code ),
     DECODE ( p_enabled_flag,FND_API.g_miss_char, NULL,p_enabled_flag ),
     DECODE ( p_notify_pt_flag,FND_API.g_miss_char, NULL,p_notify_pt_flag ),
     DECODE ( p_notify_cm_flag,FND_API.g_miss_char, NULL,p_notify_cm_flag ),
     DECODE ( p_notify_am_flag,FND_API.g_miss_char, NULL,p_notify_am_flag ),
     DECODE ( p_notify_others_flag,FND_API.g_miss_char, NULL,p_notify_others_flag ),
     DECODE ( p_creation_date,FND_API.g_miss_char, NULL,p_creation_date ),
     DECODE ( p_created_by,FND_API.g_miss_num,NULL,p_created_by ),
     DECODE ( p_last_update_date,FND_API.g_miss_char, NULL,p_last_update_date ),
     DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by ),
     DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login ));



end INSERT_ROW;

procedure LOCK_ROW (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2
) IS
  CURSOR c IS SELECT
      object_version_number,
      status_type,
      status_code,
      enabled_flag,
      notify_pt_flag,
      notify_cm_flag,
      notify_am_flag,
      notify_others_flag
    FROM pv_status_notifications
    WHERE status_notification_id = p_status_notification_id
    FOR UPDATE OF status_notification_id NOWAIT;

  recinfo c%ROWTYPE;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
      AND (recinfo.STATUS_TYPE = p_STATUS_TYPE)
      AND (recinfo.STATUS_CODE = p_STATUS_CODE)
      AND (recinfo.ENABLED_FLAG = p_ENABLED_FLAG)
      AND ((recinfo.NOTIFY_PT_FLAG = p_NOTIFY_PT_FLAG)
           OR ((recinfo.NOTIFY_PT_FLAG is null) AND (p_NOTIFY_PT_FLAG is null)))
      AND ((recinfo.NOTIFY_CM_FLAG = p_NOTIFY_CM_FLAG)
           OR ((recinfo.NOTIFY_CM_FLAG is null) AND (p_NOTIFY_CM_FLAG is null)))
      AND ((recinfo.NOTIFY_AM_FLAG = p_NOTIFY_AM_FLAG)
           OR ((recinfo.NOTIFY_AM_FLAG is null) AND (p_NOTIFY_AM_FLAG is null)))
      AND ((recinfo.NOTIFY_OTHERS_FLAG = p_NOTIFY_OTHERS_FLAG)
           OR ((recinfo.NOTIFY_OTHERS_FLAG is null) AND (p_NOTIFY_OTHERS_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
return;
end LOCK_ROW;

procedure UPDATE_ROW (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER
) IS
BEGIN
  UPDATE pv_status_notifications
  SET
    object_version_number = DECODE ( p_object_version_number,FND_API.g_miss_num,NULL,p_object_version_number+1 ) ,
   status_type		  = DECODE ( p_status_type,FND_API.g_miss_char, NULL,p_status_type ),
    status_code		  = DECODE ( p_status_code,FND_API.g_miss_char, NULL,p_status_code ),
    enabled_flag	  = DECODE ( p_enabled_flag,FND_API.g_miss_char, NULL,p_enabled_flag ),
    notify_pt_flag	  = DECODE ( p_notify_pt_flag,FND_API.g_miss_char, NULL,p_notify_pt_flag ),
    notify_cm_flag	  = DECODE ( p_notify_cm_flag,FND_API.g_miss_char, NULL,p_notify_cm_flag ),
    notify_am_flag	  = DECODE ( p_notify_am_flag,FND_API.g_miss_char, NULL,p_notify_am_flag ),
    notify_others_flag	  = DECODE ( p_notify_others_flag,FND_API.g_miss_char, NULL,p_notify_others_flag ),
    last_update_date	  = DECODE ( p_last_update_date,FND_API.g_miss_char, NULL,p_last_update_date ),
    last_updated_by	  = DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by ),
    last_update_login	  = DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login )
  WHERE status_notification_id = p_status_notification_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

end UPDATE_ROW;

procedure SEED_UPDATE_ROW (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER
) IS
BEGIN
  UPDATE pv_status_notifications
  SET
    object_version_number = DECODE ( p_object_version_number,FND_API.g_miss_num,NULL,p_object_version_number+1 ),
    status_type		  = DECODE ( p_status_type,FND_API.g_miss_char, NULL,p_status_type ),
    status_code		  = DECODE ( p_status_code,FND_API.g_miss_char, NULL,p_status_code ),
    last_update_date	  = DECODE ( p_last_update_date,FND_API.g_miss_char, NULL,p_last_update_date ),
    last_updated_by	  = DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by ),
    last_update_login	  = DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login )
  WHERE status_notification_id = p_status_notification_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

end SEED_UPDATE_ROW;

procedure UPDATE_ROW_SEED (
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_last_update_date		 in DATE,
  p_last_updated_by		 in NUMBER,
  p_last_update_login		 in NUMBER
)  IS

  CURSOR  c_updated_by
  IS
  SELECT last_updated_by
  FROM   pv_status_notifications
  WHERE  status_notification_id = p_status_notification_id;

  l_last_updated_by NUMBER;


  BEGIN

    FOR x IN c_updated_by
     LOOP
		l_last_updated_by :=  x.last_updated_by;
     END LOOP;

     -- Checking if some body updated seeded attribute codes other than SEED,
     -- If other users updated it, We will not updated enabled_flag .
     -- Else we will update enabled_flag

      IF ( l_last_updated_by = 1) THEN

        PV_STATUS_NOTIFICATIONS_PKG.UPDATE_ROW(
         p_status_notification_id	  =>   p_status_notification_id,
         p_object_version_number	  =>   p_object_version_number,
         p_status_type			  =>   p_status_type,
         p_status_code			  =>   p_status_code,
         p_enabled_flag			  =>   p_enabled_flag,
         p_notify_pt_flag		  =>   p_notify_pt_flag,
         p_notify_cm_flag		  =>   p_notify_cm_flag,
         p_notify_am_flag		  =>   p_notify_am_flag,
         p_notify_others_flag		  =>   p_notify_others_flag,
         p_last_update_date		  =>   p_last_update_date,
         p_last_updated_by		  =>   p_last_updated_by,
         p_last_update_login		  =>   p_last_update_login);


    ELSE

        PV_STATUS_NOTIFICATIONS_PKG.SEED_UPDATE_ROW(
         p_status_notification_id	  =>   p_status_notification_id,
         p_object_version_number	  =>   p_object_version_number,
         p_status_type			  =>   p_status_type,
         p_status_code			  =>   p_status_code,
         p_last_update_date		  =>   p_last_update_date,
         p_last_updated_by		  =>   p_last_updated_by,
         p_last_update_login		  =>   p_last_update_login);

    END IF;


 END Update_Row_Seed;

 procedure LOAD_ROW (
  p_upload_mode			 in VARCHAR2,
  p_status_notification_id	 in NUMBER,
  p_object_version_number	 in NUMBER,
  p_status_type			 in VARCHAR2,
  p_status_code			 in VARCHAR2,
  p_enabled_flag		 in VARCHAR2,
  p_notify_pt_flag		 in VARCHAR2,
  p_notify_cm_flag		 in VARCHAR2,
  p_notify_am_flag		 in VARCHAR2,
  p_notify_others_flag		 in VARCHAR2,
  p_owner			 in VARCHAR2
)
IS

 l_user_id           number := 0;
 l_obj_verno         number;
 l_dummy_char        varchar2(1);
 l_row_id            varchar2(100);
 l_status_notification_id      number := p_status_notification_id;

 cursor  c_obj_verno is
  SELECT object_version_number
  FROM   pv_status_notifications
  WHERE  status_notification_id =  p_status_notification_id;

 cursor c_chk_status_exists is
  SELECT 'x'
  FROM   pv_status_notifications
  WHERE  status_notification_id =  p_status_notification_id;


BEGIN

 IF p_OWNER = 'SEED' then
     l_user_id := 1;
 ELSE
     l_user_id := 0;
 END IF;
 IF p_upload_mode = 'NLS' THEN
    null;
 ELSE
	 OPEN c_chk_status_exists;
	 FETCH c_chk_status_exists INTO l_dummy_char;
	 IF c_chk_status_exists%NOTFOUND THEN
	    CLOSE c_chk_status_exists;
	    l_obj_verno := 1;
	     PV_STATUS_NOTIFICATIONS_PKG.INSERT_ROW(
		 px_status_notification_id	  =>   l_status_notification_id,
		 px_object_version_number	  =>   l_obj_verno,
		 p_status_type			  =>   p_status_type,
		 p_status_code			  =>   p_status_code,
		 p_enabled_flag			  =>   p_enabled_flag,
		 p_notify_pt_flag		  =>   p_notify_pt_flag,
		 p_notify_cm_flag		  =>   p_notify_cm_flag,
		 p_notify_am_flag		  =>   p_notify_am_flag,
		 p_notify_others_flag		  =>   p_notify_others_flag,
		 p_creation_date                  =>   SYSDATE,
		 p_created_by                     =>   l_user_id,
		 p_last_update_date		  =>   SYSDATE,
		 p_last_updated_by		  =>   l_user_id,
		 p_last_update_login		  =>   0);
	 ELSE
	     close c_chk_status_exists;
	     open c_obj_verno;
	     fetch c_obj_verno into l_obj_verno;
	     close c_obj_verno;

	     PV_STATUS_NOTIFICATIONS_PKG.UPDATE_ROW_SEED(
		 p_status_notification_id	  =>   p_status_notification_id,
		 p_object_version_number	  =>   l_obj_verno,
		 p_status_type			  =>   p_status_type,
		 p_status_code			  =>   p_status_code,
		 p_enabled_flag			  =>   p_enabled_flag,
		 p_notify_pt_flag		  =>   p_notify_pt_flag,
		 p_notify_cm_flag		  =>   p_notify_cm_flag,
		 p_notify_am_flag		  =>   p_notify_am_flag,
		 p_notify_others_flag		  =>   p_notify_others_flag,
		 p_last_update_date		  =>   SYSDATE,
		 p_last_updated_by		  =>   l_user_id,
		 p_last_update_login		  =>   0);

	 END IF;
  END IF;
END LOAD_ROW;

PROCEDURE DELETE_ROW (
  p_status_notification_id in NUMBER
)
IS
BEGIN

  DELETE FROM pv_status_notifications
  WHERE status_notification_id = p_status_notification_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

END DELETE_ROW;


end PV_STATUS_NOTIFICATIONS_PKG;

/
