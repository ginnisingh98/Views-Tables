--------------------------------------------------------
--  DDL for Package Body PA_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MERGE_PKG" AS
--$Header: PAXTCAMB.pls 120.0 2005/05/30 15:00:29 appldev noship $
--
PROCEDURE party_merge(
p_entity_name                IN   VARCHAR2,
p_from_id                    IN   NUMBER,
x_to_id                      OUT  NOCOPY  NUMBER,
p_from_fk_id                 IN   NUMBER,
p_to_fk_id                   IN   NUMBER,
p_parent_entity_name         IN   VARCHAR2,
p_batch_id                   IN   NUMBER,
p_batch_party_id             IN   NUMBER,
x_return_status              OUT  NOCOPY  VARCHAR2)
IS

begin

  -- This API is currently not doing anything. It just rejects the merge.
  -- We do this to avoid merge in TCA for 11.5.9. For 11.5.9, we are not
  -- ready to merge Project entities. So if a party_id referenced in projects
  -- is merged, we reject it. This API will be enhanced immediately after
  -- 11.5.9 to support the merge.

  x_return_status := fnd_api.g_ret_sts_error;

  fnd_message.set_name ('PA', 'PA_REJECT_MERGE');
  FND_MSG_PUB.add;

END party_merge;

PROCEDURE control_items_owner_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    UPDATE pa_control_items
    SET owner_id = p_to_fk_id
    WHERE owner_id = p_from_fk_id;

    x_to_id := p_from_id;

  END IF;
END control_items_owner_id;

PROCEDURE control_items_last_mod_by_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    UPDATE pa_control_items
    SET last_modified_by_id = p_to_fk_id
    WHERE last_modified_by_id = p_from_fk_id;

    x_to_id := p_from_id;

  END IF;
END control_items_last_mod_by_id;

PROCEDURE control_items_closed_by_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    UPDATE pa_control_items
    SET closed_by_id = p_to_fk_id
    WHERE closed_by_id = p_from_fk_id;

    x_to_id := p_from_id;

  END IF;
END control_items_closed_by_id;

PROCEDURE ci_actions_assigned_to(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    UPDATE pa_ci_actions
    SET assigned_to = p_to_fk_id
    WHERE assigned_to = p_from_fk_id;

    x_to_id := p_from_id;

  END IF;
END ci_actions_assigned_to;

PROCEDURE ci_impacts_implemented_by(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2)
IS
  l_dummy NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    UPDATE pa_ci_impacts
    SET implemented_by = p_to_fk_id
    WHERE implemented_by = p_from_fk_id;

    x_to_id := p_from_id;

  END IF;
END ci_impacts_implemented_by;

PROCEDURE project_parties_res_src_id(
  p_entity_name                IN   VARCHAR2,
  p_from_id                    IN   NUMBER,
  x_to_id                      OUT  NOCOPY  NUMBER,
  p_from_fk_id                 IN   NUMBER,
  p_to_fk_id                   IN   NUMBER,
  p_parent_entity_name         IN   VARCHAR2,
  p_batch_id                   IN   NUMBER,
  p_batch_party_id             IN   NUMBER,
  x_return_status              OUT  NOCOPY  VARCHAR2)
IS
  l_dummy NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_fk_id <> p_to_fk_id) THEN
    BEGIN
--Looking for a grant from PA for the party being merged
      SELECT 1
      INTO l_dummy
      FROM fnd_grants g, fnd_objects o
      WHERE o.application_id = 275
        AND g.object_id = o.object_id
        AND g.grantee_type = 'USER'
        AND g.grantee_key = 'HZ_PARTY:'||p_from_fk_id
        AND ROWNUM = 1;

--Veto if grant is found for the same party, because grants are not yet merged
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MESSAGE.SET_NAME('PA', 'PA_REJECT_MERGE');
      FND_MSG_PUB.add;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        UPDATE pa_project_parties
        SET resource_source_id = p_to_fk_id
        WHERE resource_source_id = p_from_fk_id
          AND resource_type_id = 112;

      x_to_id := p_from_id;

    END;
  END IF;
END project_parties_res_src_id;

PROCEDURE update_project_parties_res_id(
  p_from_resource_id IN NUMBER,
  p_to_resource_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_from_resource_id <> p_to_resource_id) THEN
    UPDATE pa_project_parties
    SET resource_id = p_to_resource_id
    WHERE resource_id = p_from_resource_id;
  END IF;
END update_project_parties_res_id;

end;

/
