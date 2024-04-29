--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPE_USAGE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPE_USAGE_BK2" AUTHID CURRENT_USER as
/* $Header: pyetuapi.pkh 120.1 2005/10/02 02:30:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_element_type_usage_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_type_usage_b
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_inclusion_flag		   in     varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_usage_type			   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_element_type_usage_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_type_usage_a
  (p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_inclusion_flag		   in     varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_usage_type			   in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_element_type_usage_bk2;

 

/
