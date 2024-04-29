--------------------------------------------------------
--  DDL for Package IBC_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_UTILITIES_PUB" AUTHID CURRENT_USER as
/* $Header: ibcputls.pls 120.2 2006/01/21 18:50:38 apulijal noship $ */

-----------------------------------------
-- Global Variables
-----------------------------------------
G_SERVLET_URL	          CONSTANT CHAR(21) := 'ibcGetAttachment.jsp?';
G_CITEM_SERVLET_URL	  CONSTANT CHAR(22) := 'ibcGetContentItem.jsp?';
G_PCITEM_SERVLET_URL	  CONSTANT CHAR(26) := 'ibcPreviewContentItem.jsp?';
G_RENDITION_SERVLET_URL	  CONSTANT CHAR(20) := 'ibcGetRendition.jsp?';


-- content item version status constants
G_STV_APPROVED            CONSTANT CHAR(8)  := 'APPROVED';
G_STV_WORK_IN_PROGRESS    CONSTANT CHAR(10) := 'INPROGRESS';
G_STV_SUBMIT_FOR_APPROVAL CONSTANT CHAR(9)  := 'SUBMITTED';
G_STV_REJECTED            CONSTANT CHAR(8)  := 'REJECTED';
G_STV_ARCHIVED            CONSTANT CHAR(8)  := 'ARCHIVED';

-- content item status constants
G_STI_PENDING             CONSTANT CHAR(7)  := 'PENDING';
G_STI_APPROVED            CONSTANT CHAR(8)  := 'APPROVED';
G_STI_ARCHIVED            CONSTANT CHAR(8)  := 'ARCHIVED';
G_STI_ARCHIVED_CASCADE    CONSTANT CHAR(16) := 'ARCHIVED-CASCADE';
G_STI_STOPPED             CONSTANT CHAR(7)  := 'STOPPED';

-- fixed content item xml tags
G_XML_REND_TAG		  CONSTANT CHAR(13) := 'IBC_RENDITION';

-- date type constants
G_DTC_ATTACHMENT          CONSTANT CHAR(10) := 'attachment';
G_DTC_TEXT                CONSTANT CHAR(6)  := 'string';
G_DTC_HTML                CONSTANT CHAR(4)  := 'html';
G_DTC_NUMBER              CONSTANT CHAR(7)  := 'decimal';
G_DTC_DATE                CONSTANT CHAR(8)  := 'dateTime';
G_DTC_URL                 CONSTANT CHAR(3)  := 'url';
G_DTC_BOOLEAN             CONSTANT CHAR(7)  := 'boolean';
G_DTC_COMPONENT           CONSTANT CHAR(9)  := 'component';

-- other constants
G_COMMON_DIR_NODE         CONSTANT NUMBER := 1;




/****************************************************
-------------FUNCTIONS--------------------------------------------------------------------------
****************************************************/


/****************************************************
-------------PROCEDURES--------------------------------------------------------------------------
****************************************************/







END Ibc_Utilities_Pub;

 

/
