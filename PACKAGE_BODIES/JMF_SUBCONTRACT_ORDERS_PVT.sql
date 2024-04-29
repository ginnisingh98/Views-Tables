--------------------------------------------------------
--  DDL for Package Body JMF_SUBCONTRACT_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SUBCONTRACT_ORDERS_PVT" AS
-- $Header: JMFVSHKB.pls 120.39.12010000.2 2010/03/17 13:33:25 abhissri ship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFVSHKB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   Main Package body for SHIKYU Interlock processor                    |
--| FUNCTIONS/PROCEDURE                                                   |
--|    Get_OEM_Tp_Org                                                     |
--|    Validate_Lot_Serial_Control                                        |
--|    Is_Valid_Location                                                  |
--|    Validate_OSA_Item                                                  |
--|    Verify_Org_Attributes                                              |
--|    Verify_Shikyu_Attributes                                           |
--|    Load_Subcontract_Orders                                            |
--|    Load_Replenishments                                                |
--|    Load_Shikyu_Components                                             |
--|    Stamp_Null_Shikyu_Comp_Prices                                      |
--|    Generate_Batch_id                                                  |
--|    Process_Subcontract_Orders                                         |
--|    Allocate_Batch                                                     |
--|    Subcontract_Orders_Manager                                         |
--|    Subcontract_Orders_Worker                                          |
--|                                                                       |
--| HISTORY                                                               |
--|     04/26/2005 pseshadr       Created                                 |
--|     07/08/2005 vchu           Fixed GSCC error File.Pkg.21            |
--|     22/09/2005 pseshadr       Modified the name of the SHIKYU         |
--|                               profile option in the                   |
--|                               Subcontract_Orders_Manager procedure    |
--|     22/09/2005 vchu           Changed the name of the error message   |
--|                               for the case if the profile isn't on    |
--|     13/10/2005 vchu           Modified the c_alloc cursor in the      |
--|                               Load_Replenishments procedure for an    |
--|                               over allocation issue.                  |
--|     10/17/2005 vchu           Modified calls to JMF_SHIKYU_ONT_PVT.   |
--|                               Process_Replenishment_SO due to a       |
--|                               change of signature.  Also modified the |
--|                               c_rep cursor in Load_Replenishments     |
--|                               procedure for an issue where multiple   |
--|                               replenishment so lines were created for |
--|                               each replensihment po shipment.         |
--|     10/26/2005 vchu           Modified the value to populate into the |
--|                               TP_SUPPLIER_ID and TP_SUPPLIER_SITE_ID  |
--|                               columns of the JMF_SHIKYU_REPLENISHMENTS|
--|                               table for fixing the wrong value issue  |
--|                               of the Manufacturing Partner / MP site  |
--|                               as described in bug 4651480.            |
--|                               Also fixed the logic of the LOOP in the |
--|                               Load_Replenishments procedure to skip   |
--|                               the current iteration instead of exiting|
--|                               if encountered a replenishment PO for a |
--|                               non-shikyu component.                   |
--|     11/02/2005 vchu           Added the condition                     |
--|                               nvl(cancel_flag, 'N') = 'N' to the      |
--|                               where clause of c_rep cursor (for PO    |
--|                               Header, Line and Line Location levels)  |
--|                               in order to filter out the              |
--|                               cancelled Replenishment POs.            |
--|     11/15/2005 vchu           Modified the query of the c_alloc cursor|
--|                               to use required_quantity instead of     |
--|                               wro.required_quantity - quantity_issued |
--|                               when selecting subcontracting components|
--|                               still requiring more allocations.       |
--|     11/18/2005 vchu           Removed from Load_Shikyu_Components the |
--|                               validation that fails a Subcontracting  |
--|                               Order if the OSA item composes of a     |
--|                               regular item.                           |
--|     12/05/2005 vchu           Added a filtering condition to the      |
--|                               c_comp_cur cursor of the                |
--|                               Load_Shikyu_Components procedure to     |
--|                               make sure that the components have not  |
--|                               been loaded yet for the subcontract     |
--|                               order in consideration.                 |
--|     02/08/2006 vchu           Bug fix for 4912487: Fixed the FTS      |
--|                               issue in Is_Valid_Location by replacing |
--|                               the WHERE EXISTS logic by a join        |
--|                               between the hr_locations_all and        |
--|                               hr_all_organization_units tables.       |
--|     03/23/2006 vchu           Polished up the FND Log messages.       |
--|                               Fixed bug 5090721: set last_updated_by  |
--|                               and last_update_login in all update     |
--|                               statements.                             |
--|     03/31/2006 vchu           Bug fix for 5132505:                    |
--|                               Added the Stamp_Null_Shikyu_Comp_Prices |
--|                               procedure (and a call to it in          |
--|                               Subcontract_Orders_Manager) to pick up  |
--|                               the shikyu components loaded with a     |
--|                               null price, because of issues with the  |
--|                               price list setup.                       |
--|                               Also removed commented code.            |
--|     04/03/2006 vchu           Set batch_id of the Subcontrating PO    |
--|                               failing creation of the WIP job to -1,  |
--|                               so that it will be picked up again by   |
--|                               the next Interlock run, and thus the    |
--|                               processing can be completed if the WIP  |
--|                               issue is resolved.                      |
--|     04/17/2006 vchu           Modified the format of the FND Log      |
--|                               messages.                               |
--|     05/02/2006 vchu           Modified the c_alloc cursor to restrict |
--|                               by the Operating Unit specified in the  |
--|                               concurrent request parameters, and to   |
--|                               order the not yet fully allocated       |
--|                               Subcontract Orders by Need By Date,     |
--|                               Header Number, Line Number and Shipment |
--|                               Number of the PO.                       |
--|                               Fixed Bug 5197415: Added the            |
--|                               p_skip_po_replen_creation parameter to  |
--|                               the calls to Create_New_Allocations.    |
--|                               For the call to create new allocations  |
--|                               for the Subcontracting Orders not yet   |
--|                               fully allocated (those in c_alloc), the |
--|                               decision depends on the                 |
--|                               replen_so_creation_failed flag, which   |
--|                               would be set to 'Y' if the call to      |
--|                               Process_Replenishment_SO returned an    |
--|                               error status.  The other call in        |
--|                               Load_Subcontract_Orders passes 'N' for  |
--|                               p_skip_po_replen_creation, since only   |
--|                               the newly loaded Subcontracting Orders  |
--|                               are processed here.                     |
--|     05/08/2006 vchu           Bug fixes for 5198838 and 5212219:      |
--|                               Modified the c_project_csr cursor and   |
--|                               the logic to fetch the project and task |
--|                               info from the Subcontracting Order      |
--|                               Distributions.                          |
--|                               Also fixes a leftover issue from bug    |
--|                               5197415: Added a range logic to the     |
--|                               c_alloc cursor of Load_Replenishments,  |
--|                               so that the not yet fully allocated     |
--|                               Subcontracting Orders that do not       |
--|                               belong to that range would not be       |
--|                               picked up and redundant Replenishment   |
--|                               POs won't be created.                   |
--|     05/09/2006 vchu           Modified the INSERT INTO                |
--|                               JMF_SUBCONTRACT_ORDERS_TEMP statement   |
--|                               to populate the need_by_date as the     |
--|                               promised_date from po_line_locations_all|
--|                               table, if need_by_date was null.        |
--|     05/12/2006 vchu           Bug fix for 5212199: Added where clause |
--|                               condition to c_alloc to select only the |
--|                               not fully allocated Subcontracting      |
--|                               Orders that have not been cancelled.    |
--|     05/16/2006 vchu           Bug fix for 5222131: Modified           |
--|                               Load_Shikyu_Components to load          |
--|                               components for any subcontracting order |
--|                               with interlock_status = 'N' but without |
--|                               any existing shikyu components, instead |
--|                               of requiring batch_id = -1.  Also,      |
--|                               modified Process_Subcontract_Orders to  |
--|                               pick up any subcontracting orders with  |
--|                               interlock_status = 'N' or 'U', without  |
--|                               requiring batch_id = -1.  This would    |
--|                               allow subcontratcing orders loaded half |
--|                               way in case of a database crash to be   |
--|                               picked and recovered in a later         |
--|                               Interlock run.                          |
--|     06/13/2006 vchu           Fixed bug 5153959:                      |
--|                               Modified the join statement with        |
--|                               mtl_units_of_measure of the select      |
--|                               statement for inserting into the        |
--|                               JMF_SUBCONTRACT_ORDERS_TEMP temp table  |
--|                               (in Load_Subcontract_Orders) to take    |
--|                               the unit_meas_lookup_code from the PO   |
--|                               Line if that of the PO Line Location    |
--|                               was NULL.                               |
--|     06/14/2006 vchu           Added a join to po_releases_all table   |
--|                               in the select statement for inserting   |
--|                               into the JMF_SUBCONTRACT_ORDERS_TEMP    |
--|                               temp table, in order to make sure the   |
--|                               Blanket Releases are approved, if the   |
--|                               shipments are against Blanket Releases. |
--|     06/16/2006 rajkrish       Fixed the worker batch issue            |
--|     08/18/2006 vchu           Added Taiwan (TW) and Korea (KR) to the |
--|                               list of valid countries in              |
--|                               Is_Valid_Location.                      |
--|     08/22/2006 vchu           Bug fix for bug 5364037: Added the new  |
--|                               Validate_Lot_Serial_Control procedure,  |
--|                               and calls to this procedure in          |
--|                               Validate_OSA_Item and                   |
--|                               Verify_Shikyu_Attributes to make sure   |
--|                               that the OSA item and the components    |
--|                               are not Lot/Serial controlled in the TP |
--|                               Organization.                           |
--|     08/30/2006 vchu           Bug fix for 5500896: Interlock was not  |
--|                               picking up any Subcontract POs because  |
--|                               of PJM POs created with an invalid      |
--|                               OEM-TP Shipping Network, and PJM POs    |
--|                               with an OSA item that wasn't assigned   |
--|                               to the TP Org.  An IF statement was     |
--|                               added to the Load_Subcontract_Orders    |
--|                               procedure to avoid performing the       |
--|                               project reference validation and prevent|
--|                               the l_valid_flag from being overwritten |
--|                               if previous validations have already    |
--|                               failed the current Subcontract Order.   |
--|                               Also added filters to the cursors of    |
--|                               the Load_Shikyu_components and          |
--|                               Allocate_Batch procedures, in order to  |
--|                               avoid processing of Subcontract POs     |
--|                               outside of the current OU.              |
--|                               This was the issue why the invalid POs  |
--|                               in PJM OU was also affecting the DMF    |
--|                               POs.                                    |
--|                               Also added FND_LOG calls to print out   |
--|                               sqlerrm in cases where an unexpected    |
--|                               exception is caught, and polished up    |
--|                               some existing FND Log messages.         |
--|     10/31/2006 vchu           Bug fix for 5632012: Modified           |
--|                               Load_Shikyu_Components to call the WIP  |
--|                               explodeRequirements API in order to     |
--|                               explode any phantom BOMs defined in the |
--|                               BOM for the assembly item of the        |
--|                               Subcontracting Order.                   |
--|     11/08/2006 vchu           Bug fix for 5632012: Added a validation |
--|                               to set the interlock_status of the      |
--|                               Subcontracting PO Shipment to 'E', if   |
--|                               routings are defined for the            |
--|                               corresponding OSA Item in the TP Org.   |
--|                               Moreover, removed the logic to set      |
--|                               the interlock_status of Subcontract     |
--|                               Orders  to 'E' only because no price    |
--|                               was stamped after calling               |
--|                               Process_Replenishment_So to do a price  |
--|                               quote.  This would enable these POs to  |
--|                               have WIP Jobs created and to be seen    |
--|                               from the Workbench UI.                  |
--|                               Also moved the call to                  |
--|                               Stamp_Null_Shikyu_Comp_Prices before    |
--|                               Load_Shikyu_Components, in order to     |
--|                               avoid calling OM Process Order API      |
--|                               again to get prices for the components  |
--|                               that were newly loaded and that failed  |
--|                               price quoting the first time, which can |
--|                               seriously hurt the performance.         |
--|     11/23/2006 vchu           Bug fix for 5678387: Modified the       |
--|                               queries that select                     |
--|                               UNIT_MEAS_LOOKUP_CODE from              |
--|                               PO_LINE_LOCATIONS_ALL to select the     |
--|                               same column from PO_LINES_ALL, if the   |
--|                               UOM is not stamped on the line location,|
--|                               which seems to be the case for BPA      |
--|                               Release Shipments.                      |
--|                               Also removed unnecessary logic that     |
--|                               gets the next sequence ID for           |
--|                               bom_explosion_temp, since we do not     |
--|                               call bom explosion API directly anymore.|
--|   04-OCT-2007      kdevadas  12.1 Buy/Sell Subcontracting changes     |
--|                              Reference - GBL_BuySell_TDD.doc          |
--|                              Reference - GBL_BuySell_FDD.doc          |
--|   01-MAY-2008      kdevadas  Bug 7000413 -  In case of errors in  WIP |
--|                              job creation, the appropriate message is |
--|                              set and displayed in the request log     |
--+=======================================================================+

--=============================================
-- GLOBALS
--=============================================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'JMF_SUBCONTRACT_ORDERS_PVT';
g_log_enabled          BOOLEAN;

TYPE g_SubcontractTabTyp IS TABLE OF JMF_SUBCONTRACT_ORDERS_TEMP%ROWTYPE;
TYPE g_OsaTabTyp IS TABLE OF JMF_SUBCONTRACT_ORDERS%ROWTYPE;
TYPE g_Comp_TabTyp IS TABLE OF JMF_SHIKYU_COMPONENTS%ROWTYPE;
TYPE g_oem_tp_rec IS RECORD
( oem_organization_id NUMBER
, tp_organization_id  NUMBER
, vendor_id           NUMBER
, vendor_site_id      NUMBER
, status              VARCHAR2(1)
);
TYPE g_oemtp_TabTyp IS TABLE OF g_oem_tp_rec
     INDEX BY PLS_INTEGER;
TYPE g_org_rec IS RECORD
( organization_id NUMBER
, status          VARCHAR2(1)
);
TYPE g_org_TabTyp IS TABLE OF g_org_rec
     INDEX BY PLS_INTEGER;
g_oemtp_tbl g_oemtp_TabTyp;
g_org_tbl   g_org_TabTyp;

--=============================================
-- PROCEDURES AND FUNCTIONS
--=============================================

