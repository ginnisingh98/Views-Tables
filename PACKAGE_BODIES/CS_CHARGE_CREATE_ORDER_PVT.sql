--------------------------------------------------------
--  DDL for Package Body CS_CHARGE_CREATE_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHARGE_CREATE_ORDER_PVT" as
/* $Header: csxvchob.pls 120.28.12010000.15 2010/04/03 18:33:33 rgandhi ship $ */

/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_Charge_Create_Order_PVT' ;


/**************************************************************
    --
    --Private global variables and functions
    --
*************************************************************/

G_MAXERRPARMLEN constant number := 200;
G_MAXERRLEN constant number := 512;
g_oraerrmsg varchar2(600);
j  number := 1;


procedure get_who_info
(
    p_login_id  out NOCOPY number,
    p_user_id   out NOCOPY number
) is
begin
    p_login_id := FND_GLOBAL.Login_Id;
    p_user_id  := FND_GLOBAL.User_Id;

end get_who_info;


procedure Get_acct_from_party_site
(
    p_party_site_id             in  number,
    p_sold_to_customer_party    in  number,
    p_sold_to_customer_account  in  number,
    p_org_id                    in  number DEFAULT -1,--bug# 4870037
    p_site_use_flag             in  VARCHAR2 DEFAULT 'E',--bug# 4870037
    p_site_use_code	        in  varchar2,
    x_account_id                out NOCOPY number
) is

-- Bug 6655006
Cursor active_accts(p_party_id number) is
SELECT CUST_ACCOUNT_ID
FROM HZ_CUST_ACCOUNTS_ALL
WHERE PARTY_ID = p_party_id
AND STATUS = 'A';

Cursor acct_site_csr(p_org_id number, p_party_site_id number, p_account_id number) IS
    SELECT cust_acct_site_id
    FROM   hz_cust_acct_sites_all
    WHERE  cust_account_id = p_account_id and
           party_site_id = p_party_site_id and
           org_id = p_org_id and
           status = 'A';

Cursor acct_site_use_csr(p_cust_acct_site_id number, p_site_use_code varchar2) IS
    SELECT site_use_id
    FROM   hz_cust_site_uses_all
    WHERE  cust_acct_site_id = p_cust_acct_site_id and
           site_use_code = p_site_use_code and
           status = 'A';

Cursor get_address is
    SELECT b.address1
    FROM   hz_party_sites a, hz_locations b
    WHERE  a.location_id = b.location_id
    AND    a.party_site_id = p_party_site_id;

Cursor get_inv_org_name is
SELECT org.organization_name
FROM   org_organization_definitions org
WHERE  org.organization_id = p_org_id;

l_party_id  number := null;
l_cust_acct_site_use   varchar2(1) := 'N';
l_site_use_id  NUMBER;
l_bill_ship_addr varchar2(300);
l_inv_org_name varchar2(300);

BEGIN

    IF p_party_site_id  IS NULL THEN
        x_account_id := FND_API.G_MISS_NUM;
    ELSE
        SELECT party_id
        INTO   l_party_id
        FROM   HZ_PARTY_SITES
        WHERE  party_site_id = p_party_site_id;

        IF l_party_id = p_sold_to_customer_party THEN
            IF p_sold_to_customer_account is not null then
                x_account_id := p_sold_to_customer_account;
            ELSE
                x_account_id := FND_API.G_MISS_NUM;
            END IF;
        ELSIF l_party_id <> p_sold_to_customer_party THEN
            BEGIN

   /*             SELECT min(CUST_ACCOUNT_ID)
                INTO x_account_id
                FROM HZ_CUST_ACCOUNTS_ALL
                WHERE PARTY_ID = l_party_id
                AND STATUS = 'A'
                AND CUST_ACCOUNT_ID is not null;*/
/*
--Begin : Bug# 4870037
            IF p_site_use_flag = 'B' THEN
                SELECT min(CUST_ACCOUNT_ID)
                INTO x_account_id
                FROM HZ_CUST_ACCOUNTS_ALL h1
                WHERE h1.PARTY_ID = l_party_id
                AND h1.STATUS = 'A'
                AND h1.CUST_ACCOUNT_ID is not null
                AND EXISTS (SELECT '1' FROM hz_cust_acct_sites_all h2
                            WHERE h2.party_site_id = p_party_site_id
                              AND h2.CUST_ACCOUNT_ID = h1.CUST_ACCOUNT_ID
                              AND h2.STATUS = 'A'
                              AND h2.ORG_ID = p_org_id
                              AND h2.BILL_TO_FLAG = 'Y');
            ELSIF p_site_use_flag = 'S' THEN
                SELECT min(CUST_ACCOUNT_ID)
                INTO x_account_id
                FROM HZ_CUST_ACCOUNTS_ALL h1
                WHERE h1.PARTY_ID = l_party_id
                AND h1.STATUS = 'A'
                AND h1.CUST_ACCOUNT_ID is not null
                AND EXISTS (SELECT '1' FROM hz_cust_acct_sites_all h2
                            WHERE h2.party_site_id = p_party_site_id
                              AND h2.CUST_ACCOUNT_ID = h1.CUST_ACCOUNT_ID
                              AND h2.STATUS = 'A'
                              AND h2.ORG_ID = p_org_id
                              AND h2.SHIP_TO_FLAG = 'Y');
            END IF;
            --End : Bug# 4870037
*/
/* Commented the above fix using the minimum logic and the following new logic would loop till it finds an account with
   valid account site and usage */

                For i in active_accts(l_party_id) loop
		  x_account_id := i.cust_account_id;
		  For j in acct_site_csr(p_org_id, p_party_site_id, i.cust_account_id) loop

		    Open acct_site_use_csr(j.cust_acct_site_id, p_site_use_code);
		    fetch acct_site_use_csr into l_site_use_id;
		    IF acct_site_use_csr%FOUND THEN
		       l_cust_acct_site_use := 'Y';
		       Exit;
		    END IF;
		    Close acct_site_use_csr;

		  End loop;
		  If nvl(l_cust_acct_site_use,'N') = 'Y' then
		    exit;
		  End if;
		End loop;

		If nvl(l_cust_acct_site_use,'N') = 'N' then
		  If fnd_profile.value('CS_SR_ACTION_MISS_ACCT') = 'CHG_ABORT_SUB' Then
		    Open  get_address;
		    Fetch get_address into l_bill_ship_addr;
		    Close get_address;

		    Open get_inv_org_name;
		    Fetch get_inv_org_name into l_inv_org_name;
		    Close get_inv_org_name;

		    FND_MESSAGE.Set_Name('CS','CS_SR_NO_VALID_ACCT_SITE_USE');
		    FND_MESSAGE.Set_Token('BILL_SHIP_ADDR',l_bill_ship_addr);
		    FND_MESSAGE.Set_Token('OPER_UNIT',l_inv_org_name);
		    FND_MSG_PUB.Add;
		    RAISE FND_API.G_EXC_ERROR;
		  End if;
		End if;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_account_id := FND_API.G_MISS_NUM;
            END;

            IF x_account_id is null THEN
                x_account_id := FND_API.G_MISS_NUM;
            END IF;
        END IF;
    END IF;
END Get_acct_from_party_site;



