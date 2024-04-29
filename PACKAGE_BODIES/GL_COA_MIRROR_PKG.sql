--------------------------------------------------------
--  DDL for Package Body GL_COA_MIRROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_COA_MIRROR_PKG" as
/* $Header: glcoamrb.pls 120.2 2005/05/05 02:02:36 kvora ship $ */

  PROCEDURE set_coa_id ( X_coa_id   NUMBER) IS
  BEGIN
    gl_coa_mirror_pkg.chart_of_accounts_id := X_coa_id;
  END set_coa_id;

  FUNCTION get_coa_id RETURN NUMBER IS
    profile_val   VARCHAR2(100);
    defined_flag  BOOLEAN;
    as_id NUMBER;
    coa_id        NUMBER;
  BEGIN
    IF(gl_coa_mirror_pkg.chart_of_accounts_id is null) then
        fnd_profile.get_specific(name_z => 'GL_ACCESS_SET_ID',
                                 val_z => profile_val,
                                 defined_z=> defined_flag);
        if(profile_val IS NULL OR defined_flag = FALSE) then
           app_exception.raise_exception;
        end if;

        as_id := to_number(profile_val);

        SELECT chart_of_accounts_id
        INTO coa_id
        FROM gl_access_sets
        WHERE access_set_id = as_id;

        gl_coa_mirror_pkg.chart_of_accounts_id := coa_id;

    END IF;

    RETURN gl_coa_mirror_pkg.chart_of_accounts_id;

  EXCEPTION
    when app_exceptions.application_exception then
         return -1;

  END get_coa_id;

END GL_COA_MIRROR_PKG;

/
