--------------------------------------------------------
--  DDL for Package Body XLE_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_PARTY_MERGE_PUB" AS
/* $Header: xleptymergeb.pls 120.4 2006/03/31 06:01:02 cjain ship $ */

--                                 Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding recipient_id need to be merged
--========================================================================
PROCEDURE merge_registrations(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES' or 'HZ_PARTY_STIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  XLE_REGISTRATIONS
  Where issuing_authority_id = p_from_fk_id
  for update nowait;

 Cursor C2 is
  Select 'X' from
  XLE_REGISTRATIONS
  Where issuing_authority_site_id = p_from_fk_id
  for update nowait;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   --check the merge reason, if merge reason is 'Duplicate Record' then no validation is performed.
   --otherwise check if the resource is being used somewhere
   SELECT merge_reason_code
   INTO   l_merge_reason_code
   FROM   hz_merge_batch
   WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   ELSE
	 -- if there are any validations to be done, include it in this section
	 null;
   END IF;

   /* Perform the Merge */

   /* If Parent (i.e., Party ID) has NOT changed, then nothing needs to be done.  Set
      Merged To ID is the same as Merged From ID and Return  */

   IF p_from_FK_id = p_to_FK_id THEN
      p_to_id := p_from_id;

      RETURN;
   END IF;

   /********************************************************************************
    If the Party_ID (Parent) has changed, then transfer the dependent record to the
	new parent.
    *******************************************************************************/

   IF p_from_FK_id <> p_to_FK_id THEN
      IF p_parent_entity_name = 'HZ_PARTIES' THEN

         fnd_message.set_name('XLE', 'XLE_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'XLE_REGISTRATIONS', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('XLE', 'XLE_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'XLE_REGISTRATIONS', FALSE);

         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE XLE_REGISTRATIONS
         SET issuing_authority_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE issuing_authority_id = p_From_FK_id;

         RETURN;

    ELSIF p_Parent_Entity_name = 'HZ_PARTY_SITES' THEN

        fnd_message.set_name('XLE', 'XLE_LOCKING_TABLE');
        fnd_message.set_token('TABLE_NAME', 'XLE_REGISTRATIONS', FALSE);

        Open C2;
        Close C2;

        fnd_message.set_name('XLE', 'XLE_UPDATING_TABLE');
        fnd_message.set_token('TABLE_NAME', 'XLE_REGISTRATIONS', FALSE);

         UPDATE XLE_REGISTRATIONS
         SET issuing_authority_site_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE issuing_authority_site_id = p_From_FK_id;
        RETURN;
      END IF;
   END IF;

EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('XLE','XLE_REGISTRATIONS_LOCK');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('XLE','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_registrations;


--========================================================================
-- PROCEDURE : merge_reg_functions   Called by HZ Party merge routine
--                                Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding party_id needs to be merged
--========================================================================
PROCEDURE merge_reg_functions(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES' or 'HZ_PARTY_SITES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  XLE_REG_FUNCTIONS
  Where authority_id = p_from_fk_id
  for update nowait;

  Cursor C2 is
  Select 'X' from
  XLE_REG_FUNCTIONS
  Where authority_site_id = p_from_fk_id
  for update nowait;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --check the merge reason, if merge reason is 'Duplicate Record' then no validation is performed.
   --otherwise check if the resource is being used somewhere
   SELECT merge_reason_code
   INTO   l_merge_reason_code
   FROM   hz_merge_batch
   WHERE  batch_id  = p_batch_id;

   IF l_merge_reason_code = 'DUPLICATE' THEN
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   ELSE
	 -- if there are any validations to be done, include it in this section
	 null;
   END IF;

   /* Perform the Merge */

   /* If Parent (i.e., Party ID) has NOT changed, then nothing needs to be done.  Set
      Merged To ID is the same as Merged From ID and Return  */

   IF p_from_FK_id = p_to_FK_id THEN
      p_to_id := p_from_id;

      RETURN;
   END IF;

   /********************************************************************************
    If the Party_ID (Parent) has changed, then transfer the dependent record to the
	new parent.
    *******************************************************************************/

   IF p_from_FK_id <> p_to_FK_id THEN

      IF p_parent_entity_name = 'HZ_PARTIES' THEN

         fnd_message.set_name('XLE', 'XLE_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'XLE_REG_FUNCTIONS', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('XLE', 'XLE_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'XLE_REG_FUNCTIONS', FALSE);

         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE XLE_REG_FUNCTIONS
         SET authority_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE authority_id = p_From_FK_id;
        RETURN;

    ELSIF p_Parent_Entity_name = 'HZ_PARTY_SITES' THEN

         fnd_message.set_name('XLE', 'XLE_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'XLE_REG_FUNCTIONS', FALSE);

         Open C2;
		 Close C2;

         fnd_message.set_name('XLE', 'XLE_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'XLE_REG_FUNCTIONS', FALSE);

         UPDATE XLE_REG_FUNCTIONS
         SET authority_site_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE authority_site_id = p_From_FK_id;
         RETURN;
    END IF;
   END IF;
EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('XLE','XLE_REG_FUNCTIONS');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('XLE','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END merge_reg_functions;

--========================================================================
-- PROCEDURE : merge_legal_entities     Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             It should veto the merging of legal entities.
--========================================================================

PROCEDURE merge_legal_entities(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2)

IS

BEGIN

  -- always veto legal entity merge

  fnd_message.set_name('XLE','XLE_LEGAL_ENTITY_VETO_MERGE');
  fnd_msg_pub.ADD;
  x_return_status  := fnd_api.g_ret_sts_error ;

  EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('XLE','HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END merge_legal_entities;

--========================================================================
-- PROCEDURE : merge_establishments     Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             It should veto the merging of establishments.
--========================================================================

PROCEDURE merge_establishments(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2)

IS
BEGIN

  -- always veto establishments merge

  fnd_message.set_name('XLE','XLE_ESTABLISHMENT_VETO_MERGE');
  fnd_msg_pub.ADD;
  x_return_status  := fnd_api.g_ret_sts_error ;

  EXCEPTION
     WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('XLE','HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END merge_establishments;



END XLE_PARTY_MERGE_PUB;


/