PROCEDURE validate_acct_site_uses
(
  p_org_id              IN  number,
  p_party_site_id       IN  number,
  p_account_id          IN  number,
  p_site_use_code       IN  varchar2,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2
  ) IS

  Cursor acct_site_csr(p_org_id number, p_party_site_id number, p_account_id number, p_status varchar2) IS
    SELECT cust_acct_site_id
    FROM   hz_cust_acct_sites_all
    WHERE  cust_account_id = p_account_id and
           party_site_id = p_party_site_id and
           org_id = p_org_id and
           status = p_status;

  Cursor acct_site_use_csr(p_cust_acct_site_id number, p_site_use_code varchar2, p_status varchar2) IS
    SELECT site_use_id
    FROM   hz_cust_site_uses_all
    WHERE  cust_acct_site_id = p_cust_acct_site_id and
           site_use_code = p_site_use_code and
           status = p_status;

  Cursor get_address is
    SELECT b.address1
    FROM   hz_party_sites a, hz_locations b
    WHERE  a.location_id = b.location_id
    AND    a.party_site_id = p_party_site_id;

  Cursor get_inv_org_name is
    SELECT org.organization_name
    FROM   org_organization_definitions org
    WHERE  org.organization_id = p_org_id;

  l_cust_acct_site_id   number := null;
  l_site_use_id         number := null;
  l_bill_ship_addr varchar2(300);
  l_inv_org_name varchar2(300);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_org_id is not null and
     p_party_site_id is not null and
     p_account_id is not null THEN

    Open  get_address;
    Fetch get_address into l_bill_ship_addr;
    Close get_address;

    Open get_inv_org_name;
    Fetch get_inv_org_name into l_inv_org_name;
    Close get_inv_org_name;

    -- Check if an active customer account site exists.
    open acct_site_csr(p_org_id, p_party_site_id, p_account_id, 'A');
    fetch acct_site_csr into l_cust_acct_site_id;
    IF acct_site_csr%NOTFOUND THEN
      close acct_site_csr;
      -- Check if an inactive customer account site exists.
      open acct_site_csr(p_org_id, p_party_site_id, p_account_id, 'I');
      fetch acct_site_csr into l_cust_acct_site_id;
      IF acct_site_csr%NOTFOUND THEN
        close acct_site_csr;
	--srini
	If fnd_profile.value('CS_SR_ACTION_MISS_ACCT') = 'CHG_ABORT_SUB' Then
	  FND_MESSAGE.Set_Name('CS','CS_SR_NO_VALID_ACCT_SITE_USE');
	  FND_MESSAGE.Set_Token('BILL_SHIP_ADDR',l_bill_ship_addr);
	  FND_MESSAGE.Set_Token('OPER_UNIT',l_inv_org_name);
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
        End if;
      ELSE
        close acct_site_csr;
        -- Raise error if active customer account site doesn't exist but an inactive
        -- custoemr account site exist.  Charges will raise a clear error message instead of
        -- passing this data to OC.
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_CUST_ACCT_SITE');
        FND_MESSAGE.SET_TOKEN('ACCT_SITE_ID', l_cust_acct_site_id);
        FND_MESSAGE.SET_TOKEN('PARTY_SITE_ID', p_party_site_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      close acct_site_csr;

      -- Check if an active account site use exists.
      IF p_site_use_code is not null THEN

        open acct_site_use_csr(l_cust_acct_site_id, p_site_use_code, 'A');
        fetch acct_site_use_csr into l_site_use_id;
        IF acct_site_use_csr%NOTFOUND THEN
          close acct_site_use_csr;

          -- Check if an inactive account site use exists.
          open acct_site_use_csr(l_cust_acct_site_id, p_site_use_code, 'I');
          fetch acct_site_use_csr into l_site_use_id;
          IF acct_site_use_csr%NOTFOUND THEN
            close acct_site_use_csr;
--srini
	    If fnd_profile.value('CS_SR_ACTION_MISS_ACCT') = 'CHG_ABORT_SUB' Then
	      FND_MESSAGE.Set_Name('CS','CS_SR_NO_VALID_ACCT_SITE_USE');
	      FND_MESSAGE.Set_Token('BILL_SHIP_ADDR',l_bill_ship_addr);
	      FND_MESSAGE.Set_Token('OPER_UNIT',l_inv_org_name);
	      FND_MSG_PUB.Add;
	      RAISE FND_API.G_EXC_ERROR;
	    End if;
          ELSE
            close acct_site_use_csr;
            -- Raise error if active bill to or ship to account site use doesn't exist but an
            -- inactive bill to or ship to account site use exist.  Charges will raise a clear
            -- error message instead of passing this data to OC.
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_ACCT_SITE_USE');
            FND_MESSAGE.SET_TOKEN('SITE_USE_CODE', p_site_use_code);
            FND_MESSAGE.SET_TOKEN('ACCT_SITE_USE_ID', l_site_use_id);
            FND_MESSAGE.SET_TOKEN('ACCT_SITE_ID', l_cust_acct_site_id);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          close acct_site_use_csr;
        END IF;

      END IF;
    END IF;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get
        (p_count     =>      x_msg_count,
         p_data      =>      x_msg_data);


    WHEN OTHERS THEN
	  g_oraerrmsg := substrb(sqlerrm,1,G_MAXERRLEN);
	  fnd_message.set_name('CS','CS_CHG_SUBMIT_ORDER_FAILED');
	  fnd_message.set_token('ROUTINE','CS_Charge_Create_Order_PKG.Submit_Order');
	  fnd_message.set_token('REASON',g_oraerrmsg);
	  app_exception.raise_exception;

END validate_acct_site_uses;
--
-- Changes for 11.5.10
-- procedure to update charges schema with error messages.
--
Procedure Update_Errors (p_estimate_detail_id  IN  NUMBER,
                         p_line_submitted      IN  VARCHAR2,
                         p_submit_restriction_message  IN  VARCHAR2,
                         p_submit_error_message        IN  VARCHAR2,
                         p_submit_from_system          IN  VARCHAR2
                         ) IS

            pragma AUTONOMOUS_TRANSACTION;

            -- DEADLOCK_DETECTED EXCEPTION ;
	    -- PRAGMA EXCEPTION_INIT(DEADLOCK_DETECTED,-60);

            BEGIN

		--  Standard Start of API Savepoint
    		-- SAVEPOINT  Update_Errors;

             IF p_estimate_detail_id IS NOT NULL THEN
                UPDATE CS_ESTIMATE_DETAILS
                  SET line_submitted  = p_line_submitted,
                      submit_restriction_message = p_submit_restriction_message,
                      submit_error_message = p_submit_error_message,
                      submit_from_system = p_submit_from_system,
		      last_update_date = sysdate, -- bug 8838622
	              last_update_login = fnd_global.login_id, -- bug 8838622
		      last_updated_by = fnd_global.user_id -- bug 8838622
                 WHERE Estimate_Detail_Id = p_estimate_detail_id;

             -- dbms_output.put_line('submit_error_message' || substr(p_submit_error_message,1,100));


            END IF;

            commit;
            -- dbms_output.put_line('In the Update_Errors');

            EXCEPTION
                  -- WHEN DEADLOCK_DETECTED THEN
                  -- dbms_output.put_line('dead lock detected');
                  -- ROLLBACK;
		  -- NULL;

		  WHEN OTHERS THEN
		  ROLLBACK;
                  FND_MESSAGE.SET_NAME('CS', 'CS_DB_ERROR');
                  FND_MESSAGE.SET_TOKEN(token => 'PROG_NAME', value => 'Cs_Charge_Create_Order_PVT.Update_Errors');
                  FND_MESSAGE.SET_TOKEN(token => 'SQLCODE', value => SQLCODE);
                  FND_MESSAGE.SET_TOKEN(token => 'SQLERRM', value => SQLERRM);
                  FND_MSG_PUB.add;

       END Update_Errors;
 --
 -- End of Update_Errors
 --
 --
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Order
--   Type    :  Public
--   Purpose :  This API is for submitting an order.
--              It is intended for use by the owning module only; contrast to published API.
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version           IN      NUMBER     Required
--       p_init_msg_list         IN      VARCHAR2   Optional
--       p_commit                IN      VARCHAR2   Optional
--       p_validation_level      IN      NUMBER     Optional
--       p_incident_id           IN      NUMBER     Required
--       p_party_id              IN      NUMBER     Required
--       p_account_id            IN      NUMBER     Optional see bug#2447927,
--                                                            changed p_account_id to optional param.
--       p_book_order_flag       IN      VARCHAR2   Optional
--       p_submit_source	     IN	     VARCHAR2   Optional
--       p_submit_from_system    IN      VARCHAR2   Optional
--       p_book_order_flag       IN      VARCHAR2   Optional
--   OUT:
--       x_return_status         OUT    NOCOPY     VARCHAR2
--       x_msg_count             OUT    NOCOPY     NUMBER
--       x_msg_data              OUT    NOCOPY     VARCHAR2

--   SSHILPAM    11-Feb-2010      Bug 9312433: CSI api should be called when no instance number is present also
--   Version : Current version 1.0
--   End of Comments
--
PROCEDURE Submit_Order(
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2,
    p_commit                IN      VARCHAR2,
    p_validation_level      IN      NUMBER,
    p_incident_id           IN      NUMBER,
    p_party_id              IN      NUMBER,
    p_account_id            IN      NUMBER,
    p_book_order_flag       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_submit_source	        IN	    VARCHAR2 := FND_API.G_MISS_CHAR,
    p_submit_from_system    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
)
IS
    l_api_name                  CONSTANT  VARCHAR2(30) := 'Submit_Order' ;
    l_api_name_full             CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
    l_log_module  CONSTANT VARCHAR2(255)  := 'cs.plsql.' || l_api_name_full || '.';
    l_api_version               CONSTANT  NUMBER       := 1.0 ;

--    l_debug     number      :=  ASO_DEBUG_PUB.G_DEBUG_LEVEL ;

    l_billing_flag              VARCHAR2(30) ;
    l_inv_item_id               NUMBER ;
    l_unit_code                 VARCHAR2(3) ;

    l_header_rec                ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_header_rec_default        ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    l_line_tbl                  ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_Line_dtl_tbl              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    l_hd_shipment_tbl           ASO_QUOTE_PUB.Shipment_tbl_Type;
    l_ln_shipment_tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type;
    l_hd_payment_tbl            ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_ln_payment_tbl            ASO_QUOTE_PUB.Payment_Tbl_Type; /* Credit Card 9358401 */
    l_lot_serial_tbl            ASO_ORDER_INT.Lot_Serial_Tbl_Type;
    l_line_price_adj_tbl        ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    l_charges_rec_type          CS_Charge_Details_PUB.Charges_Rec_Type;

    i                           NUMBER:=0;
    k                           NUMBER:=0;
    lx_return_status            VARCHAR2(1);
    lx_msg_count                NUMBER;
    lx_msg_data                 VARCHAR2(2000);
    l_workflow_process_id       NUMBER;

--  x_return_status             VARCHAR2(1);
--  x_msg_count                 NUMBER;
--  x_msg_data                  VARCHAR2(2000);
    oe_x_msg_count              NUMBER;
    oe_x_msg_data               VARCHAR2(2000);

    x_order_header_rec          ASO_ORDER_INT.Order_Header_rec_type;
    x_order_line_tbl            ASO_ORDER_INT.Order_Line_tbl_type;
    x_order_header_id           NUMBER;
    l_unit_selling_price        NUMBER;
    l_profile_option            VARCHAR2(33) ;
    l_control_rec               ASO_ORDER_INT.control_rec_type;
    l_login_id                  number;
    l_user_id                   number;
    l_ordered_quantity          number;
    l_ship_ordered_quantity     number;
    l_inv_org_id                number;
    l_record_found              VARCHAR2(1) := 'N';
    l_ship_to_cust_account_id   number;
    l_invoice_to_cust_account_id    number;
    l_ib_lot_number           VARCHAR2(30); -- Bug 8284773

    -- Fix for bug:3509921
    l_incident_number			NUMBER;
    Resource_Busy               EXCEPTION; --7117301
    PRAGMA EXCEPTION_INIT(Resource_Busy, -00054); --7117301

--  Following cursor fetches charge lines that are not submitted to
--  order management as orders or returns.

    CURSOR Fetch_Est_Dtl(p_incident_id NUMBER,p_inv_org_id NUMBER,p_ctrl_submit_source VARCHAR2,
                         p_ctrl_orig_source VARCHAR2,p_ctrl_source VARCHAR2) IS
    SELECT  edt.incident_id,
            edt.org_id,
            edt.estimate_detail_id,
            edt.currency_code,
            edt.conversion_type_code,
            edt.conversion_rate,
            edt.conversion_rate_date,
            edt.business_process_id,
            edt.txn_billing_type_id,
            edt.price_list_header_id,
            edt.inventory_item_id,
            edt.item_revision,
            edt.unit_of_measure_code,
            edt.quantity_required,
            edt.selling_price,
            edt.after_warranty_cost,
            edt.invoice_to_org_id,
            edt.ship_to_org_id,
            edt.customer_product_id,
            edt.installed_cp_return_by_date,
            edt.new_cp_return_by_date, -- Bug 4586140
            edt.add_to_order_flag,
            edt.order_header_id,
            edt.rollup_flag,
            edt.purchase_order_num,
            edt.return_reason_code,
            edt.serial_number return_serial_number,
            tt.LINE_ORDER_CATEGORY_CODE line_category_code,
            edt.organization_id,
            edt.transaction_inventory_org,
            edt.invoice_to_account_id,
            edt.ship_to_account_id,
            edt.ship_to_contact_id,
            edt.bill_to_contact_id,
            edt.bill_to_party_id,
            edt.ship_to_party_id,
            tb.order_type_id,
            tb.line_type_id,
            i.comms_nl_trackable_flag,
            sr.customer_id,
            sr.account_id,
            sr.incident_number,
            tbt.billing_type,
            cbtc.rollup_item_id,
            cbtc.billing_category,
            edt.list_price , -- 4870210
	    i.item_type item_type_code, --6523849
            /* Credit Card 9358401 */
            edt.instrument_payment_use_id
    FROM    CS_ESTIMATE_DETAILS      edt,
            CS_TXN_BILLING_OETXN_ALL tb,
            CS_TXN_BILLING_TYPES     tbt,
            MTL_SYSTEM_ITEMS_KFV     i,
            CS_INCIDENTS_ALL_B       sr,
            CS_TRANSACTION_TYPES_B   tt,
            cs_billing_type_categories cbtc
    WHERE   edt.incident_id          =  p_incident_id AND
            edt.interface_to_oe_flag = 'Y'   AND
            edt.order_line_id        IS NULL AND
            edt.charge_line_type     = 'ACTUAL' AND
            edt.txn_billing_type_id  = tb.txn_billing_type_id(+) AND
            --edt.org_id               = tb.org_id (+) AND
            nvl(edt.org_id, '-999')  = nvl(tb.org_id, '-999') AND
            edt.inventory_item_id    = i.inventory_item_id AND
            nvl(i.organization_id,-999) = nvl(p_inv_org_id,-999) AND
            edt.incident_id          = sr.incident_id      AND
            edt.txn_billing_type_id  = tbt.txn_billing_type_id AND
            tt.transaction_type_id   = tbt.transaction_type_id AND
            tbt.billing_type         = cbtc.billing_type AND
            edt.line_submitted       = 'N' AND
            ((edt.original_source_code = nvl(p_ctrl_orig_source,ORIGINAL_SOURCE_CODE)
                and edt.source_code = nvl(p_ctrl_source,SOURCE_CODE))  OR
            (p_ctrl_submit_source = 'DR'
              and original_source_code = 'SR'
              and edt.source_code = 'DR'))
              order by edt.org_id,edt.estimate_detail_id
              For Update of edt.estimate_detail_id nowait; -- Bug 7632716
--	      For Update nowait; -- for cross ou  --7117301

    TYPE t_EstDTLTAB IS TABLE OF Fetch_Est_Dtl%rowtype
    INDEX BY BINARY_INTEGER;

    EstDTLTAB     T_EstDTLTAB;

    -- Changes for 11.5.10
    TYPE t_msgtable IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;

    msg_table t_msgtable;
    temp_tab VARCHAR2(8000);

    --
    -- Following Cursor fetches the Order_Number from Charge lines that have
    -- already been submitted to Order Management .

    CURSOR Fetch_Est_Ord_Dtl(p_currency_code varchar2,p_price_list_header_id number,
                        p_invoice_to_org_id number,p_ship_to_org_id number ,
                        p_purchase_order_num varchar2,p_txn_billing_type_id number,
                        p_org_id number,p_order_type_id number,p_book_order_flag varchar2) IS
    SELECT nvl(max(edt.order_header_id),-999)
    FROM    CS_ESTIMATE_DETAILS      edt,
            CS_TXN_BILLING_OETXN_ALL tb,
            OE_ORDER_HEADERS_ALL     oe
    WHERE   edt.incident_id          = p_incident_id          AND
            edt.currency_code        = p_currency_code        AND
            nvl(edt.invoice_to_org_id,-999)    = nvl(p_invoice_to_org_id,-999)    AND
            nvl(edt.ship_to_org_id,-999)       = nvl(p_ship_to_org_id,-999)       AND
            nvl(edt.org_id,-999)               = nvl(p_org_id,-999)               AND
            nvl(edt.purchase_order_num,'-999') = nvl(p_purchase_order_num,'-999') AND
            edt.order_header_id      is not null              AND
            edt.order_line_id        is not null              AND
            edt.interface_to_oe_flag = 'Y'                    AND
            edt.txn_billing_type_id  = tb.txn_billing_type_id AND
            nvl(edt.org_id,-999)     = nvl(tb.org_id,-999)    AND
            tb.order_type_id         = p_order_type_id        AND
            edt.order_header_id      = oe.header_id           AND
            oe.open_flag             = 'Y'                    AND
            oe.booked_flag           = decode(p_book_order_flag,'N','N','Y');


--  NOT Needed since org_id is now at the line level.
--  Get the Incident_Org_id
--  Cursor Get_Org_Id is
--  SELECT org_id
--  FROM   cs_incidents_all_b
--  WHERE  incident_id = p_incident_id;

    -- Get the PO from Order_Header
    Cursor Cust_Po(p_order_header_id number) is
    SELECT nvl(cust_po_number,'-999')
    FROM   oe_order_headers_all
    WHERE  header_id = p_order_header_id;

    -- Get the Modifier_header_id
    CURSOR Get_Modifier_Header(p_list_line_id number) is
    SELECT list_header_id
    FROM   qp_list_lines
    WHERE  list_line_id = p_list_line_id;

    --
     --BUG 4287842

    CURSOR get_inv_item_id(p_instance_id number) IS
    select inventory_item_id from csi_item_instances
    where instance_id = p_instance_id;
    --
    CURSOR acct_from_party(p_party_id number) IS
    SELECT count(cust_account_id)
    FROM  HZ_CUST_ACCOUNTS_ALL
    WHERE party_id = p_party_id
    AND   NVL(status, 'A') = 'A';
    --
    --
    l_inventory_item_id     NUMBER;
    l_order_type_id         NUMBER := 0;
    l_order_header_id       NUMBER;
    l_line_type_id          NUMBER := 0;
    l_org_id                NUMBER;
    l_purchase_order_num    VARCHAR2(50);  --added by cnemalik

    l_OM_ERROR  EXCEPTION;
    l_IB_ERROR  EXCEPTION;

    l_dummy     NUMBER;

--  The following are reqd to call installbase API.
--  11.5.5 Intstalled Base definitions
--  l_line_inst_dtl_rec          cs_inst_detail_pub.line_inst_dtl_rec_type;
--  l_line_inst_dtl_desc_flex    CS_INSTALLEDBASE_PUB.DFF_REC_TYPE;

--  11.5.6 Intstalled Base definitions
    csi_txn_line_rec             csi_t_datastructures_grp.txn_line_rec;
    csi_txn_line_rec_null        csi_t_datastructures_grp.txn_line_rec;
    csi_txn_line_detail_tbl      csi_t_datastructures_grp.txn_line_detail_tbl;
    csi_txn_party_detail_tbl     csi_t_datastructures_grp.txn_party_detail_tbl;
    csi_txn_pty_acct_detail_tbl  csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    csi_txn_ii_rltns_tbl         csi_t_datastructures_grp.txn_ii_rltns_tbl;
    csi_txn_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;
    csi_txn_ext_attrib_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    csi_txn_systems_tbl          csi_t_datastructures_grp.txn_systems_tbl;
--
    l_sub_type_id                NUMBER;
    l_source_type_id             NUMBER;

    l_src_reference_reqd         VARCHAR2(1);
    l_src_change_owner           VARCHAR2(1);
    l_src_change_owner_to_code   VARCHAR2(1);
    l_src_return_reqd_flag       VARCHAR2(1);

    l_non_src_reference_reqd     VARCHAR2(1);
    l_non_src_change_owner       VARCHAR2(1);
    l_non_src_change_owner_to_code  VARCHAR2(1);

    l_internal_party_id          NUMBER;
    l_instance_party_id          NUMBER;
    l_update_ib_flag             VARCHAR2(1);

    l_ib_serial_number           VARCHAR2(30);

-- Common Intstalled Base definitions
    xi_return_status            VARCHAR2(30);
    xi_msg_count                NUMBER;
    xi_msg_data                 VARCHAR2(2000);
    xi_line_inst_detail_id      NUMBER;
    xi_object_version_number    NUMBER;
    l_transaction_type_id       NUMBER;
--
--
-- Variables for creating Line_adjustment records
    l_modifier_header_id        NUMBER := 0;
    l_modifier_line_id          NUMBER := 0;
    l_operand                   NUMBER := 0;
    l_adjusted_amount           NUMBER := 0;
    l_before_warranty_cost      NUMBER := 0;
    l_return_quantity           NUMBER;  -- Fix bug 2930729

    l_file varchar2(80);
    l_acct_no NUMBER;

    -- Added for bug:5408354
    l_arith_operator qp_list_lines.arithmetic_operator%type;
    l_currency_code  qp_list_headers.currency_code%type;
    L_API_ERROR_WITH_FND_MESSAGE EXCEPTION;
    --
--
--  Added this to get account_id after submitting an order to OM.
--
    l_account_id NUMBER;

-- Changes for 11.5.10
--
  	l_book_order_flag	    VARCHAR2(1);
	l_book_order_profile	VARCHAR2(1);
	l_order_status_flag	    VARCHAR2(1);
	l_ctrl_orig_source	    VARCHAR2(30);
   	l_ctrl_source		    VARCHAR2(30);
--
	CURSOR get_order_status(p_order_header_id number) IS
	SELECT booked_flag
	FROM   oe_order_headers_all
	WHERE  header_id = p_order_header_id;

--srini
	CURSOR Get_party_number is
	 SELECT party_number
	 FROM hz_parties
	 WHERE party_id = p_party_id;

	 l_party_number hz_parties.party_number%type;
--
--
--   For Events

          wf_resp_appl_id                 number;
          wf_resp_id                      number;
          wf_user_id                      number;
--
        orig_org_id             number;
        orig_user_id            number;
        orig_resp_id            number;
        orig_resp_appl_id       number;
        new_org_id              number;
        new_user_id             number;
        new_resp_id             number;
        new_resp_appl_id        number;

     -- Bug 9312433
     Cursor c_sub_type(p_sub_type_id  number) is
     SELECT SRC_REFERENCE_REQD
     FROM CSI_IB_TXN_TYPES
     WHERE sub_type_id = p_sub_type_id;

     l_src_ref_reqd varchar2(3);

     -- Bug 8203856
     Cursor get_parent_instance(p_child_instance_id Number) is
     SELECT object_id
     FROM csi_ii_relationships
     WHERE subject_id = p_child_instance_id;

     l_parent_instance_id Number;
     -- End Bug 8203856

BEGIN

 -- dbms_application_info.set_client_info('204');


    --  Standard Start of API Savepoint
    SAVEPOINT  CS_Charge_Create_Order_PVT;

    --  Standard Call to check API compatibility
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_incident_id:' || p_incident_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_party_id:' || p_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_account_id:' || p_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_book_order_flag:' || p_book_order_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_source:' || p_submit_source
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_from_system:' || p_submit_from_system
    );

  END IF;
    --
    -- API body
    --
    -- Local Procedure

    -- Validate parameters
    IF (p_incident_id is null) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement
	    , L_LOG_MODULE || 'get_request_info_end'
	    , 'invalid input parameter :' || 'p_incident_id'
	    );
	  END IF;
	FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_SUBMIT_PARAMS');
        FND_MESSAGE.Set_Token('PARAM','p_incident_id');
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_party_id is null) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'invalid input parameter :'
	    , 'p_party_id'
	    );
	  END IF;
	FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_SUBMIT_PARAMS');
        FND_MESSAGE.Set_Token('PARAM','p_party_id');
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Added validations for 11.5.10 parameters. There is no validation required
    -- for submit_from_system parameter.
    --
    IF (p_book_order_flag NOT IN ('Y','N',FND_API.G_MISS_CHAR)) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'invalid input parameter :'
	    , 'p_book_order_flag'
	    );
	  END IF;
	FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_SUBMIT_PARAMS');
        FND_MESSAGE.Set_Token('PARAM','p_book_order_flag');
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_submit_source NOT IN ('SR','DR','FS',FND_API.G_MISS_CHAR)) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'invalid input parameter :'
	    , 'p_submit_source'
	    );
	  END IF;
	FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_SUBMIT_PARAMS');
        FND_MESSAGE.Set_Token('PARAM','p_submit_source');
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --- End of 11.5.10 parameter validations
    ---
    get_who_info(l_login_id,l_user_id);

    -- Verify the account on the SR party
    OPEN acct_from_party(p_party_id);
    FETCH acct_from_party
        INTO l_acct_no;
    CLOSE acct_from_party;

    IF (l_acct_no > 0) and (p_account_id is null) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE , 'Missing account id'
	    );
	  END IF;
        FND_MESSAGE.Set_Name('CS','CS_CHG_NO_ACCT_NUM_IN_SR');
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	--srini
    ELSIF l_acct_no = 0 then
      If fnd_profile.value('CS_SR_ACTION_MISS_ACCT') = 'CHG_ABORT_SUB' Then
        Open Get_party_number;
        Fetch Get_party_number into l_party_number;
	Close Get_party_number;

        FND_MESSAGE.Set_Name('CS','CS_SR_NO_VALID_ACCT');
        FND_MESSAGE.Set_Token('SOLD_TO_PARTY',l_party_number);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      End if;
    END IF;

    -- Get modifier for OM adjustment lines
    BEGIN
  l_modifier_line_id := fnd_profile.value_specific('CS_CHARGE_DEFAULT_MODIFIER');
    -- dbms_output.put_line('Default_Modifier' || l_modifier_line_id);
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The Value of profile CS_CHARGE_DEFAULT_MODIFIER :' || l_modifier_line_id
    );
  END IF;

        IF (l_modifier_line_id IS NOT NULL) THEN
            OPEN Get_Modifier_Header(l_modifier_line_id);
                FETCH Get_Modifier_Header
                INTO l_modifier_header_id;
            CLOSE Get_Modifier_Header;
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_DEFAULT_MODIFIER');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    --
    -- Check the value of book_order_flag.Changes for 11.5.10
    --
    BEGIN

       l_book_order_profile := fnd_profile.value('CS_CHG_CREATE_BOOKED_ORDERS');
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The Value of profile CS_CHG_CREATE_BOOKED_ORDERS :' || l_book_order_profile
    );
  END IF;
       -- Set the value of the profile as 'N', if the profile has no value set.
         IF l_book_order_profile IS NULL THEN
	        l_book_order_profile := 'N';
         END IF;

         IF p_book_order_flag IS NOT NULL OR
            p_book_order_flag =  FND_API.G_MISS_CHAR THEN
	        l_book_order_flag := p_book_order_flag;

	     ELSIF p_book_order_flag IS NULL THEN
	           l_book_order_flag := l_book_order_profile;
         END IF;

        EXCEPTION
	       WHEN OTHERS THEN
            FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_SUBMIT_PARAMS');
            FND_MESSAGE.Set_Token('PARAM','p_book_order_flag');
            FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
            -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END;
