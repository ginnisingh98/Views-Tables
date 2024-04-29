--------------------------------------------------------
--  DDL for Package Body IGC_CC_BUDGETARY_CTRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_BUDGETARY_CTRL_PKG" AS
/*$Header: IGCCBCLB.pls 120.34.12010000.3 2010/02/11 17:09:43 schakkin ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_BUDGETARY_CTRL_PKG';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1) := 'N' ;

  g_line_num          NUMBER := 0;

  g_debug_msg         VARCHAR2(10000) := NULL;

--  g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--

--Variables for ATG Central logging
  g_debug_level       NUMBER  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level       NUMBER  :=  FND_LOG.LEVEL_STATEMENT;
  g_proc_level        NUMBER  :=  FND_LOG.LEVEL_PROCEDURE;
  g_event_level       NUMBER  :=  FND_LOG.LEVEL_EVENT;
  g_excep_level       NUMBER  :=  FND_LOG.LEVEL_EXCEPTION;
  g_error_level       NUMBER  :=  FND_LOG.LEVEL_ERROR;
  g_unexp_level       NUMBER  :=  FND_LOG.LEVEL_UNEXPECTED;
  g_path              VARCHAR2(255) := 'IGC.PLSQL.IGCCBCLB.IGC_CC_BUDGETARY_CTRL_PKG.';

-- Generic Procedure for putting out debug information
--
PROCEDURE Output_Debug (
   p_path             IN VARCHAR2,
   p_debug_msg        IN VARCHAR2
);


PROCEDURE Account_Line_Wrapper
(
  p_api_version                   IN  NUMBER,
  p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  x_rowid                      IN OUT NOCOPY      VARCHAR2,
  p_action_flag                IN                 VARCHAR2,
  p_cc_acct_lines_rec          IN OUT NOCOPY      igc_cc_acct_lines%ROWTYPE,
  p_update_flag                IN OUT NOCOPY      VARCHAR2
);

PROCEDURE Det_Pf_Wrapper
(
  p_api_version                   IN  NUMBER,
  p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  x_rowid                      IN OUT NOCOPY      VARCHAR2,
  p_action_flag                   IN              VARCHAR2,
  p_cc_pmt_fcst_rec               IN              igc_cc_det_pf%ROWTYPE,
  p_update_flag                IN OUT NOCOPY      VARCHAR2
);

PROCEDURE Header_Wrapper
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  x_rowid                      IN OUT NOCOPY      VARCHAR2,
  p_action_flag                   IN       VARCHAR2,
  p_cc_header_rec                 IN       igc_cc_headers%ROWTYPE,
  p_update_flag                IN OUT NOCOPY      VARCHAR2
);


PROCEDURE Output_Debug (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Local Variables :
-- --------------------------------------------------------------------
   /*l_prod           VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(7)           := 'CC_BUD';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

   /*IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;*/
   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       NULL;
       RETURN;

END Output_Debug;



PROCEDURE Account_Line_Wrapper
(
  p_api_version                   IN              NUMBER,
  p_init_msg_list                 IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN              NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  x_rowid                      IN OUT NOCOPY      VARCHAR2,
  p_action_flag                IN                 VARCHAR2,
  p_cc_acct_lines_rec          IN OUT NOCOPY      igc_cc_acct_lines%ROWTYPE,
  p_update_flag                IN OUT NOCOPY      VARCHAR2
) IS

   l_api_name        CONSTANT VARCHAR2(30)   := 'Account_Line_Wrapper';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Account_Line_Wrapper';

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- ---------------------------------------------------------------------------------
-- Make sure that the action requested to be performed is to UPDATE a row.
-- ---------------------------------------------------------------------------------
   IF (p_action_flag = 'U') THEN

      IGC_CC_ACCT_LINES_PKG.Update_Row (
         p_api_version,
         p_init_msg_list,
         p_commit,
         p_validation_level,
         x_return_status,
         X_msg_count,
         X_msg_data,
         x_rowid,
         p_cc_acct_lines_rec.CC_acct_line_id,
         p_cc_acct_lines_rec.CC_header_id,
         p_cc_acct_lines_rec.Parent_Header_Id,
         p_cc_acct_lines_rec.Parent_Acct_Line_Id,
         p_cc_acct_lines_rec.CC_Charge_Code_Combination_Id,
         p_cc_acct_lines_rec.CC_Acct_Line_Num,
         p_cc_acct_lines_rec.CC_Budget_Code_Combination_Id,
         p_cc_acct_lines_rec.CC_Acct_Entered_Amt,
         p_cc_acct_lines_rec.CC_Acct_Func_Amt,
         p_cc_acct_lines_rec.CC_Acct_Desc,
         p_cc_acct_lines_rec.CC_Acct_Billed_Amt,
         p_cc_acct_lines_rec.CC_Acct_Unbilled_Amt,
         p_cc_acct_lines_rec.CC_Acct_Taxable_Flag,
         p_cc_acct_lines_rec.Tax_Id,
         p_cc_acct_lines_rec.cc_acct_encmbrnc_amt,
         p_cc_acct_lines_rec.cc_acct_encmbrnc_date,
         p_cc_acct_lines_rec.CC_Acct_Encmbrnc_Status,
         p_cc_acct_lines_rec.Project_Id,
         p_cc_acct_lines_rec.Task_Id,
         p_cc_acct_lines_rec.Expenditure_Type,
         p_cc_acct_lines_rec.Expenditure_Org_Id,
         p_cc_acct_lines_rec.Expenditure_Item_Date,
         p_cc_acct_lines_rec.Last_Update_Date,
         p_cc_acct_lines_rec.Last_Updated_By,
         p_cc_acct_lines_rec.Last_Update_Login,
         p_cc_acct_lines_rec.Creation_Date,
         p_cc_acct_lines_rec.Created_By,
         p_cc_acct_lines_rec.Attribute1,
         p_cc_acct_lines_rec.Attribute2,
         p_cc_acct_lines_rec.Attribute3,
         p_cc_acct_lines_rec.Attribute4,
         p_cc_acct_lines_rec.Attribute5,
         p_cc_acct_lines_rec.Attribute6,
         p_cc_acct_lines_rec.Attribute7,
         p_cc_acct_lines_rec.Attribute8,
         p_cc_acct_lines_rec.Attribute9,
         p_cc_acct_lines_rec.Attribute10,
         p_cc_acct_lines_rec.Attribute11,
         p_cc_acct_lines_rec.Attribute12,
         p_cc_acct_lines_rec.Attribute13,
         p_cc_acct_lines_rec.Attribute14,
         p_cc_acct_lines_rec.Attribute15,
         p_cc_acct_lines_rec.Context,
         p_cc_acct_lines_rec.cc_func_withheld_amt,
         p_cc_acct_lines_rec.cc_ent_withheld_amt,
         p_update_flag,
         p_cc_acct_lines_rec.Tax_Classif_Code
        );

   ELSE

-- ------------------------------------------------------------------------------------
-- Handle exception where the action flag is NOT Valid.  Return Status of Failure
-- ------------------------------------------------------------------------------------
      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   RETURN;

EXCEPTION

  WHEN OTHERS THEN

    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                 l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

    IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    RETURN;

END Account_Line_Wrapper;


PROCEDURE Det_Pf_Wrapper
(
  p_api_version                   IN              NUMBER,
  p_init_msg_list                 IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN              VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN              NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  x_rowid                         IN OUT NOCOPY   VARCHAR2,
  p_action_flag                   IN              VARCHAR2,
  p_cc_pmt_fcst_rec               IN              igc_cc_det_pf%ROWTYPE,
  p_update_flag                IN OUT NOCOPY      VARCHAR2
) IS

   l_api_name        CONSTANT VARCHAR2(30)   := 'Det_Pf_Wrapper';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Det_Pf_Wrapper';

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- ---------------------------------------------------------------------------------
-- Make sure that the action requested to be performed is to UPDATE a row.
-- ---------------------------------------------------------------------------------
   IF (p_action_flag = 'U') THEN

      IGC_CC_DET_PF_PKG.Update_Row (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_validation_level,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_rowid,
            p_cc_pmt_fcst_rec.CC_det_pf_line_id,
            p_cc_pmt_fcst_rec.CC_Det_PF_Line_Num,
            p_cc_pmt_fcst_rec.CC_Acct_Line_Id,
            p_cc_pmt_fcst_rec.Parent_Acct_Line_Id,
            p_cc_pmt_fcst_rec.Parent_Det_PF_Line_Id,
            p_cc_pmt_fcst_rec.CC_Det_PF_Entered_Amt,
            p_cc_pmt_fcst_rec.CC_Det_PF_Func_Amt,
            p_cc_pmt_fcst_rec.CC_Det_PF_Date,
            p_cc_pmt_fcst_rec.CC_Det_PF_Billed_Amt,
            p_cc_pmt_fcst_rec.CC_Det_PF_Unbilled_Amt,
            p_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Amt,
            p_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Date,
            p_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Status,
            p_cc_pmt_fcst_rec.Last_Update_Date,
            p_cc_pmt_fcst_rec.Last_Updated_By,
            p_cc_pmt_fcst_rec.Last_Update_Login,
            p_cc_pmt_fcst_rec.Creation_Date,
            p_cc_pmt_fcst_rec.Created_By,
            p_cc_pmt_fcst_rec.Attribute1,
            p_cc_pmt_fcst_rec.Attribute2,
            p_cc_pmt_fcst_rec.Attribute3,
            p_cc_pmt_fcst_rec.Attribute4,
            p_cc_pmt_fcst_rec.Attribute5,
            p_cc_pmt_fcst_rec.Attribute6,
            p_cc_pmt_fcst_rec.Attribute7,
            p_cc_pmt_fcst_rec.Attribute8,
            p_cc_pmt_fcst_rec.Attribute9,
            p_cc_pmt_fcst_rec.Attribute10,
            p_cc_pmt_fcst_rec.Attribute11,
            p_cc_pmt_fcst_rec.Attribute12,
            p_cc_pmt_fcst_rec.Attribute13,
            p_cc_pmt_fcst_rec.Attribute14,
            p_cc_pmt_fcst_rec.Attribute15,
            p_cc_pmt_fcst_rec.Context,
            p_update_flag
           );

   ELSE

-- ------------------------------------------------------------------------------------
-- Handle exception where the action flag is NOT Valid.  Return Status of Failure
-- ------------------------------------------------------------------------------------
      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   RETURN;

EXCEPTION

  WHEN OTHERS THEN

    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                 l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

    IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    RETURN;

END Det_Pf_Wrapper;

PROCEDURE Header_Wrapper
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  x_rowid                      IN OUT NOCOPY      VARCHAR2,
  p_action_flag                   IN       VARCHAR2,
  p_cc_header_rec                 IN       igc_cc_headers%ROWTYPE,
  p_update_flag                IN OUT NOCOPY      VARCHAR2
) IS

   l_api_name        CONSTANT VARCHAR2(30)   := 'Header_Wrapper';
   l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Header_Wrapper';

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- ---------------------------------------------------------------------------------
-- Make sure that the action requested to be performed is to UPDATE a row.
-- ---------------------------------------------------------------------------------
   IF (p_action_flag = 'U') THEN

      IGC_CC_HEADERS_PKG.Update_Row (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_validation_level,
            x_return_status,
            x_msg_count,
            x_msg_data,
            x_rowid,
            p_cc_header_rec.CC_Header_Id,
            p_cc_header_rec.Org_id,
            p_cc_header_rec.CC_Type,
            p_cc_header_rec.CC_Num,
            p_cc_header_rec.CC_Version_num,
            p_cc_header_rec.Parent_Header_Id,
            p_cc_header_rec.CC_State,
            p_cc_header_rec.CC_ctrl_status,
            p_cc_header_rec.CC_Encmbrnc_Status,
            p_cc_header_rec.CC_Apprvl_Status,
            p_cc_header_rec.Vendor_Id,
            p_cc_header_rec.Vendor_Site_Id,
            p_cc_header_rec.Vendor_Contact_Id,
            p_cc_header_rec.Term_Id,
            p_cc_header_rec.Location_Id,
            p_cc_header_rec.Set_Of_Books_Id,
            p_cc_header_rec.CC_Acct_Date,
            p_cc_header_rec.CC_Desc,
            p_cc_header_rec.CC_Start_Date,
            p_cc_header_rec.CC_End_Date,
            p_cc_header_rec.CC_Owner_User_Id,
            p_cc_header_rec.CC_Preparer_User_Id,
            p_cc_header_rec.Currency_Code,
            p_cc_header_rec.Conversion_Type,
            p_cc_header_rec.Conversion_Date,
            p_cc_header_rec.Conversion_Rate,
            p_cc_header_rec.Last_Update_Date,
            p_cc_header_rec.Last_Updated_By,
            p_cc_header_rec.Last_Update_Login,
            p_cc_header_rec.Created_By,
            p_cc_header_rec.Creation_Date,
            p_cc_header_rec.CC_Current_User_Id,
            p_cc_header_rec.Wf_Item_Type,
            p_cc_header_rec.Wf_Item_Key,
            p_cc_header_rec.Attribute1,
            p_cc_header_rec.Attribute2,
            p_cc_header_rec.Attribute3,
            p_cc_header_rec.Attribute4,
            p_cc_header_rec.Attribute5,
            p_cc_header_rec.Attribute6,
            p_cc_header_rec.Attribute7,
            p_cc_header_rec.Attribute8,
            p_cc_header_rec.Attribute9,
            p_cc_header_rec.Attribute10,
            p_cc_header_rec.Attribute11,
            p_cc_header_rec.Attribute12,
            p_cc_header_rec.Attribute13,
            p_cc_header_rec.Attribute14,
            p_cc_header_rec.Attribute15,
            p_cc_header_rec.Context,
            p_cc_header_rec.Cc_Guarantee_Flag,
            p_update_flag
           );

   ELSE

-- ------------------------------------------------------------------------------------
-- Handle exception where the action flag is NOT Valid.  Return Status of Failure
-- ------------------------------------------------------------------------------------
      x_return_status := FND_API.G_RET_STS_ERROR;

   END IF;

   RETURN;

EXCEPTION

  WHEN OTHERS THEN

    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                 l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

    IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    RETURN;

END Header_Wrapper;


PROCEDURE Execute_Rel_Budgetary_Ctrl
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  p_cc_header_id                  IN       NUMBER,
  p_accounting_date               IN       DATE,
  p_cbc_on        IN      BOOLEAN,
  p_currency_code                 IN       VARCHAR2
)
IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Execute_Rel_Budgetary_Ctrl';
  l_api_version                   CONSTANT NUMBER         :=  1.0;

  l_cc_headers_rec                igc_cc_headers%ROWTYPE;
  l_cc_acct_lines_rec             igc_cc_acct_lines_v%ROWTYPE;
  l_cc_pmt_fcst_rec               igc_cc_det_pf_v%ROWTYPE;

  l_transaction_date              DATE;

  l_cc_acct_comp_func_amt         igc_cc_acct_lines_v.cc_acct_comp_func_amt%TYPE;
  l_cc_acct_enc_amt         igc_cc_acct_lines_v.cc_acct_encmbrnc_amt%TYPE;

  l_cc_det_pf_comp_func_amt       igc_cc_det_pf_v.cc_det_pf_comp_func_amt%TYPE;
  l_cc_det_pf_enc_amt             igc_cc_det_pf_v.cc_det_pf_encmbrnc_amt%TYPE;

  l_billed_amt                    NUMBER;
  l_func_billed_amt               NUMBER;
  l_encumbrance_status            VARCHAR2(1);
  l_error_message                 VARCHAR2(2000);

-- -------------------------------------------------------------------------
-- Variables to be used in calls to the table wrapper procedures.
-- -------------------------------------------------------------------------
        l_validation_level              NUMBER;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_row_id                        VARCHAR2(18);
        l_update_flag                   VARCHAR2(1);
        l_update_login                  igc_cc_acct_lines.last_update_login%TYPE;
        l_update_by                     igc_cc_acct_lines.last_updated_by%TYPE;

-- -------------------------------------------------------------------------
-- Record definitions to be used for CURSORS getting single record for
-- the table wrappers.  These record definitions are NOT the same as the
-- ones above when getting data from the views.
-- -------------------------------------------------------------------------
        l_det_pf_rec                    igc_cc_det_pf%ROWTYPE;
        l_acct_line_rec                 igc_cc_acct_lines%ROWTYPE;

  /* Contract Commitment account lines  */

-- Bug 2885953 - amended cursor below for performance enhancements
--    CURSOR c_account_lines(t_cc_header_id NUMBER) IS
--    SELECT *
--        FROM  igc_cc_acct_lines_v ccac
--        WHERE ccac.cc_header_id = t_cc_header_id;
  CURSOR c_account_lines(t_cc_header_id NUMBER) IS
  SELECT ccac.ROWID,
               ccac.cc_header_id,
               NULL org_id,
               NULL cc_type,
               NULL cc_type_code,
               NULL cc_num,
               ccac.cc_acct_line_id,
               ccac.cc_acct_line_num,
               ccac.cc_acct_desc,
               ccac.parent_header_id,
               ccac.parent_acct_line_id,
               NULL parent_cc_acct_line_num,
               NULL cc_budget_acct_desc,
               ccac.cc_budget_code_combination_id,
               NULL cc_charge_acct_desc,
               ccac.cc_charge_code_combination_id,
               ccac.cc_acct_entered_amt,
               ccac.cc_acct_func_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_func_billed_amt,
               ccac.cc_acct_encmbrnc_amt,
               (IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0)) - NVL(ccac.cc_acct_encmbrnc_amt,0)) cc_acct_unencmrd_amt,
               ccac.cc_acct_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0))
               cc_acct_comp_func_amt,
               NULL project_number,
               ccac.project_id,
               NULL task_number,
               ccac.task_id,
               ccac.expenditure_type,
               NULL expenditure_org_name,
               ccac.expenditure_org_id,
               ccac.expenditure_item_date,
               ccac.cc_acct_taxable_flag,
               NULL tax_name,
               ccac.tax_id,
               ccac.cc_acct_encmbrnc_status,
               ccac.cc_acct_encmbrnc_date,
               ccac.context,
               ccac.attribute1,
               ccac.attribute2,
               ccac.attribute3,
               ccac.attribute4,
               ccac.attribute5,
               ccac.attribute6,
               ccac.attribute7,
               ccac.attribute8,
               ccac.attribute9,
               ccac.attribute10,
               ccac.attribute11,
               ccac.attribute12,
               ccac.attribute13,
               ccac.attribute14,
               ccac.attribute15,
               ccac.created_by,
               ccac.creation_date,
               ccac.last_updated_by,
               ccac.last_update_date,
               ccac.last_update_login,
               ccac.cc_func_withheld_amt,
               ccac.cc_ent_withheld_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
               ccac.Tax_Classif_Code
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;

  /* Contract  Detail Payment Forecast lines  */

  CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS
        -- Performance Tuning, Replaced view igc_cc_det_pf_v with
        -- igc_cc_det_pf
  -- SELECT *
        -- FROM  igc_cc_det_pf_v
        -- WHERE cc_acct_line_id = t_cc_acct_line_id;
        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id, NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) ) cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
        WHERE ccdpf.cc_acct_line_id = t_cc_acct_line_id;

-- -------------------------------------------------------------------------
-- Cursors used for obtaining a single line to be passed into the wrapper
-- functions for updating, inserting, deleting records from tables.
-- -------------------------------------------------------------------------
        CURSOR c_cc_acct_line IS
          SELECT *
            FROM igc_cc_acct_lines
           WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

        CURSOR c_det_pf_line IS
          SELECT *
            FROM igc_cc_det_pf
           WHERE cc_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id;

   l_full_path         VARCHAR2(255);

BEGIN

        l_full_path := g_path || 'Execute_Rel_Budgetary_Ctrl';

  SAVEPOINT Execute_Rel_Budgetary_Ctrl;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;
        l_validation_level := p_validation_level;
        l_update_login     := FND_GLOBAL.LOGIN_ID;
        l_update_by        := FND_GLOBAL.USER_ID;

  SELECT *
  INTO l_cc_headers_rec
  FROM igc_cc_headers
  WHERE cc_header_id = p_cc_header_id;

  IF ( (l_cc_headers_rec.cc_state = 'PR') OR (l_cc_headers_rec.cc_state = 'CL') )
  THEN
    l_encumbrance_status := 'P';
  END IF;

  IF ( (l_cc_headers_rec.cc_state = 'CM') OR (l_cc_headers_rec.cc_state = 'CT') )
  THEN
    l_encumbrance_status := 'C';
  END IF;


  OPEN c_account_lines(p_cc_header_id);

  LOOP

    FETCH c_account_lines INTO l_cc_acct_lines_rec;

    EXIT WHEN c_account_lines%NOTFOUND;

-- ----------------------------------------------------------------------------------
-- Obtain the actual account line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                OPEN c_cc_acct_line;
                FETCH c_cc_acct_line
                 INTO l_acct_line_rec;

                IF (c_cc_acct_line%NOTFOUND) THEN
                   EXIT;
                END IF;

                CLOSE c_cc_acct_line;

/*    IF (p_cbc_on = TRUE)
    THEN*/ --Bug 5464993. Update amounts even when cbc is disabled

    IF (l_cc_headers_rec.cc_state = 'CL') THEN
      -- Added for Bug 3219208
      -- Entered Amt should be set to 0 when the CC is being
      -- cancelled.
      l_acct_line_rec.cc_acct_entered_amt     := 0;
      l_acct_line_rec.cc_acct_func_amt        := 0;
      l_cc_acct_comp_func_amt := 0;

        -- l_cc_acct_comp_func_amt := l_cc_acct_lines_rec.cc_acct_comp_func_amt;
      l_cc_acct_enc_amt  := 0;
      IF (p_cbc_on = TRUE)
      THEN
                        l_acct_line_rec.cc_acct_encmbrnc_amt    := 0;
                          l_acct_line_rec.cc_acct_encmbrnc_status := 'N';
                          l_acct_line_rec.cc_acct_encmbrnc_date   := p_accounting_date;
      END IF;
                  l_acct_line_rec.last_update_date        := SYSDATE;
                  l_acct_line_rec.last_update_login       := l_update_login;
                        l_acct_line_rec.last_updated_by         := l_update_by;

    ELSIF (l_cc_headers_rec.cc_state = 'PR') THEN

      IF (p_cbc_on = TRUE)
      THEN
        l_cc_acct_comp_func_amt := l_cc_acct_lines_rec.cc_acct_comp_func_amt;
        l_cc_acct_enc_amt  := l_cc_acct_lines_rec.cc_acct_comp_func_amt;
                          l_acct_line_rec.cc_acct_encmbrnc_amt    := l_cc_acct_comp_func_amt;
                          l_acct_line_rec.cc_acct_encmbrnc_status := l_encumbrance_status;
                          l_acct_line_rec.cc_acct_encmbrnc_date   := p_accounting_date;
                          l_acct_line_rec.last_update_date        := SYSDATE;
                          l_acct_line_rec.last_update_login       := l_update_login;
                          l_acct_line_rec.last_updated_by         := l_update_by;
      END IF;

    ELSIF (l_cc_headers_rec.cc_state = 'CM') THEN

      IF (p_cbc_on = TRUE)
      THEN
        l_cc_acct_comp_func_amt := l_cc_acct_lines_rec.cc_acct_comp_func_amt;
        l_cc_acct_enc_amt       := l_cc_acct_lines_rec.cc_acct_comp_func_amt;
                          l_acct_line_rec.cc_acct_encmbrnc_amt    := l_cc_acct_comp_func_amt;
                          l_acct_line_rec.cc_acct_encmbrnc_status := l_encumbrance_status;
                          l_acct_line_rec.cc_acct_encmbrnc_date   := p_accounting_date;
                          l_acct_line_rec.last_update_date        := SYSDATE;
                          l_acct_line_rec.last_update_login       := l_update_login;
                          l_acct_line_rec.last_updated_by         := l_update_by;
      END IF;

    ELSIF (l_cc_headers_rec.cc_state = 'CT') THEN

            l_billed_amt      := 0;
            l_func_billed_amt := 0;
                                -- Performance Tuning, Replaced view
                                -- igc_cc_acct_lines_v with
                                -- igc_cc_acct_lines and replaced the line
                                -- below.
        -- SELECT cc_acct_billed_amt , cc_acct_func_billed_amt
                        SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
                               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt
        INTO   l_billed_amt,l_func_billed_amt
        FROM   igc_cc_acct_lines ccal
        WHERE  ccal.cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

      IF (p_currency_code <> l_cc_headers_rec.currency_code) THEN

                            l_CC_Acct_Comp_Func_Amt := l_func_billed_amt;
                                l_CC_Acct_Enc_Amt       := l_func_billed_amt;

                                l_acct_line_rec.cc_acct_entered_amt     := l_billed_amt;
                                l_acct_line_rec.cc_acct_func_amt        := l_func_billed_amt;
        IF (p_cbc_on = TRUE)
        THEN
                                        l_acct_line_rec.cc_acct_encmbrnc_amt    := l_func_billed_amt;
                                        l_acct_line_rec.cc_acct_encmbrnc_status := 'N';
                                        l_acct_line_rec.cc_acct_encmbrnc_date   := p_accounting_date;
        END IF;
                                l_acct_line_rec.last_update_date        := SYSDATE;
                                l_acct_line_rec.last_update_login       := l_update_login;
                                l_acct_line_rec.last_updated_by         := l_update_by;

                                -- 2043221, Bidisha , 19 Oct 2001
                                -- Withheld amount should be set to 0 if the CC
                                -- is completed.
                                l_acct_line_rec.cc_func_withheld_amt    := 0;
                                l_acct_line_rec.cc_ent_withheld_amt     := 0;

      ELSE

                          l_CC_Acct_Comp_Func_Amt := l_billed_amt;
                                l_CC_Acct_Enc_Amt       := l_billed_amt;

                                l_acct_line_rec.cc_acct_entered_amt     := l_billed_amt;
                                l_acct_line_rec.cc_acct_func_amt        := l_billed_amt;
        IF (p_cbc_on = TRUE)
        THEN
                                        l_acct_line_rec.cc_acct_encmbrnc_amt    := l_billed_amt;
                                        l_acct_line_rec.cc_acct_encmbrnc_status := 'N';
                                        l_acct_line_rec.cc_acct_encmbrnc_date   := p_accounting_date;
        END IF;
                                l_acct_line_rec.last_update_date        := SYSDATE;
                                l_acct_line_rec.last_update_login       := l_update_login;
                                l_acct_line_rec.last_updated_by         := l_update_by;

                                -- 2043221, Bidisha , 19 Oct 2001
                                -- Withheld amount should be set to 0 if the CC
                                -- is completed.
                                l_acct_line_rec.cc_func_withheld_amt    := 0;
                                l_acct_line_rec.cc_ent_withheld_amt     := 0;
      END IF;

    ELSE

