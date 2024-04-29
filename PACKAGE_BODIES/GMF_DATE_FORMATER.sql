--------------------------------------------------------
--  DDL for Package Body GMF_DATE_FORMATER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_DATE_FORMATER" AS
/* $Header: gmfformb.pls 115.0 99/07/16 04:17:53 porting shi $ */

       procedure FORMAT_DATE (datetoformat  in  date,
                              formattouse   in  varchar2,
                              formateddate  out varchar2,
                              statuscode    out number) IS

       BEGIN

          SELECT to_char(datetoformat,formattouse)
          INTO   formateddate
          FROM   sys.dual;

          EXCEPTION
            when others then
                 statuscode := SQLCODE;

       END FORMAT_DATE;
END GMF_DATE_FORMATER;

/
