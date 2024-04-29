--------------------------------------------------------
--  DDL for Package PON_AUCTION_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: PONAUCIS.pls 120.4 2005/08/10 16:48:54 xtang noship $ */
/*
===================
    CONSTANTS
===================
*/
 success	NUMBER := 0;
 error		NUMBER := -1;

/*
===================
    PROCEDURES
===================
========================================================================
 PROCEDURE : Create_Draft_Negotiation     PUBLIC
 PARAMETERS:
  P_DOCUMENT_TITLE	IN	Title of negotiation
  P_DOCUMENT_TYPE	IN	'BUYER_AUCTION' or 'REQUEST_FOR_QUOTE'
  P_CONTRACT_TYPE	IN	'STANDARD' or 'BLANKET'
  P_ORIGINATION_CODE	IN	'REQUISITION' or caller product name
  P_ORG_ID		IN	Organization id of creator
  P_BUYER_ID		IN	FND_USER_ID of creator
  P_NEG_STYLE_ID	IN	negotiation style id
  P_PO_STYLE_ID		IN	po style id
  P_DOCUMENT_NUMBER	OUT	Created Document number
  P_DOCUMENT_URL	OUT	Additional parameters to PON_AUC_EDIT_DRAFT_B
				form function for editing draft
  P_RESULT              OUT     One of (error, success)
  P_ERROR_CODE		OUT	Internal code for error
  P_ERROR_MESSAGE	OUT	Displayable error
 COMMENT   : Creates a draft auction
======================================================================*/
PROCEDURE Create_Draft_Negotiation(
 P_DOCUMENT_TITLE	IN		VARCHAR2,
 P_DOCUMENT_TYPE	IN		VARCHAR2,
 P_CONTRACT_TYPE	IN		VARCHAR2,
 P_ORIGINATION_CODE	IN		VARCHAR2,
 P_ORG_ID		IN		NUMBER,
 P_BUYER_ID		IN		NUMBER,
 P_NEG_STYLE_ID		IN		NUMBER,
 P_PO_STYLE_ID		IN		NUMBER,
 P_DOCUMENT_NUMBER	OUT	NOCOPY	NUMBER,
 P_DOCUMENT_URL		OUT	NOCOPY	VARCHAR2,
 P_RESULT		OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	OUT	NOCOPY	VARCHAR2);

