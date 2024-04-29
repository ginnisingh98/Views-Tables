--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_SECURITY_PVT" AS
/* $Header: jtfvnsb.pls 115.7 2003/09/26 22:52:51 hbouten ship $ */

PROCEDURE check_notes_access
( p_api_version                 IN            NUMBER
, p_init_msg_list               IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_note_id                     IN            NUMBER
, x_select_predicate            IN OUT NOCOPY VARCHAR2
, x_note_type_predicate         IN OUT NOCOPY VARCHAR2
, x_select_access               IN OUT NOCOPY NUMBER
, x_create_access               IN OUT NOCOPY NUMBER
, x_update_note_access          IN OUT NOCOPY NUMBER
, x_update_note_details_access  IN OUT NOCOPY NUMBER
, x_update_secondary_access     IN OUT NOCOPY NUMBER
, x_delete_access               IN OUT NOCOPY NUMBER
, x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                      OUT NOCOPY NUMBER
, x_msg_data                       OUT NOCOPY VARCHAR2
) IS

  l_api_name       CONSTANT VARCHAR2(30)    := 'check_notes_access';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_privilege_tbl  FND_DATA_SECURITY.FND_PRIVILEGE_NAME_TABLE_TYPE;

BEGIN

  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get Security Predicate for Select
  --
  IF (x_select_predicate IS NULL)
  THEN
    get_security_predicate
    ( p_api_version         => 1.0
    , p_init_msg_list       => FND_API.G_FALSE
    , p_object_name         => G_OBJECT_NOTE
    , p_function            => G_FUNCTION_SELECT
    , p_statement_type      => 'OTHER'
    , p_table_alias         => NULL
    , x_predicate           => x_select_predicate
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --
  -- Get Security Predicate for Note Type DropDown
  --
  IF (x_note_type_predicate IS NULL)
  THEN

    get_security_predicate
    ( p_api_version         => 1.0
    , p_init_msg_list       => FND_API.G_FALSE
    , p_object_name         => G_OBJECT_NOTE_TYPE
    , p_function            => G_FUNCTION_TYPE_SELECT
    , p_statement_type      => 'OTHER'
    , p_table_alias         => NULL
    , x_predicate           => x_note_type_predicate
    , x_return_status       => x_return_status
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF ((p_note_id IS NOT NULL) AND
     ((x_select_access NOT IN (0,1)) OR
     (x_update_note_access NOT IN (0,1)) OR
     (x_update_note_details_access NOT IN (0,1)) OR
     (x_update_secondary_access NOT IN (0,1)) OR
     (x_delete_access NOT IN (0,1))))
  THEN

    x_select_access := 0;
    x_update_note_access := 0;
    x_update_note_details_access := 0;
    x_update_secondary_access := 0;
    x_delete_access := 0;

    get_functions
    ( p_api_version         => 1.0
    , p_init_msg_list       => FND_API.G_FALSE
    , p_object_name         => G_OBJECT_NOTE
    , p_instance_pk1_value  => TO_CHAR(p_note_id)
    , p_instance_pk2_value  => NULL
    , p_instance_pk3_value  => NULL
    , p_instance_pk4_value  => NULL
    , p_instance_pk5_value  => NULL
    , p_user_name           => NULL
    , x_return_status       => x_return_status
    , x_privilege_tbl       => l_privilege_tbl
    , x_msg_count           => x_msg_count
    , x_msg_data            => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_privilege_tbl.LAST IS NOT NULL)
    THEN
      FOR i IN l_privilege_tbl.FIRST..l_privilege_tbl.LAST
      LOOP <<FUNCTIONS>>
        IF (l_privilege_tbl(i) = G_FUNCTION_SELECT)
        THEN
          x_select_access := 1;
        ELSIF (l_privilege_tbl(i) = G_FUNCTION_UPDATE_NOTE)
        THEN
            x_update_note_access := 1;
        ELSIF (l_privilege_tbl(i) = G_FUNCTION_UPDATE_NOTE_DTLS)
        THEN
            x_update_note_details_access := 1;
        ELSIF (l_privilege_tbl(i) = G_FUNCTION_UPDATE_SEC)
        THEN
            x_update_secondary_access := 1;
        ELSIF (l_privilege_tbl(i) = G_FUNCTION_DELETE)
        THEN
          x_delete_access := 1;
        END IF;
      END LOOP;
    END IF;

  END IF;

  --
  -- Get Security Access for Create
  --
  IF (x_create_access NOT IN (0,1))
  THEN

    check_function
    ( p_api_version          => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_function             => G_FUNCTION_CREATE
    , p_object_name          => G_OBJECT_NOTE
    , p_instance_pk1_value   => NULL
    , p_instance_pk2_value   => NULL
    , p_instance_pk3_value   => NULL
    , p_instance_pk4_value   => NULL
    , p_instance_pk5_value   => NULL
    , p_user_name            => NULL
    , x_return_status        => x_return_status
    , x_grant                => x_create_access
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    -- In case of exception return no access for all functions
    -- (required for NOCOPY)
    x_select_predicate           := 0;
    x_note_type_predicate        := 0;
    x_select_access              := 0;
    x_create_access              := 0;
    x_update_note_access         := 0;
    x_update_note_details_access := 0;
    x_update_secondary_access    := 0;
    x_delete_access              := 0;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
  WHEN OTHERS
  THEN
    -- In case of exception return no access for all functions
    -- (required for NOCOPY)
    x_select_predicate           := 0;
    x_note_type_predicate        := 0;
    x_select_access              := 0;
    x_create_access              := 0;
    x_update_note_access         := 0;
    x_update_note_details_access := 0;
    x_update_secondary_access    := 0;
    x_delete_access              := 0;
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , SQLERRM
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END check_notes_access;


PROCEDURE get_security_predicate
( p_api_version         IN            NUMBER
, p_init_msg_list       IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_object_name         IN            VARCHAR2 DEFAULT NULL
, p_function            IN            VARCHAR2 DEFAULT NULL
, p_grant_instance_type IN            VARCHAR2 DEFAULT 'UNIVERSAL'
, p_user_name           IN            VARCHAR2 DEFAULT NULL
, p_statement_type      IN            VARCHAR2 DEFAULT 'OTHER'
, p_table_alias         IN            VARCHAR2 DEFAULT NULL
, x_predicate              OUT NOCOPY VARCHAR2
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS

  l_api_name       CONSTANT VARCHAR2(30)    := 'get_security_predicate';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_msg_data       VARCHAR2(2000);

BEGIN
  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Call the FND procedure
  --
  FND_DATA_SECURITY.get_security_predicate
  ( p_api_version         => 1.0
  , p_function            => p_function
  , p_object_name         => p_object_name
  , p_grant_instance_type => p_grant_instance_type
  , p_user_name           => p_user_name
  , p_statement_type      => p_statement_type
  , p_table_alias         => p_table_alias
  , x_predicate           => x_predicate
  , x_return_status       => x_return_status
  );

  IF (x_return_status NOT IN ('T','F'))
  THEN
    --
    -- An error occured
    --
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --
    -- Get error message from FND stack
    --
    l_msg_data      := FND_MESSAGE.GET;

    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_msg_data
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

    --
    -- Reset to NULL because of NOCOPY
    --
    x_predicate     := NULL;

  WHEN OTHERS
  THEN
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , SQLERRM
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

    --
    -- Reset to NULL because of NOCOPY
    --
    x_predicate     := NULL;

END get_security_predicate;


PROCEDURE get_functions
( p_api_version         IN            NUMBER
, p_init_msg_list       IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_object_name         IN            VARCHAR2
, p_instance_pk1_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk2_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk3_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk4_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk5_value  IN            VARCHAR2 DEFAULT NULL
, p_user_name           IN            VARCHAR2 DEFAULT NULL
, x_return_status          OUT NOCOPY VARCHAR2
, x_privilege_tbl          OUT NOCOPY FND_DATA_SECURITY.FND_PRIVILEGE_NAME_TABLE_TYPE
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)IS

  l_api_name       CONSTANT VARCHAR2(30)    := 'get_functions';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_msg_data       VARCHAR2(2000);
  l_privilege_tbl  FND_DATA_SECURITY.FND_PRIVILEGE_NAME_TABLE_TYPE;

BEGIN
  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Call the FND procedure
  --
  FND_DATA_SECURITY.get_functions
  ( p_api_version        => 1.0
  , p_object_name        => p_object_name
  , p_instance_pk1_value => p_instance_pk1_value
  , p_instance_pk2_value => p_instance_pk2_value
  , p_instance_pk3_value => p_instance_pk3_value
  , p_instance_pk4_value => p_instance_pk4_value
  , p_instance_pk5_value => p_instance_pk5_value
  , p_user_name          => p_user_name
  , x_return_status      => x_return_status
  , x_privilege_tbl      => x_privilege_tbl
  );

  IF (x_return_status NOT IN('T','F'))
  THEN
    --
    -- An error occured
    --
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --
    -- Get error message from FND stack
    --
    l_msg_data      := FND_MESSAGE.GET;

    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_msg_data
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

    --
    -- reset to NULL because of NOCOPY
    --
    x_privilege_tbl := l_privilege_tbl;

  WHEN OTHERS
  THEN
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , SQLERRM
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

    --
    -- reset to NULL because of NOCOPY
    --
    x_privilege_tbl := l_privilege_tbl;


END get_functions;

PROCEDURE check_function
( p_api_version          IN            NUMBER
, p_init_msg_list        IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_function             IN            VARCHAR2
, p_object_name          IN            VARCHAR2
, p_instance_pk1_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk2_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk3_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk4_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk5_value   IN            VARCHAR2 DEFAULT NULL
, p_user_name            IN            VARCHAR2 DEFAULT NULL
, x_return_status           OUT NOCOPY VARCHAR2
, x_grant                   OUT NOCOPY NUMBER -- 1 yes, 0 no
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
)
IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'check_function';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_fnd_grant      BOOLEAN;

  l_msg_data       VARCHAR2(2000);

BEGIN
  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --
  -- Call the FND procedure
  --

  l_fnd_grant := FND_FUNCTION.test_instance
                 ( function_name        => p_function
                 , object_name          => p_object_name
                 , instance_pk1_value   => p_instance_pk1_value
                 , instance_pk2_value   => p_instance_pk2_value
                 , instance_pk3_value   => p_instance_pk3_value
                 , instance_pk4_value   => p_instance_pk4_value
                 , instance_pk5_value   => p_instance_pk5_value
                 , user_name            => p_user_name
                 );


  IF (l_fnd_grant)
  THEN
    x_grant := 1;
  ELSE
    x_grant := 0;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    --
    -- Something is wrong: no access
    --
    x_grant := 0;

    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    -- Get error message from FND stack
    --
    l_msg_data      := FND_MESSAGE.GET;
    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_msg_data
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

  WHEN OTHERS
  THEN
    --
    -- Something is wrong: no access
    --
    x_grant := 0;

    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , SQLERRM
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END check_function;


PROCEDURE check_note_type
( p_api_version          IN            NUMBER
, p_init_msg_list        IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_note_type            IN            VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_grant                   OUT NOCOPY NUMBER -- 1 yes, 0 no
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
)
IS

  TYPE note_types_cur_type IS REF CURSOR;

  l_api_name       CONSTANT VARCHAR2(30)    := 'check_note_type';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  cv_note_types             note_types_cur_type; -- place holder for dynamic cursor


  l_query                   VARCHAR2(4000) := 'SELECT COUNT(1) '
                                            ||'FROM FND_LOOKUPS FNS '
                                            ||'WHERE FNS.LOOKUP_TYPE = ''JTF_NOTE_TYPE'' '
                                            ||'AND FNS.LOOKUP_CODE = :A ';

  l_predicate               VARCHAR2(32767);

BEGIN
  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get the security predicate
  --
  get_security_predicate
  ( p_api_version         => 1.0
  , p_init_msg_list       => FND_API.G_FALSE
  , p_object_name         => G_OBJECT_NOTE_TYPE
  , p_function            => G_FUNCTION_TYPE_SELECT
  , p_statement_type      => 'OTHER'
  , p_table_alias         => 'FNS'
  , x_predicate           => l_predicate
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  );


  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    --
    -- An error occured
    --
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- No error so we can do the checks
  --
  IF (l_predicate = '1=2')
  THEN
    --
    -- this means no grant was given, avoiding the dynamic SQL
    --
    x_grant := 0;

  ELSE
    --
    -- We got a genuine where clause so we can do the check
    --
    l_query  := l_query ||' AND '||l_predicate;

    OPEN cv_note_types FOR l_query USING p_note_type;

    FETCH cv_note_types INTO x_grant;

    CLOSE cv_note_types;

  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    --
    -- Something is wrong: no access
    --
    x_grant := 0;

    IF (cv_note_types%ISOPEN)
    THEN
      CLOSE cv_note_types;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    --
    -- Something is wrong: no access
    --
    x_grant := 0;

    IF (cv_note_types%ISOPEN)
    THEN
      CLOSE cv_note_types;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , SQLERRM
                           );

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END check_note_type;

FUNCTION check_update_sec_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_update_sec_access
--  Type      : Private
--  Usage     : Check notes access using AOL security
--  Version : Initial version   1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_note_id                     IN            NUMBER
) RETURN INTEGER
IS

   retAccess         INTEGER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);

BEGIN

   IF (p_note_id IS NOT NULL)
   THEN
    check_function
    ( p_api_version          => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_function             => G_FUNCTION_UPDATE_SEC
    , p_object_name          => G_OBJECT_NOTE
    , p_instance_pk1_value   => p_note_id
    , p_instance_pk2_value   => NULL
    , p_instance_pk3_value   => NULL
    , p_instance_pk4_value   => NULL
    , p_instance_pk5_value   => NULL
    , p_user_name            => NULL
    , x_return_status        => l_return_status
    , x_grant                => retAccess
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      retAccess := 0;
    END IF;
   END IF;

   RETURN retAccess;

END check_update_sec_access;

FUNCTION check_update_prim_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_update_prim_access
--  Type      : Private
--  Usage     : Check notes access using AOL security
--  Version : Initial version   1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_note_id                     IN            NUMBER
) RETURN INTEGER
IS

   retAccess         INTEGER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);

