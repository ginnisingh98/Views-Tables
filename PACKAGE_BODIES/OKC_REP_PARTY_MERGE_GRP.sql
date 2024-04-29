--------------------------------------------------------
--  DDL for Package Body OKC_REP_PARTY_MERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_PARTY_MERGE_GRP" AS
/* $Header: OKCGREPMERGEB.pls 120.0 2005/05/25 22:49:48 appldev noship $ */


  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

  -- Start of comments
  --API name      : party_merge
  --Type          : Group.
  --Procedure     : Merge Parties from HZ_PARTIES table that are referenced from
  --                 OKC_REP_CONTRACT_PARTIES table.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_entity_name         IN HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE
  --              :                        p_entity_name is the registered entity for which
  --              :                        this routine is being called.  It should have the value
  --              :                        OKC_REP_CONTRACT_PARTIES.
  --              :
  --              : p_from_id             IN ROWID
  --              :                        PK of the entity that is being merged.
  --              :
  --              : x_to_id               OUT ROWID
  --
  --              : p_from_fk_id          IN NUMBER
  --              :                        Old PK of the entity being merged.
  --              :
  --              : p_to_fk_id            IN NUMBER
  --              :                        New PK of the entity being merged.
  --              :
  --              : p_parent_entity_name  IN HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE
  --              :                        Entity name of the parent which is being merged.
  --              :                        This should have the value HZ_PARTIES.
  --              :
  --              : p_batch_id            IN NUMBER
  --              :                        ID of the batch.
  --              :
  --              : p_batch_party_id      IN NUMBER
  --              :                        ID that uniquely identifies the batch and
  --              :                        party record that is being merged.
  -- End of comments

  PROCEDURE party_merge(p_entity_name IN HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE,
                        p_from_id     IN ROWID,
                        x_to_id       IN OUT NOCOPY ROWID,
                        p_from_fk_id  IN NUMBER,
                        p_to_fk_id    IN NUMBER,
                        p_parent_entity_name IN HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE,
                        p_batch_id    IN NUMBER,
                        p_batch_party_id IN NUMBER)


IS

  l_api_name VARCHAR2(30);
  l_msg_data FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;


BEGIN
  NULL;
/*
  l_api_name := 'party_merge';

  --
  -- Party Merge Routine.  Verify that this routine is being
  -- called for the appropriate parent entity merge
  -- and child entity merge.
  --

  IF (p_parent_entity_name = G_HZ_PARTY_ENTITY AND
      p_entity_name = G_OKC_REP_PARTY_ENTITY)
  THEN

    IF p_from_fk_id = p_to_fk_id
    THEN
      x_to_id := p_from_id;
      RETURN;
    END IF;

    --
    -- Update PARTY_ID with P_FROM_FK_ID to
    -- new merged PARTY_ID of P_TO_FK_ID.
    --

    IF p_from_fk_id <> p_to_fk_id
    THEN

      UPDATE okc_rep_contract_parties
	 SET party_id    = p_to_fk_id,
	     last_update_date  = sysdate,
	     last_updated_by    = fnd_global.user_id,
	     last_update_login  = fnd_global.user_id,
	     object_version_number = object_version_number+1
      WHERE  party_id = p_from_fk_id
      AND    party_role_code IN (G_PARTNER_ROLE, G_CUSTOMER_ROLE);


    END IF; -- End p_from_fk_id <> p_to_fk_id


    --
    -- Call Deliverables Merge.  This will take care of 'PARTNER_ORG' and 'CUSTOMER_ORG' roles.
    --
    OKC_MANAGE_DELIVERABLES_GRP.mergeExtPartyOnDeliverables (
     p_api_version               => 1.0,
     p_init_msg_list             => FND_API.G_FALSE,
     p_commit                    => FND_API.G_FALSE,
     p_document_class            => G_OKC_REP_DOCUMENT_CLASS,
     p_from_external_party_id    => p_from_fk_id,
     p_from_external_party_site_id => NULL,
     p_to_external_party_id        => p_to_fk_id,
     p_to_external_party_site_id   => NULL,
     x_msg_data                 => l_msg_data,
     x_msg_count                => l_msg_count,
     x_return_status            => l_return_status);



  END IF; -- End p_parent_entity = G_HZ_PARTY_ENTITY


EXCEPTION


  WHEN others THEN

    l_msg_data := substr(SQLERRM,1,70);
    arp_message.set_error(G_PACKAGE_NAME || '.' || l_api_name, l_msg_data);
    RAISE;
*/
END; -- party_merge procedure



  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

  -- Start of comments
  --API name      : party_site_merge
  --Type          : Group.
  --Procedure     : Merge Parties from HZ_PARTY_SITES table that are referenced from
  --                 OKC_REP_CONTRACT_PARTIES.location_id table.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_entity_name         IN HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE
  --              :                        p_entity_name is the registered entity for which
  --              :                        this routine is being called.  It should have the value
  --              :                        OKC_REP_CONTRACT_PARTIES.
  --              :
  --              : p_from_id             IN ROWID
  --              :                        PK of the entity that is being merged.
  --              :
  --              : x_to_id               OUT ROWID
  --
  --              : p_from_fk_id          IN NUMBER
  --              :                        Old PK of the entity being merged.
  --              :
  --              : p_to_fk_id            IN NUMBER
  --              :                        New PK of the entity being merged.
  --              :
  --              : p_parent_entity_name  IN HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE
  --              :                        Entity name of the parent which is being merged.
  --              :                        This should have the value HZ_PARTIES.
  --              :
  --              : p_batch_id            IN NUMBER
  --              :                        ID of the batch.
  --              :
  --              : p_batch_party_id      IN NUMBER
  --              :                        ID that uniquely identifies the batch and
  --              :                        party record that is being merged.
  -- End of comments

  PROCEDURE party_site_merge(p_entity_name IN HZ_MERGE_DICTIONARY.ENTITY_NAME%TYPE,
                             p_from_id     IN ROWID,
                             x_to_id       IN OUT NOCOPY ROWID,
                             p_from_fk_id  IN NUMBER,
                             p_to_fk_id    IN NUMBER,
                             p_parent_entity_name IN HZ_MERGE_DICTIONARY.PARENT_ENTITY_NAME%TYPE,
                             p_batch_id    IN NUMBER,
                             p_batch_party_id IN NUMBER)


