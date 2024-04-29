--------------------------------------------------------
--  DDL for Package Body CST_MGD_MSTR_BOOK_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_MGD_MSTR_BOOK_RPT" AS
-- $Header: CSTGMBKB.pls 120.2.12010000.20 2009/11/11 20:15:38 vjavli ship $
--+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     CSTGMBKB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body for Inventory Master Book Report data generation             |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Insert_Rpt_Data                                                   |
--|     Get_Acct_Period_ID                                                |
--|     Get_Unit_Infl_Adj_Cost                                            |
--|     Get_Ini_Total_Infl                                                |
--|     get_item_txn_info                                                 |
--|     Create_Inv_Msbk_Rpt                                               |
--| *** Italy / China enhancements ***                                    |
--|     get_break_by                                                      |
--|     beforereport                                                      |
--|     get_abc_group_name                                                |
--|     getledger_name                                                    |
--|	--get_category_set_name                                           |
--|     get_shipment_num                                                  |
--|	get_include_cost	                                          |
--|     get_waybill                                                       |
--|	get_po_number                                                     |
--|     get_detail_level                                                  |
--|                                                                       |
--| HISTORY                                                               |
--|     07/16/1999 ksaini          Created from CSTRIADB.pls              |
--|     08/30/1999 ksaini          Remove ABC Class Name and Assignment   |
--|                                Group name from the temp table         |
--|     09/06/1999 ksaini          Modified Code for Subinventory Range   |
--|     08/19/2001 vjavli          Bug#1917957 to fix the wrong begin     |
--|                                quantity                               |
--|     10/04/2001 vjavli          Cost group id  NULL created as part of |
--|                                bug#1474753 fix; this is to support    |
--|                                CST_MGD_INFL_ADJUSTMENT_PVT.Get_Period_|
--|                                End_Avg_Cost                           |
--|     10/20/2001 fdubois         Two changes made :a) Begin On Hand Qty |
--|                                cannot be derived from                 |
--|                                MTL_PER_CLOSE_DTLS because the table is|
--|                                only used for Avg costing. Also the    |
--|                                datte_to and date_from can fall within |
--|                                open periods.                          |
--|                                b) Date_to changed to extend up to     |
--|                                23:59:59 of the day.                   |
--|                                Bug#2011340                            |
--|    01/28/2002 vjavli           WIP transactions should be excluded    |
--|                                Bug#2198569                            |
--|    01/30/2002 vjavli           excluded in procedures get_offset_qty  |
--|                                get_item_txn_info                      |
--|    07/11/2002 vjavli           Bug#2433926 fix no validation for      |
--|                                transaction type disable date          |
--|    09/18/2002 vjavli           Bug#2576310 to consider the sub        |
--|                                inventories while getting the begin    |
--|                                onhand quantity                        |
--|    19/11/2002 tsimmond         UTF8 : changed org_name size to 240    |
--|    02/14/2003 vjavli           Bug#2799104: Average Cost Update Trn   |
--|                                should be shown; filter logic of WIP   |
--|                                transaction modified for correction    |
--|    03/31/2003 vjavli           Bug#2865534 fix: Cosigned inventory    |
--|                                transactions to be eliminated          |
--|                                owning_tp_type = 1 for consigned trn   |
--|    05/23/2003 vjavli           Bug#2904882 fix: transaction_id added  |
--|                                temporary table inorder to get correct |
--|                                sort by transaction_date,              |
--|                                transaction_id                         |
--|    05/29/2003 vjavli           Bug#2977020 fix: ACU transactions not  |
--|                                being displayed - reason: primary_qty  |
--|                                is 0 ; verified in internal system for |
--|                                3 types of ACUs. In all 3 types the qty|
--|                                is not null                            |
--|                                Found that percentage and new avg cost |
--|                                to be supported                        |
--|                                primary_qty <> 0 condition removed in  |
--|                                get_item_txn_info                      |
--|   06/10/2003 vjavli            regression from bug#2904882 fix: sort  |
--|                                trunc(transaction_date), transaction_id|
--|                                get_item_txn_info cursor added with    |
--|                                order by trunc(transaction_date),      |
--|                                transaction_id bug#3002073 fix         |
--|   06/22/2003 vjavli            Bug#3013597 fix: cost type of the      |
--|                                organization is to be verified. If cost|
--|                                type is Standard then Begin Unit Cost  |
--|                                will be actual cost of very first txn  |
--|                                and End Unit Cost will be actual cost  |
--|                                of last txn.  If Cost Type is Average, |
--|                                LIFO, FIFO then Begin Unit Cost will be|
--|                                prior cost of very first txn and End   |
--|                                Unit Cost will be new cost of last txn |
--|                                in the report date range               |
--| 06/22/2003  vjavli             NOTE: Create_Infl_Adj_Rpt procedure    |
--|                                removed since it is not invoked by any |
--|                                of the inflation reports               |
--| 09/09/2003  fdubois            bug#3118846 : exclude NON qty tracked  |
--|                                subinventory transactions as the ON    |
--|                                HAND qty in Inventory does NOT account |
--|                                for these quantities.                  |
--| 09/10/2003  fdubois            code cleaning : removing unused API    |
--|                                get_offset_qty and related code (dead  |
--|                                code)                                  |
--| 10/02/2003  fdubois            bug#3147073 :exclude non asset items   |
--|                                and non asset subinventory  and        |
--|                                exclude expense items                  |
--| 05/12/2004  vjavli             Performance bug fix as in bug#2862480  |
--|                                for 11.5.9. Get_Acct_Period_Id and     |
--|                                Get_Acct_Period_Id_invmbk modified     |
--|                                NOTE:Get_Acct_Period_id and Get_Acct_  |
--|                                Period_Id_invmbk are not used anywhere |
--| 02/17/2006 vmutyala            Bug # 4086259 Added Creation_date to   |
--|                                CST_MGD_MSTR_BOOK_TEMP                 |
--| 02/24/2006 vmutyala            Bug # 4912772 Performance issue in the |
--|                                dynamic query in Create_Inv_Msbk_Rpt is|
--|                                resolved by restructuring the query    |
--| 10/27/2008 vjavli              FP Bug 7458643 fix:Standard cost update|
--|                                transaction should be displayed with   |
--|                                correct cost(new cost minus prior cost)|
--|                                * primary_quantity (onhand qty at that |
--|                                moment). l_primary_qty := 0;           |
--|                                l_total_cost :=                        |
--|                                (l_item_txn_info.new_cost -            |
--|                                l_item_txn_info.prior_cost) *          |
--|                                l_item_txn_info.primary_quantity;      |
--|                                get_item_txn_info proc modified        |
--|12/01/2008 vjavli               Bug 7458643 fix:  Standard cost Update |
--|                                found that primary_quantity is 0;      |
--|                                We have to use quantity_adjusted       |
--|                                Also, actual_cost will be NULL         |
--|                                Even in Average Cost update, better to |
--|                                use quantity_adjusted instead of PQ    |
--|                                quantity_adjusted will always has value|
--|                                In ACU, priorcost,newcost,actcost will |
--|                                will be NOT NULL                       |
--|                                                                       |
--|-----------------------------------------------------------------------|
--|     05/27/2009  vputchal      Italy and China Enhancements from India |
--|                               localization team Package re-designed   |
--|                               The following functions added:          |
--|                               get_break_by,beforereport               |
--|                               get_abc_group_name,getledger_name       |
--|                               --get_category_set_name,get_shipment_num|
--|                               get_include_cost, get_waybill           |
--|                               get_po_number,get_detail_level          |
--|     09/07/2009  ppandit       Changed datatypes for P_LEGAL_ENTITY,   |
--|                               P_LEDGER_ID and P_INVENTORY_ORG in Italy|
--|                               China Enhancements from SSI. Added      |
--|                               functions get_date_from and get_date_to,|
--|                               improved get_po_number. Used REF        |
--|                               CURSOR for table insertion logic. Added |
--|                               p_dummy, p_all_or_single,               |
--|                               get_org_details                         |
--|     09/16/2009  ppandit       Added following functions for XML       |
--|                               elements                                |
--|                               get_inv_org,                            |
--|                               get_subinv_org_from,                    |
--|                               get_subinv_org_to,                      |
--|                               get_category_set_from,                  |
--|                               get_category_set_to,                    |
--|                               get_category_from,                      |
--|                               get_category_to,                        |
--|                               get_item_from,                          |
--|                               get_item_to,                            |
--|                               get_abc_class,                          |
--|                               get_break_by_desc,                      |
--|                               get_all_or_one,                         |
--|                               get_icx_date,                           |
--|                               get_page_penultimate,                   |
--|                               get_suborg_details                      |
--|     09/29/2009  ppandit       Added get_begin_columns, get_end_columns|
--|     10/05/2009  ppandit       Added get_summ_beg_cols,                |
--|                               get_summ_end_cols                       |
--|     11/11/2009  ppandit       Removed DISTINCT from summary functions |
--+=======================================================================+
--===================
-- VARIABLES
--===================

lc_sub_inv_max            VARCHAR2 (10);   -- Added for Italy China Enhancements
lc_sub_inv_min            VARCHAR2 (10);   -- Added for Italy China Enhancements
ln_inv_org                NUMBER;          -- Added for Italy China Enhancements

--===================
-- TYPES
--===================
TYPE report_rec_type IS RECORD (
                                transaction_id           NUMBER
                               ,organization_id          NUMBER
                               ,inventory_item_id        NUMBER
                               ,uom_code                 VARCHAR2(3)   -- added for inv book
                               ,item_code                VARCHAR2(40)  -- added for inv book
                               ,item_desc                VARCHAR2(240) -- added for inv book
                               ,org_name                 VARCHAR2(240) -- added for inv book
                               ,currency_code            VARCHAR2(15)  -- added for inv book
                               ,txn_source               VARCHAR2(30)  -- added for inv book
                               ,txn_date                 DATE
                               ,txn_type                 VARCHAR2(80)
                               ,txn_ini_qty              NUMBER
                               ,txn_ini_unit_cost        NUMBER
                               ,txn_ini_h_total_cost     NUMBER
                               ,txn_ini_adj_total_cost   NUMBER
                               ,txn_qty                  NUMBER
                               ,txn_unit_cost            NUMBER
                               ,txn_h_total_cost         NUMBER
                               ,txn_adj_total_cost       NUMBER
                               ,txn_fnl_qty              NUMBER
                               ,txn_fnl_unit_cost        NUMBER
                               ,txn_fnl_h_total_cost     NUMBER
                               ,txn_fnl_adj_total_cost   NUMBER
                               ,creation_date            DATE
                               ,sub_inv_organization_id  NUMBER         -- Added by ppandit for Italy and China Enhancements
                               ,subinventory_code        VARCHAR2 (10)  -- Added by ppandit for Italy and China Enhancements
                               );

TYPE report_tbl_rec_type IS TABLE OF report_rec_type INDEX BY BINARY_INTEGER;

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2 (30) := 'CST_MGD_MSTR_BOOK_RPT';
GC_TXT_ISSUE        VARCHAR2 (10) := 'Issue';
GC_TXT_RECEIPT      VARCHAR2 (10) := 'Receipt';
--G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_MGD_INV_MASTER_BOOK';

--===================
-- GLOBAL VARIABLES
--===================
g_txn_cost_exc  EXCEPTION;
g_msg           VARCHAR2(255);

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Insert_Rpt_Data         PRIVATE
-- PARAMETERS: p_rpt_item_rec          Kardex report data for one row
-- COMMENT   :
-- EXCEPTIONS: OTHERS
--========================================================================
PROCEDURE insert_rpt_data (p_rpt_item_rec  IN  report_rec_type)
IS
BEGIN

  INSERT INTO cst_mgd_mstr_book_temp (
                                      transaction_id
                                     ,organization_id
                                     ,inventory_item_id
                                     ,uom_code   -- added for inv book
                                     ,item_code
                                     ,item_desc
                                     ,org_name
                                     ,currency_code
                                     ,txn_source -- added for inv book
                                     ,txn_date
                                     ,txn_type
                                     ,txn_ini_qty
                                     ,txn_ini_unit_cost
                                     ,txn_ini_h_total_cost
                                     ,txn_ini_adj_total_cost
                                     ,txn_qty
                                     ,txn_unit_cost
                                     ,txn_h_total_cost
                                     ,txn_adj_total_cost
                                     ,txn_fnl_qty
                                     ,txn_fnl_unit_cost
                                     ,txn_fnl_h_total_cost
                                     ,txn_fnl_adj_total_cost
                                     ,creation_date
                                     ,sub_inv_organization_id  -- Added by ppandit for Italy and China Enhancements
                                     ,subinventory_code        -- Added by ppandit for Italy and China Enhancements
                                     )
  VALUES                             (
                                      p_rpt_item_rec.transaction_id
                                     ,p_rpt_item_rec.organization_id
                                     ,p_rpt_item_rec.inventory_item_id
                                     ,p_rpt_item_rec.uom_code           -- added for inv book
                                     ,p_rpt_item_rec.item_code          -- added for inv book
                                     ,p_rpt_item_rec.item_desc          -- added for inv book
                                     ,p_rpt_item_rec.org_name           -- added for inv book
                                     ,p_rpt_item_rec.currency_code      -- added for inv book
                                     ,p_rpt_item_rec.txn_source         -- added for inv book
                                     ,p_rpt_item_rec.txn_date
                                     ,p_rpt_item_rec.txn_type
                                     ,p_rpt_item_rec.txn_ini_qty
                                     ,p_rpt_item_rec.txn_ini_unit_cost
                                     ,p_rpt_item_rec.txn_ini_h_total_cost
                                     ,p_rpt_item_rec.txn_ini_adj_total_cost
                                     ,p_rpt_item_rec.txn_qty
                                     ,p_rpt_item_rec.txn_unit_cost
                                     ,p_rpt_item_rec.txn_h_total_cost
                                     ,p_rpt_item_rec.txn_adj_total_cost
                                     ,p_rpt_item_rec.txn_fnl_qty
                                     ,p_rpt_item_rec.txn_fnl_unit_cost
                                     ,p_rpt_item_rec.txn_fnl_h_total_cost
                                     ,p_rpt_item_rec.txn_fnl_adj_total_cost
                                     ,p_rpt_item_rec.creation_date
                                     ,p_rpt_item_rec.sub_inv_organization_id  -- Added by ppandit for Italy and China Enhancements
                                     ,p_rpt_item_rec.subinventory_code        -- Added by ppandit for Italy and China Enhancements
                                     );

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Insert_Rpt_Data'
                             );
    END IF;
    --RAISE; -- Commented by ppandit for Italy and China Enhancements

END insert_rpt_data;

