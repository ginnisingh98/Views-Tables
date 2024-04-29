--------------------------------------------------------
--  DDL for Package CE_COPY_TRX_CODES_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_COPY_TRX_CODES_XML" AUTHID CURRENT_USER AS
/* $Header: cecptxcs.pls 120.0.12010000.1 2009/07/31 08:39:01 vnetan noship $ */

    -- Parameter variables
    P_SOURCE_ACCT_ID    NUMBER(15)   default NULL;
    P_DEST_BANK_ID      NUMBER(15)   default NULL;
    P_DEST_BRANCH_ID    NUMBER(15)   default NULL;
    P_DEST_ACCT_ID      NUMBER(15)   default NULL;
    P_DEST_ACCT_TYPE    VARCHAR2(30) default NULL;

    -- Global Variables
    G_SOURCE_ACCOUNT_NAME   VARCHAR2(50);
    G_SOURCE_ACCOUNT_NUM    VARCHAR2(30);
    G_DEST_BANK_NAME        VARCHAR2(50);
    G_DEST_BRANCH_NAME      VARCHAR2(50);
    G_DEST_ACCOUNT_NUM      VARCHAR2(50);
    G_DEST_ACCOUNT_TYPE     VARCHAR2(50);
    G_CONC_REQUEST_ID       NUMBER(15);
    G_INSERT_COUNT          NUMBER;

    -- Report Triggers
    FUNCTION beforeReport RETURN BOOLEAN;
    FUNCTION afterReport RETURN BOOLEAN;


END CE_COPY_TRX_CODES_XML;

/
