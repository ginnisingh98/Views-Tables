--------------------------------------------------------
--  DDL for Package Body ASG_DEVICE_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_DEVICE_USER_PUB" as
/* $Header: asgpusrb.pls 120.1 2005/08/12 02:55:31 saradhak noship $ */


--------------------------------------------------------------------------------------
-- Procedure to create synch server.
--------------------------------------------------------------------------------------
--
PROCEDURE Create_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2,
  x_device_user_id          OUT nocopy NUMBER
) IS

BEGIN
  null;
END Create_Device_User;

PROCEDURE Update_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
) IS
BEGIN
  null;
END Update_Device_User;

PROCEDURE Delete_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE  ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
) IS

BEGIN
  null;
END Delete_Device_User;

PROCEDURE Delete_Mobile_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
) IS

BEGIN
  null;
END Delete_Mobile_User;

PROCEDURE Get_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_user_name		    IN  VARCHAR2 ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2,
  x_rec_count		    OUT nocopy NUMBER,
  x_device_user_tbl         OUT nocopy DEVICE_USER_TBL_TYPE,
  x_device_user_desc_tbl    OUT nocopy DEVICE_USER_DESC_TBL_TYPE
) IS
BEGIN
  null;
END Get_Device_User;


FUNCTION Get_Last_Sync_Date
( p_device_user_id	    IN NUMBER
) RETURN DATE IS

BEGIN
  return null;
END Get_Last_Sync_Date;


PROCEDURE Set_Last_Sync_Date
( p_device_user_id	    IN NUMBER  ,
  p_last_sync_date          IN DATE
) IS
BEGIN
  null;
END Set_Last_Sync_Date;


FUNCTION Get_Device_User_Id
( p_mobile_user_name	    IN VARCHAR2
) RETURN NUMBER IS
BEGIN
   return null;
END Get_Device_User_Id;

FUNCTION Get_User_Id ( p_device_user_id  IN NUMBER) RETURN NUMBER IS
BEGIN
  return null;
END Get_User_Id;

FUNCTION Get_User_Name (p_device_user_id    IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  return null;
END Get_User_Name;

FUNCTION Get_Language (p_device_user_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
 return null;
END Get_Language;


END ASG_DEVICE_USER_PUB;

/
