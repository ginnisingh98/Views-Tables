--------------------------------------------------------
--  DDL for Package CS_CH_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CH_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: cschmpgs.pls 120.0 2006/02/09 16:39:24 spusegao noship $ */
-- Start of Comments
-- Package name     : CS_CH_PARTY_MERGE_PKG
--
-- Purpose          : Merges duplicate party_site_id's in Charges tables. The
--                    Charges tables that need to be considered for
--                    Party Merge are:
--                    CS_ESTIMATE_DETAILS and CS_CHG_SUB_RESTRICTIONS.

-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 11-20-2000    aseethep      Created.
-- 11-08-2002    mviswana      Added NOCOPY Functionality to file
-- 05/04/2003    mviswana      Added new TCA Party Merge functionality
--                             for 11.5.9 TCA columns in Charges
-- 08/12/2003    cnemalik      For 11.5.10, added the new procedure
--                             CS_CHG_ALL_SETUP_PARTY for the
--                             Auto Submission Restriction Table.
--
-- End of Comments


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:    CS_CHG_ALL_MERGE_PARTY
   --   Purpose :  Performs bill_to_party_id/ship_to_party_id
   --              bill_to_contact_id/ship_to_contact_id merge
   --              in CS_ESTIMATE_DETAILS table.
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_entity_name         VARCHAR2 - Name of the entity that is being merged
   --     p_from_id             NUMBER   - Id of the record that is being merged
   --     p_from_fk_id          NUMBER   - Id of the Old Parent
   --     p_to_fk_id            NUMBER   - Id of the New Parent
   --     p_parent_entity_name  VARCHAR2 - Parent entity name
   --     p_batch_id            NUMBER   - Id of the Batch
   --     p_batch_party_id      NUMBER   - Id of the batch and party record
   --   OUT:
   --     x_to_id               NUMBER   - Id of the record under the new parent
   --                                      that its merged to
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --


PROCEDURE CS_CHG_ALL_MERGE_PARTY (
    p_entity_name                IN          VARCHAR2,
    p_from_id                    IN          NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN          NUMBER,
    p_to_fk_id                   IN          NUMBER,
    p_parent_entity_name         IN          VARCHAR2,
    p_batch_id                   IN          NUMBER,
    p_batch_party_id             IN          NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:   CS_CHG_ALL_MERGE_SITE_ID
   --   Purpose :  Performs invoice_to_site_id/ship_to_site_id merge
   --              in CS_ESTIMATE_DETAILS table.
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_entity_name         VARCHAR2 - Name of the entity that is being merged
   --     p_from_id             NUMBER   - Id of the record that is being merged
   --     p_from_fk_id          NUMBER   - Id of the Old Parent
   --     p_to_fk_id            NUMBER   - Id of the New Parent
   --     p_parent_entity_name  VARCHAR2 - Parent entity name
   --     p_batch_id            NUMBER   - Id of the Batch
   --     p_batch_party_id      NUMBER   - Id of the batch and party record
   --   OUT:
   --     x_to_id               NUMBER   - Id of the record under the new parent
   --                                      that its merged to
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE  CS_CHG_ALL_MERGE_SITE_ID(
    p_entity_name                IN          VARCHAR2,
    p_from_id                    IN          NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN          NUMBER,
    p_to_fk_id                   IN          NUMBER,
    p_parent_entity_name         IN         VARCHAR2,
    p_batch_id                   IN         NUMBER,
    p_batch_party_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_CHG_ALL_SETUP_PARTY
   --   Purpose :  Performs value_object_id merge
   --              in CS_CHG_SUB_RESTRICTIONS table.
   --   Type    :  Private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     p_entity_name         VARCHAR2 - Name of the entity that is being merged
   --     p_from_id             NUMBER   - Id of the record that is being merged
   --     p_from_fk_id          NUMBER   - Id of the Old Parent
   --     p_to_fk_id            NUMBER   - Id of the New Parent
   --     p_parent_entity_name  VARCHAR2 - Parent entity name
   --     p_batch_id            NUMBER   - Id of the Batch
   --     p_batch_party_id      NUMBER   - Id of the batch and party record
   --   OUT:
   --     x_to_id               NUMBER   - Id of the record under the new parent
   --                                      that its merged to
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --
   --   End of Comments

PROCEDURE  CS_CHG_ALL_SETUP_PARTY(
    p_entity_name                IN          VARCHAR2,
    p_from_id                    IN          NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN          NUMBER,
    p_to_fk_id                   IN          NUMBER,
    p_parent_entity_name         IN         VARCHAR2,
    p_batch_id                   IN         NUMBER,
    p_batch_party_id             IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);


END  CS_CH_PARTY_MERGE_PKG;



 

/
