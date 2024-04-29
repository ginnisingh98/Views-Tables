--------------------------------------------------------
--  DDL for Package AR_CMGT_ACCOUNT_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_ACCOUNT_MERGE" AUTHID CURRENT_USER AS
/*  $Header: ARCMGAMS.pls 115.0 2003/03/09 20:23:10 bsarkar noship $ */

PROCEDURE CASE_FOLDER_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE CREDIT_REQUEST_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE TRX_BAL_SUMMARY_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE TRX_SUMMARY_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);
END;

 

/