--========================================================================
-- PROCEDURE : get_acct_period_id_invmbk      PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_rpt_from_date         Report start date
--             P_rpt_to_date           Report end date
--             x_rpt_from_acct_per_id  Report start account period ID
--             x_rpt_to_acct_per_id    Report end account period ID
-- COMMENT   : Get the account period IDs for user defined reporting
--             period
-- EXCEPTIONS:
--========================================================================
PROCEDURE get_acct_period_id_invmbk (
                                     p_org_id               IN         NUMBER
                                    ,p_rpt_from_date        IN         VARCHAR2
                                    ,p_rpt_to_date          IN         VARCHAR2
                                    ,x_rpt_from_acct_per_id OUT NOCOPY NUMBER
                                    ,x_rpt_to_acct_per_id   OUT NOCOPY NUMBER
                                    )
IS
l_rpt_from_acct_per_id NUMBER;
l_rpt_to_acct_per_id   NUMBER;
l_rpt_from_date	       DATE;
l_rpt_to_date	       DATE;

-- Cursor to retrieve from accounting period id
CURSOR from_acct_period_cur(c_rpt_from_date DATE)
IS
  SELECT f.acct_period_id
    FROM org_acct_periods f
   WHERE f.organization_id      = p_org_id
     AND f.period_start_date   <= c_rpt_from_date
     AND f.schedule_close_date >= c_rpt_from_date;

-- Cursor to retrieve to accounting period id
CURSOR to_acct_period_cur(c_rpt_to_date DATE)
IS
  SELECT t.acct_period_id
    FROM org_acct_periods t
   WHERE t.organization_id      = p_org_id
     AND t.period_start_date   <= c_rpt_to_date
     AND t.schedule_close_date >= c_rpt_to_date;

-- Exception
acct_period_not_found_exc  EXCEPTION;

BEGIN
  l_rpt_from_date := TRUNC (FND_DATE.canonical_to_date (p_rpt_from_date));
  l_rpt_to_date   := TRUNC (FND_DATE.canonical_to_date (p_rpt_to_date));

  -- Get from account period id
  OPEN from_acct_period_cur (TO_DATE (p_date_from, 'YYYY/MM/DD HH24:MI:SS'));
 FETCH from_acct_period_cur
  INTO x_rpt_from_acct_per_id;

  IF from_acct_period_cur%NOTFOUND THEN
    RAISE acct_period_not_found_exc;
  END IF;
  CLOSE from_acct_period_cur;

  -- Get to account period id
  OPEN to_acct_period_cur(TO_DATE(p_date_to, 'YYYY/MM/DD HH24:MI:SS') + (86399 / 86400)); -- Changed by ppandit for using params directly, Italy China Enhancements
 FETCH to_acct_period_cur
  INTO x_rpt_to_acct_per_id;

  IF to_acct_period_cur%NOTFOUND THEN
    RAISE acct_period_not_found_exc;
  END IF;
  CLOSE to_acct_period_cur;


EXCEPTION

  WHEN acct_period_not_found_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_ACCT_PER_ID_INVBK');

    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_Period_ID_invmbk'
                             );
    END IF;
    RAISE;


  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_Period_ID_invmbk'
                             );
    END IF;
    RAISE;

END Get_Acct_Period_ID_invmbk;

-- =======================================================================
--              Added for Italy and China Requirements
-- =======================================================================

--========================================================================
-- FUNCTION : BEFOREREPORT         PUBLIC
-- PARAMETERS: none
--Return : Boolean
-- COMMENT   : This is called from Inventory Master Book Report from XML
-- EXCEPTIONS:INVALID_DATE_RANGE_EXCEPT, OTHERS
--========================================================================
FUNCTION beforereport RETURN BOOLEAN IS
  INVALID_DATE_RANGE_EXCEPT EXCEPTION;

  CURSOR lcu_inv_org -- Added for Italy China Enhancements
  IS
    SELECT HOU.organization_id
      FROM hr_organization_units         HOU
          ,mtl_parameters_view           MPV
          ,xle_firstparty_information_v  XFI
     WHERE MPV.master_organization_id  = p_legal_entity
       AND HOU.organization_id         = MPV.organization_id
       AND XFI.legal_entity_id         = MPV.master_organization_id;

  CURSOR lcu_sub_inv_org (ln_org IN NUMBER) -- Added for Italy China Enhancements
  IS
    SELECT MIN(MSI.secondary_inventory_name)
          ,MAX(MSI.secondary_inventory_name)
      FROM mtl_secondary_inventories  MSI
     WHERE MSI.organization_id = ln_org;
BEGIN
    -- P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
     GD_RPT_DATE_FROM := TRUNC(FND_DATE.canonical_to_date(p_date_from));
     GD_RPT_DATE_TO   := TRUNC(FND_DATE.canonical_to_date(p_date_to)) + (86399 / 86400);

       IF GD_RPT_DATE_FROM > GD_RPT_DATE_TO THEN
         FND_MESSAGE.SET_NAME('FND', 'INVALID DATE RANGE');
         G_MSG := FND_MESSAGE.GET;
         RAISE INVALID_DATE_RANGE_EXCEPT;
       END IF;

	BEGIN
		fnd_file.put_line(fnd_file.LOG, 'P_LEGAL_ENTITY           ' || P_LEGAL_ENTITY);
		fnd_file.put_line(fnd_file.LOG, 'P_LEDGER_ID              ' || P_LEDGER_ID);
		fnd_file.put_line(fnd_file.LOG, 'P_INVENTORY_ORG          ' || P_INVENTORY_ORG);
		fnd_file.put_line(fnd_file.LOG, 'P_DATE_FROM              ' || P_DATE_FROM);
		fnd_file.put_line(fnd_file.LOG, 'P_DATE_TO                ' || P_DATE_TO);
		fnd_file.put_line(fnd_file.LOG, 'P_ITEM_CODE_FROM         ' || P_ITEM_CODE_FROM);
		fnd_file.put_line(fnd_file.LOG, 'P_ITEM_CODE_TO           ' || P_ITEM_CODE_TO);
		fnd_file.put_line(fnd_file.LOG, 'P_CATEGORY_SET_ID_FROM   ' || P_CATEGORY_SET_ID_FROM);
		fnd_file.put_line(fnd_file.LOG, 'P_CATEGORY_SET_ID_TO     ' || P_CATEGORY_SET_ID_TO);
		fnd_file.put_line(fnd_file.LOG, 'P_CATEGORY_FROM          ' || P_CATEGORY_FROM);
		fnd_file.put_line(fnd_file.LOG, 'P_CATEGORY_TO            ' || P_CATEGORY_TO);
		fnd_file.put_line(fnd_file.LOG, 'P_CATEGORY_STRUCTURE     ' || P_CATEGORY_STRUCTURE);
		fnd_file.put_line(fnd_file.LOG, 'P_ABC_GROUP_ID           ' || P_ABC_GROUP_ID);
		fnd_file.put_line(fnd_file.LOG, 'P_ABC_CLASS_ID           ' || P_ABC_CLASS_ID);
		fnd_file.put_line(fnd_file.LOG, 'P_BREAK_BY               ' || P_BREAK_BY);
		fnd_file.put_line(fnd_file.LOG, 'P_PAGE_NUMBER            ' || P_PAGE_NUMBER);
		fnd_file.put_line(fnd_file.LOG, 'P_FISCAL_YEAR            ' || P_FISCAL_YEAR);
		fnd_file.put_line(fnd_file.LOG, 'P_SUBINV_FROM            ' || P_SUBINV_FROM);
		fnd_file.put_line(fnd_file.LOG, 'P_SUBINV_TO              ' || P_SUBINV_TO);
		fnd_file.put_line(fnd_file.LOG, 'P_DETAIL                 ' || P_DETAIL);
		fnd_file.put_line(fnd_file.LOG, 'P_INCLUDE_ITEM_COST      ' || P_INCLUDE_ITEM_COST);
		fnd_file.put_line(fnd_file.LOG, 'P_ALL_OR_SINGLE          ' || P_ALL_OR_SINGLE);

        /* Changed for Italy China Enhancements start, added LOOP for ALL Inventory Org parameter */
        IF p_inventory_org IS NULL THEN

          FOR rec IN lcu_inv_org
          LOOP

            ln_inv_org := rec.organization_id;

            IF lcu_sub_inv_org%ISOPEN THEN
              CLOSE lcu_sub_inv_org;
            END IF;

            OPEN lcu_sub_inv_org (ln_inv_org);
           FETCH lcu_sub_inv_org INTO lc_sub_inv_min, lc_sub_inv_max;
           CLOSE lcu_sub_inv_org;

            CST_MGD_MSTR_BOOK_RPT.create_inv_msbk_rpt (
                                                       p_org_id               => ln_inv_org
                                                      ,p_category_set_id_from => p_category_set_id_from
                                                      ,p_category_set_id_to   => p_category_set_id_to
                                                      ,p_category_from        => p_category_from
                                                      ,p_category_to          => p_category_to
                                                      ,p_subinv_from          => lc_sub_inv_min
                                                      ,p_subinv_to            => lc_sub_inv_max
                                                      ,p_abc_group_id         => p_abc_group_id
                                                      ,p_abc_class_id         => p_abc_class_id
                                                      ,p_item_from_code       => p_item_code_from
                                                      ,p_item_to_code         => p_item_code_to
                                                      ,p_rpt_from_date        => p_date_from
                                                      ,p_rpt_to_date          => p_date_to
                                                      );

          END LOOP;
        ELSE
            CST_MGD_MSTR_BOOK_RPT.create_inv_msbk_rpt (
                                                       p_org_id               => p_inventory_org
                                                      ,p_category_set_id_from => p_category_set_id_from
                                                      ,p_category_set_id_to   => p_category_set_id_to
                                                      ,p_category_from        => p_category_from
                                                      ,p_category_to          => p_category_to
                                                      ,p_subinv_from          => p_subinv_from
                                                      ,p_subinv_to            => p_subinv_to
                                                      ,p_abc_group_id         => p_abc_group_id
                                                      ,p_abc_class_id         => p_abc_class_id
                                                      ,p_item_from_code       => p_item_code_from
                                                      ,p_item_to_code         => p_item_code_to
                                                      ,p_rpt_from_date        => p_date_from
                                                      ,p_rpt_to_date          => p_date_to
                                                      );
        END IF;
        /* Changed for Italy China Enhancements end, added LOOP for ALL Inventory Orgs */
    END;

-- Commented by ppandit
/*     BEGIN
      SELECT FND_DATE.date_to_chardate (TRUNC (FND_DATE.canonical_to_date (p_date_from)))
        INTO p_date_from_formatting
        FROM  DUAL;
    END;

    BEGIN
      SELECT FND_DATE.date_to_chardate (TRUNC (FND_DATE.canonical_to_date (p_date_to)))
        INTO p_date_to_formatting
        FROM  DUAL;
    END; */

    BEGIN
      SELECT fc.extended_precision, gsob.currency_code
        INTO gn_precision_val, gc_currency_code
        FROM gl_sets_of_books gsob,
             org_organization_definitions ood,
             fnd_currencies fc
       WHERE ood.organization_id = p_inventory_org
         AND ood.set_of_books_id = gsob.set_of_books_id
         AND fc.currency_code    = gsob.currency_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        gn_precision_val := NULL;
        gc_currency_code := NULL;
    END;
	/*
    BEGIN
      SELECT  FRV.RESPONSIBILITY_NAME,
        FND_DATE.DATE_TO_CHARDT(FCR.REQUEST_DATE),
        FAV.APPLICATION_NAME,
        FU.USER_NAME
      INTO  GC_RESPONSIBILITY
			,GC_REQUEST_TIME
			,GC_APPLICATION
			,GC_REQUESTED_BY
      FROM  FND_CONCURRENT_REQUESTS FCR,
			FND_RESPONSIBILITY_VL FRV,
			FND_APPLICATION_VL FAV,
			FND_USER FU
      WHERE FCR.REQUEST_ID = P_CONC_REQUEST_ID
        AND FCR.RESPONSIBILITY_APPLICATION_ID = FRV.APPLICATION_ID
        AND FCR.RESPONSIBILITY_ID = FRV.RESPONSIBILITY_ID
        AND FRV.APPLICATION_ID = FAV.APPLICATION_ID
        AND FU.USER_ID = FCR.REQUESTED_BY;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		NULL;
    END;
	*/
    BEGIN
      SELECT meaning
        INTO gc_include_cost
        FROM fnd_lookups
       WHERE lookup_code = p_include_item_cost
         AND lookup_type = 'YES_NO';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        gc_include_cost := 'N';
    END;

    BEGIN

      SELECT meaning
        INTO gc_detail
        FROM fnd_lookups
       WHERE lookup_code = p_detail
         AND lookup_type = 'INV_BOOK_DETAIL';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        gc_detail := NULL;
    END;

    IF p_abc_class_id IS NOT NULL THEN
      BEGIN
        SELECT abc_class_name
          INTO gc_abc_class_name
          FROM mtl_abc_classes
         WHERE abc_class_id = p_abc_class_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          gc_abc_class_name := NULL;
      END;
    END IF;

    IF p_abc_group_id IS NOT NULL THEN
      BEGIN
        SELECT assignment_group_name
          INTO gc_abc_group_name
          FROM mtl_abc_assignment_groups
         WHERE assignment_group_id = p_abc_group_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          gc_abc_group_name := NULL;
      END;
    END IF;

    IF p_category_set_id_from IS NOT NULL THEN
      BEGIN
        SELECT category_set_name
          INTO gc_category_set_name_1
          FROM mtl_category_sets
         WHERE category_set_id = p_category_set_id_from;    -- Changed by ppandit P_CATEGORY_SET_ID to P_CATEGORY_SET_ID_FROM
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          gc_category_set_name_1 := NULL;
      END;
    END IF;

    IF p_category_set_id_to IS NOT NULL THEN  -- Added by ppandit
      BEGIN
        SELECT category_set_name
          INTO gc_category_set_name_2
          FROM mtl_category_sets
         WHERE category_set_id = p_category_set_id_to;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          gc_category_set_name_2 := NULL;
      END;
    END IF;

    RETURN (TRUE);

  EXCEPTION
 WHEN INVALID_DATE_RANGE_EXCEPT THEN
      FND_MESSAGE.SET_NAME('FND', 'INVALID DATE RANGE');
      RETURN (TRUE);

END beforereport;

  /* Included for Italy Joint Project */
-- +==========================================================================+
-- FUNCTION: get_shipment_num
-- PARAMETERS:
-- p_transaction_id  IN  NUMBER
-- COMMENT:
-- This procedure is called by Inventory Master Book Report
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
  FUNCTION get_shipment_num (p_transaction_id NUMBER) RETURN VARCHAR2 IS
    lv_shipment_num VARCHAR2(100);
  BEGIN
    BEGIN
      SELECT shipment_number
        INTO lv_shipment_num
        FROM mtl_material_transactions
       WHERE transaction_id = p_transaction_id;

    EXCEPTION
      WHEN OTHERS THEN
        lv_shipment_num:=NULL;
    END;
    RETURN (lv_shipment_num);
  END get_shipment_Num;

