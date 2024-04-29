--------------------------------------------------------
--  DDL for Package GL_TRANS_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TRANS_STATUSES_PKG" AUTHID CURRENT_USER AS
/* $Header: glitrsts.pls 120.3 2005/05/05 01:29:03 kvora ship $ */
--
-- Package
--   GL_TRANS_STATUSES_PKG
-- Purpose
--   To create GL_TRANS_STATUSES_PKG package.
--

  PROCEDURE set_translation_status( x_chart_of_accounts_id NUMBER,
				 x_ccid			NUMBER,
				 x_ledger_id  		NUMBER,
                                 x_currency		VARCHAR2,
                                 x_period_year		NUMBER,
                                 x_period_num 		NUMBER,
                                 x_period_name 		VARCHAR2,
                                 x_last_updated_by	NUMBER,
                                 x_usage_code   	VARCHAR2 );


END GL_TRANS_STATUSES_PKG;

 

/
