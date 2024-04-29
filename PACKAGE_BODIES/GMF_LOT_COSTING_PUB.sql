--------------------------------------------------------
--  DDL for Package Body GMF_LOT_COSTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_LOT_COSTING_PUB" AS
/*  $Header: GMFPLCRB.pls 120.36.12010000.25 2010/03/09 17:49:57 rpatangy ship $ */

--****************************************************************************************************
--*                                                                                                  *
--* Oracle Process Manufacturing                                                                     *
--* ============================                                                                     *
--*                                                                                                  *
--* Package GMF_LOT_COSTING_PUB                                                                      *
--* ---------------------------                                                                      *
--* This package contains a publically callable procedure ROLLUP_LOT_COSTS together with several     *
--* utility procedures that are called by it. For individual procedures' descriptions, see the       *
--* description in front of each one.                                                                *
--*                                                                                                  *
--* Author: Paul J Schofield, OPM Development EMEA                                                   *
--* Date:   September 2003                                                                           *
--*                                                                                                  *
--* HISTORY                                                                                          *
--* =======                                                                                          *
--* 12-Sep-2003     PJS     Removed p_debug_level parameter in favour of the GMF_CONC_DEBUG profile  *
--*                         option. Also created the audit trail in table GMF_LOT_COST_AUDIT and     *
--*                         removed all code that supported the GMF_RESOURCE_LOT_COST_TXNS table.    *
--*                                                                                                  *
--* 29-Sep-2003     PJS     Added code to support CREI/CRER, TRNI/TRNR, ADJI/ADJR, XFER, OMSO/OPSO   *
--*                         PIPH/PICY transactions                                                   *
--*                                                                                                  *
--* 09-Oct-2003     PJS     Change of direction on storing costs. Currently if a lot is replenished  *
--*                         the cost is updated by calculating an averaged cost of the new and old   *
--*                         quantities and amending the header and details as required. In the new   *
--*                         method we create a new set of costs that contain what the amended costs  *
--*                         would have had in them. The reason is so that the sub-ledger update can  *
--*                         post the cost of a consumption from a lot at the correct cost, based on  *
--*                         the transaction date.                                                    *
--*                                                                                                  *
--* 10-Oct-2003     PJS     More changes, to incorporate burdens on lot costs. If the new burdens    *
--*                         table (GMF_LOT_COST_BURDENS) has an entry for the whse/item/lot/cost     *
--*                         method code then the burden cost is incorporated into that specific lot's*
--*                         costs. If there is an entry against the whse/item/cost method code then  *
--*                         the costs are incorporated into all of the item's lots. A lot that has   *
--*                         specific burdens set up will thus have the item level burdens and the    *
--*                         lot-specific burdens against it in its resulting lot costs.              *
--*                                                                                                  *
--* 05-Nov-2003    umoogala Changes made to use cost_category_id instead of itemcost_class.	     *
--*                         Also, added lot_ctl = 1 condition to where clause while getting items for*
--*			    a passed itemcost_class.						     *
--*                                                                                                  *
--* 10-Nov-2003    PJS      If we encounter a consumption transaction (eg OMSO) but the lot has not  *
--*                         been costed, report an error and skip the transaction.                   *
--*                         Also fixed the cursors that retrieve uncosted transactions as a new      *
--*                         column has been added to the gmf_lot_costed_items table (co_code) and    *
--*                         this created a semi-cartesian join.                                      *
--*                                                                                                  *
--* 17-Nov-2003    PJS      Reinstate the code that handles acquisition costs as it somehow became   *
--*                         lost.                                                                    *
--*                                                                                                  *
--* 17-Nov-2003    umoogala Removed insert into gmf_lot_cost_audit table and replaced with procedure *
--*                         lot_cost_audit which prints to log file when debug profile is set to 3   *
--*			          or more.                                                                 *
--*			    Introduced and used debug level l_debug_level_none/low/medium/high       *
--*			    instead of using numbers.					             *
--*			    The reason for removing audit table is the issues with packaging.        *
--*			    (O/X)DF doesn't support nested table. XDF allows creation, but it doesn't*
--*			    support update or alterations to it. Also, Oracle db itself doesn't      *
--*			    support updates to  nested tables - we need to drop and recreate it.     *
--*                                                                                                  *
--* 21-Nov-2003    umoogala ic_item_mst.lot_costed_flag does not exist. To work around this loaded   *
--*		 	    all lot costed item from gmf_lot_costed_items_flag into lc_item_tab. If  *
--*			    item exists in this table then lot_costed_flag is set to 1 otherwise to 0*
--*			    Called new function is_item_lot_costed to do this in material_cursor.    *
--*                                                                                                  *
--* 30-Nov-2003    umoogala Now passing co_code to main routines ROLLUP_LOT_COSTS and removed        *
--*		 	    calendar_code and user params. Using co_code where ever cldr was used.   *
--*		 	    Also, using cm_mthd_mst.default_lot_cost_mthd for non-lot controlled items*
--*                                                                                                  *
--* 03-Dec-2003    PJS      Moved the code that sets the inventory transaction as 'costed' to after  *
--*                         the main CASE statement, and made it conditional on the return status of *
--*                         whatever procedure was called.                                           *
--*                                                                                                  *
--* 05-Dec-2003    umoogala Enabling process for trial runs. Added flag p_final_run_flag to args list*
--*                         Update lot_costed_ind when flag is set to Y.                             *
--*                                                                                                  *
--* 13-Jan-2004    PJS      Fixed the cursors to cater for the case where a recipe has no routing or *
--*                         no step dependencies set up.                                             *
--*                                                                                                  *
--* 21-Jan-2004    umoogala Bug 3388974: Fixed burdens cursor to pickup burdens.		     *
--*                         Skip global burden for item when lot specific burden is there.           *
--*                                                                                                  *
--* 27-Jan-2004    PJS      Bug 3388699: Amended cursor on cm_cmpt_mtl to retrieve analysis_code     *
--*                         and cost component class successfully when using company as the sole     *
--*                         criterion. Date ranging also added.                                      *
--*                                                                                                  *
--* 29-Jan-2004    PJS      Reworked burdens processing and acquisition cost processing to ensure    *
--*                         correct averaging is always performed. Rescinded some fixes from bug     *
--*                         3388974 as they were redundant and reinstated some code that was taken   *
--*                         out. Look for comments starting 3388974-2                                *
--*                                                                                                  *
--* 10-Feb-2004    PJS      Exchange rates catered for on TRNI/TRNR transactions if the movement is  *
--*                         between companies that use different currencies.                         *
--*                                                                                                  *
--* 11-Feb-2004    PJS      Set the actual_cost_ind in GME_BATCH_HEADER if the program is being run  *
--*                         in 'final' mode.                                                         *
--*                                                                                                  *
--* 12-Feb-2004    PJS      Various changes for bugs 3399618, 3401451, 3397388 and 3397408. These    *
--*                         reported different manifestations of the same problem of either adding   *
--*                         a duplicate row to the gmf_lot_cost_details table (the duplicate was a   *
--*                         burden row that shared the same keys) or a division by zero if there     *
--*                         was no onhand quantity.                                                  *
--*                                                                                                  *
--* 12-Feb-2004    PJS      Changes to prevent multiple updates to a cost header flagged as 'Final'. *
--*                         We now clone the row and the associated details so that the onhand_qty   *
--*                         can be maintained correctly. Also treat batch ingredient lines in the    *
--*                         same was ADJI/R transactions.                                            *
--*                                                                                                  *
--* 17-Feb-2004    PJS      Set the final flag in the cost heder if mode is not draft.               *
--*                                                                                                  *
--* 24-Feb-2004    PJS      Fixed indexing when writing burdens for a CREI                           *
--*                                                                                                  *
--* 25-Feb-2004    PJS      Added burden_ind to gmf_cost_type.                                       *
--*                                                                                                  *
--* 25-Feb-2004    PJS      Added handling for replenishing negative onhand quantities.              *
--*                                                                                                  *
--* 03-Mar-2004    umoogala Bug 3476508: setting status to show normal/warning/error on process req  *
--*			    screen.                                                                  *
--*			    Also, if any error is found in a trx (say, no rsrc cost), now we will    *
--*			    skip all trxns related to that item/lot/whse combination.                *
--*                                                                                                  *
--* 08-Mar-2004    PJS      Changes for bugs 3485915 (receipt uom conversion) and 3476427 (order of  *
--*                         parameters changed)                                                      *
--*                                                                                                  *
--* 09-Mar-2004    PJS      Ignore the orgn_code in the transaction when looking up resource costs   *
--*                         and use ic_whse_mst to find the correct one instead.                     *
--*                                                                                                  *
--* 11-Mar-2004    PJS      Changes to support lot cost adjustments (a pseudo transaction of type    *
--*                         'LADJ'). Also introduced logic to skip transactions for lots that have   *
--*                         failed costing attempts already.                                         *
--*                                                                                                  *
--* 15-Mar-2004    PJS      XFER txns do not use line types of +1 and -1. Use line id instead to     *
--*                         decide 1 => -1, 3 => +1                                                  *
--*                                                                                                  *
--* 17-Mar-2004    PJS      Various issues with cost adjustments. Altered cursors to respect delete  *
--*                         marks and retrieve the item's primary uom. Also avoided in/out clash in  *
--*                         call to create_header. No bug reference.                                 *
--*                                                                                                  *
--* 18-Mar-2004    umoogala Lot Cost Adjustment query fix. Removed ref to gmf_lot_cost_adjustment_dtls*
--*                                                                                                  *
--* 19-Mar-2004    PJS      Bug 3514108 - RMA fixes and Bug 3513668 - Requisitions                   *
--*                                                                                                  *
--* 22-Mar-2004    PJS      Reworked 3485915 and 3476427. Also tightened up error messaging for the  *
--*                         cases where clashing parameters are specified. 3486228 also fixed by     *
--*                         setting the transaction quantity to the residual quantity when a balance *
--*                         is flipped positive again.                                               *
--*                                                                                                  *
--* 24-Mar-2004    umoogala Lot Cost Adjustments. Updating onhand_qty in adjs table. Now trans_id in *
--*			    material txn table is -ve of cost_trans_id.				     *
--*			    Another change to clear old_cost record for each trx being processed.    *
--*                                                                                                  *
--* 25-Mar-2004    PJS      No bug reference. Do not use new_cost_tab elements as the target of an   *
--*                         OUT NOCOPY procedure parameter as a run time error results.              *
--*                                                                                                  *
--* 29-Mar-2004    PJS      BUG 3533452. Change process_batch procedure so that the same merge       *
--*                         procedure is called that other procedures call. Also gross up retrieved  *
--*                         cost by the yield quantity.                                              *
--*                                                                                                  *
--* 29-Mar-2004    umoogala Modified delete_lot_costs to first check item_id instead of category     *
--*                         since item overrides category.					     *
--*                                                                                                  *
--* 30-Mar-2004    PJS      Resolved an arry out of bounds error from 3533452.                       *
--*                                                                                                  *
--* 06-Apr-2004    PJS      Major changes to handle multiple yields from the same step and also to   *
--*                         handle to differing requirements of yields from terminal/non-terminal    *
--*                         steps. Also deleted procedure dump_batch_steps in favour of the lot_     *
--*                         cost_audit variant and tided up the debug lines. Batch changes cover     *
--*                         bug 3548217.                                                             *
--*                                                                                                  *
--* 06-Apr-2004    PJS      Fixed small problem with batches that possess a routing but no step      *
--*                         dependency chain. Now attach all inventory to final step.                *
--*                                                                                                  *
--* 07-Apr-2004    PJS      B3556291 - attach any unassociated ingredients to first step and any     *
--*                         unassociated products to final step                                      *
--*                                                                                                  *
--* 15-Apr-2004    PJS      Various issues with mixed mode accounting in the same batch. Anything    *
--*                         that is not a lot costed (co) product now has its costs subtracted from  *
--*                         the total costs accrued to date before the residual costs are shared     *
--*                         amongst the remaining lot costed products. Also tidied up a bit so that  *
--*                         presets no longer cause GSCC warnings.                                   *
--*                                                                                                  *
--* 16-Apr-2004    PJS      Sub Ledger Update has a problem with the costs generated for batch       *
--*                         yields if the cost(s) have been replenished. To get round this the       *
--*                         calculated costs are stored alongside the merged costs but with a        *
--*                         negated header ID. This is for bug 3578680 and now applies to all lots   *
--*                         that are replenished.                                                    *
--*                                                                                                  *
--* 22-Apr-2004    PJS      Rider to previous change. So as not to degrade the performance of the    *
--*                         SLU process a new column 'new_cost_ind' is being added to the gmf_       *
--*                         material_lot_cost_txns table. If a cost is updated then the indicator    *
--*                         will be set to 1. Null otherwise. This saves a select per transaction in *
--*                         the SLU as most of the time there will not be a new cost.                *
--*                                                                                                  *
--* 05-May-2004    PJS      Reworked the fix for bug 3578680 for TRNI etc.                           *
--*                                                                                                  *
--* 06-May-2004    umoogala Updating gmf_lot_cost_adjustments rows even in trial run for subledger to*
--*                         process. Only in final mode applied_ind is set to 'Y'. No bug was created*
--*                                                                                                  *
--* 25-May-2004    PJS      Bug 3643858. Include delete mark on LADJ cursor.  			     *
--*												     *
--* 19-Aug-2004    Dinesh   Bug# 3831782                                         	             *
--*        Added where clause in the queries in proc rollup_lot_costs to ignore the                  *
--*        Lot Cost Adjustment Records which has no Detail Records(i.e., NULL Adjustment Cost)       *
--*
--* 27-Nov-2004 Dinesh Vadivel Bug# 4004338
--*       Modified the basic INV_TRAN_CURSOR query to order the transactions from ic_tran_pnd table.
--*       Right now if we change a batch actual output qty from 100 to 150, the records in ic_tran_pnd table are
--*       in order as 100, 150 and -100 .
--*      Since our costing logic, needs them in 100,-100 and 150 order inv_tran_Cursor's order_by clause is modified
--*
--* 15-Dec-2004 Dinesh Vadivel Bug# 4053149
--*      Modified the process_batch to handle the various cases for the step dependencies
--*      and to create the virtual row appropriately. Also added new explosion_cursor_ss
--*
--*     Modified the process_reversals to populate the new_cost_ind. modified the call to the
--*     create_material_transaction to pass this new_cost_ind instead of NULL. This field is
--*     being used in SL update posting.
--*
--* 06-Jan-2004 Dinesh Vadivel Bug# 4095937
--*       The Lot Cost Process calculates the Exchg Rate as on the Receipt Header Date
--*        whereas the Subledger uses the "Exchg Rate Date". Modified the Lot Actual Cost Process
--*        to use the rcv_transactions.CURRENCY_CONVERSION_RATE as the Exchg Rate .
--*       This is how we are doing in Actual Costing and Subledger Update
--*
--*  20-Jan-2005 Girish Jha Bug 4094132
--*       We added a new filtering condition in the materials_cursor for handling reversals
--*
--* 28-Jan-2005 Dinesh Vadivel Bug 4057323 - Cost Allocation Factor Enhancement.
--*        Modified code especially in process_batch to use Cost Allocation Factor when the profile
--*        "GMF: Use Cost Alloc Factor in Lot Costing" is set to Yes. Also the cost Allocation factor will
--*         considered only under any of the following cases
--*       1. All the Products have to be yielded at one single step, not necessarily terminal step
--*       2. No Product should be associated to any step.
--*
--* 28-Jan-2005 Dinesh Vadivel - Bug 4149549 - Issue occurs only when debug_level is not 3.
--*      In rollup_lot_costs the initialization of old_cost.onhand_qty has been done inside the
--*      IF(l_debug_level >= debug_level_high)..... So the variable didn't get initialized when the
--*      debug level is not 3.
--*
--*   30-Jan-2005 Dinesh Vadivel Bug# 4152397
--*      Uncommented the code which fetches lot_id into l_lot_id for the lot_no
--*      entered on Lot ACP screen.
--*      Also, the inv_tran_cursor inside "ELSIF l_item_id IS NOT NULL .... "
--*      we have filter only those LADJ transactions for that particular Lot_id if any.
--*
--*   02-Feb-2005 Dinesh Vadivel Bug# 4130869
--*       Modified the Lot_Cost_Cursor to also filter by correct transaction_date
--*
--*  03-Feb-2005 - Bug 4144329 - Dinesh Vadivel - If there is no cost defined for Resource
--*            then don't stop by setting the cost as uncostable. Just give a warning and ignore
--*            the resources.
--*
--*  24-Feb-2005 Dinesh Vadivel Bug# 4177349
--*      When a batch is reversed to WIP, the Lot Cost process fails at process_reversals
--*      Now modified the code to handle the product yielding transactions.
--*      Added process_wip_batch for this purpose. More comments before the procedure
--*      definition
--*   24-Feb-2005 Dinesh Vadivel Bug# 4187891
--*      Cancellation of Inv Xfer has been modified such that it is considered
--*       as if it is an actual transfer where the source and destination warehouses are the same.
--*  24-Feb-2005 Dinesh Vadivel Bug# 4176690
--*      Added a new Date Field in the Lot Cost Process submission screen
--*      All the transactions only upto the Date entered will be considered for Lot Costing.
--*  13-Mar-2005 Dinesh Vadivel Bug# 4227784
--*    - Both these bugs have same code change of replacing l_total_item_qty to actual_line_qty
--*      in process_batch()
--*    - Added NVL clause in process_reversals to avoid "ORA error- Cannot insert NULL into
--*      into TOTAL_TRANS_COST".
--*    - Moved the old_cost.onhand_qty into ELSE part of lot_cost_cursor%FOUND in
--*      rollup_lot_costs(). This is to initialize if there is no record in gmf_lot_costs
--*  19-Apr-2005 Dinesh Bug# 4165614
--*     Passed correct shipped date to book the receive transaction in case of internal orders
--*     Modified argument passing date for process_movements in process_receipts()
--*  28-Apr-2005 WmJohn Harris Bug# 4307381  --  procedure process_batch :
--*     more detailed debug info for 2 msgs 'Unable to convert from ' ... correct subscript in 2nd msg
--*  23-May-2005 Dinesh Vadivel - Bug 4320765 - Modified item_cost_cursor to support warehouse association
--*     functionality for the Alternate Cost Method
--*  31-May-2005 Dinesh Vadivel - Bug 4320765(Part B)
--*     Modified "Explosion_Cursor" to avoid duplicate rows
--*  01-Jun-2005 Sukarna Reddy INCONV changes for release 12.
--*  07-Jun-2006 Anand Thiyagarajan Bug#5285726
--*     Modified Code to remove the references to trans_id in gmf_material_lot_cost_txns table
--*     which caused the lot cost process after a final run to calculate wrong costs
--*  07-Jun-2006 Anand Thiyagarajan Bug#5287514
--*     Modified code to call process_receipts procedure for Purchase Order Return to Vendors
--*     and for PO Receipt corrections, which are similar to the Purchase Order receipts with a +ve or -ve signs
--*  26-Jul-2006 Anand Thiyagarajan Bug#5412410
--*     Modified code in process_lot_split and process_lot_translate to correct the code pertaining to call of
--*     merge_costs procedure and also to correct the value of total trans cost and unit cost being passed to the
--*     create_material_transaction and create_lot_header procedures.
--*  14-Aug-2006 Anand Thiyagarajan Bug#5463200
--*     Modified Code in the Special Charges query to remove po_line_locations_all, changed the
--*     value for include_in_acquisition_cost to "I", used estimated_amount instead of actual
--*     and included MMT table join with RCV_TRANSACTION_ID instead of INV_TRANSACTION_ID
--*   2-Aug-2007 Venkat Ch. Bug 6320304/5953977 - Non-recoverable taxes ME, as part of this
--*     added unit of nonrecoverable tax to the unit cost in process_receipt().
--*   30-Jun-2008 Bug 7215069
--*      Changed ordering for Receipt transactions in inv_tran_cursor. If transactions exist for multiple
--*      document types with same transaction date then first process the receipt transactions.
--*   26-Aug-2008 Pramod B.H. Bug#7306720
--*      Modified the cursor component_class_cursor to handle the issue of LACP considering incorrect
--*      cost component class.
--*   12-Mar-2009 Hari Luthra Bug # 7317270
--*      Modified materials_cursor and many other cursors as part of F.P. fix for bug 7312497
--*   10-Apr-2009 Hari Luthra Bug # 7173679
--*	 Modified delete statment in delete_lot_costs to improve the performance as part of F.P. fix for 11i bug 7159210
--*	21-May-2009 Bug 7249505 HARI LUTHRA
--*	HALUTHRA BUG 7249505 In case of return to vendor process the transaction as an adjustment
--*    21-MAY-2009 Bug 6165255 and BUG 8330088 HARI LUTHRA
--*	 Modified the cursor unassociated_ings_cursor and unassociated_prds_cursor so as to include ingrediant transactions
--*	 which are non lot controlled and also to take the primary qty and primary UOM of item from mtl_material_transactions
--*	and mtl_system_items_b instead of transaction_qty and transaction_uom to avoid the dual_uom issues.
--*    27-MAY-2009 Hari Luthra Bug 5473138/8533290
--*	 Modified item_cost_cursor , item_cost_detail_cursor to avoid issues with cost warehouse assosciation
--*	 Also modified query which picks up all the transactions on the basis of the parameters fed while running Lot Cost Process
--*	 Made changes in this query to handle phantom item issues.
--*      Also modified transaction_type cursor defination to synchronize the changes with the changes made in the query to pick all transaction records
--*    27-JUL-2009 Parag Kanetkar Bug 8687115
--*      Process transactions only for legal entity on request. Delete preliminary lot costs also for
--*      legal entity on request.
--*    27-JUL-2009 Parag Kanetkar Bug 8730374 All items belonging to submitted items cost category get processed
--*      even if request is submitted for just one item. Moreover Procedure ReLoad_Lot_Costed_Items_gt does not load
--*      Items if assigned by category. Modified ReLoad_Lot_Costed_Items_gt to use cost category set up of lot costed items.
--*    30-jul-2009 LCMOPM dev, bug 8642337 LCM-OPM Integration, Modified code to consider LC adjustments in lot cost calculations
--*      1) Added one union query to inv_tran_cursor cursor to load LC adjustments
--*      2) created new procedure process LC adjustments to process actual LC adjustments
--*      3) Added one union to the existsing query in get special charges procedure to process ELCs
--*    22-FEB-2010 Parag Kanetkar Bug 9356358 / 12.1 Bug 9400419 . Transfer_price in MMT is already in receiving org currency.
--*       Use transfer price in MMT to create incoming lot cost in process_movement for receipts of transfers
--*       across different legal entities.
--****************************************************************************************************






  --**********************************************************************************************
  --*                                                                                            *
  --* The procedures in this package share a common set of data structures. The most complex one *
  --* being the l_step_tab table defined as being of type gmf_step_tab. This is a database type  *
  --* that has nested tables in it. Once a batch has been exploded, its steps will be ordered    *
  --* correctly in this table so that the costs of a step can be rolled forward into subsequent  *
  --* steps until we fall off the end of the routing.                                            *
  --*                                                                                            *
  --**********************************************************************************************



    /* INVCONV sschinch Constants representing Transaction source type id */
    PURCHASE_ORDER      CONSTANT PLS_INTEGER  := 1;
    SALES_ORDER         CONSTANT PLS_INTEGER  := 2;
    ACCOUNT             CONSTANT PLS_INTEGER  := 3;
    MOVE_ORDER          CONSTANT PLS_INTEGER  := 4;  -- B 6859710
    BATCH               CONSTANT PLS_INTEGER  := 5;
    ACCOUNT_ALIAS       CONSTANT PLS_INTEGER  := 6;
    INTERNAL_REQ        CONSTANT PLS_INTEGER  := 7;
    INTERNAL_ORDER      CONSTANT PLS_INTEGER  := 8;
    CYCLE_COUNT         CONSTANT PLS_INTEGER  := 9;
    PHYSICAL_INVENTORY  CONSTANT PLS_INTEGER  :=10;
    RMA                 CONSTANT PLS_INTEGER  :=12;
    INVENTORY           CONSTANT PLS_INTEGER  :=13;


    /* INVCONV sschinch Transaction Actions */

    LOT_COST_ADJUSTMENT         CONSTANT PLS_INTEGER :=0;
    ISSUE_FROM_STORES           CONSTANT PLS_INTEGER := 1;
    DIRECT_ORG_TRANSFER         CONSTANT PLS_INTEGER := 3;
    CYCLE_COUNT_ADJUSTMENT      CONSTANT PLS_INTEGER := 4;
    OWNERSHIP_TRANSFER          CONSTANT PLS_INTEGER := 6;
    PHYSICAL_INVENTORY_ADJST    CONSTANT PLS_INTEGER := 8;
    INTRANSIT_RECEIPT           CONSTANT PLS_INTEGER := 12;
    LOGICAL_INTRANSIT_RECEIPT   CONSTANT PLS_INTEGER := 15;
    INTRANSIT_SHIPMENT          CONSTANT PLS_INTEGER := 21;
    LOGICAL_INTRANSIT_SHIPMENT  CONSTANT PLS_INTEGER := 22;
    RECEIPT_INTO_STORES         CONSTANT PLS_INTEGER := 27;
    DELIVERY_ADJUSTMENTS        CONSTANT PLS_INTEGER := 29; /* ANTHIYAG Bug#5287514 07-Jun-2006 */
    LOT_SPLIT                   CONSTANT PLS_INTEGER := 40;
    LOT_MERGE                   CONSTANT PLS_INTEGER := 41;
    LOT_TRANSLATE               CONSTANT PLS_INTEGER := 42;
    LC_ADJUSTMENT               CONSTANT PLS_INTEGER := 50; -- LCM-OPM Integration


    /* INVCONV sschinch FOB flags */
    FOB_SHIPPING   CONSTANT PLS_INTEGER := 1;
    FOB_RECEIVING  CONSTANT PLS_INTEGER := 2;

    l_calendar_code    cm_cldr_hdr.calendar_code%TYPE;
    l_default_cost_type_id NUMBER; /* INVCONV sschinch */
    l_le_id          NUMBER;
    l_cost_type_id      NUMBER;

    --Use this to get the costof non-lot controlled items
    l_default_lot_cstype_id  NUMBER;
    l_cost_method_code  cm_mthd_mst.cost_mthd_code%TYPE;
    l_trans_start_date  cm_mthd_mst.trans_start_date%TYPE;

    --l_cost_class       mtl_categories_v.category_concat_segs%TYPE;
    l_cost_category_id  mtl_categories_v.category_id%TYPE;


    --l_item_no            VARCHAR2(800);
    l_lot_no             mtl_lot_numbers.LOT_NUMBER%TYPE; /* INVCONV sschinch */

    l_debug_level      PLS_INTEGER;
    l_user             fnd_user.user_name%TYPE;
    l_return_status    VARCHAR2(1) := 'S';

    l_final_run_date DATE; -- Bug 4176690


    l_debug_level_none     PLS_INTEGER;
    l_debug_level_low      PLS_INTEGER;
    l_debug_level_medium   PLS_INTEGER;
    l_debug_level_high     PLS_INTEGER;

    TYPE l_cost_tab_type IS TABLE OF SYSTEM.gmf_cost_type INDEX BY PLS_INTEGER;

    old_cost           gmf_lot_costs%ROWTYPE;
    old_cost_tab       l_cost_tab_type; -- Existing lot costs of lot being rolled up

    new_cost           gmf_lot_costs%ROWTYPE;
    new_cost_tab       l_cost_tab_type; -- New lot costs of lot being rolled up

    ing_cost           gmf_lot_costs%ROWTYPE;
    ing_cost_tab       l_cost_tab_type; -- Batch ingredient cost

    prd_cost           gmf_lot_costs%ROWTYPE;
    prd_cost_tab       l_cost_tab_type; -- Batch product cost

    cur_cost_tab       l_cost_tab_type; -- Current costs of batch step

    res_cost           NUMBER;
    item_unit_cost     NUMBER;
    lot_unit_cost      NUMBER;
    lot_total_cost     NUMBER;


    l_rate_type_code   VARCHAR2(4);
    l_from_ccy_code    VARCHAR2(4);
    l_to_ccy_code      VARCHAR2(4);
    l_exchange_rate    NUMBER;
    l_mul_div_sign     NUMBER;
    l_error_status     NUMBER;

    l_lot_number  mtl_lot_numbers.lot_number%type; /* INVCONV sschinch */
    l_source_lot_number mtl_lot_numbers.lot_number%type; /* INVCONV sschinch */
    l_orgn_id NUMBER;

    l_base_ccy_code VARCHAR2(4);  /* Bug 4038722 Dinesh Vadivel */


    l_tmp  BOOLEAN; -- Bug 3476508
    i      PLS_INTEGER; -- Loop counter to sweep through uncosted inventory transactions
    j      PLS_INTEGER;
    k      PLS_INTEGER;
    l      PLS_INTEGER;

    dummy  NUMBER;
    l_item_id          mtl_item_flexfields.inventory_item_id%TYPE;
    l_batchstep_id     NUMBER;
    l_total_qty        NUMBER;
    TYPE num_tab       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE char_tab      IS TABLE OF VARCHAR2(80) INDEX BY VARCHAR2(80); /* INVCONV sschinch */

    TYPE org_tab       IS TABLE OF VARCHAR2(4) INDEX BY BINARY_INTEGER; /* INVCONV sschinch */
    l_org_tab          org_tab;  /* INVCONV sschinch */
    l_cost_mthd_code   cm_mthd_mst.cost_mthd_code%type;
    l_default_cost_mthd cm_mthd_mst.cost_mthd_code%type;

    l_step_lev         num_tab;
    l_step_tab         SYSTEM.gmf_step_tab;
    l_skip_this_batch  BOOLEAN ;
    l_skip_this_txn    BOOLEAN ;
    l_cost_accrued     BOOLEAN ;
    l_batch_status     NUMBER;
    l_cost_factor      NUMBER;
    l_step_index       NUMBER;

    receipt_qty         NUMBER;
    receipt_unit_cost   NUMBER;
    receipt_uom         VARCHAR2(3);
    receipt_ccy         VARCHAR2(4);
    l_residual_qty      NUMBER;
    l_flg_ind           NUMBER;

    component_class_id  cm_cmpt_mst.cost_cmpntcls_id%TYPE;
    cost_analysis_code  cm_alys_mst.cost_analysis_code%TYPE;

    /*l_uncostable_lots_tab num_tab; INVCONV sschinch*/
      /*l_uncostable_lots_tab char_tab;  jboppana */

    TYPE lot_uncostable_lots_tab IS TABLE OF mtl_item_flexfields.inventory_item_id%TYPE INDEX BY VARCHAR2(150);
    l_uncostable_lots_tab        lot_uncostable_lots_tab;


    l_cost_alloc_profile NUMBER; -- Bug 4057323

    TYPE burdens_rec IS RECORD
    (
      LOT_BURDEN_LINE_ID              NUMBER(15)
    , RESOURCES                       VARCHAR2(32)
    , COST_CMPNTCLS_ID                NUMBER(10)
    , COST_ANALYSIS_CODE              VARCHAR2(4)
    , BURDEN_FACTOR                   NUMBER
    , BURDEN_COST                     NUMBER
    );


    TYPE burdens_tab IS TABLE OF burdens_rec;
    l_burdens_tab       burdens_tab;
    l_burden_cost       NUMBER;
    l_burden_costs_tab  l_cost_tab_type;
    l_burdens_total     NUMBER;

    l_acqui_cost_tab    l_cost_tab_type;
    l_acquisitions_total NUMBER;

    l_onhand_qty         NUMBER;
    -- umoogala
    TYPE lot_costed_items_tab IS TABLE OF mtl_item_flexfields.inventory_item_id%TYPE INDEX BY VARCHAR2(64);
    lc_items_tab        lot_costed_items_tab;

    -- WHO columns -- umoogala 05-Dec-2003
    l_user_id		fnd_user.user_id%TYPE;
    l_login_id		NUMBER;
    l_prog_appl_id  	NUMBER;
    l_program_id	NUMBER;
    l_request_id	NUMBER;

    l_routing           NUMBER;
    l_dep_steps         NUMBER;
   -- l_step_items        NUMBER;     /* No where used */
    l_prior_step_id     NUMBER;

    l_final_run_flag	NUMBER(1);   -- 1 for final run and 0 for trial run
    l_lot_cost_flag     NUMBER(1);   -- LCM-OPM Integration, 0 for DRAFT and 1 for FINAL run


/* FORWARD DECLARATIONS INVCONV sschinch */

    --**********************************************************************************************
    --*                                                                                            *
    --* These next few declarations are for the main driving query. The rollup_lot_costs procedure *
    --* is callable in several ways, and, for efficiency, each type of invocation has a dedicated  *
    --* cursor. Each one returns rows of transaction_type (defined below). The rollup_lot_costs    *
    --* procedure examines the parameters passed in and sets up a cursor appropriate to them.      *
    --*
    --* 27-MAY-2009 HARI LUTHRA Bug 8533290/5473138 Modified the transaction_type record defination*
    --* so as to include the three new selece columns in rollup_lot_costs procedure		   *
    --**********************************************************************************************

    TYPE transaction_type  IS RECORD
    ( doc_id            NUMBER
    , transaction_source_type_id  NUMBER(5)
    , inventory_item_id           NUMBER
    , line_id           NUMBER
    , line_type         NUMBER
    , lot_number         VARCHAR2(80)
    , trans_date        DATE
    , transaction_id          NUMBER
    , trans_qty         NUMBER
    , trans_um          VARCHAR2(4)
    , orgn_id           NUMBER
    , source            NUMBER(1)
    , reverse_id        NUMBER
    , transaction_action_id NUMBER(5)
    , transfer_price     NUMBER
    , transportation_cost NUMBER
    , fob_point          NUMBER(1)
    , transfer_transaction_id NUMBER
    , transaction_cost     NUMBER
    , transfer_orgn_id   NUMBER
    , phantom_trans_date  DATE
    , phantom_type       NUMBER
    , pair_type          NUMBER
    , oc1                DATE
    , oc2                NUMBER
    , oc3                NUMBER
    );

    TYPE inv_tran_cursor_type IS REF CURSOR RETURN transaction_type;

    transaction_row transaction_type;

    /* INVCONV sschinch */
    TYPE child_lots_rec  IS RECORD
    ( lot_number VARCHAR2(80),
      trans_qty  NUMBER,
      trans_date DATE
    );
    child_lot_row  child_lots_rec;


    --**********************************************************************************************
    --*                                                                                            *
    --* This, rather complex, cursor explodes the batch routing and orders the steps in an order   *
    --* suitable for the rollup. This is not necessarily the same as the ordering implied by the   *
    --* step dependencies. The terminal step(s) of the routing are found and then a heirarchical   *
    --* sub-query generates the base rows (that are added to by other parts of the query) ordered  *
    --* by distance from the terminal step(s).                                                     *
    --*                                                                                            *
    --* The explosion handles linear, converging, diverging and parallel route sections and works  *
    --* with any arbitrary routing step dependence topology, with the important exception of loops *
    --* as this introduces a 'feedback' loop.                                                      *
    --*                                                                                            *
    --* Each row retrieved consists of a nested table of step-related data, which itself consists  *
    --* of several nested tables so that we have a resulting structure as follows:                 *
    --*                                                                                            *
    --* Table of steps                                                                             *
    --*   Each step consists of step_id, step_qty, step_uom, output_qty                            *
    --*                         table of inherited costs,                                          *
    --*                         table of current costs                                             *
    --*                         table of step costs (= inherited + current)                        *
    --*                         table of material txns                                             *
    --*                         table of resource txns                                             *
    --*                         table of steps that follow this step                               *
    --*                                                                                            *
    --*   Each inherited cost consists of cost component class, cost analysis code, level and cost *
    --*                                                                                            *
    --*   Each current cost has the same format as an inherited cost                               *
    --*                                                                                            *
    --*   Each material transaction consists of data from ic_tran_pnd and a cost table which is    *
    --*   in the same format as the inherited costs                                                *
    --*                                                                                            *
    --*   Each resource transaction consists of data from gme_resource_txns and a cost table which *
    --*   which is in the same format as the inherited costs                                       *
    --*                                                                                            *
    --*   Each step dependency consists of inherited step qty, step_qty_uom and the index of the   *
    --*   dependent step in the structure.                                                         *
    --*                                                                                            *
    --*   This entire structure is dumped to the gmf_lot_cost_audit table when a lot's cost has    *
    --*   been generated.                                                                          *
    --**********************************************************************************************
    --* NOTE: The columns in gmf_step_dependencies are a bit ambiguous. The dep_step_id is better  *
    --* thought of as 'prior_step_id' as it is the one on which the (current) batchstep_id depends *
    --**********************************************************************************************


    CURSOR explosion_cursor
    ( p_batch_id NUMBER )
    IS
      SELECT  max(grsd.seq)
      , SYSTEM.gmf_step_type
        ( grsd.dep_step_id, gbs.actual_step_qty, gbs.step_qty_um, 0
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , NULL, NULL
        , CAST
          ( MULTISET
            (
              SELECT SYSTEM.gmf_dependency_type(a.batchstep_id, b.actual_step_qty, b.step_qty_um, NULL)
              FROM   gme_batch_step_dependencies a, gme_batch_steps b
              WHERE  a.batch_id = p_batch_id and a.dep_step_id = grsd.dep_step_id
              AND    a.batchstep_id = b.batchstep_id
              AND    a.batch_id = b.batch_id
            ) AS SYSTEM.gmf_dependency_tab
          )
        )
      FROM
      (
        SELECT MAX(level) seq, dep_step_id, batchstep_id
        FROM   gme_batch_step_dependencies
        START WITH batch_id = p_batch_id
        AND   batchstep_id NOT IN (SELECT dep_step_id FROM gme_batch_step_dependencies WHERE batch_id=p_batch_id)
        CONNECT BY PRIOR dep_step_id = batchstep_id AND batch_id = PRIOR batch_id
        GROUP BY dep_step_id, batchstep_id
      ) grsd
      , gme_batch_steps gbs
      WHERE gbs.batch_id = p_batch_id
      AND   gbs.batchstep_id = grsd.dep_step_id
      GROUP BY  grsd.dep_step_id, gbs.actual_step_qty, gbs.step_qty_um
      UNION ALL
      SELECT 0
      , SYSTEM.gmf_step_type
        ( g.batchstep_id, g.actual_step_qty, g.step_qty_um, 0
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , NULL, NULL
        , CAST
          ( MULTISET
            (
              SELECT SYSTEM.gmf_dependency_type(NULL, NULL, NULL, NULL)
              FROM   DUAL
            ) AS SYSTEM.gmf_dependency_tab
          )
        )
      FROM
      ( SELECT DISTINCT/*Bug 4320765*/ gbsd.batchstep_id, gbs2.actual_step_qty, gbs2.step_qty_um
        FROM gme_batch_step_dependencies gbsd
      ,      gme_batch_steps gbs2
      WHERE  gbsd.batch_id = p_batch_id
      AND    gbs2.batch_id = p_batch_id
      AND    gbsd.batchstep_id NOT IN
             (SELECT dep_step_id from gme_batch_step_dependencies where batch_id = p_batch_id)
      AND    gbsd.batchstep_id = gbs2.batchstep_id ) g
      ORDER BY 1 desc;
    --**********************************************************************************************
    --                                                                                             *
    -- This cursor does pretty much the same thing as above, but caters for the situation where    *
    -- the recipe does not have a routing. We simply create a ficticious step (0) and attach all   *
    -- materials and their transactions and costs to it. The _nr suffix means 'No Routing'         *
    --                                                                                             *
    --**********************************************************************************************

    CURSOR explosion_cursor_nr
    IS
      SELECT 0
      , SYSTEM.gmf_step_type
        ( 1, 0, NULL, 0
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , CAST
          ( MULTISET
            ( SELECT SYSTEM.gmf_cost_type( 0, ' ', 0, 0, 0)
              FROM   DUAL
            ) AS SYSTEM.gmf_cost_tab
          )
        , NULL, NULL
        , CAST
          ( MULTISET
            (
              SELECT SYSTEM.gmf_dependency_type(NULL, NULL, NULL, NULL)
              FROM   DUAL
            ) AS SYSTEM.gmf_dependency_tab
          )
        )
      FROM DUAL;


   --**********************************************************************************************
    --*                                                                                                                                                         *
    --* Cursor to retrieve step from a SINGLE STEP BATCH which obviously                            *
    --* will not have any dependency associated                                                                              *
    --*                                                                                                                                                         *
    --**********************************************************************************************
      CURSOR explosion_cursor_ss(p_batch_id NUMBER)
      IS
         SELECT 0,
          SYSTEM.gmf_step_type
             (gbs.batchstep_id,
              gbs.actual_step_qty,
              gbs.step_qty_um,
              0,
              CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ),
              CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ),
              CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ),
              NULL,
              NULL,
              CAST
                 (MULTISET (SELECT SYSTEM.gmf_dependency_type (NULL, NULL, NULL, NULL)
                              FROM DUAL) AS SYSTEM.gmf_dependency_tab
                 )
             )
         FROM gme_batch_steps gbs
         WHERE gbs.batch_id = p_batch_id  ;


    --**********************************************************************************************
    --*                                                                                            *
    --* Cursor to retrieve steps that have not been set up in a dependency chain                   *
    --*                                                                                            *
    --**********************************************************************************************

    CURSOR steps_cursor (p_batch_id NUMBER)
    IS
     SELECT batchstep_no, batchstep_id
     FROM   gme_batch_steps
     WHERE  batch_id = p_batch_id
     ORDER  by batchstep_no;

    --***************************************************************************************************************
    --*                                                                                            *
    --* Cursor to retrieve all material transactions for a given batch step.                       *
    --*                                                                                            *
    --* This cursor would ideally be nested inside the above cursor, but SQL syntax does not allow *
    --* an order by clause in a subquery, and we need to have the transactions ordered by date     *
    --*                                                                                            *
    --* umoogala: ic_item_mst.lot_costed_flag does not exist. To work around this loaded all lot   *
    --* costed item from gmf_lot_costed_items_flag into lc_item_tab. If item exists in this table  *
    --* then lot_costed_flag is set to 1 otherwise to 0.                                           *
    --*
    --* Girish - Bug 4094132 Modified this materials cursor NOT IN clause to add  lot_id and reverse_id
    --*  Since we are filtering the query using "NOT IN" the product yielded into multiple lots
    --*  is not costed correctly. So added this condition.
    --*
    --* Dinesh Vadivel - Bug 4057323 - Added Cost Allocation Factor value in the select clause
    --* prasad marada bug 7409599 getting distinct resource costs for the cost component class,
    --*               analysis code combination, modified cursor resource_cost_cursor
    --**************************************************************************************************************

CURSOR materials_cursor
    ( p_batch_id        NUMBER
    , p_batchstep_id    NUMBER
    )
    IS
      SELECT SYSTEM.gmf_matl_type
             (mmt.transaction_id,
              hoi.org_information2,
              mmt.organization_id,
              mmt.inventory_item_id,
              mtln.lot_number,
              gmd.line_type,
              NVL(mtln.primary_quantity, mmt.primary_quantity), -- B9131983 used NVL
              iimb.primary_uom_code,
              mmt.transaction_date,
	            decode(is_item_lot_costed(iimb.organization_id,iimb.inventory_item_id), iimb.inventory_item_id, 1, NULL, 0, 0),
              gmd.contribute_step_qty_ind,
              0,
              gmd.plan_qty,
              gmd.actual_qty,
              gmd.dtl_um,
               CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ), -- Bug 7317270,
              gmd.cost_alloc
             )
      FROM  mtl_system_items_b iimb,
            mtl_material_transactions mmt,
            gme_batch_step_items gbsi,
            gme_material_details gmd,
            mtl_transaction_lot_numbers mtln,
            mtl_parameters mp,
            hr_organization_information hoi,
            gme_transaction_pairs gtp
      WHERE gbsi.batch_id = p_batch_id
      AND   gbsi.batchstep_id = p_batchstep_id
      AND   mp.organization_id = mmt.organization_id
      AND   hoi.organization_id = mmt.organization_id
      AND   hoi.org_information_context = 'Accounting Information'
      AND   gbsi.material_detail_id = mmt.trx_source_line_id
      AND   mmt.transaction_id = mtln.transaction_id (+)
      AND   mmt.transaction_source_type_id = 5  /* Production */
      AND   mmt.transaction_quantity   <> 0
      AND   mmt.inventory_item_id      = iimb.inventory_item_id
      AND   mmt.organization_id        = iimb.organization_id
      AND   mmt.transaction_date      <= l_final_run_date
      AND   gmd.batch_id               = p_batch_id
      AND   gmd.material_detail_id     = gbsi.material_detail_id
      AND   mmt.transaction_id = gtp.transaction_id1 (+)
      AND   NOT (mmt.inventory_item_id = transaction_row.inventory_item_id
                 AND mmt.transaction_id  <> transaction_row.transaction_id
                 AND mtln.lot_number = transaction_row.lot_number
                 AND gtp.transaction_id2 IS NOT NULL )
       ORDER BY mmt.transaction_date, gmd.line_type,
                 DECODE (gmd.line_type,1, DECODE ((  ABS (DECODE (mmt.transaction_quantity, 0, 1, mmt.transaction_quantity))
                             / DECODE (mmt.transaction_quantity, 0, 1, mmt.transaction_quantity)
                            ),
                            1, mmt.transaction_id,
                            DECODE (gtp.transaction_id2,
                                    NULL, mmt.transaction_id,
                                    gtp.transaction_id2 + .5
                                   )
                           ),
                   mmt.transaction_id
                   ), mtln.lot_number ;        -- B9131983

    /*HALUTHRA BUG 6165255 changed from mmt.transaction_quantity to mmt.primary_quantity and from
mmt.transaction_uom to iimb.primary_uom_code to avoid dual uom issue*/
    /* HALUTHRA BUG 8330088 Added the join condition in mtln case so as to include the records for non lot controlled
    items . also changed from mtln.transaction_date to Decode(mtln.transaction_date,null,mmt.transaction_date,mtln.transaction_date)
    so that date gets populated in case the item is non lot controlled. */

    CURSOR unassociated_ings_cursor
    ( p_batch_id       NUMBER
    )
    IS
      SELECT SYSTEM.gmf_matl_type
             ( mmt.transaction_id,
               hoi.org_information2,
               mmt.organization_id,
               mmt.inventory_item_id,
               mtln.lot_number,
               gmd.line_type,
               NVL(mtln.primary_quantity, mmt.primary_quantity), -- B9131983 used NVL
               iimb.primary_uom_code, --mmt.transaction_uom,
               Decode(mtln.transaction_date,null,mmt.transaction_date,mtln.transaction_date),--mtln.transaction_date,
	             decode(is_item_lot_costed(iimb.organization_id,iimb.inventory_item_id), iimb.inventory_item_id, 1, NULL, 0, 0),
               gmd.contribute_step_qty_ind,
               0,
               gmd.plan_qty,
               gmd.actual_qty,
               gmd.dtl_um,
                CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ), -- Bug 7317270
               gmd.cost_alloc
             )
      FROM  mtl_system_items_b iimb,
            mtl_material_transactions mmt,
            gme_material_details gmd,
            mtl_transaction_lot_numbers mtln,
            mtl_parameters mp,
            hr_organization_information hoi
      WHERE mmt.transaction_source_type_id = 5
      AND   gmd.line_type IN (-1,2)
      AND   mtln.transaction_quantity(+) <> 0
      AND   mmt.transaction_id = mtln.transaction_id(+)
      AND   mmt.organization_id = hoi.organization_id
      AND   hoi.org_information_context = 'Accounting Information'
      AND   mmt.organization_id = mp.organization_id
      AND   iimb.inventory_item_id = mmt.inventory_item_id
      AND   iimb.organization_id  = mmt.organization_id
      AND   gmd.batch_id = p_batch_id
      AND   mmt.trx_source_line_id = gmd.material_detail_id
      AND   gmd.material_detail_id NOT IN
            (SELECT material_detail_id FROM gme_batch_step_items
             WHERE  batch_id = p_batch_id);


    /*HALUTHRA BUG 6165255 changed from mmt.transaction_quantity to mmt.primary_quantity and from
mmt.transaction_uom to iimb.primary_uom_code to avoid dual uom issue*/
    /* HALUTHRA BUG 8330088 Added the join condition in mtln case so as to include the records for non lot controlled
    items . also changed from mtln.transaction_date to Decode(mtln.transaction_date,null,mmt.transaction_date,mtln.transaction_date)
    so that date gets populated in case the item is non lot controlled. */

     CURSOR unassociated_prds_cursor
    ( p_batch_id       NUMBER
    )
    IS
      SELECT SYSTEM.gmf_matl_type
             ( mmt.transaction_id,
               hoi.org_information2,
               mmt.organization_id,
               mmt.inventory_item_id,
               mtln.lot_number,
               gmd.line_type,
               NVL(mtln.primary_quantity, mmt.primary_quantity), -- B9131983 used NVL
               iimb.primary_uom_code, --mmt.transaction_uom,
               Decode(mtln.transaction_date,null,mmt.transaction_date,mtln.transaction_date),--mtln.transaction_date,
	             decode(is_item_lot_costed(iimb.organization_id,iimb.inventory_item_id), iimb.inventory_item_id, 1, NULL, 0, 0),
               gmd.contribute_step_qty_ind,
               0,
               gmd.plan_qty,
               gmd.actual_qty,
               gmd.dtl_um,
                  CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ), -- Bug 7317270
               gmd.cost_alloc
             )
      FROM  mtl_system_items_b iimb,
            mtl_material_transactions mmt,
            gme_material_details gmd,
            mtl_transaction_lot_numbers mtln,
            hr_organization_information hoi
      WHERE mmt.transaction_source_type_id = 5
      AND   gmd.line_type = 1
      AND   mtln.transaction_quantity(+) <> 0
      AND   mmt.transaction_id = mtln.transaction_id(+)
      AND   mmt.organization_id = hoi.organization_id
      AND   hoi.org_information_context = 'Accounting Information'
      AND   iimb.inventory_item_id = mmt.inventory_item_id
      AND   iimb.organization_id  = mmt.organization_id
      AND   gmd.batch_id = p_batch_id
      AND   mmt.trx_source_line_id = gmd.material_detail_id
      AND   gmd.material_detail_id NOT IN
            (SELECT material_detail_id FROM gme_batch_step_items
             WHERE  batch_id = p_batch_id);


CURSOR materials_cursor_nr
    ( p_batch_id        NUMBER
    )
    IS
      SELECT SYSTEM.gmf_matl_type
             ( mmt.transaction_id,
               l_le_id,
               mmt.organization_id,
               mmt.inventory_item_id,
               mtln.lot_number,
               gme.line_type,
               NVL(mtln.primary_quantity, mmt.primary_quantity), -- B9131983 used NVL
               iimb.primary_uom_code,
               mmt.transaction_date,
	             decode(is_item_lot_costed(mmt.organization_id,iimb.inventory_item_id), iimb.inventory_item_id, 1, NULL, 0, 0),
               gme.contribute_step_qty_ind,
               0,
               gme.plan_qty,
               gme.actual_qty,
               gme.dtl_um,
                  CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ), -- Bug 7317270
               gme.cost_alloc
             )
      FROM  mtl_system_items_b iimb,
            mtl_material_transactions mmt,
            gme_material_details gme,
            mtl_transaction_lot_numbers mtln,
            gme_transaction_pairs gtp
      WHERE mmt.trx_source_line_id = gme.material_detail_id
           AND   mmt.transaction_source_type_id = 5  /* Rajesh B8290451 */
           AND   mmt.transaction_source_id=gme.batch_id-- added by Francisco 23 Feb 2009
           AND   gme.batch_id = p_batch_id
           AND   mmt.transaction_quantity <> 0
           AND   mmt.inventory_item_id = iimb.inventory_item_id
           AND   mmt.organization_id = iimb.organization_id
           AND   mmt.transaction_date <= l_final_run_date
           AND   mmt.transaction_id = mtln.transaction_id (+)
           AND   mmt.transaction_id = gtp.transaction_id1 (+)
           AND   gtp.batch_id (+) = p_batch_id
           AND   NOT (mmt.inventory_item_id = transaction_row.inventory_item_id
                 AND gme.line_type = transaction_row.line_type
                 AND mmt.transaction_id  <> transaction_row.transaction_id
                 AND mtln.lot_number = transaction_row.lot_number
		            AND gtp.transaction_id2 IS NOT NULL )
      ORDER BY mmt.transaction_date, gme.line_type,
                   DECODE (gme.line_type,
                   1, DECODE ((  ABS (DECODE (mmt.transaction_quantity, 0, 1, mmt.transaction_quantity))
                             / DECODE (mmt.transaction_quantity, 0, 1, mmt.transaction_quantity)
                            ),
                            1, mmt.transaction_id,
                            DECODE (gtp.transaction_id2,
                                    NULL, mmt.transaction_id,
                                    gtp.transaction_id2 + .5
                                   )
                           ),
                   mmt.transaction_id
                   ), mtln.lot_number;       -- B9131983


    --**********************************************************************************************
    --*                                                                                            *
    --* Cursor to retrieve all resource transactions for a given batch step.                       *
    --*                                                                                            *
    --* This cursor should also be nested inside the above cursor, but SQL syntax does not allow   *
    --* an order by clause in a subquery, and we need to have the transactions ordered by date     *
    --*                                                                                            *
    --**********************************************************************************************


   CURSOR resources_cursor
    ( p_batch_id         NUMBER
    , p_batchstep_id     NUMBER
    )
    IS
      SELECT SYSTEM.gmf_rsrc_type
             ( grt.poc_trans_id,
               grt.organization_id,
               grt.resources,
               grt.resource_usage,
               grt.trans_qty_um,
               grt.trans_date,
               0,
                  CAST (MULTISET (SELECT SYSTEM.gmf_cost_type (0, ' ', 0, 0, 0)
                                FROM DUAL) AS SYSTEM.gmf_cost_tab
                   ) -- Bug 7317270
             )
      FROM   gme_resource_txns grt,
             gme_batch_step_resources gbsr
      WHERE  gbsr.batch_id = p_batch_id
      AND    gbsr.batchstep_id = p_batchstep_id
      AND    gbsr.batchstep_resource_id = grt.line_id
      AND    grt.doc_type = 'PROD'
      AND    grt.doc_id = p_batch_id
      AND    grt.completed_ind = 1
      AND    grt.resource_usage <> 0
      ORDER BY grt.trans_date;

    --**********************************************************************************************
    --*                                                                                            *
    --* Cursors to retrieve the cost of a lot in the organization specified.                          *
    --*                                                                                            *
    --**********************************************************************************************


 CURSOR lot_cost_cursor
    ( p_orgn_id     NUMBER
    , p_item_id     NUMBER
    , p_lot_number  VARCHAR2
    , p_trans_date DATE
    , p_cost_type_id NUMBER
    )
    IS
      SELECT *
      FROM  gmf_lot_costs glc
      WHERE glc.lot_number        = p_lot_number
      AND   glc.inventory_item_id = p_item_id
      AND   glc.organization_id   = p_orgn_id
      AND   glc.cost_type_id      = p_cost_type_id
      AND   glc.cost_date        <= NVL(p_trans_date, glc.cost_date)
      ORDER BY header_id desc
    ;

    CURSOR lot_cost_detail_cursor
    ( p_header_id  NUMBER )
    IS
      SELECT SYSTEM.gmf_cost_type
             ( glcd.cost_cmpntcls_id,
               glcd.cost_analysis_code,
               glcd.cost_level,
               glcd.component_cost,
               0    -- B9131983 Burden_ind
             )
      FROM  gmf_lot_cost_details glcd
      WHERE glcd.header_id = p_header_id;

    --**********************************************************************************************
    --*                                                                                            *
    --* Cursors to retrieve the standard cost of an item in the organization specified.               *
    --* umoogala: passing co_code instead of calendar_code. Also, joined with cldr_hdr.            *
    --* Dinesh Vadivel - Bug 4320765 - Modified item_cost_cursor to support warehouse association
    --*   functionality for the Alternate Cost Method
    --* Hari Luthra - Bug 8533290/5473138 Modified item_cost_cursor and item_cost_detail_cursor to avoid issues in case of
    --* multiple cost warehouse assosciation. Added an outer join with cstw.eff_start_date and
    --* cstw.eff_end_date as well.
    --**********************************************************************************************

 CURSOR item_cost_cursor
    ( p_le_id	    	 NUMBER
    , p_cost_type_id NUMBER
    , p_orgn_id      NUMBER
    , p_item_id      VARCHAR2
    , p_date         DATE
    )
    IS
      SELECT sum(cst.cmpnt_cost)
      FROM   cm_cmpt_dtl cst,
             gmf_period_statuses gps
      WHERE  gps.legal_entity_id  = p_le_id
      AND    gps.cost_type_id     = p_cost_type_id
      AND    gps.start_date      <= p_date
      AND    gps.end_date        >= p_date
      AND    gps.period_id        = cst.period_id
      AND    cst.organization_id  = (SELECT NVL (cstw.cost_organization_id, invw.organization_id)
                                                 FROM cm_whse_asc cstw, mtl_parameters invw
                                                 WHERE cstw.organization_id(+) = invw.organization_id
                                                    AND invw.organization_id = p_orgn_id
                                                    AND NVL(cstw.eff_start_date(+),p_date) <= p_date -- HALUTHRA Bug 5473138/8533290
                                                    AND NVL(cstw.eff_end_date(+),p_date) >= p_date   -- HALTURHA Bug 5473138/8533290
                                                    AND cstw.delete_mark (+) = 0)
      AND    cst.inventory_item_id = p_item_id
      AND    cst.delete_mark = 0
      AND    gps.delete_mark = 0;


 -- Bug 8867177  rollup all costs at this level
CURSOR item_cost_detail_cursor
    ( p_le_id		    NUMBER
    , p_cost_type_id NUMBER
    , p_orgn_id      NUMBER
    , p_item_id          VARCHAR2
    , p_date             DATE
    )
    IS
      SELECT SYSTEM.gmf_cost_type
             (cstdtl.cost_cmpntcls_id,
              cstdtl.cost_analysis_code,
              cstdtl.cost_level,
              cstdtl.cmpnt_cost,
              0
             )
	  FROM
 	       (SELECT cst.cost_cmpntcls_id,
 	               cst.cost_analysis_code,
 	               0 cost_level,
 	               SUM(cst.cmpnt_cost) cmpnt_cost
      FROM   cm_cmpt_dtl cst,
             gmf_period_statuses gps
      WHERE  gps.legal_entity_id = p_le_id
       AND   gps.cost_type_id = p_cost_type_id
       AND   gps.start_date <= p_date
      AND    gps.end_date >= p_date
      AND    cst.cost_type_id = p_cost_type_id
      AND    gps.period_id = cst.period_id
      AND    cst.organization_id =
                        (SELECT NVL (cstw.cost_organization_id, invw.organization_id)
                                                FROM cm_whse_asc cstw, mtl_parameters invw
                                                WHERE cstw.organization_id(+) = invw.organization_id
                                                  AND invw.organization_id = p_orgn_id
                                                  AND NVL(cstw.eff_start_date(+),p_date) <= p_date -- HALUTHRA Bug 5473138/8533290
                                                  AND NVL(cstw.eff_end_date(+),p_date) >= p_date -- HALUTHRA Bug 5473138/8533290
                                                  AND cstw.delete_mark (+) = 0)
      AND    cst.inventory_item_id = p_item_id
      AND    cst.delete_mark = 0
      AND    gps.delete_mark = 0
	  Group by cst.cost_cmpntcls_id, cst.cost_analysis_code ) cstdtl
    ;
    --**********************************************************************************************
    --*                                                                                            *
    --* Cursor to retrieve the cost of a resource.                                                 *
    --* umoogala: passing co_code instead of calendar_code. Also, joined with cldr_hdr.            *
    --*                                                                                            *
    --**********************************************************************************************

    -- Bug 7409599 added distinct below

   CURSOR resource_cost_cursor
    ( p_le_id         NUMBER
    , p_cost_type_id   NUMBER
    , p_resources      VARCHAR2
    , p_orgn_id        NUMBER
    , p_date             DATE
    , p_batch_id         NUMBER
    , p_batchstep_id     NUMBER
    )
    IS
    SELECT  SYSTEM.gmf_cost_type
               (gct.cost_cmpntcls_id,
                gct.cost_analysis_code,
                0,
                gct.nominal_cost,
                0)
    FROM (SELECT DISTINCT gbsr.cost_cmpntcls_id,  --used the distinct bug 7409599, pmarada
                gbsr.cost_analysis_code,
                0,
                cst.nominal_cost,
                0
          FROM  cm_rsrc_dtl cst
               ,gmf_period_statuses gps
               ,gme_batch_step_resources gbsr
         WHERE  gps.legal_entity_id = p_le_id
           AND    gps.cost_type_id = p_cost_type_id
           AND    gps.start_date <= p_date
           AND    gps.end_date >= p_date
           AND    cst.period_id = gps.period_id
           AND    cst.organization_id = p_orgn_id
           AND    cst.resources = p_resources
           AND    cst.delete_mark = 0
           AND    gps.delete_mark = 0
           AND    gbsr.batch_id = p_batch_id
           AND    gbsr.batchstep_id = p_batchstep_id
           AND    gbsr.resources = p_resources
         ) gct ;

    --**********************************************************************************************
    --*                                                                                            *
    --* Cursor to retrieve the default cost component class and analysis code for a received item  *
    --* umoogala: replaced itemcost_class with cost_category_id 				   *
    --*                                                                                            *
    --* Bug 3388699: Added the IS NULL and date clauses for retrieval using company                *
    --**********************************************************************************************

    CURSOR component_class_cursor
    ( p_le_id NUMBER
     ,p_item_id    NUMBER
     ,p_orgn_id     NUMBER
     ,p_date       DATE
    )
    IS
      SELECT a.mtl_cmpntcls_id,
             a.mtl_analysis_code, 1
        FROM cm_cmpt_mtl a
      WHERE (legal_entity_id = p_le_id OR legal_entity_id IS NULL)
        AND inventory_item_id = p_item_id
        AND (organization_id = p_orgn_id OR organization_id IS NULL)
        AND p_date BETWEEN eff_start_date AND eff_end_date
        AND a.delete_mark = 0
      UNION
      SELECT b.mtl_cmpntcls_id, b.mtl_analysis_code, 2
      FROM cm_cmpt_mtl b
      WHERE (legal_entity_id = p_le_id OR legal_entity_id IS NULL)
        AND (organization_id = p_orgn_id OR organization_id IS NULL)
        AND p_date BETWEEN eff_start_date AND eff_end_date
        AND delete_mark = 0
        AND cost_category_id IN
            ( SELECT category_id -- cost_category_id  Bug#7306720
                FROM mtl_item_categories mic,
                     gmf_process_organizations_gt gpo
              WHERE  mic.inventory_item_id = p_item_id
                   AND mic.organization_id = gpo.organization_id
                   AND (mic.organization_id = p_orgn_id OR p_orgn_id IS NULL)
            )
      UNION
      SELECT d.mtl_cmpntcls_id, d.mtl_analysis_code, 3
      FROM gmf_fiscal_policies d
      WHERE d.legal_entity_id = p_le_id
      ORDER BY 3;

    -- Cursor to retrieve item-specific and lot-specific burdens. If burdens are defined at
    -- at both levels the lot-specific ones take priority. The cursor might need a bit of
    -- explaining. The first select (the first branch of the union) selects lot-specific
    -- burdens. The second branch of the union first finds all burdens that are item specific
    -- that do not have a matching one that is lot-specific. In this context 'matching' means
    -- that the two burdens have the same resource, cost analysis code and cost component class ID.

    -- The result is the set of burdens (which could easily be empty) that needs to be incorporated
    -- in the lot cost.

    -- Not that this partially repeals some changes made for bug 3388974

    -- Bug 3388974-2 This cursor reinstated.

     CURSOR burdens_cursor
    ( p_item_id      NUMBER
    , p_orgn_id      NUMBER
    , p_lot_number   VARCHAR2
    , p_cost_type_id NUMBER
    , p_trans_date   DATE
    )
    IS
        SELECT lot_burden_line_id,
               resources,
               cost_cmpntcls_id,
               cost_analysis_code,
               burden_factor,
               0
        FROM   gmf_lot_cost_burdens
        WHERE  inventory_item_id = p_item_id
        AND    organization_id = p_orgn_id
        AND    lot_number = p_lot_number
        AND    cost_type_id = p_cost_type_id
        AND    delete_mark = 0
        AND    start_date <= p_trans_date
        AND    nvl(end_date, p_trans_date) >= p_trans_date
      UNION
        SELECT lot_burden_line_id,
               resources,
               cost_cmpntcls_id,
               cost_analysis_code,
               burden_factor, 0
      	FROM   gmf_lot_cost_burdens
      	WHERE  inventory_item_id = p_item_id
      	AND    organization_id = p_orgn_id
      	AND    lot_number IS NULL
      	AND    cost_type_id = p_cost_type_id
      	AND    delete_mark = 0
      	AND    start_date <= p_trans_date
      	AND    nvl(end_date, p_trans_date) >= p_trans_date
      	AND    (resources, cost_cmpntcls_id, cost_analysis_code)
               NOT IN
                 (SELECT resources, cost_cmpntcls_id, cost_analysis_code
                  FROM   gmf_lot_cost_burdens
                  WHERE  inventory_item_id = p_item_id
                  AND    organization_id = p_orgn_id
                  AND    lot_number = p_lot_number
                  AND    cost_type_id = p_cost_type_id
                  AND    delete_mark = 0
      	          AND    start_date <= p_trans_date
      	          AND    nvl(end_date, p_trans_date) >= p_trans_date
                 )
     ORDER BY 3,4 ;
    -- End 3388974-2

    --**********************************************************************************************
    --*                                                                                            *
    --* Cursor to retrieve the cost of a resource.                                                 *
    --* umoogala: passing co_code instead of calendar_code. Also, joined with cldr_hdr.            *
    --*                                                                                            *
    --**********************************************************************************************


    CURSOR burden_cost_cursor
    ( p_le_id	             NUMBER
    , p_cost_type_id       NUMBER
    , p_resources          VARCHAR2
    , p_orgn_id            NUMBER
    , p_cost_cmpntcls_id   NUMBER
    , p_cost_analysis_code VARCHAR2
    , p_date               DATE
    )
    IS
      SELECT cst.nominal_cost
      FROM   cm_rsrc_dtl cst,
             gmf_period_statuses gps
      WHERE  gps.legal_entity_id = p_le_id
      AND    gps.cost_type_id = p_cost_type_id
      AND    gps.start_date <= p_date
      AND    gps.end_date >= p_date
      AND    cst.period_id = gps.period_id
      AND    cst.resources = p_resources
      AND    cst.organization_id = p_orgn_id
      AND    cst.delete_mark = 0
      AND    gps.delete_mark = 0;


    CURSOR lot_costed_items
      IS
      SELECT g.inventory_item_id,g.organization_id
      FROM  gmf_lot_costed_items_gt g
      ORDER BY organization_id,inventory_item_id
     ;


    --**********************************************************************************************
    --*      Cursor to get the Batch Step ID which has Step Material Associations
    --*
    --**********************************************************************************************
    CURSOR associated_batch_steps_cursor(p_batch_id NUMBER)
    IS
    SELECT DISTINCT gbsi.batchstep_id
       FROM gme_material_details gmd, gme_batch_step_items gbsi
     WHERE gmd.material_detail_id = gbsi.material_detail_id
           AND gmd.batch_id = gbsi.batch_id
           AND gmd.line_type = 1
           AND gmd.batch_id = p_batch_id;


    --**********************************************************************************************
    --*                                                                                            *
    --* Function to check whether item is lot costed or not. This fucntion is used in cursor       *
    --* materials_cursor.									                                                         *
    --*                                                                                            *
    --* Bug 9212497 - OPM LOT ACTUAL COSTING PERFORMANCE ISSUE                                     *
    --**********************************************************************************************
/* INVCONV sschinch modified to add orgn id as additional parameter*/
FUNCTION is_item_lot_costed1
( p_orgn_id IN NUMBER,
  p_item_id IN NUMBER
)
RETURN NUMBER
IS
BEGIN
   RETURN lc_items_tab(p_item_id||'-'||p_orgn_id);
END;

    --**********************************************************************************************
    --*                                                                                            *
    --* Function to check whether item is present in _GT table, if not get it through query        *
    --*                                                                                            *
    --* Bug 9212497 - OPM LOT ACTUAL COSTING PERFORMANCE ISSUE                                     *
    --**********************************************************************************************
FUNCTION is_item_lot_costed
( p_orgn_id IN NUMBER,
  p_item_id IN NUMBER
)
RETURN NUMBER
IS
l_inv_id NUMBER;
BEGIN

  BEGIN
     SELECT decode(is_item_lot_costed1(p_orgn_id,p_item_id),p_item_id,p_item_id,0)
     INTO l_inv_id from dual;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_inv_id := 0;
    WHEN OTHERS THEN
       l_inv_id := 0;
  END;

  -- fnd_file.put_line(fnd_file.log,'After check: ' || l_inv_id ||'--' ||p_item_id||'-'||p_orgn_id);

 IF l_inv_id = 0 or l_inv_id is null THEN
      SELECT distinct inventory_item_id into l_inv_id FROM
      (
       SELECT
           msi.inventory_item_id
      FROM gmf_lot_costed_items lci,
           mtl_system_items_b msi
      WHERE lci.legal_entity_id = l_le_id
        AND lci.delete_mark = 0 /* ANTHIYAG Bug#5279681 06-Jun-2006 */
        AND msi.lot_control_code = 2
        AND lci.inventory_item_id = msi.inventory_item_id
        AND msi.inventory_asset_flag = 'Y'
        AND msi.process_costing_enabled_flag = 'Y'
        AND lci.cost_type_id = l_cost_type_id
        AND msi.inventory_item_id = p_item_id
        AND msi.organization_id = p_orgn_id
     UNION
      SELECT msi.inventory_item_id
      FROM mtl_item_categories mic,
           gmf_lot_costed_items g,
           mtl_system_items_b msi
     WHERE g.cost_category_id = mic.category_id
          AND g.legal_entity_id = l_le_id
          AND g.delete_mark = 0
          AND msi.lot_control_code = 2
          AND msi.organization_id = mic.organization_id
          AND mic.inventory_item_id = msi.inventory_item_id
          AND msi.inventory_asset_flag = 'Y'
          AND msi.process_costing_enabled_flag = 'Y'
          AND g.cost_type_id = l_cost_type_id
          AND msi.inventory_item_id = p_item_id
          AND msi.organization_id = p_orgn_id  )  ;

   --  fnd_file.put_line(fnd_file.log,'After Query ' || l_inv_id ||'--' ||p_item_id||'-'||p_orgn_id);
  END IF;

   -- Return the value
   RETURN l_inv_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   IF l_debug_level >= l_debug_level_medium THEN
      fnd_file.put_line(fnd_file.log,'Item is not lot costed ' || p_item_id||'-'||p_orgn_id );
   END IF;
    RETURN null;
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in is_item_lot_costed');
    RETURN null;
END;

/*=========================================================
  PROCEDURE : ReLoad_Lot_Costed_Items_gt

  DESCRIPTION
    This procedure loads global temporary tables for lot costed process
    organizations items.
  AUTHOR : Rajesh Patangya

  HISTORY
    When the process is run only for product item, then Lot_Costed_Items_gt table
    have only product items, this does not contain ingradient items in
    Lot_Costed_Items_gt table. When material cursor try to find the costed_flag for
    ingradients, it does not find it and further process assumes that the ingradient is
    not lot costed.
    1. Delete Lot_Costed_Items_gt table.
    2. Load all the lot costed items in Lot_Costed_Items_gt table.
    3. Reindex the array.
 ==========================================================*/

 PROCEDURE ReLoad_Lot_Costed_Items_gt(p_le_id        IN NUMBER,
                                   x_return_status OUT NOCOPY NUMBER
                                   ) IS
--    l_le_id NUMBER;  B 8687115 already declared global Not used.
   procedure_name VARCHAR2(100);
 BEGIN
   procedure_name := 'Reload Lot Costed Items GT';
   IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
     END IF;

   DELETE FROM GMF_LOT_COSTED_ITEMS_GT ;

-- Bug 8730374 Modified the insert to load items assigned by category as well

   INSERT
      INTO GMF_LOT_COSTED_ITEMS_GT
      (
          organization_id,
          inventory_item_id,
          primary_uom_code
      )
      SELECT
           msi.organization_id,
           msi.inventory_item_id,
           msi.primary_uom_code
      FROM gmf_lot_costed_items lci,
           mtl_system_items_b msi,
           gmf_process_organizations_gt gpo
      WHERE lci.legal_entity_id = l_le_id
        AND lci.delete_mark = 0 /* ANTHIYAG Bug#5279681 06-Jun-2006 */
        AND gpo.organization_id = msi.organization_id
        AND msi.lot_control_code = 2
        AND lci.inventory_item_id = msi.inventory_item_id
        AND msi.inventory_asset_flag = 'Y'
        AND msi.process_costing_enabled_flag = 'Y'
        AND lci.cost_type_id = l_cost_type_id
    UNION
      SELECT
        mic.organization_id,    /*ANTHIYAG Bug#5279681 06-Jun-2006 */
        mic.inventory_item_id,  /*ANTHIYAG Bug#5279681 06-Jun-2006 */
        i.primary_uom_code
      FROM mtl_item_categories mic,
           gmf_lot_costed_items g,
           mtl_system_items_b i,
           gmf_process_organizations_gt gpo
     WHERE g.cost_category_id = mic.category_id
          AND g.legal_entity_id = l_le_id
          AND g.delete_mark = 0
          AND i.lot_control_code = 2
          AND gpo.organization_id = i.organization_id
          AND i.organization_id = mic.organization_id
          AND mic.inventory_item_id = i.inventory_item_id
          AND i.inventory_asset_flag = 'Y'
          AND i.process_costing_enabled_flag = 'Y'
          AND g.cost_type_id = l_cost_type_id;

    /* Build index for organization id and item id*/
      FOR Cur_lc_items IN lot_costed_items
      LOOP
	 lc_items_tab(Cur_lc_items.inventory_item_id||'-'||cur_lc_items.organization_id) := Cur_lc_items.inventory_item_id;
      END LOOP;

    x_return_status := 0;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
     fnd_file.put_line
     (fnd_file.log,'Procedure failed: '||procedure_name);
      x_return_status := -1;
END;

/**********************************************************************************************
 *                                                                                            *
 * Procedures to merge a table of costs with the new_cost_tab. If mode = 'C' (= Combine) any  *
 * matches between the costs_table and new_cost_tab are simply added together. If mode = 'A'  *
 * (= Average) the cost_qty and new_qty are used to perform weighted averaging. The result is *
 * placed in new_cost_tab in both modes, and new_cost.unit_cost is the sum its costs.         *
 *                                                                                            *
 * Combining costs is used for adding burdens or acquisition costs to a new cost before it is *
 * either written to the database or used to update an existing cost. The update will use the *
 * Averaging mode.                                                                            *
 * History                                                                                    *
 * LCMOPM Dev 4-Aug-2009 LCM-OPM Integration, bug 8642337 Added new merge mode V for          *
 *        value adjustment. multiply the component cost by 1 and add to unit cost             *
--**********************************************************************************************/

PROCEDURE merge_costs
( costs_table     IN OUT NOCOPY l_cost_tab_type
, cost_qty        IN NUMBER
, new_qty         IN NUMBER
, merge_mode      IN VARCHAR2
)
IS
  k              NUMBER;
  l              NUMBER;
  divisor        NUMBER;
  l_cost_accrued BOOLEAN := FALSE;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Merge Costs';

  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Entered Procedure: '||procedure_name);
     END IF;

  IF l_debug_level >= l_debug_level_high THEN
    fnd_file.put_line(fnd_file.log,'Cost_qty = '||cost_qty||', new_qty = '||new_qty);

    fnd_file.put_line(fnd_file.log,'Before merge new_cost_tab is:');

    FOR k IN 1 .. new_cost_tab.COUNT
    LOOP
      fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
      fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
      fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
      fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
      fnd_file.put_line(fnd_file.log,'====================================');
    END LOOP;

    IF costs_table.EXISTS(1) THEN
      fnd_file.put_line(fnd_file.log,'Before merge costs_tab is:');
      FOR k IN 1 .. costs_table.COUNT
      LOOP
        fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||costs_table(k).cost_cmpntcls_id);
        fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||costs_table(k).cost_analysis_code);
        fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||costs_table(k).cost_level);
        fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||costs_table(k).component_cost);
        fnd_file.put_line(fnd_file.log,'====================================');
      END LOOP;
    ELSE
      fnd_file.put_line(fnd_file.log,'No costs to merge');
    END IF;
  END IF;

  IF costs_table.EXISTS(1) THEN
    -- If this is an averaging of costs we need to do his first before combining the results
    IF merge_mode IN ('A','V') THEN --IF merge_mode = 'A'  -- AF
      divisor := new_qty + cost_qty;
      IF divisor = 0 THEN
        divisor := 1;
      END IF;

      fnd_file.put_line(fnd_file.log,'Divisor is  '||divisor||'cost qty = '||cost_qty||' new qty= '||new_qty);

      IF merge_mode ='A' THEN
        FOR k in 1 .. costs_table.COUNT
        LOOP
          costs_table(k).component_cost := costs_table(k).component_cost * cost_qty / divisor;
         END LOOP;
      END IF;

      FOR k in 1 .. new_cost_tab.COUNT
      LOOP
         -- LCM-OPM Integration, added merge mode V (Value adjustment) for LC adjustments.
        IF merge_mode ='A' THEN
          new_cost_tab(k).component_cost := new_cost_tab(k).component_cost * new_qty / divisor;
        ELSE --Merge mode IS V value adjustment
          new_cost_tab(k).component_cost := new_cost_tab(k).component_cost * 1 / divisor;
        END IF;
        -- AF
      END LOOP;

      IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line(fnd_file.log,'Cost_qty = '||cost_qty||', new_qty = '||new_qty);
        fnd_file.put_line(fnd_file.log,'After averaging new_cost_tab is:');

        FOR k IN 1 .. new_cost_tab.COUNT
        LOOP
          fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
          fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
          fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
          fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
          fnd_file.put_line(fnd_file.log,'====================================');
        END LOOP;

        fnd_file.put_line(fnd_file.log,'After averaging costs_tab is:');
        FOR k IN 1 .. costs_table.COUNT
        LOOP
          fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||costs_table(k).cost_cmpntcls_id);
          fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||costs_table(k).cost_analysis_code);
          fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||costs_table(k).cost_level);
          fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||costs_table(k).component_cost);
          fnd_file.put_line(fnd_file.log,'====================================');
        END LOOP;
      END IF;
    END IF;

    FOR k IN 1 .. costs_table.COUNT
    LOOP
      FOR l in 1..new_cost_tab.COUNT
      LOOP
        l_cost_accrued := FALSE;
        IF  new_cost_tab(l).cost_cmpntcls_id = costs_table(k).cost_cmpntcls_id
        AND new_cost_tab(l).cost_analysis_code = costs_table(k).cost_analysis_code
        AND new_cost_tab(l).cost_level = costs_table(k).cost_level
        THEN
          new_cost_tab(l).component_cost :=  new_cost_tab(l).component_cost + costs_table(k).component_cost;
          l_cost_accrued := TRUE;
          EXIT;
        END IF;
      END LOOP;

      IF NOT l_cost_accrued THEN
        l := new_cost_tab.count+1;
        new_cost_tab(l) := SYSTEM.gmf_cost_type
                           ( costs_table(k).cost_cmpntcls_id
                           , costs_table(k).cost_analysis_code
                           , 0
                           , costs_table(k).component_cost
                           , 0
                           );

      END IF;
    END LOOP;
  END IF;

  new_cost.unit_cost := 0;

  FOR k IN 1 .. new_cost_tab.COUNT
  LOOP
    new_cost.unit_cost := new_cost.unit_cost + new_cost_tab(k).component_cost;
  END LOOP;

  IF l_debug_level >= l_debug_level_high THEN
    fnd_file.put_line(fnd_file.log,'After merge new_cost_tab is:');

    FOR k IN 1 .. new_cost_tab.COUNT
    LOOP
      fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
      fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
      fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
      fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
      fnd_file.put_line(fnd_file.log,'====================================');
    END LOOP;
    fnd_file.put_line(fnd_file.log,'After merging, new unit cost is: '||new_cost.unit_cost);
  END IF;

  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
END;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure load and cost burdens. If any burdens are located, they are costed and the       *
    --* l_burdens_tab and l_burdens_costs_tab tables are populated                                 *
    --*                                                                                            *
    --**********************************************************************************************

-- 3388974-2 This procedure reinstated and its replacement deleted.

PROCEDURE process_burdens
IS
  i         NUMBER;
  j         NUMBER;
  factor    NUMBER;
  cost      NUMBER;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Process Burdens';

  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Entered Procedure: '||procedure_name);
     END IF;

  l_return_status := 'S';
  l_burdens_total := 0;
  l_burden_costs_tab.delete;

  OPEN  burdens_cursor ( transaction_row.inventory_item_id
                       , transaction_row.orgn_id
                       , transaction_row.lot_number
                       , l_cost_type_id
                       , transaction_row.trans_date
                       );


  FETCH burdens_cursor BULK COLLECT into l_burdens_tab;

  CLOSE burdens_cursor;

  IF  l_burdens_tab.EXISTS(1) THEN

    IF l_debug_level >= l_debug_level_high THEN
      fnd_file.put_line(fnd_file.log,
            'Burdens found for item: ' || transaction_row.inventory_item_id ||
  	        ' orgn: ' || l_org_tab(transaction_row.orgn_id) ||
            ' cost type: ' || l_cost_method_code ||
		        ' lot: ' || transaction_row.lot_number ||
		        ' trans_date: ' || to_char(transaction_row.trans_date));

      fnd_file.put_line( fnd_file.log, 'Burdens Table is:');
      FOR i IN 1.. l_burdens_tab.COUNT
      LOOP
        fnd_file.put_line( fnd_file.log, 'Resources['||i||']:'||l_burdens_tab(i).resources);
        fnd_file.put_line( fnd_file.log, 'CCC ID   ['||i||']:'||l_burdens_tab(i).cost_cmpntcls_id);
        fnd_file.put_line( fnd_file.log, 'C/A Code ['||i||']:'||l_burdens_tab(i).cost_analysis_code);
        fnd_file.put_line( fnd_file.log, 'B/Factor ['||i||']:'||l_burdens_tab(i).burden_factor);
      END LOOP;
    END IF;

    -- Retrieve the cost for each resource. If we can't find a cost for this cost method
    -- then we cannot carry on.

    FOR i IN 1..l_burdens_tab.COUNT
    LOOP
      l_burden_cost := 0;

      -- umoogala: using co_code and default_cost_mthd to get costs for non-lot controlled items.
      -- was calendar_code and cost_mthd_code

      IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line( fnd_file.log,
          'Searching for resource cost using LE: ' || l_le_id ||
          ' mthd: ' || l_default_cost_type_id ||
	        ' rsrc: ' || l_burdens_tab(i).resources ||
          ' orgn: ' || l_org_tab(transaction_row.orgn_id) ||
          ' CCC/ID: ' || l_burdens_tab(i).cost_cmpntcls_id ||
          ' A/Code: ' ||l_burdens_tab(i).cost_analysis_code ||
          ' date: '   || transaction_row.trans_date);
      END IF;
/* INVCONV sschinch */
      OPEN burden_cost_cursor
           ( l_le_id
           , l_default_cost_type_id
           , l_burdens_tab(i).resources
           , transaction_row.orgn_id
           , l_burdens_tab(i).cost_cmpntcls_id
           , l_burdens_tab(i).cost_analysis_code
           , transaction_row.trans_date
           );

      l_burden_cost := NULL;

      FETCH burden_cost_cursor INTO l_burden_cost;

      CLOSE burden_cost_cursor;

      IF l_burden_cost IS NOT NULL THEN

        IF l_debug_level >= l_debug_level_high THEN
          fnd_file.put_line
          (fnd_file.log, 'Found cost: '|| l_burden_cost);
        END IF;

        l_burdens_tab(i).burden_cost := l_burdens_tab(i).burden_factor * l_burden_cost;

      ELSE

        fnd_file.put_line
        (  fnd_file.log
        ,  'ERROR: Unable to locate a burden cost. Resource: '
        || l_burdens_tab(i).resources
        || ', analysis code: '
        || l_burdens_tab(i).cost_analysis_code
        || ', component class ID: '
        || to_char(l_burdens_tab(i).cost_cmpntcls_id)
        );

        l_return_status := 'E';
        RETURN;
      END IF;

      l_burden_costs_tab(i) := SYSTEM.gmf_cost_type
                             ( l_burdens_tab(i).cost_cmpntcls_id
                             , l_burdens_tab(i).cost_analysis_code
                             , 0
                             , l_burdens_tab(i).burden_cost
                             , 1
                             );


      l_burdens_total := l_burdens_total + l_burden_costs_tab(i).component_cost;
    END LOOP;
  END IF;

  IF l_debug_level >= l_debug_level_high THEN
    fnd_file.put_line(fnd_file.log,'At end of process_burdens, the burden costs are:');
    FOR i IN 1 .. l_burden_costs_tab.COUNT
    LOOP
      fnd_file.put_line(fnd_file.log,'CCC/ID['||i||']: '||l_burden_costs_tab(i).cost_cmpntcls_id);
      fnd_file.put_line(fnd_file.log,'A/Code['||i||']: '||l_burden_costs_tab(i).cost_analysis_code);
      fnd_file.put_line(fnd_file.log,'Level ['||i||']: '||l_burden_costs_tab(i).cost_level);
      fnd_file.put_line(fnd_file.log,'C/Cost['||i||']: '||l_burden_costs_tab(i).component_cost);
      fnd_file.put_line(fnd_file.log,'====================================');
    END LOOP;
  END IF;

  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

EXCEPTION
  WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
    l_return_status := 'E';

END process_burdens;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to create a cost header for a new lot in gmf_lot_costs                           *
    --*                                                                                            *
    --**********************************************************************************************


PROCEDURE create_cost_header
( p_item_id          IN NUMBER
, p_lot_number       IN VARCHAR2
, p_orgn_id          IN NUMBER
, p_cost_type_id     IN NUMBER
, p_unit_cost        IN NUMBER
, p_cost_date        IN DATE
, p_onhand_qty       IN NUMBER
, p_doc_id           IN NUMBER
, p_trx_src_type_id  IN NUMBER
, p_txn_act_id       IN NUMBER
, x_header_id       OUT NOCOPY NUMBER
, x_unit_cost       OUT NOCOPY NUMBER
, x_onhand_qty      OUT NOCOPY NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
)
IS
  loop_count NUMBER;
  procedure_name VARCHAR2(100);
BEGIN
  procedure_name := 'Create Cost Header';
  IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

  IF p_unit_cost IS NULL THEN
    fnd_file.put_line
    (fnd_file.log,'ERROR: Could not create cost header for Lot Number '||to_char(transaction_row.lot_number)||' as no cost was available');
    fnd_file.put_line
    (fnd_file.log,'      Transaction type/ID was '||transaction_row.transaction_source_type_id||'/'||to_char(transaction_row.transaction_id));
    fnd_file.put_line(fnd_file.log, 'p_unit_cost  = '||p_unit_cost);
    x_return_status := 'E';
    RETURN;
  END IF;

  IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Inside INSERT HEADER');
    fnd_file.put_line(fnd_file.log,'Item ID      = '||p_item_id);
    fnd_file.put_line(fnd_file.log,'Lot Number       = '||p_lot_number);
    fnd_file.put_line(fnd_file.log,'Unit Cost    = '||p_unit_cost);
    fnd_file.put_line(fnd_file.log,'Cost Date    = '||p_cost_date);
    fnd_file.put_line(fnd_file.log,'Whse Code    = '||p_orgn_id);
    fnd_file.put_line(fnd_file.log,'Cost Method  = '||p_cost_type_id);
    fnd_file.put_line(fnd_file.log,'Onhand Qty   = '||p_onhand_qty);
    fnd_file.put_line(fnd_file.log,'Doc Type     = '||p_trx_src_type_id||','||p_txn_act_id);
    fnd_file.put_line(fnd_file.log,'Doc ID       = '||p_doc_id);
  END IF;

  INSERT INTO gmf_lot_costs
  ( header_id
  , inventory_item_id
  , lot_number
  , organization_id
  , cost_type_id
  , unit_cost
  , cost_date
  , onhand_qty
  , last_trx_source_type_id
  , last_trx_action_id
  , last_costing_doc_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , delete_mark
  , request_id
  , program_application_id
  , program_id
  , program_update_date
  , final_cost_flag
  )
  VALUES
  (
    gmf_cost_header_id_s.nextval
  , p_item_id
  , p_lot_number
  , p_orgn_id
  , p_cost_type_id
  , p_unit_cost
  , p_cost_date
  , p_onhand_qty
  , p_trx_src_type_id
  , p_txn_act_id
  , p_doc_id
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , 0
  , l_request_id
  , l_prog_appl_id
  , l_program_id
  , SYSDATE
  , l_final_run_flag
  )
  RETURNING header_id, unit_cost, onhand_qty
  INTO      x_header_id, x_unit_cost, x_onhand_qty;

  x_return_status := 'S';

  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

EXCEPTION

  WHEN OTHERS THEN
    fnd_file.put_line
    (fnd_file.log,'ERROR: Unable to create cost header');
    fnd_file.put_line
    (fnd_file.log,SQLERRM || ' in ' || procedure_name);

    x_return_status := 'E';

END create_cost_header;


    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to create a new lot cost detail row in gmf_lot_cost_details                      *
    --*                                                                                            *
    --**********************************************************************************************


PROCEDURE create_cost_detail
( p_header_id          IN NUMBER
, p_component_class_id IN NUMBER
, p_cost_analysis_code IN VARCHAR2
, p_cost_level         IN VARCHAR2
, p_component_cost     IN NUMBER
, p_burden_ind         IN NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
)
IS

  loop_count NUMBER;
  procedure_name VARCHAR2(100);
  do_insert_flag      NUMBER := 1;      /* B9131983 */
  ZERO_component_cost NUMBER := 0 ;     /* B9131983 */
  ZERO_DETAIL_ID      NUMBER := 0 ;     /* B9131983 */

BEGIN
  procedure_name := 'Create Cost Detail';
  IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
    fnd_file.put_line(fnd_file.log,'Inside INSERT DETAIL');
    fnd_file.put_line(fnd_file.log,'Header ID           = '||p_header_id);
    fnd_file.put_line(fnd_file.log,'Component Class ID  = '||p_component_class_id);
    fnd_file.put_line(fnd_file.log,'Analysis Code       = '||p_cost_analysis_code);
    fnd_file.put_line(fnd_file.log,'Cost Level          = '||p_cost_level);
    fnd_file.put_line(fnd_file.log,'Burden Ind          = '||p_burden_ind);
    fnd_file.put_line(fnd_file.log,'Cost                = '||p_component_cost);
  END IF;

   /* B9131983 starts */
   BEGIN
    SELECT detail_id, component_cost INTO ZERO_DETAIL_ID, ZERO_component_cost
     FROM gmf_lot_cost_details
    WHERE header_id = p_header_id
      AND cost_cmpntcls_id = p_component_class_id
      AND cost_analysis_code = p_cost_analysis_code
      AND cost_level = p_cost_level ;

   IF ZERO_component_cost = 0 THEN
   -- If Zero cost record is present then we have to delete the record
    DELETE gmf_lot_cost_details
     WHERE detail_id = ZERO_DETAIL_ID
       AND header_id = p_header_id  ;
    do_insert_flag := 1;   -- This will insert the incomiong new record
   ELSE
     do_insert_flag := 0;
   END IF;
    x_return_status := 'S';

   EXCEPTION
     WHEN no_data_found then
      do_insert_flag := 1;
     WHEN OTHERS then
      fnd_file.put_line
      (fnd_file.log,'ERROR: Unable to create/update cost detail');
      fnd_file.put_line
      (fnd_file.log,SQLERRM || ' in ' || procedure_name);
       x_return_status := 'E';
   END ;
  /* B9131983 End */

   IF do_insert_flag = 1 THEN       -- B9131983

    INSERT INTO gmf_lot_cost_details
    ( header_id
    , detail_id
    , cost_cmpntcls_id
    , cost_analysis_code
    , cost_level
    , component_cost
    , burden_ind
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , delete_mark
    , request_id
    , program_application_id
    , program_id
    , program_update_date
    , final_cost_flag
    )
    VALUES
    ( p_header_id
    , gmf_cost_detail_id_s.nextval
    , p_component_class_id
    , p_cost_analysis_code
    , p_cost_level
    , p_component_cost
    , p_burden_ind
    , sysdate
    , l_user_id
    , sysdate
    , l_user_id
    , 0
    , l_request_id
    , l_prog_appl_id
    , l_program_id
    , SYSDATE
    , l_final_run_flag
    );
  END IF;        -- B9131983

  x_return_status := 'S';
  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

EXCEPTION

  WHEN OTHERS THEN
    fnd_file.put_line
    (fnd_file.log,'ERROR: Unable to create cost detail');
    fnd_file.put_line
    (fnd_file.log,SQLERRM || ' in ' || procedure_name);

    x_return_status := 'E';

END create_cost_detail;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to clone the costs for a lot/organization                                           *
    --*                                                                                            *
    --**********************************************************************************************

PROCEDURE clone_costs
IS
  old_header_id  NUMBER;
  new_header_id  NUMBER;
  i              NUMBER;
  discard        NUMBER;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Clone Costs';
  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

  create_cost_header
  ( old_cost.inventory_item_id /*bug 5309434*/
  , old_cost.lot_number
  , old_cost.organization_id
  , old_cost.cost_type_id
  , old_cost.unit_cost
  , old_cost.cost_date
  , old_cost.onhand_qty
  ,old_cost.last_trx_source_type_id
  ,old_cost.last_trx_action_id
  , old_cost.last_costing_doc_id
  , new_header_id
  , discard
  , discard
  , l_return_status
  );

  old_cost.header_id := new_header_id;

  IF l_return_status = 'S' THEN
    FOR i in 1 .. old_cost_tab.COUNT
    LOOP
      create_cost_detail
      ( new_header_id
      , old_cost_tab(i).cost_cmpntcls_id
      , old_cost_tab(i).cost_analysis_code
      , 0
      , old_cost_tab(i).component_cost
      , 0
      , l_return_status
      );
    END LOOP;
  END IF;
  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log
  , 'ERROR: Could not clone costs '||SQLERRM
  );

  l_return_status := 'U';
END clone_costs;


    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to create a new linking transaction in gmf_material_lot_cost_txns                *
    --*                                                                                            *
    --**********************************************************************************************
PROCEDURE create_material_transaction
( p_header_id        IN NUMBER
, p_cost_type_id     IN NUMBER
, p_trans_date       IN DATE
, p_trans_qty        IN NUMBER
, p_trans_um         IN VARCHAR2
, p_total_cost       IN NUMBER
, p_trans_id         IN NUMBER
, p_unit_cost        IN NUMBER
, p_onhand_qty       IN NUMBER
, p_old_unit_cost    IN NUMBER
, p_old_onhand_qty   IN NUMBER
, p_new_cost_ind     IN NUMBER
, p_lot_number       IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
)
IS
  loop_count NUMBER;
  procedure_name VARCHAR2(100);
BEGIN
  procedure_name := 'Create Material Transaction';
  IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
    fnd_file.put_line(fnd_file.log,'Creating material transaction with these values:');
    fnd_file.put_line(fnd_file.log,'Header ID      :'||p_header_id);
    fnd_file.put_line(fnd_file.log,'Cost Method    :'||p_cost_type_id);
    fnd_file.put_line(fnd_file.log,'Date           :'||p_trans_date);
    fnd_file.put_line(fnd_file.log,'Trans Qty      :'||p_trans_qty);
    fnd_file.put_line(fnd_file.log,'UoM            :'||p_trans_um);
    fnd_file.put_line(fnd_file.log,'Total Cost     :'||p_total_cost);
    fnd_file.put_line(fnd_file.log,'Trans ID       :'||p_trans_id);
    fnd_file.put_line(fnd_file.log,'Unit Cost      :'||p_unit_cost);
    fnd_file.put_line(fnd_file.log,'Onhand Qty     :'||p_onhand_qty);
    fnd_file.put_line(fnd_file.log,'Old Unit Cost  :'||p_old_unit_cost);
    fnd_file.put_line(fnd_file.log,'Old Onhand Qty :'||p_old_onhand_qty);
    fnd_file.put_line(fnd_file.log,'New Cost Ind   :'||p_new_cost_ind);
    fnd_file.put_line(fnd_file.log,'Lot Number   :'||p_lot_number);
  END IF;

  INSERT INTO gmf_material_lot_cost_txns
  ( cost_trans_id
  , cost_header_id
  , cost_type_id
  , cost_trans_date
  , cost_trans_qty
  , cost_trans_um
  , total_trans_cost
  , transaction_id
  , new_unit_cost
  , new_onhand_qty
  , old_unit_cost
  , old_onhand_qty
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , request_id
  , program_application_id
  , program_id
  , program_update_date
  , final_cost_flag
  , new_cost_ind
  , lot_number
  )
  VALUES
  ( gmf_cost_trans_id_s.nextval
  , p_header_id
  , p_cost_type_id
  , p_trans_date
  , p_trans_qty
  , p_trans_um
  , p_total_cost
  , decode(p_trans_id, -9, (-1*gmf_cost_trans_id_s.currval),p_trans_id)
  , p_unit_cost
  , p_onhand_qty
  , p_old_unit_cost
  , p_old_onhand_qty
  , sysdate
  , l_user_id
  , sysdate
  , l_user_id
  , l_request_id
  , l_prog_appl_id
  , l_program_id
  , SYSDATE
  , l_final_run_flag
  , p_new_cost_ind
  , p_lot_number
  );
  x_return_status := 'S';

  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line
    (fnd_file.log,'ERROR: Unable to create material cost transaction');
    fnd_file.put_line
    (fnd_file.log,SQLERRM || ' in ' || procedure_name);

    x_return_status := 'E';

END create_material_transaction;


    --**********************************************************************************************
    --*                                                                                            *
    --* Procedures to handle received lots.                                                        *
    --*                                                                                            *
    --* The costs come from the PO together with any associated Special Charges and burdens.       *
    --* If this is the first receipt for this lot in this warehouse the costs will be set up.      *
    --*                                                                                            *
    --* If there is already a cost for this lot and warehouse then the costs will be revised       *
    --* by averaging the new cost with the old cost by using the original and revised quantities.  *
    --*                                                                                            *
    --* Returns update the cost using an identical formula                                         *
    --*                                                                                            *
    --* HISTORY                                                                                    *
    --*                                                                                            *
    --*   Bug#5463200 Anand Thiyagarajan  14-Aug-2006                                              *
    --*     Modified Code in the Special Charges query to remove po_line_locations_all, changed the*
    --*     value for include_in_acquisition_cost to "I", used estimated_amount instead of actual  *
    --*     and included MMT table join with RCV_TRANSACTION_ID instead of INV_TRANSACTION_ID      *
    --*    Andrea 4-Aug-2009 LCM-OPM Integrations, bug 8642337, added Unin all query to fetch      *
    --*      Estimated LC adjustments for LCM enabled Po lines.                                    *
    --**********************************************************************************************

PROCEDURE get_special_charges IS

    /* Begin 3824810 sschinch */
    TYPE acquistion_rec IS RECORD
    ( COST_CMPNTCLS_ID               NUMBER(15)
    , COST_ANALYSIS_CODE             VARCHAR2(4)
    , COMPONENT_COST                 NUMBER
    , RECEIPT_UOM                    VARCHAR2(3)
    , LCM_FLAG                       NUMBER
     );

   TYPE acq_tab_type IS TABLE OF acquistion_rec	 INDEX BY PLS_INTEGER;

        CURSOR acquisition_cursor IS
        SELECT  rc.cost_component_class_id
                ,rc.cost_analysis_code
                ,nvl(rca.estimated_amount, rca.actual_amount)/mmt.transaction_quantity /* ANTHIYAG Bug#5463200 14-Aug-2006 */
                ,uom.uom_code
                ,0  lcm_flag
         FROM   rcv_transactions t,
                po_rcv_charges rc,
                po_rcv_charge_allocations rca,
                mtl_units_of_measure uom,
                mtl_material_transactions mmt, /* ANTHIYAG Bug#5463200 14-Aug-2006 */
                po_line_locations_all pll -- AF
         WHERE  mmt.transaction_id = transaction_row.transaction_id /* ANTHIYAG Bug#5463200 14-Aug-2006 */
         AND    t.transaction_id = mmt.rcv_transaction_id
         AND    t.shipment_header_id = rc.shipment_header_id
         AND    t.shipment_line_id  = rca.shipment_line_id
         AND    rc.charge_id = rca.charge_id
         AND    t.unit_of_measure = uom.unit_of_measure
         AND    rc.include_in_acquisition_cost = 'I' /* ANTHIYAG Bug#5463200 14-Aug-2006 */
         AND    t.po_line_location_id = pll.line_location_id  -- AF
         AND    NVL(pll.lcm_flag,'N') = 'N'                   -- AF
         -- AF
      UNION ALL  /* Estimated LC adjustments for LCM enabled PO lines */
         SELECT  glat.cost_cmpntcls_id
                ,glat.cost_analysis_code
                ,(nvl(glat.new_landed_cost,0) - nvl(glat.prior_landed_cost,0)) / glat.Primary_quantity
                ,glat. primary_uom_code
                ,1  lcm_flag
           FROM
                 gmf_lc_adj_transactions glat,
		 mtl_material_transactions mmt,
                 rcv_transactions rt ,
                 po_line_locations_all pll
          WHERE
                 mmt.transaction_id      = transaction_row.transaction_id
            AND  glat.rcv_transaction_id = mmt.rcv_transaction_id
            AND  rt.transaction_id       = glat.rcv_transaction_id
            AND  (glat.lc_adjustment_flag = 0 OR glat.adjustment_num = 0)
            AND  glat.cost_acquisition_flag = 'I'
            AND  glat.component_type IN ('ITEM PRICE','CHARGE')
            AND  rt.po_line_location_id  = pll.line_location_id
            AND  NVL(pll.lcm_flag,'N')   = 'Y';
            -- AF

         l_acq_tab            acq_tab_type;
         l_from_uom           VARCHAR2(25); --(This variable stores po or receipt unit of measure)
         l_cmpntcls_id        NUMBER;
         l_cost_analysis_code VARCHAR2(5);
         l_component_cost     NUMBER;
         l_acquisition_cost NUMBER;
         procedure_name VARCHAR2(100);

        /* End 3824810 sschinch */
BEGIN

  procedure_name := 'Process Special Charges';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

  l_acquisitions_total := 0;

  OPEN acquisition_cursor;
  FETCH acquisition_cursor BULK COLLECT INTO l_acq_tab;
  CLOSE acquisition_cursor;


    IF l_acq_tab.EXISTS(1) THEN
    FOR i IN 1 .. l_acq_tab.COUNT
    LOOP
        /* For non-LCM charges only invoke uom conversion */
       l_from_uom := l_acq_tab(i).receipt_uom;
      IF (transaction_row.trans_um <> l_from_uom AND l_acq_tab(i).lcm_flag = 0)
       THEN
         l_acquisition_cost :=
               INV_CONVERT.INV_UM_CONVERT(ITEM_ID       => transaction_row.inventory_item_id
                                         ,PRECISION     => 5
                                         ,ORGANIZATION_ID => transaction_row.orgn_id
                                         ,LOT_NUMBER     => transaction_row.lot_number
                                         ,FROM_QUANTITY => l_acq_tab(i).component_cost
                                         ,FROM_UNIT     => transaction_row.trans_um
                                         ,TO_UNIT       => l_from_uom
                                         ,FROM_NAME     => NULL
                                         ,TO_NAME       => NULL
                                           );
        l_acq_tab(i).component_cost := l_acquisition_cost;

      	IF ((l_acquisition_cost = -99999) OR (SIGN(l_acq_tab(i).component_cost)<> SIGN (l_acquisition_cost)))
      	THEN
           fnd_file.put_line
                 (fnd_file.log,'ERROR: Unable to convert from '
                 ||transaction_row.trans_um
                 ||' to '||l_from_uom||' for transaction ID '
                 ||transaction_row.transaction_id
                 ||' aqui component cost '|| l_acq_tab(i).component_cost
                 ||' Reurned Value '||l_acquisition_cost
                 );
                 l_return_status := 'E';
                 RETURN;

        END IF;
      END IF;

      /******** Bug  4038722 - Dinesh Vadivel - Start **********/

      /*   Convert to Base Currency, if Acquisition Cost(i.e., Receipt )
       **  currency is different.
       **  receipt_ccy and l_exchange_rate would have been calculated
       **  in process_receipts itself. So we can just use it as they are global variables.
       */
      IF ( l_base_ccy_code <>  receipt_ccy AND l_acq_tab(i).lcm_flag = 0) THEN /* Check if the receipt currency is the same as the base currency */

         IF l_debug_level >= l_debug_level_medium THEN
              fnd_file.put_line   (fnd_file.log,'
                 In Acquisition Costs() : Converting component_cost : '||
                 NVL(l_acq_tab(i).component_cost,0)||' Receipt Currency : '||receipt_ccy||
                 ' to Base Currency : '||l_base_ccy_code||'. New component_cost : '||
                 NVL(l_acq_tab(i).component_cost,0) * l_exchange_rate||'. Exchange Rate is : '||l_exchange_rate);
          END IF;

          l_acq_tab(i).component_cost :=  NVL(l_acq_tab(i).component_cost,0) * l_exchange_rate;

        END IF;

      /******** Bug  4038722 - Dinesh Vadivel - End **********/

      l_acquisitions_total := l_acquisitions_total + NVL(l_acq_tab(i).component_cost,0);

      l_cmpntcls_id := l_acq_tab(i).cost_cmpntcls_id;
      l_cost_analysis_Code := l_acq_tab(i).cost_analysis_code;
      l_component_cost := NVL(l_acq_tab(i).component_cost,0);



      l_acqui_cost_tab(i) := SYSTEM.gmf_cost_type(l_cmpntcls_id,
      			                   l_cost_analysis_code,
     			                   0,
     			                   l_component_cost,
     			                   0);

       /*End Bug 3824810 sschinch */

    END LOOP;
  END IF;

    IF l_debug_level >= l_debug_level_medium THEN
      fnd_file.put_line(fnd_file.log,'At end of get_special_charges, the costs are:');
      FOR i IN 1 .. l_acqui_cost_tab.COUNT
      LOOP
        fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||l_acqui_cost_tab(i).cost_cmpntcls_id);
        fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||l_acqui_cost_tab(i).cost_analysis_code);
        fnd_file.put_line(fnd_file.log,'Level ['||k||']: '||l_acqui_cost_tab(i).cost_level);
        fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||l_acqui_cost_tab(i).component_cost);
        fnd_file.put_line(fnd_file.log,'====================================');

      END LOOP;
    END IF;

    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,procedure_name||':'||SQLERRM);
END get_special_charges;

--*************************************************************************************
--*    Procedure Name : PROCESS_ADJUSTMENT
--*
--*     Description :
--*                Procedure to handle adjusted lots (ADJI/ADJR)
--*
--* HISTORY
--*
--*   27-Nov-2004 Dinesh Vadivel Bug# 4004338
--*        Added cost_type_code in where clause of the select query which returns the header_id
--*        from the gmf_material_lot_cost_txns. The issue arises if we have the same item in two different lot cost methods
--*        and try to run the Lot Actual Cost Process
--*************************************************************************************

 PROCEDURE process_adjustment
IS
  loop_count NUMBER;
  l_header_id gmf_lot_costs.header_id%type;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Process Adjustment';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
     fnd_file.put_line
    (fnd_file.log,'Updating lot cost header with trans_qty of '||transaction_row.trans_qty);
  END IF;

  -- This procedure is used if the lot being adjusted has a lot cost. Lots being created
  -- via ADJx transactions are handled by the process_creation procedure (above).

  -- Adjustments to lots are handled at the prevailing lot costs. They only affect the quantities
  -- not the costs themselves.

  -- If the existing cost is marked as 'Final' and we are running in test mode we need
  -- to clone the header and its details to prevent multiple decrements from the same transaction.

  -- This change is done to provide teh undo script for the current run of lot
  -- costing in final mode requested by MACSTEEL

  IF     old_cost.final_cost_flag = 1
  AND    old_cost.request_id <> l_request_id  --  l_final_run_flag = 0
  THEN
    clone_costs;
  END IF;

  UPDATE gmf_lot_costs
  SET    onhand_qty = onhand_qty + transaction_row.trans_qty
  ,      last_update_date = sysdate
  WHERE  header_id = old_cost.header_id;

  IF SQL%ROWCOUNT = 1 THEN
    IF l_debug_level >= l_debug_level_medium THEN
      fnd_file.put_line
      (fnd_file.log,'Creating new cost transaction');
    END IF;

    l_header_id := old_cost.header_id;

    create_material_transaction
    ( l_header_id
    , l_cost_type_id /* INVCONV sschinch */
    , transaction_row.trans_date
    , transaction_row.trans_qty
    , transaction_row.trans_um
    , transaction_row.trans_qty * old_cost.unit_cost
    , transaction_row.transaction_id
    , old_cost.unit_cost
    , old_cost.onhand_qty + transaction_row.trans_qty
    , old_cost.unit_cost
    , old_cost.onhand_qty
    , NULL
    ,transaction_row.lot_number
    , l_return_status
    );

    IF l_return_status <> 'S' THEN
      RETURN;
    END IF;
  ELSE
    l_return_status := 'E';
    RETURN;
  END IF;
  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

EXCEPTION
  WHEN OTHERS THEN
       fnd_file.put_line
       (fnd_file.log,'Failed in procedure process_adjustment with error');
       fnd_file.put_line
       (fnd_file.log,SQLERRM);
       l_return_status := 'U';

END process_adjustment;



--********************************************************************************************************
    --*    Procedure Name : PROCESS_REVERSALS
    --*
    --*     Description :
    --*               Procedure to reversals for products  - Uday Moogala - Bug 4004338
    --*
    --*   Description :   Assume three records returned by inv_tran_cursor with trans_qty as 100,-100 and 75.
    --*    When we encounter -100 record we have to reverse the transaction and set the unit_cost of this record to
    --*           Zero  -  if there is no cost prior to 100 record
    --*           X$     - where X$ is the cost of the record that is prior to 100 if any exists.
    --*          This X$ will be set one and only if we get 100 and -100 adjacent.
    --*
    --*   Dinesh -No Bug# - Earlier new_cost_ind was not set up properly.Now corrected along with 4053149
    --*          NEW_COST_IND in gmf_material_lot_cost_txns is used in the Subledger Posting.
    --*          If this indicator is set to 1 then that means whatever cost pointed by
    --*          header_id in gmf_lot_cost_details is the AVERAGE COST and not the actual
    --*          TRANSACTION COST. The Actual Transaction cost is under the negative of header_id.
    --*          So, depending on this NEW_COST_IND, the SL will decide on posting at the cost of
    --*          header_id or negative of header_id (i.e., -header_id)
    --*
    --*  Dinesh 4227784 - Issue due to the above changes. Since we have added gmf_material_lot_cost_txns
    --*          to the get_previous_costs_cur CURSOR, while querying for the prev-prev transaction
    --*          it will ignore the reversal transactions if any, because the reversal transaction will
    --*          not have the exact header_id as in gmf_lot_costs. Rather it will have the same header_id
    --*          as that of its original transaction.
    --*          So removed this table and added seperately to get new_cost_ind
    --*
    --**********************************************************************************************


PROCEDURE process_reversals
IS
/* INVCONV sschinch modifications */

  CURSOR get_previous_costs_cur(
           p_item_id   NUMBER,
           p_lot_number VARCHAR2,
           p_orgn_id      NUMBER,
           p_cost_type_id NUMBER,
           p_cost_date DATE
           )
  IS
   SELECT *
     FROM (
           SELECT last_trx_source_type_id,  --last_costing_doc_type prev_doc_type INVCONV sschinch,
                  last_trx_action_id,     --last_costing_doc_id   prev_doc_id INVCONV sschinch,
                  header_id             prev_header_id,
                  unit_cost             prev_unit_cost,
                  RANK () OVER (PARTITION BY glc.inventory_item_id, glc.organization_id, glc.cost_type_id, glc.lot_number
                                    ORDER BY glc.cost_date DESC, glc.header_id DESC) lot_cost_rank
             FROM gmf_lot_costs glc
            WHERE glc.inventory_item_id     = p_item_id
              AND glc.lot_number  = p_lot_number
              AND glc.organization_id = p_orgn_id
              AND glc.cost_type_id = p_cost_type_id
              AND glc.cost_date <= p_cost_date
          )
     WHERE lot_cost_rank < 3
     ORDER BY lot_cost_rank
    ;

  CURSOR get_cost_details_cur(p_header_id NUMBER)
  IS
    SELECT cost_cmpntcls_id,
           cost_analysis_code,
           cost_level,
           component_cost,
           burden_ind,
           cost_origin,
           frozen_ind
      FROM gmf_lot_cost_details
     WHERE header_id = p_header_id
  ;

/* Bug 4227784 - Dinesh Added this as we removed txns table from above query */
  CURSOR get_material_lot_cost_txns(p_header_id NUMBER)
  IS
    SELECT   gmlct.new_cost_ind
       FROM  gmf_material_lot_cost_txns gmlct
     WHERE   gmlct.cost_header_id = p_header_id
    ORDER BY cost_trans_id DESC
  ;

  l_prev_cost_cnt    NUMBER := 0;
  l_prev_header_id   gmf_lot_costs.header_id%TYPE;
  l_prev_prev_header_id   gmf_lot_costs.header_id%TYPE := NULL;
  l_prev_unit_cost   gmf_lot_costs.unit_cost%TYPE;
  l_cost_header_id   gmf_material_lot_cost_txns.cost_header_id%TYPE;

  l_onhand_qty       gmf_lot_costs.onhand_qty%TYPE;
  l_header_id        gmf_lot_costs.header_id%TYPE;
  l_unit_cost        gmf_lot_costs.unit_cost%TYPE;
  l_prev_trans_unit_cost  gmf_lot_cost_details.component_cost%TYPE;
  l_cmpnt_cost       gmf_lot_cost_details.component_cost%TYPE;
  l_prev_new_cost_ind   gmf_material_lot_cost_txns.new_cost_ind%TYPE;          /* Dinesh No Bug# */
  procedure_name VARCHAR2(100);

BEGIN

  procedure_name := 'Process Reversals';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

    --
  -- Running this loop only twice to see two previous cost rows.
  -- Cursor will return more than 2 rows in some cases, so had to put EXIT
  -- after 2nd iteration
  --
  /* INVCONV sschich modifications */
  FOR i in get_previous_costs_cur(transaction_row.inventory_item_id,
                                  transaction_row.lot_number,
                                  transaction_row.orgn_id,
                                  l_cost_type_id,
                                  transaction_row.trans_date
                                 )
  LOOP
      -- if following variable has count > 1 then there are previous costs before
      -- original yield.
      l_prev_cost_cnt := l_prev_cost_cnt + 1;


      IF l_prev_cost_cnt = 1
      AND (i.last_trx_source_type_id  <> 5 --transaction_row.transaction_source_type_id
           OR i.last_trx_action_id <> transaction_row.transaction_action_id)
      THEN
        -- Other types of txns after original yield. So, process this reversal
        -- as regular adjustment. This will result in incorrect avg costs. known issue
        IF l_debug_level >= l_debug_level_medium
        THEN
          fnd_file.put_line
          (fnd_file.log,'Reversals: Processing reversal as regular adjustment');
        END IF;

        process_adjustment;
        RETURN;


      ELSIF l_prev_cost_cnt = 1         -- 1st iteration
      AND   i.last_trx_source_type_id = 5
      AND   i.last_trx_action_id = transaction_row.transaction_action_id
      THEN
        -- set cost and onhand qty to zero assuming no previous costs.
        -- if prev costs exists, then we'll use those costs and qty, but will
        -- get set in the else block below in the 2nd iteration.
        IF l_debug_level >= l_debug_level_low
        THEN
          fnd_file.put_line
          (fnd_file.log, 'Reversals: This txn is (pure) reversal of previous txn');
        END IF;

        l_prev_header_id      := i.prev_header_id;
        l_cost_header_id      := i.prev_header_id; /* will be used to insert in material txns table */
        l_prev_unit_cost      := 0;
        --
        -- new_cost_ind is needed as Subledger depends on this flag to get the
        -- correct transaction costs.
        --
        -- l_prev_new_cost_ind   := i.prev_new_cost_ind;   /* Dinesh - No Bug #  Removed for 4227784*/
        /* Bug 4227784 Added instead of above line*/
        OPEN get_material_lot_cost_txns(l_prev_header_id);
        FETCH get_material_lot_cost_txns INTO l_prev_new_cost_ind;
        CLOSE get_material_lot_cost_txns;
      ELSE         -- 2nd iteration
        --
        -- Will come here if there any old costs before original yield.
        --
        IF l_debug_level >= l_debug_level_low
        THEN
          fnd_file.put_line
          (fnd_file.log,'Reversals: costs exists prior to original yield');
        END IF;
        l_prev_header_id      := i.prev_header_id;
        l_prev_prev_header_id := i.prev_header_id;
        l_prev_unit_cost      := i.prev_unit_cost;
        --
        -- new_cost_ind is needed as Subledger depends on this flag to get the
        -- correct transaction costs.
        --
        --l_prev_new_cost_ind   := i.prev_new_cost_ind; /*Dinesh - No Bug # - Removed for 4227784*/
        /* Bug 4227784 Added instead of above line*/
        OPEN get_material_lot_cost_txns(l_prev_header_id);
        FETCH get_material_lot_cost_txns INTO l_prev_new_cost_ind;
        CLOSE get_material_lot_cost_txns;

        EXIT;
      END IF;
  END LOOP;


  IF l_debug_level >= l_debug_level_low
  THEN
    fnd_file.put_line
     (fnd_file.log,'Reversals: setting unit cost to ' || l_prev_unit_cost ||
                   ' and qty to ' || (old_cost.onhand_qty + transaction_row.trans_qty));
  END IF;

  IF l_prev_cost_cnt = 0
      THEN
        fnd_file.put_line
              (fnd_file.log,'ERROR: Failed to retrieve previous costs in Process Reversals');
        RETURN;
  END IF;

  create_cost_header
  ( p_item_id         => transaction_row.inventory_item_id
  , p_lot_number      => transaction_row.lot_number
  , p_orgn_id         => transaction_row.orgn_id
  , p_cost_type_id    => l_cost_type_id
  , p_unit_cost       => l_prev_unit_cost
  , p_cost_date       => transaction_row.trans_date
  , p_onhand_qty      => old_cost.onhand_qty + transaction_row.trans_qty
  , p_trx_src_type_id => transaction_row.transaction_source_type_id
  , p_doc_id          => transaction_row.doc_id
  , p_txn_act_id      => transaction_row.transaction_action_id
  , x_header_id      => l_header_id
  , x_unit_cost      => l_unit_cost
  , x_onhand_qty     => l_onhand_qty
  , x_return_status  => l_return_status
  );


  IF l_return_status = 'S'
  THEN

        IF l_debug_level >= l_debug_level_low
        THEN
          fnd_file.put_line
          (fnd_file.log,'Reversals: Creating new cost detail row');
        END IF;

    FOR j in get_cost_details_cur(l_prev_header_id)
    LOOP

        IF l_prev_cost_cnt = 1
        THEN
          l_cmpnt_cost := 0;
        ELSIF l_prev_cost_cnt > 1
        THEN
          -- carrying forward costs before original yield
          l_cmpnt_cost := NVL(j.component_cost,0);
        END IF;

        create_cost_detail
        ( p_header_id          => l_header_id
        , p_component_class_id => j.cost_cmpntcls_id
        , p_cost_analysis_code => j.cost_analysis_code
        , p_cost_level         => j.cost_level
        , p_component_cost     => l_cmpnt_cost
        , p_burden_ind         => j.burden_ind
        , x_return_status      => l_return_status
        );

    END LOOP;

    IF l_return_status = 'S'
    THEN

      IF l_debug_level >= l_debug_level_medium
      THEN
        fnd_file.put_line
        (fnd_file.log,'Reversals: Creating new material cost transaction. the l_prev_prev_header_id is  '||l_prev_prev_header_id||' and l_cost_header_id '||l_cost_header_id);
      END IF;



      SELECT NVL(SUM(component_cost),0)
        INTO l_prev_trans_unit_cost
        FROM gmf_lot_cost_details
       WHERE header_id = DECODE(NVL(l_prev_prev_header_id, 0), 0, l_cost_header_id, -l_cost_header_id);



      create_material_transaction
      ( l_cost_header_id
      , l_cost_type_id    /*INVCONV sschinch */
      , transaction_row.trans_date
      , transaction_row.trans_qty
      , transaction_row.trans_um
      , transaction_row.trans_qty * l_prev_trans_unit_cost --old_cost.unit_cost
      , transaction_row.transaction_id
      , l_unit_cost
      , old_cost.onhand_qty + transaction_row.trans_qty
      , old_cost.unit_cost
      , old_cost.onhand_qty
      ,  l_prev_new_cost_ind
      ,  transaction_row.lot_number
      , l_return_status
      );

      IF l_return_status <> 'S'
      THEN
        RETURN;
      END IF;

    ELSE
      RETURN;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN fnd_file.put_line
       (fnd_file.log,'Failed in procedure process_reversals with error');
       fnd_file.put_line
       (fnd_file.log,SQLERRM);
       l_return_status := 'U';
END process_reversals;



--************************************************************************************************
--*  Procedure Name : PROCESS_REVERSALS2
--*
--*  Desc: New Procedure for handling batch product reversal transactions
--*   In process_reversals procedure we check whether the cost record in gmf_lot_costs
--*   just prior to reversal transaction is its Original transaction.
--*   If so, we will leap frog that record so as to reverse the effect of original transaction
--*   in the average cost of the lot. gmf_material_lot_cost_txns will be pointed to the original
--*   transaction record, so that subledger posts the entry accordingly. BUT we are not handling
--*   the case if original transactions and reversal transactions don't come next to each other.
--*   we process it as adjustment and it is a known issue.
--*
--*   To handle this issue, changed the complete logic of process_reversals.
--*   No more leap frogging. We directly get the original transaction header_id and get the orig
--*   transaction cost. With this we average it with the latest average cost available in order t
--*   reverse the orig trx from the average cost.
--*   If the current onhand_qty(before reversal) is less than or equal to the reversal trx qty
--*   then we consider it as adjustment.
--*
--* Handled in 11.5.10 as part of Bug 4769118
--*
--*  Bug 9239944 Rajesh and Parag For MAcsteel
--*  Procedure to Modified to handle WIP product returns, which are not reversals
--*  WIP product returns identified as transaction_row.transaction_source_type_id = 5
--*  AND transaction_row.transaction_action_id = 32
--*  AND transaction_row.transaction_type_id = 17   and trans_row.reverse_id IS NULL
--*  Find out the latest WIP completion record for same item, lot for the batch
--*  Material line. If there is none, then we'll return Error
--*  If found then create reversals with this transaction header
--************************************************************************************************


PROCEDURE process_reversals2
IS

  -- Bug 9239944
  CURSOR get_last_wipcompletion
  IS
      SELECT mmt.transaction_id
      FROM  gmf_lot_costs glc, gmf_material_lot_cost_txns gmt,
            mtl_material_transactions mmt
      WHERE glc.lot_number        = transaction_row.lot_number
      AND   glc.inventory_item_id = transaction_row.inventory_item_id
      AND   glc.organization_id   = transaction_row.orgn_id
      AND   glc.cost_type_id      = l_cost_type_id
      AND   glc.cost_date        <= NVL(transaction_row.trans_date, glc.cost_date)
      AND   gmt.cost_header_id    =  glc.header_id
      AND   mmt.transaction_id    = gmt.transaction_id
      AND   mmt.transaction_source_type_id = 5
      AND   mmt.transaction_action_id = 31
      AND   mmt.transaction_source_id = transaction_row.doc_id
      AND   mmt.trx_source_line_id = transaction_row.line_id
      ORDER By transaction_date desc ;

  CURSOR get_orig_trx(p_orig_trans_id NUMBER)
  IS
  SELECT DECODE(NVL(txns.new_cost_ind,0), 0, txns.cost_header_id, -txns.cost_header_id), txns.new_cost_ind
  FROM gmf_material_lot_cost_txns txns
  WHERE txns.transaction_id = p_orig_trans_id
    AND txns.cost_type_id = l_cost_type_id    -- PK 9069363 added cost_type_id and order by
  Order by cost_header_id desc;

  l_orig_trx_header_id gmf_lot_costs.header_id%TYPE;
  l_orig_trx_new_cost_ind NUMBER;
  l_orig_trx_trans_cost NUMBER;
  orig_trx_cost_tab l_cost_tab_type;

  l_onhand_qty       gmf_lot_costs.onhand_qty%TYPE;
  l_header_id        gmf_lot_costs.header_id%TYPE;
  l_unit_cost        gmf_lot_costs.unit_cost%TYPE;
  l_cmpnt_cost       gmf_lot_cost_details.component_cost%TYPE;
  i NUMBER;
  procedure_name VARCHAR2(100);
  orig_completion_transid  NUMBER;       -- Bug 9239944


BEGIN
   procedure_name := 'Process Reversals2';
    IF l_debug_level >= l_debug_level_medium  THEN     -- B9131983
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
     fnd_file.put_line(fnd_file.log,'Reversals2 getting orig_trx for txn_id '||transaction_row.reverse_id);
    END IF;

  -- Bug 9239944
    IF transaction_row.reverse_id IS NULL THEN
      -- WIP completion Return for products
      orig_completion_transid := 0 ;

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line
        (fnd_file.log,'WIP Product Return transaction ID = '||to_char(transaction_row.transaction_id)
         || ' Batch_id '|| transaction_row.doc_id || ' Material Line Id ' ||  transaction_row.line_id
         || ' Quanity ' || transaction_row.trans_qty ||' UOM '||transaction_row.trans_um  );
      END IF;

      OPEN get_last_wipcompletion ;
      FETCH get_last_wipcompletion INTO orig_completion_transid ;

      IF(get_last_wipcompletion%NOTFOUND) THEN
        CLOSE get_last_wipcompletion;
        fnd_file.put_line(fnd_file.log,'Reversals2: Error in locating the Last WIP completion ');
        l_return_status := 'E';
        RETURN;
      END IF;
      CLOSE get_last_wipcompletion;

    ELSE
      -- it means that it is a TRUE Reversals
      orig_completion_transid := transaction_row.reverse_id ;

    END IF;

    OPEN get_orig_trx(orig_completion_transid);
    FETCH get_orig_trx INTO l_orig_trx_header_id, l_orig_trx_new_cost_ind;

    IF(get_orig_trx%NOTFOUND) THEN
      CLOSE get_orig_trx;
      fnd_file.put_line(fnd_file.log,'Reversals2: Error in locating the original trx '||transaction_row.reverse_id||' of transaction'||transaction_row.transaction_id);
      l_return_status := 'E';
      RETURN;
    END IF;
    CLOSE get_orig_trx;

    IF l_debug_level >= l_debug_level_medium  THEN   -- B9131983
      fnd_file.put_line(fnd_file.log,'After get_orig_trx cost header_id  '||l_orig_trx_header_id);
    END IF;

    /* l_orig_trx_header_id directly points to trx cost. and it can be negative */
    OPEN  lot_cost_detail_cursor(l_orig_trx_header_id);
    FETCH lot_cost_detail_cursor BULK COLLECT INTO orig_trx_cost_tab;

    IF(orig_trx_cost_tab.COUNT = 0) THEN
      CLOSE lot_cost_detail_cursor;
      fnd_file.put_line(fnd_file.log,'Reversals2: Error in locating the cost detail for orig_trx '||transaction_row.reverse_id);
      l_return_status := 'E';
      RETURN;
    END IF;
    CLOSE lot_cost_detail_cursor;

    new_cost := old_cost;
    new_cost_tab := old_cost_tab;

    IF (old_cost.onhand_qty + transaction_row.trans_qty <= 0) THEN
        /* Replicate process_adjustments without create_material_transactions */
  -- This change is done to provide teh undo script for the current run of lot
  -- costing in final mode requested by MACSTEEL

        IF     old_cost.final_cost_flag = 1
        AND    old_cost.request_id <> l_request_id  --  l_final_run_flag = 0
        THEN
          clone_costs;
        END IF;

        UPDATE gmf_lot_costs
        SET    onhand_qty = onhand_qty + transaction_row.trans_qty,
        last_update_date = sysdate
        WHERE  header_id = old_cost.header_id;

        IF(SQL%ROWCOUNT = 1) THEN
          l_return_status := 'S';
        ELSE
          fnd_file.put_line(fnd_file.log,'Reversals2: Error in updating gmf_lot_costs for transaction_id: '||to_char(transaction_row.transaction_id));
          l_return_status := 'E';
          RETURN;
        END IF;

    ELSE

      merge_costs(orig_trx_cost_tab, transaction_row.trans_qty, new_cost.onhand_qty, 'A');
      create_cost_header
      ( p_item_id         => transaction_row.inventory_item_id
      , p_lot_number      => transaction_row.lot_number
      , p_orgn_id         => transaction_row.orgn_id
      , p_cost_type_id    => l_cost_type_id
      , p_unit_cost      => new_cost.unit_cost
      , p_cost_date      => transaction_row.trans_date
      , p_onhand_qty     => old_cost.onhand_qty + transaction_row.trans_qty
      , p_trx_src_type_id => transaction_row.transaction_source_type_id
      , p_txn_act_id       => transaction_row.transaction_action_id
      , p_doc_id          => transaction_row.doc_id
      , x_header_id      => l_header_id
      , x_unit_cost      => l_unit_cost
      , x_onhand_qty     => l_onhand_qty
      , x_return_status  => l_return_status
      );


      IF l_return_status = 'S' THEN
        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line(fnd_file.log,'Reversals2: Creating new cost detail row');
        END IF;

        FOR i in 1..new_cost_tab.COUNT
        LOOP
          create_cost_detail
          ( p_header_id          => l_header_id
          , p_component_class_id => new_cost_tab(i).cost_cmpntcls_id
          , p_cost_analysis_code => new_cost_tab(i).cost_analysis_code
          , p_cost_level         => new_cost_tab(i).cost_level
          , p_component_cost     => new_cost_tab(i).component_cost
          , p_burden_ind         => new_cost_tab(i).burden_ind
          , x_return_status      => l_return_status
          );
        END LOOP;

      END IF;
    END IF; /* End of if old_cost.onhand + trans_qty <= 0 */

    IF l_return_status = 'S' THEN
      l_orig_trx_trans_cost := 0;

      FOR i in 1..orig_trx_cost_tab.COUNT
      LOOP
        l_orig_trx_trans_cost := l_orig_trx_trans_cost + orig_trx_cost_tab(i).component_cost;
      END LOOP;

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line
        (fnd_file.log,'Reversals2: Creating new material cost transaction. The orig_header_id is '||l_orig_trx_header_id||' and l_header_id '||l_header_id);
      END IF;
      -- PK Bug 8730374 pass ABS when creating material transaction.
      create_material_transaction
      ( ABS(l_orig_trx_header_id)
      , l_cost_type_id
      , transaction_row.trans_date
      , transaction_row.trans_qty
      , transaction_row.trans_um
      , transaction_row.trans_qty * l_orig_trx_trans_cost
      , transaction_row.transaction_id
      , new_cost.unit_cost
      , old_cost.onhand_qty + transaction_row.trans_qty
      , old_cost.unit_cost
      , old_cost.onhand_qty
      , l_orig_trx_new_cost_ind
      , transaction_row.lot_number
      , l_return_status
      );


      IF l_return_status <> 'S' THEN
        fnd_file.put_line(fnd_file.log,'Reversals2: Error in creating material_transaction for '||to_char(transaction_row.transaction_id));
        RETURN;
      END IF;

    ELSE
      fnd_file.put_line(fnd_file.log,'Reversals2: Error in creating Cost Header/Detail for transaction '||to_char(transaction_row.transaction_id));
      RETURN;
    END IF;
   IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

 EXCEPTION
 WHEN OTHERS THEN fnd_file.put_line
   (fnd_file.log,'Failed in procedure process_reversals2 with error');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    l_return_status := 'U';
 END PROCESS_REVERSALS2;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to handle movements (TRNI/TRNR)                                                  *
    --*                                                                                            *
    --**********************************************************************************************

PROCEDURE process_movement
( p_line_type   NUMBER
, p_source_orgn NUMBER
, p_target_orgn NUMBER
, p_source_le   NUMBER
, p_target_le   NUMBER
, p_trans_date DATE
)
IS
  l_orgn_code    VARCHAR2(4);
  l_header_id    NUMBER;
  l_unit_cost    NUMBER;
  l_onhand_qty   NUMBER;
  l_method       VARCHAR2(10);
  l_ccc_id       NUMBER;
  l_a_code       VARCHAR2(4);
  l_no_of_rows   NUMBER;
  i              NUMBER;
  retval         NUMBER;
  l_msg_data     VARCHAR2(100);
  l_msg_count    NUMBER;
  l_var_return_status VARCHAR2(2);
  l_total_cost    NUMBER;

  l_src_qty       NUMBER;
  l_src_uom       VARCHAR2(3);
  l_cost_ratio    NUMBER;
  procedure_name VARCHAR2(100);



  CURSOR get_src_qty_uom IS
     select  NVL(mtln.primary_quantity, mmt.primary_quantity), -- B9131983 used NVL
            lcig.primary_uom_code
     from   mtl_material_transactions mmt,
            mtl_transaction_lot_numbers mtln,
            gmf_lot_costed_items_gt lcig
     where  mmt.transaction_id = transaction_row.transfer_transaction_id
       AND  mmt.transaction_id = mtln.transaction_id
       AND  mmt.inventory_item_id = lcig.inventory_item_id
       AND  mmt.organization_id   = lcig.organization_id;

BEGIN
   procedure_name := 'Process Movement';
   IF l_debug_level >= l_debug_level_medium
     THEN
       fnd_file.put_line
       (fnd_file.log,'Entered Procedure: '||procedure_name);
     END IF;
     -- This procedure is only called when the source and target organizations differ.

  -- If this is a debit on the source organization (line type = -1) this is equivalent to an adjustment
  -- and we must assume that there is a cost there already (in old_cost and old_cost_tab).

  -- If it is the credit on a target organization then we have to locate the costs in the source organization
  -- and create or modify the cost in the target organization with them.

  -- A complication here is that TRNI/TRNR transaction pairs can be for different companies, and this means
  -- the the company in the sending transaction might not use the same currency as the company in the
  -- receiving transaction.

  IF p_line_type = -1
  THEN
    -- This is the debit on the source organization.
    process_adjustment;

  ELSE
    -- This is the credit on the target organization. Retrieve the costs from the source organization.
    -- This section also caters for line type 0 (used in PORC transactions for internal orders)

    IF l_debug_level >= l_debug_level_medium
    THEN
      fnd_file.put_line(fnd_file.log,'At start of Process Movement, new_cost_tab is:');
      IF new_cost_tab.EXISTS(1)
      THEN
        FOR k IN 1 .. new_cost_tab.COUNT
        LOOP
          fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
          fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
          fnd_file.put_line(fnd_file.log,'Level ['||k||']: '||new_cost_tab(k).cost_level);
          fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
          fnd_file.put_line(fnd_file.log,'====================================');
        END LOOP;
      ELSE
        fnd_file.put_line(fnd_file.log,'EMPTY');
      END IF;
    END IF;
    -- As there is a chance that the two organizations could be in separate companies we need to do something
    -- to ensure we can locate a cost for the sending transaction. If the two companies involved are the same
    -- we can simply query the gmf_lot_costs table. If not we have to do dig around for costs.



      IF (p_source_le <> p_target_le)
      THEN

         -- Bug Bug 9356358 / 12.1 Bug 9400419 Query transfer price and create cost with default material component
         SELECT transfer_price INTO l_unit_cost
         FROM mtl_material_transactions
         WHERE transaction_id = transaction_row.transaction_id;


         SELECT mtl_cmpntcls_id, mtl_analysis_code INTO l_ccc_id, l_a_code
         FROM   gmf_fiscal_policies
         WHERE  legal_entity_id = p_target_le;

         IF new_cost_tab.EXISTS(1)
         THEN
            new_cost_tab.delete;
         END IF;

         new_cost_tab(1) := SYSTEM.gmf_cost_type ( l_ccc_id, l_a_code, 0, l_unit_cost, 0);

         IF l_debug_level >= l_debug_level_medium
         THEN
             fnd_file.put_line(fnd_file.log,'Intercompany transfer Transaction_id '||transaction_row.transaction_id||' Transfer Price '||l_unit_cost);
             fnd_file.put_line(fnd_file.log,'Fiscal Policy cost component '||l_ccc_id||' Analysis Code '||l_a_code||' Origin Le '||p_source_le||' Destination Le '||p_target_le);
         END IF;

         -- PK Bug Bug 9356358 / 12.1 Bug 9400419 Comment out Old code

/*        IF (1 = gmf_cmcommon.Get_Process_Item_Cost(p_api_version               => 1.0
                                                   ,p_init_msg_list             => 'T'
                                                   ,x_return_status             => l_var_return_status
                                                   ,x_msg_count                 => l_msg_count
                                                  ,x_msg_data                  => l_msg_data
                                                  ,p_inventory_item_id         => transaction_row.inventory_item_id
                                                  ,p_organization_id           =>  p_source_orgn
                                                  ,p_transaction_date          => p_trans_date
                                                  ,p_detail_flag               => 4
                                                  ,p_cost_method               => l_method
                                                  ,p_cost_component_class_id   =>l_ccc_id
                                                  ,p_cost_analysis_code        =>  l_a_code
                                                  ,x_total_cost                => l_total_cost
                                                  ,x_no_of_rows                => l_no_of_rows
                                                  ,p_lot_number                => transaction_row.lot_number
                                                 ,p_transaction_id            => NULL
                                                ) ) THEN
          IF new_cost_tab.EXISTS(1)
          THEN
            new_cost_tab.delete;
          END IF;

          FOR i IN 1..l_no_of_rows
          LOOP
            gmf_cmcommon.get_multiple_cmpts_cost
                             (v_index             => i
                             ,v_cost_cmpntcls_id  => l_ccc_id
                             ,v_cost_analysis_code=> l_a_code
                             ,v_cmpnt_amt         => l_unit_cost
                             ,v_retrieve_ind      => 4
                             ,v_status            => retval
                             );
            IF retval <> 0
            THEN
              l_return_status := 'E';
              fnd_file.put_line
              (fnd_file.log,'ERROR: Failed to retrieve single cost component in source organization '||l_org_tab(p_source_orgn));
              RETURN;
            ELSE
              -- Procedure doesn't return burden ind so coerce it to zero.
              new_cost_tab(i) := SYSTEM.gmf_cost_type ( l_ccc_id, l_a_code, 0, l_unit_cost, 0);
            END IF;
          END LOOP;
        ELSE
          IF new_cost_tab.EXISTS(1)
          THEN
            new_cost_tab.delete;
          END IF;
          OPEN  component_class_cursor( p_target_le,transaction_row.inventory_item_id,p_target_orgn,p_trans_date);
          FETCH component_class_cursor INTO l_ccc_id,l_a_code,dummy;
          IF (component_class_cursor%NOTFOUND) THEN
            l_return_status := 'E';
            fnd_file.put_line
            (fnd_file.log,'ERROR: Failed to retrieve cost multiple components in source organization '||l_org_tab(p_source_orgn));
            CLOSE component_class_cursor;
            RETURN;
          END IF;
        END IF;  */
        -- PK Bug Bug 9356358 / 12.1 Bug 9400419 Comment out Old code. Else below is for IF (p_source_le <> p_target_le) old code for within company.
       ELSE -- Else part of (p_source_le <> p_target_le)
            new_cost.header_id := NULL;
            OPEN  lot_cost_cursor(p_source_orgn, transaction_row.inventory_item_id, transaction_row.lot_number, p_trans_date,l_cost_type_id );
            FETCH lot_cost_cursor INTO new_cost;
            CLOSE lot_cost_cursor;

            IF new_cost.header_id IS NULL
            THEN
              fnd_file.put_line
              ( fnd_file.log,'ERROR: Unable to locate cost header for organization: '||l_org_tab(p_source_orgn)
              ||  ', item ID: '||transaction_row.inventory_item_id
              ||', lot Number: '||transaction_row.lot_number
              );
              l_return_status := 'E';
              RETURN;
            END IF;

            OPEN  lot_cost_detail_cursor ( new_cost.header_id );
            FETCH lot_cost_detail_cursor BULK COLLECT INTO new_cost_tab;
            CLOSE lot_cost_detail_cursor;
          END IF;

          IF l_debug_level >= l_debug_level_medium
          THEN
            fnd_file.put_line(fnd_file.log,'After reading costs from source organization, new_cost_tab is:');
            FOR k IN 1 .. new_cost_tab.COUNT
            LOOP
              fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
              fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
              fnd_file.put_line(fnd_file.log,'Level ['||k||']: '||new_cost_tab(k).cost_level);
              fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
              fnd_file.put_line(fnd_file.log,'====================================');
            END LOOP;
          END IF;


          IF NOT new_cost_tab.EXISTS(1)
          THEN
            fnd_file.put_line
            ( fnd_file.log,'ERROR: Unable to locate source cost details for organization: '||l_org_tab(p_source_orgn)
            ||', inventory item ID: '||transaction_row.inventory_item_id
            ||', lot number: '||transaction_row.lot_number /* INVCONV sschinch */
            );
            l_return_status := 'E';
            RETURN;
          END IF;

          OPEN get_src_qty_uom;
          FETCH get_src_qty_uom INTO l_src_qty, l_src_uom;
          IF get_src_qty_uom%NOTFOUND THEN
              fnd_file.put_line( fnd_file.log,'ERROR: Unable to locate source primary quantity and primary uom for the transfer transaction id: '||
                 transaction_row.transfer_transaction_id);
                l_return_status := 'E';
             CLOSE get_src_qty_uom;
             RETURN;
          END IF;
          CLOSE get_src_qty_uom;

          IF l_src_uom <> transaction_row.trans_um THEN
              fnd_file.put_line( fnd_file.log,'Source primary uom: '||l_src_uom||' and Receiving primary uom: '||transaction_row.trans_um||
                 ' are different');
              IF transaction_row.trans_qty <> 0 THEN
                 l_cost_ratio := (l_src_qty * -1)/transaction_row.trans_qty;
                 fnd_file.put_line(fnd_file.log,'Source primary qty: '||l_src_qty||', Receiving primary qty: '||transaction_row.trans_qty||
                 ', cost ratio: '||l_cost_ratio);
              ELSE
                 l_cost_ratio := 0;
                 fnd_file.put_line(fnd_file.log,'Transaction qty is zero, so making cost ratio as zero');
              END IF;

              FOR i IN 1 .. new_cost_tab.COUNT
              LOOP
                new_cost_tab(i).component_cost := new_cost_tab(i).component_cost * l_cost_ratio;
              END LOOP;

          ELSE
              fnd_file.put_line( fnd_file.log,'Source primary uom: '||l_src_uom||' and Receiving primary uom: '||transaction_row.trans_um||
                 ' are same');
              l_cost_ratio := 1;
          END IF;



          process_burdens;

          IF l_return_status <> 'S'
          THEN
            RETURN;
          END IF;

          -- At this point old_cost_tab holds the costs of the lot in the target whse (if any exist),
          -- new_cost_tab holds the costs of the lot in the source whse (these must exist) and
          -- l_burdens_cost_tab holds the costs of any burdens set up against the target whse (if any exist).
          -- We now need to see if the two organizations belong to companies that share a common
          -- currency. If we find that they don't then we have to convert the source costs to the currency
          -- used in the target before we start the merging them.

          -- PK Bug Bug 9356358 / 12.1 Bug 9400419 this code is not required. Transfer_price in MMT is already in receiving org currency.
/*          IF p_source_le <> p_target_le
          THEN
            SELECT s.base_currency_code,t.base_currency_code
            INTO   l_from_ccy_code, l_to_ccy_code
            FROM   gmf_fiscal_policies s,
                   gmf_fiscal_policies t
            WHERE  s.legal_entity_id = p_source_le
            AND    t.legal_entity_id  = p_target_le;

            IF l_from_ccy_code <> l_to_ccy_code
            THEN


              l_exchange_rate := gl_currency_api.get_closest_rate(x_from_currency => l_from_ccy_code,
                                                               x_to_currency   => l_to_ccy_code,
                                                               x_conversion_date => transaction_row.trans_date,
                                                               x_max_roll_days   => 0);



              IF l_error_status <> 0
              THEN
                fnd_file.put_line
                ( fnd_file.log
                 , 'ERROR: Unable to find exchange rate from '||l_from_ccy_code
                 ||' to '||l_to_ccy_code
                 ||' on '||transaction_row.trans_date
                );
                l_return_status := 'E';
                RETURN;
              END IF;

             FOR i IN 1 .. new_cost_tab.COUNT
              LOOP
                new_cost_tab(i).component_cost := new_cost_tab(i).component_cost * l_exchange_rate;
              END LOOP;
            END IF; -- l_from_ccy_code <> l_to_ccy_code
          END IF;  -- p_source_le <> p_target_le */

          -- PK Bug Bug 9356358 / 12.1 Bug 9400419 this code is not required. Transfer_price in MMT is already in receiving org currency.

          IF l_burdens_total <> 0
          THEN
            IF l_debug_level >= l_debug_level_medium
            THEN
              fnd_file.put_line
                (fnd_file.log,'Combining burden costs');
            END IF;

            merge_costs( l_burden_costs_tab
                       , 1
                       , 1
                      , 'C'
                       );
            new_cost.unit_cost := new_cost.unit_cost + l_burdens_total;
          END IF;

          -- We need to preserve the 'new' cost so that we can write its details separately to the
          -- merged costs. This preserved cost is also what is used when we write the new material
          -- lot cost transaction. Bug 3578680

          prd_cost := new_cost;
          prd_cost_tab := new_cost_tab;

          IF l_debug_level >= l_debug_level_medium
          THEN
            fnd_file.put_line
             (fnd_file.log,'Aggregating old costs with new costs');
          END IF;

          merge_costs( old_cost_tab
               , old_cost.onhand_qty
               , transaction_row.trans_qty
               , 'A'
               );
          create_cost_header
           ( p_item_id         => transaction_row.inventory_item_id
            , p_lot_number      => transaction_row.lot_number
            , p_orgn_id         => transaction_row.orgn_id
            , p_cost_type_id    =>  l_cost_type_id
            , p_unit_cost       => new_cost.unit_cost
            , p_cost_date       => transaction_row.trans_date
            , p_onhand_qty      => transaction_row.trans_qty + old_cost.onhand_qty
            , p_trx_src_type_id => transaction_row.transaction_source_type_id
            , p_txn_act_id       => transaction_row.transaction_action_id
            , p_doc_id          => transaction_row.doc_id
            , x_header_id       => l_header_id
            , x_unit_cost       => l_unit_cost
            , x_onhand_qty      => l_onhand_qty
            , x_return_status   => l_return_status
          );

          IF l_return_status = 'S'
          THEN
            IF l_debug_level >= l_debug_level_medium
            THEN
              fnd_file.put_line
                (fnd_file.log,'Creating new cost detail rows');
            END IF;

            -- Bug 3388974
            new_cost.header_id := l_header_id;
            new_cost.unit_cost := l_unit_cost;
            new_cost.onhand_qty := l_onhand_qty;

            FOR i IN 1..new_cost_tab.COUNT
            LOOP
              create_cost_detail
               ( l_header_id
                , new_cost_tab(i).cost_cmpntcls_id
                , new_cost_tab(i).cost_analysis_code
                , 0
                , new_cost_tab(i).component_cost
                , 0
                , l_return_status
               );

             IF l_return_status <> 'S'
             THEN
               RETURN;
             END IF;
           END LOOP;

           IF l_debug_level >= l_debug_level_medium
           THEN
             fnd_file.put_line
               (fnd_file.log,'Creating new material cost transaction');
           END IF;


           IF NOT old_cost_tab.EXISTS(1)
           THEN
             IF l_debug_level >= l_debug_level_high
             THEN
               fnd_file.put_line (fnd_file.log,'AAAAA');
             END IF;

             create_material_transaction
             ( new_cost.header_id
               , l_cost_type_id
               , transaction_row.trans_date
               , transaction_row.trans_qty
               , transaction_row.trans_um
               , new_cost.onhand_qty * new_cost.unit_cost
               , transaction_row.transaction_id
               , new_cost.unit_cost
               , transaction_row.trans_qty
               , NULL
               , NULL
               , NULL
               ,transaction_row.lot_number
               , l_return_status
             );

           ELSE
             IF l_debug_level >= l_debug_level_high
             THEN
               fnd_file.put_line (fnd_file.log,'BBBBB');
             END IF;
             create_material_transaction
             ( new_cost.header_id
               , l_cost_type_id
               , transaction_row.trans_date
               , transaction_row.trans_qty
               , transaction_row.trans_um
               , transaction_row.trans_qty * prd_cost.unit_cost -- Bug 3578680
               , transaction_row.transaction_id
               , new_cost.unit_cost
               , old_cost.onhand_qty + transaction_row.trans_qty
               , old_cost.unit_cost
               , old_cost.onhand_qty
               , 1
               ,transaction_row.lot_number
               , l_return_status
             );

             -- Bug 3578680
             FOR i IN 1..prd_cost_tab.COUNT
             LOOP
               create_cost_detail
               ( -l_header_id
               , prd_cost_tab(i).cost_cmpntcls_id
               , prd_cost_tab(i).cost_analysis_code
               , 0
               , prd_cost_tab(i).component_cost
               , 0
               , l_return_status
              );

              IF l_return_status <> 'S'
              THEN
                RETURN;
              END IF;
            END LOOP;
          END IF;
          IF l_return_status <> 'S'
          THEN
            RETURN;
          END IF;
         END IF; /* get cost */
     END IF; /* Line type */
   IF l_debug_level >= l_debug_level_medium
     THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
  EXCEPTION
  WHEN OTHERS THEN
  fnd_file.put_line
       (fnd_file.log,'Failed in procedure Process Movement with error');
       fnd_file.put_line
       (fnd_file.log,SQLERRM);
       l_return_status := 'U';

END process_movement;

--********************************************************************************************************
--*    Procedure Name : PROCESS_RECEIPT
--*
--*     Description :
--*               Procedure to handle Purchase Order Receipt.
--*
--* HISTORY
--*
--*   06-Jan-2004 Dinesh Vadivel Bug# 4095937
--*       The Lot Cost Process calculates the Exchg Rate as on the Receipt Header Date
--*        whereas the Subledger uses the "Exchg Rate Date". Modified the Lot Actual Cost Process
--*        to use the rcv_transactions.CURRENCY_CONVERSION_RATE as the Exchg Rate .
--*   2-Aug-2007 Bug 6320304/5953977 - Non-recoverable taxes ME, as part of this added unit of
--*        nonrecoverable tax to the unit cost.
--*
--********************************************************************************************************

PROCEDURE process_receipt
IS
  document_code   rcv_transactions.source_document_code%TYPE;
  source_orgn_id    NUMBER;
  target_orgn_id    NUMBER;
  source_le_id      NUMBER;
  target_le_id      NUMBER;
  l_shipped_date DATE;
  procedure_name VARCHAR2(100);
  l_rcv_transaction_id NUMBER;
BEGIN
      procedure_name := 'Process Receipt';
     IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
       fnd_file.put_line
      (fnd_file.log,'PO Receipt found: transaction ID = '||to_char(transaction_row.transaction_id));
        fnd_file.put_line
        (fnd_file.log,' Retrieving receipt details');
      END IF;

      -- The pointers in the inventory transaction link to the receipt as follows:
      -- DOC_ID is the SHIPMENT_HEADER_ID in rcv_shipment_headers
      -- LINE_ID is the TRANSACTION_ID in rcv_transactions

      -- From the row in rcv_transactions the po_unit_price (expressed in price_um so
      -- we need to convert it to item_um) is the source of the cost. There is also the
      -- received qty (expressed in recv_um so it might need converting too, although the
      -- OPM inventory transaction should have the number we need already). There are
      -- pointers in the receiving transaction to the po_header, po_line and the receipt
      -- line too.

      -- The cost component class for the lot cost details is found in table cm_cmpt_mtl
      -- with a default from the fiscal policy if there isn't an entry in the table.

      -- Finally we have to keep in mind that a PORC transaction could be for a -ve quantity
      -- if goods are being returned to a vendor. In this respect, we shouldn't ever encounter
      -- the situation where uncosted goods are being sent back as we must have received them
      -- beforehand.

      -- Now using source_doc_unit_of_measure instead of unit_of_measure

      -- B3514108, added source_document_code to select statement so we can see if this PORC is
      -- actually an RMA. Note that source_doc_unit_of_measure is NULL for an RMA so we have to
      -- perform an outer join.

	/* Bug 6320304/5953977        SELECT t.po_unit_price, */
      SELECT  t.po_unit_price + DECODE(nvl(pda.quantity_ordered,0),0,0, (nvl(pda.nonrecoverable_tax,0)/pda.quantity_ordered)),
               t.currency_code,
               t.quantity,
               u.uom_code,
               t.source_document_code,
               NVL(t.currency_conversion_rate,1),
               t.transaction_id
      INTO    receipt_unit_cost,
              receipt_ccy,
              receipt_qty,
              receipt_uom,
              document_code,
              l_exchange_rate,
              l_rcv_transaction_id
      FROM    rcv_transactions t, mtl_units_of_measure u, mtl_material_transactions mmt -- jboppana
      		, po_distributions_all pda
      WHERE   t.source_doc_unit_of_measure = u.unit_of_measure(+)
      AND     t.transaction_id = mmt.rcv_transaction_id
    --  AND     mmt.transaction_source_id = transaction_row.doc_id
      AND    t.po_distribution_id = pda.po_distribution_id (+)  /* Bug 6320304/5953977 */
      AND     mmt.transaction_id = transaction_row.transaction_id     ;

      -- If we're processing an RMA treat it as an adjustment
      -- and make a swift exit.
      /******** Bug  4038722 - Dinesh Vadivel - Convert to Base Currency, if Receipt currency is different **********/
      /*     Added the query to pick up the base currency in the main lot_cost_rollup procedure  */
      IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line
        (fnd_file.log,' receipt details found rcv transaction id'||l_rcv_transaction_id);
      END IF;

      IF ( l_base_ccy_code <>  receipt_ccy)  THEN /* Check if the receipt currency is the same as the base currency */
        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line   (fnd_file.log,' Converting Receipt_unit_cost : '||receipt_unit_cost||' Receipt Currency : '||receipt_ccy||
                               ' to Base Currency : '||l_base_ccy_code||'. New_receipt_unit_cost : '||receipt_unit_cost * l_exchange_rate||'. Exchange Rate is : '||l_exchange_rate);
        END IF;

        receipt_unit_cost := receipt_unit_cost * l_exchange_rate;


     END IF;

      /******** Bug  4038722 - Dinesh Vadivel - Convert to Base Currency, if Receipt currency is different - End **********/


      IF document_code = 'RMA' THEN
        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,' Processing PORC txn as an RMA');
        END IF;
        process_adjustment;
        RETURN;
      END IF;

      -- End of B3514108 changes

      -- B3513668 If this is an internal order treat it as a transfer or movement

      IF document_code = 'REQ' THEN
        SELECT
          mmt.organization_id,
          mmt.transfer_organization_id,
          hoi1.org_information2,
          hoi2.org_information2,
          r.shipped_date
        INTO
          target_orgn_id,source_orgn_id, source_le_id, target_le_id, l_shipped_date
        FROM
          rcv_transactions t,
          mtl_material_transactions mmt,
          rcv_shipment_headers r,
          rcv_shipment_lines rsl,
          po_headers_all poh,
          hr_organization_information hoi1,
          hr_organization_information hoi2
        WHERE
                t.source_document_code = 'REQ'
        AND     t.transaction_id = mmt.rcv_transaction_id
        AND     mmt.transaction_id = transaction_row.transaction_id
        AND     mmt.organization_id = hoi2.organization_id
        AND     mmt.transfer_organization_id = hoi1.organization_id
        AND     hoi1.org_information_context = 'Accounting Information'
        AND     hoi2.org_information_context = 'Accounting Information'
        AND     t.shipment_header_id = r.shipment_header_id
        AND     r.receipt_source_code in ('INTERNAL ORDER')
        AND     t.shipment_line_id = rsl.shipment_line_id
        AND     t.po_header_id = poh.po_header_id (+);

         /* INVCONV sschinch */
         -- process_movement (1, source_whse, target_whse, source_co, target_co,l_shipped_date);
            process_movement (1, source_orgn_id, target_orgn_id, source_le_id, target_le_id,l_shipped_date);

        RETURN;
      END IF;

      /* Inter org transfers -- Intransit*/
      IF document_code = 'INVENTORY' THEN
        SELECT
          mmt.organization_id,
          mmt.transfer_organization_id,
          hoi1.org_information2,
          hoi2.org_information2,
          r.shipped_date
        INTO
          target_orgn_id,source_orgn_id, source_le_id, target_le_id, l_shipped_date
        FROM
          rcv_transactions t,
          mtl_material_transactions mmt,
          rcv_shipment_headers r,
          rcv_shipment_lines rsl,
          po_headers_all poh,
          hr_organization_information hoi1,
          hr_organization_information hoi2
        WHERE
                t.source_document_code = 'INVENTORY'
        AND     t.transaction_id = mmt.rcv_transaction_id
        AND     mmt.transaction_id = transaction_row.transaction_id
        AND     mmt.organization_id = hoi2.organization_id
        AND     mmt.transfer_organization_id = hoi1.organization_id
        AND     hoi1.org_information_context = 'Accounting Information'
        AND     hoi2.org_information_context = 'Accounting Information'
        AND     t.shipment_header_id = r.shipment_header_id
        AND     r.receipt_source_code in ('INVENTORY')
        AND     t.shipment_line_id = rsl.shipment_line_id
        AND     t.po_header_id = poh.po_header_id (+);

         /* INVCONV sschinch */
         -- process_movement (1, source_whse, target_whse, source_co, target_co,l_shipped_date);
            process_movement (1, source_orgn_id, target_orgn_id, source_le_id, target_le_id,l_shipped_date);

        RETURN;
      END IF;

      -- If we reach here the PORC transaction is for a true PO Receipt
      IF receipt_unit_cost IS NULL THEN
        fnd_file.put_line
        (fnd_file.log,'ERROR: Could not retrieve PO unit price for transaction ID '||to_char(transaction_row.transaction_id));
        l_return_status := 'E';
        RETURN;
      END IF;

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line
        (fnd_file.log,'Received '||transaction_row.trans_qty ||' '||transaction_row.trans_um
         ||' at a unit price of '||l_base_ccy_code||' '||to_char(receipt_unit_cost)); /* Bug 4038722 - Changed the receipt_ccy to l_base_ccy_code. */
      END IF;

      IF transaction_row.trans_um <> receipt_uom THEN
         -- convert unit cost of receipt to a unit cost that is in the OPM transaction uom
         -- BUG 3485915 Reversed the uom parameters in the call
         -- B9131983
      IF l_debug_level >= l_debug_level_medium THEN
 		       fnd_file.put_line
		       (fnd_file.log,'Before UOM Conversion for lot_unit_cost: convert from '
		       ||transaction_row.trans_um
		       ||' to '||receipt_uom
		       ||' for item ID '
		       ||transaction_row.inventory_item_id
		       ||' for Lot Number '
		       ||transaction_row.lot_number
		       ||' Receipt Unit Cost '
		       ||receipt_unit_cost
		       );
      END IF;
        lot_unit_cost := 0 ;
        lot_unit_cost :=
               INV_CONVERT.INV_UM_CONVERT(ITEM_ID       => transaction_row.inventory_item_id
                                          ,LOT_NUMBER    => transaction_row.lot_number
                                          ,ORGANIZATION_ID => transaction_row.orgn_id
                                          ,PRECISION     => 5
                                          ,FROM_QUANTITY => receipt_unit_cost
                                          ,FROM_UNIT     => transaction_row.trans_um
                                          ,TO_UNIT       => receipt_uom
                                          ,FROM_NAME     => NULL
                                          ,TO_NAME       => NULL
                                         );

        IF lot_unit_cost = -99999  THEN  -- B9131983
          fnd_file.put_line
          (fnd_file.log,'ERROR: Could not convert PO receipt uom for transaction ID '||to_char(transaction_row.transaction_id));
          l_return_status := 'E';
          RETURN;
        END IF;

      ELSE
        lot_unit_cost := receipt_unit_cost;
      END IF;

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Retrieving burdens for receipt');
      END IF;

      process_burdens;

      IF   l_return_status <> 'S' THEN
        RETURN;
      END IF;

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Retrieving Freight and special charges for receipt');
      END IF;

      get_special_charges;

      IF l_return_status <> 'S' THEN
        RETURN;
      END IF;

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line
        (fnd_file.log,'Retrieving component class and analysis code for cost details');
      END IF;

      OPEN component_class_cursor
           (l_le_id, transaction_row.inventory_item_id, transaction_row.orgn_id,transaction_row.trans_date);
      FETCH component_class_cursor INTO component_class_id, cost_analysis_code, dummy;
      CLOSE component_class_cursor;

      IF l_debug_level >= l_debug_level_medium  THEN
        fnd_file.put_line
        (fnd_file.log,'Setting up lot cost of PO receipt');
        fnd_file.put_line
        (fnd_file.log,'Lot cost of PO Receipt is: ' || to_char(lot_unit_cost));
        fnd_file.put_line
        (fnd_file.log,'Initialising new_cost_tab(1)' || to_char(lot_unit_cost));
      END IF;

      new_cost_tab(1) :=  SYSTEM.gmf_cost_type
                          ( component_class_id
                          , cost_analysis_code
                          , 0
                          , lot_unit_cost
                          , 0
                          );

      new_cost.unit_cost := lot_unit_cost;

      IF NOT old_cost_tab.EXISTS(1) THEN
        -- No costing data for this lot/organization exists

        IF l_burdens_total <> 0 THEN
          IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line
            (fnd_file.log,'Merging burden costs');
          END IF;

          merge_costs( l_burden_costs_tab
                     , 0
                     , transaction_row.trans_qty
                     , 'C'
                     );

       END IF;

       IF l_acquisitions_total <> 0 THEN
         IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line
            (fnd_file.log,'Merging acquisition costs');
         END IF;

         merge_costs( l_acqui_cost_tab
                     , 0
                     , transaction_row.trans_qty
                     , 'C'
                     );

      END IF;

      lot_unit_cost := lot_unit_cost + l_burdens_total + l_acquisitions_total;

      l_onhand_qty := transaction_row.trans_qty;

      IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,'Finished setting up costs for PO Receipt. Lot unit cost is:'||to_char(lot_unit_cost));
      END IF;
    ELSE
      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line
          (fnd_file.log,'Merging old costs with new cost');
      END IF;

      IF l_burdens_total <> 0 THEN
        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line
            (fnd_file.log,'Merging burden costs');
        END IF;

        merge_costs( l_burden_costs_tab
                    , transaction_row.trans_qty
                    , old_cost.onhand_qty
                    , 'C'
                    );

      END IF;

      IF l_acquisitions_total <> 0  THEN
        IF l_debug_level >= l_debug_level_medium THEN
           fnd_file.put_line (fnd_file.log,'Merging Special Charges');
        END IF;

          merge_costs( l_acqui_cost_tab
                     , transaction_row.trans_qty
                     , old_cost.onhand_qty
                     , 'C'
                     );

      END IF;

        -- Bug 3578680
        prd_cost := new_cost;
        prd_cost_tab := new_cost_tab;

        merge_costs( old_cost_tab
                   , old_cost.onhand_qty
                   , transaction_row.trans_qty
                   , 'A'
                   );

        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line(fnd_file.log,'Lot_unit_cost        = '||lot_unit_cost);
          fnd_file.put_line(fnd_file.log,'l_burdens_total      = '||l_burdens_total);
          fnd_file.put_line(fnd_file.log,'l_acquisitions_total = '||l_acquisitions_total);
          fnd_file.put_line(fnd_file.log,'old_onhand           = '||old_cost.onhand_qty);
          fnd_file.put_line(fnd_file.log,'old_unit_cost        = '||old_cost.unit_cost);
          fnd_file.put_line(fnd_file.log,'trans_qty            = '||transaction_row.trans_qty);
        END IF;

        lot_unit_cost := new_cost.unit_cost;

        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,'Finished setting up revised costs for PO Receipt. Lot unit cost is:'||to_char(lot_unit_cost));
        END IF;

         l_onhand_qty := transaction_row.trans_qty + old_cost.onhand_qty;

      END IF;

      create_cost_header
      ( transaction_row.inventory_item_id
      , transaction_row.lot_number
      , transaction_row.orgn_id
      , l_cost_type_id
      , lot_unit_cost
      , transaction_row.trans_date
      , l_onhand_qty
      , transaction_row.doc_id
      , transaction_row.transaction_source_type_id
      , transaction_row.transaction_action_id
      , new_cost.header_id
      , new_cost.unit_cost
      , new_cost.onhand_qty
      , l_return_status
      );

      IF l_return_status = 'S' THEN
      -- If header creation success then
        FOR i in 1 .. new_cost_tab.COUNT
        LOOP
          create_cost_detail
          ( new_cost.header_id
          , new_cost_tab(i).cost_cmpntcls_id
          , new_cost_tab(i).cost_analysis_code
          , 0
          , new_cost_tab(i).component_cost
          , 0
          , l_return_status
          );

          IF l_return_status <> 'S' THEN
            RETURN;
          END IF;

        END LOOP;

        IF l_return_status = 'S' THEN
          IF NOT old_cost_tab.EXISTS(1) THEN
            create_material_transaction
            ( new_cost.header_id
            , l_cost_type_id
            , transaction_row.trans_date
            , transaction_row.trans_qty
            , transaction_row.trans_um
            , new_cost.onhand_qty * new_cost.unit_cost
            , transaction_row.transaction_id
            , new_cost.unit_cost
            , transaction_row.trans_qty
            , NULL
            , NULL
            , NULL
            , transaction_row.lot_number
            , l_return_status
            );
          ELSE
            -- Bug 3578680 Write the cost details with a negated header
            FOR i in 1 .. prd_cost_tab.COUNT
            LOOP
              create_cost_detail
              ( -new_cost.header_id
              , prd_cost_tab(i).cost_cmpntcls_id
              , prd_cost_tab(i).cost_analysis_code
              , 0
              , prd_cost_tab(i).component_cost
              , 0
              , l_return_status
              );

              IF l_return_status <> 'S' THEN
                RETURN;
              END IF;

            END LOOP;

            create_material_transaction
            ( new_cost.header_id
            , l_cost_type_id
            , transaction_row.trans_date
            , transaction_row.trans_qty
            , transaction_row.trans_um
            , prd_cost.unit_cost*transaction_row.trans_qty
            , transaction_row.transaction_id
            , new_cost.unit_cost
            , new_cost.onhand_qty
            , old_cost.unit_cost
            , old_cost.onhand_qty
            , 1
            ,transaction_row.lot_number
            , l_return_status
            );

          END IF;

        END IF;
      END IF;
     IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
END process_receipt;


    --**********************************************************************************************
    --*                                                                                            *
    --* Lot Cost audit- printing to log file.                                                      *
    --*                                                                                            *
    --**********************************************************************************************


PROCEDURE lot_cost_audit
     ( p_item_id	NUMBER
     , p_lot_number  	VARCHAR2
     , p_orgn_id	NUMBER
     , p_batch_id	NUMBER
     , p_date_costed	DATE
     , p_steps		SYSTEM.GMF_STEP_TAB
     )
IS

  l_item_id       NUMBER;
  l_lot_number      VARCHAR2(80);
  l_batch_id      NUMBER;
  l_date_costed   DATE;
  i               NUMBER;
  j               NUMBER;
  k               NUMBER;
  l               NUMBER;
  l_item_no       VARCHAR2(2000);
  l_batch_no      VARCHAR2(32);
  l_plant_code    VARCHAR2(4);
  l_resources     VARCHAR2(32);
  l_cost_analysis_code          VARCHAR2(4);
  l_cost_component_class_code   VARCHAR2(16);
  procedure_name VARCHAR2(100);


BEGIN
   procedure_name := 'Lot Cost Audit';

    -- Retrieve data in a form that the user will understand
    SELECT item_number INTO l_item_no FROM mtl_item_flexfields
    WHERE inventory_item_id = p_item_id AND organization_id = p_orgn_id;

    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
    fnd_file.put_line
    (fnd_file.log, 'Lot cost breakdown for item '
    ||l_item_no
    ||' lot '
    ||l_lot_number
    ||' created by batch '
    ||l_plant_code
    ||' '
    ||l_batch_no
    ||' in organization '
    ||p_orgn_id
    ||' on '
    ||to_char(p_date_costed)
    );

    fnd_file.put_line
    (fnd_file.log, '==============================================================================================');

      --
      -- umoogala 26-dec-03: program is failing with ORA error when there are no batch steps
      --
       IF NOT l_step_tab.EXISTS(1) THEN
         fnd_file.put_line(fnd_file.log,'No batch steps to print.');
         RETURN;
       END IF;

      fnd_file.put_line(fnd_file.log,' ');

      FOR i IN 1..l_step_tab.count
      LOOP
        fnd_file.put_line
        (fnd_file.log,'Dump of step index '||to_char(i));
        fnd_file.put_line
        (fnd_file.log,'---------------------');
        fnd_file.put_line
        (fnd_file.log,'Step ID         = '||to_char(l_step_tab(i).current_step_id));
        fnd_file.put_line
        (fnd_file.log,'Step qty        = '
        ||to_char(ROUND(l_step_tab(i).step_qty,2))||' '||l_step_tab(i).step_qty_uom);
        fnd_file.put_line
        (fnd_file.log,'Output qty      = '
        ||to_char(ROUND(l_step_tab(i).output_qty,2))||' '||l_step_tab(i).step_qty_uom);
        fnd_file.put_line
        (fnd_file.log,'  ');

        fnd_file.put_line
        (fnd_file.log,'  Current Costs');
        fnd_file.put_line
        (fnd_file.log,'  -------------');

        IF l_step_tab(i).current_costs.EXISTS(1) THEN
          FOR j IN 1..l_step_tab(i).current_costs.count
          LOOP
            fnd_file.put_line
            (fnd_file.log,'  Component Class ID     = '
            ||to_char(l_step_tab(i).current_costs(j).cost_cmpntcls_id));
            fnd_file.put_line
            (fnd_file.log,'  Cost Analysis Code     = '
            ||l_step_tab(i).current_costs(j).cost_analysis_code);
            fnd_file.put_line
            (fnd_file.log,'  Cost Level             = '
            ||to_char(l_step_tab(i).current_costs(j).cost_level));
            fnd_file.put_line
            (fnd_file.log,'  Component Cost         = '
            ||to_char(ROUND(l_step_tab(i).current_costs(j).component_cost,2)));
            fnd_file.put_line(fnd_file.log,' ');
          END LOOP;
        ELSE
          fnd_file.put_line(fnd_file.log,'  This step has no current costs');
        END IF;

        fnd_file.put_line
        (fnd_file.log,'  Inherited Costs');
        fnd_file.put_line
        (fnd_file.log,'  ---------------');
        IF l_step_tab(i).inherited_costs.EXISTS(1) THEN
          FOR j IN 1..l_step_tab(i).inherited_costs.count
          LOOP
            fnd_file.put_line
            (fnd_file.log,'  Component Class ID     = '
            ||to_char(l_step_tab(i).inherited_costs(j).cost_cmpntcls_id));
            fnd_file.put_line
            (fnd_file.log,'  Cost Analysis Code     = '
            ||l_step_tab(i).inherited_costs(j).cost_analysis_code);
            fnd_file.put_line
            (fnd_file.log,'  Cost Level             = '
            ||to_char(l_step_tab(i).inherited_costs(j).cost_level));
            fnd_file.put_line
            (fnd_file.log,'  Component Cost         = '
            ||to_char(ROUND(l_step_tab(i).inherited_costs(j).component_cost,2)));
            fnd_file.put_line(fnd_file.log,' ');
          END LOOP;
        ELSE
          fnd_file.put_line(fnd_file.log,'  This step has no inherited costs');
        END IF;

        fnd_file.put_line
        (fnd_file.log,'  Step Costs');
        fnd_file.put_line
        (fnd_file.log,'  ---------------');
        IF l_step_tab(i).step_costs.EXISTS(1) THEN
          FOR j IN 1..l_step_tab(i).step_costs.count
          LOOP
            fnd_file.put_line
            (fnd_file.log,'  Component Class ID     = '
            ||to_char(l_step_tab(i).step_costs(j).cost_cmpntcls_id));
            fnd_file.put_line
            (fnd_file.log,'  Cost Analysis Code     = '
            ||l_step_tab(i).step_costs(j).cost_analysis_code);
            fnd_file.put_line
            (fnd_file.log,'  Cost Level             = '
            ||to_char(l_step_tab(i).step_costs(j).cost_level));
            fnd_file.put_line
            (fnd_file.log,'  Component Cost         = '
            ||to_char(ROUND(l_step_tab(i).step_costs(j).component_cost,2)));
            fnd_file.put_line(fnd_file.log,' ');
          END LOOP;
        ELSE
          fnd_file.put_line(fnd_file.log,'  This step has no step costs - THIS SHOULD NEVER HAPPEN');
        END IF;


        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line
        (fnd_file.log,'  Subsequent steps');
        fnd_file.put_line
        (fnd_file.log,'  ----------------');
        IF l_step_tab(i).dependencies(1).step_index IS NULL THEN
          fnd_file.put_line(fnd_file.log,'  This is a terminal step');
        ELSE
          FOR j IN 1..l_step_tab(i).dependencies.count
          LOOP
            fnd_file.put_line
            (fnd_file.log,'  Step index      = '||to_char(l_step_tab(i).dependencies(j).step_index));
            fnd_file.put_line
            (fnd_file.log,'  Step ID         = '||to_char(l_step_tab(i).dependencies(j).batchstep_id));
            fnd_file.put_line
            (fnd_file.log,'  Step qty        = '
            ||to_char(ROUND(l_step_tab(i).dependencies(j).step_qty,2))
            ||l_step_tab(i).dependencies(j).step_qty_uom);
            fnd_file.put_line(fnd_file.log,' ');
          END LOOP;
        END IF;

        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line
        (fnd_file.log,'  Materials');
        fnd_file.put_line
        (fnd_file.log,'  ---------');

        IF l_step_tab(i).materials.EXISTS(1) THEN
          FOR j in 1..l_step_tab(i).materials.count
          LOOP
            fnd_file.put_line
            (fnd_file.log,'  Trans ID      = '||to_char(l_step_tab(i).materials(j).trans_id));
            fnd_file.put_line
            (fnd_file.log,'  Legal Entity       = '||l_step_tab(i).materials(j).legal_entity_id);
            fnd_file.put_line
            (fnd_file.log,'  Organization      = '||l_org_tab(l_step_tab(i).materials(j).organization_id));
            fnd_file.put_line
            (fnd_file.log,'  Item ID       = '||to_char(l_step_tab(i).materials(j).item_id));
            fnd_file.put_line
            (fnd_file.log,'  Lot Number        = '||to_char(l_step_tab(i).materials(j).lot_number));
            fnd_file.put_line
            (fnd_file.log,'  Line type     = '||to_char(l_step_tab(i).materials(j).line_type));
            fnd_file.put_line
            (fnd_file.log,'  Trans Qty     = '||to_char(l_step_tab(i).materials(j).trans_qty)
            ||l_step_tab(i).materials(j).trans_um);
            fnd_file.put_line
            (fnd_file.log,'  Trans Date    = '
            ||to_char(l_step_tab(i).materials(j).trans_date,'DD-Mon-YYYY HH24:MI:SS'));
            fnd_file.put_line
            (fnd_file.log,'  Lot Cost Flag = '||to_char(l_step_tab(i).materials(j).lot_costed_flag));
            fnd_file.put_line
            (fnd_file.log,'  Contribution  = '||to_char(l_step_tab(i).materials(j).step_contribution));
            fnd_file.put_line
            (fnd_file.log,'  Trans Cost    = '||to_char(ROUND(l_step_tab(i).materials(j).trans_cost,2)));
            fnd_file.put_line
            (fnd_file.log,' ');
            fnd_file.put_line
            (fnd_file.log,'    Cost Details for material transaction '
            ||to_char(l_step_tab(i).materials(j).trans_id));
            fnd_file.put_line
            (fnd_file.log,'    ----------------------------------------------');

            IF l_step_tab(i).materials(j).cost_details.EXISTS(1) THEN
              FOR k IN 1..l_step_tab(i).materials(j).cost_details.count
              LOOP
                fnd_file.put_line
                (fnd_file.log,'    Component Class ID     = '
                ||to_char(l_step_tab(i).materials(j).cost_details(k).cost_cmpntcls_id));
                fnd_file.put_line
                (fnd_file.log,'    Cost Analysis Code     = '
                ||l_step_tab(i).materials(j).cost_details(k).cost_analysis_code);
                fnd_file.put_line
                (fnd_file.log,'    Cost Level             = '
                ||to_char(l_step_tab(i).materials(j).cost_details(k).cost_level));
                fnd_file.put_line
                (fnd_file.log,'    Component Cost         = '
                ||to_char(ROUND(l_step_tab(i).materials(j).cost_details(k).component_cost,2)));
                fnd_file.put_line(fnd_file.log,' ');
              END LOOP;
            ELSE
              fnd_file.put_line(fnd_file.log,'    No costs exist for this material');
            END IF;
          END LOOP;
        ELSE
          fnd_file.put_line(fnd_file.log,'  This step has no associated materials');
        END IF;

        fnd_file.put_line(fnd_file.log,' ');
        fnd_file.put_line
        (fnd_file.log,'  Resources');
        fnd_file.put_line
        (fnd_file.log,'  ---------');

        IF l_step_tab(i).resources.EXISTS(1) THEN
          FOR j in 1..l_step_tab(i).resources.count
          LOOP
            fnd_file.put_line
            (fnd_file.log,'  Trans ID      = '||to_char(l_step_tab(i).resources(j).trans_id));
            fnd_file.put_line
            (fnd_file.log,'  Orgn Id     = '||l_org_tab(l_step_tab(i).resources(j).organization_id));
            fnd_file.put_line
            (fnd_file.log,'  Resource      = '||l_step_tab(i).resources(j).resources);
            fnd_file.put_line
            (fnd_file.log,'  Resource Usage= '||to_char(l_step_tab(i).resources(j).resource_usage)
            ||l_step_tab(i).resources(j).trans_um);
            fnd_file.put_line
            (fnd_file.log,'  Trans Date    = '
            ||to_char(l_step_tab(i).resources(j).trans_date,'DD-Mon-YYYY HH24:MI:SS'));
            fnd_file.put_line
            (fnd_file.log,'  Trans Cost    = '||to_char(ROUND(l_step_tab(i).resources(j).trans_cost,2)));
            fnd_file.put_line
            (fnd_file.log,' ');
            fnd_file.put_line
            (fnd_file.log,'    Cost Details for resource transaction '
            ||to_char(l_step_tab(i).resources(j).trans_id));
            fnd_file.put_line
            (fnd_file.log,'    ---------------------------------------------');

            IF l_step_tab(i).resources(j).cost_details.EXISTS(1)
            THEN
              FOR k IN 1..l_step_tab(i).resources(j).cost_details.count
              LOOP
                fnd_file.put_line
                (fnd_file.log,'    Component Class ID     = '
                ||to_char(l_step_tab(i).resources(j).cost_details(k).cost_cmpntcls_id));
                fnd_file.put_line
                (fnd_file.log,'    Cost Analysis Code     = '
                ||l_step_tab(i).resources(j).cost_details(k).cost_analysis_code);
                fnd_file.put_line
                (fnd_file.log,'    Cost Level             = '
                ||to_char(l_step_tab(i).resources(j).cost_details(k).cost_level));
                fnd_file.put_line
                (fnd_file.log,'    Component Cost         = '
                ||to_char(ROUND(l_step_tab(i).resources(j).cost_details(k).component_cost,2)));
                fnd_file.put_line(fnd_file.log,' ');
              END LOOP;
            ELSE
              fnd_file.put_line(fnd_file.log,'    This resource has no costs');
            END IF;
          END LOOP;
        ELSE
          fnd_file.put_line(fnd_file.log,'  This step has no associated resources');
        END IF;
      END LOOP;
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);

END lot_cost_audit;

--********************************************************************************************************
    --*    Procedure Name : PROCESS_BATCH
    --*
    --*     Description :
    --*               Procedure to handle manufactured lots.
    --*
    --* HISTORY
    --*
    --*  15-Dec-2004 Dinesh Vadivel Bug# 4053149
    --*    Earlier we were handling only two cases in the step dependency chain
    --*     1. if no routing call the explosion_cursor_nr.
    --*     2. if there is routing and dependent_steps == 0 then we will create n-1
    --*          virtual rows in gme_batch_step_dependencies
    --*    Now changed the code to handle the following cases if there is routing present
    --*     1. All the steps have Dependency defined - Directly call the explosion_cursor
    --*     2. Single Step Batch. Obviously No Dependency - So call explosion_cursor_ss
    --*     3. All steps are Independent. Here create n-1 virtual rows in dependency table
    --*         and then call the explosion_cursor
    --*     4. Few steps have dependency defined by user and Few are independent
    --*           Here, we have to add virtual rows in dependency table only for those
    --*           independent rows. For this we use a query and find the Min(batchstep_id)
    --*           and insert these independent rows above it.
    --*
    --*  Bug 4094132 - 20-Jan-2005 - Girish Jha Added a condition to set the new local variable
    --*                               l_step_output_qty to 0 or Null.
    --*
    --* 03-Feb-2005 - Bug 4144329 - Dinesh Vadivel - If there is no cost defined for Resource
    --*            then don't stop by setting the cost as uncostable. Just give a warning and ignore
    --*            the resources.
    --* 12-MAR-2009  Hari Luthra Bug 7317270
    --*             FETCH of the individual cusrsor have initialization like
    --*                l_step_tab(i).resources := SYSTEM.gmf_rsrc_tab();
--********************************************************************************************************

PROCEDURE process_batch
IS
  l_cost_factor         NUMBER;
  l_tran_qty            NUMBER;
  l_um_type             VARCHAR2(25);
  ing_tab               SYSTEM.gmf_matl_tab;
  prd_tab               SYSTEM.gmf_matl_tab;
  l_new_cost            NUMBER;
  l_step_output_qty     NUMBER;      -- Bug 4094132 Added
  l_count               NUMBER;      -- Bug 4057323
  l_unassociated_prds   NUMBER;      -- Bug 4057323
  l_temp_qty            NUMBER :=1;  -- B9131983
  l_temp_trans_qty      NUMBER :=1;  -- B9131983
  l_actual_line_qty     NUMBER :=1;  -- B9131983
  l_odd_even            NUMBER := NULL ;  -- B9239944
  l_total_materials     NUMBER := NULL ;  -- B9239944

    /***** Bug 4227784 - Dinesh - The Below explanation is correct. But
     if we use the total_item_qty obtained from the below cursor, then the
     case in which the same product is allocated in multiple lines may give
     wrong cost. So we have to use actual_line_qty instead of
     total_item_qty *****/

    /***** Bug 4057323 - Dinesh - Added the below cursor *****/
    -- Eg: Consider we have two products P1 and P2 having cost allocation factor
    -- of 0.7 and 0.3 respectively.  P1 has 10LB which is yielded into two lots L1(8LB)
    -- L2(2LB) . P2 has 20LB yielded into one single Lot. Let us assume Total Ingredient
    -- Cost is 300$
    -- In the above case when we use the Cost Allocation Factor, the product P1 gets 210$ (300 * 0.7)
    -- and P2 gets 90$ (300 * 0.3). Now we need to approtion the cost of P1 into its Lots L1 and L2.
    -- It is done as L1 gets 210$ * 8/(8+2) = 168$ and L2 gets 210$ * 2/(2+8) = 42$ . This is total cost the
    -- lots L1 and L2 gets. So unit price of these lots will become as 21$ each.
    -- Here the denominator (8+2) is obtained using the following newly added query.

  /***** Bug 4053149  Dinesh Vadivel - Start *****/
  l_min_dep_step_id       NUMBER;
  l_cur_step_id           NUMBER;
  l_independent_steps_cnt NUMBER;
  procedure_name VARCHAR2(100);


  TYPE l_independent_steps_type IS TABLE OF
        gme_batch_steps.batchstep_id%TYPE INDEX BY BINARY_INTEGER;
  l_independent_steps  l_independent_steps_type;

  -- we'll add order by...doesn't harm. since data is not setup properly, we'll assume
  -- steps are in order, at least.

  /* Cursor to get the details of Independent Steps.
  ** i.e., Steps without any dependency defined */
  CURSOR independent_steps_cursor(p_batch_id NUMBER)
  IS
     SELECT batchstep_id
       FROM gme_batch_steps
      WHERE batch_id = p_batch_id
        AND batchstep_id NOT IN
             (
               SELECT batchstep_id
                 FROM gme_batch_step_dependencies
                WHERE batch_id = p_batch_id
                UNION ALL
               SELECT dep_step_id
                 FROM gme_batch_step_dependencies
                WHERE batch_id = p_batch_id
             )
      ORDER BY batchstep_id
  ;

   /***** Bug 4053149  Dinesh Vadivel - End *****/
   x_mtl_analysis_code  varchar2(5) ;   /* B9131983 */
   x_mtl_cmpntcls_id    NUMBER;         /* B9131983 */
BEGIN

   procedure_name := 'Process Batch';
   IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;

   l_skip_this_batch  := FALSE;
   l_skip_this_txn    := FALSE;
   l_cost_accrued     := FALSE;

   /* B9131983 If cost is ZERO or component is not available
      select the default value from fiscal policy and use it in cost details */
   SELECT mtl_analysis_code, mtl_cmpntcls_id
     INTO x_mtl_analysis_code, x_mtl_cmpntcls_id
     FROM GMF_FISCAL_POLICIES WHERE legal_entity_id = l_le_id ;

      -- We're in business  . Will reach here only if batch_status is in (3,4)

      IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line
        (fnd_file.log,'Batch is eligible for lot costing');
      END IF;

     l_skip_this_batch := FALSE;

      -- If this is a product line then we need to perform a complete explosion of the batch
      -- steps. This will retrieve the steps in the correct sequence dependencies together
      -- with all associated material and resource transactions.

     IF transaction_row.line_type = 1 THEN -- Don't explode for byproducts
       IF l_debug_level >= l_debug_level_medium THEN
         fnd_file.put_line
         (fnd_file.log,'About to explode batch');
       END IF;

       -- Explode the batch

       SELECT nvl(routing_id,0) INTO l_routing
       FROM   gme_batch_header
       WHERE  batch_type = 0
       AND    batch_id = transaction_row.doc_id;

       IF l_routing = 0 THEN   /* Start if of l_routing = 0 */
       IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,' Opening explosion_cursor_nr cursor');
       END IF;

         OPEN  explosion_cursor_nr;
         FETCH explosion_cursor_nr BULK COLLECT INTO l_step_lev, l_step_tab;
         CLOSE explosion_cursor_nr;

          GMD_API_GRP.FETCH_PARM_VALUES (P_orgn_id => l_orgn_id,
                             P_parm_name => 'FM_YIELD_TYPE',
                             P_parm_value  => l_um_type,
                             X_return_status => l_return_status);
          IF l_return_status = 'E' THEN
           fnd_file.put_line(fnd_file.log,'Error Cannot find the value for the FM_YIELD_TYPE' );
           RETURN;
          ELSE          -- B9131983
           fnd_file.put_line(fnd_file.log,'The value for the FM_YIELD_TYPE is SET ' );
        END IF;

         SELECT uom_code INTO l_step_tab(1).step_qty_uom
         FROM   mtl_units_of_measure
         WHERE  uom_class = l_um_type AND base_uom_flag = 'Y';

       ELSE
       IF l_debug_level >= l_debug_level_medium THEN
         fnd_file.put_line(fnd_file.log,' Entering else part of l_routing=0');
       END IF;

         SELECT count(*) INTO l_dep_steps
         FROM   gme_batch_step_dependencies
         WHERE  batch_id = transaction_row.doc_id;

         /******* Dinesh Vadivel - Bug 4053149 - Start ********/

         OPEN independent_steps_cursor(transaction_row.doc_id);
         FETCH independent_steps_cursor BULK COLLECT INTO l_independent_steps;
         CLOSE independent_steps_cursor;

         l_independent_steps_cnt :=  NVL(l_independent_steps.COUNT,0)  ;

         IF l_debug_level >= l_debug_level_medium THEN
             fnd_file.put_line(fnd_file.log,
                '  Before all the CASES...' ||
                '# of dep steps : '|| l_dep_steps || '...' ||
                '# of independent steps : '|| l_independent_steps_cnt );
              fnd_file.put_line(fnd_file.log,
                ' Independent steps(ids), if any, are: ' );
              FOR i in 1.. l_independent_steps_cnt LOOP
                 fnd_file.put_line(fnd_file.log, ' i = '||i||'. step_id --> '||l_independent_steps(i));
              END LOOP;
         END IF;


         /*************  CASE 1 ******************/
         --  All the steps have Dependency defined
         IF (l_independent_steps_cnt = 0 AND  l_dep_steps > 0) THEN

           IF l_debug_level >= l_debug_level_medium THEN
              fnd_file.put_line(fnd_file.log,'  Opening the Normal Explosion Cursor at CASE 1. All dependency already defined ');
            END IF;

            OPEN  explosion_cursor (transaction_row.doc_id);
            FETCH explosion_cursor BULK COLLECT INTO l_step_lev, l_step_tab;
            CLOSE explosion_cursor;

           /*************  CASE 2 ******************/
          --  Single Step Batch. No Dependency
         ELSIF (l_independent_steps_cnt = 1  AND l_dep_steps = 0) THEN

             IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,'  Opening the Single Step Explosion Cursor at CASE 2');
             END IF;

              OPEN  explosion_cursor_ss (transaction_row.doc_id);
              FETCH explosion_cursor_ss BULK COLLECT INTO l_step_lev, l_step_tab;
              CLOSE explosion_cursor_ss;

         /*************  CASE 3 ******************/
         --  All steps are Independent
         ELSIF ( l_independent_steps_cnt > 1 AND l_dep_steps = 0) THEN

             IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,
                   ' Inside CASE 3 : All steps are independent. So we are
                     building virtual dependency chain. ');
             END IF;

              i:= 0;
              l_prior_step_id := NULL;

              FOR step_row IN steps_cursor(transaction_row.doc_id)
              LOOP
                   IF i > 0 THEN
                     INSERT INTO gme_batch_step_dependencies
                     ( batch_id
                     , batchstep_id
                     , dep_step_id
                     , standard_delay
                     , dep_type
                     , created_by
                     , creation_date
                     , last_updated_by
                     , last_update_date
                     )
                     VALUES
                     ( transaction_row.doc_id
                     , step_row.batchstep_id
                     , l_prior_step_id
                     , 0
                     , 0
                     , -1
                     , SYSDATE
                     , -1
                     , SYSDATE
                     );
                   END IF;

                   i := i+1;
                   l_prior_step_id := step_row.batchstep_id;
             END LOOP;

             OPEN  explosion_cursor (transaction_row.doc_id);
             FETCH explosion_cursor BULK COLLECT INTO l_step_lev, l_step_tab;
             CLOSE explosion_cursor;

             DELETE FROM gme_batch_step_dependencies
             WHERE  batch_id = transaction_row.doc_id;
         -- END OF CASE 3


         /*************  CASE 4 ******************/
         -- Few steps have dependency defined and Few are independent.
         ELSIF(l_independent_steps_cnt > 0 AND  l_dep_steps > 0) THEN

             IF l_debug_level >= l_debug_level_medium THEN
                 fnd_file.put_line(fnd_file.log,
                   ' Inside CASE 4 : Few steps are independent. So we are
                     building virtual dependency chain only for those
                     independent rows. ');
             END IF;

             SELECT MIN(dep_step_id)
               INTO l_min_dep_step_id
               FROM gme_batch_step_dependencies
              START WITH batch_id =  transaction_row.doc_id
                AND batchstep_id NOT IN (SELECT dep_step_id
                                           FROM gme_batch_step_dependencies
                                          WHERE batch_id =  transaction_row.doc_id)
             CONNECT BY PRIOR dep_step_id = batchstep_id
                AND batch_id = PRIOR batch_id;

             IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,'  CASE 4 : The minimum step id is '||l_min_dep_step_id);
             END IF;

             i:= 0;
             l_cur_step_id := l_min_dep_step_id;

             /*  Eg:  We have records 10,20,30,40,50 and 30,40,50 have dependency existing.
             **       There will be two records in the gme_batch_step_Dependency table
             **       as   batchstep_id : 40  (dep_step_id : 30)
             **       and batchstep_id : 50  (dep_step_id : 40)
             **
             **       In the below insert, we will add two new records as
             **       batchstep_id : 30      (dep_step_id : 20)
             **       batchstep_id : 20 (dep_step_id : 10).
             */


             FOR i IN 1..l_independent_steps_cnt
             LOOP
               INSERT INTO gme_batch_step_dependencies
                     ( batch_id
                     , batchstep_id
                     , dep_step_id
                     , standard_delay
                     , dep_type
                     , created_by
                     , creation_date
                     , last_updated_by
                     , last_update_date
                     )
               VALUES
                     ( transaction_row.doc_id
                     , l_cur_step_id
                     , l_independent_steps(i)
                     , 0
                     , 0
                     , -1
                     , SYSDATE
                     , -1
                     , SYSDATE
                     );
               l_cur_step_id :=  l_independent_steps(i);
             END LOOP;

             OPEN  explosion_cursor (transaction_row.doc_id);
             FETCH explosion_cursor BULK COLLECT INTO l_step_lev, l_step_tab;
             CLOSE explosion_cursor;

             /* Delete only those records which were inserted above.
             **  Eg:  We have records 10,20,30,40,50 and 30,40,50 have dependency existing.
             **       There will be two records in the gme_batch_step_Dependency table
             **       as   40  (dep_step_id : 30)
             **       and 50  (dep_step_id : 40)
             **
             **       In the above insert, we have added two new records as
             **       30 (dep_step_id : 20)
             **       20 (dep_step_id : 10).
             **Now we need to delete these two newly inserted records.
             */

             FOR i IN 1 .. l_independent_steps_cnt
             LOOP
                DELETE FROM gme_batch_step_dependencies
                WHERE batch_id = transaction_row.doc_id
                  AND dep_step_id = l_independent_steps(i);
             END LOOP;

          /* ELSE is not used, because code will not reach ELSE. */

         END IF; /* Ending all the Cases */

      /******* Dinesh Vadivel - Bug 4053149 - End ********/

     END IF;  /* End if of l_routing = 0 */

       IF NOT l_step_tab.EXISTS(1) THEN
         fnd_file.put_line
         (fnd_file.log,'ERROR: Could not explode steps of batch ID '||to_char(transaction_row.doc_id));
         l_tmp := FALSE;
         RETURN;
       END IF;

       IF l_debug_level >= l_debug_level_medium THEN
         fnd_file.put_line
         (fnd_file.log,'After explosion, '||to_char(l_step_tab.count)||' steps loaded');
       END IF;

       -- Load the transactions and cost them individually

       FOR i in 1..l_step_tab.count
       LOOP

          /**** Bug 5368082 Skip the Batch and set the Lot as uncostable if any of the step_qty is zero ****/
         /* Added l_routing <> 0. When there is no routing, still l_step_tab will
          * have one record. In that case we should not check for step_qty = 0 check */
         IF (l_routing <> 0 AND l_step_tab(i).step_qty = 0) THEN
	        l_skip_this_batch := TRUE;

           fnd_file.put_line /* Bug 4297815 - Debug Msg Tuning */
           ( fnd_file.log,'ERROR: The Actual Step Qty of one of the steps in Batch_Id '||transaction_row.doc_id||' is zero. The Batch will be skipped from being costed.');

           l_return_status := 'E';
           l_uncostable_lots_tab(transaction_row.orgn_id||'-'||transaction_row.inventory_item_id||'-'||transaction_row.lot_number) := transaction_row.inventory_item_id;
           l_tmp := FALSE;

           RETURN;
         END IF;
         /**** Bug 5368082 Skip the Lot if any of the step_qty is zero ****/

         IF l_routing <> 0  THEN   /* Start  l_routing <> 0 */
            -- Load all resource transactions for each step and calculate the cost of each

           IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line
            (fnd_file.log,'Loading resource transactions for step ID '
            ||to_char(l_step_tab(i).current_step_id)
            );
           END IF;

	   l_step_tab(i).resources := SYSTEM.gmf_rsrc_tab();  -- Bug 7317270

           OPEN  resources_cursor (transaction_row.doc_id, l_step_tab(i).current_step_id);
           FETCH resources_cursor BULK COLLECT INTO l_step_tab(i).resources;
           CLOSE resources_cursor;

           IF l_debug_level >= l_debug_level_medium THEN
             fnd_file.put_line
             (fnd_file.log,'Loaded '
             ||to_char(l_step_tab(i).resources.count)||' resource txns'
             );
           END IF;

           FOR j in 1..l_step_tab(i).resources.count
           LOOP

             res_cost := NULL;
	         OPEN resource_cost_cursor ( l_le_id
               , l_default_cost_type_id
               , l_step_tab(i).resources(j).resources
               , l_step_tab(i).resources(j).organization_id
               , l_step_tab(i).resources(j).trans_date
               , transaction_row.doc_id
               , l_step_tab(i).current_step_id
               );
             FETCH resource_cost_cursor BULK COLLECT INTO l_step_tab(i).resources(j).cost_details;
             CLOSE resource_cost_cursor;

             IF NOT l_step_tab(i).resources(j).cost_details.EXISTS(1) THEN
             fnd_file.put_line
               (fnd_file.log, 'Warning: The resource '
                  ||l_step_tab(i).resources(j).resources
                  ||' transaction is ignored as the resource has no cost'
               );

             ELSE

               FOR k IN 1..l_step_tab(i).resources(j).cost_details.count
               LOOP

                 l_step_tab(i).resources(j).trans_cost := l_step_tab(i).resources(j).trans_cost
                  + l_step_tab(i).resources(j).resource_usage
                   *l_step_tab(i).resources(j).cost_details(k).component_cost;

                 l_cost_accrued := FALSE;

                 FOR l IN 1..l_step_tab(i).current_costs.count
                 LOOP
                   IF   l_step_tab(i).resources(j).cost_details(k).cost_cmpntcls_id
                       =l_step_tab(i).current_costs(l).cost_cmpntcls_id
                   AND  l_step_tab(i).resources(j).cost_details(k).cost_analysis_code
                       =l_step_tab(i).current_costs(l).cost_analysis_code
                   AND  l_step_tab(i).resources(j).cost_details(k).cost_level
                       =l_step_tab(i).current_costs(l).cost_level
                   THEN
                     l_step_tab(i).current_costs(l).component_cost :=
                       l_step_tab(i).current_costs(l).component_cost
                     + l_step_tab(i).resources(j).resource_usage
                      *l_step_tab(i).resources(j).cost_details(k).component_cost;
                     l_cost_accrued := TRUE;
                     EXIT;
                   END IF;
                 END LOOP;

                 IF NOT l_cost_accrued THEN
                   IF l_step_tab(i).current_costs(1).cost_analysis_code = ' ' THEN
                     l_step_tab(i).current_costs(1) :=
                       l_step_tab(i).resources(j).cost_details(k);
                     l_step_tab(i).current_costs(1).component_cost :=
                       l_step_tab(i).resources(j).resource_usage
                      *l_step_tab(i).resources(j).cost_details(k).component_cost;
                   ELSE
                     l_step_tab(i).current_costs.EXTEND;
                     l := l_step_tab(i).current_costs.count;
                     l_step_tab(i).current_costs(l) :=
                       l_step_tab(i).resources(j).cost_details(k);
                     l_step_tab(i).current_costs(l).component_cost :=
                       l_step_tab(i).resources(j).resource_usage
                      *l_step_tab(i).resources(j).cost_details(k).component_cost;
                   END IF;
                 END IF;
               END LOOP;
             END IF;
           END LOOP;
         END IF;

         -- Now load the inventory transactions. If the batch didn't have a routing, or the
         -- routing it possessed only had a single step, all inventory is attached to the
         -- first (only) step in the steps table.

         -- If there was a routing but no associations were set up, we attach all inventory
         -- to the last step of the chain, so that the products absorb all of the costs.

         -- If we have a routing and dependencies we attach the inventory to the
         -- correct step.


         IF l_step_tab.COUNT = 1  THEN
           l_step_tab(i).materials := SYSTEM.gmf_matl_tab();  -- Bug 7317270
           -- Only come in here for single step routings
            IF l_debug_level >= l_debug_level_medium THEN    -- B9131983
             fnd_file.put_line(fnd_file.log,' Opening materials_cursor_nr cursor: single step routings');
            END IF;

           OPEN  materials_cursor_nr (transaction_row.doc_id);
           FETCH materials_cursor_nr BULK COLLECT INTO l_step_tab(i).materials;
           CLOSE materials_cursor_nr;
         ELSE

           l_step_tab(i).materials := SYSTEM.gmf_matl_tab();  -- Bug 7317270
           -- Get here if dependenies exist, so attach inventory to the correct step.
           IF l_debug_level >= l_debug_level_medium THEN    -- B9131983
            fnd_file.put_line(fnd_file.log,' Opening materials_cursor ');
           END IF;

           OPEN  materials_cursor (transaction_row.doc_id, l_step_tab(i).current_step_id);
           FETCH materials_cursor BULK COLLECT INTO l_step_tab(i).materials;
           CLOSE materials_cursor;

           -- B3556291
           -- Now need to see if there were any lines that were not associated to a step. If so,
           -- associate the ingredients with the first step and the products with the last step

           IF i = 1 THEN
            IF l_debug_level >= l_debug_level_medium THEN    -- B9131983
             fnd_file.put_line(fnd_file.log,' Opening unassociated_ings_cursor cursor: Only One Ingrad');
            END IF;

             OPEN unassociated_ings_cursor (transaction_row.doc_id);
             FETCH unassociated_ings_cursor BULK COLLECT INTO ing_tab;
             CLOSE unassociated_ings_cursor;

             FOR j IN 1..ing_tab.COUNT
             LOOP
               l_step_tab(i).materials.EXTEND;
               l_step_tab(i).materials(l_step_tab(i).materials.COUNT) := ing_tab(j);
             END LOOP;
           END IF;

           IF i = l_step_tab.COUNT THEN
            IF l_debug_level >= l_debug_level_medium THEN    -- B9131983
              fnd_file.put_line(fnd_file.log,' Opening unassociated_prds_cursor cursor');
            END IF;

             OPEN unassociated_prds_cursor (transaction_row.doc_id);
             FETCH unassociated_prds_cursor BULK COLLECT INTO prd_tab;
             CLOSE unassociated_prds_cursor;

             FOR j IN 1..prd_tab.COUNT
             LOOP
               l_step_tab(i).materials.EXTEND;
               l_step_tab(i).materials(l_step_tab(i).materials.COUNT) := prd_tab(j);
             END LOOP;
           END IF;
           -- B3556291 end
         END IF;

         -- If transactions have been reversed then don't attempt to cost them. Simply set both transactions'
         -- quantities to zero, so that they'll be ignored.

  /*       l_total_materials := l_step_tab(i).materials.COUNT ;
         FOR j IN 1..l_step_tab(i).materials.COUNT-1
         LOOP
           FOR k IN j+1..l_step_tab(i).materials.COUNT
           LOOP
             IF l_step_tab(i).materials(j).organization_id = l_step_tab(i).materials(k).organization_id
             AND l_step_tab(i).materials(j).line_type = l_step_tab(i).materials(k).line_type
              AND l_step_tab(i).materials(j).item_id = l_step_tab(i).materials(k).item_id
             AND l_step_tab(i).materials(j).lot_number = l_step_tab(i).materials(k).lot_number
             AND l_step_tab(i).materials(j).trans_qty + l_step_tab(i).materials(k).trans_qty = 0
             THEN
                fnd_file.put_line(fnd_file.log,'Before RDP Lot ' ||
                 l_step_tab(i).materials(k).lot_number
                || '-J- ' ||
                l_step_tab(i).materials(j).trans_qty || '-K- ' ||
               l_step_tab(i).materials(k).trans_qty  );

                 l_step_tab(i).materials(j).trans_qty := 0;
                 l_step_tab(i).materials(k).trans_qty := 0;

                fnd_file.put_line(fnd_file.log,'After RDP Lot ' || l_step_tab(i).materials(k).lot_number
                || '-J-' ||
                l_step_tab(i).materials(j).trans_qty || '-K-' ||
                l_step_tab(i).materials(j).trans_qty  );

                EXIT;
             END IF;
           END LOOP;
         END LOOP;

   */
         IF l_routing = 0 THEN    /* l_routing = 0 */
           l_step_tab(1).step_qty := 0;

           FOR j IN 1..l_step_tab(1).materials.COUNT
           LOOP
             IF l_step_tab(1).materials(j).step_contribution = 'Y'
             AND l_step_tab(1).materials(j).line_type = -1
             AND l_step_tab(1).materials(j).trans_qty <> 0
             THEN
               l_tran_qty := 0;       -- B9131983
               l_tran_qty :=
               INV_CONVERT.INV_UM_CONVERT(ITEM_ID       => l_step_tab(1).materials(j).item_id
                                         ,LOT_NUMBER    => l_step_tab(1).materials(j).lot_number
                                         ,PRECISION     => 5
                                         ,ORGANIZATION_ID => transaction_row.orgn_id
                                         ,FROM_QUANTITY => -l_step_tab(1).materials(j).trans_qty
                                         ,FROM_UNIT     => l_step_tab(1).materials(j).trans_um
                                         ,TO_UNIT       => l_step_tab(1).step_qty_uom
                                         ,FROM_NAME     => NULL
                                         ,TO_NAME       => NULL
                                           );

          -- IF l_tran_qty < 0 PK Bug 9069363 check for -99999
          IF l_tran_qty = -99999  THEN      -- B9131983
     			 fnd_file.put_line
			     (fnd_file.log,'ERROR: Unable to convert from '
			     ||l_step_tab(1).materials(j).trans_um
			     ||' to '||l_step_tab(1).step_qty_uom||' for transaction ID '
			     ||l_step_tab(1).materials(j).trans_id
		       ||' for item ID '
		       ||l_step_tab(1).materials(j).item_id
		       ||' for lot Number '
		       ||l_step_tab(1).materials(j).lot_number
		       ||' qty '
		       ||l_step_tab(1).materials(j).trans_qty
		       ||' Returned Value '||l_tran_qty
			     );

                 l_return_status := 'E';
                 l_tmp := FALSE;
                 RETURN;
               END IF;

               l_step_tab(1).step_qty := l_step_tab(1).step_qty + l_tran_qty;
             END IF;
           END LOOP;
         END IF;   /*  l_routing = 0 */

       /***** Bug 4057323 - To check whether all the Products are yielded in one single step - Start *****/
        IF l_debug_level >= l_debug_level_high THEN
            fnd_file.put_line (fnd_file.log, 'Cost Allocation Factor : Just before entering the cost allocation factor code , l_cost_alloc_profile value is '||l_cost_alloc_profile);
        END IF;

         IF (l_cost_alloc_profile = 1) THEN  /* Start if of l_cost_alloc_profile =1 */
              IF l_debug_level >= l_debug_level_high  THEN
                   fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor :  l_Step_tab.COUNT is '||l_step_tab.COUNT);
               END IF;
              IF (l_step_tab.COUNT = 1) THEN
                IF l_debug_level >= l_debug_level_high THEN
                   fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor : Go ahead as there is only one total step ');
                 END IF;
                 -- Go ahead... There is only one step available. So all products should be attached to this step only.
                 l_cost_alloc_profile := 1;
              ELSIF (l_step_tab.COUNT > 1) THEN
                  IF l_debug_level >= l_debug_level_high THEN
                      fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor :  Wait, there are many steps. So have to process others. Before the distinct batchstep_id area');
                  END IF;

                 /* Check whether the number of Distinct steps having step material association is 1.
                     If not don't use Cost Allocation Factor */
                 SELECT COUNT (DISTINCT batchstep_id)
                   INTO l_count
                   FROM gme_material_details gmd, gme_batch_step_items gbsi
                  WHERE gmd.material_detail_id = gbsi.material_detail_id
                    AND gmd.batch_id = gbsi.batch_id
                    AND gmd.line_type = 1
                    AND gmd.batch_id = transaction_row.doc_id;

                     IF l_debug_level >= l_debug_level_high THEN
                        fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor : After the distinct batchstep_id area. the l_count is '||l_count);
                      END IF;

                 IF (NVL (l_count, 0) = 1) THEN
                     IF l_debug_level >= l_debug_level_high THEN
                        fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor : There are some Step Matl Association. So check any unassociated products ');
                      END IF;

                    -- If l_count is 1 then there is only one step having step material association
                    /* Get Unassociated Products */
                    /* Check whether there is/are any unassociated products */


                      SELECT COUNT (DISTINCT mmt.inventory_item_id)
                      INTO l_unassociated_prds
                      FROM mtl_material_transactions mmt, gme_material_details gmd
                     WHERE mmt.transaction_source_type_id = 5
                       AND mmt.transaction_source_id = gmd.batch_id
                       AND gmd.line_type = 1
                       AND mmt.transaction_quantity <> 0
                       AND gmd.batch_id =transaction_row.doc_id
                       AND mmt.trx_source_line_id = gmd.material_detail_id
                       AND gmd.material_detail_id NOT IN (
                                SELECT material_detail_id
                                  FROM gme_batch_step_items
                                 WHERE batch_id = transaction_row.doc_id);

                       IF l_debug_level >= l_debug_level_high THEN
                           fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor : The number of unassociated products are '||l_unassociated_prds);
                       END IF;

                    IF (l_unassociated_prds = 0) THEN
                      IF l_debug_level >= l_debug_level_high THEN
                        fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor : unassociated prds are zero. so Go Ahead');
                      END IF;

                       -- Go ahead and use the profile
                       l_cost_alloc_profile := 1;
                    ELSE

                       /***** Important Case *****/
                       -- At this place we have some products attached to a step,
                       -- and some unassociated products.
                       -- Although there is a chance that all the products which have explicit step association
                       -- is on terminal step  and our logic considers the unassociated products
                       -- to be attached with the terminal step, BUT WE DONOT SUPPORT THIS CASE
                         fnd_file.put_line
                             ( fnd_file.log, ' NOTE : The profile GMF: Use Cost Alloc Factor in Lot Costing has been set to ''Yes''.
                                  Since few products have step association defined and few does not, this profile will NOT be used.');
                         l_cost_alloc_profile := 0;
                     END IF;

                 ELSIF (NVL (l_count, 0) = 0)  THEN
                     IF l_debug_level >= l_debug_level_high THEN
                         fnd_file.put_line (fnd_file.log, ' Cost Allocation Factor : No Step material Associations. So Go Ahead ');
                      END IF;

                    -- Go Ahead.. The Number of steps having step material Association is zero.
                    -- So all steps should have been attached to a single step by default which is the terminal step
                    l_cost_alloc_profile := 1;

                 ELSE    -- The Products are associated with multiple steps. So don't use the profile
                    fnd_file.put_line
                         ( fnd_file.log, ' NOTE : The profile GMF: Use Cost Alloc Factor in Lot Costing has been set to ''Yes''.
                                Since all the products are not yielded in a single step this profile will NOT be used.');
                    l_cost_alloc_profile := 0;
                 END IF;                     /* End if of   IF( NVL(l_count,0) = 1) */
              END IF;                           /* End of IF (l_step_tab.COUNT = 1) */
           END IF;  /* End if of l_cost_alloc_profile =1 */

        /***** Bug 4057323 - To check whether all the Products are yielded in one single step  - End *****/

        -- Only consider lot costed products for output_qty Start
         l_step_tab(i).output_qty := 0;

         FOR j IN 1..l_step_tab(i).materials.COUNT
         LOOP
           IF l_step_tab(i).materials(j).line_type = 1
           AND l_step_tab(i).materials(j).lot_costed_flag = 1 THEN

             /***** Bug 4094132 - Girish Jha - Begin *****/
    	      IF (l_step_tab(i).materials(j).trans_id = transaction_row.transaction_id AND transaction_row.reverse_id IS NOT NULL) THEN
                l_step_output_qty := 0;
  	      ELSE
	        l_step_output_qty := NULL;
 	      END IF;
              /***** Bug 4094132 - Girish Jha - End *****/
              l_tran_qty := 0;   -- B9131983
              l_tran_qty :=
               INV_CONVERT.INV_UM_CONVERT(ITEM_ID       => l_step_tab(i).materials(j).item_id
                                         ,LOT_NUMBER    => l_step_tab(i).materials(j).lot_number
                                         ,PRECISION     => 5
                                         ,ORGANIZATION_ID => transaction_row.orgn_id
                                         ,FROM_QUANTITY => nvl(l_step_output_qty, l_step_tab(i).materials(j).trans_qty)
                                         ,FROM_UNIT     => l_step_tab(i).materials(j).trans_um
                                         ,TO_UNIT       => l_step_tab(i).step_qty_uom
                                         ,FROM_NAME     => NULL
                                         ,TO_NAME       => NULL
                                           );
            IF l_tran_qty = -99999  THEN    -- B9131983
 		          fnd_file.put_line
		         (fnd_file.log,'ERROR: Unable to convert from '
		         ||l_step_tab(i).materials(j).trans_um
		         ||' to '||l_step_tab(i).step_qty_uom||' for transaction ID '
		         ||l_step_tab(i).materials(j).trans_id
		         ||' for item ID '
		         ||l_step_tab(i).materials(j).item_id
		         ||' for Lot Number '
		         ||l_step_tab(i).materials(j).lot_number
		         ||' qty (nvl) '
		         ||l_step_output_qty||' nvl part2 '||l_step_tab(i).materials(j).trans_qty
		         ||' Returned Value '||l_tran_qty
		         );

               l_return_status := 'E';
               l_tmp := FALSE;
               RETURN;
             END IF;

             l_step_tab(i).output_qty := l_step_tab(i).output_qty + l_tran_qty;
           END IF;
         END LOOP;
           -- Only consider lot costed products for output_qty Ends

         IF l_debug_level >= l_debug_level_medium THEN
           fnd_file.put_line
           (fnd_file.log,'Loaded '||to_char(l_step_tab(i).materials.count)||' material txns');
         END IF;

         FOR j in 1..l_step_tab(i).materials.count
         LOOP
           l_skip_this_txn   := FALSE; -- PK Avoid incorrect log messages

           -- This if condition will ignore reversal record processing, it is already set to ZERO
           IF l_step_tab(i).materials(j).trans_qty <> 0 THEN
             -- Calculate the cost of ingredients from the cost of the lot consumed.
             -- If the lot being consumed has not been costed, perhaps because the
             -- batch that produced it has not yet been certified, we skip this batch.

             -- The transactions are sorted by date and then by line type. This should
             -- give the correct ordering of transactions for the rollup.

             -- If item is not lot controlled or is not lot costed
             -- use the standard (period-based) cost from cm_cmpt_dtl,
             -- otherwise use the lot cost
             -- B9131983
             IF l_step_tab(i).materials(j).line_type IN (-1,2) -- Treat byproducts as negative ingredients
             OR l_step_tab(i).materials(j).line_type = 1 AND l_step_tab(i).materials(j).lot_costed_flag = 0
             THEN
               -- This is an ingredient attached to this step

               ing_cost.unit_cost := NULL;

               IF l_step_tab(i).materials(j).lot_costed_flag = 0 THEN
	         -- umoogala: using co_code and default_cost_mthd to get costs for non-lot controlled items.
	         -- was calendar_code and cost_mthd_code
                IF l_debug_level >= l_debug_level_medium THEN   -- B9131983
          			 fnd_file.put_line
		     	     (fnd_file.log,' If Item is NOT Lot costed then Org: '
			        || l_step_tab(i).materials(j).organization_id
			        ||' transaction ID '
			        ||l_step_tab(i).materials(j).trans_id
		          ||' item ID '
		          ||l_step_tab(i).materials(j).item_id
		          ||' lot Number '
		          ||l_step_tab(i).materials(j).lot_number
		          ||' Date '
		          ||l_step_tab(i).materials(j).trans_date
              ||' Cpst TYPE ' || l_cost_type_id
			         );
                END IF;

                 OPEN item_cost_detail_cursor
                       ( l_le_id
                       , l_default_cost_type_id
                       , l_step_tab(i).materials(j).organization_id
                       , l_step_tab(i).materials(j).item_id
                       , l_step_tab(i).materials(j).trans_date
                       );
                 FETCH item_cost_detail_cursor BULK COLLECT INTO l_step_tab(i).materials(j).cost_details;
                 CLOSE item_cost_detail_cursor;

	         -- umoogala: using co_code and default_cost_mthd to get costs for non-lot controlled items.
	         -- was calendar_code and cost_mthd_code

                 ing_cost.unit_cost := NULL;
                 OPEN item_cost_cursor
                       ( l_le_id
                       , l_default_cost_type_id
                       , l_step_tab(i).materials(j).organization_id
                       , l_step_tab(i).materials(j).item_id
                       , l_step_tab(i).materials(j).trans_date
                       );
                 FETCH item_cost_cursor INTO ing_cost.unit_cost;
                 CLOSE item_cost_cursor;

                 IF ing_cost.unit_cost IS NULL THEN
                   l_skip_this_batch := TRUE;
                   l_skip_this_txn   := TRUE; -- PK Avoid incorrect log messages
                 END IF;

               ELSE
--                IF l_debug_level >= l_debug_level_medium THEN     -- B9131983
--          			 fnd_file.put_line
--		     	     (fnd_file.log,' If Item Lot costed then Org: '
--			         || l_step_tab(i).materials(j).organization_id
--			         ||' transaction ID '
--			         ||l_step_tab(i).materials(j).trans_id
--		           ||' item ID '
--		           ||l_step_tab(i).materials(j).item_id
--	             ||' lot Number '
--		           ||l_step_tab(i).materials(j).lot_number
--		           ||' Date '
--		           ||l_step_tab(i).materials(j).trans_date
--               ||' Cpst TYPE ' || l_cost_type_id
--			          );
--                END IF;

                 ing_cost.header_id := NULL;

                 OPEN  lot_cost_cursor ( l_step_tab(i).materials(j).organization_id
                                       , l_step_tab(i).materials(j).item_id
                                       , l_step_tab(i).materials(j).lot_number
                                       , l_step_tab(i).materials(j).trans_date      -- Bug 4130869 Added Date field
                                       , l_cost_type_id
                                       );
                 FETCH lot_cost_cursor INTO ing_cost;
                 CLOSE lot_cost_cursor;

                 IF ing_cost.header_id IS NOT NULL THEN
                   OPEN  lot_cost_detail_cursor
                         ( ing_cost.header_id );
                   FETCH lot_cost_detail_cursor BULK COLLECT INTO l_step_tab(i).materials(j).cost_details;
                   CLOSE lot_cost_detail_cursor;
                 ELSE
                   l_skip_this_batch := TRUE;
                   l_skip_this_txn   := TRUE; -- PK Avoid incorrect log messages
                 END IF;

               END IF;

               -- IF l_skip_this_batch PK Avoid incorrect log messages

               IF l_skip_this_txn  THEN

                 fnd_file.put_line
                 (fnd_file.log, 'ERROR: Cannot calculate cost of lot '
                  ||to_char(transaction_row.lot_number)
                  ||' because material transaction '
                  ||to_char(l_step_tab(i).materials(j).trans_id)
                  ||' cannot be costed'
                 );
               ELSE
                 FOR k IN 1..l_step_tab(i).materials(j).cost_details.count
                 LOOP
                   l_step_tab(i).materials(j).trans_cost := l_step_tab(i).materials(j).trans_cost
                     + -1*l_step_tab(i).materials(j).trans_qty * l_step_tab(i).materials(j).cost_details(k).component_cost;
                   l_cost_accrued := FALSE;

                   FOR l IN 1..l_step_tab(i).current_costs.count
                   LOOP
                     IF   l_step_tab(i).materials(j).cost_details(k).cost_cmpntcls_id
                         =l_step_tab(i).current_costs(l).cost_cmpntcls_id
                     AND  l_step_tab(i).materials(j).cost_details(k).cost_analysis_code
                         =l_step_tab(i).current_costs(l).cost_analysis_code
                     AND  l_step_tab(i).materials(j).cost_details(k).cost_level
                         =l_step_tab(i).current_costs(l).cost_level
                     THEN
                       l_step_tab(i).current_costs(l).component_cost :=
                          l_step_tab(i).current_costs(l).component_cost
                        + -1*l_step_tab(i).materials(j).trans_qty
                            *l_step_tab(i).materials(j).cost_details(k).component_cost;
                       l_cost_accrued := TRUE;
                       EXIT;
                     END IF;
                   END LOOP;

                   IF NOT l_cost_accrued THEN
                     IF l_step_tab(i).current_costs(1).cost_analysis_code = ' ' THEN
                       l_step_tab(i).current_costs(1) := l_step_tab(i).materials(j).cost_details(k);
                       l_step_tab(i).current_costs(1).component_cost :=
                         -l_step_tab(i).materials(j).trans_qty * l_step_tab(i).materials(j).cost_details(k).component_cost;
                     ELSE
                       l_step_tab(i).current_costs.EXTEND;
                       l := l_step_tab(i).current_costs.count;
                       l_step_tab(i).current_costs(l) :=
                         l_step_tab(i).materials(j).cost_details(k);
                       l_step_tab(i).current_costs(l).component_cost :=
                         -1*l_step_tab(i).materials(j).trans_qty
                           *l_step_tab(i).materials(j).cost_details(k).component_cost;
                     END IF;
                   END IF;
                 END LOOP;
               END IF;
             ELSE
               -- This is a product/coproduct that is yielded at this step. If the item
               -- being yielded uses standard costing we extract the cost so that we can
               -- work out the cost of this transaction and then include it in the total
               -- for this step. Any items that use lot costing have these costs calculated
               -- after we've rolled up the costs into the step from where the lot is yielded

               IF l_step_tab(i).materials(j).lot_number IS NULL /* INVCONV sshchinch */
               OR l_step_tab(i).materials(j).lot_costed_flag = 0
               THEN
	               -- umoogala: using co_code and default_cost_mthd to get costs for non-lot controlled items.
	               -- was calendar_code and cost_mthd_code
                 OPEN item_cost_detail_cursor
                 ( l_le_id
                 , l_default_cost_type_id
                 , l_step_tab(i).materials(j).organization_id
                 , l_step_tab(i).materials(j).item_id
                 , l_step_tab(i).materials(j).trans_date
                 );
                 FETCH item_cost_detail_cursor BULK COLLECT INTO l_step_tab(i).materials(j).cost_details;
                 CLOSE item_cost_detail_cursor;


	               -- umoogala: using co_code and default_cost_mthd to get costs for non-lot controlled items.
	               -- was calendar_code and cost_mthd_code
                 OPEN item_cost_cursor
                 ( l_le_id
                 , l_default_cost_type_id
                 , l_step_tab(i).materials(j).organization_id
                 , l_step_tab(i).materials(j).item_id
                 , l_step_tab(i).materials(j).trans_date
                 );
                 FETCH item_cost_cursor INTO prd_cost.unit_cost;
                 CLOSE item_cost_cursor;

                 IF NOT l_step_tab(i).materials(j).cost_details.EXISTS(1) THEN
                   fnd_file.put_line
                   (fnd_file.log, 'ERROR: Cannot calculate cost of Lot Number '
                    ||to_char(transaction_row.lot_number)
                    ||' because item ID / Lot Number '
                    ||to_char(l_step_tab(i).materials(j).item_id)
                    ||'/'
                    ||to_char(l_step_tab(i).materials(j).lot_number)
                    ||' cannot be costed'
                   );
                   l_skip_this_batch := TRUE;
                 ELSE
                   FOR k IN 1..l_step_tab(i).materials(j).cost_details.count
                   LOOP
                     l_step_tab(i).materials(j).trans_cost := l_step_tab(i).materials(j).trans_cost
                     + -1*l_step_tab(i).materials(j).trans_qty * l_step_tab(i).materials(j).cost_details(k).component_cost;

                     l_cost_accrued := FALSE;

                     FOR l IN 1..l_step_tab(i).current_costs.count
                     LOOP
                       IF   l_step_tab(i).materials(j).cost_details(k).cost_cmpntcls_id
                           =l_step_tab(i).current_costs(l).cost_cmpntcls_id
                       AND  l_step_tab(i).materials(j).cost_details(k).cost_analysis_code
                           =l_step_tab(i).current_costs(l).cost_analysis_code
                       AND  l_step_tab(i).materials(j).cost_details(k).cost_level
                           =l_step_tab(i).current_costs(l).cost_level
                       THEN
                         l_step_tab(i).current_costs(l).component_cost :=
                           l_step_tab(i).current_costs(l).component_cost
                         + -1*l_step_tab(i).materials(j).trans_qty * l_step_tab(i).materials(j).cost_details(k).component_cost;
                         l_cost_accrued := TRUE;
                         EXIT;
                       END IF;
                     END LOOP;

                     IF NOT l_cost_accrued THEN
                       IF l_step_tab(i).current_costs(1).cost_analysis_code = ' ' THEN
                         l_step_tab(i).current_costs(1) :=
                           l_step_tab(i).materials(j).cost_details(k);
                         l_step_tab(i).current_costs(1).component_cost :=
                           l_step_tab(i).materials(j).trans_qty * l_step_tab(i).materials(j).cost_details(k).component_cost;
                       ELSE
                         l_step_tab(i).current_costs.EXTEND;
                         l := l_step_tab(i).current_costs.count;
                         l_step_tab(i).current_costs(l) :=
                           l_step_tab(i).materials(j).cost_details(k);
                         l_step_tab(i).current_costs(l).component_cost :=
                          -1*l_step_tab(i).materials(j).trans_qty * l_step_tab(i).materials(j).cost_details(k).component_cost;
                       END IF;
                     END IF;
                   END LOOP;
                 END IF;
               END IF;
             END IF;
           END IF; -- If trans_qty <> 0
        END LOOP;

        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,'Setting up step dependency index and quantities');
        END IF;

        -- Set up the step_index field in the 'next steps' nested tables

        FOR j IN 1..l_step_tab(i).dependencies.count
        LOOP
          FOR k IN 1..l_step_tab.count
          LOOP
            IF l_step_tab(k).current_step_id = l_step_tab(i).dependencies(j).batchstep_id
            THEN

              IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line
                (fnd_file.log,'Setting ('||to_char(i)||','||to_char(j)||') to '||to_char(k));
              END IF;

               l_step_tab(i).dependencies(j).step_index := k;

              EXIT;
            END IF;
          END LOOP;
        END LOOP;

        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,'End of transaction load/costing loop for iteration '||to_char(i));
        END IF;

      END LOOP; -- End of loop that retrieves and costs the transactions

      -- Start of the actual rollup

      IF l_skip_this_batch THEN
        -- For one reason or another we cannot cost this lot.
        fnd_file.put_line
        ( fnd_file.log,'ERROR: Batch ID '
        ||to_char(transaction_row.doc_id)
        ||' was skipped because of missing cost(s)');
        l_return_status := 'E';
        l_uncostable_lots_tab(transaction_row.orgn_id||'-'||transaction_row.inventory_item_id||'-'||transaction_row.lot_number) := transaction_row.inventory_item_id;
        l_tmp := FALSE;

        RETURN;
      ELSE


        -- At this stage we have a complete explosion of the batch in terms of materials
        -- consumed and yielded, and also resources expended, together with all costs for
        -- each consumption and expenditure. We now need to traverse the routing
        -- to roll up the costs from the starting step(s) to the step where the lot is yielded.

        -- The explosion of the routing honours the fact that steps can converge and also
        -- diverge into any arbitrary topology. The only thing that is not allowed is a feedback
        -- loop.

        -- Traversing the routing is simplified by the explosion method, which orders the steps
        -- in the correct sequence. We can start at the first node (step) and examine the
        -- nested table in it to see what the next step/steps is/are. If there is only one 'next'
        -- step the costs accumulated in the current step are passed on. If there is more than
        -- one next step the costs accumulated so far are passed on in direct proportion to
        -- their actual step quantities. If there are no next steps we have reached a terminal
        -- step in the routing.

        -- Note that if anything is yielded at the current step, the cost of it is subtracted
        -- and only the residual costs are rolled into the next steps.

        -- We have the following values for each step, stored in table l_step_tab:

        -- current_step_id (ie the batchstep_id of the current step)
        -- current_costs   (ie all costs incurred at this step)
        -- inherited_costs (ie all of the costs from prior steps)
        -- dependencies    (ie a list of steps that directly follow on from this step)

        -- Each element of the dependencies list has the following components

        -- batchstep_id       (the ID of the step)
        -- step_qty (the material quantity inherited from prior steps)
        -- step_qty_uom       (the unit of measure of the above)
        -- step_index         (this is the index of the step in l_step_tab)

        IF l_debug_level >= l_debug_level_low THEN
          fnd_file.put_line
          (fnd_file.log,'Transaction costs complete. Starting rollup for batch ID '
          ||to_char(transaction_row.doc_id)
          );
        END IF;


        FOR i in 1..l_step_tab.count
        LOOP
          IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line
            (fnd_file.log,'Inside rollup loop for step index '||to_char(i));
          END IF;

          -- We need to set up the step_costs table. This holds the combined inherited costs (that is
          -- those that have come from prior steps) and the current costs (ie those that have been
          -- introduced at this step. This is done so that any yields from this step can be calculated
          -- a bit more easily.

          new_cost_tab.delete;
          cur_cost_tab.delete;

          FOR j IN 1.. l_step_tab(i).inherited_costs.COUNT
          LOOP
            new_cost_tab(j) := l_step_tab(i).inherited_costs(j);
          END LOOP;

          FOR j IN 1..l_step_tab(i).current_costs.COUNT
          LOOP
            cur_cost_tab(j) := l_step_tab(i).current_costs(j);
          END LOOP;

          merge_costs ( cur_cost_tab
                      , 1
                      , 1
                      , 'C'
                      );

          FOR j IN 1..new_cost_tab.COUNT
          LOOP
            l_step_tab(i).step_costs(j) := new_cost_tab(j);
            l_step_tab(i).step_costs.EXTEND;
          END LOOP;

          -- Get rid of the unused last entry

          l_step_tab(i).step_costs.DELETE(l_step_tab(i).step_costs.COUNT);

          -- See if we've yielded anything that is lot_costed in this step.

          FOR j IN 1..l_step_tab(i).materials.count  -- Main Processing
          LOOP

            IF  l_step_tab(i).materials(j).line_type = 1 -- Ignore byproducts
            AND l_step_tab(i).materials(j).lot_costed_flag = 1
            THEN
              -- We've yielded something. Find its cost and, if needed,  update the
              -- lot costing tables. If there isn't an existing cost then we have to
              -- create a new one.

              new_cost.onhand_qty := l_step_tab(i).materials(j).trans_qty;
              new_cost.unit_cost := 0;
              new_cost_tab.delete;
              old_cost.onhand_qty := 0;
              old_cost_tab.delete;
              cur_cost_tab.delete; /* Bug 3533452 */

              IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line(fnd_file.log,'Setting up new_cost_tab');
              END IF;

              -- Bug 3548217
              IF l_step_tab(i).step_qty_uom <> l_step_tab(i).materials(j).trans_um
              THEN
              l_tran_qty := 0;   -- B9131983
              l_tran_qty :=
               INV_CONVERT.INV_UM_CONVERT(ITEM_ID       => l_step_tab(i).materials(j).item_id
                                         ,LOT_NUMBER    => l_step_tab(i).materials(j).lot_number
                                         ,PRECISION     => 5
                                         ,ORGANIZATION_ID => transaction_row.orgn_id
                                         ,FROM_QUANTITY => l_step_tab(i).materials(j).trans_qty
                                         ,FROM_UNIT     => l_step_tab(i).materials(j).trans_um
                                         ,TO_UNIT       => l_step_tab(i).step_qty_uom
                                         ,FROM_NAME     => NULL
                                         ,TO_NAME       => NULL
                                           );
                -- PK Bug 9069363 do not return for all negative quatities.
                IF l_tran_qty = -99999 THEN      -- B9131983
                  fnd_file.put_line
                  (fnd_file.log,'ERROR: Unable to convert to step qty uom for transaction ID '
                  ||l_step_tab(i).materials(j).trans_id
                  );
                  l_return_status := 'E';
                  l_tmp := FALSE;
                  RETURN;
                END IF;
              ELSE
                l_tran_qty := l_step_tab(i).materials(j).trans_qty;
              END IF;

              -- Bug 3548217
              -- If we're on a terminal step we have to set up the cost factor
              -- so that all costs will be absorbed by the products yielded. If
              -- the step is higher up the chain the we use the step qty instead so that all
              -- residual costs are passed on to the next steps.

              IF l_step_tab(i).dependencies(1).step_index IS NULL
              THEN

                 /***** Bug 4094132 - Girish Jha - Begin *****/
                  IF (l_step_tab(i).materials(j).trans_id = transaction_row.transaction_id AND transaction_row.reverse_id IS NOT NULL) THEN
                    l_step_output_qty := 0;
                  ELSE
                    l_step_output_qty := NULL;
                  END IF;
                  /***** Bug 4094132 - Girish Jha - End *****/

                -- We're on a terminal step

                /***** Bug 4057323 - Use Cost Allocation Factor Depending on Profile value - Start *****/
                IF ( l_cost_alloc_profile = 1) THEN
                  l_cost_factor := l_step_tab(i).materials(j).cost_alloc;
                ELSE  /* Else approtion the cost by using the quantities as the ratio */
                    /* Quantity in the batch step is not zero then */
                  IF l_step_tab(i).output_qty<>0 THEN   /*Condition Added - Bug 5985680, pmarada  */
                    l_cost_factor := (l_tran_qty /l_step_tab(i).output_qty);
                  ELSE
                    l_cost_factor := 0;
                    fnd_file.put_line (fnd_file.log,' Setting Cost Allocation Factor to zero as output_qty is zero.');
                  END IF;
                END IF;
                /***** Bug 4057323 - Use Cost Allocation Factor Depending on Profile value - End *****/

                IF l_debug_level >= l_debug_level_high THEN
                   fnd_file.put_line (fnd_file.log,' Cost Allocation Factor :  For the transaction of '||l_step_tab(i).materials(j).trans_id
                                                || ' the new cost_factor is '|| l_cost_factor);
                 END IF;

                -- Reduce remaining output_qty for next time around

                -- Bug 4094132 Added NVL(l_step_output_qty, .....
                -- l_step_tab(i).output_qty := l_step_tab(i).output_qty - l_tran_qty;
                l_step_tab(i).output_qty := l_step_tab(i).output_qty - NVL(l_step_output_qty,l_tran_qty);

              ELSE  /* If not terminal step */
                  /***** Bug 4057323 - Use Cost Allocation Factor Depending on Profile value - Start *****/
                  IF ( l_cost_alloc_profile = 1) THEN
                    l_cost_factor := l_step_tab(i).materials(j).cost_alloc;
                  ELSE  /* Else approtion the cost by using the quantities as the ratio of step quantities*/
                    IF l_step_tab(i).step_qty <> 0 THEN  /*Condition Added - Bug 5985680, pmarada  */
                      l_cost_factor := l_tran_qty / l_step_tab(i).step_qty;
                    ELSE
                      l_cost_factor := 0;
                      fnd_file.put_line (fnd_file.log,' Setting Cost Allocation Factor to zero as step_qty is zero.');
                    END IF;
                  END IF;
                  /***** Bug 4057323 - Use Cost Allocation Factor Depending on Profile value - End *****/
              END IF;

              IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line
                (fnd_file.log,'Cost factor for yield costs calculation is '||l_cost_factor);

                fnd_file.put_line(fnd_file.log,'Step costs before are');
                FOR jj IN 1..l_step_tab(i).step_costs.COUNT
                LOOP
                  fnd_file.put_line
                  (fnd_file.log,l_step_tab(i).step_costs(jj).component_cost);
                END LOOP;
              END IF;

              -- Now calculate the costs of the yielded lot and reduce the step costs by the same amounts

              FOR l IN 1 ..l_step_tab(i).step_costs.COUNT
              LOOP
                new_cost_tab(l) := l_step_tab(i).step_costs(l);

                /***** Bug 4057323 - Use Cost Allocation Factor Depending on Profile value - Start *****/
                IF ( l_cost_alloc_profile = 0 ) THEN
                  new_cost_tab(l).component_cost := l_step_tab(i).step_costs(l).component_cost * l_cost_factor;              -- Bug 4057323
                  new_cost.unit_cost := new_cost.unit_cost + new_cost_tab(l).component_cost;
                  l_step_tab(i).step_costs(l).component_cost := l_step_tab(i).step_costs(l).component_cost * (1-l_cost_factor);

                ELSE
                 /* B 4057323 - The following change is to apportion the cost into multiple lots depending on LOT QUANTITIES
                     if the product is yielded into Multiple Lots */
                     /* Bug 4227784 - Replaced l_total_item_qty by the line_actual_qty. This is fail if there are mulitple lines for same product */

                  IF(l_step_tab(i).materials(j).actual_line_qty = 0) THEN /* Bug 4227784. To avoid Divide by zero error */
                    new_cost_tab(l).component_cost := 0;
                  ELSE

               /* Rajesh Patangya B9131983  Starts */
              l_actual_line_qty :=
               INV_CONVERT.INV_UM_CONVERT(ITEM_ID       => l_step_tab(i).materials(j).item_id
                                         ,LOT_NUMBER    => l_step_tab(i).materials(j).lot_number
                                         ,PRECISION     => 5
                                         ,ORGANIZATION_ID => transaction_row.orgn_id
                                         ,FROM_QUANTITY => l_step_tab(i).materials(j).actual_line_qty
                                         ,FROM_UNIT     => l_step_tab(i).materials(j).line_um
                                         ,TO_UNIT       => l_step_tab(i).materials(j).trans_um
                                         ,FROM_NAME     => NULL
                                         ,TO_NAME       => NULL
                                           );
                -- PK Bug 9069363 do not return for all negative quatities.
                IF l_actual_line_qty = -99999 THEN
                  fnd_file.put_line
                  (fnd_file.log,'ERROR: Unable to convert to Actual Line qty uom for transaction ID '
                  ||l_step_tab(i).materials(j).trans_id
                  );
                  l_return_status := 'E';
                  l_tmp := FALSE;
                  RETURN;
                END IF;

				       IF l_actual_line_qty = 0 THEN  /* divide by Zero */
				          l_actual_line_qty := 1 ;
				       END IF;
                l_step_tab(i).materials(j).actual_line_qty := l_actual_line_qty ;
                l_step_tab(i).materials(j).line_um := l_step_tab(i).step_qty_uom ;
               /* Rajesh Patangya B9131983  Ends  */
				       fnd_file.put_line
                  (fnd_file.log, 'Actual Line Qty = ' || l_actual_line_qty
                  ||'-Compo-'||l_step_tab(i).step_costs(l).component_cost ||'-factor-'||
                  l_cost_factor ||'-trans_qty-'||
                  l_step_tab(i).materials(j).trans_qty ||'-actual-'||
                   l_step_tab(i).materials(j).actual_line_qty
                   );

                    new_cost_tab(l).component_cost := l_step_tab(i).step_costs(l).component_cost * l_cost_factor * l_step_tab(i).materials(j).trans_qty / l_step_tab(i).materials(j).actual_line_qty; --l_total_item_qty;
                  END IF;

                  new_cost.unit_cost := new_cost.unit_cost + new_cost_tab(l).component_cost;
                END IF;

                /***** Bug 4057323 - Use Cost Allocation Factor Depending on Profile value - End *****/

              END LOOP;
              -- End 3548217

              IF l_debug_level >= l_debug_level_low THEN
                fnd_file.put_line(fnd_file.log,'Step costs after are');
                FOR jj IN 1..l_step_tab(i).step_costs.COUNT
                LOOP
                  fnd_file.put_line
                  (fnd_file.log,l_step_tab(i).step_costs(jj).component_cost);
                END LOOP;
                fnd_file.put_line(fnd_file.log,'New costs after are');
                FOR jj IN 1..new_cost_tab.COUNT
                LOOP
                  fnd_file.put_line
                  (fnd_file.log,new_cost_tab(jj).component_cost);
                END LOOP;
              END IF;

              -- See if this transaction is the transaction that has yielded the lot being costed
              -- Reworked the following loops for bug 3548217
              -- Rajesh Patangya B9131983
              IF transaction_row.transaction_id = l_step_tab(i).materials(j).trans_id
              AND l_step_tab(i).materials(j).lot_number = transaction_row.lot_number THEN
                -- It was. -- See if any burdens should apply to this yield

                process_burdens;

                IF l_return_status <> 'S' THEN
                  RETURN;
                END IF;

                -- If we retrieved any, incorporate ('c' = Combine) their costs into the cost accumulated so far

                IF l_burdens_total <> 0 THEN
                  -- Burdens are held per unit, we need to gross them up to the product output quantity

                  FOR l IN 1..l_burden_costs_tab.count
                  LOOP
                    l_burden_costs_tab(l).component_cost := l_burden_costs_tab(l).component_cost * transaction_row.trans_qty;
                    IF l_debug_level >= l_debug_level_medium THEN
                      fnd_file.put_line
                      (fnd_file.log,'l_burden_costs_tab['||l||'] is '||l_burden_costs_tab(l).component_cost);
                    END IF;
                  END LOOP;

                  merge_costs ( l_burden_costs_tab
                              , 1
                              , 1
                              , 'C'
                              );

                END IF;

                old_cost.header_id := NULL;

                OPEN lot_cost_cursor
                   ( l_step_tab(i).materials(j).organization_id
                   , l_step_tab(i).materials(j).item_id
                   , l_step_tab(i).materials(j).lot_number
                   , l_step_tab(i).materials(j).trans_date      -- Bug 4130869 Added Date field
                   ,l_cost_type_id
                   );
                FETCH lot_cost_cursor INTO old_cost;
                CLOSE lot_cost_cursor;

                IF old_cost.header_id IS NOT NULL THEN
                  -- A cost already exists, retrieve it together with the details,

                  OPEN lot_cost_detail_cursor
                       ( old_cost.header_id );
                  FETCH lot_cost_detail_cursor BULK COLLECT INTO old_cost_tab;
                  CLOSE lot_cost_detail_cursor;

                  FOR k IN 1 .. old_cost_tab.COUNT
                  LOOP
                    old_cost_tab(k).component_cost := old_cost_tab(k).component_cost * old_cost.onhand_qty;
                  END LOOP;

                  -- Before merging, we need to preserve the 'new' cost so that sub-ledger has access to the
                  -- details. Bug 3578680

                  prd_cost_tab := new_cost_tab;
                  prd_cost := new_cost;

                  -- Now merge the old and new costs
                  /*  PK B6853640 Do not assign zero comment out next line
                  new_cost.unit_cost := 0; */

                  merge_costs ( old_cost_tab
                              , 1
                              , 1
                              , 'C'
                              );

                  l_new_cost := new_cost.unit_cost;
                  IF l_debug_level >= l_debug_level_low THEN
                     fnd_file.put_line   (fnd_file.log, 'Before create_cost_header in process_batch ');
                     fnd_file.put_line   (fnd_file.log, 'new unit cost: '||new_cost.unit_cost);
                     fnd_file.put_line   (fnd_file.log, 'l_new unit cost: '||l_new_cost);
                     fnd_file.put_line   (fnd_file.log, 'trans qty: '||transaction_row.trans_qty);
                     fnd_file.put_line   (fnd_file.log, 'onhand qty: '||old_cost.onhand_qty);
                     fnd_file.put_line   (fnd_file.log, 'new_cost_tab count: '||new_cost_tab.count);
                     fnd_file.put_line   (fnd_file.log, 'prd_cost_tab count: '||new_cost_tab.count);
                  END IF;

                  -- At this stage we have all the header and cost component information we need
                  -- to store the costs in the database.

                   --bug 8880554 added below if condition to avoid divisor is equal to zero error
                   -- Rajesh Patangya B9131983
                  IF NVL((transaction_row.trans_qty+old_cost.onhand_qty),0) = 0 THEN
                    l_temp_qty := 1;
                  ELSE
                    l_temp_qty :=(transaction_row.trans_qty+old_cost.onhand_qty);
                  END IF;

                  IF NVL(transaction_row.trans_qty,0) = 0 THEN
                     l_temp_trans_qty := 1;
                  ELSE
                   l_temp_trans_qty:= transaction_row.trans_qty;
                  END IF;
                    -- end for bug  8880554

                  -- PK Bug 9069363

                  IF l_temp_qty IS NULL THEN
                     l_temp_qty := 1;
                  END IF;

                  IF l_temp_trans_qty IS NULL THEN
                     l_temp_trans_qty := 1;
                  END IF;

                  -- PK Bug 9069363


        /* B9131983
         IF  l_step_tab(i).materials(j).lot_number = transaction_row.lot_number THEN
             if 2 product lots Lot Number should be same */

               IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line
                  (fnd_file.log,'Before Create Header Call 1');
               END IF;

                   create_cost_header
                  ( l_step_tab(i).materials(j).item_id
                  , l_step_tab(i).materials(j).lot_number
                  , l_step_tab(i).materials(j).organization_id
                  , l_cost_type_id
                  , l_new_cost/l_temp_qty      -- B9131983
                  , l_step_tab(i).materials(j).trans_date
                  , old_cost.onhand_qty + l_step_tab(i).materials(j).trans_qty
                  , transaction_row.doc_id
                  , transaction_row.transaction_source_type_id
                  , transaction_row.transaction_action_id
                  , new_cost.header_id
                  , dummy
                  , new_cost.onhand_qty
                  , l_return_status
                  );


                  IF l_return_status ='S' THEN   /* Success of header */

                    FOR k IN 1.. new_cost_tab.count
                    LOOP    /* +ve Details */

                     /* B9131983  If cost is ZERO or component is not available
                         enter the default row in cost details */
                      IF new_cost_tab(k).cost_cmpntcls_id = 0 THEN
                         new_cost_tab(k).cost_cmpntcls_id := x_mtl_cmpntcls_id;
                      END IF;

                       IF NVL(rtrim(ltrim(new_cost_tab(k).cost_analysis_code)),'X') = 'X' THEN
                         new_cost_tab(k).cost_analysis_code := x_mtl_analysis_code;
                       END IF;

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'After Replacing component/analysis/level to fiscal policy');
                  fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
                  fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
                  fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
                  fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
                  fnd_file.put_line(fnd_file.log,'====================================');
                END IF;

                      -- IF new_cost_tab(k).component_cost <> 0 THEN
                        create_cost_detail
                        ( new_cost.header_id
                        , new_cost_tab(k).cost_cmpntcls_id
                        , new_cost_tab(k).cost_analysis_code
                        , new_cost_tab(k).cost_level
                        , new_cost_tab(k).component_cost/l_temp_qty    -- B9131983
                        , 0
                        , l_return_status
                        );

                         procedure_name := 'Process Batch';

                        IF l_return_status <> 'S' THEN
                          RETURN;
                        END IF;
                      -- END IF;      -- B9131983
                    END LOOP;   /* +ve Details */

                    FOR k IN 1 .. prd_cost_tab.COUNT
                    LOOP       /* -ve Details */

                      -- Write the 'new' costs with a -ve header ID Bug 3578680

                      /* B9131983 If cost is ZERO or component is not available
                         enter the default row in cost details */
                      IF prd_cost_tab(k).cost_cmpntcls_id = 0 THEN
                         prd_cost_tab(k).cost_cmpntcls_id := x_mtl_cmpntcls_id;
                      END IF;

                       IF NVL(rtrim(ltrim(prd_cost_tab(k).cost_analysis_code)),'X') = 'X' THEN
                         prd_cost_tab(k).cost_analysis_code := x_mtl_analysis_code;
                      END IF;

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'After Replacing component/analysis/level to fiscal policy');
                  fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||prd_cost_tab(k).cost_cmpntcls_id);
                  fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||prd_cost_tab(k).cost_analysis_code);
                  fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||prd_cost_tab(k).cost_level);
                  fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||prd_cost_tab(k).component_cost);
                  fnd_file.put_line(fnd_file.log,'====================================');
                END IF;

                    /*  IF prd_cost_tab(k).component_cost <> 0  THEN  -- B9131983 */

                        create_cost_detail
                        ( -new_cost.header_id
                        , prd_cost_tab(k).cost_cmpntcls_id
                        , prd_cost_tab(k).cost_analysis_code
                        , prd_cost_tab(k).cost_level
                        , prd_cost_tab(k).component_cost/l_temp_trans_qty      -- B9131983
                        , 0
                        , l_return_status
                        );

                        IF l_return_status <> 'S' THEN

                          RETURN;
                        END IF;
                     /* END IF;   -- B9131983 */
                    END LOOP;    /* -ve Details */

                    create_material_transaction
                    ( new_cost.header_id
                    , l_cost_type_id
                    , l_step_tab(i).materials(j).trans_date
                    , l_step_tab(i).materials(j).trans_qty
                    , l_step_tab(i).materials(j).trans_um
                    , prd_cost.unit_cost
                    , l_step_tab(i).materials(j).trans_id
                    , new_cost.unit_cost/l_temp_qty     -- B9131983
                    , new_cost.onhand_qty
                    , old_cost.unit_cost
                    , old_cost.onhand_qty
                    , 1
                    ,transaction_row.lot_number
                    , l_return_status
                    );

                    IF l_debug_level >= l_debug_level_low THEN
                       fnd_file.put_line (fnd_file.log, 'Completed inserts into tables in process_batch ');
                    END IF;

                    IF l_return_status <> 'S' THEN

                      RETURN;
                    END IF;

                  ELSE    /* Success of header */
                    RETURN;
                  END IF;  /* Success of header */

          /*    END IF;     if 2 product lots Lot Number should be same */


                ELSE    /*   IF old_cost.header_id IS NOT NULL THEN */

                IF   l_debug_level >= l_debug_level_high THEN
                  fnd_file.put_line(fnd_file.log,'No cost currently exists, create one and all associated details and transactions');
                END IF;

                  -- No cost currently exists, create one and all associated details
                  -- and transactions. Again, this is only for the invoking transaction

                  IF l_debug_level >= l_debug_level_high  THEN
                    fnd_file.put_line
                    ( fnd_file.log,'New cost tab has '||to_char(new_cost_tab.count)||' entries:');

                    FOR k IN 1 .. new_cost_tab.COUNT
                    LOOP
                      fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
                      fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
                      fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
                      fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
                      fnd_file.put_line(fnd_file.log,'====================================');
                    END LOOP;
                  END IF;

                  /*  B9131983 Rajesh Patangya Starts */
                    --bug 8880554 added below if condition to avoid divisor is equal to zero error
                  IF NVL((transaction_row.trans_qty+old_cost.onhand_qty),0) = 0 THEN
                    l_temp_qty := 1;
                  ELSE
                    l_temp_qty :=(transaction_row.trans_qty+old_cost.onhand_qty);
                  END IF;
                  -- NOTE: Dowe need to use l_temp_qty, confirm with prasad and venkat
                  -- Prd_tab should be used to isnert the negative cost details records for subledger
                  -- posting purposes only, what does it means is that we need to enter the batch cost to book the entries

                  IF NVL(transaction_row.trans_qty,0) = 0 THEN
                     l_temp_trans_qty := 1;
                  ELSE
                   l_temp_trans_qty:= transaction_row.trans_qty;
                  END IF;
                    -- end for bug  8880554

                  -- PK Bug 9069363

                  IF l_temp_qty IS NULL THEN
                     l_temp_qty := 1;
                  END IF;

                  IF l_temp_trans_qty IS NULL THEN
                     l_temp_trans_qty := 1;
                  END IF;

                  -- PK Bug 9069363
                  /*  B9131983 Rajesh Patangya Ends */

                  IF l_debug_level >= l_debug_level_high  THEN
                    fnd_file.put_line(fnd_file.log,' New total cost is : '||new_cost.unit_cost);
                    fnd_file.put_line(fnd_file.log,' New unit cost is  : '||new_cost.unit_cost/l_temp_trans_qty);

                  END IF;

          /* B9131983
         IF  l_step_tab(i).materials(j).lot_number = transaction_row.lot_number THEN
              if 2 product lots Lot Number should be same */

               IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line
                  (fnd_file.log,'Before Create Header Call 2');
               END IF;

                  create_cost_header
                  ( l_step_tab(i).materials(j).item_id
                  , l_step_tab(i).materials(j).lot_number   /* INCONV SSCHINCH */
                  , l_step_tab(i).materials(j).organization_id
                  , l_cost_type_id
                  , new_cost.unit_cost/l_temp_trans_qty        -- B9131983
                  , l_step_tab(i).materials(j).trans_date
                  , l_step_tab(i).materials(j).trans_qty
                  , transaction_row.doc_id
                  , transaction_row.transaction_source_type_id
                  , transaction_row.transaction_action_id
                  , new_cost.header_id
                  , dummy
                  , new_cost.onhand_qty
                  , l_return_status
                  );

                  IF l_return_status = 'S' THEN    /* l_return_status = 'S' */

                    FOR k IN 1..new_cost_tab.count
                    LOOP       /* +ve Details */

                      -- IF new_cost_tab(k).component_cost <> 0 THEN
                       /* B9131983 If cost is ZERO or component is not available
                         enter the default row in cost details */
                      IF new_cost_tab(k).cost_cmpntcls_id = 0 THEN
                         new_cost_tab(k).cost_cmpntcls_id := x_mtl_cmpntcls_id;
                      END IF;

                       IF NVL(rtrim(ltrim(new_cost_tab(k).cost_analysis_code)),'X') = 'X' THEN
                         new_cost_tab(k).cost_analysis_code := x_mtl_analysis_code;
                       END IF;

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'After Replacing component/analysis/level to fiscal policy'
);
                  fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
                  fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
                  fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
                  fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
                  fnd_file.put_line(fnd_file.log,'====================================');
                END IF;

                        create_cost_detail
                        ( new_cost.header_id
                        , new_cost_tab(k).cost_cmpntcls_id
                        , new_cost_tab(k).cost_analysis_code
                        , 0
                        , new_cost_tab(k).component_cost/l_temp_qty    -- B9131983
                        , 0
                        , l_return_status
                        );
                      -- Bug 9069363 create zero cost detail as well.
                      -- END IF;

                      IF l_return_status <> 'S' THEN
                        RETURN;
                      END IF;

             -- Becuase there is no previous Header record present
             -- and hence Perpetual and transaction csot are same
             -- Juse need to negate the header_id and all other inforamtion will be same

                        create_cost_detail
                        ( -1*new_cost.header_id
                        , new_cost_tab(k).cost_cmpntcls_id
                        , new_cost_tab(k).cost_analysis_code
                        , 0
                        , new_cost_tab(k).component_cost/l_temp_qty   -- B9131983
                        , 0
                        , l_return_status
                        );
                      -- Bug 9069363 create zero cost detail as well.
                      -- END IF;

                      IF l_return_status <> 'S' THEN
                        RETURN;


                      END IF;


                    END LOOP;    /* +ve Details */

                  END IF;    /* l_return_status = 'S' */

                  create_material_transaction
                  ( new_cost.header_id
                  , l_cost_type_id
                  , l_step_tab(i).materials(j).trans_date
                  , l_step_tab(i).materials(j).trans_qty
                  , l_step_tab(i).materials(j).trans_um
                  , new_cost.unit_cost
                  , l_step_tab(i).materials(j).trans_id
                  , new_cost.unit_cost/l_temp_trans_qty     -- B9131983
                  , l_step_tab(i).materials(j).trans_qty
                  , NULL
                  , NULL
                  , NULL
                  ,transaction_row.lot_number
                  , l_return_status
                  );

                  IF l_return_status <> 'S' THEN

                    RETURN;
                  END IF;

              /*  END IF;   if 2 product lots Lot Number should be same */

                END IF;  /*  IF old_cost.header_id IS NOT NULL THEN*/

              END IF;

            END IF;

          END LOOP;   /*  -- Main Processing */

          IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line
            (fnd_file.log,'After yield check');
          END IF;

          -- If we are not on a terminal step, we have to roll the costs into
          -- the next step(s) in the dependency chain. Also, if the route divides
          -- at this point we need to aportion the costs held in this step between
          -- all subsequent steps.
          IF l_step_tab(i).dependencies(1).step_index IS NOT NULL THEN

            IF l_debug_level >= l_debug_level_medium  THEN
              fnd_file.put_line
              (fnd_file.log,'Before quantity accumulation');
            END IF;

            l_total_qty := 0;

            FOR j in 1..l_step_tab(i).dependencies.count
            LOOP
               -- B9131983 need to check why step_qty is NULL on some steps. using NVL at the moment
              l_total_qty := l_total_qty + NVL(l_step_tab(i).dependencies(j).step_qty,0);
            END LOOP;

            IF l_debug_level >= l_debug_level_high THEN

              fnd_file.put_line
              (fnd_file.log,'After quantity accumulation, total_qty is'
              ||to_char(l_total_qty,'999999999.99')
              );
            END IF;


            FOR j IN 1..l_step_tab(i).dependencies.count
            LOOP
               -- B9131983 need to check why step_qty is NULL on some steps. using NVL at the moment
              IF l_total_qty <> 0 THEN
                l_cost_factor := NVL(l_step_tab(i).dependencies(j).step_qty, 0) / l_total_qty;
              ELSE
                l_cost_factor := 0;
                IF l_debug_level >= l_debug_level_medium THEN
                   fnd_file.put_line
                    (fnd_file.log,'Assigning cost factor as zero');
                END IF;
              END IF;
              IF l_debug_level >= l_debug_level_medium THEN
                fnd_file.put_line
                (fnd_file.log,'Cost factor is '||to_char(l_cost_factor,'9999.99'));
              END IF;

              -- Roll current costs into next step(s). We loop through all costs accumulated
              -- and apply the above factor to each cost when rolling them forward

              -- Find index of step to roll costs into

              l_step_index := l_step_tab(i).dependencies(j).step_index;

              FOR k IN 1..l_step_tab(i).step_costs.count
              LOOP
                 -- B9131983
                IF (NVL(l_step_tab(i).step_costs(k).cost_analysis_code, ' ') <> ' ')
                THEN

                  IF l_debug_level >= l_debug_level_medium THEN

                    fnd_file.put_line
                    (fnd_file.log,'Rolling costs of step '
                    ||to_char(i)||' into step '||to_char(l_step_index));
                   END IF;

                   -- Now roll current costs into the next step

                   l_cost_accrued := FALSE;

                   FOR l IN 1..l_step_tab(l_step_index).inherited_costs.count
                   LOOP
                     IF   l_step_tab(i).step_costs(k).cost_cmpntcls_id
                         =l_step_tab(l_step_index).inherited_costs(l).cost_cmpntcls_id
                     AND  l_step_tab(i).step_costs(k).cost_analysis_code
                         =l_step_tab(l_step_index).inherited_costs(l).cost_analysis_code
                     AND  l_step_tab(i).step_costs(k).cost_level
                         =l_step_tab(l_step_index).inherited_costs(l).cost_level
                     THEN
                       l_step_tab(l_step_index).inherited_costs(l).component_cost :=
                         l_step_tab(l_step_index).inherited_costs(l).component_cost
                        +l_step_tab(i).step_costs(k).component_cost * l_cost_factor;

                       l_cost_accrued := TRUE;
                       EXIT;
                     END IF;
                   END LOOP;

                   -- If we didn't find a match, create a new cost in the target steps
                   -- inherited costs

                   IF NOT l_cost_accrued THEN
                     -- B9131983 use NVL here as well ??
                     IF l_debug_level >= l_debug_level_medium THEN
                       fnd_file.put_line (fnd_file.log,'cost_analysis_code '||l_step_tab(l_step_index).inherited_costs(1).cost_analysis_code||'.');
                     END IF;
                     IF l_step_tab(l_step_index).inherited_costs(1).cost_analysis_code = ' '
                     THEN
                       l_step_tab(l_step_index).inherited_costs(1) :=
                         l_step_tab(i).step_costs(k);
                       l_step_tab(l_step_index).inherited_costs(1).component_cost :=
                         l_step_tab(i).step_costs(k).component_cost * l_cost_factor;
                     ELSE
                       l_step_tab(l_step_index).inherited_costs.EXTEND;
                       l := l_step_tab(l_step_index).inherited_costs.count;
                       l_step_tab(l_step_index).inherited_costs(l) := l_step_tab(i).step_costs(k);
                       l_step_tab(l_step_index).inherited_costs(l).component_cost :=
                       l_step_tab(i).step_costs(k).component_cost * l_cost_factor;
                     END IF;
                   END IF;
                 END IF;
               END LOOP;
             END LOOP;
           END IF;                     -- If we are not in terminal step
         END LOOP; -- End of outer rollup loop
       END IF;-- End of conditional skip
     END IF;-- End of if this is an output

 /*    IF l_debug_level >= l_debug_level_high THEN
       lot_cost_audit
	     ( transaction_row.inventory_item_id
	     , transaction_row.lot_number
	     , transaction_row.orgn_id
	     , transaction_row.doc_id
	     , transaction_row.trans_date
	     , l_step_tab
	     );
     END IF;
  */
     -- Finally, mark the invoking transaction as costed
     -- Also, mark the batch as having participated in actual costing - PJS 11Feb04

    IF l_final_run_flag = 1 THEN -- umoogala 05-Dec-2003
       /*UPDATE mtl_transaction_lot_numbers
       SET    lot_cost_ind 	      = 1,
	      --request_id              = l_request_id,
	      --program_application_id  = l_prog_appl_id,
	      --program_id              = l_program_id,
	      last_update_date     = sysdate
       WHERE  transaction_id = transaction_row.transaction_id;*/

       UPDATE gme_batch_header
       SET    actual_cost_ind = 1
       WHERE  batch_id = transaction_row.doc_id;

     END IF;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Entered Procedure: '||procedure_name);
     END IF;

END process_batch;



    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to handle created lots (CREI/CRER)                                               *
    --*                                                                                            *
    --**********************************************************************************************

PROCEDURE process_creation
IS
  l_header_id    NUMBER;
  l_unit_cost    NUMBER;
  l_onhand_qty   NUMBER;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Process Creation';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

  -- We assume that no lot cost exists, as the lot is being created by this transaction.
  -- The only costs we can determine come from burdens.

  process_burdens;

  IF l_return_status = 'S' THEN
    create_cost_header
    ( p_item_id              => transaction_row.inventory_item_id
    , p_lot_number           => transaction_row.lot_number  /* INVCONV sschinch */
    , p_orgn_id              => transaction_row.orgn_id         /* INVCONV sschinch */
    , p_cost_type_id         => l_cost_type_id
    , p_unit_cost            => NVL(l_burdens_total,0)
    , p_cost_date            => transaction_row.trans_date
    , p_onhand_qty           => transaction_row.trans_qty
    , p_trx_src_type_id      => transaction_row.transaction_source_type_id  /* INVCONV sschinch */
    , p_txn_act_id           => transaction_row.transaction_action_id   /* INVCONV sschinch */
    , p_doc_id               => transaction_row.doc_id
    , x_header_id            => l_header_id
    , x_unit_cost            => l_unit_cost
    , x_onhand_qty           => l_onhand_qty
    , x_return_status        => l_return_status
    );

    -- Bug 3388974-2
    new_cost.header_id := l_header_id;
    new_cost.unit_cost := l_unit_cost;
    new_cost.onhand_qty:= l_onhand_qty;

    IF l_return_status = 'S' THEN

      IF l_burdens_total <> 0 THEN
        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,'Processing' || l_burden_costs_tab.count ||' burdens for CREI transaction ID '||transaction_row.transaction_id);
        END IF;

        FOR i IN 1..l_burden_costs_tab.COUNT
        LOOP
          create_cost_detail
          ( l_header_id
          , l_burden_costs_tab(i).cost_cmpntcls_id
          , l_burden_costs_tab(i).cost_analysis_code
          , 0
          , l_burden_costs_tab(i).component_cost
          , 1
          , l_return_status
          );

          IF l_return_status <> 'S' THEN
            EXIT;
          END IF;
        END LOOP;

      ELSE

        IF l_debug_level >= l_debug_level_medium THEN
          fnd_file.put_line
          (fnd_file.log,'No burdens found, retrieving default component class and analysis code for cost details');
        END IF;


        OPEN component_class_cursor
             (l_le_id, transaction_row.inventory_item_id, transaction_row.orgn_id,transaction_row.trans_date); /* INVCONV sschinch */
        FETCH component_class_cursor INTO component_class_id, cost_analysis_code, dummy;
        CLOSE component_class_cursor;

        create_cost_detail
        ( l_header_id
        , component_class_id
        , cost_analysis_code
        , 0
        , 0.00
        , 0
        , l_return_status
        );

      END IF; -- end of cost details creation
    ELSE
      RETURN; --BUG 3476508  Some kind of problem with burdens
    END IF; -- end of header creation

    IF l_return_status = 'S' THEN

      create_material_transaction
      ( l_header_id
      , l_cost_type_id
      , transaction_row.trans_date
      , transaction_row.trans_qty
      , transaction_row.trans_um
      , transaction_row.trans_qty * l_burdens_total
      , transaction_row.transaction_id
      , l_burdens_total
      , transaction_row.trans_qty
      , NULL
      , NULL
      , NULL
      ,transaction_row.lot_number
      , l_return_status
      );

      IF l_return_status <> 'S' THEN
        RETURN;
      END IF;

    ELSE
      RETURN;
    END IF;
  END IF;
  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

EXCEPTION
  WHEN OTHERS THEN
     fnd_file.put_line
     (fnd_file.log,'Failed in procedure process_creation with error');
     fnd_file.put_line(fnd_file.log,SQLERRM);
       l_return_status := 'U';
END process_creation;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to handle sales orders (OMSO/OPSO)                                               *
    --*                                                                                            *
    --**********************************************************************************************

PROCEDURE process_sales_order
IS
  loop_count NUMBER;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Process Sales Order';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;
  -- This is a debit on the source organization so treat this as an adjustment. Returns are handled
  -- as PORC transactions.

  process_adjustment;

  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
  END IF;

END process_sales_order;



    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to handle cycle counts (PIPH/PICY)                                               *
    --*                                                                                            *
    --**********************************************************************************************


PROCEDURE process_cycle_count
IS
  loop_count NUMBER;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Process cycle count';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

  -- For costing purposes this is equivalent to an adjustment

  process_adjustment;
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
  END IF;

END process_cycle_count;

-- AF

/************************************************************************
NAME
        process_lc_adjustments


DESCRIPTION
        This function Process all Actual LC adjustments for the item and lot
        and calculate lot cost also insert a record in lot cost adjustments table

AUTHOR
   Andrea  4-Aug-09, LCM-OPM Integration, bug 8642337

HISTORY
*************************************************************************/
PROCEDURE process_lc_adjustments IS

  CURSOR c_adjustments_cursor IS
  SELECT
         glat.cost_cmpntcls_id,
         glat.cost_analysis_code,
         (nvl(glat.new_landed_cost,0) - nvl(glat.prior_landed_cost,0)) * (rtt.primary_quantity /rt.primary_quantity ) adjustment_amt,
         nvl(glat.new_landed_cost,0),
         glat.adj_transaction_id,
         glat.ship_header_id,
         glat.ship_line_id,
         glat.adjustment_num,
         glat.organization_id,
         glat.inventory_item_id,
         glat.rcv_transaction_id,
         glat.charge_line_type_code,
         glat.component_type,
         glat.component_name,
         glat.transaction_date,
         glat.primary_quantity,
         glat.primary_uom_code,
         glat.lc_adjustment_flag,
         rtt.lot_num
   FROM
         gmf_lc_adj_transactions glat,
         rcv_transactions rt,
         rcv_lot_transactions rtt
  WHERE
         glat.adj_transaction_id = transaction_row.transaction_id
    AND  glat.rcv_transaction_id = transaction_row.doc_id
    AND  glat.ship_line_id       = transaction_row.line_id
    AND  (lc_adjustment_flag  = 1 OR glat.adjustment_num > 0 )
    AND  glat.rcv_transaction_id = rt.transaction_id
    AND  rt.transaction_id       = rtt.transaction_id
    AND  glat.component_type IN ('ITEM PRICE','CHARGE')
    AND  rtt.lot_num            = transaction_row.lot_number;

 TYPE adjustments_cursor IS TABLE OF c_adjustments_cursor%ROWTYPE;
 l_adjustments_cursor adjustments_cursor;

  new_unit_cost   NUMBER;
  l_new_lc        NUMBER;
  procedure_name VARCHAR2(100);

  CURSOR cur_lca_count (cp_adj_transaction_id NUMBER,
                        cp_lot_number gmf_lc_lot_cost_adjs.lot_number%TYPE) IS
  SELECT 1  FROM gmf_lc_lot_cost_adjs
   WHERE adj_transaction_id = cp_adj_transaction_id
     AND lot_number         = cp_lot_number  ;

   l_count NUMBER := 0;

BEGIN
    procedure_name := 'process_lc_adjustments';
    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
        fnd_file.put_line(fnd_file.log,'INSIDE LC Actual adjustments for adjustment transaction ID/Rcv Transaction Id/Shipment line ID '
                                        ||transaction_row.transaction_id ||'/'||transaction_row.doc_id ||'/'|| transaction_row.line_id);
    fnd_file.put_line(fnd_file.log,'transaction_row.transaction_id: '||transaction_row.transaction_id);
    fnd_file.put_line(fnd_file.log,'Entered transaction_row.doc_id: '||transaction_row.doc_id);
    fnd_file.put_line(fnd_file.log,'Entered transaction_row.line_id: '||transaction_row.line_id);
    END IF;

    -- Load adjustment cost details
    OPEN c_adjustments_cursor;
    FETCH c_adjustments_cursor BULK COLLECT INTO l_adjustments_cursor;
    CLOSE c_adjustments_cursor;

    IF l_debug_level >= l_debug_level_medium THEN
        fnd_file.put_line(fnd_file.log,'Opened the c_adjustments_cursor');
    END IF;

    FOR i IN 1 .. l_adjustments_cursor.COUNT
    LOOP

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'Add the gmf_cost_type to new_cost_tab');
        END IF;

        new_cost_tab(i) := SYSTEM.gmf_cost_type(l_adjustments_cursor(i).cost_cmpntcls_id ,
                                                l_adjustments_cursor(i).cost_analysis_code,
                                                0,
                                                l_adjustments_cursor(i).adjustment_amt,
                                                0);

        IF l_debug_level >= l_debug_level_medium THEN
            fnd_file.put_line(fnd_file.log,'new_cost_tab('||i ||').cost_cmpntcls_id: ' || new_cost_tab(i).cost_cmpntcls_id);
            fnd_file.put_line(fnd_file.log,'new_cost_tab('||i ||').cost_analysis_code: ' || new_cost_tab(i).cost_analysis_code);
            fnd_file.put_line(fnd_file.log,'new_cost_tab('||i ||').cost_level: ' || new_cost_tab(i).cost_level);
            fnd_file.put_line(fnd_file.log,'new_cost_tab('||i ||').component_cost: ' || new_cost_tab(i).component_cost);
            fnd_file.put_line(fnd_file.log,'new_cost_tab('||i ||').burden_ind: ' || new_cost_tab(i).burden_ind);
        END IF;

        -- Now merge the costs adjustments just loaded with the existing costs loaded in the rollup_lot_costs
        -- procedure. pass Merge type as V value adjustment

        merge_costs ( old_cost_tab
                    , 0
                    , old_cost.onhand_qty
                    , 'V');

        -- Write the adjusted costs to the database
          create_cost_header
            ( transaction_row.inventory_item_id
            , transaction_row.lot_number
            , transaction_row.orgn_id
            , l_cost_type_id
            , new_cost.unit_cost
            , transaction_row.trans_date
            , old_cost.onhand_qty
            , transaction_row.transaction_id
            , transaction_row.transaction_source_type_id
            , transaction_row.transaction_action_id
            , new_cost.header_id
            , new_unit_cost
            , new_cost.onhand_qty
            , l_return_status);

        -- If that worked OK, create the new cost details
        IF l_return_status = 'S' THEN
            FOR j IN 1..new_cost_tab.COUNT LOOP

                create_cost_detail
                    (new_cost.header_id
                   , new_cost_tab(j).cost_cmpntcls_id
                   , new_cost_tab(j).cost_analysis_code
                   , 0
                   , new_cost_tab(j).component_cost
                   , 0
                   , l_return_status);

                IF l_return_status <> 'S'THEN
                    RETURN;
                END IF;
            END LOOP;

            -- Finally create a transaction for the adjustment
            new_cost.unit_cost := new_unit_cost;
            IF NOT old_cost_tab.EXISTS(1) THEN
              create_material_transaction
                ( new_cost.header_id
                , l_cost_type_id
                , transaction_row.trans_date
                , transaction_row.trans_qty
                , transaction_row.trans_um
                , new_cost.onhand_qty * new_cost.unit_cost
                ,-9             -- trans_id
                , new_cost.unit_cost
                , transaction_row.trans_qty
                , NULL
                , NULL
                , NULL
                ,transaction_row.lot_number
                , l_return_status);
            ELSE
              create_material_transaction
                ( new_cost.header_id
                , l_cost_type_id
                , transaction_row.trans_date
                , transaction_row.trans_qty
                , transaction_row.trans_um
                , new_cost.onhand_qty * new_cost.unit_cost - old_cost.onhand_qty * old_cost.unit_cost
                , -9    -- trans_id
                , new_cost.unit_cost
                , new_cost.onhand_qty
                , old_cost.unit_cost
                , old_cost.onhand_qty
                , NULL
                , transaction_row.lot_number
                , l_return_status);
            END IF;
          END IF;

           fnd_file.put_line(fnd_file.log,'adj_transaction_id: ' || l_adjustments_cursor(i).adj_transaction_id);

           OPEN cur_lca_count (l_adjustments_cursor(i).adj_transaction_id, transaction_row.lot_number);
           FETCH cur_lca_count INTO l_count;
           CLOSE cur_lca_count;

       /* If LC lot cost adjustments exists update else insert adjustment record  */
         IF l_count >0 THEN

            UPDATE  gmf_lc_lot_cost_adjs lca SET
                    lca.lot_costed_flag        = l_lot_cost_flag
                  , lca.last_update_date       = sysdate
                  , lca.last_updated_by        = l_user_id
                  , lca.last_update_login      = l_user_id
                  , lca.program_application_id = l_prog_appl_id
                  , lca.program_id             = l_program_id
                  , lca.request_id             = l_request_id
              WHERE
                    lca.adj_transaction_id = l_adjustments_cursor(i).adj_transaction_id
                AND lca.lot_number         = transaction_row.lot_number  ;

         ELSE
             INSERT INTO gmf_lc_lot_cost_adjs(
                    lc_adjustment_id,         --01
                    adj_transaction_id,       --02
                    adjustment_quantity,      --03
                    costed_quantity,          --04
                    total_quantity,           --05
                    quantity_uom_code,        --06
                    unit_base_price,          --07
                    base_amount,              --08
                    trans_amount,             --09
                    base_adj_amount,          --10
                    trans_adj_amount,         --11
                    cost_type_id,             --12
                    accounted_flag,           --13
                    final_posting_date,       --14
                    lot_number,               --15
                    lot_costed_flag ,         --16
                    onhand_quantity,          --17
                    old_cost_header_id,       --18
                    new_cost_header_id,       --19
                    creation_date,            --20
                    created_by,               --21
                    last_update_date,         --22
                    last_updated_by,          --23
                    last_update_login,        --24
                    request_id,               --25
                    program_application_id,   --26
                    program_id,               --27
                    program_udpate_date       --28
                   )
             VALUES(
                    gmf_lc_actual_adjs_s.NEXTVAL,               --01
                    l_adjustments_cursor(i).adj_transaction_id, --02
                    new_cost.onhand_qty,                        --03
                    new_cost.onhand_qty,                        --04
                    new_cost.onhand_qty,                        --05
                    transaction_row.trans_um,                   --06
                    new_cost.unit_cost,                         --07
                    l_adjustments_cursor(i).adjustment_amt,     --08  base_amount
                    l_adjustments_cursor(i).adjustment_amt,     --09  trans_amount
                    l_adjustments_cursor(i).adjustment_amt,     --10  base_adj_amount
                    l_adjustments_cursor(i).adjustment_amt,     --11  trans_adj_amount
                    l_cost_type_id,                             --12
                    'N',                                        --13
                    NULL,                                       --14
                    transaction_row.lot_number,                 --15
                    l_lot_cost_flag,                            --16
                    new_cost.onhand_qty,                        --17
                    old_cost.header_id,                         --18
                    new_cost.header_id,                         --19
                    SYSDATE,                                    --20
                    l_user_id,                                  --21
                    SYSDATE,                                    --22
                    l_user_id,                                  --23
                    0,                                          --24
                    l_request_id,                               --25
                    l_prog_appl_id,                             --26
                    l_program_id,                               --27
                    SYSDATE                                     --28
                   );

         END IF;

    END LOOP;

    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Leaving Procedure: '|| procedure_name );
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'ERROR: Unable to Process Actual LC Adjustment ');
    fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
    l_return_status := 'E';

END process_lc_adjustments;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to delete previously costed rows in the trail run.                               *
    --*                                                                                            *
    --**********************************************************************************************


PROCEDURE delete_lot_costs
IS

    TYPE lot_cost_cursor_type IS REF CURSOR;
    Cur_lc_header lot_cost_cursor_type;

    TYPE header_ids_tab IS TABLE OF gmf_lot_costs.header_id%TYPE
    	INDEX BY BINARY_INTEGER;
    l_header_ids_tab       header_ids_tab;
    l_empty_header_ids_tab header_ids_tab;


    TYPE rowids_tab IS TABLE OF rowid INDEX BY BINARY_INTEGER;
    l_rowids_tab       rowids_tab;
    l_empty_rowids_tab rowids_tab;


    l_rows_to_delete	PLS_INTEGER;
    l_indx_from		PLS_INTEGER;
    l_indx_to		PLS_INTEGER;
    l_max_loop_cnt	PLS_INTEGER;
    l_remaining_rows	PLS_INTEGER;

    l_matl_rows_deleted PLS_INTEGER;
    l_cdtl_rows_deleted PLS_INTEGER;
    procedure_name VARCHAR2(100);

BEGIN
  procedure_name := 'Delete Lot Costs';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

  l_rows_to_delete	:= 1000;
  l_matl_rows_deleted   := 0;
  l_cdtl_rows_deleted   := 0;

  /* umoogala 29-Mar-2004
  ** Since item_id overrides itemcost_class check for item_id first
  */

    -- Open a cursor that retrieves only the item/lot/sublot specified
    OPEN Cur_lc_header FOR
    	SELECT glc.header_id, glc.rowid
	      FROM  gmf_lot_costs glc,
	            gmf_lot_costed_items_gt gpo
       WHERE  glc.organization_id   = gpo.organization_id
         AND  glc.inventory_item_id = gpo.inventory_item_id
	       AND  glc.cost_type_id      = l_cost_type_id
	       AND  gpo.organization_id IN (select organization_id from gmf_process_organizations_gt
	                                     where legal_entity_id = l_le_id)/* Bug 8687115 */
	       AND  glc.final_cost_flag 	= 0
	       --AND  glc.inventory_item_id = l_item_id  /*jboppana*/
	       AND  glc.lot_number 		    = DECODE(l_lot_no, NULL, glc.lot_number, l_lot_no)
	       ;

  FETCH Cur_lc_header BULK COLLECT INTO l_header_ids_tab, l_rowids_tab;
  CLOSE Cur_lc_header;

  IF l_header_ids_tab.EXISTS(1) THEN

    --
    -- umoogala: delete and commit for every 10000 rows
    -- All the logic here is to avoid 'ORA-22160: element at index [n] does not exist'
    -- error when trying to delete non-existent elememnt.
    --

    l_indx_from      := l_header_ids_tab.FIRST;
    l_remaining_rows := l_header_ids_tab.count;

    IF l_header_ids_tab.count <= l_rows_to_delete THEN
      l_indx_to      := l_header_ids_tab.count;
      l_max_loop_cnt := 1;

    ELSE
      l_indx_to      := l_rows_to_delete;
      l_max_loop_cnt := ceil(l_header_ids_tab.count/l_rows_to_delete);
    END IF;


    fnd_file.put_line(fnd_File.LOG, '#of rows to delete in cost header: ' || l_header_ids_tab.count);
    fnd_file.put_line(fnd_File.LOG, 'l_max_loop_cnt: ' || l_max_loop_cnt);

    FOR i in 1..l_max_loop_cnt
    LOOP
        -- Delete all material trx info
        FORALL indx IN l_indx_from..l_indx_to
          DELETE FROM gmf_material_lot_cost_txns
          WHERE cost_header_id in l_header_ids_tab(indx);

  	      l_matl_rows_deleted := l_matl_rows_deleted + SQL%ROWCOUNT;

        -- Delete all cost details
        FORALL indx IN l_indx_from..l_indx_to
          DELETE FROM gmf_lot_cost_details
          WHERE abs(header_id) in l_header_ids_tab(indx);

          l_cdtl_rows_deleted := l_cdtl_rows_deleted + SQL%ROWCOUNT;

        COMMIT;

        l_remaining_rows := l_header_ids_tab.COUNT - (i * l_rows_to_delete);

        EXIT WHEN (l_header_ids_tab.count <= l_rows_to_delete) OR
                  (l_remaining_rows < 0);


        IF l_remaining_rows <= l_rows_to_delete THEN
          l_indx_from := l_indx_to + 1;
          l_indx_to   := l_header_ids_tab.COUNT;

        ELSE
          l_indx_from := l_indx_to + 1;
          l_indx_to   := l_indx_to + l_rows_to_delete;
        END IF;

    END LOOP;

    -- Now delete all rows from main lot costs table
    FORALL indx IN l_rowids_tab.FIRST..l_rowids_tab.LAST
      DELETE FROM gmf_lot_costs
      WHERE rowid in l_rowids_tab(indx);

    fnd_file.put_line(fnd_File.LOG, '  ' || l_matl_rows_deleted || ' rows deleted from gmf_material_lot_cost_txns.');
    fnd_file.put_line(fnd_File.LOG, '  ' || l_cdtl_rows_deleted || ' rows deleted from gmf_lot_cost_details.');
    fnd_file.put_line(fnd_File.LOG, '  ' || SQL%ROWCOUNT || ' rows deleted from gmf_lot_costs.');

    COMMIT;

    -- remove old rows and release memory.
    l_header_ids_tab	:= l_empty_header_ids_tab;
    l_rowids_tab	:= l_empty_rowids_tab;

  END IF;

/***** Bug 4094132 -  Added the following Delete - Start  *****/
-- Delete the residual transactions for which header is final costed
-- but because of reversal, one more transaction got created for the same header.

DELETE
  FROM gmf_material_lot_cost_txns t
 WHERE cost_type_id = l_cost_type_id
  AND t.final_cost_flag = 0 -- Bug 7173679
  AND EXISTS (
          SELECT 1
            FROM gmf_lot_costs glc,
                 gmf_process_organizations_gt gpo
           WHERE glc.organization_id = gpo.organization_id
             AND glc.header_id = t.cost_header_id
             AND glc.cost_type_id = t.cost_type_id
             AND glc.final_cost_flag = 1
             );

  l_matl_rows_deleted := l_matl_rows_deleted + SQL%ROWCOUNT;

 IF l_matl_rows_deleted = 0 THEN
    fnd_file.put_line(fnd_File.LOG, '  No rows found to delete.');
 END IF;

 COMMIT;
 /***** Bug 4094132 -  Added the above Delete  - End *****/
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
  END IF;

END delete_lot_costs;

    --**********************************************************************************************
    --*                                                                                            *
    --* Procedure to process Lot cost Adjustment rows                                              *
    --*                                                                                            *
    --**********************************************************************************************

PROCEDURE process_lot_cost_adjustments
IS
  CURSOR adjustments_cursor IS
  SELECT SYSTEM.gmf_cost_type
	 ( lcad.cost_cmpntcls_id
         , lcad.cost_analysis_code
         , 0
         , lcad.adjustment_cost
         , 0
	 )
  FROM  gmf_lot_cost_adjustment_dtls lcad
  WHERE lcad.adjustment_id = transaction_row.doc_id
  AND   lcad.delete_mark = 0;

  new_unit_cost   NUMBER;
  procedure_name VARCHAR2(100);

BEGIN
  procedure_name := 'Process Lot Cost Adjustments';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
     fnd_file.put_line
    (fnd_file.log,'INSIDE lot_cost_adjustments for transaction ID '||transaction_row.transaction_id);
  END IF;

  -- Load adjustment cost details

  OPEN  adjustments_cursor;
  FETCH adjustments_cursor BULK COLLECT INTO new_cost_tab;
  CLOSE adjustments_cursor;

  -- Now merge the costs adjustments just loaded with the existing costs loaded in the rollup_lot_costs
  -- procedure.

   merge_costs ( old_cost_tab
  , 0
  , old_cost.onhand_qty
  , 'C'
  );
  -- Write the adjusted costs to the database
/* INVCONV sschinch changes done to parameter*/
  create_cost_header
  ( transaction_row.inventory_item_id
  , transaction_row.lot_number
  , transaction_row.orgn_id
  , l_cost_type_id
  , new_cost.unit_cost
  , transaction_row.trans_date
  , old_cost.onhand_qty
  , transaction_row.doc_id
  , transaction_row.transaction_source_type_id
  ,transaction_row.transaction_action_id
  , new_cost.header_id
  , new_unit_cost
  , new_cost.onhand_qty
  , l_return_status
  ); -- PJS 17-Mar-2004 no bug reference

  -- If that worked OK, create the new cost details

  IF l_return_status = 'S' THEN
    FOR i IN 1..new_cost_tab.COUNT
    LOOP
      create_cost_detail
      ( new_cost.header_id
      , new_cost_tab(i).cost_cmpntcls_id
      , new_cost_tab(i).cost_analysis_code
      , 0
      , new_cost_tab(i).component_cost
      , 0
      , l_return_status
      );

      IF l_return_status <> 'S' THEN
        RETURN;
      END IF;
    END LOOP;

    -- Finally create a transaction for the adjustment

    new_cost.unit_cost := new_unit_cost;

    IF NOT old_cost_tab.EXISTS(1) THEN
      create_material_transaction
      ( new_cost.header_id
      , l_cost_type_id
      , transaction_row.trans_date
      , transaction_row.trans_qty
      , transaction_row.trans_um
      , new_cost.onhand_qty * new_cost.unit_cost
      , -9	-- trans_id
      , new_cost.unit_cost
      , transaction_row.trans_qty
      , NULL
      , NULL
      , NULL
      ,transaction_row.lot_number
      , l_return_status
      );

    ELSE
      create_material_transaction
      ( new_cost.header_id
      , l_cost_type_id /* INVCONV sschinch*/
      , transaction_row.trans_date
      , transaction_row.trans_qty
      , transaction_row.trans_um
      , new_cost.onhand_qty * new_cost.unit_cost - old_cost.onhand_qty * old_cost.unit_cost
      , -9	-- trans_id
      , new_cost.unit_cost
      , new_cost.onhand_qty
      , old_cost.unit_cost
      , old_cost.onhand_qty
      , NULL
      ,transaction_row.lot_number
      , l_return_status
      );
    END IF;
  END IF;
  IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

END process_lot_cost_adjustments;


--********************************************************************************************************
--*    Procedure Name : PROCESS_WIP_BATCH
--*
--*     Description :
--*               Procedure to Process the PROD transaction records, whose current
--*       status is not Completed or Closed. Basically if we complete a batch and then
--*       for example we yield 20LB product. Now we reverted the batch to WIP State
--*       introducing a new -20 LB record. At this point, If we run the Lot Actual Cost Process
--*       we don't cost these two transactions. Rather we copy the previous cost of the Lot if any
--*       or 0$ to both these +20LB and -20LB transaction.
--*
--********************************************************************************************************

PROCEDURE process_wip_batch
IS
   procedure_name VARCHAR2(100);
   x_mtl_analysis_code  varchar2(5) ;   /* B9131983 */
   x_mtl_cmpntcls_id    NUMBER;         /* B9131983 */

BEGIN
  procedure_name := 'Process WIP Batch';
  IF l_debug_level >= l_debug_level_medium THEN
     fnd_file.put_line (fnd_file.log,' Entering process_wip_batch');
   END IF;

   /* B9131983 If cost is ZERO or component is not available
      select the default value from fiscal policy and use it in cost details */
   SELECT mtl_analysis_code, mtl_cmpntcls_id
     INTO x_mtl_analysis_code, x_mtl_cmpntcls_id
     FROM GMF_FISCAL_POLICIES WHERE legal_entity_id = l_le_id ;

  old_cost_tab.delete;

  OPEN  lot_cost_cursor (transaction_row.orgn_id,
                         transaction_row.inventory_item_id,
                         transaction_row.lot_number,
                         transaction_row.trans_date,
                         l_cost_type_id);
  FETCH lot_cost_cursor INTO old_cost;

  IF lot_cost_cursor%FOUND THEN
     IF l_debug_level >= l_debug_level_high THEN
       fnd_file.put_line
       (fnd_file.log,'Reading existing costs for header ID '||old_cost.header_id);
     END IF;

      OPEN  lot_cost_detail_cursor (old_cost.header_id);
      FETCH lot_cost_detail_cursor BULK COLLECT INTO old_cost_tab;
      CLOSE lot_cost_detail_cursor;

     END IF;
     CLOSE lot_cost_cursor;

     IF old_cost_tab.EXISTS(1) THEN
       IF l_debug_level >= l_debug_level_high THEN
         fnd_file.put_line
         (fnd_file.log,'Lot Cost before this transaction is '||to_char(old_cost.unit_cost,'999999999.99'));
       END IF;

       -- At this stage we have all the header and cost component information we need
       -- to store the costs in the database.

       create_cost_header
       ( transaction_row.inventory_item_id
       , transaction_row.lot_number /* INVCONV sschinch */
       , transaction_row.orgn_id    /* INVCONV sschinch */
       , l_cost_type_id             /*INVCONV sschinch */
       , old_cost.unit_cost     -- Carry Forward the Cost
       , transaction_row.trans_date
       , old_cost.onhand_qty + transaction_row.trans_qty
       , transaction_row.doc_id
       , transaction_row.transaction_source_type_id
       ,transaction_row.transaction_action_id
       , new_cost.header_id
       , dummy
       , new_cost.onhand_qty
       , l_return_status
       );

       IF l_return_status ='S' THEN
         FOR k IN 1.. old_cost_tab.count
         LOOP

   --     IF old_cost_tab(k).component_cost <> 0  THEN
          /* B9131983 If cost is ZERO or component is not available
             enter the default row in cost details */
          IF old_cost_tab(k).cost_cmpntcls_id = 0 THEN
             old_cost_tab(k).cost_cmpntcls_id := x_mtl_cmpntcls_id;
          END IF;

           IF NVL(rtrim(ltrim(old_cost_tab(k).cost_analysis_code)),'X') = 'X' THEN
             old_cost_tab(k).cost_analysis_code := x_mtl_analysis_code;
          END IF;

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'WIP:After Replacing component/analysis/level to fiscal policy');
                  fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||old_cost_tab(k).cost_cmpntcls_id);
                  fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||old_cost_tab(k).cost_analysis_code);
                  fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||old_cost_tab(k).cost_level);
                  fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||old_cost_tab(k).component_cost);
                  fnd_file.put_line(fnd_file.log,'====================================');
                END IF;

             create_cost_detail
             ( new_cost.header_id
             , old_cost_tab(k).cost_cmpntcls_id
             , old_cost_tab(k).cost_analysis_code
             , old_cost_tab(k).cost_level
             , old_cost_tab(k).component_cost
             , 0
             , l_return_status
             );

           IF l_return_status <> 'S' THEN
             RETURN;
           END IF;
         -- END IF;       -- B9131983
       END LOOP;

       FOR k IN 1 .. old_cost_tab.COUNT
       LOOP
       -- Write the 'new' costs with a -ve header ID . This is because, there is some cost
       -- before this transaction. So this transaction must have ideally resulted in the change of
       -- cost. So we may need to store the transaction cost under the -header_id
       -- Although this looks like duplicate entry, process_reversals may expect this record.

       -- IF old_cost_tab(k).component_cost <> 0  THEN

          /* B9131983 If cost is ZERO or component is not available
             enter the default row in cost details */
          IF old_cost_tab(k).cost_cmpntcls_id = 0 THEN
             old_cost_tab(k).cost_cmpntcls_id := x_mtl_cmpntcls_id;
          END IF;

           IF NVL(rtrim(ltrim(old_cost_tab(k).cost_analysis_code)),'X') = 'X' THEN
             old_cost_tab(k).cost_analysis_code := x_mtl_analysis_code;
          END IF;

                IF l_debug_level >= l_debug_level_low THEN
                  fnd_file.put_line(fnd_file.log,'WIP:After Replacing component/analysis/level to fiscal policy');
                  fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||old_cost_tab(k).cost_cmpntcls_id);
                  fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||old_cost_tab(k).cost_analysis_code);
                  fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||old_cost_tab(k).cost_level);
                  fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||old_cost_tab(k).component_cost);
                  fnd_file.put_line(fnd_file.log,'====================================');
                END IF;

         create_cost_detail
         ( -new_cost.header_id
         , old_cost_tab(k).cost_cmpntcls_id
         , old_cost_tab(k).cost_analysis_code
         , old_cost_tab(k).cost_level
         , old_cost_tab(k).component_cost
         , 0
         , l_return_status
         );

         IF l_return_status <> 'S' THEN
           RETURN;
         END IF;
       -- END IF;      -- B9131983
     END LOOP;

     create_material_transaction
     ( new_cost.header_id
      , l_cost_type_id     /*INVCONV sschinch */
      , transaction_row.trans_date
      , transaction_row.trans_qty
      , transaction_row.trans_um
      , old_cost.unit_cost  * transaction_row.trans_qty
      , transaction_row.transaction_id
      , old_cost.unit_cost
      ,  new_cost.onhand_qty -- Same as old_cost.onhand_qty+transaction_row.trans_qty
      , old_cost.unit_cost
      , old_cost.onhand_qty
      , 1
      ,transaction_row.lot_number
      , l_return_status
      );

        IF l_return_status <> 'S' THEN
          RETURN;
        END IF;
      ELSE
        RETURN;
      END IF;
    ELSE
      -- No cost currently exists, create one and all associated details
      -- and transactions. Again, this is only for the invoking transaction
      IF   l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line( fnd_file.log,' Previous Cost is NULL');
      END IF;

       create_cost_header
       ( transaction_row.inventory_item_id
       , transaction_row.lot_number  /* INVCONV sschinch */
       , transaction_row.orgn_id     /* INVCONV sschinch */
       , l_cost_type_id             /*INVCONV sschinch */
       , 0     -- No Cost to Carry Forward. So Set to 0$
       , transaction_row.trans_date
       , transaction_row.trans_qty
       , transaction_row.doc_id
       , transaction_row.transaction_source_type_id
       ,transaction_row.transaction_action_id
       , new_cost.header_id
       , dummy
       , new_cost.onhand_qty
       , l_return_status
       );

       IF l_return_status <> 'S' THEN
          RETURN;
       END IF;

        OPEN component_class_cursor
             (l_le_id, transaction_row.inventory_item_id,transaction_row.orgn_id, transaction_row.trans_date);
        FETCH component_class_cursor INTO component_class_id, cost_analysis_code, dummy;
        CLOSE component_class_cursor;

        create_cost_detail
        ( new_cost.header_id
        , component_class_id
        , cost_analysis_code
        , 0
        , 0.00
        , 0
        , l_return_status
        );

       IF l_return_status <> 'S' THEN
          RETURN;
       END IF;

       create_material_transaction
      ( new_cost.header_id
       , l_cost_type_id  /* INVCONV sschinch */
       , transaction_row.trans_date
       , transaction_row.trans_qty
       , transaction_row.trans_um
       , 0 -- Total Cost is also 0$
       , transaction_row.transaction_id
       , 0 -- Carrying Forward 0$
       ,  new_cost.onhand_qty -- Same as old_cost.onhand_qty+transaction_row.trans_qty
       , 0 -- No Old Cost
       , 0  -- No Old Qty
       , NULL
       ,transaction_row.lot_number
       , l_return_status
       );

      IF l_return_status <> 'S' THEN
          RETURN;
       END IF;

    END IF;
    IF l_debug_level >= l_debug_level_medium THEN
      fnd_file.put_line (fnd_file.log,' Leaving process_wip_batch');
     END IF;

END process_wip_batch;


/*=========================================================
  PROCEDURE : perform_weighted_average

  DESCRIPTION  This procedure performs weighted avererage of
               individual lots
  AUTHOR : Sukarna Reddy  INVCONV June 2005
 ==========================================================*/

PROCEDURE perform_weighted_average
( costs_table      IN OUT NOCOPY l_cost_tab_type
 ,trans_qty        IN NUMBER
 ,total_qty        IN NUMBER
 )
IS
  k              NUMBER;
  l              NUMBER;
  divisor        NUMBER;
  l_new_row   NUMBER;
  procedure_name VARCHAR2(100);
BEGIN

  procedure_name := 'Weighted Average';

  IF l_debug_level >= l_debug_level_high THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
    fnd_file.put_line(fnd_file.log,'trans_qty = '||trans_qty);
    fnd_file.put_line(fnd_file.log,'Previous Copy of new_cost_tab is:');

    FOR k IN 1 .. new_cost_tab.COUNT
    LOOP
      fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
      fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
      fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
      fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
      fnd_file.put_line(fnd_file.log,'====================================');
    END LOOP;

    IF costs_table.EXISTS(1) THEN
      fnd_file.put_line(fnd_file.log,'Before Average costs_tab is:');
      FOR k IN 1 .. costs_table.COUNT
      LOOP
        fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||costs_table(k).cost_cmpntcls_id);
        fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||costs_table(k).cost_analysis_code);
        fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||costs_table(k).cost_level);
        fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||costs_table(k).component_cost);
        fnd_file.put_line(fnd_file.log,'====================================');
      END LOOP;
    ELSE
      fnd_file.put_line(fnd_file.log,'No costs to merge');
    END IF;
  END IF;

  IF costs_table.EXISTS(1) THEN

      divisor := total_qty;
      IF divisor = 0 THEN
        divisor := 1;
      END IF;

      fnd_file.put_line(fnd_file.log,'Divisor is  '||divisor);

      FOR k in 1 .. costs_table.COUNT
      LOOP
        costs_table(k).component_cost := costs_table(k).component_cost * trans_qty / divisor;
      END LOOP;

      IF l_debug_level >= l_debug_level_high THEN
        fnd_file.put_line(fnd_file.log,' new_qty = '||trans_qty);

       -- fnd_file.put_line(fnd_file.log,'After averaging new_cost_tab is:');

        fnd_file.put_line(fnd_file.log,'After averaging costs_tab is:');
        FOR k IN 1 .. costs_table.COUNT
        LOOP
          fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||costs_table(k).cost_cmpntcls_id);
          fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||costs_table(k).cost_analysis_code);
          fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||costs_table(k).cost_level);
          fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||costs_table(k).component_cost);
          fnd_file.put_line(fnd_file.log,'====================================');
        END LOOP;
      END IF;

   IF (new_cost_tab.COUNT = 0) THEN
         l_new_row := 1;
         FOR k IN 1..costs_table.COUNT
           LOOP
            new_cost_tab(l_new_row) := SYSTEM.gmf_cost_type(costs_table(k).cost_cmpntcls_id,costs_table(k).cost_analysis_code,costs_table(k).cost_level,costs_table(k).component_cost,0);
            l_new_row := l_new_row + 1;
          END LOOP;
     ELSE
       merge_costs(costs_table,
                      0,
                      0,
                     'C'
                     );
   END IF;

      fnd_file.put_line(fnd_file.log,'After averaging new_cost_tab is:');
      FOR k IN 1 .. new_cost_tab.COUNT
      LOOP
          fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||new_cost_tab(k).cost_cmpntcls_id);
          fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||new_cost_tab(k).cost_analysis_code);
          fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||new_cost_tab(k).cost_level);
          fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||new_cost_tab(k).component_cost);
          fnd_file.put_line(fnd_file.log,'====================================');
      END LOOP;
      END IF;

     IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
END perform_weighted_average;


/*=====================================================================
  PROCEDURE : get_new_cost

  DESCRIPTION This procedure sums up all the component costs by grouping
              component class and analysis code
  AUTHOR : Sukarna Reddy  INVCONV
======================================================================*/

  PROCEDURE get_new_cost (p_cost_tab IN OUT NOCOPY  l_cost_tab_type,
                          x_new_cost_tab OUT NOCOPY l_cost_tab_type,
                          x_total_cost   OUT NOCOPY NUMBER
                          )
  IS
    l_cost_table SYSTEM.gmf_cost_tab := new SYSTEM.gmf_cost_tab();
    CURSOR final_cmpnt_cur IS
     SELECT SYSTEM.gmf_cost_type(nct.cost_cmpntcls_id,
            nct.cost_analysis_code,
            nct.cost_level,
            sum(nct.component_cost),
            nct.burden_ind)
     FROM TABLE ( cast(l_cost_Table AS SYSTEM.gmf_cost_tab) ) nct
     GROUP BY nct.cost_cmpntcls_id,nct.cost_analysis_code,nct.cost_level,nct.burden_ind;

    procedure_name VARCHAR2(100);

  BEGIN
   procedure_name := 'Get New Cost';
  IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
  END IF;

   IF (p_cost_tab.COUNT > 0) THEN
    FOR i IN 1..p_cost_tab.COUNT LOOP
      l_cost_table.extend;
      l_cost_table(i) := SYSTEM.gmf_cost_type(p_cost_tab(i).cost_cmpntcls_id,
                                      p_cost_tab(i).cost_analysis_code,
                                      p_cost_tab(i).cost_level,
                                      p_cost_tab(i).component_cost,
                                      p_cost_tab(i).burden_ind);
    END LOOP;
     OPEN final_cmpnt_cur;
     FETCH final_cmpnt_cur BULK COLLECT INTO x_new_cost_tab;
     CLOSE final_cmpnt_cur;
   END IF;


   SELECT SUM(nct.component_cost)
   INTO x_total_cost
   FROM TABLE ( CAST(l_cost_table AS SYSTEM.gmf_cost_tab) ) nct;

   IF l_debug_level >= l_debug_level_high THEN
     fnd_file.put_line(fnd_file.log,'After weighted average new_cost_tab is:');
     FOR k IN 1 .. new_cost_tab.COUNT
     LOOP
       fnd_file.put_line(fnd_file.log,'CCC/ID['||k||']: '||x_new_cost_tab(k).cost_cmpntcls_id);
       fnd_file.put_line(fnd_file.log,'A/Code['||k||']: '||x_new_cost_tab(k).cost_analysis_code);
       fnd_file.put_line(fnd_file.log,'Level['||k||'] : '||x_new_cost_tab(k).cost_level);
       fnd_file.put_line(fnd_file.log,'C/Cost['||k||']: '||x_new_cost_tab(k).component_cost);
       fnd_file.put_line(fnd_file.log,'====================================');
     END LOOP;
     fnd_file.put_line(fnd_file.log,'After merging, new unit cost is: '||x_total_cost);
   END IF;
   IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
END get_new_cost;

/*=========================================================
  PROCEDURE : Load_lot_costed_items_gt

  DESCRIPTION
    This procedure loads global temporary tables with process
    organizations and lot costed items.
  AUTHOR : Sukarna Reddy  INVCONV June 2005

  HISTORY
    jboppana bug 5241052
      added inventory_asset_flag and process_costing_enabled_flag to the insert query
    ANTHIYAG Bug#5279681
      Modified Query to correct the Query which fetches item codes based on Category
      Codes and also to add delete_mark check for the first query
 ==========================================================*/

 PROCEDURE Load_Lot_Costed_Items_gt(p_le_id        IN NUMBER,
                                   p_orgn_id      IN NUMBER,
                                   p_item_id      IN NUMBER,
                                   p_category_id  IN NUMBER,
                                   x_return_status OUT NOCOPY NUMBER
                                   ) IS
   l_from_orgn_code VARCHAR2(4) := NULL;
   l_row_count NUMBER;
   ll_return_status NUMBER;


   CURSOR get_process_org IS
   SELECT organization_code,
          organization_id
    FROM  gmf_process_organizations_gt
   ORDER BY organization_code;
--    l_le_id NUMBER; B 8687115 already declared global Not used.
   procedure_name VARCHAR2(100);
 BEGIN
   procedure_name := 'load Lot Costed Items GT';
   IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;
   IF (p_le_id IS NOT NULL) THEN
     -- Always load all organizations. There may be transfers across orgs
     /*
     IF (p_orgn_id IS NOT NULL) THEN
       SELECT mp.organization_code
         INTO l_from_orgn_code
         FROM mtl_parameters mp
       WHERE mp.organization_id = p_orgn_id;
     END IF;
     */
--    l_le_id := p_le_id;
 /*   gmf_organizations_pkg.get_process_organizations(p_legal_entity_id => l_le_id
                                                   ,p_From_Orgn_Code => l_from_orgn_code
                                                   ,p_To_Orgn_Code  => l_from_orgn_code
                                                   ,x_Row_Count     => l_row_count
                                                   ,x_Return_Status => ll_return_status
                                                   ); */
    -- B6822310 replace code to load all process orgs.

    Begin
       INSERT
        INTO GMF_PROCESS_ORGANIZATIONS_GT
        (
           organization_id,
           organization_code,
           base_currency_code,
           std_uom,
           legal_entity_id,
           operating_unit_id
        )
       SELECT  mp.organization_id, mp.organization_code, gfp.base_currency_code,
               NULL,  gfp.legal_entity_id, ood.operating_unit
        FROM  mtl_parameters mp,
                gmf_fiscal_policies gfp,
                org_organization_definitions ood
       WHERE  mp.process_enabled_flag = 'Y'
         AND  gfp.legal_entity_id = ood.legal_entity
         AND  mp.organization_id = ood.organization_id;
       l_Row_Count := sql%rowcount;

       IF l_Row_Count = 0 THEN
         ll_return_status := -1; --No Rows returned by the API
       END IF;

       UPDATE gmf_process_organizations_gt gpo
          SET std_uom = (SELECT u.uom_code
                      FROM mtl_units_of_measure u,
                           gmd_parameters_hdr h,
                           gmd_parameters_dtl d
                    WHERE u.base_uom_flag = 'Y'
                    AND gpo.organization_id = h.organization_id
                    AND h.parameter_id = d.parameter_id
                    AND d.parameter_name = 'FM_YIELD_TYPE'
                    AND d.parameter_value = u.uom_class)
      WHERE gpo.std_uom IS NULL;

      UPDATE gmf_process_organizations_gt gpo
         SET std_uom = (SELECT u.uom_code
                      FROM mtl_units_of_measure u,
                           gmd_parameters_hdr h,
                           gmd_parameters_dtl d
                    WHERE u.base_uom_flag = 'Y'
                    AND  h.organization_id IS NULL
                    AND h.parameter_id = d.parameter_id
                    AND d.parameter_name = 'FM_YIELD_TYPE'
                    AND d.parameter_value = u.uom_class)
      WHERE gpo.std_uom IS NULL;

      ll_return_status := 0;

     EXCEPTION
      WHEN OTHERS THEN
      ll_return_status := -1;

     END ;


   -- B 6822310 replaced commented code as above.

    IF (ll_return_status <> 0) THEN
      x_return_status := ll_return_status;
      RETURN;
    END IF;
    /* Build index for organization id */
    FOR cur_rec IN get_process_org LOOP
      l_org_tab(cur_rec.organization_id) := cur_rec.organization_code;
    END LOOP;

   INSERT
      INTO GMF_LOT_COSTED_ITEMS_GT
      (
          organization_id,
          inventory_item_id,
          primary_uom_code
      )
      SELECT
           msi.organization_id,
           msi.inventory_item_id,
           msi.primary_uom_code
      FROM gmf_lot_costed_items lci,
           mtl_system_items_b msi,
           gmf_process_organizations_gt gpo
      WHERE lci.legal_entity_id = l_le_id
        AND lci.delete_mark = 0 /* ANTHIYAG Bug#5279681 06-Jun-2006 */
        AND gpo.organization_id = msi.organization_id
        AND msi.lot_control_code = 2
        AND lci.inventory_item_id = msi.inventory_item_id
        AND msi.inventory_asset_flag = 'Y'
        AND msi.process_costing_enabled_flag = 'Y'
        AND lci.inventory_item_id = NVL(p_item_id,lci.inventory_item_id)
        AND lci.cost_type_id = l_cost_type_id
        AND
         (
           (
              p_item_id IS NULL
              AND p_category_id IS NULL
           )
          OR
          (
              p_item_id IS NOT NULL
          )
         )
    UNION
      SELECT
        mic.organization_id,    /*ANTHIYAG Bug#5279681 06-Jun-2006 */
        mic.inventory_item_id,  /*ANTHIYAG Bug#5279681 06-Jun-2006 */
        i.primary_uom_code
      FROM mtl_item_categories mic,
           gmf_lot_costed_items g,
           mtl_system_items_b i,
           gmf_process_organizations_gt gpo
     WHERE g.cost_category_id = mic.category_id
          AND g.legal_entity_id = l_le_id
          AND g.delete_mark = 0
          AND i.lot_control_code = 2
          AND gpo.organization_id = i.organization_id
          AND i.organization_id = mic.organization_id
          AND mic.inventory_item_id = i.inventory_item_id
          AND i.inventory_asset_flag = 'Y'
          AND i.process_costing_enabled_flag = 'Y'
          AND g.cost_type_id = l_cost_type_id
          AND g.cost_category_id = NVL(p_category_id,g.cost_category_id)
          AND
           (
            (
               p_item_id IS NULL
               AND p_category_id IS NULL
            )
            OR
            (
               p_category_id IS NOT NULL
            )
           )
       UNION   /* Bug 8730374 added this union to load one item if assigned by cost category */
       SELECT
        mic.organization_id,    /*ANTHIYAG Bug#5279681 06-Jun-2006 */
        mic.inventory_item_id,  /*ANTHIYAG Bug#5279681 06-Jun-2006 */
        i.primary_uom_code
       FROM mtl_item_categories mic,
           gmf_lot_costed_items g,
           mtl_system_items_b i,
           gmf_process_organizations_gt gpo
     WHERE g.cost_category_id = mic.category_id
          AND g.legal_entity_id = l_le_id
          AND g.delete_mark = 0
          AND i.lot_control_code = 2
          AND gpo.organization_id = i.organization_id
          AND i.organization_id = mic.organization_id
          AND mic.inventory_item_id = i.inventory_item_id
          AND i.inventory_asset_flag = 'Y'
          AND i.process_costing_enabled_flag = 'Y'
          AND g.cost_type_id = l_cost_type_id
	  AND mic.inventory_item_id = p_item_id;

   END IF;
    x_return_status := 0;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
      x_return_status := -1;
END Load_Lot_Costed_Items_gt;

  /*=========================================================
    PROCEDURE : Process_lot_split

    DESCRIPTION
      This procedure process lot split transactions.
    AUTHOR : Sukarna Reddy  INVCONV
   ==========================================================*/

  PROCEDURE process_lot_split IS
    l_old_cost gmf_lot_costs%ROWTYPE;
    l_old_cost_tab l_cost_tab_type;
    l_parent_lot_number VARCHAR2(80);
    i NUMBER;
    l_new_cost  NUMBER;
    procedure_name VARCHAR2(100);
  BEGIN
   procedure_name := 'Process Lot Split';
   IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;

    IF (transaction_row.transaction_id = transaction_row.transfer_transaction_id)
    THEN    /* This is a parent lot from which split happened */
    -- Check if cost for this Lot exist
      IF old_cost_tab.EXISTS(1) THEN
        process_adjustment;
      ELSE
        process_creation;
      END IF;
    ELSE  /* This is a new lot created from the parent lot */
      --check if there is cost from parent lot At this point
      SELECT  mln.lot_number
        INTO  l_parent_lot_number
        FROM  mtl_transaction_lot_numbers mln,
              mtl_material_transactions mmt
       WHERE  mmt.transaction_id = transaction_row.transfer_transaction_id
            AND mmt.transaction_id = mln.transaction_id;

       OPEN lot_cost_cursor(transaction_row.orgn_id,
                            transaction_row.inventory_item_id,
                            l_parent_lot_number,
                            transaction_row.trans_date,
                            l_cost_type_id);
       FETCH lot_cost_cursor INTO l_old_cost;

       IF lot_cost_cursor%FOUND THEN
         IF   l_debug_level >= l_debug_level_high THEN
            fnd_file.put_line
            (fnd_file.log,'Reading existing costs for header ID '||l_old_cost.header_id);
         END IF;

         OPEN  lot_cost_detail_cursor (l_old_cost.header_id);
         FETCH lot_cost_detail_cursor BULK COLLECT INTO l_old_cost_tab;
         CLOSE lot_cost_detail_cursor;

         IF (l_old_cost_tab.EXISTS(1)) THEN
           merge_costs(l_old_cost_tab,
                       old_cost.onhand_qty,
                       transaction_row.trans_qty,
                       'C'
                      );
            merge_costs(old_cost_tab,
                        transaction_row.trans_qty, /* ANTHIYAG Bug#5412410 26-Jul-2006 */
                        old_cost.onhand_qty, /* ANTHIYAG Bug#5412410 26-Jul-2006 */
                       'A'
                       );
          END IF;
          CLOSE lot_cost_cursor;
       ELSE
         CLOSE lot_cost_cursor;
         -- if we are here that means there is no incomming cost from the parent lot
         -- check if current child lot has prior cost
         IF (old_cost_tab.EXISTS(1)) THEN
           merge_costs(old_cost_tab,
                       transaction_row.trans_qty, /* ANTHIYAG Bug#5412410 26-Jul-2006 */
                       old_cost.onhand_qty, /* ANTHIYAG Bug#5412410 26-Jul-2006 */
                       'A'
                      );
         ELSE
           -- If we are hear then this is a new transaction
           process_creation;
           RETURN;
         END IF;
       END IF;
        --
       IF (new_cost_tab.EXISTS(1)) THEN   -- jboppana
         l_new_cost := new_cost.unit_cost;
         create_cost_header
          (p_item_id               => transaction_row.inventory_item_id
           ,p_lot_number           => transaction_row.lot_number
           ,p_orgn_id              => transaction_row.orgn_id
           ,p_cost_type_id         => l_cost_type_id
           ,p_unit_cost            => l_new_cost
           ,p_cost_date            => transaction_row.trans_date
           ,p_onhand_qty           => transaction_row.trans_qty + NVL(old_cost.onhand_qty,0) /* ANTHIYAG Bug#5412410 26-Jul-2006 */
           ,p_trx_src_type_id      => transaction_row.transaction_source_type_id
           ,p_txn_act_id           => transaction_row.transaction_action_id
           ,p_doc_id               => transaction_row.doc_id
           ,x_header_id            => new_cost.header_id
           ,x_unit_cost            => new_cost.unit_cost
           ,x_onhand_qty           => new_cost.onhand_qty
           ,x_return_status        => l_return_status
          );

          FOR i IN 1..new_cost_tab.COUNT
          LOOP
            create_cost_detail
                 ( new_cost.header_id
                  ,new_cost_tab(i).cost_cmpntcls_id
                  , new_cost_tab(i).cost_analysis_code
                  ,0
                  , new_cost_tab(i).component_cost
                  ,0
                  , l_return_status
                 );
          END LOOP;
          IF l_return_status = 'S' THEN
             create_material_transaction
            ( new_cost.header_id
             ,l_cost_type_id
             ,transaction_row.trans_date
              ,transaction_row.trans_qty
              ,transaction_row.trans_um
              ,transaction_row.trans_qty * nvl(new_cost.unit_cost,0) /* ANTHIYAG Bug#5412410 26-Jul-2006 */
              ,transaction_row.transaction_id
              ,nvl(new_cost.unit_cost,0) /* ANTHIYAG Bug#5412410 26-Jul-2006 */
              ,transaction_row.trans_qty
              ,NULL
              ,NULL
              ,NULL
              ,transaction_row.lot_number
              , l_return_status
             );
          END IF;
        END IF;
      END IF;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
  END process_lot_split;

  /* INVCONV sschinch New procedure*/

  /*=========================================================
    PROCEDURE : Process_lot_merge
    DESCRIPTION
      This procedure processes lot merge transactions for costing.
    AUTHOR : Sukarna Reddy Jun 2005 INVCONV
   ==========================================================*/

  PROCEDURE process_lot_merge IS

  CURSOR child_lots_cursor IS
  SELECT mtln.lot_number,
         ABS(mtln.primary_quantity),
         mtln.transaction_date
    FROM mtl_transaction_lot_numbers mtln, mtl_material_transactions mmt
   WHERE mmt.transfer_transaction_id = transaction_row.transfer_transaction_id
        AND  mmt.transaction_id <> transaction_row.transfer_transaction_id
        AND  mmt.transaction_id = mtln.transaction_id  ;


  l_unit_cost  NUMBER;
  l_total_cost NUMBER;
  l_cost_tab   l_cost_tab_type;
  l_old_cost   gmf_lot_costs%rowtype;
  l_new_cost_tab l_cost_tab_type;
  procedure_name VARCHAR2(100);



  BEGIN
    procedure_name := 'Process Merged Lot';
   IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;

    IF (transaction_row.transaction_id = transaction_row.transfer_transaction_id)
    THEN
      -- This is a merged lot and there may be or may not be any prior cost for this lot
      -- Get the cost from child lots which are the sources of costs for this transaction
      -- and perform weighted average. We need to get the child lots first.
        OPEN child_lots_cursor;
        FETCH child_lots_cursor INTO child_lot_row;
        WHILE child_lots_cursor%FOUND
        LOOP
         OPEN lot_cost_cursor(transaction_row.orgn_id,
                              transaction_row.inventory_item_id,
                              child_lot_row.lot_number,
                              child_lot_row.trans_date,
                              l_cost_type_id);
         FETCH lot_cost_cursor INTO l_old_cost;

         OPEN  lot_cost_detail_cursor ( l_old_cost.header_id );
         FETCH lot_cost_detail_cursor BULK COLLECT INTO l_cost_tab;
         CLOSE lot_cost_detail_cursor;

         IF (l_cost_tab.EXISTS(1)) THEN
           perform_weighted_average(l_cost_tab,
                                    child_lot_row.trans_qty,
                                    transaction_row.trans_qty
                                    );
         ELSE
            fnd_file.put_line
                (fnd_File.LOG,'PROCEDURE Process_Lot_Merge '||'Warning : Child Lot :'||child_lot_row.lot_number||' has no cost will be using 0 cost ');
         END IF;

         CLOSE lot_cost_cursor;
         FETCH child_lots_cursor INTO child_lot_row;
       END LOOP;
       CLOSE child_lots_cursor;

       IF (old_cost_tab.EXISTS(1)) THEN
          perform_weighted_average(old_cost_tab,
                                   old_cost.onhand_qty,
                                   transaction_row.trans_qty
                                   );
          merge_costs(old_cost_tab,
                      0,
                      0,
                     'C'
                     );
      END IF;

       get_new_cost(p_cost_tab => new_cost_tab,
                    x_new_cost_tab => l_new_cost_tab,
                    x_total_cost   => l_unit_cost
                   );
       new_cost_tab := l_new_cost_tab;
       lot_unit_cost := l_unit_cost;

      IF (new_cost_tab.EXISTS(1)) THEN
        create_cost_header
          ( transaction_row.inventory_item_id
          , transaction_row.lot_number
          , transaction_row.orgn_id
          , l_cost_type_id
          , lot_unit_cost
          , transaction_row.trans_date
          , transaction_row.trans_qty
          , transaction_row.doc_id
          ,transaction_row.transaction_source_type_id
          ,transaction_row.transaction_action_id
          , new_cost.header_id
          , new_cost.unit_cost
          , new_cost.onhand_qty
          , l_return_status
         );

      IF l_return_status = 'S' THEN

        FOR i in 1 .. new_cost_tab.COUNT
        LOOP
          create_cost_detail
          ( new_cost.header_id
          , new_cost_tab(i).cost_cmpntcls_id
          , new_cost_tab(i).cost_analysis_code
          , 0
          , new_cost_tab(i).component_cost
          , 0
          , l_return_status
          );

          IF l_return_status <> 'S' THEN
            RETURN;
          END IF;
        END LOOP;

        create_material_transaction
            ( new_cost.header_id
            , l_cost_type_id
            , transaction_row.trans_date
            , transaction_row.trans_qty
            , transaction_row.trans_um
            , new_cost.onhand_qty * new_cost.unit_cost
            , transaction_row.transaction_id
            , new_cost.unit_cost
            , new_cost.onhand_qty
            , NULL
            , NULL
            , NULL
            ,transaction_row.lot_number
            , l_return_status
            );
      END IF; /* l_return_status = 'S' */
     END IF;
    ELSE
      -- This is a child lot and consumed lot. Consider this as an adjustment.
      process_adjustment;
    END IF;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
END process_lot_merge;
  /*=========================================================
    PROCEDURE : Process_lot_translate
    DESCRIPTION
      This procedure processes lot translate transaction.
    AUTHOR : Sukarna Reddy june 2005
   ==========================================================*/


  PROCEDURE process_lot_translate IS
    l_old_cost  gmf_lot_costs%rowtype;
    l_cost_tab  l_cost_tab_type;
    l_lot_number  VARCHAR2(80);
    l_trans_date  DATE;
    i PLS_INTEGER;
    l_new_cost NUMBER;
    procedure_name VARCHAR2(100);
  BEGIN
    procedure_name := 'Process Lot Translate';
   IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;

    IF (transaction_row.transaction_id = transaction_row.transfer_transaction_id) THEN
      process_adjustment;
    ELSE
      SELECT    lot_number,
                transaction_date
               INTO l_lot_number,
                    l_trans_date
      FROM   mtl_transaction_lot_numbers
      WHERE transaction_id = transaction_row.transfer_transaction_id;

      IF (old_cost_tab.EXISTS(1)) THEN
        merge_costs(old_cost_tab,
              old_cost.onhand_qty,
              transaction_row.trans_qty,
              'C'
             );
      END IF;

       -- Get the parent lot info to retrive cost

      OPEN lot_cost_cursor(transaction_row.orgn_id,
                           transaction_row.inventory_item_id,
                           l_lot_number,
                           l_trans_date,
                           l_cost_type_id);
      FETCH lot_cost_cursor INTO l_old_cost;
      CLOSE lot_cost_cursor;
      IF (l_old_cost.header_id > 0) THEN
        OPEN  lot_cost_detail_cursor ( l_old_cost.header_id);
        FETCH lot_cost_detail_cursor BULK COLLECT INTO l_cost_tab;
        CLOSE lot_cost_detail_cursor;
      END IF;

      IF (l_cost_tab.EXISTS(1)) THEN
        IF (old_cost_tab.EXISTS(1)) THEN
          merge_costs(l_cost_tab,
                transaction_row.trans_qty, /* ANTHIYAG Bug#5412410 26-Jul-2006 */
                old_cost.onhand_qty, /* ANTHIYAG Bug#5412410 26-Jul-2006 */
               'A'
               );
        ELSE
          merge_costs(l_cost_tab,
                transaction_row.trans_qty,
                0,
               'A'
               );
        END IF;
      ELSE
        IF (NOT new_cost_tab.EXISTS(1)) THEN
          -- There is not cost for this lot
          --Treat this as creation of inventory
          process_creation;
          RETURN;
        END IF;
      END IF;

      l_new_cost := new_cost.unit_cost;

      IF (new_cost_tab.EXISTS(1)) THEN
        create_cost_header
          ( transaction_row.inventory_item_id
          , transaction_row.lot_number
          , transaction_row.orgn_id
          , l_cost_type_id
          , l_new_cost
          , transaction_row.trans_date
          , transaction_row.trans_qty + NVL(old_cost.onhand_qty,0)
          , transaction_row.doc_id
          ,transaction_row.transaction_source_type_id
          ,transaction_row.transaction_action_id
          , new_cost.header_id
          , new_cost.unit_cost
          , new_cost.onhand_qty
          , l_return_status
         );

       IF (l_return_status = 'S') THEN
         FOR i in 1 .. new_cost_tab.COUNT
         LOOP
           create_cost_detail
               ( new_cost.header_id
               , new_cost_tab(i).cost_cmpntcls_id
               , new_cost_tab(i).cost_analysis_code
               , 0
               , new_cost_tab(i).component_cost
               , 0
               , l_return_status
              );

           IF l_return_status <> 'S'
           THEN
                RETURN;
           END IF;
           create_material_transaction
              ( new_cost.header_id
              , l_cost_type_id
              , transaction_row.trans_date
              , transaction_row.trans_qty
              , transaction_row.trans_um
              , new_cost.onhand_qty * new_cost.unit_cost
              , transaction_row.transaction_id
              , new_cost.unit_cost
              , new_cost.onhand_qty
              , NULL
              , NULL
              , NULL
              ,transaction_row.lot_number
              , l_return_status
              );
        END LOOP;
      END IF;
    END IF;
    END IF;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
END process_lot_translate;


  /*=========================================================
  PROCEDURE : process_consigned_inventory

  DESCRIPTION
    This procedure will process consigned inventory transactions
  AUTHOR : Sukarna Reddy  INVCONV June 2005
 ==========================================================*/

 PROCEDURE process_consigned_inventory IS
   l_ccc_id NUMBER;
   l_a_code VARCHAR2(4);
   l_new_cost   NUMBER;
   procedure_name VARCHAR2(100);
 BEGIN
     procedure_name := 'Process Consigned Inventory';
     IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
     END IF;

     OPEN component_class_cursor
    ( l_le_id
     ,transaction_row.inventory_item_id
     ,transaction_row.orgn_id
     ,transaction_row.trans_date
    );
    FETCH component_class_cursor INTO l_ccc_id,l_a_code,dummy;
    CLOSE component_class_cursor;

     IF (l_ccc_id IS NOT NULL) THEN
       new_cost_tab(1):= SYSTEM.gmf_cost_type(l_ccc_id,l_a_code,0,transaction_row.transaction_cost,0);
       new_cost.unit_cost := transaction_row.transaction_cost;
     ELSE
       RETURN;
     END IF;

     IF (old_cost_tab.EXISTS(1)) THEN
       merge_costs(old_cost_tab,
                   old_cost.onhand_qty,
                   transaction_row.trans_qty,
                   'A'
                   );
     END IF;
     IF (new_cost_tab.EXISTS(1)) THEN
       l_new_cost := new_cost.unit_cost;
        create_cost_header
          ( transaction_row.inventory_item_id
          , transaction_row.lot_number
          , transaction_row.orgn_id
          , l_cost_type_id
          , l_new_cost
          , transaction_row.trans_date
          , transaction_row.trans_qty + NVL(old_cost.onhand_qty,0)
          , transaction_row.doc_id
          ,transaction_row.transaction_source_type_id
          ,transaction_row.transaction_action_id
          , new_cost.header_id
          , new_cost.unit_cost
          , new_cost.onhand_qty
          , l_return_status
         );

       IF (l_return_status = 'S') THEN
         FOR i in 1 .. new_cost_tab.COUNT
         LOOP
           create_cost_detail
               ( new_cost.header_id
               , new_cost_tab(i).cost_cmpntcls_id
               , new_cost_tab(i).cost_analysis_code
               , 0
               , new_cost_tab(i).component_cost
               , 0
               , l_return_status
              );

           IF l_return_status <> 'S' THEN
                RETURN;
           END IF;
           create_material_transaction
              ( new_cost.header_id
              , l_cost_type_id
              , transaction_row.trans_date
              , transaction_row.trans_qty
              , transaction_row.trans_um
              , new_cost.onhand_qty * new_cost.unit_cost
              , transaction_row.transaction_id
              , new_cost.unit_cost
              , new_cost.onhand_qty
              , NULL
              , NULL
              , NULL
              ,transaction_row.lot_number
              , l_return_status
              );
        END LOOP;
      END IF;
    END IF;

     IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line
       (fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
END process_consigned_inventory;

 /*=========================================================
  PROCEDURE : process_pdtxf_cost

  DESCRIPTION
    This procedure will process process discrete transfers
  AUTHOR : Sukarna Reddy  INVCONV June 2005
 ==========================================================*/

  PROCEDURE process_pdtxf_cost IS
    l_cost_tab l_cost_tab_type;
    x_total_cost NUMBER;
    l_new_cost NUMBER;
    l_trp_cost NUMBER;
    l_txf_price NUMBER;
    l_ccc_id NUMBER;
    l_a_code VARCHAR2(4);
    l_trans_id NUMBER;
    l_header_id NUMBER;

    l_cmpntcls_id NUMBER;
    l_cost_analysis_code VARCHAR2(4);
    l_cost_level         NUMBER(1);
    l_component_cost     NUMBER;
    l_burden_ind         NUMBER(1);
    procedure_name VARCHAR2(100);

    CURSOR cur_get_default_cmpt(p_le_id NUMBER,
                                p_trp_cost  NUMBER) IS
            SELECT default_ovh_cmpntcls_id,
                                default_ovh_analysis_code,
                                0,
                                p_trp_cost,
                                1
                           FROM  gmf_fiscal_policies
            WHERE legal_entity_id = p_le_id  ;
  BEGIN

    procedure_name := 'process_pdtxf_cost';
   IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;

    OPEN  component_class_cursor(l_le_id,
                                 transaction_row.inventory_item_id,
                                 transaction_row.orgn_id,
                                 transaction_row.trans_date);
    FETCH component_class_cursor INTO l_ccc_id,l_a_code,dummy;
    CLOSE component_class_cursor;

    IF(transaction_row.trans_qty <> 0) THEN
       l_new_cost := transaction_row.transfer_price;
       l_trp_cost := transaction_row.transportation_cost/transaction_row.trans_qty;
    ELSE
       fnd_file.put_line
               (fnd_file.log,'ERROR Procedure : '||procedure_name||' Transaction qty is zero.Cannot proceed');
       l_return_status := 'E';
        RETURN;
     END IF;

    IF (old_cost_tab.EXISTS(1)) THEN
      IF (l_ccc_id IS NOT NULL) THEN
        l_cost_tab(1) := SYSTEM.gmf_cost_type(l_ccc_id,l_a_code,0,l_new_cost,0);
      ELSE
        l_return_status := 'E';
        -- PK added this message as above
        fnd_file.put_line
          (fnd_file.log,'ERROR Procedure : '||procedure_name||' l_ccc_id has value NULL. Cannot proceed');

        RETURN;
      END IF;

    IF( l_trp_cost <> 0) AND nvl(transaction_row.fob_point,-1) = 1 THEN /* ANTHIYAG Bug#5550911 21-Sep-2006 */
       OPEN cur_get_default_cmpt(l_le_id, l_trp_cost);
       FETCH cur_get_default_cmpt  INTO l_cmpntcls_id,l_cost_analysis_code,l_cost_level,l_component_cost,l_burden_ind;
       CLOSE cur_get_default_cmpt;

       IF(l_cmpntcls_id IS NULL OR l_cost_analysis_code IS NULL) THEN
           fnd_file.put_line (fnd_file.log,'Procedure : '||procedure_name||' Overhead default component/analysis code in fiscal policies table is not defined. Ignoring the transportation cost');
       ELSE
          l_cost_tab(2) := SYSTEM.gmf_cost_type(l_cmpntcls_id,l_cost_analysis_code,l_cost_level,l_component_cost,l_burden_ind);
       END IF;
    END IF;

      l_onhand_qty := old_cost.onhand_qty + transaction_row.trans_qty;

      merge_costs(l_cost_tab,
                  0,
                  0,
                 'C'
                 );

      merge_costs(old_cost_tab,
                  old_cost.onhand_qty,
                  transaction_row.trans_qty,
                  'A'
                 );
      l_new_cost := new_cost.unit_cost;
    ELSE
      -- This is a new lot with new cost in the target organization
      IF (l_ccc_id IS NOT NULL) THEN
        l_onhand_qty := transaction_row.trans_qty;
        new_cost_tab(1) := SYSTEM.gmf_cost_type(l_ccc_id,l_a_code,0,l_new_cost,0);
      ELSE
        l_return_status := 'E';
        fnd_file.put_line
          (fnd_file.log,'ERROR Procedure : '||procedure_name||' loc2 l_ccc_id has value NULL. Cannot proceed');
        RETURN;
      END IF;
    END IF;



    create_cost_header
            ( transaction_row.inventory_item_id
            , transaction_row.lot_number
            , transaction_row.orgn_id
            , l_cost_type_id
            , l_new_cost
            , transaction_row.trans_date
            , l_onhand_qty
            , transaction_row.doc_id
            , transaction_row.transaction_source_type_id
            , transaction_row.transaction_action_id
            , new_cost.header_id
            , new_cost.unit_cost
            , new_cost.onhand_qty
            , l_return_status
            );
    IF (l_return_status = 'S') THEN
      FOR i IN 1..new_cost_tab.COUNT
      LOOP
        create_cost_detail
                   ( new_cost.header_id
                   , new_cost_tab(i).cost_cmpntcls_id
                   , new_cost_tab(i).cost_analysis_code
                   , 0
                   , new_cost_tab(i).component_cost
                   , 0
                   , l_return_status
                   );
        IF l_return_status <> 'S'
        THEN
          RETURN;
        END IF;
      END LOOP;

      -- create data with original transaction cost.

      FOR i IN 1..l_cost_tab.COUNT
      LOOP
        create_cost_detail
                   ( -new_cost.header_id
                    , l_cost_tab(i).cost_cmpntcls_id
                    , l_cost_tab(i).cost_analysis_code
                    , 0
                    , l_cost_tab(i).component_cost
                    , l_cost_tab(i).burden_ind
                    , l_return_status
                   );
        IF l_return_status <> 'S'
        THEN
          RETURN;
        END IF;
      END LOOP;

      IF l_debug_level >= l_debug_level_medium
      THEN
        fnd_file.put_line
               (fnd_file.log,'Procedure : '||procedure_name||' Creating cost transaction');
      END IF;

      create_material_transaction
              ( new_cost.header_id
               ,l_cost_type_id
               ,transaction_row.trans_date
               ,transaction_row.trans_qty
               ,transaction_row.trans_um
               ,new_cost.onhand_qty * new_cost.unit_cost
               ,transaction_row.transaction_id
               ,new_cost.unit_cost
               ,new_cost.onhand_qty  /* ANTHIYAG Bug#5550911 21-Sep-2006 */
               ,old_cost.unit_cost--  NULL                        --jboppana
               ,old_cost.onhand_qty             --NULL jboppana
               ,1
               ,transaction_row.lot_number
               ,l_return_status
              );
    END IF;
    IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
END process_pdtxf_cost;



/* Process process discrete transfers */

/*=========================================================
  PROCEDURE : process_pd_transfers

  DESCRIPTION
    This procedure will process - discrete to process transfers
  AUTHOR : Sukarna Reddy  INVCONV June 2005
 ==========================================================*/

   PROCEDURE process_pd_transfer IS
     l_header_id NUMBER;
     l_trans_id NUMBER;
     procedure_name VARCHAR2(100);
   BEGIN
   procedure_name := 'Process Pd Transfer';
   IF l_debug_level >= l_debug_level_medium THEN
    fnd_file.put_line(fnd_file.log,'Entered Procedure: '||procedure_name);
   END IF;

     IF new_cost_tab.EXISTS(1) THEN
       new_cost_tab.delete;
     END IF;

     IF (( transaction_row.fob_point = FOB_SHIPPING AND
            transaction_row.transaction_action_id  = LOGICAL_INTRANSIT_RECEIPT
           )
           OR
          (transaction_row.fob_point = FOB_RECEIVING AND
             transaction_row.transaction_action_id  = INTRANSIT_RECEIPT
             )
           OR
           (
             transaction_row.transaction_action_id = DIRECT_ORG_TRANSFER
           )
         )
     THEN
       process_pdtxf_cost;
     ELSIF (transaction_row.fob_point = FOB_SHIPPING AND /*jboppana changed source_type_id to fob_point*/
            transaction_row.transaction_action_id = INTRANSIT_RECEIPT
           )
     THEN
       -- This transaction is a physical receipt and should not be costed since there is a
       -- Logical intransit receipt which was created earlier and costed. We need to point the cost to previous
       -- logical intransit receipt.

       SELECT transaction_id
         INTO l_trans_id
         FROM  mtl_material_transactions
        WHERE  transfer_transaction_id = transaction_row.transfer_transaction_id
         AND transaction_action_id = 15;

       SELECT cost_header_id
          INTO l_header_id
          FROM gmf_material_lot_cost_txns gmlc
         WHERE  transaction_id = l_trans_id
           AND lot_number = transaction_row.lot_number
           AND cost_type_id = l_cost_type_id;

       SELECT * INTO new_cost
          FROM  gmf_lot_costs
         WHERE header_id = l_header_id;

       create_material_transaction
         ( p_header_id      => l_header_id
          ,p_cost_type_id   => l_cost_type_id
          ,p_trans_date     => transaction_row.trans_date
          ,p_trans_qty      => transaction_row.trans_qty
          ,p_trans_um       => transaction_row.trans_um
          ,p_total_cost     => transaction_row.trans_qty * new_cost.unit_cost
          ,p_trans_id       => transaction_row.transaction_id
          ,p_unit_cost      => new_cost.unit_cost
          ,p_onhand_qty     => old_cost.onhand_qty
          ,p_old_unit_cost  => NULL
          ,p_old_onhand_qty => NULL
          ,p_new_cost_ind   => 1
          ,p_lot_number     => transaction_row.lot_number
          ,x_return_status  => l_return_status
         );
     END IF;
      IF l_debug_level >= l_debug_level_medium THEN
       fnd_file.put_line(fnd_file.log,'Leaving Procedure: '||procedure_name);
     END IF;
EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
    l_return_status := 'E';
END process_pd_transfer;


--*************************************************************************************
--*                                                                                   *
--* This is the main procedure for the rollup, and is the only one that can be called *
--* globally. It is written as a concurrent request.                                  *
--*                                                                                   *
--* The mandatory parameters are:                                                     *
--*                                                                                   *
--* p_co_code               This is used to locate costs for items that are not       *
--*                         costed by lot and also to locate resource costs           *
--*                                                                                   *
--* p_cost_method_code      This is also used to locate item and resource costs       *
--*                                                                                   *
--* p_user                  This is used to tag any rows inserted or updated with     *
--*                         the identity of the user (obsoleted)                      *
--*                                                                                   *
--* The optional parameters are:                                                      *
--*                                                                                   *
--* p_item_no               If specified, only this item's uncosted lots will be      *
--*                         costed                                                    *
--*                                                                                   *
--* p_lot_no                If specified, only this the lot number belonging to the   *
--*                         item specified will be costed. Note: This does not imply  *
--*                         that a range of lots sharing this lot_no will be costed.  *
--*                         If the lot_no exists for the item only that lot will be   *
--*                         processed.                                                *
--*                                                                                   *
--* p_sublot_no             If specified only the lot identified by the concatenation *
--*                         of p_item_no/p_lot_no/p_sublot_no will be costed          *
--*                                                                                   *
--* p_final_run_flag        Indicates this is a final or trial run.                   *
--*                         Valid values are Y and N.                                 *
--*                 								      *
--* HISTORY                                                                           *
--*   19-Aug-2004 Dinesh Vadivel Bug# 3831782                                         *
--*        Added where clause in the queries to ignore the Lot Cost Adjustment Records*
--*        which has no Detail Records(i.e., NULL Adjustment Cost)                    *
--*
--*    26-Nov-2004 Uday Moogala Bug# 4004338
--*       Added Reverse_id in the select clause of INV_TRAN_CURSOR.
--*       Also added new DECODE(...) order by clause in the INV_TRAN_CURSOR.
--*
--*   27-Nov-2004 Dinesh Vadivel Bug# 4004338
--*      Modified the if condition to set the lot_costed_ind if it is final_run to the
--*      reversal records of the product..
--*      Eg : If we records as 100, -100 and 150 then during Final run we are setting
--*              lot_costed_ind to 1 only for the rows 100 and 150.
--*              So modified the code here to set for the -100 transaction record also.
--*
--*   30-Jan-2005 Dinesh Vadivel Bug# 4152397
--*      Uncommented the code which fetches lot_id into l_lot_id for the lot_no
--*      entered on Lot ACP screen.
--*      Also, the inv_tran_cursor inside "ELSIF l_item_id IS NOT NULL .... "
--*      we have filter only those LADJ transactions for that particular Lot_id if any.
--*
--*  24-Feb-2005 Dinesh Vadivel Bug# 4177349
--*      When a batch is reversed to WIP, the Lot Cost process fails at process_reversals
--*      So added check to verify the batch status before calling process_reversals
--*
--*   24-Feb-2005 Dinesh Vadivel Bug# 4187891
--*      Cancellation of Inv Xfer has been modified such that it is considered
--*      as if it is an actual transfer where the source and destination organizations are the same.
--*
--*   24-Feb-2005 Dinesh Vadivel Bug# 4176690
--*       Added a new Date field in the Lot Cost Process Submission Screen.
--*       Lot Cost Process will consider only those transactions upto this date
--*
--*   11-Aug-2006 Anand Thiyagarajan Bug#5460458
--*       Modified code to ignore the PO receipt transactions for consigned items unless received
--*       by Transfer to Regular Options. Also Modified Code to consider the Consigned inventory transactions
--*   18-dec-2006 bug 5705311, Modified the select query to fetch category_id for the cost class, pmarada
--*   30-Jun-2008 Bug 7215069
--*      Change ordering for Receipt transactions. If transactions exist for multiple
--*      document types with same transaction date then first process the receipt transactions.
--*	21-May-2009 Bug 7249505
--*	HALUTHRA BUG 7249505 In case of return to vendor process the transaction as an adjustment
--*     27-May-2009 Bug 5473138/8533290
--*	HALUTHRA Bug 5473138/8533290 Modified select statement to cover the case for phantom batches.
--*     03-Aug-2009 LCMOPM dev, bug 8642337, LCM-OPM Integration, Added one more query to load LC
--*                 adjustments invoking process_lc_adjustments to process LC adjustment transactions
--*************************************************************************************



PROCEDURE rollup_lot_costs
( errbuf            OUT NOCOPY VARCHAR2
, retcode           OUT NOCOPY VARCHAR2
, p_le_id   	       IN NUMBER
, p_cost_type_id     IN NUMBER
, p_final_run_flag   IN VARCHAR2
, p_structure_id     IN NUMBER
, p_category_id     IN NUMBER
, p_orgn_id          IN NUMBER
, p_item_id        IN NUMBER
, p_lot_no           IN VARCHAR2
, p_final_run_date IN VARCHAR2
)
IS
  inv_tran_cursor inv_tran_cursor_type;

  l_return_code  VARCHAR2(1);
  l_trans_date DATE;
  x_return_status NUMBER(1) := 0;
  l_source_orgn_id NUMBER;
  l_source_le_id NUMBER;
  procedure_name VARCHAR2(100);
  r_return_status NUMBER:= 0;
  l_code_version VARCHAR2(2000);

  CURSOR batch_status_cursor(p_batch_id NUMBER)
  IS
  SELECT batch_status
  FROM gme_batch_header
  WHERE batch_id = p_batch_id
  AND ACTUAL_CMPLT_DATE <= l_final_run_date;

  CURSOR file_version IS
  select text
    from   user_source
   where  name = 'GMF_LOT_COSTING_PUB'
     and    type = 'PACKAGE BODY'
     and    text like '%$Header%'
     and    line < 100;

BEGIN
    /* Moved various initialisations here to avoid GSCC warnings and errors */

    l_debug_level_none     := 0;
    l_debug_level_low      := 1;
    l_debug_level_medium   := 2;
    l_debug_level_high     := 3;
    l_tmp                  := TRUE;
    l_final_run_date := NVL(fnd_date.canonical_to_date(p_final_run_date),SYSDATE); -- Bug 4176690
    l_return_code  := NULL; -- Bug 3476508
    procedure_name := 'Rollup Lot Costs';

      /* uncomment the call below to write to a local file */
     --FND_FILE.PUT_NAMES('gmfplcrb.log','gmfplcrb.out','/appslog/opm_top/utl/opmm0dv/log');
    --  FND_FILE.PUT_NAMES('gmfplcrb.log','gmfplcrb.out','/slot05/oracle/opml0mtddb/9.2.0/temp');

--      fnd_file.put_line
--      (fnd_File.LOG,'Lot Cost Rollup v 0.1 started on '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));

      -- l_calendar_code := p_calendar_code;  umoogala - replaced with co_code
      --l_co_code := p_co_code;
      l_le_id := p_le_id;
      --l_cost_method_code := p_cost_method_code;
      l_cost_type_id := p_cost_type_id;
      l_cost_category_id := p_category_id;
      l_item_id := p_item_id;
      l_lot_no := p_lot_no;
      l_orgn_id := p_orgn_id;

      l_debug_level := TO_NUMBER(FND_PROFILE.VALUE( 'GMF_CONC_DEBUG' ));
      l_cost_alloc_profile := NVL( FND_PROFILE.VALUE('GMF_LOT_COST_ALLOC'), 0);

      -- umoogala 05-Dec-2003
      IF  p_final_run_flag = 'Y' THEN
        l_final_run_flag := 1;
      ELSE
        l_final_run_flag := 0;
      END IF;

     -- AF LCM-OPM Integration, to set the lot costed flag in lc_lot_cost_adjs table
     IF p_final_run_flag = 'Y' THEN
        l_lot_cost_flag := 1;
     ELSE
        l_lot_cost_flag := 0;
     END IF;

      -- l_user := p_user;  umoogala - replaced with the following:
      l_user_id := FND_PROFILE.VALUE('USER_ID');

      SELECT user_name INTO l_user
      FROM   fnd_user
      WHERE  user_id = l_user_id;

      -- Initialize WHO columns -- umoogala 05-DEC-2003
      l_login_id      := FND_GLOBAL.LOGIN_ID;
      l_prog_appl_id  := FND_GLOBAL.PROG_APPL_ID;
      l_program_id    := FND_GLOBAL.CONC_PROGRAM_ID;
      l_request_id    := FND_GLOBAL.CONC_REQUEST_ID;


    /* INVCONV sschinch Modified for convergence */

      SELECT m1.default_lot_cost_type_id
           , m1.trans_start_date
           , m1.cost_mthd_code
           , m2.cost_mthd_code
      INTO   l_default_cost_type_id,
             l_trans_start_date,
             l_cost_mthd_code,
             l_default_cost_mthd
      FROM   cm_mthd_mst m1,
             cm_mthd_mst m2
      WHERE  m1.cost_type_id = l_cost_type_id
      AND    m2.cost_type_id = m1.default_lot_cost_type_id;


     /******** Bug  4038722 - Dinesh Vadivel - Start **********/
     /*Get the Base Currency for the company. Later if needed check whether the unit cost is in
      the base currency and if not, convert it to the base currency */
     /* INVCONV sschinch */
      SELECT base_currency_code
      INTO l_base_ccy_code
      FROM gmf_fiscal_policies
      WHERE legal_entity_id = l_le_id;


      /******** Bug  4038722 - Dinesh Vadivel - End**********/

      -- PK print file version as well
      OPEN file_version;
      FETCH file_version INTO l_code_version;
      CLOSE file_version;

      fnd_file.put_line(fnd_file.log,'Code version '||l_code_version);
      fnd_file.put_line(fnd_file.log,'Parameters for this run are:');
      fnd_file.put_line(fnd_file.log,'Legal Entity Id    = '||p_le_id);
      fnd_file.put_line(fnd_file.log,'Cost Type = '||l_cost_mthd_code);
      fnd_file.put_line(fnd_file.log,'Default Cost Type = '||l_default_cost_mthd);
      fnd_file.put_line(fnd_file.log,'Rate Type Code   = '||l_rate_type_code);
      fnd_file.put_line(fnd_file.log,'Base Currency Code   = '||l_base_ccy_code);
      fnd_file.put_line(fnd_file.log,'trans start date = '||l_trans_start_date);
      fnd_file.put_line(fnd_file.log,'Item Category Id  = '||p_category_id);
      fnd_file.put_line(fnd_file.log,'Item Id      = '||p_item_id);
      fnd_file.put_line(fnd_file.log,'Lot Number       = '||p_lot_no);
      --fnd_file.put_line(fnd_file.log,'Sub-Lot Number   = '||p_sublot_no);
      fnd_file.put_line(fnd_file.log,'Debug Level      = '||to_char(l_debug_level));
      fnd_file.put_line(fnd_file.log,'User             = '||l_user);
      fnd_file.put_line(fnd_file.log,'Final Date = '||to_char(l_final_run_date,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log,'Final Run?       = '|| p_final_run_flag);
      fnd_file.put_line(fnd_file.log,'Cost Alloc Factor Profile   = '|| l_cost_alloc_profile);

      -- BUG 3476427
      -- If this is a final run, and the user has entered limiting parameters then
      -- let them know that they will be ignored.

      IF  l_final_run_flag = 1
      AND
      (   p_category_id IS NOT NULL
       OR p_item_id IS NOT NULL
       OR p_lot_no IS NOT NULL
       OR p_orgn_id IS NOT NULL
      )
      THEN
        fnd_file.put_line
        ( fnd_file.log, 'WARNING : Rollup submitted in final mode, limiting parameters will be ignored');

        l_cost_category_id := NULL;
        l_item_id := NULL;
        l_lot_no := NULL;
        l_orgn_id := NULL;
        l_tmp := FALSE;
      ELSE
        IF p_item_id IS NOT NULL AND p_category_id IS NOT NULL THEN
          fnd_file.put_line
          ( fnd_file.log, 'WARNING : Cost Category and item have both been specified, item will be used');
          l_cost_category_id := NULL;
          l_tmp := FALSE;
        END IF;
      END IF;


       -- There are two possibilities for the costing. A lot might be manufactured
      -- or bought in. Occasionally a lot might be bought in and later added to by a
      -- production batch or vice versa. No matter how the lot is created and/or replenished
      -- the sole criterion to decide whether to cost an item's lots using lot costing will
      -- be an entry for the item, or its cost_class, in gmf_lot_costed_items

      -- In the case of a lot that is an output of a production batch, we need
      -- to explode it and find out what lots went into its manufacture.

      -- If the lot is not from a production batch, then there is no explosion.

      -- In either case, once we have all the transactions that we need, we just have
      -- to work through them. The transactions are ordered by date and then by type and
      -- if transactions have been back-dated the algorithm will work, but might produce
      -- a wrong answer.

      -- For each replenishment we must add a new row to (or update the existing
      -- row in) GMF_LOT_COSTS, add new rows to (or update the existing rows in)
      -- GMF_LOT_COST_DETAILS and finally create a row in GMF_LOT_COST_TRANSACTIONS
      -- that links the inventory transaction to the row in GMF_LOT_COSTS.

      -- For each consumption we leave the GMF_LOT_COSTS and GMF_LOT_COST_DETAILS
      -- rows alone and just create the GMF_LOT_COST_TRANSACTIONS row.

      --
      -- umoogala 21-Nov-2003
      -- The reason for not using BULK COLLECT is, I want the table to be
      -- indexed by item_id so that I can easily lookup.
      --
/*  Bug 8730374 Always records for one cost category will be processed rather than one item alone
      IF l_item_id IS NOT NULL
      THEN
         BEGIN
                -- modified the query for bug 5705311, pmarada
               SELECT 		mic.category_id
         	   INTO 		l_cost_category_id
               FROM 		mtl_default_category_sets mdc,
                     		mtl_category_sets mcs,
                          	mtl_item_categories mic,
                          	mtl_categories mc
                 WHERE 		mic.inventory_item_id = l_item_id
                 AND 		mic.organization_id = l_orgn_id
                 AND 		mic.category_id = mc.category_id
                 AND 		mcs.structure_id = mc.structure_id
                 AND 		mdc.functional_area_id = 19
         	     AND     	mcs.category_set_id = mic.category_set_id
         	     AND     	mcs.category_set_id = mdc.category_set_id;

         EXCEPTION
          when NO_DATA_FOUND then
             l_cost_category_id := NULL;
         END;
      END IF;

End Bug 8730374 */
            -- PK Bug 6822310 always make l_orgn_id as NULL.
      IF l_final_run_flag = 0 AND p_orgn_id IS NOT NULL THEN
         fnd_file.put_line
        ( fnd_file.log, 'WARNING : Lot cost process should consider all lot transactions. Setting l_orgn_id to NULL');
        l_orgn_id := NULL;
      END IF;

       /* INVCONV sschinch Load Lot costed items and process organizations */
           Load_Lot_Costed_Items_gt(p_le_id        => l_le_id,
                                   p_orgn_id      => l_orgn_id,
                                   p_item_id      => l_item_id,
                                   p_category_id  => l_cost_category_id,
                                   x_return_status => x_return_status
                                  );
         IF (x_return_status <> 0) THEN
           fnd_file.put_line
          (fnd_file.log,'ERROR Procedure : '||procedure_name||' Load_Lot_Costed_Items_gt returned error. Cannot proceed');
           l_return_status := 'E';
           RETURN;
         END IF;

      /* FOR Cur_lc_items IN lot_costed_items (l_co_code, l_cost_method_code) INVCONV sshinch*/
      /* sschinch INVCONV indexed by organization id and item id */
      FOR Cur_lc_items IN lot_costed_items
      LOOP
	      lc_items_tab(Cur_lc_items.inventory_item_id||'-'||cur_lc_items.organization_id) := Cur_lc_items.inventory_item_id;
      END LOOP;


      -- umoogala 05-Dec-2003
      -- remove rows from previous trial run.
      fnd_file.put_line(fnd_File.LOG, 'Removing rows of previous trial run.');
      delete_lot_costs;

      fnd_file.put_line(fnd_File.LOG,'Reading uncosted transactions');


      -- Cursors to retrieve all transactions for items that are costed by lot
      -- that have not yet been processed. The above type is used to store the
      -- rows that are returned. There are several cursors depending on how the
      -- user has launched the rollup:
      --
      -- A full rollup will retrieve all transactions for all items/cost classes
      -- listed in the gmf_lot_costed_items table. Note that this retrieval will not
      -- possess a date range.
      --
      -- An item-specific rollup will only retrieve transactions for the item specified.
      -- If the item has a date range in the gmf_lot_costed_items table this will be
      -- used. This option also allows a user to specify an optional lot and sublot.
      --
      -- A cost class-specific rollup will only retrieved transactions for items in the
      -- cost class specified. If the cost class possesses a date range in gmf_lot_costed_items
      -- this will be used.


      --
      -- umoogala: replaced itemcost_class with cost_category_id and
      -- l_cost_class with l_cost_category_id.
      -- Also, added lot_ctl = 1 condition
      -- to where clause
      --

      -- Since the cursors below were written, a new column (co_code) has been added to the gmf_lot_costed_items table
      -- with the result that it is now possible to have rows differing only in this column.

      -- Cursors now possess a third branch that is 'union all'd' into the result set to retrieve the lot cost
      -- adjustments. These are disguised as transactions of type LADJ.

    -- Open a cursor that retrieves every uncosted lot costed item's transactions
	  --
	  -- umoogala: replaced itemcost_class with cost_category_id
	  --
  /* INVCONV sschinch. Removed all queries and recreated a single query to handle all situations */
  /* HALUTHRA Bug 8533290/5473138  In Case of phantom batches the ingrediant transactions were being given a higher prefernce when compared to
     product transaction. As a result of this , during first iteration since there was no cost for the item , the item was being set
     uncostable. Hence on second iteration for product transaction , the transaction was getting skipped since this item had been given
     uncostable tag.

     Now modifying the query to take product transaction first for phantom items.Doing this by a small trick
     Added two more variables, gme.phantom_type phantom_type and DECODE( NVL(gme.phantom_type,0),1,(mmt.transaction_date + (1/(2*24 * 3600)) ),
                                    mmt.transaction_date) phantom_trans_date
     Basically we are adding .5 second to the transaction date for ingrediant transaction of the phantom item so that product transaction is picked
     up before the ingrediant transaction.
     In the order by clause if the item a phantom item , then we order by phantom_trans_date otherwise we order by trans_date

dbms_output.put_line(' ');     Now once the product transaction gets picked up before the ingrediant transaction for a phantom item, there are still couple more of issues.
     In gme_transaction_pairs the transaction_id2 is can be for actual reversal transaction , and also for phantom item there can be a transaction_id2 which
     stores the other transaction for item .Eg if for a phantom item LCIMT2 there are two transactions
      Transaction 1 having transaction_ID = 887 which is a product transaction
      Transaction 2 havign transaction_id = 890 which is an ingrediant transaction.
     Now in GTP there will be a transaction_id2 for both the transacions but they have pair_type =2 which will be 1 for pure reversal transactions.
     Since we dont check for pair_type we mistake the transaction_id2 in this case as the reverse_id. Therefore changing the clause for reverse_id choice.


  Making three changes in this query
  Change 1 : changed reverse_id from nvl(gtp.transaction_id2,NULL) as reverse_id, to Decode(nvl(gtp.pair_type,0),1,gtp.transaction_id2,NULL) as reverse_id,
  Change 2 : Added three more columns to be selected in the select clause
		DECODE( NVL(gme.phantom_type,0),1,(mmt.transaction_date + (1/(2*24 * 3600)) ),
                                    mmt.transaction_date) phantom_trans_date
		gme.phantom_type phantom_type
		gtp.pair_type pair_type
  Change 3 : Changed the order by clause from  ORDER BY 7,decode(transaction_action_id,27,-1,transaction_source_type_id)... to
      ORDER BY decode(phantom_type,1,phantom_trans_date,trans_date),decode(transaction_action_id,27,-1,transaction_source_type_id)...
 */

 -- PK Bug 9069363 use in line query for gme_transaction_pairs we do not want to consider pair_type 2 records since such records are created for
 -- phantom batches even when there is no reversals causing duplicate selection of data.

OPEN inv_tran_cursor FOR
      SELECT * from
             (SELECT
                     mmt.transaction_source_id  as doc_id,
                     mmt.transaction_source_type_id,
                     mmt.inventory_item_id,
                     mmt.trx_source_line_id,
                     NVL(gme.line_type,0) as line_type,
                     mtln.lot_number,
                     mmt.transaction_date as trans_date,
                     mmt.transaction_id as transaction_id,
                     mtln.primary_quantity as trans_qty,
                     lcig.primary_uom_code as trans_um,
                     mmt.organization_id,
                     1 source,
                     Decode(nvl(gtp.pair_type,0),1,gtp.transaction_id2,NULL) as reverse_id, --nvl(gtp.transaction_id2,NULL) as reverse_id,
                     mmt.transaction_action_id,
                     nvl(mmt.transfer_price,0),
                     nvl(mmt.transportation_cost,0),
                     mmt.fob_point,
                     mmt.transfer_transaction_id,
                     NVL(mmt.transaction_cost,0),
                     mmt.transfer_organization_id,
                     DECODE( NVL(gme.phantom_type,0),1,(mmt.transaction_date + (1/(2*24 * 3600)) ),
                                    mmt.transaction_date) phantom_trans_date,
                     gme.phantom_type phantom_type,
                     gtp.pair_type pair_type,
                     decode(gme.phantom_type,1,DECODE( NVL(gme.phantom_type,0),1,(mmt.transaction_date + (1/(2*24 * 3600)) ),
                                    mmt.transaction_date),mmt.transaction_date) as oc1,
                     decode(mmt.transaction_action_id,27,-1,mmt.transaction_source_type_id) as oc2,
                     DECODE(gme.line_type,1, DECODE((ABS(DECODE(mtln.primary_quantity, 0, 1,mtln.primary_quantity))/DECODE(mtln.primary_quantity, 0, 1, mtln.primary_quantity)),
                                         1, mmt.transaction_id ,
                                         DECODE(Decode(nvl(gtp.pair_type,0),1,gtp.transaction_id2,NULL), NULL, mmt.transaction_id, (Decode(nvl(gtp.pair_type,0),1,gtp.transaction_id2,NULL)+.5))),mmt.transaction_id) as oc3
                   FROM mtl_material_transactions mmt,
                        gme_material_details gme,
                        mtl_transaction_lot_numbers mtln,
                        (Select pair_type, transaction_id1, transaction_id2 From gme_transaction_pairs where pair_type = 1) gtp, -- PK Bug 9069363
                        gmf_process_organizations_gt gpo,
                        gmf_lot_costed_items_gt lcig
                   WHERE
                         gpo.organization_id = mmt.organization_id
                   AND   gpo.legal_entity_id = l_le_id  -- B 8687115
                   AND   mmt.transaction_date >= NVL(l_trans_start_date, mmt.transaction_date)
                   AND   mmt.transaction_date <= l_final_run_date
                   AND   mmt.trx_source_line_id = gme.material_detail_id
                   AND   mmt.transaction_id = gtp.transaction_id1 (+)
                   AND   mmt.transaction_id = mtln.transaction_id
                   AND   mmt.organization_id = NVL(l_orgn_id,mmt.organization_id)
                   AND   mmt.inventory_item_id = lcig.inventory_item_id
                   AND   mmt.organization_id   = lcig.organization_id
                   AND  mmt.transaction_source_type_id = 5
                   AND   mtln.lot_number = nvl(p_lot_no,mtln.lot_number)
                   AND  NOT EXISTS (SELECT 1
                                    FROM GMF_MATERIAL_LOT_COST_TXNS gmlct
                                   WHERE gmlct.transaction_id = mmt.transaction_id /* ANTHIYAG Bug#5285726 07-Jun-2006 */
                                   AND   gmlct.cost_type_id = l_cost_type_id
                                   AND   gmlct.lot_number  = mtln.lot_number
                                  AND   gmlct.final_cost_flag = 1)
                   AND   gme.phantom_type IN (select (decode(phantom_type,1,1,0))
                                from gme_material_details gme1 where mmt.trx_source_line_id = gme1.material_detail_id)
                 UNION ALL
                 SELECT
                     mmt.transaction_source_id  as doc_id,
                     mmt.transaction_source_type_id,
                     mmt.inventory_item_id,
                     mmt.trx_source_line_id,
                     0 as line_type,
                     mtln.lot_number,
                     mmt.transaction_date as trans_date,
                     mmt.transaction_id as transaction_id,
                     mtln.primary_quantity as trans_qty,
                     lcig.primary_uom_code as trans_um,
                     mmt.organization_id,
                     2 source,
                     NULL as reverse_id,
                     mmt.transaction_action_id,
                     nvl(mmt.transfer_price,0),
                     nvl(mmt.transportation_cost,0),
                     mmt.fob_point,
                     mmt.transfer_transaction_id,
                     NVL(mmt.transaction_cost,0),
                     mmt.transfer_organization_id,
                    mmt.transaction_date as phantom_trans_date,
                     -1 as phantom_type,
                     null,
                     mmt.transaction_date as oc1,
                     decode(mmt.transaction_action_id,27,-1,mmt.transaction_source_type_id) as oc2,
                     mmt.transaction_id as oc3
                   FROM mtl_material_transactions mmt,
                        mtl_transaction_lot_numbers mtln,
                        gmf_process_organizations_gt gpo,
                        gmf_lot_costed_items_gt lcig
                   WHERE
                         gpo.organization_id = mmt.organization_id
                   AND   gpo.legal_entity_id = l_le_id  -- B 8687115
                   AND   mmt.transaction_date >= NVL(l_trans_start_date, mmt.transaction_date)
                   AND   mmt.transaction_date <= l_final_run_date
                   AND   mmt.transaction_id = mtln.transaction_id
                   AND   mmt.organization_id = NVL(l_orgn_id,mmt.organization_id)
                   AND   mmt.inventory_item_id = lcig.inventory_item_id
                   AND   mmt.organization_id   = lcig.organization_id
                   AND   mmt.organization_id = NVL(mmt.owning_organization_id, mmt.organization_id) /* ANTHIYAG Bug#5460458 11-Aug-2006 */
                   AND   NVL(mmt.owning_tp_type,2) = 2                                              /* ANTHIYAG Bug#5460458 11-Aug-2006 */
                   AND   mmt.transaction_source_type_id <> 5
                   AND   mmt.transaction_action_id NOT IN (15,22,6,2) /* PK added subinv Xfer */
                   AND   mtln.lot_number = nvl(p_lot_no,mtln.lot_number)
                   AND   NOT EXISTS (SELECT 1
                                    FROM GMF_MATERIAL_LOT_COST_TXNS gmlct
                                   WHERE gmlct.transaction_id = mmt.transaction_id /* ANTHIYAG Bug#5285726 07-Jun-2006 */
                                   AND   gmlct.cost_type_id = l_cost_type_id
                                   AND   gmlct.lot_number  = mtln.lot_number
                                   AND   gmlct.final_cost_flag = 1)
                UNION ALL
                  SELECT
                     mmt.transaction_source_id  as doc_id,
                     mmt.transaction_source_type_id,
                     mmt.inventory_item_id,
                     mmt.trx_source_line_id,
                     0 as line_type,
                     mtln.lot_number,
                     mmt.transaction_date as trans_date,
                     mmt.transaction_id as transaction_id,
                     mtln.primary_quantity as trans_qty,
                     lcig.primary_uom_code as trans_um,
                     mmt.organization_id,
                     2 source,
                     NULL as reverse_id,
                     mmt.transaction_action_id,
                     nvl(mmt.transfer_price,0),
                     nvl(mmt.transportation_cost,0),
                     mmt.fob_point,
                     mmt.transfer_transaction_id,
                     NVL(mmt.transaction_cost,0),
                     mmt.transfer_organization_id,
                    mmt.transaction_date as phantom_trans_date,
                     -1 as phantom_type,
                     null,
                     mmt.transaction_date as oc1,
                     decode(mmt.transaction_action_id,27,-1,mmt.transaction_source_type_id) as oc2,
                     mmt.transaction_id as oc3
                   FROM mtl_material_transactions mmt,
                        mtl_transaction_lot_numbers mtln,
                        gmf_process_organizations_gt gpo,
                        gmf_lot_costed_items_gt lcig
                   WHERE
                         gpo.organization_id = mmt.owning_organization_id
                   AND   gpo.legal_entity_id = l_le_id  -- B 8687115
                   AND   mmt.transaction_date >= NVL(l_trans_start_date, mmt.transaction_date)
                   AND   mmt.transaction_date <= l_final_run_date
                   AND   mmt.owning_tp_type    = 2
                   AND   mmt.transaction_id = mtln.transaction_id
                   AND   mmt.owning_organization_id = NVL(l_orgn_id,mmt.owning_organization_id)
                   AND   mmt.transaction_source_type_id = 1
                   AND   mmt.transaction_action_id = 6
                   AND   mmt.inventory_item_id = lcig.inventory_item_id
                   AND   mmt.organization_id   = lcig.organization_id
                   AND   mtln.lot_number = nvl(p_lot_no,mtln.lot_number)
                   AND  NOT EXISTS (SELECT 1
                                    FROM GMF_MATERIAL_LOT_COST_TXNS gmlct
                                   WHERE gmlct.transaction_id = mmt.transaction_id /* ANTHIYAG Bug#5285726 07-Jun-2006 */
                                   AND   gmlct.cost_type_id = l_cost_type_id
                                   AND   gmlct.lot_number  = mtln.lot_number
                                   AND   gmlct.final_cost_flag = 1)
                  UNION ALL  /*sschinch INVCONV this query will pickup logical shipments and receipts */
                    SELECT
                     mmt.transaction_source_id  as doc_id,
                     mmt.transaction_source_type_id,
                     mmt.inventory_item_id,
                     mmt.trx_source_line_id,
                     0 as line_type,
                     mtln.lot_number,
                     mmt.transaction_date as trans_date,
                     mmt.transaction_id as transaction_id,
                     mtln.primary_quantity as trans_qty,
                     lcig.primary_uom_code as trans_um,
                     mmt.organization_id,
                     2 source,
                     NULL as reverse_id,
                     mmt.transaction_action_id,
                     nvl(mmt.transfer_price,0),
                     nvl(mmt.transportation_cost,0),
                     mmt.fob_point,
                     mmt.transfer_transaction_id,
                     NVL(mmt.transaction_cost,0),
                     mmt.transfer_organization_id,
                     mmt.transaction_date as phantom_trans_date,
                     -1 as phantom_type,
                     null,
                     mmt.transaction_date as oc1,
                     decode(mmt.transaction_action_id,27,-1,mmt.transaction_source_type_id) as oc2,
                     mmt.transaction_id as oc3
                   FROM mtl_material_transactions mmt,
                        mtl_transaction_lot_numbers mtln,
                        gmf_process_organizations_gt gpo,
                        gmf_lot_costed_items_gt lcig
                   WHERE
                         gpo.organization_id = mmt.organization_id
                   AND   gpo.legal_entity_id = l_le_id  -- B 8687115
                   AND   mmt.transaction_date >= NVL(l_trans_start_date, mmt.transaction_date)
                   AND   mmt.transaction_date <= l_final_run_date
                   AND   mmt.transfer_transaction_id = mtln.transaction_id
                   AND   mmt.organization_id = NVL(l_orgn_id,mmt.organization_id)
                   AND   mmt.inventory_item_id = lcig.inventory_item_id
                   AND   mmt.organization_id   = lcig.organization_id
                   AND   mmt.transaction_source_type_id IN (8,7,13)
                   AND   mmt.transaction_action_id IN (15,22)
                   AND   mtln.lot_number = nvl(p_lot_no,mtln.lot_number)
                   AND   NOT EXISTS (SELECT 1
                                     FROM GMF_MATERIAL_LOT_COST_TXNS gmlct
                                     WHERE gmlct.transaction_id = mmt.transaction_id /* ANTHIYAG Bug#5285726 07-Jun-2006 */
                                     AND   gmlct.cost_type_id = l_cost_type_id
                                     AND   gmlct.lot_number  = mtln.lot_number
                                     AND   gmlct.final_cost_flag = 1)
                 UNION ALL
                   SELECT
                     glca.adjustment_id doc_id,
                     0 transaction_source_type_id,
                     glca.inventory_item_id,
                     glca.adjustment_id line_id,
                     0 as line_type ,
                     glca.lot_number ,
                     glca.adjustment_date trans_date ,
                     -9 transaction_id,
                     0  trans_qty,
                     iimb.primary_uom_code trans_um,
                     glca.organization_id,
                     3 source,
                     NULL as reverse_id,
                     0 as transaction_action_id,
                     0 as transfer_price,
                     0 as transportation_cost,
                     0 as fob_point,
                     0 as transfer_transaction_id,
                     0 as transaction_cost,
                     0 as transfer_transaction_id,
                     glca.adjustment_date as phantom_trans_date,
                     -1 as phantom_type,
                     null,
                     glca.adjustment_date as oc1,
                     0 as oc2,
                     -9 as oc3
                   FROM  gmf_lot_cost_adjustments glca,
                         mtl_system_items_b iimb,
                         gmf_lot_costed_items_gt glci
                   WHERE glca.applied_ind       = 'N'
                   AND   glca.adjustment_date  >= NVL(l_trans_start_date, glca.adjustment_date)
                   AND   glca.legal_entity_id   = l_le_id
                   AND   glca.cost_type_id      = l_cost_type_id
                   AND   glca.delete_mark       = 0
                   AND   iimb.inventory_item_id = glca.inventory_item_id
                   AND   glca.organization_id   = iimb.organization_id
                   AND   glca.organization_id   = NVL(l_orgn_id,glca.organization_id)
                   AND   glca.inventory_item_id = glci.inventory_item_id
                   AND   glca.organization_id   = glci.organization_id
                   AND   glca.adjustment_date   <= l_final_run_date
                   AND   glca.lot_number = nvl(p_lot_no,glca.lot_number)
                  AND EXISTS
                       (SELECT 1 FROM gmf_lot_cost_adjustment_dtls
                        WHERE adjustment_id = glca.adjustment_id
                        AND   delete_mark = 0
                       )
                    --LCM-OPM Integration, Load Actual LC adjustment transactions, AF
                UNION ALL
                   SELECT
		                      glat.rcv_transaction_id doc_id,
                          50 transaction_source_type_id,
                          glat.inventory_item_id,
                          glat.ship_line_id line_id,
                          0 as line_type ,
                          rlt.lot_num,
                          decode(sign(glat.transaction_date-rt.transaction_date), 1, glat.transaction_date, rt.transaction_date) trans_date,
                          glat.adj_transaction_id transaction_id,
                          glat.primary_quantity,
                          glat.primary_uom_code trans_um,
                          glat.organization_id,
                          4 source,
                          NULL as reverse_id,
                          0 as transaction_action_id,
                          0 as transfer_price,
                          0 as transportation_cost,
                          0 as fob_point,
                          0 as transfer_transaction_id,
                          0 as transaction_cost,
                          0 as transfer_transaction_id,
                          glat.transaction_date as phantom_trans_date,
                          -1 as phantom_type,
                          NULL,
                          decode(sign(glat.transaction_date-rt.transaction_date), 1, glat.transaction_date, rt.transaction_date) oc1,
                          0 as oc2,
                         -9 as oc3
                   FROM
		                      gmf_lc_adj_transactions glat,
                          rcv_transactions rt,
                          rcv_lot_transactions rlt,
                          gmf_process_organizations_gt gpo,
                          gmf_lot_costed_items_gt glci
                   WHERE
		                      glat.transaction_date >= NVL(l_trans_start_date,glat.transaction_date)
                     AND  rlt.lot_num            = NVL(p_lot_no,rlt.lot_num)
                     AND  rt.transaction_id      = rlt.transaction_id
                     AND  rt.transaction_id      = glat.rcv_transaction_id
                     AND  gpo.organization_id    = glat.organization_id
                     AND  glat.organization_id   = NVL(l_orgn_id,glat.organization_id)
                     AND  glci.organization_id   = glat.organization_id
                     AND  glci.inventory_item_id = glat.inventory_item_id
                     AND  glat.transaction_date  <= l_final_run_date
                     AND  glat.event_type         IN (16,17)
                     AND  glat.component_type IN ('ITEM PRICE','CHARGE')
                     AND  glat.cost_acquisition_flag = 'I'
                     AND  (glat.lc_adjustment_flag = 1 OR glat.adjustment_num > 0)  /* Load only actual lc adj */
                     AND  NOT EXISTS (SELECT 1
                                        FROM  gmf_lc_lot_cost_adjs    gllca
                                       WHERE  gllca.adj_transaction_id = glat.adj_transaction_id
                                         AND  gllca.cost_type_id       = l_cost_type_id
                                         AND  gllca.lot_number         = rlt.lot_num
                                         AND  gllca.lot_costed_flag    = 1)
                -- End LCM-OPM Integration, AF
                )
                --ORDER BY 7,2,5  /*Bug 7215069 - Changed ordering for Receipt into Stores*/
                -- oc1, oc2, line_type,  oc3, lot_number    -- B9131983
                ORDER BY 24, 25, 5, 26, 6;


/*                 ORDER BY decode(phantom_type,1,phantom_trans_date,trans_date),decode(transaction_action_id,27,-1,transaction_source_type_id),5
                  ,DECODE(line_type,1, DECODE((ABS(DECODE(trans_qty, 0, 1,trans_qty))/DECODE(trans_qty, 0, 1, trans_qty)),
                  1, transaction_id ,
                  DECODE(reverse_id, NULL, transaction_id, reverse_id+.5)),transaction_id)
              ;   */

               /* ORDER BY 7,decode(transaction_action_id,27,-1,transaction_source_type_id),5
                  ,DECODE(line_type,1, DECODE((ABS(DECODE(trans_qty, 0, 1,trans_qty))/DECODE(trans_qty, 0, 1, trans_qty)),
                  1, transaction_id ,
                  DECODE(reverse_id, NULL, transaction_id, reverse_id+.5)),transaction_id)
              ;*/



      FETCH inv_tran_cursor INTO transaction_row;

     -- BUG8290451 (found during QA testing)
   /*    IF l_item_id  is null then
         r_return_status := 0;
         ReLoad_Lot_Costed_Items_gt(p_le_id         => l_le_id,
                                    x_return_status => r_return_status
                                  );
         IF (r_return_status <> 0) THEN
           fnd_file.put_line
          (fnd_file.log,'ERROR Procedure : '||procedure_name||' Load_Lot_Costed_Items_gt returned error. Cannot proceed');
           l_return_status := 'E';
           CLOSE inv_tran_cursor;
           RETURN;
         END IF;
       END IF;  */

      WHILE inv_tran_cursor%FOUND
      LOOP

        SAVEPOINT inv_tran;

        /* Reset the profile variable to the correct one in every loop*/
        l_cost_alloc_profile := NVL( FND_PROFILE.VALUE('GMF_LOT_COST_ALLOC'), 0);

        IF ( transaction_row.fob_point = FOB_SHIPPING AND
            transaction_row.transaction_action_id  = LOGICAL_INTRANSIT_RECEIPT
           )
        THEN
          /*here transaction_row.trans_qty  will be negative as we take the value from the source org in the inv trans cursor
           making the qunatity as positive as we know that this is a receipt and the qunatity will be positive*/
          transaction_row.trans_qty := abs(transaction_row.trans_qty);
        END IF;


        -- Forget all data from last time round

        old_cost := NULL;
        IF old_cost_tab.exists(1) THEN old_cost_tab.delete; END IF;
        IF new_cost_tab.exists(1) THEN new_cost_tab.delete; END IF;
        IF l_burdens_tab.exists(1) THEN l_burdens_tab.delete; END IF;
        IF l_acqui_cost_tab.exists(1) THEN l_acqui_cost_tab.delete; END IF;

        IF   l_debug_level >= l_debug_level_high THEN
          fnd_file.put_line
          (fnd_file.log,'Inside inv_tran_cursor, inventory_item_id = ' || transaction_row.inventory_item_id ||
	  		' lot_number = '||transaction_row.lot_number ||
	  		' orgn = '||l_org_tab(transaction_row.orgn_id) ||
	  		' transaction_id = '||to_char(transaction_row.transaction_id) ||
	  		' reverse_id = '||to_char(transaction_row.reverse_id) ||
	  		' trans_date = '||to_char(transaction_row.trans_date, 'DD-MON-YYYY HH24:MI:SS') ||
			  ' doc type = '||transaction_row.transaction_source_type_id ||
           ' action type = '||transaction_row.transaction_action_id ||
			  ' Qty = ' || transaction_row.trans_qty ||
				' ' || transaction_row.trans_um ||
			' source = ' || transaction_row.source ||
           ' transfer orgn id = ' || transaction_row.transfer_orgn_id ||
           ' line id = ' || transaction_row.line_id);
          fnd_file.put_line
          (fnd_File.LOG,'Loading existing cost for lot_id '||to_char(transaction_row.lot_number)||' in organization '
         		||l_org_tab(transaction_row.orgn_id));
        END IF;

         -- Bug 4130869 Added Date field as NULL.. Because, the Date field has no significance here.
         -- We have to delete all the records irrespective of trans_date.
        /* INVCONV sschinch Commented to replace parameters
          OPEN  lot_cost_cursor (transaction_row.whse_code, transaction_row.inventory_item_id, transaction_row.lot_id,NULL);
        */
        /* INVCONV sschinch */
        l_lot_number := transaction_row.lot_number;

        OPEN lot_cost_cursor(transaction_row.orgn_id,
                             transaction_row.inventory_item_id,
                             transaction_row.lot_number,
                             NULL,
                             l_cost_type_id);
        FETCH lot_cost_cursor INTO old_cost;

        IF lot_cost_cursor%FOUND THEN
          IF   l_debug_level >= l_debug_level_high THEN
            fnd_file.put_line
            (fnd_file.log,'Reading existing costs for header ID '||old_cost.header_id);
          END IF;

          OPEN  lot_cost_detail_cursor (old_cost.header_id);
          FETCH lot_cost_detail_cursor BULK COLLECT INTO old_cost_tab;
          CLOSE lot_cost_detail_cursor;
        ELSE
          old_cost.onhand_qty := 0;
        END IF;

        CLOSE lot_cost_cursor;

        IF old_cost_tab.EXISTS(1) THEN
          IF   l_debug_level >= l_debug_level_high THEN
            fnd_file.put_line
                (fnd_file.log,'Lot Cost before this transaction is '||to_char(old_cost.unit_cost,'999999999.99'));
          END IF;
        ELSE
            /* Bug 4227784 - This has to be moved up. We can have a case, where we have header
               but not details. So old_cost_tab can be null, even though old_cost has some record.
               In that case, we should not initialize onhand_qty to zero*/
                --  old_cost.onhand_qty := 0;
          IF   l_debug_level >= l_debug_level_high THEN
             fnd_file.put_line(fnd_file.log,'Previous cost was NULL');
          END IF;
        END IF;

          IF   l_debug_level >= l_debug_level_high THEN
            fnd_file.put_line(fnd_file.log,' Checking if the Current Lot '||transaction_row.lot_number||' is Costable ?');

          END IF;

        /*IF NOT l_uncostable_lots_tab.EXISTS(transaction_row.lot_id)*/
        /*IF is_lot_costable(transaction_row.orgn_id,transaction_row.inventory_item_id,transaction_row.lot_number) IS NOT NULL*/
       IF NOT l_uncostable_lots_tab.EXISTS(transaction_row.orgn_id||'-'||transaction_row.inventory_item_id||'-'||transaction_row.lot_number)
        THEN
           IF   l_debug_level >= l_debug_level_high THEN
               fnd_file.put_line(fnd_file.log,' Yes. Current Lot '||transaction_row.lot_number||' is Costable.');
           END IF;

           --
	        -- umoogala: replaced CASE stmt with IF..ELSE..END IF
	        -- CASE stmt is not supported in 8i Db
	        --
          -- If the onhand balance for this lot is negative before this transaction is processed
          -- we have to process it differently.
          -- If the onhand balance will still be negative (or 0) after this transaction has been
          -- processed, we simply treat this as an adjustment at the curent cost. Transactions that
          -- flip the balance positive are treated as if they had been split into two quantities. The
          -- first of which updates the balance to zero at the old cost. The residue of the trans_qty
          -- is then used to create a new cost. The 'feature' though is that the new cost is created as
          -- the entire quantity has been used in the calculations but the onhand it is set against is
          -- the difference beween the old and new quantities. Got that?

          l_residual_qty := old_cost.onhand_qty + transaction_row.trans_qty;

          IF   old_cost.onhand_qty < 0 AND  l_residual_qty <= 0
          THEN
             fnd_file.put_line(fnd_file.log,' 3');
            IF   l_debug_level >= l_debug_level_high  THEN
              fnd_file.put_line
              (fnd_file.log,'Onhand balance is currently -ve and will remain -ve. Processing txn as an ADJI');
            END IF;

            process_adjustment;

          ELSE
            IF  old_cost.onhand_qty < 0 AND  l_residual_qty > 0
            THEN

              IF   l_debug_level >= l_debug_level_high THEN
                fnd_file.put_line
                (fnd_file.log,'Onhand balance is currently -ve and will go +ve. Clearing old balance to zero');
              END IF;

              old_cost.onhand_qty := 0;
            ELSE
              IF   l_debug_level >= l_debug_level_high THEN
                fnd_file.put_line
                (fnd_file.log,'Onhand balance is currently +ve. Processing normally');
              END IF;

              l_residual_qty := transaction_row.trans_qty;
            END IF;

            /*IF transaction_row.transaction_source_type_id = 'PORC'*/
            IF (transaction_row.transaction_source_type_id IN (INTERNAL_REQ,INTERNAL_ORDER,INVENTORY)
                AND transaction_row.transaction_action_id IN (INTRANSIT_RECEIPT,LOGICAL_INTRANSIT_RECEIPT)
               )
            THEN
                  SELECT decode(mp.process_enabled_flag,'N',1,0)
                  INTO l_flg_ind
                  FROM mtl_parameters mp
                  WHERE mp.organization_id = transaction_row.transfer_orgn_id;

              IF (l_flg_ind = 0) THEN
                process_receipt;
              ELSE
                process_pd_transfer;
              END IF;

            ELSIF ( transaction_row.transaction_source_type_id = PURCHASE_ORDER  -- jboppana
                    AND transaction_row.transaction_action_id = RECEIPT_INTO_STORES)
            THEN
                 process_receipt;
            /*ELSIF transaction_row.doc_type = 'PROD' INVCONV sshchinch*/
            ELSIF (transaction_row.transaction_source_type_id = BATCH)
            THEN

                OPEN batch_status_cursor(transaction_row.doc_id);
                FETCH batch_status_cursor INTO l_batch_status;
                IF( batch_status_cursor % NOTFOUND) THEN
                  l_batch_status := 0;
                END IF;
                CLOSE batch_status_cursor;


                IF (transaction_row.line_type IN (-1,2)) THEN
                  process_adjustment;

                ELSIF transaction_row.line_type = 1       /* Bug 4004338 Uday Moogala - Added */
                   AND   transaction_row.trans_qty < 0
                   AND   transaction_row.reverse_id IS NOT NULL
                THEN

                  -- If PROD and reversal, then see if there are any txns between the
                  -- original yeild and this reversal. If there is none, then we'll
                  -- create new header and details row(s) with unit cost prior to the
                  -- original yield. Set it to zero, if there are no prior costs.
                    process_reversals2;

                ELSIF transaction_row.line_type = 1
                   AND   transaction_row.trans_qty < 0
                   AND   transaction_row.reverse_id IS NULL
                THEN
                   -- Bug 9239944 Wip Completion return
                   IF l_batch_status IN (3,4)  THEN
                  -- If PROD and WIP Completion Return and not a reversal.
                    process_reversals2;
                   ELSE
                     fnd_file.put_line(fnd_file.log,'WARNING: Batch status is not 3 or 4 Setting Lot for the orgn/Item/Lot '||transaction_row.orgn_id||'/'||transaction_row.inventory_item_id||'/'||transaction_row.lot_number||' as uncostable');
                     l_uncostable_lots_tab(transaction_row.orgn_id||'-'||transaction_row.inventory_item_id||'-'||transaction_row.lot_number) := transaction_row.inventory_item_id;
                     goto DONT_PROCESS_WIPBATCH ;
                   END IF;

                ELSE

                -- This is a product line of some kind. If the batch has been uncertified the usually positive
                -- transaction quantity will be negative. This is similar to a PO return.

                -- The costs come from both standard and lot-costed items, together with any resource costs
                -- and burdens. If the lot being yielded does not have a cost in this organization, the procedure
                -- will set them up.

                -- If there is already a cost for this lot and organization then the costs will be updated
                -- by averaging the new cost with the old cost by using the original and revised quantities.

                /****** Bug 4177349 - Start ******/

                --The Status as on Final Date is Completed . So Process Normally through process_batch*/
                IF l_batch_status IN (3,4)  THEN
                  process_batch;
                ELSE  /* The Status as on Final Date is not completed. So copy the previous cost for this record or 0$ */

                  -- Bug 9284024 Macsteel. Decided not to process wip batches product yield
                  -- for item, lot combination.
                  fnd_file.put_line(fnd_file.log,'WARNING: Batch status is not 3 or 4 Setting Lot for the orgn/Item/Lot '||transaction_row.orgn_id||'/'||transaction_row.inventory_item_id||'/'||transaction_row.lot_number||' as uncostable');
                  l_uncostable_lots_tab(transaction_row.orgn_id||'-'||transaction_row.inventory_item_id||'-'||transaction_row.lot_number) := transaction_row.inventory_item_id;
                  goto DONT_PROCESS_WIPBATCH ;
                  -- process_wip_batch;
                END IF;

                IF l_step_tab.EXISTS(1) THEN
                   l_step_tab.DELETE;
                END IF;
              END IF;
              /* Consigned Inventory Transfer to Regular*/
            ELSIF (transaction_row.transaction_source_type_id = PURCHASE_ORDER
                   AND transaction_row.transaction_action_id = OWNERSHIP_TRANSFER
                   AND transaction_row.transaction_cost > 0
                   AND transaction_row.trans_qty >= 0
                  )
              THEN
                process_consigned_inventory;
            ELSIF (transaction_row.transaction_source_type_id
                        IN (ACCOUNT,ACCOUNT_ALIAS,
                            CYCLE_COUNT,
                            PHYSICAL_INVENTORY,
                            INVENTORY,
                            MOVE_ORDER)            -- B 6859710 Added MOVE_ORDER
                     AND transaction_row.transaction_action_id IN (ISSUE_FROM_STORES,
                                                                 CYCLE_COUNT_ADJUSTMENT,
                                                                 RECEIPT_INTO_STORES,PHYSICAL_INVENTORY_ADJST) -- B 8616761 Added PHYSICAL_INVENTORY_ADJST
                  )
           THEN
             -- Because of the way that creations and adjustments can be entered there might
             -- or might not be a cost already. If there is a cost treat all such transactions
             -- as adjustments. If there isn't one treat them as creations

             IF old_cost_tab.EXISTS(1) THEN
               process_adjustment;
             ELSE
               process_creation;
             END IF;
              /*ELSIF transaction_row.doc_type IN ('TRNI','TRNR')*/
           ELSIF (transaction_row.transaction_source_type_id IN (INTERNAL_ORDER,INTERNAL_REQ,INVENTORY) AND
                  transaction_row.transaction_action_id = DIRECT_ORG_TRANSFER AND
                  transaction_row.trans_qty > 0
                 )THEN
            /* INVCONV sschinch */
            SELECT  transfer_organization_id,
                    hoi.org_information2
              INTO l_source_orgn_id,
                   l_source_le_id
              FROM   mtl_material_transactions mmt,
                     hr_organization_information hoi
             WHERE  mmt.transaction_id = transaction_row.transaction_id
                  AND hoi.organization_id = mmt.transfer_organization_id
                  AND hoi.org_information_context = 'Accounting Information';
                /*  INVCONV sschinch
                  INVCONV sschinchIF l_source_whse_code <> l_target_whse_code
                  THEN
                */

                SELECT decode(mp.process_enabled_flag,'N',1,0)
                  INTO l_flg_ind
                  FROM mtl_parameters mp
                 WHERE mp.organization_id = transaction_row.transfer_orgn_id;

              IF (l_flg_ind = 0) THEN
                 process_movement( transaction_row.line_type
                                , l_source_orgn_id
                                , transaction_row.orgn_id
                                , l_source_le_id
                                , l_le_id
                                , transaction_row.trans_date
                                );
              ELSE
                 process_pd_transfer;
              END IF;

        	    /*ELSIF transaction_row.doc_type = 'XFER' INVCONV sschinch*/
	          ELSIF (transaction_row.transaction_source_type_id IN (INTERNAL_ORDER,INTERNAL_REQ,INVENTORY) AND
                   transaction_row.transaction_action_id  = DIRECT_ORG_TRANSFER AND
                   transaction_row.trans_qty < 0
	                )
	           THEN
                process_adjustment;
             ELSIF (transaction_row.transaction_source_type_id IN (INTERNAL_ORDER,INTERNAL_REQ,INVENTORY) AND
                   transaction_row.transaction_action_id  = INTRANSIT_SHIPMENT)  -- JBOPPANA
	           THEN
                process_adjustment;
               /*ELSIF transaction_row.doc_type IN ('OMSO','OPSO') */
            ELSIF transaction_row.transaction_source_type_id IN (SALES_ORDER,INTERNAL_ORDER)
                AND transaction_row.transaction_action_id IN (ISSUE_FROM_STORES,LOGICAL_INTRANSIT_SHIPMENT)
              THEN
                process_adjustment;

/* ANTHIYAG Bug#5287514 07-Jun-2006 Start */
/*HALUTHRA BUG 7249505 STARTS : In case of return to vendor process the transaction as an adjustment */
           /*
            ELSIF transaction_row.transaction_source_type_id = PURCHASE_ORDER
                AND transaction_row.transaction_action_id IN (ISSUE_FROM_STORES, DELIVERY_ADJUSTMENTS)
              THEN
                process_receipt;
                */
              ELSIF transaction_row.transaction_source_type_id = PURCHASE_ORDER
                AND transaction_row.transaction_action_id = ISSUE_FROM_STORES
              THEN
                process_adjustment;
               -- process_receipt;
             ELSIF transaction_row.transaction_source_type_id = PURCHASE_ORDER
                AND transaction_row.transaction_action_id =DELIVERY_ADJUSTMENTS
              THEN
                process_receipt;

/*HALUTHRA BUG 7249505 ENDS */
/* ANTHIYAG Bug#5287514 07-Jun-2006 End */

            ELSIF transaction_row.transaction_source_type_id = RMA
                AND transaction_row.transaction_action_id = ISSUE_FROM_STORES
              THEN
                process_adjustment;
            ELSIF transaction_row.transaction_source_type_id = RMA
                AND transaction_row.transaction_action_id = RECEIPT_INTO_STORES
              THEN
                process_receipt;

               /*ELSIF transaction_row.doc_type = 'LADJ'*/
            ELSIF (transaction_row.transaction_source_type_id = LOT_COST_ADJUSTMENT)
              THEN
                process_lot_cost_adjustments;
                /* INVCONV sschinch */
            ELSIF (transaction_row.transaction_source_type_id = INVENTORY AND
                transaction_row.transaction_action_id = LOT_SPLIT)
              THEN
                process_lot_split;
            ELSIF (transaction_row.transaction_source_type_id = INVENTORY AND
                   transaction_row.transaction_action_id = LOT_MERGE)
            THEN
                process_lot_merge;
            ELSIF (transaction_row.transaction_source_type_id = INVENTORY AND
                   transaction_row.transaction_action_id = LOT_TRANSLATE
                  ) THEN
              process_lot_translate;
            -- AF   LCM-OPM Integration
            ELSIF transaction_row.transaction_source_type_id = LC_ADJUSTMENT THEN
                 IF   l_debug_level >= l_debug_level_high THEN
                  fnd_file.put_line (fnd_file.log,'Call process_lc_adjustments for :' || transaction_row.transaction_id);
                END IF;
                process_lc_adjustments();
            -- AF
            END IF;

              IF l_residual_qty <> transaction_row.trans_qty THEN
                -- The transaction that has been processed flipped a negative onhand balance back to positive
                -- so we need to adjust the onhand balance in the header to the residual balance

                IF   l_debug_level >= l_debug_level_high THEN
                  fnd_file.put_line
                  (fnd_file.log,'Onhand balance has flipped from -ve to +ve. Setting onhand qty to residual qty');
                END IF;

                UPDATE gmf_lot_costs
                SET    onhand_qty = l_residual_qty
                WHERE  header_id = (SELECT max(header_id)
                                    FROM   gmf_lot_costs
                                    WHERE organization_id = transaction_row.orgn_id
                                    AND lot_number = transaction_row.lot_number)
                RETURNING header_id INTO new_cost.header_id;

                -- B3486228 Also set the transaction qty to the residual
                UPDATE gmf_material_lot_cost_txns
                   SET    new_onhand_qty = l_residual_qty
                 WHERE  transaction_id = transaction_row.transaction_id /* ANTHIYAG Bug#5285726 07-Jun-2006 */
                  AND   cost_header_id = new_cost.header_id;
              END IF;
            END IF;

            -- For anything other than production transactions we can
            -- set the rows to 'costed'. 'PROD' transactions are dealt with
            -- in their own procedure above

            IF  l_return_status = 'S' THEN
              IF l_final_run_flag = 1	THEN -- umoogala  05-Dec-2003
                IF transaction_row.source = 1 THEN
                  IF (transaction_row.transaction_source_type_id <> 5
                    OR (transaction_row.transaction_source_type_id = 5  /* ingredients, by products and reversals for products */
                    AND (transaction_row.line_type in (-1,2)
                    OR (transaction_row.line_type = 1
                    AND transaction_row.trans_qty < 0
                    AND transaction_row.reverse_id IS NOT NULL
                    )
                     )
                   ))
                     -- the lot_Costed_ind to 1 in the process_batch for reversal transactions.
                     -- So after Final Run, inv_tran_cursor returns the reversal transaction rows
                     -- of the PRODUCT. To solve, this added another condition as
                     --  if line_type is product and the tran_qty is negative then set the lot_costed_ind to 1.
                THEN
                  -- INVCONV sschinch uncommet if we have this column approved
                  /*
                  UPDATE mtl_material_lot_numbers
                  SET    lot_costed_ind	         = 1
                  WHERE  transaction_id = transaction_row.transaction_id
                   AND  lot_number = transaction_row.lot_number;
                  */
                  NULL;
                END IF;
              ELSE
                -- This is a lot cost adjustment (source is 3)
                -- This is a lot cost adjustment (source is 3)
                -- PK Bug 6697946 If old_cost.header_id is NULL Use new_cost.header_id
                IF   l_debug_level >= l_debug_level_high THEN
                  fnd_file.put_line
                 (fnd_file.log,'FINAL Mode old '||old_cost.header_id||' new '||new_cost.header_id||' Onhand '||new_cost.onhand_qty||' adj '||transaction_row.doc_id);
                END IF;
                UPDATE gmf_lot_cost_adjustments
                SET  applied_ind = 'Y',
          		       old_cost_header_id = NVL(old_cost.header_id, new_cost.header_id),
		                 new_cost_header_id = new_cost.header_id,
		                 onhand_qty	  = new_cost.onhand_qty
                WHERE  adjustment_id = transaction_row.doc_id;
              END IF;

              UPDATE gmf_lot_costs
              SET    final_cost_flag = 1
              WHERE  header_id = new_cost.header_id;
            ELSE
	   	    	  IF transaction_row.source = 3 THEN
	   	    	    -- PK Bug 6697946 If old_cost.header_id is NULL Use new_cost.header_id
                            IF   l_debug_level >= l_debug_level_high THEN
                                fnd_file.put_line
                                (fnd_file.log,'TEST Mode old '||old_cost.header_id||' new '||new_cost.header_id||' Onhand '||new_cost.onhand_qty||' adj '||transaction_row.doc_id);
                            END IF;
			          UPDATE gmf_lot_cost_adjustments
			             SET  old_cost_header_id = NVL(old_cost.header_id, new_cost.header_id),
			                  new_cost_header_id = new_cost.header_id,
			                  onhand_qty	  = new_cost.onhand_qty
			            WHERE adjustment_id = transaction_row.doc_id;
		          END IF;
            END IF;
            COMMIT;
          ELSE
            -- Add this lot to the list of lots that can't be costed
            fnd_file.put_line(fnd_file.log,'WARNING: Setting Lot for the orgn/Item/Lot '||transaction_row.orgn_id||'/'||transaction_row.inventory_item_id||'/'||transaction_row.lot_number||' as uncostable');
            l_uncostable_lots_tab(transaction_row.orgn_id||'-'||transaction_row.inventory_item_id||'-'||transaction_row.lot_number) := transaction_row.inventory_item_id;
            l_tmp := FALSE;
	          l_return_code := 'F';
            ROLLBACK TO SAVEPOINT inv_tran;
          END IF;

         ELSE
             IF   l_debug_level >= l_debug_level_high THEN
                fnd_file.put_line(fnd_file.log,' Current orgn/Item/Lot '||transaction_row.orgn_id||'/'||transaction_row.inventory_item_id||'/'||transaction_row.lot_number||' is Not Costable');
                fnd_file.put_line(fnd_file.log,' So skipping the transaction: '||transaction_row.transaction_id);
              END IF;
         END IF; -- skip this txn
        <<DONT_PROCESS_WIPBATCH>>
        FETCH inv_tran_cursor INTO transaction_row;
      END LOOP;
      CLOSE inv_tran_cursor;


      IF l_return_code = 'F' OR l_tmp = FALSE THEN
        l_tmp := fnd_concurrent.set_completion_status('WARNING','Errors found during processing.'||
			' Please check the log file for details.');
      ELSE
        l_tmp := fnd_concurrent.set_completion_status('NORMAL','Process completed successfully.');
      END IF;

      fnd_file.put_line
      (fnd_file.log,'Lot Cost Rollup finished at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
      COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR: '||substr(sqlerrm,1,100) || ' in ' || procedure_name);
      l_tmp := fnd_concurrent.set_completion_status('ERROR',sqlerrm || ' in ' || procedure_name);
      ROLLBACK;
  END rollup_lot_costs;
END GMF_LOT_COSTING_PUB;

/
