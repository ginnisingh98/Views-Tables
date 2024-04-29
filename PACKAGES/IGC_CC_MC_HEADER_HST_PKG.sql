--------------------------------------------------------
--  DDL for Package IGC_CC_MC_HEADER_HST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_MC_HEADER_HST_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCMHHS.pls 120.3.12000000.1 2007/08/20 12:13:25 mbremkum ship $ */



/* ================================================================================
                         PROCEDURE Insert_Row
   ===============================================================================*/


  PROCEDURE Insert_Row(
                       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       X_return_status             OUT NOCOPY      VARCHAR2,
                       X_msg_count                 OUT NOCOPY      NUMBER,
                       X_msg_data                  OUT NOCOPY      VARCHAR2,
                       p_Rowid               IN OUT NOCOPY      VARCHAR2,
                       p_CC_Header_Id                    IGC_CC_MC_HEADER_HISTORY.CC_Header_Id%TYPE,
                       p_Set_Of_Books_Id                 IGC_CC_MC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
                       p_cc_version_num                  IGC_CC_MC_HEADER_HISTORY.cc_version_num%TYPE,
                       p_cc_version_action               IGC_CC_MC_HEADER_HISTORY.cc_version_action%TYPE,
                       p_Conversion_Type                 IGC_CC_MC_HEADER_HISTORY.Conversion_Type%TYPE,
                       p_Conversion_Date                 IGC_CC_MC_HEADER_HISTORY.Conversion_Date%TYPE,
                       p_Conversion_Rate                 IGC_CC_MC_HEADER_HISTORY.Conversion_Rate%TYPE
                      );
/* =================================================================================
                             PROCEDURE Lock_Row
   ================================================================================*/
  PROCEDURE Lock_Row  (
                       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       X_return_status             OUT NOCOPY      VARCHAR2,
                       X_msg_count                 OUT NOCOPY      NUMBER,
                       X_msg_data                  OUT NOCOPY      VARCHAR2,
                       p_Rowid               IN OUT NOCOPY      VARCHAR2,
                       p_CC_Header_Id                    IGC_CC_MC_HEADER_HISTORY.CC_Header_Id%TYPE,
                       p_Set_Of_Books_Id                 IGC_CC_MC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
                       p_cc_version_num                  IGC_CC_MC_HEADER_HISTORY.cc_version_num%TYPE,
                       p_cc_version_action               IGC_CC_MC_HEADER_HISTORY.cc_version_action%TYPE,
                       p_Conversion_Type                 IGC_CC_MC_HEADER_HISTORY.Conversion_Type%TYPE,
                       p_Conversion_Date                 IGC_CC_MC_HEADER_HISTORY.Conversion_Date%TYPE,
                       p_Conversion_Rate                 IGC_CC_MC_HEADER_HISTORY.Conversion_Rate%TYPE,
                       X_row_locked                OUT NOCOPY   VARCHAR2
     );
/* ================================================================================
                           PROCEDURE Update_Row
   ===============================================================================*/
  PROCEDURE Update_Row(
                       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       X_return_status             OUT NOCOPY      VARCHAR2,
                       X_msg_count                 OUT NOCOPY      NUMBER,
                       X_msg_data                  OUT NOCOPY      VARCHAR2,
                       p_Rowid               IN OUT NOCOPY      VARCHAR2,
                       p_CC_Header_Id                    IGC_CC_MC_HEADER_HISTORY.CC_Header_Id%TYPE,
                       p_Set_Of_Books_Id                 IGC_CC_MC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
                       p_cc_version_num                  IGC_CC_MC_HEADER_HISTORY.cc_version_num%TYPE,
                       p_cc_version_action               IGC_CC_MC_HEADER_HISTORY.cc_version_action%TYPE,
                       p_Conversion_Type                 IGC_CC_MC_HEADER_HISTORY.Conversion_Type%TYPE,
                       p_Conversion_Date                 IGC_CC_MC_HEADER_HISTORY.Conversion_Date%TYPE,
                       p_Conversion_Rate                 IGC_CC_MC_HEADER_HISTORY.Conversion_Rate%TYPE
                      );


/* ==============================================================================
                          PROCEDURE Delete_Row
   ============================================================================*/
  PROCEDURE Delete_Row(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  X_return_status             OUT NOCOPY      VARCHAR2,
  X_msg_count                 OUT NOCOPY      NUMBER,
  X_msg_data                  OUT NOCOPY      VARCHAR2,
  p_Rowid                   IN OUT NOCOPY     VARCHAR2
);

END IGC_CC_MC_HEADER_HST_PKG;
 

/
