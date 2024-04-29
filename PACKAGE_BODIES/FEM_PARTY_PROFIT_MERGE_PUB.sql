--------------------------------------------------------
--  DDL for Package Body FEM_PARTY_PROFIT_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_PARTY_PROFIT_MERGE_PUB" AS
-- $Header: femprfMB.pls 120.0 2005/06/06 20:57:50 appldev noship $



procedure merge_profitability (
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY  NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY     VARCHAR2)


IS

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Perform the Merge */

   /* If Parent (i.e., Party ID) has NOT changed, then nothing needs to be done.  Set
      Merged To ID is the same as Merged From ID and Return  */

   IF p_from_FK_id = p_to_FK_id THEN
      p_to_id := p_from_id;

      RETURN;
   END IF;

   /********************************************************************************
    If the Party_ID (Parent) has changed, then we are deleting the existing profitability of the "From"
    Party_ID and replacing with the profitability of the "To" Party_ID.  If the "To" Party_ID does
    not exist, we will just update the "From" Party_ID to the new Party ID
    *******************************************************************************/

   IF p_from_FK_id <> p_to_FK_id THEN

      IF p_parent_entity_name = 'HZ_PARTIES' THEN

         /*delete the existing target party ID  */
         DELETE FROM FEM_PARTY_PROFITABILITY
         WHERE party_id = p_To_Fk_id;


         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE FEM_PARTY_PROFITABILITY
         SET party_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE party_id = p_From_FK_id;
         RETURN;


      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_profitability;


END FEM_PARTY_PROFIT_MERGE_PUB;

/
