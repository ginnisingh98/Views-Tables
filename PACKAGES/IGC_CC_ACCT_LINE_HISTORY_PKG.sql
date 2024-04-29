--------------------------------------------------------
--  DDL for Package IGC_CC_ACCT_LINE_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_ACCT_LINE_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCALHS.pls 120.3.12000000.3 2007/10/18 15:22:04 vumaasha ship $  */

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
     p_Rowid                  IN OUT NOCOPY      VARCHAR2,
     p_CC_Acct_Line_Id                 IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Line_Id%TYPE,
     p_CC_Header_Id                    IGC_CC_ACCT_LINE_HISTORY.CC_Header_Id%TYPE,
     p_Parent_Header_Id                IGC_CC_ACCT_LINE_HISTORY.Parent_Header_Id%TYPE,
     p_Parent_Acct_Line_Id             IGC_CC_ACCT_LINE_HISTORY.Parent_Acct_Line_Id%TYPE,
     p_CC_Acct_Line_Num	               IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Line_Num%TYPE,
     p_CC_Acct_Version_Num             IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Version_Num%TYPE,
     p_CC_Acct_Version_Action          IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Version_Action%TYPE,
     p_CC_Charge_Code_Comb_Id          IGC_CC_ACCT_LINE_HISTORY.CC_Charge_Code_Combination_Id%TYPE,
     p_CC_Budget_Code_Comb_Id          IGC_CC_ACCT_LINE_HISTORY.CC_Budget_Code_Combination_Id%TYPE,
     p_CC_Acct_Entered_Amt             IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Entered_Amt%TYPE,
     p_CC_Acct_Func_Amt                IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Func_Amt%TYPE,
     p_CC_Acct_Desc                    IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Desc%TYPE,
     p_CC_Acct_Billed_Amt              IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Billed_Amt%TYPE,
     p_CC_Acct_Unbilled_Amt            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Unbilled_Amt%TYPE,
     p_CC_Acct_Taxable_Flag            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Taxable_Flag%TYPE,
     p_Tax_Id                          IGC_CC_ACCT_LINE_HISTORY.Tax_Id%TYPE,
     p_CC_Acct_Encmbrnc_Amt            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Amt%TYPE,
     p_CC_Acct_Encmbrnc_Date           IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Date%TYPE,
     p_CC_Acct_Encmbrnc_Status         IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Status%TYPE,
     p_Project_Id                      IGC_CC_ACCT_LINE_HISTORY.Project_Id%TYPE,
     p_Task_Id           	       IGC_CC_ACCT_LINE_HISTORY.Task_Id%TYPE,
     p_Expenditure_Type                IGC_CC_ACCT_LINE_HISTORY.Expenditure_Type%TYPE,
     p_Expenditure_Org_Id              IGC_CC_ACCT_LINE_HISTORY.Expenditure_Org_Id%TYPE,
     p_Expenditure_Item_Date           IGC_CC_ACCT_LINE_HISTORY.Expenditure_Item_Date%TYPE,
     p_Last_Update_Date                IGC_CC_ACCT_LINE_HISTORY.Last_Update_Date%TYPE,
     p_Last_Updated_By                 IGC_CC_ACCT_LINE_HISTORY.Last_Updated_By%TYPE,
     p_Last_Update_Login               IGC_CC_ACCT_LINE_HISTORY.Last_Update_Login%TYPE,
     p_Creation_Date                   IGC_CC_ACCT_LINE_HISTORY.Creation_Date%TYPE,
     p_Created_By                      IGC_CC_ACCT_LINE_HISTORY.Created_By%TYPE,
     p_Attribute1                      IGC_CC_ACCT_LINE_HISTORY.Attribute1%TYPE,
     p_Attribute2                      IGC_CC_ACCT_LINE_HISTORY.Attribute2%TYPE,
     p_Attribute3                      IGC_CC_ACCT_LINE_HISTORY.Attribute3%TYPE,
     p_Attribute4                      IGC_CC_ACCT_LINE_HISTORY.Attribute4%TYPE,
     p_Attribute5                      IGC_CC_ACCT_LINE_HISTORY.Attribute5%TYPE,
     p_Attribute6                      IGC_CC_ACCT_LINE_HISTORY.Attribute6%TYPE,
     p_Attribute7                      IGC_CC_ACCT_LINE_HISTORY.Attribute7%TYPE,
     p_Attribute8                      IGC_CC_ACCT_LINE_HISTORY.Attribute8%TYPE,
     p_Attribute9                      IGC_CC_ACCT_LINE_HISTORY.Attribute9%TYPE,
     p_Attribute10                     IGC_CC_ACCT_LINE_HISTORY.Attribute10%TYPE,
     p_Attribute11                     IGC_CC_ACCT_LINE_HISTORY.Attribute11%TYPE,
     p_Attribute12                     IGC_CC_ACCT_LINE_HISTORY.Attribute12%TYPE,
     p_Attribute13                     IGC_CC_ACCT_LINE_HISTORY.Attribute13%TYPE,
     p_Attribute14                     IGC_CC_ACCT_LINE_HISTORY.Attribute14%TYPE,
     p_Attribute15                     IGC_CC_ACCT_LINE_HISTORY.Attribute15%TYPE,
     p_Context                         IGC_CC_ACCT_LINE_HISTORY.Context%TYPE,
     p_cc_func_withheld_amt            IGC_CC_ACCT_LINE_HISTORY.cc_func_withheld_amt%TYPE,
     p_cc_ent_withheld_amt             IGC_CC_ACCT_LINE_HISTORY.cc_ent_withheld_amt%TYPE,
     G_FLAG              IN OUT NOCOPY        VARCHAR2,
     P_Tax_Classif_Code                IGC_CC_ACCT_LINE_HISTORY.Tax_Classif_Code%TYPE
                      );

