--------------------------------------------------------
--  DDL for Package BOMPEXPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPEXPL" AUTHID CURRENT_USER as
/* $Header: BOMEXPLS.pls 120.2.12010000.1 2008/07/24 17:14:50 appldev ship $ */
/*#
* This API contains methods to explode BOM based on the module passed.The possible values for module are
* 1-Costing 2-BOM 3-Order Entry and 4-ATO and 5-WSM(When the calling application is WSM then the process will explode subassemblies that are phantom).
* If the module is BOM then exploder in this package is called or if the module
* is Costing or ATO then Costing Exploder is called.The user should first call the exploder_userexit.This method will check the
* verify_flag.It will also check the validity of explosion date and if explosion date is null it will default to sysdate.Then based
* on module option it will call the appropriate exploder method.The parameters used in methods in this API are described below.<BR>
*
* -----------------
*   Parameters
* -----------------
*<pre>
* org_id                            -- Organization Id
* order_by                          -- 1->order by Op seq, Item Seq and 2->Item seq, Op Seq
* grp_id                            -- Unique value to identify current explosion from sequence bom_explosion_temp_s
* session_id                        -- Unique value to identify current session from sequence bom_explosion_temp_session_s
* levels_to_explode                 -- Level in the Structure to which explosion should be done
* bom_or_eng                        -- 1->BOM and 2->ENG
* impl_flag                         -- 1->Implemented Only and 2->Both implemented and unimplemented
* explode_option                    -- Components to be included in explosion 1->All 2->Current 3->Current and Future
* module                            -- Module value 1->Costing 2->BOM 3->Order Entry 4->ATO and 5->WSM(only phantom subassembly)
* cst_type_id                       -- Cost Type Id for costed explosion
* std_comp_flag                     -- 1->Explode only standard components 2->Explode all components
* expl_qty                          -- The quantity of top assembly that we want to explode
* item_id                           -- Item Id of Assembly to explode
* list_id                           -- Unique id for lists in bom_lists for range
* report_option                     -- 1->Cost rollup with report 2->Cost rollup no report 3->Temp cost rollup with report
* cst_rlp_id                        -- Rollup Id
* req_id                            -- Request Id
* prgm_appl_id                      -- Program Application Id
* prg_id                            -- Program Id
* user_id                           -- User Id
* lock_flag                         -- 1->Do not lock the table 2->Lock the table
* alt_rtg_desg                      -- Alternate Routing Designator
* rollup_option                     -- 1->Single Level Rollup 2->Full Rollup
* plan_factor_flag1                 -- 1-> Yes 2-> No
* incl_lt_flag                      -- 1-> Yes 2-> No
* alt_desg                          -- Alternate Bom Designator
* rev_date                          -- Explosion Date (dd-mon-yy hh24:mi)
* comp_code                         -- Concatenated Component Code lpad 16
* Err_Msg                           -- Error Message Out Buffer
* error_code                        -- Error Code Out (returns sql error code if sql error, 9999 if loop detected)
* </pre>
* @rep:scope public
* @rep:product BOM
* @rep:displayname Structure Exploder
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
*/
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPEXPL.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the exploders.
|      This package contains 3 different exploders for the
|      modules it can be called from.  The procedure exploders
|    calls the correct exploder based on the module option.
|    Each of the 3 exploders can be called on directly too.
| Parameters: org_id    organization_id
|   order_by  1 - Op seq, item seq
|       2 - Item seq, op seq
|   grp_id    unique value to identify current explosion
|       use value from sequence bom_explosion_temp_s
|   session_id  unique value to identify current session
|       use value from bom_explosion_temp_session_s
|   levels_to_explode
|   bom_or_eng  1 - BOM
|       2 - ENG
|   impl_flag 1 - implemented only
|       2 - both impl and unimpl
|   explode_option  1 - All
|       2 - Current
|       3 - Current and future
|   module    1 - Costing
|       2 - Bom
|       3 - Order entry
        4 - ATO
