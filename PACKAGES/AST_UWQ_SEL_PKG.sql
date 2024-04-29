--------------------------------------------------------
--  DDL for Package AST_UWQ_SEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_UWQ_SEL_PKG" AUTHID CURRENT_USER AS
/* $Header: asttmsls.pls 115.22 2002/12/26 19:13:36 kmahajan ship $ */

   G_CurrentForm varchar2(60) := 'AST_RC_CALL';
   l_profile            varchar2(10);
   l_dumpData           varchar2(10);
   l_NoAreaCodeMatch    varchar2(10);

------------------------------------------------------------------------------
--  Procedure	: handleOTSInbound,
--  Usage	: Used by UWQ to call Telesales Form
--  Description	: This procedure takes the table of objects containing
--		  the meta data as input and gives the following as output:
--		  1. Action Type -  Method to be used to call the telesales form
--		     using APP_NAVIGATE.EXECUTEFND_FUNCTION.EXECUTE etc.
--		  2. Action Name - Name of the function to call the telesales form.
--		  3. Action Param - Parameters to be passed to the telesales form.
--  Parameters	:
--   p_ieu_media_data 	IN   SYSTEM.IEU_UWQ_MEDIA_DATA_NST	Required
--   p_action_type	OUT  NUMBER
--   p_action_name	OUT  VARCHAR2
--   p_action_param	OUT  VARCHAR2
--
------------------------------------------------------------------------------

PROCEDURE handleOTSInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY varchar2,
			       p_action_param OUT NOCOPY varchar2);

PROCEDURE handleOTSOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY varchar2,
				p_action_param OUT NOCOPY varchar2);

PROCEDURE handleEmail (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY varchar2,
				p_action_param OUT NOCOPY varchar2);

PROCEDURE handleOCInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY varchar2,
			       p_action_param OUT NOCOPY varchar2);

PROCEDURE handleOCOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY varchar2,
			       p_action_param OUT NOCOPY varchar2);

PROCEDURE  setCurrentForm(p_formName varchar2);
FUNCTION   constructParam return varchar2;
PROCEDURE handleFooTask (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2,
			    p_msg_name     OUT NOCOPY varchar2,
			    p_msg_param    OUT NOCOPY varchar2,
			    p_dialog_style OUT NOCOPY NUMBER,
			    p_msg_appl_short_name OUT NOCOPY varchar2) ;



END AST_UWQ_SEL_PKG;

 

/
