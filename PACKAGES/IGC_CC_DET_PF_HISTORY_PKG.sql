--------------------------------------------------------
--  DDL for Package IGC_CC_DET_PF_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_DET_PF_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCDFHS.pls 120.4.12010000.2 2008/08/04 14:50:10 sasukuma ship $  */

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
            p_CC_Det_PF_Line_Id               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Id%TYPE,
            p_CC_Det_PF_Line_Num              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Num%TYPE,
            p_CC_Acct_Line_Id                 IGC_CC_DET_PF_HISTORY.CC_Acct_Line_Id%TYPE,
            p_Parent_Acct_Line_Id             IGC_CC_DET_PF_HISTORY.Parent_Acct_Line_Id%TYPE,
            p_Parent_Det_PF_Line_Id           IGC_CC_DET_PF_HISTORY.Parent_Det_PF_Line_Id%TYPE,
            p_Det_PF_Version_Num              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Num%TYPE,
            p_Det_PF_Version_Action           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Action%TYPE,
            p_CC_Det_PF_Entered_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Entered_Amt%TYPE,
            p_CC_Det_PF_Func_Amt              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Func_Amt%TYPE,
            p_CC_Det_PF_Date                  IGC_CC_DET_PF_HISTORY.CC_Det_PF_Date%TYPE,
            p_CC_Det_PF_Billed_Amt            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Billed_Amt%TYPE,
            p_CC_Det_PF_Unbilled_Amt          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Unbilled_Amt%TYPE,
            p_CC_Det_PF_Encmbrnc_Amt          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Amt%TYPE,
            p_CC_Det_PF_Encmbrnc_Date         IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Date%TYPE,
            p_CC_Det_PF_Encmbrnc_Status	 IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Status%TYPE,
            p_Last_Update_Date                IGC_CC_DET_PF_HISTORY.Last_Update_Date%TYPE,
            p_Last_Updated_By                 IGC_CC_DET_PF_HISTORY.Last_Updated_By%TYPE,
	    p_Last_Update_Login               IGC_CC_DET_PF_HISTORY.Last_Update_Login%TYPE,
	    p_Creation_Date                   IGC_CC_DET_PF_HISTORY.Creation_Date%TYPE,
            p_Created_By                      IGC_CC_DET_PF_HISTORY.Created_By%TYPE,
            p_Attribute1                      IGC_CC_DET_PF_HISTORY.Attribute1%TYPE,
	    p_Attribute2                      IGC_CC_DET_PF_HISTORY.Attribute2%TYPE,
	    p_Attribute3                      IGC_CC_DET_PF_HISTORY.Attribute3%TYPE,
	    p_Attribute4                      IGC_CC_DET_PF_HISTORY.Attribute4%TYPE,
	    p_Attribute5                      IGC_CC_DET_PF_HISTORY.Attribute5%TYPE,
	    p_Attribute6                      IGC_CC_DET_PF_HISTORY.Attribute6%TYPE,
	    p_Attribute7                      IGC_CC_DET_PF_HISTORY.Attribute7%TYPE,
	    p_Attribute8                      IGC_CC_DET_PF_HISTORY.Attribute8%TYPE,
	    p_Attribute9                      IGC_CC_DET_PF_HISTORY.Attribute9%TYPE,
	    p_Attribute10                     IGC_CC_DET_PF_HISTORY.Attribute10%TYPE,
	    p_Attribute11                     IGC_CC_DET_PF_HISTORY.Attribute11%TYPE,
	    p_Attribute12                     IGC_CC_DET_PF_HISTORY.Attribute12%TYPE,
	    p_Attribute13                     IGC_CC_DET_PF_HISTORY.Attribute13%TYPE,
	    p_Attribute14                     IGC_CC_DET_PF_HISTORY.Attribute14%TYPE,
	    p_Attribute15                     IGC_CC_DET_PF_HISTORY.Attribute15%TYPE,
            p_Context                         IGC_CC_DET_PF_HISTORY.Context%TYPE,
            G_FLAG            IN OUT NOCOPY          VARCHAR2
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
            p_CC_Det_PF_Line_Id               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Id%TYPE,
            p_CC_Det_PF_Line_Num              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Num%TYPE,
            p_CC_Acct_Line_Id                 IGC_CC_DET_PF_HISTORY.CC_Acct_Line_Id%TYPE,
            p_Parent_Acct_Line_Id             IGC_CC_DET_PF_HISTORY.Parent_Acct_Line_Id%TYPE,
            p_Parent_Det_PF_Line_Id           IGC_CC_DET_PF_HISTORY.Parent_Det_PF_Line_Id%TYPE,
            p_Det_PF_Version_Num              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Num%TYPE,
            p_Det_PF_Version_Action           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Action%TYPE,
            p_CC_Det_PF_Entered_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Entered_Amt%TYPE,
            p_CC_Det_PF_Func_Amt              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Func_Amt%TYPE,
            p_CC_Det_PF_Date                  IGC_CC_DET_PF_HISTORY.CC_Det_PF_Date%TYPE,
            p_CC_Det_PF_Billed_Amt            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Billed_Amt%TYPE,
            p_CC_Det_PF_Unbilled_Amt          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Unbilled_Amt%TYPE,
            p_CC_Det_PF_Encmbrnc_Amt          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Amt%TYPE,
            p_CC_Det_PF_Encmbrnc_Date         IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Date%TYPE,
            p_CC_Det_PF_Encmbrnc_Status	 IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Status%TYPE,
            p_Last_Update_Date                IGC_CC_DET_PF_HISTORY.Last_Update_Date%TYPE,
            p_Last_Updated_By                 IGC_CC_DET_PF_HISTORY.Last_Updated_By%TYPE,
	    p_Last_Update_Login               IGC_CC_DET_PF_HISTORY.Last_Update_Login%TYPE,
	    p_Creation_Date                   IGC_CC_DET_PF_HISTORY.Creation_Date%TYPE,
            p_Created_By                      IGC_CC_DET_PF_HISTORY.Created_By%TYPE,
            p_Attribute1                      IGC_CC_DET_PF_HISTORY.Attribute1%TYPE,
	    p_Attribute2                      IGC_CC_DET_PF_HISTORY.Attribute2%TYPE,
	    p_Attribute3                      IGC_CC_DET_PF_HISTORY.Attribute3%TYPE,
	    p_Attribute4                      IGC_CC_DET_PF_HISTORY.Attribute4%TYPE,
	    p_Attribute5                      IGC_CC_DET_PF_HISTORY.Attribute5%TYPE,
	    p_Attribute6                      IGC_CC_DET_PF_HISTORY.Attribute6%TYPE,
	    p_Attribute7                      IGC_CC_DET_PF_HISTORY.Attribute7%TYPE,
	    p_Attribute8                      IGC_CC_DET_PF_HISTORY.Attribute8%TYPE,
	    p_Attribute9                      IGC_CC_DET_PF_HISTORY.Attribute9%TYPE,
	    p_Attribute10                     IGC_CC_DET_PF_HISTORY.Attribute10%TYPE,
	    p_Attribute11                     IGC_CC_DET_PF_HISTORY.Attribute11%TYPE,
	    p_Attribute12                     IGC_CC_DET_PF_HISTORY.Attribute12%TYPE,
	    p_Attribute13                     IGC_CC_DET_PF_HISTORY.Attribute13%TYPE,
	    p_Attribute14                     IGC_CC_DET_PF_HISTORY.Attribute14%TYPE,
	    p_Attribute15                     IGC_CC_DET_PF_HISTORY.Attribute15%TYPE,
            p_Context                         IGC_CC_DET_PF_HISTORY.Context%TYPE,
            X_row_locked                OUT NOCOPY      VARCHAR2,
            G_FLAG                   IN OUT NOCOPY   VARCHAR2
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
            p_CC_Det_PF_Line_Id               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Id%TYPE,
            p_CC_Det_PF_Line_Num              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Num%TYPE,
            p_CC_Acct_Line_Id                 IGC_CC_DET_PF_HISTORY.CC_Acct_Line_Id%TYPE,
            p_Parent_Acct_Line_Id             IGC_CC_DET_PF_HISTORY.Parent_Acct_Line_Id%TYPE,
            p_Parent_Det_PF_Line_Id           IGC_CC_DET_PF_HISTORY.Parent_Det_PF_Line_Id%TYPE,
            p_Det_PF_Version_Num              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Num%TYPE,
            p_Det_PF_Version_Action           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Action%TYPE,
            p_CC_Det_PF_Entered_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Entered_Amt%TYPE,
            p_CC_Det_PF_Func_Amt              IGC_CC_DET_PF_HISTORY.CC_Det_PF_Func_Amt%TYPE,
            p_CC_Det_PF_Date                  IGC_CC_DET_PF_HISTORY.CC_Det_PF_Date%TYPE,
            p_CC_Det_PF_Billed_Amt            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Billed_Amt%TYPE,
            p_CC_Det_PF_Unbilled_Amt          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Unbilled_Amt%TYPE,
            p_CC_Det_PF_Encmbrnc_Amt          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Amt%TYPE,
            p_CC_Det_PF_Encmbrnc_Date         IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Date%TYPE,
            p_CC_Det_PF_Encmbrnc_Status	 IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Status%TYPE,
            p_Last_Update_Date                IGC_CC_DET_PF_HISTORY.Last_Update_Date%TYPE,
	    p_Last_Updated_By                 IGC_CC_DET_PF_HISTORY.Last_Updated_By%TYPE,
	    p_Last_Update_Login               IGC_CC_DET_PF_HISTORY.Last_Update_Login%TYPE,
	    p_Creation_Date                   IGC_CC_DET_PF_HISTORY.Creation_Date%TYPE,
            p_Created_By                      IGC_CC_DET_PF_HISTORY.Created_By%TYPE,
            p_Attribute1                      IGC_CC_DET_PF_HISTORY.Attribute1%TYPE,
	    p_Attribute2                      IGC_CC_DET_PF_HISTORY.Attribute2%TYPE,
	    p_Attribute3                      IGC_CC_DET_PF_HISTORY.Attribute3%TYPE,
	    p_Attribute4                      IGC_CC_DET_PF_HISTORY.Attribute4%TYPE,
	    p_Attribute5                      IGC_CC_DET_PF_HISTORY.Attribute5%TYPE,
	    p_Attribute6                      IGC_CC_DET_PF_HISTORY.Attribute6%TYPE,
	    p_Attribute7                      IGC_CC_DET_PF_HISTORY.Attribute7%TYPE,
	    p_Attribute8                      IGC_CC_DET_PF_HISTORY.Attribute8%TYPE,
	    p_Attribute9                      IGC_CC_DET_PF_HISTORY.Attribute9%TYPE,
	    p_Attribute10                     IGC_CC_DET_PF_HISTORY.Attribute10%TYPE,
	    p_Attribute11                     IGC_CC_DET_PF_HISTORY.Attribute11%TYPE,
	    p_Attribute12                     IGC_CC_DET_PF_HISTORY.Attribute12%TYPE,
	    p_Attribute13                     IGC_CC_DET_PF_HISTORY.Attribute13%TYPE,
	    p_Attribute14                     IGC_CC_DET_PF_HISTORY.Attribute14%TYPE,
	    p_Attribute15                     IGC_CC_DET_PF_HISTORY.Attribute15%TYPE,
            p_Context                         IGC_CC_DET_PF_HISTORY.Context%TYPE,
            G_FLAG           IN OUT NOCOPY           VARCHAR2

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
                     G_FLAG               IN OUT NOCOPY          VARCHAR2
);

END IGC_CC_DET_PF_HISTORY_PKG;

/
