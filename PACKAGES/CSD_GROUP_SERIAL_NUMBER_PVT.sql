--------------------------------------------------------
--  DDL for Package CSD_GROUP_SERIAL_NUMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GROUP_SERIAL_NUMBER_PVT" AUTHID CURRENT_USER as
/* $Header: csdvsrns.pls 115.5 2002/11/14 01:49:49 swai noship $ */
--
-- Package name     : CSD_GROUP_SERIAL_NUMBER_PVT
-- Purpose          : This package contains the private APIs for creating,
--                    updating, deleting serial numbers. Access is
--                    restricted to Oracle Depot Rapair Internal Development.
-- History          :
-- Version       Date       Name        Description
-- 115.0         05/07/01   askumar      Created.


--
--   -------------------------------------------------------
--    Record name :
--    This record type will be used for creating and updating the
--    Repair Orders.
--   -------------------------------------------------------

TYPE SERIAL_NUMBER_Rec_Type IS RECORD
(      MRO_SERIAL_NUMBER_ID            NUMBER,
       REPAIR_GROUP_ID                 NUMBER,
       IB_FLAG                         VARCHAR2(1),
       INVENTORY_ITEM_ID               NUMBER,
       SERIAL_NUMBER                   VARCHAR2(30),
       VALIDATE_LEVEL                  VARCHAR2(2),
       VALID_FLAG                      VARCHAR2(1),
       CONTEXT                         VARCHAR2(30),
       ATTRIBUTE1                      VARCHAR2(150),
       ATTRIBUTE2                      VARCHAR2(150),
       ATTRIBUTE3                      VARCHAR2(150),
       ATTRIBUTE4                      VARCHAR2(150),
       ATTRIBUTE5                      VARCHAR2(150),
       ATTRIBUTE6                      VARCHAR2(150),
       ATTRIBUTE7                      VARCHAR2(150),
       ATTRIBUTE8                      VARCHAR2(150),
       ATTRIBUTE9                      VARCHAR2(150),
       ATTRIBUTE10                     VARCHAR2(150),
       ATTRIBUTE11                     VARCHAR2(150),
       ATTRIBUTE12                     VARCHAR2(150),
       ATTRIBUTE13                     VARCHAR2(150),
       ATTRIBUTE14                     VARCHAR2(150),
       ATTRIBUTE15                     VARCHAR2(150),
       OBJECT_VERSION_NUMBER           NUMBER,
       CUSTOMER_PRODUCT_ID             NUMBER,
       REFERENCE_NUMBER                VARCHAR2(30));


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
  );
--
--   *******************************************************
--   API Name:  Update_Serial_Number
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
--   Notes: This API will update a Serial Numbers entered via the Serial
--          Number Capture Screen. They will be validated against IB or
--          Service Inventory if the user opted for them.
--
PROCEDURE Update_Serial_Number(
  P_Api_Version_Number      IN      NUMBER,
  P_Init_Msg_List           IN      VARCHAR2,
  P_Commit                  IN      VARCHAR2,
  p_validation_level        IN      NUMBER,
  x_MRO_Serial_Number_rec   IN  OUT NOCOPY CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type,
  X_Return_Status           OUT NOCOPY     VARCHAR2,
  X_Msg_Count               OUT NOCOPY     NUMBER,
  X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

--   *******************************************************
--   API Name:  Delete_Serial_Number
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--     p_api_version_number      IN   NUMBER     Required
--     p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_MRO_Serial_Number_ID    IN   NUMBER     Required
--     x_return_status           OUT NOCOPY  VARCHAR2
--     x_msg_count               OUT NOCOPY  NUMBER
--     x_msg_data                OUT NOCOPY  VARCHAR2
--
--   Version : Current Version 1.0
--             Initial Version 1.0
--
--   Notes: This API will delete a Serial Numbers entered via the Serial
--          Number Capture Screen.
--
PROCEDURE Delete_Serial_Number(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2,
  P_Commit                     IN   VARCHAR2,
  p_validation_level           IN   NUMBER,
  p_MRO_Serial_Number_ID       IN   NUMBER,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2
  );


--   *******************************************************
--   API Name:  Lock_Serial_Number
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--     p_api_version_number      IN   NUMBER     Required
--     p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     x_MRO_Serial_Number_Rec    IN OUT NOCOPY  CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type
--       x_return_status         OUT NOCOPY  VARCHAR2
--       x_msg_count             OUT NOCOPY  NUMBER
--       x_msg_data              OUT NOCOPY  VARCHAR2
--
--   Version : Current Version 1.0
--             Initial Version 1.0
--
--   Notes: This API will Lock a Serial Numbers entered via the Serial
--          Number Capture Screen.
--
PROCEDURE Lock_Serial_Number(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2,
  P_Commit                     IN   VARCHAR2,
  p_validation_level           IN   NUMBER,
  x_MRO_Serial_Number_rec      IN   CSD_GROUP_SERIAL_NUMBER_PVT.SERIAL_NUMBER_Rec_Type,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2
  );


/*------------------------------------------------------------*/
/*  This function verifies that the item is a valid inventory */
/*  item and is marked as 'Trackable'                         */
/*------------------------------------------------------------*/
FUNCTION Is_ib_trackable
 (
   p_inv_item_id       IN  NUMBER,
   p_stack_err_msg     IN  BOOLEAN
 )
RETURN BOOLEAN;

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
RETURN BOOLEAN;


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
 );


/*------------------------------------------------------------*/
-- Procedure: Is_Duplicate_Serial_Num (11.5.7.1 development)
-- Purpose: Checks if serial numbers entered are duplicates
/*------------------------------------------------------------*/

PROCEDURE Is_Duplicate_Serial_Num
 (p_Api_Version_Number      IN      NUMBER,
  P_Init_Msg_List           IN      VARCHAR2,
  P_Commit                  IN      VARCHAR2,
  p_validation_level        IN      NUMBER,
  p_repair_group_id         IN      NUMBER,
  p_serial_number           IN      VARCHAR2,
  x_return_value            OUT NOCOPY    BOOLEAN,
  X_Return_Status           OUT NOCOPY     VARCHAR2,
  X_Msg_Count               OUT NOCOPY     NUMBER,
  X_Msg_Data                OUT NOCOPY     VARCHAR2
 );

End CSD_GROUP_SERIAL_NUMBER_PVT;

 

/