--========================================================================
-- FUNCTION : Get_OEM_Tp_Org    PRIVATE
-- PARAMETERS: p_organization_id   Organization
--             p_vendor_id         Vendor
--             p_vendor_site_id    Vendor Site
-- COMMENT   : This function validates the following:
--                The OEM and TP org have relationship defined
--                in the shipping networks.
--                For the OEM-TP relationship that is defined, the
--                Supplier/site should be associated with only one TP org
--========================================================================
FUNCTION Get_OEM_Tp_Org
( p_organization_id IN NUMBER
, p_vendor_id       IN NUMBER
, p_vendor_site_id  IN NUMBER
) RETURN NUMBER
IS
  l_org_tbl  g_oemtp_TabTyp;
  l_current_index PLS_INTEGER;
  l_org_index     PLS_INTEGER;
  l_tp_org        NUMBER;
  l_program CONSTANT VARCHAR2(30) := 'Get_OEM_Tp_Org';


 CURSOR c_oem_tp_cur IS
 SELECT  mip.from_organization_id oem_organization_id
       , hoi.organization_id  tp_organization_id
       , p_vendor_id vendor_id
       , p_vendor_site_id vendor_site_id
       , 'Y' status
  FROM   HR_ORGANIZATION_INFORMATION hoi
     ,   mtl_interorg_parameters mip
     ,   mtl_parameters mp
  WHERE  mip.to_organization_id = mp.organization_id
  AND    mp.organization_id     = hoi.organization_id
  AND    mp.trading_partner_org_flag = 'Y'
  AND    mip.from_organization_id    = p_organization_id
  AND    hoi.org_information_context = 'Customer/Supplier Association'
  AND    hoi.org_information3 = to_char(p_vendor_id)           --Bugfix 9315131
  AND    hoi.org_information4 = to_char(p_vendor_site_id);     --Bugfix 9315131

BEGIN

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  --Debug changes for bug 9315131
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program
		|| ': p_organization_id:' || p_organization_id
		|| ': p_vendor_id:' || p_vendor_id
		|| ': p_vendor_site_id:' || p_vendor_site_id
                );
  END IF;
  END IF;

  OPEN c_oem_tp_cur;
    --Bugfix 9315131
    --FETCH c_oem_tp_cur INTO l_org_tbl(l_org_tbl.COUNT);
    FETCH c_oem_tp_cur INTO l_org_tbl(nvl(l_org_tbl.last, 0) + 1);
  CLOSE c_oem_tp_cur;

  -- Cache the OEM/TP relationship status and OEM/TP organization associations
  -- if they are defined in the shipping network.

  l_current_index:= g_oemtp_tbl.COUNT;

  -- If there is more than one association defined for OEM/TP org combination,
  -- mark the status as 'N' and set the tp_org to null.

  IF l_org_tbl.COUNT <> 1
  THEN
    g_oemtp_tbl(l_current_index).status := 'N';
    g_oemtp_tbl(l_current_index).oem_organization_id := p_organization_id;
    g_oemtp_tbl(l_current_index).tp_organization_id := null;
    g_oemtp_tbl(l_current_index).vendor_id := p_vendor_id;
    g_oemtp_tbl(l_current_index).vendor_site_id := p_vendor_site_id;
    l_tp_org := null;

    FND_MESSAGE.set_name('JMF', 'JMF_SHK_OEM_TP_ASSN_ERROR');
    FND_MSG_PUB.add;
  ELSE
    l_org_index    := l_org_tbl.FIRST;
    g_oemtp_tbl(l_org_index).status := 'Y';
    g_oemtp_tbl(l_org_index).oem_organization_id := p_organization_id;
    g_oemtp_tbl(l_org_index).tp_organization_id  :=
        l_org_tbl(l_org_index).tp_organization_id;
    g_oemtp_tbl(l_org_index).vendor_id := p_vendor_id;
    g_oemtp_tbl(l_org_index).vendor_site_id := p_vendor_site_id;
    l_tp_org := l_org_tbl(l_org_index).tp_organization_id;

  END IF;

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  --Debugging changes for bug 9315131
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program
		|| 'TP Org:' || l_tp_org
                );
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

  RETURN l_tp_org;

END Get_OEM_Tp_Org;

--========================================================================
-- PROCEDURE : Validate_Lot_Serial_Control    PRIVATE
-- PARAMETERS: p_item_id          IN NUMBER  Item Identifier
--             p_organization_id  IN NUMBER  Inventory Item Identifier
--             x_valid_flag       OUT NUMBER Return value
-- COMMENT   : Returns 'Y' if the item represented by the IN parameters is
--             not Lot and/or Serial controlled; returns 'N' otherwise.
--
--             Bug fix for 5364037: Added for Lot/Serial validation.
--========================================================================
PROCEDURE Validate_Lot_Serial_Control
( p_item_id          IN  NUMBER
, p_organization_id  IN  NUMBER
, x_valid_flag       OUT NOCOPY VARCHAR2
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================
  l_lot_control_code     NUMBER := -1;
  l_serial_control_code  NUMBER := -1;

  l_program CONSTANT VARCHAR2(30) := 'Validate_Lot_Serial_Control';

BEGIN

  x_valid_flag := 'Y';

  SELECT lot_control_code,
         serial_number_control_code
  INTO   l_lot_control_code,
         l_serial_control_code
  FROM   mtl_system_items_b
  WHERE  inventory_item_id = p_item_id
  AND    organization_id = p_organization_id;

  IF l_lot_control_code <> 1 OR l_serial_control_code <> 1
  THEN
    x_valid_flag := 'N';
  END IF;

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || G_PKG_NAME || '.' || l_program
                  || ': l_lot_control_code = ' || l_lot_control_code
                  || ', l_serial_control_code = ' || l_serial_control_code
                  || ', x_valid_flag = ' || x_valid_flag
                  );
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_valid_flag := 'N';

    IF g_log_enabled AND
       FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_EXCEPTION
                    , G_PKG_NAME || 'Get_Lot_Serial_Control_Code.no_data_found'
                    , G_PKG_NAME || '.' || l_program || ': No Data Found'
                    );
    END IF;

  WHEN OTHERS THEN
    x_valid_flag := 'N';

    IF g_log_enabled AND
       FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME || 'Get_Lot_Serial_Control_Code.others_exception'
                    , G_PKG_NAME || '.' || l_program || sqlerrm
                    );
    END IF;

END Validate_Lot_Serial_Control;

--========================================================================
-- FUNCTION : Is_Valid_Location    PRIVATE
-- PARAMETERS: p_organization_id   Organization
-- COMMENT   : This function validates if the country associated with
--             the OEM organization is Japan.
--========================================================================
FUNCTION Is_Valid_Location
( p_organization_id            IN   NUMBER
, p_subcontracting_type        IN   VARCHAR2   -- 12.1 Buy/Sell Subcontracting changes
) RETURN BOOLEAN
IS
 l_count   NUMBER;
 l_program CONSTANT VARCHAR2(30) := 'Is_Valid_Location';
BEGIN

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;

  -- Check to see if the country code of the OEM org is Japan.
  -- Added Taiwan (TW) and Korea (KR) to the list of countries

  -- Bug 4912487: Fixed the FTS issue by replacing the WHERE EXISTS logic
  -- by a join between the hr_all_organization_units and hr_locations_all
  -- tables.
     /* 12.1 Buy/Sell Subcontracting changes */
  	/* No country code validation required for Buy/Sell subcontracting */
	  IF (p_subcontracting_type = 'B') THEN
	     return TRUE;
	  END IF;


  SELECT count(*)
  INTO   l_count
  FROM   hr_all_organization_units hou,
         hr_locations_all hrl
  WHERE  hou.location_id = hrl.location_id
  AND    hou.organization_id = p_organization_id
  AND    hrl.country in ('JP', 'KR', 'TW');

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Country Code count is for JP = ' || l_count
                );
  END IF;
  END IF;

  IF l_count = 0
  THEN
    FND_MESSAGE.set_name('JMF','JMF_SHK_INVALID_LOCATION');
    FND_MSG_PUB.add;
    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': OEM Country is not Japan:'
                  );
    END IF;
    END IF;
    RETURN FALSE;
  ELSE
    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Is_Valid_Location will return TRUE'
                  );
    END IF;
    END IF;

    RETURN TRUE;
  END IF;


END Is_Valid_Location;


--========================================================================
-- PROCEDURE : Validate_OSA_Item    PRIVATE
-- PARAMETERS:
--             p_item_id           Item
--             p_organization_id   Organization
--             p_vendor_id         Vendor Id
--             p_vendor_site_id    Vendor Site
--             x_tp_organization_id Tp Orgn
--             x_valid_flag        Flag to indicate if the item is valid to follow
--                                 the SHIKYU business flow.
-- COMMENT   : This procedure validates if the OSA item that is being passed
--             in is eligible to be processed through the SHIKYU flow.
--             The following validations are performed:
--             1. Check if outsourced_assembly attribute for the item is set at OEM org
--             2. Check if the location of the OEM org is valid
--             3. Check if OEM/TP relationship exists and valid
--             4. Check if outsourced_assembly attribute for the item is set at TP org
--             5. Check if consigned flow is enabled at the for the item/supplier/site
--========================================================================
PROCEDURE Validate_OSA_Item
( p_item_id                    IN   NUMBER
, p_organization_id            IN   NUMBER
, p_vendor_id                  IN   NUMBER
, p_vendor_site_id             IN   NUMBER
, x_tp_organization_id         OUT NOCOPY  NUMBER
, x_valid_flag                 OUT NOCOPY VARCHAR2
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================
  l_msg_list   VARCHAR2(2000);
  l_msg_data   VARCHAR2(2000);
  l_msg_count  NUMBER;
  l_return_status VARCHAR2(1);
  l_osa_flag   NUMBER;
  l_comp_flag  NUMBER;
  l_item_id    NUMBER;
  l_organization_id NUMBER;
  i         INTEGER;
  l_exists  BOOLEAN := FALSE;
  l_consigned_from_supplier_flag
  PO.PO_ASL_ATTRIBUTES.CONSIGNED_FROM_SUPPLIER_FLAG%TYPE := NULL;
  l_enable_vmi_flag
  PO.PO_ASL_ATTRIBUTES.ENABLE_VMI_FLAG%TYPE             := NULL;
  l_last_billing_date                         DATE      := NULL;
  l_consigned_billing_cycle                   NUMBER    := NULL;
  l_program CONSTANT VARCHAR2(30) := 'Validate_OSA_Item';

  -- Bug 5364037: Added for Lot/Serial validation
  l_lot_serial_valid_flag  VARCHAR2(1);

   /* 12.1 Buy/Sell subcontracting changes */
   l_mp_organization_id   NUMBER;
   l_subcontracting_type VARCHAR2(1);


BEGIN

  IF g_log_enabled THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  --Debugging changes for bug 9315131
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program
		||': l_organization_id:' || l_organization_id
		||': l_item_id:' || l_item_id
                );

  END IF;
  END IF;

  l_organization_id := p_organization_id;
  l_item_id         := p_item_id;


  -- Check to see if the item has the outsourced_assembly flag turned on
  -- at the OEM organization.

  JMF_SHIKYU_GRP.Get_Shikyu_Attributes
    ( p_api_version             => 1.0
    , p_init_msg_list           => l_msg_list
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_organization_id         => l_organization_id
    , p_item_id                 => l_item_id
    , x_outsourced_assembly     => l_osa_flag
    , x_subcontracting_component => l_comp_flag
    );

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': OSA flag is ' || l_osa_flag
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Component flag is ' || l_comp_flag
                  );
    END IF;
    END IF;

    /* 12.1 Buy/Sell subcontracting changes */
	  /* Check to see if the location country code is Japan, Korea or Taiwan
       only for Chargeable Subcontracting */

	  l_mp_organization_id := Get_OEM_Tp_Org
	                        ( p_organization_id  => p_organization_id
	                        , p_vendor_id        => p_vendor_id
	                        , p_vendor_site_id   => p_vendor_site_id
	                        );
    IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ' mp org id -  ' ||
                  l_mp_organization_id
                  );
      END IF ;
    END IF ;

	  l_subcontracting_type := JMF_SHIKYU_GRP.get_subcontracting_type
				    (p_oem_org_id => p_organization_id,
				    p_mp_org_id => l_mp_organization_id);

    IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ' subcontracting_type is  ' ||
                  l_subcontracting_type
                  );
      END IF ;
    END IF ;

	IF Is_Valid_Location(p_organization_id, l_subcontracting_type)
  AND ((l_osa_flag =1) AND (l_return_status = FND_API.G_RET_STS_SUCCESS))
  THEN

    -- To check if the OEM/TP relationship exists, check the cache to see
    -- if the OEM/TP combn exists. If it does, get the status from the
    -- cache. IF the combination does not exist, invoke the function to
    -- validate the OEM/TP relationship.

    i:= g_oemtp_tbl.FIRST;

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ' Index of g_oemtp_tbl is ' || i
                  );
    END IF;
    END IF;

    WHILE i <= g_oemtp_tbl.LAST
    LOOP
      IF((g_oemtp_tbl(i).oem_organization_id = p_organization_id)
        AND (g_oemtp_tbl(i).vendor_id = p_vendor_id)
        AND (g_oemtp_tbl(i).vendor_site_id = p_vendor_site_id))
      THEN
        l_exists := TRUE;
        x_valid_flag := g_oemtp_tbl(i).status;
        x_tp_organization_id := g_oemtp_tbl(i).tp_organization_id;

        IF g_log_enabled THEN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program || ': x_valid_flag = '
                        || x_valid_flag
                      );
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program || ': x_tp_organization_id = '
                        || x_tp_organization_id
                      );
        END IF;
        END IF;

        EXIT;
      END IF;

      i := i + 1;

      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': index of g_oemtp_tbl is now ' || i
                    );
      END IF;
      END IF;

    END LOOP;

    IF NOT(l_exists)
    THEN

       IF g_log_enabled THEN
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_PKG_NAME
                     , '>> ' || l_program || ': Calling Get_OEM-TP_Org with '
                       || 'p_organization_id = ' || p_organization_id
                       || ', p_vendor_id = ' || p_vendor_id
                       || ', p_vendor_site_id = ' || p_vendor_site_id
                     );
       END IF;
       END IF;

       x_tp_organization_id := Get_OEM_Tp_Org
                              ( p_organization_id  => p_organization_id
                              , p_vendor_id        => p_vendor_id
                              , p_vendor_site_id   => p_vendor_site_id
                              );
    END IF;
  END IF;

  -- If a valid relationship exists between OEM and TP , then check the
  -- outsourced_assembly attribute of the item at the TP org to ensure
  -- it is set so that it can follow the SHIKYU flow.

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': x_tp_organization_id = '
                    || x_tp_organization_id
                  );
  END IF;
  END IF;

  IF x_tp_organization_id IS NULL
  THEN
    x_valid_flag := 'N';
  ELSE
    JMF_SHIKYU_GRP.Get_Shikyu_Attributes
    ( p_api_version             => 1.0
    , p_init_msg_list           => l_msg_list
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_organization_id         => x_tp_organization_id
    , p_item_id                 => l_item_id
    , x_outsourced_assembly     => l_osa_flag
    , x_subcontracting_component => l_comp_flag
    );

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': OSA flag = ' || l_osa_flag
                  );
    END IF;
    END IF;

    IF ((l_osa_flag <>1) OR (l_return_status <> FND_API.G_RET_STS_SUCCESS))
    THEN
      x_valid_flag := 'N';
    ELSE

      -- Check if the Supplier/Supplier Site/Ship to Organization/Item
      -- combination corresponds to a consigned enabled ASL, if yes, set
      -- the valid flag to be 'N'

      PO_THIRD_PARTY_STOCK_GRP.Get_Asl_Attributes
      ( p_api_version                  => 1.0
      , p_init_msg_list                => NULL
      , x_return_status                => l_return_status
      , x_msg_count                    => l_msg_count
      , x_msg_data                     => l_msg_data
      , p_inventory_item_id            => p_item_id
      , p_vendor_id                    => p_vendor_id
      , p_vendor_site_id               => p_vendor_site_id
      , p_using_organization_id        => p_organization_id
      , x_consigned_from_supplier_flag => l_consigned_from_supplier_flag
      , x_enable_vmi_flag              => l_enable_vmi_flag
      , x_last_billing_date            => l_last_billing_date
      , x_consigned_billing_cycle      => l_consigned_billing_cycle
      );

      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Consigned flag = '
                      || l_consigned_from_supplier_flag
                    );
      END IF;
      END IF;

      IF l_consigned_from_supplier_flag = 'Y'
      THEN
        x_valid_flag := 'N';
      ELSE
        x_valid_flag := 'Y';
      END IF;

    END IF;

    -- Bug 5364037: To validate that the OSA item is not Lot and/or
    -- Serial controlled in the TP Organization

    IF x_valid_flag = 'Y'
    THEN

      Validate_Lot_Serial_Control
      ( p_item_id         => p_item_id
      , p_organization_id => x_tp_organization_id
      , x_valid_flag      => l_lot_serial_valid_flag
      );

      IF l_lot_serial_valid_flag = 'N'
      THEN
        x_valid_flag := 'N';
      END IF;

      IF g_log_enabled AND
         (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || G_PKG_NAME || '.' || l_program
                      || ': x_valid_flag after Lot/Serial validation = ' || x_valid_flag
                      );
      END IF;
    END IF;

  END IF;

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': x_valid_flag after Consigned validation = ' || x_valid_flag
                  );
  END IF;
  END IF;

  IF x_valid_flag = 'N'
  THEN
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_OSA_ATTR_ERR');
    FND_MSG_PUB.add;
  END IF;

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

