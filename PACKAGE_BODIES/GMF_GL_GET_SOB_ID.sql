--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_SOB_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_SOB_ID" AS
/* $Header: gmfsobib.pls 115.1 2002/11/11 00:44:19 rseshadr ship $ */
  CURSOR cur_gl_get_sob_id(st_date date, en_date date,
  sob_name varchar2)  IS
        SELECT   set_of_books_id
        FROM     gl_sets_of_books
        WHERE    name LIKE sob_name
        AND      creation_date
        BETWEEN  nvl(st_date,creation_date)
        AND      nvl(en_date,creation_date);

  PROCEDURE proc_gl_get_sob_id(
          st_date  in out  NOCOPY date,
          en_date    in out  NOCOPY date,
          sob_name    in out  NOCOPY varchar2,
          sob_id     out   NOCOPY number,
          row_to_fetch in number,
          error_status out   NOCOPY number) IS
  Begin  /* Beginning of procedure proc_gl_get_sob_id */

    IF NOT cur_gl_get_sob_id%ISOPEN THEN
      OPEN cur_gl_get_sob_id(st_date, en_date, sob_name);
    END IF;
    FETCH cur_gl_get_sob_id
    INTO   sob_id;
    if cur_gl_get_sob_id%NOTFOUND then
      error_status := 100;
    end if;
    if (cur_gl_get_sob_id%NOTFOUND) or row_to_fetch = 1 THEN
      CLOSE cur_gl_get_sob_id;
    end if;
    exception
    when others then
      error_status := SQLCODE;
  END;  /* End of procedure proc_gl_get_sob_id */
END GMF_GL_GET_SOB_ID;  -- END GMF_GL_GET_SOB_ID

/
