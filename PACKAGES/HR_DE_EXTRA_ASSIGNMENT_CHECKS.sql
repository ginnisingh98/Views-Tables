--------------------------------------------------------
--  DDL for Package HR_DE_EXTRA_ASSIGNMENT_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_EXTRA_ASSIGNMENT_CHECKS" AUTHID CURRENT_USER AS
  /* $Header: pedeasgv.pkh 120.0.12010000.3 2009/03/18 11:10:43 parusia ship $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Assignment checks.
  --
  -- 1. Union Membership cannot be recorded.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE assignment_checks
  (p_labour_union_member_flag IN VARCHAR2);

  PROCEDURE set_labour_union_flag
  (p_labour_union_member_flag IN OUT NOCOPY VARCHAR2);
END hr_de_extra_assignment_checks;

/
