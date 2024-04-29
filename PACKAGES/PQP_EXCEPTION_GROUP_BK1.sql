--------------------------------------------------------
--  DDL for Package PQP_EXCEPTION_GROUP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXCEPTION_GROUP_BK1" AUTHID CURRENT_USER as
/* $Header: pqergapi.pkh 120.0 2005/05/29 01:45:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_exception_group_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_exception_group_b
  (p_exception_report_id            in     number
  ,p_exception_group_name           in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_business_group_id              in     number
  ,p_consolidation_set_id           in     number
  ,p_payroll_id                     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< create_exception_group_a >   ------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_exception_group_a
  (p_exception_report_id            in     number
  ,p_exception_group_name           in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_business_group_id              in     number
  ,p_consolidation_set_id           in     number
  ,p_payroll_id                     in     number
  ,p_exception_group_id             in     number
  ,p_object_version_number          in     number
  );
--
end pqp_exception_group_bk1;

 

/
