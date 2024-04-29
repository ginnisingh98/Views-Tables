--------------------------------------------------------
--  DDL for Function GET_COMPNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."GET_COMPNO" (
               Set_of_books_id NUMBER,
               in_stallid VARCHAR2)
             RETURN NUMBER AUTHID CURRENT_USER IS
/* $Header: ARTAESDY.pls 115.3 2000/07/10 16:18:52 pkm ship      $ */
   BEGIN
      RETURN (0);
END get_compno;

 

/
