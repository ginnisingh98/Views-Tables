--------------------------------------------------------
--  DDL for Package Body IGC_CC_DET_PF_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_DET_PF_HISTORY_PKG" as
/* $Header: IGCCDFHB.pls 120.3.12000000.3 2007/10/19 07:03:44 smannava ship $  */

   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_DET_PF_HISTORY_PKG';
   g_debug_flag        VARCHAR2(1) := 'N' ;

/* ================================================================================
                         PROCEDURE Insert_Row
   ===============================================================================*/

PROCEDURE Insert_Row(
   p_api_version                  IN  NUMBER,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status                OUT NOCOPY VARCHAR2,
   X_msg_count                    OUT NOCOPY NUMBER,
   X_msg_data                     OUT NOCOPY VARCHAR2,
   p_Rowid                     IN OUT NOCOPY VARCHAR2,
   p_CC_Det_PF_Line_Id                IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Line_Num               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Num%TYPE,
   p_CC_Acct_Line_Id                  IGC_CC_DET_PF_HISTORY.CC_Acct_Line_Id%TYPE,
   p_Parent_Acct_Line_Id              IGC_CC_DET_PF_HISTORY.Parent_Acct_Line_Id%TYPE,
   p_Parent_Det_PF_Line_Id            IGC_CC_DET_PF_HISTORY.Parent_Det_PF_Line_Id%TYPE,
   p_Det_PF_Version_Num               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Num%TYPE,
   p_Det_PF_Version_Action            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Action%TYPE,
   p_CC_Det_PF_Entered_Amt            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Entered_Amt%TYPE,
   p_CC_Det_PF_Func_Amt               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Func_Amt%TYPE,
   p_CC_Det_PF_Date                   IGC_CC_DET_PF_HISTORY.CC_Det_PF_Date%TYPE,
   p_CC_Det_PF_Billed_Amt             IGC_CC_DET_PF_HISTORY.CC_Det_PF_Billed_Amt%TYPE,
   p_CC_Det_PF_Unbilled_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Unbilled_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Date          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Date%TYPE,
   p_CC_Det_PF_Encmbrnc_Status        IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Status%TYPE,
   p_Last_Update_Date                 IGC_CC_DET_PF_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By                  IGC_CC_DET_PF_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login                IGC_CC_DET_PF_HISTORY.Last_Update_Login%TYPE,
   p_Creation_Date                    IGC_CC_DET_PF_HISTORY.Creation_Date%TYPE,
   p_Created_By                       IGC_CC_DET_PF_HISTORY.Created_By%TYPE,
   p_Attribute1                       IGC_CC_DET_PF_HISTORY.Attribute1%TYPE,
   p_Attribute2                       IGC_CC_DET_PF_HISTORY.Attribute2%TYPE,
   p_Attribute3                       IGC_CC_DET_PF_HISTORY.Attribute3%TYPE,
   p_Attribute4                       IGC_CC_DET_PF_HISTORY.Attribute4%TYPE,
   p_Attribute5                       IGC_CC_DET_PF_HISTORY.Attribute5%TYPE,
   p_Attribute6                       IGC_CC_DET_PF_HISTORY.Attribute6%TYPE,
   p_Attribute7                       IGC_CC_DET_PF_HISTORY.Attribute7%TYPE,
   p_Attribute8                       IGC_CC_DET_PF_HISTORY.Attribute8%TYPE,
   p_Attribute9                       IGC_CC_DET_PF_HISTORY.Attribute9%TYPE,
   p_Attribute10                      IGC_CC_DET_PF_HISTORY.Attribute10%TYPE,
   p_Attribute11                      IGC_CC_DET_PF_HISTORY.Attribute11%TYPE,
   p_Attribute12                      IGC_CC_DET_PF_HISTORY.Attribute12%TYPE,
   p_Attribute13                      IGC_CC_DET_PF_HISTORY.Attribute13%TYPE,
   p_Attribute14                      IGC_CC_DET_PF_HISTORY.Attribute14%TYPE,
   p_Attribute15                      IGC_CC_DET_PF_HISTORY.Attribute15%TYPE,
   p_Context                          IGC_CC_DET_PF_HISTORY.Context%TYPE,
   G_FLAG                      IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   l_Application_Id      NUMBER;
   l_MRC_Enabled         VARCHAR2(1);
   l_Conversion_Date     DATE;
   l_Set_Of_Books_Id     NUMBER;
   l_Org_Id              NUMBER(15);
   l_return_status       VARCHAR2(1);

   CURSOR C_DET_PF_HST_ROWID IS
     SELECT Rowid
       FROM IGC_CC_DET_PF_HISTORY
      WHERE CC_Det_PF_Line_Id     = p_CC_Det_PF_Line_Id
        AND CC_Det_PF_Version_Num = p_Det_PF_Version_Num;

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
       WHERE ICH.CC_HEADER_ID       = IAL.CC_HEADER_ID
         AND IDP.CC_ACCT_LINE_ID    = IAL.CC_ACCT_LINE_ID
         AND IDP.CC_DET_PF_LINE_ID  = p_CC_Det_Pf_Line_Id;


BEGIN

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

-- -----------------------------------------------------------------
-- Insert the DET PF line History record as requested.
-- -----------------------------------------------------------------
   INSERT
     INTO IGC_CC_DET_PF_HISTORY
             (CC_Det_PF_Line_Id,
              Parent_Det_PF_Line_Id,
              CC_Acct_Line_Id,
              Parent_Acct_Line_Id,
              CC_Det_PF_Line_Num,
              CC_Det_PF_Version_Num,
              CC_Det_PF_Version_Action,
              CC_Det_PF_Entered_Amt,
              CC_Det_PF_Func_Amt,
              CC_Det_PF_Date,
              CC_Det_PF_Billed_Amt,
              CC_Det_PF_Unbilled_Amt,
              CC_Det_PF_Encmbrnc_Amt,
              CC_Det_Pf_Encmbrnc_Date,
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
             (p_CC_Det_PF_Line_Id,
              p_Parent_Det_PF_Line_Id,
              p_CC_Acct_Line_Id,
              p_Parent_Acct_Line_Id,
              p_CC_Det_PF_Line_Num,
              p_Det_PF_Version_Num,
              p_Det_PF_Version_Action,
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
             );

-- -------------------------------------------------------------------
-- Obtain the ROWID of the record that was just inserted to return
-- to the caller.
-- -------------------------------------------------------------------

    OPEN C_DET_PF_HST_ROWID;
    FETCH C_DET_PF_HST_ROWID
     INTO p_Rowid;

    IF (C_DET_PF_HST_ROWID%NOTFOUND) THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;

    CLOSE C_DET_PF_HST_ROWID;

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
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_det_pf_info;

-- ------------------------------------------------------------------
-- If the conversion date is NULL then fill in the value with the
-- current system date.
-- ------------------------------------------------------------------

   gl_mc_info.mrc_enabled(
                        l_Set_Of_Books_Id,
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

-- ------------------------------------------------------------------
-- MRC Handler For IGC_CC_DET_PF to insert all MRC records for
-- the reporting set of books for this PRIMARY set of books.
-- ------------------------------------------------------------------
      IGC_CC_MC_MAIN_HST_PVT.get_rsobs_DET_PF(
                                 l_api_version,
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
                                 p_Det_PF_Version_Num,
                                 p_Det_PF_Version_Action
                                );

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
    IF (c_det_pf_hst_rowid%ISOPEN) THEN
       CLOSE c_det_pf_hst_rowid;
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
    IF (c_det_pf_hst_rowid%ISOPEN) THEN
       CLOSE c_det_pf_hst_rowid;
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
    IF (c_det_pf_hst_rowid%ISOPEN) THEN
       CLOSE c_det_pf_hst_rowid;
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

END Insert_Row;

/* ================================================================================
                         PROCEDURE Lock_Row
   ===============================================================================*/


PROCEDURE Lock_Row(
   p_api_version                  IN  NUMBER,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status                OUT NOCOPY VARCHAR2,
   X_msg_count                    OUT NOCOPY NUMBER,
   X_msg_data                     OUT NOCOPY VARCHAR2,
   p_Rowid                     IN OUT NOCOPY VARCHAR2,
   p_CC_Det_PF_Line_Id                IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Line_Num               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Num%TYPE,
   p_CC_Acct_Line_Id                  IGC_CC_DET_PF_HISTORY.CC_Acct_Line_Id%TYPE,
   p_Parent_Acct_Line_Id              IGC_CC_DET_PF_HISTORY.Parent_Acct_Line_Id%TYPE,
   p_Parent_Det_PF_Line_Id            IGC_CC_DET_PF_HISTORY.Parent_Det_PF_Line_Id%TYPE,
   p_Det_PF_Version_Num               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Num%TYPE,
   p_Det_PF_Version_Action            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Action%TYPE,
   p_CC_Det_PF_Entered_Amt            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Entered_Amt%TYPE,
   p_CC_Det_PF_Func_Amt               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Func_Amt%TYPE,
   p_CC_Det_PF_Date                   IGC_CC_DET_PF_HISTORY.CC_Det_PF_Date%TYPE,
   p_CC_Det_PF_Billed_Amt             IGC_CC_DET_PF_HISTORY.CC_Det_PF_Billed_Amt%TYPE,
   p_CC_Det_PF_Unbilled_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Unbilled_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Date          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Date%TYPE,
   p_CC_Det_PF_Encmbrnc_Status        IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Status%TYPE,
   p_Last_Update_Date                 IGC_CC_DET_PF_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By                  IGC_CC_DET_PF_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login                IGC_CC_DET_PF_HISTORY.Last_Update_Login%TYPE,
   p_Creation_Date                    IGC_CC_DET_PF_HISTORY.Creation_Date%TYPE,
   p_Created_By                       IGC_CC_DET_PF_HISTORY.Created_By%TYPE,
   p_Attribute1                       IGC_CC_DET_PF_HISTORY.Attribute1%TYPE,
   p_Attribute2                       IGC_CC_DET_PF_HISTORY.Attribute2%TYPE,
   p_Attribute3                       IGC_CC_DET_PF_HISTORY.Attribute3%TYPE,
   p_Attribute4                       IGC_CC_DET_PF_HISTORY.Attribute4%TYPE,
   p_Attribute5                       IGC_CC_DET_PF_HISTORY.Attribute5%TYPE,
   p_Attribute6                       IGC_CC_DET_PF_HISTORY.Attribute6%TYPE,
   p_Attribute7                       IGC_CC_DET_PF_HISTORY.Attribute7%TYPE,
   p_Attribute8                       IGC_CC_DET_PF_HISTORY.Attribute8%TYPE,
   p_Attribute9                       IGC_CC_DET_PF_HISTORY.Attribute9%TYPE,
   p_Attribute10                      IGC_CC_DET_PF_HISTORY.Attribute10%TYPE,
   p_Attribute11                      IGC_CC_DET_PF_HISTORY.Attribute11%TYPE,
   p_Attribute12                      IGC_CC_DET_PF_HISTORY.Attribute12%TYPE,
   p_Attribute13                      IGC_CC_DET_PF_HISTORY.Attribute13%TYPE,
   p_Attribute14                      IGC_CC_DET_PF_HISTORY.Attribute14%TYPE,
   p_Attribute15                      IGC_CC_DET_PF_HISTORY.Attribute15%TYPE,
   p_Context                          IGC_CC_DET_PF_HISTORY.Context%TYPE,
   X_row_locked                   OUT NOCOPY VARCHAR2,
   G_FLAG                      IN OUT NOCOPY VARCHAR2
) IS

   l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
   l_api_version         CONSTANT NUMBER         :=  1.0;
   Counter               NUMBER;

   CURSOR C IS
     SELECT *
       FROM IGC_CC_DET_PF_HISTORY
      WHERE Rowid = p_Rowid
        FOR UPDATE of CC_Det_PF_Line_Id NOWAIT;

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
               (Recinfo.CC_Det_PF_Line_Id =  p_CC_Det_PF_Line_Id)
           AND (Recinfo.CC_Det_PF_Line_Num =  p_CC_Det_PF_Line_Num)
           AND (Recinfo.CC_Acct_Line_Id =  p_CC_Acct_Line_Id)
           AND (Recinfo.CC_Det_PF_Version_Num =  p_Det_PF_Version_Num)
           AND (Recinfo.CC_Det_PF_Version_Action =  p_Det_PF_Version_Action)
           AND (   (Recinfo.Parent_Det_PF_Line_Id =  p_Parent_Det_PF_Line_Id)
                OR (    (Recinfo.Parent_Det_PF_Line_Id IS NULL)
                    AND (p_Parent_Det_PF_Line_Id IS NULL)))
           AND (   (Recinfo.Parent_Acct_Line_Id =  p_Parent_Acct_Line_Id)
                OR (    (Recinfo.Parent_Acct_Line_Id IS NULL)
                    AND (p_Parent_Acct_Line_Id IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Entered_Amt =  p_CC_Det_PF_Entered_Amt)
                OR (    (Recinfo.CC_Det_PF_Entered_Amt IS NULL)
                    AND (p_CC_Det_PF_Entered_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Func_Amt =  p_CC_Det_PF_Func_Amt)
                OR (    (Recinfo.CC_Det_PF_Func_Amt IS NULL)
                    AND (p_CC_Det_PF_Func_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Date =  p_CC_Det_PF_Date)
                OR (    (Recinfo.CC_Det_PF_Date IS NULL)
                    AND (p_CC_Det_PF_Date IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Billed_Amt =  p_CC_Det_PF_Billed_Amt)
                OR (    (Recinfo.CC_Det_PF_Billed_Amt IS NULL)
                    AND (p_CC_Det_PF_Billed_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_UnBilled_Amt =  p_CC_Det_PF_UnBilled_Amt )
                OR (    (Recinfo.CC_Det_PF_UnBilled_Amt  IS NULL)
                    AND (p_CC_Det_PF_UnBilled_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Encmbrnc_Amt =  p_CC_Det_PF_Encmbrnc_Amt)
                OR (    (Recinfo.CC_Det_PF_Encmbrnc_Amt IS NULL)
                    AND (p_CC_Det_PF_Encmbrnc_Amt IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Encmbrnc_Date =  p_CC_Det_PF_Encmbrnc_Date)
                OR (    (Recinfo.CC_Det_PF_Encmbrnc_Date IS NULL)
                    AND (p_CC_Det_PF_Encmbrnc_Date IS NULL)))
           AND (   (Recinfo.CC_Det_PF_Encmbrnc_Status =  p_CC_Det_PF_Encmbrnc_Status)
                OR (    (Recinfo.CC_Det_PF_Encmbrnc_Status IS NULL)
                    AND (p_CC_Det_PF_Encmbrnc_Status IS NULL)))
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
                         PROCEDURE Update_Row
   ===============================================================================*/

PROCEDURE Update_Row(
   p_api_version                  IN  NUMBER,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status                OUT NOCOPY VARCHAR2,
   X_msg_count                    OUT NOCOPY NUMBER,
   X_msg_data                     OUT NOCOPY VARCHAR2,
   p_Rowid                     IN OUT NOCOPY VARCHAR2,
   p_CC_Det_PF_Line_Id                IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Id%TYPE,
   p_CC_Det_PF_Line_Num               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Line_Num%TYPE,
   p_CC_Acct_Line_Id                  IGC_CC_DET_PF_HISTORY.CC_Acct_Line_Id%TYPE,
   p_Parent_Acct_Line_Id              IGC_CC_DET_PF_HISTORY.Parent_Acct_Line_Id%TYPE,
   p_Parent_Det_PF_Line_Id            IGC_CC_DET_PF_HISTORY.Parent_Det_PF_Line_Id%TYPE,
   p_Det_PF_Version_Num               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Num%TYPE,
   p_Det_PF_Version_Action            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Version_Action%TYPE,
   p_CC_Det_PF_Entered_Amt            IGC_CC_DET_PF_HISTORY.CC_Det_PF_Entered_Amt%TYPE,
   p_CC_Det_PF_Func_Amt               IGC_CC_DET_PF_HISTORY.CC_Det_PF_Func_Amt%TYPE,
   p_CC_Det_PF_Date                   IGC_CC_DET_PF_HISTORY.CC_Det_PF_Date%TYPE,
   p_CC_Det_PF_Billed_Amt             IGC_CC_DET_PF_HISTORY.CC_Det_PF_Billed_Amt%TYPE,
   p_CC_Det_PF_Unbilled_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Unbilled_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Amt           IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Amt%TYPE,
   p_CC_Det_PF_Encmbrnc_Date          IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Date%TYPE,
   p_CC_Det_PF_Encmbrnc_Status        IGC_CC_DET_PF_HISTORY.CC_Det_PF_Encmbrnc_Status%TYPE,
   p_Last_Update_Date                 IGC_CC_DET_PF_HISTORY.Last_Update_Date%TYPE,
   p_Last_Updated_By                  IGC_CC_DET_PF_HISTORY.Last_Updated_By%TYPE,
   p_Last_Update_Login                IGC_CC_DET_PF_HISTORY.Last_Update_Login%TYPE,
   p_Creation_Date                    IGC_CC_DET_PF_HISTORY.Creation_Date%TYPE,
   p_Created_By                       IGC_CC_DET_PF_HISTORY.Created_By%TYPE,
   p_Attribute1                       IGC_CC_DET_PF_HISTORY.Attribute1%TYPE,
   p_Attribute2                       IGC_CC_DET_PF_HISTORY.Attribute2%TYPE,
   p_Attribute3                       IGC_CC_DET_PF_HISTORY.Attribute3%TYPE,
   p_Attribute4                       IGC_CC_DET_PF_HISTORY.Attribute4%TYPE,
   p_Attribute5                       IGC_CC_DET_PF_HISTORY.Attribute5%TYPE,
   p_Attribute6                       IGC_CC_DET_PF_HISTORY.Attribute6%TYPE,
   p_Attribute7                       IGC_CC_DET_PF_HISTORY.Attribute7%TYPE,
   p_Attribute8                       IGC_CC_DET_PF_HISTORY.Attribute8%TYPE,
   p_Attribute9                       IGC_CC_DET_PF_HISTORY.Attribute9%TYPE,
   p_Attribute10                      IGC_CC_DET_PF_HISTORY.Attribute10%TYPE,
   p_Attribute11                      IGC_CC_DET_PF_HISTORY.Attribute11%TYPE,
   p_Attribute12                      IGC_CC_DET_PF_HISTORY.Attribute12%TYPE,
   p_Attribute13                      IGC_CC_DET_PF_HISTORY.Attribute13%TYPE,
   p_Attribute14                      IGC_CC_DET_PF_HISTORY.Attribute14%TYPE,
   p_Attribute15                      IGC_CC_DET_PF_HISTORY.Attribute15%TYPE,
   p_Context                          IGC_CC_DET_PF_HISTORY.Context%TYPE,
   G_FLAG                      IN OUT NOCOPY VARCHAR2
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

   UPDATE IGC_CC_DET_PF_HISTORY
      SET CC_Det_PF_Line_Id         =  p_CC_Det_PF_Line_Id,
          Parent_Det_PF_Line_Id     =  p_Parent_Det_PF_Line_Id,
          CC_Acct_Line_Id           =  p_CC_Acct_Line_Id,
          Parent_Acct_Line_Id       =  p_Parent_Acct_Line_Id,
          CC_Det_PF_Line_Num        =  p_CC_Det_PF_Line_Num,
          CC_Det_PF_Version_Num     =  p_Det_PF_Version_Num,
          CC_Det_PF_Version_Action  =  p_Det_PF_Version_Action,
          CC_Det_PF_Entered_Amt     =  p_CC_Det_PF_Entered_Amt,
          CC_Det_PF_Func_Amt        =  p_CC_Det_PF_Func_Amt,
          CC_Det_PF_Date            =  p_CC_Det_PF_Date,
          CC_Det_PF_Billed_Amt      =  p_CC_Det_PF_Billed_Amt,
          CC_Det_PF_Unbilled_Amt    =  p_CC_Det_PF_Unbilled_Amt,
          CC_Det_PF_Encmbrnc_Amt    =  p_CC_Det_PF_Encmbrnc_Amt,
          CC_Det_PF_Encmbrnc_Date   =  p_CC_Det_PF_Encmbrnc_Date,
          CC_Det_PF_Encmbrnc_Status =  p_CC_Det_PF_Encmbrnc_Status,
          Last_Update_Date          =  p_Last_Update_Date,
          Last_Updated_By           =  p_Last_Updated_By,
          Last_Update_Login         =  p_Last_Update_Login,
          Creation_Date             =  p_Creation_Date,
          Created_By                =  p_Created_By,
          Attribute1                =  p_Attribute1,
          Attribute2                =  p_Attribute2,
          Attribute3                =  p_Attribute3,
          Attribute4                =  p_Attribute4,
          Attribute5                =  p_Attribute5,
          Attribute6                =  p_Attribute6,
          Attribute7                =  p_Attribute7,
          Attribute8                =  p_Attribute8,
          Attribute9                =  p_Attribute9,
          Attribute10               =  p_Attribute10,
          Attribute11               =  p_Attribute11,
          Attribute12               =  p_Attribute12,
          Attribute13               =  p_Attribute13,
          Attribute14               =  p_Attribute14,
          Attribute15               =  p_Attribute15,
          Context                   =  p_Context
    WHERE rowid = p_Rowid;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
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
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level         IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   X_return_status            OUT NOCOPY VARCHAR2,
   X_msg_count                OUT NOCOPY NUMBER,
   X_msg_data                 OUT NOCOPY VARCHAR2,
   p_Rowid                        VARCHAR2,
   G_FLAG                  IN OUT NOCOPY VARCHAR2
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
     FROM IGC_CC_DET_PF_HISTORY
    WHERE rowid = p_Rowid;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
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

END IGC_CC_DET_PF_HISTORY_PKG;

/
