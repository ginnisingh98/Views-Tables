--------------------------------------------------------
--  DDL for Package Body IGC_CC_ACCT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_ACCT_LINES_PKG" as
/* $Header: IGCCACLB.pls 120.6.12000000.4 2007/10/19 06:55:31 smannava ship $  */

   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_ACCT_LINES_PKG';
   g_debug_flag        VARCHAR2(1) := 'N' ;
   g_debug_msg         VARCHAR2(10000) := NULL;

--   g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
   g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Variables for ATG central logging
  g_debug_level       NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level       NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level        NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level       NUMBER	:=	FND_LOG.LEVEL_EVENT;
  g_excep_level       NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level       NUMBER	:=	FND_LOG.LEVEL_ERROR;
  g_unexp_level       NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
  g_path              VARCHAR2(255) := 'IGC.PLSQL.IGCCACLB.IGC_CC_ACCT_LINES_PKG.';

/* ================================================================================
                         PROCEDURE Output_Debug
   ===============================================================================*/

PROCEDURE Output_Debug (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2
) IS

-- --------------------------------------------------------------------
-- Local Variables :
-- --------------------------------------------------------------------
   /*l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(8)           := 'CC_ACLB';
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
   p_CC_Acct_Line_Id        IN OUT NOCOPY   IGC_CC_ACCT_LINES.CC_Acct_Line_Id%TYPE,
   p_CC_Header_Id                    IGC_CC_ACCT_LINES.CC_Header_Id%TYPE,
   p_Parent_Header_Id                IGC_CC_ACCT_LINES.Parent_Header_Id%TYPE,
   p_Parent_Acct_Line_Id             IGC_CC_ACCT_LINES.Parent_Acct_Line_Id%TYPE,
   p_CC_Charge_Code_Comb_Id          IGC_CC_ACCT_LINES.CC_Charge_Code_Combination_Id%TYPE,
   p_CC_Acct_Line_Num                IGC_CC_ACCT_LINES.CC_Acct_Line_Num%TYPE,
   p_CC_Budget_Code_Comb_Id          IGC_CC_ACCT_LINES.CC_Budget_Code_Combination_Id%TYPE,
   p_CC_Acct_Entered_Amt             IGC_CC_ACCT_LINES.CC_Acct_Entered_Amt%TYPE,
   p_CC_Acct_Func_Amt                IGC_CC_ACCT_LINES.CC_Acct_Func_Amt%TYPE,
   p_CC_Acct_Desc                    IGC_CC_ACCT_LINES.CC_Acct_Desc%TYPE,
   p_CC_Acct_Billed_Amt              IGC_CC_ACCT_LINES.CC_Acct_Billed_Amt%TYPE,
   p_CC_Acct_Unbilled_Amt            IGC_CC_ACCT_LINES.CC_Acct_Unbilled_Amt%TYPE,
   p_CC_Acct_Taxable_Flag            IGC_CC_ACCT_LINES.CC_Acct_Taxable_Flag%TYPE,
   p_Tax_Id                          IGC_CC_ACCT_LINES.Tax_Id%TYPE,
   p_CC_Acct_Encmbrnc_Amt            IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Amt%TYPE,
   p_CC_Acct_Encmbrnc_Date           IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Date%TYPE,
   p_CC_Acct_Encmbrnc_Status         IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Status%TYPE,
   p_Project_Id                      IGC_CC_ACCT_LINES.Project_Id%TYPE,
   p_Task_Id                         IGC_CC_ACCT_LINES.Task_Id%TYPE,
   p_Expenditure_Type                IGC_CC_ACCT_LINES.Expenditure_Type%TYPE,
   p_Expenditure_Org_Id              IGC_CC_ACCT_LINES.Expenditure_Org_Id%TYPE,
   p_Expenditure_Item_Date           IGC_CC_ACCT_LINES.Expenditure_Item_Date%TYPE,
   p_Last_Update_Date                IGC_CC_ACCT_LINES.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_ACCT_LINES.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_ACCT_LINES.Last_Update_Login%TYPE,
   p_Creation_Date                   IGC_CC_ACCT_LINES.Creation_Date%TYPE,
   p_Created_By                      IGC_CC_ACCT_LINES.Created_By%TYPE,
   p_Attribute1                      IGC_CC_ACCT_LINES.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_ACCT_LINES.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_ACCT_LINES.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_ACCT_LINES.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_ACCT_LINES.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_ACCT_LINES.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_ACCT_LINES.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_ACCT_LINES.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_ACCT_LINES.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_ACCT_LINES.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_ACCT_LINES.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_ACCT_LINES.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_ACCT_LINES.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_ACCT_LINES.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_ACCT_LINES.Attribute15%TYPE,
   p_Context                         IGC_CC_ACCT_LINES.Context%TYPE,
   p_cc_func_withheld_amt            IGC_CC_ACCT_LINES.cc_func_withheld_amt%TYPE,
   p_cc_ent_withheld_amt             IGC_CC_ACCT_LINES.cc_ent_withheld_amt%TYPE,
   G_FLAG                   IN OUT NOCOPY   VARCHAR2,
   P_Tax_Classif_Code                IGC_CC_ACCT_LINES.Tax_Classif_Code%TYPE
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;

   l_version_num         IGC_CC_HEADERS.CC_Version_Num%TYPE ;

   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_flag                VARCHAR2(1) := 'I';
   l_return_status       VARCHAR2(1);
   l_row_id              VARCHAR2(18);
   l_debug               VARCHAR2(1);

   CURSOR c_acct_row_id IS
      SELECT Rowid
        FROM IGC_CC_ACCT_LINES
       WHERE CC_Acct_Line_Id = p_CC_Acct_Line_Id;

   CURSOR c_cc_version_num IS
     SELECT CC_Version_Num
       FROM IGC_CC_HEADERS
      WHERE CC_Header_Id = p_CC_Header_Id;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

   CURSOR c_cc_info IS
     SELECT SET_OF_BOOKS_ID,
            ORG_ID,
            CONVERSION_DATE
       FROM IGC_CC_HEADERS,
            IGC_CC_ACCT_LINES
      WHERE IGC_CC_HEADERS.CC_HEADER_ID       = IGC_CC_ACCT_LINES.CC_HEADER_ID
        AND IGC_CC_ACCT_LINES.CC_ACCT_LINE_ID = p_CC_Acct_Line_Id;

  l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Insert_Row';

   SAVEPOINT Insert_Row_Pvt ;

-- -----------------------------------------------------------------
-- Ensure that the version requested to be used is correct for
-- this API.
-- -----------------------------------------------------------------
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;


   X_return_status := FND_API.G_RET_STS_SUCCESS ;
--   l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Begin Insert account line ID ....' || ' for Header ID .... ' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Insert the account line record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_ACCT_LINES
             (CC_Acct_Line_Id,
              CC_Header_Id,
              Parent_Header_Id,
              Parent_Acct_Line_Id,
              CC_Charge_Code_Combination_Id,
              CC_Acct_Line_Num,
              CC_Budget_Code_Combination_Id,
              CC_Acct_Entered_Amt,
              CC_Acct_Func_Amt,
              CC_Acct_Desc,
              CC_Acct_Billed_Amt,
              CC_Acct_Unbilled_Amt,
              CC_Acct_Taxable_Flag,
              Tax_Id,
              CC_Acct_Encmbrnc_Amt,
              CC_Acct_Encmbrnc_Date,
              CC_Acct_Encmbrnc_Status,
              Project_Id,
              Task_Id,
              Expenditure_Type,
              Expenditure_Org_Id,
              Expenditure_Item_Date,
              Last_Update_Date,
              Last_Updated_By,
              Last_Update_Login,
              Creation_Date,
              Created_By,
              Attribute1,
              Attribute2,
              Attribute3,
              Attribute4,
              Attribute5,
              Attribute6,
              Attribute7,
              Attribute8,
              Attribute9,
              Attribute10,
              Attribute11,
              Attribute12,
              Attribute13,
              Attribute14,
              Attribute15,
              Context,
              cc_func_withheld_amt,
              cc_ent_withheld_amt,
              Tax_Classif_Code
             )
       VALUES
           (  NVL(p_CC_Acct_Line_Id, igc_cc_acct_lines_s.NEXTVAL),
              p_CC_Header_Id,
              p_Parent_Header_Id,
              p_Parent_Acct_Line_Id,
              p_CC_Charge_Code_Comb_Id,
              p_CC_Acct_Line_Num,
              p_CC_Budget_Code_Comb_Id,
              p_CC_Acct_Entered_Amt,
              p_CC_Acct_Func_Amt,
              p_CC_Acct_Desc,
              p_CC_Acct_Billed_Amt,
              p_CC_Acct_Unbilled_Amt,
              p_CC_Acct_Taxable_Flag,
              p_Tax_Id,
              p_CC_Acct_Encmbrnc_Amt,
              p_CC_Acct_Encmbrnc_Date,
              p_CC_Acct_Encmbrnc_Status,
              p_Project_Id,
              p_Task_Id,
              p_Expenditure_Type,
              p_Expenditure_Org_Id,
              p_Expenditure_Item_Date,
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_Last_Update_Login,
              p_Creation_Date,
              p_Created_By,
              p_Attribute1,
              p_Attribute2,
              p_Attribute3,
              p_Attribute4,
              p_Attribute5,
              p_Attribute6,
              p_Attribute7,
              p_Attribute8,
              p_Attribute9,
              p_Attribute10,
              p_Attribute11,
              p_Attribute12,
              p_Attribute13,
              p_Attribute14,
              p_Attribute15,
              p_Context,
              p_cc_func_withheld_amt,
              p_cc_ent_withheld_amt,
              P_Tax_Classif_Code
             )
           RETURNING CC_Acct_Line_Id INTO p_CC_Acct_Line_Id;

-- -----------------------------------------------------------------
-- Get the next history version number for the account line history
-- -----------------------------------------------------------------
   OPEN c_cc_version_num;
   FETCH c_cc_version_num
    INTO l_Version_Num;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Fetching account line version num';
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- If there is a version number present then insert the next
-- history record for the account line being inserted.
-- -----------------------------------------------------------------
   IF (l_Version_Num > 0) THEN

      IGC_CC_ACCT_LINE_HISTORY_PKG.Insert_Row(
                       l_api_version ,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       p_validation_level,
                       l_return_status,
                       X_msg_count,
                       X_msg_data,
                       p_Rowid,
                       p_CC_Acct_Line_Id,
                       p_CC_Header_Id,
                       p_Parent_Header_Id,
                       p_Parent_Acct_Line_Id ,
                       p_CC_Acct_Line_Num,
                       l_Version_Num - 1 ,
                       'I',
                       p_CC_Charge_Code_Comb_Id,
                       p_CC_Budget_Code_Comb_Id,
                       p_CC_Acct_Entered_Amt ,
                       p_CC_Acct_Func_Amt,
                       p_CC_Acct_Desc ,
                       p_CC_Acct_Billed_Amt ,
                       p_CC_Acct_Unbilled_Amt,
                       p_CC_Acct_Taxable_Flag,
                       p_Tax_Id,
                       p_CC_Acct_Encmbrnc_Amt,
                       p_CC_Acct_Encmbrnc_Date,
                       p_CC_Acct_Encmbrnc_Status,
                       p_Project_Id,
                       p_Task_Id,
                       p_Expenditure_Type,
                       p_Expenditure_Org_Id,
                       p_Expenditure_Item_Date,
                       p_Last_Update_Date,
                       p_Last_Updated_By,
                       p_Last_Update_Login ,
                       p_Creation_Date ,
                       p_Created_By ,
                       p_Attribute1,
                       p_Attribute2,
                       p_Attribute3,
                       p_Attribute4,
                       p_Attribute5,
                       p_Attribute6,
                       p_Attribute7,
                       p_Attribute8,
                       p_Attribute9,
                       p_Attribute10,
                       p_Attribute11,
                       p_Attribute12,
                       p_Attribute13,
                       p_Attribute14,
                       p_Attribute15,
                       p_Context,
                       p_cc_func_withheld_amt,
                       p_cc_ent_withheld_amt,
                       G_FLAG,
                       P_Tax_Classif_Code);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          IF (IGC_MSGS_PKG.g_debug_mode) THEN
          IF (g_debug_mode = 'Y') THEN
             g_debug_msg := ' IGCCACLB -- Failure returned from insert History row...';
             Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

--       IF (IGC_MSGS_PKG.g_debug_mode) THEN
       IF (g_debug_mode = 'Y') THEN
          g_debug_msg := ' IGCCACLB -- Successfully inserted History row...';
          Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
       END IF;
       G_FLAG := 'Y';

   ELSE
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Not inserting History row version num <= 0...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
   END IF;

   CLOSE c_cc_version_num;

-- -------------------------------------------------------------------
-- Obtain the ROWID of the record that was just inserted to return
-- to the caller.
-- -------------------------------------------------------------------
   OPEN c_acct_row_id;
   FETCH c_acct_row_id
    INTO p_Rowid;

-- -------------------------------------------------------------------
-- If no ROWID can be obtained then exit the procedure with a failure
-- -------------------------------------------------------------------
   IF (c_acct_row_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining acct line inserted rowid...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_acct_row_id;

-- ------------------------------------------------------------------
-- Obtain the application ID for IGC to be used for the MRC check
-- being enabled for this set of books.
-- ------------------------------------------------------------------
   OPEN c_igc_app_id;
   FETCH c_igc_app_id
    INTO l_Application_Id;

-- ------------------------------------------------------------------
-- If the application ID can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_igc_app_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining application ID...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- Obtain the set of books, org id, and the conversion date for the
-- CC Header record that the account line is associated to.
-- ------------------------------------------------------------------
   OPEN c_cc_info;
   FETCH c_cc_info
    INTO l_Set_Of_Books_Id,
         l_Org_Id,
         l_Conversion_Date;

-- ------------------------------------------------------------------
-- Exit procedure if the values can not be obtained.
-- ------------------------------------------------------------------
   IF (c_cc_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining CC Info conversion date...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_cc_info;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (l_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/
                           l_Org_Id,
                           Null,
                           l_MRC_Enabled);

-- ------------------------------------------------------------------
-- If MRC is enabled for this set of books being used then call the
-- handler to insert all reporting set of books into the MRC
-- table for the account line inserted.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- MRC Enabled so now inserting MRC info...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_ACCT_LINES to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------

      IGC_CC_MC_MAIN_PVT.get_rsobs_Acct_Lines (
                                   l_api_version,
                                   FND_API.G_FALSE,
                                   FND_API.G_FALSE,
                                   p_validation_level,
                                   l_return_status,
                                   X_msg_count,
                                   X_msg_data,
                                   p_CC_Acct_Line_Id,
                                   l_Set_Of_Books_Id,
                                    101, /*--l_Application_Id, commented for MRC uptake*/
                                   l_org_Id,
                                   NVL(l_Conversion_Date, sysdate),
                                   p_CC_Acct_Func_Amt,
                                   p_CC_Acct_Encmbrnc_Amt,
                                   p_CC_Func_Withheld_Amt,
                                   l_flag);
