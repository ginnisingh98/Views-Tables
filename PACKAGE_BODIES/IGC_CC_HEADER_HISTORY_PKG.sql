--------------------------------------------------------
--  DDL for Package Body IGC_CC_HEADER_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_HEADER_HISTORY_PKG" as
/* $Header: IGCCHDHB.pls 120.3.12000000.3 2007/10/19 07:07:39 smannava ship $  */

   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_HEADER_HISTORY_PKG';
   g_debug_flag        VARCHAR2(1) := 'N' ;


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
   p_CC_Header_Id                    IGC_CC_HEADER_HISTORY.CC_Header_Id%TYPE,
   p_Org_id                          IGC_CC_HEADER_HISTORY.Org_id%TYPE,
   p_CC_Type                         IGC_CC_HEADER_HISTORY.CC_Type%TYPE,
   p_CC_Num                          IGC_CC_HEADER_HISTORY.CC_Num%TYPE,
   p_CC_Ref_Num                      IGC_CC_HEADER_HISTORY.CC_Ref_Num%TYPE,
   p_CC_Version_num                  IGC_CC_HEADER_HISTORY.CC_Version_Num%TYPE,
   p_CC_Version_Action               IGC_CC_HEADER_HISTORY.CC_Version_Action%TYPE,
   p_CC_State                        IGC_CC_HEADER_HISTORY.CC_State%TYPE,
   p_Parent_Header_Id                IGC_CC_HEADER_HISTORY.Parent_Header_Id%TYPE,
   p_CC_ctrl_status                  IGC_CC_HEADER_HISTORY.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status              IGC_CC_HEADER_HISTORY.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status                IGC_CC_HEADER_HISTORY.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                       IGC_CC_HEADER_HISTORY.Vendor_Id%TYPE,
   p_Vendor_Site_Id                  IGC_CC_HEADER_HISTORY.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id               IGC_CC_HEADER_HISTORY.Vendor_Contact_Id%TYPE,
   p_Term_Id                         IGC_CC_HEADER_HISTORY.Term_Id%TYPE,
   p_Location_Id                     IGC_CC_HEADER_HISTORY.Location_Id%TYPE,
   p_Set_Of_Books_Id                 IGC_CC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                    IGC_CC_HEADER_HISTORY.CC_Acct_Date%TYPE,
   p_CC_Desc                         IGC_CC_HEADER_HISTORY.CC_Desc%TYPE,
   p_CC_Start_Date                   IGC_CC_HEADER_HISTORY.CC_Start_Date%TYPE,
   p_CC_End_Date                     IGC_CC_HEADER_HISTORY.CC_End_Date%TYPE,
   p_CC_Owner_User_Id                IGC_CC_HEADER_HISTORY.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id             IGC_CC_HEADER_HISTORY.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                   IGC_CC_HEADER_HISTORY.Currency_Code%TYPE,
   p_Conversion_Type                 IGC_CC_HEADER_HISTORY.Conversion_Type%TYPE,
   p_Conversion_Date                 IGC_CC_HEADER_HISTORY.Conversion_Date%TYPE,
   p_Conversion_Rate                 IGC_CC_HEADER_HISTORY.Conversion_Rate%TYPE,
   p_Last_Update_Date                IGC_CC_HEADER_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_HEADER_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_HEADER_HISTORY.Last_Update_Login%TYPE,
   p_Created_By                      IGC_CC_HEADER_HISTORY.Created_By%TYPE,
   p_Creation_Date                   IGC_CC_HEADER_HISTORY.Creation_Date%TYPE,
   p_Wf_Item_Type                    IGC_CC_HEADER_HISTORY.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                     IGC_CC_HEADER_HISTORY.Wf_Item_Key%TYPE,
   p_CC_Current_User_Id              IGC_CC_HEADERS.CC_Current_User_Id%TYPE,
   p_Attribute1                      IGC_CC_HEADER_HISTORY.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_HEADER_HISTORY.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_HEADER_HISTORY.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_HEADER_HISTORY.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_HEADER_HISTORY.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_HEADER_HISTORY.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_HEADER_HISTORY.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_HEADER_HISTORY.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_HEADER_HISTORY.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_HEADER_HISTORY.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_HEADER_HISTORY.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_HEADER_HISTORY.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_HEADER_HISTORY.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_HEADER_HISTORY.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_HEADER_HISTORY.Attribute15%TYPe,
   p_Context                         IGC_CC_HEADER_HISTORY.Context%TYPE,
   p_CC_Guarantee_Flag               IGC_CC_HEADER_HISTORY.CC_Guarantee_Flag%TYPE,
   G_FLAG                   IN OUT NOCOPY   VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_return_status       VARCHAR2(1);

   CURSOR C_header_hst_rowid IS
     SELECT Rowid
       FROM IGC_CC_HEADER_HISTORY
      WHERE CC_Header_id   = p_CC_Header_id
        AND CC_Version_Num = P_CC_Version_Num ;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM   FND_APPLICATION
      WHERE  Application_Short_Name =  'IGC';

