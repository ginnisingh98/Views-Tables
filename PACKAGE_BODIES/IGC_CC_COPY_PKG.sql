--------------------------------------------------------
--  DDL for Package Body IGC_CC_COPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_COPY_PKG" AS
/* $Header: IGCCCPCB.pls 120.5.12000000.3 2007/10/18 15:20:43 vumaasha ship $*/

-- ------------------------------------------------------------------------------
-- Define globals to be used within this procedure itself.
-- ------------------------------------------------------------------------------
   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_COPY_PKG';
   g_update_login         igc_cbc_je_lines.last_update_login%TYPE;
   g_update_by            igc_cbc_je_lines.last_updated_by%TYPE;
   g_prod                 VARCHAR2(3)           := 'IGC';
   g_sub_comp             VARCHAR2(7)           := 'CC_COPY';
   g_profile_name         VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   g_debug                VARCHAR2(10000);
   g_new_cc_header_id     NUMBER;

--   g_debug_mode           VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
     g_debug_mode           VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
 --following variables added for bug 3199488: fnd logging changes: sdixit
     g_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     g_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
     g_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
     g_event_level number	:=	FND_LOG.LEVEL_EVENT;
     g_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
     g_error_level number	:=	FND_LOG.LEVEL_ERROR;
     g_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
     g_path varchar2(500) :=      'igc.plsql.igcccpcb.igc_cc_copy_pkg.';


-- ------------------------------------------------------------------------------
-- Declare the procedures that are within this package.
-- ------------------------------------------------------------------------------
PROCEDURE Acct_Line_Copy (
   p_cc_acct_line      IN igc_cc_acct_lines%ROWTYPE,
   p_conversion_rate   IN igc_cc_headers.conversion_rate%TYPE,
   x_cc_acct_line_id  OUT NOCOPY igc_cc_acct_lines.cc_acct_line_id%TYPE,
   x_return_status    OUT NOCOPY VARCHAR2
);

PROCEDURE Det_Pf_Line_Copy (
   p_cc_pmt_fcst       IN igc_cc_det_pf%ROWTYPE,
   p_cc_acct_line_id   IN igc_cc_acct_lines.cc_acct_line_id%TYPE,
   p_conversion_rate   IN igc_cc_headers.conversion_rate%TYPE,
   x_return_status    OUT NOCOPY VARCHAR2
);

PROCEDURE Access_Copy (
   p_access_lines      IN igc_cc_access%ROWTYPE,
   x_return_status    OUT NOCOPY VARCHAR2
);

PROCEDURE Put_Debug_Msg (
	p_path       IN VARCHAR2,
        p_debug_msg  IN VARCHAR2,
        p_sev_level  IN VARCHAR2 := g_state_level
);


/* ================================================================================
                         PROCEDURE Acct_Line_Copy
   ===============================================================================*/

PROCEDURE Acct_Line_Copy (
   p_cc_acct_line     IN igc_cc_acct_lines%ROWTYPE,
   p_conversion_rate  IN igc_cc_headers.conversion_rate%TYPE,
   x_cc_acct_line_id OUT NOCOPY igc_cc_acct_lines.cc_acct_line_id%TYPE,
   x_return_status   OUT NOCOPY VARCHAR2
) IS

   l_cc_acct_line_id    igc_cc_acct_lines.cc_acct_line_id%TYPE;

   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_Rowid              VARCHAR2(18);
   l_flag               VARCHAR2(1);
   l_functional_amount  igc_cc_acct_lines.cc_acct_func_amt%TYPE;
-- bug 2043221 ssmales - added variable declaration on l_func_withheld_amt
   l_func_withheld_amt  igc_cc_acct_lines.cc_func_withheld_amt%TYPE;
   l_seq_num            NUMBER;

   l_full_path          VARCHAR2(500) :=  g_path||'Acct_Line_Copy';--bug 3199488

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - Starting to Insert Account Line.');
   END IF;



-- ---------------------------------------------------------------------
-- Make sure that the functional amount is correctly calculated.
-- ---------------------------------------------------------------------
      IF (p_conversion_rate IS NULL) THEN
         l_functional_amount := p_cc_acct_line.CC_Acct_Entered_Amt;
-- bug 2043221 ssmales -  added line below
         l_func_withheld_amt := p_cc_acct_line.CC_Ent_Withheld_Amt;
      ELSE
         l_functional_amount := p_cc_acct_line.CC_Acct_Entered_Amt * p_conversion_rate;
