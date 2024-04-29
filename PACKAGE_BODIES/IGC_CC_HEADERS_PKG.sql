--------------------------------------------------------
--  DDL for Package Body IGC_CC_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_HEADERS_PKG" as
/* $Header: IGCCHDRB.pls 120.7.12000000.4 2007/10/19 06:44:14 smannava ship $  */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_HEADERS_PKG';
  g_debug_flag        VARCHAR2(1) := 'N' ;
  g_debug_msg         VARCHAR2(10000) := NULL;

--  g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--Variables for ATG Central logging
  g_debug_level       NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level       NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level        NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level       NUMBER	:=	FND_LOG.LEVEL_EVENT;
  g_excep_level       NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level       NUMBER	:=	FND_LOG.LEVEL_ERROR;
  g_unexp_level       NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
  g_path              VARCHAR2(255) := 'IGC.PLSQL.IGCCHDRB.IGC_CC_HEADERS_PKG.';

-- Generic Procedure for putting out debug information

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
/*   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(8)           := 'CC_HDRB';
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
       RETURN;

END Output_Debug;

/* ================================================================================
           PROCEDURE Insert_Row Overloaded Procedure for CC_REF_NUM addition
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
   p_CC_Header_Id                    IGC_CC_HEADERS_ALL.CC_Header_Id%TYPE,
   p_Org_id                          IGC_CC_HEADERS_ALL.Org_id%TYPE,
   p_CC_Type                         IGC_CC_HEADERS_ALL.CC_Type%TYPE,
   p_CC_Num                          IGC_CC_HEADERS_ALL.CC_Num%TYPE,
   p_CC_Ref_Num                      IGC_CC_HEADERS_ALL.CC_Ref_Num%TYPE,
   p_CC_Version_num                  IGC_CC_HEADERS_ALL.CC_Version_num%TYPE,
   p_Parent_Header_Id                IGC_CC_HEADERS_ALL.Parent_Header_Id%TYPE,
   p_CC_State                        IGC_CC_HEADERS_ALL.CC_State%TYPE,
   p_CC_ctrl_status                  IGC_CC_HEADERS_ALL.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status              IGC_CC_HEADERS_ALL.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status                IGC_CC_HEADERS_ALL.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                       IGC_CC_HEADERS_ALL.Vendor_Id%TYPE,
   p_Vendor_Site_Id                  IGC_CC_HEADERS_ALL.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id               IGC_CC_HEADERS_ALL.Vendor_Contact_Id%TYPE,
   p_Term_Id                         IGC_CC_HEADERS_ALL.Term_Id%TYPE,
   p_Location_Id                     IGC_CC_HEADERS_ALL.Location_Id%TYPE,
   p_Set_Of_Books_Id                 IGC_CC_HEADERS_ALL.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                    IGC_CC_HEADERS_ALL.CC_Acct_Date%TYPE,
   p_CC_Desc                         IGC_CC_HEADERS_ALL.CC_Desc%TYPE,
   p_CC_Start_Date                   IGC_CC_HEADERS_ALL.CC_Start_Date%TYPE,
   p_CC_End_Date                     IGC_CC_HEADERS_ALL.CC_End_Date%TYPE,
   p_CC_Owner_User_Id                IGC_CC_HEADERS_ALL.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id             IGC_CC_HEADERS_ALL.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                   IGC_CC_HEADERS_ALL.Currency_Code%TYPE,
   p_Conversion_Type                 IGC_CC_HEADERS_ALL.Conversion_Type%TYPE,
   p_Conversion_Date                 IGC_CC_HEADERS_ALL.Conversion_Date%TYPE,
   p_Conversion_Rate                 IGC_CC_HEADERS_ALL.Conversion_Rate%TYPE,
   p_Last_Update_Date                IGC_CC_HEADERS_ALL.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_HEADERS_ALL.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_HEADERS_ALL.Last_Update_Login%TYPE,
   p_Created_By                      IGC_CC_HEADERS_ALL.Created_By%TYPE,
   p_Creation_Date                   IGC_CC_HEADERS_ALL.Creation_Date%TYPE,
   p_CC_Current_User_Id              IGC_CC_HEADERS_ALL.CC_Current_User_Id%TYPE,
   p_Wf_Item_Type                    IGC_CC_HEADERS_ALL.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                     IGC_CC_HEADERS_ALL.Wf_Item_Key%TYPE,
   p_Attribute1                      IGC_CC_HEADERS_ALL.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_HEADERS_ALL.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_HEADERS_ALL.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_HEADERS_ALL.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_HEADERS_ALL.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_HEADERS_ALL.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_HEADERS_ALL.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_HEADERS_ALL.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_HEADERS_ALL.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_HEADERS_ALL.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_HEADERS_ALL.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_HEADERS_ALL.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_HEADERS_ALL.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_HEADERS_ALL.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_HEADERS_ALL.Attribute15%TYPE,
   p_Context                         IGC_CC_HEADERS_ALL.Context%TYPE,
   p_CC_Guarantee_Flag               IGC_CC_HEADERS_ALL.CC_Guarantee_Flag%TYPE,
   G_FLAG                    IN OUT NOCOPY  VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_action_flag         VARCHAR2(1) := 'I';
   l_return_status       VARCHAR2(1);
--   l_debug               VARCHAR2(1);

   CURSOR c_cc_header_row_id IS
     SELECT Rowid
       FROM IGC_CC_HEADERS_ALL
      WHERE CC_Header_id = p_CC_Header_id;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

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


   IF FND_API.to_Boolean (p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
   END IF;

   X_return_status := FND_API.G_RET_STS_SUCCESS ;
--   l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--   IF (l_debug = 'Y') THEN
--      l_debug := FND_API.G_TRUE;
--   ELSE
--      l_debug := FND_API.G_FALSE;
--  END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Begin Insert Header ID Overload .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Insert the CC Header record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_HEADERS_ALL
             (CC_Header_Id,
              Parent_Header_Id,
              Org_Id,
              CC_Type,
              CC_Num,
              CC_Ref_Num,
              CC_Version_Num,
              CC_State,
              CC_Ctrl_Status,
              CC_Encmbrnc_Status,
              CC_Apprvl_Status,
              Vendor_Id,
              Vendor_Site_Id,
              Vendor_Contact_Id,
              Term_Id,
              Location_Id,
              Set_Of_Books_Id,
              CC_Acct_Date,
              CC_Desc,
              CC_Start_Date,
              CC_End_Date,
              CC_Owner_User_Id,
              CC_Preparer_User_Id,
              Currency_Code,
              Conversion_Type,
              Conversion_Date,
              Conversion_Rate,
              Last_Update_Date,
              Last_Updated_By,
              Last_Update_Login,
              Created_By,
              Creation_Date,
              Wf_Item_Type,
              Wf_Item_Key,
              CC_Current_User_Id,
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
              CC_Guarantee_Flag
             )
       VALUES
             (p_CC_Header_Id,
              p_Parent_Header_Id,
              p_Org_id,
              p_CC_Type,
              p_CC_Num,
              p_CC_Ref_Num,
              p_CC_Version_num,
              p_CC_State,
              p_CC_ctrl_status,
              p_CC_Encmbrnc_Status,
              p_CC_Apprvl_Status,
              p_Vendor_Id,
              p_Vendor_Site_Id,
              p_Vendor_Contact_Id,
              p_Term_Id,
              p_Location_Id,
              p_Set_Of_Books_Id,
              p_CC_Acct_Date,
              p_CC_Desc,
              p_CC_Start_Date,
              p_CC_End_Date,
              p_CC_Owner_User_Id,
              p_CC_Preparer_User_Id,
              p_Currency_Code,
              p_Conversion_Type,
              p_Conversion_Date,
              p_Conversion_Rate,
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_Last_Update_Login,
              p_Created_By,
              p_Creation_Date,
              p_Wf_Item_Type,
              p_Wf_Item_Key,
              p_CC_Current_User_Id,
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
              p_CC_Guarantee_Flag
             );

-- -------------------------------------------------------------------
-- Obtain the ROWID of the record that was just inserted to return
-- to the caller.
-- -------------------------------------------------------------------
   OPEN c_cc_header_row_id;
   FETCH c_cc_header_row_id
    INTO p_Rowid;

-- -------------------------------------------------------------------
-- If no ROWID can be obtained then exit the procedure with a failure
-- -------------------------------------------------------------------
   IF (c_cc_header_row_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Failure getting rowid for Header ID Overload.....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE c_cc_header_row_id;

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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- failure getting appl id for Header ID Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (p_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/
                           p_Org_Id,
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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- MRC enabled for Header ID Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_HEADERS to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_Headers (l_api_version,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            p_validation_level,
                                            l_return_status,
                                            X_msg_count,
                                            X_msg_data,
                                            p_CC_Header_Id,
                                            p_Set_Of_Books_Id,
                                            101, /*--l_Application_Id, commented for MRC uptake*/                                            p_org_Id,
                                            SYSDATE,
                                            l_action_flag
                                           );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          IF (IGC_MSGS_PKG.g_debug_mode) THEN
          IF g_debug_mode = 'Y' THEN
             g_debug_msg := ' IGCCHDRB -- Failure returned from MRC call ID Overload .....' || p_cc_header_id;
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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Committing Insert Header ID Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Done Insert Header ID Overload .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Execution on Header ID Overload .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Unexpected on Header ID Overload .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Others on Header ID Overload .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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

  END Insert_Row;

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
   p_CC_Header_Id                    IGC_CC_HEADERS_ALL.CC_Header_Id%TYPE,
   p_Org_id                          IGC_CC_HEADERS_ALL.Org_id%TYPE,
   p_CC_Type                         IGC_CC_HEADERS_ALL.CC_Type%TYPE,
   p_CC_Num                          IGC_CC_HEADERS_ALL.CC_Num%TYPE,
   p_CC_Version_num                  IGC_CC_HEADERS_ALL.CC_Version_num%TYPE,
   p_Parent_Header_Id                IGC_CC_HEADERS_ALL.Parent_Header_Id%TYPE,
   p_CC_State                        IGC_CC_HEADERS_ALL.CC_State%TYPE,
   p_CC_ctrl_status                  IGC_CC_HEADERS_ALL.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status              IGC_CC_HEADERS_ALL.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status                IGC_CC_HEADERS_ALL.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                       IGC_CC_HEADERS_ALL.Vendor_Id%TYPE,
   p_Vendor_Site_Id                  IGC_CC_HEADERS_ALL.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id               IGC_CC_HEADERS_ALL.Vendor_Contact_Id%TYPE,
   p_Term_Id                         IGC_CC_HEADERS_ALL.Term_Id%TYPE,
   p_Location_Id                     IGC_CC_HEADERS_ALL.Location_Id%TYPE,
   p_Set_Of_Books_Id                 IGC_CC_HEADERS_ALL.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                    IGC_CC_HEADERS_ALL.CC_Acct_Date%TYPE,
   p_CC_Desc                         IGC_CC_HEADERS_ALL.CC_Desc%TYPE,
   p_CC_Start_Date                   IGC_CC_HEADERS_ALL.CC_Start_Date%TYPE,
   p_CC_End_Date                     IGC_CC_HEADERS_ALL.CC_End_Date%TYPE,
   p_CC_Owner_User_Id                IGC_CC_HEADERS_ALL.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id             IGC_CC_HEADERS_ALL.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                   IGC_CC_HEADERS_ALL.Currency_Code%TYPE,
   p_Conversion_Type                 IGC_CC_HEADERS_ALL.Conversion_Type%TYPE,
   p_Conversion_Date                 IGC_CC_HEADERS_ALL.Conversion_Date%TYPE,
   p_Conversion_Rate                 IGC_CC_HEADERS_ALL.Conversion_Rate%TYPE,
   p_Last_Update_Date                IGC_CC_HEADERS_ALL.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_HEADERS_ALL.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_HEADERS_ALL.Last_Update_Login%TYPE,
   p_Created_By                      IGC_CC_HEADERS_ALL.Created_By%TYPE,
   p_Creation_Date                   IGC_CC_HEADERS_ALL.Creation_Date%TYPE,
   p_CC_Current_User_Id              IGC_CC_HEADERS_ALL.CC_Current_User_Id%TYPE,
   p_Wf_Item_Type                    IGC_CC_HEADERS_ALL.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                     IGC_CC_HEADERS_ALL.Wf_Item_Key%TYPE,
   p_Attribute1                      IGC_CC_HEADERS_ALL.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_HEADERS_ALL.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_HEADERS_ALL.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_HEADERS_ALL.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_HEADERS_ALL.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_HEADERS_ALL.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_HEADERS_ALL.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_HEADERS_ALL.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_HEADERS_ALL.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_HEADERS_ALL.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_HEADERS_ALL.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_HEADERS_ALL.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_HEADERS_ALL.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_HEADERS_ALL.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_HEADERS_ALL.Attribute15%TYPE,
   p_Context                         IGC_CC_HEADERS_ALL.Context%TYPE,
   p_CC_Guarantee_Flag               IGC_CC_HEADERS_ALL.CC_Guarantee_Flag%TYPE,
   G_FLAG                    IN OUT NOCOPY  VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_action_flag         VARCHAR2(1) := 'I';
   l_return_status       VARCHAR2(1);
