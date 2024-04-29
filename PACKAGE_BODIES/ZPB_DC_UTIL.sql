--------------------------------------------------------
--  DDL for Package Body ZPB_DC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DC_UTIL" AS
/* $Header: ZPBDCUTB.pls 120.1 2007/12/04 14:33:44 mbhat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'ZPB_DC_UTIL';

  /*=========================================================================+
  |                       PROCEDURE freeze_worksheet
  |
  | DESCRIPTION
  |   Procedure freezes the worksheet with the specified object_id in
  |    ZPB_DC_OBJECTS table.
  |
  | NOTE: FND context has to be initialized before calling this API.
  |
 +=========================================================================*/
 PROCEDURE freeze_worksheet
 (
  p_object_id 		IN NUMBER,
  x_return_status 	OUT NOCOPY VARCHAR2,
  x_msg 		OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'freeze_worksheet';
  l_return_status           VARCHAR2(1) ;
  l_prior_lock_status       ZPB_DC_OBJECTS.STATUS%type ;

BEGIN

  -- get the status of the worksheet
  SELECT status
  INTO l_prior_lock_status
  FROM ZPB_DC_OBJECTS
  WHERE object_id = p_object_id;

  UPDATE ZPB_DC_OBJECTS
  SET status = 'LOCKED',
      prior_lock_status = l_prior_lock_status,
      freeze_flag = 'Y',
      --who columns
     last_updated_by =  fnd_global.USER_ID,
     last_update_date = SYSDATE,
     last_update_login  = fnd_global.LOGIN_ID
  WHERE object_id = p_object_id;

  IF(SQL%ROWCOUNT > 0)
   THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg :='Row updated successfully';
   ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_msg :='Object_id ' ||p_object_id ||' not found ';
   END IF;

  COMMIT;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg :='Object_id ' ||p_object_id ||' not found ';


   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg:=substr(sqlerrm, 1, 255);

END freeze_worksheet;

 /*=========================================================================+
  |                       PROCEDURE unfreeze_worksheet
  |
  | DESCRIPTION
  |   Procedure unfreezes the worksheet with the specified object_id in
  |    ZPB_DC_OBJECTS table.
  |
  | NOTE: FND context has to be initialized before calling this API
  |
 +=========================================================================*/

PROCEDURE unfreeze_worksheet
 (
  p_object_id 		IN NUMBER,
  x_return_status 	OUT NOCOPY VARCHAR2,
  x_msg 		OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'unfreeze_worksheet';
  l_return_status           VARCHAR2(1) ;
  l_prior_lock_status       ZPB_DC_OBJECTS.PRIOR_LOCK_STATUS%type ;

BEGIN

  -- get the previous status of the the worksheet
  SELECT prior_lock_status
    INTO l_prior_lock_status
    FROM ZPB_DC_OBJECTS
  WHERE object_id = p_object_id;

  UPDATE ZPB_DC_OBJECTS
  SET status = l_prior_lock_status,
      freeze_flag = 'N',
      --who columns
     last_updated_by =  fnd_global.USER_ID,
     last_update_date = SYSDATE,
     last_update_login  = fnd_global.LOGIN_ID
  WHERE object_id = p_object_id
  AND status = 'LOCKED';

  IF(SQL%ROWCOUNT > 0)
   THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg :='Row updated successfully';
   ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_msg :='No locked worksheet to unfreeze for Object_id ' || p_object_id;
   END IF;

  COMMIT;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg :='Object_id ' ||p_object_id ||' not found ';

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg:=substr(sqlerrm, 1, 255);

END unfreeze_worksheet;

 /*=========================================================================+
  |                       PROCEDURE refresh_worksheet
  |
  | DESCRIPTION
  |   Procedure set the worksheet with the specified  object_id
  |   for refresh  from shared in  ZPB_DC_OBJECTS table.
  |
  | NOTE: FND context has to be initialized before calling this API
  |
 +=========================================================================*/

PROCEDURE refresh_worksheet
 (
  p_object_id 		IN NUMBER,
  x_return_status 	OUT NOCOPY VARCHAR2,
  x_msg 		OUT NOCOPY VARCHAR2
  )
  IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'refresh_worksheet';
  l_return_status           VARCHAR2(1) ;



BEGIN

  UPDATE ZPB_DC_OBJECTS
  SET status = 'DISTRIBUTION_PENDING',
      freeze_flag = 'N',
      distributor_user_id = -100,
      --who columns
     last_updated_by =  fnd_global.USER_ID,
     last_update_date = SYSDATE,
     last_update_login  = fnd_global.LOGIN_ID
  WHERE object_id = p_object_id;

  IF(SQL%ROWCOUNT > 0)
   THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg :='Row updated successfully';
   ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_msg :='Object_id ' ||p_object_id ||' not found ';
   END IF;

  COMMIT;

EXCEPTION

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg:=substr(sqlerrm, 1, 255);

END refresh_worksheet;

END ZPB_DC_UTIL;

/
