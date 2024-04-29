--------------------------------------------------------
--  DDL for Package Body IGC_CC_MC_DET_PF_HST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_MC_DET_PF_HST_PKG" as
/* $Header: IGCCMHDB.pls 120.3.12000000.1 2007/08/20 12:13:16 mbremkum ship $*/

 G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_MC_DET_PF_HST_PKG';
 g_debug_flag      VARCHAR2(1) := 'N' ;

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
                p_CC_DET_PF_Line_Id               IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Line_Id%TYPE,
                p_Set_Of_Books_Id                 IGC_CC_MC_DET_PF_HISTORY.Set_Of_Books_Id%TYPE,
                p_CC_DET_PF_Func_Amt              IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Func_Amt%TYPE,
                p_CC_DET_PF_Encmbrnc_Amt          IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Encmbrnc_Amt%TYPE,
                p_CC_DET_PF_version_num           IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_version_num%TYPE,
                p_CC_DET_PF_version_action        IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_version_action%TYPE,
                p_Conversion_Type                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Type%TYPE,
                p_Conversion_Date                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Date%TYPE,
                p_Conversion_Rate                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Rate%TYPE

              )

 IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  CURSOR c_det_pf_mrc_hst_rowid
         IS SELECT Rowid
            FROM   IGC_CC_MC_DET_PF_HISTORY
            WHERE  CC_DET_PF_Line_Id = p_CC_DET_PF_Line_Id;

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


    IF FND_API.to_Boolean (p_init_msg_list ) THEN
       FND_MSG_PUB.initialize ;
    END IF;

    X_return_status := FND_API.G_RET_STS_SUCCESS ;
-- -----------------------------------------------------------------
-- Insert the MRC DET PF line History record as requested.
-- -----------------------------------------------------------------
     INSERT INTO IGC_CC_MC_DET_PF_HISTORY (
               CC_DET_PF_Line_Id,
               Set_Of_Books_Id,
               CC_DET_PF_Func_Amt,
               CC_DET_PF_Encmbrnc_Amt,
               CC_DET_PF_version_num,
               CC_DET_PF_version_action,
               Conversion_Type,
               Conversion_Date,
               Conversion_Rate
           ) VALUES (
               p_CC_DET_PF_Line_Id,
               p_Set_Of_Books_Id,
               p_CC_DET_PF_Func_Amt,
               p_CC_DET_PF_Encmbrnc_Amt,
               p_CC_DET_PF_version_num,
               p_CC_DET_PF_version_action,
               p_Conversion_Type,
               p_Conversion_Date,
               p_Conversion_Rate
         );