-- bug 2043221 ssmales -  added line below
         l_func_withheld_amt := p_cc_acct_line.CC_Ent_Withheld_Amt * p_conversion_rate;
      END IF;

      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Both Acct Line Entered Amounts are : ' ||  p_cc_acct_line.CC_Acct_Entered_Amt);
         Put_Debug_Msg (l_full_path,' IGCCCPCB - OLD Acct Line Functional Amount is : ' ||  p_cc_acct_line.CC_Acct_Func_Amt);
         Put_Debug_Msg (l_full_path,' IGCCCPCB - New Copied Acct Line Functional Amount is : ' || l_functional_amount);


-- bug 2043221 ssmales - start block
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Acct Line Withheld Entered Amount is : ' ||  p_cc_acct_line.CC_Ent_Withheld_Amt);
         Put_Debug_Msg (l_full_path,' IGCCCPCB - OLD Acct Line Func Withheld Amount is : ' ||  p_cc_acct_line.CC_Func_Withheld_Amt);
         Put_Debug_Msg (l_full_path,' IGCCCPCB - New Copied Acct Line Functional Amount is : ' || l_func_withheld_amt);
-- bug 2043221 ssmales - end block
      END IF;

      IGC_CC_ACCT_LINES_PKG.Insert_Row
           (p_api_version             => 1.0,
            p_init_msg_list           => FND_API.G_FALSE,
            p_commit                  => FND_API.G_FALSE,
            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
            X_return_status           => l_return_status,
            X_msg_count               => l_msg_count,
            X_msg_data                => l_msg_data,
            p_Rowid                   => l_rowid,
            p_CC_Acct_Line_Id         => l_cc_acct_line_id,
            p_CC_Header_Id            => g_new_cc_header_id,
            p_Parent_Header_Id        => NULL,
            p_Parent_Acct_Line_Id     => NULL,
            p_CC_Charge_Code_Comb_Id  => p_cc_acct_line.CC_Charge_Code_Combination_Id,
            p_CC_Acct_Line_Num        => p_cc_acct_line.CC_Acct_Line_Num,
            p_CC_Budget_Code_Comb_Id  => p_cc_acct_line.CC_Budget_Code_Combination_Id,
            p_CC_Acct_Entered_Amt     => p_cc_acct_line.CC_Acct_Entered_Amt,
            p_CC_Acct_Func_Amt        => l_functional_amount,
            p_CC_Acct_Desc            => p_cc_acct_line.CC_Acct_Desc,
            p_CC_Acct_Billed_Amt      => NULL,
            p_CC_Acct_Unbilled_Amt    => NULL,
            p_CC_Acct_Taxable_Flag    => p_cc_acct_line.CC_Acct_Taxable_Flag,
            p_Tax_Id                  => p_cc_acct_line.Tax_Id,
            p_CC_Acct_Encmbrnc_Amt    => NULL,
            p_CC_Acct_Encmbrnc_Date   => NULL,
            p_CC_Acct_Encmbrnc_Status => NULL,
            p_Project_Id              => p_cc_acct_line.Project_Id,
            p_Task_Id                 => p_cc_acct_line.Task_Id,
            p_Expenditure_Type        => p_cc_acct_line.Expenditure_Type,
            p_Expenditure_Org_Id      => p_cc_acct_line.Expenditure_Org_Id,
            p_Expenditure_Item_Date   => p_cc_acct_line.Expenditure_Item_Date,
            p_Last_Update_Date        => SYSDATE,
            p_Last_Updated_By         => g_update_by,
            p_Last_Update_Login       => g_update_login,
            p_Creation_Date           => SYSDATE,
            p_Created_By              => g_update_by,
            p_Attribute1              => p_cc_acct_line.Attribute1,
            p_Attribute2              => p_cc_acct_line.Attribute2,
            p_Attribute3              => p_cc_acct_line.Attribute3,
            p_Attribute4              => p_cc_acct_line.Attribute4,
            p_Attribute5              => p_cc_acct_line.Attribute5,
            p_Attribute6              => p_cc_acct_line.Attribute6,
            p_Attribute7              => p_cc_acct_line.Attribute7,
            p_Attribute8              => p_cc_acct_line.Attribute8,
            p_Attribute9              => p_cc_acct_line.Attribute9,
            p_Attribute10             => p_cc_acct_line.Attribute10,
            p_Attribute11             => p_cc_acct_line.Attribute11,
            p_Attribute12             => p_cc_acct_line.Attribute12,
            p_Attribute13             => p_cc_acct_line.Attribute13,
            p_Attribute14             => p_cc_acct_line.Attribute14,
            p_Attribute15             => p_cc_acct_line.Attribute15,
            p_Context                 => p_cc_acct_line.Context,
--bug 2043221 ssmales - 2 arguments below added
            p_CC_Func_Withheld_Amt    => l_func_withheld_amt,
            p_CC_Ent_Withheld_Amt     => p_cc_acct_line.CC_Ent_Withheld_Amt,
            G_FLAG                    => l_flag,
            P_Tax_Classif_Code        => p_cc_acct_line.Tax_Classif_Code
           );

