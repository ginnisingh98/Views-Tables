--------------------------------------------------------
--  DDL for Package Body QRM_EQ_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QRM_EQ_FORMULAS" AS
/* $Header: qrmeqflb.pls 115.5 2003/11/22 00:36:20 prafiuly noship $ */




PROCEDURE fv_stock(p_price_model	IN		VARCHAR2,
		   p_ccy		IN		VARCHAR2,
		   p_issue_code		IN		VARCHAR2,
		   p_market_set		IN		VARCHAR2,
		   p_share_price	IN		NUMBER,
		   p_shares_rem		IN		NUMBER,
		   p_date		IN		DATE,
		   p_fair_value		IN	OUT NOCOPY	NUMBER,
		   p_reval_rate		IN	OUT NOCOPY	NUMBER) IS

	p_md_in       XTR_MARKET_DATA_P.md_from_set_in_rec_type;
	p_md_out      XTR_MARKET_DATA_P.md_from_set_out_rec_type;
	l_ric_code    XTR_STOCK_ISSUES.ric_code%TYPE;
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_EQ_FORMULAS.fv_stock');
  END IF;
  IF (p_price_model = 'MARKET') THEN

    select RIC_CODE
    into l_ric_code
    from XTR_STOCK_ISSUES
    where stock_issue_code = p_issue_code;


    p_md_in.p_md_set_code := p_market_set;
    p_md_in.p_source := 'C';
    p_md_in.p_indicator := 'T';
    p_md_in.p_spot_date := p_date;
    p_md_in.p_future_date := p_date;
    p_md_in.p_ccy := p_ccy;
    p_md_in.p_contra_ccy := NULL;
    p_md_in.p_day_count_basis_out := NULL;
    p_md_in.p_interpolation_method := NULL;
    p_md_in.p_side := 'B';			-- Always Buy deal, use bid
    p_md_in.p_batch_id := NULL;
    p_md_in.p_bond_code := l_ric_code;

    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);

    p_reval_rate    := p_md_out.p_md_out;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('fv_stock: ' || 'Stock price: '||p_reval_rate);
    END IF;

    p_fair_value := p_reval_rate * p_shares_rem;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('fv_stock: ' || 'Fair value: '||p_fair_value);
      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_EQ_FORMULAS.fv_stock');
   END IF;

  END IF;
END fv_stock;

END;

/