-- --------------------------------------------------------------------------------------
-- Unknown CC State in the Header record so abort the process for the Account Lines.
-- --------------------------------------------------------------------------------------
                           fnd_message.set_name('IGC', 'IGC_INVALID_CC_HEADER_STATE');
                           fnd_message.set_token('HEADER_STATE', l_cc_headers_rec.cc_state);
                           fnd_message.set_token('CC_NUM_VAL', l_cc_headers_rec.cc_num);
                           IF(g_error_level >= g_debug_level) THEN
                              FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                           END IF;
                           fnd_msg_pub.add;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

                SELECT rowid
                INTO l_row_id
                FROM igc_cc_acct_lines
                WHERE cc_acct_line_id = l_acct_line_rec.cc_acct_line_id;

                Account_Line_Wrapper (p_api_version       => l_api_version,
                                              p_init_msg_list     => FND_API.G_FALSE,
                                              p_commit            => FND_API.G_FALSE,
                                              p_validation_level  => l_validation_level,
                                              x_return_status     => l_return_status,
                                              x_msg_count         => l_msg_count,
                                              x_msg_data          => l_msg_data,
                                              x_rowid             => l_row_id,
                                              p_action_flag       => 'U',
                                              p_cc_acct_lines_rec => l_acct_line_rec,
                                              p_update_flag       => l_update_flag
                                             );

                  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        x_msg_data  := l_msg_data;
                        x_msg_count := l_msg_count;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;
--    END IF;


    OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

    LOOP

      FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

      EXIT WHEN c_payment_forecast%NOTFOUND;

-- ----------------------------------------------------------------------------------
-- Obtain the actual Det PF line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                        OPEN c_det_pf_line;
                        FETCH c_det_pf_line
                        INTO l_det_pf_rec;

                        IF (c_det_pf_line%NOTFOUND) THEN
                           EXIT;
                        END IF;

                        CLOSE c_det_pf_line;

      IF (l_cc_headers_rec.cc_state = 'CL') THEN

        -- Added for Bug 3219208
        -- Entered Amt should be set to 0 when the CC is being
        -- cancelled.
        l_det_pf_rec.cc_det_pf_entered_amt     := 0;
        l_det_pf_rec.cc_det_pf_func_amt        := 0;
        l_cc_det_pf_comp_func_amt := 0;

        l_cc_det_pf_enc_amt := 0;
        -- l_cc_det_pf_comp_func_amt := l_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt;

        l_transaction_date := NULL;

                    IF (p_accounting_date IS NOT NULL) THEN

          IF (l_cc_pmt_fcst_rec.cc_det_pf_date < p_accounting_date)
          THEN
            l_transaction_date      :=  p_accounting_date;
          ELSE
            l_transaction_date      :=  l_cc_pmt_fcst_rec.cc_det_pf_date;
          END IF;
        END IF;

                    IF (p_accounting_date IS NULL) THEN

          IF (l_cc_pmt_fcst_rec.cc_det_pf_date < sysdate)
          THEN
            l_transaction_date      :=  sysdate;
          ELSE
            l_transaction_date      :=  l_cc_pmt_fcst_rec.cc_det_pf_date;

          END IF;
        END IF;

                                l_det_pf_rec.cc_det_pf_encmbrnc_amt    := 0;
                                l_det_pf_rec.cc_det_pf_encmbrnc_status := 'N';
                                l_det_pf_rec.cc_det_pf_date            := l_transaction_date;
                                l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_transaction_date;
                                l_det_pf_rec.last_update_date          := SYSDATE;
                                l_det_pf_rec.last_update_login         := l_update_login;
                                l_det_pf_rec.last_updated_by           := l_update_by;

      ELSIF (l_cc_headers_rec.cc_state = 'PR') THEN

        l_cc_det_pf_enc_amt  := l_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt;
        l_cc_det_pf_comp_func_amt := l_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt;
                        l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_cc_det_pf_comp_func_amt;
                        l_det_pf_rec.cc_det_pf_encmbrnc_status := l_encumbrance_status;
                        l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_pmt_fcst_rec.cc_det_pf_date;
                        l_det_pf_rec.last_update_date          := SYSDATE;
                        l_det_pf_rec.last_update_login         := l_update_login;
                        l_det_pf_rec.last_updated_by           := l_update_by;

      ELSIF (l_cc_headers_rec.cc_state = 'CM') THEN

        l_cc_det_pf_enc_amt       := l_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt;
        l_cc_det_pf_comp_func_amt := l_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt;
                        l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_cc_det_pf_comp_func_amt;
                        l_det_pf_rec.cc_det_pf_encmbrnc_status := l_encumbrance_status;
                        l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_pmt_fcst_rec.cc_det_pf_date;
                        l_det_pf_rec.last_update_date          := SYSDATE;
                        l_det_pf_rec.last_update_login         := l_update_login;
                        l_det_pf_rec.last_updated_by           := l_update_by;

      ELSIF (l_cc_headers_rec.cc_state = 'CT') THEN

                                l_billed_amt      := 0;
                                l_func_billed_amt := 0;

                                -- Performance Tuning, Replaced view
                                -- igc_cc_det_pf_v with
                                -- igc_cc_det_pf and replaced the line
                                -- below.
        -- SELECT cc_det_pf_billed_amt ,cc_det_pf_func_billed_amt
                                SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
                                       IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt
        INTO l_billed_amt, l_func_billed_amt
        FROM igc_cc_det_pf ccdpf
        WHERE ccdpf.cc_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id;

        l_transaction_date := NULL;

                    IF (p_accounting_date IS NOT NULL)
        THEN
          IF (l_cc_pmt_fcst_rec.cc_det_pf_date < p_accounting_date)
          THEN
            l_transaction_date      :=  p_accounting_date;
          ELSE
            l_transaction_date      :=  l_cc_pmt_fcst_rec.cc_det_pf_date;
          END IF;
        END IF;

                    IF (p_accounting_date IS NULL)
        THEN
          IF (l_cc_pmt_fcst_rec.cc_det_pf_date < sysdate)
          THEN
            l_transaction_date      :=  sysdate;
          ELSE
            l_transaction_date      :=  l_cc_pmt_fcst_rec.cc_det_pf_date;

          END IF;
        END IF;

        IF (p_currency_code <> l_cc_headers_rec.currency_code)
        THEN
                                        l_cc_det_pf_comp_func_amt := l_func_billed_amt;
                                        l_cc_det_pf_enc_amt       := l_func_billed_amt;

                                        l_det_pf_rec.cc_det_pf_entered_amt     := l_billed_amt;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_func_billed_amt;
                                        l_det_pf_rec.cc_det_pf_func_amt        := l_func_billed_amt;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_status := 'N';
                                        l_det_pf_rec.cc_det_pf_date            := l_transaction_date;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_transaction_date;
                                        l_det_pf_rec.last_update_date          := SYSDATE;
                                        l_det_pf_rec.last_update_login         := l_update_login;
                                        l_det_pf_rec.last_updated_by           := l_update_by;

                                        -- 2043221, Bidisha , 19 Oct 2001
                                        -- Withheld amount should be set to 0 if the CC
                                        -- is completed.
                                        l_acct_line_rec.cc_func_withheld_amt    := 0;
                                        l_acct_line_rec.cc_ent_withheld_amt     := 0;
        ELSE

                                        l_cc_det_pf_comp_func_amt := l_billed_amt;
                                        l_cc_det_pf_enc_amt       := l_billed_amt;

                                        l_det_pf_rec.cc_det_pf_entered_amt     := l_billed_amt;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_billed_amt;
                                        l_det_pf_rec.cc_det_pf_func_amt        := l_billed_amt;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_status := 'N';
                                        l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_transaction_date;
                                        l_det_pf_rec.last_update_date          := SYSDATE;
                                        l_det_pf_rec.last_update_login         := l_update_login;
                                        l_det_pf_rec.last_updated_by           := l_update_by;

                                        -- 2043221, Bidisha , 19 Oct 2001
                                        -- Withheld amount should be set to 0 if the CC
                                        -- is completed.
                                        l_acct_line_rec.cc_func_withheld_amt    := 0;
                                        l_acct_line_rec.cc_ent_withheld_amt     := 0;
        END IF;

                        ELSE

-- -----------------------------------------------------------------------------
-- Unknown CC State in the Header record for the Det PF update.  Exit Process.
-- -----------------------------------------------------------------------------
                           fnd_message.set_name('IGC', 'IGC_INVALID_CC_HEADER_STATE');
                           fnd_message.set_token('HEADER_STATE', l_cc_headers_rec.cc_state);
                           fnd_message.set_token('CC_NUM_VAL', l_cc_headers_rec.cc_num);
                           IF(g_error_level >= g_debug_level) THEN
                              FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                           END IF;
                           fnd_msg_pub.add;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

                        SELECT rowid
                          INTO l_row_id
                          FROM igc_cc_det_pf
                         WHERE cc_det_pf_line_id = l_det_pf_rec.cc_det_pf_line_id;

                        Det_Pf_Wrapper (p_api_version      => l_api_version,
                                        p_init_msg_list    => FND_API.G_FALSE,
                                        p_commit           => FND_API.G_FALSE,
                                        p_validation_level => l_validation_level,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data,
                                        x_rowid            => l_row_id,
                                        p_action_flag      => 'U',
                                        p_cc_pmt_fcst_rec  => l_det_pf_rec,
                                        p_update_flag      => l_update_flag
                                       );

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                           x_msg_data  := l_msg_data;
                           x_msg_count := l_msg_count;
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;

    END LOOP;

    CLOSE c_payment_forecast;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;

  END LOOP;

  CLOSE c_account_lines;
        IF (c_cc_acct_line%ISOPEN) THEN
           CLOSE c_cc_acct_line;
        END IF;

  IF ((l_cc_headers_rec.cc_state = 'CT') OR
            (l_cc_headers_rec.cc_state = 'CL')) THEN

           l_cc_headers_rec.cc_encmbrnc_status := 'N';
           l_cc_headers_rec.last_update_date   := SYSDATE;
           l_cc_headers_rec.last_update_login  := l_update_login;
           l_cc_headers_rec.last_updated_by    := l_update_by;

  ELSIF ((l_cc_headers_rec.cc_state = 'PR') OR
               (l_cc_headers_rec.cc_state = 'CM')) THEN

           l_cc_headers_rec.cc_encmbrnc_status := l_encumbrance_status;
           l_cc_headers_rec.last_update_date   := SYSDATE;
           l_cc_headers_rec.last_update_login  := l_update_login;
           l_cc_headers_rec.last_updated_by    := l_update_by;

        ELSE

-- -----------------------------------------------------------------------------
-- Unknown CC State in the Header record for the Header update.  Exit Process.
-- -----------------------------------------------------------------------------
           fnd_message.set_name('IGC', 'IGC_INVALID_CC_HEADER_STATE');
           fnd_message.set_token('HEADER_STATE', l_cc_headers_rec.cc_state);
           fnd_message.set_token('CC_NUM_VAL', l_cc_headers_rec.cc_num);
           IF(g_error_level >= g_debug_level) THEN
              FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
           END IF;
           fnd_msg_pub.add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

        SELECT rowid
          INTO l_row_id
          FROM igc_cc_headers
         WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

        l_cc_headers_rec.cc_acct_date := p_accounting_date;

        Header_Wrapper (p_api_version      => l_api_version,
                        p_init_msg_list    => FND_API.G_FALSE,
                        p_commit           => FND_API.G_FALSE,
                        p_validation_level => l_validation_level,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        x_rowid            => l_row_id,
                        p_action_flag      => 'U',
                        p_cc_header_rec    => l_cc_headers_rec,
                        p_update_flag      => l_update_flag
                       );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_msg_data  := l_msg_data;
           x_msg_count := l_msg_count;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

-- -----------------------------------------------------------------------------------
-- Make sure that all cursors used in procedure are closed upon exit.
-- -----------------------------------------------------------------------------------
        IF (c_account_lines%ISOPEN) THEN
           CLOSE c_account_lines;
        END IF;
        IF (c_cc_acct_line%ISOPEN) THEN
           CLOSE c_cc_acct_line;
        END IF;
        IF (c_payment_forecast%ISOPEN) THEN
           CLOSE c_payment_forecast;
        END IF;
        IF (c_det_pf_line%ISOPEN) THEN
           CLOSE c_det_pf_line;
        END IF;

        RETURN;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
                ROLLBACK TO Execute_Rel_Budgetary_Ctrl;
                x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;

                FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
                IF (g_excep_level >=  g_debug_level ) THEN
                    FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
                END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
     THEN
    ROLLBACK TO Execute_Rel_Budgetary_Ctrl;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
          FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data );
                IF (g_excep_level >=  g_debug_level ) THEN
                    FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
                END IF;

  WHEN OTHERS
  THEN
    ROLLBACK TO Execute_Rel_Budgetary_Ctrl;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
                IF ( g_unexp_level >= g_debug_level ) THEN
                   FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                   FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                   FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                   FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                END IF;

END Execute_Rel_Budgetary_Ctrl;

PROCEDURE Insert_Interface_Row(
   p_cc_interface_rec    IN     igc_cc_interface%ROWTYPE,
   x_msg_count           OUT NOCOPY    NUMBER,
   x_msg_data            OUT NOCOPY    VARCHAR2,
   x_return_status       OUT NOCOPY    VARCHAR2
) IS

  l_api_name      CONSTANT VARCHAR2(30)   := 'Insert_Interface_Row';
        l_full_path         VARCHAR2(255);

BEGIN

        l_full_path := g_path || 'Insert_Interface_Row';

        x_return_status    := FND_API.G_RET_STS_SUCCESS;

  INSERT
          INTO igc_cc_interface (
    batch_line_num,
    cc_header_id,
    cc_version_num,
    cc_acct_line_id,
    cc_det_pf_line_id,
    set_of_books_id,
    code_combination_id,
    cc_transaction_date,
    transaction_description,
    encumbrance_type_id,
    currency_code,
    cc_func_dr_amt,
    cc_func_cr_amt,
    je_source_name,
    je_category_name,
    actual_flag,
    budget_dest_flag,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    period_set_name,
    period_name,
    cbc_result_code,
    status_code,
    budget_version_id,
    budget_amt,
    commitment_encmbrnc_amt,
    obligation_encmbrnc_amt,
    funds_available_amt,
    document_type,
    reference_1,
    reference_2,
    reference_3,
    reference_4,
    reference_5,
    reference_6,
    reference_7,
    reference_8,
    reference_9,
    reference_10,
    cc_encmbrnc_date,
    project_line --Bug 6341012 Added this column
         )
  VALUES
         (p_cc_interface_rec.batch_line_num,
    p_cc_interface_rec.cc_header_id,
    p_cc_interface_rec.cc_version_num,
    p_cc_interface_rec.cc_acct_line_id,
    p_cc_interface_rec.cc_det_pf_line_id,
    p_cc_interface_rec.set_of_books_id,
    p_cc_interface_rec.code_combination_id,
    p_cc_interface_rec.cc_transaction_date,
    p_cc_interface_rec.transaction_description,
    p_cc_interface_rec.encumbrance_type_id,
    p_cc_interface_rec.currency_code,
    p_cc_interface_rec.cc_func_dr_amt,
    p_cc_interface_rec.cc_func_cr_amt,
    p_cc_interface_rec.je_source_name,
    p_cc_interface_rec.je_category_name,
    p_cc_interface_rec.actual_flag,
    p_cc_interface_rec.budget_dest_flag,
    p_cc_interface_rec.last_update_date,
    p_cc_interface_rec.last_updated_by,
    p_cc_interface_rec.last_update_login,
    p_cc_interface_rec.creation_date,
    p_cc_interface_rec.created_by,
    p_cc_interface_rec.period_set_name,
    p_cc_interface_rec.period_name,
    p_cc_interface_rec.cbc_result_code,
    p_cc_interface_rec.status_code,
    p_cc_interface_rec.budget_version_id,
    p_cc_interface_rec.budget_amt,
    p_cc_interface_rec.commitment_encmbrnc_amt,
    p_cc_interface_rec.obligation_encmbrnc_amt,
    p_cc_interface_rec.funds_available_amt,
    p_cc_interface_rec.document_type,
    p_cc_interface_rec.reference_1,
    p_cc_interface_rec.reference_2,
    p_cc_interface_rec.reference_3,
    p_cc_interface_rec.reference_4,
    p_cc_interface_rec.reference_5,
    p_cc_interface_rec.reference_6,
    p_cc_interface_rec.reference_7,
    p_cc_interface_rec.reference_8,
    p_cc_interface_rec.reference_9,
    p_cc_interface_rec.reference_10,
    p_cc_interface_rec.cc_encmbrnc_date,
    p_cc_interface_rec.project_line  --Bug 6341012 Added this column
               );

        RETURN;

