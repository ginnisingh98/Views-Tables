--------------------------------------------------------
--  DDL for Package Body IGC_CC_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PERIODS_PKG" AS
/*$Header: IGCCCCPB.pls 120.3.12000000.2 2007/09/26 17:07:55 smannava ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_PERIODS_PKG';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1) := 'N' ;


/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/
PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,
  p_cc_period_status		       VARCHAR2,
  p_last_update_date                   DATE,
  p_last_updated_by                    NUMBER,
  p_last_update_login                  NUMBER,
  p_created_by                         NUMBER,
  p_creation_date                      DATE
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  CURSOR C IS SELECT ROWID FROM igc_cc_periods_all
              WHERE org_id = p_org_id
	      AND period_set_name = p_period_set_name
	      AND period_name = p_period_name;
BEGIN

  SAVEPOINT Insert_Row_Pvt ;

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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  INSERT INTO igc_cc_periods_all
              (
  		org_id,
  		period_set_name,
  		period_name,
  		cc_period_status,
  		last_update_date,
  		last_updated_by,
  		last_update_login,
  		created_by,
  		creation_date
              )
  VALUES
              (
  		p_org_id,
  		p_period_set_name,
  		p_period_name,
  		p_cc_period_status,
  		p_last_update_date,
  		p_last_updated_by,
  		p_last_update_login,
  		p_created_by,
  		p_creation_date
              );
  OPEN C;
  FETCH C INTO p_row_id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

END Insert_Row;
/*-------------------------------------------------------------------------*/



/*==========================================================================+
 |                       PROCEDURE Lock_Row                                 |
 +==========================================================================*/
PROCEDURE Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,
  p_cc_period_status		       VARCHAR2,

  p_row_locked                OUT NOCOPY      VARCHAR2

)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  Counter NUMBER;
  CURSOR C IS
       SELECT * FROM igc_cc_periods_all
       WHERE rowid = p_row_id
       FOR UPDATE NOWAIT;
  Recinfo 		C%ROWTYPE;

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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;

  OPEN C;

  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  IF (          (Recinfo.org_id = p_org_id)
	    AND (Recinfo.period_set_name = p_period_set_name)
	    AND (Recinfo.period_name = p_period_name)
            AND (       (Recinfo.cc_period_status = p_cc_period_status)
                     OR (       (Recinfo.cc_period_status IS NULL)
                            AND (p_cc_period_status IS NULL)))
      ) THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

END Lock_Row;
/* ----------------------------------------------------------------------- */




/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/
PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,
  p_cc_period_status		       VARCHAR2,
  p_last_update_date                   DATE,
  p_last_updated_by                    NUMBER,
  p_last_update_login                  NUMBER
)
IS

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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;


  UPDATE igc_cc_periods_all
  SET
  	org_id				=  p_org_id,
  	cc_period_status		=  p_cc_period_status,
        last_update_date        	=  p_last_update_date ,
        last_updated_by         	=  p_last_updated_by ,
        last_update_login       	=  p_last_update_login
  WHERE rowid = p_row_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

END Update_Row;
/* ----------------------------------------------------------------------- */




/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/
PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id	              IN       VARCHAR2
)
IS

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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Deleting the record in igc_cc_periods.

  DELETE FROM igc_cc_periods_all
  WHERE rowid = p_row_id;


  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

END Delete_Row;


/*==========================================================================+
 |                       PROCEDURE Check_Unique                             |
 +==========================================================================*/
PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,

  p_return_value              IN OUT NOCOPY   VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  l_tmp                 VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM  igc_cc_periods_all
    WHERE org_id = p_org_id
    AND period_set_name = p_period_set_name
    AND period_name = p_period_name
    AND  (
             p_row_id IS NULL
             OR
             rowid <> p_row_id
         );

BEGIN

  SAVEPOINT Check_Unique_Pvt ;

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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Checking the igc_cc_periods table for uniqueness.
  OPEN c;
  FETCH c INTO l_tmp;

  -- p_Return_Value specifies whether unique value exists or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );

END Check_Unique;
/* ----------------------------------------------------------------------- */

END IGC_CC_PERIODS_PKG;

/
