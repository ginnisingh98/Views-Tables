--------------------------------------------------------
--  DDL for Package Body FF_CLIENT_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_CLIENT_ENGINE" as
/* $Header: ffcxeng.pkb 115.0 99/07/16 02:02:05 porting ship $ */

/*---------------------------------------------------------------------------*/
/*-------------------------- global variables -------------------------------*/
/*---------------------------------------------------------------------------*/
/*
 *  Need to keep the input and output data structures in global
 *  variables.
 */
g_inputs  ff_exec.inputs_t;   -- inputs and contexts.
g_outputs ff_exec.outputs_t;  -- the outputs.

/*---------------------------------------------------------------------------*/
/*------------------ local functions and procedures -------------------------*/
/*---------------------------------------------------------------------------*/

/*
 *  Actually deals with the core business of setting
 *  an input (or context) value.
 *  If the p_datatype parameter is null, it does not
 *  check the datatype of the input name - it assumes
 *  that it is correct.
 *  It is a private procedure.
 */
procedure local_set_input
(
  p_input_name   in varchar2,
  p_input_value  in varchar2
) is
  l_count binary_integer;
  l_found boolean := false;
begin

  ff_utils.entry('client:local_set_input');

  if(p_input_name is null) then
    return; -- do not set if null.
  end if;

  for l_count in g_inputs.first..g_inputs.last loop
    -- Search for a match in the name.
    if(g_inputs(l_count).name = p_input_name) then
      g_inputs(l_count).value := p_input_value;
      l_found := TRUE;
      exit;  -- will only be one match.
    end if;
  end loop;

  -- We expect to have found the input, so check that.
  if(not l_found) then
    hr_utility.set_message(801, 'FFPLX03_ITEM_NOT_FOUND');
    hr_utility.set_message_token('NAME', p_input_name);
    hr_utility.raise_error;
  end if;

  ff_utils.exit('client:local_set_input');

end local_set_input;

/*
 *  Generic, overloaded version of the get_output procedure
 *  called by the datatype specific versions.
 *  If the p_return_name parameter is null, the routine
 *  does not attempt to set a value.
 *  If the p_datatype parameter is null, it assumes
 *  the datatype of the input matches the expected
 *  type.
 */
procedure local_get_output
(
  p_return_name  in varchar2,
  p_return_value out varchar2
) is
  l_count binary_integer;
  l_found boolean;
begin

  ff_utils.entry('client:local_get_output');

  -- Exit immediately if the return name is null.
  if(p_return_name is null) then
    return;
  end if;

  for l_count in g_outputs.first..g_outputs.last loop
    if(g_outputs(l_count).name = p_return_name) then
      p_return_value := g_outputs(l_count).value;
      l_found := TRUE;
      exit; -- wil be only one match.
    end if;
  end loop;

  -- We expect to have found the input, so check that.
  if(not l_found) then
    hr_utility.set_message(801, 'FFPLX03_ITEM_NOT_FOUND');
    hr_utility.set_message_token('NAME', p_return_name);
    hr_utility.raise_error;
  end if;

  ff_utils.exit('client:local_get_output');

end local_get_output;


---------------------------- init_formula -------------------------------------
/*
  NAME
    init_formula
  DESCRIPTION
    Initialises engine to allow execution of a formula.
  NOTES
    Calls the main formula initialisation, creating the tables.
*/

procedure init_formula
(
   p_formula_id     in number,
   p_effective_date in date
) is
begin

  ff_utils.entry('client:init_formula');

  ff_exec.init_formula(p_formula_id, p_effective_date, g_inputs, g_outputs);

  ff_utils.exit('client:init_formula');

end init_formula;

------------------------------- set_input -------------------------------------
/*
  NAME
    set_input
  DESCRIPTION
    Allows the setting of inputs or contexts to the formula.
    One version has to be used for all three data types.
  NOTES
    The input with the appropriate name is searched for in the
    inputs table and the value set.
*/

procedure set_input
(
  p_input_name in varchar2,
  p_value      in varchar2
) is
begin
  ff_utils.entry('client:set_input (varchar2)');

  -- Call the generic set_input procedure
  local_set_input(p_input_name, p_value);

  ff_utils.exit('set_input (varchar2)');

end set_input;

------------------------------ run_formula ------------------------------------
/*
  NAME
    init_formula
  DESCRIPTION
    Uses data structures built up to execute Fast Formula.
  NOTES
    Calls the main run_formula routine.
    Always uses the db item cache.
*/

procedure run_formula is
begin

  ff_utils.entry('client:run_formula');

  ff_exec.run_formula(g_inputs, g_outputs);

  ff_utils.exit('client:run_formula');

