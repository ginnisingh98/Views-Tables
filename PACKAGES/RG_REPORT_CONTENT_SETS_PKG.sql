--------------------------------------------------------
--  DDL for Package RG_REPORT_CONTENT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_CONTENT_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgircnss.pls 120.2 2002/11/14 03:00:43 djogg ship $ */
--
-- Name
--   rg_report_content_sets_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_content_sets
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   select_row
-- Purpose
--   querying a row
-- Arguments
--   recinfo        record inforation
--
PROCEDURE select_row(recinfo in out NOCOPY rg_report_content_sets%ROWTYPE);

-- Name
--   select_columns
-- Purpose
--   querying columns from a row for populating non-database fields
--   in POST-QUERY
-- Arguments
--   recinfo        record inforation
PROCEDURE select_columns(X_content_set_id NUMBER, X_name IN OUT NOCOPY VARCHAR2);

-- Name
--   check_unique
-- Purpose
--   unique check for name
-- Arguments
--   name
--
PROCEDURE check_unique(X_rowid VARCHAR2,
                       X_name VARCHAR2,
                       X_application_id NUMBER);

-- Name
--   check_references
-- Purpose
--   Referential integrity check on rg_report_content_sets
-- Arguments
--   content_set_id
--
PROCEDURE check_references(X_content_set_id NUMBER);

-- Name
--   get_nextval
-- Purpose
--   Retrieves next value for content_set_id from
--   rg_report_content_sets_s
-- Arguments
--   None.
--
FUNCTION get_nextval RETURN NUMBER;

END RG_REPORT_CONTENT_SETS_PKG;

 

/
