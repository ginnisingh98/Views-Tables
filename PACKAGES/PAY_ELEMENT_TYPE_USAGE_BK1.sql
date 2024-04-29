--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPE_USAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPE_USAGE_BK1" AUTHID CURRENT_USER as
/* $Header: pyetuapi.pkh 120.1 2005/10/02 02:30:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_element_type_usage_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_type_usage_b
  (p_effective_date                in     date
  ,p_run_type_id                   in     number
  ,p_element_type_id               in     number
  ,p_inclusion_flag		   in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_usage_type			   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_element_type_usage_a --------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_type_usage_a
  (p_effective_date                in     date
  ,p_run_type_id                   in     number
  ,p_element_type_id               in     number
  ,p_inclusion_flag		   in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_usage_type			   in     varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_element_type_usage_bk1;

 

/