EXCEPTION

        WHEN OTHERS
        THEN
            x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
               FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                         l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                        p_data  => x_msg_data );
            IF ( g_unexp_level >= g_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
            END IF;

END Insert_Interface_Row;


PROCEDURE Process_Interface_Row(
   p_currency_code             IN VARCHAR2,
   p_cc_headers_rec            IN igc_cc_headers%ROWTYPE,
   p_cc_acct_lines_rec         IN igc_cc_acct_lines_v%ROWTYPE,
   p_cc_pmt_fcst_rec           IN igc_cc_det_pf_v%ROWTYPE,
   p_mode                      IN VARCHAR2,
   p_type                      IN VARCHAR2,
   p_accounting_date           IN DATE,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2
) IS

  l_cc_interface_rec igc_cc_interface%ROWTYPE;
  l_enc_amt          NUMBER;
  l_func_amt         NUMBER;
  l_billed_amt       NUMBER;
  l_func_billed_amt  NUMBER;
  l_unbilled_amt     NUMBER;
        l_return_status    VARCHAR2(1);
  l_api_name         CONSTANT VARCHAR2(30)   := 'Process_Interface_Row';


  l_enc_tax_amt          NUMBER;
  l_func_tax_amt         NUMBER;
  l_unbilled_tax_amt     NUMBER;
        l_msg_count            NUMBER;
        l_msg_data             VARCHAR2(2000);
        l_full_path            VARCHAR2(255);
  /* Added by 6341012 for SLA Uptake */
  l_sob_name VARCHAR2(30);
  P_Error_Code       VARCHAR2(32); /*Bug 6472296 EB Tax uptake - CC*/
  l_taxable_flag     VARCHAR2(2);  /*Bug 6472296 EB Tax uptake - CC*/
BEGIN

        l_full_path := g_path || 'Process_Interface_Row';

        x_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- Bug 1914745, clean up any old records before, more than 2 days old
       -- processing new ones.
       -- DELETE FROM igc_cc_interface
       --WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date((sysdate - interval '2' day), 'DD/MM/YYYY');

        -- Bug 2872060 delete statement above causing compilation probs in oracle8i
        DELETE FROM igc_cc_interface
        WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date(sysdate ,'DD/MM/YYYY') - 2;

  l_cc_interface_rec.cbc_result_code          := NULL;
  l_cc_interface_rec.status_code              := NULL;
  l_cc_interface_rec.budget_version_id        := NULL;
  l_cc_interface_rec.budget_amt               := NULL;
  l_cc_interface_rec.commitment_encmbrnc_amt  := NULL;
  l_cc_interface_rec.obligation_encmbrnc_amt  := NULL;
  l_cc_interface_rec.funds_available_amt      := NULL;
  l_cc_interface_rec.reference_1              := NULL;
  l_cc_interface_rec.reference_2              := NULL;
  l_cc_interface_rec.reference_3              := NULL;
  l_cc_interface_rec.reference_4              := NULL;
  l_cc_interface_rec.reference_5              := NULL;
  l_cc_interface_rec.reference_6              := NULL;
-- ssmales 22/01/02 bug 2124137 - assign value 'EC' to reference_7
--  l_cc_interface_rec.reference_7              := NULL;
        l_cc_interface_rec.reference_7              := 'EC';
  l_cc_interface_rec.reference_8              := NULL;
  l_cc_interface_rec.reference_9              := NULL;
  l_cc_interface_rec.reference_10             := NULL;
  l_cc_interface_rec.encumbrance_type_id      :=  Null; --added by 6341012
  l_cc_interface_rec.cc_encmbrnc_date         := NULL;
  l_cc_interface_rec.document_type            := 'CC';

  l_cc_interface_rec.cc_header_id             :=  p_cc_headers_rec.cc_header_id;
  l_cc_interface_rec.cc_version_num           :=  p_cc_headers_rec.cc_version_num;
  l_cc_interface_rec.set_of_books_id          :=  p_cc_headers_rec.set_of_books_id;
  l_cc_interface_rec.code_combination_id      :=  p_cc_acct_lines_rec.cc_budget_code_combination_id;
  l_cc_interface_rec.currency_code            :=  p_currency_code;
--  l_cc_interface_rec.je_source_name           := 'Contract Commitment';  Bug 6341012 commented this line
  l_cc_interface_rec.actual_flag              :=  'E';
  l_cc_interface_rec.last_update_date         :=  sysdate;
  l_cc_interface_rec.last_updated_by          :=  -1;
  l_cc_interface_rec.last_update_login        :=  -1;
  l_cc_interface_rec.creation_date            :=  sysdate;
  l_cc_interface_rec.created_by               :=  -1;
  l_cc_interface_rec.transaction_description  :=  LTRIM(RTRIM(p_cc_headers_rec.cc_num))
                    || ' ' || rtrim(ltrim(p_cc_acct_lines_rec.cc_acct_desc));

--     Bug 6341012 Added following 2 lines
  l_cc_interface_rec.Event_Id  :=  Null;
  l_cc_interface_rec.Project_line  := 'N';


  IF (p_type = 'A')
  THEN
    l_cc_interface_rec.cc_acct_line_id          :=  p_cc_acct_lines_rec.cc_acct_line_id;
    l_cc_interface_rec.cc_det_pf_line_id        :=  NULL;
    l_cc_interface_rec.cc_transaction_date      :=  p_accounting_date;
    l_cc_interface_rec.budget_dest_flag         :=  'C';
    l_enc_amt                                   :=  NVL(p_cc_acct_lines_rec.cc_acct_encmbrnc_amt,0);
    l_func_amt                                  :=  NVL(p_cc_acct_lines_rec.cc_acct_comp_func_amt,0);
    l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.cc_header_id;
    l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.cc_acct_line_id;
    l_cc_interface_rec.reference_3              :=  p_cc_headers_rec.cc_version_num;
    l_cc_interface_rec.reference_4        :=  p_cc_headers_rec.cc_num;  /* Please check this  by 6341012 */

    IF (p_cc_headers_rec.cc_state = 'CT')
    THEN
                  l_billed_amt       := 0;
                  l_func_billed_amt  := 0;
                  l_func_amt         := 0;

                        -- Performance Tuning, Replaced view
                        -- igc_cc_acct_lines_v with
                        -- igc_cc_acct_lines and replaced the line
                        -- below.
      -- SELECT cc_acct_billed_amt , cc_acct_func_billed_amt, cc_acct_func_amt
                    SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
                               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt,
                                cc_acct_func_amt
      INTO   l_billed_amt, l_func_billed_amt, l_func_amt
      FROM   igc_cc_acct_lines ccal
      WHERE  ccal.cc_acct_line_id = p_cc_acct_lines_rec.cc_acct_line_id;

        l_unbilled_amt       :=  l_func_amt - l_func_billed_amt;

    END IF;

  END IF;

  IF (p_type = 'P')
  THEN
    l_cc_interface_rec.cc_acct_line_id          :=  p_cc_acct_lines_rec.cc_acct_line_id;  --Bug 5464993
--    l_cc_interface_rec.cc_acct_line_id          :=  NULL;
    l_cc_interface_rec.cc_det_pf_line_id        :=  p_cc_pmt_fcst_rec.cc_det_pf_line_id;
    l_cc_interface_rec.cc_transaction_date      :=  p_cc_pmt_fcst_rec.cc_det_pf_date;
    l_cc_interface_rec.budget_dest_flag         :=  'S';
    l_enc_amt                                   :=  NVL(p_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt,0);
    l_func_amt                                  :=  NVL(p_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt,0);
    l_cc_interface_rec.reference_1              :=  p_cc_headers_rec.cc_header_id;
    l_cc_interface_rec.reference_2              :=  p_cc_acct_lines_rec.cc_acct_line_id;
    l_cc_interface_rec.reference_3              :=  p_cc_headers_rec.cc_version_num;

--    Bug 6341012  made reference_4 to be assigned from p_cc_headers_rec.cc_num rather than from p_cc_pmt_fcst.cc_det_pf_line_id
    l_cc_interface_rec.reference_4        :=  p_cc_headers_rec.cc_num;


    IF (p_cc_headers_rec.cc_state = 'CT')
    THEN
      l_billed_amt      := 0;
                        l_func_billed_amt := 0;
                        l_func_amt        := 0;

                        -- Performance Tuning, Replaced view
                        -- igc_cc_acct_lines_v with
                        -- igc_cc_acct_lines and replaced the line
                        -- below.
      -- SELECT cc_det_pf_billed_amt, cc_det_pf_func_billed_amt , cc_det_pf_func_amt
                    SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
                               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
                              ccdpf.cc_det_pf_func_amt
        INTO l_billed_amt, l_func_billed_amt, l_func_amt
      FROM igc_cc_det_pf ccdpf
      WHERE ccdpf.cc_det_pf_line_id = p_cc_pmt_fcst_rec.cc_det_pf_line_id;

        l_unbilled_amt       :=   l_func_amt - l_func_billed_amt;
    END IF;
  END IF;

        /*EB Tax uptake - Bug No : 6472296*/
  -- Bug 2409502, On the 3 amounts, calculate the non recoverable tax
        -- Calculate on the l_enc_amt
/*  igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
    (p_api_version       => 1.0,
    p_init_msg_list     => FND_API.G_FALSE,
    p_commit            => FND_API.G_FALSE,
    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data,
    p_tax_id            => p_cc_acct_lines_rec.tax_id,
    p_amount            => l_enc_amt,
    p_tax_amount        => l_enc_tax_amt);
*/
  l_taxable_flag := nvl(p_cc_acct_lines_rec.cc_acct_taxable_flag,'N');
  /* Bug 6719456 Added one more condition here. Call Tax calculation api only when l_enc_amt <> 0 */
  l_enc_tax_amt := 0;
  IF (l_taxable_flag = 'Y' AND l_enc_amt <> 0) THEN
    IGC_ETAX_UTIL_PKG.Calculate_Tax
      (P_CC_Header_Rec  =>p_cc_headers_rec,
      P_Calling_Mode    =>null,
      P_Amount    =>l_enc_amt,
      P_Line_Id   =>l_cc_interface_rec.cc_acct_line_id,
      P_Tax_Amount    =>l_enc_tax_amt,
      P_Return_Status   =>l_return_status,
      P_Error_Code            =>P_Error_Code);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
        l_enc_amt := l_enc_amt + Nvl(l_enc_tax_amt,0);

        -- Calculate on the l_func_amt
        /*igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
    (p_api_version       => 1.0,
    p_init_msg_list     => FND_API.G_FALSE,
    p_commit            => FND_API.G_FALSE,
    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data,
    p_tax_id            => p_cc_acct_lines_rec.tax_id,
    p_amount            => l_func_amt,
    p_tax_amount        => l_func_tax_amt);
  */
  /* Bug 6719456 Added one more condition here. Call Tax calculation api only when l_func_amt <> 0 */
  l_func_tax_amt := 0;
  IF (l_taxable_flag = 'Y' AND l_func_amt <> 0) THEN
    IGC_ETAX_UTIL_PKG.Calculate_Tax
      (P_CC_Header_Rec  =>p_cc_headers_rec,
      P_Calling_Mode    =>null,
      P_Amount    =>l_func_amt,
      P_Line_Id   =>l_cc_interface_rec.cc_acct_line_id,
      P_Tax_Amount    =>l_func_tax_amt,
      P_Return_Status   =>l_return_status,
      P_Error_Code            =>P_Error_Code);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
        l_func_amt := l_func_amt + Nvl(l_func_tax_amt,0);

        -- Calculate on the l_unbilled_amt
        /*igc_cc_budgetary_ctrl_pkg.calculate_nonrec_tax
    (p_api_version       => 1.0,
    p_init_msg_list     => FND_API.G_FALSE,
    p_commit            => FND_API.G_FALSE,
    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
    x_return_status     => l_return_status,
    x_msg_count         => l_msg_count,
    x_msg_data          => l_msg_data,
    p_tax_id            => p_cc_acct_lines_rec.tax_id,
    p_amount            => l_unbilled_amt,
    p_tax_amount        => l_unbilled_tax_amt);
  */
  /* Bug 6719456 Added one more condition here. Call Tax calculation api only when l_unbilled_amt <> 0 */
  l_unbilled_tax_amt := 0;
  IF (l_taxable_flag = 'Y' AND l_unbilled_amt <> 0) THEN
    IGC_ETAX_UTIL_PKG.Calculate_Tax
      (P_CC_Header_Rec  =>p_cc_headers_rec,
      P_Calling_Mode    =>null,
      P_Amount    =>l_unbilled_amt,
      P_Line_Id   =>l_cc_interface_rec.cc_acct_line_id,
      P_Tax_Amount    =>l_unbilled_tax_amt,
      P_Return_Status   =>l_return_status,
      P_Error_Code            =>P_Error_Code);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;
  /*EB Tax uptake - Bug No : 6472296 END*/
        l_unbilled_amt := l_unbilled_amt + Nvl(l_unbilled_tax_amt,0);


        -- End Bug 2409502, 20 Aug 2002

  IF (p_mode = 'R') OR (p_mode = 'C')
  THEN

    /* Confirmed state */
    IF (p_cc_headers_rec.cc_state = 'CM')
    THEN
            /* Transition to Confirmed state  */
      IF   ( NVL(p_cc_headers_rec.cc_encmbrnc_status,'N') = 'T')
      THEN
        /* Provisional CC has been encumbered */

        IF (NVL(l_enc_amt,0) >= 0)  AND
                                   /* Begin fix for bug 1757526 */
                                   ( ((p_cc_acct_lines_rec.cc_acct_encmbrnc_date IS NOT NULL) AND p_type = 'A') OR
                                      ((p_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date IS NOT NULL) AND p_type = 'P')
                                    )
                                   /* End fix for bug 1757526 */

        THEN

                            /* Reverse COMMITMENT Encumbrance against CBC */

          g_line_num := g_line_num + 1;

          l_cc_interface_rec.batch_line_num           :=  g_line_num;
          l_cc_interface_rec.cc_func_dr_amt           :=  NULL;
          l_cc_interface_rec.cc_func_cr_amt           :=  l_enc_amt;
          --l_cc_interface_rec.je_category_name         := 'Provisional';  Bug 6341012  commented this line

          Insert_Interface_Row(l_cc_interface_rec,
                                                             x_msg_count,
                                                             x_msg_data,
                                                             l_return_status);

                                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                           RAISE FND_API.G_EXC_ERROR;
                                        END IF;

        END IF;

        /* Create ACTUAL Encumbrance against CBC */

              g_line_num := g_line_num + 1;

        l_cc_interface_rec.batch_line_num           :=  g_line_num;
        l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
        l_cc_interface_rec.cc_func_dr_amt           :=  l_func_amt;
        --l_cc_interface_rec.je_category_name         := 'Confirmed';   Bug Number 6341012 commented this line

        Insert_Interface_Row(l_cc_interface_rec,
                                                     x_msg_count,
                                                     x_msg_data,
                                                     l_return_status);

                         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                             RAISE FND_API.G_EXC_ERROR;
                         END IF;

      ELSE
        /*Increase Adjustment */

        IF
             (( NVL(p_cc_headers_rec.cc_encmbrnc_status, 'N')  = 'N') AND
                              ( NVL(l_enc_amt,0) <= NVL(l_func_amt,0) )
                      )
              THEN
                g_line_num := g_line_num + 1;

          l_cc_interface_rec.batch_line_num           :=  g_line_num;
          l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
          l_cc_interface_rec.cc_func_dr_amt           := abs(l_func_amt - l_enc_amt);
          --l_cc_interface_rec.je_category_name         := 'Confirmed'; Bug Number 6341012 commented this line

          Insert_Interface_Row(l_cc_interface_rec,
                                                             x_msg_count,
                                                             x_msg_data,
                                                             l_return_status);
                            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE FND_API.G_EXC_ERROR;
                            END IF;
        ELSIF
             (( NVL(p_cc_headers_rec.cc_encmbrnc_status,'N') = 'N') AND
                              ( NVL(l_enc_amt,0) >= NVL(l_func_amt,0) )
                      )
              THEN
                            /* Decrease Adjustment */

                g_line_num := g_line_num + 1;

          l_cc_interface_rec.batch_line_num           :=  g_line_num;
/* Commented By 6341012 to test confirm state with decrease/increase amount
          l_cc_interface_rec.cc_func_dr_amt           :=  NULL;
          l_cc_interface_rec.cc_func_cr_amt           := abs(l_func_amt - l_enc_amt);
*/
          l_cc_interface_rec.cc_func_dr_amt           := l_func_amt - l_enc_amt;
          l_cc_interface_rec.cc_func_cr_amt           := NULL;
          --l_cc_interface_rec.je_category_name         := 'Confirmed'; Bug Number 6341012 commented this line

          Insert_Interface_Row(l_cc_interface_rec,
                                                             x_msg_count,
                                                             x_msg_data,
                                                             l_return_status);

                            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               RAISE FND_API.G_EXC_ERROR;
                            END IF;
        END IF;
      END IF;
    END IF; /* Confirmed State */

    /* Funds reservation in Provisional state */
    IF (p_cc_headers_rec.cc_state = 'PR')
    THEN
      IF
              ( ( NVL(p_cc_headers_rec.cc_encmbrnc_status,'N') = 'N') AND
                        ( NVL(l_enc_amt,0) <= NVL(l_func_amt,0) )
                 )
            THEN
                          /* Increase Adjustment*/

              g_line_num := g_line_num + 1;

        l_cc_interface_rec.batch_line_num           :=  g_line_num;
        l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
        l_cc_interface_rec.cc_func_dr_amt           :=  abs(l_func_amt - l_enc_amt);
        --l_cc_interface_rec.je_category_name         :=  'Provisional'; Bug Number 6341012 commented this line

        Insert_Interface_Row(l_cc_interface_rec,
                                                     x_msg_count,
                                                     x_msg_data,
                                                     l_return_status);

                                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                   RAISE FND_API.G_EXC_ERROR;
                                END IF;

            ELSIF
              ( ( NVL(p_cc_headers_rec.cc_encmbrnc_status,'N') = 'N') AND
                        ( NVL(l_enc_amt,0) >= NVL(l_func_amt,0) )
                 )
      THEN
                          /* Decrease Adjustment */
              g_line_num := g_line_num + 1;

        l_cc_interface_rec.batch_line_num           :=  g_line_num;
        l_cc_interface_rec.cc_func_dr_amt           :=  NULL;
        l_cc_interface_rec.cc_func_cr_amt           :=  abs(l_func_amt - l_enc_amt);
        --l_cc_interface_rec.je_category_name         :=  'Provisional'; Bug Number 6341012 commented this line

        Insert_Interface_Row(l_cc_interface_rec,
                                                     x_msg_count,
                                                     x_msg_data,
                                                     l_return_status);

                                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                   RAISE FND_API.G_EXC_ERROR;
                                END IF;

      END IF;
    END IF; /* Provisional state */

    /* Un-reserving Funds in Cancelled state */

    IF ( ( p_cc_headers_rec.cc_state = 'CL') AND
               ( NVL(l_enc_amt,0) >= 0)
       )
    THEN
            /* Decrease Adjustment */
      g_line_num := g_line_num + 1;

      l_cc_interface_rec.batch_line_num           :=  g_line_num;
      l_cc_interface_rec.cc_func_cr_amt           :=  NULL;
      l_cc_interface_rec.cc_func_dr_amt           :=  -1 * l_enc_amt;
      --l_cc_interface_rec.je_category_name         :=  'Provisional'; Bug Number 6341012 commented this line

      IF (p_type = 'A')
      THEN
                    l_cc_interface_rec.cc_transaction_date      :=  p_accounting_date;
      END IF;

      IF (p_type = 'P')
      THEN

                    IF (p_accounting_date IS NOT NULL)
        THEN
          IF (p_cc_pmt_fcst_rec.cc_det_pf_date < p_accounting_date)
          THEN
            l_cc_interface_rec.cc_transaction_date      :=  p_accounting_date;
          ELSE
            l_cc_interface_rec.cc_transaction_date      :=  p_cc_pmt_fcst_rec.cc_det_pf_date;
          END IF;
        END IF;

                    IF (p_accounting_date IS NULL)
        THEN
          IF (p_cc_pmt_fcst_rec.cc_det_pf_date < sysdate)
          THEN
            l_cc_interface_rec.cc_transaction_date      :=  sysdate;
          ELSE
            l_cc_interface_rec.cc_transaction_date      :=  p_cc_pmt_fcst_rec.cc_det_pf_date;

          END IF;
        END IF;

      END IF;

      Insert_Interface_Row(l_cc_interface_rec,
                                             x_msg_count,
                                             x_msg_data,
                                             l_return_status);

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;

    END IF; /*Cancel State */

    /* Liquidating Funds in Complete state */
    IF ( (p_cc_headers_rec.cc_state = 'CT') AND
         ( NVL(p_cc_headers_rec.cc_encmbrnc_status,'N') = 'C') AND
               ( nvl(l_enc_amt,0) >= 0)
       )
    THEN
      g_line_num := g_line_num + 1;

      l_cc_interface_rec.batch_line_num           :=  g_line_num;
      l_cc_interface_rec.cc_func_dr_amt           :=  NULL;
      l_cc_interface_rec.cc_func_cr_amt           :=  l_unbilled_amt;
      --l_cc_interface_rec.je_category_name         :=  'Confirmed'; Bug Number 6341012 commented this line

      IF (p_type = 'A')
      THEN
                          l_cc_interface_rec.cc_transaction_date      :=  p_accounting_date;
      END IF;

      IF (p_type = 'P')
      THEN

                    IF (p_accounting_date IS NOT NULL)
        THEN
          IF (p_cc_pmt_fcst_rec.cc_det_pf_date < p_accounting_date)
          THEN
            l_cc_interface_rec.cc_transaction_date      :=  p_accounting_date;
          ELSE
            l_cc_interface_rec.cc_transaction_date      :=  p_cc_pmt_fcst_rec.cc_det_pf_date;
          END IF;
        END IF;

                    IF (p_accounting_date IS NULL)
        THEN
          IF (p_cc_pmt_fcst_rec.cc_det_pf_date < sysdate)
          THEN
            l_cc_interface_rec.cc_transaction_date      :=  sysdate;
          ELSE
            l_cc_interface_rec.cc_transaction_date      :=  p_cc_pmt_fcst_rec.cc_det_pf_date;

          END IF;
        END IF;

      END IF;

      Insert_Interface_Row(l_cc_interface_rec,
                                             x_msg_count,
                                             x_msg_data,
                                             l_return_status);

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;

    END IF; /* Completion of CC */

  END IF; /* p_mode = 'R' */

        RETURN;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
            x_return_status  := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                        p_data  => x_msg_data );

            RETURN;
            IF (g_excep_level >=  g_debug_level ) THEN
               FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
            END IF;

        WHEN OTHERS
        THEN
            x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
               FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                         l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                        p_data  => x_msg_data );

            IF ( g_unexp_level >= g_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
            END IF;
            RETURN;

END Process_Interface_Row;

PROCEDURE Execute_Budgetary_Ctrl
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY      VARCHAR2,
  x_bc_status                     OUT NOCOPY      VARCHAR2 ,
  x_msg_count                     OUT NOCOPY      NUMBER,
  x_msg_data                      OUT NOCOPY      VARCHAR2,
  p_cc_header_id                  IN       NUMBER,
  p_accounting_date               IN       DATE,
  p_mode                          IN       VARCHAR2,
  p_notes                         IN       VARCHAR2
)
IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Execute_Budgetary_Ctrl';
  l_api_version                   CONSTANT NUMBER         :=  1.0;

  l_enable_budg_control_flag      gl_sets_of_books.enable_budgetary_control_flag%TYPE;
  l_cc_bc_enable_flag             igc_cc_bc_enable.cc_bc_enable_flag%TYPE;
  l_req_encumbrance_flag        financials_system_params_all.req_encumbrance_flag%TYPE;
  l_purch_encumbrance_flag      financials_system_params_all.purch_encumbrance_flag%TYPE;
--  l_cc_prov_enc_enable_flag       igc_cc_encmbrnc_ctrls.cc_prov_encmbrnc_enable_flag%TYPE;
--  l_cc_conf_enc_enable_flag       igc_cc_encmbrnc_ctrls.cc_conf_encmbrnc_enable_flag%TYPE;

  l_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
  l_cc_acct_line_id       igc_cc_acct_lines_v.cc_acct_line_id%TYPE;
  l_cc_det_pf_line_id       igc_cc_det_pf_v.cc_det_pf_line_id%TYPE;
  l_budget_dest_flag        igc_cc_interface.budget_dest_flag%TYPE;
  l_cc_transaction_date   igc_cc_interface.cc_transaction_date%TYPE;

  l_cc_acct_comp_func_amt     igc_cc_acct_lines_v.cc_acct_comp_func_amt%TYPE;
  l_cc_acct_enc_amt         igc_cc_acct_lines_v.cc_acct_encmbrnc_amt%TYPE;

  l_cc_det_pf_comp_func_amt   igc_cc_det_pf_v.cc_det_pf_comp_func_amt%TYPE;
  l_cc_det_pf_enc_amt         igc_cc_det_pf_v.cc_det_pf_encmbrnc_amt%TYPE;

  l_flag        BOOLEAN := FALSE;
  l_cbc_on      BOOLEAN := FALSE;

  l_rowid                         VARCHAR2(18);

  l_batch_result_code           VARCHAR2(3);
  l_encumbrance_on                VARCHAR2(1);
  l_encumbrance_status            VARCHAR2(1);
  l_bc_return_status              VARCHAR2(2);
  l_bc_success                    BOOLEAN;

  l_billed_amt                    NUMBER;
  l_func_billed_amt               NUMBER;
  l_interface_row_count       NUMBER;
  l_org_id                    NUMBER;
  l_sob_id                  NUMBER;
  l_cc_state                  VARCHAR2(2);

  l_cc_headers_rec                igc_cc_headers%ROWTYPE;
  l_cc_acct_lines_rec             igc_cc_acct_lines_v%ROWTYPE;
  l_cc_pmt_fcst_rec               igc_cc_det_pf_v%ROWTYPE;
  l_cc_interface_rec              igc_cc_interface%ROWTYPE;

  l_debug                   VARCHAR2(1);

  l_currency_code               gl_sets_of_books.currency_code%TYPE;
  l_error_message                 VARCHAR2(2000);

  l_cc_apprvl_status_old          igc_cc_headers.cc_apprvl_status%TYPE;
  l_encumbrance_status_old        VARCHAR2(1);
    -- bug 2689651, start 1
    l_pa_mode                       VARCHAR2(1);
    l_unencumbered_amount           NUMBER;
    l_project_id                    NUMBER;
    -- bug 2689651,  end 1

-- -------------------------------------------------------------------------
-- Variables to be used in calls to the table wrapper procedures.
-- -------------------------------------------------------------------------
    l_validation_level              NUMBER;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    l_row_id                        VARCHAR2(18);
    l_update_flag                   VARCHAR2(1);
    l_update_login                  igc_cc_acct_lines.last_update_login%TYPE;
    l_update_by                     igc_cc_acct_lines.last_updated_by%TYPE;

-- -------------------------------------------------------------------------
-- Record definitions to be used for CURSORS getting single record for
-- the table wrappers.  These record definitions are NOT the same as the
-- ones above when getting data from the views.
-- -------------------------------------------------------------------------
    l_det_pf_rec                    igc_cc_det_pf%ROWTYPE;
    l_acct_line_rec                 igc_cc_acct_lines%ROWTYPE;

    e_cc_invalid_set_up             EXCEPTION;
  e_no_budgetary_control          EXCEPTION;
  e_cc_not_found                  EXCEPTION;
  e_invalid_mode                  EXCEPTION;
  e_bc_execution                  EXCEPTION;
  e_update                        EXCEPTION;
  e_delete                        EXCEPTION;
  e_sbc_data                      EXCEPTION;
  e_sbc_data1                     EXCEPTION;
  e_cbc_data                      EXCEPTION;
  e_cbc_data1                     EXCEPTION;
  e_process_row                   EXCEPTION;
  e_update_cc_tables              EXCEPTION;
  e_others                      EXCEPTION;
  e_check_budg_ctrl             EXCEPTION;

  /*Budgetary Control Interface   */
  CURSOR c_cc_interface(t_cc_header_id NUMBER) IS
  SELECT distinct cc_header_id, cc_acct_line_id, cc_det_pf_line_id, budget_dest_flag, cc_transaction_date
  FROM igc_cc_interface
  WHERE cc_header_id =  t_cc_header_id AND
        actual_flag = 'E';

        /* Current year payment forecast lines only */

  /* Contract Commitment detail payment forecast  */
  CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS
        -- Performance Tuning, Replaced view igc_cc_det_pf_v with
        -- igc_cc_det_pf
  -- SELECT *
  -- FROM igc_cc_det_pf_v
  -- WHERE cc_acct_line_id =  t_cc_acct_line_id;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id, NVL(ccdpf.cc_det_pf_entered_amt,0) ) -
               NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) ) cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
        WHERE ccdpf.cc_acct_line_id =  t_cc_acct_line_id;

               /* Current year payment forecast lines only */

  /* Contract Commitment account lines  */

-- Bug 2885953 - cursor below amended for performance enhancements
--    CURSOR c_account_lines(t_cc_header_id NUMBER) IS
--    SELECT *
--        FROM  igc_cc_acct_lines_v ccac
--        WHERE ccac.cc_header_id = t_cc_header_id;
  CURSOR c_account_lines(t_cc_header_id NUMBER) IS
  SELECT ccac.ROWID,
               ccac.cc_header_id,
               NULL org_id,
               NULL cc_type,
               NULL cc_type_code,
               NULL cc_num,
               ccac.cc_acct_line_id,
               ccac.cc_acct_line_num,
               ccac.cc_acct_desc,
               ccac.parent_header_id,
               ccac.parent_acct_line_id,
               NULL parent_cc_acct_line_num,
               NULL cc_budget_acct_desc,
               ccac.cc_budget_code_combination_id,
               NULL cc_charge_acct_desc,
               ccac.cc_charge_code_combination_id,
               ccac.cc_acct_entered_amt,
               ccac.cc_acct_func_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_func_billed_amt,
               ccac.cc_acct_encmbrnc_amt,
               (IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0)) - NVL(ccac.cc_acct_encmbrnc_amt,0)) cc_acct_unencmrd_amt,
               ccac.cc_acct_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0))
               cc_acct_comp_func_amt,
               NULL project_number,
               ccac.project_id,
               NULL task_number,
               ccac.task_id,
               ccac.expenditure_type,
               NULL expenditure_org_name,
               ccac.expenditure_org_id,
               ccac.expenditure_item_date,
               ccac.cc_acct_taxable_flag,
               NULL tax_name,
               ccac.tax_id,
               ccac.cc_acct_encmbrnc_status,
               ccac.cc_acct_encmbrnc_date,
               ccac.context,
               ccac.attribute1,
               ccac.attribute2,
               ccac.attribute3,
               ccac.attribute4,
               ccac.attribute5,
               ccac.attribute6,
               ccac.attribute7,
               ccac.attribute8,
               ccac.attribute9,
               ccac.attribute10,
               ccac.attribute11,
               ccac.attribute12,
               ccac.attribute13,
               ccac.attribute14,
               ccac.attribute15,
               ccac.created_by,
               ccac.creation_date,
               ccac.last_updated_by,
               ccac.last_update_date,
               ccac.last_update_login,
               ccac.cc_func_withheld_amt,
               ccac.cc_ent_withheld_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
               ccac.Tax_Classif_Code
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;

-- -------------------------------------------------------------------------
-- Cursors used for obtaining a single line to be passed into the wrapper
-- functions for updating, inserting, deleting records from tables.
-- -------------------------------------------------------------------------
        CURSOR c_cc_acct_line IS
          SELECT *
            FROM igc_cc_acct_lines
           WHERE cc_acct_line_id = l_cc_acct_line_id;

        CURSOR c_det_pf_line IS
          SELECT *
            FROM igc_cc_det_pf
           WHERE cc_det_pf_line_id = l_cc_det_pf_line_id;

        CURSOR c_cc_acct_line_rec_input IS
          SELECT *
            FROM igc_cc_acct_lines
           WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

        CURSOR c_det_pf_line_rec_input IS
          SELECT *
            FROM igc_cc_det_pf
           WHERE cc_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id;

   -- bug 2689651,  start 2
   CURSOR c_unencumbered_amount(cp_cc_header_id   igc_cc_headers.cc_header_id%TYPE)
   IS
   SELECT SUM(( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(cp_cc_header_id, NVL(cc_det_pf_entered_amt,0) ) -
               NVL(cc_det_pf_encmbrnc_amt,0) )) cc_det_pf_unencmbrd_amt
   FROM igc_cc_det_pf
   WHERE cc_acct_line_id IN (SELECT cc_acct_line_id
                             FROM igc_cc_acct_lines
                             WHERE cc_header_id = cp_cc_header_id);
   -- bug 2689651,  end 2

   l_full_path         VARCHAR2(255);
BEGIN
    l_full_path := g_path || 'Execute_Budgetary_Ctrl';

  SAVEPOINT Execute_Budgetary_Ctrl1;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status           := FND_API.G_RET_STS_SUCCESS;
  x_bc_status               := FND_API.G_TRUE;
  g_line_num                := 0;
--        l_debug                   := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--        IF (l_debug = 'Y') THEN
    IF (g_debug_mode = 'Y') THEN
           l_debug := FND_API.G_TRUE;
    ELSE
           l_debug := FND_API.G_FALSE;
    END IF;
