--------------------------------------------------------
--  DDL for Package Body PA_RES_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_MERGE_PKG" AS
--$Header: PARTCAMB.pls 120.0 2005/05/29 19:07:36 appldev noship $
--
PROCEDURE res_party_merge(
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
l_from_resource_id           NUMBER;
l_to_resource_id             NUMBER;
l_new_party_resource_exists  VARCHAR2(1);
l_return_status              VARCHAR2(1);
l_exists                     VARCHAR2(1);
begin

  x_return_status := fnd_api.g_ret_sts_success;

  -- This API merges the resource records in PA_RESOURCE_TXN_ATTRIBUTES.
  -- We will merge the resource record *ONLY* if it is not referenced in
  -- any PA tables. The only exception is if there is a reference in
  -- PA_PROJECT_PARTIES for a key member. We do allow merging party records
  -- for external key members, so we will allow merging the resource records for
  -- them, provided that recource record is not reference in any other PA table.
  IF p_from_fk_id <> p_to_fk_id THEN

     -- Select the resource_id corresponding to the old party id
     BEGIN
       SELECT resource_id
       INTO l_from_resource_id
       FROM PA_RESOURCE_TXN_ATTRIBUTES
       WHERE PARTY_ID = p_from_fk_id
       AND ROWNUM=1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            return;
     END;

     -- Select the resource_id corresponding to the new party id

     l_new_party_resource_exists := 'Y';

     BEGIN
       SELECT resource_id
       INTO l_to_resource_id
       FROM PA_RESOURCE_TXN_ATTRIBUTES
       WHERE PARTY_ID = p_to_fk_id
       AND ROWNUM=1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            l_new_party_resource_exists := 'N';
     END;


     IF l_new_party_resource_exists = 'N'
     THEN
       -- No record exists for new party id. Simply update
       -- the resource record for the old party id.

       UPDATE PA_RESOURCE_TXN_ATTRIBUTES
       SET        PARTY_ID               = P_TO_FK_ID,
                  last_update_date       = hz_utility_pub.last_update_date,
                  last_updated_by        = hz_utility_pub.user_id,
                  last_update_login      = hz_utility_pub.last_update_login,
                  request_id             = hz_utility_pub.request_id,
                  program_application_id = hz_utility_pub.program_application_id,
                  program_id             = hz_utility_pub.program_id,
                  program_update_date    = sysdate
       WHERE PARTY_ID = P_FROM_FK_ID;

       RETURN;
     END IF;

     -- If we are here is means there are 2 resource records - 1 for the
     -- from_party_id and 1 for the to_party_id. We need to delete the resource
     -- record corresponding to the from_party_id. All references to this
     -- resource_id needs to move to the resource corresponding to the
     -- to_party_id. The only table where the references will be updated is
     -- PA_PROJECT_PARTIES. If any other PA table references the old resource
     -- id, we will veto the merge.

     l_exists := 'N';

     BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM PA_PROJECT_ASSIGNMENTS
        WHERE RESOURCE_ID = l_from_resource_id
        AND ROWNUM = 1;

        IF l_exists = 'Y' THEN
             fnd_message.set_name ('PA', 'PA_REJECT_MERGE');
             FND_MSG_PUB.add;
             x_return_status := fnd_api.g_ret_sts_error;
             return;
        END IF;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               null;
     END;

     BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM PA_CANDIDATES
        WHERE RESOURCE_ID = l_from_resource_id
        AND ROWNUM = 1;

        IF l_exists = 'Y' THEN
             fnd_message.set_name ('PA', 'PA_REJECT_MERGE');
             FND_MSG_PUB.add;
             x_return_status := fnd_api.g_ret_sts_error;
             return;
        END IF;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               null;
     END;

     pa_ci_merge_pkg.update_project_parties_res_id
           (p_from_resource_id  => l_from_resource_id,
            p_to_resource_id    => l_to_resource_id,
            x_return_status     => l_return_status);

     delete from pa_resources
     where resource_id = l_from_resource_id;

     delete from pa_resource_txn_attributes
     where resource_id = l_from_resource_id;

  END IF; /* IF p_from_fk_id <> p_to_fk_id */

end res_party_merge;

END PA_RES_MERGE_PKG;


/
