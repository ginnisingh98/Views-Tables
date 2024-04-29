--------------------------------------------------------
--  DDL for Package Body RG_REPORT_CONTENT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_CONTENT_SETS_PKG" AS
/* $Header: rgircnsb.pls 120.2 2002/11/14 03:00:34 djogg ship $ */
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
-- PRIVATE VARIABLES
--   None.
--
-- PRIVATE FUNCTIONS
--   None.
--
-- PUBLIC FUNCTIONS
--
  PROCEDURE select_row(recinfo IN OUT NOCOPY rg_report_content_sets%ROWTYPE) IS
  BEGIN
    select * INTO recinfo
    from rg_report_content_sets
    where content_set_id = recinfo.content_set_id;
  END select_row;

  PROCEDURE select_columns(X_content_set_id NUMBER,
                           X_name IN OUT NOCOPY VARCHAR2) IS
    recinfo rg_report_content_sets%ROWTYPE;
  BEGIN
    recinfo.content_set_id := X_content_set_id;
    select_row(recinfo);
    X_name := recinfo.name;
  END select_columns;

  PROCEDURE check_unique(X_rowid VARCHAR2,
                         X_name VARCHAR2,
                         X_application_id NUMBER) IS
     dummy   NUMBER;
  BEGIN
     select 1 into dummy from dual
     where not exists
       (select 1 from rg_report_content_sets
        where name = X_name
          and application_id = X_application_id
          and ((X_rowid IS NULL) OR (rowid <> X_rowid)));
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         fnd_message.set_name('RG','RG_FORMS_OBJECT_EXISTS');
         fnd_message.set_token('OBJECT','RG_CONTENT_SET',TRUE);
         app_exception.raise_exception;
  END check_unique;

  PROCEDURE check_references(X_content_set_id NUMBER) IS
    object_name  VARCHAR2(80);
    dummy        NUMBER;
  BEGIN
    select 1 into dummy from dual
    where not exists
      (select 1 from rg_reports
       where  content_set_id = X_content_set_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('RG','RG_FORMS_REF_OBJECT');
        fnd_message.set_token('OBJECT','RG_CONTENT_SET',TRUE);
        app_exception.raise_exception;
  END check_references;

  FUNCTION get_nextval return number IS
    next_group_id  NUMBER;
  BEGIN
    select rg_report_content_sets_s.nextval
    into   next_group_id
    from   dual;

    RETURN (next_group_id);
  END get_nextval;

END RG_REPORT_CONTENT_SETS_PKG;

/