END Validate_OSA_Item;

--========================================================================
-- PROCEDURE : Verify_Org_Attributes    PRIVATE
-- PARAMETERS:
--             p_organization_id   Organization
--             x_eam_enabled       EAM enabled flag
--             x_wms_enabled       WMS enabled flag
--             x_process_enabled   Process enabled flag
-- COMMENT   : This procedure returns the process enabled,WMS,EAM attributes
--             for the organization passed in
--========================================================================
PROCEDURE Verify_Org_Attributes
( p_organization_id     IN NUMBER
, x_eam_enabled         OUT NOCOPY VARCHAR2
, x_wms_enabled         OUT NOCOPY VARCHAR2
, x_process_enabled     OUT NOCOPY VARCHAR2
)
IS
  l_program CONSTANT VARCHAR2(30) := 'Verify_Org_Attributes';
BEGIN

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;

  SELECT NVL(eam_enabled_flag,'N')
       , wms_enabled_Flag
       , process_enabled_flag
  INTO  x_eam_enabled
     ,  x_wms_enabled
     ,  x_process_enabled
  FROM   mtl_parameters
  WHERE  organization_id = p_organization_id;

  -- Cache the attributes and the status for the organization.

  IF x_eam_enabled = 'Y' OR x_wms_enabled ='Y' OR x_process_enabled='Y'
  THEN

    g_org_tbl(g_org_tbl.COUNT).organization_id := p_organization_id;
    g_org_tbl(g_org_tbl.COUNT).status          := 'N';
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_ORG_ATTR_ERR');
    FND_MSG_PUB.add;

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': Validation failed for Organization with ID = '
                    || p_organization_id
                    || ': x_eam_enabled = '
                    || x_eam_enabled
                    || ', x_wms_enabled = '
                    || x_wms_enabled
                    || ', x_process_enabled = '
                    || x_process_enabled
                    );
    END IF;

  ELSE

    g_org_tbl(g_org_tbl.COUNT).organization_id := p_organization_id;
    g_org_tbl(g_org_tbl.COUNT).status          := 'Y';

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': Validation passed for Organization with ID = '
                    || p_organization_id
                    );
    END IF;

  END IF;

  /*Commenting these debug stmnts as they are not needed
  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': Validation failed for Organization with ID = '
                  || p_organization_id
                  || ': x_eam_enabled = '
                  || x_eam_enabled
                  || ', x_wms_enabled = '
                  || x_wms_enabled
                  || ', x_process_enabled = '
                  || x_process_enabled
                  );
  END IF;
  */

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_ERROR
                    , G_PKG_NAME || l_program || '.no_data_found'
                    , 'Org does not exist');
    END IF;
    END IF;

  WHEN OTHERS THEN
    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

END Verify_Org_Attributes;

--========================================================================
-- PROCEDURE : Verify_Shikyu_Attributes    PRIVATE
-- PARAMETERS:
--             p_osa_item_id           Item
--             p_component_item_id     Shikyu Component
--             p_oem_organization_id   Organization
--             p_tp_organization_id    Tp Organization
--             x_return_status         Return STatus
-- COMMENT   : This procedure validates if the Shikyu component
--             has the attribute enabled in system items for both OEM and TP Org
--========================================================================
PROCEDURE Verify_Shikyu_Attributes
( p_osa_item_id         IN NUMBER
, p_component_item_id   IN NUMBER
, p_oem_organization_id IN NUMBER
, p_tp_organization_id  IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================
  l_msg_list   VARCHAR2(2000);
  l_msg_data   VARCHAR2(2000);
  l_msg_count  NUMBER;
  l_return_status VARCHAR2(1);
  l_osa_flag   NUMBER;
  l_comp_flag  NUMBER;
  l_program CONSTANT VARCHAR2(30) := 'Verify_Shikyu_Attributes';
BEGIN

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;

  -- Check if the Shikyu component flag is enabled at the OEM orgn

  JMF_SHIKYU_GRP.Get_Shikyu_Attributes
  ( p_api_version             => 1.0
  , p_init_msg_list           => l_msg_list
  , x_return_status           => l_return_status
  , x_msg_count               => l_msg_count
  , x_msg_data                => l_msg_data
  , p_organization_id         => p_oem_organization_id
  , p_item_id                 => p_component_item_id
  , x_outsourced_assembly     => l_osa_flag
  , x_subcontracting_component => l_comp_flag
  );

  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
     (l_comp_flag IN (1,2))
  THEN
  -- Check if the Shikyu component flag is enabled at the TP orgn

    JMF_SHIKYU_GRP.Get_Shikyu_Attributes
    ( p_api_version             => 1.0
    , p_init_msg_list           => l_msg_list
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_organization_id         => p_tp_organization_id
    , p_item_id                 => p_component_item_id
    , x_outsourced_assembly     => l_osa_flag
    , x_subcontracting_component => l_comp_flag
    );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
       (l_comp_flag IN (1,2))
    THEN
      x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('JMF', 'JMF_SHK_COMP_ATTR_ERR');
      FND_MSG_PUB.add;

      IF g_log_enabled AND
         (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program
                      || ': Subcontracting Component flag not equals to 1 or 2 '
                      || 'for component_id = '
                      || p_component_item_id
                      || ', tp_organization_id = '
                      || p_tp_organization_id
                      );
      END IF;

    END IF;
  ELSE
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_COMP_ATTR_ERR');
    FND_MSG_PUB.add;

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': Subcontracting Component flag not equals to 1 or 2 '
                    || 'for component_id = '
                    || p_component_item_id
                    || ', oem_organization_id = '
                    || p_oem_organization_id
                    );
    END IF;

  END IF;


  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

END Verify_Shikyu_Attributes;