/* Included for Italy Joint Project */
-- +==========================================================================+
-- FUNCTION: get_waybill
-- PARAMETERS:
-- p_transaction_id  IN  NUMBER
-- COMMENT:
-- This procedure is called by the Inventory Master Book Report
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+

  FUNCTION get_waybill (p_transaction_id NUMBER) RETURN VARCHAR2 IS
  lc_waybill_airbill VARCHAR2(100);
  BEGIN
    BEGIN
      SELECT waybill_airbill
        INTO lc_waybill_airbill
        FROM mtl_material_transactions
       WHERE transaction_id = p_transaction_id;
    EXCEPTION
      WHEN OTHERS THEN
        lc_waybill_airbill := NULL;
    END;
    RETURN (lc_waybill_airbill);
  END get_waybill;

 /* Included for Italy Joint Project */
-- +==========================================================================+
-- FUNCTION: get_po_number
-- PARAMETERS:
-- p_transaction_id IN NUMBER
-- p_type           IN VARCHAR2
-- COMMENT:
-- This procedure is called by Inventory Master Book Report
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
  FUNCTION get_po_number (p_transaction_id IN NUMBER, p_type IN VARCHAR2) -- Added p_type by ppandit for Italy - China Enhancements
    RETURN VARCHAR2
  IS
    ln_org_id                NUMBER;
    ln_trx_line_id           NUMBER; -- Added for Bug Number 8834843
    ln_row_count             NUMBER;
    ln_trans_source_type_id  NUMBER;
    ln_trans_source_id       NUMBER;
    lc_po_or_so_number       VARCHAR2 (100);
    --lv_po_number VARCHAR2(100); -- Commented by ppandit for Italy and China JF Project
  BEGIN
    -- Code added by ppandit for Italy and China JF Project to capture correct PO or SO Numbers start
    SELECT MMT.organization_id
          ,MMT.transaction_source_type_id
          ,MMT.transaction_source_id
          ,MMT.trx_source_line_id
      INTO ln_org_id
          ,ln_trans_source_type_id
          ,ln_trans_source_id
          ,ln_trx_line_id
      FROM mtl_material_transactions  MMT
     WHERE MMT.transaction_id = p_transaction_id;

    IF ln_trans_source_type_id = 1 THEN
      SELECT PHA.segment1
        INTO lc_po_or_so_number
        FROM po_headers_all     PHA
       WHERE PHA.po_header_id = ln_trans_source_id;
    ELSIF ln_trans_source_type_id IN (2, 8, 12) THEN
      SELECT OOH.order_number      -- Changed to refer to OE tables for Bug Number 8834843
        INTO lc_po_or_so_number
        FROM oe_order_headers_all  OOH
            ,oe_order_lines_all    OOL
       WHERE OOH.header_id       = OOL.header_id
         AND OOL.line_id         = ln_trx_line_id;
    END IF;

    IF (p_type = 'PO' AND ln_trans_source_type_id = 1) OR (p_type = 'SO' AND ln_trans_source_type_id IN (2, 8, 12)) THEN
      RETURN (lc_po_or_so_number);
    ELSE
      RETURN NULL;
    END IF;
    -- Code added by ppandit for Italy and China JF Project to capture correct PO or SO Numbers end
    /* ppandit Comment start - Commented by ppandit for Italy and China JF Project */
    --BEGIN
	--	SELECT transaction_source_name
	--	INTO lv_po_number
	--	FROM mtl_material_transactions
	--	WHERE transaction_id =p_transaction_id;
	--EXCEPTION
	--	WHEN others THEN
	--	   lv_po_number:=NULL;
	--END;
    --RETURN (lv_po_number);
    /* ppandit Comment end */
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_po_number;

-- +==========================================================================+
-- FUNCTION: getledger_name
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get the name of the Ledger
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
  FUNCTION getledger_name RETURN VARCHAR2 IS
    lv_ledgername VARCHAR2(100);
  BEGIN
    BEGIN
      SELECT name
        INTO lv_ledgername
        FROM gl_ledgers
       WHERE ledger_id = p_ledger_id;
  EXCEPTION
    WHEN no_data_found THEN
      lv_ledgername := NULL;
  END;
  RETURN (lv_ledgername);
  END getledger_Name;

-- +==========================================================================+
-- FUNCTION: get_inv_org
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Inventory Org
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_inv_org RETURN VARCHAR2
IS
  lc_inventory_org  VARCHAR2 (240);
BEGIN
  SELECT HOU.name
    INTO lc_inventory_org
    FROM hr_all_organization_units  HOU
   WHERE HOU.organization_id = p_inventory_org;

    RETURN lc_inventory_org;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN (' ');
  WHEN OTHERS THEN
    RETURN (' ');
END get_inv_org;
-- +==========================================================================+
-- FUNCTION: get_subinv_org_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report Subinventory From
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_subinv_org_from RETURN VARCHAR2
IS
BEGIN
  RETURN p_subinv_from;
END get_subinv_org_from;
-- +==========================================================================+
-- FUNCTION: get_subinv_org_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report Subinventory To
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_subinv_org_to RETURN VARCHAR2
IS
BEGIN
  RETURN p_subinv_to;
END get_subinv_org_to;
-- +==========================================================================+
-- FUNCTION: get_category_set_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report Category Set From
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_set_from RETURN VARCHAR2
IS
BEGIN
  RETURN gc_category_set_name_1;
END get_category_set_from;
-- +==========================================================================+
-- FUNCTION: get_category_set_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Category Set To
-- Return: VARCHAR2
-- PRE-COND: none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_set_to RETURN VARCHAR2
IS
BEGIN
  RETURN gc_category_set_name_2;
END get_category_set_to;
-- +==========================================================================+
-- FUNCTION: get_category_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Category From
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_from RETURN VARCHAR2
IS
BEGIN
  RETURN (p_category_from);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_category_from;
-- +==========================================================================+
-- FUNCTION: get_category_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get to get Category To
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_to RETURN VARCHAR2
IS
BEGIN
  RETURN (p_category_to);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_category_to;
-- +==========================================================================+
-- FUNCTION: get_item_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Item Code From
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_item_from RETURN VARCHAR2
IS
BEGIN
  RETURN p_item_code_from;
END get_item_from;
-- +==========================================================================+
-- FUNCTION: get_item_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Item Code To
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_item_to RETURN VARCHAR2
IS
BEGIN
  RETURN p_item_code_to;
END get_item_to;
-- +==========================================================================+
-- FUNCTION: get_abc_class
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get ABC Class
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_abc_class RETURN VARCHAR2
IS
BEGIN
  RETURN gc_abc_class_name;
END get_abc_class;
-- +==========================================================================+
-- FUNCTION: get_break_by_desc
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get Break By meaning
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_break_by_desc RETURN VARCHAR2
IS
  lc_meaning  VARCHAR2 (80);
BEGIN
  SELECT MLS.meaning
    INTO lc_meaning
    FROM mfg_lookups        MLS
   WHERE MLS.lookup_type  = 'CST_BREAK_BY_INV'
     AND MLS.lookup_code  = p_break_by
     AND MLS.enabled_flag = 'Y';

  RETURN (lc_meaning);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN (' ');
  WHEN OTHERS THEN
    RETURN (' ');
END get_break_by_desc;

-- +==========================================================================+
-- FUNCTION: get_all_or_one
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- All or One parameter
--
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_all_or_one RETURN VARCHAR2
IS
  lc_meaning  VARCHAR2 (80);
BEGIN
  SELECT MLS.meaning
    INTO lc_meaning
    FROM mfg_lookups        MLS
   WHERE MLS.lookup_type  = 'CST_ALL_OR_ONE_INV'
     AND MLS.lookup_code  = p_all_or_single
     AND MLS.enabled_flag = 'Y';

  RETURN (lc_meaning);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN (' ');
  WHEN OTHERS THEN
    RETURN (' ');
END get_all_or_one;

-- +==========================================================================+
-- FUNCTION: get_icx_date
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Sysdate as per ICX Date Format
--
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_icx_date RETURN VARCHAR2
IS
  lc_sysdate  VARCHAR2 (80);
BEGIN
  SELECT TO_CHAR(SYSDATE, FND_PROFILE.value('ICX_DATE_FORMAT_MASK'))
    INTO lc_sysdate
    FROM SYS.dual;

  RETURN (lc_sysdate);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_icx_date;

-- +==========================================================================+
-- FUNCTION: get_page_penultimate
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Page Numbering minus one
--
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_page_penultimate RETURN NUMBER
IS
  lc_sysdate  VARCHAR2 (80);
BEGIN
  RETURN (TO_NUMBER(p_page_number) - 1);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_page_penultimate;

-- +==========================================================================+
-- FUNCTION: get_row_count
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get record count
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_row_count RETURN NUMBER
IS
BEGIN
  /* Added counter for row count as this function is called in G_MAIN and G_SUMMARY_MAIN as well */
  gn_row_count := gn_row_count + 1;
  RETURN (NVL(gn_row_count, 0));
END get_row_count;

-- +==========================================================================+
-- FUNCTION: get_category_structure
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Item or Category Flexfields segments
--
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_category_structure (
                                 p_type          IN VARCHAR2
                                ,p_cat_struct_id IN NUMBER
                                )
  RETURN VARCHAR2
IS
  lr_flexfield_rec   FND_FLEX_KEY_API.flexfield_type;
  lr_structure_rec   FND_FLEX_KEY_API.structure_type;
  lr_segment_rec     FND_FLEX_KEY_API.segment_type;
  lt_segment_rec     FND_FLEX_KEY_API.segment_list;
  ln_segment_number  NUMBER;
  lc_segment_number  VARCHAR2 (850);
  lc_mcat_segs       VARCHAR2 (2000);

BEGIN

  FND_FLEX_KEY_API.set_session_mode ('customer_data');

  IF p_type = 'ITEM' THEN -- Retrieve system item concatenated flexfield
    lc_segment_number := '';
    lr_flexfield_rec  := FND_FLEX_KEY_API.find_flexfield ('INV', 'MSTK');
    lr_structure_rec  := FND_FLEX_KEY_API.find_structure (lr_flexfield_rec, p_cat_struct_id);
    FND_FLEX_KEY_API.get_segments (
                                   flexfield => lr_flexfield_rec
                                  ,structure => lr_structure_rec
                                  ,nsegments => ln_segment_number
                                  ,segments  => lt_segment_rec
                                  );

    FOR l_idx IN 1..ln_segment_number LOOP
      lr_segment_rec := FND_FLEX_KEY_API.find_segment (
                                                       lr_flexfield_rec
                                                      ,lr_structure_rec
                                                      ,lt_segment_rec (l_idx)
                                                      );

      lc_segment_number := lc_segment_number || 'MSI.' || lr_segment_rec.column_name;

      IF l_idx < ln_segment_number THEN
        lc_segment_number := lc_segment_number || '||' || '''' || lr_structure_rec.segment_separator || '''' || '||';
      END IF;

    END LOOP;

    RETURN (lc_segment_number);
  END IF;

  IF p_type = 'CAT' THEN -- Retrieve Item Category concatenated flexfield
    lc_mcat_segs     := '';
    lr_flexfield_rec := FND_FLEX_KEY_API.find_flexfield ('INV', 'MCAT');
    lr_structure_rec := FND_FLEX_KEY_API.find_structure (
                                                         lr_flexfield_rec
                                                        ,p_cat_struct_id
                                                        );
    FND_FLEX_KEY_API.get_segments (
                                   flexfield => lr_flexfield_rec
                                  ,structure => lr_structure_rec
                                  ,nsegments => ln_segment_number
                                  ,segments  => lt_segment_rec
                                  );

    FOR l_idx IN 1..ln_segment_number LOOP
      lr_segment_rec := FND_FLEX_KEY_API.find_segment (
                                                       lr_flexfield_rec
                                                      ,lr_structure_rec
                                                      ,lt_segment_rec (l_idx)
                                                      );

      lc_mcat_segs   := lc_mcat_segs || 'MCK.' || lr_segment_rec.column_name;

      IF l_idx < ln_segment_number THEN
        lc_mcat_segs := lc_mcat_segs || ' || ' || '''' || lr_structure_rec.segment_separator || '''' || ' || ';
      END IF;

    END LOOP;
    RETURN (lc_mcat_segs);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_category_structure;

-- +==========================================================================+
-- FUNCTION: get_structure_id
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by Inventory Master Book Report to get value of
-- Category Structure ID
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_structure_id (p_category_set_id IN NUMBER)
  RETURN NUMBER
IS
  ln_cat_struct  NUMBER;
BEGIN
  SELECT MCS.structure_id
    INTO ln_cat_struct
    FROM mtl_category_sets     MCS
   WHERE MCS.category_set_id = p_category_set_id;

  RETURN (ln_cat_struct);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_structure_id;

  /* Included for Italy Joint Project */
-- +==========================================================================+
-- FUNCTION: get_org_details
-- PARAMETERS:
-- p_org_id     IN NUMBER
-- p_number     IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Org details
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_org_details (p_org_id IN NUMBER, p_number IN NUMBER)
RETURN VARCHAR2 IS
  lc_location  VARCHAR2 (100);
  lc_type      VARCHAR2 (100);
  lc_address   VARCHAR2 (500);
BEGIN
  SELECT HOU.location_code
        ,HOU.internal_external_meaning
        ,HOU.address_line_1 ||
         ' '                ||
         HOU.address_line_2 ||
         ' '                ||
         HOU.address_line_3 ||
         ' '                ||
         HOU.town_or_city   ||
         ' '                ||
         HOU.country
    INTO lc_location
        ,lc_type
        ,lc_address
    FROM hr_organization_units_v  HOU
   WHERE HOU.organization_id = p_org_id;

  IF p_number = 1 THEN
    RETURN (lc_location);
  ELSIF p_number = 2 THEN
    RETURN (lc_type);
  ELSIF p_number = 3 THEN
    RETURN (lc_address);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_org_details;

-- +==========================================================================+
-- FUNCTION: get_suborg_details
-- PARAMETERS:
-- p_subinvname IN VARCHAR2
-- p_org_id     IN NUMBER
-- p_number     IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Sub Org details
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_suborg_details (
                             p_subinvname IN VARCHAR2
                            ,p_org_id     IN NUMBER
                            ,p_number     IN NUMBER
                            )
RETURN VARCHAR2 IS
  lc_location  VARCHAR2 (100);
  lc_type      VARCHAR2 (100);
  lc_address   VARCHAR2 (500);
