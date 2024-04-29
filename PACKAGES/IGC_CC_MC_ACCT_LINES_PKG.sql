--------------------------------------------------------
--  DDL for Package IGC_CC_MC_ACCT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_MC_ACCT_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCMCAS.pls 120.3.12000000.1 2007/08/20 12:12:53 mbremkum ship $ */



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
                p_CC_Acct_Line_Id                 IGC_CC_MC_ACCT_LINES.CC_Acct_Line_Id%TYPE,
                p_Set_Of_Books_Id                 IGC_CC_MC_ACCT_LINES.Set_Of_Books_Id%TYPE,
                p_CC_Acct_Func_Amt                IGC_CC_MC_ACCT_LINES.CC_Acct_Func_Amt%TYPE,
                p_CC_Acct_Encmbrnc_Amt            IGC_CC_MC_ACCT_LINES.CC_Acct_Encmbrnc_Amt%TYPE,
                p_Conversion_Type                 IGC_CC_MC_ACCT_LINES.Conversion_Type%TYPE,
                p_Conversion_Date                 IGC_CC_MC_ACCT_LINES.Conversion_Date%TYPE,
                p_Conversion_Rate                 IGC_CC_MC_ACCT_LINES.Conversion_Rate%TYPE,
                p_cc_func_withheld_amt            IGC_CC_MC_ACCT_LINES.cc_func_withheld_amt%TYPE

                );
/* =================================================================================
                             PROCEDURE Lock_Row
   ================================================================================*/
  PROCEDURE Lock_Row  (
                p_api_version               IN    NUMBER,
                p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
                p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
                p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                X_return_status             OUT NOCOPY   VARCHAR2,
                X_msg_count                 OUT NOCOPY   NUMBER,
                X_msg_data                  OUT NOCOPY   VARCHAR2,
                p_Rowid               IN OUT NOCOPY      VARCHAR2,
                p_CC_Acct_Line_Id                 IGC_CC_MC_ACCT_LINES.CC_Acct_Line_Id%TYPE,
                p_Set_Of_Books_Id                 IGC_CC_MC_ACCT_LINES.Set_Of_Books_Id%TYPE,
                p_CC_Acct_Func_Amt                IGC_CC_MC_ACCT_LINES.CC_Acct_Func_Amt%TYPE,
                p_CC_Acct_Encmbrnc_Amt            IGC_CC_MC_ACCT_LINES.CC_Acct_Encmbrnc_Amt%TYPE,
                p_Conversion_Type                 IGC_CC_MC_ACCT_LINES.Conversion_Type%TYPE,
                p_Conversion_Date                 IGC_CC_MC_ACCT_LINES.Conversion_Date%TYPE,
                p_Conversion_Rate                 IGC_CC_MC_ACCT_LINES.Conversion_Rate%TYPE,
                p_cc_func_withheld_amt            IGC_CC_MC_ACCT_LINES.cc_func_withheld_amt%TYPE,
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
                p_CC_Acct_Line_Id                 IGC_CC_MC_ACCT_LINES.CC_Acct_Line_Id%TYPE,
                p_Set_Of_Books_Id                 IGC_CC_MC_ACCT_LINES.Set_Of_Books_Id%TYPE,
                p_CC_Acct_Func_Amt                IGC_CC_MC_ACCT_LINES.CC_Acct_Func_Amt%TYPE,
                p_CC_Acct_Encmbrnc_Amt            IGC_CC_MC_ACCT_LINES.CC_Acct_Encmbrnc_Amt%TYPE,
                p_Conversion_Type                 IGC_CC_MC_ACCT_LINES.Conversion_Type%TYPE,
                p_Conversion_Date                 IGC_CC_MC_ACCT_LINES.Conversion_Date%TYPE,
                p_Conversion_Rate                 IGC_CC_MC_ACCT_LINES.Conversion_Rate%TYPE,
                p_cc_func_withheld_amt            IGC_CC_MC_ACCT_LINES.cc_func_withheld_amt%TYPE
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
  p_Rowid                  IN OUT NOCOPY     VARCHAR2
);

END IGC_CC_MC_ACCT_LINES_PKG ;
 

/
