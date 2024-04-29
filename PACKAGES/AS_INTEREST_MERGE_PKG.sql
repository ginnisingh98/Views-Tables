--------------------------------------------------------
--  DDL for Package AS_INTEREST_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INTEREST_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: asxpmits.pls 120.1 2005/11/25 01:30:16 subabu noship $ */
--
-- NAME
-- AS_INTEREST_MERGE_PKG
--
-- HISTORY
--   02/15/2001    ACNG          CREATED
--

PROCEDURE INTERESTS_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT   NOCOPY NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT   NOCOPY VARCHAR2
);

PROCEDURE CURRENT_ENV_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT   NOCOPY NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT   NOCOPY VARCHAR2
);

END AS_INTEREST_MERGE_PKG;

 

/
