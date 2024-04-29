--------------------------------------------------------
--  DDL for Package Body IGC_CC_DET_PF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_DET_PF_PKG" as
/* $Header: IGCCDPFB.pls 120.4.12000000.3 2007/10/19 06:51:09 smannava ship $  */

   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_DET_PF_PKG';
   g_debug_flag        VARCHAR2(1) := 'N' ;
   g_debug_msg         VARCHAR2(10000) := NULL;

   --g_debug_mode VARCHAR2(1):= NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
   g_debug_mode VARCHAR2(1):= NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--following variables added for bug 3199488: fnd logging changes: sdixit
   g_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level number	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level number	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path CONSTANT varchar2(500) :=      'igc.plsql.igccdpfb.igc_cc_det_pf_pkg.';

/* ================================================================================
                         PROCEDURE Output_Debug
   ===============================================================================*/
/*modifed for 3199488 - fnd logging changes*/
PROCEDURE Output_Debug (
   p_path           IN VARCHAR2,
   p_debug_msg      IN VARCHAR2,
   p_sev_level      IN VARCHAR2 := g_state_level
) IS
BEGIN

	IF p_sev_level >= g_debug_level THEN
		fnd_log.string(p_sev_level, p_path, p_debug_msg);
	END IF;
END;
/*********************
PROCEDURE Output_Debug (p_path => l_full_path ,
   p_debug_msg      IN VARCHAR2
) IS

   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(8)           := 'CC_DPFB';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

   IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
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

END Output_Debug;
************************/

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
   p_Rowid                     IN OUT NOCOPY   VARCHAR2,
   p_CC_Det_PF_Line_Id         IN OUT NOCOPY   IGC_CC_DET_PF.CC_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Line_Num                 IGC_CC_DET_PF.CC_Det_PF_Line_Num%TYPE,
   p_CC_Acct_Line_Id                    IGC_CC_DET_PF.CC_Acct_Line_Id%TYPE,
   p_Parent_Acct_Line_Id                IGC_CC_DET_PF.Parent_Acct_Line_Id%TYPE,
   p_Parent_Det_PF_Line_Id              IGC_CC_DET_PF.Parent_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Entered_Amt              IGC_CC_DET_PF.CC_Det_PF_Entered_Amt%TYPE,
   p_CC_Det_PF_Func_Amt                 IGC_CC_DET_PF.CC_Det_PF_Func_Amt%TYPE,
   p_CC_Det_PF_Date                     IGC_CC_DET_PF.CC_Det_PF_Date%TYPE,
   p_CC_Det_PF_Billed_Amt               IGC_CC_DET_PF.CC_Det_PF_Billed_Amt%TYPE,
   p_CC_Det_PF_Unbilled_Amt             IGC_CC_DET_PF.CC_Det_PF_Unbilled_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Amt             IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Date            IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Date%TYPE,
   p_CC_Det_PF_Encmbrnc_Status          IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Status%TYPE,
   p_Last_Update_Date                   IGC_CC_DET_PF.Last_Update_Date%TYPE,
   p_Last_Updated_By                    IGC_CC_DET_PF.Last_Updated_By%TYPE,
   p_Last_Update_Login                  IGC_CC_DET_PF.Last_Update_Login%TYPE,
   p_Creation_Date                      IGC_CC_DET_PF.Creation_Date%TYPE,
   p_Created_By                         IGC_CC_DET_PF.Created_By%TYPE,
   p_Attribute1                         IGC_CC_DET_PF.Attribute1%TYPE,
   p_Attribute2                         IGC_CC_DET_PF.Attribute2%TYPE,
   p_Attribute3                         IGC_CC_DET_PF.Attribute3%TYPE,
   p_Attribute4                         IGC_CC_DET_PF.Attribute4%TYPE,
   p_Attribute5                         IGC_CC_DET_PF.Attribute5%TYPE,
   p_Attribute6                         IGC_CC_DET_PF.Attribute6%TYPE,
   p_Attribute7                         IGC_CC_DET_PF.Attribute7%TYPE,
   p_Attribute8                         IGC_CC_DET_PF.Attribute8%TYPE,
   p_Attribute9                         IGC_CC_DET_PF.Attribute9%TYPE,
   p_Attribute10                        IGC_CC_DET_PF.Attribute10%TYPE,
   p_Attribute11                        IGC_CC_DET_PF.Attribute11%TYPE,
   p_Attribute12                        IGC_CC_DET_PF.Attribute12%TYPE,
   p_Attribute13                        IGC_CC_DET_PF.Attribute13%TYPE,
   p_Attribute14                        IGC_CC_DET_PF.Attribute14%TYPE,
   p_Attribute15                        IGC_CC_DET_PF.Attribute15%TYPE,
   p_Context                            IGC_CC_DET_PF.Context%TYPE,
   G_FLAG                      IN OUT NOCOPY   VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_version_num         IGC_CC_HEADERS.CC_Version_Num%TYPE;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_action_flag         VARCHAR2(1) := 'I';
   l_return_status       VARCHAR2(1);
   l_row_id              VARCHAR2(18);
   l_debug               VARCHAR2(1);

   CURSOR c_det_pf_row_id IS
      SELECT Rowid
        FROM IGC_CC_DET_PF
       WHERE CC_Det_PF_Line_Id = p_CC_Det_PF_Line_Id;

   CURSOR c_cc_version_num IS
      SELECT CC_Version_Num
        from IGC_CC_HEADERS     ICH,
             IGC_CC_ACCT_LINES  IAL
      WHERE ICH.CC_HEADER_ID    = IAL.CC_HEADER_ID
        and IAL.CC_ACCT_LINE_ID = p_cc_acct_line_id;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

   CURSOR c_det_pf_info IS
      SELECT SET_OF_BOOKS_ID,
             ORG_ID,CONVERSION_DATE
        FROM IGC_CC_HEADERS      ICH,
             IGC_CC_ACCT_LINES   IAL,
             IGC_CC_DET_PF       IDP
       WHERE ICH.CC_HEADER_ID      = IAL.CC_HEADER_ID
         AND IDP.CC_ACCT_LINE_ID   = IAL.CC_ACCT_LINE_ID
         AND IDP.CC_DET_PF_LINE_ID = p_CC_Det_Pf_Line_Id;

   l_full_path varchar2(500);
