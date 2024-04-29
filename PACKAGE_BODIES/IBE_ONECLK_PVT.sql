--------------------------------------------------------
--  DDL for Package Body IBE_ONECLK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ONECLK_PVT" AS
/* $Header: IBEVOCPB.pls 120.5 2006/05/16 04:56:29 knachiap ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ibe_oneclk_pvt';
l_true VARCHAR2(1) := FND_API.G_TRUE;

procedure Submit_Quotes(
 errbuf OUT NOCOPY VARCHAR2,
 retcode OUT NOCOPY NUMBER
) is

 l_api_name    CONSTANT VARCHAR2(30) := 'Get_Settings';
 l_api_version CONSTANT NUMBER       := 1.0;

 p_commit           VARCHAR2(1) := FND_API.g_true;
 p_init_msg_list    VARCHAR2(1) := FND_API.g_true;
 x_return_status    VARCHAR2(1000);
 x_msg_count        NUMBER;
 x_msg_data         VARCHAR2(1000);
 x_last_update_date DATE;

 l_order_header_rec   aso_quote_pub.Order_Header_Rec_Type ;
 l_qte_header_rec     aso_quote_pub.Qte_Header_Rec_Type;
 l_payment_tbl        aso_quote_pub.Payment_Tbl_Type;
 l_payment_rec        aso_quote_pub.Payment_Rec_Type;
 lx_payment_tbl       aso_quote_pub.Payment_Tbl_Type;

 l_cc_trxn_rec        ASO_PAYMENT_INT.CC_Trxn_Rec_Type;
 lx_cc_trxn_out_rec   ASO_PAYMENT_INT.CC_TRXN_OUT_REC_TYPE;

 l_control_rec        aso_quote_pub.Submit_Control_Rec_Type;

 l_max_date              DATE;
 l_earliest_time         DATE;
 l_consolidation_time_n  number := 60/1440; -- default to 60 minutes
 l_consolidation_time_s  varchar2(240);
 l_auth_pmt_offline_s    varchar2(240);
 l_oneclick_id           NUMBER;

 my_message              VARCHAR2(2000);
 l_count_good            NUMBER := 0;
 l_count_fail            NUMBER := 0;
 l_quote_status          aso_quote_statuses_vl.status_code%type;
 l_contract_template_id  NUMBER;
 l_hold_flag             VARCHAR2(1);


 CURSOR c_quotes(c_earliest_time DATE) IS
 SELECT  h.quote_header_id,
  h.total_quote_price,
  h.party_id,
  h.cust_account_id,
  h.org_id
 FROM aso_quote_headers h
 WHERE
  trunc(h.quote_expiration_date) >= trunc(sysdate) and
  h.quote_source_code = 'IStore Oneclick' and
  h.order_id is null and
  h.last_update_date < c_earliest_time;

 CURSOR c_settings(c_party_id NUMBER, c_acct_id NUMBER) IS
 SELECT  ord_oneclick_id
 FROM IBE_ORD_ONECLICK
 WHERE
  party_id = c_party_id and
  cust_account_id = c_acct_id;

 CURSOR c_quote_status_code (quote_hdr_id number) is
    select status_code
    from aso_quote_headers_all a,   aso_quote_statuses_vl b
    where quote_header_id = quote_hdr_id
    and a.quote_status_id = b.quote_status_id;

 rec_quote_status_code   c_quote_status_code%rowtype;

BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('start Submit Quotes');
END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting ibe_oneclk_pvt.Submit_Quotes Concurrent Program for organization id ' || FND_PROFILE.VALUE('ASO_PRODUCT_ORGANIZATION_ID'));
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting ibe_oneclk_pvt.Submit_Quotes Concurrent Program for MO organization id ' || MO_GLOBAL.get_current_org_id());
 SAVEPOINT  Submit_Quotes_Pvt;
 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call (l_api_version,
                                     1.0          ,
                                     l_api_name   ,
                                     G_PKG_NAME   )
 THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
  FND_MSG_PUB.initialize;
 END IF;

 -- Initialize API rturn status to success
 x_return_status := FND_API.g_ret_sts_success;

 FND_PROFILE.get('IBE_1CLICK_CONSOLIDATION_TIME',l_consolidation_time_s);
 FND_FILE.PUT_LINE(FND_FILE.LOG,'profile variable IBE_1CLICK_CONSOLIDATION_TIME:' || l_consolidation_time_s);
 -- convert to number and divide by minutes in a day to express in
 -- terms of days or fraction thereof
 if (l_consolidation_time_s is not null) then
   l_consolidation_time_n :=  to_number(l_consolidation_time_s) / 1440;
 end if;
 l_earliest_time := sysdate - l_consolidation_time_n;
 FND_FILE.PUT_LINE(FND_FILE.LOG,'Looking for quotes last updated before: ' || to_char(l_earliest_time,'DD-MON-YYYY:HH:MI:SS'));

 open c_quotes(l_earliest_time);
 loop
  -- give each loop a fair start
  x_return_status := FND_API.g_ret_sts_success;
  fetch c_quotes into
    l_qte_header_rec.quote_header_id,
    l_qte_header_rec.payment_amount,
    l_qte_header_rec.party_id,
    l_qte_header_rec.cust_account_id,
    l_qte_header_rec.org_id;
    exit when c_quotes%NOTFOUND;

FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
FND_FILE.PUT_LINE(FND_FILE.LOG,'#####  PROCESSING QUOTE ID:' || l_qte_header_rec.quote_header_id || ' #####');


-- if error check email and maybe insert a row for email notification
-- dbms_output.put_line('OneClick Concurrent Trying to Submit...');
-- Whether auth payment succeeds or not try to submit the quote
-- bug 2426483 - set to gmiss so proper defaulting will happen in IBE_QUOTE_CHECKOUT_PVT
l_control_rec.BOOK_FLAG := FND_API.G_MISS_CHAR;
FND_FILE.PUT_LINE(FND_FILE.LOG,'calling IBE_QUOTE_CHECKOUT_PVT.submitQuote ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG,'l_control_rec.BOOK_FLAG ' || l_control_rec.BOOK_FLAG);

--Need to call Contracts expert engine before placing the order to refresh the template with latest terms
--if user has made any changes to the cart.
--This needs to be done only if the quote status is not "APPROVED"
IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS') = 'Y' ) THEN --Only if contracts is enabled
  l_quote_status := IBE_QUOTE_MISC_PVT.get_aso_quote_status(l_qte_header_rec.quote_header_id);

  IF(upper(l_quote_status) <> 'APPROVED') THEN
    /*mannamra: changes for MOAC: Bug 4682364 	*/
    --l_contract_template_id := FND_PROFILE.VALUE('ASO_DEFAULT_CONTRACT_TEMPLATE'); old style
      l_contract_template_id := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_CONTRACT_TEMPLATE)); --New style
    /*mannamra: end of changes for MOAC*/

    IF (l_contract_template_id is not null) THEN

      OKC_XPRT_INT_GRP.get_contract_terms(
            p_api_version    => 1.0                   ,
            p_init_msg_list  => FND_API.g_false       ,
            P_document_type  => 'QUOTE'               ,
            P_document_id    => l_qte_header_rec.quote_header_id     ,
            P_template_id    => l_contract_template_id,
            P_called_from_UI => 'N'                   ,
            P_run_xprt_flag  => 'Y'                   ,
            x_return_status  => x_return_status       ,
            x_msg_count      => x_msg_count           ,
            x_msg_data       => x_msg_data            )  ;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF; --if quote_status not approved

