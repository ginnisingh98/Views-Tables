--------------------------------------------------------
--  DDL for Package PAY_BAL_ADJUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ADJUST" AUTHID CURRENT_USER as
/* $Header: pybaladj.pkh 120.0.12010000.1 2008/07/27 22:07:57 appldev ship $ */
/*
  Notes:
  o This package defines the public interface to the batch
    balance adjustment process.
  o See the notes for the individual procedures and functions
    below for calling details.  However the overall
    calling sequence is:

    - init_batch
    - (many calls of) adjust_balance
    - process_batch
*/

--------------------------------- init_batch ----------------------------------
/*
  NAME
    init_batch
  DESCRIPTION
    Initialises batch load.
  NOTES
    Must be called before any calls to adjust_balance procedure
    are made.

    This function returns a batch_id value that should be passed
    to subsequent procedures as p_batch_id.

    The consolidation_set_id and payroll_id are required as the entire
    batch has to be processed with the same values.

    The p_batch_mode parameter must be called with either
    STANDARD (the default) - a commit will occur on calling process_batch.
    NO_COMMIT              - no commit will occur on calling process_batch.
*/

function init_batch
(
   p_batch_name           in varchar2 default null,
   p_effective_date       in date,
   p_consolidation_set_id in number,
   p_payroll_id           in number,
   p_action_type          in varchar2 default 'B',   -- for balance adjustment.
   p_batch_mode           in varchar2 default 'STANDARD',
   p_prepay_flag          in varchar2 default 'Y'
) return number;

------------------------------- adjust_balance --------------------------------
/*
  NAME
    adjust_balance
  DESCRIPTION
    Performs the Balance Adjustment.
  NOTES
    If you want to call this procedure, please bear in mind:
    o The procedure assumes that the assignment is assigned to a
      Payroll.
    o The p_batch_id parameter is that obtained from the
      init_batch procedure.
    o The actual balance adjustment is performed by the
      process_batch procedure, not this one.
    o The columns required for the costing of balance adjustments
      are provided on the interface.
    o This procedure does not perform commits.
*/

procedure adjust_balance
(
   p_batch_id                   in  number,
   p_assignment_id              in  number,
   p_element_link_id            in  number,
   --
   -- Element Entry Values Table
   --
   p_num_entry_values           IN  number,
   p_input_value_id_tbl         IN  hr_entry.number_table,
   p_entry_value_tbl            IN  hr_entry.varchar2_table,

   -- Costing information.
   p_balance_adj_cost_flag      in varchar2 default null,
   p_cost_allocation_keyflex_id in number   default null,
   p_attribute_category         in varchar2 default null,
   p_attribute1                 in varchar2 default null,
   p_attribute2                 in varchar2 default null,
   p_attribute3                 in varchar2 default null,
   p_attribute4                 in varchar2 default null,
   p_attribute5                 in varchar2 default null,
   p_attribute6                 in varchar2 default null,
   p_attribute7                 in varchar2 default null,
   p_attribute8                 in varchar2 default null,
   p_attribute9                 in varchar2 default null,
   p_attribute10                in varchar2 default null,
   p_attribute11                in varchar2 default null,
   p_attribute12                in varchar2 default null,
   p_attribute13                in varchar2 default null,
   p_attribute14                in varchar2 default null,
   p_attribute15                in varchar2 default null,
   p_attribute16                in varchar2 default null,
   p_attribute17                in varchar2 default null,
   p_attribute18                in varchar2 default null,
   p_attribute19                in varchar2 default null,
   p_attribute20                in varchar2 default null,
   p_run_type_id                in number   default null,
   p_original_entry_id          in number   default null,
   p_tax_unit_id                in number   default null,
   p_purge_mode                 in boolean  default false
);


procedure adjust_balance
(
   p_batch_id                   in  number,
   p_assignment_id              in  number,
   p_element_link_id            in  number,
   p_input_value_id1            in  number   default null,
   p_input_value_id2            in  number   default null,
   p_input_value_id3            in  number   default null,
   p_input_value_id4            in  number   default null,
   p_input_value_id5            in  number   default null,
   p_input_value_id6            in  number   default null,
   p_input_value_id7            in  number   default null,
   p_input_value_id8            in  number   default null,
   p_input_value_id9            in  number   default null,
   p_input_value_id10           in  number   default null,
   p_input_value_id11           in  number   default null,
   p_input_value_id12           in  number   default null,
   p_input_value_id13           in  number   default null,
   p_input_value_id14           in  number   default null,
   p_input_value_id15           in  number   default null,
   p_entry_value1               in  varchar2 default null,
   p_entry_value2               in  varchar2 default null,
   p_entry_value3               in  varchar2 default null,
   p_entry_value4               in  varchar2 default null,
   p_entry_value5               in  varchar2 default null,
   p_entry_value6               in  varchar2 default null,
   p_entry_value7               in  varchar2 default null,
   p_entry_value8               in  varchar2 default null,
   p_entry_value9               in  varchar2 default null,
   p_entry_value10              in  varchar2 default null,
   p_entry_value11              in  varchar2 default null,
   p_entry_value12              in  varchar2 default null,
   p_entry_value13              in  varchar2 default null,
   p_entry_value14              in  varchar2 default null,
   p_entry_value15              in  varchar2 default null,

   -- Costing information.
   p_balance_adj_cost_flag      in varchar2 default null,
   p_cost_allocation_keyflex_id in number   default null,
   p_attribute_category         in varchar2 default null,
   p_attribute1                 in varchar2 default null,
   p_attribute2                 in varchar2 default null,
   p_attribute3                 in varchar2 default null,
   p_attribute4                 in varchar2 default null,
   p_attribute5                 in varchar2 default null,
   p_attribute6                 in varchar2 default null,
   p_attribute7                 in varchar2 default null,
   p_attribute8                 in varchar2 default null,
   p_attribute9                 in varchar2 default null,
   p_attribute10                in varchar2 default null,
   p_attribute11                in varchar2 default null,
   p_attribute12                in varchar2 default null,
   p_attribute13                in varchar2 default null,
   p_attribute14                in varchar2 default null,
   p_attribute15                in varchar2 default null,
   p_attribute16                in varchar2 default null,
   p_attribute17                in varchar2 default null,
   p_attribute18                in varchar2 default null,
   p_attribute19                in varchar2 default null,
   p_attribute20                in varchar2 default null,
   p_run_type_id                in number   default null,
   p_original_entry_id          in number   default null,
   p_tax_unit_id                in number   default null,
   p_purge_mode                 in boolean  default false
);

-------------------------------- process_batch --------------------------------
/*
  NAME
    process_batch
  DESCRIPTION
    Processes the batch as set up in earlier calls.
  NOTES
    This procedure processes the batch of balance adjustments.
    The batch_id is as obtained from the batch initialisation call
    and passed to the adjustment procedure itself.

    NOTE: this procedure a commits if init_batch was called with
    STANDARD mode (i.e. the default).
*/

procedure process_batch
(
   p_batch_id in number
);

procedure rerun_batch
(
   p_batch_id in number,
   p_busgrpid in number,
   p_effdate in date,
   p_legcode in varchar2,
   p_assignment_action_id in number

);

procedure process_bal_adj
(
   p_ele_type in number,
   p_busgrpid in number,
   p_effdate in date,
   p_legcode in varchar2,
   p_assignment_action_id in number,
   p_assignment_id in number,
   p_balcostflg in varchar2,
   p_costkflx_id in number

);



end pay_bal_adjust;

/
