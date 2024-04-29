--------------------------------------------------------
--  DDL for Package PAY_COST_ALLOCATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COST_ALLOCATION_BK3" AUTHID CURRENT_USER as
/* $Header: pycalapi.pkh 120.2 2005/11/11 07:06:59 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cost_allocation_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cost_allocation_b
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_cost_allocation_id            in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_cost_allocation_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cost_allocation_a
  (p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_cost_allocation_id            in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end PAY_COST_ALLOCATION_BK3;

 

/
