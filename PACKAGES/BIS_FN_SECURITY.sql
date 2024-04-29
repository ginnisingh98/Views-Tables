--------------------------------------------------------
--  DDL for Package BIS_FN_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FN_SECURITY" AUTHID CURRENT_USER AS
/* $Header: BISLNKSS.pls 115.1 99/07/17 16:08:32 porting ship $ */

--  Start of Comments
--  API name    isAccessible
--  Type        Public
--  Function
--       Returns 'TRUE' if the given responsibility is permitted to access
--       the function. otherwise returns 'FALSE'
--  Pre-reqs
--
--  Parameters
--      p_function_id         - id of the function in fnd_form_functions
--      p_responsibility_id   - id of responsibility form fnd_responsibility
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
FUNCTION isAccessible
(
   p_function_id      	in number
   ,p_responsibility_id in number
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(isAccessible, WNDS, WNPS, RNPS);

END BIS_FN_SECURITY ;

 

/
