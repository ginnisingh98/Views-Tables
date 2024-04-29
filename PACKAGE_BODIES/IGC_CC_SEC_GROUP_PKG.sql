--------------------------------------------------------
--  DDL for Package Body IGC_CC_SEC_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_SEC_GROUP_PKG" as
/* $Header: IGCCSCGB.pls 120.6.12000000.1 2007/08/20 12:14:38 mbremkum ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_SEC_GROUP_PKG';

PROCEDURE Insert_Row(  p_api_version        IN       NUMBER,
  		p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  		p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  		p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		p_return_status             OUT NOCOPY      VARCHAR2,
  		p_msg_count                 OUT NOCOPY      NUMBER,
  		p_msg_data                  OUT NOCOPY      VARCHAR2,

		P_ROWID 			IN OUT NOCOPY VARCHAR2,
                P_CC_GROUP_ID              NUMBER,
                P_SET_OF_BOOKS_ID          NUMBER,
                P_CC_GROUP_NAME            VARCHAR2,
                P_CC_GROUP_DESC            VARCHAR2,
                P_CONTEXT	           VARCHAR2,
                P_ATTRIBUTE1               VARCHAR2,
                P_ATTRIBUTE2               VARCHAR2,
                P_ATTRIBUTE3               VARCHAR2,
                P_ATTRIBUTE4               VARCHAR2,
                P_ATTRIBUTE5               VARCHAR2,
                P_ATTRIBUTE6               VARCHAR2,
                P_ATTRIBUTE7               VARCHAR2,
                P_ATTRIBUTE8               VARCHAR2,
                P_ATTRIBUTE9               VARCHAR2,
                P_ATTRIBUTE10              VARCHAR2,
                P_ATTRIBUTE11              VARCHAR2,
                P_ATTRIBUTE12              VARCHAR2,
                P_ATTRIBUTE13              VARCHAR2,
                P_ATTRIBUTE14              VARCHAR2,
                P_ATTRIBUTE15              VARCHAR2,
                P_LAST_UPDATE_DATE         DATE,
                P_LAST_UPDATED_BY          NUMBER,
                P_CREATION_DATE   	   DATE,
                P_CREATED_BY               NUMBER,
                P_LAST_UPDATE_LOGIN        NUMBER
	    ) IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

	CURSOR C IS SELECT ROWID FROM IGC_CC_GROUPS
		    WHERE CC_GROUP_ID = P_CC_GROUP_ID
		    AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID;
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


	INSERT INTO IGC_CC_GROUPS(
			CC_GROUP_ID,
			SET_OF_BOOKS_ID,
			CC_GROUP_NAME,
			CC_GROUP_DESC,
			CONTEXT,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN) VALUES(
			P_CC_GROUP_ID,
			P_SET_OF_BOOKS_ID,
			P_CC_GROUP_NAME,
			P_CC_GROUP_DESC,
			P_CONTEXT,
			P_ATTRIBUTE1,
			P_ATTRIBUTE2,
			P_ATTRIBUTE3,
			P_ATTRIBUTE4,
			P_ATTRIBUTE5,
			P_ATTRIBUTE6,
			P_ATTRIBUTE7,
			P_ATTRIBUTE8,
			P_ATTRIBUTE9,
			P_ATTRIBUTE10,
			P_ATTRIBUTE11,
			P_ATTRIBUTE12,
			P_ATTRIBUTE13,
			P_ATTRIBUTE14,
			P_ATTRIBUTE15,
			P_LAST_UPDATE_DATE,
			P_LAST_UPDATED_BY,
			P_CREATION_DATE,
			P_CREATED_BY,
			P_LAST_UPDATE_LOGIN
			);
	OPEN C;
	FETCH C INTO P_ROWID;
	IF (C%NOTFOUND) THEN
	  CLOSE C;
	  Raise NO_DATA_FOUND;
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

PROCEDURE Update_Row(  p_api_version        IN       NUMBER,
  		p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  		p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  		p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		p_return_status             OUT NOCOPY      VARCHAR2,
  		p_msg_count                 OUT NOCOPY      NUMBER,
  		p_msg_data                  OUT NOCOPY      VARCHAR2,

	        P_ROWID			   VARCHAR2,
                P_CC_GROUP_ID              NUMBER,
                P_SET_OF_BOOKS_ID          NUMBER,
                P_CC_GROUP_NAME            VARCHAR2,
                P_CC_GROUP_DESC            VARCHAR2,
                P_CONTEXT	           VARCHAR2,
                P_ATTRIBUTE1               VARCHAR2,
                P_ATTRIBUTE2               VARCHAR2,
                P_ATTRIBUTE3               VARCHAR2,
                P_ATTRIBUTE4               VARCHAR2,
                P_ATTRIBUTE5               VARCHAR2,
                P_ATTRIBUTE6               VARCHAR2,
                P_ATTRIBUTE7               VARCHAR2,
                P_ATTRIBUTE8               VARCHAR2,
                P_ATTRIBUTE9               VARCHAR2,
                P_ATTRIBUTE10              VARCHAR2,
                P_ATTRIBUTE11              VARCHAR2,
                P_ATTRIBUTE12              VARCHAR2,
                P_ATTRIBUTE13              VARCHAR2,
                P_ATTRIBUTE14              VARCHAR2,
                P_ATTRIBUTE15              VARCHAR2,
                P_LAST_UPDATE_DATE         DATE,
                P_LAST_UPDATED_BY          NUMBER,
                P_LAST_UPDATE_LOGIN        NUMBER
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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

 UPDATE IGC_CC_GROUPS
 SET
	CC_GROUP_ID		= P_CC_GROUP_ID,
	SET_OF_BOOKS_ID		= P_SET_OF_BOOKS_ID,
	CC_GROUP_NAME		= P_CC_GROUP_NAME,
	CC_GROUP_DESC		= P_CC_GROUP_DESC,
	CONTEXT	        	= P_CONTEXT,
	ATTRIBUTE1		= P_ATTRIBUTE1,
	ATTRIBUTE2		= P_ATTRIBUTE2,
	ATTRIBUTE3		= P_ATTRIBUTE3,
	ATTRIBUTE4		= P_ATTRIBUTE4,
	ATTRIBUTE5		= P_ATTRIBUTE5,
	ATTRIBUTE6		= P_ATTRIBUTE6,
	ATTRIBUTE7		= P_ATTRIBUTE7,
	ATTRIBUTE8		= P_ATTRIBUTE8,
	ATTRIBUTE9		= P_ATTRIBUTE9,
	ATTRIBUTE10		= P_ATTRIBUTE10,
	ATTRIBUTE11		= P_ATTRIBUTE11,
	ATTRIBUTE12		= P_ATTRIBUTE12,
	ATTRIBUTE13		= P_ATTRIBUTE13,
	ATTRIBUTE14		= P_ATTRIBUTE14,
	ATTRIBUTE15		= P_ATTRIBUTE15,
	LAST_UPDATE_DATE	= P_LAST_UPDATE_DATE,
	LAST_UPDATED_BY		= P_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN	= P_LAST_UPDATE_LOGIN
 WHERE ROWID = P_ROWID;

 IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
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


PROCEDURE Lock_Row(  p_api_version          IN       NUMBER,
  		p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  		p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  		p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		p_return_status             OUT NOCOPY      VARCHAR2,
  		p_msg_count                 OUT NOCOPY      NUMBER,
  		p_msg_data                  OUT NOCOPY      VARCHAR2,


		 P_ROWID		  VARCHAR2,
                 P_CC_GROUP_ID            NUMBER,
                 P_SET_OF_BOOKS_ID        NUMBER,
                 P_CC_GROUP_NAME          VARCHAR2,
                 P_CC_GROUP_DESC          VARCHAR2,
                 P_CONTEXT	          VARCHAR2,
                 P_ATTRIBUTE1             VARCHAR2,
                 P_ATTRIBUTE2             VARCHAR2,
                 P_ATTRIBUTE3             VARCHAR2,
                 P_ATTRIBUTE4             VARCHAR2,
                 P_ATTRIBUTE5             VARCHAR2,
                 P_ATTRIBUTE6             VARCHAR2,
                 P_ATTRIBUTE7             VARCHAR2,
                 P_ATTRIBUTE8             VARCHAR2,
                 P_ATTRIBUTE9             VARCHAR2,
                 P_ATTRIBUTE10            VARCHAR2,
                 P_ATTRIBUTE11            VARCHAR2,
                 P_ATTRIBUTE12            VARCHAR2,
                 P_ATTRIBUTE13            VARCHAR2,
                 P_ATTRIBUTE14            VARCHAR2,
                 P_ATTRIBUTE15            VARCHAR2,
  		 p_row_locked    OUT NOCOPY      VARCHAR2
		 ) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

	CURSOR C IS
		SELECT  cc_group_id,
			set_of_books_id,
			cc_group_name,
			cc_group_desc,
			context,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15
		FROM  IGC_CC_GROUPS
		WHERE ROWID = P_ROWID
		for UPDATE OF CC_GROUP_ID NOWAIT;
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

  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;

  OPEN C;
  FETCH C INTO Recinfo;
   IF (C%NOTFOUND) THEN
   CLOSE C;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   APP_EXCEPTION.Raise_Exception;
   END IF;
  CLOSE C;
  IF (
       	    (recinfo.CC_GROUP_ID = P_CC_GROUP_ID)
	AND (recinfo.CC_GROUP_NAME = P_CC_GROUP_NAME)
	AND (recinfo.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID)

	AND ((recinfo.CC_GROUP_DESC = P_CC_GROUP_DESC)
	     OR ((recinfo.CC_GROUP_DESC IS NULL)
		AND (P_CC_GROUP_DESC IS NULL)))
	AND ((recinfo.CONTEXT = P_CONTEXT)
	     OR ((recinfo.CONTEXT IS NULL)
		AND (P_CONTEXT IS NULL)))
        AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
                OR ((recinfo.ATTRIBUTE1 IS NULL)
                     AND (P_ATTRIBUTE1 IS NULL)))
        AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
                OR ((recinfo.ATTRIBUTE2 IS NULL)
                     AND (P_ATTRIBUTE2 IS NULL)))
        AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
                OR ((recinfo.ATTRIBUTE3 IS NULL)
                     AND (P_ATTRIBUTE3 IS NULL)))
        AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
                OR ((recinfo.ATTRIBUTE4 IS NULL)
                     AND (P_ATTRIBUTE4 IS NULL)))
        AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
                OR ((recinfo.ATTRIBUTE5 IS NULL)
                     AND (P_ATTRIBUTE5 IS NULL)))
        AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
                OR ((recinfo.ATTRIBUTE6 IS NULL)
                     AND (P_ATTRIBUTE6 IS NULL)))
        AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
                OR ((recinfo.ATTRIBUTE7 IS NULL)
                     AND (P_ATTRIBUTE7 IS NULL)))
        AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
                OR ((recinfo.ATTRIBUTE8 IS NULL)
                     AND (P_ATTRIBUTE8 IS NULL)))
        AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
                OR ((recinfo.ATTRIBUTE9 IS NULL)
                     AND (P_ATTRIBUTE9 IS NULL)))
        AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
                OR ((recinfo.ATTRIBUTE10 IS NULL)
                     AND (P_ATTRIBUTE10 IS NULL)))
        AND ((recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
                OR ((recinfo.ATTRIBUTE11 IS NULL)
                     AND (P_ATTRIBUTE11 IS NULL)))
        AND ((recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
                OR ((recinfo.ATTRIBUTE12 IS NULL)
                     AND (P_ATTRIBUTE12 IS NULL)))
        AND ((recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
                OR ((recinfo.ATTRIBUTE13 IS NULL)
                     AND (P_ATTRIBUTE13 IS NULL)))
        AND ((recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
                OR ((recinfo.ATTRIBUTE14 IS NULL)
                     AND (P_ATTRIBUTE14 IS NULL)))
        AND ((recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
                OR ((recinfo.ATTRIBUTE15 IS NULL)
                     AND (P_ATTRIBUTE15 IS NULL)))
	) THEN
	RETURN;
   ELSE
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    	FND_MSG_PUB.Add;
    	RAISE FND_API.G_EXC_ERROR ;
   -- APP_EXCEPTION.RAISE_EXCEPTION;
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



PROCEDURE Delete_Row(  p_api_version IN       NUMBER,
  	p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  	p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  	p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  	p_return_status              OUT NOCOPY      VARCHAR2,
  	p_msg_count                  OUT NOCOPY      NUMBER,
  	p_msg_data                   OUT NOCOPY      VARCHAR2,

	P_ROWID 			      VARCHAR2) IS

  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version             CONSTANT NUMBER         :=  1.0;

  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;

 x_cc_group_id NUMBER;

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

  BEGIN
	SELECT cc_group_id
	INTO   x_cc_group_id
	FROM   IGC_CC_GROUPS
	WHERE  rowid = p_rowid;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE;
  END;


/* Delete IGC_CC_GROUP_USERS - Master - Detail Record */
  DELETE FROM IGC_CC_GROUP_USERS
  WHERE cc_group_id = x_cc_group_id;

  IF (SQL%NOTFOUND) THEN
  RAISE NO_DATA_FOUND;
  END IF;