-- --------------------------------------------------------------
--  At this point l_cc_acct_line_id has been assigned a sequence
--  number by the table handler.
-- --------------------------------------------------------------
     x_cc_acct_line_id := l_cc_acct_line_id;


-- ---------------------------------------------------------------
-- Check to make sure that the Access Copy was actually done.
-- ---------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure Inserting new Account Line ID......');
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
      END IF;


   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - Acct Line has successfully been added......');
   END IF;

   RETURN;

-- --------------------------------------
-- Exception Handlers Section
-- --------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status    := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                 p_data  => l_msg_data );

      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - EXC ERROR Failure for Acct Line ID Copy.');
      END IF;
      RETURN;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                 p_data  => l_msg_data );
      IF g_unexp_level >= g_debug_level THEN
	fnd_message.set_name('IGC','IGC_LOGGING_UNEXP_ERROR');
	fnd_message.set_token('CODE',SQLCODE);
	fnd_message.set_token('MESG',SQLERRM);
        fnd_log.message(g_unexp_level,l_full_path,TRUE);
      END IF;
      RETURN;

END Acct_Line_Copy;

/* ================================================================================
                         PROCEDURE Det_Pf_Line_Copy
   ===============================================================================*/

PROCEDURE Det_Pf_Line_Copy (
   p_cc_pmt_fcst      IN igc_cc_det_pf%ROWTYPE,
   p_cc_acct_line_id  IN igc_cc_acct_lines.cc_acct_line_id%TYPE,
   p_conversion_rate  IN igc_cc_headers.conversion_rate%TYPE,
   x_return_status   OUT NOCOPY VARCHAR2
) IS

   l_cc_pmt_fcst_id     igc_cc_det_pf.cc_det_pf_line_id%TYPE;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_Rowid              VARCHAR2(18);
   l_flag               VARCHAR2(1);
   l_functional_amount  igc_cc_det_pf.cc_det_pf_func_amt%TYPE;

   l_full_path          VARCHAR2(500) :=  g_path||'Det_Pf_Line_Copy';--bug 3199488
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Starting Det PF Line Copy......');


         Put_Debug_Msg (l_full_path,' IGCCCPCB - Conversion rate is : ' || p_conversion_rate);
      END IF;

