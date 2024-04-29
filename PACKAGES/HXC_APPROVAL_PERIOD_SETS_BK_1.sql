--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_PERIOD_SETS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_PERIOD_SETS_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcaprpsapi.pkh 120.0 2005/05/29 06:12:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_approval_period_sets_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_period_sets_b
  (p_approval_period_set_id        in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
--  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_approval_period_sets_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_period_sets_a
  (p_approval_period_set_id        in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
--  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_period_sets_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_period_sets_b
  (p_approval_period_set_id        in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
 -- ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_period_sets_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_period_sets_a
  (p_approval_period_set_id        in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  --,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_period_sets_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_period_sets_b
  (p_approval_period_set_id         in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_period_sets_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_period_sets_a
  (p_approval_period_set_id         in  number
  ,p_object_version_number          in  number
  );
--
end hxc_approval_period_sets_bk_1;

 

/