|   cst_type_id cost type id for costed explosion
|   std_comp_flag 1 - explode only standard components
|       2 - all components
|   expl_qty  explosion quantity
|   item_id   item id of asembly to explode
|   list_id   unique id for lists in bom_lists for range
|   report_option 1 - cost rollup with report
|       2 - cost rollup no report
|       3 - temp cost rollup with report
|   cst_rlp_id  rollup_id
|   req_id    request id
|   prgm_appl_id  program application id
|   prg_id    program id
|   user_id   user id
|   lock_flag 1 - do not lock the table
|       2 - lock the table
|   alt_rtg_desg  alternate routing designator
|   rollup_option 1 - single level rollup
|       2 - full rollup
|   plan_factor_flag1 - Yes
|       2 - No
|   incl_lt_flag    1 - Yes
|       2 - No
|   alt_desg  alternate bom designator
|   rev_date  explosion date dd-mon-yy hh24:mi
|   comp_code concatenated component code lpad 16
|   err_msg   error message out buffer
|   error_code  error code out.  returns sql error code
|       if sql error, 9999 if loop detected.
| Revision
      Shreyas Shah  creation
  02/10/94  Shreyas Shah  added multi-org capability from bom_lists
        max_bom_levels of all orgs for multi-org
  03/24/94  Shreyas Shah    added 4 to module parameter so that
        if ATO calls it dont commit but if CST
        calls it then commit data
  10/19/95      Robert Yee      Added lead time flags
  06-10-2003  Sreejith Nelloliyil Added arg_expl_type for PLM
| 01-may-2004  Vani Hymavathi   Added a new procedure exploder for PDI
|                                                                           |
+==========================================================================*/

/*#
* This method will check the module value passed and will call the exploder procedure based on the
* module value.The possible values for module are 1-Costing,2-BOM,3-Order Entry,4-ATO and 5-WSM. When the calling application is WSM then the process will explode subassemblies that are phantom.
* It checks the verify_flag to see whether parameters need to be validated.The default value for verify_flag is 0 (TRUE).This method also checks the
* explosion date and if the explosion date is null its defaulted to sysdate.
* @param verify_flag IN This flag indicates whether the parameters have to be validated or not,depending
* on the module
* @param org_id IN Organization id
* @param order_by IN Pass 1 for (Op seq, item seq) and 2  for (Item seq, op seq)
* @param grp_id  IN unique value to identify current explosion use value from sequence
* bom_explosion_temp_s
* @param session_id IN unique value to identify current session use value from
* bom_explosion_temp_session_s
* @param levels_to_explode IN Levels to explode
* @param bom_or_eng IN 1-BOM, 2-ENG, default is 1
* @param impl_flag IN 1 - implemented only , 2 - both impl and unimpl
* @param plan_factor_flag IN 1 - Yes, 2 - No
* @param explode_option IN 1 - All, 2 - Current, 3 - Current and future
* @param module IN 1 - Costing, 2 - Bom,  3 - Order entry, 4 - ATO
* @param cst_type_id IN cost type id for costed explosion
* @param std_comp_flag IN 1 - explode only standard components, 2 - all components
* @param expl_qty IN explosion quantity
* @param item_id IN item id of assembly to explode
* @param alt_desg IN alternate bom designator
* @param comp_code IN concatenated component code lpad 16
* @param rev_date IN explosion date dd-mon-yy hh24:mi
* @param unit_number IN unit number for which the explosion should be done (for unit effective boms)
* @param err_msg OUT error message out buffer
* @param error_code OUT error code out.  returns sql error code if sql error, 9999 if loop detected
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Exploder userexit
*/

PROCEDURE exploder_userexit (
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 2,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  item_id     IN  NUMBER,
  alt_desg    IN  VARCHAR2 DEFAULT '',
  comp_code               IN  VARCHAR2 DEFAULT '',
  rev_date    IN  VARCHAR2,
  unit_number IN  VARCHAR2 DEFAULT '',
  release_option IN NUMBER DEFAULT 0,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER
);

