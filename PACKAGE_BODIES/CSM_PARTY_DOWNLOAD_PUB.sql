--------------------------------------------------------
--  DDL for Package Body CSM_PARTY_DOWNLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PARTY_DOWNLOAD_PUB" AS
/* $Header: csmpptdb.pls 120.7 2008/02/29 09:06:26 anaraman noship $*/

PROCEDURE assign_cust_to_user
( p_api_version_number        IN  NUMBER,
  p_init_msg_list             IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                   IN  NUMBER,
  p_party_id                  IN  NUMBER,
  p_operation                 IN  VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_error_message             OUT NOCOPY VARCHAR2
)
IS

   l_owner_id                 asg_user.owner_id%TYPE := NULL;
   l_party_site_id            csm_party_sites_acc.party_site_id%TYPE := NULL;
   l_return_status            VARCHAR2(3000);
   l_error_message            VARCHAR2(3000) := NULL;
   l_msg_data                 VARCHAR2(3000);
   l_sqlerrmsg                VARCHAR2(3000);
   l_sqlerrno                 VARCHAR2(20);

   CURSOR csr_owner_id(p_user_id IN NUMBER)
   IS
      SELECT au.owner_id
      FROM   asg_user au
      WHERE  au.user_id = p_user_id
      AND    au.enabled = 'Y';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN csr_owner_id (p_user_id);
  FETCH csr_owner_id INTO l_owner_id;

  IF (csr_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME  ('CSM', 'CSM_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO owner found for the given user - '||p_user_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_owner_id;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert records into CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.insert_party_assg
      ( P_USER_ID           => p_user_id,
        P_PARTY_ID          => p_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => l_party_site_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to delete records from CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.delete_party_assg
      ( P_USER_ID           => p_user_id,
        P_PARTY_ID          => p_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => l_party_site_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  END IF;

  IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS)

  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  IF p_operation IS NULL

  THEN

  CSM_UTIL_PKG.LOG('Value for p_operation is NULL', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  END IF;

  IF (csr_owner_id%ISOPEN)

  THEN

   CLOSE csr_owner_id;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'Assigning customer to single user through CSM_PARTY_ASSIGNMENT_PKG is done successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER ',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_PARTY_ASSIGN_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER Procedure :'||'while processing the party -'
      ||p_party_id|| 'for the user -'||p_user_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_TO_USER',FND_LOG.LEVEL_EXCEPTION);

END assign_cust_to_user;

PROCEDURE assign_mul_cust_to_users
( p_api_version_number             IN  NUMBER,
  p_init_msg_list                  IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id_lst                    IN  l_user_id_tbl_type,
  p_party_id_lst                   IN  l_party_id_tbl_type,
  p_operation                      IN  VARCHAR2,
  x_msg_count                      OUT NOCOPY NUMBER,
  x_return_status                  OUT NOCOPY VARCHAR2,
  x_error_message                  OUT NOCOPY VARCHAR2
)
IS

  l_user_id_tbl                    l_user_id_tbl_type;
  l_party_id_tbl                   l_party_id_tbl_type;
  l_user_id                        asg_user.user_id%TYPE;
  l_party_id                       csm_parties_acc.party_id%TYPE;
  l_owner_id                       asg_user.owner_id%TYPE := NULL;
  l_party_site_id                  csm_party_sites_acc.party_site_id%TYPE := NULL;
  l_return_status                  VARCHAR2(3000);
  l_error_message                  VARCHAR2(3000) := NULL;
  l_msg_data                       VARCHAR2(3000);
  l_sqlerrmsg                      VARCHAR2(3000);
  l_sqlerrno                       VARCHAR2(20);

  CURSOR csr_owner_id (p_user_id IN NUMBER)
  IS
     SELECT au.owner_id
     FROM   asg_user au
     WHERE  au.user_id = p_user_id
     AND    au.enabled = 'Y';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  IF l_party_id_tbl.COUNT > 0

  THEN

    l_party_id_tbl.DELETE;

  END IF;

  IF l_user_id_tbl.COUNT > 0

  THEN

    l_user_id_tbl.DELETE;

  END IF;

    l_party_id_tbl      := p_party_id_lst;

    l_user_id_tbl       := p_user_id_lst;

  FOR i IN l_party_id_tbl.FIRST..l_party_id_tbl.LAST LOOP

    l_party_id          := l_party_id_tbl(i);

    l_user_id           := l_user_id_tbl(i);

    l_owner_id          := NULL;

  OPEN csr_owner_id (l_user_id);
  FETCH csr_owner_id INTO l_owner_id;

  IF (csr_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME ('CSM', 'CSM_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO owner found for the given user - '||l_user_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_owner_id;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert records into CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.insert_party_assg
      ( P_USER_ID           => l_user_id,
        P_PARTY_ID          => l_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => l_party_site_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to delete records from CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.delete_party_assg
      ( P_USER_ID           => l_user_id,
        P_PARTY_ID          => l_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => l_party_site_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  END IF;

  IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS)

  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  END LOOP;

  COMMIT;

  IF p_operation IS NULL

  THEN

  CSM_UTIL_PKG.LOG('Value for p_operation is NULL', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS',FND_LOG.LEVEL_EXCEPTION);

  END IF;

  IF (csr_owner_id%ISOPEN)

  THEN

   CLOSE csr_owner_id;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'Assigning multiple customers to multiple users through CSM_PARTY_ASSIGNMENT_PKG is done successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS ',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      ROLLBACK;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_PARTY_ASSIGN_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS Procedure :'||'while processing the party -'
      ||l_party_id|| 'for the user -'||l_user_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_TO_USERS',FND_LOG.LEVEL_EXCEPTION);

END assign_mul_cust_to_users;

PROCEDURE assign_cust_loc_to_user
( p_api_version_number           IN  NUMBER,
  p_init_msg_list                IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                      IN  NUMBER,
  p_party_id                     IN  NUMBER,
  p_location_id                  IN  NUMBER,
  p_operation                    IN  VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_error_message                OUT NOCOPY VARCHAR2
)
IS

  l_owner_id                     asg_user.owner_id%TYPE := NULL;
  l_return_status                VARCHAR2(3000);
  l_error_message                VARCHAR2(3000);
  l_msg_data                     VARCHAR2(3000);
  l_sqlerrmsg                    VARCHAR2(3000) := NULL;
  l_sqlerrno                     VARCHAR2(20);

  CURSOR csr_owner_id(p_user_id IN NUMBER)
  IS
    SELECT au.owner_id
    FROM   asg_user au
    WHERE  au.user_id = p_user_id
    AND    au.enabled = 'Y';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN csr_owner_id (p_user_id);
  FETCH csr_owner_id INTO l_owner_id;

  IF (csr_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME ('CSM', 'CSM_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO owner found for the given user - '||p_user_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_owner_id;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert records into CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.insert_party_assg
      ( P_USER_ID           => p_user_id,
        P_PARTY_ID          => p_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => p_location_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to delete records from CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.delete_party_assg
      ( P_USER_ID           => p_user_id,
        P_PARTY_ID          => p_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => p_location_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  END IF;

  IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS)

  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  IF p_operation IS NULL

  THEN

  CSM_UTIL_PKG.LOG('Value for p_operation is NULL', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  END IF;

  IF (csr_owner_id%ISOPEN)

  THEN

   CLOSE csr_owner_id;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'Assigning customer with a location to single user through CSM_PARTY_ASSIGNMENT_PKG is done successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_PARTY_ASSIGN_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER Procedure :'||'while processing the party -'
      ||p_party_id|| 'for the user -'||p_user_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

END assign_cust_loc_to_user;

PROCEDURE assign_mul_cust_loc_to_users
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id_lst                       IN  l_user_id_tbl_type,
  p_party_id                          IN  NUMBER,
  p_location_id_lst                   IN  l_party_id_tbl_type,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
)

IS

  l_user_id_tbl                       l_user_id_tbl_type;
  l_party_site_id_tbl                 l_party_id_tbl_type;
  l_user_id                           asg_user.user_id%TYPE;
  l_party_id                          csm_parties_acc.party_id%TYPE;
  l_location_id                       csm_party_sites_acc.party_site_id%TYPE;
  l_owner_id                          asg_user.owner_id%TYPE := NULL;
  l_party_site_id                     csm_party_sites_acc.party_site_id%TYPE;
  l_return_status                     VARCHAR2(3000);
  l_error_message                     VARCHAR2(3000);
  l_msg_data                          VARCHAR2(3000);
  l_sqlerrmsg                         VARCHAR2(3000) := NULL;
  l_sqlerrno                          VARCHAR2(20);

  CURSOR csr_owner_id (p_user_id IN NUMBER)
  IS
    SELECT au.owner_id
    FROM   asg_user au
    WHERE  au.user_id = p_user_id
    AND    au.enabled = 'Y';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USERS Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USERS',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  IF l_party_site_id_tbl.COUNT > 0

  THEN

    l_party_site_id_tbl.DELETE;

  END IF;

  IF l_user_id_tbl.COUNT > 0

  THEN

    l_user_id_tbl.DELETE;

  END IF;

    l_party_id                := p_party_id;

    l_user_id_tbl             := p_user_id_lst;

    l_party_site_id_tbl       := p_location_id_lst;

  FOR i IN l_party_site_id_tbl.FIRST..l_party_site_id_tbl.LAST LOOP

    l_user_id        := l_user_id_tbl(i);

    l_party_site_id  := l_party_site_id_tbl(i);

    l_owner_id       := NULL;

  OPEN csr_owner_id (l_user_id);
  FETCH csr_owner_id INTO l_owner_id;

  IF (csr_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME ('CSM', 'CSM_PARTY_ASSIGN_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO owner found for the given user - '||l_user_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_owner_id;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert records into CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.insert_party_assg
      ( P_USER_ID           => l_user_id,
        P_PARTY_ID          => l_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => l_party_site_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to delete records from CSM_PARTY_ASSIGNMENT table

    csm_party_assignment_pkg.delete_party_assg
      ( P_USER_ID           => l_user_id,
        P_PARTY_ID          => l_party_id,
        P_OWNER_ID          => l_owner_id,
        P_PARTY_SITE_ID     => l_party_site_id,
        X_RETURN_STATUS     => l_return_status,
        X_ERROR_MESSAGE     => l_error_message);

  END IF;

  IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS)

  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  END LOOP;

  COMMIT;

  IF p_operation IS NULL

  THEN

  CSM_UTIL_PKG.LOG('Value for p_operation is NULL', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  END IF;

  IF (csr_owner_id%ISOPEN)

  THEN

   CLOSE csr_owner_id;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'Assigning customer with multiple locations to multiple users through CSM_PARTY_ASSIGNMENT_PKG is done successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

 EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      ROLLBACK;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_PARTY_ASSIGN_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USER Procedure :'||'while processing the party -'
      ||l_party_id|| 'for the user -'||l_user_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.ASSIGN_MUL_CUST_LOC_TO_USER',FND_LOG.LEVEL_EXCEPTION);

END assign_mul_cust_loc_to_users;

PROCEDURE get_parties_for_user
( p_api_version_number         IN  NUMBER,
  p_init_msg_list              IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                    IN  NUMBER,
  p_party_id_lst               OUT NOCOPY l_party_id_tbl_type,
  p_operation                  IN  VARCHAR2,
  x_msg_count                  OUT NOCOPY NUMBER,
  x_return_status              OUT NOCOPY VARCHAR2,
  x_error_message              OUT NOCOPY VARCHAR2
)

IS

  l_party_id_tbl               l_party_id_tbl_type;
  l_user_id                    asg_user.user_id%TYPE;
  l_msg_data                   VARCHAR2(3000);
  l_sqlerrmsg                  VARCHAR2(3000);
  l_sqlerrno                   VARCHAR2(20);
  l_error_message              VARCHAR2(3000);

  CURSOR csr_get_party_id (p_user_id IN NUMBER)
  IS
    SELECT cpa.party_id
    FROM   csm_party_assignment cpa
    WHERE  cpa.user_id = p_user_id
    AND    cpa.party_site_id in (-1,-2)
    AND    cpa.deleted_flag = 'N';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN  csr_get_party_id (p_user_id);

  IF l_party_id_tbl.COUNT > 0

  THEN

  l_party_id_tbl.DELETE;

  END IF;

  FETCH csr_get_party_id BULK COLLECT INTO l_party_id_tbl;

  IF l_party_id_tbl.COUNT = 0

  THEN

    FND_MESSAGE.SET_NAME ('CSM', 'CSM_PARTY_FOR_USER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO Data found for the given user - '||p_user_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_get_party_id;

  IF (csr_get_party_id%ISOPEN)

  THEN

   CLOSE csr_get_party_id;

  END IF;

    p_party_id_lst := l_party_id_tbl;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'The party records for the user are fetched successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_encoded   => 'T',
          p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_PARTY_ASSIGN_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER Procedure :'||'while fetching the parties for the user -'
      ||p_user_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTIES_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

END get_parties_for_user;

PROCEDURE get_party_locations_for_user
( p_api_version_number                IN  NUMBER,
  p_init_msg_list                     IN  VARCHAR2 :=FND_API.G_FALSE,
  p_user_id                           IN  NUMBER,
  p_party_id                          IN  NUMBER,
  p_location_id                       OUT NOCOPY l_party_id_tbl_type,
  p_operation                         IN  VARCHAR2,
  x_msg_count                         OUT NOCOPY NUMBER,
  x_return_status                     OUT NOCOPY VARCHAR2,
  x_error_message                     OUT NOCOPY VARCHAR2
)

IS

  l_party_site_id_tbl                 l_party_id_tbl_type;
  l_user_id                           asg_user.user_id%TYPE;
  l_party_id                          csm_parties_acc.party_id%TYPE;
  l_msg_data                          VARCHAR2(3000);
  l_sqlerrmsg                         VARCHAR2(3000);
  l_sqlerrno                          VARCHAR2(20);
  l_error_message                     VARCHAR2(3000);

  CURSOR csr_get_party_site_id (p_user_id IN NUMBER, p_party_id IN NUMBER)
  IS
    SELECT cpa.party_site_id
    FROM   csm_party_assignment cpa
    WHERE  cpa.user_id  = p_user_id
    AND    cpa.party_id = p_party_id
    AND    cpa.party_site_id not in (-1,-2)
    AND    cpa.deleted_flag = 'N';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN  csr_get_party_site_id  (p_user_id, p_party_id);

  IF l_party_site_id_tbl.COUNT > 0

  THEN

    l_party_site_id_tbl.DELETE;

  END IF;

  FETCH csr_get_party_site_id BULK COLLECT INTO l_party_site_id_tbl;

  IF l_party_site_id_tbl.COUNT = 0

  THEN

    FND_MESSAGE.SET_NAME ('CSM', 'CSM_SITE_FOR_USER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO Data found for the given user - '||p_user_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_get_party_site_id ;

    p_location_id := l_party_site_id_tbl;

  IF (csr_get_party_site_id%ISOPEN)

  THEN

   CLOSE csr_get_party_site_id;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'The party locations records for the user are fetched successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER Package ', 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_PARTY_ASSIGN_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER Procedure :'||'while fetching the parties and party sites for the user -'
      ||p_user_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_PARTY_DOWNLOAD_PUB.GET_PARTY_LOCATIONS_FOR_USER',FND_LOG.LEVEL_EXCEPTION);

 END get_party_locations_for_user;

 END CSM_PARTY_DOWNLOAD_PUB;

/
