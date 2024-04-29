--------------------------------------------------------
--  DDL for Package OZF_ACTIVITY_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTIVITY_DENORM_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvacds.pls 120.2 2006/03/30 13:38:05 gramanat noship $ */

TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE char_tbl_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

PROCEDURE prepare_customer_full_load;

PROCEDURE prepare_product_full_load;

PROCEDURE create_customer_indexes;

PROCEDURE create_product_indexes;

PROCEDURE refresh_denorm(
  ERRBUF             OUT NOCOPY VARCHAR2,
  RETCODE            OUT NOCOPY VARCHAR2,
  p_increment_flag   IN VARCHAR2 := 'N',
  p_offer_id         IN  NUMBER
);

END OZF_ACTIVITY_DENORM_PVT;

 

/