--========================================================================
-- PROCEDURE : Load_Subcontract_Orders    PRIVATE
-- PARAMETERS:
--             p_operating_unit      Operating Unit
--             p_from_organization   From Organization
--             p_to_organization     To Organization
-- COMMENT   : This procedure loads all the PO Shipment lines
--             that are eligible for processing the SHIKYU business flow.
--             It populates the JMF_SUBCONTRACT_
--             ORDERS table with the Shipment lines of the OSA item .
--             The column interlock_status in JMF_SUBCONTRACT_ORDERS will
--             be updated as follows:
--             'N' - New , components are not yet loaded
--             'E' - Error when loading components, hence components are not loaded
--             'U' - Unprocessed (WIP job failure)
--             'P' - Processed (flow is complete)
--             'C' - Closed (after receiving is complete)
--========================================================================
PROCEDURE Load_Subcontract_Orders
( p_operating_unit             IN   NUMBER
, p_from_organization          IN   NUMBER
, p_to_organization            IN   NUMBER
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================

  TYPE l_project_rec IS RECORD
  ( project_id       NUMBER
  , task_id          NUMBER
  , line_location_id NUMBER
  );

  TYPE l_project_Tabtyp IS TABLE of l_project_rec
   INDEX BY PLS_INTEGER;


  l_subcontract_rec   g_SubcontractTabTyp;
  l_count             NUMBER;
  l_valid_flag        VARCHAR2(1);
  l_program           CONSTANT VARCHAR2(30) := 'Load_Subcontract_Orders';
  l_exists            BOOLEAN := FALSE;
  l_eam_enabled       VARCHAR2(1);
  l_wms_enabled       VARCHAR2(1);
  l_process_enabled   VARCHAR2(1);
  l_shipment_id       NUMBER;
  l_curr_index        NUMBER;
  l_project_tbl       l_project_Tabtyp;

  --=================
  -- CURSORS
  --=================

  CURSOR c_load_cur IS
  SELECT
    subcontract_po_shipment_id
  , subcontract_po_header_id
  , subcontract_po_line_id
  , oem_organization_id
  , tp_organization_id
  , need_by_date
  , vendor_id
  , vendor_site_id
  , uom
  , currency
  , quantity
  , osa_item_id
  , osa_item_price
  , project_id
  , task_id
  FROM JMF_SUBCONTRACT_ORDERS_TEMP;

  -- Bugs 5198838 and 5212219: Should get the project id for the distributions
  -- of the Subcontracting Order Shipment as long as it is NOT NULL.
  -- Should not restrict the task id to be NOT NULL as well.
  CURSOR c_project_csr IS
  SELECT distinct project_id
       , task_id
       , line_location_id
  FROM   po_distributions_all
  WHERE  line_location_id = l_shipment_id
  AND    project_id IS NOT NULL;
  --AND    task_id IS NOT NULL;

BEGIN

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;

  --Get all the Subcontract orders that were not processed by the
  --Interlock processor.

  INSERT INTO JMF_SUBCONTRACT_ORDERS_TEMP
  ( subcontract_po_shipment_id
  , subcontract_po_header_id
  , subcontract_po_line_id
  , oem_organization_id
  , tp_organization_id
  , need_by_date
  , vendor_id
  , vendor_site_id
  , uom
  , currency
  , quantity
  , osa_item_id
  , osa_item_price
  , project_id
  , task_id
  )
  SELECT /*+ PARALLEL(poll) */
    poll.line_location_id
  , poll.po_header_id
  , poll.po_line_id
  , poll.ship_to_organization_id
  , null
  , nvl(poll.need_by_date, poll.promised_date)
  , poh.vendor_id
  , poh.vendor_site_id
  , muom.uom_code
  , poh.currency_code
  , poll.quantity
  , pol.item_id
  , poll.price_override
  , pol.project_id
  , pol.task_id
  FROM
    po_line_locations_all poll
  , po_headers_all poh
  , po_lines_all pol
  , mtl_units_of_measure muom
  , po_releases_all por
  WHERE poll.po_header_id = poh.po_header_id
  AND   poll.po_line_id   = pol.po_line_id
  AND   poh.po_header_id  = pol.po_header_id
  AND   poll.po_release_id = por.po_release_id (+)
  AND   NVL(poll.unit_meas_lookup_code, pol.unit_meas_lookup_code) = muom.unit_of_measure
  AND   ((pol.closed_code   = 'OPEN') OR (pol.closed_code IS NULL))
  AND   poh.approved_flag = 'Y'
  AND   nvl(poh.cancel_flag, 'N') = 'N'
  AND   nvl(pol.cancel_flag, 'N') = 'N'
  AND   nvl(poll.cancel_flag, 'N') = 'N'
  AND   poll.outsourced_assembly = 1
  AND   poll.org_id        = p_operating_unit
  AND   DECODE(poll.po_release_id,
               NULL, 'Y',
               por.approved_flag) = 'Y'
  AND   poll.ship_to_organization_id
  BETWEEN
    (NVL(p_from_organization,poll.ship_to_organization_id))
    AND
     (NVL(p_to_organization,poll.ship_to_organization_id)
    )
  AND  NOT EXISTS
  ( SELECT subcontract_po_shipment_id
    FROM   JMF_SUBCONTRACT_ORDERS jso
    WHERE  poll.line_location_id = jso.subcontract_po_shipment_id
  );

  OPEN c_load_cur;
  FETCH c_load_cur
  BULK COLLECT INTO l_subcontract_rec;
  CLOSE c_load_cur;

  l_count := l_subcontract_rec.COUNT;

  --Debug changes for bug 9315131
  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||'Count of records to process:' || l_count
                  );
    END IF;
  END IF;

  IF l_subcontract_rec.COUNT > 0 THEN
  FOR i IN l_subcontract_rec.FIRST..l_subcontract_rec.LAST
  LOOP

    -- For the shipment lines fetched, check the cache to see if the
    -- OEM org(ship_to_organization) is valid. If the orgn does not
    -- exists in the cache, invoke Verify_Org_attributes procedure
    -- to validate.

    --Debug changes for bug 9315131
    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||'----------------------Index i:' || i || '---------------------------------'
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: subcontract_po_shipment_id:' || l_subcontract_rec(i).subcontract_po_shipment_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: subcontract_po_header_id:' || l_subcontract_rec(i).subcontract_po_header_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: subcontract_po_line_id:' || l_subcontract_rec(i).subcontract_po_line_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: oem_organization_id:' || l_subcontract_rec(i).oem_organization_id
		  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: tp_organization_id:' || l_subcontract_rec(i).tp_organization_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: vendor_id:' || l_subcontract_rec(i).vendor_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: vendor_site_id:' || l_subcontract_rec(i).vendor_site_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Processing: osa_item_id:' || l_subcontract_rec(i).osa_item_id
                  );
    END IF;
    END IF;

    IF g_org_tbl.COUNT > 0
    THEN
      FOR k in g_org_tbl.FIRST .. g_org_tbl.LAST
      LOOP
        IF(g_org_tbl(k).organization_id = l_subcontract_rec(i).oem_organization_id)
        THEN
          l_valid_flag := g_org_tbl(k).status;
          l_exists     := TRUE;
          EXIT;
        ELSE
          l_exists     := FALSE;
        END IF;

      END LOOP;
    END IF;

  IF NOT(l_exists)
  THEN
    Verify_Org_Attributes
   ( p_organization_id  => l_subcontract_rec(i).oem_organization_id
   , x_eam_enabled      => l_eam_enabled
   , x_wms_enabled      => l_wms_enabled
   , x_process_enabled  => l_process_enabled
   );
  END IF;

   IF ((l_eam_enabled = 'N') AND (l_wms_enabled='N') AND (l_process_enabled = 'N'))
        OR (l_valid_flag ='Y')
   THEN
     Validate_OSA_Item
     ( p_item_id           => l_subcontract_rec(i).osa_item_id
     , p_organization_id   => l_subcontract_rec(i).oem_organization_id
     , p_vendor_id         => l_subcontract_rec(i).vendor_id
     , p_vendor_site_id    => l_subcontract_rec(i).vendor_site_id
     , x_tp_organization_id => l_subcontract_rec(i).tp_organization_id
     , x_valid_flag        => l_valid_flag
     );
   ELSE
     l_valid_flag := 'N';
   END IF;

   --Debug changes for 9315131
   IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
		  || 'After Validate_OSA_Item: l_valid_flag:' || l_valid_flag
                  );
    END IF;
   END IF;

   -- Bug 5500896: Validate Project reference only if all the previous validations
   -- have passed to avoid resetting of the l_valid_flag from 'N' back to 'Y'

   IF l_valid_flag = 'Y'
   THEN

     -- Check if the shipment line has distributions allocated to different projects
     -- and tasks.
     -- Since the project and task attributes are stored at distribution level
     -- we need to ensure that the shipment line which can have multiple distributions
     -- should be allocated to only one project/task. IF the shipment line is allocated
     -- to multiple project/task then mark the status as not valid. We will not
     -- process these records.

     l_shipment_id := l_subcontract_rec(i).subcontract_po_shipment_id;

     --Debug changes for 9315131
     IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> ' || l_program
		       || 'l_shipment_id:' || l_shipment_id
                      );
      END IF;
     END IF;

     /*
     OPEN c_project_csr;
     LOOP
       l_curr_index := l_project_tbl.COUNT;
       FETCH c_project_csr INTO  l_project_tbl(l_curr_index) ;
       IF c_project_csr%NOTFOUND
       THEN
         EXIT;
       END IF;
     END LOOP;
     CLOSE c_project_csr;
     */

     -- Bugs 5198838 and 5212219: Open the c_project_csr to get the
     -- appropriate project and task reference

     OPEN c_project_csr;
     FETCH c_project_csr
     BULK COLLECT INTO l_project_tbl;

     IF l_project_tbl.COUNT > 1
     THEN
       l_valid_flag := 'N';
     ELSIF l_project_tbl.COUNT = 1
     THEN
       l_valid_flag := 'Y';
       l_curr_index := l_project_tbl.FIRST;

       UPDATE jmf_subcontract_orders_temp
       SET project_id = l_project_tbl(l_curr_index).project_id
         , task_id    = l_project_tbl(l_curr_index).task_id
       WHERE subcontract_po_shipment_id = l_shipment_id;
     ELSE
       -- l_valid_flag := 'Y';
       NULL;
     END IF;

     CLOSE c_project_csr;

   END IF; /* IF l_valid_flag = 'Y' */

   -- If the shipment line is marked as not valid to be processed, delete
   -- from the temp table so that we do not need to load it in JMF_SUBCONTRACT_
   -- ORDERS table for processing.

   IF l_valid_flag = 'N'
   THEN
     DELETE FROM JMF_SUBCONTRACT_ORDERS_TEMP
     WHERE  subcontract_po_shipment_id = l_subcontract_rec(i).subcontract_po_shipment_id;

     IF g_log_enabled THEN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': l_valid_flag is ''N'': Deleting record with subcontract_po_shipment_id = '
                  || l_subcontract_rec(i).subcontract_po_shipment_id
                  || ' from JMF_SUBCONTRACT_ORDERS_TEMP'
                  );
     END IF;
     END IF;
   ELSE
     UPDATE JMF_SUBCONTRACT_ORDERS_TEMP
     SET tp_organization_id = l_subcontract_rec(i).tp_organization_id
     WHERE subcontract_po_shipment_id = l_subcontract_rec(i).subcontract_po_shipment_id;

     --Debug changes for bug 9315131
     IF g_log_enabled THEN
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ':After updating jsot with tp org:'
		  || l_subcontract_rec(i).tp_organization_id
		  || ': for shipment_id:'
                  || l_subcontract_rec(i).subcontract_po_shipment_id
                  );
     END IF;
     END IF;

   END IF;
  END LOOP;

  -- This will ensure if multiple process of Interlock is run, and these processes
  -- happen to pick up the same shipment line, then the load will only
  -- pick up the shipment line that is not processed by the other process.
  -- The new shipment lines are marked as 'N' which indicates they need to be
  -- processed. 'N' is the first step in processing of the shipment lines.

  --Debug changes for bug 9315131
  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  ||':End of Loop. Merge stmnt about to be executed.'
                  );
  END IF;
  END IF;

  MERGE INTO JMF_SUBCONTRACT_ORDERS jso
  USING (SELECT subcontract_po_shipment_id
           , subcontract_po_header_id
           , subcontract_po_line_id
           , oem_organization_id
           , tp_organization_id
           , osa_item_id
           , osa_item_price
           , need_by_date
           , uom
           , currency
           , quantity
           , project_id
           , task_id
           FROM JMF_SUBCONTRACT_ORDERS_TEMP ) jsot
  ON ( jso.subcontract_po_shipment_id = jsot.subcontract_po_shipment_id)
  WHEN NOT MATCHED THEN
  INSERT
  ( jso.subcontract_po_shipment_id
  , jso.subcontract_po_header_id
  , jso.subcontract_po_line_id
  , jso.oem_organization_id
  , jso.tp_organization_id
  , jso.osa_item_id
  , jso.osa_item_price
  , jso.need_by_date
  , jso.uom
  , jso.currency
  , jso.quantity
  , jso.batch_id
  , jso.project_id
  , jso.task_id
  , jso.last_update_date
  , jso.last_updated_by
  , jso.creation_date
  , jso.created_by
  , jso.last_update_login
  , jso.interlock_status
  )
  VALUES
  ( jsot.subcontract_po_shipment_id
  , jsot.subcontract_po_header_id
  , jsot.subcontract_po_line_id
  , jsot.oem_organization_id
  , jsot.tp_organization_id
  , jsot.osa_item_id
  , jsot.osa_item_price
  , jsot.need_by_date
  , jsot.uom
  , jsot.currency
  , jsot.quantity
  , -1
  , jsot.project_id
  , jsot.task_id
  , sysdate
  , FND_GLOBAL.user_id
  , sysdate
  , FND_GLOBAL.user_id
  , FND_GLOBAL.login_id
  , 'N'
  );

  END IF;

  -- To reprocess the existing records which are marked as error,
  -- update the interlock_status flag to 'N' so that they can be
  -- processed in this run.

  UPDATE jmf_subcontract_orders
  SET interlock_status ='N'
    , batch_id = -1
    , last_update_date = sysdate
    , last_updated_by = FND_GLOBAL.user_id
    , last_update_login = FND_GLOBAL.login_id
  WHERE  interlock_status = 'E'
  AND  EXISTS
  ( SELECT 'X'
    FROM jmf_subcontract_orders
    WHERE interlock_status = 'E');

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHK_OSA_LD_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Subcontract_Orders;

--========================================================================
-- PROCEDURE : Load_Replenishments    PRIVATE
-- PARAMETERS:
--             p_operating_unit      Operating Unit
--             p_from_organization   From Organization
--             p_to_organization     To Organization
-- COMMENT   : This procedure loads all the PO Shipment lines
--             that are eligible for processing the SHIKYU business flow.
--             It populates the JMF_SUBCONTRACT_
--             ORDERS table with the Shipment lines of the OSA item .
--========================================================================
PROCEDURE Load_Replenishments
( p_operating_unit             IN   NUMBER
, p_from_organization          IN   NUMBER
, p_to_organization            IN   NUMBER
)
IS

  --=================
  -- CURSORS
  --=================

  -- Selects the Replenishment POs with the supplier matching the OEM
  -- Organization and the Ship To Organization matching the TP
  -- Organization of some SHIKYU enabled shipping network.

  -- Bug 5678387: Modified the query to get the uom from PO_LINES_ALL
  -- if the uom is not stamped on the PO_LINE_LOCATIONS_ALL record

  CURSOR c_rep IS
  SELECT DISTINCT plla.line_location_id,
                  hoi.organization_id as oem_organization_id,
                  plla.ship_to_organization_id as tp_organization_id,
                  pla.item_id as shikyu_component_id,
                  msib.subcontracting_component,
                  plla.quantity,
                  plla.need_by_date,
                  NVL(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code),
                  pha.reference_num,
                  pha.segment1,
                  pla.line_num,
                  plla.shipment_num
  FROM  hr_organization_information hoi,
        po_line_locations_all plla,
        po_lines_all pla,
        po_headers_all pha,
        mtl_interorg_parameters mip,
        mtl_system_items_b msib
  WHERE hoi.org_information_context = 'Customer/Supplier Association'
  AND   TO_NUMBER(hoi.org_information3) = pha.vendor_id
  AND   TO_NUMBER(hoi.org_information4) = pha.vendor_site_id
  AND   mip.to_organization_id = plla.ship_to_organization_id
  AND   mip.from_organization_id = hoi.organization_id
	--AND   mip.SHIKYU_ENABLED_FLAG = 'Y'    /* SHIKYU_ENABLED_FLAG is no longer used*/
	AND mip.subcontracting_type in ('B','C') /* 12.1 Buy/Sell Subcontracting Changes */
  AND   plla.po_line_id = pla.po_line_id
  AND   plla.po_header_id = pha.po_header_id
  AND   plla.org_id = p_operating_unit
  AND   pla.item_id = msib.inventory_item_id
  AND   hoi.organization_id = msib.organization_id
  AND   msib.subcontracting_component in (1, 2)
  AND   pha.approved_flag = 'Y'
  AND   nvl(pha.cancel_flag, 'N') = 'N'
  AND   nvl(pla.cancel_flag, 'N') = 'N'
  AND   nvl(plla.cancel_flag, 'N') = 'N'
  AND   hoi.organization_id
   BETWEEN
    (NVL(p_from_organization, hoi.organization_id))
    AND
     (NVL(p_to_organization, hoi.organization_id)
    )
  AND NOT EXISTS (SELECT jsr.replenishment_so_line_id
                  FROM   jmf_shikyu_replenishments jsr
                  WHERE  jsr.replenishment_po_shipment_id = plla.line_location_id)
  ORDER BY plla.need_by_date,
           pha.segment1,
           pla.line_num,
           plla.shipment_num;

  -- Selects the Subcontracting PO Shipments that have been processed and still
  -- open, but not yet fully allocated, along with the component needing more
  -- allocation, and the required and allocated quantities
/*
  CURSOR c_alloc IS
  SELECT jsc.subcontract_po_shipment_id
       , jsc.shikyu_component_id
       , sum(nvl(jsa.allocated_quantity,0))
       , max(nvl(wro.required_quantity,0))
  FROM   jmf_shikyu_allocations     jsa
       , jmf_shikyu_components      jsc
       , jmf_subcontract_orders     jso
       , wip_requirement_operations wro
  WHERE jso.subcontract_po_shipment_id = jsc.subcontract_po_shipment_id
  AND   jsc.subcontract_po_shipment_id=jsa.subcontract_po_shipment_id(+)
  AND   jsc.shikyu_component_id=jsa.shikyu_component_id(+)
  AND   jso.interlock_status = 'P'
  AND   wro.wip_entity_id = jso.wip_entity_id
  AND   wro.inventory_item_id = jsc.shikyu_component_id
  AND   wro.organization_id = jso.tp_organization_id
  GROUP BY jsc.shikyu_component_id
         , jsc.subcontract_po_shipment_id
  HAVING sum(nvl(jsa.allocated_quantity,0)) <
         avg(nvl(wro.required_quantity,0));
*/

  CURSOR c_alloc IS
  SELECT jsc.subcontract_po_shipment_id
       , jsc.shikyu_component_id
       , max(TO_NUMBER(pha.segment1))
       , max(TO_NUMBER(pla.line_num))
       , max(TO_NUMBER(plla.shipment_num))
       , max(plla.need_by_date)
       , sum(nvl(jsa.allocated_quantity,0))
       , max(nvl(wro.required_quantity,0))
       , max(jsc.replen_so_creation_failed)
  FROM   jmf_shikyu_allocations     jsa
       , jmf_shikyu_components      jsc
       , jmf_subcontract_orders     jso
       , wip_requirement_operations wro
       , po_line_locations_all      plla
       , po_lines_all               pla
       , po_headers_all             pha
  WHERE jso.subcontract_po_shipment_id = jsc.subcontract_po_shipment_id
  AND   jsc.subcontract_po_shipment_id=jsa.subcontract_po_shipment_id(+)
  AND   jsc.shikyu_component_id = jsa.shikyu_component_id(+)
  AND   jso.interlock_status = 'P'
  AND   wro.wip_entity_id = jso.wip_entity_id
  AND   wro.inventory_item_id = jsc.shikyu_component_id
  AND   wro.organization_id = jso.tp_organization_id
  AND   plla.line_location_id = jso.subcontract_po_shipment_id
  AND   plla.po_line_id = pla.po_line_id
  AND   plla.po_header_id = pha.po_header_id
  AND   plla.org_id = p_operating_unit
  AND   nvl(pha.cancel_flag, 'N') = 'N'
  AND   nvl(pla.cancel_flag, 'N') = 'N'
  AND   nvl(plla.cancel_flag, 'N') = 'N'
  AND   jso.oem_organization_id
        BETWEEN
        NVL(p_from_organization, jso.oem_organization_id)
         AND
        NVL(p_to_organization, jso.oem_organization_id)
  GROUP BY jsc.shikyu_component_id
         , jsc.subcontract_po_shipment_id
  HAVING sum(nvl(jsa.allocated_quantity,0)) <
         avg(nvl(wro.required_quantity,0))
  ORDER BY max(plla.need_by_date),
           max(TO_NUMBER(pha.segment1)),
           max(TO_NUMBER(pla.line_num)),
           max(TO_NUMBER(plla.shipment_num));

  --=================
  -- LOCAL VARIABLES
  --=================

  l_subcontract_rec   g_SubcontractTabTyp;
  l_count             NUMBER;
  l_program           CONSTANT VARCHAR2(30) := 'Load_Replenishments';
  l_exists            BOOLEAN := FALSE;
  k                   INTEGER;
  l_line_location_id  NUMBER;
  l_oem_organization_id NUMBER;
  l_tp_organization_id  NUMBER;
  l_tp_supplier_id      NUMBER;
  l_tp_supplier_site_id NUMBER;
  l_component_id        NUMBER;
  l_msg_list            VARCHAR2(2000);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;
  l_return_status       VARCHAR2(1);
  l_osa_flag            NUMBER;
  l_comp_flag           NUMBER;
  --l_so_quantity         NUMBER;
  l_order_header_id     NUMBER;
  l_order_line_id       NUMBER;
  l_ship_date           DATE;
  l_ordered_uom         VARCHAR2(3);
  l_ordered_quantity    NUMBER;
  l_primary_uom_qty     NUMBER;
  l_primary_uom         VARCHAR2(3);
  l_additional_supply   VARCHAR2(1);
  l_po_uom              PO_LINE_LOCATIONS_ALL.unit_meas_lookup_code%TYPE;
  l_po_quantity         NUMBER;
  --l_shipment_id         NUMBER;
  l_osa_shipment_id     NUMBER;
  l_osa_component_id    NUMBER;
  l_total_qty           NUMBER;
  l_allocated_qty       NUMBER;
  l_qty                 NUMBER;
  l_reference_num       VARCHAR2(25);
  l_po_need_by_date     DATE;
  l_po_header_num       PO_HEADERS_ALL.SEGMENT1%TYPE;
  l_po_line_num         PO_LINES.LINE_NUM%TYPE;
  l_po_shipment_num     PO_LINE_LOCATIONS_ALL.SHIPMENT_NUM%TYPE;
  l_subcontracting_component
                        NUMBER;
  l_replen_so_creation_failed
                        VARCHAR2(1);