-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          IF (IGC_MSGS_PKG.g_debug_mode) THEN
          IF (g_debug_mode = 'Y') THEN
             g_debug_msg := ' IGCCACLB -- Failure returned from MC.get_rsobs_Acct_Lines...';
             Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------

   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Committing Inserted account line...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Done inserting row for Account Line...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt;
    X_return_status := FND_API.G_RET_STS_ERROR;

--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure Execute Error...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);

    END IF;

    IF (c_acct_row_id%ISOPEN) THEN
       CLOSE c_acct_row_id;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_cc_info%ISOPEN) THEN
       CLOSE c_cc_info;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure Unexpected Error...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_row_id%ISOPEN) THEN
       CLOSE c_acct_row_id;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_cc_info%ISOPEN) THEN
       CLOSE c_cc_info;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure Others Error...'|| p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_row_id%ISOPEN) THEN
       CLOSE c_acct_row_id;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_cc_info%ISOPEN) THEN
       CLOSE c_cc_info;
    END IF;

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

END Insert_Row;


/* ================================================================================
                         PROCEDURE Lock_Row
   ===============================================================================*/


PROCEDURE Lock_Row(
   p_api_version                 IN  NUMBER,
   p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status               OUT NOCOPY VARCHAR2,
   X_msg_count                   OUT NOCOPY NUMBER,
   X_msg_data                    OUT NOCOPY VARCHAR2,
   p_Rowid                    IN OUT NOCOPY VARCHAR2,
   p_CC_Acct_Line_Id                 IGC_CC_ACCT_LINES.CC_Acct_Line_Id%TYPE,
   p_CC_Header_Id                    IGC_CC_ACCT_LINES.CC_Header_Id%TYPE,
   p_Parent_Header_Id                IGC_CC_ACCT_LINES.Parent_Header_Id%TYPE,
   p_Parent_Acct_Line_Id             IGC_CC_ACCT_LINES.Parent_Acct_Line_Id%TYPE,
   p_CC_Charge_Code_Comb_Id          IGC_CC_ACCT_LINES.CC_Charge_Code_Combination_Id%TYPE,
   p_CC_Acct_Line_Num                IGC_CC_ACCT_LINES.CC_Acct_Line_Num%TYPE,
   p_CC_Budget_Code_Comb_Id          IGC_CC_ACCT_LINES.CC_Budget_Code_Combination_Id%TYPE,
   p_CC_Acct_Entered_Amt             IGC_CC_ACCT_LINES.CC_Acct_Entered_Amt%TYPE,
   p_CC_Acct_Func_Amt                IGC_CC_ACCT_LINES.CC_Acct_Func_Amt%TYPE,
   p_CC_Acct_Desc                    IGC_CC_ACCT_LINES.CC_Acct_Desc%TYPE,
   p_CC_Acct_Billed_Amt              IGC_CC_ACCT_LINES.CC_Acct_Billed_Amt%TYPE,
   p_CC_Acct_Unbilled_Amt            IGC_CC_ACCT_LINES.CC_Acct_Unbilled_Amt%TYPE,
   p_CC_Acct_Taxable_Flag            IGC_CC_ACCT_LINES.CC_Acct_Taxable_Flag%TYPE,
   p_Tax_Id                          IGC_CC_ACCT_LINES.Tax_Id%TYPE,
   p_CC_Acct_Encmbrnc_Amt            IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Amt%TYPE,
   p_CC_Acct_Encmbrnc_Date           IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Date%TYPE,
   p_CC_Acct_Encmbrnc_Status         IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Status%TYPE,
   p_Project_Id                      IGC_CC_ACCT_LINES.Project_Id%TYPE,
   p_Task_Id                         IGC_CC_ACCT_LINES.Task_Id%TYPE,
   p_Expenditure_Type                IGC_CC_ACCT_LINES.Expenditure_Type%TYPE,
   p_Expenditure_Org_Id              IGC_CC_ACCT_LINES.Expenditure_Org_Id%TYPE,
   p_Expenditure_Item_Date           IGC_CC_ACCT_LINES.Expenditure_Item_Date%TYPE,
   p_Last_Update_Date                IGC_CC_ACCT_LINES.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_ACCT_LINES.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_ACCT_LINES.Last_Update_Login%TYPE,
   p_Creation_Date                   IGC_CC_ACCT_LINES.Creation_Date%TYPE,
   p_Created_By                      IGC_CC_ACCT_LINES.Created_By%TYPE,
   p_Attribute1                      IGC_CC_ACCT_LINES.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_ACCT_LINES.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_ACCT_LINES.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_ACCT_LINES.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_ACCT_LINES.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_ACCT_LINES.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_ACCT_LINES.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_ACCT_LINES.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_ACCT_LINES.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_ACCT_LINES.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_ACCT_LINES.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_ACCT_LINES.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_ACCT_LINES.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_ACCT_LINES.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_ACCT_LINES.Attribute15%TYPE,
   p_Context                         IGC_CC_ACCT_LINES.Context%TYPE,
   p_cc_func_withheld_amt            IGC_CC_ACCT_LINES.cc_func_withheld_amt%TYPE,
   p_cc_ent_withheld_amt             IGC_CC_ACCT_LINES.cc_ent_withheld_amt%TYPE,
   X_row_locked                  OUT NOCOPY VARCHAR2,
   G_FLAG                     IN OUT NOCOPY VARCHAR2,
   P_Tax_Classif_Code                IGC_CC_ACCT_LINES.Tax_Classif_Code%TYPE
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   Counter               NUMBER;
   l_debug               VARCHAR2(1);

   CURSOR C IS
        SELECT *
        FROM   IGC_CC_ACCT_LINES
        WHERE  Rowid = p_Rowid
        FOR UPDATE of CC_Acct_Line_Id NOWAIT;

    Recinfo C%ROWTYPE;

    l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Lock_Row';

   SAVEPOINT Lock_Row_Pvt ;

   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;


   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS ;
   X_row_locked    := FND_API.G_TRUE ;
--   l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Beginning Lock account line ID ...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   OPEN C;
   FETCH C INTO Recinfo;

   IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.Add;
      IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.MESSAGE (g_excep_level ,l_full_path ,FALSE);
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE C;

   IF (
               (Recinfo.CC_Acct_Line_Id =  p_CC_Acct_Line_Id)
           AND (Recinfo.CC_Header_Id =  p_CC_Header_Id)
           AND (Recinfo.CC_Acct_Line_Num =  p_CC_Acct_Line_Num)
           AND (   (Recinfo.Parent_Acct_Line_Id =  p_Parent_Acct_Line_Id)
                OR (    (Recinfo.Parent_Acct_Line_Id IS NULL)
                    AND (p_parent_acct_line_Id IS NULL)))
           AND (   (Recinfo.Parent_Header_Id =  p_Parent_Header_Id)
                OR (    (Recinfo.Parent_Header_Id IS NULL)
                    AND (p_Parent_Header_Id IS NULL)))
           AND (   (Recinfo.CC_Charge_Code_Combination_Id =  p_CC_Charge_Code_Comb_Id)
                OR (    (Recinfo.CC_Charge_Code_Combination_Id IS NULL)
                    AND (p_CC_Charge_Code_Comb_Id IS NULL)))
           AND (   (Recinfo.CC_Budget_Code_Combination_Id =  p_CC_Budget_Code_Comb_Id)
                OR (    (Recinfo.CC_Budget_Code_Combination_Id IS NULL)
                    AND (p_CC_Budget_Code_Comb_Id IS NULL)))
           AND (   (Recinfo.CC_Acct_Entered_Amt =  p_CC_Acct_Entered_Amt)
                OR (    (Recinfo.CC_Acct_Entered_Amt IS NULL)
                    AND (p_CC_Acct_Entered_Amt IS NULL)))
           AND (   (Recinfo.CC_Acct_Func_Amt =  p_CC_Acct_Func_Amt)
                OR (    (Recinfo.CC_Acct_Func_Amt IS NULL)
                    AND (p_CC_Acct_Func_Amt IS NULL)))
           AND (   (Recinfo.CC_Acct_Desc =  p_CC_Acct_Desc )
                OR (    (Recinfo.CC_Acct_Desc  IS NULL)
                    AND (p_CC_Acct_Desc IS NULL)))
          -- AND (   (Recinfo.CC_Acct_Billed_Amt =  p_CC_Acct_Billed_Amt)
           --     OR (    (Recinfo.CC_Acct_Billed_Amt IS NULL)
            --        AND (p_CC_Acct_Billed_Amt IS NULL)))
           AND (   (Recinfo.CC_Acct_UnBilled_Amt =  p_CC_Acct_UnBilled_Amt)
                OR (    (Recinfo.CC_Acct_UnBilled_Amt IS NULL)
                    AND (p_CC_Acct_UnBilled_Amt IS NULL)))
           AND (   (Recinfo.CC_Acct_Taxable_Flag =  p_CC_Acct_Taxable_Flag)
                OR (    (Recinfo.CC_Acct_Taxable_Flag IS NULL)
                    AND (p_CC_Acct_Taxable_Flag IS NULL)))
           AND (   (Recinfo.Tax_Id =  p_Tax_Id )
                OR (    (Recinfo.Tax_Id  IS NULL)
                    AND (p_Tax_Id IS NULL)))
           AND (   (Recinfo.CC_Acct_Encmbrnc_Amt =  p_CC_Acct_Encmbrnc_Amt)
                OR (    (Recinfo.CC_Acct_Encmbrnc_Amt IS NULL)
                    AND (p_CC_Acct_Encmbrnc_Amt IS NULL)))
           AND (   (Recinfo.CC_Acct_Encmbrnc_Date =  p_CC_Acct_Encmbrnc_Date)
                OR (    (Recinfo.CC_Acct_Encmbrnc_Date IS NULL)
                    AND (p_CC_Acct_Encmbrnc_Date IS NULL)))
--           AND (   (Recinfo.CC_Acct_Encmbrnc_Status=  p_CC_Acct_Encmbrnc_Status)
--                OR (    (Recinfo.CC_Acct_Encmbrnc_Status IS NULL)
--                    AND (p_CC_Acct_Encmbrnc_Status IS NULL)))
           AND (   (Recinfo.Project_Id =  p_Project_Id)
                OR (    (Recinfo.Project_Id IS NULL)
                    AND (p_Project_Id IS NULL)))
           AND (   (Recinfo.Task_Id =  p_Task_Id)
                OR (    (Recinfo.Task_Id IS NULL)
                    AND (p_Task_Id IS NULL)))
           AND (   (Recinfo.Expenditure_Type =  p_Expenditure_Type)
                OR (    (Recinfo.Expenditure_Type IS NULL)
                    AND (p_Expenditure_Type IS NULL)))
           AND (   (Recinfo.Expenditure_Org_Id =  p_Expenditure_Org_Id)
                OR (    (Recinfo.Expenditure_Org_Id IS NULL)
                    AND (p_Expenditure_Org_Id IS NULL)))
           AND (   (Recinfo.Expenditure_Item_Date =  p_Expenditure_Item_Date)
                OR (    (Recinfo.Expenditure_Item_Date IS NULL)
                    AND (p_Expenditure_Item_Date IS NULL)))
           AND (   (Recinfo.Attribute1 =  p_Attribute1)
                OR (    (Recinfo.Attribute1 IS NULL)
                    AND (p_Attribute1 IS NULL)))
           AND (   (Recinfo.Attribute2 =  p_Attribute2)
                OR (    (Recinfo.Attribute2 IS NULL)
                    AND (p_Attribute2 IS NULL)))
           AND (   (Recinfo.Attribute3 =  p_Attribute3)
                OR (    (Recinfo.Attribute3 IS NULL)
                    AND (p_Attribute3 IS NULL)))
           AND (   (Recinfo.Attribute4 =  p_Attribute4)
                OR (    (Recinfo.Attribute4 IS NULL)
                    AND (p_Attribute4 IS NULL)))
           AND (   (Recinfo.Attribute5 =  p_Attribute5)
                OR (    (Recinfo.Attribute5 IS NULL)
                    AND (p_Attribute5 IS NULL)))
           AND (   (Recinfo.Attribute6 =  p_Attribute6)
                OR (    (Recinfo.Attribute6 IS NULL)
                    AND (p_Attribute6 IS NULL)))
           AND (   (Recinfo.Attribute7 =  p_Attribute7)
                OR (    (Recinfo.Attribute7 IS NULL)
                    AND (p_Attribute7 IS NULL)))
           AND (   (Recinfo.Attribute8 =  p_Attribute8)
                OR (    (Recinfo.Attribute8 IS NULL)
                    AND (p_Attribute8 IS NULL)))
           AND (   (Recinfo.Attribute9 =  p_Attribute9)
                OR (    (Recinfo.Attribute9 IS NULL)
                    AND (p_Attribute9 IS NULL)))
           AND (   (Recinfo.Attribute10 =  p_Attribute10)
                OR (    (Recinfo.Attribute10 IS NULL)
                    AND (p_Attribute10 IS NULL)))
           AND (   (Recinfo.Attribute11 =  p_Attribute11)
                OR (    (Recinfo.Attribute11 IS NULL)
                    AND (p_Attribute11 IS NULL)))
           AND (   (Recinfo.Attribute12 =  p_Attribute12)
                OR (    (Recinfo.Attribute12 IS NULL)
                    AND (p_Attribute12 IS NULL)))
           AND (   (Recinfo.Attribute13 =  p_Attribute13)
                OR (    (Recinfo.Attribute13 IS NULL)
                    AND (p_Attribute13 IS NULL)))
           AND (   (Recinfo.Attribute14 =  p_Attribute14)
                OR (    (Recinfo.Attribute14 IS NULL)
                    AND (p_Attribute14 IS NULL)))
           AND (   (Recinfo.Attribute15 =  p_Attribute15)
                OR (    (Recinfo.Attribute15 IS NULL)
                    AND (p_Attribute15 IS NULL)))
           AND (   (Recinfo.Context =  p_Context)
                OR (    (Recinfo.Context IS NULL)
                    AND (p_Context IS NULL)))
           AND (   (Recinfo.CC_Func_Withheld_Amt =  p_CC_Func_Withheld_Amt)
                OR (    (Recinfo.CC_Func_Withheld_Amt IS NULL)
                    AND (p_CC_Func_Withheld_Amt IS NULL)))
           AND (   (Recinfo.CC_Ent_Withheld_Amt =  p_CC_Ent_Withheld_Amt)
                OR (    (Recinfo.CC_Ent_Withheld_Amt IS NULL)
                    AND (p_CC_Ent_Withheld_Amt IS NULL)))
           AND (   (Recinfo.Tax_Classif_Code =  P_Tax_Classif_Code)
                OR (    (Recinfo.Tax_Classif_Code IS NULL)
                    AND (P_Tax_Classif_Code IS NULL)))

     ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Locked account line';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      NULL;

   ELSE
--     IF (IGC_MSGS_PKG.g_debug_mode) THEN
     IF (g_debug_mode = 'Y') THEN
        g_debug_msg := ' IGCCACLB -- Failure Locking account line';
        Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
     END IF;
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.MESSAGE (g_excep_level,l_full_path,FALSE);
     END IF;
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Committing Locked account line';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- End of Locking account line ID ...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_row_locked := FND_API.G_FALSE;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Record Lock exception...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'APP_EXCEPTION.RECORD_LOCK_EXCEPTION Exception Raised');
    END IF;

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Execute exception...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Unexpected exception...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Others exception...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
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

END Lock_Row;


/* ================================================================================
                         PROCEDURE Update_Row
   ===============================================================================*/

PROCEDURE Update_Row(
   p_api_version                 IN  NUMBER,
   p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status               OUT NOCOPY VARCHAR2,
   X_msg_count                   OUT NOCOPY NUMBER,
   X_msg_data                    OUT NOCOPY VARCHAR2,
   p_Rowid                       IN OUT NOCOPY VARCHAR2,
   p_CC_Acct_Line_Id             IN OUT NOCOPY IGC_CC_ACCT_LINES.CC_Acct_Line_Id%TYPE,
   p_CC_Header_Id                    IGC_CC_ACCT_LINES.CC_Header_Id%TYPE,
   p_Parent_Header_Id                IGC_CC_ACCT_LINES.Parent_Header_Id%TYPE,
   p_Parent_Acct_Line_Id             IGC_CC_ACCT_LINES.Parent_Acct_Line_Id%TYPE,
   p_CC_Charge_Code_Comb_Id          IGC_CC_ACCT_LINES.CC_Charge_Code_Combination_Id%TYPE,
   p_CC_Acct_Line_Num                IGC_CC_ACCT_LINES.CC_Acct_Line_Num%TYPE,
   p_CC_Budget_Code_Comb_Id          IGC_CC_ACCT_LINES.CC_Budget_Code_Combination_Id%TYPE,
   p_CC_Acct_Entered_Amt             IGC_CC_ACCT_LINES.CC_Acct_Entered_Amt%TYPE,
   p_CC_Acct_Func_Amt                IGC_CC_ACCT_LINES.CC_Acct_Func_Amt%TYPE,
   p_CC_Acct_Desc                    IGC_CC_ACCT_LINES.CC_Acct_Desc%TYPE,
   p_CC_Acct_Billed_Amt              IGC_CC_ACCT_LINES.CC_Acct_Billed_Amt%TYPE,
   p_CC_Acct_Unbilled_Amt            IGC_CC_ACCT_LINES.CC_Acct_Unbilled_Amt%TYPE,
   p_CC_Acct_Taxable_Flag            IGC_CC_ACCT_LINES.CC_Acct_Taxable_Flag%TYPE,
   p_Tax_Id                          IGC_CC_ACCT_LINES.Tax_Id%TYPE,
   p_CC_Acct_Encmbrnc_Amt            IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Amt%TYPE,
   p_CC_Acct_Encmbrnc_Date           IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Date%TYPE,
   p_CC_Acct_Encmbrnc_Status         IGC_CC_ACCT_LINES.CC_Acct_Encmbrnc_Status%TYPE,
   p_Project_Id                      IGC_CC_ACCT_LINES.Project_Id%TYPE,
   p_Task_Id                         IGC_CC_ACCT_LINES.Task_Id%TYPE,
   p_Expenditure_Type                IGC_CC_ACCT_LINES.Expenditure_Type%TYPE,
   p_Expenditure_Org_Id              IGC_CC_ACCT_LINES.Expenditure_Org_Id%TYPE,
   p_Expenditure_Item_Date           IGC_CC_ACCT_LINES.Expenditure_Item_Date%TYPE,
   p_Last_Update_Date                IGC_CC_ACCT_LINES.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_ACCT_LINES.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_ACCT_LINES.Last_Update_Login%TYPE,
   p_Creation_Date                   IGC_CC_ACCT_LINES.Creation_Date%TYPE,
   p_Created_By                      IGC_CC_ACCT_LINES.Created_By%TYPE,
   p_Attribute1                      IGC_CC_ACCT_LINES.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_ACCT_LINES.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_ACCT_LINES.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_ACCT_LINES.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_ACCT_LINES.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_ACCT_LINES.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_ACCT_LINES.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_ACCT_LINES.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_ACCT_LINES.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_ACCT_LINES.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_ACCT_LINES.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_ACCT_LINES.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_ACCT_LINES.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_ACCT_LINES.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_ACCT_LINES.Attribute15%TYPE,
   p_Context                         IGC_CC_ACCT_LINES.Context%TYPE,
   p_cc_func_withheld_amt            IGC_CC_ACCT_LINES.cc_func_withheld_amt%TYPE,
   p_cc_ent_withheld_amt             IGC_CC_ACCT_LINES.cc_ent_withheld_amt%TYPE,
   G_FLAG                     IN OUT NOCOPY VARCHAR2,
   P_Tax_Classif_Code                IGC_CC_ACCT_LINES.Tax_Classif_Code%TYPE
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_flag                VARCHAR2(1) := 'U';
   l_return_status       VARCHAR2(1);
   l_debug               VARCHAR2(1);

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

   CURSOR c_acct_line_info IS
     SELECT ICH.set_of_books_id,
            ICH.org_id
       FROM IGC_CC_HEADERS     ICH,
            IGC_CC_ACCT_LINES  IAL
      WHERE ICH.CC_HEADER_ID    = IAL.CC_HEADER_ID
        AND IAL.CC_ACCT_LINE_ID = p_CC_Acct_Line_Id;

  l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Update_Row';

   SAVEPOINT Update_Row_Pvt ;

-- -----------------------------------------------------------------
-- Ensure that the version requested to be used is correct for
-- this API.
-- -----------------------------------------------------------------
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS ;
--   l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Starting Update Account for Header ID .... ' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------------
-- Update the Account Line Record
-- --------------------------------------------------------------------------
   UPDATE IGC_CC_ACCT_LINES
      SET CC_Acct_Line_Id = NVL(p_CC_Acct_Line_Id, igc_cc_acct_lines_s.NEXTVAL),
          CC_Header_Id                  =  p_CC_Header_Id,
          Parent_Header_Id              =  p_Parent_Header_id,
          Parent_Acct_Line_Id           =  p_Parent_Acct_Line_Id,
          CC_Charge_Code_Combination_Id =  p_CC_Charge_Code_Comb_Id,
          CC_Acct_Line_Num              =  p_CC_Acct_Line_Num,
          CC_Budget_Code_Combination_Id =  p_CC_Budget_Code_Comb_Id,
          CC_Acct_Entered_Amt           =  p_CC_Acct_Entered_Amt,
          CC_Acct_Func_Amt              =  p_CC_Acct_Func_Amt,
          CC_Acct_Desc                  =  p_CC_Acct_Desc,
          CC_Acct_Billed_Amt            =  p_CC_Acct_Billed_Amt,
          CC_Acct_Unbilled_Amt          =  p_CC_Acct_Unbilled_Amt,
          CC_Acct_Taxable_Flag          =  p_CC_Acct_Taxable_Flag,
          Tax_Id                        =  p_Tax_Id,
          CC_Acct_Encmbrnc_Amt          =  p_CC_Acct_Encmbrnc_Amt,
          CC_Acct_Encmbrnc_Date         =  p_CC_Acct_Encmbrnc_Date,
          CC_Acct_Encmbrnc_Status       =  p_CC_Acct_Encmbrnc_Status,
          Project_Id                    =  p_Project_Id,
          Task_Id                       =  p_Task_Id,
          Expenditure_Type              =  p_Expenditure_Type,
          Expenditure_Org_Id            =  p_Expenditure_Org_Id,
          Expenditure_Item_Date         =  p_Expenditure_Item_Date,
          Last_Update_Date              =  p_Last_Update_Date,
          Last_Updated_By               =  p_Last_Updated_By,
          Last_Update_Login             =  p_Last_Update_Login,
          Creation_Date                 =  p_Creation_Date,
          Created_By                    =  p_Created_By,
          Attribute1                    =  p_Attribute1,
          Attribute2                    =  p_Attribute2,
          Attribute3                    =  p_Attribute3,
          Attribute4                    =  p_Attribute4,
          Attribute5                    =  p_Attribute5,
          Attribute6                    =  p_Attribute6,
          Attribute7                    =  p_Attribute7,
          Attribute8                    =  p_Attribute8,
          Attribute9                    =  p_Attribute9,
          Attribute10                   =  p_Attribute10,
          Attribute11                   =  p_Attribute11,
          Attribute12                   =  p_Attribute12,
          Attribute13                   =  p_Attribute13,
          Attribute14                   =  p_Attribute14,
          Attribute15                   =  p_Attribute15,
          Context                       =  p_Context  ,
          cc_func_withheld_amt          =  p_cc_func_withheld_amt,
          cc_ent_withheld_amt           =  p_cc_ent_withheld_amt,
          Tax_Classif_Code              =  P_Tax_Classif_Code
    WHERE rowid = p_Rowid
    RETURNING CC_Acct_Line_Id INTO p_CC_Acct_Line_Id ;

   IF (SQL%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Account Line not found to update.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

-- -------------------------------------------------------------------------
-- Obtain the information required for doing the update for the MRC
-- records and reporting sets of books.
-- -------------------------------------------------------------------------
   OPEN c_igc_app_id;
   FETCH c_igc_app_id
    INTO l_Application_Id;

-- ------------------------------------------------------------------
-- If the application ID can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_igc_app_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining application ID.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- Obtain the set of books, org id, and the conversion date for the
-- CC Header record that the Account line is associated to.
-- ------------------------------------------------------------------
   OPEN c_acct_line_info;
   FETCH c_acct_line_info
    INTO l_Set_Of_Books_Id,
         l_Org_Id;

-- ------------------------------------------------------------------
-- Exit procedure if the values can not be obtained.
-- ------------------------------------------------------------------
   IF (c_acct_line_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining account line info for update.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c_acct_line_info;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (l_Set_Of_Books_Id,
                            101, /*--l_Application_Id, commented for MRC uptake*/
                           l_Org_Id,
                           Null,
                           l_MRC_Enabled
                          );

-- ------------------------------------------------------------------
-- If MRC has been enabled for this set of books then make sure that
-- the records are updated accordingly.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- MRC enabled for update account line.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_ACCT_LINES to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_ACCT_LINES(
                                 l_api_version,
                                 FND_API.G_FALSE,
                                 FND_API.G_FALSE,
                                 p_validation_level,
                                 l_return_status,
                                 X_msg_count,
                                 X_msg_data,
                                 p_CC_Acct_Line_Id,
                                 l_Set_Of_Books_Id,
                                  101, /*--l_Application_Id, commented for MRC uptake*/
                                 l_org_Id,
                                 NVL(l_Conversion_Date, sysdate),
                                 p_CC_Acct_Func_Amt,
                                 p_CC_Acct_Encmbrnc_Amt,
                                 p_CC_Func_Withheld_Amt,
                                 l_flag);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' IGCCACLB -- Failure returned from MRC update account line.....';
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Committing account line update.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- End of Update Account Line ID ...' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure update execute error.....' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_line_info%ISOPEN) THEN
       CLOSE c_acct_line_info;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure update Unexpected error.....' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_line_info%ISOPEN) THEN
       CLOSE c_acct_line_info;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure update Others error.....' || p_CC_Acct_Line_Id  ||
                     ' for Header ID .... ' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_line_info%ISOPEN) THEN
       CLOSE c_acct_line_info;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;

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

  END Update_Row;


/* ================================================================================
                         PROCEDURE Delete_Row
   ===============================================================================*/

PROCEDURE Delete_Row(
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY  VARCHAR2,
   X_msg_count                 OUT NOCOPY  NUMBER,
   X_msg_data                  OUT NOCOPY  VARCHAR2,
   p_Rowid                  IN OUT NOCOPY  VARCHAR2,
   G_FLAG                   IN OUT NOCOPY  VARCHAR2
) IS

   l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
   l_api_version             CONSTANT NUMBER         :=  1.0;

   l_Application_Id          NUMBER;
   l_return_status           VARCHAR2(1) ;
   l_msg_count               NUMBER ;
   l_msg_data                VARCHAR2(2000) ;
   l_version_num             IGC_CC_HEADERS.CC_Version_Num%TYPE;
   l_acct_row_id             Varchar2(18);
   l_pf_row_id               Varchar2(18);
   l_action_flag             VARCHAR2(1) := 'D';
   l_Conversion_Date         DATE;
   l_Set_Of_Books_Id         NUMBER;
   l_Org_Id                  NUMBER(15);
   l_MRC_Enabled             VARCHAR2(1);
   l_global_flag             VARCHAR2(1);
   l_debug                   VARCHAR2(1);

   CURSOR c_acct_row_info IS
      SELECT *
        FROM IGC_CC_ACCT_LINES
       WHERE Rowid = p_Rowid;

   CURSOR c_cc_version_num IS
     SELECT ICH.CC_Version_Num
       FROM IGC_CC_HEADERS    ICH,
            IGC_CC_ACCT_LINES IAL
      WHERE ICH.CC_Header_Id = IAL.CC_Header_Id
        AND IAL.Rowid        = p_Rowid;

   Recinfo c_acct_row_info%ROWTYPE;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

   CURSOR c_cc_info IS
     SELECT ICH.SET_OF_BOOKS_ID,
            ICH.ORG_ID,
            ICH.CONVERSION_DATE
       FROM IGC_CC_HEADERS     ICH,
            IGC_CC_ACCT_LINES  CAL
      WHERE ICH.CC_HEADER_ID    = CAL.CC_HEADER_ID
        AND CAL.CC_ACCT_LINE_ID = Recinfo.cc_acct_line_id;

   CURSOR c_get_all_pf_lines IS
     SELECT rowid
       FROM igc_cc_det_pf CDP
      WHERE CDP.cc_acct_line_id = Recinfo.cc_acct_line_id;

  l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'Delete_Row';

   SAVEPOINT Delete_Row_Pvt ;

-- -----------------------------------------------------------------
-- Ensure that the version requested to be used is correct for
-- this API.
-- -----------------------------------------------------------------
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF ;

   X_return_status := FND_API.G_RET_STS_SUCCESS ;
--   l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Starting account line delete Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Get The record that is about to be deleted
-- -----------------------------------------------------------------
   OPEN c_acct_row_info;
   FETCH c_acct_row_info
    INTO Recinfo;

-- ------------------------------------------------------------------
-- If the row information can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_acct_row_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure delete obtain acct info.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c_acct_row_info;

-- -----------------------------------------------------------------
-- Get the next history version number for the account line history
-- -----------------------------------------------------------------
   OPEN c_cc_version_num;
   FETCH c_cc_version_num
    INTO l_version_num;

-- ------------------------------------------------------------------
-- If the version number can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_cc_version_num%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure delete getting version num.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c_cc_version_num;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Inserting history record for Delete action account line.....';
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- ----------------------------------------------------------------
-- Insert the deleted history record for the account line
-- ----------------------------------------------------------------
   IGC_CC_ACCT_LINE_HISTORY_PKG.Insert_Row(
                       l_api_version ,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       p_validation_level,
                       l_return_status,
                       X_msg_count,
                       X_msg_data,
                       l_acct_row_id,
                       Recinfo.CC_Acct_Line_Id,
                       Recinfo.CC_Header_Id,
                       Recinfo.Parent_Header_Id,
                       Recinfo.Parent_Acct_Line_Id ,
                       Recinfo.CC_Acct_Line_Num,
                       l_Version_Num - 1 ,
                       l_action_flag,
                       Recinfo.CC_Charge_Code_Combination_Id,
                       Recinfo.CC_Budget_Code_Combination_Id,
                       Recinfo.CC_Acct_Entered_Amt ,
                       Recinfo.CC_Acct_Func_Amt,
                       Recinfo.CC_Acct_Desc ,
                       Recinfo.CC_Acct_Billed_Amt ,
                       Recinfo.CC_Acct_Unbilled_Amt,
                       Recinfo.CC_Acct_Taxable_Flag,
                       Recinfo.Tax_Id,
                       Recinfo.CC_Acct_Encmbrnc_Amt,
                       Recinfo.CC_Acct_Encmbrnc_Date,
                       Recinfo.CC_Acct_Encmbrnc_Status,
                       Recinfo.Project_Id,
                       Recinfo.Task_Id,
                       Recinfo.Expenditure_Type,
                       Recinfo.Expenditure_Org_Id,
                       Recinfo.Expenditure_Item_Date,
                       Recinfo.Last_Update_Date,
                       Recinfo.Last_Updated_By,
                       Recinfo.Last_Update_Login ,
                       Recinfo.Creation_Date ,
                       Recinfo.Created_By ,
                       Recinfo.Attribute1,
                       Recinfo.Attribute2,
                       Recinfo.Attribute3,
                       Recinfo.Attribute4,
                       Recinfo.Attribute5,
                       Recinfo.Attribute6,
                       Recinfo.Attribute7,
                       Recinfo.Attribute8,
                       Recinfo.Attribute9,
                       Recinfo.Attribute10,
                       Recinfo.Attribute11,
                       Recinfo.Attribute12,
                       Recinfo.Attribute13,
                       Recinfo.Attribute14,
                       Recinfo.Attribute15,
                       Recinfo.Context,
                       Recinfo.cc_func_withheld_amt,
                       Recinfo.cc_ent_withheld_amt,
                       G_FLAG,
                       Recinfo.Tax_Classif_code);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure returned from history delete action.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- ------------------------------------------------------------------
-- Obtain the application ID for IGC to be used for the MRC check
-- being enabled for this set of books.
-- ------------------------------------------------------------------
   OPEN c_igc_app_id;
   FETCH c_igc_app_id
    INTO l_Application_Id;

-- ------------------------------------------------------------------
-- If the application ID can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_igc_app_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining application ID in delete operation...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- Obtain the set of books, org id, and the conversion date for the
-- CC Header record that the account line is associated to.
-- ------------------------------------------------------------------
   OPEN c_cc_info;
   FETCH c_cc_info
    INTO l_Set_Of_Books_Id,
         l_Org_Id,
         l_Conversion_Date;


-- ------------------------------------------------------------------
-- Exit procedure if the values can not be obtained.
-- ------------------------------------------------------------------
   IF (c_cc_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure obtaining CC Info conversion date in delete...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_cc_info;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (l_Set_Of_Books_Id,
                            101, /*--l_Application_Id, commented for MRC uptake*/
                           l_Org_Id,
                           Null,
                           l_MRC_Enabled);

-- ------------------------------------------------------------------
-- If MRC is enabled for this set of books being used then call the
-- handler to insert all reporting set of books into the MRC
-- table for the account line inserted.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- MRC Enabled so now deleting MRC info...';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_ACCT_LINES to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_Acct_Lines (
                                   l_api_version,
                                   FND_API.G_FALSE,
                                   FND_API.G_FALSE,
                                   p_validation_level,
                                   l_return_status,
                                   X_msg_count,
                                   X_msg_data,
                                   Recinfo.cc_acct_line_id,
                                   l_Set_Of_Books_Id,
                                   101, /*--l_Application_Id, commented for MRC uptake*/
                                   l_org_Id,
                                   NVL(l_Conversion_Date, sysdate),
                                   0,
                                   0,
                                   0,
                                   l_action_flag);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          IF (IGC_MSGS_PKG.g_debug_mode) THEN
          IF (g_debug_mode = 'Y') THEN
             g_debug_msg := ' IGCCACLB -- Failure returned from MC.get_rsobs_Acct_Lines delete...';
             Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF;

-- ----------------------------------------------------------------
-- Get all the associated Detail Payment Forcast Lines to the
-- Account line to be deleted.  Then delete the associated PF
-- Lines.
-- ----------------------------------------------------------------
   OPEN c_get_all_pf_lines;
   FETCH c_get_all_pf_lines
    INTO l_pf_row_id;

   IF (c_get_all_pf_lines%FOUND) THEN

      WHILE (c_get_all_pf_lines%FOUND) LOOP

         IGC_CC_DET_PF_PKG.Delete_Row (l_api_version,
                                       FND_API.G_FALSE,
                                       FND_API.G_FALSE,
                                       p_validation_level,
                                       l_return_status,
                                       X_msg_count,
                                       X_msg_data,
                                       l_pf_row_id,
                                       l_global_flag);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--            IF (IGC_MSGS_PKG.g_debug_mode) THEN
            IF (g_debug_mode = 'Y') THEN
               g_debug_msg := ' IGCCACLB -- Failure returned from Delete Row DET PF...';
               Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

-- ------------------------------------------------------------------
-- Get the next row of Payment forcast record
-- ------------------------------------------------------------------
         FETCH c_get_all_pf_lines
          INTO l_pf_row_id;

      END LOOP;

   END IF;

   CLOSE c_get_all_pf_lines;

-- ----------------------------------------------------------------
-- Delete the requested record from the acct line table
-- ----------------------------------------------------------------
   DELETE
     FROM IGC_CC_ACCT_LINES
    WHERE rowid = p_Rowid;

-- ------------------------------------------------------------------
-- If the row can not be deleted then exit the procedure
-- ------------------------------------------------------------------
   IF (SQL%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Failure delete not found.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- Deleted account line.....';
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   G_FLAG := 'Y';

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCACLB -- Committing account line delete.....';
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCACLB -- End of Delete Rowid ...' || p_rowid;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- ------------------------------------------------------------
-- Make sure (double check that all cursors are closed.
-- ------------------------------------------------------------
   IF (c_acct_row_info%ISOPEN) THEN
      CLOSE c_acct_row_info;
   END IF;
   IF (c_cc_version_num%ISOPEN) THEN
      CLOSE c_cc_version_num;
   END IF;
   IF (c_igc_app_id%ISOPEN) THEN
      CLOSE c_igc_app_id;
   END IF;
   IF (c_cc_info%ISOPEN) THEN
      CLOSE c_cc_info;
   END IF;
   IF (c_get_all_pf_lines%ISOPEN) THEN
      CLOSE c_get_all_pf_lines;
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure Delete Execute Error Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_row_info%ISOPEN) THEN
       CLOSE c_acct_row_info;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_cc_info%ISOPEN) THEN
       CLOSE c_cc_info;
    END IF;
    IF (c_get_all_pf_lines%ISOPEN) THEN
       CLOSE c_get_all_pf_lines;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure Delete Unexpected Error Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_row_info%ISOPEN) THEN
       CLOSE c_acct_row_info;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_cc_info%ISOPEN) THEN
       CLOSE c_cc_info;
    END IF;
    IF (c_get_all_pf_lines%ISOPEN) THEN
       CLOSE c_get_all_pf_lines;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCACLB -- Failure Delete Others Error Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_acct_row_info%ISOPEN) THEN
       CLOSE c_acct_row_info;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_cc_info%ISOPEN) THEN
       CLOSE c_cc_info;
    END IF;
    IF (c_get_all_pf_lines%ISOPEN) THEN
       CLOSE c_get_all_pf_lines;
    END IF;

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

END Delete_Row;

END IGC_CC_ACCT_LINES_PKG;

/
