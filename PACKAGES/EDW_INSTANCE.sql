--------------------------------------------------------
--  DDL for Package EDW_INSTANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_INSTANCE" AUTHID CURRENT_USER AS
/* $Header: EDWSRINS.pls 115.6 2003/11/19 09:19:37 smulye ship $  */
VERSION			CONSTANT CHAR(80) := '$Header: EDWSRINS.pls 115.6 2003/11/19 09:19:37 smulye ship $';

-- ------------------------
-- Public Functions
-- ------------------------
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
FUNCTION get_code RETURN VARCHAR2;

-- ========================================
-- Need RNPS, RNDS for this function to be
-- available via view across database links
-- ========================================
PRAGMA RESTRICT_REFERENCES (get_code,WNDS, WNPS,RNPS);

END EDW_INSTANCE;

 

/