BEGIN
  SELECT H.location_code
        ,H.description
        ,H.address_line_1 ||
         ' '              ||
         H.address_line_2 ||
         ' '              ||
         H.country
    INTO lc_location
        ,lc_type
        ,lc_address
    FROM mtl_secondary_inventories    A
        ,hr_locations_all             H
   WHERE A.secondary_inventory_name = p_subinvname
     AND H.location_id(+)           = A.location_id
     AND organization_id            = p_org_id;

  IF p_number = 1 THEN
    RETURN (lc_location);
  ELSIF p_number = 2 THEN
    RETURN (lc_type);
  ELSIF p_number = 3 THEN
    RETURN (lc_address);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_suborg_details;

-- +==========================================================================+
-- FUNCTION: get_begin_columns
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_type               IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Begin Cost, Quantity and Value when Break By is Item
-- and report is running for ALL Inventory Organizations
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_begin_columns (
                            p_inventory_item_id  IN NUMBER
                           ,p_type               IN NUMBER
                           )
RETURN NUMBER IS
  ln_txn_ini_qty    NUMBER := 0;
  ln_txn_ini_value  NUMBER := 0;
  ln_org_id         NUMBER;

  CURSOR lcu_begin_val (p_org_id IN NUMBER)
  IS
    SELECT CMIAKD.transaction_id                                    TRANSACTION_ID
          ,CMIAKD.txn_date                                          TXN_DATE
          ,CMIAKD.txn_ini_qty                                       TXN_INI_QTY
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2) * CMIAKD.txn_ini_qty  TXN_INI_VALUE
          ,CMIAKD.organization_id                                   ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND CMIAKD.organization_id   = p_org_id
       AND p_break_by               = 1
     ORDER BY 5, 2, 1 ASC;

  lr_rec lcu_begin_val%ROWTYPE;

  CURSOR lcu_org
  IS
    SELECT DISTINCT organization_id
      FROM cst_mgd_mstr_book_temp
     WHERE inventory_item_id = p_inventory_item_id
  ORDER BY organization_id ASC;

BEGIN
  FOR r_org IN lcu_org LOOP
    OPEN lcu_begin_val (r_org.organization_id);
   FETCH lcu_begin_val INTO lr_rec;
   CLOSE lcu_begin_val;

    ln_txn_ini_qty   := ln_txn_ini_qty   + lr_rec.txn_ini_qty;
    ln_txn_ini_value := ln_txn_ini_value + lr_rec.txn_ini_value;
  END LOOP;

  IF p_type = 1 THEN
    IF ln_txn_ini_qty <> 0 THEN RETURN (ln_txn_ini_value/ln_txn_ini_qty); ELSE RETURN (0); END IF;
  ELSIF p_type = 2 THEN
    RETURN (ln_txn_ini_qty);
  ELSIF p_type = 3 THEN
    RETURN (ln_txn_ini_value);
  END IF;
END get_begin_columns;

-- +==========================================================================+
-- FUNCTION: get_end_columns
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_type               IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the End Cost, Quantity and Value when Break By is Item
-- and report is running for ALL Inventory Organizations
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_end_columns (
                          p_inventory_item_id  IN NUMBER
                         ,p_type               IN NUMBER
                         )
RETURN NUMBER IS
  ln_txn_fnl_qty    NUMBER := 0;
  ln_txn_fnl_value  NUMBER := 0;
  ln_org_id         NUMBER;

  CURSOR lcu_end_val (p_org_id IN NUMBER)
  IS
    SELECT CMIAKD.transaction_id                            TRANSACTION_ID
          ,CMIAKD.txn_date                                  TXN_DATE
          ,CMIAKD.txn_qty                                   TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_unit_cost, 2) * CMIAKD.txn_qty  TXN_FNL_VALUE
          ,CMIAKD.organization_id                           ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND CMIAKD.organization_id   = p_org_id
       AND p_break_by               = 1
     ORDER BY 5, 2, 1 ASC;

  CURSOR lcu_org
  IS
    SELECT DISTINCT organization_id
      FROM cst_mgd_mstr_book_temp
     WHERE inventory_item_id = p_inventory_item_id
  ORDER BY organization_id ASC;

BEGIN

  FOR r_org IN lcu_org LOOP
    FOR lr_rec IN lcu_end_val (r_org.organization_id)
    LOOP
      ln_txn_fnl_qty   := ln_txn_fnl_qty   + lr_rec.txn_fnl_qty;
      ln_txn_fnl_value := ln_txn_fnl_value + lr_rec.txn_fnl_value;
    END LOOP;
  END LOOP;

  ln_txn_fnl_qty   := ln_txn_fnl_qty   + get_begin_columns (p_inventory_item_id, 2);
  ln_txn_fnl_value := ln_txn_fnl_value + get_begin_columns (p_inventory_item_id, 3);

  IF p_type = 1 THEN
    IF ln_txn_fnl_qty <> 0 THEN RETURN (ln_txn_fnl_value/ln_txn_fnl_qty); ELSE RETURN (0); END IF;
  ELSIF p_type = 2 THEN
    RETURN (ln_txn_fnl_qty);
  ELSIF p_type = 3 THEN
    RETURN (ln_txn_fnl_value);
  END IF;
END get_end_columns;

-- +==========================================================================+
-- FUNCTION: get_summ_beg_cols
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_organization_id    IN NUMBER
-- p_sub_inv_org_name   IN VARCHAR2
-- p_sub_inv_org_id     IN NUMBER
-- p_type               IN NUMBER
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the Begin Cost, Quantity and Value when report is running for
-- detail as Summary
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_summ_beg_cols (
                            p_inventory_item_id  IN NUMBER
                           ,p_organization_id    IN NUMBER
                           ,p_sub_inv_org_name   IN VARCHAR2
                           ,p_sub_inv_org_id     IN NUMBER
                           ,p_type               IN NUMBER
                           )
RETURN NUMBER IS
  ln_txn_ini_qty    NUMBER := 0;
  ln_txn_ini_value  NUMBER := 0;
  ln_org_id         NUMBER;

  CURSOR lcu_begin_val (p_org_id IN NUMBER)
  IS
    SELECT CMIAKD.transaction_id                                    TRANSACTION_ID
          ,CMIAKD.txn_date                                          TXN_DATE
          ,CMIAKD.txn_ini_qty                                       TXN_INI_QTY
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2) * CMIAKD.txn_ini_qty  TXN_INI_VALUE
          ,CMIAKD.organization_id                                   ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND CMIAKD.organization_id   = p_org_id
       AND p_break_by               = 1
     ORDER BY 5, 2, 1 ASC;

  lr_rec lcu_begin_val%ROWTYPE;

  CURSOR lcu_summary_cols
  IS
    SELECT CMIAKD.transaction_id                                              TRANSACTION_ID
          ,CMIAKD.currency_code                                               CURRENCY_CODE
          ,ROUND(CMIAKD.txn_unit_cost, 2)                                     TXN_UNIT_COST
          ,CMIAKD.txn_date                                                    TXN_DATE
          ,CMIAKD.txn_type                                                    TXN_TYPE
          ,CMIAKD.txn_source                                                  TXN_SOURCE
          ,CMIAKD.txn_ini_qty                                                 TXN_INI_QTY
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2)                                 TXN_INI_UNIT_COST
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2) * CMIAKD.txn_ini_qty            TXN_INI_VALUE
          ,CMIAKD.txn_fnl_qty                                                 TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2)                                 TXN_FNL_UNIT_COST
          ,CMIAKD.txn_qty                                                     TXN_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2)  *  CMIAKD.txn_fnl_qty          TXN_FNL_VALUE
          ,ROUND(CMIAKD.txn_h_total_cost, 2)                                  TXN_VALUE
          ,CMIAKD.organization_id                                             ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND p_break_by               = 1
       AND p_detail                 = 'S'
    UNION ALL
    SELECT CMIAKD.transaction_id                                              TRANSACTION_ID
          ,CMIAKD.currency_code                                               CURRENCY_CODE
          ,ROUND(CMIAKD.txn_unit_cost, 2)                                     TXN_UNIT_COST
          ,CMIAKD.txn_date                                                    TXN_DATE
          ,CMIAKD.txn_type                                                    TXN_TYPE
          ,CMIAKD.txn_source                                                  TXN_SOURCE
          ,CMIAKD.txn_ini_qty                                                 TXN_INI_QTY
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2)                                 TXN_INI_UNIT_COST
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2) * CMIAKD.txn_ini_qty            TXN_INI_VALUE
          ,CMIAKD.txn_fnl_qty                                                 TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2)                                 TXN_FNL_UNIT_COST
          ,CMIAKD.txn_qty                                                     TXN_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2)  *  CMIAKD.txn_fnl_qty          TXN_FNL_VALUE
          ,ROUND(CMIAKD.txn_h_total_cost, 2)                                  TXN_VALUE
          ,CMIAKD.organization_id                                             ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND CMIAKD.organization_id   = p_organization_id
       AND p_break_by               IN (2, 4)
       AND p_detail                 = 'S'
    UNION ALL
    SELECT CMIAKD.transaction_id                                              TRANSACTION_ID
          ,CMIAKD.currency_code                                               CURRENCY_CODE
          ,ROUND(CMIAKD.txn_unit_cost, 2)                                     TXN_UNIT_COST
          ,CMIAKD.txn_date                                                    TXN_DATE
          ,CMIAKD.txn_type                                                    TXN_TYPE
          ,CMIAKD.txn_source                                                  TXN_SOURCE
          ,CMIAKD.txn_ini_qty                                                 TXN_INI_QTY
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2)                                 TXN_INI_UNIT_COST
          ,ROUND(CMIAKD.txn_ini_unit_cost, 2) * CMIAKD.txn_ini_qty            TXN_INI_VALUE
          ,CMIAKD.txn_fnl_qty                                                 TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2)                                 TXN_FNL_UNIT_COST
          ,CMIAKD.txn_qty                                                     TXN_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2)  *  CMIAKD.txn_fnl_qty          TXN_FNL_VALUE
          ,ROUND(CMIAKD.txn_h_total_cost, 2)                                  TXN_VALUE
          ,CMIAKD.organization_id                                             ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp           CMIAKD
     WHERE CMIAKD.inventory_item_id       = p_inventory_item_id
       AND CMIAKD.organization_id         = p_organization_id
       AND CMIAKD.subinventory_code       = p_sub_inv_org_name
       AND CMIAKD.sub_inv_organization_id = p_sub_inv_org_id
       AND p_break_by                     IN (3, 5)
       AND p_detail                       = 'S'
     ORDER BY 15, 4, 1 ASC;

  ls_rec  lcu_summary_cols%ROWTYPE;

  CURSOR lcu_org
  IS
    SELECT DISTINCT organization_id
      FROM cst_mgd_mstr_book_temp
     WHERE inventory_item_id = p_inventory_item_id
  ORDER BY organization_id ASC;

BEGIN
  IF p_inventory_org IS NULL AND p_break_by = 1 AND p_detail = 'S' THEN
    FOR r_org IN lcu_org LOOP

      OPEN lcu_begin_val (r_org.organization_id);
     FETCH lcu_begin_val INTO lr_rec;
     CLOSE lcu_begin_val;

      ln_txn_ini_qty   := ln_txn_ini_qty   + lr_rec.txn_ini_qty;
      ln_txn_ini_value := ln_txn_ini_value + lr_rec.txn_ini_value;
    END LOOP;
  ELSIF NOT (p_inventory_org IS NULL AND p_break_by = 1) AND p_detail = 'S' THEN
     OPEN lcu_summary_cols;
    FETCH lcu_summary_cols INTO ls_rec;
    CLOSE lcu_summary_cols;

      ln_txn_ini_qty   := ls_rec.txn_ini_qty;
      ln_txn_ini_value := ls_rec.txn_ini_value;
  END IF;

  IF p_type = 1 THEN
    IF ln_txn_ini_qty <> 0 THEN RETURN (ln_txn_ini_value/ln_txn_ini_qty); ELSE RETURN (0); END IF;
  ELSIF p_type = 2 THEN
    RETURN (ln_txn_ini_qty);
  ELSIF p_type = 3 THEN
    RETURN (ln_txn_ini_value);
  END IF;
END get_summ_beg_cols;

-- +==========================================================================+
-- FUNCTION: get_summ_end_cols
-- PARAMETERS:
-- p_inventory_item_id  IN NUMBER
-- p_organization_id    IN NUMBER
-- p_sub_inv_org_name   IN VARCHAR2
-- p_sub_inv_org_id     IN NUMBER
-- p_type               IN NUMBER
--
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the End Cost, Quantity and Value when report is running for
-- detail as Summary
--
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_summ_end_cols (
                            p_inventory_item_id  IN NUMBER
                           ,p_organization_id    IN NUMBER
                           ,p_sub_inv_org_name   IN VARCHAR2
                           ,p_sub_inv_org_id     IN NUMBER
                           ,p_type               IN NUMBER
                           )
RETURN NUMBER IS
  ln_txn_fnl_qty    NUMBER := 0;
  ln_txn_fnl_value  NUMBER := 0;

  CURSOR lcu_end_val (p_org_id IN NUMBER)
  IS
    SELECT CMIAKD.transaction_id                            TRANSACTION_ID
          ,CMIAKD.txn_date                                  TXN_DATE
          ,CMIAKD.txn_qty                                   TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_unit_cost, 2) * CMIAKD.txn_qty  TXN_FNL_VALUE
          ,CMIAKD.organization_id                           ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND CMIAKD.organization_id   = p_org_id
       AND p_break_by               = 1
     ORDER BY 5, 2, 1 ASC;

  CURSOR lcu_summary_cols
  IS
    SELECT CMIAKD.transaction_id                                    TRANSACTION_ID
          ,CMIAKD.txn_date                                          TXN_DATE
          ,CMIAKD.txn_fnl_qty                                       TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2) * CMIAKD.txn_fnl_qty  TXN_FNL_VALUE
          ,CMIAKD.organization_id                                   ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND p_break_by               = 1
       AND p_detail                 = 'S'
    UNION ALL
    SELECT CMIAKD.transaction_id                                    TRANSACTION_ID
          ,CMIAKD.txn_date                                          TXN_DATE
          ,CMIAKD.txn_fnl_qty                                       TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2) * CMIAKD.txn_fnl_qty  TXN_FNL_VALUE
          ,CMIAKD.organization_id                                   ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp     CMIAKD
     WHERE CMIAKD.inventory_item_id = p_inventory_item_id
       AND CMIAKD.organization_id   = p_organization_id
       AND p_break_by               IN (2, 4)
       AND p_detail                 = 'S'
    UNION ALL
    SELECT CMIAKD.transaction_id                                    TRANSACTION_ID
          ,CMIAKD.txn_date                                          TXN_DATE
          ,CMIAKD.txn_fnl_qty                                       TXN_FNL_QTY
          ,ROUND(CMIAKD.txn_fnl_unit_cost, 2) * CMIAKD.txn_fnl_qty  TXN_FNL_VALUE
          ,CMIAKD.organization_id                                   ORGANIZATION_ID
      FROM cst_mgd_mstr_book_temp           CMIAKD
     WHERE CMIAKD.inventory_item_id       = p_inventory_item_id
       AND CMIAKD.organization_id         = p_organization_id
       AND CMIAKD.subinventory_code       = p_sub_inv_org_name
       AND CMIAKD.sub_inv_organization_id = p_sub_inv_org_id
       AND p_break_by                     IN (3, 5)
       AND p_detail                       = 'S'
     ORDER BY 5, 2, 1 ASC;

  ls_rec  lcu_summary_cols%ROWTYPE;

  CURSOR lcu_org
  IS
    SELECT DISTINCT organization_id
      FROM cst_mgd_mstr_book_temp
     WHERE inventory_item_id = p_inventory_item_id
  ORDER BY organization_id ASC;

