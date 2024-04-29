--------------------------------------------------------
--  DDL for Package PVX_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxvmrgs.pls 120.1 2005/05/31 11:29:30 appldev  $ */

-- Start of Comments
-- Package name     : PVX_PARTY_MERGE_PKG
--
-- Purpose          : Merges duplicate parties in PV tables. The
--                    PV tables that need to be considered for
--                    Party Merge are:
--                    PV_PARTNER_PROFILES
--                    PV_ENTY_ATTR_VALUES

-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
--
-- End of Comments




PROCEDURE MERGE_REFERRALS_B (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);



   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_PARTNER_PROFILES
   --   Purpose :  Merges parties in PARTNER_PROFILES  table
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

PROCEDURE MERGE_PARTNER_PROFILES1(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE MERGE_PARTNER_PROFILES2(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_PARTNER_ENTITY_ATTRIBUTES
   --   Purpose :  Merges parties in PV_ENTY_ATTR_VALUES  table
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

PROCEDURE MERGE_PARTNER_ENTITY_ATTRS(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_LEAD_ASSIGNMENTS
   --   Purpose :  Merges parties in PV_LEAD_ASSIGNMENTS  table
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

PROCEDURE MERGE_LEAD_ASSIGNMENTS(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_ASSIGNMENT_LOGS
   --   Purpose :  Merges parties in PV_ASSIGNMENT_LOGS  table
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

PROCEDURE MERGE_ASSIGNMENT_LOGS(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_SEARCH_ATTR_VALUES
   --   Purpose :  Merges parties in PV_SEARCH_ATTR_VALUES  table
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

PROCEDURE MERGE_SEARCH_ATTR_VALUES(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_LEAD_PSS_LINES
   --   Purpose :  Merges parties in PV_LEAD_PSS_LINES  table
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

PROCEDURE MERGE_LEAD_PSS_LINES(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_GE_PARTY_NOTIFICATIONS
   --   Purpose :  Merges parties in PV_GE_PARTY_NOTIFICATIONS  table
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

PROCEDURE MERGE_GE_PARTY_NOTIFICATIONS(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_PG_ENRL_REQUESTS
   --   Purpose :  Merges parties in PV_PG_ENRL_REQUESTS  table
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

PROCEDURE MERGE_PG_ENRL_REQUESTS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_PG_MEMBERSHIPS
   --   Purpose :  Merges parties in PV_PG_MEMBERSHIPS   table
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

PROCEDURE MERGE_PG_MEMBERSHIPS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  MERGE_PARTNER_ACCESSES
   --   Purpose :  Merges partner_id in PV_PARTNER_ACCESSES   table
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

PROCEDURE MERGE_PARTNER_ACCESSES (
    p_entity_name             IN              VARCHAR2
   ,p_from_id                 IN              NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN              NUMBER
   ,p_to_fk_id                IN              NUMBER
   ,p_parent_entity_name      IN              VARCHAR2
   ,p_batch_id                IN              NUMBER
   ,p_batch_party_id          IN              NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE MERGE_PV_GE_PTNR_RESPS (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2
);

PROCEDURE MERGE_CONTRACT_BINDING_CONTACT (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    p_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2
);


END  PVX_PARTY_MERGE_PKG;

 

/