-- End of Book Order Flag
--
--  Changes for 11.5.10. Validate submit source.
--
    IF      p_submit_source = 'SR' THEN
            l_ctrl_orig_source := 'SR';
            l_ctrl_source := 'SR';
    ELSIF   p_submit_source = 'DR' THEN
            l_ctrl_orig_source := 'DR';
            l_ctrl_source := NULL;
    ELSIF   p_submit_source = 'FS' THEN
            l_ctrl_orig_source := 'SR';
            l_ctrl_source := 'SD';
    ELSIF   p_submit_source = FND_API.G_MISS_CHAR THEN
            l_ctrl_orig_source := NULL;
            l_ctrl_source := NULL;
   END IF;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The defaulted value of parameter l_ctrl_orig_source:' || l_ctrl_orig_source
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'The defaulted value of parameter l_ctrl_source:' || l_ctrl_source
    );
  END IF;

--
-- End of Validate Submit Source for 11.5.10.
--
--  NOT NEEDED since org_id is now at the line level.
--  Get the Incident_Org_id
--  OPEN Get_Org_Id;
--  FETCH Get_Org_Id
--  INTO l_org_id;
--  CLOSE Get_Org_Id;

--  Get Inventory_Org_Id
--
    l_inv_org_id := cs_std.Get_Item_Valdn_Orgzn_ID;

    -- dbms_output.put_line('Inventory_Org ' || l_inv_org_id);

    OPEN Fetch_Est_Dtl(p_incident_id,l_inv_org_id,p_submit_source,
                         l_ctrl_orig_source,l_ctrl_source);

    LOOP
        i := i+1;
        FETCH Fetch_Est_Dtl
        INTO  EstDtlTab(i);
        EXIT WHEN Fetch_Est_Dtl%NOTFOUND;

        -- dbms_output.put_line('Estimate_Detail_Id ' || EstDtlTab(i).estimate_detail_id);

        l_record_found := 'Y';
	--
	--
        l_control_rec.calculate_price := FND_API.G_FALSE;
        l_org_id := EstDtlTab(i).org_id;

        OPEN Fetch_Est_Ord_Dtl(EstDtlTab(i).currency_code,EstDtlTab(i).price_list_header_id,
                EstDtlTab(i).invoice_to_org_id,EstDtlTab(i).ship_to_org_id,
                EstDtlTab(i).purchase_order_num ,EstDtlTab(i).txn_billing_type_id,
                l_org_id, EstDtlTab(i).Order_Type_Id,l_book_order_flag);
        FETCH Fetch_Est_Ord_Dtl
         INTO l_order_header_id;
        CLOSE Fetch_Est_Ord_Dtl;

       -- dbms_output.put_line('In the begin');
    --
	-- Added for 11.5.10
	-- Checking the status of the order for add_to_order or
        -- when adding a line to an existing order.

    -- dbms_output.put_line('Add_to_Order_Flag' || EstDtlTab(i).add_to_order_flag);
    -- dbms_output.put_line('order_header_id' || l_order_header_id);

 IF (EstDtlTab(i).add_to_order_flag = 'Y'
    OR l_order_header_id <> -999
    )
    AND EstDtlTab(i).add_to_order_flag <> 'F' --5649493
 THEN

	       IF EstDtlTab(i).order_header_id IS NULL THEN

           OPEN get_order_status(l_order_header_id);
	       FETCH Get_Order_Status
           INTO l_order_status_flag;
	       CLOSE Get_Order_Status;

           ELSE

           OPEN get_order_status(EstDtlTab(i).order_header_id);
	       FETCH Get_Order_Status
           INTO l_order_status_flag;
	       CLOSE Get_Order_Status;

           END IF;

	       -- dbms_output.put_line('Order_Status_Flag' || l_order_status_flag);

	       -- OM order_status is null till the records have been comitted.
	       IF (l_order_status_flag = 'Y' or
               l_order_status_flag IS NULL or
		       l_order_status_flag = 'N') and
               l_book_order_flag = 'N'    THEN

                 l_control_rec.book_flag := FND_API.G_FALSE;

           ELSIF (l_order_status_flag = 'Y' and
                  l_book_order_flag = 'Y') THEN

		         l_control_rec.book_flag := FND_API.G_FALSE;

           ELSIF l_order_status_flag = 'N'  and
		         l_book_order_flag = 'Y'    THEN

                 l_control_rec.book_flag := FND_API.G_TRUE;

           END IF;

      ELSIF (EstDtlTab(i).add_to_order_flag = 'N') or
              (EstDtlTab(i).add_to_order_flag IS NULL) or
	       -- fix bug:3667208
              (EstDtlTab(i).add_to_order_flag = 'F')
	      --and (l_order_header_id = -999 )  --5649493
	THEN

	        IF l_book_order_flag = 'Y' THEN
                 l_control_rec.book_flag := FND_API.G_TRUE;
	        ELSIF l_book_order_flag = 'N' THEN
                 l_control_rec.book_flag := FND_API.G_FALSE;
	        END IF;
       END IF;

     -- dbms_output.put_line('Book_Flag' || l_control_rec.book_flag);
	--
	-- End of 11.5.10 changes for order status.
	--
    --  VALIDATE CATEGORY CODE
        IF  EstDtlTab(i).line_category_code <> 'RETURN'
        AND EstDtlTab(i).line_category_code <> 'ORDER' THEN
            FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_CAT_CODE');
            FND_MSG_PUB.Add;
	    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        IF  EstDtlTab(i).quantity_required is null
        OR  EstDtlTab(i).quantity_required = 0  THEN
            FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_QTY');
            FND_MSG_PUB.Add;
	    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    --  GET ORDER_TYPE AND LINE_TYPE
        BEGIN
            l_order_type_id := EstDtlTab(i).order_type_id;
            l_line_type_id  := EstDtlTab(i).line_type_id;

        IF l_order_type_id = 0
            or l_order_type_id  is null
            or l_line_type_id = 0
            or l_line_type_id is null then
            RAISE L_OM_ERROR;

        END IF;

        EXCEPTION
            WHEN L_OM_ERROR THEN
                FND_MESSAGE.Set_Name('CS','CS_CHG_DEFINE_OMTYPES');
                FND_MSG_PUB.Add;
	    	FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                      p_count => x_msg_count,
                                      p_data  => x_msg_data);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        --
        --
        -- dbms_output.put_line('After Order Type and Line Type');
        --
        -- Clear ASO datastructures
        l_line_tbl.delete;
        l_line_dtl_tbl.delete;
        l_ln_shipment_tbl.delete;
        l_hd_payment_tbl.delete;
        l_ln_payment_tbl.delete; /* Credit Card 9358401 */
        l_line_price_adj_tbl.delete;
        l_header_rec := l_header_rec_default;

    	l_header_rec.invoice_to_party_id := NULL;
        l_header_rec.invoice_to_party_site_id := NULL;
        l_header_rec.invoice_to_cust_account_id := NULL;

        l_lot_serial_tbl := ASO_ORDER_INT.G_MISS_Lot_Serial_Tbl;
	--
	-- Order_type_id moved to create order section. fix bug:3557645
        -- l_header_rec.order_type_id := l_order_type_id;

	--
	-- Populate Flexfiled with G_MISS_CHAR so defaulting rules will work.
	-- Passing flexfield values as g_miss_char both for new orders/add to orders.
            l_header_rec.attribute1  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute2  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute3  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute4  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute5  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute6  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute7  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute8  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute9  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute10 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute11 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute12 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute13 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute14 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute15 := FND_API.G_MISS_CHAR;

       -- FIX Bug:3667208
	IF (EstDtlTab(i).add_to_order_flag = 'F') THEN

            l_header_rec.order_type_id := l_order_type_id;
            l_header_rec.org_id := EstDtlTab(i).org_id;
            l_header_rec.quote_source_code  := 'Service Billing';  -- Lookup value 7
            l_header_rec.party_id           := p_party_id ;

            IF EstDtlTab(i).invoice_to_account_id IS NULL THEN
              Get_acct_from_party_site (
                p_party_site_id            => EstDtlTab(i).invoice_to_org_id,
                p_sold_to_customer_party   => p_party_id,
                p_sold_to_customer_account => p_account_id,
                p_org_id                   => EstDtlTab(i).org_id,--Bug# 4870037
                p_site_use_flag            => 'B',--Bug# 4870037
		p_site_use_code		   => 'BILL_TO',
                x_account_id               => l_invoice_to_cust_account_id);
            ELSE
               --l_header_rec.invoice_to_cust_account_id := EstDtlTab(i).invoice_to_account_id;
               l_invoice_to_cust_account_id := EstDtlTab(i).invoice_to_account_id;
            END IF;

            l_header_rec.invoice_to_party_id := EstDtlTab(i).bill_to_contact_id; --Bugfix :7164996
            l_header_rec.invoice_to_party_site_id := EstDtlTab(i).invoice_to_org_id;
            l_header_rec.cust_account_id    := p_account_id;
            l_header_rec.invoice_to_cust_account_id := l_invoice_to_cust_account_id;

            IF EstDtlTab(i).ship_to_account_id IS NULL THEN
              Get_acct_from_party_site (
                p_party_site_id            => EstDtlTab(i).ship_to_org_id,
                p_sold_to_customer_party   => p_party_id,
                p_sold_to_customer_account => p_account_id,
                p_org_id                   => EstDtlTab(i).org_id,
                p_site_use_flag            => 'S',
		p_site_use_code		   => 'SHIP_TO',
                x_account_id               => l_ship_to_cust_account_id);
            ELSE
               --l_hd_shipment_tbl(j).ship_to_cust_account_id := EstDtlTab(i).ship_to_account_id;
               l_ship_to_cust_account_id := EstDtlTab(i).ship_to_account_id;
            END IF;

            l_hd_shipment_tbl(j).ship_to_party_id := EstDtlTab(i).ship_to_contact_id;  --Bugfix :7164996
            l_hd_shipment_tbl(j).ship_to_party_site_id := EstDtlTab(i).ship_to_org_id;
            l_hd_shipment_tbl(j).ship_from_org_id := EstDtlTab(i).transaction_inventory_org;
            l_hd_shipment_tbl(j).ship_to_cust_account_id := l_ship_to_cust_account_id;

            l_header_rec.quote_header_id           :=  P_INCIDENT_ID;

	    BEGIN
             -- Fix for the bug:3509921
            l_incident_number := to_number(EstDtlTab(i).incident_number);

            l_header_rec.original_system_reference :=  EstDtlTab(i).incident_number;
            l_header_rec.quote_number              :=  EstDtlTab(i).incident_number;

            -- dbms_output.put_line('Passing number incident_number');

            EXCEPTION
            WHEN OTHERS THEN
                 l_header_rec.original_system_reference :=  EstDtlTab(i).incident_number; --Bug 7170849

		  -- dbms_output.put_line('Passing character incident_number');

	    END;

            --
            l_header_rec.order_type_id      := l_order_type_id;

	    IF EstDtlTab(i).conversion_type_code = 'User' THEN
            l_header_rec.exchange_rate      := EstDtlTab(i).conversion_rate;
            l_header_rec.exchange_type_code := EstDtlTab(i).conversion_type_code;
            l_header_rec.exchange_rate_date := EstDtlTab(i).conversion_rate_date;
            ELSIF EstDtlTab(i).conversion_type_code = 'Corporate' THEN
            l_header_rec.exchange_type_code := EstDtlTab(i).conversion_type_code;
            l_header_rec.exchange_rate_date := EstDtlTab(i).conversion_rate_date;
	    END IF;

            l_header_rec.price_list_id      := EstDtlTab(i).price_list_header_id;
            l_header_rec.currency_code      := EstDtlTab(i).currency_code ;

            --
            IF EstDtlTab(i).purchase_order_num <> '-999' THEN
                l_hd_payment_tbl(j).payment_type_code := NULL;
                -- Fix bug:5210040
                -- l_hd_payment_tbl(j).payment_ref_number := EstDtlTab(i).purchase_order_num;
                l_hd_payment_tbl(j).cust_po_number := EstDtlTab(i).purchase_order_num;
            END IF;
        --
        END IF; -- END OF CREATING A NEW ORDER FOR A CHARGE LINE.NEW ORDER IS CREATED IF
		-- ADD_TO_ORDER_FLAG = 'F'
	--
	--
        /**************** ADDING A LINE TO AN EXISTING ORDER *************/

     IF (EstDtlTab(i).add_to_order_flag = 'Y') or (l_order_header_id <> -999) THEN
            IF (EstDtlTab(i).add_to_order_flag = 'Y') then
                l_header_rec.order_id   := EstDtlTab(i).order_header_id;
                --
                OPEN Cust_Po(EstDtlTab(i).order_header_id);
                    FETCH Cust_Po
                    INTO  l_purchase_order_num;
                CLOSE Cust_Po;
                --
            ELSIF (l_order_header_id <> -999) then
                l_header_rec.order_id := l_order_header_id;
                --
                OPEN Cust_Po(l_order_header_id);
                    FETCH Cust_Po
                    INTO  l_purchase_order_num;
                CLOSE Cust_Po;
                --
            END IF;

            l_line_tbl(j).operation_code   := 'CREATE';
            l_ln_shipment_tbl(j).operation_code :=  'CREATE';

            -- following added by cnemalik
            IF (l_purchase_order_num = '-999') AND
               (EstDtlTab(i).purchase_order_num <> '-999') THEN
                  -- Fix bug:51051400
                  -- l_hd_payment_tbl(j).payment_ref_number := EstDtlTab(i).purchase_order_num;
                  l_hd_payment_tbl(j).payment_type_code := NULL;
                  l_hd_payment_tbl(j).cust_po_number := EstDtlTab(i).purchase_order_num;

            ELSIF EstDtlTab(i).purchase_order_num <> '-999'  AND
                  l_purchase_order_num <> EstDtlTab(i).purchase_order_num THEN

                   ROLLBACK TO CS_Charge_Create_Order_PVT;
                   FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_PO');
                   FND_MESSAGE.Set_Token('PURCHASE_ORDER_NUM',l_purchase_order_num);
			    FND_MSG_PUB.Add; -- 5455064
                   -- APP_EXCEPTION.Raise_Exception;
	    	         FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
					     p_count => x_msg_count,
                                             p_data  => x_msg_data);

                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;
        -- This value needs to be passed for add_to_order/update_order as well.
        -- Fix for the bug 2123535
            l_header_rec.quote_source_code  := 'Service Billing';  -- Lookup value 7
	    Begin
	        -- Fix for the bug 5463554
		l_incident_number := to_number(EstDtlTab(i).incident_number);  -- Bug 8857796

		l_header_rec.original_system_reference :=  EstDtlTab(i).incident_number;
                l_header_rec.quote_number              :=  EstDtlTab(i).incident_number;
            /* Bug 8857796 */
	    Exception
	      When others then
	         l_header_rec.original_system_reference :=  EstDtlTab(i).incident_number;
	    End;
            /* Bug 8857796 */
        ELSE   /* create a new order */
            -- Populate Flexfiled with G_MISS_CHAR so defaulting rules will work
	    -- Moved to before add_to_order/new_order.
            /* l_header_rec.attribute1  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute2  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute3  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute4  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute5  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute6  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute7  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute8  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute9  := FND_API.G_MISS_CHAR;
            l_header_rec.attribute10 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute11 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute12 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute13 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute14 := FND_API.G_MISS_CHAR;
            l_header_rec.attribute15 := FND_API.G_MISS_CHAR; */
            --
            l_header_rec.order_type_id := l_order_type_id;
            l_header_rec.org_id := EstDtlTab(i).org_id;
            l_header_rec.quote_source_code  := 'Service Billing';  -- Lookup value 7
            l_header_rec.party_id           := p_party_id ;

           -- dbms_output.put_line('In the begin');
            -- IF ACCOUNT_ID IS NULL, THEN OC CREATES AN ACCT FROM INVOICE_TO_PARTY_SITE_ID
            /* Get_acct_from_party_site (
               p_party_site_id            => EstDtlTab(i).invoice_to_org_id,
               p_sold_to_customer_party   => p_party_id,
               p_sold_to_customer_account => p_account_id,
               x_account_id               => l_header_rec.invoice_to_cust_account_id); */

            IF EstDtlTab(i).invoice_to_account_id IS NULL THEN
              Get_acct_from_party_site (
                p_party_site_id            => EstDtlTab(i).invoice_to_org_id,
                p_sold_to_customer_party   => p_party_id,
                p_sold_to_customer_account => p_account_id,
                p_org_id                   => EstDtlTab(i).org_id,
                p_site_use_flag            => 'B',
		p_site_use_code		   => 'BILL_TO',
                x_account_id               => l_invoice_to_cust_account_id);
            ELSE
               --l_header_rec.invoice_to_cust_account_id := EstDtlTab(i).invoice_to_account_id;
               l_invoice_to_cust_account_id := EstDtlTab(i).invoice_to_account_id;
            END IF;

            l_header_rec.invoice_to_party_id := EstDtlTab(i).bill_to_contact_id; --Bugfix :7164996
            l_header_rec.invoice_to_party_site_id := EstDtlTab(i).invoice_to_org_id;
            l_header_rec.cust_account_id    := p_account_id;
            l_header_rec.invoice_to_cust_account_id := l_invoice_to_cust_account_id;

            /*Get_acct_from_party_site (
                p_party_site_id            => EstDtlTab(i).ship_to_org_id,
                p_sold_to_customer_party   => p_party_id,
                p_sold_to_customer_account => p_account_id,
                x_account_id               => l_hd_shipment_tbl(j).ship_to_cust_account_id); */

            IF EstDtlTab(i).ship_to_account_id IS NULL THEN
              Get_acct_from_party_site (
                p_party_site_id            => EstDtlTab(i).ship_to_org_id,
                p_sold_to_customer_party   => p_party_id,
                p_sold_to_customer_account => p_account_id,
                p_org_id                   => EstDtlTab(i).org_id,
                p_site_use_flag            => 'S',
		p_site_use_code		   => 'SHIP_TO',
                x_account_id               => l_ship_to_cust_account_id);
            ELSE
               --l_hd_shipment_tbl(j).ship_to_cust_account_id := EstDtlTab(i).ship_to_account_id;
               l_ship_to_cust_account_id := EstDtlTab(i).ship_to_account_id;
            END IF;

            l_hd_shipment_tbl(j).ship_to_party_id := EstDtlTab(i).ship_to_contact_id;  --Bugfix :7164996
            l_hd_shipment_tbl(j).ship_to_party_site_id := EstDtlTab(i).ship_to_org_id;
            l_hd_shipment_tbl(j).ship_from_org_id := EstDtlTab(i).transaction_inventory_org;
            l_hd_shipment_tbl(j).ship_to_cust_account_id := l_ship_to_cust_account_id;

            l_header_rec.quote_header_id           :=  P_INCIDENT_ID;

	    BEGIN
             -- Fix for the bug:3509921
            l_incident_number := to_number(EstDtlTab(i).incident_number);

            l_header_rec.original_system_reference :=  EstDtlTab(i).incident_number;
            l_header_rec.quote_number              :=  EstDtlTab(i).incident_number;

            -- dbms_output.put_line('Passing number incident_number');

            EXCEPTION
            WHEN OTHERS THEN
            NULL;
            -- dbms_output.put_line('Passing character incident_number');
            l_header_rec.original_system_reference :=  EstDtlTab(i).incident_number;

	    END;

            --
            l_header_rec.order_type_id      := l_order_type_id;
            IF EstDtlTab(i).conversion_type_code = 'User' THEN
            l_header_rec.exchange_rate      := EstDtlTab(i).conversion_rate;
            l_header_rec.exchange_type_code := EstDtlTab(i).conversion_type_code;
            l_header_rec.exchange_rate_date := EstDtlTab(i).conversion_rate_date;
            ELSIF EstDtlTab(i).conversion_type_code = 'Corporate' THEN
            l_header_rec.exchange_type_code := EstDtlTab(i).conversion_type_code;
	    END IF;

            l_header_rec.price_list_id      := EstDtlTab(i).price_list_header_id;
            l_header_rec.currency_code      := EstDtlTab(i).currency_code ;

            --
            IF EstDtlTab(i).purchase_order_num <> '-999' THEN
                l_hd_payment_tbl(j).payment_type_code := NULL;
                -- Fix bug:5210040
                -- l_hd_payment_tbl(j).payment_ref_number := EstDtlTab(i).purchase_order_num;
                l_hd_payment_tbl(j).cust_po_number := EstDtlTab(i).purchase_order_num;
            END IF;
        --
        END IF; -- END OF ADDING AN ORDER LINE TO AN EXISTING ORDER
        --
        -- Moved to create order section for bug:3557645
        -- l_header_rec.price_list_id      := EstDtlTab(i).price_list_header_id;
        -- l_header_rec.currency_code      := EstDtlTab(i).currency_code ;

        -- VALIDATION FOR ROLLUP FLAG
        --
        --
        IF EstDtlTab(i).rollup_flag = 'Y' THEN

        /*    SELECT billing_type
            INTO l_billing_flag
            FROM   cs_txn_billing_types
            WHERE  txn_billing_type_id = EstDtlTab(i).txn_billing_type_id; */

            /*
            SELECT cbtc.billing_category
            INTO l_billing_flag
            FROM cs_txn_billing_types ctbt, cs_billing_type_categories cbtc
            WHERE ctbt.txn_billing_type_id = EstDtlTab(i).txn_billing_type_id
              AND ctbt.billing_type = cbtc.billing_type;

            IF l_billing_flag = 'L' THEN
                l_inv_item_id := FND_PROFILE.VALUE_SPECIFIC('CS_REPAIR_DEFAULT_LABOR_ITEM');
                l_profile_option := 'CS_REPAIR_DEFAULT_LABOR_ITEM';
		  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
		    , 'The Value of profile CS_REPAIR_DEFAULT_LABOR_ITEM :' || l_inv_item_id
		    );
		  END IF;
            ELSIF l_billing_flag = 'M' THEN
                l_inv_item_id := FND_PROFILE.VALUE_SPECIFIC('CS_REPAIR_DEFAULT_MATERIAL_ITEM');
                l_profile_option := 'CS_REPAIR_DEFAULT_MATERIAL_ITEM';
		  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
		    , 'The Value of profile CS_REPAIR_DEFAULT_MATERIAL_ITEM :' || l_inv_item_id
		    );
		  END IF;
	    ELSIF l_billing_flag = 'E' THEN
                l_inv_item_id := FND_PROFILE.VALUE_SPECIFIC('CS_REPAIR_DEFAULT_EXPENSE_ITEM');
                l_profile_option := 'CS_REPAIR_DEFAULT_EXPENSE_ITEM';
		  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		  THEN
		    FND_LOG.String
		    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
		    , 'The Value of profile CS_REPAIR_DEFAULT_EXPENSE_ITEM :' || l_inv_item_id
		    );
		  END IF;
	    END IF;

            IF l_inv_item_id = NULL THEN */
            IF EstDtlTab(i).rollup_item_id IS NULL THEN
                --FND_MESSAGE.Set_Name('CS', 'CS_CHG_DEFINE_PROFILE_OPTION');
                --FND_MESSAGE.Set_Token('PROFILE_OPTION', l_profile_option);
                FND_MESSAGE.Set_Name('CS', 'CS_CHG_BILLING_TYPE_NO_ROLLUP');
                FND_MSG_PUB.Add;
		FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                          p_count => x_msg_count,
                                          p_data  => x_msg_data);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSE
               l_inv_item_id := EstDtlTab(i).rollup_item_id;
            END IF;

            -- Get the Primary_Unit_of_Measure.
            SELECT     primary_uom_code
            INTO       l_unit_code
            FROM       mtl_system_items
            WHERE      inventory_item_id = l_inv_item_id AND
                       organization_id = CS_STD.Get_Item_Valdn_Orgzn_ID;

             l_line_tbl(j).inventory_item_id   := l_inv_item_id ;
             l_line_tbl(j).UOM_code            := l_unit_code ;
          --Bug 8474403
	    l_line_tbl(j).item_revision       := null;

        ELSE  -- If rollup_flag is not 'Y'
            l_line_tbl(j).inventory_item_id   := EstDtlTab(i).inventory_item_id;
            l_line_tbl(j).UOM_code            := EstDtlTab(i).unit_of_measure_code ;
          --Bug 8474403
	    l_line_tbl(j).item_revision       := EstDtlTab(i).item_revision;

        END IF ; -- ROLLUP FLAG

        /* Get_acct_from_party_site (
           p_party_site_id            => EstDtlTab(i).invoice_to_org_id,
           p_sold_to_customer_party   => p_party_id,
           p_sold_to_customer_account => p_account_id,
           x_account_id               => l_header_rec.invoice_to_cust_account_id); */

        IF EstDtlTab(i).invoice_to_account_id IS NULL THEN
          Get_acct_from_party_site (
            p_party_site_id            => EstDtlTab(i).invoice_to_org_id,
            p_sold_to_customer_party   => p_party_id,
            p_sold_to_customer_account => p_account_id,
            p_org_id                   => EstDtlTab(i).org_id,
            p_site_use_flag            => 'B',
    	    p_site_use_code	       => 'BILL_TO',
            x_account_id               => l_invoice_to_cust_account_id);
        ELSE
           --l_header_rec.invoice_to_cust_account_id := EstDtlTab(i).invoice_to_account_id;
           l_invoice_to_cust_account_id := EstDtlTab(i).invoice_to_account_id;
        END IF;

        l_header_rec.invoice_to_cust_account_id := l_invoice_to_cust_account_id;
	l_line_tbl(j).item_type_code := EstDtlTab(i).item_type_code; -- 6523849
        l_line_tbl(j).invoice_to_party_id := EstDtlTab(i).bill_to_contact_id; --Bugfix :7164996
        l_line_tbl(j).invoice_to_party_site_id := EstDtlTab(i).invoice_to_org_id;
        l_line_tbl(j).invoice_to_cust_account_id := l_header_rec.invoice_to_cust_account_id;
        l_line_tbl(j).order_line_type_id  := l_line_type_id;

        IF EstDtlTab(i).line_category_code = 'RETURN' THEN
            l_ordered_quantity        := (EstDtlTab(i).quantity_required * -1);
            l_line_tbl(j).quantity            := l_ordered_quantity;
        ELSE
            l_line_tbl(j).quantity            := EstDtlTab(i).quantity_required ;
        END IF;

        l_line_tbl(j).quote_line_id       := EstDtlTab(i).estimate_detail_id ;
        l_line_tbl(j).price_list_id       := EstDtlTab(i).price_list_header_id ;

        l_unit_selling_price :=  (nvl(EstDtlTab(i).after_warranty_cost,0)/EstDtlTab(i).quantity_required);
        l_line_tbl(j).line_list_price     := nvl(EstDtlTab(i).list_price,0) ; -- 4870210
   --   l_line_tbl(j).line_list_price     := nvl(EstDtlTab(i).selling_price,0) ;
        l_line_tbl(j).line_quote_price    := l_unit_selling_price;
        l_line_tbl(j).line_category_code  := EstDtlTab(i).line_category_code;

        /*Get_acct_from_party_site (
            p_party_site_id            => EstDtlTab(i).ship_to_org_id,
            p_sold_to_customer_party   => p_party_id,
            p_sold_to_customer_account => p_account_id,
            x_account_id               => l_ln_shipment_tbl(j).ship_to_cust_account_id); */

        IF EstDtlTab(i).ship_to_account_id IS NULL THEN
          Get_acct_from_party_site (
            p_party_site_id            => EstDtlTab(i).ship_to_org_id,
            p_sold_to_customer_party   => p_party_id,
            p_sold_to_customer_account => p_account_id,
            p_org_id                   => EstDtlTab(i).org_id,
            p_site_use_flag            => 'S',
  	    p_site_use_code	       => 'SHIP_TO',
            x_account_id               => l_ship_to_cust_account_id);
        ELSE
           --l_hd_shipment_tbl(j).ship_to_cust_account_id := EstDtlTab(i).ship_to_account_id;
           l_ship_to_cust_account_id := EstDtlTab(i).ship_to_account_id;
        END IF;

        l_ln_shipment_tbl(j).ship_to_party_id := EstDtlTab(i).ship_to_contact_id;  --Bugfix :7164996
        l_ln_shipment_tbl(j).ship_to_party_site_id := EstDtlTab(i).ship_to_org_id;
        l_ln_shipment_tbl(j).quote_line_id := EstDtlTab(i).estimate_detail_id;
        l_ln_shipment_tbl(j).quote_header_id := EstDtlTab(i).incident_id;
        l_ln_shipment_tbl(j).ship_from_org_id := EstDtlTab(i).transaction_inventory_org;
        l_ln_shipment_tbl(j).ship_to_cust_account_id := l_ship_to_cust_account_id;

        IF EstDtlTab(i).line_category_code = 'RETURN' then
          l_ship_ordered_quantity  := (EstDtlTab(i).quantity_required * (-1));
          l_ln_shipment_tbl(j).quantity   :=  l_ship_ordered_quantity;
        ELSE
          l_ln_shipment_tbl(j).quantity   :=  EstDtlTab(i).quantity_required;
        END IF;

        l_ln_shipment_tbl(j).qte_line_index :=  j;

        IF EstDtlTab(i).line_category_code = 'RETURN' THEN
          -- return reason code needs to be passed in line_dtl_tbl
          l_line_dtl_tbl(j).return_reason_code := EstDtlTab(i).return_reason_code;
         -- l_line_dtl_tbl(j).qte_line_index  := j;   -- 6523849
        END IF;  -- for return

        l_line_dtl_tbl(j).qte_line_index  := j; -- 6523849
	l_line_dtl_tbl(j).quote_line_id  := EstDtlTab(i).estimate_detail_id; -- 6523849

        --
        --
        -- Passing Values for Creating Line Adjustment record.
        --
        --
        -- << Start >> Changed the logic of modifier based Calculation based on bug 5408354
                IF l_modifier_line_id IS NOT NULL
                AND  (nvl(EstDtlTab(i).selling_price, 0) * EstDtlTab(i).quantity_required  ) <> EstDtlTab(i).after_warranty_cost
                THEN

                   Begin

                      SELECT  l.arithmetic_operator,h.currency_code
                      INTO    l_arith_operator, l_currency_code
                      FROM    qp_list_headers h,
                              qp_list_lines l
                      WHERE    h.list_header_id = l.list_header_id
                      AND      l.list_line_id = l_modifier_line_id;

                      If l_arith_operator Not In ('%','AMT') Then
                         --Only amount-based and percent-based modifiers are supported as default modifier in Charges.
                         FND_MESSAGE.Set_Name('CS','CS_CHG_AMT_PER_MODIF_SUPP');
                         FND_MSG_PUB.Add;
					     FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                                  p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      End If;

                   End;

                   If NVL(l_currency_code,'@~') <> EstDtlTab(i).currency_code
                   And l_arith_operator = 'AMT'
                   Then
                      --Default modifier currency must be the same as charge line currency.
                      FND_MESSAGE.Set_Name('CS','CS_CHG_SAME_CURR_REQD');
                      FND_MSG_PUB.Add;
                      FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                                  p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   End If;

                   l_before_warranty_cost :=  (nvl(EstDtlTab(i).selling_price, 0) * EstDtlTab(i).quantity_required  );
			    -- Added according to PMs proposed bug fix
			    IF (EstDtlTab(i).list_price = 0 AND
			       l_before_warranty_cost <> 0 AND l_arith_operator <> 'AMT') THEN
				 FND_MESSAGE.Set_Name('CS','CS_CHG_AMT_MODIF_0_PRICE_ITEM');
				 FND_MSG_PUB.Add;
				 FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
				                           p_count => x_msg_count,
                                               p_data  => x_msg_data);
	                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			    END IF;

                   IF  l_before_warranty_cost = 0
                   Then
                      If  l_arith_operator = 'AMT' Then
                         l_operand := -1 * nvl (EstDtlTab(i).after_warranty_cost, 0);
                      Else
                         --Default modifier must be amount-based in order to support overrides of zero priced items.
                         FND_MESSAGE.Set_Name('CS','CS_CHG_AMT_MODIF_0_PRICE_ITEM');
                         FND_MSG_PUB.Add;
					     FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              			      p_count => x_msg_count,
                                              			      p_data  => x_msg_data);
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      End If;
                   Elsif l_before_warranty_cost > 0
                   Then
                      If l_arith_operator = 'AMT' Then
                         l_operand := nvl(EstDtlTab(i).selling_price, 0) -  nvl(EstDtlTab(i).after_warranty_cost,0)/EstDtlTab(i).quantity_required;
                      ElsIf l_arith_operator = '%' Then
                         l_operand := (l_before_warranty_cost - (nvl(EstDtlTab(i).after_warranty_cost, 0))) /l_before_warranty_cost * 100;
                      End If;
                   End IF;

                   IF  EstDtlTab(i).line_category_code = 'RETURN'
                   THEN
                      l_return_quantity := (EstDtlTab(i).quantity_required * (-1));
                      l_adjusted_amount := (EstDtlTab(i).after_warranty_cost/l_return_quantity) - EstDtlTab(i).selling_price;
                   ELSE
                      l_adjusted_amount := (EstDtlTab(i).after_warranty_cost/EstDtlTab(i).quantity_required) - EstDtlTab(i).selling_price;
                   END IF;

                   l_line_price_adj_tbl(j).operation_code     := 'CREATE';
                   l_line_price_adj_tbl(j).qte_line_index     := 1;
                   l_line_price_adj_tbl(j).Modifier_header_id := l_modifier_header_id;
                   l_line_price_adj_tbl(j).Modifier_line_id   := l_modifier_line_id;
                   l_line_price_adj_tbl(j).operand            := l_operand;
                   l_line_price_adj_tbl(j).adjusted_amount    := l_adjusted_amount;
                   l_line_price_adj_tbl(j).updated_flag       := 'Y';
                   l_line_price_adj_tbl(j).applied_flag       := 'Y';
                   l_line_price_adj_tbl(j).change_reason_code := 'MANUAL';
                   l_line_price_adj_tbl(j).change_reason_text := 'Manually Applied';
                   l_line_tbl(j).line_list_price    := nvl(EstDtlTab(i).selling_price,0); --5408354
                END IF;
  -- << End >> Changed the logic of modifier based Calculation based on bug 5408354




        /* IF (l_modifier_line_id IS NOT NULL) THEN

            l_before_warranty_cost := (nvl(EstDtlTab(i).list_price,0) *
                                        EstDtlTab(i).quantity_required); --4870210
            IF l_before_warranty_cost = 0 THEN
                l_operand := 100;
            ELSE
                l_operand := (l_before_warranty_cost -
                                (nvl(EstDtlTab(i).after_warranty_cost,0)))/l_before_warranty_cost * 100;
            END IF;

            -- Fix bug 2930729
            IF EstDtlTab(i).line_category_code = 'RETURN' then
               l_return_quantity  := (EstDtlTab(i).quantity_required * (-1));
               l_adjusted_amount := (EstDtlTab(i).after_warranty_cost/l_return_quantity) - EstDtlTab(i).list_price;
            ELSE
               l_adjusted_amount := (EstDtlTab(i).after_warranty_cost/EstDtlTab(i).quantity_required) - EstDtlTab(i).list_price;
            END IF;

            l_line_price_adj_tbl(j).operation_code := 'CREATE';
            l_line_price_adj_tbl(j).qte_line_index := 1;
            l_line_price_adj_tbl(j).Modifier_header_id := l_modifier_header_id;
            l_line_price_adj_tbl(j).Modifier_line_id := l_modifier_line_id;
            l_line_price_adj_tbl(j).operand  := l_operand;
            -- Bug 2930729 l_line_price_adj_tbl(j).adjusted_amount  := l_operand;
            l_line_price_adj_tbl(j).adjusted_amount  := l_adjusted_amount;  -- Bug 2930729
            l_line_price_adj_tbl(j).updated_flag  := 'Y';
            l_line_price_adj_tbl(j).applied_flag  := 'Y';
            l_line_price_adj_tbl(j).change_reason_code  := 'MANUAL';
            l_line_price_adj_tbl(j).change_reason_text  := 'Manually Applied';

        END IF; */
