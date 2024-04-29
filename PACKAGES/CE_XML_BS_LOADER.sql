--------------------------------------------------------
--  DDL for Package CE_XML_BS_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_XML_BS_LOADER" AUTHID CURRENT_USER AS
/* $Header: cexmldrs.pls 120.2 2002/11/05 21:51:06 byleung noship $      */

PROCEDURE SETUP_IMPORT(
                X_STATEMENT_NUMBER      IN      VARCHAR2,
                X_BANK_ACCOUNT_NUM      IN      VARCHAR2,
                X_TRADING_PARTNER       IN      VARCHAR2,
                X_ITEM_KEY              IN      VARCHAR2);

PROCEDURE RUN_IMPORT;

END CE_XML_BS_LOADER;

 

/
