--------------------------------------------------------
--  DDL for Package Body EAM_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CONSTANTS" AS
 /* $Header: EAMCONSB.pls 115.0 2002/11/12 06:51:18 rethakur noship $ */

  -- Cover routine to SQLCODE and SQLERRM to place error code and text
  -- onto message stack.
  procedure get_ora_error(application varchar2, proc_name varchar2) IS
    x_sql_code number;
    x_sql_errm varchar2(512);
  begin
    x_sql_code := sqlcode;
    x_sql_errm := sqlerrm(x_sql_code);

    fnd_message.set_name(
      application => application,
      name        => 'SQL-Generic error');
    fnd_message.set_token(
      token     => 'ERRNO',
      value     => to_char(x_sql_code),
      translate => true);
    fnd_message.set_token(
      token     => 'ROUTINE',
      value     => proc_name,
      translate => TRUE);
    fnd_message.set_token(
      token     => 'REASON',
      value     => x_sql_errm,
      translate => TRUE);
  end get_ora_error;

  procedure initialize is
  begin
    return;
  end initialize;

END EAM_CONSTANTS;

/
