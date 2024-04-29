--------------------------------------------------------
--  DDL for Package Body PV_BENFT_USER_ROLE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BENFT_USER_ROLE_MAPS_PKG" as
/* $Header: pvxtulmb.pls 120.0 2005/07/11 23:13:14 appldev noship $ */
procedure INSERT_ROW (
  px_user_role_map_id		IN OUT NOCOPY NUMBER,
  px_object_version_number	IN OUT NOCOPY NUMBER,
  p_benefit_type		in VARCHAR2,
  p_user_role_code		in VARCHAR2,
  p_external_flag		in VARCHAR2,
  p_creation_date		IN DATE,
  p_created_by			IN NUMBER,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
  )
  IS
begin
  INSERT INTO pv_benft_user_role_maps (
    user_role_map_id,
    object_version_number,
    benefit_type,
    user_role_code,
    external_flag,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    DECODE ( px_user_role_map_id,FND_API.g_miss_num,NULL,px_user_role_map_id),
    DECODE ( px_object_version_number,FND_API.g_miss_num,NULL,px_object_version_number),
    DECODE ( p_benefit_type,FND_API.g_miss_char,NULL,p_benefit_type),
    DECODE ( p_user_role_code,FND_API.g_miss_char,NULL,p_user_role_code),
    DECODE ( p_external_flag,FND_API.g_miss_char,NULL,p_external_flag),
    DECODE ( p_creation_date,FND_API.g_miss_date,NULL,p_creation_date),
    DECODE ( p_created_by,FND_API.g_miss_num,NULL,p_created_by),
    DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date),
    DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by),
    DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login));
end INSERT_ROW;

procedure LOCK_ROW (
  p_user_role_map_id		IN NUMBER,
  p_object_version_number	IN NUMBER,
  p_benefit_type		in VARCHAR2,
  p_user_role_code		in VARCHAR2,
  p_external_flag		in VARCHAR2
) is
  CURSOR C IS SELECT
      object_version_number,
      benefit_type,
      user_role_code,
      external_flag
    FROM pv_benft_user_role_maps
    WHERE user_role_map_id = p_user_role_map_id
    FOR UPDATE OF user_role_map_id nowait;
  recinfo c%rowtype;

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
      AND ((recinfo.BENEFIT_TYPE = p_BENEFIT_TYPE)
           OR ((recinfo.BENEFIT_TYPE is null) AND (p_BENEFIT_TYPE is null)))
      AND ((recinfo.USER_ROLE_CODE = p_USER_ROLE_CODE)
           OR ((recinfo.USER_ROLE_CODE is null) AND (p_USER_ROLE_CODE is null)))
      AND ((recinfo.external_flag = p_external_flag)
           OR ((recinfo.external_flag is null) AND (p_external_flag is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  p_user_role_map_id	   IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_user_role_code	   IN VARCHAR2,
  p_external_flag	   IN VARCHAR2,
  p_last_update_date	   IN DATE,
  p_last_updated_by	   IN NUMBER,
  p_last_update_login	   IN NUMBER
) is
begin
  UPDATE pv_benft_user_role_maps SET
    object_version_number	= DECODE ( p_object_version_number,FND_API.g_miss_num,NULL,p_object_version_number+1),
    benefit_type		= DECODE ( p_benefit_type,FND_API.g_miss_char,NULL,p_benefit_type),
    user_role_code		= DECODE ( p_user_role_code,FND_API.g_miss_char,NULL,p_user_role_code),
    external_flag		= DECODE ( p_external_flag,FND_API.g_miss_char,NULL,p_external_flag),
    last_update_date		= DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date),
    last_updated_by		= DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by),
    last_update_login		= DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login)
  WHERE user_role_map_id  = p_user_role_map_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


end UPDATE_ROW;


procedure DELETE_ROW (
  p_user_role_map_id in NUMBER
) is
begin

  DELETE FROM pv_benft_user_role_maps
  WHERE user_role_map_id = p_user_role_map_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
end DELETE_ROW;

procedure LOAD_ROW (
  p_upload_mode            IN VARCHAR2,
  p_user_role_map_id	   IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_user_role_code	   IN VARCHAR2,
  p_external_flag	   IN VARCHAR2,
  p_owner		   IN VARCHAR2
)
IS

 l_user_id           number := 0;
 l_obj_verno         number;
 l_dummy_char        varchar2(1);
 l_row_id            varchar2(100);
 l_user_role_map_id  number := p_user_role_map_id;

 cursor  c_obj_verno is
  SELECT object_version_number
  FROM   pv_benft_user_role_maps
  WHERE  user_role_map_id =  p_user_role_map_id;

 cursor c_chk_status_exists is
  SELECT 'x'
  FROM   pv_benft_user_role_maps
  WHERE  user_role_map_id =  p_user_role_map_id;

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

	     INSERT_ROW(
		 px_user_role_map_id		  =>   l_user_role_map_id,
		 px_object_version_number	  =>   l_obj_verno,
		 p_benefit_type			  =>   p_benefit_type,
		 p_user_role_code		  =>   p_user_role_code,
		 p_external_flag		  =>   p_external_flag,
		 p_creation_date		  =>   SYSDATE,
		 p_created_by			  =>   l_user_id,
		 p_last_update_date		  =>   SYSDATE,
		 p_last_updated_by		  =>   l_user_id,
		 p_last_update_login		  =>   0);


	 ELSE
	     close c_chk_status_exists;
	     open c_obj_verno;
	     fetch c_obj_verno into l_obj_verno;
	     close c_obj_verno;

		 UPDATE_ROW (
		  p_user_role_map_id	   => p_user_role_map_id,
		  p_object_version_number  => l_obj_verno,
		  p_benefit_type	   => p_benefit_type,
		  p_user_role_code	   => p_user_role_code,
		  p_external_flag	   => p_external_flag,
		  p_last_update_date	   => SYSDATE,
		  p_last_updated_by	   => l_user_id,
		  p_last_update_login	   => 0);


	 END IF;
  END IF;

END LOAD_ROW;
end PV_BENFT_USER_ROLE_MAPS_PKG;

/
