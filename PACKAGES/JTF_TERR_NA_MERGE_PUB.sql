--------------------------------------------------------
--  DDL for Package JTF_TERR_NA_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_NA_MERGE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtftptns.pls 120.2 2006/09/29 07:32:36 spai noship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_NA_MERGE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force named account territory manager public api's.
--      This package is a public API for party merge
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      04/15/03    SGKUMAR     Created
--
--    End of Comments
--

PROCEDURE party_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT  NOCOPY NUMBER,
              		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT  NOCOPY VARCHAR2);

PROCEDURE party_site_merge(
                           p_entity_name                IN   VARCHAR2,
                           p_from_id                    IN   NUMBER,
                           x_to_id                      OUT  NOCOPY NUMBER,
              		   p_from_fk_id                 IN   NUMBER,
                           p_to_fk_id                   IN   NUMBER,
                           p_parent_entity_name         IN   VARCHAR2,
			   p_batch_id                   IN   NUMBER,
			   p_batch_party_id             IN   NUMBER,
			   x_return_status              OUT  NOCOPY VARCHAR2);


END JTF_TERR_NA_MERGE_PUB;

 

/
