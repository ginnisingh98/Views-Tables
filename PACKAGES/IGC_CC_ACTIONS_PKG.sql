--------------------------------------------------------
--  DDL for Package IGC_CC_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_ACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCACTS.pls 120.3.12000000.1 2007/08/20 12:10:47 mbremkum ship $  */


/* ================================================================================
                         PROCEDURE Insert_Row
   ===============================================================================*/

  PROCEDURE Insert_Row(

                 p_api_version               IN    NUMBER,
                 p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
                 p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 X_return_status             OUT NOCOPY   VARCHAR2,
                 X_msg_count                 OUT NOCOPY   NUMBER,
                 X_msg_data                  OUT NOCOPY   VARCHAR2,
                 p_Rowid                  IN OUT NOCOPY   VARCHAR2,
                 p_CC_Header_Id                    IGC_CC_ACTIONS.CC_Header_Id%TYPE,
                 p_CC_Action_Version_Num           IGC_CC_ACTIONS.CC_Action_Version_Num%TYPE,
                 p_CC_Action_Type                  IGC_CC_ACTIONS.CC_Action_Type %TYPE,
                 p_CC_Action_State                 IGC_CC_ACTIONS.CC_Action_State%TYPE,
                 p_CC_Action_Ctrl_Status           IGC_CC_ACTIONS.CC_Action_Ctrl_Status%TYPE,
                 p_CC_Action_Apprvl_Status         IGC_CC_ACTIONS.CC_Action_Apprvl_Status%TYPE,
                 p_CC_Action_Notes                 IGC_CC_ACTIONS.CC_Action_Notes%TYPE,
		 p_Last_Update_Date                IGC_CC_ACTIONS.Last_Update_Date%TYPE,
		 p_Last_Updated_By                 IGC_CC_ACTIONS.Last_Updated_By%TYPE,
		 p_Last_Update_Login               IGC_CC_ACTIONS.Last_Update_Login%TYPE,
		 p_Creation_Date                   IGC_CC_ACTIONS.Creation_Date%TYPE,
                 p_Created_By                      IGC_CC_ACTIONS.Created_By%TYPE
                );

/* ================================================================================
                                    PROCEDURE Lock_Row
   ===============================================================================*/


  PROCEDURE Lock_Row  (

                 p_api_version               IN    NUMBER,
                 p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
                 p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 X_return_status            OUT NOCOPY    VARCHAR2,
                 X_msg_count                OUT NOCOPY    NUMBER,
                 X_msg_data                 OUT NOCOPY    VARCHAR2,
                 p_Rowid                 IN OUT NOCOPY    VARCHAR2,
                 p_CC_Header_Id                    IGC_CC_ACTIONS.CC_Header_Id%TYPE,
                 p_CC_Action_Num                   IGC_CC_ACTIONS.CC_Action_Num%TYPE,
                 p_CC_Action_Version_Num           IGC_CC_ACTIONS.CC_Action_Version_Num%TYPE,
                 p_CC_Action_Type                  IGC_CC_ACTIONS.CC_Action_Type %TYPE,
                 p_CC_Action_State                 IGC_CC_ACTIONS.CC_Action_State%TYPE,
                 p_CC_Action_Ctrl_Status           IGC_CC_ACTIONS.CC_Action_Ctrl_Status%TYPE,
                 p_CC_Action_Apprvl_Status         IGC_CC_ACTIONS.CC_Action_Apprvl_Status%TYPE,
                 p_CC_Action_Notes                 IGC_CC_ACTIONS.CC_Action_Notes%TYPE,
                 p_Last_Update_Date                IGC_CC_ACTIONS.Last_Update_Date%TYPE,
	         p_Last_Updated_By                 IGC_CC_ACTIONS.Last_Updated_By%TYPE,
	         p_Last_Update_Login               IGC_CC_ACTIONS.Last_Update_Login%TYPE,
	         p_Creation_Date                   IGC_CC_ACTIONS.Creation_Date%TYPE,
                 p_Created_By                      IGC_CC_ACTIONS.Created_By%TYPE,
                 X_row_locked                OUT NOCOPY   VARCHAR2
                 );


/* ================================================================================
                         PROCEDURE Update_Row
   ===============================================================================*/

  PROCEDURE Update_Row(

                 p_api_version               IN    NUMBER,
                 p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
                 p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 X_return_status             OUT NOCOPY   VARCHAR2,
                 X_msg_count                 OUT NOCOPY   NUMBER,
                 X_msg_data                  OUT NOCOPY   VARCHAR2,
                 p_Rowid                  IN OUT NOCOPY   VARCHAR2,
                 p_CC_Header_Id                    IGC_CC_ACTIONS.CC_Header_Id%TYPE,
                 p_CC_Action_Num                   IGC_CC_ACTIONS.CC_Action_Num%TYPE,
                 p_CC_Action_Version_Num           IGC_CC_ACTIONS.CC_Action_Version_Num%TYPE,
                 p_CC_Action_Type                  IGC_CC_ACTIONS.CC_Action_Type %TYPE,
                 p_CC_Action_State                 IGC_CC_ACTIONS.CC_Action_State%TYPE,
                 p_CC_Action_Ctrl_Status           IGC_CC_ACTIONS.CC_Action_Ctrl_Status%TYPE,
                 p_CC_Action_Apprvl_Status         IGC_CC_ACTIONS.CC_Action_Apprvl_Status%TYPE,
                 p_CC_Action_Notes                 IGC_CC_ACTIONS.CC_Action_Notes%TYPE,
	         p_Last_Update_Date                IGC_CC_ACTIONS.Last_Update_Date%TYPE,
	         p_Last_Updated_By                 IGC_CC_ACTIONS.Last_Updated_By%TYPE,
	         p_Last_Update_Login               IGC_CC_ACTIONS.Last_Update_Login%TYPE,
	         p_Creation_Date                   IGC_CC_ACTIONS.Creation_Date%TYPE,
                 p_Created_By                      IGC_CC_ACTIONS.Created_By%TYPE
                 );


/* ================================================================================
                         PROCEDURE Delete_Row
   ===============================================================================*/

PROCEDURE Delete_Row(
                 p_api_version               IN       NUMBER,
                 p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                 p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 X_return_status             OUT NOCOPY      VARCHAR2,
                 X_msg_count                 OUT NOCOPY      NUMBER,
                 X_msg_data                  OUT NOCOPY      VARCHAR2,
                 p_Rowid                              VARCHAR2
            );

END IGC_CC_ACTIONS_PKG;
 

/
