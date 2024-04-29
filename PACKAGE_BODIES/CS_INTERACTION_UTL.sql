--------------------------------------------------------
--  DDL for Package Body CS_INTERACTION_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INTERACTION_UTL" AS
/* $Header: csucib.pls 115.0 99/07/16 09:02:51 porting s $ */

------------------------------------------------------------------------------
--  Function	: Validate_Parent_Interaction
------------------------------------------------------------------------------

PROCEDURE Validate_Parent_Interaction
  ( p_api_name			IN	VARCHAR2,
    p_parameter_name		IN	VARCHAR2,
    p_parent_interaction_id	IN	NUMBER,
    p_org_id			IN	NUMBER DEFAULT NULL,
    x_return_status		OUT	VARCHAR2 )
  IS
     l_dummy	VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT 'x' INTO l_dummy
     FROM cs_interactions
     WHERE interaction_id = p_parent_interaction_id
     AND Nvl(org_id, -99) = Decode(org_id, NULL, -99, p_org_id);
EXCEPTION
   WHEN no_data_found THEN
      x_return_status := fnd_api.g_ret_sts_error;
      cs_core_util.add_invalid_argument_msg(p_api_name,
					    p_parent_interaction_id,
					    p_parameter_name);
END Validate_Parent_Interaction;

END CS_Interaction_UTL;

/
