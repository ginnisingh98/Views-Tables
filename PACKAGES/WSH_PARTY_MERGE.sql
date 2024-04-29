--------------------------------------------------------
--  DDL for Package WSH_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PARTY_MERGE" AUTHID CURRENT_USER as
/* $Header: WSHPAMRS.pls 120.3 2006/03/30 17:23:39 rlanka noship $ */

G_PACKAGE_NAME CONSTANT VARCHAR2(50) := 'WSH_PARTY_MERGE';

 --========================================================================
  -- PROCEDURE :merge_carriers
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id				Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			 Returns the staus of call
 --
 -- COMMENT   : Carriers cannot be merged.
 --========================================================================
PROCEDURE merge_carriers(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2);

 --========================================================================
  -- PROCEDURE :merge_carrier_sites
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id				Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			 Returns the staus of call
 --
 -- COMMENT   : Carriers Sites cannot be merged.
 --========================================================================

PROCEDURE merge_carrier_sites(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name IN             VARCHAR2,
p_batch_id                IN             NUMBER,
p_batch_party_id	IN             NUMBER,
x_return_status		IN  OUT NOCOPY VARCHAR2);

 --========================================================================
  -- PROCEDURE :merge_party_locations
  -- PARAMETERS:
  --		p_entity_name			Name of Entity Being Merged
  --		p_from_id				Primary Key Id of the entity that is being merged
  --		p_to_id				The record under the 'To Parent' that is being merged
  --		p_from_fk_id			Foreign Key id of the Old Parent Record
 --		p_to_fk_id			Foreign  Key id of the New Parent Record
 --		p_parent_entity_name	Name of Parent Entity
 --		p_batch_id			Id of the Batch
 --		p_batch_party_id		Id uniquely identifies the batch and party record that is being merged
 --		x_return_status			 Returns the staus of call
 --
 -- COMMENT :  To merge locations for parties.-Parent Entity is HZ_PARTIES.
 --			   Owner Type can be either Supplier or Customer, Carriers cannot be merged
 --			   Updates OWNER_PARTY_ID and OWNER_TYPE in WSH_LOCATION_OWNERS
 --========================================================================

PROCEDURE  merge_party_locations(
p_entity_name		IN             VARCHAR2,
p_from_id			IN             NUMBER,
p_to_id			IN  OUT NOCOPY NUMBER,
p_from_fk_id		IN             NUMBER,
p_to_fk_id		IN             NUMBER,
p_parent_entity_name	IN             VARCHAR2,
p_batch_id              IN             NUMBER,
p_batch_party_id	IN             NUMBER,
x_return_status		IN  OUT NOCOPY VARCHAR2);

 --========================================================================
  -- PROCEDURE :	Merge_supplier_sf_sites
  -- PARAMETERS:
  --		p_entity_name              Name of registered table/entity
  --		p_from_id                      Value of PK of the record being merged
  --		x_to_id                          Value of the PK of the record to which this record is mapped
  --		p_from_fk_id                  Value of the from ID (e.g. Party, Party Site, etc.) when merge is executed
 --		p_to_fk_id                     Value of the to ID (e.g. Party, Party Site, etc.) when merge is executed
 --		p_parent_entity_name  Name of parent HZ table (e.g. HZ_PARTIES, HZ_PARTY_SITES)
 --		p_batch_id                    ID of the batch
 --		p_batch_party_id          ID of the batch and Party record
 --		x_return_status             Return status
 --
 -- COMMENT :
 --========================================================================
Procedure Merge_supplier_sf_sites (
	p_entity_name          IN           VARCHAR2,
	p_from_id                  IN           NUMBER,
	x_to_id                      OUT   NOCOPY  NUMBER,
	p_from_fk_id             IN           NUMBER,
	p_to_fk_id                 IN           NUMBER,
	p_parent_entity_name IN        VARCHAR2,
	p_batch_id                IN           NUMBER,
	p_batch_party_id      IN           NUMBER,
	x_return_status       OUT    NOCOPY  VARCHAR2  );



--========================================================================
-- PROCEDURE : Update_Entities_During_merge
--
-- PARAMETERS:
--
--     p_to_id                     Merge To Vendor ID
--     p_from_id                   Merge From Vendor ID
--     p_from_party_id             Merge From Party ID
--     p_to_party_id               Merge To Party ID
--     p_to_site_id                Merge To Site ID
--     p_from_site_id              Merge From Site ID
--     p_site_merge                Indicates whether this is a site merge
--     p_from_supplier_name        Merge From Supplier Name
--     x_return_status             Return status
--
--
-- COMMENT : This procedure is used to merge vendor level calendar assignments
--           during Party Merge and Vendor Merge.
--
--==========================================================================

PROCEDURE Update_Entities_during_Merge
       (
         p_to_id         IN NUMBER,
         p_from_id       IN NUMBER,
         p_from_party_id IN NUMBER,
         p_to_party_id   IN NUMBER,
         p_to_site_id    IN NUMBER,
         p_from_site_id  IN NUMBER,
         p_site_merge    IN BOOLEAN,
         p_from_supplier_name IN VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2
       );



-- ============================================================================
--
-- R12 FP Bug 5075838
--
-- PROCEDURE  :    MERGE_LOCATION
-- PARAMETERS :
--   p_entity_name         Name of Entity Being Merged
--   p_from_id             Primary Key Id of the entity that is being merged
--   p_to_id               The record under the 'To Parent' that is being
--                         merged
--   p_from_fk_id          Foreign Key id of the Old Parent Record
--   p_to_fk_id            Foreign  Key id of the New Parent Record
--   p_parent_entity_name  Name of Parent Entity
--   p_batch_id            Id of the Batch
--   p_batch_party_id      Id uniquely identifies the batch and party record
--                         that is being merged
--   x_return_status       Returns the status of call
--
-- COMMENT :
--   To update locations in Wsh_Delivery_Details, Wsh_New_Deliveries,
--   Wsh_Trip_Stops tables for Unshipped delivery lines during party
--   merge. Also updates Wsh_Picking_Rules tables during party merge.
-- ============================================================================
PROCEDURE merge_location(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2);


END WSH_PARTY_MERGE;

 

/
