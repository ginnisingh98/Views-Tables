--------------------------------------------------------
--  DDL for Package AST_SEARCHURL_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_SEARCHURL_CUHK" AUTHID CURRENT_USER AS
/* $Header: astvscus.pls 115.4 2002/02/06 11:44:38 pkm ship   $ */

PROCEDURE Query_SearchURL_PRE(p_api_version		    	IN  NUMBER,
		p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit		    		IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level	    	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status		OUT VARCHAR2,
		x_msg_count		    	OUT NUMBER,
		x_msg_data	    	    	OUT VARCHAR2,
  		p_fname				IN VARCHAR2,
	  	p_lname				IN VARCHAR2,
                p_address                       IN VARCHAR2,
		p_city				IN VARCHAR2,
		p_state				IN VARCHAR2,
		p_zip				IN VARCHAR2,
		p_country				IN VARCHAR2);

PROCEDURE Query_SearchURL_POST(
        p_api_version		    	IN  NUMBER,
		p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
		p_commit		    		IN  VARCHAR2 := FND_API.G_FALSE,
		p_validation_level	    	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
		x_return_status		OUT VARCHAR2,
		x_msg_count		    	OUT NUMBER,
		x_msg_data	    	    	OUT VARCHAR2,
  		p_fname				IN VARCHAR2,
		p_lname				IN VARCHAR2,
                p_address                       IN VARCHAR2,
		p_city				IN VARCHAR2,
		p_state				IN VARCHAR2,
		p_zip				IN VARCHAR2,
		p_country				IN VARCHAR2);

FUNCTION OK_TO_LAUNCH_WORKFLOW(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN;


FUNCTION OK_TO_GENERATE_MSG(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN;

END ast_SEARCHURL_CUHK;

 

/
