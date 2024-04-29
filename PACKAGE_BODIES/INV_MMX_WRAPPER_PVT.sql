--------------------------------------------------------
--  DDL for Package Body INV_MMX_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MMX_WRAPPER_PVT" AS
/* $Header: INVMMXWB.pls 120.6 2008/03/01 11:05:46 gjyoti ship $ */

   -- Package variable to store move order line grouping.
   G_MO_LINE_GROUPING NUMBER     := 1;  -- one move order header per execution.

   -- Package variable to store current subinventory being planned.
   G_CURRENT_SUBINV VARCHAR2(10) := NULL;

   -- Package variables to store current move order header ID and Line Number.
   G_CURRENT_MO_HDR_ID NUMBER    := NULL;
   G_CURRENT_MO_LINE_NUM NUMBER  := NULL;

   --
   -- Find the user name, INV debug profile setting
   --

   G_USER_NAME fnd_user.user_name%TYPE := FND_GLOBAL.USER_NAME;
   G_TRACE_ON NUMBER                   := NVL(fnd_profile.value('INV_DEBUG_TRACE'),2);


PROCEDURE print_debug
( p_message        IN  VARCHAR2
, p_module         IN  VARCHAR2
, p_level          IN  NUMBER
) IS
BEGIN
     inv_log_util.trace( G_USER_NAME||':  '||p_message,G_PKG_NAME||'.'||p_module||'($Revision: 120.6 $)',p_level);

EXCEPTION
  WHEN OTHERS THEN
     NULL;
END print_debug;


/*
** ---------------------------------------------------------------------------
** Procedure    : exec_min_max
**
** Description  : This procedure is called from both the min-max planning report
**                as well as the Oracle Spares Management Applications.
**
**                1) It performs most of the validations that were previously done
**                   in the BEFORE-REPORT trigger of the min-max report report.
**                2) Initializes the package variables for move order line consolidation,
**                   current subinventory being planned and current move order header ID
**                   and line Number.
**                3) Loops through the passed in array of subinventories and calls
**                   the existing INV_Minmax_PVT.run_min_max_plan API when
**                   doing sub-level planning for more than one subinventory.
**                4) After report is complete,submit FND request for WIP Mass Load
**                   which was previously done in AFTER-REPORT trigger of the min-max report.
**
** Input Parameters:
**
**  p_organization_id
**         Identifier of organization for which Min Max planning is to be done.
**  p_user_id
**         Identifier of the User performinng the Min Max planning.
**  p_subinv_tbl
**         Set of Subinventories for which Min Max planning is to be done.
**         Min-Max report will pass in a table with only one record since
**         planning for a set of subinventories from the INV UI is not supported .
**         Oracle Spares Management Applications will pass in a table with all the
**         subinventories that need to be planned.
**         If no table is passed in and sub level planning is being done,
**         then plan for all valid subinventories (that have at least one item set up
**         for min-max planning on the item-subinventory form in the org).
**  p_employee_id
**         Identifier of the Employee associated with the User.
**         Deafult value is NULL.
**  p_gen_report
**         Parameter to turn off report output generation (for Spares).
**         Default value is 'N'.
**  p_mo_line_grouping
**         Parameter to Control the number of move order headers created.
**         A value of 1 (one) denotes "one move order header per execution"
**         whereas a value of 2 stands for
**         "one move order header for each planned subinventory".
**         Defualt Value is 1.
**  p_item_select
**         Item Number.
**         Default Value is NULL.
**  p_handle_rep_item
**         Parameter for Repetitive item handling.
**         1- Create Requistion
**         2- Create Discrete Job
**         3- Do not Restock ,ie Report Only.
**         Default Value is 3.
**  p_pur_revision
**         Parameter for Purchasing by Revision.
**         Used for Revision controlled items.
**         It can be 'Yes' or 'No' or NULL.
**         Default value is NULL.
**  p_cat_select
**         Item Category.
**         Defualt value is 'NULL'
**  p_cat_set_id
**         Category Set Id.
**         Default value is NULL.
**  p_mcat_struct
**         Category Structure Number.
**         Default value is NULL.
**  p_level
**         Min Max Planning Level.
**         1-Organization
**         2-Subinventory
**         Default value is 2.
**  p_restock
**         Restocking is required or not.
**         If Restock is No, only the report will be generated and
**         no replenishment will happen.
**         Default value is 1.
**  p_include_nonnet
**         Include Non-netable Subinventories or not.
**         Default value is 1.
**  p_include_po
**         Include PO as Supply or not.
**         Default value is 1.
**  p_include_mo   -- Added for Bug 3057273
**         Include Move Orders as Supply or not.
**         Default value is 1.
**  p_include_wip
**         Include WIP as Supply or not.
**         Default value is 2.
**  p_include_if
**         Include Interface as Supply or not.
**         Default value is 1.
**  p_net_rsv
**         Inlclude Reserved Orders as Demands or not.
**         Default value is 1.
**  p_net_unrsv
**         Inlclude Unreserved Orders as Demands or not.
**         Default value is 1.
**  p_net_wip
**         Inlclude WIP Jobs as Demands or not.
**         Default value is 2.
**  p_dd_loc_id
**         Default Delivery To Location Id of the Planning Org.
**         Default value is NULL.
**  p_buyer_hi
**         Buyer Name From.
**         Default value is NULL.
**  p_buyer_lo
**         Buyer Name To.
**         Default value is NULL.
**  p_range_buyer
**         Where clause for Range of Buyers.
**         Default Value is '1 = 1'.
**  p_range_sql
**         Where clause for Range of Items,Categories and Planners.
**         Default Value is '1 = 1'.
**  p_sort
**         Min Max Report Sort By Criteria.
**         1-Inventory Item
**         2-Category
**         3-Planner
**         4-Buyer
**         Default Value is 1.
**  p_selection
**         Parameter for Min Max planned Item selection criteria.
**         1- Min Max planned Items under minimum Qty.
**         2- Min Max planned Items over minimum Qty.
**         3- All Min Max planned Items.
**         Deafualt value is 3.
**  p_sysdate
**         Current System Date.
**         Default Value is sysdate.
**  p_s_cutoff
**        Supply Cut Off Date.
**        Default Value is NULL.
**  p_d_cutoff
**        Demand Cut Off Date.
**        Default Value is NULL.
**
** Output Parameters:
**
**  x_return_status
**        Return status indicating success, error or unexpected error.
**  x_msg_count
**        Number of messages in the message list.
**  x_msg_data
**        If the number of messages in message list is 1, contains
**        message text.
**
** ---------------------------------------------------------------------------
*/

PROCEDURE exec_min_max
( x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, p_organization_id   IN  NUMBER
, p_user_id           IN  NUMBER
, p_subinv_tbl        IN  SubInvTableType
, p_employee_id       IN  NUMBER
, p_gen_report        IN  VARCHAR2
, p_mo_line_grouping  IN  NUMBER
, p_item_select       IN  VARCHAR2
, p_handle_rep_item   IN  NUMBER
, p_pur_revision      IN  NUMBER
, p_cat_select        IN  VARCHAR2
, p_cat_set_id        IN  NUMBER
, p_mcat_struct       IN  NUMBER
, p_level             IN  NUMBER
, p_restock           IN  NUMBER
, p_include_nonnet    IN  NUMBER
, p_include_po        IN  NUMBER
, p_include_mo        IN  NUMBER
, p_include_wip       IN  NUMBER
, p_include_if        IN  NUMBER
, p_net_rsv           IN  NUMBER
, p_net_unrsv         IN  NUMBER
, p_net_wip           IN  NUMBER
, p_dd_loc_id         IN  NUMBER
, p_buyer_hi          IN  VARCHAR2
, p_buyer_lo          IN  VARCHAR2
, p_range_buyer       IN  VARCHAR2
, p_range_sql         IN  VARCHAR2
, p_sort              IN  VARCHAR2
, p_selection         IN  NUMBER
, p_sysdate           IN  DATE
, p_s_cutoff          IN  DATE
, p_d_cutoff          IN  DATE
)  IS

