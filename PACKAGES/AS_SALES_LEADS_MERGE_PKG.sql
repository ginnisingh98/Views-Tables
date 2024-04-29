--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: asxpmsls.pls 115.5 2003/02/11 22:27:39 solin ship $ */
--
-- NAME
-- AS_SALES_LEADS_MERGE_PKG
--
-- HISTORY
--   02/16/2001    SOLIN         CREATED
--

PROCEDURE Sales_Lead_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

PROCEDURE Lead_Contact_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
);

END AS_SALES_LEADS_MERGE_PKG;

 

/