-- ---------------------------------------------------------------------
-- Make sure that the functional amount is correctly calculated.
-- ---------------------------------------------------------------------
      IF (p_conversion_rate IS NULL) THEN
         l_functional_amount := p_cc_pmt_fcst.cc_det_pf_entered_amt;
      ELSE
         l_functional_amount := p_cc_pmt_fcst.cc_det_pf_entered_amt * p_conversion_rate;
      END IF;

      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Both Det Pf Entered Amounts are : ' ||  p_cc_pmt_fcst.CC_Det_PF_Entered_Amt);
         Put_Debug_Msg (l_full_path,' IGCCCPCB - OLD Det PF Functional Amount is : ' ||  p_cc_pmt_fcst.cc_det_pf_func_amt);
         Put_Debug_Msg (l_full_path,' IGCCCPCB - New Copied Det PF Functional Amount is : ' || l_functional_amount);
      END IF;

      IGC_CC_DET_PF_PKG.Insert_Row
         (p_api_version               => 1.0,
          p_init_msg_list             => FND_API.G_FALSE,
          p_commit                    => FND_API.G_FALSE,
          p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
          X_return_status             => l_return_status,
          X_msg_count                 => l_msg_count,
          X_msg_data                  => l_msg_data,
          p_Rowid                     => l_rowid,
          p_CC_Det_PF_Line_Id         => l_cc_pmt_fcst_id,
          p_CC_Det_PF_Line_Num        => p_cc_pmt_fcst.CC_Det_PF_Line_Num,
          p_CC_Acct_Line_Id           => p_cc_acct_line_id,
          p_Parent_Acct_Line_Id       => NULL,
          p_Parent_Det_PF_Line_Id     => NULL,
          p_CC_Det_PF_Entered_Amt     => p_cc_pmt_fcst.CC_Det_PF_Entered_Amt,
          p_CC_Det_PF_Func_Amt        => l_functional_amount,
          p_CC_Det_PF_Date            => p_cc_pmt_fcst.CC_Det_PF_Date,
          p_CC_Det_PF_Billed_Amt      => NULL,
          p_CC_Det_PF_Unbilled_Amt    => NULL,
          p_CC_Det_PF_Encmbrnc_Amt    => NULL,
          p_CC_Det_PF_Encmbrnc_Date   => NULL,
          p_CC_Det_PF_Encmbrnc_Status => NULL,
          p_Last_Update_Date          => SYSDATE,
          p_Last_Updated_By           => g_update_by,
          p_Last_Update_Login         => g_update_login,
          p_Creation_Date             => SYSDATE,
          p_Created_By                => g_update_by,
          p_Attribute1                => p_cc_pmt_fcst.Attribute1,
          p_Attribute2                => p_cc_pmt_fcst.Attribute2,
          p_Attribute3                => p_cc_pmt_fcst.Attribute3,
          p_Attribute4                => p_cc_pmt_fcst.Attribute4,
          p_Attribute5                => p_cc_pmt_fcst.Attribute5,
          p_Attribute6                => p_cc_pmt_fcst.Attribute6,
          p_Attribute7                => p_cc_pmt_fcst.Attribute7,
          p_Attribute8                => p_cc_pmt_fcst.Attribute8,
          p_Attribute9                => p_cc_pmt_fcst.Attribute9,
          p_Attribute10               => p_cc_pmt_fcst.Attribute10,
          p_Attribute11               => p_cc_pmt_fcst.Attribute11,
          p_Attribute12               => p_cc_pmt_fcst.Attribute12,
          p_Attribute13               => p_cc_pmt_fcst.Attribute13,
          p_Attribute14               => p_cc_pmt_fcst.Attribute14,
          p_Attribute15               => p_cc_pmt_fcst.Attribute15,
          p_Context                   => p_cc_pmt_fcst.Context,
          G_FLAG                      => l_flag
         );

-- ---------------------------------------------------------------
-- Check to make sure that the Det PF Line was actually done.
-- ---------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure Inserting Det PF Line ID on Copy.......');
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
      END IF;


   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - Successfully inserted Det PF Line ID.' || l_cc_pmt_fcst_id);
   END IF;

   RETURN;

-- --------------------------------------
-- Exception Handlers Section
-- --------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status    := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                 p_data  => l_msg_data );
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - EXC ERROR Copying new Det PF Line ID.');
      END IF;

      RETURN;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count, p_data  => l_msg_data );
      IF g_unexp_level >= g_debug_level THEN
    	  fnd_message.set_name('IGC','IGC_LOGGING_UNEXP_ERROR');
          fnd_message.set_token('CODE',SQLCODE);
	  fnd_message.set_token('MESG',SQLERRM);
          fnd_log.message(g_unexp_level,l_full_path,TRUE);
      END IF;
      RETURN;

END Det_Pf_Line_Copy;


/* ================================================================================
                         PROCEDURE Access_Copy
   ===============================================================================*/

PROCEDURE Access_Copy (
   p_access_lines    IN igc_cc_access%ROWTYPE,
   x_return_status  OUT NOCOPY VARCHAR2
) IS

   l_cc_access_id    igc_cc_access.cc_access_id%TYPE;
   l_return_status    VARCHAR2(1);
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(2000);
   l_Rowid            VARCHAR2(18);
   l_flag             VARCHAR2(1);

   l_full_path          VARCHAR2(500) :=  g_path||'Access_Copy';--bug 3199488
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - Starting the Access Copy routine..........');
   END IF;


      IGC_CC_ACCESS_PKG.Insert_Row
          (p_api_version       => 1.0,
           p_init_msg_list     => FND_API.G_FALSE,
           p_commit            => FND_API.G_FALSE,
           p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
           x_return_status     => l_return_status,
           x_msg_count         => l_msg_count,
           x_msg_data          => l_msg_data,
           p_row_id            => l_rowid,
           p_CC_HEADER_ID      => g_new_cc_header_id,
           p_USER_ID           => p_access_lines.user_id,
           p_CC_GROUP_ID       => p_access_lines.cc_group_id,
           p_CC_ACCESS_ID      => l_cc_access_id,
           p_CC_ACCESS_LEVEL   => p_access_lines.cc_access_level,
           p_CC_ACCESS_TYPE    => p_access_lines.cc_access_type,
           p_LAST_UPDATE_DATE  => SYSDATE,
           p_LAST_UPDATED_BY   => g_update_by,
           p_CREATION_DATE     => SYSDATE,
           p_CREATED_BY        => g_update_by,
           p_LAST_UPDATE_LOGIN => g_update_login
          );