BEGIN
  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;

  -- Pick up all the replenishments created manually.

  OPEN c_rep;
  LOOP

    <<skip_curr_replen_po>>

    FETCH c_rep
    INTO  l_line_location_id
        , l_oem_organization_id
        , l_tp_organization_id
        , l_component_id
        , l_subcontracting_component
        , l_po_quantity
        , l_po_need_by_date
        , l_po_uom
        , l_reference_num
        , l_po_header_num
        , l_po_line_num
        , l_po_shipment_num;

    IF c_rep%NOTFOUND
    THEN
      EXIT;
    END IF;

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Fetching Replenishment POs not yet loaded');

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': l_line_location_id = ' || l_line_location_id
                    || ', l_oem_organization_id = ' || l_oem_organization_id
                    || ', l_tp_organization_id = ' || l_tp_organization_id
                    || ', l_component_id = ' || l_component_id
                    || ', l_po_quantity = ' || l_po_quantity
                    || ', l_po_need_by_date = ' || l_po_need_by_date
                    || ', l_po_uom = ' || l_po_uom
                    || ', l_reference_num = ' || l_reference_num
		    --Debugging changes for bug 9315131
		    || ', l_po_shipment_num = ' || l_po_shipment_num
		    || ', l_po_header_num = ' || l_po_header_num
		    || ', l_po_line_num = ' || l_po_line_num
		    || ', l_subcontracting_component = ' || l_subcontracting_component
                    );
    END IF;
    END IF;

    -- Check if component is pre-positioned or sync ship
    JMF_SHIKYU_GRP.Get_Shikyu_Attributes
    ( p_api_version             => 1.0
    , p_init_msg_list           => l_msg_list
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_organization_id         => l_tp_organization_id
    , p_item_id                 => l_component_id
    , x_outsourced_assembly     => l_osa_flag
    , x_subcontracting_component => l_comp_flag
    );

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': After calling Get_Shikyu_Attributes: l_return_status = '
                    || l_return_status
                    || ', l_osa_flag = '||l_osa_flag
                    || ', l_comp_flag = '||l_comp_flag
                    );
    END IF;
    END IF;

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
       (l_comp_flag = 1) -- Pre-positioned
    THEN

      l_additional_supply := 'N';

    ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
       (l_comp_flag = 2) -- sync-ship
    THEN

      -- This indicates that there are PO's that are created but not picked
      -- up the Interlock even though they are sync. ship. This could have
      -- happened because when interlock was run previously, it did not
      -- complete creating the replenishment PO for sync ship

      IF l_reference_num IS NULL
      THEN
        l_additional_supply := 'Y';
      ELSE
        l_additional_supply := 'N';
      END IF;

    ELSE

      --EXIT;
      GOTO skip_curr_replen_po;

    END IF;

    -- Create replenishment SO for all the replenishment PO's that are
    -- created manually.

    JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO
    ( p_action                     => 'C' --Create
    , p_subcontract_po_shipment_id => NULL --l_shipment_id
    , p_quantity                   => l_po_quantity
    , p_item_id                    => l_component_id
    , p_replen_po_shipment_id      => l_line_location_id
    , p_oem_organization_id        => l_oem_organization_id
    , p_tp_organization_id         => l_tp_organization_id
    , x_return_status              => l_return_status
    , x_order_line_id              => l_order_line_id
    );

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': After calling Process_Replenishment_SO: l_return_status = '
                    || l_return_status
                    || ', l_order_line_id:  = '
                    || l_order_line_id
                    );
    END IF;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

      SELECT header_id
           , schedule_ship_date
      INTO l_order_header_id
         , l_ship_date
      FROM oe_order_lines_all
      WHERE line_id = l_order_line_id;

      SELECT primary_uom_code
      INTO   l_primary_uom
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_component_id
      AND    organization_id   = l_tp_organization_id;

      l_ordered_uom:= JMF_SHIKYU_UTIL.Get_UOM_Code(l_po_uom);

      --Debugging for bug 9315131
      IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                        || ': l_order_header_id = ' || l_order_header_id
                        || ', l_ship_date = ' || l_ship_date
                        || ', l_primary_uom  = ' || l_primary_uom
		        || ', l_ordered_uom  = ' || l_ordered_uom
                       );
      END IF;

      IF l_primary_uom <> l_ordered_uom
      THEN
        l_primary_uom_qty := INV_CONVERT.inv_um_convert
                    ( item_id             => l_component_id
                    , precision           => 5
                    , from_quantity       => l_po_quantity
                    , from_unit           => l_ordered_uom
                    , to_unit             => l_primary_uom
                    , from_name           => null
                    , to_name             => null
                    );
      ELSE
        l_primary_uom_qty  := l_po_quantity;
        l_primary_uom      := l_ordered_uom;
      END IF; /* IF l_primary_uom <> l_ordered_uom */

      --Debugging for bug 9315131
      IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                        || ': l_primary_uom_qty = ' || l_primary_uom_qty
                       );
      END IF;

      -- To get the supplier id and supplier site id associated
      -- with the TP Organization
      SELECT TO_NUMBER(org_information3),
             TO_NUMBER(org_information4)
      INTO   l_tp_supplier_id,
             l_tp_supplier_site_id
      FROM   hr_organization_information
      WHERE  organization_id = l_tp_organization_id
      AND    org_information_context = 'Customer/Supplier Association';

      --Debugging for bug 9315131
      IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                        || ': l_tp_supplier_id = ' || l_tp_supplier_id
                        || ', l_tp_supplier_site_id  = ' || l_tp_supplier_site_id
                       );
      END IF;

      INSERT INTO JMF_SHIKYU_REPLENISHMENTS
      ( replenishment_so_line_id
      , replenishment_so_header_id
      , schedule_ship_date
      , replenishment_po_header_id
      , replenishment_po_line_id
      , replenishment_po_shipment_id
      , oem_organization_id
      , tp_organization_id
      , tp_supplier_id
      , tp_supplier_site_id
      , shikyu_component_id
      , ordered_quantity
      , ordered_primary_uom_quantity
      , uom
      , primary_uom
      , org_id
      , additional_supply
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , allocable_quantity
      , allocable_primary_uom_quantity
      , allocated_quantity
      , allocated_primary_uom_quantity
      )
      SELECT
        l_order_line_id
      , l_order_header_id
      , l_ship_date
      , poll.po_header_id
      , poll.po_line_id
      , poll.line_location_id
      , l_oem_organization_id
      , l_tp_organization_id
      , l_tp_supplier_id
      , l_tp_supplier_site_id
      , l_component_id
      , poll.quantity
      , l_primary_uom_qty
      , l_ordered_uom
      , l_primary_uom
      , poll.org_id
      , l_additional_supply
      , sysdate
      , FND_GLOBAL.user_id
      , sysdate
      , FND_GLOBAL.user_id
      , FND_GLOBAL.login_id
      , poll.quantity
      , l_primary_uom_qty
      , 0
      , 0
      FROM  po_line_locations_all poll
      WHERE poll.line_location_id = l_line_location_id;

    ELSE

      IF l_subcontracting_component = 2
        THEN

        l_osa_shipment_id := TO_NUMBER(SUBSTR(l_reference_num, 1, INSTR(l_reference_num, '-') - 1));

        UPDATE jmf_shikyu_components
        SET    replen_so_creation_failed = 'Y'
             , last_update_date = sysdate
             , last_updated_by = FND_GLOBAL.user_id
             , last_update_login = FND_GLOBAL.login_id
        WHERE  subcontract_po_shipment_id = l_osa_shipment_id
        AND    shikyu_component_id = l_component_id;

        IF g_log_enabled
           AND (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Setting replen_so_creation_failed = ''Y'' '
                      || 'for subcontract_po_shipment_id = '
                      || l_osa_shipment_id
                      || ', shikyu_component_id = '
                      || l_component_id
                      );
        END IF;

      END IF;

    END IF; /* IF l_return_status = FND_API.G_RET_STS_SUCCESS */

  END LOOP;

  --Bugfix 9315131
  close c_rep;

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Exit'
                    );
  END IF;
  END IF;

  -- After loading replenishments, auto allocate for all the shipment lines
  -- wherein the allocated quantity is less than required quantity.
  -- This will prevent unnecessarily creating new replenishments which
  -- can be allocated.

  OPEN c_alloc;
  LOOP
    FETCH c_alloc
    INTO  l_osa_shipment_id
        , l_osa_component_id
        , l_po_header_num
        , l_po_line_num
        , l_po_shipment_num
        , l_po_need_by_date
        , l_allocated_qty
        , l_total_qty
        , l_replen_so_creation_failed;

    IF c_alloc%NOTFOUND
    THEN
      EXIT;
    ELSE

      IF g_log_enabled
         AND (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program || ': Fetching Subcontract Orders not fully allocated');

        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program
                      || ': l_osa_shipment_id = ' || l_osa_shipment_id
                      || ', l_osa_component_id = ' || l_osa_component_id
                      || ', l_po_header_num = ' || l_po_header_num
                      || ', l_po_line_num = ' || l_po_line_num
                      || ', l_po_shipment_num = ' || l_po_shipment_num
                      || ', l_po_need_by_date = ' || l_po_need_by_date
                      || ', l_allocated_qty = ' || l_allocated_qty
                      || ', l_total_qty = ' || l_total_qty
                      || ', l_replen_so_creation_failed = ' || l_replen_so_creation_failed
                      );
      END IF;

      IF l_allocated_qty < l_total_qty
      THEN
        l_qty := (l_total_qty - l_allocated_qty);

        JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => null
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_subcontract_po_shipment_id => l_osa_shipment_id
        , p_component_id               => l_osa_component_id
        , p_qty                        => l_qty
        , p_skip_po_replen_creation    => NVL(l_replen_so_creation_failed, 'N')
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

          IF g_log_enabled
             AND (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                         , G_PKG_NAME
                         , '>> ' || l_program || ': Allocation Failed'
                         );
          END IF;

        END IF; /* IF l_return_status <> FND_API.G_RET_STS_SUCCESS */

	--Debug changes for bugfix 9315131
	IF g_log_enabled
          AND (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                         , G_PKG_NAME
                         , '>> ' || l_program
			 || ': l_replen_so_creation_failed:' || l_replen_so_creation_failed
                         );
        END IF;

        -- Reset the replen_so_creation_failed flag
        IF l_replen_so_creation_failed IS NOT NULL
          THEN

          UPDATE jmf_shikyu_components
          SET    replen_so_creation_failed = NULL
               , last_update_date = sysdate
               , last_updated_by = FND_GLOBAL.user_id
               , last_update_login = FND_GLOBAL.login_id
          WHERE  subcontract_po_shipment_id = l_osa_shipment_id
          AND    shikyu_component_id = l_osa_component_id;

        END IF;

      END IF; /* IF l_allocated_qty < l_total_qty */
    END IF; /* IF c_alloc%NOTFOUND*/

  END LOOP;
  CLOSE c_alloc;

EXCEPTION

  WHEN OTHERS THEN
    --Bugfix 9315131
    if c_rep%isopen then
      close c_rep;
    end if;

    if c_alloc%isopen then
      close c_alloc;
    end if;

    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHIKYU_REPL_LD_ERR');
    FND_MSG_PUB.add;

END Load_Replenishments;

