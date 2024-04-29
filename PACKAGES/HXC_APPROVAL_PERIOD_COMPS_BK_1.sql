--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_PERIOD_COMPS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_PERIOD_COMPS_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcapcapi.pkh 120.0 2005/05/29 05:24:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_approval_period_comps_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_period_comps_b
  (p_approval_period_comp_id       in     number
  ,p_object_version_number         in     number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_approval_period_comps_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_period_comps_a
  (p_approval_period_comp_id       in     number
  ,p_object_version_number         in     number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_period_comps_b >---------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_period_comps_b
  (p_approval_period_comp_id       in     number
  ,p_object_version_number         in     number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_period_comps_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_period_comps_a
  (p_approval_period_comp_id       in     number
  ,p_object_version_number         in     number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_period_comps_b >---------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_period_comps_b
  (p_approval_period_comp_id        in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_period_comps_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_period_comps_a
  (p_approval_period_comp_id        in  number
  ,p_object_version_number          in  number
  );
--
end hxc_approval_period_comps_bk_1;

 

/