l_proc CONSTANT    VARCHAR2(30) := 'EXEC_MIN_MAX';
l_pur_revision     NUMBER;
l_cat_set_id       NUMBER;
l_mcat_struct      NUMBER;
l_employee_id      NUMBER;
l_include_no_net   NUMBER;
l_dd_loc_id        NUMBER;
l_approval         NUMBER;
l_range_buyer      VARCHAR2(600);       -- For Bug #2815313, changed the width from 100 to 600
l_cust_id          NUMBER;
l_site_use_id      NUMBER;
l_po_org_id        NUMBER;
l_operating_unit   NUMBER;
l_order_by         VARCHAR2(20);
l_encum_flag       VARCHAR2(1);
l_cal_code         VARCHAR2(10);
l_exception_set_id NUMBER;
l_item_select      VARCHAR2(300);
l_cat_select       VARCHAR2(300);
l_gen_report       VARCHAR2(1);
l_sysdate          DATE;
l_s_cutoff         DATE;
l_d_cutoff         DATE;
l_valid            NUMBER;
l_wip_batch_id     NUMBER;
l_count            NUMBER := 0;
l_bulk_fetch_limit NUMBER := 100;
l_subinv_tbl       SubInvTableType;
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(1000);
l_warn             Varchar2(1) := 'S';  --Bug 4681032
/* Added for Bug 6807835 */
l_reqid            NUMBER := NULL;
l_osfm_batch_id    NUMBER;
l_job_count        NUMBER := 0;
/* End of Changes for Bug 6807835 */


--
-- Cursor for retrieving the list of subinventories for min-max planning,
-- if no subinventory is passed in the parameter p_subinv_tbl.
--
CURSOR c_subinv (cp_org_id  IN  NUMBER) IS
  SELECT secondary_inventory_name
  FROM mtl_secondary_inventories  msi
  WHERE msi.organization_id = cp_org_id
  AND EXISTS
  (  SELECT 1
     FROM mtl_item_sub_inventories  misi
     WHERE misi.organization_id       = msi.organization_id
     AND misi.secondary_inventory     = msi. secondary_inventory_name
     AND misi.inventory_planning_code = 2
  );

