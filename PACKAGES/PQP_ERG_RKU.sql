--------------------------------------------------------
--  DDL for Package PQP_ERG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERG_RKU" AUTHID CURRENT_USER as
/* $Header: pqergrhi.pkh 120.0 2005/05/29 01:45:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_exception_group_id           in number
  ,p_exception_group_name         in varchar2
  ,p_exception_report_id          in number
  ,p_legislation_code             in varchar2
  ,p_business_group_id            in number
  ,p_consolidation_set_id         in number
  ,p_payroll_id                   in number
  ,p_object_version_number        in number
  ,p_exception_group_name_o       in varchar2
  ,p_exception_report_id_o        in number
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  ,p_consolidation_set_id_o       in number
  ,p_payroll_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end pqp_erg_rku;

 

/
