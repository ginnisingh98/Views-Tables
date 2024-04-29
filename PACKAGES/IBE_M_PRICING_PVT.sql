--------------------------------------------------------
--  DDL for Package IBE_M_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_M_PRICING_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVMPLS.pls 120.0.12010000.2 2012/10/29 06:03:19 amaheshw ship $ */

-- Cursors with data for mini-site

TYPE pricing_cur_type IS REF CURSOR;
TYPE currency_cur_type IS REF CURSOR;

--bug 14789352
 procedure parseInputTable (p_inTable IN QP_UTIL_PUB.PRICE_LIST_TBL,
                        p_Type     IN VARCHAR2,
                        p_keyString IN VARCHAR2,
                        p_number IN NUMBER,
                        x_QueryString OUT NOCOPY VARCHAR2);

PROCEDURE Search_Price_List
  (
   p_currency_code                  IN VARCHAR2,
   p_search_by                      IN NUMBER,
   p_search_value                   IN VARCHAR2,
   x_pricelist_csr                  OUT NOCOPY pricing_cur_type
  );
  PROCEDURE Search_Currency
  (
   p_search_by                      IN VARCHAR2,
   p_search_value                   IN VARCHAR2,
   x_currency_csr                  OUT NOCOPY currency_cur_type
  );
END Ibe_M_Pricing_Pvt;

/
