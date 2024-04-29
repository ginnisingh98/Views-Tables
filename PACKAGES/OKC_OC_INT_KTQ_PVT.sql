--------------------------------------------------------
--  DDL for Package OKC_OC_INT_KTQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_KTQ_PVT" AUTHID CURRENT_USER AS
-- $Header: OKCRKTQS.pls 120.2 2006/02/28 14:51:40 smallya noship $
--
--  Copyright (c) 1999 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--
-- Global constants
--

g_rlt_typ_oh              	CONSTANT VARCHAR2(30)  := 'OKX_ORDERHEAD';
g_rlt_typ_ol              	CONSTANT VARCHAR2(30)  := 'OKX_ORDERLINE';
g_rlt_typ_qh              	CONSTANT VARCHAR2(30)  := 'OKX_QUOTEHEAD';
g_rlt_typ_ql              	CONSTANT VARCHAR2(30)  := 'OKX_QUOTELINE';
g_rlt_code_ktq            	CONSTANT VARCHAR2(30)  := 'CONTRACTISTERMSFORQUOTE';
g_rlt_code_knq            	CONSTANT VARCHAR2(30)  := 'CONTRACTNEGOTIATESQUOTE';
g_rlt_cod_qrk             	CONSTANT VARCHAR2(30)  := 'QUOTERENEWSCONTRACT';

-- other constants
g_k_s_class                     CONSTANT VARCHAR2(30)  := 'SERVICE';
g_k_kfq_subclass                CONSTANT VARCHAR2(30)  := 'KFORQUOTE';
--
-- contract top line styles
g_lt_coverprod                  CONSTANT VARCHAR2(30)  := 'COVER_PROD';
g_lt_supp                       CONSTANT VARCHAR2(30)  := 'SUPPORT';
g_support                 	CONSTANT VARCHAR2(1)   := 'S';
g_lt_suppline                   CONSTANT VARCHAR2(30)  := 'SUPPORT_LINE';
--
g_lt_service                    CONSTANT VARCHAR2(30)  := 'SERVICE';
g_lt_support                    CONSTANT VARCHAR2(30)  := 'SUPPORT';
g_lt_ext_warr                   CONSTANT VARCHAR2(30)  := 'EXT_WARRANTY';
--
g_rd_billto                     CONSTANT VARCHAR2(30)  := 'BTO';
g_rd_shipto                     CONSTANT VARCHAR2(30)  := 'STO';
g_rd_shipmtd                    CONSTANT VARCHAR2(30)  := 'SMD';
g_rd_convert                    CONSTANT VARCHAR2(30)  := 'CVN';
g_rd_custacct                   CONSTANT VARCHAR2(30)  := 'CAN';
g_rd_invrule                    CONSTANT VARCHAR2(30)  := 'IRE';
g_rd_price                      CONSTANT VARCHAR2(30)  := 'PRE';
g_qte_ref_quote                 CONSTANT VARCHAR2(30)  := 'QUOTE';
--
g_aso_op_code_create 		CONSTANT VARCHAR2(30)  := 'CREATE';
g_aso_op_code_update 		CONSTANT VARCHAR2(30)  := 'UPDATE';
g_aso_op_code_delete 		CONSTANT VARCHAR2(30)  := 'DELETE';

--
g_okc_model_item  		CONSTANT VARCHAR2(30)  := 'TOP_MODEL_LINE';
g_okc_base_item  		CONSTANT VARCHAR2(30)  := 'TOP_BASE_LINE';
g_okc_config_item  		CONSTANT VARCHAR2(30)  := 'CONFIG';
g_okc_service_item  		CONSTANT VARCHAR2(30)  := 'SRV';

--
g_aso_model_item  		CONSTANT VARCHAR2(30)  := 'MDL';
g_aso_config_item  		CONSTANT VARCHAR2(30)  := 'CFG';
g_aso_service_item  		CONSTANT VARCHAR2(30)  := 'SRV';

--
-- Global variables
--

g_quote_id			OKX_QUOTE_HEADERS_V.ID1%TYPE;

l_contract_number          	okc_k_headers_b.contract_number%TYPE;
l_contract_number_modifier 	okc_k_headers_b.contract_number_modifier%TYPE;
l_quote_number             	okx_quote_headers_v.quote_number%TYPE;



--------------------------------------------------------------------------------
-- Procedure:       create_quote_from_k
-- Version:         1.0
-- Purpose:         Create a quote from a contract as the initial stage in
--                  the renewal process, or just as a new quote by
--                  "copying" the contract content into the quote.
--                  Create relationships from renewing contract to quote.
--                  May also create subject-to relationship from
--                  quote to master contract if renewing contract is
--                  subject to a master contract
--                  Calls ASO_QUOTE_PUB.CREATE_QUOTE to create the quote
-- In Parameters:   p_contract_id   Contract for which to create quote
--                  p_rel_type      Relationship type between K and Q
--                                  headers and lines
-- Out Parameters:  x_quote_id      Id of created quote
--
PROCEDURE create_quote_from_k( p_api_version     IN  NUMBER
                              ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
						--
                              ,p_contract_id     IN  okc_k_headers_b.id%TYPE
			      ,p_rel_type        IN  okc_k_rel_objs.rty_code%TYPE DEFAULT OKC_API.g_miss_char
						--
                              ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_quote_id        OUT NOCOPY okx_quote_headers_v.id1%TYPE
                              );

--------------------------------------------------------------------------------
-- Procedure:       update_quote_from_k
-- Version:         1.0
-- Purpose:         update a quote from a contract
--                  Calls ASO_QUOTE_PUB.UPDATE_QUOTE to create the quote
-- In Parameters:   p_contract_id   Contract for which to update quote
--                  p_quote_id      The id for the quote that is to be renewed
--
--
PROCEDURE update_quote_from_k( p_api_version     IN NUMBER
                              ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,p_quote_id        IN OKX_QUOTE_HEADERS_V.ID1%TYPE
                              ,p_contract_id     IN OKC_K_HEADERS_B.ID%TYPE
                              ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
                                                );

END OKC_OC_INT_KTQ_PVT;

 

/