--
--
--      Populate return_serial_number value in OM if the item is not ib_trackable and line type is return.
--
        IF (EstDtlTab(i).comms_nl_trackable_flag = 'N' and
            EstDtlTab(i).line_category_code = 'RETURN' and
            EstDtlTab(i).return_serial_number IS NOT NULL) THEN

            l_lot_serial_tbl(1).lot_number    := FND_API.G_MISS_CHAR;
            l_lot_serial_tbl(1).lot_serial_id := FND_API.G_MISS_NUM;
            l_lot_serial_tbl(1).quantity      := abs(EstDtlTab(i).quantity_required);
            l_lot_serial_tbl(1).from_serial_number := EstDtlTab(i).return_serial_number;
            l_lot_serial_tbl(1).to_serial_number := EstDtlTab(i).return_serial_number;
            l_lot_serial_tbl(1).operation     := 'CREATE';
            l_lot_serial_tbl(1).line_index    := j;
        END IF;
--
--
--      Populate Install Base API records
--
--
        IF EstDtlTab(i).comms_nl_trackable_flag = 'Y' THEN

        -- Get Transaction type information
            BEGIN
                SELECT a.transaction_type_id,
                    b.sub_type_id,
                    c.transaction_type_id,
                    nvl(b.src_reference_reqd,'N'),
                    b.src_change_owner,
                    b.src_change_owner_to_code,
                    nvl(b.non_src_reference_reqd,'N'),
                    b.non_src_change_owner,
                    b.non_src_change_owner_to_code,
                    nvl(b.update_ib_flag,'N'),
                    b.src_return_reqd -- Bug 4586140
                INTO   l_transaction_type_id,
                    l_sub_type_id,
                    l_source_type_id,
                    l_src_reference_reqd,
                    l_src_change_owner,
                    l_src_change_owner_to_code,
                    l_non_src_reference_reqd,
                    l_non_src_change_owner,
                    l_non_src_change_owner_to_code,
                    l_update_ib_flag,
                    l_src_return_reqd_flag -- Bug 4586140
                FROM   CS_TXN_BILLING_TYPES a,
                    csi_txn_sub_types    b,
                    csi_txn_types        c
                WHERE a.txn_billing_type_id = EstDtlTab(i).txn_billing_type_id
                    AND   a.transaction_type_id = b.cs_transaction_type_id
                    AND   b.transaction_type_id = c.transaction_type_id
                    AND   c.source_application_id = 660
                    AND   c.source_transaction_type =
                    decode(EstDtlTab(i).line_category_code,'RETURN', 'RMA_RECEIPT', 'ORDER', 'OM_SHIPMENT',null);
                EXCEPTION
                    WHEN TOO_MANY_ROWS THEN
                        FND_MESSAGE.Set_Name('CS','CS_CHG_IB_TOO_MANY_SOURCES');
                        FND_MSG_PUB.Add;
			FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              	  p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   WHEN NO_DATA_FOUND THEN
		 	l_update_ib_flag := 'N';
		   /* Commenting out this exception as part of IB changes */
                      /* FND_MESSAGE.Set_Name('CS','CS_CHG_IB_NO_VALID_TXN_TYPE');
                         FND_MSG_PUB.Add;
			 FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              	  p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */
            END;

            -- Populate installation details if there is instance information and
	    -- update_ib_flag is 'Y',but do not raise any error message.
            -- Bug fix 3564034

      IF l_update_ib_flag = 'Y' THEN
           IF  EstDtlTab(i).customer_product_id is not null THEN
            -- For return lines for IB, pass serial number to OM
                IF EstDtlTab(i).line_category_code = 'RETURN' THEN
                        l_ib_serial_number := null;
                        BEGIN
                            select serial_number,
			           lot_number -- Bug 8284773
                            into l_ib_serial_number,
			         l_ib_lot_number  --Bug 8284773
                            from CSI_ITEM_INSTANCES
                            where instance_id = EstDtlTab(i).customer_product_id;
                        EXCEPTION
  			     -- Serial_number is available only if the instance is serialized
                            /* WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('CS','CS_CHG_IB_MISSING_INSTANCE');
                                FND_MSG_PUB.Add;
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */
                            WHEN OTHERS THEN
                                RAISE;
                        END;
                        IF l_ib_serial_number is not null THEN
                            l_lot_serial_tbl(1).lot_number    := FND_API.G_MISS_CHAR;
                            l_lot_serial_tbl(1).lot_serial_id := FND_API.G_MISS_NUM;
                            l_lot_serial_tbl(1).quantity      := abs(EstDtlTab(i).quantity_required);
                            l_lot_serial_tbl(1).from_serial_number := l_ib_serial_number;
                            l_lot_serial_tbl(1).to_serial_number := l_ib_serial_number;
                            l_lot_serial_tbl(1).operation     := 'CREATE';
                            l_lot_serial_tbl(1).line_index    := j;
                        END IF;
			--Bug 8284773
			IF l_ib_lot_number is not null THEN
                            l_lot_serial_tbl(1).lot_number    := l_ib_lot_number;
                            l_lot_serial_tbl(1).lot_serial_id := FND_API.G_MISS_NUM;
                            l_lot_serial_tbl(1).quantity      := abs(EstDtlTab(i).quantity_required);
                            l_lot_serial_tbl(1).operation     := 'CREATE';
                            l_lot_serial_tbl(1).line_index    := j;
                        END IF;
			-- End Bug 8284773
                    /* ELSE
                        FND_MESSAGE.Set_Name('CS','CS_CHG_IB_MISSING_INSTANCE');
                        FND_MSG_PUB.Add;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */
                 END IF;
                END IF;


		/** Raise an error message , if the src_reference_reqd flag or the non_src_reference_reqd_flag
		    are 'Y',update_ib_flag is 'Y' and the instance_id is null ***/

		IF (l_src_reference_reqd = 'Y' OR
		   l_non_src_reference_reqd = 'Y') AND
		   l_update_ib_flag = 'Y' AND
		   EstDtlTab(i).customer_product_id IS NULL THEN

		   FND_MESSAGE.Set_Name('CS','CS_CHG_IB_MISSING_INSTANCE');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

		--
                -- Clear IB structures
                --
                csi_txn_line_rec := csi_txn_line_rec_null;
                csi_txn_line_detail_tbl.delete;
                csi_txn_party_detail_tbl.delete;
                csi_txn_pty_acct_detail_tbl.delete;
                csi_txn_ii_rltns_tbl.delete;
                csi_txn_org_assgn_tbl.delete;
                csi_txn_ext_attrib_vals_tbl.delete;
                csi_txn_systems_tbl.delete;
                l_internal_party_id := null;
                l_instance_party_id := null;

                --
                -- Create Transaction Line Record
                --
                csi_txn_line_rec.source_transaction_table := 'OE_ORDER_LINES_ALL';
                csi_txn_line_rec.source_transaction_type_id := l_source_type_id;

                --
                --  Create IB Transaction Line Detail and Relationship Record(s)
                -- Fix for bug:3564034
                IF EstDtlTab(i).line_category_code = 'RETURN'  and
		   EstDtlTab(i).customer_product_id is not null then
                    csi_txn_line_detail_tbl(1).sub_type_id  := l_sub_type_id;
                    csi_txn_line_detail_tbl(1).source_transaction_flag := 'Y';

                    IF  (l_src_reference_reqd = 'Y' OR
			 l_src_reference_reqd = 'N') AND
			(EstDtlTab(i).Customer_product_id is not null) THEN
                        csi_txn_line_detail_tbl(1).instance_id := EstDtlTab(i).Customer_Product_Id;
                        csi_txn_line_detail_tbl(1).instance_exists_flag := 'Y';
		        -- Bug 8203856
			open get_parent_instance(EstDtlTab(i).Customer_Product_Id);
			Fetch get_parent_instance into l_parent_instance_id;
			If get_parent_instance%FOUND Then
			   csi_txn_line_detail_tbl(1).parent_instance_id := l_parent_instance_id;
			End If;
			Close get_parent_instance;
			-- End Bug 8203856
                    ELSE
                        FND_MESSAGE.Set_Name('CS','CS_CHG_IB_INVALID_RET_TXN_DATA');
                        FND_MSG_PUB.Add;
			FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              	  p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        -- null;

                    END IF;

                    IF EstDtlTab(i).Item_revision is not null THEN
                        csi_txn_line_detail_tbl(1).inventory_revision := EstDtlTab(i).Item_revision;
                    ELSE
                        csi_txn_line_detail_tbl(1).inventory_revision := FND_API.G_MISS_CHAR;
                    END IF;

                    csi_txn_line_detail_tbl(1).inventory_item_id   := EstDtlTab(i).Inventory_Item_id;
                    csi_txn_line_detail_tbl(1).inv_organization_id := CS_STD.Get_Item_Valdn_Orgzn_ID;
                    csi_txn_line_detail_tbl(1).unit_of_measure     := EstDtlTab(i).unit_of_measure_code;
                    csi_txn_line_detail_tbl(1).quantity            := abs(EstDtlTab(i).quantity_required);

                    IF EstDtlTab(i).installed_cp_return_by_date is not null THEN
                        csi_txn_line_detail_tbl(1).return_by_date := EstDtlTab(i).installed_cp_return_by_date;
                    ELSE
                        csi_txn_line_detail_tbl(1).return_by_date := FND_API.G_MISS_DATE;
                    END IF;

                ELSE  -- Shipment Line
                    csi_txn_line_detail_tbl(1).sub_type_id  := l_sub_type_id;
                    csi_txn_line_detail_tbl(1).source_transaction_flag := 'Y';

                    csi_txn_line_detail_tbl(1).instance_id := FND_API.G_MISS_NUM;
                    csi_txn_line_detail_tbl(1).instance_exists_flag := 'N';

                    IF EstDtlTab(i).Item_revision is not null THEN
                        csi_txn_line_detail_tbl(1).inventory_revision := EstDtlTab(i).Item_revision;
                    ELSE
                        csi_txn_line_detail_tbl(1).inventory_revision := FND_API.G_MISS_CHAR;
                    END IF;

                    csi_txn_line_detail_tbl(1).inventory_item_id   := EstDtlTab(i).Inventory_Item_id;
                    csi_txn_line_detail_tbl(1).inv_organization_id := CS_STD.Get_Item_Valdn_Orgzn_ID;
                    csi_txn_line_detail_tbl(1).unit_of_measure     := EstDtlTab(i).unit_of_measure_code;
                    csi_txn_line_detail_tbl(1).quantity            := abs(EstDtlTab(i).quantity_required);

