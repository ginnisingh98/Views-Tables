--------------------------------------------------------
--  DDL for Package Body IGC_CC_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_ACTIONS_PKG" as
/* $Header: IGCCACTB.pls 120.3.12000000.1 2007/08/20 12:10:44 mbremkum ship $  */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_ACTIONS_PKG';

g_debug_flag        VARCHAR2(1) := 'N' ;



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
                 p_CC_Header_Id                    IGC_CC_ACTIONS.CC_Header_Id%TYPE,
                 p_CC_Action_Version_Num           IGC_CC_ACTIONS.CC_Action_Version_Num%TYPE,
                 p_CC_Action_Type                  IGC_CC_ACTIONS.CC_Action_Type %TYPE,
                 p_CC_Action_State                 IGC_CC_ACTIONS.CC_Action_State%TYPE,
                 p_CC_Action_Ctrl_Status           IGC_CC_ACTIONS.CC_Action_Ctrl_Status%TYPE,
                 p_CC_Action_Apprvl_Status         IGC_CC_ACTIONS.CC_Action_Apprvl_Status%TYPE,
                 p_CC_Action_Notes                 IGC_CC_ACTIONS.CC_Action_Notes%TYPE,
                 p_Last_Update_Date                IGC_CC_ACTIONS.Last_Update_Date%TYPE,
	         p_Last_Updated_By                 IGC_CC_ACTIONS.Last_Updated_By%TYPE,
	         p_Last_Update_Login               IGC_CC_ACTIONS.Last_Update_Login%TYPE,
	         p_Creation_Date                   IGC_CC_ACTIONS.Creation_Date%TYPE,
                 p_Created_By                      IGC_CC_ACTIONS.Created_By%TYPE
                 ) IS

    l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
    l_api_version         CONSTANT NUMBER         :=  1.0;
    l_CC_Action_Num       IGC_CC_ACTIONS.CC_Action_Num%TYPE;
    CURSOR C IS
       SELECT Rowid
       FROM IGC_CC_ACTIONS
       WHERE CC_Header_Id = p_CC_Header_Id;

    CURSOR C1 IS
       SELECT NVL(MAX(CC_Action_Num),0)
       FROM IGC_CC_ACTIONS
       WHERE CC_Header_Id = p_CC_Header_Id;

   BEGIN

     SAVEPOINT Insert_Row_Pvt ;

     OPEN C1;
      FETCH C1 INTO l_CC_Action_Num;
      IF c1%NOTFOUND THEN l_CC_Action_Num := 0;
      END IF;
     CLOSE C1;


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


       INSERT INTO IGC_CC_ACTIONS(
                       CC_Header_Id,
                       CC_Action_Num,
                       CC_Action_Version_Num,
                       CC_Action_Type,
                       CC_Action_State,
                       CC_Action_Ctrl_Status,
                       CC_Action_Apprvl_Status,
                       CC_Action_Notes,
		       Last_Update_Date,
		       Last_Updated_By,
		       Last_Update_Login,
		       Creation_Date,
                       Created_By

             ) VALUES (
                       p_CC_Header_Id,
                       l_CC_Action_Num + 1,
                       p_CC_Action_Version_Num,
                       p_CC_Action_Type,
                       p_CC_Action_State,
                       p_CC_Action_Ctrl_Status,
                       p_CC_Action_Apprvl_Status,
                       p_CC_Action_Notes,
		       p_Last_Update_Date,
		       p_Last_Updated_By,
		       p_Last_Update_Login,
		       p_Creation_Date,
                       p_Created_By

                      );

    OPEN C;
    FETCH C INTO p_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                              p_data  => X_msg_data );

  EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => X_msg_count,
                                p_data  => X_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
                 p_CC_Header_Id                    IGC_CC_ACTIONS.CC_Header_Id%TYPE,
                 p_CC_Action_Num                   IGC_CC_ACTIONS.CC_Action_Num%TYPE,
                 p_CC_Action_Version_Num           IGC_CC_ACTIONS.CC_Action_Version_Num%TYPE,
                 p_CC_Action_Type                  IGC_CC_ACTIONS.CC_Action_Type %TYPE,
                 p_CC_Action_State                 IGC_CC_ACTIONS.CC_Action_State%TYPE,
                 p_CC_Action_Ctrl_Status           IGC_CC_ACTIONS.CC_Action_Ctrl_Status%TYPE,
                 p_CC_Action_Apprvl_Status         IGC_CC_ACTIONS.CC_Action_Apprvl_Status%TYPE,
                 p_CC_Action_Notes                 IGC_CC_ACTIONS.CC_Action_Notes%TYPE,
                 p_Last_Update_Date                IGC_CC_ACTIONS.Last_Update_Date%TYPE,
	         p_Last_Updated_By                 IGC_CC_ACTIONS.Last_Updated_By%TYPE,
	         p_Last_Update_Login               IGC_CC_ACTIONS.Last_Update_Login%TYPE,
	         p_Creation_Date                   IGC_CC_ACTIONS.Creation_Date%TYPE,
                 p_Created_By                      IGC_CC_ACTIONS.Created_By%TYPE,
                 X_row_locked                OUT NOCOPY   VARCHAR2
  ) IS

    l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
    l_api_version         CONSTANT NUMBER         :=  1.0;
    Counter NUMBER;

    CURSOR C IS
        SELECT *
        FROM   IGC_CC_ACTIONS
        WHERE  Rowid = p_Rowid
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

    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    end if;

    CLOSE C;

    if (
               (Recinfo.CC_Header_Id =  p_CC_Header_Id)
           AND (   (Recinfo.CC_Action_Num =  p_CC_Action_Num)
                OR (    (Recinfo.CC_Action_Num IS NULL)
                    AND (p_CC_Action_Num IS NULL)))
           AND (   (Recinfo.CC_Action_Version_Num =  p_CC_Action_Version_Num)
                OR (    (Recinfo.CC_Action_Version_Num IS NULL)
                    AND (p_CC_Action_Version_Num IS NULL)))
           AND (   (Recinfo.CC_Action_Type =  p_CC_Action_Type)
                OR (    (Recinfo.CC_Action_Type IS NULL)
                    AND (p_CC_Action_Type IS NULL)))
           AND (   (Recinfo.CC_Action_State =  p_CC_Action_State)
                OR (    (Recinfo.CC_Action_State IS NULL)
                    AND (p_CC_Action_State IS NULL)))
           AND (   (Recinfo.CC_Action_Ctrl_Status =  p_CC_Action_Ctrl_Status)
                OR (    (Recinfo.CC_Action_Ctrl_Status IS NULL)
                    AND (p_CC_Action_Ctrl_Status IS NULL)))
           AND (   (Recinfo.CC_Action_Apprvl_Status =  p_CC_Action_Apprvl_Status )
                OR (    (Recinfo.CC_Action_Apprvl_Status  IS NULL)
                    AND (p_CC_Action_Apprvl_Status IS NULL)))
           AND (   (Recinfo.CC_Action_Notes =  p_CC_Action_Notes)
                OR (    (Recinfo.CC_Action_Notes IS NULL)
                    AND (p_CC_Action_Notes IS NULL)))
           AND (   (Recinfo.Last_Update_Date =  p_Last_Update_Date)
                OR (    (Recinfo.Last_Update_Date IS NULL)
                    AND (p_Last_Update_Date IS NULL)))
           AND (   (Recinfo.Last_Updated_By =  p_Last_Updated_By)
                OR (    (Recinfo.Last_Updated_BY IS NULL)
                    AND (p_Last_Updated_By IS NULL)))
           AND (   (Recinfo.Last_Update_Login =  p_Last_Update_Login)
                OR (    (Recinfo.Last_Update_Login IS NULL)
                    AND (p_Last_Update_Login IS NULL)))
           AND (   (Recinfo.Created_By =  p_Created_By)
                OR (    (Recinfo.Created_By IS NULL)
                    AND (p_Created_By IS NULL)))
           AND (   (Recinfo.Creation_Date =  p_Creation_Date)
                OR (    (Recinfo.Creation_Date IS NULL)
                    AND (p_Creation_Date IS NULL)))
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
                 p_CC_Header_Id                    IGC_CC_ACTIONS.CC_Header_Id%TYPE,
                 p_CC_Action_Num                   IGC_CC_ACTIONS.CC_Action_Num%TYPE,
                 p_CC_Action_Version_Num           IGC_CC_ACTIONS.CC_Action_Version_Num%TYPE,
                 p_CC_Action_Type                  IGC_CC_ACTIONS.CC_Action_Type %TYPE,
                 p_CC_Action_State                 IGC_CC_ACTIONS.CC_Action_State%TYPE,
                 p_CC_Action_Ctrl_Status           IGC_CC_ACTIONS.CC_Action_Ctrl_Status%TYPE,
                 p_CC_Action_Apprvl_Status         IGC_CC_ACTIONS.CC_Action_Apprvl_Status%TYPE,
                 p_CC_Action_Notes                 IGC_CC_ACTIONS.CC_Action_Notes%TYPE,
	         p_Last_Update_Date                IGC_CC_ACTIONS.Last_Update_Date%TYPE,
	         p_Last_Updated_By                 IGC_CC_ACTIONS.Last_Updated_By%TYPE,
	         p_Last_Update_Login               IGC_CC_ACTIONS.Last_Update_Login%TYPE,
	         p_Creation_Date                   IGC_CC_ACTIONS.Creation_Date%TYPE,
                 p_Created_By                      IGC_CC_ACTIONS.Created_By%TYPE
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

    UPDATE IGC_CC_ACTIONS
    SET

                       CC_Header_Id              =       p_CC_Header_Id,
                       CC_Action_Num             =       p_CC_Action_Num,
                       CC_Action_Version_Num     =       p_CC_Action_Version_Num,
                       CC_Action_Type            =       p_CC_Action_Type,
                       CC_Action_State           =       p_CC_Action_State,
                       CC_Action_Ctrl_Status     =       p_CC_Action_Ctrl_Status,
                       CC_Action_Apprvl_Status   =       p_CC_Action_Apprvl_Status,
                       CC_Action_Notes           =       p_CC_Action_Notes,
		       Last_Update_Date          =       p_Last_Update_Date,
		       Last_Updated_By           =       p_Last_Updated_By,
		       Last_Update_Login         =       p_Last_Update_Login,
		       Creation_Date             =       p_Creation_Date,
                       Created_By                =       p_Created_By
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
                      p_Rowid                              VARCHAR2
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

    DELETE FROM IGC_CC_ACTIONS
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

END IGC_CC_ACTIONS_PKG;

/
