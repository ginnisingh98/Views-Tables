--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_CURRENCIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_CURRENCIES" AS
/* $Header: gmfcurdb.pls 115.0 99/07/16 04:17:05 porting shi $ */
  CURSOR cur_gl_get_currencies(st_date date, en_date date,
  cur_code varchar2) IS
        SELECT   currency_code, name, description, precision, symbol,
               creation_date, created_by,
		last_update_date,last_updated_by
             FROM  fnd_currencies_vl
        WHERE    currency_code like cur_code AND
               last_update_date BETWEEN nvl(st_date, last_update_date)
               AND nvl(en_date, last_update_date);
 function get_name(usr_id  number) return varchar2 is
    usr_name varchar2(100);
       begin
          select user_name into usr_name from fnd_user where
          user_id=usr_id;
        return(usr_name);
      end;
  PROCEDURE proc_gl_get_currencies(
          st_date  in out  date,
          en_date    in out  date,
          cur_code    in out  varchar2,
          cur_name    in out  varchar2,
          descr            out  varchar2,
          preci            out  number,
          symb             out  varchar2,
          creation_date    out  date,
          created_by       out  number,
          last_update_date out  date,
          last_updated_by  out  number,
          row_to_fetch   in out  number,
          error_status out   number) IS
/*   ad_by number;*/
/*  mod_by number;*/
  Begin  /* Beginning of procedure proc_gl_get_currencies*/
    	IF NOT cur_gl_get_currencies%ISOPEN THEN
      	OPEN cur_gl_get_currencies(st_date, en_date, cur_code);
    	END IF;
    	FETCH cur_gl_get_currencies
    		INTO   cur_code ,cur_name, descr, preci, symb, 			creation_date,created_by,last_update_date,
			last_updated_by;
    		IF cur_gl_get_currencies%NOTFOUND then
       		error_status := 100;
      	END IF;
      IF cur_gl_get_currencies%NOTFOUND or row_to_fetch = 1 THEN
            CLOSE cur_gl_get_currencies;
      END IF;
/* SIERRA COMMENTED kiran 3/11/98 instead of getting the user_id into*/
/* ad_by and mod_by the values are directly fetched into created_by*/
/* and last_updated_by.*/
      /*created_by:=get_name(ad_by);*/
      /* modified_by:=get_name(mod_by);*/
      exception
          when others then
            error_status := SQLCODE;
  END;  /* End of procedure proc_gl_get_currencies*/
END GMF_GL_GET_CURRENCIES;  /* END GMF_GL_GET_CURRENCIES*/

/
