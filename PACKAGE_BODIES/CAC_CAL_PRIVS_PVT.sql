--------------------------------------------------------
--  DDL for Package Body CAC_CAL_PRIVS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_CAL_PRIVS_PVT" AS
/* $Header: caccpvb.pls 120.1 2006/07/28 09:13:21 sankgupt noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_CAL_GRANTS';

  CURSOR C_LOGGEDIN_RESOURCE IS
  select resource_id, resource_type
  from   cac_cal_resources
  where  user_name = FND_GLOBAL.USER_NAME;

  CURSOR C_GRANTEE_USER
  (
    b_resource_id     NUMBER,
    b_resource_type   VARCHAR2
  ) IS
  select user_name
  from   cac_cal_resources
  where  resource_id   = b_resource_id
  and    resource_type = b_resource_type;

  CURSOR C_INSTANCE_SET_ID IS
  select instance_set_id from fnd_object_instance_sets
  where  instance_set_name = 'JTF_TASK_RESOURCE_TASKS';

  PROCEDURE INSERT_GRANTS
  ( p_grantee                IN  VARCHAR2
  , p_resource_id            IN  NUMBER
  , p_resource_type          IN  VARCHAR2
  , p_instance_set_id        IN  NUMBER
  , p_start_date             IN  DATE
  , p_end_date               IN  DATE
  , p_appointment_access     IN  VARCHAR2
  , p_task_access            IN  VARCHAR2
  , p_booking_access         IN  VARCHAR2
  ) IS

    l_grant_guid       RAW(16);
    l_return_status    VARCHAR2(1);
    l_error            NUMBER;

  BEGIN

    IF (p_appointment_access IS NOT NULL)
    THEN
      fnd_grants_pkg.grant_function
      ( p_api_version        => 1.0
      , p_menu_name          => p_appointment_access
      , p_instance_type      => 'INSTANCE'
      , p_object_name        => 'CAC_CAL_RESOURCES'
      , p_instance_pk1_value => TO_CHAR(p_resource_id)
      , p_instance_pk2_value => p_resource_type
      , p_grantee_type       => 'USER'
      , p_grantee_key        => p_grantee
      , p_start_date         => p_start_date
      , p_end_date           => p_end_Date
      , p_program_name       => 'CALENDAR'
      , p_program_tag        => 'CAC_CAL_ACCESS'
      , x_grant_guid         => l_grant_guid
      , x_success            => l_return_status
      , x_errorcode          => l_error
      , p_name               => 'Calendar: Appointment Access'
      , p_description        => 'This is used for delgating calendar access'
      );

      IF (l_return_status <> FND_API.G_TRUE)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF (p_booking_access IS NOT NULL)
    THEN
      fnd_grants_pkg.grant_function
      ( p_api_version        => 1.0
      , p_menu_name          => p_booking_access
      , p_instance_type      => 'INSTANCE'
      , p_object_name        => 'CAC_CAL_RESOURCES'
      , p_instance_pk1_value => TO_CHAR(p_resource_id)
      , p_instance_pk2_value => p_resource_type
      , p_grantee_type       => 'USER'
      , p_grantee_key        => p_grantee
      , p_start_date         => p_start_date
      , p_end_date           => p_end_Date
      , p_program_name       => 'CALENDAR'
      , p_program_tag        => 'CAC_CAL_ACCESS'
      , x_grant_guid         => l_grant_guid
      , x_success            => l_return_status
      , x_errorcode          => l_error
      , p_name               => 'Calendar: Booking Access'
      , p_description        => 'This is used for delgating calendar access'
      );

      IF (l_return_status <> FND_API.G_TRUE)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF (p_task_access IS NOT NULL)
    THEN
      fnd_grants_pkg.grant_function
      ( p_api_version        => 1.0
      , p_menu_name          => p_task_access
      , p_instance_type      => 'INSTANCE'
      , p_object_name        => 'CAC_CAL_RESOURCES'
      , p_instance_pk1_value => TO_CHAR(p_resource_id)
      , p_instance_pk2_value => p_resource_type
      , p_grantee_type       => 'USER'
      , p_grantee_key        => p_grantee
      , p_start_date         => p_start_date
      , p_end_date           => p_end_Date
      , p_program_name       => 'CALENDAR'
      , p_program_tag        => 'CAC_CAL_ACCESS'
      , x_grant_guid         => l_grant_guid
      , x_success            => l_return_status
      , x_errorcode          => l_error
      , p_name               => 'Calendar: Task Access'
      , p_description        => 'This is used for delgating calendar access'
      );

      IF (l_return_status <> FND_API.G_TRUE)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      fnd_grants_pkg.grant_function
      ( p_api_version        => 1.0
      , p_menu_name          => p_task_access
      , p_instance_type      => 'SET'
      , p_instance_set_id    => p_instance_set_id
      , p_object_name        => 'JTF_TASKS'
      , p_grantee_type       => 'USER'
      , p_grantee_key        => p_grantee
      , p_start_date         => p_start_date
      , p_end_date           => p_end_Date
      , p_program_name       => 'CALENDAR'
      , p_program_tag        => 'CAC_CAL_ACCESS'
      , p_parameter1         => TO_CHAR(p_resource_id)
      , x_grant_guid         => l_grant_guid
      , x_success            => l_return_status
      , x_errorcode          => l_error
      , p_name               => 'Calendar: Task Data Access'
      , p_description        => 'This is used for delgating calendar access'
      );

      IF (l_return_status <> FND_API.G_TRUE)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END INSERT_GRANTS;


  PROCEDURE CREATE_GRANTS
  ( p_grantee_user_name      IN  VARCHAR2
  , p_grantee_start_date     IN  DATE
  , p_grantee_end_date       IN  DATE
  , p_appointment_access     IN  VARCHAR2
  , p_task_access            IN  VARCHAR2
  , p_booking_access         IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
  ) IS


    l_api_name         CONSTANT VARCHAR2(30)   := 'create_grants';
    l_resource_id      NUMBER;
    l_resource_type    VARCHAR2(80);
    l_instance_set_id  NUMBER;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN C_LOGGEDIN_RESOURCE;
    FETCH C_LOGGEDIN_RESOURCE
      INTO l_resource_id,l_resource_type;
    CLOSE C_LOGGEDIN_RESOURCE;

    OPEN C_INSTANCE_SET_ID;
    FETCH C_INSTANCE_SET_ID
      INTO l_instance_set_id;
    CLOSE C_INSTANCE_SET_ID;

    INSERT_GRANTS
    ( p_grantee              => p_grantee_user_name
    , p_resource_id          => l_resource_id
    , p_resource_type        => l_resource_type
    , p_instance_set_id      => l_instance_set_id
    , p_start_date           => p_grantee_start_date
    , p_end_date             => p_grantee_end_date
    , p_appointment_access   => p_appointment_access
    , p_task_access          => p_task_access
    , p_booking_access       => p_booking_access
    );

    /***************************************************************************
    ** Standard call to get message count and if count is > 1, get message info
    ***************************************************************************/
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                               , p_data  => x_msg_data
                               );
    WHEN OTHERS
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                               , l_api_name
                               );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                               , p_data  => x_msg_data
                               );

  END CREATE_GRANTS;


  PROCEDURE UPDATE_GRANTS
  ( p_grantee_user_name      IN  VARCHAR2
  , p_grantee_start_date     IN  DATE
  , p_grantee_end_date       IN  DATE
  , p_appointment_access     IN  VARCHAR2
  , p_task_access            IN  VARCHAR2
  , p_booking_access         IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  , x_msg_data               OUT NOCOPY VARCHAR2
  ) IS

    CURSOR C_GET_GRANTS
    (
      b_grantee            VARCHAR2,
      b_resource_id        NUMBER,
      b_resource_type      VARCHAR2,
      b_instance_set_id    NUMBER
    ) IS
    SELECT fgs.grant_guid
    FROM   FND_GRANTS fgs
         , FND_MENUS fmu
         , FND_OBJECTS fos
    WHERE  fgs.object_id = fos.object_id
    AND    fos.obj_name  = 'CAC_CAL_RESOURCES'
    AND    fgs.menu_id   = fmu.menu_id
    AND    fmu.menu_name IN ( 'JTF_CAL_READ_ACCESS'
                            , 'JTF_CAL_FULL_ACCESS'
                            , 'JTF_TASK_READ_ONLY'
                            , 'JTF_TASK_FULL_ACCESS'
                            , 'CAC_BKG_READ_ONLY_ACCESS'
                            )
    AND    fgs.grantee_type       = 'USER'
    AND    fgs.grantee_key        = b_grantee
    AND    fgs.instance_type      = 'INSTANCE'
    AND    fgs.instance_pk1_value = TO_CHAR(b_resource_id)
    AND    fgs.instance_pk2_value = b_resource_type
    AND    fgs.program_tag = 'CAC_CAL_ACCESS'
    UNION ALL
    SELECT fgs.grant_guid
    FROM   FND_GRANTS fgs
         , FND_MENUS fmu
         , FND_OBJECTS fos
    WHERE  fgs.object_id = fos.object_id
    AND    fos.obj_name  = 'JTF_TASKS'
    AND    fgs.menu_id   = fmu.menu_id
    AND    fmu.menu_name IN ( 'JTF_TASK_READ_ONLY'
                            , 'JTF_TASK_FULL_ACCESS'
                            )
    AND    fgs.grantee_type       = 'USER'
    AND    fgs.grantee_key        = b_grantee
    AND    fgs.instance_type      = 'SET'
    AND    fgs.instance_set_id    = b_instance_set_id
    AND    fgs.parameter1         = TO_CHAR(b_resource_id)
    AND    fgs.PROGRAM_TAG = 'CAC_CAL_ACCESS' ;


    l_api_name         CONSTANT VARCHAR2(30)   := 'update_grants';
    l_resource_id      NUMBER;
    l_resource_type    VARCHAR2(80);
    l_grantee          VARCHAR2(100);
    l_instance_set_id  NUMBER;
    l_return_status    VARCHAR2(1);
    l_error            NUMBER;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN C_LOGGEDIN_RESOURCE;
    FETCH C_LOGGEDIN_RESOURCE
      INTO l_resource_id,l_resource_type;
    CLOSE C_LOGGEDIN_RESOURCE;

    OPEN C_INSTANCE_SET_ID;
    FETCH C_INSTANCE_SET_ID
      INTO l_instance_set_id;
    CLOSE C_INSTANCE_SET_ID;

    FOR ref_cursor IN C_GET_GRANTS(p_grantee_user_name,l_resource_id,l_resource_type,l_instance_set_id)
    LOOP
      fnd_grants_pkg.revoke_grant
      ( p_api_version        => 1.0
      , p_grant_guid         => ref_cursor.grant_guid
      , x_success            => l_return_status
      , x_errorcode          => l_error
      );

      IF (l_return_status <> FND_API.G_TRUE)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;

    INSERT_GRANTS
    ( p_grantee              => p_grantee_user_name
    , p_resource_id          => l_resource_id
    , p_resource_type        => l_resource_type
    , p_instance_set_id      => l_instance_set_id
    , p_start_date           => p_grantee_start_date
    , p_end_date             => p_grantee_end_date
    , p_appointment_access   => p_appointment_access
    , p_task_access          => p_task_access
    , p_booking_access       => p_booking_access
    );

    /***************************************************************************
    ** Standard call to get message count and if count is > 1, get message info
    ***************************************************************************/
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                               , p_data  => x_msg_data
                               );
    WHEN OTHERS
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                               , l_api_name
                               );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                               , p_data  => x_msg_data
                               );

  END UPDATE_GRANTS;


END CAC_CAL_PRIVS_PVT;

/
