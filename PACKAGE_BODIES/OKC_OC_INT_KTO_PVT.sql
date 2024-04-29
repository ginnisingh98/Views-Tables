--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_KTO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_KTO_PVT" AS
/* $Header: OKCRKTOB.pls 120.1 2005/10/04 20:00:08 smallya noship $ */

-- Tables to hold bill to and ship to information at the header level
--

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
--                  Calls ASO_ORDER_PUB.CREATE_ORDER to create the order
-- In Parameters:   p_contract_id   Contract for which to create order
--                  p_rel_type      Relationship type used to decide on
--                                  which kind of order to create
-- Out Parameters:  x_order_id      Id of created order
--
PROCEDURE create_order_from_k(
                   p_api_version     IN NUMBER
			      ,p_init_msg_list   IN VARCHAR2
			      ,x_return_status   OUT NOCOPY VARCHAR2
			      ,x_msg_count       OUT NOCOPY NUMBER
			      ,x_msg_data        OUT NOCOPY VARCHAR2
						--
			      ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
			      ,p_rel_type        IN  okc_k_rel_objs.rty_code%TYPE
						--
				  ,p_trace_mode      IN  VARCHAR2
			      ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
						)
			      IS
BEGIN
  NULL;
END create_order_from_k;


--
-- Create new procedure to create relationships
--
PROCEDURE create_k_relationships(p_api_version        IN  NUMBER
			       ,p_init_msg_list      IN  VARCHAR2
			       ,p_sales_contract_id  IN  OKC_K_HEADERS_B.ID%TYPE
			       ,p_service_contract_id IN OKC_K_HEADERS_B.ID%TYPE
			       ,p_quote_id           IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
			       ,p_quote_line_tab     IN  OKC_OC_INT_PUB.OKC_QUOTE_LINE_TAB
			       ,p_order_id           IN  OKX_ORDER_HEADERS_V.ID1%TYPE
			       ,p_order_line_tab     IN  OKC_OC_INT_PUB.OKC_ORDER_LINE_TAB
                   ,x_return_status      OUT NOCOPY VARCHAR2
                   ,x_msg_count          OUT NOCOPY NUMBER
                   ,x_msg_data           OUT NOCOPY VARCHAR2
) IS

BEGIN
  NULL;
END;

END OKC_OC_INT_KTO_PVT;

/
