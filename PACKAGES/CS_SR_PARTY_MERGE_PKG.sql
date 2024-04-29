--------------------------------------------------------
--  DDL for Package CS_SR_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: cssrpmgs.pls 115.7 2004/01/22 01:37:13 spusegao noship $ */
-- Start of Comments
-- Package name     : CS_SR_PARTY_MERGE_PKG
--
-- Purpose          : Merges duplicate parties in Service tables. The
--                    Service tables that need to be considered for
--                    Party Merge are:
--                    CS_INCIDENTS_ALL_B
--                    CS_HZ_SR_CONTACT_POINTS
--                    CS_INCIDENTS_AUDIT_B

-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-10-2000    asequeir      Created.
-- 07-02-2002    dejoseph      Made changes for SR Party Merge performance bug 2271992.
--                             - Created the following procedure so that the same proc. is
--                               not used by more than one FK. This gets rid of the decode
--                               as well as the 'or' predicate in the update statement.
--                               - cs_inc_all_merge_bill_to_cont
--                               - cs_inc_all_merge_ship_to_cont
--                               - cs_inc_all_merge_ct_site_id
--                               - cs_inc_all_merge_inst_site_use
--                               - cs_audit_merge_old_bill_cont
--                               - cs_audit_merge_ship_to_cont
--                               - cs_audit_merge_old_ship_cont
--                               - cs_audit_merge_old_site_id
--                             - Added the dbdrv and checkfile commands.
-- 08-29-2002   dejoseph       - Cont'd of performance fixes for bug 2271992
--                               Procedure name that has changed:
--                               - CS_INC_ALL_MERGE_BILL_SITE_USE to
--                                 CS_INC_ALL_MERGE_SITE_USES
--
-- End of Comments

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_PARTY
   --   Purpose :  Merges customer_id in CS_INCIDENTS_ALL_B  table
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
PROCEDURE CS_INC_ALL_MERGE_PARTY(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_BILL_TO_CONT
   --   Purpose :  Merges bill_to_contact_id in CS_INCIDENTS_ALL_B  table
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
PROCEDURE CS_INC_ALL_MERGE_BILL_TO_CONT(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_SHIP_TO_CONT
   --   Purpose :  Merges ship_to_contact_id in CS_INCIDENTS_ALL_B  table
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
PROCEDURE CS_INC_ALL_MERGE_SHIP_TO_CONT(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_SITE_USES
   --   Purpose :  Performs bill_to_site_use merge in CS_INCIDENTS_ALL_B table.
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
PROCEDURE CS_INC_ALL_MERGE_SITE_USES (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_SHIP_SITE_USE
   --   Purpose :  Performs ship_to-site_use merge in CS_INCIDENTS_ALL_B table.
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
PROCEDURE CS_INC_ALL_MERGE_SHIP_SITE_USE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_SITE_ID
   --   Purpose :  Performs site_id merge in CS_INCIDENTS_ALL_B
   --              table.
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
PROCEDURE  CS_INC_ALL_MERGE_SITE_ID(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_CT_SITE_ID
   --   Purpose :  Performs customer_site_id merge in CS_INCIDENTS_ALL_B
   --              table.
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
PROCEDURE  CS_INC_ALL_MERGE_CT_SITE_ID(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_INST_SITE_USE
   --   Purpose :  Merges install_site_use_id in CS_INCIDENTS_ALL_B  table
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
PROCEDURE CS_INC_ALL_MERGE_INST_SITE_USE(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_AUDIT_MERGE_PARTY
   --   Purpose :  Performs bill_to_contact_id merge in CS_INCIDENT_AUDIT_B table.
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
PROCEDURE CS_AUDIT_MERGE_PARTY(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_AUDIT_MERGE_OLD_BILL_CONT
   --   Purpose :  Performs old_bill_to_contact_id ids  merge in CS_INCIDENT_AUDIT_B table.
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
PROCEDURE CS_AUDIT_MERGE_OLD_BILL_CONT (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_AUDIT_MERGE_SHIP_TO_CONT
   --   Purpose :  Performs ship_to_contact_id merge in CS_INCIDENT_AUDIT_B table.
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
PROCEDURE CS_AUDIT_MERGE_SHIP_TO_CONT (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_AUDIT_MERGE_OLD_SHIP_CONT
   --   Purpose :  Performs old_ship_to_contact_id merge in CS_INCIDENT_AUDIT_B table.
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
PROCEDURE CS_AUDIT_MERGE_OLD_SHIP_CONT(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_AUDIT_MERGE_SITE_ID
   --   Purpose :  Performs site_id merge in CS_INCIDENT_AUDIT_B table.
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
PROCEDURE CS_AUDIT_MERGE_SITE_ID(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_AUDIT_MERGE_OLD_SITE_ID
   --   Purpose :  Performs old_site_id merge in CS_INCIDENT_AUDIT_B table.
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
PROCEDURE CS_AUDIT_MERGE_OLD_SITE_ID(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_CONTACTS_MERGE_PARTY
   --   Purpose :  Performs party id merge in CS_HZ_SR_CONTACT_POINTS table.
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
PROCEDURE CS_CONTACTS_MERGE_PARTY(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_CONTACTS_MERGE_CONT_POINTS
   --   Purpose :  Performs contact_point id merge in CS_HZ_SR_CONTACT_POINTS table.
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
PROCEDURE CS_CONTACTS_MERGE_CONT_POINTS(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  CS_INC_ALL_MERGE_CONT_POINTS
   --   Purpose :  Performs customer_phone_id and customer_email_id merge in
   --              CS_INCIDENTS_ALL_B table.
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
PROCEDURE CS_INC_ALL_MERGE_CONT_POINTS(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);


END  CS_SR_PARTY_MERGE_PKG;


 

/