BEGIN
   SAVEPOINT  sp_exec_min_max;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF G_TRACE_ON = 1 THEN
   print_debug('Starting Min-max planning with the following parameters: '  || fnd_global.local_chr(10)||
                     '  p_organization_id: '  || to_char(p_organization_id) || fnd_global.local_chr(10)||
                     ', p_user_id: '          || to_char(p_user_id)         || fnd_global.local_chr(10)
                     , l_proc
                     , 9);

   FOR i in 1..p_subinv_tbl.count
   LOOP

      print_debug(', p_subinv('|| i ||'): '   || p_subinv_tbl(i)            || fnd_global.local_chr(10)
                   , l_proc
                   , 9);
   END LOOP;

   print_debug('Parameters contd..: '         || fnd_global.local_chr(10)||
                     '  p_employee_id: '      || to_char(p_employee_id)     || fnd_global.local_chr(10)||
                     ', p_gen_report:'        || p_gen_report               || fnd_global.local_chr(10)||
                     ', p_mo_line_grouping:'  || p_mo_line_grouping         || fnd_global.local_chr(10)||
                     ', p_item_select: '      || p_item_select              || fnd_global.local_chr(10)||
                     ', p_handle_rep_item: '  || to_char(p_handle_rep_item) || fnd_global.local_chr(10)||
                     ', p_pur_revision: '     || to_char(p_pur_revision)    || fnd_global.local_chr(10)||
                     ', p_cat_select: '       || p_cat_select               || fnd_global.local_chr(10)||
                     ', p_cat_set_id: '       || to_char(p_cat_set_id)      || fnd_global.local_chr(10)||
                     ', p_mcat_struct: '      || to_char(p_mcat_struct)     || fnd_global.local_chr(10)||
                     ', p_level: '            || to_char(p_level)           || fnd_global.local_chr(10)||
                     ', p_restock: '          || to_char(p_restock)         || fnd_global.local_chr(10)||
                     ', p_include_nonnet: '   || to_char(p_include_nonnet)  || fnd_global.local_chr(10)||
                     ', p_include_po: '       || to_char(p_include_po)      || fnd_global.local_chr(10)||
                     ', p_include_mo: '       || to_char(p_include_mo)      || fnd_global.local_chr(10)||
                     ', p_include_wip: '      || to_char(p_include_wip)     || fnd_global.local_chr(10)||
                     ', p_include_if: '       || to_char(p_include_if)      || fnd_global.local_chr(10)
                     , l_proc
                     , 9);

   print_debug('Parameters contd..: '         || fnd_global.local_chr(10)||
                     '  p_net_rsv: '          || to_char(p_net_rsv)         || fnd_global.local_chr(10)||
                     ', p_net_unrsv: '        || to_char(p_net_unrsv)       || fnd_global.local_chr(10)||
                     ', p_net_wip: '          || to_char(p_net_wip)         || fnd_global.local_chr(10)||
                     ', p_dd_loc_id: '        || to_char(p_dd_loc_id)       || fnd_global.local_chr(10)||
                     ', p_buyer_hi: '         || p_buyer_hi                 || fnd_global.local_chr(10)||
                     ', p_buyer_lo: '         || p_buyer_lo                 || fnd_global.local_chr(10)||
                     ', p_range_buyer: '      || p_range_buyer              || fnd_global.local_chr(10)||
                     ', p_range_sql: '        || p_range_sql                || fnd_global.local_chr(10)||
                     ', p_sort: '             || p_sort                     || fnd_global.local_chr(10)||
                     ', p_selection: '        || to_char(p_selection)       || fnd_global.local_chr(10)||
                     ', p_sysdate: '          || to_char(p_sysdate,  'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10)||
                     ', p_s_cutoff: '         || to_char(p_s_cutoff, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10)||
                     ', p_s_cutoff: '         || to_char(p_s_cutoff, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10)||
                     ', p_d_cutoff: '         || to_char(p_d_cutoff, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10)
                     , l_proc
                     , 9);
   END IF;

   --
   -- If the value of P_PUR_REVISION has not been initialized, set it to 'No'.
   --
   l_pur_revision := NVL(P_PUR_REVISION,NVL(fnd_profile.value('INV_PURCHASING_BY_REVISION'),2)) ;
   IF G_TRACE_ON = 1 THEN
      print_debug('Profile PUR_REVISION is: ' || l_pur_revision
                 ,l_proc
                 , 9);
   END IF;

   --
   -- Validate category set and MCAT struct
   --
   IF P_CAT_SET_ID IS NOT NULL THEN
          l_cat_set_id := P_CAT_SET_ID;
          IF P_MCAT_STRUCT IS NULL THEN
              BEGIN
                  SELECT STRUCTURE_ID
                  INTO   l_mcat_struct
                  FROM   MTL_CATEGORY_SETS
                  WHERE  CATEGORY_SET_ID = P_CAT_SET_ID;
              EXCEPTION
               WHEN no_data_found THEN
                  IF G_TRACE_ON = 1 THEN
                  print_debug('Exception: No category set exists for the passed Category set ID:'|| P_CAT_SET_ID
                             ,l_proc
                             , 9);
                  END IF;
                  RAISE  fnd_api.g_exc_error;
              END;
          ELSE
              l_mcat_struct := P_MCAT_STRUCT;
          END IF;
   ELSE
          BEGIN
            SELECT CSET.CATEGORY_SET_ID, CSET.STRUCTURE_ID
            INTO   l_cat_set_id,l_mcat_struct
            FROM   MTL_CATEGORY_SETS CSET,
                   MTL_DEFAULT_CATEGORY_SETS DEF
            WHERE  DEF.CATEGORY_SET_ID = CSET.CATEGORY_SET_ID
            AND    DEF.FUNCTIONAL_AREA_ID = 1;
          EXCEPTION
            WHEN no_data_found THEN
              IF G_TRACE_ON = 1 THEN
              print_debug('Exception: No default category set exists'
                          ,l_proc
                          , 9);
              END IF;
              RAISE  fnd_api.g_exc_error;
          END;

   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('CAT_SET_ID and MCAT_STRUCT are: ' || l_cat_set_id ||','|| l_mcat_struct
              ,l_proc
              , 9);
   END IF;

   --
   -- Get the Employee Id from the passed in User ID.
   --
   IF P_EMPLOYEE_ID IS NULL THEN
        BEGIN
            SELECT EMPLOYEE_ID
            INTO   l_employee_id
            FROM   FND_USER
            WHERE  USER_ID = P_USER_ID;
        EXCEPTION
         WHEN no_data_found THEN
           IF G_TRACE_ON = 1 THEN
           print_debug('Exception: No Employee Exists for the passed in User Id: '|| P_USER_ID
                       ,l_proc
                       , 9);
           END IF;
           RAISE  fnd_api.g_exc_error;
        END;
   ELSE
        l_employee_id := P_EMPLOYEE_ID;
   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('EMPLOYEE_ID is: ' || l_employee_id
              , l_proc
              , 9);
   END IF;

   --
   -- In case ,planning level is Subinventory, non-netable is always 'Yes'.
   --
   IF P_LEVEL = 2 THEN
      l_include_no_net := 1;
   ELSE
      l_include_no_net := P_INCLUDE_NONNET;
   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('INCLUDE_NO_NET is: ' || l_include_no_net
               ,l_proc
               , 9);
   END IF;

   --
   -- Set the Default value for Delivery To Location of the Planning Org,if it is null.
   --
   IF P_DD_LOC_ID IS NULL AND P_RESTOCK=1 THEN
  --Bug 3942423 added p_restock=1 condition as it is not required in case of p_restock=2
  -- and using p_organization_id parameter rather than MFG_ORGANIZATION_ID
        BEGIN
             SELECT LOC.LOCATION_ID
             INTO   l_dd_loc_id
             FROM   HR_ORGANIZATION_UNITS ORG,HR_LOCATIONS LOC
             WHERE  ORG.ORGANIZATION_ID = nvl(p_organization_id,-1)
             AND    ORG.LOCATION_ID = LOC.LOCATION_ID;
        EXCEPTION
         WHEN no_data_found THEN
              IF G_TRACE_ON = 1 THEN
              print_debug('Exception: No Default Delivery To Location Exists'
                          , l_proc
                          , 9);
              END IF;
           RAISE  fnd_api.g_exc_error;
        END;
   ELSE
        l_dd_loc_id := P_DD_LOC_ID;
   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('DD_LOC_ID is: ' || l_dd_loc_id
               ,l_proc
               , 9);
   END IF;

   --
   -- From now onwards, Move Orders should also honor
   -- the profile value set at the  profile "INV: Minmax Reorder Approval"
   -- This profile can have 3 values:
   -- (Lookup Type 'MTL_REQUISITION_APPROVAL' defined in MFG_LOOKUPS)
   --  1- Pre-approve d
   --  2- Pre-approve move orders only
   --  3- Approval Required
   --
   l_approval := to_number(nvl(FND_PROFILE.VALUE('INV_MINMAX_REORDER_APPROVED'),'2'));
   IF G_TRACE_ON = 1 THEN
   print_debug('APPROVAL STATUS is: ' || l_approval
               ,l_proc
               , 9);
   END IF;

   --
   -- Construct the BUYER Range WHERE Clause.
   -- Bug#3248005 - Buyer range where clause modified

   --IF P_RANGE_BUYER IS NULL THEN
        IF P_BUYER_LO IS NOT NULL AND P_BUYER_HI IS NOT NULL THEN
          l_range_buyer := 'V.FULL_NAME BETWEEN ' ||''''||P_BUYER_LO||'''' || ' AND ' ||''''||P_BUYER_HI||'''';
        ELSIF P_BUYER_LO IS NOT NULL THEN
          l_range_buyer := 'V.FULL_NAME >= ' ||''''||P_BUYER_LO||'''';
        ELSIF P_BUYER_HI IS NOT NULL THEN
          l_range_buyer := 'V.FULL_NAME <= ' ||''''||P_BUYER_HI||'''';
        ELSE
          l_range_buyer := '1 = 1';
        END IF;
  /* ELSE
        l_range_buyer := P_RANGE_BUYER;
   END IF; */

   IF G_TRACE_ON = 1 THEN
   print_debug('RANGE_BUYER WHERE Clause is: ' || l_range_buyer
               ,l_proc
               , 9);
   END IF;


   --
   --  Get the Operating Unit,Org Name etc.,
   --
   BEGIN
        SELECT OPERATING_UNIT, OPERATING_UNIT
        INTO   l_operating_unit, l_po_org_id
        FROM   ORG_ORGANIZATION_DEFINITIONS
        WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID;
   EXCEPTION
      WHEN no_data_found  THEN
         IF G_TRACE_ON = 1 THEN
         print_debug('Exception: Organization Id '|| P_ORGANIZATION_ID ||' Passed in is invalid'
                     , l_proc
                     , 9);
         END IF;
         RAISE  fnd_api.g_exc_error;
   END;
   IF G_TRACE_ON = 1 THEN
   print_debug('Operating Unit is: ' || l_operating_unit
               ,l_proc
               , 9);
   END IF;

   --
   --  Get the customer Id.
   --

   -- MOAC : change from PO_LOCATION_ASSOCIATIONS table to PO_LOCATION_ASSOCIATIONS_ALL
   --Bug :4968383 Added condition org_id=l_operating_unit to fetch the customer details
   --     of the CURRENT operating unit in which the Min-Max report is requested.

   BEGIN
        SELECT CUSTOMER_ID,SITE_USE_ID
        INTO   l_cust_id,l_site_use_id
        FROM   PO_LOCATION_ASSOCIATIONS_ALL
        WHERE  LOCATION_ID = l_dd_loc_id
          AND org_id=l_operating_unit;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_site_use_id := NULL;
        l_cust_id     := NULL;
   END;
   IF (P_RESTOCK = 1) AND (l_site_use_id IS NULL OR l_cust_id IS NULL)  THEN
       IF G_TRACE_ON = 1 THEN
       print_debug('Exception: No Customer Set up has been done for the Delivery Location Id: '|| l_dd_loc_id
                   ,l_proc
                   , 9);
       END IF;
   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('CUSTOMER ID and SITE USE ID are: ' || l_cust_id ||','|| l_site_use_id
               ,l_proc
               , 9);
   END IF;


   --
   -- Set order by clause.
   --
   IF P_SORT = 1 OR P_SORT IS NULL THEN
      l_order_by := ' ORDER BY 1';
   ELSIF P_SORT = 2  THEN
      l_order_by := ' ORDER BY 14,1';
   ELSIF P_SORT = 3  THEN
      l_order_by := ' ORDER BY 12,1';
   ELSIF P_SORT = 4  THEN
      l_order_by := ' ORDER BY 13,1';
   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('ORDER BY Clause is: ' || l_order_by
               ,l_proc
               , 9);
   END IF;

   --
   -- Set the Encumbrance Flag.
   --
   BEGIN
        SELECT NVL(REQ_ENCUMBRANCE_FLAG, 'N')
        INTO   l_encum_flag
        FROM   FINANCIALS_SYSTEM_PARAMS_ALL
        WHERE  NVL(ORG_ID,-11) = NVL(l_operating_unit,-11);
   EXCEPTION
      WHEN no_data_found THEN
        IF G_TRACE_ON = 1 THEN
        print_debug('Exception: No Encumbrance setup has been done for Organization Id '|| P_ORGANIZATION_ID ||' Passed'
                     , l_proc
                     , 9);
        END IF;
        RAISE  fnd_api.g_exc_error;
   END;
   IF G_TRACE_ON = 1 THEN
   print_debug('Encumbrance Flag is: ' || l_encum_flag
               ,l_proc
               , 9);
   END IF;

   --
   -- Get calendar Code and Exception Set Id.
   --
   BEGIN
        SELECT P.CALENDAR_CODE, P.CALENDAR_EXCEPTION_SET_ID
        INTO   l_cal_code, l_exception_set_id
        FROM   MTL_PARAMETERS P
        WHERE  P.ORGANIZATION_ID = P_ORGANIZATION_ID;
   EXCEPTION
      WHEN no_data_found  THEN
        IF G_TRACE_ON = 1 THEN
        print_debug('Exception: Organization Id '||P_ORGANIZATION_ID||' Passed in does not exist'
                    ,l_proc
                    , 9);
        END IF;
        RAISE  fnd_api.g_exc_error;
   END;
   IF G_TRACE_ON = 1 THEN
   print_debug('Calendar Code and Exception Set Id are: ' || l_cal_code ||','|| l_exception_set_id
               ,l_proc
               , 9);
   END IF;

   --
   -- Set Item and Category if they are null.
   -- These values are used as select columns in the SQLs used in INV_MINMAX_PVT.run_min_max(),
   -- but not used elsewhere in that procedure.
   --
   l_item_select := NVL(P_ITEM_SELECT,('C.SEGMENT1'));
   l_cat_select  := NVL(P_CAT_SELECT,('B.SEGMENT1||B.SEGMENT2'));
   IF G_TRACE_ON = 1 THEN
   print_debug('Item and Category are: ' || l_item_select  ||','|| l_cat_select
              , l_proc
              , 9);
   END IF;

   --
   -- Validate P_SORT.
   --
   BEGIN
        SELECT 1
        INTO   l_valid
        FROM   MFG_LOOKUPS
        WHERE  LOOKUP_TYPE = 'MTL_MINMAX_RPT_SORT_BY'
        AND    LOOKUP_CODE = NVL(P_SORT,1);
   EXCEPTION
     WHEN no_data_found  THEN
        IF G_TRACE_ON = 1 THEN
        print_debug('Exception: The Lookup MTL_MINMAX_RPT_SORT_BY is not defined'
                    , l_proc
                    , 9);
        END IF;
        RAISE  fnd_api.g_exc_error;
   END;

   --
   -- Validate P_SELECTION.
   --
   BEGIN
        SELECT 1
        INTO   l_valid
        FROM   MFG_LOOKUPS
        WHERE  LOOKUP_TYPE = 'MTL_MINMAX_RPT_SEL'
        AND    LOOKUP_CODE = NVL(P_SELECTION,3);
   EXCEPTION
     WHEN no_data_found  THEN
        IF G_TRACE_ON = 1 THEN
        print_debug('Exception: The Lookup MTL_MINMAX_RPT_SEL is not defined'
                    , l_proc
                    , 9);
        END IF;
        RAISE  fnd_api.g_exc_error;
   END;

   --
   --  Set P_S_CUTOFF and P_D_CUTOFF to sysdate if they are null.
   --
   l_sysdate  :=  NVL(P_SYSDATE,SYSDATE);
   l_s_cutoff :=  NVL(P_S_CUTOFF,trunc(l_sysdate));
   l_d_cutoff :=  NVL(P_D_CUTOFF,trunc(l_sysdate));
   IF G_TRACE_ON = 1 THEN
   print_debug('Supply Cut-Off and Demand Cut-off Dates are: ' || l_s_cutoff ||','|| l_d_cutoff
              , l_proc
              , 9);
   END IF;

   --
   --  Set L_WIP_BATCH_ID to the next Sequence of WIP_JOB_SCHEDULE_INTERFACE_S.
   --
   BEGIN
        SELECT WIP_JOB_SCHEDULE_INTERFACE_S.NEXTVAL
        INTO l_wip_batch_id
        FROM SYS.DUAL;
   EXCEPTION
     WHEN no_data_found  THEN
        IF G_TRACE_ON = 1 THEN
        print_debug('Exception: WIP_JOB_SCHEDULE_INTERFACE_S.NEXTVAL is not defined'
                    , l_proc
                    , 9);
        END IF;
        RAISE  fnd_api.g_exc_error;
   END;
   IF G_TRACE_ON = 1 THEN
   print_debug('WIP Batch Id is: ' || l_wip_batch_id
               , l_proc
               , 9);
   END IF;


/* Added for Bug 6807835 */

  --
  --  Set L_OSFM_BATCH_ID to the next Sequence of WSM_LOT_JOB_INTERFACE_S.
  --

   BEGIN
        SELECT WSM_LOT_JOB_INTERFACE_S.NEXTVAL
        INTO l_osfm_batch_id
        FROM SYS.DUAL;
   EXCEPTION
     WHEN no_data_found  THEN
        IF G_TRACE_ON = 1 THEN
        print_debug('Exception: WSM_LOT_JOB_INTERFACE_S.NEXTVAL is not defined'
                    , l_proc
                    , 9);
        END IF;
        RAISE  fnd_api.g_exc_error;
   END;
   IF G_TRACE_ON = 1 THEN
   print_debug('OSFM Batch Id is: ' || l_osfm_batch_id
               , l_proc
               , 9);
   END IF;
/* End of Changes for Bug 6807835 */
   --
   -- Set P_GEN_REPORT to 'Y', if it is not 'N'.
   --
   IF P_GEN_REPORT <> 'N' THEN
       l_gen_report := 'Y';
   ELSE
      l_gen_report := 'N';
   END IF;
   IF G_TRACE_ON = 1 THEN
   print_debug('Generate Report is: ' || l_gen_report
              , l_proc
              , 9);
   END IF;

   --
   -- Initialize the Package variables.
   --
   G_MO_LINE_GROUPING    := NVL(P_MO_LINE_GROUPING,1) ;
   G_CURRENT_SUBINV      := NULL;
   G_CURRENT_MO_HDR_ID   := NULL;
   G_CURRENT_MO_LINE_NUM := NULL;

   --
   -- If planning level is sub level (2)then
   --     If P_SUBINV_TBL count is Zero then
   --         Open c_subinv, bulk fetch list of subs
   --         If no subs found, return an error: "No items have been set up for
   --         subinventory level min-max planning in this organization."
   --     End if;
   --     Loop through list of subs
   --        Call inv_minmax_pvt.run_min_max_plan for each sub.
   --     End loop;
   -- Else
   --    Call inv_minmax_pvt.run_min_max_plan for org level planning.
   -- End if;
   --
   IF P_LEVEL = 2 THEN
      IF  P_SUBINV_TBL.COUNT = 0 THEN
              OPEN c_subinv(P_ORGANIZATION_ID);
              FETCH c_subinv BULK COLLECT INTO l_subinv_tbl;
              CLOSE c_subinv;
              IF l_subinv_tbl.COUNT = 0 THEN
                 IF G_TRACE_ON = 1 THEN
                 print_debug('No items have been set up for subinventory level min-max planning in this organization.'
                             , l_proc
                             , 9);
                 END IF;
                 fnd_message.set_name('INV','INV_MINMAX_NO_ITEM_SETUP');
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
              END IF;
      ELSE
              l_subinv_tbl := p_subinv_tbl;

      END IF;

      FOR l_subinv_count IN 1..l_subinv_tbl.COUNT
      LOOP
         IF G_TRACE_ON = 1 THEN
            print_debug('Calling INV_Minmax_PVT.run_min_max_plan for subinventory level ' ||
                        'Min Max Planning with sub '||l_subinv_tbl(l_subinv_count)
                        ,l_proc
                        , 9);
         END IF;

         INV_Minmax_PVT.run_min_max_plan
         ( p_item_select       => l_item_select
         , p_handle_rep_item   => NVL(p_handle_rep_item,3)
         , p_pur_revision      => l_pur_revision
         , p_cat_select        => l_cat_select
         , p_cat_set_id        => l_cat_set_id
         , p_mcat_struct       => l_mcat_struct
         , p_level             => NVL(p_level,2)
         , p_restock           => NVL(p_restock,1)
         , p_include_nonnet    => l_include_no_net
         , p_include_po        => NVL(p_include_po,1)
         , p_include_mo        => NVL(p_include_mo,1)
         , p_include_wip       => NVL(p_include_wip,2)
         , p_include_if        => NVL(P_include_if,1)
         , p_net_rsv           => NVL(p_net_rsv,1)
         , p_net_unrsv         => NVL(p_net_unrsv,1)
         , p_net_wip           => NVL(p_net_wip,2)
         , p_org_id            => p_organization_id
         , p_user_id           => p_user_id
         , p_employee_id       => l_employee_id
         , p_subinv            => l_subinv_tbl(l_subinv_count)
         , p_dd_loc_id         => l_dd_loc_id
         , p_wip_batch_id      => l_wip_batch_id
         , p_approval          => l_approval
         , p_buyer_hi          => p_buyer_hi
         , p_buyer_lo          => p_buyer_lo
         , p_range_buyer       => l_range_buyer
         , p_cust_id           => l_cust_id
         , p_cust_site_id      => l_site_use_id
         , p_po_org_id         => l_po_org_id
         , p_range_sql         => NVL(p_range_sql,'1 = 1')
         , p_sort              => NVL(p_sort,1)
         , p_selection         => NVL(p_selection,3)
         , p_sysdate           => l_sysdate
         , p_s_cutoff          => l_s_cutoff
         , p_d_cutoff          => l_d_cutoff
         , p_order_by          => l_order_by
         , p_encum_flag        => l_encum_flag
         , p_cal_code          => l_cal_code
         , p_exception_set_id  => l_exception_set_id
         , p_gen_report        => l_gen_report
         , x_return_status     => l_return_status
         , x_msg_data          => l_msg_data
         , p_osfm_batch_id     => l_osfm_batch_id               /* Added for Bug 6807835 */
         );

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            l_warn := 'W'; --Bug 4681032
            IF G_TRACE_ON = 1 THEN
               print_debug('INV_Minmax_PVT.run_min_max_plan failed with unexpected error '||
                           'for subinventory '|| l_subinv_tbl(l_subinv_count) ||
                           'returning message: ' || l_msg_data
                           ,l_proc
                           , 9);
            END IF;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR  THEN
             l_warn := 'W'; --Bug 4681032
               IF G_TRACE_ON = 1 THEN
               print_debug('INV_Minmax_PVT.run_min_max_plan failed with expected error for subinventory '|| l_subinv_tbl(l_subinv_count) ||' returning message: ' || l_msg_data
                           ,l_proc
                           , 9);
               END IF;
          END IF;
      END LOOP;
   ELSE
      IF G_TRACE_ON = 1 THEN
      print_debug('Calling INV_Minmax_PVT.run_min_max_plan for Organization level Min Max Planning'
                  ,l_proc
                  , 9);
      END IF;

      INV_Minmax_PVT.run_min_max_plan
      ( p_item_select       => l_item_select
      , p_handle_rep_item   => NVL(p_handle_rep_item,3)
      , p_pur_revision      => l_pur_revision
      , p_cat_select        => l_cat_select
      , p_cat_set_id        => l_cat_set_id
      , p_mcat_struct       => l_mcat_struct
      , p_level             => NVL(p_level,2)
      , p_restock           => NVL(p_restock,1)
      , p_include_nonnet    => l_include_no_net
      , p_include_po        => NVL(p_include_po,1)
      , p_include_mo        => NVL(p_include_mo,1)
      , p_include_wip       => NVL(p_include_wip,2)
      , p_include_if        => NVL(P_include_if,1)
      , p_net_rsv           => NVL(p_net_rsv,1)
      , p_net_unrsv         => NVL(p_net_unrsv,1)
      , p_net_wip           => NVL(p_net_wip,2)
      , p_org_id            => p_organization_id
      , p_user_id           => p_user_id
      , p_employee_id       => l_employee_id
      , p_subinv            => NULL
      , p_dd_loc_id         => l_dd_loc_id
      , p_wip_batch_id      => l_wip_batch_id
      , p_approval          => l_approval
      , p_buyer_hi          => p_buyer_hi
      , p_buyer_lo          => p_buyer_lo
      , p_range_buyer       => l_range_buyer
      , p_cust_id           => l_cust_id
      , p_cust_site_id      => l_site_use_id
      , p_po_org_id         => l_po_org_id
      , p_range_sql         => NVL(p_range_sql,'1 = 1')
      , p_sort              => NVL(p_sort,1)
      , p_selection         => NVL(p_selection,3)
      , p_sysdate           => l_sysdate
      , p_s_cutoff          => l_s_cutoff
      , p_d_cutoff          => l_d_cutoff
      , p_order_by          => l_order_by
      , p_encum_flag        => l_encum_flag
      , p_cal_code          => l_cal_code
      , p_exception_set_id  => l_exception_set_id
      , p_gen_report        => l_gen_report
      , x_return_status     => l_return_status
      , x_msg_data          => l_msg_data
      , p_osfm_batch_id     => l_osfm_batch_id               /* Added for Bug 6807835 */
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
         IF G_TRACE_ON = 1 THEN
            print_debug('INV_Minmax_PVT.run_min_max_plan failed with unexpected error ' ||
                        'returning message: ' || l_msg_data
                        ,l_proc
                        , 9);
         END IF;
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
         IF G_TRACE_ON = 1 THEN
         print_debug('INV_Minmax_PVT.run_min_max_plan failed with expected error returning message: ' || l_msg_data
                     ,l_proc
                     , 9);
         END IF;
         RAISE fnd_api.g_exc_error;
      ELSE
         IF G_TRACE_ON = 1 THEN
         print_debug('INV_Minmax_PVT.run_min_max_plan returned success'
                    ,l_proc
                    , 9);
         END IF;

      END IF;

   END IF;


   --
   -- Submit the Concurrent Request for WIP Mass Load.
   --
   SELECT COUNT(*)
   INTO l_count
   FROM WIP_JOB_SCHEDULE_INTERFACE
   WHERE GROUP_ID = l_wip_batch_id;

   IF l_count > 0 THEN

      l_count := FND_REQUEST.SUBMIT_REQUEST('WIP', 'WICMLP',
                                NULL, NULL, FALSE,
                                TO_CHAR(l_wip_batch_id),
                                CHR(0), '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '', '', '',
                                '', '', '', '');
      COMMIT;
   END IF;


/* Added for Bug 6807835 */

   SELECT count(*)
   INTO l_job_count
   FROM WSM_LOT_JOB_INTERFACE
   WHERE GROUP_ID = l_osfm_batch_id;

   IF l_job_count > 0 THEN
      l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                                      application => 'WSM',
                                      program => 'WSMPLBJI',
                                      sub_request => FALSE,
                                      argument1 =>  l_osfm_batch_id);
      COMMIT;
   END IF;
/* End of Changes for Bug 6807835 */

   --Bug 4681032
   if x_return_status = FND_API.G_RET_STS_SUCCESS and l_warn='W' then
      x_return_status := 'W';
   end if;
   --Bug 4681032


EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO  sp_exec_min_max;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_exec_min_max;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

   WHEN OTHERS THEN
      ROLLBACK TO sp_exec_min_max;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)THEN
         fnd_msg_pub.add_exc_msg
                               ('INV_MMX_WRAPPER_PVT'
                                ,l_proc
                               );
     END IF;
     fnd_msg_pub.count_and_get
                             ( p_count => x_msg_count,
                               p_data  => x_msg_data
                             );

