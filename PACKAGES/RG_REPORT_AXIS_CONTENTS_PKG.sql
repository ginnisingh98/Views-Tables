--------------------------------------------------------
--  DDL for Package RG_REPORT_AXIS_CONTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_AXIS_CONTENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgiracns.pls 120.1 2003/04/29 01:29:11 djogg ship $ */
--
-- Name
--   RG_REPORT_AXIS_CONTENTS_PKG
-- Purpose
--   to include all sever side procedures and packages for table
--   RG_REPORT_AXIS_CONTENTS
-- Notes
--
-- History
--   11/01/93	A Chen	Created
--
--
-- Procedures

-- Name
--   check_existence
-- Purpose
--   Check whether a axis has flex defined.
-- Arguments
--   axis_set_id
--   axis_seq
--
FUNCTION check_existence(X_axis_set_id NUMBER,
                         X_axis_seq NUMBER) RETURN BOOLEAN;

-- Name
--   delete_rows
-- Purpose
--   delete all flexfield assignments from a row or a column
-- Arguments
--   axis_set_id
--   axis_seq
--
PROCEDURE delete_rows(X_axis_set_id NUMBER,
                      X_axis_seq NUMBER);

END RG_REPORT_AXIS_CONTENTS_PKG;

 

/
