--------------------------------------------------------
--  DDL for Package Body AHL_UC_INSTANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_INSTANCE_PUB" AS
/* $Header: AHLPUCIB.pls 120.0.12010000.2 2008/11/20 11:38:50 sathapli ship $ */

--Define global internal variables
G_PKG_NAME VARCHAR2(30) := 'AHL_UC_UNITCONFIG_PUB';


--Define global cursor
CURSOR get_csi_ii_ovn(c_subject_id number) IS
SELECT object_version_number
  FROM csi_ii_relationships
 WHERE subject_id = c_subject_id
   AND relationship_type_code = 'COMPONENT-OF'
   AND trunc(nvl(active_start_date, SYSDATE)) <= trunc(SYSDATE)
   AND trunc(nvl(active_end_date, SYSDATE+1)) > trunc(SYSDATE);

--Define local procedures
PROCEDURE validate_uc_header(p_uc_header_id  IN NUMBER,
                             p_uc_name       IN VARCHAR2,
                             x_uc_header_id  OUT NOCOPY NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2)
IS
  CURSOR get_uc_header_id IS
  SELECT unit_config_header_id
    FROM ahl_unit_config_headers
   WHERE name = p_uc_name;
  CURSOR check_uc_header_id IS
  SELECT unit_config_header_id
    FROM ahl_unit_config_headers
   WHERE unit_config_header_id = p_uc_header_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_uc_header_id := p_uc_header_id;

  IF p_uc_header_id IS NULL AND p_uc_name IS NULL THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'uc_name');
    FND_MESSAGE.set_token('VALUE', p_uc_name);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  ELSIF p_uc_header_id IS NULL AND p_uc_name IS NOT NULL THEN
    OPEN get_uc_header_id;
    FETCH get_uc_header_id INTO x_uc_header_id;
    IF get_uc_header_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'uc_name');
      FND_MESSAGE.set_token('VALUE', p_uc_name);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE get_uc_header_id;
  ELSIF p_uc_header_id IS NOT NULL AND p_uc_name IS NULL THEN
    OPEN check_uc_header_id;
    FETCH check_uc_header_id INTO x_uc_header_id;
    IF check_uc_header_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'uc_header_id');
      FND_MESSAGE.set_token('VALUE', p_uc_header_id);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE check_uc_header_id;
  ELSIF p_uc_header_id IS NOT NULL AND p_uc_name IS NOT NULL THEN
    OPEN get_uc_header_id;
    FETCH get_uc_header_id INTO x_uc_header_id;
    IF get_uc_header_id%NOTFOUND OR p_uc_header_id <> x_uc_header_id THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'uc_name');
      FND_MESSAGE.set_token('VALUE', p_uc_name);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE get_uc_header_id;
  END IF;
END;

PROCEDURE validate_csi_instance(p_instance_id   IN NUMBER,
                                p_instance_num  IN VARCHAR2,
                                x_instance_id   OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2)
IS
  CURSOR get_instance_id IS
  SELECT instance_id
    FROM csi_item_instances
   WHERE instance_number = p_instance_num;
  CURSOR check_instance_id IS
  SELECT instance_id
    FROM csi_item_instances
   WHERE instance_id = p_instance_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_instance_id := p_instance_id;

  IF p_instance_id IS NULL AND p_instance_num IS NULL THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'instance_number');
    FND_MESSAGE.set_token('VALUE', p_instance_num);
    FND_MSG_PUB.add;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  ELSIF p_instance_id IS NULL AND p_instance_num IS NOT NULL THEN
    OPEN get_instance_id;
    FETCH get_instance_id INTO x_instance_id;
    IF get_instance_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'instance_number');
      FND_MESSAGE.set_token('VALUE', p_instance_num);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE get_instance_id;
  ELSIF p_instance_id IS NOT NULL AND p_instance_num IS NULL THEN
    OPEN check_instance_id;
    FETCH check_instance_id INTO x_instance_id;
    IF check_instance_id%NOTFOUND THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'instance_id');
      FND_MESSAGE.set_token('VALUE', p_instance_id);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE check_instance_id;
  ELSIF p_instance_id IS NOT NULL AND p_instance_num IS NOT NULL THEN
    OPEN get_instance_id;
    FETCH get_instance_id INTO x_instance_id;
    IF get_instance_id%NOTFOUND OR p_instance_id <> x_instance_id THEN
      FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
      FND_MESSAGE.set_token('NAME', 'instance_number');
      FND_MESSAGE.set_token('VALUE', p_instance_num);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    CLOSE get_instance_id;
  END IF;
END;

