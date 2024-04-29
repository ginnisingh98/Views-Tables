--------------------------------------------------------
--  DDL for Package Body RG_REPORT_EXCEPTION_FLAGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_EXCEPTION_FLAGS_PKG" AS
-- $Header: rgirxnfb.pls 120.1 2003/04/29 01:29:36 djogg ship $
-- Name
--   RG_REPORT_EXCEPTION_FLAGS_PKG
-- Purpose
--   to include all sever side procedures and packages for table
--   RG_REPORT_EXCEPTION_FLAGS
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
  FUNCTION get_nextval return number IS
    next_group_id  NUMBER;
  BEGIN
    select RG_REPORT_EXCEPTION_FLAGS_s.nextval
    into   next_group_id
    from   dual;

    RETURN (next_group_id);
  END get_nextval;

  PROCEDURE delete_rows(X_axis_set_id NUMBER,
                        X_axis_seq NUMBER) IS
  BEGIN
    IF (X_axis_seq = -1) THEN
      delete from rg_report_exceptions
      where axis_set_id = X_axis_set_id;

      delete from rg_report_exception_flags
       where axis_set_id = X_axis_set_id;
    ELSE
      delete from rg_report_exceptions
       where axis_set_id = X_axis_set_id
        and axis_seq = X_axis_seq;

      delete from rg_report_exception_flags
       where axis_set_id = X_axis_set_id
         and axis_seq = X_axis_seq;
    END IF;

  END delete_rows;

END RG_REPORT_EXCEPTION_FLAGS_PKG;

/
