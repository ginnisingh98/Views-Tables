--------------------------------------------------------
--  DDL for Package CS_INTERACTION_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INTERACTION_UTL" AUTHID CURRENT_USER AS
/* $Header: csucis.pls 115.0 99/07/16 09:02:57 porting s $ */

------------------------------------------------------------------------------
--  Procedure	: Validate_Parent_Interaction
--  Description	: Validate that the parent interaction is a valid interaction
--		  within the given operating unit
--  Parameters  :
--	p_api_name		IN	VARCHAR2(30)	Required
--		Name of the calling API (used for messages)
--	p_parameter_name	IN	VARCHAR2(30)	Required
--		Name of the parameter in the calling API
--		(e.g. 'p_parent_interaction_id')
--	p_parent_interaction_id	IN	NUMBER		Required
--		Value of the customer number to be converted
--	p_org_id		IN	NUMBER		Optional
--		Operating Unit ID
--	x_return_status		OUT	VARCHAR2(1)
--		FND_API.G_RET_STS_SUCCESS	=> interaction is valid
--		FND_API.G_RET_STS_ERROR		=> interaction is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Parent_Interaction
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name		IN	VARCHAR2,
    p_parent_interaction_id	IN	NUMBER,
    p_org_id			IN	NUMBER DEFAULT NULL,
    x_return_status		OUT	VARCHAR2 );

END CS_Interaction_UTL;

 

/
