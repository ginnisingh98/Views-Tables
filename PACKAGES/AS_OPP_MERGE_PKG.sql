--------------------------------------------------------
--  DDL for Package AS_OPP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPP_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: asxpmops.pls 120.1 2005/06/24 22:26:06 appldev ship $ */
--
-- NAME
-- AS_OPP_MERGE_PKG
--
-- HISTORY
--   02/20/2001    XDING          CREATED
--

PROCEDURE OPP_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY /* file.sql.39 change */   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
--   ,p_request_id              IN       NUMBER
   ,x_return_status           IN OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

END AS_OPP_MERGE_PKG;

 

/