--========================================================================
-- PROCEDURE : Load_Shikyu_Components    PRIVATE
-- PARAMETERS: p_operating_unit          The OU to execute the loading of
--                                       Subcontracting Order Components in
-- COMMENT   : This procedure loads all the components of the subcontracting order
--             based on the OSA shipments that are loaded in JMF_SUBCONTRACT_ORDERS
--========================================================================
PROCEDURE Load_Shikyu_Components
( p_operating_unit             IN   NUMBER
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================

  -- Bug 5678387: Removed the field group_id, since it is not
  -- necessary given that we do not insert into bom_explosion_temp
  -- anymore.

  TYPE l_osa_rec IS RECORD
  ( subcontract_po_shipment_id NUMBER
  , osa_item_id                NUMBER
  , oem_organization_id        NUMBER
  , tp_organization_id         NUMBER
  , need_by_date               DATE
  , quantity                   NUMBER
  , unit_of_measure            PO_LINE_LOCATIONS_ALL.unit_meas_lookup_code%TYPE
  , uom_code                   MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE
  , primary_uom_code           MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE
  , primary_uom_quantity       NUMBER
  , project_id                 NUMBER
  , task_id                    NUMBER
  , status                     VARCHAR2(1)
  );

  TYPE l_osa_TabTyp IS TABLE OF l_osa_rec;

  l_program                CONSTANT VARCHAR2(30) := 'Load_Shikyu_Components';

  l_osa_tbl                l_osa_TabTyp;
  l_errmsg                 VARCHAR2(2000);
  l_error_code             NUMBER;
  l_curr_index             NUMBER;
  l_return_status          VARCHAR2(1);
  l_start_date             DATE;
  l_order_header_id        NUMBER;
  l_order_line_id          NUMBER;

  -- Bug 5364037: Added for Lot/Serial validation
  l_lot_serial_valid_flag  VARCHAR2(1);

  -- Bug 5632012: For supporting OSA Items with Phantom Assemblies
  -- as Components
  l_comp_tbl               system.wip_component_tbl_t;
  l_count_seq              NUMBER;
  l_routing_count          NUMBER;

  --=================
  -- CURSORS
  --=================

  -- Bug 5500896: Added a where clause condition to filter out the
  -- subcontracting orders that do not belong to the operating unit
  -- for which the current run was executed in

  -- Bug 5678387: Modified the query to get the uom from PO_LINES_ALL
  -- if the uom is not stamped on the PO_LINE_LOCATIONS_ALL record,
  -- which seems to be the case for PO Release Shipments
  -- Also, removed bom_explosion_temp_s.nextval from the select statement
  -- since we do not insert into bom_explosion_temp, and this would
  -- unnecessarily bump up the sequence number for the ID of
  -- bom_explosion_temp

  CURSOR c_comp_cur IS
  SELECT
    jso.subcontract_po_shipment_id
  , jso.osa_item_id
  , jso.oem_organization_id
  , jso.tp_organization_id
  , jso.need_by_date
  , poll.quantity
  , NVL(poll.unit_meas_lookup_code, pla.unit_meas_lookup_code)
  , NULL
  , NULL
  , NULL
  , jso.project_id
  , jso.task_id
  , 'V'
  FROM
    jmf_subcontract_orders jso
  , po_line_locations_all poll
  , po_lines_all pla
  WHERE poll.line_location_id = jso.subcontract_po_shipment_id
  AND   pla.po_line_id = poll.po_line_id
  AND   jso.interlock_status = 'N'
  AND   poll.org_id = p_operating_unit
  AND NOT EXISTS
  (SELECT shikyu_component_id
   FROM   jmf_shikyu_components
   WHERE  subcontract_po_shipment_id = jso.subcontract_po_shipment_id);

/*
  -- Once the BOM is exploded for the OSA item, the components
  -- are grouped so that when we load the components in WIP table
  -- to create the WIP job, we use the standard mechanism to create
  -- requirements by item/operations. Hence we check if there
  -- are multiple operation requirements for the same item.
  -- If the same item is defined in multiple operations, we
  -- log a message and move on to the next shipment.
  -- We do not summarize the item at the item/operation level.

  CURSOR c_bom_cur(l_group_id NUMBER
                  ,l_parent_id NUMBER) IS
  SELECT
    component_item_id shikyu_component_id
  , primary_uom_code primary_uom
  , sum(component_quantity) quantity
  , count(component_item_id) count_seq
  FROM
    bom_explosion_temp
  WHERE group_id = l_group_id
  AND   assembly_item_id = l_parent_id
  AND   l_start_date BETWEEN
       (effectivity_date) and NVL(disable_date,l_start_date+1)
  GROUP BY component_item_id,primary_uom_code;
*/

BEGIN

  IF g_log_enabled THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;

  OPEN c_comp_cur;
  FETCH c_comp_cur
  BULK COLLECT INTO l_osa_tbl;
  CLOSE c_comp_cur;

  IF g_log_enabled THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': After opening c_comp_cur, l_osa_tbl.COUNT = ' || l_osa_tbl.COUNT
                );
  END IF;
  END IF;

  IF l_osa_tbl.COUNT > 0 THEN
  FOR i IN l_osa_tbl.FIRST..l_osa_tbl.LAST
  LOOP

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Exploding BOM for subcontract_po_shipment_id = '
                      || l_osa_tbl(i).subcontract_po_shipment_id
                      || ', osa_item_id = '
                      || l_osa_tbl(i).osa_item_id
                      || ', oem_organization_id = '
                      || l_osa_tbl(i).oem_organization_id
                      || ', tp_organization_id = '
                      || l_osa_tbl(i).tp_organization_id
                    );
    END IF;

    -- Get the count of routings defined for the OSA Item in the
    -- TP Organization
    SELECT count(bor.routing_sequence_id)
    INTO   l_routing_count
    FROM   bom_operational_routings bor
    WHERE  bor.organization_id = l_osa_tbl(i).tp_organization_id
    AND    bor.assembly_item_id = l_osa_tbl(i).osa_item_id;

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': l_routing_count = '
                      || l_routing_count
                    );
    END IF;

    -- Continue loading SHIKYU Components only if there are no routings
    -- defined for the OSA Item in the TP Organization
    IF l_routing_count <= 0
    THEN

    BEGIN

      SELECT uom_code
      INTO   l_osa_tbl(i).uom_code
      FROM   mtl_units_of_measure_vl
      WHERE  unit_of_measure = l_osa_tbl(i).unit_of_measure;

      l_osa_tbl(i).primary_uom_code := JMF_SHIKYU_UTIL.Get_Primary_Uom_Code
                                     ( l_osa_tbl(i).osa_item_id
                                     , l_osa_tbl(i).tp_organization_id
                                     );

      --Debugging for bug 9315131
      IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
		    ||': uom_code = ' || l_osa_tbl(i).uom_code
		    || ': primary_uom_code = ' || l_osa_tbl(i).primary_uom_code
                    );
      END IF;

      IF l_osa_tbl(i).uom_code <> l_osa_tbl(i).primary_uom_code
      THEN

        l_osa_tbl(i).primary_uom_quantity
          := INV_CONVERT.inv_um_convert
             ( item_id       => l_osa_tbl(i).osa_item_id
             , precision     => 5
             , from_quantity => l_osa_tbl(i).quantity
             , from_unit     => l_osa_tbl(i).uom_code
             , to_unit       => l_osa_tbl(i).primary_uom_code
             , from_name     => null
             , to_name       => null
             );

      ELSE

        l_osa_tbl(i).primary_uom_quantity := l_osa_tbl(i).quantity;

      END IF;

      IF g_log_enabled AND
         (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program
                      || ': Primary UOM = '
                      || l_osa_tbl(i).primary_uom_quantity
                      || ', Subcontracting PO UOM = '
                      || l_osa_tbl(i).quantity
                                            );
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF g_log_enabled AND
           (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                        || ': NO DATA FOUND when trying to do UOM conversion for Subcontract PO Shipment with ID '
                        || l_osa_tbl(i).subcontract_po_shipment_id
                    );
        END IF;
    END;

    -- Compute the start date for the WIP job

    JMF_SHIKYU_WIP_PVT.Compute_Start_Date
    ( p_need_by_date       => l_osa_tbl(i).need_by_date
    , p_item_id            => l_osa_tbl(i).osa_item_id
    , p_oem_organization   => l_osa_tbl(i).oem_organization_id
    , p_tp_organization    => l_osa_tbl(i).tp_organization_id
    , p_quantity           => l_osa_tbl(i).primary_uom_quantity
    , x_start_date         => l_start_date
    );

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': WIP Job Start Date = ' || l_start_date
                  );
    END IF;
    END IF;

    -- Bug 5632012:
    -- For the current OSA item being fetched, call the WIP explodeRequirements
    -- API (instead of the BOM Explosion API directly) in order to explode the
    -- bom to get all the components that are part of the OSA item.  This WIP API
    -- would consider phantom components and explode multiple levels.

    wip_bflProc_priv.explodeRequirements( p_itemID       => l_osa_tbl(i).osa_item_id
                                        , p_orgID        => l_osa_tbl(i).tp_organization_id
                                        , p_qty          => l_osa_tbl(i).primary_uom_quantity
                                        , p_altBomDesig  => NULL
                                        , p_altOption    => 2
                                        , p_bomRevDate   => l_start_date
                                        , p_txnDate      => l_start_date
                                        , p_implFlag     => 2
                                        , p_projectID    => l_osa_tbl(i).project_id
                                        , p_taskID       => l_osa_tbl(i).task_id
                                        , p_initMsgList  => fnd_api.g_false
                                        , p_endDebug     => fnd_api.g_true
                                        , x_compTbl      => l_comp_tbl
                                        , x_returnStatus => l_return_status);

    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': After calling wip_bflProc_priv.explodeRequirements: '
                  || 'Return Status = ' || l_return_status
                  || ', Comp Tbl Size = ' || l_comp_tbl.COUNT
                  );
    END IF;
    END IF;

    -- if WIP Explode Requirements erred out
    -- Bugfix 9315131: Adding an OR condition. The else used to fail
    -- with ORA-06502: PL/SQL: numeric or value error: NULL index table key value
    -- if OSA didn't have any BOM.
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR
       l_comp_tbl.COUNT = 0
    THEN
      -- Error in bom explosion. Mark the shipment line status as error.
      -- Skip and move on to the next shipment line. In the next run,
      -- the shipment line that is marked as error, will be processed
      -- starting from loading the components.

      --Debugging for 9315131
      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || 'Inside If. Either wip returned error or No BOM for OSA'
                    );
      END IF;
      END IF;

      UPDATE JMF_SUBCONTRACT_ORDERS
      SET interlock_status = 'E'
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.login_id
      WHERE subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;

      FND_MESSAGE.set_name('JMF', 'JMF_SHK_INVALID_BOM');
      FND_MSG_PUB.add;

      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> ' || l_program
                       || ': WIP Explode Requirements API failed for organization_id = '
                       || l_osa_tbl(i).tp_organization_id
                       || '/ inventory_item_id = ' || l_osa_tbl(i).osa_item_id
                       );
      END IF;
      END IF;

      l_return_status := NULL;

    -- if WIP Explode Requirements completed successfully
    ELSE

      l_return_status := NULL;

      l_curr_index := l_comp_tbl.FIRST;

      LOOP
       IF g_log_enabled AND
          (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> ' || l_program || ': Loading shikyu_component_id = '
                       || l_comp_tbl(l_curr_index).inventory_item_id
                       || ', item_name = '
                       || l_comp_tbl(l_curr_index).item_name
                       || ', index of BOM Explosion LOOP = '
                       || l_curr_index
                       );
       END IF;

       /* if Component is a Phantom Assembly */
       IF l_comp_tbl(l_curr_index).wip_supply_type = 6
       THEN

         IF g_log_enabled AND
            (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                         , G_PKG_NAME
                         , '>> ' || l_program || ': Shikyu Component '
                         || l_comp_tbl(l_curr_index).item_name
                         || ' is of Supply Type Phantom and will not be loaded into JMF_SHIKYU_COMPONENTS'
                         );
         END IF;

       ELSE /* if Component is not a Phantom Assembly */

       -- Checking to make sure that the same component would not be inserted into
       -- the jmf_shikyu_components table multiple times.  The same component can be
       -- an immediate child of the assembly item, or the child of a phantom child
       -- (at any level) of the assembly.

       IF g_log_enabled AND
          (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> ' || l_program
                       || ': Quantity for Shikyu Component '
                       || l_comp_tbl(l_curr_index).item_name
                       || ' = '
                       || l_comp_tbl(l_curr_index).primary_quantity
                       );
       END IF;

       l_count_seq := 0;

       SELECT COUNT(*)
       INTO   l_count_seq
       FROM   jmf_shikyu_components
       WHERE  subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id
       AND    shikyu_component_id = l_comp_tbl(l_curr_index).inventory_item_id;

       IF g_log_enabled AND
          (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> ' || l_program
                       || ': l_count_seq  = '
                       || l_count_seq
                       || ', Shikyu Component '
                       || l_comp_tbl(l_curr_index).item_name
                       || ' already exists in the JMF_SHIKYU_COMPONENTS table'
                       );
       END IF;

       IF l_count_seq > 0
       THEN

         IF g_log_enabled AND
            (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                        || ': BOM has same item defined in multiple operation sequences for subcontract_po_shipment_id '
                        || l_osa_tbl(i).subcontract_po_shipment_id
                        );
         END IF;

       END IF; /* l_count_seq > 0 */

       -- Verify the attributes of the Shikyu components that are to be loaded.

       IF g_log_enabled THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                          || ': Call Verify_Shikyu_Attributes for shikyu_component_id = '
                          || l_comp_tbl(l_curr_index).inventory_item_id);
         END IF;
       END IF;

       Verify_Shikyu_Attributes
       ( p_osa_item_id          => l_osa_tbl(i).osa_item_id
       , p_component_item_id    => l_comp_tbl(l_curr_index).inventory_item_id
       , p_oem_organization_id  => l_osa_tbl(i).oem_organization_id
       , p_tp_organization_id   => l_osa_tbl(i).tp_organization_id
       , x_return_status        => l_return_status
       );

       IF g_log_enabled AND
          (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> ' || l_program || ': Return status from Verify_Shikyu_Attributes = '
                         || l_return_status
                         || ', for shikyu_component_id = '
                         || l_comp_tbl(l_curr_index).inventory_item_id
                         || ', subcontract_po_shipment_id = '
                         || l_osa_tbl(i).subcontract_po_shipment_id);
       END IF;

       -- Bug 5364037: To validate that the OSA item is not Lot and/or
       -- Serial controlled in the TP Organization

       IF l_return_status = FND_API.G_RET_STS_SUCCESS
       THEN

         Validate_Lot_Serial_Control
         ( p_item_id         => l_comp_tbl(l_curr_index).inventory_item_id
         , p_organization_id => l_osa_tbl(i).tp_organization_id
         , x_valid_flag      => l_lot_serial_valid_flag
         );

         IF l_lot_serial_valid_flag = 'N'
         THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

         IF g_log_enabled AND
            (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                         , G_PKG_NAME
                         , '>> ' || G_PKG_NAME || '.' || l_program
                         || ': l_return_status after Lot/Serial validation = '
                         || l_return_status
                         || ', for shikyu_component_id = '
                         || l_comp_tbl(l_curr_index).inventory_item_id
                         || ', subcontract_po_shipment_id = '
                         || l_osa_tbl(i).subcontract_po_shipment_id
                         );
         END IF;

       END IF;

       IF g_log_enabled THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                         , G_PKG_NAME
                         , '>> ' || l_program
                           || ': primary_uom_code for shikyu_component_id '
                           || l_comp_tbl(l_curr_index).inventory_item_id
                           || ' = ' || l_comp_tbl(l_curr_index).primary_uom_code
                         );
         END IF;
       END IF;

       /* if component validation passed */
       IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
       THEN
         -- Load the Components table.

         IF NVL(l_count_seq, 0) = 0
         THEN
           INSERT INTO JMF_SHIKYU_COMPONENTS
           ( subcontract_po_shipment_id
           , shikyu_component_id
           , oem_organization_id
           , primary_uom
           , quantity
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , request_id
           , program_application_id
           , program_id
           , program_update_date
           )
           VALUES
           ( l_osa_tbl(i).subcontract_po_shipment_id
           , l_comp_tbl(l_curr_index).inventory_item_id
           , l_osa_tbl(i).oem_organization_id
           , l_comp_tbl(l_curr_index).primary_uom_code
           , l_comp_tbl(l_curr_index).primary_quantity
           , sysdate
           , FND_GLOBAL.user_id
           , sysdate
           , FND_GLOBAL.user_id
           , FND_GLOBAL.login_id
           , null
           , null
           , null
           , null
           );

           IF g_log_enabled AND
              (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                           , G_PKG_NAME
                           , '>> ' || l_program
                           || ': After insert into JMF_SHIKYU_COMPONENTS');
           END IF;

         ELSE

           IF g_log_enabled AND
              (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                           , G_PKG_NAME
                           , '>> ' || l_program
                           || ': JMF_SHIKYU_COMPONENTS record with ID = '
                           || l_comp_tbl(l_curr_index).inventory_item_id
                           || ' already inserted');
           END IF;

           UPDATE JMF_SHIKYU_COMPONENTS
           SET    quantity = quantity + l_comp_tbl(l_curr_index).primary_quantity
           WHERE  subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id
           AND    shikyu_component_id = l_comp_tbl(l_curr_index).inventory_item_id;

         END IF; /* IF NVL(l_count_seq, 0) = 0 */

         -- Invoke Process Replenishment SO with action of Quote.
         -- This will just populate the UOM code and price in
         -- the jmf_shikyu_components table without creating the
         -- order line. This information is required when creating
         -- the replenishment SO for the component.

         JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO
         ( p_action                => 'Q' --Quote
         , p_subcontract_po_shipment_id =>
             l_osa_tbl(i).subcontract_po_shipment_id
         , p_quantity               => l_comp_tbl(l_curr_index).primary_quantity
         , p_item_id                => l_comp_tbl(l_curr_index).inventory_item_id
         , p_replen_po_shipment_id  => null
         , p_oem_organization_id    => l_osa_tbl(i).oem_organization_id
         , p_tp_organization_id     => l_osa_tbl(i).tp_organization_id
         , x_order_line_id          => l_order_line_id
         , x_return_status          => l_return_status
         );

         IF g_log_enabled AND
            (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_PKG_NAME
                        , '>> ' || l_program
                          || ': Process_Replenishment_SO returns '
                          || l_return_status
                          || ', l_order_line_id = ' || l_order_line_id);
         END IF;

        -- If the return status from Process_Replenishment_SO (doing Price Quote)
        -- is not success, move on to the next shipment line
        /*
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN

          -- Update the interlock_status of the current Subcontracting Order to 'E',
          -- signifying that some errors occurred when loading the components
          -- (specifically, shikyu_component_price could not be obtained)
          UPDATE JMF_SUBCONTRACT_ORDERS
          SET interlock_status = 'E'
            , last_update_date = sysdate
            , last_updated_by = FND_GLOBAL.user_id
            , last_update_login = FND_GLOBAL.login_id
          WHERE subcontract_po_shipment_id =
                  l_osa_tbl(i).subcontract_po_shipment_id;

        END IF;
        */

     ELSE /* if component validation failed */

      -- Error in validating attributes. Mark the shipment line status as Invalid.
      -- Skip and move on to the next shipment line.

      UPDATE JMF_SUBCONTRACT_ORDERS
      SET interlock_status = 'E'
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.login_id
      WHERE subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;

      DELETE FROM jmf_shikyu_components
      WHERE  subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;

      IF g_log_enabled AND
         (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_PKG_NAME
                     , '>> ' || l_program || ': Component Validation failed for oem_organization_id = '
                             || l_osa_tbl(i).oem_organization_id
                             || ', tp_organization_id = '
                             || l_osa_tbl(i).tp_organization_id
                             || ', osa_item_id = '
                             || l_osa_tbl(i).osa_item_id
                             || ', subcontract_po_shipment_id = '
                             || l_osa_tbl(i).subcontract_po_shipment_id);
      END IF;

      -- Skip current Subcontracting Order (since component validation failed) and
      -- move on to the next Order
      EXIT;

     END IF; /* IF (l_return_status = FND_API.G_RET_STS_SUCCESS) */

     END IF; /* IF l_comp_tbl(l_curr_index).wip_supply_type = 6 */

     l_curr_index := l_comp_tbl.next(l_curr_index);
     EXIT WHEN l_curr_index IS NULL;

     END LOOP; /* End of FOR LOOP iterating l_comp_tbl */

   END IF; /* IF l_return_status <> FND_API.G_RET_STS_SUCCESS*/

   ELSE /* IF l_routing_count <= 0 */

      IF g_log_enabled AND
         (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_PKG_NAME
                     , '>> ' || l_program || ': Routing exists for oem_organization_id = '
                             || l_osa_tbl(i).oem_organization_id
                             || ', tp_organization_id = '
                             || l_osa_tbl(i).tp_organization_id
                             || ', osa_item_id = '
                             || l_osa_tbl(i).osa_item_id
                             || ', subcontract_po_shipment_id = '
                             || l_osa_tbl(i).subcontract_po_shipment_id);

        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_PKG_NAME
                     , '>> ' || l_program
                     || ': Marking the JMF_SUBCONTRACT_ORDERS record with interlock_status ''E''');
      END IF;

      -- Routings defined for the OSA Item in the TP Organization.  Mark the interlock_status
      -- of the Subcontract Shipment Line status as 'E' (Error).
      -- Skip and move on to the next Subcontract Shipment Line.

      UPDATE JMF_SUBCONTRACT_ORDERS
      SET interlock_status = 'E'
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.login_id
      WHERE subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;

   END IF; /* IF l_routing_count <= 0 */

  END LOOP; /* End of FOR LOOP iterating l_osa_tbl */

  END IF; /* IF l_osa_tbl.COUNT > 0 */

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Exit'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHIKYU_COMP_LD_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Shikyu_Components;

