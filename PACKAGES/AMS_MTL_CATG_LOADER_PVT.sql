--------------------------------------------------------
--  DDL for Package AMS_MTL_CATG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MTL_CATG_LOADER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmcas.pls 115.6 2004/03/16 01:16:46 musman ship $ */

-- Start of Comments
--
-- NAME
--   Refresh_Inv_Category
--
-- PURPOSE
--   This procedure is created to as a concurrent program which
--   will load inventory categories into ams denorm table.
--
-- NOTES
--
--
-- HISTORY
--   07/01/2002         ABHOLA       Created
--   28-MAR-2003   mukumar   Add languagem added

-- End of Comments

PROCEDURE Load_Inv_Category
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER);

/*
*  This procedure would upgrade the interest types in ams_competitor_products_b
*  categories and category sets from as_interets_types_vl mapped in OSO
*/


PROCEDURE UPGRADE_INTEREST_TYPES
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER);

/*
*  This procedure would upgrade the marketing transaction table (ams_Act_products)
*  categories and category sets to the one mapped in PLM
*/

PROCEDURE UPGRADE_CATEGORIES
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER);


procedure ADD_LANGUAGE;

END AMS_MTL_CATG_LOADER_PVT;

 

/
