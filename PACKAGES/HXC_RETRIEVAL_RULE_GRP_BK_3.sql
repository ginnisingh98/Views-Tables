--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULE_GRP_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULE_GRP_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcrrgapi.pkh 120.0 2005/05/29 05:50:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------< delete_retrieval_rule_grp_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rule_grp_b
  (p_retrieval_rule_grp_id       in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------< delete_retrieval_rule_grp_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rule_grp_a
  (p_retrieval_rule_grp_id       in  number
  ,p_object_version_number          in  number
  );
--
end hxc_retrieval_rule_grp_bk_3;

 

/
