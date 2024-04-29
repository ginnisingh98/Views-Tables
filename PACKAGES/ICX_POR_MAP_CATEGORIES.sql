--------------------------------------------------------
--  DDL for Package ICX_POR_MAP_CATEGORIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_MAP_CATEGORIES" AUTHID CURRENT_USER AS
/* $Header: ICXECMCS.pls 115.0 2002/11/20 19:34:14 sbgeorge noship $*/

PROCEDURE clear_tables ;

PROCEDURE map_categories(p_sourceCategory IN VARCHAR2,
                         p_oldCatKey IN VARCHAR2,
                         p_destCatKey IN VARCHAR2,
			 p_userId IN NUMBER,
			 p_status OUT VARCHAR2,
			 p_message OUT VARCHAR2) ;

END ICX_POR_MAP_CATEGORIES;

 

/