/*
-- Bug 4586140
                    IF l_src_return_reqd_flag = 'Y' THEN
                      IF EstDtlTab(i).installed_cp_return_by_date is not null THEN
                        csi_txn_line_detail_tbl(1).return_by_date := EstDtlTab(i).installed_cp_return_by_date;
                      ELSE
                        csi_txn_line_detail_tbl(1).return_by_date := FND_API.G_MISS_DATE;
                      END IF;
                    END IF;
*/
 -- Commented the above and uncommented the below IF block for Bug# 5136853.
                      IF EstDtlTab(i).new_cp_return_by_date is not null THEN
                          csi_txn_line_detail_tbl(1).return_by_date := EstDtlTab(i).new_cp_return_by_date;
                      ELSE
                          csi_txn_line_detail_tbl(1).return_by_date := FND_API.G_MISS_DATE;
                      END IF;

                    -- Referenced IB (non-source)
                    IF l_non_src_reference_reqd = 'Y'
	            OR l_non_src_reference_reqd = 'N'
                   AND EstDtlTab(i).Customer_product_id is not null THEN
                        csi_txn_line_detail_tbl(2).sub_type_id  := l_sub_type_id;
                        csi_txn_line_detail_tbl(2).source_transaction_flag := 'N';

                        IF EstDtlTab(i).Customer_product_id is not null THEN
                            csi_txn_line_detail_tbl(2).instance_id := EstDtlTab(i).Customer_Product_Id;
                            csi_txn_line_detail_tbl(2).instance_exists_flag := 'Y';
			     -- Bug 8203856
			    open get_parent_instance(EstDtlTab(i).Customer_Product_Id);
			    Fetch get_parent_instance into l_parent_instance_id;
			    If get_parent_instance%FOUND Then
			       csi_txn_line_detail_tbl(2).parent_instance_id := l_parent_instance_id;
			    End If;
			    Close get_parent_instance;
			    -- End Bug 8203856
			    -- fix bug:3593660
                            csi_txn_line_detail_tbl(2).assc_txn_line_detail_id := 1;

			/* Do not raise any error message if instance is missing.New 11.5.10 changes */

			  /* ELSE
                            FND_MESSAGE.Set_Name('CS','CS_CHG_IB_INVALID_SHP_TXN_DATA');
                            FND_MSG_PUB.Add;
			    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              	  p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */
                        END IF;

