--------------------------------------------------------
--  DDL for Package EDR_ADHOC_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_ADHOC_USER_PVT" AUTHID CURRENT_USER AS
/* $Header: EDRVADHS.pls 120.0.12000000.1 2007/01/18 05:56:04 appldev ship $

/* Constants declared */
-- constants
G_ACTION_REQD	constant varchar2(1) := 'Y';
G_NO_ACTION_REQD	constant varchar2(1) := 'N';
G_PKG_NAME	 constant varchar2(30) := 'EDR_ADHOC_USER_PVT';

-- Start of comments
-- API name             : UPDATE_SIGNERLIST
-- Type                 : Private
-- Function             : Update the signer list when new approvers are added.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_event_id             IN number
--                        p_event_name           IN VARCHAR2
--                        p_document_id          IN number
--                        p_originalrecipient    IN FND_TABLE_OF_VARCHAR2_255
--                        p_finalrecipient       IN FND_TABLE_OF_VARCHAR2_255
--                        p_overridingdetails    IN FND_TABLE_OF_VARCHAR2_255
--                        p_signaturesequence    IN FND_TABLE_OF_VARCHAR2_255
--                        p_recipientdisplayname IN FND_TABLE_OF_VARCHAR2_255
--                        p_originating_system   IN FND_TABLE_OF_VARCHAR2_255
--                        p_orignating_system_id IN FND_TABLE_OF_VARCHAR2_255
-- OUT                  : x_error OUT NUMBER
--                        x_error_msg OUT VARCHAR2
-- End of comments

-- Bug 2674799: start
-- Added signersequence as a new parameter for sequence number use.

procedure UPDATE_SIGNERLIST (
	p_event_id             IN number,
	p_event_name	       IN VARCHAR2 ,
	p_document_id	       IN number,
        p_originalrecipient    IN FND_TABLE_OF_VARCHAR2_255,
	p_finalrecipient       IN FND_TABLE_OF_VARCHAR2_255,
	p_overridingdetails    IN FND_TABLE_OF_VARCHAR2_255,
        p_signaturesequence    IN FND_TABLE_OF_VARCHAR2_255,
	p_recipientdisplayname IN FND_TABLE_OF_VARCHAR2_255 DEFAULT NULL,
	p_originating_system   IN FND_TABLE_OF_VARCHAR2_255 DEFAULT NULL,
	p_orignating_system_id IN FND_TABLE_OF_VARCHAR2_255 DEFAULT NULL,
        x_error                OUT NOCOPY NUMBER,
        x_error_msg            OUT NOCOPY VARCHAR2
) ;

-- Bug 2674799: end

END EDR_ADHOC_USER_PVT;

 

/
