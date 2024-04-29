--------------------------------------------------------
--  DDL for Package FF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_UTILS" AUTHID CURRENT_USER as
/* $Header: ffutil.pkh 115.2 2002/05/31 07:13:29 pkm ship     $ */
/*
 *  Debug global variable
 */
g_debug_level binary_integer;

/*
 *  The following constants define the debugging levels
 *  that are available.
 */
ROUTING     constant binary_integer := 1;

---------------------------- set_debug ----------------------------------------
/*
  NAME
    set_debug
  DESCRIPTION
    Sets the debugging option to appropriate level.
  NOTES
    This procedure is used to set the value of a global
    variable that, in turn, controls debugging output.
*/
procedure set_debug
(
  p_debug_level in binary_integer
);

------------------------------ assert -----------------------------------------
/*
  NAME
    assert
  DESCRIPTION
    Raise assert error if expression is FALSE.
  NOTES
    The procedure takes two parameters.  The first is an expression
    that should resolve to a boolean.  If this is FALSE, an error
    is raised.  The position that this error occurred is indicated
    by the second parameter, which is unique within the code, and
    by convension is in the form '<procedure_name>:<number>', e.g.
    'load_formula:2'.

    This procedure should be used to test 'impossible' conditions
    have not occurred.  It should not be used as a substitute for
    common user errors.
*/

procedure assert
(
  p_expression in boolean,
  p_location   in varchar2
);

--------------------------------- entry ---------------------------------------
/*
  NAME
    entry
  DESCRIPTION
    Outputs a TRACE message to indicate enty to a function.
  NOTES
    Output controlled  by current debug level.
*/
procedure entry
(
  p_procedure_name in varchar2
);

--------------------------------- exit ----------------------------------------
/*
  NAME
    exit
  DESCRIPTION
    Outputs a TRACE message to indicate exit from a function.
  NOTES
    Output controlled  by current debug level.
*/
procedure exit
(
  p_procedure_name in varchar2
);

end ff_utils;

 

/
