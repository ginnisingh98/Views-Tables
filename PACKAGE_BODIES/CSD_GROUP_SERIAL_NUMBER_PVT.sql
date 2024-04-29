--------------------------------------------------------
--  DDL for Package Body CSD_GROUP_SERIAL_NUMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_GROUP_SERIAL_NUMBER_PVT" as
/* $Header: csdvsrnb.pls 120.1.12000000.2 2007/02/20 22:43:27 takwong ship $*/
--
-- Package name     : CSD_GROUP_SERIAL_NUMBER_PVT
-- Purpose          : This package contains the private APIs for creating,
--                    updating, deleting, locking serial numbers.
--                    Access is restricted to Oracle Depot Rapair
--                Internal Development.
-- History          :
-- Version       Date       Name        Description
-- 115.0         05/08/02   askumar     Created.
--
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_GROUP_SERIAL_NUMBER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvsrnb.pls';
--
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_REQUEST_ID      NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
G_PROG_APPL_ID    NUMBER := FND_GLOBAL.PROG_APPL_ID;
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
--
--
--   *******************************************************
--   API Name:  Create_Serial_Number
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version_number       IN   NUMBER     Required
--     p_init_msg_list            IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                   IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level         IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL

--     x_MRO_Serial_Number_Rec    IN OUT NOCOPY  CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type
--     x_return_status            OUT NOCOPY  VARCHAR2
--     x_msg_count                OUT NOCOPY  NUMBER
--     x_msg_data                 OUT NOCOPY  VARCHAR2
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Notes: This API will create a Serial Numbers entered via the Serial
--          Number Capture Screen. They will be validated against IB or
--          Service Inventory if the user opted for them.
--
PROCEDURE Create_Serial_Number(
  P_Api_Version_Number      IN      NUMBER,
  P_Init_Msg_List           IN      VARCHAR2,
  P_Commit                  IN      VARCHAR2,
  p_validation_level        IN      NUMBER,
  x_MRO_Serial_Number_rec   IN  OUT NOCOPY CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type,
  X_Return_Status           OUT NOCOPY     VARCHAR2,
  X_Msg_Count               OUT NOCOPY     NUMBER,
  X_Msg_Data                OUT NOCOPY     VARCHAR2
  )
IS
--
--
BEGIN
--

NULL;

End Create_Serial_Number;

PROCEDURE Update_Serial_Number(
  P_Api_Version_Number      IN      NUMBER,
  P_Init_Msg_List           IN      VARCHAR2,
  P_Commit                  IN      VARCHAR2,
  p_validation_level        IN      NUMBER,
  x_MRO_Serial_Number_rec   IN  OUT NOCOPY CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type,
  X_Return_Status           OUT NOCOPY     VARCHAR2,
  X_Msg_Count               OUT NOCOPY     NUMBER,
  X_Msg_Data                OUT NOCOPY     VARCHAR2
  )
IS
--

--
BEGIN

NULL;
--
 End Update_Serial_Number;


PROCEDURE Delete_Serial_Number(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2,
  P_Commit                     IN   VARCHAR2,
  p_validation_level           IN   NUMBER,
  p_MRO_Serial_Number_ID       IN   NUMBER,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  x_Msg_Count                  OUT NOCOPY  NUMBER,
  x_Msg_Data                   OUT NOCOPY  VARCHAR2
  )
iS
--
--
BEGIN
--
-- Standard Start of API savepoint
null;
 End Delete_Serial_Number;



PROCEDURE Lock_Serial_Number(
  P_Api_Version_Number      IN      NUMBER,
  P_Init_Msg_List           IN      VARCHAR2,
  P_Commit                  IN      VARCHAR2,
  p_validation_level        IN      NUMBER,
  x_MRO_Serial_Number_rec   IN      CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type,
  X_Return_Status           OUT NOCOPY     VARCHAR2,
  X_Msg_Count               OUT NOCOPY     NUMBER,
  X_Msg_Data                OUT NOCOPY     VARCHAR2
  )
IS
--

BEGIN
--
-- Standard Start of API savepoint
NULL;

 End Lock_Serial_Number;


/*------------------------------------------------------------*/
/*  This function verifies that the item is a valid inventory */
/*  item and is marked as 'Trackable'                         */
/*------------------------------------------------------------*/

FUNCTION Is_ib_trackable
 (
   p_inv_item_id       IN  NUMBER,
   p_stack_err_msg     IN  BOOLEAN
 )
RETURN BOOLEAN IS


BEGIN
return null;

END Is_ib_trackable;


/*------------------------------------------------------------*/
/*  This function verifies that the item is a serialized      */
/*  item or not                                               */
/*------------------------------------------------------------*/

FUNCTION Is_serialized
 (
   p_inv_item_id       IN  NUMBER,
   p_item_number       IN  VARCHAR2,
   p_stack_err_msg     IN  BOOLEAN
 )
RETURN BOOLEAN IS


BEGIN
return null;

END Is_serialized;


/*------------------------------------------------------------*/
-- Procedure: Validate_Serial_Number (for 11.5.7.1 development)
-- Purpose: Validate serial numbers entered via the
--          serial number capture screen
/*------------------------------------------------------------*/

PROCEDURE Validate_Serial_Number
 (
   p_ib_flag                    IN     VARCHAR2,
   p_inv_item_id                IN     NUMBER,
   p_serial_number              IN     VARCHAR2,
   x_return_value               OUT NOCOPY    VARCHAR2
 ) IS

BEGIN
       -- Validate against installed base if the user opted for it
null;
END Validate_Serial_Number;


/*------------------------------------------------------------*/
-- Function: Is_Duplicate_Serial_Num (11.5.7.1 development)
-- Purpose: Checks if serial numbers entered are duplicates
/*------------------------------------------------------------*/

PROCEDURE Is_Duplicate_Serial_Num
 (p_Api_Version_Number      IN      NUMBER,
  P_Init_Msg_List           IN      VARCHAR2,
  P_Commit                  IN      VARCHAR2,
  p_validation_level        IN      NUMBER,
  p_repair_group_id         IN     NUMBER,
  p_serial_number           IN     VARCHAR2,
  x_return_value            OUT NOCOPY    BOOLEAN,
  X_Return_Status           OUT NOCOPY     VARCHAR2,
  X_Msg_Count               OUT NOCOPY     NUMBER,
  X_Msg_Data                OUT NOCOPY     VARCHAR2
 )
 IS

BEGIN
--
null;

 END Is_Duplicate_Serial_Num;


End CSD_GROUP_SERIAL_NUMBER_PVT;

/