BEGIN

   SAVEPOINT Insert_Row_Pvt ;

l_full_path := g_path||'Insert_Row';--bug 3199488

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
   l_row_id        := p_Rowid;
--   l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- Begin Insert Payment Forcast for Account Line ID...'  || p_cc_acct_line_id;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Insert the DET PF line record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_DET_PF
            (CC_Det_PF_Line_Id,
             Parent_Det_PF_Line_Id,
             CC_Acct_Line_Id,
             Parent_Acct_Line_Id,
             CC_Det_PF_Line_Num,
             CC_Det_PF_Entered_Amt,
             CC_Det_PF_Func_Amt,
             CC_Det_PF_Date,
             CC_Det_PF_Billed_Amt,
             CC_Det_PF_Unbilled_Amt,
             CC_Det_PF_Encmbrnc_Amt,
             CC_Det_PF_Encmbrnc_Date,
             CC_Det_PF_Encmbrnc_Status,
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
             Context
            )
      VALUES
            ( NVL(p_CC_Det_PF_Line_Id,igc_cc_det_pf_s.NEXTVAL),
             p_Parent_Det_PF_Line_Id,
             p_CC_Acct_Line_Id,
             p_Parent_Acct_Line_Id,
             p_CC_Det_PF_Line_Num,
             p_CC_Det_PF_Entered_Amt,
             p_CC_Det_PF_Func_Amt,
             p_CC_Det_PF_Date,
             p_CC_Det_PF_Billed_Amt,
             p_CC_Det_PF_Unbilled_Amt,
             p_CC_Det_PF_Encmbrnc_Amt,
             p_CC_Det_PF_Encmbrnc_Date,
             p_CC_Det_PF_Encmbrnc_Status,
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
             p_Context
            ) RETURNING CC_Det_PF_Line_Id INTO p_CC_Det_PF_Line_Id;

-- -----------------------------------------------------------------
-- Get the next history version number for the account line history
-- -----------------------------------------------------------------
     OPEN c_cc_version_num;
     FETCH c_cc_version_num
      INTO l_version_num;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- Fetching Payment Forcast Version Num';
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- If there is a version number present then insert the next
-- history record for the account line being inserted.
-- -----------------------------------------------------------------
     IF (l_Version_Num > 0) THEN

        IGC_CC_DET_PF_HISTORY_PKG.Insert_Row (
                       l_api_version,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       p_validation_level,
                       l_return_status,
                       X_msg_count,
                       X_msg_data,
                       l_row_id,
                       p_CC_Det_PF_Line_Id,
                       p_CC_Det_PF_Line_Num,
                       p_CC_Acct_Line_Id,
                       p_Parent_Acct_Line_Id,
                       p_Parent_Det_PF_Line_Id,
                       l_version_num - 1,
                       l_action_flag,
                       p_CC_Det_PF_Entered_Amt,
                       p_CC_Det_PF_Func_Amt,
                       p_CC_Det_PF_Date,
                       p_CC_Det_PF_Billed_Amt,
                       p_CC_Det_PF_Unbilled_Amt,
                       p_CC_Det_PF_Encmbrnc_Amt,
                       p_CC_Det_PF_Encmbrnc_Date,
                       p_CC_Det_PF_Encmbrnc_Status,
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
                       G_FLAG );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' IGCCDPFB -- Failure returned from History Insert Payment Forcast Row';
            Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Inserted Payment Forcast History Row';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;

      G_FLAG := 'Y';

   END IF ;

