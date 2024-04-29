--------------------------------------------------------
--  DDL for Package Body AST_SEARCHURL_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_SEARCHURL_CUHK" AS
/* $Header: astvscub.pls 115.4 2002/02/06 11:44:36 pkm ship   $ */

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
		p_country				IN VARCHAR2)
AS

BEGIN
	/* Customer to add the customization procedures here - for pre processing */
	null;
END;

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
		p_country				IN VARCHAR2)

AS

BEGIN
	/* Customer to add the customization procedures here - for post processing */
	null;
END;

FUNCTION OK_TO_LAUNCH_WORKFLOW(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN is
BEGIN
	/* logic to check if a workflow to be launched */
	null;
	return true;
END;


FUNCTION OK_TO_GENERATE_MSG(
            p_api_version IN NUMBER := 1.0,
            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
            p_commit IN VARCHAR2 := FND_API.G_FALSE,
            p_validation_level IN NUMBER :=
            FND_API.G_VALID_LEVEL_FULL,
            x_return_status OUT VARCHAR2,
            x_msg_count OUT NUMBER,
            x_msg_data OUT VARCHAR2) RETURN BOOLEAN is
BEGIN
	/* customer/vertical industry to add the customization here */
	null;
	return true;
END;

end ast_SEARCHURL_CUHK;

/
