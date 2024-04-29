--------------------------------------------------------
--  DDL for Package INV_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: INVFBWFS.pls 120.2.12000000.1 2007/01/17 16:14:16 appldev ship $ */


FUNCTION CALL_GENERATE_COGS (
        c_FB_FLEX_NUM IN NUMBER DEFAULT 101,
        c_IC_CUSTOMER_ID IN NUMBER DEFAULT NULL,
        c_IC_ITEM_ID IN NUMBER DEFAULT NULL,
        c_IC_ORDER_HEADER_ID IN NUMBER DEFAULT NULL,
        c_IC_ORDER_LINE_ID IN NUMBER DEFAULT NULL,
        c_IC_ORDER_TYPE_ID IN NUMBER DEFAULT NULL,
        c_IC_SELL_OPER_UNIT IN NUMBER DEFAULT NULL,
        c_V_CCID IN OUT NOCOPY NUMBER,
        c_FB_FLEX_SEG IN OUT NOCOPY VARCHAR2,
        c_FB_ERROR_MSG IN OUT NOCOPY VARCHAR2,
        c_IC_TO_INV_ORGANIZATION_ID IN NUMBER DEFAULT NULL)  -- Bug: 4474976. Added parameter to get the Selling Inventory organization.
        RETURN BOOLEAN;


FUNCTION GENERATE_COGS (
        FB_FLEX_NUM IN NUMBER DEFAULT 101,
        IC_CUSTOMER_ID IN VARCHAR2 DEFAULT NULL,
        IC_ITEM_ID IN VARCHAR2 DEFAULT NULL,
        IC_ORDER_HEADER_ID IN VARCHAR2 DEFAULT NULL,
        IC_ORDER_LINE_ID IN VARCHAR2 DEFAULT NULL,
        IC_ORDER_TYPE_ID IN VARCHAR2 DEFAULT NULL,
        IC_SELL_OPER_UNIT IN VARCHAR2 DEFAULT NULL,
        V_CCID IN OUT NOCOPY NUMBER,
        FB_FLEX_SEG IN OUT NOCOPY VARCHAR2,
        FB_ERROR_MSG IN OUT NOCOPY VARCHAR2,
        IC_TO_INV_ORGANIZATION_ID IN NUMBER DEFAULT NULL) -- Bug: 4474976. Added parameter to get the Selling Inventory organization.
        RETURN BOOLEAN;

Procedure INVOKE_BUILD (        itemtype        IN         VARCHAR2,
                                itemkey         IN         VARCHAR2,
                                actid           IN         NUMBER,
                                funcmode        IN         VARCHAR2,
                                result          OUT NOCOPY VARCHAR2);

END INV_WORKFLOW;

 

/
