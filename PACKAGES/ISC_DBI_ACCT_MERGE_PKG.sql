--------------------------------------------------------
--  DDL for Package ISC_DBI_ACCT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_ACCT_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCACMGS.pls 115.1 2004/05/21 22:31:32 scheung noship $ */

PROCEDURE ISC_BOOK_SUM2_PDUE_F_AM (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE ISC_BOOK_SUM2_PDUE2_F_AM (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE ISC_BOOK_SUM2_BKORD_F_AM (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

END  ISC_DBI_ACCT_MERGE_PKG;

 

/
