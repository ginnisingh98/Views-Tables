--------------------------------------------------------
--  DDL for Package OKC_REP_PARTY_MERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_PARTY_MERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGREPMERGES.pls 120.0 2005/05/25 19:09:47 appldev noship $ */

  ------------------------------------------------------------------------------------
  -- Global Constants
  ------------------------------------------------------------------------------------
   G_PACKAGE_NAME              CONSTANT   VARCHAR2(1) := 'OKC_REP_PARTY_MERGE_GRP';


   G_PARTNER_ROLE              CONSTANT   VARCHAR2(1) := 'PARTNER_ORG';
   G_CUSTOMER_ROLE             CONSTANT   VARCHAR2(1) := 'CUSTOMER_ORG';
   G_SUPPLIER_ROLE             CONSTANT   VARCHAR2(1) := 'SUPPLIER_ORG';

   G_OKC_REP_DOCUMENT_CLASS    CONSTANT   VARCHAR2(30) := 'REPOSITORY';


   G_HZ_PARTY_ENTITY           CONSTANT   VARCHAR2(30) := 'HZ_PARTIES';
   G_HZ_PARTY_SITES_ENTITY     CONSTANT   VARCHAR2(30) := 'HZ_PARTY_SITES';
   G_OKC_REP_PARTY_ENTITY      CONSTANT   VARCHAR2(30) := 'OKC_REP_CONTRACT_PARTIES';


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
                        p_batch_party_id IN NUMBER);

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
                             p_batch_party_id IN NUMBER);

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
  --IN            : p_entity_name         IN VARCHAR2
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
  --              : p_parent_entity_name  IN VARCHAR2
  --              :                        Entity name of the parent which is being merged.
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
                        p_batch_party_id IN NUMBER);

  -- Start of comments
  --API name      : party_site_merge
  --Type          : Group.
  --Procedure     : Merge Parties from HZ_PARTY_SITES table that are referenced from
  --                 OKC_REP_CONTRACT_PARTIES.location_id table.
  --Pre-reqs      : None.
  --Parameters    :
  --IN            : p_entity_name         IN VARCHAR2
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
  --              : p_parent_entity_name  IN VARCHAR2
  --              :                        Entity name of the parent which is being merged.
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
                             p_batch_party_id IN NUMBER);


END OKC_REP_PARTY_MERGE_GRP;

 

/