/*#
* This method will do an explosion and then a single level or full cost rollup depending upon the value of rollup_option parameter. This
* method will first insert explosion data into BOM_EXPLOSION_TEMP table and then
* wll call the explode procedure.This method will check the module value passed and will call the exploder procedure based on the
* module value.The possible values for module are 1-Costing,2-BOM,3-Order Entry,4-ATO and 5-WSM(When the calling application is
* WSM then the process will explode subassemblies that are phantom)
* It checks the verify_flag to see whether parameters need to be validated.The default value for verify_flag is 0 (TRUE).This method also checks the
* explosion date and if the explosion date is null its defaulted to sysdate.
* @param verify_flag This flag indicates whether the parameters have to be validated or not,depending
* on the module
* @param org_id IN Organization id
* @param order_by IN Pass 1 for (Op seq, item seq) and 2  for (Item seq, op seq)
* @param list_id IN unique id for lists in bom_lists for range
* @param grp_id IN unique value to identify current explosion use value from sequence
* bom_explosion_temp_s
* @param session_id IN unique value to identify current session use value from
* bom_explosion_temp_session_s
* @param levels_to_explode IN Levels to explode
* @param bom_or_eng IN 1-BOM, 2-ENG, default is 1
* @param impl_flag IN 1 - implemented only , 2 - both impl and unimpl
* @param plan_factor_flag IN 1 - Yes, 2 - No
* @param incl_lt_flag IN 1 - Yes, 2 - No
* @param explode_option IN 1 - All, 2 - Current, 3 - Current and future
* @param module IN 1 - Costing,  2 - Bom,  3 - Order entry, 4 - ATO
* @param cst_type_id IN cost type id for costed explosion
* @param std_comp_flag IN 1 - explode only standard components, 2 - all components
* @param expl_qty IN explosion quantity
* @param report_option IN 1 - cost rollup with report, 2 - cost rollup no report
* 3 - temp cost rollup with report
* @param req_id IN request id
* @param cst_rlp_id IN rollup_id
* @param lock_flag IN 1 - do not lock the table, 2 - lock the table
* @param rollup_option IN 1 - single level rollup, 2 - full rollup
* @param alt_rtg_desg IN alternate routing designator
* @param alt_desg IN alternate bom designator
* @param rev_date IN explosion date dd-mon-yy hh24:mi
* @param err_msg OUT error message out buffer
* @param error_code OUT error code out.Returns sql error code if sql error, 9999 if loop detected
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Explosion Report
*/
PROCEDURE explosion_report(
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
      list_id     IN  NUMBER,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  incl_lt_flag          IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 2,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  report_option   IN  NUMBER DEFAULT 0,
  req_id      IN  NUMBER DEFAULT 0,
  cst_rlp_id    IN  NUMBER DEFAULT 0,
  lock_flag   IN  NUMBER DEFAULT 2,
  rollup_option   IN  NUMBER DEFAULT 2,
  alt_rtg_desg    IN  VARCHAR2 DEFAULT '',
  alt_desg    IN  VARCHAR2 DEFAULT '',
  rev_date    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER
);


/*#
* Explode BOM Method for PDI usage.This exploder will populate trimmed date in the explosion table.
* @param verify_flag This flag indicates whether the parameters have to be validated or not,depending
* on the module
* @param org_id IN Organization id
* @param order_by IN Pass 1 for (Op seq, item seq) and 2  for (Item seq, op seq)
* @param grp_id IN unique value to identify current explosion use value from sequence
* bom_explosion_temp_s
* @param session_id IN unique value to identify current session use value from
* bom_explosion_temp_session_s
* @param levels_to_explode IN Levels to explode
* @param bom_or_eng IN 1-BOM, 2-ENG, default is 1
* @param impl_flag IN 1 - implemented only , 2 - both impl and unimpl
* @param plan_factor_flag IN 1 - Yes, 2 - No
* @param explode_option IN 1 - All, 2 - Current, 3 - Current and future
* @param module IN 1 - Costing,  2 - Bom,  3 - Order entry, 4 - ATO
* @param cst_type_id IN cost type id for costed explosion
* @param std_comp_flag IN 1 - explode only standard components, 2 - all components
* @param expl_qty IN explosion quantity
* @param item_id IN item id of assembly to explode
* @param alt_desg IN alternate bom designator
* @param comp_code IN concatenated component code lpad 16
* @param rev_date IN explosion date dd-mon-yy hh24:mi
* @param unit_number IN unit number for which the explosion should be done (for unit effective boms)
* @param err_msg OUT error message out buffer
* @param error_code OUT error code out.  returns sql error code if sql error, 9999 if loop detected
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Exploder for PDI usage
*/

PROCEDURE explode(
  verify_flag   IN  NUMBER DEFAULT 0,
  org_id      IN  NUMBER,
  order_by    IN  NUMBER DEFAULT 1,
  grp_id      IN  NUMBER,
  session_id    IN  NUMBER DEFAULT 0,
  levels_to_explode   IN  NUMBER DEFAULT 1,
  bom_or_eng    IN  NUMBER DEFAULT 1,
  impl_flag   IN  NUMBER DEFAULT 1,
  plan_factor_flag  IN  NUMBER DEFAULT 2,
  explode_option    IN  NUMBER DEFAULT 1,
  module      IN  NUMBER DEFAULT 2,
  cst_type_id   IN  NUMBER DEFAULT 0,
  std_comp_flag   IN  NUMBER DEFAULT 0,
  expl_qty    IN  NUMBER DEFAULT 1,
  item_id     IN  NUMBER,
  alt_desg    IN  VARCHAR2 DEFAULT '',
  comp_code               IN  VARCHAR2 DEFAULT '',
  rev_date    IN  VARCHAR2,
  unit_number IN  VARCHAR2 DEFAULT '',
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER
);
END bompexpl;

/
