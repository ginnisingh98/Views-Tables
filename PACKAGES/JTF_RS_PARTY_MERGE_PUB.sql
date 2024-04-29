--------------------------------------------------------
--  DDL for Package JTF_RS_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_PARTY_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbms.pls 120.0 2005/05/11 08:19:21 appldev ship $ */
/*#
 * Party Merge API for Resource manager
 * This API contains the procedures to Party merge, Party site merge and Party contact merge in Resource manager.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Party Merge API for Resource manager
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
 * @rep:businessevent oracle.apps.jtf.jres.resource.merge
*/

/************************************************************

This is the part and party site merge package for jtf resources

 *****************************************************************************/

/*#
 * Resource Party Merge API
 * This procedure allows to merge two party resources or partner resources.
 * @param p_entity_name Entity Name
 * @param p_from_id From Resource Identifier
 * @param p_from_fk_id From Party Identifier
 * @param p_to_fk_id To Party Identifier
 * @param p_parent_entity_name Parent Entity Name
 * @param p_batch_id Batch Identifier
 * @param p_batch_party_id Batch Party Identifier
 * @param x_return_status Output parameter for return status
 * @param x_to_id Out parameter for To Resource Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Resource Party Merge API
 * @rep:businessevent oracle.apps.jtf.jres.resource.merge
*/
PROCEDURE resource_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY NUMBER,
              		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY VARCHAR2);

/*#
 * Resource Party Site Merge API
 * This procedure allows to merge two party Sites in Resource Manager.
 * @param p_entity_name Entity Name
 * @param p_from_id From Resource Identifier
 * @param p_from_fk_id From Party Identifier
 * @param p_to_fk_id To Party Identifier
 * @param p_parent_entity_name Parent Entity Name
 * @param p_batch_id Batch Identifier
 * @param p_batch_party_id Batch Party Identifier
 * @param x_to_id Out parameter for To Resource Identifier
 * @param x_return_status Output parameter for return status
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Resource Party Site Merge API
 * @rep:businessevent oracle.apps.jtf.jres.resource.merge
*/
PROCEDURE resource_party_site_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY NUMBER,
              		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY VARCHAR2);

/*#
 * Resource Party Contact Merge API
 * This procedure allows to merge two party Contacts in Resource Manager.
 * @param p_entity_name Entity Name
 * @param p_from_id From Resource Identifier
 * @param p_from_fk_id From Party Identifier
 * @param p_to_fk_id To Party Identifier
 * @param p_parent_entity_name Parent Entity Name
 * @param p_batch_id Batch Identifier
 * @param p_batch_party_id Batch Party Identifier
 * @param x_to_id Out parameter for To Resource Identifier
 * @param x_return_status Output parameter for return status
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Resource Party Contact Merge API
*/
PROCEDURE resource_party_cont_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY NUMBER,
              		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY VARCHAR2);

/*#
 * Resource Support Site Merge API
 * This procedure allows to merge two support sites in Resource Manager.
 * @param p_entity_name Entity Name
 * @param p_from_id From Resource Identifier
 * @param p_from_fk_id From Party Site Identifier
 * @param p_to_fk_id To Party Site Identifier
 * @param p_parent_entity_name Parent Entity Name
 * @param p_batch_id Batch Identifier
 * @param p_batch_party_id Batch Party Identifier
 * @param x_to_id Out parameter for To Resource Identifier
 * @param x_return_status Output parameter for return status
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Resource Support Site Merge API
*/
PROCEDURE resource_support_site_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY NUMBER,
                           p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
                           p_batch_id                   IN   NUMBER,
                           p_batch_party_id             IN   NUMBER,
                           x_return_status              OUT NOCOPY VARCHAR2);

end;

 

/