/* BUG 4287842 for a loaner shipment, installation details should display the ITEM for which the instance_number was selected. Currently it displays the Item irrespective of the reference number*/

              OPEN  get_inv_item_id(EstDtlTab(i).customer_product_id);
              FETCH get_inv_item_id
              INTO  l_inventory_item_id;
              CLOSE get_inv_item_id;
                        csi_txn_line_detail_tbl(2).inventory_item_id   := l_inventory_item_id;
                        csi_txn_line_detail_tbl(2).inv_organization_id := CS_STD.Get_Item_Valdn_Orgzn_ID;
                        csi_txn_line_detail_tbl(2).unit_of_measure     := EstDtlTab(i).unit_of_measure_code;
                        csi_txn_line_detail_tbl(2).quantity            := abs(EstDtlTab(i).quantity_required);

                        /*
                        IF EstDtlTab(i).Item_revision is not null THEN
                            csi_txn_line_detail_tbl(2).inventory_revision := EstDtlTab(i).Item_revision;
                        ELSE
                            csi_txn_line_detail_tbl(2).inventory_revision := FND_API.G_MISS_CHAR;
                        END IF;
                        */

 -- Uncommented the below IF block for Bug# 5136853.
                        IF EstDtlTab(i).installed_cp_return_by_date is not null THEN
                            csi_txn_line_detail_tbl(2).return_by_date := EstDtlTab(i).installed_cp_return_by_date;
                        ELSE
                            csi_txn_line_detail_tbl(2).return_by_date := FND_API.G_MISS_DATE;
                        END IF;


                        -- Create relationship between two txn line detail records
                        csi_txn_ii_rltns_tbl(1).subject_id := 2;
                        csi_txn_ii_rltns_tbl(1).object_id  := 1;
                        csi_txn_ii_rltns_tbl(1).relationship_type_code := 'REPLACED-BY';

                    END IF;  -- IF l_non_src_reference_reqd = 'Y'
                END IF;  -- IF EstDtlTab(i).line_category_code = 'RETURN'

                  --
                  --  Create IB Party details and account details records,when p_account_id is not null.
                  --
                IF EstDtlTab(i).account_id IS NOT NULL THEN
                    IF EstDtlTab(i).line_category_code = 'RETURN' then
                        IF l_src_change_owner = 'Y' THEN
                            IF l_src_change_owner_to_code = 'I' THEN
                                BEGIN
                                    SELECT internal_party_id
                                    INTO   l_internal_party_id
                                    FROM   csi_install_parameters
                                    WHERE  rownum = 1;

                                    IF l_internal_party_id is null THEN
                                        RAISE l_IB_ERROR;
                                    END IF;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            FND_MESSAGE.Set_Name('CS','CS_CHG_INTERNAL_PARTY_NOT_DEF');
                                            FND_MSG_PUB.Add;
					    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              			      p_count => x_msg_count,
                                              			      p_data  => x_msg_data);
                                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                END;

				-- Start Bug 8209077
				DECLARE
				  CURSOR c_instance_party is
				   SELECT instance_party_id,
				          relationship_type_code
                                   FROM   CSI_I_PARTIES
                                   WHERE  instance_id = EstDtlTab(i).Customer_Product_Id
                                   --AND    relationship_type_code = 'OWNER'  -- Bug 8209077
                                   AND    party_id = (SELECT party_id
                                   FROM   hz_cust_accounts
                                   WHERE  cust_account_id = EstDtlTab(i).account_id);

				   k Number;

				BEGIN
				   k := 0;
				   For i in c_instance_party loop
				      k := k + 1;
				      csi_txn_party_detail_tbl(k).instance_party_id  := i.instance_party_id;
                                      csi_txn_party_detail_tbl(k).party_source_table := 'HZ_PARTIES';
                                      csi_txn_party_detail_tbl(k).party_source_id    := l_internal_party_id;
                                      csi_txn_party_detail_tbl(k).relationship_type_code := i.relationship_type_code;
                                      csi_txn_party_detail_tbl(k).txn_line_details_index := k;
                                      csi_txn_party_detail_tbl(k).contact_flag := 'N';
                                      --csi_txn_pty_acct_detail_tbl.delete;
				   End loop;
				End;

                              /*  BEGIN
                                   SELECT instance_party_id
                                   INTO   l_instance_party_id
                                   FROM   CSI_I_PARTIES
                                   WHERE  instance_id = EstDtlTab(i).Customer_Product_Id
                                   AND    relationship_type_code = 'OWNER'
                                   AND    party_id = (SELECT party_id
                                   FROM   hz_cust_accounts
                                   WHERE  cust_account_id = EstDtlTab(i).account_id);

                                   EXCEPTION
                                       WHEN OTHERS THEN
                                           FND_MESSAGE.Set_Name('CS','CS_CHG_INSTANCE_NOT_OWN_BY_PTY');
                                           FND_MSG_PUB.Add;
					   FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              			     p_count => x_msg_count,
                                              			     p_data  => x_msg_data);
                                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                END;

                                csi_txn_party_detail_tbl(1).instance_party_id  := l_instance_party_id;
                                csi_txn_party_detail_tbl(1).party_source_table := 'HZ_PARTIES';
                                csi_txn_party_detail_tbl(1).party_source_id    := l_internal_party_id;
                                csi_txn_party_detail_tbl(1).relationship_type_code := 'OWNER';
                                csi_txn_party_detail_tbl(1).txn_line_details_index := 1;
                                csi_txn_party_detail_tbl(1).contact_flag := 'N';*/
                                csi_txn_pty_acct_detail_tbl.delete;
                            ELSE
                              FND_MESSAGE.Set_Name('CS','CS_CHG_RTN_TO_EXT_PTY_NOT_SUP');
                              FND_MSG_PUB.Add;
			      FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              		p_count => x_msg_count,
                                              		p_data  => x_msg_data);
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                            END IF;  --  IF l_src_change_owner_to_code = 'I'

                     --taklam
                     ---NEW CODE
                        ELSIF l_src_change_owner = 'N' AND l_src_change_owner_to_code is NULL THEN
                              BEGIN
                                 SELECT internal_party_id
                                 INTO   l_internal_party_id
                                 FROM   csi_install_parameters
                                 WHERE  rownum = 1;


                                 IF l_internal_party_id is null THEN
                                    RAISE l_IB_ERROR;
                                 END IF;
                                    EXCEPTION
                                    WHEN OTHERS THEN
                                       FND_MESSAGE.Set_Name('CS','CS_CHG_INTERNAL_PARTY_NOT_DEF');
                                       FND_MSG_PUB.Add;
                                       FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                       p_count => x_msg_count,
                                       p_data  => x_msg_data);
                                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END;

			      -- Start Bug 8209077
			      DECLARE
			         Cursor c_instance_party1 is
			         SELECT instance_party_id,
				        relationship_type_code
                                 FROM   CSI_I_PARTIES
                                 WHERE  instance_id = EstDtlTab(i).Customer_Product_Id
                                 --AND    relationship_type_code = 'OWNER'
                                 AND    party_id  IN (l_internal_party_id,EstDtlTab(i).customer_id);

				 k number;
                              BEGIN
                              IF EstDtlTab(i).Customer_Product_Id is not NULL THEN
			         k := 0;

			         For i in c_instance_party1 loop
				    k := k + 1;
				    csi_txn_party_detail_tbl(k).instance_party_id  := i.instance_party_id;
                                    csi_txn_party_detail_tbl(k).party_source_table := 'HZ_PARTIES';
				    csi_txn_party_detail_tbl(k).party_source_id    := l_internal_party_id;
				    csi_txn_party_detail_tbl(k).relationship_type_code := i.relationship_type_code;
				    csi_txn_party_detail_tbl(k).txn_line_details_index := k;
				    csi_txn_party_detail_tbl(k).contact_flag := 'N';
				 End Loop;

                             /* BEGIN
                              IF EstDtlTab(i).Customer_Product_Id is not NULL THEN
                                 SELECT instance_party_id
                                 INTO   l_instance_party_id
                                 FROM   CSI_I_PARTIES
                                 WHERE  instance_id = EstDtlTab(i).Customer_Product_Id
                                 AND    relationship_type_code = 'OWNER'
                                 AND    party_id  IN (l_internal_party_id,EstDtlTab(i).customer_id);*/
                              ELSE
                              NULL; -- submit successful. But, do not create installation details.
                              END IF;

                             /* EXCEPTION
                                 WHEN OTHERS THEN
                                 FND_MESSAGE.Set_Name('CS','CS_CHG_INSTANCE_NOT_OWN_BY_PTY');
                                 FND_MSG_PUB.Add;
                                 FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data);
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;*/
                              END;
/*
                              csi_txn_party_detail_tbl(1).instance_party_id  := l_instance_party_id;
                              csi_txn_party_detail_tbl(1).party_source_table := 'HZ_PARTIES';
                              csi_txn_party_detail_tbl(1).party_source_id    := l_internal_party_id;
                              csi_txn_party_detail_tbl(1).relationship_type_code := 'OWNER';
                              csi_txn_party_detail_tbl(1).txn_line_details_index := 1;
                              csi_txn_party_detail_tbl(1).contact_flag := 'N';*/
                              csi_txn_pty_acct_detail_tbl.delete;
                        --taklam

                        ELSE
                            csi_txn_party_detail_tbl.delete;
                            csi_txn_pty_acct_detail_tbl.delete;
                        END IF;  --  IF l_src_change_owner = 'Y'

                    ELSE -- shipment line
                      IF l_src_change_owner = 'Y' THEN
                        -- Create Party record
                        csi_txn_party_detail_tbl(1).party_source_table := 'HZ_PARTIES';
                        csi_txn_party_detail_tbl(1).party_source_id    := EstDtlTab(i).customer_id;
                        csi_txn_party_detail_tbl(1).relationship_type_code := 'OWNER';
                        csi_txn_party_detail_tbl(1).txn_line_details_index := 1;
                        csi_txn_party_detail_tbl(1).contact_flag := 'N';

                        -- Create Account record
                        csi_txn_pty_acct_detail_tbl(1).account_id           := EstDtlTab(i).account_id;
                        csi_txn_pty_acct_detail_tbl(1).relationship_type_code  := 'OWNER';
                        csi_txn_pty_acct_detail_tbl(1).txn_party_details_index := 1;
                        csi_txn_pty_acct_detail_tbl(1).active_start_date       := sysdate;
                      END IF;
                    END IF; -- IF EstDtlTab(i).line_category_code = 'RETURN'

                END IF; --IF account_id is not null.

	END IF; -- IF Update_Ib_Flag = Y

        END IF;  -- If COMMS_NL_TRACKABLE_FLAG = Y

        --
  -- The ASO debug statements are replaced with the FND Logging

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , '==================================================='
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Beginning Charges submission'
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Item revision is: ' || EstDtlTab(i).item_revision
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Estimate Detail_id is: '  || EstDtlTab(i).estimate_detail_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Selling_price: '|| EstDtlTab(i).selling_price
    ) ;
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'After Warranty Cost: ' || EstDtlTab(i).after_warranty_cost
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Incident Id is: '|| EstDtlTab(i).incident_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Charges Invoice to party site id: ' || EstDtlTab(i).invoice_to_org_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Charges Ship to party site id: ' || EstDtlTab(i).ship_to_org_id
    );
