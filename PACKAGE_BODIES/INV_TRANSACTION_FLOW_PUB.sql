--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTION_FLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTION_FLOW_PUB" AS
/* $Header: INVPICTB.pls 120.17.12010000.8 2010/03/22 12:42:32 rkatoori ship $ */

/** These two global variable are used to cache the start OU and get the functional currency of
    The start OU
 **/
G_FUNCTIONAL_CURRENCY_CODE VARCHAR2(31);
G_SETS_OF_BOOK_ID	   NUMBER := -1;
G_INV_CURR_ORG		   NUMBER := -1;
G_INV_CURR_CODE		   VARCHAR2(31);
G_FROM_ORG_ID	           NUMBER := -1;
G_TO_ORG_ID		   NUMBER := -1;
G_FLOW_TYPE		   NUMBER := -1;
g_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
g_version_printed BOOLEAN := FALSE;

G_PKG_NAME CONSTANT VARCHAR2(50) := 'INV_TRANSACTION_FLOW_PUB';

G_ORDER_LINE_ID            NUMBER := -1; /* Bug 5527437: umoogala */

Procedure print_debug(p_message IN VARCHAR2,
		      p_module IN VARCHAR2)
IS
BEGIN
IF (g_debug=1) THEN
    IF NOT g_version_printed THEN
      INV_TRX_UTIL_PUB.TRACE('$Header: INVPICTB.pls 120.17.12010000.8 2010/03/22 12:42:32 rkatoori ship $',G_PKG_NAME, 9);
      g_version_printed := TRUE;
    END IF;
   inv_log_util.trace(p_message, p_module);
END IF;
   --dbms_output.put_line(p_module || ' ' || p_message);
end;

Procedure print_debug(p_message IN VARCHAR2)
IS
BEGIN
   print_debug(p_message, 'INV_TRANSACTION_FLOW_PUB');
   --dbms_output.put_line(p_module || ' ' || p_message);
end;



/*===================================================================================================
 * Procedure: GET_TRANSACTION_FLOW()
 *
 * Description:
 * This API is used to get a valid Inter-company Transaction Flow for a pair of Start Operating Unit
 * and End Operating Unit, which is active on the transaction date for either Global Procurement Flow
 * or Drop Ship flow.
 * This API will be a public API and will be called by
 * 1.	the "Create Logical Transaction" API within Oracle Inventory,
 * 2.	by Receiving during the time of delivery for True Drop Ship flows
 * 3.	by Oracle Costing while creating the Receiving Accounting Event records for
 *      Global Procurement flows
 *
 * Usage:
 * To get a valid Inter-company Transaction Flow for a pair of Start Operating Unit and
 * End Operating Unit, which is active on the transaction date for either Global Procurement Flow
 * or Drop Ship flow.
 *
 * Inputs:
 * This API will receive the following input parameters:
 * 1.	Start OU: The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 *      This is a required parameter.
 * 2.	End OU: The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 *      This is a required parameter
 * 3.	Flow Type: To indicate what is the flow type, either Global Procurement or Drop Ship
 * 4.	Array of Qualifier Codes: The qualifier code, for  this release, it will be "1" - Category.
 *      This is an optional parameter. Default value for this parameter is NULL.
 * 5.	Array of Qualifier Value IDs: The value of the qualifier.
 *      For this release, it will be the category_id of the item. This is an optional parameter.
 *      The default value of this parameter will be NULL.
 * 6.	Transaction Date: The date when the transaction is going to happen.
 * 7.	API version - the version of the API
 * 8.	Get default cost group - Flag to get the default cost group
 *
 * Outputs:
 * This API will return a table of records of all the nodes in between the
 * Start Operating Unit and End Operating Unit, the pricing options,
 * and the Inter-Company Relations information.
 *===================================================================================================*/
PROCEDURE GET_TRANSACTION_FLOW
(
 x_return_status	   OUT NOCOPY 	VARCHAR2
 , x_msg_data		   OUT NOCOPY 	VARCHAR2
 , x_msg_count		   OUT NOCOPY 	NUMBER
 , x_transaction_flows_tbl OUT NOCOPY 	g_transaction_flow_tbl_type
 , p_api_version 	   IN  NUMBER
 , p_init_msg_list         IN  VARCHAR2
 , p_start_operating_unit  IN  NUMBER
 , p_end_operating_unit	   IN  NUMBER
 , p_flow_type		   IN  NUMBER
 , p_organization_id	   IN  NUMBER
 , p_qualifier_code_tbl	   IN  NUMBER_TBL
 , p_qualifier_value_tbl   IN  NUMBER_TBL
 , p_transaction_date	   IN  DATE
 , p_get_default_cost_group IN  VARCHAR2)
   IS
      CURSOR txn_flow_hdrs(l_start_org_id NUMBER, l_end_org_id NUMBER, l_flow_type NUMBER, l_txn_date DATE)
	IS
	   SELECT
	     t_hdr.header_id,
	     t_hdr.start_org_id,
	     t_hdr.end_org_id,
	     t_hdr.organization_id,
	     t_hdr.start_date,
	     t_hdr.end_date,
	     t_hdr.asset_item_pricing_option,
	     t_hdr.expense_item_pricing_option,
	     t_hdr.new_accounting_flag,
	     t_hdr.qualifier_code,
	     t_hdr.qualifier_value_id
	     FROM
	     mtl_transaction_flow_headers t_hdr
	     WHERE
	     t_hdr.start_org_id = l_start_org_id
	     and t_hdr.end_org_id = l_end_org_id
	     and l_txn_date between t_hdr.start_date and nvl(t_hdr.end_date,l_txn_date+1)
	     and t_hdr.flow_type = l_flow_type
	     ORDER BY
	     t_hdr.organization_id,t_hdr.qualifier_code;

      CURSOR txn_flow_lines(l_header_id NUMBER,l_flow_type NUMBER)
	IS
	   SELECT
	     t_line.line_number,
	     t_line.from_org_id,
	     t_line.from_organization_id,
	     t_line.to_org_id,
	     t_line.to_organization_id,
	     --
	     icp.customer_id,
	     icp.address_id,
	     icp.customer_site_id,
	     icp.cust_trx_type_id,
	     icp.vendor_id,
	     icp.vendor_site_id,
	     icp.freight_code_combination_id,
	     icp.inventory_accrual_account_id,
	     icp.expense_accrual_account_id,
	     icp.intercompany_cogs_account_id
	     FROM
	     mtl_transaction_flow_lines t_line,
	     mtl_intercompany_parameters icp
	     WHERE
	     t_line.header_id = l_header_id
	     and icp.ship_organization_id=t_line.from_org_id
	     and icp.sell_organization_id=t_line.to_org_id
	     and icp.flow_type = l_flow_type
	     ORDER BY t_line.line_number;

      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_transaction_flows_tbl g_transaction_flow_tbl_type;
      rcount NUMBER := 0;
      l_match BOOLEAN;
      l_found BOOLEAN;
      l_api_name CONSTANT VARCHAR2(30) := 'GET_TRANSACTION_FLOW';
    l_api_version_number CONSTANT NUMBER := 1.0;
    l_from_ou_name VARCHAR2(240);
    l_to_ou_name	VARCHAR2(240);
BEGIN

   x_return_status := g_ret_sts_success;
   x_msg_data := null;
   x_msg_count := 0;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
               l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;


   IF l_debug = 1 then
      print_debug('Entered get_transaction_flow', l_api_name);
      print_debug('p_start_operating_unit '||p_start_operating_unit, l_api_name);
      print_debug('p_end_operating_unit '||p_end_operating_unit, l_api_name);
      print_debug('p_flow_type '|| p_flow_type, l_api_name);
      print_debug('p_organization_id '||p_organization_id, l_api_name);
      print_debug('p_transaction_date '||To_char(p_transaction_date,'DD-MON-YYYY HH24:MI:SS'), l_api_name);
      print_debug('p_get_default_cost_group '||p_get_default_cost_group, l_api_name);

      IF p_qualifier_code_tbl.COUNT > 0
	AND p_qualifier_value_tbl.COUNT > 0
	AND p_qualifier_code_tbl.COUNT = p_qualifier_value_tbl.COUNT THEN

	 FOR i IN 1..p_qualifier_code_tbl.COUNT LOOP
	    print_debug('p_qualifier_code_tbl('||i||'):'||p_qualifier_code_tbl(i), l_api_name);
	    print_debug('p_qualifier_value_tbl('||i||'):'||p_qualifier_value_tbl(i), l_api_name);
	 END LOOP;
      END IF;--IF p_qualifier_code_tbl.COUNT > 0....
   END IF;



   FOR l_txn_flow_hdrs IN txn_flow_hdrs(p_start_operating_unit, p_end_operating_unit, p_flow_type, p_transaction_date) LOOP

      l_match := TRUE;

      IF l_debug = 1 THEN
	 print_debug(' Verifying match for txn flow hdr '||l_txn_flow_hdrs.header_id, l_api_name);
      END IF;

      /************************************************
      l_txn_flow_hdrs.organization_id |p_organization_id  |match
      NOT NULL                        NOT NULL          only when l_txn_flow_hdrs.organization_id=p_organization_id
      NOT NULL                        NULL              Not a Match
      NULL                            NOT NULL          Match
      NULL                            NULL              Match
      ************************************************/

      IF Nvl(l_txn_flow_hdrs.organization_id,Nvl(p_organization_id,-9999)) = NVL(p_organization_id,-9999) THEN
	 l_match := TRUE;
       ELSE
	 l_match := FALSE;
      END IF;-- IF l_txn_flow_hdrs.organization_id = p_organization_id

      IF l_debug = 1 THEN
	 print_debug('p_organization_id '||p_organization_id||' compare to '||
		     l_txn_flow_hdrs.organization_id, l_api_name);
	 IF l_match THEN
	    print_debug('l_match TRUE', l_api_name);
	  ELSE
	    print_debug('l_match FALSE', l_api_name);
	 END IF;--IF l_match THEN
      END IF;-- IF l_debug = 1 THEN

      IF l_match THEN
	 IF (p_qualifier_code_tbl.COUNT > 0)
	   AND (p_qualifier_value_tbl.COUNT > 0)
	   AND (p_qualifier_code_tbl.COUNT = p_qualifier_value_tbl.COUNT) THEN

	    IF l_debug = 1 THEN
	       print_debug('p_qualifier_code_tbl(1) '||p_qualifier_code_tbl(1)||' compare to '||
			   l_txn_flow_hdrs.qualifier_code, l_api_name);
	    end if;

	    IF Nvl(l_txn_flow_hdrs.qualifier_code, Nvl(p_qualifier_code_tbl(1),-9999)) = Nvl(p_qualifier_code_tbl(1),-9999)
	      AND Nvl(l_txn_flow_hdrs.qualifier_value_id,Nvl(p_qualifier_value_tbl(1),-9999)) = Nvl(p_qualifier_value_tbl(1),-9999)  THEN
	       l_match := TRUE;
	     ELSE
	       l_match := FALSE;
	    END IF;
	  ELSIF l_txn_flow_hdrs.qualifier_code IS NULL
	    AND l_txn_flow_hdrs.qualifier_value_id IS NULL THEN
	    l_match := TRUE;
	  ELSE
	    l_match := FALSE;
	 END IF;

	 IF l_debug = 1 THEN
	    IF l_match THEN
	       print_debug('l_match TRUE', l_api_name);
	     ELSE
	       print_debug('l_match FALSE', l_api_name);
	    END IF;--IF l_match THEN
	 END IF;-- IF l_debug = 1 THEN

      END IF;--IF l_match THEN

      IF l_match THEN

	 rcount := rcount + 1;

	 l_transaction_flows_tbl(rcount).HEADER_ID            := l_txn_flow_hdrs.header_id;
	 l_transaction_flows_tbl(rcount).START_ORG_ID         := l_txn_flow_hdrs.start_org_id;
	 l_transaction_flows_tbl(rcount).END_ORG_ID           := l_txn_flow_hdrs.end_org_id;
	 l_transaction_flows_tbl(rcount).ORGANIZATION_ID      := l_txn_flow_hdrs.organization_id;
	 l_transaction_flows_tbl(rcount).ASSET_ITEM_PRICING_OPTION  := l_txn_flow_hdrs.asset_item_pricing_option;
	 l_transaction_flows_tbl(rcount).EXPENSE_ITEM_PRICING_OPTION := l_txn_flow_hdrs.expense_item_pricing_option;
	 l_transaction_flows_tbl(rcount).START_DATE	      := l_txn_flow_hdrs.start_date;
	 l_transaction_flows_tbl(rcount).END_DATE	      := l_txn_flow_hdrs.end_date;
	 l_transaction_flows_tbl(rcount).NEW_ACCOUNTING_FLAG  := l_txn_flow_hdrs.new_accounting_flag;

	 FOR l_txn_flow_lines IN txn_flow_lines(l_txn_flow_hdrs.header_id,p_flow_type) LOOP

	    l_transaction_flows_tbl(rcount).HEADER_ID            := l_txn_flow_hdrs.header_id;
	    l_transaction_flows_tbl(rcount).START_ORG_ID         := l_txn_flow_hdrs.start_org_id;
	    l_transaction_flows_tbl(rcount).END_ORG_ID           := l_txn_flow_hdrs.end_org_id;
	    l_transaction_flows_tbl(rcount).ORGANIZATION_ID      := l_txn_flow_hdrs.organization_id;
	    l_transaction_flows_tbl(rcount).ASSET_ITEM_PRICING_OPTION  := l_txn_flow_hdrs.asset_item_pricing_option;
	    l_transaction_flows_tbl(rcount).EXPENSE_ITEM_PRICING_OPTION := l_txn_flow_hdrs.expense_item_pricing_option;
	    l_transaction_flows_tbl(rcount).START_DATE	      := l_txn_flow_hdrs.start_date;
	    l_transaction_flows_tbl(rcount).END_DATE	      := l_txn_flow_hdrs.end_date;
	    l_transaction_flows_tbl(rcount).NEW_ACCOUNTING_FLAG  := l_txn_flow_hdrs.new_accounting_flag;

	    --Line attributes
	    l_transaction_flows_tbl(rcount).LINE_NUMBER          := l_txn_flow_lines.line_number;
	    l_transaction_flows_tbl(rcount).FROM_ORG_ID          := l_txn_flow_lines.from_org_id;
	    l_transaction_flows_tbl(rcount).FROM_ORGANIZATION_ID := l_txn_flow_lines.from_organization_id;
	    l_transaction_flows_tbl(rcount).TO_ORG_ID            := l_txn_flow_lines.to_org_id;
	    l_transaction_flows_tbl(rcount).TO_ORGANIZATION_ID   := l_txn_flow_lines.to_organization_id;
	    --I/C attributes
	    l_transaction_flows_tbl(rcount).CUSTOMER_ID          := l_txn_flow_lines.customer_id;
	    l_transaction_flows_tbl(rcount).ADDRESS_ID	      := l_txn_flow_lines.address_id;
	    l_transaction_flows_tbl(rcount).CUSTOMER_SITE_ID     := l_txn_flow_lines.customer_site_id;
	    l_transaction_flows_tbl(rcount).CUST_TRX_TYPE_ID     := l_txn_flow_lines.cust_trx_type_id;
	    l_transaction_flows_tbl(rcount).VENDOR_ID	      := l_txn_flow_lines.vendor_id;
	    l_transaction_flows_tbl(rcount).VENDOR_SITE_ID       := l_txn_flow_lines.vendor_site_id;
	    l_transaction_flows_tbl(rcount).FREIGHT_CODE_COMBINATION_ID  := l_txn_flow_lines.freight_code_combination_id;
	    l_transaction_flows_tbl(rcount).INVENTORY_ACCRUAL_ACCOUNT_ID := l_txn_flow_lines.inventory_accrual_account_id;
	    l_transaction_flows_tbl(rcount).EXPENSE_ACCRUAL_ACCOUNT_ID   := l_txn_flow_lines.expense_accrual_account_id;
	    l_transaction_flows_tbl(rcount).INTERCOMPANY_COGS_ACCOUNT_ID := l_txn_flow_lines.intercompany_cogs_account_id;

	    if p_get_default_cost_group in ('Y','y') THEN

	       IF l_txn_flow_lines.from_organization_id IS NOT NULL THEN
	          BEGIN
		     SELECT default_cost_group_id
		       INTO l_transaction_flows_tbl(rcount).From_ORG_COST_GROUP_ID
		       FROM mtl_parameters mp
		       WHERE
		       organization_id =  l_txn_flow_lines.from_organization_id;
		  EXCEPTION
		     WHEN no_data_found THEN
			RAISE fnd_api.g_exc_error;
		  END;
	       END IF;--if l_txn_flows.from_organization_id IS ...

	       IF l_txn_flow_lines.to_organization_id IS NOT NULL THEN
	          BEGIN
		     SELECT default_cost_group_id
		       INTO l_transaction_flows_tbl(rcount).to_ORG_COST_GROUP_ID
		       FROM mtl_parameters mp
		       WHERE
		       organization_id =  l_txn_flow_lines.to_organization_id;
		  EXCEPTION
		     WHEN no_data_found THEN
			RAISE fnd_api.g_exc_error;
		  END;
	       END IF;--IF l_txn_flows.to_organization_id

	    END IF;--if p_get_default_cost_group in ('Y','y') THEN

	    rcount := rcount + 1;

	 END LOOP;-- FOR l_txn_flow_lines IN txn_flow..

	 IF l_debug = 1 THEN
	    print_debug(' returning Header_id '||l_txn_flow_hdrs.header_id, l_api_name);
	 END IF;
         --Exiting the loop as we found the matching transaction flow
	 EXIT;

      END IF; -- if l_match

   END LOOP;--l_txn_flow_hdrs IN txn_flows...

   IF rcount > 0 THEN
      x_transaction_flows_tbl := l_transaction_flows_tbl;
    ELSE
      x_return_status := g_ret_sts_warning;
      BEGIN
	select name
	into l_from_ou_name
	FROM hr_organization_units
	WHERE organization_id = p_start_operating_unit;

      EXCEPTION
	when no_data_found then
	FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_START_ORG');
	FND_MSG_PUB.ADD;
	raise fnd_api.g_exc_error;
      end;

      BEGIN
	select name
	into l_to_ou_name
	FROM hr_organization_units
	WHERE organization_id = p_end_operating_unit;
      EXCEPTION
	when no_data_found then
	FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_END_ORG');
	FND_MSG_PUB.ADD;
	raise fnd_api.g_exc_error;
      end;

      fnd_message.set_name('INV', 'INV_NO_IC_TXN_FLOW');
      FND_MESSAGE.SET_TOKEN('FROM_OU', l_from_ou_name);
      FND_MESSAGE.SET_TOKEN('TO_OU', l_to_ou_name);
      fnd_msg_pub.add;
      IF l_debug = 1 THEN
	 print_debug(' No matching transaction flows found ', l_api_name);
      END IF;
      x_transaction_flows_tbl.DELETE;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_transaction_flows_tbl.delete;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_transaction_flows_tbl.delete;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_transaction_flows_tbl.delete;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'GET_TRANSACTION_FLOW');
      end if;
END GET_TRANSACTION_FLOW;


 /*===================================================================================================
 * Procedure: GET_TRANSACTION_FLOW()
 *
 * Description:
 * This API is used to get a valid Inter-company Transaction Flow for a
 * given transaction flow header
 * This API will be a public API and will be called by
 * 1.	the "Create Logical Transaction" API within Oracle Inventory,
 *
 * Usage:
 * To get a valid Inter-company Transaction Flow for a given transaction flow header.
 * Inputs:
 * This API will receive the following input parameters:
 * 1.	API version - the version of the API
 * 2.	Header Id - Transaction Flow Header id
 * 3.   Get default cost group - if passed 'Y' , populates the from org
 *      cost group and to org cost group on the return transaction flows table
 * Outputs:
 * This API will return a table of records of type g_transaction_flow_tbl_type
 * x_return_status - this API will return 'S' if it is successfull and a transaction flow record
 *                   is found.
 *                 - This API will return 'W' if it is successfull but no transaction flow record is
 *                   found
 *                 - This API will return 'U' or 'E' if something errors out.
 *===================================================================================================*/
procedure get_transaction_flow(
 	x_return_status		OUT NOCOPY 	VARCHAR2
, 	x_msg_data		OUT NOCOPY 	VARCHAR2
,	x_msg_count		OUT NOCOPY 	NUMBER
, 	x_transaction_flows_tbl	OUT NOCOPY 	g_transaction_flow_tbl_type
,       p_api_version 		IN		NUMBER
,       p_init_msg_list		IN		VARCHAR2 default G_FALSE
, 	p_header_id	        IN		NUMBER
,       p_get_default_cost_group IN		VARCHAR2) IS


   CURSOR txn_flows(l_header_id NUMBER)
     IS
	SELECT
	  t_hdr.header_id,
	  t_hdr.start_org_id,
	  t_hdr.end_org_id,
	  t_hdr.organization_id,
	  t_hdr.start_date,
	  t_hdr.end_date,
	  t_hdr.asset_item_pricing_option,
	  t_hdr.expense_item_pricing_option,
	  t_hdr.new_accounting_flag,
	  t_hdr.qualifier_code,
	  t_hdr.qualifier_value_id,
	  --
	  t_line.line_number,
	  t_line.from_org_id,
	  t_line.from_organization_id,
	  t_line.to_org_id,
	  t_line.to_organization_id,
	  --
	  icp.customer_id,
	  icp.address_id,
	  icp.customer_site_id,
	  icp.cust_trx_type_id,
	  icp.vendor_id,
	  icp.vendor_site_id,
	  icp.freight_code_combination_id,
	  icp.inventory_accrual_account_id,
	  icp.expense_accrual_account_id,
	  icp.intercompany_cogs_account_id
	  FROM
	  mtl_transaction_flow_headers t_hdr,
	  mtl_transaction_flow_lines t_line,
	  mtl_intercompany_parameters icp
	  WHERE
	  t_hdr.header_id = l_header_id
	  AND t_hdr.header_id = t_line.header_id (+)
	  and icp.ship_organization_id=t_line.from_org_id
	  and icp.sell_organization_id=t_line.to_org_id
	  AND icp.flow_type = t_hdr.flow_type
	  ORDER BY t_line.line_number;


   l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_transaction_flows_tbl g_transaction_flow_tbl_type;
   rcount NUMBER := 0;
   l_api_name CONSTANT VARCHAR2(30) := 'GET_TRANSACTION_FLOW';
   l_api_version_number CONSTANT NUMBER := 1.0;
   l_from_ou_name VARCHAR2(240);
   l_to_ou_name vARCHAR2(240);
