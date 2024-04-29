--------------------------------------------------------
--  DDL for Package OKS_KTO_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_KTO_INT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPORDS.pls 120.1 2006/02/08 05:05:52 gchadha noship $ */



-------------------------------------------------------------------------------
--
-- APIs: K->O
--
-------------------------------------------------------------------------------

-- Procedure:       create_order_from_k
-- Version:         1.0
-- Purpose:         Create an order from a contract.
--                  The first one is planned to be called by a Conc. Prog.
--                  and calls itself the second one
--                  Calls ASO_ORDER_PUB.CREATE_ORDER to create the order
-- In Parameters:   p_contract_id   Contract for which to create order
-- Out Parameters:  x_order_id      Id of created order
--
-------------------------------------------------------------------------------

PROCEDURE create_order_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			       ,RETCODE             OUT NOCOPY  NUMBER
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                              ,p_default_date    IN DATE  DEFAULT OKC_API.G_MISS_DATE
                              ,P_Customer_id     IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_Grp_id          IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_org_id          IN  NUMBER DEFAULT OKC_API.G_MISS_NUM
			      ,P_contract_hdr_id_lo in NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_hdr_id_hi in NUMBER DEFAULT OKC_API.G_MISS_NUM
			      -- Bug 4915691 --
			      ,P_contract_line_id_lo in NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_line_id_hi in NUMBER DEFAULT OKC_API.G_MISS_NUM
                             -- Bug 4915691 --
                             );


PROCEDURE create_order_from_k(p_api_version     IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
                             ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,p_commit          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                              ,p_default_date    IN DATE  DEFAULT OKC_API.G_MISS_DATE
                              ,P_Customer_id     IN NUMBER    DEFAULT OKC_API.G_MISS_NUM
                              ,P_Grp_id          IN NUMBER    DEFAULT OKC_API.G_MISS_NUM
                              ,P_org_id          IN  NUMBER   DEFAULT OKC_API.G_MISS_NUM
			      ,P_contract_hdr_id_lo in NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_hdr_id_hi in NUMBER DEFAULT OKC_API.G_MISS_NUM
			      -- Bug 4915691 --
                              ,P_contract_line_id_lo in NUMBER DEFAULT OKC_API.G_MISS_NUM
                              ,P_contract_line_id_hi in NUMBER DEFAULT OKC_API.G_MISS_NUM

			      -- Bug 4915691 --

                              ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
                             );

END OKS_KTO_INT_PUB;



 

/