--        IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);
    l_validation_level        := p_validation_level;
    l_update_login            := FND_GLOBAL.LOGIN_ID;
    l_update_by               := FND_GLOBAL.USER_ID;

  IF ( (p_mode <> 'C') AND (p_mode <> 'R') )
  THEN
    fnd_message.set_name('IGC', 'IGC_CC_INVALID_MODE');
    fnd_message.set_token('MODE', p_mode,TRUE);
        IF(g_error_level >= g_debug_level) THEN
                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
        END IF;
    fnd_msg_pub.add;
      RAISE E_INVALID_MODE;
  END IF;

    BEGIN
    SELECT *
    INTO l_cc_headers_rec
    FROM igc_cc_headers
    WHERE cc_header_id = p_cc_header_id;

    l_cc_apprvl_status_old   := l_cc_headers_rec.cc_apprvl_status;
                l_encumbrance_status_old := l_cc_headers_rec.cc_encmbrnc_status;
  EXCEPTION
    WHEN OTHERS
    THEN
      fnd_message.set_name('IGC', 'IGC_CC_NOT_FOUND');
      fnd_message.set_token('CC_NUM', to_char(p_cc_header_id),TRUE);
                    IF(g_error_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;
      RAISE E_CC_NOT_FOUND;

  END;

  IF (l_cc_apprvl_status_old <> 'IP')
  THEN
           l_cc_headers_rec.cc_apprvl_status   := 'IP';
           l_cc_headers_rec.last_update_date   := SYSDATE;
           l_cc_headers_rec.last_update_login  := l_update_login;
           l_cc_headers_rec.last_updated_by    := l_update_by;

           SELECT rowid
           INTO l_row_id
           FROM igc_cc_headers
           WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

           Header_Wrapper (p_api_version      => l_api_version,
                           p_init_msg_list    => FND_API.G_FALSE,
                           p_commit           => FND_API.G_FALSE,
                           p_validation_level => l_validation_level,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           x_rowid            => l_row_id,
                           p_action_flag      => 'U',
                           p_cc_header_rec    => l_cc_headers_rec,
                           p_update_flag      => l_update_flag
                          );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_msg_data  := l_msg_data;
              x_msg_count := l_msg_count;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                 FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                           l_api_name);
              END IF;
              RAISE E_UPDATE;
           END IF;

  END IF;

  IF (l_cc_headers_rec.cc_type <> 'R')
  THEN
    BEGIN
      DELETE igc_cc_interface
      WHERE cc_header_id = p_cc_header_id AND
            actual_flag = 'E';
    EXCEPTION
      WHEN OTHERS THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                            l_api_name);
               END IF;
               IF ( g_unexp_level >= g_debug_level ) THEN
                  FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                  FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                  FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                  FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
               END IF;
               RAISE E_DELETE;
    END;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

  SAVEPOINT Execute_Budgetary_Ctrl2;

  l_org_id   := l_cc_headers_rec.org_id;
  l_sob_id   := l_cc_headers_rec.set_of_books_id;
  l_cc_State := l_cc_headers_rec.cc_state;

  Check_Budgetary_Ctrl_On(1.0,
                            FND_API.G_FALSE,
                            FND_API.G_VALID_LEVEL_FULL,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_org_id,
                            l_sob_id,
                            l_cc_state,
                            l_encumbrance_on
                            );

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
  THEN
    IF (l_encumbrance_on = FND_API.G_FALSE)
    THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_bc_status     := FND_API.G_TRUE;
      RETURN;
    END IF;
  ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                     l_api_name);
        END IF;
    RAISE E_CHECK_BUDG_CTRL;
  END IF;

    BEGIN
    SELECT  enable_budgetary_control_flag,currency_code
    INTO    l_enable_budg_control_flag, l_currency_code
    FROM    gl_sets_of_books
    WHERE   set_of_books_id = l_cc_headers_rec.set_of_books_id;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      fnd_message.set_name('IGC', 'IGC_CC_INVALID_GL_DATA');
                    IF(g_error_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;
      RAISE E_CC_INVALID_SET_UP;
  END;

  /* Check whether CBC is turned on */
  BEGIN
    l_cbc_on := FALSE;
    l_cc_bc_enable_flag := 'N';

    SELECT  cc_bc_enable_flag
    INTO    l_cc_bc_enable_flag
    FROM    igc_cc_bc_enable
    WHERE   set_of_books_id = l_cc_headers_rec.set_of_books_id;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      l_cc_bc_enable_flag := 'N';
  END;

  IF (NVL(l_cc_bc_enable_flag,'N') = 'Y')
  THEN
    l_cbc_on := TRUE;
  END IF;

  /* Begin fix for bug 1509057 */
  IF (l_cc_headers_rec.cc_state = 'PR')
  THEN
    l_encumbrance_status := 'P';
  END IF;

  IF (l_cc_headers_rec.cc_state = 'CL')
  THEN
    l_encumbrance_status := 'N';
  END IF;

  IF (l_cc_headers_rec.cc_state = 'CM')
  THEN
    l_encumbrance_status := 'C';
  END IF;

        IF (l_cc_headers_rec.cc_state = 'CT')
  THEN
    l_encumbrance_status := 'N';
  END IF;

  /* End fix for bug 1509057 */
  IF (l_cc_headers_rec.cc_type = 'R')
  THEN
    Execute_Rel_Budgetary_Ctrl(1.0,
                                   FND_API.G_FALSE,
                                   FND_API.G_FALSE,
                                   FND_API.G_VALID_LEVEL_FULL,
                                   x_return_status,
                                   x_msg_count,
                                   x_msg_data,
                                   p_cc_header_id,
                                   p_accounting_date,
                                   l_cbc_on,
                                   l_currency_code
                                   );

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
      x_bc_status     := FND_API.G_TRUE;
    ELSE
      x_bc_status     := FND_API.G_FALSE;
    END IF;

    IF (l_cc_apprvl_status_old <> 'IP')
    THEN
      /* begin fix for bug 1567120 */
            BEGIN
        SELECT *
        INTO l_cc_headers_rec
        FROM igc_cc_headers
                    WHERE cc_header_id = p_cc_header_id;
          EXCEPTION
            WHEN OTHERS THEN
          fnd_message.set_name('IGC', 'IGC_CC_NOT_FOUND');
          fnd_message.set_token('CC_NUM', to_char(p_cc_header_id),TRUE);
                    IF(g_error_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                    END IF;
          fnd_msg_pub.add;
          RAISE E_CC_NOT_FOUND;
      END;

      /* end fix for bug 1567120 */
            l_cc_headers_rec.cc_apprvl_status   := l_cc_apprvl_status_old;
            l_cc_headers_rec.last_update_date   := SYSDATE;
            l_cc_headers_rec.last_update_login  := l_update_login;
            l_cc_headers_rec.last_updated_by    := l_update_by;

            SELECT rowid
            INTO l_row_id
            FROM igc_cc_headers
            WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

            Header_Wrapper (p_api_version      => l_api_version,
                            p_init_msg_list    => FND_API.G_FALSE,
                            p_commit           => FND_API.G_FALSE,
                            p_validation_level => l_validation_level,
                            x_return_status    => l_return_status,
                            x_msg_count        => l_msg_count,
                            x_msg_data         => l_msg_data,
                            x_rowid            => l_row_id,
                            p_action_flag      => 'U',
                            p_cc_header_rec    => l_cc_headers_rec,
                            p_update_flag      => l_update_flag
                            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_data  := l_msg_data;
                x_msg_count := l_msg_count;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                      THEN
                         FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                   l_api_name);
                      END IF;
                      RAISE E_UPDATE;
                   END IF;

                   IF FND_API.To_Boolean(p_commit)
                   THEN
                      COMMIT WORK;
                   END IF;

    END IF;
    RETURN;
  END IF;

  SAVEPOINT Execute_Budgetary_Ctrl3;
  /* Process Interface Rows */
  OPEN c_account_lines(p_cc_header_id);
  LOOP
    FETCH c_account_lines INTO l_cc_acct_lines_rec;
    EXIT WHEN c_account_lines%NOTFOUND;
      IF ( (l_cbc_on = TRUE)  AND (l_enable_budg_control_flag = 'Y') )
    THEN
      IF ( ( (NVL(l_cc_acct_lines_rec.cc_acct_encmbrnc_status,'N') <> 'P') AND
             (l_cc_headers_rec.cc_state = 'PR')
            )
            OR
            ( ( (NVL(l_cc_acct_lines_rec.cc_acct_encmbrnc_status,'N') <> 'C') OR
                (NVL(l_cc_acct_lines_rec.cc_acct_encmbrnc_status,'N')  = 'T') OR
                (NVL(l_cc_acct_lines_rec.cc_acct_encmbrnc_status,'N')  = 'N')
                                 )
                                 AND
              (l_cc_headers_rec.cc_state = 'CM')
             )
            OR
             ( (l_cc_headers_rec.cc_state = 'CL') AND
                                 /* Fix for bug 1722709 */
                                 (l_cc_acct_lines_rec.cc_acct_encmbrnc_date IS NOT NULL)
                               )
            OR
             (l_cc_headers_rec.cc_state = 'CT')
          )
      THEN
        BEGIN
              Process_Interface_Row(
                                          l_currency_code,
                                          l_cc_headers_rec,
                                          l_cc_acct_lines_rec,
                                          l_cc_pmt_fcst_rec,
                                          p_mode,
                                          'A',
                                          p_accounting_date,
                                          x_msg_count,
                                          x_msg_data,
                                          l_return_status);
                     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                         THEN
                             FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                       l_api_name);
                         END IF;
                         RAISE E_PROCESS_ROW;
                     END IF;
        END;
      END IF;
    END IF;

    OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);
    LOOP
      FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;
      EXIT WHEN c_payment_forecast%NOTFOUND;
      IF (l_enable_budg_control_flag = 'Y')
      THEN
        IF ( ( (NVL(l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_status,'N') <> 'P') AND
                     (l_cc_headers_rec.cc_state = 'PR')
                                      )
              OR
                    ( ( (NVL(l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_status,'N') <> 'C') OR
                        (NVL(l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_status,'N')  = 'T') OR
                        (NVL(l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_status,'N')  = 'N')
                                         ) AND
                       (l_cc_headers_rec.cc_state = 'CM')
                    )
              OR
                          (l_cc_headers_rec.cc_state = 'CT')
                    OR
                          ( (l_cc_headers_rec.cc_state = 'CL') AND
                                        /* Fix for bug 1722709 */
                                        (l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date IS NOT NULL)
                                      )
                        )
        THEN
          BEGIN
                   Process_Interface_Row(
                                               l_currency_code,
                                               l_cc_headers_rec,
                                               l_cc_acct_lines_rec,
                                               l_cc_pmt_fcst_rec,
                                               p_mode,
                                               'P',
                                               p_accounting_date,
                                               x_msg_count,
                                               x_msg_data,
                                               l_return_status);

                           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                              THEN
                                 FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                           l_api_name);
                              END IF;
                              RAISE E_PROCESS_ROW;
                           END IF;
          END;
        END IF;
          END IF;
    END LOOP;
    CLOSE c_payment_forecast;
  END LOOP;
  CLOSE c_account_lines;

-- COMMIT is suppose to be done here.....  IF NOT then Bug 1543646 will happen.
    COMMIT WORK;

  l_interface_row_count := 0;

  select count(*)
  INTO l_interface_row_count
  FROM igc_cc_interface
  WHERE cc_header_id = p_cc_header_id;

  SAVEPOINT Execute_Budgetary_Ctrl4;
  /* Execute budgetary control */

    BEGIN
        IF (l_interface_row_count <> 0)
    THEN
      l_batch_result_code := NULL;

            -- bug 2689651, start 3
            OPEN c_unencumbered_amount(l_cc_headers_rec.cc_header_id);
            FETCH c_unencumbered_amount INTO l_unencumbered_amount;
            IF c_unencumbered_amount%NOTFOUND THEN
               l_unencumbered_amount := -1;
            END IF;
            CLOSE c_unencumbered_amount;
            -- set the pa mode based on whether a payment shift has happened
            -- if yes mode is F else default p_mode
            l_pa_mode := p_mode;
            IF (p_mode <> 'C' AND l_unencumbered_amount = 0) THEN
               l_pa_mode := 'F';
            ELSE
               l_pa_mode := p_mode;
            END IF;
            -- bug 2689651,  end 3

            -- The call to IGCFCK updated to IGCPAFCK for bug 1844214.
            -- Bidisha S , 21 June 2001
            -- bug 2689651, change p_mode to l_pa_mode
--      l_bc_success := IGC_CBC_FUNDS_CHECKER.IGCFCK( p_sobid      =>  l_cc_headers_rec.set_of_books_id,
      l_bc_success := IGC_CBC_PA_BC_PKG.IGCPAFCK( p_sobid             =>  l_cc_headers_rec.set_of_books_id,
                                              p_header_id         =>  l_cc_headers_rec.cc_header_id,
                                                        p_mode              => l_pa_mode,
                                                        p_actual_flag       =>  'E',
                                        p_ret_status        =>  l_bc_return_status,
                                        p_batch_result_code => l_batch_result_code,
                                        p_doc_type          =>  'CC',
                                        p_debug             =>   l_debug,
                                          p_conc_proc         =>   FND_API.G_FALSE);
             IF l_bc_success = TRUE  --No fatal errors
              AND substr(l_bc_return_status,1,1) IN ('N','S','A') --CBC successfull
                    AND substr(l_bc_return_status,2,1) IN ('N','S','A') --SBC successfull
                        AND l_interface_row_count <> 0 -- remained from the previous version ????
             THEN
                 x_bc_status     := FND_API.G_TRUE;
             ELSE
                 x_bc_status     := FND_API.G_FALSE;
             END IF;

        ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_bc_status     := FND_API.G_TRUE;
        END IF;

  /*EXCEPTION
    WHEN OTHERS
    THEN
      RAISE E_OTHERS;*/
    END;

--        IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
--           g_debug_msg := ' Finished call to IGCFCK ';
           g_debug_msg := ' Finished call to IGCPAFCK ';
           Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;

  /* Budgetary Control Successfully executed */
  /* Update CC Tables with feedback from igc_cc_interface */

  /* If mode = Reservation then update CC Tables encumbrance status, encumbered_amount */

  BEGIN

  IF ( (p_mode = 'R') AND (x_bc_status = FND_API.G_TRUE) AND (l_interface_row_count <> 0) )
  THEN

    OPEN c_cc_interface(p_cc_header_id);

    LOOP
      FETCH c_cc_interface
                         INTO l_cc_header_id,
                              l_cc_acct_line_id,
                              l_cc_det_pf_line_id,
            l_budget_dest_flag,
                              l_cc_transaction_date;

--                        IF (IGC_MSGS_PKG.g_debug_mode) THEN
                        IF (g_debug_mode = 'Y') THEN
                           g_debug_msg := ' Fetching Interface records ';
                           Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                        END IF;

      EXIT WHEN c_cc_interface%NOTFOUND;

--                        IF (IGC_MSGS_PKG.g_debug_mode) THEN
                        IF (g_debug_mode = 'Y') THEN
                           g_debug_msg := ' Check acct line id 1.......';
                           Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                        END IF;

      /* Update CC Tables with the feedback */
/*      IF ((l_cc_acct_line_id IS NOT NULL) AND
            (l_budget_dest_flag = 'C'))
      THEN */--Bug 5464993. Update amounts even when cbc is disabled

                                -- Performance Tuning, Replaced view
                                -- igc_cc_acct_lines_v with
                                -- igc_cc_acct_lines and replaced the line
                                -- below.
        -- SELECT cc_acct_comp_func_amt
                        SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0)) cc_acct_comp_func_amt
      INTO  l_cc_acct_comp_func_amt
      FROM igc_cc_acct_lines ccal
      WHERE ccal.cc_acct_line_id = l_cc_acct_line_id;

--                                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                        IF (g_debug_mode = 'Y') THEN
                              g_debug_msg := ' Getting CC_ACCT_COMP_FUNC_AMT';
                              Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                        END IF;

-- ----------------------------------------------------------------------------------
-- Obtain the actual account line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                        OPEN c_cc_acct_line;
                        FETCH c_cc_acct_line
                        INTO l_acct_line_rec;

                        IF (c_cc_acct_line%NOTFOUND) THEN
                              EXIT;
                        END IF;

                        CLOSE c_cc_acct_line;

      IF (l_cc_headers_rec.cc_state = 'CL') THEN

        l_cc_acct_enc_amt  := 0;

                                        -- Added for Bug 3219208
                                        -- Entered Amt should be set to 0 when the CC is being
                                        -- cancelled.
        l_acct_line_rec.cc_acct_entered_amt     := 0;
                  l_acct_line_rec.cc_acct_func_amt        := 0;

                IF l_budget_dest_flag = 'C' THEN
                                        l_acct_line_rec.cc_acct_encmbrnc_amt    := 0;
                                        l_acct_line_rec.cc_acct_encmbrnc_status := 'N';
                                        l_acct_line_rec.cc_acct_encmbrnc_date   := l_cc_transaction_date;
        END IF;
                                l_acct_line_rec.last_update_date        := SYSDATE;
                                l_acct_line_rec.last_update_login       := l_update_login;
                                l_acct_line_rec.last_updated_by         := l_update_by;

      ELSIF (l_cc_headers_rec.cc_state = 'PR') THEN

                IF l_budget_dest_flag = 'C' THEN
          l_cc_acct_enc_amt  := l_cc_acct_comp_func_amt;
                                  l_acct_line_rec.cc_acct_encmbrnc_amt    := l_cc_acct_comp_func_amt;
                                  l_acct_line_rec.cc_acct_encmbrnc_status := l_encumbrance_status;
                                  l_acct_line_rec.cc_acct_encmbrnc_date   := l_cc_transaction_date;
                                  l_acct_line_rec.last_update_date        := SYSDATE;
                            l_acct_line_rec.last_update_login       := l_update_login;
                                  l_acct_line_rec.last_updated_by         := l_update_by;
        END IF;

      ELSIF (l_cc_headers_rec.cc_state = 'CM') THEN

                IF l_budget_dest_flag = 'C' THEN
          l_cc_acct_enc_amt  := l_cc_acct_comp_func_amt;
                                        l_acct_line_rec.cc_acct_encmbrnc_amt    := l_cc_acct_comp_func_amt;
                                        l_acct_line_rec.cc_acct_encmbrnc_status := l_encumbrance_status;
                                        l_acct_line_rec.cc_acct_encmbrnc_date   := l_cc_transaction_date;
                                  l_acct_line_rec.last_update_date        := SYSDATE;
                                  l_acct_line_rec.last_update_login       := l_update_login;
                                  l_acct_line_rec.last_updated_by         := l_update_by;
        END IF;

      ELSIF (l_cc_headers_rec.cc_state = 'CT') THEN

              l_billed_amt      := 0;
              l_func_billed_amt := 0;

                                -- Performance Tuning, Replaced view
                                -- igc_cc_acct_lines_v with
                                -- igc_cc_acct_lines and replaced the line
                                -- below.
        -- SELECT cc_acct_billed_amt ,cc_acct_func_billed_amt
                              SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
                                   IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt
        INTO   l_billed_amt, l_func_billed_amt
        FROM   igc_cc_acct_lines ccal
        WHERE  ccal.cc_acct_line_id = l_cc_acct_line_id;

        IF (l_currency_code <> l_cc_headers_rec.currency_code)
        THEN
                                  l_cc_acct_comp_func_Amt := l_func_billed_amt;
                                  l_cc_acct_enc_Amt       := l_func_billed_amt;
                                        l_acct_line_rec.cc_acct_entered_amt     := l_billed_amt;
                                        l_acct_line_rec.cc_acct_func_amt        := l_func_billed_amt;
                  IF l_budget_dest_flag = 'C' THEN
                                                l_acct_line_rec.cc_acct_encmbrnc_amt    := l_func_billed_amt;
                                                l_acct_line_rec.cc_acct_encmbrnc_status := 'N';
                                          l_acct_line_rec.cc_acct_encmbrnc_date   := l_cc_transaction_date;
          END IF;
                                        l_acct_line_rec.last_update_date        := SYSDATE;
                                        l_acct_line_rec.last_update_login       := l_update_login;
                                        l_acct_line_rec.last_updated_by         := l_update_by;

                                                -- 2043221, Bidisha , 19 Oct 2001
                                                -- Withheld amount should be set to 0 if the CC
                                                -- is completed.
                                        l_acct_line_rec.cc_func_withheld_amt    := 0;
                                        l_acct_line_rec.cc_ent_withheld_amt     := 0;
        ELSE
                                  l_cc_acct_comp_func_Amt := l_func_billed_amt;
                                  l_cc_acct_enc_Amt       := l_func_billed_amt;
                                        l_acct_line_rec.cc_acct_entered_amt     := l_func_billed_amt;
                                        l_acct_line_rec.cc_acct_func_amt        := l_func_billed_amt;

                  IF l_budget_dest_flag = 'C' THEN
                                                l_acct_line_rec.cc_acct_encmbrnc_amt    := l_func_billed_amt;
                                          l_acct_line_rec.cc_acct_encmbrnc_status := 'N';
                                          l_acct_line_rec.cc_acct_encmbrnc_date   := l_cc_transaction_date;
          END IF;
                                        l_acct_line_rec.last_update_date        := SYSDATE;
                                        l_acct_line_rec.last_update_login       := l_update_login;
                                        l_acct_line_rec.last_updated_by         := l_update_by;

                                                -- 2043221, Bidisha , 19 Oct 2001
                                                -- Withheld amount should be set to 0 if the CC
                                                -- is completed.
                                        l_acct_line_rec.cc_func_withheld_amt    := 0;
                                        l_acct_line_rec.cc_ent_withheld_amt     := 0;
        END IF;

                        ELSE

-- -----------------------------------------------------------------------------
-- Unknown CC State in the Header record for the Acct Line update.  Exit Process.
-- -----------------------------------------------------------------------------
--                                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                IF (g_debug_mode = 'Y') THEN
                                      g_debug_msg := ' Bad CC State for Update';
                                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                END IF;
                                RAISE E_UPDATE_CC_TABLES;

      END IF;

                         SELECT rowid
                         INTO l_row_id
                         FROM igc_cc_acct_lines
                         WHERE cc_acct_line_id = l_acct_line_rec.cc_acct_line_id;

--                                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                         IF (g_debug_mode = 'Y') THEN
                               g_debug_msg := ' Updating Acct Line ';
                               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                         END IF;

                         Account_Line_Wrapper (p_api_version       => l_api_version,
                                               p_init_msg_list     => FND_API.G_FALSE,
                                               p_commit            => FND_API.G_FALSE,
                                               p_validation_level  => l_validation_level,
                                               x_return_status     => l_return_status,
                                               x_msg_count         => l_msg_count,
                                               x_msg_data          => l_msg_data,
                                               x_rowid             => l_row_id,
                                               p_action_flag       => 'U',
                                               p_cc_acct_lines_rec => l_acct_line_rec,
                                               p_update_flag       => l_update_flag
                                              );

                         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               x_msg_data  := l_msg_data;
                               x_msg_count := l_msg_count;
--                                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                               IF (g_debug_mode = 'Y') THEN
                                   g_debug_msg := ' FAILED Updated Acct Line ..... 1 ';
                                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                               END IF;
                               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                               THEN
                                      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                               l_api_name);
                               END IF;
                               RAISE E_UPDATE_CC_TABLES;
                          END IF;

--      END IF;

--                        IF (IGC_MSGS_PKG.g_debug_mode) THEN
                        IF (g_debug_mode = 'Y') THEN
                           g_debug_msg := ' Check det pf line id 1.......';
                           Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                        END IF;

      IF ((l_cc_det_pf_line_id IS NOT NULL) AND
            (l_budget_dest_flag = 'S'))
      THEN
                                -- Performance Tuning, Replaced view
                                -- igc_cc_det_pf_v with
                                -- igc_cc_det_pf and replaced the line
                                -- below.
        -- SELECT cc_det_pf_comp_func_amt
                                SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt
        INTO l_cc_det_pf_comp_func_amt
        FROM igc_cc_det_pf ccdpf
        WHERE ccdpf.cc_det_pf_line_id = l_cc_det_pf_line_id;

-- ----------------------------------------------------------------------------------
-- Obtain the actual Det PF line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                                OPEN c_det_pf_line;
                                FETCH c_det_pf_line
                                 INTO l_det_pf_rec;

                                IF (c_det_pf_line%NOTFOUND) THEN
                                   EXIT;
                                END IF;

                                CLOSE c_det_pf_line;

--                                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                IF (g_debug_mode = 'Y') THEN
                                   g_debug_msg := ' Getting Det PF Line Info ';
                                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                END IF;

        IF (l_cc_headers_rec.cc_state = 'CL') THEN

                                        -- Added for Bug 3219208
                                        -- Entered Amt should be set to 0 when the CC is being
                                        -- cancelled.
          l_det_pf_rec.cc_det_pf_entered_amt     := 0;
          l_det_pf_rec.cc_det_pf_func_amt     := 0;
          l_cc_det_pf_enc_amt := 0;
                            l_det_pf_rec.cc_det_pf_encmbrnc_amt    := 0;
                            l_det_pf_rec.cc_det_pf_encmbrnc_status := 'N';
                            l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_transaction_date;
                            l_det_pf_rec.cc_det_pf_date            := l_cc_transaction_date;
                            l_det_pf_rec.last_update_date          := SYSDATE;
                            l_det_pf_rec.last_update_login         := l_update_login;
                            l_det_pf_rec.last_updated_by           := l_update_by;

        ELSIF (l_cc_headers_rec.cc_state = 'PR') THEN

          l_cc_det_pf_enc_amt := l_cc_det_pf_comp_func_amt;
                            l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_cc_det_pf_comp_func_amt;
                            l_det_pf_rec.cc_det_pf_encmbrnc_status := l_encumbrance_status;
                            l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_transaction_date;
                            l_det_pf_rec.last_update_date          := SYSDATE;
                            l_det_pf_rec.last_update_login         := l_update_login;
                            l_det_pf_rec.last_updated_by           := l_update_by;

        ELSIF (l_cc_headers_rec.cc_state = 'CM') THEN

          l_cc_det_pf_enc_amt := l_cc_det_pf_comp_func_amt;
                            l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_cc_det_pf_comp_func_amt;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_status := l_encumbrance_status;
                                        l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_transaction_date;
                                        l_det_pf_rec.last_update_date          := SYSDATE;
                                        l_det_pf_rec.last_update_login         := l_update_login;
                                        l_det_pf_rec.last_updated_by           := l_update_by;

        ELSIF (l_cc_headers_rec.cc_state = 'CT') THEN

          l_billed_amt      := 0;
                                        l_func_billed_amt := 0;

                                        -- Performance Tuning, Replaced view
                                        -- igc_cc_det_pf_v with
                                        -- igc_cc_det_pf and replaced the line
                                        -- below.
          -- SELECT cc_det_pf_billed_amt , cc_det_pf_func_billed_amt
                            SELECT IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
                                   IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt
          INTO l_billed_amt, l_func_billed_amt
          FROM igc_cc_det_pf ccdpf
          WHERE ccdpf.cc_det_pf_line_id = l_cc_det_pf_line_id;

          IF (l_currency_code <> l_cc_headers_rec.currency_code) THEN

                                                l_cc_det_pf_comp_func_amt := l_func_billed_amt;
                                                l_cc_det_pf_enc_amt       := l_func_billed_amt;

                                                l_det_pf_rec.cc_det_pf_entered_amt     := l_billed_amt;
                                                l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_func_billed_amt;
                                                l_det_pf_rec.cc_det_pf_func_amt        := l_func_billed_amt;
                                                l_det_pf_rec.cc_det_pf_encmbrnc_status := 'N';
                                                l_det_pf_rec.cc_det_pf_date            := l_cc_transaction_date;
                                                l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_transaction_date;
                                                l_det_pf_rec.last_update_date          := SYSDATE;
                                                l_det_pf_rec.last_update_login         := l_update_login;
                                                l_det_pf_rec.last_updated_by           := l_update_by;

                                                -- 2043221, Bidisha , 19 Oct 2001
                                                -- Withheld amount should be set to 0 if the CC
                                                -- is completed.
                                                l_acct_line_rec.cc_func_withheld_amt    := 0;
                                                l_acct_line_rec.cc_ent_withheld_amt     := 0;
          ELSE

                                                l_cc_det_pf_comp_func_amt := l_func_billed_amt;
                                                l_cc_det_pf_enc_amt       := l_func_billed_amt;

                                                l_det_pf_rec.cc_det_pf_entered_amt     := l_func_billed_amt;
                                                l_det_pf_rec.cc_det_pf_encmbrnc_amt    := l_func_billed_amt;
                                                l_det_pf_rec.cc_det_pf_func_amt        := l_func_billed_amt;
                                                l_det_pf_rec.cc_det_pf_encmbrnc_status := 'N';
                                                l_det_pf_rec.cc_det_pf_date            := l_cc_transaction_date;
                                                l_det_pf_rec.cc_det_pf_encmbrnc_date   := l_cc_transaction_date;
                                                l_det_pf_rec.last_update_date          := SYSDATE;
                                                l_det_pf_rec.last_update_login         := l_update_login;
                                                l_det_pf_rec.last_updated_by           := l_update_by;

                                                -- 2043221, Bidisha , 19 Oct 2001
                                                -- Withheld amount should be set to 0 if the CC
                                                -- is completed.
                                                l_acct_line_rec.cc_func_withheld_amt    := 0;
                                                l_acct_line_rec.cc_ent_withheld_amt     := 0;
          END IF;

                                ELSE

-- -----------------------------------------------------------------------------
-- Unknown CC State in the Header record for the Det PF update.  Exit Process.
-- -----------------------------------------------------------------------------
--                                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                   IF (g_debug_mode = 'Y') THEN
                                      g_debug_msg := ' Bad CC State ...... 2';
                                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                   END IF;

                                   RAISE E_UPDATE_CC_TABLES;

        END IF;

                                SELECT rowid
                                  INTO l_row_id
                                  FROM igc_cc_det_pf
                                 WHERE cc_det_pf_line_id = l_det_pf_rec.cc_det_pf_line_id;

--                                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                IF (g_debug_mode = 'Y') THEN
                                   g_debug_msg := ' Updating DET PF Line';
                                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                END IF;

                                Det_Pf_Wrapper (p_api_version      => l_api_version,
                                                p_init_msg_list    => FND_API.G_FALSE,
                                                p_commit           => FND_API.G_FALSE,
                                                p_validation_level => l_validation_level,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => l_msg_count,
                                                x_msg_data         => l_msg_data,
                                                x_rowid            => l_row_id,
                                                p_action_flag      => 'U',
                                                p_cc_pmt_fcst_rec  => l_det_pf_rec,
                                                p_update_flag      => l_update_flag
                                               );

                                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                   x_msg_data  := l_msg_data;
                                   x_msg_count := l_msg_count;

--                                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                   IF (g_debug_mode = 'Y') THEN
                                      g_debug_msg := ' FAILURE updating DET PF line ...... 1 ';
                                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                   END IF;

                                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                                   THEN
                                      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                                l_api_name);
                                   END IF;
                                   RAISE E_UPDATE_CC_TABLES;
                                END IF;

      END IF;

    END LOOP;

--                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                IF (g_debug_mode = 'Y') THEN
                   g_debug_msg := ' End LOOP ...... 1 ';
                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                END IF;

    CLOSE c_cc_interface;

                IF (c_det_pf_line%ISOPEN) THEN
                    CLOSE c_det_pf_line;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;

--                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                IF (g_debug_mode = 'Y') THEN
                   g_debug_msg := ' Done Updating for Phase 1 Acct Lines and PF Lines.....';
                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                END IF;

    IF ((l_cc_headers_rec.cc_state = 'CT') OR
                    (l_cc_headers_rec.cc_state = 'CL')) THEN

                   l_cc_headers_rec.cc_encmbrnc_status := 'N';
                   l_cc_headers_rec.last_update_date   := SYSDATE;
                   l_cc_headers_rec.last_update_login  := l_update_login;
                   l_cc_headers_rec.last_updated_by    := l_update_by;

    ELSIF ((l_cc_headers_rec.cc_state = 'PR') OR
                       (l_cc_headers_rec.cc_state = 'CM')) THEN

                   l_cc_headers_rec.cc_encmbrnc_status := l_encumbrance_status;
                   l_cc_headers_rec.last_update_date   := SYSDATE;
                   l_cc_headers_rec.last_update_login  := l_update_login;
                   l_cc_headers_rec.last_updated_by    := l_update_by;

                ELSE