-- Define procedure unassociate_instance
-- This API is used to to nullify a child instance's position reference but keep
-- the parent-child relationship in a UC tree structure (in other word, to make
-- the child instance as an extra node in the UC).
PROCEDURE unassociate_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_instance_id           IN  NUMBER := NULL,
  p_instance_num          IN  VARCHAR2,
  p_prod_user_flag        IN  VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'unassociate_instance';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_id              NUMBER;
  l_instance_id               NUMBER;
  l_csi_ii_ovn                NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT unassociate_instance;

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

  --Validate the parameters which are not present in the private API. All the other
  --parameters are validated in the corresponding private API.
  --Validate the pair of p_uc_name and p_uc_header_id
  validate_uc_header(p_uc_header_id,
                     p_uc_name,
                     l_uc_header_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_instance_num and p_instance_id
  validate_csi_instance(p_instance_id,
                     p_instance_num,
                     l_instance_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the object_version_number of the record in csi_ii_relationships which has p_instance_id
  --as the subject_id. This public API doesn't contain the validation to check whether
  --p_instance_id is installed in p_uc_header_id which is done in the private API.
  OPEN get_csi_ii_ovn(l_instance_id);
  FETCH get_csi_ii_ovn INTO l_csi_ii_ovn;
  IF get_csi_ii_ovn%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'instance_id');
    FND_MESSAGE.set_token('VALUE', l_instance_id);
    FND_MSG_PUB.add;
    CLOSE get_csi_ii_ovn;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE get_csi_ii_ovn;

  --Calling the corresponding private API
  ahl_uc_instance_pvt.unassociate_instance_pos(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_instance_id           => l_instance_id,
        p_csi_ii_ovn            => l_csi_ii_ovn,
        p_prod_user_flag        => p_prod_user_flag);

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
    ROLLBACK TO unassociate_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO unassociate_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO unassociate_instance;
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
END unassociate_instance;

-- Define procedure remove_instance
-- This API is used to to remove(uninstall) an instance (leaf, branch node or
-- sub-unit) from a UC node. After uninstallation, this instance is available to be
-- reinstalled in another appropriate position.
PROCEDURE remove_instance (
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_instance_id           IN  NUMBER := NULL,
  p_instance_num          IN  VARCHAR2,
  p_prod_user_flag        IN  VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'remove_instance';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_id              NUMBER;
  l_instance_id               NUMBER;
  l_csi_ii_ovn                NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT remove_instance;

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

  --Validate the parameters which are not present in the private API. All the other
  --parameters are validated in the corresponding private API.
  --Validate the pair of p_uc_name and p_uc_header_id
  validate_uc_header(p_uc_header_id,
                     p_uc_name,
                     l_uc_header_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_instance_num and p_instance_id
  validate_csi_instance(p_instance_id,
                     p_instance_num,
                     l_instance_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the object_version_number of the record in csi_ii_relationships which has p_instance_id
  --as the subject_id. This public API doesn't contain the validation to check whether
  --p_instance_id is installed in p_uc_header_id which is done in the private API.
  OPEN get_csi_ii_ovn(l_instance_id);
  FETCH get_csi_ii_ovn INTO l_csi_ii_ovn;
  IF get_csi_ii_ovn%NOTFOUND THEN
    FND_MESSAGE.set_name('AHL','AHL_UC_API_PARAMETER_INVALID');
    FND_MESSAGE.set_token('NAME', 'instance_id');
    FND_MESSAGE.set_token('VALUE', l_instance_id);
    FND_MSG_PUB.add;
    CLOSE get_csi_ii_ovn;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE get_csi_ii_ovn;

  --Calling the corresponding private API
  ahl_uc_instance_pvt.remove_instance(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_instance_id           => l_instance_id,
        p_csi_ii_ovn            => l_csi_ii_ovn,
        p_prod_user_flag        => p_prod_user_flag);

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
    ROLLBACK TO remove_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO remove_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO remove_instance;
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
END remove_instance;

-- Define procedure update_instance
-- This API is used to update an instance's (top node or non top node) attributes
-- (serial Number, serial_number_tag, lot_number, revision, mfg_date and etc.)
PROCEDURE update_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_uc_instance_rec       IN  ahl_uc_instance_pvt.uc_instance_rec_type,
  p_prod_user_flag        IN  VARCHAR2)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'update_instance';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_id              NUMBER;
  l_instance_id               NUMBER;
  l_csi_ii_ovn                NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT update_instance;

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

  --Validate the parameters which are not present in the private API. All the other
  --parameters are validated in the corresponding private API.
  --Validate the pair of p_uc_name and p_uc_header_id
  validate_uc_header(p_uc_header_id,
                     p_uc_name,
                     l_uc_header_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Calling the corresponding private API
  ahl_uc_instance_pvt.update_instance_attr(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_uc_instance_rec       => p_uc_instance_rec,
        p_prod_user_flag        => p_prod_user_flag);

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
    ROLLBACK TO update_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO update_instance;
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
END update_instance;

-- Define procedure create_install_instance
-- This API is used to create a new instance in csi_item_instances and assign it
-- to a UC node. And if the UC node happens to be the root node of a sub-unit, then
-- it also create the corresponding sub UC header record as well.
PROCEDURE create_install_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_parent_instance_id    IN  NUMBER := NULL,
  p_parent_instance_num   IN  VARCHAR2,
  p_prod_user_flag        IN  VARCHAR2,
  p_x_uc_instance_rec     IN OUT NOCOPY ahl_uc_instance_pvt.uc_instance_rec_type,
  p_x_sub_uc_rec          IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'create_install_instance';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_id              NUMBER;
  l_instance_id               NUMBER;
  l_csi_ii_ovn                NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT create_install_instance;

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

  --Validate the parameters which are not present in the private API. All the other
  --parameters are validated in the corresponding private API.
  --Validate the pair of p_uc_name and p_uc_header_id
  validate_uc_header(p_uc_header_id,
                     p_uc_name,
                     l_uc_header_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_instance_num and p_instance_id
  validate_csi_instance(p_parent_instance_id,
                        p_parent_instance_num,
                        l_instance_id,
                        l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Calling the corresponding private API
  ahl_uc_instance_pvt.install_new_instance(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_parent_instance_id    => l_instance_id,
        p_prod_user_flag        => p_prod_user_flag,
        p_x_uc_instance_rec     => p_x_uc_instance_rec,
        p_x_sub_uc_rec          => p_x_sub_uc_rec,
        x_warning_msg_tbl       => x_warning_msg_tbl);

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
    ROLLBACK TO create_install_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_install_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO create_install_instance;
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
END create_install_instance;

-- Define procedure install_instance
-- This API is used to assign an existing instance to a UC node.
PROCEDURE install_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_parent_instance_id    IN  NUMBER := NULL,
  p_parent_instance_num   IN  VARCHAR2,
  p_instance_id           IN  NUMBER := NULL,
  p_instance_num          IN  VARCHAR2,
  p_relationship_id       IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'install_instance';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_id              NUMBER;
  l_instance_id               NUMBER;
  l_parent_instance_id        NUMBER;
  l_csi_ii_ovn                NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT install_instance;

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

  --Validate the parameters which are not present in the private API. All the other
  --parameters are validated in the corresponding private API.
  --Validate the pair of p_uc_name and p_uc_header_id
  validate_uc_header(p_uc_header_id,
                     p_uc_name,
                     l_uc_header_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_instance_num and p_instance_id
  validate_csi_instance(p_instance_id,
                        p_instance_num,
                        l_instance_id,
                        l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_parent_instance_num and p_parent_instance_id
  validate_csi_instance(p_parent_instance_id,
                        p_parent_instance_num,
                        l_parent_instance_id,
                        l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the object_version_number of the record in csi_ii_relationships which has p_instance_id
  --as the subject_id and p_parent_instance_id as the object_id and also position_reference is
  --NULL(extra). This public API doesn't contain the validation to check whether
  --p_relationship_id is valid which is done in the private API.
  OPEN get_csi_ii_ovn(l_instance_id);
  FETCH get_csi_ii_ovn INTO l_csi_ii_ovn;
  IF get_csi_ii_ovn%NOTFOUND THEN
    l_csi_ii_ovn := NULL;
  END IF;
  CLOSE get_csi_ii_ovn;

  --Calling the corresponding private API
  ahl_uc_instance_pvt.install_existing_instance(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_parent_instance_id    => l_parent_instance_id,
        p_instance_id           => l_instance_id,
        p_instance_number       => NULL,
        p_relationship_id       => p_relationship_id,
        p_csi_ii_ovn            => l_csi_ii_ovn,
        p_prod_user_flag        => p_prod_user_flag,
        x_warning_msg_tbl       => x_warning_msg_tbl);

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
    ROLLBACK TO install_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO install_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO install_instance;
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
END install_instance;

-- Define procedure swap_instances
-- This API is used by Production user to make parts change: replace an old instance
-- with a new one in a UC tree.
PROCEDURE swap_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_parent_instance_id    IN  NUMBER := NULL,
  p_parent_instance_num   IN  VARCHAR2,
  p_old_instance_id       IN  NUMBER := NULL,
  p_old_instance_num      IN  VARCHAR2,
  p_new_instance_id       IN  NUMBER := NULL,
  p_new_instance_num      IN  VARCHAR2,
  p_relationship_id       IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)
IS
  l_api_name       CONSTANT   VARCHAR2(30)   := 'swap_instance';
  l_api_version    CONSTANT   NUMBER         := 1.0;
  l_uc_header_id              NUMBER;
  l_old_instance_id           NUMBER;
  l_new_instance_id           NUMBER;
  l_parent_instance_id        NUMBER;
  l_csi_ii_ovn                NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

BEGIN
  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Standard Start of API savepoint
  SAVEPOINT swap_instance;

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

  --Validate the parameters which are not present in the private API. All the other
  --parameters are validated in the corresponding private API.
  --Validate the pair of p_uc_name and p_uc_header_id
  validate_uc_header(p_uc_header_id,
                     p_uc_name,
                     l_uc_header_id,
                     l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_old_instance_num and p_old_instance_id
  validate_csi_instance(p_old_instance_id,
                        p_old_instance_num,
                        l_old_instance_id,
                        l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_new_instance_num and p_new_instance_id
  validate_csi_instance(p_new_instance_id,
                        p_new_instance_num,
                        l_new_instance_id,
                        l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Validate the pair of p_parent_instance_num and p_parent_instance_id
  validate_csi_instance(p_parent_instance_id,
                        p_parent_instance_num,
                        l_parent_instance_id,
                        l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Get the object_version_number of the record in csi_ii_relationships which has p_instance_id
  --as the subject_id and p_parent_instance_id as the object_id and also position_reference is
  --NULL(extra). This public API doesn't contain the validation to check whether
  --p_relationship_id is valid which is done in the private API.
  OPEN get_csi_ii_ovn(l_old_instance_id);
  FETCH get_csi_ii_ovn INTO l_csi_ii_ovn;
  IF get_csi_ii_ovn%NOTFOUND THEN
    l_csi_ii_ovn := NULL;
  END IF;
  CLOSE get_csi_ii_ovn;

  --Calling the corresponding private API
  ahl_uc_instance_pvt.swap_instance(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_parent_instance_id    => l_parent_instance_id,
        p_old_instance_id       => l_old_instance_id,
        p_new_instance_id       => l_new_instance_id,
        p_new_instance_number   => NULL,
        p_relationship_id       => p_relationship_id,
        p_csi_ii_ovn            => l_csi_ii_ovn,
        p_prod_user_flag        => p_prod_user_flag,
        x_warning_msg_tbl       => x_warning_msg_tbl);

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
    ROLLBACK TO swap_instance;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO swap_instance;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO swap_instance;
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
END swap_instance;

-- SATHAPLI::FP ER 6504147, 18-Nov-2008
-- Define procedure create_unassigned_instance.
-- This API is used to create a new instance in csi_item_instances as an extra
-- instance attached to the root node.
PROCEDURE create_unassigned_instance(
    p_api_version           IN            NUMBER   := 1.0,
    p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_uc_header_id          IN            NUMBER,
    p_uc_name               IN            VARCHAR2,
    p_x_uc_instance_rec     IN OUT NOCOPY ahl_uc_instance_pvt.uc_instance_rec_type)
IS
    l_api_name       CONSTANT   VARCHAR2(30)   := 'create_unassigned_instance';
    l_full_name      CONSTANT   VARCHAR2(70)   := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;
    l_api_version    CONSTANT   NUMBER         := 1.0;
    l_uc_header_id              NUMBER;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'Start of the API');
    END IF;

    -- Standard start of API savepoint
    SAVEPOINT create_unassigned_instance;

    -- Initialize Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    -- Validate the parameters which are not present in the private API. All the other
    -- parameters are validated in the corresponding private API.
    -- Validate the pair of p_uc_name and p_uc_header_id
    validate_uc_header(p_uc_header_id,
                       p_uc_name,
                       l_uc_header_id,
                       l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Calling the corresponding private API
    ahl_uc_instance_pvt.create_unassigned_instance(
        p_api_version           => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_uc_header_id          => l_uc_header_id,
        p_x_uc_instance_rec     => p_x_uc_instance_rec);

    -- Check the return status after calling private API
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit
    IF FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
    ( p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE
    );

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name,'End of the API');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        Rollback to create_unassigned_instance;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        Rollback to create_unassigned_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
        Rollback to create_unassigned_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg( p_pkg_name       => G_PKG_NAME,
                                 p_procedure_name => l_api_name,
                                 p_error_text     => SQLERRM);
        FND_MSG_PUB.Count_And_Get( p_count   => x_msg_count,
                                   p_data    => x_msg_data,
                                   p_encoded => FND_API.G_FALSE);

END create_unassigned_instance;

END AHL_UC_INSTANCE_PUB; -- Package body

/
