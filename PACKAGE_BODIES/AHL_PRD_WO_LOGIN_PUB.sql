--------------------------------------------------------
--  DDL for Package Body AHL_PRD_WO_LOGIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_WO_LOGIN_PUB" AS
/* $Header: AHLPLGNB.pls 120.0 2005/12/05 18:08:59 sracha noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_PRD_WO_Login_PUB';

G_DEBUG_LEVEL       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG_PROC        CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_DEBUG_STMT        CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

------------------------------
-- Definition of Procedures --
------------------------------

-- Start of Comments --
--  Procedure name : Workorder_Login
--
--  Parameters  :
--
--
--  Description : This API logs a technician onto a workorder or operation. If the
--                operation sequence number passed to the API is null, then the login
--                is done at the workorder level; if the resource sequence or resource ID is not
--                passed but the workorder and operation is passed, then the login is at operation level.
--                If resource details are passed, then login is at the operation and resource level.
--
PROCEDURE Workorder_Login(p_api_version       IN         NUMBER,
                          p_init_msg_list     IN         VARCHAR2 := FND_API.G_FALSE,
                          p_commit            IN         VARCHAR2 := FND_API.G_FALSE,
                          p_validation_level  IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                          p_module_type       IN         VARCHAR2 := NULL,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2,
                          p_employee_num      IN         NUMBER   := NULL,
                          p_employee_id       IN         NUMBER   := NULL,
                          p_workorder_name    IN         VARCHAR2 := NULL,
                          p_workorder_id      IN         NUMBER   := NULL,
                          p_org_code          IN         VARCHAR2 := NULL,
                          p_operation_seq_num IN         NUMBER   := NULL,
                          p_resource_seq_num  IN         NUMBER   := NULL,
                          p_resource_id       IN         NUMBER   := NULL)

IS

l_api_version        CONSTANT NUMBER       := 1.0;
l_api_name           CONSTANT VARCHAR2(30) := 'Workorder_Login';

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PUB.Workorder_Login.begin',
                  'At the start of PLSQL procedure' );
  END IF;

  -- Standard call to check for api compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Workorder_Login_Pub;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Call private api.
  AHL_PRD_WO_LOGIN_PVT.Workorder_Login(
                          p_api_version       => 1.0,
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_commit            => FND_API.G_FALSE,
                          p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                          p_module_type       => NULL,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          p_employee_num      => p_employee_num,
                          p_employee_id       => p_employee_id,
                          p_workorder_name    => p_workorder_name,
                          p_workorder_id      => p_workorder_id,
                          p_org_code          => p_org_code,
                          p_operation_seq_num => p_operation_seq_num,
                          p_resource_seq_num  => p_resource_seq_num,
                          p_resource_id       => p_resource_id);


  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
  );

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PUB.Process_Workorder_Login.End',
                  'Exiting Procedure' );
  END IF;

--
EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Workorder_Login_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Workorder_Login_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Workorder_Login_Pub;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Workorder_Login',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END Workorder_Login;

------------------------------------------------------------------------------------------------
-- Start of Comments --
--  Procedure name : Workorder_Logout
--
--  Parameters  :
--
--
--  Description : This API logs a technician out of a workorder or operation-resource. If the
--                operation sequence number passed to the API is null, then the logout
--                is done at the workorder level; if the resource sequence or resource ID is not
--                passed but the workorder and operation is passed, then the logout is at operation level.
--                If resource details are passed, then logout is at the operation and resource level.
--

PROCEDURE Workorder_Logout(p_api_version       IN         NUMBER,
                           p_init_msg_list     IN         VARCHAR2 := FND_API.G_FALSE,
                           p_commit            IN         VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level  IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                           p_module_type       IN         VARCHAR2 := NULL,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_employee_num      IN         NUMBER   := NULL,
                           p_employee_id       IN         NUMBER   := NULL,
                           p_workorder_name    IN         VARCHAR2 := NULL,
                           p_workorder_id      IN         NUMBER   := NULL,
                           p_org_code          IN         VARCHAR2 := NULL,
                           p_operation_seq_num IN         NUMBER   := NULL,
                           p_resource_seq_num  IN         NUMBER   := NULL,
                           p_resource_id       IN         NUMBER   := NULL)

IS

l_api_version        CONSTANT NUMBER       := 1.0;
l_api_name           CONSTANT VARCHAR2(30) := 'Workorder_Logout';

BEGIN

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_PUB.Workorder_Logout.begin',
                  'At the start of PLSQL procedure' );
  END IF;


  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT Workorder_Logout_Pub;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Call private api.
  AHL_PRD_WO_LOGIN_PVT.Workorder_Logout(
                          p_api_version       => 1.0,
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_commit            => FND_API.G_FALSE,
                          p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                          p_module_type       => NULL,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          p_employee_num      => p_employee_num,
                          p_employee_id       => p_employee_id,
                          p_workorder_name    => p_workorder_name,
                          p_workorder_id      => p_workorder_id,
                          p_org_code          => p_org_code,
                          p_operation_seq_num => p_operation_seq_num,
                          p_resource_seq_num  => p_resource_seq_num,
                          p_resource_id       => p_resource_id);

  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
  );

  -- log debug message.
  IF (G_DEBUG_PROC >= G_DEBUG_LEVEL) THEN
    fnd_log.string(G_DEBUG_PROC, 'ahl.plsql.AHL_PRD_WO_LOGIN_Pub.Workorder_Logout.End',
                  'Exiting Procedure' );
  END IF;

--
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Workorder_Logout_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Workorder_Logout_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Workorder_Logout_Pub;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Workorder_Logout',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);


END Workorder_Logout ;

END AHL_PRD_WO_LOGIN_PUB;

/
