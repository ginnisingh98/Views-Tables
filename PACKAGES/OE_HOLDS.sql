--------------------------------------------------------
--  DDL for Package OE_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HOLDS" AUTHID CURRENT_USER as
/* $Header: OEXOHAPS.pls 115.0 99/07/16 08:13:50 porting ship $ */
function HOLDS_API
	        (V_ACTION in varchar2,
                 V_HOLD_ID IN number,
		V_ENTITY_CODE IN varchar2,
		V_ENTITY_ID IN number,
		V_REASON_CODE IN varchar2,
		V_COMMENT IN varchar2,
		V_MSG_TEXT OUT varchar2,
                V_LINE_ID IN number DEFAULT NULL,
                V_HEADER_ID IN number DEFAULT NULL,
                P_HOLD_NAME IN varchar2 DEFAULT NULL,
                P_ORDER_NUMBER IN number DEFAULT NULL,
                P_ORDER_TYPE IN varchar2 DEFAULT NULL,
                P_APPLICATION_ID IN number DEFAULT NULL,
                P_RESPONSIBILITY_ID IN number DEFAULT NULL,
                P_CUSTOMER_ID IN number DEFAULT NULL,
                P_SITE_USE_ID IN number DEFAULT NULL)
		RETURN number;
end OE_HOLDS;

 

/
