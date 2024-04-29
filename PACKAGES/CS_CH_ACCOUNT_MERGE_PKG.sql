--------------------------------------------------------
--  DDL for Package CS_CH_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CH_ACCOUNT_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: cschmags.pls 115.0 2003/05/08 21:21:00 mviswana noship $ */

PROCEDURE CS_CH_MERGE_CUST_ACCOUNT_ID( req_id       IN NUMBER,
                                    set_number   IN NUMBER,
                                    process_mode IN VARCHAR2 );

PROCEDURE MERGE_CUST_ACCOUNTS( req_id       IN NUMBER,
                               set_number   IN NUMBER,
                               process_mode IN VARCHAR2 );

END CS_CH_ACCOUNT_MERGE_PKG;

 

/