IS
  l_api_name VARCHAR2(30);
  l_error_msg VARCHAR2(2000);
  l_msg_data VARCHAR2(2000);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;


BEGIN
  NULL;
/*
  l_api_name := 'party_site_merge';

  --
  -- Party Site Merge Routine.  Verify that this routine is being
  -- called for the appropriate parent entity merge
  -- and child entity merge.
  --

  IF (p_parent_entity_name = G_HZ_PARTY_SITES_ENTITY AND
      p_entity_name = G_OKC_REP_PARTY_ENTITY)
  THEN

    IF p_from_fk_id = p_to_fk_id
    THEN
      x_to_id := p_from_id;
      RETURN;
    END IF;

    --
    -- Update PARTY_ID with P_FROM_FK_ID to
    -- new merged PARTY_ID of P_TO_FK_ID.
    --

    IF p_from_fk_id <> p_to_fk_id
    THEN

     UPDATE okc_rep_contract_parties
	 SET party_location_id = p_to_fk_id,
	     last_update_date  = sysdate,
	     last_updated_by    = fnd_global.user_id,
	     last_update_login  = fnd_global.user_id,
	     object_version_number = object_version_number+1
      WHERE  party_location_id = p_from_fk_id
      AND    party_role_code IN (G_PARTNER_ROLE, G_CUSTOMER_ROLE);


    --
    -- Call Deliverables Merge.  This will take care of 'PARTNER_ORG' and 'CUSTOMER_ORG' roles.
    --
    OKC_MANAGE_DELIVERABLES_GRP.mergeExtPartyOnDeliverables (
     p_api_version               => 1.0,
     p_init_msg_list             => FND_API.G_FALSE,
     p_commit                    => FND_API.G_FALSE,
     p_document_class            => G_OKC_REP_DOCUMENT_CLASS,
     p_from_external_party_id    => NULL,
     p_from_external_party_site_id => p_from_fk_id,
     p_to_external_party_id        => NULL,
     p_to_external_party_site_id   => p_to_fk_id,
     x_msg_data                 => l_msg_data,
     x_msg_count                => l_msg_count,
     x_return_status            => l_return_status);



    END IF; -- End p_from_fk_id <> p_to_fk_id

  END IF; -- End p_parent_entity = G_HZ_PARTY_SITES_ENTITY


EXCEPTION


  WHEN others THEN

    l_error_msg := substr(SQLERRM,1,70);
    arp_message.set_error(G_PACKAGE_NAME || '.' || l_api_name, l_error_msg);
    RAISE;
*/
END; -- party_site_merge procedure

  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

  -- Start of comments
  --API name      : party_merge
  --Type          : Group.
  --Procedure     : Merge Parties from PO_VENDORS table that are referenced from
  --                 OKC_REP_CONTRACT_PARTIES table.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_entity_name         IN p_entity_name is the registered entity for which
  --              :                        this routine is being called.  It should have the value
  --              :                        OKC_REP_CONTRACT_PARTIES.
  --              :
  --              : p_from_id             IN ROWID
  --              :                        PK of the entity that is being merged.
  --              :
  --              : x_to_id               OUT ROWID
  --
  --              : p_from_fk_id          IN NUMBER
  --              :                        Old PK of the entity being merged.
  --              :
  --              : p_to_fk_id            IN NUMBER
  --              :                        New PK of the entity being merged.
  --              :
  --              : p_parent_entity_name  IN p_parent_entity_name is
  --              :                        entity name of the parent which is being merged.
  --              :                        This should have the value PO_VENDORS.
  --              :
  --              : p_batch_id            IN NUMBER
  --              :                        ID of the batch.
  --              :
  --              : p_batch_party_id      IN NUMBER
  --              :                        ID that uniquely identifies the batch and
  --              :                        party record that is being merged.
  -- End of comments

  PROCEDURE vendor_merge(p_entity_name IN VARCHAR2,
                        p_from_id     IN ROWID,
                        x_to_id       IN OUT NOCOPY ROWID,
                        p_from_fk_id  IN NUMBER,
                        p_to_fk_id    IN NUMBER,
                        p_parent_entity_name IN VARCHAR2,
                        p_batch_id    IN NUMBER,
                        p_batch_party_id IN NUMBER)


