--------------------------------------------------------
--  DDL for Package Body GL_BC_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BC_GROUP_PKG" as
/* $Header: glibcgpb.pls 120.2 2005/05/05 00:59:30 kvora ship $ */
--
-- Package
--   gl_bc_group_pkg
-- Purpose
--   To contain validation, insertion, and update routines for gl_bc_group
-- History
--   09-12-94   Sharif Rahman 	Created

PROCEDURE check_unique_bc_option_name(X_bc_option_name  VARCHAR2 ) IS
  dummy    NUMBER;
BEGIN
  select 1 into dummy from dual
  where not exists
    (select 1 from gl_bc_options
     where bc_option_name = X_bc_option_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL','GL_DUPLICATE_BC_GROUP');
      app_exception.raise_exception;
END check_unique_bc_option_name;


FUNCTION get_unique_id RETURN NUMBER IS
  next_id NUMBER;
BEGIN
  SELECT gl_bc_options_s.nextval
  INTO next_id
  FROM dual;

  RETURN (next_id);
END get_unique_id;

END GL_BC_GROUP_PKG;

/
