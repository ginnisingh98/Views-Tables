--------------------------------------------------------
--  DDL for Package FEM_PARTY_PROFIT_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_PARTY_PROFIT_MERGE_PUB" AUTHID CURRENT_USER AS
-- $Header: femprfMS.pls 120.0 2005/06/06 19:41:20 appldev noship $


procedure merge_profitability (
        p_Entity_name          IN      VARCHAR2, -- Name of the Entity being merged
        p_from_id              IN      NUMBER,   -- PK of the Party ID being merged
        p_to_id                IN OUT NOCOPY  NUMBER,   -- PK of the target Party ID; returned if duplicate
        p_From_FK_id           IN      NUMBER,   -- same as p_from_id
        p_To_FK_id             IN      NUMBER,   -- same as p_to_id
        p_Parent_Entity_name   IN      VARCHAR2, -- should always be 'HZ_PARTIES'
        p_batch_id             IN      NUMBER,   -- Batch ID running the merge
        p_Batch_Party_id       IN      NUMBER,   -- same as the From Party ID
        x_return_status        OUT NOCOPY     VARCHAR2

);


END FEM_PARTY_PROFIT_MERGE_PUB;

 

/