-- -------------------------------------------------------------------
-- Obtain the ROWID of the record that was just inserted to return
-- to the caller.
-- -------------------------------------------------------------------
   OPEN c_det_pf_row_id;
   FETCH c_det_pf_row_id
    INTO p_Rowid;

-- -------------------------------------------------------------------
-- If no ROWID can be obtained then exit the procedure with a failure
-- -------------------------------------------------------------------
   IF (c_det_pf_row_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failure getting Payment Forcast Row ID';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_det_pf_row_id;

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
         g_debug_msg := ' IGCCDPFB -- Failure getting Application ID in Payment FC Insert';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
       END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- Obtain the set of books, org id, and the conversion date for the
-- CC Header record that the DET PF line is associated to.
-- ------------------------------------------------------------------
   OPEN c_det_pf_info;
   FETCH c_det_pf_info
    INTO l_Set_Of_Books_Id,
         l_Org_Id,
         l_Conversion_Date;

-- ------------------------------------------------------------------
-- Exit procedure if the values can not be obtained.
-- ------------------------------------------------------------------
   IF (c_det_pf_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failure getting Payment Forcast Info';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
       END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_det_pf_info;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (l_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/
                           l_Org_Id,
                           NULL,
                           l_MRC_Enabled
                          );

-- ------------------------------------------------------------------
-- If MRC is enabled for this set of books being used then call the
-- handler to insert all reporting set of books into the MRC
-- table for the account line inserted.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- MRC enabled for Payment Forcast ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_DET_PF to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_DET_PF (l_api_version,
                                           FND_API.G_FALSE,
                                           FND_API.G_FALSE,
                                           p_validation_level,
                                           l_return_status,
                                           X_msg_count,
                                           X_msg_data,
                                           p_CC_DET_PF_LINE_ID,
                                           l_Set_Of_Books_Id,
                                            101, /*--l_Application_Id, commented for MRC uptake*/
                                          l_org_Id,
                                           NVL(l_Conversion_Date, sysdate),
                                           p_CC_DET_PF_FUNC_AMT,
                                           p_CC_DET_PF_ENCMBRNC_AMT,
                                           l_action_flag);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          IF (IGC_MSGS_PKG.g_debug_mode) THEN
          IF (g_debug_mode = 'Y') THEN
             g_debug_msg := ' IGCCDPFB -- Failure returned from MRC processing';
             Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

--       IF (IGC_MSGS_PKG.g_debug_mode) THEN
       IF (g_debug_mode = 'Y') THEN
          g_debug_msg := ' IGCCDPFB -- MRC Payment Forcast Success';
          Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
       END IF;

   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Committing Payment Forcast Insert';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- End Payment Forcast Insert ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Execute Payment Forcast ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
    END IF;
    IF (c_det_pf_row_id%ISOPEN) THEN
       CLOSE c_det_pf_row_id;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_det_pf_info%ISOPEN) THEN
       CLOSE c_det_pf_info;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Unexpected Payment Forcast ID...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
    END IF;
    IF (c_det_pf_row_id%ISOPEN) THEN
       CLOSE c_det_pf_row_id;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_det_pf_info%ISOPEN) THEN
       CLOSE c_det_pf_info;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Others Payment Forcast ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
    END IF;
    IF (c_det_pf_row_id%ISOPEN) THEN
       CLOSE c_det_pf_row_id;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    IF (c_det_pf_info%ISOPEN) THEN
       CLOSE c_det_pf_info;
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
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   X_msg_count                 OUT NOCOPY      NUMBER,
   X_msg_data                  OUT NOCOPY      VARCHAR2,
   p_Rowid                     IN OUT NOCOPY   VARCHAR2,
   p_CC_Det_PF_Line_Id               IGC_CC_DET_PF.CC_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Line_Num              IGC_CC_DET_PF.CC_Det_PF_Line_Num%TYPE,
   p_CC_Acct_Line_Id                 IGC_CC_DET_PF.CC_Acct_Line_Id%TYPE,
   p_Parent_Acct_Line_Id             IGC_CC_DET_PF.Parent_Acct_Line_Id%TYPE,
   p_Parent_Det_PF_Line_Id           IGC_CC_DET_PF.Parent_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Entered_Amt           IGC_CC_DET_PF.CC_Det_PF_Entered_Amt%TYPE,
   p_CC_Det_PF_Func_Amt              IGC_CC_DET_PF.CC_Det_PF_Func_Amt%TYPE,
   p_CC_Det_PF_Date                  IGC_CC_DET_PF.CC_Det_PF_Date%TYPE,
   p_CC_Det_PF_Billed_Amt            IGC_CC_DET_PF.CC_Det_PF_Billed_Amt%TYPE,
   p_CC_Det_PF_Unbilled_Amt          IGC_CC_DET_PF.CC_Det_PF_Unbilled_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Amt          IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Date         IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Date%TYPE,
   p_CC_Det_PF_Encmbrnc_Status       IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Status%TYPE,
   p_Last_Update_Date                IGC_CC_DET_PF.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_DET_PF.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_DET_PF.Last_Update_Login%TYPE,
   p_Creation_Date                   IGC_CC_DET_PF.Creation_Date%TYPE,
   p_Created_By                      IGC_CC_DET_PF.Created_By%TYPE,
   p_Attribute1                      IGC_CC_DET_PF.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_DET_PF.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_DET_PF.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_DET_PF.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_DET_PF.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_DET_PF.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_DET_PF.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_DET_PF.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_DET_PF.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_DET_PF.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_DET_PF.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_DET_PF.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_DET_PF.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_DET_PF.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_DET_PF.Attribute15%TYPE,
   p_Context                         IGC_CC_DET_PF.Context%TYPE,
   X_row_locked                OUT NOCOPY      VARCHAR2,
   G_FLAG                      IN OUT NOCOPY   VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   Counter               NUMBER;
   l_debug               VARCHAR2(1);

   CURSOR C IS
      SELECT *
        FROM IGC_CC_DET_PF
       WHERE Rowid = p_Rowid
         FOR UPDATE of CC_Det_PF_Line_Id NOWAIT;

   Recinfo C%ROWTYPE;

   l_full_path varchar2(500);
