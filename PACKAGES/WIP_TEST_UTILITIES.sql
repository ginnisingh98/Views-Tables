--------------------------------------------------------
--  DDL for Package WIP_TEST_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_TEST_UTILITIES" AUTHID CURRENT_USER as
  /* $Header: wiptests.pls 115.6 2002/12/12 16:01:55 rmahidha ship $ */


-- Whether or not to execute the test code that is embedded in normal
-- packages. Using this boolean, we can embed test code that does a lot of
-- extra work without worrying about it causing a performance problem later.
EXECUTE_TEST_CODE boolean := false ;


-- Throws PROGRAMMER_ERROR if the condition is false.
procedure assert(condition boolean) ;

-- Throws PROGRAMMER_ERROR.
procedure die ;

-- Throws PROGRAMMER_ERROR after printing message.
procedure die(message varchar2) ;

PROGRAMMER_ERROR exception ;


end WIP_TEST_UTILITIES ;

 

/
