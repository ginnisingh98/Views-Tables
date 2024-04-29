--------------------------------------------------------
--  DDL for Package HR_SALARY_BASIS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_BASIS_BK3" AUTHID CURRENT_USER as
/* $Header: peppbapi.pkh 120.1 2005/10/02 02:21:58 aroussel $ */
-- ----------------------------------------------------------------------------
-- |------------------------< delete_salary_basis_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_basis_b
  (p_validate                      in     boolean
  ,p_pay_basis_id                  in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_salary_basis_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_basis_a
  (p_validate                      in     boolean
  ,p_pay_basis_id                  in     number
  ,p_object_version_number         in     number
  );
end hr_salary_basis_bk3;

 

/