--========================================================================
-- PROCEDURE : Stamp_Null_Shikyu_Comp_Prices    PRIVATE
-- PARAMETERS: None
-- COMMENT   : This procedure stamps the SHIKYU Component records with
--             NULL prices because of errors tahat occurred in a previous
--             run
--========================================================================
PROCEDURE Stamp_Null_Shikyu_Comp_Prices
( p_operating_unit             IN   NUMBER
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================

  l_oem_organization_id
    JMF_SUBCONTRACT_ORDERS.oem_organization_id%TYPE;
  l_tp_organization_id
    JMF_SUBCONTRACT_ORDERS.tp_organization_id%TYPE;
  l_subcontract_po_shipment_id
    JMF_SHIKYU_COMPONENTS.subcontract_po_shipment_id%TYPE;
  l_shikyu_component_id
    JMF_SHIKYU_COMPONENTS.shikyu_component_id%TYPE;
  l_quantity
    JMF_SHIKYU_COMPONENTS.quantity%TYPE;
  l_order_line_id
    OE_ORDER_LINES_ALL.line_id%TYPE;

  l_program CONSTANT VARCHAR2(30) := 'Stamp_Null_Shikyu_Comp_Prices';
  l_return_status VARCHAR2(1);

  --=================
  -- CURSORS
  --=================

  CURSOR c_comp_cur IS
  SELECT
    jsc.subcontract_po_shipment_id
  , jsc.shikyu_component_id
  , jsc.quantity
  , jso.oem_organization_id
  , jso.tp_organization_id
  FROM
    jmf_subcontract_orders jso,
    jmf_shikyu_components jsc,
    po_line_locations_all plla
  WHERE jso.subcontract_po_shipment_id = jsc.subcontract_po_shipment_id
  AND   shikyu_component_price IS NULL
  AND   plla.line_location_id = jso.subcontract_po_shipment_id
  AND   plla.org_id = p_operating_unit;

BEGIN

  IF g_log_enabled AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Start'
                  );
  END IF;

  IF g_log_enabled AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': p_operating_unit = ' || p_operating_unit
                  );
  END IF;

  OPEN c_comp_cur;
  LOOP

    FETCH c_comp_cur
    INTO  l_subcontract_po_shipment_id
        , l_shikyu_component_id
        , l_quantity
        , l_oem_organization_id
        , l_tp_organization_id;

    IF c_comp_cur%NOTFOUND
    THEN
      EXIT;
    END IF;

    -- Invoke Process Replenishment SO with action of Quote.
    -- This will just populate the UOM code and price in
    -- the jmf_shikyu_components table without creating the
    -- order line. This information is required when creating
    -- the replenishment SO for the component.

    IF g_log_enabled AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': Calling Process_Replenishment_SO for '
                    || 'subcontract_po_shipment_id = ' || l_subcontract_po_shipment_id
                    || ', shikyu_component_id = ' || l_shikyu_component_id);
    END IF;

    JMF_SHIKYU_ONT_PVT.Process_Replenishment_SO
    ( p_action                 => 'Q' --Quote
    , p_subcontract_po_shipment_id
                               => l_subcontract_po_shipment_id
    , p_quantity               => l_quantity
    , p_item_id                => l_shikyu_component_id
    , p_replen_po_shipment_id  => null
    , p_oem_organization_id    => l_oem_organization_id
    , p_tp_organization_id     => l_tp_organization_id
    , x_order_line_id          => l_order_line_id
    , x_return_status          => l_return_status
    );

    IF g_log_enabled AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': Process_Replenishment_SO returns '
                    || l_return_status
                    || ', l_order_line_id = ' || l_order_line_id);
    END IF;

  END LOOP;

  CLOSE c_comp_cur;


  IF g_log_enabled AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Exit'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    --Bugfix 9315131
    if c_comp_cur%isopen then
      CLOSE c_comp_cur;
    end if;

    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHK_STAMP_COMP_PRICE_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Stamp_Null_Shikyu_Comp_Prices;

--========================================================================
-- FUNCTION  : Generate_Batch_Id         PRIVATE
-- PARAMETERS: None
-- RETURNS   : NUMBER
-- COMMENT   : This function returns the next batch id to be assigned to
--             the records in JMF_SUBCONTRACT_ORDERS
--=========================================================================
FUNCTION generate_batch_id
RETURN NUMBER
IS
l_batch_id NUMBER;
l_program CONSTANT VARCHAR2(30) := 'Generate_Batch_Id';
BEGIN

  IF g_log_enabled THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;
  END IF;
  -- Generate sequence that will become the new batch id

  SELECT  jmf_shikyu_batch_s.NEXTVAL
    INTO  l_batch_id
    FROM  dual;

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

  RETURN l_batch_id;

END generate_batch_id;

--========================================================================
-- PROCEDURE : Process_Subcontract_Orders    PRIVATE
-- PARAMETERS: p_batch_id          Batch ID
-- COMMENT   : This procedure is called by the worker to process all the
--             records in the batch that is loaded in JMF_SUBCONTRACT_ORDERS
--             table.
--========================================================================
PROCEDURE Process_Subcontract_Orders
( p_batch_id                 IN   NUMBER
)
IS
  l_program CONSTANT VARCHAR2(30) := 'Process_Subcontract_Orders';
  l_osa_tbl       g_OsaTabTyp;
  l_comp_tbl      g_Comp_TabTyp;
  l_quantity      NUMBER;
  l_return_status VARCHAR2(1);
  l_wip_entity_id NUMBER;
  l_shipment_id   NUMBER;
  l_po_uom        VARCHAR2(25);
  l_primary_uom   VARCHAR2(25);
  l_po_qty        NUMBER;
  l_comp_qty      NUMBER;
  l_msg_data   VARCHAR2(2000);
  l_msg_count  NUMBER;
  l_osa_item        MTL_SYSTEM_ITEMS_B.SEGMENT1%TYPE;
  l_tp_organization MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
  l_message         VARCHAR(2000);
  l_status_flag     BOOLEAN;

  CURSOR c_osa_rec IS
  SELECT *
  FROM   jmf_subcontract_orders
  WHERE  batch_id = p_batch_id
  AND    interlock_status in ('N','U');

  CURSOR c_comp_rec IS
  SELECT *
  FROM   jmf_shikyu_components
  WHERE  subcontract_po_shipment_id = l_shipment_id;

BEGIN

  IF g_log_enabled THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Start >>'
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , '>> ' || l_program || ': p_batch_id = '
                  , p_batch_id
                  );
  END IF;
  END IF;

  OPEN c_osa_rec;
  FETCH c_osa_rec
  BULK COLLECT INTO l_osa_tbl;
  CLOSE c_osa_rec;

  FOR i IN l_osa_tbl.FIRST .. l_osa_tbl.LAST
  LOOP

    IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Processing Subcontracting Order with '
                    || 'subcontract_po_shipment_id = '
                    || l_osa_tbl(i).subcontract_po_shipment_id
                    || ', osa_item_id = '
                    || l_osa_tbl(i).osa_item_id
                    || ', oem_organization_id = '
                    || l_osa_tbl(i).oem_organization_id
                    || ', tp_organization_id = '
                    || l_osa_tbl(i).tp_organization_id
                    );
    END IF;

    -- Bug 5678387: Modified the query to get the uom from PO_LINES_ALL
    -- if the uom is not stamped on the PO_LINE_LOCATIONS_ALL record,
    -- which seems to be the case for PO Release Shipments

    SELECT plla.quantity
         , NVL(plla.unit_meas_lookup_code, pla.unit_meas_lookup_code)
    INTO   l_po_qty
         , l_po_uom
    FROM   po_line_locations_all plla
         , po_lines_all pla
    WHERE  plla.line_location_id = l_osa_tbl(i).subcontract_po_shipment_id
    AND    plla.po_line_id = pla.po_line_id;

    l_primary_uom:= JMF_SHIKYU_UTIL.Get_Primary_UOM
                    (l_osa_tbl(i).osa_item_id
                    ,l_osa_tbl(i).tp_organization_id);

    -- Check if Purchasing UOM is different than the primary UOM of the item
    -- IF it is convert to primary UOM.

    IF l_po_uom <> l_primary_uom
    THEN
      l_quantity := INV_CONVERT.inv_um_convert
                  ( item_id             => l_osa_tbl(i).osa_item_id
                  , precision           => 5
                  , from_quantity       => l_po_qty
                  , from_unit           => null
                  , to_unit             => null
                  , from_name           => l_po_uom
                  , to_name             => l_primary_uom
                  );
    ELSE
      l_quantity := l_po_qty;
    END IF;

    -- Create a WIP job at the TP org for the OSA item

    JMF_SHIKYU_WIP_PVT.Process_WIP_Job
    ( p_action                 => 'C'
    , p_subcontract_po_shipment_id => l_osa_tbl(i).subcontract_po_shipment_id
    , p_need_by_date           => l_osa_tbl(i).need_by_date
    , p_quantity               => l_quantity
    , x_return_status          => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
      -- If WIP job is created, update with the WIP job id

      SELECT wip_entity_id
      INTO   l_wip_entity_id
      FROM   JMF_SUBCONTRACT_ORDERS
      WHERE  subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;
      -- Based on the above action, update JSO with interlock_status
      UPDATE jmf_subcontract_orders
      SET    interlock_status ='P'
           , last_update_date = sysdate
           , last_updated_by = FND_GLOBAL.user_id
           , last_update_login = FND_GLOBAL.login_id
      WHERE  subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;

      l_osa_tbl(i).wip_entity_id := l_wip_entity_id;

      l_shipment_id := l_osa_tbl(i).subcontract_po_shipment_id;

      --Debugging for bug 9315131
      IF g_log_enabled AND
       (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': Processed Subcontracting Order with '
                    || 'subcontract_po_shipment_id = '
                    || l_osa_tbl(i).subcontract_po_shipment_id
                    || ', osa_item_id = '
                    || l_osa_tbl(i).osa_item_id
                    || ', oem_organization_id = '
                    || l_osa_tbl(i).oem_organization_id
                    || ', tp_organization_id = '
                    || l_osa_tbl(i).tp_organization_id
		    || ', wip_entity_id = '
                    || l_osa_tbl(i).wip_entity_id
                    );
      END IF;

      OPEN c_comp_rec;
      FETCH c_comp_rec
      BULK COLLECT INTO l_comp_tbl;
      CLOSE c_comp_rec;


      FOR k IN l_comp_tbl.FIRST .. l_comp_tbl.LAST
      LOOP

       l_comp_qty := JMF_SHIKYU_WIP_PVT.get_component_quantity
                     ( p_item_id => l_comp_tbl(k).shikyu_component_id
                     , p_organization_id => l_osa_tbl(i).tp_organization_id
                     , p_subcontract_po_shipment_id =>
                          l_osa_tbl(i).subcontract_po_shipment_id
                     );
      -- Call Process Allocation to allocate
      -- based in sync or pre-stock process allocation accordingly.

        JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => null
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_subcontract_po_shipment_id => l_osa_tbl(i).subcontract_po_shipment_id
        , p_component_id               => l_comp_tbl(k).shikyu_component_id
        , p_qty                        => l_comp_qty
        , p_skip_po_replen_creation    => 'N'
        );
      END LOOP;

    ELSE
      UPDATE jmf_subcontract_orders
      SET    interlock_status ='U'
           , batch_id = -1
           , last_update_date = sysdate
           , last_updated_by = FND_GLOBAL.user_id
           , last_update_login = FND_GLOBAL.login_id
      WHERE  subcontract_po_shipment_id = l_osa_tbl(i).subcontract_po_shipment_id;

      --Debugging changes for bug 9315131
      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Process_Wip_Job returned E for shipment:'
		  || l_osa_tbl(i).subcontract_po_shipment_id
                  );
      END IF;
      END IF;

      /*  Bug 7000413 - Start */
      /* Log the error in the Concurrent Request log   */
      BEGIN

        SELECT segment1 INTO l_osa_item
        FROM mtl_system_items_b
        WHERE inventory_item_id = l_osa_tbl(i).osa_item_id
        AND organization_id = l_osa_tbl(i).tp_organization_id ;

        SELECT organization_code INTO l_tp_organization
        FROM mtl_parameters
        WHERE organization_id =l_osa_tbl(i).tp_organization_id ;

        fnd_message.set_name('JMF','JMF_SHK_WIP_JOB_ERROR');
        fnd_message.set_token('OSA', l_osa_item);
        fnd_message.set_token('MP', l_tp_organization);
        l_message := fnd_message.GET();
        fnd_file.put_line(fnd_file.LOG,  l_message);
        l_status_flag := FND_CONCURRENT.set_completion_status('WARNING',NULL);
      EXCEPTION
      WHEN OTHERS THEN
        NULL; -- Return null if there is an error in fetching the message
      END;
      /*  Bug 7000413 - End */

    END IF;

  END LOOP;


