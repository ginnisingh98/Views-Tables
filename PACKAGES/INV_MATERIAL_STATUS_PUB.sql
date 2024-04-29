--------------------------------------------------------
--  DDL for Package INV_MATERIAL_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MATERIAL_STATUS_PUB" AUTHID CURRENT_USER as
/* $Header: INVMSPUS.pls 120.2 2007/12/25 02:24:03 musinha ship $ */

-- Following constants are valid update method values which are same as
-- the look up code definition for update_method in the table MTL_MATERIAL
-- _STATUS_HISTORY

g_update_method_receive           	CONSTANT NUMBER := 1 ;
g_update_method_manual			CONSTANT NUMBER := 2 ;
g_update_method_auto			CONSTANT NUMBER := 3 ;
g_update_method_quality                 CONSTANT NUMBER := 4 ;

------------------------------------------------------------------------
-- Record type for status update record               ------------------
------------------------------------------------------------------------

TYPE mtl_status_update_rec_type is RECORD
(
     ORGANIZATION_ID       	NUMBER := fnd_api.g_miss_num
    ,INVENTORY_ITEM_ID     	NUMBER := fnd_api.g_miss_num
    ,LOT_NUMBER            	VARCHAR2(80) := fnd_api.g_miss_char  -- INVCONV,nsrivast
    ,SERIAL_NUMBER         	VARCHAR2(30) := fnd_api.g_miss_char
    ,TO_SERIAL_NUMBER           VARCHAR2(30) := fnd_api.g_miss_char
    ,UPDATE_METHOD         	NUMBER := fnd_api.g_miss_num
    ,STATUS_ID             	NUMBER := fnd_api.g_miss_num
    ,ZONE_CODE             	VARCHAR2(10) := fnd_api.g_miss_char
    ,LOCATOR_ID            	NUMBER := fnd_api.g_miss_num
    ,LPN_ID             	NUMBER := fnd_api.g_miss_num -- -- Added for # 6633612
    ,CREATION_DATE         	DATE    := fnd_api.g_miss_date
    ,CREATED_BY            	NUMBER  := fnd_api.g_miss_num
    ,LAST_UPDATED_BY       	NUMBER  := fnd_api.g_miss_num
    ,LAST_UPDATE_DATE      	DATE    := fnd_api.g_miss_date
    ,LAST_UPDATE_LOGIN          NUMBER  := fnd_api.g_miss_num
    ,PROGRAM_APPLICATION_ID     NUMBER  := fnd_api.g_miss_num
    ,PROGRAM_ID                 NUMBER  := fnd_api.g_miss_num
    ,ATTRIBUTE_CATEGORY         VARCHAR2(30) := fnd_api.g_miss_char
    ,ATTRIBUTE1                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE2                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE3                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE4                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE5                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE6                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE7                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE8                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE9                 VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE10                VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE11                VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE12                VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE13                VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE14                VARCHAR2(150) := fnd_api.g_miss_char
    ,ATTRIBUTE15                VARCHAR2(150) := fnd_api.g_miss_char
    ,UPDATE_REASON_ID           NUMBER        := fnd_api.g_miss_num
    ,INITIAL_STATUS_FLAG	VARCHAR2(1)   := fnd_api.g_miss_char
    ,FROM_MOBILE_APPS_FLAG	VARCHAR2(1)   := fnd_api.g_miss_char
    -- NSRIVAST, INVCONV , Start
    ,GRADE_CODE                 VARCHAR2(150) := fnd_api.g_miss_char
    ,PRIMARY_ONHAND             NUMBER        := fnd_api.g_miss_num
    ,SECONDARY_ONHAND           NUMBER        := fnd_api.g_miss_num
    -- NSRIVAST, INVCONV , End
);

-- Bug# 1695432, added INITIAL_STATUS_FLAG and FROM_MOBILE_APPS_FLAG col
------------------------------------------------------------------------------
-- Procedure
--   update_status
--
-- Description
--  update the corresponding entity (zone, locator, lot, serial) status and
--  record the update info in the update history
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--   p_commit                   whether or not to commit the changes to Database
--
--   p_object_type              this parameter is for performance purpose
--                              must be specified for the proper function
--                                 'Z' update zone (subinventory)
--                                 'L' update locator
--                                 'O' update lot
--                                 'S' update serial

--   p_status_rec               Contains info to be used to update entity status
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if
--                              an unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message
--                              is in this output parameter
--
------------------------------------------------------------------------------

PROCEDURE update_status
  (  p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_object_type               IN  VARCHAR2
   , p_status_rec                IN  INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type
   );

END INV_MATERIAL_STATUS_PUB;

/
