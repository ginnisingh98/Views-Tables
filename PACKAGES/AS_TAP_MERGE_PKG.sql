--------------------------------------------------------
--  DDL for Package AS_TAP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_TAP_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: asxpmtes.pls 120.1 2005/06/24 22:26:10 appldev ship $ */
--
-- NAME
-- AS_TAP_MERGE_PKG
--
-- HISTORY
--
--

PROCEDURE ACCESS_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY /* file.sql.39 change */   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

PROCEDURE TAP_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY /* file.sql.39 change */   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

END AS_TAP_MERGE_PKG;

 

/
