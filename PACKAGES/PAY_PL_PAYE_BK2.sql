--------------------------------------------------------
--  DDL for Package PAY_PL_PAYE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_PAYE_BK2" AUTHID CURRENT_USER as
/* $Header: pyppdapi.pkh 120.4 2006/04/24 23:22:43 nprasath noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_paye_details_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_paye_details_b
  (p_effective_date                in     date
  ,p_paye_details_id                in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_tax_reduction				   in     varchar2
  ,p_tax_calc_with_spouse_child    in     varchar2
  ,p_income_reduction	           in     varchar2
  ,p_income_reduction_amount       in     number
  ,p_rate_of_tax			       in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_paye_details_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_paye_details_a
  (p_effective_date                in     date
  ,p_paye_details_id                in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_tax_reduction				   in     varchar2
  ,p_tax_calc_with_spouse_child    in     varchar2
  ,p_income_reduction	           in     varchar2
  ,p_income_reduction_amount       in     number
  ,p_rate_of_tax			       in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end PAY_PL_PAYE_BK2;

 

/