END exec_min_max;


/*
** ---------------------------------------------------------------------------
** Procedure    : do_restock
**
** Description  : This procedure is called from MRP's Reorder Point report.
**
**                1) Initializes the package variables for move order line consolidation,
**                   current subinventory being planned and current move order header ID
**                   and line Number.
**                2) Calls INV_Minmax_PVT.do_restock.
**
** Input Parameters:
**
**  p_item_id
**         Inventory Item Id of the Item to be replenished.
**  p_mbf
**         Make or Buy Flag of the Item to be replenished.
**  p_handle_repetitive_item
**         Parameter for Repetitive item handling.
**         1- Create Requistion
**         2- Create Discrete Job
**         3- Do not Restock ,ie Report Only.
**  p_repetitive_planned_item
**         Flag indicating whether item has to be planned as repetitive schedule.
**  p_qty
**         Quantity to be replenished.
**  p_fixed_lead_time
**         Fixed portion of the assembly Item's lead time.
**  p_variable_lead_time
**         Variable portion of the assembly Item's lead time.
**  p_buying_lead_time
**         Preprocessing Lead time + Full Lead Time of the Buy Item.
**  p_uom
**         Primary UOM of the Item.
**  p_accru_acct
**         Accrual Account of the Organization/Operating Unit.
**  p_ipv_acct
**         Invoice Process Varialbe Account.
**  p_budget_acct
**         Budget Account.
**  p_charge_acct
**         Charge Account.
**  p_purch_flag
**         Flag indicating if item may appear on outside operation purchase order.
**  p_order_flag
**         Flag indicating if item is internally orderable.
**  p_transact_flag
**         Flag indicating if item is transactable.
**  p_unit_price
**         Unit list price - purchasing.
**  p_wip_id
**         WIP Batch Id of WIP_JOB_SCHEDULE_INTERFACE.
**  p_user_id
**         Identifier of the User performinng the Min Max planning.
**  p_sysd
**         Current System Date.
**  p_organization_id
**         Identifier of organization for which Min Max planning is to be done.
**  p_approval
**         Approval status.
**         1-Incomplete.
**         7-pre-approved.
**  p_build_in_wip
**         Flag indicating if item may be built in WIP.
**  p_pick_components
**         Flag indicating whether all shippable components should be picked.
**  p_src_type
**         Source type for the Item.
**         1-Inventory.
**         2-Supplier.
**         3-Subinventory.
**  p_encum_flag
**         Encumbrance Flag.
**  p_customer_id
**         Customer Id.
**  p_customer_site_id
**         Customer Site Id. Default value is NULL.
**  p_cal_code
**         Calendar Code of the Organization.
**  p_except_id
**         Exception Set Id of the Organization.
**  p_employee_id
**         Identifier of the Employee associated with the User.
**  p_description
**         Description of the Item.
**  p_src_org
**         Organization to source items from.
**  p_src_subinv
**         Subinventory to source items from.
**  p_subinv
**         Subinventory to be replenished.
**  p_location_id
**         Default Delivery To Location Id of the Planning Org.
**  p_po_org_id
**         Operating Unit Id.
**  p_pur_revision
**         Parameter for Purchasing By Revision .
**         Used for Revision controlled items.
**  p_mo_line_grouping
**         Parameter to Control the number of move order headers created.
**         A value of 1(one) denotes "one move order header per execution"
**         whereas a value of 2 stands for
**         "one move order header for each planned subinventory".
**         Defualt Value is 1.
**
** Output Parameters:
**
**  x_return_status
**        Return status indicating success, error or unexpected error.
**  x_msg_count
**        Number of messages in the message list.
**  x_msg_data
**        If the number of messages in message list is 1, contains
**        message text.
**
** ---------------------------------------------------------------------------
*/

