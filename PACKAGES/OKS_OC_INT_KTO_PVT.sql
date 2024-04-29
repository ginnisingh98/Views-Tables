--------------------------------------------------------
--  DDL for Package OKS_OC_INT_KTO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_OC_INT_KTO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRKTOS.pls 120.1 2006/02/08 04:28:24 gchadha noship $ */

g_rlt_typ_oh              	CONSTANT VARCHAR2(30)  := 'OKX_ORDERHEAD';
g_rlt_typ_qh              	CONSTANT VARCHAR2(30)  := 'OKX_QUOTEHEAD';
g_rlt_cod_osk             	CONSTANT VARCHAR2(30)  := 'ORDERSHIPSCONTRACT';
g_rlt_cod_kfo             	CONSTANT VARCHAR2(30)  := 'CONTRACTFORORDER';
g_rlt_typ_ql              	CONSTANT VARCHAR2(30)  := 'OKX_QUOTELINE';
g_rlt_typ_ol              	CONSTANT VARCHAR2(30)  := 'OKX_ORDERLINE';
g_aso_op_code_create	  	CONSTANT VARCHAR2(30)  := 'CREATE';
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
--                  Calls ASO_ORDER_INT.CREATE_ORDER to create the order
--
-- In Parameters:   p_contract_id   Contract for which to create order
-- Out Parameters:  x_order_id      Id of created order
--
PROCEDURE create_order_from_k(
                               p_api_version     IN  NUMBER
                              ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                               ,p_default_date    IN DATE  DEFAULT OKC_API.G_MISS_DATE
                              ,P_Customer_id     IN NUMBER
                              ,P_Grp_id          IN NUMBER
                              ,P_org_id          IN  NUMBER
	                      ,P_contract_hdr_id_lo IN NUMBER
                              ,P_contract_hdr_id_hi IN NUMBER
 	                      -- Bug 4915691 --
 	                      ,P_contract_line_id_lo in NUMBER
 	                      ,P_contract_line_id_hi in NUMBER
 	                      -- Bug 4915691 --
                              ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
						);
END OKS_OC_INT_KTO_PVT;

 

/
