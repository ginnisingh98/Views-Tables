--------------------------------------------------------
--  DDL for Package CSP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_MERGE_PKG" AUTHID CURRENT_USER AS
/*$Header: cspvmrgs.pls 120.0.12010000.3 2011/07/26 15:13:59 hhaugeru ship $*/
--Start of comments
--
-- API name	: CSP_MERGE_PKG
-- Type		: Private
-- Purpose  : Merges duplicate parties in Spares tables. The
--            Spares tables that need to be considered for
--            Party Merge are:
--            CSP_MOVEORDER_HEADERS
--            CSP_PACKLIST_HEADERS
--            CSP_RS_CUST_RELATIONS
--
-- Modification History
-- Person      Date         Comments
-- ---------   -----------  ------------------------------------------
-- iouyang     23-JUL-2001  New
--

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  SDS_MERGE_PARTY_SITE
   --   Purpose :  Performs party_site_id merge
   --              in CSP_DEDICATED_SITES table.
   --   Type    :  private
   --   Pre-Req :  None.
   --   Parameters:
   -- IN - All IN parameters are REQUIRED.
   --   p_entity_name         VARCHAR2 - Name of the entity that is being merged
   --   p_from_id             NUMBER   - Id of the record that is being merged
   --   p_from_fk_id          NUMBER   - Id of the Old Parent
   --   p_to_fk_id            NUMBER   - Id of the New Parent
   --   p_parent_entity_name  VARCHAR2 - Parent entity name
   --   p_batch_id            NUMBER   - Id of the Batch
   --   p_batch_party_id      NUMBER   - Id of the batch and party record
   -- OUT:
   --   x_to_id               NUMBER   - Id of the record under the new parent
   --                                    that its merged to
   --   x_return_status       VARCHAR2 - Return the status of the procedure
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE  sds_merge_party_site(
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
   --   API Name:  MO_MERGE_PARTY_SITE
   --   Purpose :  Performs party_site_id merge
   --              in CSP_MOVEORDER_HEADERS table.
   --   Type    :  private
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
PROCEDURE  mo_merge_party_site(
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
   --   API Name:  PL_MERGE_PARTY_SITE
   --   Purpose :  Performs party_site_id merge
   --              in CSP_PACKLIST_HEADERS table.
   --   Type    :  private
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

PROCEDURE  pl_merge_party_site(
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
   --   API Name:  MERGE_CUST_ACCOUNT
   --   Purpose :  Performs customer_id merge
   --              in CSP_RS_CUST_RELATIONS table.
   --   Type    :  private
   --   Pre-Req :  None.
   --   Parameters:
   --   IN - All IN parameters are REQUIRED.
   --     req_id                NUMBER - request id
   --     set_number            NUMBER - set_number
   --     process_mode          NUMBER - process_mode
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE merge_cust_account (
        req_id      Number,
    set_num      Number,
    process_mode    Varchar2);
END; -- Package spec

/