PROCEDURE do_restock
( x_return_status            OUT  NOCOPY VARCHAR2
, x_msg_count                OUT  NOCOPY NUMBER
, x_msg_data                 OUT  NOCOPY VARCHAR2
, p_item_id                  IN   NUMBER
, p_mbf                      IN   NUMBER
, p_handle_repetitive_item   IN   NUMBER
, p_repetitive_planned_item  IN   VARCHAR2
, p_qty                      IN   NUMBER
, p_fixed_lead_time          IN   NUMBER
, p_variable_lead_time       IN   NUMBER
, p_buying_lead_time         IN   NUMBER
, p_uom                      IN   VARCHAR2
, p_accru_acct               IN   NUMBER
, p_ipv_acct                 IN   NUMBER
, p_budget_acct              IN   NUMBER
, p_charge_acct              IN   NUMBER
, p_purch_flag               IN   VARCHAR2
, p_order_flag               IN   VARCHAR2
, p_transact_flag            IN   VARCHAR2
, p_unit_price               IN   NUMBER
, p_wip_id                   IN   NUMBER
, p_user_id                  IN   NUMBER
, p_sysd                     IN   DATE
, p_organization_id          IN   NUMBER
, p_approval                 IN   NUMBER
, p_build_in_wip             IN   VARCHAR2
, p_pick_components          IN   VARCHAR2
, p_src_type                 IN   NUMBER
, p_encum_flag               IN   VARCHAR2
, p_customer_id              IN   NUMBER
, p_customer_site_id         IN   NUMBER
, p_cal_code                 IN   VARCHAR2
, p_except_id                IN   NUMBER
, p_employee_id              IN   NUMBER
, p_description              IN   VARCHAR2
, p_src_org                  IN   NUMBER
, p_src_subinv               IN   VARCHAR2
, p_subinv                   IN   VARCHAR2
, p_location_id              IN   NUMBER
, p_po_org_id                IN   NUMBER
, p_pur_revision             IN   NUMBER
, p_mo_line_grouping         IN   NUMBER
)  IS
l_proc_name CONSTANT    VARCHAR2(30) := 'DO_RESTOCK';
l_return_status   VARCHAR2(1);
l_msg_data        VARCHAR2(100);
l_msg_count       NUMBER;