BEGIN
   x_return_status := g_ret_sts_success;
   x_msg_data := null;
   x_msg_count := 0;

   --  Standard call to check for call compatibility
   IF NOT FND_API.compatible_api_call
     (l_api_version_number
      ,   p_api_version
      ,   l_api_name
      ,   G_PKG_NAME)
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;


   IF l_debug = 1 then
      print_debug('Entered get_transaction_flow', l_api_name);
      print_debug('p_header_id '||p_header_id, l_api_name);
      print_debug('p_get_default_cost_group '||p_get_default_cost_group, l_api_name);
   END IF;--IF l_debug = 1 then

   FOR l_txn_flows IN txn_flows(p_header_id) LOOP

      rcount := rcount + 1;

      l_transaction_flows_tbl(rcount).HEADER_ID            := l_txn_flows.header_id;
      l_transaction_flows_tbl(rcount).START_ORG_ID         := l_txn_flows.start_org_id;
      l_transaction_flows_tbl(rcount).END_ORG_ID           := l_txn_flows.end_org_id;
      l_transaction_flows_tbl(rcount).ORGANIZATION_ID      := l_txn_flows.organization_id;
      l_transaction_flows_tbl(rcount).ASSET_ITEM_PRICING_OPTION  := l_txn_flows.asset_item_pricing_option;
      l_transaction_flows_tbl(rcount).EXPENSE_ITEM_PRICING_OPTION := l_txn_flows.expense_item_pricing_option;
      l_transaction_flows_tbl(rcount).START_DATE	      := l_txn_flows.start_date;
      l_transaction_flows_tbl(rcount).END_DATE	      := l_txn_flows.end_date;
      l_transaction_flows_tbl(rcount).NEW_ACCOUNTING_FLAG  := l_txn_flows.new_accounting_flag;
      --Line attributes
      l_transaction_flows_tbl(rcount).LINE_NUMBER          := l_txn_flows.line_number;
      l_transaction_flows_tbl(rcount).FROM_ORG_ID          := l_txn_flows.from_org_id;
      l_transaction_flows_tbl(rcount).FROM_ORGANIZATION_ID := l_txn_flows.from_organization_id;
      l_transaction_flows_tbl(rcount).TO_ORG_ID            := l_txn_flows.to_org_id;
      l_transaction_flows_tbl(rcount).TO_ORGANIZATION_ID   := l_txn_flows.to_organization_id;
      --I/C attributes
      l_transaction_flows_tbl(rcount).CUSTOMER_ID          := l_txn_flows.customer_id;
      l_transaction_flows_tbl(rcount).ADDRESS_ID	      := l_txn_flows.address_id;
      l_transaction_flows_tbl(rcount).CUSTOMER_SITE_ID     := l_txn_flows.customer_site_id;
      l_transaction_flows_tbl(rcount).CUST_TRX_TYPE_ID     := l_txn_flows.cust_trx_type_id;
      l_transaction_flows_tbl(rcount).VENDOR_ID	      := l_txn_flows.vendor_id;
      l_transaction_flows_tbl(rcount).VENDOR_SITE_ID       := l_txn_flows.vendor_site_id;
      l_transaction_flows_tbl(rcount).FREIGHT_CODE_COMBINATION_ID  := l_txn_flows.freight_code_combination_id;
      l_transaction_flows_tbl(rcount).INVENTORY_ACCRUAL_ACCOUNT_ID := l_txn_flows.inventory_accrual_account_id;
      l_transaction_flows_tbl(rcount).EXPENSE_ACCRUAL_ACCOUNT_ID   := l_txn_flows.expense_accrual_account_id;
      l_transaction_flows_tbl(rcount).INTERCOMPANY_COGS_ACCOUNT_ID := l_txn_flows.intercompany_cogs_account_id;

      if p_get_default_cost_group in ('Y','y') THEN

	 IF l_txn_flows.from_organization_id IS NOT NULL THEN
	          BEGIN
		     SELECT default_cost_group_id
		       INTO l_transaction_flows_tbl(rcount).From_ORG_COST_GROUP_ID
		       FROM mtl_parameters mp
		       WHERE
		       organization_id =  l_txn_flows.from_organization_id;
		  EXCEPTION
		     WHEN no_data_found THEN
			RAISE fnd_api.g_exc_error;
		  END;
	 END IF;--if l_txn_flows.from_organization_id IS ...

	 IF l_txn_flows.to_organization_id IS NOT NULL THEN
	          BEGIN
		     SELECT default_cost_group_id
		       INTO l_transaction_flows_tbl(rcount).to_ORG_COST_GROUP_ID
		       FROM mtl_parameters mp
		       WHERE
		       organization_id =  l_txn_flows.to_organization_id;
		  EXCEPTION
		     WHEN no_data_found THEN
			RAISE fnd_api.g_exc_error;
		  END;
	 END IF;--IF l_txn_flows.to_organization_id

      END IF;--if p_get_default_cost_group in ('Y','y') THEN



   END LOOP;--l_txn_flows IN txn_flows...

   IF rcount > 0 THEN
      x_transaction_flows_tbl := l_transaction_flows_tbl;
    ELSE

      fnd_message.set_name('INV', 'INV_NO_IC_TXN_FLOW_ID');
      FND_MESSAGE.SET_TOKEN('ID', p_headeR_id);

      fnd_msg_pub.add;
      IF l_debug = 1 THEN
	 print_debug(' No transaction flows found ', l_api_name);
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_transaction_flows_tbl.delete;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_transaction_flows_tbl.delete;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_transaction_flows_tbl.delete;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	  FND_MSG_PUB.Add_Exc_Msg
	    (   G_PACKAGE_NAME, 'GET_TRANSACTION_FLOW');
       end if;
END GET_TRANSACTION_FLOW;


/*======================================================================================================
 * Procedure: CHECK_TRANSACTION_FLOW()
 * Description:
 * This API will be a public API and will be called by PO while user creates the PO Document.
 * This API will return true if a Inter-company Transaction Flow exists between two operating units
 * for user specified date and qualifier.
 *
 * Usage:
 * This API will return true if a Inter-company Transaction Flow exists between two operating units
 * for user specified date and qualifier.
 *
 * Inputs:
 * This API will receive the following input parameters:
 * 1.	Start OU: The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 *      This is a required parameter.
 * 2.	End OU: The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 *      This is a required parameter
 * 3.	Flow Type: To indicate what is the flow type, either Global Procurement or Drop Ship
 * 4.	Array of Qualifier Codes: The qualifier code, for  this release, it will be "1" - Category.
 *      This is an optional parameter. Default value for this parameter is NULL.
 * 5.	Array of Qualifier Value IDs: The value of the qualifier.
 *      For this release, it will be the category_id of the item. This is an optional parameter.
 *      The default value of this parameter will be NULL.
 * 6.	Transaction Date: The date when the transaction will happen.
 * 7.	API version: the version of the API.
 *
 * Outputs:
 * This API will return true if a Inter-company Transaction Flow exists between two operating units
 * for user specified date and qualifier, otherwise, it will return false.
 * The API will also return the header_id for the Inter-company Transaction Flow,
 * and the new_accounting_flag to indicate whether Inter-company Transaction Flow is used or not.
 *======================================================================================================*/
PROCEDURE CHECK_TRANSACTION_FLOW(
	p_api_version		IN		NUMBER
,       p_init_msg_list         IN              VARCHAR2
,	p_start_operating_unit	IN		NUMBER
, 	p_end_operating_unit	IN		NUMBER
,	p_flow_type		IN		NUMBER
,       p_organization_id	IN		NUMBER
, 	p_qualifier_code_tbl	IN		NUMBER_TBL
,	p_qualifier_value_tbl	IN		NUMBER_TBL
, 	p_transaction_date	IN		DATE
,	x_return_status		OUT NOCOPY	VARCHAR2
,	x_msg_count		OUT NOCOPY	NUMBER
,	x_msg_data		OUT NOCOPY	VARCHAR2
, 	x_header_id		OUT NOCOPY 	NUMBER
, 	x_new_accounting_flag	OUT NOCOPY	VARCHAR2
,	x_transaction_flow_exists OUT NOCOPY	VARCHAR2 )
   IS
      CURSOR txn_flow_hdrs(l_start_org_id NUMBER,
		       l_end_org_id NUMBER,
		       l_flow_type NUMBER,
		       l_txn_date DATE)
	IS
	   SELECT
	     t_hdr.HEADER_ID,
	     t_hdr.organization_id,
	     t_hdr.new_accounting_flag,
	     t_hdr.Qualifier_Code,
	     t_hdr.Qualifier_Value_Id
	     FROM
	     mtl_transaction_flow_headers t_hdr
	     WHERE
	     t_hdr.start_org_id = l_start_org_id
	     and t_hdr.end_org_id = l_end_org_id
	     and l_txn_date between t_hdr.start_date and nvl(t_hdr.end_date,l_txn_date+1)
	     and t_hdr.flow_type = l_flow_type
	     ORDER BY
	     t_hdr.organization_id, t_hdr.qualifier_code;

      l_match BOOLEAN;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2(30) := 'CHECK_TRANSACTION_FLOW';
      l_from_ou_name VARCHAR2(240);
      l_to_ou_name VARCHAR2(240);
BEGIN
   x_return_status := g_ret_sts_success;
   x_msg_data := null;
   x_msg_count := 0;
   l_match := FALSE;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
               l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;


   IF l_debug = 1 then
      print_debug('Entered check_transaction_flow', l_api_name);
      print_debug('p_start_operating_unit '||p_start_operating_unit, l_api_name);
      print_debug('p_end_operating_unit '||p_end_operating_unit, l_api_name);
      print_debug('p_flow_type '|| p_flow_type, l_api_name);
      print_debug('p_organization_id '||p_organization_id, l_api_name);
      print_debug('p_transaction_date '||To_char(p_transaction_date,'DD-MON-YYYY HH24:MI:SS'), l_api_name);

      IF p_qualifier_code_tbl.COUNT > 0
	AND p_qualifier_value_tbl.COUNT > 0
	AND p_qualifier_code_tbl.COUNT = p_qualifier_value_tbl.COUNT THEN

	 FOR i IN 1..p_qualifier_code_tbl.COUNT LOOP
	    print_debug('p_qualifier_code_tbl('||i||'):'||p_qualifier_code_tbl(i), l_api_name);
	    print_debug('p_qualifier_value_tbl('||i||'):'||p_qualifier_value_tbl(i), l_api_name);
	 END LOOP;
      END IF;--IF p_qualifier_code_tbl.COUNT > 0....
   END IF;


   FOR l_txn_flow_hdrs IN txn_flow_hdrs(p_start_operating_unit, p_end_operating_unit, p_flow_type,p_transaction_date)  LOOP

      l_match := TRUE;
      IF l_debug = 1 THEN
	 print_debug('verifying match txn flow hdr:'||l_txn_flow_hdrs.header_id, l_api_name);
      END IF;

      /**************************************************************************************************************
      Matching Logic

      l_txn_flow_hdrs.organization_id |p_organization_id  |match
      NOT NULL                        NOT NULL             only when l_txn_flow_hdrs.organization_id=p_organization_id
      NOT NULL                        NULL                 Not a Match
      NULL                            NOT NULL             Match
      NULL                            NULL                 Match
      ****************************************************************************************************************/

      IF Nvl(l_txn_flow_hdrs.organization_id,Nvl(p_organization_id,-9999)) = NVL(p_organization_id,-9999) THEN
	 l_match := TRUE;
       ELSE
	 l_match := FALSE;
      END IF;-- IF l_txn_flow_hdrs.organization_id = p_organization_id

      IF l_debug = 1 THEN
	 print_debug('p_organization_id '||p_organization_id||' compare to '||
		     l_txn_flow_hdrs.organization_id, l_api_name);
	 IF l_match THEN
	    print_debug('l_match TRUE', l_api_name);
	  ELSE
	    print_debug('l_match FALSE', l_api_name);
	 END IF;--IF l_match THEN
      END IF;-- IF l_debug = 1 THEN

      IF l_match THEN

	 IF (p_qualifier_code_tbl.COUNT > 0)
	   AND (p_qualifier_value_tbl.COUNT > 0)
	   AND (p_qualifier_code_tbl.COUNT = p_qualifier_value_tbl.COUNT) THEN

	    IF l_debug = 1 THEN
	       print_debug('p_qualifier_code_tbl(1) '||p_qualifier_code_tbl(1)||' compare to '||
			   l_txn_flow_hdrs.qualifier_code, l_api_name);
	    end if;

	    IF Nvl(l_txn_flow_hdrs.qualifier_code, Nvl(p_qualifier_code_tbl(1),-9999)) = Nvl(p_qualifier_code_tbl(1),-9999)
	      AND Nvl(l_txn_flow_hdrs.qualifier_value_id,Nvl(p_qualifier_value_tbl(1),-9999)) = Nvl(p_qualifier_value_tbl(1),-9999)  THEN
	       l_match := TRUE;
	     ELSE
	       l_match := FALSE;
	    END IF;
	  ELSIF l_txn_flow_hdrs.qualifier_code IS NULL
	    AND l_txn_flow_hdrs.qualifier_value_id IS NULL THEN
	    l_match := TRUE;
	  ELSE
	    l_match := FALSE;
	 END IF;

	 IF l_debug = 1 THEN
	    IF l_match THEN
	       print_debug('l_match TRUE', l_api_name);
	     ELSE
	       print_debug('l_match FALSE', l_api_name);
	    END IF;--IF l_match THEN
	 END IF;-- IF l_debug = 1 THEN

      END IF;----IF l_match THEN

      IF l_match THEN
	 x_header_id := l_txn_flow_hdrs.header_id;
	 x_new_accounting_flag :=  l_txn_flow_hdrs.new_accounting_flag;
	 x_transaction_flow_exists := g_transaction_flow_found;
	 IF l_debug = 1 THEN
	    print_debug('match txn flow hdr:'||l_txn_flow_hdrs.header_id, l_api_name);
	    print_debug('new_accounting_flag:'||l_txn_flow_hdrs.new_accounting_flag, l_api_name);
	 END IF;
	 EXIT;
       ELSE
	 IF l_debug = 1 THEN
	    print_debug('not match txn flow hdr:'||l_txn_flow_hdrs.header_id, l_api_name);
	 END IF;
      END IF;
   END LOOP;

   IF NOT l_match THEN
      BEGIN
	select name
	into l_from_ou_name
	FROM hr_organization_units
	WHERE organization_id = p_start_operating_unit;

      EXCEPTION
	when no_data_found then
	FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_START_ORG');
	FND_MSG_PUB.ADD;
	raise fnd_api.g_exc_error;
      end;

      BEGIN
	select name
	into l_to_ou_name
	FROM hr_organization_units
	WHERE organization_id = p_end_operating_unit;
      EXCEPTION
	when no_data_found then
	FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_END_ORG');
	FND_MSG_PUB.ADD;
	raise fnd_api.g_exc_error;
      end;

      fnd_message.set_name('INV', 'INV_NO_IC_TXN_FLOW');
      FND_MESSAGE.SET_TOKEN('FROM_OU', l_from_ou_name);
      FND_MESSAGE.SET_TOKEN('TO_OU', l_to_ou_name);
      fnd_msg_pub.add;

      IF l_debug = 1 THEN
	 print_debug(' No matching transaction flows found ', l_api_name);
      END IF;
      x_header_id := NULL;
      x_new_accounting_flag := NULL;
      x_transaction_flow_exists := G_TRANSACTION_FLOW_NOT_FOUND;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_transaction_flow_exists :=  G_TRANSACTION_FLOW_NOT_FOUND;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_transaction_flow_exists :=  G_TRANSACTION_FLOW_NOT_FOUND;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_transaction_flow_exists :=  G_TRANSACTION_FLOW_NOT_FOUND;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'CHECK_TRANSACTION_FLOW');
      end if;
END CHECK_TRANSACTION_FLOW;

/*=======================================================================================================
 * Procedure: Insert_Row()
 * This API is a private API to insert new transaction flow for  a start operating unit and end operating unit.
 * This API will be called by the Transaction Flow Setup Form on the ON-INSERT trigger of the block.
 * Inputs:
 *
 * 1.	Start OU: The start Operating Unit for which the Global Procurement or Drop Ship occurred.
 *      This is a required parameter.
 * 2.	End OU: The End Operating Unit for which the Global Procurement of Drop Ship occurred.
 *      This is a required parameter
 * 3.	Flow Type: To indicate what is the flow type, either Global Procurement or Drop Ship
 * 4.	Qualifier Code: The qualifier code, for  this release, it will be "1" - Category.
 *      This is an optional parameter. Default value for this parameter is NULL.
 * 5.	Qualifier Value ID: The value of the qualifier.
 *      For this release, it will be the category_id of the item. The default value of this parameter will be NULL.
 * 6.	Start Date: The date when the Inter-company Transaction Flow become active.
 *      The default value is SYSDATE. This is required parameter
 * 7.	End Date: The date when the when Inter-company Transaction Flow become inactive.
 * 8.	Asset Item Pricing Option: The pricing option for asset item for global procurement flow.
 * 9.	Expense Item Pricing option: the pricing option for expense item
 * 10.	new accounting flag : flag to indicate new accounting will be use
 * 11.	line_number_tbl - list of sequence of the line nodes
 * 12.	from_ou_tbl - list of from operating unit of the line nodes
 * 13.	to_ou_tbl - list of to_operating unit of the line nodes
 *
 * Outputs:
 * 1.	header_id
 * 2.	line_number
 *
 *=======================================================================================================*/
PROCEDURE create_transaction_flow
(
  x_return_status		OUT NOCOPY 	VARCHAR2
, x_msg_data			OUT NOCOPY 	VARCHAR2
, x_msg_count			OUT NOCOPY 	NUMBER
, x_header_id			OUT NOCOPY	NUMBER
, x_line_number_tbl		OUT NOCOPY	NUMBER_TBL
, p_api_version                 IN              NUMBER
, p_init_msg_list               IN              VARCHAR2
, p_validation_level		IN		NUMBER
, p_start_org_id	 	IN 		NUMBER
, p_end_org_id			IN		NUMBER
, p_flow_type			IN		NUMBER
, p_organization_id             IN              NUMBER
, p_qualifier_code		IN		NUMBER
, p_qualifier_value_id		IN		NUMBER
, p_asset_item_pricing_option 	IN		NUMBER
, p_expense_item_pricing_option IN 		NUMBER
, p_new_accounting_flag		IN		VARCHAR2
, p_start_date                  IN              DATE
, p_end_date                    IN              DATE
, P_Attribute_Category          IN              VARCHAR2
, P_Attribute1                  IN              VARCHAR2
, P_Attribute2                  IN              VARCHAR2
, P_Attribute3                  IN              VARCHAR2
, P_Attribute4                  IN              VARCHAR2
, P_Attribute5                  IN              VARCHAR2
, P_Attribute6                  IN              VARCHAR2
, P_Attribute7                  IN              VARCHAR2
, P_Attribute8                  IN              VARCHAR2
, P_Attribute9                  IN              VARCHAR2
, P_Attribute10                 IN              VARCHAR2
, P_Attribute11                 IN              VARCHAR2
, P_Attribute12                 IN              VARCHAR2
, P_Attribute13                 IN              VARCHAR2
, P_Attribute14                 IN              VARCHAR2
, P_Attribute15                 IN              VARCHAR2
, p_line_number_tbl		     IN		NUMBER_TBL
, p_from_org_id_tbl		     IN		NUMBER_TBL
, p_from_organization_id_tbl	     IN 	NUMBER_TBL
, p_to_org_id_tbl		     IN		NUMBER_TBL
, p_to_organization_id_tbl	     IN 	NUMBER_TBL
, P_LINE_Attribute_Category_tbl      IN         VARCHAR2_tbl
, P_LINE_Attribute1_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute2_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute3_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute4_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute5_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute6_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute7_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute8_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute9_tbl              IN         VARCHAR2_tbl
, P_LINE_Attribute10_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute11_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute12_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute13_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute14_tbl             IN         VARCHAR2_tbl
, P_LINE_Attribute15_tbl             IN         VARCHAR2_tbl
, P_Ship_Organization_Id_tbl             IN         NUMBER_tbl
, P_Sell_Organization_Id_tbl             IN         NUMBER_tbl
, P_Vendor_Id_tbl                        IN         NUMBER_tbl
, P_Vendor_Site_Id_tbl                   IN         NUMBER_tbl
, P_Customer_Id_tbl                      IN         NUMBER_tbl
, P_Address_Id_tbl                       IN         NUMBER_tbl
, P_Customer_Site_Id_tbl                 IN         NUMBER_tbl
, P_Cust_Trx_Type_Id_tbl                 IN         NUMBER_tbl
, P_IC_Attribute_Category_tbl            IN         VARCHAR2_tbl
, P_IC_Attribute1_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute2_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute3_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute4_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute5_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute6_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute7_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute8_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute9_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute10_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute11_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute12_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute13_tbl                   IN         VARCHAR2_tbl
, P_IC_Attribute14_tbl                    IN         VARCHAR2_tbl
, P_IC_Attribute15_tbl                   IN         VARCHAR2_tbl
, P_Revalue_Average_Flag_tbl             IN         VARCHAR2_tbl
, P_Freight_Code_Comb_Id_tbl      IN         NUMBER_tbl
, p_inv_currency_code_tbl	  IN	NUMBER_tbl
, P_IC_COGS_Acct_Id_tbl     IN         NUMBER_tbl
, P_Inv_Accrual_Acct_Id_tbl     IN         NUMBER_tbl
, P_Exp_Accrual_Acct_Id_tbl       IN         NUMBER_tbl
) IS

      l_lines_tab        INV_TRANSACTION_FLOW_PVT.trx_flow_lines_tab;
      l_line_number_tbl  NUMBER_TBL;
      l_header_id        NUMBER := NULL;
      l_line_number      NUMBER := NULL;
      l_ref_date         DATE := Sysdate;
      l_return_status    VARCHAR2(1) := NULL;
      l_msg_data         VARCHAR2(2000):= NULL;
      l_msg_count        NUMBER := NULL;
      l_ic_rowid         VARCHAR2(2000);
      l_valid            VARCHAR2(1) := NULL;
   l_api_version_number CONSTANT NUMBER := 1.0;
   l_api_name CONSTANT VARCHAR2(30) := 'CREATE_TRANSACTION_FLOW';
