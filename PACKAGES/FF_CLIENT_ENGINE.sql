--------------------------------------------------------
--  DDL for Package FF_CLIENT_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_CLIENT_ENGINE" AUTHID CURRENT_USER as
/* $Header: ffcxeng.pkh 115.0 99/07/16 02:02:08 porting ship $ */
---------------------------- init_formula -------------------------------------
/*
  NAME
    init_formula
  DESCRIPTION
    Initialises engine to allow execution of a formula.
*/

procedure init_formula
(
  p_formula_id     in number,
  p_effective_date in date
);

------------------------------- set_input -------------------------------------
/*
  NAME
    set_input
  DESCRIPTION
    Allows the setting of inputs or contexts to the formula.

    There is only one version to avoid problems with calling
    overloaded functions from forms.  Therefore, dates and
    numbers have to passed in as the appropriate string.
*/

procedure set_input
(
  p_input_name in varchar2,
  p_value      in varchar2
);

------------------------------ run_formula ------------------------------------
/*
  NAME
    run_formula
  DESCRIPTION
    Uses data structures built up to execute Fast Formula.
*/

procedure run_formula;

-------------------------------- get_output -----------------------------------
/*
  NAME
    get_output
  DESCRIPTION
    Allows access to data returned from Fast Formula return variables.

    There is only one version to avoid problems with calling
    overloaded functions from forms.  Therefore, dates and
    numbers have to converted from strings as appropriate.
*/

procedure get_output
(
  p_return_name  in varchar2,
  p_return_value out varchar2
);

------------------------------- run_id_formula --------------------------------
/*
  NAME
    run_id_formula
  DESCRIPTION
    This procedure is designed specifically to be called from forms,
    in that it reduces network round trips to a minimum, i.e. it sets
    inputs and executes the formula in one network round-trip,
    returning values on the way back.

    This version is to be used when the caller knows the id of the
    formula they wish to execute.

    Unfortunately, since forms PLSQL is V1 - we cannot have an
    arbitrarily large number of parameters (using defaults) - so
    this procedure copes with up to 5 inputs, contexts and
    outputs.

    The clent will simply pass null values to the parameters
    that are not needed.
*/
procedure run_id_formula
(
  p_formula_id     in number,
  p_effective_date in date,
  p_input_name01   in varchar2, p_input_value01   in varchar2,
  p_input_name02   in varchar2, p_input_value02   in varchar2,
  p_input_name03   in varchar2, p_input_value03   in varchar2,
  p_input_name04   in varchar2, p_input_value04   in varchar2,
  p_input_name05   in varchar2, p_input_value05   in varchar2,
  p_input_name06   in varchar2, p_input_value06   in varchar2,
  p_input_name07   in varchar2, p_input_value07   in varchar2,
  p_input_name08   in varchar2, p_input_value08   in varchar2,
  p_input_name09   in varchar2, p_input_value09   in varchar2,
  p_input_name10   in varchar2, p_input_value10   in varchar2,

  p_context_name01  in varchar2, p_context_value01 in varchar2,
  p_context_name02  in varchar2, p_context_value02 in varchar2,
  p_context_name03  in varchar2, p_context_value03 in varchar2,
  p_context_name04  in varchar2, p_context_value04 in varchar2,
  p_context_name05  in varchar2, p_context_value05 in varchar2,
  p_context_name06  in varchar2, p_context_value06 in varchar2,
  p_context_name07  in varchar2, p_context_value07 in varchar2,
  p_context_name08  in varchar2, p_context_value08 in varchar2,
  p_context_name09  in varchar2, p_context_value09 in varchar2,
  p_context_name10  in varchar2, p_context_value10 in varchar2,
  p_context_name11  in varchar2, p_context_value11 in varchar2,
  p_context_name12  in varchar2, p_context_value12 in varchar2,
  p_context_name13  in varchar2, p_context_value13 in varchar2,
  p_context_name14  in varchar2, p_context_value14 in varchar2,

  p_return_name01   in varchar2, p_return_value01  in out varchar2,
  p_return_name02   in varchar2, p_return_value02  in out varchar2,
  p_return_name03   in varchar2, p_return_value03  in out varchar2,
  p_return_name04   in varchar2, p_return_value04  in out varchar2,
  p_return_name05   in varchar2, p_return_value05  in out varchar2,
  p_return_name06   in varchar2, p_return_value06  in out varchar2,
  p_return_name07   in varchar2, p_return_value07  in out varchar2,
  p_return_name08   in varchar2, p_return_value08  in out varchar2,
  p_return_name09   in varchar2, p_return_value09  in out varchar2,
  p_return_name10   in varchar2, p_return_value10  in out varchar2
);

