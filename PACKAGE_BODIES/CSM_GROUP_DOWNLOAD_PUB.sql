--------------------------------------------------------
--  DDL for Package Body CSM_GROUP_DOWNLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_GROUP_DOWNLOAD_PUB" AS
/* $Header: csmpgpdb.pls 120.2 2008/02/29 09:16:01 anaraman noship $*/

PROCEDURE assign_related_group
( p_api_version_number                    IN  NUMBER,
  p_init_msg_list                         IN  VARCHAR2 :=FND_API.G_FALSE,
  p_group_id                              IN  NUMBER,
  p_related_group_id                      IN  NUMBER,
  p_operation                             IN  VARCHAR2,
  x_msg_count                             OUT NOCOPY NUMBER,
  x_return_status                         OUT NOCOPY VARCHAR2,
  x_error_message                         OUT NOCOPY VARCHAR2
)
IS

   l_owner_id                             asg_user.owner_id%TYPE := NULL;
   l_rel_owner_id                         asg_user.owner_id%TYPE := 0;
   l_rel_user_id                          asg_user.owner_id%TYPE := NULL;
   l_rel_grp_type                         VARCHAR2(1)            := 'R';
   l_return_status                        VARCHAR2(3000);
   l_error_message                        VARCHAR2(3000) := NULL;
   l_rel_return_status                    VARCHAR2(3000);
   l_rel_error_message                    VARCHAR2(3000) := NULL;
   l_msg_data                             VARCHAR2(3000);
   l_sqlerrmsg                            VARCHAR2(3000);
   l_sqlerrno                             VARCHAR2(20);

   CURSOR csr_grp_owner_id(p_group_id IN NUMBER)
   IS
      SELECT au.owner_id
      FROM   asg_user au
      WHERE  au.group_id = p_group_id
      AND    au.user_id  = au.owner_id
      AND    au.enabled  = 'Y';

   CURSOR csr_rel_grp(p_related_group_id IN NUMBER)
   IS
      SELECT au.owner_id
      FROM   asg_user au
      WHERE  au.group_id = p_related_group_id
      AND    au.user_id  = au.owner_id
      AND    au.enabled  = 'Y';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP Package ', 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN csr_grp_owner_id (p_group_id);
  FETCH csr_grp_owner_id INTO l_owner_id;

  IF (csr_grp_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME  ('CSM', 'CSM_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    x_error_message := 'NO owner found for the given group - '||p_group_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_grp_owner_id;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert records into CSM_GROUPS table

    csm_group_download_pvt.insert_my_group
      ( P_USER_ID          => l_owner_id,
        X_RETURN_STATUS    => l_return_status,
        X_ERROR_MESSAGE    => l_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to delete records from CSM_GROUPS table

    csm_group_download_pvt.delete_my_group
      ( P_USER_ID          => l_owner_id,
        X_RETURN_STATUS    => l_return_status,
        X_ERROR_MESSAGE    => l_error_message);

  END IF;

  IF NOT (l_return_status = 'SUCCESS')

  THEN

    x_error_message := l_error_message;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  OPEN csr_rel_grp (p_related_group_id);

  l_rel_user_id := l_owner_id;

  FETCH csr_rel_grp INTO l_rel_owner_id;

  CLOSE csr_rel_grp;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert Related groups records into CSM_GROUPS table

    csm_group_download_pvt.insert_group_acc
      ( P_USER_ID          => l_rel_user_id,
        P_GROUP_ID         => p_related_group_id,
        P_OWNER_ID         => l_rel_owner_id,
        P_GROUP_TYPE       => l_rel_grp_type,
        X_RETURN_STATUS    => l_rel_return_status,
        X_ERROR_MESSAGE    => l_rel_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to insert Related groups records into CSM_GROUPS table

    csm_group_download_pvt.delete_group_acc
      ( P_USER_ID          => l_rel_user_id,
        P_GROUP_ID         => p_related_group_id,
        X_RETURN_STATUS    => l_rel_return_status,
        X_ERROR_MESSAGE    => l_rel_error_message);

  END IF;

  IF NOT (l_return_status = 'SUCCESS')

  THEN

    x_error_message := l_rel_error_message;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  IF p_operation IS NULL

  THEN

  CSM_UTIL_PKG.LOG('Value for p_operation is NULL', 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP',FND_LOG.LEVEL_EXCEPTION);

  END IF;


  IF (csr_grp_owner_id%ISOPEN)

  THEN

   CLOSE csr_grp_owner_id;

  END IF;

  IF (csr_rel_grp%ISOPEN)

  THEN

   CLOSE csr_rel_grp;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'Downloading related group to a group through CSM_GROUP_DOWNLOAD_PVT is done successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP Package ', 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP ',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := x_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_GROUP_DWNLD_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP Procedure :'||'while processing the group -'
     ||p_group_id|| 'and related group:'||p_related_group_id||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP',FND_LOG.LEVEL_EXCEPTION);

END assign_related_group;

PROCEDURE assign_mutiple_related_groups
( p_api_version_number                    IN  NUMBER,
  p_init_msg_list                         IN  VARCHAR2 :=FND_API.G_FALSE,
  p_group_id                              IN  NUMBER,
  p_related_group_lst                     IN  l_group_id_tbl_type,
  p_operation                             IN  VARCHAR2,
  x_msg_count                             OUT NOCOPY NUMBER,
  x_return_status                         OUT NOCOPY VARCHAR2,
  x_error_message                         OUT NOCOPY VARCHAR2
)
IS

   l_rel_group_id_tbl                     l_group_id_tbl_type;
   l_owner_id                             asg_user.owner_id%TYPE := NULL;
   l_rel_user_id                          asg_user.user_id%TYPE := NULL;
   l_rel_owner_id                         asg_user.owner_id%TYPE := 0;
   l_rel_group_id                         asg_user.group_id%TYPE := NULL;
   l_rel_grp_type                         VARCHAR2(1)            := 'R';
   l_return_status                        VARCHAR2(3000);
   l_error_message                        VARCHAR2(3000) := NULL;
   l_rel_return_status                    VARCHAR2(3000);
   l_rel_error_message                    VARCHAR2(3000) := NULL;
   l_msg_data                             VARCHAR2(3000);
   l_sqlerrmsg                            VARCHAR2(3000);
   l_sqlerrno                             VARCHAR2(20);

   CURSOR csr_grp_owner_id(p_group_id IN NUMBER)
   IS
      SELECT au.owner_id
      FROM   asg_user au
      WHERE  au.group_id = p_group_id
      AND    au.user_id  = au.owner_id
      AND    au.enabled  = 'Y';

   CURSOR csr_rel_grp(p_group_id IN NUMBER)
   IS
      SELECT au.owner_id
      FROM   asg_user au
      WHERE  au.group_id = p_group_id
      AND    au.user_id  = au.owner_id
      AND    au.enabled  = 'Y';

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS Package ', 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_RELATED_GROUP',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN csr_grp_owner_id (p_group_id);
  FETCH csr_grp_owner_id INTO l_owner_id;

  IF (csr_grp_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME  ('CSM', 'CSM_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    x_error_message := 'NO owner found for the given group - '||p_group_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_grp_owner_id;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert records into CSM_GROUPS table

    csm_group_download_pvt.insert_my_group
      ( P_USER_ID          => l_owner_id,
        X_RETURN_STATUS    => l_return_status,
        X_ERROR_MESSAGE    => l_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to delete records from CSM_GROUPS table

    csm_group_download_pvt.delete_my_group
      ( P_USER_ID          => l_owner_id,
        X_RETURN_STATUS    => l_return_status,
        X_ERROR_MESSAGE    => l_error_message);

  END IF;


  IF NOT (l_return_status = 'SUCCESS')

  THEN

    x_error_message := l_error_message;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  IF l_rel_group_id_tbl.COUNT > 0 THEN

     l_rel_group_id_tbl.DELETE;

  END IF;

  l_rel_group_id_tbl       := p_related_group_lst;

  l_rel_user_id            := l_owner_id;

  FOR i IN l_rel_group_id_tbl.FIRST..l_rel_group_id_tbl.LAST LOOP

    l_rel_group_id          := l_rel_group_id_tbl(i);

    l_rel_owner_id          := NULL;

  OPEN csr_rel_grp (l_rel_group_id);
  FETCH csr_rel_grp INTO l_rel_owner_id;

  CLOSE csr_rel_grp;

  IF p_operation = 'INSERT'

  THEN

    --calling the package to insert Related groups records into CSM_GROUPS table

    csm_group_download_pvt.insert_group_acc
      ( P_USER_ID          => l_rel_user_id,
        P_GROUP_ID         => l_rel_group_id,
        P_OWNER_ID         => l_rel_owner_id,
        P_GROUP_TYPE       => l_rel_grp_type,
        X_RETURN_STATUS    => l_rel_return_status,
        X_ERROR_MESSAGE    => l_rel_error_message);

  ELSIF p_operation = 'DELETE'

  THEN

    --calling the package to insert Related groups records into CSM_GROUPS table

    csm_group_download_pvt.delete_group_acc
      ( P_USER_ID          => l_rel_user_id,
        P_GROUP_ID         => l_rel_group_id,
        X_RETURN_STATUS    => l_rel_return_status,
        X_ERROR_MESSAGE    => l_rel_error_message);

  END IF;

  IF NOT (l_rel_return_status = 'SUCCESS')

  THEN

    x_error_message := l_rel_error_message;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  END LOOP;

  COMMIT;

  IF p_operation IS NULL

  THEN

  CSM_UTIL_PKG.LOG('Value for p_operation is NULL', 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

  END IF;

  IF (csr_grp_owner_id%ISOPEN)

  THEN

   CLOSE csr_grp_owner_id;

  END IF;

  IF (csr_rel_grp%ISOPEN)

  THEN

   CLOSE csr_rel_grp;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'Downloading related group to a group through CSM_GROUP_DOWNLOAD_PVT is done successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS Package ', 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS ',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK;
      x_error_message := x_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_GROUP_DWNLD_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS Procedure :'||'while processing the group -'
      ||p_group_id|| 'and related group:'||l_rel_group_id|| ':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PUB.ASSIGN_MUTIPLE_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

END assign_mutiple_related_groups;

PROCEDURE get_related_groups
( p_api_version_number                    IN  NUMBER,
  p_init_msg_list                         IN  VARCHAR2 :=FND_API.G_FALSE,
  p_group_id                              IN  NUMBER,
  p_related_group_lst                     OUT NOCOPY l_group_id_tbl_type,
  x_msg_count                             OUT NOCOPY NUMBER,
  x_return_status                         OUT NOCOPY VARCHAR2,
  x_error_message                         OUT NOCOPY VARCHAR2
)

IS

   l_rel_group_id_tbl                     l_group_id_tbl_type;
   l_owner_id                             asg_user.owner_id%TYPE := NULL;
   l_msg_data                             VARCHAR2(3000);
   l_sqlerrmsg                            VARCHAR2(3000);
   l_sqlerrno                             VARCHAR2(20);
   l_error_message                        VARCHAR2(3000);

  CURSOR csr_get_owner_id (p_group_id IN NUMBER)
  IS
     SELECT au.owner_id
     FROM   asg_user au
     WHERE  au.group_id = p_group_id
     AND    au.user_id  = au.owner_id
     AND    au.enabled  = 'Y';

  CURSOR csr_get_rel_grp_id (p_owner_id IN NUMBER)
  IS
     SELECT acc.group_id
     FROM   csm_groups acc
     WHERE  acc.user_id         = p_owner_id
     AND    acc.group_owner_id  <> acc.user_id;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS PACKAGE ', 'CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

  IF FND_API.TO_BOOLEAN (p_init_msg_list)

  THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  OPEN  csr_get_owner_id (p_group_id);
  FETCH csr_get_owner_id INTO l_owner_id;

  IF (csr_get_owner_id%NOTFOUND)

  THEN

    FND_MESSAGE.SET_NAME ('CSM', 'CSM_OWNER_NOT_FOUND');

    FND_MSG_PUB.ADD;

    l_error_message := 'NO Data found for the given group - '||p_group_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_get_owner_id;

  IF l_rel_group_id_tbl.COUNT > 0

  THEN

    l_rel_group_id_tbl.DELETE;

  END IF;

  OPEN csr_get_rel_grp_id (l_owner_id);
  FETCH csr_get_rel_grp_id BULK COLLECT INTO l_rel_group_id_tbl;

  IF l_rel_group_id_tbl.COUNT = 0

  THEN

    FND_MESSAGE.SET_NAME  ('CSM', 'CSM_REL_GROUPS_NOT_FOUND');

    FND_MSG_PUB.ADD;

    x_error_message := 'NO related groups for the given group id - '||p_group_id;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  CLOSE csr_get_rel_grp_id;

  p_related_group_lst := l_rel_group_id_tbl;

  IF (csr_get_owner_id%ISOPEN)

  THEN

   CLOSE csr_get_owner_id;

  END IF;

  IF (csr_get_rel_grp_id%ISOPEN)

  THEN

   CLOSE csr_get_rel_grp_id;

  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    x_error_message := 'The related groups for the group id are fetched successfully';
    CSM_UTIL_PKG.LOG('Leaving CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS Package ', 'CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR

  THEN

      FND_MSG_PUB.COUNT_AND_GET
        ( p_encoded   => 'T',
          p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_message := l_error_message || ' - the error message is :'||l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

  WHEN OTHERS

  THEN

      FND_MESSAGE.SET_NAME  ('CSM', 'CSM_GROUP_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT', SQLCODE || SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_sqlerrno      := TO_CHAR(SQLCODE);
      l_sqlerrmsg     := SUBSTR(SQLERRM, 1,2000);
      FND_MSG_PUB.COUNT_AND_GET
        ( p_count     => x_msg_count,
          p_data      => l_msg_data );
      x_error_message := 'Exception in CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS Procedure :'||'while fetching the related groups for the group -'
      ||p_group_id ||':' || l_sqlerrno || ':' || l_sqlerrmsg ||'the error message is :' || l_msg_data;
      CSM_UTIL_PKG.LOG(x_error_message, 'CSM_GROUP_DOWNLOAD_PUB.GET_RELATED_GROUPS',FND_LOG.LEVEL_EXCEPTION);

END get_related_groups;

END CSM_GROUP_DOWNLOAD_PUB;

/