END IF; -- if contracs enabled

IBE_QUOTE_CHECKOUT_PVT.submitQuote(
       P_Api_Version_Number => 1.0,
       P_Init_Msg_List      => FND_API.G_TRUE,
       P_commit             => FND_API.G_FALSE,
       P_quote_Header_Id    => l_qte_header_rec.quote_header_id,

       /* -- accept defaults for these parameters
         ,p_last_update_date         in  DATE     := FND_API.G_MISS_DATE
         ,p_sharee_party_Id          IN  NUMBER   := FND_API.G_MISS_NUM
         ,p_sharee_cust_account_id   IN  NUMBER   := FND_API.G_MISS_NUM
         ,p_sharee_number       IN  NUMBER   := FND_API.G_MISS_NUM
         ,p_customer_comments        IN  VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_reason_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR
         ,p_salesrep_email_id        IN  VARCHAR2 := FND_API.G_MISS_CHAR
       */
       P_submit_Control_Rec => l_control_rec,
       -- 9/17/02: added to not validate the user
       p_validate_user      => FND_API.G_FALSE,

       x_order_header_rec   => l_order_header_rec,
       x_Return_Status      => x_return_status ,
       x_Msg_Count          => x_msg_count ,
       x_Msg_Data           => x_msg_data,
       x_hold_flag          => l_hold_flag  );

FND_FILE.PUT_LINE(FND_FILE.LOG,'back from IBE_QUOTE_CHECKOUT_PVT.submitQuote ' || to_char(sysdate,'DD-MON-YYYY:HH24:MI:SS'));