------------------------------ run_name_formula -------------------------------
/*
  NAME
    run_name_formula
  DESCRIPTION
    This procedure is designed specifically to be called from forms,
    in that it reduces network round trips to a minimum, i.e. it sets
    inputs and executes the formula in one network round-trip,
    returning values on the way back.

    This version takes formula_name and formula_type_name as a
    convenience for users who do not know the formula_id.

    Unfortunately, since forms PLSQL is V1 - we cannot have an
    arbitrarily large number of parameters (using defaults) - so
    this procedure copes with up to 5 inputs, contexts and
    outputs.

    The clent will simply pass null values to the parameters
    that are not needed.
*/
procedure run_name_formula
(
  p_formula_type_name in varchar2,
  p_formula_name      in varchar2,
  p_effective_date    in date,
  p_input_name01 in varchar2, p_input_value01 in varchar2,
  p_input_name02 in varchar2, p_input_value02 in varchar2,
  p_input_name03 in varchar2, p_input_value03 in varchar2,
  p_input_name04 in varchar2, p_input_value04 in varchar2,
  p_input_name05 in varchar2, p_input_value05 in varchar2,
  p_input_name06 in varchar2, p_input_value06 in varchar2,
  p_input_name07 in varchar2, p_input_value07 in varchar2,
  p_input_name08 in varchar2, p_input_value08 in varchar2,
  p_input_name09 in varchar2, p_input_value09 in varchar2,
  p_input_name10 in varchar2, p_input_value10 in varchar2,

  p_context_name01 in varchar2, p_context_value01 in varchar2,
  p_context_name02 in varchar2, p_context_value02 in varchar2,
  p_context_name03 in varchar2, p_context_value03 in varchar2,
  p_context_name04 in varchar2, p_context_value04 in varchar2,
  p_context_name05 in varchar2, p_context_value05 in varchar2,
  p_context_name06 in varchar2, p_context_value06 in varchar2,
  p_context_name07 in varchar2, p_context_value07 in varchar2,
  p_context_name08 in varchar2, p_context_value08 in varchar2,
  p_context_name09 in varchar2, p_context_value09 in varchar2,
  p_context_name10 in varchar2, p_context_value10 in varchar2,
  p_context_name11 in varchar2, p_context_value11 in varchar2,
  p_context_name12 in varchar2, p_context_value12 in varchar2,
  p_context_name13 in varchar2, p_context_value13 in varchar2,
  p_context_name14 in varchar2, p_context_value14 in varchar2,

  p_return_name01 in varchar2, p_return_value01  in out varchar2,
  p_return_name02 in varchar2, p_return_value02  in out varchar2,
  p_return_name03 in varchar2, p_return_value03  in out varchar2,
  p_return_name04 in varchar2, p_return_value04  in out varchar2,
  p_return_name05 in varchar2, p_return_value05  in out varchar2,
  p_return_name06 in varchar2, p_return_value06  in out varchar2,
  p_return_name07 in varchar2, p_return_value07  in out varchar2,
  p_return_name08 in varchar2, p_return_value08  in out varchar2,
  p_return_name09 in varchar2, p_return_value09  in out varchar2,
  p_return_name10 in varchar2, p_return_value10  in out varchar2
);

end ff_client_engine;

 

/