/* Credit Card 9358401 */
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Charges Ship to Instr Assignment id: ' || EstDtlTab(i).instrument_payment_use_id
    );
/* Credit Card 9358401 */
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , ' '
    );

    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_control_rec.book_flag is: ' || l_control_rec.book_flag
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_control_rec.calculate_price is: ' || l_control_rec.calculate_price
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.Order_id is: '|| l_header_rec.order_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.Order_type_id is: '|| l_header_rec.order_type_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.quote_source_code is: '|| l_header_rec.quote_source_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute1  is: '|| l_header_rec.attribute1
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute2  is: '|| l_header_rec.attribute2
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute3  is: '|| l_header_rec.attribute3
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute4  is: '|| l_header_rec.attribute4
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute5  is: '|| l_header_rec.attribute5
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute6  is: '|| l_header_rec.attribute6
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute7  is: '|| l_header_rec.attribute7
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute8  is: '|| l_header_rec.attribute8
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute9  is: '|| l_header_rec.attribute9
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute10 is: '|| l_header_rec.attribute10
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute11 is: '|| l_header_rec.attribute11
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute12 is: '|| l_header_rec.attribute12
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute13 is: '|| l_header_rec.attribute13
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute14 is: '|| l_header_rec.attribute14
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.attribute15 is: '|| l_header_rec.attribute15
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.Org_Id is: '|| l_header_rec.org_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.party_id (Customer_id) is: ' || l_header_rec.party_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.cust_account_id (Customer_account_id) is: ' || l_header_rec.cust_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.quote_header_id is: ' || l_header_rec.quote_header_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.original_system_reference is: ' || l_header_rec.original_system_reference
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.quote_number is: ' || l_header_rec.quote_number
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.exchange_rate is: '|| l_header_rec.exchange_rate
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.exchange_type_code is: '|| l_header_rec.exchange_type_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.exchange_rate_date is: '|| l_header_rec.exchange_rate_date
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.price_list_id is: ' || l_header_rec.price_list_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_header_rec.currency_code is: ' || l_header_rec.currency_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_Header_rec.invoice_to_cust_account_id: ' || l_header_rec.invoice_to_cust_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_Header_rec.invoice_to_party_id: ' || l_header_rec.invoice_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_Header_rec.invoice_to_party_site_id: ' || l_header_rec.invoice_to_party_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Update_Ib_Flag: ' || l_update_ib_flag
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Src_Reference_Reqd_Flag: ' || l_src_reference_reqd
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Non_Src_Reference_Reqd_Flag: ' || l_non_src_reference_reqd
    );

            if l_hd_payment_tbl.count = 0  then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_payment_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_payment_tbl.cust_po_number is: '|| l_hd_payment_tbl(j).cust_po_number
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_payment_tbl.payment_type_code is: '|| l_hd_payment_tbl(j).payment_type_code
    );
            end if;

            if l_hd_shipment_tbl.count = 0  then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_shipment_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_shipment_tbl.ship_to_cust_account_id: ' || l_hd_shipment_tbl(j).ship_to_cust_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_shipment_tbl.ship_to_party_id: ' || l_hd_shipment_tbl(j).ship_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_hd_shipment_tbl.ship_to_party_site_id: ' || l_hd_shipment_tbl(j).ship_to_party_site_id
    );
            end if;

   if l_line_tbl.count = 0  then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.operation_code is: '|| l_line_tbl(j).operation_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.inventory_item_id is: ' || l_line_tbl(j).inventory_item_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.UOM_code is: ' || l_line_tbl(j).UOM_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.order_line_type_id is: ' || l_line_tbl(j).order_line_type_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.quantity is: ' || l_line_tbl(j).quantity
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.quote_line_id is: ' || l_line_tbl(j).quote_line_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.price_list_id is: ' || l_line_tbl(j).price_list_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.line_list_price is: ' || l_line_tbl(j).line_list_price
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.line_quote_price is: ' || l_line_tbl(j).line_quote_price
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.line_category_code is: ' || l_line_tbl(j).line_category_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.invoice_to_cust_account_id: ' || l_line_tbl(j).invoice_to_cust_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.invoice_to_party_id: ' || l_line_tbl(j).invoice_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_tbl.invoice_to_party_site_id: ' || l_line_tbl(j).invoice_to_party_site_id
    );
            end if;

            if l_ln_shipment_tbl.count = 0 then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.operation_code is: '|| l_ln_shipment_tbl(j).operation_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.ship_to_cust_account_id: ' || l_ln_shipment_tbl(j).ship_to_cust_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.ship_to_party_id: ' || l_ln_shipment_tbl(j).ship_to_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.ship_to_party_site_id: ' || l_ln_shipment_tbl(j).ship_to_party_site_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.quote_line_id is: ' || l_ln_shipment_tbl(j).quote_line_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.quote_header_id is: ' || l_ln_shipment_tbl(j).quote_header_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.quantity is: ' || l_ln_shipment_tbl(j).quantity
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_ln_shipment_tbl.qte_line_index is: ' || l_ln_shipment_tbl(j).qte_line_index
    );
            end if;

            if l_line_dtl_tbl.count = 0  then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_dtl_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_dtl_tbl.return_reason_code is: ' || l_line_dtl_tbl(j).return_reason_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_dtl_tbl.qte_line_index is: ' || l_line_dtl_tbl(j).qte_line_index
    );
            end if;

            if l_line_price_adj_tbl.count = 0 then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.operation_code is: ' || l_line_price_adj_tbl(j).operation_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.qte_line_index is: ' || l_line_price_adj_tbl(j).qte_line_index
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.modifier_header_id is: ' || l_line_price_adj_tbl(j).modifier_header_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.modifier_line_id is: ' || l_line_price_adj_tbl(j).modifier_line_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.operand is: ' || l_line_price_adj_tbl(j).operand
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.adjusted_amount is: ' || l_line_price_adj_tbl(j).adjusted_amount
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.updated_flag is: ' || l_line_price_adj_tbl(j).updated_flag
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.applied_flag is: ' || l_line_price_adj_tbl(j).applied_flag
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.change_reason_code is: ' || l_line_price_adj_tbl(j).change_reason_code
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_line_price_adj_tbl.change_reason_text is: ' || l_line_price_adj_tbl(j).change_reason_text
    );
            end if;

            if l_lot_serial_tbl.count = 0  then
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl does not exist'
    );
            else
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.lot_number is: ' || l_lot_serial_tbl(1).lot_number
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.lot_serial_id is: ' || l_lot_serial_tbl(1).lot_serial_id
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.quantity is: ' || l_lot_serial_tbl(1).quantity
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.from_serial_number is: ' || l_lot_serial_tbl(1).from_serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.to_serial_number is: ' || l_lot_serial_tbl(1).to_serial_number
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.operation is: ' || l_lot_serial_tbl(1).operation
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'l_lot_serial_tbl.line_index is: ' || l_lot_serial_tbl(1).line_index
    );
            end if;

    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , 'Ending Charges submission'
    );
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE , '==================================================='
    );

  END IF;


  -- Validate the ship to customer account site and account site use are correct.
  validate_acct_site_uses(
    p_org_id            => EstDtlTab(i).org_id,
    p_party_site_id     => EstDtlTab(i).ship_to_org_id,
    p_account_id        => l_ship_to_cust_account_id,
    p_site_use_code     => 'SHIP_TO',
    x_msg_data          => x_msg_data,
    x_msg_count         => x_msg_count,
    x_return_status     => x_return_status);

  -- dbms_output.put_line('In the validate_acct_site_call');
  -- dbms_output.put_line('Return_Status' || x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate the bill to customer account site and account site use are correct.
  validate_acct_site_uses(
    p_org_id            => EstDtlTab(i).org_id,
    p_party_site_id     => EstDtlTab(i).invoice_to_org_id,
    p_account_id        => l_invoice_to_cust_account_id,
    p_site_use_code     => 'BILL_TO',
    x_msg_data          => x_msg_data,
    x_msg_count         => x_msg_count,
    x_return_status     => x_return_status);

  -- dbms_output.put_line('In the validate_acct_site_call2');
  -- dbms_output.put_line('Return_Status2' || x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                              p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --

-- r12 code start

    IF (MO_GLOBAL.check_valid_org(l_org_id) ='N')
    THEN
        FND_MSG_PUB.initialize;
        FND_MESSAGE.Set_Name('CS','CS_CHG_NEW_CONTEXT_OU_MISMATCH')  ;
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full)  ;
        FND_MSG_PUB.Add  ;
        raise FND_API.G_EXC_ERROR  ;
    END IF;

mo_global.set_policy_context('S',l_org_id);

-- end r12
/* Credit Card 9358401 */
    IF EstDtlTab(i).instrument_payment_use_id is not null then
      BEGIN
	   SELECT INSTRUMENT_ID
	     INTO l_ln_payment_tbl(j).instrument_id
	     FROM iby_pmt_instr_uses_all
         WHERE INSTRUMENT_PAYMENT_USE_ID =
	                                EstDtlTab(i).instrument_payment_use_id;

        l_ln_payment_tbl(j).instr_assignment_id :=
                                     EstDtlTab(i).instrument_payment_use_id;

	 EXCEPTION
	 WHEN OTHERS THEN
	  NULL;
	 END;
    END IF;


        -- CALL OC'S CREATE_ORDER API FOR CREATING A NEW ORDER
        -- UPDATE ORDER API FOR ADDING TO AN EXISTING ORDER

        IF (EstDtlTab(i).add_to_order_flag = 'F') THEN

         ASO_ORDER_INT.Create_order(
                    P_Api_Version_Number    => 1.0,
                    P_Qte_Rec               =>  l_header_rec,
                    P_Header_Shipment_Tbl   =>  l_hd_shipment_tbl,
                    P_Qte_Line_Tbl          =>  l_line_tbl,
                    P_Qte_Line_Dtl_Tbl      =>  l_line_dtl_tbl,
                    P_Line_Shipment_Tbl     =>  l_ln_shipment_tbl,
                    P_Header_Payment_Tbl    =>  l_hd_payment_tbl,
                    P_Line_Payment_Tbl      =>  l_ln_payment_tbl,/* Credit Card 9358401 */
                    P_Line_Price_Adj_Tbl	=>  l_line_price_adj_tbl,
                    P_Lot_Serial_Tbl        =>  l_lot_serial_tbl,
                    P_Control_Rec	        =>  l_control_rec,
                    X_Order_Header_Rec      =>  x_order_header_rec,
                    X_Order_Line_Tbl        =>  x_order_line_tbl,
                    X_Return_Status         =>  x_return_status,
                    X_Msg_Count             =>  x_msg_count,
                    X_Msg_Data              =>  x_msg_data
                    );

       ELSIF (EstDtlTab(i).add_to_order_flag = 'Y') or
                        (l_order_header_id <> -999)  THEN

         -- dbms_output.put_line('Calling Update_Order');

            ASO_ORDER_INT.Update_order(
                    P_Api_Version_Number    => 1.0,
                    P_Qte_Rec               =>  l_header_rec,
                    P_Qte_Line_Tbl          =>  l_line_tbl,
                    P_Qte_Line_Dtl_Tbl      =>  l_line_dtl_tbl,
                    P_Line_Shipment_Tbl     =>  l_ln_shipment_tbl,
                    P_Header_Payment_Tbl    =>  l_hd_payment_tbl,
                    P_Line_Payment_Tbl      =>  l_ln_payment_tbl,/* Credit Card 9358401 */
                    P_Line_Price_Adj_Tbl	=>  l_line_price_adj_tbl,
                    P_Lot_Serial_Tbl        =>  l_lot_serial_tbl,
                    P_Control_Rec	        =>  l_control_rec,
                    X_Order_Header_Rec      =>  x_order_header_rec,
                    X_Order_Line_Tbl        =>  x_order_line_tbl,
                    X_Return_Status         =>  x_return_status,
                    X_Msg_Count             =>  x_msg_count,
                    X_Msg_Data              =>  x_msg_data
                    );
        ELSE

          -- dbms_output.put_line('Calling Create_Order');

            ASO_ORDER_INT.Create_order(
                    P_Api_Version_Number    => 1.0,
                    P_Qte_Rec               =>  l_header_rec,
                    P_Header_Shipment_Tbl   =>  l_hd_shipment_tbl,
                    P_Qte_Line_Tbl          =>  l_line_tbl,
                    P_Qte_Line_Dtl_Tbl      =>  l_line_dtl_tbl,
                    P_Line_Shipment_Tbl     =>  l_ln_shipment_tbl,
                    P_Header_Payment_Tbl    =>  l_hd_payment_tbl,
                    P_Line_Payment_Tbl      =>  l_ln_payment_tbl,/* Credit Card 9358401 */
                    P_Line_Price_Adj_Tbl	=>  l_line_price_adj_tbl,
                    P_Lot_Serial_Tbl        =>  l_lot_serial_tbl,
                    P_Control_Rec	        =>  l_control_rec,
                    X_Order_Header_Rec      =>  x_order_header_rec,
                    X_Order_Line_Tbl        =>  x_order_line_tbl,
                    X_Return_Status         =>  x_return_status,
                    X_Msg_Count             =>  x_msg_count,
                    X_Msg_Data              =>  x_msg_data
                    );

        END IF; -- Add_To_Order


     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            -- moved this to elsif below.
            -- X_ORDER_HEADER_ID := X_ORDER_HEADER_REC.ORDER_HEADER_ID;

            IF X_ORDER_HEADER_REC.ORDER_HEADER_ID IS NULL THEN
                FND_MESSAGE.Set_Name('CS','CS_CHG_NO_ORD_NUM_RETURNED');
                FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
                FND_MSG_PUB.Add;
    		FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
               		                  p_count => x_msg_count,
                              		  p_data  => x_msg_data);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               -- Need to verify if we need to trap this error message
	       --

             ELSIF X_ORDER_HEADER_REC.ORDER_HEADER_ID IS NOT NULL THEN
                X_ORDER_HEADER_ID := X_ORDER_HEADER_REC.ORDER_HEADER_ID;
             END IF;
            -- Moving this to after IB call so that the record is not locked
            -- fix bug:3545283
            /* FOR k in 1..x_order_line_tbl.count LOOP

            -- UPDATE ESTIMATE_DETAILS WITH ORDER_HEADER_ID AND ORDER_LINE_ID.
            -- Changes for 11.5.10.
            -- NULL Values should be passed for submit_error_message,
            -- submit_restriction_message and line_submitted columns as the
            -- order creation is successful.

   		      Update_Estimate_Details(EstDtlTab(i).estimate_detail_id,
                           		      x_order_header_id,
                         		      x_order_line_tbl(k).order_line_id,
			 		      NULL,
                         		      NULL,
                         		      NULL,
                                              p_submit_from_system);


            END LOOP; */

            -- Initialize xi_return_status.

            xi_return_status := FND_API.G_RET_STS_SUCCESS;

/* This will call the wrapper API to raise the Business Event oracle.apps.cs.chg.Charges.submitted
   and their subscriptions.
   All the custom code exists in the subscriptions/rule functions
   created by customers, which should be subscribed to this charges event in
   order to execute their code.
   Presently we are not shipping any seeded subscriptions.
   Some parameters were initialized to NULL , which will be changed later.
   As there are no workflows attached to this, l_workflow_process_id is not required for
   processing.
   The mandatory parameters are event code(SUBMIT_CHARGES) and
   event key(estimate_detail_id). l_charges_rec_type can utilized for future modifications*/

   l_charges_rec_type.incident_id  := EstDtlTab(i).incident_id;
   l_charges_rec_type.org_id       := EstDtlTab(i).org_id;
   wf_resp_appl_id                 := FND_GLOBAL.RESP_APPL_ID;
   wf_resp_id                      := FND_GLOBAL.RESP_ID;
   wf_user_id                      := FND_GLOBAL.USER_ID;