BEGIN

   IF (p_note_id IS NOT NULL)
   THEN
    check_function
    ( p_api_version          => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_function             => G_FUNCTION_UPDATE_NOTE_DTLS
    , p_object_name          => G_OBJECT_NOTE
    , p_instance_pk1_value   => p_note_id
    , p_instance_pk2_value   => NULL
    , p_instance_pk3_value   => NULL
    , p_instance_pk4_value   => NULL
    , p_instance_pk5_value   => NULL
    , p_user_name            => NULL
    , x_return_status        => l_return_status
    , x_grant                => retAccess
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      retAccess := 0;
    END IF;

    IF (retAccess <> 0)
    THEN
      check_function
      ( p_api_version          => 1.0
      , p_init_msg_list        => FND_API.G_FALSE
      , p_function             => G_FUNCTION_UPDATE_NOTE
      , p_object_name          => G_OBJECT_NOTE
      , p_instance_pk1_value   => p_note_id
      , p_instance_pk2_value   => NULL
      , p_instance_pk3_value   => NULL
      , p_instance_pk4_value   => NULL
      , p_instance_pk5_value   => NULL
      , p_user_name            => NULL
      , x_return_status        => l_return_status
      , x_grant                => retAccess
      , x_msg_count            => l_msg_count
      , x_msg_data             => l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        retAccess := 0;
      END IF;
     END IF;
   END IF;

   RETURN retAccess;

END check_update_prim_access;

FUNCTION check_delete_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_update_sec_access
--  Type      : Private
--  Usage     : Check notes access using AOL security
--  Version : Initial version   1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_note_id                     IN            NUMBER
) RETURN INTEGER
IS

   retAccess         INTEGER := 0;
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);

BEGIN

   IF (p_note_id IS NOT NULL)
   THEN
    check_function
    ( p_api_version          => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_function             => G_FUNCTION_DELETE
    , p_object_name          => G_OBJECT_NOTE
    , p_instance_pk1_value   => p_note_id
    , p_instance_pk2_value   => NULL
    , p_instance_pk3_value   => NULL
    , p_instance_pk4_value   => NULL
    , p_instance_pk5_value   => NULL
    , p_user_name            => NULL
    , x_return_status        => l_return_status
    , x_grant                => retAccess
    , x_msg_count            => l_msg_count
    , x_msg_data             => l_msg_data
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      retAccess := 0;
    END IF;
   END IF;

   RETURN retAccess;

END check_delete_access;

END JTF_NOTES_SECURITY_PVT;

/