-- -----------------------------------------------------------------------------
-- Unknown CC State in the Header record for the Det PF update.  Exit Process.
-- -----------------------------------------------------------------------------
--                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                   IF (g_debug_mode = 'Y') THEN
                      g_debug_msg := ' Bad CCC State....... 3 ';
                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                   END IF;

                   RAISE E_UPDATE_CC_TABLES;

    END IF;

                SELECT rowid
                  INTO l_row_id
                  FROM igc_cc_headers
                 WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

--                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                IF (g_debug_mode = 'Y') THEN
                   g_debug_msg := ' Updating Header Record....... 1';
                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                END IF;

                l_cc_headers_rec.cc_acct_date := p_accounting_date;

                Header_Wrapper (p_api_version      => l_api_version,
                                p_init_msg_list    => FND_API.G_FALSE,
                                p_commit           => FND_API.G_FALSE,
                                p_validation_level => l_validation_level,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data,
                                x_rowid            => l_row_id,
                                p_action_flag      => 'U',
                                p_cc_header_rec    => l_cc_headers_rec,
                                p_update_flag      => l_update_flag
                               );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   x_msg_data  := l_msg_data;
                   x_msg_count := l_msg_count;
                   l_cc_headers_rec.cc_encmbrnc_status := l_encumbrance_status_old;

--                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                   IF (g_debug_mode = 'Y') THEN
                      g_debug_msg := ' Failure UPDATING Header record..... 1';
                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                   END IF;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                   THEN
                      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                l_api_name);
                   END IF;
                   RAISE E_UPDATE_CC_TABLES;
                END IF;

--                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                IF (g_debug_mode = 'Y') THEN
                   g_debug_msg := ' Inserting Actions Record.....';
                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                END IF;

    IGC_CC_ACTIONS_PKG.Insert_Row
                    (1.0,
           FND_API.G_FALSE,
           FND_API.G_FALSE,
           FND_API.G_VALID_LEVEL_FULL,
           l_return_status,
           l_msg_count,
           l_msg_data,
           l_rowid,
           p_cc_header_id,
           l_cc_headers_rec.cc_version_num,
           'EC',
                     l_cc_headers_rec.cc_state,
           l_cc_headers_rec.cc_ctrl_status,
           l_cc_headers_rec.cc_apprvl_status,
           p_notes,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           sysdate,
           fnd_global.user_id
          );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   x_msg_data  := l_msg_data;
                   x_msg_count := l_msg_count;

--                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                   IF (g_debug_mode = 'Y') THEN
                      g_debug_msg := ' Falure Inserting Actions Row..... 1 ';
                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                   END IF;

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                   THEN
                      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                l_api_name);
                   END IF;
                   RAISE E_UPDATE_CC_TABLES;
                END IF;

  END IF; /* Update CC Tables */

  EXCEPTION
    WHEN OTHERS
    THEN
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                           FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                     l_api_name);
                        END IF;
                        IF ( g_unexp_level >= g_debug_level ) THEN
                           FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                           FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                           FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                           FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                        END IF;

      RAISE E_UPDATE_CC_TABLES;
  END;

--        IF (IGC_MSGS_PKG.g_debug_mode) THEN
        IF (g_debug_mode = 'Y') THEN
           g_debug_msg := ' Beginning Phase 2....... Updates';
           Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
        END IF;

  IF ( (l_interface_row_count = 0) AND (p_mode = 'R') )
  THEN

    OPEN c_account_lines(p_cc_header_id);

    LOOP
      FETCH c_account_lines INTO l_cc_acct_lines_rec;

      EXIT WHEN c_account_lines%NOTFOUND;

-- ----------------------------------------------------------------------------------
-- Obtain the actual account line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                        OPEN c_cc_acct_line_rec_input;
                        FETCH c_cc_acct_line_rec_input
                         INTO l_acct_line_rec;

                        IF (c_cc_acct_line_rec_input%NOTFOUND) THEN
                           EXIT;
                        END IF;

--                        IF (IGC_MSGS_PKG.g_debug_mode) THEN
                        IF (g_debug_mode = 'Y') THEN
                           g_debug_msg := ' Retrieving Account Line info 2......';
                           Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                        END IF;

                        CLOSE c_cc_acct_line_rec_input;

                        IF ((l_cc_acct_lines_rec.cc_acct_encmbrnc_amt =
                             l_cc_acct_lines_rec.cc_acct_comp_func_amt) AND
                            (l_cc_acct_lines_rec.cc_acct_encmbrnc_status = 'N')) THEN

                           l_acct_line_rec.cc_acct_encmbrnc_status := l_encumbrance_status;
                           l_acct_line_rec.last_update_date        := SYSDATE;
                           l_acct_line_rec.last_update_login       := l_update_login;
                           l_acct_line_rec.last_updated_by         := l_update_by;

                           SELECT rowid
                             INTO l_row_id
                             FROM igc_cc_acct_lines
                            WHERE cc_acct_line_id = l_acct_line_rec.cc_acct_line_id;

--                           IF (IGC_MSGS_PKG.g_debug_mode) THEN
                           IF (g_debug_mode = 'Y') THEN
                              g_debug_msg := ' Updating Acct Line........ 2';
                              Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                           END IF;

                           Account_Line_Wrapper (p_api_version       => l_api_version,
                                                 p_init_msg_list     => FND_API.G_FALSE,
                                                 p_commit            => FND_API.G_FALSE,
                                                 p_validation_level  => l_validation_level,
                                                 x_return_status     => l_return_status,
                                                 x_msg_count         => l_msg_count,
                                                 x_msg_data          => l_msg_data,
                                                 x_rowid             => l_row_id,
                                                 p_action_flag       => 'U',
                                                 p_cc_acct_lines_rec => l_acct_line_rec,
                                                 p_update_flag       => l_update_flag
                                                );

                           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                              x_msg_data  := l_msg_data;
                              x_msg_count := l_msg_count;

--                              IF (IGC_MSGS_PKG.g_debug_mode) THEN
                              IF (g_debug_mode = 'Y') THEN
                                 g_debug_msg := ' FAILED update accout line ........ 2';
                                 Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                              END IF;

                              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                              THEN
                                 FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                           l_api_name);
                              END IF;
                              RAISE E_UPDATE_CC_TABLES;
                           END IF;

                        END IF;

      OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

      LOOP
        FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

        EXIT WHEN c_payment_forecast%NOTFOUND;

-- ----------------------------------------------------------------------------------
-- Obtain the actual Det PF line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                                OPEN c_det_pf_line_rec_input;
                                FETCH c_det_pf_line_rec_input
                                 INTO l_det_pf_rec;

                                IF (c_det_pf_line_rec_input%NOTFOUND) THEN
                                   EXIT;
                                END IF;

                                CLOSE c_det_pf_line_rec_input;

--                                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                IF (g_debug_mode = 'Y') THEN
                                   g_debug_msg := ' Getting the DET PF Line INFO ...... 2 ';
                                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                END IF;

                                IF ((l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt =
                                     l_cc_pmt_fcst_rec.cc_det_pf_comp_func_amt) AND
                                    (l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_status = 'N')) THEN

                                   l_det_pf_rec.cc_det_pf_encmbrnc_status := l_encumbrance_status;
                                   l_det_pf_rec.last_update_date          := SYSDATE;
                                   l_det_pf_rec.last_update_login         := l_update_login;
                                   l_det_pf_rec.last_updated_by           := l_update_by;

                                   SELECT rowid
                                     INTO l_row_id
                                     FROM igc_cc_det_pf
                                    WHERE cc_det_pf_line_id = l_det_pf_rec.cc_det_pf_line_id;

                                   Det_Pf_Wrapper (p_api_version      => l_api_version,
                                                   p_init_msg_list    => FND_API.G_FALSE,
                                                   p_commit           => FND_API.G_FALSE,
                                                   p_validation_level => l_validation_level,
                                                   x_return_status    => l_return_status,
                                                   x_msg_count        => l_msg_count,
                                                   x_msg_data         => l_msg_data,
                                                   x_rowid            => l_row_id,
                                                   p_action_flag      => 'U',
                                                   p_cc_pmt_fcst_rec  => l_det_pf_rec,
                                                   p_update_flag      => l_update_flag
                                                  );

                                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                                      x_msg_data  := l_msg_data;
                                      x_msg_count := l_msg_count;

--                                      IF (IGC_MSGS_PKG.g_debug_mode) THEN
                                      IF (g_debug_mode = 'Y') THEN
                                         g_debug_msg := ' FAILED Updating DET PF Line INFO ...... 2 ';
                                         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                                      END IF;

                                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                                      THEN
                                         FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                                   l_api_name);
                                      END IF;
                                      RAISE E_UPDATE_CC_TABLES;
                                   END IF;

                                END IF;

      END LOOP;

      CLOSE c_payment_forecast;
                        IF (c_det_pf_line_rec_input%ISOPEN) THEN
                           CLOSE c_det_pf_line_rec_input;
                        END IF;

    END LOOP;

    CLOSE c_account_lines;
                IF (c_cc_acct_line_rec_input%ISOPEN) THEN
                   CLOSE c_cc_acct_line_rec_input;
                END IF;
                IF (c_det_pf_line_rec_input%ISOPEN) THEN
                   CLOSE c_det_pf_line_rec_input;
                END IF;

                l_cc_headers_rec.cc_encmbrnc_status := l_encumbrance_status;
                l_cc_headers_rec.last_update_date   := SYSDATE;
                l_cc_headers_rec.last_update_login  := l_update_login;
                l_cc_headers_rec.last_updated_by    := l_update_by;

                SELECT rowid
                  INTO l_row_id
                  FROM igc_cc_headers
                 WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

--                IF (IGC_MSGS_PKG.g_debug_mode) THEN
                IF (g_debug_mode = 'Y') THEN
                   g_debug_msg := ' Updating Header Line INFO ...... 3 ';
                   Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                END IF;

                Header_Wrapper (p_api_version      => l_api_version,
                                p_init_msg_list    => FND_API.G_FALSE,
                                p_commit           => FND_API.G_FALSE,
                                p_validation_level => l_validation_level,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data,
                                x_rowid            => l_row_id,
                                p_action_flag      => 'U',
                                p_cc_header_rec    => l_cc_headers_rec,
                                p_update_flag      => l_update_flag
                               );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   x_msg_data  := l_msg_data;
                   x_msg_count := l_msg_count;

--                   IF (IGC_MSGS_PKG.g_debug_mode) THEN
                   IF (g_debug_mode = 'Y') THEN
                      g_debug_msg := ' FAILED Updated Header Line INFO ...... 3 ';
                      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
                   END IF;

                   l_cc_headers_rec.cc_encmbrnc_status := l_encumbrance_status_old;
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                   THEN
                      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                l_api_name);
                   END IF;
                   RAISE E_UPDATE_CC_TABLES;
                END IF;

  END IF;

  IF (l_cc_apprvl_status_old <> 'IP')
  THEN

           l_cc_headers_rec.cc_apprvl_status    := l_cc_apprvl_status_old;
           l_cc_headers_rec.last_update_date    := SYSDATE;
           l_cc_headers_rec.last_update_login   := l_update_login;
           l_cc_headers_rec.last_updated_by     := l_update_by;

           SELECT rowid
           INTO l_row_id
           FROM igc_cc_headers
           WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

           Header_Wrapper (p_api_version      => l_api_version,
                           p_init_msg_list    => FND_API.G_FALSE,
                           p_commit           => FND_API.G_FALSE,
                           p_validation_level => l_validation_level,
                           x_return_status    => l_return_status,
                           x_msg_count        => l_msg_count,
                           x_msg_data         => l_msg_data,
                           x_rowid            => l_row_id,
                           p_action_flag      => 'U',
                           p_cc_header_rec    => l_cc_headers_rec,
                           p_update_flag      => l_update_flag
                          );

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_msg_data  := l_msg_data;
              x_msg_count := l_msg_count;
--              IF (IGC_MSGS_PKG.g_debug_mode) THEN
              IF (g_debug_mode = 'Y') THEN
                 g_debug_msg := ' FAILED Update Header Line Info ...... 4 ';
                 Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
              END IF;

              l_cc_headers_rec.cc_encmbrnc_status := l_encumbrance_status_old;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                 FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                           l_api_name);
              END IF;
              RAISE E_UPDATE_CC_TABLES;
           END IF;

  END IF;

  IF ( (l_batch_result_code IS NOT NULL) AND (l_interface_row_count <> 0) )
  THEN
    IF (l_batch_result_code = 'HXX')
    THEN
      fnd_message.set_name('IGC', 'IGC_CC_CBC_RESULT_CODE_INVALID');
                    IF(g_state_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_state_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;
    ELSE
      fnd_message.set_name('IGC', 'IGC_CC_CBC_RESULT_CODE_'||l_batch_result_code);
                    IF(g_state_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_state_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;
    END IF;

  END IF;

  IF FND_API.To_Boolean(p_commit)
  THEN
           COMMIT WORK;
  END IF;

        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data );

        RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR OR E_CC_NOT_FOUND OR  E_INVALID_MODE OR E_UPDATE OR E_DELETE
  THEN
    ROLLBACK TO Execute_Budgetary_Ctrl1;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_bc_status      := FND_API.G_FALSE;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_cc_acct_line_rec_input%ISOPEN) THEN
                   CLOSE c_cc_acct_line_rec_input;
                END IF;
                IF (c_det_pf_line_rec_input%ISOPEN) THEN
                   CLOSE c_det_pf_line_rec_input;
                END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
                IF (g_excep_level >=  g_debug_level ) THEN
                     FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR OR E_CC_NOT_FOUND OR  E_INVALID_MODE OR E_UPDATE OR E_DELETE Exception Raised');
                END IF;

  WHEN  E_PROCESS_ROW
  THEN
    ROLLBACK TO Execute_Budgetary_Ctrl3;
    IF (l_cc_apprvl_status_old <> 'IP')
    THEN

                   l_cc_headers_rec.cc_apprvl_status   := l_cc_apprvl_status_old;
                   l_cc_headers_rec.last_update_date   := SYSDATE;
                   l_cc_headers_rec.last_update_login  := l_update_login;
                   l_cc_headers_rec.last_updated_by    := l_update_by;

                   SELECT rowid
                     INTO l_row_id
                     FROM igc_cc_headers
                    WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

                   Header_Wrapper (p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_FALSE,
                                   p_commit           => FND_API.G_TRUE,
                                   p_validation_level => l_validation_level,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_rowid            => l_row_id,
                                   p_action_flag      => 'U',
                                   p_cc_header_rec    => l_cc_headers_rec,
                                   p_update_flag      => l_update_flag
                                  );

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      x_msg_data  := l_msg_data;
                      x_msg_count := l_msg_count;
                   END IF;

    END IF;

    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_bc_status      := FND_API.G_FALSE;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_cc_acct_line_rec_input%ISOPEN) THEN
                   CLOSE c_cc_acct_line_rec_input;
                END IF;
                IF (c_det_pf_line_rec_input%ISOPEN) THEN
                   CLOSE c_det_pf_line_rec_input;
                END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
                IF (g_excep_level >=  g_debug_level ) THEN
                    FND_LOG.STRING (g_excep_level,l_full_path,'E_PROCESS_ROW Exception Raised');
                END IF;

  WHEN  E_CC_INVALID_SET_UP OR E_NO_BUDGETARY_CONTROL
       OR E_SBC_DATA OR E_SBC_DATA1 OR E_CBC_DATA OR E_CBC_DATA1 OR E_CHECK_BUDG_CTRL
  THEN
    ROLLBACK TO Execute_Budgetary_Ctrl2;

    IF (l_cc_apprvl_status_old <> 'IP')
    THEN

                   l_cc_headers_rec.cc_apprvl_status   := l_cc_apprvl_status_old;
                   l_cc_headers_rec.last_update_date   := SYSDATE;
                   l_cc_headers_rec.last_update_login  := l_update_login;
                   l_cc_headers_rec.last_updated_by    := l_update_by;

                   SELECT rowid
                     INTO l_row_id
                     FROM igc_cc_headers
                    WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

                   Header_Wrapper (p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_FALSE,
                                   p_commit           => FND_API.G_TRUE,
                                   p_validation_level => l_validation_level,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_rowid            => l_row_id,
                                   p_action_flag      => 'U',
                                   p_cc_header_rec    => l_cc_headers_rec,
                                   p_update_flag      => l_update_flag
                                  );

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      x_msg_data  := l_msg_data;
                      x_msg_count := l_msg_count;
                   END IF;

    END IF;

    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_bc_status      := FND_API.G_FALSE;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_cc_acct_line_rec_input%ISOPEN) THEN
                   CLOSE c_cc_acct_line_rec_input;
                END IF;
                IF (c_det_pf_line_rec_input%ISOPEN) THEN
                   CLOSE c_det_pf_line_rec_input;
                END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );
                IF (g_excep_level >=  g_debug_level ) THEN
                    FND_LOG.STRING (g_excep_level,l_full_path,
               'E_CC_INVALID_SET_UP OR E_NO_BUDGETARY_CONTROLOR E_SBC_DATA OR E_SBC_DATA1 OR E_CBC_DATA OR E_CBC_DATA1 OR E_CHECK_BUDG_CTRL');
                END IF;

  WHEN E_BC_EXECUTION /*OR E_UPDATE_CC_TABLES */
  THEN
    --ROLLBACK TO Execute_Budgetary_Ctrl4;
    select count(*)
    INTO x_msg_count
    FROM igc_cc_interface
    WHERE cc_header_id = p_cc_header_id;

    IF (l_cc_apprvl_status_old <> 'IP')
    THEN

                   l_cc_headers_rec.cc_apprvl_status   := l_cc_apprvl_status_old;
                   l_cc_headers_rec.last_update_date   := SYSDATE;
                   l_cc_headers_rec.last_update_login  := l_update_login;
                   l_cc_headers_rec.last_updated_by    := l_update_by;

                   SELECT rowid
                     INTO l_row_id
                     FROM igc_cc_headers
                    WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

                   Header_Wrapper (p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_FALSE,
                                   p_commit           => FND_API.G_TRUE,
                                   p_validation_level => l_validation_level,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_rowid            => l_row_id,
                                   p_action_flag      => 'U',
                                   p_cc_header_rec    => l_cc_headers_rec,
                                   p_update_flag      => l_update_flag
                                  );

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      x_msg_data  := l_msg_data;
                      x_msg_count := l_msg_count;
                   END IF;

    END IF;

    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_bc_status      := FND_API.G_FALSE;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_cc_acct_line_rec_input%ISOPEN) THEN
                   CLOSE c_cc_acct_line_rec_input;
                END IF;
                IF (c_det_pf_line_rec_input%ISOPEN) THEN
                   CLOSE c_det_pf_line_rec_input;
                END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );
                IF (g_excep_level >=  g_debug_level ) THEN
                   FND_LOG.STRING (g_excep_level,l_full_path,'E_BC_EXECUTION Exception Raised');
                END IF;

        WHEN OTHERS
  THEN
    ROLLBACK;

    IF (l_cc_apprvl_status_old <> 'IP')
    THEN

                   l_cc_headers_rec.cc_apprvl_status   := l_cc_apprvl_status_old;
                   l_cc_headers_rec.last_update_date   := SYSDATE;
                   l_cc_headers_rec.last_update_login  := l_update_login;
                   l_cc_headers_rec.last_updated_by    := l_update_by;

                   SELECT rowid
                     INTO l_row_id
                     FROM igc_cc_headers
                    WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

                   Header_Wrapper (p_api_version      => l_api_version,
                                   p_init_msg_list    => FND_API.G_FALSE,
                                   p_commit           => FND_API.G_TRUE,
                                   p_validation_level => l_validation_level,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data,
                                   x_rowid            => l_row_id,
                                   p_action_flag      => 'U',
                                   p_cc_header_rec    => l_cc_headers_rec,
                                   p_update_flag      => l_update_flag
                                  );

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                      x_msg_data  := l_msg_data;
                      x_msg_count := l_msg_count;
                   END IF;

    END IF;

    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_bc_status      := FND_API.G_FALSE;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_cc_acct_line_rec_input%ISOPEN) THEN
                   CLOSE c_cc_acct_line_rec_input;
                END IF;
                IF (c_det_pf_line_rec_input%ISOPEN) THEN
                   CLOSE c_det_pf_line_rec_input;
                END IF;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
                IF ( g_unexp_level >= g_debug_level ) THEN
                   FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                   FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                   FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                   FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                END IF;

END Execute_Budgetary_Ctrl;


PROCEDURE Check_Budgetary_Ctrl_On
(
  p_api_version                         IN       NUMBER,
  p_init_msg_list                       IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                    IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_org_id                              IN       NUMBER,
  p_sob_id                              IN       NUMBER,
  p_cc_state                            IN       VARCHAR2,
  x_encumbrance_on                      OUT NOCOPY      VARCHAR2
)
IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Check_Budgetary_Ctrl_On';
  l_api_version                   CONSTANT NUMBER         :=  1.0;

  l_enable_budg_control_flag      gl_sets_of_books.enable_budgetary_control_flag%TYPE;
  l_cc_bc_enable_flag             igc_cc_bc_enable.cc_bc_enable_flag%TYPE;
  l_req_encumbrance_flag        financials_system_params_all.req_encumbrance_flag%TYPE;
  l_purch_encumbrance_flag      financials_system_params_all.purch_encumbrance_flag%TYPE;
--  l_cc_prov_enc_enable_flag       igc_cc_encmbrnc_ctrls.cc_prov_encmbrnc_enable_flag%TYPE;
--  l_cc_conf_enc_enable_flag       igc_cc_encmbrnc_ctrls.cc_conf_encmbrnc_enable_flag%TYPE;

  l_error_message                 VARCHAR2(2000);

  e_cc_not_found                  EXCEPTION;
  e_cc_invalid_set_up             EXCEPTION;
  e_gl_data                   EXCEPTION;
  e_null_parameter                EXCEPTION;

        l_full_path                     VARCHAR2(255);
BEGIN

   l_full_path := g_path || 'Check_Budgetary_Ctrl_On';

  x_encumbrance_on           := FND_API.G_TRUE;
  x_return_status            := FND_API.G_RET_STS_SUCCESS;
  l_enable_budg_control_flag := 'N';

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_org_id IS NULL)
  THEN
    fnd_message.set_name('IGC', 'IGC_CC_NO_ORG_ID');
                IF(g_error_level >= g_debug_level) THEN
                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                END IF;
    fnd_msg_pub.add;
    RAISE E_NULL_PARAMETER;
  END IF;

  IF (p_sob_id IS NULL)
  THEN
    fnd_message.set_name('IGC', 'IGC_CC_NO_SOB_ID');
                IF(g_error_level >= g_debug_level) THEN
                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                END IF;
    fnd_msg_pub.add;
    RAISE E_NULL_PARAMETER;
  END IF;

  IF (p_cc_state IS NULL)
  THEN
    fnd_message.set_name('IGC', 'IGC_CC_NO_CC_STATE');
                IF(g_error_level >= g_debug_level) THEN
                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                END IF;
    fnd_msg_pub.add;
    RAISE E_NULL_PARAMETER;
  END IF;

  /* Check whether SBC is turned on */

  BEGIN

    SELECT  NVL(enable_budgetary_control_flag,'N')
    INTO    l_enable_budg_control_flag
    FROM    gl_sets_of_books
    WHERE   set_of_books_id = p_sob_id;

  EXCEPTION

    WHEN NO_DATA_FOUND
    THEN
      fnd_message.set_name('IGC', 'IGC_CC_INVALID_GL_DATA');
      IF(g_error_level >= g_debug_level) THEN
        FND_LOG.MESSAGE(g_error_level, l_full_path || 'Msg4', FALSE);
      END IF;
      fnd_msg_pub.add;
      RAISE E_CC_INVALID_SET_UP;
  END;


  IF ( NVL(l_enable_budg_control_flag,'N') = 'Y')
  THEN
    BEGIN
      SELECT  req_encumbrance_flag, purch_encumbrance_flag
      INTO      l_req_encumbrance_flag, l_purch_encumbrance_flag
      FROM    financials_system_params_all
      WHERE   set_of_books_id = p_sob_id AND
          org_id = p_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        x_encumbrance_on            := FND_API.G_FALSE;
    END;

    /* Check whether CBC is turned on */

      BEGIN
        SELECT  cc_bc_enable_flag
        INTO    l_cc_bc_enable_flag
        FROM    igc_cc_bc_enable
        WHERE   set_of_books_id = p_sob_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_cc_bc_enable_flag := 'N';
      END;

      IF ( (p_cc_state = 'PR') OR (p_cc_state = 'CL') )
      THEN
        IF (NVL(l_req_encumbrance_flag,'N') = 'Y')
        THEN
          x_encumbrance_on := FND_API.G_TRUE;
        ELSE
          x_encumbrance_on := FND_API.G_FALSE;
        END IF;
      END IF;

      IF ( (p_cc_state = 'CM') OR (p_cc_state = 'CT') )
      THEN
        IF (NVL(l_purch_encumbrance_flag,'N') = 'Y')
        THEN
          x_encumbrance_on := FND_API.G_TRUE;
        ELSE
          x_encumbrance_on := FND_API.G_FALSE;
        END IF;
      END IF;
    ELSE
      x_encumbrance_on := FND_API.G_FALSE;
    END IF;

EXCEPTION

  WHEN E_CC_NOT_FOUND OR E_CC_INVALID_SET_UP OR E_GL_DATA OR E_NULL_PARAMETER
  THEN
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_encumbrance_on := FND_API.G_FALSE;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
        IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'E_CC_NOT_FOUND OR E_CC_INVALID_SET_UP OR E_GL_DATA OR E_NULL_PARAMETER Exception Raised');
        END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_encumbrance_on := FND_API.G_FALSE;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );
        IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
        END IF;

  WHEN OTHERS
  THEN
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    x_encumbrance_on := FND_API.G_FALSE;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
        IF ( g_unexp_level >= g_debug_level ) THEN
           FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
           FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
           FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
        END IF;

END Check_Budgetary_Ctrl_On;


PROCEDURE Set_Encumbrance_Status
(
  p_api_version                         IN       NUMBER,
  p_init_msg_list                       IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                              IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                    IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                       OUT NOCOPY      VARCHAR2,
  x_msg_count                           OUT NOCOPY      NUMBER,
  x_msg_data                            OUT NOCOPY      VARCHAR2,
  p_cc_header_id                        IN       NUMBER,
  p_encumbrance_status_code             IN       VARCHAR2
)
IS
  l_api_name                      CONSTANT VARCHAR2(30)   := 'Set_Encumbrance_Status';
  l_api_version                   CONSTANT NUMBER         :=  1.0;

  l_cc_headers_rec                igc_cc_headers%ROWTYPE;
  l_cc_acct_lines_rec             igc_cc_acct_lines_v%ROWTYPE;
  l_cc_pmt_fcst_rec               igc_cc_det_pf_v%ROWTYPE;

  l_error_message                 VARCHAR2(2000);

-- -------------------------------------------------------------------------
-- Variables to be used in calls to the table wrapper procedures.
-- -------------------------------------------------------------------------
        l_validation_level              NUMBER;
        l_return_status                 VARCHAR2(1);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_row_id                        VARCHAR2(18);
        l_update_flag                   VARCHAR2(1);
        l_update_login                  igc_cc_acct_lines.last_update_login%TYPE;
        l_update_by                     igc_cc_acct_lines.last_updated_by%TYPE;