BEGIN
  IF p_inventory_org IS NULL AND p_break_by = 1 AND p_detail = 'S' THEN
    FOR r_org IN lcu_org LOOP
      FOR lr_rec IN lcu_end_val (r_org.organization_id)
      LOOP
        ln_txn_fnl_qty   := ln_txn_fnl_qty   + lr_rec.txn_fnl_qty;
        ln_txn_fnl_value := ln_txn_fnl_value + lr_rec.txn_fnl_value;
      END LOOP;
    END LOOP;

    ln_txn_fnl_qty   := ln_txn_fnl_qty   + get_summ_beg_cols (p_inventory_item_id, p_organization_id, p_sub_inv_org_name, p_sub_inv_org_id, 2);
    ln_txn_fnl_value := ln_txn_fnl_value + get_summ_beg_cols (p_inventory_item_id, p_organization_id, p_sub_inv_org_name, p_sub_inv_org_id, 3);
  ELSIF NOT (p_inventory_org IS NULL AND p_break_by = 1) AND p_detail = 'S' THEN
    FOR ls_rec IN lcu_summary_cols LOOP
      ln_txn_fnl_qty   := ls_rec.txn_fnl_qty;
      ln_txn_fnl_value := ls_rec.txn_fnl_value;
    END LOOP;
  END IF;

  IF p_type = 1 THEN
    IF ln_txn_fnl_qty <> 0 THEN RETURN (ln_txn_fnl_value/ln_txn_fnl_qty); ELSE RETURN (0); END IF;
  ELSIF p_type = 2 THEN
    RETURN (ln_txn_fnl_qty);
  ELSIF p_type = 3 THEN
    RETURN (ln_txn_fnl_value);
  END IF;
END get_summ_end_cols;

-- +==========================================================================+
-- FUNCTION: get_break_by
-- PARAMETERS: NONE
-- COMMENT:
-- This function is called in the XML of Inventory Master Book Report
-- for getting the break by details
-- Return:     NUMBER
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_break_by RETURN NUMBER
IS
  ln_break_by  NUMBER;
BEGIN
/* Commented by ppandit for Italy - China Joint Fund Project */
-- 		BEGIN
-- 			SELECT   MEANING
-- 			INTO GC_BREAK
-- 			FROM  FND_LOOKUPS
-- 			WHERE LOOKUP_CODE = P_BREAK_BY
-- 			AND LOOKUP_TYPE = 'BREAK_BY_IMB';
-- 		EXCEPTION
-- 			WHEN NO_DATA_FOUND THEN
-- 				GC_BREAK:=NULL;
-- 		END;
-- 		RETURN  (GC_BREAK);
  SELECT p_break_by
    INTO ln_break_by
    FROM SYS.dual;
  RETURN (ln_break_by);
END;

--========================================================================
-- FUNCTION : get_detail_param         Public
-- PARAMETERS: None
-- RETURN :    VARCHAR2
-- COMMENT   : This function is called by Inventory Master Book Report to gets p_detail
-- EXCEPTIONS: no_data_found
--========================================================================
FUNCTION get_detail_param RETURN VARCHAR2
IS
  lc_detail_param  VARCHAR2(10);
BEGIN
  SELECT p_detail
    INTO lc_detail_param
    FROM SYS.dual;
  RETURN (lc_detail_param);
END;

--========================================================================
-- FUNCTION : get_include_item_cost         Public
-- PARAMETERS: None
-- RETURN :    VARCHAR2
-- COMMENT   : This Function is called by Inventory Master Book Report to gets the break by p_include_item_cost
-- EXCEPTIONS: no_data_found
--========================================================================
FUNCTION get_include_item_cost RETURN VARCHAR2
IS
  lc_incl_cost  VARCHAR2(10);
BEGIN
  SELECT p_include_item_cost
    INTO lc_incl_cost
    FROM SYS.dual;
  RETURN (lc_incl_cost);
END;

-- +==========================================================================+
-- FUNCTION: get_detail_level
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the detail level
-- like Summary, Detail, Intermidiate
-- Return:     VARCHAR2
-- PRE-COND:   none
-- EXCEPTIONS: none
-- +==========================================================================+
FUNCTION get_detail_level RETURN VARCHAR2 IS
BEGIN
  RETURN (gc_detail);
END get_detail_level;

-- +==========================================================================+
-- FUNCTION: get_date_from
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the Lower of Date Range
-- Added by ppandit for Italy and China JF Project
-- Return: VARCHAR2
-- +==========================================================================+
FUNCTION get_date_from
  RETURN VARCHAR2
IS
  lc_date VARCHAR2 (50);
BEGIN
  SELECT TO_CHAR (TO_DATE (p_date_from, 'YYYY/MM/DD HH24:MI:SS'), FND_PROFILE.value('ICX_DATE_FORMAT_MASK'))
    INTO lc_date
    FROM SYS.dual;

  RETURN (lc_date);
END get_date_from;

-- +==========================================================================+
-- FUNCTION: get_date_to
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the Higher of Date Range
--
-- Return: VARCHAR2
-- +==========================================================================+
FUNCTION get_date_to
  RETURN VARCHAR2
IS
  lc_date VARCHAR2 (50);
BEGIN
  SELECT TO_CHAR (TO_DATE (p_date_to, 'YYYY/MM/DD HH24:MI:SS'), FND_PROFILE.value ('ICX_DATE_FORMAT_MASK'))
    INTO lc_date
    FROM SYS.dual;

  RETURN (lc_date);
END get_date_to;

-- +==========================================================================+
-- FUNCTION: get_trx_action
-- PARAMETERS: p_transaction_id
-- COMMENT:
-- This procedure is called by the  Inventory Master Book Report to get the Higher of Date Range
-- Added by ppandit for Italy and China JF Project
-- Return: VARCHAR2
-- +==========================================================================+
FUNCTION get_trx_action (p_transaction_id IN NUMBER)
  RETURN VARCHAR2
IS
  lc_transaction_action  VARCHAR2 (80);
BEGIN
  SELECT MLS.meaning
    INTO lc_transaction_action
    FROM mtl_material_transactions MMT
        ,mfg_lookups               MLS
   WHERE MLS.lookup_code         = MMT.transaction_action_id
     AND MLS.lookup_type         = 'MTL_TRANSACTION_ACTION'
     AND MMT.transaction_id      = p_transaction_id;

  RETURN (lc_transaction_action);
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

--========================================================================
-- FUNCTION : CF_TITLEFORMULA         Public
-- PARAMETERS: None
-- RETURN : VARCHAR2
-- COMMENT   :This Function is called by Inventory Master Book Report to the title
-- EXCEPTIONS: OTHERS
--========================================================================

  FUNCTION CF_TITLEFORMULA RETURN CHAR IS
    TITLE VARCHAR2(40);
  BEGIN
    TITLE := '';
    IF P_DETAIL = 'S' THEN
      TITLE := 'Summary Level';
    ELSIF P_DETAIL = 'I' THEN
      TITLE := 'Intermediate Level';
    ELSIF P_DETAIL = 'D' THEN
      TITLE := 'Detail Level';
    END IF;
    IF P_INCLUDE_ITEM_COST = 'Y' THEN
      RETURN (CONCAT(TITLE
                   ,' - Cost Included'));
    ELSE
      RETURN (TITLE);
    END IF;
  END CF_TITLEFORMULA;

-- +==========================================================================+
-- FUNCTION: get_abc_group_name
-- PARAMETERS: None
-- Return : VARCHAR2
-- COMMENT:
-- This function is called by Inventory Master Book Report for getting the ABC Group Name
-- for a given ABC Group
-- PRE-COND:    none
-- EXCEPTIONS:  none
-- +==========================================================================+
  FUNCTION get_abc_group_name RETURN VARCHAR2 IS
  BEGIN
    RETURN gc_abc_group_name;
  END get_abc_group_name;

-- +==========================================================================+
-- FUNCTION: get_include_cost
-- PARAMETERS: None
-- COMMENT:
-- This procedure is called by the Inventory Master Book Report which returns 'Y/N'
-- Return:      VARCHAR2
-- PRE-COND:    none
-- EXCEPTIONS:  none
-- +==========================================================================+
  FUNCTION get_include_cost RETURN VARCHAR2 IS
  BEGIN
    RETURN gc_include_cost;
  END get_include_cost;

--========================================================================
-- FUNCTION : CF_COUNT_ROWSFORMULA         PRIVATE
-- PARAMETERS: None
-- COMMENT   :
-- EXCEPTIONS: OTHERS
--========================================================================

  FUNCTION CF_COUNT_ROWSFORMULA RETURN NUMBER IS
    COUNT_ROWS NUMBER;
  BEGIN
    SELECT
      count(*)
    INTO COUNT_ROWS
    FROM
      CST_MGD_MSTR_BOOK_TEMP;
    RETURN (COUNT_ROWS);
  END CF_COUNT_ROWSFORMULA;

  FUNCTION P_DATE_FROMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_DATE_FROMVALIDTRIGGER;

  FUNCTION CF_TXN_GROUP_TYPEFORMULA(TXN_TYPE_QTY IN NUMBER) RETURN CHAR IS

  BEGIN
    IF TXN_TYPE_QTY > 0 THEN
      RETURN (GC_TXT_RECEIPT);
    ELSE
      RETURN (GC_TXT_ISSUE);
    END IF;
  END CF_TXN_GROUP_TYPEFORMULA;

  FUNCTION CF_FINAL_QUANTITYFORMULA(CS_FINAL_QUANTITY IN NUMBER
                                   ,CS_B_QTY IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(CS_FINAL_QUANTITY
              ,0) + NVL(CS_B_QTY
              ,0));
  END CF_FINAL_QUANTITYFORMULA;


--========================================================================
-- PROCEDURE : get_acct_period_id      PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_rpt_from_date         Report start date
--             P_rpt_to_date           Report end date
--             x_rpt_from_acct_per_id  Report start account period ID
--             x_rpt_to_acct_per_id    Report end account period ID
-- COMMENT   : Get the account period IDs for user defined reporting
--             period
-- EXCEPTIONS:
--========================================================================
PROCEDURE get_acct_period_id (
  p_org_id               IN  NUMBER
, p_rpt_from_date        IN  VARCHAR2
, p_rpt_to_date          IN  VARCHAR2
, x_rpt_from_acct_per_id OUT NOCOPY NUMBER
, x_rpt_to_acct_per_id   OUT NOCOPY NUMBER
)
IS
l_rpt_from_acct_per_id NUMBER;
l_rpt_to_acct_per_id   NUMBER;
l_rpt_from_date	       DATE;
l_rpt_to_date	       DATE;

-- Cursor to retrieve from accounting period id
CURSOR from_acct_period_cur(c_rpt_from_date DATE)
IS
SELECT
  f.acct_period_id
FROM
  org_acct_periods f
WHERE f.organization_id      = p_org_id
  AND f.period_start_date   <= c_rpt_from_date
  AND f.schedule_close_date >= c_rpt_from_date
  AND F.Open_Flag           = 'N'
  AND F.Period_Close_Date IS NOT NULL;

-- Cursor to retrieve to accounting period id
CURSOR to_acct_period_cur(c_rpt_to_date DATE)
IS
SELECT
  t.acct_period_id
FROM
  org_acct_periods t
WHERE t.organization_id      = p_org_id
  AND t.period_start_date   <= c_rpt_to_date
  AND t.schedule_close_date >= c_rpt_to_date
  AND T.Open_Flag           = 'N'
  AND T.Period_Close_Date IS NOT NULL;

-- Exception
acct_period_not_found_exc  EXCEPTION;

BEGIN
  l_rpt_from_date := TRUNC(FND_DATE.canonical_to_date(p_rpt_from_date));
  l_rpt_to_date   := TRUNC(FND_DATE.canonical_to_date(p_rpt_to_date));

  -- Get from account period id
  OPEN from_acct_period_cur(TO_DATE(p_date_from, 'YYYY/MM/DD HH24:MI:SS'));
 FETCH from_acct_period_cur
  INTO x_rpt_from_acct_per_id;

  IF from_acct_period_cur%NOTFOUND THEN
    RAISE acct_period_not_found_exc;
  END IF;
  CLOSE from_acct_period_cur;

  -- Get to account period id
  OPEN to_acct_period_cur(TO_DATE(p_date_to, 'YYYY/MM/DD HH24:MI:SS') + (86399 / 86400)); -- Changed by ppandit for using params directly, Italy China Enhancements
  FETCH to_acct_period_cur
   INTO x_rpt_to_acct_per_id;

  IF to_acct_period_cur%NOTFOUND THEN
    RAISE acct_period_not_found_exc;
  END IF;
  CLOSE to_acct_period_cur;

EXCEPTION

  WHEN acct_period_not_found_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_ND_ACCT_PER_ID');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_Period_ID'
                             );
    END IF;
    RAISE ;


  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Acct_Period_ID'
                             );
    END IF;
    RAISE;

END get_acct_period_id;

