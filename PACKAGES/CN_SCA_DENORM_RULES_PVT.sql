--------------------------------------------------------
--  DDL for Package CN_SCA_DENORM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_DENORM_RULES_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvscads.pls 120.4 2005/12/30 02:21:23 raramasa noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--  CN_SCA_DENORM_RULES_PVT
-- Purpose
--   This package is a public API for processing Credit Rules and associated
--   allocation percentages.
-- History
--   06/26/03   Rao.Chenna         Created
--
   --
   G_PKG_NAME   CONSTANT VARCHAR2(30) := 'CN_SCA_DENORM_RULES_PVT';
   g_cn_debug          	 VARCHAR2(1) := fnd_profile.value('CN_DEBUG');
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
   PROCEDURE populate_rule_denorm (
	errbuf         		OUT NOCOPY 	VARCHAR2,
	retcode        		OUT NOCOPY 	NUMBER,
   	p_txn_src		IN		VARCHAR2);

END; -- Package spec

 

/
