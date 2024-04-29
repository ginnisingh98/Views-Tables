--------------------------------------------------------
--  DDL for Package PER_BF_PAYROLL_RUNS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PAYROLL_RUNS_BK3" AUTHID CURRENT_USER as
/* $Header: pebprapi.pkh 120.1 2005/10/02 02:12:27 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <delete_payroll_run_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_payroll_run_b
  (
   p_payroll_run_id                in number
  ,p_object_version_number         in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <delete_payroll_run_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_payroll_run_a
  (
   p_payroll_run_id                in     number
  ,p_object_version_number         in     number
  );
--
end PER_BF_PAYROLL_RUNS_BK3;

 

/
