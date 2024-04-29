--------------------------------------------------------
--  DDL for Package CSI_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: csipymgs.pls 120.0 2005/05/24 17:45:56 appldev noship $ */

/******************************************************************************
    Parameters: Applies to all APIs

       IN - All IN parameters are REQUIRED.
        p_entity_name         VARCHAR2 - Name of the entity that is being merged
        p_from_id             NUMBER   - Id of the record that is being merged
        p_from_fk_id          NUMBER   - Id of the Old Parent
        p_to_fk_id            NUMBER   - Id of the New Parent
        p_parent_entity_name  VARCHAR2 - Parent entity name
        p_batch_id            NUMBER   - Id of the Batch
        p_batch_party_id      NUMBER   - Id of the batch and party record
      OUT NOCOPY:
        x_to_id               NUMBER   - Id of the record under the new parent
                                         that its merged to
        x_return_status       VARCHAR2 - Return the status of the procedure
******************************************************************************/

PROCEDURE CSI_ITEM_INSTANCES_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE CSI_I_PARTIES_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE CSI_SYSTEMS_B_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE CSI_T_PARTY_DETAILS_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE CSI_T_TXN_SYSTEMS_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE CSI_T_TXN_LINE_DETAILS_MERGE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

END  CSI_PARTY_MERGE_PKG;

 

/