-- -------------------------------------------------------------------------
-- Record definitions to be used for CURSORS getting single record for
-- the table wrappers.  These record definitions are NOT the same as the
-- ones above when getting data from the views.
-- -------------------------------------------------------------------------
        l_det_pf_rec                    igc_cc_det_pf%ROWTYPE;
        l_header_rec                    igc_cc_headers%ROWTYPE;
        l_acct_line_rec                 igc_cc_acct_lines%ROWTYPE;

  e_cc_not_found                  EXCEPTION;
  e_invalid_status_code           EXCEPTION;

  /* Contract Commitment detail payment forecast  */
  CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS

        -- Performance Tuning, Replaced view igc_cc_det_pf_v with
        -- igc_cc_det_pf and replaced the line below.
  -- SELECT *
  -- FROM igc_cc_det_pf_v
  -- WHERE cc_acct_line_id =  t_cc_acct_line_id;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id, NVL(ccdpf.cc_det_pf_entered_amt,0) ) -
               NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) ) cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
  WHERE ccdpf.cc_acct_line_id =  t_cc_acct_line_id;

  /* Contract Commitment account lines  */

-- Bug 2885953 - cursor below amended for performance enhancements
--    CURSOR c_account_lines(t_cc_header_id NUMBER) IS
--    SELECT *
--        FROM  igc_cc_acct_lines_v ccac
--        WHERE ccac.cc_header_id = t_cc_header_id;
  CURSOR c_account_lines(t_cc_header_id NUMBER) IS
  SELECT ccac.ROWID,
               ccac.cc_header_id,
               NULL org_id,
               NULL cc_type,
               NULL cc_type_code,
               NULL cc_num,
               ccac.cc_acct_line_id,
               ccac.cc_acct_line_num,
               ccac.cc_acct_desc,
               ccac.parent_header_id,
               ccac.parent_acct_line_id,
               NULL parent_cc_acct_line_num,
               NULL cc_budget_acct_desc,
               ccac.cc_budget_code_combination_id,
               NULL cc_charge_acct_desc,
               ccac.cc_charge_code_combination_id,
               ccac.cc_acct_entered_amt,
               ccac.cc_acct_func_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_func_billed_amt,
               ccac.cc_acct_encmbrnc_amt,
               (IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0)) - NVL(ccac.cc_acct_encmbrnc_amt,0)) cc_acct_unencmrd_amt,
               ccac.cc_acct_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0))
               cc_acct_comp_func_amt,
               NULL project_number,
               ccac.project_id,
               NULL task_number,
               ccac.task_id,
               ccac.expenditure_type,
               NULL expenditure_org_name,
               ccac.expenditure_org_id,
               ccac.expenditure_item_date,
               ccac.cc_acct_taxable_flag,
               NULL tax_name,
               ccac.tax_id,
               ccac.cc_acct_encmbrnc_status,
               ccac.cc_acct_encmbrnc_date,
               ccac.context,
               ccac.attribute1,
               ccac.attribute2,
               ccac.attribute3,
               ccac.attribute4,
               ccac.attribute5,
               ccac.attribute6,
               ccac.attribute7,
               ccac.attribute8,
               ccac.attribute9,
               ccac.attribute10,
               ccac.attribute11,
               ccac.attribute12,
               ccac.attribute13,
               ccac.attribute14,
               ccac.attribute15,
               ccac.created_by,
               ccac.creation_date,
               ccac.last_updated_by,
               ccac.last_update_date,
               ccac.last_update_login,
               ccac.cc_func_withheld_amt,
               ccac.cc_ent_withheld_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
               ccac.Tax_Classif_Code
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;

-- -------------------------------------------------------------------------
-- Cursors used for obtaining a single line to be passed into the wrapper
-- functions for updating, inserting, deleting records from tables.
-- -------------------------------------------------------------------------
        CURSOR c_cc_acct_line IS
          SELECT *
            FROM igc_cc_acct_lines
           WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

        CURSOR c_det_pf_line IS
          SELECT *
            FROM igc_cc_det_pf
           WHERE cc_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id;

   l_full_path         VARCHAR2(255);

BEGIN

    l_full_path := g_path || 'Set_Encumbrance_Status';

  SAVEPOINT Set_Encumbrance_Status;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version,
             p_api_version,
             l_api_name,
             G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;
        l_validation_level := p_validation_level;
        l_update_login     := FND_GLOBAL.LOGIN_ID;
        l_update_by        := FND_GLOBAL.USER_ID;

  IF ( (NVL(p_encumbrance_status_code,'X') <> 'P') AND
       (NVL(p_encumbrance_status_code,'X') <> 'T') )
  THEN
    fnd_message.set_name('IGC', 'IGC_CC_INVALID_STATUS_CODE');
    fnd_message.set_token('CODE', p_encumbrance_status_code,TRUE);
                IF(g_error_level >= g_debug_level) THEN
                  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                END IF;
    fnd_msg_pub.add;
    RAISE E_INVALID_STATUS_CODE;

  END IF;

        BEGIN

    SELECT *
    INTO l_cc_headers_rec
    FROM igc_cc_headers
    WHERE cc_header_id = p_cc_header_id;

  EXCEPTION

    WHEN no_data_found
    THEN
      fnd_message.set_name('IGC', 'IGC_CC_NOT_FOUND');
      fnd_message.set_token('CC_NUM', to_char(p_cc_header_id),TRUE);
                    IF(g_excep_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;
      RAISE E_CC_NOT_FOUND;

  END;

  OPEN c_account_lines(p_cc_header_id);

  LOOP
    FETCH c_account_lines INTO l_cc_acct_lines_rec;

    EXIT WHEN c_account_lines%NOTFOUND;

-- ----------------------------------------------------------------------------------
-- Obtain the actual account line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                OPEN c_cc_acct_line;
                FETCH c_cc_acct_line
                 INTO l_acct_line_rec;

                IF (c_cc_acct_line%NOTFOUND) THEN
                   EXIT;
                END IF;

                CLOSE c_cc_acct_line;

                l_acct_line_rec.cc_acct_encmbrnc_status := p_encumbrance_status_code;
                l_acct_line_rec.last_update_date        := SYSDATE;
                l_acct_line_rec.last_update_login       := l_update_login;
                l_acct_line_rec.last_updated_by         := l_update_by;

                SELECT rowid
                  INTO l_row_id
                  FROM igc_cc_acct_lines
                 WHERE cc_acct_line_id = l_acct_line_rec.cc_acct_line_id;

                Account_Line_Wrapper (p_api_version       => l_api_version,
                                      p_init_msg_list     => FND_API.G_FALSE,
                                      p_commit            => FND_API.G_FALSE,
                                      p_validation_level  => l_validation_level,
                                      x_return_status     => l_return_status,
                                      x_msg_count         => l_msg_count,
                                      x_msg_data          => l_msg_data,
                                      x_rowid             => l_row_id,
                                      p_action_flag       => 'U',
                                      p_cc_acct_lines_rec => l_acct_line_rec,
                                      p_update_flag       => l_update_flag
                                     );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   x_msg_data  := l_msg_data;
                   x_msg_count := l_msg_count;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

    OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

    LOOP
      FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

      EXIT WHEN c_payment_forecast%NOTFOUND;

-- ----------------------------------------------------------------------------------
-- Obtain the actual Det PF line record based upon the data that was just retrieved
-- from the view.
-- ----------------------------------------------------------------------------------
                        OPEN c_det_pf_line;
                        FETCH c_det_pf_line
                         INTO l_det_pf_rec;

                        IF (c_det_pf_line%NOTFOUND) THEN
                           EXIT;
                        END IF;

                        CLOSE c_det_pf_line;

                        l_det_pf_rec.cc_det_pf_encmbrnc_status := p_encumbrance_status_code;
                        l_det_pf_rec.last_update_date          := SYSDATE;
                        l_det_pf_rec.last_update_login         := l_update_login;
                        l_det_pf_rec.last_updated_by           := l_update_by;

                        SELECT rowid
                          INTO l_row_id
                          FROM igc_cc_det_pf
                         WHERE cc_det_pf_line_id = l_det_pf_rec.cc_det_pf_line_id;

                        Det_Pf_Wrapper (p_api_version      => l_api_version,
                                        p_init_msg_list    => FND_API.G_FALSE,
                                        p_commit           => FND_API.G_FALSE,
                                        p_validation_level => l_validation_level,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data,
                                        x_rowid            => l_row_id,
                                        p_action_flag      => 'U',
                                        p_cc_pmt_fcst_rec  => l_det_pf_rec,
                                        p_update_flag      => l_update_flag
                                       );

                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                           x_msg_data  := l_msg_data;
                           x_msg_count := l_msg_count;
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;

    END LOOP;

    CLOSE c_payment_forecast;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;

  END LOOP;

  CLOSE c_account_lines;
        IF (c_cc_acct_line%ISOPEN) THEN
           CLOSE c_cc_acct_line;
        END IF;

        l_cc_headers_rec.cc_encmbrnc_status := p_encumbrance_status_code;
        l_cc_headers_rec.last_update_date   := SYSDATE;
        l_cc_headers_rec.last_update_login  := l_update_login;
        l_cc_headers_rec.last_updated_by    := l_update_by;

        SELECT rowid
          INTO l_row_id
          FROM igc_cc_headers
         WHERE cc_header_id = l_cc_headers_rec.cc_header_id;

        Header_Wrapper (p_api_version      => l_api_version,
                        p_init_msg_list    => FND_API.G_FALSE,
                        p_commit           => FND_API.G_FALSE,
                        p_validation_level => l_validation_level,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data,
                        x_rowid            => l_row_id,
                        p_action_flag      => 'U',
                        p_cc_header_rec    => l_cc_headers_rec,
                        p_update_flag      => l_update_flag
                       );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_msg_data  := l_msg_data;
           x_msg_count := l_msg_count;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  IF FND_API.To_Boolean(p_commit)
  THEN
           COMMIT WORK;
  END IF;

        RETURN;

EXCEPTION

  WHEN E_CC_NOT_FOUND OR E_INVALID_STATUS_CODE
  THEN
    ROLLBACK TO Set_Encumbrance_Status;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
        IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'E_CC_NOT_FOUND OR E_INVALID_STATUS_CODE  Exception Raised');
        END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Set_Encumbrance_Status;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );
        IF (g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR  Exception Raised');
        END IF;

  WHEN OTHERS
  THEN
    ROLLBACK TO Set_Encumbrance_Status;
    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                IF (c_payment_forecast%ISOPEN) THEN
                   CLOSE c_payment_forecast;
                END IF;
                IF (c_det_pf_line%ISOPEN) THEN
                   CLOSE c_det_pf_line;
                END IF;
                IF (c_account_lines%ISOPEN) THEN
                   CLOSE c_account_lines;
                END IF;
                IF (c_cc_acct_line%ISOPEN) THEN
                   CLOSE c_cc_acct_line;
                END IF;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
                IF ( g_unexp_level >= g_debug_level ) THEN
                   FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                   FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                   FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                   FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                END IF;

END Set_Encumbrance_Status;


PROCEDURE   Validate_CC
(
  p_api_version                 IN             NUMBER,
  p_init_msg_list               IN             VARCHAR2   := FND_API.G_FALSE,
  p_validation_level            IN             NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2,
  p_cc_header_id                IN             NUMBER,
  x_valid_cc                    OUT NOCOPY     VARCHAR2,
  p_mode              IN             VARCHAR2,
  p_field_from              IN             VARCHAR2,
  p_encumbrance_flag        IN             VARCHAR2,
  p_sob_id                      IN             NUMBER,
  p_org_id              IN             NUMBER,
  p_start_date              IN             DATE,
  p_end_date              IN             DATE,
  p_cc_type_code            IN             VARCHAR2,
  p_parent_cc_header_id       IN             NUMBER,
  p_cc_det_pf_date            IN             DATE,
  p_acct_date             IN             DATE,
  p_prev_acct_date            IN             DATE,
  p_cc_state              IN             VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2(30)     := 'Validate_CC';
  l_api_version           CONSTANT NUMBER           :=  1.0;
  l_cc_headers_rec        igc_cc_headers%ROWTYPE;
  l_cc_acct_lines_rec     igc_cc_acct_lines_v%ROWTYPE;
  l_cc_det_pf_lines_rec igc_cc_det_pf_v%ROWTYPE;
  l_cc_pmt_fcst_rec       igc_cc_det_pf_v%ROWTYPE;
  l_cc_acct_cnt         NUMBER := 0;
  l_total_pf_entered_amt  NUMBER := 0;
  l_cc_det_pf_cnt       NUMBER := 0;
  l_min_pf_date       DATE;
  l_max_pf_date       DATE;
  l_error_message         VARCHAR2(2000);
  e_cc_invalid_set_up     EXCEPTION;
  e_cc_not_found          EXCEPTION;
  e_no_det_pf           EXCEPTION;
  e_amt_mismatch          EXCEPTION;

  l_sbc_enable_flag   gl_sets_of_books.enable_budgetary_control_flag%TYPE := 'N';
  l_cbc_enable_flag igc_cc_bc_enable.cc_bc_enable_flag%TYPE     := 'N';
--  l_cc_prov_encmbrnc_flag igc_cc_encmbrnc_ctrls.cc_prov_encmbrnc_enable_flag%TYPE := 'N';
--  l_cc_conf_encmbrnc_flag igc_cc_encmbrnc_ctrls.cc_conf_encmbrnc_enable_flag%TYPE := 'N';
  l_cc_prov_encmbrnc_flag VARCHAR2(1);
  l_cc_conf_encmbrnc_flag VARCHAR2(1);
  l_orig_fiscal_year      gl_periods.period_year%TYPE;
  l_new_fiscal_year gl_periods.period_year%TYPE;

  l_COUNT     NUMBER;
  l_min_rel_start_date  DATE;
  l_cover_start_date  DATE;

  l_cover_end_date  DATE;
  l_max_rel_end_date  DATE;

        -- Bug 1830385, Bidisha S, 2 Jul 2001
        l_gl_application_id    fnd_application.application_id%TYPE := NULL;


  --  Contract Commitment account lines

-- Bug 2885953 - cursor below amended for performance enhancements
--    CURSOR c_account_lines(t_cc_header_id NUMBER) IS
--    SELECT *
--          FROM  igc_cc_acct_lines_v ccac
--          WHERE ccac.cc_header_id = t_cc_header_id;
  CURSOR c_account_lines(t_cc_header_id NUMBER) IS
  SELECT ccac.ROWID,
               ccac.cc_header_id,
               NULL org_id,
               NULL cc_type,
               NULL cc_type_code,
               NULL cc_num,
               ccac.cc_acct_line_id,
               ccac.cc_acct_line_num,
               ccac.cc_acct_desc,
               ccac.parent_header_id,
               ccac.parent_acct_line_id,
               NULL parent_cc_acct_line_num,
               NULL cc_budget_acct_desc,
               ccac.cc_budget_code_combination_id,
               NULL cc_charge_acct_desc,
               ccac.cc_charge_code_combination_id,
               ccac.cc_acct_entered_amt,
               ccac.cc_acct_func_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT(ccac.cc_acct_line_id) cc_acct_func_billed_amt,
               ccac.cc_acct_encmbrnc_amt,
               (IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0)) - NVL(ccac.cc_acct_encmbrnc_amt,0)) cc_acct_unencmrd_amt,
               ccac.cc_acct_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_acct_entered_amt,0))
               cc_acct_comp_func_amt,
               NULL project_number,
               ccac.project_id,
               NULL task_number,
               ccac.task_id,
               ccac.expenditure_type,
               NULL expenditure_org_name,
               ccac.expenditure_org_id,
               ccac.expenditure_item_date,
               ccac.cc_acct_taxable_flag,
               NULL tax_name,
               ccac.tax_id,
               ccac.cc_acct_encmbrnc_status,
               ccac.cc_acct_encmbrnc_date,
               ccac.context,
               ccac.attribute1,
               ccac.attribute2,
               ccac.attribute3,
               ccac.attribute4,
               ccac.attribute5,
               ccac.attribute6,
               ccac.attribute7,
               ccac.attribute8,
               ccac.attribute9,
               ccac.attribute10,
               ccac.attribute11,
               ccac.attribute12,
               ccac.attribute13,
               ccac.attribute14,
               ccac.attribute15,
               ccac.created_by,
               ccac.creation_date,
               ccac.last_updated_by,
               ccac.last_update_date,
               ccac.last_update_login,
               ccac.cc_func_withheld_amt,
               ccac.cc_ent_withheld_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccac.cc_header_id, NVL(ccac.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
               ccac.Tax_Classif_Code
        FROM  igc_cc_acct_lines ccac
        WHERE ccac.cc_header_id = t_cc_header_id;

  CURSOR c_det_pf_lines(t_cc_acct_line_id NUMBER) IS
        -- Performance Tuning, Replaced view
        -- igc_cc_det_pf_v with
        -- igc_cc_det_pf and replaced the line
        -- below.
  -- SELECT *
  -- FROM igc_cc_det_pf_v ccdpf
  -- WHERE ccdpf.cc_acct_line_id = t_cc_acct_line_id;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id, ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id, NVL(ccdpf.cc_det_pf_entered_amt,0) ) -
               NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) ) cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
  WHERE ccdpf.cc_acct_line_id = t_cc_acct_line_id;

        -- Bug 1830385, Bidisha S, 2 Jul 2001
        CURSOR c_gl_app_id IS
        SELECT application_id
        FROM   fnd_application
        WHERE  application_short_name = 'SQLGL';

        l_full_path         VARCHAR2(255);


  BEGIN

      l_full_path := g_path || 'Validate_CC';

    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_valid_cc      := FND_API.G_TRUE;

                -- Get the application id that will be used throughout the process.
                -- Bug 1830385, Bidisha S, 2 Jul 2001
                OPEN   c_gl_app_id;
                FETCH  c_gl_app_id INTO l_gl_application_id;
                CLOSE  c_gl_app_id;

  -- If encumbrance is enabled , the following validations helps in determining the  individual
  -- options like standard budgetary control , commitment budgetary control, provisional contract
  -- encumbrance set-up, confirmed contract encumbrance setups or enabled or not.
  -- If encumbrance is not enabled then the individual setups are defaulted to 'N'.

    IF p_encumbrance_flag = FND_API.G_TRUE THEN

      -- Standard Budgetary Control enabled or not

      BEGIN
      SELECT  NVL(enable_budgetary_control_flag,'N')
        INTO    l_sbc_enable_flag
        FROM    gl_sets_of_books
        WHERE   set_of_books_id = p_sob_id;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                                             x_valid_cc      := FND_API.G_FALSE;
                                             x_return_status := FND_API.G_RET_STS_ERROR;
               fnd_message.set_name('IGC', 'IGC_CC_INVALID_GL_DATA');
                                  IF(g_error_level >= g_debug_level) THEN
                                     FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                              END IF;
                           fnd_msg_pub.add;
                           RAISE E_CC_INVALID_SET_UP;
      END;

      --  Commitment Budgetary Control enabled or not

      IF ( NVL(l_sbc_enable_flag,'N') = 'Y')
      THEN
        BEGIN
          SELECT  cc_bc_enable_flag
          INTO     l_cbc_enable_flag
          FROM    igc_cc_bc_enable
          WHERE   set_of_books_id = p_sob_id;
          EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                l_cbc_enable_flag := 'N';
        END;


        -- Provisional Contract and Confirmed Contract can encumber or not.

                                IF l_cbc_enable_flag = 'Y'
                                THEN
/*Bug No : 6341012. SLA Uptake. IGC_CC_ENCMBRNC_CTRLS_V no more exists*/
          l_cc_prov_encmbrnc_flag := 'Y';
          l_cc_conf_encmbrnc_flag := 'Y';