/* ================================================================================
                                    PROCEDURE Lock_Row
   ===============================================================================*/


  PROCEDURE Lock_Row  (
     p_api_version               IN       NUMBER,
     p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
     p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
     p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     X_return_status             OUT NOCOPY      VARCHAR2,
     X_msg_count                 OUT NOCOPY      NUMBER,
     X_msg_data                  OUT NOCOPY      VARCHAR2,
     p_Rowid               IN OUT NOCOPY      VARCHAR2,
     p_CC_Acct_Line_Id                 IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Line_Id%TYPE,
     p_CC_Header_Id                    IGC_CC_ACCT_LINE_HISTORY.CC_Header_Id%TYPE,
     p_Parent_Header_Id                IGC_CC_ACCT_LINE_HISTORY.Parent_Header_Id%TYPE,
     p_Parent_Acct_Line_Id             IGC_CC_ACCT_LINE_HISTORY.Parent_Acct_Line_Id%TYPE,
     p_CC_Acct_Line_Num	               IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Line_Num%TYPE,
     p_CC_Acct_Version_Num             IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Version_Num%TYPE,
     p_CC_Acct_Version_Action          IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Version_Action%TYPE,
     p_CC_Charge_Code_Comb_Id          IGC_CC_ACCT_LINE_HISTORY.CC_Charge_Code_Combination_Id%TYPE,
     p_CC_Budget_Code_Comb_Id          IGC_CC_ACCT_LINE_HISTORY.CC_Budget_Code_Combination_Id%TYPE,
     p_CC_Acct_Entered_Amt             IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Entered_Amt%TYPE,
     p_CC_Acct_Func_Amt                IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Func_Amt%TYPE,
     p_CC_Acct_Desc                    IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Desc%TYPE,
     p_CC_Acct_Billed_Amt              IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Billed_Amt%TYPE,
     p_CC_Acct_Unbilled_Amt            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Unbilled_Amt%TYPE,
     p_CC_Acct_Taxable_Flag            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Taxable_Flag%TYPE,
     p_Tax_Id                          IGC_CC_ACCT_LINE_HISTORY.Tax_Id%TYPE,
     p_CC_Acct_Encmbrnc_Amt            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Amt%TYPE,
     p_CC_Acct_Encmbrnc_Date           IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Date%TYPE,
     p_CC_Acct_Encmbrnc_Status         IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Status%TYPE,
     p_Project_Id                      IGC_CC_ACCT_LINE_HISTORY.Project_Id%TYPE,
     p_Task_Id         	               IGC_CC_ACCT_LINE_HISTORY.Task_Id%TYPE,
     p_Expenditure_Type                IGC_CC_ACCT_LINE_HISTORY.Expenditure_Type%TYPE,
     p_Expenditure_Org_Id              IGC_CC_ACCT_LINE_HISTORY.Expenditure_Org_Id%TYPE,
     p_Expenditure_Item_Date           IGC_CC_ACCT_LINE_HISTORY.Expenditure_Item_Date%TYPE,
     p_Last_Update_Date                IGC_CC_ACCT_LINE_HISTORY.Last_Update_Date%TYPE,
     p_Last_Updated_By                 IGC_CC_ACCT_LINE_HISTORY.Last_Updated_By%TYPE,
     p_Last_Update_Login               IGC_CC_ACCT_LINE_HISTORY.Last_Update_Login%TYPE,
     p_Creation_Date                   IGC_CC_ACCT_LINE_HISTORY.Creation_Date%TYPE,
     p_Created_By                      IGC_CC_ACCT_LINE_HISTORY.Created_By%TYPE,
     p_Attribute1                      IGC_CC_ACCT_LINE_HISTORY.Attribute1%TYPE,
     p_Attribute2                      IGC_CC_ACCT_LINE_HISTORY.Attribute2%TYPE,
     p_Attribute3                      IGC_CC_ACCT_LINE_HISTORY.Attribute3%TYPE,
     p_Attribute4                      IGC_CC_ACCT_LINE_HISTORY.Attribute4%TYPE,
     p_Attribute5                      IGC_CC_ACCT_LINE_HISTORY.Attribute5%TYPE,
     p_Attribute6                      IGC_CC_ACCT_LINE_HISTORY.Attribute6%TYPE,
     p_Attribute7                      IGC_CC_ACCT_LINE_HISTORY.Attribute7%TYPE,
     p_Attribute8                      IGC_CC_ACCT_LINE_HISTORY.Attribute8%TYPE,
     p_Attribute9                      IGC_CC_ACCT_LINE_HISTORY.Attribute9%TYPE,
     p_Attribute10                     IGC_CC_ACCT_LINE_HISTORY.Attribute10%TYPE,
     p_Attribute11                     IGC_CC_ACCT_LINE_HISTORY.Attribute11%TYPE,
     p_Attribute12                     IGC_CC_ACCT_LINE_HISTORY.Attribute12%TYPE,
     p_Attribute13                     IGC_CC_ACCT_LINE_HISTORY.Attribute13%TYPE,
     p_Attribute14                     IGC_CC_ACCT_LINE_HISTORY.Attribute14%TYPE,
     p_Attribute15                     IGC_CC_ACCT_LINE_HISTORY.Attribute15%TYPE,
     p_Context                         IGC_CC_ACCT_LINE_HISTORY.Context%TYPE,
     p_cc_func_withheld_amt            IGC_CC_ACCT_LINE_HISTORY.cc_func_withheld_amt%TYPE,
     p_cc_ent_withheld_amt             IGC_CC_ACCT_LINE_HISTORY.cc_ent_withheld_amt%TYPE,
     X_row_locked                OUT NOCOPY   VARCHAR2,
     G_FLAG                   IN OUT NOCOPY   VARCHAR2,
     P_Tax_Classif_Code                IGC_CC_ACCT_LINE_HISTORY.Tax_Classif_Code%TYPE
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
     p_Rowid                  IN OUT NOCOPY      VARCHAR2,
     p_CC_Acct_Line_Id                 IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Line_Id%TYPE,
     p_CC_Header_Id                    IGC_CC_ACCT_LINE_HISTORY.CC_Header_Id%TYPE,
     p_Parent_Header_Id                IGC_CC_ACCT_LINE_HISTORY.Parent_Header_Id%TYPE,
     p_Parent_Acct_Line_Id             IGC_CC_ACCT_LINE_HISTORY.Parent_Acct_Line_Id%TYPE,
     p_CC_Acct_Line_Num	               IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Line_Num%TYPE,
     p_CC_Acct_Version_Num             IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Version_Num%TYPE,
     p_CC_Acct_Version_Action          IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Version_Action%TYPE,
     p_CC_Charge_Code_Comb_Id          IGC_CC_ACCT_LINE_HISTORY.CC_Charge_Code_Combination_Id%TYPE,
     p_CC_Budget_Code_Comb_Id          IGC_CC_ACCT_LINE_HISTORY.CC_Budget_Code_Combination_Id%TYPE,
     p_CC_Acct_Entered_Amt             IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Entered_Amt%TYPE,
     p_CC_Acct_Func_Amt                IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Func_Amt%TYPE,
     p_CC_Acct_Desc                    IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Desc%TYPE,
     p_CC_Acct_Billed_Amt              IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Billed_Amt%TYPE,
     p_CC_Acct_Unbilled_Amt            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Unbilled_Amt%TYPE,
     p_CC_Acct_Taxable_Flag            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Taxable_Flag%TYPE,
     p_Tax_Id                          IGC_CC_ACCT_LINE_HISTORY.Tax_Id%TYPE,
     p_CC_Acct_Encmbrnc_Amt            IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Amt%TYPE,
     p_CC_Acct_Encmbrnc_Date           IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Date%TYPE,
     p_CC_Acct_Encmbrnc_Status         IGC_CC_ACCT_LINE_HISTORY.CC_Acct_Encmbrnc_Status%TYPE,
     p_Project_Id                      IGC_CC_ACCT_LINE_HISTORY.Project_Id%TYPE,
     p_Task_Id           	       IGC_CC_ACCT_LINE_HISTORY.Task_Id%TYPE,
     p_Expenditure_Type                IGC_CC_ACCT_LINE_HISTORY.Expenditure_Type%TYPE,
     p_Expenditure_Org_Id              IGC_CC_ACCT_LINE_HISTORY.Expenditure_Org_Id%TYPE,
     p_Expenditure_Item_Date           IGC_CC_ACCT_LINE_HISTORY.Expenditure_Item_Date%TYPE,
     p_Last_Update_Date                IGC_CC_ACCT_LINE_HISTORY.Last_Update_Date%TYPE,
     p_Last_Updated_By                 IGC_CC_ACCT_LINE_HISTORY.Last_Updated_By%TYPE,
     p_Last_Update_Login               IGC_CC_ACCT_LINE_HISTORY.Last_Update_Login%TYPE,
     p_Creation_Date                   IGC_CC_ACCT_LINE_HISTORY.Creation_Date%TYPE,
     p_Created_By                      IGC_CC_ACCT_LINE_HISTORY.Created_By%TYPE,
     p_Attribute1                      IGC_CC_ACCT_LINE_HISTORY.Attribute1%TYPE,
     p_Attribute2                      IGC_CC_ACCT_LINE_HISTORY.Attribute2%TYPE,
     p_Attribute3                      IGC_CC_ACCT_LINE_HISTORY.Attribute3%TYPE,
     p_Attribute4                      IGC_CC_ACCT_LINE_HISTORY.Attribute4%TYPE,
     p_Attribute5                      IGC_CC_ACCT_LINE_HISTORY.Attribute5%TYPE,
     p_Attribute6                      IGC_CC_ACCT_LINE_HISTORY.Attribute6%TYPE,
     p_Attribute7                      IGC_CC_ACCT_LINE_HISTORY.Attribute7%TYPE,
     p_Attribute8                      IGC_CC_ACCT_LINE_HISTORY.Attribute8%TYPE,
     p_Attribute9                      IGC_CC_ACCT_LINE_HISTORY.Attribute9%TYPE,
     p_Attribute10                     IGC_CC_ACCT_LINE_HISTORY.Attribute10%TYPE,
     p_Attribute11                     IGC_CC_ACCT_LINE_HISTORY.Attribute11%TYPE,
     p_Attribute12                     IGC_CC_ACCT_LINE_HISTORY.Attribute12%TYPE,
     p_Attribute13                     IGC_CC_ACCT_LINE_HISTORY.Attribute13%TYPE,
     p_Attribute14                     IGC_CC_ACCT_LINE_HISTORY.Attribute14%TYPE,
     p_Attribute15                     IGC_CC_ACCT_LINE_HISTORY.Attribute15%TYPE,
     p_Context                         IGC_CC_ACCT_LINE_HISTORY.Context%TYPE,
     p_cc_func_withheld_amt            IGC_CC_ACCT_LINE_HISTORY.cc_func_withheld_amt%TYPE,
     p_cc_ent_withheld_amt             IGC_CC_ACCT_LINE_HISTORY.cc_ent_withheld_amt%TYPE,
     G_FLAG            IN OUT NOCOPY          VARCHAR2,
     P_Tax_Classif_Code                IGC_CC_ACCT_LINE_HISTORY.Tax_Classif_Code%TYPE
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
     p_Rowid                              VARCHAR2,
     G_FLAG                   IN OUT NOCOPY      VARCHAR2
);

END IGC_CC_ACCT_LINE_HISTORY_PKG;
 

/