BEGIN

   x_return_status := G_RET_STS_SUCCESS;
   x_msg_data := null;
   x_msg_count := 0;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
               l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   SELECT mtl_transaction_flow_headers_s.NEXTVAL
     INTO l_header_id FROM dual;

   l_line_number := 0;

   SAVEPOINT CREATE_TRANSACTION_FLOW;

   FOR i IN 1..p_line_number_tbl.COUNT LOOP

      l_line_number := l_line_number + 1;
      l_line_number_tbl(i) := l_line_number;

      l_lines_tab(i).HEADER_ID             := l_header_id;
      l_lines_tab(i).LINE_NUMBER           := l_line_number;
      l_lines_tab(i).FROM_ORG_ID           := p_from_org_id_tbl(i);
      l_lines_tab(i).FROM_ORGANIZATION_ID  := p_from_organization_id_tbl(i);
      l_lines_tab(i).TO_ORG_ID             := p_to_org_id_tbl(i) ;
      l_lines_tab(i).TO_ORGANIZATION_ID    := p_to_organization_id_tbl(i);
      l_lines_tab(i).ATTRIBUTE_CATEGORY    := p_line_attribute_category_tbl(i);
      l_lines_tab(i).ATTRIBUTE1            := p_line_attribute1_tbl(i);
      l_lines_tab(i).ATTRIBUTE2            := p_line_attribute2_tbl(i);
      l_lines_tab(i).ATTRIBUTE3            := p_line_attribute3_tbl(i);
      l_lines_tab(i).ATTRIBUTE4            := p_line_attribute4_tbl(i);
      l_lines_tab(i).ATTRIBUTE5            := p_line_attribute5_tbl(i);
      l_lines_tab(i).ATTRIBUTE6            := p_line_attribute6_tbl(i);
      l_lines_tab(i).ATTRIBUTE7            := p_line_attribute7_tbl(i);
      l_lines_tab(i).ATTRIBUTE8            := p_line_attribute8_tbl(i);
      l_lines_tab(i).ATTRIBUTE9            := p_line_attribute9_tbl(i);
      l_lines_tab(i).ATTRIBUTE10           := p_line_attribute10_tbl(i);
      l_lines_tab(i).ATTRIBUTE11           := p_line_attribute11_tbl(i);
      l_lines_tab(i).ATTRIBUTE12           := p_line_attribute12_tbl(i);
      l_lines_tab(i).ATTRIBUTE13           := p_line_attribute13_tbl(i);
      l_lines_tab(i).ATTRIBUTE14           := p_line_attribute14_tbl(i);
      l_lines_tab(i).ATTRIBUTE15           := p_line_attribute15_tbl(i);

      DECLARE
        vDummy VARCHAR2(30);
      BEGIN

        SELECT 'ic_relation_exists' INTO vDummy
	    FROM MTL_INTERCOMPANY_PARAMETERS
        WHERE ship_organization_id = p_from_org_id_tbl(i)
        AND sell_organization_id = p_to_org_id_tbl(i)
	    AND flow_type = p_flow_type;

	IF (g_debug=1) THEN
          print_debug('IC RELATION ALREADY EXISTS HENCE SKIP THIS RECORD, Ship Org=' || p_ship_organization_id_tbl(i) || ', Sell Org=' || p_Sell_Organization_Id_tbl(i));
        END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN

        IF (g_debug=1) THEN
          print_debug('NO IC RELATION EXISTS HENCE GO AHEAD AND CREATE, Ship Org=' || p_ship_organization_id_tbl(i) || ', Sell Org=' || p_Sell_Organization_Id_tbl(i));
        END IF;

      inv_transaction_flow_pub.validate_ic_relation_rec
	(x_return_status                =>  l_return_status,
	 x_msg_data                     =>  l_msg_data,
	 x_msg_count                    =>  l_msg_count,
	 x_valid                        =>  l_valid,
	 p_api_version                  =>  p_api_version,
	 p_init_msg_list                =>  G_FALSE,
	 p_ship_organization_id         =>  p_from_org_id_tbl(i),
	 p_sell_organization_id         =>  p_to_org_id_tbl(i),
	 p_vendor_id                    =>  p_vendor_id_tbl(i),
	 p_vendor_site_id               =>  p_vendor_site_id_tbl(i),
	 p_customer_id                  =>  p_customer_id_tbl(i),
	 p_address_id                   =>  p_address_id_tbl(i),
	 p_customer_site_id             =>  p_customer_site_id_tbl(i),
	 p_cust_trx_type_id             =>  p_cust_trx_type_id_tbl(i),
	 p_attribute_category           =>  p_ic_attribute_category_tbl(i),
	 p_attribute1                   =>  p_ic_attribute1_tbl(i),
	 p_attribute2                   => p_ic_attribute2_tbl(i),
	p_attribute3                   =>  p_ic_attribute3_tbl(i),
	p_attribute4                   =>  p_ic_attribute4_tbl(i),
	p_attribute5                   =>  p_ic_attribute5_tbl(i),
	p_attribute6                    =>  p_ic_attribute6_tbl(i),
	p_attribute7                    =>  p_ic_attribute7_tbl(i),
	p_attribute8                    =>  p_ic_attribute8_tbl(i),
	p_attribute9                    =>  p_ic_attribute9_tbl(i),
	p_attribute10                   =>  p_ic_attribute10_tbl(i),
	p_attribute11                   =>  p_ic_attribute11_tbl(i),
	p_attribute12                   =>  p_ic_attribute12_tbl(i),
	p_attribute13                   =>  p_ic_attribute13_tbl(i),
	p_attribute14                   =>  p_ic_attribute14_tbl(i),
	p_attribute15                   =>  p_ic_attribute15_tbl(i),
	p_revalue_average_flag          =>  p_revalue_average_flag_tbl(i),
	p_freight_code_combination_id   =>  p_freight_code_comb_id_tbl(i),
	p_inv_currency_code		=>  p_inv_currency_code_tbl(i),
	p_flow_type                     =>  p_flow_type,
	p_intercompany_cogs_account_id  =>  p_IC_COGS_Acct_Id_tbl(i),
	p_inventory_accrual_account_id  =>   p_Inv_Accrual_Acct_Id_tbl(i) ,
	p_expense_accrual_account_id    =>   p_Exp_Accrual_Acct_Id_tbl(i)
	);

	IF (g_debug=1) THEN
     print_debug('After validation of IC RELATION , Ship Org=' || p_ship_organization_id_tbl(i) || ', Sell Org=' || p_Sell_Organization_Id_tbl(i) || ', Return Status=' || l_return_status);
   END IF;

   IF l_return_status = g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;

   ELSIF l_valid = g_true THEN

	IF (g_debug=1) THEN
    print_debug('Before MTL_IC_PARAMETERS_PKG.INSERT_ROW call...');
   END IF;

   MTL_IC_PARAMETERS_PKG.INSERT_ROW
	   (X_Rowid                   => l_ic_rowid,
	    X_Ship_Organization_Id    => p_from_org_id_tbl(i),
	    X_Sell_Organization_Id    => p_to_org_id_tbl(i),
	    X_Last_Update_Date        => Sysdate,
	    X_Last_Updated_By         => FND_GLOBAL.user_id,
	    X_Creation_Date           => Sysdate,
	    X_Created_By              => FND_GLOBAL.user_id,
	    X_Last_Update_Login       => fnd_global.login_id,
	    X_Vendor_Id               => p_vendor_id_tbl(i),
	    X_Vendor_Site_Id          => p_vendor_site_id_tbl(i),
	    X_Customer_Id             => p_customer_id_tbl(i),
	    X_Address_Id              => p_address_id_tbl(i),
	    X_Customer_Site_Id        => p_customer_site_id_tbl(i),
	    X_Cust_Trx_Type_Id        => p_cust_trx_type_id_tbl(i),
	    X_Attribute_Category      => p_ic_attribute_category_tbl(i),
	    X_Attribute1              => p_ic_attribute1_tbl(i),
	    X_Attribute2              => p_ic_attribute2_tbl(i),
	    X_Attribute3              => p_ic_attribute3_tbl(i),
	   X_Attribute4              => p_ic_attribute4_tbl(i),
	   X_Attribute5              => p_ic_attribute5_tbl(i),
	   X_Attribute6               => p_ic_attribute6_tbl(i),
	   X_Attribute7               => p_ic_attribute7_tbl(i),
	   X_Attribute8               => p_ic_attribute8_tbl(i),
	   X_Attribute9               => p_ic_attribute9_tbl(i),
	   X_Attribute10              => p_ic_attribute10_tbl(i),
	   X_Attribute11              => p_ic_attribute11_tbl(i),
	   X_Attribute12              => p_ic_attribute12_tbl(i),
	   X_Attribute13              => p_ic_attribute13_tbl(i),
	   X_Attribute14              => p_ic_attribute14_tbl(i),
	   X_Attribute15              => p_ic_attribute15_tbl(i),
	   X_Revalue_Average_Flag     => p_revalue_average_flag_tbl(i),
	   X_Freight_Code_Combination_Id   => p_freight_code_comb_id_tbl(i),
	   X_Inv_Currency_Code		=> p_inv_currency_code_tbl(i),
	   X_Flow_Type                     => p_flow_type,
	   X_Intercompany_COGS_Account_Id  => p_IC_COGS_Acct_Id_tbl(i) ,
	   X_Inventory_Accrual_Account_Id  => p_Inv_Accrual_Acct_Id_tbl(i) ,
	   X_Expense_Accrual_Account_Id    => p_Exp_Accrual_Acct_Id_tbl(i));

	IF (g_debug=1) THEN
          print_debug('After MTL_IC_PARAMETERS_PKG.INSERT_ROW call...');
        END IF;

      END IF;
      END;
   END LOOP;

   l_return_status := NULL;
   l_msg_count := NULL;
   l_msg_data := NULL;

	IF (g_debug=1) THEN
          print_debug('Before inv_transaction_flow_pvt.create_ic_transaction_flow call...');
        END IF;

   inv_transaction_flow_pvt.create_ic_transaction_flow
     (x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data,
      p_header_id                   => l_header_id,
      p_commit                      => false,
      p_validation_level            => fnd_api.g_valid_level_full,
      p_start_org_id                => p_start_org_id,
      p_end_org_id                  => p_end_org_id,
      p_flow_type                   => p_flow_type,
      p_organization_id             => p_organization_id,
      p_qualifier_code              => p_qualifier_code,
      p_qualifier_value_id          => p_qualifier_value_id,
      p_asset_item_pricing_option   => p_asset_item_pricing_option,
      p_expense_item_pricing_option => p_expense_item_pricing_option,
      p_start_date                   => p_start_date,
      p_end_date                     => p_end_date,
      p_new_accounting_flag          => p_new_accounting_flag,
     p_attribute_category           => p_attribute_category,
     p_attribute1                   => p_attribute1,
     p_attribute2                   => p_attribute2,
     p_attribute3                   => p_attribute3,
     p_attribute4                   => p_attribute4,
     p_attribute5                   => p_attribute5,
     p_attribute6                   => p_attribute6,
     p_attribute7                   => p_attribute7,
     p_attribute8                   => p_attribute8,
     p_attribute9                   => p_attribute9,
     p_attribute10                  => p_attribute10,
     p_attribute11                  => p_attribute11,
     p_attribute12                  => p_attribute12,
     p_attribute13                  => p_attribute13,
     p_attribute14                  => p_attribute14,
     p_attribute15                  => p_attribute15,
     p_ref_date                     => l_ref_date,
     p_lines_tab                    => l_lines_tab
     );

   IF (g_debug=1) THEN
     print_debug('After inv_transaction_flow_pvt.create_ic_transaction_flow call... Return Status=' || l_return_status);
   END IF;

   IF l_return_status = fnd_api.g_ret_sts_success THEN
      x_header_id := l_header_id;
      x_line_number_tbl := l_line_number_tbl;
    ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_transaction_flow;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_header_id := NULL;
      x_line_number_tbl.DELETE;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_transaction_flow;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_header_id := NULL;
      x_line_number_tbl.DELETE;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO create_transaction_flow;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_header_id := NULL;
      x_line_number_tbl.DELETE;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'CREATE_TRANSACTION_FLOW');
      end if;

END CREATE_TRANSACTION_FLOW;

/*========================================================================================================
 * Procedure: Update_Transaction_Flow()
 *
 * Description:
 * This API is used to update the transaction flow. Once a transaction flow is created, user can only
 * update the start date and the end date and desc flex field attributes of headers and lines and the Ic relation
 * defined.
 *
 *
 *
 *========================================================================================================*/

PROCEDURE update_transaction_flow
(
  x_return_status		           OUT NOCOPY 	   VARCHAR2
, x_msg_data			           OUT NOCOPY 	   VARCHAR2
, x_msg_count			           OUT NOCOPY 	   NUMBER
, p_api_version                 IN              NUMBER
, p_init_msg_list               IN              VARCHAR2
, p_validation_level		        IN		         NUMBER
, p_header_id                   IN              NUMBER
, p_flow_type                   IN              NUMBER
, p_start_date                  IN              DATE
, p_end_date                    IN              DATE
, P_Attribute_Category          IN              VARCHAR2
, P_Attribute1                  IN              VARCHAR2
, P_Attribute2                  IN              VARCHAR2
, P_Attribute3                  IN              VARCHAR2
, P_Attribute4                  IN              VARCHAR2
, P_Attribute5                  IN              VARCHAR2
, P_Attribute6                  IN              VARCHAR2
, P_Attribute7                  IN              VARCHAR2
, P_Attribute8                  IN              VARCHAR2
, P_Attribute9                  IN              VARCHAR2
, P_Attribute10                 IN              VARCHAR2
, P_Attribute11                 IN              VARCHAR2
, P_Attribute12                 IN              VARCHAR2
, P_Attribute13                 IN              VARCHAR2
, P_Attribute14                 IN              VARCHAR2
, P_Attribute15                 IN              VARCHAR2
, p_line_number_tbl		        IN	            NUMBER_TBL
, P_LINE_Attribute_Category_tbl IN              VARCHAR2_tbl
, P_LINE_Attribute1_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute2_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute3_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute4_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute5_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute6_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute7_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute8_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute9_tbl         IN              VARCHAR2_tbl
, P_LINE_Attribute10_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute11_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute12_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute13_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute14_tbl        IN              VARCHAR2_tbl
, P_LINE_Attribute15_tbl        IN              VARCHAR2_tbl
, P_Ship_Organization_Id_tbl    IN              NUMBER_tbl
, P_Sell_Organization_Id_tbl    IN              NUMBER_tbl
, P_Vendor_Id_tbl               IN              NUMBER_tbl
, P_Vendor_Site_Id_tbl          IN              NUMBER_tbl
, P_Customer_Id_tbl             IN              NUMBER_tbl
, P_Address_Id_tbl              IN              NUMBER_tbl
, P_Customer_Site_Id_tbl        IN              NUMBER_tbl
, P_Cust_Trx_Type_Id_tbl        IN              NUMBER_tbl
, P_IC_Attribute_Category_tbl   IN              VARCHAR2_tbl
, P_IC_Attribute1_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute2_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute3_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute4_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute5_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute6_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute7_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute8_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute9_tbl           IN              VARCHAR2_tbl
, P_IC_Attribute10_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute11_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute12_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute13_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute14_tbl          IN              VARCHAR2_tbl
, P_IC_Attribute15_tbl          IN              VARCHAR2_tbl
, P_Revalue_Average_Flag_tbl    IN              VARCHAR2_tbl
, P_Freight_Code_Comb_Id_tbl    IN              NUMBER_tbl
, p_inv_currency_code_tbl	     IN	            NUMBER_tbl
, P_IC_COGS_Acct_Id_tbl         IN              NUMBER_tbl
, P_Inv_Accrual_Acct_Id_tbl     IN              NUMBER_tbl
, P_Exp_Accrual_Acct_Id_tbl     IN              NUMBER_tbl
) IS

      l_return_status      VARCHAR2(1) := NULL;
      l_msg_data           VARCHAR2(2000):= NULL;
      l_msg_count          NUMBER := NULL;
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name           CONSTANT VARCHAR2(30) := 'UPDATE_TRANSACTION_FLOW';
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
   x_msg_data := null;
   x_msg_count := 0;

   SAVEPOINT UPDATE_TRANSACTION_FLOW;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
               l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF (g_debug=1) THEN
     print_debug('Before inv_transaction_flow_pub.update_transaction_flow_header call...');
   END IF;

   inv_transaction_flow_pub.update_transaction_flow_header
     (x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_api_version                  => p_api_version,
      p_init_msg_list                => G_FALSE,
      p_header_id                    => p_header_id,
      p_start_date                   => p_start_date,
      p_end_date                     => p_end_date,
      p_attribute_category           => p_attribute_category,
      p_attribute1                   => p_attribute1,
      p_attribute2                   => p_attribute2,
      p_attribute3                   => p_attribute3,
      p_attribute4                   => p_attribute4,
      p_attribute5                   => p_attribute5,
      p_attribute6                   => p_attribute6,
      p_attribute7                   => p_attribute7,
      p_attribute8                   => p_attribute8,
      p_attribute9                   => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
      p_attribute12                  => p_attribute12,
      p_attribute13                  => p_attribute13,
      p_attribute14                  => p_attribute14,
      p_attribute15                  => p_attribute15
     );

   IF (g_debug=1) THEN
     print_debug('After inv_transaction_flow_pub.update_transaction_flow_header call... Return Status=' || l_return_status);
   END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

  l_return_status:=NULL;
  l_msg_data:=NULL;
  l_msg_count:=NULL;

   FOR i IN 1..p_line_number_tbl.COUNT LOOP

     IF (g_debug=1) THEN
       print_debug('Before inv_transaction_flow_pub.update_transaction_flow_line call...');
     END IF;

    inv_transaction_flow_pub.update_transaction_flow_line
   (    x_return_status       => l_return_status
      , x_msg_data            => l_msg_data
      , x_msg_count           => l_msg_count
      , p_api_version         => p_api_version
      , p_init_msg_list       => G_FALSE
      , p_header_id           => p_header_id
      , p_line_number         => p_line_number_tbl(i)
      , p_attribute_category  => p_line_attribute_category_tbl(i)
      , p_attribute1          => p_line_attribute1_tbl(i)
      , p_attribute2          => p_line_attribute2_tbl(i)
      , p_attribute3          => p_line_attribute3_tbl(i)
      , p_attribute4          => p_line_attribute4_tbl(i)
      , p_attribute5          => p_line_attribute5_tbl(i)
      , p_attribute6          => p_line_attribute6_tbl(i)
      , p_attribute7          => p_line_attribute7_tbl(i)
      , p_attribute8          => p_line_attribute8_tbl(i)
      , p_attribute9          => p_line_attribute9_tbl(i)
      , p_attribute10         => p_line_attribute10_tbl(i)
      , p_attribute11          => p_line_attribute11_tbl(i)
      , p_attribute12          => p_line_attribute12_tbl(i)
     ,  p_attribute13          => p_line_attribute13_tbl(i)
     ,  p_attribute14          => p_line_attribute14_tbl(i)
     ,  p_attribute15          => p_line_attribute15_tbl(i)
     );

     IF (g_debug=1) THEN
       print_debug('After inv_transaction_flow_pub.update_transaction_flow_line call... Return Status=' || l_return_status);
     END IF;

     IF l_return_status = g_ret_sts_error THEN
	  RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = g_ret_sts_unexp_error THEN
	  RAISE fnd_api.g_exc_unexpected_error;
     END IF;
    l_return_status:=NULL;
    l_msg_data:=NULL;
    l_msg_count:=NULL;

     IF (g_debug=1) THEN
       print_debug('Before inv_transaction_flow_pub.update_ic_relation call...');
     END IF;

	 inv_transaction_flow_pub.update_ic_relation
   (x_return_status          =>  l_return_status,
    x_msg_data               =>  l_msg_data,
    x_msg_count              =>  l_msg_count,
    p_api_version            =>  p_api_version,
    p_init_msg_list          =>  G_FALSE,
    p_Ship_Organization_Id   =>  p_ship_organization_id_tbl(i),
    p_Sell_Organization_Id   =>  p_Sell_Organization_Id_tbl(i),
    p_Vendor_Id              =>  p_vendor_id_tbl(i),
    p_Vendor_Site_Id         =>  p_vendor_site_id_tbl(i),
    p_Customer_Id            =>  p_customer_id_tbl(i) ,
    p_Address_Id             =>  p_address_id_tbl(i) ,
    p_Customer_Site_Id       =>  p_customer_site_id_tbl(i) ,
    p_Cust_Trx_Type_Id       =>  p_cust_trx_type_id_tbl(i) ,
    p_Attribute_Category     =>  p_ic_attribute_category_tbl(i) ,
    p_Attribute1             =>  p_ic_attribute1_tbl(i) ,
    p_Attribute2             =>  p_ic_attribute2_tbl(i) ,
    p_Attribute3             =>  p_ic_attribute3_tbl(i) ,
    p_Attribute4             =>  p_ic_attribute4_tbl(i) ,
    p_Attribute5             =>  p_ic_attribute5_tbl(i) ,
    p_Attribute6             =>  p_ic_attribute6_tbl(i) ,
    p_Attribute7             =>  p_ic_attribute7_tbl(i) ,
    p_Attribute8             =>  p_ic_attribute8_tbl(i) ,
    p_Attribute9             =>  p_ic_attribute9_tbl(i) ,
    p_Attribute10             => p_ic_attribute10_tbl(i) ,
    p_Attribute11             => p_ic_attribute11_tbl(i) ,
    p_Attribute12             => p_ic_attribute12_tbl(i) ,
    p_Attribute13             => p_ic_attribute13_tbl(i) ,
    p_Attribute14             => p_ic_attribute14_tbl(i) ,
    p_Attribute15             => p_ic_attribute15_tbl(i) ,
    p_Revalue_Average_Flag    => p_revalue_average_flag_tbl(i) ,
    p_Freight_Code_Combination_Id =>p_freight_code_comb_id_tbl(i),
    p_inv_currency_code		  => p_inv_currency_code_tbl(i),
    p_Flow_Type               =>p_flow_type,
    p_Intercompany_COGS_Account_Id =>p_IC_COGS_Acct_Id_tbl(i),
    p_Inventory_Accrual_Account_Id => p_Inv_Accrual_Acct_Id_tbl(i),
    p_Expense_Accrual_Account_Id  => p_Exp_Accrual_Acct_Id_tbl(i)

  );

     IF (g_debug=1) THEN
       print_debug('After inv_transaction_flow_pub.update_ic_relation call...Return Status=' || l_return_status);
     END IF;

    IF l_return_status = g_ret_sts_error THEN
	 RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = g_ret_sts_unexp_error THEN
	 RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  END LOOP;



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_TRANSACTION_FLOW;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_TRANSACTION_FLOW;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_TRANSACTION_FLOW;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	   FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'CREATE_TRANSACTION_FLOW');
      end if;

END UPDATE_TRANSACTION_FLOW;

