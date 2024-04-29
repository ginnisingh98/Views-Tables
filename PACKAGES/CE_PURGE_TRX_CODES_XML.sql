--------------------------------------------------------
--  DDL for Package CE_PURGE_TRX_CODES_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_PURGE_TRX_CODES_XML" AUTHID CURRENT_USER AS
/* $Header: ceputxcs.pls 120.0.12010000.1 2009/07/31 08:40:05 vnetan noship $ */

    -- Parameter variables
    P_PROCESS_OPTION    VARCHAR2(30) default NULL;
    P_REQUEST_ID        NUMBER(15)   default NULL;
    P_BANK_ID           NUMBER(15)   default NULL;
    P_BANK_BRANCH_ID    NUMBER(15)   default NULL;
    P_BANK_ACCT_ID      NUMBER(15)   default NULL;
    P_ACCT_TYPE         VARCHAR2(30) default NULL;


    -- Global Variables
    G_PROCESS_OPTION    VARCHAR2(50);
    G_BANK_NAME         VARCHAR2(50);
    G_BRANCH_NAME       VARCHAR2(50);
    G_ACCOUNT_NUM       VARCHAR2(50);
    G_ACCOUNT_TYPE      VARCHAR2(50);
    G_DELETE_COUNT      NUMBER;

    -- Report Triggers
    FUNCTION beforeReport RETURN BOOLEAN;
    FUNCTION afterReport RETURN BOOLEAN;


END CE_PURGE_TRX_CODES_XML;

/
