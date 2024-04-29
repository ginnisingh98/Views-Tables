--------------------------------------------------------
--  DDL for Package OKL_UWQ_SEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_UWQ_SEL_PKG" AUTHID CURRENT_USER AS
/* $Header: OKLRUWQS.pls 115.4 2002/12/18 12:52:00 kjinger noship $ */

   G_CurrentForm VARCHAR2(60) := 'OKLCSHDR_FUNC';
   l_profile            VARCHAR2(10);
   l_dumpData           VARCHAR2(10);
   l_NoAreaCodeMatch    VARCHAR2(10);
------------------------------------------------------------------------------
--  Procedure	: handleOTSInbound,
--  Usage	: Used by UWQ to call Leasing Center Form Form
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
			       p_action_name OUT NOCOPY VARCHAR2,
			       p_action_param OUT NOCOPY VARCHAR2);
PROCEDURE handleOTSOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY VARCHAR2,
				p_action_param OUT NOCOPY VARCHAR2);
PROCEDURE handleEmail (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY VARCHAR2,
				p_action_param OUT NOCOPY VARCHAR2);
PROCEDURE handleOCInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY VARCHAR2,
			       p_action_param OUT NOCOPY VARCHAR2);
PROCEDURE handleOCOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY VARCHAR2,
			       p_action_param OUT NOCOPY VARCHAR2);
PROCEDURE  setCurrentForm(p_formName VARCHAR2);
FUNCTION   constructParam RETURN VARCHAR2;
END Okl_Uwq_Sel_Pkg;

 

/
