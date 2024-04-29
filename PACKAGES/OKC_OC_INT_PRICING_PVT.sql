--------------------------------------------------------
--  DDL for Package OKC_OC_INT_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_PRICING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRPRIS.pls 120.0 2005/05/25 22:36:17 appldev noship $ */

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_PKG_NAME	          CONSTANT VARCHAR2(200) := 'OKC_OC_INT_PRICING_PVT';
  ---G_APP_NAME              CONSTANT VARCHAR2(3)   := OKO_DATATYPES.G_APP_NAME;
  -- to be restored when this package is moved back into OKO

  G_APP_NAME              CONSTANT VARCHAR2(3)   := 'OKO';

  G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_ERROR                 CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_ERROR';
  G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';

  --G_MISS_REL_LINE_TAB     OKC_K_REL_OBJS_PUB.crj_rel_line_tbl_type;
  G_MISS_LINE_INF_TAB     OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type;

  ---------------------------------------------------------------------------
  --Procedure to contract pricing information at the header and line levels
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE create_k_pricing (
    x_return_status               OUT NOCOPY VARCHAR2,

    p_chr_id                      IN  OKC_K_HEADERS_B.ID%TYPE,
    p_o_flag                      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id                      IN  NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_q_flag                      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id                      IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                                      DEFAULT OKC_API.G_MISS_NUM,
    p_line_inf_tab                IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
			     DEFAULT  OKC_OC_INT_PRICING_PVT.G_MISS_LINE_INF_TAB
    -- this PL/SQL table has quote (or order) lines against contract lines


  );



  ----------------------------------------------------------------------------
  -- Procedure creates price attribute information in OKC from
  -- ASO or ONT pricing
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_price_attr(
    p_chr_id                    IN  NUMBER,
    p_q_flag                    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id                    IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                                    DEFAULT OKC_API.G_MISS_NUM,
    p_o_flag                    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id                    IN  NUMBER,
    p_line_inf_tab              IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
			    DEFAULT OKC_OC_INT_PRICING_PVT.G_MISS_LINE_INF_TAB
    );



   --------------------------------------------------------------------------
   --------get price adjustments from ASO or ONT and put in OKC pricing tables
   --------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
   PROCEDURE get_price_adj(
    p_chr_id                       IN NUMBER,
    p_q_flag                       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id                       IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                                      DEFAULT OKC_API.G_MISS_NUM,
    p_o_flag                       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_line_inf_tab                 IN OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
			DEFAULT OKC_OC_INT_PRICING_PVT.G_MISS_LINE_INF_TAB
    );



  --put PRICE ADJUSTMENT RELATIONSHIPS FROM ASO (or ONT) into OKC
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_price_adj_rltship(
    p_o_flag          IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id          IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_q_flag          IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id          IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                         DEFAULT OKC_API.G_MISS_NUM,
    p_line_inf_tab    IN OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
	              DEFAULT OKC_OC_INT_PRICING_PVT.G_MISS_LINE_INF_TAB
     );



  ----------------------------------------------------------------
  --put PRICE ADJUSTMENT ATTRIBUTES FROM ASO or ONT into OKC
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_price_adj_attr(
    p_o_flag                       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_q_flag                       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id                       IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                                      DEFAULT OKC_API.G_MISS_NUM
                                    );

  ----------------------------------------------------------------------------
  -- PROCEDURE to get PRICE ADJUSTMENTS information from ASO or ONT tables
  -- get_patv_tab stores it's output in global PL/SQL table g_patv_tbl
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
  PROCEDURE get_patv_tab(
               p_chr_id   IN OKC_K_HEADERS_B.ID%TYPE,
               p_cle_id   IN OKC_K_LINES_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM,
               p_o_flag   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
               p_ohr_id   IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
               p_ole_id   IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
               p_q_flag   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
               p_qhr_id   IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                             DEFAULT OKC_API.G_MISS_NUM,
               p_qle_id   IN OKX_QUOTE_LINES_V.ID1%TYPE
                             DEFAULT OKC_API.G_MISS_NUM);


    ---------------------------------------------------------------
    -- PROCEDURE to get PRICE ADJUSTMENT RELATIONSHIP information
    -- from ASO or ONT tables
    -- get_pacv_tab stores all the price adjustment relationships in
    -- global PL/SQL table g_pacv_tbl
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
    PROCEDURE get_pacv_tab(
                p_old_pat_id    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                p_new_pat_id    IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                p_o_flag        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                p_ohr_id        IN NUMBER
                                   DEFAULT OKC_API.G_MISS_NUM,
                p_q_flag        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                p_qhr_id        IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                                   DEFAULT OKC_API.G_MISS_NUM,
                p_line_inf_tab  IN OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
		            DEFAULT OKC_OC_INT_PRICING_PVT.G_MISS_LINE_INF_TAB);


   -----------------------------------------------------------------------------
   -- to get PRICE ADJUSTMENT ATTRIBUTES information from ASO or ONT tables
   -- get_paav_tab stores all the price adjustment attributes in global
   -- PL/SQL table g_paav_tbl
   -----------------------------------------------------------------------------
    PROCEDURE get_paav_tab(p_old_pat_id IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                          p_new_pat_id IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                          p_q_flag     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          p_qhr_id     IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                          p_o_flag     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          p_ohr_id     IN NUMBER DEFAULT OKC_API.G_MISS_NUM);
                          --   x_paav_tbl OUT NOCOPY paav_tbl_type)


    ----------------------------------------------------------------------
    -- PROCEDURE to get PRICE ATTRIBUTES information from ASO or ONT tables
    -- get_pavv_tab stores it's output in global PL/SQL table g_pavv_tbl
    ----------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
    PROCEDURE get_pavv_tab(
                p_chr_id  IN OKC_K_HEADERS_B.ID%TYPE,
                p_cle_id  IN OKC_K_LINES_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM,

                p_o_flag  IN VARCHAR2 DEFAULT OKC_API.G_FALSE, --order flag
                p_ohr_id  IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                p_ole_id  IN NUMBER DEFAULT OKC_API.G_MISS_NUM,

                p_q_flag  IN VARCHAR2 DEFAULT OKC_API.G_FALSE, --quote flag
                p_qhr_id  IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                             DEFAULT OKC_API.G_MISS_NUM,
                p_qle_id  IN OKX_QUOTE_LINES_V.ID1%TYPE
	                     DEFAULT OKC_API.G_MISS_NUM);



