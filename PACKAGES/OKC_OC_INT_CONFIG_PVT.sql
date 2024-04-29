--------------------------------------------------------
--  DDL for Package OKC_OC_INT_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_CONFIG_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRCFGS.pls 120.0 2005/05/26 09:42:48 appldev noship $        */

G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKC_OC_INT_CONFIG_PVT';
G_APP_NAME                     CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

G_MODEL_LINE                    CONSTANT OKC_K_LINES_B.CONFIG_ITEM_TYPE%TYPE := 'TOP_MODEL_LINE';
G_BASE_LINE                     CONSTANT OKC_K_LINES_B.CONFIG_ITEM_TYPE%TYPE := 'TOP_BASE_LINE';
G_NORMAL_LINE                   CONSTANT OKC_K_LINES_B.CONFIG_ITEM_TYPE%TYPE := 'CONFIG';
rolledup_line_list_price        NUMBER :=0;
rolledup_price_negotiated       NUMBER :=0;

-- Bug : 1686001 Changed references aso_quote_lines_all  to  okx_quote_lines_v
TYPE line_inf_rec_type IS RECORD(cle_id       okc_k_lines_b.id%TYPE
                                ,lse_id       okc_k_lines_b.lse_id%TYPE
                                ,lty_code     okc_line_styles_b.lty_code%TYPE
                                ,object1_id1  okx_order_headers_v.id1%TYPE
                                ,line_num     NUMBER
                                ,subline      NUMBER
                                ,line_qty     okx_quote_lines_v.quantity%TYPE
                                ,line_uom     okx_quote_lines_v.uom_code%TYPE
                                ,line_type    OKC_K_LINES_B.CONFIG_ITEM_TYPE%TYPE
                                );

TYPE line_inf_tbl_type IS TABLE OF line_inf_rec_type INDEX BY BINARY_INTEGER;

TYPE source_inf_rec_type IS RECORD(o_flag        VARCHAR2(1) DEFAULT OKC_API.G_FALSE
                                  ,q_flag        VARCHAR2(1) DEFAULT OKC_API.G_FALSE
                                  ,line_id       OKX_ORDER_LINES_V.ID1%TYPE
                                  ,line_number   OKX_ORDER_LINES_V.LINE_NUMBER%TYPE
                                  ,Object_number OKX_ORDER_HEADERS_V.ORDER_NUMBER%TYPE
                                  );


TYPE line_rel_rec_type IS RECORD (k_line_id             okc_k_lines_b.id%TYPE
                                 ,k_parent_line_id      okc_k_lines_b.id%TYPE
                                 ,q_line_idx            NUMBER
                                 ,q_item_type_code      okx_quote_lines_v.item_type_code%TYPE
                                  );

TYPE line_rel_tab_type IS TABLE OF line_rel_rec_type INDEX BY BINARY_INTEGER;

g_miss_kl_rel_tab line_rel_tab_type;

g_okc_model_item                CONSTANT VARCHAR2(30)  := 'TOP_MODEL_LINE';
g_okc_base_item                 CONSTANT VARCHAR2(30)  := 'TOP_BASE_LINE';
g_okc_config_item               CONSTANT VARCHAR2(30)  := 'CONFIG';
g_okc_service_item              CONSTANT VARCHAR2(30)  := 'SRV';


g_aso_model_item                CONSTANT VARCHAR2(30)  := 'MDL';
g_aso_config_item               CONSTANT VARCHAR2(30)  := 'CFG';
g_aso_service_item              CONSTANT VARCHAR2(30)  := 'SRV';


g_aso_op_code_create VARCHAR2(30) := 'CREATE';
g_aso_op_code_update VARCHAR2(30) := 'UPDATE';
g_aso_op_code_delete VARCHAR2(30) := 'DELETE';



-------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure:       create_k_config_lines
-- Purpose:         To create the lines in contract corresponding to child lines of a Model Item in Order or Quote.
--                  For Each Model Item line in quote and Order 2 Contract lines will be created.One Contract Line will be
--                  having config_item_type_code ='TOP_MODEL_LINE' and other one which is child of this one will have
--                  having config_item_type_code ='TOP_BASE_LINE'
--
--                 This Procedure then calls create_config_sublines to create/transfer Option class and Option Item lines
--                 from order or quote to Contract.

-- In Parameters:   p_source_inf_rec  It will contain info like order/quote header id and Flag stating that If this
--                                    proceedure is being called for Order or Contract.
--                  p_clev_rec        Contract Line rec of Top line
--                  p_cimv_rec        Contract Item rec of Top line
--                  p_line_inf_tab    PL/SQL table to return relationship between K Line and Quote/Order Line
-- Out Parameters:  x_return_status   Return Status
--------------------------------------------------------------------------------------------------------------------------------------------
Procedure create_k_config_lines( p_source_inf_rec IN  SOURCE_INF_REC_TYPE,
                                 p_clev_rec       IN  OKC_CONTRACT_PUB.CLEV_REC_TYPE,
                                 p_cimv_rec       IN  OKC_CONTRACT_ITEM_PUB.CIMV_REC_TYPE,
                                 p_line_inf_tab   IN OUT NOCOPY LINE_INF_TBL_TYPE,
                                 x_clev_rec       OUT NOCOPY  OKC_CONTRACT_PUB.CLEV_REC_TYPE,
                                 x_return_status  OUT NOCOPY  VARCHAR2
                                );

-- =====================================================================================
--
-- Purpose: To build the relationship between quote lines which is
--	    populated in the aso_line_relationships table
--
-- IN parameters: px_k2q_line_tbl 	- holds k to q relation
--		  px_qte_line_tbl 	- holds quote line information
--		  px_qte_line_dtl_tbl 	- holds quote line detail information
--
-- OUT parameters: l_line_rltship_tab	- holds the information about relationship
--					  between quote lines.
--		   x_return_status	- Return status of the procedure executed.
--
-- =====================================================================================


PROCEDURE quote_line_relationship( px_k2q_line_tbl 	IN line_rel_tab_type DEFAULT g_miss_kl_rel_tab
			 ,px_qte_line_tbl 	IN ASO_QUOTE_PUB.qte_line_tbl_type
                         ,px_qte_line_dtl_tbl   IN ASO_QUOTE_PUB.qte_line_dtl_tbl_type
			 ,x_line_rltship_tab  OUT NOCOPY ASO_QUOTE_PUB.line_rltship_tbl_type
			 ,x_return_status   OUT NOCOPY  VARCHAR2
			 );



END OKC_OC_INT_CONFIG_PVT;

 

/