if x_return_status <> FND_API.g_ret_sts_success then
  l_count_fail := l_count_fail + 1;
  FND_MESSAGE.SET_NAME('IBE','IBE_EXPR_PLSQL_API_ERROR');
  FND_MESSAGE.SET_TOKEN ( '0' , 'CONCURRENT PROGRAM - IBE_QUOTE_CHECKOUT_PVT.submitQuote' );
  FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
  FND_MSG_PUB.Add;

  if x_return_status = FND_API.G_RET_STS_ERROR then
    null;
  elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    null;
  end if;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Unsuccessful call to IBE_QUOTE_CHECKOUT_PVT.submitQuote');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Messages from FND_MSG_PUB....(if any):');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '    ' || fnd_msg_pub.get(p_encoded => FND_API.g_false));
  FND_FILE.PUT_LINE(FND_FILE.LOG, '    IBE_QUOTE_CHECKOUT_PVT.submitQuote returned ' || x_msg_count || ' messages.');
  if x_msg_count = 1 then
    FND_FILE.PUT_LINE(FND_FILE.LOG, '    ' || x_msg_data);
  else

    for i in 1..x_msg_count loop
      FND_FILE.PUT_LINE(FND_FILE.LOG, '    msg ' || i || ': ' || fnd_msg_pub.get(p_encoded => FND_API.g_false));
    end loop;
  end if;

else
  FND_FILE.PUT_LINE(FND_FILE.LOG,'SUCCESSFUL SUBMISSION - order number: ' || l_order_header_rec.order_number || ' / order status: ' || l_order_header_rec.status);
  l_count_good := l_count_good + 1;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Hold_flag is '||l_hold_flag);
end if;

FND_FILE.PUT_LINE(FND_FILE.LOG,'#####  DONE PROCESSING QUOTE ID:' || l_qte_header_rec.quote_header_id || ' #####');
IF FND_API.To_Boolean( p_commit ) THEN
  COMMIT WORK;
END IF;

end loop L_BIG_LOOP;
close c_quotes;


FND_FILE.PUT_LINE(FND_FILE.LOG, '**** Finished running ibe_oneclk_pvt.Submit_Quotes Concurrent Program for organization id ' || FND_PROFILE.VALUE('ASO_PRODUCT_ORGANIZATION_ID') || ' ****');
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Successful submissions: ' || to_char(l_count_good) || ' Failed to submit: ' || to_char(l_count_fail));

-- for the other log file
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '**** Ran ibe_oneclk_pvt.Submit_Quotes Concurrent Program for organization id ' || FND_PROFILE.VALUE('ASO_PRODUCT_ORGANIZATION_ID') || ' ****');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Successful submissions: ' || to_char(l_count_good) || ' Failed to submit: ' || to_char(l_count_fail));

IF FND_API.To_Boolean( p_commit ) THEN
  COMMIT WORK;
END IF;
FND_MSG_PUB.Count_And_Get
     (p_encoded   => FND_API.G_FALSE,
      p_count     => x_msg_count,
      p_data      => x_msg_data);

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('Exit submit quotes');
END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Submit_Quotes_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Expected Error exception.  Successful submissions: ' || to_char(l_count_good) || ' Failed to submit: ' || to_char(l_count_fail));
    errbuf := fnd_message.get;
    retcode := 2;

    FND_MSG_PUB.Count_And_Get(
     p_encoded   => FND_API.G_FALSE,
     p_count     => x_msg_count,
     p_data      => x_msg_data     );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO Submit_Quotes_Pvt;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected Error exception.  Successful submissions: ' || to_char(l_count_good) || ' Failed to submit: ' || to_char(l_count_fail));
  errbuf := fnd_message.get;
  retcode := 2;

  FND_MSG_PUB.Count_And_Get(
    p_encoded => FND_API.G_FALSE,
    p_count   => x_msg_count,
    p_data    => x_msg_data );

 WHEN OTHERS THEN
  ROLLBACK TO Submit_Quotes_Pvt;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Other Error exception.  Successful submissions: ' || to_char(l_count_good) || ' Failed to submit: ' || to_char(l_count_fail));

  errbuf  := fnd_message.get;
  retcode := 2;
  IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    FND_MSG_PUB.Add_Exc_Msg(
             G_PKG_NAME,
             l_api_name);
  END IF;

    FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data      => x_msg_data);

end Submit_Quotes;

end ibe_oneclk_pvt;

/
