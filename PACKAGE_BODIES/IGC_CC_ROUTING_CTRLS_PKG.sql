--------------------------------------------------------
--  DDL for Package Body IGC_CC_ROUTING_CTRLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_ROUTING_CTRLS_PKG" as
/* $Header: IGCCCTLB.pls 120.3.12000000.2 2007/09/26 17:21:12 smannava ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGC_CC_ROUTING_CTRLS_PKG';
G_debug_flag VARCHAR2(1) := 'N';

/* ================================================================================
                         PROCEDURE Insert_Row
   ===============================================================================*/

  PROCEDURE Insert_Row(
                       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       x_return_status             OUT NOCOPY      VARCHAR2,
                       x_msg_count                 OUT NOCOPY      NUMBER,
                       x_msg_data                  OUT NOCOPY      VARCHAR2,
                       p_Rowid                    IN OUT NOCOPY    VARCHAR2,
                       p_ORG_ID                       IGC_CC_ROUTING_CTRLS_ALL.ORG_ID%TYPE,
                       p_CC_TYPE                      IGC_CC_ROUTING_CTRLS_ALL.CC_TYPE%TYPE,
                       p_CC_STATE                     IGC_CC_ROUTING_CTRLS_ALL.CC_STATE%TYPE,
                       p_CC_CAN_PRPR_APPRV_FLAG       IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_APPRV_FLAG%TYPE,
                       p_CC_CAN_PRPR_ENCMBR_FLAG      IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_ENCMBR_FLAG%TYPE,
                       p_wf_approval_itemtype         IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_ITEMTYPE%TYPE,
                       p_wf_approval_process          IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_PROCESS%TYPE,
                       p_DEFAULT_APPROVAL_PATH_ID     IGC_CC_ROUTING_CTRLS_ALL.DEFAULT_APPROVAL_PATH_ID%TYPE,
                       p_LAST_UPDATE_DATE             IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_DATE%TYPE,
                       p_LAST_UPDATE_LOGIN            IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_LOGIN%TYPE,
                       p_CREATION_DATE                IGC_CC_ROUTING_CTRLS_ALL.CREATION_DATE%TYPE,
                       p_LAST_UPDATED_BY              IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATED_BY%TYPE,
                       p_CREATED_BY                   IGC_CC_ROUTING_CTRLS_ALL.CREATED_BY%TYPE
  ) IS

    l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
    l_api_version         CONSTANT NUMBER         :=  1.0;

    CURSOR C IS SELECT rowid FROM IGC_CC_ROUTING_CTRLS_ALL
                 WHERE org_id = p_org_id;

   BEGIN

      SAVEPOINT Insert_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;


       INSERT INTO IGC_CC_ROUTING_CTRLS_ALL(

                       ORG_ID,
                       CC_TYPE,
                       CC_STATE,
                       CC_CAN_PRPR_APPRV_FLAG,
                       CC_CAN_PRPR_ENCMBR_FLAG,
                       WF_APPROVAL_ITEMTYPE,
                       WF_APPROVAL_PROCESS,
                       DEFAULT_APPROVAL_PATH_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATE_LOGIN,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       CREATED_BY )
       VALUES (
                       p_ORG_ID,
                       p_CC_TYPE,
                       p_CC_STATE,
                       p_CC_CAN_PRPR_APPRV_FLAG,
                       p_CC_CAN_PRPR_ENCMBR_FLAG,
                       p_WF_APPROVAL_ITEMTYPE,
                       p_WF_APPROVAL_PROCESS,
                       p_DEFAULT_APPROVAL_PATH_ID,
                       p_LAST_UPDATE_DATE,
                       p_LAST_UPDATE_LOGIN,
                       p_CREATION_DATE,
                       p_LAST_UPDATED_BY,
                       p_CREATED_BY
             );

    OPEN C;
    FETCH C INTO p_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE FND_API.G_EXC_ERROR ;
    end if;
    CLOSE C;

IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


  END Insert_Row;


  PROCEDURE Lock_Row(
                       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       x_return_status             OUT NOCOPY      VARCHAR2,
                       x_msg_count                 OUT NOCOPY      NUMBER,
                       x_msg_data                  OUT NOCOPY      VARCHAR2,

                       p_Rowid                IN OUT NOCOPY    VARCHAR2,
                       p_ORG_ID                       IGC_CC_ROUTING_CTRLS_ALL.ORG_ID%TYPE,
                       p_CC_TYPE                      IGC_CC_ROUTING_CTRLS_ALL.CC_TYPE%TYPE,
                       p_CC_STATE                     IGC_CC_ROUTING_CTRLS_ALL.CC_STATE%TYPE,
                       p_CC_CAN_PRPR_APPRV_FLAG       IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_APPRV_FLAG%TYPE,
                       p_CC_CAN_PRPR_ENCMBR_FLAG      IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_ENCMBR_FLAG%TYPE,
                       p_wf_approval_itemtype         IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_ITEMTYPE%TYPE,
                       p_wf_approval_process          IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_PROCESS%TYPE,
                       p_DEFAULT_APPROVAL_PATH_ID     IGC_CC_ROUTING_CTRLS_ALL.DEFAULT_APPROVAL_PATH_ID%TYPE,
                       p_LAST_UPDATE_DATE             IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_DATE%TYPE,
                       p_LAST_UPDATE_LOGIN            IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_LOGIN%TYPE,
                       p_CREATION_DATE                IGC_CC_ROUTING_CTRLS_ALL.CREATION_DATE%TYPE,
                       p_LAST_UPDATED_BY              IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATED_BY%TYPE,
                       p_CREATED_BY                   IGC_CC_ROUTING_CTRLS_ALL.CREATED_BY%TYPE,
                       p_row_locked                OUT NOCOPY      VARCHAR2
  ) IS

    l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
    l_api_version         CONSTANT NUMBER         :=  1.0;
    Counter NUMBER;
    CURSOR C IS
        SELECT *
        FROM   IGC_CC_ROUTING_CTRLS_ALL
        WHERE  rowid = p_Rowid
        FOR UPDATE of ORG_ID NOWAIT;
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

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;


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
               (Recinfo.ORG_ID =  p_ORG_ID)
           AND (   (Recinfo.CC_TYPE =  p_CC_TYPE)
                OR (    (Recinfo.CC_TYPE IS NULL)
                    AND (p_CC_TYPE IS NULL)))
           AND (   (Recinfo.CC_STATE =  p_CC_STATE)
                OR (    (Recinfo.CC_STATE IS NULL)
                    AND (p_CC_STATE IS NULL)))
           AND (   (Recinfo.CC_CAN_PRPR_APPRV_FLAG =  p_CC_CAN_PRPR_APPRV_FLAG)
                OR (    (Recinfo.CC_CAN_PRPR_APPRV_FLAG IS NULL)
                    AND (p_CC_CAN_PRPR_APPRV_FLAG IS NULL)))
           AND (   (Recinfo.CC_CAN_PRPR_ENCMBR_FLAG =  p_CC_CAN_PRPR_ENCMBR_FLAG)
                OR (    (Recinfo.CC_CAN_PRPR_ENCMBR_FLAG IS NULL)
                    AND (p_CC_CAN_PRPR_ENCMBR_FLAG IS NULL)))
           AND (   (Recinfo.LAST_UPDATE_DATE =  p_LAST_UPDATE_DATE)
                OR (    (Recinfo.LAST_UPDATE_DATE IS NULL)
                    AND (p_LAST_UPDATE_DATE IS NULL)))
           AND (   (Recinfo.LAST_UPDATE_LOGIN  =  p_LAST_UPDATE_LOGIN )
                OR (    (Recinfo.LAST_UPDATE_LOGIN  IS NULL)
                    AND (p_LAST_UPDATE_LOGIN  IS NULL)))
           AND (   (Recinfo.CREATION_DATE   =  p_CREATION_DATE  )
                OR (    (Recinfo.CREATION_DATE   IS NULL)
                    AND (p_CREATION_DATE   IS NULL)))
           AND (   (Recinfo.LAST_UPDATED_BY   =  p_LAST_UPDATED_BY  )
                OR (    (Recinfo.LAST_UPDATED_BY   IS NULL)
                    AND (p_LAST_UPDATED_BY   IS NULL)))
           AND (   (Recinfo.CREATED_BY   =  p_CREATED_BY  )
                OR (    (Recinfo.CREATED_BY   IS NULL)
                    AND (p_CREATED_BY   IS NULL)))

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
end if;

IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  END Lock_Row;


  PROCEDURE Update_Row(

                       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       x_return_status             OUT NOCOPY      VARCHAR2,
                       x_msg_count                 OUT NOCOPY      NUMBER,
                       x_msg_data                  OUT NOCOPY      VARCHAR2,

                       p_Rowid                IN OUT NOCOPY    VARCHAR2,
                       p_ORG_ID                       IGC_CC_ROUTING_CTRLS_ALL.ORG_ID%TYPE,
                       p_CC_TYPE                      IGC_CC_ROUTING_CTRLS_ALL.CC_TYPE%TYPE,
                       p_CC_STATE                     IGC_CC_ROUTING_CTRLS_ALL.CC_STATE%TYPE,
                       p_CC_CAN_PRPR_APPRV_FLAG       IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_APPRV_FLAG%TYPE,
                       p_CC_CAN_PRPR_ENCMBR_FLAG      IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_ENCMBR_FLAG%TYPE,
                       p_wf_approval_itemtype         IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_ITEMTYPE%TYPE,
                       p_wf_approval_process          IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_PROCESS%TYPE,
                       p_DEFAULT_APPROVAL_PATH_ID     IGC_CC_ROUTING_CTRLS_ALL.DEFAULT_APPROVAL_PATH_ID%TYPE,
                       p_LAST_UPDATE_DATE             IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_DATE%TYPE,
                       p_LAST_UPDATE_LOGIN            IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_LOGIN%TYPE,
                       p_CREATION_DATE                IGC_CC_ROUTING_CTRLS_ALL.CREATION_DATE%TYPE,
                       p_LAST_UPDATED_BY              IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATED_BY%TYPE,
                       p_CREATED_BY                   IGC_CC_ROUTING_CTRLS_ALL.CREATED_BY%TYPE
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

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

    UPDATE IGC_CC_ROUTING_CTRLS_ALL
    SET

                       ORG_ID                    =     p_ORG_ID,
                       CC_TYPE                   =     p_CC_TYPE,
                       CC_STATE                  =     p_CC_STATE,
                       CC_CAN_PRPR_APPRV_FLAG    =     p_CC_CAN_PRPR_APPRV_FLAG,
                       CC_CAN_PRPR_ENCMBR_FLAG   =     p_CC_CAN_PRPR_ENCMBR_FLAG,
                       WF_APPROVAL_ITEMTYPE      =     p_wf_approval_itemtype,
                       WF_APPROVAL_PROCESS       =     p_wf_approval_process,
                       DEFAULT_APPROVAL_PATH_ID  =     p_DEFAULT_APPROVAL_PATH_ID,
                       LAST_UPDATE_DATE          =     p_LAST_UPDATE_DATE,
                       LAST_UPDATE_LOGIN         =     p_LAST_UPDATE_LOGIN,
                       CREATION_DATE             =     p_CREATION_DATE,
                       LAST_UPDATED_BY           =     p_LAST_UPDATED_BY,
                       CREATED_BY                =     p_CREATED_BY
    WHERE rowid = p_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


  END Update_Row;


  PROCEDURE Delete_Row(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_Rowid                              VARCHAR2) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

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

  x_return_status := FND_API.G_RET_STS_SUCCESS ;


    DELETE FROM IGC_CC_ROUTING_CTRLS_ALL
    WHERE rowid = p_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


  END Delete_Row;


END IGC_CC_ROUTING_CTRLS_PKG;

/
