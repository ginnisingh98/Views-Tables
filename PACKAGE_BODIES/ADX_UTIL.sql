--------------------------------------------------------
--  DDL for Package Body ADX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ADX_UTIL" AS
 /* $Header: ADXUTILB.pls 120.0.12010000.2 2016/10/21 10:44:09 sbandla noship $ */

 FUNCTION GET_DB_NAME return varchar2 is
   dbname varchar2(256);
   begin
     select SYS_CONTEXT('USERENV','DB_NAME')
       into dbname from dual;
     return dbname;
 end GET_DB_NAME;

END ADX_UTIL;

/