/*========================================================================================================*/


   PROCEDURE update_transaction_flow_header
   (X_return_status	    OUT NOCOPY	VARCHAR2
    , x_msg_data	    OUT NOCOPY	VARCHAR2
    , x_msg_count	    OUT NOCOPY	NUMBER
    , p_api_version         IN          NUMBER
    , p_init_msg_list       IN          VARCHAR2 DEFAULT G_FALSE
    , p_header_id	    IN		NUMBER
    , p_end_date	    IN		DATE
    , p_start_date	    IN		DATE
    , P_Attribute_Category  IN          VARCHAR2
    , P_Attribute1          IN          VARCHAR2
    , P_Attribute2          IN          VARCHAR2
    , P_Attribute3          IN          VARCHAR2
    , P_Attribute4          IN          VARCHAR2
    , P_Attribute5          IN          VARCHAR2
    , P_Attribute6          IN          VARCHAR2
    , P_Attribute7          IN          VARCHAR2
    , P_Attribute8          IN          VARCHAR2
    , P_Attribute9          IN          VARCHAR2
    , P_Attribute10         IN          VARCHAR2
    , P_Attribute11         IN          VARCHAR2
    , P_Attribute12         IN          VARCHAR2
    , P_Attribute13         IN         VARCHAR2
   , P_Attribute14          IN          VARCHAR2
   , P_Attribute15          IN          VARCHAR2)
   IS


      l_ref_date         DATE := Sysdate;
      l_return_status    VARCHAR2(1) := NULL;
      l_msg_data         VARCHAR2(2000):= NULL;
      l_msg_count        NUMBER := NULL;
      l_lines_tab        INV_TRANSACTION_FLOW_PVT.trx_flow_lines_tab;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_TRANSACTION_FLOW_HEADER';
   BEGIN

      x_return_status := G_RET_STS_SUCCESS;
      x_msg_data := null;
      x_msg_count := 0;

      --  Standard call to check for call compatibility
      IF NOT FND_API.compatible_api_call
	(l_api_version_number
	 ,   p_api_version
	 ,   l_api_name
	 ,   G_PKG_NAME)
	THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --  Initialize message list.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
	 fnd_msg_pub.initialize;
      END IF;


      SAVEPOINT UPDATE_TRANSACTION_FLOW_HEADER;

      l_lines_tab.DELETE;

      inv_transaction_flow_pvt.update_ic_txn_flow_hdr
	(x_return_status               => l_return_status,
	 x_msg_count                   => l_msg_count,
	 x_msg_data                    => l_msg_data,
	 p_header_id                   => p_header_id,
	 p_commit                      => false,
	 p_start_date                  => p_start_date,
	 p_end_date                    => p_end_date,
	 p_ref_date                    => l_ref_date,
	 p_attribute_category          => p_attribute_category,
	 p_attribute1                  => p_attribute1,
	 p_attribute2                  => p_attribute2,
	 p_attribute3                  => p_attribute3,
	 p_attribute4                  => p_attribute4,
	 p_attribute5                  => p_attribute5,
	 p_attribute6                  => p_attribute6,
	 p_attribute7                  => p_attribute7,
	 p_attribute8                   => p_attribute8,
	 p_attribute9                   => p_attribute9,
	p_attribute10                  => p_attribute10,
	p_attribute11                  => p_attribute11,
	p_attribute12                  => p_attribute12,
	p_attribute13                  => p_attribute13,
	p_attribute14                  => p_attribute14,
	p_attribute15                  => p_attribute15
	);

      IF l_debug = 1 THEN
	 print_debug('l_return_status from'||
		     'inv_transaction_flow_pvt.update_ic_txn_flow_hdr'||
		     x_return_status,l_api_name);
      END IF;

   IF l_return_status = g_ret_sts_success THEN
      --Successful
      x_return_status := l_return_status;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      IF l_debug = 1 THEN
	 print_debug('l_msg_data from'||
		     'inv_transaction_flow_pvt.update_ic_txn_flow_hdr'||
		     l_msg_data,l_api_name);
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSE
      IF l_debug = 1 THEN
	 print_debug('l_msg_data from'||
		     'inv_transaction_flow_pvt.update_ic_txn_flow_hdr'||
		     l_msg_data,l_api_name);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_TRANSACTION_FLOW_HEADER;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_TRANSACTION_FLOW_HEADER;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      WHEN OTHERS THEN
      ROLLBACK TO UPDATE_TRANSACTION_FLOW_HEADER;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'UPDATE_TRANSACTION_FLOW_HEADER');
      end if;
   END Update_Transaction_Flow_Header;



   PROCEDURE update_transaction_flow_line
     (x_return_status          OUT NOCOPY VARCHAR2
      , x_msg_data             OUT NOCOPY VARCHAR2
      , x_msg_count            OUT NOCOPY VARCHAR2
      , p_api_version          IN          NUMBER
      , p_init_msg_list        IN          VARCHAR2 DEFAULT g_false
      , p_header_id            IN         NUMBER
      , p_line_number              IN     NUMBER
      , p_attribute_category  IN     VARCHAR2
      , p_attribute1          IN     VARCHAR2
      , p_attribute2          IN     VARCHAR2
      , p_attribute3          IN     VARCHAR2
      , p_attribute4          IN     VARCHAR2
      , p_attribute5          IN     VARCHAR2
      , p_attribute6          IN     VARCHAR2
      , p_attribute7          IN     VARCHAR2
      , p_attribute8          IN     VARCHAR2
      , p_attribute9          IN     VARCHAR2
      , p_attribute10         IN     VARCHAR2
      , p_attribute11         IN     VARCHAR2
      , p_attribute12         IN     VARCHAR2
     , p_attribute13         IN     VARCHAR2
     , p_attribute14         IN     VARCHAR2
     , p_attribute15         IN     VARCHAR2
     )IS


      l_return_status    VARCHAR2(1) := NULL;
      l_msg_data         VARCHAR2(2000):= NULL;
      l_msg_count        NUMBER := NULL;
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2(30) := 'Update_Transaction_flow_line';
BEGIN

   x_return_status := G_RET_STS_SUCCESS;
   x_msg_data := null;
   x_msg_count := 0;

   --  Standard call to check for call compatibility
   IF NOT FND_API.compatible_api_call
    (l_api_version_number
     ,   p_api_version
     ,   l_api_name
     ,   G_PKG_NAME)
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;


   SAVEPOINT UPDATE_TRANSACTION_FLOW_LINE;



   inv_transaction_flow_pvt.update_ic_txn_flow_line
     (x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data,
      p_commit                      => FALSE,
      p_header_id                   => p_header_id,
      p_line_number                 => p_line_number,
      p_attribute_category          => p_attribute_category,
      p_attribute1                   => p_attribute1,
      p_attribute2                   => p_attribute2,
      p_attribute3                   => p_attribute3,
      p_attribute4                   => p_attribute4,
      p_attribute5                   => p_attribute5,
      p_attribute6                   => p_attribute6,
      p_attribute7                   => p_attribute7,
      p_attribute8                   => p_attribute8,
      p_attribute9                   => p_attribute9,
      p_attribute10                  => p_attribute10,
      p_attribute11                  => p_attribute11,
     p_attribute12                  => p_attribute12,
     p_attribute13                  => p_attribute13,
     p_attribute14                  => p_attribute14,
     p_attribute15                  => p_attribute15
     );

   IF l_debug = 1 THEN
      print_debug('l_return_status from'||
		  'inv_transaction_flow_pvt.update_ic_txn_flow_line'||
		  x_return_status,l_api_name);
   END IF;

   IF l_return_status = g_ret_sts_success THEN
      --Successful
      x_return_status := l_return_status;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      IF l_debug = 1 THEN
	 print_debug('l_msg_data from'||
		     'inv_transaction_flow_pvt.update_ic_txn_flow_line'||
		     l_msg_data,l_api_name);
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSE
      IF l_debug = 1 THEN
	 print_debug('l_msg_data from'||
		     'inv_transaction_flow_pvt.update_ic_txn_flow_line'||
		     l_msg_data,l_api_name);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_transaction_flow_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_transaction_flow_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO update_transaction_flow_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'UPDATE_TRANSACTION_FLOW');
      end if;
 END Update_Transaction_Flow_line;

 PROCEDURE update_ic_relation
   (x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY VARCHAR2,
    p_api_version                 IN   NUMBER,
    p_init_msg_list               IN   VARCHAR2 DEFAULT g_false,
    p_Ship_Organization_Id        IN   NUMBER,
    p_Sell_Organization_Id        IN   NUMBER,
    p_Vendor_Id                   IN   NUMBER,
    p_Vendor_Site_Id              IN   NUMBER,
    p_Customer_Id                 IN   NUMBER,
    p_Address_Id                  IN   NUMBER,
    p_Customer_Site_Id            IN   NUMBER,
    p_Cust_Trx_Type_Id            IN   NUMBER,
    p_Attribute_Category          IN   VARCHAR2,
    p_Attribute1                  IN   VARCHAR2,
    p_Attribute2                  IN   VARCHAR2,
    p_Attribute3                  IN   VARCHAR2,
    p_Attribute4                  IN   VARCHAR2,
    p_Attribute5                  IN   VARCHAR2,
    p_Attribute6                  IN   VARCHAR2,
    p_Attribute7                  IN   VARCHAR2,
    p_Attribute8                  IN   VARCHAR2,
    p_Attribute9                  IN   VARCHAR2,
   p_Attribute10                  IN   VARCHAR2,
   p_Attribute11                  IN   VARCHAR2,
   p_Attribute12                  IN   VARCHAR2,
   p_Attribute13                  IN   VARCHAR2,
   p_Attribute14                  IN   VARCHAR2,
   p_Attribute15                  IN   VARCHAR2,
   p_Revalue_Average_Flag         IN   VARCHAR2,
   p_Freight_Code_Combination_Id  IN   NUMBER,
   p_inv_currency_code		  IN   NUMBER,
   p_Flow_Type                    IN   NUMBER,
   p_Intercompany_COGS_Account_Id IN   NUMBER,
   p_Inventory_Accrual_Account_Id IN   NUMBER,
   p_Expense_Accrual_Account_Id   IN   NUMBER
   )IS

      CURSOR ic_information(l_ship_organization_id NUMBER,
			    l_sell_organization_id NUMBER,
			    l_flow_type            NUMBER)
	IS
	   SELECT
	     rowid,
	     ship_organization_id,
	     sell_organization_id,
	     last_update_date,
	     last_updated_by,
	     creation_date,
	     created_by,
	     last_update_login,
	     customer_id,
	     address_id,
	     customer_site_id,
	     cust_trx_type_id,
	     vendor_id,
	     vendor_site_id,
	     revalue_average_flag,
	     attribute_category,
	     attribute1,
	     attribute2,
	     attribute3,
	     attribute4,
	     attribute5,
	     attribute6,
	     attribute7,
	     attribute8,
	     attribute9,
	     attribute10,
	     attribute11,
	     attribute12,
	     attribute13,
	     attribute14,
	     attribute15,
	     freight_code_combination_id,
	     inv_currency_code,
	     flow_type,
	     intercompany_cogs_account_id,
	     inventory_accrual_account_id,
	     expense_accrual_account_id
	     FROM
	     mtl_intercompany_parameters
	     WHERE
	     ship_organization_id = l_ship_organization_id
	     AND sell_organization_id = l_sell_organization_id
	     AND flow_type = l_flow_type;

      l_return_status    VARCHAR2(1) := NULL;
      l_msg_data         VARCHAR2(2000):= NULL;
      l_msg_count        NUMBER := NULL;

      l_valid VARCHAR2(1) := NULL;

      l_rowid                              ROWID;
      l_ship_organization_id               NUMBER := p_ship_organization_id;
      l_sell_organization_id               NUMBER := p_sell_organization_id;
      l_customer_id                        NUMBER := p_customer_id;
      l_address_id                         NUMBER := p_address_id;
      l_customer_site_id                   NUMBER := p_customer_site_id;
      l_cust_trx_type_id                   NUMBER := p_cust_trx_type_id;
      l_vendor_id                          NUMBER := p_vendor_id;
      l_vendor_site_id                     NUMBER := p_vendor_site_id;
      l_freight_code_combination_id        NUMBER := p_freight_code_combination_id;
      l_intercompany_cogs_account_id       NUMBER := p_intercompany_cogs_account_id;
      l_inventory_accrual_account_id       NUMBER := p_inventory_accrual_account_id;
      l_expense_accrual_account_id         NUMBER := p_expense_accrual_account_id;
      l_chart_of_accounts_id               NUMBER := NULL;
      l_ship_chart_of_accounts_id               NUMBER := NULL;

      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2(30) := 'Update_ic_relation';
 BEGIN

    x_return_status := G_RET_STS_SUCCESS;
    x_msg_data := null;
    x_msg_count := 0;

    --  Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call
      (l_api_version_number
       ,   p_api_version
       ,   l_api_name
       ,   G_PKG_NAME)
      THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
    END IF;

    SAVEPOINT update_ic_relation;

    inv_transaction_flow_pub.validate_ic_relation_rec
      (x_return_status                =>  l_return_status,
       x_msg_data                     =>  l_msg_data,
       x_msg_count                    =>  l_msg_count,
       x_valid                        =>  l_valid,
       p_api_version                  =>  p_api_version,
       p_init_msg_list                =>  G_FALSE,
       p_ship_organization_id         =>  p_ship_organization_id,
       p_sell_organization_id         =>  p_sell_organization_id,
       p_vendor_id                    =>  p_vendor_id,
       p_vendor_site_id               =>  p_vendor_site_id,
       p_customer_id                  =>  p_customer_id,
       p_address_id                   =>  p_address_id,
       p_customer_site_id             =>  p_customer_site_id,
       p_cust_trx_type_id             =>  p_cust_trx_type_id,
       p_attribute_category           =>  p_attribute_category,
       p_attribute1                   =>  p_attribute1,
       p_attribute2                   =>  p_attribute2,
       p_attribute3                   =>  p_attribute3,
       p_attribute4                   =>  p_attribute4,
       p_attribute5                   =>  p_attribute5,
      p_attribute6                    =>  p_attribute6,
      p_attribute7                    =>  p_attribute7,
      p_attribute8                    =>  p_attribute8,
      p_attribute9                    =>  p_attribute9,
      p_attribute10                   =>  p_attribute10,
      p_attribute11                   =>  p_attribute11,
      p_attribute12                   =>  p_attribute12,
      p_attribute13                   =>  p_attribute13,
      p_attribute14                   =>  p_attribute14,
      p_attribute15                   =>  p_attribute15,
      p_revalue_average_flag          =>  p_revalue_average_flag,
      p_freight_code_combination_id   =>  p_freight_code_combination_id,
      p_inv_currency_code	      =>  p_inv_currency_code,
      p_flow_type                     =>  p_flow_type,
      p_intercompany_cogs_account_id  =>  p_intercompany_cogs_account_id,
      p_inventory_accrual_account_id  =>  p_inventory_accrual_account_id,
      p_expense_accrual_account_id    =>  p_expense_accrual_account_id
      );

    IF l_return_status = g_ret_sts_error THEN
       RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = g_ret_sts_unexp_error THEN
       RAISE fnd_api.g_exc_unexpected_error;
     ELSIF l_valid = g_true THEN

       FOR ic_information_rec IN ic_information(p_ship_organization_id,p_sell_organization_id,p_flow_type) LOOP

	  l_rowid := ic_information_rec.ROWID;

	  IF p_customer_id = g_miss_num THEN
	     l_customer_id := ic_information_rec.customer_id;
	  END IF;

	  IF p_address_id = g_miss_num THEN
	     l_address_id := ic_information_rec.address_id;
	  END IF;

	  IF p_customer_site_id = g_miss_num THEN
	     l_customer_site_id := ic_information_rec.customer_site_id;
	  END IF;

	  IF p_address_id = g_miss_num THEN
	     l_address_id := ic_information_rec.address_id;
	  END IF;

	  IF p_customer_site_id = g_miss_num THEN
	     l_customer_site_id := ic_information_rec.customer_site_id;
	  END IF;

	  IF p_cust_trx_type_id = g_miss_num THEN
	     l_cust_trx_type_id := ic_information_rec.cust_trx_type_id;
	  END IF;

	  IF p_vendor_id = g_miss_num THEN
	     l_vendor_id := ic_information_rec.vendor_id;
	  END IF;

	  IF p_vendor_site_id = g_miss_num THEN
	     l_vendor_site_id := ic_information_rec.vendor_site_id;
	  END IF;

	  IF P_FREIGHT_CODE_COMBINATION_ID = g_miss_num THEN
	     l_freight_code_combination_id := ic_information_rec.freight_code_combination_id;
	  END IF;

	  IF P_intercompany_cogs_account_id = g_miss_num THEN
	     l_intercompany_cogs_account_id := ic_information_rec.intercompany_cogs_account_id;
	  END IF;

	  IF P_inventory_accrual_account_id = g_miss_num THEN
	     l_inventory_accrual_account_id := ic_information_rec.inventory_accrual_account_id;
	  END IF;

	  IF P_expense_accrual_account_id = g_miss_num THEN
	     l_expense_accrual_account_id := ic_information_rec.expense_accrual_account_id;
	  END IF;

	  mtl_ic_parameters_pkg.update_row
	    (x_rowid=> l_rowid,
	     x_ship_organization_id=> p_ship_organization_id,
	     x_sell_organization_id=> p_sell_organization_id,
	     x_last_update_date=>sysdate,
	     x_last_updated_by=> fnd_global.user_id,
	     x_last_update_login=> fnd_global.login_id,
	     x_vendor_id=> l_vendor_id,
	     x_vendor_site_id=> l_vendor_site_id,
	     x_customer_id=> l_customer_id,
	     x_address_id=> l_address_id,
	     x_customer_site_id=> l_customer_site_id,
	     x_cust_trx_type_id=> l_cust_trx_type_id,
	     x_attribute_category=> p_attribute_category,
	     x_attribute1=> p_attribute1,
	     x_attribute2=> p_attribute2,
	     x_attribute3=> p_attribute3,
	     x_attribute4=> p_attribute4,
	     x_attribute5=> p_attribute5,
	     x_attribute6=> p_attribute6,
	    x_attribute7=> p_attribute7,
	    x_attribute8=> p_attribute8,
	    x_attribute9=> p_attribute9,
	    x_attribute10=> p_attribute10,
	    x_attribute11=> p_attribute11,
	    x_attribute12=> p_attribute12,
	    x_attribute13=> p_attribute13,
	    x_attribute14=> p_attribute14,
	    x_attribute15=> p_attribute15,
	    x_revalue_average_flag=> p_revalue_average_flag,
	    x_freight_code_combination_id=> l_freight_code_combination_id,
	    x_inv_currency_code		=> p_inv_currency_Code,
	    x_flow_type=> p_flow_type,
	    x_intercompany_cogs_account_id=> l_intercompany_cogs_account_id,
	    x_inventory_accrual_account_id=> l_inventory_accrual_account_id,
	    x_expense_accrual_account_id=> l_expense_accrual_account_id
	    );
       END LOOP;
    END IF;


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_ic_relation;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO update_ic_relation;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
       ROLLBACK TO update_ic_relation;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	  FND_MSG_PUB.Add_Exc_Msg
	    (   G_PACKAGE_NAME, 'UPDATE_TRANSACTION_FLOW');
       end if;
 END Update_IC_RELATION;



 PROCEDURE validate_ic_relation_rec
   (x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY VARCHAR2,
    x_valid                  OUT NOCOPY VARCHAR2,
    p_api_version                 IN   NUMBER,
    p_init_msg_list               IN   VARCHAR2 DEFAULT g_false,
    p_Ship_Organization_Id        IN   NUMBER,
    p_Sell_Organization_Id        IN   NUMBER,
    p_Vendor_Id                   IN   NUMBER,
    p_Vendor_Site_Id              IN   NUMBER,
    p_Customer_Id                 IN   NUMBER,
    p_Address_Id                  IN   NUMBER,
    p_Customer_Site_Id            IN   NUMBER,
    p_Cust_Trx_Type_Id            IN   NUMBER,
    p_Attribute_Category          IN   VARCHAR2,
    p_Attribute1                  IN   VARCHAR2,
    p_Attribute2                  IN   VARCHAR2,
    p_Attribute3                  IN   VARCHAR2,
    p_Attribute4                  IN   VARCHAR2,
    p_Attribute5                  IN   VARCHAR2,
    p_Attribute6                  IN   VARCHAR2,
   p_Attribute7                  IN   VARCHAR2,
   p_Attribute8                  IN   VARCHAR2,
   p_Attribute9                  IN   VARCHAR2,
   p_Attribute10                  IN   VARCHAR2,
   p_Attribute11                  IN   VARCHAR2,
   p_Attribute12                  IN   VARCHAR2,
   p_Attribute13                  IN   VARCHAR2,
   p_Attribute14                  IN   VARCHAR2,
   p_Attribute15                  IN   VARCHAR2,
   p_Revalue_Average_Flag         IN   VARCHAR2,
   p_Freight_Code_Combination_Id  IN   NUMBER,
   p_inv_currency_code		  IN   NUMBER,
   p_Flow_Type                    IN   NUMBER,
   p_Intercompany_COGS_Account_Id IN   NUMBER,
   p_Inventory_Accrual_Account_Id IN   NUMBER,
   p_Expense_Accrual_Account_Id   IN   NUMBER
   )IS


      l_address_id NUMBER := NULL;
      l_customer_site_id NUMBER := NULL;
      l_chart_of_accounts_id NUMBER := NULL;
      l_ship_chart_of_accounts_id NUMBER := NULL;

      l_valid VARCHAR2(1) := NULL;
      l_valid_ccid BOOLEAN;
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_IC_RELATION';

      lreturn_status VARCHAR2(1);
      lmsg_data  VARCHAR2(100);
      lsob_id  NUMBER;
      lcoa_id  NUMBER;

 BEGIN

    x_return_status := G_RET_STS_SUCCESS;
    x_valid := g_true;
    x_msg_data := null;
    x_msg_count := 0;

    --  Standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call
      (l_api_version_number
       ,   p_api_version
       ,   l_api_name
       ,   G_PKG_NAME)
      THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --  Initialize message list.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
    END IF;

    /* NOT NULL CHECK - ALL THE NOT NULL ERROR MESSAGES WOULD BE GROUPED AND
       RAISE AT ONCE */
    DECLARE
      hasNotNullError BOOLEAN := false;
    BEGIN -- BEGIN NOT NULL CHECK

    IF p_ship_organization_id IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_INPUT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','SHIP_ORGANIZATION_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;

    IF p_sell_organization_id IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_INPUT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','SELL_ORGANIZATION_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;

    IF p_flow_type IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_INPUT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','FLOW_TYPE');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;

    IF p_customer_id IS NULL THEN

       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','CUSTOMER_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;

    IF p_address_id IS NULL THEN

       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','ADDRESS_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;

    END IF;

    IF p_customer_site_id IS NULL THEN

       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','CUSTOMER_SITE_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;

    END IF;

    IF p_cust_trx_type_id IS NULL THEN

       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','CUST_TRX_TYPE_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;

    END IF;

    IF p_vendor_id IS NULL THEN

       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','VENDOR_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;

    END IF;

    IF p_vendor_site_id IS NULL THEN

      FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
      FND_MESSAGE.SET_TOKEN('COLUMN','VENDOR_SITE_ID');
      FND_MSG_PUB.ADD;
       hasNotNullError := true;

    END IF;
/* Bug# 3314606
    IF p_freight_code_combination_id IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','FREIGHT_CODE_COMBINATION_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;
*/
DECLARE
	nDummy NUMBER;
BEGIN

SELECT 1 INTO nDummy FROM DUAL
WHERE EXISTS (SELECT 1 FROM MTL_TRANSACTION_FLOW_HEADERS
WHERE START_ORG_ID = p_ship_organization_id
AND END_ORG_ID = p_ship_organization_id
AND (NEW_ACCOUNTING_FLAG = 'Y' OR FLOW_TYPE <> 1));

    IF p_intercompany_cogs_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','INTERCOMPANY_COGS_ACCOUNT_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;

    IF p_inventory_accrual_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','INVENTORY_ACCRUAL_ACCOUNT_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;

    IF p_expense_accrual_account_id IS NULL THEN
       FND_MESSAGE.SET_NAME('INV','INV_COLUMN_NOT_NULL');
       FND_MESSAGE.SET_TOKEN('COLUMN','EXPENSE_ACCRUAL_ACCOUNT_ID');
       FND_MSG_PUB.ADD;
       hasNotNullError := true;
    END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
