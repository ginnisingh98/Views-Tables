--------------------------------------------------------
--  DDL for Package CS_SR_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_ACCOUNT_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: cssramgs.pls 115.1 2003/05/07 15:05:04 pkesani noship $ */

PROCEDURE CS_MERGE_CUST_ACCOUNT_ID( req_id       IN NUMBER,
                                    set_number   IN NUMBER,
                                    process_mode IN VARCHAR2 );

PROCEDURE MERGE_CUST_ACCOUNTS( req_id       IN NUMBER,
                               set_number   IN NUMBER,
                               process_mode IN VARCHAR2 );

END CS_SR_ACCOUNT_MERGE_PKG;

 

/
