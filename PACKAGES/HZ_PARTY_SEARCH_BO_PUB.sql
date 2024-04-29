--------------------------------------------------------
--  DDL for Package HZ_PARTY_SEARCH_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_SEARCH_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHDBOSS.pls 120.0 2006/01/18 03:23:17 repuri noship $ */

   PROCEDURE find_party_bos (
      p_init_msg_list		IN	    VARCHAR2 := fnd_api.g_false,
      p_within_os               IN          VARCHAR2,
      p_rule_id                 IN          NUMBER,
      p_search_attr_obj         IN          HZ_SEARCH_ATTR_OBJ_TBL,
      p_party_status            IN          VARCHAR2,
      p_restrict_sql            IN          VARCHAR2,
      p_match_type              IN          VARCHAR2,
      x_search_results_obj      OUT NOCOPY  HZ_MATCHED_PARTY_OBJ_TBL,
      x_return_status		OUT NOCOPY  VARCHAR2,
      x_msg_count		OUT NOCOPY  NUMBER,
      x_msg_data		OUT NOCOPY  VARCHAR2
);

END HZ_PARTY_SEARCH_BO_PUB; -- Package spec

 

/
