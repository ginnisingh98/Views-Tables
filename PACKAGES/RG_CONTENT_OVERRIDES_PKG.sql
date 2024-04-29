--------------------------------------------------------
--  DDL for Package RG_CONTENT_OVERRIDES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_CONTENT_OVERRIDES_PKG" AUTHID CURRENT_USER AS
/* $Header: rgircnos.pls 120.1 2003/04/29 01:29:19 djogg ship $ */
--
-- Name
--   rg_content_overrides_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_content_overrides
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   check_unique
-- Purpose
--   unique check for name
-- Arguments
--   name
--
PROCEDURE check_unique(X_rowid VARCHAR2,
                       X_override_seq NUMBER,
                       X_content_set_id NUMBER);

END RG_CONTENT_OVERRIDES_PKG;

 

/
