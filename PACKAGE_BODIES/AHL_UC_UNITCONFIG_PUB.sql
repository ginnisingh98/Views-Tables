--------------------------------------------------------
--  DDL for Package Body AHL_UC_UNITCONFIG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_UNITCONFIG_PUB" AS
/* $Header: AHLPUCXB.pls 115.9 2003/10/28 23:12:40 jeli noship $ */

-- Define global internal variables
G_PKG_NAME VARCHAR2(30) := 'AHL_UC_UNITCONFIG_PUB';

-- Define Procedure process_uc_header --
-- This API is used to create, update or expire a UC header record in ahl_unit_config_headers
PROCEDURE process_uc_header(
  p_api_version           IN  NUMBER    := 1.0,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_dml_flag              IN  VARCHAR2,
  p_x_uc_header_rec       IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'process_uc_header';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_ovn             NUMBER;
  l_csi_instance_ovn          NUMBEr;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  CURSOR get_ovns(c_uc_header_id number) IS
  SELECT u.object_version_number,
         c.object_version_number
    FROM ahl_unit_config_headers u,
         csi_item_instances c
   WHERE u.unit_config_header_id = c_uc_header_id
     AND u.csi_item_instance_id = c.instance_id
     AND trunc(nvl(u.active_end_date, SYSDATE+1)) > trunc(SYSDATE);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT process_uc_header;

  --Standard call to check for call compatibility.
  IF NOT FND_API.compatible_api_call(
    l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': Begin API',
			       'At the start of the procedure');
  END IF;

  --Validate p_dml_flag is one of 'C', 'U' or 'D', where
  --'C','U','D' refer to 'CREATE','UPDATE','DELETE(EXPIRE)' respectively
  IF (p_dml_flag NOT IN ('C', 'U', 'D')) THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'dml_flag');
    FND_MESSAGE.set_token('VALUE', p_dml_flag);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_dml_flag = 'C' THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			       ': before calling ahl_uc_unitconfig_pvt.create_uc_header');
    END IF;
    ahl_uc_unitconfig_pvt.create_uc_header(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        p_module_type           => NULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_x_uc_header_rec       => p_x_uc_header_rec);
  ELSIF p_dml_flag = 'U' THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			       ': before calling ahl_uc_unitconfig_pvt.update_uc_header');
    END IF;
    ahl_uc_unitconfig_pvt.update_uc_header(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        p_module_type           => NULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_x_uc_header_rec       => p_x_uc_header_rec,
        p_uc_instance_rec       => NULL);
  ELSIF p_dml_flag = 'D' THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,
			       ': before calling ahl_uc_unitconfig_pvt.delete_uc_header');
    END IF;

    --Get the object_version_number of the uc_header and csi instance record
    OPEN get_ovns(p_x_uc_header_rec.uc_header_id);
    FETCH get_ovns INTO l_uc_header_ovn, l_csi_instance_ovn;
    IF get_ovns%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'uc_header_id');
      FND_MESSAGE.set_token('VALUE', p_x_uc_header_rec.uc_header_id);
      FND_MSG_PUB.add;
      CLOSE get_ovns;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE get_ovns;
    ahl_uc_unitconfig_pvt.delete_uc_header(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => p_x_uc_header_rec.uc_header_id,
        p_object_version_number => l_uc_header_ovn,
        p_csi_instance_ovn      => l_csi_instance_ovn);
  END IF;

  --Check the return status after calling private APIs
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                   'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name||': After normal execution','At the end of the procedure');
  END IF;

  -- Get all the error messages from the previous steps (if any) and raise the appropriate Exception
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- Perform the Commit (if requested)
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT;
  END IF;
  -- Count and Get messages (optional)
  FND_MSG_PUB.count_and_get(
    p_encoded  => FND_API.G_FALSE,
    p_count    => x_msg_count,
    p_data     => x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO process_uc_header;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO process_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO process_uc_header;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
END process_uc_header;

END AHL_UC_UNITCONFIG_PUB; -- Package Body

/
