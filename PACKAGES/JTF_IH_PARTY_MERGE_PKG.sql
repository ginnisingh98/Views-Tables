--------------------------------------------------------
--  DDL for Package JTF_IH_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFIHPMS.pls 115.5 2002/11/08 16:48:20 rdday ship $ */
-- Start of Comments
-- Package name     : JTF_IH_PARTY_MERGE_PKG
--
-- Purpose          : Merges duplicate parties in JTF_IH_INTERACTIONS table.

-- History
-- MM-DD-YYYY    NAME          		MODIFICATIONS
-- 01-04-2001    James Baldo Jr.      	Created.
--
-- End of Comments

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  JTF_IH_MERGE_PARTY
   --   Purpose :  Merges parties in JTF_IH_INTERACTIONS  table
   --   Type    :  Public
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

PROCEDURE JTF_IH_MERGE_PARTY(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2);





END  JTF_IH_PARTY_MERGE_PKG;

 

/