BEGIN

   SAVEPOINT Insert_Row_Pvt ;

-- -----------------------------------------------------------------
-- Ensure that the version requested to be used is correct for
-- this API.
-- -----------------------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
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

-- -----------------------------------------------------------------
-- Insert the CC Header History record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_HEADER_HISTORY
             (CC_Header_Id,
              Parent_Header_Id,
              Org_Id,
              CC_Type,
              CC_Num,
              CC_Ref_Num,
              CC_Version_Num,
              CC_Version_Action,
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
              p_CC_Version_Action,
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
   OPEN C_header_hst_rowid ;
   FETCH C_header_hst_rowid
    INTO p_Rowid;

-- -------------------------------------------------------------------
-- If no ROWID can be obtained then exit the procedure with a failure
-- -------------------------------------------------------------------
   IF (C_header_hst_rowid %NOTFOUND) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE C_header_hst_rowid ;

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
                           Null,
                           l_MRC_Enabled);

-- ------------------------------------------------------------------
-- If MRC is enabled for this set of books being used then call the
-- handler to insert all reporting set of books into the MRC
-- table for the account line inserted.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_HEADERS to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_HST_PVT.get_rsobs_Headers(
                                 l_api_version,
                                 FND_API.G_FALSE,
                                 FND_API.G_FALSE,
                                 p_validation_level,
                                 l_return_status,
                                 X_msg_count,
                                 X_msg_data,
                                 p_CC_Header_Id,
                                 p_Set_Of_Books_Id,
                                  101, /*--l_Application_Id, commented for MRC uptake*/
                                 p_org_Id,
                                 SYSDATE,
                                 p_CC_Version_num,
                                 p_CC_Version_Action );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    IF (C_header_hst_rowid %ISOPEN) THEN
       CLOSE C_header_hst_rowid ;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (C_header_hst_rowid %ISOPEN) THEN
       CLOSE C_header_hst_rowid ;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (C_header_hst_rowid %ISOPEN) THEN
       CLOSE C_header_hst_rowid ;
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
   p_CC_Header_Id                    IGC_CC_HEADER_HISTORY.CC_Header_Id%TYPE,
   p_Org_id                          IGC_CC_HEADER_HISTORY.Org_id%TYPE,
   p_CC_Type                         IGC_CC_HEADER_HISTORY.CC_Type%TYPE,
   p_CC_Num                          IGC_CC_HEADER_HISTORY.CC_Num%TYPE,
   p_CC_Version_num                  IGC_CC_HEADER_HISTORY.CC_Version_Num%TYPE,
   p_CC_Version_Action               IGC_CC_HEADER_HISTORY.CC_Version_Action%TYPE,
   p_CC_State                        IGC_CC_HEADER_HISTORY.CC_State%TYPE,
   p_Parent_Header_Id                IGC_CC_HEADER_HISTORY.Parent_Header_Id%TYPE,
   p_CC_ctrl_status                  IGC_CC_HEADER_HISTORY.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status              IGC_CC_HEADER_HISTORY.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status                IGC_CC_HEADER_HISTORY.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                       IGC_CC_HEADER_HISTORY.Vendor_Id%TYPE,
   p_Vendor_Site_Id                  IGC_CC_HEADER_HISTORY.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id               IGC_CC_HEADER_HISTORY.Vendor_Contact_Id%TYPE,
   p_Term_Id                         IGC_CC_HEADER_HISTORY.Term_Id%TYPE,
   p_Location_Id                     IGC_CC_HEADER_HISTORY.Location_Id%TYPE,
   p_Set_Of_Books_Id                 IGC_CC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                    IGC_CC_HEADER_HISTORY.CC_Acct_Date%TYPE,
   p_CC_Desc                         IGC_CC_HEADER_HISTORY.CC_Desc%TYPE,
   p_CC_Start_Date                   IGC_CC_HEADER_HISTORY.CC_Start_Date%TYPE,
   p_CC_End_Date                     IGC_CC_HEADER_HISTORY.CC_End_Date%TYPE,
   p_CC_Owner_User_Id                IGC_CC_HEADER_HISTORY.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id             IGC_CC_HEADER_HISTORY.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                   IGC_CC_HEADER_HISTORY.Currency_Code%TYPE,
   p_Conversion_Type                 IGC_CC_HEADER_HISTORY.Conversion_Type%TYPE,
   p_Conversion_Date                 IGC_CC_HEADER_HISTORY.Conversion_Date%TYPE,
   p_Conversion_Rate                 IGC_CC_HEADER_HISTORY.Conversion_Rate%TYPE,
   p_Last_Update_Date                IGC_CC_HEADER_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By                 IGC_CC_HEADER_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login               IGC_CC_HEADER_HISTORY.Last_Update_Login%TYPE,
   p_Created_By                      IGC_CC_HEADER_HISTORY.Created_By%TYPE,
   p_Creation_Date                   IGC_CC_HEADER_HISTORY.Creation_Date%TYPE,
   p_Wf_Item_Type                    IGC_CC_HEADER_HISTORY.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                     IGC_CC_HEADER_HISTORY.Wf_Item_Key%TYPE,
   p_CC_Current_User_Id              IGC_CC_HEADERS.CC_Current_User_Id%TYPE,
   p_Attribute1                      IGC_CC_HEADER_HISTORY.Attribute1%TYPE,
   p_Attribute2                      IGC_CC_HEADER_HISTORY.Attribute2%TYPE,
   p_Attribute3                      IGC_CC_HEADER_HISTORY.Attribute3%TYPE,
   p_Attribute4                      IGC_CC_HEADER_HISTORY.Attribute4%TYPE,
   p_Attribute5                      IGC_CC_HEADER_HISTORY.Attribute5%TYPE,
   p_Attribute6                      IGC_CC_HEADER_HISTORY.Attribute6%TYPE,
   p_Attribute7                      IGC_CC_HEADER_HISTORY.Attribute7%TYPE,
   p_Attribute8                      IGC_CC_HEADER_HISTORY.Attribute8%TYPE,
   p_Attribute9                      IGC_CC_HEADER_HISTORY.Attribute9%TYPE,
   p_Attribute10                     IGC_CC_HEADER_HISTORY.Attribute10%TYPE,
   p_Attribute11                     IGC_CC_HEADER_HISTORY.Attribute11%TYPE,
   p_Attribute12                     IGC_CC_HEADER_HISTORY.Attribute12%TYPE,
   p_Attribute13                     IGC_CC_HEADER_HISTORY.Attribute13%TYPE,
   p_Attribute14                     IGC_CC_HEADER_HISTORY.Attribute14%TYPE,
   p_Attribute15                     IGC_CC_HEADER_HISTORY.Attribute15%TYPe,
   p_Context                         IGC_CC_HEADER_HISTORY.Context%TYPE,
   p_CC_Guarantee_Flag               IGC_CC_HEADER_HISTORY.CC_Guarantee_Flag%TYPE,
   G_FLAG                   IN OUT NOCOPY   VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_return_status       VARCHAR2(1);

   CURSOR C_header_hst_rowid IS
     SELECT Rowid
       FROM IGC_CC_HEADER_HISTORY
      WHERE CC_Header_id   = p_CC_Header_id
        AND CC_Version_Num = P_CC_Version_Num ;

   CURSOR c_igc_app_id IS
     SELECT Application_Id
       FROM   FND_APPLICATION
      WHERE  Application_Short_Name =  'IGC';

