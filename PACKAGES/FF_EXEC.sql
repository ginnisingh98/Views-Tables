--------------------------------------------------------
--  DDL for Package FF_EXEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_EXEC" AUTHID CURRENT_USER as
/* $Header: ffexec.pkh 115.9 2003/01/20 18:10:06 arashid ship $ */
g_debug boolean;
/*
  Notes:
    This version of the execution engine relies on PL/SQL release 2.3
    or later (i.e. it uses PL/SQL tables of records).  Therefore there
    is a separate set of library routines to allow calling formula
    from forms.

    For detailed design notes and examples on how to call the
    execution engine, please see the associated low level design.
    The filename for this is ffrunf.lld and is held under $FF_TOP/lld
    directory.

    Also, please refer to this documentation for explanation of the
    logging strategy for this module, as there are some improvements
    to the normal standard.
*/
/*
 *  Debug level constants.
 *  These values can be used in conjunction with the set_debug
 *  procedure to control debug output from the execution engine.
 */
FF_DBG         constant binary_integer := 2;
FF_CACHE_DBG   constant binary_integer := 4;
DBI_CACHE_DBG  constant binary_integer := 8;
MRU_DBG        constant binary_integer := 16;
IO_TABLE_DBG   constant binary_integer := 32;
FF_BIND_LEN    constant binary_integer := 255;  -- input/return values.

/*
 *  Definition of record to hold inputs to formula.
 *  NOTES:
 *  o This record is used for both contexts and input values.
 *  o This record is instantiated by a call to the init_formula
 *    procedure.
 *  o Dates should be passed in the apps Canonical format.
 *  o The 'datatype' member is used to indicate the datatype of
 *    the input.  It's value should not be set by the caller.
 *  o The 'class' member is used to indicate whether the input
 *    is a context or a formula input.  It's value should not
 *    be set by the caller.
 */
type inputs_r is record
(
  name     varchar2(240),
  datatype varchar2(6),   -- 'DATE', 'NUMBER', 'TEXT'
  class    varchar2(7),   -- 'CONTEXT' or 'INPUT'.
  value    varchar2(255)  -- NOTE: match FF_BIND_LEN
);

/*
 *  Definition of table to hold inputs to formula.
 *  NOTES:
 *  o The index for this table is guaranteed to start at 1
 *    and be contiguous throughout.
 *  o This table is instantiated by a call to the init_formula
 *    procedure.
 */
type inputs_t is table of inputs_r index by binary_integer;

/*
 *  Definition of record to hold outputs from formula.
 *  NOTES:
 *  o This record is instantiated by a call to the init_formula
 *    procedure.
 *  o Dates will be returned in the apps Canonical format.
 *  o The 'datatype' member is used to indicate the datatype of
 *    the output.  It's value should not be set by the caller.
 */
type outputs_r is record
(
  name     varchar2(240),
  datatype varchar2(6),   -- 'DATE', 'NUMBER', 'TEXT'
  value    varchar2(255)  -- NOTE: match FF_BIND_LEN
);

/*
 *  Definition of table to hold outputs to formula.
 *  NOTES:
 *  o The index for this table is guaranteed to start at 1
 *    and be contiguous throughout.
 *  o This table is instantiated by a call to the init_formula
 *    procedure.
 */
type outputs_t is table of outputs_r index by binary_integer;

/*
 *  The following global variables hold the number of contexts,
 *  inputs and outputs required by the currently executing formula.
 *  Therefore, they need to be examined after calling init_formula.
 */
context_count binary_integer;
input_count   binary_integer;
output_count  binary_integer;

------------------------------- reset_caches ----------------------------------
/*
  NAME
    reset_caches
  DESCRIPTION
    Resets the internal caches to their initial states.
*/
procedure reset_caches;


---------------------------- init_formula -------------------------------------
/*
  NAME
    init_formula
  DESCRIPTION
    Initialises data structures for a specific formula.
  NOTES
    The first call to this function initialises the execution engine.
    The input and output tables are initialised by this call so
    that the user knows the names of all the inputs, contexts and
    outputs that they should set/expect to be returned.
*/

procedure init_formula
(
  p_formula_id     in     number,
  p_effective_date in     date,
  p_inputs         in out nocopy ff_exec.inputs_t,
  p_outputs        in out nocopy ff_exec.outputs_t
);

------------------------------ run_formula ------------------------------------
/*
  NAME
    init_formula
  DESCRIPTION
    Uses data structures built up to execute Fast Formula.
  NOTES
    The p_use_dbi_cache parameter controls whether the db
    item cache will be used when executing formulas.  The only
    circumstance where this should be set to 'false' is when
    being called from the API user hooks functionality.
*/

procedure run_formula
(
  p_inputs         in     ff_exec.inputs_t,
  p_outputs        in out nocopy ff_exec.outputs_t,
  p_use_dbi_cache  in     boolean    default true
);

end ff_exec;

 

/