END;

    IF (hasNotNullError) THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    END; -- END NOT NULL CHECK

    /* END NOT NULL CHECK */

    --Validating Customer_id
    IF p_customer_id = g_miss_num THEN
       --Do nothing
       NULL;
     ELSE
       l_valid := 'N';
       BEGIN
	  SELECT 'Y' INTO l_valid FROM dual
	    WHERE
	    exists(SELECT CUST_ACCOUNT_ID
		   FROM HZ_CUST_ACCOUNTS
		   WHERE CUST_ACCOUNT_ID = p_customer_id);
       EXCEPTION
	  WHEN no_data_found THEN
	     l_valid := 'N';
       END;

       IF l_valid = 'N' THEN
	  FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	  FND_MESSAGE.SET_TOKEN('COLUMN','CUSTOMER_ID');
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --Validating Address_id

    IF p_address_id = g_miss_num THEN
       --Do nothing
       NULL;
     ELSE
       l_valid := 'N';
       BEGIN
       /* Modified query below : RA to HZ conversions
          Replaced occurances of RA views with HZ tables*/
       /*
   	 SELECT 'Y' INTO l_valid FROM dual
	    WHERE
	    exists
	    (select rsu.address_id
	     from ra_addresses_all ra , ra_site_uses_all rsu
	     where nvl(rsu.status,'A') = 'A'
	     and rsu.site_use_code = 'BILL_TO'
	     and ra.address_id = rsu.address_id and nvl(ra.status,'A') = 'A'
	     and ra.customer_id = Decode(p_customer_id,g_miss_num,ra.customer_id,p_customer_id)
	     and ra.org_id = p_ship_organization_id
	     AND rsu.address_id = p_address_id
	     AND rsu.site_use_id = Decode(p_customer_site_id,g_miss_num,rsu.site_use_id,p_customer_site_id));
        */

         SELECT 'Y' INTO l_valid
           FROM DUAL
          WHERE EXISTS(
                  SELECT rsu.cust_acct_site_id
                    FROM (SELECT loc_id address_id
                               , acct_site.status
                               , cust_account_id customer_id
                               , acct_site.org_id
                            FROM hz_party_sites party_site, hz_loc_assignments loc_assign, hz_locations loc, hz_cust_acct_sites_all acct_site
                           WHERE acct_site.party_site_id = party_site.party_site_id
                             AND loc.location_id = party_site.location_id
                             AND loc.location_id = loc_assign.location_id
                             AND NVL(acct_site.org_id, -99) = NVL(loc_assign.org_id, -99)) ra
                       , hz_cust_site_uses_all rsu
                   WHERE NVL(rsu.status, 'A') = 'A'
                     AND rsu.site_use_code = 'BILL_TO'
                     AND ra.address_id = rsu.cust_acct_site_id
                     AND NVL(ra.status, 'A') = 'A'
                     AND ra.customer_id = DECODE(p_customer_id, g_miss_num, ra.customer_id, p_customer_id)
                     AND ra.org_id = p_ship_organization_id
                     AND rsu.cust_acct_site_id = p_address_id
                     AND rsu.site_use_id = DECODE(p_customer_site_id, g_miss_num, rsu.site_use_id, p_customer_site_id));


       EXCEPTION
	  WHEN no_data_found THEN
	     l_valid := 'N';
       END;

       IF l_valid = 'N' THEN
	  FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	  FND_MESSAGE.SET_TOKEN('COLUMN','ADDRESS_ID');
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --Validating customer_site_id

    IF p_customer_site_id = g_miss_num THEN
       --Do nothing
       NULL;
     ELSE
       l_valid := 'N';
       BEGIN
      /* Modified query below : RA to HZ conversions
          Replaced occurances of RA views with HZ tables*/
     /*
	  SELECT 'Y' INTO l_valid FROM dual
	    WHERE
	    exists
	    (select rsu.site_use_id
	     from ra_addresses_all ra , ra_site_uses_all rsu
	     where nvl(rsu.status,'A') = 'A'
	     and rsu.site_use_code = 'BILL_TO'
	     and ra.address_id = rsu.address_id and nvl(ra.status,'A') = 'A'
	     and ra.customer_id = Decode(p_customer_id,g_miss_num,ra.customer_id,p_customer_id)
	     and ra.org_id = p_ship_organization_id
	     AND rsu.address_id = Decode(p_address_id,g_miss_num,rsu.address_id,p_address_id)
	     AND rsu.site_use_id = p_customer_site_id);
      */

         SELECT 'Y' INTO l_valid
           FROM DUAL
          WHERE EXISTS(
                  SELECT rsu.site_use_id
                    FROM (SELECT loc_id address_id
                               , acct_site.status
                               , cust_account_id customer_id
                               , acct_site.org_id
                            FROM hz_party_sites party_site, hz_loc_assignments loc_assign, hz_locations loc, hz_cust_acct_sites_all acct_site
                           WHERE acct_site.party_site_id = party_site.party_site_id
                             AND loc.location_id = party_site.location_id
                             AND loc.location_id = loc_assign.location_id
                             AND NVL(acct_site.org_id, -99) = NVL(loc_assign.org_id, -99)) ra
                       , hz_cust_site_uses_all rsu
                   WHERE NVL(rsu.status, 'A') = 'A'
                     AND rsu.site_use_code = 'BILL_TO'
                     AND ra.address_id = rsu.cust_acct_site_id
                     AND NVL(ra.status, 'A') = 'A'
                     AND ra.customer_id = DECODE(p_customer_id, g_miss_num, ra.customer_id, p_customer_id)
                     AND ra.org_id = p_ship_organization_id
                     AND rsu.cust_acct_site_id = DECODE(p_address_id, g_miss_num, rsu.cust_acct_site_id, p_address_id)
                     AND rsu.site_use_id = p_customer_site_id);

       EXCEPTION
	  WHEN no_data_found THEN
	     l_valid := 'N';
       END;

       IF l_valid = 'N' THEN
	  FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	  FND_MESSAGE.SET_TOKEN('COLUMN','CUSTOMER_SITE_ID');
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --Validating cust_trx_type_id

   IF p_cust_trx_type_id = g_miss_num THEN
       --Do nothing
       NULL;

    ELSE
      l_valid := 'N';
      BEGIN
	 SELECT 'Y' INTO l_valid FROM dual
	   WHERE
	   exists
	   (select cust_trx_type_id
	    from ra_cust_trx_types_all
	    where
	    sysdate between nvl(start_date, sysdate-1)
	    and nvl(end_date, sysdate+1)
	    and org_id = p_ship_organization_id
	    AND cust_trx_type_id = p_cust_trx_type_id);
      EXCEPTION
	 WHEN no_data_found THEN
	    l_valid := 'N';
      END;

      IF l_valid = 'N' THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','CUST_TRX_TYPE_ID');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Validating vendor_id

   IF p_vendor_id = g_miss_num THEN
	  --Do nothing
	  NULL;

    ELSE
      l_valid := 'N';
      BEGIN
	 SELECT 'Y' INTO l_valid FROM dual
	   WHERE
	   exists
	   (select pov.vendor_id from
	    po_vendors pov,
	    FND_LOOKUPS FL
	    WHERE
	    NVL(POV.HOLD_FLAG,'N') = FL.LOOKUP_CODE
	    AND FL.LOOKUP_TYPE = 'YES_NO'
	    AND POV.ENABLED_FLAG = 'Y'
	    AND SYSDATE BETWEEN NVL(POV.START_DATE_ACTIVE, SYSDATE-1)
	    AND NVL(POV.END_DATE_ACTIVE+1, SYSDATE+1)
	    and pov.vendor_id = p_vendor_id);
      EXCEPTION
	 WHEN no_data_found THEN
	    l_valid := 'N';
      END;

      IF l_valid = 'N' THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','VENDOR_ID');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Validating vendor_site_id
   IF p_vendor_site_id = g_miss_num THEN
      --Do nothing
      NULL;

    ELSE
      l_valid := 'N';
      BEGIN
	 SELECT 'Y' INTO l_valid FROM dual
	   WHERE
	   exists
	   (select vendor_site_id
	    from po_vendor_sites_all
	    where pay_site_flag = 'Y'
	    and vendor_id = p_vendor_id
	    and org_id = p_sell_organization_id
	    AND vendor_site_id = p_vendor_site_id);
      EXCEPTION
	 WHEN no_data_found THEN
	    l_valid := 'N';
      END;

      IF l_valid = 'N' THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','VENDOR_SITE_ID');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Getting chart_of_accounts_id

   /* commented the selection of COA using LE - OU link which is obsoleted in R12
      and replaced the code with selection of COAs using the API - INV_GLOBALS.GET_LEDGER_INFO
      Bug No - 4336479
   BEGIN
      SELECT
	gsob.chart_of_accounts_id
	into
	l_ship_chart_of_accounts_id
	from
	gl_sets_of_books gsob,
	hr_organization_information hoi,
	hr_organization_information hoi1
	where
	hoi1.organization_id = p_ship_organization_id
	and hoi1.org_information_context = 'Operating Unit Information'
	and hoi.organization_id = to_number(hoi1.org_information2)
	and hoi.org_information_context = 'Legal Entity Accounting'
	and gsob.set_of_books_id = to_number(hoi.org_information1);
   EXCEPTION
      WHEN no_data_found THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','SHIP_CHART_OF_ACCOUNTS_ID');
	 RAISE FND_API.G_EXC_ERROR;
   END;
   */

   BEGIN
            Inv_globals.get_ledger_info(
                                  x_return_status               => lreturn_status,
                                  x_msg_data                    => lmsg_data  ,
                                  p_context_type                => 'Operating Unit Information',
                                  p_org_id                      => p_ship_organization_id,
                                  x_sob_id                      => lsob_id,
                                  x_coa_id                      => lcoa_id,
                                  p_account_info_context        => 'COA');
          IF NVL(lreturn_status , 'S') = 'E' THEN
              FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN','SHIP_CHART_OF_ACCOUNTS_ID');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
           l_ship_chart_of_accounts_id := lcoa_id;
    END;


   -- sell side
   /* commented the selection of COA using LE - OU link which is obsoleted in R12
      and replaced the code with selection of COAs using the API - INV_GLOBALS.GET_LEDGER_INFO
      Bug No - 4336479
   BEGIN
      select
	gsob.chart_of_accounts_id
	into
	l_chart_of_accounts_id
	from
	gl_sets_of_books gsob,
	hr_organization_information hoi,
	hr_organization_information hoi1
	where hoi1.organization_id = p_sell_organization_id
	and hoi1.org_information_context = 'Operating Unit Information'
	and hoi.organization_id = to_number(hoi1.org_information2)
	and hoi.org_information_context = 'Legal Entity Accounting'
	and gsob.set_of_books_id = to_number(hoi.org_information1);
   EXCEPTION
      WHEN no_data_found THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','CHART_OF_ACCOUNTS_ID');
	 RAISE FND_API.G_EXC_ERROR;
   END;
   */

   BEGIN
            Inv_globals.get_ledger_info(
                                  x_return_status                => lreturn_status,
                                  x_msg_data                     => lmsg_data  ,
                                  p_context_type                 => 'Operating Unit Information',
                                  p_org_id                       => p_sell_organization_id,
                                  x_sob_id                       => lsob_id,
                                  x_coa_id                       => lcoa_id,
                                  p_account_info_context         => 'COA');
          IF NVL(lreturn_status , 'S') = 'E' THEN
   	      FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
   	      FND_MESSAGE.SET_TOKEN('COLUMN','CHART_OF_ACCOUNTS_ID');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_chart_of_accounts_id:= lcoa_id;
   END;


   --Validating freight_code_combination_id

   IF P_FREIGHT_CODE_COMBINATION_ID IS NULL OR P_FREIGHT_CODE_COMBINATION_ID = g_miss_num THEN
      --Do nothing
      NULL;
    ELSE
      l_valid_ccid :=
	fnd_flex_keyval.validate_ccid
	(appl_short_name    => 'SQLGL',
	 key_flex_code	    => 'GL#',
	 structure_number   => l_chart_of_accounts_id,
	 combination_id	    => p_freight_code_combination_id,
	 vrule		    => '\\nSUMMARY_FLAG\\nI\\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\\nN\\0GL_GLOBAL\\nDETAIL_POSTING_ALLOWED\\nE\\nAPPL=INV;NAME=INV_VRULE_POSTING\\nN');

      IF NOT l_valid_ccid THEN

	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','FREIGHT_CODE_COMBINATION_ID');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Validating intercompany_cogs_account_id

   IF P_intercompany_cogs_account_id IS NULL OR P_intercompany_cogs_account_id = g_miss_num THEN
      --Do nothing
      NULL;
    ELSE
      l_valid_ccid :=
	fnd_flex_keyval.validate_ccid
	(appl_short_name    => 'SQLGL',
	 key_flex_code	    => 'GL#',
	 structure_number   => l_ship_chart_of_accounts_id,
	 combination_id	    => p_intercompany_cogs_account_id,
	 vrule		    => '\\nSUMMARY_FLAG\\nI\\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\\nN\\0GL_GLOBAL\\nDETAIL_POSTING_ALLOWED\\nE\\nAPPL=INV;NAME=INV_VRULE_POSTING\\nN');

	  IF NOT l_valid_ccid THEN
	     FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	     FND_MESSAGE.SET_TOKEN('COLUMN','INTERCOMPANY_COGS_ACCOUNT_ID');
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

   --Validating inventory_accrual_account_id

   IF P_inventory_accrual_account_id IS NULL OR P_inventory_accrual_account_id = g_miss_num THEN
      --Do nothing
      NULL;
    ELSE
      l_valid_ccid :=
	fnd_flex_keyval.validate_ccid
	(appl_short_name    => 'SQLGL',
	 key_flex_code	    => 'GL#',
	 structure_number   => l_chart_of_accounts_id,
	 combination_id	    => p_inventory_accrual_account_id,
	 vrule		    => '\\nSUMMARY_FLAG\\nI\\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\\nN\\0GL_GLOBAL\\nDETAIL_POSTING_ALLOWED\\nE\\nAPPL=INV;NAME=INV_VRULE_POSTING\\nN');

      IF NOT l_valid_ccid THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','INVENTORY_ACCRUAL_ACCOUNT_ID');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   --Validating expense_accrual_account_id

   IF P_expense_accrual_account_id IS NULL OR P_expense_accrual_account_id = g_miss_num THEN
      --Do nothing
      NULL;
    ELSE
      l_valid_ccid :=
	fnd_flex_keyval.validate_ccid
	(appl_short_name   => 'SQLGL',
	 key_flex_code	   => 'GL#',
	 structure_number  => l_chart_of_accounts_id,
	 combination_id	   => p_expense_accrual_account_id,
	 vrule		   => '\\nSUMMARY_FLAG\\nI\\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\\nN\\0GL_GLOBAL\\nDETAIL_POSTING_ALLOWED\\nE\\nAPPL=INV;NAME=INV_VRULE_POSTING\\nN');

      IF NOT l_valid_ccid THEN
	 FND_MESSAGE.SET_NAME('INV','INV_INVALID_COLUMN');
	 FND_MESSAGE.SET_TOKEN('COLUMN','EXPENSE_ACCRUAL_ACCOUNT_ID');
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF p_attribute_category = g_miss_num THEN
      --Do nothing
      NULL;
    ELSIF NOT inv_transaction_flow_pvt.Validate_Dff( P_FLEX_NAME          => 'MTL_INTERCOMPANY_PARAMETERS',
						     P_ATTRIBUTE1         =>  p_attribute1,
						     P_ATTRIBUTE2         =>  p_attribute2,
						     P_ATTRIBUTE3         =>  p_attribute3,
						     P_ATTRIBUTE4         =>  p_attribute4,
						     P_ATTRIBUTE5         =>  p_attribute5,
						     P_ATTRIBUTE6         =>  p_attribute6,
						     P_ATTRIBUTE7         =>  p_attribute7,
						     P_ATTRIBUTE8         =>  p_attribute8,
						     P_ATTRIBUTE9         =>  p_attribute9,
						     P_ATTRIBUTE10        =>  p_attribute10,
						     P_ATTRIBUTE11        =>  p_attribute11,
						     P_ATTRIBUTE12        =>  p_attribute12,
						     P_ATTRIBUTE13        =>  p_attribute13,
						     P_ATTRIBUTE14        =>  p_attribute14,
						     P_ATTRIBUTE15        =>  p_attribute15,
						     P_ATTRIBUTE_CATEGORY =>  p_attribute_category
						     ) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_valid := g_false;
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_valid := g_false;
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_valid := g_false;
       FND_MSG_PUB.ADD;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	  FND_MSG_PUB.Add_Exc_Msg
	    (   G_PACKAGE_NAME, 'validate_IC_RELATION_rec');
       end if;
 END validate_IC_RELATION_rec;



/*==========================================================================================================
 * Package: INV_TRANSACTION_FLOWS_PUB
 *
 * Procedure: GET_DROPSHIP_PO_TXN_TYPE
 *
 * Description:
 * This API gets the drop ship transaction type code for a drop ship or global procurement flow.
 * This API will be called by Oracle Receiving  as well as Oracle Costing
 *
 * Inputs:
 * - 	p_po_line_location_id  - the Purchase Order LIne Location
 * -	p_global_procurement_flag - a flag to indicate whether the flow is global procurement flow
 *
 * Outputs:
 * - x_ds_type_code  - the drop ship transaction type code. The possible value for this are:
 *      1 - Drop Ship flow and logical
 *      2 - Drop Ship Flow and physical
 *      3 - Not a Drop Ship Flow and Physical
 * - x_header_id    - Transaction Flow Header Identifier.A value is
 *   returned only when x_ds_type_code is returned as 1
 *
 * - x_return_Status -  the return status
 * - x_msg_data - the error message
 * - x_msg_count - the message count
 *============================================================================================================*/
PROCEDURE GET_DROPSHIP_PO_TXN_TYPE
(
  p_api_version			IN	NUMBER
, p_init_msg_list               IN      VARCHAR2
, p_rcv_transaction_id		IN	NUMBER
, p_global_procurement_flag	IN	VARCHAR2
, x_return_Status		OUT NOCOPY VARCHAR2
, x_msg_data			OUT NOCOPY VARCHAR2
, x_msg_count			OUT NOCOPY NUMBER
, x_transaction_type_id		OUT NOCOPY NUMBER
, x_transaction_action_id	OUT NOCOPY NUMBER
, x_transaction_Source_type_id  OUT NOCOPY NUMBER
, x_dropship_type_Code		OUT NOCOPY NUMBER
, x_header_id                   OUT NOCOPY NUMBER
  ) IS

     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_inventory_item_id NUMBER;
     l_po_header_id NUMBER := NULL;
     l_po_line_id NUMBER := NULL;
     l_po_line_location_id NUMBER := NULL;
     l_transaction_type VARCHAR2(80) := NULL;
     l_header_id NUMBER := NULL;
     l_line_id NUMBER := NULL;
     l_external_drop_ship BOOLEAN := TRUE;
     l_selling_org_id NUMBER := NULL;
     l_ship_from_org_id NUMBER := NULL;
     l_selling_ou NUMBER := NULL;
     l_ship_from_ou NUMBER := NULL;
     l_qualifier_code_tbl number_tbl;
     l_qualifier_value_tbl number_tbl;
     l_transaction_flow_exists VARCHAR2(1);
     l_txn_flow_header_id NUMBER;
     l_new_accounting_flag VARCHAR2(1);
     l_return_status VARCHAR2(1);
     l_msg_data VARCHAR2(2000);
     l_msg_count NUMBER;
     l_transaction_date DATE;
     l_api_version_number CONSTANT NUMBER := 1.0;
     l_api_name CONSTANT VARCHAR2(30) := 'GET_DROPSHIP_PO_TXN_TYPE';

     CURSOR drop_ship_sources
       (l_poh_id NUMBER,
	l_pol_id NUMBER,
	l_poll_id NUMBER)
       IS
	  SELECT header_id, line_id
	    FROM
	    oe_drop_ship_sources
	    WHERE
	    po_header_id = l_poh_id
	    AND po_line_id = l_pol_id
	    AND line_location_id = l_poll_id
	    ORDER BY header_id,line_id;
BEGIN

   IF l_debug = 1 then
      print_debug('Entered Get_dropship_PO_txn_type', l_api_name);
      print_debug('Inputs p_rcv_transaction_id '||p_rcv_transaction_id||
		  ' p_global_procurement_flag '||p_global_procurement_flag, l_api_name);
   END IF;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
               l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;


   x_return_status := 'S';
   x_msg_data := null;
   x_msg_count := 0;
   x_dropship_type_code := -99;
   x_transaction_type_id := -99;
   x_transaction_action_id := -99;
   x_transaction_source_type_id := -99;
   x_header_id := -99;

   IF nvl(p_rcv_transaction_id,-1) <= 0 THEN
      IF l_debug = 1 then
	 print_debug('incorrect p_rcv_transaction_id', l_api_name);
      END IF;
      fnd_message.set_name('INV', 'INV_NO_RCVTXNID');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;

   BEGIN
      SELECT rt.po_header_id, rt.po_line_id, rt.po_line_location_id,
	rt.transaction_type, rt.transaction_date, rsl.item_id
	INTO
	l_po_header_id,	l_po_line_id, l_po_line_location_id,
	l_transaction_type, l_transaction_date, l_inventory_item_id
	FROM
	rcv_transactions rt,
	rcv_shipment_lines rsl
	WHERE
	transaction_id = p_rcv_transaction_id
	AND rt.shipment_line_id = rsl.shipment_line_id;
   EXCEPTION
      WHEN no_data_found THEN
	 IF l_debug = 1 then
	    print_debug('no record found in rcv_transcations', l_api_name);
	 END IF;
	 fnd_message.set_name('INV', 'INV_NO_RCVTXN');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;
   END;

   IF l_debug = 1 then
      print_debug(' l_po_header_id '||l_po_header_id||
		  ' l_po_line_id '||l_po_line_id||
		  ' l_po_line_location_id '||l_po_line_location_id||
		  ' l_inventory_item_id '||l_inventory_item_id, l_api_name);
      print_debug('l_transaction_date '||l_transaction_date, l_api_name);
       print_debug('l_transaction_type '||l_transaction_type, l_api_name);
   END IF;

   IF (l_po_header_id IS NULL) OR (l_po_line_id IS NULL) OR
     (l_po_line_location_id IS NULL) THEN
      IF l_debug = 1 then
	 print_debug('Insufficient information in rcv_transactions', l_api_name);
      END IF;
      fnd_message.set_name('INV', 'INV_NO_RCVTXN_INFO');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
   END IF;


   IF l_transaction_type in ('RETURN TO RECEIVING',
			     'RETURN TO CUSTOMER',
			     'RETURN TO VENDOR') THEN

      x_dropship_type_code := G_PHYSICAL_RECEIPT_FOR_NON_DS;
      x_transaction_type_id := INV_GLOBALS.G_TYPE_RETURN_TO_VENDOR;
      x_transaction_action_id := INV_GLOBALS.G_ACTION_ISSUE;
      x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;

    ELSE

      OPEN drop_ship_sources(l_po_header_id,l_po_line_id,l_po_line_location_id);

      FETCH drop_ship_sources INTO l_header_id,l_line_id;

      IF drop_ship_sources%notfound THEN
	 IF l_debug = 1 then
	    print_debug('No data found in oe_drop_ship_sources: not a drop ship', l_api_name);
	 END IF;
	 l_external_drop_ship := FALSE;
       ELSE
	 l_external_drop_ship := TRUE;
	 IF l_debug = 1 then
	    print_debug('Drop ship', l_api_name);
	 END IF;
      END IF;

      IF drop_ship_sources%isopen THEN
	 CLOSE drop_ship_sources;
      END IF;

      IF l_debug = 1 then
	 print_debug('l_header_id '||l_header_id||
		     ' l_line_id '||l_line_id, l_api_name);
      END IF;

      IF NOT l_external_drop_ship THEN
	 x_dropship_type_code := G_PHYSICAL_RECEIPT_FOR_NON_DS;
	 IF l_transaction_type = 'DELIVER' THEN
	    x_transaction_type_id := INV_GLOBALS.G_TYPE_PO_RECEIPT;
	    x_transaction_action_id := INV_GLOBALS.G_ACTION_RECEIPT;
	    x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;
	  ELSIF l_transaction_type = 'CORRECT' THEN
	    x_transaction_type_id := INV_GLOBALS.G_TYPE_PO_RCPT_ADJ;
	    x_transaction_action_id := INV_GLOBALS.G_ACTION_DELIVERYADJ;
	    x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;
	 END IF;
       ELSE

         BEGIN
	    SELECT org_id, ship_from_org_id
	      INTO l_selling_ou, l_ship_from_org_id
	      FROM oe_order_lines_all
	      WHERE
	      header_id = l_header_id AND
	      line_id = l_line_id;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF l_debug = 1 then
		  print_debug('cannot find sales order line ', l_api_name);
	       END IF;
	       fnd_message.set_name('INV', 'INV_NO_SALES_ORDER_LINE');
	       fnd_msg_pub.add;
	       RAISE fnd_api.g_exc_error;
	 END;

	 IF l_debug = 1 then
	    print_debug('l_selling_ou '||l_selling_ou||
			' l_ship_from_org_id '||l_ship_from_org_id, l_api_name);
	 END IF;

         BEGIN
	    SELECT org_information3
	      INTO l_ship_from_ou
	      FROM HR_ORGANIZATION_INFORMATION HOI
	      WHERE HOI.ORGANIZATION_ID= l_ship_from_org_id
	      AND HOI.ORG_INFORMATION_CONTEXT = 'Accounting Information';
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_ship_from_ou := NULL;
	       IF l_debug = 1 then
		  print_debug('cannot find ship from operating unit', l_api_name);
	       END IF;
	 END;

	 IF l_debug = 1 then
	    print_debug('l_ship_from_ou '||l_ship_from_ou, l_api_name);
	 END IF;

	 IF (l_selling_ou IS NULL) OR (l_ship_from_ou IS NULL) THEN
	    fnd_message.set_name('INV', 'INV_NULL_SELLSHIP_OU');
	    fnd_msg_pub.add;
	    RAISE fnd_api.g_exc_error;
	 END IF;

	 /******* Calling get transaction flow for the operating units*******/

	 l_qualifier_code_tbl.DELETE;
	 l_qualifier_value_tbl.DELETE;

         BEGIN
	    SELECT category_id INTO l_qualifier_value_tbl(1)
	      FROM mtl_item_categories
	      WHERE
	      inventory_item_id = l_inventory_item_id
	      AND organization_id = l_ship_from_org_id
	      AND category_set_id = 1;

	    l_qualifier_code_tbl(1) := 1;

	    IF l_debug = 1 then
	       print_debug('category id'||l_qualifier_value_tbl(1), l_api_name);
	    END IF;

	 EXCEPTION
	    WHEN no_data_found THEN
	       l_qualifier_value_tbl.DELETE;
	       l_qualifier_value_tbl.DELETE;

	    when too_many_rows then
	       fnd_message.set_name('INV', 'INV_TOO_MANY_CATEGORIES');
	       fnd_msg_pub.add;
	       RAISE fnd_api.g_exc_error;
	 END;

	 INV_TRANSACTION_FLOW_PUB.CHECK_TRANSACTION_FLOW
	   (p_api_version		  => 1.0
	    ,p_start_operating_unit  => l_ship_from_ou
	    ,p_end_operating_unit	  => l_selling_ou
	    ,p_flow_type		  => 1 --shipping
	    ,p_organization_id	  => l_ship_from_org_id
	    ,p_qualifier_code_tbl	  => l_qualifier_code_tbl
	    ,p_qualifier_value_tbl	  => l_qualifier_value_tbl
	    ,p_transaction_date	  => l_transaction_date
	    ,x_return_status	  => l_return_status
	    ,x_msg_count		  => l_msg_data
	    ,x_msg_data		  => l_msg_count
	    ,x_header_id		  => l_txn_flow_header_id
	    ,x_new_accounting_flag	  => l_new_accounting_flag
	    ,x_transaction_flow_exists => l_transaction_flow_exists
	    );

	 IF l_debug = 1 THEN
	    print_debug('check_transaction_flow Ret Status '|| l_return_status, l_api_name);
	    print_debug('Ret Message '||l_msg_data, l_api_name);
	    print_debug('l_transaction_flow_exists '||l_transaction_flow_exists, l_api_name);
	    print_debug('l_txn_flow_header_id '||l_txn_flow_header_id, l_api_name);
	    print_debug('l_new_accounting_flag '||l_new_accounting_flag, l_api_name);
	 END IF;

	 IF l_return_status <> fnd_api.g_ret_sts_success THEN

	    RAISE fnd_api.g_exc_unexpected_error;

	  ELSIF (l_transaction_flow_exists = g_transaction_flow_found)
	    AND (l_new_accounting_flag in ('Y','y')) THEN
	    --Drop ship logical
	    x_dropship_type_code := G_LOGICAL_RECEIPT_FOR_DS;
	    IF l_transaction_type = 'DELIVER' THEN
	       x_header_id := l_txn_flow_header_id;
	       x_transaction_type_id := INV_GLOBALS.G_TYPE_LOGL_PO_RECEIPT;
	       x_transaction_action_id := INV_GLOBALS.G_ACTION_LOGICALRECEIPT;
	       x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;
	     ELSIF l_transaction_type = 'CORRECT' THEN
	       x_header_id := l_txn_flow_header_id;
	       x_transaction_type_id := INV_GLOBALS.G_TYPE_LOGL_PO_RECEIPT_ADJ;
	       x_transaction_action_id := INV_GLOBALS.G_ACTION_LOGICALDELADJ;
	       x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;
	    END IF;
	  ELSE
	    --Drop ship Physical
	    x_dropship_type_code := G_PHYSICAL_RECEIPT_FOR_DS;
	    IF l_transaction_type = 'DELIVER' THEN
	       x_transaction_type_id := INV_GLOBALS.G_TYPE_PO_RECEIPT;
	       x_transaction_action_id := INV_GLOBALS.G_ACTION_RECEIPT;
	       x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;
	     ELSIF l_transaction_type = 'CORRECT' THEN
	       x_transaction_type_id := INV_GLOBALS.G_TYPE_PO_RCPT_ADJ;
	       x_transaction_action_id := INV_GLOBALS.G_ACTION_DELIVERYADJ;
	       x_transaction_source_type_id := INV_GLOBALS.G_SOURCETYPE_PURCHASEORDER;
	    END IF;
	 END IF;

      END IF;--NOT l_external_drop_ship
   END IF;--else of IF l_transaction_type = 'RETURN TO RECEIVING'

   IF l_debug = 1 THEN
      print_debug('Return values ', l_api_name);
      print_debug('x_dropship_type_code '||x_dropship_type_code, l_api_name);
      print_debug('x_header_id '||x_header_id, l_api_name);
      print_debug('x_transaction_type_id '||x_transaction_type_id||
		  ' x_transaction_action_id '||x_transaction_action_id||
		  ' x_transaction_source_type_id '||x_transaction_source_type_id, l_api_name);
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_dropship_type_code := -99;
      x_transaction_type_id := -99;
      x_transaction_action_id := -99;
      x_transaction_source_type_id := -99;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_dropship_type_code := -99;
      x_transaction_type_id := -99;
      x_transaction_action_id := -99;
      x_transaction_source_type_id := -99;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_dropship_type_code := -99;
      x_transaction_type_id := -99;
      x_transaction_action_id := -99;
      x_transaction_source_type_id := -99;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PACKAGE_NAME, 'GET_DROPSHIP_PO_TXN_TYPE');
      end if;
END GET_DROPSHIP_PO_TXN_TYPE;


/** Get_Inventory_Org function
 * Private function to get the inventory org of a specific OU
 */

FUNCTION GET_INVENTORY_ORG(
        p_reference_id                  IN NUMBER
      , p_global_procurement_flag       IN VARCHAR2
      , p_drop_ship_flag		IN VARCHAR2
      , x_transaction_date              OUT NOCOPY DATE
      , x_return_status                 OUT NOCOPY VARCHAR2
      , x_msg_data                      OUT NOCOPY VARCHAR2
      , x_msg_count                     OUT NOCOPY NUMBER
) RETURN NUMBER IS
   l_organization_id NUMBER;
   l_transaction_date DATE;
   l_progress NUMBER := 0;
   l_doc_type VARCHAR2(4);
   l_whse_code VARCHAR2(4);
   l_line_id NUMBER;
