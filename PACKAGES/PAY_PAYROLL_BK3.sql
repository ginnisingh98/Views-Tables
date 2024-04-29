--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_BK3" AUTHID CURRENT_USER as
/* $Header: pyprlapi.pkh 120.13 2007/11/20 06:17:36 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_payroll_b >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_payroll_b
(  p_effective_date               in     date,
   p_datetrack_mode               in     varchar2,
   p_payroll_id                   in     number,
   p_object_version_number        in     number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_payroll_a >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_payroll_a
  (p_effective_date               in     date,
   p_datetrack_mode               in     varchar2,
   p_payroll_id                   in     number,
   p_object_version_number        in     number,
   p_effective_start_date         in     date,
   p_effective_end_date           in     date
  );

  end pay_payroll_bk3;


/