BEGIN
   SAVEPOINT  sp_do_restock;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Initialize the Package variables.
   --
   G_MO_LINE_GROUPING    := NVL(p_mo_line_grouping,1);
   G_CURRENT_SUBINV      := NULL;
   G_CURRENT_MO_HDR_ID   := NULL;
   G_CURRENT_MO_LINE_NUM := NULL;

   IF G_TRACE_ON = 1 THEN
   print_debug ('Executing do_restock with the following parameters: '                   || fnd_global.local_chr(10) ||
                    '  p_item_id '                  || to_char(p_item_id)                || fnd_global.local_chr(10) ||
                    ', p_mbf: '                     || to_char(p_mbf)                    || fnd_global.local_chr(10) ||
                    ', p_handle_repetitive_item: '  || to_char(p_handle_repetitive_item) || fnd_global.local_chr(10) ||
                    ', p_repetitive_planned_item: ' || p_repetitive_planned_item         || fnd_global.local_chr(10) ||
                    ', p_qty: '                     || to_char(p_qty)                    || fnd_global.local_chr(10) ||
                    ', p_fixed_lead_time: '         || to_char(p_fixed_lead_time)        || fnd_global.local_chr(10) ||
                    ', p_variable_lead_time: '      || to_char(p_variable_lead_time)     || fnd_global.local_chr(10) ||
                    ', p_buying_lead_time: '        || to_char(p_buying_lead_time)       || fnd_global.local_chr(10) ||
                    ', p_uom: '                     || p_uom                             || fnd_global.local_chr(10) ||
                    ', p_accru_acct: '              || to_char(p_accru_acct)             || fnd_global.local_chr(10) ||
                    ', p_ipv_acct: '                || to_char(p_ipv_acct)               || fnd_global.local_chr(10) ||
                    ', p_budget_acct: '             || to_char(p_budget_acct)            || fnd_global.local_chr(10)
                    ,  l_proc_name
                    , 9);

   print_debug ('Parameters Contd..'                || fnd_global.local_chr(10)          ||
                    '  p_charge_acct: '             || to_char(p_charge_acct)            || fnd_global.local_chr(10) ||
                    ', p_purch_flag: '              || p_purch_flag                      || fnd_global.local_chr(10) ||
                    ', p_order_flag: '              || p_order_flag                      || fnd_global.local_chr(10) ||
                    ', p_transact_flag: '           || p_transact_flag                   || fnd_global.local_chr(10) ||
                    ', p_unit_price: '              || to_char(p_unit_price)             || fnd_global.local_chr(10) ||
                    ', p_wip_id: '                  || to_char(p_wip_id)                 || fnd_global.local_chr(10) ||
                    ', p_user_id: '                 || to_char(p_user_id)                ||
                    ', p_sysd: '                    || to_char(p_sysd, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10) ||
                    ', p_organization_id: '         || to_char(p_organization_id)        || fnd_global.local_chr(10) ||
                    ', p_approval: '                || to_char(p_approval)               || fnd_global.local_chr(10) ||
                    ', p_build_in_wip: '            || p_build_in_wip                    || fnd_global.local_chr(10) ||
                    ', p_pick_components: '         || p_pick_components                 || fnd_global.local_chr(10) ||
                    ', p_src_type: '                || to_char(p_src_type)               || fnd_global.local_chr(10)
                    ,  l_proc_name
                    , 9);

   print_debug ('Parameters Contd..'                || fnd_global.local_chr(10)          ||
                    '  p_encum_flag: '              || p_encum_flag                      || fnd_global.local_chr(10) ||
                    ', p_customer_id: '             || to_char(p_customer_id)            || fnd_global.local_chr(10) ||
                    ', p_customer_site_id: '        || to_char(p_customer_site_id)       || fnd_global.local_chr(10) ||
                    ', p_cal_code: '                || p_cal_code                        || fnd_global.local_chr(10) ||
                    ', p_except_id: '               || to_char(p_except_id)              || fnd_global.local_chr(10) ||
                    ', p_employee_id: '             || to_char(p_employee_id)            || fnd_global.local_chr(10) ||
                    ', p_description: '             || p_description                     || fnd_global.local_chr(10) ||
                    ', p_src_org: '                 || to_char(p_src_org)                || fnd_global.local_chr(10) ||
                    ', p_src_subinv: '              || p_src_subinv                      || fnd_global.local_chr(10) ||
                    ', p_subinv: '                  || p_subinv                          || fnd_global.local_chr(10) ||
                    ', p_location_id: '             || to_char(p_location_id)            || fnd_global.local_chr(10) ||
                    ', p_po_org_id: '               || to_char(p_po_org_id)              || fnd_global.local_chr(10) ||
                    ', p_pur_revision: '            || to_char(p_pur_revision)           || fnd_global.local_chr(10) ||
                    ', p_mo_line_grouping '         || to_char(p_mo_line_grouping)       || fnd_global.local_chr(10)
                    ,  l_proc_name
                    , 9);
   print_debug('Calling INV_Minmax_PVT.do_restock'
                   , l_proc_name
                   , 9);
   END IF;

   INV_Minmax_PVT.do_restock( p_item_id                  => p_item_id
                            , p_mbf                      => p_mbf
                            , p_handle_repetitive_item   => p_handle_repetitive_item
                            , p_repetitive_planned_item  => p_repetitive_planned_item
                            , p_qty                      => p_qty
                            , p_fixed_lead_time          => p_fixed_lead_time
                            , p_variable_lead_time       => p_variable_lead_time
                            , p_buying_lead_time         => p_buying_lead_time
                            , p_uom                      => p_uom
                            , p_accru_acct               => p_accru_acct
                            , p_ipv_acct                 => p_ipv_acct
                            , p_budget_acct              => p_budget_acct
                            , p_charge_acct              => p_charge_acct
                            , p_purch_flag               => p_purch_flag
                            , p_order_flag               => p_order_flag
                            , p_transact_flag            => p_transact_flag
                            , p_unit_price               => p_unit_price
                            , p_wip_id                   => p_wip_Id
                            , p_user_id                  => p_user_id
                            , p_sysd                     => p_sysd
                            , p_organization_id          => p_organization_id
                            , p_approval                 => p_approval
                            , p_build_in_wip             => p_build_in_wip
                            , p_pick_components          => p_pick_components
                            , p_src_type                 => p_src_type
                            , p_encum_flag               => p_encum_flag
                            , p_customer_id              => p_customer_id
                            , p_customer_site_id         => p_customer_site_id
                            , p_cal_code                 => p_cal_code
                            , p_except_id                => p_except_id
                            , p_employee_id              => p_employee_id
                            , p_description              => p_description
                            , p_src_org                  => p_src_org
                            , p_src_subinv               => p_src_subinv
                            , p_subinv                   => p_subinv
                            , p_location_id              => p_location_id
                            , p_po_org_id                => p_po_org_id
                            , p_pur_revision             => p_pur_revision
                            , x_ret_stat                 => l_return_status
                            , x_ret_mesg                 => l_msg_data
                            );

   IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
      IF G_TRACE_ON = 1 THEN
      print_debug('INV_Minmax_PVT.do_restock failed with unexpected error returning message: ' || l_msg_data
                   , l_proc_name
                   , 9);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      IF G_TRACE_ON = 1 THEN
      print_debug('INV_Minmax_PVT.do_restock failed with expected error returning message: ' || l_msg_data
                  , l_proc_name
                  , 9);
      END IF;
      RAISE fnd_api.g_exc_error;
   ELSE
      IF G_TRACE_ON = 1 THEN
      print_debug('INV_Minmax_PVT.do_restock returned success'
                  , l_proc_name
                  , 9);
      END IF;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO sp_do_restock;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_do_restock;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

   WHEN OTHERS THEN
      ROLLBACK TO sp_do_restock;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)THEN
         fnd_msg_pub.add_exc_msg
                               (  G_PKG_NAME
                                , l_proc_name
                               );
     END IF;
     fnd_msg_pub.count_and_get
                             ( p_count => x_msg_count,
                               p_data  => x_msg_data
                             );
