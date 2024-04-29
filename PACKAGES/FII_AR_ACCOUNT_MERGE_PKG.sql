--------------------------------------------------------
--  DDL for Package FII_AR_ACCOUNT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_ACCOUNT_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIAR21S.pls 120.0.12000000.1 2007/02/23 02:27:37 applrt ship $ */

PROCEDURE MERGE_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE MERGE_FACT_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE MERGE_COLLECTOR_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE MERGE_CUSTOMER_ACCOUNTS
 (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

End FII_AR_ACCOUNT_MERGE_PKG;

 

/