/* Delete IGC_CC_GROUPS - Master Record */
  DELETE FROM IGC_CC_GROUPS
  WHERE cc_group_id = x_cc_group_id;

  IF (SQL%NOTFOUND) THEN
  RAISE NO_DATA_FOUND;
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
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );


END DELETE_ROW;

PROCEDURE CHECK_UNIQUE(
--        p_api_version               IN       NUMBER,
--        p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
--        p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
--        p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--        p_return_status             OUT NOCOPY      VARCHAR2,
--        p_msg_count                 OUT NOCOPY      NUMBER,
--        p_msg_data                  OUT NOCOPY      VARCHAR2,

        P_ROWID  VARCHAR2,
        P_GROUP_NAME VARCHAR2,
        P_SOB_ID NUMBER)
IS

--  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
--  l_api_version         CONSTANT NUMBER         :=  1.0;

--  l_tmp                 VARCHAR2(1);


 DUMMY NUMBER;

  BEGIN


--  SAVEPOINT Check_Unique_Pvt ;
--  IF NOT FND_API.Compatible_API_Call ( l_api_version,
--                                       p_api_version,
--                                       l_api_name,
--                                       G_PKG_NAME )
--  THEN
--    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
--  END IF;


--  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
--    FND_MSG_PUB.initialize ;
--  END IF;

--  p_return_status := FND_API.G_RET_STS_SUCCESS ;

        SELECT COUNT(1)
         INTO DUMMY
         FROM IGC_CC_GROUPS
         WHERE CC_GROUP_NAME = P_GROUP_NAME AND
               SET_OF_BOOKS_ID = P_SOB_ID AND
             ((P_ROWID IS NULL) OR (ROWID <> P_ROWID));
--      dbms_output.put_line('DUMMY '||dummy);

        IF (DUMMY >= 1) THEN
--      FND_MESSAGE.SET_NAME('FND', 'EXPORT-NONE');
        FND_MESSAGE.SET_NAME('IGC', 'IGC_CC_UNIQUE_EVENT');
--      FND_MESSAGE.ERROR;
        APP_EXCEPTION.RAISE_EXCEPTION;

        END IF;

--  IF FND_API.To_Boolean ( p_commit ) THEN
--    COMMIT WORK;

--  END IF;

--  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
--                              p_data  => p_msg_data );
--

/* EXCEPTION

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
*/

END CHECK_UNIQUE;


END IGC_CC_SEC_GROUP_PKG ;

/
