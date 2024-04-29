--------------------------------------------------------
--  DDL for Package EDW_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MESSAGE_S" AUTHID CURRENT_USER AS
/* $Header: EDWCOMSS.pls 115.5 1999/12/10 14:41:13 pkm ship      $*/

g_routine varchar2(240) := NULL;
g_location varchar2(10) := NULL;

PROCEDURE SQL_ERROR(routine IN varchar2 ,
                    location IN varchar2,
                    error_code IN number);

PROCEDURE APP_ERROR(error_name IN varchar2);

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2);

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2);

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2,
                    token3 IN varchar2,
                    value3 IN varchar2);

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2,
                    token3 IN varchar2,
                    value3 IN varchar2,
                    token4 IN varchar2,
                    value4 IN varchar2);

PROCEDURE SQL_SHOW_ERROR;

PROCEDURE APP_SET_NAME(error_name IN varchar2);

PROCEDURE CLEAR;

END EDW_MESSAGE_S;

 

/
