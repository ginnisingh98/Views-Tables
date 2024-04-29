--------------------------------------------------------
--  DDL for Package CSC_UWQ_FORM_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_UWQ_FORM_ROUTE" AUTHID CURRENT_USER AS
/* $Header: cscpuwqs.pls 115.9 2002/12/04 01:51:31 vxsriniv ship $ */

------------------------------------------------------------------------------
--  Procedure	: CSC_UWQ_Form_Obj
--  Usage	: Used by UWQ to call Contact Center Form
--  Description	: This procedure takes the table of objects containing
--				  the meta data as input and gives the following as output:
--				  1. Action Type -  Method to be used to call the contact center form
--								like APP_NAVIGATE.EXECUTE or
--								FND_FUNCTION.EXECUTE etc.
--				  2. Action Name - Name of the function to call the contact center form.
--				  3. Action Param - Parameters to be passed to the contact center form.
--  Parameters	:
--   p_ieu_media_data	        IN	SYSTEM.IEU_UWQ_MEDIA_DATA_NST	Required
--   p_action_type		OUT  NUMBER
--   p_action_name		OUT  VARCHAR2
--   p_action_param		OUT  VARCHAR2
--
------------------------------------------------------------------------------

PROCEDURE CSC_UWQ_Form_Obj
( p_ieu_media_data IN  SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
  p_action_type   OUT  NOCOPY NUMBER,
  p_action_name   OUT  NOCOPY VARCHAR2,
  p_action_param  OUT  NOCOPY VARCHAR2);

END CSC_UWQ_FORM_ROUTE;

 

/
