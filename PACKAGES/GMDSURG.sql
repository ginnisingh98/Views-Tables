--------------------------------------------------------
--  DDL for Package GMDSURG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDSURG" AUTHID CURRENT_USER AS
/* $Header: GMDPSURS.pls 115.10 2002/03/24 06:24:28 pkm ship    $ */

/* Subtypes                                                                                          */
/* ========                                                                                          */
SUBTYPE sqlbuffer_type IS all_source.text%TYPE;

/* Constants                                                                                         */
/* =========                                                                                         */
ss_debug CONSTANT INTEGER   := 1;
ss_sqltype CONSTANT NUMBER  := DBMS_SQL.NATIVE;
ss_cursor  INTEGER          := 1;

/* Error Return Code Constants:                                                                      */
/* ============================                                                                      */
SURG_PACKAGE_ERR         CONSTANT INTEGER := -90001;

/* Functions and Procedures                                                                          */
/* ========================                                                                          */
  FUNCTION get_surrogate(psurrogate VARCHAR2) RETURN NUMBER;
END;

 

/
