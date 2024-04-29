--------------------------------------------------------
--  DDL for Package ICX_CAT_INTERMEDIA_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_INTERMEDIA_INDEX_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVCIIS.pls 120.2 2005/10/19 10:54 sbgeorge noship $*/

/*
** Create one index for each installed language in FND_LANGUAGES,
** including the base language.
*/
PROCEDURE create_index;

/*
** Drop the index for each installed language in FND_LANGUAGES,
** including the base language.
*/
PROCEDURE drop_index;

/*
** Rebuild the index for each installed language in FND_LANGUAGES,
** including the base language.
*/
PROCEDURE rebuild_index;

END ICX_CAT_INTERMEDIA_INDEX_PVT;

 

/
