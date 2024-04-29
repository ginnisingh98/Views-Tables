--------------------------------------------------------
--  DDL for Package PAY_BALANCE_CATEGORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_CATEGORY_BK3" AUTHID CURRENT_USER as
/* $Header: pypbcapi.pkh 120.2 2005/10/22 01:25:41 aroussel noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_balance_category_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_category_b
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_balance_category_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_category_a
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_balance_category_id           in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end pay_balance_category_bk3;

 

/
