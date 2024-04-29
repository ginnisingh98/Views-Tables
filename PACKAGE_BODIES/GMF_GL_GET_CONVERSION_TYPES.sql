--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_CONVERSION_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_CONVERSION_TYPES" AS
/* $Header: gmfcnvtb.pls 115.1 2002/11/11 00:32:49 rseshadr ship $ */
      CURSOR conversion_types(  startdate date,
                        enddate date,
                        usr_conversiontype varchar2) IS
          SELECT  conversion_type,
                user_conversion_type,
                description,
                creation_date,
                last_update_date,
                created_by,
                last_updated_by
          FROM  GL_DAILY_CONVERSION_TYPES
          WHERE  nvl(user_conversion_type,' ')  like
                  nvl(usr_conversiontype,nvl(user_conversion_type,' '))
                                      AND
      /*        nvl(description,' ')  like
                      nvl(descr,nvl(description,' '))   AND
                      */
              last_update_date  BETWEEN
              nvl(startdate,last_update_date)  AND
              nvl(enddate,last_update_date);
      PROCEDURE gl_get_conversion_types(  startdate in date,
                              enddate in date,
                              creation_date out NOCOPY date,
                              last_update_date out NOCOPY date,
                              created_by out NOCOPY number,
                              last_updated_by out NOCOPY number,
                              conversiontype in out NOCOPY varchar2,
                              usr_conversiontype in out NOCOPY varchar2,
                              descr in out NOCOPY varchar2,
                              row_to_fetch in out NOCOPY number,
                              statuscode out NOCOPY number) IS
      BEGIN
        IF NOT conversion_types%ISOPEN THEN
          OPEN conversion_types(startdate,enddate,usr_conversiontype);
        END IF;
        FETCH conversion_types INTO   conversiontype,
                            usr_conversiontype,
                            descr,
                            creation_date,
                            last_update_date,
                            created_by,
                            last_updated_by ;
  /*            added_by := pkg_gl_get_currencies.get_name(ad_by);*/
  /*            modified_by := pkg_gl_get_currencies.get_name(mod_by);*/
          if conversion_types%NOTFOUND then
          statuscode:=100;
          END IF;
        IF conversion_types%NOTFOUND or row_to_fetch = 1 THEN
          CLOSE conversion_types;
        END IF;
        EXCEPTION
          WHEN OTHERS THEN
            statuscode := SQLCODE;
      END;    /* Procedure gl_get_conversion_types*/
      END GMF_GL_GET_CONVERSION_TYPES;

/
