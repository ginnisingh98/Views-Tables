--------------------------------------------------------
--  DDL for Package Body HR_API_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_UTILS" AS -- Body
/* $Header: hrapiutl.pkb 115.1 2002/11/29 12:22:44 apholt ship $ */
--
--
-- A procedure which will parse dynamic sql on the server.
procedure call_parse(p_cursor IN OUT NOCOPY NUMBER
                    ,p_proc IN OUT NOCOPY varchar2
                    ) IS
BEGIN
  dbms_sql.parse(p_cursor, p_proc, dbms_sql.v7);
END call_parse;
--
--
-- A procedure which will bind variables within a dynamic sql block.
-- Variables will be of the type varchar2.
--
PROCEDURE bind_var(p_cursor   IN     NUMBER
                  ,p_bind_var IN     VARCHAR2
                  ,p_out_val  IN OUT NOCOPY VARCHAR2
                  ) IS
BEGIN
  dbms_sql.bind_variable(p_cursor, p_bind_var, p_out_val, 240);
END bind_var;
--
--
-- A procedure which will bind variables within a dynamic sql block.
-- Variables are of the type number.
--
PROCEDURE bind_num(p_cursor   IN     NUMBER
                  ,p_bind_var IN     VARCHAR2
                  ,p_out_val  IN OUT NOCOPY NUMBER
                  ) IS
BEGIN
  dbms_sql.bind_variable(p_cursor, p_bind_var, p_out_val);
END bind_num;
--
--
-- A procedure which will bind variables within a dynamic sql block.
-- Variables are of the type date.
--
PROCEDURE bind_date(p_cursor   IN     NUMBER
                   ,p_bind_var IN     VARCHAR2
                   ,p_out_val  IN OUT NOCOPY DATE
                   ) IS
BEGIN
  dbms_sql.bind_variable(p_cursor, p_bind_var, p_out_val);
END bind_date;
--
--  The following are procedures which will return values from
--  bound varibales.
--
-- For values of the type varchar2.
--
PROCEDURE get_var(p_cursor   IN     NUMBER
                 ,p_bind_var IN     VARCHAR2
                 ,p_out_val  IN OUT NOCOPY VARCHAR2
                 ) IS
BEGIN
  dbms_sql.variable_value(p_cursor, p_bind_var, p_out_val);
END get_var;
--
--
-- For values of the type number.
--
PROCEDURE get_num(p_cursor   IN     NUMBER
                 ,p_bind_var IN     VARCHAR2
                 ,p_out_val  IN OUT NOCOPY NUMBER
                 ) IS
BEGIN
  dbms_sql.variable_value(p_cursor, p_bind_var, p_out_val);
END get_num;
--
--
-- For values of the type date.
--
PROCEDURE get_date(p_cursor   IN     NUMBER
                  ,p_bind_var IN     VARCHAR2
                  ,p_out_val  IN OUT NOCOPY DATE
                  ) IS
BEGIN
  dbms_sql.variable_value(p_cursor, p_bind_var, p_out_val);
END get_date;
--
--
END hr_api_utils;

/
