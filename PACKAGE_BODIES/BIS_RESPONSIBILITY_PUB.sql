--------------------------------------------------------
--  DDL for Package Body BIS_RESPONSIBILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RESPONSIBILITY_PUB" AS
/* $Header: BISPRSPB.pls 120.0 2005/05/31 18:09:32 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPRSPB.pls                                                      |
REM | PACKAGE                                                               |
REM |     BIS_RESPONSIBILITY_PUB                                            |
REM | DESCRIPTION                                                           |
REM |     Module: Private package that calls the FND packages to            |
REM |      insert records in the FND Responsibility table                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 07-MAR-2005 KRISHNA  Created.                                         |
REM +=======================================================================+
*/

PROCEDURE UPDATE_ROW(
   p_application_id         IN NUMBER
 , p_responsibility_id      IN NUMBER
 , p_menu_id                IN NUMBER
 , x_return_status          OUT NOCOPY VARCHAR2
 , x_msg_count              OUT NOCOPY NUMBER
 , x_msg_data               OUT NOCOPY VARCHAR2
) IS

l_responsibility_rec Responsibility_Rec_Type;

CURSOR cResponsibility IS
SELECT web_host_name,
       web_agent_name,
       data_group_application_id,
       data_group_id,
       start_date,
       end_date,
       group_application_id,
       request_group_id,
       version ,
       responsibility_key ,
       responsibility_name,
       description
FROM   fnd_responsibility_vl
WHERE  application_id    = p_application_id
AND    responsibility_id = p_responsibility_id;

BEGIN

    IF cResponsibility%ISOPEN THEN
        CLOSE cResponsibility;
    END IF;

    OPEN cResponsibility;
        FETCH cResponsibility INTO
        l_responsibility_rec.web_host_name,
        l_responsibility_rec.web_agent_name,
        l_responsibility_rec.data_group_application_id,
        l_responsibility_rec.data_group_id,
        l_responsibility_rec.start_date,
        l_responsibility_rec.end_date,
        l_responsibility_rec.group_application_id,
        l_responsibility_rec.request_group_id,
        l_responsibility_rec.version,
        l_responsibility_rec.responsibility_key,
        l_responsibility_rec.responsibility_name,
        l_responsibility_rec.description;
    CLOSE cResponsibility;
    --dbms_output.put_line( 'just before calling update row is');
    FND_RESPONSIBILITY_PKG.UPDATE_ROW(
            X_RESPONSIBILITY_ID          =>   p_responsibility_id
          , X_APPLICATION_ID             =>   p_application_id
          , X_WEB_HOST_NAME              =>   l_responsibility_rec.web_host_name
          , X_WEB_AGENT_NAME             =>   l_responsibility_rec.web_agent_name
          , X_DATA_GROUP_APPLICATION_ID  =>   l_responsibility_rec.data_group_application_id
          , X_DATA_GROUP_ID              =>   l_responsibility_rec.data_group_id
          , X_MENU_ID                    =>   p_menu_id
          , X_START_DATE                 =>   l_responsibility_rec.start_date
          , X_END_DATE                   =>   l_responsibility_rec.end_date
          , X_GROUP_APPLICATION_ID       =>   l_responsibility_rec.group_application_id
          , X_REQUEST_GROUP_ID           =>   l_responsibility_rec.request_group_id
          , X_VERSION                    =>   l_responsibility_rec.version
          , X_RESPONSIBILITY_KEY         =>   l_responsibility_rec.responsibility_key
          , X_RESPONSIBILITY_NAME        =>   l_responsibility_rec.responsibility_name
          , X_DESCRIPTION                =>   l_responsibility_rec.description
          , X_LAST_UPDATE_DATE           =>   sysdate
          , X_LAST_UPDATED_BY            =>   fnd_global.user_id
          , X_LAST_UPDATE_LOGIN          =>   fnd_global.user_id
      );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF(cResponsibility%ISOPEN) THEN
          CLOSE cResponsibility;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>  x_msg_count
                              ,p_data   =>  x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF(cResponsibility%ISOPEN) THEN
          CLOSE cResponsibility;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>  x_msg_count
                              ,p_data   =>  x_msg_data);
  WHEN NO_DATA_FOUND THEN
      IF(cResponsibility%ISOPEN) THEN
          CLOSE cResponsibility;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>  x_msg_count
                              ,p_data   =>  x_msg_data);
  WHEN OTHERS THEN
      IF(cResponsibility%ISOPEN) THEN
          CLOSE cResponsibility;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>  x_msg_count
                              ,p_data   =>  x_msg_data);
      IF (x_msg_data IS NULL) THEN
          x_msg_data := SQLERRM;
      END IF;

END UPDATE_ROW;


PROCEDURE LOCK_ROW
(  p_application_id         IN      NUMBER
 , p_responsibility_id      IN      NUMBER
 , p_last_update_date       IN      DATE
) IS

 l_last_update_date    DATE;

 CURSOR cResponsibility IS
 SELECT last_update_date
 FROM   fnd_responsibility
 WHERE  responsibility_id = p_responsibility_id
 AND    application_id    = p_application_id
 FOR    UPDATE OF menu_id NOWAIT;

BEGIN

    fnd_msg_pub.initialize;

    SAVEPOINT SP_LOCK_ROW;

    IF cResponsibility%ISOPEN THEN
       CLOSE cResponsibility;
    END IF;
    OPEN cResponsibility;
    FETCH cResponsibility INTO l_last_update_date;

    IF (cResponsibility%NOTFOUND) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_RESP_DELETED_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_last_update_date IS NOT NULL THEN
        IF p_last_update_date <> l_last_update_date THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_RESP_CHANGED_ERROR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    ROLLBACK TO SP_LOCK_ROW;
    CLOSE cResponsibility;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
      THEN NULL;
  WHEN OTHERS THEN
      IF(cResponsibility%ISOPEN) THEN
          CLOSE cResponsibility;
      END IF;
      ROLLBACK TO SP_LOCK_ROW;
      FND_MESSAGE.SET_NAME('BIS','BIS_RESP_LOCKED_ERROR');
      FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
END LOCK_ROW;

END BIS_RESPONSIBILITY_PUB;

/
