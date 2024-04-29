--------------------------------------------------------
--  DDL for Package MTL_CC_TRANSACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CC_TRANSACT_PKG" AUTHID CURRENT_USER as
/* $Header: INVATC2S.pls 120.0 2005/05/25 06:48:51 appldev noship $ */

-- This function is used for cycle count adjustment transactions
-- The lpn_discrepancy parameter is used when during cycle counting,
-- an LPN discrepancy is found and a subinventory transfer on that LPN
-- needs to be issued.  It defaults to 2 for no, 1 when an LPN discrepancy
-- transaction is processed
FUNCTION CC_TRANSACT(   org_id            NUMBER                  ,
                        cc_header_id      NUMBER                  ,
                        item_id           NUMBER                  ,
                        sub               VARCHAR2                ,
                        PUOMQty           NUMBER                  ,
                        TxnQty            NUMBER                  ,
                        TxnUOM            VARCHAR2                ,
                        TxnDate           DATE                    ,
                        TxnAcctId         NUMBER                  ,
                        LotNum            VARCHAR2                ,
                        LotExpDate        DATE                    ,
                        rev               VARCHAR2                ,
                        locator_id        NUMBER                  ,
                        TxnRef            VARCHAR2                ,
                        ReasonId          NUMBER                  ,
                        UserId            NUMBER                  ,
                        cc_entry_id       NUMBER                  ,
                        LoginId           NUMBER                  ,
                        TxnProcMode       NUMBER                  ,
                        TxnHeaderId       NUMBER                  ,
                        SerialNum         VARCHAR2                ,
                        TxnTempId         NUMBER                  ,
                        SerialPrefix      VARCHAR2                ,
                        lpn_id            NUMBER                  ,
                        transfer_sub      VARCHAR2 DEFAULT NULL   ,
                        transfer_loc_id   NUMBER DEFAULT NULL     ,
                        cost_group_id     NUMBER DEFAULT NULL     ,
                        lpn_discrepancy   NUMBER DEFAULT 2
                       ,secUOM            VARCHAR2 DEFAULT NULL    -- INVCONV,NSRIVAST
                       ,secQty            NUMBER DEFAULT NULL      -- INVCONV,NSRIVAST
                        )
        RETURN Number;

END MTL_CC_TRANSACT_PKG;

 

/
