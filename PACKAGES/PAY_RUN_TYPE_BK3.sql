--------------------------------------------------------
--  DDL for Package PAY_RUN_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RUN_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: pyprtapi.pkh 120.1 2005/10/02 02:33:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_run_type_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_run_type_b
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_id                   in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_run_type_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_run_type_a
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_id                   in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_run_type_bk3;

 

/
