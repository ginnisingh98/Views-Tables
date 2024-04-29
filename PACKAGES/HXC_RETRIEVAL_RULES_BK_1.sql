--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcrtrapi.pkh 120.0 2005/05/29 05:52:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_retrieval_rules_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rules_b
  (p_retrieval_rule_id             in     number
  ,p_object_version_number         in     number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_retrieval_rules_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rules_a
  (p_retrieval_rule_id             in     number
  ,p_object_version_number         in     number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retrieval_rules_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rules_b
  (p_retrieval_rule_id             in     number
  ,p_object_version_number         in     number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_retrieval_rules_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rules_a
  (p_retrieval_rule_id             in     number
  ,p_object_version_number         in     number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retrieval_rules_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rules_b
  (p_retrieval_rule_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_retrieval_rules_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rules_a
  (p_retrieval_rule_id              in  number
  ,p_object_version_number          in  number
  );
--
end hxc_retrieval_rules_bk_1;

 

/
