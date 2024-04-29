--------------------------------------------------------
--  DDL for Package Body FF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_UTILS" as
/* $Header: ffutil.pkb 120.1.12000000.1 2007/01/17 17:53:40 appldev noship $ */
/*
 *  Set debug level.
 */
procedure set_debug
(
  p_debug_level in binary_integer
) is
begin
  -- Simply set the debugging level as appropriate.
  ff_utils.g_debug_level := p_debug_level;
end set_debug;

/*
 *  Raise an assert if 'expression' is FALSE.
 */
procedure assert
(
  p_expression in boolean,
  p_location   in varchar2
) is
begin
  if(not p_expression) then
    hr_utility.set_message(801, 'FFPLU01_ASSERTION_FAILED');
    hr_utility.set_message_token('1', p_location);
    hr_utility.raise_error;
  end if;
end assert;

/*
 *  Function entry.
 */
procedure entry
(
  p_procedure_name in varchar2
) is
begin
  -- Check the debug level.
  -- Unless it has a value set, we simply return.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  -- Now check that the specific debug level has been set.
  if(bitand(g_debug_level, ff_utils.ROUTING) <> 0) then
    -- Tell the world that we have entered a function.
    hr_utility.trace('In  : ' || p_procedure_name);
  end if;

end entry;

/*
 *  Function exit.
 */
procedure exit
(
  p_procedure_name in varchar2
) is
begin
  -- Check the debug level.
  -- Unless it has a value set, we simply return.
  if(ff_utils.g_debug_level is null or ff_utils.g_debug_level = 0) then
    return;
  end if;

  -- Now check that the specific debug level has been set.
  if(bitand(g_debug_level, ff_utils.ROUTING) <> 0) then
    -- Tell the world that we have entered a function.
    hr_utility.trace('Out : ' || p_procedure_name);
  end if;

end exit;

end ff_utils;

/
