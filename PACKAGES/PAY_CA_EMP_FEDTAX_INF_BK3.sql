--------------------------------------------------------
--  DDL for Package PAY_CA_EMP_FEDTAX_INF_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EMP_FEDTAX_INF_BK3" AUTHID CURRENT_USER as
/* $Header: pycatapi.pkh 120.1.12010000.1 2008/07/27 22:17:49 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ca_emp_fedtax_inf_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_emp_fedtax_inf_b
  (
   p_emp_fed_tax_inf_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ca_emp_fedtax_inf_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ca_emp_fedtax_inf_a
  (
   p_emp_fed_tax_inf_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end pay_ca_emp_fedtax_inf_bk3;

/