BEGIN
   print_debug('Inside get_inventory_org', 'Get_Inventory_Org');
   print_debug('p_reference_id = ' || p_reference_id, 'Get_Inventory_org');
   print_Debug('p_global_procurement_flag = ' || p_global_procurement_flag, 'Get_Inventory_Org');
   print_Debug('p_drop_ship_flag = ' || p_drop_ship_flag, 'Get_Inventory_org');

   /* OPM INVCONV umoogala
    * This code will not longer be needed for process mfg.orgs
   IF ( GML_PROCESS_FLAGS.process_orgn = 1 AND GML_PROCESS_FLAGS.opmitem_flag = 1 ) THEN

        SELECT doc_type, line_id, whse_code
        INTO   l_doc_type, l_line_id, l_whse_code
        FROM   ic_tran_pnd
        WHERE  trans_id = p_reference_id;

        IF l_doc_type = 'OMSO' THEN
            SELECT WHS.mtl_organization_id, oeh.ordered_date
            INTO   l_organization_id, l_transaction_date
            FROM   ic_whse_mst WHS
                   , oe_order_lines_all OEL
		   , oe_order_headers_all OEH
            WHERE  OEL.line_id = l_line_id
		   AND oel.header_id = oeh.header_id
                   AND WHS.whse_code = l_whse_code;
         ELSIF l_doc_type = 'PORC' THEN
            SELECT WHS.mtl_organization_id,  oeh.ordered_date
            INTO   l_organization_id, l_transaction_date
            FROM   ic_whse_mst WHS
                   , oe_order_lines_all OEL
		   , oe_order_headers_all OEH
                   , rcv_transactions RCT
		   , po_requisition_headers_all poh
		   , po_requisition_lines_all pol
            WHERE  poh.requisition_header_id = pol.requisition_header_id
              AND  pol.requisition_line_id = oel.orig_sys_document_Ref
	      AND  oel.order_source_id = 10
	      AND oel.header_id = oeh.header_id
              AND RCT.transaction_id = l_line_id
	      AND RCT.requisition_line_id = pol.requisition_line_id
              AND WHS.whse_code = l_whse_code;
        END IF;
   else
   end OPM INVCONV */

   if( p_global_procurement_flag = 'N' )
   then
      -- this means this is not a global procurement
      -- we need to check if this is a drop ship with procuring flow
      print_debug('Inside p_global_procurement_flag = N', 'Get_Inventory_Org');

      if( p_drop_ship_flag = 'N')
      then
           l_progress := 1;
                 BEGIN
                      select mmt.organization_id, transaction_date
                      into l_organization_id, l_transaction_date
                      From mtl_material_transactions mmt
                      where mmt.transaction_id= p_reference_id;
                 EXCEPTION
                      WHEN NO_DATA_FOUND then
                         FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_TRANSACTIONS');
                         FND_MESSAGE.SET_TOKEN('ID', p_reference_id);
                         FND_MSG_PUB.ADD;
                         raise FND_API.G_EXC_ERROR;
                 END;
      else
           l_progress := 2;
           -- this is a true drop ship with procuring flow
                 BEGIN
                      select oel.ship_from_org_id, oeh.ordered_date
                      into   l_organization_id, l_transaction_date
                      FROM   oe_order_lines_all oel, oe_order_headers_all oeh
                      where  oel.line_id = p_reference_id
                      AND    oel.header_id = oeh.header_id;
                 EXCEPTION
                      WHEN NO_DATA_FOUND then
                          FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SALES_ORDER');
                          FND_MESSAGE.SET_TOKEN('LINE', p_reference_id);
                          FND_MSG_PUB.ADD;
                          raise FND_API.G_EXC_ERROR;
                 END;
      end if;
    else
      -- this is global procurement flow.
      l_progress := 3;
      BEGIN
           select rcv.organization_id, transaction_date
           into l_organization_id, l_transaction_date
           FROM rcv_transactions rcv
           WHERE rcv.transaction_id = p_reference_id;
      EXCEPTION
            WHEN NO_DATA_FOUND then
                FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_RCV_TRANSACTION');
                FND_MESSAGE.SET_TOKEN('RCVID', p_reference_id);
                FND_MSG_PUB.ADD;
                raise FND_API.G_EXC_ERROR;
      END;
    end if;
    -- end if; OPM INVCONV

    x_transaction_date := l_transaction_date;
    x_return_status    := G_RET_STS_SUCCESS;
    fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
    );

    return l_organization_id;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR then
         x_return_status := G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

    WHEN OTHERS then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, 'Get_Inventory_Org');
         end if;

	 print_debug('in When Others, l_progress = ' || l_progress, 'GET_INVENTORY_ORG');

END GET_INVENTORY_ORG;

/**
 * Helper function to get the functioanl currency code of an operating unit
 */
Function get_functional_currency_code(
	p_org_id	IN NUMBER,
	x_sets_of_book_id OUT NOCOPY NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_data	OUT NOCOPY VARCHAR2,
	x_msg_count 	OUT NOCOPY NUMBER) return VARCHAR2
IS
  l_functional_currency_code VARCHAR2(31);
  l_progress NUMBER := 0;
  l_set_of_book_id NUMBER;
  lreturn_status VARCHAR2(1);
  lmsg_data      VARCHAR2(100);
  lsob_id        NUMBER;
  lcoa_id        NUMBER;

BEGIN
    l_functional_currency_code := '';
    x_return_status := G_RET_STS_SUCCESS;
    x_msg_data := null;
    x_msg_count := 0;

    print_debug('Start Get_Functional_Currency_Code', 'Get_Functional_Currency_Code');
    print_debug('p_org_id ' || p_org_id, 'Get_Functional_Currency_Code');

    -- print_Debug('Get the set of books', 'get_functional_currency_code');
    -- Modified the message text set of books to ledger for making the message compatible with LE uptake project
    print_Debug('Get the ledgers', 'get_functional_currency_code');

    /* commented the selection of COA using LE - OU link which is obsoleted in R12
       and replaced the code with selection of COAs using the API - INV_GLOBALS.GET_LEDGER_INFO
      Bug No - 4336479
    BEGIN
	    l_progress := 1;
            SELECT to_number(LEI.org_information1)
            into l_set_of_book_id
            FROM HR_ORGANIZATION_INFORMATION LEI, HR_ORGANIZATION_UNITS OU,
                 HR_ORGANIZATION_INFORMATION OUI
            WHERE OU.organization_id = p_org_id
            AND   LEI.org_information_context = 'Legal Entity Accounting'
            AND   to_char(LEI.organization_id) = OUI.org_information2
            AND   OUI.org_information_context = 'Operating Unit Information'
            AND   OUI.organization_id = OU.organization_id;
    EXCEPTION
        when no_data_found then
                -- print_Debug('cannot find the set of book of the ou ', 'Get_Functional_Currency_Code');
                -- Modified the message text set of books to ledger for making the message compatible with LE uptake project
                print_Debug('cannot find the ledger of the ou ', 'Get_Functional_Currency_Code');
                FND_MESSAGE.SET_NAME('INV', 'IC-INVALID BOOKS');
		FND_MESSAGE.SET_TOKEN('ID', p_org_id);
                FND_MSG_PUB.ADD;
                raise FND_API.G_EXC_ERROR;
    END;
    */
    BEGIN
            l_progress := 1;
            Inv_globals.get_ledger_info(
                                   x_return_status                => lreturn_status,
                                   x_msg_data                     => lmsg_data  ,
                                   p_context_type                 => 'Operating Unit Information',
                                   p_org_id                       => p_org_id,
                                   x_sob_id                       => lsob_id,
                                   x_coa_id                       => lcoa_id,
                                   p_account_info_context         => 'SOB');
           IF NVL(lreturn_status , 'S') = 'E' THEN
                FND_MESSAGE.SET_NAME('INV', 'IC-INVALID BOOKS');
                FND_MESSAGE.SET_TOKEN('ID', p_org_id);
                FND_MSG_PUB.ADD;
                print_debug('Cannot find the ledger information for operating unit = '||p_org_id  , 9);
                RAISE FND_API.G_EXC_ERROR;
           END IF;
           l_set_of_book_id := lsob_id;
    END;



    l_progress := 2;
    BEGIN
            select currency_code
            into l_functional_currency_code
            FROM gl_sets_of_books
            WHERE set_of_books_id = l_set_of_book_id;
    EXCEPTION
            when NO_DATA_FOUND then
                print_debug('cannot find the functional currency code', 'get_functional_currency_code');
                FND_MESSAGE.SET_NAME('SQLGL', 'GL funct curr does not exist');
                FND_MSG_PUB.ADD;
                raise FND_API.G_EXC_ERROR;
    end;

    print_debug('l_functional_currency_code is ' || l_functional_currency_code, 'get_functional_currency_code');
    x_sets_of_book_id := l_set_of_book_id;
    return l_functional_currency_code;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR then
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
	return null;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
        return null;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, 'get_functional_currency_code');
        end if;

	print_debug('in When Others, l_progress = ' || l_progress, 'get_functional_currency_code');
	print_Debug(sqlerrm, 'get_functional_currency_code');
        return null;

END get_functional_currency_code;


/* Package: INV_TRANSACTION_FLOWS_PUB
 * Function: convert_currency (
 * Description: This function is used to convert the transfer price
 * to the functional currency of a particular operating unit.
 *
 * Inputs:
 * 1. p_org_id - the operating unit to which functional currency the
 *    transfer price will be converted.
 * 2. p_transfer_price - the amount to be converted.
 * 3. p_currency_code - the original currency code to be converted to functional
 *    currency
 * 4. p_transaction_date - the date for which the conversion rate is used
 *
 * Output:
 * 1. x_functional_currency_code - the functional currency code of the p_org_id
 * 2. x_return_status - return status
 * 3. x_msg_data - the message on the message stack.
 * 4. x_msg_count - the number of message in the message stack
*/

FUNCTION CONVERT_CURRENCY (
          p_org_id              IN NUMBER
        , p_transfer_price      IN NUMBER
        , p_currency_code       IN VARCHAR2
        , p_transaction_date    IN DATE
        , p_logical_txn         IN VARCHAR2 DEFAULT 'N' /* bug 6696446 */
        , x_functional_currency_code OUT NOCOPY VARCHAR2
        , x_return_status       OUT NOCOPY VARCHAR2
        , x_msg_data            OUT NOCOPY VARCHAR2
        , x_msg_count           OUT NOCOPY NUMBER
) RETURN NUMBER
IS
    l_functional_currency_code VARCHAR2(30);
    l_set_of_book_id NUMBER;
    l_fixed_rate VARCHAR2(4) := 'N';
    l_conversion_type VARCHAR2(31);
    l_conversion_rate NUMBER;
    l_transfer_price NUMBER;
    l_progress NUMBER;
BEGIN
    x_functional_currency_code := '';
    x_return_status := G_RET_STS_SUCCESS;
    x_msg_data := null;
    x_msg_count := 0;

    print_debug('Start Convert_Currency', 'Convert_Currency');
    print_debug('p_org_id     p_transfer_price    p_currency_code    p_transaction_date', 'Convert_currency');
    print_Debug(p_org_id || ' ' || p_transfer_price || ' ' || p_currency_code || ' ' || p_transaction_date,
        'Convert_currency');

    if( G_FROM_ORG_ID = p_org_id ) THEN
	l_functional_currency_code := G_FUNCTIONAL_CURRENCY_CODE;
	l_set_of_book_id := G_SETS_OF_BOOK_ID;
    elsif( G_FROM_ORG_ID = -1 OR G_FROM_ORG_ID <> p_org_id ) then
	G_FROM_ORG_ID := p_org_id;
	l_functional_currency_code := get_functional_currency_code(
	     p_org_id, l_set_of_book_id, x_return_status, x_msg_data, x_msg_count);
	if( x_return_status <> G_RET_STS_SUCCESS ) then
	    raise FND_API.G_EXC_ERROR;
	else
	    G_FUNCTIONAL_CURRENCY_CODE := l_functional_currency_code;
	    G_SETS_OF_BOOK_ID := l_set_of_book_id;
	end if;
    end if;

    x_functional_currency_code := l_functional_currency_code;
    print_debug('l_functional_currency_code is ' || l_functional_currency_code, 'convert_currency');
    print_Debug('calling gl_currency_api.is_fix_rate', 'convert_currency');

    if( l_functional_currency_code <> p_currency_code ) then
        print_Debug('calling gl_currency_api.is_fix_rate', 'convert_currency');
        l_fixed_rate := gl_currency_api.is_fixed_rate(
            p_currency_code, l_functional_currency_code,  p_transaction_date);

        print_debug('l_fixed_rate is ' || l_fixed_rate, 'convert_currency');
        l_conversion_type := fnd_profile.value('IC_CURRENCY_CONVERSION_TYPE');
        if( l_fixed_rate =  'Y' ) then
            l_conversion_type := 'EMU FIXED';
        end if;

        print_Debug('l_conversion_type is ' || l_conversion_type, 'convert_currency');
	print_Debug('l_set_of_book_id is ' || l_set_of_book_id, 'convert_currency');
	print_Debug('p_currency_code is ' || p_currency_code, 'convert_currency');
	print_Debug('p_transfer_price is ' || p_transfer_price, 'convert_currency');
	print_Debug('p_transaction_date is ' || p_transaction_date, 'convert_currency');

    -- Added following for bug 6696446
        print_Debug('p_logical_txn is ' || p_logical_txn, 'convert_currency');

        IF p_logical_txn = 'Y' THEN  /* Added if condition for bug 6696446 */

            print_debug('calling gl_currency_api.get_rate_sql ',  'convert_currency');
            l_conversion_rate := gl_currency_api.get_rate_sql(
                                 x_set_of_books_id   => l_set_of_book_id
                                , x_from_currency     => p_currency_code
                                , x_conversion_date   => p_transaction_date
                                , x_conversion_type   => l_conversion_type
                                 );
            print_debug('l_conversion_rate is '||l_conversion_rate,  'convert_currency');

            IF l_conversion_rate = -1 THEN
                l_transfer_price := -1;
            ELSIF l_conversion_rate = -2 THEN
                l_transfer_price := -2;
            ELSE
                print_debug('Before conversion p_transfer_price : '||p_transfer_price,  'convert_currency');
                print_debug('l_conversion_rate : '||l_conversion_rate,  'convert_currency');

                l_transfer_price := p_transfer_price * l_conversion_rate;
                print_debug('After conversion l_transfer_price : '|| l_transfer_price,  'convert_currency');
            END IF;

        ELSIF p_logical_txn = 'N' THEN

            print_debug('calling gl_currency_api.converT_amount_sql ', 'convert_currency');
            l_transfer_price := gl_currency_api.convert_amount_sql(
                x_set_of_books_id       => l_set_of_book_id
                , x_from_currency       => p_currency_code
                , x_conversion_date     => p_transaction_date
                , x_conversion_type     => l_conversion_type
                , x_amount              => p_transfer_price
            );

        END IF; /* p_logical_txn = 'Y' */

        if( l_transfer_price = -1 ) then
            print_debug('ic no conversion rate', 'convert_currency');
            FND_MESSAGE.SET_NAME('INV', 'IC-No conversion rate');
	    FND_MESSAGE.SET_TOKEN('CONV_TYPE', l_conversion_type);
	    FND_MESSAGE.SET_TOKEN('FROM_CURR', p_currency_code);
	    FND_MESSAGE.SET_TOKEN('TO_CURR', l_functional_currency_code);
            FND_MSG_PUB.ADD;
            raise FND_API.G_EXC_ERROR;
        elsif( l_transfer_price = -2 ) then
            print_Debug('ic invalid currency', 'convert_currency');
            FND_MESSAGE.SET_NAME('INV', 'IC-Invalid_Currency');
	    FND_MESSAGE.SET_TOKEN('FROM_CURR', p_currency_code);
            FND_MSG_PUB.ADD;
            raise FND_API.G_EXC_ERROR;
        end if;
    else
	l_transfer_price := p_transfer_price;
    end if;

    print_debug('l_transfer_price is ' || l_transfer_price, 'convert_currency');
    x_return_status := G_RET_STS_SUCCESS;
    fnd_msg_pub.count_and_get (
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data
    );


    return l_transfer_price;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR then
        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
	return -99;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
        return -99;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, 'Convert_Currency');
        end if;

	print_debug('in When Others, l_progress = ' || l_progress, 'Convert_Currency');
	print_Debug(sqlerrm, 'Convert_Currency');
        return -99;

end convert_currency;

/*==========================================================================================================
 * Package: INV_TRANSACTION_FLOWS_PUB
 *
 * Procedure: GET_TRANSFER_PRICE_FOR_ITEM
 *
 * Description:
 * This API gets the transfer price in the transaction UOM using the following defaulting mechanism:
 * 1.	list price at transaction UOM I established transfer price list
 * 2.	Transaction cost of shipment transaction.
 * This API will be called by Oracle Inventory as well as Oracle CTO for CTO item
 *
 * Inputs:
 * - 	From_Org_ID - the start operating unit
 * -	To_Org_Id - The End operating Unit
 * -	Transaction_UOM - the transaction units of meassure
 * -	Invenotry_Item_ID - the inventory item identifier
 * -	Transaction ID - the logical transaction id
 * -	price_list_id - the static price list id.
 *
 * Outputs:
 * - x_transfer_price - the unit transfer price of the item
 * - x_currency_code - the currency code of the transfer price
 * - x_return_Status -  the return status
 * - x_msg_data - the error message
 * - x_msg_count - the message count
 *
 * History:
 *   umoogala        21-Apr-2006     Bug  5171637/5138311: Process/Discrete Xfers Enh.
 *     Removed parameter p_process_discrete_xfer_flag added as part of above fix, and replaced it
 *     with p_order_line_id to make it clear. Fix for bug 5126431 caused ORA error. The get_transfer_price
 *     API expects, transaction_id. But, different programs pass different value in transaction_id.
 *     --
 *     INV: Logical Txn procedure (INVTLTPBB.pls) puts order line_id as transaction_id with
 *          global_procurement flag to N.
 *     INV: InterCompany Invocing Program: sends mmt.transaction_id.
 *     RCV: puts rcv_transaction_id as transaction_id with global_procurement flag to 'Y'
 *          and drop_ship_flag to 'N'.
 *     GMF: calls this API with order line_id as transaction_id
 *     --
 *
 *============================================================================================================*/
