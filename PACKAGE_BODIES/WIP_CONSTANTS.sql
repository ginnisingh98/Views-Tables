--------------------------------------------------------
--  DDL for Package Body WIP_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CONSTANTS" AS
 /* $Header: wipconsb.pls 115.7 2002/12/12 16:57:10 rmahidha ship $ */

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

END WIP_CONSTANTS;

/
