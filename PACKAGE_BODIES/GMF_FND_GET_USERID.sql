--------------------------------------------------------
--  DDL for Package Body GMF_FND_GET_USERID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_FND_GET_USERID" AS
/* $Header: gmfusrib.pls 115.2 2002/11/11 00:46:23 rseshadr Exp $ */
  CURSOR cur_get_user_id(st_date date, en_date date,
  usr_name varchar2)  IS
        SELECT   user_id
           FROM     fnd_user
        WHERE    lower(user_name) LIKE lower(usr_name)   AND
               creation_date BETWEEN
              nvl(start_date,creation_date) AND
              nvl(end_date,creation_date);
  PROCEDURE proc_fnd_get_user_id(
          start_date  in out  NOCOPY date,
          end_date    in out  NOCOPY date,
          usr_name            varchar2,
          user_id     out   NOCOPY number,
          row_to_fetch in out  NOCOPY number,
          error_status out   NOCOPY number) IS
          st_date date;
          en_date date;
  Begin  /*Beginning of procedure proc_fnd_get_user_id*/
       st_date := start_date;
       en_date := end_date;
    IF NOT cur_get_user_id%ISOPEN THEN
      OPEN cur_get_user_id(st_date, en_date, usr_name);
    END IF;
    FETCH cur_get_user_id
    INTO   user_id;
      if cur_get_user_id%NOTFOUND then
      error_status := 100;
      end if;
    IF cur_get_user_id%NOTFOUND or row_to_fetch = 1 THEN
      CLOSE cur_get_user_id;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        error_status := SQLCODE;
  END;  /*End of procedure proc_fnd_get_user_id*/
END GMF_FND_GET_USERID;  -- END GMF_FND_GET_USERID

/
