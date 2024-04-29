--------------------------------------------------------
--  DDL for Package RRS_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_PARTY_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: RRSPMRGS.pls 120.0 2005/09/21 08:00 pfarkade noship $ */

 --========================================================================
  -- PROCEDURE :merge_site_party
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id			Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	        Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			Returns the staus of call
 --
 -- COMMENT   : Merge of Real Estate party with another Real Estate or Non-Real Estate party is not allowed.
 --             When an Legal Entity Party is getting merged update the records in RRS_SITES_B.
 --========================================================================
PROCEDURE MERGE_SITE_PARTY(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN             NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY VARCHAR2);

 --========================================================================
  -- PROCEDURE :merge_le_party
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id			Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	        Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			Returns the staus of call
 --
 -- COMMENT :  When an Legal Entity Party is getting merged, update the records in RRS_SITES_B.
 --==========================================================================

PROCEDURE  MERGE_LE_PARTY(
p_entity_name		IN             VARCHAR2,
p_from_id		IN             NUMBER,
p_to_id			IN             NUMBER,
p_from_fk_id		IN             NUMBER,
p_to_fk_id		IN             NUMBER,
p_parent_entity_name	IN             VARCHAR2,
p_batch_id              IN             NUMBER,
p_batch_party_id	IN             NUMBER,
x_return_status		OUT NOCOPY VARCHAR2);

 --===========================================================================
 END RRS_PARTY_MERGE_PKG;

/
