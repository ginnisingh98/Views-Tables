--------------------------------------------------------
--  DDL for Package Body RG_CONTENT_OVERRIDES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_CONTENT_OVERRIDES_PKG" AS
/* $Header: rgircnob.pls 120.1 2003/04/29 01:29:15 djogg ship $ */
-- Name
--   rg_content_overrides_pkg
-- Purpose
--   to include all sever side procedures and packages for table
--   rg_report_content_overrides
-- Notes
--
-- History
--   03/23/93	A Chen	Created
--
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(X_rowid VARCHAR2,
                         X_override_seq NUMBER,
                         X_content_set_id NUMBER) IS
     dummy   NUMBER;
  BEGIN
     select 1 into dummy from dual
     where not exists
       (select 1 from rg_report_content_overrides
        where override_seq = X_override_seq
          and content_set_id = X_content_set_id
          and ((x_rowid IS NULL) OR (rowid <> x_rowid)));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fnd_message.set_name('RG','RG_FORMS_DUP_OBJECT_SEQUENCES');
         fnd_message.set_token('OBJECT','RG_CONTENT_SET',TRUE);
         app_exception.raise_exception;
  END check_unique;

END RG_CONTENT_OVERRIDES_PKG;

/
