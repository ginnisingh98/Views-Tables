--------------------------------------------------------
--  DDL for Package OZF_CHECK_DUP_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CHECK_DUP_PROD_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcdps.pls 120.1 2005/10/02 00:53 julou noship $ */

--------------------------------------------------------------------
-- PROCEDURE
--    denorm_products
--
-- PURPOSE
--    Refreshes volume offerproduct denorm table ozf_vo_products_temp.
--
-- PARAMETERS
--    p_offer_d: identifier of the offer
--
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment
----------------------------------------------------------------------
PROCEDURE denorm_vo_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2,
  p_commit           IN  VARCHAR2,
  p_offer_id         IN  NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_product_stmt     OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--   check_dup_prod
--
-- PURPOSE
--   check duplicate products upon volume offer activation.
--
-- PARAMETERS
--    p_offer_d: identifier of the offer
--
-- DESCRIPTION
--  This procedure calls denorm_products to builds SQL statment and denorm volume offer products
----------------------------------------------------------------------
PROCEDURE check_dup_prod(
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  p_offer_id      IN  NUMBER
);

END OZF_CHECK_DUP_PROD_PVT;

 

/
