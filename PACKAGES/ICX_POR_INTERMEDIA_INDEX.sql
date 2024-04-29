--------------------------------------------------------
--  DDL for Package ICX_POR_INTERMEDIA_INDEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_INTERMEDIA_INDEX" AUTHID CURRENT_USER AS
/* $Header: ICXCGITS.pls 115.12 2003/02/07 19:29:11 vkartik ship $*/

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

END ICX_POR_INTERMEDIA_INDEX;

 

/
