--------------------------------------------------------
--  DDL for Package Body INV_LOGICAL_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOGICAL_TRANSACTIONS_PUB" AS
/* $Header: INVLTPBB.pls 120.28.12010000.5 2010/03/18 19:36:18 musinha ship $ */

  l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

  PROCEDURE print_debug(
       p_err_msg       IN VARCHAR2,
       p_level         IN NUMBER := 9
  ) IS
  BEGIN
      INV_LOG_UTIL.Trace(p_message => p_err_msg,
                         p_module  => 'INV_LOGICAL_TRANSACTIONS_PUB',
                         p_level   => p_level);
  END print_debug;


  PROCEDURE GET_ACCT_PERIOD(
         x_return_status       OUT NOCOPY  VARCHAR2
       , x_msg_count           OUT NOCOPY  NUMBER
       , x_msg_data            OUT NOCOPY  VARCHAR2
       , x_acct_period_id      OUT NOCOPY  NUMBER
       , p_organization_id     IN  NUMBER
       , p_transaction_date    IN  DATE
  )
  IS
  BEGIN
     IF (l_debug = 1) THEN
        print_debug('Enter get_acct_period', 9);
        print_debug('p_organization_id = ' || p_organization_id, 9);
     END IF;

     SELECT acct_period_id
     INTO   x_acct_period_id
     FROM   org_acct_periods
     WHERE  period_close_date IS NULL
     AND    organization_id = p_organization_id
     AND    TRUNC(schedule_close_date) >=
            TRUNC(NVL(p_transaction_date,sysdate))
     AND    TRUNC(PERIOD_START_DATE) <=
            TRUNC(NVL(p_transaction_date,sysdate));

     IF (l_debug = 1) THEN
        print_debug('x_acct_period_id = ' || x_acct_period_id, 9);
     END IF;

     x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN no_data_found THEN
          x_return_status := G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('GET_ACCT_PERIOD: no_data_found error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
     WHEN OTHERS THEN
          x_return_status := G_RET_STS_UNEXP_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_acct_period');
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('GET_ACCT_PERIOD: others error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
  END GET_ACCT_PERIOD;



  PROCEDURE GET_COGS_ACCT_FOR_LOGICAL_SO(
          x_return_status       OUT NOCOPY  VARCHAR2
        , x_msg_count           OUT NOCOPY  NUMBER
        , x_msg_data            OUT NOCOPY  VARCHAR2
        , x_cogs_acct_id        OUT NOCOPY  NUMBER
        , p_inventory_item_id   IN NUMBER
        , p_order_line_id       IN NUMBER
	, p_ic_to_inv_organization_id IN NUMBER  DEFAULT NULL   -- Bug: 4607049. Added parameter to get the Selling Inventory organization to pass to INV_WORKFLOW.
  )
  IS
     l_dist_acct_id    NUMBER := null;
     l_order_header_id NUMBER := null;
     l_order_type_id   NUMBER := null;
     l_customer_id     NUMBER := null;
     l_selling_org_id  NUMBER := null;
     l_flex_seg        VARCHAR2(2000) := null;
     l_error_msg       VARCHAR2(2000);
     l_success         BOOLEAN := TRUE;
     l_sob_id          NUMBER := NULL;
     l_coa_id          NUMBER := NULL;
     lreturn_status    VARCHAR2(1);
     lmsg_data         VARCHAR2(100);
  BEGIN
     IF (l_debug = 1) THEN
        print_debug('Enter get_cogs_acct_for_logical_so', 9);
        print_debug('p_inventory_item_id = ' || p_inventory_item_id, 9);
        print_debug('p_order_line_id = ' || p_order_line_id, 9);
	print_debug('p_ic_to_inv_organization_id = ' || p_ic_to_inv_organization_id, 9);
     END IF;

     BEGIN
        SELECT oel.header_id,
               oel.org_id,
               oel.sold_to_org_id,
               oeh.order_type_id
        INTO   l_order_header_id,
               l_selling_org_id,
               l_customer_id,
               l_order_type_id
        FROM   oe_order_headers_all oeh,
               oe_order_lines_all oel
        WHERE  oel.line_id = p_order_line_id
        AND    oel.header_id = oeh.header_id;

        IF (l_debug = 1) THEN
           print_debug('header_id = ' || l_order_header_id, 9);
           print_debug('selling_org_id = ' || l_selling_org_id, 9);
           print_debug('customer_id = ' || l_customer_id, 9);
           print_debug('order_type_id = ' || l_order_type_id, 9);
        END IF;
     EXCEPTION
        WHEN no_data_found THEN
             IF (l_debug = 1) THEN
                print_debug('Cannot find so order line or OU for order line = '
                            || p_order_line_id, 9);
             END IF;
             RAISE FND_API.G_EXC_ERROR;
     END;

    /* commented the selection of COA using LE - OU link which is obsoleted in R12
       and replaced the code with selection of COAs using the API - INV_GLOBALS.GET_LEDGER_INFO
       Bug No - 4336479
     begin
	SELECT to_number(LEI.org_information1)
	  INTO    l_sob_id
	  FROM   hr_organization_information LEI
	  ,      hr_organization_information OUI
	  ,      hr_organization_units OU
	  ,      hr_organization_units LE
	  WHERE  OU.organization_id = l_selling_org_id
	  AND    LEI.org_information_context = 'Legal Entity Accounting'
	  AND    to_char(LEI.organization_id) = OUI.org_information2
	  AND    OUI.org_information_context = 'Operating Unit Information'
	  AND    OUI.organization_id = OU.organization_id
	  AND    LE.organization_id = LEI.organization_id;
     EXCEPTION
        WHEN no_data_found THEN
	   IF (l_debug = 1) THEN
	      -- print_debug('Cannot find set of books id for the selling OU = '
	      --		  || l_selling_org_id, 9);
	 -- Modified the message text set of books to ledger for making
	 --the message compatible with LE uptake project
	      print_debug('Cannot find ledger id for the selling OU = '
	      		  || l_selling_org_id, 9);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
     END;

     BEGIN
        SELECT  chart_of_accounts_id
	  INTO   l_coa_id
	  FROM   gl_sets_of_books
	  WHERE  set_of_books_id = l_sob_id;
     EXCEPTION
        WHEN no_data_found THEN
	   IF (l_debug = 1) THEN
	      -- print_debug('Cannot find chart of accounts id for the SOB ID = '
	      --		  || l_sob_id, 9);
              -- Modified the message text set of books to ledger for making the message compatible with LE uptake project
	      print_debug('Cannot find chart of accounts id for the Ledger ID = '
			  || l_sob_id, 9);
	   END IF;
	   RAISE FND_API.G_EXC_ERROR;
     END;
     */

     BEGIN
              Inv_globals.get_ledger_info(
                                    x_return_status                => lreturn_status,
                                    x_msg_data                     => lmsg_data  ,
                                    p_context_type                 => 'Operating Unit Information',
                                    p_org_id                       => l_selling_org_id,
                                    x_sob_id                       => l_sob_id,
                                    x_coa_id                       => l_coa_id,
                                    p_account_info_context         => 'BOTH');
            IF NVL(lreturn_status , 'S') = 'E' THEN
                   print_debug('Cannot find Ledger Information for Operating Unit = '||l_selling_org_id , 9);
                   RAISE FND_API.G_EXC_ERROR;
            END IF;
     END;

     IF (l_debug = 1) THEN
        print_debug('Calling INV_WORKFLOW.CALL_GENERATE_COGS', 9);
     END IF;

     l_success := INV_WORKFLOW.call_generate_cogs
       (
	c_fb_flex_num                  => l_coa_id,
	c_IC_CUSTOMER_ID               => l_customer_id
	, c_ic_iTEM_ID                 => p_inventory_item_id
	, c_IC_ORDER_HEADER_ID         => l_order_header_id
	, c_IC_ORDER_LINE_ID           => p_order_line_id
	, c_IC_ORDER_TYPE_ID           => l_order_type_id
	, c_IC_SELL_OPER_UNIT          => l_selling_org_id
	, c_V_CCID                     => x_cogs_acct_id
	, c_FB_FLEX_SEG                => l_flex_seg
	, c_FB_ERROR_MSG               => l_error_msg
	, c_IC_TO_INV_ORGANIZATION_ID  => p_ic_to_inv_organization_id); -- Bug: 4607049.

     IF (l_success) THEN
        IF (l_debug = 1) THEN
           print_debug('l_success is TRUE', 9);
           print_debug('x_cogs_acct_id = ' || x_cogs_acct_id, 9);
        END IF;
     ELSE
        IF (l_debug = 1) THEN
           print_debug('l_success = FALSE', 9);
           print_debug('error msg : ' || l_error_msg, 9);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := G_RET_STS_ERROR;
          IF (l_debug = 1) THEN
             print_debug('GET_COGS_FOR_LOGICAL_SO: Expected Error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
     WHEN OTHERS THEN
          x_return_status := G_RET_STS_UNEXP_ERROR;
          IF (l_debug = 1) THEN
             print_debug('GET_COGS_FOR_LOGICAL_SO: Others Error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
  END GET_COGS_ACCT_FOR_LOGICAL_SO;

  PROCEDURE GET_DEFAULT_COSTGROUP(
          x_return_status       OUT NOCOPY  VARCHAR2
        , x_msg_count           OUT NOCOPY  NUMBER
        , x_msg_data            OUT NOCOPY  VARCHAR2
        , x_cost_group_id       OUT NOCOPY  NUMBER
        , p_organization_id     IN  NUMBER
  )
  IS
  BEGIN
     IF (l_debug = 1) THEN
        print_debug('Enter get_default_costgroup', 9);
        print_debug('p_organization_id = ' || p_organization_id, 9);
     END IF;

     SELECT default_cost_group_id
     INTO   x_cost_group_id
     FROM   mtl_parameters
     WHERE  organization_id = p_organization_id;

     IF (l_debug = 1) THEN
        print_debug('x_cost_group_id = ' || x_cost_group_id, 9);
     END IF;

     x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN no_data_found THEN
          x_return_status := G_RET_STS_ERROR;

          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('GET_DEFAULT_COSTGROUP: No Data Found Error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
     WHEN OTHERS THEN
          x_return_status := G_RET_STS_UNEXP_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_acct_period');
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('GET_DEFAULT_COSTGROUP: Others Error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
  END GET_DEFAULT_COSTGROUP;


  PROCEDURE GET_PROJECT_COSTGROUP(
          x_return_status       OUT NOCOPY  VARCHAR2
        , x_msg_count           OUT NOCOPY  NUMBER
        , x_msg_data            OUT NOCOPY  VARCHAR2
        , x_cost_group_id       OUT NOCOPY  NUMBER
        , p_project_id          IN  NUMBER
        , p_organization_id     IN  NUMBER
  )
  IS
  BEGIN
     IF (l_debug = 1) THEN
        print_debug('Enter get_project_costgroup', 9);
        print_debug('p_project_id = ' || p_project_id, 9);
        print_debug('p_organization_id = ' || p_organization_id, 9);
     END IF;

     SELECT costing_group_id
     INTO   x_cost_group_id
     FROM   mrp_project_parameters
     WHERE  project_id = p_project_id
     and    organization_id = p_organization_id;

     IF (l_debug = 1) THEN
        print_debug('x_cost_group_id = ' || x_cost_group_id, 9);
     END IF;

     x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN no_data_found THEN
          x_return_status := G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('GET_PROJECT_COSTGROUP: No Data Found Error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
     WHEN OTHERS THEN
          x_return_status := G_RET_STS_UNEXP_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_acct_period');
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('GET_PROJECT_COSTGROUP: Others Error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
  END GET_PROJECT_COSTGROUP;


------------------------------------------------------------------------------

PROCEDURE create_exp_req_rcpt_trx(x_return_status OUT nocopy VARCHAR2,
				  x_msg_data OUT nocopy VARCHAR2,
				  p_transaction_id IN NUMBER,
				  p_transaction_temp_id IN NUMBER)
  IS
     l_return_status varchar2(1);
     l_msg_data VARCHAR2(240);
     l_msg_count NUMBER;
     l_account_period_id NUMBER;
     l_organization_id NUMBER;
     l_transaction_date DATE;
     l_cost_group_id NUMBER;
     l_project_id NUMBER;
     l_requisition_line_id NUMBER;
     l_expenditure_type VARCHAR2(240);
     l_distribution_account_id NUMBER;
     --changes for backport3990277
     l_trx_src_id NUMBER;
     x_ret_status VARCHAR2(5);
     prj_ref_enabled NUMBER;
     l_pm_cost_collected VARCHAR2(3);
     l_expenditure_org NUMBER;
     l_task_id NUMBER;

     --
     -- OPM INVCONV: umoogala  11-Jul-2006
     -- Bug 5349860: Process/Discrete Internal Order Xfer to Exp Destination
     --
     l_process_discrete_xfer  VARCHAR2(1);
     l_transfer_price         NUMBER;
     l_curr_rate              NUMBER;
     l_precision              NUMBER;
     l_ext_precision          NUMBER;
     l_min_unit               NUMBER;

     l_parentorg_process_org  VARCHAR2(1);
     l_parentorg_currency     fnd_currencies.currency_code%TYPE;

     l_logicalorg_process_org VARCHAR2(1);
     l_logicalorg_ou_id       NUMBER;
     l_logicalorg_currency    fnd_currencies.currency_code%TYPE;

     -- End Bug 5349860

BEGIN


   --
   -- OPM INVCONV: umoogala  11-Jul-2006
   -- Bug 5349860: Process/Discrete Internal Order Xfer to Exp Destination
   -- Getting process_enabled_flag's for orgs.
   --
   SELECT
          mmtt.transfer_organization, mmtt.transaction_date,
          mmtt.requisition_line_id,
	  parentorg.process_enabled_flag, logicalorg.process_enabled_flag,
	  codx.operating_unit, cod.currency_code,
	  mmtt.transfer_price
     INTO
          l_organization_id,l_transaction_date,
          l_requisition_line_id,
	  l_parentorg_process_org, l_logicalorg_process_org,
	  l_logicalorg_ou_id, l_parentorg_currency,
	  l_transfer_price
     FROM mtl_material_transactions_temp mmtt,
          mtl_parameters parentorg, mtl_parameters logicalorg,
	  cst_organization_definitions cod, cst_organization_definitions codx
    WHERE mmtt.transaction_temp_id   = p_transaction_temp_id
      AND parentorg.organization_id  = mmtt.organization_id
      AND logicalorg.organization_id = mmtt.transfer_organization
      AND cod.organization_id        = mmtt.organization_id
      AND codx.organization_id       = mmtt.transfer_organization
   ;

   --
   -- OPM INVCONV: umoogala  11-Jul-2006
   -- Bug 5349860: Process/Discrete Internal Order Xfer to Exp Destination
   --
   IF l_parentorg_process_org <> l_logicalorg_process_org
   THEN
     l_process_discrete_xfer := 'Y';
   ELSE
     l_process_discrete_xfer := 'N';
   END IF;

   --changes for backport3990277
   --check if Project ref enabled
   SELECT NVL(project_reference_enabled,2)
     INTO prj_ref_enabled
     FROM mtl_parameters
    WHERE organization_id = l_organization_id ;

   SELECT REQUISITION_HEADER_ID
     INTO l_trx_src_id
     FROM PO_REQUISITION_LINES_ALL
    WHERE requisition_line_id =l_requisition_line_id;

   --bug 3357867 get the distribution account id from po api
   -- get the expenditure type and org from po_distributions.
   SELECT expenditure_type,expenditure_organization_id
     INTO l_expenditure_type,l_expenditure_org
     FROM po_req_distributions_all
    WHERE requisition_line_id = l_requisition_line_id;

   l_distribution_account_id:= PO_REQ_DIST_SV1.get_dist_account(l_requisition_line_id);

   inv_project.Get_project_info_from_Req(
                 x_ret_status,
                 l_project_id,
                 l_task_id,
                 l_requisition_line_id);

   IF (x_ret_status <> g_ret_sts_success) THEN
      print_debug('Failed to get project id and task id');
      x_return_status := x_ret_status;
      RETURN;
   END IF;


   IF (l_project_id IS NOT NULL)THEN
      l_pm_cost_collected :='N';
   END IF;
   --changes for backport3990277

   GET_ACCT_PERIOD(
		   x_return_status =>l_return_status,
		   x_msg_count =>l_msg_count,
		   x_msg_data    =>l_msg_data,
		   x_acct_period_id  =>l_account_period_id,
		   p_organization_id =>l_organization_id,
		   p_transaction_date => l_transaction_date);

   IF (l_return_status <> g_ret_sts_success) THEN
      print_debug('Failed to get acct period id for org:'||l_organization_id ||' message '||l_msg_data);
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      RETURN;
   END IF;

    IF (l_project_id IS NULL OR prj_ref_enabled=2) THEN
       get_default_costgroup(
			     x_return_status   => l_return_status
			     , x_msg_count       => l_msg_count
			     , x_msg_data        => l_msg_data
			     , x_cost_group_id   => l_cost_group_id
			     , p_organization_id => l_organization_id);
     ELSE
       get_project_costgroup(
			     x_return_status   => l_return_status
			     , x_msg_count       => l_msg_count
			     , x_msg_data        => l_msg_data
			     , x_cost_group_id   => l_cost_group_id
			     , p_project_id      => l_project_id
			     , p_organization_id => l_organization_id);
    END IF;

          IF (l_return_status <> G_RET_STS_SUCCESS) THEN
             IF (l_debug = 1) THEN
                print_debug('get_default_costgroup returns error', 9);
                print_debug('l_msg_data = ' || l_msg_data, 9);
             END IF;
             FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;


 /*Bug# 5027170. The column 'logical_transaction' is included in the following
   INSERT statement because the record inserted corresponds to a logical
   transaction*/

   --
   -- OPM INVCONV: umoogala  11-Jul-2006
   -- Bug 5349860: Process/Discrete Internal Order Xfer to Exp Destination
   -- Convert transfer price from shipping currency to receiving currency.
   --
   IF l_process_discrete_xfer = 'Y'
   THEN
     print_debug(': Now doing currency conversion from Currency: ' ||
        l_parentorg_currency || ' to functional currency, if necessary');

     l_curr_rate := INV_TRANSACTION_FLOW_PUB.convert_currency (
                                p_org_id              => l_logicalorg_ou_id
                              , p_transfer_price      => 1
                              , p_currency_code       => l_parentorg_currency
                              , p_transaction_date    => l_transaction_date
                              , x_functional_currency_code => l_logicalorg_currency
                              , x_return_status       => l_return_status
                              , x_msg_data            => l_msg_data
                              , x_msg_count           => l_msg_count
                              );


     IF (l_return_status <> G_RET_STS_SUCCESS) THEN
        IF (l_debug = 1) THEN
           print_debug('INV_TRANSACTION_FLOW_PUB.convert_currency returns error', 9);
           print_debug('l_msg_data = ' || l_msg_data, 9);
        END IF;
        x_return_status := l_return_status;
        x_msg_data      := l_msg_data;
        RETURN;
     END IF;
     fnd_currency.get_info (currency_code     => l_logicalorg_currency,
                            precision         => l_precision,
                            ext_precision     => l_ext_precision,
                            min_acct_unit     => l_min_unit);

     l_transfer_price := round(l_curr_rate * l_transfer_price, l_ext_precision);
   END IF;

   INSERT INTO mtl_material_transactions
     (TRANSACTION_ID,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     REVISION,
     SUBINVENTORY_CODE,
     LOCATOR_ID,
     TRANSACTION_TYPE_ID,
     TRANSACTION_ACTION_ID,
     TRANSACTION_SOURCE_TYPE_ID,
     TRANSACTION_SOURCE_ID,
     TRANSACTION_SOURCE_NAME,
     TRANSACTION_QUANTITY,
     TRANSACTION_UOM,
     PRIMARY_QUANTITY,
     TRANSACTION_DATE,
     ACCT_PERIOD_ID,
     DISTRIBUTION_ACCOUNT_ID,
     COSTED_FLAG,
     ACTUAL_COST,
     INVOICED_FLAG,
     TRANSACTION_COST,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_RATE,
     CURRENCY_CONVERSION_TYPE,
     CURRENCY_CONVERSION_DATE,
     PM_COST_COLLECTED,
     TRX_SOURCE_LINE_ID,
     SOURCE_CODE,
     SOURCE_LINE_ID,
     TRANSFER_ORGANIZATION_ID,
     TRANSFER_SUBINVENTORY,
     TRANSFER_LOCATOR_ID,
     COST_GROUP_ID,
     TRANSFER_COST_GROUP_ID,
     PROJECT_ID,
     TASK_ID,
     TO_PROJECT_ID,
     TO_TASK_ID,
     SHIP_TO_LOCATION_ID,
     TRANSACTION_MODE,
     TRANSACTION_BATCH_ID,
     TRANSACTION_BATCH_SEQ,
     LPN_ID,
     parent_transaction_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     transaction_set_id,
     expenditure_type,
     PA_EXPENDITURE_ORG_ID,
     logical_transaction,
     --
     -- OPM INVCONV: umoogala  11-Jul-2006
     -- Added transfer_price, and opm_costed_flag columns
     --
     transfer_price,
     opm_costed_flag,
     SHIPMENT_NUMBER) /*  Bug 6411640.Shipment Number was not inserted for
Logical receipt */
     SELECT
      mmt.transfer_transaction_id,
      mmt.TRANSFER_ORGANIZATION_ID,
      mmt.INVENTORY_ITEM_ID,
      mmt.REVISION,
      mmt.TRANSFER_SUBINVENTORY,
      mmt.TRANSFER_LOCATOR_ID,
      g_type_logl_exp_req_receipt,
      G_ACTION_LOGICALEXPREQRECEIPT,
      g_sourcetype_intreq,
      l_trx_src_id,
      null,
      Abs(mmt.transaction_quantity),
      mmt.TRANSACTION_UOM,
      Abs(mmt.primary_quantity),
      mmt.TRANSACTION_DATE,
      l_account_period_id,
     l_distribution_account_id,
     --
     -- OPM INVCONV: umoogala  11-Jul-2006
     -- Bug 5349860: Process/Discrete Internal Order Xfer to Exp Destination
     -- If this logical txn org is process org, then set costed_flag to NULL.
     --
      decode(l_logicalorg_process_org, 'Y', NULL, 'N'), /* OPMCONV ANTHIYAG Bug#5510484 06-Sep-2006 */
      mmt.ACTUAL_COST,
      mmt.INVOICED_FLAG,
      mmt.TRANSACTION_COST,
      mmt.CURRENCY_CODE,
      mmt.CURRENCY_CONVERSION_RATE,
      mmt.CURRENCY_CONVERSION_TYPE,
      mmt.CURRENCY_CONVERSION_DATE,
      l_pm_cost_collected,--added pm_cost_collected flag
      l_requisition_line_id,
      mmt.SOURCE_CODE,
      mmt.SOURCE_LINE_ID,
      mmt.ORGANIZATION_ID,
      mmt.SUBINVENTORY_CODE,
      mmt.LOCATOR_ID,
      l_cost_group_id,
      mmt.TRANSFER_COST_GROUP_ID,
      l_project_id,
      l_task_id,
      mmt.TO_PROJECT_ID,
      mmt.TO_TASK_ID,
      mmt.SHIP_TO_LOCATION_ID,
      mmt.TRANSACTION_MODE,
      mmt.TRANSACTION_BATCH_ID,
      mmt.TRANSACTION_BATCH_SEQ,
      mmt.LPN_ID,
      mmt.transaction_id,
      mmt.last_update_date,
      mmt.last_updated_by,
      mmt.creation_date,
     mmt.created_by,
     mmt.transaction_set_id,
     l_expenditure_type,
     l_expenditure_org,
     1,
     --
     -- OPM INVCONV: umoogala  11-Jul-2006
     -- Bug 5349860: Process/Discrete Internal Order Xfer to Exp Destination
     -- Added transfer_price and opm_costed_flag
     --
     l_transfer_price,
     DECODE(l_logicalorg_process_org, 'Y', 'N', NULL), -- opm_costed_flag
     MMT.SHIPMENT_NUMBER -- Bug 6411640
     FROM
            mtl_material_transactions mmt,
	    fnd_currencies curr  -- Bug 5349860: OPM INVCONV: umoogala  11-Jul-2006
     WHERE  mmt.transaction_id    = p_transaction_id
       AND  curr.currency_code(+) = mmt.currency_code;

   x_return_status := g_ret_sts_success;
   IF (l_debug = 1) THEN
      print_debug('create_exp_req_rcpt_trx: AFter mmt insert', 9);
   END IF;

EXCEPTION
   WHEN no_data_found THEN
	x_return_status := G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('create_exp_req_rcpt_trx: no_data_found error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
   WHEN OTHERS THEN
	x_return_status := G_RET_STS_UNEXP_ERROR;

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'create_logical_exp_req_rcpt_trx');
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data => x_msg_data);
          IF (l_debug = 1) THEN
             print_debug('create_exp_req_rcpt_trx: others error', 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE), 9);
          END IF;
END create_exp_req_rcpt_trx;

  -----------------------------------------------------------------------------



/*==========================================================================*
 | Procedure : CREATE_LOGICAL_TRX_WRAPPER                                   |
 |                                                                          |
 | Description : This API is a wrapper that would be called from TM to      |
 |               create logical transactions. This API has the input        |
 |               parameter of transaction id of the inserted SO issue MMT   |
 |               record, check if the selling OU is not the same as the     |
 |               shipping OU, the transaction flow exists and new           |
 |               transaction flow is checked, then it creates a record of   |
 |               mtl_trx_rec_type and table of mtl_trx_tbl_type and then    |
 |               calls the create_logical_transactions. This API is mainly  |
 |               called from the INV java TM.                               |
 |                                                                          |
 | Input Parameters :                                                       |
 |   p_api_version_number - API version number                              |
 |   p_init_msg_lst       - Whether initialize the error message list or not|
 |                          Should be fnd_api.g_false or fnd_api.g_true     |
 |   p_transaction_id     - transaction id of the inserted SO issue MMT     |
 |                          record.                                         |
 |   p_transaction_temp_id - mmtt transaction temp id, only will be passed  |
 |  from the inventory transaction manager for internal order intransit     |
 |  issue transactions, where the destination type is EXPENSE            |
 | Output Parameters :                                                      |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded         |
 |                          fnd_api.g_ret_sts_exc_error, if an expected     |
 |                          error occurred                                  |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected |
 |                          eror occurred                                   |
 |   x_msg_count          - Number of error message in the error message    |
 |                          list                                            |
 |   x_msg_data           - If the number of error message in the error     |
 |                          message list is one, the error message is in    |
 |                          this output parameter                           |
 *==========================================================================*/
  PROCEDURE create_logical_trx_wrapper(
          x_return_status       OUT NOCOPY  VARCHAR2
        , x_msg_count           OUT NOCOPY  NUMBER
        , x_msg_data            OUT NOCOPY  VARCHAR2
        , p_api_version_number  IN          NUMBER   := 1.0
        , p_init_msg_lst        IN          VARCHAR2 := G_FALSE
        , p_transaction_id      IN          NUMBER
        , p_transaction_temp_id IN          NUMBER   := NULL
				       )
  IS
     l_api_version_number CONSTANT NUMBER := 1.0;
     l_in_api_version_number NUMBER := NVL(p_api_version_number, 1.0);
     l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_LOGICAL_TRX_WRAPPER';
     l_init_msg_lst VARCHAR2(1) := NVL(p_init_msg_lst, G_FALSE);
     l_progress NUMBER;
     l_mtl_trx_tbl INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_tbl_type;
     l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.number_tbl;
     l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.number_tbl;
     l_selling_OU NUMBER;
     l_shipping_OU NUMBER;
     l_ship_from_org_id NUMBER;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);
     l_header_id NUMBER;
     l_transaction_date DATE;
     l_new_accounting_flag VARCHAR2(1) := 'N';
     l_transaction_flow_exists VARCHAR2(1) := INV_TRANSACTION_FLOW_PUB.G_TRANSACTION_FLOW_NOT_FOUND;
     l_organization_id NUMBER;
     l_item_id NUMBER;
     l_transaction_source_type_id NUMBER;
     l_transaction_action_id NUMBER;
     l_logical_trx_type_code NUMBER;
     l_defer_logical_trx NUMBER;
     l_defer_logical_trx_flag NUMBER;
  BEGIN
     IF (l_debug = 1) THEN
        print_debug('Enter create_logical_trx_wrapper', 9);
        print_debug('p_api_version_number = ' || p_api_version_number, 9);
        print_debug('l_in_api_version_number = ' || l_in_api_version_number, 9);
        print_debug('p_init_msg_lst = ' || p_init_msg_lst, 9);
        print_debug('l_init_msg_lst = ' || l_init_msg_lst, 9);
        print_debug('p_transaction_id = ' || p_transaction_id, 9);
	print_debug('p_transaction_temp_id = ' || p_transaction_temp_id, 9);
     END IF;

     --  Standard call to check for call compatibility
     IF NOT fnd_api.compatible_api_call(l_api_version_number,
                l_in_api_version_number, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     --  Initialize message list.
     IF fnd_api.to_boolean(l_init_msg_lst) THEN
        fnd_msg_pub.initialize;
     END IF;


     -- Determine if it's sales order shipment transaction or Logical PO receipt transaction
     -- If it's logical PO receipt transaction, then receiving should already check the
     -- transaction flow exists and get the transaction flow header_id, therefore we don't
     -- need to check transaction flow for logical PO receipt
     SELECT transaction_source_type_id, transaction_action_id
       INTO   l_transaction_source_type_id, l_transaction_action_id
       FROM   mtl_material_transactions
       WHERE  transaction_id = p_transaction_id;

     IF (l_debug = 1) THEN
        print_debug('transaction_source_type_id = ' || l_transaction_source_type_id, 9);
        print_debug('transaction_action_id = ' || l_transaction_action_id, 9);
     END IF;

     --Internal Order Intransit Issue Transaction. Need to create a
     --costing record if the destination is EXPENSE
     IF ((l_transaction_source_type_id = g_sourcetype_intorder)
	 AND (l_transaction_action_id =  g_action_issue)
	 AND (p_transaction_temp_id IS NOT NULL))THEN

	create_exp_req_rcpt_trx(x_return_status =>l_return_status,
				x_msg_data => l_msg_data,
				p_transaction_id => p_transaction_id,
				p_transaction_temp_id => p_transaction_temp_id);
	IF (l_debug = 1) THEN
           print_debug('AFter calling create_exp_req_rcpt_trx', 9);
        END IF;

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           IF (l_debug = 1) THEN
              print_debug('create_exp_req_rcpt_trx returns error', 9);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
	 ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           IF (l_debug = 1) THEN
              print_debug('create_exp_req_rcpt_trx returns unexpected error', 9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (l_debug = 1) THEN
           print_debug('create_exp_req_rcpt_trx returns success', 9);
        END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

     ELSE

	IF ((l_transaction_source_type_id = G_SOURCETYPE_SALESORDER and
	     l_transaction_action_id = G_ACTION_ISSUE) or
	    (l_transaction_source_type_id = G_SOURCETYPE_RMA and
	     (l_transaction_action_id = G_ACTION_RECEIPT
	      OR l_transaction_action_id = G_ACTION_ISSUE))) THEN

	   IF (l_debug = 1) THEN
	      print_debug('This is sales order issue/ RMA', 9);
	   END IF;

	   -- Get the selling OU and shipping OU of the sales order issue transaction
           BEGIN
              l_progress := 10;
              IF (l_debug = 1) THEN
                 print_debug('Getting the selling OU and shipping OU of the SO issue', 9);
              END IF;

              SELECT oola.org_id,
         	     to_number(hoi.org_information3),
         	     oola.ship_from_org_id,
         	     mmt.organization_id,
         	     mmt.inventory_item_id,
         	     mmt.transaction_date
      	      INTO   l_selling_OU,
         	     l_shipping_OU,
         	     l_ship_from_org_id,
         	     l_organization_id,
         	     l_item_id,
         	     l_transaction_date
	      FROM   hr_organization_information hoi,
         	     oe_order_lines_all          oola,
         	     mtl_material_transactions   mmt
	      WHERE  mmt.transaction_id = p_transaction_id
         	     AND    mmt.trx_source_line_id = oola.line_id
         	     AND    oola.ship_from_org_id = hoi.organization_id
         	     AND    hoi.org_information_context = 'Accounting Information';

              l_progress := 20;

              IF (l_debug = 1) THEN
                 print_debug('create_logical_trx_wrapper: Selling OU = ' || l_selling_OU
	   		     || ' Shipping OU = ' || l_shipping_OU
			     || ' ship_from_org_id = ' || l_ship_from_org_id, 9);
              END IF;
           EXCEPTION
              WHEN no_data_found THEN
	           IF (l_debug = 1) THEN
		      print_debug('Cannot find the selling and shipping OU of the sales order', 9);
	           END IF;
	           FND_MESSAGE.SET_NAME('INV', 'INV_NO_OU');
	           FND_MSG_PUB.ADD;
	           RAISE FND_API.G_EXC_ERROR;
           END;

           -- check if the selling OU is not the same as the shipping OU, the
           -- transaction flow exists and new transaction flow is checked, then
           -- creates table of mtl_trx_tbl_type
           -- and then calls the create_logical_transactions.
           IF (l_selling_OU <> l_shipping_OU) THEN
              l_progress := 30;
              IF (l_debug = 1) THEN
                 print_debug('selling OU <> shipping OU', 9);
                 print_debug('Getting category_id', 9);
              END IF;

              -- get if there is any Category id of the item with the category set id = 1(Inventory)
              BEGIN
                 SELECT category_id
   		 INTO   l_qualifier_value_tbl(1)
		 FROM   mtl_item_categories
		 WHERE  category_set_id = 1
		 AND    organization_id = l_organization_id
		 AND    inventory_item_id = l_item_id;

                 IF (l_qualifier_value_tbl(1) IS NOT NULL) THEN
                    IF (l_debug = 1) THEN
                       print_debug('l_qualifier_value_tbl(1) = ' || l_qualifier_value_tbl(1), 9);
                    END IF;
                    l_qualifier_code_tbl(1) := 1;
                 END IF;
              EXCEPTION
                 WHEN no_data_found THEN
	  	      IF (l_debug = 1) THEN
		         print_debug('no category_id is found for the item id = ' || l_item_id, 9);
		      END IF;
              END;

              IF (l_debug = 1) THEN
                 print_debug('Calling INV_TRANSACTION_FLOW_PUB.check_transaction_flow', 9);
                 print_debug('l_shipping_OU = ' || l_shipping_OU, 9);
                 print_debug('l_selling_OU = ' || l_selling_OU, 9);
                 print_debug('flow_type = ' || G_SHIPPING, 9);
                 print_debug('organization_id = ' || l_ship_from_org_id, 9);
                 IF (l_qualifier_code_tbl.COUNT > 0) THEN
                    print_debug('l_qualifier_code_tbl(1) = ' || l_qualifier_code_tbl(1), 9);
                 END IF;

                 IF (l_qualifier_code_tbl.COUNT > 0) THEN
                    print_debug('l_qualifier_value_tbl(1) = ' || l_qualifier_value_tbl(1), 9);
                 END IF;
              END IF;

              INV_TRANSACTION_FLOW_PUB.check_transaction_flow(
		    p_api_version             => 1.0
	          , p_init_msg_list           => fnd_api.g_false
		  , p_start_operating_unit    => l_shipping_OU
		  , p_end_operating_unit      => l_selling_OU
		  , p_flow_type               => G_SHIPPING
		  , p_organization_id         => l_ship_from_org_id
		  , p_qualifier_code_tbl      => l_qualifier_code_tbl
		  , p_qualifier_value_tbl     => l_qualifier_value_tbl
		  , p_transaction_date        => l_transaction_date
		  , x_return_status           => l_return_status
		  , x_msg_count               => l_msg_count
		  , x_msg_data                => l_msg_data
		  , x_header_id               => l_header_id
		  , x_new_accounting_flag     => l_new_accounting_flag
		  , x_transaction_flow_exists => l_transaction_flow_exists);

              l_progress := 40;
              IF (l_debug = 1) THEN
                 print_debug('Output from the API: l_header_id = ' || l_header_id, 9);
                 print_debug('l_new_accounting_flag = ' || l_new_accounting_flag, 9);
                 print_debug('l_transaction_flow_exists = ' || l_transaction_flow_exists, 9);
              END IF;

              IF (l_return_status = G_RET_STS_ERROR) THEN
                 IF (l_debug = 1) THEN
                    print_debug('Check trx flow returns error: ' || l_msg_data, 9);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
	      ELSIF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 IF (l_debug = 1) THEN
                    print_debug('Check trx flow returns unexpected error: ' || l_msg_data, 9);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              IF (l_debug = 1) THEN
                 print_debug('Check trx flow returns success', 9);
              END IF;

              l_logical_trx_type_code := G_LOGTRXCODE_RMASOISSUE;
              l_defer_logical_trx := G_DEFER_LOGICAL_TRX_ORG_LEVEL;
	   ELSE -- selling OU = shipping OU, no logical transactions
	      IF (l_debug = 1) THEN
		 print_debug('l_selling_OU = l_shipping_OU, do not create logical transactions', 9);
	      END IF;
	      --deferred cogs change
	      --since selling ou is the same as shipping ou
	      -- update the physical sales order with so_issue_acct_type as
	      -- 2 deferred cogs
	      BEGIN
		 UPDATE mtl_material_transactions
		   SET so_issue_account_type =2
		   WHERE transaction_id = p_transaction_id;
	      EXCEPTION
		 WHEN no_data_found THEN
		    IF (l_debug = 1) THEN
		       print_debug('No MMT found while updating so_issue_acct_type' || p_transaction_id, 9);
		       x_return_status:= FND_API.g_ret_sts_error;
		    END IF;
	      END;
	      x_return_status := FND_API.G_RET_STS_SUCCESS;
	      return;
           END IF; -- end of (l_selling_OU <> l_shipping_OU)
           l_progress := 50;
	   --Bug 5103108: Added this condition so that other transaction
	   -- source types doesnt get into the default logic
	 ELSIF (l_transaction_source_type_id =
		inv_globals.G_SOURCETYPE_PURCHASEORDER AND
		(l_transaction_action_id = G_ACTION_LOGICALRECEIPT OR
		 l_transaction_action_id = G_ACTION_LOGICALDELADJ)) THEN
		    -- it's a Logical PO receipt
	   IF (l_debug = 1) THEN
	      print_debug('This is logical PO receipt', 9);
	   END IF;

	   l_logical_trx_type_code := G_LOGTRXCODE_DSDELIVER;
	   l_transaction_flow_exists := INV_TRANSACTION_FLOW_PUB.G_TRANSACTION_FLOW_FOUND;
	   l_new_accounting_flag := 'Y';
	   l_defer_logical_trx := G_NOT_DEFER_LOGICAL_TRX;
	END IF; -- end of transaction source type is sales order issue/RMA

        IF (l_transaction_flow_exists = INV_TRANSACTION_FLOW_PUB.G_TRANSACTION_FLOW_FOUND
	    AND l_new_accounting_flag = 'Y') THEN
	   l_progress := 60;
           BEGIN

	      --The check for the installation of Costing J and OM J will
	      -- be done here if the new accoutning flag is set to Yes.
	      --

		-- check the patchset level of Costing and OM, returns error
		-- if they are not in patchset J
		IF (l_debug = 1) THEN
		   print_debug('Costing Current Release Level = ' || CST_VersionCtrl_GRP.Get_Current_Release_Level, 9);
		   print_debug('Costing J Release Level = ' || CST_Release_GRP.G_J_Release_Level, 9);
		   print_debug('OM Current Release Level = ' || OE_CODE_CONTROL.Get_Code_Release_Level, 9);
		END IF;

		--do as before
		IF (CST_VersionCtrl_GRP.Get_Current_Release_Level < CST_Release_GRP.G_J_Release_Level) THEN
		   IF (l_debug = 1) THEN
		      print_debug('Costing Release Level < Costing J Release Level', 9);
		   END IF;
		   FND_MESSAGE.SET_NAME('INV', 'INV_CST_JRELEASE');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		 ELSIF (OE_CODE_CONTROL.Get_Code_Release_Level < '110510') THEN
		   IF (l_debug = 1) THEN
		      print_debug('OM Release Level < 110510', 9);
		   END IF;
		   FND_MESSAGE.SET_NAME('INV', 'INV_OM_JRELEASE');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		IF (l_debug = 1) THEN
		   print_debug('l_transaction_flow_exists=1 AND l_new_accounting_flag=Y', 9);
		   print_debug('before construct the transaction pl/sql table', 9);
		END IF;
		-- construct the pl/sql table
		SELECT TRANSACTION_ID,
   	             ORGANIZATION_ID,
	             INVENTORY_ITEM_ID,
	             REVISION,
	             SUBINVENTORY_CODE,
	             LOCATOR_ID,
	             TRANSACTION_TYPE_ID,
        	     TRANSACTION_ACTION_ID,
        	     TRANSACTION_SOURCE_TYPE_ID,
        	     TRANSACTION_SOURCE_ID,
        	     TRANSACTION_SOURCE_NAME,
        	     TRANSACTION_QUANTITY,
        	     TRANSACTION_UOM,
        	     PRIMARY_QUANTITY,
        	     TRANSACTION_DATE,
        	     ACCT_PERIOD_ID,
        	     DISTRIBUTION_ACCOUNT_ID,
        	     COSTED_FLAG,
        	     ACTUAL_COST,
        	     INVOICED_FLAG,
        	     TRANSACTION_COST,
        	     CURRENCY_CODE,
        	     CURRENCY_CONVERSION_RATE,
        	     CURRENCY_CONVERSION_TYPE,
        	     CURRENCY_CONVERSION_DATE,
        	     PM_COST_COLLECTED,
        	     TRX_SOURCE_LINE_ID,
        	     SOURCE_CODE,
        	     RCV_TRANSACTION_ID,
        	     SOURCE_LINE_ID,
        	     TRANSFER_ORGANIZATION_ID,
        	     TRANSFER_SUBINVENTORY,
        	     TRANSFER_LOCATOR_ID,
        	     COST_GROUP_ID,
        	     TRANSFER_COST_GROUP_ID,
        	     PROJECT_ID,
        	     TASK_ID,
        	     TO_PROJECT_ID,
        	     TO_TASK_ID,
        	     SHIP_TO_LOCATION_ID,
        	     TRANSACTION_MODE,
        	     TRANSACTION_BATCH_ID,
        	     TRANSACTION_BATCH_SEQ,
        	     TRX_FLOW_HEADER_ID,
        	     INTERCOMPANY_COST,
        	     INTERCOMPANY_CURRENCY_CODE,
        	     INTERCOMPANY_PRICING_OPTION,
        	     LPN_ID,
		     PARENT_TRANSACTION_ID,
		     LOGICAL_TRANSACTIONS_CREATED
  	      INTO   l_mtl_trx_tbl(1).TRANSACTION_ID,
        	     l_mtl_trx_tbl(1).ORGANIZATION_ID,
        	     l_mtl_trx_tbl(1).INVENTORY_ITEM_ID,
        	     l_mtl_trx_tbl(1).REVISION,
        	     l_mtl_trx_tbl(1).SUBINVENTORY_CODE,
        	     l_mtl_trx_tbl(1).LOCATOR_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_TYPE_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_ACTION_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_SOURCE_TYPE_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_SOURCE_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_SOURCE_NAME,
        	     l_mtl_trx_tbl(1).TRANSACTION_QUANTITY,
        	     l_mtl_trx_tbl(1).TRANSACTION_UOM,
        	     l_mtl_trx_tbl(1).PRIMARY_QUANTITY,
        	     l_mtl_trx_tbl(1).TRANSACTION_DATE,
        	     l_mtl_trx_tbl(1).ACCT_PERIOD_ID,
        	     l_mtl_trx_tbl(1).DISTRIBUTION_ACCOUNT_ID,
        	     l_mtl_trx_tbl(1).COSTED_FLAG,
        	     l_mtl_trx_tbl(1).ACTUAL_COST,
        	     l_mtl_trx_tbl(1).INVOICED_FLAG,
        	     l_mtl_trx_tbl(1).TRANSACTION_COST,
        	     l_mtl_trx_tbl(1).CURRENCY_CODE,
        	     l_mtl_trx_tbl(1).CURRENCY_CONVERSION_RATE,
        	     l_mtl_trx_tbl(1).CURRENCY_CONVERSION_TYPE,
        	     l_mtl_trx_tbl(1).CURRENCY_CONVERSION_DATE,
        	     l_mtl_trx_tbl(1).PM_COST_COLLECTED,
        	     l_mtl_trx_tbl(1).TRX_SOURCE_LINE_ID,
        	     l_mtl_trx_tbl(1).SOURCE_CODE,
        	     l_mtl_trx_tbl(1).RCV_TRANSACTION_ID,
        	     l_mtl_trx_tbl(1).SOURCE_LINE_ID,
        	     l_mtl_trx_tbl(1).TRANSFER_ORGANIZATION_ID,
        	     l_mtl_trx_tbl(1).TRANSFER_SUBINVENTORY,
        	     l_mtl_trx_tbl(1).TRANSFER_LOCATOR_ID,
        	     l_mtl_trx_tbl(1).COST_GROUP_ID,
        	     l_mtl_trx_tbl(1).TRANSFER_COST_GROUP_ID,
        	     l_mtl_trx_tbl(1).PROJECT_ID,
        	     l_mtl_trx_tbl(1).TASK_ID,
        	     l_mtl_trx_tbl(1).TO_PROJECT_ID,
        	     l_mtl_trx_tbl(1).TO_TASK_ID,
        	     l_mtl_trx_tbl(1).SHIP_TO_LOCATION_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_MODE,
        	     l_mtl_trx_tbl(1).TRANSACTION_BATCH_ID,
        	     l_mtl_trx_tbl(1).TRANSACTION_BATCH_SEQ,
        	     l_mtl_trx_tbl(1).TRX_FLOW_HEADER_ID,
        	     l_mtl_trx_tbl(1).INTERCOMPANY_COST,
        	     l_mtl_trx_tbl(1).INTERCOMPANY_CURRENCY_CODE,
        	     l_mtl_trx_tbl(1).INTERCOMPANY_PRICING_OPTION,
        	     l_mtl_trx_tbl(1).LPN_ID,
		     l_mtl_trx_tbl(1).parent_transaction_id,
		     l_defer_logical_trx_flag
 	      FROM   mtl_material_transactions
	      WHERE  transaction_id = p_transaction_id;

              IF (l_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
                 l_mtl_trx_tbl(1).trx_flow_header_id := l_header_id;
              END IF;

              l_progress := 70;
              IF (l_debug = 1) THEN
                 print_debug('after construct the pl/sql table with transaction_id = '
                             || p_transaction_id, 9);
              END IF;
           EXCEPTION
              WHEN no_data_found THEN
	           IF (l_debug = 1) THEN
		      print_debug('Error when creating logical trx table', 9);
	           END IF;
	           FND_MESSAGE.SET_NAME('INV', 'INV_LOG_TRX_REC_ERROR');
	           FND_MSG_PUB.ADD;
	           RAISE FND_API.G_EXC_ERROR ;
           END;

	   --bug fix - the defer flag should be set only if it is being
	   -- called by the concurrent program which will set the value of
	   -- the flag to N before calling the wrapper. Other cases,
	   -- it will get either the org. default or for PO will be set to No.
	   IF (l_defer_logical_trx_flag = 1) THEN
	      l_defer_logical_trx := G_NOT_DEFER_LOGICAL_TRX;
	   END IF;


           l_progress := 80;
           IF (l_debug = 1) THEN
              print_debug('Before calling create_logical_transactions', 9);
           END IF;

           create_logical_transactions(
		 x_return_status               => l_return_status
	       , x_msg_count                   => l_msg_count
	       , x_msg_data                    => l_msg_data
	       , p_api_version_number          => 1.0
	       , p_init_msg_lst                => G_FALSE
	       , p_mtl_trx_tbl                 => l_mtl_trx_tbl
	       , p_validation_flag             => G_TRUE
	       , p_trx_flow_header_id          => l_mtl_trx_tbl(1).trx_flow_header_id
	       , p_defer_logical_transactions  => l_defer_logical_trx
	       , p_logical_trx_type_code       => l_logical_trx_type_code
	       , p_exploded_flag               => G_NOT_EXPLODED);

           l_progress := 90;
           IF (l_debug = 1) THEN
              print_debug('AFter calling create_logical_transactions', 9);
           END IF;

           IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
              IF (l_debug = 1) THEN
                 print_debug('create_logical_transactions returns error', 9);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
	   ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              IF (l_debug = 1) THEN
                 print_debug('create_logical_transactions returns unexpected error', 9);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           IF (l_debug = 1) THEN
              print_debug('create_logical_transactions returns success', 9);
           END IF;
	   --deferred cogs change
	   --when old acct than stamp cogs for multiple OU's.
           UPDATE mtl_material_transactions
	     SET   so_issue_account_type = 2--defcogs
           WHERE  transaction_id = p_transaction_id;
           IF (SQL%ROWCOUNT = 0) THEN
              IF (l_debug = 1) THEN
                 print_debug('No MMT record is found for defcogsupdate with trx id:'
			     || p_transaction_id ,9);
              END IF;
              FND_MESSAGE.SET_NAME('INV', 'INV_MMT_NOT_FOUND');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
	 ELSIF (l_transaction_flow_exists = INV_TRANSACTION_FLOW_PUB.G_TRANSACTION_FLOW_FOUND
               AND l_new_accounting_flag = 'N') THEN
           IF (l_debug = 1) THEN
              print_debug('updating MMT record trx_id ' || p_transaction_id ||
                          ' with trx_flow_header_id = ' || l_header_id, 9);
           END IF;
	   --deferred cogs change
	   --when old acct than stamp cogs for multiple OU's.
           UPDATE mtl_material_transactions
	     SET    trx_flow_header_id = l_header_id,
	            so_issue_account_type = 1--cogs
           WHERE  transaction_id = p_transaction_id;
           IF (SQL%ROWCOUNT = 0) THEN
              IF (l_debug = 1) THEN
                 print_debug('No MMT record is found for update with trx id:'
                               || p_transaction_id ,9);
              END IF;
              FND_MESSAGE.SET_NAME('INV', 'INV_MMT_NOT_FOUND');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

	END IF;--end of (l_transaction_flow_exists = 1 AND l_new_accounting_flag = 'Y')
	x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;--End condition for 'if' internal order int shipment trx.
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
	IF (l_debug = 1) THEN
	   print_debug('create_logical_trx_wrapper error exception, l_progress = '
		       || l_progress, 9);
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	IF (l_debug = 1) THEN
	   print_debug('create_logical_trx_wrapper unexpected error exception,l_progress = ' || l_progress, 9);
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
	IF (l_debug = 1) THEN
	   print_debug('create_logical_trx_wrapper other exception, l_progress = '  || l_progress || ' ' || substr(sqlerrm, 1, 100), 9);
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	   FND_MSG_PUB.Add_Exc_Msg
	     (G_PKG_NAME, 'INV_LOGICAL_TRANSACTIONS_PUB');
	END IF;
  END create_logical_trx_wrapper;

/*==================================================================================*
 | Procedure : CREATE_LOGICAL_TRANSACTIONS                                          |
 |                                                                                  |
 | Description : The create_logical_transactions API will be a public API that will |
 |               be called from within Oracle Inventory and other modules that would|
 |               like to insert records into mtl_material_transactions table as part|
 |               part of a logical shipment or a logical receipt transaction or a   |
 |               retroactive price change transaction.                              |
 |               The following transactions may trigger such as insert:             |
 |               1. Sales order issue transaction tied to a transaction flow        |
 |                  spanning across multiple operating units.                       |
 |               2. Global procurement transaction tied to a transaction flow       |
 |                  across multiple operating units.                                |
 |               3. Drop ship transaction from a supplier/vendor to a customer      |
 |                  spanning across multiple operating units and tied to a          |
 |                  transaction flow. The drop shipments can also be a combination  |
 |                  of the global procurement and a shipment flow depending on the  |
 |                  receiving operating unit.                                       |
 |               4. Retroactive price update that has a consumption advice already  |
 |                  created.                                                        |
 |               5. In-transit receipt transaction with an expense destination.     |
 |               6. All return transactions such as return to vendor, RMAs or PO    |
 |                  corrections spanning multiple operating units.                  |
 |                                                                                  |
 | Input Parameters:                                                                |
 |   p_api_version_number    - API version number                                   |
 |   p_init_msg_lst          - Whether initialize the error message list or not     |
 |                             Should be fnd_api.g_false or fnd_api.g_true          |
 |   p_mtl_trx_tbl           - An array of mtl_trx_rec_type records, the definition |
 |                             is in the INV_LOGICAL_TRANSACTION_GLOBAL package.    |
 |   p_validation_flag       - To indicate whether the call to this API is a trusted|
 |                             call or not. Depending on this flag, we will decide  |
 |                             whether to validate the parameters passed.           |
 |                             Default will be 'TRUE'                               |
 |   p_trx_flow_header_id    - The header id of the transaction flow that is being  |
 |                             used. This parameter would be null for retroactive   |
 |                             price update transactions.                           |
 |   p_defer_logical_transactions - The flag indicates whether to defer the         |
 |                             creation of logical transactions or not. The         |
 |                             following are the values:                            |
 |                             1 - YES. This would indicate that the creation of    |
 |                                 logical transactions would be deferred.          |
 |                             2 - No. This would indicate that the creation of     |
 |                                 logical transactions would not be deferred.      |
 |                             3 - Use the flag set at the Org level. mtl_parameters|
 |                                 will hold the default value for a specific       |
 |                                 organization.                                    |
 |                                 Default would be set to 3 - use the flag set at  |
 |                                 the organization level.                          |
 |   p_logical_trx_type_code - Indentify the type of transaction being processed.   |
 |                             The following are the values:                        |
 |                             1 - Indicates a Drop Ship transaction.               |
 |                             2 - Indicates sales order shipment spanning multiple |
 |                                 operating units/RMA return transaction flow      |
 |                                 across multiple nodes.                           |
 |                             3 - Indicates Global Procurement/Return to Vendor    |
 |                             4 - Retroactive Price Update.                        |
 |                             Null - Transactions that does not belong to any of   |
 |                                    the type mentioned above.                     |
 |                                                                                  |
 |   p_exploded_flag         - This will indicate whether the table of records that |
 |                             is being passed to this API has already been exploded|
 |                             or not. Exploded means that all the logical          |
 |                             transactions for all the intermediate nodes have been|
 |                             created and this API would just perform a bulk insert|
 |                             into MMT. Otherwise, this API has to create all the  |
 |                             logical transactions. Default value will be 2 (No).  |
 |                             The following are the values this can take:          |
 |                             1 - YES. This would indicate that the calling API has|
 |                                 already exploded all the nodes and all this API  |
 |                                 has to do is to insert the logical transactions  |
 |                                 into MMT.                                        |
 |                             2 - No. This would indicate that the calling API has |
 |                                 not done the creation of the logical transactions|
 |                                 and this API would have to explode the           |
 |                                 intermediate nodes.                              |
 | Output Parameters:                                                               |
 |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded                 |
 |                          fnd_api.g_ret_sts_exc_error, if an expected error       |
 |                          occurred                                                |
 |                          fnd_api.g_ret_sts_unexp_error, if an unexpected error   |
 |                          occurred                                                |
 |   x_msg_count          - Number of error message in the error message list       |
 |   x_msg_data           - If the number of error message in the error message     |
 |                          message list is one, the error message is in            |
 |                          this output parameter                                   |
 *==================================================================================*/
  PROCEDURE create_logical_transactions(
            x_return_status              OUT NOCOPY  VARCHAR2
          , x_msg_count                  OUT NOCOPY  NUMBER
          , x_msg_data                   OUT NOCOPY  VARCHAR2
          , p_api_version_number         IN          NUMBER   := 1.0
          , p_init_msg_lst               IN          VARCHAR2 := G_FALSE
          , p_mtl_trx_tbl                IN          inv_logical_transaction_global.mtl_trx_tbl_type
          , p_validation_flag            IN          VARCHAR2 := G_TRUE
          , p_trx_flow_header_id         IN          NUMBER
          , p_defer_logical_transactions IN          NUMBER := G_DEFER_LOGICAL_TRX_ORG_LEVEL
          , p_logical_trx_type_code      IN          NUMBER := NULL
          , p_exploded_flag              IN          NUMBER := G_NOT_EXPLODED
  )
  IS
     l_api_version_number CONSTANT NUMBER := 1.0;
     l_in_api_version_number NUMBER := NVL(p_api_version_number, 1.0);
     l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_LOGICAL_TRANSACTIONS';
     l_init_msg_lst VARCHAR2(1) := NVL(p_init_msg_lst, G_FALSE);
     l_progress NUMBER;

     l_mtl_trx_tbl INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_tbl_type;
     l_mtl_trx_tbl_temp INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_tbl_type;
     l_defer_logical_trx NUMBER := p_defer_logical_transactions;
     l_project_id NUMBER;
     l_user_id NUMBER := fnd_global.user_id;
     l_row_id VARCHAR2(10) := NULL;
     l_transaction_batch_id NUMBER;
     l_parent_transaction_id NUMBER;
     l_start_org_id NUMBER;
     l_rec_start_org_id NUMBER;
     l_transaction_uom VARCHAR2(3);
     l_selling_OU NUMBER;
     l_shipping_OU NUMBER;
     l_ship_from_org_id NUMBER;
     l_new_accounting_flag VARCHAR2(1) := 'N';
     l_index NUMBER;
     l_trx_flow_tbl INV_TRANSACTION_FLOW_PUB.g_transaction_flow_tbl_type;
     l_transfer_price_tbl mtl_transfer_price_tbl_type;
     l_qualifier_code_tbl INV_TRANSACTION_FLOW_PUB.number_tbl;
     l_qualifier_value_tbl INV_TRANSACTION_FLOW_PUB.number_tbl;
     l_trx_id NUMBER;
     l_is_return NUMBER := 0; -- values: 0 - No, 1 - Yes
     l_dsreceive BOOLEAN;
     l_drop_ship_flag VARCHAR2(1) := 'N';
     l_inv_asset_flag VARCHAR2(1);
     l_lot_control_code NUMBER;
     l_serial_control_code NUMBER;
     l_order_source VARCHAR2(40) := fnd_profile.value('ONT_SOURCE_CODE');
     l_oe_header_id NUMBER;
     l_oe_order_type_id NUMBER;
     l_oe_order_type_name VARCHAR2(80);
     l_ic_to_inv_organization_id NUMBER;
     l_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);
     --Bug#8620411
     l_uom_rate NUMBER := 1;
     l_primary_uom VARCHAR2(4);
     -- Bug 4411804: Removing direct updates to WLPN
     l_lpn WMS_CONTAINER_PUB.lpn;
     --
     -- Bug: -  umoogala   13-Feb-2006
     -- No bug is logged. But fixing as part of bug 5008080.
     -- Do NOT insert into MTL_CST_TXN_COST_DETAILS table for
     -- process mfg organizations.
     --
     l_prev_organization_id  BINARY_INTEGER := NULL;
     l_process_enabled_flag  VARCHAR2(1)    := NULL;
  BEGIN
     SAVEPOINT create_logical_transactions;

     IF (l_debug = 1) THEN
        print_debug('Enter create_logical_transactions', 9);
        print_debug('p_api_version_number = ' || p_api_version_number, 9);
        print_debug('l_in_api_version_number = ' || l_in_api_version_number, 9);
        print_debug('p_init_msg_lst = ' || p_init_msg_lst, 9);
        print_debug('l_init_msg_lst = ' || l_init_msg_lst, 9);
        print_debug('p_validation_flag = ' || p_validation_flag, 9);
        print_debug('p_trx_flow_header_id = ' || p_trx_flow_header_id, 9);
        print_debug('p_defer_logical_transactions = ' || p_defer_logical_transactions, 9);
        print_debug('p_logical_trx_type_code = ' || p_logical_trx_type_code, 9);
        print_debug('p_exploded_flag = ' || p_exploded_flag, 9);
     END IF;

     --  Standard call to check for call compatibility
     IF NOT fnd_api.compatible_api_call(l_api_version_number,
                l_in_api_version_number, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     --  Initialize message list.
     IF fnd_api.to_boolean(l_init_msg_lst) THEN
        fnd_msg_pub.initialize;
     END IF;


     l_progress := 10;
     -- If the defer accounting trx is 3 (at org level)
     -- get the defer logical transactions flag from mtl_parameters
     IF (l_defer_logical_trx = G_DEFER_LOGICAL_TRX_ORG_LEVEL) THEN
        BEGIN
           IF (l_debug = 1) THEN
              print_debug('l_defer_logical_trx = 3', 9);
              print_debug('get defer_logical_transactions from org ' ||
                          p_mtl_trx_tbl(1).organization_id, 9);
           END IF;
           l_progress := 20;
           SELECT defer_logical_transactions
           INTO   l_defer_logical_trx
           FROM   mtl_parameters
           WHERE  organization_id = p_mtl_trx_tbl(1).organization_id;

           l_progress := 30;
           IF (l_debug = 1) THEN
              print_debug('defer_logical_transactions is: ' || l_defer_logical_trx, 9);
           END IF;
        EXCEPTION
           WHEN no_data_found THEN
                IF (l_debug = 1) THEN
                   print_debug('Cannot get defer logical trx flag from mtl_parameters', 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV', 'INV_DEFER_LOGICAL_ERR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END;
     END IF;

     IF (l_debug = 1) THEN
        print_debug('The p_logical_trx_type_code is : ' || p_logical_trx_type_code, 9);
     END IF;

     l_mtl_trx_tbl := p_mtl_trx_tbl;

     -- ***** Starts populating logical transaction records of the pl/sql table *****
     IF (p_logical_trx_type_code = G_LOGTRXCODE_RETROPRICEUPD) THEN
        l_progress := 40;
        -- Retroactive price update
        IF (l_debug = 1) THEN
           print_debug('Trx type is Retroactive price update', 9);
           print_debug('Start constructing pl/sql table for retroactive price update', 9);
        END IF;

        -- Populate account period id to the record if it's null
        FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
          IF (l_mtl_trx_tbl(i).acct_period_id IS NULL) THEN
             l_progress := 50;
             get_acct_period(x_return_status    => l_return_status
                           , x_msg_count        => l_msg_count
                           , x_msg_data         => l_msg_data
                           , x_acct_period_id   => l_mtl_trx_tbl(i).acct_period_id
                           , p_organization_id  => l_mtl_trx_tbl(i).organization_id
                           , p_transaction_date => l_mtl_trx_tbl(i).transaction_date);
             IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                IF (l_debug = 1) THEN
                   print_debug('get_acct_period returns error with org id = '
                                || l_mtl_trx_tbl(i).organization_id, 9);
                   print_debug('x_msg_data = ' || x_msg_data, 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV', 'INV_PERIOD_RETRIEVAL_ERROR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

          -- get the project if the locator is populated and tied to project
          IF (l_mtl_trx_tbl(i).project_id IS NULL AND l_mtl_trx_tbl(i).locator_id > 0) THEN
             l_progress := 60;
             BEGIN
                IF (l_debug = 1) THEN
                   print_debug('getting the project id and task id', 9);
                END IF;
                SELECT project_id, task_id
                INTO   l_mtl_trx_tbl(i).project_id,
                       l_mtl_trx_tbl(i).task_id
                FROM   mtl_item_locations
                WHERE  organization_id = l_mtl_trx_tbl(i).organization_id
                and    inventory_location_id = l_mtl_trx_tbl(i).locator_id;
                IF (l_debug = 1) THEN
                   print_debug('The project id = ' || l_mtl_trx_tbl(i).project_id ||
                               ' and the task id = ' || l_mtl_trx_tbl(i).task_id, 9);
                END IF;
             EXCEPTION
                WHEN no_data_found THEN
                     l_mtl_trx_tbl(i).project_id := NULL;
                     l_mtl_trx_tbl(i).task_id := NULL;
                     IF (l_debug = 1) THEN
                        print_debug('No project id is found', 9);
                     END IF;
             END;
          END IF;

          -- Get default cost group if no project id, else get cost group of the project
          IF (l_mtl_trx_tbl(i).project_id IS NULL) THEN
             l_progress := 70;
             get_default_costgroup(
                           x_return_status   => l_return_status
                         , x_msg_count       => l_msg_count
                         , x_msg_data        => l_msg_data
                         , x_cost_group_id   => l_mtl_trx_tbl(i).cost_group_id
                         , p_organization_id => l_mtl_trx_tbl(i).organization_id);
          ELSE
             l_progress := 80;
             get_project_costgroup(
                           x_return_status   => l_return_status
                         , x_msg_count       => l_msg_count
                         , x_msg_data        => l_msg_data
                         , x_cost_group_id   => l_mtl_trx_tbl(i).cost_group_id
                         , p_project_id      => l_mtl_trx_tbl(i).project_id
                         , p_organization_id => l_mtl_trx_tbl(i).organization_id);
          END IF;

          IF (l_return_status <> G_RET_STS_SUCCESS) THEN
             IF (l_debug = 1) THEN
                print_debug('get_default_costgroup returns error', 9);
                print_debug('l_msg_data = ' || l_msg_data, 9);
             END IF;
             FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_mtl_trx_tbl(i).costed_flag := 'N';
          l_mtl_trx_tbl(i).invoiced_flag := null;

          -- populate the transaction id to the record
          SELECT mtl_material_transactions_s.nextval
          INTO   l_mtl_trx_tbl(i).transaction_id
          FROM   DUAL;

          l_mtl_trx_tbl(i).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;
          l_mtl_trx_tbl(i).transaction_batch_seq := i;

        END LOOP;

        IF (l_debug = 1) THEN
           print_debug('End of constructing pl/sql table for retroactive price update', 9);
        END IF;
     elsif (p_logical_trx_type_code = G_LOGTRXCODE_GLOBPROCRTV OR
                  p_logical_trx_type_code = G_LOGTRXCODE_DSRECEIPT) THEN
        -- global procurement/Return to vendor, or True dropship with logical PO receipt
        l_progress := 90;
        IF (l_debug = 1) THEN
           print_debug('Trx Type: Global procurement/Return to vendor or DS receipt', 9);
           print_debug('Start constructing pl/sql table for GLOB PROC/RTV or DS recipet', 9);
        END IF;

        -- Return error if the input table is not exploded
        IF (p_exploded_flag = G_NOT_EXPLODED) THEN
           IF (l_debug = 1) THEN
              print_debug('Records are not exploded', 9);
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_REC_NOT_EXPLODED');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (l_debug = 1) THEN
           print_debug('Get the start OU from the transaction flow header', 9);
        END IF;

        -- get the start OU from the transaction flow header
        -- this is used for later when we get the cost_group_id
        l_progress := 100;
        SELECT start_org_id
        INTO   l_start_org_id
        FROM   mtl_transaction_flow_headers
        WHERE  header_id = p_trx_flow_header_id;

        l_progress := 110;
        IF (l_debug = 1) THEN
           print_debug('The start OU from the transaction flow header = ' || l_start_org_id, 9);
        END IF;

        IF (l_defer_logical_trx = G_NOT_DEFER_LOGICAL_TRX) THEN -- not defer
           FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
              l_progress := 120;
              -- populate transaction id
              SELECT mtl_material_transactions_s.nextval
              INTO   l_mtl_trx_tbl(i).transaction_id
              FROM   dual;

              l_progress := 130;

              -- If the record is parent transaction, populate transaction id to the
              -- parent transaction id and transaction batch id
              IF (l_mtl_trx_tbl(i).parent_transaction_flag = 1) THEN
                 l_mtl_trx_tbl(i).parent_transaction_id := l_mtl_trx_tbl(i).transaction_id;
                 l_mtl_trx_tbl(i).transaction_batch_id := l_mtl_trx_tbl(i).transaction_id;
                 l_parent_transaction_id := l_mtl_trx_tbl(i).parent_transaction_id;
                 l_transaction_batch_id  := l_mtl_trx_tbl(i).transaction_batch_id;
              END IF;

              -- Populate account period id to the record if it's null
              IF (l_mtl_trx_tbl(i).acct_period_id IS NULL) THEN
                 l_progress := 140;
                 get_acct_period(x_return_status    => l_return_status
                               , x_msg_count        => l_msg_count
                               , x_msg_data         => l_msg_data
                               , x_acct_period_id   => l_mtl_trx_tbl(i).acct_period_id
                               , p_organization_id  => l_mtl_trx_tbl(i).organization_id
                               , p_transaction_date => l_mtl_trx_tbl(i).transaction_date);
                 IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_acct_period returns error with org id = '
                                    || l_mtl_trx_tbl(1).organization_id, 9);
                       print_debug('x_msg_data = ' || x_msg_data, 9);
                    END IF;
                    FND_MESSAGE.SET_NAME('INV', 'INV_PERIOD_RETRIEVAL_ERROR');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
              END IF;

              -- Populate cost group id to the record
              -- If it's the first node and project id is populated, get the cost
              -- group of project and task, else if it's the first node and no project
              -- tied to it or if it's the intermediate nodes with project or not, get
              -- the default cost group of the organization level
              l_progress := 150;
              IF (l_mtl_trx_tbl(i).cost_group_id IS NULL) THEN
                 SELECT to_number(org_information3)
                 INTO   l_rec_start_org_id
                 FROM   hr_organization_information
                 WHERE  organization_id = l_mtl_trx_tbl(i).organization_id
                 AND    org_information_context = 'Accounting Information';

                 -- For the first node, check if there's project tied to the locator
                 IF (l_start_org_id = l_rec_start_org_id) THEN --It's the first node
                    -- get the project if the locator is populated and tied to project
                    IF (l_mtl_trx_tbl(i).project_id IS NULL AND l_mtl_trx_tbl(i).locator_id>0) THEN
                       BEGIN
                          l_progress := 160;
                          SELECT project_id, task_id
                          INTO   l_mtl_trx_tbl(i).project_id,
                                 l_mtl_trx_tbl(i).task_id
                          FROM   mtl_item_locations
                          WHERE  organization_id = l_mtl_trx_tbl(1).organization_id
                          and    inventory_location_id = l_mtl_trx_tbl(1).locator_id;
                       EXCEPTION
                          WHEN no_data_found THEN
                               l_mtl_trx_tbl(i).project_id := NULL;
                               IF (l_debug = 1) THEN
                                  print_debug('No project id is found', 9);
                               END IF;
                       END;
                    END IF;
                 END IF;

                 IF ((l_start_org_id = l_rec_start_org_id AND l_mtl_trx_tbl(i).project_id is null)
                     OR (l_start_org_id <> l_rec_start_org_id)) THEN
                     l_progress := 170;
                     get_default_costgroup(
                            x_return_status   => l_return_status
                          , x_msg_count       => l_msg_count
                          , x_msg_data        => l_msg_data
                          , x_cost_group_id   => l_mtl_trx_tbl(i).cost_group_id
                          , p_organization_id => l_mtl_trx_tbl(i).organization_id);
                 ELSE
                     l_progress := 180;
                     get_project_costgroup(
                            x_return_status   => l_return_status
                          , x_msg_count       => l_msg_count
                          , x_msg_data        => l_msg_data
                          , x_cost_group_id   => l_mtl_trx_tbl(i).cost_group_id
                          , p_project_id      => l_mtl_trx_tbl(i).project_id
                          , p_organization_id => l_mtl_trx_tbl(i).organization_id);
                 END IF;

                 IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_default_costgroup returns error', 9);
                       print_debug('l_msg_data = ' || l_msg_data, 9);
                    END IF;
                    FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;
              END IF;

              IF (l_mtl_trx_tbl(i).transfer_cost_group_id is null) THEN
                 IF (l_mtl_trx_tbl(i).transaction_action_id IN (G_ACTION_LOGICALICSALES,
                     G_ACTION_LOGICALICRECEIPT, G_ACTION_LOGICALICSALESRETURN,
                     G_ACTION_LOGICALICRCPTRETURN)) THEN
                     get_default_costgroup(
                            x_return_status   => l_return_status
                          , x_msg_count       => l_msg_count
                          , x_msg_data        => l_msg_data
                          , x_cost_group_id   => l_mtl_trx_tbl(i).transfer_cost_group_id
                          , p_organization_id => l_mtl_trx_tbl(i).transfer_organization_id);

                     IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                        IF (l_debug = 1) THEN
                           print_debug('get_default_costgroup returns error', 9);
                           print_debug('l_msg_data = ' || l_msg_data, 9);
                        END IF;
                        FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;
                 END IF;
              END IF;
           END LOOP;

           -- populate the parent_transaction_id, transaction_batch_id and
           -- transaction_batch_seq to every records of the table
           FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
             l_mtl_trx_tbl(i).parent_transaction_id := l_parent_transaction_id;
             l_mtl_trx_tbl(i).transaction_batch_id := l_transaction_batch_id;
             l_mtl_trx_tbl(i).transaction_batch_seq := i;
           END LOOP;

           IF (l_debug = 1) THEN
              print_debug('End constructing pl/sql table for global proc/Return to vendor', 9);
           END IF;
        ELSE -- else of if (l_defer_logical_trx = G_NOT_DEFER_LOGICAL_TRX)
           IF (l_debug = 1) THEN
              print_debug('Cannot defer creating logical trx for global proc/return to vendor', 9);
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('INV', 'INV_CANNOT_DEFER_LOGICAL_TRX');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF; -- end of if (l_defer_logical_trx = G_NOT_DEFER_LOGICAL_TRX)
     -- true dropship(shipping flow)/SO issue across OUs/RMA return
     ELSIF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER
                  or p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
        -- IF true drop ship(shipping flow) and Yes defer flag, return error
        IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER
                  and l_defer_logical_trx = G_DEFER_LOGICAL_TRX) THEN
           IF (l_debug = 1) THEN
              print_debug('Cannot defer creating logical trx for true dropship', 9);
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('INV', 'INV_CANNOT_DEFER_LOGICAL_TRX');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE
                    and l_defer_logical_trx = G_DEFER_LOGICAL_TRX) THEN
           -- If sales order issue/RMA and yes defer flag, update the MMT record

           IF (l_debug = 1) THEN
              print_debug('Defer creating logical trx for SO issue/RMA', 9);
              print_debug('Update MMT with transaction_id = ' || p_mtl_trx_tbl(1).transaction_id, 9);
	      print_debug('Update MMT with header_id = ' || p_trx_flow_header_id, 9);
           END IF;
	   -- Bug:3426281. Have to update the MMT record with the header id
           l_progress := 190;
           UPDATE mtl_material_transactions
	     SET    logical_transactions_created = 2,
	     invoiced_flag = NULL,
	     trx_flow_header_id = p_trx_flow_header_id
	     WHERE  transaction_id = p_mtl_trx_tbl(1).transaction_id;
           IF (SQL%ROWCOUNT = 0) THEN
              IF (l_debug = 1) THEN
                 print_debug('No MMT record is found to update with logical_transactions_created=N', 9);
              END IF;
              FND_MESSAGE.SET_NAME('INV', 'INV_MMT_NOT_FOUND');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           return;
        END IF;

        -- set the return flag to check if the transaction is RMA later
        IF (l_mtl_trx_tbl(1).transaction_source_type_id = G_SOURCETYPE_RMA and
            (l_mtl_trx_tbl(1).transaction_action_id = G_ACTION_RECEIPT
              OR l_mtl_trx_tbl(1).transaction_action_id = G_ACTION_ISSUE)) THEN
            l_is_return := 1;
        END IF;

        -- get the shipping OU and selling OU and ship from org id for get_transaction_flow api
        l_progress := 200;
        BEGIN
           SELECT start_org_id,
                  end_org_id,
                  new_accounting_flag
           into   l_selling_OU,
                  l_shipping_OU,
                  l_new_accounting_flag
           FROM   mtl_transaction_flow_headers
           WHERE  header_id = p_trx_flow_header_id;

           l_progress := 210;
           IF (l_debug = 1) THEN
              print_debug('Selling OU: ' || l_selling_OU || ' Shipping OU: ' || l_shipping_OU, 9);
           END IF;
        EXCEPTION
           WHEN no_data_found THEN
                IF (l_debug = 1) THEN
                   print_debug('Transaction flow not defined for header_id = ' || p_trx_flow_header_id, 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV', 'INV_NO_TRX_FLOW');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END;

        -- For dropship deliver, get the sales order id and populate to transaction_source_id
        -- Also get the lot_control_code and serial_control_code of the item.
        IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
           IF (l_debug = 1) THEN
               print_debug('DSDELIVER: rcv_transaction_id = ' || l_mtl_trx_tbl(1).rcv_transaction_id, 9);
           END IF;

           BEGIN
              l_progress := 220;
              SELECT MAX(odss.line_id), odss.header_id
              INTO  l_mtl_trx_tbl(1).trx_source_line_id, l_oe_header_id
              FROM  oe_drop_ship_sources odss, rcv_transactions rt
              WHERE rt.transaction_id = l_mtl_trx_tbl(1).rcv_transaction_id
              AND   rt.po_line_location_id = odss.line_location_id
              GROUP BY odss.header_id;

              IF (l_debug = 1) THEN
                 print_debug('DSDELIVER: trx_source_line_id = ' || l_mtl_trx_tbl(1).trx_source_line_id, 9);
                 print_debug('DSDELIVER: l_oe_header_id = ' || l_oe_header_id, 9);
              END IF;

              l_progress := 230;
              SELECT oeh.order_type_id, oet.name
              INTO   l_oe_order_type_id, l_oe_order_type_name
              FROM   oe_order_headers_all oeh, oe_transaction_types_tl oet
              WHERE  oeh.header_id = l_oe_header_id
              AND    oeh.order_type_id = oet.transaction_type_id
              AND    oet.language = (Select language_code from fnd_languages where installed_flag = 'B');

              IF (l_debug = 1) THEN
                 print_debug('DSDELIVER: l_oe_order_type_id = ' || l_oe_order_type_id, 9);
                 print_debug('DSDELIVER: l_oe_order_type_name = ' || l_oe_order_type_name, 9);
              END IF;

              /* bug 4155079, added to_char to oeh.order_number */

              l_progress := 240;
              SELECT mso.sales_order_id
              INTO   l_mtl_trx_tbl(1).transaction_source_id
              FROM   oe_order_headers_all oeh, mtl_sales_orders mso
              WHERE  to_char(oeh.order_number) = mso.segment1
              AND    mso.segment2 = l_oe_order_type_name
              AND    mso.segment3 = l_order_source
              AND    oeh.header_id = l_oe_header_id;

              IF (l_debug = 1) THEN
                 print_debug('DSDELIVER: transaction_source_id = ' || l_mtl_trx_tbl(1).transaction_source_id, 9);
              END IF;
/******
	      SELECT MAX(odss.line_id),
                     mso.sales_order_id
              INTO   l_mtl_trx_tbl(1).trx_source_line_id,
                     l_mtl_trx_tbl(1).transaction_source_id
              FROM   oe_drop_ship_sources odss,
                     rcv_transactions rt,
                     mtl_sales_orders mso,
                     oe_order_headers_all ooha
              WHERE  rt.transaction_id = l_mtl_trx_tbl(1).rcv_transaction_id
              AND    odss.line_location_id = rt.po_line_location_id
              AND    odss.header_id = ooha.header_id
              AND    ooha.order_number = mso.segment1
	      GROUP BY mso.sales_order_id;
******/
/*****
	      SELECT mso.sales_order_id
              INTO   l_mtl_trx_tbl(1).transaction_source_id
              FROM   mtl_sales_orders mso,
                     oe_order_headers_all ooha,
                     oe_order_lines_all oola
              WHERE  oola.line_id = l_mtl_trx_tbl(1).trx_source_line_id
              AND    oola.header_id = ooha.header_id
	      AND    ooha.order_number = mso.segment1;
*****/

           EXCEPTION
              WHEN no_data_found THEN
                   IF (l_debug = 1) THEN
                      print_debug('no sales order found for line id = ' || l_mtl_trx_tbl(1).trx_source_line_id, 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV', 'INV_NO_SO');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;

              WHEN others THEN
                   IF (l_debug = 1) THEN
                      print_debug('when others ' || sqlerrm, 9);
                      print_Debug('l_progress = ' || l_progress, 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV', 'INV_NO_SO');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
           END;

	   IF (l_debug = 1) THEN
	      print_debug('sales order id = ' ||
			  l_mtl_trx_tbl(1).transaction_source_id, 9);
	      print_debug('line id = ' ||
			  l_mtl_trx_tbl(1).trx_source_line_id, 9);
	   END IF;

           SELECT lot_control_code, serial_number_control_code
           INTO   l_lot_control_code, l_serial_control_code
           FROM   mtl_system_items
           WHERE  organization_id = l_mtl_trx_tbl(1).organization_id
           AND    inventory_item_id = l_mtl_trx_tbl(1).inventory_item_id;

           IF (l_debug = 1) THEN
              print_debug('l_lot_control_code = ' || l_lot_control_code, 9);
              print_debug('l_serial_control_code = ' || l_serial_control_code, 9);
           END IF;
        END IF;

        -- for true dropship of shipping flow, if there is only single OU, which means
        -- shipping OU = selling OU, and there is transaction flow define and the new
        -- accounting flag is Y, we still have to create a logical sales order issue
        -- rather than a physical shipment
        -- else for multiple OUs, create a table of logical transaction records
        IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER
             AND l_selling_OU = l_shipping_OU AND l_new_accounting_flag = 'Y') THEN
           IF (l_debug = 1) THEN
              print_debug('Drop shipment deliver and selling OU is the same as shipping OU', 9);
              print_debug('Transaction flow exists and new accounting flag=Y', 9);
              print_debug('Constructing the pl/sql table for DS deliver single OU', 9);
           END IF;

           -- update the input(first) record of the pl/sql table
           -- get the project if the locator is populated and tied to project
/*
           IF (l_mtl_trx_tbl(1).project_id IS NULL AND l_mtl_trx_tbl(1).locator_id > 0) THEN
              l_progress := 220;
              BEGIN
                 SELECT project_id, task_id
                 INTO   l_mtl_trx_tbl(1).project_id,
                        l_mtl_trx_tbl(1).task_id
                 FROM   mtl_item_locations
                 WHERE  organization_id = l_mtl_trx_tbl(1).organization_id
                 and    inventory_location_id = l_mtl_trx_tbl(1).locator_id;
                 l_progress := 230;
              EXCEPTION
                 WHEN no_data_found THEN
                      l_mtl_trx_tbl(1).project_id := NULL;
                      IF (l_debug = 1) THEN
                         print_debug('No project id is found', 9);
                      END IF;
              END;
           END IF;

           -- Get the cost group: default cost group if no project id,
           -- else cost group of the project
           IF (l_mtl_trx_tbl(1).project_id IS NULL) THEN
              l_progress := 240;
              get_default_costgroup(
                         x_return_status   => l_return_status
                       , x_msg_count       => l_msg_count
                       , x_msg_data        => l_msg_data
                       , x_cost_group_id   => l_mtl_trx_tbl(1).cost_group_id
                       , p_organization_id => l_mtl_trx_tbl(1).organization_id);

           ELSE
              l_progress := 250;
              get_project_costgroup(
                         x_return_status   => l_return_status
                       , x_msg_count       => l_msg_count
                       , x_msg_data        => l_msg_data
                       , x_cost_group_id   => l_mtl_trx_tbl(1).cost_group_id
                       , p_project_id      => l_mtl_trx_tbl(1).project_id
                       , p_organization_id => l_mtl_trx_tbl(1).organization_id);
           END IF;

           IF (l_return_status <> G_RET_STS_SUCCESS) THEN
              IF (l_debug = 1) THEN
                 print_debug('get_default_costgroup returns error', 9);
                 print_debug('l_msg_data = ' || l_msg_data, 9);
              END IF;
              FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           IF (l_mtl_trx_tbl(1).acct_period_id IS NULL) THEN
              l_progress := 260;
              get_acct_period(x_return_status    => l_return_status
                          , x_msg_count        => l_msg_count
                          , x_msg_data         => l_msg_data
                          , x_acct_period_id   => l_mtl_trx_tbl(1).acct_period_id
                          , p_organization_id  => l_mtl_trx_tbl(1).organization_id
                          , p_transaction_date => l_mtl_trx_tbl(1).transaction_date);
              IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                 IF (l_debug = 1) THEN
                    print_debug('get_acct_period returns error with org id = '
                                 || l_mtl_trx_tbl(1).organization_id, 9);
                    print_debug('x_msg_data = ' || x_msg_data, 9);
                 END IF;
                 FND_MESSAGE.SET_NAME('INV', 'INV_PERIOD_RETRIEVAL_ERROR');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;

           l_mtl_trx_tbl(1).costed_flag := 'N';
           l_mtl_trx_tbl(1).invoiced_flag := null;
           l_mtl_trx_tbl(1).parent_transaction_flag := 1;

           l_progress := 270;
           SELECT mtl_material_transactions_s.nextval
           INTO   l_mtl_trx_tbl(1).transaction_id
           FROM   dual;

           l_mtl_trx_tbl(1).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;
           l_mtl_trx_tbl(1).transaction_batch_seq := 1;
           -- end of updating the input(first) record of the pl/sql table

           -- construct a logical sales order issue record of to_org_id
           l_index := l_mtl_trx_tbl.COUNT + 1;
           IF (l_debug = 1) THEN
              print_debug('l_index = ' || l_index, 9);
           END IF;

           l_mtl_trx_tbl(l_index) := l_mtl_trx_tbl(1);
*/
           l_mtl_trx_tbl(1).transaction_type_id := G_TYPE_LOGL_SALES_ORDER_ISSUE;
           l_mtl_trx_tbl(1).transaction_action_id := G_ACTION_LOGICALISSUE;
           l_mtl_trx_tbl(1).transaction_source_type_id := G_SOURCETYPE_SALESORDER;
           l_mtl_trx_tbl(1).transaction_date := NVL(p_mtl_trx_tbl(1).transaction_date,sysdate);
           l_mtl_trx_tbl(1).transaction_quantity := -1*p_mtl_trx_tbl(1).transaction_quantity;
           l_mtl_trx_tbl(1).primary_quantity := -1*p_mtl_trx_tbl(1).primary_quantity;
           l_mtl_trx_tbl(1).pm_cost_collected := null;
           IF (l_mtl_trx_tbl(1).project_id is null) THEN
              l_mtl_trx_tbl(1).cost_group_id := p_mtl_trx_tbl(1).cost_group_id;
           ELSE
              l_progress := 280;
              get_default_costgroup(
                     x_return_status   => l_return_status
                   , x_msg_count       => l_msg_count
                   , x_msg_data        => l_msg_data
                   , x_cost_group_id   => l_mtl_trx_tbl(1).cost_group_id
                   , p_organization_id => l_mtl_trx_tbl(1).organization_id);

              IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                 IF (l_debug = 1) THEN
                    print_debug('get_default_costgroup returns error', 9);
                    print_debug('l_msg_data = ' || l_msg_data, 9);
                 END IF;
                 FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF;

           l_mtl_trx_tbl(1).currency_code := null;
           l_mtl_trx_tbl(1).parent_transaction_flag := 2;

           l_progress := 290;

	   -- Bug: 4607049.
           -- Added SQL to get the value of TO_ORGANIZATION_ID from the IC Transaction Flow Lines.
           -- Pass this TO_ORGANIZATION_ID to get_cogs_acct_for_logical_so()
           BEGIN
              SELECT to_organization_id
                INTO l_ic_to_inv_organization_id
                FROM mtl_transaction_flow_lines
               WHERE header_id = l_mtl_trx_tbl(1).trx_flow_header_id;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 NULL;
           END;

           get_cogs_acct_for_logical_so(
                        x_return_status => l_return_status
                      , x_msg_count     => l_msg_count
                      , x_msg_data      => l_msg_data
                      , x_cogs_acct_id  => l_mtl_trx_tbl(1).distribution_account_id
                      , p_inventory_item_id => l_mtl_trx_tbl(1).inventory_item_id
                      , p_order_line_id     => l_mtl_trx_tbl(1).trx_source_line_id
		      , p_ic_to_inv_organization_id => l_ic_to_inv_organization_id);
           IF (l_return_status <> G_RET_STS_SUCCESS) THEN
              IF (l_debug = 1) THEN
                 print_debug('get_cogs_acct_for_logical_so returns error', 9);
                 print_debug('l_msg_data = ' || l_msg_data, 9);
              END IF;
              FND_MESSAGE.SET_NAME('INV', 'INV_NO_COGS_FOR_LOG_SO');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
           END IF;

           l_progress := 300;
           SELECT mtl_material_transactions_s.nextval
           INTO   l_mtl_trx_tbl(1).transaction_id
           FROM   dual;

           l_mtl_trx_tbl(1).parent_transaction_id := p_mtl_trx_tbl(1).transaction_id;
           l_mtl_trx_tbl(1).transaction_batch_id := p_mtl_trx_tbl(1).transaction_id;
           l_mtl_trx_tbl(1).transaction_batch_seq := 1;

           print_debug('End of constructing the pl/sql table for DS deliver single OU', 9);
        -- end of DSDELIVER and single OU
        ELSE -- (p_logical_trx_type_code=G_LOGTRXCODE_DSDELIVER
             -- and shipping_ou<>selling_ou) or SO issue/RMA return
           l_progress := 310;
           IF (l_debug = 1) THEN
              print_debug('Drop shipment deliver across multiple OUS or SO issue/RMA', 9);
              print_debug('Calling INV_TRANSACTION_FLOW_PUB.get_transaction_flow', 9);
           END IF;

           l_progress := 320;

           INV_TRANSACTION_FLOW_PUB.get_transaction_flow(
                 x_return_status          => l_return_status
               , x_msg_data               => l_msg_data
               , x_msg_count              => l_msg_count
               , x_transaction_flows_tbl  => l_trx_flow_tbl
               , p_api_version            => 1.0
               , p_init_msg_list          => fnd_api.g_false
               , p_header_id              => p_trx_flow_header_id
               , p_get_default_cost_group => 'Y');

           IF (l_debug = 1) THEN
              print_debug('get_transaction_flow returns status = ' || l_return_status, 9);
              print_debug('Transaction flow counts = ' || l_trx_flow_tbl.COUNT, 9);
           END IF;

           IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
              IF (l_debug = 1) THEN
                 print_debug('get_transaction_flow returns error: ' || l_msg_data, 9);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              IF (l_debug = 1) THEN
                 print_debug('get_transaction_flow returns unexpected error: ' || l_msg_data, 9);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           -- If there is transaction flow, then get the the transfer price
           -- and construct a pl/sql transfer price table
           IF (l_trx_flow_tbl.COUNT > 0) THEN
              -- For true dropship (shipping flow), since there is no mmt record inserted
              -- before calling the get transfer price, should pass the so line id
              -- and 'D' to p_global_procurement_flag to get_transfer_price api
              -- else for SO shipment, pass the inserted mmt transaction_id of the
              -- physical SO issue record and 'N' to the p_global_procurement_flag
              IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
                 l_trx_id := l_mtl_trx_tbl(1).trx_source_line_id;
                 l_drop_ship_flag := 'Y';
              ELSE
                 l_trx_id := l_mtl_trx_tbl(1).transaction_id;
                 l_drop_ship_flag := 'N';
              END IF;

              l_trx_flow_tbl(1).from_organization_id := l_mtl_trx_tbl(1).organization_id;

              IF (l_debug = 1) THEN
                 print_debug('Calling INV_TRANSACTION_FLOW_PUB.get_transfer_price', 9);
              END IF;

              -- start construct transfer price pl/sql table
              FOR i in 1..l_trx_flow_tbl.COUNT LOOP
                 IF (l_debug = 1) THEN
                    print_debug('index of l_trx_flow_tbl = ' || i, 9);
                    print_debug('from_org_id = ' || l_trx_flow_tbl(i).from_org_id, 9);
                    print_debug('to_org_id = ' || l_trx_flow_tbl(i).to_org_id, 9);
                    print_debug('from_organization_id = ' || l_trx_flow_tbl(i).from_organization_id, 9);
                    print_debug('transaction_uom = ' || l_mtl_trx_tbl(1).transaction_uom, 9);
                    print_debug('inventory_item_id = ' || l_mtl_trx_tbl(1).inventory_item_id, 9);
                    print_debug('l_trx_id = ' || l_trx_id, 9);
                    print_debug('l_drop_ship_flag = ' || l_drop_ship_flag, 9);
                 END IF;

                 l_transfer_price_tbl(i).from_org_id := l_trx_flow_tbl(i).from_org_id;
                 l_transfer_price_tbl(i).to_org_id := l_trx_flow_tbl(i).to_org_id;
                 l_progress := 330;
                 INV_TRANSACTION_FLOW_PUB.get_transfer_price(
                       x_return_status  => l_return_status
                     , x_msg_data       => l_msg_data
                     , x_msg_count      => l_msg_count
                     , x_transfer_price => l_transfer_price_tbl(i).transfer_price
                     , x_currency_code  => l_transfer_price_tbl(i).functional_currency_code
                     , x_incr_transfer_price => l_transfer_price_tbl(i).incr_transfer_price
                     , x_incr_currency_code  => l_transfer_price_tbl(i).incr_currency_code
                     , p_api_version    => 1.0
                     , p_init_msg_list  => fnd_api.g_false
                     , p_from_org_id    => l_transfer_price_tbl(i).from_org_id
                     , p_to_org_id      => l_transfer_price_tbl(i).to_org_id
                     , p_transaction_uom   => l_mtl_trx_tbl(1).transaction_uom
                     , p_inventory_item_id => l_mtl_trx_tbl(1).inventory_item_id
                     , p_transaction_id    => l_trx_id
                     , p_from_organization_id => l_trx_flow_tbl(i).from_organization_id
                     , p_global_procurement_flag => 'N'
                     , p_drop_ship_flag    => l_drop_ship_flag);

                 IF (l_debug = 1) THEN
                    print_debug('get_transfer_price returns status = ' || l_return_status, 9);
                 END IF;

                 IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_transfer_price returns error: ' || l_msg_data, 9);
                    END IF;
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_transfer_price returns unexpected error: ' || l_msg_data, 9);
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
              END LOOP;

              IF (l_debug = 1) THEN
                 print_debug('Transfer price pl/sql table count = ' || l_transfer_price_tbl.COUNT, 9);
                 FOR i in 1..l_transfer_price_tbl.COUNT LOOP
                    print_debug('from_org_id=' || l_transfer_price_tbl(i).from_org_id ||
                         ' to_org_id=' || l_transfer_price_tbl(i).to_org_id ||
                         ' transfer_price=' || l_transfer_price_tbl(i).transfer_price ||
                         ' func_curr_code=' || l_transfer_price_tbl(i).functional_currency_code ||
                         ' incr_transfer_price=' || l_transfer_price_tbl(i).incr_transfer_price ||
                         ' incr_currency_code=' || l_transfer_price_tbl(i).incr_currency_code, 9);
                 END LOOP;
              END IF;
           END IF;

           -- check if the item is inventory asset item or expense item, to decide
           -- which account should be used to populate the distribution account id
           -- for intercompany receipt record
           -- If it is inventory asset item, then use the inventory accrual account id
           -- else if it is expense item, use the expense accrual account id
           -- inventory_asset_flag = Y or N
           BEGIN
              l_progress := 340;
              SELECT inventory_asset_flag
              INTO   l_inv_asset_flag
              FROM   mtl_system_items
              WHERE  organization_id = l_mtl_trx_tbl(1).organization_id
              AND    inventory_item_id = l_mtl_trx_tbl(1).inventory_item_id;
           EXCEPTION
              WHEN no_data_found THEN
                   IF (l_debug = 1) THEN
                      print_debug('No item is found for item id: '
                                   || l_mtl_trx_tbl(1).inventory_item_id, 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV', 'INV_NO_ITEM_FOUND');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
           END;

           -- loop for each record of transaction flow table and construct the logical
           -- transaction table
           l_index := l_mtl_trx_tbl.COUNT;
           FOR i in 1..l_trx_flow_tbl.COUNT LOOP
              l_index := l_index + 1;

              IF (l_trx_flow_tbl(i).start_org_id = l_trx_flow_tbl(i).from_org_id) THEN
                 -- this is first node to intermediate node
                 -- create a logical I/C sales issue of from_org_id and
                 -- a logical I/C receipt of to_org_id
                 -- OR a logical I/C sales return into from_org_id for RMA and
                 -- a logical I/C receipt return of the to_org_id

                 -- start to construct the logical I/C sales issue of from_org_id
                 -- or logical I/C sales return into from_org_id
                 IF (l_debug = 1) THEN
                    print_debug('First node', 9);
                    print_debug('Construct the logical I/C sales issue/return of from_org_id', 9);
                    print_debug('l_index for l_mtl_trx_tbl = ' || l_index, 9);
                 END IF;

                 l_mtl_trx_tbl(l_index).organization_id := l_mtl_trx_tbl(1).organization_id;
                 l_mtl_trx_tbl(l_index).transfer_organization_id := l_trx_flow_tbl(i).to_organization_id;
                 l_mtl_trx_tbl(l_index).subinventory_code := l_mtl_trx_tbl(1).subinventory_code;
                 l_mtl_trx_tbl(l_index).locator_id := l_mtl_trx_tbl(1).locator_id;
                 l_mtl_trx_tbl(l_index).project_id := l_mtl_trx_tbl(1).project_id;
                 l_mtl_trx_tbl(l_index).task_id := l_mtl_trx_tbl(1).task_id;
                 l_mtl_trx_tbl(l_index).transfer_cost_group_id := l_trx_flow_tbl(i).to_org_cost_group_id;
                 l_mtl_trx_tbl(l_index).intercompany_cost := l_transfer_price_tbl(i).incr_transfer_price;
                 l_mtl_trx_tbl(l_index).intercompany_currency_code := l_transfer_price_tbl(i).incr_currency_code;
                 l_mtl_trx_tbl(l_index).currency_code := l_transfer_price_tbl(i).functional_currency_code;
                 l_mtl_trx_tbl(l_index).invoiced_flag := 'N';
                 l_mtl_trx_tbl(l_index).pm_cost_collected := null;
                 l_mtl_trx_tbl(l_index).transaction_date := NVL(l_mtl_trx_tbl(1).transaction_date,sysdate);
                 l_mtl_trx_tbl(l_index).acct_period_id := l_mtl_trx_tbl(l_index-1).acct_period_id;
                 l_mtl_trx_tbl(l_index).distribution_account_id :=
		   l_trx_flow_tbl(i).INTERCOMPANY_COGS_ACCOUNT_ID;
		 l_mtl_trx_tbl(l_index).trx_source_line_id :=
		   l_mtl_trx_tbl(1).trx_source_line_id;
		 l_mtl_trx_tbl(l_index).transaction_source_id :=
		   l_mtl_trx_tbl(1).transaction_source_id;
		 IF (l_debug = 1) THEN
		    print_debug('******transaction_source_id: ******' ||
				l_mtl_trx_tbl(l_index).transaction_source_id);
		     print_debug('******index: ******' ||l_index);

		 END IF;

                 IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
                    -- SO issue/RMA
                    l_mtl_trx_tbl(l_index).transaction_quantity := l_mtl_trx_tbl(1).transaction_quantity;
                    l_mtl_trx_tbl(l_index).primary_quantity := l_mtl_trx_tbl(1).primary_quantity;
                    l_mtl_trx_tbl(l_index).transaction_cost := null;
                    l_mtl_trx_tbl(l_index).cost_group_id := l_mtl_trx_tbl(1).cost_group_id;
                    l_mtl_trx_tbl(l_index).parent_transaction_id := l_mtl_trx_tbl(1).transaction_id;
                    l_mtl_trx_tbl(l_index).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;

                    IF (l_is_return = 1) THEN
                       l_mtl_trx_tbl(l_index).pm_cost_collected := null;
                    END IF;
                 ELSIF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
                    -- true trop ship
                    l_mtl_trx_tbl(l_index).transaction_quantity := -1*l_mtl_trx_tbl(1).transaction_quantity;
                    l_mtl_trx_tbl(l_index).primary_quantity := -1*l_mtl_trx_tbl(1).primary_quantity;
                    l_mtl_trx_tbl(l_index).transaction_cost := l_mtl_trx_tbl(1).transaction_cost;
                    l_mtl_trx_tbl(l_index).cost_group_id := l_mtl_trx_tbl(1).cost_group_id;
                 END IF;

                 IF (l_is_return = 0) THEN -- construct logical I/C sales issue
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_SALES_ISSUE;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICSALES;
                 ELSE -- it's RMA, construct logical I/C sales return
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_SALES_RETURN;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICSALESRETURN;
                 END IF;
                 -- end of construct the logical I/C sales issue of from_org_id
                 -- or logical I/C sales return into from_rog_id

                 -- start to construct the logical I/C receipt of the to_org_id
                 l_index := l_index + 1;
                 IF (l_debug = 1) THEN
                    print_debug('First node', 9);
                    print_debug('Construct the logical I/C receipt/sales return of from_org_id', 9);
                    print_debug('l_index for l_mtl_trx_tbl = ' || l_index, 9);
                 END IF;

                 l_mtl_trx_tbl(l_index).organization_id := l_trx_flow_tbl(i).to_organization_id;
                 l_mtl_trx_tbl(l_index).transfer_organization_id := l_trx_flow_tbl(i).from_organization_id;
                 l_mtl_trx_tbl(l_index).transaction_date := NVL(l_mtl_trx_tbl(1).transaction_date,sysdate);
                 l_progress := 350;
                 get_acct_period(
                            x_return_status    => l_return_status
                          , x_msg_count        => l_msg_count
                          , x_msg_data         => l_msg_data
                          , x_acct_period_id   => l_mtl_trx_tbl(l_index).acct_period_id
                          , p_organization_id  => l_mtl_trx_tbl(l_index).organization_id
                          , p_transaction_date => l_mtl_trx_tbl(l_index).transaction_date);
                 IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_acct_period returns error with org id = '
                                      || l_mtl_trx_tbl(1).organization_id, 9);
                       print_debug('x_msg_data = ' || x_msg_data, 9);
                    END IF;
                    FND_MESSAGE.SET_NAME('INV', 'INV_PERIOD_RETRIEVAL_ERROR');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 IF (l_inv_asset_flag = 'Y') THEN
                    l_mtl_trx_tbl(l_index).distribution_account_id := l_trx_flow_tbl(i).INVENTORY_ACCRUAL_ACCOUNT_ID;
                 ELSE
                    l_mtl_trx_tbl(l_index).distribution_account_id := l_trx_flow_tbl(i).EXPENSE_ACCRUAL_ACCOUNT_ID;
                 END IF;

                 IF (l_debug = 1) THEN
                    print_debug('Calling INV_TRANSACTION_FLOW_PUB.convert_currency, input params:', 9);
                    print_debug('1. p_org_id = ' || l_transfer_price_tbl(i).to_org_id, 9);
                    print_debug('2. p_transfer_price = ' || l_mtl_trx_tbl(l_index-1).intercompany_cost, 9);
                    print_debug('3. p_currency_code = ' || l_mtl_trx_tbl(l_index-1).currency_code, 9);
                 END IF;

		 /*Start of Bug: 5554106. */
		 BEGIN
		    SELECT primary_uom_code
		      INTO l_primary_uom
		      FROM mtl_system_items
		     WHERE organization_id = l_trx_flow_tbl(i).to_organization_id
		       AND inventory_item_id = l_mtl_trx_tbl(1).inventory_item_id;
		    print_debug('Primary UOM is: '||l_primary_uom, 9);
		 EXCEPTION
		   WHEN NO_DATA_FOUND THEN
                      print_debug('Item not found for item id: '|| l_mtl_trx_tbl(1).inventory_item_id, 9);
                      FND_MESSAGE.SET_NAME('INV', 'INV_NO_ITEM_FOUND');
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
		 END;

		 print_debug('Transaction UOM is: '||p_mtl_trx_tbl(1).transaction_uom, 9);


		 IF p_mtl_trx_tbl(1).transaction_uom <> l_primary_uom THEN
     		    INV_CONVERT.inv_um_conversion(
                                from_unit   => l_primary_uom
                              , to_unit     => p_mtl_trx_tbl(1).transaction_uom
                              , item_id     => l_mtl_trx_tbl(1).inventory_item_id
                              , uom_rate    => l_uom_rate
                                               );

		    -- Converting the transaction quantity to primary UOMs quantity when transaction UOM is not same as Primary UOM.
		    print_debug('Transaction UOM is NOT same as Primary UOM.', 9);
		    print_debug('Calling inv_convert.inv_um_convert....', 9);
		    l_mtl_trx_tbl(l_index).primary_quantity :=  -1*inv_convert.inv_um_convert(l_mtl_trx_tbl(1).inventory_item_id,6
		                                                                         ,l_mtl_trx_tbl(l_index-1).transaction_quantity
											 ,p_mtl_trx_tbl(1).transaction_uom
											 ,l_primary_uom
											 ,'','');
		 ELSE
		    print_debug('Transaction UOM is same as Primary UOM.', 9);
		    l_mtl_trx_tbl(l_index).primary_quantity := -1*l_mtl_trx_tbl(l_index-1).primary_quantity;
		 END IF;
  	         print_debug('Primary Quantity: '||l_mtl_trx_tbl(l_index).primary_quantity, 9);
		 /*End of bug: 5554106. */

		 print_debug('l_uom_rate: '||l_uom_rate, 9);

                 l_progress := 360;
                 l_mtl_trx_tbl(l_index).transaction_cost := l_uom_rate * INV_TRANSACTION_FLOW_PUB.convert_currency(
                               p_org_id                   => l_transfer_price_tbl(i).to_org_id
                             , p_transfer_price           => l_transfer_price_tbl(i).transfer_price
                             , p_currency_code            => l_mtl_trx_tbl(l_index-1).currency_code
                             , p_transaction_date         => l_mtl_trx_tbl(l_index).transaction_date
                             , p_logical_txn              => 'Y' /* bug 6696446 */
                             , x_functional_currency_code => l_mtl_trx_tbl(l_index).currency_code
                             , x_return_status            => l_return_status
                             , x_msg_data                 => l_msg_data
                             , x_msg_count                => l_msg_count);

                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('l_return_status = ' || l_return_status, 9);
                       print_debug('l_msg_data = ' || l_msg_data, 9);
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
                 END IF;
                 -- Commented following for bug 6696446
                 -- l_mtl_trx_tbl(l_index).transaction_cost := round(l_mtl_trx_tbl(l_index).transaction_cost,2);
                 print_debug('transaction_cost: '||l_mtl_trx_tbl(l_index).transaction_cost, 9);

                 l_mtl_trx_tbl(l_index).intercompany_cost := l_mtl_trx_tbl(l_index-1).intercompany_cost;
                 l_mtl_trx_tbl(l_index).intercompany_currency_code := l_mtl_trx_tbl(l_index-1).intercompany_currency_code;
                 l_mtl_trx_tbl(l_index).invoiced_flag := 'N';
                 l_mtl_trx_tbl(l_index).pm_cost_collected := null;
                 l_mtl_trx_tbl(l_index).cost_group_id := l_trx_flow_tbl(i).to_org_cost_group_id;
                 l_mtl_trx_tbl(l_index).transfer_cost_group_id := l_mtl_trx_tbl(l_index-1).cost_group_id;

                 l_mtl_trx_tbl(l_index).transaction_quantity := -1*l_mtl_trx_tbl(l_index-1).transaction_quantity;


                 IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
                    -- SO issue/RMA
                    l_mtl_trx_tbl(l_index).parent_transaction_id := l_mtl_trx_tbl(1).transaction_id;
                    l_mtl_trx_tbl(l_index).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;
                 END IF;

                 IF (l_is_return = 0) THEN -- construct logical I/C receipt of to_org_id
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_SHIP_RECEIPT;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICRECEIPT;
                 ELSE -- it's RMA, construct logical I/C receipt return
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_RECEIPT_RETURN;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICRCPTRETURN;
                 END IF;
                 -- END of construct the logical I/C receipt or logical I/C receipt
                 -- return of to_org_id

              ELSE -- (l_trx_flow_tbl(i).start_org_id <> l_trx_flow_tbl(i).from_org_id) THEN
                 -- this is intermediate node to intermediate node
                 -- OR intermediate node to last node
                 -- create a logical I/C sales issue of the from_org_id and a
                 -- logical I/C receipt of the to_org_id,
                 -- if the to_org_id is the last node, also create a logical sales
                 -- order issue from to_org_id
                 -- OR for RMA, create a logical I/C sales return of from_org_id
                 -- and a logical I/C receipt return of the to_org_id.
                 -- if the to_org_id is the last node, also create a logical
                 -- RMA receipt into to_org_id

                 -- start to construct the logical I/C sales issue of the from_org_id
                 -- or logical I/C sales return into from_org_id
                 IF (l_debug = 1) THEN
                    print_debug('Intermediate node', 9);
                    print_debug('Construct the logical I/C sales issue/return of from_org_id', 9);
                    print_debug('l_index for l_mtl_trx_tbl = ' || l_index, 9);
                 END IF;

                 l_mtl_trx_tbl(l_index).organization_id := l_trx_flow_tbl(i).from_organization_id;
                 l_mtl_trx_tbl(l_index).transfer_organization_id := l_trx_flow_tbl(i).to_organization_id;
                 l_mtl_trx_tbl(l_index).acct_period_id := l_mtl_trx_tbl(l_index-1).acct_period_id;
                 l_mtl_trx_tbl(l_index).distribution_account_id := l_trx_flow_tbl(i).INTERCOMPANY_COGS_ACCOUNT_ID;
                 l_mtl_trx_tbl(l_index).currency_code := l_transfer_price_tbl(i).functional_currency_code;
                 l_mtl_trx_tbl(l_index).transaction_cost := l_mtl_trx_tbl(l_index-1).transaction_cost;
                 l_mtl_trx_tbl(l_index).intercompany_cost := l_transfer_price_tbl(i).incr_transfer_price;
                 l_mtl_trx_tbl(l_index).intercompany_currency_code := l_transfer_price_tbl(i).incr_currency_code;
                 l_mtl_trx_tbl(l_index).invoiced_flag := 'N';
                 l_mtl_trx_tbl(l_index).pm_cost_collected := null;
                 l_mtl_trx_tbl(l_index).cost_group_id := l_trx_flow_tbl(i).from_org_cost_group_id;
                 l_mtl_trx_tbl(l_index).transfer_cost_group_id := l_trx_flow_tbl(i).to_org_cost_group_id;
                 l_mtl_trx_tbl(l_index).transaction_quantity := -1*l_mtl_trx_tbl(l_index-1).transaction_quantity;
                 l_mtl_trx_tbl(l_index).primary_quantity := -1*l_mtl_trx_tbl(l_index-1).primary_quantity;
                 l_mtl_trx_tbl(l_index).transaction_date := NVL(l_mtl_trx_tbl(1).transaction_date,sysdate);

                 IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
                    l_mtl_trx_tbl(l_index).parent_transaction_id := l_mtl_trx_tbl(1).transaction_id;
                    l_mtl_trx_tbl(l_index).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;
                 END IF;

                 IF (l_is_return = 0) THEN -- construct logical I/C sales issue of the from_org_id
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_SALES_ISSUE;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICSALES;
                 ELSE -- it's RMA, construct logical I/C sales return
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_TYPE_LOGL_IC_RECEIPT_RETURN;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_SALES_RETURN;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICSALESRETURN;
                 END IF;
                 -- end of construct the logical I/C sales issue of the from_org_id
                 -- or logical I/C sales return into from_org_id

                 -- start to construct the logical I/C receipt of the to_org_id
                 -- or logical I/C receipt return from the to_org_id
                 l_index := l_index + 1;
                 IF (l_debug = 1) THEN
                    print_debug('Intermediate node', 9);
                    print_debug('Construct the logical I/C receipt/receipt return of from_org_id', 9);
                    print_debug('l_index for l_mtl_trx_tbl = ' || l_index, 9);
                 END IF;

                 l_mtl_trx_tbl(l_index).organization_id := l_trx_flow_tbl(i).to_organization_id;
                 l_mtl_trx_tbl(l_index).transfer_organization_id := l_trx_flow_tbl(i).from_organization_id;
                 l_mtl_trx_tbl(l_index).transaction_date := NVL(l_mtl_trx_tbl(1).transaction_date,sysdate);
                 l_progress := 370;
                 get_acct_period(
                            x_return_status    => l_return_status
                          , x_msg_count        => l_msg_count
                          , x_msg_data         => l_msg_data
                          , x_acct_period_id   => l_mtl_trx_tbl(l_index).acct_period_id
                          , p_organization_id  => l_mtl_trx_tbl(l_index).organization_id
                          , p_transaction_date => l_mtl_trx_tbl(l_index).transaction_date);
                 IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_acct_period returns error with org id = '
                                      || l_mtl_trx_tbl(1).organization_id, 9);
                       print_debug('x_msg_data = ' || x_msg_data, 9);
                    END IF;
                    FND_MESSAGE.SET_NAME('INV', 'INV_PERIOD_RETRIEVAL_ERROR');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 IF (l_inv_asset_flag = 'Y') THEN
                    l_mtl_trx_tbl(l_index).distribution_account_id := l_trx_flow_tbl(i).INVENTORY_ACCRUAL_ACCOUNT_ID;
                 ELSE
                    l_mtl_trx_tbl(l_index).distribution_account_id := l_trx_flow_tbl(i).EXPENSE_ACCRUAL_ACCOUNT_ID;
                 END IF;



		 /*Start of Bug: 5554106. */
		 print_debug('Checking Transaction UOM and Primary UOM.', 9);
		 BEGIN
		    SELECT primary_uom_code
		      INTO l_primary_uom
		      FROM mtl_system_items
		     WHERE organization_id = l_trx_flow_tbl(i).to_organization_id
		       AND inventory_item_id = l_mtl_trx_tbl(1).inventory_item_id;
		    print_debug('Primary UOM for '||l_trx_flow_tbl(i).to_organization_id||' is: '||l_primary_uom, 9);
		 EXCEPTION
		   WHEN NO_DATA_FOUND THEN
                      print_debug('Item not found for item id: '|| l_mtl_trx_tbl(1).inventory_item_id, 9);
                      FND_MESSAGE.SET_NAME('INV', 'INV_NO_ITEM_FOUND');
                      FND_MSG_PUB.ADD;
                      RAISE FND_API.G_EXC_ERROR;
		 END;
		 l_uom_rate := 1;

		 print_debug('Transaction UOM is: '||p_mtl_trx_tbl(1).transaction_uom, 9);

		 IF p_mtl_trx_tbl(1).transaction_uom <> l_primary_uom THEN
		    INV_CONVERT.inv_um_conversion(
                                from_unit   => l_primary_uom
                              , to_unit     => p_mtl_trx_tbl(1).transaction_uom
                              , item_id     => l_mtl_trx_tbl(1).inventory_item_id
                              , uom_rate    => l_uom_rate
                                               );

		    -- Converting the transaction quantity to primary UOMs quantity when transaction UOM is not same as Primary UOM.
		    print_debug('Transaction UOM is NOT same as Primary UOM.', 9);
		    print_debug('Calling inv_convert.inv_um_convert....', 9);
		    l_mtl_trx_tbl(l_index).primary_quantity :=  -1*inv_convert.inv_um_convert(l_mtl_trx_tbl(1).inventory_item_id,6
		                                                                         ,l_mtl_trx_tbl(l_index-1).transaction_quantity
											 ,p_mtl_trx_tbl(1).transaction_uom
											 ,l_primary_uom
											 ,'','');
		 ELSE
		    print_debug('Transaction UOM is same as Primary UOM.', 9);
		    l_mtl_trx_tbl(l_index).primary_quantity := -1*l_mtl_trx_tbl(l_index-1).primary_quantity;
		 END IF;
  	         print_debug('Primary Quantity: '||l_mtl_trx_tbl(l_index).primary_quantity, 9);
		 /*End of bug: 5554106. */

		 print_debug('l_uom_rate: '||l_uom_rate, 9);

		 l_progress := 380;
                 l_mtl_trx_tbl(l_index).transaction_cost := l_uom_rate * INV_TRANSACTION_FLOW_PUB.convert_currency(
                               p_org_id                   => l_transfer_price_tbl(i).to_org_id
                             , p_transfer_price           => l_transfer_price_tbl(i).transfer_price
                             , p_currency_code            => l_mtl_trx_tbl(l_index-1).currency_code
                             , p_transaction_date         => l_mtl_trx_tbl(l_index).transaction_date
                             , p_logical_txn              => 'Y'  /* bug 6696446 */
                             , x_functional_currency_code => l_mtl_trx_tbl(l_index).currency_code
                             , x_return_status            => l_return_status
                             , x_msg_data                 => l_msg_data
                             , x_msg_count                => l_msg_count);
                 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('l_return_status = ' || l_return_status, 9);
                       print_debug('l_msg_data = ' || l_msg_data, 9);
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
                 END IF;

                -- commented following for bug 6696446
                -- l_mtl_trx_tbl(l_index).transaction_cost := round(l_mtl_trx_tbl(l_index).transaction_cost,2);

                print_debug('transaction_cost: '||l_mtl_trx_tbl(l_index).transaction_cost, 9);

                 l_mtl_trx_tbl(l_index).intercompany_cost := l_mtl_trx_tbl(l_index-1).intercompany_cost;
                 l_mtl_trx_tbl(l_index).intercompany_currency_code := l_mtl_trx_tbl(l_index-1).intercompany_currency_code;
                 l_mtl_trx_tbl(l_index).invoiced_flag := 'N';
                 l_mtl_trx_tbl(l_index).pm_cost_collected := null;
                 l_mtl_trx_tbl(l_index).cost_group_id := l_trx_flow_tbl(i).to_org_cost_group_id;
                 l_mtl_trx_tbl(l_index).transfer_cost_group_id := l_trx_flow_tbl(i).from_org_cost_group_id;
                 l_mtl_trx_tbl(l_index).transaction_quantity := -1*l_mtl_trx_tbl(l_index-1).transaction_quantity;

                 IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
                    -- SO issue/RMA
                    l_mtl_trx_tbl(l_index).parent_transaction_id := l_mtl_trx_tbl(1).transaction_id;
                    l_mtl_trx_tbl(l_index).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;
                 END IF;

                 IF (l_is_return = 0) THEN -- construct logical I/C receipt of from_org_id
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_SHIP_RECEIPT;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICRECEIPT;
                 ELSE -- it's RMA, construct logical I/C receipt return
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_INVENTORY;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_IC_RECEIPT_RETURN;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALICRCPTRETURN;
                 END IF;
                 -- END of construct the logical I/C receipt or logical I/C receipt
                 -- return of to_org_id
              END IF; -- end of IF (l_trx_flow_tbl(i).start_org_id = l_trx_flow_tbl(i).from_org_id)

              -- if it's the end node, also construct the logical sales order issue
              -- of to_org_id or logical RMA receipt of to_org_id
              IF (l_trx_flow_tbl(i).end_org_id = l_trx_flow_tbl(i).to_org_id) THEN
                 l_index := l_index + 1;
                 IF (l_debug = 1) THEN
                    print_debug('End node', 9);
                    print_debug('Construct the logical sales issue/RMA receipt of from_org_id', 9);
                    print_debug('l_index for l_mtl_trx_tbl = ' || l_index, 9);
                 END IF;

                 l_mtl_trx_tbl(l_index).organization_id := l_trx_flow_tbl(i).to_organization_id;
                 l_mtl_trx_tbl(l_index).transfer_organization_id := null;
                 l_mtl_trx_tbl(l_index).acct_period_id := l_mtl_trx_tbl(l_index-1).acct_period_id;

                 l_progress := 390;

                 get_cogs_acct_for_logical_so(
                              x_return_status => l_return_status
                            , x_msg_count     => l_msg_count
                            , x_msg_data      => l_msg_data
                            , x_cogs_acct_id  => l_mtl_trx_tbl(l_index).distribution_account_id
                            , p_inventory_item_id => l_mtl_trx_tbl(1).inventory_item_id
                            , p_order_line_id     => l_mtl_trx_tbl(1).trx_source_line_id
			    , p_ic_to_inv_organization_id => l_mtl_trx_tbl(l_index).organization_id);  -- Bug: 4607049.
                 IF (l_return_status <> G_RET_STS_SUCCESS) THEN
                    IF (l_debug = 1) THEN
                       print_debug('get_cogs_acct_for_logical_so returns error', 9);
                       print_debug('l_msg_data = ' || l_msg_data, 9);
                    END IF;
                    FND_MESSAGE.SET_NAME('INV', 'INV_NO_COGS_FOR_LOG_SO');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 l_mtl_trx_tbl(l_index).currency_code := null;
                 l_mtl_trx_tbl(l_index).transaction_cost := l_mtl_trx_tbl(l_index-1).transaction_cost;
                 l_mtl_trx_tbl(l_index).intercompany_cost := null;
                 l_mtl_trx_tbl(l_index).intercompany_currency_code := null;
                 l_mtl_trx_tbl(l_index).invoiced_flag := null;
                 l_mtl_trx_tbl(l_index).pm_cost_collected  := null;
                 l_mtl_trx_tbl(l_index).cost_group_id := l_mtl_trx_tbl(l_index-1).cost_group_id;
                 l_mtl_trx_tbl(l_index).transaction_quantity := -1*l_mtl_trx_tbl(l_index-1).transaction_quantity;
                 l_mtl_trx_tbl(l_index).primary_quantity := -1*l_mtl_trx_tbl(l_index-1).primary_quantity;
                 l_mtl_trx_tbl(l_index).transaction_date := NVL(l_mtl_trx_tbl(1).transaction_date,sysdate);

                 IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
                    l_mtl_trx_tbl(l_index).parent_transaction_id := l_mtl_trx_tbl(1).transaction_id;
                    l_mtl_trx_tbl(l_index).transaction_batch_id := l_mtl_trx_tbl(1).transaction_id;
                 END IF;

                 IF (l_is_return = 0) THEN
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_SALESORDER;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_SALES_ORDER_ISSUE;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALISSUE;
                 ELSE -- it's RMA, construct logical RMA receipt
                    l_mtl_trx_tbl(l_index).transaction_source_type_id := G_SOURCETYPE_RMA;
                    l_mtl_trx_tbl(l_index).transaction_type_id := G_TYPE_LOGL_RMA_RECEIPT;
                    l_mtl_trx_tbl(l_index).transaction_action_id := G_ACTION_LOGICALRECEIPT;
                 END IF;
              END IF;
              -- end of constrct the logical sales order issue or the logical RMA
              -- receipt of the to_org_id
           END LOOP;

           IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE
                OR p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
              -- For sales order issue or RMA, we don't want to insert the first record
              -- which is physical record for RMA or SO issue or
              -- logical record for dropship deliver already inserted into MMT.
              IF (l_is_return = 0) THEN
                 l_index := 0;
                 FOR i in 2..l_mtl_trx_tbl.COUNT LOOP
                     l_index := l_index + 1;
                     l_mtl_trx_tbl_temp(l_index) := l_mtl_trx_tbl(i);
                 END LOOP;
                 l_mtl_trx_tbl := l_mtl_trx_tbl_temp;
              ELSE
                 -- IF the transaction is return transaction (RMA), reserve the order
                 -- of the records in the pl/sql table
                 l_index := 0;
                 FOR i in REVERSE 2..l_mtl_trx_tbl.COUNT LOOP
                     l_index := l_index + 1;
                     l_mtl_trx_tbl_temp(l_index) := l_mtl_trx_tbl(i);
                 END LOOP;
                 l_mtl_trx_tbl := l_mtl_trx_tbl_temp;
              END IF;

           END IF;

           -- populate the transaction id of the records
           FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
              -- populate transaction id
              l_progress := 400;
              SELECT mtl_material_transactions_s.nextval
              INTO   l_mtl_trx_tbl(i).transaction_id
              FROM   dual;

              -- populate the columns which has same value for all types of records
              l_mtl_trx_tbl(i).inventory_item_id := p_mtl_trx_tbl(1).inventory_item_id;
              l_mtl_trx_tbl(i).revision := p_mtl_trx_tbl(1).revision;
              l_mtl_trx_tbl(i).transaction_uom := p_mtl_trx_tbl(1).transaction_uom;
              l_mtl_trx_tbl(i).source_line_id := p_mtl_trx_tbl(1).source_line_id;
              l_mtl_trx_tbl(i).rcv_transaction_id := p_mtl_trx_tbl(1).rcv_transaction_id;
              l_mtl_trx_tbl(i).trx_flow_header_id := p_mtl_trx_tbl(1).trx_flow_header_id;
              l_mtl_trx_tbl(i).lpn_id := p_mtl_trx_tbl(1).lpn_id;
              l_mtl_trx_tbl(i).costed_flag := 'N';
              l_mtl_trx_tbl(i).transaction_source_name := p_mtl_trx_tbl(1).transaction_source_name;

              IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
                 l_mtl_trx_tbl(i).transaction_batch_id := p_mtl_trx_tbl(1).transaction_id;
                 l_mtl_trx_tbl(i).parent_transaction_id := p_mtl_trx_tbl(1).transaction_id;
		 l_mtl_trx_tbl(i).transaction_source_id := l_mtl_trx_tbl(1).transaction_source_id;
                 l_mtl_trx_tbl(i).trx_source_line_id := l_mtl_trx_tbl(1).trx_source_line_id;

		 IF (l_debug = 1) THEN
		    print_debug('******transaction_source_id: ******' ||
				l_mtl_trx_tbl(i).transaction_source_id);
		    print_debug('******i: ******' ||i);
		 END IF;
	      ELSE
		 l_mtl_trx_tbl(i).transaction_source_id := p_mtl_trx_tbl(1).transaction_source_id;
                 l_mtl_trx_tbl(i).trx_source_line_id := p_mtl_trx_tbl(1).trx_source_line_id;
              END IF;

              l_mtl_trx_tbl(i).transaction_batch_seq := i;
           END LOOP;
        END IF; --end of (p_logical_trx_type_code=2 and shipping_ou<>selling_ou) or SO issue/RMA
     END IF; -- end of checking p_logical_trx_type_code
     -- ****** end of populating the logical transaction records of the pl/sql table *******

     IF (l_debug = 1) THEN
        FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
          print_debug('***** l_mtl_trx_tbl record ' || i, 9);
          print_debug('transaction_id: ' || l_mtl_trx_tbl(i).transaction_id, 9);
          print_debug('transaction_batch_id: ' || l_mtl_trx_tbl(i).transaction_batch_id, 9);
          print_debug('transaction_batch_seq: ' || l_mtl_trx_tbl(i).transaction_batch_seq, 9);
          print_debug('parent_transaction_id: ' || l_mtl_trx_tbl(i).parent_transaction_id, 9);
          print_debug('parent_transaction_flag: ' || l_mtl_trx_tbl(i).parent_transaction_flag, 9);
          print_debug('organization_id: ' || l_mtl_trx_tbl(i).organization_id, 9);
          print_debug('transfer_organization_id: ' || l_mtl_trx_tbl(i).transfer_organization_id, 9);
          print_debug('inventory_item_id: ' || l_mtl_trx_tbl(i).inventory_item_id, 9);
          print_debug('revision:' || l_mtl_trx_tbl(i).revision, 9);
          print_debug('transaction_type_id: ' || l_mtl_trx_tbl(i).transaction_type_id, 9);
          print_debug('transaction_action_id: ' || l_mtl_trx_tbl(i).transaction_action_id, 9);
          print_debug('transaction_source_type_id: ' || l_mtl_trx_tbl(i).transaction_source_type_id, 9);
          print_debug('transaction_source_id: ' || l_mtl_trx_tbl(i).transaction_source_id, 9);
          print_debug('transaction_source_name: ' || l_mtl_trx_tbl(i).transaction_source_name, 9);
          print_debug('transaction_quantity: ' || l_mtl_trx_tbl(i).transaction_quantity, 9);
          print_debug('transaction_uom: ' || l_mtl_trx_tbl(i).transaction_uom, 9);
          print_debug('primary_quantity: ' || l_mtl_trx_tbl(i).primary_quantity, 9);
          print_debug('transaction_cost: ' || l_mtl_trx_tbl(i).transaction_cost, 9);
          print_debug('intercompany_cost: ' || l_mtl_trx_tbl(i).intercompany_cost, 9);
          print_debug('cost_group_id: ' || l_mtl_trx_tbl(i).cost_group_id, 9);
          print_debug('transfer_cost_group_id: ' || l_mtl_trx_tbl(i).transfer_cost_group_id, 9);
          print_debug('trx_flow_header_id: ' || l_mtl_trx_tbl(i).trx_flow_header_id, 9);
          print_debug('invoiced_flag: ' || l_mtl_trx_tbl(i).invoiced_flag, 9);
          print_debug('pm_cost_collected: ' || l_mtl_trx_tbl(i).pm_cost_collected, 9);
          print_debug('acct_period_id: ' || l_mtl_trx_tbl(i).acct_period_id, 9);
          print_debug('distribution_account_id: ' || l_mtl_trx_tbl(i).distribution_account_id, 9);
          print_debug('transaction_source_id: ' || l_mtl_trx_tbl(i).transaction_source_id, 9);
          print_debug('trx_source_line_id: ' || l_mtl_trx_tbl(i).trx_source_line_id, 9);
          print_debug('source_line_id: ' || l_mtl_trx_tbl(i).source_line_id, 9);
          print_debug('rcv_transaction_id: ' || l_mtl_trx_tbl(i).rcv_transaction_id, 9);
          print_debug('lpn_id: ' || l_mtl_trx_tbl(i).lpn_id, 9);
        END LOOP;
     END IF;

     -- For global procurement or drop shipment receipt, if the transaction type is populated
     -- but the transaction_action_id and transaction_source_type_id is null, populate
     -- the transaction_action_id and transaction_source_type_id
     IF (p_logical_trx_type_code = G_LOGTRXCODE_GLOBPROCRTV OR
          p_logical_trx_type_code = G_LOGTRXCODE_DSRECEIPT) THEN
        FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
          IF (l_mtl_trx_tbl(i).transaction_action_id is null OR
               l_mtl_trx_tbl(i).transaction_source_type_id is null) THEN
             IF (l_mtl_trx_tbl(i).transaction_type_id is not null) THEN
                BEGIN
                   l_progress := 410;
                   SELECT transaction_action_id, transaction_source_type_id
                   INTO   l_mtl_trx_tbl(i).transaction_action_id, l_mtl_trx_tbl(i).transaction_source_type_id
                   FROM   mtl_transaction_types
                   WHERE  transaction_type_id = l_mtl_trx_tbl(i).transaction_type_id
                   AND    nvl(disable_date, sysdate+1) > sysdate;
                EXCEPTION
                   WHEN no_data_found THEN
                        IF (l_debug = 1) THEN
                           print_debug('Transaction type not found', 9);
                        END IF;
                        FND_MESSAGE.SET_NAME('INV', 'INV_TRX_TYPE_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END;
             ELSE
                IF (l_debug = 1) THEN
                   print_debug('Trx action id, trx source type id or trx type is invalid', 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV', 'INV_TRX_TYPE_ERROR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
        END LOOP;
     END IF;


     IF (p_validation_flag = G_TRUE) THEN
        -- validate the transaction record
        IF (l_debug = 1) THEN
           print_debug('Calling INV_LOGICAL_TRANSACTIONS_PVT.validate_input_parameters', 9);
        END IF;

        l_progress := 420;
        INV_LOGICAL_TRANSACTIONS_PVT.validate_input_parameters(
              x_return_status         => l_return_status
            , x_msg_count             => l_msg_count
            , x_msg_data              => l_msg_data
            , p_mtl_trx_tbl           => l_mtl_trx_tbl
            , p_validation_level      => p_validation_flag
            , p_logical_trx_type_code => p_logical_trx_type_code);

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           IF (l_debug = 1) THEN
              print_debug('Validate_input_parameters returns error: ' || l_msg_data, 9);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           IF (l_debug = 1) THEN
              print_debug('Validate_input_parameters returns unexpected error: ' || l_msg_data, 9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

     -- validate_input_parameters returns success, call inv_mmt_insert to insert the
     -- record into mmt
     IF (l_debug = 1) THEN
        print_debug('Calling INV_LOGICAL_TRANSACTIONS_PVT.inv_mmt_insert', 9);
     END IF;

     l_progress := 430;
     INV_LOGICAL_TRANSACTIONS_PVT.inv_mmt_insert(
           x_return_status         => l_return_status
         , x_msg_count             => l_msg_count
         , x_msg_data              => l_msg_data
         , p_api_version_number    => 1.0
         , p_init_msg_lst          => fnd_api.g_false
         , p_mtl_trx_tbl           => l_mtl_trx_tbl
         , p_logical_trx_type_code => p_logical_trx_type_code);

     IF (l_debug = 1) THEN
        print_debug('After calling inv_mmt_insert, return status = ' || l_return_status, 9);
     END IF;

     IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        IF (l_debug = 1) THEN
           print_debug('inv_mmt_insert returns error: ' || l_msg_data, 9);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        IF (l_debug = 1) THEN
           print_debug('inv_mmt_insert returns unexpected error: ' || l_msg_data, 9);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- For dropship deliver, if the item is lot or serial controlled, we need to
     -- insert into mtl_transaction_lot_numbers or mtl_unit_transactions
     -- for the first logical intercompany sales issue record
     IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
        IF (l_lot_control_code = 2 or l_serial_control_code in (2, 5, 6)) THEN
           INV_LOGICAL_TRANSACTIONS_PVT.inv_lot_serial_insert
              (x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_api_version_number => 1.0,
               p_init_msg_lst  => fnd_api.g_false,
               p_parent_transaction_id => l_mtl_trx_tbl(1).parent_transaction_id,
               p_transaction_id => l_mtl_trx_tbl(1).transaction_id,
               p_lot_control_code => l_lot_control_code,
               p_serial_control_code => l_serial_control_code,
               p_organization_id     => l_mtl_trx_tbl(1).organization_id,
               p_inventory_item_id   => l_mtl_trx_tbl(1).inventory_item_id,
               p_primary_quantity    => l_mtl_trx_tbl(1).primary_quantity,
               p_trx_source_type_id  => l_mtl_trx_tbl(1).transaction_source_type_id,
               p_revision            => l_mtl_trx_tbl(1).revision);

            IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
               IF (l_debug = 1) THEN
                  print_debug('inv_lot_serial_insert returns error: ' || l_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
               IF (l_debug = 1) THEN
                  print_debug('inv_lot_serial_insert returns unexpected error: ' || l_msg_data, 9);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF (l_mtl_trx_tbl(1).lpn_id IS NOT NULL) THEN
	   --Bug 4411804: Removing direct updates to WLPN table.
	   /*******
           UPDATE wms_license_plate_numbers
	     SET    lpn_context = 4
	     WHERE  organization_id = l_mtl_trx_tbl(1).organization_id
	     AND    lpn_id = l_mtl_trx_tbl(1).lpn_id;

	     IF (SQL%ROWCOUNT = 0) THEN
	     IF (l_debug = 1) THEN
	     print_debug('No wms_license_plate_number record is found for update with lpn_id'
	     || l_mtl_trx_tbl(1).lpn_id ,9);
	     END IF;
	     FND_MESSAGE.SET_NAME('INV', 'INV_LPN_UPDATE_FAILURE');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	     END IF;
	     ******/
	     --Calling wms_container_pvt.Modify_LPN API to update the
	     -- context.
	     l_lpn.organization_id := l_mtl_trx_tbl(1).organization_id;
	   l_lpn.lpn_id := l_mtl_trx_tbl(1).lpn_id;
	   l_lpn.lpn_context := 4;
	   wms_container_pvt.Modify_LPN
	     (
	      p_api_version        => 1.0
	      , p_init_msg_list    => fnd_api.g_false
	      , p_commit           => fnd_api.g_false
	      , p_validation_level => fnd_api.g_valid_level_full
	      , x_return_status    => l_return_status
	      , x_msg_count        => l_msg_count
	      , x_msg_data         => l_msg_data
	      , p_lpn              => l_lpn
	      , p_caller           => 'INV_LOGTXN'
	      );

	   IF (l_return_status <> G_RET_STS_SUCCESS) THEN
	      IF (l_debug = 1) THEN
		 print_debug('Error from modify LPN API', 9);
		 print_debug('l_msg_data = ' || l_msg_data, 9);
	      END IF;
	      FND_MESSAGE.SET_NAME('INV', 'INV_LPN_UPDATE_FAILURE');
	      FND_MSG_PUB.ADD;
	      RAISE FND_API.G_EXC_ERROR;
	   END IF;
        END IF;
     END IF;

     -- inv_mmt_insert returns success
     -- Loop through the records of pl/sql table, if transaction cost is not null,
     -- call costing API to insert into MTL_CST_TXN_COST_DETAILS
     IF (l_debug = 1) THEN
        print_debug('Calling MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row', 9);
     END IF;

     IF (p_logical_trx_type_code = G_LOGTRXCODE_RETROPRICEUPD) THEN
        l_progress := 440;
        FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
          --
          -- Bug: -  umoogala   13-Feb-2006
          -- No bug is logged. But fixing as part of bug 5008080.
          -- Do NOT insert into MTL_CST_TXN_COST_DETAILS table for
          -- process mfg organizations.
          --
	  IF l_prev_organization_id IS NULL OR
	     p_mtl_trx_tbl(i).organization_id <> l_prev_organization_id
	  THEN
	    l_prev_organization_id := p_mtl_trx_tbl(i).organization_id;

            SELECT NVL(process_enabled_flag, 'N')
	      INTO l_process_enabled_flag
	      FROM mtl_parameters
	     WHERE organization_id = p_mtl_trx_tbl(i).organization_id;
	  END IF;

          IF (l_debug = 1) THEN
             print_debug('X_Transaction_Id = ' || l_mtl_trx_tbl(i).transaction_id, 9);
             print_debug('X_Organization_Id = ' || l_mtl_trx_tbl(i).organization_id, 9);
             print_debug('X_Last_Updated_By = ' || l_user_id, 9);
             print_debug('X_Inventory_Item_Id = ' || l_mtl_trx_tbl(i).inventory_item_id, 9);
             print_debug('X_Transaction_Cost = ' || l_mtl_trx_tbl(i).old_po_price, 9);
             print_debug('old po price = ' || l_mtl_trx_tbl(i).old_po_price, 9);
             print_debug('new po price = ' || l_mtl_trx_tbl(i).new_po_price, 9);
             print_debug('process_enabled_flag = ' || l_process_enabled_flag, 9);
          END IF;

          IF l_process_enabled_flag = 'N'
          THEN

            MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row(
                     X_Rowid             => l_row_id
                   , X_Transaction_Id    => l_mtl_trx_tbl(i).transaction_id
                   , X_Organization_Id   => l_mtl_trx_tbl(i).organization_id
                   , X_Cost_Element_Id   => 1
                   , X_Level_Type        => 1
                   , X_Last_Update_Date  => NVL(l_mtl_trx_tbl(i).transaction_date,sysdate)
                   , X_Last_Updated_By   => l_user_id
                   , X_Creation_Date     => NVL(l_mtl_trx_tbl(i).transaction_date,sysdate)
                   , X_Created_By        => l_user_id
                   , X_Inventory_Item_Id => l_mtl_trx_tbl(i).inventory_item_id
                   , X_Transaction_Cost  => l_mtl_trx_tbl(i).old_po_price
                   , X_Value_Change      => l_mtl_trx_tbl(i).old_po_price-l_mtl_trx_tbl(i).new_po_price);
            IF (l_row_id is null or l_row_id < 0) THEN
               IF (l_debug = 1) THEN
                  print_debug('MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row returns error', 9);
                  print_debug('l_row_id = ' || l_row_id, 9);
               END IF;
               FND_MESSAGE.SET_NAME('INV', 'INV_INSERT_COST_ERR');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
	  ELSE
	    IF (l_debug = 1)
	    THEN
	      print_debug('Note: This is Process Enabled Org, so no rows being inserted into MTL_CST_TXN_COST_DETAILS', 9);
	    END IF;
          END IF;
        END LOOP;
     ELSE
        l_progress := 450;
        FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
          IF (l_mtl_trx_tbl(i).transaction_cost IS NOT NULL) THEN
             IF (l_debug = 1) THEN
                print_debug('X_Transaction_Id = ' || l_mtl_trx_tbl(i).transaction_id, 9);
                print_debug('X_Organization_Id = ' || l_mtl_trx_tbl(i).organization_id, 9);
                print_debug('X_Last_Updated_By = ' || l_user_id, 9);
                print_debug('X_Inventory_Item_Id = ' || l_mtl_trx_tbl(i).inventory_item_id, 9);
                print_debug('X_Transaction_Cost = ' || l_mtl_trx_tbl(i).transaction_cost, 9);
             END IF;

              -- Bug 8620411  - Code changes start
 	          SELECT primary_uom_code
 	          INTO l_primary_uom
 	          FROM mtl_system_items
 	          WHERE inventory_item_id = l_mtl_trx_tbl(i).inventory_item_id
 	          AND organization_id =l_mtl_trx_tbl(i).organization_id;

 	         print_debug('Calling uom_conversion', 9);

 	         INV_CONVERT.inv_um_conversion(
 	                from_unit   => l_mtl_trx_tbl(i).transaction_uom
 	              , to_unit     => l_primary_uom
 	              , item_id     => l_mtl_trx_tbl(i).inventory_item_id
 	              , uom_rate    => l_uom_rate
 	         );

 	         IF ( l_uom_rate = -99999 ) THEN
 	             print_debug('Error from calling uom_conversion', 9);
 	             FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_UOM_CONV');
 	             FND_MESSAGE.SET_TOKEN('VALUE1', l_mtl_trx_tbl(i).transaction_uom);
 	             FND_MESSAGE.SET_TOKEN('VALUE2', l_primary_uom);
 	             FND_MSG_PUB.ADD;
 	             RAISE FND_API.G_EXC_ERROR;
 	         END IF;

 	         print_debug('l_uom_rate = ' || l_uom_rate, 9);

 	        l_mtl_trx_tbl(i).transaction_cost :=   l_mtl_trx_tbl(i).transaction_cost / l_uom_rate;

 	         print_debug('X_Transaction_Cost in primary uom =  ' || l_mtl_trx_tbl(i).transaction_cost, 9);
 	         -- Bug 8620411  - Code changes end

             MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row(
                  X_Rowid             => l_row_id
                , X_Transaction_Id    => l_mtl_trx_tbl(i).transaction_id
                , X_Organization_Id   => l_mtl_trx_tbl(i).organization_id
                , X_Cost_Element_Id   => 1
                , X_Level_Type        => 1
                , X_Last_Update_Date  => NVL(l_mtl_trx_tbl(i).transaction_date,sysdate)
                , X_Last_Updated_By   => l_user_id
                , X_Creation_Date     => NVL(l_mtl_trx_tbl(i).transaction_date,sysdate)
                , X_Created_By        => l_user_id
                , X_Inventory_Item_Id => l_mtl_trx_tbl(i).inventory_item_id
                , X_Transaction_Cost  => l_mtl_trx_tbl(i).transaction_cost
                , X_Value_Change      => null);
             IF (l_row_id is null or l_row_id < 0) THEN
                IF (l_debug = 1) THEN
                   print_debug('MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row returns error', 9);
                   print_debug('l_row_id = ' || l_row_id, 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV', 'INV_INSERT_COST_ERR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
             ELSE
                IF (l_debug = 1) THEN
                   print_debug('MTL_CST_TXN_COST_DETAILS_PKG.Insert_Row returns success', 9);
                END IF;
             END IF;
          END IF;
        END LOOP;
     END IF;

     -- if it's dropship deliver, then call the om API to update
     -- the shipped qty for the sales order with p_mode=1
     IF (p_logical_trx_type_code = G_LOGTRXCODE_DSDELIVER) THEN
        IF (l_debug = 1) THEN
           print_debug('Calling OE_DS_PVT.DropShipReceive', 9);
           print_debug('p_rcv_transaction_id = ' ||  p_mtl_trx_tbl(1).rcv_transaction_id, 9);
        END IF;
        l_progress := 460;
        l_dsreceive := OE_DS_PVT.DropShipReceive(
                                p_rcv_transaction_id => p_mtl_trx_tbl(1).rcv_transaction_id
                              , p_application_short_name  => 'INV'
                              , p_mode => 1);
        IF (l_debug = 1) THEN
           print_debug('After calling OE_DS_PVT.DropShipReceive', 9);
        END IF;

        IF (l_dsreceive = FALSE) THEN
           IF (l_debug = 1) THEN
              print_debug('OE_DS_PVT.DropShipReceive returns false', 9);
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_DS_UPDATE_ERROR');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           IF (l_debug = 1) THEN
              print_debug('OE_DS_PVT.DropShipReceive returns true', 9);
           END IF;
        END IF;

	--Update the DSdelievr transaction with the parent transaction id
	-- after we call the om API

	IF (l_debug = 1) THEN
           print_debug('update MMT of trx_id = ' || p_mtl_trx_tbl(1).transaction_id
                       || ' with parent trx id and trx batch id = '
                       || p_mtl_trx_tbl(1).transaction_id, 9);
        END IF;
        UPDATE mtl_material_transactions
	SET    parent_transaction_id = p_mtl_trx_tbl(1).transaction_id,
	       transaction_batch_id  = p_mtl_trx_tbl(1).transaction_id,
	       logical_transactions_created = 1,
	       logical_transaction = 1,
	       invoiced_flag = NULL,
	       trx_source_line_id = l_mtl_trx_tbl(1).trx_source_line_id,
               pm_cost_collected = 'N'
	WHERE  transaction_id = p_mtl_trx_tbl(1).transaction_id;

        IF (SQL%ROWCOUNT = 0) THEN
           IF (l_debug = 1) THEN
              print_debug('No MMT record is found for update with trx id:'
			  || p_mtl_trx_tbl(1).transaction_id ,9);
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_MMT_NOT_FOUND');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Call INV_TXNSTUB_PUB.postTransaction only for logical PO receipt record
        -- of true dropship
        IF (l_debug = 1) THEN
           print_debug('Before Calling INV_TXNSTUB_PUB.postTransaction', 9);
           print_debug('transaction_id = ' || p_mtl_trx_tbl(1).transaction_id, 9);
        END IF;

        INV_TXNSTUB_PUB.postTransaction
           ( p_header_id      => null
            ,p_transaction_id => p_mtl_trx_tbl(1).transaction_id
            ,x_return_status  => l_return_status);

        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           IF (l_debug = 1) THEN
              print_debug('INV_TXNSTUB_PUB.postTransaction returns error: ' || l_msg_data, 9);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           IF (l_debug = 1) THEN
              print_debug('INV_TXNSTUB_PUB.postTransaction returns unexpected error: ' || l_msg_data, 9);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
           IF (l_debug = 1) THEN
              print_debug('INV_TXNSTUB_PUB returns success', 9);
           END IF;
        END IF;

     END IF;

     -- If it's sales order issue or RMA,
     -- update the MMT transaction with the parent_transaction_id,
     -- transaction_batch_id, logical_transactions_created
     -- logical_transaction (1 - logical trx, 2 - physical trx) and invoiced_flag
     IF (p_logical_trx_type_code = G_LOGTRXCODE_RMASOISSUE) THEN
        l_progress := 470;
        IF (l_debug = 1) THEN
           print_debug('update MMT of trx_id = ' || p_mtl_trx_tbl(1).transaction_id
                       || ' with parent trx id and trx batch id = '
                       || p_mtl_trx_tbl(1).transaction_id, 9);
        END IF;
        UPDATE mtl_material_transactions
        SET    parent_transaction_id = p_mtl_trx_tbl(1).transaction_id,
               transaction_batch_id  = p_mtl_trx_tbl(1).transaction_id,
               trx_flow_header_id = p_trx_flow_header_id,
               logical_transactions_created = 1,
               logical_transaction = 2,
               invoiced_flag = null
        WHERE  transaction_id = p_mtl_trx_tbl(1).transaction_id;
        IF (SQL%ROWCOUNT = 0) THEN
           IF (l_debug = 1) THEN
              print_debug('No MMT record is found for update with trx id:'
                            || p_mtl_trx_tbl(1).transaction_id ,9);
           END IF;
           FND_MESSAGE.SET_NAME('INV', 'INV_MMT_NOT_FOUND');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


     -- if it's retroactive price update, Call price_update_insert API
     -- to insert into mtl_consumption_transactions
     IF (p_logical_trx_type_code = G_LOGTRXCODE_RETROPRICEUPD) THEN
        FOR i in 1..l_mtl_trx_tbl.COUNT LOOP
          IF (l_debug = 1) THEN
             print_debug('Calling INV_CONSUMPTION_TXN_PVT.price_update_insert', 9);
             print_debug('p_transaction_id = ' || l_mtl_trx_tbl(i).transaction_id, 9);
             print_debug('p_consumption_po_header_id = ' || l_mtl_trx_tbl(i).consumption_po_header_id, 9);
             print_debug('p_consumption_release_id = ' || l_mtl_trx_tbl(i).consumption_release_id, 9);
             print_debug('p_transaction_quantity = ' || l_mtl_trx_tbl(i).transaction_quantity, 9);
          END IF;

          l_progress := 480;
          INV_CONSUMPTION_TXN_PVT.price_update_insert(
                p_transaction_id           => l_mtl_trx_tbl(i).transaction_id
              , p_consumption_po_header_id => l_mtl_trx_tbl(i).consumption_po_header_id
              , p_consumption_release_id   => l_mtl_trx_tbl(i).consumption_release_id
              , p_transaction_quantity     => l_mtl_trx_tbl(i).transaction_quantity
              , p_po_distribution_id       => l_mtl_trx_tbl(i).PO_DISTRIBUTION_ID
              , x_msg_count                => l_msg_count
              , x_msg_data                 => l_msg_data
              , x_return_status            => l_return_status);

          IF (l_debug = 1) THEN
             print_debug('After calling price_update_insert, l_return_status = ' || l_return_status, 9);
          END IF;

          IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
             IF (l_debug = 1) THEN
                print_debug('price_update_insert returns error: ' || l_msg_data, 9);
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             IF (l_debug = 1) THEN
                print_debug('price_update_insert returns unexpected error: ' || l_msg_data, 9);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
             IF (l_debug = 1) THEN
                print_debug('price_update_insert returns success', 9);
             END IF;
          END IF;
        END LOOP;
     END IF;

     x_return_status := G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          ROLLBACK TO create_logical_transactions;

          IF (l_debug = 1) THEN
             print_debug('create_logical_transactions: Expected Error, l_progress = ' || l_progress, 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE),9);
             print_debug('Return Status :' || x_return_status, 9);
          END IF;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          ROLLBACK TO create_logical_transactions;

          IF (l_debug = 1) THEN
             print_debug('create_logical_transactions: Unexpected Error, l_progress = ' || l_progress, 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE),9);
             print_debug('Return Status :' || x_return_status, 9);
          END IF;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          ROLLBACK TO create_logical_transactions;

          IF (l_debug = 1) THEN
             print_debug('create_logical_transactions: Other Error, l_progress = ' || l_progress, 9);
             print_debug('SQL Error: ' || Sqlerrm(SQLCODE),9);
             print_debug('Return Status :' || x_return_status, 9);
          END IF;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                   FND_MSG_PUB.Add_Exc_Msg
                     (G_PKG_NAME, 'INV_LOGICAL_TRANSACTIONS_PUB');
          END IF;
  END create_logical_transactions;

  PROCEDURE create_deferred_log_txns_cp
    (errbuf               OUT    NOCOPY VARCHAR2,
     retcode              OUT    NOCOPY NUMBER,
     p_api_version        IN     NUMBER,
     p_start_date         IN     VARCHAR2,
     p_end_date           IN     VARCHAR2
     )
    IS
       l_ret                BOOLEAN;
       l_return_status      VARCHAR2(1);
       l_msg_data           VARCHAR2(2000);
       l_msg_count          NUMBER;
       l_failed             NUMBER := 0;
       l_success            NUMBER := 0;
       l_message            VARCHAR2(255);

       --Bug: 3632208. Removed the NVL around the start date and end date
       -- so that the index on transaction_date will be used. The start and
       -- end dates are mandatory. So, no need for the NVL.
       CURSOR deferred_transactions IS
	    SELECT transaction_id FROM
	    mtl_material_transactions
	    WHERE
	    logical_transactions_created = 2
	    AND transaction_date BETWEEN
           fnd_date.canonical_to_date(p_start_date)
       AND fnd_date.canonical_to_date(p_end_date);

  BEGIN
    -- Bug Number 3307070
  IF(
       (inv_control.get_current_release_level < INV_Release.Get_J_RELEASE_LEVEL)
    OR (CST_VersionCtrl_GRP.GET_CURRENT_RELEASE_LEVEL < CST_Release_GRP.GET_J_RELEASE_LEVEL )
    OR (OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110510' )
   )
   THEN
   print_debug('This function is not availiable without patchset J of INV,OM,and COSTING');
  	retcode := 2;
	fnd_message.set_name('INV', 'INV_CREATE_DEF_NOT_AVAILABLE');
	l_message := fnd_message.get;
	l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

  ELSE

   FOR l_txn_rec IN deferred_transactions LOOP

	l_return_status := g_ret_sts_success;
	l_msg_data := NULL;
	l_msg_count := 0;

	SAVEPOINT create_log_txn;

        BEGIN

	   UPDATE mtl_material_transactions
	     SET logical_transactions_created = 1
	     WHERE
	     transaction_id = l_txn_rec.transaction_id;

	   inv_logical_transactions_pub.create_logical_trx_wrapper
	     (  x_return_status         => l_return_status
		, x_msg_count           => l_msg_count
		, x_msg_data            => l_msg_data
		, p_api_version_number  => p_api_version
		, p_init_msg_lst        => fnd_api.g_true
		, p_transaction_id      => l_txn_rec.transaction_id
		);
	EXCEPTION
	   WHEN OTHERS THEN
	      l_return_status := G_RET_STS_UNEXP_ERROR;
	END;

	IF l_return_status = g_ret_sts_success THEN
	   l_success := l_success + 1;
	   print_debug('successfully processed txn id:'||l_txn_rec.transaction_id);
	   COMMIT;
	 ELSE
	   l_failed := l_failed + 1;
	   print_debug('Falied to process txn id:'||l_txn_rec.transaction_id ||
		       ' message '||l_msg_data);
	   ROLLBACK TO create_log_txn;
	END IF;
     END LOOP;

     print_debug(l_success||' successful '||l_failed||' failed.');

     IF l_failed > 0 THEN
	retcode := 3;
	fnd_message.set_name('INV', 'INV_CREATE_LOG_TXNS_WARN');
	fnd_message.set_token('FAIL_COUNT',''||l_failed);
	l_message := fnd_message.get;
	l_ret :=  FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);

      ELSE
	retcode := 1;
	fnd_message.set_name('INV', 'INV_CREATE_LOG_TXNS_SUCCESS');
	l_message := fnd_message.get;
	l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);
     END IF;
END IF;
  EXCEPTION
     WHEN OTHERS THEN
	retcode := 2;
	fnd_message.set_name('INV', 'INV_CREATE_LOG_TXNS_ERR');
	l_message := fnd_message.get;
	l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);

  END CREATE_DEFERRED_LOG_TXNS_CP;



  /*==========================================================================*
  | Procedure : CHECK_ACCOUNTING_PERIOD_CLOSE
    |
    |
    |
    | Description : This API  will deletermine if a current accounting
    |               period that is being closed has any transactions in
    |               mtl_material_transactions table that has any deferred
    |               transactions that have not been costed,and if it
    |               belongs to a transaction flow where the orgs operatinh
    |               unit is one of the intermediate nodes and so, will
    |               prevent the user from cosing the accounting period.
    |
    |
    |
    | Input Parameters :
    |
    |   p_api_version_number - API version number
    |
    |   p_init_msg_lst       - Whether initialize the error message list
    |                          or not
    |                          Should be fnd_api.g_false or fnd_api.g_true
    |
    |   p_organization_id     - Organziation Id of the org that is being
    |                           closed .
    |
    |   p_org_id - operating unit of the org that is being closed.
    |
    |   p_period_start_date    - Start date of the accounting period of the
    |                            organization that is being closed.
    |
    |   p_period_end_date    - End date of the accounting period of the
    |                            organization that is being closed.
    |
    | Output Parameters :
    |
    |   x_return_status      - fnd_api.g_ret_sts_success, if succeeded
    |
    |                          fnd_api.g_ret_sts_exc_error, if an expected
    |
    |                          error occurred
    |
    |                          fnd_api.g_ret_sts_unexp_error, if an
    |                          unexpected
    |                          eror occurred
    |
    |   x_msg_count          - Number of error message in the error message
    |
    |                          list
    |
    |   x_msg_data           - If the number of error message in the error
    |
    |                          message list is one, the error message is in
    |
    |                          this output parameter
    |   x_period_close       - This is a boolean which will decide whether
    |                           the accounting period can be closed or not
    *========================================================================*/

    PROCEDURE check_accounting_period_close
    (x_return_status              OUT NOCOPY  VARCHAR2
     , x_msg_count                  OUT NOCOPY  NUMBER
     , x_msg_data                   OUT NOCOPY  VARCHAR2
     , x_period_close               OUT nocopy  VARCHAR2
     , p_api_version_number         IN          NUMBER   := 1.0
     , p_init_msg_lst               IN          VARCHAR2 := G_FALSE
     , p_organization_id            IN NUMBER
     , p_org_id                     IN NUMBER
     , p_period_start_date          IN DATE
     , p_period_end_date            IN DATE
     )
    IS

       l_count NUMBER := 0;
       l_transaction_date DATE;
       l_api_version_number CONSTANT NUMBER := 1.0;
       l_in_api_version_number NUMBER := NVL(p_api_version_number, 1.0);
       l_api_name  CONSTANT VARCHAR2(30) := 'CHECK_ACCOUNTING_PERIOD_CLOSE';
       l_init_msg_lst VARCHAR2(1) := NVL(p_init_msg_lst, G_FALSE);

       CURSOR deferred_mmt_records IS
	  SELECT trx_flow_header_id, transaction_date FROM
	    mtl_material_transactions mmt WHERE costed_flag = 'N' AND
	    logical_transactions_created = 2;

    BEGIN

       x_period_close := 'Y';
       x_return_status := G_RET_STS_SUCCESS;

       IF (l_debug = 1) THEN
	  print_debug('Organization Id :' || p_organization_id, 9);
	  print_debug('OU Id :' || p_org_id, 9);
	  print_debug('Period Start Date= ' || p_period_start_date, 9);
	  print_debug('Period End Date = ' || p_period_end_date, 9);
       END IF;

       IF (p_organization_id IS NULL OR
	   p_period_start_date IS NULL OR p_period_end_date IS NULL) then
	  IF (l_debug = 1) THEN
	     print_debug('Invalid input parameters', 9);
	  END IF;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Before calling compatible API', 9);
       END IF;


       --  Standard call to check for call compatibility
       IF NOT fnd_api.compatible_api_call
	 (l_api_version_number, l_in_api_version_number, l_api_name, g_pkg_name) THEN
	  RAISE fnd_api.g_exc_unexpected_error;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('Before calling init API', 9);
       END IF;

       --  Initialize message list.
       IF fnd_api.to_boolean(l_init_msg_lst) THEN
	  fnd_msg_pub.initialize;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('After calling init API', 9);
       END IF;

       FOR deferred_trxs IN deferred_mmt_records LOOP

	  IF (l_debug = 1) THEN
	     print_debug('Inside the loop', 9);
	  END IF;

	  IF deferred_mmt_records%ROWCOUNT = 0 THEN

	     IF (l_debug = 1) THEN
		print_debug('No records with deferred flag',9);
		x_period_close := 'Y';
		x_return_status := G_RET_STS_SUCCESS;
		RETURN;
	     END IF;
	  END IF;

	  IF (l_debug = 1) THEN
	     print_debug('Inside the loop', 9);
	  END IF;

	    BEGIN
	       l_transaction_date :=
		 INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(deferred_trxs.transaction_date,p_organization_id);

	    EXCEPTION
	       WHEN others THEN
		  IF (l_debug = 1) THEN
		     print_debug('Timezone API returned error: ' || l_transaction_date, 9);
		     RAISE fnd_api.g_exc_unexpected_error;
		  END IF;

	    END;

	    IF (l_debug = 1) THEN
	       print_debug('Transaction date' || l_transaction_date, 9);
	    END IF;

	    IF (l_debug = 1) THEN
	       print_debug('Trx Flow Header Id'||
			   deferred_trxs.trx_flow_header_id , 9);
	       print_debug('Transaction_date'||
			   deferred_trxs.transaction_date, 9);
	       print_debug('Transaction_date with LE timezone'|| l_transaction_date, 9);
	    END IF;

	     BEGIN
		SELECT COUNT(1) into l_count
		  FROM mtl_transaction_flow_headers mtfh,
		  mtl_transaction_flow_lines mtfl
		  WHERE (l_transaction_date BETWEEN p_period_start_date AND
			 p_period_end_date) AND
		  mtfh.header_id = deferred_trxs.trx_flow_header_id AND
		  mtfh.new_accounting_flag = 'Y' AND
		  mtfh.header_id = mtfl.header_id AND
		  (mtfl.from_organization_id = p_organization_id OR
		   mtfl.to_organization_id = p_organization_id );
	     EXCEPTION
		WHEN no_data_found THEN

		   IF (l_debug = 1) THEN
		      print_debug('Check Account Period Close: Cannot find any lines', 9);
		      x_period_close := 'Y';
		      x_return_status := G_RET_STS_SUCCESS;
		   END IF;

	     END;

	     IF l_count > 0 THEN
		x_period_close := 'N';
		print_debug('Check Account Period Close: Count > 0', 9);
		x_return_status := G_RET_STS_SUCCESS;
		RETURN;
	      ELSIF l_count = 0 THEN
		x_period_close := 'Y';
		print_debug('Check Account Period Close: Count = 0', 9);
		x_return_status := G_RET_STS_SUCCESS;
	      ELSE
		x_period_close := 'N';
		x_return_status := G_RET_STS_UNEXP_ERROR;
		print_debug('Check Account Period Close: Count incorrect', 9);
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

       END LOOP;

       IF (l_debug = 1) THEN
	  print_debug('After the loop', 9);
	  print_debug('Period Close' || x_period_close, 9);
	  print_debug('Return Status' || x_return_status , 9);
       END IF;


       /******** Rather than doing it for 1 record at a time, we can do it a
       little differently. Instead of converting the transaction_date to
	 the legal entities timezone, we can add the difference between
	 the transaction_date in the server time and the legal entities
	 time to the period start and the period end date.

	 Say for example,
	 Period start date is 'Jun 01 2003, 00:00:00
	 Period end date is 'Jun 30 2003, 23:59:59
	 Transaction Date is 'Jun 30 2003, 10:50:00

	 Say if the Transaction date if coverted to the Legal Entity's
	 time zone is Jun 31 2003, 00:50:00 (Trx_date + 14).
	 To achieve the same result, we can subtract the period start
	 date and the period end date by the same factor, which in this
	 case is 14 hours.

	 So,
	 Jun 01 2003, 00:00:00 > Jun 30 2003, 10:50:00 >= Jun 30 2003,
	 23:59:59
	 When the transaction_date is converted to legal entitys
	 timezone, it will beccome,
	 Jun 01 2003, 00:00:00 > Jun 31 2003, 00:50:00 >= Jun 30 2003,

	 23:59:59

	 It is the same as,

	 May 31 2003, 10:00:00 > Jun 30 2003, 10:50:00 >=
	 Jun 30 2003, 09:59:59

	 l_period_start_date :=
	 INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(p_period_start_date,p_organization_id);
	 l_period_end_date :=
	 INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(p_period_end_date,p_organization_id);

	 BEGIN
	   SELECT COUNT(1) into l_count
	 FROM
	 mtl_material_transactions mmt,
	 mtl_transaction_flow_headers mtfh,
	 mtl_transaction_flow_lines mtfl
	 WHERE (mmt.transaction_date BETWEEN
	 l_period_start_date AND l_period_end_date) AND
	 mmt.logical_transactions_created = 2 AND
	 mmt.trx_flow_header_id = mtfh.header_id AND
	 mtfh.new_accounting_flag = 'Y' AND
	 mtfh.header_id = mtfl.header_id AND
	 (mtfl.from_organization_id = p_organziation_id OR
	 mtfl.to_organization_id = p_organziation_id );
	 EXCEPTION
	 WHEN no_data_found THEN
	 IF (l_debug = 1) THEN
	 print_debug('Check Account Period Close: Cannot find any lines', 9);
	 x_period_close := 'Y';
	 x_return_status := G_RET_STS_SUCCESS;
	 END IF;

	 END;

	 IF l_count > 0 THEN
	 x_period_close := 'N';
	 print_debug('Check Account Period Close: Count > 0', 9);
	 x_return_status := G_RET_STS_SUCCESS;
	 ELSIF l_count = 0 THEN
	 x_period_close := 'Y';
	 print_debug('Check Account Period Close: Count = 0', 9);
	 x_return_status := G_RET_STS_SUCCESS;
	 ELSE
	 x_period_close := 'N';
	 x_return_status := G_RET_STS_UNEXP_ERROR;
	 print_debug('Check Account Period Close: Count incorrect', 9);
	 RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
	 *******/

	 EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;

	  IF (l_debug = 1) THEN
	     print_debug('Check Account Period Close: Expected Error', 9);
	     print_debug('SQL Error: ' || Sqlerrm(SQLCODE),9);
	     print_debug('Return Status :' || x_return_status, 9);
	  END IF;

	  FND_MSG_PUB.count_and_get
	    (p_count => x_msg_count, p_data => x_msg_data);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	  IF (l_debug = 1) THEN
	     print_debug('Check Account Period Close: Unexpected Error', 9);
	     print_debug('SQL Error: ' || Sqlerrm(SQLCODE),9);
	     print_debug('Return Status :' || x_return_status, 9);
	  END IF;

	  FND_MSG_PUB.count_and_get
	    (p_count => x_msg_count, p_data => x_msg_data);

       WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	  IF (l_debug = 1) THEN
	     print_debug('Check Account Period Close: Other Error', 9);
	     print_debug('SQL Error: ' || Sqlerrm(SQLCODE),9);
	     print_debug('Return Status :' || x_return_status, 9);
	  END IF;

	  FND_MSG_PUB.count_and_get
	    (p_count => x_msg_count, p_data => x_msg_data);

	  IF FND_MSG_PUB.check_msg_level
	    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     FND_MSG_PUB.Add_Exc_Msg
	       (G_PKG_NAME, 'INV_LOGICAL_TRANSACTIONS_PUB');
	  END IF;

    END  CHECK_ACCOUNTING_PERIOD_CLOSE;

    --deferred cogs NEW api for cogs recognition
   PROCEDURE create_cogs_recognition ( x_return_status OUT nocopy NUMBER,
					x_error_code OUT nocopy VARCHAR2,
					x_error_message OUT nocopy VARCHAR2)
      IS
	 l_count NUMBER :=0;

    BEGIN
       x_return_status :=0;
       --Validate the inventory item id.
       SELECT COUNT(1) INTO l_count FROM mtl_cogs_recognition_temp crtt
	 WHERE INVENTORY_ITEM_ID IS NOT NULL
	   AND NOT EXISTS (
			   SELECT NULL
			   FROM MTL_SYSTEM_ITEMS MSI
			   WHERE MSI.INVENTORY_ITEM_ID = crtt.INVENTORY_ITEM_ID
			   AND MSI.ORGANIZATION_ID = crtt.ORGANIZATION_ID
			   AND MSI.INVENTORY_ITEM_FLAG = 'Y');

	 IF l_count <> 0 THEN
	    IF (l_debug = 1) THEN
	       print_debug('CREATE_COGS_RECOGNITION:Validating specified item 1' || l_count || 'failed', 9);
	    END IF;
	    fnd_message.set_name('INV', 'inv_int_itmcode');
	    x_error_code := fnd_message.get;
	    fnd_message.set_name('INV', 'inv_int_itmexp');
	    x_error_message := fnd_message.get;
	    x_return_status := -1;
	    RETURN;
	 END IF;

	 SELECT COUNT(1)  INTO l_count FROM mtl_cogs_recognition_temp

	   WHERE INVENTORY_ITEM_ID IS NULL;

	   IF l_count <> 0 THEN
	      IF (l_debug = 1) THEN
		 print_debug('CREATE_COGS_RECOGNITION:Validating specified item 1' || l_count || 'failed', 9);
	      END IF;
	      fnd_message.set_name('INV', 'INV_INT_ITMCODE');
	      x_error_code := fnd_message.get;
	      fnd_message.set_name('INV', 'inv_int_itmexp');
	      x_error_message := fnd_message.get;
	      x_return_status := -1;
	      RETURN;
	   END IF;
	   --validate subinventory code.


	   SELECT COUNT(1)  INTO l_count FROM mtl_cogs_recognition_temp crtt

	     WHERE   TRANSACTION_ACTION_ID NOT IN (24, 30)
	     AND subinventory_code IS NOT null
	       AND NOT EXISTS (
				  SELECT NULL
				  FROM MTL_SECONDARY_INVENTORIES MSI
				  WHERE MSI.ORGANIZATION_ID = crtt.ORGANIZATION_ID
				  AND MSI.SECONDARY_INVENTORY_NAME = crtt.SUBINVENTORY_CODE
				  AND NVL(MSI.DISABLE_DATE,SYSDATE+1) > Sysdate);

		      IF l_count <> 0 THEN
			 IF (l_debug = 1) THEN
			    print_debug('CREATE_COGS_RECOGNITION"Validating specified item 1' || l_count || 'failed',  9);
			 END IF;
			 fnd_message.set_name('INV','inv_int_subcode' );
			 x_error_code := fnd_message.get;
			 fnd_message.set_name('INV', 'INV_INT_SUBEXP');
			 x_error_message := fnd_message.get;
			 x_return_status := -1;
			 RETURN;
		      END IF;

		      --Validating restricted subinventories



			SELECT COUNT(1)  INTO l_count  FROM mtl_cogs_recognition_temp crtt

			  where SUBINVENTORY_CODE IS NOT NULL
			    AND NOT EXISTS (
					    SELECT NULL
					    FROM MTL_ITEM_SUB_INVENTORIES MIS,
					    MTL_SYSTEM_ITEMS MSI
					    WHERE MSI.ORGANIZATION_ID = crtt.ORGANIZATION_ID
					    AND MSI.INVENTORY_ITEM_ID = crtt.INVENTORY_ITEM_ID
					    AND MSI.RESTRICT_SUBINVENTORIES_CODE = 1
					    AND MIS.ORGANIZATION_ID = crtt.ORGANIZATION_ID
					    AND MIS.INVENTORY_ITEM_ID = crtt.INVENTORY_ITEM_ID
					    AND MIS.ORGANIZATION_ID = MSI.ORGANIZATION_ID
					    AND MIS.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
					    AND MIS.SECONDARY_INVENTORY = crtt.SUBINVENTORY_CODE
					    UNION
					    SELECT NULL
					    FROM MTL_SYSTEM_ITEMS ITM
					    WHERE ITM.ORGANIZATION_ID = crtt.ORGANIZATION_ID
					    AND ITM.INVENTORY_ITEM_ID = crtt.INVENTORY_ITEM_ID
					    AND ITM.RESTRICT_SUBINVENTORIES_CODE = 2);
			  IF l_count <> 0 THEN
			     IF (l_debug = 1) THEN
				print_debug('CREATE_COGS_RECOGNITION:Validating specified item 3' || l_count || 'failed', 9);
			     END IF;
			     fnd_message.set_name('INV','INV_INT_SUBCODE');
			     x_error_code := fnd_message.get;
			     fnd_message.set_name('INV','inv_int_subcode');
			     x_error_message := fnd_message.get;
			     x_return_status := -1;
			     RETURN;
			  END IF;

			  SELECT COUNT(1)   INTO l_count FROM mtl_cogs_recognition_temp crtt

			    where transaction_type_id <> 10008
			    OR transaction_action_id <> 36
			    OR transaction_source_type_id <>2;

			  IF l_count <> 0 THEN
			     IF (l_debug = 1) THEN
				print_debug('CREATE_COGS_RECOGNITION:Validating specified item 4' || l_count || 'failed', 9);
			     END IF;
			     --fnd_message.set_name('INV','INV_INT_SUBCODE');
			     x_error_code := 'Invalid Transaction Source-Action-TYPE combination';
			     --fnd_message.set_name('INV','inv_int_subcode');
			     x_error_message := 'Invalid Transaction Source-Action-TYPE combination';
			     x_return_status := -1;
			     RETURN;
			  END IF;

			  --bulk insert into mmt.


			  INSERT INTO mtl_material_transactions
			    (TRANSACTION_ID,
			     ORGANIZATION_ID,
			     INVENTORY_ITEM_ID,
			     REVISION,
			     SUBINVENTORY_CODE,
			     LOCATOR_ID,
			     TRANSACTION_TYPE_ID,
			     TRANSACTION_ACTION_ID,
			     TRANSACTION_SOURCE_TYPE_ID,
			     TRANSACTION_SOURCE_ID,
			     TRANSACTION_SOURCE_NAME,
			     TRANSACTION_QUANTITY,
			     TRANSACTION_UOM,
			     PRIMARY_QUANTITY,
			     TRANSACTION_DATE,
			     ACCT_PERIOD_ID,
			     DISTRIBUTION_ACCOUNT_ID,
			     COSTED_FLAG,
			     ACTUAL_COST,
			     INVOICED_FLAG,
			     TRANSACTION_COST,
			     CURRENCY_CODE,
			     CURRENCY_CONVERSION_RATE,
			     CURRENCY_CONVERSION_TYPE,
			     CURRENCY_CONVERSION_DATE,
			     PM_COST_COLLECTED,
			     TRX_SOURCE_LINE_ID,
			     SOURCE_CODE,
			     SOURCE_LINE_ID,
			     TRANSFER_ORGANIZATION_ID,
			     TRANSFER_SUBINVENTORY,
			     TRANSFER_LOCATOR_ID,
			     COST_GROUP_ID,
			     TRANSFER_COST_GROUP_ID,
			     PROJECT_ID,
			     TASK_ID,
			     TO_PROJECT_ID,
			     TO_TASK_ID,
			    SHIP_TO_LOCATION_ID,
			    TRANSACTION_MODE,
			    TRANSACTION_BATCH_ID,
			    TRANSACTION_BATCH_SEQ,
			    LPN_ID,
			    parent_transaction_id,
			    last_update_date,
			    last_updated_by,
			    creation_date,
			    created_by,
			    transaction_set_id,
			    expenditure_type,
			    pa_expenditure_org_id,
			    opm_costed_flag,
			    cogs_recognition_percent,
			    so_issue_account_type,
			    logical_transaction)
			    SELECT
			    crtt.transaction_id,
			    crtt.ORGANIZATION_ID,
			    crtt.INVENTORY_ITEM_ID,
			    crtt.REVISION,
			    crtt.SUBINVENTORY_CODE,
			    crtt.LOCATOR_ID,
			    crtt.transaction_type_id,
			    crtt.transaction_action_id,
			    crtt.transaction_source_type_id,
			    crtt.transaction_source_id,
			    crtt.transaction_source_name,
			    crtt.transaction_quantity,
			    crtt.TRANSACTION_UOM,
			    crtt.primary_quantity,
			    crtt.TRANSACTION_DATE,
			    crtt.acct_period_id,
			    crtt.distribution_account_id,
			    crtt.COSTED_FLAG,
			    crtt.ACTUAL_COST,
			    crtt.INVOICED_FLAG,
			    crtt.TRANSACTION_COST,
			    crtt.CURRENCY_CODE,
			    crtt.CURRENCY_CONVERSION_RATE,
			    crtt.CURRENCY_CONVERSION_TYPE,
			    crtt.CURRENCY_CONVERSION_DATE,
			    crtt.pm_cost_collected,--added pm_cost_collected flag
			    crtt.trx_source_line_id,
			    crtt.SOURCE_CODE,
			    crtt.SOURCE_LINE_ID,
			    crtt.transfer_ORGANIZATION_id,
			    crtt.transfer_SUBINVENTORY,
			    crtt.transfer_LOCATOR_id,
			    crtt.cost_group_id,
			    crtt.TRANSFER_COST_GROUP_ID,
			    crtt.project_id,
			    crtt.task_id,
			    crtt.TO_PROJECT_ID,
			    crtt.TO_TASK_ID,
			    crtt.SHIP_TO_LOCATION_ID,
			    crtt.TRANSACTION_MODE,
			    crtt.TRANSACTION_BATCH_ID,
			    crtt.TRANSACTION_BATCH_SEQ,
			    crtt.LPN_ID,
			    crtt.transaction_id,
			    crtt.last_update_date,
			    crtt.last_updated_by,
			    crtt.creation_date,
			    crtt.created_by,
			    crtt.transaction_set_id,
			    crtt.expenditure_type,
			    crtt.pa_expenditure_org_id,
			    crtt.opm_costed_flag,
			    crtt.cogs_recognition_percent,
			    crtt.so_issue_account_type ,
			    crtt.logical_transaction
			    FROM  mtl_cogs_recognition_temp crtt
			    ;
			  x_return_status := 0;
			  RETURN;
    EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug('CREATE_COGS_RECOGNITION:Error in insert', 9);
	  END IF;
	  x_error_code := 'Error in insert';
	  x_error_message := 'Error in INSERT';
	  x_return_status := -1;
	  RETURN ;
   END create_cogs_recognition;

  /**
  * OPM INVCONV  rseshadr/umoogala  15-Feb-2005
  * added procedure for creating logical trx
  * for any process/discrete transfers with in-transit.
  * No logical txns will be created for direct transfers
  **/
  PROCEDURE create_opm_disc_logical_trx (
      x_return_status       OUT NOCOPY VARCHAR2
    , x_msg_count           OUT NOCOPY NUMBER
    , x_msg_data            OUT NOCOPY VARCHAR2

    , p_api_version_number  IN         NUMBER := 1.0
    , p_init_msg_lst        IN         VARCHAR2 := G_FALSE
    , p_transaction_id      IN         NUMBER
    , p_transaction_temp_id IN         NUMBER
  )
  IS
    l_api_version_number         CONSTANT NUMBER := 1.0;
    l_in_api_version_number      NUMBER := NVL(p_api_version_number, 1.0);
    l_api_name                   CONSTANT VARCHAR2(30) := 'CREATE_OPM_DISC_LOGICAL_TRX';
    l_init_msg_lst               VARCHAR2(1) := NVL(p_init_msg_lst, G_FALSE);

    l_return_status              VARCHAR2(1);
    l_msg_data                   VARCHAR2(240);
    l_msg_count                  BINARY_INTEGER;
    l_account_period_id          BINARY_INTEGER;
    l_organization_id            BINARY_INTEGER;
    l_xfer_organization_id       BINARY_INTEGER;
    l_transaction_date           DATE;
    l_cost_group_id              BINARY_INTEGER;
    l_xfer_cost_group_id         BINARY_INTEGER;
    l_requisition_line_id        BINARY_INTEGER;
    l_expenditure_type           VARCHAR2(240);
    l_distribution_account_id    BINARY_INTEGER;
    l_curr_conversion_rate       NUMBER;
    l_pri_uom_code               mtl_material_transactions.transaction_uom%TYPE;
    l_sec_uom_code               mtl_material_transactions.secondary_uom_code%TYPE;
    l_sec_qty                    mtl_material_transactions.secondary_transaction_quantity%TYPE;
    l_transfer_price             mtl_material_transactions.transfer_price%TYPE;
    l_transportation_cost        mtl_material_transactions.transportation_cost%TYPE;
    l_xfer_transaction_id        mtl_material_transactions.transfer_transaction_id%TYPE;
    l_snd_txn_qty                mtl_material_transactions.transaction_quantity%TYPE;
    l_snd_txn_uom                mtl_material_transactions.transaction_uom%TYPE;
    l_snd_pri_qty                mtl_material_transactions.primary_quantity%TYPE;
    l_snd_pri_uom                mtl_system_items_b.primary_uom_code%TYPE;
    l_snd_subinv                 mtl_material_transactions.subinventory_code%TYPE;
    l_pri_qty                    mtl_material_transactions.primary_quantity%TYPE;
    l_pri_uom                    mtl_system_items_b.primary_uom_code%TYPE;
    l_owner_pri_uom              mtl_system_items_b.primary_uom_code%TYPE;
    l_pri_uom_rate               NUMBER;
    l_snd_sec_qty                mtl_material_transactions.secondary_transaction_quantity%TYPE;
    l_snd_sec_uom                mtl_system_items_b.secondary_uom_code%TYPE;
    l_sec_uom                    mtl_system_items_b.secondary_uom_code%TYPE;
    l_tracking_quantity_ind      mtl_system_items_b.tracking_quantity_ind%TYPE;
    l_secondary_default_ind      mtl_system_items_b.secondary_default_ind%TYPE;
    l_transaction_uom            mtl_material_transactions.transaction_uom%TYPE;
    l_item_id                    mtl_material_transactions.inventory_item_id%TYPE;

    l_currency_code              mtl_material_transactions.currency_code%TYPE;
    l_owner_currency_code          mtl_material_transactions.currency_code%TYPE;
    -- l_snd_ou_id                  BINARY_INTEGER;
    -- l_snd_sob_id                 BINARY_INTEGER;
    l_ou_id                      BINARY_INTEGER;
    l_sob_id                     BINARY_INTEGER;

    l_owner_org_id               BINARY_INTEGER;
    l_owner_pri_qty              NUMBER;
    l_owner_ou_id                BINARY_INTEGER;
    l_owner_sob_id               BINARY_INTEGER;

    l_procedure_name             VARCHAR2(64) := 'create_opm_disc_logical_trx';
    l_skip_qty_conv              VARCHAR2(1) := 'N';
    l_costed_flag                VARCHAR2(1) := NULL;
    l_opm_costed_flag            VARCHAR2(1) := NULL;

    l_transaction_source_type_id BINARY_INTEGER;
    l_transaction_action_id      BINARY_INTEGER;
    l_parent_transaction_id      BINARY_INTEGER;
    l_transaction_id             BINARY_INTEGER;
    l_transaction_qty            NUMBER;
    l_qty_ratio                  NUMBER;

    l_logical_trx_id             BINARY_INTEGER;
    l_logical_trx_type_id        BINARY_INTEGER;
    l_logical_trx_action_id      BINARY_INTEGER;
    l_logical_trx_src_type_id    BINARY_INTEGER;


    l_fobpoint                   BINARY_INTEGER;
    l_pd_txfr_ind                BINARY_INTEGER;

    l_stmt_num                   BINARY_INTEGER;
    l_are_qties_valid            BINARY_INTEGER;

    e_p_d_xfer_na                EXCEPTION;
    e_uom_conversion_error       EXCEPTION;
    e_currency_conversion_error  EXCEPTION;

    -- Bug 5018698: Following columns have been added.
    l_transaction_source_id      mtl_material_transactions.transaction_source_id%TYPE;
    l_transaction_source_name    mtl_material_transactions.transaction_source_name%TYPE;
    l_trx_source_line_id         mtl_material_transactions.trx_source_line_id%TYPE;
    l_source_code                mtl_material_transactions.source_code%TYPE;
    l_source_line_id             mtl_material_transactions.source_line_id%TYPE;

    l_trx_source_delivery_id     mtl_material_transactions.trx_source_delivery_id%TYPE;
    l_picking_line_id            mtl_material_transactions.picking_line_id%TYPE;
    l_pick_slip_number           mtl_material_transactions.pick_slip_number%TYPE;
    l_pick_strategy_id           mtl_material_transactions.pick_strategy_id%TYPE;
    l_pick_rule_id               mtl_material_transactions.pick_rule_id%TYPE;
    l_pick_slip_date             mtl_material_transactions.pick_slip_date%TYPE;
    l_so_issue_account_type      mtl_material_transactions.so_issue_account_type%TYPE;
    l_ship_to_location_id        mtl_material_transactions.ship_to_location_id%TYPE;

    l_invoiced_flag              mtl_material_transactions.invoiced_flag%TYPE;

    l_snd_currency_code           mtl_material_transactions.currency_code%TYPE;
    l_currency_conversion_rate    mtl_material_transactions.currency_conversion_rate%TYPE;
    l_currency_conversion_type    mtl_material_transactions.currency_conversion_type%TYPE;
    l_currency_conversion_date    mtl_material_transactions.currency_conversion_date%TYPE;

    l_intercompany_currency_code  mtl_material_transactions.intercompany_currency_code%TYPE;
    l_intercompany_cost           mtl_material_transactions.intercompany_cost%TYPE;
    l_intercompany_pricing_option mtl_material_transactions.intercompany_pricing_option%TYPE;

    -- End Bug 5018698

    l_snd_trp_cost                mtl_material_transactions.transportation_cost%TYPE;

    CURSOR c_process_flag(p_organization_id BINARY_INTEGER)
    IS
      SELECT NVL(mp.process_enabled_flag,'N')
        FROM mtl_parameters mp
       WHERE mp.organization_id = p_organization_id;


    CURSOR c_from_to_ou(p_organizaiton_id BINARY_INTEGER, p_xfer_organization_id BINARY_INTEGER)
    IS
    SELECT org.operating_unit,  org.set_of_books_id,
           xorg.operating_unit, xorg.set_of_books_id
      FROM org_organization_definitions org, org_organization_definitions xorg
     WHERE org.organization_id  = p_organizaiton_id
       AND xorg.organization_id = p_xfer_organization_id
    ;

  BEGIN

    IF (l_debug = 1)
    THEN
       print_debug(l_procedure_name, 9);
       print_debug('p_api_version_number = ' || p_api_version_number, 9);
       print_debug('l_in_api_version_number = ' || l_in_api_version_number, 9);
       print_debug('p_init_msg_lst = ' || p_init_msg_lst, 9);
       print_debug('l_init_msg_lst = ' || l_init_msg_lst, 9);
       print_debug('p_transaction_id = ' || p_transaction_id, 9);
       print_debug('p_transaction_temp_id = ' || p_transaction_temp_id, 9);
    END IF;

    --  Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version_number,
               l_in_api_version_number, l_api_name, g_pkg_name)
    THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --  Initialize message list.
    IF fnd_api.to_boolean(l_init_msg_lst)
    THEN
       fnd_msg_pub.initialize;
    END IF;


    l_stmt_num := 10;

    SELECT mmt.inventory_item_id,
           mmt.organization_id, mmt.transfer_organization_id, mmt.transaction_date,
           mmt.transaction_source_type_id, mmt.transaction_action_id, mmt.fob_point,
           mmt.cost_group_id, mmt.transfer_cost_group_id,
           mmt.transaction_quantity, mmt.transaction_uom,
           mmt.transfer_price, mmt.transportation_cost,
           mmt.transfer_transaction_id, msi.primary_uom_code
      INTO l_item_id,
           l_organization_id, l_xfer_organization_id, l_transaction_date,
           l_transaction_source_type_id, l_transaction_action_id, l_fobpoint,
           l_xfer_cost_group_id, l_cost_group_id, -- yes, we've to flip CGs
           l_transaction_qty, l_transaction_uom,
           l_transfer_price, l_transportation_cost,
           l_xfer_transaction_id, l_pri_uom
      FROM mtl_material_transactions mmt, mtl_system_items_b msi
     WHERE mmt.transaction_id = p_transaction_id
       AND mmt.inventory_item_id = msi.inventory_item_id
       AND mmt.organization_id   = msi.organization_id
    ;

    l_stmt_num := 20;
    SELECT MOD(SUM(DECODE(process_enabled_flag, 'Y', 1, 2)), 2)
      INTO l_pd_txfr_ind
      FROM mtl_parameters mp
     WHERE mp.organization_id = l_organization_id
        OR mp.organization_id = l_xfer_organization_id;

    IF l_pd_txfr_ind <> 1
    THEN
      RAISE e_p_d_xfer_na;
    END IF;


    IF (l_debug = 1) THEN
      print_debug(l_procedure_name || 'transaction_source_type_id = ' || l_transaction_source_type_id ||
                                      ' transaction_action_id = ' || l_transaction_action_id ||
                                      ' FOB Point = ' || l_fobpoint, 9);
      print_debug(l_procedure_name || 'org/xferOrg: ' || l_organization_id || '/' ||
                   l_xfer_organization_id || ' transfer price: ' || l_transfer_price, 9);
    END IF;

    /**
    * rseshadr -
    * Determine if a logical trx needs to be created
    * if so, also determine who owns it
    * ownership of the logical trx is based on the fob point
    * fobpoint:  1 (shipping)
    *  Receiver is owner of intransit and hence owns the logical trx
    *  The logical trx is created along with the shipping trx
    * fobpoint:  2 (receiving)
    *  Shipper is owner of intransit and owns the logical trx
    *  The logical trx is created along with the receiving trx
    */

    l_stmt_num := 30;
    IF( (l_fobpoint = G_FOB_RECEIVING AND l_transaction_action_id = G_ACTION_INTRANSITSHIPMENT) OR
        (l_fobpoint = G_FOB_SHIPPING AND l_transaction_action_id = G_ACTION_INTRANSITRECEIPT) )
    THEN
      /** No logical trx is required, return */
      x_return_status := 'S';
      x_msg_data := 'No Logical Transaction is required';
      print_debug(l_procedure_name || ': No Logical Transaction is required', 9);
      RETURN;
    END IF;

    print_debug(l_procedure_name || ': setting logical txns', 9);

    <<ASSIGN_LOGICAL_TXN_TYPES>>
    CASE
      WHEN (l_fobpoint = 1 AND l_transaction_action_id = G_ACTION_INTRANSITSHIPMENT)
      THEN
        l_owner_org_id            := l_xfer_organization_id;
        l_logical_trx_action_id   := G_ACTION_LOGICALINTRECEIPT;

        CASE l_transaction_source_type_id

          WHEN G_SOURCETYPE_INVENTORY
          THEN
            --
            -- FOB = Shipping, source = inventory, Action = Intransit Shipment
            -- set trx type to 'Logical Intransit Receipt (59)'
            --
            l_logical_trx_src_type_id := G_SOURCETYPE_INVENTORY;
            l_logical_trx_type_id     := G_TYPE_LOGL_INTORG_INTRECEIPT;

          WHEN G_SOURCETYPE_INTORDER
          THEN
            --
            -- FOB = Shipping, source = Int. Order, Action = Intransit Shipment
            -- set trx type to 'Logical Intransit Shipment (65)'
            --
            l_logical_trx_src_type_id := G_SOURCETYPE_INTREQ;
            l_logical_trx_type_id     := G_TYPE_LOGL_INTREQ_INTRECEIPT;

          ELSE NULL;

        END CASE;

      WHEN ( l_fobpoint = 2 AND l_transaction_action_id = G_ACTION_INTRANSITRECEIPT )
      THEN

        l_owner_org_id          := l_xfer_organization_id;
        l_logical_trx_action_id := G_ACTION_LOGICALINTSHIPMENT;

        CASE l_transaction_source_type_id

          WHEN G_SOURCETYPE_INVENTORY
          THEN
            --
            -- FOB = Receipt, source = inventory, Action = Intransit Receipt
            -- set trx type to 'Logical Intransit Receipt (59)'
            --
            l_logical_trx_src_type_id := G_SOURCETYPE_INVENTORY;
            l_logical_trx_type_id     := G_TYPE_LOGL_INTORG_INTSHIPMENT;

          WHEN G_SOURCETYPE_INTREQ
          THEN
            --
            -- FOB = Shipping, source = Int. Req, Action = Intransit Shipment
            -- set trx type to 'Logical Intransit Receipt (76)'
            --
            l_logical_trx_src_type_id := G_SOURCETYPE_INTORDER;
            l_logical_trx_type_id     := G_TYPE_LOGL_INTORD_INTSHIPMENT;

        END CASE;

      ELSE
        IF (l_debug = 1)
        THEN
          print_debug(l_procedure_name || 'before raise no_data_found. Invalid trx passed', 9);
        END IF;
        RAISE no_data_found;

    END CASE ASSIGN_LOGICAL_TXN_TYPES;

    IF (l_debug = 1) THEN
      print_debug(l_procedure_name || ': Logical Txn is, Source: ' || l_logical_trx_src_type_id ||
                                      ' Action: ' || l_logical_trx_action_id ||
                                      ' Type: ' || l_logical_trx_type_id);
    END IF;

    --
    -- Since the logical trx will be created against *Receiving* orgs, we have
    -- to do some conversions if necessary.
    -- Get Accounting Period
    -- Transaction Qty to primary and secondary UOMs.
    -- Transfer Price should be converted to Receiving Orgs currency
    --

    IF (l_debug = 1) THEN
      print_debug(l_procedure_name || ': getting accounting period for org: ' || l_owner_org_id ||
        ' on txn date: ' || l_transaction_date);
    END IF;

    /** Get the account period Id of the owner org */
    l_stmt_num := 40;
    GET_ACCT_PERIOD(
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      x_acct_period_id   => l_account_period_id,
      p_organization_id  => l_owner_org_id,
      p_transaction_date => l_transaction_date
      );

    IF (l_return_status <> g_ret_sts_success)
    THEN
      print_debug(l_procedure_name || ': Failed to get acct period id for org:'||
        l_organization_id ||' message '||l_msg_data);
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      RETURN;
    END IF;

    /********************************************************************
    * convert the Transaction Qty to the owner_Org's Primary UOM and
    * if necessary, secondary UOM.
    * Items might have different primary UOM in different orgs (correct?).
    * So, first converty the trx qty from trx uom to logical transactions
    * owner_Org's primary UOM.
    * Then converty the primary to secondary, if necessary.
    *********************************************************************/

    l_stmt_num := 90;
    IF l_fobpoint = G_FOB_RECEIVING
    THEN
      --
      -- Get the details from shipping txn since this logical txn is for
      -- shipping org
      --
      IF (l_debug = 1) THEN
        print_debug(l_procedure_name || ': FOB Receipt. So, populating transfer_price from shipping txn');
      END IF;

      l_stmt_num := 60;
      SELECT mmt.transfer_price,
             mmt.transaction_quantity, mmt.transaction_uom,
             mmt.primary_quantity, msi.primary_uom_code,
             mmt.secondary_transaction_quantity, mmt.secondary_uom_code,
             mmt.subinventory_code,
	     -- Bug 5018698: Following columns have been added.
	     mmt.transaction_source_id, mmt.transaction_source_name, mmt.trx_source_line_id,
	     mmt.source_code, mmt.source_line_id,
	     mmt.trx_source_delivery_id, mmt.picking_line_id, mmt.pick_slip_number,
	     mmt.pick_strategy_id, mmt.pick_rule_id, mmt.pick_slip_date,
	     mmt.so_issue_account_type, mmt.invoiced_flag,
             mmt.currency_code, mmt.currency_conversion_rate,
             mmt.currency_conversion_type, mmt.currency_conversion_date,
             mmt.intercompany_currency_code, mmt.intercompany_cost,
             mmt.intercompany_pricing_option,
	     mmt.ship_to_location_id, mmt.transportation_cost
        INTO l_transfer_price,
             l_snd_txn_qty, l_snd_txn_uom,
             l_snd_pri_qty, l_snd_pri_uom,
             l_snd_sec_qty, l_snd_sec_uom,
             l_snd_subinv,
	     -- Bug 5018698: Following columns have been added.
	     l_transaction_source_id, l_transaction_source_name, l_trx_source_line_id,
	     l_source_code, l_source_line_id,
	     l_trx_source_delivery_id, l_picking_line_id, l_pick_slip_number,
	     l_pick_strategy_id, l_pick_rule_id, l_pick_slip_date,
	     l_so_issue_account_type, l_invoiced_flag,
             l_snd_currency_code, l_currency_conversion_rate,
             l_currency_conversion_type, l_currency_conversion_date,
             l_intercompany_currency_code, l_intercompany_cost,
             l_intercompany_pricing_option,
	     l_ship_to_location_id, l_snd_trp_cost
        FROM mtl_material_transactions mmt, mtl_system_items_b msi
       WHERE mmt.transaction_id    = l_xfer_transaction_id
         AND mmt.inventory_item_id = msi.inventory_item_id
         AND mmt.organization_id   = msi.organization_id
      ;

      --
      -- when creating this logical txn, shipping txn already exists.
      -- If total quantity is received in the same *txn* UOM as sending txn UOM,
      -- then we can directly populate all the qty fields without doing any UOM
      -- conversions. Doing just to improve performance!!!
      --
      l_stmt_num := 100;
      IF l_snd_txn_uom <> l_transaction_uom
        -- shipping qty and recv. txn uom are same
      THEN
        -- Do not skip qty conversions
        l_skip_qty_conv := 'N';
      ELSE
        l_skip_qty_conv := 'Y';

        l_qty_ratio     := l_transaction_qty/l_snd_txn_qty;
        l_pri_qty       := l_snd_pri_qty * l_qty_ratio;
        l_owner_pri_uom := l_snd_pri_uom;
        l_sec_qty       := l_snd_sec_qty * l_qty_ratio;
        l_sec_uom       := l_snd_sec_uom;
        l_transportation_cost := abs(l_qty_ratio * l_snd_trp_cost); -- Bug 5332813

        IF (l_debug = 1)
        THEN
          IF (l_qty_ratio = 1)
          THEN
            print_debug(l_procedure_name || ': Fully received');
          ELSE
            print_debug(l_procedure_name || ': Partially received');
          END IF;
        END IF; -- l_debug =1

      END IF;  -- IF l_snd_txn_uom <> l_transaction_uom

    ELSIF l_fobpoint = G_FOB_SHIPPING
    THEN

      --
      -- Bug 5018698: This elsif block of code is added.
      -- For FOB Ship, we are creating Internal Req/Logical Intransit Receipt (7/15) txn.
      --
      -- Inventory Material Txns form gets requision# as soon as it sees Internal Req. txn.
      -- Earlier, we were setting source_code and txn source id from the shipping line.
      -- The values were 'ORDER ENTRY' and mtl_sales_order.sales_order_id respectively.
      -- Because of this, form is unable to find the req and throwing No Data Found error and
      -- unable to query and logical intransit receipts at all.
      --
      -- Now we are setting the source_code to 'RCV' and getting the requisition_header_id
      -- from oe_order_lines_all table, so that form can query the txn.
      -- Txn_Source_Line_Id column should get updated when actual receipt of goods is made.
      --
      l_source_code := 'RCV';

      l_stmt_num := 601;
      IF l_transaction_source_type_id in (7,8)
      THEN
        SELECT
               ol.source_document_id	-- Requisition_header_id
                                          -- requisition_line_id = ol.source_document_line_id
          INTO
               l_transaction_source_id
          FROM mtl_material_transactions mmt, oe_order_lines_all ol
         WHERE mmt.transaction_id    = p_transaction_id
           AND ol.line_id            = mmt.trx_source_line_id
        ;
      ELSE
        l_transaction_source_id := NULL;
      END IF;

      IF (l_debug = 1) THEN
        print_debug(l_procedure_name || ': SourceDoc/ReqHdrId: ' || l_source_code ||'/'||l_transaction_source_id);
      END IF; -- IF l_fobpoint = G_FOB_RECEIVING

    END IF; -- IF l_fobpoint = G_FOB_RECEIVING


    l_stmt_num := 110;
    IF l_skip_qty_conv = 'N' /* Always 'N' for FOB Shipping */
    THEN

      IF (l_debug = 1) THEN
        print_debug(l_procedure_name || ': getting primary and secondary uom flags.');
      END IF;

      l_stmt_num := 120;
      SELECT primary_uom_code, tracking_quantity_ind, secondary_default_ind, secondary_uom_code
        INTO l_owner_pri_uom, l_tracking_quantity_ind, l_secondary_default_ind, l_sec_uom
        FROM mtl_system_items_b
       WHERE organization_id   = l_owner_org_id
         AND inventory_item_id = l_item_id;

      IF (l_transaction_uom <> l_owner_pri_uom)
      THEN

        IF (l_debug = 1) THEN
          print_debug(l_procedure_name || ': calling INV_CONVERT.inv_um_convert (' || l_stmt_num || '): '
            || 'converting from txnUOM: ' || l_transaction_uom || ' to primaryUOM: ' || l_owner_pri_uom, 9);
        END IF;

        l_stmt_num := 130;
        l_pri_qty  := INV_CONVERT.INV_UM_CONVERT
                            ( item_id         => l_item_id
                            , lot_number      => NULL
                            , organization_id => l_owner_org_id
                            , precision       => 5
                            , from_quantity   => l_transaction_qty
                            , from_unit       => l_transaction_uom
                            , to_unit         => l_owner_pri_uom
                            , from_name       => NULL
                            , to_name         => NULL);

        IF (l_pri_qty = -99999)
        THEN
          -- log message
          RAISE e_uom_conversion_error;
        END IF;

      ELSE
        l_pri_qty := l_transaction_qty;
      END IF;

      IF  (l_tracking_quantity_ind <> 'P')
      AND (l_secondary_default_ind IN ('F', 'D'))
      AND (l_owner_pri_uom <> l_sec_uom)
      THEN

        IF (l_debug = 1) THEN
          print_debug(l_procedure_name || ': calling INV_CONVERT.inv_um_convert (' || l_stmt_num || '): '
            || 'converting from primaryUOM: ' || l_owner_pri_uom|| ' to secUOM: ' || l_sec_uom, 9);
        END IF;

        l_stmt_num := 140;
        l_sec_qty := INV_CONVERT.INV_UM_CONVERT
                       ( item_id         => l_item_id
                       , lot_number      => NULL
                       , organization_id => l_owner_org_id
                       , precision       => 5
                       , from_quantity   => l_transaction_qty
                       , from_unit       => l_owner_pri_uom
                       , to_unit         => l_sec_uom
                       , from_name       => NULL
                       , to_name         => NULL);

        IF (l_sec_qty = -99999)
        THEN
          -- log message
          RAISE e_uom_conversion_error;
        END IF;

        IF (l_debug = 1) THEN
          print_debug(l_procedure_name || ': calling INV_CONVERT.WITHIN_DEVIATION', 9);
        END IF;

         -- Validate the quantitioes within deviation :
        l_stmt_num := 150;
        l_are_qties_valid := INV_CONVERT.within_deviation(
              p_organization_id    => l_owner_org_id
            , p_inventory_item_id  => l_item_id
            , p_lot_number         => NULL
            , p_precision          => 5
            , p_quantity           => ABS(l_pri_qty)
            , p_uom_code1          => l_owner_pri_uom
            , p_quantity2          => ABS(l_sec_qty)
            , p_uom_code2          => l_sec_uom)
        ;

        IF (l_are_qties_valid = 0)
        THEN
          -- dbms_output.put_line('INV_CONVERT.within_deviation (ERROR) '|| l_error_exp );
          IF (l_debug = 1) THEN
            print_debug(l_procedure_name || ': INV_CONVERT.within_deviation (ERROR)', 9);
            print_debug(' l_pri_qty: ' || l_pri_qty || ' l_owner_pri_uom: ' || l_owner_pri_uom, 9);
            print_debug(' l_sec_qty: ' || l_sec_qty || ' l_sec_uom: ' || l_sec_uom, 9);
            print_debug(' l_item_id: ' || l_item_id || ' l_owner_org_id: ' || l_owner_org_id, 9);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- dbms_output.put_line('INV_CONVERT.within_deviation (PASS) ');
        IF (l_debug = 1) THEN
          inv_log_util.trace(l_procedure_name || ': INV_CONVERT.within_deviation (PASS)' , 9);
        END IF;

      ELSE
        l_sec_qty := NULL;
        l_sec_uom := NULL;
      END IF;
    END IF;
    --
    -- End of qty conversions
    --

    /********************************************************************
    ** Transfer_Price and Transportation Cost conversion
    ** For FOB Shipping: Shipping Orgs currency to Receiving Orgs currency
    ** For FOB Receiving: we can directly pickup from shipping txn.
    ********************************************************************/

    --
    -- Get from and to OUs. If they are different then only do currency conversion.
    -- Here l_owner_ou_id is the OU Id of logical txn owner organizaiton.
    -- l_organization_id: sending   org for fob ship,
    --                    receiving org for fob receipt.
    --
    l_stmt_num := 61;
    OPEN  c_from_to_ou (l_organization_id, l_owner_org_id);
    FETCH c_from_to_ou INTO l_ou_id, l_sob_id, l_owner_ou_id, l_owner_sob_id;
    CLOSE c_from_to_ou;

    --
    -- Get base currency of sending org (fob ship) or receiving org (fob receipt) org
    --
    SELECT currency_code
      INTO l_currency_code
      FROM gl_sets_of_books
     WHERE set_of_books_id = l_sob_id;


    IF (l_debug = 1) THEN
      print_debug(l_procedure_name || ': doing transfer_price currency conversion, if necessary. txn/OwnerSOBId: ' ||
        l_sob_id||'/'||l_owner_sob_id);
    END IF;
    --
    -- Following call converts transfer_price from Receiving OU currency (l_currency_code)
    -- to funcational currency of Receiving OU (p_owner_ou_id).
    --
    IF l_sob_id <> l_owner_sob_id
    THEN

      IF (l_debug = 1) THEN
        print_debug(l_procedure_name || ': SOBs are different. currSOB/ownerSOB: ' ||
          l_sob_id ||'/'|| l_owner_sob_id || '. ownerOUId: ' || l_owner_ou_id);
      END IF;

      l_curr_conversion_rate := INV_TRANSACTION_FLOW_PUB.convert_currency(
                                    p_org_id                   => l_owner_ou_id
                                  , p_transfer_price           => 1
                                  , p_currency_code            => l_currency_code
                                  , p_transaction_date         => l_transaction_date
                                  , x_functional_currency_code => l_owner_currency_code
                                  , x_return_status            => x_return_status
                                  , x_msg_data                 => x_msg_data
                                  , x_msg_count                => x_msg_count
                                  );

      IF (l_debug = 1) THEN
        print_debug(l_procedure_name || ': currConvRate from curr '|| l_currency_code ||
          ' to ' || l_owner_currency_code || ' is: ' || l_curr_conversion_rate);
      END IF;

      IF ( x_return_status <> G_RET_STS_SUCCESS )
      THEN
          print_debug(l_procedure_name || ': Error from INV_TRANSACTION_FLOW_PUB.convert_currency: ' ||
            x_msg_data, 9);
          IF x_return_status = FND_API.G_RET_STS_ERROR
          THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

    -- Bug 5326088: Default to 1 otherwise it is NULL and hence transfer price is NULL.
    ELSE
      l_curr_conversion_rate := 1;
    END IF;

    l_stmt_num := 50;
    IF l_fobpoint = G_FOB_RECEIVING
    THEN
      --
      -- Since the logical trx being created against *shipping* orgs, we can
      -- get the transfer price from shipping transaction.
      -- We already got it above with stmt number 60.
      --
      -- But, we still need to convert transportation cost. We cannot directly
      -- pickup transportation cost from shipping transaction, since qty can
      -- be received mutliple times i.e., partially. Transportation cost on
      -- receiving transaction is already prorated. So, we just need to convert
      -- it from receiving currency to shipping currency.
      --
      -- Bug 5332813: using conversion rate from shipping txn. Then dividing the
      -- transportation_cost on the receiving txn (in rcv currency) with conversion rate
      -- to derive in shipping orgs currency. Just working backwards to avoid decimal dust.
      --
      IF l_skip_qty_conv = 'N' AND nvl(l_currency_conversion_rate, 0) <> 0
      THEN
        l_transportation_cost := l_transportation_cost / l_currency_conversion_rate;
      END IF;

    ELSE

      --
      -- In case of FOB Shipment, logical transaction will be created for
      -- receiving org. So, convert transfer_price from sending org currency
      -- to receiving orgs currency, if they are different.
      -- Conversion is only needed when transfers across OUs.
      --
      IF (l_debug = 1) THEN
        print_debug(l_procedure_name || ': FOB Shipment. So, doing transfer_price UOM (not Currency) conversion, if necessary. Transfer Price at this point is ' || l_transfer_price);
      END IF;

      --
      -- First do uom conversion and then currency conversion for transfer price.
      --

      IF l_pri_uom <> l_owner_pri_uom
      THEN

        IF (l_debug = 1) THEN
          print_debug(l_procedure_name ||
            ': First, doing UOM conv. from/to: ' || l_pri_uom ||'/'|| l_owner_pri_uom ||
            ' tp/trp: ' || l_transfer_price ||'/'|| l_transportation_cost);
        END IF;

        INV_CONVERT.inv_um_conversion(
            from_unit   => l_pri_uom
          , to_unit     => l_owner_pri_uom
          , item_id     => l_item_id
          , uom_rate    => l_pri_uom_rate
        );

        IF (l_pri_uom_rate = -99999)
        THEN
          -- UOM conversion error
          RAISE e_uom_conversion_error;
        END IF;

      ELSE
        l_pri_uom_rate := 1;
      END IF;


---   l_transfer_price      := l_pri_uom_rate * l_transfer_price; /* Bug#5471868 ANTHIYAG 17-Aug-2006 */
      l_transfer_price      := l_transfer_price / nvl(l_pri_uom_rate, 1); /* Bug#5471868 ANTHIYAG 17-Aug-2006 */
      l_transfer_price      := l_curr_conversion_rate * l_transfer_price;
      l_transportation_cost := l_curr_conversion_rate * l_transportation_cost;

        IF (l_debug = 1) THEN
          print_debug(l_procedure_name || ': After doing UOM conv. uom conv rate: ' ||
            l_pri_uom_rate || ' currConvRate: ' || l_curr_conversion_rate);
        END IF;

    END IF;

    print_Debug(l_procedure_name || ': transfer price/trpCost = ' || l_transfer_price ||
        '/' || l_transportation_cost ||
        ' ' || nvl(l_owner_currency_code, l_currency_code), 9);


    /********************************************************************
    ** Determine Costed_Flag and OPM_costed_flag column values.
    ********************************************************************/
    l_stmt_num := 160;
    SELECT DECODE(NVL(process_enabled_flag, 'N'), 'N', 'N', NULL),
           DECODE(NVL(process_enabled_flag, 'N'), 'Y', 'N', NULL)
      INTO l_costed_flag, l_opm_costed_flag
      FROM mtl_parameters
     WHERE organization_id = l_owner_org_id;


    IF (l_debug = 1) THEN
      print_debug(l_procedure_name || ': All set to insert logical txn into MMT');
    END IF;
    /** we have all values, insert into MMT */

    l_stmt_num := 170;
    INSERT INTO mtl_material_transactions
      (TRANSACTION_ID,
      ORGANIZATION_ID,
      INVENTORY_ITEM_ID,
      REVISION,
      SUBINVENTORY_CODE,
      LOCATOR_ID,
      TRANSACTION_TYPE_ID,
      TRANSACTION_ACTION_ID,
      TRANSACTION_SOURCE_TYPE_ID,
      TRANSACTION_SOURCE_ID,
      TRANSACTION_SOURCE_NAME,
      TRANSACTION_QUANTITY,
      TRANSACTION_UOM,
      TRANSACTION_DATE,
      ACCT_PERIOD_ID,
      DISTRIBUTION_ACCOUNT_ID,
      COSTED_FLAG,
      OPM_COSTED_FLAG,
      ACTUAL_COST,
      INVOICED_FLAG,
      TRANSACTION_COST,
      CURRENCY_CODE,
      CURRENCY_CONVERSION_RATE,
      CURRENCY_CONVERSION_TYPE,
      CURRENCY_CONVERSION_DATE,
      PM_COST_COLLECTED,
      TRX_SOURCE_LINE_ID,
      SOURCE_CODE,
      SOURCE_LINE_ID,
      TRANSFER_TRANSACTION_ID,
      TRANSFER_ORGANIZATION_ID,
      TRANSFER_SUBINVENTORY,
      TRANSFER_LOCATOR_ID,
      COST_GROUP_ID,
      TRANSFER_COST_GROUP_ID,
      SHIP_TO_LOCATION_ID,
      TRANSACTION_MODE,
      TRANSACTION_BATCH_ID,
      TRANSACTION_BATCH_SEQ,
      LPN_ID,
      PARENT_TRANSACTION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      TRANSACTION_SET_ID,
      EXPENDITURE_TYPE,
      TRANSFER_PRICE,
      LOGICAL_TRANSACTION,
      LOGICAL_TRANSACTIONS_CREATED,
      FOB_POINT,
      TRANSPORTATION_COST,
      TRANSPORTATION_DIST_ACCOUNT,
      SHIPMENT_NUMBER,
      TRANSACTION_REFERENCE,
      QUANTITY_ADJUSTED,
      TRANSFER_ORGANIZATION_TYPE,
      ORGANIZATION_TYPE,
      OWNING_ORGANIZATION_ID,
      PLANNING_ORGANIZATION_ID,
      XFR_PLANNING_ORGANIZATION_ID,
      PRIMARY_QUANTITY,
      SECONDARY_UOM_CODE,
      SECONDARY_TRANSACTION_QUANTITY,
      RCV_TRANSACTION_ID,
      OWNING_TP_TYPE,
      XFR_OWNING_ORGANIZATION_ID,
      TRANSFER_OWNING_TP_TYPE,
      PLANNING_TP_TYPE,
      TRANSFER_PLANNING_TP_TYPE,
      -- Bug 5018698: Following columns have been added.
      INTERCOMPANY_COST,
      INTERCOMPANY_PRICING_OPTION,
      INTERCOMPANY_CURRENCY_CODE,
      TRX_SOURCE_DELIVERY_ID,
      PICKING_LINE_ID,
      PICK_SLIP_NUMBER,
      PICK_STRATEGY_ID,
      PICK_RULE_ID,
      PICK_SLIP_DATE,
      INTRANSIT_ACCOUNT,		-- Bug 5018698
      SO_ISSUE_ACCOUNT_TYPE
      )
     SELECT
      mtl_material_transactions_s.nextval, -- transaction_id
      l_owner_org_id,                   -- organization_id
      mmt.inventory_item_id,
      mmt.revision,
      decode(mmt.fob_point, G_FOB_RECEIVING, l_snd_subinv,
      			     mmt.transfer_subinventory),    -- subinv_code of owner org i.e., shipping org subinv
      mmt.transfer_locator_id,          -- locator_id of owner org
      l_logical_trx_type_id,            -- transaction_type_id
      l_logical_trx_action_id,          -- transaction_action_id
      -- Bug 4898549: replaced following line with local variable.
      -- mmt.transaction_source_type_id,              -- transaction_source_id
      l_logical_trx_src_type_id,
      l_transaction_source_id,
      l_transaction_source_name,
      abs(mmt.transaction_quantity),    -- transaction_quantity
      mmt.transaction_uom,              -- transaction_uom
      mmt.transaction_date,             -- transaction_date
      l_account_period_id,
      null,                             -- distribution_account_id null for now
      l_costed_flag,                    -- costed_flag
      l_opm_costed_flag,                -- opm_costed_flag
      mmt.actual_cost,
      decode(mmt.fob_point, G_FOB_RECEIVING, l_invoiced_flag,
                            mmt.invoiced_flag),
      mmt.transaction_cost,
      l_owner_currency_code,
      l_currency_conversion_rate,
      l_currency_conversion_type,
      l_currency_conversion_date,
      mmt.pm_cost_collected,
      decode(mmt.fob_point, G_FOB_RECEIVING, l_trx_source_line_id, mmt.trx_source_line_id),
      l_source_code,
      decode(mmt.fob_point, G_FOB_RECEIVING, l_source_line_id, mmt.source_line_id),
      mmt.transaction_id,               -- transfer_transaction_id
      mmt.organization_id,              -- transfer_organization_id
      mmt.subinventory_code,            -- transfer_subinventory
      mmt.locator_id,                   -- transfer_locator_id
      l_cost_group_id,                  -- cost_group_id
      l_xfer_cost_group_id,
      l_ship_to_location_id,
      mmt.transaction_mode,
      mmt.transaction_batch_id,
      mmt.transaction_batch_seq,
      mmt.lpn_id,
      mmt.transaction_id,               -- parent_transaction_id
      mmt.last_update_date,
      mmt.last_updated_by,
      mmt.creation_date,
      mmt.created_by,
      mmt.transaction_set_id,            -- should we set this here?
      l_expenditure_type,
      l_transfer_price,
      1,                                 -- logical_transaction it is!
      null,                              -- logical_transactions_created set it to null
      l_fobpoint,
      l_transportation_cost,
      mmt.transportation_dist_account,
      mmt.shipment_number,
      mmt.transaction_reference,
      mmt.quantity_adjusted,             -- in Recv Orgs UOM for FOB Shipping
      mmt.organization_type,              -- transfer_organization_type.
      mmt.transfer_organization_type,     -- organization_type. xxx how to get this???
      l_owner_org_id,                     -- owning_organization_id
      mmt.xfr_planning_organization_id,
      mmt.planning_organization_id,
      abs(l_pri_qty),
      l_sec_uom,
      l_sec_qty,
      mmt.rcv_transaction_id,
      mmt.transfer_owning_tp_type,
      mmt.owning_organization_id,
      mmt.owning_tp_type,
      mmt.transfer_planning_tp_type,
      mmt.planning_tp_type,
      -- Bug 5018698: Following columns have been added.
      l_intercompany_cost,
      l_intercompany_pricing_option,
      l_intercompany_currency_code,
      l_trx_source_delivery_id,
      l_picking_line_id,
      l_pick_slip_number,
      l_pick_strategy_id,
      l_pick_rule_id,
      l_pick_slip_date,
      mmt.intransit_account,		-- Bug 5018698
      l_so_issue_account_type
     FROM   mtl_material_transactions mmt
     WHERE  mmt.transaction_id = p_transaction_id;

   x_return_status := g_ret_sts_success;

   IF (l_debug = 1)
   THEN
      print_debug(l_procedure_name || ': After mmt insert', 9);
   END IF;

    /** rseshadr TBD -
    * should we use the project_id from the current trx? or
    * do we get it from the other side of the trx, if available?
    * or find it ourselves based on owner_org_id and trx type?
    * For I Phase p/d transfers from or to a Project Org is disabled
    *
    * umoogala: since CG is already stamped on the shipping row, we can
    * use that. Did that in the query against mmt.
    *
    IF (true)
    THEN
      INV_LOGICAL_TRANSACTIONS_PUB.get_default_costgroup(
        x_return_status     => l_return_status
        , x_msg_count       => l_msg_count
        , x_msg_data        => l_msg_data
        , x_cost_group_id   => l_cost_group_id
        , p_organization_id => l_owner_org_id);
    ELSE
      INV_LOGICAL_TRANSACTIONS_PUB.get_project_costgroup(
        x_return_status     => l_return_status
        , x_msg_count       => l_msg_count
        , x_msg_data        => l_msg_data
        , x_cost_group_id   => l_cost_group_id
        , p_project_id      => l_project_id
        , p_organization_id => l_owner_org_id);
    END IF;

    IF (l_return_status <> G_RET_STS_SUCCESS)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug(l_procedure_name || 'get_default_costgroup returns error', 9);
        print_debug(l_procedure_name || 'l_msg_data = ' || l_msg_data, 9);
      END IF;
      FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_GET_COST_GROUP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */
EXCEPTION
   WHEN no_data_found
   THEN
     x_return_status := G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data => x_msg_data);

     IF (l_debug = 1)
     THEN
       print_debug(l_procedure_name || ' (' || l_stmt_num ||'): no_data_found error', 9);
       print_debug(l_procedure_name || 'SQL Error ' || '(' || l_stmt_num || '): ' || Sqlerrm(SQLCODE), 9);
     END IF;

   WHEN OTHERS
   THEN
     x_return_status := G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_procedure_name);
     END IF;

     FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data => x_msg_data);
     IF (l_debug = 1)
     THEN
       print_debug(l_procedure_name || ' (' || l_stmt_num ||'): others error', 9);
       print_debug(l_procedure_name || 'SQL Error ' || '(' || l_stmt_num || '): ' || Sqlerrm(SQLCODE), 9);
     END IF;

END create_opm_disc_logical_trx;


END INV_LOGICAL_TRANSACTIONS_PUB;

/