IS
  l_api_name VARCHAR2(30);
  l_msg_data VARCHAR2(2000);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;


BEGIN

  NULL;
/*
  l_api_name := 'vendor_merge';
  --
  -- Party Merge Routine.  Verify that this routine is being
  -- called for the appropriate parent entity merge
  -- and child entity merge.
  --

  IF (p_parent_entity_name = G_HZ_PARTY_ENTITY AND
      p_entity_name = G_OKC_REP_PARTY_ENTITY)
  THEN

    IF p_from_fk_id = p_to_fk_id
    THEN
      x_to_id := p_from_id;
      RETURN;
    END IF;

    --
    -- Update PARTY_ID with P_FROM_FK_ID to
    -- new merged PARTY_ID of P_TO_FK_ID.
    --

    IF p_from_fk_id <> p_to_fk_id
    THEN

      UPDATE okc_rep_contract_parties
	    SET party_id    = p_to_fk_id,
	     last_update_date  = sysdate,
	     last_updated_by    = fnd_global.user_id,
	     last_update_login  = fnd_global.user_id,
	     object_version_number = object_version_number+1
      WHERE  party_id = p_from_fk_id
      AND    party_role_code = G_SUPPLIER_ROLE;


    END IF; -- End p_from_fk_id <> p_to_fk_id


    --
    -- Call Deliverables Merge for 'SUPPLIER_ORG' Party Role
    --
    OKC_MANAGE_DELIVERABLES_GRP.updateExtPartyOnDeliverables(
      p_api_version               => 1.0,
      p_init_msg_list             => FND_API.G_FALSE,
      p_commit                    => FND_API.G_FALSE,
      p_document_class            => G_OKC_REP_DOCUMENT_CLASS,
      p_from_external_party_id    => p_from_fk_id,
      p_from_external_party_site_id  => NULL,
      p_to_external_party_id         => p_to_fk_id,
      p_to_external_party_site_id    => NULL,
      x_msg_data                  => l_msg_data,
      x_msg_count                 => l_msg_count,
      x_return_status             => l_return_status);


  END IF; -- End vendor_merge = G_HZ_PARTY_ENTITY


EXCEPTION


  WHEN others THEN

    l_msg_data := substr(SQLERRM,1,70);
    arp_message.set_error(G_PACKAGE_NAME || '.' || l_api_name, l_msg_data);
    RAISE;

*/