Procedure get_transfer_price_for_item
(
  x_return_status	OUT NOCOPY	VARCHAR2
, x_msg_data		OUT NOCOPY	VARCHAR2
, x_msg_count		OUT NOCOPY	NUMBER
, x_transfer_price	OUT NOCOPY	NUMBER
, x_currency_code	OUT NOCOPY	VARCHAR2
, p_api_version             IN          NUMBER
, p_init_msg_list           IN          VARCHAR2
, p_from_org_id		    IN		NUMBER
, p_to_org_id		    IN		NUMBER
, p_transaction_uom	    IN		VARCHAR2
, p_inventory_item_id	    IN		NUMBER
, p_transaction_id	    IN 		NUMBER
, p_from_organization_id    IN		NUMBER DEFAULT null
, p_price_list_id	    IN		NUMBER
, p_global_procurement_flag IN          VARCHAR2
, p_drop_ship_flag	    IN 		VARCHAR2 DEFAULT 'N'
, p_cto_item_flag	    IN 		VARCHAR2 DEFAULT 'N'
-- , p_process_discrete_xfer_flag IN       VARCHAR2 DEFAULT 'N'    -- Bug  4750256
, p_order_line_id           IN          VARCHAR2 DEFAULT  NULL
                                        -- Bug 5171637/5138311 umoogala:
                                        -- replaced above line with this one.
) IS
  l_invoice_currency_code VARCHAR2(30);
  l_return_Status VARCHAR2(1);
  l_msg_data VARCHAR2(255);
  l_msg_count NUMBER;
  l_debug NUMBER := nvl(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
  l_transfer_price NUMBER := 0;
  l_qp_profile NUMBER := nvl(fnd_profile.value('INV_USE_QP_FOR_INTERCOMPANY'), 2);
  l_transfer_price_code NUMBER := -1;
  l_organization_id NUMBER;
  l_functional_currency_code VARCHAR2(30);
  l_uom_rate NUMBER;
  l_primary_uom VARCHAR2(4);
  l_transaction_date DATE;
  l_fixed_rate VARCHAR2(1);
  l_progress NUMBER;

  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'GET_TRANSFER_PRICE_FOR_ITEM';
  l_flow_type 	NUMBER := G_SHIPPING_FLOW_TYPE;
  l_transaction_id NUMBER;
  l_order_line_id NUMBER;
  l_order_header_id NUMBER;
  l_inventory_item_id NUMBER;
  l_currency_code VARCHAR2(30);
  l_currency_org  NUMBER;
  l_qp_price_flag BOOLEAN := false;
  l_set_of_book_id NUMBER;
  l_inv_currency_code NUMBER;
  l_count 		NUMBER := 0;
  l_item_description	VARCHAR2(255);
  l_price_list_name	VARCHAR2(255);

  l_from_ou_name	VARCHAR2(255);
  l_to_ou_name 		VARCHAR2(255);
  l_cto_item_flag	VARCHAR2(1) := p_cto_item_flag;
  l_ato_line_id number; --bug 5126431
  l_trf_price_date date; --bug 6700919
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
   x_msg_data := null;
   x_msg_count := 0;
   x_transfer_price := 0;
   x_currency_code := null;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
	       l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   --
   -- Bug 5171637/5138311 umoogala: INVCONV
   -- Added following IF condition.
   -- We calling this API from Inventory Interface when Sales Order is
   -- ship confirmed. So, we do not have MMT transaction_id at this point.
   -- For this reason, we are sending order_line_id, which gets used by
   -- Advanced Pricing Engine.
   --
   IF p_order_line_id IS NOT NULL
   THEN
     l_order_line_id := p_order_line_id;
   ELSE

--- Bug 9458617. Added the p_global_procurement_flag check.
   IF (nvl(p_global_procurement_flag,'N') = 'N') THEN

     BEGIN --5126431
        IF l_cto_item_flag = 'Y' THEN

           select l.ato_line_id,l.header_id
             into l_ato_line_id,l_order_header_id
             from mtl_material_transactions mmt
                , oe_order_lines_all l
            WHERE MMT.transaction_id = p_transaction_id
              AND l.line_id = mmt.trx_source_line_id;

              SELECT line_id
                INTO l_order_line_id
                from oe_order_lines_all
               where header_id=l_order_header_id
                 and ato_line_id=l_ato_line_id
                 and inventory_item_id=p_inventory_item_id;
        ELSE

              SELECT trx_source_line_id
               INTO l_order_line_id
                 FROM mtl_material_transactions
                 WHERE transaction_id = p_transaction_id;

        END IF;
        EXCEPTION
           when no_data_found then
           l_order_header_id := NULL;
           l_order_line_id := NULL;
           l_ato_line_id := NULL;
     END;
     --End of 5126431
   END IF;
   END IF;

   --
   -- Bug 5527437 umoogala
   --
   IF (p_order_line_id IS NULL AND p_transaction_id IS NULL AND p_cto_item_flag = 'Y')
   THEN
     l_order_line_id := G_ORDER_LINE_ID;
   END IF;


   print_debug('START GET_TRANSFER_PRICE_FOR_ITEM', 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug('Input Parameter ' , 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug('--------------- ' , 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_api_version = ' || p_api_version, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_init_msg_list = ' || p_init_msg_list, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_from_org_id = ' || p_from_org_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_to_org_id = ' || p_to_org_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_transaction_uom = ' || p_transaction_uom, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_inventory_item_id = ' || p_inventory_item_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_transaction_id = ' || p_transaction_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_price_list_id = ' || p_price_list_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_global_procurement_flag = ' || p_global_procurement_flag, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_drop_ship_flag = ' || p_drop_ship_flag, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_from_organization_id = ' || p_from_organization_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' p_cto_item_flag = ' || p_cto_item_flag, 'GET_TRANSFER_PRICE_FOR_ITEM');
   -- print_debug(' p_process_discrete_xfer_flag = ' || p_process_discrete_xfer_flag, 'GET_TRANSFER_PRICE_FOR_ITEM'); /* INVCONV Bug 4750256 */
   print_debug(' l_order_header_id = ' || l_order_header_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' l_ato_line_id = ' || l_ato_line_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' l_order_line_id = ' || l_order_line_id, 'GET_TRANSFER_PRICE_FOR_ITEM');
   print_debug(' G_ORDER_LINE_ID = ' || G_ORDER_LINE_ID, 'GET_TRANSFER_PRICE_FOR_ITEM');



   print_debug('Calling mtl_intercompany_invoices.get_transfer_price ',
            'Get_Transfer_Price_For_Item');

   --5126431: Added new parameter I_order_line_id

   l_transfer_price := MTL_INTERCOMPANY_INVOICES.get_transfer_price(
           I_transaction_id     => p_transaction_id
         , I_price_list_id      => p_price_list_id
         , I_sell_ou_id         => p_to_org_id
         , I_ship_ou_id         => p_from_org_id
         , O_currency_code      => l_invoice_currency_code
         , x_return_status      => l_return_status
         , x_msg_count          => l_msg_count
         , x_msg_data           => l_msg_data
         , I_order_line_id      => l_order_line_id
   );
   print_debug('Return Status from External API is ' || l_return_Status, 'Get_transfer_price_for_item');
   print_debug('Message Data from External API is ' || l_msg_data, 'Get_transfer_price_for_item');
   print_debug('Message Count from External API is ' || l_msg_count, 'Get_transfer_price_for_item');
   print_debug('Transfer price = ' || l_transfer_price, 'Get_transfer_price_for_item');
   print_debug('Currency code = ' || l_invoice_currency_code, 'Get_transfer_price_for_item');

   if( l_return_status <> G_RET_STS_SUCCESS ) then
        print_Debug('Error from mtl_intercompany_invoices.get_transfer_price', 'get_transfer_price_for_item');
        FND_MESSAGE.SET_NAME('INV', 'INV_ERROR_EXT_TRANSFER_PRICE');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
   end if;

   if( nvl(l_transfer_price, -1) = -1 ) then
       -- This means that we get nothing from the external api
       -- try to get the transfer price using the QP Engine

       if( p_from_organization_id is  not null ) then
	   l_organization_id := p_from_organization_id;
	   l_transaction_date := sysdate;
       else
	   print_debug('p_from_organization_id is null, need to call get_inventory_org', 'get_transfer_price_for_item');
           print_debug('Calling get_inventory_org', 'get_transfer_price_for_item');
           l_organization_id := get_inventory_org(
             p_reference_id                  => p_transaction_id
           , p_global_procurement_flag       => p_global_procurement_flag
	   , p_drop_ship_flag		   => p_drop_ship_flag
           , x_transaction_date              => l_transaction_date
           , x_return_status                 => l_return_status
           , x_msg_data                      => l_msg_data
           , x_msg_count                     => l_msg_count
           );
           print_debug('l_organization_id = ' || l_organization_id, 'geT_transfer_price_for_item');

           if( l_return_status <> G_RET_STS_SUCCESS ) then
               print_debug('Error from get_inventory_org', 'get_transfer_price_for_item');
               raise FND_API.G_EXC_ERROR;
           end if;
       end if;

       print_debug('l_qp_profile = ' || l_qp_profile, 'get_transfer_price_for_item');
       print_debug('l_qp_status = ' || qp_util.get_qp_status, 'get_transfer_price_for_item');

       if( QP_UTIL.get_qp_status <> 'I' OR l_qp_profile <> 1 ) then
            print_debug('QP is not install', 'Get_transfer_price_for_item');
	    print_debug('QP PRofile set to NO', 'Get_Transfer_Price_For_Item');
            print_debug('Get the static price list in transaction_uom', 'get_transfer_price_for_item');
          /* bug 6700919 Calling get_transfer_price_date to retreive the date
            by which price list price will be queried*/

            print_debug('Calling get_transfer_price_date', 'Get_Transfer_Price_For_Item');
            l_trf_price_date := get_transfer_price_date(
                p_call                                         => 'I'
               ,p_order_line_id                       => l_order_line_id
               ,p_global_procurement_flag => p_global_procurement_flag
               ,p_transaction_id                     => p_transaction_id
	       ,p_drop_ship_flag                   => p_drop_ship_flag
               ,x_return_status                       => l_return_status
               ,x_msg_data                             => l_msg_data
               ,x_msg_count                           => l_msg_count
               );

             print_debug('l_trf_price_date ='||l_trf_price_date, 'Get_Transfer_Price_For_Item');
             if( l_return_status <> G_RET_STS_SUCCESS ) then
               print_debug('Error from get_transfer_price_date', 'get_transfer_price_for_item');
               raise FND_API.G_EXC_ERROR;
            end if;

            BEGIN
                 l_transfer_price_code := 1;
                 /*Bug: 5054047 Modified the SQL*/
                 select SPLL.operand, substr(SPL.currency_code, 1, 15)
                 INTO l_transfer_price, l_invoice_currency_code
                 FROM qp_list_headers_b spl, qp_list_lines SPLL, qp_pricing_attributes qpa
                 WHERE SPL.list_header_id = p_price_list_id
                 AND   SPLL.list_header_id = SPL.list_header_id
                 AND   SPLL.list_line_id = qpa.list_line_id
                 AND   qpa.product_attribute_context = 'ITEM'
                 AND   qpa.product_attribute = 'PRICING_ATTRIBUTE1'
                 AND   qpa.product_attr_value = to_Char(p_inventory_item_id)
                 AND   qpa.product_uom_code = p_transaction_uom
                 AND   l_trf_price_date between nvl(SPLL.start_date_active, (l_trf_price_date-1)) AND
                              nvl(SPLL.end_date_active+0.99999, (l_trf_price_date+1)) --bug 6700919 changed sysdate to l_trf_price_date
                 AND qpa.qualification_ind = 4
                 AND qpa.excluder_flag = 'N'
                 AND qpa.pricing_phase_id=1
                 AND   rownum = 1;

                 print_debug('l_transfer_price = ' || l_transfer_price, 'get_transfer_price_for_item');
                 print_debug('l_invoice_currency_code = ' || l_invoice_currency_code, 'get_transfeR_price_for_item');

            EXCEPTION
                when no_data_found then
                    print_debug('Get static price list in primary uom', 'get_transfeR_price_for_item');
                    BEGIN
                        l_transfer_price_code := 2;
                        /*Bug: 5054047 Modified the SQL*/
                        SELECT SPLL.operand, substr(SPL.currency_code, 1, 15), msi.primary_uom_code
                        INTO l_transfer_price, l_invoice_currency_code, l_primary_uom
                        FROM QP_LIST_HEADERS_B SPL, QP_LIST_LINES SPLL,
                             QP_PRICING_ATTRIBUTES QPA, MTL_SYSTEM_ITEMS_B MSI
                        WHERE MSI.organization_id = l_organization_id
                        AND   MSI.inventory_item_id = p_inventory_item_id
                        AND   SPL.list_header_id = p_price_list_id
                        AND   SPLL.list_header_id = SPL.list_header_id
                        AND   QPA.list_header_id = SPL.list_header_id
                        AND   SPLL.list_line_id = QPA.list_line_id
                        AND   QPA.product_attribute_context = 'ITEM'
                        AND   QPA.product_attribute = 'PRICING_ATTRIBUTE1'
                        AND   QPA.product_attr_value = to_char(MSI.inventory_item_id)
                        AND   QPA.product_uom_code = MSI.primary_uom_code
                        AND   l_trf_price_date between nvl(SPLL.start_date_active, (l_trf_price_date-1))
                                AND nvl(SPLL.end_date_active + 0.99999, (l_trf_price_date+1)) --bug 6700919 changed sysdate to l_trf_price_date
                        AND qpa.qualification_ind = 4
                        AND qpa.excluder_flag = 'N'
                        AND qpa.pricing_phase_id=1
                        AND   rownum = 1;
                    EXCEPTION
                        when no_data_found THEN
                            print_debug('no price list found', 'get_transfer_price_for_item');

			    if( l_cto_item_flag = 'Y' ) then
				l_transfer_price := -99;
			    else
                                l_transfer_price := -99;
                                l_return_status := G_RET_STS_ERROR;
			        SELECT concatenated_segments, primary_uom_code
			        INTO l_item_description, l_primary_uom
			        FROM mtl_system_items_kfv
			        WHERE organization_id = l_organization_id
			        AND  inventory_item_id = p_inventory_item_id;

			        SELECT name
			        into l_price_list_name
			        FROM QP_LIST_HEADERS
			        WHERE list_header_id = p_price_list_id;

		                FND_MESSAGE.SET_NAME('QP', 'QP_PRC_NO_LIST_PRICE');
		                FND_MESSAGE.SET_TOKEN('ITEM', l_item_description);
		                FND_MESSAGE.SET_TOKEN('UNIT', l_primary_uom);
		                FND_MESSAGE.SET_TOKEN('PRICE_LIST', l_price_list_name);
		                FND_MSG_PUB.ADD;
			        raise fnd_api.g_exc_error;
			    end if;
                    end;
                when others then
                     print_debug('sqlerrm = ' || sqlerrm, 'get_transfer_price_for_item');
	             l_transfer_price := 0;
		     l_return_status := G_RET_STS_ERROR;
		     FND_MESSAGE.SET_NAME('INV', 'IC-No Transfer Price');
		     FND_MSG_PUB.ADD;
		     raise fnd_api.g_exc_error;
            END;
       else
	    l_qp_price_flag := TRUE;
	    if( p_global_procurement_flag = 'Y' ) then
		l_flow_type := G_PROCURING_FLOW_TYPE;
	    end if;
	    print_Debug('after setting the l_flow_type ', 'Get_transfer_price_for_item');

	    --
	    -- Setting order_line_id and transaction_id
	    --
	    IF (p_order_line_id IS NULL AND p_transaction_id IS NULL AND p_cto_item_flag = 'Y') THEN
	       print_Debug('Value of l_order_line_id = '||l_order_line_id, 'Get_transfer_price_for_item');
	    ELSIF p_order_line_id IS NOT NULL
	    then
	      --
              -- Bug 5171637/5138311 umoogala: INVCONV
	      -- Added this IF block
	      --
	      l_order_line_id := p_order_line_id;
	      l_transaction_id := null;
	    else
	      if( p_drop_ship_flag = 'Y' )
              then
	          l_order_line_id := nvl(l_order_line_id, p_transaction_id);
	          l_transaction_id := null;
	      --
	      -- Bug 5171637/5138311 umoogala: Commented following code and
	      -- replaced with first IF condition above.
	      --
              -- Bug  4750256, OPM INVCONV: Added this elsif block
	      -- elsif( p_drop_ship_flag = 'N' AND p_process_discrete_xfer_flag = 'Y')
              -- then
	      --    l_order_line_id  := p_transaction_id;
	      --    l_transaction_id := null;
	      else
	          print_debug(' p_drop_ship_flag is ' || p_drop_ship_flag, 'Get_transfer_price_for_item');
	          if( p_cto_item_flag = 'N') then
	              l_transaction_id := p_transaction_id;
	              l_order_line_id := null;
	          else
	              BEGIN
	                 select 1
	          	INTO  l_count
	          	From mtl_material_transactions
	          	WHERE transaction_id = p_transaction_id;

	          	l_transaction_id := p_transaction_id;
	          	l_order_line_id := null;
	              EXCEPTION
	          	WHEN no_data_found then
	          	     l_order_line_id := p_transaction_id;
	          	     l_transaction_id := null;
	              END;
	          end if;
	      end if;
	    end if;

            print_debug('After setting the l_order_line_id ' || l_order_line_id || ' l_transaction_id ' || l_transaction_id,
		'Get_Transfer_price_for_item');

	   /* BEGIN
		print_debug('about to delete the qp temp table', 'Get_Transfer_price_for_item');
		select count(*)
		into l_count
		From qp_preq_lines_tmp;

		if( l_count > 0 ) then
		    Delete from qp_preq_lines_tmp_t;
		end if;
	    EXCEPTION
		when others then
		    fnd_message.set_name('INV', 'INV_INT_SQLCODE');
		    fnd_msg_pub.add;
		    raise FND_API.G_EXC_ERROR;
	    end;*/

	    /* Added this for bug 3141793
        * The currency code in which the transfer price will be return is control by the
	     * value of inv_currency_code column in the mtl_intercompany_parameters
        * The possible value of inv_currency_code are:
        * 1 - Currency of the SHip/From/Procuring OU
        * 2 - Currency of the Sell/To/Receiving OU
        * 3 - Order Currency (Sales Order/Purchase Order)
        * We will cache the OU in which the currency will return
        * And also will cache the currency code
        */
	    if( p_global_procurement_flag = 'Y' ) then
	        l_flow_type := 2;
	    else
		l_flow_type := 1;
	    end if;

        /* Bug 4903269 moved the call in order to get the option of currency of sales order to work */
               BEGIN
                   select nvl(inv_currency_code, 1)
                   into l_inv_currency_code
                   From mtl_intercompany_parameters
                   where ship_organization_id = p_from_org_id
                   and sell_organization_id = p_to_org_id
                   and flow_type = l_flow_type;
                EXCEPTION
                   when no_data_found then
                       print_debug('No IC Relations exists between from OU and To OU', 'GET_TRANSFER_PRICE_FOR_ITEM');
                       SELECT name
                       INTO l_from_ou_name
                       FROM hr_operating_units
                       WHERE organization_id = p_from_org_id;


                       SELECT name
                       INTO l_to_ou_name
                       FROM hr_operating_units
                       WHERE organization_id = p_to_org_id;

                       FND_MESSAGE.SET_NAME('INV', 'IC-No INTERCO RELATION');
                       FND_MESSAGE.SET_TOKEN('FROM_OU', l_from_ou_name);
                       FND_MESSAGE.SET_TOKEN('TO_OU', l_to_ou_name);
                       FND_MSG_PUB.ADD;
                       raise FND_API.G_EXC_ERROR;
                END;



	    if( (G_FROM_ORG_ID = -1  AND G_TO_ORG_ID = -1 AND G_INV_CURR_ORG = -1)
		OR (G_FROM_ORG_ID <> p_from_org_id ) OR (G_TO_ORG_ID <> p_to_org_id ) OR (G_FLOW_TYPE <>l_flow_type)) THEN
	         -- This means that this API is called for the first time or the from OU and to OU
		 -- is not the same as the last time when this API is called.
		 -- Need to query the inv_currency_code from the database.

		G_FROM_ORG_ID := p_from_org_id;
		G_TO_ORG_ID := p_to_org_id;
		G_FLOW_TYPE := l_flow_type;

	        if( l_inv_currency_code = 1 ) then
	            l_currency_org := p_from_org_id;
	        elsif( l_inv_currency_code = 2 ) then
		    l_currency_org := p_to_org_id;
	        else
		    l_currency_org := 0;
	        end if;

		G_INV_CURR_ORG := l_currency_org;

 		G_FUNCTIONAL_CURRENCY_CODE :=  get_functional_currency_code(
			p_from_org_id, l_set_of_book_id, x_return_status, x_msg_data, x_msg_count);

		G_SETS_OF_BOOK_ID := l_set_of_book_id;

	        if( l_currency_org > 0 ) then
		    l_currency_code := get_functional_currency_code(
			l_currency_org, l_set_of_book_id, x_return_status, x_msg_data, x_msg_count);

	            if( x_return_status <> G_RET_STS_SUCCESS ) then
		        raise FND_API.G_EXC_ERROR;
	            end if;
	        end if;
		G_INV_CURR_CODE := l_currency_code;
	    ELSIF( (G_FROM_ORG_ID = p_from_org_id ) AND (G_TO_ORG_ID = p_to_org_id ) AND (G_FLOW_TYPE = l_flow_type) ) THEN
		l_currency_org := G_INV_CURR_ORG;
		l_currency_code := G_INV_CURR_CODE;
		--null;
	    END IF;

            print_Debug('Calling mtl_qp_price.get_transfer_price', 'Get_transfer_price_for_item');
            l_transfer_price := MTL_QP_PRICE.get_transfer_price_ds(
                p_transaction_id        => l_transaction_id
              , p_sell_ou_id            => p_to_org_id
              , p_ship_ou_id            => p_from_org_id
              , p_flow_type 		=> l_flow_type
	      , p_order_line_id		=> l_order_line_id
	      , p_inventory_item_id	=> p_inventory_item_id
	      , p_organization_id	=> l_organization_id
	      , p_uom_code		=> p_transaction_uom
	      , p_cto_item_flag		=> p_cto_item_flag
	      , p_incr_code		=> l_inv_currency_code
	      , p_incrcurrency		=> l_currency_code
              , x_currency_code         => l_invoice_currency_code
              , x_tfrPriceCode          => l_transfer_price_code
              , x_return_status         => l_return_status
              , x_msg_count             => l_msg_count
              , x_msg_data              => l_msg_data
            );

            print_Debug('l_transfer_price is ' || l_transfer_price, 'get_transfer_price_for_item');
            print_Debug('l_transfer_price_code = ' || l_transfer_price_code, 'get_transfer_price_for_item');
            print_Debug('l_invoice_currency_code = ' || l_invoice_currency_code, 'get_transfer_price_for_item');
            print_Debug('l_return_status = ' || l_return_status, 'get_transfer_price_for_item');
            print_Debug('l_msg_data = ' || l_msg_data, 'get_transfer_price_for_item');
            print_Debug('l_msg_count = ' || l_msg_count, 'get_transfer_price_for_item');

            if( l_return_status <> G_RET_STS_SUCCESS ) THEN
                print_Debug('Error from mtl_qp_price', 'get_transfer_price_for_item');
                raise FND_API.G_EXC_ERROR;
            end if;

            --Fixed for bug#9049184
            --primary uom is not derived in this part. When tranfer price code is
            --returned as 2 then we call to INV_CONVERT.inv_um_conversion is made
            --after this else part. But since the primary uom is not derived in this
            --part hence it is passed as null and this API fails with error
            --UOM conversion not defined.
            --below code is aded to select the primary UOM.
            if( nvl(l_transfer_price,0) > 0 AND  l_transfer_price_code = 2 AND l_primary_uom IS NULL
               AND p_inventory_item_id IS NOT NULL ) THEN
               print_Debug('l_primary_uom is Null ' || l_primary_uom, 'get_transfer_price_for_item');

                SELECT primary_uom_code
                into l_primary_uom
                FROM mtl_system_items
                WHERE organization_id = l_organization_id
                AND  inventory_item_id = p_inventory_item_id;

               print_Debug('l_primary_uom is ' || l_primary_uom, 'get_transfer_price_for_item');
            END IF;



	    IF( l_transfer_price is NULL or l_transfer_price = -99 ) then
		SELECT description
	        into l_item_description
		FROM mtl_system_items
		WHERE organization_id = l_organization_id
		AND  inventory_item_id = p_inventory_item_id;
	    END IF;

            if( l_transfer_price = -99 ) THEN
                print_Debug('qp price is wrong', 'get_transfeR_price_for_item');
                FND_MESSAGE.SET_NAME('INV', 'INV_QP_PRICE_ERROR');
		FND_MESSAGE.SET_TOKEN('ITEM', l_item_description);
                FND_MSG_PUB.ADD;
                l_transfer_price := 0;
            end if;

	    if( l_transfer_price is null ) then
                print_Debug('qp price is wrong', 'get_transfeR_price_for_item');
                FND_MESSAGE.SET_NAME('INV', 'INV_QP_PRICE_ERROR');
		FND_MESSAGE.SET_TOKEN('ITEM', l_item_description);
                FND_MSG_PUB.ADD;
                l_transfer_price := 0;
            end if;
       end if; -- if( QP_UTIL.get_qp_status <> 'I' OR l_qp_profile <> 1 )
    end if; -- if( nvl(l_transfer_price, -1) = -1 )

    l_progress := 2;
    if( l_debug = 1 ) then
        print_debug('Calling uom_conversion', 'get_transfer_price_for_item');
    end if;

    print_debug('l_transfer_price_code = '||l_transfer_price_code, 'get_transfer_price_for_item');
    print_debug('l_organization_id = '||l_organization_id, 'get_transfer_price_for_item');

    if( nvl(l_transfer_price,0) > 0 AND  l_transfer_price_code = 2 ) then

       IF l_primary_uom IS NULL THEN
          SELECT primary_uom_code
            INTO l_primary_uom
  	    FROM mtl_system_items
	   WHERE organization_id = l_organization_id
	     AND inventory_item_id = p_inventory_item_id;
	END IF;

        -- do uom conversion
        print_debug('Calling uom_conversion', 'get_transfer_price_for_item');
        INV_CONVERT.inv_um_conversion(
               from_unit   => p_transaction_uom
             , to_unit     => l_primary_uom
             , item_id     => p_inventory_item_id
             , uom_rate    => l_uom_rate
        );

        if( l_uom_rate = -99999 ) then
            print_debug('Error from Calling uom_conversion', 'get_transfer_price_for_item');
            FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_UOM_CONV');
	    FND_MESSAGE.SET_TOKEN('VALUE1', p_transaction_uom);
	    FND_MESSAGE.SET_TOKEN('VALUE2', l_primary_uom);
            FND_MSG_PUB.ADD;
            raise FND_API.G_EXC_ERROR;
        end if;
        print_debug('l_uom_rate is ' || l_uom_rate, 'get_transfer_price_for_item');

        l_transfer_price := l_uom_rate * l_transfer_price;
    end if;

    if( l_debug = 1 ) then
        print_debug('Calling convert_to_functional_currency', 'get_transfer_price_for_item');
    end if;

    /* Commented out the following currency conversion to From OU currency for Static Pricing*/
    /* Bug 4159025 */
   /* if( QP_UTIL.get_qp_status <> 'I' OR l_qp_profile <> 1 )  THEN
        l_transfer_price := convert_currency(
          p_org_id              => p_from_org_id
        , p_transfer_price      => l_transfer_price
        , p_currency_code       => l_invoice_currency_code
        , p_transaction_date    => l_transaction_date
        , x_functional_currency_code => l_functional_currency_code
        , x_return_status       => l_return_status
        , x_msg_data            => x_msg_data
        , x_msg_count           => x_msg_count
        );

        if( l_return_status <> G_RET_STS_SUCCESS ) then
            print_debug('Error from convert_currency', 'get_transfer_price_for_item');
            raise FND_API.G_EXC_ERROR;
        end if;
    else*/

    l_functional_currency_code := l_invoice_currency_code;

    print_Debug('l_transfer_price = ' || l_transfer_price, 'get_transfer_price_for_item');
    print_Debug('x_currency_code = ' || l_functional_currency_code, 'get_transfer_price_for_item');

    /** THe currency code return is if it's not qp, return the functional currency of the shipping OU
        else if it is QP, return the currency code pass to qp **/

    x_transfer_price := l_transfer_price;
    x_currency_code := l_functional_currency_code;
    x_return_status := l_return_status;

    fnd_msg_pub.count_and_get(
               p_encoded => fnd_api.g_false,
               p_count => x_msg_count,
               p_data => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := G_RET_STS_ERROR;
        x_transfer_price := -99;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        x_transfer_price := -99;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

    WHEN OTHERS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, l_api_name);
        end if;

	print_debug('in When Others, l_progress = ' || l_progress, 'Get_Transfer_price');

END get_transfer_price_for_item;

/*==========================================================================================================
 * Procedure: GET_TRANSFER_PRICE
 *
 * Description:
 * This API is wrapper API to the Get_Transfer_Price API.
 * This API will be called by Oracle Inventory Create_logical_transaction API
 * as well as Oracle Costing.
 * This API will be called with transaction_uom as : PO UOM or SO UOM, whichever is applicable.
 * The API will return the transfer_price in the Transaction_UOM that was passed to it.
 * The currency of the price will be the currency set in the price list.
 * The calling program will take care of appropriate conversions of UOM and currency.
 *
 * Inputs:
 * - 	From_Org_ID - the start operating unit
 * -	To_Org_Id - The End operating Unit
 * -	Transaction UOM - the units of meassure
 * -	Invenotry_Item_ID - the inventory item identifier
 * -    Transaction ID - the inventory transaction ID
 * Outputs:
 * - 	x_transfer_price  - The total price for the item. If there are no pricelist found, then return 0
 * -	x_currency_code - the currency code of the transfer price
 * - 	x_return_status -  the return status - S - success, E - Error, U - Unexpected Error
 * - 	x_msg_data - the error message
 * - 	x_msg_count - the number of messages in the message stack.
 *
 *==========================================================================================================*/

Procedure Get_Transfer_Price
(
  x_return_status	OUT NOCOPY 	VARCHAR2
, x_msg_data		OUT NOCOPY	VARCHAR2
, x_msg_count		OUT NOCOPY	NUMBER
, x_transfer_price	OUT NOCOPY	NUMBER
, x_currency_code	OUT NOCOPY	VARCHAR2
, x_incr_transfer_price  OUT NOCOPY      NUMBER
, x_incr_currency_code   OUT NOCOPY      VARCHAR2
, p_api_version             IN          NUMBER
, p_init_msg_list           IN          VARCHAR2
, p_from_org_id		    IN		NUMBER
, p_to_org_id		    IN 		NUMBER
, p_transaction_uom	    IN		VARCHAR2
, p_inventory_item_id	    IN		NUMBER
, p_transaction_id	    IN		NUMBER
, p_from_organization_id    IN          NUMBER DEFAULT NULL
, p_global_procurement_flag IN          VARCHAR2
, p_drop_ship_flag	    IN 		VARCHAR2 DEFAULT 'N'
-- , p_process_discrete_xfer_flag IN       VARCHAR2 DEFAULT 'N'    -- Bug  4750256
, p_order_line_id           IN          VARCHAR2 DEFAULT  NULL
                                        -- Bug 5171637/5138311 umoogala:
                                        -- replaced above line with this one.
, p_txn_date                IN          DATE DEFAULT NULL        /* added for bug 8282784 */
) IS

   l_base_item NUMBER := 0;
   l_organization_id NUMBER := 0;
   l_transaction_action_id NUMBER := 0;
   l_transaction_source_type_id NUMBER := 0;
   l_transaction_type_id NUMBER := 0;
   l_trx_source_line_id NUMBER := 0;
   l_exists NUMBER := 0;
   l_transfer_price NUMBER := 0;
   l_currency_code VARCHAR2(30);
   l_inventory_item_id NUMBER;
   l_functional_currency_code VARCHAR2(30);
   l_debug NUMBER := nvl(FND_PROFILE.VALUE('INV_DEBUG_TRACE'), 0);
   l_return_status VARCHAR2(1);
   l_msg_data VARCHAR2(255);
   l_msg_count NUMBER;
   l_transaction_date DATE;
   l_price_list_id NUMBER;
   l_progress NUMBER;
   l_api_version_number CONSTANT NUMBER := 1.0;
   l_api_name 		CONSTANT VARCHAR2(30) := 'GET_TRANSFER_PRICE';
   l_inv_transfer_price NUMBER;
   l_inv_currency_code VARCHAR2(30);
   l_flow_type		NUMBER;
   l_from_ou_name 	VARCHAR2(240);
   l_to_ou_name         VARCHAR2(240);
   l_location		VARCHAR2(40);
   l_customer_number	VARCHAR2(30);
 --For bug6460311.column length in table hz_parties is varchar2(360)
 --l_customer_name	VARCHAR2(50);
   l_customer_name	VARCHAR2(360);
   l_cto_item_flag      VARCHAR2(1);
   l_trx_src_type_id    NUMBER := NULL;
   l_inventory_item_id NUMBER := p_inventory_item_id;
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
   x_msg_data := null;
   x_msg_count := 0;
   x_transfer_price := 0;
   x_currency_code := null;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(
	       l_api_version_number
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --  Initialize message list.
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;


   print_debug('START GET_TRANSFER_PRICE', 'GET_TRANSFER_PRICE');
   print_Debug('Input Parameters', 'GET_TRANSFER_PRICE');
   print_Debug('----------------', 'GET_TRANSFER_PRICE');
   print_Debug('p_api_version is  ' || p_api_version, 'GET_TRANSFER_PRICE');
   print_Debug('p_init_msg_list' || p_init_msg_list, 'GET_TRANSFER_PRICE');
   print_Debug('p_from_org_id is ' || p_from_org_id, 'GET_TRANSFER_PRICE');
   print_Debug('p_to_org_id is ' || p_to_org_id, 'GET_TRANSFER_PRICE');
   print_Debug('p_transaction_uom is ' || p_transaction_uom, 'GET_TRANSFER_PRICE');
   print_Debug('p_inventory_item_id is ' || p_inventory_item_id, 'GET_TRANSFER_PRICE');
   print_Debug('p_transaction_id is  ' || p_transaction_id, 'GET_TRANSFER_PRICE');
   print_Debug('p_global_procurement_flag is ' || p_global_procurement_flag,  'GET_TRANSFER_PRICE');
   print_Debug('p_drop_ship_flag is ' || p_drop_ship_flag,  'GET_TRANSFER_PRICE');
   print_Debug('p_from_organization_id is ' || p_from_organization_id,  'GET_TRANSFER_PRICE');
   -- print_Debug('p_process_discrete_xfer_flag is ' || p_process_discrete_xfer_flag,  'GET_TRANSFER_PRICE'); /* INVCONV Bug 4750256 */
   print_Debug('p_order_line_id is ' || p_order_line_id,  'GET_TRANSFER_PRICE'); -- Bug 5171637/5138311 umoogala: INVCONV


   if( p_global_procurement_flag = 'Y' ) then
	l_flow_type := 2;
   else
	l_flow_type := 1;
   end if;

   print_debug('Calling get_inventory_org ', 'GET_TRANSFER_PRICE');
    /* Added if condition for bug 8282784
        OPM passes shipment date to p_txn_date, conversion rate (hence used in
        function convert_currency() below) should be the one applicable on
        shipment date , not as per sysdate.
    */
   if ( p_txn_date is not null and p_from_organization_id is not null ) then
        l_transaction_date := p_txn_date;
        l_organization_id  := p_from_organization_id;
   /* End of changes for bug 8282784 */

   elsif( p_from_organization_id is not null ) then
        l_organization_id := p_from_organization_id;
        l_transaction_date := sysdate;
   else

        l_organization_id := get_inventory_org(
           p_reference_id                  => p_transaction_id
         , p_global_procurement_flag       => p_global_procurement_flag
	 , p_drop_ship_flag		   => p_drop_ship_flag
         , x_transaction_date              => l_transaction_date
         , x_return_status                 => l_return_status
         , x_msg_data                      => l_msg_data
         , x_msg_count                     => l_msg_count
        );

        if( l_return_status <> G_RET_STS_SUCCESS ) then
           print_debug('Error from get_inventory_org', 'GET_TRANSFER_PRICE');
           raise FND_API.G_EXC_ERROR;
        end if;
   end if;

   print_debug('Inventory org is ' || l_organization_id, 'GET_TRANSFER_PRICE');

    l_progress := 1;
    print_debug('Check if the from OU is valid ', 'GET_TRANSFER_PRICE');

    select count(organization_id)
    into l_exists
    FROM HR_ORGANIZATION_INFORMATION HOI
    WHERE HOI.ORG_INFORMATION3 = to_char(p_from_org_id)
    AND HOI.ORGANIZATION_ID= l_organization_id
    AND HOI.ORG_INFORMATION_CONTEXT = 'Accounting Information';

    if(  l_exists = 0 ) then
        print_debug('FROM OU is invalid', 'GET_TRANSFER_PRICE');
        FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_FROM_OU');
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
          -- throw error invalid from operating unit
    end if;

    l_progress := 2;
    print_debug('Check if IC Relations exists between the From OU and TO OU', 'GET_TRANSFER_PRICE');

    BEGIN
         select 1
         into l_exists
         FROM mtl_intercompany_parameters
         where sell_organization_id = p_to_org_id
         AND ship_organization_id = p_from_org_id
         and flow_type = l_flow_type;
    EXCEPTION
	WHEN no_data_found then
        print_debug('No IC Relations exists between from OU and To OU', 'GET_TRANSFER_PRICE');
	select name
	INTO l_from_ou_name
	FROM hr_operating_units
	where organization_id = p_from_org_id;

	SELECT NAME
	INTO l_to_ou_name
	From HR_OPERATING_UNITS
	Where organization_id = p_to_org_id;

        FND_MESSAGE.SET_NAME('INV', 'IC-No INTERCO Relation');
	FND_MESSAGE.SET_TOKEN('FROM_OU', l_from_ou_name);
        FND_MESSAGE.SET_TOKEN('TO_OU', l_to_ou_name);
        FND_MSG_PUB.ADD;
        raise FND_API.G_EXC_ERROR;
          -- throw error invalid no intercompany parameters defined
    END;

      l_progress := 3;
      print_Debug('Get the base_item_id for the inventory_item_id ' || p_inventory_item_id, 'GET_TRANSFER_PRICE');
      BEGIN
          select nvl(base_item_id, 0)
          into l_base_item
          from mtl_system_items_b
          where inventory_item_id = p_inventory_item_id
          and organization_id =  l_organization_id;

      EXCEPTION
          when no_data_found then
                -- throw unexpected error;

               print_debug('Cannot find item ' || p_inventory_item_id, 'GET_TRANSFER_PRICE');
               FND_MESSAGE.SET_NAME('INV', 'INV_IC_INVALID_ITEM_ORG');
	       FND_MESSAGE.SET_TOKEN('ITEM', p_inventory_item_id);
	       FND_MESSAGE.SET_TOKEN('ORG', l_organization_id);
               FND_MSG_PUB.ADD;
               raise FND_API.G_EXC_ERROR;
      END;

      l_progress := 4;
      -- get price list id
      print_Debug('Get price list id ' , 'GET_TRANSFER_PRICE');
      BEGIN
         /* Modified query below : RA to HZ conversions
          Replaced occurances of RA views with HZ tables*/
        /* SELECT nvl(RSU.price_list_id, nvl(RC.price_list_id, -1)), RSU.location, RC.Customer_number, RC.Customer_name
        INTO   l_price_List_Id, l_location, l_customer_number, l_customer_name
        FROM   mtl_intercompany_parameters MIP
        ,      ra_site_uses_all RSU
        ,      ra_customers RC
        WHERE  MIP.sell_organization_id = p_to_org_id
        AND    MIP.ship_organization_id = p_from_org_id
	AND    MIP.flow_type = l_flow_type
        AND    RSU.site_use_id = MIP.customer_site_id
        AND    RSU.org_id = MIP.ship_organization_id
        AND    RC.customer_id = MIP.customer_id;
        */

         SELECT NVL(rsu.price_list_id, NVL(rc.price_list_id, -1))
              , rsu.LOCATION
              , rc.customer_number
              , rc.customer_name
INTO   l_price_List_Id, l_location, l_customer_number, l_customer_name
           FROM mtl_intercompany_parameters mip
              , hz_cust_site_uses_all rsu
              , (SELECT cust_account_id customer_id
                      , party.party_name customer_name
                      , party.party_number customer_number
                      , price_list_id
                   FROM hz_parties party, hz_cust_accounts cust_acct
                  WHERE cust_acct.party_id = party.party_id) rc
          WHERE mip.sell_organization_id = p_to_org_id
            AND mip.ship_organization_id = p_from_org_id
            AND mip.flow_type = l_flow_type
            AND rsu.site_use_id = mip.customer_site_id
            AND rsu.org_id = mip.ship_organization_id
            AND rc.customer_id = mip.customer_id;



        if( l_price_list_id = -1 ) then
		FND_MESSAGE.SET_NAME('INV', 'IC-Price List Not Found');
		FND_MESSAGE.SET_TOKEN('LOC', l_location);
		FND_MESSAGE.SET_TOKEN('CUST_NUM', l_customer_number);
		FND_MESSAGE.SET_TOKEN('CUST_NAME', l_customer_name);
		FND_MSG_PUB.ADD;
		raise FND_API.G_EXC_ERROR;
	end if;
      EXCEPTION
        when no_data_found then
           print_debug('no price list found ', 'GET_TRANSFER_PRICE');
	   SELECT name
	   into l_from_ou_name
	   FROM hr_operating_units
	   WHERE organization_id = p_from_org_id;

           FND_MESSAGE.SET_NAME('INV', 'IC-Invalid Customer');
	   FND_MESSAGE.SET_TOKEN('OU', l_from_ou_name);
           FND_MSG_PUB.ADD;
           raise FND_API.G_EXC_ERROR;
      END;

      -- call get_transfer_price_for_item for the base item
      if( l_base_item <> 0 ) then
	  l_cto_item_flag := 'Y';
      else
	  l_cto_item_flag := 'N';
      end if;

      print_debug('Calling get_transfer_price_for_item', 'GET_TRANSFER_PRICE');
       get_transfer_price_for_item (
          x_return_Status       => x_return_status
        , x_msg_data            => x_msg_data
        , x_msg_count           => x_msg_count
        , x_transfer_price      => l_inv_transfer_price
        , x_currency_code       => l_inv_currency_code
        , p_api_version         => 1.0
        , p_init_msg_list       => 'F'
        , p_from_org_id         => p_from_org_id
        , p_to_org_id           => p_to_org_id
        , p_transaction_uom     => p_transaction_uom
        , p_inventory_item_id   => p_inventory_item_id
        , p_transaction_id      => p_transaction_id
	, p_from_organization_id => l_organization_id
        , p_price_list_id       => l_price_list_id
        , p_global_procurement_flag => p_global_procurement_flag
	, p_drop_ship_flag	=> p_drop_ship_flag
	, p_cto_item_flag 	=> l_cto_item_flag
        -- , p_process_discrete_xfer_flag => p_process_discrete_xfer_flag  /* INVCONV Bug 4750256 */
        , p_order_line_id       => p_order_line_id   -- Bug 5171637/5138311 umoogala:
                                                     -- replaced above line with this one.
       );

       if( l_cto_item_flag = 'N' AND  x_return_status <> G_RET_STS_SUCCESS ) then
          print_debug('Error from get_transfer_price_for_item', 'GET_TRANSFER_PRICE');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

       /* Added following logic for ISO with confgiured items calling of the CTO roll-up price API
          only when the price is not associated with the configured item */
       BEGIN
          SELECT transaction_source_type_id into l_trx_src_type_id
          FROM   mtl_material_transactions
          WHERE  transaction_id = p_transaction_id;
          if ( l_trx_src_type_id = 8 ) AND ( l_base_item <> 0 ) AND ( nvl(l_inv_transfer_price,0) <> 0 )
             AND ( l_inv_currency_code is not null ) then
              l_transfer_price := l_inv_transfer_price;
          end if;
       EXCEPTION WHEN OTHERS THEN
          l_trx_src_type_id := NULL;
       END;
       /* End for ISO with confgiured items changes */

        print_debug('l_transfer_price = ' || l_inv_transfer_price, 'GET_TRANSFER_PRICE');
        print_Debug('l_currency_code = ' || l_inv_currency_code, 'GET_TRANSFER_PRICE');
	print_debug('l_base_item = ' || l_base_item, 'GET_TRANSFER_PRICE');

       -- Bug 4366773: In the IF condition modified the variable from l_transfer_price to l_inv_transfer_price

       --
       -- Bug 5527437 umoogala:
       -- Added '= -99' condition to the following IF condition.
       --
       if( (l_inv_transfer_price IS NULL OR l_inv_transfer_price = -99) AND l_base_item <> 0 ) then
        -- call CTO API to get the transfer price
           --null;
	   --
	   -- Bug 5527437 umoogala: added following IF block
	   --
	   l_inv_transfer_price := 0;
	   IF G_ORDER_LINE_ID = -1 OR G_ORDER_LINE_ID <> p_order_line_id
	   THEN
	     G_ORDER_LINE_ID := p_order_line_id;
	   END IF;

           print_debug('Calling CTO API to get the transfer price' , 'GET_TRANSFER_PRICE');
	   print_debug('G_ORDER_LINE_ID'||G_ORDER_LINE_ID , 'GET_TRANSFER_PRICE');
           CTO_TRANSFER_PRICE_PK.CTO_TRANSFER_PRICE(
                p_config_item_id           => p_inventory_item_id
              , p_selling_oper_unit     => p_to_org_id
              , p_shipping_oper_unit    => p_from_org_id
              , p_transaction_uom       => p_transaction_uom
              , p_transaction_id        => p_transaction_id
              , p_price_list_id         => l_price_list_id
	      , p_from_organization_id  => l_organization_id
              , p_global_procurement_flag => p_global_procurement_flag
              , x_transfer_price        => l_inv_transfer_price
              , x_currency_code         => l_inv_currency_code
              , x_return_status         => l_return_status
              , x_msg_count             => l_msg_count
              , x_msg_data              => l_msg_data
           );

           if( l_return_status <> G_RET_STS_SUCCESS ) then
                print_debug('Error from CTO_Transfer_price', 'GET_TRANSFER_PRICE');
                raise FND_API.G_EXC_ERROR;
           end if;
	   print_debug('l_transfer_price from CTO is ' || l_inv_transfer_price, 'GET_TRANSFER_PRICE');
       end if;

        l_transfer_price := convert_currency(
          p_org_id              => p_from_org_id
        , p_transfer_price      => l_inv_transfer_price
        , p_currency_code       => l_inv_currency_code
        , p_transaction_date    => l_transaction_date
        , p_logical_txn         => 'Y'     /* bug 6696446 */
        , x_functional_currency_code => l_functional_currency_code
        , x_return_status       => l_return_status
        , x_msg_data            => x_msg_data
        , x_msg_count           => x_msg_count
        );

        if( l_return_status <> G_RET_STS_SUCCESS ) then
            print_debug('Error from convert_currency', 'get_transfer_price_for_item');
            raise FND_API.G_EXC_ERROR;
        end if;
        print_Debug('l_transfer_price = ' || l_transfer_price, 'get_transfer_price');
        print_Debug('x_currency_code = ' || l_functional_currency_code, 'get_transfer_price');

       x_transfer_price := l_transfer_price;
       x_currency_code := l_functional_currency_code;
       x_incr_transfer_price := l_inv_transfer_price;
       x_incr_currency_code := l_inv_currency_code;
       x_return_status := G_RET_STS_SUCCESS;
       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := G_RET_STS_UNEXP_ERROR;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
         print_debug('In Exc_Unexpected_Error ' || l_progress, 'Get_Transfer_price');
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	 print_debug('In EXC_ERROR ' || l_progress, 'Get_Transfer_Price');
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);


      WHEN OTHERS then
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
         x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, l_api_name);
         end if;

	 print_debug('in When Others, l_progress = ' || l_progress, 'Get_Transfer_price');

END get_transfer_price;

/*==========================================================================================================
 * Function: GET_TRANSFER_PRICE_DATE();
 *
 * Description: This function is to get the date by which the transfer price for the item will be queried from Transfer Price List
 *                        This function retrieve the date according to value of profile "INV: Intercompany Transfer Price Date".
 *	                   i) Profile set to 'ORDER DATE'
 *	                        a) Shipping flow-  function returns order line pricing date
 *	                        b) Procurement flow-  function returns Purchase Order Approved date.
 *                         ii) Profile set to 'CURRENT DATE', function returns sysdate
 *
 * Input Parameters:
 *      1. p_call                         -  Determines from where this function is called
 *                                                  I - Called from internal procedure or function of INV_TRANSACTION_FLOW_PUB
 *                                                  E - Called from any external procedure or function
 *	2. p_order_line_id 	 -  SO line id for Shipping flow and PO line id for purchasing flow
 *     3. p_global_procurement_flag
 *	4. p_transaction_id      -  This is not required when called from external procedure/function
 *	5. p_drop_ship_flag     - default is N
 *
 * Output Parameter:
 *	1. x_return_status - return status
 *	2. x_msg_data	- error message
 *	3. x_msg_count - number of message in the message stack
 *
 *   It returns a date value
 * Note -   Function is added as a part of changes done in bug#6700919
 *==========================================================================================================*/
FUNCTION get_transfer_price_date(
   p_call                                         IN VARCHAR2
 , p_order_line_id                       IN NUMBER
 , p_global_procurement_flag IN VARCHAR2
 , p_transaction_id                     IN NUMBER  DEFAULT NULL
 , p_drop_ship_flag	               IN VARCHAR2 DEFAULT 'N'
 , x_return_status                       OUT NOCOPY VARCHAR2
 , x_msg_data                             OUT NOCOPY VARCHAR2
 , x_msg_count                           OUT NOCOPY NUMBER
) RETURN DATE
IS
  l_trf_date_profile NUMBER:= nvl(fnd_profile.value('INV_INTERCOMPANY_TRANSFER_PRICE_DATE'), 1);
  l_trf_price_date   DATE;
  l_doc_type            VARCHAR2(4);
  l_whse_code       VARCHAR2(4);
  l_line_id                NUMBER;
BEGIN
   print_debug('Inside get_transfer_price_date', 'GET_TRANSFER_PRICE_DATE');
   print_Debug('p_call = ' || p_call, 'get_transfer_price_date');
   print_Debug('p_order_line_id = ' || p_order_line_id, 'GET_TRANSFER_PRICE_DATE');
   print_Debug('p_global_procurement_flag = ' || p_global_procurement_flag, 'GET_TRANSFER_PRICE_DATE');
   print_Debug('p_transaction_id = ' || p_transaction_id, 'GET_TRANSFER_PRICE_DATE');
   print_Debug('p_drop_ship_flag = ' || p_drop_ship_flag, 'GET_TRANSFER_PRICE_DATE');


   if l_trf_date_profile <>1 then -- for profile value =ORDER DATE
      print_debug('INV: Intercompany Transfer Price Date -ORDER DATE', 'GET_TRANSFER_PRICE_DATE');
      if (p_call <> 'I') then
         if( p_global_procurement_flag = 'N' ) then
	    print_debug('Inside p_global_procurement_flag = N', 'GET_TRANSFER_PRICE_DATE');
            begin
     	    select oel.pricing_date
	    into  l_trf_price_date
	    from oe_order_lines_all oel
	    where oel.line_id = p_order_line_id;
            exception
            when no_data_found then
               FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SALES_ORDER');
	       FND_MESSAGE.SET_TOKEN('LINE', p_order_line_id);
               FND_MSG_PUB.ADD;
               raise FND_API.G_EXC_ERROR;
            end;
         else
	   -- this is global procurement flow.
            print_debug('Inside p_global_procurement_flag =Y', 'GET_TRANSFER_PRICE_DATE');
            begin
	    select poh.approved_date
	    into l_trf_price_date
	    from po_headers_all poh, po_lines_all pol
	    where poh.po_header_id = pol.po_header_id
	    and pol.po_line_id = p_order_line_id;
            exception
            when no_data_found then
               FND_MESSAGE.SET_NAME('INV', 'INV_INT_PO');
               FND_MSG_PUB.ADD;
               raise FND_API.G_EXC_ERROR;
            end;
         end if;  --p_global_procurement_flag = 'N'
      else
         if ( GML_PROCESS_FLAGS.process_orgn = 1 AND GML_PROCESS_FLAGS.opmitem_flag = 1 ) then
	 --OPM Flow
            print_debug('Inside OPM Flow', 'GET_TRANSFER_PRICE_DATE');
            select doc_type, line_id, whse_code
            into   l_doc_type, l_line_id, l_whse_code
            from   ic_tran_pnd
            where  trans_id = p_transaction_id;
	    if l_doc_type = 'OMSO' then
	       begin
               select oel.pricing_date
               into  l_trf_price_date
               from   ic_whse_mst WHS
                           , oe_order_lines_all OEL
               where  OEL.line_id = l_line_id
               and WHS.whse_code = l_whse_code;
               exception
               when no_data_found then
                  FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SALES_ORDER');
	          FND_MESSAGE.SET_TOKEN('ID', l_line_id);
                  FND_MSG_PUB.ADD;
                  raise FND_API.G_EXC_ERROR;
	       end;
            elsif l_doc_type = 'PORC' THEN
	       begin
               select oel.pricing_date
               into   l_trf_price_date
               from   ic_whse_mst WHS
                          , oe_order_lines_all OEL
                          , rcv_transactions RCT
		          , po_requisition_lines_all pol
               where  pol.requisition_line_id = oel.orig_sys_document_Ref
	       and  oel.order_source_id = 10
               and RCT.transaction_id = l_line_id
	       and RCT.requisition_line_id = pol.requisition_line_id
               and WHS.whse_code = l_whse_code;
               exception
               when no_data_found then
                  FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_RCV_TRANSACTION');
	          FND_MESSAGE.SET_TOKEN('RCVID', l_line_id);
                  FND_MSG_PUB.ADD;
                  raise FND_API.G_EXC_ERROR;
               end;
            end if;
         else
            if( p_global_procurement_flag = 'N' ) then
	    -- this means this is not a global procurement
	    -- we need to check if this is a drop ship with procuring flow
	       print_debug('Inside p_global_procurement_flag = N', 'GET_TRANSFER_PRICE_DATE');
	       if( p_drop_ship_flag = 'N') then
                  begin
     	          select oel.pricing_date
	          into  l_trf_price_date
	          from oe_order_lines_all oel
	          where oel.line_id = p_order_line_id;
                  exception
                  when no_data_found then
                     FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SALES_ORDER');
	             FND_MESSAGE.SET_TOKEN('ID', p_order_line_id);
                     FND_MSG_PUB.ADD;
                     raise FND_API.G_EXC_ERROR;
                  end;
	       else
	        -- this is a true drop ship with procuring flow
                  BEGIN
                  select oel.pricing_date
                  INTO  l_trf_price_date
                  FROM oe_order_lines_all oel
                  where oel.line_id = p_transaction_id;
                  EXCEPTION
                  WHEN NO_DATA_FOUND then
                     FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_SALES_ORDER');
		     FND_MESSAGE.SET_TOKEN('LINE', p_transaction_id);
                     FND_MSG_PUB.ADD;
                     raise FND_API.G_EXC_ERROR;
                  END;
	       end if; --if( p_drop_ship_flag = 'N')
            else
	    -- this is global procurement flow.
               print_debug('Inside p_global_procurement_flag =Y', 'GET_TRANSFER_PRICE_DATE');
               begin
               SELECT  poh.approved_date
               into  l_trf_price_date
               FROM rcv_transactions rcv, po_headers_all poh
               WHERE rcv.transaction_id = p_transaction_id
               AND rcv.po_header_id = poh.po_header_id;
               exception
               when no_data_found then
                  FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_RCV_TRANSACTION');
	          FND_MESSAGE.SET_TOKEN('RCVID', p_transaction_id);
                  FND_MSG_PUB.ADD;
                  raise FND_API.G_EXC_ERROR;
               end;
            end if; --if( p_global_procurement_flag = 'N' )
         end if;  --if ( GML_PROCESS_FLAGS.process_orgn = 1
      end if;  -- p_call <> 'I'
   else -- for profile value =CURRENT DATE
      print_debug('INV: Intercompany Transfer Price Date -CURRENT DATE', 'GET_TRANSFER_PRICE_DATE');
      l_trf_price_date := sysdate;
   end if; --if l_trf_date_profile <>1

   if l_trf_price_date is null then
      print_debug('Error: l_trf_price_date is null' , 'GET_TRANSFER_PRICE_DATE');
      raise FND_API.G_EXC_ERROR;
   end if;

   x_return_status := G_RET_STS_SUCCESS;
   /* Added trunc() function for bug 8796195 */
   return trunc(l_trf_price_date);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR then
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);
   WHEN OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
      x_msg_data := fnd_msg_pub.get(p_msg_index => x_msg_count, p_encoded => fnd_api.g_false);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     FND_MSG_PUB.Add_Exc_Msg(G_PACKAGE_NAME, 'GET_TRANSFER_PRICE_DATE');
      end if;
END get_transfer_price_date;

END INV_TRANSACTION_FLOW_PUB;

/