end run_formula;

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
) is
begin

  ff_utils.entry('run_id_formula');

  -- Initialise the formula.
  ff_exec.init_formula(p_formula_id, p_effective_date, g_inputs, g_outputs);

  -- Set the inputs.
  local_set_input(p_input_name01, p_input_value01);
  local_set_input(p_input_name02, p_input_value02);
  local_set_input(p_input_name03, p_input_value03);
  local_set_input(p_input_name04, p_input_value04);
  local_set_input(p_input_name05, p_input_value05);
  local_set_input(p_input_name06, p_input_value06);
  local_set_input(p_input_name07, p_input_value07);
  local_set_input(p_input_name08, p_input_value08);
  local_set_input(p_input_name09, p_input_value09);
  local_set_input(p_input_name10, p_input_value10);

  -- Set the contexts.
  local_set_input(p_context_name01, p_context_value01);
  local_set_input(p_context_name02, p_context_value02);
  local_set_input(p_context_name03, p_context_value03);
  local_set_input(p_context_name04, p_context_value04);
  local_set_input(p_context_name05, p_context_value05);
  local_set_input(p_context_name06, p_context_value06);
  local_set_input(p_context_name07, p_context_value07);
  local_set_input(p_context_name08, p_context_value08);
  local_set_input(p_context_name09, p_context_value09);
  local_set_input(p_context_name10, p_context_value10);
  local_set_input(p_context_name11, p_context_value11);
  local_set_input(p_context_name12, p_context_value12);
  local_set_input(p_context_name13, p_context_value13);
  local_set_input(p_context_name14, p_context_value14);

  -- Now execute the formula.
  ff_client_engine.run_formula;

  -- Get the outputs.
  local_get_output(p_return_name01, p_return_value01);
  local_get_output(p_return_name02, p_return_value02);
  local_get_output(p_return_name03, p_return_value03);
  local_get_output(p_return_name04, p_return_value04);
  local_get_output(p_return_name05, p_return_value05);
  local_get_output(p_return_name06, p_return_value06);
  local_get_output(p_return_name07, p_return_value07);
  local_get_output(p_return_name08, p_return_value08);
  local_get_output(p_return_name09, p_return_value09);
  local_get_output(p_return_name10, p_return_value10);

  ff_utils.exit('run_id_formula');

end run_id_formula;

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
) is
  l_formula_id number;
begin
  ff_utils.entry('run_name_formula');

  -- Obtain the appropriate ids.
  select fff.formula_id
  into   l_formula_id
  from   ff_formulas_f    fff,
         ff_formula_types fft
  where  fft.formula_type_name = p_formula_type_name
  and    fff.formula_type_id   = fft.formula_type_id
  and    fff.formula_name      = p_formula_name
  and    p_effective_date between
         fff.effective_start_date and fff.effective_end_date;

  -- Call the other version of run_formula.
  ff_client_engine.run_id_formula
  (
    p_formula_id     => l_formula_id,
    p_effective_date => p_effective_date,
    p_input_name01   => p_input_name01,
    p_input_value01  => p_input_value01,
    p_input_name02   => p_input_name02,
    p_input_value02  => p_input_value02,
    p_input_name03   => p_input_name03,
    p_input_value03  => p_input_value03,
    p_input_name04   => p_input_name04,
    p_input_value04  => p_input_value04,
    p_input_name05   => p_input_name05,
    p_input_value05  => p_input_value05,
    p_input_name06   => p_input_name06,
    p_input_value06  => p_input_value06,
    p_input_name07   => p_input_name07,
    p_input_value07  => p_input_value07,
    p_input_name08   => p_input_name08,
    p_input_value08  => p_input_value08,
    p_input_name09   => p_input_name09,
    p_input_value09  => p_input_value09,
    p_input_name10   => p_input_name10,
    p_input_value10  => p_input_value10,

    p_context_name01  => p_context_name01,
    p_context_value01 => p_context_value01,
    p_context_name02  => p_context_name02,
    p_context_value02 => p_context_value02,
    p_context_name03  => p_context_name03,
    p_context_value03 => p_context_value03,
    p_context_name04  => p_context_name04,
    p_context_value04 => p_context_value04,
    p_context_name05  => p_context_name05,
    p_context_value05 => p_context_value05,
    p_context_name06  => p_context_name06,
    p_context_value06 => p_context_value06,
    p_context_name07  => p_context_name07,
    p_context_value07 => p_context_value07,
    p_context_name08  => p_context_name08,
    p_context_value08 => p_context_value08,
    p_context_name09  => p_context_name09,
    p_context_value09 => p_context_value09,
    p_context_name10  => p_context_name10,
    p_context_value10 => p_context_value10,
    p_context_name11  => p_context_name11,
    p_context_value11 => p_context_value11,
    p_context_name12  => p_context_name12,
    p_context_value12 => p_context_value12,
    p_context_name13  => p_context_name13,
    p_context_value13 => p_context_value13,
    p_context_name14  => p_context_name14,
    p_context_value14 => p_context_value14,

    p_return_name01  => p_return_name01,
    p_return_value01 => p_return_value01,
    p_return_name02  => p_return_name02,
    p_return_value02 => p_return_value02,
    p_return_name03  => p_return_name03,
    p_return_value03 => p_return_value03,
    p_return_name04  => p_return_name04,
    p_return_value04 => p_return_value04,
    p_return_name05  => p_return_name05,
    p_return_value05 => p_return_value05,
    p_return_name06  => p_return_name06,
    p_return_value06 => p_return_value06,
    p_return_name07  => p_return_name07,
    p_return_value07 => p_return_value07,
    p_return_name08  => p_return_name08,
    p_return_value08 => p_return_value08,
    p_return_name09  => p_return_name09,
    p_return_value09 => p_return_value09,
    p_return_name10  => p_return_name10,
    p_return_value10 => p_return_value10
  );

  ff_utils.exit('run_name_formula');

end run_name_formula;

-------------------------------- get_output -----------------------------------
/*
  NAME
    get_output
  DESCRIPTION
    Allows access to data returned from Fast Formula return variables.
    This one function has to be used for all three data types.
*/

procedure get_output
(
  p_return_name  in varchar2,
  p_return_value out varchar2
) is
begin

  ff_utils.entry('client:get_output (varchar2)');

  -- Call the generic get_output procedure.
  local_get_output(p_return_name, p_return_value);

  ff_utils.exit('client:get_output (varchar2)');

end get_output;

end ff_client_engine;

/