--  =========================================================================
--  =========================================================================
--                   START OF KTQ or KTO PRICING INFORMATION CREATION
--                                   or UPDATE
--  =========================================================================
--  =========================================================================


  TYPE k_price_adj_rec_type IS RECORD(id okc_price_adjustments.id%TYPE,level VARCHAR2(1));

  TYPE k_price_adj_tab_type IS TABLE OF k_price_adj_rec_type index by binary_integer;


  g_aso_op_code_create VARCHAR2(30) := 'CREATE';
  g_aso_op_code_update VARCHAR2(30) := 'UPDATE';
  g_aso_op_code_delete VARCHAR2(30) := 'DELETE';

  x_return_status	VARCHAR2(1);
  p_o_flag		VARCHAR2(1);
  p_q_flag		VARCHAR2(1);

  p_qle_tab          ASO_QUOTE_PUB.qte_line_tbl_type DEFAULT ASO_QUOTE_PUB.g_miss_qte_line_tbl;
  p_qle_shipment_tab ASO_QUOTE_PUB.shipment_tbl_type DEFAULT ASO_QUOTE_PUB.g_miss_shipment_tbl;

  p_ole_tab          ASO_QUOTE_PUB.qte_line_tbl_type DEFAULT ASO_QUOTE_PUB.g_miss_qte_line_tbl;
  p_ole_shipment_tab ASO_QUOTE_PUB.shipment_tbl_type DEFAULT ASO_QUOTE_PUB.g_miss_shipment_tbl;



  e_exit EXCEPTION;

  l_line_tab	          ASO_QUOTE_PUB.qte_line_tbl_type;
  l_line_shipment_tab     ASO_QUOTE_PUB.shipment_tbl_type;
  l_k_price_adj_tab       k_price_adj_tab_type;


