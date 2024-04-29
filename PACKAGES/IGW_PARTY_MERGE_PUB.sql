--------------------------------------------------------
--  DDL for Package IGW_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PARTY_MERGE_PUB" AUTHID CURRENT_USER as
--$Header: igwtcaps.pls 115.4 2002/11/14 18:48:35 vmedikon noship $
G_package_name   VARCHAR2(30)  := 'IGW_PARTY_MERGE_PUB';

PROCEDURE person_degrees_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
              		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);


PROCEDURE person_biosketch_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);


PROCEDURE prop_location_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);


PROCEDURE prop_person_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);


PROCEDURE prop_org_party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE other_support_location_merge (
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE other_support_pi_party_merge (
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT NOCOPY  NUMBER,
               		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT NOCOPY  VARCHAR2);

END;

 

/
