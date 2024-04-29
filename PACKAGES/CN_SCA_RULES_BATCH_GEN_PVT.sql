--------------------------------------------------------
--  DDL for Package CN_SCA_RULES_BATCH_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_RULES_BATCH_GEN_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvscabs.pls 120.2 2005/09/15 15:45:58 rchenna noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_RULES_BATCH_GEN_PVT
-- Purpose
--   This package is a public API for processing Credit Rules and associated
--   allocation percentages.
-- History
--   06/26/03   Rao.Chenna         Created
--
--
   G_PKG_NAME	CONSTANT VARCHAR2(30) := 'CN_SCA_RULES_BATCH_GEN_PVT';
   --
   TYPE attr_prime_rec_type IS RECORD(
   	attribute_name		VARCHAR2(12),
	prime_number		NUMBER);
   TYPE attr_prime_tbl_type IS TABLE OF attr_prime_rec_type
   INDEX BY BINARY_INTEGER;
   --
   TYPE attr_operator_rec_type IS RECORD(
   	sca_rule_attribute_id	NUMBER,
	-- codeCheck: I need to check the length
	operator_id		VARCHAR2(30));
   TYPE attr_operator_tbl_type IS TABLE OF attr_operator_rec_type
   INDEX BY BINARY_INTEGER;
   --
   PROCEDURE gen_sca_rules_batch_dyn(
      	p_api_version           IN  NUMBER,
      	p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      	p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      	p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      	p_org_id	        IN  NUMBER,
      	x_return_status         OUT NOCOPY VARCHAR2,
      	x_msg_count             OUT NOCOPY NUMBER,
      	x_msg_data              OUT NOCOPY VARCHAR2,
      	x_transaction_source    IN  cn_sca_rule_attributes.transaction_source%TYPE);
   --
   PROCEDURE populate_matches (
   	spec_code        	IN OUT NOCOPY cn_utils.code_type,
        body_code        	IN OUT NOCOPY cn_utils.code_type ,
        x_transaction_source   	IN cn_sca_rule_attributes.transaction_source%TYPE);
   --
   FUNCTION create_sca_rules_batch_dyn (
   	x_transaction_source   	IN cn_sca_rule_attributes.transaction_source%TYPE)
   RETURN BOOLEAN ;
   --
END cn_sca_rules_batch_gen_pvt;
 

/
