--------------------------------------------------------
--  DDL for Package FUN_RICH_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RICH_MESSAGE_PKG" AUTHID CURRENT_USER AS
/* $Header: FUNXTMRULRTMUTS.pls 120.0 2005/06/20 04:30:11 ammishra noship $ */

/*
TYPE token_rec_type IS RECORD (
   TOK_NAM   VARCHAR2(100),
   TOK_VAL   VARCHAR2(100)
);

TYPE token_tab_type IS TABLE OF token_rec_type INDEX BY BINARY_INTEGER;
*/

PROCEDURE init_token_list;

PROCEDURE add_token(name VARCHAR2, value VARCHAR2);

FUNCTION CLOB_REPLACE(P_LOB IN OUT nocopy CLOB,
                      P_WHAT IN VARCHAR2,
               	      P_WITH IN VARCHAR2) RETURN CLOB;

--Method to be called from Java programs where token substitutions would happen in Java.

FUNCTION GET_MESSAGE_JAVA(APPLICATION_SHORT_NAME  IN VARCHAR2,
                          MESSAGE_NAME in varchar2
                         ) return CLOB;

--Method to be called from PLSQL program.
FUNCTION GET_MESSAGE(APPLICATION_SHORT_NAME  IN VARCHAR2,
             MESSAGE_NAME in varchar2
            ) return CLOB;


/*FUNCTION TEST RETURN CLOB;*/


END FUN_RICH_MESSAGE_PKG;

 

/
