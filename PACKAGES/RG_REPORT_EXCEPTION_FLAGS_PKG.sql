--------------------------------------------------------
--  DDL for Package RG_REPORT_EXCEPTION_FLAGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_EXCEPTION_FLAGS_PKG" AUTHID CURRENT_USER AS
-- $Header: rgirxnfs.pls 120.1 2003/04/29 01:29:40 djogg ship $
--
-- Name
--   rg_report_exception_flags_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_exception_flags
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   get_nextval
-- Purpose
--   Retrieves next value for axis_set_id from
--   rg_report_exception_flags_s
-- Arguments
--   None.
--
FUNCTION get_nextval RETURN NUMBER;

-- Name
--   delete_rows
-- Purpose
--   delete exception_flag from a row or a column
-- Arguments
--   axis_set_id
--   axis_seq
--
PROCEDURE delete_rows(X_axis_set_id NUMBER,
                      X_axis_seq NUMBER);

END RG_REPORT_EXCEPTION_FLAGS_PKG;

 

/