/*======================================================================
 PROCEDURE : Add_Negotiation_Line
 PARAMETERS:
  P_DOCUMENT_NUMBER	IN	Document number to add line
  P_CONTRACT_TYPE	IN	'STANDARD' or 'BLANKET'
  P_ORIGINATION_CODE	IN	'REQUISITION' or caller product name
  P_ORG_ID		IN	Organization id of creator
  P_BUYER_ID		IN	FND_USER_ID of creator
  P_GROUPING_TYPE	IN	'DEFAULT' or 'NONE' grouping
  P_REQUISITION_HEADER_ID  IN	Requisition header
  P_REQUISITION_NUMBER  IN	Requisition header formatted for display
  P_REQUISITION_LINE_ID IN	Requisition line
  P_LINE_TYPE_ID	IN	Line type
  P_CATEGORY_ID		IN	Line category
  P_ITEM_DESCRIPTION	IN	Item Desription
  P_ITEM_ID		IN	Item Id
  P_ITEM_NUMBER		IN      Item Number formatted for display
  P_ITEM_REVISION	IN	Item Revision
  P_UOM_CODE		IN	UOM_CODE from MTL_UNITS_OF_MEASURE
  P_QUANTITY		IN	Quantity
  P_NEED_BY_DATE	IN	Item Need-By
  P_SHIP_TO_LOCATION_ID IN	Ship To
  P_NOTE_TO_VENDOR	IN	Note to Supplier
  P_PRICE		IN	Start price for line
  P_JOB_ID		IN      Job_id for the services job
  P_JOB_DETAILS	        IN      job details if any
  P_PO_AGREED_AMOUNT	IN	PO Agreed Amount
  P_HAS_PRICE_DIFF_FLAG IN      If the line has any price differentials flag
  P_LINE_NUMBER		OUT	Line number to which the demand was added
  P_RESULT      	OUT     One of (error, success)
  P_ERROR_CODE		OUT	Internal Error Code
  P_ERROR_MESSAGE	OUT	Displayable error
 COMMENT   : Creates a line in a draft auction
======================================================================*/
PROCEDURE Add_Negotiation_Line(
 P_DOCUMENT_NUMBER	IN	NUMBER,
 P_CONTRACT_TYPE	IN	VARCHAR2,
 P_ORIGINATION_CODE	IN	VARCHAR2,
 P_ORG_ID		IN	NUMBER,
 P_BUYER_ID		IN	NUMBER,
 P_GROUPING_TYPE	IN	VARCHAR2,
 P_REQUISITION_HEADER_ID   IN	NUMBER,
 P_REQUISITION_NUMBER	IN	VARCHAR2,
 P_REQUISITION_LINE_ID	IN	NUMBER,
 P_LINE_TYPE_ID		IN	NUMBER,
 P_CATEGORY_ID		IN	NUMBER,
 P_ITEM_DESCRIPTION	IN	VARCHAR2,
 P_ITEM_ID		IN	NUMBER,
 P_ITEM_NUMBER		IN      VARCHAR2,
 P_ITEM_REVISION	IN	VARCHAR2,
 P_UOM_CODE		IN	VARCHAR2,
 P_QUANTITY		IN	NUMBER,
 P_NEED_BY_DATE		IN	DATE,
 P_SHIP_TO_LOCATION_ID	IN	NUMBER,
 P_NOTE_TO_VENDOR	IN	VARCHAR2,
 P_PRICE		IN	NUMBER,
 P_JOB_ID		IN      NUMBER, -- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_JOB_DETAILS	        IN      VARCHAR2,-- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_PO_AGREED_AMOUNT	IN	NUMBER,-- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_HAS_PRICE_DIFF_FLAG	IN	VARCHAR2,-- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_LINE_NUMBER		OUT	NOCOPY	NUMBER,
 P_RESULT		OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	OUT	NOCOPY	VARCHAR2);

/*============ADDED FOR UNIFIED CATALOG PROJECT=====================
 PROCEDURE : Add_Catalog_Descriptors
 PARAMETERS:
  P_API_VERSION                 IN       NUMBER
  P_DOCUMENT_NUMBER             IN       NUMBER
  X_RETURN_STATUS               OUT      NOCOPY  VARCHAR2
  X_MSG_COUNT                   OUT      NOCOPY  NUMBER
  X_MSG_DATA                    OUT      NOCOPY  VARCHAR2
 COMMENT   : Adds ip descriptors to a draft auction
======================================================================*/

PROCEDURE Add_Catalog_Descriptors (
 P_API_VERSION                 IN       NUMBER,
 P_DOCUMENT_NUMBER             IN       NUMBER,
 X_RETURN_STATUS               OUT      NOCOPY  VARCHAR2,
 X_MSG_COUNT                   OUT      NOCOPY  NUMBER,
 X_MSG_DATA                    OUT      NOCOPY  VARCHAR2);

/*============ADDED FOR SERVICES PROCUREMENT PROJECT=====================
 PROCEDURE : Add_Price_Differential
 PARAMETERS:
  P_DOCUMENT_NUMBER	        IN	Document number to add line
  P_LINE_NUMBER                 IN      Line number
  P_SHIPMENT_NUMBER             IN      Shipment number
  P_PRICE_TYPE                  IN      Price Type
  P_MULTIPLIER                  IN      Multiplier
  P_BUYER_ID                    IN      FND_USER_ID of the creator
  P_PRICE_DIFFERENTIAL_NUMBER 	OUT	Price Differential Number

  P_RESULT      	        OUT     One of (error, success)
  P_ERROR_CODE		        OUT	Internal Error Code
  P_ERROR_MESSAGE	        OUT	Displayable error
 COMMENT   : Creates a price differential in a draft auction
======================================================================*/

