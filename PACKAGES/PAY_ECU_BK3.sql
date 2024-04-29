--------------------------------------------------------
--  DDL for Package PAY_ECU_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ECU_BK3" AUTHID CURRENT_USER as
/* $Header: pyecuapi.pkh 120.2 2005/12/12 23:31:49 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_ELE_CLASS_USAGES_B >----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELE_CLASS_USAGES_B
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_element_class_usage_id        in     number
  ,p_object_version_number         in     number
   );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_ELE_CLASS_USAGES_A >----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELE_CLASS_USAGES_A
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_element_class_usage_id        in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end PAY_ECU_BK3;

 

/
