--------------------------------------------------------
--  DDL for Package HR_SECURITY_PAYROLLS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_PAYROLLS_BK1" AUTHID CURRENT_USER as
/* $Header: hrsprapi.pkh 120.3.12010000.1 2008/07/28 03:49:03 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_pay_security_payroll_b>-----------------|
-- ----------------------------------------------------------------------------
--
procedure  create_pay_security_payroll_b
  (p_effective_date                 in     date
  ,p_security_profile_id            in     number
  ,p_payroll_id                     in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pay_security_payroll_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pay_security_payroll_a
  (p_effective_date                 in     date
  ,p_security_profile_id            in     number
  ,p_payroll_id                     in     number
  ,p_object_version_number          in    number
  );

--
 end hr_security_payrolls_bk1;
--

/
