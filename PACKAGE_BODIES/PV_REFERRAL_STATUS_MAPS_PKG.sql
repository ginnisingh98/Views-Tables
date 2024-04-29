--------------------------------------------------------
--  DDL for Package Body PV_REFERRAL_STATUS_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_REFERRAL_STATUS_MAPS_PKG" as
/* $Header: pvxtrfmb.pls 120.0 2005/07/11 23:13:08 appldev noship $ */
procedure INSERT_ROW (
  px_referral_status_map_id	IN OUT NOCOPY NUMBER,
  px_object_version_number	IN OUT NOCOPY NUMBER,
  p_benefit_type		IN VARCHAR2,
  p_status_code			IN VARCHAR2,
  p_map_status_code		IN VARCHAR2,
  p_creation_date		IN DATE,
  p_created_by			IN NUMBER,
  p_last_update_date		IN DATE,
  p_last_updated_by		IN NUMBER,
  p_last_update_login		IN NUMBER
  ) is
begin
  INSERT INTO pv_referral_status_maps (
    referral_status_map_id,
    object_version_number,
    benefit_type,
    status_code,
    map_status_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    DECODE ( px_referral_status_map_id,FND_API.g_miss_num,NULL,px_referral_status_map_id),
    DECODE ( px_object_version_number,FND_API.g_miss_num,NULL,px_object_version_number),
    DECODE ( p_benefit_type,FND_API.g_miss_char,NULL,p_benefit_type),
    DECODE ( p_status_code,FND_API.g_miss_char,NULL,p_status_code),
    DECODE ( p_map_status_code,FND_API.g_miss_char,NULL,p_map_status_code),
    DECODE ( p_creation_date,FND_API.g_miss_date,NULL,p_creation_date),
    DECODE ( p_created_by,FND_API.g_miss_num,NULL,p_created_by),
    DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date),
    DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by),
    DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login));


end INSERT_ROW;

procedure LOCK_ROW (
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code            IN VARCHAR2,
  p_map_status_code        IN VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      BENEFIT_TYPE,
      STATUS_CODE,
      MAP_STATUS_CODE
    from PV_REFERRAL_STATUS_MAPS
    where REFERRAL_STATUS_MAP_ID = p_REFERRAL_STATUS_MAP_ID
    for update of REFERRAL_STATUS_MAP_ID nowait;
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
      AND ((recinfo.STATUS_CODE = p_STATUS_CODE)
           OR ((recinfo.STATUS_CODE is null) AND (p_STATUS_CODE is null)))
      AND ((recinfo.MAP_STATUS_CODE = p_MAP_STATUS_CODE)
           OR ((recinfo.MAP_STATUS_CODE is null) AND (p_MAP_STATUS_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code		   IN VARCHAR2,
  p_map_status_code	   IN VARCHAR2,
  p_last_update_date	   IN DATE,
  p_last_updated_by	   IN NUMBER,
  p_last_update_login	   IN NUMBER
) is
begin
  UPDATE pv_referral_status_maps SET
    object_version_number	= DECODE ( p_object_version_number,FND_API.g_miss_num,NULL,p_object_version_number+1),
    benefit_type		= DECODE ( p_benefit_type,FND_API.g_miss_char,NULL,p_benefit_type),
    status_code			= DECODE ( p_status_code,FND_API.g_miss_char,NULL,p_status_code),
    map_status_code		= DECODE ( p_map_status_code,FND_API.g_miss_char,NULL,p_map_status_code),
    last_update_date		= DECODE ( p_last_update_date,FND_API.g_miss_date,NULL,p_last_update_date),
    last_updated_by		= DECODE ( p_last_updated_by,FND_API.g_miss_num,NULL,p_last_updated_by),
    last_update_login		= DECODE ( p_last_update_login,FND_API.g_miss_num,NULL,p_last_update_login)
  WHERE referral_status_map_id  = p_referral_status_map_id;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


end UPDATE_ROW;

procedure UPDATE_SEED_ROW (
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code		   IN VARCHAR2,
  p_map_status_code	   IN VARCHAR2,
  p_last_update_date	   IN DATE,
  p_last_updated_by	   IN NUMBER,
  p_last_update_login	   IN NUMBER
) IS

  CURSOR  c_updated_by
  IS
  SELECT last_updated_by
  FROM   pv_referral_status_maps
  WHERE  referral_status_map_id = p_referral_status_map_id;

  l_last_updated_by NUMBER;

BEGIN

    FOR x IN c_updated_by
     LOOP
		l_last_updated_by :=  x.last_updated_by;
     END LOOP;

  IF ( l_last_updated_by = 1) THEN

	 UPDATE_ROW (
	  p_referral_status_map_id => p_referral_status_map_id,
	  p_object_version_number  => p_object_version_number,
	  p_benefit_type	   => p_benefit_type,
	  p_status_code		   => p_status_code,
	  p_map_status_code	   => p_map_status_code,
	  p_last_update_date	   => p_last_update_date,
	  p_last_updated_by	   => p_last_updated_by,
	  p_last_update_login	   => p_last_update_login
	  );

  ELSE
     null;
  END IF;


end UPDATE_SEED_ROW;

procedure DELETE_ROW (
  p_REFERRAL_STATUS_MAP_ID in NUMBER
) is
begin

  delete from PV_REFERRAL_STATUS_MAPS
  where REFERRAL_STATUS_MAP_ID = p_REFERRAL_STATUS_MAP_ID;

  IF (SQL%NOTFOUND) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
end DELETE_ROW;

procedure LOAD_ROW (
  p_upload_mode            IN VARCHAR2,
  p_referral_status_map_id IN NUMBER,
  p_object_version_number  IN NUMBER,
  p_benefit_type	   IN VARCHAR2,
  p_status_code		   IN VARCHAR2,
  p_map_status_code	   IN VARCHAR2,
  p_owner		   IN VARCHAR2
)
IS

 l_user_id           number := 0;
 l_obj_verno         number;
 l_dummy_char        varchar2(1);
 l_row_id            varchar2(100);
 l_referral_status_map_id      number := p_referral_status_map_id;

 cursor  c_obj_verno is
  SELECT object_version_number
  FROM   pv_referral_status_maps
  WHERE  referral_status_map_id =  p_referral_status_map_id;

 cursor c_chk_status_exists is
  SELECT 'x'
  FROM   pv_referral_status_maps
  WHERE  referral_status_map_id =  p_referral_status_map_id;

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
		 px_referral_status_map_id	  =>   l_referral_status_map_id,
		 px_object_version_number	  =>   l_obj_verno,
		 p_benefit_type			  =>   p_benefit_type,
		 p_status_code			  =>   p_status_code,
		 p_map_status_code		  =>   p_map_status_code,
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
		  p_referral_status_map_id => p_referral_status_map_id,
		  p_object_version_number  => l_obj_verno,
		  p_benefit_type	   => p_benefit_type,
		  p_status_code		   => p_status_code,
		  p_map_status_code	   => p_map_status_code,
		  p_last_update_date	   => SYSDATE,
		  p_last_updated_by	   => l_user_id,
		  p_last_update_login	   => 0);


	 END IF;
  END IF;

END LOAD_ROW;
end PV_REFERRAL_STATUS_MAPS_PKG;

/
