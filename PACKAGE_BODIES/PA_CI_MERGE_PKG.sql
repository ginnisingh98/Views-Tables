--------------------------------------------------------
--  DDL for Package Body PA_CI_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_MERGE_PKG" AS
--$Header: PACIMRGB.pls 120.0 2005/06/03 13:43:42 appldev noship $

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
  l_party_type hz_parties.party_type%TYPE;

  CURSOR c_parties IS
    SELECT project_party_id,
           object_id,
           object_type,
           project_role_id,
           start_date_active,
           end_date_active
    FROM pa_project_parties
    WHERE resource_source_id=p_from_fk_id
      AND resource_type_id=112;

  cp_party c_parties%ROWTYPE;

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
        SELECT party_type
        INTO l_party_type
        FROM hz_parties
        WHERE party_id = p_to_fk_id;

        IF l_party_type = 'ORGANIZATION' THEN
          FOR cp_party IN c_parties LOOP
--Looping through every project_party_id corresponding to a party_id
            BEGIN
--Detecting duplicate assignment for a given organization, regardless of effective dates
              SELECT project_party_id
              INTO l_dummy
              FROM pa_project_parties
              WHERE object_id = cp_party.object_id
                AND object_type = cp_party.object_type
                AND project_role_id = cp_party.project_role_id
                AND resource_type_id = 112
                AND resource_source_id = p_to_fk_id
                AND ROWNUM = 1;

--If duplicated, deleting the old project_party and update customer table
              UPDATE pa_project_customers
              SET project_party_id = l_dummy
              WHERE project_party_id = cp_party.project_party_id;

              DELETE FROM pa_project_parties
              WHERE project_party_id = cp_party.project_party_id;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
--Update party_id if no duplicates
                UPDATE pa_project_parties
                SET resource_source_id = p_to_fk_id
                WHERE project_party_id = cp_party.project_party_id;
            END;
          END LOOP;

        ELSE
--For non organizational parties
          UPDATE pa_project_parties
          SET resource_source_id = p_to_fk_id
          WHERE resource_type_id = 112
            AND resource_source_id = p_from_fk_id;
        END IF;

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

END;

/