--========================================================================
-- PROCEDURE : Get_Unit_Infl_Adj_Cost  PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_acct_period_id        Account period ID
--             p_item_id               Inventory item ID
--             x_unit_infl_adj         Inventory item period end unit
--                                     inflation adjusted cost
--           : x_init_qty              Period begin quantity
-- COMMENT   : Retrieve item unit inflation adjusted cost and begin
--             quantity
-- EXCEPTIONS:
--========================================================================
PROCEDURE get_unit_infl_adj_cost (
  p_org_id             IN  NUMBER
, p_acct_period_id     IN  NUMBER
, p_item_id            IN  NUMBER
, x_unit_infl_adj      OUT NOCOPY NUMBER
, x_init_qty           OUT NOCOPY NUMBER
)
IS
l_final_infl_adj NUMBER;
l_final_qty      NUMBER;
BEGIN

  SELECT
    Begin_Qty
  , NVL((Actual_Inflation_Adj - Issue_Inflation_Adj), 0)
  , NVL((Actual_Qty - Issue_Qty), 0)
  INTO
    x_init_qty
  , l_final_infl_adj
  , l_final_qty
  FROM
    CST_MGD_INFL_ADJUSTED_COSTS
  WHERE Organization_ID   = p_org_id
    AND Acct_Period_ID    = p_acct_period_id
    AND Inventory_Item_ID = p_item_id;

  IF l_final_qty = 0
  THEN
    x_unit_infl_adj := 0;
  ELSE
    x_unit_infl_adj := l_final_infl_adj/l_final_qty;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Unit_Infl_Adj_Cost'
                             );
    END IF;
    RAISE;

END get_unit_infl_adj_cost;


--========================================================================
-- PROCEDURE : Get_Txn_Type            PRIVATE
-- PARAMETERS: p_txn_type_id           Transaction type ID
--             x_txn_type_name         Transaction type name
-- COMMENT   : Retrieve transaction type name from ID
-- EXCEPTIONS:
--========================================================================
PROCEDURE Get_Txn_Type (
  p_txn_type_id   IN  NUMBER
, x_txn_type_name OUT NOCOPY VARCHAR2
)
IS
BEGIN

  SELECT
    Transaction_Type_Name
  INTO
    x_txn_type_name
  FROM
    MTL_TRANSACTION_TYPES
  WHERE Transaction_Type_ID = p_txn_type_id;

-- Bug#2433926 fix no validation for transaction type disable date
--    AND NVL(Disable_Date, SYSDATE + 1) > SYSDATE;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Get_Txn_Type'
                             );
    END IF;
    RAISE;

END Get_Txn_Type;

--========================================================================
-- PROCEDURE : get_item_txn_info       PRIVATE
-- PARAMETERS: p_org_id                Organization ID
--             p_item_id               Inventory item ID
--             p_acct_period_id        Mfg accounting period ID
--             p_per_first_txn_date    First transaction date for
--                                     reporting.
--             p_per_last_txn_date     Last transaction date for
--                                     reporting.
--             p_item_unit_cost        Inventory item unit average cost
--             p_primary_cost_method   Primary Cost Method of Organization
--             p_item_init_qty         Inventory item period begin
--                                     quantity
--             p_item_unit_infl_adj    Inventory item period end unit
--                                     inflation adjusted cost
--             x_rpt_item_tbl_rec      Report data record
-- COMMENT   : Builds data for one row
-- Bug3118846 fix : exclude NON qty tracked subinventories trx
-- EXCEPTION : g_txn_cost_exc          Missing transaction costs.
--========================================================================
PROCEDURE get_item_txn_info (
  p_org_id               IN  NUMBER
, p_item_id              IN  NUMBER
, p_uom_code             IN  VARCHAR2  --added for inv book
, p_item_code            IN  VARCHAR2
, p_item_desc            IN  VARCHAR2
, p_org_name             IN  VARCHAR2
, p_currency_code        IN  VARCHAR2
, p_subinv_from          IN  VARCHAR2
, p_subinv_to            IN  VARCHAR2
, p_acct_period_id       IN  NUMBER
, p_per_first_txn_date   IN  VARCHAR2
, p_per_last_txn_date    IN  VARCHAR2
, p_item_unit_cost       IN  NUMBER
, p_primary_cost_method  IN  NUMBER
, p_item_init_qty        IN  NUMBER
, p_item_init_infl       IN  NUMBER
, p_item_unit_infl_adj   IN  NUMBER
, x_rpt_item_tbl_rec     OUT NOCOPY Report_Tbl_Rec_Type
)
IS
l_rpt_item_tbl_rec     Report_Tbl_Rec_Type;
l_txn_init_qty         NUMBER;
l_txn_init_infl        NUMBER;
l_prev_acct_period_id  NUMBER;
l_prev_sch_close_date  DATE;
l_index                BINARY_INTEGER := 1;
l_begin_unit_cost      NUMBER;
l_txn_cost_exc         EXCEPTION;
l_per_first_txn_date   DATE;
l_per_last_txn_date    DATE;
l_primary_qty          NUMBER;
l_total_cost           NUMBER;
-- Bug#2799104 fix: to exclude WIP scrap transaction and
-- WIP cost update transaction
-- value_change for Average Cost Update transaction
-- Bug#7458643 fix: quantity_adjusted added
CURSOR l_item_txn_csr IS
  SELECT mmt.transaction_id transaction_id,
         mmt.transaction_type_id transaction_type_id,
         mmt.transaction_source_type_id transaction_source_type_id,
         mmt.transaction_action_id transaction_action_id,
         mmt.transaction_date transaction_date,
         mmt.primary_quantity primary_quantity, mmt.actual_cost actual_cost,
         mmt.prior_cost prior_cost, mmt.new_cost new_cost,
         mmt.value_change value_change,
         mmt.percentage_change percentage_change,
         mmt.transfer_organization_id transfer_organization_id,
         mmt.creation_date creation_date, mmt.quantity_adjusted,
         NVL (mmt.subinventory_code, ' ') subinventory_code, mmt.organization_id  subinventory_org_id
    FROM mtl_material_transactions mmt
   WHERE mmt.organization_id = p_org_id
     AND mmt.inventory_item_id = p_item_id
     AND NVL (mmt.acct_period_id, 0) =
                           NVL (p_acct_period_id, NVL (mmt.acct_period_id, 0))
     AND NVL (mmt.subinventory_code, '0') >=
                         NVL (p_subinv_from, NVL (mmt.subinventory_code, '0'))
     AND NVL (mmt.subinventory_code, '0') <=
                           NVL (p_subinv_to, NVL (mmt.subinventory_code, '0'))
     AND mmt.transaction_date BETWEEN TO_DATE(p_date_from, 'YYYY/MM/DD HH24:MI:SS') AND TO_DATE(p_date_to, 'YYYY/MM/DD HH24:MI:SS') + (86399 / 86400) -- Changed by ppandit for using params directly, Italy China Enhancements
     AND (   mmt.subinventory_code IS NULL
          OR mmt.subinventory_code =
                (SELECT secondary_inventory_name
                   FROM mtl_secondary_inventories
                  WHERE secondary_inventory_name = mmt.subinventory_code
                    AND organization_id = mmt.organization_id
                    AND quantity_tracked = 1
                    AND asset_inventory = 1)
         )
     AND mmt.transaction_id NOT IN (
            SELECT mmt1.transaction_id
              FROM mtl_material_transactions mmt1
             WHERE mmt1.organization_id = p_org_id
               AND mmt1.inventory_item_id = p_item_id
               AND NVL (mmt1.acct_period_id, 0) =
                          NVL (p_acct_period_id, NVL (mmt1.acct_period_id, 0))
               AND NVL (mmt1.subinventory_code, '0') >=
                        NVL (p_subinv_from, NVL (mmt1.subinventory_code, '0'))
               AND NVL (mmt1.subinventory_code, '0') <=
                          NVL (p_subinv_to, NVL (mmt1.subinventory_code, '0'))
               AND mmt1.transaction_source_type_id = 5
               AND mmt1.transaction_action_id = 24
               AND NVL (mmt1.owning_tp_type, 2) = 1)
     AND mmt.transaction_action_id <> 30
     AND NVL (mmt.owning_tp_type, 2) <> 1
ORDER BY mmt.acct_period_id,
         TRUNC (mmt.transaction_date),
         mmt.creation_date,
         mmt.transaction_id;



BEGIN

-- The From date is at midnight for the day
l_per_first_txn_date:=TRUNC(FND_DATE.canonical_to_date(p_per_first_txn_date));
-- The to date is at 23:59:59 of that date entered.
l_per_last_txn_date:=TRUNC(FND_DATE.canonical_to_date(p_per_last_txn_date)) + (86399 / 86400);

  l_txn_init_qty  := p_item_init_qty;
  l_txn_init_infl := p_item_init_infl;


  FOR l_item_txn_info IN l_item_txn_csr
  LOOP

  -- =====================================================================
  -- Bug#2799104 fix: Average Cost Update display
  -- check whether the transaction is Average Cost Update
  -- If so, then value_change is the total cost
  -- for all other ACU transactions it is quantity_adjusted * actual_cost
  -- Bug#2977020 fix: support percentage and new average cost
  -- Set the Total Transaction Cost and primary quantity
  -- =====================================================================
  IF l_item_txn_info.transaction_source_type_id = 13 AND
     l_item_txn_info.transaction_action_id = 24  THEN
    -- Average Cost Update transaction
    IF l_item_txn_info.value_change IS NOT NULL THEN
      -- ACU type is value change
      l_primary_qty := 0; -- to avoid double counting of total quantity
      l_total_cost := l_item_txn_info.value_change;
    ELSIF l_item_txn_info.percentage_change IS NOT NULL THEN
      -- ACU type is percentage
      l_primary_qty := 0; -- to avoid double counting of total quantity
      l_total_cost := (l_item_txn_info.new_cost - l_item_txn_info.prior_cost) * l_item_txn_info.quantity_adjusted;
    ELSE
      -- ACU type New Average Cost
      l_primary_qty := 0; -- to avoid double counting of total quantity
      l_total_cost := (l_item_txn_info.new_cost - l_item_txn_info.prior_cost) * l_item_txn_info.quantity_adjusted;
    END IF;

  ELSIF l_item_txn_info.transaction_source_type_id = 11 AND
     l_item_txn_info.transaction_action_id = 24  THEN
     -- FP Bug#7458643 fix: Standard Cost Update transaction
      l_primary_qty := 0; -- to avoid double counting of total quantity
      l_total_cost := (l_item_txn_info.new_cost - l_item_txn_info.prior_cost) * l_item_txn_info.quantity_adjusted;
  ELSE
    -- all other transactions
  l_primary_qty := l_item_txn_info.primary_quantity;
  l_total_cost  := l_primary_qty * l_item_txn_info.actual_cost;
  END IF;

    IF (l_item_txn_info.Actual_Cost IS NULL) THEN
       l_item_txn_info.Actual_Cost := 0;
    END IF;

    IF (l_item_txn_info.Prior_Cost IS NULL) THEN
       l_item_txn_info.Prior_Cost := 0;
    END IF;

    IF (l_item_txn_info.New_Cost IS NULL) THEN
       l_item_txn_info.New_Cost := 0;
    END IF;

    l_rpt_item_tbl_rec(l_index).organization_id         := p_org_id;
    l_rpt_item_tbl_rec(l_index).inventory_item_id       := p_item_id;
    l_rpt_item_tbl_rec(l_index).uom_code                := p_uom_code;
    l_rpt_item_tbl_rec(l_index).org_name                := p_org_name;
    l_rpt_item_tbl_rec(l_index).subinventory_code       := l_item_txn_info.subinventory_code;   -- Added by ppandit for Italy and China Enhancements
    l_rpt_item_tbl_rec(l_index).sub_inv_organization_id := l_item_txn_info.subinventory_org_id; -- Added by ppandit for Italy and China Enhancements
    l_rpt_item_tbl_rec(l_index).item_code               := p_item_code;
    l_rpt_item_tbl_rec(l_index).item_desc               := p_item_desc;
    l_rpt_item_tbl_rec(l_index).currency_code           := p_currency_code;
    l_rpt_item_tbl_rec(l_index).txn_date                :=
                                    l_item_txn_info.Transaction_Date;
    -- Bug 4086259 to insert creation_date into temp table
    l_rpt_item_tbl_rec(l_index).creation_date           := l_item_txn_info.creation_date;

    -- Bug#2904882 fix: transaction_id included for correct sort
    l_rpt_item_tbl_rec(l_index).transaction_id          :=
                                    l_item_txn_info.Transaction_id;

    begin
  -- Get Txn_Source_Type_Name
    Select Transaction_source_type_name
    Into   l_rpt_item_tbl_rec(l_index).txn_source
    From   MTL_TXN_SOURCE_TYPES
    Where  Transaction_Source_Type_Id = l_item_txn_info.transaction_source_type_id;
    exception
       when no_data_found then
	  select 'No TXN Source'
          INTO l_rpt_item_tbl_rec(l_index).txn_source
          from dual;
    end;

    Get_Txn_Type
    ( p_txn_type_id   => l_item_txn_info.Transaction_Type_ID
    , x_txn_type_name => l_rpt_item_tbl_rec(l_index).txn_type
    );

    -- =======================================================================
    -- Beginning Balance - Beginning quantity and begin cost for each txn
    -- =======================================================================
    l_rpt_item_tbl_rec(l_index).txn_ini_qty            := l_txn_init_qty;
    -- Bug#3013597 fix: begin unit cost based on costing method of organization
    IF p_primary_cost_method = 1 THEN
      -- Standard costing organization
      l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost      :=
        l_item_txn_info.prior_Cost;
    ELSE
      -- Average 2, FIFO 5, LIFO 6 organizations
      l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost      :=
      l_item_txn_info.Prior_Cost;
    END IF;

    -- ==================================================================
    -- Beginning balance -- Beginnning quantity * begin cost for each txn
    -- ==================================================================
    l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty *
      l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost := l_txn_init_infl;

    -- ==================================================================
    -- Final quantity for each transaction
    -- ==================================================================
    -- Total quantity including current transaction quantity
    -- Total quantity = Begin qty + transaction quantity
    -- For Standard Cost Update or Average Cost Update, primary_quantity
    -- will be set to 0 in the earlier logic to avoid double counting
    -- ==================================================================
    l_rpt_item_tbl_rec(l_index).txn_fnl_qty            :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty +
      l_primary_qty;

    -- =============================================================
    -- Final Cost for each transaction
    -- New Cost which is the final cost after processing current txn
    -- =============================================================
    IF p_primary_cost_method = 1 THEN
      -- Standard costing organization
      l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost      :=
        l_item_txn_info.New_Cost;
    ELSE
      -- Average 2, FIFO 5, LIFO 6 organizations
      l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost      :=
        l_item_txn_info.New_Cost;
    END IF;

     -- ==========================================================
     -- Final total balance
     -- ==========================================================
     -- all transactions
      l_rpt_item_tbl_rec(l_index).txn_fnl_h_total_cost  :=
      l_rpt_item_tbl_rec(l_index).txn_fnl_qty *
      l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost;

    IF ((l_item_txn_info.Primary_Quantity > 0)
        AND
       (l_item_txn_info.Transfer_Organization_ID IS NULL))
       OR
       (l_item_txn_info.Transfer_Organization_ID = p_org_id)
    THEN
      l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost :=
      l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost;
    ELSE
      l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost :=
        l_rpt_item_tbl_rec(l_index).txn_fnl_qty * p_item_unit_infl_adj;
    END IF;

    -- ===============================================================
    -- Transaction Quantity and Transaction Cost of each transaction
    -- Bug 7458643 fix: For Standard Cost Update - src_type_id is 11.
    -- Average Cost Update - src_type_id is 13, l_primary_qty is zero.
    -- For all other txns, l_primary_quantity has not null value.
    -- ===============================================================
    l_rpt_item_tbl_rec(l_index).txn_qty  := l_primary_qty;

    -- ======================================================
    -- Transaction Cost of each transaction
    -- ======================================================
    -- Bug 7458643 fix: standard cost update
    -- transaction unit cost is diff of new_cost - prior_cost
    -- for all other txns, actual_cost is a transaction cost
    -- Note that for Average Cost Update txn, actual_cost will
    -- have item adjustment cost.
    -- ======================================================
    IF l_item_txn_info.transaction_source_type_id = 11 AND
      l_item_txn_info.transaction_action_id = 24  THEN
      l_rpt_item_tbl_rec(l_index).txn_unit_cost  :=
        (l_item_txn_info.new_Cost - l_item_txn_info.prior_Cost);
    ELSE
      l_rpt_item_tbl_rec(l_index).txn_unit_cost  :=
        l_item_txn_info.Actual_Cost;
    END IF;

    -- =======================================================
    -- Transaction Total Cost -- Txn Cost * txn quantity
    -- =======================================================
    -- total cost takes the value according to transaction type
    -- Bug#2799104 fix
    l_rpt_item_tbl_rec(l_index).txn_h_total_cost       :=
      l_total_cost;
    l_rpt_item_tbl_rec(l_index).txn_adj_total_cost     :=
      l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost -
      l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost;

    -- ====================================================================
    -- Set initial quantity to final quantity so far for the next
    -- transaction, so that for the next transaction initial quantity will
    -- be final qty until previous transaction before the current txn
    -- being processed
    -- ====================================================================
    l_txn_init_qty  := l_rpt_item_tbl_rec(l_index).txn_fnl_qty;
    l_txn_init_infl := l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost;

    l_index        := l_index + 1;
  END LOOP;

  IF NVL(l_rpt_item_tbl_rec.FIRST, 0) = 0
  THEN

    l_rpt_item_tbl_rec(l_index).organization_id        := p_org_id;
    l_rpt_item_tbl_rec(l_index).inventory_item_id      := p_item_id;
    l_rpt_item_tbl_rec(l_index).uom_code               := p_uom_code;
    l_rpt_item_tbl_rec(l_index).org_name               := p_org_name;
    l_rpt_item_tbl_rec(l_index).item_code              := p_item_code;
    l_rpt_item_tbl_rec(l_index).item_desc              := p_item_desc;
    l_rpt_item_tbl_rec(l_index).currency_code          := p_currency_code;
    l_rpt_item_tbl_rec(l_index).txn_ini_qty            := l_txn_init_qty;


    l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost      := p_item_unit_cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty *
      l_rpt_item_tbl_rec(l_index).txn_ini_unit_cost;
    l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost := p_item_init_infl;
    l_rpt_item_tbl_rec(l_index).txn_fnl_qty            :=
      l_rpt_item_tbl_rec(l_index).txn_ini_qty;
    l_rpt_item_tbl_rec(l_index).txn_fnl_unit_cost      := p_item_unit_cost;
    l_rpt_item_tbl_rec(l_index).txn_fnl_h_total_cost   :=
      l_rpt_item_tbl_rec(l_index).txn_ini_h_total_cost;
    l_rpt_item_tbl_rec(l_index).txn_fnl_adj_total_cost :=
      l_rpt_item_tbl_rec(l_index).txn_ini_adj_total_cost;
  END IF;

  x_rpt_item_tbl_rec := l_rpt_item_tbl_rec;

