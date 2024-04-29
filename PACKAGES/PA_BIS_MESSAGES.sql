--------------------------------------------------------
--  DDL for Package PA_BIS_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BIS_MESSAGES" AUTHID CURRENT_USER AS
/* $Header: PABISMES.pls 115.0 99/07/16 13:24:45 porting ship  $ */

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--
--  1. Function Name:GET_MESSAGE
--  	Usage:	Get Message Description for the message code passed
Function GET_MESSAGE(p_prod_code IN VARCHAR2,p_msg_code IN VARCHAR2) RETURN VARCHAR2;
pragma restrict_references(get_message,wnds);
END PA_BIS_MESSAGES;

 

/
