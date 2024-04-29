--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULE_COMPS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULE_COMPS_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcrtcapi.pkh 120.0 2005/05/29 05:51:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_retrieval_rule_comps_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rule_comps_b
  (p_retrieval_rule_comp_id        in     number
  ,p_object_version_number         in     number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_retrieval_rule_comps_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rule_comps_a
  (p_retrieval_rule_comp_id        in     number
  ,p_object_version_number         in     number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retrieval_rule_comps_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rule_comps_b
  (p_retrieval_rule_comp_id        in     number
  ,p_object_version_number         in     number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retrieval_rule_comps_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rule_comps_a
  (p_retrieval_rule_comp_id        in     number
  ,p_object_version_number         in     number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retrieval_rule_comps_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rule_comps_b
  (p_retrieval_rule_comp_id         in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retrieval_rule_comps_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rule_comps_a
  (p_retrieval_rule_comp_id         in  number
  ,p_object_version_number          in  number
  );
--
end hxc_retrieval_rule_comps_bk_1;

 

/