EXCEPTION

  WHEN OTHERS THEN

    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHK_INTERLK_PROCESS_ERR');
    FND_MSG_PUB.add;

END Process_Subcontract_Orders;

--========================================================================
-- PROCEDURE : Allocate_batch        PRIVATE
-- PARAMETERS: p_batch_size          Batch size to be processed
--             p_max_workers         Maximum no of workers allowed
--             p_operating_unit      Operating unit passed in
--                                   from the concurrent request
--             p_from_organization   From OEM Organization
--             p_to_organization     To OEM Organization
-- COMMENT   : This procedure allocates batches to a set of records
--             that are grouped for processing.
--========================================================================
PROCEDURE Allocate_batch
( p_batch_size                 IN   NUMBER
, p_max_workers                IN   NUMBER
, p_operating_unit             IN   NUMBER
, p_from_organization          IN   NUMBER
, p_to_organization            IN   NUMBER
)
IS
  --=================
  -- LOCAL VARIABLES
  --=================

  TYPE t_osa_TabTyp IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  l_osa_tbl     t_osa_TabTyp;
  l_request_tbl JMF_SHIKYU_UTIL.g_request_tbl_type;
  l_batch_size  NUMBER;
  l_curr_index  NUMBER := 0;
  l_count       NUMBER := 0;
  l_batch_id    NUMBER;
  l_program CONSTANT VARCHAR2(30) := 'Allocate_batch';
  l_request_id  NUMBER;
  l_return_status VARCHAR2(1);

  -- Bug 5500896: Modified the cursor query to select only the
  -- Subcontracting Orders that belongs to the OU in which the
  -- current concurrent request operates, and for which
  -- the OEM Organization is in the range passed in from
  -- the concurrent request.  Also, any cancelled POs would
  -- be filtered out.

  /*
  CURSOR c_proc_batch IS
  SELECT jso.subcontract_po_shipment_id
    FROM jmf_subcontract_orders jso
  WHERE  jso.interlock_status IN ('N', 'U');
  */

  CURSOR c_proc_batch IS
  SELECT jso.subcontract_po_shipment_id
  FROM   jmf_subcontract_orders     jso
       , po_line_locations_all      plla
       , po_lines_all               pla
       , po_headers_all             pha
  WHERE jso.interlock_status IN ('N', 'U')
  AND   plla.line_location_id = jso.subcontract_po_shipment_id
  AND   plla.po_line_id = pla.po_line_id
  AND   plla.po_header_id = pha.po_header_id
  AND   plla.org_id = p_operating_unit
  AND   nvl(pha.cancel_flag, 'N') = 'N'
  AND   nvl(pla.cancel_flag, 'N') = 'N'
  AND   nvl(plla.cancel_flag, 'N') = 'N'
  AND   jso.oem_organization_id
        BETWEEN
        NVL(p_from_organization, jso.oem_organization_id)
         AND
        NVL(p_to_organization, jso.oem_organization_id)
  ORDER BY jso.subcontract_po_shipment_id;

BEGIN

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Start'
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': p_batch_size = ' || p_batch_size
                  || ', p_max_worker = ' || p_max_workers
		  --Debug changes for Bug 9315131
		  || ', p_operating_unit = ' || p_operating_unit
		  || ', p_from_organization = ' || p_from_organization
		  || ', p_to_organization = ' || p_to_organization
                  );
  END IF;
  END IF;

  OPEN c_proc_batch;
  FETCH c_proc_batch
  BULK COLLECT INTO l_osa_tbl;
  CLOSE c_proc_batch;

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program
                  || ': l_osa_tbl.COUNT = '|| l_osa_tbl.COUNT
                  );
  END IF;

  IF l_osa_tbl.COUNT > 0
  THEN

    l_count := l_osa_tbl.LAST;
    l_curr_index := l_osa_tbl.FIRST;


    IF (p_batch_size IS NULL) OR (l_count < p_batch_size)
    THEN
      l_batch_size := l_osa_tbl.LAST;
    ELSE
      l_batch_size := p_batch_size ;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                     , G_PKG_NAME
                     , '>> ' || l_program
                     || ': Actual batch size = ' || l_batch_size
                     );
    END IF;

    LOOP
      l_batch_id := generate_batch_id();

      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> '|| l_program
                    || ': After calling generate_batch_id: '
                    || 'current index = ' || l_curr_index
                    || ', batch_id = ' || l_batch_id
                    || ', batch size = ' || l_batch_size
                    );
      END IF;
      END IF;

      FORALL i IN l_curr_index .. l_batch_size
      UPDATE jmf_subcontract_orders
      SET batch_id         = l_batch_id
        , last_update_date = sysdate
        , last_updated_by = FND_GLOBAL.user_id
        , last_update_login = FND_GLOBAL.login_id
      WHERE subcontract_po_shipment_id = l_osa_tbl(i);

      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program
                    || ': After updating JMF_SUBCONTRACT_ORDERS with batch ID '
                    || l_batch_id
                    );
      END IF;
      END IF;

      -- Invoke the worker to process the bunch of transactions that
      -- are grouped after generating a new batch id.

      JMF_SHIKYU_UTIL.Submit_Worker
      ( p_batch_id        => l_batch_id
      , p_request_count   => NVL(p_max_workers,1)
      , p_cp_short_name   => 'JMFSKIWP'
      , p_cp_product_code => 'JMF'
      , x_workers         => l_request_tbl
      , x_request_id      => l_request_id
      , x_return_status   => l_return_status
      );

      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , '>> ' || l_program || ': After calling submit_worker, '
                    || 'l_return_status = ' || l_return_status
                    || ', l_request_id = ' || l_request_id
                    );
      END IF;
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF g_log_enabled THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_PKG_NAME
                      , '>> ' || l_program || ': Batch with id ' || l_batch_id
                        || ' not processed'
                      );
        END IF;
        END IF;
      END IF;

      IF l_batch_size = l_osa_tbl.LAST
      THEN
        EXIT;
      ELSE
        l_curr_index := l_batch_size ;
        l_batch_size := p_batch_size+l_curr_index;

        IF l_count < l_batch_size
        THEN
          l_batch_size := l_osa_tbl.LAST;
        END IF;
      END IF;

    END LOOP;
  END IF;

  --- add check for all workers complete

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': After LOOP, waiting for all workers to complete, '
                  || 'l_request_tbl COUNT = ' || l_request_tbl.COUNT
                  );
  END IF;

  jmf_shikyu_util.wait_for_all_workers(p_workers => l_request_tbl );

  IF g_log_enabled AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Exit'
                  );
  END IF;

END Allocate_batch;

--========================================================================
-- PROCEDURE : Subcontract_Orders_Manager    PUBLIC
-- PARAMETERS: p_batch_size          Batch size to be processed
--             p_max_workers         Maximum no of workers allowed
--             p_operating_unit      Operating Unit
--             p_from_organization   From Organization
--             p_to_organization     To Organization
--             p_init_msg_list       indicate if msg list needs to be initialized
--             p_validation_level    Validation Level
-- COMMENT   : The Interlock Concurrent program manager invokes this procedure
--             to process all the Subcontract Orders. This is the main entry
--             point for processing any subcontract records.
--========================================================================
PROCEDURE Subcontract_Orders_Manager
( p_batch_size                 IN   NUMBER
, p_max_workers                IN   NUMBER
, p_operating_unit             IN   NUMBER
, p_from_organization          IN   NUMBER
, p_to_organization            IN   NUMBER
, p_init_msg_list              IN  VARCHAR2
, p_validation_level           IN  NUMBER
)
IS
  l_program CONSTANT VARCHAR2(30) := 'Subcontract_Orders_Manager';
  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(2000);

  --Variable to store the OM debug file name. Bug 9315131
  l_file_val   VARCHAR2(60);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSHKB '
                  , '>> ' || l_program || ': Start >>'
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSHKB p_batch_size => '
                  , p_batch_size
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , ' p_max_workers => '
                  , p_max_workers
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , ' p_operating_unit => '
                  , p_operating_unit
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , ' p_from_organization => '
                  , p_from_organization
                  );
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , ' p_to_organization => '
                  , p_to_organization
                  );
    --Debugging for bug 9315131
    --Starting OM debugging.
    oe_debug_pub.debug_on;
    oe_debug_pub.initialize;
    l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
    oe_Debug_pub.setdebuglevel(5);

    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || 'OM Debug File:' || l_file_val
                  );
    --End OM debugging.
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean(NVL(p_init_msg_list, FND_API.G_FALSE) ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- If SHIKYU is not enabled, do not process the records.

  IF NVL(FND_PROFILE.value('JMF_SHK_CHARGE_BASED_ENABLED'),'N') = 'Y'
  THEN
   -- Load the Subcontract orders that are eligible for processing.
   Load_Subcontract_Orders
   ( p_operating_unit     => p_operating_unit
   , p_from_organization  => p_from_organization
   , p_to_organization    => p_to_organization
   );

   -- Moved the call to Stamp_Null_Shikyu_Comp_Prices before the call
   -- to Load_Shikyu_Components, in order to avoid calling OM Process
   -- Order API again to get prices for the components that were newly
   -- inserted into the JMF_SHIKYU_COMPONENTS table and that failed
   -- price quoting the first time (typically because of wrong or
   -- missing pricing setup), which can seriously hurt the performance.
   Stamp_Null_Shikyu_Comp_Prices
   ( p_operating_unit     => p_operating_unit
   );

   -- Bug 5500896: Added an actual parameter to pass the
   -- operating unit
   Load_Shikyu_Components
   ( p_operating_unit     => p_operating_unit
   );
/*
   Stamp_Null_Shikyu_Comp_Prices
   ( p_operating_unit     => p_operating_unit
   );
*/
   Load_Replenishments
   ( p_operating_unit     => p_operating_unit
   , p_from_organization  => p_from_organization
   , p_to_organization    => p_to_organization
   );

   -- Bug 5500896: Added actual parameters to pass the
   -- operating unit and the range of OEM organization id
   Allocate_batch
   ( p_batch_size         => p_batch_size
   , p_max_workers        => p_max_workers
   , p_operating_unit     => p_operating_unit
   , p_from_organization  => p_from_organization
   , p_to_organization    => p_to_organization
   );

  ELSE
    FND_MESSAGE.Set_Name('JMF', 'JMF_SHK_NOT_ENABLED');
    FND_MSG_PUB.Add;
    IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': Charge based SHIKYU not enabled >>'
                  );
    END IF;
    END IF;

  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_INTERLK_MGR_ERR');
    FND_MSG_PUB.add;
    FND_MSG_PUB.Count_And_Get
      ( p_count         =>  l_msg_count
      , p_data          =>  l_msg_data
      );

  WHEN OTHERS THEN
    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHK_INTERLK_MGR_ERR');
    FND_MSG_PUB.add;
    FND_MSG_PUB.Count_And_Get
    (  p_count        => l_msg_count
    ,  p_data         => l_msg_data
    );

END Subcontract_Orders_Manager;

--========================================================================
-- PROCEDURE : Subcontract_Orders_Worker    PUBLIC
-- PARAMETERS: p_batch_id          Batch Id
-- COMMENT   : This procedure is invoked by the Subcontract_Orders_manager.
--             After the batch is assigned by the Manager, the Subcontract
--             Orders Manager process will launch this worker to complete
--             the processing of the Subcontract Orders.
--========================================================================
PROCEDURE Subcontract_Orders_Worker
( p_batch_id         IN   NUMBER
)
IS
 l_program CONSTANT VARCHAR2(30) := 'Subcontract_Orders_Worker';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;

    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Start'
                );
  END IF;

  JMF_SUBCONTRACT_ORDERS_PVT.Process_Subcontract_Orders(p_batch_id);

  IF g_log_enabled THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                , G_PKG_NAME
                , '>> ' || l_program || ': Exit'
                );
  END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF g_log_enabled AND
       (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_PKG_NAME
                    , G_PKG_NAME || l_program || ': ' || sqlerrm);
    END IF;

    FND_MESSAGE.set_name('JMF', 'JMF_SHK_INTERLK_WRKR_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Subcontract_Orders_Worker;

END JMF_SUBCONTRACT_ORDERS_PVT;

/
