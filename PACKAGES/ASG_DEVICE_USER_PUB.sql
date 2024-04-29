--------------------------------------------------------
--  DDL for Package ASG_DEVICE_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_DEVICE_USER_PUB" AUTHID CURRENT_USER as
/* $Header: asgpusrs.pls 120.1 2005/08/12 02:55:51 saradhak noship $ */

--
--  NAME
--    ASG_DEVICE_USER_PUB
--
--  PURPOSE
--    Public API to ADD/DELETE/UPDATE/FIND Mobile Device User

G_Device_User_Id    NUMBER ;
G_Last_Sync_Date    DATE   ;


TYPE device_user_rec_type IS RECORD
(DEVICE_USER_ID              NUMBER ,
 RESOURCE_ID                 NUMBER,
 MOBILE_APPLICATION_ID       NUMBER ,
 CLIENT_NUMBER               NUMBER ,
 CLIENT_NAME		     VARCHAR2(30) ,
 LAST_UPDATE_DATE            DATE ,
 LAST_UPDATED_BY             NUMBER ,
 CREATION_DATE               DATE ,
 CREATED_BY                  NUMBER ,
 ORG_ID                      NUMBER ,
 DEVICE_TAG                  VARCHAR2(30),
 USER_ID                     NUMBER ,
 SERVER_ID                   NUMBER ,
 LAST_SYNCH_MODE             NUMBER ,
 ENABLED                     VARCHAR2(1),
 UPGRADE                     NUMBER ,
 REMOTE_DEVICE_NAME          VARCHAR2(60),
 ADDRESS_DEVICE_TYPE         VARCHAR2(30),
 ADDRESS_DEVICE_NAME         VARCHAR2(240),
 ONAIR_FLAG                  VARCHAR2(1) ,
 LAST_SYNC_DATE              DATE ,
 LAST_WIRELESS_CONTACT_DATE  DATE ,
 RETRY_DATE                  DATE ,
 BYTES_SENT_WIRELESS         NUMBER ,
 BYTES_RECEIVED_WIRELESS     NUMBER ,
 DEVICE_LOCKED               VARCHAR2(1),
 ACCESS_CODE                 VARCHAR2(240),
 LANGUAGE		     VARCHAR2(4) ,
 FLASH_MESSAGE_FLAG          VARCHAR2(1)
);

TYPE DEVICE_USER_TBL_TYPE IS TABLE OF DEVICE_USER_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_DEVICE_USER_REC device_user_rec_type ;

TYPE server_resource_rec_type IS RECORD
(SERVER_ID                   NUMBER ,
 RESOURCE_ID                 NUMBER ,
 LAST_UPDATE_DATE            DATE ,
 LAST_UPDATED_BY             NUMBER ,
 CREATION_DATE               DATE ,
 CREATED_BY                  NUMBER
 );

TYPE SERVER_RESOURCE_TBL_TYPE IS TABLE OF SERVER_RESOURCE_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_SERVER_RESOURCE_REC server_resource_rec_type;


TYPE device_user_desc_rec_type IS RECORD
(DEVICE_USER_ID		     NUMBER  ,
 MOBILE_APPLICATION_NAME     VARCHAR2(240) ,
 GATEWAY_SERVER_NAME	     VARCHAR2(240) ,
 USER_NAME		     VARCHAR2(240) ,
 FULL_NAME		     VARCHAR2(240) ,
 LANGUAGE_DESC		     VARCHAR2(255)
);


G_MISS_DEVICE_USER_DESC_REC device_user_desc_rec_type;


TYPE DEVICE_USER_DESC_TBL_TYPE IS TABLE OF DEVICE_USER_DESC_REC_TYPE INDEX BY BINARY_INTEGER;

PROCEDURE Create_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE  ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2,
  x_device_user_id          OUT nocopy NUMBER
);

PROCEDURE Update_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
);

PROCEDURE Delete_Device_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
);

PROCEDURE Delete_Mobile_User
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_device_user_rec         IN  DEVICE_USER_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
);

-- Find all device users for p_synch_server_id
-- p_device_user_rec may be used in the future

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
);

FUNCTION Get_Last_Sync_Date
( p_device_user_id	    IN NUMBER
) RETURN DATE;

PROCEDURE Set_Last_Sync_Date
( p_device_user_id	    IN NUMBER  ,
  p_last_sync_date          IN DATE
);

FUNCTION Get_Device_User_Id
( p_mobile_user_name        IN VARCHAR2
) RETURN NUMBER;

FUNCTION Get_User_Id
( p_device_user_id    IN NUMBER
) RETURN NUMBER;

FUNCTION Get_User_Name
( p_device_user_id    IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Language
( p_device_user_id    IN NUMBER
) RETURN VARCHAR2;


END ASG_DEVICE_USER_PUB;

 

/