END do_restock;

/*
** ---------------------------------------------------------------------------
** Procedure    : get_move_order_info
** Description  : This procedure is called from INV_Minmax_PVT.do_restock to
**                get the move order header ID and move order line number ,
**                prior to creating a move order line.
**
**                1) It returns the header ID and line number of the existing Header,
**                   to be stamped on the move order line based on how consolidation
**                   is being done.
**                2) If a move order header does not exist, it creates one.
**
** Input Parameters:
**
**  p_user_id
**         Identifier of the User performinng the Min Max planning.
**  p_organization_id
**         Identifier of organization for which Min Max planning is to be done.
**  p_subinv
**         Subinventory Being Planned.
**  p_src_subinv
**         Subinventory to source items from.
**  p_approval
**         Approval status.
**         1-Incomplete.
**         7- pre-approved.
** p_need_by_date
**         Need By Date for the Move Order.
**
** Output Parameters:
**
**  x_return_status
**        Return status indicating success, error or unexpected error.
**  x_msg_count
**        Number of messages in the message list.
**  x_msg_data
**        If the number of messages in message list is 1, contains
**        message text.
**  x_move_order_header_ID
**        Header Id of the MO to be used.
**  x_move_order_line_num
**        Next Line number of the Move Order.
**
** ---------------------------------------------------------------------------
*/

