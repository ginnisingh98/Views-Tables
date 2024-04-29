--------------------------------------------------------
--  DDL for Package Body IEU_SH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_SH_PVT" AS
/* $Header: IEUSHVB.pls 115.19 2004/07/23 10:19:31 nveerara ship $ */
PROCEDURE UWQ_BEGIN_SESSION
( P_API_VERSION               IN NUMBER,
  P_INIT_MSG_LIST             IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_COMMIT                    IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_RESOURCE_ID               IN NUMBER,
  P_USER_ID                   IN NUMBER,
  P_LOGIN_ID                  IN NUMBER   DEFAULT NULL,
  P_EXTENSION                 IN VARCHAR2 DEFAULT NULL,
  P_APPLICATION_ID            IN NUMBER,
  X_SESSION_ID                OUT NOCOPY NUMBER,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'UWQ_BEGIN_SESSION';

  l_token_str          VARCHAR2(4000) := '';

  l_end_date_time  DATE;

  l_object_version_number NUMBER;
  l_active_flag           VARCHAR2(1);
BEGIN
      l_object_version_number := 1;
      l_active_flag := 'T';

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      INSERT INTO IEU_SH_SESSIONS (
       SESSION_ID,
       OBJECT_VERSION_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       RESOURCE_ID,
       BEGIN_DATE_TIME,
       END_DATE_TIME,
       ACTIVE_FLAG,
       EXTENSION,
       APPLICATION_ID
     ) values
     (
       IEU_SH_SESSIONS_S1.NEXTVAL,
       l_object_version_number,
       P_USER_ID,
       SYSDATE,
       P_USER_ID,
       SYSDATE,
       P_LOGIN_ID,
       P_RESOURCE_ID,
       SYSDATE,
       NULL,
       l_active_flag,
       P_EXTENSION,
       P_APPLICATION_ID)
     RETURNING SESSION_ID INTO X_SESSION_ID;

     if (sql%notfound) then
        x_return_status := fnd_api.g_ret_sts_error;
      end if;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := 'USER_ID : '||p_user_id||
                        ' RESOURCE_ID : '||p_resource_id;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_SESSION_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_SH_PVT.UWQ_BEGIN_SESSION');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      COMMIT;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UWQ_BEGIN_SESSION;

PROCEDURE UWQ_END_SESSION
( P_API_VERSION               IN NUMBER,
  P_INIT_MSG_LIST             IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_COMMIT                    IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_SESSION_ID                IN NUMBER,
  P_END_REASON_CODE           IN VARCHAR2 DEFAULT NULL,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2 ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'UWQ_END_SESSION';

  l_token_str          VARCHAR2(4000) := '';

BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      update IEU_SH_SESSIONS set
       OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
       END_DATE_TIME = SYSDATE,
       ACTIVE_FLAG = NULL,
       END_REASON_CODE = P_END_REASON_CODE,
       FORCE_CLOSED_BY_UWQ_FLAG = 'N',
	  LAST_UPDATE_DATE = SYSDATE
      WHERE SESSION_ID = P_SESSION_ID;

      if (sql%notfound) then
        x_return_status := fnd_api.g_ret_sts_error;
      end if;


      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := 'SESSION_ID : '||p_session_id;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_END_SESSION_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_SH_PVT.UWQ_END_SESSION');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      COMMIT;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;
END UWQ_END_SESSION;

PROCEDURE UWQ_BEGIN_ACTIVITY
( P_API_VERSION               IN NUMBER,
  P_INIT_MSG_LIST             IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_COMMIT                    IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_SESSION_ID                IN NUMBER,
--  P_ACTIVITY_TYPE_ID          IN NUMBER,
  P_ACTIVITY_TYPE_CODE        IN VARCHAR2,
  P_LAST_ACTIVITY_ID          IN NUMBER   DEFAULT NULL,
  P_BEGIN_TIME_FLAG           IN NUMBER   DEFAULT NULL,
  P_MEDIA_TYPE_ID             IN NUMBER   DEFAULT NULL,
  P_MEDIA_ID                  IN NUMBER   DEFAULT NULL,
  P_USER_ID                   IN NUMBER,
  P_LOGIN_ID                  IN NUMBER   DEFAULT NULL,
  P_REASON_CODE               IN VARCHAR2 DEFAULT NULL,
  P_REQUEST_METHOD            IN VARCHAR2 DEFAULT NULL,
  P_REQUESTED_MEDIA_TYPE_ID   IN NUMBER   DEFAULT NULL,
  P_WORK_ITEM_TYPE_CODE       IN VARCHAR2 DEFAULT NULL,
  P_WORK_ITEM_PK_ID           IN NUMBER   DEFAULT NULL,
  P_END_ACTIVITY_FLAG         IN VARCHAR2 DEFAULT NULL,
  P_PARENT_CYCLE_ID           IN NUMBER   DEFAULT NULL,
  P_CATEGORY_TYPE             IN VARCHAR2 DEFAULT NULL,
  P_CATEGORY_VALUE            IN VARCHAR2 DEFAULT NULL,
  X_ACTIVITY_ID               OUT NOCOPY NUMBER,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'UWQ_BEGIN_ACTIVITY';

  l_token_str          VARCHAR2(4000) := '';

  l_return_status varchar2(5);
  l_msg_count number;
  l_msg_data varchar2(1000);

  l_begin_date_time DATE;
  l_last_activity_id NUMBER;

  l_end_date_time  DATE;
  l_active_flag    VARCHAR2(1);

  l_activity_type_id  NUMBER;

BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      UPDATE ieu_sh_sessions
      SET    active_flag = 'Y',
             end_date_time = NULL
      WHERE  session_id = p_session_id
      AND    end_date_time is not null
      AND    active_flag <> 'Y';

      BEGIN

         SELECT activity_type_id
         INTO   l_activity_type_id
         FROM   ieu_sh_act_types_b
         WHERE  activity_type_code = p_activity_type_code;

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      -- changes for correcting reports..
      -- 0 OR NULL means we have to use db native time
      -- 1 means we have to use previous activity time
      -- 2 means we have to use previous cycle time
      IF ( P_BEGIN_TIME_FLAG = 1 )
      THEN
        l_last_activity_id := P_LAST_ACTIVITY_ID;
      ELSIF ( P_BEGIN_TIME_FLAG = 2 )
      THEN
        l_last_activity_id := P_PARENT_CYCLE_ID;
      END IF;

      -- the default begin_date_time is the current systime
      SELECT SYSDATE INTO l_begin_date_time FROM DUAL;

      -- if this is the first activity in the cycle then get the begin_date_time
      -- for the cycle
      -- if this is an intermediate activity get the end_date_time of the
      -- previous activity if there is an error default to the current time
      if ( l_last_activity_id IS NOT NULL )
      THEN
        IF ( P_BEGIN_TIME_FLAG = 1 )
        THEN
          SELECT END_DATE_TIME INTO l_begin_date_time FROM IEU_SH_ACTIVITIES
            WHERE ACTIVITY_ID = l_last_activity_id;
        ELSIF ( P_BEGIN_TIME_FLAG = 2 )
        THEN
          SELECT BEGIN_DATE_TIME INTO l_begin_date_time FROM IEU_SH_ACTIVITIES
            WHERE ACTIVITY_ID = l_last_activity_id;
        END IF;
      END IF;

      -- end changes for correcting reports

      INSERT INTO IEU_SH_ACTIVITIES (
       ACTIVITY_ID,
       SESSION_ID,
       ACTIVITY_TYPE_ID,
       ACTIVITY_TYPE_CODE,
       MEDIA_TYPE_ID,
       MEDIA_ID,
       OBJECT_VERSION_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       BEGIN_DATE_TIME,
       END_DATE_TIME,
       ACTIVE_FLAG,
       REASON_CODE,
       REQUEST_METHOD,
       REQUESTED_MEDIA_TYPE_ID,
       WORK_ITEM_TYPE_CODE,
       WORK_ITEM_PK_ID,
       STATE_CODE,
       PARENT_CYCLE_ID,
       CATEGORY_TYPE,
       CATEGORY_VALUE
      ) values
      (
       IEU_SH_ACTIVITIES_S1.NEXTVAL,
       P_SESSION_ID,
       L_ACTIVITY_TYPE_ID,
       P_ACTIVITY_TYPE_CODE,
       P_MEDIA_TYPE_ID,
       P_MEDIA_ID,
       1,
       P_USER_ID,
       l_begin_date_time,
       P_USER_ID,
       l_begin_date_time,
       P_LOGIN_ID,
       l_begin_date_time,
       NULL,
       'T',
       P_REASON_CODE,
       P_REQUEST_METHOD,
       P_REQUESTED_MEDIA_TYPE_ID,
       P_WORK_ITEM_TYPE_CODE,
       P_WORK_ITEM_PK_ID,
       'BEGIN',
       P_PARENT_CYCLE_ID,
       P_CATEGORY_TYPE,
       P_CATEGORY_VALUE)
       RETURNING ACTIVITY_ID INTO X_ACTIVITY_ID;

      if (sql%notfound) then
        x_return_status := fnd_api.g_ret_sts_error;
         l_token_str := 'USER_ID : '|| p_user_id ||
                        ' SESSION_ID : '||p_session_id;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_ACTIVITY_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_SH_PVT.UWQ_BEGIN_ACTIVITY');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      end if;

      COMMIT;

      -- A NON_MEDIA activity has only one state, so
      -- we will just end it right away.


 --     IF (P_ACTIVITY_TYPE_CODE = 'NON_MEDIA') THEN
     IF (nvl(P_END_ACTIVITY_FLAG, 'N') = 'Y') THEN
        IEU_SH_PVT.UWQ_END_ACTIVITY
	( P_API_VERSION      => l_api_version,
          P_INIT_MSG_LIST    => 'T',
          P_COMMIT           => 'T',
	  P_ACTIVITY_ID      => x_activity_id,
	  P_MEDIA_TYPE_ID    => NULL,
	  P_MEDIA_ID         => NULL,
	  X_MSG_COUNT        => l_msg_count,
	  X_MSG_DATA         => l_msg_data,
	  X_RETURN_STATUS    => l_return_status);
      END IF;


     if (l_return_status <> 'S') then
        x_return_status := fnd_api.g_ret_sts_error;
      end if;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := 'USER_ID : '|| p_user_id ||
                        ' SESSION_ID : '||p_session_id;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_CREATE_ACTIVITY_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_SH_PVT.UWQ_BEGIN_ACTIVITY');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      --  In any Autonomous Transaction, COMMIT and ROLLBACK end the active autonomous transaction but do not exit the autonomous routine.
      --  when one transaction ends, the next SQL statement begins another transaction. So we have to COMMIT this transaction again.

      COMMIT;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UWQ_BEGIN_ACTIVITY;


PROCEDURE UWQ_UPDATE_ACTIVITY
( P_API_VERSION               IN NUMBER,
  P_INIT_MSG_LIST             IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_COMMIT                    IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_ACTIVITY_ID               IN NUMBER,
  P_INTERMEDIATE_STATE_CODE   IN VARCHAR2 DEFAULT NULL,
  P_MEDIA_TYPE_ID             IN NUMBER   DEFAULT NULL,
  P_MEDIA_ID                  IN NUMBER   DEFAULT NULL,
  P_REASON_CODE               IN VARCHAR2 DEFAULT NULL,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2)  IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'UWQ_UPDATE_ACTIVITY';

  l_token_str          VARCHAR2(4000) := '';

BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      IF (P_INTERMEDIATE_STATE_CODE = 'ACTIVE') THEN

        update IEU_SH_ACTIVITIES set
	 OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
	 DELIVER_DATE_TIME = SYSDATE,
	 STATE_CODE = P_INTERMEDIATE_STATE_CODE
       WHERE ACTIVITY_ID = P_ACTIVITY_ID;

       if (sql%notfound) then
        x_return_status := fnd_api.g_ret_sts_error;
       end if;

      END IF;

      IF (P_MEDIA_ID IS NOT NULL)
      THEN

         UPDATE IEU_SH_ACTIVITIES SET
          MEDIA_ID = P_MEDIA_ID,
		LAST_UPDATE_DATE = SYSDATE
         WHERE ACTIVITY_ID = P_ACTIVITY_ID;

      END IF;

      IF (P_MEDIA_TYPE_ID IS NOT NULL)
      THEN

         UPDATE IEU_SH_ACTIVITIES SET
          MEDIA_TYPE_ID = P_MEDIA_TYPE_ID,
		LAST_UPDATE_DATE = SYSDATE
         WHERE ACTIVITY_ID = P_ACTIVITY_ID;

      END IF;

      IF (P_MEDIA_TYPE_ID IS NOT NULL)
      THEN

         UPDATE IEU_SH_ACTIVITIES SET
          REASON_CODE = P_REASON_CODE,
		LAST_UPDATE_DATE = SYSDATE
         WHERE ACTIVITY_ID = P_ACTIVITY_ID;

      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := 'ACTIVITY_ID : '||p_activity_id;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UPDATE_ACTIVITY_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_SH_PVT.UWQ_UPDATE_ACTIVITY');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      COMMIT;

EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UWQ_UPDATE_ACTIVITY;


PROCEDURE UWQ_END_ACTIVITY
( P_API_VERSION               IN NUMBER,
  P_INIT_MSG_LIST             IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_COMMIT                    IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_ACTIVITY_ID               IN NUMBER,
  P_LAST_ACTIVITY_ID          IN NUMBER   DEFAULT NULL,
  P_MEDIA_TYPE_ID             IN NUMBER   DEFAULT NULL,
  P_MEDIA_ID                  IN NUMBER   DEFAULT NULL,
  P_COMPLETION_CODE           IN VARCHAR2 DEFAULT NULL,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'UWQ_END_ACTIVITY';

  l_token_str          VARCHAR2(4000) := '';
  l_end_date_time      DATE;

--  l_session_id        NUMBER;

BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      -- Check for API Version

      IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize Message list

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         FND_MSG_PUB.INITIALIZE;
      END IF;

      -- begin changes for correcting reports
      -- the default end_date_time is the current time
      -- if the last activity id is passed this is a MEDIA_CYCLE ending..
      -- set the end_date_time as the end time of the last activity

      SELECT SYSDATE INTO l_end_date_time FROM DUAL;

      IF ( P_LAST_ACTIVITY_ID IS NOT NULL )
      THEN
        SELECT END_DATE_TIME INTO l_end_date_time FROM IEU_SH_ACTIVITIES WHERE
          ACTIVITY_ID = P_LAST_ACTIVITY_ID;
      END IF;

      -- end changes for correcting reports

      update IEU_SH_ACTIVITIES set
        OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
        END_DATE_TIME = l_end_date_time,
        MEDIA_ID = P_MEDIA_ID,
        MEDIA_TYPE_ID = P_MEDIA_TYPE_ID,
        ACTIVE_FLAG = NULL,
        COMPLETION_CODE = P_COMPLETION_CODE,
        STATE_CODE = 'END',
        FORCE_CLOSED_BY_UWQ_FLAG = 'N',
	   LAST_UPDATE_DATE = l_end_date_time
      WHERE ACTIVITY_ID = P_ACTIVITY_ID;

      if (sql%notfound) then
        x_return_status := fnd_api.g_ret_sts_error;
      end if;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN

         x_return_status := fnd_api.g_ret_sts_error;

         l_token_str := 'ACTIVITY_ID : '||p_activity_id;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_END_ACTIVITY_FAILED');
         FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_SH_PVT.UWQ_END_ACTIVITY');
         FND_MESSAGE.SET_TOKEN('DETAILS', l_token_str);

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
      END IF;

      COMMIT;


EXCEPTION

 WHEN fnd_api.g_exc_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );

 WHEN fnd_api.g_exc_unexpected_error THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  fnd_msg_pub.Count_and_Get
  (
    p_count   =>   x_msg_count,
    p_data    =>   x_msg_data
  );


 WHEN OTHERS THEN

  ROLLBACK;
  x_return_status := fnd_api.g_ret_sts_unexp_error;

  IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN

     fnd_msg_pub.Count_and_Get
     (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
     );

  END IF;

END UWQ_END_ACTIVITY;

PROCEDURE UWQ_BREAK_TRANSITION
( P_API_VERSION               IN NUMBER,
  P_INIT_MSG_LIST             IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_COMMIT                    IN VARCHAR2 DEFAULT fnd_api.g_false,
  P_SESSION_ID                IN NUMBER,
  P_ACTIVITY_ID               IN NUMBER,
--  P_ACTIVITY_TYPE_ID          IN NUMBER,
  P_ACTIVITY_TYPE_CODE        IN VARCHAR2,
  P_LAST_ACTIVITY_ID          IN NUMBER   DEFAULT NULL,
  P_BEGIN_TIME_FLAG           IN NUMBER   DEFAULT NULL,
  P_MEDIA_TYPE_ID             IN NUMBER   DEFAULT NULL,
  P_MEDIA_ID                  IN NUMBER   DEFAULT NULL,
  P_USER_ID                   IN NUMBER,
  P_LOGIN_ID                  IN NUMBER   DEFAULT NULL,
--  P_PRV_REASON_CODE           IN VARCHAR2 DEFAULT NULL
  P_COMPLETION_CODE           IN VARCHAR2 DEFAULT NULL,
  P_REASON_CODE               IN VARCHAR2 DEFAULT NULL,
  P_REQUEST_METHOD            IN VARCHAR2 DEFAULT NULL,
  P_REQUESTED_MEDIA_TYPE_ID   IN NUMBER   DEFAULT NULL,
  P_WORK_ITEM_TYPE_CODE       IN VARCHAR2 DEFAULT NULL,
  P_WORK_ITEM_PK_ID           IN NUMBER   DEFAULT NULL,
  P_END_ACTIVITY_FLAG         IN VARCHAR2 DEFAULT NULL,
  P_PARENT_CYCLE_ID           IN NUMBER   DEFAULT NULL,
  P_CATEGORY_TYPE             IN VARCHAR2 DEFAULT NULL,
  P_CATEGORY_VALUE            IN VARCHAR2 DEFAULT NULL,
  X_ACTIVITY_ID               OUT NOCOPY NUMBER,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2) AS

  BEGIN
    UWQ_END_ACTIVITY(
      P_API_VERSION     ,
      P_INIT_MSG_LIST   ,
      P_COMMIT          ,
      P_ACTIVITY_ID     ,
      P_LAST_ACTIVITY_ID,
      P_MEDIA_TYPE_ID   ,
      P_MEDIA_ID        ,
      P_COMPLETION_CODE ,
      X_MSG_COUNT   ,
      X_MSG_DATA    ,
      X_RETURN_STATUS   );

    UWQ_BEGIN_ACTIVITY(
      P_API_VERSION     ,
      P_INIT_MSG_LIST   ,
      P_COMMIT          ,
      P_SESSION_ID      ,
    --  P_ACTIVITY_TYPE_ID          IN NUMBER,
      P_ACTIVITY_TYPE_CODE,
      P_LAST_ACTIVITY_ID,
      P_BEGIN_TIME_FLAG ,
      P_MEDIA_TYPE_ID   ,
      P_MEDIA_ID        ,
      P_USER_ID         ,
      P_LOGIN_ID        ,
    --  P_PRV_REASON_CODE           IN VARCHAR2 DEFAULT NULL
      P_REASON_CODE     ,
      P_REQUEST_METHOD  ,
      P_REQUESTED_MEDIA_TYPE_ID,
      P_WORK_ITEM_TYPE_CODE,
      P_WORK_ITEM_PK_ID ,
      P_END_ACTIVITY_FLAG,
      P_PARENT_CYCLE_ID ,
      P_CATEGORY_TYPE   ,
      P_CATEGORY_VALUE  ,
      X_ACTIVITY_ID     ,
      X_MSG_COUNT       ,
      X_MSG_DATA        ,
      X_RETURN_STATUS);

  END UWQ_BREAK_TRANSITION;

END IEU_SH_PVT;

/
