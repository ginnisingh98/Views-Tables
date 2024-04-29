--------------------------------------------------------
--  DDL for Package OKC_OC_INT_SALESCDT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_SALESCDT_PVT" AUTHID CURRENT_USER AS
/*  $Header: OKCRSCTS.pls 120.2 2006/03/01 13:45:32 smallya noship $   */

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_PKG_NAME	          CONSTANT VARCHAR2(200) := 'OKC_OC_INT_SALESCDT_PVT';
  --  G_APP_NAME              CONSTANT VARCHAR2(3)   :=  OKO_DATATYPES.G_APP_NAME;
  -- to be restoed after this package is moved back into OKO

  G_APP_NAME              CONSTANT VARCHAR2(3)   :=  'OKO'; --for OKO error messages
  G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_ERROR                 CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_ERROR';
  G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLCODE';

  --G_MISS_REL_LINE_TAB     OKC_K_REL_OBJS_PUB.crj_rel_line_tbl_type;
  G_MISS_LINE_INF_TAB     OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type;

  G_SALESREP_CTROL        CONSTANT fnd_lookups.lookup_code%TYPE := 'SALESPERSON';
  ---------------------------------------------------------------------------
  --Procedure to create contract sales credit information at the header and line levels
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE create_k_sales_credit (
    x_return_status               OUT NOCOPY VARCHAR2,

    p_chr_id                      IN  OKC_K_HEADERS_B.ID%TYPE,
    p_o_flag                      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id                      IN  NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_q_flag                      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id                      IN  OKX_QUOTE_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM,
    p_line_inf_tab                IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
		             DEFAULT  OKC_OC_INT_SALESCDT_PVT.G_MISS_LINE_INF_TAB
    -- this PL/SQL table has quote (or order) lines against contract lines

  );



  ----------------------------------------------------------------------------
  -- Procedure creates sales credit information in OKC from
  -- ASO or ONT sales credit
  ----------------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
  PROCEDURE get_sales_credit(
    p_chr_id                    IN  NUMBER,
    p_q_flag                    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_qhr_id                    IN  OKX_QUOTE_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM,
    p_o_flag                    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_ohr_id                    IN  NUMBER DEFAULT OKC_API.G_MISS_NUM,
    p_line_inf_tab              IN  OKC_OC_INT_CONFIG_PVT.line_inf_tbl_type
			     DEFAULT OKC_OC_INT_SALESCDT_PVT.G_MISS_LINE_INF_TAB
    );


    ----------------------------------------------------------------------
    -- PROCEDURE to get SALES CREDITS information from ASO or ONT tables
    -- get_sales_credit_tab stores it's output in global PL/SQL table g_sales_credit_tab
    ----------------------------------------------------------------------
-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
--                                     ASO_QUOTE_LINES_ALL.LINE_HEADER_ID to OKX_QUOTE_LINES_V.ID1
    PROCEDURE get_sales_credit_tab(
                p_chr_id  IN OKC_K_HEADERS_B.ID%TYPE,
                p_cle_id  IN OKC_K_LINES_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM,

                p_o_flag  IN VARCHAR2 DEFAULT OKC_API.G_FALSE, --order flag
                p_ohr_id  IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
                p_ole_id  IN NUMBER DEFAULT OKC_API.G_MISS_NUM,

                p_q_flag  IN VARCHAR2 DEFAULT OKC_API.G_FALSE, --quote flag
                p_qhr_id  IN OKX_QUOTE_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM,
                p_qle_id  IN OKX_QUOTE_LINES_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM);


--  ========================================================================
--                 START OF KTQ or KTO SALES CREDIT INFORMATION CREATION
--                                   or UPDATE
--  ========================================================================


g_aso_model_item	CONSTANT VARCHAR2(30) := 'MDL';


TYPE k_sales_credit_rec_type IS RECORD( id OKC_K_SALES_CREDITS.id%TYPE,
                                        level VARCHAR2(1));

TYPE k_sales_credit_tab_type IS TABLE OF k_sales_credit_rec_type INDEX BY BINARY_INTEGER;

g_aso_op_code_create VARCHAR2(30) := 'CREATE';
g_aso_op_code_update VARCHAR2(30) := 'UPDATE';
g_aso_op_code_delete VARCHAR2(30) := 'DELETE';

l_line_tab    ASO_QUOTE_PUB.qte_line_tbl_type;
l_k_sales_credit_tab  k_sales_credit_tab_type;


    ----------------------------------------------------------------------
    --
    -- PROCEDURE build_sales_credit_from_k
    --
    -- To get sales credits information from contract table(s) at header
    -- and line levels to update a quote or create an order.
    --
    ----------------------------------------------------------------------

PROCEDURE build_sales_credit_from_k(
        p_chr_id           IN  OKC_K_HEADERS_B.id%TYPE,
        p_kl_rel_tab       IN  okc_oc_int_config_pvt.line_rel_tab_type DEFAULT okc_oc_int_config_pvt.g_miss_kl_rel_tab,
     --
        p_q_flag           IN  VARCHAR2                             DEFAULT OKC_API.g_miss_char,
        p_qhr_id           IN  OKX_QUOTE_HEADERS_V.id1%TYPE         DEFAULT OKC_API.g_miss_num,
        p_qle_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      DEFAULT ASO_QUOTE_PUB.g_miss_qte_line_tbl,
     --
        p_o_flag           IN  VARCHAR2                             DEFAULT OKC_API.g_miss_char,
        p_ohr_id           IN  OKX_ORDER_HEADERS_V.id1%TYPE         DEFAULT OKC_API.g_miss_num,
        p_ole_tab          IN  ASO_QUOTE_PUB.qte_line_tbl_type      DEFAULT ASO_QUOTE_PUB.g_miss_qte_line_tbl,
     --
        x_hd_sales_credit_tab           OUT NOCOPY ASO_QUOTE_PUB.sales_credit_tbl_type,
        x_ln_sales_credit_tab           OUT NOCOPY ASO_QUOTE_PUB.sales_credit_tbl_type,
     --
        x_return_status                 OUT NOCOPY  VARCHAR2 );


--  ========================================================================
--                 END OF KTQ or KTO SALES CREDIT INFORMATION CREATION
--                                   or UPDATE
--  ========================================================================




----------------------------------------------------------------------
--
-- Function get_party_name to retrieve a party name against    -------
-- the jtot_object1_code and object1_id1                       -------
--
-- This is a general function that can be used anywhere to retrieve
-- the party name for eg. from the OKCSLCRD.fmb sales credit form
FUNCTION get_party_name (p_object1_id1 varchar2,  p_jtot_object1_code varchar2) RETURN VARCHAR2;


END OKC_OC_INT_SALESCDT_PVT;

 

/
