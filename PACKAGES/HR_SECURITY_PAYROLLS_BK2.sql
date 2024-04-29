--------------------------------------------------------
--  DDL for Package HR_SECURITY_PAYROLLS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_PAYROLLS_BK2" AUTHID CURRENT_USER as
/* $Header: hrsprapi.pkh 120.3.12010000.1 2008/07/28 03:49:03 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<delete_pay_security_payroll_b>-----------------|
-- ----------------------------------------------------------------------------
--
procedure  delete_pay_security_payroll_b
  (p_security_profile_id            in     number
  ,p_payroll_id                     in     number
  );
--
--
-- --------------------------------------------------------------------------
-- |----------------------< delete_pay_security_payroll_a >----------------|
-- --------------------------------------------------------------------------
--
procedure delete_pay_security_payroll_a
  (p_security_profile_id            in     number
  ,p_payroll_id                     in     number
  ,p_object_version_number          in    number
  );

--
end hr_security_payrolls_bk2;
--

/
