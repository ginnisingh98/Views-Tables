--------------------------------------------------------
--  DDL for Package AST_SEARCHURL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_SEARCHURL_PVT" AUTHID CURRENT_USER AS
/* $Header: astvschs.pls 115.5 2002/02/06 11:44:34 pkm ship   $ */

  PROCEDURE Query_SearchURL (p_api_version IN NUMBER := 1.0,
                             p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                             p_commit IN VARCHAR2 := FND_API.G_FALSE,
                             p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                             x_return_status OUT VARCHAR2,
                             x_msg_count OUT NUMBER,
                             x_msg_data OUT VARCHAR2,
			     p_search_id IN NUMBER, -- add by jypark 12/27/2000 for new requirement
                             p_fname IN VARCHAR2,
                             p_lname IN VARCHAR2,
                             p_address IN VARCHAR2,
                             p_city IN VARCHAR2,
		             p_state IN VARCHAR2,
                             p_zip IN VARCHAR2,
                             p_country IN VARCHAR2,
 		             x_search_url OUT VARCHAR2,
                             x_max_nbr_pages OUT VARCHAR2,
                             x_next_page_ident OUT VARCHAR2);


 END;

 

/