-----------------------------------------------------------------------------------------
-- procedure build_pricing_from_k
-----------------------------------------------------------------------------------------

-- Notes for the impact of configuration items on Pricing information
-- for k->Q update and K->O creation.
--
--      Quote                   Contract
--      -----                   --------
--      QL1 <----------------   KL1        Top Model line (Contains sales credit, rule info)
--            |______________    |__KSL1   Top Base line  (Contains Price adjustment info)
--                                  |
--      QL2 <----------------       |- KSL1.1  Config     (Contains Price adjustment info)
--      QL3 <----------------       |_ KSL1.2  Config     (Contains Price adjustment info)
--
-- The Top model line and the Top base line information is stored into the same
-- quote line as shown above and when the relationship PL/SQL table is constructed
-- the first relationship between KL1 and QL1 is overwritten by the second
-- relationship. Therefore the line id that is against the QL1 is the id
-- of the top base line.So there is no impact of configuration items on
-- Pricing information because all the information is available
--

PROCEDURE build_pricing_from_k(
	p_chr_id           IN  OKC_K_HEADERS_B.id%TYPE,
	p_kl_rel_tab       IN  okc_oc_int_config_pvt.line_rel_tab_type DEFAULT okc_oc_int_config_pvt.g_miss_kl_rel_tab,
     --
	p_q_flag           IN  VARCHAR2 			    DEFAULT OKC_API.g_miss_char,
	p_qhr_id           IN  OKX_QUOTE_HEADERS_V.id1%TYPE         DEFAULT OKC_API.g_miss_num,
	p_qle_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      DEFAULT ASO_QUOTE_PUB.g_miss_qte_line_tbl,
	p_qle_shipment_tab IN  ASO_QUOTE_PUB.shipment_tbl_type      DEFAULT ASO_QUOTE_PUB.g_miss_shipment_tbl,
     --
	p_o_flag           IN  VARCHAR2 			    DEFAULT OKC_API.g_miss_char,
	p_ohr_id           IN  OKX_ORDER_HEADERS_V.id1%TYPE         DEFAULT OKC_API.g_miss_num,
	p_ole_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      DEFAULT ASO_QUOTE_PUB.g_miss_qte_line_tbl,
	p_ole_shipment_tab IN  ASO_QUOTE_PUB.shipment_tbl_type      DEFAULT ASO_QUOTE_PUB.g_miss_shipment_tbl,
     --
	x_hd_price_adj_tab              OUT NOCOPY ASO_QUOTE_PUB.price_adj_tbl_type,
 	x_ln_price_adj_tab              OUT NOCOPY ASO_QUOTE_PUB.price_adj_tbl_type,
 	x_hd_price_adj_attr_tab         OUT NOCOPY ASO_QUOTE_PUB.price_adj_attr_tbl_type,
 	x_ln_price_adj_attr_tab         OUT NOCOPY ASO_QUOTE_PUB.price_adj_attr_tbl_type,
 	x_hd_price_attr_tab             OUT NOCOPY ASO_QUOTE_PUB.price_attributes_tbl_type,
 	x_ln_price_attr_tab             OUT NOCOPY ASO_QUOTE_PUB.price_attributes_tbl_type,
 	x_hd_price_adj_rltship_tab      OUT NOCOPY ASO_QUOTE_PUB.price_adj_rltship_tbl_type,
 	x_ln_price_adj_rltship_tab      OUT NOCOPY ASO_QUOTE_PUB.price_adj_rltship_tbl_type,
     --
	x_return_status      OUT NOCOPY  VARCHAR2);

--  =========================================================================
--  =========================================================================
--                   END OF KTQ or KTO PRICING INFORMATION CREATION
--                                   or UPDATE
--  =========================================================================
--  =========================================================================

END OKC_OC_INT_PRICING_PVT;

 

/
