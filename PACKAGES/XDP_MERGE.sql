--------------------------------------------------------
--  DDL for Package XDP_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_MERGE" AUTHID CURRENT_USER AS
/* $Header: XDPPMRGS.pls 120.1 2005/06/09 00:27:13 appldev  $ */
--
-- Start of Comments
-- Package name     : XDP_MERGE
-- Purpose          : Merges duplicate parties in SFM tables. The
--                    SFM tables that need to be considered for
--                    Party Merge are:
--                    XDP_ORDER_HEADERS
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 05-05-2003    spusegao      Created.
--
-- End of comments

  --   API Name:  MERGE_CUSTOMER_ID
   --   Purpose :  Merges customer_id in XDP_ORDER_HEADERS  table
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

PROCEDURE MERGE_CUSTOMER_ID(
    p_entity_name          IN   VARCHAR2,
    p_from_id              IN   NUMBER,
    x_to_id                OUT NOCOPY   NUMBER,
    p_from_fk_id           IN   NUMBER,
    p_to_fk_id             IN   NUMBER,
    p_parent_entity_name   IN   VARCHAR2,
    p_batch_id             IN   NUMBER,
    p_batch_party_id       IN   NUMBER,
    x_return_status        OUT NOCOPY   VARCHAR2);

END XDP_MERGE ;

 

/