--   l_debug               VARCHAR2(1);

   CURSOR c_cc_header_row_id IS
     SELECT Rowid
       FROM IGC_CC_HEADERS_ALL
      WHERE CC_Header_id = p_CC_Header_id;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

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


   IF FND_API.to_Boolean (p_init_msg_list ) THEN
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
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Begin Insert Header ID .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Insert the CC Header record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_HEADERS_ALL
             (CC_Header_Id,
              Parent_Header_Id,
              Org_Id,
              CC_Type,
              CC_Num,
              CC_Version_Num,
              CC_State,
              CC_Ctrl_Status,
              CC_Encmbrnc_Status,
              CC_Apprvl_Status,
              Vendor_Id,
              Vendor_Site_Id,
              Vendor_Contact_Id,
              Term_Id,
              Location_Id,
              Set_Of_Books_Id,
              CC_Acct_Date,
              CC_Desc,
              CC_Start_Date,
              CC_End_Date,
              CC_Owner_User_Id,
              CC_Preparer_User_Id,
              Currency_Code,
              Conversion_Type,
              Conversion_Date,
              Conversion_Rate,
              Last_Update_Date,
              Last_Updated_By,
              Last_Update_Login,
              Created_By,
              Creation_Date,
              Wf_Item_Type,
              Wf_Item_Key,
              CC_Current_User_Id,
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
              CC_Guarantee_Flag
             )
       VALUES
             (p_CC_Header_Id,
              p_Parent_Header_Id,
              p_Org_id,
              p_CC_Type,
              p_CC_Num,
              p_CC_Version_num,
              p_CC_State,
              p_CC_ctrl_status,
              p_CC_Encmbrnc_Status,
              p_CC_Apprvl_Status,
              p_Vendor_Id,
              p_Vendor_Site_Id,
              p_Vendor_Contact_Id,
              p_Term_Id,
              p_Location_Id,
              p_Set_Of_Books_Id,
              p_CC_Acct_Date,
              p_CC_Desc,
              p_CC_Start_Date,
              p_CC_End_Date,
              p_CC_Owner_User_Id,
              p_CC_Preparer_User_Id,
              p_Currency_Code,
              p_Conversion_Type,
              p_Conversion_Date,
              p_Conversion_Rate,
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_Last_Update_Login,
              p_Created_By,
              p_Creation_Date,
              p_Wf_Item_Type,
              p_Wf_Item_Key,
              p_CC_Current_User_Id,
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
              p_CC_Guarantee_Flag
             );