CS_CHG_WF_EVENT_PKG.RAISE_SUBMITCHARGES_EVENT(
         p_api_version           => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         p_commit                => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_event_code            => 'SUBMIT_CHARGES',
         p_estimate_detail_id    => EstDtlTab(i).Estimate_Detail_Id,
         p_USER_ID               => wf_user_id,
         p_RESP_ID               => wf_resp_id,
         p_RESP_APPL_ID          => wf_resp_appl_id,
         p_est_detail_rec        => l_charges_rec_type,
         p_wf_process_id         => NULL,
         p_owner_id              => NULL,
         p_wf_manual_launch      => 'N' ,
         x_wf_process_id         => l_workflow_process_id,
         x_return_status         => lx_return_status,
         x_msg_count             => lx_msg_count,
         x_msg_data              => lx_msg_data );

if ( lx_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         -- do nothing in this API. The BES wrapper API will have to trap this
         -- situation.
         null;
      end if;

     -- Installbase Call if the Order creation is successful
     --
            --IF EstDtlTab(i).billing_type = 'M' THEN
            IF EstDtlTab(i).billing_category = 'M' THEN
                -- 11.5.6 Installation details call
           -- Bug fix:3564034
           -- Create installtion details if an instance is available and update_ib_flag = 'Y'
	   --
          IF (EstDtlTab(i).comms_nl_trackable_flag = 'Y')
	    -- commented for the bug:3800010
	     -- and (EstDtlTab(i).customer_product_id IS NOT NULL)
	     and l_update_ib_flag = 'Y' THEN

	     -- assign order line id to source transaction id.
               csi_txn_line_rec.source_transaction_id := x_order_line_tbl(1).order_line_id;

               --Checking for account_id.If account_id is null then we need to derive one
               --created by OC.
                    IF EstDtlTab(i).account_id is null then
                        BEGIN
                            SELECT cust_account_id
                            INTO l_account_id
                            FROM hz_cust_accounts_all
                            WHERE party_id = p_party_id
                                    AND status = 'A';
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                FND_MESSAGE.Set_Name('CS','CS_CHG_NO_ACCT_CREATED');
                                FND_MSG_PUB.Add;

				FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              		  p_count => x_msg_count,
                                              		  p_data  => x_msg_data);
                        END;
                        --
                        --  Create IB Party details and account details records
                        --
                        IF EstDtlTab(i).line_category_code = 'RETURN' then
                            IF l_src_change_owner = 'Y' THEN
                                IF l_src_change_owner_to_code = 'I' THEN

                                    BEGIN
                                        SELECT internal_party_id
                                        INTO   l_internal_party_id
                                        FROM   csi_install_parameters
                                        WHERE  rownum = 1;

                                        IF l_internal_party_id is null THEN
                                        RAISE l_IB_ERROR;
                                        END IF;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                             FND_MESSAGE.Set_Name('CS','CS_CHG_INTERNAL_PARTY_NOT_DEF');
                                             FND_MSG_PUB.Add;
                                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                    END;

                                    SELECT instance_party_id
                                    INTO   l_instance_party_id
                                    FROM   CSI_I_PARTIES
                                    WHERE  instance_id = EstDtlTab(i).Customer_Product_Id
                                    AND    relationship_type_code = 'OWNER'
                                    AND    party_id = (SELECT party_id
                                                        FROM   hz_cust_accounts
                                                        WHERE  cust_account_id = l_account_id);

                                    csi_txn_party_detail_tbl(1).instance_party_id  := l_instance_party_id;
                                    csi_txn_party_detail_tbl(1).party_source_table := 'HZ_PARTIES';
                                    csi_txn_party_detail_tbl(1).party_source_id    := l_internal_party_id;
                                    csi_txn_party_detail_tbl(1).relationship_type_code := 'OWNER';
                                    csi_txn_party_detail_tbl(1).txn_line_details_index := 1;
                                    csi_txn_party_detail_tbl(1).contact_flag := 'N';
                                    csi_txn_pty_acct_detail_tbl.delete;
                                ELSE
                                    FND_MESSAGE.Set_Name('CS','CS_CHG_RTN_TO_EXT_PTY_NOT_SUP');
                                    FND_MSG_PUB.Add;
			            FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              		      p_count => x_msg_count,
                                                              p_data  => x_msg_data);
                                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                                END IF;  --  IF l_src_change_owner_to_code = 'I'
                            ELSE
                                csi_txn_party_detail_tbl.delete;
                                csi_txn_pty_acct_detail_tbl.delete;
                            END IF;  --  IF l_src_change_owner = 'Y'

                        ELSE -- shipment line
                          IF l_src_change_owner = 'Y' THEN
                            -- Create Party record
                           csi_txn_party_detail_tbl(1).party_source_table := 'HZ_PARTIES';
                           csi_txn_party_detail_tbl(1).party_source_id    := EstDtlTab(i).customer_id;
                           csi_txn_party_detail_tbl(1).relationship_type_code := 'OWNER';
                           csi_txn_party_detail_tbl(1).txn_line_details_index := 1;
                           csi_txn_party_detail_tbl(1).contact_flag := 'N';

                            -- Create Account record
                           csi_txn_pty_acct_detail_tbl(1).account_id := l_account_id;
                           csi_txn_pty_acct_detail_tbl(1).relationship_type_code  := 'OWNER';
                           csi_txn_pty_acct_detail_tbl(1).txn_party_details_index := 1;
                           csi_txn_pty_acct_detail_tbl(1).active_start_date := sysdate;

                         END IF;

                      END IF; -- IF EstDtlTab(i).line_category_code = 'RETURN'

                    END IF; -- EstDtlTab.account_id is null

		   -- Bug 9312433
		   Open c_sub_type(l_sub_type_id);
		   Fetch c_sub_type into l_src_ref_reqd;
		   close c_sub_type;
                   --
                   --
		   -- fix for bug:3800010
                    IF EstDtlTab(i).line_category_code = 'RETURN' and
		    (nvl(l_src_ref_reqd,'N') = 'N' OR (l_src_ref_reqd = 'Y' AND EstDtlTab(i).customer_product_id IS NOT NULL)) THEN
                    --and (EstDtlTab(i).customer_product_id IS NOT NULL) THEN  -- commented for bug 9312433
                    -- Now call the create transaction Details API.
                    csi_t_txn_details_grp.create_transaction_dtls(
                                p_api_version              => 1.0,
                                p_commit                   => fnd_api.g_false,
                                p_init_msg_list            => fnd_api.g_false,
                                p_validation_level         => fnd_api.g_valid_level_full,
                                px_txn_line_rec            => csi_txn_line_rec ,
                                px_txn_line_detail_tbl     => csi_txn_line_detail_tbl,
                                px_txn_party_detail_tbl    => csi_txn_party_detail_tbl ,
                                px_txn_pty_acct_detail_tbl => csi_txn_pty_acct_detail_tbl,
                                px_txn_ii_rltns_tbl        => csi_txn_ii_rltns_tbl,
                                px_txn_org_assgn_tbl       => csi_txn_org_assgn_tbl,
                                px_txn_ext_attrib_vals_tbl => csi_txn_ext_attrib_vals_tbl,
                                px_txn_systems_tbl         => csi_txn_systems_tbl,
                                x_return_status            => x_return_status,
                                x_msg_count                => x_msg_count,
                                x_msg_data                 => x_msg_data);

		    ELSIF EstDtlTab(i).line_category_code = 'ORDER' THEN
                    -- Now call the create transaction Details API.
                    csi_t_txn_details_grp.create_transaction_dtls(
                                p_api_version              => 1.0,
                                p_commit                   => fnd_api.g_false,
                                p_init_msg_list            => fnd_api.g_false,
                                p_validation_level         => fnd_api.g_valid_level_full,
                                px_txn_line_rec            => csi_txn_line_rec ,
                                px_txn_line_detail_tbl     => csi_txn_line_detail_tbl,
                                px_txn_party_detail_tbl    => csi_txn_party_detail_tbl ,
                                px_txn_pty_acct_detail_tbl => csi_txn_pty_acct_detail_tbl,
                                px_txn_ii_rltns_tbl        => csi_txn_ii_rltns_tbl,
                                px_txn_org_assgn_tbl       => csi_txn_org_assgn_tbl,
                                px_txn_ext_attrib_vals_tbl => csi_txn_ext_attrib_vals_tbl,
                                px_txn_systems_tbl         => csi_txn_systems_tbl,
                                x_return_status            => x_return_status,
                                x_msg_count                => x_msg_count,
                                x_msg_data                 => x_msg_data);

		  END IF; -- fix bug:3800010

                END IF; -- comms_nl_trackable_flag

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                    FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                              p_count => x_msg_count,
                                              p_data  => x_msg_data);

                    -- dbms_output.put_line('message status' || x_return_status);
                    -- dbms_output.put_line('message_data' || substr(x_msg_data,1,200));
                    -- dbms_output.put_line('message_count' || x_msg_count);

                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    END IF;

                    -- FND_MESSAGE.Set_Encoded(xi_msg_data);
                    -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


            END IF;  -- if billing flag = 'M'


	   -- Update charge lines with order details
           -- Fix for bug:3545283

	    FOR k in 1..x_order_line_tbl.count LOOP

            -- UPDATE ESTIMATE_DETAILS WITH ORDER_HEADER_ID AND ORDER_LINE_ID.
            -- Changes for 11.5.10.
            -- NULL Values should be passed for submit_error_message,
            -- submit_restriction_message and line_submitted columns as the
            -- order creation is successful.

   		      Update_Estimate_Details(EstDtlTab(i).estimate_detail_id,
                           		      x_order_header_id,
                         		      x_order_line_tbl(k).order_line_id,
			 		      NULL,
                         		      NULL,
                         		      NULL,
                                              p_submit_from_system);


            END LOOP;
     --
     -- IF THE ORDER CREATION IS NOT SUCCESSFUL
     ELSIF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF x_msg_count > 0 THEN
                -- Get next message

		-- FND_MSG_PUB.initialize;
                /* FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                          p_count => x_msg_count,
                                          p_data  => x_msg_data); */

                for k in 1..x_msg_count loop
                    FND_MSG_PUB.get(p_encoded  => 'F',
                    p_data=>x_msg_data,
                    p_msg_index_out=>l_dummy);
	        end loop;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                /* for k in 1..x_msg_count loop
                    FND_MSG_PUB.get(p_encoded  => 'F',
                    p_data=>x_msg_data,
                    p_msg_index_out=>l_dummy);

                    -- changes for 11.5.10
                    msg_table(k) := x_msg_data;
                    temp_tab := (temp_tab || msg_table(k));


                end loop; */
                --
                -- Changes for 11.5.10
                -- Recording error messages in the Charges schema as an autonomous
                -- transaction.
                /* Update_Errors(p_estimate_detail_id  => EstDtlTab(i).estimate_detail_id,
                              p_line_submitted   => 'N',
                              p_submit_restriction_message => NULL,
                              p_submit_error_message  => temp_tab,
                              p_submit_from_system => p_submit_from_system); */

            END IF;  -- end of message count

            IF x_msg_count = 0 THEN
                 -- dbms_output.put_line('Before set_name');
                 FND_MESSAGE.Set_Name('CS','CS_CHG_OM_ERR_WITH_NO_MSG');
                 FND_MSG_PUB.Add;
		 FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                           p_count => x_msg_count,
                                           p_data  => x_msg_data);
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

            -- FND_MESSAGE.Set_Encoded(x_msg_data);
            -- FND_MSG_PUB.Add;
            -- RAISE FND_API.G_EXC_ERROR;

        END IF;

    END LOOP;
    Close Fetch_Est_Dtl;  -- Bug 7632716


     -- If no records are been submitted to OM, return a message.
     IF l_record_found = 'N' THEN
       FND_MESSAGE.Set_Name('CS','CS_CHG_NO_CHARGES_SUBMITTED');
       --FND_MESSAGE.SET_TOKEN('INCIDENT_ID', p_incident_id, TRUE);
       --FND_MESSAGE.SET_TOKEN('PARTY_ID', p_party_id, TRUE);
       --FND_MESSAGE.SET_TOKEN('ACCOUNT_ID', p_account_id, TRUE);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     --
     -- End of API body
     --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );


EXCEPTION
    -- This exception is for SR level
    --
    --7117301
    WHEN RESOURCE_BUSY THEN
       FND_MESSAGE.Set_Name('CS','CS_CH_SUBMIT_IN_PROCESS');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --7117301
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CS_Charge_Create_Order_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );

     --
     -- This exception is for Charge Line Level

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        -- updating charges schema with errors for 11.5.10
            --
            -- dbms_output.put_line('Charge_Line_Id before calling update_errors'  || EstDtlTab(i).estimate_detail_id);
            -- dbms_output.put_line('message data before calling update_errors'  || substr(x_msg_data,1,200));
                ROLLBACK TO CS_Charge_Create_Order_PVT; --7117301
            	Update_Errors(p_estimate_detail_id  => EstDtlTab(i).estimate_detail_id,
                              p_line_submitted   => 'N',
                              p_submit_restriction_message => NULL,
                              p_submit_error_message  => x_msg_data,
                              p_submit_from_system => p_submit_from_system);

             FND_MESSAGE.Set_Encoded(x_msg_data);
             --ROLLBACK TO CS_Charge_Create_Order_PVT; --7117301
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
        g_oraerrmsg := substrb(sqlerrm,1,G_MAXERRLEN);
        fnd_message.set_name('CS','CS_CHG_SUBMIT_ORDER_FAILED');
        fnd_message.set_token('ROUTINE',l_api_name_full);
        fnd_message.set_token('REASON',g_oraerrmsg);
        FND_MSG_PUB.Add;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;

          FND_MSG_PUB.Count_And_Get(p_encoded => 'F',
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data);

	    --
            -- Adding the error message to charges schema for 11.5.10
            --
	        ROLLBACK TO CS_Charge_Create_Order_PVT; --7117301
            	Update_Errors(p_estimate_detail_id  => EstDtlTab(i).estimate_detail_id,
                              p_line_submitted   => 'N',
                              p_submit_restriction_message => NULL,
                              p_submit_error_message  => x_msg_data,
                              p_submit_from_system => p_submit_from_system);

                FND_MESSAGE.Set_Encoded(x_msg_data);


        	--ROLLBACK TO CS_Charge_Create_Order_PVT; --7117301
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Submit_Order;

/***************************************************************************/
 -- Update Charges table.
/***************************************************************************/
PROCEDURE Update_Estimate_Details (
                 p_Estimate_Detail_Id           IN  NUMBER,
                 p_order_header_Id              IN  NUMBER,
                 p_order_line_Id                IN  NUMBER,
                 p_line_submitted               IN  VARCHAR2,
                 p_submit_restriction_message   IN	VARCHAR2,-- new
                 p_submit_error_message	        IN	VARCHAR2,-- new
                 p_submit_from_system 	        IN	VARCHAR2 -- new
                 ) IS

l_api_name          CONSTANT VARCHAR2(30)    := 'Update_Estimate_Details' ;
l_api_name_full     CONSTANT VARCHAR2(61)    :=  G_PKG_NAME || '.' || l_api_name ;
l_log_module        CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';

BEGIN

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_Estimate_Detail_Id:' || p_Estimate_Detail_Id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_order_header_Id:' || p_order_header_Id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_order_line_Id:' || p_order_line_Id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_line_submitted:' || p_line_submitted
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_restriction_message:' || p_submit_restriction_message
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_error_message:' || p_submit_error_message
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_from_system:' || p_submit_from_system
    );
  END IF;

      UPDATE CS_ESTIMATE_DETAILS
          SET Order_Header_Id = p_order_header_Id,
              Order_Line_Id   = p_order_line_Id,
              line_submitted  = p_line_submitted,
              submit_restriction_message = p_submit_restriction_message,
              submit_error_message = p_submit_error_message,
              submit_from_system = p_submit_from_system,
              last_update_date = sysdate,
	      last_update_login = fnd_global.login_id, --6027992
	      last_updated_by = fnd_global.user_id --6027992
       WHERE Estimate_Detail_Id = p_estimate_detail_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        Raise  No_Data_Found;

end Update_Estimate_Details;

End CS_Charge_Create_Order_PVT;

/
