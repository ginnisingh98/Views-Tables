--------------------------------------------------------
--  DDL for Package Body AR_ARHDUNDP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARHDUNDP_XMLP_PKG" AS
/* $Header: ARHDUNDPB.pls 120.0 2007/12/27 13:19:50 abraghun noship $ */

FUNCTION BeforeReport RETURN BOOLEAN IS
BEGIN

DECLARE

    CURSOR get_co_name IS
      SELECT glsb.name   name
      FROM   gl_sets_of_books      glsb,
             ar_system_parameters  arsp
      WHERE  glsb.set_of_books_id = arsp.set_of_books_id;

      r1     get_co_name%ROWTYPE;

      l_len  number;

BEGIN

          /*srw.user_exit('FND SRWINIT');*/null;


          hz_common_pub.disable_cont_source_security;

          OPEN get_co_name;
     FETCH get_co_name INTO r1;
     CLOSE get_co_name;

     p_company_name := r1.name;


EXCEPTION

    WHEN others then
       /*srw.message('100','Oracle  Error : ' || SQLERRM) ;*/null;

END;

    RETURN (TRUE);

END;

FUNCTION AfterReport RETURN BOOLEAN IS
BEGIN

BEGIN

        hz_common_pub.enable_cont_source_security;

        /*SRW.USER_EXIT('FND SRWEXIT');*/null;


EXCEPTION

    WHEN others then
       /*srw.message('100','Oracle  Error : ' || SQLERRM) ;*/null;


END;

    RETURN (TRUE);

END;

--Functions to refer Oracle report placeholders--

END AR_ARHDUNDP_XMLP_PKG ;


/