-- ---------------------------------------------------------------
-- Check to make sure that the Access Copy was actually done.
-- ---------------------------------------------------------------
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR ;
         END IF;


   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - Successfully Added new access ID : ' || l_cc_access_id);
   END IF;

   RETURN;

-- --------------------------------------
-- Exception Handlers Section
-- --------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status    := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                 p_data  => l_msg_data );
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - EXC ERROR in inserting new Access ID........');
      END IF;
      RETURN;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                 p_data  => l_msg_data );
         IF g_unexp_level >= g_debug_level THEN
		fnd_message.set_name('IGC','IGC_LOGGING_UNEXP_ERROR');
                fnd_message.set_token('CODE',SQLCODE);
		fnd_message.set_token('MESG',SQLERRM);
                fnd_log.message(g_unexp_level,l_full_path,TRUE);
	 END IF;
      RETURN;

END Access_Copy;

/* ================================================================================
                         PROCEDURE Header_Copy
   =============================================================================== */

PROCEDURE Header_Copy (
   p_api_version           IN NUMBER,
   p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_old_cc_header_id      IN igc_cc_headers.cc_header_id%TYPE,
   p_new_cc_header_id      IN igc_cc_headers.cc_header_id%TYPE,
   p_cc_num                IN igc_cc_headers.cc_num%TYPE,
   p_cc_type               IN igc_cc_headers.cc_type%TYPE
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Header_Copy';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_cc_headers_rec	 igc_cc_headers%ROWTYPE;
   l_cc_acct_lines_rec   igc_cc_acct_lines%ROWTYPE;
   l_cc_pmt_fcst_rec     igc_cc_det_pf%ROWTYPE;
   l_cc_access_lines_rec igc_cc_access%ROWTYPE;
   l_cc_acct_line_id     igc_cc_acct_lines.cc_acct_line_id%TYPE;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_Rowid               VARCHAR2(18);
   l_action_rowid        VARCHAR2(18);
   l_flag                VARCHAR2(1);
   l_debug               VARCHAR2(1);
   l_cc_num_val          igc_cc_headers.cc_num%TYPE;
   l_cc_type_val         igc_cc_headers.cc_type%TYPE;
   l_CC_State            igc_cc_headers.cc_state%TYPE;
   l_CC_ctrl_status      igc_cc_headers.cc_ctrl_status%TYPE;
   l_CC_Encmbrnc_Status  igc_cc_headers.cc_encmbrnc_status%TYPE;
   l_CC_Apprvl_Status    igc_cc_headers.cc_apprvl_status%TYPE;

   l_full_path           VARCHAR2(500) := g_path||'Header_Copy';--bug 3199488

   CURSOR c_account_lines (t_cc_header_id NUMBER) IS
      SELECT *
        FROM igc_cc_acct_lines ccac
       WHERE ccac.cc_header_id = t_cc_header_id;

   /* Contract  Detail Payment Forecast lines  */

   CURSOR c_payment_forecast (t_cc_acct_line_id NUMBER) IS
      SELECT *
        FROM igc_cc_det_pf
       WHERE cc_acct_line_id = t_cc_acct_line_id;

   /* Contract  Access Lines  */

   CURSOR c_access_lines (t_cc_header_id NUMBER) IS
      SELECT *
        FROM igc_cc_access
       WHERE cc_header_id = t_cc_header_id;

   CURSOR c_obtain_cc_header (t_cc_header_id NUMBER) IS
      SELECT *
        FROM igc_cc_headers
       WHERE cc_header_id = t_cc_header_id;

BEGIN

   SAVEPOINT Header_Copy_Pvt ;

-- ---------------------------------------------------------------------------------------
-- Ensure that the arguments passed in match the appropriate version of this
-- procedure.
-- ---------------------------------------------------------------------------------------
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF FND_API.to_Boolean (p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS ;

-- --------------------------------------------------------------------------------------
-- Initialize Global variables that are used by procedure.
-- --------------------------------------------------------------------------------------
   g_update_login            := FND_GLOBAL.LOGIN_ID;
   g_update_by               := FND_GLOBAL.USER_ID;
   g_new_cc_header_id        := p_new_cc_header_id;
   l_cc_num_val              := p_cc_num;
   l_cc_type_val             := p_cc_type;
   l_CC_State                := 'PR';
   l_CC_ctrl_status          := 'E';
   l_CC_Encmbrnc_Status      := 'N';
   l_CC_Apprvl_Status        := 'IN';

-- --------------------------------------------------------------------------------------
-- Determine if debug has been enabled for this process.
-- --------------------------------------------------------------------------------------
--   l_debug := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;

--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN (l_debug);
   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - Starting Header Copy for New Header : ' || p_new_cc_header_id ||
                  ' from Old Header ID : ' || p_old_cc_header_id);
   END IF;

-- -------------------------------------------------------------------------------------
-- Obtain the CC Header record that is to be copied
-- -------------------------------------------------------------------------------------
   OPEN c_obtain_cc_header (p_old_cc_header_id);
   FETCH c_obtain_cc_header
    INTO l_cc_headers_rec;

   IF (c_obtain_cc_header%NOTFOUND) THEN
      IGC_MSGS_PKG.message_token (p_tokname => 'CC_NUM',
                                  p_tokval  => p_cc_num);
      IGC_MSGS_PKG.message_token (p_tokname => 'CC_HEADER_ID',
                                  p_tokval  => p_old_cc_header_id);
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_HEADER_ID_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_obtain_cc_header;

-- ------------------------------------------------------------------------------------
-- Call table handler to insert appropriate CC Header record into table as well as
-- the appropriate MRC records.
-- ------------------------------------------------------------------------------------
   IGC_CC_HEADERS_PKG.Insert_Row
      (p_api_version         => 1.0,
       p_init_msg_list       => FND_API.G_FALSE,
       p_commit              => FND_API.G_FALSE,
       p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
       X_return_status       => l_return_status,
       X_msg_count           => l_msg_count,
       X_msg_data            => l_msg_data,
       p_Rowid               => l_rowid,
       p_CC_Header_Id        => p_new_CC_Header_Id,
       p_Org_id              => l_cc_headers_rec.org_id,
       p_CC_Type             => l_cc_type_val,
       p_CC_Num              => l_CC_Num_val,
       p_CC_Version_num      => 0,
       p_Parent_Header_Id    => NULL,
       p_CC_State            => l_cc_state,
       p_CC_ctrl_status      => l_cc_ctrl_status,
       p_CC_Encmbrnc_Status  => l_cc_encmbrnc_status,
       p_CC_Apprvl_Status    => l_cc_apprvl_status,
       p_Vendor_Id           => l_cc_headers_rec.vendor_id,
       p_Vendor_Site_Id      => l_cc_headers_rec.vendor_site_id,
       p_Vendor_Contact_Id   => l_cc_headers_rec.vendor_contact_id,
       p_Term_Id             => l_cc_headers_rec.term_id,
       p_Location_Id         => l_cc_headers_rec.location_id,
       p_Set_Of_Books_Id     => l_cc_headers_rec.set_of_books_id,
       p_CC_Acct_Date        => NULL,
       p_CC_Desc             => l_cc_headers_rec.cc_desc,
       p_CC_Start_Date       => trunc(SYSDATE),
       p_CC_End_Date         => NULL,
       p_CC_Owner_User_Id    => l_cc_headers_rec.cc_owner_user_id,
       p_CC_Preparer_User_Id => l_cc_headers_rec.cc_preparer_user_id,
       p_Currency_Code       => l_cc_headers_rec.currency_code,
       p_Conversion_Type     => l_cc_headers_rec.conversion_type,
       p_Conversion_Date     => trunc(SYSDATE),
       p_Conversion_Rate     => l_cc_headers_rec.conversion_rate,
       p_Last_Update_Date    => SYSDATE,
       p_Last_Updated_By     => g_update_by,
       p_Last_Update_Login   => g_update_login,
       p_Created_By          => g_update_by,
       p_Creation_Date       => SYSDATE,
       p_CC_Current_User_Id  => l_cc_headers_rec.cc_current_user_id,
       p_Wf_Item_Type        => NULL,
       p_Wf_Item_Key         => NULL,
       p_Attribute1          => l_cc_headers_rec.Attribute1,
       p_Attribute2          => l_cc_headers_rec.Attribute2,
       p_Attribute3          => l_cc_headers_rec.Attribute3,
       p_Attribute4          => l_cc_headers_rec.Attribute4,
       p_Attribute5          => l_cc_headers_rec.Attribute5,
       p_Attribute6          => l_cc_headers_rec.Attribute6,
       p_Attribute7          => l_cc_headers_rec.Attribute7,
       p_Attribute8          => l_cc_headers_rec.Attribute8,
       p_Attribute9          => l_cc_headers_rec.Attribute9,
       p_Attribute10         => l_cc_headers_rec.Attribute10,
       p_Attribute11         => l_cc_headers_rec.Attribute11,
       p_Attribute12         => l_cc_headers_rec.Attribute12,
       p_Attribute13         => l_cc_headers_rec.Attribute13,
       p_Attribute14         => l_cc_headers_rec.Attribute14,
       p_Attribute15         => l_cc_headers_rec.Attribute15,
       p_Context             => l_cc_headers_rec.Context,
       p_CC_Guarantee_Flag   => l_cc_headers_rec.CC_Guarantee_Flag,
       G_FLAG                => l_flag
      );

-- ------------------------------------------------------------------------------------
-- Check to make sure that the Header was actually created.
-- ------------------------------------------------------------------------------------
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure inserting New CC Header id.........');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- ------------------------------------------------------------------------------------
-- Add the Entry into the Actions table indicating that the CC action is a COPY.  This
-- resolves bug 1518478 and the new ACTION_TYPE added into lookups is "CP"
-- ------------------------------------------------------------------------------------
   IGC_CC_ACTIONS_PKG.Insert_Row(
                                1.0,
                                FND_API.G_FALSE,
                                FND_API.G_FALSE,
                                FND_API.G_VALID_LEVEL_FULL,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_action_rowid,
                                p_new_CC_Header_Id,
                                0,                  -- Version number
                                'CP',               -- Action Type "COPY"
                                l_CC_State,
                                l_cc_ctrl_status,
                                l_CC_Apprvl_Status,
                                'Copied From CC Number : ' || l_cc_headers_rec.cc_num,  -- Note Field
                                Sysdate,
                                g_update_by,
                                g_update_login,
                                Sysdate,
                                g_update_by
                               );

-- ------------------------------------------------------------------------------------
-- Check to make sure that the Header was actually created.
-- ------------------------------------------------------------------------------------
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure inserting New CC Header id.........');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- ------------------------------------------------------------------------------------
-- Copy all the corresponding account lines for the CC Header given.
-- ------------------------------------------------------------------------------------
   OPEN c_account_lines(p_old_cc_header_id);

   LOOP

      FETCH c_account_lines INTO l_cc_acct_lines_rec;

      EXIT WHEN c_account_lines%NOTFOUND;

      Acct_Line_Copy (p_cc_acct_line    => l_cc_acct_lines_rec,
                      p_conversion_rate => l_cc_headers_rec.conversion_rate,
                      x_cc_acct_line_id => l_cc_acct_line_id,
                      x_return_status   => l_return_status);

-- -----------------------------------------------------------------------------------
-- Check to make sure that the Account Line was actually created.
-- -----------------------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure returned from Acct_Line_Copy......');
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
      END IF;

      OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

      LOOP

         FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

         EXIT WHEN c_payment_forecast%NOTFOUND;

         Det_Pf_Line_Copy (p_cc_pmt_fcst     => l_cc_pmt_fcst_rec,
                           p_cc_acct_line_id => l_cc_acct_line_id,
                           p_conversion_rate => l_cc_headers_rec.conversion_rate,
                           x_return_status   => l_return_status);

-- -----------------------------------------------------------------------------------
-- Check to make sure that the Det PF Line was actually created.
-- -----------------------------------------------------------------------------------
         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (g_debug_mode = 'Y') THEN
               Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure returned from Det_Pf_Line_Copy........');
            END IF;
            RAISE FND_API.G_EXC_ERROR ;
         END IF;

      END LOOP;

      CLOSE c_payment_forecast;

   END LOOP;

   CLOSE c_account_lines;

-- ------------------------------------------------------------------------------------
-- Copy all the corresponding Access lines records for the CC Header given.
-- ------------------------------------------------------------------------------------
   OPEN c_access_lines(p_old_cc_header_id);

   LOOP

      FETCH c_access_lines INTO l_cc_access_lines_rec;

      EXIT WHEN c_access_lines%NOTFOUND;

      Access_Copy (p_access_lines  => l_cc_access_lines_rec,
                   x_return_status => l_return_status);

-- -----------------------------------------------------------------------------------
-- Check to make sure that the Access Copy was actually done.
-- -----------------------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (g_debug_mode = 'Y') THEN
            Put_Debug_Msg (l_full_path,' IGCCCPCB - Failure returned from Access_Copy.......');
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
      END IF;

   END LOOP;

   CLOSE c_access_lines;

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg (l_full_path,' IGCCCPCB - CC Header has been copied successfully.......');
   END IF;

-- --------------------------------------------------------------------------------------
-- If there are no errors and the caller wants the commit to be performed then commit
-- since there were no exceptions encountered.
-- --------------------------------------------------------------------------------------
   IF FND_API.To_Boolean(p_commit)
   THEN
      IF (g_debug_mode = 'Y') THEN
         Put_Debug_Msg (l_full_path,' IGCCCPCB - Committing work performed......');
      END IF;
      COMMIT WORK;
   END IF;

   RETURN;

-- --------------------------------------------------------------------------------------
-- Exception Handler section for procedure.
-- --------------------------------------------------------------------------------------
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Header_Copy_Pvt;
       X_return_status    := FND_API.G_RET_STS_ERROR;
       g_new_cc_header_id := NULL;
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,' IGCCCPCB - EXC ERROR encountered in the Header Copy routine.....');
       END IF;
       IF (c_access_lines%ISOPEN) THEN
          CLOSE c_access_lines;
       END IF;
       IF (c_payment_forecast%ISOPEN) THEN
          CLOSE c_payment_forecast;
       END IF;
       IF (c_account_lines%ISOPEN) THEN
          CLOSE c_account_lines;
       END IF;
       IF (c_obtain_cc_header%ISOPEN) THEN
          CLOSE c_obtain_cc_header;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data );
       RETURN;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Header_Copy_Pvt;
       X_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
       g_new_cc_header_id := NULL;
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,' IGCCCPCB - EXC UNEXPECTED ERROR encountered in the Header Copy routine.....');
       END IF;
       IF (c_access_lines%ISOPEN) THEN
          CLOSE c_access_lines;
       END IF;
       IF (c_payment_forecast%ISOPEN) THEN
          CLOSE c_payment_forecast;
       END IF;
       IF (c_account_lines%ISOPEN) THEN
          CLOSE c_account_lines;
       END IF;
       IF (c_obtain_cc_header%ISOPEN) THEN
          CLOSE c_obtain_cc_header;
       END IF;
       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data );
       RETURN;

    WHEN OTHERS THEN
       ROLLBACK TO Header_Copy_Pvt;
       X_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
       g_new_cc_header_id := NULL;
       IF (g_debug_mode = 'Y') THEN
          Put_Debug_Msg (l_full_path,' IGCCCPCB - OTHERS ERROR encountered in the Header Copy routine.....');
       END IF;
       IF (c_access_lines%ISOPEN) THEN
          CLOSE c_access_lines;
       END IF;
       IF (c_payment_forecast%ISOPEN) THEN
          CLOSE c_payment_forecast;
       END IF;
       IF (c_account_lines%ISOPEN) THEN
          CLOSE c_account_lines;
       END IF;
       IF (c_obtain_cc_header%ISOPEN) THEN
          CLOSE c_obtain_cc_header;
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                   l_api_name);
       END if;

       FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                  p_data  => X_msg_data );
       RETURN;

END Header_Copy;

/*modifed for 3199488 - fnd logging changes*/
PROCEDURE Put_Debug_Msg (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2,
   p_sev_level      IN VARCHAR2 := g_state_level
) IS
BEGIN

	IF p_sev_level >= g_debug_level THEN
		fnd_log.string(p_sev_level, p_path, p_debug_msg);
	END IF;
END;
/*************
PROCEDURE Put_Debug_Msg (
   p_debug_msg IN VARCHAR2
) IS

   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';

BEGIN

   IGC_MSGS_PKG.Put_Debug_Msg (l_full_path,p_debug_message    => p_debug_msg,
                               p_profile_log_name => g_profile_name,
                               p_prod             => g_prod,
                               p_sub_comp         => g_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

END Put_Debug_Msg;
****************/
END IGC_CC_COPY_PKG;

/
