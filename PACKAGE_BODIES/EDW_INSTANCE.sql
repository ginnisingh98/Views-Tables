--------------------------------------------------------
--  DDL for Package Body EDW_INSTANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_INSTANCE" AS
/* $Header: EDWSRINB.pls 115.5 2003/11/19 09:10:56 smulye ship $  */
VERSION			CONSTANT CHAR(80) := '$Header: EDWSRINB.pls 115.5 2003/11/19 09:10:56 smulye ship $';

---------------------------------------------------------------------------------
/*
Name : get_code

Purpose : To get the local instance code. This code is
          run at the source site

Arguments
Input :
  NONE
O/P
  l_instance_code  :   Holds the value of the local instance
                       that it gets from edw_local_instance
                       Data Type:  VARCHAR2(30)
*/
---------------------------------------------------------------------------------

FUNCTION get_code RETURN VARCHAR2 IS
l_local_instance VARCHAR2(30):='';
BEGIN
  -- get the instance code from the local instance

  SELECT instance_code into
     l_local_instance
  FROM EDW_LOCAL_INSTANCE;

  RETURN l_local_instance;
EXCEPTION when NO_DATA_FOUND then
  null;
  raise;

END get_code;

END EDW_INSTANCE;

/