EXCEPTION

  WHEN l_txn_cost_exc THEN
    FND_MESSAGE.Set_Name('BOM', 'CST_MGD_INFL_UNIT_COST_NULL');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'get_item_txn_info'
                             );
    END IF;
    RAISE g_txn_cost_exc;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'get_item_txn_info'
                             );
    END IF;
    RAISE;

END get_item_txn_info;

--========================================================================
-- PROCEDURE : create_inv_msbk_rpt     PUBLIC
-- PARAMETERS: p_org_id                Organization ID
--             p_item_from_code        Report start item code
--             p_item_to_code          Report end item code
--             p_rpt_from_date         Report start date
--             p_rpt_to_date           Report end date
-- COMMENT   : Main procedure called by Inventory Master Book report
--========================================================================
PROCEDURE create_inv_msbk_rpt (
                               p_org_id               IN  NUMBER
                              ,p_category_set_id_from IN  NUMBER
                              ,p_category_set_id_to   IN  NUMBER
                              ,p_category_from        IN  VARCHAR2
                              ,p_category_to          IN  VARCHAR2
                              ,p_subinv_from          IN  VARCHAR2
                              ,p_subinv_to            IN  VARCHAR2
                              ,p_abc_group_id         IN  NUMBER
                              ,p_abc_class_id         IN  NUMBER
                              ,p_item_from_code       IN  VARCHAR2
                              ,p_item_to_code         IN  VARCHAR2
                              ,p_rpt_from_date        IN  VARCHAR2
                              ,p_rpt_to_date          IN  VARCHAR2
                              )
IS
l_rpt_item_tbl_rec     Report_Tbl_Rec_Type;
TYPE lcu_ref_cursor    IS REF CURSOR;
lr_ref_cursor          lcu_ref_cursor;
l_item_id              NUMBER;
l_uom_code             VARCHAR2 (3);  -- added for inv book
l_item_unit_cost       NUMBER;
l_begin_unit_cost      NUMBER;
base_period_id         NUMBER;
base_qty               NUMBER;
txn_count              NUMBER;
additional_qty         NUMBER;
l_rpt_from_acct_per_id NUMBER;
l_rpt_to_acct_per_id   NUMBER;
l_final_infl_adj       NUMBER;
l_final_qty            NUMBER;
l_purchase_qty         NUMBER;
l_unit_infl_adj        NUMBER;
l_per_begin_qty        NUMBER;
l_begin_infl_adj       NUMBER;
l_per_first_txn_date   DATE;
l_per_last_txn_date    DATE;
l_period_start_date    DATE;
l_period_close_date    DATE;
l_period_open_flag     VARCHAR2(1);
l_msi_segment          VARCHAR2(200);  -- Added by ppandit
l_cat_segment          VARCHAR2(200);  -- Added by ppandit
lc_cat_string          VARCHAR2(200);  -- Added by ppandit
l_struct               NUMBER;         -- Added by ppandit
l_index                BINARY_INTEGER;
d_org_name             VARCHAR2(240);
d_currency_code        VARCHAR2(15);
d_item_desc            VARCHAR2(240);
d_item_code            VARCHAR2(40);
subinv_min             VARCHAR2(10);
subinv_max             VARCHAR2(10);
subinv_from            VARCHAR2(10);
subinv_to              VARCHAR2(10);
l_rpt_from_date	       DATE;
l_rpt_to_date	       DATE;
l_item_ohq             NUMBER ;
l_item_trx_qty         NUMBER ;

-- primary costing method of an inventory organization
l_primary_cost_method  NUMBER;

--variables for dynamic sql query
--v_cursorID	       INTEGER;
v_select_clause        VARCHAR2(4000);
v_from_clause          VARCHAR2(4000);
v_where_clause         VARCHAR2(8000);
v_order_by             VARCHAR2(4000);
v_final_query          VARCHAR2(32767);
--v_dummy                INTEGER;

-- Cursor to get primary costing method of an inventory organization
CURSOR get_cost_method_cur (c_organization_id  NUMBER)
IS
  SELECT
    primary_cost_method
  FROM
    mtl_parameters
  WHERE
    organization_id = c_organization_id;

CURSOR lcu_cat_range (p_cat_set_id In NUMBER)
IS
  SELECT category_set_name
   FROM mtl_category_sets
   WHERE category_set_id = p_cat_set_id;

lc_cat_set_high  VARCHAR2 (30);
lc_cat_set_low   VARCHAR2 (30);

-- Exception for cost method not found
cost_method_not_found_except  EXCEPTION;

BEGIN
-- The From date is at midnight for the day
l_rpt_from_date := TRUNC (FND_DATE.canonical_to_date (p_rpt_from_date));
-- The to date is at 23:59:59 of that date entered.
l_rpt_to_date   := TRUNC (FND_DATE.canonical_to_date (p_rpt_to_date)) + (86399 / 86400);

---- Open Corsor for processing
--v_CursorID := DBMS_SQL.OPEN_CURSOR;

--Bug # 4912772 Performance issue in the dynamic query resolved by restructuring the query

v_select_clause := NULL;
v_from_clause   := NULL;
v_where_clause  := NULL;
v_order_by      := NULL;
v_final_query   := NULL;

-- If one of the ranges for a subinventory is missing then retrieve the min and max values
IF p_subinv_from IS NULL AND p_subinv_to IS NOT NULL THEN
   SELECT MIN (secondary_inventory_name)
     INTO subinv_min
     FROM mtl_secondary_inventories
    WHERE organization_id = p_org_id;
END IF;

IF p_subinv_from IS NOT NULL AND p_subinv_to IS NULL THEN
   SELECT MAX (secondary_inventory_name)
     INTO subinv_max
     FROM mtl_secondary_inventories
    WHERE organization_id = p_org_id;
END IF;

   OPEN lcu_cat_range (p_category_set_id_from);
  FETCH lcu_cat_range INTO lc_cat_set_high;
  CLOSE lcu_cat_range;

   OPEN lcu_cat_range (p_category_set_id_to);
  FETCH lcu_cat_range INTO lc_cat_set_low;
  CLOSE lcu_cat_range;

/* Logic added for inclusion of Category Set Range and dynamic decision on mtl_system_items_b segments by ppandit start */
FOR r_cat IN (
              SELECT category_set_id
                FROM mtl_category_sets
               WHERE category_set_name BETWEEN lc_cat_set_high AND lc_cat_set_low
                 AND mult_item_cat_assign_flag = 'N'
                 ORDER BY category_set_id ASC
             )
LOOP

l_struct      := get_structure_id (r_cat.category_set_id);
l_cat_segment := get_category_structure ('CAT' , l_struct);
l_msi_segment := get_category_structure ('ITEM', l_struct);

IF l_msi_segment IS NOT NULL THEN
-- Bug#3147073 : exclude expense items
v_select_clause := 'SELECT DISTINCT MSI.inventory_item_id
                                   ,MSI.primary_uom_code
                                   ,' || l_msi_segment ||
                                  ',MSI.description
                                   ,OOD.organization_name
                                   ,GSOB.currency_code ';

v_from_clause := ' FROM mtl_system_items_b            MSI
                       ,gl_sets_of_books              GSOB
                       ,org_organization_definitions  OOD
                       ,mtl_material_transactions     MTX ';

v_where_clause := '  WHERE MSI.organization_id      = ' || p_org_id ||
		     ' AND OOD.organization_id      = MSI.organization_id
		       AND OOD.set_of_books_id      = GSOB.set_of_books_id
                       AND MSI.inventory_asset_flag = ''Y''
		       AND MSI.inventory_item_id    = MTX.inventory_item_id
		       AND MTX.organization_id      = ' || p_org_id ||
	             ' AND MTX.costed_flag IS NULL
	               AND MTX.transaction_date BETWEEN TO_DATE(''' || p_date_from || ''',''YYYY/MM/DD HH24:MI:SS'') AND TO_DATE(''' || p_date_to || ''',''YYYY/MM/DD HH24:MI:SS'') + (86399 / 86400)';

--main order by clause
v_order_by := ' ORDER BY MSI.inventory_item_id';

