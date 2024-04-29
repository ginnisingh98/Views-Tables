--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_COMPS_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_COMPS_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchacapi.pkh 120.1 2006/06/08 15:54:21 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_approval_comps_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_comps_b
  (p_approval_comp_id              in     number
  ,p_object_version_number         in     number
  ,p_approval_mechanism            in     varchar2
  ,p_approval_style_id             in     number
  ,p_time_recipient_id             in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_approval_mechanism_id         in     number
  ,p_approval_order                in     number
  ,p_wf_item_type                  in     varchar2
  ,p_wf_name                       in     varchar2
  ,p_effective_date                in     date
  ,p_time_category_id              in     number
  ,p_parent_comp_id                in     number
  ,p_parent_comp_ovn               in     number
  ,p_run_recipient_extensions      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_approval_comps_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_comps_a
  (p_approval_comp_id              in     number
  ,p_object_version_number         in     number
  ,p_approval_mechanism            in     varchar2
  ,p_approval_style_id             in     number
  ,p_time_recipient_id             in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_approval_mechanism_id         in     number
  ,p_approval_order                in     number
  ,p_wf_item_type                  in     varchar2
  ,p_wf_name                       in     varchar2
  ,p_effective_date                in     date
  ,p_time_category_id              in     number
  ,p_parent_comp_id                in     number
  ,p_parent_comp_ovn               in     number
  ,p_run_recipient_extensions      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_comps_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_comps_b
  (p_approval_comp_id              in     number
  ,p_object_version_number         in     number
  ,p_approval_mechanism            in     varchar2
  ,p_approval_style_id             in     number
  ,p_time_recipient_id             in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_approval_mechanism_id         in     number
  ,p_approval_order                in     number
  ,p_wf_item_type                  in     varchar2
  ,p_wf_name                       in     varchar2
  ,p_effective_date                in     date
  ,p_time_category_id              in     number
  ,p_parent_comp_id                in     number
  ,p_parent_comp_ovn               in     number
  ,p_run_recipient_extensions      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_comps_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_comps_a
  (p_approval_comp_id              in     number
  ,p_object_version_number         in     number
  ,p_approval_mechanism            in     varchar2
  ,p_approval_style_id             in     number
  ,p_time_recipient_id             in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_approval_mechanism_id         in     number
  ,p_approval_order                in     number
  ,p_wf_item_type                  in     varchar2
  ,p_wf_name                       in     varchar2
  ,p_effective_date                in     date
  ,p_time_category_id              in     number
  ,p_parent_comp_id                in     number
  ,p_parent_comp_ovn               in     number
  ,p_run_recipient_extensions      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_comps_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_comps_b
  (p_approval_comp_id               in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_comps_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_comps_a
  (p_approval_comp_id               in  number
  ,p_object_version_number          in  number
  );
--
end hxc_approval_comps_bk_1;


 

/