-- -------------------------------------------------------------------
-- Obtain the ROWID of the record that was just inserted to return
-- to the caller.
-- -------------------------------------------------------------------
  OPEN  c_det_pf_mrc_hst_rowid;
  FETCH c_det_pf_mrc_hst_rowid
  INTO  p_Rowid;

  if (c_det_pf_mrc_hst_rowid%NOTFOUND) then
    CLOSE c_det_pf_mrc_hst_rowid;
    RAISE FND_API.G_EXC_ERROR ;
  end if;
  CLOSE c_det_pf_mrc_hst_rowid;
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
     IF (c_det_pf_mrc_hst_rowid%ISOPEN) THEN
         CLOSE c_det_pf_mrc_hst_rowid;
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO Insert_Row_Pvt ;
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (c_det_pf_mrc_hst_rowid%ISOPEN) THEN
         CLOSE c_det_pf_mrc_hst_rowid;
     END IF;

     FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                 p_data  => X_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO Insert_Row_Pvt ;
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (c_det_pf_mrc_hst_rowid%ISOPEN) THEN
         CLOSE c_det_pf_mrc_hst_rowid;
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
                p_api_version               IN    NUMBER,
                p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
                p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
                p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                X_return_status             OUT NOCOPY   VARCHAR2,
                X_msg_count                 OUT NOCOPY   NUMBER,
                X_msg_data                  OUT NOCOPY   VARCHAR2,
                p_Rowid                  IN OUT NOCOPY   VARCHAR2,
                p_CC_DET_PF_Line_Id               IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Line_Id%TYPE,
                p_Set_Of_Books_Id                 IGC_CC_MC_DET_PF_HISTORY.Set_Of_Books_Id%TYPE,
                p_CC_DET_PF_Func_Amt              IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Func_Amt%TYPE,
                p_CC_DET_PF_Encmbrnc_Amt          IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Encmbrnc_Amt%TYPE,
                p_CC_DET_PF_version_num           IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_version_num%TYPE,
                p_CC_DET_PF_version_action        IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_version_action%TYPE,
                p_Conversion_Type                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Type%TYPE,
                p_Conversion_Date                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Date%TYPE,
                p_Conversion_Rate                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Rate%TYPE,
                X_row_locked                OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  Counter               NUMBER;

  CURSOR C IS
      SELECT *
      FROM   IGC_CC_MC_DET_PF_HISTORY
      WHERE  rowid = p_Rowid
      FOR UPDATE of CC_DET_PF_Line_Id NOWAIT;
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

  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  end if;
  CLOSE C;
  if (
             (Recinfo.CC_DET_PF_Line_Id =  p_CC_DET_PF_Line_Id)
         AND (   (Recinfo.Set_Of_Books_Id =  p_Set_Of_Books_Id)
              OR (    (Recinfo.Set_Of_Books_Id IS NULL)
                  AND (p_Set_Of_Books_Id IS NULL)))
         AND (   (Recinfo.CC_DET_PF_Func_Amt = p_CC_DET_PF_Func_Amt)
              OR (    (Recinfo.CC_DET_PF_Func_Amt IS NULL)
                  AND (p_CC_DET_PF_Func_Amt IS NULL)))
         AND (   (Recinfo.CC_DET_PF_Encmbrnc_Amt = p_CC_DET_PF_Encmbrnc_Amt)
              OR (    (Recinfo.CC_DET_PF_Encmbrnc_Amt IS NULL)
                  AND (p_CC_DET_PF_Encmbrnc_Amt IS NULL)))
         AND (   (Recinfo.CC_DET_PF_version_num =  p_CC_DET_PF_version_num)
                OR (    (Recinfo.CC_DET_PF_version_num IS NULL)
                    AND (p_CC_DET_PF_version_num IS NULL)))
         AND (   (Recinfo.CC_DET_PF_version_action =  p_CC_DET_PF_version_action)
                OR (    (Recinfo.CC_DET_PF_version_action IS NULL)
                    AND (p_CC_DET_PF_version_action IS NULL)))
         AND (   (Recinfo.Conversion_Type =  p_Conversion_Type)
              OR (    (Recinfo.Conversion_Type IS NULL)
                  AND (p_Conversion_Type IS NULL)))
         AND (   (Recinfo.Conversion_Date =  p_Conversion_Date)
              OR (    (Recinfo.Conversion_Date IS NULL)
                  AND (p_Conversion_Date IS NULL)))
         AND (   (Recinfo.Conversion_Rate =  p_Conversion_Rate)
              OR (    (Recinfo.Conversion_Rate IS NULL)
                  AND (p_Conversion_Rate IS NULL)))

    ) then
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  end if;

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
                p_api_version               IN    NUMBER,
                p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
                p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
                p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                X_return_status             OUT NOCOPY   VARCHAR2,
                X_msg_count                 OUT NOCOPY   NUMBER,
                X_msg_data                  OUT NOCOPY   VARCHAR2,
                p_Rowid                  IN OUT NOCOPY   VARCHAR2,
                p_CC_DET_PF_Line_Id               IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Line_Id%TYPE,
                p_Set_Of_Books_Id                 IGC_CC_MC_DET_PF_HISTORY.Set_Of_Books_Id%TYPE,
                p_CC_DET_PF_Func_Amt              IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Func_Amt%TYPE,
                p_CC_DET_PF_Encmbrnc_Amt          IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_Encmbrnc_Amt%TYPE,
                p_CC_DET_PF_version_num           IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_version_num%TYPE,
                p_CC_DET_PF_version_action        IGC_CC_MC_DET_PF_HISTORY.CC_DET_PF_version_action%TYPE,
                p_Conversion_Type                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Type%TYPE,
                p_Conversion_Date                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Date%TYPE,
                p_Conversion_Rate                 IGC_CC_MC_DET_PF_HISTORY.Conversion_Rate%TYPE

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

  UPDATE IGC_CC_MC_DET_PF_HISTORY
  SET
                     CC_DET_PF_Line_Id            =      p_CC_DET_PF_Line_Id,
                     Set_Of_Books_Id              =      p_Set_Of_Books_Id,
		     CC_DET_PF_Func_Amt           =      p_CC_DET_PF_Func_Amt,
                     CC_DET_PF_Encmbrnc_Amt       =      p_CC_DET_PF_Encmbrnc_Amt,
                     CC_DET_PF_version_num       =     p_CC_DET_PF_version_num,
                     CC_DET_PF_version_action       =     p_CC_DET_PF_version_action,
                     Conversion_Type              =      p_Conversion_Type,
		     Conversion_Date              =      p_Conversion_Date,
		     Conversion_Rate              =      p_Conversion_Rate
  WHERE rowid = p_Rowid;
  if (SQL%NOTFOUND) then
    Raise NO_DATA_FOUND;
  end if;

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
p_api_version               IN       NUMBER,
p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
X_return_status             OUT NOCOPY      VARCHAR2,
X_msg_count                 OUT NOCOPY      NUMBER,
X_msg_data                  OUT NOCOPY      VARCHAR2,
p_Rowid                   IN OUT NOCOPY     VARCHAR2

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

DELETE FROM IGC_CC_MC_DET_PF_HISTORY
WHERE rowid = p_Rowid;

if (SQL%NOTFOUND) then
  Raise NO_DATA_FOUND;
end if;

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




END IGC_CC_MC_DET_PF_HST_PKG;

/