IF p_subinv_from IS NOT NULL OR p_subinv_to IS NOT NULL THEN
 v_where_clause := v_where_clause || '   AND MTX.subinventory_code >= ''' || p_subinv_from || '''' ||
		                       ' AND MTX.subinventory_code <= ''' || p_subinv_to   || '''';
END IF;

IF p_category_from IS NOT NULL AND p_category_to IS NOT NULL
THEN
  lc_cat_string := ' AND ' || l_cat_segment || ' BETWEEN ''' || p_category_from || ''' AND ''' || p_category_to || '''';
ELSIF p_category_from IS NULL AND p_category_to IS NULL THEN
  lc_cat_string := ' AND 1 = 1 ';
END IF;

v_from_clause := v_from_clause || ', mtl_item_categories  MIC
                                   , mtl_category_sets    MCS
                                   , mtl_categories_b     MCK ';

v_where_clause := v_where_clause ||   ' AND MIC.organization_id   = '  || p_org_id ||
               		              ' AND MIC.category_set_id   = MCS.category_set_id
                                        AND MCS.category_set_id   = ' || r_cat.category_set_id  ||
                                      ' AND MCK.category_id       = MIC.category_id ' ||
                                        lc_cat_string ||
                                      ' AND MIC.inventory_item_id = MSI.inventory_item_id ';

IF p_abc_group_id IS NOT NULL AND p_abc_class_id IS NOT NULL THEN
  v_from_clause := v_from_clause || ',mtl_abc_classes            MAC
                                     ,mtl_abc_assignments        MAA
                                     ,mtl_abc_assignment_groups  MAG ';

  v_where_clause := v_where_clause || '   AND MAC.abc_class_id        = MAA.abc_class_id
				          AND MAA.assignment_group_id = MAG.assignment_group_id
                                          AND MAG.assignment_group_id = ' || p_abc_group_id ||
		                        ' AND MAC.organization_id     = ' || p_org_id       ||
				        ' AND MAC.abc_class_id        = ' || p_abc_class_id ||
				        ' AND MAA.inventory_item_id   =  MSI.inventory_item_id ';

   IF p_subinv_from IS NOT NULL OR p_subinv_to IS NOT NULL THEN
     v_where_clause := v_where_clause || '   AND MAG.secondary_inventory >= ''' || p_subinv_from || '''' ||
				           ' AND MAG.secondary_inventory <= ''' || p_subinv_to   || '''';
    END IF;
ELSE IF p_abc_class_id IS NOT NULL THEN
           v_from_clause := v_from_clause || ',mtl_abc_classes      MAC
                                              ,mtl_abc_assignments  MAA ';
           v_where_clause := v_where_clause || '   AND MAC.abc_class_id      = MAA.abc_class_id
                                                   AND MAC.organization_id   = '  || p_org_id ||
                                                 ' AND MAC.abc_class_id      = '  || p_abc_class_id ||
 				                 ' AND MAA.inventory_item_id =  MSI.inventory_item_id ';
      END IF;
END IF;

IF p_item_from_code IS NOT NULL AND p_item_to_code IS NOT NULL THEN
  v_where_clause := v_where_clause || ' AND ' || l_msi_segment || ' BETWEEN ''' || p_item_from_code || ''' AND ''' || p_item_to_code || '''';
END IF;

v_final_query := v_select_clause || v_from_clause || v_where_clause || v_order_by;

/* ppandit Comment Start - Commented by ppandit for Italy and China JF Project */
-- --Parse the query
-- DBMS_SQL.PARSE(v_cursorID, v_final_query, DBMS_SQL.V7);
--
-- -- Not needed as temporary table
-- -- DELETE FROM CST_MGD_MSTR_BOOK_TEMP;
--
-- --bind the input variables
-- DBMS_SQL.BIND_VARIABLE(v_cursorID,':org_id',p_org_id);
-- DBMS_SQL.BIND_VARIABLE(v_cursorID,':to_date',l_rpt_to_date);
-- DBMS_SQL.BIND_VARIABLE(v_cursorID,':from_date',l_rpt_from_date);
--
-- --for selection of items in a subinventory
-- if p_subinv_from is not null  then
--    DBMS_SQL.BIND_VARIABLE(v_cursorID,':subinv_from',p_subinv_from);
--    subinv_from := p_subinv_from;
-- else if p_subinv_to is not null then
--        DBMS_SQL.BIND_VARIABLE(v_cursorID,':subinv_from',subinv_min);
--        subinv_from := subinv_min;
--      end if;
-- end if;
--
-- if p_subinv_to is not null then
--    DBMS_SQL.BIND_VARIABLE(v_cursorID,':subinv_to',p_subinv_to);
--    subinv_to := p_subinv_to;
-- else if p_subinv_from is not null then
--        DBMS_SQL.BIND_VARIABLE(v_cursorID,':subinv_to',subinv_max);
--        subinv_to := subinv_max;
--      end if;
-- end if;
--
-- --for selection of items in a category
-- if p_category_from is NOT NULL and p_category_to is NOT NULL and p_category_set_id is NOT NULL
-- then
--   DBMS_SQL.BIND_VARIABLE(v_cursorID,':category_from',p_category_from);
--   DBMS_SQL.BIND_VARIABLE(v_cursorID,':category_to',p_category_to);
--   DBMS_SQL.BIND_VARIABLE(v_cursorID,':category_set_id',p_category_set_id);
-- end if;
--
--
-- --for selection of items in a abc_class
-- if p_abc_class_id is NOT NULL then
--    DBMS_SQL.BIND_VARIABLE(v_cursorID,':abc_class_id',p_abc_class_id);
-- end if;
--
-- if p_abc_group_id is NOT NULL then
--    DBMS_SQL.BIND_VARIABLE(v_cursorID,':abc_group_id',p_abc_group_id);
-- end if;
--
-- if p_item_from_code is NOT NULL and p_item_to_code IS NOT NULL then
--    DBMS_SQL.BIND_VARIABLE(v_cursorID,':item_from_code',p_item_from_code);
--    DBMS_SQL.BIND_VARIABLE(v_cursorID,':item_to_code',p_item_to_code);
-- end if;
--
-- --define the output variables
-- DBMS_SQL.DEFINE_COLUMN(v_cursorID, 1, l_item_id);
-- DBMS_SQL.DEFINE_COLUMN(v_cursorID, 2, l_uom_code,3);
-- DBMS_SQL.DEFINE_COLUMN(v_cursorID, 3, d_item_code,40);
-- DBMS_SQL.DEFINE_COLUMN(v_cursorID, 4, d_item_desc,240);
-- DBMS_SQL.DEFINE_COLUMN(v_cursorID, 5, d_org_name,240);
-- DBMS_SQL.DEFINE_COLUMN(v_cursorID, 6, d_currency_code,15);
--
-- --execute the sql statement we don't care about the return value
-- v_dummy := DBMS_SQL.EXECUTE(v_cursorID);

/* Comment by ppandit End */

-- Not needed as the On Hand Qty Does not rely on the MTL_PER_CLOSE_DTLS table
--  Get_Acct_Period_ID_invmbk
--  ( p_org_id               => p_org_id
--  , p_rpt_from_date        => p_rpt_from_date
--  , p_rpt_to_date          => p_rpt_to_date
--  , x_rpt_from_acct_per_id => l_rpt_from_acct_per_id
--  , x_rpt_to_acct_per_id   => l_rpt_to_acct_per_id
--  );

  -- Get costing method of organization

  IF get_cost_method_cur%ISOPEN THEN
    CLOSE get_cost_method_cur;
  END IF;

   OPEN get_cost_method_cur (p_org_id);
  FETCH get_cost_method_cur
   INTO l_primary_cost_method;

  IF get_cost_method_cur%NOTFOUND THEN
    RAISE cost_method_not_found_except;
  END IF;

--LOOP -- Commented by ppandit for Italy and China JF Project

IF lr_ref_cursor%ISOPEN THEN
  CLOSE lr_ref_cursor;
END IF;

OPEN lr_ref_cursor FOR v_final_query; -- Added by ppandit for Italy and China JF Project
LOOP
FETCH lr_ref_cursor INTO l_item_id, l_uom_code, d_item_code, d_item_desc, d_org_name, d_currency_code;
EXIT WHEN lr_ref_cursor%NOTFOUND;

/* ppandit Comment Start - Commented by ppandit for Italy and China JF Project */
-- -- fetch the rows and also check for exit condition
--
-- IF DBMS_SQL.FETCH_ROWS(v_cursorID) = 0 THEN
--   EXIT;
-- END IF;
--
-- --retrieve the rows from the buffer into PL/SQL variables
-- DBMS_SQL.COLUMN_VALUE(v_cursorID,1,l_item_id);
-- DBMS_SQL.COLUMN_VALUE(v_cursorID,2,l_uom_code);
-- DBMS_SQL.COLUMN_VALUE(v_cursorID,3,d_item_code);
-- DBMS_SQL.COLUMN_VALUE(v_cursorID,4,d_item_desc);
-- DBMS_SQL.COLUMN_VALUE(v_cursorID,5,d_org_name);
-- DBMS_SQL.COLUMN_VALUE(v_cursorID,6,d_currency_code);
/* Comment by ppandit End */

-- First re initialize local var
l_item_ohq      := 0;
l_item_trx_qty  := 0;
l_per_begin_qty := 0;

-- First get the Acutual On Hand Qty for the Ite, Org_id combination :
-- Bug#2576310 to add the sub inventory range the where condition
-- bug#3147073 : exclude non asset subinventories
SELECT NVL (SUM (transaction_quantity), 0)
  INTO l_item_ohq
  FROM mtl_onhand_quantities
 WHERE inventory_item_id = l_item_id
   AND organization_id = p_org_id
   AND subinventory_code BETWEEN NVL (p_subinv_from, subinventory_code)
                             AND NVL (p_subinv_to, subinventory_code)
   AND subinventory_code NOT IN (
                      SELECT secondary_inventory_name
                        FROM mtl_secondary_inventories
                       WHERE organization_id = p_org_id
                         AND asset_inventory = 2);

-- Get the qty between NOW and the P_FROM_DATE
-- Bug#2198569 to excluded wip transactions
--   transaction action id: 24 for wip cost update
--   transaction action id: 30 for wip scrap transaction
-- Bug#2576310 to add the sub inventory range the where condition
-- Bug#2865534 fix: get only regular stock and exclude consigned stock
-- for regular stock: organization_id is equal to owning_organization_id
-- for consigned stock: organization_id is the inventory organization
-- and owning_organization_id is the supplier organization.
-- owning_tp_type will be 1 for consigned transaction
-- bug#3118846 fix: exclude TRX from NON Qty tracked subinventories
SELECT NVL (SUM (mmt.primary_quantity), 0)
  INTO l_item_trx_qty
  FROM mtl_material_transactions mmt
 WHERE mmt.organization_id = p_org_id
   AND mmt.inventory_item_id = l_item_id
   AND mmt.subinventory_code BETWEEN NVL (p_subinv_from,
                                          mmt.subinventory_code)
                                 AND NVL (p_subinv_to, mmt.subinventory_code)
   AND (   mmt.subinventory_code IS NULL
        OR mmt.subinventory_code =
              (SELECT secondary_inventory_name
                 FROM mtl_secondary_inventories
                WHERE secondary_inventory_name = mmt.subinventory_code
                  AND organization_id = mmt.organization_id
                  AND quantity_tracked = 1
                  AND asset_inventory = 1)
       )
   AND mmt.transaction_id NOT IN (
          SELECT mmt1.transaction_id
            FROM mtl_material_transactions mmt1
           WHERE mmt1.organization_id = p_org_id
             AND mmt1.inventory_item_id = l_item_id
             AND mmt1.subinventory_code BETWEEN NVL (p_subinv_from,
                                                     mmt1.subinventory_code
                                                    )
                                            AND NVL (p_subinv_to,
                                                     mmt1.subinventory_code
                                                    )
             AND mmt1.transaction_source_type_id = 5
             AND mmt1.transaction_action_id = 24
             AND NVL (mmt1.owning_tp_type, 2) = 1)
   AND mmt.transaction_action_id <> 30
   AND NVL (mmt.owning_tp_type, 2) <> 1
   AND mmt.transaction_date BETWEEN TO_DATE(p_date_from, 'YYYY/MM/DD HH24:MI:SS') AND SYSDATE;

-- On Hand Qty to begin = Actual On Hand MINUS sum of Trx qty form Now to begin date
l_per_begin_qty := l_item_ohq - l_item_trx_qty ;

     l_begin_infl_adj := 0;
     l_final_infl_adj := 0;
     l_final_qty := 0;


    IF l_final_qty = 0
    THEN
      l_unit_infl_adj := 0;
    ELSE
      l_unit_infl_adj := l_final_infl_adj/l_final_qty;
    END IF;

  BEGIN
        -- Bug#2576310 fix subinventory code to add in the WHERE condition
SELECT NVL (mmt.prior_cost, mmt.actual_cost)
  INTO l_item_unit_cost
  FROM mtl_material_transactions mmt
 WHERE mmt.transaction_id =
          (SELECT MIN (transaction_id)
             FROM mtl_material_transactions
            WHERE organization_id = p_org_id
              AND inventory_item_id = l_item_id
              AND transaction_date =
                     (SELECT MIN (transaction_date)
                        FROM mtl_material_transactions
                       WHERE organization_id = p_org_id
                         AND transaction_action_id NOT IN (24, 30)
                         AND NVL (owning_tp_type, 2) <> 1
                         AND transaction_date BETWEEN TO_DATE(p_date_from, 'YYYY/MM/DD HH24:MI:SS')
                                                  AND TO_DATE(p_date_to, 'YYYY/MM/DD HH24:MI:SS') + (86399 / 86400) -- Changed by ppandit for using params directly, Italy China Enhancements
                         AND inventory_item_id = l_item_id
                         AND subinventory_code BETWEEN NVL (p_subinv_from,
                                                            subinventory_code
                                                           )
                                                   AND NVL (p_subinv_to,
                                                            subinventory_code
                                                           )))
   AND (   mmt.subinventory_code IS NULL
        OR mmt.subinventory_code =
              (SELECT secondary_inventory_name
                 FROM mtl_secondary_inventories
                WHERE secondary_inventory_name = mmt.subinventory_code
                  AND organization_id = mmt.organization_id
                  AND quantity_tracked = 1
                  AND asset_inventory = 1)
       )
   AND mmt.transaction_id NOT IN (
          SELECT mmt1.transaction_id
            FROM mtl_material_transactions mmt1
           WHERE mmt1.organization_id = p_org_id
             AND mmt1.inventory_item_id = l_item_id
             AND NVL (mmt1.owning_tp_type, 2) = 1
             AND mmt1.transaction_date BETWEEN TO_DATE(p_date_from, 'YYYY/MM/DD HH24:MI:SS') AND TO_DATE(p_date_to, 'YYYY/MM/DD HH24:MI:SS') + (86399 / 86400) -- Changed by ppandit for using params directly, Italy China Enhancements
             AND mmt1.subinventory_code BETWEEN NVL (p_subinv_from,
                                                     mmt1.subinventory_code
                                                    )
                                            AND NVL (p_subinv_to,
                                                     mmt1.subinventory_code
                                                    )
             AND mmt1.transaction_source_type_id = 5
             AND mmt1.transaction_action_id = 24)
   AND mmt.transaction_action_id <> 30
   AND NVL (mmt.owning_tp_type, 2) <> 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

IF l_item_unit_cost IS NULL THEN l_item_unit_cost := 0; END IF;

    get_item_txn_info
    ( p_org_id                => p_org_id
    , p_item_id               => l_item_id
    , p_uom_code              => l_uom_code
    , p_item_code             => d_item_code
    , p_item_desc             => d_item_desc
    , p_org_name              => d_org_name
    , p_currency_code         => d_currency_code
    , p_subinv_from           => p_subinv_from
    , p_subinv_to             => p_subinv_to
    , p_acct_period_id        => NULL
    , p_per_first_txn_date    => p_rpt_from_date
    , p_per_last_txn_date     => p_rpt_to_date
    , p_item_unit_cost        => l_item_unit_cost
    , p_primary_cost_method   => l_primary_cost_method
    , p_item_init_qty         => l_per_begin_qty
    , p_item_init_infl        => 0
    , p_item_unit_infl_adj    => 0
    , x_rpt_item_tbl_rec      => l_rpt_item_tbl_rec
    );

    l_index := NVL(l_rpt_item_tbl_rec.FIRST, 0);
    IF l_index > 0
    THEN
      LOOP

        Insert_Rpt_Data
	   ( p_rpt_item_rec    => l_rpt_item_tbl_rec(l_index)
	   );
        EXIT WHEN l_index = l_rpt_item_tbl_rec.LAST;
        l_index := l_rpt_item_tbl_rec.NEXT(l_index);
      END LOOP;
    END IF;

END LOOP;
CLOSE lr_ref_cursor;

END IF;

END LOOP;
/* Logic added for inclusion of Category Set Range and dynamic decision on mtl_system_items_b segments by ppandit end */

EXCEPTION
  WHEN cost_method_not_found_except THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Inv_Msbk_Rpt' || ' Cost Method Not Found'
                             );
    END IF;
    RAISE;

  WHEN OTHERS THEN
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Inv_Msbk_Rpt'
                             );
    END IF;
    RAISE;

END create_inv_msbk_rpt;

END CST_MGD_MSTR_BOOK_RPT;

/
