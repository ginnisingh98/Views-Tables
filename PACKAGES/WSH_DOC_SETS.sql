--------------------------------------------------------
--  DDL for Package WSH_DOC_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DOC_SETS" AUTHID CURRENT_USER as
/* $Header: WSHUSDSS.pls 115.1 99/07/16 08:23:57 porting ship $ */

  --
  -- Name
  --   Print_Document_Sets
  -- Purpose
  --   Execute any Delivery-based Document Set by submitting each document
  --   to the transaction manager
  -- Arguments
  --   many
  -- Notes
  --   all the paramters for every possible report in any document set
  --   must be included as the paramters to this package. To reduce the
  --   number of them we introduced naming standards for Delivery Based
  --   shipping. However we must still support oexski and oexobr.

/* Included P_PROG_REQUEST_ID as a fix for bug 859003 */

  PROCEDURE Print_Document_Sets (X_report_set_id IN number,
	      P_BATCH_NAME              in varchar2 DEFAULT NULL,
	      P_BATCH_ID                in varchar2 DEFAULT NULL,
	      P_PROG_REQUEST_ID         in varchar2 DEFAULT NULL,
	      P_CATEGORY_HIGH           in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_CATEGORY_LOW            in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_CUSTOMER_ITEMS          in varchar2 DEFAULT NULL,
	      P_DELIVERY_ID             in varchar2 DEFAULT NULL,
	      P_DEPARTURE_DATE_HI       in varchar2 DEFAULT NULL,
	      P_DEPARTURE_DATE_LO       in varchar2 DEFAULT NULL,
	      P_DEPARTURE_ID            in varchar2 DEFAULT NULL,
	      P_FREIGHT_CARRIER         in varchar2 DEFAULT NULL,
	      P_ITEM                    in varchar2 DEFAULT NULL,
	      P_ITEM_DISPLAY            in varchar2 DEFAULT NULL,
	      P_ITEM_FLEX_CODE          in varchar2 DEFAULT NULL,
	      P_LINE_FLAG               in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_LOCATOR_FLEX_CODE       in varchar2 DEFAULT NULL,
	      P_ORDER_CATEGORY          in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_ORDER_TYPE_HIGH         in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_ORDER_TYPE_LOW          in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_ORGANIZATION_ID         in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_PICK_SLIP_NUMBER_HIGH   in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_PICK_SLIP_NUMBER_LOW    in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_PRINT_DESCRIPTION       in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_RELEASE_DATE_HIGH       in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_RELEASE_DATE_LOW        in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_RESERVATIONS            in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_SHIP_DATE_HIGH          in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_SHIP_DATE_LOW           in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_SOB_ID                  in varchar2 DEFAULT NULL,
	      P_USE_FUNCTIONAL_CURRENCY in varchar2 DEFAULT NULL,
	      P_WAREHOUSE               in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_WAREHOUSE_HIGH          in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_WAREHOUSE_ID            in varchar2 DEFAULT NULL,
	      P_WAREHOUSE_LOW           in varchar2 DEFAULT NULL,  /* oexshski only */
              P_TEXT1                   in varchar2 default null,
	      P_TEXT2                   in varchar2 default null,
	      P_TEXT3                   in varchar2 default null,
	      P_TEXT4                   in varchar2 default null,
              message_string            in out varchar2,
              status                    in out boolean);




END WSH_DOC_SETS;

 

/