PROCEDURE get_move_order_info
( x_return_status         OUT  NOCOPY VARCHAR2
, x_msg_count             OUT  NOCOPY NUMBER
, x_msg_data              OUT  NOCOPY VARCHAR2
, x_move_order_header_id  OUT  NOCOPY NUMBER
, x_move_order_line_num   OUT  NOCOPY NUMBER
, p_user_id               IN   NUMBER
, p_organization_id       IN   NUMBER
, p_subinv                IN   VARCHAR2
, p_src_subinv            IN   VARCHAR2
, p_approval              IN   NUMBER
, p_need_by_date          IN   DATE
) IS
l_proc_name CONSTANT    VARCHAR2(30) := 'GET_MOVE_ORDER_INFO';
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
l_trohdr_rec            INV_Move_Order_PUB.Trohdr_Rec_Type;
l_trohdr_val_rec        INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
l_x_trohdr_rec          INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trohdr_val_rec      INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
l_commit                VARCHAR2(1) := FND_API.G_FALSE;

BEGIN
    SAVEPOINT  sp_get_move_order_info;
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    IF G_TRACE_ON = 1 THEN
    print_debug ('Executing get_move_order_info with the following parameters: '         || fnd_global.local_chr(10) ||
                    '  p_user_id: '                 || to_char(p_user_id)                || fnd_global.local_chr(10) ||
                    ', p_organization_id: '         || to_char(p_organization_id)        || fnd_global.local_chr(10) ||
                    ', p_subinv: '                  || p_subinv                          || fnd_global.local_chr(10) ||
                    ', p_src_subinv: '              || p_src_subinv                      || fnd_global.local_chr(10) ||
                    ', p_approval: '                || to_char(p_approval)               || fnd_global.local_chr(10) ||
                    ', p_need_by_time: '            || to_char(p_need_by_date)           || fnd_global.local_chr(10)
                    , l_proc_name
                    , 9 );
    END IF;

    IF G_CURRENT_MO_HDR_ID IS NULL OR (G_MO_LINE_GROUPING = 2 AND  G_CURRENT_SUBINV <> p_subinv) THEN
     --
     -- Being called for the first time or (one move order per planning sub and the passed-in sub
     -- is different from the sub stored as package variable).
     --
        l_trohdr_rec.created_by                 :=   p_user_id;
        l_trohdr_rec.creation_date              :=   sysdate;
        l_trohdr_rec.date_required              :=   p_need_by_date;
        l_trohdr_rec.from_subinventory_code     :=   p_src_subinv;
        l_trohdr_rec.header_status              :=   p_approval;
        l_trohdr_rec.last_updated_by            :=   p_user_id;
        l_trohdr_rec.last_update_date           :=   sysdate;
        l_trohdr_rec.last_update_login          :=   p_user_id;
        l_trohdr_rec.organization_id            :=   p_organization_id;
        l_trohdr_rec.status_date                :=   sysdate;
        l_trohdr_rec.to_subinventory_code       :=   p_subinv;
        l_trohdr_rec.move_order_type            :=   INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT;
        l_trohdr_rec.transaction_type_id        :=   INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
        l_trohdr_rec.db_flag                    :=   FND_API.G_TRUE;
        l_trohdr_rec.operation                  :=   INV_GLOBALS.G_OPR_CREATE;
        IF G_TRACE_ON = 1 THEN
        print_debug('Calling INV_Move_Order_PUB.Create_Move_Order_Header'
                       , l_proc_name
                       , 9);
        END IF;
        INV_Move_Order_PUB.Create_Move_Order_Header(
                                                    p_api_version_number => 1,
                                                    p_init_msg_list      => FND_API.G_FALSE,
                                                    p_return_values      => FND_API.G_TRUE,
                                                    p_commit             => l_commit,
                                                    x_return_status      => l_return_status,
                                                    x_msg_count          => l_msg_count,
                                                    x_msg_data           => l_msg_data,
                                                    p_trohdr_rec         => l_trohdr_rec,
                                                    p_trohdr_val_rec     => l_trohdr_val_rec,
                                                    x_trohdr_rec         => l_x_trohdr_rec,
                                                    x_trohdr_val_rec     => l_x_trohdr_val_rec
                                                    );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF G_TRACE_ON = 1 THEN
           print_debug('INV_Move_Order_PUB.Create_Move_Order_Header failed with unexpected error returning message: ' || l_msg_data
                       , l_proc_name
                       , 9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF G_TRACE_ON = 1 THEN
           print_debug('INV_Move_Order_PUB.Create_Move_Order_Header failed with expected error returning message: ' || l_msg_data
                       , l_proc_name
                       , 9);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           IF G_TRACE_ON = 1 THEN
           print_debug('INV_Move_Order_PUB.Create_Move_Order_Header returned success with header Id: ' || l_x_trohdr_rec.header_id
                       , l_proc_name
                       , 9);
           END IF;
        END IF;


        G_CURRENT_MO_HDR_ID := l_x_trohdr_rec.header_id;
        G_CURRENT_MO_LINE_NUM := 0;

        IF G_MO_LINE_GROUPING = 2 THEN -- one move order per planning sub
           G_CURRENT_SUBINV := p_subinv;
        END IF;
    END IF;

   G_CURRENT_MO_LINE_NUM  := G_CURRENT_MO_LINE_NUM + 1;
   x_move_order_header_ID := G_CURRENT_MO_HDR_ID;
   x_move_order_line_num  := G_CURRENT_MO_LINE_NUM ;
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO sp_get_move_order_info;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO sp_get_move_order_info;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      fnd_msg_pub.count_and_get
                              ( p_count => x_msg_count,
                                p_data  => x_msg_data
                              );

   WHEN OTHERS THEN
      ROLLBACK TO sp_get_move_order_info;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)THEN
         fnd_msg_pub.add_exc_msg
                               (  G_PKG_NAME
                                , l_proc_name
                               );
     END IF;
     fnd_msg_pub.count_and_get
                             ( p_count => x_msg_count,
                               p_data  => x_msg_data
                             );

END get_move_order_info;


END INV_MMX_WRAPPER_PVT;

/