PROCEDURE Add_Price_Differential (
 P_DOCUMENT_NUMBER	       IN	NUMBER,
 P_LINE_NUMBER                 IN       NUMBER,
 P_SHIPMENT_NUMBER             IN       NUMBER,
 P_PRICE_TYPE                  IN       VARCHAR2,
 P_MULTIPLIER                  IN       NUMBER,
 P_BUYER_ID                    IN       NUMBER,
 P_PRICE_DIFFERENTIAL_NUMBER   OUT      NOCOPY  NUMBER,
 P_RESULT		       OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		       OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	       OUT	NOCOPY	VARCHAR2);

/*========================================================================
 PROCEDURE : Get_Negotiation_Owner
 PARAMETERS:
  P_DOCUMENT_NUMBER	IN	Document Id
  P_OWNER_NAME		OUT	FND_USER.USER_NAME of document owner
  P_RESULT		OUT	One of (error, success)
  P_ERROR_CODE		OUT	Internal Error Code
  P_ERROR_MESSAGE	OUT	Displayable error
 COMMENT   : Returns the owner name for a negotiation document
======================================================================*/
PROCEDURE Get_Negotiation_Owner(
 P_DOCUMENT_NUMBER	IN	NUMBER,
 P_OWNER_NAME		OUT	NOCOPY 	VARCHAR2,
 P_RESULT		OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	OUT	NOCOPY	VARCHAR2);

/*========================================================================
 PROCEDURE : Get_PO_Negotiation_Link     PUBLIC
 PARAMETERS:
  P_PO_HEADER_ID        IN      PO Header Id
  P_ROLE       	        IN      User is one of ('BUYER', 'SUPPLIER')
  P_DOCUMENT_NUMBER     OUT     Negotiation Document number display
  P_DOCUMENT_URL        OUT     URL to view negotiation document
  P_RESULT              OUT     One of (error, success)
  P_ERROR_CODE          OUT     Internal code for error
  P_ERROR_MESSAGE       OUT     Displayable error message
 COMMENT   : Returns the Negotiation Document number and Sourcing URL
   for viewing the Negotiation Document.  The Negotiation Document number
   returned is formatted for display and may not be the same as the
   pon_auction_headers.auction_header_id.  The Document Number should not
   be used in subsequent calls to this API.
======================================================================*/
PROCEDURE Get_PO_Negotiation_Link(
 P_PO_HEADER_ID        IN      		NUMBER,
 P_DOCUMENT_ID         OUT     NOCOPY   NUMBER,
 P_DOCUMENT_NUMBER     OUT     NOCOPY	VARCHAR2,
 P_DOCUMENT_URL        OUT     NOCOPY	VARCHAR2,
 P_RESULT              OUT     NOCOPY	NUMBER,
 P_ERROR_CODE          OUT     NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE       OUT     NOCOPY	VARCHAR2);

/*===================================================================
 PROCEDURE: add_negotiation_invitees    PUBLIC
 PARAMETERS:
  p_api_version                  version of the api
  x_return_status        OUT     FND_API.G_RET_STS_SUCCESS or FND_API.G_RET_STS_ERROR
  x_msg_count            OUT     Internal code for error
  x_msg_data             OUT     Displayable error message
  P_DOCUMENT_NUMBER      IN      Negotiation Document number
  P_BUYER_ID             IN      FND_USER_ID of the creator
 COMMENT: Gets distinct vendor_ids and vendor sites
   across all the requisition lines that are part of the
   negotiation and adds (bulk inserts ) them as invitees. We do not check
   for inactive suppliers/ sites in the autocreate process; these
   will be validated at publish time.
=====================================================================*/
PROCEDURE add_negotiation_invitees(
 p_api_version          IN              NUMBER,
 x_return_status        OUT     NOCOPY  VARCHAR2,
 x_msg_count            OUT     NOCOPY  NUMBER,
 x_msg_data             OUT     NOCOPY  VARCHAR2,
 P_DOCUMENT_NUMBER      IN              NUMBER,
 P_BUYER_ID             IN              NUMBER);

PROCEDURE get_default_negotiation_style(
                   x_style_id        OUT     NOCOPY  NUMBER,
                   x_style_name      OUT     NOCOPY  VARCHAR2);

--
END PON_AUCTION_INTERFACE_PKG;

 

/