BEGIN

   SAVEPOINT Insert_Row_Pvt ;

-- -----------------------------------------------------------------
-- Ensure that the version requested to be used is correct for
-- this API.
-- -----------------------------------------------------------------
   IF NOT FND_API.Compatible_API_Call (l_api_version,
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

-- -----------------------------------------------------------------
-- Insert the CC Header History record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_HEADER_HISTORY
             (CC_Header_Id,
              Parent_Header_Id,
              Org_Id,
              CC_Type,
              CC_Num,
              CC_Version_Num,
              CC_Version_Action,
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
              p_CC_Version_Action,
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
   OPEN C_header_hst_rowid ;
   FETCH C_header_hst_rowid
    INTO p_Rowid;

-- -------------------------------------------------------------------
-- If no ROWID can be obtained then exit the procedure with a failure
-- -------------------------------------------------------------------
   IF (C_header_hst_rowid %NOTFOUND) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE C_header_hst_rowid ;

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
                           Null,
                           l_MRC_Enabled);

-- ------------------------------------------------------------------
-- If MRC is enabled for this set of books being used then call the
-- handler to insert all reporting set of books into the MRC
-- table for the account line inserted.
-- ------------------------------------------------------------------
   IF (l_MRC_Enabled = 'Y') THEN

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_HEADERS to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_HST_PVT.get_rsobs_Headers(
                                 l_api_version,
                                 FND_API.G_FALSE,
                                 FND_API.G_FALSE,
                                 p_validation_level,
                                 l_return_status,
                                 X_msg_count,
                                 X_msg_data,
                                 p_CC_Header_Id,
                                 p_Set_Of_Books_Id,
                                  101, /*--l_Application_Id, commented for MRC uptake*/
                                 p_org_Id,
                                 SYSDATE,
                                 p_CC_Version_num,
                                 p_CC_Version_Action );

-- ------------------------------------------------------------------
-- Make sure that the insertion was a success
-- ------------------------------------------------------------------
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   END IF;

-- -----------------------------------------------------------------
-- If the records are to be commited in this procedure then
-- commit the work now otherwise wait for the caller to do COMMIT.
-- -----------------------------------------------------------------
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

   RETURN;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    IF (C_header_hst_rowid %ISOPEN) THEN
       CLOSE C_header_hst_rowid ;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (C_header_hst_rowid %ISOPEN) THEN
       CLOSE C_header_hst_rowid ;
    END IF;
    IF (c_igc_app_id%ISOPEN) THEN
       CLOSE c_igc_app_id;
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (C_header_hst_rowid %ISOPEN) THEN
       CLOSE C_header_hst_rowid ;
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


  END Insert_Row;

/* ================================================================================
                         PROCEDURE Lock_Row
   ===============================================================================*/

PROCEDURE Lock_Row(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY VARCHAR2,
   X_msg_count                 OUT NOCOPY NUMBER,
   X_msg_data                  OUT NOCOPY VARCHAR2,
   p_Rowid                  IN OUT NOCOPY VARCHAR2,
   p_CC_Header_Id                  IGC_CC_HEADER_HISTORY.CC_Header_Id%TYPE,
   p_Org_id                        IGC_CC_HEADER_HISTORY.Org_id%TYPE,
   p_CC_Type                       IGC_CC_HEADER_HISTORY.CC_Type%TYPE,
   p_CC_Num                        IGC_CC_HEADER_HISTORY.CC_Num%TYPE,
   p_CC_Version_num                IGC_CC_HEADER_HISTORY.CC_Version_Num%TYPE,
   p_CC_Version_Action             IGC_CC_HEADER_HISTORY.CC_Version_Action%TYPE,
   p_CC_State                      IGC_CC_HEADER_HISTORY.CC_State%TYPE,
   p_Parent_Header_Id              IGC_CC_HEADER_HISTORY.Parent_Header_Id%TYPE,
   p_CC_ctrl_status                IGC_CC_HEADER_HISTORY.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status            IGC_CC_HEADER_HISTORY.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status              IGC_CC_HEADER_HISTORY.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                     IGC_CC_HEADER_HISTORY.Vendor_Id%TYPE,
   p_Vendor_Site_Id                IGC_CC_HEADER_HISTORY.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id             IGC_CC_HEADER_HISTORY.Vendor_Contact_Id%TYPE,
   p_Term_Id                       IGC_CC_HEADER_HISTORY.Term_Id%TYPE,
   p_Location_Id                   IGC_CC_HEADER_HISTORY.Location_Id%TYPE,
   p_Set_Of_Books_Id               IGC_CC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                  IGC_CC_HEADER_HISTORY.CC_Acct_Date%TYPE,
   p_CC_Desc                       IGC_CC_HEADER_HISTORY.CC_Desc%TYPE,
   p_CC_Start_Date                 IGC_CC_HEADER_HISTORY.CC_Start_Date%TYPE,
   p_CC_End_Date                   IGC_CC_HEADER_HISTORY.CC_End_Date%TYPE,
   p_CC_Owner_User_Id              IGC_CC_HEADER_HISTORY.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id           IGC_CC_HEADER_HISTORY.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                 IGC_CC_HEADER_HISTORY.Currency_Code%TYPE,
   p_Conversion_Type               IGC_CC_HEADER_HISTORY.Conversion_Type%TYPE,
   p_Conversion_Date               IGC_CC_HEADER_HISTORY.Conversion_Date%TYPE,
   p_Conversion_Rate               IGC_CC_HEADER_HISTORY.Conversion_Rate%TYPE,
   p_Last_Update_Date              IGC_CC_HEADER_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By               IGC_CC_HEADER_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login             IGC_CC_HEADER_HISTORY.Last_Update_Login%TYPE,
   p_Created_By                    IGC_CC_HEADER_HISTORY.Created_By%TYPE,
   p_Creation_Date                 IGC_CC_HEADER_HISTORY.Creation_Date%TYPE,
   p_Wf_Item_Type                  IGC_CC_HEADER_HISTORY.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                   IGC_CC_HEADER_HISTORY.Wf_Item_Key%TYPE,
   p_CC_Current_User_Id            IGC_CC_HEADERS.CC_Current_User_Id%TYPE,
   p_Attribute1                    IGC_CC_HEADER_HISTORY.Attribute1%TYPE,
   p_Attribute2                    IGC_CC_HEADER_HISTORY.Attribute2%TYPE,
   p_Attribute3                    IGC_CC_HEADER_HISTORY.Attribute3%TYPE,
   p_Attribute4                    IGC_CC_HEADER_HISTORY.Attribute4%TYPE,
   p_Attribute5                    IGC_CC_HEADER_HISTORY.Attribute5%TYPE,
   p_Attribute6                    IGC_CC_HEADER_HISTORY.Attribute6%TYPE,
   p_Attribute7                    IGC_CC_HEADER_HISTORY.Attribute7%TYPE,
   p_Attribute8                    IGC_CC_HEADER_HISTORY.Attribute8%TYPE,
   p_Attribute9                    IGC_CC_HEADER_HISTORY.Attribute9%TYPE,
   p_Attribute10                   IGC_CC_HEADER_HISTORY.Attribute10%TYPE,
   p_Attribute11                   IGC_CC_HEADER_HISTORY.Attribute11%TYPE,
   p_Attribute12                   IGC_CC_HEADER_HISTORY.Attribute12%TYPE,
   p_Attribute13                   IGC_CC_HEADER_HISTORY.Attribute13%TYPE,
   p_Attribute14                   IGC_CC_HEADER_HISTORY.Attribute14%TYPE,
   p_Attribute15                   IGC_CC_HEADER_HISTORY.Attribute15%TYPE,
   p_Context                       IGC_CC_HEADER_HISTORY.Context%TYPE,
   p_CC_Guarantee_Flag             IGC_CC_HEADER_HISTORY.CC_Guarantee_Flag%TYPE,
   X_row_locked                OUT NOCOPY VARCHAR2,
   G_FLAG                   IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   Counter               NUMBER;

   CURSOR C IS
     SELECT *
       FROM IGC_CC_HEADER_HISTORY
      WHERE rowid = p_Rowid
        FOR UPDATE of CC_Header_Id NOWAIT;

    Recinfo C%ROWTYPE;

BEGIN

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


   OPEN C;
   FETCH C
    INTO Recinfo;

   IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE C;

   IF (
               (Recinfo.CC_Header_Id =  p_CC_Header_Id)
           AND (Recinfo.Org_Id =  p_Org_Id)
           AND (Recinfo.CC_Type =  p_CC_Type)
           AND (Recinfo.CC_Num =  p_CC_Num)
           AND (Recinfo.CC_Version_Num =  p_CC_Version_Num)
           AND (Recinfo.CC_Version_Action =  p_CC_Version_Action)
           AND (   (Recinfo.Parent_Header_Id =  p_Parent_Header_Id)
                OR (    (Recinfo.Parent_Header_Id IS NULL)
                    AND (p_Parent_Header_Id IS NULL)))
           AND (   (Recinfo.CC_state =  p_CC_State)
                OR (    (Recinfo.CC_State IS NULL)
                    AND (p_CC_State IS NULL)))
           AND (   (Recinfo.CC_Ctrl_Status =  p_CC_Ctrl_Status)
                OR (    (Recinfo.CC_Ctrl_status IS NULL)
                    AND (p_CC_Ctrl_Status IS NULL)))
           AND (   (Recinfo.CC_Encmbrnc_Status =  p_CC_Encmbrnc_Status)
                OR (    (Recinfo.CC_Encmbrnc_Status IS NULL)
                    AND (p_CC_Encmbrnc_Status IS NULL)))
           AND (   (Recinfo.CC_Apprvl_Status =  p_CC_Apprvl_Status)
                OR (    (Recinfo.CC_Apprvl_Status IS NULL)
                    AND (p_CC_Apprvl_Status IS NULL)))
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
           AND (   (Recinfo.Set_Of_Books_Id =  p_Set_Of_Books_Id)
                OR (    (Recinfo.Set_Of_Books_Id IS NULL)
                    AND (p_Set_Of_Books_Id IS NULL)))
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
           AND (   (Recinfo.CC_Owner_User_Id =  p_CC_Owner_User_Id)
                OR (    (Recinfo.CC_Owner_User_Id IS NULL)
                    AND (p_CC_Owner_User_Id IS NULL)))
           AND (   (Recinfo.CC_Preparer_User_Id =  p_CC_Preparer_User_Id)
                OR (    (Recinfo.CC_Preparer_User_Id IS NULL)
                    AND (p_CC_Preparer_User_Id IS NULL)))
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
           AND (   (Recinfo.WF_Item_Type =  p_WF_Item_Type)
                OR (    (Recinfo.WF_Item_Type IS NULL)
                    AND (p_WF_Item_Type IS NULL)))
           AND (   (Recinfo.WF_Item_Key =  p_WF_Item_Key)
                OR (    (Recinfo.WF_Item_Key IS NULL)
                    AND (p_WF_Item_Key IS NULL)))
           AND (   (Recinfo.CC_Current_User_Id =  p_CC_Current_User_Id)
                OR (    (Recinfo.CC_Current_User_Id IS NULL)
                    AND (p_CC_Current_User_Id IS NULL)))
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
                OR (    (Recinfo.CC_Guarantee_Flag IS NULL)
                    AND (p_CC_Guarantee_Flag IS NULL)))

      ) THEN

       NULL;

   ELSE

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;

   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

   RETURN;

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_row_locked := FND_API.G_FALSE;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  END Lock_Row;

/* ================================================================================
         PROCEDURE Update_Row Overloaded Procedure for CC_REF_NUM addition
   ===============================================================================*/

PROCEDURE Update_Row(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY VARCHAR2,
   X_msg_count                 OUT NOCOPY NUMBER,
   X_msg_data                  OUT NOCOPY VARCHAR2,
   p_Rowid                  IN OUT NOCOPY VARCHAR2,
   p_CC_Header_Id                  IGC_CC_HEADER_HISTORY.CC_Header_Id%TYPE,
   p_Org_id                        IGC_CC_HEADER_HISTORY.Org_id%TYPE,
   p_CC_Type                       IGC_CC_HEADER_HISTORY.CC_Type%TYPE,
   p_CC_Num                        IGC_CC_HEADER_HISTORY.CC_Num%TYPE,
   p_CC_Ref_Num                    IGC_CC_HEADER_HISTORY.CC_Ref_Num%TYPE,
   p_CC_Version_num                IGC_CC_HEADER_HISTORY.CC_Version_Num%TYPE,
   p_CC_Version_Action             IGC_CC_HEADER_HISTORY.CC_Version_Action%TYPE,
   p_CC_State                      IGC_CC_HEADER_HISTORY.CC_State%TYPE,
   p_Parent_Header_Id              IGC_CC_HEADER_HISTORY.Parent_Header_Id%TYPE,
   p_CC_ctrl_status                IGC_CC_HEADER_HISTORY.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status            IGC_CC_HEADER_HISTORY.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status              IGC_CC_HEADER_HISTORY.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                     IGC_CC_HEADER_HISTORY.Vendor_Id%TYPE,
   p_Vendor_Site_Id                IGC_CC_HEADER_HISTORY.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id             IGC_CC_HEADER_HISTORY.Vendor_Contact_Id%TYPE,
   p_Term_Id                       IGC_CC_HEADER_HISTORY.Term_Id%TYPE,
   p_Location_Id                   IGC_CC_HEADER_HISTORY.Location_Id%TYPE,
   p_Set_Of_Books_Id               IGC_CC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                  IGC_CC_HEADER_HISTORY.CC_Acct_Date%TYPE,
   p_CC_Desc                       IGC_CC_HEADER_HISTORY.CC_Desc%TYPE,
   p_CC_Start_Date                 IGC_CC_HEADER_HISTORY.CC_Start_Date%TYPE,
   p_CC_End_Date                   IGC_CC_HEADER_HISTORY.CC_End_Date%TYPE,
   p_CC_Owner_User_Id              IGC_CC_HEADER_HISTORY.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id           IGC_CC_HEADER_HISTORY.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                 IGC_CC_HEADER_HISTORY.Currency_Code%TYPE,
   p_Conversion_Type               IGC_CC_HEADER_HISTORY.Conversion_Type%TYPE,
   p_Conversion_Date               IGC_CC_HEADER_HISTORY.Conversion_Date%TYPE,
   p_Conversion_Rate               IGC_CC_HEADER_HISTORY.Conversion_Rate%TYPE,
   p_Last_Update_Date              IGC_CC_HEADER_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By               IGC_CC_HEADER_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login             IGC_CC_HEADER_HISTORY.Last_Update_Login%TYPE,
   p_Created_By                    IGC_CC_HEADER_HISTORY.Created_By%TYPE,
   p_Creation_Date                 IGC_CC_HEADER_HISTORY.Creation_Date%TYPE,
   p_Wf_Item_Type                  IGC_CC_HEADER_HISTORY.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                   IGC_CC_HEADER_HISTORY.Wf_Item_Key%TYPE,
   p_CC_Current_User_Id            IGC_CC_HEADERS.CC_Current_User_Id%TYPE,
   p_Attribute1                    IGC_CC_HEADER_HISTORY.Attribute1%TYPE,
   p_Attribute2                    IGC_CC_HEADER_HISTORY.Attribute2%TYPE,
   p_Attribute3                    IGC_CC_HEADER_HISTORY.Attribute3%TYPE,
   p_Attribute4                    IGC_CC_HEADER_HISTORY.Attribute4%TYPE,
   p_Attribute5                    IGC_CC_HEADER_HISTORY.Attribute5%TYPE,
   p_Attribute6                    IGC_CC_HEADER_HISTORY.Attribute6%TYPE,
   p_Attribute7                    IGC_CC_HEADER_HISTORY.Attribute7%TYPE,
   p_Attribute8                    IGC_CC_HEADER_HISTORY.Attribute8%TYPE,
   p_Attribute9                    IGC_CC_HEADER_HISTORY.Attribute9%TYPE,
   p_Attribute10                   IGC_CC_HEADER_HISTORY.Attribute10%TYPE,
   p_Attribute11                   IGC_CC_HEADER_HISTORY.Attribute11%TYPE,
   p_Attribute12                   IGC_CC_HEADER_HISTORY.Attribute12%TYPE,
   p_Attribute13                   IGC_CC_HEADER_HISTORY.Attribute13%TYPE,
   p_Attribute14                   IGC_CC_HEADER_HISTORY.Attribute14%TYPE,
   p_Attribute15                   IGC_CC_HEADER_HISTORY.Attribute15%TYPE,
   p_Context                       IGC_CC_HEADER_HISTORY.Context%TYPE,
   p_CC_Guarantee_Flag             IGC_CC_HEADER_HISTORY.CC_Guarantee_Flag%TYPE,
   G_FLAG                   IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

   SAVEPOINT Update_Row_Pvt ;

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

   UPDATE IGC_CC_HEADER_HISTORY
      SET CC_Header_Id        = p_CC_Header_Id,
          Parent_Header_Id    = p_Parent_Header_Id,
          Org_Id              = p_Org_id,
          CC_Type             = p_CC_Type,
          CC_Num              = p_CC_Num,
          CC_Ref_Num          = p_CC_Ref_Num,
          CC_Version_Num      = p_CC_Version_num,
          CC_Version_Action   = p_CC_Version_Action,
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
      Raise NO_DATA_FOUND;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );


  END Update_Row;

/* ================================================================================
                         PROCEDURE Update_Row
   ===============================================================================*/

PROCEDURE Update_Row(
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status             OUT NOCOPY VARCHAR2,
   X_msg_count                 OUT NOCOPY NUMBER,
   X_msg_data                  OUT NOCOPY VARCHAR2,
   p_Rowid               IN OUT NOCOPY    VARCHAR2,
   p_CC_Header_Id                  IGC_CC_HEADER_HISTORY.CC_Header_Id%TYPE,
   p_Org_id                        IGC_CC_HEADER_HISTORY.Org_id%TYPE,
   p_CC_Type                       IGC_CC_HEADER_HISTORY.CC_Type%TYPE,
   p_CC_Num                        IGC_CC_HEADER_HISTORY.CC_Num%TYPE,
   p_CC_Version_num                IGC_CC_HEADER_HISTORY.CC_Version_Num%TYPE,
   p_CC_Version_Action             IGC_CC_HEADER_HISTORY.CC_Version_Action%TYPE,
   p_CC_State                      IGC_CC_HEADER_HISTORY.CC_State%TYPE,
   p_Parent_Header_Id              IGC_CC_HEADER_HISTORY.Parent_Header_Id%TYPE,
   p_CC_ctrl_status                IGC_CC_HEADER_HISTORY.CC_ctrl_status%TYPE,
   p_CC_Encmbrnc_Status            IGC_CC_HEADER_HISTORY.CC_Encmbrnc_Status%TYPE,
   p_CC_Apprvl_Status              IGC_CC_HEADER_HISTORY.CC_Apprvl_Status%TYPE,
   p_Vendor_Id                     IGC_CC_HEADER_HISTORY.Vendor_Id%TYPE,
   p_Vendor_Site_Id                IGC_CC_HEADER_HISTORY.Vendor_Site_Id%TYPE,
   p_Vendor_Contact_Id             IGC_CC_HEADER_HISTORY.Vendor_Contact_Id%TYPE,
   p_Term_Id                       IGC_CC_HEADER_HISTORY.Term_Id%TYPE,
   p_Location_Id                   IGC_CC_HEADER_HISTORY.Location_Id%TYPE,
   p_Set_Of_Books_Id               IGC_CC_HEADER_HISTORY.Set_Of_Books_Id%TYPE,
   p_CC_Acct_Date                  IGC_CC_HEADER_HISTORY.CC_Acct_Date%TYPE,
   p_CC_Desc                       IGC_CC_HEADER_HISTORY.CC_Desc%TYPE,
   p_CC_Start_Date                 IGC_CC_HEADER_HISTORY.CC_Start_Date%TYPE,
   p_CC_End_Date                   IGC_CC_HEADER_HISTORY.CC_End_Date%TYPE,
   p_CC_Owner_User_Id              IGC_CC_HEADER_HISTORY.CC_Owner_User_Id%TYPE,
   p_CC_Preparer_User_Id           IGC_CC_HEADER_HISTORY.CC_Preparer_User_Id%TYPE,
   p_Currency_Code                 IGC_CC_HEADER_HISTORY.Currency_Code%TYPE,
   p_Conversion_Type               IGC_CC_HEADER_HISTORY.Conversion_Type%TYPE,
   p_Conversion_Date               IGC_CC_HEADER_HISTORY.Conversion_Date%TYPE,
   p_Conversion_Rate               IGC_CC_HEADER_HISTORY.Conversion_Rate%TYPE,
   p_Last_Update_Date              IGC_CC_HEADER_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By               IGC_CC_HEADER_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login             IGC_CC_HEADER_HISTORY.Last_Update_Login%TYPE,
   p_Created_By                    IGC_CC_HEADER_HISTORY.Created_By%TYPE,
   p_Creation_Date                 IGC_CC_HEADER_HISTORY.Creation_Date%TYPE,
   p_Wf_Item_Type                  IGC_CC_HEADER_HISTORY.Wf_Item_Type%TYPE,
   p_Wf_Item_Key                   IGC_CC_HEADER_HISTORY.Wf_Item_Key%TYPE,
   p_CC_Current_User_Id            IGC_CC_HEADERS.CC_Current_User_Id%TYPE,
   p_Attribute1                    IGC_CC_HEADER_HISTORY.Attribute1%TYPE,
   p_Attribute2                    IGC_CC_HEADER_HISTORY.Attribute2%TYPE,
   p_Attribute3                    IGC_CC_HEADER_HISTORY.Attribute3%TYPE,
   p_Attribute4                    IGC_CC_HEADER_HISTORY.Attribute4%TYPE,
   p_Attribute5                    IGC_CC_HEADER_HISTORY.Attribute5%TYPE,
   p_Attribute6                    IGC_CC_HEADER_HISTORY.Attribute6%TYPE,
   p_Attribute7                    IGC_CC_HEADER_HISTORY.Attribute7%TYPE,
   p_Attribute8                    IGC_CC_HEADER_HISTORY.Attribute8%TYPE,
   p_Attribute9                    IGC_CC_HEADER_HISTORY.Attribute9%TYPE,
   p_Attribute10                   IGC_CC_HEADER_HISTORY.Attribute10%TYPE,
   p_Attribute11                   IGC_CC_HEADER_HISTORY.Attribute11%TYPE,
   p_Attribute12                   IGC_CC_HEADER_HISTORY.Attribute12%TYPE,
   p_Attribute13                   IGC_CC_HEADER_HISTORY.Attribute13%TYPE,
   p_Attribute14                   IGC_CC_HEADER_HISTORY.Attribute14%TYPE,
   p_Attribute15                   IGC_CC_HEADER_HISTORY.Attribute15%TYPE,
   p_Context                       IGC_CC_HEADER_HISTORY.Context%TYPE,
   p_CC_Guarantee_Flag             IGC_CC_HEADER_HISTORY.CC_Guarantee_Flag%TYPE,
   G_FLAG                   IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;


BEGIN

   SAVEPOINT Update_Row_Pvt ;

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

   UPDATE IGC_CC_HEADER_HISTORY
      SET CC_Header_Id        =      p_CC_Header_Id,
          Parent_Header_Id    =      p_Parent_Header_Id,
          Org_Id              =      p_Org_id,
          CC_Type             =      p_CC_Type,
          CC_Num              =      p_CC_Num,
          CC_Version_Num      =      p_CC_Version_num,
          CC_Version_Action   =      p_CC_Version_Action,
          CC_State            =      p_CC_State,
          CC_ctrl_status      =      p_CC_ctrl_status ,
          CC_Encmbrnc_Status  =      p_CC_Encmbrnc_Status,
          CC_Apprvl_Status    =      p_CC_Apprvl_Status,
          Vendor_Id           =      p_Vendor_Id,
          Vendor_Site_Id      =      p_Vendor_Site_Id,
          Vendor_Contact_Id   =      p_Vendor_Contact_Id,
          Term_Id             =      p_Term_Id,
          Location_Id         =      p_Location_Id,
          Set_Of_Books_Id     =      p_Set_Of_Books_Id,
          CC_Acct_Date        =      p_CC_Acct_Date,
          CC_Desc             =      p_CC_Desc,
          CC_Start_Date       =      p_CC_Start_Date,
          CC_End_Date         =      p_CC_End_Date,
          CC_Owner_User_Id    =      p_CC_Owner_User_Id,
          CC_Preparer_User_Id =      p_CC_Preparer_User_Id,
          Currency_Code       =      p_Currency_Code,
          Conversion_Type     =      p_Conversion_Type,
          Conversion_Date     =      p_Conversion_Date,
          Conversion_Rate     =      p_Conversion_Rate,
          Last_Update_Date    =      p_Last_Update_Date,
          Last_Updated_By     =      p_Last_Updated_By,
          Last_Update_Login   =      p_Last_Update_Login,
          Created_By          =      p_Created_By,
          Creation_Date       =      p_Creation_Date,
          Wf_Item_Type        =      p_Wf_Item_Type,
          Wf_Item_Key         =      p_Wf_Item_Key,
          CC_Current_User_Id  =      p_CC_Current_User_Id,
          Attribute1          =      p_Attribute1,
          Attribute2          =      p_Attribute2,
          Attribute3          =      p_Attribute3,
          Attribute4          =      p_Attribute4,
          Attribute5          =      p_Attribute5,
          Attribute6          =      p_Attribute6,
          Attribute7          =      p_Attribute7,
          Attribute8          =      p_Attribute8,
          Attribute9          =      p_Attribute9,
          Attribute10         =      p_Attribute10,
          Attribute11         =      p_Attribute11,
          Attribute12         =      p_Attribute12,
          Attribute13         =      p_Attribute13,
          Attribute14         =      p_Attribute14,
          Attribute15         =      p_Attribute15,
          Context             =      p_Context,
          CC_Guarantee_Flag   =      p_CC_Guarantee_Flag
    WHERE rowid = p_Rowid;

   IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );


  END Update_Row;

/* ================================================================================
                         PROCEDURE Delete_Row
   ===============================================================================*/

PROCEDURE Delete_Row(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status       OUT NOCOPY VARCHAR2,
   X_msg_count           OUT NOCOPY NUMBER,
   X_msg_data            OUT NOCOPY VARCHAR2,
   p_Rowid                   VARCHAR2,
   G_FLAG             IN OUT NOCOPY VARCHAR2
) IS

   l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
   l_api_version             CONSTANT NUMBER         :=  1.0;
   l_return_status           VARCHAR2(1) ;
   l_msg_count               NUMBER ;
   l_msg_data                VARCHAR2(2000) ;

BEGIN

   SAVEPOINT Delete_Row_Pvt ;

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

   DELETE
     FROM IGC_CC_HEADER_HISTORY
    WHERE rowid = p_Rowid;

   IF (SQL%NOTFOUND) THEN
      Raise NO_DATA_FOUND;
   END IF;

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END iF;

   FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                               p_data  => X_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  END Delete_Row;



END IGC_CC_HEADER_HISTORY_PKG;

/
