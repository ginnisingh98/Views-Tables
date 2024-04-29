--------------------------------------------------------
--  DDL for Package Body HR_DE_EXTRA_ASSIGNMENT_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_EXTRA_ASSIGNMENT_CHECKS" AS
  /* $Header: pedeasgv.pkb 120.1.12010000.3 2009/03/18 11:11:42 parusia ship $ */
  --
  --
  -- Service functions to return TRUE if the value passed has been changed.
  --
  FUNCTION val_changed(p_value IN NUMBER) RETURN BOOLEAN IS
  BEGIN RETURN (NVL(p_value, 1) <> hr_api.g_number); END val_changed;
  --
  FUNCTION val_changed(p_value IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN RETURN (NVL(p_value, 'a') <> hr_api.g_varchar2); END val_changed;
  --
  FUNCTION val_changed(p_value IN DATE) RETURN BOOLEAN IS
  BEGIN RETURN (NVL(p_value, sysdate) <> hr_api.g_date); END val_changed;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Assignment checks.
  --
  -- 1. Union Membership cannot be recorded.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE assignment_checks
  (p_labour_union_member_flag IN VARCHAR2) IS
  BEGIN
    --
    --
    -- Check if DE is installed
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

    -- Check that the union member flag has not been set.
    --
    If val_changed(p_labour_union_member_flag) AND p_labour_union_member_flag IS NOT NULL THEN
      hr_utility.set_message(800, 'HR_DE_INVALID_UNION_FLAG');
      hr_utility.raise_error;
    END IF;

    END IF;
  END assignment_checks;

  PROCEDURE set_labour_union_flag
  (p_labour_union_member_flag IN OUT NOCOPY VARCHAR2) IS
  BEGIN
    -- It is not required with a German commercial HR system to record an
    -- individuals membership of a union. In Germany union membership and
    -- any associated dues are dealt with outside of any HRMS system to
    -- prevent companies from discriminating against employees who are union members
    -- Hence returning null for Labour_union_member_flag for germany.

    p_labour_union_member_flag := null ;

  END set_labour_union_flag ;

END hr_de_extra_assignment_checks;

/