BEGIN

l_full_path := g_path||'Lock_Row';--bug 3199488

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
      g_debug_msg := ' IGCCDPFB -- Begin Lock Payment Forcast Line ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

   OPEN C;
   FETCH C
    INTO Recinfo;

   IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      IF(g_excep_level >= g_debug_level) THEN
          FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE C;

   IF (
               (Recinfo.CC_Det_PF_Line_Id =  p_CC_Det_PF_Line_Id)
           AND (Recinfo.CC_Det_PF_Line_Num =  p_CC_Det_PF_Line_Num)
           AND (Recinfo.CC_Acct_Line_Id =  p_CC_Acct_Line_Id)
           AND (Recinfo.CC_Det_PF_Date =  p_CC_Det_PF_Date)
           AND (   (Recinfo.Parent_Det_PF_Line_Id =  p_Parent_Det_PF_Line_Id)
                OR (    (Recinfo.Parent_Det_PF_Line_Id IS NULL)
                    AND (p_Parent_Det_PF_Line_Id IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Entered_Amt =  p_CC_Det_PF_Entered_Amt)
                OR (    (Recinfo.CC_Det_PF_Entered_Amt IS NULL)
                    AND (p_CC_Det_PF_Entered_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Func_Amt =  p_CC_Det_PF_Func_Amt)
                OR (    (Recinfo.CC_Det_PF_Func_Amt IS NULL)
                    AND (p_CC_Det_PF_Func_Amt IS NULL)))
          -- AND (   (Recinfo.CC_Det_PF_Billed_Amt =  p_CC_Det_PF_Billed_Amt)
           --     OR (    (Recinfo.CC_Det_PF_Billed_Amt IS NULL)
            --        AND (p_CC_Det_PF_Billed_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_UnBilled_Amt =  p_CC_Det_PF_UnBilled_Amt )
                OR (    (Recinfo.CC_Det_PF_UnBilled_Amt  IS NULL)
                    AND (p_CC_Det_PF_UnBilled_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Encmbrnc_Amt =  p_CC_Det_PF_Encmbrnc_Amt)
                OR (    (Recinfo.CC_Det_PF_Encmbrnc_Amt IS NULL)
                    AND (p_CC_Det_PF_Encmbrnc_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Encmbrnc_Date =  p_CC_Det_PF_Encmbrnc_Date)
                OR (    (Recinfo.CC_Det_PF_Encmbrnc_Date IS NULL)
                    AND (p_CC_Det_PF_Encmbrnc_Date IS NULL)))
          -- AND (   (Recinfo.CC_Det_PF_Encmbrnc_Status =  p_CC_Det_PF_Encmbrnc_Status)
           --     OR (    (Recinfo.CC_Det_PF_Encmbrnc_Status IS NULL)
            --        AND (p_CC_Det_PF_Encmbrnc_Status IS NULL)))
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

      ) THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Lock Payment Forcast line ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      NULL;

   ELSE

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failed Lock Payment Forcast line';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      IF(g_excep_level >= g_debug_level) THEN
           FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
      END IF;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;

   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Committing Lock Payment Forcast line';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- End Lock Payment Forcast line ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_row_locked := FND_API.G_FALSE;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Record Lock exception Payment Forcast line';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Execute exception Payment Forcast line';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Unexpected exception Payment Forcast line';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Others exception Payment Forcast line';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
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
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   X_msg_count                 OUT NOCOPY      NUMBER,
   X_msg_data                  OUT NOCOPY      VARCHAR2,
   p_Rowid                     IN OUT NOCOPY   VARCHAR2,
   p_CC_Det_PF_Line_Id                  IGC_CC_DET_PF.CC_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Line_Num                 IGC_CC_DET_PF.CC_Det_PF_Line_Num%TYPE,
   p_CC_Acct_Line_Id                    IGC_CC_DET_PF.CC_Acct_Line_Id%TYPE,
   p_Parent_Acct_Line_Id                IGC_CC_DET_PF.Parent_Acct_Line_Id%TYPE,
   p_Parent_Det_PF_Line_Id              IGC_CC_DET_PF.Parent_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Entered_Amt              IGC_CC_DET_PF.CC_Det_PF_Entered_Amt%TYPE,
   p_CC_Det_PF_Func_Amt                 IGC_CC_DET_PF.CC_Det_PF_Func_Amt%TYPE,
   p_CC_Det_PF_Date                     IGC_CC_DET_PF.CC_Det_PF_Date%TYPE,
   p_CC_Det_PF_Billed_Amt               IGC_CC_DET_PF.CC_Det_PF_Billed_Amt%TYPE,
   p_CC_Det_PF_Unbilled_Amt             IGC_CC_DET_PF.CC_Det_PF_Unbilled_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Amt             IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Date            IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Date%TYPE,
   p_CC_Det_PF_Encmbrnc_Status          IGC_CC_DET_PF.CC_Det_PF_Encmbrnc_Status%TYPE,
   p_Last_Update_Date                   IGC_CC_DET_PF.Last_Update_Date%TYPE,
   p_Last_Updated_By                    IGC_CC_DET_PF.Last_Updated_By%TYPE,
   p_Last_Update_Login                  IGC_CC_DET_PF.Last_Update_Login%TYPE,
   p_Creation_Date                      IGC_CC_DET_PF.Creation_Date%TYPE,
   p_Created_By                         IGC_CC_DET_PF.Created_By%TYPE,
   p_Attribute1                         IGC_CC_DET_PF.Attribute1%TYPE,
   p_Attribute2                         IGC_CC_DET_PF.Attribute2%TYPE,
   p_Attribute3                         IGC_CC_DET_PF.Attribute3%TYPE,
   p_Attribute4                         IGC_CC_DET_PF.Attribute4%TYPE,
   p_Attribute5                         IGC_CC_DET_PF.Attribute5%TYPE,
   p_Attribute6                         IGC_CC_DET_PF.Attribute6%TYPE,
   p_Attribute7                         IGC_CC_DET_PF.Attribute7%TYPE,
   p_Attribute8                         IGC_CC_DET_PF.Attribute8%TYPE,
   p_Attribute9                         IGC_CC_DET_PF.Attribute9%TYPE,
   p_Attribute10                        IGC_CC_DET_PF.Attribute10%TYPE,
   p_Attribute11                        IGC_CC_DET_PF.Attribute11%TYPE,
   p_Attribute12                        IGC_CC_DET_PF.Attribute12%TYPE,
   p_Attribute13                        IGC_CC_DET_PF.Attribute13%TYPE,
   p_Attribute14                        IGC_CC_DET_PF.Attribute14%TYPE,
   p_Attribute15                        IGC_CC_DET_PF.Attribute15%TYPE,
   p_Context                            IGC_CC_DET_PF.Context%TYPE,
   G_FLAG                      IN OUT NOCOPY   VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_action_flag         VARCHAR2(1) := 'U';
   l_return_status       VARCHAR2(1);
   l_debug               VARCHAR2(1);

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

   CURSOR c_det_pf_info IS
     SELECT ICH.SET_OF_BOOKS_ID,
            ICH.ORG_ID
       FROM IGC_CC_HEADERS     ICH,
            IGC_CC_ACCT_LINES  IAL,
            IGC_CC_DET_PF      IDP
      WHERE ICH.CC_HEADER_ID      = IAL.CC_HEADER_ID
        AND IDP.CC_ACCT_LINE_ID   = IAL.CC_ACCT_LINE_ID
        AND IDP.CC_DET_PF_LINE_ID = p_CC_Det_Pf_Line_Id;

   l_full_path varchar2(500);
BEGIN

l_full_path := g_path||'Update_Row';--bug 3199488

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
      g_debug_msg := ' IGCCDPFB -- Starting Update Payment Forcast Line ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------------
-- Update the Det PF Line Record
-- --------------------------------------------------------------------------
   UPDATE IGC_CC_DET_PF
      SET CC_Det_PF_Line_Id             =       p_CC_Det_PF_Line_Id,
          Parent_Det_PF_Line_Id         =       p_Parent_Det_PF_Line_Id,
          CC_Acct_Line_Id               =       p_CC_Acct_Line_Id,
          Parent_Acct_Line_Id           =       p_Parent_Acct_Line_Id,
          CC_Det_PF_Line_Num            =       p_CC_Det_PF_Line_Num,
          CC_Det_PF_Entered_Amt         =       p_CC_Det_PF_Entered_Amt,
          CC_Det_PF_Func_Amt            =       p_CC_Det_PF_Func_Amt,
          CC_Det_PF_Date                =       p_CC_Det_PF_Date,
          CC_Det_PF_Billed_Amt          =       p_CC_Det_PF_Billed_Amt,
          CC_Det_PF_Unbilled_Amt        =       p_CC_Det_PF_Unbilled_Amt,
          CC_Det_PF_Encmbrnc_Amt        =       p_CC_Det_PF_Encmbrnc_Amt,
          CC_Det_PF_Encmbrnc_Date       =       p_CC_Det_PF_Encmbrnc_Date,
          CC_Det_PF_Encmbrnc_Status     =       p_CC_Det_PF_Encmbrnc_Status,
          Last_Update_Date              =       p_Last_Update_Date,
          Last_Updated_By               =       p_Last_Updated_By,
          Last_Update_Login             =       p_Last_Update_Login,
          Creation_Date                 =       p_Creation_Date,
          Created_By                    =       p_Created_By,
          Attribute1                    =       p_Attribute1,
          Attribute2                    =       p_Attribute2,
          Attribute3                    =       p_Attribute3,
          Attribute4                    =       p_Attribute4,
          Attribute5                    =       p_Attribute5,
          Attribute6                    =       p_Attribute6,
          Attribute7                    =       p_Attribute7,
          Attribute8                    =       p_Attribute8,
          Attribute9                    =       p_Attribute9,
          Attribute10                   =       p_Attribute10,
          Attribute11                   =       p_Attribute11,
          Attribute12                   =       p_Attribute12,
          Attribute13                   =       p_Attribute13,
          Attribute14                   =       p_Attribute14,
          Attribute15                   =       p_Attribute15,
          Context                       =       p_Context
    WHERE rowid = p_Rowid;

    IF (SQL%NOTFOUND) THEN
--       IF (IGC_MSGS_PKG.g_debug_mode) THEN
       IF (g_debug_mode = 'Y') THEN
          g_debug_msg := ' IGCCDPFB -- Payment Forcast Line not found to update.....';
          Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
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
         g_debug_msg := ' IGCCDPFB -- Failure getting application ID for Payment Forcast Update.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

   OPEN c_det_pf_info;
   FETCH c_det_pf_info
    INTO l_Set_Of_Books_Id,
         l_Org_Id;

-- ------------------------------------------------------------------
-- If the Det PF Info can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_det_pf_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failure getting Payment Forcast info for Update.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_det_pf_info;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------


   gl_mc_info.mrc_enabled (l_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/
                           l_Org_Id,
                           NULL,
                           l_MRC_Enabled
                          );

-- ------------------------------------------------------------------
-- If MRC is enabled for this set of books being used then call the
-- handler to insert all reporting set of books into the MRC
-- table for the account line inserted.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- MRC enabled Payment Forcast Update.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_DET_PF to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_DET_PF (l_api_version,
                                           FND_API.G_FALSE,
                                           FND_API.G_FALSE,
                                           p_validation_level,
                                           l_return_status,
                                           X_msg_count,
                                           X_msg_data,
                                           p_CC_DET_PF_LINE_ID,
                                           l_Set_Of_Books_Id,
                                           101, /*--l_Application_Id, commented for MRC uptake*/
                                           l_org_Id,
                                  --         l_Conversion_Date,
                                           sysdate,  -- Added
                                           p_CC_DET_PF_FUNC_AMT,
                                           p_CC_DET_PF_ENCMBRNC_AMT,
                                           l_action_flag);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' IGCCDPFB -- Failure returned from MRC for update.....';
            Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
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
         g_debug_msg := ' IGCCDPFB -- Committing work for Payment Forcast update.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- End Payment Forcast Update Line ID ...' || p_CC_Det_PF_Line_Id ||
                     ' For account Line ID ... ' || p_cc_acct_line_id;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Execute Payment Forcast Update.....';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    IF (c_det_pf_info%ISOPEN) THEN
       CLOSE c_det_pf_info;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Unexpected Payment Forcast Update.....';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    IF (c_det_pf_info%ISOPEN) THEN
       CLOSE c_det_pf_info;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Others Payment Forcast Update.....';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    IF (c_det_pf_info%ISOPEN) THEN
       CLOSE c_det_pf_info;
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
   p_api_version               IN       NUMBER,
   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY      VARCHAR2,
   X_msg_count                 OUT NOCOPY      NUMBER,
   X_msg_data                  OUT NOCOPY      VARCHAR2,
   p_Rowid                  IN OUT NOCOPY      VARCHAR2,
   G_FLAG                   IN OUT NOCOPY      VARCHAR2
) IS

   l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
   l_api_version             CONSTANT NUMBER         :=  1.0;
   l_return_status           VARCHAR2(1);
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000);
   l_version_num             IGC_CC_HEADERS.CC_Version_Num%TYPE;
   l_action_flag             VARCHAR2(1) := 'D';
   l_det_pf_row_id           VarChar2(18);
   l_Application_Id          NUMBER;
   l_Conversion_Date         DATE;
   l_Set_Of_Books_Id         NUMBER;
   l_Org_Id                  NUMBER(15);
   l_MRC_Enabled             VARCHAR2(1);
   l_global_flag             VARCHAR2(1);
   l_debug                   VARCHAR2(1);

   CURSOR c_det_pf_row_info IS
      SELECT *
        FROM IGC_CC_DET_PF
       WHERE Rowid = p_Rowid;

   CURSOR c_cc_version_num IS
      SELECT CC_Version_Num
        FROM IGC_CC_HEADERS      ICH,
             IGC_CC_ACCT_LINES   IAL,
             IGC_CC_DET_PF       IDP
       WHERE ICH.CC_HEADER_ID    = IAL.CC_HEADER_ID
         AND IAL.CC_ACCT_LINE_ID = IDP.CC_ACCT_LINE_ID
         AND IDP.ROWID           = p_rowid;

   Recinfo c_det_pf_row_info%ROWTYPE;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

   CURSOR c_cc_info IS
     SELECT ICH.SET_OF_BOOKS_ID,
            ICH.ORG_ID,
            ICH.CONVERSION_DATE
       FROM IGC_CC_HEADERS     ICH,
            IGC_CC_ACCT_LINES  CAL,
            IGC_CC_DET_PF      DPF
      WHERE ICH.CC_HEADER_ID      = CAL.CC_HEADER_ID
        AND CAL.CC_ACCT_LINE_ID   = DPF.CC_ACCT_LINE_ID
        AND DPF.CC_DET_PF_LINE_ID = Recinfo.cc_det_pf_line_id;

   l_full_path varchar2(500);
BEGIN

l_full_path := g_path||'Delete_Row';--bug 3199488

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
       g_debug_msg := ' IGCCDPFB -- Starting Payment Forcast delete Row ID ... ' || p_rowid;
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Get the next history version number for the account line history
-- -----------------------------------------------------------------
   OPEN c_cc_version_num;
   FETCH c_cc_version_num
    INTO l_version_num;

   IF (c_cc_version_num%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failed getting version num for Payment FC Delete.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c_cc_version_num;

-- -----------------------------------------------------------------
-- Get The record that is about to be deleted
-- -----------------------------------------------------------------
   OPEN c_det_pf_row_info;
   FETCH c_det_pf_row_info
    INTO Recinfo;

   IF (c_det_pf_row_info%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failrue getting Row for Payment FC Delete.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c_det_pf_row_info;

   IGC_CC_DET_PF_HISTORY_PKG.Insert_Row(
                       l_api_version,
                       FND_API.G_FALSE,
                       FND_API.G_FALSE,
                       p_validation_level,
                       l_return_status,
                       X_msg_count,
                       X_msg_data,
                       l_det_pf_row_id,
                       Recinfo.CC_Det_PF_Line_Id,
                       Recinfo.CC_Det_PF_Line_Num,
                       Recinfo.CC_Acct_Line_Id,
                       Recinfo.Parent_Acct_Line_Id,
                       Recinfo.Parent_Det_PF_Line_Id,
                       l_version_num-1,
                       l_action_flag,
                       Recinfo.CC_Det_PF_Entered_Amt,
                       Recinfo.CC_Det_PF_Func_Amt,
                       Recinfo.CC_Det_PF_Date,
                       Recinfo.CC_Det_PF_Billed_Amt,
                       Recinfo.CC_Det_PF_Unbilled_Amt,
                       Recinfo.CC_Det_PF_Encmbrnc_Amt,
                       Recinfo.CC_Det_PF_Encmbrnc_Date,
                       Recinfo.CC_Det_PF_Encmbrnc_Status,
                       Recinfo.Last_Update_Date,
                       Recinfo.Last_Updated_By,
                       Recinfo.Last_Update_Login,
                       Recinfo.Creation_Date,
                       Recinfo.Created_By,
                       Recinfo.Attribute1,
                       Recinfo.Attribute2,
                       Recinfo.Attribute3,
                       Recinfo.Attribute4,
                       Recinfo.Attribute5,
                       Recinfo.Attribute6,
                       Recinfo.Attribute7,
                       Recinfo.Attribute8,
                       Recinfo.Attribute9,
                       Recinfo.Attribute10 ,
                       Recinfo.Attribute11,
                       Recinfo.Attribute12,
                       Recinfo.Attribute13,
                       Recinfo.Attribute14,
                       Recinfo.Attribute15,
                       Recinfo.Context,
                       G_FLAG
                      );

-- ------------------------------------------------------------------
-- Make sure that the insertion of History Record was a success
-- ------------------------------------------------------------------
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failure returned from Payment FC History insert.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- History insert success for Payment FC Delete.....';
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
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
         g_debug_msg := ' IGCCDPFB -- Failure obtaining application ID in delete operation...';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
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
         g_debug_msg := ' IGCCDPFB -- Failure obtaining CC Info conversion date in delete...';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
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
         g_debug_msg := ' IGCCDPFB-- MRC Enabled so now deleting MRC info...';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_DET_PF to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_DET_PF (l_api_version,
                                           FND_API.G_FALSE,
                                           FND_API.G_FALSE,
                                           p_validation_level,
                                           l_return_status,
                                           X_msg_count,
                                           X_msg_data,
                                           Recinfo.cc_det_pf_line_id,
                                           l_Set_Of_Books_Id,
                                            101, /*--l_Application_Id, commented for MRC uptake*/
                                           l_org_Id,
                                           NVL(l_Conversion_Date,sysdate),
                                           0,
                                           0,
                                           l_action_flag);

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y') THEN
            g_debug_msg := ' IGCCACLB -- Failure returned from MC.get_rsobs_Acct_Lines delete...';
            Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;

-- ----------------------------------------------------------------
-- Delete the requested record from the Det PF Line table
-- ----------------------------------------------------------------
   DELETE
     FROM IGC_CC_DET_PF
    WHERE rowid = p_Rowid;

   IF (SQL%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Failure deleting Row for Payment FC .....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      RAISE NO_DATA_FOUND;
   END IF;

   G_FLAG := 'Y';

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y') THEN
         g_debug_msg := ' IGCCDPFB -- Payment FC Delete being Committed.....';
         Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF (g_debug_mode = 'Y') THEN
      g_debug_msg := ' IGCCDPFB -- End of Delete row ID ...' || p_rowid;
      Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Delete Execute Error.....';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    IF (c_det_pf_row_info%ISOPEN) THEN
       CLOSE c_det_pf_row_info;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Delete Unexpected Error.....';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    IF (c_det_pf_row_info%ISOPEN) THEN
       CLOSE c_det_pf_row_info;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF (g_debug_mode = 'Y') THEN
       g_debug_msg := ' IGCCDPFB -- Failure Delete Others Error.....';
       Output_Debug (p_path => l_full_path ,p_debug_msg => g_debug_msg,p_sev_level => g_excep_level);
    END IF;
    IF (c_det_pf_row_info%ISOPEN) THEN
       CLOSE c_det_pf_row_info;
    END IF;
    IF (c_cc_version_num%ISOPEN) THEN
       CLOSE c_cc_version_num;
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

END IGC_CC_DET_PF_PKG;

/
