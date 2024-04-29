--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULE_GRP_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULE_GRP_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcrrgapi.pkh 120.0 2005/05/29 05:50:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------< create_retrieval_rule_grp_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rule_grp_b
  (p_retrieval_rule_grp_id       in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------< create_retrieval_rule_grp_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rule_grp_a
  (p_retrieval_rule_grp_id       in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
end hxc_retrieval_rule_grp_bk_1;

 

/