END; -- vendor_merge procedure



  ---------------------------------------------------------------------------
  -- START: Procedures and Functions
  ---------------------------------------------------------------------------

  -- Start of comments
  --API name      : party_site_merge
  --Type          : Group.
  --Procedure     : Merge Parties from HZ_PARTY_SITES table that are referenced from
  --                 OKC_REP_CONTRACT_PARTIES.location_id table.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : vendor_site_merge      IN p_entity_name is the registered entity for which
  --              :                        this routine is being called.  It should have the value
  --              :                        OKC_REP_CONTRACT_PARTIES.
  --              :
  --              : p_from_id             IN ROWID
  --              :                        PK of the entity that is being merged.
  --              :
  --              : x_to_id               OUT ROWID
  --
  --              : p_from_fk_id          IN NUMBER
  --              :                        Old PK of the entity being merged.
  --              :
  --              : p_to_fk_id            IN NUMBER
  --              :                        New PK of the entity being merged.
  --              :
  --              : p_parent_entity_name  IN p_parent_entity_name is
  --              :                        entity name of the parent which is being merged.
  --              :                        This should have the value PO_VENDORS.
  --              :
  --              : p_batch_id            IN NUMBER
  --              :                        ID of the batch.
  --              :
  --              : p_batch_party_id      IN NUMBER
  --              :                        ID that uniquely identifies the batch and
  --              :                        party record that is being merged.
  -- End of comments

  PROCEDURE vendor_site_merge(p_entity_name IN VARCHAR2,
                             p_from_id     IN ROWID,
                             x_to_id       IN OUT NOCOPY ROWID,
                             p_from_fk_id  IN NUMBER,
                             p_to_fk_id    IN NUMBER,
                             p_parent_entity_name IN VARCHAR2,
                             p_batch_id    IN NUMBER,
                             p_batch_party_id IN NUMBER)


IS
  l_api_name VARCHAR2(30);
  l_error_msg VARCHAR2(2000);
  l_msg_data VARCHAR2(2000);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;


BEGIN
  NULL;
/*
  l_api_name := 'vendor_site_merge';
  --
  -- Party Site Merge Routine.  Verify that this routine is being
  -- called for the appropriate parent entity merge
  -- and child entity merge.
  --

  IF (p_parent_entity_name = G_HZ_PARTY_SITES_ENTITY AND
      p_entity_name = G_OKC_REP_PARTY_ENTITY)
  THEN

    IF p_from_fk_id = p_to_fk_id
    THEN
      x_to_id := p_from_id;
      RETURN;
    END IF;

    --
    -- Update PARTY_ID with P_FROM_FK_ID to
    -- new merged PARTY_ID of P_TO_FK_ID.
    --

    IF p_from_fk_id <> p_to_fk_id
    THEN

      UPDATE okc_rep_contract_parties
	    SET party_location_id    = p_to_fk_id,
	     last_update_date  = sysdate,
	     last_updated_by    = fnd_global.user_id,
	     last_update_login  = fnd_global.user_id,
	     object_version_number = object_version_number+1
      WHERE  party_location_id = p_from_fk_id
      AND    party_role_code = G_SUPPLIER_ROLE;

    --
    -- Call Deliverables Merge for 'SUPPLIER_ORG' Party Role
    --
    OKC_MANAGE_DELIVERABLES_GRP.mergeExtPartyOnDeliverables (
      p_api_version               => 1.0,
      p_init_msg_list             => FND_API.G_FALSE,
      p_commit                    => FND_API.G_FALSE,
      p_document_class            => G_OKC_REP_DOCUMENT_CLASS,
      p_external_party_role       => G_SUPPLIER_ROLE,
      p_from_external_party_id    => NULL,
      p_from_external_party_site_id  => p_from_fk_id,
      p_to_external_party_id         => NULL,
      p_to_external_party_site_id    => p_to_fk_id,
      x_msg_data                  => l_msg_data,
      x_msg_count                 => l_msg_count,
      x_return_status             => l_return_status);


    END IF; -- End p_from_fk_id <> p_to_fk_id

  END IF; -- End p_parent_entity = G_HZ_PARTY_SITES_ENTITY


EXCEPTION


  WHEN others THEN

    l_error_msg := substr(SQLERRM,1,70);
    arp_message.set_error(G_PACKAGE_NAME || '.' || l_api_name, l_error_msg);
    RAISE;
*/
END; -- vendor_site_merge procedure

END OKC_REP_PARTY_MERGE_GRP;

/
