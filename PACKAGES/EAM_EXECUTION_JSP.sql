--------------------------------------------------------
--  DDL for Package EAM_EXECUTION_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_EXECUTION_JSP" AUTHID CURRENT_USER AS
/* $Header: EAMEXUJS.pls 115.5 2002/11/18 18:14:18 aan ship $
   $Author: aan $ */

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   g_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   g_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   g_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

--  This function accepts as input an organization name and returns as output
--  the organization's organization ID.  If there is no organization record
--  for the given organization name, then this function returns NULL.
  FUNCTION  GetOrgId ( X_org_name  IN VARCHAR2 ) RETURN NUMBER;
  pragma RESTRICT_REFERENCES ( GetOrgId, WNDS, WNPS );

--  This function accepts as input an organization ID and returns as output
--  the organization's name.  If there is no organization record for the
--  given organization ID, then this function returns NULL.
  FUNCTION  GetOrgName ( X_org_id  IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES ( GetOrgName, WNDS, WNPS );

--  get time string, temporary
  FUNCTION to_time_string( date1 IN DATE) RETURN VARCHAR2;

---------------------------------------------------------------
-- Procedure : Get_Encoded_Msg
--    This procedure serves as a wrapper to the function
--    FND_MSG_PUB.Get.  It is needed to access the call from
--    client FORMS.
---------------------------------------------------------------
  Procedure Get_Encoded_Msg
  (
    p_index	IN   	NUMBER,
		p_msg_out	IN OUT NOCOPY  VARCHAR2
  );

  PROCEDURE Get_Messages
  (
    p_encoded        IN VARCHAR2 := FND_API.G_FALSE,
    p_msg_index      IN NUMBER   := NULL,
    p_msg_count      IN NUMBER   := 0,
    p_msg_data       IN VARCHAR2 := NULL,
    p_data           OUT NOCOPY VARCHAR2,
    p_msg_index_out  OUT NOCOPY NUMBER
  );


---------------------------------------------------------------
-- Procedure : Add_Message
--    This procedure serves as a wrapper to the FND_MEG_PUB
--    procedures to add the specified message onto the message
--    stack.
---------------------------------------------------------------
  Procedure Add_Message( p_app_short_name	IN	VARCHAR2,
		       p_msg_name	IN	VARCHAR2,
		       p_token1		IN	VARCHAR2 DEFAULT NULL,
		       p_value1		IN	VARCHAR2 DEFAULT NULL,
		       p_token2		IN	VARCHAR2 DEFAULT NULL,
		       p_value2		IN	VARCHAR2 DEFAULT NULL,
		       p_token3		IN	VARCHAR2 DEFAULT NULL,
		       p_value3		IN	VARCHAR2 DEFAULT NULL,
		       p_token4		IN	VARCHAR2 DEFAULT NULL,
		       p_value4		IN	VARCHAR2 DEFAULT NULL,
		       p_token5		IN	VARCHAR2 DEFAULT NULL,
		       p_value5		IN	VARCHAR2 DEFAULT NULL
  );

END eam_execution_jsp;

 

/
