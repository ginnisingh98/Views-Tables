--------------------------------------------------------
--  DDL for Package GCS_RULES_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_RULES_PROCESSOR" AUTHID CURRENT_USER as
-- $Header: gcserups.pls 120.4 2006/08/14 18:46:24 skamdar noship $

  /*
  ** Type
  **   contextRecord
  ** Purpose
  **   Arg to process_rule, below
  **   Public so callers can declare by referencing here
  */
  TYPE contextRecord is Record (
    eventType        varchar2(1),   -- [A|C] for AD or Consolidation, resp
    eventKey         number,        -- eventType A:transaction_id, C:run_detail_id
    eventCategory    varchar2(50),  -- category_display_code of the rule_id
    parentEntity     number,        -- parent entity id
    childEntity      number,        -- subsidiary entity id
    elimsEntity      number,        -- eliminations entity id
    datasetCode      number,        -- the FEM dataset_code for this hierarchy id
    hierarchy        number,        -- the GCS hierarchy id
    calPeriodId      number,        -- the calendar period
    currencyCode     varchar2(15),  -- the consolidation reporting currency
    relationship     number,        -- the GCS hierarchy relationship id
    runName	     varchar2(240), -- process identifier
    --Bugfix 4928211: Added currency precision to cache it earlier
    currPrecision    number,        -- precision of functional currency
    calPeriodEndDate date,          -- end date of calendar period
    --Bugfix 5103251: Added support for additional balance types
    balanceTypeCode  varchar2(30),   -- balance type code
    --Bugfix 5456211: Added ledger to context information for performance purposes
    ledgerId         number

  );

  TYPE contextTable is Table of contextRecord Index By BINARY_INTEGER;


  /*
  ** Type
  **   ruleDataRecord
  ** Purpose
  **   Arg to process_rule, below
  **   Public so callers can declare by referencing here
  */
  TYPE ruleDataRecord is Record (
    fromPercent      Number,      --Old percentage ownership (AD only)
    toPercent        Number,      --Current percentage owned (AD or CE)
    consideration    Number,      --Monetary value of the deal (AD only)
    netAssetValue    Number       --Monetary value of net assets (AD only)
  );

  TYPE ruleDataTable is Table of ruleDataRecord Index By BINARY_INTEGER;

  /*
  ** Procedure
  **   process_rule
  ** Arguments
  **   p_rule_id        is the rule_id to process
  **   p_stat_flag      indicates whether the rule should run twice,
  **                    once for the currency given in p_context.currencyCode
  **                    and again for STAT currency
  **   p_context        is the context record (see above)
  **   p_rule_data      rule data record (see above)
  ** Synopsis
  **   - Looks up the rule steps
  **   - Resolves the distinct account sets used by the steps
  **   - Executes step formulas using account sets and arg values
  **   - Creates detailed outputs, one for each source account
  **   - Aggregates the outputs across dimensions
  **   - Writes entries to the GCS tables
  **   - Returns 0 for success, 1 for warning and 2 for failure
  **
  ** NOTES:
  **   This routine results in a populated GCS_ENTRIES_GT table with...
  **     - Each rule step's id, name, sequence, formula text, account set
  **       id, name and line number info
  **     - The values for the "from" and "to" side of each dimension set line
  **     - The account balance input amount, where applicable, for each
  **       dimension set line
  **     - The account balance output amount for each dimension set line
  **     - The currency code used for each line
  **
  **   The GCS_ENTRIES_GT will have all the detail info necessary to create
  **   that portion of an execution report related to rule processing.  The
  **   creation of that report is the job of the routine that calls this one.
  */
  Function process_rule (
    p_rule_id        IN       NUMBER,
    p_stat_flag      IN       VARCHAR2,
    p_context        IN       contextRecord,
    p_rule_data      IN       ruleDataRecord
  ) RETURN NUMBER;


  /*
  ** Procedure
  **   process_rule
  ** Arguments
  **   p_rules          is a hash table of rule_ids to process,
  **                    with a record structure that allows each
  **                    rule to have a stat_flag and to return
  **                    an individual result code (see below)
  **   p_context        is a context record (see above)
  **   p_rules_data     table of rule data records (see above)
  ** Synopsis
  **   Loops through the rules table, calling process_rule above
  **   for each rule
  **
  **   Returns 0 for successful execution of all rules
  **           1 for warnings on one or more rules
  **           2 for failure of any single rule
  **           2 if p_rules is empty
  **
  **   NOTE: ALL Rule IDs use the same ruleData and context values!
  **         For example, all rules assume the same ownership percentage
  **         between the parent and child entities, and all are executed
  **         in the context of a single category.
  */

  TYPE ruleParmRecord IS RECORD (
    ruleId   Number,
    result   Number,
    statFlag Varchar2(1));
  TYPE ruleParmsTable Is TABLE Of ruleParmRecord Index By BINARY_INTEGER;

  Function process_rule (
    p_rules          IN OUT NOCOPY   ruleParmsTable,
    p_context        IN              contextRecord,
    p_rules_data     IN              ruleDataTable
  ) RETURN NUMBER;

END GCS_RULES_PROCESSOR;

 

/
