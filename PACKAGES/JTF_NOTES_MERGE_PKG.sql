--------------------------------------------------------
--  DDL for Package JTF_NOTES_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: jtfntmgs.pls 120.1 2005/07/02 00:50:51 appldev ship $ */

-- --------------------------------------------------------------------------
-- Start of notes
--  API Name    : Merge Notes
--  Type        : Package
--  Description : Party Merge for JTF_NOTES_B
--  Pre-reqs    :
--  Parameters  :
--  Standard:
--      p_entity_name                IN   VARCHAR2,
--		p_from_id                    IN   NUMBER,
--		x_to_id                      OUT  NUMBER,
--		p_from_fk_id                 IN   NUMBER,
--		p_to_fk_id                   IN   NUMBER,
--		p_parent_entity_name         IN   VARCHAR2,
--		p_batch_id                   IN   NUMBER,
--		p_batch_party_id             IN   NUMBER,
--  Version     : Initial Version     1.0
--
--  Notes       :
--
--  Version : Revision   1.1
--
--  Notes       :
--
-- End of notes
-- --------------------------------------------------------------------------

PROCEDURE MERGE_NOTES
( p_entity_name        IN            VARCHAR2
, p_from_id            IN            NUMBER
, x_to_id                 OUT NOCOPY NUMBER
, p_from_fk_id         IN            NUMBER
, p_to_fk_id           IN            NUMBER
, p_parent_entity_name IN            VARCHAR2
, p_batch_id           IN            NUMBER
, p_batch_party_id     IN            NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
);


PROCEDURE MERGE_CONTEXT
( p_entity_name        IN            VARCHAR2
, p_from_id            IN            NUMBER
, x_to_id                 OUT NOCOPY NUMBER
, p_from_fk_id         IN            NUMBER
, p_to_fk_id           IN            NUMBER
, p_parent_entity_name IN            VARCHAR2
, p_batch_id           IN            NUMBER
, p_batch_party_id     IN            NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
);

END ;

 

/