-- -------------------------------------------------------------------
-- Obtain the ROWID of the record that was just inserted to return
-- to the caller.
-- -------------------------------------------------------------------
   OPEN c_cc_header_row_id;
   FETCH c_cc_header_row_id
    INTO p_Rowid;

-- -------------------------------------------------------------------
-- If no ROWID can be obtained then exit the procedure with a failure
-- -------------------------------------------------------------------
   IF (c_cc_header_row_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Failure getting rowid for Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE c_cc_header_row_id;

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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- failure getting appl id for Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (p_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/
                           p_Org_Id,
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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- MRC enabled for Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_HEADERS to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_Headers (l_api_version,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            p_validation_level,
                                            l_return_status,
                                            X_msg_count,
                                            X_msg_data,
                                            p_CC_Header_Id,
                                            p_Set_Of_Books_Id,
                                            101, /*--l_Application_Id, commented for MRC uptake*/                                            p_org_Id,
                                            SYSDATE,
                                            l_action_flag
                                           );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--          IF (IGC_MSGS_PKG.g_debug_mode) THEN
          IF g_debug_mode = 'Y' THEN
             g_debug_msg := ' IGCCHDRB -- Failure returned from MRC call ID .....' || p_cc_header_id;
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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Committing Insert Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Done Insert Header ID .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Execution on Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;
    FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                p_data  => X_msg_data );
    IF (g_excep_level >=  g_debug_level ) THEN
        FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Unexpected on Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Others on Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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

  END Insert_Row;

/* ================================================================================
                         PROCEDURE Lock_Row
   ===============================================================================*/

PROCEDURE Lock_Row(
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status           OUT NOCOPY VARCHAR2,
   X_msg_count               OUT NOCOPY NUMBER,
   X_msg_data                OUT NOCOPY VARCHAR2,
   p_Rowid                IN OUT NOCOPY VARCHAR2,
   p_CC_Header_Id                IGC_CC_HEADERS_ALL.CC_Header_Id%TYPE,
   p_Org_id                      IGC_CC_HEADERS_ALL.Org_id%TYPE,
   p_CC_Type                     IGC_CC_HEADERS_ALL.CC_Type%TYPE,
   p_CC_Num                      IGC_CC_HEADERS_ALL.CC_Num%TYPE,
   p_CC_Version_num              IGC_CC_HEADERS_ALL.CC_Version_num%TYPE,
   p_Parent_Header_Id            IGC_CC_HEADERS_ALL.Parent_Header_Id%TYPE,
   p_CC_State                    IGC_CC_HEADERS_ALL.CC_State%TYPE,
   p_CC_ctrl_status              IGC_CC_HEADERS_ALL.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status          IGC_CC_HEADERS_ALL.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status            IGC_CC_HEADERS_ALL.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                   IGC_CC_HEADERS_ALL.Vendor_Id%TYPE,
   p_Vendor_Site_Id              IGC_CC_HEADERS_ALL.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id           IGC_CC_HEADERS_ALL.Vendor_Contact_Id%TYPE,
   p_Term_Id                     IGC_CC_HEADERS_ALL.Term_Id%TYPE,
   p_Location_Id                 IGC_CC_HEADERS_ALL.Location_Id%TYPE,
   p_Set_Of_Books_Id             IGC_CC_HEADERS_ALL.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                IGC_CC_HEADERS_ALL.CC_Acct_Date%TYPE,
   p_CC_Desc                     IGC_CC_HEADERS_ALL.CC_Desc%TYPE,
   p_CC_Start_Date               IGC_CC_HEADERS_ALL.CC_Start_Date%TYPE,
   p_CC_End_Date                 IGC_CC_HEADERS_ALL.CC_End_Date%TYPE,
   p_CC_Owner_User_Id            IGC_CC_HEADERS_ALL.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id         IGC_CC_HEADERS_ALL.CC_Preparer_User_Id%TYPE,
   p_Currency_Code               IGC_CC_HEADERS_ALL.Currency_Code%TYPE,
   p_Conversion_Type             IGC_CC_HEADERS_ALL.Conversion_Type%TYPE,
   p_Conversion_Date             IGC_CC_HEADERS_ALL.Conversion_Date%TYPE,
   p_Conversion_Rate             IGC_CC_HEADERS_ALL.Conversion_Rate%TYPE,
   p_Last_Update_Date            IGC_CC_HEADERS_ALL.Last_Update_Date%TYPE,
   p_Last_Updated_By             IGC_CC_HEADERS_ALL.Last_Updated_By%TYPE,
   p_Last_Update_Login           IGC_CC_HEADERS_ALL.Last_Update_Login%TYPE,
   p_Created_By                  IGC_CC_HEADERS_ALL.Created_By%TYPE,
   p_Creation_Date               IGC_CC_HEADERS_ALL.Creation_Date%TYPE,
   p_CC_Current_User_Id          IGC_CC_HEADERS_ALL.CC_Current_User_Id%TYPE,
   p_Wf_Item_Type                IGC_CC_HEADERS_ALL.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                 IGC_CC_HEADERS_ALL.Wf_Item_Key%TYPE,
   p_Attribute1                  IGC_CC_HEADERS_ALL.Attribute1%TYPE,
   p_Attribute2                  IGC_CC_HEADERS_ALL.Attribute2%TYPE,
   p_Attribute3                  IGC_CC_HEADERS_ALL.Attribute3%TYPE,
   p_Attribute4                  IGC_CC_HEADERS_ALL.Attribute4%TYPE,
   p_Attribute5                  IGC_CC_HEADERS_ALL.Attribute5%TYPE,
   p_Attribute6                  IGC_CC_HEADERS_ALL.Attribute6%TYPE,
   p_Attribute7                  IGC_CC_HEADERS_ALL.Attribute7%TYPE,
   p_Attribute8                  IGC_CC_HEADERS_ALL.Attribute8%TYPE,
   p_Attribute9                  IGC_CC_HEADERS_ALL.Attribute9%TYPE,
   p_Attribute10                 IGC_CC_HEADERS_ALL.Attribute10%TYPE,
   p_Attribute11                 IGC_CC_HEADERS_ALL.Attribute11%TYPE,
   p_Attribute12                 IGC_CC_HEADERS_ALL.Attribute12%TYPE,
   p_Attribute13                 IGC_CC_HEADERS_ALL.Attribute13%TYPE,
   p_Attribute14                 IGC_CC_HEADERS_ALL.Attribute14%TYPE,
   p_Attribute15                 IGC_CC_HEADERS_ALL.Attribute15%TYPE,
   p_Context                     IGC_CC_HEADERS_ALL.Context%TYPE,
   p_CC_Guarantee_Flag           IGC_CC_HEADERS_ALL.CC_Guarantee_Flag%TYPE,
   X_row_locked              OUT NOCOPY VARCHAR2,
   G_FLAG                 IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   Counter               NUMBER;
--   l_debug               VARCHAR2(1);

   CURSOR C IS
     SELECT *
       FROM IGC_CC_HEADERS_ALL
      WHERE rowid = p_Rowid
        FOR UPDATE of CC_Header_Id NOWAIT;

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
--    l_debug         := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');

--    IF (l_debug = 'Y') THEN
--       l_debug := FND_API.G_TRUE;
--    ELSE
--       l_debug := FND_API.G_FALSE;
--    END IF;
--    IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Begin Lock Row Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;

    OPEN C;
    FETCH C
     INTO Recinfo;

    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.Add;
      IF (g_excep_level  >=  g_debug_level ) THEN
          FND_LOG.MESSAGE (g_excep_level ,l_full_path,FALSE);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE C;

    IF (
               (Recinfo.CC_Header_Id =  p_CC_Header_Id)
           AND (Recinfo.Org_Id =  p_Org_Id)
           AND (Recinfo.CC_Type =  p_CC_Type)
           AND (Recinfo.CC_Num =  p_CC_Num)
           AND (Recinfo.CC_Version_Num =  p_CC_Version_Num)
          -- AND (Recinfo.CC_state =  p_CC_State)
           --AND (Recinfo.CC_Ctrl_Status =  p_CC_Ctrl_Status)
           --AND (Recinfo.CC_Apprvl_Status =  p_CC_Apprvl_Status)
           AND (Recinfo.Set_Of_Books_Id =  p_Set_Of_Books_Id)
           AND (Recinfo.CC_Owner_User_Id =  p_CC_Owner_User_Id)
           AND (Recinfo.CC_Preparer_User_Id =  p_CC_Preparer_User_Id)
           AND (   (Recinfo.Parent_Header_Id =  p_Parent_Header_Id)
                OR (    (Recinfo.Parent_Header_Id IS NULL)
                    AND (p_Parent_Header_Id IS NULL)))
         --  AND (   (Recinfo.CC_Encmbrnc_Status =  p_CC_Encmbrnc_Status)
          --      OR (    (Recinfo.CC_Encmbrnc_Status IS NULL)
           --         AND (p_CC_Encmbrnc_Status IS NULL)))
           AND (   (Recinfo.Vendor_Id =  p_Vendor_Id)
                OR (    (Recinfo.Vendor_Id IS NULL)
                    AND (p_Vendor_Id IS NULL)))
           AND (   (Recinfo.Vendor_Site_Id =  p_Vendor_Site_Id)
                OR (    (Recinfo.Vendor_Site_Id IS NULL)
                    AND (p_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.Vendor_Contact_Id =  p_Vendor_Contact_Id)
                OR (    (Recinfo.Vendor_Contact_Id IS NULL)
                    AND (p_Vendor_Contact_Id IS NULL)))
           AND (   (Recinfo.Term_Id =  p_Term_Id)
                OR (    (Recinfo.Term_Id IS NULL)
                    AND (p_Term_Id IS NULL)))
           AND (   (Recinfo.Location_Id =  p_Location_Id)
                OR (    (Recinfo.Location_Id IS NULL)
                    AND (p_Location_Id IS NULL)))
           AND (   (Recinfo.CC_Acct_Date =  p_CC_Acct_Date)
                OR (    (Recinfo.CC_Acct_Date IS NULL)
                    AND (p_CC_Acct_Date IS NULL)))
           AND (   (Recinfo.CC_Desc =  p_CC_Desc)
                OR (    (Recinfo.CC_Desc IS NULL)
                    AND (p_CC_Desc IS NULL)))
           AND (   (Recinfo.CC_Start_Date =  p_CC_Start_Date)
                OR (    (Recinfo.CC_Start_Date IS NULL)
                    AND (p_CC_Start_Date IS NULL)))
           AND (   (Recinfo.CC_End_Date =  p_CC_End_Date)
                OR (    (Recinfo.CC_End_Date IS NULL)
                    AND (p_CC_End_Date IS NULL)))
           AND (   (Recinfo.Currency_Code =  p_Currency_Code)
                OR (    (Recinfo.Currency_Code IS NULL)
                    AND (p_Currency_Code IS NULL)))
           AND (   (Recinfo.Conversion_Type =  p_Conversion_Type)
                OR (    (Recinfo.Conversion_Type IS NULL)
                    AND (p_Conversion_Type IS NULL)))
           AND (   (Recinfo.Conversion_Date =  p_Conversion_Date)
                OR (    (Recinfo.Conversion_Date IS NULL)
                    AND (p_Conversion_Date IS NULL)))
           AND (   (Recinfo.Conversion_Rate =  p_Conversion_Rate)
                OR (    (Recinfo.Conversion_Rate IS NULL)
                    AND (p_Conversion_Rate IS NULL)))
--           AND (   (Recinfo.WF_Item_Type =  p_WF_Item_Type)
--                OR (    (Recinfo.WF_Item_Type IS NULL)
--                    AND (p_WF_Item_Type IS NULL)))
--           AND (   (Recinfo.WF_Item_Key =  p_WF_Item_Key)
--                OR (    (Recinfo.WF_Item_Key IS NULL)
--                    AND (p_WF_Item_Key IS NULL)))
--           AND (   (Recinfo.CC_Current_User_Id =  p_CC_Current_User_Id)
--                OR (    (Recinfo.CC_Current_User_Id IS NULL)
--                    AND (p_CC_Current_User_Id IS NULL)))
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
           AND (   (Recinfo.CC_Guarantee_Flag = p_CC_Guarantee_Flag)
               OR  (    (Recinfo.CC_Guarantee_Flag IS NULL)
                    AND (p_CC_Guarantee_Flag IS NULL)))
      ) THEN

--       IF (IGC_MSGS_PKG.g_debug_mode) THEN
       IF g_debug_mode = 'Y' THEN
          g_debug_msg := ' IGCCHDRB -- Locked Row Header ID .....' || p_cc_header_id;
          Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
       END IF;

       NULL;

   ELSE

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Failed Lock Row Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      IF (g_excep_level >=  g_debug_level ) THEN
          FND_LOG.MESSAGE (g_excep_level , l_full_path,FALSE);
      END IF;
      RAISE FND_API.G_EXC_ERROR ;

   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
--     IF (IGC_MSGS_PKG.g_debug_mode) THEN
     IF g_debug_mode = 'Y' THEN
        g_debug_msg := ' IGCCHDRB -- Committing Lock Row Header ID .....' || p_cc_header_id;
        Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
     END IF;

      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- End Lock Row Header ID .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_row_locked := FND_API.G_FALSE;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Record Lock Exc Header ID .....' || p_cc_header_id;
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Execute Lock Header ID .....' || p_cc_header_id;
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Unexpected Lock Header ID .....' || p_cc_header_id;
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Others Lock Header ID .....' || p_cc_header_id;
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
         PROCEDURE Update_Row Overloaded Procedure for CC_REF_NUM addition
   ===============================================================================*/

PROCEDURE Update_Row(
   p_api_version            IN     NUMBER,
   p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status          OUT NOCOPY    VARCHAR2,
   X_msg_count              OUT NOCOPY    NUMBER,
   X_msg_data               OUT NOCOPY    VARCHAR2,
   p_Rowid               IN OUT NOCOPY    VARCHAR2,
   p_CC_Header_Id                  IGC_CC_HEADERS_ALL.CC_Header_Id%TYPE,
   p_Org_id                        IGC_CC_HEADERS_ALL.Org_id%TYPE,
   p_CC_Type                       IGC_CC_HEADERS_ALL.CC_Type%TYPE,
   p_CC_Num                        IGC_CC_HEADERS_ALL.CC_Num%TYPE,
   p_CC_Ref_Num                    IGC_CC_HEADERS_ALL.CC_Ref_Num%TYPE,
   p_CC_Version_num                IGC_CC_HEADERS_ALL.CC_Version_num%TYPE,
   p_Parent_Header_Id              IGC_CC_HEADERS_ALL.Parent_Header_Id%TYPE,
   p_CC_State                      IGC_CC_HEADERS_ALL.CC_State%TYPE,
   p_CC_ctrl_status                IGC_CC_HEADERS_ALL.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status            IGC_CC_HEADERS_ALL.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status              IGC_CC_HEADERS_ALL.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                     IGC_CC_HEADERS_ALL.Vendor_Id%TYPE,
   p_Vendor_Site_Id                IGC_CC_HEADERS_ALL.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id             IGC_CC_HEADERS_ALL.Vendor_Contact_Id%TYPE,
   p_Term_Id                       IGC_CC_HEADERS_ALL.Term_Id%TYPE,
   p_Location_Id                   IGC_CC_HEADERS_ALL.Location_Id%TYPE,
   p_Set_Of_Books_Id               IGC_CC_HEADERS_ALL.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                  IGC_CC_HEADERS_ALL.CC_Acct_Date%TYPE,
   p_CC_Desc                       IGC_CC_HEADERS_ALL.CC_Desc%TYPE,
   p_CC_Start_Date                 IGC_CC_HEADERS_ALL.CC_Start_Date%TYPE,
   p_CC_End_Date                   IGC_CC_HEADERS_ALL.CC_End_Date%TYPE,
   p_CC_Owner_User_Id              IGC_CC_HEADERS_ALL.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id           IGC_CC_HEADERS_ALL.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                 IGC_CC_HEADERS_ALL.Currency_Code%TYPE,
   p_Conversion_Type               IGC_CC_HEADERS_ALL.Conversion_Type%TYPE,
   p_Conversion_Date               IGC_CC_HEADERS_ALL.Conversion_Date%TYPE,
   p_Conversion_Rate               IGC_CC_HEADERS_ALL.Conversion_Rate%TYPE,
   p_Last_Update_Date              IGC_CC_HEADERS_ALL.Last_Update_Date%TYPE,
   p_Last_Updated_By               IGC_CC_HEADERS_ALL.Last_Updated_By%TYPE,
   p_Last_Update_Login             IGC_CC_HEADERS_ALL.Last_Update_Login%TYPE,
   p_Created_By                    IGC_CC_HEADERS_ALL.Created_By%TYPE,
   p_Creation_Date                 IGC_CC_HEADERS_ALL.Creation_Date%TYPE,
   p_CC_Current_User_Id            IGC_CC_HEADERS_ALL.CC_Current_User_Id%TYPE,
   p_Wf_Item_Type                  IGC_CC_HEADERS_ALL.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                   IGC_CC_HEADERS_ALL.Wf_Item_Key%TYPE,
   p_Attribute1                    IGC_CC_HEADERS_ALL.Attribute1%TYPE,
   p_Attribute2                    IGC_CC_HEADERS_ALL.Attribute2%TYPE,
   p_Attribute3                    IGC_CC_HEADERS_ALL.Attribute3%TYPE,
   p_Attribute4                    IGC_CC_HEADERS_ALL.Attribute4%TYPE,
   p_Attribute5                    IGC_CC_HEADERS_ALL.Attribute5%TYPE,
   p_Attribute6                    IGC_CC_HEADERS_ALL.Attribute6%TYPE,
   p_Attribute7                    IGC_CC_HEADERS_ALL.Attribute7%TYPE,
   p_Attribute8                    IGC_CC_HEADERS_ALL.Attribute8%TYPE,
   p_Attribute9                    IGC_CC_HEADERS_ALL.Attribute9%TYPE,
   p_Attribute10                   IGC_CC_HEADERS_ALL.Attribute10%TYPE,
   p_Attribute11                   IGC_CC_HEADERS_ALL.Attribute11%TYPE,
   p_Attribute12                   IGC_CC_HEADERS_ALL.Attribute12%TYPE,
   p_Attribute13                   IGC_CC_HEADERS_ALL.Attribute13%TYPE,
   p_Attribute14                   IGC_CC_HEADERS_ALL.Attribute14%TYPE,
   p_Attribute15                   IGC_CC_HEADERS_ALL.Attribute15%TYPe,
   p_Context                       IGC_CC_HEADERS_ALL.Context%TYPE,
   p_CC_Guarantee_Flag             IGC_CC_HEADERS_ALL.CC_Guarantee_Flag%TYPE,
   G_FLAG                   IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_action_flag         VARCHAR2(1) := 'U';
   l_return_status       VARCHAR2(1);
--   l_debug               VARCHAR2(1);

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

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
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Begin Update Row Header ID Overload .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------------
-- Update the CC Header Record
-- --------------------------------------------------------------------------
   UPDATE IGC_CC_HEADERS_ALL
      SET CC_Header_Id        = p_CC_Header_Id,
          Parent_Header_Id    = p_Parent_Header_Id,
          Org_Id              = p_Org_id,
          CC_Type             = p_CC_Type,
          CC_Num              = p_CC_Num,
          CC_Ref_Num          = p_CC_Ref_Num,
          CC_Version_Num      = p_CC_Version_num,
          CC_State            = p_CC_State,
          CC_ctrl_status      = p_CC_ctrl_status ,
          CC_Encmbrnc_Status  = p_CC_Encmbrnc_Status,
          CC_Apprvl_Status    = p_CC_Apprvl_Status,
          Vendor_Id           = p_Vendor_Id,
          Vendor_Site_Id      = p_Vendor_Site_Id,
          Vendor_Contact_Id   = p_Vendor_Contact_Id,
          Term_Id             = p_Term_Id,
          Location_Id         = p_Location_Id,
          Set_Of_Books_Id     = p_Set_Of_Books_Id,
          CC_Acct_Date        = p_CC_Acct_Date,
          CC_Desc             = p_CC_Desc,
          CC_Start_Date       = p_CC_Start_Date,
          CC_End_Date         = p_CC_End_Date,
          CC_Owner_User_Id    = p_CC_Owner_User_Id,
          CC_Preparer_User_Id = p_CC_Preparer_User_Id,
          Currency_Code       = p_Currency_Code,
          Conversion_Type     = p_Conversion_Type,
          Conversion_Date     = p_Conversion_Date,
          Conversion_Rate     = p_Conversion_Rate,
          Last_Update_Date    = p_Last_Update_Date,
          Last_Updated_By     = p_Last_Updated_By,
          Last_Update_Login   = p_Last_Update_Login,
          Created_By          = p_Created_By,
          Creation_Date       = p_Creation_Date,
          Wf_Item_Type        = p_Wf_Item_Type,
          Wf_Item_Key         = p_Wf_Item_Key,
          CC_Current_User_Id  = p_CC_Current_User_Id,
          Attribute1          = p_Attribute1,
          Attribute2          = p_Attribute2,
          Attribute3          = p_Attribute3,
          Attribute4          = p_Attribute4,
          Attribute5          = p_Attribute5,
          Attribute6          = p_Attribute6,
          Attribute7          = p_Attribute7,
          Attribute8          = p_Attribute8,
          Attribute9          = p_Attribute9,
          Attribute10         = p_Attribute10,
          Attribute11         = p_Attribute11,
          Attribute12         = p_Attribute12,
          Attribute13         = p_Attribute13,
          Attribute14         = p_Attribute14,
          Attribute15         = p_Attribute15,
          Context             = p_Context,
          CC_Guarantee_Flag   = p_CC_Guarantee_Flag
    WHERE rowid = p_Rowid;

    IF (SQL%NOTFOUND) THEN
--       IF (IGC_MSGS_PKG.g_debug_mode) THEN
       IF g_debug_mode = 'Y' THEN
          g_debug_msg := ' IGCCHDRB -- Failure Update Row Header ID Overload .....' || p_cc_header_id;
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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Failure getting appl ID for Upd Header Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (p_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/
                           p_Org_Id,
                           NULL,
                           l_MRC_Enabled
                          );

-- ------------------------------------------------------------------
-- If MRC has been enabled for this set of books then make sure that
-- the records are updated accordingly.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- MRC enabled for Update Row Header ID Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_CC_HEADERS to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_Headers (l_api_version,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            p_validation_level,
                                            l_return_status,
                                            X_msg_count,
                                            X_msg_data,
                                            p_CC_Header_Id,
                                            p_Set_Of_Books_Id,
                                            101, /*--l_Application_Id, commented for MRC uptake*/                                            p_org_Id,
                                            SYSDATE,
                                            l_action_flag
                                           );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            g_debug_msg := ' IGCCHDRB -- Failure Update MRC return Header ID Overload .....' || p_cc_header_id;
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- MRC Updated Header ID Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Committing Update Row Header ID Overload .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- End Update Row Header ID Overload .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Execute Update Header ID Overload .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Unexpected Update Header ID Overload .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Others Update Header ID Overload .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
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
                         PROCEDURE Update_Row
   ===============================================================================*/

PROCEDURE Update_Row(
   p_api_version            IN     NUMBER,
   p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status          OUT NOCOPY    VARCHAR2,
   X_msg_count              OUT NOCOPY    NUMBER,
   X_msg_data               OUT NOCOPY    VARCHAR2,
   p_Rowid               IN OUT NOCOPY    VARCHAR2,
   p_CC_Header_Id                  IGC_CC_HEADERS_ALL.CC_Header_Id%TYPE,
   p_Org_id                        IGC_CC_HEADERS_ALL.Org_id%TYPE,
   p_CC_Type                       IGC_CC_HEADERS_ALL.CC_Type%TYPE,
   p_CC_Num                        IGC_CC_HEADERS_ALL.CC_Num%TYPE,
   p_CC_Version_num                IGC_CC_HEADERS_ALL.CC_Version_num%TYPE,
   p_Parent_Header_Id              IGC_CC_HEADERS_ALL.Parent_Header_Id%TYPE,
   p_CC_State                      IGC_CC_HEADERS_ALL.CC_State%TYPE,
   p_CC_ctrl_status                IGC_CC_HEADERS_ALL.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status            IGC_CC_HEADERS_ALL.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status              IGC_CC_HEADERS_ALL.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                     IGC_CC_HEADERS_ALL.Vendor_Id%TYPE,
   p_Vendor_Site_Id                IGC_CC_HEADERS_ALL.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id             IGC_CC_HEADERS_ALL.Vendor_Contact_Id%TYPE,
   p_Term_Id                       IGC_CC_HEADERS_ALL.Term_Id%TYPE,
   p_Location_Id                   IGC_CC_HEADERS_ALL.Location_Id%TYPE,
   p_Set_Of_Books_Id               IGC_CC_HEADERS_ALL.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                  IGC_CC_HEADERS_ALL.CC_Acct_Date%TYPE,
   p_CC_Desc                       IGC_CC_HEADERS_ALL.CC_Desc%TYPE,
   p_CC_Start_Date                 IGC_CC_HEADERS_ALL.CC_Start_Date%TYPE,
   p_CC_End_Date                   IGC_CC_HEADERS_ALL.CC_End_Date%TYPE,
   p_CC_Owner_User_Id              IGC_CC_HEADERS_ALL.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id           IGC_CC_HEADERS_ALL.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                 IGC_CC_HEADERS_ALL.Currency_Code%TYPE,
   p_Conversion_Type               IGC_CC_HEADERS_ALL.Conversion_Type%TYPE,
   p_Conversion_Date               IGC_CC_HEADERS_ALL.Conversion_Date%TYPE,
   p_Conversion_Rate               IGC_CC_HEADERS_ALL.Conversion_Rate%TYPE,
   p_Last_Update_Date              IGC_CC_HEADERS_ALL.Last_Update_Date%TYPE,
   p_Last_Updated_By               IGC_CC_HEADERS_ALL.Last_Updated_By%TYPE,
   p_Last_Update_Login             IGC_CC_HEADERS_ALL.Last_Update_Login%TYPE,
   p_Created_By                    IGC_CC_HEADERS_ALL.Created_By%TYPE,
   p_Creation_Date                 IGC_CC_HEADERS_ALL.Creation_Date%TYPE,
   p_CC_Current_User_Id            IGC_CC_HEADERS_ALL.CC_Current_User_Id%TYPE,
   p_Wf_Item_Type                  IGC_CC_HEADERS_ALL.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                   IGC_CC_HEADERS_ALL.Wf_Item_Key%TYPE,
   p_Attribute1                    IGC_CC_HEADERS_ALL.Attribute1%TYPE,
   p_Attribute2                    IGC_CC_HEADERS_ALL.Attribute2%TYPE,
   p_Attribute3                    IGC_CC_HEADERS_ALL.Attribute3%TYPE,
   p_Attribute4                    IGC_CC_HEADERS_ALL.Attribute4%TYPE,
   p_Attribute5                    IGC_CC_HEADERS_ALL.Attribute5%TYPE,
   p_Attribute6                    IGC_CC_HEADERS_ALL.Attribute6%TYPE,
   p_Attribute7                    IGC_CC_HEADERS_ALL.Attribute7%TYPE,
   p_Attribute8                    IGC_CC_HEADERS_ALL.Attribute8%TYPE,
   p_Attribute9                    IGC_CC_HEADERS_ALL.Attribute9%TYPE,
   p_Attribute10                   IGC_CC_HEADERS_ALL.Attribute10%TYPE,
   p_Attribute11                   IGC_CC_HEADERS_ALL.Attribute11%TYPE,
   p_Attribute12                   IGC_CC_HEADERS_ALL.Attribute12%TYPE,
   p_Attribute13                   IGC_CC_HEADERS_ALL.Attribute13%TYPE,
   p_Attribute14                   IGC_CC_HEADERS_ALL.Attribute14%TYPE,
   p_Attribute15                   IGC_CC_HEADERS_ALL.Attribute15%TYPe,
   p_Context                       IGC_CC_HEADERS_ALL.Context%TYPE,
   p_CC_Guarantee_Flag             IGC_CC_HEADERS_ALL.CC_Guarantee_Flag%TYPE,
   G_FLAG                   IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_action_flag         VARCHAR2(1) := 'U';
   l_return_status       VARCHAR2(1);
--   l_debug               VARCHAR2(1);

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM FND_APPLICATION
      WHERE Application_Short_Name =  'IGC';

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
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Begin Update Row Header ID .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------------
-- Update the CC Header Record
-- --------------------------------------------------------------------------
   UPDATE IGC_CC_HEADERS_ALL
      SET CC_Header_Id                 =      p_CC_Header_Id,
          Parent_Header_Id             =      p_Parent_Header_Id,
          Org_Id                       =      p_Org_id,
          CC_Type                      =      p_CC_Type,
          CC_Num                       =      p_CC_Num,
          CC_Version_Num               =      p_CC_Version_num,
          CC_State                     =      p_CC_State,
          CC_ctrl_status               =      p_CC_ctrl_status ,
          CC_Encmbrnc_Status           =      p_CC_Encmbrnc_Status,
          CC_Apprvl_Status             =      p_CC_Apprvl_Status,
          Vendor_Id                    =      p_Vendor_Id,
          Vendor_Site_Id               =      p_Vendor_Site_Id,
          Vendor_Contact_Id            =      p_Vendor_Contact_Id,
          Term_Id                      =      p_Term_Id,
          Location_Id                  =      p_Location_Id,
          Set_Of_Books_Id              =      p_Set_Of_Books_Id,
          CC_Acct_Date                 =      p_CC_Acct_Date,
          CC_Desc                      =      p_CC_Desc,
          CC_Start_Date                =      p_CC_Start_Date,
          CC_End_Date                  =      p_CC_End_Date,
          CC_Owner_User_Id             =      p_CC_Owner_User_Id,
          CC_Preparer_User_Id          =      p_CC_Preparer_User_Id,
          Currency_Code                =      p_Currency_Code,
          Conversion_Type              =      p_Conversion_Type,
          Conversion_Date              =      p_Conversion_Date,
          Conversion_Rate              =      p_Conversion_Rate,
          Last_Update_Date             =      p_Last_Update_Date,
          Last_Updated_By              =      p_Last_Updated_By,
          Last_Update_Login            =      p_Last_Update_Login,
          Created_By                   =      p_Created_By,
          Creation_Date                =      p_Creation_Date,
          Wf_Item_Type                 =      p_Wf_Item_Type,
          Wf_Item_Key                  =      p_Wf_Item_Key,
          CC_Current_User_Id           =      p_CC_Current_User_Id,
          Attribute1                   =      p_Attribute1,
          Attribute2                   =      p_Attribute2,
          Attribute3                   =      p_Attribute3,
          Attribute4                   =      p_Attribute4,
          Attribute5                   =      p_Attribute5,
          Attribute6                   =      p_Attribute6,
          Attribute7                   =      p_Attribute7,
          Attribute8                   =      p_Attribute8,
          Attribute9                   =      p_Attribute9,
          Attribute10                  =      p_Attribute10,
          Attribute11                  =      p_Attribute11,
          Attribute12                  =      p_Attribute12,
          Attribute13                  =      p_Attribute13,
          Attribute14                  =      p_Attribute14,
          Attribute15                  =      p_Attribute15,
          Context                      =      p_Context,
          CC_Guarantee_Flag            =      p_CC_Guarantee_Flag
    WHERE rowid = p_Rowid;

    IF (SQL%NOTFOUND) THEN
--       IF (IGC_MSGS_PKG.g_debug_mode) THEN
       IF g_debug_mode = 'Y' THEN
          g_debug_msg := ' IGCCHDRB -- Failure Update Row Header ID .....' || p_cc_header_id;
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
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Failure getting appl ID for Upd Header.....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_igc_app_id;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled (p_Set_Of_Books_Id,
                           101, /*--l_Application_Id, commented for MRC uptake*/                           p_Org_Id,
                           NULL,
                           l_MRC_Enabled
                          );

-- ------------------------------------------------------------------
-- If MRC has been enabled for this set of books then make sure that
-- the records are updated accordingly.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- MRC enabled for Update Row Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_CC_HEADERS to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_PVT.get_rsobs_Headers (l_api_version,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            p_validation_level,
                                            l_return_status,
                                            X_msg_count,
                                            X_msg_data,
                                            p_CC_Header_Id,
                                            p_Set_Of_Books_Id,
                                            101, /*--l_Application_Id, commented for MRC uptake*/                                            p_org_Id,
                                            SYSDATE,
                                            l_action_flag
                                           );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
--         IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF g_debug_mode = 'Y' THEN
            g_debug_msg := ' IGCCHDRB -- Failure Update MRC return Header ID .....' || p_cc_header_id;
            Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- MRC Updated Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Committing Update Row Header ID .....' || p_cc_header_id;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- End Update Row Header ID .....' || p_cc_header_id;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Execute Update Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Unexpected Update Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Others Update Header ID .....' || p_cc_header_id;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
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
   p_Rowid                   IN OUT NOCOPY     VARCHAR2,
   G_FLAG                    IN OUT NOCOPY     VARCHAR2
) IS

   l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
   l_api_version             CONSTANT NUMBER         :=  1.0;
   l_msg_count               NUMBER ;
   l_msg_data                VARCHAR2(2000) ;
   l_version_num             IGC_CC_HEADERS_ALL.CC_Version_Num%TYPE;
   l_header_row_id           Varchar2(18);
   l_return_status           VARCHAR2(1);
   l_action_flag             VARCHAR2(1) := 'D';
--   l_debug                   VARCHAR2(1);

l_bc_return_status           VARCHAR2(2);
l_batch_result_code          VARCHAR2(3);
l_debug                      VARCHAR2(1);
l_bc_success                 BOOLEAN;

   CURSOR c_cc_header_row_id IS
     SELECT *
       FROM IGC_CC_HEADERS_ALL
      WHERE Rowid = p_Rowid;

   Recinfo c_cc_header_row_id%ROWTYPE;

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
   IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Starting Header delete Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- -----------------------------------------------------------------
-- Get The record that is about to be deleted
-- -----------------------------------------------------------------
   OPEN c_cc_header_row_id;
   FETCH c_cc_header_row_id
    INTO Recinfo;

-- ------------------------------------------------------------------
-- If the row information can not be attained then exit the procedure
-- ------------------------------------------------------------------
   IF (c_cc_header_row_id%NOTFOUND) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Failure getting Header Rec delete Rowid ...' || p_rowid;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c_cc_header_row_id;


-- --------------------------------------------------------------
-- Unreserve the Encubracnes if any
-- ----------------------------------------------------

   IF (Recinfo.CC_ENCMBRNC_STATUS =  'P' AND
                Recinfo.CC_APPRVL_STATUS = 'IN') THEN

          l_bc_success := IGC_CBC_PA_BC_PKG.IGCPAFCK( p_sobid  =>  Recinfo.set_of_books_id,
                                             p_header_id         =>  Recinfo.cc_header_id,
                                             p_mode              => 'U',
                                             p_actual_flag       =>  'E',
                                             p_ret_status        =>  l_bc_return_status,
                                             p_batch_result_code => l_batch_result_code,
                                             p_doc_type          =>  'CC',
                                             p_debug             =>   g_debug_mode,
                                             p_conc_proc         =>   FND_API.G_FALSE);

             IF l_bc_success = TRUE  --No fatal errors
                    AND substr(l_bc_return_status,1,1) IN ('N','S','A') --CBC successfull
                    AND substr(l_bc_return_status,2,1) IN ('N','S','A') --SBC successfull

             THEN
                 l_Return_Status     := FND_API.G_TRUE;
             ELSE
                 l_Return_Status      := FND_API.G_FALSE;
             END IF;

   IF g_debug_mode = 'Y' THEN
	IF  l_Return_Status = FND_API.G_TRUE THEN
	      g_debug_msg := ' IGCCHDRB -- Succesfully Unreserved the Encubracnes';
	ELSE
	      g_debug_msg := ' IGCCHDRB -- Failed to unreserve the Encubracnes';
	END IF;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   IF l_Return_Status = FND_API.G_TRUE THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END IF;


-- --------------------------------------------------------------------
-- Delete all MRC PF History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_mc_det_pf_history DPH
    WHERE DPH.cc_det_pf_line_id IN
          ( SELECT DPF.cc_det_pf_line_id
              FROM igc_cc_det_pf DPF
             WHERE DPF.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id = Recinfo.cc_header_id
                   )
          )
       OR DPH.cc_det_pf_line_id IN
          ( SELECT DPFH.cc_det_pf_line_id
              FROM igc_cc_det_pf_history DPFH
             WHERE DPFH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id = Recinfo.cc_header_id
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_MC_DET_PF_HISTORY for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all MRC PF History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_mc_det_pf DP
    WHERE DP.cc_det_pf_line_id IN
          ( SELECT DPF.cc_det_pf_line_id
              FROM igc_cc_det_pf DPF
             WHERE DPF.cc_acct_line_id IN
                   ( SELECT ACL.cc_acct_line_id
                       FROM igc_cc_acct_lines ACL
                      WHERE ACL.cc_header_id = Recinfo.cc_header_id
                   )
          )
       OR DP.cc_det_pf_line_id IN
          ( SELECT DPFH.cc_det_pf_line_id
              FROM igc_cc_det_pf_history DPFH
             WHERE DPFH.cc_acct_line_id IN
                   ( SELECT ACLH.cc_acct_line_id
                       FROM igc_cc_acct_line_history ACLH
                      WHERE ACLH.cc_header_id = Recinfo.cc_header_id
                   )
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_MC_DET_PF for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Account Line History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_mc_acct_line_history CALH
    WHERE CALH.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id = Recinfo.cc_header_id
          )
       OR CALH.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id = Recinfo.cc_header_id
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_MC_ACCT_LINE_HISTORY for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Account Line History Lines for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_mc_acct_lines CAL
    WHERE CAL.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id = Recinfo.cc_header_id
          )
       OR CAL.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id = Recinfo.cc_header_id
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_MC_ACCT_LINES for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Header History records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_mc_header_history
    WHERE cc_header_id = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_MC_HEADER_HISTORY for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all MRC Header records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_mc_headers
    WHERE cc_header_id = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_MC_HEADERS for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all CC Action records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_actions
    WHERE cc_header_id = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_ACTIONS for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all PF Line History records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_det_pf_history CDPH
    WHERE CDPH.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id = Recinfo.cc_header_id
          )
       OR CDPH.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id = Recinfo.cc_header_id
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_DET_PF_HISTORY for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all PF Line records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_det_pf CDP
    WHERE CDP.cc_acct_line_id IN
          ( SELECT ACL.cc_acct_line_id
              FROM igc_cc_acct_lines ACL
             WHERE ACL.cc_header_id = Recinfo.cc_header_id
          )
       OR CDP.cc_acct_line_id IN
          ( SELECT ACLH.cc_acct_line_id
              FROM igc_cc_acct_line_history ACLH
             WHERE ACLH.cc_header_id = Recinfo.cc_header_id
          );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_DET_PF for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all Acct Line History records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_acct_line_history ALH
    WHERE ALH.cc_header_id = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_ACCT_LINE_HISTORY for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all Acct Line records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_acct_lines AL
    WHERE AL.cc_header_id = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_ACCT_LINES for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all CC Interface records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_interface CI
    WHERE CI.cc_header_id    = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_INTERFACE for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all CC Access records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_access CA
    WHERE CA.cc_header_id    = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_ACCESS for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all Header History records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM igc_cc_header_history CHH
    WHERE CHH.cc_header_id    = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_HEADER_HISTORY for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

-- --------------------------------------------------------------------
-- Delete all Header records for related CC Header IDs.
-- --------------------------------------------------------------------
   DELETE
     FROM IGC_CC_HEADERS_ALL
    WHERE cc_header_id = Recinfo.cc_header_id;

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- Num Rows Delete IGC_CC_HEADER for CC Header ID : ' ||
                     Recinfo.cc_header_id || ' is : ' || to_char(SQL%ROWCOUNT);
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   G_FLAG := 'Y';

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
--      IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF g_debug_mode = 'Y' THEN
         g_debug_msg := ' IGCCHDRB -- Committing Header delete Rowid ...' || p_rowid;
         Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
   IF g_debug_mode = 'Y' THEN
      g_debug_msg := ' IGCCHDRB -- End Header delete Rowid ...' || p_rowid;
      Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
   END IF;

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
--    IF (IGC_MSGS_PKG.g_debug_mode) THEN
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Execute Header delete Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Unexpected Header delete Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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
    IF g_debug_mode = 'Y' THEN
       g_debug_msg := ' IGCCHDRB -- Failure Others Header delete Rowid ...' || p_rowid;
       Output_Debug (l_full_path, p_debug_msg => g_debug_msg);
    END IF;
    IF (c_cc_header_row_id%ISOPEN) THEN
       CLOSE c_cc_header_row_id;
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

END IGC_CC_HEADERS_PKG;

/