/*            BEGIN
          SELECT cc_prov_encmbrnc_enable_flag,
                       cc_conf_encmbrnc_enable_flag
          INTO  l_cc_prov_encmbrnc_flag,
                        l_cc_conf_encmbrnc_flag
          FROM     igc_cc_encmbrnc_ctrls_v
          WHERE    org_id = p_org_id;
          EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  l_cc_prov_encmbrnc_flag := NULL;
                        l_cc_conf_encmbrnc_flag := NULL;
                                    END;
   */                           ELSE
            l_cc_prov_encmbrnc_flag := NULL;
                  l_cc_conf_encmbrnc_flag := NULL;

        END IF;
      END IF;  -- Commitment Budgetary Control enabled or not check ends here.

    END IF; -- Individual options setup based on encumbrance allowed or not check ends here.

        l_cc_prov_encmbrnc_flag := Nvl(l_cc_prov_encmbrnc_flag,'N');
        l_cc_conf_encmbrnc_flag := Nvl(l_cc_conf_encmbrnc_flag,'N');

  -- Date Validation begins here.


  IF p_mode = 'E'  AND p_field_from IS NOT NULL THEN          -- Entry Mode

         -- When Mode of call to the procedure is 'Entry' the following  validations should be performed.

  -- Start Date Validations begins here.

    IF ( p_start_date IS NOT NULL) AND p_field_from = 'START_DATE' THEN

      IF (p_end_date IS NOT NULL) THEN
                      IF p_end_date < p_start_date THEN
                                        x_valid_cc      := FND_API.G_FALSE;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('IGC', 'IGC_CC_EFFECTIVE_START_DATE');
                  fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE (P_START_DATE),FALSE);
                            IF(g_state_level >= g_debug_level) THEN
                              FND_LOG.MESSAGE(g_state_level, l_full_path, FALSE);
                            END IF;
            fnd_msg_pub.add;
        END IF;
      END IF;

      -- Encumbrance turned on or not check begins here.

      IF (p_encumbrance_flag = FND_API.G_FALSE) THEN

      -- Encumbrance is turned OFF.
      -- If encumbrance is off
      -- then start date is validated only against
      -- commitment budget and not against standard budget.

        BEGIN
                          SELECT count(*)
                          INTO l_COUNT
                          FROM gl_sets_of_books sob, gl_periods gp, igc_cc_periods cp
              WHERE sob.set_of_books_id = p_sob_id
          AND   sob.period_set_name = gp.period_set_name
          AND   cp.org_id = p_org_id
          AND  gp.period_set_name = cp.period_set_name
          AND  cp.period_name = gp.period_name
              AND  cp.cc_period_status IN ('O','F')
          AND  (p_start_date BETWEEN gp.start_date AND gp.end_date);
          EXCEPTION
                                           WHEN OTHERS THEN
                 l_COUNT := 0;
        END;

                          IF (NVL(l_COUNT,0) = 0) THEN
                                     x_valid_cc      := FND_API.G_FALSE;
                                     x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('IGC', 'IGC_CC_EFF_CCPER_START_DATE');
                 fnd_message.set_token('STARTDATE', FND_DATE.DATE_TO_CHARDATE (P_START_DATE),FALSE);
                                     IF(g_state_level >= g_debug_level) THEN
                                        FND_LOG.MESSAGE(g_state_level, l_full_path, FALSE);
                                     END IF;
                     fnd_msg_pub.add;
          END IF;

      ELSIF p_encumbrance_flag = FND_API.G_TRUE  AND
                 ( l_sbc_enable_flag = 'Y' )  AND
              ( l_cbc_enable_flag IN ('Y','N') AND
                  (l_cc_prov_encmbrnc_flag IN ('Y','N') AND l_cc_conf_encmbrnc_flag = 'Y')
                    )
      THEN

      -- Encumbrance turned ON.
      -- Standard budgetary control is on
      -- Commitment budgetary control is on or off.
      -- Provisional contract can encumber or not.
      -- Confirmed contract must encumber.

        BEGIN
                          SELECT  count(*)
                          INTO  l_COUNT
                          FROM  gl_sets_of_books sob,
                                                gl_period_statuses gl,
                                                igc_cc_periods cp
              WHERE   sob.set_of_books_id = p_sob_id
          AND   gl.set_of_books_id = sob.set_of_books_id
                            AND     gl.application_id = 101
          AND     cp.org_id = p_org_id
          AND   cp.period_set_name = sob.period_set_name
          AND   cp.period_name = gl.period_name
            AND     cp.cc_period_status IN ('O','F')
          AND     gl.closing_status IN ('O','F')
            AND     (p_start_date BETWEEN gl.start_date AND gl.end_date);
                        EXCEPTION
                               WHEN OTHERS THEN
                 l_COUNT := 0;
                                     IF ( g_unexp_level >= g_debug_level ) THEN
                                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                     END IF;
        END;

                         IF (NVL(l_COUNT,0) = 0) THEN
                                        x_valid_cc      := FND_API.G_FALSE;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('IGC', 'IGC_CC_EFF_CCGLPER_START_DATE');
             fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE(p_start_date),FALSE);
                               IF(g_error_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                               END IF;
                 fnd_msg_pub.add;
                        END IF;

      END IF; -- Encumbrance turned on or not condition ends here.


        IF (p_cc_type_code = 'C') AND (p_cc_header_id IS NOT NULL)
      THEN
        l_min_rel_start_date := NULL;
        BEGIN
              SELECT MIN(cch.cc_start_date)
              INTO  l_min_rel_start_date
              FROM igc_cc_headers  cch
              WHERE cch.parent_header_id = p_cc_header_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_min_rel_start_date := NULL;
        END ;

        IF (p_start_date > NVL(l_min_rel_start_date,p_start_date) )
        THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('IGC', 'IGC_CC_EFF_COVER_START_DATE');
                    fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE(P_START_DATE),FALSE);
                                IF(g_error_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
                fnd_msg_pub.add;
        END IF;
        END IF; -- Commitment Type is Cover


      IF (p_cc_type_code = 'R') THEN
        l_cover_start_date := NULL;
        BEGIN
              SELECT cch.cc_start_date
              INTO  l_cover_start_date
              FROM igc_cc_headers  cch
              WHERE cch.cc_header_id = p_parent_cc_header_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_cover_start_date := NULL;
        END ;

        IF (p_start_date <  NVL(l_cover_start_date,p_start_date) )
        THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('IGC', 'IGC_CC_EFF_REL_START_DATE');
                fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE (P_START_DATE),FALSE);
                                IF(g_error_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
                fnd_msg_pub.add;
        END IF;
        END IF;  -- Commitment Type is Release.

    ELSIF ( p_start_date IS  NULL) THEN
                    x_valid_cc      := FND_API.G_FALSE;
                    x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('IGC', 'IGC_CC_NO_START_DATE');
                    IF(g_error_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;

    END IF; -- Start Date is Not Null. Start Date Validations ends here.

    -- End Date Validations begins here.

    IF (p_end_date IS NOT NULL)  AND p_field_from = 'END_DATE' THEN

                  IF p_end_date < p_start_date THEN
                            x_valid_cc      := FND_API.G_FALSE;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('IGC', 'IGC_CC_EFFECTIVE_END_DATE');
              fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE (P_START_DATE),FALSE);
                        fnd_message.set_token('ENDDATE',FND_DATE.DATE_TO_CHARDATE (P_END_DATE),FALSE);
                            IF(g_error_level >= g_debug_level) THEN
                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                            END IF;
                fnd_msg_pub.add;
                  END IF;

      IF (p_cc_type_code = 'C') AND  (p_cc_header_id IS NOT NULL)
      THEN
        l_max_rel_end_date := NULL;
        BEGIN
              SELECT MAX(cch.cc_end_date)
              INTO  l_max_rel_end_date
              FROM igc_cc_headers  cch
              WHERE cch.parent_header_id = p_cc_header_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_max_rel_end_date := NULL;
        END ;

        IF (p_end_date < NVL(l_max_rel_end_date,p_end_date) )
        THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('IGC', 'IGC_CC_EFF_COVER_END_DATE');
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
                      fnd_msg_pub.add;
        END IF;
      END IF;  -- Commitment Type is Cover

      IF (p_cc_type_code = 'R') THEN
        l_cover_end_date := NULL;
        BEGIN
          SELECT cch.cc_end_date
            INTO  l_cover_end_date
              FROM igc_cc_headers  cch
              WHERE cch.cc_header_id = p_parent_cc_header_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_cover_end_date := NULL;
        END ;

        IF (p_end_date > NVL(l_cover_end_date,p_end_date) )
        THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('IGC', 'IGC_CC_EFF_REL_END_DATE');
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
                    fnd_msg_pub.add;
        END IF;
      END IF; -- Commitment Type is Release

                END IF; -- End Date is NOT NULL. End Date Validations ends here.


    -- Payment Forecast Date Validations begins here.
    IF ( p_cc_det_pf_date IS NOT NULL) AND p_field_from = 'DET_PF_DATE'  THEN

      -- Basic Validations

      IF (p_cc_det_pf_date < p_start_date) THEN
                            x_valid_cc      := FND_API.G_FALSE;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('IGC', 'IGC_CC_DET_PF_START_DATE');
                fnd_message.set_token('PFDATE',FND_DATE.DATE_TO_CHARDATE(p_cc_det_pf_date),FALSE);
                            IF(g_error_level >= g_debug_level) THEN
                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                            END IF;
            fnd_msg_pub.add;
                  END IF;
      IF ( (p_cc_det_pf_date > p_end_date) AND
                           (p_end_date IS NOT NULL)
                         ) THEN
                            x_valid_cc      := FND_API.G_FALSE;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('IGC', 'IGC_CC_DET_PF_END_DATE');
            fnd_message.set_token('PFDATE',FND_DATE.DATE_TO_CHARDATE(p_cc_det_pf_date),FALSE);
                            IF(g_error_level >= g_debug_level) THEN
                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                            END IF;
                    fnd_msg_pub.add;
      END IF;

      -- Budgetary Control  turned on.

      IF p_encumbrance_flag = FND_API.G_TRUE THEN
        BEGIN
                                        -- Performance Tuning, replaced
                                        -- view gl_period_statuses_v with
                                        -- gl_period_statuses
                    SELECT  count(*)
                        INTO  l_COUNT
          FROM  gl_sets_of_books sob,
                                    gl_period_statuses gl,
                                    igc_cc_periods cp
            WHERE   sob.set_of_books_id = p_sob_id
          AND   gl.set_of_books_id = sob.set_of_books_id
                            AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
          AND     cp.org_id = p_org_id
          AND   cp.period_set_name = sob.period_set_name
          AND   cp.period_name = gl.period_name
            AND     cp.cc_period_status IN ('O','F')
          AND     gl.closing_status IN ('O','F')
                        AND     (p_cc_det_pf_date BETWEEN gl.start_date AND gl.end_date);
                      EXCEPTION
                       WHEN OTHERS THEN
            l_COUNT := 0;
                                IF ( g_unexp_level >= g_debug_level ) THEN
                                    FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                    FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                    FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                    FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                END IF;
        END;
        IF NVL(l_COUNT,0) = 0  THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_DET_PF_DATE');
                                IF(g_error_level >= g_debug_level) THEN
                                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
                      fnd_msg_pub.add;
        END IF;
      END IF; -- Budgetary Control turned on.
    END IF; -- Payment Forecast Date is NOT NULL. Payment Forecast Date Validations ends here.

    -- Encumbrance Accounting Date Validations begins here.

    IF  p_field_from = 'ENCUMBRANCE' THEN
                        IF NVL(l_cbc_enable_flag,'N') = 'Y' THEN

                         -- Bug # 1678518.

                             IF  (p_cc_state = 'PR'  OR p_cc_state = 'CM') THEN
        IF ( ( p_acct_date < NVL(p_start_date,p_acct_date) )  OR
                   ( p_acct_date > NVL(p_end_date,p_acct_date)   )
                           )
                 OR ( p_acct_date IS NULL)
                 OR (p_acct_date < p_prev_acct_date AND
               p_prev_acct_date IS NOT NULL)
        THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE');
                  fnd_message.set_token('ACCTDATE',FND_DATE.DATE_TO_CHARDATE(P_ACCT_DATE),FALSE);
                  fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE(P_START_DATE),FALSE);
                              fnd_message.set_token('ENDDATE',FND_DATE.DATE_TO_CHARDATE(P_END_DATE),FALSE);
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
                      fnd_msg_pub.add;
        END IF;

                         -- Bug # 1678518.

           ELSIF (p_cc_state = 'CL'  OR p_cc_state = 'CT') THEN
        IF ( p_acct_date IS NULL)
                 OR ( (p_acct_date  NOT BETWEEN p_prev_acct_date AND SYSDATE) AND
                 p_prev_acct_date IS NOT NULL AND
                                   p_prev_acct_date < SYSDATE)
        THEN
                                        x_valid_cc      := FND_API.G_FALSE;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                      fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE_CL_CT');
                      fnd_message.set_token('ACCTDATE',FND_DATE.DATE_TO_CHARDATE(P_ACCT_DATE),FALSE);
                      fnd_message.set_token('PREV_ACCTDATE',FND_DATE.DATE_TO_CHARDATE(P_PREV_ACCT_DATE),FALSE);
                                        IF(g_error_level >= g_debug_level) THEN
                                           FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                        END IF;
                          fnd_msg_pub.add;
              END IF;
            END IF;
      END IF;

      -- Encumbrance turned ON.

      IF p_encumbrance_flag = FND_API.G_TRUE  AND
           (l_sbc_enable_flag = 'Y' )  AND
             ( l_cbc_enable_flag IN ('Y','N') AND
                      (l_cc_prov_encmbrnc_flag IN ('Y','N') AND (l_cc_conf_encmbrnc_flag = 'Y'))
         )
          THEN

        -- Encumbrance turned ON.
        -- Standard budgetary control is on
        -- Commitment budgetary control is on or off.
        -- Provisional contract can encumber or not.
        -- Confirmed contract must encumber.
        IF (p_cc_state = 'PR'  OR p_cc_state = 'CL') AND
                 (l_cc_prov_encmbrnc_flag ='Y' AND l_cc_conf_encmbrnc_flag = 'Y')
        THEN
          BEGIN
                                                -- Performance Tuning, replaced
                                                -- view gl_period_statuses_v with
                                                -- gl_period_statuses
                              SELECT  count(*)
                            INTO  l_COUNT
                FROM  gl_sets_of_books sob,
                        gl_period_statuses gl,
                        igc_cc_periods cp
                WHERE   sob.set_of_books_id = p_sob_id
            AND   gl.set_of_books_id = sob.set_of_books_id
                                AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
            AND     cp.org_id = p_org_id
            AND   cp.period_set_name = sob.period_set_name
            AND   cp.period_name = gl.period_name
              AND     cp.cc_period_status IN ('O','F')
            AND     gl.closing_status IN ('O','F')
                          AND     (p_acct_date BETWEEN gl.start_date AND gl.end_date);
                          EXCEPTION
                             WHEN OTHERS THEN
               l_COUNT := 0;
                                     IF ( g_unexp_level >= g_debug_level ) THEN
                                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                     END IF;

                      END;
          IF NVL(l_COUNT,0) = 0  THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE_OF');
                                IF(g_error_level >= g_debug_level) THEN
                                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
                      fnd_msg_pub.add;
          END IF;

          -- Bug # 1619201.
          -- If Previously been encumbered.
          -- Fiscal Year Mismatch Valdn begins here.
          IF p_prev_acct_date IS NOT NULL
          THEN
            -- Original Fiscal Year
            BEGIN
                                                        -- Performance Tuning, Replaced
                                                        -- the following query with the
                                                        -- one below as we are only
                                                        -- interested in the fiscal years.
              -- SELECT   DISTINCT cp.period_year
              -- INTO   l_orig_fiscal_year
              -- FROM   gl_sets_of_books sob,
              --  gl_period_statuses_v gl,
              --  igc_cc_periods_v cp
              -- WHERE  sob.set_of_books_id = p_sob_id
              -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                        -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
              -- AND     cp.org_id = p_org_id
              -- AND     cp.period_set_name= sob.period_set_name
              -- AND     cp.period_name = gl.period_name
              -- AND  (p_prev_acct_date BETWEEN cp.start_date AND cp.end_date
                    --  );
                                                        SELECT  distinct gl.period_year
                                  INTO    l_orig_fiscal_year
                                                        FROM  gl_sets_of_books sob,
                                                                gl_periods gl
                                                        WHERE   sob.set_of_books_id = p_sob_id
                                                        AND     gl.period_set_name= sob.period_set_name
                                                        AND     gl.period_type = sob.accounted_period_type
                                                        AND    (p_prev_acct_date between gl.start_date and gl.end_date);
            END;
            -- New Fiscal Year if any.
            BEGIN
                                                        -- Performance Tuning, Replaced
                                                        -- the following query with the
                                                        -- one below as we are only
                                                        -- interested in the fiscal years.
              -- SELECT   DISTINCT cp.period_year
              -- INTO   l_new_fiscal_year
              -- FROM   gl_sets_of_books sob,
              --  gl_period_statuses_v gl,
              --  igc_cc_periods_v cp
              -- WHERE  sob.set_of_books_id = p_sob_id
              -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                        -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
              -- AND     cp.org_id = p_org_id
              -- AND     cp.period_set_name= sob.period_set_name
              -- AND     cp.period_name = gl.period_name
              -- AND  (p_acct_date BETWEEN cp.start_date AND cp.end_date
              --         );
                                                        SELECT  distinct gl.period_year
                                  INTO    l_new_fiscal_year
                                                        FROM  gl_sets_of_books sob,
                                                                gl_periods gl
                                                        WHERE   sob.set_of_books_id = p_sob_id
                                                        AND     gl.period_set_name= sob.period_set_name
                                                        AND     gl.period_type = sob.accounted_period_type
                                                        AND    (p_acct_date between gl.start_date and gl.end_date);
            END;
            IF l_orig_fiscal_year <> l_new_fiscal_year
            THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_ACCT_FISCAL_YRS_NE');
              fnd_message.set_TOKEN('PREVACTDATE',FND_DATE.DATE_TO_CHARDATE (p_prev_acct_date),FALSE);
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
              fnd_msg_pub.add;
            END IF; -- Fiscal Year Mismatch valdn ends here.
          END IF; -- If Previously been encumbered. Bug # 1619201.

        ELSIF (p_cc_state = 'CM' OR p_cc_state = 'CT')
        THEN
          BEGIN
                                                -- Performance Tuning, replaced
                                                -- view gl_period_statuses_v with
                                                -- gl_period_statuses
                            SELECT  count(*)
                          INTO  l_COUNT
            FROM  gl_sets_of_books sob,
                        gl_period_statuses gl,
                        igc_cc_periods cp
              WHERE   sob.set_of_books_id = p_sob_id
            AND   gl.set_of_books_id = sob.set_of_books_id
                                AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
            AND     cp.org_id = p_org_id
            AND   cp.period_set_name = sob.period_set_name
            AND   cp.period_name = gl.period_name
              AND     cp.cc_period_status = 'O'
            AND     gl.closing_status = 'O'
                          AND     (p_acct_date BETWEEN gl.start_date AND gl.end_date);
                          EXCEPTION
                             WHEN OTHERS THEN
                 l_COUNT := 0;
                                     IF ( g_unexp_level >= g_debug_level ) THEN
                                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                     END IF;
                      END;
          IF NVL(l_COUNT,0) = 0  THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE_O');
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
                        fnd_msg_pub.add;
          END IF;
        END IF;
      END IF; -- Encumbrance turned on.
    END IF;  -- Encumbrance Account Date Validations ends here.

    -- Approval Accounting Date Validations begins here.

    IF p_field_from = 'APPROVAL' THEN
      IF NVL(l_cbc_enable_flag,'N') = 'Y' THEN

                         -- Bug # 1678518.

           IF (p_cc_state = 'PR'  OR p_cc_state = 'CM') THEN
        IF ( ( p_acct_date < NVL(p_start_date,p_acct_date) ) OR
                   ( p_acct_date > NVL(p_end_date,p_acct_date) )
                 )
               OR ( p_acct_date IS NULL)
               OR (p_acct_date < p_prev_acct_date AND
               p_prev_acct_date IS NOT NULL)
        THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE');
              fnd_message.set_token('ACCTDATE',FND_DATE.DATE_TO_CHARDATE(P_ACCT_DATE),FALSE);
              fnd_message.set_token('STARTDATE',FND_DATE.DATE_TO_CHARDATE(P_START_DATE),FALSE);
              fnd_message.set_token('ENDDATE',FND_DATE.DATE_TO_CHARDATE(P_END_DATE),FALSE);
                                IF(g_error_level >= g_debug_level) THEN
                                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
              fnd_msg_pub.add;
                      END IF;

                         -- Bug # 1678518.

           ELSIF (p_cc_state = 'CL'  OR p_cc_state = 'CT') THEN
        IF ( p_acct_date IS NULL)
                 OR ( (p_acct_date  NOT BETWEEN p_prev_acct_date AND SYSDATE) AND
                 p_prev_acct_date IS NOT NULL AND
                                         p_prev_acct_date < SYSDATE)
        THEN
                                 x_valid_cc      := FND_API.G_FALSE;
                                 x_return_status := FND_API.G_RET_STS_ERROR;
               fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE_CL_CT');
               fnd_message.set_token('ACCTDATE',FND_DATE.DATE_TO_CHARDATE(P_ACCT_DATE),FALSE);
               fnd_message.set_token('PREV_ACCTDATE',FND_DATE.DATE_TO_CHARDATE(P_PREV_ACCT_DATE),FALSE);
                                 IF(g_error_level >= g_debug_level) THEN
                                    FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                 END IF;
                     fnd_msg_pub.add;
              END IF;
            END IF;
      END IF;

      -- Encumbrance turned ON.

      IF p_encumbrance_flag = FND_API.G_TRUE  AND
                (l_sbc_enable_flag = 'Y' )  AND
                ( l_cbc_enable_flag IN ('Y','N') AND
               (l_cc_prov_encmbrnc_flag IN ('Y','N') AND (l_cc_conf_encmbrnc_flag = 'Y'))
        )
            THEN

        -- Encumbrance turned ON.
        -- Standard budgetary control is on
        -- Commitment budgetary control is on or off.
        -- Provisional contract can encumber or not.
        -- Confirmed contract must encumber.
        IF (p_cc_state = 'PR'  OR p_cc_state = 'CL') AND
                 (l_cc_prov_encmbrnc_flag ='Y' AND l_cc_conf_encmbrnc_flag = 'Y')
        THEN
          BEGIN
                                                -- Performance Tuning, replaced
                                                -- view gl_period_statuses_v with
                                                -- gl_period_statuses
                            SELECT  count(*)
                          INTO  l_COUNT
            FROM  gl_sets_of_books sob,
                        gl_period_statuses gl,
                        igc_cc_periods cp
              WHERE   sob.set_of_books_id = p_sob_id
            AND   gl.set_of_books_id = sob.set_of_books_id
                                AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
            AND      cp.org_id = p_org_id
            AND   cp.period_set_name = sob.period_set_name
            AND   cp.period_name = gl.period_name
              AND      cp.cc_period_status IN ('O','F')
            AND      gl.closing_status IN ('O','F')
                          AND      (p_acct_date BETWEEN gl.start_date AND gl.end_date);
                          EXCEPTION
                             WHEN OTHERS THEN
                 l_COUNT := 0;
                                     IF ( g_unexp_level >= g_debug_level ) THEN
                                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                     END IF;
                      END;
          IF NVL(l_COUNT,0) = 0  THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE_OF');
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
                        fnd_msg_pub.add;
          END IF;

          -- Bug # 1619201.
          -- If Previously been encumbered.
          -- Fiscal Year Mismatch Valdn begins here.
          IF p_prev_acct_date IS NOT NULL
          THEN
            -- Original Fiscal Year
            BEGIN
                                                        -- Performance Tuning, Replaced
                                                        -- the following query with the
                                                        -- one below as we are only
                                                        -- interested in the fiscal years.
              -- SELECT   DISTINCT cp.period_year
              -- INTO   l_orig_fiscal_year
              -- FROM   gl_sets_of_books sob,
              --  gl_period_statuses_v gl,
              --  igc_cc_periods_v cp
              -- WHERE  sob.set_of_books_id = p_sob_id
              -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                        -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
              -- AND     cp.org_id = p_org_id
              -- AND     cp.period_set_name= sob.period_set_name
              -- AND     cp.period_name = gl.period_name
              -- AND  (p_prev_acct_date BETWEEN cp.start_date AND cp.end_date
                    --  );
                                    SELECT  distinct gl.period_year
              INTO    l_orig_fiscal_year
                                    FROM  gl_sets_of_books sob,
                                            gl_periods gl
                                    WHERE   sob.set_of_books_id = p_sob_id
                                    AND     gl.period_set_name= sob.period_set_name
                                    AND     gl.period_type = sob.accounted_period_type
                                    AND     (p_prev_acct_date between gl.start_date and gl.end_date);
            END;
            -- New Fiscal Year if any.
            BEGIN
                                                        -- Performance Tuning, Replaced
                                                        -- the following query with the
                                                        -- one below as we are only
                                                        -- interested in the fiscal years.
              -- SELECT   DISTINCT cp.period_year
              -- INTO   l_new_fiscal_year
              -- FROM   gl_sets_of_books sob,
              --  gl_period_statuses_v gl,
              --  igc_cc_periods_v cp
              -- WHERE  sob.set_of_books_id = p_sob_id
              -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                        -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
              -- AND     cp.org_id = p_org_id
              -- AND     cp.period_set_name= sob.period_set_name
              -- AND     cp.period_name = gl.period_name
              -- AND  (p_acct_date BETWEEN cp.start_date AND cp.end_date
              --         );
                                    SELECT  distinct gl.period_year
              INTO    l_new_fiscal_year
                                    FROM  gl_sets_of_books sob,
                                            gl_periods gl
                                    WHERE   sob.set_of_books_id = p_sob_id
                                    AND     gl.period_set_name= sob.period_set_name
                                    AND     gl.period_type = sob.accounted_period_type
                                    AND    (p_acct_date between gl.start_date and gl.end_date);
            END;
            IF l_orig_fiscal_year <> l_new_fiscal_year
            THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_ACCT_FISCAL_YRS_NE');
              fnd_message.set_TOKEN('PREVACTDATE',FND_DATE.DATE_TO_CHARDATE (p_prev_acct_date),FALSE);
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
              fnd_msg_pub.add;
            END IF; -- Fiscal Year Mismatch valdn ends here.
          END IF; -- If Previously been encumbered. Bug # 1619201.

        ELSIF (p_cc_state = 'CM' OR p_cc_state = 'CT')
        THEN
          BEGIN
                                                -- Performance Tuning, replaced
                                                -- view gl_period_statuses_v with
                                                -- gl_period_statuses
                            SELECT  count(*)
                          INTO  l_COUNT
            FROM  gl_sets_of_books sob,
                      gl_period_statuses gl,
                            igc_cc_periods cp
              WHERE   sob.set_of_books_id = p_sob_id
            AND   gl.set_of_books_id = sob.set_of_books_id
                                AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
            AND     cp.org_id = p_org_id
            AND   cp.period_set_name = sob.period_set_name
            AND   cp.period_name = gl.period_name
              AND      cp.cc_period_status = 'O'
            AND      gl.closing_status = 'O'
                          AND      (p_acct_date BETWEEN gl.start_date AND gl.end_date);
                          EXCEPTION
                             WHEN OTHERS THEN
               l_COUNT := 0;
                                     IF ( g_unexp_level >= g_debug_level ) THEN
                                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                     END IF;
                      END;
          IF NVL(l_COUNT,0) = 0  THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('IGC', 'IGC_CC_ACCT_DATE_O');
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
                        fnd_msg_pub.add;
          END IF;
        END IF;
      END IF; -- Encumbrance turned on.
    END IF;  -- Approval Accounting Date Validations ends here.

  ELSIF p_mode = 'T'  THEN

  -- When Mode of call to the procedure is 'T' stands for 'Transition' the following validations should be
  -- performed.
    BEGIN
      SELECT *
      INTO l_cc_headers_rec
      FROM igc_cc_headers
      WHERE cc_header_id = p_cc_header_id;
      EXCEPTION
                       WHEN no_data_found THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('IGC', 'IGC_CC_NOT_FOUND');
                fnd_message.set_token('CC_NUM', to_char(p_cc_header_id),TRUE);
                                IF(g_error_level >= g_debug_level) THEN
                                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
                l_error_message := fnd_message.get;
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name, l_error_message);
                RAISE E_CC_NOT_FOUND;

    END;


    -- Check only for Contract that are transition to confirmed and
          -- has an approval status of incomplete and
                -- has an encumbrance status as 'T'.

    IF ((l_cc_headers_rec.cc_state = 'CM') AND
                   (l_cc_headers_rec.cc_apprvl_status = 'IN') AND
                   (l_cc_headers_rec.cc_encmbrnc_status = 'T')) OR
                -- Bug 2656232, following 2 lines added.
                   (l_cc_headers_rec.cc_state = 'PR' AND
                    l_cc_headers_rec.cc_apprvl_status = 'IN')
                THEN

        l_cc_acct_cnt   := 0;

        OPEN c_account_lines(p_cc_header_id);
        LOOP
      l_total_pf_entered_amt := 0;

      FETCH c_account_lines INTO l_cc_acct_lines_rec;

      EXIT WHEN c_account_lines%NOTFOUND;
      l_cc_acct_cnt   := l_cc_acct_cnt + 1;

      l_cc_det_pf_cnt   := 0;

      BEGIN
                                -- Performance Tuning, Replaced view
                                -- igc_cc_det_pf_v with
                                -- igc_cc_det_pf
        SELECT count(*)
        INTO l_cc_det_pf_cnt
        FROM igc_cc_det_pf
        WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_cc_det_pf_cnt := 0;
      END;
      IF (NVL(l_cc_det_pf_cnt ,0) = 0)
                        AND l_cc_acct_lines_rec.cc_ent_withheld_amt <> l_cc_acct_lines_rec.cc_acct_entered_amt
                        -- And clause added for 2043221, Bidisha S , 12 Oct 2001
                        -- Perform this validation only if the withheld amount is not equal to
                        -- the amount in the account line
                        THEN
                             x_valid_cc      := FND_API.G_FALSE;
                             x_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('IGC', 'IGC_CC_NO_PF');
             fnd_message.set_token('ACCT_NUM', to_char(l_cc_acct_lines_rec.cc_acct_line_num),TRUE);
                             IF(g_error_level >= g_debug_level) THEN
                                FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                             END IF;
             fnd_msg_pub.add;
      ELSIF (NVL(l_cc_det_pf_cnt,0) > 0) THEN

        OPEN c_det_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
        LOOP

          FETCH c_det_pf_lines INTO l_cc_det_pf_lines_rec;

          EXIT WHEN c_det_pf_lines%NOTFOUND;
          l_cc_det_pf_cnt   := l_cc_det_pf_cnt + 1;

          -- PF Date vs Accounting Date Validation.

          IF (l_cc_det_pf_lines_rec.cc_det_pf_date < p_acct_date) THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('IGC', 'IGC_CC_DET_PF_ACCT_DATE');
                fnd_message.set_TOKEN('PFDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_date),FALSE);
                fnd_message.set_TOKEN('ACCTDATE',FND_DATE.DATE_TO_CHARDATE (p_acct_date),FALSE);
                                IF(g_error_level >= g_debug_level) THEN
                                   FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
            fnd_msg_pub.add;
          END IF;


        END LOOP; -- Payment Forecast Loop end here.

        CLOSE c_det_pf_lines;

      END IF;

       END LOOP;

       CLOSE c_account_lines;

       IF (l_cc_acct_cnt = 0)  THEN
                        x_valid_cc      := FND_API.G_FALSE;
                        x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('IGC', 'IGC_CC_NO_ACCT_LINES');
      fnd_message.set_token('CC_NUM', l_cc_headers_rec.cc_num,TRUE);
                    IF(g_error_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                    END IF;
      fnd_msg_pub.add;
        END IF;
    END IF;


  ELSIF p_mode = 'V'  THEN

  -- When Mode of call to the procedure is 'V' stands for 'Validate' the following validations should be
  -- performed.
    BEGIN
      SELECT *
      INTO l_cc_headers_rec
      FROM igc_cc_headers
      WHERE cc_header_id = p_cc_header_id;
      EXCEPTION
                       WHEN no_data_found THEN
                                     x_valid_cc      := FND_API.G_FALSE;
                                     x_return_status := FND_API.G_RET_STS_ERROR;
                     fnd_message.set_name('IGC', 'IGC_CC_NOT_FOUND');
                     fnd_message.set_token('CC_NUM', to_char(p_cc_header_id),TRUE);
                                     IF(g_error_level >= g_debug_level) THEN
                                         FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                     END IF;
                     l_error_message := fnd_message.get;
                     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name, l_error_message);
                     RAISE E_CC_NOT_FOUND;

    END;


    -- Check only for provisional and confirmed states

    IF (l_cc_headers_rec.cc_state = 'PR') OR (l_cc_headers_rec.cc_state = 'CM')  THEN

        l_cc_acct_cnt   := 0;

        OPEN c_account_lines(p_cc_header_id);
        LOOP
      l_total_pf_entered_amt := 0;

      FETCH c_account_lines INTO l_cc_acct_lines_rec;

      EXIT WHEN c_account_lines%NOTFOUND;
      l_cc_acct_cnt   := l_cc_acct_cnt + 1;

      l_cc_det_pf_cnt   := 0;

      BEGIN
                                -- Performance Tuning, Replaced view
                                -- igc_cc_det_pf_v with
                                -- igc_cc_det_pf and replaced the line
                                -- below.
        SELECT count(*)
        INTO l_cc_det_pf_cnt
        FROM igc_cc_det_pf
        WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_cc_det_pf_cnt := 0;
      END;
      IF (NVL(l_cc_det_pf_cnt ,0) = 0)
                        AND l_cc_acct_lines_rec.cc_ent_withheld_amt <> l_cc_acct_lines_rec.cc_acct_entered_amt
                        -- And clause added for 2043221, Bidisha S , 12 Oct 2001
                        -- Perfom this validation only if the withheld amount is not equal to
                        -- the amount in the account line
                        THEN
                              x_valid_cc      := FND_API.G_FALSE;
                              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_NO_PF');
              fnd_message.set_token('ACCT_NUM', to_char(l_cc_acct_lines_rec.cc_acct_line_num),TRUE);
                              IF(g_error_level >= g_debug_level) THEN
                                 FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                              END IF;
              fnd_msg_pub.add;
      ELSIF (NVL(l_cc_det_pf_cnt,0) > 0) THEN

        OPEN c_det_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
        LOOP

          FETCH c_det_pf_lines INTO l_cc_det_pf_lines_rec;

          EXIT WHEN c_det_pf_lines%NOTFOUND;
          l_cc_det_pf_cnt   := l_cc_det_pf_cnt + 1;

          -- PF Date vs Start Date Validation.

          IF (l_cc_det_pf_lines_rec.cc_det_pf_date < p_start_date) THEN
                                x_valid_cc      := FND_API.G_FALSE;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('IGC', 'IGC_CC_DET_PF_START_DATE');
                fnd_message.set_TOKEN('PFDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_date),FALSE);
                                IF (g_error_level >= g_debug_level) THEN
                                    FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                END IF;
            fnd_msg_pub.add;
          END IF;

          -- PF Date vs End Date Validation.

          IF ( (l_cc_det_pf_lines_rec.cc_det_pf_date > p_end_date) AND
                               (p_end_date IS NOT NULL)
                           ) THEN
                                  x_valid_cc      := FND_API.G_FALSE;
                                  x_return_status := FND_API.G_RET_STS_ERROR;
                            fnd_message.set_name('IGC', 'IGC_CC_DET_PF_END_DATE');
              fnd_message.set_TOKEN('PFDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_date),FALSE);
                                  IF(g_error_level >= g_debug_level) THEN
                                     FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                  END IF;
              fnd_msg_pub.add;
          END IF;

                    -- bug 5667529
                    -- changes done by kasbalas
          -- the validation for the pf date to be in a open period
          -- is done here instead of in the if loop below.
          -- this is beign done here since the check needs to be
          -- maintained even of the DBc is disabled or the
          -- computed fucntional amount and encumberence amount
          -- match or mismatch
		IF ( NVL(l_cc_det_pf_lines_rec.cc_det_pf_comp_func_amt,0) <>
		            NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) ) THEN  -- Added for Bug 9366764

          BEGIN
                             -- Performance Tuning, replaced
                             -- view gl_period_statuses_v with
                             -- gl_period_statuses
                    SELECT  count(*)
                          INTO  l_COUNT
                          FROM  gl_sets_of_books sob,
                    gl_period_statuses gl,
                  igc_cc_periods cp
                 WHERE  sob.set_of_books_id = p_sob_id
               AND  gl.set_of_books_id = sob.set_of_books_id
                           AND  gl.application_id  = l_gl_application_id   -- Bug 1830385
               AND  cp.org_id = p_org_id
                 AND  cp.period_set_name = sob.period_set_name
               AND  cp.period_name = gl.period_name
                 AND  cp.cc_period_status IN ('O','F')
                 AND  gl.closing_status IN ('O','F')
                 AND  (l_cc_det_pf_lines_rec.cc_det_pf_date
                 BETWEEN gl.start_date AND gl.end_date
                 );
                    EXCEPTION
                       WHEN OTHERS THEN
               l_COUNT := 0;
                           IF ( g_unexp_level >= g_debug_level ) THEN
                               FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                               FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                            END IF;
          END;
          IF NVL(l_COUNT,0) = 0  THEN
                        x_valid_cc      := FND_API.G_FALSE;
                        x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_DET_PF_DATE');
                        IF(g_error_level >= g_debug_level) THEN
                           FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                        END IF;
                    fnd_msg_pub.add;
          END IF;
		  END IF; -- ending the If Condition added for bug 9366764
          -- Encumbrance turned ON.
          -- Bug 1623034. Commitment Type should not be a RELEASE.

          IF p_encumbrance_flag = FND_API.G_TRUE  AND
                 (  (l_sbc_enable_flag = 'Y' )  AND
                      ( ( l_cbc_enable_flag IN ('Y','N') AND
                            (l_cc_prov_encmbrnc_flag IN ('Y','N') AND
                     (l_cc_conf_encmbrnc_flag = 'Y')
              )
                  )
                      )
                   ) AND
             l_cc_headers_rec.cc_type <> 'R'
          THEN

            -- Encumbrance turned ON.
            -- Standard budgetary control is on
            -- Commitment budgetary control is on or off.
            -- Provisional contract can encumber or not.
            -- Confirmed contract must encumber.

            IF ( NVL(l_cc_det_pf_lines_rec.cc_det_pf_comp_func_amt,0) <>
               NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) )
            THEN
                -- Bug 5667529
                -- changes done by kasbalas
                -- removed teh pf validation code to be outside
                -- this if loop since the check needs to be
                    -- maintained even of the DBc is disabled or the
                  -- computed fucntional amount and encumberence
              -- amount match or mismatch
              NULL;

            -- PF Functional and Encumbered Amt Different ends here.

            ELSIF (NVL(l_cc_det_pf_lines_rec.cc_det_pf_comp_func_amt,0) =
                NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) )
            THEN
            -- PF Functional and Encumbered Amt  are same starts here.
              IF ( ( ( l_cc_prov_encmbrnc_flag  = 'Y'  AND
                               (l_cc_conf_encmbrnc_flag = 'Y')
                ) OR
                           ( (l_cc_prov_encmbrnc_flag = 'N') AND
                             (l_cc_conf_encmbrnc_flag = 'Y') AND
                             (l_cc_headers_rec.cc_state = 'CM')
                )
                       ) AND
                           (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_status <> 'T')
                 )
              THEN
                   IF TRUNC(l_cc_det_pf_lines_rec.cc_det_pf_date ) <>
                TRUNC(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date)
                   THEN
                                             x_valid_cc      := FND_API.G_FALSE;
                                             x_return_status := FND_API.G_RET_STS_ERROR;
                     fnd_message.set_name('IGC','IGC_CC_DET_PF_DATE_NO_UPDATE');
                     fnd_message.set_TOKEN('ENCMBRNCDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date),FALSE);
                                             IF(g_error_level >= g_debug_level) THEN
                                                FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                             END IF;
                             fnd_msg_pub.add;
                   END IF;
              END IF;
            END IF ; -- PF Functional and Encumbered Amt  are same.

            -- Encumbrance Amount is greater than zero.
            IF NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) >  0
            THEN
                 -- Original Fiscal Year
               BEGIN
                                                        -- Performance Tuning, Replaced
                                                        -- the following query with the
                                                        -- one below as we are only
                                                        -- interested in the fiscal years.
              -- SELECT   DISTINCT cp.period_year
              -- INTO   l_orig_fiscal_year
              -- FROM   gl_sets_of_books sob,
              --  gl_period_statuses_v gl,
              --  igc_cc_periods_v cp
              -- WHERE  sob.set_of_books_id = p_sob_id
              -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                        -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
              -- AND     cp.org_id = p_org_id
              -- AND     cp.period_set_name= sob.period_set_name
              -- AND     cp.period_name = gl.period_name
              -- AND  (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date
              -- BETWEEN cp.start_date AND cp.end_date
                    -- );
                                    SELECT  distinct gl.period_year
              INTO    l_orig_fiscal_year
                                    FROM  gl_sets_of_books sob,
                                            gl_periods gl
                                    WHERE   sob.set_of_books_id = p_sob_id
                                    AND     gl.period_set_name= sob.period_set_name
                                    AND     gl.period_type = sob.accounted_period_type
                                    AND    (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date between gl.start_date and gl.end_date);
                 END;
              -- New Fiscal Year if any.
               BEGIN
                                                        -- Performance Tuning, Replaced
                                                        -- the following query with the
                                                        -- one below as we are only
                                                        -- interested in the fiscal years.
              -- SELECT   DISTINCT cp.period_year
              -- INTO   l_new_fiscal_year
              -- FROM   gl_sets_of_books sob,
              --  gl_period_statuses_v gl,
              --  igc_cc_periods_v cp
              -- WHERE  sob.set_of_books_id = p_sob_id
              -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                        -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
              -- AND     cp.org_id = p_org_id
              -- AND     cp.period_set_name= sob.period_set_name
              -- AND     cp.period_name = gl.period_name
              -- AND  ( l_cc_det_pf_lines_rec.cc_det_pf_date
              --    BETWEEN cp.start_date AND cp.end_date
                    -- );
                                    SELECT  distinct gl.period_year
              INTO    l_new_fiscal_year
                                    FROM  gl_sets_of_books sob,
                                            gl_periods gl
                                    WHERE   sob.set_of_books_id = p_sob_id
                                    AND     gl.period_set_name= sob.period_set_name
                                    AND     gl.period_type = sob.accounted_period_type
                                    AND    (l_cc_det_pf_lines_rec.cc_det_pf_date between gl.start_date and gl.end_date);
               END;
              IF l_orig_fiscal_year <> l_new_fiscal_year
              THEN
                                            x_valid_cc      := FND_API.G_FALSE;
                                            x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('IGC', 'IGC_CC_FISCAL_YRS_NE');
                  fnd_message.set_TOKEN('ENCMBRNCDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date),FALSE);
                                            IF(g_error_level >= g_debug_level) THEN
                                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                            END IF;
                  fnd_msg_pub.add;
              END IF; -- Fiscal Year Mismatch valdn ends here.
            END IF; -- Encumbrance Amt is greater than zero ends here.
          END IF; -- Encumbrance turned ON validation ends here.

        END LOOP; -- Payment Forecast Loop end here.

        CLOSE c_det_pf_lines;

      END IF;
                        -- Performance Tuning, Replaced view
                        -- igc_cc_det_pf_v with
                        -- igc_cc_det_pf and replaced the line
                        -- below.
      SELECT SUM(NVL(CC_DET_PF_ENTERED_AMT,0))
      INTO l_total_pf_entered_amt
      FROM igc_cc_det_pf
      WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

      IF ( l_total_pf_entered_amt  +
                             NVL(l_cc_acct_lines_rec.cc_ent_withheld_amt,0)) <> NVL(l_cc_acct_lines_rec.cc_acct_entered_amt,0)
                        -- '+' added for 2043221, Bidisha S , 12 Oct 2001
                        -- This validation now needs to include the withheld amount
                        THEN
                           x_valid_cc      := FND_API.G_FALSE;
                           x_return_status := FND_API.G_RET_STS_ERROR;
           fnd_message.set_name('IGC', 'IGC_CC_AMT_MISMATCH');
           fnd_message.set_token('ACCT_NUM',to_char(l_cc_acct_lines_rec.cc_acct_line_num),TRUE);
                           IF(g_error_level >= g_debug_level) THEN
                              FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                           END IF;
           fnd_msg_pub.add;
      END IF;

       END LOOP;

       CLOSE c_account_lines;

       IF (l_cc_acct_cnt = 0)  THEN
                        x_valid_cc      := FND_API.G_FALSE;
                        x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('IGC', 'IGC_CC_NO_ACCT_LINES');
      fnd_message.set_token('CC_NUM', l_cc_headers_rec.cc_num,TRUE);
                    IF(g_error_level >= g_debug_level) THEN
                       FND_LOG.MESSAGE(g_error_level, g_debug_level, FALSE);
                    END IF;
      fnd_msg_pub.add;
        END IF;
    END IF;

  ELSIF  p_mode = 'A'   OR p_mode = 'B' THEN

  -- When Mode of call to the procedure is either 'A' stands for 'Approval'  or 'B' for 'Encumbrance'
  -- the following validations should be performed.


  -- Common Payment Forecast Date Validations.

    BEGIN
      SELECT *
      INTO l_cc_headers_rec
      FROM igc_cc_headers
      WHERE cc_header_id = p_cc_header_id;
      EXCEPTION
                       WHEN no_data_found THEN
                                 x_valid_cc      := FND_API.G_FALSE;
                                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('IGC', 'IGC_CC_NOT_FOUND');
                 fnd_message.set_token('CC_NUM', to_char(p_cc_header_id),TRUE);
                                 IF(g_error_level >= g_debug_level) THEN
                                    FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                 END IF;
                 l_error_message := fnd_message.get;
                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name, l_error_message);
                 RAISE E_CC_NOT_FOUND;

    END;

    -- Check only for provisional and confirmed states

    IF (l_cc_headers_rec.cc_state = 'PR') OR (l_cc_headers_rec.cc_state = 'CM')  THEN

    l_cc_acct_cnt   := 0;

      OPEN c_account_lines(p_cc_header_id);
      LOOP
        l_total_pf_entered_amt := 0;

        FETCH c_account_lines INTO l_cc_acct_lines_rec;

        EXIT WHEN c_account_lines%NOTFOUND;
        l_cc_acct_cnt   := l_cc_acct_cnt + 1;

        l_cc_det_pf_cnt   := 0;

        BEGIN
                                        -- Performance Tuning, Replaced view
                                        -- igc_cc_det_pf_v with
                                        -- igc_cc_det_pf and replaced the line
                                        -- below.
          SELECT count(*)
          INTO l_cc_det_pf_cnt
          FROM igc_cc_det_pf
          WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_cc_det_pf_cnt := 0;
                                     IF ( g_unexp_level >= g_debug_level ) THEN
                                        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                     END IF;
        END;
        IF (NVL(l_cc_det_pf_cnt ,0) = 0)
                                AND l_cc_acct_lines_rec.cc_ent_withheld_amt <> l_cc_acct_lines_rec.cc_acct_entered_amt
                                -- And clause added for 2043221, Bidisha S , 12 Oct 2001
                                -- Perfom this validation only if the withheld amount is not equal to
                                -- the amount in the account line
                                THEN
                                        x_valid_cc      := FND_API.G_FALSE;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('IGC', 'IGC_CC_NO_PF');
          fnd_message.set_token('ACCT_NUM', to_char(l_cc_acct_lines_rec.cc_acct_line_num),TRUE);
                            IF(g_error_level >= g_debug_level) THEN
                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                            END IF;
          fnd_msg_pub.add;
        ELSIF (NVL(l_cc_det_pf_cnt,0) > 0) THEN

          OPEN c_det_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
          LOOP

            FETCH c_det_pf_lines INTO l_cc_det_pf_lines_rec;

            EXIT WHEN c_det_pf_lines%NOTFOUND;
            l_cc_det_pf_cnt   := l_cc_det_pf_cnt + 1;

            -- PF Date vs Start Date Validation.

            IF (l_cc_det_pf_lines_rec.cc_det_pf_date < p_start_date) THEN
                                        x_valid_cc      := FND_API.G_FALSE;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                              fnd_message.set_name('IGC', 'IGC_CC_DET_PF_START_DATE');
                      fnd_message.set_TOKEN('PFDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_date),FALSE);
                                        IF(g_error_level >= g_debug_level) THEN
                                           FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                        END IF;
                  fnd_msg_pub.add;
            END IF;

            -- PF Date vs End Date Validation.

            IF ( (l_cc_det_pf_lines_rec.cc_det_pf_date > p_end_date) AND
                                 (p_end_date IS NOT NULL)
                                   ) THEN
                                    x_valid_cc      := FND_API.G_FALSE;
                                    x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('IGC', 'IGC_CC_DET_PF_END_DATE');
              fnd_message.set_TOKEN('PFDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_date),FALSE);
                                    IF(g_error_level >= g_debug_level) THEN
                                       FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                    END IF;
              fnd_msg_pub.add;
            END IF;

                        -- bug 5667529
                        -- changes done by kasbalas
              -- the validation for the pf date to be in a open period
              -- is done here instead of in the if loop below.
              -- this is beign done here since the check needs to be
              -- maintained even of the DBc is disabled or the
              -- computed fucntional amount and encumberence amount
              -- match or mismatch
			IF ( NVL(l_cc_det_pf_lines_rec.cc_det_pf_comp_func_amt,0) <>               -- Added for Bug 9366764
			   NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) ) THEN

              BEGIN
                             -- Performance Tuning, replaced
                             -- view gl_period_statuses_v with
                             -- gl_period_statuses
                        SELECT  count(*)
                              INTO  l_COUNT
                              FROM  gl_sets_of_books sob,
                        gl_period_statuses gl,
                      igc_cc_periods cp
                     WHERE  sob.set_of_books_id = p_sob_id
                   AND  gl.set_of_books_id = sob.set_of_books_id
                               AND  gl.application_id  = l_gl_application_id   -- Bug 1830385
                   AND  cp.org_id = p_org_id
                     AND  cp.period_set_name = sob.period_set_name
                   AND  cp.period_name = gl.period_name
                     AND  cp.cc_period_status IN ('O','F')
                     AND  gl.closing_status IN ('O','F')
                     AND  (l_cc_det_pf_lines_rec.cc_det_pf_date
                     BETWEEN gl.start_date AND gl.end_date
                     );
                        EXCEPTION
                           WHEN OTHERS THEN
                   l_COUNT := 0;
                               IF ( g_unexp_level >= g_debug_level ) THEN
                                   FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                                   FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                                   FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                                   FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                                END IF;
              END;
              IF NVL(l_COUNT,0) = 0  THEN
                            x_valid_cc      := FND_API.G_FALSE;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('IGC', 'IGC_CC_DET_PF_DATE');
                            IF(g_error_level >= g_debug_level) THEN
                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                            END IF;
                        fnd_msg_pub.add;
              END IF;
			  END IF; -- End of the If condition added for bug 9366764
            -- Encumbrance turned ON.
            -- Bug 1623034. Commitment Type should not be a RELEASE.

            IF p_encumbrance_flag = FND_API.G_TRUE  AND
                   (  (l_sbc_enable_flag = 'Y' )  AND
                        ( l_cbc_enable_flag IN ('Y','N') AND
                              (l_cc_prov_encmbrnc_flag IN ('Y','N') AND
                       (l_cc_conf_encmbrnc_flag = 'Y')
                      )
                        )
                     ) AND
                  l_cc_headers_rec.cc_type <> 'R'
            THEN

              -- Encumbrance turned ON.
              -- Standard budgetary control is on
              -- Commitment budgetary control is on or off.
              -- Provisional contract can encumber or not.
              -- Confirmed contract must encumber.

              IF ( NVL(l_cc_det_pf_lines_rec.cc_det_pf_comp_func_amt,0) <>
                 NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) )
              THEN
                  -- Bug 5667529
                  -- changes done by kasbalas
                  -- removed teh pf validation code to be outside
                  -- this if loop since the check needs to be
                      -- maintained even of the DBc is disabled or the
                    -- computed fucntional amount and encumberence
                -- amount match or mismatch
                NULL;

              -- PF Functional and Encumbered Amt Different ends here.

              ELSIF (NVL(l_cc_det_pf_lines_rec.cc_det_pf_comp_func_amt,0) =
                     NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) )
              THEN
              -- PF Functional and Encumbered Amt  are same starts here.
                IF ( ( ( l_cc_prov_encmbrnc_flag  = 'Y'  AND
                                 (l_cc_conf_encmbrnc_flag = 'Y')
                  ) OR
                       ( (l_cc_prov_encmbrnc_flag = 'N') AND
                         (l_cc_conf_encmbrnc_flag = 'Y') AND
                         (l_cc_headers_rec.cc_state = 'CM')
                  )
                      ) AND
                     (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_status <> 'T')
                   )
                THEN
                     IF TRUNC(l_cc_det_pf_lines_rec.cc_det_pf_date ) <>
                  TRUNC (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date)
                     THEN
                                                                           x_valid_cc      := FND_API.G_FALSE;
                                                                           x_return_status := FND_API.G_RET_STS_ERROR;
                     fnd_message.set_name('IGC',
                      'IGC_CC_DET_PF_DATE_NO_UPDATE');
                     fnd_message.set_TOKEN('ENCMBRNCDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date),FALSE);
                                               IF(g_error_level >= g_debug_level) THEN
                                                  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                               END IF;
                               fnd_msg_pub.add;
                     END IF;
                END IF;
              END IF ; -- PF Functional and Encumbered Amt  are same.

              -- Encumbrance Amount is greater than zero.
              IF NVL(l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_amt,0) >  0
              THEN
                 -- Original Fiscal Year
                 BEGIN
                                                                -- Performance Tuning, Replaced
                                                                -- the following query with the
                                                                -- one below as we are only
                                                                -- interested in the fiscal years.
                -- SELECT   DISTINCT cp.period_year
                -- INTO   l_orig_fiscal_year
                -- FROM   gl_sets_of_books sob,
                --  gl_period_statuses_v gl,
                --  igc_cc_periods_v cp
                -- WHERE  sob.set_of_books_id = p_sob_id
                -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                                -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
                -- AND     cp.org_id = p_org_id
                -- AND     cp.period_set_name= sob.period_set_name
                -- AND     cp.period_name = gl.period_name
                -- AND  (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date
                --    BETWEEN cp.start_date AND cp.end_date
                      -- );
                                         SELECT   distinct gl.period_year
                       INTO   l_orig_fiscal_year
                                         FROM   gl_sets_of_books sob,
                                                gl_periods gl
                                         WHERE  sob.set_of_books_id = p_sob_id
                                         AND     gl.period_set_name= sob.period_set_name
                                         AND     gl.period_type = sob.accounted_period_type
                                         AND    (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date between gl.start_date and gl.end_date);
                   END;
                 -- New Fiscal Year if any.
                 BEGIN
                                                                -- Performance Tuning, Replaced
                                                                -- the following query with the
                                                                -- one below as we are only
                                                                -- interested in the fiscal years.
                -- SELECT   DISTINCT cp.period_year
                -- INTO   l_new_fiscal_year
                -- FROM   gl_sets_of_books sob,
                --  gl_period_statuses_v gl,
                --  igc_cc_periods_v cp
                -- WHERE  sob.set_of_books_id = p_sob_id
                -- AND     gl.set_of_books_id = sob.set_of_books_id
                                                                -- AND     gl.application_id  = l_gl_application_id   -- Bug 1830385
                -- AND     cp.org_id = p_org_id
                -- AND     cp.period_set_name= sob.period_set_name
                -- AND     cp.period_name = gl.period_name
                -- AND  (l_cc_det_pf_lines_rec.cc_det_pf_date
                --    BETWEEN cp.start_date AND cp.end_date
                      --  );
                                          SELECT  distinct gl.period_year
                        INTO    l_new_fiscal_year
                                          FROM      gl_sets_of_books sob,
                                                    gl_periods gl
                                          WHERE   sob.set_of_books_id = p_sob_id
                                          AND     gl.period_set_name= sob.period_set_name
                                          AND     gl.period_type = sob.accounted_period_type
                                          AND    (l_cc_det_pf_lines_rec.cc_det_pf_date between gl.start_date and gl.end_date);
                  END;
                IF l_orig_fiscal_year <> l_new_fiscal_year
                THEN
                                            x_valid_cc      := FND_API.G_FALSE;
                                            x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('IGC', 'IGC_CC_FISCAL_YRS_NE');
                  fnd_message.set_TOKEN('ENCMBRNCDATE',FND_DATE.DATE_TO_CHARDATE (l_cc_det_pf_lines_rec.cc_det_pf_encmbrnc_date),FALSE);
                                            IF(g_error_level >= g_debug_level) THEN
                                               FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                                            END IF;
                  fnd_msg_pub.add;
                END IF; -- Fiscal Year Mismatch valdn ends here.
              END IF; -- Encumbrance Amt is greater than zero ends here.
            END IF; -- Encumbrance turned ON validation ends here.

          END LOOP; -- Payment Forecast Loop end here.

          CLOSE c_det_pf_lines;

        END IF;
                                -- Performance Tuning, Replaced view
                                -- igc_cc_det_pf_v with igc_cc_det_pf
        SELECT SUM(NVL(CC_DET_PF_ENTERED_AMT,0))
        INTO l_total_pf_entered_amt
        FROM igc_cc_det_pf
        WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

        IF ( l_total_pf_entered_amt
                                     + NVL(l_cc_acct_lines_rec.cc_ent_withheld_amt,0) )
                                      <> (NVL(l_cc_acct_lines_rec.cc_acct_entered_amt,0))
                                     -- '+' added for 2043221, Bidisha S , 12 Oct 2001
                                     -- This validation now needs to include the withheld amount
        THEN
                            x_valid_cc      := FND_API.G_FALSE;
                            x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('IGC', 'IGC_CC_AMT_MISMATCH');
          fnd_message.set_token('ACCT_NUM',to_char(l_cc_acct_lines_rec.cc_acct_line_num),TRUE);
                            IF(g_error_level >= g_debug_level) THEN
                                FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                            END IF;
          fnd_msg_pub.add;
        END IF;

      END LOOP;

      CLOSE c_account_lines;

      IF (l_cc_acct_cnt = 0)  THEN
                        x_valid_cc      := FND_API.G_FALSE;
                        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('IGC', 'IGC_CC_NO_ACCT_LINES');
        fnd_message.set_token('CC_NUM', l_cc_headers_rec.cc_num,TRUE);
                        IF(g_error_level >= g_debug_level) THEN
                           FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                        END IF;
        fnd_msg_pub.add;
      END IF;

    END IF;

  END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data  => x_msg_data );

  EXCEPTION
           WHEN E_CC_NOT_FOUND OR E_CC_INVALID_SET_UP THEN
          x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
          x_valid_cc        := FND_API.G_FALSE;
          FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                                p_data  => x_msg_data );
           CLOSE c_account_lines;
                IF (g_excep_level >=  g_debug_level ) THEN
                   FND_LOG.STRING (g_excep_level,l_full_path,'E_CC_NOT_FOUND OR E_CC_INVALID_SET_UP Exception Raised');
                END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
                x_valid_cc        := FND_API.G_FALSE;
          FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                          p_data  => x_msg_data );
          CLOSE c_account_lines;
                IF (g_excep_level >=  g_debug_level ) THEN
                   FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
                END IF;

     WHEN OTHERS THEN
          x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
          x_valid_cc        := FND_API.G_FALSE;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );
      CLOSE c_account_lines;

                    IF ( g_unexp_level >= g_debug_level ) THEN
                       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
                       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
                       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
                    END IF;

