--------------------------------------------------------
--  DDL for Package QLTSMENB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTSMENB" AUTHID CURRENT_USER as
/* $Header: qltsmenb.pls 115.2 2002/11/27 19:30:21 jezheng ship $ */

-- 8/2/95 - CREATED
-- Kevin Wiggen

--  This package does the join to other tables for qa results
--  It needs the char_id and value from results, and it will perform the lookup
--  It is not necessary to check if there is a lookup first, but its suggested

  FUNCTION LOOKUP(x_char_id IN NUMBER,
	          x_value   IN VARCHAR2)
     RETURN VARCHAR2;



END QLTSMENB;


 

/
