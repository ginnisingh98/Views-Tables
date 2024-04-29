--------------------------------------------------------
--  DDL for Package IEX_UWQ_SEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_UWQ_SEL_PKG" AUTHID CURRENT_USER AS
/* $Header: iextmsls.pls 120.1.12010000.1 2008/11/12 10:18:55 appldev noship $ */

   G_CurrentForm varchar2(60) := 'IEXRCALL';

   l_eventName          varchar2(60);
   l_partyId            number;
   l_partyType          varchar2(80);
   l_customerNumber     number;
   l_contactId          number;
   l_contactNumber      number;
   l_eventConfCode      varchar2(30);
   l_eventId            number;
   l_collateralReqNum   VARCHAR2(30) ;
   l_collateralId       number;
   l_campaignCode       varchar2(30);
   l_campaignId	    number;
   l_dnis	              varchar2(25);
   l_callId             varchar2(30);
   l_ani                varchar2(30);
   l_accountCode        number;
   l_usage              varchar2(60);
   l_agentID            varchar2(60);
   l_mediaType          varchar2(60);
   l_mediaItemID        varchar2(60);
   l_workitemID         varchar2(60);
   l_sendername         varchar2(60);
   l_subject            varchar2(60);
   l_messageID          varchar2(60);
   l_profile            varchar2(10);
   l_PhoneAreaCodeYN    varchar2(10);
   l_dumpData           varchar2(10);
   l_MoreAniMatch       varchar2(10);
   l_AreaCodeLength     varchar2(10);
   l_PhoneNumberLength  varchar2(10);

   l_task_id            varchar2(60) ;
   l_source_code        varchar2(60) ;
   l_source_code_id     varchar2(60) ;
   l_customer_trx_id    number;
   l_trx_view_by         varchar2(60) ;
   l_InvoiceNum         varchar2(60) ;
   l_AccountRolesExist VARCHAR2(10);

   -- kmahajan - added for bug 2695645
   l_customerID               number;

--for handlefootask function below..jraj..11/5/02
   l_source_object_type varchar2(300);
   l_source_campaign_id number;
   l_nm_party_id        number;

   l_blocked			boolean;


------------------------------------------------------------------------------
--  Procedure	: handleIEXInbound,
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

PROCEDURE handleIEXInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY varchar2,
			       p_action_param OUT NOCOPY varchar2);

PROCEDURE handleIEXOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY varchar2,
				p_action_param OUT NOCOPY varchar2);

PROCEDURE handleEmail (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY varchar2,
				p_action_param OUT NOCOPY varchar2);

PROCEDURE handleOOCInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			       p_action_type OUT NOCOPY NUMBER,
			       p_action_name OUT NOCOPY varchar2,
			       p_action_param OUT NOCOPY varchar2);

PROCEDURE  setCurrentForm(p_formName varchar2);

PROCEDURE  getFooData(p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST);

PROCEDURE handleFooTask (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2);

END IEX_UWQ_SEL_PKG;

/
