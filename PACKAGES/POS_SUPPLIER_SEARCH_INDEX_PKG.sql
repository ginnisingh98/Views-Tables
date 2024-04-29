--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_SEARCH_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_SEARCH_INDEX_PKG" AUTHID CURRENT_USER AS
-- $Header: POS_SUPPLIER_SEARCH_INDEX_PKG.pls 120.0.12010000.1 2013/01/23 11:27:32 irasoolm noship $

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

FUNCTION getPosSchemaName
  RETURN VARCHAR2;

END pos_supplier_search_index_pkg;

/
