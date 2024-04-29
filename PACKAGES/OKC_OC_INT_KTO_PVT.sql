--------------------------------------------------------
--  DDL for Package OKC_OC_INT_KTO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_OC_INT_KTO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRKTOS.pls 120.0 2005/05/25 18:42:22 appldev noship $ */

g_rlt_typ_oh              	CONSTANT VARCHAR2(30)  := 'OKX_ORDERHEAD';
g_rlt_typ_qh              	CONSTANT VARCHAR2(30)  := 'OKX_QUOTEHEAD';
g_rlt_cod_osk             	CONSTANT VARCHAR2(30)  := 'ORDERSHIPSCONTRACT';
g_rlt_cod_kfo             	CONSTANT VARCHAR2(30)  := 'CONTRACTFORORDER';
g_rlt_cod_ktq             	CONSTANT VARCHAR2(30)  := 'CONTRACTISTERMSOFQUOTE';
g_rlt_cod_knq             	CONSTANT VARCHAR2(30)  := 'CONTRACTNEGOTIATESQUOTE';
g_rlt_type_osc            	CONSTANT VARCHAR2(30)  := 'COREORDERSSERVICECONTRACT'; -- K(service)-K(sales) relationship
g_rlt_typ_ql              	CONSTANT VARCHAR2(30)  := 'OKX_QUOTELINE';
g_rlt_typ_ol              	CONSTANT VARCHAR2(30)  := 'OKX_ORDERLINE';
g_aso_op_code_create	  	CONSTANT VARCHAR2(30)  := 'CREATE';
g_okc_model_item            CONSTANT VARCHAR2(30)  := 'TOP_MODEL_LINE';
g_okc_base_item             CONSTANT VARCHAR2(30)  := 'TOP_BASE_LINE';
g_okc_config_item           CONSTANT VARCHAR2(30)  := 'CONFIG';
g_okc_service_item          CONSTANT VARCHAR2(30)  := 'SRV';
g_aso_model_item            CONSTANT VARCHAR2(30)  := 'MDL';
g_aso_config_item           CONSTANT VARCHAR2(30)  := 'CFG';
g_aso_service_item          CONSTANT VARCHAR2(30)  := 'SRV';
--
-- Global variables
--
l_contract_number          	okc_k_headers_b.contract_number%TYPE;
l_contract_number_modifier 	okc_k_headers_b.contract_number_modifier%TYPE;
l_order_number             	okx_order_headers_v.order_number%TYPE;


-------------------------------------------------------------------------------
-- Procedure:       create_order_from_k
-- Version:         1.0
-- Purpose:         Create an order from a contract by populating quote
--                  input records from a contract as the initial
--                  stage.
--                  Provides process 2.1 in data flow diagram in HLD.
--                  Create Relationships from ordering contract to order
--                  May also create subject-to relationship from order
--                  to master contract if ordering contract is subject
--                  to a master contract
--                  Calls ASO_ORDER_INT.CREATE_ORDER to create the order
--
-- In Parameters:   p_contract_id   Contract for which to create order
--                  p_rel_type      Relationship type used to decide on
--                                  which kind of order to create
-- Out Parameters:  x_order_id      Id of created order
--

PROCEDURE create_order_from_k( p_api_version     IN  NUMBER
                              ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
			   --
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
			      ,p_rel_type        IN  okc_k_rel_objs.rty_code%TYPE DEFAULT OKC_API.g_miss_char
			   --
			      ,p_trace_mode      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
						);

-- ---------------------------------------------------------------------------
-- Procedure:       create_k_relationships
-- Version:         1.0
-- Purpose:         1. Creates a relationship between the related sales
--                     contract and the new order.
--                     This is done at the header and line levels.
--                  2. Create the relationships between the related sales
--                     contract and the new service contract (created from
--                     the original order).
--                     This is done at the header and line levels.
--
-- In Parameters:   p_api_version         API version (to be initialized to 1)
--                  p_init_msg_list       Flag to reset the error message stack
--                  p_sales_contract_id   Sales Contract header id as
--                                        created from Quote header id
--                  p_service_contract_id Service Contract header id as
--                                        created from Order header id
--                  p_quote_id            Quote header id
--                  p_quote_line_tab      Quote line ids  (PL/SQL table)
--                  p_order_id            Order header id as created from
--                                        Quote header id
--                  p_order_line_tab      Order line ids  (PL/SQL table)
--
-- Out Parameters:  x_return_status       Final status of the O-K relationship
--                                        creation API:
--                                        OKC_API.G_RET_STS_SUCCESS
--                                        OKC_API.G_RET_STS_ERROR
--                                        OKC_API.G_RET_STS_UNEXP_ERROR

PROCEDURE create_k_relationships(p_api_version        IN  NUMBER DEFAULT OKC_API.G_MISS_NUM
                                ,p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                                ,p_sales_contract_id  IN  OKC_K_HEADERS_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM
                                ,p_service_contract_id IN OKC_K_HEADERS_B.ID%TYPE DEFAULT OKC_API.G_MISS_NUM
                                ,p_quote_id           IN  OKX_QUOTE_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM
                                ,p_quote_line_tab     IN  OKC_OC_INT_PUB.OKC_QUOTE_LINE_TAB DEFAULT OKC_OC_INT_PUB.G_MISS_QL_TAB
                                ,p_order_id           IN  OKX_ORDER_HEADERS_V.ID1%TYPE DEFAULT OKC_API.G_MISS_NUM
                                ,p_order_line_tab     IN  OKC_OC_INT_PUB.OKC_ORDER_LINE_TAB DEFAULT OKC_OC_INT_PUB.G_MISS_OL_TAB
                                ,x_return_status      OUT NOCOPY VARCHAR2
                                ,x_msg_count          OUT NOCOPY NUMBER
                                ,x_msg_data           OUT NOCOPY VARCHAR2
);
END OKC_OC_INT_KTO_PVT;

 

/
