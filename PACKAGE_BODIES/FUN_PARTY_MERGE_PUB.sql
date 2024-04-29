--------------------------------------------------------
--  DDL for Package Body FUN_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_PARTY_MERGE_PUB" AS
-- $Header:


--========================================================================
-- PROCEDURE : merge_trx_batches   Called by HZ Party merge routine
--                                 Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding initiator_id needs to be merged
--========================================================================
PROCEDURE merge_trx_batches(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  FUN_TRX_BATCHES
  Where initiator_id = p_from_fk_id
  for update nowait;

 Cursor C2 is
  Select 'X' from
  FUN_TRX_HEADERS
  Where initiator_id = p_from_fk_id
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

        IF fun_tca_pkg.get_le_id(p_from_FK_id) = fun_tca_pkg.get_le_id(p_to_FK_id) THEN
         fnd_message.set_name('FUN', 'FUN_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_TRX_BATCHES', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('FUN', 'FUN_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_TRX_BATCHES', FALSE);

         /*delete the existing target party ID  */
--         DELETE FROM FUN_TRX_BATCHES
--         WHERE party_id = p_To_Fk_id;

          /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE FUN_TRX_BATCHES
         SET initiator_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE initiator_id = p_From_FK_id;

		 Open C2;
		 Close C2;

         UPDATE FUN_TRX_HEADERS
         SET initiator_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE initiator_id = p_From_FK_id;

        END IF;

        RETURN;

      END IF;
   END IF;

EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('FUN','FUN_TRX_BATCHES_LOCK');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FUN','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_trx_batches;


--========================================================================
-- PROCEDURE : merge_trx_headers   Called by HZ Party merge routine
--                                 Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding recipient_id need to be merged
--========================================================================
PROCEDURE merge_trx_headers(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  FUN_TRX_HEADERS
  Where recipient_id = p_from_fk_id
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

        IF fun_tca_pkg.get_le_id(p_from_FK_id) = fun_tca_pkg.get_le_id(p_to_FK_id) THEN
         fnd_message.set_name('FUN', 'FUN_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_TRX_HEADERS', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('FUN', 'FUN_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_TRX_HEADERS', FALSE);

         /*delete the existing target party ID  */
--         DELETE FROM FUN_TRX_BATCHES
--         WHERE party_id = p_To_Fk_id;


         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE FUN_TRX_HEADERS
         SET recipient_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE recipient_id = p_From_FK_id;

        END IF;

        RETURN;

      END IF;
   END IF;

EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('FUN','FUN_TRX_HEADERS_LOCK');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FUN','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_trx_headers;


--========================================================================
-- PROCEDURE : merge_dist_lines   Called by HZ Party merge routine
--                                Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding party_id needs to be merged
--========================================================================
PROCEDURE merge_dist_lines(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  FUN_DIST_LINES
  Where party_id = p_from_fk_id
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

        IF fun_tca_pkg.get_le_id(p_from_FK_id) = fun_tca_pkg.get_le_id(p_to_FK_id) THEN
         fnd_message.set_name('FUN', 'FUN_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_DIST_LINES', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('FUN', 'FUN_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_DIST_LINES', FALSE);

         /*delete the existing target party ID  */
--         DELETE FROM FUN_TRX_BATCHES
--         WHERE party_id = p_To_Fk_id;


         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE FUN_DIST_LINES
         SET party_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE party_id = p_From_FK_id;

        END IF;

        RETURN;

      END IF;
   END IF;

EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('FUN','FUN_DIST_LINES_LOCK');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FUN','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_dist_lines;


--========================================================================
-- PROCEDURE : merge_customer_maps  Called by HZ Party merge routine
--                                  Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding site_use_id needs to be merged
--========================================================================
PROCEDURE merge_customer_maps(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  FUN_CUSTOMER_MAPS
  Where site_use_id = p_from_fk_id
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

      IF p_parent_entity_name = 'HZ_PARTY_SITE_USES' THEN

         fnd_message.set_name('FUN', 'FUN_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_CUSTOMER_MAPS', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('FUN', 'FUN_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_CUSTOMER_MAPS', FALSE);

         /*delete the existing target party ID  */
--         DELETE FROM FUN_TRX_BATCHES
--         WHERE party_id = p_To_Fk_id;


         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE FUN_CUSTOMER_MAPS
         SET site_use_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE site_use_id = p_From_FK_id;
         RETURN;


      END IF;
   END IF;

EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('FUN','FUN_CUSTOMER_MAPS_LOCK');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FUN','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_customer_maps;


--========================================================================
-- PROCEDURE : merge_supplier_maps  Called by HZ Party merge routine
--                                  Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding vendor_site_id needs to be merged
--========================================================================
PROCEDURE merge_supplier_maps(
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY VARCHAR2)

IS

 l_merge_reason_code          VARCHAR2(30);
 RESOURCE_BUSY           EXCEPTION;
 PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

 Cursor C1 is
  Select 'X' from
  FUN_SUPPLIER_MAPS
  Where vendor_site_id = p_from_fk_id
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

      IF p_parent_entity_name = 'HZ_PARTY_SITES' THEN

         fnd_message.set_name('FUN', 'FUN_LOCKING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_SUPPLIER_MAPS', FALSE);

         Open C1;
         Close C1;

         fnd_message.set_name('FUN', 'FUN_UPDATING_TABLE');
         fnd_message.set_token('TABLE_NAME', 'FUN_SUPPLIER_MAPS', FALSE);

         /*delete the existing target party ID  */
--         DELETE FROM FUN_TRX_BATCHES
--         WHERE party_id = p_To_Fk_id;


         /*  Update the "From" Party_ID to be equal to the new target  */
         UPDATE FUN_SUPPLIER_MAPS
         SET vendor_site_id = p_To_FK_id,
             LAST_UPDATED_BY = hz_utility_pub.user_id,
             LAST_UPDATE_DATE = hz_utility_pub.last_update_date,
             LAST_UPDATE_LOGIN = hz_utility_pub.last_update_login
         WHERE vendor_site_id = p_From_FK_id;
         RETURN;


      END IF;
   END IF;

EXCEPTION
   WHEN RESOURCE_BUSY THEN
      FND_MESSAGE.SET_NAME('FUN','FUN_SUPPLIER_MAPS_LOCK');
      FND_MSG_PUB.ADD;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FUN','HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END merge_supplier_maps;


END FUN_PARTY_MERGE_PUB;

/
