--------------------------------------------------------
--  DDL for Package CSC_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: cscvmpts.pls 115.2 2002/12/04 16:19:02 bhroy noship $ */
-- Start of Comments
-- Package name     : CSC_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate parties in Customer Care tables. The
--                    Customer Care table that need to be considered for
--                    Party Merge are:
--                    CSC_CUSTOMERS,              CSC_CUSTOMERS_AUDIT_HIST,
--                    CSC_CUSTOMIZED_PLANS,       CSC_CUST_PLANS,
--                    CSC_CUST_PLANS_AUDIT,       CSC_PROF_BLOCK_RESULTS,
--                    CSC_PROF_CHECK_RESULTS.
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-10-2000    dejoseph      Created.
-- 10-25-2001    dejoseph      Included command for auto db driver.
--                             Ref bug # 2076739.
--
-- End of Comments

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  csc_customers_merge
   --   Purpose :  Merges parties in CSC_CUSTOMERS table
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
   --   OUT NOCOPY:
   --     x_to_id               NUMBER   - Id of the record under the new parent
   --                                      that its merged to
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE CSC_CUSTOMERS_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  csc_cust_plans_merge
   --   Purpose :  Performs party merge in CSC_CUST_PLANS table. For every record
   --              updated in CSC_CUST_PLANS, insert a row in CSC_CUST_PLANS_AUDIT
   --              table to record the merge operation
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
   --   OUT NOCOPY:
   --     x_to_id               NUMBER   - Id of the record under the new parent
   --                                      that its merged to
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE CSC_CUST_PLANS_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  csc_customized_plans_merge
   --   Purpose :  Performs party merge in CSC_CUSTOMIZED_PLANS table. If there are
   --              duplicate plans existing between the two merging parties, then
   --              delete the rows of the merge from party in this table.
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
   --   OUT NOCOPY:
   --     x_to_id               NUMBER   - Id of the record under the new parent
   --                                      that its merged to
   --     x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE CSC_CUSTOMIZED_PLANS_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2);

END  CSC_PARTY_MERGE_PKG;

 

/
