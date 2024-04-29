--------------------------------------------------------
--  DDL for Package Body HR_THIRD_PARTY_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_THIRD_PARTY_INTERFACE_PKG" AS
/* $Header: petpipkg.pkb 120.0 2005/05/31 22:16:14 appldev noship $ */
--
--
-----------------------------------------------------------------------
procedure set_extract_date (p_payroll_extract_date date)
------------------------------------------------------------------------
is
-- This procedure sets the g_payroll_extract_date variable to the given date.
--
begin
   g_payroll_extract_date := p_payroll_extract_date;
--
end set_extract_date;
--
-----------------------------------------------------------------------
function get_extract_date return date
------------------------------------------------------------------------
is
-- This function returns the g_payroll_extract_date set by the call to
-- set_payroll_extract_date. If set_payroll_extract_date is never called, it
-- returns the sysdate as g_payroll_extract_date is initialized to
-- sysdate.
--
begin
  --
  RETURN g_payroll_extract_date;
  --
end get_extract_date;
--
end HR_THIRD_PARTY_INTERFACE_PKG ;

/