END Validate_CC;

-- This procedure calculates the non recoverable tax given an amount.
-- Bug 2409502
PROCEDURE calculate_nonrec_tax (
                                p_api_version       IN       NUMBER,
                                p_init_msg_list     IN       VARCHAR2 := FND_API.G_FALSE,
                                p_commit            IN       VARCHAR2 := FND_API.G_FALSE,
                                p_validation_level  IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                                x_return_status     OUT NOCOPY      VARCHAR2,
                                x_msg_count         OUT NOCOPY      NUMBER,
                                x_msg_data          OUT NOCOPY      VARCHAR2,
                                p_tax_id            IN       ap_tax_codes.tax_id%TYPE,
                                p_amount            IN       NUMBER,
                                p_tax_amount        OUT NOCOPY      NUMBER)
IS
   CURSOR c_get_tax IS
   SELECT Nvl(tax_recovery_rate,100),
          Nvl(tax_rate,0)
   FROM   ap_tax_codes a,
          financials_system_parameters b
   WHERE  a.set_of_books_id = b.set_of_books_id
   AND    a.tax_id          = p_tax_id;


   l_api_name                 CONSTANT VARCHAR2(30)   := 'Calculate_Nonrec_Tax';
   l_api_version              CONSTANT NUMBER         := 1.0;
   l_tax_recovery_rate        ap_tax_codes.tax_recovery_rate%TYPE;
   l_tax_rate                 ap_tax_codes.tax_rate%TYPE;
   l_full_path                VARCHAR2(255);

BEGIN

    l_full_path := g_path || 'calculate_nonrec_tax';

    IF FND_API.to_Boolean(p_init_msg_list)
    THEN
  FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.Compatible_API_Call(l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME)
    THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get the tax rates
    OPEN c_get_tax;
    FETCH c_get_tax INTO l_tax_recovery_rate,
                         l_tax_rate;
    CLOSE c_get_tax;

    IF l_tax_recovery_rate <> 100
    THEN
        p_tax_amount := ((100 - l_tax_recovery_rate)/100) *
                           (l_tax_rate/100) * p_amount;
    END IF;


    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
        p_data  => x_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;

    WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
        p_data  => x_msg_data );

    IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;

END calculate_nonrec_tax;

END IGC_CC_BUDGETARY_CTRL_PKG;

/
