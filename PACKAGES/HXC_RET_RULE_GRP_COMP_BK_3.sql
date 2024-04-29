--------------------------------------------------------
--  DDL for Package HXC_RET_RULE_GRP_COMP_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RET_RULE_GRP_COMP_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcrrcapi.pkh 120.0 2005/05/29 05:50:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ret_rule_grp_comp_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ret_rule_grp_comp_b
  (p_ret_rule_grp_comp_id in  number
  ,p_object_version_number         in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ret_rule_grp_comp_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ret_rule_grp_comp_a
  (p_ret_rule_grp_comp_id      in  number
  ,p_object_version_number         in  number
  );
--
end hxc_ret_rule_grp_comp_bk_3;

 

/
