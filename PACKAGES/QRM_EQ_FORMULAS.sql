--------------------------------------------------------
--  DDL for Package QRM_EQ_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QRM_EQ_FORMULAS" AUTHID CURRENT_USER AS
/* $Header: qrmeqfls.pls 115.4 2003/11/22 00:36:19 prafiuly noship $ */

--bug 3236479
g_debug_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;

PROCEDURE fv_stock(p_price_model	IN		VARCHAR2,
		   p_ccy		IN		VARCHAR2,
		   p_issue_code		IN		VARCHAR2,
		   p_market_set		IN		VARCHAR2,
		   p_share_price	IN		NUMBER,
		   p_shares_rem		IN		NUMBER,
		   p_date		IN		DATE,
		   p_fair_value		IN	OUT NOCOPY	NUMBER,
		   p_reval_rate		IN	OUT NOCOPY	NUMBER);



END;

 

/
